local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'

---------
-- Locals
---------
local Aeon = 5
local Difficulty = ScenarioInfo.Options.Difficulty

----------------
-- Base Managers
----------------
local AeonM3Base = BaseManager.CreateBaseManager()
local AeonM3BaseNaval = BaseManager.CreateBaseManager()

-----------------
-- Aeon Main Base
-----------------
function AeonM3BaseAI()
	AeonM3Base:InitializeDifficultyTables(ArmyBrains[Aeon], 'M3_Aeon_Base', 'M3_Aeon_Base_Marker', 60, {M3_Aeon_Base = 100,
                                                                                                        M3_Aeon_Bluffs_1 = 90,
                                                                                                        M3_Aeon_Bluffs_2 = 80})
    AeonM3Base:StartNonZeroBase({{8, 10, 12}, {6, 8, 10}})
    AeonM3Base:SetActive('AirScouting', true)

    ForkThread(function()
        -- Spawn support factories bit later, since sometimes they can't build anything
        WaitSeconds(1)
        AeonM3Base:AddBuildGroup('M3_Aeon_Base_Support_Factories', 100, true)
    end)

    AeonM3BaseAirAttacks()
    AeonM3BaseLandAttacks()
end

function AeonM3BaseAirAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    quantity = {6, 8, 10}
    opai = AeonM3Base:AddOpAI('AirAttacks', 'M2_Aeon_AirAttack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Aeon_AirAttack_Chain_1',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    opai:SetLockingStyle('DeathTimer', {LockTimer = 60})


    -- Air Defense
    quantity = {3, 4, 5}
    for i = 1, 2 do
        opai = AeonM3Base:AddOpAI('AirAttacks', 'M3_Aeon_AirDefense' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M3_Aeon_Base_AirDefense_Chain',
                },
                Priority = 200,
            }
        )
        opai:SetChildQuantity('HeavyGunships', quantity[Difficulty])
        opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    end

    quantity = {4, 5, 6}
    for i = 3, 5 do
        opai = AeonM3Base:AddOpAI('AirAttacks', 'M3_Aeon_AirDefense' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M3_Aeon_Base_AirDefense_Chain',
                },
                Priority = 200,
            }
        )
        opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
        opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    end

    quantity = {2, 3, 4}
    for i = 6, 7 do
        opai = AeonM3Base:AddOpAI('AirAttacks', 'M3_Aeon_AirDefense' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M3_Aeon_Base_AirDefense_Chain',
                },
                Priority = 190,
            }
        )
        opai:SetChildQuantity('StratBombers', quantity[Difficulty])
        opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    end
end

function AeonM3BaseLandAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    for i = 1, 2 do
        quantity = {12, 14, 16}
        opai = AeonM3Base:AddOpAI('BasicLandAttack', 'M2_Aeon_LandAttack_1_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M3_Aeon_LandAttackOrder_Chain',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('HeavyTanks', quantity[Difficulty])
        opai:SetFormation('AttackFormation')
    end

    quantity = {6, 8, 10}
    opai = AeonM3Base:AddOpAI('BasicLandAttack', 'M2_Aeon_LandAttack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Aeon_LandAttackOrder_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('MobileMissiles', quantity[Difficulty])
    opai:SetFormation('AttackFormation')
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'Order'}, 10, categories.DEFENSE, '>='})

    quantity = {6, 8, 8}
    opai = AeonM3Base:AddOpAI('BasicLandAttack', 'M2_Aeon_LandAttack_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Aeon_LandAttackOrder_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('MobileFlak', quantity[Difficulty])
    opai:SetFormation('AttackFormation')
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'Order'}, 10, categories.AIR * categories.TECH2 * categories.MOBILE, '>='})

    for i = 1, 2 do
        quantity = {6, 9, 12}
        opai = AeonM3Base:AddOpAI('BasicLandAttack', 'M2_Aeon_LandAttack_4_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M3_Aeon_LandAttackOrder_Chain',
                },
                Priority = 110,
            }
        )
        opai:SetChildQuantity('SiegeBots', quantity[Difficulty])
        opai:SetFormation('AttackFormation')
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'Order'}, 30, categories.LAND, '>='})
    end
    --[[ -- Sniper Bots
    for i = 1, 2 do
        quantity = {3, 6, 9}
        opai = AeonM3Base:AddOpAI('BasicLandAttack', 'M2_Aeon_LandAttack_5_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M3_Aeon_LandAttackOrder_Chain',
                },
                Priority = 120,
            }
        )
        opai:SetChildQuantity('HeavyBots', quantity[Difficulty])
        opai:SetFormation('AttackFormation')
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
    end]]--
end

function M3AeonExperimentals()
    local opai = nil
    local quantity = {}

    -- Defensive GCs
    quantity = {1, 2, 3}
    opai = AeonM3Base:AddOpAI('M3_Aeon_Def_GC',
        {
            Amount = 2,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Aeon_GC_Def_Chain',
            },
            MaxAssist = quantity[Difficulty],
            Retry = true,
        }
    )

    quantity = {1, 2, 3}
    local waitTime = {300, 240, 180}
    opai = AeonM3Base:AddOpAI('M3_Aeon_Attack_GC_Order',
        {
            Amount = 1,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Exp_Combined_Order_Chain',
            },
            MaxAssist = quantity[Difficulty],
            Retry = true,
            WaitSecondsAfterDeath = waitTime[Difficulty],
        }
    )

    quantity = {1, 2, 3}
    opai = AeonM3Base:AddOpAI('M3_Aeon_Attack_GC',
        {
            Amount = 2,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Exp_Combined_Player_Chain_1', 'M3_Exp_Combined_Player_Chain_2'},
            },
            MaxAssist = quantity[Difficulty],
            Retry = true,
        }
    )
end

-----------------
-- Aeon Naval Base
-----------------
function AeonM3BaseNavalAI()
    AeonM3BaseNaval:InitializeDifficultyTables(ArmyBrains[Aeon], 'M3_Aeon_Base_Naval', 'M3_Aeon_Base_Naval_Marker', 60, {M3_Aeon_Base_Naval = 100})
    AeonM3BaseNaval:StartNonZeroBase({{4, 5, 7}, {3, 4, 5}})

    AeonM3BaseNavalAttacks()
end

function AeonM3BaseNavalAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    quantity = {20, 25, 30}
    opai = AeonM3BaseNaval:AddNavalAI('M3_Aeon_NavalAttack1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_UEF_Base_NavalAttack_Chain',
            },
            EnabledTypes = {'Destroyer', 'Cruiser', 'Submarine'},
            MaxFrigates = quantity[Difficulty],
            MinFrigates = quantity[Difficulty],
            Priority = 110,
            Overrides = {
                CORE_TO_CRUISERS = 2,
                CORE_TO_SUBS = 2,
            },
            DisableTypes = {['T2Submarine'] = true},
        }
    )
    opai:SetChildActive('T3', false)
    opai:SetFormation('AttackFormation')
    opai:SetLockingStyle('None')

    trigger = {8, 7, 6}
    quantity = {55, 65, 75}
    opai = AeonM3BaseNaval:AddNavalAI('M3_Aeon_Base_BattleshipAttack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_UEF_Base_NavalAttack_Chain',
            },
            EnabledTypes = {'Battleship', 'Destroyer', 'Cruiser'},
            MaxFrigates = quantity[Difficulty],
            MinFrigates = quantity[Difficulty],
            Priority = 140,
            Overrides = {
                CORE_TO_CRUISERS = 1,
            },
        }
    )
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.BATTLESHIP, '>='})
end

--------
-- Other
--------
function M4AeonExperimentals()
    local opai = nil
    local quantity = {}

    quantity = {1, 1, 3}
    opai = AeonM3BaseNaval:AddOpAI('M4_Aeon_Tempest',
        {
            Amount = 1,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_UEF_Base_NavalAttack_Chain',
            },
            MaxAssist = quantity[Difficulty],
            Retry = true,
        }
    )
end

function DisableBase()
    if(AeonM3Base) then
        LOG('AeonM3Base stopped')
        AeonM3Base:BaseActive(false)
    end
    if AeonM3BaseNaval then
        LOG('AeonM3BaseNaval stopped')
        AeonM3BaseNaval:BaseActive(false)
    end
    for _, platoon in ArmyBrains[Aeon]:GetPlatoonsList() do
        platoon:Stop()
        ArmyBrains[Aeon]:DisbandPlatoon(platoon)
    end
    LOG('All Platoons of AeonM3Base stopped')
end