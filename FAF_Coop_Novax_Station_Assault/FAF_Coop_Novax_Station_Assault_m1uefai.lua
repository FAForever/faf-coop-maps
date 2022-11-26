local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/ScenarioPlatoonAI.lua'

---------
-- Locals
---------
local UEF = 2
local Difficulty = ScenarioInfo.Options.Difficulty

----------------
-- Base Managers
----------------
local UEFM1Base = BaseManager.CreateBaseManager()

--------------
-- UEF M1 Base
--------------
function UEFM1BaseAI()
    UEFM1Base:InitializeDifficultyTables(ArmyBrains[UEF], 'M1_UEF_Base', 'M1_UEF_Base_Marker', 80, {M1_UEF_Base = 100})
    UEFM1Base:StartNonZeroBase({{10, 15, 20}, {9, 13, 17}})
    UEFM1Base:SetActive('AirScouting', true)

    UEFM1BaseAirAttacks()
    UEFM1BaseNavalAttacks()
end

function UEFM1BaseAirAttacks()
    local DefaultPatrolChains = {
        'M1_UEF_Naval_Attack_East_Chain',
        'M1_UEF_Naval_Attack_Middle_Chain',
        'M1_UEF_Naval_Attack_West_Chain',
    }

    local opai = nil
    local quantity = {}
    local trigger = {}

    -- Air Attacks
    quantity = {4, 6, 8}
    opai = UEFM1Base:AddOpAI('AirAttacks', 'M1_UEF_AirAttack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'SplitPatrolThread'},
            PlatoonData = {
                PatrolChains = DefaultPatrolChains,
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('Bombers', quantity[Difficulty])

    quantity = {4, 6, 8}
    trigger = {6, 4, 2}
    opai = UEFM1Base:AddOpAI('AirAttacks', 'M1_UEF_AirAttack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = DefaultPatrolChains,
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('interceptors', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.TECH2, '>='})

    quantity = {3, 3, 4}
    trigger = {15, 13, 9}
    opai = UEFM1Base:AddOpAI('AirAttacks', 'M1_UEF_AirAttack_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = DefaultPatrolChains,
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('CombatFighters', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.TECH2, '>='})

    quantity = {3, 3, 4}
    trigger = {19, 16, 14}
    opai = UEFM1Base:AddOpAI('AirAttacks', 'M1_UEF_AirAttack_4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = DefaultPatrolChains,
            },
            Priority = 140,
        }
    )
    opai:SetChildQuantity('CombatFighters', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.TECH2, '>='})

    quantity = {3, 3, 4}
    trigger = {9, 7, 5}
    opai = UEFM1Base:AddOpAI('AirAttacks', 'M1_UEF_AirAttack_5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = DefaultPatrolChains,
            },
            Priority = 140,
        }
    )
    opai:SetChildQuantity('TorpedoBombers', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.NAVAL * categories.TECH2, '>='})

    -- Air Patrol
    quantity = {1, 2, 3}
    for i = 1, 3 do
        opai = UEFM1Base:AddOpAI('AirAttacks', 'M1_UEF_AirDefense_1_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M1_UEF_Base_Air_Patrol_Chain',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('CombatFighters', quantity[Difficulty])
        opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    end

    quantity = {3, 3, 4}
    for i = 1, 2 do
        opai = UEFM1Base:AddOpAI('AirAttacks', 'M1_UEF_AirDefense_2_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M1_UEF_Base_Air_Patrol_Chain',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('Gunships', quantity[Difficulty])
        opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    end
end

function UEFM1BaseNavalAttacks()
    local DefaultPatrolChains = {
        'M1_UEF_Naval_Attack_East_Chain',
        'M1_UEF_Naval_Attack_Middle_Chain',
        'M1_UEF_Naval_Attack_West_Chain',
    }

    local opai = nil
    local quantity = {}
    local trigger = {}

    quantity = {4, 6, 8}
    opai = UEFM1Base:AddOpAI('NavalAttacks', 'M1_UEF_NavalAttack_1',
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

    quantity = {{2, 2}, {4, 2}, {6, 2}}
    opai = UEFM1Base:AddOpAI('NavalAttacks', 'M1_UEF_NavalAttack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = DefaultPatrolChains,
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'Frigates', 'Submarines'}, quantity[Difficulty])
    opai:SetFormation('AttackFormation')

    quantity = {6, 7, 9}
    trigger = {10, 8, 6}
    for i = 1, 2 do
        opai = UEFM1Base:AddNavalAI('M1_UEF_NavalAttack_3_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
                PlatoonData = {
                    PatrolChains = DefaultPatrolChains,
                },
                EnabledTypes = {'Frigate', 'Submarine', 'Destroyer'},
                MaxFrigates = quantity[Difficulty],
                MinFrigates = quantity[Difficulty],
                Priority = 110,
                Overrides = {
                    CORE_TO_SUBS = 0.5,
                },
                DisableTypes = {['T2Submarine'] = true},
            }
        )
        opai:SetChildActive('T3', false)
        opai:SetFormation('AttackFormation')
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
            'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.TECH2, '>='})
    end
end