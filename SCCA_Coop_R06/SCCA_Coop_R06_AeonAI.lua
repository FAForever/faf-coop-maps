local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/ScenarioPlatoonAI.lua'

---------
-- Locals
---------
local Aeon = 2
local Difficulty = ScenarioInfo.Options.Difficulty

----------------
-- Base Managers
----------------
local AeonBase = BaseManager.CreateBaseManager()

-----------------
-- Aeon Main Base
-----------------
function AeonBaseAI()
    AeonBase:InitializeDifficultyTables(ArmyBrains[Aeon], 'Aeon_Main_Base', 'Aeon_Main_Base_Marker', 200, {Aeon_Main_Base = 100})
    AeonBase:StartNonZeroBase({{10, 20, 30}, {8, 17, 27}})
    AeonBase:SetMaximumConstructionEngineers(3)

    AeonBase:AddBuildGroupDifficulty('Aeon_Main_Base_Extra', 90)
    
    AeonBase:SetActive('AirScouting', true)
    AeonBase:SetActive('LandScouting', true)

    M1AeonBaseAirAttacks()
    M1AeonBaseLandAttacks()
    M1AeonBaseNavalAttacks()
end

function M1AeonBaseAirAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    -- 4 factories

    -- Transport builder
    opai = AeonBase:AddOpAI('EngineerAttack', 'Aeon_TransportBuilder',
        {
            MasterPlatoonFunction = {SPAIFileName, 'TransportPool'},
            PlatoonData = {
                TransportMoveLocation = 'Rally Point Aeon Air',
            },
            Priority = 1000,
        }
    )
    opai:SetChildQuantity('T2Transports', 4)
    opai:SetLockingStyle('None')
    opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
        'HaveLessThanUnitsWithCategory', {'default_brain', 6, categories.uaa0104})

    opai = AeonBase:AddOpAI('AirAttacks', 'Aeon_To_Player_AirAttack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'PlayerAirAttack_Chain',
                },
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'StratBombers', 'Gunships', 'Bombers'}, {4, 8, 16})

    opai = AeonBase:AddOpAI('AirAttacks', 'Aeon_To_Player_AirAttack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'PlayerAirAttack_Chain',
                },
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'AirSuperiority', 'Gunships', 'Interceptors'}, {8, 8, 16})
end

function M1AeonBaseLandAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    -- 2 factories

    -- Engineer for reclaiming if there's less than 2000 Mass in the storage, starting after 5 minutes
    quantity = {4, 6, 10}
    opai = AeonBase:AddOpAI('EngineerAttack', 'M1_Aeon_Reclaim_Engineers_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
            PlatoonData = {
                PatrolChain = 'Aeon_Chain',
            },
            Priority = 200,
        }
    )
    opai:SetChildQuantity('T1Engineers', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/economybuildconditions.lua', 'LessThanMassStorageCurrent', {'default_brain', 2000})

    --------
    -- Drops
    --------
    if false then
        quantity = {6, 8, 10}
        --trigger = {{180, 160, 140}, {160, 140, 120}}
        opai = AeonBase:AddOpAI('BasicLandAttack', 'Aeon_TransportAttack_1',
            {
                MasterPlatoonFunction = {SPAIFileName, 'LandAssaultWithTransports'},
                PlatoonData = {
                    AttackChain = 'Aeon_AttackChain',
                    LandingChain = 'Aeon_LandingChain',
                    TransportReturn = 'Rally Point Aeon Air', -- Removed until transport return function is fixed
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('HeavyTanks', quantity[Difficulty])
        --opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        --    'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers', 'Order'}, trigger[i][Difficulty], categories.ALLUNITS - categories.WALL, '>='})
    end

    if false then
        quantity = {3, 6, 8}
        --trigger = {{180, 160, 140}, {160, 140, 120}}
        opai = AeonBase:AddOpAI('BasicLandAttack', 'Aeon_TransportAttack_2',
            {
                MasterPlatoonFunction = {SPAIFileName, 'LandAssaultWithTransports'},
                PlatoonData = {
                    AttackChain = 'Aeon_AttackChain',
                    LandingChain = 'Aeon_LandingChain',
                    TransportReturn = 'Rally Point Aeon Air',
                },
                Priority = 150,
            }
        )
        opai:SetChildQuantity('SiegeBots', quantity[Difficulty])
        opai:SetLockingStyle('DeathTimer', {LockTimer = 120})
        --opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        --    'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers', 'Order'}, trigger[i][Difficulty], categories.ALLUNITS - categories.WALL, '>='})
        opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
            'HaveGreaterThanUnitsWithCategory', {'default_brain', math.ceil(quantity[Difficulty] / 2), categories.uaa0104})
    end

    -- drop 2x harb, T3 arty, shield, flak, obsidian
    local Builder = {
        BuilderName = 'Aeon_TransportAttack_3',
        PlatoonTemplate = {
            'Aeon_TransportAttack_Template_3',
            'NoPlan',
            {'ual0303', 1, 2, 'Attack', 'GrowthFormation'},    -- T3 Titans
            {'ual0304', 1, 2, 'Artillery', 'AttackFormation'}, -- T3 Arty
            {'ual0202', 1, 2, 'Attack', 'GrowthFormation'},    -- T2 Tank
            {'ual0205', 1, 2, 'Attack', 'GrowthFormation'},    -- T2 Flak
            {'ual0307', 1, 2, 'Attack', 'GrowthFormation'},    -- T2 Mobile Shield
        },
        InstanceCount = 1,
        Priority = 250,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'Aeon_Main_Base',
        BuildConditions = {
        --    { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        --        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.LAND * categories.MOBILE, '>='}},
            {'/lua/editor/BaseManagerBuildConditions.lua', 'BaseActive', {'Aeon_Main_Base'}},
        },
        PlatoonAIFunction = {SPAIFileName, 'LandAssaultWithTransports'},       
        PlatoonData = {
            AttackChain = 'Aeon_AttackChain',
            LandingChain = 'Aeon_LandingChain',
            TransportReturn = 'Rally Point Aeon Air',
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon(Builder)
end

function M1AeonBaseNavalAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    -- 2, 4, 6 factories

    opai = AeonBase:AddOpAI('NavalAttacks', 'Aeon_To_Players_NavalAttack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'PlayerNavalAttack_Chain',
                },
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'Battleships', 'Destroyers', 'Cruisers', 'Frigates', 'Submarines'}, {1, 2, 2, 2, 18})

    -- Sonar in the base
    opai = AeonBase:AddOpAI('Aeon_T3_Sonar',
        {
            Amount = 1,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'Aeon_Sonar_Patrol_Chain',
            },
            MaxAssist = 3,
            Retry = true,
        }
    )
end

function M2AeonBaseNavalAttacks()
    local opai = AeonBase:AddOpAI('M2_Attack_Tempest',
        {
            Amount = 1,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'PlayerNavalAttack_Chain',
            },
            MaxAssist = 3,
            Retry = true,
            WaitSecondsAfterDeath = 180,
        }
    )
end

function StartBuildingGCs()
    local opai = nil
    local quantity = {}

    -- GCs to guard the base
    quantity = {1, 1, 2}
    opai = AeonBase:AddOpAI('M2_Defense_GC',
        {
            Amount = quantity[Difficulty],
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
            PlatoonData = {
                PatrolChain = 'Aeon_Base_Land_Patrol_Chain',
            },
            MaxAssist = 3,
            Retry = true,
        }
    )

    -- GCs to attack the player
    opai = AeonBase:AddOpAI('M2_Attack_GC',
        {
            Amount = 1,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'Aeon_AttackChain',
            },
            MaxAssist = 3,
            Retry = true,
            WaitSecondsAfterDeath = 120,
        }
    )
end

function StartBuildingCZARs()
    -- CZAR
    opai = AeonBase:AddOpAI('Czar',
        {
            Amount = 1,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'Aeon_AttackChain',
            },
            MaxAssist = 3,
            Retry = true,
            WaitSecondsAfterDeath = 180,
        }
    )
end

--M2_Attack_GC M2_Attack_Tempest, CZAR