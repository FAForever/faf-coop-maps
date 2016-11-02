local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')

-----------------------------------
-- Example OperationScenarios Table
----------------------------------- 
--     ScenarioInfo.OperationScenarios = {
--          M1 = {
--              Bases = {
--                  {
--                      CallFunction = function(baseType) end,
--                      Types = {'Type1', 'Type2', 'Type3', ...},
--                  },
--                  {
--                      CallFunction = function(baseType) end,
--                      Types = {'Type1', 'Type2', 'Type3', ...},
--                  },
--              },
--              Events = {
--                  {
--                      CallFunction = function() end,
--                      Delay = {10*60, 8*60, 6*60},
--                  },
--                  {
--                      CallFunction = function() end,
--                      Delay = 10*60,
--                  },
--              },
--          },
--          M2 = {
--               ...
--          },
--     }
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
    if useDelay then
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