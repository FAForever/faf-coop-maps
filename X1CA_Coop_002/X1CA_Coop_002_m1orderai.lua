-- ****************************************************************************
-- **
-- **  File     : /maps/X1CA_Coop_002/X1CA_Coop_002_m1orderai.lua
-- **  Author(s): Jessica St. Croix
-- **
-- **  Summary  : Order army AI for Mission 1 - X1CA_Coop_002
-- **
-- **  Copyright © 2007 Gas Powered Games, Inc.  All rights reserved.
-- ****************************************************************************
local BaseManager = import('/lua/ai/opai/basemanager.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')

local SPAIFileName = '/lua/scenarioplatoonai.lua'

--------
-- Locals
--------
local Player = 1
local Order = 2
local Loyalist = 4
local Difficulty = ScenarioInfo.Options.Difficulty

---------------
-- Base Managers
---------------
local OrderM1MainBase = BaseManager.CreateBaseManager()
local OrderM1ResourceBase = BaseManager.CreateBaseManager()

function OrderM1MainBaseAI()

    --------------------
    -- Order M1 Main Base
    --------------------
    ScenarioUtils.CreateArmyGroup('Order', 'M1_Order_MainBase_InitEng_D' .. Difficulty)
    OrderM1MainBase:InitializeDifficultyTables(ArmyBrains[Order], 'M1_Order_MainBase', 'Order_M1_Order_MainBase_Marker', 70, {M1_Order_MainBase = 100})
    OrderM1MainBase:StartNonZeroBase({{3, 7, 15}, {3, 6, 14}})
    OrderM1MainBase:SetActive('AirScouting', true)
    OrderM1MainBase:SetActive('LandScouting', true)
    OrderM1MainBase:SetBuild('Defenses', false)
    OrderM1MainBase:SetBuild('Shields', true)

    local opai = OrderM1MainBase:AddReactiveAI('ExperimentalLand', 'AirRetaliation', 'OrderM1WestBase_ExperimentalLand')
    opai:SetChildActive('HeavyGunships', false)
    opai:SetChildActive('StrategicBombers', false)
    opai:RemoveChildren({'HeavyGunships', 'StrategicBombers'})

    opai = OrderM1MainBase:AddReactiveAI('ExperimentalAir', 'AirRetaliation', 'OrderM1WestBase_ExperimentalAir')
    opai:SetChildActive('HeavyGunships', false)
    opai:SetChildActive('StrategicBombers', false)
    opai:RemoveChildren({'HeavyGunships', 'StrategicBombers'})

    opai = OrderM1MainBase:AddReactiveAI('ExperimentalNaval', 'AirRetaliation', 'OrderM1WestBase_ExperimentalNaval')
    opai:SetChildActive('HeavyGunships', false)
    opai:SetChildActive('StrategicBombers', false)
    opai:RemoveChildren({'HeavyGunships', 'StrategicBombers'})

    opai = OrderM1MainBase:AddReactiveAI('Nuke', 'AirRetaliation', 'OrderM1WestBase_Nuke')
    opai:SetChildActive('HeavyGunships', false)
    opai:SetChildActive('StrategicBombers', false)
    opai:RemoveChildren({'HeavyGunships', 'StrategicBombers'})

    opai = OrderM1MainBase:AddReactiveAI('HLRA', 'AirRetaliation', 'OrderM1WestBase_HLRA')
    opai:SetChildActive('HeavyGunships', false)
    opai:SetChildActive('StrategicBombers', false)
    opai:RemoveChildren({'HeavyGunships', 'StrategicBombers'})

    OrderM1MainBaseAirAttacks()
    OrderM1MainBaseLandAttacks()
end

function OrderM1MainBaseAirAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    -------------------------------------
    -- Order Main Base Op AI, Air Atttacks
    -------------------------------------

    -- sends 3, 4, 6 [bombers] if player has >= 12, 8, 5 AA
    quantity = {3, 4, 6}
    trigger = {12, 8, 5}
    opai = OrderM1MainBase:AddOpAI('AirAttacks', 'M1_AirAttack1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Order_M1_Attack_Chain', 'Order_M1_Attack2_Chain', 'Order_M1_Attack3_Chain', 'Order_M1_Attack4_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Bombers', quantity[Difficulty])
    if(Difficulty < 3) then
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.ANTIAIR, '>='})
    else
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers', 'Loyalist'}, trigger[Difficulty], categories.ANTIAIR, '>='})
    end

    -- sends 4, 4, 6 [gunships, combat fighter] if player has >= 7, 5, 3 T2/T3 AA
    quantity = {4, 4, 6}
    trigger = {7, 5, 3}
    opai = OrderM1MainBase:AddOpAI('AirAttacks', 'M1_AirAttack2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Order_M1_Attack_Chain', 'Order_M1_Attack2_Chain', 'Order_M1_Attack3_Chain', 'Order_M1_Attack4_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'Gunships', 'CombatFighters'}, quantity[Difficulty])
    if(Difficulty < 3) then
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.ANTIAIR - categories.TECH1, '>='})
    else
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers', 'Loyalist'}, trigger[Difficulty], categories.ANTIAIR - categories.TECH1, '>='})
    end

    -- sends 3, 4, 6 [interceptors] if player has >= 15, 10, 10 mobile air
    quantity = {3, 4, 6}
    trigger = {15, 10, 10}
    opai = OrderM1MainBase:AddOpAI('AirAttacks', 'M1_AirAttack3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Order_M1_Attack_Chain', 'Order_M1_Attack2_Chain', 'Order_M1_Attack3_Chain', 'Order_M1_Attack4_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Interceptors', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.MOBILE * categories.AIR, '>='})

    -- sends 3, 4, 6 [bombers] if player has >= 50, 40, 30 structures
    quantity = {3, 4, 6}
    trigger = {50, 40, 30}
    opai = OrderM1MainBase:AddOpAI('AirAttacks', 'M1_AirAttack4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Order_M1_Attack_Chain', 'Order_M1_Attack2_Chain', 'Order_M1_Attack3_Chain', 'Order_M1_Attack4_Chain'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Bombers', quantity[Difficulty])
    if(Difficulty < 3) then
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.STRUCTURE - categories.WALL, '>='})
    else
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers', 'Loyalist'}, trigger[Difficulty], categories.STRUCTURE - categories.WALL, '>='})
    end

    -- sends 3, 4, 6 [gunships] if player has >= 30, 20, 15 T2/T3 structures
    quantity = {3, 4, 6}
    trigger = {30, 20, 15}
    opai = OrderM1MainBase:AddOpAI('AirAttacks', 'M1_AirAttack5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Order_M1_Attack_Chain', 'Order_M1_Attack2_Chain', 'Order_M1_Attack3_Chain', 'Order_M1_Attack4_Chain'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    if(Difficulty < 3) then
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.STRUCTURE - categories.TECH1, '>='})
    else
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers', 'Loyalist'}, trigger[Difficulty], categories.STRUCTURE - categories.TECH1, '>='})
    end

    -- sends 3, 4, 6 [gunships] if player has >= 75, 60, 40 mobile land units
    quantity = {3, 4, 6}
    trigger = {75, 60, 40}
    opai = OrderM1MainBase:AddOpAI('AirAttacks', 'M1_AirAttack6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Order_M1_Attack_Chain', 'Order_M1_Attack2_Chain', 'Order_M1_Attack3_Chain', 'Order_M1_Attack4_Chain'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    if(Difficulty < 3) then
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers'}, trigger[Difficulty], (categories.MOBILE * categories.LAND) - categories.CONSTRUCTION, '>='})
    else
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers', 'Loyalist'}, trigger[Difficulty], (categories.MOBILE * categories.LAND) - categories.CONSTRUCTION, '>='})
    end

    -- sends 4, 6, 9 [combat fighter] if player has >= 75, 60, 40 mobile air units
    quantity = {4, 6, 9}
    trigger = {75, 60, 40}
    opai = OrderM1MainBase:AddOpAI('AirAttacks', 'M1_AirAttack7',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Order_M1_Attack_Chain', 'Order_M1_Attack2_Chain', 'Order_M1_Attack3_Chain', 'Order_M1_Attack4_Chain'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('CombatFighters', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.MOBILE * categories.AIR, '>='})

    -- sends 4, 6, 10 [combat fighter, gunships] if player has >= 40, 30, 20 gunships
    quantity = {4, 6, 10}
    trigger = {40, 30, 20}
    opai = OrderM1MainBase:AddOpAI('AirAttacks', 'M1_AirAttack8',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Order_M1_Attack_Chain', 'Order_M1_Attack2_Chain', 'Order_M1_Attack3_Chain', 'Order_M1_Attack4_Chain'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity({'CombatFighters', 'Gunships'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.uaa0203 + categories.uea0203 + categories.ura0203, '>='})

    -- sends 4, 6, 9 [gunships] if player has >= 50, 40, 30 T3 units
    quantity = {4, 6, 9}
    trigger = {50, 40, 30}
    opai = OrderM1MainBase:AddOpAI('AirAttacks', 'M1_AirAttack9',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Order_M1_Attack_Chain', 'Order_M1_Attack2_Chain', 'Order_M1_Attack3_Chain', 'Order_M1_Attack4_Chain'},
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.TECH3, '>='})

    -- sends 4, 6, 9 [combat fighter] if player has >= 1 strat bomber
    quantity = {4, 6, 9}
    opai = OrderM1MainBase:AddOpAI('AirAttacks', 'M1_AirAttack10',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Order_M1_Attack_Chain', 'Order_M1_Attack2_Chain', 'Order_M1_Attack3_Chain', 'Order_M1_Attack4_Chain'},
            },
            Priority = 140,
        }
    )
    opai:SetChildQuantity('CombatFighters', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, 1, categories.uaa0304 + categories.uea0304 + categories.ura0304, '>='})

    -- sends 4, 6, 9 [gunships] if player has >= 300, 250, 200 units
    quantity = {4, 6, 10}
    trigger = {300, 250, 200}
    opai = OrderM1MainBase:AddOpAI('AirAttacks', 'M1_AirAttack11',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Order_M1_Attack_Chain', 'Order_M1_Attack2_Chain', 'Order_M1_Attack3_Chain', 'Order_M1_Attack4_Chain'},
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    if(Difficulty < 3) then
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL, '>='})
    else
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers', 'Loyalist'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL, '>='})
    end

    -- Air Defense
    for i = 1, 4 do
        opai = OrderM1MainBase:AddOpAI('AirAttacks', 'M1_AirDefense' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M1_Order_BasePatrol_Air_Chain',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('Interceptors', 2)
    end
end

function OrderM1MainBaseLandAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    -------------------------------------
    -- Order Main Base Op AI, Land Attacks
    -------------------------------------

    -- sends 4, 5, 10 [light bots]
    quantity = {4, 5, 10}
    opai = OrderM1MainBase:AddOpAI('BasicLandAttack', 'M1_LandAttack1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Order_M1_Attack_Chain', 'Order_M1_Attack2_Chain', 'Order_M1_Attack3_Chain', 'Order_M1_Attack4_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('LightBots', quantity[Difficulty])

    -- sends 4, 5, 10 [light tanks] if player has >= 10, 8, 0 DF/IF
    quantity = {4, 5, 10}
    trigger = {10, 8, 0}
    opai = OrderM1MainBase:AddOpAI('BasicLandAttack', 'M1_LandAttack2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Order_M1_Attack_Chain', 'Order_M1_Attack2_Chain', 'Order_M1_Attack3_Chain', 'Order_M1_Attack4_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('LightTanks', quantity[Difficulty])
    if(Difficulty < 3) then
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.DIRECTFIRE + categories.INDIRECTFIRE, '>='})
    end

    -- sends 4, 5, 10 [light artillery] if player has >= 40, 30, 20 units
    quantity = {4, 5, 10}
    trigger = {40, 30, 20}
    opai = OrderM1MainBase:AddOpAI('BasicLandAttack', 'M1_LandAttack3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Order_M1_Attack_Chain', 'Order_M1_Attack2_Chain', 'Order_M1_Attack3_Chain', 'Order_M1_Attack4_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('LightArtillery', quantity[Difficulty])
    if(Difficulty < 3) then
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL, '>='})
    else
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers', 'Loyalist'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL, '>='})
    end

    -- sends 4, 5, 10 [mobile aa] if player has >= 10, 8, 6 planes
    quantity = {4, 5, 10}
    trigger = {10, 8, 6}
    opai = OrderM1MainBase:AddOpAI('BasicLandAttack', 'M1_LandAttack4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Order_M1_Attack_Chain', 'Order_M1_Attack2_Chain', 'Order_M1_Attack3_Chain', 'Order_M1_Attack4_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('MobileAntiAir', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.MOBILE * categories.AIR, '>='})

    -- sends 4, 4, 10 [light tanks, heavy tanks] if player has >= 8, 6, 4 T2/T3 DF/IF
    quantity = {4, 4, 10}
    trigger = {8, 6, 4}
    opai = OrderM1MainBase:AddOpAI('BasicLandAttack', 'M1_LandAttack5',
        {
            MasterPlatoonFunction = {'/lua/scenarioplatoonai.lua', 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Order_M1_Attack_Chain', 'Order_M1_Attack2_Chain', 'Order_M1_Attack3_Chain', 'Order_M1_Attack4_Chain'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'LightTanks', 'HeavyTanks'}, quantity[Difficulty])
    if(Difficulty < 3) then
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers'}, trigger[Difficulty], (categories.DIRECTFIRE + categories.INDIRECTFIRE) - categories.TECH1, '>='})
    else
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers', 'Loyalist'}, trigger[Difficulty], (categories.DIRECTFIRE + categories.INDIRECTFIRE) - categories.TECH1, '>='})
    end

    -- sends 4, 6, 10 [light artillery, mobile missiles] if player has >= 12, 10, 8 T2/T3 DF/IF
    quantity = {4, 6, 10}
    trigger = {12, 10, 8}
    opai = OrderM1MainBase:AddOpAI('BasicLandAttack', 'M1_LandAttack6',
        {
            MasterPlatoonFunction = {'/lua/scenarioplatoonai.lua', 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Order_M1_Attack_Chain', 'Order_M1_Attack2_Chain', 'Order_M1_Attack3_Chain', 'Order_M1_Attack4_Chain'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'LightArtillery', 'MobileMissiles'}, quantity[Difficulty])
    if(Difficulty < 3) then
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers'}, trigger[Difficulty], (categories.DIRECTFIRE + categories.INDIRECTFIRE) - categories.TECH1, '>='})
    else
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers', 'Loyalist'}, trigger[Difficulty], (categories.DIRECTFIRE + categories.INDIRECTFIRE) - categories.TECH1, '>='})
    end

    -- sends 4, 4, 10 [light tanks, heavy tanks] if player has >= 70, 60, 50 units
    quantity = {4, 4, 10}
    trigger = {70, 60, 50}
    opai = OrderM1MainBase:AddOpAI('BasicLandAttack', 'M1_LandAttack7',
        {
            MasterPlatoonFunction = {'/lua/scenarioplatoonai.lua', 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Order_M1_Attack_Chain', 'Order_M1_Attack2_Chain', 'Order_M1_Attack3_Chain', 'Order_M1_Attack4_Chain'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'LightTanks', 'HeavyTanks'}, quantity[Difficulty])
    if(Difficulty < 3) then
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL, '>='})
    else
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers', 'Loyalist'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL, '>='})
    end

    -- sends 4, 6, 10 [light artillery, mobile missiles] if player has >= 90, 80, 70 units
    quantity = {4, 6, 10}
    trigger = {90, 80, 70}
    opai = OrderM1MainBase:AddOpAI('BasicLandAttack', 'M1_LandAttack8',
        {
            MasterPlatoonFunction = {'/lua/scenarioplatoonai.lua', 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Order_M1_Attack_Chain', 'Order_M1_Attack2_Chain', 'Order_M1_Attack3_Chain', 'Order_M1_Attack4_Chain'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'LightArtillery', 'MobileMissiles'}, quantity[Difficulty])
    if(Difficulty < 3) then
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL, '>='})
    else
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers', 'Loyalist'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL, '>='})
    end

    -- sends 10, 12, 14 [mobile aa, mobile shields] if player has >= 40, 30, 20 mobile air units
    quantity = {10, 12, 14}
    trigger = {40, 30, 20}
    opai = OrderM1MainBase:AddOpAI('BasicLandAttack', 'M1_LandAttack9',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Order_M1_Attack_Chain', 'Order_M1_Attack2_Chain', 'Order_M1_Attack3_Chain', 'Order_M1_Attack4_Chain'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity({'MobileAntiAir', 'MobileShields'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.MOBILE * categories.AIR, '>='})

    -- sends 10, 12, 14 [mobile flak, mobile shields] if player has >= 60, 50, 40 mobile air units
    quantity = {10, 12, 14}
    trigger = {60, 50, 40}
    opai = OrderM1MainBase:AddOpAI('BasicLandAttack', 'M1_LandAttack10',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Order_M1_Attack_Chain', 'Order_M1_Attack2_Chain', 'Order_M1_Attack3_Chain', 'Order_M1_Attack4_Chain'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity({'MobileFlak', 'MobileShields'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.MOBILE * categories.AIR, '>='})

    -- sends 6, 8, 10 [amphibious tanks, light tanks] if player has >= 10, 8, 6 T3 units
    quantity = {6, 8, 10}
    trigger = {10, 8, 6}
    opai = OrderM1MainBase:AddOpAI('BasicLandAttack', 'M1_LandAttack11',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Order_M1_Attack_Chain', 'Order_M1_Attack2_Chain', 'Order_M1_Attack3_Chain', 'Order_M1_Attack4_Chain'},
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity({'AmphibiousTanks', 'LightTanks'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.TECH3, '>='})

    -- sends 10, 12, 14 [mobile flak, mobile shields] if player has >= 1 strat bomber
    quantity = {10, 12, 14}
    opai = OrderM1MainBase:AddOpAI('BasicLandAttack', 'M1_LandAttack12',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Order_M1_Attack_Chain', 'Order_M1_Attack2_Chain', 'Order_M1_Attack3_Chain', 'Order_M1_Attack4_Chain'},
            },
            Priority = 140,
        }
    )
    opai:SetChildQuantity({'MobileFlak', 'MobileShields'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, 1, categories.uaa0304 + categories.uea0304 + categories.ura0304, '>='})

    -- sends 10, 12, 14 [mobile missiles, light artillery] if player has >= 300, 250, 200 units
    quantity = {10, 12, 14}
    trigger = {300, 250, 200}
    opai = OrderM1MainBase:AddOpAI('BasicLandAttack', 'M1_LandAttack13',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Order_M1_Attack_Chain', 'Order_M1_Attack2_Chain', 'Order_M1_Attack3_Chain', 'Order_M1_Attack4_Chain'},
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity({'MobileMissiles', 'LightArtillery'}, quantity[Difficulty])
    if(Difficulty < 3) then
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL, '>='})
    else
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers', 'Loyalist'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL})
    end

    -- Land Defense
    for i = 1, 3 do
        opai = OrderM1MainBase:AddOpAI('BasicLandAttack', 'M1_LandDefense' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
                PlatoonData = {
                    PatrolChains = {'M1_Order_BasePatrol_1_Chain', 'M1_Order_BasePatrol_2_Chain'},
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity({'LightBots', 'HeavyTanks'}, 4)
    end
end

function OrderM1ResourceBaseAI()

    ------------------------
    -- Order M1 Resource Base
    ------------------------
    OrderM1ResourceBase:InitializeDifficultyTables(ArmyBrains[Order], 'M1_Order_ResourceBase', 'Order_M1_Resource_Base_Marker', 30, {M1_Order_ResourceBase = 100})
    OrderM1ResourceBase:StartNonZeroBase()
end

function M1S1Response()
    OrderM1MainBase:SetActive('Shields', false)
end