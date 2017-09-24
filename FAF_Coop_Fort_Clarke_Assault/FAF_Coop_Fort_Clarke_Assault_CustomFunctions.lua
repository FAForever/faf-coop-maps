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

    for _, unit in platoon:GetPlatoonUnits() do
        while (not unit:IsDead() and unit:IsUnitState('Attached')) do
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

####################################################################################################################
### ReclaimPatrolThread
###     - Each unit of a platoon gets a random patrol chain from the list
###
### PlatoonData
###     - PatrolChains - List of chains to choose from
###
####################################################################################################################
function ReclaimPatrolThread(platoon)
    local data = platoon.PlatoonData
    platoon:Stop()
    if(data) then
        if(data.PatrolChains) then
            for k, v in platoon:GetPlatoonUnits() do
                local chain = Random(1, table.getn(data.PatrolChains))
                ScenarioFramework.GroupPatrolChain({v}, data.PatrolChains[chain])
            end
        else
            error('*SCENARIO PLATOON AI ERROR: PatrolChains not defined', 2)
        end
    else
        error('*SCENARIO PLATOON AI ERROR: PlatoonData not defined', 2)
    end
end