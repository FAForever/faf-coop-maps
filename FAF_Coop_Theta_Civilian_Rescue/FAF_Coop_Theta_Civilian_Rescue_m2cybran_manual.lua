local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local Objectives = import('/lua/ScenarioFramework.lua').Objectives
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local TCRUtil = import('/maps/FAF_Coop_Theta_Civilian_Rescue/FAF_Coop_Theta_Civilian_Rescue_CustomFunctions.lua')

---------
-- Locals
---------
local Difficulty = ScenarioInfo.Options.Difficulty

local spawnMonkeylords = 0
local spawnMegaliths = 0
local spawnCorsairs = 0
local singleMega = false
local timeBeforeFocus = 5

function CybranM2EastBaseDefensePatrols()
    local platoon
    
    -- Patroling interceptors
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2_Cybran_Air_Patrol_D' .. Difficulty, 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M2_Cybran_Air_Patrol_Chain')
    
    -- Patroling landforces
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2_Cybran_Land_Patrol_D' .. Difficulty, 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M2_Cybran_Land_Patrol_Chain')
end

----------------------
-- Drop units at start
----------------------
function CybranM2EastBaseUnitDrops()
    
    if not (ScenarioInfo.M1P1) or Objectives.IsComplete(ScenarioInfo.M1P1) then
        TCRUtil.DropUnits('Rhino_1_D' .. Difficulty, 'M2_Cybran_Drop_Rhino_1_Alternative', 'Transport_End_Point', 'M1_Forward_S1_Patrol_Chain')
        TCRUtil.DropUnits('Rhino_2_D' .. Difficulty, 'M2_Cybran_Drop_Rhino_Chain_2_0', 'Transport_End_Point', 'M2_Cybran_Drop_Rhino_Chain_2')
        TCRUtil.DropUnits('Loya_5_D' .. Difficulty, 'M2_Cybran_Drop_Loya_Chain_5_0', 'Transport_End_Point', 'M2_Cybran_Drop_Loya_Chain_5')
    else
        TCRUtil.DropUnits('Rhino_1_D' .. Difficulty, 'M1_Forward_S1_Patrol_Chain_0', 'Transport_End_Point', 'M1_Forward_S1_Patrol_Chain')
        TCRUtil.DropUnits('Loya_3_D' .. Difficulty, 'M2_Cybran_Drop_Loya_Chain_3_0', 'Transport_End_Point', 'M2_Cybran_Drop_Loya_Chain_3')
        TCRUtil.DropUnits('Loya_4_D' .. Difficulty, 'M2_Cybran_Drop_Loya_Chain_4_0', 'Transport_End_Point', 'M2_Cybran_Drop_Loya_Chain_4')
        TCRUtil.DropUnits('Rhino_2_D' .. Difficulty, 'M2_Cybran_Drop_Rhino_2_Alternative', 'Transport_End_Point', 'M1_Forward_S1_Patrol_Chain')
        TCRUtil.DropUnits('Loya_5_D' .. Difficulty, 'M2_Cybran_Drop_Loya_Alternative', 'Transport_End_Point', 'M2_Cybran_Drop_Loya_Chain_4')
    end
end

----------------------
--Spawn Experimentals
----------------------

function DropExperimental(deathCallback)
    if spawnMonkeylords <= spawnMegaliths then
        spawnMonkeylords = spawnMonkeylords + 1
    else
        spawnMegaliths = spawnMegaliths + 1
    end

    --some changes to have a better increase of difficulty.
    if spawnMonkeylords == 1 and spawnMegaliths == 1 and (not singleMega) then
        spawnMonkeylords = 0
        singleMega = true
    end

    for i = 1,spawnMonkeylords do
        local units = {}
        local move1 = math.random(10)
        local move2 = math.random(10)
        local monkeylord = CreateUnitHPR("url0402", "Cybran", 240 + move1, 6.75, 10 + move2,0,0,0)
        ScenarioFramework.CreateUnitDeathTrigger(deathCallback, monkeylord)
        table.insert(units, monkeylord )
        local transport = CreateUnitHPR("ura0104", "Cybran", 240 + move1, 6.75, 10 + move2,0,0,0)
        table.insert(units, transport )
        TCRUtil.DropUnits(units, 'M2_Exp_Drop_Location', 'Transport_End_Point', 'M2_Cybran_Exp_Attack_Chain_1')
        FocusACUs(monkeylord)
    end
    for i = 1,spawnMegaliths do
        local units = {}
        local move1 = math.random(10)
        local move2 = math.random(10)
        local megalith = CreateUnitHPR("xrl0403", "Cybran", 240 + move1, 6.75, 10 + move2,0,0,0)
        ScenarioFramework.CreateUnitDeathTrigger(deathCallback, megalith)
        table.insert(units, megalith )
        local transport = CreateUnitHPR("ura0104", "Cybran", 240 + move1, 6.75, 10 + move2,0,0,0)
        table.insert(units, transport )
        TCRUtil.DropUnits(units, 'M2_Exp_Drop_Location', 'Transport_End_Point', 'M2_Cybran_Exp_Attack_Chain_1')
        FocusACUs(megalith)
    end
end

function FocusACUs(unit)
    TCRUtil.CreateFocusACUTrigger( unit, ScenarioInfo.PlayerCDR, 30, timeBeforeFocus )
    for i = 2,ScenarioInfo.NumberOfPlayers do
        TCRUtil.CreateFocusACUTrigger( unit, ScenarioInfo.CoopCDR[i - 1], 30 , timeBeforeFocus)
    end
end

function AfterExperimentalDrops()
    -- 2 times 2 loyalists
    local dropLocations = {'M1_Forward_S1_Patrol_Chain_0', 'M2_Cybran_Drop_Rhino_Chain_2_0'}
    local attackChains = {'M1_Forward_S1_Patrol_Chain', 'M2_Cybran_Drop_Rhino_Chain_2'}
    for i = 1,2 do
        local units = {}
        for i = 1,2 do
            local loyalist = CreateUnitHPR("url0303", "Cybran", 250, 6.75, 15,0,0,0)
            table.insert(units, loyalist )
        end
        local transport = CreateUnitHPR("ura0104", "Cybran", 250, 6.75, 15,0,0,0)
        table.insert(units, transport )
        TCRUtil.DropUnits(units, dropLocations[i], 'Transport_End_Point', attackChains[i])
    end
    
    -- 3 times 1 brick
    dropLocations = {'M2_Cybran_Drop_Loya_Chain_3_0', 'M2_Cybran_Drop_Loya_Chain_4_0', 'M2_Cybran_Drop_Loya_Chain_5_0'}
    attackChains = {'M2_Cybran_Drop_Loya_Chain_3', 'M2_Cybran_Drop_Loya_Chain_4', 'M2_Cybran_Drop_Loya_Chain_5'}
    for i = 1,3 do
        local units = {}
        local brick = CreateUnitHPR("xrl0305", "Cybran", 250, 6.75, 15,0,0,0)
        table.insert(units, brick )
        local transport = CreateUnitHPR("ura0104", "Cybran", 250, 6.75, 15,0,0,0)
        table.insert(units, transport )
        TCRUtil.DropUnits(units, dropLocations[i], 'Transport_End_Point', attackChains[i])
    end
end

function SnipeACUs()
    local units = TCRUtil.GetAllCatUnitsInArea(categories.COMMAND, 'M2_Area')
    spawnCorsairs = spawnCorsairs + 5
    if spawnCorsairs < 21 then
        for _, cdr in units do
            for i = 1,spawnCorsairs do
                local corsair = CreateUnitHPR("dra0202", "Cybran", 245 + math.random(10), 6.75, 10 + math.random(10),0,0,0)
                IssueAttack({corsair}, cdr)
            end
        end
    else
        for _, cdr in units do
            local spawnStrats = spawnCorsairs / 5
            for i = 1,spawnStrats do
                local strat = CreateUnitHPR("ura0304", "Cybran", 245 + math.random(10), 6.75, 10 + math.random(10),0,0,0)
                IssueAttack({strat}, cdr)
            end
        end
    end
end