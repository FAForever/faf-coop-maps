local BaseManager = import('/lua/ai/opai/basemanager.lua')
local CustomFunctions = '/maps/FAF_Coop_Novax_Station_Assault/FAF_Coop_Novax_Station_Assault_CustomFunctions.lua'
local SPAIFileName = '/lua/ScenarioPlatoonAI.lua'

---------
-- Locals
---------
local UEF = 2
local Difficulty = ScenarioInfo.Options.Difficulty

----------------
-- Base Managers
----------------
local UEFM3Base = BaseManager.CreateBaseManager()
local UEFM3SeaBase = BaseManager.CreateBaseManager()

-------------------
-- UEF M3 Main Base
-------------------
function UEFM3BaseAI()
    UEFM3Base:InitializeDifficultyTables(ArmyBrains[UEF], 'M3_UEF_Base', 'M3_UEF_Base_Marker', 200, {M3_UEF_Base = 100})
    UEFM3Base:StartNonZeroBase({{20, 25, 30}, {15, 19, 23}})
    local num = {1, 1, 2}
    UEFM3Base:SetSupportACUCount(num[Difficulty])
    UEFM3Base:SetSACUUpgrades({'ResourceAllocation', 'SensorRangeEnhancer', 'Shield'}, true)
    UEFM3Base:SetMaximumConstructionEngineers(5)
    
    UEFM3Base:SetActive('AirScouting', true)

    -- Restrict UEF from rebuilding destroyed novaxes
    UEFM3Base.BuildTable['T4SatelliteExperimental'] = false

    --UEFM3Base:AddReactiveAI('ExperimentalLand', 'AirRetaliation', 'UEFM3Base_ExperimentalLand')
    --UEFM3Base:AddReactiveAI('ExperimentalAir', 'AirRetaliation', 'UEFM3Base_ExperimentalAir')
    --UEFM3Base:AddReactiveAI('ExperimentalNaval', 'AirRetaliation', 'UEFM3Base_ExperimentalNaval')
    --UEFM3Base:AddReactiveAI('Nuke', 'AirRetaliation', 'UEFM3Base_Nuke')
    --UEFM3Base:AddReactiveAI('HLRA', 'AirRetaliation', 'UEFM3Base_HLRA')

    UEFM3BaseAirAttacks()
    UEFM3BaseLandAttacks()
    UEFM3BaseNavalAttacks()
    UEFM3BaseConditionalBuilds()
end

function UEFM3BaseAirAttacks()
    local DefaultPatrolChains = {
        'M3_UEF_Air_Attack_Chain_1',
        'M3_UEF_Air_Attack_Chain_2',
        'M3_UEF_Air_Attack_Chain_3',
        'M3_UEF_Air_Attack_Chain_4',
    }

    local opai = nil
    local quantity = {}
    local trigger = {}

    -- Air factories 5, 7, 8
    -- Transport Builder
    quantity = {5, 6, 8}
    opai = UEFM3Base:AddOpAI('EngineerAttack', 'M3_UEF_TransportBuilder',
        {
            MasterPlatoonFunction = {SPAIFileName, 'LandAssaultWithTransports'},
            PlatoonData = {
                TransportReturn = 'M3_UEF_Base_Marker',
            },
            Priority = 1000,
        }
    )
    opai:SetChildQuantity('T3Transports', quantity[Difficulty])
    opai:SetLockingStyle('None')
    opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
        'HaveLessThanUnitsWithCategory', {'default_brain', 4, categories.xea0306})

    ----------
    -- Attacks
    ----------
    -- Send {8, 10, 12} T2 Gunships
    quantity = {8, 10, 12}
    opai = UEFM3Base:AddOpAI('AirAttacks', 'M3_UEF_Base_AirAttack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = DefaultPatrolChains,
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])

    -- Send {8, 10, 12} TorpedoBombers if players have more than {20, 15, 10} ships
    quantity = {8, 10, 12}
    trigger = {20, 15, 10}
    opai = UEFM3Base:AddOpAI('AirAttacks', 'M3_UEF_Base_AirAttack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = DefaultPatrolChains,
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('TorpedoBombers', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers', 'Order'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE, '>='})

    -- Send {2, 3, 4} StratBombers if players have more than {7, 5, 3} T3 ships
    quantity = {4, 5, 6}
    trigger = {7, 5, 3}
    opai = UEFM3Base:AddOpAI('AirAttacks', 'M3_UEF_Base_AirAttack_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'SplitPatrolThread'},
            PlatoonData = {
                PatrolChains = DefaultPatrolChains,
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('StratBombers', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers', 'Order'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE * categories.TECH3 + categories.uas0401, '>='})

    -- Send {8, 10, 12} ASFs if players have more than {30, 25, 20} T2/T3 air units
    quantity = {10, 14, 16}
    trigger = {35, 30, 25}
    opai = UEFM3Base:AddOpAI('AirAttacks', 'M3_UEF_Base_AirAttack_4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackClosestUnit'},
            Priority = 110,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers', 'Order'}, trigger[Difficulty], categories.AIR * categories.MOBILE * (categories.TECH2 + categories.TECH3), '>='})

    -- Send {12, 14, 16} TorpedoBombers if players have more than {30, 25, 20} ships
    quantity = {10, 14, 16}
    trigger = {30, 25, 20}
    opai = UEFM3Base:AddOpAI('AirAttacks', 'M3_UEF_Base_AirAttack_5',
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
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers', 'Order'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE, '>='})

    -- Send {4, 6, 8} HeavyGunships if players have more than {30, 25, 20} T2 ships, attack the closest unit
    quantity = {5, 7, 8}
    trigger = {30, 25, 20}
    opai = UEFM3Base:AddOpAI('AirAttacks', 'M3_UEF_Base_AirAttack_6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackClosestUnit'},
            Priority = 120,
        }
    )
    opai:SetChildQuantity('HeavyGunships', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers', 'Order'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE * categories.TECH2, '>='})

    -- Send {16, 18, 20} TorpedoBombers if players have more than {40, 35, 30} ships
    quantity = {15, 18, 21}
    trigger = {40, 35, 30}
    opai = UEFM3Base:AddOpAI('AirAttacks', 'M3_UEF_Base_AirAttack_7',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = DefaultPatrolChains,
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('TorpedoBombers', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers', 'Order'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE, '>='})

    -- Send ASFs if players have more air experimentals
    quantity = {15, 21, 24}
    trigger = {2, 1, 1}
    opai = UEFM3Base:AddOpAI('AirAttacks', 'M3_UEF_Base_AirAttack_8',
        {
            MasterPlatoonFunction = {SPAIFileName, 'CategoryHunterPlatoonAI'},
            PlatoonData = {
                CategoryList = {
                    categories.EXPERIMENTAL * categories.AIR,
                },
            },
            Priority = 140,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers', 'Order'}, trigger[Difficulty], categories.EXPERIMENTAL * categories.AIR, '>='})

    ----------
    -- Defense
    ----------
    quantity = {5, 7, 9}
    for i = 1, 3 do
        -- ASFs
        opai = UEFM3Base:AddOpAI('AirAttacks', 'M3_UEF_Base_AirDefense_1_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M3_UEF_Base_Novax_Patrol_Chain',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
        opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})

        -- Torpedo bombers
        opai = UEFM3Base:AddOpAI('AirAttacks', 'M3_UEF_Base_AirDefense_2_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M3_UEF_Base_Novax_Patrol_Chain',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('TorpedoBombers', quantity[Difficulty])
        opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    end

    -- T3 Gunships
    opai = UEFM3Base:AddOpAI('AirAttacks', 'M3_UEF_Base_AirDefense_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_UEF_Base_Novax_Patrol_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('HeavyGunships', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})

    -- Strats
    opai = UEFM3Base:AddOpAI('AirAttacks', 'M3_UEF_Base_AirDefense_4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_UEF_Base_Novax_Patrol_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('StratBombers', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
end

function UEFM3BaseLandAttacks()
    local DefaultPatrolChains = {
        'M3_UEF_Naval_Attack_Chain_West',
        'M3_UEF_Naval_Attack_Chain_East',
    }
    local DefaultReclaimChains = {
        'M3_UEF_Naval_Attack_Chain_West',
        'M3_UEF_Naval_Attack_Chain_East',
        'M3_UEF_Air_Attack_Chain_1',
        'M3_UEF_Air_Attack_Chain_2',
        'M3_UEF_Air_Attack_Chain_3',
        'M3_UEF_Air_Attack_Chain_4',
    }

    local opai = nil
    local quantity = {}
    local trigger = {}
    -- 3, 4, 5 Land Factories
    quantity = {6, 6, 8}
    --------------------
    -- Reclaim Engineers
    --------------------
    opai = UEFM3Base:AddOpAI('EngineerAttack', 'M3_UEF_Reclaim_Engineers_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'SplitPatrolThread'},
            PlatoonData = {
                PatrolChains = DefaultReclaimChains,
            },
            Priority = 180,
        }
    )
    opai:SetChildQuantity('T1Engineers', quantity[Difficulty])

    quantity = {6, 6, 8}
    opai = UEFM3Base:AddOpAI('EngineerAttack', 'M3_UEF_Reclaim_Engineers_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'SplitPatrolThread'},
            PlatoonData = {
                PatrolChains = DefaultReclaimChains,
            },
            Priority = 190,
        }
    )
    opai:SetChildQuantity('T1Engineers', quantity[Difficulty])
    opai:AddBuildCondition(CustomFunctions, 'LessMassStorageCurrent', {'default_brain', 6000})

    quantity = {8, 10, 10}
    opai = UEFM3Base:AddOpAI('EngineerAttack', 'M3_UEF_Reclaim_Engineers_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'SplitPatrolThread'},
            PlatoonData = {
                PatrolChains = DefaultReclaimChains,
            },
            Priority = 200,
        }
    )
    opai:SetChildQuantity('T1Engineers', quantity[Difficulty])
    opai:AddBuildCondition(CustomFunctions, 'LessMassStorageCurrent', {'default_brain', 3000})

    -- Send Riptides
    quantity = {6, 8, 10}
    opai = UEFM3Base:AddOpAI('BasicLandAttack', 'M3_UEF_Base_Amphibious_Attack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = DefaultPatrolChains,
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('AmphibiousTanks', quantity[Difficulty])
    opai:SetFormation('AttackFormation')

    -- Send Riptides
    quantity = {9, 12, 15}
    opai = UEFM3Base:AddOpAI('BasicLandAttack', 'M3_UEF_Base_Amphibious_Attack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = DefaultPatrolChains,
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('AmphibiousTanks', quantity[Difficulty])
    opai:SetFormation('AttackFormation')

    -- Send Riptides
    quantity = {12, 16, 20}
    trigger = {28, 24, 20}
    opai = UEFM3Base:AddOpAI('BasicLandAttack', 'M3_UEF_Base_Amphibious_Attack_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = DefaultPatrolChains,
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('AmphibiousTanks', quantity[Difficulty])
    opai:SetFormation('AttackFormation')
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers', 'Order'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE - categories.TECH1, '>='})

    -- Send Riptides
    quantity = {15, 20, 25}
    trigger = {2, 1, 1}
    opai = UEFM3Base:AddOpAI('BasicLandAttack', 'M3_UEF_Base_Amphibious_Attack_4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = DefaultPatrolChains,
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('AmphibiousTanks', quantity[Difficulty])
    opai:SetFormation('AttackFormation')
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers', 'Order'}, trigger[Difficulty], categories.NAVAL * categories.EXPERIMENTAL, '>='})

    -- Send Percies
    quantity = {6, 8, 10}
    trigger = {500, 450, 400}
    opai = UEFM3Base:AddOpAI('BasicLandAttack', 'M3_UEF_Base_Amphibious_Attack_5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = DefaultPatrolChains,
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('HeavyBots', quantity[Difficulty])
    opai:SetFormation('AttackFormation')
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers', 'Order'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL, '>='})

    -- Send Percies
    quantity = {9, 12, 15}
    trigger = {2, 1, 1}
    opai = UEFM3Base:AddOpAI('BasicLandAttack', 'M3_UEF_Base_Amphibious_Attack_6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = DefaultPatrolChains,
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('HeavyBots', quantity[Difficulty])
    opai:SetFormation('AttackFormation')
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers', 'Order'}, trigger[Difficulty], categories.NAVAL * categories.EXPERIMENTAL, '>='})

    -- Drop Percies
    quantity = {6, 8, 10}
    trigger = {9, 7, 5}
    for i = 1, 2 do
        opai = UEFM3Base:AddOpAI('BasicLandAttack', 'M3_UEF_TransportAttack_1_' .. i,
            {
                MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
                PlatoonData = { 
                    AttackChain = 'M2_Player_Island_Drop_Chain',
                    LandingList = {'M2_Drop_Marker_' .. i .. '_1', 'M2_Drop_Marker_' .. i .. '_2'},
                    MovePath = 'M3_Cybran_Base_Transport_Chain_' .. i,
                    --TransportReturn = 'M3_Cybran_Base_Marker', -- Removed until transport return function is fixed
                },
                Priority = 150,
            }
        )
        opai:SetChildQuantity({'HeavyBots', 'SiegeBots' , 'MobileShields', 'MobileFlak'}, {5, 5, 10, 10})
        opai:SetLockingStyle('DeathTimer', {LockTimer = 240})
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
            'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers', 'Order'}, trigger[Difficulty], categories.STRUCTURE * categories.TECH3 * categories.ENERGYPRODUCTION, '>='})
        opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
            'HaveGreaterThanUnitsWithCategory', {'default_brain', 4, categories.xea0306})
    end
end

function UEFM3BaseNavalAttacks()
    local DefaultPatrolChains = {
        'M3_UEF_Naval_Attack_Chain_West',
        'M3_UEF_Naval_Attack_Chain_East',
    }

    local opai = nil
    local quantity = {}
    local trigger = {}
    -- Naval factories 5, 6, 7

    -- Send {5, 6, 7} Frigates
    quantity = {5, 6, 7}
    opai = UEFM3Base:AddOpAI('NavalAttacks', 'M3_UEF_Naval_Attack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = DefaultPatrolChains,
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Frigates', quantity[Difficulty])
    opai:SetFormation('AttackFormation')

    -- Send {5, 6, 7} Submarines
    quantity = {5, 6, 7}
    opai = UEFM3Base:AddOpAI('NavalAttacks', 'M3_UEF_Naval_Attack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = DefaultPatrolChains,
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Submarines', quantity[Difficulty])
    opai:SetFormation('AttackFormation')

    -- Send Destroyers and Frigates
    quantity = {{3, 2}, {4, 2}, 5}
    opai = UEFM3Base:AddOpAI('NavalAttacks', 'M3_UEF_Naval_Attack_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = DefaultPatrolChains,
            },
            Priority = 110,
        }
    )
    if Difficulty <= 2 then
        opai:SetChildQuantity({'Destroyers', 'Frigates'}, quantity[Difficulty])
    else
        opai:SetChildQuantity('Destroyers', quantity[Difficulty])
    end
    opai:SetFormation('AttackFormation')

    -- Send 2 Cruisers and 2 UtilityBoats
    opai = UEFM3Base:AddOpAI('NavalAttacks', 'M3_UEF_Naval_Attack_4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = DefaultPatrolChains,
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'Cruisers', 'UtilityBoats'}, 4)

    -- Send {12, 16, 20} Frigates if players have more than {42, 38, 36} ships
    quantity = {15, 18, 21}
    trigger = {42, 38, 36}
    opai = UEFM3Base:AddOpAI('NavalAttacks', 'M3_UEF_Naval_Attack_5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = DefaultPatrolChains,
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Frigates', quantity[Difficulty])
    opai:SetFormation('AttackFormation')
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers', 'Order'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE, '>='})

    -- Send {5, 6, 7} TorpedoBoats if players have more than {14, 12, 10} submarines
    quantity = {5, 6, 7}
    trigger = {14, 12, 10}
    opai = UEFM3Base:AddOpAI('NavalAttacks', 'M3_UEF_Naval_Attack_6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = DefaultPatrolChains,
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('TorpedoBoats', quantity[Difficulty])
    opai:SetFormation('AttackFormation')
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers', 'Order'}, trigger[Difficulty], categories.SUBMERSIBLE, '>='})

    -- Send Destroyers and Shield Boat if players have more than {15, 13, 11} T2 ships
    quantity = {5, {5, 1}, {6, 1}}
    trigger = {15, 13, 11}
    opai = UEFM3Base:AddOpAI('NavalAttacks', 'M3_UEF_Naval_Attack_7',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = DefaultPatrolChains,
            },
            Priority = 110,
        }
    )
    if Difficulty == 1 then
        opai:SetChildQuantity('Destroyers', quantity[Difficulty])
    else
        opai:SetChildQuantity({'Destroyers', 'UtilityBoats'}, quantity[Difficulty])
    end
    opai:SetFormation('AttackFormation')
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers', 'Order'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE * categories.TECH2, '>='})

    -- Send 4 Cruisers if players have more than {85, 75, 65} air units
    quantity = {4, 5, 6}
    trigger = {85, 75, 65}
    opai = UEFM3Base:AddOpAI('NavalAttacks', 'M3_UEF_Naval_Attack_8',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = DefaultPatrolChains,
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Cruisers', quantity[Difficulty])
    opai:SetFormation('AttackFormation')
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers', 'Order'}, trigger[Difficulty], categories.AIR * categories.MOBILE, '>='})

    -- Send Cruisers if players have air experimentals
    quantity = {5, 6, 7}
    opai = UEFM3Base:AddOpAI('NavalAttacks', 'M3_UEF_Naval_Attack_9',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = DefaultPatrolChains,
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Cruisers', quantity[Difficulty])
    opai:SetFormation('AttackFormation')
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers', 'Order'}, 1, categories.AIR * categories.EXPERIMENTAL, '>='})

    -- Send 4 Destroyers, Cruisers and UtilityBoats if players have more than {16, 13, 10} T2 ships
    quantity = {{3, 1, 1}, {3, 1, 2}, {4, 2, 2}}
    trigger = {16, 13, 10}
    opai = UEFM3Base:AddOpAI('NavalAttacks', 'M3_UEF_Naval_Attack_10',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = DefaultPatrolChains,
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity({'Destroyers', 'Cruisers', 'UtilityBoats'}, quantity[Difficulty])
    opai:SetFormation('AttackFormation')
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers', 'Order'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE * categories.TECH2, '>='})

    -- Send {5, 8, 11} TorpedoBoats if players have more than {20, 18, 16} submarines
    quantity = {5, 8, 11}
    trigger = {20, 18, 16}
    opai = UEFM3Base:AddOpAI('NavalAttacks', 'M3_UEF_Naval_Attack_11',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = DefaultPatrolChains,
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('TorpedoBoats', quantity[Difficulty])
    opai:SetFormation('AttackFormation')
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers', 'Order'}, trigger[Difficulty], categories.SUBMERSIBLE, '>='})

    -- Send Destroyers and Cruisers if players have more than {22, 19, 16} T2 ships
    quantity = {{4, 1, 2}, {5, 1, 2, 1}, {6, 1, 2, 1}}
    trigger = {22, 19, 16}
    opai = UEFM3Base:AddOpAI('NavalAttacks', 'M3_UEF_Naval_Attack_12',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = DefaultPatrolChains,
            },
            Priority = 120,
        }
    )
    if Difficulty == 1 then
        opai:SetChildQuantity({'Destroyers', 'Cruisers', 'TorpedoBoats'}, quantity[Difficulty])
    else
        opai:SetChildQuantity({'Destroyers', 'Cruisers', 'TorpedoBoats', 'UtilityBoats'}, quantity[Difficulty])
    end
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers', 'Order'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE * categories.TECH2, '>='})

    -- Send 8 Cruisers if players have more than {90, 80, 70} air units
    quantity = {{6, 2}, {8, 2}, {10, 4}}
    trigger = {110, 95, 85}
    opai = UEFM3Base:AddOpAI('NavalAttacks', 'M3_UEF_Naval_Attack_13',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = DefaultPatrolChains,
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity({'Cruisers', 'UtilityBoats'}, quantity[Difficulty])
    opai:SetFormation('AttackFormation')
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers', 'Order'}, trigger[Difficulty], categories.AIR * categories.MOBILE, '>='})

    -- Send Destroyers and Cruisers if players have more than {22, 19, 16} T3 ships
    quantity = {{6, 2, 2}, {8, 2, 2}, {10, 2, 2}}
    trigger = {11, 9, 7}
    opai = UEFM3Base:AddOpAI('NavalAttacks', 'M3_UEF_Naval_Attack_14',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = DefaultPatrolChains,
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity({'Destroyers', 'Cruisers', 'UtilityBoats'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers', 'Order'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE * categories.TECH3 + categories.uas0401, '>='})

    -- Send {2, 3, 4} Battleships if players have more than {12, 10, 8} T3 ships
    quantity = {{2, 2}, {3, 2}, {3, 3}}
    trigger = {12, 10, 8}
    opai = UEFM3Base:AddOpAI('NavalAttacks', 'M3_UEF_Naval_Attack_15',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = DefaultPatrolChains,
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity({'BattleCruisers', 'Battleships'}, quantity[Difficulty])
    --opai:SetFormation('AttackFormation')
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers', 'Order'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE * categories.TECH3 + categories.uas0401, '>='})

    -- Send Battleships and BattleCruisers if players have Tempests
    quantity = {{2, 2}, {3, 2}, {3, 3}}
    trigger = {3, 2, 2}
    opai = UEFM3Base:AddOpAI('NavalAttacks', 'M3_UEF_Naval_Attack_16',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = DefaultPatrolChains,
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity({'BattleCruisers', 'Battleships'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers', 'Order'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE * categories.EXPERIMENTAL, '>='})

    -- Send Destroyers and UtilityBoats if players have more than {36, 34, 32} ships
    quantity = {{8, 2}, {10, 2},{14, 2}}
    trigger = {36, 34, 32}
    opai = UEFM3Base:AddOpAI('NavalAttacks', 'M3_UEF_Naval_Attack_17',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = DefaultPatrolChains,
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity({'Destroyers', 'UtilityBoats'}, quantity[Difficulty])
    opai:SetFormation('AttackFormation')
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers', 'Order'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE, '>='})

    -- Send {4, 5, 6} BattleCruisers if players have more than {26, 24, 22} T2 ships
    quantity = {4, 5, 6}
    trigger = {26, 24, 22}
    opai = UEFM3Base:AddOpAI('NavalAttacks', 'M3_UEF_Naval_Attack_18',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = DefaultPatrolChains,
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('BattleCruisers', quantity[Difficulty])
    opai:SetFormation('AttackFormation')
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers', 'Order'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE * categories.TECH2, '>='})

    -- Send Battleships if players have more than {14, 12, 10} T3 ships
    quantity = {5, 6, 7}
    trigger = {14, 12, 10}
    opai = UEFM3Base:AddOpAI('NavalAttacks', 'M3_UEF_Naval_Attack_19',
        {
            MasterPlatoonFunction = {SPAIFileName, 'SplitPatrolThread'},
            PlatoonData = {
                PatrolChains = DefaultPatrolChains,
            },
            Priority = 140,
        }
    )
    opai:SetChildQuantity('Battleships', quantity[Difficulty])
    opai:SetFormation('AttackFormation')
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers', 'Order'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE * categories.TECH3 + categories.uas0401, '>='})
end

function UEFM3BaseConditionalBuilds()
    -- Sonar around the base
    local opai = UEFM3Base:AddOpAI('M3_Sonar',
        {
            Amount = 1,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_UEF_Base_Sonar_Chain',
            },
            MaxAssist = 1,
            Retry = true,
        }
    )
end

function BuildArty()
    UEFM3Base:AddBuildGroupDifficulty('M3_UEF_Arty', 90)
end

------------------
-- M3 UEF Sea Base
------------------
function UEFM3SeaBaseAI()
    UEFM3SeaBase:InitializeDifficultyTables(ArmyBrains[UEF], 'M3_UEF_Sea_Base', 'M3_UEF_Sea_Base_Marker', 45, {M3_UEF_Sea_Base = 100})
    UEFM3SeaBase:StartEmptyBase({{2, 4, 5}, {1, 2, 3}})
    UEFM3SeaBase:SetMaximumConstructionEngineers(2)

    UEFM3Base:AddExpansionBase('M3_UEF_Sea_Base', 1)
    
    UEFM3SeaBaseNavalAttacks()
end

function UEFM3SeaBaseNavalAttacks()
    local DefaultPatrolChains = {
        'M3_UEF_Sea_Base_Naval_Attack_Chain_1',
    }

    local opai = nil
    local quantity = {}
    local trigger = {}

    -- 1, 4 --- 1, 6 --- 3, 6

    quantity = {6, 8, 12}
    opai = UEFM3SeaBase:AddOpAI('NavalAttacks', 'M3_UEF_Sea_Base_Naval_Attack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_UEF_Sea_Base_Naval_Attack_Chain_1',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Frigates', quantity[Difficulty])
    opai:SetFormation('AttackFormation')

    quantity = {6, 8, 12}
    opai = UEFM3SeaBase:AddOpAI('NavalAttacks', 'M3_UEF_Sea_Base_Naval_Attack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_UEF_Sea_Base_Naval_Attack_Chain_1',
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Submarines', quantity[Difficulty])
    opai:SetFormation('AttackFormation')

    quantity = {6, 8, 12}
    opai = UEFM3SeaBase:AddOpAI('NavalAttacks', 'M3_UEF_Sea_Base_Naval_Attack_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_UEF_Sea_Base_Naval_Attack_Chain_1',
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity({'Frigates', 'Submarines'}, quantity[Difficulty])
    opai:SetFormation('AttackFormation')

    quantity = {10, 14, 18}
    trigger = {400, 350, 300}
    opai = UEFM3SeaBase:AddOpAI('NavalAttacks', 'M3_UEF_Sea_Base_Naval_Attack_4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_UEF_Sea_Base_Naval_Attack_Chain_1',
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('Frigates', quantity[Difficulty])
    opai:SetFormation('AttackFormation')
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers', 'Order'}, trigger[Difficulty], categories.ALLUNITS, '>='})

    quantity = {12, 16, 24}
    trigger = {450, 400, 350}
    opai = UEFM3SeaBase:AddOpAI('NavalAttacks', 'M3_UEF_Sea_Base_Naval_Attack_5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_UEF_Sea_Base_Naval_Attack_Chain_1',
            },
            Priority = 140,
        }
    )
    opai:SetChildQuantity({'Frigates', 'Submarines'}, quantity[Difficulty])
    opai:SetFormation('AttackFormation')
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers', 'Order'}, trigger[Difficulty], categories.ALLUNITS, '>='})

    quantity = {{1, 8}, {1, 12}, {3, 12}}
    trigger = {15, 13, 11}
    opai = UEFM3SeaBase:AddOpAI('NavalAttacks', 'M3_UEF_Sea_Base_Naval_Attack_6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_UEF_Sea_Base_Naval_Attack_Chain_1',
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity({'Destroyers', 'Frigates'}, quantity[Difficulty])
    opai:SetFormation('AttackFormation')
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers', 'Order'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE - categories.TECH1, '>='})

    quantity = {{1, 4, 4}, {1, 6, 6}, {3, 6, 6}}
    trigger = {20, 18, 16}
    opai = UEFM3SeaBase:AddOpAI('NavalAttacks', 'M3_UEF_Sea_Base_Naval_Attack_7',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_UEF_Sea_Base_Naval_Attack_Chain_1',
            },
            Priority = 160,
        }
    )
    opai:SetChildQuantity({'Destroyers', 'Frigates', 'Submarines'}, quantity[Difficulty])
    opai:SetFormation('AttackFormation')
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers', 'Order'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE - categories.TECH1, '>='})
end
