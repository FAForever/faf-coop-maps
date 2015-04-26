#****************************************************************************
#**
#**  File     : /maps/X1CA_Coop_005_v03/X1CA_Coop_005_v03_m3qaiai.lua
#**  Author(s): Jessica St. Croix
#**
#**  Summary  : QAI army AI for Mission 3 - X1CA_Coop_005_v03
#**
#**  Copyright © 2007 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************
local BaseManager = import('/lua/ai/opai/basemanager.lua')
local NavalOSB = import('/lua/ai/opai/GenerateNaval.lua')

local SPAIFileName = '/lua/ScenarioPlatoonAI.lua'

# ------
# Locals
# ------
local Player = 1
local QAI = 4
local AeonArmy = 5
local UEFArmy = 6
local Brackman = 8
local Difficulty = ScenarioInfo.Options.Difficulty

# -------------
# Base Managers
# -------------
local QAIMainBase = BaseManager.CreateBaseManager()
local QAILandBase = BaseManager.CreateBaseManager()
local QAIAirBase = BaseManager.CreateBaseManager()
local QAINavalBase = BaseManager.CreateBaseManager()
local QAICybranExpBase = BaseManager.CreateBaseManager()
local QAIAeonExpBase = BaseManager.CreateBaseManager()
local QAIUEFExpBase = BaseManager.CreateBaseManager()

function QAIMainBaseAI()

    # -------------
    # QAI Main Base
    # -------------
    QAIMainBase:InitializeDifficultyTables(ArmyBrains[QAI], 'M3_QAI_Main_Base', 'M3_QAI_Main_Base_Marker', 50, {M3_QAI_Main_Base = 100})
    QAIMainBase:StartNonZeroBase({{2, 6, 9}, {2, 5, 7}})

    QAIMainBase:AddReactiveAI('ExperimentalLand', 'AirRetaliation', 'QAIMainBase_ExperimentalLand')
    QAIMainBase:AddReactiveAI('ExperimentalAir', 'AirRetaliation', 'QAIMainBase_ExperimentalAir')
    QAIMainBase:AddReactiveAI('Nuke', 'AirRetaliation', 'QAIMainBase_Nuke')
    QAIMainBase:AddReactiveAI('HLRA', 'AirRetaliation', 'QAIMainBase_HLRA')

    QAIMainBaseAirAttacks()
    QAIMainBaseLandAttacks()
end

function QAIMainBaseAirAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    # --------------------------------
    # QAI Main Base Op AI, Air Attacks
    # --------------------------------

    # sends 2, 4, 6 [bombers]
    quantity = {2, 4, 6}
    opai = QAIMainBase:AddOpAI('AirAttacks', 'M3_MainAirAttack1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_QAI_Main_Base_AirAttack_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Bombers', quantity[Difficulty])
    opai:SetLockingStyle('None')

    # sends 2, 4, 6 [interceptors]
    quantity = {2, 4, 6}
    opai = QAIMainBase:AddOpAI('AirAttacks', 'M3_MainAirAttack2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_QAI_Main_Base_AirAttack_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Interceptors', quantity[Difficulty])
    opai:SetLockingStyle('None')

    # sends 4, 8, 12 [gunships, combat fighters]
    quantity = {4, 8, 12}
    opai = QAIMainBase:AddOpAI('AirAttacks', 'M3_MainAirAttack3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_QAI_Main_Base_AirAttack_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'Gunships', 'CombatFighters'}, quantity[Difficulty])
    opai:SetLockingStyle('None')

    # sends 2, 4, 6 [gunships] if player has >= 100, 80, 60 mobile land
    quantity = {2, 4, 6}
    trigger = {100, 80, 60}
    opai = QAIMainBase:AddOpAI('AirAttacks', 'M3_MainAirAttack4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_QAI_Main_Base_AirAttack_Chain',
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], (categories.MOBILE * categories.LAND) - categories.CONSTRUCTION})

    # sends 2, 4, 6 [air superiority] if player has >= 60, 40, 40 mobile air
    quantity = {2, 4, 6}
    trigger = {60, 40, 40}
    opai = QAIMainBase:AddOpAI('AirAttacks', 'M3_MainAirAttack5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_QAI_Main_Base_AirAttack_Chain',
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.MOBILE * categories.AIR})

    # sends 2, 4, 6 [air superiority] if player has >= 50, 30, 30 gunships
    quantity = {2, 4, 6}
    trigger = {50, 30, 30}
    opai = QAIMainBase:AddOpAI('AirAttacks', 'M3_MainAirAttack6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_QAI_Main_Base_AirAttack_Chain',
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.uaa0203 + categories.uea0203 + categories.ura0203})

    # sends 6, 12, 18 [combat fighters, gunships] if player has >= 60, 40, 20 T3 units
    quantity = {6, 12, 18}
    trigger = {60, 40, 20}
    opai = QAIMainBase:AddOpAI('AirAttacks', 'M3_MainAirAttack7',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_QAI_Main_Base_AirAttack_Chain',
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity({'Gunships', 'CombatFighters'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainGreaterThanOrEqualNumCategory', {'default_brain', 'Player', trigger[Difficulty], categories.TECH3})

    # sends 2, 4, 6 [air superiority] if player has >= 1 strat bomber
    quantity = {2, 4, 6}
    opai = QAIMainBase:AddOpAI('AirAttacks', 'M3_MainAirAttack8',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_QAI_Main_Base_AirAttack_Chain',
            },
            Priority = 140,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainGreaterThanOrEqualNumCategory', {'default_brain', 'Player', 1, categories.uaa0304 + categories.uea0304 + categories.ura0304})

    # sends 8, 16, 24 [bombers, gunships] if player has >= 450, 400, 300 units
    quantity = {8, 16, 24}
    trigger = {450, 400, 300}
    opai = QAIMainBase:AddOpAI('AirAttacks', 'M3_MainAirAttack9',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_QAI_Main_Base_AirAttack_Chain',
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity({'Bombers', 'Gunships'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainGreaterThanOrEqualNumCategory', {'default_brain', 'Player', trigger[Difficulty], categories.ALLUNITS - categories.WALL})

    # sends 2, 4, 6 [heavy gunships] if player has >= 250, 200, 100 structures
    quantity = {2, 4, 6}
    trigger = {250, 200, 100}
    opai = QAIMainBase:AddOpAI('AirAttacks', 'M3_MainAirAttack10',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_QAI_Main_Base_AirAttack_Chain',
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity('HeavyGunships', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainGreaterThanOrEqualNumCategory', {'default_brain', 'Player', trigger[Difficulty], categories.STRUCTURE - categories.WALL})

    # Air Defense
    quantity = {2, 4, 6}
    for i = 1, 2 do
        opai = QAIMainBase:AddOpAI('AirAttacks', 'M3_MainAirDefense' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M3_QAI_Main_Base_AirDef_Chain',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    end

    quantity = {2, 4, 6}
    for i = 3, 4 do
        opai = QAIMainBase:AddOpAI('AirAttacks', 'M3_MainAirDefense' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M3_QAI_Main_Base_AirDef_Chain',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('Gunships', quantity[Difficulty])
    end
end

function QAIMainBaseLandAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    # ---------------------------------
    # QAI Main Base Op AI, Land Attacks
    # ---------------------------------

    # sends 6, 10, 14 [light tanks, heavy tanks]
    quantity = {6, 10, 14}
    opai = QAIMainBase:AddOpAI('BasicLandAttack', 'M3_MainLandAttack1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_QAI_Main_Base_LandAttack_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'LightTanks', 'HeavyTanks'}, quantity[Difficulty])
    if(Difficulty > 1) then
        opai:SetLockingStyle('None')
    end

    # sends 6, 10, 14 [light artillery, mobile missiles]
    quantity = {6, 10, 14}
    opai = QAIMainBase:AddOpAI('BasicLandAttack', 'M3_MainLandAttack2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_QAI_Main_Base_LandAttack_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'LightArtillery', 'MobileMissiles'}, quantity[Difficulty])
    if(Difficulty > 1) then
        opai:SetLockingStyle('None')
    end

    # sends 6, 10, 14 [mobile bombs, mobile stealth]
    quantity = {6, 10, 14}
    opai = QAIMainBase:AddOpAI('BasicLandAttack', 'M3_MainLandAttack3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_QAI_Main_Base_LandAttack_Chain',
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'MobileBombs', 'MobileStealth'}, quantity[Difficulty])
    if(Difficulty > 1) then
        opai:SetLockingStyle('None')
    end

    # sends 2, 6, 10 [siege bots]
    quantity = {2, 6, 10}
    opai = QAIMainBase:AddOpAI('BasicLandAttack', 'M3_MainLandAttack4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_QAI_Main_Base_LandAttack_Chain',
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('SiegeBots', quantity[Difficulty])
    if(Difficulty > 1) then
        opai:SetLockingStyle('None')
    end

    # sends 2, 6, 12 [heavy bots]
    quantity = {2, 6, 12}
    opai = QAIMainBase:AddOpAI('BasicLandAttack', 'M3_MainLandAttack5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_QAI_Main_Base_LandAttack_Chain',
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('HeavyBots', quantity[Difficulty])
    if(Difficulty > 1) then
        opai:SetLockingStyle('None')
    end

    # sends 4, 6, 8 [mobile flak, mobile shields] if player has >= 60, 40, 40 mobile air
    quantity = {4, 6, 8}
    trigger = {60, 40, 40}
    opai = QAIMainBase:AddOpAI('BasicLandAttack', 'M3_MainLandAttack6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_QAI_Main_Base_LandAttack_Chain',
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'MobileFlak', 'MobileShields'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.MOBILE * categories.AIR})

    # sends 4, 6, 8 [mobile flak, mobile shields] if player has >= 50, 30, 30 gunships
    quantity = {4, 6, 8}
    trigger = {50, 30, 30}
    opai = QAIMainBase:AddOpAI('BasicLandAttack', 'M3_MainLandAttack7',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_QAI_Main_Base_LandAttack_Chain',
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'MobileFlak', 'MobileShields'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.uaa0203 + categories.uea0203 + categories.ura0203})

    # sends 6, 10, 14 [siege bots, heavy bots] if player has >= 60, 40, 20 T3 units
    quantity = {6, 10, 14}
    trigger = {60, 40, 20}
    opai = QAIMainBase:AddOpAI('BasicLandAttack', 'M3_MainLandAttack8',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_QAI_Main_Base_LandAttack_Chain',
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity({'SiegeBots', 'HeavyBots'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.TECH3})

    # sends 2, 4, 6 [mobile flak] if player has >= 1 strat bomber
    quantity = {2, 4, 6}
    opai = QAIMainBase:AddOpAI('BasicLandAttack', 'M3_MainLandAttack9',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_QAI_Main_Base_LandAttack_Chain',
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('MobileFlak', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', 1, categories.uaa0304 + categories.uea0304 + categories.ura0304})

    # sends 6, 9, 12 [mobile heavy artillery, mobile missiles, light artillery] if player has >= 450, 400, 350 units
    quantity = {6, 9, 12}
    trigger = {450, 400, 350}
    opai = QAIMainBase:AddOpAI('BasicLandAttack', 'M3_MainLandAttack10',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_QAI_Main_Base_LandAttack_Chain',
            },
            Priority = 140,
        }
    )
    opai:SetChildQuantity({'MobileHeavyArtillery', 'MobileMissiles', 'LightArtillery'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.ALLUNITS - categories.WALL})

    # Land Defense
    # Maintains 4, 8, 12 Mobile Flak
    quantity = {2, 4, 6}
    for i = 1, 2 do
        opai = QAIMainBase:AddOpAI('BasicLandAttack', 'M3_MainLandDefense1_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M3_QAI_Main_Base_LandDef_Chain',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity({'MobileFlak'}, quantity[Difficulty])
    end

    # Maintains 4, 8, 12 Mobile Missiles
    quantity = {2, 4, 6}
    for i = 1, 2 do
        opai = QAIMainBase:AddOpAI('BasicLandAttack', 'M3_MainLandDefense2_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M3_QAI_Main_Base_LandDef_Chain',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity({'MobileMissiles'}, quantity[Difficulty])
    end
end

function QAILandBaseAI()

    # -------------
    # QAI Land Base
    # -------------
    QAILandBase:InitializeDifficultyTables(ArmyBrains[QAI], 'M3_QAI_LandBase', 'M3_QAI_LandBase_Marker', 40, {M3_QAI_LandBase = 100})
    QAILandBase:StartNonZeroBase({{3, 7, 11}, {3, 6, 9}})

    QAILandBaseAttacks()
end

function QAILandBaseAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    # ---------------------------------
    # QAI Land Base Op AI, Land Attacks
    # ---------------------------------

    # sends 6, 12, 18 [light tanks, heavy tanks]
    quantity = {6, 12, 18}
    opai = QAILandBase:AddOpAI('BasicLandAttack', 'M3_LandLandAttack1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_QAI_LandBase_Attack1_Chain', 'M3_QAI_LandBase_Attack2_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'LightTanks', 'HeavyTanks'}, quantity[Difficulty])
    if(Difficulty > 1) then
        opai:SetLockingStyle('None')
    end

    # sends 6, 12, 18 [light artillery, mobile missiles]
    quantity = {6, 12, 18}
    opai = QAILandBase:AddOpAI('BasicLandAttack', 'M3_LandLandAttack2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_QAI_LandBase_Attack1_Chain', 'M3_QAI_LandBase_Attack2_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'LightArtillery', 'MobileMissiles'}, quantity[Difficulty])
    if(Difficulty > 1) then
        opai:SetLockingStyle('None')
    end

    # sends 6, 12, 18 [mobile bombs, mobile stealth]
    quantity = {6, 12, 18}
    opai = QAILandBase:AddOpAI('BasicLandAttack', 'M3_LandLandAttack3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_QAI_LandBase_Attack1_Chain', 'M3_QAI_LandBase_Attack2_Chain'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'MobileBombs', 'MobileStealth'}, quantity[Difficulty])
    if(Difficulty > 1) then
        opai:SetLockingStyle('None')
    end

    # sends 2, 6, 12 [siege bots]
    quantity = {2, 6, 12}
    opai = QAILandBase:AddOpAI('BasicLandAttack', 'M3_LandLandAttack4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_QAI_LandBase_Attack1_Chain', 'M3_QAI_LandBase_Attack2_Chain'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('SiegeBots', quantity[Difficulty])
    if(Difficulty > 1) then
        opai:SetLockingStyle('None')
    end

    # sends 2, 6, 12 [heavy bots]
    quantity = {2, 6, 12}
    opai = QAILandBase:AddOpAI('BasicLandAttack', 'M3_LandLandAttack5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_QAI_LandBase_Attack1_Chain', 'M3_QAI_LandBase_Attack2_Chain'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('HeavyBots', quantity[Difficulty])
    if(Difficulty > 1) then
        opai:SetLockingStyle('None')
    end

    # sends 4, 6, 12 [mobile flak, mobile shields] if player has >= 60, 40, 40 mobile air
    quantity = {4, 6, 12}
    trigger = {60, 40, 40}
    opai = QAILandBase:AddOpAI('BasicLandAttack', 'M3_LandLandAttack6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_QAI_LandBase_Attack1_Chain', 'M3_QAI_LandBase_Attack2_Chain'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'MobileFlak', 'MobileShields'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.MOBILE * categories.AIR})

    # sends 4, 6, 12 [mobile flak, mobile shields] if player has >= 50, 30, 30 gunships
    quantity = {4, 6, 12}
    trigger = {50, 30, 30}
    opai = QAILandBase:AddOpAI('BasicLandAttack', 'M3_LandLandAttack7',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_QAI_LandBase_Attack1_Chain', 'M3_QAI_LandBase_Attack2_Chain'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'MobileFlak', 'MobileShields'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.uaa0203 + categories.uea0203 + categories.ura0203})

    # sends 6, 12, 18 [siege bots, heavy bots] if player has >= 60, 40, 20 T3 units
    quantity = {6, 10, 14}
    trigger = {60, 40, 20}
    opai = QAILandBase:AddOpAI('BasicLandAttack', 'M3_LandLandAttack8',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_QAI_LandBase_Attack1_Chain', 'M3_QAI_LandBase_Attack2_Chain'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity({'SiegeBots', 'HeavyBots'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.TECH3})

    # sends 6, 12, 12 [mobile flak] if player has >= 1 strat bomber
    quantity = {6, 12, 12}
    opai = QAILandBase:AddOpAI('BasicLandAttack', 'M3_LandLandAttack9',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_QAI_LandBase_Attack1_Chain', 'M3_QAI_LandBase_Attack2_Chain'},
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('MobileFlak', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', 1, categories.uaa0304 + categories.uea0304 + categories.ura0304})

    # sends 6, 9, 12 [mobile heavy artillery, mobile missiles, light artillery] if player has >= 450, 400, 350 units
    quantity = {6, 9, 12}
    trigger = {450, 400, 350}
    opai = QAILandBase:AddOpAI('BasicLandAttack', 'M3_LandLandAttack10',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_QAI_LandBase_Attack1_Chain', 'M3_QAI_LandBase_Attack2_Chain'},
            },
            Priority = 140,
        }
    )
    opai:SetChildQuantity({'MobileHeavyArtillery', 'MobileMissiles', 'LightArtillery'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.ALLUNITS - categories.WALL})

    # sends amphibious at Fletcher
    quantity = {6, 12, 18}
    opai = QAILandBase:AddOpAI('BasicLandAttack', 'M3_LandLandAttack11',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_QAI_LandBase_AttackFletcher_Chain',
            },
            Priority = 140,
        }
    )
    opai:SetChildQuantity('AmphibiousTanks', quantity[Difficulty])

    # Land Defense
    # Maintains 4, 6, 12 Heavy Tanks
    quantity = {2, 3, 6}
    for i = 1, 2 do
        opai = QAILandBase:AddOpAI('BasicLandAttack', 'M3_LandLandDefense1_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M3_QAI_LandBase_LandDef_Chain',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity({'HeavyTanks'}, quantity[Difficulty])
    end

    # Maintains 4, 6, 12 Heavy Bots
    quantity = {2, 3, 6}
    for i = 1, 2 do
        opai = QAILandBase:AddOpAI('BasicLandAttack', 'M3_LandLandDefense2_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M3_QAI_LandBase_LandDef_Chain',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity({'HeavyBots'}, quantity[Difficulty])
    end
end

function QAIAirBaseAI()

    # ------------
    # QAI Air Base
    # ------------
    QAIAirBase:InitializeDifficultyTables(ArmyBrains[QAI], 'M3_QAI_AirBase', 'M3_QAI_AirBase_Marker', 50, {M3_QAI_AirBase = 100})
    QAIAirBase:StartNonZeroBase({{2, 10, 14}, {2, 9, 12}})

    QAIAirBase:AddReactiveAI('ExperimentalLand', 'AirRetaliation', 'QAIAirBase_ExperimentalLand')
    QAIAirBase:AddReactiveAI('ExperimentalAir', 'AirRetaliation', 'QAIAirBase_ExperimentalAir')
    QAIAirBase:AddReactiveAI('Nuke', 'AirRetaliation', 'QAIAirBase_Nuke')
    QAIAirBase:AddReactiveAI('HLRA', 'AirRetaliation', 'QAIAirBase_HLRA')

    QAIAirBaseAttacks()
end

function QAIAirBaseAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    # -------------------------------
    # QAI Air Base Op AI, Air Attacks
    # -------------------------------

    # sends 6, 12, 18 [bombers]
    quantity = {6, 12, 18}
    opai = QAIAirBase:AddOpAI('AirAttacks', 'M3_AirAirAttack1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_QAI_AirBase_Attack_1_Chain', 'M3_QAI_AirBase_Attack_2_Chain', 'M3_QAI_AirBase_Attack_3_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Bombers', quantity[Difficulty])
    opai:SetLockingStyle('None')

    # sends 6, 12, 18 [interceptors]
    quantity = {6, 12, 18}
    opai = QAIAirBase:AddOpAI('AirAttacks', 'M3_AirAirAttack2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_QAI_AirBase_Attack_1_Chain', 'M3_QAI_AirBase_Attack_2_Chain', 'M3_QAI_AirBase_Attack_3_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Interceptors', quantity[Difficulty])
    opai:SetLockingStyle('None')

    # sends 4, 8, 12 [gunships, combat fighters]
    quantity = {4, 8, 12}
    opai = QAIAirBase:AddOpAI('AirAttacks', 'M3_AirAirAttack3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_QAI_AirBase_Attack_1_Chain', 'M3_QAI_AirBase_Attack_2_Chain', 'M3_QAI_AirBase_Attack_3_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'Gunships', 'CombatFighters'}, quantity[Difficulty])
    opai:SetLockingStyle('None')

    # sends 6, 12, 18 [gunships] if player has >= 100, 80, 60 mobile land
    quantity = {6, 12, 18}
    trigger = {100, 80, 60}
    opai = QAIAirBase:AddOpAI('AirAttacks', 'M3_AirAirAttack4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_QAI_AirBase_Attack_1_Chain', 'M3_QAI_AirBase_Attack_2_Chain', 'M3_QAI_AirBase_Attack_3_Chain'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], (categories.MOBILE * categories.LAND) - categories.CONSTRUCTION})

    # sends 6, 12, 18 [air superiority] if player has >= 60, 40, 40 mobile air
    quantity = {6, 12, 18}
    trigger = {60, 40, 40}
    opai = QAIAirBase:AddOpAI('AirAttacks', 'M3_AirAirAttack5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_QAI_AirBase_Attack_1_Chain', 'M3_QAI_AirBase_Attack_2_Chain', 'M3_QAI_AirBase_Attack_3_Chain'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.MOBILE * categories.AIR})

    # sends 6, 12, 18 [air superiority] if player has >= 50, 30, 30 gunships
    quantity = {6, 12, 18}
    trigger = {50, 30, 30}
    opai = QAIAirBase:AddOpAI('AirAttacks', 'M3_AirAirAttack6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_QAI_AirBase_Attack_1_Chain', 'M3_QAI_AirBase_Attack_2_Chain', 'M3_QAI_AirBase_Attack_3_Chain'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.uaa0203 + categories.uea0203 + categories.ura0203})

    # sends 6, 12, 18 [combat fighters, gunships] if player has >= 60, 40, 20 T3 units
    quantity = {6, 12, 18}
    trigger = {60, 40, 20}
    opai = QAIAirBase:AddOpAI('AirAttacks', 'M3_AirAirAttack7',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_QAI_AirBase_Attack_1_Chain', 'M3_QAI_AirBase_Attack_2_Chain', 'M3_QAI_AirBase_Attack_3_Chain'},
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity({'Gunships', 'CombatFighters'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainGreaterThanOrEqualNumCategory', {'default_brain', 'Player', trigger[Difficulty], categories.TECH3})

    # sends 6, 12, 18 [air superiority] if player has >= 1 strat bomber
    quantity = {6, 12, 18}
    opai = QAIAirBase:AddOpAI('AirAttacks', 'M3_AirAirAttack8',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_QAI_AirBase_Attack_1_Chain', 'M3_QAI_AirBase_Attack_2_Chain', 'M3_QAI_AirBase_Attack_3_Chain'},
            },
            Priority = 140,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainGreaterThanOrEqualNumCategory', {'default_brain', 'Player', 1, categories.uaa0304 + categories.uea0304 + categories.ura0304})

    # sends 8, 16, 24 [bombers, gunships] if player has >= 450, 400, 300 units
    quantity = {8, 16, 24}
    trigger = {450, 400, 300}
    opai = QAIAirBase:AddOpAI('AirAttacks', 'M3_AirAirAttack9',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_QAI_AirBase_Attack_1_Chain', 'M3_QAI_AirBase_Attack_2_Chain', 'M3_QAI_AirBase_Attack_3_Chain'},
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity({'Bombers', 'Gunships'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainGreaterThanOrEqualNumCategory', {'default_brain', 'Player', trigger[Difficulty], categories.ALLUNITS - categories.WALL})

    # sends 6, 12, 18 [heavy gunships] if player has >= 250, 200, 100 structures
    quantity = {1, 2, 3}
    trigger = {250, 200, 100}
    opai = QAIAirBase:AddOpAI('AirAttacks', 'M3_AirAirAttack10',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_QAI_AirBase_Attack_1_Chain', 'M3_QAI_AirBase_Attack_2_Chain', 'M3_QAI_AirBase_Attack_3_Chain'},
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity('HeavyGunships', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainGreaterThanOrEqualNumCategory', {'default_brain', 'Player', trigger[Difficulty], categories.STRUCTURE - categories.WALL})

    # sends 6, 12, 18 [bombers] at Fletcher
    quantity = {6, 12, 18}
    opai = QAIAirBase:AddOpAI('AirAttacks', 'M3_AirAirAttack11',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_QAI_AirBase_AttackFletcher_Chain',
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('Bombers', quantity[Difficulty])

    # sends 4, 8, 12 [gunships] at Fletcher
    quantity = {4, 8, 12}
    opai = QAIAirBase:AddOpAI('AirAttacks', 'M3_AirAirAttack12',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_QAI_AirBase_AttackFletcher_Chain',
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])

    # sends 4, 8, 12 [torpedo bombers] at Megalith
    quantity = {4, 8, 12}
    opai = QAIAirBase:AddOpAI('AirAttacks', 'M3_AirAirAttack13',
        {
            MasterPlatoonFunction = {'/maps/X1CA_Coop_005_v03/X1CA_Coop_005_v03_m3qaiai.lua', 'M3AttackMegalithWaterAI'},
            Priority = 150,
        }
    )
    opai:SetChildQuantity('TorpedoBombers', quantity[Difficulty])
    opai:AddBuildCondition('/maps/X1CA_Coop_005_v03/X1CA_Coop_005_v03_m3qaiai.lua', 'MegalithOnWater', {})

    # sends 4, 8, 12 [gunships] at Megalith
    quantity = {4, 8, 12}
    opai = QAIAirBase:AddOpAI('AirAttacks', 'M3_AirAirAttack14',
        {
            MasterPlatoonFunction = {'/maps/X1CA_Coop_005_v03/X1CA_Coop_005_v03_m3qaiai.lua', 'M3AttackMegalithLandAI'},
            Priority = 140,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    opai:AddBuildCondition('/maps/X1CA_Coop_005_v03/X1CA_Coop_005_v03_m3qaiai.lua', 'MegalithOnLand', {})

    # sends 4, 8, 12 [torpedo bombers] at Player CDR
    quantity = {4, 8, 12}
    opai = QAIAirBase:AddOpAI('AirAttacks', 'M3_AirAirAttack15',
        {
            MasterPlatoonFunction = {'/maps/X1CA_Coop_005_v03/X1CA_Coop_005_v03_m3qaiai.lua', 'M3AttackCDRWaterAI'},
            Priority = 150,
        }
    )
    opai:SetChildQuantity('TorpedoBombers', quantity[Difficulty])
    opai:AddBuildCondition('/maps/X1CA_Coop_005_v03/X1CA_Coop_005_v03_m3qaiai.lua', 'CDROnWater', {})

    # sends 4, 8, 12 [gunships] at Player CDR
    quantity = {4, 8, 12}
    opai = QAIAirBase:AddOpAI('AirAttacks', 'M3_AirAirAttack16',
        {
            MasterPlatoonFunction = {'/maps/X1CA_Coop_005_v03/X1CA_Coop_005_v03_m3qaiai.lua', 'M3AttackCDRLandAI'},
            Priority = 140,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    opai:AddBuildCondition('/maps/X1CA_Coop_005_v03/X1CA_Coop_005_v03_m3qaiai.lua', 'CDROnLand', {})

    opai = QAIAirBase:AddOpAI('M3_Air_Base_Spiderbot_Unit',
        {
            Amount = 1,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_QAI_Fatboy_AttackFletcher_Chain',
            },

            MaxAssist = 10,
            Retry = true,
        }
    )

    # Air Defense
    for i = 1, 2 do
        opai = QAIAirBase:AddOpAI('AirAttacks', 'M3_AirAirDefense' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M3_QAI_AirBase_Def_Chain',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('AirSuperiority', 6)
    end

    for i = 3, 4 do
        opai = QAIAirBase:AddOpAI('AirAttacks', 'M3_AirAirDefense' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M3_QAI_AirBase_Def_Chain',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('Gunships', 6)
    end
end

function QAINavalBaseAI()

    # --------------
    # QAI Naval Base
    # --------------
    QAINavalBase:InitializeDifficultyTables(ArmyBrains[QAI], 'M3_QAI_Naval_Base', 'M3_QAI_Naval_Base_Marker', 50, {M3_QAI_Naval_Base = 100})
    QAINavalBase:StartNonZeroBase({{1, 4, 7}, {1, 3, 6}})

    QAINavalBaseAttacks()
end

function QAINavalBaseAttacks()

    # -----------------------------------
    # QAI Naval Base Op AI, Naval Attacks
    # -----------------------------------
    local quantity = {20, 30, 40}
    for i = 1, 2 do
        local navalOSB = NavalOSB.GenerateNavalOSB('QAINaval' .. i, 5, 1, quantity[Difficulty], 'C', 100, nil, nil)
        local opai = QAINavalBase:AddOpAI(navalOSB, 'QAINaval' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M3_QAI_NavalBase_Def' .. i .. '_Chain',
                },
            }
        )

        opai:SetChildActive('Cruiser', false)
        opai:SetChildActive('T3', false)
    end
end

function QAICybranExpBaseAI()

    # -------------------
    # QAI Cybran Exp Base
    # -------------------
    QAICybranExpBase:InitializeDifficultyTables(ArmyBrains[QAI], 'M3_QAI_ExpBase', 'M3_QAI_ExpBase_Marker', 50, {M3_QAI_ExpBase = 100})
    QAICybranExpBase:StartNonZeroBase({1, 2, 3})

    QAICybranExpBaseAttacks()
end

function QAICybranExpBaseAttacks()

    # -------------------------
    # QAI Cybran Exp Base Op AI
    # -------------------------

    local units = {'M3_QAI_Exp_Spider', 'M3_QAI_Exp_Gunship'}
    if(Difficulty == 3) then
        table.insert(units, 'M3_QAI_Exp_Scathis')
    end
    local numEngineers = {1, 2, 3}
    local opai = QAICybranExpBase:AddOpAI(units,
        {
            Amount = 1,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_QAI_ExpBase_Attack_Chain',
            },

            MaxAssist = numEngineers[Difficulty],
            Retry = true,
        }
    )
end

function QAIAeonExpBaseAI()

    # -----------------
    # QAI Aeon Exp Base
    # -----------------
    QAIAeonExpBase:InitializeDifficultyTables(ArmyBrains[AeonArmy], 'M3_Aeon_Factory', 'M3_QAI_ExpBase_Marker', 50, {M3_Aeon_Factory = 100})
    QAIAeonExpBase:StartNonZeroBase({1, 2, 3})

    QAIAeonExpBaseAttacks()
end

function QAIAeonExpBaseAttacks()

    # -----------------------
    # QAI Aeon Exp Base Op AI
    # -----------------------

    local numEngineers = {1, 2, 3}
    local opai = QAIAeonExpBase:AddOpAI({'M3_Aeon_Exp_Czar', 'M3_Aeon_Exp_Col'},
        {
            Amount = 1,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Experimental_Patrol_2_Chain',
            },

            MaxAssist = numEngineers[Difficulty],
            Retry = true,
        }
    )
end

function QAIUEFExpBaseAI()

    # ----------------
    # QAI UEF Exp Base
    # ----------------
    QAIUEFExpBase:InitializeDifficultyTables(ArmyBrains[UEFArmy], 'M3_UEF_Factory', 'M3_QAI_ExpBase_Marker', 50, {M3_UEF_Factory = 100})
    QAIUEFExpBase:StartNonZeroBase({1, 2, 3})

    QAIUEFExpBaseAttacks()
end

function QAIUEFExpBaseAttacks()

    # ----------------------
    # QAI UEF Exp Base Op AI
    # ----------------------

    local numEngineers = {1, 2, 3}
    local opai = QAIUEFExpBase:AddOpAI('M3_UEF_Exp_Fatboy',
        {
            Amount = 1,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Experimental_Patrol_3_Chain',
            },

            MaxAssist = numEngineers[Difficulty],
            Retry = true,
        }
    )
end

function MegalithOnWater()
    local unit = ArmyBrains[Brackman]:GetListOfUnits(categories.xrl0403, false)
    local result = false

    if(unit[1] and not unit[1]:IsDead() and unit[1]:GetCurrentLayer() == 'Seabed') then
        result = true
    else
        result = false
    end

    return result
end

function MegalithOnLand(category)
    local unit = ArmyBrains[Brackman]:GetListOfUnits(categories.xrl0403, false)
    local result = false

    if(unit[1] and not unit[1]:IsDead() and unit[1]:GetCurrentLayer() == 'Land') then
        result = true
    else
        result = false
    end

    return result
end

function M3AttackMegalithWaterAI(platoon)
    local unit = ArmyBrains[Brackman]:GetListOfUnits(categories.xrl0403, false)
    if(unit[1] and not unit[1]:IsDead() and unit[1]:GetCurrentLayer() == 'Seabed') then
        platoon:AttackTarget(unit[1])
    else
        ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_QAI_NavalBase_Def1_Chain')
    end
end

function M3AttackMegalithLandAI(platoon)
    local unit = ArmyBrains[Brackman]:GetListOfUnits(categories.xrl0403, false)
    if(unit[1] and not unit[1]:IsDead() and unit[1]:GetCurrentLayer() == 'Land') then
        platoon:AttackTarget(unit[1])
    else
        ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_QAI_AirBase_Attack_1_Chain')
    end
end

function CDROnWater(category)
    local unit = ArmyBrains[Player]:GetListOfUnits(categories.COMMAND, false)
    local result = false

    if(unit[1] and not unit[1]:IsDead() and unit[1]:GetCurrentLayer() == 'Seabed') then
        result = true
    else
        result = false
    end

    return result
end

function CDROnLand(category)
    local unit = ArmyBrains[Player]:GetListOfUnits(categories.COMMAND, false)
    local result = false

    if(unit[1] and not unit[1]:IsDead() and unit[1]:GetCurrentLayer() == 'Land') then
        result = true
    else
        result = false
    end

    return result
end

function M3AttackCDRWaterAI(platoon)
    local unit = ArmyBrains[Player]:GetListOfUnits(categories.COMMAND, false)
    if(unit[1] and not unit[1]:IsDead() and unit[1]:GetCurrentLayer() == 'Seabed') then
        platoon:AttackTarget(unit[1])
    else
        ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_QAI_NavalBase_Def1_Chain')
    end
end

function M3AttackCDRLandAI(platoon)
    local unit = ArmyBrains[Player]:GetListOfUnits(categories.COMMAND, false)
    if(unit[1] and not unit[1]:IsDead() and unit[1]:GetCurrentLayer() == 'Land') then
        platoon:AttackTarget(unit[1])
    else
        ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_QAI_AirBase_Attack_1_Chain')
    end
end