local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'

---------
-- Locals
---------
local Cybran = 2
local Difficulty = ScenarioInfo.Options.Difficulty

----------------
-- Base Managers
----------------
local CybranM1NodeBase = BaseManager.CreateBaseManager()
local CybranM1NavalBase = BaseManager.CreateBaseManager()

----------------------
-- Cybran M1 Node Base
----------------------
function CybranM1NodeBaseAI()
    CybranM1NodeBase:InitializeDifficultyTables(ArmyBrains[Cybran], 'M1_Node_Base', 'M1_Node_Base_Marker', 40, {M1_Node_Base = 100})
    CybranM1NodeBase:StartNonZeroBase({{6, 12, 18}, {5, 10, 16}})
    CybranM1NodeBase:SetActive('AirScouting', true)

    ForkThread(function()
        WaitSeconds(1)
        CybranM1NodeBase:AddBuildGroup('M1_Node_Base_Support_Factories', 100, true)
    end)

    --CybranM1NodeBase:AddReactiveAI('MassedAir', 'AirRetaliation', 'CybranM1NodeBase_MassedAir')

    CybranM1NodeBaseAirAttacks()
    CybranM1NodeBaseLandAttacks()
end

function CybranM1NodeBaseAirAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    -- Transport Builder
    opai = CybranM1NodeBase:AddOpAI('EngineerAttack', 'M1_Cybran_TransportBuilder',
    {
        MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
        PlatoonData = {
            TransportReturn = 'M1_Node_Base_Marker',
        },
        Priority = 1000,
    })
    opai:SetChildQuantity('T2Transports', 3)
    opai:SetLockingStyle('None')
    opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
        'HaveLessThanUnitsWithCategory', {'default_brain', 6, categories.ura0104})

    -- Attack
    -- Send 3 Bombers when Players have >= 35, 25, 15 units
    trigger = {35, 25, 15}
    opai = CybranM1NodeBase:AddOpAI('AirAttacks', 'M1_Cybran_AirAttack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Cybran_M1_Air_Attack_Chain_1',
                                'Cybran_M1_Air_Attack_Chain_2',
                                'Cybran_M1_Air_Attack_Chain_3',
                                'Cybran_M1_Air_Attack_Chain_4',
                                'Cybran_M1_Air_Attack_Chain_5'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Bombers', 3)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL, '>='})

    -- Send 3, 3, 6 Bombers when Players have >= 50, 40, 30 units
    quantity = {3, 3, 6}
    trigger = {50, 40, 30}
    opai = CybranM1NodeBase:AddOpAI('AirAttacks', 'M1_Cybran_AirAttack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Cybran_M1_Air_Attack_Chain_1',
                                'Cybran_M1_Air_Attack_Chain_2',
                                'Cybran_M1_Air_Attack_Chain_3',
                                'Cybran_M1_Air_Attack_Chain_4',
                                'Cybran_M1_Air_Attack_Chain_5'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Bombers', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL, '>='})

    -- Send 3 Gunships when Players have >= 65, 55, 45 units and T2 Land Factory
    trigger = {65, 55, 45}
    opai = CybranM1NodeBase:AddOpAI('AirAttacks', 'M1_Cybran_AirAttack_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Cybran_M1_Air_Attack_Chain_1',
                                'Cybran_M1_Air_Attack_Chain_2',
                                'Cybran_M1_Air_Attack_Chain_3',
                                'Cybran_M1_Air_Attack_Chain_4',
                                'Cybran_M1_Air_Attack_Chain_5'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('Gunships', 3)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL, '>='})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, 1, categories.LAND * categories.FACTORY * categories.TECH2, '>='})

    -- Send 3, 3, 6 Gunships when Players have >= 10 T2 units
    quantity = {3, 3, 6}
    opai = CybranM1NodeBase:AddOpAI('AirAttacks', 'M1_Cybran_AirAttack_4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Cybran_M1_Air_Attack_Chain_1',
                                'Cybran_M1_Air_Attack_Chain_2',
                                'Cybran_M1_Air_Attack_Chain_3',
                                'Cybran_M1_Air_Attack_Chain_4',
                                'Cybran_M1_Air_Attack_Chain_5'},
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, 10, categories.TECH2, '>='})

    -- Send 3, 6, 9} Gunships when Players have >= 20 T2 units
    quantity = {3, 6, 9}
    opai = CybranM1NodeBase:AddOpAI('AirAttacks', 'M1_Cybran_AirAttack_5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Cybran_M1_Air_Attack_Chain_1',
                                'Cybran_M1_Air_Attack_Chain_2',
                                'Cybran_M1_Air_Attack_Chain_3',
                                'Cybran_M1_Air_Attack_Chain_4',
                                'Cybran_M1_Air_Attack_Chain_5'},
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, 20, categories.TECH2, '>='})

    -- Send 3, 6, 9 Interceptors when Players have >= 13, 10, 7 Mobile Air units
    quantity = {3, 6, 6}
    trigger = {13, 10, 7}
    opai = CybranM1NodeBase:AddOpAI('AirAttacks', 'M1_Cybran_AirAttack_6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Cybran_M1_Air_Attack_Chain_1',
                                'Cybran_M1_Air_Attack_Chain_2',
                                'Cybran_M1_Air_Attack_Chain_3',
                                'Cybran_M1_Air_Attack_Chain_4',
                                'Cybran_M1_Air_Attack_Chain_5'},
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('Interceptors', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE, '>='})

    -- Send 6, 6, 9 Interceptors when Players have >= 19, 16, 13 Mobile Air units
    quantity = {6, 6, 9}
    trigger = {19, 16, 13}
    opai = CybranM1NodeBase:AddOpAI('AirAttacks', 'M1_Cybran_AirAttack_7',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Cybran_M1_Air_Attack_Chain_1',
                                'Cybran_M1_Air_Attack_Chain_2',
                                'Cybran_M1_Air_Attack_Chain_3',
                                'Cybran_M1_Air_Attack_Chain_4',
                                'Cybran_M1_Air_Attack_Chain_5'},
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('Interceptors', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE, '>='})

    -- Defense
    quantity = {3, 6, 9}
    for i = 1, 2 do
        opai = CybranM1NodeBase:AddOpAI('AirAttacks', 'M1_Cybran_AirDefense_1_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'Cybran_M1_Node_BasePatrolChain',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('Interceptors', quantity[Difficulty])
    end

    quantity = {3, 6, 6}
    for i = 1, 2 do
        opai = CybranM1NodeBase:AddOpAI('AirAttacks', 'M1_Cybran_AirDefense_2_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'Cybran_M1_Node_BasePatrolChain',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('Bombers', quantity[Difficulty])
    end
end

function CybranM1NodeBaseLandAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    -- Drops
    trigger = {50, 40, 30}
    opai = CybranM1NodeBase:AddOpAI('BasicLandAttack', 'M1_Cybran_TransportAttack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain = 'Player_Patrol_Chain',
                LandingChain = 'Cybran_M1_Landing_Chain',
                TransportReturn = 'M1_Node_Base_Marker',
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('HeavyBots', 6)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL, '>='})

    trigger = {70, 60, 50}
    quantity = {8, 12, 16}
    opai = CybranM1NodeBase:AddOpAI('BasicLandAttack', 'M1_Cybran_TransportAttack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain = 'Player_Patrol_Chain',
                LandingChain = 'Cybran_M1_Landing_Chain',
                TransportReturn = 'M1_Node_Base_Marker',
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('HeavyBots', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL, '>='})

    trigger = {20, 15, 10}
    opai = CybranM1NodeBase:AddOpAI('BasicLandAttack', 'M1_Cybran_TransportAttack_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain = 'Player_Patrol_Chain',
                LandingChain = 'Cybran_M1_Landing_Chain',
                TransportReturn = 'M1_Node_Base_Marker',
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('LightAtrillery', 8)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.DEFENSE, '>='})

    quantity = {4, 8, 8}
    trigger = {32, 26, 20}
    opai = CybranM1NodeBase:AddOpAI('BasicLandAttack', 'M1_Cybran_TransportAttack_4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain = 'Player_Patrol_Chain',
                LandingChain = 'Cybran_M1_Landing_Chain',
                TransportReturn = 'M1_Node_Base_Marker',
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity('HeavyTanks', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.TECH2, '>='})

    quantity = {4, 8, 8}
    trigger = {20, 16, 12}
    opai = CybranM1NodeBase:AddOpAI('BasicLandAttack', 'M1_Cybran_TransportAttack_5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain = 'Player_Patrol_Chain',
                LandingChain = 'Cybran_M1_Landing_Chain',
                TransportReturn = 'M1_Node_Base_Marker',
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity('HeavyTanks', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.TECH2 * categories.MOBILE, '>='})

    -- Wagner attacks
    quantity = {6, 9, 12}
    trigger = {100, 85, 70}
    opai = CybranM1NodeBase:AddOpAI('BasicLandAttack', 'M1_Cybran_AmphibiousAttack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Cybran_M1_Air_Attack_Chain_1',
                                'Cybran_M1_Air_Attack_Chain_2',
                                'Cybran_M1_Air_Attack_Chain_3',
                                'Cybran_M1_Air_Attack_Chain_4',
                                'Cybran_M1_Air_Attack_Chain_5'},
            },
            Priority = 140,
        }
    )
    opai:SetChildQuantity('AmphibiousTanks', quantity[Difficulty])
    opai:SetFormation('AttackFormation')
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL, '>='})

    quantity = {6, 9, 12}
    trigger = {36, 28, 20}
    opai = CybranM1NodeBase:AddOpAI('BasicLandAttack', 'M1_Cybran_AmphibiousAttack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Cybran_M1_Air_Attack_Chain_1',
                                'Cybran_M1_Air_Attack_Chain_2',
                                'Cybran_M1_Air_Attack_Chain_3',
                                'Cybran_M1_Air_Attack_Chain_4',
                                'Cybran_M1_Air_Attack_Chain_5'},
            },
            Priority = 140,
        }
    )
    opai:SetChildQuantity('AmphibiousTanks', quantity[Difficulty])
    opai:SetFormation('AttackFormation')
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.TECH2 * categories.MOBILE * categories.LAND, '>='})

    quantity = {6, 9, 12}
    trigger = {16, 13, 10}
    opai = CybranM1NodeBase:AddOpAI('BasicLandAttack', 'M1_Cybran_AmphibiousAttack_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Cybran_M1_Air_Attack_Chain_1',
                                'Cybran_M1_Air_Attack_Chain_2',
                                'Cybran_M1_Air_Attack_Chain_3',
                                'Cybran_M1_Air_Attack_Chain_4',
                                'Cybran_M1_Air_Attack_Chain_5'},
            },
            Priority = 140,
        }
    )
    opai:SetChildQuantity('AmphibiousTanks', quantity[Difficulty])
    opai:SetFormation('AttackFormation')
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.MOBILE * categories.NAVAL, '>='})
end

--------------------
-- Cybran Naval Base
--------------------
function CybranM1NavalBaseAI()
    CybranM1NavalBase:InitializeDifficultyTables(ArmyBrains[Cybran], 'M1_Naval_Base', 'M1_Naval_Base_Marker', 50, {M1_Naval_Base = 100})
    CybranM1NavalBase:StartNonZeroBase({{3, 6, 9}, {2, 5, 7}})

    ForkThread(function()
        WaitSeconds(1)
        CybranM1NavalBase:AddBuildGroup('M1_Naval_Base_Support_Factories', 100, true)
    end)

    CybranM1NavalBaseNavalAttacks()
end

function CybranM1NavalBaseNavalAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    -- Attack
    -- T1
    quantity = {3, 5, 6}
    opai = CybranM1NavalBase:AddNavalAI('M1_Cybran_T1_Naval_Attack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'Cybran_M1_Naval_Attack_Chain',
            },
            MaxFrigates = quantity[Difficulty],
            MinFrigates = quantity[Difficulty],
            Priority = 100,
        }
    )
    opai:SetChildActive('T2', false)
    opai:SetChildActive('T3', false)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, 1, categories.NAVAL * categories.FACTORY, '>='})

    quantity = {6, 8, 10}
    trigger = {16, 13, 10}
    opai = CybranM1NavalBase:AddNavalAI('M1_Cybran_T1_Naval_Attack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'Cybran_M1_Naval_Attack_Chain',
            },
            MaxFrigates = quantity[Difficulty],
            MinFrigates = quantity[Difficulty],
            Priority = 110,
        }
    )
    opai:SetChildActive('T2', false)
    opai:SetChildActive('T3', false)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE, '>='})

    -- T2 navy
    if Difficulty == 3 then
        opai = CybranM1NavalBase:AddNavalAI('M1_Cybran_T2_Naval_Attack_1',
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'Cybran_M1_Destroyer_Land_Chain',
                },
                EnabledTypes = {'Destroyer'},
                MaxFrigates = 10,
                MinFrigates = 10,
                Priority = 120,
            }
        )
        opai:SetChildActive('T1', false)
        opai:SetChildActive('T3', false)
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'HumanPlayers'}, 8, categories.MASSEXTRACTION * categories.TECH2, '>='})
    end

    quantity = {10, 15, 20}
    trigger = {10, 7, 3}
    opai = CybranM1NavalBase:AddNavalAI('M1_Cybran_T2_Naval_Attack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'Cybran_M1_Naval_Attack_Destroyer_Chain',
            },
            EnabledTypes = {'Destroyer', 'Cruiser'},
            MaxFrigates = quantity[Difficulty],
            MinFrigates = quantity[Difficulty],
            Priority = 130,
        }
    )
    opai:SetChildActive('T1', false)
    opai:SetChildActive('T3', false)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE * categories.TECH2, '>='})

    -- Defense
    for i = 1, 1 + Difficulty do
        opai = CybranM1NavalBase:AddNavalAI('M1_Cybran_T1_Naval_Defense_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'SplitPatrolThread'},
                PlatoonData = {
                    PatrolChains = {'Cybran_M1_Naval_Patrol_Chain'},
                },
                Overrides = {
                    CORE_TO_SUBS = 1,
                },
                EnabledTypes = {'Submarine'},
                MaxFrigates = 3,
                MinFrigates = 3,
                Priority = 100,
            }
        )
        opai:SetChildActive('T2', false)
        opai:SetChildActive('T3', false)
        opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    end

    opai = CybranM1NavalBase:AddNavalAI('M1_Cybran_Destroyer_Defense',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'Cybran_M1_Naval_Patrol_Chain_2',
            },
            EnabledTypes = {'Destroyer'},
            MaxFrigates = 15,
            MinFrigates = 15,
            Priority = 100,
        }
    )
    opai:SetChildActive('T1', false)
    opai:SetChildActive('T3', false)
end

function M1BlockadeDestroyers()
    local opai = CybranM1NavalBase:AddNavalAI('M1_Cybran_Destroyer_Blockade',
        {
            MasterPlatoonFunction = {SPAIFileName, 'MoveToThread'},
            PlatoonData = {
                MoveRoute = {'Cybran_M1_Destroyer_Blockade_Marker'},
            },
            EnabledTypes = {'Destroyer'},
            MaxFrigates = 15,
            MinFrigates = 15,
            Priority = 120,
        }
    )
    opai:SetChildActive('T1', false)
    opai:SetChildActive('T3', false)
end

function M1BlockadeCruisers()
    local opai = CybranM1NavalBase:AddNavalAI('M1_Cybran_Cruiser_Blockade',
        {
            MasterPlatoonFunction = {SPAIFileName, 'MoveToThread'},
            PlatoonData = {
                MoveRoute = {'Cybran_M1_Cruiser_Blockade_Marker'},
            },
            Overrides = {
                CORE_TO_CRUISERS = 1,
            },
            EnabledTypes = {'Cruiser'},
            MaxFrigates = 15,
            MinFrigates = 15,
            Priority = 110,
        }
    )
    opai:SetChildActive('T1', false)
    opai:SetChildActive('T3', false)
end