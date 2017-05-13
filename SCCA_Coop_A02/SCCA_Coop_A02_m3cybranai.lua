local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'

---------
-- Locals
---------
local Cybran = 2
local Difficulty = ScenarioInfo.Options.Difficulty

----------------
-- Base Managers
----------------
local CybranM3WestBase = BaseManager.CreateBaseManager()
local CybranM3EastBase = BaseManager.CreateBaseManager()

----------------------
-- Cybran M3 West Base
----------------------
function CybranM3WestBaseAI()
    CybranM3WestBase:InitializeDifficultyTables(ArmyBrains[Cybran], 'M3_West_Base', 'M3_Base_West', 80, {M3_West_Base = 100})
    CybranM3WestBase:StartNonZeroBase({{3, 5, 7}, {3, 4, 5}})
    CybranM3WestBase:SetActive('AirScouting', true)

    ForkThread(function()
        WaitSeconds(1)
        CybranM3WestBase:AddBuildGroupDifficulty('M3_West_Base_Support_Factroeis', 100, true)
    end)

    CybranM3WestBaseAirAttacks()
    CybranM3WestBaseLandAttacks()
    CybranM3WestBaseNavalAttacks()
end

function CybranM3WestBaseAirAttacks()
	local opai = nil
	local trigger = {}
	local quantity = {}

    -- Bombers
    quantity = {6, 8, 10}
    opai = CybranM3WestBase:AddOpAI('AirAttacks', 'M3_West_AirAttack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Attack_Route1',
                                'M1_Attack_Route2',
                                'M1_Attack_Route3'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Bombers', quantity[Difficulty])
    opai:SetLockingStyle('None')

    -- Interceptors
    quantity = {10, 12, 14}
    trigger = {20, 17, 15}
    opai = CybranM3WestBase:AddOpAI('AirAttacks', 'M3_West_AirAttack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Attack_Route1',
                                'M1_Attack_Route2',
                                'M1_Attack_Route3'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('Interceptors', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE, '>='})

    -- Air Defence
    for i = 1, 1 + Difficulty do
        opai = CybranM3WestBase:AddOpAI('AirAttacks', 'M3_West_AirDefense_1_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M3_West_Air_Patrol',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('Interceptors', 4)
    end

    for i = 1, 2 * Difficulty do
        opai = CybranM3WestBase:AddOpAI('AirAttacks', 'M3_West_AirDefense_2_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M3_West_Air_Patrol',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('Bombers', 2)
    end
end

function CybranM3WestBaseLandAttacks()
    local opai = nil
    local trigger = {}

    -- Enginners for reclaim
    quantity = {4, 6, 8}
    opai = CybranM3WestBase:AddOpAI('EngineerAttack', 'M3_West_Reclaim_Engineers_1',
    {
        MasterPlatoonFunction = {SPAIFileName, 'SplitPatrolThread'},
        PlatoonData = {
            PatrolChains = {'M1_Attack_Route1',
                            'M1_Attack_Route2',
                            'M1_Attack_Route3',
                            'M3_West_Naval_Attack',
                            'M2_North_West_Naval_Patrol'},
        },
        Priority = 200,
    })
    opai:SetChildQuantity('T1Engineers', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})

    -- Wagner attack
    quantity = {2, 4, 6}
    opai = CybranM3WestBase:AddOpAI('BasicLandAttack', 'M3_West_AmphibiousAttack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Attack_Route1',
                                'M1_Attack_Route2',
                                'M1_Attack_Route3'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('AmphibiousTanks', quantity[Difficulty])
    opai:SetFormation('AttackFormation')
    opai:SetLockingStyle('None')
end

function CybranM3WestBaseNavalAttacks()
    local opai = nil
    local trigger = {}
    local quantity = {}

    -- Attacks
    
    -- Counters Players' navy
    quantity = {2, 2, 3}
    trigger = {7, 6, 5}
    opai = CybranM3WestBase:AddNavalAI('M3_West_Naval_Attack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_West_Naval_Attack',
            },
            MaxFrigates = quantity[Difficulty],
            MinFrigates = quantity[Difficulty],
            EnableTypes = {'Frigate'},
            Priority = 110,
        }
    )
    opai:SetChildActive('T2', false)
    opai:SetChildActive('T3', false)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE, '>='})

    quantity = {4, 5, 6}
    trigger = {13, 11, 9}
    opai = CybranM3WestBase:AddNavalAI('M3_West_Naval_Attack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_West_Naval_Attack',
            },
            MaxFrigates = quantity[Difficulty],
            MinFrigates = quantity[Difficulty],
            EnableTypes = {'Frigate'},
            Priority = 120,
        }
    )
    opai:SetChildActive('T2', false)
    opai:SetChildActive('T3', false)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE, '>='})

    -- Counters auroras
    quantity = {2, 4, 6}
    opai = CybranM3WestBase:AddNavalAI('M3_West_Naval_Attack_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_West_Naval_Attack',
            },
            MaxFrigates = quantity[Difficulty],
            MinFrigates = quantity[Difficulty],
            EnableTypes = {'Frigate'},
            Priority = 130,
        }
    )
    opai:SetChildActive('T2', false)
    opai:SetChildActive('T3', false)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, 60, categories.ual0201, '>='})

    -- Defense
    quantity = {6, 8, 10}
    opai = CybranM3WestBase:AddNavalAI('M3_West_Naval_Defense_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_West_Naval_Patrol',
            },
            MaxFrigates = quantity[Difficulty],
            MinFrigates = quantity[Difficulty],
            Priority = 100,
        }
    )
    opai:SetChildActive('T2', false)
    opai:SetChildActive('T3', false)
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    opai:SetFormation('NoFormation')

    quantity = {4, 6, 8}
    opai = CybranM3WestBase:AddNavalAI('M3_West_Naval_Defense_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_North_West_Naval_Patrol',
            },
            MaxFrigates = quantity[Difficulty],
            MinFrigates = quantity[Difficulty],
            Priority = 100,
        }
    )
    opai:SetChildActive('T2', false)
    opai:SetChildActive('T3', false)
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    opai:SetFormation('NoFormation')
end

----------------------
-- Cybran M3 East Base
----------------------
function CybranM3EastBaseAI()
    CybranM3EastBase:InitializeDifficultyTables(ArmyBrains[Cybran], 'M3_East_Base', 'M3_Base_East', 80, {M3_East_Base = 100})
    CybranM3EastBase:StartNonZeroBase({{3, 5, 7}, {3, 4, 5}})
    CybranM3EastBase:SetActive('AirScouting', true)

    ForkThread(function()
        WaitSeconds(1)
        CybranM3WestBase:AddBuildGroupDifficulty('M3_East_Base_Support_Factroeis', 100, true)
    end)

    CybranM3EastBaseAirAttacks()
    CybranM3EastBaseLandAttacks()
    CybranM3EastBaseNavalAttacks()
end

function CybranM3EastBaseAirAttacks()
    local opai = nil
    local trigger = {}
    local quantity = {}

    -- Bombers
    quantity = {6, 8, 10}
    opai = CybranM3EastBase:AddOpAI('AirAttacks', 'M3_East_AirAttack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_East_Air_Attack_Chain_1',
                                'M3_East_Air_Attack_Chain_2'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Bombers', quantity[Difficulty])
    opai:SetLockingStyle('None')

    -- Interceptors
    quantity = {10, 12, 14}
    trigger = {30, 25, 20}
    opai = CybranM3EastBase:AddOpAI('AirAttacks', 'M3_East_AirAttack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_East_Air_Attack_Chain_1',
                                'M3_East_Air_Attack_Chain_2'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('Interceptors', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE, '>='})

    -- Air Defence
    for i = 1, 1 + Difficulty do
        opai = CybranM3EastBase:AddOpAI('AirAttacks', 'M3_East_AirDefense_1_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M3_East_Air_Patrol',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('Interceptors', 4)
    end

    for i = 1, 2 * Difficulty do
        opai = CybranM3EastBase:AddOpAI('AirAttacks', 'M3_East_AirDefense_2_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M3_East_Air_Patrol',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('Bombers', 2)
    end
end

function CybranM3EastBaseLandAttacks()
    local opai = nil
    local quantity = {}

    -- Enginners for reclaim
    quantity = {6, 8, 10}
    opai = CybranM3EastBase:AddOpAI('EngineerAttack', 'M3_East_Reclaim_Engineers_1',
    {
        MasterPlatoonFunction = {SPAIFileName, 'SplitPatrolThread'},
        PlatoonData = {
            PatrolChains = {'M3_East_Air_Attack_Chain_1',
                            'M3_East_Air_Attack_Chain_2',
                            'M3_East_Amphibious_Chain',
                            'M2_North_Naval_Attack',
                            'M3_East_Naval_Attack_Chain_1',
                            'M3_East_Naval_Attack_Chain_2'},
        },
        Priority = 200,
    })
    opai:SetChildQuantity('T1Engineers', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})

    -- Wagner attack
    quantity = {2, 4, 6}
    opai = CybranM3EastBase:AddOpAI('BasicLandAttack', 'M3_East_AmphibiousAttack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_East_Amphibious_Chain',
                                'M3_East_Air_Attack_Chain_2'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('AmphibiousTanks', quantity[Difficulty])
    opai:SetFormation('AttackFormation')
    opai:SetLockingStyle('None')
end

function CybranM3EastBaseNavalAttacks()
    local opai = nil
    local trigger = {}
    local quantity = {}

    -- 'M2_North_Naval_Attack' -- middle to player navy
    -- 'M3_East_Naval_Attack_Chain_1' -- east to player navy
    -- 'M3_East_Naval_Attack_Chain_2' -- attacks m2 north and sount base then player navy

    -- Counters Players' navy
    quantity = {2, 2, 3}
    trigger = {5, 4, 3}
    opai = CybranM3EastBase:AddNavalAI('M3_East_Naval_Attack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_North_Naval_Attack',
                                'M3_East_Naval_Attack_Chain_1',
                                'M3_East_Naval_Attack_Chain_2'},
            },
            MaxFrigates = quantity[Difficulty],
            MinFrigates = quantity[Difficulty],
            EnableTypes = {'Frigate'},
            Priority = 110,
        }
    )
    opai:SetChildActive('T2', false)
    opai:SetChildActive('T3', false)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE, '>='})

    quantity = {2, 4, 6}
    trigger = {8, 7, 6}
    opai = CybranM3EastBase:AddNavalAI('M3_East_Naval_Attack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_North_Naval_Attack',
                                'M3_East_Naval_Attack_Chain_1',
                                'M3_East_Naval_Attack_Chain_2'},
            },
            MaxFrigates = quantity[Difficulty],
            MinFrigates = quantity[Difficulty],
            Priority = 120,
        }
    )
    opai:SetChildActive('T2', false)
    opai:SetChildActive('T3', false)
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.7})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE, '>='})

    quantity = {4, 6, 9}
    trigger = {16, 14, 12}
    opai = CybranM3EastBase:AddNavalAI('M3_East_Naval_Attack_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_North_Naval_Attack',
                                'M3_East_Naval_Attack_Chain_1',
                                'M3_East_Naval_Attack_Chain_2'},
            },
            MaxFrigates = quantity[Difficulty],
            MinFrigates = quantity[Difficulty],
            Priority = 130,
        }
    )
    opai:SetChildActive('T2', false)
    opai:SetChildActive('T3', false)
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.7})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE, '>='})

    -- Counters auroras
    quantity = {2, 4, 6}
    trigger = {60, 50, 40}
    opai = CybranM3EastBase:AddNavalAI('M3_East_Naval_Attack_4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_North_Naval_Attack',
                                'M3_East_Naval_Attack_Chain_1',
                                'M3_East_Naval_Attack_Chain_2'},
            },
            MaxFrigates = quantity[Difficulty],
            MinFrigates = quantity[Difficulty],
            EnableTypes = {'Frigate'},
            Priority = 130,
        }
    )
    opai:SetChildActive('T2', false)
    opai:SetChildActive('T3', false)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.ual0201, '>='})

    -- Defense
    quantity = {6, 9, 12}
    opai = CybranM3EastBase:AddNavalAI('M3_East_Naval_Defense_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_East_Naval_Patrol',
            },
            MaxFrigates = quantity[Difficulty],
            MinFrigates = quantity[Difficulty],
            Priority = 100,
        }
    )
    opai:SetChildActive('T2', false)
    opai:SetChildActive('T3', false)
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    opai:SetFormation('NoFormation')
end
--[[
        MasterPlatoonFunction = {SPAIFileName, 'SplitPatrolThread'},
        PlatoonData = {
            PatrolChains = {'M3_West_Naval_Patrol'},
        },
--]]