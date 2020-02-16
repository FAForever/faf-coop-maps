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
function PlayersACUsNearBase(aiBrain, baseName, distance)
    local bManager = aiBrain.BaseManagers[baseName]
    if not bManager then return false end

    local bPosition = bManager:GetPosition()
    if not distance then
        distance = bManager:GetRadius()
    end

    for _, v in ScenarioInfo.PlayersACUs or {} do
        if not v:IsDead() then
            local position = v:GetPosition()
            local value = VDist2(position[1], position[3], bPosition[1], bPosition[3])

            if value <= distance then
                return true
            end
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

--- Build condition
-- Returns true if mass in storage of <aiBrain> is less than <mStorage>
function LessMassStorageCurrent(aiBrain, mStorage)
    local econ = AIUtils.AIGetEconomyNumbers(aiBrain)
    if econ.MassStorage < mStorage then
        return true
    end
    return false
end

--- Adds more fuel to the air units
function UnitsMultiplyMaxFuel(units, num)
    for _, unit in units do
        local bp = unit:GetBlueprint()
        
        if bp.Physics.FuelUseTime then
            unit:SetFuelUseTime(bp.Physics.FuelUseTime * num)
        end
    end
end