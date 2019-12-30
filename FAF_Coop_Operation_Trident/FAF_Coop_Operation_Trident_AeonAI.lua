local BaseManager = import('/lua/ai/opai/basemanager.lua')
local CustomFunctions = '/maps/FAF_Coop_Operation_Trident/FAF_Coop_Operation_Trident_CustomFunctions.lua'
local SPAIFileName = '/lua/ScenarioPlatoonAI.lua'

---------
-- Locals
---------
local Aeon = 2
local Difficulty = ScenarioInfo.Options.Difficulty

----------------
-- Base Managers
----------------
local M2AeonMainBase = BaseManager.CreateBaseManager()
local M2AeonResourceBase = BaseManager.CreateBaseManager()

--------------------
-- M2 Aeon Main Base
--------------------
function M2AeonMainBaseAI()
    M2AeonMainBase:InitializeDifficultyTables(ArmyBrains[Aeon], 'M2_Aeon_Main_Base', 'M2_Aeon_Main_Base_Marker', 90, {Aeon_Base = 100})
    M2AeonMainBase:StartNonZeroBase({{7, 11, 16}, {6, 9, 13}})
    M2AeonMainBase:SetSupportACUCount(1)
    M2AeonMainBase:SetSACUUpgrades({'StabilitySuppressant', 'SystemIntegrityCompensator'}, true)

    M2AeonMainBase:SetActive('AirScouting', true)
    M2AeonMainBase:SetActive('LandScouting', true)

    M2AeonMainBaseAirAttacks()
    M2AeonMainBaseLandAttacks()
    M2AeonMainBaseNavalAttacks()
end

function M2AeonMainBaseAirAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    ----------
    -- Attacks
    ----------
    quantity = {3, 4, 5}
    opai = M2AeonMainBase:AddOpAI('AirAttacks', 'M2_Aeon_AirAttack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M2_Aeon_Land_Attack_Chain_1',
                    'M2_Aeon_Land_Attack_Chain_2',
                    'M2_Aeon_Naval_Attack_Player_Chain',
                },
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Bombers', quantity[Difficulty])

    quantity = {6, 8, 10}
    opai = M2AeonMainBase:AddOpAI('AirAttacks', 'M2_Aeon_AirAttack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M2_Aeon_Land_Attack_Chain_1',
                    'M2_Aeon_Land_Attack_Chain_2',
                    'M2_Aeon_Naval_Attack_Player_Chain',
                },
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Bombers', quantity[Difficulty])

    quantity = {9, 12, 15}
    opai = M2AeonMainBase:AddOpAI('AirAttacks', 'M2_Aeon_AirAttack_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'SplitPatrolThread'},
            PlatoonData = {
                PatrolChains = {
                    'M2_Aeon_Land_Attack_Chain_1',
                    'M2_Aeon_Land_Attack_Chain_2',
                    'M2_Aeon_Naval_Attack_Player_Chain',
                },
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('Bombers', quantity[Difficulty])

    quantity = {6, 8, 10}
    opai = M2AeonMainBase:AddOpAI('AirAttacks', 'M2_Aeon_AirAttack_4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M2_Aeon_Land_Attack_Chain_1',
                    'M2_Aeon_Land_Attack_Chain_2',
                    'M2_Aeon_Naval_Attack_Player_Chain',
                },
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])

    quantity = {6, 8, 10}
    trigger = {35, 30, 25}
    opai = M2AeonMainBase:AddOpAI('AirAttacks', 'M2_Aeon_AirAttack_5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M2_Aeon_Land_Attack_Chain_1',
                    'M2_Aeon_Land_Attack_Chain_2',
                    'M2_Aeon_Naval_Attack_Player_Chain',
                },
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('CombatFighters', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.AIR *  categories.MOBILE, '>='})
    

    quantity = {6, 8, 10}
    opai = M2AeonMainBase:AddOpAI('AirAttacks', 'M2_Aeon_AirAttack_6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Aeon_Naval_Attack_Player_Chain',
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('TorpedoBombers', quantity[Difficulty])

    ----------
    -- Patrols
    ----------
    quantity = {6, 8, 10}
    opai = M2AeonMainBase:AddOpAI('AirAttacks', 'M2_Aeon_AirDefense_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Aeon_Air_Patrol_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('CombatFighters', quantity[Difficulty])
    opai:SetFormation('NoFormation')
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})

    quantity = {6, 8, 10}
    opai = M2AeonMainBase:AddOpAI('AirAttacks', 'M2_Aeon_AirDefense_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Aeon_Air_Patrol_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('TorpedoBombers', quantity[Difficulty])
    opai:SetFormation('NoFormation')
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})

    quantity = {6, 8, 10}
    opai = M2AeonMainBase:AddOpAI('AirAttacks', 'M2_Aeon_AirDefense_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Aeon_Air_Patrol_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    opai:SetFormation('NoFormation')
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})

    -- Mercy snipe on medium and hard difficulty
    if Difficulty >= 2 then
        quantity = {0, 4, 5}
        opai = M2AeonMainBase:AddOpAI('AirAttacks', 'M2_Aeon_MercyAttack_1',
            {
                MasterPlatoonFunction = {CustomFunctions, 'MercyThread'},
                PlatoonData = {
                    Distance = 100,
                    Base = 'M2_Aeon_Main_Base',
                    PatrolChain = 'M2_Aeon_Land_Attack_Chain_' .. Random(1, 2),
                },
                Priority = 150,
            }
        )
        opai:SetChildQuantity('GuidedMissiles', quantity[Difficulty])
        opai:AddBuildCondition(CustomFunctions, 'PlayersACUsNearBase', {'default_brain', 'M2_Aeon_Main_Base', 100})
    end
end

function M2AeonMainBaseLandAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    -- Extra engineers assisting T2 naval factories, all T2 factories has to be built
    -- Count is {X, 0} since the platoon contains shields/stealth as well and we want just the engineers. And too lazy to make a new platoon rn.
    quantity = {{3, 0}, {6, 0}, {9, 0}}
    opai = M2AeonMainBase:AddOpAI('EngineerAttack', 'M2_Aeon_Assist_Engineers_1',
        {
            MasterPlatoonFunction = {CustomFunctions, 'AssistNavalFactories'},
            PlatoonData = {
                BaseName = 'M2_Aeon_Main_Base',
                Factories = categories.TECH2 * categories.NAVAL * categories.FACTORY,
            },
            Priority = 170,
        }
    )
    opai:SetChildQuantity('T2Engineers', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
        'HaveGreaterThanUnitsWithCategory', {'default_brain', 2, categories.TECH2 * categories.NAVAL * categories.FACTORY})

    -- Engineer for reclaiming if there's less than 4000 Mass in the storage
    quantity = {6, 8, 10}
    opai = M2AeonMainBase:AddOpAI('EngineerAttack', 'M2_Aeon_Reclaim_Engineers_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'SplitPatrolThread'},
            PlatoonData = {
                PatrolChains = {
                    'M2_Aeon_Land_Attack_Chain_1',
                    'M2_Aeon_Land_Attack_Chain_2',
                    'M2_Aeon_Amphibious_Attack_Chain_1',
                    'M2_Aeon_Amphibious_Attack_Chain_2',
                    'M2_Aeon_Naval_Attack_Player_Chain',
                },
            },
            Priority = 190,
        }
    )
    opai:SetChildQuantity('T1Engineers', quantity[Difficulty])
    opai:AddBuildCondition(CustomFunctions, 'LessMassStorageCurrent', {'default_brain', 4000})

    ----------
    -- Attacks
    ----------
    quantity = {6, 8, 10}
    opai = M2AeonMainBase:AddOpAI('BasicLandAttack', 'M1_Aeon_Land_Attack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M2_Aeon_Land_Attack_Chain_1',
                    'M2_Aeon_Land_Attack_Chain_2',
                    'M2_Aeon_Amphibious_Attack_Chain_1',
                    'M2_Aeon_Amphibious_Attack_Chain_2',
                },
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('LightTanks', quantity[Difficulty])
    opai:SetFormation('AttackFormation')

    quantity = {6, 8, 10}
    opai = M2AeonMainBase:AddOpAI('BasicLandAttack', 'M1_Aeon_Land_Attack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M2_Aeon_Land_Attack_Chain_1',
                    'M2_Aeon_Land_Attack_Chain_2',
                },
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('LightArtillery', quantity[Difficulty])
    opai:SetFormation('AttackFormation')

    quantity = {{2, 4}, {3, 6}, {4, 6}}
    opai = M2AeonMainBase:AddOpAI('BasicLandAttack', 'M1_Aeon_Land_Attack_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M2_Aeon_Land_Attack_Chain_1',
                    'M2_Aeon_Land_Attack_Chain_2',
                },
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'HeavyTanks', 'LightTanks'}, quantity[Difficulty])

    quantity = {9, 12, 15}
    trigger = {300, 250, 200}
    opai = M2AeonMainBase:AddOpAI('BasicLandAttack', 'M1_Aeon_Land_Attack_4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M2_Aeon_Land_Attack_Chain_1',
                    'M2_Aeon_Land_Attack_Chain_2',
                    'M2_Aeon_Amphibious_Attack_Chain_1',
                    'M2_Aeon_Amphibious_Attack_Chain_2',
                },
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('LightTanks', quantity[Difficulty])
    opai:SetFormation('AttackFormation')
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers', 'Cybran'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL, '>='})

    quantity = {9, 12, 15}
    trigger = {300, 250, 200}
    opai = M2AeonMainBase:AddOpAI('BasicLandAttack', 'M1_Aeon_Land_Attack_5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M2_Aeon_Land_Attack_Chain_1',
                    'M2_Aeon_Land_Attack_Chain_2',
                },
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('LightArtillery', quantity[Difficulty])
    opai:SetFormation('AttackFormation')
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers', 'Cybran'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL, '>='})

    quantity = {6, 8, 10}
    trigger = {360, 330, 300}
    opai = M2AeonMainBase:AddOpAI('BasicLandAttack', 'M1_Aeon_Land_Attack_6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M2_Aeon_Land_Attack_Chain_1',
                    'M2_Aeon_Land_Attack_Chain_2',
                },
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'HeavyTanks', 'LightTanks'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers', 'Cybran'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL, '>='})

    quantity = {3, 4, 5}
    trigger = {350, 300, 250}
    opai = M2AeonMainBase:AddOpAI('BasicLandAttack', 'M1_Aeon_Ambhibious_Attack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M2_Aeon_Amphibious_Attack_Chain_1',
                    'M2_Aeon_Amphibious_Attack_Chain_2',
                },
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('AmphibiousTanks', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers', 'Cybran'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL, '>='})

    quantity = {3, {4, 1}, {6, 3}}
    trigger = {16, 13, 10}
    opai = M2AeonMainBase:AddOpAI('BasicLandAttack', 'M1_Aeon_Land_Attack_7',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M2_Aeon_Land_Attack_Chain_1',
                    'M2_Aeon_Land_Attack_Chain_2',
                },
            },
            Priority = 120,
        }
    )
    if Difficulty == 1 then
        opai:SetChildQuantity('MobileMissiles', quantity[Difficulty])
    else
        opai:SetChildQuantity({'MobileMissiles', 'MobileFlak'}, quantity[Difficulty])
    end
    opai:SetFormation('AttackFormation')
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers', 'Cybran'}, trigger[Difficulty], categories.DEFENSE * categories.STRUCTURE * categories.TECH2, '>='})

    quantity = {6, 8, 10}
    trigger = {400, 370, 340}
    opai = M2AeonMainBase:AddOpAI('BasicLandAttack', 'M1_Aeon_Land_Attack_8',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M2_Aeon_Land_Attack_Chain_1',
                    'M2_Aeon_Land_Attack_Chain_2',
                },
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('HeavyTanks', quantity[Difficulty])
    opai:SetFormation('AttackFormation')
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers', 'Cybran'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL, '>='})

    quantity = {6, 8, 10}
    trigger = {60, 50, 40}
    opai = M2AeonMainBase:AddOpAI('BasicLandAttack', 'M1_Aeon_Land_Attack_9',
        {
            MasterPlatoonFunction = {SPAIFileName, 'SplitPatrolThread'},
            PlatoonData = {
                PatrolChains = {
                    'M2_Aeon_Land_Attack_Chain_1',
                    'M2_Aeon_Land_Attack_Chain_2',
                    'M2_Aeon_Amphibious_Attack_Chain_1',
                    'M2_Aeon_Amphibious_Attack_Chain_2',
                },
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('MobileFlak', quantity[Difficulty])
    opai:SetFormation('AttackFormation')
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers', 'Cybran'}, trigger[Difficulty], categories.AIR * categories.MOBILE, '>='})

    quantity = {{4, 2}, {5, 2, 1}, {6, 2, 2}}
    trigger = {8, 6, 4}
    opai = M2AeonMainBase:AddOpAI('BasicLandAttack', 'M1_Aeon_Ambhibious_Attack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M2_Aeon_Amphibious_Attack_Chain_1',
                    'M2_Aeon_Amphibious_Attack_Chain_2',
                },
            },
            Priority = 120,
        }
    )
    if Difficulty == 1 then
        opai:SetChildQuantity({'AmphibiousTanks', 'MobileFlak'}, quantity[Difficulty])
    else
        opai:SetChildQuantity({'AmphibiousTanks', 'MobileFlak', 'MobileShields'}, quantity[Difficulty])
    end
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers', 'Cybran'}, trigger[Difficulty], categories.TECH2 * categories.NAVAL * categories.MOBILE, '>='})

    quantity = {6, {8, 2}, {10, 4}}
    trigger = {26, 23, 20}
    opai = M2AeonMainBase:AddOpAI('BasicLandAttack', 'M1_Aeon_Land_Attack_10',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M2_Aeon_Land_Attack_Chain_1',
                    'M2_Aeon_Land_Attack_Chain_2',
                },
            },
            Priority = 130,
        }
    )
    if Difficulty == 1 then
        opai:SetChildQuantity('MobileMissiles', quantity[Difficulty])
    else
        opai:SetChildQuantity({'MobileMissiles', 'MobileFlak'}, quantity[Difficulty])
    end
    opai:SetFormation('AttackFormation')
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers', 'Cybran'}, trigger[Difficulty], categories.DEFENSE * categories.STRUCTURE * categories.TECH2, '>='})

    quantity = {{6, 2, 1}, {8, 2, 2}, {10, 2, 3}}
    trigger = {12, 10, 8}
    opai = M2AeonMainBase:AddOpAI('BasicLandAttack', 'M1_Aeon_Ambhibious_Attack_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M2_Aeon_Amphibious_Attack_Chain_1',
                    'M2_Aeon_Amphibious_Attack_Chain_2',
                },
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity({'AmphibiousTanks', 'MobileFlak', 'MobileShields'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers', 'Cybran'}, trigger[Difficulty], categories.TECH2 * categories.NAVAL * categories.MOBILE, '>='})

    quantity = {9, 12, 15}
    trigger = {550, 475, 400}
    opai = M2AeonMainBase:AddOpAI('BasicLandAttack', 'M1_Aeon_Land_Attack_11',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M2_Aeon_Land_Attack_Chain_1',
                    'M2_Aeon_Land_Attack_Chain_2',
                },
            },
            Priority = 140,
        }
    )
    opai:SetChildQuantity('HeavyTanks', quantity[Difficulty])
    opai:SetFormation('AttackFormation')
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers', 'Cybran'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL, '>='})
end

function M2AeonMainBaseNavalAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    ----------
    -- Attacks
    ----------
    -- Attack the Aeon base once in a while
    --opai = M2AeonMainBase:AddOpAI('NavalAttacks', 'M2_Aeon_NavalAttack_UEF_1',
    --    {
    --        MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
    --        PlatoonData = {
    --            PatrolChain = 'M2_Aeon_Naval_Attack_UEF_Chain',
    --        },
    --        Priority = 200,
    --    }
    --)
    --opai:SetChildQuantity({'Destroyers', 'Cruisers', 'T2Submarines'}, {3, 1, 4})
    --opai:SetLockingStyle('DeathTimer', {LockTimer = 360})

    quantity = {2, 3, 3}
    opai = M2AeonMainBase:AddOpAI('NavalAttacks', 'M2_Aeon_NavalAttack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Aeon_Naval_Attack_Player_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Frigates', quantity[Difficulty])

    quantity = {2, 3, 3}
    opai = M2AeonMainBase:AddOpAI('NavalAttacks', 'M2_Aeon_NavalAttack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Aeon_Naval_Attack_Player_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Submarines', quantity[Difficulty])

    quantity = {4, 6, 6}
    trigger = {10, 8, 6}
    opai = M2AeonMainBase:AddOpAI('NavalAttacks', 'M2_Aeon_NavalAttack_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Aeon_Naval_Attack_Player_Chain',
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'Frigates', 'Submarines'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers', 'Cybran'}, trigger[Difficulty], categories.NAVAL *  categories.MOBILE, '>='})

    quantity = {4, 6, 9}
    trigger = {14, 12, 10}
    opai = M2AeonMainBase:AddOpAI('NavalAttacks', 'M2_Aeon_NavalAttack_4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Aeon_Naval_Attack_Player_Chain',
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Submarines', quantity[Difficulty])
    opai:SetFormation('AttackFormation')
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers', 'Cybran'}, trigger[Difficulty], categories.T1SUBMARINE, '>='})

    quantity = {4, 6, 6}
    trigger = {16, 14, 12}
    opai = M2AeonMainBase:AddOpAI('NavalAttacks', 'M2_Aeon_NavalAttack_5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Aeon_Naval_Attack_Player_Chain',
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Frigates', quantity[Difficulty])
    opai:SetFormation('AttackFormation')
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers', 'Cybran'}, trigger[Difficulty], categories.NAVAL *  categories.MOBILE, '>='})

    quantity = {2, 3, 3}
    trigger = {7, 6, 5}
    opai = M2AeonMainBase:AddOpAI('NavalAttacks', 'M2_Aeon_NavalAttack_7',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Aeon_Naval_Attack_Player_Chain',
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('T2Submarines', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers', 'Cybran'}, trigger[Difficulty], categories.T2SUBMARINE, '>='})

    quantity = {4, 6, 9}
    trigger = {17, 16, 15}
    opai = M2AeonMainBase:AddOpAI('NavalAttacks', 'M2_Aeon_NavalAttack_8',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Aeon_Naval_Attack_Player_Chain',
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('T2Submarines', quantity[Difficulty])
    opai:SetFormation('AttackFormation')
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers', 'Cybran'}, trigger[Difficulty], categories.T2SUBMARINE, '>='})

    quantity = {{2, 2}, {2, 4}, {2, 1, 3}}
    trigger = {8, 6, 4}
    opai = M2AeonMainBase:AddOpAI('NavalAttacks', 'M2_Aeon_NavalAttack_9',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Aeon_Naval_Attack_Player_Chain',
            },
            Priority = 120,
        }
    )
    if Difficulty <= 2 then
        opai:SetChildQuantity({'Destroyers', 'Frigates'}, quantity[Difficulty])
    else
        opai:SetChildQuantity({'Destroyers', 'Cruisers', 'Frigates'}, quantity[Difficulty])
    end
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers', 'Cybran'}, trigger[Difficulty], categories.TECH2 * categories.NAVAL * categories.MOBILE, '>='})

    quantity = {2, 3, 3}
    trigger = {50, 40, 30}
    opai = M2AeonMainBase:AddOpAI('NavalAttacks', 'M2_Aeon_NavalAttack_10',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Aeon_Naval_Attack_Player_Chain',
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('Cruisers', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers', 'Cybran'}, trigger[Difficulty], categories.AIR * categories.MOBILE, '>='})

    -- Extra cruisers if there's a lot of T2 Bombers
    quantity = {2, 3, 3}
    trigger = {50, 40, 30}
    opai = M2AeonMainBase:AddOpAI('NavalAttacks', 'M2_Aeon_NavalAttack_11',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Aeon_Naval_Attack_Player_Chain',
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('Cruisers', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers', 'Cybran'}, trigger[Difficulty],categories.TECH2 * categories.BOMBER *  categories.AIR * categories.MOBILE, '>='})

    quantity = {{3, 1, 3}, {4, 1, 6}, {4, 2, 3}}
    trigger = {11, 9, 7}
    opai = M2AeonMainBase:AddOpAI('NavalAttacks', 'M2_Aeon_NavalAttack_12',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Aeon_Naval_Attack_Player_Chain',
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity({'Destroyers', 'Cruisers', 'Frigates'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers', 'Cybran'}, trigger[Difficulty], categories.TECH2 * categories.NAVAL * categories.MOBILE, '>='})
end

------------------------
-- M2 Aeon Resource Base
------------------------
function M2AeonResourceBaseAI()
    M2AeonResourceBase:InitializeDifficultyTables(ArmyBrains[Aeon], 'M2_Aeon_Resource_Base', 'M2_Aeon_Resource_Base_Marker', 30, {Resource_Base = 100})
    M2AeonResourceBase:StartEmptyBase(1)
    M2AeonMainBase:AddExpansionBase('M2_Aeon_Resource_Base', 1)
end