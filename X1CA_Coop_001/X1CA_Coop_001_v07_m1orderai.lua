#****************************************************************************
#**
#**  File     : /maps/X1CA_Coop_001_v07/X1CA_Coop_001_v07_m1orderai.lua
#**  Author(s): Jessica St. Croix
#**
#**  Summary  : Order army AI for Mission 1 - X1CA_Coop_001_v07
#**
#**  Copyright © 2007 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************
local BaseManager = import('/lua/ai/opai/basemanager.lua')

local SPAIFileName = '/lua/scenarioplatoonai.lua'

# ------
# Locals
# ------
local Order = 3
local Difficulty = ScenarioInfo.Options.Difficulty

# -------------
# Base Managers
# -------------
local OrderM1WestBase = BaseManager.CreateBaseManager()
local OrderM1EastBase = BaseManager.CreateBaseManager()

function OrderM1WestBaseAI()

    # ------------------
    # Order M1 West Base
    # ------------------
    OrderM1WestBase:InitializeDifficultyTables(ArmyBrains[Order], 'M1_West_Road', 'Order_M1_West_Base_Marker', 60, {M1_West_Road = 100,})
    OrderM1WestBase:StartNonZeroBase({{4, 7, 14}, {3, 6, 13}})
    OrderM1WestBase:SetBuild('Defenses', false)
    OrderM1WestBase:SetSupportACUCount(1)

    local opai = OrderM1WestBase:AddReactiveAI('ExperimentalLand', 'AirRetaliation', 'OrderM1WestBase_ExperimentalLand')
    opai:SetChildActive('HeavyGunships', false)
    opai:SetChildActive('StrategicBombers', false)

    opai = OrderM1WestBase:AddReactiveAI('ExperimentalAir', 'AirRetaliation', 'OrderM1WestBase_ExperimentalAir')
    opai:SetChildActive('HeavyGunships', false)
    opai:SetChildActive('StrategicBombers', false)

    opai = OrderM1WestBase:AddReactiveAI('ExperimentalNaval', 'AirRetaliation', 'OrderM1WestBase_ExperimentalNaval')
    opai:SetChildActive('HeavyGunships', false)
    opai:SetChildActive('StrategicBombers', false)

    opai = OrderM1WestBase:AddReactiveAI('Nuke', 'AirRetaliation', 'OrderM1WestBase_Nuke')
    opai:SetChildActive('HeavyGunships', false)
    opai:SetChildActive('StrategicBombers', false)

    opai = OrderM1WestBase:AddReactiveAI('HLRA', 'AirRetaliation', 'OrderM1WestBase_HLRA')
    opai:SetChildActive('HeavyGunships', false)
    opai:SetChildActive('StrategicBombers', false)

    OrderM1WestBaseAirAttacks()
end

function OrderM1WestBaseAirAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    # -------------------------------------
    # Order M1 West Base Op AI, Air Attacks
    # -------------------------------------

    # sends 2, 4, 6 [bombers]
    quantity = {2, 4, 6}
    opai = OrderM1WestBase:AddOpAI('AirAttacks', 'M1_WestAirAttack1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Order_W_AirAttack_1_Chain', 'M1_Order_W_AirAttack_2_Chain', 'M1_Order_W_AirAttack_3_Chain'},
            },
            Priority = 90,
        }
    )
    # using quantity count based on difficulty for number of units sent in per group
    opai:SetChildQuantity('Bombers', quantity[Difficulty])

    # sends 2, 4, 6 [interceptors]
    quantity = {2, 4, 6}
    opai = OrderM1WestBase:AddOpAI('AirAttacks', 'M1_WestAirAttack2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Order_W_AirAttack_1_Chain', 'M1_Order_W_AirAttack_2_Chain', 'M1_Order_W_AirAttack_3_Chain'},
            },
            Priority = 90,
        }
    )
    opai:SetChildQuantity('Interceptors', quantity[Difficulty])

    # sends 6, 8, 10 [bombers] if player has >= 12, 8, 5 AA towers
    quantity = {6, 8, 10}
    trigger = {12, 8, 5}
    opai = OrderM1WestBase:AddOpAI('AirAttacks', 'M1_WestAirAttack3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Order_W_AirAttack_1_Chain', 'M1_Order_W_AirAttack_2_Chain', 'M1_Order_W_AirAttack_3_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Bombers', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.ANTIAIR * categories.STRUCTURE})

    # sends 4, 8, 12 [gunships, combat fighter] if player has >= 8, 6, 3 T2/T3 AA towers
    # quantity is split between the children, 2 in this case, half gunships/half combat fighters
    quantity = {4, 8, 12}
    trigger = {8, 6, 3}
    opai = OrderM1WestBase:AddOpAI('AirAttacks', 'M1_WestAirAttack4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Order_W_AirAttack_1_Chain', 'M1_Order_W_AirAttack_2_Chain', 'M1_Order_W_AirAttack_3_Chain'},
            },
            Priority = 100,
        }
    )
    # more than one type of unit in the group, so the first parameter has to be a table
    opai:SetChildQuantity({'Gunships', 'CombatFighters'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], (categories.ANTIAIR * categories.STRUCTURE) - categories.TECH1})

    # sends 6, 9, 12 [interceptors] if player has >= 15, 10, 10 mobile air
    quantity = {6, 9, 12}
    trigger = {15, 10, 10}
    opai = OrderM1WestBase:AddOpAI('AirAttacks', 'M1_WestAirAttack5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Order_W_AirAttack_1_Chain', 'M1_Order_W_AirAttack_2_Chain', 'M1_Order_W_AirAttack_3_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Interceptors', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.MOBILE * categories.AIR})

    # sends 6, 6, 8 [torpedo bombers] if player has >= 10, 7, 3 boats - t1 subs
    quantity = {6, 6, 8}
    trigger = {10, 7, 3}
    opai = OrderM1WestBase:AddOpAI('AirAttacks', 'M1_WestAirAttack6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Order_Torp_1_Chain', 'M1_Order_Torp_2_Chain'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('TorpedoBombers', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.NAVAL * categories.MOBILE - categories.T1SUBMARINE})

    # sends 3, 6, 9 [bombers] if player has >= 50, 40, 30 structures
    quantity = {3, 6, 9}
    trigger = {50, 40, 30}
    opai = OrderM1WestBase:AddOpAI('AirAttacks', 'M1_WestAirAttack7',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Order_W_AirAttack_1_Chain', 'M1_Order_W_AirAttack_2_Chain', 'M1_Order_W_AirAttack_3_Chain'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Bombers', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.STRUCTURE - categories.WALL})

    # sends 6, 8, 12 [gunships] if player has >= 40, 34, 20 T2/T3 structures
    quantity = {6, 8, 12}
    trigger = {40, 34, 20}
    opai = OrderM1WestBase:AddOpAI('AirAttacks', 'M1_WestAirAttack8',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Order_W_AirAttack_1_Chain', 'M1_Order_W_AirAttack_2_Chain', 'M1_Order_W_AirAttack_3_Chain'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.STRUCTURE - categories.TECH1})

    # sends 6, 9, 12 [gunships] if player has >= 75, 60, 40 mobile land units
    quantity = {6, 9, 12}
    trigger = {75, 60, 40}
    opai = OrderM1WestBase:AddOpAI('AirAttacks', 'M1_WestAirAttack9',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Order_W_AirAttack_1_Chain', 'M1_Order_W_AirAttack_2_Chain', 'M1_Order_W_AirAttack_3_Chain'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], (categories.MOBILE * categories.LAND) - categories.CONSTRUCTION})

    # sends 9, 12, 18 [combat fighter] if player has >= 75, 60, 40 mobile air units
    quantity = {9, 12, 18}
    trigger = {75, 60, 40}
    opai = OrderM1WestBase:AddOpAI('AirAttacks', 'M1_WestAirAttack10',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Order_W_AirAttack_1_Chain', 'M1_Order_W_AirAttack_2_Chain', 'M1_Order_W_AirAttack_3_Chain'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('CombatFighters', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.MOBILE * categories.AIR})

    # sends 8, 10, 16 [combat fighter, gunships] if player has >= 40, 30, 20 T2/T3 gunships
    quantity = {8, 10, 16}
    trigger = {40, 30, 20}
    opai = OrderM1WestBase:AddOpAI('AirAttacks', 'M1_WestAirAttack11',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Order_W_AirAttack_1_Chain', 'M1_Order_W_AirAttack_2_Chain', 'M1_Order_W_AirAttack_3_Chain'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity({'CombatFighters', 'Gunships'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty],
         categories.uaa0203 + categories.xaa0305 + categories.uea0203 + categories.uea0305 + categories.ura0203 + categories.xra0305})

    # sends 6, 12, 18 [gunships] if player has >= 50, 40, 30 T3 units
    quantity = {6, 12, 18}
    trigger = {50, 40, 30}
    opai = OrderM1WestBase:AddOpAI('AirAttacks', 'M1_WestAirAttack12',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Order_W_AirAttack_1_Chain', 'M1_Order_W_AirAttack_2_Chain', 'M1_Order_W_AirAttack_3_Chain'},
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.TECH3})

    # sends 6, 12, 12 [combat fighter] if player has >= 1 strat bomber
    quantity = {6, 12, 12}
    opai = OrderM1WestBase:AddOpAI('AirAttacks', 'M1_WestAirAttack13',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Order_W_AirAttack_1_Chain', 'M1_Order_W_AirAttack_2_Chain', 'M1_Order_W_AirAttack_3_Chain'},
            },
            Priority = 140,
        }
    )
    opai:SetChildQuantity('CombatFighters', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', 1, categories.uaa0304 + categories.uea0304 + categories.ura0304})

    # sends 6, 9, 12 [torpedo bombers] if player has >= 1 T3 boat
    quantity = {6, 9, 12}
    opai = OrderM1WestBase:AddOpAI('AirAttacks', 'M1_WestAirAttack14',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Order_Torp_1_Chain', 'M1_Order_Torp_2_Chain'},
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity('TorpedoBombers', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', 1, categories.MOBILE * categories.NAVAL * categories.TECH3})

    # sends 6, 12, 18 [gunships] if player has >= 300, 250, 200 units
    quantity = {6, 12, 18}
    trigger = {300, 250, 200}
    opai = OrderM1WestBase:AddOpAI('AirAttacks', 'M1_WestAirAttack15',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Order_W_AirAttack_1_Chain', 'M1_Order_W_AirAttack_2_Chain', 'M1_Order_W_AirAttack_3_Chain'},
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    # unlocked on hard difficulty, easy and medium will build once then rebuild once the platoon is dead if the conditions are still met
    if(Difficulty == 3) then
        opai:SetLockingStyle('None')
    end
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.ALLUNITS - categories.WALL})
end

function OrderM1EastBaseAI()
    # ------------------
    # Order M1 East Base
    # ------------------
    OrderM1EastBase:InitializeDifficultyTables(ArmyBrains[Order], 'M1_East_Road', 'Order_M1_East_Base_Marker', 60, {M1_East_Road = 100,})
    OrderM1EastBase:StartNonZeroBase({{3, 5, 12}, {2, 4, 11}})
    OrderM1EastBase:SetActive('LandScouting', true)
    OrderM1EastBase:SetBuild('Defenses', false)

    local opai = OrderM1EastBase:AddReactiveAI('ExperimentalLand', 'AirRetaliation', 'OrderM1EastBase_ExperimentalLand')
    opai:SetChildActive('HeavyGunships', false)
    opai:SetChildActive('StrategicBombers', false)

    opai = OrderM1EastBase:AddReactiveAI('ExperimentalAir', 'AirRetaliation', 'OrderM1EastBase_ExperimentalAir')
    opai:SetChildActive('HeavyGunships', false)
    opai:SetChildActive('StrategicBombers', false)

    opai = OrderM1EastBase:AddReactiveAI('ExperimentalNaval', 'AirRetaliation', 'OrderM1EastBase_ExperimentalNaval')
    opai:SetChildActive('HeavyGunships', false)
    opai:SetChildActive('StrategicBombers', false)

    opai = OrderM1EastBase:AddReactiveAI('Nuke', 'AirRetaliation', 'OrderM1EastBase_Nuke')
    opai:SetChildActive('HeavyGunships', false)
    opai:SetChildActive('StrategicBombers', false)

    opai = OrderM1EastBase:AddReactiveAI('HLRA', 'AirRetaliation', 'OrderM1EastBase_HLRA')
    opai:SetChildActive('HeavyGunships', false)
    opai:SetChildActive('StrategicBombers', false)

    OrderM1EastBaseAirAttacks()
    OrderM1EastBaseLandAttacks()
end

function OrderM1EastBaseAirAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    # -------------------------------------
    # Order M1 East Base Op AI, Air Attacks
    # -------------------------------------

    # sends 2, 4, 6 [bombers]
    quantity = {2, 4, 6}
    opai = OrderM1EastBase:AddOpAI('AirAttacks', 'M1_EastAirAttack1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Order_E_AirAttack_1_Chain', 'M1_Order_E_AirAttack_2_Chain'},
            },
            Priority = 90,
        }
    )
    # using quantity count based on difficulty for number of units sent in per group
    opai:SetChildQuantity('Bombers', quantity[Difficulty])

    # sends 2, 4, 6 [interceptors]
    quantity = {2, 4, 6}
    opai = OrderM1EastBase:AddOpAI('AirAttacks', 'M1_EastAirAttack2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Order_E_AirAttack_1_Chain', 'M1_Order_E_AirAttack_2_Chain'},
            },
            Priority = 90,
        }
    )
    opai:SetChildQuantity('Interceptors', quantity[Difficulty])

    # sends 3, 4, 5 [bombers] if player has >= 12, 8, 5 AA towers
    quantity = {3, 4, 5}
    trigger = {12, 8, 5}
    opai = OrderM1EastBase:AddOpAI('AirAttacks', 'M1_EastAirAttack3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Order_E_AirAttack_1_Chain', 'M1_Order_E_AirAttack_2_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Bombers', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.ANTIAIR * categories.STRUCTURE})

    # sends 4, 8, 12 [gunships, combat fighter] if player has >= 8, 6, 3 T2/T3 AA towers
    # quantity is split between the children, 2 in this case, half gunships/half combat fighters
    quantity = {4, 8, 12}
    trigger = {8, 6, 3}
    opai = OrderM1EastBase:AddOpAI('AirAttacks', 'M1_EastAirAttack4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Order_E_AirAttack_1_Chain', 'M1_Order_E_AirAttack_2_Chain'},
            },
            Priority = 100,
        }
    )
    # more than one type of unit in the group, so the first parameter has to be a table
    opai:SetChildQuantity({'Gunships', 'CombatFighters'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], (categories.ANTIAIR * categories.STRUCTURE) - categories.TECH1})

    # sends 3, 6, 9 [interceptors] if player has >= 15, 10, 10 mobile air
    quantity = {3, 6, 9}
    trigger = {15, 10, 10}
    opai = OrderM1EastBase:AddOpAI('AirAttacks', 'M1_EastAirAttack5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Order_E_AirAttack_1_Chain', 'M1_Order_E_AirAttack_2_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Interceptors', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.MOBILE * categories.AIR})

    # sends 3, 3, 6 [torpedo bombers] if player has >= 10, 7, 3 boats - t1 subs
    quantity = {3, 3, 6}
    trigger = {10, 7, 3}
    opai = OrderM1EastBase:AddOpAI('AirAttacks', 'M1_EastAirAttack6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Order_Torp_1_Chain', 'M1_Order_Torp_2_Chain'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('TorpedoBombers', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.NAVAL * categories.MOBILE - categories.T1SUBMARINE})

    # sends 3, 6, 9 [bombers] if player has >= 50, 40, 30 structures
    quantity = {3, 6, 9}
    trigger = {50, 40, 30}
    opai = OrderM1EastBase:AddOpAI('AirAttacks', 'M1_EastAirAttack7',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Order_E_AirAttack_1_Chain', 'M1_Order_E_AirAttack_2_Chain'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Bombers', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.STRUCTURE - categories.WALL})

    # sends 3, 6, 12 [gunships] if player has >= 40, 33, 20 T2/T3 structures
    quantity = {3, 6, 12}
    trigger = {40, 33, 20}
    opai = OrderM1EastBase:AddOpAI('AirAttacks', 'M1_EastAirAttack8',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Order_E_AirAttack_1_Chain', 'M1_Order_E_AirAttack_2_Chain'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.STRUCTURE - categories.TECH1})

    # sends 3, 6, 12 [gunships] if player has >= 75, 60, 40 mobile land units
    quantity = {3, 6, 12}
    trigger = {75, 60, 40}
    opai = OrderM1EastBase:AddOpAI('AirAttacks', 'M1_EastAirAttack9',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Order_E_AirAttack_1_Chain', 'M1_Order_E_AirAttack_2_Chain'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], (categories.MOBILE * categories.LAND) - categories.CONSTRUCTION})

    # sends 6, 9, 12 [combat fighter] if player has >= 75, 60, 40 mobile air units
    quantity = {6, 9, 12}
    trigger = {75, 60, 40}
    opai = OrderM1EastBase:AddOpAI('AirAttacks', 'M1_EastAirAttack10',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Order_E_AirAttack_1_Chain', 'M1_Order_E_AirAttack_2_Chain'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('CombatFighters', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.MOBILE * categories.AIR})

    # sends 6, 8, 12 [combat fighter, gunships] if player has >= 40, 30, 20 T2/T3 gunships
    quantity = {6, 8, 12}
    trigger = {40, 30, 20}
    opai = OrderM1EastBase:AddOpAI('AirAttacks', 'M1_EastAirAttack11',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Order_E_AirAttack_1_Chain', 'M1_Order_E_AirAttack_2_Chain'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity({'CombatFighters', 'Gunships'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty],
         categories.uaa0203 + categories.xaa0305 + categories.uea0203 + categories.uea0305 + categories.ura0203 + categories.xra0305})

    # sends 6, 9, 12 [gunships] if player has >= 50, 40, 30 T3 units
    quantity = {6, 9, 12}
    trigger = {50, 40, 30}
    opai = OrderM1EastBase:AddOpAI('AirAttacks', 'M1_EastAirAttack12',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Order_E_AirAttack_1_Chain', 'M1_Order_E_AirAttack_2_Chain'},
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.TECH3})

    # sends 3, 6, 9 [combat fighter] if player has >= 1 strat bomber
    quantity = {3, 6, 9}
    opai = OrderM1EastBase:AddOpAI('AirAttacks', 'M1_EastAirAttack13',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Order_E_AirAttack_1_Chain', 'M1_Order_E_AirAttack_2_Chain'},
            },
            Priority = 140,
        }
    )
    opai:SetChildQuantity('CombatFighters', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', 1, categories.uaa0304 + categories.uea0304 + categories.ura0304})

    # sends 3, 6, 9 [torpedo bombers] if player has >= 1 T3 boat
    quantity = {3, 6, 9}
    opai = OrderM1EastBase:AddOpAI('AirAttacks', 'M1_EastAirAttack14',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Order_Torp_1_Chain', 'M1_Order_Torp_2_Chain'},
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity('TorpedoBombers', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', 1, categories.MOBILE * categories.NAVAL * categories.TECH3})

    # sends 6, 12, 18 [gunships] if player has >= 300, 250, 200 units
    quantity = {6, 12, 18}
    trigger = {300, 250, 200}
    opai = OrderM1EastBase:AddOpAI('AirAttacks', 'M1_EastAirAttack15',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Order_E_AirAttack_1_Chain', 'M1_Order_E_AirAttack_2_Chain'},
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    # unlocked on hard difficulty, easy and medium will build once then rebuild once the platoon is dead if the conditions are still met
    if(Difficulty == 3) then
        opai:SetLockingStyle('None')
    end
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.ALLUNITS - categories.WALL})
end

function OrderM1EastBaseLandAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    # --------------------------------------
    # Order M1 East Base Op AI, Land Attacks
    # --------------------------------------

    # sends 4, 6, 8 [light tanks]
    quantity = {4, 6, 8}
    opai = OrderM1EastBase:AddOpAI('BasicLandAttack', 'M1_LandAttack1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Order_M1_LandAttack_Chain', 'Order_M1_LandAttack2_Chain', 'Order_M1_LandAttack3_Chain', 'M1_Order_E_AmphAttack_1_Chain'},
            },
            Priority = 90,
        }
    )
    opai:SetChildQuantity('LightTanks', quantity[Difficulty])

    # sends 6, 7, 10 [light tanks] if player has >= 5, 3, 1 DF structure
    quantity = {6, 7, 10}
    trigger = {5, 3, 1}
    opai = OrderM1EastBase:AddOpAI('BasicLandAttack', 'M1_LandAttack2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Order_M1_LandAttack_Chain', 'Order_M1_LandAttack2_Chain', 'Order_M1_LandAttack3_Chain', 'M1_Order_E_AmphAttack_1_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('LightTanks', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.DIRECTFIRE * categories.STRUCTURE})

    # sends 6, 7, 10 [light tanks] if player has >= 10, 6, 3 DF structure
    quantity = {6, 7, 10}
    trigger = {10, 6, 3}
    opai = OrderM1EastBase:AddOpAI('BasicLandAttack', 'M1_LandAttack3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Order_M1_LandAttack_Chain', 'Order_M1_LandAttack2_Chain', 'Order_M1_LandAttack3_Chain', 'M1_Order_E_AmphAttack_1_Chain'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('LightTanks', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.DIRECTFIRE * categories.STRUCTURE})

    # Hard only
    if(Difficulty == 3) then
        # sends [light tanks] if player has >= 1 naval factories, hard only
        for i = 1, 2 do
            opai = OrderM1EastBase:AddOpAI('BasicLandAttack', 'M1_LandAttack4_' .. i,
                {
                    MasterPlatoonFunction = {SPAIFileName, 'RandomPatrolThread'},
                    PlatoonData = {
                        PatrolChain = 'M1_Order_Torp_1_Chain',
                    },
                    Priority = 110,
                }
            )
            opai:SetChildQuantity('LightTanks', 4)
            opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
                {'default_brain', 'Player', 1, categories.FACTORY * categories.NAVAL})
        end

        # sends [light tanks] if player has >= 1 naval factories, hard only
        for i = 1, 2 do
            opai = OrderM1EastBase:AddOpAI('BasicLandAttack', 'M1_LandAttack5_' .. i,
                {
                    MasterPlatoonFunction = {SPAIFileName, 'RandomPatrolThread'},
                    PlatoonData = {
                        PatrolChain = 'M1_Order_Torp_2_Chain',
                    },
                    Priority = 110,
                }
            )
            opai:SetChildQuantity('LightTanks', 4)
            opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
                {'default_brain', 'Player', 1, categories.FACTORY * categories.NAVAL})
        end
    end

    # sends 4, 6, 8 [assault tanks, light tanks] if player has >= 5, 4, 1 T2/T3 DF structure
    quantity = {4, 6, 8}
    trigger = {5, 4, 1}
    opai = OrderM1EastBase:AddOpAI('BasicLandAttack', 'M1_LandAttack6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Order_M1_LandAttack_Chain', 'Order_M1_LandAttack2_Chain', 'Order_M1_LandAttack3_Chain', 'M1_Order_E_AmphAttack_1_Chain'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity({'AmphibiousTanks', 'LightTanks'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], (categories.DIRECTFIRE * categories.STRUCTURE) - categories.TECH1})

    # sends 6, 12, 18 [assault tanks, mobile flak] if player has >= 75, 60, 40 mobile air
    quantity = {6, 12, 16}
    trigger = {75, 60, 40}
    opai = OrderM1EastBase:AddOpAI('BasicLandAttack', 'M1_LandAttack7',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Order_M1_LandAttack_Chain', 'Order_M1_LandAttack2_Chain', 'Order_M1_LandAttack3_Chain', 'M1_Order_E_AmphAttack_1_Chain'},
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity({'AmphibiousTanks', 'MobileFlak'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.MOBILE * categories.AIR})

    # sends 4 [mobile flak] if player has >= 60, 50, 30 mobile air
    for i = 1, 2 do
        trigger = {60, 50, 30}
        opai = OrderM1EastBase:AddOpAI('BasicLandAttack', 'M1_LandAttack8_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomPatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M1_Order_Torp_' .. i .. '_Chain',
                },
                Priority = 130,
            }
        )
        opai:SetChildQuantity('MobileFlak', 4)
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
            {'default_brain', 'Player', trigger[Difficulty], categories.MOBILE * categories.AIR})
    end

    # sends 4 [mobile flak] if player has >= 75, 60, 40 mobile air
    for i = 1, 2 do
        trigger = {75, 60, 40}
        opai = OrderM1EastBase:AddOpAI('BasicLandAttack', 'M1_LandAttack9_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomPatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M1_Order_Torp_' .. i .. '_Chain',
                },
                Priority = 130,
            }
        )
        opai:SetChildQuantity('MobileFlak', 4)
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
            {'default_brain', 'Player', trigger[Difficulty], categories.MOBILE * categories.AIR})
    end

    # Hard only
    if(Difficulty == 3) then
        # sends 4 [assault tanks] if player has >= 1 boats
        for i = 1, 2 do
            opai = OrderM1EastBase:AddOpAI('BasicLandAttack', 'M1_LandAttack10_' .. i,
                {
                    MasterPlatoonFunction = {SPAIFileName, 'RandomPatrolThread'},
                    PlatoonData = {
                        PatrolChain = 'M1_Order_Torp_1_Chain',
                    },
                    Priority = 130,
                }
            )
            opai:SetChildQuantity('AmphibiousTanks', 4)
            opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
                {'default_brain', 'Player', 1, categories.MOBILE * categories.NAVAL})
        end

        # sends 4 [assault tanks] if player has >= 5 boats
        for i = 1, 2 do
            opai = OrderM1EastBase:AddOpAI('BasicLandAttack', 'M1_LandAttack11_' .. i,
                {
                    MasterPlatoonFunction = {SPAIFileName, 'RandomPatrolThread'},
                    PlatoonData = {
                        PatrolChain = 'M1_Order_Torp_2_Chain',
                    },
                    Priority = 130,
                }
            )
            opai:SetChildQuantity('AmphibiousTanks', 4)
            opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
                {'default_brain', 'Player', 5, categories.MOBILE * categories.NAVAL})
        end
    end

    # Land Defense
    for i = 1, Difficulty do
        opai = OrderM1EastBase:AddOpAI('BasicLandAttack', 'M1_LandDefense1_' .. i,
            {
                PlatoonData = {
                    PatrolChain = 'East_Beach_Patrol_Chain',
                },
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                Priority = 140,
            }
        )
        opai:SetChildQuantity('HeavyTanks', 4)
    end

    for i = 1, Difficulty do
        opai = OrderM1EastBase:AddOpAI('BasicLandAttack', 'M1_LandDefense2_' .. i,
            {
                PlatoonData = {
                    PatrolChain = 'West_Beach_Patrol_Chain',
                },
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                Priority = 140,
            }
        )
        opai:SetChildQuantity('HeavyTanks', 4)
    end
end

function BuildAirScouts()
    if(OrderM1WestBase) then
        OrderM1WestBase:SetActive('AirScouting', true)
    end

    if(OrderM1EastBase) then
        OrderM1EastBase:SetActive('AirScouting', true)
    end
end