local BaseManager = import('/lua/ai/opai/basemanager.lua')
local CustomFunctions = '/maps/FAF_Coop_Novax_Station_Assault/FAF_Coop_Novax_Station_Assault_CustomFunctions.lua'
local SPAIFileName = '/lua/ScenarioPlatoonAI.lua'

---------
-- Locals
---------
local Cybran = 4
local Difficulty = ScenarioInfo.Options.Difficulty

----------------
-- Base Managers
----------------
local CybranM3Base = BaseManager.CreateBaseManager()
local CybranM3SeaBase = BaseManager.CreateBaseManager()

----------------------
-- Cybran M3 Main Base
----------------------
function CybranM3BaseAI()
    CybranM3Base:InitializeDifficultyTables(ArmyBrains[Cybran], 'M3_Cybran_Main_Base', 'M3_Cybran_Base_Marker', 180, {M3_Cybran_Main_Base = 100})
    CybranM3Base:StartNonZeroBase({{9, 12, 15}, {7, 9, 11}})
    CybranM3Base:SetSupportACUCount(1)
    CybranM3Base:SetSACUUpgrades({'ResourceAllocation', 'Switchback', 'SelfRepairSystem'}, true)
    CybranM3Base:SetMaximumConstructionEngineers(4)
    
    CybranM3Base:SetActive('AirScouting', true)

    --CybranM3Base:AddReactiveAI('ExperimentalLand', 'AirRetaliation', 'CybranM3Base_ExperimentalLand')
    --CybranM3Base:AddReactiveAI('ExperimentalAir', 'AirRetaliation', 'CybranM3Base_ExperimentalAir')
    --CybranM3Base:AddReactiveAI('ExperimentalNaval', 'AirRetaliation', 'CybranM3Base_ExperimentalNaval')
    --CybranM3Base:AddReactiveAI('Nuke', 'AirRetaliation', 'CybranM3Base_Nuke')
    --CybranM3Base:AddReactiveAI('HLRA', 'AirRetaliation', 'CybranM3Base_HLRA')

    CybranM3BaseAirAttacks()
    CybranM3BaseLandAttacks()
    CybranM3BaseNavalAttacks()
    CybranM3BaseConditionalBuilds()
end

function CybranM3BaseAirAttacks()
    local DefaultPatrolChains = {
        'M3_Cybran_Air_Attack_Chain_1',
        'M3_Cybran_Air_Attack_Chain_2',
        'M3_Cybran_Air_Attack_Chain_3',
        'M3_Cybran_Air_Attack_Chain_4',
    }

	local opai = nil
	local quantity = {}
	local trigger = {}
    -- 4 Air Factories

    -- Transport builder
    opai = CybranM3Base:AddOpAI('EngineerAttack', 'M3_Cybran_TransportBuilder',
        {
            MasterPlatoonFunction = {SPAIFileName, 'LandAssaultWithTransports'},
            PlatoonData = {
                TransportReturn = 'M3_Cybran_Base_Marker',
            },
            Priority = 1000,
        }
    )
    opai:SetChildQuantity('T2Transports', 4)
    opai:SetLockingStyle('None')
    opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
        'HaveLessThanUnitsWithCategory', {'default_brain', 4, categories.ura0104})

    ----------
    -- Attacks
    ----------
    -- Send {8, 10, 12} T2 Gunships
    quantity = {8, 10, 12}
    opai = CybranM3Base:AddOpAI('AirAttacks', 'M3_Cybran_Base_AirAttack_1',
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
    opai = CybranM3Base:AddOpAI('AirAttacks', 'M3_Cybran_Base_AirAttack_2',
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
    quantity = {2, 3, 4}
    trigger = {7, 5, 3}
    opai = CybranM3Base:AddOpAI('AirAttacks', 'M3_Cybran_Base_AirAttack_3',
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
    quantity = {8, 10, 12}
    trigger = {35, 30, 25}
    opai = CybranM3Base:AddOpAI('AirAttacks', 'M3_Cybran_Base_AirAttack_4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackClosestUnit'},
            Priority = 110,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers', 'Order'}, trigger[Difficulty], categories.AIR * categories.MOBILE * (categories.TECH2 + categories.TECH3), '>='})

    -- Send {12, 14, 16} TorpedoBombers if players have more than {30, 25, 20} ships
    quantity = {12, 14, 16}
    trigger = {30, 25, 20}
    opai = CybranM3Base:AddOpAI('AirAttacks', 'M3_Cybran_Base_AirAttack_5',
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
    quantity = {4, 6, 8}
    trigger = {30, 25, 20}
    opai = CybranM3Base:AddOpAI('AirAttacks', 'M3_Cybran_Base_AirAttack_6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackClosestUnit'},
            Priority = 120,
        }
    )
    opai:SetChildQuantity('HeavyGunships', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers', 'Order'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE * categories.TECH2, '>='})

    -- Send {16, 18, 20} TorpedoBombers if players have more than {40, 35, 30} ships
    quantity = {16, 18, 20}
    trigger = {40, 35, 30}
    opai = CybranM3Base:AddOpAI('AirAttacks', 'M3_Cybran_Base_AirAttack_7',
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
    quantity = {12, 16, 20}
    trigger = {2, 1, 1}
    opai = CybranM3Base:AddOpAI('AirAttacks', 'M3_Cybran_Base_AirAttack_8',
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
    -- Torpedo Bombers
    quantity = {2, 2, 3}
    for i = 1, quantity[Difficulty] do
        opai = CybranM3Base:AddOpAI('AirAttacks', 'M3_Main_Base_AirDefense_1_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M3_Cybran_Base_AirPatrol_Chain',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('TorpedoBombers', 4)
        opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    end

    -- ASFs
    quantity = {1, 2, 3}
    for i = 1, quantity[Difficulty] do
        opai = CybranM3Base:AddOpAI('AirAttacks', 'M3_Main_Base_AirDefense_2_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M3_Cybran_Base_AirPatrol_Chain',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('AirSuperiority', 4)
        opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    end

    -- Strats
    quantity = {2, 3, 4}
    opai = CybranM3Base:AddOpAI('AirAttacks', 'M3_Main_Base_AirDefense_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Cybran_Base_AirPatrol_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('StratBombers', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})

    if Difficulty >= 2 then
        -- Heavy Gunships
        quantity = {2, 3, 4}
        opai = CybranM3Base:AddOpAI('AirAttacks', 'M3_Main_Base_AirDefense_4',
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M3_Cybran_Base_AirPatrol_Chain',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('HeavyGunships', quantity[Difficulty])
        opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    end
end

function CybranM3BaseLandAttacks()
    local DefaultPatrolChains = {
        'M3_Cybran_Amphibious_Chain_1',
        'M3_Cybran_Amphibious_Chain_2',
    }
    local DefaultReclaimChains = {
        'M3_Cybran_Amphibious_Chain_1',
        'M3_Cybran_Amphibious_Chain_2',
        'M3_Cybran_Naval_Attack_Chain_1',
        'M3_Cybran_Naval_Attack_Chain_2',
        'M3_Cybran_Naval_Attack_Chain_3',
        'M3_Cybran_Air_Attack_Chain_1',
        'M3_Cybran_Air_Attack_Chain_2',
        'M3_Cybran_Air_Attack_Chain_3',
        'M3_Cybran_Air_Attack_Chain_4',
    }

	local opai = nil
	local quantity = {}
	local trigger = {}
    -- 3 Land Factories

    --------------------
    -- Reclaim Engineers
    --------------------
    opai = CybranM3Base:AddOpAI('EngineerAttack', 'M3_Cybran_Reclaim_Engineers_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'SplitPatrolThread'},
            PlatoonData = {
                PatrolChains = DefaultReclaimChains,
            },
            Priority = 180,
        }
    )
    opai:SetChildQuantity('T1Engineers', 6)

    opai = CybranM3Base:AddOpAI('EngineerAttack', 'M3_Cybran_Reclaim_Engineers_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'SplitPatrolThread'},
            PlatoonData = {
                PatrolChains = DefaultReclaimChains,
            },
            Priority = 190,
        }
    )
    opai:SetChildQuantity('T1Engineers', 6)
    opai:AddBuildCondition(CustomFunctions, 'LessMassStorageCurrent', {'default_brain', 4000})

    opai = CybranM3Base:AddOpAI('EngineerAttack', 'M3_Cybran_Reclaim_Engineers_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'SplitPatrolThread'},
            PlatoonData = {
                PatrolChains = DefaultReclaimChains,
            },
            Priority = 200,
        }
    )
    opai:SetChildQuantity('T1Engineers', 9)
    opai:AddBuildCondition(CustomFunctions, 'LessMassStorageCurrent', {'default_brain', 2000})

    -- Send Wagners
    quantity = {9, 10, 12}
    opai = CybranM3Base:AddOpAI('BasicLandAttack', 'M3_Cybran_Base_Amphibious_Attack_1',
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

    -- Send Wagners
    quantity = {9, 12, 15}
    opai = CybranM3Base:AddOpAI('BasicLandAttack', 'M3_Cybran_Base_Amphibious_Attack_2',
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

    -- Send 6 Bricks
    opai = CybranM3Base:AddOpAI('BasicLandAttack', 'M3_Cybran_Base_Amphibious_Attack_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = DefaultPatrolChains,
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('HeavyBots', 6)
    opai:SetFormation('AttackFormation')

    -- Send {6, 9, 12} Bricks if all Mexes on the main island are taken and on T3
    quantity = {6, 9, 12}
    opai = CybranM3Base:AddOpAI('BasicLandAttack', 'M3_Cybran_Base_Amphibious_Attack_4',
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
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers', 'Order'}, 9, categories.STRUCTURE * categories.TECH3 * categories.MASSEXTRACTION, '>='})

    --------
    -- Drops
    --------
    -- Loyalists
    quantity = {4, 6, 8}
    trigger = {{360, 340, 320}, {480, 440, 400}}
    for i = 1, 2 do
        opai = CybranM3Base:AddOpAI('BasicLandAttack', 'M3_Cybran_TransportAttack_1_' .. i,
            {
                MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
                PlatoonData = {
                    AttackChain = 'M2_Player_Island_Drop_Chain',
                    LandingList = {'M2_Drop_Marker_' .. i .. '_1', 'M2_Drop_Marker_' .. i .. '_2'},
                    MovePath = 'M3_Cybran_Base_Transport_Chain_' .. i,
                    --TransportReturn = 'M3_Cybran_Base_Marker', -- Removed until transport return function is fixed
                },
                Priority = 140,
            }
        )
        opai:SetChildQuantity('SiegeBots', quantity[Difficulty])
        opai:SetLockingStyle('DeathTimer', {LockTimer = 240})
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
            'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers', 'Order'}, trigger[i][Difficulty], categories.ALLUNITS - categories.WALL, '>='})
        opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
            'HaveGreaterThanUnitsWithCategory', {'default_brain', 3, categories.ura0104})
    end

    -- Drop {4, 6, 8} Bricks if players have more than {8, 6, 4} T3 Pgens
    quantity = {4, 6, 8}
    trigger = {8, 6, 4}
    for i = 1, 2 do
        opai = CybranM3Base:AddOpAI('BasicLandAttack', 'M3_Cybran_TransportAttack_2_' .. i,
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
        opai:SetChildQuantity('HeavyBots', quantity[Difficulty])
        opai:SetLockingStyle('DeathTimer', {LockTimer = 240})
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
            'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers', 'Order'}, trigger[Difficulty], categories.STRUCTURE * categories.TECH3 * categories.ENERGYPRODUCTION, '>='})
        opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
            'HaveGreaterThanUnitsWithCategory', {'default_brain', 3, categories.ura0104})
    end
end

function CybranM3BaseNavalAttacks()
    local DefaultPatrolChains = {
        'M3_Cybran_Naval_Attack_Chain_1',
        'M3_Cybran_Naval_Attack_Chain_2',
        'M3_Cybran_Naval_Attack_Chain_3',
    }

	local opai = nil
	local quantity = {}
	local trigger = {}
    -- 4 factories

    -- Send {4, 6, 8} Frigates
    quantity = {4, 6, 8}
    opai = CybranM3Base:AddOpAI('NavalAttacks', 'M3_Cybran_Naval_Attack_1',
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

    -- Send {4, 6, 8} Submarines
    quantity = {4, 6, 8}
    opai = CybranM3Base:AddOpAI('NavalAttacks', 'M3_Cybran_Naval_Attack_2',
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
    quantity = {{2, 2}, {3, 1}, 4}
    opai = CybranM3Base:AddOpAI('NavalAttacks', 'M3_Cybran_Naval_Attack_3',
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

    -- Send 2 Cruisers and 2 T2Submarines
    opai = CybranM3Base:AddOpAI('NavalAttacks', 'M3_Cybran_Naval_Attack_4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = DefaultPatrolChains,
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'Cruisers', 'T2Submarines'}, 4)

    -- Send {12, 16, 20} Frigates if players have more than 
    quantity = {12, 16, 20}
    trigger = {38, 34, 30}
    opai = CybranM3Base:AddOpAI('NavalAttacks', 'M3_Cybran_Naval_Attack_5',
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

    -- Send T2 Submarines
    quantity = {4, 4, 8}
    trigger = {10, 8, 8}
    opai = CybranM3Base:AddOpAI('NavalAttacks', 'M3_Cybran_Naval_Attack_6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = DefaultPatrolChains,
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('T2Submarines', quantity[Difficulty])
    opai:SetFormation('AttackFormation')
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers', 'Order'}, trigger[Difficulty], categories.SUBMERSIBLE, '>='})

    -- Send 4 Destroyers if players have more than {10, 8, 6} T2 ships
    trigger = {10, 8, 6}
    opai = CybranM3Base:AddOpAI('NavalAttacks', 'M3_Cybran_Naval_Attack_7',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = DefaultPatrolChains,
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Destroyers', 4)
    opai:SetFormation('AttackFormation')
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers', 'Order'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE * categories.TECH2, '>='})

    -- Send 4 Cruisers if players have more than {70, 60, 50} air units
    trigger = {70, 60, 50}
    opai = CybranM3Base:AddOpAI('NavalAttacks', 'M3_Cybran_Naval_Attack_8',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = DefaultPatrolChains,
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Cruisers', 4)
    opai:SetFormation('AttackFormation')
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers', 'Order'}, trigger[Difficulty], categories.AIR * categories.MOBILE, '>='})

    -- Send 4 Cruisers if players have air experimentals
    opai = CybranM3Base:AddOpAI('NavalAttacks', 'M3_Cybran_Naval_Attack_9',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = DefaultPatrolChains,
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Cruisers', 4)
    opai:SetFormation('AttackFormation')
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers', 'Order'}, 1, categories.AIR * categories.EXPERIMENTAL, '>='})

    -- Send 4 Destroyers, Cruisers and T2 subs (and stealth boat) if players have more than {16, 13, 10} T2 ships
    quantity = {{3, 1, 1}, {3, 1, 2}, {4, 2, 2, 1}}
    trigger = {16, 13, 10}
    opai = CybranM3Base:AddOpAI('NavalAttacks', 'M3_Cybran_Naval_Attack_10',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = DefaultPatrolChains,
            },
            Priority = 120,
        }
    )
    if Difficulty <= 2 then
        opai:SetChildQuantity({'Destroyers', 'Cruisers', 'T2Submarines'}, quantity[Difficulty])
    else
        opai:SetChildQuantity({'Destroyers', 'Cruisers', 'T2Submarines', 'UtilityBoats'}, quantity[Difficulty])
    end
    --opai:SetFormation('AttackFormation')
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers', 'Order'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE * categories.TECH2, '>='})

    -- Send {4, 6, 8} T2Submarines if players have more than {10, 8, 6} submarines
    quantity = {4, 6, 8}
    trigger = {16, 14, 12}
    opai = CybranM3Base:AddOpAI('NavalAttacks', 'M3_Cybran_Naval_Attack_11',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = DefaultPatrolChains,
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('T2Submarines', quantity[Difficulty])
    opai:SetFormation('AttackFormation')
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers', 'Order'}, trigger[Difficulty], categories.SUBMERSIBLE, '>='})

    -- Send Destroyers and Cruisers if players have more than {22, 19, 16} T2 ships
    quantity = {{4, 1, 1}, {5, 1, 3, 1}, {6, 1, 3, 2}}
    trigger = {22, 19, 16}
    opai = CybranM3Base:AddOpAI('NavalAttacks', 'M3_Cybran_Naval_Attack_12',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = DefaultPatrolChains,
            },
            Priority = 120,
        }
    )
    if Difficulty == 1 then
        opai:SetChildQuantity({'Destroyers', 'Cruisers', 'UtilityBoats'}, quantity[Difficulty])
    else
        opai:SetChildQuantity({'Destroyers', 'Cruisers', 'T2Submarines', 'UtilityBoats'}, quantity[Difficulty])
    end
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers', 'Order'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE * categories.TECH2, '>='})

    -- Send 8 Cruisers if players have more than {90, 80, 70} air units
    trigger = {90, 80, 70}
    opai = CybranM3Base:AddOpAI('NavalAttacks', 'M3_Cybran_Naval_Attack_13',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = DefaultPatrolChains,
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('Cruisers', 8)
    opai:SetFormation('AttackFormation')
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers', 'Order'}, trigger[Difficulty], categories.AIR * categories.MOBILE, '>='})

    -- Send Destroyers and Cruisers if players have more than {10, 8, 6} T3 ships
    quantity = {{4, 2, 2}, {6, 1, 2}, {8, 2, 2}}
    trigger = {10, 8, 6}
    opai = CybranM3Base:AddOpAI('NavalAttacks', 'M3_Cybran_Naval_Attack_14',
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

    -- Send {2, 3, 4} Battleships if players have more than {8, 6, 4} T3 ships
    quantity = {{2, 2}, {3, 1}, 4}
    trigger = {8, 6, 4}
    opai = CybranM3Base:AddOpAI('NavalAttacks', 'M3_Cybran_Naval_Attack_15',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = DefaultPatrolChains,
            },
            Priority = 130,
        }
    )
    if Difficulty <= 2 then
        opai:SetChildQuantity({'Battleships', 'Carriers'}, quantity[Difficulty])
    else
        opai:SetChildQuantity('Battleships', quantity[Difficulty])
    end
    opai:SetFormation('AttackFormation')
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers', 'Order'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE * categories.TECH3 + categories.uas0401, '>='})

    -- Send 8 Destroyers if players have more than {90, 80, 70} air units
    quantity = {{7, 1}, {9, 1},{10, 2}}
    trigger = {35, 30, 25}
    opai = CybranM3Base:AddOpAI('NavalAttacks', 'M3_Cybran_Naval_Attack_16',
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

    -- Send Carriers and Cruisers if players have more than {90, 80, 70} air units
    quantity = {{2, 4}, {3, 6}, {4, 8}}
    trigger = {140, 120, 90}
    opai = CybranM3Base:AddOpAI('NavalAttacks', 'M3_Cybran_Naval_Attack_17',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = DefaultPatrolChains,
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity({'Carriers', 'Cruisers'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers', 'Order'}, trigger[Difficulty], categories.AIR * categories.MOBILE, '>='})

    -- Send Battleships and Carriers 
    quantity = {{2, 2}, {3, 3}, {4, 4}}
    trigger = {12, 10, 8}
    opai = CybranM3Base:AddOpAI('NavalAttacks', 'M3_Cybran_Naval_Attack_18',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = DefaultPatrolChains,
            },
            Priority = 140,
        }
    )
    opai:SetChildQuantity({'Battleships', 'Carriers'}, quantity[Difficulty])
    opai:SetFormation('AttackFormation')
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers', 'Order'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE * categories.TECH3 + categories.uas0401, '>='})
end

function CybranM3BaseConditionalBuilds()
    -- Sonar around the base
    local opai = CybranM3Base:AddOpAI('M3_Sonar',
        {
            Amount = 1,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Cybran_Base_Sonar_Chain',
            },
            MaxAssist = 1,
            Retry = true,
        }
    )

    -- ML
    opai = CybranM3Base:AddOpAI('M3_ML',
        {
            Amount = 1,
            KeepAlive = true,
            PlatoonAIFunction = {CustomFunctions, 'LandExperimentalAttackThread'},
            MaxAssist = 4,
            Retry = true,
            WaitSecondsAfterDeath = 180,
            BuildCondition = {
                {'/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
                    {{'HumanPlayers'}, 1, categories.LAND * categories.EXPERIMENTAL, '>='},
                },
            }
        }
    )


    if Difficulty >= 2 then
        -- Bug
        quantity = {0, 1, 2}
        opai = CybranM3Base:AddOpAI('M3_Soul_Ripper',
            {
                Amount = quantity[Difficulty],
                KeepAlive = true,
                PlatoonAIFunction = {CustomFunctions, 'AddExperimentalToPlatoon'},
                PlatoonData = {
                    Name = 'M3_Soul_Ripper_Platoon',
                    NumRequired = quantity[Difficulty],
                    PatrolChain = 'M3_Cybran_Air_Attack_Chain_' .. Random(1, 4),
                },
                MaxAssist = 4,
                Retry = true,
                --WaitSecondsAfterDeath = 120, -- Doesn't work with Amount > 1
                BuildCondition = {
                    {'/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
                        {{'HumanPlayers', 'Order'}, 2, categories.EXPERIMENTAL, '>='},
                    },
                }
            }
        )
    end
end

function BuildArty()
    CybranM3Base:AddBuildGroup('M3_Cybran_Arty', 90)
end

function BuildScathis()
    local opai = CybranM3Base:AddOpAI('M3_Scathis',
        {
            Amount = 1,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'MoveToThread'},
            PlatoonData = {
                MoveRoute = {'M3_Scathis_Destination'},
            },
            MaxAssist = 4,
            Retry = true,
            WaitSecondsAfterDeath = 300,
        }
    )
end

function BuildNukeSubs()
    -- Extra energy to help out with the nuke production
    -- CybranM3Base:AddBuildGroupDifficulty('M3_Cybran_Extra_Energy', 95)

    local quantity = {1, 2, 3}
    local opai = CybranM3Base:AddOpAI('NavalAttacks', 'M3_Cybran_NukeSub_Attack_1',
        {
            MasterPlatoonFunction = {CustomFunctions, 'M3CybranNukeSubmarinesHandle'},
            PlatoonData = {
                TargetChain = 'Nuke_Players_Chain',
                MoveChain = 'M3_Cybran_NukeSubs_Wait_Chain',
                NukeDelay = {12 * 60, 10 * 60, 8 * 60},
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity('NukeSubmarines', quantity[Difficulty])
    opai:SetFormation('NoFormation')
end

---------------------
-- M3 Cybran Sea Base
---------------------
function CybranM3SeaBaseAI()
    CybranM3SeaBase:InitializeDifficultyTables(ArmyBrains[Cybran], 'M3_Cybran_Sea_Base', 'M3_Cybran_Sea_Base_Marker', 50, {M3_Cybran_Sea_Base = 100})
    CybranM3SeaBase:StartEmptyBase({{2, 4, 5}, {1, 2, 3}})
    CybranM3SeaBase:SetMaximumConstructionEngineers(2)

    CybranM3Base:AddExpansionBase('M3_Cybran_Sea_Base', 1)
    
    CybranM3SeaBaseNavalAttacks()
end

function CybranM3SeaBaseNavalAttacks()
    local DefaultPatrolChains = {
        'M3_Cybran_Sea_Base_Naval_Attack_Chain_1',
    }

    local opai = nil
    local quantity = {}
    local trigger = {}

    -- 2, 2 --- 2, 5 --- 3, 5

    quantity = {6, 9, 11}
    opai = CybranM3SeaBase:AddOpAI('NavalAttacks', 'M3_Cybran_Sea_Base_Naval_Attack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Cybran_Sea_Base_Naval_Attack_Chain_1',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Frigates', quantity[Difficulty])
    opai:SetFormation('AttackFormation')

    quantity = {6, 9, 11}
    opai = CybranM3SeaBase:AddOpAI('NavalAttacks', 'M3_Cybran_Sea_Base_Naval_Attack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Cybran_Sea_Base_Naval_Attack_Chain_1',
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Submarines', quantity[Difficulty])
    opai:SetFormation('AttackFormation')

    quantity = {6, 8, 10}
    opai = CybranM3SeaBase:AddOpAI('NavalAttacks', 'M3_Cybran_Sea_Base_Naval_Attack_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Cybran_Sea_Base_Naval_Attack_Chain_1',
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity({'Frigates', 'Submarines'}, quantity[Difficulty])
    opai:SetFormation('AttackFormation')

    quantity = {8, 11, 14}
    trigger = {400, 350, 300}
    opai = CybranM3SeaBase:AddOpAI('NavalAttacks', 'M3_Cybran_Sea_Base_Naval_Attack_4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Cybran_Sea_Base_Naval_Attack_Chain_1',
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('Frigates', quantity[Difficulty])
    opai:SetFormation('AttackFormation')
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers', 'Order'}, trigger[Difficulty], categories.ALLUNITS, '>='})

    quantity = {12, 18, 22}
    trigger = {450, 400, 350}
    opai = CybranM3SeaBase:AddOpAI('NavalAttacks', 'M3_Cybran_Sea_Base_Naval_Attack_5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Cybran_Sea_Base_Naval_Attack_Chain_1',
            },
            Priority = 140,
        }
    )
    opai:SetChildQuantity({'Frigates', 'Submarines'}, quantity[Difficulty])
    opai:SetFormation('AttackFormation')
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers', 'Order'}, trigger[Difficulty], categories.ALLUNITS, '>='})

    quantity = {{2, 4}, {2, 10}, {3, 10}}
    trigger = {15, 13, 11}
    opai = CybranM3SeaBase:AddOpAI('NavalAttacks', 'M3_Cybran_Sea_Base_Naval_Attack_6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Cybran_Sea_Base_Naval_Attack_Chain_1',
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity({'Destroyers', 'Frigates'}, quantity[Difficulty])
    opai:SetFormation('AttackFormation')
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers', 'Order'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE - categories.TECH1, '>='})

    quantity = {{2, 2}, {2, 5}, {3, 5}}
    trigger = {20, 18, 16}
    opai = CybranM3SeaBase:AddOpAI('NavalAttacks', 'M3_Cybran_Sea_Base_Naval_Attack_7',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Cybran_Sea_Base_Naval_Attack_Chain_1',
            },
            Priority = 160,
        }
    )
    opai:SetChildQuantity({'T2Submarines', 'Submarines'}, quantity[Difficulty])
    opai:SetFormation('AttackFormation')
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers', 'Order'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE - categories.TECH1, '>='})

    quantity = {{4, 4}, {4, 10}, {6, 10}}
    trigger = {15, 13, 11}
    opai = CybranM3SeaBase:AddOpAI('NavalAttacks', 'M3_Cybran_Sea_Base_Naval_Attack_8',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Cybran_Sea_Base_Naval_Attack_Chain_1',
            },
            Priority = 170,
        }
    )
    opai:SetChildQuantity({'T2Submarines', 'Submarines'}, quantity[Difficulty])
    opai:SetFormation('AttackFormation')
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers', 'Order'}, trigger[Difficulty], categories.SUBMERSIBLE, '>='})
end
