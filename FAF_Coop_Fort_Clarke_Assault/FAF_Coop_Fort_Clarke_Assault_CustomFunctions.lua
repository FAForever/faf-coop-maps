local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')

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
                        local carrier = carriers[i]
                        IssueMove( {carriers[i]}, movePositions[i] )

                        while (not carrier.Dead and carrier:IsUnitState('Moving')) do
                            WaitSeconds(.5)
                        end
                        
                        if carrier.Dead then
                            return
                        end

                        for _, location in aiBrain.PBM.Locations do
                            if location.LocationType == data.Location .. i then
                                location.PrimaryFactories.Air = factory
                                break
                            end
                        end

                        carrier:ForkThread(function(self)
                            local factory = self.ExternalFactory
            
                            while true do
                                if table.getn(self:GetCargo()) > 0 and factory:IsIdleState() then
                                    IssueClearCommands({self})
                                    IssueTransportUnload({self}, carrier:GetPosition())
                
                                    repeat
                                        WaitSeconds(3)
                                    until not self:IsUnitState("TransportUnloading")
                                end
            
                                WaitSeconds(1)
                            end
                        end)
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

    for _, unit in platoon:GetPlatoonUnits() do
        while (not unit.Dead and unit:IsUnitState('Attached')) do
            WaitSeconds(1)
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
