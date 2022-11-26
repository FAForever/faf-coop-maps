local AIUtils = import('/lua/ai/aiutilities.lua')
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')

local UEF = 2
local Cybran = 4

local Difficulty = ScenarioInfo.Options.Difficulty

function UnitsMultiplyMaxFuel(units, num)
    for _, unit in units do
        local bp = unit:GetBlueprint()
        
        if bp.Physics.FuelUseTime then
            unit:SetFuelUseTime(bp.Physics.FuelUseTime * num)
        end
    end
end

function CarrierAI(platoon)
    platoon:Stop()

    local aiBrain = platoon:GetBrain()
    local data = platoon.PlatoonData
    local carriers = platoon:GetPlatoonUnits()
    local movePositions = {}

    if not data then
        error('*Carrier AI ERROR: PlatoonData not defined', 2)
    elseif not (data.MoveRoute or data.MoveChain) then
        error('*Carrier AI ERROR: MoveToRoute or MoveChain not defined', 2)
    end

    if data.MoveChain then
        movePositions = ScenarioUtils.ChainToPositions(data.MoveChain)
    else
        for k, v in data.MoveRoute do
            if type(v) == 'string' then
                table.insert(movePositions, ScenarioUtils.MarkerToPosition(v))
            else
                table.insert(movePositions, v)
            end
        end
    end

    local numCarriers = table.getn(carriers)
    local numPositions = table.getn(movePositions)

    if numPositions < numCarriers then
        error('*Carrier AI ERROR: Less move positions than carriers', 2)
    end

    for i = 1, numCarriers do
        ForkThread(function(i)
            IssueMove({carriers[i]}, movePositions[i])

            while not carriers[i].Dead and carriers[i]:IsUnitState('Moving') do
                WaitSeconds(.5)
            end

            if carriers[i].Dead then
                return
            end

            for num, loc in aiBrain.PBM.Locations do
                if loc.LocationType == data.Location .. i then
                    loc.PrimaryFactories.Air = carriers[i]
                    break
                end
            end

            while not carriers[i].Dead do
                if table.getn(carriers[i]:GetCargo()) > 0 and carriers[i]:IsIdleState() then
                    IssueClearCommands({carriers[i]})
                    IssueTransportUnload({carriers[i]}, carriers[i]:GetPosition())
                end
                WaitSeconds(1)
            end
        end, i)
    end
end

-- Waits until all units are released from the carrier and then issues the patrol.
function PatrolThread(platoon)
    local data = platoon.PlatoonData

    if data.Carrier then
        for _, unit in platoon:GetPlatoonUnits() do
            while (not unit.Dead and unit:IsUnitState('Attached')) do
                WaitSeconds(1)
            end
        end
    end

    platoon:Stop()

    if not data then
        error('*Custom Functions: PlatoonData not defined', 2)
    elseif not (data.PatrolRoute or data.PatrolChain) then 
        error('*Custom Functions: PatrolRoute or PatrolChain not defined', 2)
    end

    if data.PatrolChain then
        ScenarioFramework.PlatoonPatrolChain(platoon, data.PatrolChain)
    else
        ScenarioFramework.PlatoonPatrolRoute(platoon, data.PatrolRoute)
    end
end

function MergePlatoonToNavalForce(platoon)
    local brain = platoon:GetBrain()
    local plat = brain:GetPlatoonUniquelyNamed('NavalForce')
    -- Attack', 'Artillery', 'Guard' 'None', 'Scout', 'Support
    for _, unit in platoon:GetPlatoonUnits() do
        if EntityCategoryContains(categories.xes0307, unit) then           -- Battle Cruiser
            brain:AssignUnitsToPlatoon(plat, {unit}, 'Attack', 'AttackFormation')
        elseif EntityCategoryContains(categories.BATTLESHIP, unit) then    -- Battleship
            brain:AssignUnitsToPlatoon(plat, {unit}, 'Artillery', 'AttackFormation')
        elseif EntityCategoryContains(categories.DESTROYER, unit) then     -- Destroyer
            brain:AssignUnitsToPlatoon(plat, {unit}, 'Attack', 'AttackFormation')
        elseif EntityCategoryContains(categories.CRUISER, unit) then       -- Cruiser
            brain:AssignUnitsToPlatoon(plat, {unit}, 'Support', 'AttackFormation')
        elseif EntityCategoryContains(categories.SHIELD, unit) then        -- Sheild Boat
            brain:AssignUnitsToPlatoon(plat, {unit}, 'Guard', 'AttackFormation')
        elseif EntityCategoryContains(categories.xes0102, unit) then       -- Torpedo Boat
            brain:AssignUnitsToPlatoon(plat, {unit}, 'Support', 'AttackFormation')
        elseif EntityCategoryContains(categories.FRIGATE, unit) then       -- Frigate
            brain:AssignUnitsToPlatoon(plat, {unit}, 'Scout', 'AttackFormation')
        elseif EntityCategoryContains(categories.T1SUBMARINE, unit) then   -- Submarine
            brain:AssignUnitsToPlatoon(plat, {unit}, 'Scout', 'AttackFormation')
        end
    end
    brain:DisbandPlatoon(platoon)
end

function NavalForceAI(platoon)
    local brain = platoon:GetBrain()
    if not ScenarioInfo.M3NavalPlatoon then
        ScenarioInfo.M3NavalPlatoon = brain:MakePlatoon('', '')
        ScenarioInfo.M3NavalPlatoon:UniquelyNamePlatoon('NavalForce')
        MergePlatoonToNavalForce(platoon)
    end

    local plat = brain:GetPlatoonUniquelyNamed('NavalForce')

    local chains = {'M3_UEF_Naval_Force_Chain'}
    local positions = ScenarioUtils.ChainToPositions(chains[1])
    local lastPos = 0

    --[[
    local function NextPosition(currentPosition, tblPositions. lastPosition)
        local pos = {}
        local min
        local data = tblPositions

        if not lastPosition then
            return tblPositions[1]
        end

        for _, v in data do
            -- local Utils = import('/lua/utilities.lua')
            -- local distance = GetDistanceBetweenTwoPoints(currentPosition[1], currentPosition[2], currentPosition[3], v[1], v[2], v[3])
            local distance = VDist3(currentPosition, v)
            if not min and not lastPosition == v or distance < min then
                min = distance
                pos = v
            end
        end
        return pos
    end
    --]]
    local function ShielBoatAssist(platoon)
        local battleships = platoon:GetSquadUnits('Artillery')
        --local battlecruisers = platoon:GetSquadUnits('BattleCruisers')
        local shieldBoats = platoon:GetSquadUnits('Guard')
        local pos = platoon:GetSquadPosition('Artillery')
        local needGuard = {}
        local canGuard = {}
        local remainingShields = {}

        for _, unit in shieldBoats do
            if unit:ShieldIsOn() and not unit:IsUnitState('Guarding') then --unit:GetShieldRatio(unit)
                table.insert(canGuard, unit)
            elseif not unit:ShieldIsOn() then
                table.insert(remainingShields, unit)
            end
        end

        local function UnitsNeedGuard(tblResult, group)
            for num, unit in group do
                --unit:SetCustomName(num)
                local guards = unit:GetGuards()
                --LOG('Unit ' .. num .. ' num of guards ' .. table.getn(unit:GetGuards()))
                if table.getn(unit:GetGuards()) == 0 then
                    table.insert(needGuard, unit)
                else
                    for _, v in guards do
                        if not v:ShieldIsOn() then
                            table.insert(needGuard, unit)
                        end
                    end
                end
            end
        end
        UnitsNeedGuard(needGuard, battleships)
        --UnitsNeedGuard(needGuard, battlecruisers)

        LOG('SHIELDS: Num need guard: ' .. table.getn(needGuard))

        for i = 1, table.getn(canGuard) do
            if needGuard[i] then
                IssueStop({canGuard[i]})
                IssueClearCommands({canGuard[i]})
                IssueGuard({canGuard[i]}, needGuard[i])
            else
                table.insert(remainingShields, canGuard[i])
            end
        end

        if table.getn(remainingShields) > 0 then
            LOG('SHIELDS: Num remaining units: ' .. table.getn(remainingShields))
            IssueStop(remainingShields)
            IssueClearCommands(remainingShields)
            IssueMove(remainingShields, {pos[1], pos[2], pos[3] - 30})
        end
    end

    --- Assign up to 2 cruisers to 1 battleship.
    -- Issue a move command close to the battleship from each side.
    -- TODO: Override the move command to get in front of the battleships in case of danger from air.
    local function CruiserGuard(platoon)
        local cruisers = platoon:GetSquadUnits('Support')
        local battleships = platoon:GetSquadUnits('Artillery')
        local availableCruisers = {}
        local remainingCruisers = {}
        local guardingCruisers = {}
        local needCruisers = {
            [1] = {},
            [2] = {},
        }

        for _, unit in cruisers do
            if not unit.AssignedBattleship or unit.AssignedBattleship.Dead then
                unit.AssignedBattleship = nil
                table.insert(availableCruisers, unit)
            else
                table.insert(guardingCruisers, unit)
            end
        end

        for _, unit in guardingCruisers do
            local pos = unit.AssignedBattleship:GetPosition()
            IssueStop({unit})
            IssueClearCommands({unit})
            IssueMove({unit}, {pos[1] - unit.offSet, pos[2], pos[3] - 15})
        end

        if table.getn(availableCruisers) == 0 then
            return
        end

        for _, unit in battleships do
            if not unit.AssignedCruisers then
                unit.AssignedCruisers = {}
                table.insert(needCruisers[2], unit)
                table.insert(needCruisers[1], unit)
            else
                local alive = 0
                for k, v in unit.AssignedCruisers do
                    if not v.Dead then
                        alive = alive + 1
                    else
                        table.remove(availableCruisers, k)
                    end
                end

                if alive == 0 then
                    table.insert(needCruisers[2], unit)
                    table.insert(needCruisers[1], unit)
                elseif alive == 1 then
                    table.insert(needCruisers[1], unit)
                end
            end
        end

        local function AssignCruiserToBattleship(cruiser, battleship)
            local pos = battleship:GetPosition()
            cruiser.offSet = -15
            if battleship.AssignedCruisers[1].offSet == cruiser.offSet then
                cruiser.offSet = 15
            end

            cruiser.AssignedBattleship = battleship
            table.insert(battleship.AssignedCruisers, cruiser)

            IssueStop({cruiser})
            IssueClearCommands({cruiser})
            IssueMove({cruiser}, {pos[1] - cruiser.offSet, pos[2], pos[3] - 15})
        end

        needCruisers = table.cat(needCruisers[2], needCruisers[1])

        LOG('CRUISERS: Num BS need cruisers: ' .. table.getn(needCruisers))

        for i = 1, table.getn(availableCruisers) do
            if needCruisers[i] then
                AssignCruiserToBattleship(availableCruisers[i], needCruisers[i])
            else
                table.insert(remainingCruisers, availableCruisers[i])
            end
        end

        if table.getn(remainingCruisers) > 0 then
            LOG('SHIELDS: Num remaining units: ' .. table.getn(remainingCruisers))
            IssueStop(remainingCruisers)
            --IssueClearCommands(remainingCruisers)
            IssueMove(remainingCruisers, {position[1], position[2], position[3] - 40})
        end
    end

    local cmdAttackMove

    while brain:PlatoonExists(plat) do
        local currentPos = plat:GetSquadPosition('Artillery')

        -- Battleships attack
        if not cmdAttackMove or not plat:IsCommandsActive(cmdAttackMove) then
            lastPos = lastPos + 1
            local pos = positions[lastPos]
            if pos then
                cmdAttackMove = plat:AggressiveMoveToLocation(positions[lastPos], 'Artillery')
            end
        end

        ShielBoatAssist(plat)
        CruiserGuard(plat)

        WaitSeconds(5)
    end
    WARN('Something went wrong, platoon doesnt exist anymore.')
end

--------------------------
-- Novax Manager functions
--------------------------
-- {defending, attacking}
--local totalNovaxNum = {{3, 1}, {4, 2}, {6, 3}}
local totalDefending = {3, 4, 6}

local currentDefending = 0
local currentAttacking = 0

--- Decides if the Novax should patrol or attack
-- Currently Novaxes wont be rebuilt by the AI if destroyed.
function ManageNovaxThread(platoon)
    local function DecrementNovaxCount(unit)
        currentDefending = currentDefending - 1
        --LOG('NOVAX: Left defending: ' .. currentDefending)
    end

    if not platoon.PlatoonData then
        platoon.PlatoonData = {}
    end

    -- Decide what to do with the Novax
    if currentDefending < totalDefending[Difficulty] then
        local unit = platoon:GetPlatoonUnits()[1]
        ScenarioFramework.CreateUnitDeathTrigger(DecrementNovaxCount, unit)
        currentDefending = currentDefending + 1
        --LOG('NOVAX: New novax will defend. Currently defending: ' .. currentDefending)

        platoon.PlatoonData.PatrolChain = 'M3_UEF_Base_Novax_Patrol_Chain'
        ScenarioPlatoonAI.RandomDefensePatrolThread(platoon)
    else
        currentAttacking = currentAttacking + 1

        platoon.PlatoonData.TargetCats = (categories.TECH3 + categories.EXPERIMENTAL) * categories.MOBILE * categories.NAVAL
        platoon.PlatoonData.AttackChain = 'Nuke_Players_Chain'
        --LOG('NOVAX: New novax will attack.')

        --if currentAttacking <= 2 then
            platoon:StopAI()
            platoon:ForkAIThread(PlatoonAttackClosestPriorityUnit)
        --else
        --    ScenarioPlatoonAI.PlatoonAttackHighestThreat(platoon)
        --end
    end
end

local navalTargets = {}
local function GetTargetsForNovax(armyId, cats) 
    local result = {}

    for i, strArmy in ListArmies() do
        if IsEnemy(armyId, i) then
            local units = ArmyBrains[i]:GetListOfUnits(cats, false)

            for _, unit in units do
                table.insert(result, unit)
            end
        end
    end

    -- sort the unit by their Z position (aka by closest to the UEF base)
    table.sort(result, function(a, b) return a:GetPosition()[3] < b:GetPosition()[3] end)
    navalTargets = result
end

function PlatoonAttackClosestPriorityUnit(platoon)
    local aiBrain = platoon:GetBrain()
    local target
    local defaultAttack = false

    while aiBrain:PlatoonExists(platoon) do
        if not target or target.Dead or target:GetCurrentLayer() == 'Sub' then
            -- refresh the target list
            GetTargetsForNovax(aiBrain:GetArmyIndex(), platoon.PlatoonData.TargetCats)

            for _, unit in navalTargets do
                if not unit.Dead and platoon:CanAttackTarget('Attack', unit) then
                    target = unit
                    defaultAttack = false

                    platoon:Stop()
                    platoon:AttackTarget(target)
                    break
                end
            end

            -- No valid target found, attack move instead
            if not defaultAttack and (not target or target.Dead) then
                defaultAttack = true
                ScenarioFramework.PlatoonAttackChain(platoon, platoon.PlatoonData.AttackChain)
            end
        end

        WaitSeconds(20)
    end
end

---------------------------------
-- Attack with land experimentals
---------------------------------
-- Used for both Cybran and UEF land experimentals.
function LandExperimentalAttackThread(platoon)
    local moveChains = {'M2_Experimental_Move_Chain_1', 'M2_Experimental_Move_Chain_2', 'M2_Experimental_Move_Chain_3'}

    -- First move spider/fatboy on the island, then start attacking, so it doesn't try to attack anything on attack range with torpedoes
    ScenarioFramework.PlatoonMoveChain(platoon, moveChains[Random(1, table.getn(moveChains))])
    ScenarioFramework.PlatoonAttackChain(platoon, 'M2_Player_Island_Drop_Chain')
end

--- Merges units produced by the Base Manager conditional build into the same platoon.
-- PlatoonData = {
--     Name - String, unique name for this platoon
--     NumRequired - Number of experimentals to start moving the platoon
--     PatrolChain - Name of the chain to use
-- }
function AddExperimentalToPlatoon(platoon)
    local brain = platoon:GetBrain()
    local data = platoon.PlatoonData
    local name = data.Name
    local unit = platoon:GetPlatoonUnits()[1]
    local plat = brain:GetPlatoonUniquelyNamed(name)
    local spawnThread = false

    if not plat then
        plat = brain:MakePlatoon('', '')
        plat:UniquelyNamePlatoon(name)
        plat:SetPlatoonData(data)
        spawnThread = true
    end

    brain:AssignUnitsToPlatoon(plat, {unit}, 'Attack', 'AttackFormation')
    brain:DisbandPlatoon(platoon)

    if spawnThread then
        ForkThread(MultipleExperimentalsThread, plat)
    end
end

--- Handles an unique platoon of multiple experimentals.
function MultipleExperimentalsThread(platoon)
    local brain = platoon:GetBrain()
    local data = platoon.PlatoonData

    while brain:PlatoonExists(platoon) do
        if not platoon:IsPatrolling('Attack') then
            local numAlive = 0
            for _, v in platoon:GetPlatoonUnits() do
                if not v.Dead then
                    numAlive = numAlive + 1
                end
            end

            if numAlive == data.NumRequired then
                ScenarioFramework.PlatoonPatrolChain(platoon, data.PatrolChain)
            end
        end
        WaitSeconds(10)
    end
end

--- Enables stealth on air untis
function EnableStealthOnAir()
    local T3AirUnits = {}
    while true do
        for _, v in ArmyBrains[Cybran]:GetListOfUnits(categories.ura0303 + categories.ura0304 + categories.ura0401, false) do
            if not (T3AirUnits[v:GetEntityId()] or v:IsBeingBuilt()) then
                v:ToggleScriptBit('RULEUTC_StealthToggle')
                T3AirUnits[v:GetEntityId()] = true
            end
        end
        WaitSeconds(15)
    end
end

-- TODO
-- OnNukeArmed = function(self) -- loaded
-- OnNukeLaunched = function(self) -- starting to fire
-- NukeCreatedAtUnit = function(self) -- missile created
function M3CybranNukeSubmarinesHandle(platoon)
    local data = platoon.PlatoonData
    local positions = ScenarioUtils.ChainToPositions(data.MoveChain)

    platoon:Stop()

    for i, unit in platoon:GetPlatoonUnits() do
        --unit:SetAutoMode(true)

        local pos = positions[i]
        IssueMove({unit}, pos)
        unit.IdlePosition = pos

        unit:ForkThread(M3NukeSubWaitTillLoaded, data.NukeDelay[Difficulty])
    end
end

function M3NukeSubWaitTillLoaded(unit, delay)
    repeat
        -- Delay between nuking
        WaitSeconds(delay)

        if unit.Dead then
            return
        end

        local targetPosition
        while not targetPosition do
            targetPosition = FindTargetToNuke(unit)

            if targetPosition then
                unit:GiveNukeSiloAmmo(1)
                IssueNuke({unit}, targetPosition)

                -- IssueNuke does not end when the nuke is fired, so gotta clear it manually
                while not unit.Dead and unit:GetNukeSiloAmmoCount() == 1 do
                    WaitSeconds(10)
                end

                if unit.Dead then
                    return
                end

                IssueClearCommands({unit})
                IssueMove({unit}, unit.IdlePosition)

                targetPosition = false
                break
            end

            WaitSeconds(20)
        end
    until unit.Dead

    --[[
    while unit and not unit.Dead do
        if unit:GetNukeSiloAmmoCount() > 0 and not cmd then
            local targetPosition = FindTargetToNuke(unit)

            if not unit.Dead and targetPosition then
                IssueNuke({unit}, targetPosition)
                local cmd = IssueMove({unit}, unit.IdlePosition)
                
                repeat
                    WaitSeconds(15)
                until IsCommandDone(cmd) or unit.Dead

                if not unit.Dead then
                    cmd = false
                else
                    return
                end
            end
        else
            WaitSeconds(20)
        end
    end
    --]]
end

function FindTargetToNuke(unit)
    local aiBrain = unit:GetAIBrain()
    local data = unit.PlatoonHandle.PlatoonData

    local mostUnits = 0
    local bestTarget = nil
    local searching = true

    if not data.TargetChain then
        error('*speed2: FindTargetToNuke missing a TargetChain')
    end
    local positions = ScenarioUtils.ChainToPositions(data.TargetChain)

    while true do
        WaitSeconds(15)
        for i, pos in positions do
            local num = table.getn(aiBrain:GetUnitsAroundPoint(data.TargetCategory or ((categories.TECH2 * categories.STRUCTURE) + (categories.TECH3 * categories.STRUCTURE)), pos, 30, 'enemy'))
            if num > 3 and num > mostUnits then
                mostUnits = num
                bestTarget = pos
            end

            if i == table.getn(positions) and bestTarget then
                return bestTarget
            end
        end
    end
end

--------------
-- Atlantis AI
--------------
--[[
Atlantis near the UEF base, stays underwater and builds ASFs to respond to nearby air experimentals.
ASF platoon hunts down any air experimentals and return to Atlantis again.
--]]
local TargetsForASFs = {}
function UpdateASFsTargets(targetCats, rect, atlantisPos)
    --LOG("Atlantis updating targets")
    local units = GetUnitsInRect(rect)
    if units then
        units = EntityCategoryFilterDown(targetCats, units)
    end

    local result = {}
    for _, unit in units do
        if IsEnemy(UEF, unit:GetArmy()) then
            table.insert(result, unit)
        end
    end
    units = result

    -- Sort the targets by the distance to the atlantis
    if units[1] then
        table.sort(units, function(a, b)
            local posA = a:GetPosition()
            local posB = b:GetPosition()
            return VDist2(posA[1], posA[3], atlantisPos[1], atlantisPos[3]) < VDist2(posB[1], posB[3], atlantisPos[1], atlantisPos[3])
        end)
    end

    --LOG("Atlantis targets updated. currently: " .. table.getn(TargetsForASFs))

    TargetsForASFs = units
end

local maxASFs = {32, 44, 56}
local minASFs = 25
function AtlantisThread(platoon)
    local brain = platoon:GetBrain()
    local atlantis = platoon:GetPlatoonUnits()[1]

    local rect = ScenarioUtils.AreaToRect('M3_Atlantis_Guard_Area')
    local targetCats = categories.AIR * categories.MOBILE * categories.EXPERIMENTAL

    --[[
    PlatoonData = {
        Radius = 500,
        MaxUnits = 50,
        MinUnits = 20,
        UnitToBuild = 'uea0303',
        TargetCategories = categories.AIR * categories.MOBILE * categories.EXPERIMENTAL,
    }
    --]]

    local function assingASFsToPlatoon()
        if not atlantis.ASFsPlatoon then
            --LOG("Atlantis creating a new platoon")
            atlantis.ASFsPlatoon = brain:MakePlatoon('', '')
            SetUpCarrierPlatoon(atlantis.ASFsPlatoon, atlantis)
        end

        local new = 0
        for _, unit in atlantis:GetCargo() do
            if EntityCategoryContains(categories.uea0303, unit) and (not unit.PlatoonHandle or unit.PlatoonHandle ~= atlantis.ASFsPlatoon) then
                brain:AssignUnitsToPlatoon(atlantis.ASFsPlatoon, {unit}, 'Attack', 'NoFormation') --AttackFormation
                new = new + 1
            end
        end
        --LOG("Atlantis current cargo: " .. table.getn(atlantis:GetCargo()) .." added new ASFs to platoon: " .. new .. " total in platoon: " .. (atlantis.ASFsPlatoon:PlatoonCategoryCount(categories.uea0303) or 0))
    end

    local function canDeployASFs()
        local asfs = EntityCategoryFilterDown(categories.uea0303, atlantis:GetCargo())
        if not atlantis.ASFsDeployed and table.getn(asfs) >= minASFs then
            return true
        end
        return false
    end

    local function deployASFs()
        if atlantis:IsUnitState('Building') then
            IssueStop({atlantis})
            IssueClearCommands({atlantis})
        end

        platoon:UnloadUnitsAtLocation(categories.uea0303, platoon:GetPlatoonPosition())
        atlantis.ASFsPlatoon:SetAIPlan('CP_WaitUntilAllDeployed')
        IssueDive({atlantis})
    end

    local function buildASFs()
        local numASFsInPlatoon = (atlantis.ASFsPlatoon and atlantis.ASFsPlatoon:PlatoonCategoryCount(categories.uea0303)) or 0
        local cargo = 0

        for _, unit in atlantis:GetCargo() do
            if unit.PlatoonHandle and unit.PlatoonHandle ~= atlantis.ASFsPlatoon then
                cargo = cargo + 1
            end
        end
        --LOG("Atlantis current cargo: " .. table.getn(atlantis:GetCargo()) .. " from that in the ASF platoon: " .. cargo)

        local toBuild = maxASFs[Difficulty] - numASFsInPlatoon - cargo
        --LOG("Atlantis checking to build ASFs, needing: " .. toBuild)
        if toBuild > 0 then
            IssueBuildFactory({atlantis}, 'uea0303', toBuild)
        end
    end

    while brain:PlatoonExists(platoon) do
        UpdateASFsTargets(targetCats, rect, platoon:GetPlatoonPosition())

        if TargetsForASFs[1] then
            if canDeployASFs() then
                atlantis.ASFsDeployed = true

                assingASFsToPlatoon()

                deployASFs()
            end
        end

        if atlantis:IsIdleState() then
            buildASFs()
        end

        WaitSeconds(10)
    end
end

function SetUpCarrierPlatoon(platoon, carrier)
    platoon.Carrier = carrier

    -- In case the platoon dies, unlock the carrier to launch another onee
    local function platoonDestroyed(brain, platoon)
        --LOG('ASF Platoon is destroyed')
        platoon.Carrier.ASFsDeployed = false
        platoon.Carrier.ASFsPlatoon = nil
    end
    platoon:AddDestroyCallback(platoonDestroyed)

    platoon.CP_WaitUntilAllDeployed = function(platoon)
        for _, unit in platoon:GetPlatoonUnits() do
            if not unit.Dead and unit:IsUnitState('Attached') then
                --LOG("ASF Platoon waiting for all to be deplyed")
                WaitSeconds(3)
            end
        end
        
        platoon:SetAIPlan('CP_StartAirAttack')
    end

    platoon.CP_StartAirAttack = function(platoon)
        platoon:Stop()

        --LOG("ASF Platoon starting attack")

        local brain = platoon:GetBrain()

        local currentTarget = false
        while brain:PlatoonExists(platoon) do
            --LOG("ASF Platoon main loop")
            if not currentTarget or currentTarget.Dead then
                for _, target in TargetsForASFs do
                    if not target.Dead then
                        currentTarget = target
                        --LOG("ASF PLatoon new target set: " .. currentTarget.UnitId .. " position: ".. repr(currentTarget:GetPosition()))
                        platoon:AttackTarget(currentTarget)
                        break
                    end
                end
            end

            -- No new targets
            if currentTarget.Dead then 
                if platoon.Carrier.Dead then
                    platoon:SetAIPlan('CP_DefaultPatrol')
                else
                    platoon:SetAIPlan('CP_ReturnToCarrier')
                end
            end

            WaitSeconds(7)
        end
    end

    platoon.CP_ReturnToCarrier = function(platoon)
        platoon:Stop()

        local units = platoon:GetPlatoonUnits()
        IssueClearCommands({platoon.Carrier})
        IssueTransportLoad(units, platoon.Carrier)
        IssueDive({platoon.Carrier})

        for _, unit in units do
            while not unit.Dead and not unit:IsUnitState('Attached') and not platoon.Carrier.Dead do
                WaitSeconds(3)
            end
        end

        if platoon.Carrier.Dead then
            platoon:SetAIPlan('CP_DefaultPatrol')
        else
            platoon.Carrier.ASFsDeployed = false
        end
    end

    platoon.CP_DefaultPatrol = function(platoon)
        platoon:Stop()
        --LOG("ASF Platoon Carrier is dead, switching to default patrol")
        for _, v in platoon:GetPlatoonUnits() do
            ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M3_UEF_Base_Novax_Patrol_Chain')))
        end
    end

    platoon.CP_Wait = function(platoon)
        while true do
            WaitSeconds(60)
        end
    end
end

--- Build condition
-- Returns true if mass in storage of <aiBrain> is less than <mStorage>
function LessMassStorageCurrent(aiBrain, mStorage)
    local econ = AIUtils.AIGetEconomyNumbers(aiBrain)
    if econ.MassStorage < mStorage then
        return true
    end
    return false
end

-- orders group to patrol a route in formation
function GroupFormPatrolChain(group, chain, formation)
    for _, v in ScenarioUtils.ChainToPositions(chain) do
        IssueFormPatrol(group, v, formation, 0)
    end
end

-- Patrol in formation that sets the correct orientation at the patrol point instead of the default "south"
function PlatoonPatrolChain(platoon, chain, squad)
    local formation = (platoon.PlatoonData and (platoon.PlatoonData.OverrideFormation or platoon.PlatoonData.UseFormation)) or 'AttackFormation'
    local positions = ScenarioUtils.ChainToPositions(chain)
    local units = nil
    
    if squad then
        units = platoon:GetSquadUnits(squad)
    else
        units = platoon:GetPlatoonUnits()
    end

    for i, pos in positions do
        local dir = VDiff(positions[i + 1] or positions[1], pos)
        local angle = math.atan2(dir[3], dir[1]) * 180 / math.pi
        IssueFormPatrol(units, pos, formation, angle)
    end
end
