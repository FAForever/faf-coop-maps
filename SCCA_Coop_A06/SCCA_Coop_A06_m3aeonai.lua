local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'

---------
-- Locals
---------
local Aeon = 4
local Difficulty = ScenarioInfo.Options.Difficulty

----------------
-- Base Managers
----------------
local AeonM3Base = BaseManager.CreateBaseManager()
local AeonM3IslandBase = BaseManager.CreateBaseManager()
local AeonM3NavalBase = BaseManager.CreateBaseManager()

---------------
-- Aeon M3 Base
---------------
function AeonM3BaseAI()
    AeonM3Base:InitializeDifficultyTables(ArmyBrains[Aeon], 'M3_Aeon_Base', 'M3_Aeon_Base_Marker', 60, {M3_Base = 100})
    AeonM3Base:StartNonZeroBase({{4, 7, 10}, {4, 6, 8}})
    AeonM3Base:SetActive('AirScouting', true)
    AeonM3Base:SetActive('LandScouting', true)
    AeonM3Base:AddBuildGroup('M3_Base_Support_Factories', 100, true)

    AeonM3BaseAirAttacks()
    AeonM3BaseLandAttacks()
end

function AeonM3BaseAirAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    -- Transport builder, maintain 8 transports
    opai = AeonM3Base:AddOpAI('EngineerAttack', 'M3_TransportBuilder',
        {
            MasterPlatoonFunction = {SPAIFileName, 'LandAssaultWithTransports'},
            PlatoonData = {
                TransportReturn = 'M3_Aeon_Base_Marker',
            },
            Priority = 1000,
        }
    )
    opai:SetChildQuantity('T2Transports', 4)
    opai:SetLockingStyle('None')
    opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
        'HaveLessThanUnitsWithCategory', {'default_brain', 8, categories.uaa0104})

    quantity = {8, 12, 16}
    opai = AeonM3Base:AddOpAI('AirAttacks', 'M3_Aeon_Base_AirAttack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M3_Aeon_Naval_Attack_Chain',
                    'M3_Land_Attack_Chain_2',
                    'M1_UEF_Naval_Attack_Chain',
                },
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])

    opai = AeonM3Base:AddOpAI('AirAttacks', 'M3_Aeon_Base_AirAttack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M3_Aeon_Naval_Attack_Chain',
                    'M3_Land_Attack_Chain_2',
                    'M1_UEF_Naval_Attack_Chain',
                },
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('StratBombers', 4)

    quantity = {6, 9, 12}
    trigger = {10, 11, 12}
    opai = AeonM3Base:AddOpAI('AirAttacks', 'M3_Aeon_Base_AirAttack_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M3_Aeon_Naval_Attack_Chain',
                    'M3_Land_Attack_Chain_2',
                    'M1_UEF_Naval_Attack_Chain',
                },
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE, '>='})
end

function AeonM3BaseLandAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    -- Attack Control Center
    quantity = {8, 10, 12}
    opai = AeonM3Base:AddOpAI('BasicLandAttack', 'M3_Aeon_LandAttack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M3_Land_Attack_Chain_1',
                    'M3_Land_Attack_Chain_2',
                    'M3_Land_Attack_Chain_3',
                },
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('HeavyTanks', quantity[Difficulty])

    quantity = {6, 9, 12}
    opai = AeonM3Base:AddOpAI('BasicLandAttack', 'M3_Aeon_LandAttack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M3_Land_Attack_Chain_1',
                    'M3_Land_Attack_Chain_2',
                    'M3_Land_Attack_Chain_3',
                },
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('MobileMissiles', quantity[Difficulty])
    
    quantity = {4, 6, 10}
    opai = AeonM3Base:AddOpAI('BasicLandAttack', 'M3_Aeon_LandAttack_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M3_Land_Attack_Chain_1',
                    'M3_Land_Attack_Chain_2',
                    'M3_Land_Attack_Chain_3',
                },
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('SiegeBots', quantity[Difficulty])

    quantity = {4, 6, 8}
    opai = AeonM3Base:AddOpAI('BasicLandAttack', 'M3_Aeon_LandAttack_4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M3_Land_Attack_Chain_1',
                    'M3_Land_Attack_Chain_2',
                    'M3_Land_Attack_Chain_3',
                },
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('HeavyMobileArtillery', quantity[Difficulty])

    --------
    -- Drops
    --------
    quantity = {6, 8, 12}
    for i = 1, 2 do
        opai = AeonM3Base:AddOpAI('BasicLandAttack', 'M3_Aeon_Drop_1_' .. i,
            {
                MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
                PlatoonData = {
                    AttackChain = 'Player_Base_Chain',
                    MovePath = 'M3_Aeon_Drop_Move_Chain_' .. i,
                    LandingChain = 'Player_Base_Landing_Chain',
                },
                Priority = 200,
            }
        )
        opai:SetChildQuantity('SiegeBots', quantity[Difficulty])
        opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
            'HaveGreaterThanUnitsWithCategory', {'default_brain', 6, categories.uaa0104})
        opai:SetLockingStyle('DeathTimer', {LockTimer = 240})
    end
end

---------------------
-- Aeon M3 Naval Base
---------------------
function AeonM3NavalBaseAI()
    AeonM3NavalBase:InitializeDifficultyTables(ArmyBrains[Aeon], 'M3_Aeon_Naval_Base', 'M3_Aeon_Naval_Base_Marker', 70, {M3_Naval_Base = 100})
    AeonM3NavalBase:StartNonZeroBase({{3, 4, 5}, {3, 3, 4}})
    AeonM3NavalBase:AddBuildGroup('M3_Naval_Base_Support_Factories', 100, true)

    AeonM3NavalBaseNavalAttacks()
end

function AeonM3NavalBaseNavalAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    quantity = {{3, 3}, {6, 3}, {12, 6}}
    opai = AeonM3NavalBase:AddOpAI('NavalAttacks', 'M3_Aeon_NavalAttack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChain = {
                    'M1_UEF_Naval_Attack_Chain',
                    'M3_Aeon_Naval_Attack_Chain',
                },
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'Frigates', 'Submarines'}, quantity[Difficulty])

    opai = AeonM3NavalBase:AddOpAI('NavalAttacks', 'M3_Aeon_NavalAttack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChain = {
                    'M1_UEF_Naval_Attack_Chain',
                    'M3_Aeon_Naval_Attack_Chain',
                },
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'Destroyers', 'Frigates'}, {3, 6})

    quantity = {{2, 1}, {3, 1, 4}, {4, 2, 6}}
    opai = AeonM3NavalBase:AddOpAI('NavalAttacks', 'M3_Aeon_NavalAttack_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChain = {
                    'M1_UEF_Naval_Attack_Chain',
                    'M3_Aeon_Naval_Attack_Chain',
                },
            },
            Priority = 120,
        }
    )
    if Difficulty >= 2 then
        opai:SetChildQuantity({'Destroyers', 'Cruisers', 'Submarines'}, quantity[Difficulty])
    else
        opai:SetChildQuantity({'Destroyers', 'Cruisers'}, quantity[Difficulty])
    end
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, 3, categories.NAVAL * categories.MOBILE - categories.TECH1, '>='})

    opai = AeonM3NavalBase:AddOpAI('NavalAttacks', 'M3_Aeon_NavalAttack_4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChain = {
                    'M1_UEF_Naval_Attack_Chain',
                    'M3_Aeon_Naval_Attack_Chain',
                },
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity({'Battleships', 'Destroyers'}, {1, 4})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, 6, categories.NAVAL * categories.MOBILE - categories.TECH1, '>='})

    opai = AeonM3NavalBase:AddOpAI('NavalAttacks', 'M3_Aeon_NavalAttack_5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChain = {
                    'M1_UEF_Naval_Attack_Chain',
                    'M3_Aeon_Naval_Attack_Chain',
                },
            },
            Priority = 140,
        }
    )
    opai:SetChildQuantity('Battleships', 3)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, 2, categories.NAVAL * categories.MOBILE * categories.TECH3, '>='})

    -- Sonar around the base
    opai = AeonM3NavalBase:AddOpAI('Sonar',
        {
            Amount = 1,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Aeon_Sonar_Chain',
            },
            MaxAssist = 1,
            Retry = true,
        }
    )
end

----------------------
-- Aeon M3 Island Base
----------------------
function AeonM3IslandBaseAI()
    AeonM3IslandBase:InitializeDifficultyTables(ArmyBrains[Aeon], 'M3_Aeon_Island_Base', 'Experimental_Island', 50, {M3_Island_Defenses = 100})
    AeonM3IslandBase:StartNonZeroBase({3, 4, 5})
    AeonM3IslandBase:SetDefaultEngineerPatrolChain('M3_Island_Patrol')

    AeonM3IslandBaseExperimentals()
end

function AeonM3IslandBaseExperimentals()
    local opai = nil

    opai = AeonM3IslandBase:AddOpAI('M3_Island_GC',
        {
            Amount = 1,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            MaxAssist = 2 + Difficulty,
            Retry = true,
        }
    )

    opai = AeonM3IslandBase:AddOpAI('M3_Island_Tempest',
        {
            Amount = 1,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            MaxAssist = 2 + Difficulty,
            Retry = true,
        }
    )

    opai = AeonM3IslandBase:AddOpAI('M3_Island_CZAR',
        {
            Amount = 1,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            MaxAssist = 2 + Difficulty,
            Retry = true,
        }
    )
end

