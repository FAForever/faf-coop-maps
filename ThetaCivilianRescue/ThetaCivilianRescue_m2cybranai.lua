local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local Objectives = import('/lua/ScenarioFramework.lua').Objectives
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local TCRUtil = import('/maps/ThetaCivilianRescue/ThetaCivilianRescue_CustomFunctions.lua')
local ThisFile = '/maps/ThetaCivilianRescue/ThetaCivilianRescue_m2cybranai.lua'

---------
-- Locals
---------
local Cybran = 2
local Difficulty = ScenarioInfo.Options.Difficulty

local numberOfAirLimit = {70,60,50}

----------------
-- Base Managers
----------------
local CybranM2EastBase = BaseManager.CreateBaseManager()

----------------------
-- Cybran M2 East Base
----------------------
function CybranM2EastBaseAI()
    CybranM2EastBase:InitializeDifficultyTables(ArmyBrains[Cybran], 'M2_Cybran_East_Base', 'M2_Cybran_East_Base_Marker', 80, {M2_Cybran_East_Base = 100})
    local extraEngies = ScenarioInfo.NumberOfPlayers * (Difficulty-1)
    CybranM2EastBase:StartNonZeroBase({{7 + extraEngies, 14 + extraEngies, 22 + extraEngies}, {5 + extraEngies, 10 + extraEngies, 16 + extraEngies}})
    
    ForkThread(function()
        WaitSeconds(1)
        CybranM2EastBase:AddBuildGroupDifficulty('M2_Cybran_East_Base_Support_Factories', 100, true)
    end)
    
    ForkThread(function()
        for i = 1,ScenarioInfo.NumberOfPlayers do
            CybranM2EastBase:AddBuildGroupDifficulty('M2_Cybran_East_Base_Engineers_C' .. i, 100, true)
        end
        
        CybranM2EastBase:AddBuildGroupDifficulty('M2_Cybran_East_Base_Defenses', 90, true)
        
        if ScenarioInfo.NumberOfPlayers >= 3 then
            CybranM2EastBase:SpawnGroup('M2_Forward_Defenses_D' .. Difficulty)
        end
    end)
    
    CybranM2EastBaseLandAttacks()
    CybranM2EastBaseAirAttacks()
    
    ScenarioFramework.CreateAreaTrigger( ExtraAADefense, 'M2_Area', categories.AIR, true, false, ArmyBrains[ScenarioInfo.Player], numberOfAirLimit[Difficulty], true)
end

function CybranM2EastBaseLandAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}
    
    -- Rhino patrol (2 times)
    quantity = {6, 10, 14}
    for i = 1,2 do
        opai = CybranM2EastBase:AddOpAI('BasicLandAttack', 'M2_EastLandAttack3_' .. i,
            {
                MasterPlatoonFunction = {ThisFile, 'M2WestBaseLandPlatoonAI'},
                Priority = 120,
            }
        )
        opai:SetChildQuantity({'HeavyTanks'}, quantity[Difficulty])
    end
    
    -- light artillery patrol 
    quantity = {15, 20, 25}
    opai = CybranM2EastBase:AddOpAI('BasicLandAttack', 'M2_EastLandAttack4',
        {
            MasterPlatoonFunction = {ThisFile, 'M2WestBaseLandPlatoonAI'},
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'LightArtillery'}, quantity[Difficulty])
    
    if (Difficulty > 1) then
        -- Loyalists patrol
        quantity = {0, 2, 4}
        for i = 1,3 do
            opai = CybranM2EastBase:AddOpAI('BasicLandAttack', 'M2_EastLandAttack1_' .. i,
                {
                    MasterPlatoonFunction = {ThisFile, 'M2WestBaseLandPlatoonAI'},
                    Priority = 100,
                }
            )
            opai:SetChildQuantity({'SiegeBots'}, quantity[Difficulty])
        end
            
        -- heavy artillery patrol.
        quantity = {0, 1, 2}
        trigger = {0,150,100}
        local Temp = {
            'LandAttackTemp1',
            'NoPlan',
            { 'url0304', 1, quantity[Difficulty], 'Attack', 'AttackFormation' },   -- MobileHeavyArtillery
            { 'url0306', 1, 1, 'Attack', 'AttackFormation' },   -- MobileStealth
        }
        local Builder = {
            BuilderName = 'LandAttackBuilder1',
            PlatoonTemplate = Temp,
            InstanceCount = 1,
            Priority = 120,
            PlatoonType = 'Land',
            RequiresConstruction = true,
            LocationType = 'M2_Cybran_East_Base',
            BuildConditions = {
               { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
            {'default_brain', 'Player', trigger[Difficulty], categories.LAND * categories.MOBILE}},
            },
            PlatoonAIFunction = {ThisFile, 'M2WestBaseLandPlatoonAI'},
        }
        ArmyBrains[Cybran]:PBMAddPlatoon( Builder )
    end
end

function CybranM2EastBaseAirAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    quantity = {4, 6, 8}
    trigger = {30, 25, 20}
    opai = CybranM2EastBase:AddOpAI('AirAttacks', 'M2_EastAirAttack1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Cybran_Air_Attack_Chain_1', 'M2_Cybran_Air_Attack_Chain_2','M2_Cybran_Air_Attack_Chain_3'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'Gunships'}, quantity[Difficulty])

    quantity = {4,6,8}   
    opai = CybranM2EastBase:AddOpAI('AirAttacks', 'M2_EastAirAttack2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Cybran_Air_Attack_Chain_1', 'M2_Cybran_Air_Attack_Chain_2','M2_Cybran_Air_Attack_Chain_3'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'CombatFighters'}, quantity[Difficulty])

    quantity = {2, 4, 6}
    trigger = {20, 15, 10}
    opai = CybranM2EastBase:AddOpAI('AirAttacks', 'M2_EastAirAttack3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Cybran_Air_Attack_Chain_1', 'M2_Cybran_Air_Attack_Chain_2','M2_Cybran_Air_Attack_Chain_3'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'AirSuperiority'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.TECH2 * categories.AIR})
end

-------------------------------------------
-- Function that picks land patrols for AI
-------------------------------------------
function M2WestBaseLandPlatoonAI(platoon)
    --only pick chain 1 if base is destroyed!!
    local start = 2
    if Objectives.IsComplete(ScenarioInfo.M1S1) then
        start = 1
    end
    local rand = Random(start, 4)
    local chains = {'M2_Cybran_Land_Attack_Chain_1', 'M2_Cybran_Land_Attack_Chain_2','M2_Cybran_Land_Attack_Chain_3','M2_Cybran_Land_Attack_Chain_4'}
    
    platoon:Stop()
    ScenarioFramework.PlatoonPatrolRoute(platoon, ScenarioUtils.ChainToPositions(chains[rand]))
end

--------------------------------------
-- Anti-Air Defenses against air abuse
--------------------------------------
function ExtraAADefense()
    --build more AA turrets 
    CybranM2EastBase:AddBuildGroupDifficulty('M2_Cybran_East_Base_Extra_AA_Defenses', 80, false)

    --Patroling cloud of interceptors
    local opai = nil
    local quantity = {}
    local trigger = {}

    quantity = {10,20,30}
    opai = CybranM2EastBase:AddOpAI('AirAttacks', 'M2_AntiAir_AirDefense_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Cybran_Air_Patrol_Chain'},
            },
            Priority = 80,
        }
    )
    opai:SetChildQuantity({'Interceptors'}, quantity[Difficulty])

    --spawn flak assault groups
    quantity = {4, 6, 8}
    trigger = {70,60,50}
    opai = CybranM2EastBase:AddOpAI('BasicLandAttack', 'M2_AntiAir_LandAttack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Cybran_Land_Attack_Chain_1', 'M2_Cybran_Land_Attack_Chain_2','M2_Cybran_Land_Attack_Chain_3','M2_Cybran_Land_Attack_Chain_4'},
            },
            Priority = 80,
        }
    )
    opai:SetChildQuantity({'MobileFlak', 'MobileStealth'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.AIR})
end