local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'

---------
-- Locals
---------
local Cybran = 6
local Difficulty = ScenarioInfo.Options.Difficulty

----------------
-- Base Managers
----------------
local CybranM3Base = BaseManager.CreateBaseManager()

-------------------
-- Cybran Main Base
-------------------
function CybranM3BaseAI()
    CybranM3Base:InitializeDifficultyTables(ArmyBrains[Cybran], 'M3_Cybran_Base', 'M3_Cybran_Base_Marker', 70, {M3_Cybran_Base = 100,
    																											M3_Cybran_Bluffs_1 = 80,
    																											M3_Cybran_Bluffs_2 = 70})
    CybranM3Base:StartNonZeroBase({{8, 10, 12}, {6, 8, 10}})
    CybranM3Base:SetActive('AirScouting', true)
    CybranM3Base:SetSupportACUCount(Difficulty)
    CybranM3Base:SetSACUUpgrades({'ResourceAllocation', 'Switchback', 'SelfRepairSystem'})

    ForkThread(function()
        -- Spawn support factories bit later, since sometimes they can't build anything
        WaitSeconds(1)
        CybranM3Base:AddBuildGroup('M3_Cybran_Base_Support_Factories', 100, true)
    end)
    

    -- East Defenses, only for Easy Difficulty
    if Difficulty == 1 then
    	CybranM3Base:AddBuildGroup('M3_East_Defenses_D1', 90, true)
    end

    CybranM3BaseAirAttacks()
    CybranM3BaseLandAttacks()
end

function CybranM3BaseAirAttacks()
	--[[
	{'M3_Cybran_AirAttackOrder_Chain_1', 
	'M3_Cybran_AirAttackOrder_Chain_2',
	'M3_Cybran_AirAttackOrder_Chain_3'}, -- for naval
	]]--
	local opai = nil
    local quantity = {}
    local trigger = {}

    quantity = {8, 10, 12}
    for i = 1, 2 do
        opai = CybranM3Base:AddOpAI('AirAttacks', 'M2_Cybran_AirAttack_1_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
                PlatoonData = {
                    PatrolChains = {'M3_Cybran_AirAttackOrder_Chain_1', 'M3_Cybran_AirAttackOrder_Chain_2'},
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('Gunships', quantity[Difficulty])
    end

    quantity = {3, 4, 6}
    opai = CybranM3Base:AddOpAI('AirAttacks', 'M2_Cybran_AirAttack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Cybran_AirAttackOrder_Chain_1', 'M3_Cybran_AirAttackOrder_Chain_2'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('HeavyGunships', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'Order'}, 100, categories.ALLUNITS, '>='})

    quantity = {3, 4, 6}
    trigger = {14, 12, 10}
    opai = CybranM3Base:AddOpAI('AirAttacks', 'M2_Cybran_AirAttack_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Cybran_AirAttackOrder_Chain_1', 'M3_Cybran_AirAttackOrder_Chain_2'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'Order'}, trigger[Difficulty], categories.AIR * categories.TECH3, '>='})

    if Difficulty >= 2 then
        opai = CybranM3Base:AddOpAI('AirAttacks', 'M2_Cybran_AirAttack_4',
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
                PlatoonData = {
                    PatrolChains = {'M3_Cybran_AirAttackOrder_Chain_1', 'M3_Cybran_AirAttackOrder_Chain_2'},
                },
                Priority = 120,
            }
        )
        opai:SetChildQuantity('StratBombers', 3)
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'Order'}, 100, categories.ALLUNITS, '>='})
    end

    -- Air Defense
    for i = 1, 2 do
        opai = CybranM3Base:AddOpAI('AirAttacks', 'M3_Cybran_AirDefense' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M3_Cybran_Base_AirDefense_Chain',
                },
                Priority = 200,
            }
        )
        opai:SetChildQuantity('HeavyGunships', 5)
        opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    end

    for i = 3, 5 do
        opai = CybranM3Base:AddOpAI('AirAttacks', 'M3_Cybran_AirDefense' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M3_Cybran_Base_AirDefense_Chain',
                },
                Priority = 210,
            }
        )
        opai:SetChildQuantity('AirSuperiority', 6)
        opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    end
end

function CybranM3BaseLandAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    for i = 1, 2 do
        quantity = {12, 14, 16}
        opai = CybranM3Base:AddOpAI('BasicLandAttack', 'M2_Cybran_LandAttack_1_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M3_Cybran_LandAttackOrder_Chain',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('HeavyTanks', quantity[Difficulty])
        opai:SetFormation('AttackFormation')
    end

    quantity = {6, 8, 10}
    opai = CybranM3Base:AddOpAI('BasicLandAttack', 'M2_Cybran_LandAttack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Cybran_LandAttackOrder_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('MobileMissiles', quantity[Difficulty])
    opai:SetFormation('AttackFormation')
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'Order'}, 10, categories.DEFENSE, '>='})

    quantity = {6, 8, 8}
    opai = CybranM3Base:AddOpAI('BasicLandAttack', 'M2_Cybran_LandAttack_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Cybran_LandAttackOrder_Chain',
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
        opai = CybranM3Base:AddOpAI('BasicLandAttack', 'M2_Cybran_LandAttack_4_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M3_Cybran_LandAttackOrder_Chain',
                },
                Priority = 110,
            }
        )
        opai:SetChildQuantity('SiegeBots', quantity[Difficulty])
        opai:SetFormation('AttackFormation')
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'Order'}, 30, categories.LAND, '>='})
    end

    for i = 1, 2 do
        quantity = {3, 6, 9}
        opai = CybranM3Base:AddOpAI('BasicLandAttack', 'M2_Cybran_LandAttack_5_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M3_Cybran_LandAttackOrder_Chain',
                },
                Priority = 120,
            }
        )
        opai:SetChildQuantity('HeavyBots', quantity[Difficulty])
        opai:SetFormation('AttackFormation')
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', {'Order'}, 40, categories.LAND, '>='})
    end

    -- Defense
    quantity = {2, 3, 4}
    opai = CybranM3Base:AddOpAI('BasicLandAttack', 'M2_Cybran_LandDef_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Cybran_Base_EngineerChain',
            },
            Priority = 200,
        }
    )
    opai:SetChildQuantity('MobileHeavyArtillery', quantity[Difficulty])

    quantity = {2, 2, 3}
    opai = CybranM3Base:AddOpAI('BasicLandAttack', 'M2_Cybran_LandDef_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Cybran_LandDef_Chain_2',
            },
            Priority = 200,
        }
    )
    opai:SetChildQuantity('HeavyMobileAntiAir', quantity[Difficulty])

    quantity = {8, 10, 12}
    opai = CybranM3Base:AddOpAI('BasicLandAttack', 'M2_Cybran_LandDef_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Cybran_LandDef_Chain_1',
            },
            Priority = 210,
        }
    )
    opai:SetChildQuantity('HeavyBots', quantity[Difficulty])
end

function M3CybranExperimentals()
    local opai = nil
    local quantity = {}

    -- Spider Defeense
    quantity = {1, 2, 4}
    opai = CybranM3Base:AddOpAI('M3_Cybran_Spider_1',
        {
            Amount = 2,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Cybran_Spider_Def_Chain',
            },
            MaxAssist = quantity[Difficulty],
            Retry = true,
        }
    )

    quantity = {1, 2, 4}
    local waitTime = {300, 240, 180}
    opai = CybranM3Base:AddOpAI('M3_Cybran_Attack_Spider_Order',
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

    -- Spider Attack
    quantity = {1, 2, 4}
    opai = CybranM3Base:AddOpAI('M3_Cybran_Spider_2',
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

function DisableBase()
    if(CybranM3Base) then
        LOG('CybranM3Base stopped')
        CybranM3Base:BaseActive(false)
    end
    for _, platoon in ArmyBrains[Cybran]:GetPlatoonsList() do
        platoon:Stop()
        ArmyBrains[Cybran]:DisbandPlatoon(platoon)
    end
    LOG('All Platoons of CybranM3Base stopped')
end