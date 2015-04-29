-- ****************************************************************************
-- **
-- **  File     : /maps/X1CA_Coop_001/X1CA_Coop_001_m3orderai.lua
-- **  Author(s): Jessica St. Croix
-- **
-- **  Summary  : Order army AI for Mission 3 - X1CA_Coop_001
-- **
-- **  Copyright © 2007 Gas Powered Games, Inc.  All rights reserved.
-- ****************************************************************************
local BaseManager = import('/lua/ai/opai/basemanager.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')

local SPAIFileName = '/lua/scenarioplatoonai.lua'

--------
-- Locals
--------
local Order = 3
local Difficulty = ScenarioInfo.Options.Difficulty

---------------
-- Base Managers
---------------
local OrderM3MainBase = BaseManager.CreateBaseManager()
local OrderM3NavalBase = BaseManager.CreateBaseManager()
local OrderM3ExpansionBase = BaseManager.CreateBaseManager()

function OrderM3MainBaseAI()

    --------------------
    -- Order M3 Main Base
    --------------------
    ScenarioUtils.CreateArmyGroup('Order', 'M2_Order_AirBase_Init_Eng_D' .. Difficulty)
    ScenarioUtils.CreateArmyGroup('Order', 'M2_Order_LandBase_Init_Eng_D' .. Difficulty)
    OrderM3MainBase:InitializeDifficultyTables(ArmyBrains[Order], 'M2_Main_Base', 'M2_Main_Base_Marker', 70, {M2_Main_Base = 100})
    OrderM3MainBase:StartNonZeroBase({{5, 11, 17}, {4, 9, 14}})
    OrderM3MainBase:SetBuild('Defenses', false)
    OrderM3MainBase:SetActive('AirScouting', true)
    OrderM3MainBase:SetActive('LandScouting', true)

    OrderM3MainBase:AddReactiveAI('ExperimentalLand', 'AirRetaliation', 'OrderM3MainBase_ExperimentalLand')
    OrderM3MainBase:AddReactiveAI('ExperimentalAir', 'AirRetaliation', 'OrderM3MainBase_ExperimentalAir')
    OrderM3MainBase:AddReactiveAI('ExperimentalNaval', 'AirRetaliation', 'OrderM3MainBase_ExperimentalNaval')
    OrderM3MainBase:AddReactiveAI('Nuke', 'AirRetaliation', 'OrderM3MainBase_Nuke')
    OrderM3MainBase:AddReactiveAI('HLRA', 'AirRetaliation', 'OrderM3MainBase_HLRA')

    OrderM3MainBaseAirAttacks()
    OrderM3MainBaseLandAttacks()
end

function OrderM3MainBaseAirAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    ----------------------------------------
    -- Order M3 Main Base Op AI - Air Attacks
    ----------------------------------------

    -- sends 5, 8, 20 [bombers]
    quantity = {5, 8, 20}
    opai = OrderM3MainBase:AddOpAI('AirAttacks', 'M3_AirAttack1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Order_AirAttack_West_Chain', 'M3_Order_AirAttack_Mid_Chain', 'M3_Order_AirAttack_East_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Bombers', quantity[Difficulty])

    -- sends 5, 7, 10 [interceptors]
    quantity = {5, 7, 10}
    opai = OrderM3MainBase:AddOpAI('AirAttacks', 'M3_AirAttack2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Order_AirAttack_West_Chain', 'M3_Order_AirAttack_Mid_Chain', 'M3_Order_AirAttack_East_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Interceptors', quantity[Difficulty])

    -- sends 3, 6, 10 [gunships]
    quantity = {3, 6, 10}
    opai = OrderM3MainBase:AddOpAI('AirAttacks', 'M3_AirAttack3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Order_AirAttack_West_Chain', 'M3_Order_AirAttack_Mid_Chain', 'M3_Order_AirAttack_East_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])

    -- sends 4, 10, 20 [gunships, combat fighter] if player has >= 11, 8, 5 T2/T3 AA
    quantity = {4, 10, 20}
    trigger = {11, 8, 5}
    opai = OrderM3MainBase:AddOpAI('AirAttacks', 'M3_AirAttack4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Order_AirAttack_West_Chain', 'M3_Order_AirAttack_Mid_Chain', 'M3_Order_AirAttack_East_Chain'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'Gunships', 'CombatFighters'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], (categories.ANTIAIR * categories.STRUCTURE) - categories.TECH1})

    -- sends 5, 10, 20 [gunships] if player has >= 100, 80, 60 mobile land
    quantity = {5, 10, 20}
    trigger = {100, 80, 60}
    opai = OrderM3MainBase:AddOpAI('AirAttacks', 'M3_AirAttack5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Order_AirAttack_West_Chain', 'M3_Order_AirAttack_Mid_Chain', 'M3_Order_AirAttack_East_Chain'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], (categories.MOBILE * categories.LAND) - categories.CONSTRUCTION})

    -- sends 6, 14, 20 [combat fighter, air superiority] if player has >= 100, 80, 60 mobile air
    quantity = {6, 14, 20}
    trigger = {100, 80, 60}
    opai = OrderM3MainBase:AddOpAI('AirAttacks', 'M3_AirAttack6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Order_AirAttack_West_Chain', 'M3_Order_AirAttack_Mid_Chain', 'M3_Order_AirAttack_East_Chain'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity({'CombatFighters', 'AirSuperiority'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.MOBILE * categories.AIR})

    -- sends 4, 8, 10 [interceptors, air superiority] if player has >= 60, 50, 40 gunships
    quantity = {4, 8, 10}
    trigger = {60, 50, 40}
    opai = OrderM3MainBase:AddOpAI('AirAttacks', 'M3_AirAttack7',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Order_AirAttack_West_Chain', 'M3_Order_AirAttack_Mid_Chain', 'M3_Order_AirAttack_East_Chain'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity({'Interceptors', 'AirSuperiority'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.uaa0203 + categories.uea0203 + categories.ura0203 + categories.uea0305 + categories.xaa0305})

    -- sends 3, 6, 9 [torpedo bombers] if player has >= 13, 9, 5 boats
    quantity = {3, 6, 9}
    trigger = {13, 9, 5}
    opai = OrderM3MainBase:AddOpAI('AirAttacks', 'M3_AirAttack8',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Order_NavalAttack_Chain',
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('TorpedoBombers', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.NAVAL * categories.MOBILE})

    -- sends 4, 8, 12 [combat fighters, gunships] if player has >= 60, 50, 40 T3 units
    quantity = {4, 8, 12}
    trigger = {60, 50, 40}
    opai = OrderM3MainBase:AddOpAI('AirAttacks', 'M3_AirAttack9',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Order_AirAttack_West_Chain', 'M3_Order_AirAttack_Mid_Chain', 'M3_Order_AirAttack_East_Chain'},
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity({'CombatFighters', 'Gunships'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainGreaterThanOrEqualNumCategory', {'default_brain', 'Player', trigger[Difficulty], categories.TECH3})

    -- sends 4, 8, 10 [interceptors, air superiority] if player has >= 5, 4, 3 strat bomber
    quantity = {4, 8, 10}
    trigger = {5, 4, 3}
    opai = OrderM3MainBase:AddOpAI('AirAttacks', 'M3_AirAttack10',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Order_AirAttack_West_Chain', 'M3_Order_AirAttack_Mid_Chain', 'M3_Order_AirAttack_East_Chain'},
            },
            Priority = 140,
        }
    )
    opai:SetChildQuantity({'Interceptors', 'AirSuperiority'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainGreaterThanOrEqualNumCategory', {'default_brain', 'Player', trigger[Difficulty], categories.uaa0304 + categories.uea0304 + categories.ura0304})

    -- sends 6, 12, 18 [bombers, heavy gunships, air superiority] if player has >= 450, 400, 350 units
    quantity = {6, 12, 18}
    trigger = {450, 400, 350}
    opai = OrderM3MainBase:AddOpAI('AirAttacks', 'M3_AirAttack11',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Order_AirAttack_West_Chain', 'M3_Order_AirAttack_Mid_Chain', 'M3_Order_AirAttack_East_Chain'},
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity({'Bombers', 'HeavyGunships', 'AirSuperiority'}, quantity[Difficulty])
    if (Difficulty == 3) then
        opai:SetLockingStyle('None')
    end
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainGreaterThanOrEqualNumCategory', {'default_brain', 'Player', trigger[Difficulty], categories.ALLUNITS - categories.WALL})

    -- Air Defense
    for i = 1, 2 do
        opai = OrderM3MainBase:AddOpAI('AirAttacks', 'M3_AirDefense' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M3_Order_AirDefCombined_Chain',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('Interceptors', 9)
    end

    for i = 3, 4 do
        opai = OrderM3MainBase:AddOpAI('AirAttacks', 'M3_AirDefense' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M3_Order_AirDefCombined_Chain',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('AirSuperiority', 6)
    end
end

function OrderM3MainBaseLandAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    -----------------------------------------
    -- Order M3 Main Base Op AI - Land Attacks
    -----------------------------------------

    -- sends 4, 8, 10 [heavy tanks, heavy bots]
    quantity = {4, 8, 10}
    opai = OrderM3MainBase:AddOpAI('BasicLandAttack', 'M3_LandAttack1',
    {
        MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
        PlatoonData = {
            AttackChain = 'PlayerBaseArea_Attack_Chain',
            LandingChain = 'PlayerBaseArea_Landing_Chain',
            TransportReturn = 'M2_Main_Base_Marker',
        },
        Priority = 100,
    })
    opai:SetChildQuantity({'HeavyTanks', 'HeavyBots'}, quantity[Difficulty])
    opai:SetLockingStyle('None')

    -- sends 4, 6, 10 [light tanks, amphibious tanks, mobile flak]
    quantity = {4, 6, 10}
    opai = OrderM3MainBase:AddOpAI('BasicLandAttack', 'M3_LandAttack2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Order_LandAttack_Chain', 'M3_Order_LandAttack2_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'LightTanks', 'AmphibiousTanks', 'MobileFlak'}, quantity[Difficulty])
    opai:SetLockingStyle('None')

    -- sends engineers
    opai = OrderM3MainBase:AddOpAI('EngineerAttack', 'M3_EngAttack1',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain = 'Order_M2_IslandLand_Chain',
                LandingChain = 'Order_M2_IslandLand_Chain',
                TransportReturn = 'M2_Main_Base_Marker',
                Categories = {'STRUCTURE'},
            },
            Priority = 110,
        }
    )
    opai:SetChildActive('T1Transports', false)

    -- Rear Beach Land Patrols
    for i = 1, Difficulty * 2 do
        opai = OrderM3MainBase:AddOpAI('BasicLandAttack', 'M3_Defense1_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomPatrolThread'},
                PlatoonData = {
                    PatrolChain = 'Order_M2_IslandLand_Chain',
                },
                Priority = 120,
            }
        )
        opai:SetChildQuantity({'HeavyTanks', 'HeavyBots'}, 4)
    end

    -- Beach AA Patrols
    for i = 1, 3 do
        opai = OrderM3MainBase:AddOpAI('BasicLandAttack', 'M3_Defense2_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'Order_M1_Beach' .. i .. '_Chain',
                },
                Priority = 120,
            }
        )
        opai:SetChildQuantity({'MobileFlak', 'HeavyBots'}, 6)
    end
end

function OrderM3NavalBaseAI()

    ---------------------
    -- Order M3 Naval Base
    ---------------------
    ScenarioUtils.CreateArmyGroup('Order', 'M2_Naval_Init_Eng_D' .. Difficulty)
    OrderM3NavalBase:Initialize(ArmyBrains[Order], 'M2_Naval_Base', 'Order_M2_Naval_Base_Marker', 50, {M2_Naval_Base = 100})
    OrderM3NavalBase:StartNonZeroBase({{1, 3, 5}, {1, 3, 5}})
    OrderM3NavalBase:SetBuild('Defenses', false)

    OrderM3NavalBaseNavalAttacks()
end

function OrderM3NavalBaseNavalAttacks()
    local opai = nil
    local trigger = {}

    ------------------------------------------
    -- Order M3 Naval Base Op AI, Naval Attacks
    ------------------------------------------

    -- sends 3 frigate power of [frigates] if player has >= 5, 3, 1 boats
    trigger = {4, 2, 1}
    opai = OrderM3NavalBase:AddNavalAI('M2_NavalAttack1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Order_NavalAttack_Chain',
            },
            EnableTypes = {'Frigate'},
            MaxFrigates = 3,
            MinFrigates = 3,
            Priority = 100,
        }
    )
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainGreaterThanOrEqualNumCategory', {'default_brain', 'Player', trigger[Difficulty], categories.NAVAL * categories.MOBILE})

    -- sends 6 frigate power of [frigates, subs] if player has >= 8, 6, 4 boats
    trigger = {8, 6, 4}
    opai = OrderM3NavalBase:AddNavalAI('M2_NavalAttack2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Order_NavalAttack_Chain',
            },
            EnableTypes = {'Frigate', 'Submarine'},
            MaxFrigates = 6,
            MinFrigates = 6,
            Priority = 110,
        }
    )
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainGreaterThanOrEqualNumCategory', {'default_brain', 'Player', trigger[Difficulty], categories.NAVAL * categories.MOBILE})

    -- sends 9 frigate power of [all but T3] if player has >= 5, 3, 2 T2/T3 boats
    trigger = {5, 3, 2}
    opai = OrderM3NavalBase:AddNavalAI('M2_NavalAttack3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Order_NavalAttack_Chain',
            },
            MaxFrigates = 9,
            MinFrigates = 9,
            Priority = 120,
        }
    )
    opai:SetChildActive('T3', false)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainGreaterThanOrEqualNumCategory', {'default_brain', 'Player', trigger[Difficulty], (categories.NAVAL * categories.MOBILE) - categories.TECH1})

    -- sends 12 frigate power of [all but T3] if player has >= 5 T2/T3 boats
    opai = OrderM3NavalBase:AddNavalAI('M2_NavalAttack4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Order_NavalAttack_Chain',
            },
            MaxFrigates = 12,
            MinFrigates = 12,
            Priority = 130,
        }
    )
    opai:SetChildActive('T3', false)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainGreaterThanOrEqualNumCategory', {'default_brain', 'Player', 5, (categories.NAVAL * categories.MOBILE) - categories.TECH1})

    -- Naval Defense
    for i = 1, 2 do
        opai = OrderM3NavalBase:AddNavalAI('M2_NavalDefense' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
                PlatoonData = {
                    PatrolChains = {'Order_M2_NavalBasePatrol_Chain', 'Order_M2_NavalBasePatrol2_Chain'},
                },
                MaxFrigates = 9,
                MinFrigates = 9,
                Priority = 140,
            }
        )
        opai:SetChildActive('T3', false)
    end
end

function OrderM3ExpansionBaseAI()

    -------------------------
    -- Order M3 Expansion Base
    -------------------------
    -- TODO: make sure this is working
    OrderM3MainBase:AddExpansionBase('OrderM3ExpansionBase', 1)
    OrderM3ExpansionBase:InitializeDifficultyTables(ArmyBrains[Order], 'OrderM3ExpansionBase', 'Order_M2_Expansion_One_Marker', 50,
        {
           M2_EOne_First = 100,
           M2_EOne_Second = 90,
           M2_EOne_Third = 80,
        }
    )
    OrderM3ExpansionBase:StartDifficultyBase({'M2_EOne_First'}, 3)
end
