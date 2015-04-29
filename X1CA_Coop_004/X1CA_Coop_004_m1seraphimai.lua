-- ****************************************************************************
-- **
-- **  File     : /maps/X1CA_Coop_004/X1CA_Coop_004_v04_m1seraphimai.lua
-- **  Author(s): Jessica St. Croix
-- **
-- **  Summary  : Seraphim army AI for Mission 1 - X1CA_Coop_004
-- **
-- **  Copyright © 2007 Gas Powered Games, Inc.  All rights reserved.
-- ****************************************************************************
local BaseManager = import('/lua/ai/opai/basemanager.lua')

local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')

local SPAIFileName = '/lua/ScenarioPlatoonAI.lua'

--------
-- Locals
--------
local Seraphim = 3
local Difficulty = ScenarioInfo.Options.Difficulty

---------------
-- Base Managers
---------------
local SeraphimM1West = BaseManager.CreateBaseManager()
local ForwardNorthBase = BaseManager.CreateBaseManager()
local ForwardSouthBase = BaseManager.CreateBaseManager()

function SeraphimM1WestAI()

    ------------------
    -- Seraphim M1 West
    ------------------
    SeraphimM1West:InitializeDifficultyTables(ArmyBrains[Seraphim], 'M1_Seraph_West', 'Seraphim_M1_West', 50, {M1_Seraph_West = 100,})
    SeraphimM1West:StartNonZeroBase({{3, 5, 10}, {2, 3, 6}})
    SeraphimM1West:SetActive('AirScouting', true)
    SeraphimM1West:SetActive('LandScouting', true)

    SeraphimM1West:AddReactiveAI('ExperimentalLand', 'AirRetaliation', 'SeraphimM1West_ExperimentalLand')
    SeraphimM1West:AddReactiveAI('ExperimentalAir', 'AirRetaliation', 'SeraphimM1West_ExperimentalAir')
    SeraphimM1West:AddReactiveAI('Nuke', 'AirRetaliation', 'SeraphimM1West_Nuke')
    SeraphimM1West:AddReactiveAI('HLRA', 'AirRetaliation', 'SeraphimM1West_HLRA')

    SeraphimM1WestAirAttacks()
    SeraphimM1WestLandAttacks()

    ScenarioFramework.CreateTimerTrigger(SeraphForwardAI, 180)
end

function SeraphForwardAI()
    SeraphimM1West:AddBuildGroup('Seraph_M1ForwardSouth', 90)
    SeraphimM1West:AddBuildGroup('Seraph_M1ForwardNorth', 80)

    ForwardNorthBase:Initialize(ArmyBrains[Seraphim], 'ForwardNorthSeraph', 'SeraphNorth_Marker', 40, {Seraph_M1ForwardNorth = 100,})
    ForwardSouthBase:Initialize(ArmyBrains[Seraphim], 'ForwardSouthSeraph', 'SeraphSouth_Marker', 40, {Seraph_M1ForwardSouth = 100,})
    ForwardNorthBase:StartEmptyBase({4, 2})
    ForwardSouthBase:StartEmptyBase({4, 2})

    ForwardLandAttacks()
end

function SeraphimM1WestAirAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    -------------------------------------
    -- Seraphim M1 West Op AI, Air Attacks
    -------------------------------------

    -- sends 3, 6, 6 [bombers] if player has >= 12, 8, 5 AA
    quantity = {3, 6, 6}
    trigger = {12, 8, 5}
    opai = SeraphimM1West:AddOpAI('AirAttacks', 'M1_AirAttack1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Seraph_AirAttack_Chain', 'M1_Seraph_Attack_1_Chain', 'M1_Seraph_Attack_2_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Bombers', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.ANTIAIR})

    -- sends 4, 6, 6 [gunships, combat fighter] if player has >= 7, 5, 3 T2/T3 AA
    quantity = {4, 6, 6}
    trigger = {7, 5, 3}
    opai = SeraphimM1West:AddOpAI('AirAttacks', 'M1_AirAttack2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Seraph_AirAttack_Chain', 'M1_Seraph_Attack_1_Chain', 'M1_Seraph_Attack_2_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'Gunships', 'CombatFighters'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.ANTIAIR - categories.TECH1})

    -- sends 4, 6, 6 [interceptors] if player has >= 15, 10, 10 mobile air
    quantity = {4, 6, 6}
    trigger = {15, 10, 10}
    opai = SeraphimM1West:AddOpAI('AirAttacks', 'M1_AirAttack3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Seraph_AirAttack_Chain', 'M1_Seraph_Attack_1_Chain', 'M1_Seraph_Attack_2_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Interceptors', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.MOBILE * categories.AIR})

    -- sends 4, 6, 6 [bombers] if player has >= 50, 40, 30 structures
    quantity = {4, 6, 6}
    trigger = {50, 40, 30}
    opai = SeraphimM1West:AddOpAI('AirAttacks', 'M1_AirAttack4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Seraph_AirAttack_Chain', 'M1_Seraph_Attack_1_Chain', 'M1_Seraph_Attack_2_Chain'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Bombers', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.STRUCTURE - categories.WALL})

    -- sends 4, 6, 6 [gunships] if player has >= 30, 20, 10 T2/T3 structures
    quantity = {4, 6, 6}
    trigger = {30, 20, 10}
    opai = SeraphimM1West:AddOpAI('AirAttacks', 'M1_AirAttack5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Seraph_AirAttack_Chain', 'M1_Seraph_Attack_1_Chain', 'M1_Seraph_Attack_2_Chain'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.STRUCTURE - categories.TECH1})

    -- sends 4, 6, 6 [gunships] if player has >= 75, 60, 40 mobile land units
    quantity = {4, 6, 6}
    trigger = {75, 60, 40}
    opai = SeraphimM1West:AddOpAI('AirAttacks', 'M1_AirAttack6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Seraph_AirAttack_Chain', 'M1_Seraph_Attack_1_Chain', 'M1_Seraph_Attack_2_Chain'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], (categories.MOBILE * categories.LAND) - categories.CONSTRUCTION})

    -- sends 6, 9, 9 [combat fighter] if player has >= 75, 60, 40 mobile air units
    quantity = {6, 9, 9}
    trigger = {75, 60, 40}
    opai = SeraphimM1West:AddOpAI('AirAttacks', 'M1_AirAttack7',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Seraph_AirAttack_Chain', 'M1_Seraph_Attack_1_Chain', 'M1_Seraph_Attack_2_Chain'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('CombatFighters', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.MOBILE * categories.AIR})

    -- sends 4, 6, 6 [combat fighter, gunships] if player has >= 40, 30, 20 gunships
    quantity = {4, 6, 6}
    trigger = {40, 30, 20}
    opai = SeraphimM1West:AddOpAI('AirAttacks', 'M1_AirAttack8',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Seraph_AirAttack_Chain', 'M1_Seraph_Attack_1_Chain', 'M1_Seraph_Attack_2_Chain'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity({'CombatFighters', 'Gunships'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.uaa0203 + categories.uea0203 + categories.ura0203})

    -- sends 6, 9, 9 [gunships] if player has >= 50, 40, 30 T3 units
    quantity = {6, 9, 9}
    trigger = {50, 40, 30}
    opai = SeraphimM1West:AddOpAI('AirAttacks', 'M1_AirAttack9',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Seraph_AirAttack_Chain', 'M1_Seraph_Attack_1_Chain', 'M1_Seraph_Attack_2_Chain'},
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.TECH3})

    -- sends 6, 9, 9 [combat fighter] if player has >= 1 strat bomber
    quantity = {6, 9, 9}
    opai = SeraphimM1West:AddOpAI('AirAttacks', 'M1_AirAttack10',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Seraph_AirAttack_Chain', 'M1_Seraph_Attack_1_Chain', 'M1_Seraph_Attack_2_Chain'},
            },
            Priority = 140,
        }
    )
    opai:SetChildQuantity('CombatFighters', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', 1, categories.uaa0304 + categories.uea0304 + categories.ura0304})

    -- sends 6, 9, 9 [gunships] if player has >= 300, 250, 200 units
    quantity = {6, 9, 9}
    trigger = {300, 250, 200}
    opai = SeraphimM1West:AddOpAI('AirAttacks', 'M1_AirAttack11',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Seraph_AirAttack_Chain', 'M1_Seraph_Attack_1_Chain', 'M1_Seraph_Attack_2_Chain'},
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    opai:SetLockingStyle('None')
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.ALLUNITS - categories.WALL})

    -- Air Defense
    for i = 1, 2 do
        opai = SeraphimM1West:AddOpAI('AirAttacks', 'M1_AirDefense' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M1_Seraph_AirPatrol_Chain',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('Interceptors', 5)

        opai = SeraphimM1West:AddOpAI('AirAttacks', 'M1_AirDefense_2' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M1_Seraph_AirPatrol_Chain',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('Bombers', 4)
    end
end

function SeraphimM1WestLandAttacks()
    local opai = nil
    local trigger = {}

    ---- Build Engineers
    -- local Template = {
        -- 'T2Engineers',
        -- 'NoPlan',
        -- { 'xsl0208', 1, 2, 'Support', 'GrowthFormation' },    -- T2 Engineers
    -- }
    -- local Limit = {3, 5, 10}
    -- local Builder = {
        -- BuilderName = 'T2Engineers',
        -- PlatoonTemplate = Template,
        -- InstanceCount = 1,
        -- Priority = 5000,
        -- PlatoonType = 'Land',
        -- RequiresConstruction = true,
        -- AIPlan = 'DisbandAI',
        -- LocationType = 'M1_Seraph_West',
        -- BuildConditions = {
            -- { '/lua/editor/unitcountbuildconditions.lua', 'HaveLessThanUnitsWithCategory', {'default_brain', Limit[Difficulty] + 7, categories.xsl0208}},
        -- },
    -- }
    -- ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    --------------------------------------
    -- Seraphim M1 West Op AI, Land Attacks
    --------------------------------------

    -- sends engineers
    if(Difficulty > 1) then
        trigger = {0, 9, 14}
        opai = SeraphimM1West:AddOpAI('EngineerAttack', 'M1_EngAttack1',
            {
                MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
                PlatoonData = {
                    AttackChain = 'M1_TransportAttack_Chain',
                    LandingChain = 'M1_TransportAttack_Chain',
                    TransportReturn = 'Seraphim_M1_West',
                    Categories = {'ALLUNITS'},
                },
                Priority = 90,
            }
        )
        opai:SetChildActive('T2Engineers', false)
        opai:SetChildActive('T2Transports', false)
        opai:RemoveChildren({'T2Engineers', 'T2Transports'})
        opai:SetLockingStyle('BuildTimer', {LockTimer = 90})
        opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua', 'HaveLessThanUnitsWithCategoryInArea',
            {'default_brain', trigger[Difficulty], categories.xsl0105, 'M1Area'})
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainLessThanOrEqualNumCategory',
            {'default_brain', 'Player', 4, categories.DEFENSE * categories.STRUCTURE})
    end

    -- sends 3, 5, 5 [light bots] if player has >= 8, 5, 3 DF/IF
    quantity = {3, 5, 5}
    trigger = {8, 5, 3}
    opai = SeraphimM1West:AddOpAI('BasicLandAttack', 'M1_LandAttack1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M1_Seraph_Attack_2b_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('LightBots', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.DIRECTFIRE + categories.INDIRECTFIRE})

    -- sends 3, 5, 5 [light tanks] if player has >= 10, 8, 6 DF/IF
    quantity = {3, 5, 5}
    trigger = {10, 8, 6}
    opai = SeraphimM1West:AddOpAI('BasicLandAttack', 'M1_LandAttack2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M1_Seraph_Attack_2b_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('LightTanks', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.DIRECTFIRE + categories.INDIRECTFIRE})

    -- sends 3, 5, 5 [light artillery] if player has >= 40, 30, 20 units
    quantity = {3, 5, 5}
    trigger = {40, 30, 20}
    opai = SeraphimM1West:AddOpAI('BasicLandAttack', 'M1_LandAttack3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Seraph_Attack_1_Chain', 'M1_Seraph_Attack_2_Chain', 'M1_Seraph_Attack_3_Chain', 'M1_Seraph_Attack_4_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('LightArtillery', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.ALLUNITS - categories.WALL})

    -- sends 3, 5, 5 [mobile aa] if player has >= 10, 8, 6 planes
    quantity = {3, 5, 5}
    trigger = {10, 8, 6}
    opai = SeraphimM1West:AddOpAI('BasicLandAttack', 'M1_LandAttack4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Seraph_Attack_1_Chain', 'M1_Seraph_Attack_2_Chain', 'M1_Seraph_Attack_3_Chain', 'M1_Seraph_Attack_4_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('MobileAntiAir', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.MOBILE * categories.AIR})

    -- sends 4 [light tanks, heavy tanks] if player has >= 8, 6, 4 T2/T3 DF/IF
    trigger = {8, 6, 4}
    opai = SeraphimM1West:AddOpAI('BasicLandAttack', 'M1_LandAttack5',
        {
            MasterPlatoonFunction = {'/lua/scenarioplatoonai.lua', 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Seraph_Attack_1_Chain', 'M1_Seraph_Attack_2_Chain', 'M1_Seraph_Attack_3_Chain', 'M1_Seraph_Attack_4_Chain'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'LightTanks', 'HeavyTanks'}, 4)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], (categories.DIRECTFIRE + categories.INDIRECTFIRE) - categories.TECH1})

    -- sends 4, 6, 6 [light artillery, mobile missiles] if player has >= 12, 10, 8 T2/T3 DF/IF
    quantity = {4, 6, 6}
    trigger = {12, 10, 8}
    opai = SeraphimM1West:AddOpAI('BasicLandAttack', 'M1_LandAttack6',
        {
            MasterPlatoonFunction = {'/lua/scenarioplatoonai.lua', 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Seraph_Attack_1_Chain', 'M1_Seraph_Attack_2_Chain', 'M1_Seraph_Attack_3_Chain', 'M1_Seraph_Attack_4_Chain'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'LightArtillery', 'MobileMissiles'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], (categories.DIRECTFIRE + categories.INDIRECTFIRE) - categories.TECH1})

    -- sends 4 [light tanks, heavy tanks] if player has >= 80, 60, 50 units
    trigger = {80, 60, 50}
    opai = SeraphimM1West:AddOpAI('BasicLandAttack', 'M1_LandAttack7',
        {
            MasterPlatoonFunction = {'/lua/scenarioplatoonai.lua', 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Seraph_Attack_1_Chain', 'M1_Seraph_Attack_2_Chain', 'M1_Seraph_Attack_3_Chain', 'M1_Seraph_Attack_4_Chain'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'LightTanks', 'HeavyTanks'}, 4)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.ALLUNITS - categories.WALL})

    -- sends 4, 6, 6 [light artillery, mobile missiles] if player has >= 100, 80, 70 units
    quantity = {4, 6, 6}
    trigger = {100, 80, 70}
    opai = SeraphimM1West:AddOpAI('BasicLandAttack', 'M1_LandAttack8',
        {
            MasterPlatoonFunction = {'/lua/scenarioplatoonai.lua', 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Seraph_Attack_1_Chain', 'M1_Seraph_Attack_2_Chain', 'M1_Seraph_Attack_3_Chain', 'M1_Seraph_Attack_4_Chain'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'LightArtillery', 'MobileMissiles'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.ALLUNITS - categories.WALL})

    -- sends 8, 12, 12 [mobile aa, mobile shields] if player has >= 40, 30, 20 mobile air units
    quantity = {8, 12, 12}
    trigger = {40, 30, 20}
    opai = SeraphimM1West:AddOpAI('BasicLandAttack', 'M1_LandAttack9',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Seraph_Attack_1_Chain', 'M1_Seraph_Attack_2_Chain', 'M1_Seraph_Attack_3_Chain', 'M1_Seraph_Attack_4_Chain'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity({'MobileAntiAir', 'MobileShields'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.MOBILE * categories.AIR})

    -- sends 8, 12, 12 [mobile flak, mobile shields] if player has >= 60, 50, 40 mobile air units
    quantity = {8, 12, 12}
    trigger = {60, 50, 40}
    opai = SeraphimM1West:AddOpAI('BasicLandAttack', 'M1_LandAttack10',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Seraph_Attack_1_Chain', 'M1_Seraph_Attack_2_Chain', 'M1_Seraph_Attack_3_Chain', 'M1_Seraph_Attack_4_Chain'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity({'MobileFlak', 'MobileShields'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.MOBILE * categories.AIR})

    -- sends 6, 8, 8 [amphibious tanks, light tanks] if player has >= 10, 8, 6 T3 units
    quantity = {6, 8, 8}
    trigger = {10, 8, 6}
    opai = SeraphimM1West:AddOpAI('BasicLandAttack', 'M1_LandAttack11',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Seraph_Attack_1_Chain', 'M1_Seraph_Attack_2_Chain', 'M1_Seraph_Attack_3_Chain', 'M1_Seraph_Attack_4_Chain'},
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity({'AmphibiousTanks', 'LightTanks'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.TECH3})

    -- sends 8, 12, 12 [mobile flak, mobile shields] if player has >= 1 strat bomber
    quantity = {8, 12, 12}
    opai = SeraphimM1West:AddOpAI('BasicLandAttack', 'M1_LandAttack12',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Seraph_Attack_1_Chain', 'M1_Seraph_Attack_2_Chain', 'M1_Seraph_Attack_3_Chain', 'M1_Seraph_Attack_4_Chain'},
            },
            Priority = 140,
        }
    )
    opai:SetChildQuantity({'MobileFlak', 'MobileShields'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainGreaterThanOrEqualNumCategory', {'default_brain', 'Player', 1, categories.uaa0304 + categories.uea0304 + categories.ura0304})

    -- sends 8, 12, 12 [mobile missiles, light artillery] if player has >= 300, 250, 200 units
    quantity = {8, 12, 12}
    trigger = {300, 250, 200}
    opai = SeraphimM1West:AddOpAI('BasicLandAttack', 'M1_LandAttack13',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Seraph_Attack_1_Chain', 'M1_Seraph_Attack_2_Chain', 'M1_Seraph_Attack_3_Chain', 'M1_Seraph_Attack_4_Chain'},
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity({'MobileMissiles', 'LightArtillery'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.ALLUNITS - categories.WALL})

    -- Land Defense
    for i = 1, 4 do
        opai = SeraphimM1West:AddOpAI('BasicLandAttack', 'M1_LandDefense' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
                PlatoonData = {
                    PatrolChains = {'M1_Seraph_LandPatrol_1_Chain', 'M1_Seraph_LandPatrol_2_Chain'},
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity({'MobileFlak', 'MobileShields'}, 4)
    end
end

function ForwardLandAttacks()
    local opai = nil

    opai = ForwardNorthBase:AddOpAI('BasicLandAttack', 'M1_North1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackLocation'},
            PlatoonData = {
                Location = 'UEF_Base_Marker',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'MobileMissiles', 'LightArtillery'}, 4)

    opai = ForwardNorthBase:AddOpAI('BasicLandAttack', 'M1_North2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackLocation'},
            PlatoonData = {
                Location = 'UEF_Base_Marker',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'LightTanks'}, 6)

    opai = ForwardNorthBase:AddOpAI('BasicLandAttack', 'M1_North3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackLocation'},
            PlatoonData = {
                Location = 'UEF_Base_Marker',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'MobileFlak', 'LightBots'}, 4)

    opai = ForwardNorthBase:AddOpAI('BasicLandAttack', 'M1_North4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackLocation'},
            PlatoonData = {
                Location = 'UEF_Base_Marker',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'HeavyTanks', 'LightTanks'}, 2)

    opai = ForwardSouthBase:AddOpAI('BasicLandAttack', 'M1_South1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackLocation'},
            PlatoonData = {
                Location = 'UEF_Base_Marker',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'MobileMissiles', 'LightArtillery'}, 4)

    opai = ForwardSouthBase:AddOpAI('BasicLandAttack', 'M1_South2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackLocation'},
            PlatoonData = {
                Location = 'UEF_Base_Marker',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'LightTanks'}, 6)

    opai = ForwardSouthBase:AddOpAI('BasicLandAttack', 'M1_South3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackLocation'},
            PlatoonData = {
                Location = 'UEF_Base_Marker',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'MobileFlak', 'LightBots'}, 4)

    opai = ForwardSouthBase:AddOpAI('BasicLandAttack', 'M1_South4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackLocation'},
            PlatoonData = {
                Location = 'UEF_Base_Marker',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'HeavyTanks', 'LightTanks'}, 4)
end
