local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')

ScenarioInfo.Order = 2
ScenarioInfo.Seraphim = 3
ScenarioInfo.QAI = 4
ScenarioInfo.UEF = 5

local Difficulty = ScenarioInfo.Options.Difficulty

------------------------------------------------------------------
--  MoveChainPickerThread
--      Gives a platoon a random move chain from a set of chains
--  PlatoonData
--      MoveChains - List of chains to choose from
--  function: MoveChainPickerThread = AddFunction
--      parameter 0: string: platoon = "default_platoon"
------------------------------------------------------------------
function MoveChainPickerThread(platoon)
    local data = platoon.PlatoonData
    platoon:Stop()
    if data then
        if data.MoveChains then
            local chain = Random(1, table.getn(data.MoveChains))
            ScenarioFramework.PlatoonMoveRoute(platoon, ScenarioUtils.ChainToPositions(data.MoveChains[chain]))
        else
            error('*SCENARIO PLATOON AI ERROR: MoveChains not defined', 2)
        end
    else
        error('*SCENARIO PLATOON AI ERROR: PlatoonData not defined', 2)
    end
end

function PlatoonAttackClosestPriorityUnit(platoon)
    local aiBrain = platoon:GetBrain()
    local target

    while not target do
        target = platoon:FindClosestUnit('Attack', 'Enemy', true, categories.url0401 + categories.xab1401 + categories.ueb2401 + categories.xab2307)
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

function PlatoonAttackWithTransports( platoon, landingChain, attackChain, deleteMarker, instant )
    ForkThread( PlatoonAttackWithTransportsThread, platoon, landingChain, attackChain, deleteMarker, instant )
end

function PlatoonAttackWithTransportsThread( platoon, landingChain, attackChain, deleteMarker, instant, moveChain )
    local aiBrain = platoon:GetBrain()
    local allUnits = platoon:GetPlatoonUnits()
    local startPos = platoon:GetPlatoonPosition()
    local units = {}
    local transports = {}
    for k,v in allUnits do
        if EntityCategoryContains( categories.TRANSPORTATION, v ) then
            table.insert( transports, v )
        else
            table.insert( units, v )
        end
    end

    local landingLocs = ScenarioUtils.ChainToPositions( landingChain )
    local landingLocation = landingLocs[Random(1,table.getn(landingLocs))]

    if instant then
        ScenarioFramework.AttachUnitsToTransports( units, transports )
        if moveChain and not ScenarioPlatoonAI.MoveAlongRoute(platoon, ScenarioUtils.ChainToPositions(moveChain)) then
            return
        end
        IssueTransportUnload( transports, landingLocation )
        local attached = true
        while attached do
            WaitSeconds(3)
            local allDead = true
            for k,v in transports do
                if not v.Dead then
                    allDead = false
                    break
                end
            end
            if allDead then
                return
            end
            attached = false
            for num, unit in units do
                if not unit.Dead and unit:IsUnitState('Attached') then
                    attached = true
                    break
                end
            end
        end
    else
        if not import('/lua/ai/aiutilities.lua').UseTransports( units, transports, landingLocation ) then
            return
        end
    end

    local attackLocs = ScenarioUtils.ChainToPositions(attackChain)
    for k,v in attackLocs do
        IssuePatrol( units, v )
    end

    IssueMove(transports, ScenarioUtils.MarkerToPosition(deleteMarker))

    for _, transport in transports do
        ScenarioFramework.CreateUnitToMarkerDistanceTrigger(DestroyUnit, transport, deleteMarker, 15)
    end
end

function DestroyUnit(unit)
    unit:Destroy()
end

function AssistNavalFactories(platoon)
    local data = platoon.PlatoonData
    local aiBrain = platoon:GetBrain()
    local bManager = aiBrain.BaseManagers[data.BaseName]

    if not data.Factories then
        error('*CUSTOM FUNCTIONS AI ERROR: categories of factories to assist not defined', 2)
    end

    -- local factories = bManager:GetAllBaseFactories(data.Factories)
    local factories = aiBrain:GetListOfUnits(data.Factories, false)

    platoon:Stop()
    local num = 1
    for _, unit in platoon:GetPlatoonUnits() do
        local factory = factories[num]
        if not factory then
            factory = factories[1]
            num = 1
        end
        IssueGuard({unit}, factory)--factories[math.mod(i, 2) + 1])
        num = num + 1
    end
end
