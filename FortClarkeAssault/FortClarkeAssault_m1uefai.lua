local BaseManager = import('/lua/ai/opai/basemanager.lua')
local CustomFunctions = '/maps/FortClarkeAssault/FortClarkeAssault_CustomFunctions.lua'
local SPAIFileName = '/lua/scenarioplatoonai.lua'

---------
-- Locals
---------
local UEF = 4
local Difficulty = ScenarioInfo.Options.Difficulty

----------------
-- Base Managers
----------------
local UEFM1NorthBase = BaseManager.CreateBaseManager()
local UEFM1SouthBase = BaseManager.CreateBaseManager()
local UEFM1ExpansionBase1 = BaseManager.CreateBaseManager()
local UEFM1ExpansionBase2 = BaseManager.CreateBaseManager()
local UEFM1ExpansionBase3 = BaseManager.CreateBaseManager()

---------------------
-- UEF M1 North Base
---------------------
function UEFM1NorthBaseAI()
    UEFM1NorthBase:InitializeDifficultyTables(ArmyBrains[UEF], 'M1_North_Base', 'M1_North_Base_Marker', 25, {M1_North_Base = 100})
    UEFM1NorthBase:StartNonZeroBase({{2, 2, 3}, {1, 1, 1}})
    UEFM1NorthBase:SetActive('LandScouting', true)
    UEFM1NorthBase:SetActive('AirScouting', true)

    ForkThread(function()
        WaitSeconds(240 - 30*Difficulty)
        UEFM1NorthBase:AddBuildGroup('M1_North_Air_Fac', 90)
    end)

    UEFM1NorthBaseLandAttacks()
    UEFM1NorthBaseAirAttacks()
end

function UEFM1NorthBaseAirAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    quantity = {3, 4, 5}
    opai = UEFM1NorthBase:AddOpAI('AirAttacks', 'M1_NorthAirAttack1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_North_Land_Attack_Chain_1',
                                'M1_North_Land_Attack_Chain_2',
                                'M1_North_Air_Attack_Chain_1'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Bombers', quantity[Difficulty])
    opai:SetLockingStyle('None')

    quantity = {3, 4, 5}
    trigger = {11, 8, 5}
    opai = UEFM1NorthBase:AddOpAI('AirAttacks', 'M1_NorthAirAttack2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_North_Land_Attack_Chain_1',
                                'M1_North_Land_Attack_Chain_2',
                                'M1_North_Air_Attack_Chain_1'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Interceptors', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE, '>='}})
end

function UEFM1NorthBaseLandAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    quantity = {6, 6, 8}
    trigger = {36, 28, 20}
    opai = UEFM1NorthBase:AddOpAI('BasicLandAttack', 'M1_NorthLandAttack1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_North_Land_Attack_Chain_1', 'M1_North_Land_Attack_Chain_2'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'LightArtillery', 'LightTanks'}, quantity[Difficulty])
    opai:SetLockingStyle('None')
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL, '>='}})

    opai = UEFM1NorthBase:AddOpAI('BasicLandAttack', 'M1_NorthLandAttack2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_North_Land_Attack_Chain_1', 'M1_North_Land_Attack_Chain_2'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('MobileAntiAir', 4)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, 5, categories.AIR * categories.MOBILE, '>='}})

    quantity = {6, 6, 8}
    trigger = {60, 50, 40}
    opai = UEFM1NorthBase:AddOpAI('BasicLandAttack', 'M1_NorthLandAttack3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_North_Land_Attack_Chain_1', 'M1_North_Land_Attack_Chain_2'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'HeavyTanks', 'LightTanks'}, quantity[Difficulty])
    opai:SetLockingStyle('None')
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL, '>='}})

    trigger = {4, 3, 2}
    opai = UEFM1NorthBase:AddOpAI('BasicLandAttack', 'M1_NorthLandAttack4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_North_Land_Attack_Chain_1', 'M1_North_Land_Attack_Chain_2'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('MobileMissiles', 2)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.DEFENSE * categories.TECH2, '>='}})
end

--------------------
-- UEF M1 South Base
--------------------
function UEFM1SouthBaseAI()
    UEFM1SouthBase:InitializeDifficultyTables(ArmyBrains[UEF], 'M1_South_Base', 'M1_South_Base_Marker', 30, {M1_South_Base = 100})
    UEFM1SouthBase:StartNonZeroBase({{3, 3, 4}, {2, 2, 3}})

    UEFM1SouthBaseLandAttacks()
end

function UEFM1SouthBaseLandAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    opai = UEFM1SouthBase:AddOpAI('EngineerAttack', 'M1_South_Reclaim_Engineers',
    {
        MasterPlatoonFunction = {SPAIFileName, 'SplitPatrolThread'},
        PlatoonData = {
            PatrolChains = {'M1_South_Land_Attack_Chain_1', 'M1_South_Land_Attack_Chain_2', 'M1_North_Land_Attack_Chain_1', 'M1_North_Land_Attack_Chain_2'},
        },
        Priority = 1000,
    })
    opai:SetChildQuantity('T1Engineers', 8)

    quantity = {6, 8, 10}
    trigger = {41, 33, 25}
    opai = UEFM1SouthBase:AddOpAI('BasicLandAttack', 'M1_SouthLandAttack1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_South_Land_Attack_Chain_1', 'M1_South_Land_Attack_Chain_2'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'LightTanks', 'LightArtillery'}, quantity[Difficulty])
    opai:SetLockingStyle('None')
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL, '>='}})

    quantity = {6, 8, 10}
    trigger = {60, 50, 40}
    opai = UEFM1SouthBase:AddOpAI('BasicLandAttack', 'M1_SouthLandAttack2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_South_Land_Attack_Chain_1', 'M1_South_Land_Attack_Chain_2'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'HeavyTanks', 'LightTanks'}, quantity[Difficulty])
    opai:SetLockingStyle('None')
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL, '>='}})

    quantity = {6, 6, 8}
    trigger = {36, 28, 22}
    opai = UEFM1SouthBase:AddOpAI('BasicLandAttack', 'M1_SouthLandAttack3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_South_Land_Attack_Chain_1', 'M1_South_Land_Attack_Chain_2'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity({'HeavyTanks', 'MobileShields'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.TECH2})

    opai = UEFM1SouthBase:AddOpAI('BasicLandAttack', 'M1_SouthLandAttack4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_South_Land_Attack_Chain_1', 'M1_South_Land_Attack_Chain_2'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('MobileFlak', 4)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, 5, categories.TECH2 * categories.AIR * categories.MOBILE, '>='}})

    quantity = {4, 6, 8}
    trigger = {10, 8, 6}
    opai = UEFM1SouthBase:AddOpAI('BasicLandAttack', 'M1_SouthLandAttack5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_South_Land_Attack_Chain_1', 'M1_South_Land_Attack_Chain_2'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('MobileMissiles', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.DEFENSE * categories.TECH2, '>='}})
end

----------------------
-- UEF Expansion Bases
----------------------
function UEFM1ExpansionBases()
    -- North PDs
    UEFM1ExpansionBase1:Initialize(ArmyBrains[UEF], 'M1_Expansion_Base_1', 'M1_EB_1_Marker', 15, 
        {M1_EB_1_RDR = 100,
         M1_EB_1_PD1 = 90,
         M1_EB_1_WL1 = 80,
         M1_EB_1_PD2 = 70,
         M1_EB_1_WL2 = 60,
         M1_EB_1_PD3 = 50})
    UEFM1ExpansionBase1:StartEmptyBase(1)
    UEFM1NorthBase:AddExpansionBase('M1_Expansion_Base_1', 1)

    -- South resource base with defences
    UEFM1ExpansionBase2:Initialize(ArmyBrains[UEF], 'M1_Expansion_Base_2', 'M1_EB_2_Marker', 25, 
        {M1_EB_2_ECO = 200,
         M1_EB_2_PD1 = 190,
         M1_EB_2_RDR = 180,
         M1_EB_2_PD2 = 170,
         M1_EB_2_FC1 = 160,
         M1_EB_2_FC2 = 150,
         M1_EB_2_WL1 = 140,
         M1_EB_2_PD3 = 130,
         M1_EB_2_SHD = 120,
         M1_EB_2_PD4 = 110,
         M1_EB_2_WL2 = 100,})
    UEFM1ExpansionBase2:StartEmptyBase(2)
    UEFM1SouthBase:AddExpansionBase('M1_Expansion_Base_2', 2)

    UEFM1ExpansionBase2AirAttacks()

    -- T2 Arties
    if Difficulty >= 2 then
        ForkThread(function()
            WaitSeconds(4 - Difficulty)
            UEFM1ExpansionBase3:Initialize(ArmyBrains[UEF], 'M1_Expansion_Base_3', 'M1_EB_3_Marker', 15, 
                {M1_EB_3_STH = 100,
                 M1_EB_3_AT1 = 90,
                 M1_EB_3_AT2 = 80,
                 M1_EB_3_AT3 = 70,
                 M1_EB_3_AT4 = 60,
                 M1_EB_3_WL1 = 50,
                 M1_EB_3_WL2 = 40,
                 M1_EB_3_WL3 = 30,
                 M1_EB_3_WL4 = 20})
            UEFM1ExpansionBase3:StartEmptyBase(1)
            UEFM1SouthBase:AddExpansionBase('M1_Expansion_Base_3', 1)
        end)
    end
end

function UEFM1ExpansionBase2AirAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    quantity = {3, 4, 5}
    opai = UEFM1ExpansionBase2:AddOpAI('AirAttacks', 'M2ExpansionBaseAirAttack1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_EB2_Air_Attack_Chain_1',
                                'M1_EB2_Air_Attack_Chain_2',
                                'M1_EB2_Air_Attack_Chain_3'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Bombers', quantity[Difficulty])
    opai:SetLockingStyle('BuildTimer', {LockTimer = 60})

    quantity = {2, 3, 4}
    opai = UEFM1ExpansionBase2:AddOpAI('AirAttacks', 'M2ExpansionBaseAirAttack2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_EB2_Air_Attack_Chain_1',
                                'M1_EB2_Air_Attack_Chain_2',
                                'M1_EB2_Air_Attack_Chain_3'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, 1, categories.AIR * categories.TECH2, '>='}})

    quantity = {6, 8, 10}
    opai = UEFM1ExpansionBase2:AddOpAI('AirAttacks', 'M2ExpansionBaseAirAttack3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_EB2_Air_Attack_Chain_1',
                                'M1_EB2_Air_Attack_Chain_2',
                                'M1_EB2_Air_Attack_Chain_3'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('Bombers', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, 100, categories.ALLUNITS, '>='}})

    quantity = {7, 11, 15}
    trigger = {20, 16, 12}
    opai = UEFM1ExpansionBase2:AddOpAI('AirAttacks', 'M2ExpansionBaseAirAttack4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_North_Land_Attack_Chain_1',
                                'M1_North_Land_Attack_Chain_2',
                                'M1_North_Air_Attack_Chain_1'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('Interceptors', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE, '>='}})
end