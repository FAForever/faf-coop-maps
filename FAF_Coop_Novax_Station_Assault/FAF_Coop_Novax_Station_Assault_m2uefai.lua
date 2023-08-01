--#####################################################################
--###                       ### UEF Base ###                        ###
--#####################################################################
--# Available Chain
--# Air:
--# {'M2_UEF_Base_AirDef_Chain'}
--#
--# Naval:
--# 1, 2 goes to the left; 3, 4 to the right
--# {'M2_UEF_Base_NavalAttack_Chain_1', 'M2_UEF_Base_NavalAttack_Chain_2', 'M2_UEF_Base_NavalAttack_Chain_3', 'M2_UEF_Base_NavalAttack_Chain_4'},
--#
--# {'M2_UEF_Base_NavalDefense_Chain_1', 'M2_UEF_Base_NavalDefense_Chain_2'},
--#####################################################################
--#
--#####################################################################
--#                 UEF Naval Unit IDs
--# { 'ues0103', 1, 1, 'Attack', 'AttackFormation' },  -- Frigate
--# { 'ues0203', 1, 1, 'Attack', 'AttackFormation' },  -- Submarine
--# { 'ues0201', 1, 1, 'Attack', 'AttackFormation' },  -- Destroyer
--# { 'ues0202', 1, 1, 'Attack', 'AttackFormation' },  -- Cruise
--# { 'xes0102', 1, 1, 'Attack', 'AttackFormation' },  -- Torp Boat
--# { 'xes0205', 1, 1, 'Attack', 'AttackFormation' },  -- Shield Boat
--# { 'ues0302', 1, 1, 'Attack', 'AttackFormation' },  -- Battleship
--# { 'ues0304', 1, 1, 'Attack', 'AttackFormation' },  -- Nuke Sub
--# { 'xes0307', 1, 1, 'Attack', 'AttackFormation' },  -- Battlecruiser
--#####################################################################

local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/ScenarioPlatoonAI.lua'
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')

---------
-- Locals
---------
local UEF = 2
local Difficulty = ScenarioInfo.Options.Difficulty

----------------
-- Base Managers
----------------
local UEFM2Base = BaseManager.CreateBaseManager()
local UEFM2IslandBase = BaseManager.CreateBaseManager()

-------------------
-- UEF M2 Main Base
-------------------
function UEFM2BaseAI()
    UEFM2Base:InitializeDifficultyTables(ArmyBrains[UEF], 'M2_UEF_Base', 'M2_UEF_Base_Marker', 160, {M2_UEF_Base = 100,})
    UEFM2Base:StartNonZeroBase({{11, 14, 17}, {9, 11, 13}})
    UEFM2Base:SetMaximumConstructionEngineers(4)
    
    UEFM2Base:SetActive('AirScouting', true)
    -- UEFM2Base:SetSupportACUCount(1)
    -- UEFM2Base:SetSACUUpgrades({'ResourceAllocation', 'RadarJammer', 'SensorRangeEnhancer'}, true)

    UEFM2BaseLandAttacks()
    UEFM2BaseAirAttacks()
    UEFM2BaseNavalAttacks()
end

function UEFM2BaseAirAttacks()
    local DefaultPatrolChains = {
        'M2_UEF_Base_AirAttack_Chain_1',
        'M2_UEF_Base_AirAttack_Chain_2',
        'M2_UEF_Base_AirAttack_Chain_3',
    }

    local opai = nil
    local quantity = {}
    local trigger = {}

    -- Transport Builder
    opai = UEFM2Base:AddOpAI('EngineerAttack', 'M2_UEF_TransportBuilder',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                TransportReturn = 'M2_UEF_Base_Marker',
            },
            Priority = 1000,
        }
    )
    opai:SetChildQuantity('T2Transports', 8)
    opai:SetLockingStyle('None')
    opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
        'HaveLessThanUnitsWithCategory', {'default_brain', 5, categories.uea0104})

    -- T1 Bombers
    quantity = {4, 6, 8}
    trigger = {24, 17, 10}
    opai = UEFM2Base:AddOpAI('AirAttacks', 'M2_UEF_Base_AirAttack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = DefaultPatrolChains,
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
    opai = UEFM2Base:AddOpAI('AirAttacks', 'M2_UEF_Base_AirAttack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = DefaultPatrolChains,
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
    opai = UEFM2Base:AddOpAI('AirAttacks', 'M2_UEF_Base_AirAttack_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = DefaultPatrolChains,
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
    opai = UEFM2Base:AddOpAI('AirAttacks', 'M2_UEF_Base_AirAttack_4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = DefaultPatrolChains,
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
    opai = UEFM2Base:AddOpAI('AirAttacks', 'M2_UEF_Base_AirAttack_8',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = DefaultPatrolChains,
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
    opai = UEFM2Base:AddOpAI('AirAttacks', 'M2_UEF_Base_AirAttack_6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = DefaultPatrolChains,
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
    opai = UEFM2Base:AddOpAI('AirAttacks', 'M2_UEF_Base_AirAttack_7',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = DefaultPatrolChains,
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
        opai = UEFM2Base:AddOpAI('AirAttacks', 'M2_UEF_Base_AirDefense_1_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M2_UEF_Base_AirDef_Chain',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('Gunships', quantity[Difficulty])
        opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    end

    -- Interceptors
    for i = 1, 2 + Difficulty do
        opai = UEFM2Base:AddOpAI('AirAttacks', 'M2_UEF_Base_AirDefense_2_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M2_UEF_Base_AirDef_Chain',
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
        opai = UEFM2Base:AddOpAI('AirAttacks', 'M2_UEF_Base_AirDefense_3_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M2_UEF_Base_AirDef_Chain',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('TorpedoBombers', quantity[Difficulty])
        opai:SetLockingStyle('DeathRatio', {Ratio = 0.6})
    end
end

function UEFM2BaseLandAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    -- Keep attacking with Riptides
    quantity = {12, 16, 20}
    opai = UEFM2Base:AddOpAI('BasicLandAttack', 'M2_UEF_Base_Amphibious_Attack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M2_UEF_Base_Amphibious_Attack_Chain_1',
                    'M2_UEF_Base_Amphibious_Attack_Chain_2',
                    'M2_UEF_Base_Amphibious_Attack_Chain_3'   -- Around the island, to the Order base
                },
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('AmphibiousTanks', quantity[Difficulty])
    opai:SetLockingStyle('None')
    opai:SetFormation('AttackFormation')

    --------
    -- Drops
    --------
    -- T2 Tanks
    quantity = {6, 9, 12}
    trigger = {{200, 180, 160}, {220, 200, 180}}
    for i = 1, 2 do
        opai = UEFM2Base:AddOpAI('BasicLandAttack', 'M2_UEF_TransportAttack_1_' .. i,
            {
                MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
                PlatoonData = {
                    AttackChain = 'M2_Player_Island_Drop_Chain',
                    LandingList = {'M2_Drop_Marker_' .. i .. '_1', 'M2_Drop_Marker_' .. i .. '_2'},
                    MovePath = 'M2_UEF_Base_Transport_Chain_' .. i,
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

    -- Percieses thought water
    -- Removed for now
    --       base would need more T3 factories
    --[[         
    quantity = {2, 4, 6}
    trigger = {16, 13, 10}
    for i = 1, 3 do
        opai = UEFM2Base:AddOpAI('BasicLandAttack', 'M2_UEF_Base_Amphibious_Attack_2_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'MoveToThread'},
                PlatoonData = {
                    PatrolChain = 'M2_UEF_Base_Amphibious_Attack_Chain_' .. i, -- #3 Around the island, to the Order base
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('HeavyBots', quantity[Difficulty])
        opai:SetFormation('AttackFormation')
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
            'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers', 'Order'}, trigger[Difficulty], categories.TECH3 - categories.AIR, '>='})
    end
    ]]--
    
    
    local Temp = {
        'M2UEFSACU',
        'NoPlan',
        { 'uel0301_RAS', 1, 2, 'Attack', 'None' },   -- SACU
    }
    local Builder = {
        BuilderName = 'M2SACUBuilder',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 300,
        PlatoonType = 'Gate',
        RequiresConstruction = true,
        LocationType = 'M2_UEF_Base',
        PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread' },       
        PlatoonData = {
            PatrolChain = 'M2_UEF_Base_EngineerChain',
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
    --[[
    opai = UEFM2Base:AddOpAI('EngineerAttack', 'M2_EngAttack1',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'StartBaseEngineerThread'},
            PlatoonData = {
                LandingLocation = 'M2_North_Arty_Base_Marker',
                TransportReturn = 'M2_UEF_Base_Marker',
                UseTransports = true,
                BaseName = 'M2_North_Arty_Base',
            },
            Priority = 90,
        }
    )
    opai:SetChildActive('All', false)
    opai:SetChildActive({'T3Engineers', 'T3Transports'}, false)
    ]]--
end

function UEFM2BaseNavalAttacks()
    local DefaultPatrolChains = {
        'M2_UEF_Base_NavalAttack_Chain_1',
        'M2_UEF_Base_NavalAttack_Chain_2',
        'M2_UEF_Base_NavalAttack_Chain_3',
        'M2_UEF_Base_NavalAttack_Chain_4',
    }

    local opai = nil
    local quantity = {}
    local trigger = {}


    quantity = {4, 6, 8}
    for i = 1, 2 do
        opai = UEFM2Base:AddNavalAI('M2_UEF_Naval_Attack_1_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
                PlatoonData = {
                    PatrolChains = DefaultPatrolChains,
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
    trigger = {17, 14, 11}
    opai = UEFM2Base:AddNavalAI('M2_UEF_Naval_Attack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
                PlatoonData = {
                    PatrolChains = DefaultPatrolChains,
                },
            EnabledTypes = {'Destroyer', 'Submarine'},
            MaxFrigates = quantity[Difficulty],
            MinFrigates = quantity[Difficulty],
            Priority = 110,
            Overrides = {
                CORE_TO_SUBS = 1,
            }
        }
    )
    opai:SetChildActive('T3', false)
    --opai:SetFormation('AttackFormation')
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers', 'Order'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE - categories.TECH1, '>='})

    quantity = {9, 14, 19}
    trigger = {13, 10, 7}
    for i = 1, 2 do
        opai = UEFM2Base:AddNavalAI('M2_UEF_Naval_Attack_3_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
                PlatoonData = {
                    PatrolChains = DefaultPatrolChains,
                },
                MaxFrigates = quantity[Difficulty],
                MinFrigates = quantity[Difficulty],
                Priority = 120,
                Overrides = {
                    CORE_TO_CRUISERS = 1.5,
                    CORE_TO_UTILITY = 1,
                }
            }
        )
        opai:SetChildActive('T3', false)
        if Difficulty == 1 then
            opai:SetFormation('AttackFormation')
        end
        opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
            'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers', 'Order'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE - categories.TECH1, '>='})
    end

    quantity = {25, 35, 45}
    for i = 1, 2 do
        opai = UEFM2Base:AddNavalAI('M2_UEF_Naval_Attack_4_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
                PlatoonData = {
                    PatrolChains = DefaultPatrolChains,
                },
                MaxFrigates = quantity[Difficulty],
                MinFrigates = quantity[Difficulty],
                Priority = 130,
                Overrides = {
                    CORE_TO_CRUISERS = 0.5,
                    CORE_TO_SUBS = 2,
                    CORE_TO_UTILITY = 0.5,
                }
            }
        )
        opai:SetChildActive('T1', false)
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
            'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers', 'Order'}, 2, categories.BATTLESHIP, '>='})
    end


    quantity = {20, 25, 30}
    trigger = {70, 65, 50}
    opai = UEFM2Base:AddNavalAI('M2_UEF_Naval_Attack_5_',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = DefaultPatrolChains,
            },
            EnabledTypes = {'Cruiser', 'Utility'},
            MaxFrigates = quantity[Difficulty],
            MinFrigates = quantity[Difficulty],
            Priority = 140,
            Overrides = {
                CORE_TO_CRUISERS = 1,
                CORE_TO_UTILITY = 1,
            }
        }
    )
    opai:SetChildActive('T1', false)
    opai:SetChildActive('T3', false)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers', 'Order'}, trigger[Difficulty], categories.AIR * categories.MOBILE * categories.ANTIAIR - categories.TECH1, '>='})

    -- Sonar
    opai = UEFM2Base:AddOpAI('M2_UEF_Base_Sonar',
        {
            Amount = 1,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_UEF_Base_Sonar_Patrol_Chain_' .. Random(1, 2),
            },
            MaxAssist = 1,
            Retry = true,
        }
    )
end

---------------------
-- UEF M2 Island Base
---------------------
function UEFM2IslandBaseAI(baseType)
    if baseType == 'Eco' then
        -- Economy Base
        UEFM2IslandBase:InitializeDifficultyTables(
            ArmyBrains[UEF],
            'M2_UEF_Island_Base',
            'M2_UEF_Island_Base_Marker',
            30,
            {
                M2_UEF_Island_Mass = 100,
                M2_UEF_Island_Eco = 100,
            }
        )
        UEFM2IslandBase:StartNonZeroBase(1)
        UEFM2Base:AddExpansionBase('M2_UEF_Island_Base', 1)

    elseif baseType == 'Gate' then
        -- Gate Base
        UEFM2IslandBase:InitializeDifficultyTables(
            ArmyBrains[UEF],
            'M2_UEF_Island_Base',
            'M2_UEF_Island_Base_Marker',
            30,
            {
                M2_UEF_Island_Gate = 100,
                M2_UEF_Island_Mass = 100,
                M2_UEF_Island_Defense = 100,
            }
        )
        UEFM2IslandBase:StartNonZeroBase(1)
        UEFM2IslandBase:SetSupportACUCount(1)
        UEFM2IslandBase:SetSACUUpgrades({'ResourceAllocation', 'RadarJammer', 'SensorRangeEnhancer'}, true)

        UEFM2IslandBaseSACUAttacks()

    elseif baseType == 'Nuke' then
        -- Nuke Base
        UEFM2IslandBase:InitializeDifficultyTables(
            ArmyBrains[UEF],
            'M2_UEF_Island_Base',
            'M2_UEF_Island_Base_Marker',
            30,
            {
                M2_UEF_Island_Nuke = 100,
                M2_UEF_Island_Mass = 100,
                M2_UEF_Island_Defense = 100,
            }
        )
        UEFM2IslandBase:StartNonZeroBase({1, 2, 3})

        ForkThread(UEFM2IslandBaseNukeAI)

    else
        WARN('UEFM2IslandBase: "baseType" NOT DEFINED')
    end
end

-- Island Nuke Ai
function UEFM2IslandBaseNukeAI()
    local nuke = ArmyBrains[UEF]:GetListOfUnits(categories.NUKE * categories.STRATEGIC * categories.STRUCTURE * categories.TECH3, false)[1]

    if not nuke then
        WANR('*speed2: UEFM2IslandBaseNukeAI: No Nuke found... Aborting.')
        return
    end

    IssueStop({nuke})

    local waitTime = {Random(27.0, 31.0), Random(23.0, 27.0), Random(19.0, 23.0)}
    LOG('*speed2: Nuke activation wait time: ' .. waitTime[Difficulty])
    WaitSeconds(waitTime[Difficulty] * 60.0)

    local delay = {11, 8, 5}
    while nuke and not nuke.Dead do
        local marker = nil
        local numUnits = 0
        local searching = true
        while searching do
            WaitSeconds(5)
            for i = 1, 17 do
                local num = table.getn(ArmyBrains[UEF]:GetUnitsAroundPoint((categories.TECH2 * categories.STRUCTURE) + (categories.TECH3 * categories.STRUCTURE), ScenarioUtils.MarkerToPosition('M2_Nuke_Marker_' .. i), 30, 'enemy'))
                if(num > 3) then
                    if(num > numUnits) then
                        numUnits = num
                        marker = 'M2_Nuke_Marker_' .. i
                    end
                end
                if(i == 17 and marker) then
                    searching = false
                end
            end
        end
        if nuke and not nuke.Dead then
            nuke:GiveNukeSiloAmmo(1)
            IssueNuke({nuke}, ScenarioUtils.MarkerToPosition(marker))
        end
        
        WaitSeconds(delay[Difficulty] * 60)
    end
end

-- Island SACU Attacks
function UEFM2IslandBaseSACUAttacks()

end

