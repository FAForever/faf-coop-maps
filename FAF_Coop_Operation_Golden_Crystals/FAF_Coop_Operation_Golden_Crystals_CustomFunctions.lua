local AIUtils = import('/lua/ai/aiutilities.lua')
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')

local Cybran = 4

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

    if(data) then
        if(data.MoveRoute or data.MoveChain) then
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

            if numCarriers <= numPositions then
                for i = 1, numCarriers do
                    ForkThread(function(i)
                        IssueMove( {carriers[i]}, movePositions[i] )

                        while (carriers[i] and not carriers[i].Dead and carriers[i]:IsUnitState('Moving')) do
                            WaitSeconds(.5)
                        end

                        local location
                        for num, loc in aiBrain.PBM.Locations do
                            if loc.LocationType == data.Location .. i then
                                location = loc
                                break
                            end
                        end

                        if not carriers[i].Dead then
                            location.PrimaryFactories.Air = carriers[i]
                        end

                        while (carriers[i] and not carriers[i].Dead) do
                            if table.getn(carriers[i]:GetCargo()) > 0 and carriers[i]:IsIdleState() then
                                IssueClearCommands(carriers[i])
                                IssueTransportUnload({carriers[i]}, carriers[i]:GetPosition())
                            end
                            WaitSeconds(1)
                        end
                    end, i)
                end             
            else
                error('*Carrier AI ERROR: Less move positions than carriers', 2)
            end
        else
            error('*Carrier AI ERROR: MoveToRoute or MoveChain not defined', 2)
        end
    else
        error('*Carrier AI ERROR: PlatoonData not defined', 2)
    end
end

function PatrolThread(platoon)
    local data = platoon.PlatoonData

    if(data.Carrier) then
        for _, unit in platoon:GetPlatoonUnits() do
            while (not unit.Dead and unit:IsUnitState('Attached')) do
                WaitSeconds(1)
            end
        end
    end

    platoon:Stop()
    if(data) then
        if(data.PatrolRoute or data.PatrolChain) then
            if data.PatrolChain then
                ScenarioFramework.PlatoonPatrolRoute(platoon, ScenarioUtils.ChainToPositions(data.PatrolChain))
            else
                for k,v in data.PatrolRoute do
                    if type(v) == 'string' then
                        platoon:Patrol(ScenarioUtils.MarkerToPosition(v))
                    else
                        platoon:Patrol(v)
                    end
                end
            end
        else
            error('*SCENARIO PLATOON AI ERROR: PatrolRoute or PatrolChain not defined', 2)
        end
    else
        error('*SCENARIO PLATOON AI ERROR: PlatoonData not defined', 2)
    end
end

function MergePlatoonToNavalForce(platoon)
    local brain = platoon:GetBrain()
    local plat = brain:GetPlatoonUniquelyNamed('NavalForce')

    for _, unit in platoon:GetPlatoonUnits() do
        if EntityCategoryContains(categories.xes0307, unit) then           -- Battle Cruiser
            brain:AssignUnitsToPlatoon(plat, {unit}, 'BattleCruisers', 'AttackFormation')
        elseif EntityCategoryContains(categories.BATTLESHIP, unit) then    -- Battleship
            brain:AssignUnitsToPlatoon(plat, {unit}, 'Artillery', 'AttackFormation')
        elseif EntityCategoryContains(categories.DESTROYER, unit) then     -- Destroyer
            brain:AssignUnitsToPlatoon(plat, {unit}, 'Attack', 'AttackFormation')
        elseif EntityCategoryContains(categories.CRUISER, unit) then       -- Cruiser
            brain:AssignUnitsToPlatoon(plat, {unit}, 'Support', 'AttackFormation')
        elseif EntityCategoryContains(categories.SHIELD, unit) then        -- Sheild Boat
            brain:AssignUnitsToPlatoon(plat, {unit}, 'Guard', 'AttackFormation')
        elseif EntityCategoryContains(categories.xes0102, unit) then       -- Torpedo Boat
            brain:AssignUnitsToPlatoon(plat, {unit}, 'SubHunters', 'AttackFormation')
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
    LOG('NOVAX: Adding new one.')
    local function DecrementNovaxCount(unit)
        currentDefending = currentDefending - 1
        LOG('NOVAX: Left defending: ' .. currentDefending)
    end

    -- Decide what to do with the Novax
    if currentDefending < totalDefending[ScenarioInfo.Options.Difficulty] then
        local unit = platoon:GetPlatoonUnits()[1]
        ScenarioFramework.CreateUnitDeathTrigger(DecrementNovaxCount, unit)
        currentDefending = currentDefending + 1
        LOG('NOVAX: New novax will defend. Currently defending: ' .. currentDefending)

        if not platoon.PlatoonData then
            platoon.PlatoonData = {}
        end
        platoon.PlatoonData.PatrolChain = 'M3_UEF_Base_Novax_Patrol_Chain'
        ScenarioPlatoonAI.RandomDefensePatrolThread(platoon)
    else
        currentAttacking = currentAttacking + 1
        LOG('NOVAX: New novax will attack.')

        --if currentAttacking <= 2 then
        --    ScenarioPlatoonAI.PlatoonAttackClosestPriorityUnit(platoon)
        --else
            ScenarioPlatoonAI.PlatoonAttackHighestThreat(platoon)
        --end
    end
end

function PlatoonAttackClosestPriorityUnit(platoon)
    local aiBrain = platoon:GetBrain()
    local target

    while not target do
        target = platoon:FindClosestUnit('Attack', 'Enemy', true, categories.TECH3 * categories.MOBILE * categories.NAVAL)
        WaitSeconds(3)
    end
    platoon:Stop()

    local cmd = platoon:AggressiveMoveToLocation(target:GetPosition())
    while aiBrain:PlatoonExists(platoon) do
        if target ~= nil then
            if target.Dead or not platoon:IsCommandsActive(cmd) then
                target = platoon:FindClosestUnit('Attack', 'Enemy', true, categories.TECH3 * categories.MOBILE * categories.NAVAL)
                if target and not target.Dead then
                    platoon:Stop()
                    cmd = platoon:AggressiveMoveToLocation(target:GetPosition())
                end
            end
        else
            target = platoon:FindClosestUnit('Attack', 'Enemy', true, categories.TECH2 * categories.MOBILE * categories.NAVAL)
        end
        WaitSeconds(17)
    end
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
                for _, v in ScenarioUtils.ChainToPositions(data.PatrolChain) do
                    platoon:Patrol(v)
                end
            end
        end
        WaitSeconds(10)
    end
end

--- Enables stealth on air untis
function EnableStealthOnAir()
    local T3AirUnits = {}
    while true do
        for _, v in ArmyBrains[Cybran]:GetListOfUnits(categories.ura0303 + categories.ura0304, false) do
            if not (T3AirUnits[v:GetEntityId()] or v:IsBeingBuilt()) then
                v:ToggleScriptBit('RULEUTC_StealthToggle')
                T3AirUnits[v:GetEntityId()] = true
            end
        end
        WaitSeconds(15)
    end
end

function M3CybranNukeSubmarinesHandle(platoon)
    local data = platoon.PlatoonData
    local positions = ScenarioUtils.ChainToPositions(data.MoveChain)

    platoon:Stop()

    for i, unit in platoon:GetPlatoonUnits() do
        unit:SetAutoMode(true)

        local pos = positions[i]
        IssueMove({unit}, pos)
        unit.IdlePosition = pos

        ForkThread(M3NukeSubWaitTillLoaded, unit)
    end
end

function M3NukeSubWaitTillLoaded(unit)
    local cmd = false

    while unit and not unit.Dead do
        if unit:GetNukeSiloAmmoCount() > 0 and not cmd then
            local targetPosition = FindTargetToNuke()

            if not unit.Dead and targetPosition then
                local cmd = IssueNuke({unit}, targetPosition)
                
                repeat
                    WaitSeconds(15)
                until IsCommandDone(cmd) or unit.Dead

                if not unit.Dead then
                    IssueMove({unit}, unit.IdlePosition)
                    cmd = false
                else
                    return
                end
            end
        else
            WaitSeconds(20)
        end
    end
end

function FindTargetToNuke(unit)
    local aiBrain = unit:GetAIBrain()
    --local aiBrain = platoon:GetBrain()
    local data = unit.platoonHandle.PlatoonData

    local mostUnits = 0
    local bestTarget = nil
    local searching = true

    local positions = ScenarioUtils.ChainToPositions(data.TargetChain)
    if not positions then
        error('*speed2: FindTargetToNuke missing a TargetChain')
    end

    while true do
        WaitSeconds(15)
        for i, pos in positions do
            local num = table.getn(aiBrain:GetUnitsAroundPoint(data.TargetCategory or ((categories.TECH2 * categories.STRUCTURE) + (categories.TECH3 * categories.STRUCTURE)), pos, 30, 'enemy'))
            if num > 3 then
                if num > numUnits then
                    mostUnits = num
                    bestTarget = pos
                end
            end
            if i == table.getn(positions) and bestTarget then
                return bestTarget
            end
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