local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local TCRUtil = import('/maps/FAF_Coop_Theta_Civilian_Rescue/FAF_Coop_Theta_Civilian_Rescue_CustomFunctions.lua')

---------
-- Locals
---------
local Difficulty = ScenarioInfo.Options.Difficulty

-----------------------------
-- Cybran M1 West Base Manual
-----------------------------
function CybranM1WestBaseDefensePatrols()
    local platoon
    
    -- Patroling interceptors
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M1_Cybran_Air_Patrol_D' .. Difficulty, 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M1_Cybran_Air_Patrol_Chain')
    
    -- Patroling landforces
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M1_Cybran_Land_Patrol_D' .. Difficulty, 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M1_Cybran_Land_Patrol_Chain')
    
    MMLPlatoon = ScenarioUtils.CreateArmyGroup('Cybran', 'M1_Cybran_Land_MML_D' .. Difficulty, false)
    TCRUtil.CreateAreaTrigger(MMLAttackACU, 'M1_Cybran_Base_Area' , categories.COMMAND, true, false, 1)
end

function MMLAttackACU()
    units = TCRUtil.GetAllCatUnitsInArea(categories.COMMAND, 'M1_Cybran_Base_Area')
    for _,unit in units do
        IssueAttack( MMLPlatoon, unit)
        break
    end
end

function CybranM1WestBaseForwardPatrols()
    local platoon
    
    if ScenarioInfo.NumberOfPlayers >= 3 then
        -- Patroling interceptors
        if Difficulty >= 1 then 
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'Hunter_S1', 'GrowthFormation')
            ScenarioFramework.PlatoonPatrolChain(platoon, 'M1_Forward_S1_Patrol_Chain')
            
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'Mixed_S2', 'GrowthFormation')
            ScenarioFramework.PlatoonPatrolChain(platoon, 'M1_Forward_S2_Patrol_Chain')
        end
        if Difficulty >= 2 then 
            ForkThread(function()
                WaitSeconds(30) -- 30seconds
                platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'Medusa_S3', 'GrowthFormation')
                ScenarioFramework.PlatoonAttackChain(platoon, 'M1_Forward_S3_Attack_Chain')
            
            end)
            
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'Mixed_S4', 'GrowthFormation')
            ScenarioFramework.PlatoonPatrolChain(platoon, 'M1_Forward_S4_Patrol_Chain')
        end
        if Difficulty >= 3 then 
            
            ForkThread(function()
                WaitSeconds(600) -- 10min0sec
                -- Dialog?
                platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'Delayed_Assault_S6', 'GrowthFormation')
                ScenarioFramework.PlatoonAttackChain(platoon, 'M1_Forward_S6_Attack_Chain')
            
            end)
        end
    end
end