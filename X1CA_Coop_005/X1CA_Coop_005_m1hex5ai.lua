-- ****************************************************************************
-- **
-- **  File     : /maps/X1CA_Coop_005/X1CA_Coop_005_v03_m1hex5ai.lua
-- **  Author(s): Jessica St. Croix
-- **
-- **  Summary  : Hex5 army AI for Mission 1 - X1CA_Coop_005
-- **
-- **  Copyright © 2007 Gas Powered Games, Inc.  All rights reserved.
-- ****************************************************************************
local BaseManager = import('/lua/ai/opai/basemanager.lua')

local SPAIFileName = '/lua/ScenarioPlatoonAI.lua'

--------
-- Locals
--------
local Hex5 = 3
local Difficulty = ScenarioInfo.Options.Difficulty

---------------
-- Base Managers
---------------
local Hex5M1Base = BaseManager.CreateBaseManager()
local Hex5M1ResourceBase1 = BaseManager.CreateBaseManager()
local Hex5M1ResourceBase2 = BaseManager.CreateBaseManager()
local Hex5M1ResourceBase3 = BaseManager.CreateBaseManager()

function Hex5M1BaseAI()

    --------------
    -- Hex5 M1 Base
    --------------
    Hex5M1Base:InitializeDifficultyTables(ArmyBrains[Hex5], 'M1_Hex5_Main_Base', 'M1_Hex5_Base_Marker', 100, {M1_Hex5_Main_Base = 100})
    Hex5M1Base:StartNonZeroBase({{4, 9, 14}, {4, 8, 12}})
    Hex5M1Base:SetActive('AirScouting', true)
    Hex5M1Base:SetActive('LandScouting', true)
    Hex5M1Base:SetBuild('Defenses', false)

    Hex5M1Base:AddReactiveAI('ExperimentalLand', 'AirRetaliation', 'Hex5M1Base_ExperimentalLand')
    Hex5M1Base:AddReactiveAI('ExperimentalAir', 'AirRetaliation', 'Hex5M1Base_ExperimentalAir')
    Hex5M1Base:AddReactiveAI('Nuke', 'AirRetaliation', 'Hex5M1Base_Nuke')
    Hex5M1Base:AddReactiveAI('HLRA', 'AirRetaliation', 'Hex5M1Base_HLRA')

    Hex5M1BaseAirAttacks()
    Hex5M1BaseLandAttacks()
end

function Hex5M1BaseAirAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    ---------------------------------
    -- Hex5 M1 Base Op AI, Air Attacks
    ---------------------------------

    -- sends 3 [bombers] if player has >= 12, 8, 5 AA
    trigger = {12, 8, 5}
    opai = Hex5M1Base:AddOpAI('AirAttacks', 'M1_AirAttack1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Hex5_Main_AirAttack_1', 'M1_Hex5_Main_AirAttack_2'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Bombers', 3)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.ANTIAIR})

    -- sends 2, 2, 4 [gunships, combat fighter] if player has >= 7, 5, 3 T2/T3 AA
    quantity = {2, 2, 4}
    trigger = {7, 5, 3}
    opai = Hex5M1Base:AddOpAI('AirAttacks', 'M1_AirAttack2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Hex5_Main_AirAttack_1', 'M1_Hex5_Main_AirAttack_2'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'Gunships', 'CombatFighters'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.ANTIAIR - categories.TECH1})

    -- sends 1, 2, 3 [interceptors] if player has >= 15, 10, 10 mobile air
    quantity = {1, 2, 3}
    trigger = {15, 10, 10}
    opai = Hex5M1Base:AddOpAI('AirAttacks', 'M1_AirAttack3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Hex5_Main_AirAttack_1', 'M1_Hex5_Main_AirAttack_2'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Interceptors', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.MOBILE * categories.AIR})

    -- sends 2, 3, 6 [light gunships] if player has >= 50, 40, 30 structures
    quantity = {2, 3, 6}
    trigger = {50, 40, 30}
    opai = Hex5M1Base:AddOpAI('AirAttacks', 'M1_AirAttack4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Hex5_Main_AirAttack_1', 'M1_Hex5_Main_AirAttack_2'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('LightGunships', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.STRUCTURE - categories.WALL})

    -- sends 2, 3, 6 [gunships] if player has >= 30, 20, 10 T2/T3 structures
    quantity = {2, 3, 6}
    trigger = {30, 20, 10}
    opai = Hex5M1Base:AddOpAI('AirAttacks', 'M1_AirAttack5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Hex5_Main_AirAttack_1', 'M1_Hex5_Main_AirAttack_2'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.STRUCTURE - categories.TECH1})

    -- sends 1, 2, 3 [gunships] if player has >= 75, 60, 40 mobile land units
    quantity = {1, 2, 3}
    trigger = {75, 60, 40}
    opai = Hex5M1Base:AddOpAI('AirAttacks', 'M1_AirAttack6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Hex5_Main_AirAttack_1', 'M1_Hex5_Main_AirAttack_2'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], (categories.MOBILE * categories.LAND) - categories.CONSTRUCTION})

    -- sends 2, 3, 6 [combat fighter] if player has >= 75, 60, 40 mobile air units
    quantity = {2, 3, 6}
    trigger = {75, 60, 40}
    opai = Hex5M1Base:AddOpAI('AirAttacks', 'M1_AirAttack7',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Hex5_Main_AirAttack_1', 'M1_Hex5_Main_AirAttack_2'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('CombatFighters', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.MOBILE * categories.AIR})

    -- sends 2, 4, 6 [combat fighter, gunships] if player has >= 40, 30, 20 gunships
    quantity = {2, 4, 6}
    trigger = {40, 30, 20}
    opai = Hex5M1Base:AddOpAI('AirAttacks', 'M1_AirAttack8',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Hex5_Main_AirAttack_1', 'M1_Hex5_Main_AirAttack_2'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity({'CombatFighters', 'Gunships'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.uaa0203 + categories.uea0203 + categories.ura0203})

    -- sends 2, 3, 4 [gunships] if player has >= 50, 40, 30 T3 units
    quantity = {2, 3, 4}
    trigger = {50, 40, 30}
    opai = Hex5M1Base:AddOpAI('AirAttacks', 'M1_AirAttack9',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Hex5_Main_AirAttack_1', 'M1_Hex5_Main_AirAttack_2'},
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.TECH3})

    -- sends 1, 2, 3 [combat fighter] if player has >= 1 strat bomber
    quantity = {1, 2, 3}
    opai = Hex5M1Base:AddOpAI('AirAttacks', 'M1_AirAttack10',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Hex5_Main_AirAttack_1', 'M1_Hex5_Main_AirAttack_2'},
            },
            Priority = 140,
        }
    )
    opai:SetChildQuantity('CombatFighters', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', 1, categories.uaa0304 + categories.uea0304 + categories.ura0304})

    -- sends 0, 4, 6 [gunships, combat fighters] if player has >= 250 (D2), 200 (D3) units
    if(Difficulty > 1) then
        quantity = {0, 4, 6}
        trigger = {0, 250, 200}
        opai = Hex5M1Base:AddOpAI('AirAttacks', 'M1_AirAttack11',
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
                PlatoonData = {
                    PatrolChains = {'M1_Hex5_Main_AirAttack_1', 'M1_Hex5_Main_AirAttack_2'},
                },
                Priority = 150,
            }
        )
        opai:SetChildQuantity({'CombatFighters', 'Gunships'}, quantity[Difficulty])
        opai:SetLockingStyle('None')
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
            {'default_brain', 'Player', trigger[Difficulty], categories.ALLUNITS - categories.WALL})
    end

    -- Air Defense
    for i = 1, 2 do
        opai = Hex5M1Base:AddOpAI('AirAttacks', 'M1_AirDefense' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M1_Hex5_Main_AirDef_Chain',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('Interceptors', 3)
    end

    for i = 3, 4 do
        opai = Hex5M1Base:AddOpAI('AirAttacks', 'M1_AirDefense' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M1_Hex5_Main_AirDef_Chain',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('AirSuperiority', 3)
    end
end

function Hex5M1BaseLandAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    ----------------------------------
    -- Hex5 M1 Base Op AI, Land Attacks
    ----------------------------------

    -- sends engineers
    if(Difficulty > 1) then
        trigger = {0, 9, 14}
        opai = Hex5M1Base:AddOpAI('EngineerAttack', 'M1_EngAttack1',
            {
                MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
                PlatoonData = {
                    AttackChain = 'TransportAttack_PlayerBaseArea',
                    LandingChain = 'TransportAttack_PlayerBaseArea',
                    TransportReturn = 'M1_Hex5_Base_Marker',
                    Categories = {'ALLUNITS'},
                },
                Priority = 90,
            }
        )
        opai:SetChildActive('T2Engineers', false)
        opai:SetChildActive('T2Transports', false)
        opai:RemoveChildren({'T2Engineers', 'T2Transports'})
        opai:SetLockingStyle('BuildTimer', {LockTimer = 120})
        opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua', 'HaveLessThanUnitsWithCategoryInArea',
            {'default_brain', trigger[Difficulty], categories.url0105, 'M1Area'})
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainLessThanOrEqualNumCategory',
            {'default_brain', 'Player', 3, categories.DEFENSE * categories.STRUCTURE})
    end

    -- sends 5, 7, 10 [light bots] if player has >= 8, 5, 3 DF/IF
    quantity = {5, 7, 10}
    trigger = {8, 5, 3}
    opai = Hex5M1Base:AddOpAI('BasicLandAttack', 'M1_LandAttack1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Hex5_Main_LandAttack_1', 'M1_Hex5_Main_LandAttack_2', 'M1_Hex5_Main_LandAttack_3', 'M1_Hex5_Main_LandAttack_4'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('LightBots', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.DIRECTFIRE + categories.INDIRECTFIRE})

    -- sends 5, 7, 10 [light tanks] if player has >= 10, 8, 6 DF/IF
    quantity = {5, 7, 10}
    trigger = {10, 8, 6}
    opai = Hex5M1Base:AddOpAI('BasicLandAttack', 'M1_LandAttack2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Hex5_Main_LandAttack_1', 'M1_Hex5_Main_LandAttack_2', 'M1_Hex5_Main_LandAttack_3', 'M1_Hex5_Main_LandAttack_4'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('LightTanks', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.DIRECTFIRE + categories.INDIRECTFIRE})

    -- sends 5, 7, 10 [light artillery] if player has >= 40, 30, 20 units
    quantity = {5, 7, 10}
    trigger = {40, 30, 20}
    opai = Hex5M1Base:AddOpAI('BasicLandAttack', 'M1_LandAttack3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Hex5_Main_LandAttack_1', 'M1_Hex5_Main_LandAttack_2', 'M1_Hex5_Main_LandAttack_3', 'M1_Hex5_Main_LandAttack_4'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('LightArtillery', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.ALLUNITS - categories.WALL})

    -- sends 5, 7, 10 [mobile aa] if player has >= 10, 8, 6 planes
    quantity = {5, 7, 10}
    trigger = {10, 8, 6}
    opai = Hex5M1Base:AddOpAI('BasicLandAttack', 'M1_LandAttack4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Hex5_Main_LandAttack_1', 'M1_Hex5_Main_LandAttack_2', 'M1_Hex5_Main_LandAttack_3', 'M1_Hex5_Main_LandAttack_4'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('MobileAntiAir', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.MOBILE * categories.AIR})

    -- sends 2, 4, 10 [light tanks, heavy tanks] if player has >= 8, 6, 4 T2/T3 DF/IF
    quantity = {2, 4, 10}
    trigger = {8, 6, 4}
    opai = Hex5M1Base:AddOpAI('BasicLandAttack', 'M1_LandAttack5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Hex5_Main_LandAttack_1', 'M1_Hex5_Main_LandAttack_2', 'M1_Hex5_Main_LandAttack_3', 'M1_Hex5_Main_LandAttack_4'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'LightTanks', 'HeavyTanks'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], (categories.DIRECTFIRE + categories.INDIRECTFIRE) - categories.TECH1})

    -- sends 2, 6, 10 [light artillery, mobile missiles] if player has >= 12, 10, 8 T2/T3 DF/IF
    quantity = {2, 6, 10}
    trigger = {12, 10, 8}
    opai = Hex5M1Base:AddOpAI('BasicLandAttack', 'M1_LandAttack6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Hex5_Main_LandAttack_1', 'M1_Hex5_Main_LandAttack_2', 'M1_Hex5_Main_LandAttack_3', 'M1_Hex5_Main_LandAttack_4'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'LightArtillery', 'MobileMissiles'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], (categories.DIRECTFIRE + categories.INDIRECTFIRE) - categories.TECH1})

    -- sends 2, 4, 10 [amphibious tanks] if player has >= 70, 60, 50 units
    quantity = {2, 4, 10}
    trigger = {70, 60, 50}
    opai = Hex5M1Base:AddOpAI('BasicLandAttack', 'M1_LandAttack7',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M1_Hex5_Main_AmphibAttack_1',
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('AmphibiousTanks', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.ALLUNITS - categories.WALL})

    -- sends 4, 6, 10 [light artillery, mobile missiles] if player has >= 100, 80, 60 units
    quantity = {4, 6, 10}
    trigger = {100, 80, 60}
    opai = Hex5M1Base:AddOpAI('BasicLandAttack', 'M1_LandAttack8',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Hex5_Main_LandAttack_1', 'M1_Hex5_Main_LandAttack_2', 'M1_Hex5_Main_LandAttack_3', 'M1_Hex5_Main_LandAttack_4'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'LightArtillery', 'MobileMissiles'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.ALLUNITS - categories.WALL})

    -- sends 4, 8, 14 [mobile bombs, mobile stealth] if player has >= 10, 8, 6 shields
    quantity = {4, 8, 14}
    trigger = {10, 8, 6}
    opai = Hex5M1Base:AddOpAI('BasicLandAttack', 'M1_LandAttack9',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Hex5_Main_LandAttack_1', 'M1_Hex5_Main_LandAttack_2', 'M1_Hex5_Main_LandAttack_3', 'M1_Hex5_Main_LandAttack_4'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity({'MobileBombs', 'MobileStealth'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.STRUCTURE * categories.SHIELD})

    -- sends 3, 5, 7 [mobile aa] if player has >= 40, 30, 20 mobile air units
    quantity = {3, 5, 7}
    trigger = {40, 30, 20}
    opai = Hex5M1Base:AddOpAI('BasicLandAttack', 'M1_LandAttack10',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Hex5_Main_LandAttack_1', 'M1_Hex5_Main_LandAttack_2', 'M1_Hex5_Main_LandAttack_3', 'M1_Hex5_Main_LandAttack_4'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('MobileAntiAir', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.MOBILE * categories.AIR})

    -- sends 3, 5, 7 [mobile flak] if player has >= 60, 50, 40 mobile air units
    quantity = {3, 5, 7}
    trigger = {60, 50, 40}
    opai = Hex5M1Base:AddOpAI('BasicLandAttack', 'M1_LandAttack11',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Hex5_Main_LandAttack_1', 'M1_Hex5_Main_LandAttack_2', 'M1_Hex5_Main_LandAttack_3', 'M1_Hex5_Main_LandAttack_4'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('MobileFlak', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.MOBILE * categories.AIR})

    -- sends 6, 8, 14 [amphibious tanks, light tanks] if player has >= 12, 8, 4 T3 units
    quantity = {6, 8, 14}
    trigger = {12, 8, 4}
    opai = Hex5M1Base:AddOpAI('BasicLandAttack', 'M1_LandAttack12',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Hex5_Main_LandAttack_1', 'M1_Hex5_Main_LandAttack_2', 'M1_Hex5_Main_LandAttack_3', 'M1_Hex5_Main_LandAttack_4'},
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity({'AmphibiousTanks', 'LightTanks'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.TECH3})

    -- sends 3, 5, 7 [mobile flak] if player has >= 1 strat bomber
    quantity = {3, 5, 7}
    opai = Hex5M1Base:AddOpAI('BasicLandAttack', 'M1_LandAttack13',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Hex5_Main_LandAttack_1', 'M1_Hex5_Main_LandAttack_2', 'M1_Hex5_Main_LandAttack_3', 'M1_Hex5_Main_LandAttack_4'},
            },
            Priority = 140,
        }
    )
    opai:SetChildQuantity('MobileFlak', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainGreaterThanOrEqualNumCategory', {'default_brain', 'Player', 1, categories.uaa0304 + categories.uea0304 + categories.ura0304})

    -- sends 6, 10, 14 [mobile missiles, light artillery] if player has >= 300, 250, 200 units
    quantity = {6, 10, 14}
    trigger = {300, 250, 200}
    opai = Hex5M1Base:AddOpAI('BasicLandAttack', 'M1_LandAttack14',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Hex5_Main_LandAttack_1', 'M1_Hex5_Main_LandAttack_2', 'M1_Hex5_Main_LandAttack_3', 'M1_Hex5_Main_LandAttack_4'},
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity({'MobileMissiles', 'LightArtillery'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.ALLUNITS - categories.WALL})

    -- Land Defense
    quantity = {3, 5, 7}
    opai = Hex5M1Base:AddOpAI('BasicLandAttack', 'M1_LandDefense1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Hex5_Main_LandDefEast_Chain', 'M1_Hex5_Main_LandDefWest_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('MobileFlak', quantity[Difficulty])

    quantity = {3, 5, 7}
    opai = Hex5M1Base:AddOpAI('BasicLandAttack', 'M1_LandDefense2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Hex5_Main_LandDefEast_Chain', 'M1_Hex5_Main_LandDefWest_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('MobileAntiAir', quantity[Difficulty])

    quantity = {3, 5, 7}
    opai = Hex5M1Base:AddOpAI('BasicLandAttack', 'M1_LandDefense3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Hex5_Main_LandDefEast_Chain', 'M1_Hex5_Main_LandDefWest_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('HeavyTanks', quantity[Difficulty])

    if(Difficulty > 1) then
        quantity = {0, 5, 7}
        opai = Hex5M1Base:AddOpAI('BasicLandAttack', 'M1_LandDefense4',
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
                PlatoonData = {
                    PatrolChains = {'M1_Hex5_Main_LandDefEast_Chain', 'M1_Hex5_Main_LandDefWest_Chain'},
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('MobileMissiles', quantity[Difficulty])
    end
end

function Hex5M1ResourceBase1AI()

    -------------------------
    -- Hex5 M1 Resource Base 1
    -------------------------
    Hex5M1ResourceBase1:InitializeDifficultyTables(ArmyBrains[Hex5], 'M1_Hex5_Resource1', 'M1_Hex5_Resource1_Marker', 30, {M1_Hex5_Resource1 = 100})
    Hex5M1ResourceBase1:StartNonZeroBase({{1, 2, 3}, {1, 2, 3}})
    Hex5M1ResourceBase1:SetActive('LandScouting', true)
    Hex5M1ResourceBase1:SetBuildAllStructures(false)

    Hex5M1ResourceBase1LandAttacks()
end

function Hex5M1ResourceBase1LandAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    ------------------------------------------
    -- Hex5 Resource Base 1 Op AI, Land Attacks
    ------------------------------------------

    -- sends 1, 1, 2 [light bots] if player has >= 8, 5, 3 DF/IF
    quantity = {1, 1, 2}
    trigger = {8, 5, 3}
    opai = Hex5M1ResourceBase1:AddOpAI('BasicLandAttack', 'M1_LandResource1Attack1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Hex5_Resource1_Att1_Chain', 'M1_Hex5_Resource1_Att1b_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('LightBots', quantity[Difficulty])
    if(Difficulty < 3) then
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
            {'default_brain', 'Player', trigger[Difficulty], categories.DIRECTFIRE + categories.INDIRECTFIRE})
    end

    -- sends 1, 1, 2 [light tanks] if player has >= 10, 8, 6 DF/IF
    quantity = {1, 1, 2}
    trigger = {10, 8, 6}
    opai = Hex5M1ResourceBase1:AddOpAI('BasicLandAttack', 'M1_LandResource1Attack2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Hex5_Resource1_Att1_Chain', 'M1_Hex5_Resource1_Att1b_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('LightTanks', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.DIRECTFIRE + categories.INDIRECTFIRE})

    -- sends 1, 1, 2 [light artillery] if player has >= 40, 30, 20 units
    quantity = {1, 1, 2}
    trigger = {40, 30, 20}
    opai = Hex5M1ResourceBase1:AddOpAI('BasicLandAttack', 'M1_LandResource1Attack3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Hex5_Resource1_Att1_Chain', 'M1_Hex5_Resource1_Att1b_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('LightArtillery', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.ALLUNITS - categories.WALL})

    -- sends 1, 1, 2 [mobile aa] if player has >= 10, 8, 6 planes
    quantity = {1, 1, 2}
    trigger = {10, 8, 6}
    opai = Hex5M1ResourceBase1:AddOpAI('BasicLandAttack', 'M1_LandResource1Attack4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Hex5_Resource1_Att1_Chain', 'M1_Hex5_Resource1_Att1b_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('MobileAntiAir', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.MOBILE * categories.AIR})

    -- sends 2, 4, 6 [light tanks, heavy tanks] if player has >= 8, 6, 4 T2/T3 DF/IF
    quantity = {2, 4, 6}
    trigger = {8, 6, 4}
    opai = Hex5M1ResourceBase1:AddOpAI('BasicLandAttack', 'M1_LandResource1Attack5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Hex5_Resource1_Att1_Chain', 'M1_Hex5_Resource1_Att1b_Chain'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'LightTanks', 'HeavyTanks'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], (categories.DIRECTFIRE + categories.INDIRECTFIRE) - categories.TECH1})

    -- sends 4, 6, 8 [light artillery, mobile missiles] if player has >= 12, 10, 8 T2/T3 DF/IF
    quantity = {4, 6, 8}
    trigger = {12, 10, 8}
    opai = Hex5M1ResourceBase1:AddOpAI('BasicLandAttack', 'M1_LandResource1Attack6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Hex5_Resource1_Att1_Chain', 'M1_Hex5_Resource1_Att1b_Chain'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'LightArtillery', 'MobileMissiles'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], (categories.DIRECTFIRE + categories.INDIRECTFIRE) - categories.TECH1})

    -- sends 2, 4, 6 [light tanks, heavy tanks] if player has >= 70, 60, 50 units
    quantity = {2, 4, 6}
    trigger = {70, 60, 50}
    opai = Hex5M1ResourceBase1:AddOpAI('BasicLandAttack', 'M1_LandResource1Attack7',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Hex5_Resource1_Att1_Chain', 'M1_Hex5_Resource1_Att1b_Chain'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'LightTanks', 'HeavyTanks'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.ALLUNITS - categories.WALL})

    -- sends 2, 6, 8 [light artillery, mobile missiles] if player has >= 90, 80, 70 units
    quantity = {2, 6, 8}
    trigger = {90, 80, 70}
    opai = Hex5M1ResourceBase1:AddOpAI('BasicLandAttack', 'M1_LandResource1Attack8',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Hex5_Resource1_Att1_Chain', 'M1_Hex5_Resource1_Att1b_Chain'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'LightArtillery', 'MobileMissiles'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.ALLUNITS - categories.WALL})

    -- sends 4, 8, 12 [mobile bombs, mobile stealth] if player has >= 10, 8, 6 shields
    quantity = {4, 8, 12}
    trigger = {10, 8, 6}
    opai = Hex5M1ResourceBase1:AddOpAI('BasicLandAttack', 'M1_LandResource1Attack9',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Hex5_Resource1_Att1_Chain', 'M1_Hex5_Resource1_Att1b_Chain'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity({'MobileBombs', 'MobileStealth'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.STRUCTURE * categories.SHIELD})

    -- sends 2, 4, 6 [mobile aa] if player has >= 40, 30, 20 mobile air units
    quantity = {2, 4, 6}
    trigger = {40, 30, 20}
    opai = Hex5M1ResourceBase1:AddOpAI('BasicLandAttack', 'M1_LandResource1Attack10',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Hex5_Resource1_Att1_Chain', 'M1_Hex5_Resource1_Att1b_Chain'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('MobileAntiAir', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.MOBILE * categories.AIR})

    -- sends 2, 4, 6 [mobile flak] if player has >= 60, 50, 40 mobile air units
    quantity = {2, 4, 6}
    trigger = {60, 50, 40}
    opai = Hex5M1ResourceBase1:AddOpAI('BasicLandAttack', 'M1_LandResource1Attack11',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Hex5_Resource1_Att1_Chain', 'M1_Hex5_Resource1_Att1b_Chain'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('MobileFlak', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.MOBILE * categories.AIR})

    -- sends 4, 8, 12 [amphibious tanks, light tanks] if player has >= 10, 8, 6 T3 units
    quantity = {4, 8, 12}
    trigger = {10, 8, 6}
    opai = Hex5M1ResourceBase1:AddOpAI('BasicLandAttack', 'M1_LandResource1Attack12',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Hex5_Resource1_Att1_Chain', 'M1_Hex5_Resource1_Att1b_Chain'},
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity({'AmphibiousTanks', 'LightTanks'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.TECH3})

    -- sends 2, 3, 4 [mobile flak] if player has >= 1 strat bomber
    quantity = {2, 3, 4}
    opai = Hex5M1ResourceBase1:AddOpAI('BasicLandAttack', 'M1_LandResource1Attack13',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Hex5_Resource1_Att1_Chain', 'M1_Hex5_Resource1_Att1b_Chain'},
            },
            Priority = 140,
        }
    )
    opai:SetChildQuantity('MobileFlak', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainGreaterThanOrEqualNumCategory', {'default_brain', 'Player', 1, categories.uaa0304 + categories.uea0304 + categories.ura0304})

    -- sends 6, 12, 18 [mobile missiles, light artillery] if player has >= 300, 250, 200 units
    quantity = {6, 12, 18}
    trigger = {300, 250, 200}
    opai = Hex5M1ResourceBase1:AddOpAI('BasicLandAttack', 'M1_LandResource1Attack14',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Hex5_Resource1_Att1_Chain', 'M1_Hex5_Resource1_Att1b_Chain'},
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity({'MobileMissiles', 'LightArtillery'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.ALLUNITS - categories.WALL})
end

function Hex5M1ResourceBase2AI()

    -------------------------
    -- Hex5 M1 Resource Base 2
    -------------------------
    Hex5M1ResourceBase2:InitializeDifficultyTables(ArmyBrains[Hex5], 'M1_Hex5_Resource2', 'M1_Hex5_Resource2_Marker', 30, {M1_Hex5_Resource2 = 100})
    Hex5M1ResourceBase2:StartNonZeroBase({{1, 2, 3}, {1, 2, 3}})
    Hex5M1ResourceBase2:SetActive('AirScouting', true)
    Hex5M1ResourceBase2:SetBuildAllStructures(false)

    Hex5M1ResourceBase2AirAttacks()
end

function Hex5M1ResourceBase2AirAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    -----------------------------------------
    -- Hex5 Resource Base 2 Op AI, Air Attacks
    -----------------------------------------

    -- sends 1, 2, 3 [bombers] if player has >= 12, 8, 5 AA
    quantity = {1, 2, 3}
    trigger = {12, 8, 5}
    opai = Hex5M1ResourceBase2:AddOpAI('AirAttacks', 'M1_AirResource2Attack1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M1_Hex5_Resource2_AirAttack_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Bombers', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.ANTIAIR})

    -- sends 2, 4, 6 [gunships, combat fighter] if player has >= 7, 5, 3 T2/T3 AA
    quantity = {2, 4, 6}
    trigger = {7, 5, 3}
    opai = Hex5M1ResourceBase2:AddOpAI('AirAttacks', 'M1_AirResource2Attack2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M1_Hex5_Resource2_AirAttack_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'Gunships', 'CombatFighters'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.ANTIAIR - categories.TECH1})

    -- sends 2, 3, 4 [interceptors] if player has >= 15, 10, 10 mobile air
    quantity = {2, 3, 4}
    trigger = {15, 10, 10}
    opai = Hex5M1ResourceBase2:AddOpAI('AirAttacks', 'M1_AirResource2Attack3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M1_Hex5_Resource2_AirAttack_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Interceptors', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.MOBILE * categories.AIR})

    -- sends 1, 3, 4 [light gunships] if player has >= 50, 40, 30 structures
    quantity = {1, 3, 4}
    trigger = {50, 40, 30}
    opai = Hex5M1ResourceBase2:AddOpAI('AirAttacks', 'M1_AirResource2Attack4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M1_Hex5_Resource2_AirAttack_Chain',
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('LightGunships', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.STRUCTURE - categories.WALL})

    -- sends 1, 3, 4 [gunships] if player has >= 30, 20, 10 T2/T3 structures
    quantity = {1, 3, 4}
    trigger = {30, 20, 10}
    opai = Hex5M1ResourceBase2:AddOpAI('AirAttacks', 'M1_AirResource2Attack5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M1_Hex5_Resource2_AirAttack_Chain',
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.STRUCTURE - categories.TECH1})

    -- sends 1, 4, 5 [gunships] if player has >= 75, 60, 40 mobile land units
    quantity = {1, 4, 5}
    trigger = {75, 60, 40}
    opai = Hex5M1ResourceBase2:AddOpAI('AirAttacks', 'M1_AirResource2Attack6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M1_Hex5_Resource2_AirAttack_Chain',
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], (categories.MOBILE * categories.LAND) - categories.CONSTRUCTION})

    -- sends 1, 3, 4 [combat fighter] if player has >= 75, 60, 40 mobile air units
    quantity = {1, 3, 4}
    trigger = {75, 60, 40}
    opai = Hex5M1ResourceBase2:AddOpAI('AirAttacks', 'M1_AirResource2Attack7',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M1_Hex5_Resource2_AirAttack_Chain',
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('CombatFighters', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.MOBILE * categories.AIR})

    -- sends 2, 4, 6 [combat fighter, gunships] if player has >= 40, 30, 20 gunships
    quantity = {2, 4, 6}
    trigger = {40, 30, 20}
    opai = Hex5M1ResourceBase2:AddOpAI('AirAttacks', 'M1_AirResource2Attack8',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M1_Hex5_Resource2_AirAttack_Chain',
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity({'CombatFighters', 'Gunships'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.uaa0203 + categories.uea0203 + categories.ura0203})

    -- sends 2, 3, 4 [gunships] if player has >= 50, 40, 30 T3 units
    quantity = {2, 3, 4}
    trigger = {50, 40, 30}
    opai = Hex5M1ResourceBase2:AddOpAI('AirAttacks', 'M1_AirResource2Attack9',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M1_Hex5_Resource2_AirAttack_Chain',
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.TECH3})

    -- sends 2, 3, 4 [combat fighter] if player has >= 1 strat bomber
    quantity = {2, 3, 4}
    opai = Hex5M1ResourceBase2:AddOpAI('AirAttacks', 'M1_AirResource2Attack10',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M1_Hex5_Resource2_AirAttack_Chain',
            },
            Priority = 140,
        }
    )
    opai:SetChildQuantity('CombatFighters', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', 1, categories.uaa0304 + categories.uea0304 + categories.ura0304})

    -- sends 0, 4, 6 [gunships, combat fighters] if player has >= 250 (D2), 200 (D3) units
    if(Difficulty > 1) then
        quantity = {0, 4, 6}
        trigger = {0, 250, 200}
        opai = Hex5M1ResourceBase2:AddOpAI('AirAttacks', 'M1_AirResource2Attack11',
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M1_Hex5_Resource2_AirAttack_Chain',
                },
                Priority = 150,
            }
        )
        opai:SetChildQuantity({'CombatFighters', 'Gunships'}, quantity[Difficulty])
        opai:SetLockingStyle('None')
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
            {'default_brain', 'Player', trigger[Difficulty], categories.ALLUNITS - categories.WALL})
    end

    -- Air Defense
    quantity = {1, 2, 3}
    for i = 1, 2 do
        opai = Hex5M1ResourceBase2:AddOpAI('AirAttacks', 'M1_AirResource2Defense' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M1_Hex5_Resource2_AirDef_Chain',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('Interceptors', quantity[Difficulty])
    end

    quantity = {1, 2, 3}
    for i = 3, 4 do
        opai = Hex5M1Base:AddOpAI('AirAttacks', 'M1_AirResource2Defense' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M1_Hex5_Resource2_AirDef_Chain',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    end
end

function Hex5M1ResourceBase3AI()

    -------------------------
    -- Hex5 M1 Resource Base 3
    -------------------------
    Hex5M1ResourceBase3:InitializeDifficultyTables(ArmyBrains[Hex5], 'M1_Hex5_Resource3', 'M1_Hex5_Resource3_Marker', 30, {M1_Hex5_Resource3 = 100})
    Hex5M1ResourceBase3:StartNonZeroBase({{1, 2, 3}, {1, 2, 3}})
    Hex5M1ResourceBase3:SetActive('AirScouting', true)
    Hex5M1ResourceBase3:SetBuildAllStructures(false)

    Hex5M1ResourceBase3AirAttacks()
end

function Hex5M1ResourceBase3AirAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    -----------------------------------------
    -- Hex5 Resource Base 3 Op AI, Air Attacks
    -----------------------------------------

    -- sends 1, 2, 3 [bombers] if player has >= 12, 8, 5 AA
    quantity = {1, 2, 3}
    trigger = {12, 8, 5}
    opai = Hex5M1ResourceBase3:AddOpAI('AirAttacks', 'M1_AirResource3Attack1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M1_Hex5_Resource3_AirAttack_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Bombers', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.ANTIAIR})

    -- sends 2, 4, 6 [gunships, combat fighter] if player has >= 7, 5, 3 T2/T3 AA
    quantity = {2, 4, 6}
    trigger = {7, 5, 3}
    opai = Hex5M1ResourceBase3:AddOpAI('AirAttacks', 'M1_AirResource3Attack2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M1_Hex5_Resource3_AirAttack_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'Gunships', 'CombatFighters'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.ANTIAIR - categories.TECH1})

    -- sends 2, 3, 4 [interceptors] if player has >= 15, 10, 10 mobile air
    quantity = {2, 3, 4}
    trigger = {15, 10, 10}
    opai = Hex5M1ResourceBase3:AddOpAI('AirAttacks', 'M1_AirResource3Attack3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M1_Hex5_Resource3_AirAttack_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Interceptors', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.MOBILE * categories.AIR})

    -- sends 1, 3, 4 [light gunships] if player has >= 50, 40, 30 structures
    quantity = {1, 3, 4}
    trigger = {50, 40, 30}
    opai = Hex5M1ResourceBase3:AddOpAI('AirAttacks', 'M1_AirResource3Attack4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M1_Hex5_Resource3_AirAttack_Chain',
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('LightGunships', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.STRUCTURE - categories.WALL})

    -- sends 1, 3, 4 [gunships] if player has >= 30, 20, 10 T2/T3 structures
    quantity = {1, 3, 4}
    trigger = {30, 20, 10}
    opai = Hex5M1ResourceBase3:AddOpAI('AirAttacks', 'M1_AirResource3Attack5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M1_Hex5_Resource3_AirAttack_Chain',
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.STRUCTURE - categories.TECH1})

    -- sends 1, 4, 5 [gunships] if player has >= 75, 60, 40 mobile land units
    quantity = {1, 4, 5}
    trigger = {75, 60, 40}
    opai = Hex5M1ResourceBase3:AddOpAI('AirAttacks', 'M1_AirResource3Attack6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M1_Hex5_Resource3_AirAttack_Chain',
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], (categories.MOBILE * categories.LAND) - categories.CONSTRUCTION})

    -- sends 1, 3, 4 [combat fighter] if player has >= 75, 60, 40 mobile air units
    quantity = {1, 3, 4}
    trigger = {75, 60, 40}
    opai = Hex5M1ResourceBase3:AddOpAI('AirAttacks', 'M1_AirResource3Attack7',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M1_Hex5_Resource3_AirAttack_Chain',
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('CombatFighters', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.MOBILE * categories.AIR})

    -- sends 2, 4, 6 [combat fighter, gunships] if player has >= 40, 30, 20 gunships
    quantity = {2, 4, 6}
    trigger = {40, 30, 20}
    opai = Hex5M1ResourceBase3:AddOpAI('AirAttacks', 'M1_AirResource3Attack8',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M1_Hex5_Resource3_AirAttack_Chain',
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity({'CombatFighters', 'Gunships'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.uaa0203 + categories.uea0203 + categories.ura0203})

    -- sends 2, 3, 4 [gunships] if player has >= 50, 40, 30 T3 units
    quantity = {2, 3, 4}
    trigger = {50, 40, 30}
    opai = Hex5M1ResourceBase3:AddOpAI('AirAttacks', 'M1_AirResource3Attack9',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M1_Hex5_Resource3_AirAttack_Chain',
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.TECH3})

    -- sends 2, 3, 4 [combat fighter] if player has >= 1 strat bomber
    quantity = {2, 3, 4}
    opai = Hex5M1ResourceBase3:AddOpAI('AirAttacks', 'M1_AirResource3Attack10',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M1_Hex5_Resource3_AirAttack_Chain',
            },
            Priority = 140,
        }
    )
    opai:SetChildQuantity('CombatFighters', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', 1, categories.uaa0304 + categories.uea0304 + categories.ura0304})

    -- sends 0, 4, 6 [gunships, combat fighters] if player has >= 250 (D2), 200 (D3) units
    if(Difficulty > 1) then
        quantity = {0, 4, 6}
        trigger = {0, 250, 200}
        opai = Hex5M1ResourceBase3:AddOpAI('AirAttacks', 'M1_AirResource3Attack11',
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M1_Hex5_Resource3_AirAttack_Chain',
                },
                Priority = 150,
            }
        )
        opai:SetChildQuantity({'CombatFighters', 'Gunships'}, quantity[Difficulty])
        opai:SetLockingStyle('None')
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
            {'default_brain', 'Player', trigger[Difficulty], categories.ALLUNITS - categories.WALL})
    end

    -- Air Defense
    quantity = {1, 2, 3}
    for i = 1, 2 do
        opai = Hex5M1ResourceBase3:AddOpAI('AirAttacks', 'M1_AirResource3Defense' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M1_Hex5_Resource3_AirDef_Chain',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('Interceptors', quantity[Difficulty])
    end

    quantity = {1, 2, 3}
    for i = 3, 4 do
        opai = Hex5M1ResourceBase3:AddOpAI('AirAttacks', 'M1_AirResource3Defense' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M1_Hex5_Resource3_AirDef_Chain',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    end
end
