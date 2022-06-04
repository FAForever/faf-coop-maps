local AIUtils = import('/lua/ai/aiutilities.lua')
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local SPAIFileName = '/lua/ScenarioPlatoonAI.lua'

-- Wait for the units to leave the carrier before giving the orders
function PatrolThread(platoon)
    local data = platoon.PlatoonData

    for _, unit in platoon:GetPlatoonUnits() do
        while (not unit.Dead and unit:IsUnitState('Attached')) do
            WaitSeconds(1)
        end
    end

    platoon:Stop()
    if data then
        if data.PatrolRoute or data.PatrolChain then
            if data.PatrolChain then
                ScenarioFramework.PlatoonPatrolRoute(platoon, ScenarioUtils.ChainToPositions(data.PatrolChain))
            else
                for _,v in data.PatrolRoute do
                    if type(v) == 'string' then
                        platoon:Patrol(ScenarioUtils.MarkerToPosition(v))
                    else
                        platoon:Patrol(v)
                    end
                end
            end
        else
            error('*CUSTOM FUNCTIONS AI ERROR: PatrolRoute or PatrolChain not defined', 2)
        end
    else
        error('*CUSTOM FUNCTIONS AI ERROR: PlatoonData not defined', 2)
    end
end

--- Build condition
-- Checks if any of the player's ACUs is close to the base
function PlayerUnitsNearBase(aiBrain, baseName, distance)
    local bManager = aiBrain.BaseManagers[baseName]
    if not bManager then return false end

    local bPosition = bManager:GetPosition()
    if not distance then
        distance = bManager:GetRadius()
    end

    
        if not v:IsDead() then
            local position = v:GetPosition()
            local value = VDist2(position[1], position[3], bPosition[1], bPosition[3])

            if value <= distance then
                return true
            end
        end
    
    return false
end

--- Tries to attack the closest ACU to the base, else patrols
function MercyThread(platoon)
    local data = platoon.PlatoonData
    local aiBrain = platoon:GetBrain()
    local bManager = aiBrain.BaseManagers[data.Base]
    local bPosition = bManager:GetPosition()

    local target = false
    for _, v in ScenarioInfo.PlayersACUs or {} do
        if not v:IsDead() then
            local position = v:GetPosition()
            local value = VDist2(position[1], position[3], bPosition[1], bPosition[3])

            if value <= data.Distance and platoon:CanAttackTarget('Attack', v) then
                target = v
                break
            end
        end
    end

    if target then
        platoon:AttackTarget(target)
        platoon:AggressiveMoveToLocation(ScenarioUtils.MarkerToPosition('Player1'))
    else
        import(SPAIFileName).PatrolThread(platoon)
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

function PlatoonAttackWithTransports( platoon, landingChain, attackChain, instant )
    ForkThread( PlatoonAttackWithTransportsThread, platoon, landingChain, attackChain, instant )
end

function PlatoonAttackWithTransportsThread( platoon, landingChain, attackChain, instant, moveChain )
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
    --[[
    if instant then
        IssueMove( transports, startPos )
        for k, unit in transports do
            aiBrain:AssignUnitsToPlatoon( 'TransportPool', {unit}, 'Scout', 'None')
        end
    end]]--
end

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

