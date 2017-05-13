local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'

---------
-- Locals
---------
local UEF = 2
local Difficulty = ScenarioInfo.Options.Difficulty

----------------
-- Base Managers
----------------
local UEFM3MainBase = BaseManager.CreateBaseManager()

-------------------
-- UEF M3 Main Base
-------------------
function UEFM3MainBaseAI()
    UEFM3MainBase:InitializeDifficultyTables(ArmyBrains[UEF], 'M3_Main_Base', 'M3_Main_Base_Marker', 90, {M3_Main_Base = 100})
    UEFM3MainBase:StartNonZeroBase({{8, 11, 15}, {6, 9, 12}})

    ForkThread(function()
        WaitSeconds(1)
        UEFM3MainBase:AddBuildGroupDifficulty('M3_Main_Base_Support_Factories', 100, true)
    end)

    UEFM3MainBaseAirAttacks()
    UEFM3MainBaseLandAttacks()
    UEFM3MainBaseNavalAttacks()
end

function UEFM3MainBaseAirAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    -- Transport Builder
    opai = UEFM3MainBase:AddOpAI('EngineerAttack', 'M3_TransportBuilder',
        {
            MasterPlatoonFunction = {SPAIFileName, 'LandAssaultWithTransports'},
            PlatoonData = {
                TransportReturn = 'MainBase_Patrol1',
            },
            Priority = 1000,
        }
    )
    opai:SetChildQuantity('T2Transports', 4)
    opai:SetLockingStyle('None')
    opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
        'HaveLessThanUnitsWithCategory', {'default_brain', 7, categories.uea0104})

    -- Air Attacks
    quantity = {4, 6, 8}
    opai = UEFM3MainBase:AddOpAI('AirAttacks', 'M3_AirAttack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Air_Attack_Chain_1',
                                'M3_Air_Attack_Chain_2',
                                'M3_Air_Attack_Chain_3',
                                'M3_Air_Attack_Chain_4'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Bombers', quantity[Difficulty])

    quantity = {6, 9, 12}
    opai = UEFM3MainBase:AddOpAI('AirAttacks', 'M3_AirAttack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Air_Attack_Chain_1',
                                'M3_Air_Attack_Chain_2',
                                'M3_Air_Attack_Chain_3',
                                'M3_Air_Attack_Chain_4'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Bombers', quantity[Difficulty])

    quantity = {4, 6, 8}
    opai = UEFM3MainBase:AddOpAI('AirAttacks', 'M3_AirAttack_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Air_Attack_Chain_1',
                                'M3_Air_Attack_Chain_2',
                                'M3_Air_Attack_Chain_3',
                                'M3_Air_Attack_Chain_4'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])

    quantity = {6, 9, 12}
    opai = UEFM3MainBase:AddOpAI('AirAttacks', 'M3_AirAttack_4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Air_Attack_Chain_1',
                                'M3_Air_Attack_Chain_2',
                                'M3_Air_Attack_Chain_3',
                                'M3_Air_Attack_Chain_4'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])

    quantity = {8, 12, 16}
    trigger = {35, 30, 25}
    opai = UEFM3MainBase:AddOpAI('AirAttacks', 'M3_AirAttack_5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackLocationList'},
            PlatoonData = {
                LocationChain = 'ErisAll_Chain',
                High = true,
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('Interceptors', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, 30, categories.MOBILE * categories.AIR, '>='})

    -- Air Defense

end

function UEFM3MainBaseLandAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    -- Enginners for reclaim
    quantity = {4, 6, 8}
    opai = UEFM3MainBase:AddOpAI('EngineerAttack', 'M3_Reclaim_Engineers_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'SplitPatrolThread'},
            PlatoonData = {
                PatrolChains = {'M3_Naval_Attack_Chain_1',
                                'M3_Naval_Attack_Chain_2',
                                'M3_Naval_Attack_Chain_3',
                                'M3_Air_Attack_Chain_3',
                                'M3_Air_Attack_Chain_4'},
            },
            Priority = 200,
        }
    )
    opai:SetChildQuantity('T1Engineers', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})

    -- Amphibious attacks
    quantity = {4, 6, 8}
    opai = UEFM3MainBase:AddOpAI('BasicLandAttack', 'M3_AmphibiousAttack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Naval_Attack_Chain_1',
                                'M3_Naval_Attack_Chain_2',
                                'M3_Naval_Attack_Chain_3'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('AmphibiousTanks', quantity[Difficulty])
    opai:SetFormation('AttackFormation')
    opai:SetLockingStyle('None')

    -- Drops
    quantity = {12, 18, 24}
    opai = UEFM3MainBase:AddOpAI('BasicLandAttack', 'M3_TransportAttack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain = 'ErisLand_Chain',
                LandingChain = 'ErisLand_Chain',
                TransportReturn = 'MainBase_Patrol1',
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('HeavyTanks', quantity[Difficulty])
end

function UEFM3MainBaseNavalAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    quantity = {4, 6, 8}
    opai = UEFM3MainBase:AddNavalAI('M3_Naval_Attack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Naval_Attack_Chain_1',
                                'M3_Naval_Attack_Chain_2',
                                'M3_Naval_Attack_Chain_3',
                },
            },
            MaxFrigates = quantity[Difficulty],
            MinFrigates = quantity[Difficulty],
            Priority = 100,
        }
    )
    opai:SetChildActive('T2', false)
    opai:SetChildActive('T3', false)

    quantity = {6, 9, 12}
    trigger = {11, 13, 15}
    opai = UEFM3MainBase:AddNavalAI('M3_Naval_Attack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Naval_Attack_Chain_1',
                                'M3_Naval_Attack_Chain_2',
                                'M3_Naval_Attack_Chain_3',
                },
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

    quantity = {10, 15, 20}
    opai = UEFM3MainBase:AddNavalAI('M3_Naval_Attack_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Naval_Attack_Chain_1',
                                'M3_Naval_Attack_Chain_2',
                                'M3_Naval_Attack_Chain_3',
                },
            },
            MaxFrigates = quantity[Difficulty],
            MinFrigates = quantity[Difficulty],
            EnabledTypes = {'Destroyer'},
            Priority = 120,
        }
    )
    opai:SetChildActive('T1', false)
    opai:SetChildActive('T3', false)

    quantity = {12, 18, 24}
    opai = UEFM3MainBase:AddNavalAI('M3_Naval_Attack_4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Naval_Attack_Chain_1',
                                'M3_Naval_Attack_Chain_2',
                                'M3_Naval_Attack_Chain_3',
                },
            },
            MaxFrigates = quantity[Difficulty],
            MinFrigates = quantity[Difficulty],
            EnabledTypes = {'Frigate', 'Submarine', 'Destroyer'},
            DisableTypes = {['T2Submarine'] = true},
            Priority = 130,
        }
    )
    opai:SetChildActive('T1', false)
    opai:SetChildActive('T3', false)

    quantity = {40, 60, 80}
    trigger = {50, 40, 30}
    opai = UEFM3MainBase:AddNavalAI('M3_Naval_Attack_5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Naval_Attack_Chain_1',
                                'M3_Naval_Attack_Chain_2',
                                'M3_Naval_Attack_Chain_3',
                },
            },
            MaxFrigates = quantity[Difficulty],
            MinFrigates = quantity[Difficulty],
            EnabledTypes = {'Cruiser'},
            Priority = 140,
        }
    )
    opai:SetChildActive('T1', false)
    opai:SetChildActive('T3', false)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE * categories.TECH2, '>='})
end