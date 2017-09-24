local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local TCRUtil = import('/maps/FAF_Coop_Theta_Civilian_Rescue/FAF_Coop_Theta_Civilian_Rescue_CustomFunctions.lua')
local ThisFile = '/maps/FAF_Coop_Theta_Civilian_Rescue/FAF_Coop_Theta_Civilian_Rescue_m1cybranai.lua'

---------
-- Locals
---------
local Cybran = 2
local Difficulty = ScenarioInfo.Options.Difficulty
local WaitForAttackSeconds = {120,60,0}

----------------
-- Base Managers
----------------
local CybranM1WestBase = BaseManager.CreateBaseManager()

-------
-- Misc
-------
local MMLPlatoon

----------------------
-- Cybran M1 West Base
----------------------
function CybranM1WestBaseAI()
    CybranM1WestBase:InitializeDifficultyTables(ArmyBrains[Cybran], 'M1_Cybran_West_Base', 'M1_Cybran_West_Base_Marker', 80, {M1_Cybran_West_Base = 100})
    local extraEngies = ScenarioInfo.NumberOfPlayers * Difficulty
    CybranM1WestBase:StartNonZeroBase({{6 + extraEngies, 9 + extraEngies, 12 + extraEngies}, {4 + extraEngies, 6 + extraEngies, 8 + extraEngies}})
    
    ForkThread(function()
        WaitSeconds(1)
        CybranM1WestBase:AddBuildGroupDifficulty('M1_Cybran_West_Base_Support_Factories', 100, true)
    end)
    
    ForkThread(function()
        for i = 1,ScenarioInfo.NumberOfPlayers do
            CybranM1WestBase:AddBuildGroupDifficulty('M1_Cybran_West_Base_Engineers_C' .. i, 100, true)
        end
        
        CybranM1WestBase:AddBuildGroupDifficulty('M1_Cybran_West_Base_Defenses', 90, false)
        
        if ScenarioInfo.NumberOfPlayers >= 3 then
            CybranM1WestBase:SpawnGroup('M1_Forward_Defenses_D' .. Difficulty)
        end
    end)
    
    CybranM1WestBase:SetActive('AirScouting', true)

    ForkThread(function()
        WaitSeconds(WaitForAttackSeconds[Difficulty])
        CybranM1WestBaseLandAttacks()
        CybranM1WestBaseAirAttacks()
    end)
end

function CybranM1WestBaseLandAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}
    
    -- LightBots patrol until X amount of landforces (2 times)
    quantity = {6, 8, 10}
    trigger = {30, 25, 20}
    for i = 1,2 do
        opai = CybranM1WestBase:AddOpAI('BasicLandAttack', 'M1_WestLandAttack1_' .. i,
            {
                MasterPlatoonFunction = {ThisFile, 'M1EastBaseLandPlatoonAI'},
                Priority = 110,
            }
        )
        opai:SetChildQuantity({'LightBots'}, quantity[Difficulty]) 
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.LAND * categories.MOBILE - categories.ENGINEER, '<='})
    end
    
    -- LightArtillery patrol the entire time (2 times)
    quantity = {6, 8, 10}
    local quantityMantis = {1,2,3}
    local Temp = {
        'M1_LandAttackTemp1',
        'NoPlan',
        { 'url0103', 1, quantity[Difficulty] - quantityMantis[Difficulty], 'Attack', 'AttackFormation' },   -- Medusa
        { 'url0107', 1, quantityMantis[Difficulty], 'Attack', 'AttackFormation' },   -- Mantis
        { 'url0101', 1, 1, 'Attack', 'AttackFormation' },   -- Mole
    }
    local Builder = {
        BuilderName = 'M1_LandAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'M1_Cybran_West_Base',
        PlatoonAIFunction = {ThisFile, 'M1EastBaseLandPlatoonAI'},
    }
    ArmyBrains[Cybran]:PBMAddPlatoon( Builder )
    
    -- HeavyBots(Mantis) patrol the entire time (or after you have some units on easier difficulties)
    quantity = {6, 8, 10}
    local quantityMedusa = {1,2,3}
    trigger = {10, 5, 0}
    local Temp = {
        'M1_LandAttackTemp2',
        'NoPlan',
        { 'url0107', 1, quantity[Difficulty] - quantityMedusa[Difficulty], 'Attack', 'AttackFormation' },   -- Mantis
        { 'url0103', 1, quantityMedusa[Difficulty], 'Attack', 'AttackFormation' },   -- Medusa
        { 'url0101', 1, 1, 'Attack', 'AttackFormation' },   -- Mole
    }
    local Builder = {
        BuilderName = 'M1_LandAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'M1_Cybran_West_Base',
        BuildConditions = {
            {'/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
                {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.LAND * categories.MOBILE - categories.ENGINEER, '>='}},
        },
        PlatoonAIFunction = {ThisFile, 'M1EastBaseLandPlatoonAI'},
    }
    ArmyBrains[Cybran]:PBMAddPlatoon( Builder )
    
    --Small HeavyTanks patrol starting from X amount of units.
    quantity = {2, 3, 4}
    trigger = {30, 20, 10}
    opai = CybranM1WestBase:AddOpAI('BasicLandAttack', 'M1_WestLandAttack4',
        {
            MasterPlatoonFunction = {ThisFile, 'M1EastBaseLandPlatoonAI'},
            Priority = 120,
        }
    )
    opai:SetChildQuantity({'HeavyTanks'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.LAND * categories.MOBILE - categories.ENGINEER, '>='})
    
    --Big HeavyTanks patrol starting from X amount of units.
    quantity = {6, 8, 10}
    trigger = {12, 6, 2}
    opai = CybranM1WestBase:AddOpAI('BasicLandAttack', 'M1_WestLandAttack5',
        {
            MasterPlatoonFunction = {ThisFile, 'M1EastBaseLandPlatoonAI'},
            Priority = 130,
        }
    )
    opai:SetChildQuantity({'HeavyTanks'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.TECH2 * categories.LAND * categories.MOBILE - categories.ENGINEER, '>='})
        
    if Difficulty >= 3 then
        quantity = {4, 8, 12,16}
        trigger = {20, 15, 10, 6}
        opai = CybranM1WestBase:AddOpAI('BasicLandAttack', 'M1_WestLandAttack6',
            {
                MasterPlatoonFunction = {ThisFile, 'M1EastBaseLandPlatoonAI'},
                Priority = 130,
            }
        )
        opai:SetChildQuantity({'MobileMissiles'}, quantity[ScenarioInfo.NumberOfPlayers])
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.FACTORY + categories.MASSEXTRACTION + categories.ENERGYPRODUCTION, '>='})
    end
end

function CybranM1WestBaseAirAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    quantity = {4, 6, 8}
    trigger = {40, 30, 20}
    opai = CybranM1WestBase:AddOpAI('AirAttacks', 'M1_WestAirAttack1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M1_Cybran_Land_Attack_Chain_1'
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'Bombers'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL, '>='})
   
    quantity = {6, 8, 10}
    trigger = {10, 8, 6}
    opai = CybranM1WestBase:AddOpAI('AirAttacks', 'M1_WestAirAttack2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M1_Cybran_Land_Attack_Chain_1'
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'Interceptors'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.AIR, '>='})
end


-------------------------------------------
-- Function that picks land patrols for AI
-------------------------------------------
function M1EastBaseLandPlatoonAI(platoon)
    local rand = Random(1, 4)
    local chains = {'M1_Cybran_Land_Attack_Chain_1', 'M1_Cybran_Land_Attack_Chain_2','M1_Cybran_Land_Attack_Chain_3', 'M1_Cybran_Land_Attack_Chain_4'}
    local pickedChain = chains[rand]
    
    --LOG('*DEBUG: pickedChain = ' .. pickedChain)
    platoon:Stop()
    if rand <= 2 then
        ScenarioFramework.PlatoonPatrolChain(platoon, pickedChain)
    else
        PlatoonPatrolInsideAreaRoute( platoon, pickedChain )
    end
end

-- only move outside of the map and start patrolling when inside. (Depends on amount of markers in chain)
-- Attack move to edge of map so units don't run away when base is under assault.
function PlatoonPatrolInsideAreaRoute( platoon, chain )
    
    ScenarioFramework.PlatoonAttackChain(platoon, chain .. '_Go_Outside')
    ScenarioFramework.PlatoonMoveChain(platoon, chain .. '_Go_Back_Inside')
    ScenarioFramework.PlatoonPatrolChain(platoon, chain .. '_Patrol')
    
end