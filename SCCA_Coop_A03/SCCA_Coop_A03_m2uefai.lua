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
local UEFM2AirBase = BaseManager.CreateBaseManager()
local UEFM2LandBase = BaseManager.CreateBaseManager()
local UEFM2NavalBase = BaseManager.CreateBaseManager()

------------------
-- UEF M2 Air Base
------------------
function UEFM2AirBaseAI()
    UEFM2AirBase:InitializeDifficultyTables(ArmyBrains[UEF], 'M2_Air_Base', 'M2_Air_Base_Marker', 60, {M2_Air_Base = 100})
    UEFM2AirBase:StartNonZeroBase({{4, 6, 8}, {4, 5, 6}})
    UEFM2AirBase:SetActive('AirScouting', true)

    ForkThread(function()
        WaitSeconds(1)
        UEFM2AirBase:AddBuildGroupDifficulty('M2_Air_Base_Support_Factories', 100, true)
    end)

    UEFM2AirBaseAttacks()
end

function UEFM2AirBaseAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    quantity = {4, 6, 8}
    opai = UEFM2AirBase:AddOpAI('AirAttacks', 'M2_AirAttack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackLocationList'},
            PlatoonData = {
                LocationChain = 'ErisAll_Chain',
                High = true,
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Bombers', quantity[Difficulty])
    opai:SetLockingStyle('None')

    quantity = {6, 9, 12}
    opai = UEFM2AirBase:AddOpAI('AirAttacks', 'M2_AirAttack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackLocationList'},
            PlatoonData = {
                LocationChain = 'ErisAll_Chain',
                High = true,
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])

    quantity = {6, 9, 12}
    opai = UEFM2AirBase:AddOpAI('AirAttacks', 'M2_AirAttack_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackLocationList'},
            PlatoonData = {
                LocationChain = 'ErisAll_Chain',
                High = true,
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Interceptors', quantity[Difficulty])

    -- Air Defence
    for i = 1, 1 + Difficulty do
        opai = UEFM2AirBase:AddOpAI('AirAttacks', 'M2_AirDefense_1_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'AirBaseAir_Chain',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('Interceptors', 4)
        opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    end

    for i = 1, 1 + Difficulty do
        opai = UEFM2AirBase:AddOpAI('AirAttacks', 'M2_AirDefense_2_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'AirBaseAir_Chain',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('TorpedoBombers', 4)
        opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    end

    for i = 1, 1 + Difficulty do
        opai = UEFM2AirBase:AddOpAI('AirAttacks', 'M2_AirDefense_3_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'AirBaseAir_Chain',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('Gunships', 4)
        opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    end
end

-------------------
-- UEF M2 Land Base
-------------------
function UEFM2LandBaseAI()
    UEFM2LandBase:InitializeDifficultyTables(ArmyBrains[UEF], 'M2_Land_Base', 'M2_Land_Base_Marker', 60, {M2_Land_Base = 100})
    UEFM2LandBase:StartNonZeroBase({{4, 6, 8}, {4, 5, 6}})

    ForkThread(function()
        WaitSeconds(1)
        UEFM2LandBase:AddBuildGroupDifficulty('M2_Land_Base_Support_Factories', 100, true)
    end)

    UEFM2LandBaseAttacks()
end

function UEFM2LandBaseAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    -- Transport Builder
    opai = UEFM2LandBase:AddOpAI('EngineerAttack', 'M2_TransportBuilder',
        {
            MasterPlatoonFunction = {SPAIFileName, 'LandAssaultWithTransports'},
            PlatoonData = {
                TransportReturn = 'M2_Land_Base_Marker',
            },
            Priority = 1000,
        }
    )
    opai:SetChildQuantity('T2Transports', 4)
    opai:SetLockingStyle('None')
    opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
        'HaveLessThanUnitsWithCategory', {'default_brain', 8, categories.uea0104})

    quantity = {12, 18, 24}
    opai = UEFM2LandBase:AddOpAI('BasicLandAttack', 'M2_TransportAttack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain = 'ErisLand_Chain',
                LandingChain = 'ErisLand_Chain',
                TransportReturn = 'M2_Land_Base_Marker',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('HeavyTanks', quantity[Difficulty])

    quantity = {14, 28, 42}
    opai = UEFM2LandBase:AddOpAI('BasicLandAttack', 'M2_TransportAttack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain = 'ErisLand_Chain',
                LandingChain = 'ErisLand_Chain',
                TransportReturn = 'M2_Land_Base_Marker',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('LightArtillery', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
        'HaveGreaterThanUnitsWithCategory', {'default_brain', 3, categories.uea0104})
end

--------------------
-- UEF M2 Naval Base
--------------------
function UEFM2NavalBaseAI()
    UEFM2NavalBase:InitializeDifficultyTables(ArmyBrains[UEF], 'M2_Naval_Base', 'M2_Naval_Base_Marker', 90, {M2_Naval_Base = 100})
    UEFM2NavalBase:StartNonZeroBase({{4, 6, 8}, {4, 5, 6}})

    ForkThread(function()
        WaitSeconds(1)
        UEFM2NavalBase:AddBuildGroupDifficulty('M2_Naval_Base_Support_Factories', 100, true)
    end)

    UEFM2NavalBaseAttacks()
end

function UEFM2NavalBaseAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    quantity = {4, 6, 8}
    opai = UEFM2NavalBase:AddNavalAI('M2_Naval_Attack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'ErisNavy_Chain4',
            },
            MaxFrigates = quantity[Difficulty],
            MinFrigates = quantity[Difficulty],
            Priority = 100,
        }
    )
    opai:SetChildActive('T2', false)
    opai:SetChildActive('T3', false)

    -- Sends 2, 3, 4 Frigates if players havee more than 30 Auroras
    quantity = {2, 3, 4}
    opai = UEFM2NavalBase:AddNavalAI('M2_Naval_Attack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'ErisNavy_Chain4',
            },
            MaxFrigates = quantity[Difficulty],
            MinFrigates = quantity[Difficulty],
            EnabledTypes = {'Frigate'},
            Priority = 110,
        }
    )
    opai:SetChildActive('T2', false)
    opai:SetChildActive('T3', false)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, 30, categories.ual0201, '>='})

    quantity = {4, 6, 8}
    trigger = {16, 14, 12}
    opai = UEFM2NavalBase:AddNavalAI('M2_Naval_Attack_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'ErisNavy_Chain4',
            },
            MaxFrigates = quantity[Difficulty],
            MinFrigates = quantity[Difficulty],
            Priority = 110,
        }
    )
    opai:SetChildActive('T2', false)
    opai:SetChildActive('T3', false)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE - categories.TECH2, '>='})

    quantity = {7, 9, 14}
    trigger = {4, 3, 2}
    opai = UEFM2NavalBase:AddNavalAI('M2_Naval_Attack_4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'ErisNavy_Chain4',
            },
            MaxFrigates = quantity[Difficulty],
            MinFrigates = quantity[Difficulty],
            EnabledTypes = {'Frigate', 'Destroyer', 'Submarine'},
            DisableTypes = {['T2Submarine'] = true},
            Priority = 120,
        }
    )
    opai:SetChildActive('T3', false)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE * categories.TECH2, '>='})

    -- Sends 2, 3, 4 Destroyers if players have more than 8, 6, 4 T2 navy
    quantity = {10, 15, 20}
    trigger = {8, 6, 4}
    opai = UEFM2NavalBase:AddNavalAI('M2_Naval_Attack_5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'ErisNavy_Chain4',
            },
            MaxFrigates = quantity[Difficulty],
            MinFrigates = quantity[Difficulty],
            EnabledTypes = {'Destroyer'},
            Priority = 130,
        }
    )
    opai:SetChildActive('T1', false)
    opai:SetChildActive('T3', false)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE * categories.TECH2, '>='})

    -- Sends 2, 3, 4 Destroyers if players have more than 50 Auroras
    -- quantity = {10, 15, 20}
    -- opai = UEFM2NavalBase:AddNavalAI('M2_Naval_Attack_6',
    --     {
    --         MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
    --         PlatoonData = {
    --             PatrolChain = 'ErisNavy_Chain4',
    --         },
    --         MaxFrigates = quantity[Difficulty],
    --         MinFrigates = quantity[Difficulty],
    --         EnabledTypes = {'Frigate', 'Destroyer'},
    --         Priority = 130,
    --     }
    -- )
    -- opai:SetChildActive('T3', false)
    -- opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
    --     {'default_brain', {'HumanPlayers'}, 60, categories.ual0201, '>='})

    quantity = {12, 18, 24}
    trigger = {8, 7, 6}
    opai = UEFM2NavalBase:AddNavalAI('M2_Naval_Attack_7',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'ErisNavy_Chain4',
            },
            MaxFrigates = quantity[Difficulty],
            MinFrigates = quantity[Difficulty],
            EnabledTypes = {'Frigate', 'Destroyer'},
            Priority = 140,
        }
    )
    opai:SetChildActive('T3', false)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE * categories.TECH2, '>='})
end