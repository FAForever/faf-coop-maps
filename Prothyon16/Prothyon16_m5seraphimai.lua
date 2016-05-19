local BaseManager = import('/lua/ai/opai/basemanager.lua')
local CustomFunctions = '/maps/Prothyon16/Prothyon16_CustomFunctions.lua'
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'

ScenarioInfo.Player = 1

---------
-- Locals
---------
local Seraphim = 5
local Player = ScenarioInfo.Player
local Difficulty = ScenarioInfo.Options.Difficulty

----------------
-- Base Managers
----------------
local SeraphimM5MainBase = BaseManager.CreateBaseManager()
local SeraphimM5IslandMiddleBase = BaseManager.CreateBaseManager()
local SeraphimM5IslandMiddleT1NavalBase = BaseManager.CreateBaseManager()
local SeraphimM5IslandMiddleT2NavalBase = BaseManager.CreateBaseManager()
local SeraphimM5IslandWestBase = BaseManager.CreateBaseManager()
local SeraphimM5IslandWestT2NavalBase = BaseManager.CreateBaseManager()

------------------------
-- Seraphim M5 Main Base
------------------------
function SeraphimM5MainBaseAI()
    SeraphimM5MainBase:Initialize(ArmyBrains[Seraphim], 'M5_Sera_Main_Base', 'M5_Sera_Main_Base_Marker', 90, {M5_Sera_Main_Base = 100})
    SeraphimM5MainBase:StartNonZeroBase({30, 27})
    SeraphimM5MainBase:SetActive('AirScouting', true)
    
    SeraphimM5MainBaseAirAttacks()
    SeraphimM5MainBaseLandAttacks()
    SeraphimM5MainBaseNavalAttacks()
end

function SeraphimM5MainBaseAirAttacks()
	local opai = nil
    local quantity = {}
    local trigger = {}

    -- Transport Builder
    opai = SeraphimM5MainBase:AddOpAI('EngineerAttack', 'M5_Sera_MainTransportBuilder',
    {
        MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
        PlatoonData = {
            TransportReturn = 'M5_Sera_Main_Base_Marker',
        },
        Priority = 1000,
    })
    opai:SetChildQuantity('T2Transports', 4)
    opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
        'HaveLessThanUnitsWithCategory', {'default_brain', 8, categories.xsa0104})   -- T2 Transport

	-- Builds platoon of 10 Bombers 6 times
    quantity = {6, 8, 10}
	for i = 1, 3 + Difficulty do
	    opai = SeraphimM5MainBase:AddOpAI('AirAttacks', 'M5_Sera_Main_AirAttackPlayer1_' .. i,
	        {
	            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
	            PlatoonData = {
	                PatrolChains = {'M5_Sera_Main_AirAttackPlayer_Chain1',
                                    'M5_Sera_Main_AirAttackPlayer_Chain2',
                                    'M5_Sera_Main_AirAttackPlayer_Chain3',
                                    'M5_Sera_Main_AirAttackPlayer_Chain4',
                                    'M5_Sera_Main_Naval_AttackPlayer_Chain1',
                                    'M5_Sera_Main_Naval_AttackPlayer_Chain2',
                                    'M5_Sera_Main_Naval_AttackPlayer_Chain3'},
	            },
	            Priority = 100,
	        }
	    )
	    opai:SetChildQuantity('Bombers', quantity[Difficulty])
	end

	-- Builds platoon of 10 Gunships 6 times
    quantity = {6, 8, 10}
	for i = 1, 3 + Difficulty do
	    opai = SeraphimM5MainBase:AddOpAI('AirAttacks', 'M5_Sera_Main_AirAttackPlayer2_' .. i,
	        {
	            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
	            PlatoonData = {
                    PatrolChains = {'M5_Sera_Main_AirAttackPlayer_Chain1',
                                    'M5_Sera_Main_AirAttackPlayer_Chain2',
                                    'M5_Sera_Main_AirAttackPlayer_Chain3',
                                    'M5_Sera_Main_AirAttackPlayer_Chain4',
                                    'M5_Sera_Main_Naval_AttackPlayer_Chain1',
                                    'M5_Sera_Main_Naval_AttackPlayer_Chain2',
                                    'M5_Sera_Main_Naval_AttackPlayer_Chain3'},
                },
	            Priority = 110,
	        }
	    )
	    opai:SetChildQuantity('Gunships', quantity[Difficulty])
	end

	-- Builds platoon of 20 Interceptors 4 times if Player has more than 50 mobile air
    quantity = {10, 15, 20}
    trigger = {70, 60, 50}
	for i = 1, 4 do
	    opai = SeraphimM5MainBase:AddOpAI('AirAttacks', 'M5_Sera_Main_AirAttackPlayer3_' .. i,
	        {
	            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
	            PlatoonData = {
                    PatrolChains = {'M5_Sera_Main_AirAttackPlayer_Chain1',
                                    'M5_Sera_Main_AirAttackPlayer_Chain2',
                                    'M5_Sera_Main_AirAttackPlayer_Chain3',
                                    'M5_Sera_Main_AirAttackPlayer_Chain4',
                                    'M5_Sera_Main_Naval_AttackPlayer_Chain1',
                                    'M5_Sera_Main_Naval_AttackPlayer_Chain2',
                                    'M5_Sera_Main_Naval_AttackPlayer_Chain3'},
                },
	            Priority = 100,
	        }
	    )
	    opai:SetChildQuantity('Interceptors', quantity[Difficulty])
	    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
            {'default_brain', 'Player', trigger[Difficulty], categories.AIR * categories.MOBILE})
	end

    -- Builds platoon of 10 Interceptors 4 times if Player has more than 70 mobile air
    quantity = {6, 8, 10}
    trigger = {90, 80, 70} 
    for i = 1, 4 do
        opai = SeraphimM5MainBase:AddOpAI('AirAttacks', 'M5_Sera_Main_AirAttackPlayer4_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
                PlatoonData = {
                    PatrolChains = {'M5_Sera_Main_AirAttackPlayer_Chain1',
                                    'M5_Sera_Main_AirAttackPlayer_Chain2',
                                    'M5_Sera_Main_AirAttackPlayer_Chain3',
                                    'M5_Sera_Main_AirAttackPlayer_Chain4',
                                    'M5_Sera_Main_Naval_AttackPlayer_Chain1',
                                    'M5_Sera_Main_Naval_AttackPlayer_Chain2',
                                    'M5_Sera_Main_Naval_AttackPlayer_Chain3'},
                },
                Priority = 110,
            }
        )
        opai:SetChildQuantity('CombatFighters', quantity[Difficulty])
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
            {'default_brain', 'Player', trigger[Difficulty], categories.AIR * categories.MOBILE})
    end

    -- Builds platoon of 10 TorpedoBombers 4 times if Player has more than 10 T2 Naval Units
	for i = 1, 4 do
        quantity = {6, 8, 10}
        trigger = {20, 15, 10}
	    opai = SeraphimM5MainBase:AddOpAI('AirAttacks', 'M5_Sera_Main_AirAttackPlayer5_' .. i,
	        {
	            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
	            PlatoonData = {
	                PatrolChains = {'M5_Sera_Main_Naval_AttackPlayer_Chain1',
                                    'M5_Sera_Main_Naval_AttackPlayer_Chain2',
                                    'M5_Sera_Main_Naval_AttackPlayer_Chain3'},
	            },
	            Priority = 120,
	        }
	    )
	    opai:SetChildQuantity('TorpedoBombers', quantity[Difficulty])
	    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
            {'default_brain', 'Player', trigger[Difficulty], categories.NAVAL * categories.TECH2})
	end

    -- sends 10 [torpedo bombers] at Player CDR
    quantity = {10, 13, 16}
    opai = SeraphimM5MainBase:AddOpAI('AirAttacks', 'M5_Sera_Main_AirAttackPlayer6',
        {
            MasterPlatoonFunction = {'/maps/Prothyon16/Prothyon16_m5seraphimai.lua', 'M5AttackCDRWaterAI'},
            Priority = 120,
        }
    )
    opai:SetChildQuantity('TorpedoBombers', quantity[Difficulty])
    opai:AddBuildCondition('/maps/Prothyon16/Prothyon16_m5seraphimai.lua', 'CDROnWater', {})

	-----------------
	-- Attacks on UEF
	-----------------
	-- Builds platoon of 10 Bombers 2 times
	for i = 1, 2 do
	    opai = SeraphimM5MainBase:AddOpAI('AirAttacks', 'M5_Sera_Main_AirAttackUEF1_' .. i,
	        {
	            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
	            PlatoonData = {
	                PatrolChains = {'M5_Sera_Main_Air_AttackUEF_Chain1',
                                    'M5_Sera_Main_Air_AttackUEF_Chain2',
                                    'M5_Sera_Main_Hover_AttackUEF_Chain'},
	            },
	            Priority = 110,
	        }
	    )
	    opai:SetChildQuantity('Bombers', 10)
	end

	-- Builds platoon of 10 Gunships 2 times
	for i = 1, 2 do
	    opai = SeraphimM5MainBase:AddOpAI('AirAttacks', 'M5_Sera_Main_AirAttackUEF2_' .. i,
	        {
	            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
	            PlatoonData = {
                    PatrolChains = {'M5_Sera_Main_Air_AttackUEF_Chain1',
                                    'M5_Sera_Main_Air_AttackUEF_Chain2',
                                    'M5_Sera_Main_Hover_AttackUEF_Chain'},
                },
	            Priority = 120,
	        }
	    )
	    opai:SetChildQuantity('Gunships', 10)
	end

	-- Builds platoon of 20 Interceptors 2 times 
	for i = 1, 2 do
	    opai = SeraphimM5MainBase:AddOpAI('AirAttacks', 'M5_Sera_Main_AirAttackUEF3_' .. i,
	        {
	            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
	            PlatoonData = {
                    PatrolChains = {'M5_Sera_Main_Air_AttackUEF_Chain1',
                                    'M5_Sera_Main_Air_AttackUEF_Chain2',
                                    'M5_Sera_Main_Hover_AttackUEF_Chain'},
                },
	            Priority = 110,
	        }
	    )
	    opai:SetChildQuantity('Interceptors', 20)
	end

    opai = SeraphimM5MainBase:AddOpAI('AirAttacks', 'M5_Sera_Main_AirAttackUEF4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M5_Sera_Main_Air_AttackUEF_Chain1',
                                'M5_Sera_Main_Air_AttackUEF_Chain2',
                                'M5_Sera_Main_Hover_AttackUEF_Chain'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('CombatFighters', 10)
    
    -- Builds platoon of 10 TorpedoBombers
	opai = SeraphimM5MainBase:AddOpAI('AirAttacks', 'M5_Sera_Main_AirAttackUEF5',
	   {
	       MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
	       PlatoonData = {
	           PatrolChains = {'M5_Sera_Main_Air_AttackUEF_Chain1',
                                'M5_Sera_Main_Air_AttackUEF_Chain2',
                                'M5_Sera_Main_Hover_AttackUEF_Chain'},
	       },
	       Priority = 120,
	   }
	)
	opai:SetChildQuantity('TorpedoBombers', 10)

	-- Air Defense
    -- Maintains 20 CombatFighters
    quantity = {6, 8, 10}
    for i = 1, 2 do
        opai = SeraphimM5MainBase:AddOpAI('AirAttacks', 'M5_MainAirDefense1_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M5_Sera_Main_Base_Air_Def_Chain',
                },
                Priority = 110,
            }
        )
        opai:SetChildQuantity('CombatFighters', quantity[Difficulty])
        opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    end

    -- Maintains 10 Gunships
    opai = SeraphimM5MainBase:AddOpAI('AirAttacks', 'M5_MainAirDefense21',
        {
            MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
            PlatoonData = {
                PatrolChain = 'M5_Sera_Main_Base_Air_Def_Chain',
            },
            Priority = 200,
        }
    )
    opai:SetChildQuantity('Gunships', 10)
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})

    -- Maintains 12 Tropedo Bombers
    quantity = {6, 8, 10}
    for i = 1, 2 do
        opai = SeraphimM5MainBase:AddOpAI('AirAttacks', 'M5_MainAirDefense3_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M5_Sera_Main_Base_Air_Def_Chain',
                },
                Priority = 200,
            }
        )
        opai:SetChildQuantity('TorpedoBombers', quantity[Difficulty])
        opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    end
end

function SeraphimM5MainBaseLandAttacks()
	local opai = nil
    local quantity = {}
    local quantity2 = {}

    quantity = {8, 10, 14}
    for i = 1, 4 do
        opai = SeraphimM5MainBase:AddOpAI('BasicLandAttack', 'M5_Sera_HoverAttack1_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
                PlatoonData = {
                    PatrolChains = {'M5_Sera_Main_Naval_AttackPlayer_Chain1',
                                    'M5_Sera_Main_Naval_AttackPlayer_Chain2',
                                    'M5_Sera_Main_Naval_AttackPlayer_Chain3'},
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity({'AmphibiousTanks', 'MobileFlak'}, quantity[Difficulty])
        opai:SetFormation('AttackFormation')
    end
    --[[
	Temp = {
        'M5Serasacu',
        'NoPlan',
        { 'xsl0301', 1, 1, 'Attack', 'None' },   -- SACU
    }
    Builder = {
        BuilderName = 'M5Serasacubiulder',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 300,
        PlatoonType = 'Gate',
        RequiresConstruction = true,
        LocationType = 'M5_Sera_Main_Base',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},       
        PlatoonData = {
            PatrolChains = {'M5_Sera_Main_Air_AttackUEF_Chain1',
                            'M5_Sera_Main_Hover_AttackUEF_Chain',
                            'M5_Sera_Main_Naval_AttackUEF_Chain1',
                            'M5_Sera_Main_Naval_AttackUEF_Chain2'},
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )
    ]]--

    opai = SeraphimM5MainBase:AddOpAI('EngineerAttack', 'M5_Sera_Main_Reclaim_Engineers_1',
    {
        MasterPlatoonFunction = {SPAIFileName, 'SplitPatrolThread'},
        PlatoonData = {
            PatrolChains = {'M5_Sera_Main_Air_AttackUEF_Chain1',
                            'M5_Sera_Main_Hover_AttackUEF_Chain',
                            'M5_Sera_Main_Naval_AttackUEF_Chain1',
                            'M5_Sera_Main_Naval_AttackUEF_Chain2'},
        },
        Priority = 110,
    })
    opai:SetChildQuantity('T2Engineers', 8)
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})

    for i = 1, 2 do
        opai = SeraphimM5MainBase:AddOpAI('EngineerAttack', 'M5_Sera_Main_Reclaim_Engineers_2_' .. i,
        {
            MasterPlatoonFunction = {SPAIFileName, 'SplitPatrolThread'},
            PlatoonData = {
                PatrolChains = {'M5_Sera_Main_Naval_AttackPlayer_Chain1',
                                'M5_Sera_Main_Naval_AttackPlayer_Chain2',
                                'M5_Sera_Main_Naval_AttackPlayer_Chain3',
                                'M5_Sera_Main_AirAttackPlayer_Chain1',
                                'M5_Sera_Main_AirAttackPlayer_Chain2',
                                'M5_Sera_Main_AirAttackPlayer_Chain3',
                                'M5_Sera_Main_AirAttackPlayer_Chain4'},
            },
            Priority = 110,
        })
        opai:SetChildQuantity('T2Engineers', 8)
        opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    end

    -- sends 12 [hover tanks] 6 times
    for i = 1, 3 + Difficulty do
        quantity = {8, 10, 12}
        opai = SeraphimM5MainBase:AddOpAI('BasicLandAttack', 'M5_Sera_HoverAttack2_' ..i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
                PlatoonData = {
                    PatrolChains = {'M5_Sera_Main_Naval_AttackPlayer_Chain1',
                                    'M5_Sera_Main_Naval_AttackPlayer_Chain2',
                                    'M5_Sera_Main_Naval_AttackPlayer_Chain3'},
                },
                Priority = 110,
            }
        )
        opai:SetChildQuantity('AmphibiousTanks', quantity[Difficulty])
    end

    -- sends 4 [hover flak] 3 times
    for i = 1, 3 do
        quantity = {8, 10, 12}
        opai = SeraphimM5MainBase:AddOpAI('BasicLandAttack', 'M5_Sera_HoverAttack3_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
                PlatoonData = {
                    PatrolChains = {'M5_Sera_Main_Naval_AttackPlayer_Chain1',
                                    'M5_Sera_Main_Naval_AttackPlayer_Chain2',
                                    'M5_Sera_Main_Naval_AttackPlayer_Chain3'},
                },
                Priority = 110,
            }
        )
        opai:SetChildQuantity('MobileFlak', quantity[Difficulty])
    end

    -- sends 10 [hover tanks] 4 times
    for i = 1, 3 do
        opai = SeraphimM5MainBase:AddOpAI('BasicLandAttack', 'M5_Sera_HoverUEFAttack1_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
                PlatoonData = {
                    PatrolChains = {'M5_Sera_Main_Hover_AttackUEF_Chain',
                                    'M5_Sera_Main_Naval_AttackUEF_Chain1',
                                    'M5_Sera_Main_Naval_AttackUEF_Chain2'},
                },
                Priority = 110,
            }
        )
        opai:SetChildQuantity('AmphibiousTanks', 10)
    end
end

function SeraphimM5MainBaseNavalAttacks()
    local opai = nil
    local quantity = {}

    --[[
    quantity = {2, 3, 4}
    Temp = {
        'SeraM5NavalAttackPlayerTemp3',
        'NoPlan',
        { 'xss0201', 1, quantity[Difficulty], 'Attack', 'AttackFormation' },   -- Destroyers
    }
    Builder = {
        BuilderName = 'SeraM5NavyAttackPlayerBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 200,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'M5_Sera_Main_Base',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},
        PlatoonData = {
            PatrolChains = {'M5_Sera_Main_Naval_AttackPlayer_Chain1',
                            'M5_Sera_Main_Naval_AttackPlayer_Chain2',
                            'M5_Sera_Main_Naval_AttackPlayer_Chain3'},
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )
    ]]--
    -------------
    -- Attack UEF
	-------------
    -- Sends 5 Destroyer to UEF
    opai = SeraphimM5MainBase:AddNavalAI('M5_Sera_NavalAttack_UEF_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M5_Sera_Main_Naval_AttackUEF_Chain1',
                                'M5_Sera_Main_Naval_AttackUEF_Chain2'},
            },
            Overrides = {
                CORE_TO_CRUISERS = 3,
            },
            EnabledTypes = {'Destroyer', 'Cruiser'},
            MaxFrigates = 15,
            MinFrigates = 15,
            Priority = 300,
        }
    )
    opai:SetChildActive('T1', false)
    opai:SetChildActive('T3', false)
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.8})

    -- Sends 5 Destroyer to UEF
    opai = SeraphimM5MainBase:AddNavalAI('M5_Sera_NavalAttack_UEF_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M5_Sera_Main_Naval_AttackUEF_Chain1',
                                'M5_Sera_Main_Naval_AttackUEF_Chain2'},
            },
            EnabledTypes = {'Destroyer'},
            MaxFrigates = 25,
            MinFrigates = 25,
            Priority = 310,
        }
    )
    opai:SetChildActive('T1', false)
    opai:SetChildActive('T3', false)
    opai:SetFormation('AttackFormation')

    opai = SeraphimM5MainBase:AddNavalAI('M5_Sera_NavalAttack_UEF_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M5_Sera_Main_Naval_AttackUEF_Chain1',
                                'M5_Sera_Main_Naval_AttackUEF_Chain2'},
            },
            Overrides = {
                CORE_TO_CRUISERS = 2,
            },
            EnabledTypes = {'Destroyer', 'Cruiser'},
            MaxFrigates = 30,
            MinFrigates = 30,
            Priority = 310,
        }
    )
    opai:SetChildActive('T1', false)
    opai:SetChildActive('T3', false)
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})

    ----------
    -- Defense
    ----------
    quantity = {5, 6, 7}
    quantity2 = {1, 1, 2}
    Temp = {
        'SeraM5NavalDefenseTemp1',
        'NoPlan',
        { 'xss0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   -- Destroyers
        { 'xss0202', 1, quantity2[Difficulty], 'Attack', 'GrowthFormation' },   -- Cruisers
    }
    Builder = {
        BuilderName = 'SeraM5NavyDefenseBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 200,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'M5_Sera_Main_Base',
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
            PatrolChain = 'M5_Sera_Main_Naval_Def_Chain2',
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )

    quantity = {5, 6, 7}
    quantity2 = {1, 1, 2}
    Temp = {
        'SeraM5NavalDefenseTemp2',
        'NoPlan',
        { 'xss0201', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   -- Destroyers
        { 'xss0202', 1, quantity2[Difficulty], 'Attack', 'GrowthFormation' },   -- Cruisers
    }
    Builder = {
        BuilderName = 'SeraM5NavyDefenseBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 200,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'M5_Sera_Main_Base',
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
            PatrolChain = 'M5_Sera_Main_Naval_Def_Chain3',
        },
    }
    ArmyBrains[Seraphim]:PBMAddPlatoon( Builder )
end

-------------------
-- West Island Base
-------------------
function SeraphimM5IslandWestBaseAI()
    SeraphimM5IslandWestBase:Initialize(ArmyBrains[Seraphim], 'M5_Sera_Island_West_Base', 'M5_Sera_Island_West_Base_Marker', 80, {M5_Sera_Island_West_Base = 100})
    SeraphimM5IslandWestBase:StartNonZeroBase({24, 21})
    SeraphimM5IslandWestBase:SetActive('AirScouting', true)

    SeraphimM5IslandWestT2NavalBase:Initialize(ArmyBrains[Seraphim], 'M5_Sera_Island_West_Base_T2_Naval', 'M5_Sera_Island_West_Base_T2_Naval_Marker', 35, {M5_Sera_Island_West_Base_T2_Naval = 100})
    SeraphimM5IslandWestT2NavalBase:StartNonZeroBase({3, 2})

    SeraphimM5IslandWestBase:AddBuildGroup('M5_Sera_Island_West_BaseUnfinished', 90)
    
    SeraphimM5IslandWestBaseAirAttacks()
    SeraphimM5IslandWestBaseLandAttacks()
    SeraphimM5IslandWestBaseNavalAttacks()
end

function SeraphimM5IslandWestBaseAirAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    -- Transport Builder
    opai = SeraphimM5IslandWestBase:AddOpAI('EngineerAttack', 'M5_Sera_WestTransportBuilder',
    {
        MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
        PlatoonData = {
            TransportReturn = 'M5_Sera_Island_West_Base_Transport',
        },
        Priority = 1000,
    })
    opai:SetChildQuantity('T2Transports', 4)
    opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
        'HaveLessThanUnitsWithCategory', {'default_brain', 8, categories.xsa0104})   -- T2 Transport

    opai = SeraphimM5IslandWestBase:AddOpAI('AirAttacks', 'M5_Sera_West_AirAttackPlayer1' ,
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M5_Sera_Island_West_Air_AttackPlayer_Chain4',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'TorpedoBombers'}, 5)

    -- Builds platoon of 16 Bombers 3 times
    for i = 1, 3 do
        quantity = {10, 13, 16}
        opai = SeraphimM5IslandWestBase:AddOpAI('AirAttacks', 'M5_Sera_West_AirAttackPlayer2_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
                PlatoonData = {
                    PatrolChains = {'M5_Sera_Island_West_Air_AttackPlayer_Chain1', 'M5_Sera_Island_West_Air_AttackPlayer_Chain2', 'M5_Sera_Island_West_Air_AttackPlayer_Chain3'},
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('Bombers', quantity[Difficulty])
    end

    -- Builds platoon of 16 Gunships 3 times
    for i = 1, 3 do
        quantity = {10, 13, 16}
        trigger = {250, 240, 230}
        opai = SeraphimM5IslandWestBase:AddOpAI('AirAttacks', 'M5_Sera_West_AirAttackPlayer3_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
                PlatoonData = {
                    PatrolChains = {'M5_Sera_Island_West_Air_AttackPlayer_Chain1', 'M5_Sera_Island_West_Air_AttackPlayer_Chain2', 'M5_Sera_Island_West_Air_AttackPlayer_Chain3'},
                },
                Priority = 110,
            }
        )
        opai:SetChildQuantity('Gunships', quantity[Difficulty])
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
            {'default_brain', 'Player', trigger[Difficulty], categories.ALLUNITS - categories.WALL})
    end

    -- Builds platoon of 24 Interceptors 2 times if Player has more than 40 mobile air
    for i = 1, 2 do
        quantity = {16, 20, 24}
        trigger = {70, 60, 50}
        opai = SeraphimM5IslandWestBase:AddOpAI('AirAttacks', 'M5_Sera_West_AirAttackPlayer4_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
                PlatoonData = {
                    PatrolChains = {'M5_Sera_Island_West_Air_AttackPlayer_Chain1', 'M5_Sera_Island_West_Air_AttackPlayer_Chain2', 'M5_Sera_Island_West_Air_AttackPlayer_Chain3'},
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('Interceptors', quantity[Difficulty])
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
            {'default_brain', 'Player', trigger[Difficulty], categories.AIR * categories.MOBILE})
    end

    for i = 1, 2 do
        quantity = {10, 13, 16}
        trigger = {80, 70, 60}
        opai = SeraphimM5IslandWestBase:AddOpAI('AirAttacks', 'M5_Sera_West_AirAttackPlayer5_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
                PlatoonData = {
                    PatrolChains = {'M5_Sera_Island_West_Air_AttackPlayer_Chain1', 'M5_Sera_Island_West_Air_AttackPlayer_Chain2', 'M5_Sera_Island_West_Air_AttackPlayer_Chain3'},
                },
                Priority = 110,
            }
        )
        opai:SetChildQuantity('CombatFighters', quantity[Difficulty])
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
            {'default_brain', 'Player', trigger[Difficulty], categories.AIR * categories.MOBILE})
    end

    -- Air Defense
    -- Maintains 30 Interceptors
    for i = 1, 2 do
        quantity = {4, 6, 8}
        opai = SeraphimM5IslandWestBase:AddOpAI('AirAttacks', 'M5_WestAirDefense1_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M5_Sera_Island_West_AirDef_Chain',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('CombatFighters', quantity[Difficulty])
        opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    end

    -- Maintains 16 Gunships
    for i = 1, 2 do
        quantity = {4, 5, 6}
        opai = SeraphimM5IslandWestBase:AddOpAI('AirAttacks', 'M5_WestAirDefense2_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M5_Sera_Island_West_AirDef_Chain',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('Gunships', quantity[Difficulty])
        opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    end

    -- Maintains 15 Tropedo Bombers
    for i = 1, 2 do
        quantity = {3, 5, 7}
        opai = SeraphimM5IslandWestBase:AddOpAI('AirAttacks', 'M5_WestAirDefense3_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M5_Sera_Island_West_AirDef_Chain',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('TorpedoBombers', quantity[Difficulty])
        opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    end
end

function SeraphimM5IslandWestBaseLandAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    opai = SeraphimM5IslandWestBase:AddOpAI('EngineerAttack', 'M5_Sera_West_Reclaim_Engineers_1',
    {
        MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
        PlatoonData = {
            PatrolChain = 'M5_Sera_Island_West_Base_EngineerChain',
        },
        Priority = 300,
    })
    opai:SetChildQuantity('T2Engineers', 4)

    opai = SeraphimM5IslandWestBase:AddOpAI('EngineerAttack', 'M5_Sera_West_Reclaim_Engineers_2',
    {
        MasterPlatoonFunction = {SPAIFileName, 'SplitPatrolThread'},
        PlatoonData = {
            PatrolChains = {'M5_Sera_Island_West_Hover_Attack_Chain1',
                            'M5_Sera_Island_West_Hover_Attack_Chain2',
                            'M5_Sera_Island_West_Land_Attack_Chain',
                            'M5_Sera_Island_West_Navat_AttackPlayer_Chain'},
        },
        Priority = 500,
    })
    opai:SetChildQuantity('T2Engineers', 8)
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})

    quantity = {8, 10, 12}
    trigger = {20, 15, 10}
    for i = 1, 4 do
        opai = SeraphimM5IslandWestBase:AddOpAI('BasicLandAttack', 'M5_West_Hover_Attack1_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
                PlatoonData = {
                    PatrolChains = {'M5_Sera_Island_West_Hover_Attack_Chain1',
                                    'M5_Sera_Island_West_Hover_Attack_Chain2'},
                },
                Priority = 1000,
            }
        )
        opai:SetChildQuantity({'AmphibiousTanks', 'MobileFlak'}, quantity[Difficulty])
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
            {'default_brain', 'Player', trigger[Difficulty], categories.NAVAL * categories.TECH2})
    end

    quantity = {12, 16, 20}
    for i = 1, 3 do
        opai = SeraphimM5IslandWestBase:AddOpAI('BasicLandAttack', 'M5_WestLandAttack1_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M5_Sera_Island_West_Land_Attack_Chain',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('HeavyTanks', quantity[Difficulty])
    end

    quantity = {8, 12, 16}
    opai = SeraphimM5IslandWestBase:AddOpAI('BasicLandAttack', 'M5_WestLandAttack2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M5_Sera_Island_West_Land_Attack_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('MobileMissiles', quantity[Difficulty])

    quantity = {8, 12, 16}
    opai = SeraphimM5IslandWestBase:AddOpAI('BasicLandAttack', 'M5_WestLandAttackCivs1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M5_Sera_Island_West_Land_Attack_Civs_Chain',
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('LightTanks', quantity[Difficulty])

    quantity = {8, 10, 12}
    opai = SeraphimM5IslandWestBase:AddOpAI('BasicLandAttack', 'M5_WestLandAttackCivs2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M5_Sera_Island_West_Land_Attack_Civs_Chain',
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('LightArtillery', quantity[Difficulty])
end

function SeraphimM5IslandWestBaseNavalAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    quantity = {5, 6, 8}
    for i = 1, 2 do
        opai = SeraphimM5IslandWestBase:AddNavalAI('M5_Sera_West_NavalAttack_UEF_1_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M5_Sera_Island_West_Naval_AttackUEF_Chain',
                },
                Overrides = {
                    CORE_TO_SUBS = 2,
                },
                MaxFrigates = quantity[Difficulty],
                MinFrigates = quantity[Difficulty],
                Priority = 250,
            }
        )
        opai:SetChildActive('T2', false)
        opai:SetChildActive('T3', false)
        opai:SetFormation('AttackFormation')
        opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    end

    quantity = {20, 22, 24}
    trigger = {14, 10, 6}
    opai = SeraphimM5IslandWestBase:AddNavalAI('M5_Sera_West_NavalAttack_Player_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M5_Sera_Island_West_Navat_AttackPlayer_Chain',
            },
            Overrides = {
                CORE_TO_CRUISERS = 3,
            },
            EnabledTypes = {'Destroyer', 'Cruiser'},
            MaxFrigates = quantity[Difficulty],
            MinFrigates = quantity[Difficulty],
            Priority = 180,
        }
    )
    opai:SetChildActive('T1', false)
    opai:SetChildActive('T3', false)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.NAVAL * categories.TECH2})

    quantity = {15, 17, 19}
    trigger = {11, 7, 3}
    opai = SeraphimM5IslandWestBase:AddNavalAI('M5_Sera_West_NavalAttack_Player_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M5_Sera_Island_West_Navat_AttackPlayer_Chain',
            },
            Overrides = {
                CORE_TO_CRUISERS = 2,
            },
            EnabledTypes = {'Destroyer', 'Cruiser'},
            MaxFrigates = quantity[Difficulty],
            MinFrigates = quantity[Difficulty],
            Priority = 170,
        }
    )
    opai:SetChildActive('T1', false)
    opai:SetChildActive('T3', false)
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.NAVAL * categories.TECH2})

    opai = SeraphimM5IslandWestBase:AddNavalAI('M5_Sera_West_NavalAttack_Player_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M5_Sera_Island_West_Navat_AttackPlayer_Chain',
            },
            Overrides = {
                CORE_TO_CRUISERS = 2,
            },
            EnabledTypes = {'Cruiser'},
            MaxFrigates = 15,
            MinFrigates = 15,
            Priority = 200,
        }
    )
    opai:SetChildActive('T1', false)
    opai:SetChildActive('T3', false)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainLessThanOrEqualNumCategory',
        {'default_brain', 'Player', 0, categories.NAVAL * categories.FACTORY})

    opai = SeraphimM5IslandWestBase:AddNavalAI('M5_Sera_West_NavalAttack_Player_4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M5_Sera_Island_West_Navat_AttackPlayer_Chain',
            },
            Overrides = {
                CORE_TO_CRUISERS = 2,
            },
            EnabledTypes = {'Cruiser'},
            MaxFrigates = 15,
            MinFrigates = 15,
            Priority = 200,
        }
    )
    opai:SetChildActive('T1', false)
    opai:SetChildActive('T3', false)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainLessThanOrEqualNumCategory',
        {'default_brain', 'Player', 0, categories.NAVAL * categories.FACTORY + categories.uel0203})
end

---------------------------------
-- Seraphim M5 Island Middle Base
---------------------------------
function SeraphimM5IslandMiddleBaseAI()
    SeraphimM5IslandMiddleBase:Initialize(ArmyBrains[Seraphim], 'M5_Sera_Island_Middle_Base', 'M5_Sera_Island_Middle_Base_Marker', 60, {M5_Sera_Island_Middle_Base = 100})
    SeraphimM5IslandMiddleBase:StartNonZeroBase({20, 16})
    SeraphimM5IslandMiddleBase:SetActive('AirScouting', true)

    SeraphimM5IslandMiddleT1NavalBase:Initialize(ArmyBrains[Seraphim], 'M5_Sera_Island_Middle_Base_T1_Naval', 'M5_Sera_Island_Middle_Base_T1_Naval_Marker', 40, {M5_Sera_Island_Middle_Base_T1_Naval = 100})
    SeraphimM5IslandMiddleT1NavalBase:StartNonZeroBase({3, 2})

    SeraphimM5IslandMiddleT2NavalBase:Initialize(ArmyBrains[Seraphim], 'M5_Sera_Island_Middle_Base_T2_Naval', 'M5_Sera_Island_Middle_Base_T2_Naval_Marker', 30, {M5_Sera_Island_Middle_Base_T2_Naval = 100})
    SeraphimM5IslandMiddleT2NavalBase:StartEmptyBase({2, 1})

    SeraphimM5IslandMiddleBase:AddBuildGroup('M5_Sera_Island_Middle_BaseUnfinished', 95)
    SeraphimM5IslandMiddleBase:AddBuildGroup('M5_Sera_Island_Middle_Base_T1_Naval', 90)
    SeraphimM5IslandMiddleBase:AddBuildGroup('M5_Sera_Island_Middle_Base_T2_Naval', 86)
    
    SeraphimM5IslandMiddleBaseAirAttacks()
    SeraphimM5IslandMiddleBaseLandAttacks()
    SeraphimM5IslandMiddleBaseNavalAttacks()
end

function SeraphimM5IslandMiddleBaseAirAttacks()
    local opai = nil
    local quantity = {}

    -- Builds platoon of 8 Bombers 2 times
    quantity = {6, 7, 8}
    for i = 1, 2 do
        opai = SeraphimM5IslandMiddleBase:AddOpAI('AirAttacks', 'M5_Sera_Middle_AirAttackUEF1_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
                PlatoonData = {
                    PatrolChains = {'M5_Sera_Middle_Air_AttackUEF_Chain1',
                                    'M5_Sera_Middle_Air_AttackUEF_Chain2'},
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('Bombers', quantity[Difficulty])
    end

    -- Builds platoon of 10 Gunships 2 times
    quantity = {6, 8, 10}
    for i = 1, 2 do
        opai = SeraphimM5IslandMiddleBase:AddOpAI('AirAttacks', 'M5_Sera_Middle_AirAttackUEF2_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
                PlatoonData = {
                    PatrolChains = {'M5_Sera_Middle_Air_AttackUEF_Chain1',
                                    'M5_Sera_Middle_Air_AttackUEF_Chain2'},
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('Gunships', quantity[Difficulty])
    end

    -- Builds platoon of 10 TorpedoBombers
    quantity = {6, 8, 10}
    opai = SeraphimM5IslandMiddleBase:AddOpAI('AirAttacks', 'M5_Sera_Middle_AirAttackUEF3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M5_Sera_Middle_Air_AttackUEF_Chain1',
                                'M5_Sera_Middle_Air_AttackUEF_Chain2'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('TorpedoBombers', quantity[Difficulty])

    -- Builds platoon of 12 Gunships 2 times
    quantity = {8, 10, 12}
    opai = SeraphimM5IslandMiddleBase:AddOpAI('AirAttacks', 'M5_Sera_Middle_AirAttackUEF4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M5_Sera_Middle_Air_AttackUEF_Chain1',
                                'M5_Sera_Middle_Air_AttackUEF_Chain2'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Interceptors', quantity[Difficulty])
end

function SeraphimM5IslandMiddleBaseLandAttacks()
    local opai = nil
    
    -- Transport Builder
    opai = SeraphimM5IslandMiddleBase:AddOpAI('EngineerAttack', 'M5_Sera_MiddleTransportBuilder',
    {
        MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
        PlatoonData = {
            TransportReturn = 'M5_Sera_Middle_Transport_Marker',
        },
        Priority = 1000,
    })
    opai:SetChildQuantity('T2Transports', 4)
    opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
        'HaveLessThanUnitsWithCategory', {'default_brain', 8, categories.xsa0104})   -- T2 Transport

    for i = 1, 2 do
        opai = SeraphimM5IslandMiddleBase:AddOpAI('BasicLandAttack', 'M5_Sera_Middle_TransportAttack1_' .. i,
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain = 'M5_Sera_Middle_Transport_Attack_Chain',
                LandingChain = 'M5_Sera_Middle_Landing_Chain',
                TransportReturn = 'M5_Sera_Middle_Transport_Marker',
            },
            Priority = 100,
        })
        opai:SetChildQuantity('AmphibiousTanks', 16)
    end

    for i = 1, 2 do
        opai = SeraphimM5IslandMiddleBase:AddOpAI('BasicLandAttack', 'M5_Sera_Middle_TransportAttack2_' .. i,
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain = 'M5_Sera_Middle_Transport_Attack_Chain',
                LandingChain = 'M5_Sera_Middle_Landing_Chain',
                TransportReturn = 'M5_Sera_Middle_Transport_Marker',
            },
            Priority = 100,
        })
        opai:SetChildQuantity('LightArtillery', 16)
    end
end

function SeraphimM5IslandMiddleBaseNavalAttacks()
    local opai = nil
    local quantity = {}

    quantity = {15, 17, 20}
    opai = SeraphimM5IslandMiddleT2NavalBase:AddNavalAI('M5_Sera_Middle_NavalAttack_UEF_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M5_Sera_Middle_Naval_Attack_Chain',
            },
            Overrides = {
                CORE_TO_CRUISERS = 2,
            },
            EnabledTypes = {'Destroyer', 'Cruiser'},
            MaxFrigates = quantity[Difficulty],
            MinFrigates = quantity[Difficulty],
            Priority = 200,
        }
    )
    opai:SetChildActive('T1', false)
    opai:SetChildActive('T3', false)
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})

    quantity = {15, 17, 20}
    opai = SeraphimM5IslandMiddleT2NavalBase:AddNavalAI('M5_Sera_Middle_NavalAttack_UEF_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M5_Sera_Middle_Naval_Attack_Chain',
            },
            EnabledTypes = {'Destroyer'},
            MaxFrigates = quantity[Difficulty],
            MinFrigates = quantity[Difficulty],
            Priority = 250,
        }
    )
    opai:SetChildActive('T1', false)
    opai:SetChildActive('T3', false)

    quantity = {5, 6, 8}
    for i = 1, 2 do
        opai = SeraphimM5IslandMiddleT1NavalBase:AddNavalAI('M5_Sera_Middle_NavalAttack_UEF_3_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M5_Sera_Middle_Naval_Attack_Chain',
                },
                Overrides = {
                    CORE_TO_SUBS = 2,
                },
                MaxFrigates = quantity[Difficulty],
                MinFrigates = quantity[Difficulty],
                Priority = 250,
            }
        )
        opai:SetChildActive('T2', false)
        opai:SetChildActive('T3', false)
    end
end

function CDROnWater(category)
    local unit = ArmyBrains[Player]:GetListOfUnits(categories.COMMAND, false)
    local result = false

    if(unit[1] and not unit[1]:IsDead() and unit[1]:GetCurrentLayer() == 'Seabed') then
        result = true
    else
        result = false
    end

    return result
end

function M5AttackCDRWaterAI(platoon)
    local unit = ArmyBrains[Player]:GetListOfUnits(categories.COMMAND, false)
    if(unit[1] and not unit[1]:IsDead() and unit[1]:GetCurrentLayer() == 'Seabed') then
        platoon:AttackTarget(unit[1])
    else
        ScenarioFramework.PlatoonPatrolChain(platoon, 'M5_Sera_Main_Naval_AttackPlayer_Chain' .. Random(1, 3))
    end
end