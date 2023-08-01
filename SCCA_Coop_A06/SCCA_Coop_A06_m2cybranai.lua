local BaseManager = import('/lua/ai/opai/basemanager.lua')
local CustomFunctions = '/maps/SCCA_Coop_A06/SCCA_Coop_A06_CustomFunctions.lua'
local SPAIFileName = '/lua/scenarioplatoonai.lua'

---------
-- Locals
---------
local Cybran = 3
local Difficulty = ScenarioInfo.Options.Difficulty

----------------
-- Base Managers
----------------
local CybranM2Base = BaseManager.CreateBaseManager()

-----------------
-- Cybran M2 Base
-----------------
function CybranM2BaseAI()
    CybranM2Base:InitializeDifficultyTables(ArmyBrains[Cybran], 'M2_Cybran_Base', 'M2_Cybran_Base_Marker', 150, {M2_Base = 100})
    CybranM2Base:StartNonZeroBase({{6, 10, 14}, {6, 9, 12}})
    CybranM2Base:SetActive('AirScouting', true)

    CybranM2BaseAirAttacks()
    CybranM2BaseLandAttacks()
    CybranM2BaseNavalAttacks()
end

function CybranM2BaseAirAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    -- Transport builder, maintain 8 transports
    opai = CybranM2Base:AddOpAI('EngineerAttack', 'M2_TransportBuilder',
        {
            MasterPlatoonFunction = {SPAIFileName, 'TransportPool'},
            PlatoonData = {
                TransportMoveLocation = 'M2_Cybran_Base_Marker',
            },
            Priority = 1000,
        }
    )
    opai:SetChildQuantity('T2Transports', 6)
    opai:SetLockingStyle('None')
    opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
        'HaveLessThanUnitsWithCategory', {'default_brain', 8, categories.ura0104})

    quantity = {9, 12, 15}
    opai = CybranM2Base:AddOpAI('AirAttacks', 'M2_Cybran_Base_AirAttack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M1_Cybran_Naval_Attack_Chain',
                    'M1_Cybran_Naval_Attack_Chain_1',
                    'M1_Cybran_Naval_Attack_Chain_3',
                },
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])

    quantity = {9, 15, 24}
    opai = CybranM2Base:AddOpAI('AirAttacks', 'M2_Cybran_Base_AirAttack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'SplitPatrolThread'},
            PlatoonData = {
                PatrolChains = {
                    'M1_Cybran_Naval_Attack_Chain',
                    'M1_Cybran_Naval_Attack_Chain_1',
                    'M1_Cybran_Naval_Attack_Chain_3',
                },
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Bombers', quantity[Difficulty])

    quantity = {9, 12, 15}
    trigger = {20, 15, 10}
    opai = CybranM2Base:AddOpAI('AirAttacks', 'M2_Cybran_Base_AirAttack_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M1_Cybran_Naval_Attack_Chain',
                    'M1_Cybran_Naval_Attack_Chain_1',
                    'M1_Cybran_Naval_Attack_Chain_3',
                },
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('TorpedoBombers', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.NAVAL, '>='})

    quantity = {2, 3, 6}
    opai = CybranM2Base:AddOpAI('AirAttacks', 'M2_Cybran_Base_AirAttack_4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M1_Cybran_Naval_Attack_Chain',
                    'M1_Cybran_Naval_Attack_Chain_1',
                    'M1_Cybran_Naval_Attack_Chain_3',
                },
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('StratBombers', quantity[Difficulty])

    quantity = {6, 9, 12}
    trigger = {10, 11, 12}
    opai = CybranM2Base:AddOpAI('AirAttacks', 'M2_Cybran_Base_AirAttack_5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M1_Cybran_Naval_Attack_Chain',
                    'M1_Cybran_Naval_Attack_Chain_1',
                    'M1_Cybran_Naval_Attack_Chain_3',
                },
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE, '>='})
end

function CybranM2BaseLandAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    -- Wagner attacks, 2 chians through the water to the island, one to the control center
    quantity = {8, 10, 12}
    opai = CybranM2Base:AddOpAI('BasicLandAttack', 'M2_Cybran_AmphibiousAttack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M2_Cybran_Amphibious_Chain_1',
                    'M2_Cybran_Amphibious_Chain_2',
                },
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('AmphibiousTanks', quantity[Difficulty])
    opai:SetFormation('AttackFormation')
    opai:SetLockingStyle('None')

    -- Drops
    quantity = {4, 6, 8}
    for i = 1, 2 do
        opai = CybranM2Base:AddOpAI('BasicLandAttack', 'M2_Cybran_Drop_1_' .. i,
            {
                MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
                PlatoonData = {
                    AttackChain = 'Player_Base_Chain',
                    MovePath = 'M2_Cybran_Drop_Move_Chain_' .. i,
                    LandingChain = 'Player_Base_Landing_Chain',
                },
                Priority = 200,
            }
        )
        opai:SetChildQuantity('SiegeBots', quantity[Difficulty])
        opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
            'HaveGreaterThanUnitsWithCategory', {'default_brain', 4, categories.ura0104})
        opai:SetLockingStyle('DeathTimer', {LockTimer = 180})
    end

    -- Experimentals
    -- 1, 2, 3 Spiderbots, sent together to the players' island
    for i = 1, Difficulty do
        opai = CybranM2Base:AddOpAI('Spiderbot' .. i,
            {
                Amount = 1,
                KeepAlive = true,
                PlatoonAIFunction = {CustomFunctions, 'AddExperimentalToPlatoon'},
                PlatoonData = {
                    Name = 'SpiderBots',
                    NumRequired = Difficulty,
                    PatrolChain = 'Player_Base_Chain',
                },
                MaxAssist = 4,
                Retry = true,
            }
        )
    end
end

function CybranM2BaseNavalAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    quantity = {{3, 3}, {6, 3}, {12, 6}}
    opai = CybranM2Base:AddOpAI('NavalAttacks', 'M2_Cybran_Base_NavalAttack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M1_Cybran_Naval_Attack_Chain',
                    'M1_Cybran_Naval_Attack_Chain_1',
                    'M1_Cybran_Naval_Attack_Chain_2'
                },
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'Frigates', 'Submarines'}, quantity[Difficulty])

    opai = CybranM2Base:AddOpAI('NavalAttacks', 'M2_Cybran_Base_NavalAttack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M1_Cybran_Naval_Attack_Chain',
                    'M1_Cybran_Naval_Attack_Chain_1',
                    'M1_Cybran_Naval_Attack_Chain_2'
                },
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'Destroyers', 'Frigates'}, {3, 6})

    quantity = {2, 4, 6}
    trigger = {15, 12, 9}
    opai = CybranM2Base:AddOpAI('NavalAttacks', 'M2_Cybran_Base_NavalAttack_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M1_Cybran_Naval_Attack_Chain',
                    'M1_Cybran_Naval_Attack_Chain_1',
                    'M1_Cybran_Naval_Attack_Chain_2'
                },
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('Destroyers', 3)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE - categories.TECH1, '>='})

    quantity = {{2, 1}, {3, 1, 4}, {4, 2, 6}}
    opai = CybranM2Base:AddOpAI('NavalAttacks', 'M2_Cybran_Base_NavalAttack_4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M1_Cybran_Naval_Attack_Chain',
                    'M1_Cybran_Naval_Attack_Chain_1',
                    'M1_Cybran_Naval_Attack_Chain_2'
                },
            },
            Priority = 130,
        }
    )
    if Difficulty >= 2 then
        opai:SetChildQuantity({'Destroyers', 'Cruisers', 'Submarines'}, quantity[Difficulty])
    else
        opai:SetChildQuantity({'Destroyers', 'Cruisers'}, quantity[Difficulty])
    end
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, 3, categories.NAVAL * categories.MOBILE - categories.TECH1, '>='})

    opai = CybranM2Base:AddOpAI('NavalAttacks', 'M2_Cybran_Base_NavalAttack_5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M1_Cybran_Naval_Attack_Chain',
                    'M1_Cybran_Naval_Attack_Chain_1',
                    'M1_Cybran_Naval_Attack_Chain_2'
                },
            },
            Priority = 140,
        }
    )
    opai:SetChildQuantity({'Battleships', 'Destroyers'}, {1, 4})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, 6, categories.NAVAL * categories.MOBILE - categories.TECH1, '>='})

    opai = CybranM2Base:AddOpAI('NavalAttacks', 'M2_Cybran_Base_NavalAttack_6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M1_Cybran_Naval_Attack_Chain',
                    'M1_Cybran_Naval_Attack_Chain_1',
                    'M1_Cybran_Naval_Attack_Chain_2'
                },
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity('Battleships', 3)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, 2, categories.NAVAL * categories.MOBILE * categories.TECH3, '>='})

    -- Sonar around the base
    opai = CybranM2Base:AddOpAI('Sonar',
        {
            Amount = 1,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Cybran_Sonar_Chain',
            },
            MaxAssist = 1,
            Retry = true,
        }
    )
end
