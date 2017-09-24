local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')

-----------------------------------
-- Example OperationScenarios Table
----------------------------------- 
-- ScenarioInfo.OperationScenarios = {
--     M1 = {
--         Bases = {
--             {
--                 CallFunction = function(baseType) end,
--                 Types = {'Type1', 'Type2', 'Type3', ...},
--             },
--             {
--                 CallFunction = function(baseType) end,
--                 Types = {'Type1', 'Type2', 'Type3', ...},
--             },
--         },
--         Events = {
--             {
--                 CallFunction = function() end,
--                 Delay = {10*60, 8*60, 6*60},
--             },
--             {
--                 CallFunction = function() end,
--                 Delay = 10*60,
--             },
--         },
--     },
--     M2 = {
--          ...
--     },
-- }
--------------------------------
-- Delay - in seconds, can be either single number or table with 3 values, 1 for each difficulty settings

function ChooseRandomBases()
    local data = ScenarioInfo.OperationScenarios['M' .. ScenarioInfo.MissionNumber].Bases

    if not ScenarioInfo.MissionNumber then
        error('*RANDOM BASE: ScenarioInfo.MissionNumber needs to be set.')
    elseif not data then
        error('*RANDOM BASE: No bases specified for mission number: ' .. ScenarioInfo.MissionNumber)
    end

    for _, base in data do
        local num = Random(1, table.getn(base.Types))

        base.CallFunction(base.Types[num])
    end
end

function ChooseRandomEvent(useDelay, customDelay)
    local data = ScenarioInfo.OperationScenarios['M' .. ScenarioInfo.MissionNumber].Events
    local num = ScenarioInfo.MissionNumber

    if not num then
        error('*RANDOM EVENT: ScenarioInfo.MissionNumber needs to be set.')
    elseif not data then
        error('*RANDOM EVENT: No events specified for mission number: ' .. num)
    end
    
    -- Randomly pick one event
    local function PickEvent(tblEvents)
        local availableEvents = {}
        local event

        -- Check available events
        for _, event in tblEvents do
            if not event.Used then
                table.insert(availableEvents, event)
            end
        end

        -- Pick one, mark as used
        local num = table.getn(availableEvents)

        if num ~= 0 then
            local event = availableEvents[Random(1, num)]
            event.Used = true

            return event
        else
            -- Reset availability and try to pick again
            for _, event in tblEvents do
                event.Used = false
            end
            
            return PickEvent(tblEvents)
        end
    end

    local event = PickEvent(data)

    ForkThread(StartEvent, event, num, useDelay, customDelay)
end

function StartEvent(event, missionNumber, useDelay, customDelay)
    if useDelay or useDelay == nil then
        local waitTime = customDelay or event.Delay -- Delay passed as a function parametr can over ride the delay from the OperationScenarios table
        local Difficulty = ScenarioInfo.Options.Difficulty

        if type(waitTime) == 'table' then
            WaitSeconds(waitTime[Difficulty])
        else
            WaitSeconds(waitTime)
        end
    end

    -- Check if the mission didn't end while we were waiting
    if ScenarioInfo.MissionNumber ~= missionNumber then
        return
    end

    event.CallFunction()
end

function UnitsMultiplyMaxFuel(units, num)
    for _, unit in units do
        local bp = unit:GetBlueprint()
        
        if bp.Physics.FuelUseTime then
            unit:SetFuelUseTime(bp.Physics.FuelUseTime * num)
        end
    end
end

-- TODO: Create new build location with carrier.
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

                        while (carriers[i] and not carriers[i]:IsDead() and carriers[i]:IsUnitState('Moving')) do
                            WaitSeconds(.5)
                        end

                        local location
                        for num, loc in aiBrain.PBM.Locations do
                            if loc.LocationType == data.Location .. i then
                                location = loc
                                break
                            end
                        end

                        if not carriers[i]:IsDead() then
                            location.PrimaryFactories.Air = carriers[i]
                        end

                        while (carriers[i] and not carriers[i]:IsDead()) do
                            if  table.getn(carriers[i]:GetCargo()) > 0 and carriers[i]:IsIdleState() then
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
            while (not unit:IsDead() and unit:IsUnitState('Attached')) do
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

function AssistNavalFactory(platoon)
    
end

--[[
PlatoonData = {
    ReclaimChain = 'Reclaim_Chain_1',
    ReclaimChains = {
        'Reclaim_Chain_1',
        'Reclaim_Chain_2',
    },
    Radius = 100,
}

function ReclaimAI(platoon)
    local data = platoon.PlatoonData
    local engineers = platoon:GetPlatoonUnits()

    local radius = data.Radius or 50

    local position = ScenarioUtils.MarkerToPosition()
    
    for _, engineer in engineers do

    end
    

    local Reclaimables = GetReclaimablesInRect(position[1] - radius, position[3] - radius, position[1] + radius, position[3] + radius)
            
    local Wrecks = {}
    if table.getsize(Reclaimables) > 0 then 
        for k,v in Reclaimables do
            if v then
                if not IsUnit(v) and IsWreckedUnit(v) then
                    table.insert(Wrecks, v)
                end
            end
        end
    end
end
]]--

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
            if not unit.AssignedBattleship or unit.AssignedBattleship:IsDead() then
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
                    if not v:IsDead() then
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