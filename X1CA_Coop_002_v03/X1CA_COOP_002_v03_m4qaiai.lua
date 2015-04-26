#****************************************************************************
#**
#**  File     : /maps/X1CA_Coop_002_v03/X1CA_Coop_002_v03_m4qaiai.lua
#**  Author(s): Jessica St. Croix
#**
#**  Summary  : QAI army AI for Mission 4 - X1CA_Coop_002_v03
#**
#**  Copyright © 2007 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************
local BaseManager = import('/lua/ai/opai/basemanager.lua')

local SPAIFileName = '/lua/scenarioplatoonai.lua'

# ------
# Locals
# ------
local QAI = 3
local Difficulty = ScenarioInfo.Options.Difficulty

# -------------
# Base Managers
# -------------
local QAIM4MainBase = BaseManager.CreateBaseManager()
local QAIM4NavalBase = BaseManager.CreateBaseManager()
local QAIM4NorthBase = BaseManager.CreateBaseManager()
local QAIM4CenterBase = BaseManager.CreateBaseManager()
local QAIM4SouthBase = BaseManager.CreateBaseManager()

function QAIM4MainBaseAI()

    # ----------------
    # QAI M4 Main Base
    # ----------------
    QAIM4MainBase:InitializeDifficultyTables(ArmyBrains[QAI], 'M4_Main_Base', 'QAI_M4_Main_Base_Marker', 80, {M4_Main_Base = 100})
    QAIM4MainBase:StartNonZeroBase({{5, 9, 13}, {4, 7, 10}})
    QAIM4MainBase:SetActive('AirScouting', true)
    QAIM4MainBase:SetActive('LandScouting', true)
    QAIM4MainBase:SetBuild('Defenses', false)
    QAIM4MainBase:SetBuild('Shields', true)

    QAIM4MainBase:AddReactiveAI('ExperimentalLand', 'AirRetaliation', 'QAIM4MainBase_ExperimentalLand')
    QAIM4MainBase:AddReactiveAI('ExperimentalAir', 'AirRetaliation', 'QAIM4MainBase_ExperimentalAir')
    QAIM4MainBase:AddReactiveAI('ExperimentalNaval', 'AirRetaliation', 'QAIM4MainBase_ExperimentalNaval')
    QAIM4MainBase:AddReactiveAI('Nuke', 'AirRetaliation', 'QAIM4MainBase_Nuke')
    QAIM4MainBase:AddReactiveAI('HLRA', 'AirRetaliation', 'QAIM4MainBase_HLRA')

    QAIM4MainBaseAirAttacks()
    QAIM4MainBaseLandAttacks()
end

function QAIM4MainBaseAirAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    # -------------------------------
    # QAI M4 Base Op AI, Air Attacks
    # -------------------------------

    # sends 5, 10, 15 [bombers], ([gunships] on hard)
    quantity = {5, 10, 15}
    opai = QAIM4MainBase:AddOpAI('AirAttacks', 'M4_AirAttacks1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Land_Attack_Full_Chain', 'M3_QAI_AirAttack_East_Chain', 'M3_QAI_AirAttack_West_Chain', 'M3_QAI_AirAttack_Mid_Chain', 'M4_Order_Air_Defense_Chain'},
            },
            Priority = 100,
        }
    )
    if(Difficulty < 3) then
        opai:SetChildQuantity('Bombers', quantity[Difficulty])
    else
        opai:SetChildQuantity('Gunships', quantity[Difficulty])
    end
    opai:SetLockingStyle('None')

    # sends 4, 10, 14 [interceptors], ([interceptors, air superiority] on hard)
    quantity = {4, 10, 14}
    opai = QAIM4MainBase:AddOpAI('AirAttacks', 'M4_AirAttacks2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Land_Attack_Full_Chain', 'M3_QAI_AirAttack_East_Chain', 'M3_QAI_AirAttack_West_Chain', 'M3_QAI_AirAttack_Mid_Chain', 'M4_Order_Air_Defense_Chain'},
            },
            Priority = 100,
        }
    )
    if(Difficulty < 3) then
        opai:SetChildQuantity('Interceptors', quantity[Difficulty])
    else
        opai:SetChildQuantity({'Interceptors', 'AirSuperiority'}, quantity[Difficulty])
    end
    opai:SetLockingStyle('None')

    # sends 4, 10, 14 [gunships, combat fighters]
    quantity = {4, 10, 14}
    opai = QAIM4MainBase:AddOpAI('AirAttacks', 'M4_AirAttacks3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Land_Attack_Full_Chain', 'M3_QAI_AirAttack_East_Chain', 'M3_QAI_AirAttack_West_Chain', 'M3_QAI_AirAttack_Mid_Chain', 'M4_Order_Air_Defense_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'Gunships', 'CombatFighters'}, quantity[Difficulty])
    opai:SetLockingStyle('None')

    # sends 5, 10, 15 [gunships] if player has >= 100, 80, 60 mobile land, ([heavy gunships] on hard)
    quantity = {5, 10, 15}
    trigger = {100, 80, 60}
    opai = QAIM4MainBase:AddOpAI('AirAttacks', 'M4_AirAttacks4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Land_Attack_Full_Chain', 'M3_QAI_AirAttack_East_Chain', 'M3_QAI_AirAttack_West_Chain', 'M3_QAI_AirAttack_Mid_Chain', 'M4_Order_Air_Defense_Chain'},
            },
            Priority = 110,
        }
    )
    if(Difficulty < 3) then
        opai:SetChildQuantity('Gunships', quantity[Difficulty])
    else
        opai:SetChildQuantity('HeavyGunships', quantity[Difficulty])
    end
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], (categories.MOBILE * categories.LAND) - categories.CONSTRUCTION})

    # sends 5, 10, 15 [air superiority] if player has >= 60, 40, 40 mobile air
    quantity = {5, 10, 15}
    trigger = {60, 40, 40}
    opai = QAIM4MainBase:AddOpAI('AirAttacks', 'M4_AirAttacks5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Land_Attack_Full_Chain', 'M3_QAI_AirAttack_East_Chain', 'M3_QAI_AirAttack_West_Chain', 'M3_QAI_AirAttack_Mid_Chain', 'M4_Order_Air_Defense_Chain'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.MOBILE * categories.AIR})

    # sends 5, 10, 15 [air superiority] if player has >= 50, 30, 30 gunships
    quantity = {5, 10, 15}
    trigger = {50, 30, 30}
    opai = QAIM4MainBase:AddOpAI('AirAttacks', 'M4_AirAttacks6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Land_Attack_Full_Chain', 'M3_QAI_AirAttack_East_Chain', 'M3_QAI_AirAttack_West_Chain', 'M3_QAI_AirAttack_Mid_Chain', 'M4_Order_Air_Defense_Chain'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.uaa0203 + categories.uea0203 + categories.ura0203})

    # sends 4, 10, 14 [combat fighters, gunships] if player has >= 60, 40, 20 T3 units
    quantity = {4, 10, 14}
    trigger = {60, 40, 20}
    opai = QAIM4MainBase:AddOpAI('AirAttacks', 'M4_AirAttacks7',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Land_Attack_Full_Chain', 'M3_QAI_AirAttack_East_Chain', 'M3_QAI_AirAttack_West_Chain', 'M3_QAI_AirAttack_Mid_Chain', 'M4_Order_Air_Defense_Chain'},
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity({'Gunships', 'CombatFighters'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainGreaterThanOrEqualNumCategory', {'default_brain', 'Player', trigger[Difficulty], categories.TECH3})

    # sends 5, 10, 15 [air superiority] if player has >= 1 strat bomber
    quantity = {5, 10, 15}
    opai = QAIM4MainBase:AddOpAI('AirAttacks', 'M4_AirAttacks8',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Land_Attack_Full_Chain', 'M3_QAI_AirAttack_East_Chain', 'M3_QAI_AirAttack_West_Chain', 'M3_QAI_AirAttack_Mid_Chain', 'M4_Order_Air_Defense_Chain'},
            },
            Priority = 140,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainGreaterThanOrEqualNumCategory', {'default_brain', 'Player', 1, categories.uaa0304 + categories.uea0304 + categories.ura0304})

    # sends 10, 20, 24 [bombers, gunships] if player has >= 450, 400, 300 units, ([heavy gunships] on hard)
    quantity = {10, 20, 24}
    trigger = {450, 400, 300}
    opai = QAIM4MainBase:AddOpAI('AirAttacks', 'M4_AirAttacks9',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Land_Attack_Full_Chain', 'M3_QAI_AirAttack_East_Chain', 'M3_QAI_AirAttack_West_Chain', 'M3_QAI_AirAttack_Mid_Chain', 'M4_Order_Air_Defense_Chain'},
            },
            Priority = 150,
        }
    )
    if(Difficulty < 3) then
        opai:SetChildQuantity({'Bombers', 'Gunships'}, quantity[Difficulty])
    else
        opai:SetChildQuantity('HeavyGunships', quantity[Difficulty])
    end
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainGreaterThanOrEqualNumCategory', {'default_brain', 'Player', trigger[Difficulty], categories.ALLUNITS - categories.WALL})

    # Air Defense
    for i = 1, 2 do
        opai = QAIM4MainBase:AddOpAI('AirAttacks', 'M4_AirDefense' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M4_Main_Base_Air_Def_Chain',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('AirSuperiority', 5)
    end
end

function QAIM4MainBaseLandAttacks()
    local opai = nil
    local quantity = nil
    local trigger = nil

    # ------------------------------------
    # QAI M4 Main Base Op AI, Land Attacks
    # ------------------------------------

    # builds monkey defense
    opai = QAIM4MainBase:AddOpAI('UNIT_666',
        {
            Amount = 3,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'RandomPatrolThread'},
            PlatoonData = {
                PatrolChain = 'M4_Main_Base_East_Def_Chain',
            },
            MaxAssist = 6,
            Retry = true,
        }
    )

    # sends 6, 10, 20 [siege bots, light tanks, heavy tanks] to order base
    quantity = {6, 12, 18}
    opai = QAIM4MainBase:AddOpAI('BasicLandAttack', 'M4_LandAttack_Order_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M4_QAI_AttackOrder_Land2_Chain',
            },
            Priority = 180,
        }
    )
    opai:SetChildQuantity({'SiegeBots', 'HeavyTanks', 'LightTanks'}, quantity[Difficulty])

    # sends 6, 10, 20 [light tanks, heavy tanks]
    quantity = {6, 10, 20}
    opai = QAIM4MainBase:AddOpAI('BasicLandAttack', 'M4_LandAttack1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Land_Attack_Full_Chain', 'M3_Land_Attack_Full2_Chain', 'M3_Land_Attack_Full3_Chain', 'M4_QAI_AttackOrder_Land2_Chain',}
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'LightTanks', 'HeavyTanks'}, quantity[Difficulty])
    if(Difficulty > 1) then
        opai:SetLockingStyle('None')
    end

    # sends 6, 10, 20 [light artillery, mobile missiles]
    quantity = {6, 10, 20}
    opai = QAIM4MainBase:AddOpAI('BasicLandAttack', 'M4_LandAttack2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Land_Attack_Full_Chain', 'M3_Land_Attack_Full2_Chain', 'M3_Land_Attack_Full3_Chain', 'M4_QAI_AttackOrder_Land2_Chain',}
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'LightArtillery', 'MobileMissiles'}, quantity[Difficulty])
    if(Difficulty > 1) then
        opai:SetLockingStyle('None')
    end

    # sends 6, 10, 20 [mobile bombs, mobile stealth]
    quantity = {6, 10, 20}
    opai = QAIM4MainBase:AddOpAI('BasicLandAttack', 'M4_LandAttack3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Land_Attack_Full_Chain', 'M3_Land_Attack_Full2_Chain', 'M3_Land_Attack_Full3_Chain', 'M4_QAI_AttackOrder_Land2_Chain',}
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'MobileBombs', 'MobileStealth'}, quantity[Difficulty])
    if(Difficulty > 1) then
        opai:SetLockingStyle('None')
    end

    # sends 4, 6, 8 [mobile flak, mobile shields] if player has >= 60, 40, 40 mobile air
    quantity = {4, 6, 8}
    trigger = {60, 40, 40}
    opai = QAIM4MainBase:AddOpAI('BasicLandAttack', 'M4_LandAttack4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Land_Attack_Full_Chain', 'M3_Land_Attack_Full2_Chain', 'M3_Land_Attack_Full3_Chain', 'M4_QAI_AttackOrder_Land2_Chain',}
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
    opai = QAIM4MainBase:AddOpAI('BasicLandAttack', 'M4_LandAttack5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Land_Attack_Full_Chain', 'M3_Land_Attack_Full2_Chain', 'M3_Land_Attack_Full3_Chain', 'M4_QAI_AttackOrder_Land2_Chain',}
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'MobileFlak', 'MobileShields'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.uaa0203 + categories.uea0203 + categories.ura0203})

    # sends 6, 10, 20 [siege bots, heavy bots] if player has >= 60, 40, 20 T3 units
    quantity = {6, 10, 20}
    trigger = {60, 40, 20}
    opai = QAIM4MainBase:AddOpAI('BasicLandAttack', 'M4_LandAttack6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Land_Attack_Full_Chain', 'M3_Land_Attack_Full2_Chain', 'M3_Land_Attack_Full3_Chain', 'M4_QAI_AttackOrder_Land2_Chain',}
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity({'SiegeBots', 'HeavyBots'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.TECH3})

    # sends 1, 2, 2 [mobile flak] if player has >= 1 strat bomber
    quantity = {1, 2, 2}
    opai = QAIM4MainBase:AddOpAI('BasicLandAttack', 'M4_LandAttack7',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Land_Attack_Full_Chain', 'M3_Land_Attack_Full2_Chain', 'M3_Land_Attack_Full3_Chain', 'M4_QAI_AttackOrder_Land2_Chain',}
            },
            Priority = 130,
        }
    )
    opai:SetChildActive('All', false)
    opai:SetChildActive('MobileFlak', true)
    opai:SetChildCount(quantity[Difficulty])
    opai:KeepChildren('MobileFlak')
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', 1, categories.uaa0304 + categories.uea0304 + categories.ura0304})

    # sends 6, 9, 21 [mobile heavy artillery, mobile missiles, light artillery] if player has >= 450, 400, 350 units
    quantity = {6, 9, 21}
    trigger = {450, 400, 350}
    opai = QAIM4MainBase:AddOpAI('BasicLandAttack', 'M4_LandAttack8',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Land_Attack_Full_Chain', 'M3_Land_Attack_Full2_Chain', 'M3_Land_Attack_Full3_Chain', 'M4_QAI_AttackOrder_Land2_Chain',}
            },
            Priority = 140,
        }
    )
    opai:SetChildQuantity({'MobileHeavyArtillery', 'MobileMissiles', 'LightArtillery'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.ALLUNITS - categories.WALL})

    # Land Defense
    # Maintains 4, 8, 12 Heavy Tanks
    quantity = {2, 4, 6}
    for i = 1, 2 do
        opai = QAIM4MainBase:AddOpAI('BasicLandAttack', 'M4_LandDefense1_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M4_Main_Base_NW_Def_Chain',
                },
                Priority = 160,
            }
        )
        opai:SetChildQuantity({'HeavyTanks'}, quantity[Difficulty])
    end

    # Maintains 4, 8, 12 Mobile Missiles
    quantity = {2, 4, 6}
    for i = 1, 2 do
        opai = QAIM4MainBase:AddOpAI('BasicLandAttack', 'M4_LandDefense2_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M4_Main_Base_NW_Def_Chain',
                },
                Priority = 160,
            }
        )
        opai:SetChildQuantity({'MobileMissiles'}, quantity[Difficulty])
    end
end

function QAIM4NavalBaseAI()

    # -----------------
    # QAI M4 Naval Base
    # -----------------
    QAIM4NavalBase:InitializeDifficultyTables(ArmyBrains[QAI], 'M4_Naval_Base', 'QAI_M4_Naval_Marker', 80, {M4_Naval_Base = 100})
    QAIM4NavalBase:StartNonZeroBase({{4, 7, 10}, {4, 6, 8}})
    QAIM4NavalBase:SetBuild('Defenses', false)

    QAIM4NavalBaseNavalAttacks()
end

function QAIM4NavalBaseNavalAttacks()
    local opai = nil

    # --------------------------------------
    # QAI M4 Naval Base Op AI, Naval Attacks
    # --------------------------------------

    # sends [frigates]
    opai = QAIM4NavalBase:AddNavalAI('M4_NavalAttack1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_QAI_NavalAttack_1_Chain', 'M4_Naval_Attack_2_Chain'},
            },
            EnableTypes = {'Frigate'},
            MaxFrigates = 3,
            MinFrigates = 3,
            Priority = 100,
        }
    )

    # sends [frigates, subs] if player has >= 8 boats
    opai = QAIM4NavalBase:AddNavalAI('M4_NavalAttack2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_QAI_NavalAttack_1_Chain', 'M4_Naval_Attack_2_Chain'},
            },
            EnableTypes = {
                'Frigate',
                'Submarine',
            },
            MaxFrigates = 6,
            MinFrigates = 6,
            Priority = 110,
        }
    )
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainGreaterThanOrEqualNumCategory', {'default_brain', 'Player', 8, categories.NAVAL * categories.MOBILE})

    # sends all but T3 if player has >= 2 T2/T3 boats
    opai = QAIM4NavalBase:AddNavalAI('M4_NavalAttack3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_QAI_NavalAttack_1_Chain', 'M4_Naval_Attack_2_Chain'},
            },
            MaxFrigates = 6,
            MinFrigates = 6,
            Priority = 120,
        }
    )
    opai:SetChildActive('T3', false)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainGreaterThanOrEqualNumCategory', {'default_brain', 'Player', 2, (categories.NAVAL * categories.MOBILE) - categories.TECH1})

    # sends all but T3 if player has >= 5 T2/T3 boats
    opai = QAIM4NavalBase:AddNavalAI('M4_NavalAttack4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_QAI_NavalAttack_1_Chain', 'M4_Naval_Attack_2_Chain'},
            },
            MaxFrigates = 9,
            MinFrigates = 9,
            Priority = 130,
        }
    )
    opai:SetChildActive('T3', false)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainGreaterThanOrEqualNumCategory', {'default_brain', 'Player', 5, (categories.NAVAL * categories.MOBILE) - categories.TECH1})
end

function QAIM4NorthBaseAI()

    # -----------------
    # QAI M4 North Base
    # -----------------
    QAIM4NorthBase:Initialize(ArmyBrains[QAI], 'QAI_M4_North_Base', 'QAI_M4_North_Base', 40, {M4_QAI_North_Base = 100})
    QAIM4NorthBase:StartNonZeroBase(7)
	QAIM4NorthBase:SetMaximumConstructionEngineers(5)
	
	QAIM4NorthBase:AddBuildGroup('M4_QAI_Middle_Base', 90)

    QAIM4NorthBaseLandAttacks()
end

function QAIM4NorthBaseLandAttacks()
    local opai = nil

    # -------------------------------------
    # QAI M4 North Base Op AI, Land Attacks
    # -------------------------------------

    # Land Attack
    opai = QAIM4NorthBase:AddOpAI('BasicLandAttack', 'M4_LandAttack_North',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackLocation'},
            PlatoonData = {
                Location = 'Order_M4_North_Base',
            },
            Priority = 100,
        }
    )
    opai:SetChildActive('MobileShields', false)
    opai:RemoveChildren('MobileShields')
    opai:SetChildCount(1)
    opai:SetLockingStyle('BuildTimer', {LockTimer = 2})
end

function QAIM4CenterBaseAI()

    # ------------------
    # QAI M4 Center Base
    # ------------------
    QAIM4CenterBase:Initialize(ArmyBrains[QAI], 'QAI_M4_Middle_Base', 'QAI_M4_Middle_Base', 40, {M4_QAI_Middle_Base = 100})
    QAIM4CenterBase:StartNonZeroBase(9)
	
	QAIM4CenterBase:AddBuildGroup('M4_QAI_North_Base', 90)
	QAIM4CenterBase:AddBuildGroup('M4_QAI_South_Base', 90)
	QAIM4CenterBase:SetMaximumConstructionEngineers(4)

    QAIM4CenterBaseAirAttacks()
    QAIM4CenterBaseLandAttacks()
end

function QAIM4CenterBaseAirAttacks()
    local opai = nil

    # -------------------------------------
    # QAI M4 Center Base Op AI, Air Attacks
    # -------------------------------------

    # Air Attack
    opai = QAIM4CenterBase:AddOpAI('AirAttacks', 'M4_AirAttack_Center',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackLocation'},
            PlatoonData = {
                Location = 'Order_M4_Middle_Base',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Gunships', 6)
    opai:SetLockingStyle('None')
	
    opai = QAIM4CenterBase:AddOpAI('AirAttacks', 'M4_AirAttack_Center2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackLocation'},
            PlatoonData = {
                Location = 'Order_M4_Middle_Base',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Bombers', 8)
    opai:SetLockingStyle('None')
end

function QAIM4CenterBaseLandAttacks()
    local opai = nil

    # --------------------------------------
    # QAI M4 Center Base Op AI, Land Attacks
    # --------------------------------------

     # Land Attack
    opai = QAIM4CenterBase:AddOpAI('BasicLandAttack', 'M4_LandAttack_Center_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackLocation'},
            PlatoonData = {
                Location = 'Order_M4_Middle_Base',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('HeavyTanks', 8)
    opai:SetLockingStyle('None')

    opai = QAIM4CenterBase:AddOpAI('BasicLandAttack', 'M4_LandAttack_Center_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackLocation'},
            PlatoonData = {
                Location = 'Order_M4_Middle_Base',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('MobileMissiles', 6)
    opai:SetLockingStyle('None')
end

function QAIM4SouthBaseAI()

    # -----------------
    # QAI M4 South Base
    # -----------------
    QAIM4SouthBase:Initialize(ArmyBrains[QAI], 'QAI_M4_South_Base', 'QAI_M3_South_Base', 40, {M4_QAI_South_Base = 100})
    QAIM4SouthBase:StartNonZeroBase(7)
	
	QAIM4SouthBase:AddBuildGroup('M4_QAI_Middle_Base', 90)

    QAIM4SouthBaseAirAttacks()
    QAIM4SouthBaseLandAttacks()
end

function QAIM4SouthBaseAirAttacks()
    local opai = nil

    # ------------------------------------
    # QAI M4 South Base Op AI, Air Attacks
    # ------------------------------------

    # Air Attack
    opai = QAIM4SouthBase:AddOpAI('AirAttacks', 'M4_AirAttack_South',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackLocation'},
            PlatoonData = {
                Location = 'Order_M4_South_Base',
            },
            Priority = 100,
        }
    )
    opai:SetChildCount(1)
    opai:SetLockingStyle('BuildTimer', {LockTimer = 2})
end

function QAIM4SouthBaseLandAttacks()
    local opai = nil

    # -------------------------------------
    # QAI M4 South Base Op AI, Land Attacks
    # -------------------------------------

    # Land Attack
    opai = QAIM4SouthBase:AddOpAI('BasicLandAttack', 'M4_LandAttack_South',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackLocation'},
            PlatoonData = {
                Location = 'Order_M4_South_Base',
            },
            Priority = 100,
        }
    )
    opai:SetChildActive('MobileShields', false)
    opai:RemoveChildren('MobileShields')
    opai:SetChildCount(1)
    opai:SetLockingStyle('BuildTimer', {LockTimer = 2})
end