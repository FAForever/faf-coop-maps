local BaseManager = import('/lua/ai/opai/basemanager.lua')
local CustomFunctions = '/maps/NovaxStationAssault/NovaxStationAssault_CustomFunctions.lua'
-- local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local SPAIFileName = '/lua/ScenarioPlatoonAI.lua'

---------
-- Locals
---------
local Cybran = 4
local Difficulty = ScenarioInfo.Options.Difficulty

----------------
-- Base Managers
----------------
local CybranM2Base = BaseManager.CreateBaseManager()
local CybranM2IslandBase = BaseManager.CreateBaseManager()

----------------------
-- Cybran M2 Main Base
----------------------
function CybranM2BaseAI()
    CybranM2Base:InitializeDifficultyTables(ArmyBrains[Cybran], 'M2_Cybran_Base', 'M2_Cybran_Base_Marker', 100, {M2_Cybran_Base = 100})
    CybranM2Base:StartNonZeroBase({{10, 13, 16}, {8, 10, 12}})
    CybranM2Base:SetMaximumConstructionEngineers(4)
    
    CybranM2Base:SetActive('AirScouting', true)

    -- Spawn support factories a bit later, else they sometimes bug out and can't build higher tech units.
    ForkThread(function()
        WaitSeconds(1)
        CybranM2Base:AddBuildGroupDifficulty('M2_Cybran_Base_Support_Factories', 100, true)
    end)

    CybranM2BaseAirAttacks()
    CybranM2BaseLandAttacks()
    CybranM2BaseNavalAttacks()
end

function CybranM2BaseAirAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    -- M2_Cybran_Base_AirDeffense_Chain
    -- M2_Cybran_Base_AirAttack_Chain_1
    -- M2_Cybran_Base_AirAttack_Chain_2
    -- M2_Cybran_Base_AirAttack_Chain_3

    -- Transport builder
    opai = CybranM2Base:AddOpAI('EngineerAttack', 'M2_Cybran_TransportBuilder',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                TransportReturn = 'M2_Cybran_Base_Transport_Return',
            },
            Priority = 1000,
        }
    )
    opai:SetChildQuantity('T2Transports', 6)
    opai:SetLockingStyle('None')
    opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
        'HaveLessThanUnitsWithCategory', {'default_brain', 4, categories.ura0104})

    -- T1 Bombers
    quantity = {4, 6, 8}
    trigger = {24, 17, 10}
    opai = CybranM2Base:AddOpAI('AirAttacks', 'M2_Cybran_Base_AirAttack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Cybran_Base_AirAttack_Chain_1',
                                'M2_Cybran_Base_AirAttack_Chain_2',
                                'M2_Cybran_Base_AirAttack_Chain_3'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Bombers', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers', 'Order'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL, '>='})

    -- T1 Bombers
    quantity = {4, 6, 8}
    trigger = {34, 27, 20}
    opai = CybranM2Base:AddOpAI('AirAttacks', 'M2_Cybran_Base_AirAttack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Cybran_Base_AirAttack_Chain_1',
                                'M2_Cybran_Base_AirAttack_Chain_2',
                                'M2_Cybran_Base_AirAttack_Chain_3'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Bombers', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers', 'Order'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL, '>='})


    -- T2 Gunships
    quantity = {8, 10, 12}
    trigger = {50, 40, 30}
    opai = CybranM2Base:AddOpAI('AirAttacks', 'M2_Cybran_Base_AirAttack_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Cybran_Base_AirAttack_Chain_1',
                                'M2_Cybran_Base_AirAttack_Chain_2',
                                'M2_Cybran_Base_AirAttack_Chain_3'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers', 'Order'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL, '>='})

    -- T2 Gunships
    quantity = {8, 10, 12}
    trigger = {65, 55, 45}
    opai = CybranM2Base:AddOpAI('AirAttacks', 'M2_Cybran_Base_AirAttack_4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Cybran_Base_AirAttack_Chain_1',
                                'M2_Cybran_Base_AirAttack_Chain_2',
                                'M2_Cybran_Base_AirAttack_Chain_3'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers', 'Order'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL, '>='})

    -- T2 Gunshhips
    quantity = {8, 10, 12}
    trigger = {90, 75, 60}
    opai = CybranM2Base:AddOpAI('AirAttacks', 'M2_Cybran_Base_AirAttack_8',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Cybran_Base_AirAttack_Chain_1',
                                'M2_Cybran_Base_AirAttack_Chain_2',
                                'M2_Cybran_Base_AirAttack_Chain_3'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers', 'Order'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL, '>='})

    -- Torpedo Bombers
    quantity = {6, 8, 10}
    trigger = {7, 5, 3}
    opai = CybranM2Base:AddOpAI('AirAttacks', 'M2_Cybran_Base_AirAttack_6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Cybran_Base_AirAttack_Chain_1',
                                'M2_Cybran_Base_AirAttack_Chain_2',
                                'M2_Cybran_Base_AirAttack_Chain_3'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('TorpedoBombers', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers', 'Order'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE - categories.TECH1, '>='})

    -- Torpedo bombers
    quantity = {6, 8, 10}
    trigger = {10, 8, 6}
    opai = CybranM2Base:AddOpAI('AirAttacks', 'M2_Cybran_Base_AirAttack_7',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Cybran_Base_AirAttack_Chain_1',
                                'M2_Cybran_Base_AirAttack_Chain_2',
                                'M2_Cybran_Base_AirAttack_Chain_3'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('TorpedoBombers', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers', 'Order'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE - categories.TECH1, '>='})

    -- Air Defense
    -- Gunships
    quantity = {4, 5, 6}
    for i = 1, 2 do
        opai = CybranM2Base:AddOpAI('AirAttacks', 'M2_Cybran_Base_AirDefense_1_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M2_Cybran_Base_AirDeffense_Chain',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('Gunships', quantity[Difficulty])
        opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    end

    -- Interceptors
    for i = 1, 2 + Difficulty do
        opai = CybranM2Base:AddOpAI('AirAttacks', 'M2_Cybran_Base_AirDefense_2_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M2_Cybran_Base_AirDeffense_Chain',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('Interceptors', 3)
        opai:SetLockingStyle('DeathRatio', {Ratio = 0.6})
    end

    -- Torpedo bombers
    quantity = {3, 4, 5}
    for i = 1, 2 do
        opai = CybranM2Base:AddOpAI('AirAttacks', 'M2_Cybran_Base_AirDefense_3_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M2_Cybran_Base_AirDeffense_Chain',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('TorpedoBombers', quantity[Difficulty])
        opai:SetLockingStyle('DeathRatio', {Ratio = 0.6})
    end

    -- ASFs
    --[[
    if Difficulty == 3 then
        opai = CybranM2Base:AddOpAI('AirAttacks', 'M2_Cybran_Base_AirDefense_4',
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M2_Cybran_Base_AirDeffense_Chain',
                },
                Priority = 110,
            }
        )
        opai:SetChildQuantity('AirSuperiority', 4)
        opai:SetLockingStyle('DeathRatio', {Ratio = 0.6})
    end
    ]]--
end

-- Targets the tempest
function CybranM2TorpBombersSnipe()
    -- Torpedo bombers
    quantity = {8, 10, 12}
    opai = CybranM2Base:AddOpAI('AirAttacks', 'M2_Cybran_Base_AirSnipe_1',
        {
            MasterPlatoonFunction = { '/lua/ScenarioPlatoonAI.lua', 'CategoryHunterPlatoonAI' },
            PlatoonData = {
                CategoryList = { categories.uas0401 },
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('TorpedoBombers', quantity[Difficulty])
    opai:SetLockingStyle('DeathTimer', {LockTimer = 3*60})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers', 'Order'}, 1, categories.uas0401, '>='})
end

function CybranM2BaseLandAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    -- M2_Cybran_Base_Amph_Attack_Chain_1
    -- M2_Cybran_Base_Amph_Attack_Chain_2

    quantity = {8, 10, 12}
    trigger = {90, 70, 50}
    opai = CybranM2Base:AddOpAI('BasicLandAttack', 'M2_Cybran_Base_Amphibious_Attack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Cybran_Base_Amph_Attack_Chain_1', 'M2_Cybran_Base_Amph_Attack_Chain_2'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('AmphibiousTanks', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers', 'Order'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL, '>='})

    quantity = {12, 16, 20}
    trigger = {100, 85, 70}
    opai = CybranM2Base:AddOpAI('BasicLandAttack', 'M2_Cybran_Base_Amphibious_Attack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Cybran_Base_Amph_Attack_Chain_1', 'M2_Cybran_Base_Amph_Attack_Chain_2'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('AmphibiousTanks', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers', 'Order'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL, '>='})

    --------
    -- Drops
    --------
    -- T2 Tanks
    quantity = {4, 8, 12}
    trigger = {{180, 160, 140}, {160, 140, 120}}
    for i = 1, 2 do
        opai = CybranM2Base:AddOpAI('BasicLandAttack', 'M2_Cybran_TransportAttack_1_' .. i,
            {
                MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
                PlatoonData = {
                    AttackChain = 'M2_Player_Island_Drop_Chain',
                    LandingList = {'M2_Drop_Marker_' .. i .. '_1', 'M2_Drop_Marker_' .. i .. '_2'},
                    MovePath = 'M2_Cybran_Base_Transport_Chain_' .. i,
                    --TransportReturn = 'M2_Cybran_Base_Marker', -- Removed until transport return function is fixed
                },
                Priority = 140,
            }
        )
        opai:SetChildQuantity('HeavyTanks', quantity[Difficulty])
        opai:SetLockingStyle('DeathTimer', {LockTimer = 120})
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
            'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers', 'Order'}, trigger[i][Difficulty], categories.ALLUNITS - categories.WALL, '>='})
    end

    -- Loyalists
    quantity = {2, 4, 6}
    trigger = {7, 6, 5}
    for i = 1, 2 do
        opai = CybranM2Base:AddOpAI('BasicLandAttack', 'M2_Cybran_TransportAttack_2_' .. i,
            {
                MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
                PlatoonData = { 
                    AttackChain = 'M2_Player_Island_Drop_Chain',
                    LandingList = {'M2_Drop_Marker_' .. i .. '_1', 'M2_Drop_Marker_' .. i .. '_2'},
                    MovePath = 'M2_Cybran_Base_Transport_Chain_' .. i,
                    --TransportReturn = 'M2_Cybran_Base_Marker', -- Removed until transport return function is fixed
                },
                Priority = 150,
            }
        )
        opai:SetChildQuantity('SiegeBots', quantity[Difficulty])
        opai:SetLockingStyle('DeathTimer', {LockTimer = 60})
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
            'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers', 'Order'}, trigger[Difficulty], categories.FACTORY * categories.TECH3, '>='})
    end
end

function CybranM2BaseNavalAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    quantity = {4, 6, 8}
    for i = 1, 2 do
        opai = CybranM2Base:AddNavalAI('M2_Cybran_Naval_Attack_1_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M2_Cybran_Base_NavalAttack_Chain_' .. i,
                },
                EnabledTypes = {'Submarine'},
                MaxFrigates = quantity[Difficulty],
                MinFrigates = quantity[Difficulty],
                Priority = 100,
                Overrides = {
                    CORE_TO_SUBS = 2,
                }
            }
        )
        opai:SetChildActive('T2', false)
        opai:SetChildActive('T3', false)
        opai:SetFormation('AttackFormation')
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
            'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers', 'Order'}, 1, categories.NAVAL * categories.FACTORY * categories.STRUCTURE, '>='})
    end

    quantity = {20, 25, 30}
    trigger = {6, 5, 4}
    opai = CybranM2Base:AddNavalAI('M2_Cybran_Naval_Attack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Cybran_Base_NavalAttack_Chain_1',
                                'M2_Cybran_Base_NavalAttack_Chain_2'},
            },
            EnabledTypes = {'Destroyer', 'Submarine'},
            MaxFrigates = quantity[Difficulty],
            MinFrigates = quantity[Difficulty],
            Priority = 110,
            Overrides = {
                CORE_TO_SUBS = 3,
            }
        }
    )
    opai:SetChildActive('T3', false)
    opai:SetFormation('AttackFormation')
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers', 'Order'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE - categories.TECH1, '>='})

    quantity = {9, 14, 19}
    trigger = {10, 8, 6}
    for i = 1, 2 do
        opai = CybranM2Base:AddNavalAI('M2_Cybran_Naval_Attack_3_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M2_Cybran_Base_NavalAttack_Chain_' .. i,
                },
                MaxFrigates = quantity[Difficulty],
                MinFrigates = quantity[Difficulty],
                Priority = 120,
                Overrides = {
                    CORE_TO_CRUISERS = 1.5,
                    CORE_TO_SUBS = 1,
                }
            }
        )
        opai:SetChildActive('T3', false)
        opai:SetFormation('AttackFormation')
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
            'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers', 'Order'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE - categories.TECH1, '>='})
    end

    quantity = {25, 35, 45}
    for i = 1, 2 do
        opai = CybranM2Base:AddNavalAI('M2_Cybran_Naval_Attack_4_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M2_Cybran_Base_NavalAttack_Chain_' .. i,
                },
                MaxFrigates = quantity[Difficulty],
                MinFrigates = quantity[Difficulty],
                Priority = 130,
                Overrides = {
                    CORE_TO_CRUISERS = 0.25,
                    CORE_TO_SUBS = 0.5,
                    CORE_TO_UTILITY = 2,
                }
            }
        )
        opai:SetChildActive('T1', false)
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
            'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers', 'Order'}, 2, categories.BATTLESHIP, '>='})
    end

    quantity = {20, 25, 30}
    trigger = {60, 45, 30}
    opai = CybranM2Base:AddNavalAI('M2_Cybran_Naval_Attack_5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M2_Cybran_Base_NavalAttack_Chain_1',
                    'M2_Cybran_Base_NavalAttack_Chain_2',
                },
            },
            EnabledTypes = {'Cruiser', 'Submarine'},
            MaxFrigates = quantity[Difficulty],
            MinFrigates = quantity[Difficulty],
            Priority = 140,
            Overrides = {
                CORE_TO_CRUISERS = 1,
                CORE_TO_SUBS = 1,
            }
        }
    )
    opai:SetChildActive('T1', false)
    opai:SetChildActive('T2', false)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers', 'Order'}, trigger[Difficulty], categories.AIR * categories.MOBILE * categories.ANTIAIR - categories.TECH1, '>='})

    -- Sonar
    opai = CybranM2Base:AddOpAI('M2_Cybran_Base_Sonar',
        {
            Amount = 1,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Cybran_Base_Sonar_Chain',
            },
            MaxAssist = 1,
            Retry = true,
        }
    )
end

------------------------
-- Cybran M2 Island Base
------------------------
function CybranM2IslandBaseAI(baseType)
    if baseType == 'Naval' then
        -- Naval Base
        CybranM2IslandBase:InitializeDifficultyTables(ArmyBrains[Cybran], 'M2_Cybran_Island_Base', 'M2_Cybran_Island_Base_Marker', 80,
            {
                M2_Cybran_Island_Naval_Base = 100,
                M2_Cybran_Island_Mass = 100,
                M2_Cybran_Island_Defense = 100,
            }
        )
        CybranM2IslandBase:StartNonZeroBase({{4, 5, 6}, {3, 4, 4}})

        ForkThread(function()
            WaitSeconds(1)
            CybranM2IslandBase:AddBuildGroupDifficulty('M2_Cybran_Island_Naval_Base_Support_Factories', 100, true)
        end)

        CybranM2IslandBaseNavalAttacks()

    elseif baseType == 'Arty' then 
        -- T3 Arty Base
        CybranM2IslandBase:InitializeDifficultyTables(ArmyBrains[Cybran], 'M2_Cybran_Island_Base', 'M2_Cybran_Island_Base_Marker', 30,
            {
                M2_Cybran_Island_Arty_Base = 100,
                M2_Cybran_Island_Mass = 100,
                M2_Cybran_Island_Defense = 100,
            }
        )
        CybranM2IslandBase:StartNonZeroBase({1, 2, 3})

        ForkThread(CybranM2IslandBaseArtyAI)

    elseif baseType == 'Eco' or baseType == 'Air' then
        -- Economy Base, spawn carriers if 'Air' base
        CybranM2IslandBase:InitializeDifficultyTables(ArmyBrains[Cybran], 'M2_Cybran_Island_Base', 'M2_Cybran_Island_Base_Marker', 30,
            {
                M2_Cybran_Island_Mass = 100,
                M2_Cybran_Island_Eco = 100,
            }
        )
        CybranM2IslandBase:StartNonZeroBase(1)
        CybranM2Base:AddExpansionBase('M2_Cybran_Island_Base', 1)
    
        if baseType == 'Air' then
            CybranM2IslandBaseCarrierAttacks()
        end
    else
        WARN('CybranM2IslandBase: baseType: ' .. baseType  .. ' NOT DEFINED')
    end
end

-- Island Naval Attacks
function CybranM2IslandBaseNavalAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    quantity = {2, 4, 6}
    trigger = {11, 8, 6}
    opai = CybranM2IslandBase:AddNavalAI('M2_Cybran_Island_Naval_Attack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Cybran_Island_Naval_Attack_Chain_1',
                               'M2_Cybran_Island_Naval_Attack_Chain_2'}
            },
            EnabledTypes = {'Submarine'},
            MaxFrigates = quantity[Difficulty],
            MinFrigates = quantity[Difficulty],
            Priority = 100,
            Overrides = {
                CORE_TO_SUBS = 2,
            }
        }
    )
    opai:SetChildActive('T2', false)
    opai:SetChildActive('T3', false)
    opai:SetFormation('AttackFormation')
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers', 'Order'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE, '>='})

    quantity = {4, 4, 6}
    trigger = {19, 15, 11}
    opai = CybranM2IslandBase:AddNavalAI('M2_Cybran_Island_Naval_Attack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Cybran_Island_Naval_Attack_Chain_1',
                               'M2_Cybran_Island_Naval_Attack_Chain_2'}
            },
            EnabledTypes = {'Submarine'},
            MaxFrigates = quantity[Difficulty],
            MinFrigates = quantity[Difficulty],
            Priority = 110,
            Overrides = {
                CORE_TO_SUBS = 2,
            }
        }
    )
    opai:SetChildActive('T2', false)
    opai:SetChildActive('T3', false)
    opai:SetFormation('AttackFormation')
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers', 'Order'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE, '>='})

    quantity = {10, 12, 14}
    trigger = {13, 10, 7}
    opai = CybranM2IslandBase:AddNavalAI('M2_Cybran_Island_Naval_Attack_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Cybran_Island_Naval_Attack_Chain_1',
                               'M2_Cybran_Island_Naval_Attack_Chain_2'}
            },
            EnabledTypes = {'Destroyer', 'Submarine'},
            MaxFrigates = quantity[Difficulty],
            MinFrigates = quantity[Difficulty],
            Priority = 120,
        }
    )
    opai:SetChildActive('T3', false)
    opai:SetFormation('AttackFormation')
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers', 'Order'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE * categories.TECH2, '>='})
end

-- Island Carrier Attacks
function CybranM2IslandBaseCarrierAttacks()
    local quantity = {}
    local trigger = {}

    -- Initiate build locations
    for i = 1, 2 do
        ArmyBrains[Cybran]:PBMAddBuildLocation('M2_Cybran_Carrier_Marker_' .. i, 40, 'M2_Cybran_Carrier_' .. i)
    end

    -- Spawn carriers
    -- ScenarioUtils.CreateArmyGroup('Cybran', 'M2_Cybran_Carriers') -- TODO: Delete if M2CybranIslandUnits() in the script works

    -- Build units
    -- Carrier 1
    quantity = {4, 6, 8}
    trigger = {50, 45, 40}
    local Temp = {
        'M2_Cybran_Carrier1_Air_Attack_1',
        'NoPlan',
        { 'ura0203', 1, quantity[Difficulty], 'Attack', 'AttackFormation' }, -- T2 Gunship
    }
    local Builder = {
        BuilderName = 'M2_Cybran_Carrier1_Air_Builder_1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'M2_Cybran_Carrier_1',
        BuildConditions = {
            { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
                {'default_brain', {'HumanPlayers', 'Order'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL, '>='}},
        },
        PlatoonAIFunction = {CustomFunctions, 'PatrolThread'},       
        PlatoonData = {
            PatrolChain = 'M2_Cybran_Island_AirAttack_Chain_1',
        },
    }
    ArmyBrains[Cybran]:PBMAddPlatoon( Builder )

    -- Carrier 2
    quantity = {4, 6, 8}
    trigger = {20, 15, 10}
    Temp = {
        'M2_Cybran_Carrier2_Air_Attack_1',
        'NoPlan',
        { 'ura0204', 1, quantity[Difficulty], 'Attack', 'AttackFormation' }, -- T2 Torp Bomber
    }
    Builder = {
        BuilderName = 'M2_Cybran_Carrier2_Air_Builder_1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'M2_Cybran_Carrier_2',
        BuildConditions = {
            { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
                {'default_brain', {'HumanPlayers', 'Order'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE - categories.TECH1, '>='}},
        },
        PlatoonAIFunction = {CustomFunctions, 'PatrolThread'},       
        PlatoonData = {
            PatrolChain = 'M2_Cybran_Island_AirAttack_Chain_2',
        },
    }
    ArmyBrains[Cybran]:PBMAddPlatoon( Builder )
end

-- Island Arty AI
function CybranM2IslandBaseArtyAI()
    -- TODO: Use grab from area instead
    local arty = ArmyBrains[Cybran]:GetListOfUnits(categories.ARTILLERY * categories.TECH3, false)[1]

    if not arty then
        return
    end

    arty:SetFireState('HoldFire')

    local waitTime = {Random(26.0, 30.0), Random(22.0, 26.0), Random(18.0, 22.0)}
    LOG('*speed2: Arty activation wait time: ' .. waitTime[Difficulty])
    WaitSeconds(waitTime[Difficulty] * 60.0)

    arty:SetFireState('Aggressive') -- ReturnFire -- HoldGround -- GroundFire
end