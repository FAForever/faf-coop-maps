local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')

local Cybran = 3
local Aeon = 4
local Difficulty = ScenarioInfo.Options.Difficulty

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
                if not v:IsDead() then
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

--- Adds the platoon to the base's guard pool from which other platoons can request guards.
function AddToNavalGuardPool(platoon)
    local data = platoon.PlatoonData
    local base = platoon:GetBrain().BaseManagers[data.LocationType]
    if not base.NavalGuardPlatoons then
        base.NavalGuardPlatoons = {}
    end

    table.insert(base.NavalGuardPlatoons, platoon)
    platoon:AddDestroyCallback(RemoveFromNavalGuardPool)

    if data.RallyPoint then
        platoon:MoveToLocation(ScenarioUtils.MarkerToPosition(data.RallyPoint), false)
    end
end

function RemoveFromNavalGuardPool(brain, platoon)
    local base = brain.BaseManagers[platoon.PlatoonData.LocationType]
    if not base.NavalGuardPlatoons then
        return
    end

    table.removeByValue(base.NavalGuardPlatoons, platoon)
end

function GetAvailableGuardUnit(brain, baseName, cats, num)
    num = num or 1
    local availablePlatoons = brain.BaseManagers[baseName].NavalGuardPlatoons
    if not availablePlatoons then
        return
    end

    local result = {}

    for _, platoon in availablePlatoons do
        for _, unit in platoon:GetPlatoonUnits() do
            if EntityCategoryContains(cats, unit) then
                table.insert(result, unit)

                if table.getn(result) == num then
                    return result
                end
            end
        end
    end
end

function RequestAmphibiousGuard(platoon)
    local baseName = platoon.PlatoonData.LocationType
    local brain = platoon:GetBrain()

    for _, unit in platoon:GetPlatoonUnits() do
        local guardUnits = nil
        if unit.techCategory == "TECH1" then
            continue
        elseif unit.techCategory == "TECH2" then
            if EntityCategoryContains(categories.CRUISER, unit) then
                guardUnits = GetAvailableGuardUnit(brain, baseName, categories.ual0307, 1)
            else
                guardUnits = GetAvailableGuardUnit(brain, baseName, categories.ual0307 + categories.ual0205, 1)
            end
        else
            guardUnits = GetAvailableGuardUnit(brain, baseName, categories.ual0307 + categories.ual0205, 2)
        end

        if guardUnits then
            brain:AssignUnitsToPlatoon(platoon, guardUnits, 'support', 'NoFormation')
            IssueClearCommands(guardUnits)
            IssueGuard(guardUnits, unit)
        end
    end 
end

function EnableStealthOnAir()
    local T3AirUnits = {}
    while true do
        for _, v in ArmyBrains[Cybran]:GetListOfUnits(categories.ura0303 + categories.ura0304 + categories.ura0401, false) do
            if not ( T3AirUnits[v:GetEntityId()] or v:IsBeingBuilt() ) then
                v:ToggleScriptBit('RULEUTC_StealthToggle')
                T3AirUnits[v:GetEntityId()] = true
            end
        end
        WaitSeconds(10)
    end
end

function CheatEco()
    WaitSeconds(5)

    -- Bonus mass income 50, 100, 150 mass/second
    local quantity = {5000, 10000, 15000}
    while ScenarioInfo.MissionNumber == 2 do
        ArmyBrains[Cybran]:GiveResource('MASS', quantity[Difficulty])
        WaitSeconds(100)
    end

    while ScenarioInfo.MissionNumber == 3 do
        ArmyBrains[Aeon]:GiveResource('MASS', quantity[Difficulty])
        WaitSeconds(100)
    end
end