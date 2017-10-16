local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'

---------
-- Locals
---------
local Aeon = 2
local Difficulty = ScenarioInfo.Options.Difficulty

----------------
-- Base Managers
----------------
local AeonM1AirBase = BaseManager.CreateBaseManager()
local AeonM1LandBase = BaseManager.CreateBaseManager()
local AeonM1NavalBase = BaseManager.CreateBaseManager()

-------------------
-- Aeon M1 Air Base
-------------------
function AeonM1AirBaseAI()
    AeonM1AirBase:InitializeDifficultyTables(ArmyBrains[Aeon], 'M1_Air_Base', 'M1_Air_Base_Marker', 40, {M1_Base_Air = 100})
    AeonM1AirBase:StartNonZeroBase({4, 3})
    AeonM1AirBase:SetActive('AirScouting', true)

    AeonM1AirBaseAttacks()
end

function AeonM1AirBaseAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    ---------
    -- Attack
    ---------
    quantity = {2, 2, 4}
    opai = AeonM1AirBase:AddOpAI('AirAttacks', 'M1_Aeon_AirAttack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M1_Air_Attack_Chain_1',
                    'M1_Air_Attack_Chain_2',
                    'M1_Air_Attack_Chain_3',
                },
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Bombers', quantity[Difficulty])

    quantity = {2, 2, 4}
    trigger = {100, 90, 80}
    opai = AeonM1AirBase:AddOpAI('AirAttacks', 'M1_Aeon_AirAttack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M1_Air_Attack_Chain_1',
                    'M1_Air_Attack_Chain_2',
                    'M1_Air_Attack_Chain_3',
                },
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL, '>='})

    ----------
    -- Defense
    ----------
    quantity = {3, 6, 9}
    opai = AeonM1AirBase:AddOpAI('AirAttacks', 'M1_Aeon_AirPatrol_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M1_Patrol_Air_Base',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Bombers', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    opai:SetFormation('NoFormation')

    quantity = {2, 4, 6}
    opai = AeonM1AirBase:AddOpAI('AirAttacks', 'M1_Aeon_AirPatrol_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M1_Patrol_Air_Base',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Interceptors', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    opai:SetFormation('NoFormation')

    quantity = {1, 2, 3}
    opai = AeonM1AirBase:AddOpAI('AirAttacks', 'M1_Aeon_AirPatrol_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M1_Patrol_Air_Base',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    opai:SetFormation('NoFormation')
end

-------------------
-- Aeon M1 Land Base
-------------------
function AeonM1LandBaseAI()
    AeonM1LandBase:InitializeDifficultyTables(ArmyBrains[Aeon], 'M1_Land_Base', 'M1_Land_Base_Marker', 40, {M1_Base_Land = 100})
    AeonM1LandBase:StartNonZeroBase({2, 1})
    AeonM1LandBase:SetActive('LandScouting', true)

    AeonM1LandBaseAttacks()
end

function AeonM1LandBaseAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    -- Transport builder
    opai = AeonM1LandBase:AddOpAI('EngineerAttack', 'M1_Aeon_TransportBuilder',
        {
            MasterPlatoonFunction = {SPAIFileName, 'LandAssaultWithTransports'},
            PlatoonData = {
                TransportReturn = 'Aeon_M1_Transport_Return',
            },
            Priority = 1000,
        }
    )
    opai:SetChildQuantity('T1Transports', 2)
    opai:SetLockingStyle('None')
    opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
        'HaveLessThanUnitsWithCategory', {'default_brain', 5, categories.uaa0107})

    -------------
    -- Amphibious
    -------------
    quantity = {4, 4, 6}
    opai = AeonM1LandBase:AddOpAI('BasicLandAttack', 'M1_Aeon_AmphibiousAttack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M1_Air_Attack_Chain_1',
                    'M1_Air_Attack_Chain_2',
                    'M1_Air_Attack_Chain_3',
                },
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('LightTanks', quantity[Difficulty])
    opai:SetFormation('AttackFormation')
    opai:SetLockingStyle('None')

    --------
    -- Drops
    --------
    trigger = {80, 70, 60}
    for i = 1, 2 do
        opai = AeonM1LandBase:AddOpAI('BasicLandAttack', 'M1_Aeon_TransportAttack_1_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'LandAssaultWithTransports'},
                PlatoonData = {
                    AttackChain = 'M1_Player_Base_Attack_Chain',
                    LandingChain = 'M1_Landing_Chain_' .. i,
                    TransportReturn = 'Aeon_M1_Transport_Return',
                },
                Priority = 110,
            }
        )
        opai:SetChildQuantity('LightTanks', 6)
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
            'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty] + i * 10, categories.ALLUNITS - categories.WALL, '>='})
    end

    opai = AeonM1LandBase:AddOpAI('BasicLandAttack', 'M1_Aeon_TransportAttack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain = 'M1_Player_Base_Attack_Chain',
                LandingChain = 'M1_Landing_Chain_1',
                TransportReturn = 'Aeon_M1_Transport_Return',
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('LightArtillery', 6)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, 8, categories.MASSEXTRACTION * categories.TECH2, '>='})
    --[[
    opai = UEFM2Base:AddOpAI('BasicLandAttack', 'M2_UEF_TransportAttack_1_' .. i,
        {
            MasterPlatoonFunction = {SPAIFileName, 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain = 'M2_UEF_Transport_Attack_Chain',
                LandingChain = 'M2_UEF_Landing_Chain',
                MovePath = 'M2_UEF_Transport_Move_Chain',
                TransportReturn = 'M2_UEF_Transport_Return',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('LightTanks', 6)
    opai:SetLockingStyle('DeathTimer', {LockTimer = 120})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty] + i * 10, categories.ALLUNITS - categories.WALL, '>='})
    --]]
end

-------------------
-- Aeon M1 Naval Base
-------------------
function AeonM1NavalBaseAI()
    AeonM1NavalBase:InitializeDifficultyTables(ArmyBrains[Aeon], 'M1_Naval_Base', 'M1_Naval_Base_Marker', 50, {M1_Base_Naval = 100})
    AeonM1NavalBase:StartNonZeroBase({2, 2})

    AeonM1NavalBaseAttacks()
end

function AeonM1NavalBaseAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    ---------
    -- Attack
    ---------
    quantity = {2, 3, 4}
    opai = AeonM1NavalBase:AddOpAI('NavalAttacks', 'M1_Aeon_Naval_Attack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M1_Naval_Attack_Chain_1',
                    'M1_Naval_Attack_Chain_2',
                    'M1_Naval_Attack_Chain_3',
                },
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Frigates', quantity[Difficulty])
    opai:SetFormation('AttackFormation')

    quantity = {4, 6, 8}
    trigger = {8, 6, 4}
    opai = AeonM1NavalBase:AddOpAI('NavalAttacks', 'M1_Aeon_Naval_Attack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M1_Naval_Attack_Chain_1',
                    'M1_Naval_Attack_Chain_2',
                    'M1_Naval_Attack_Chain_3',
                },
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'Frigates', 'Submarines'}, quantity[Difficulty])
    opai:SetFormation('AttackFormation')
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE, '>='})

    quantity = {{2, 2}, {2, 4}, {3, 3}}
    trigger = {5, 4, 2}
    opai = AeonM1NavalBase:AddOpAI('NavalAttacks', 'M1_Aeon_Naval_Attack_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M1_Naval_Attack_Chain_1',
                    'M1_Naval_Attack_Chain_2',
                    'M1_Naval_Attack_Chain_3',
                },
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'Destroyers', 'Frigates'}, quantity[Difficulty])
    opai:SetFormation('AttackFormation')
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE * categories.TECH2, '>='})

    quantity = {{2, 1, 2, 2}, {2, 1, 4, 4}, {3, 1, 4, 4}}
    trigger = {10, 8, 6}
    opai = AeonM1NavalBase:AddOpAI('NavalAttacks', 'M1_Aeon_Naval_Attack_4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M1_Naval_Attack_Chain_1',
                    'M1_Naval_Attack_Chain_2',
                    'M1_Naval_Attack_Chain_3',
                },
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity({'Destroyers', 'Cruisers', 'Frigates', 'Submarines'}, quantity[Difficulty])
    opai:SetFormation('AttackFormation')
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE * categories.TECH2, '>='})

    ----------
    -- Defense
    ----------
    -- 4 AA boats
    for i = 1, 1 + Difficulty do
        opai = AeonM1NavalBase:AddOpAI('NavalAttacks', 'M1_Aeon_NavalPatrol_1_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M1_Patrol_Naval_Base',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('AABoats', 4)
        opai:SetFormation('AttackFormation')
    end

    -- Mixed T1/T2 patrol
    opai = AeonM1NavalBase:AddOpAI('NavalAttacks', 'M1_Aeon_NavalPatrol_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M1_Patrol_Naval_Base',
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'Destroyers', 'Cruisers', 'Frigates', 'AABoats'}, {1, 1, 2, 1})
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
end

