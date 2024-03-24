local AIUtils = import('/lua/ai/aiutilities.lua')
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')

local Cybran = 4

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
