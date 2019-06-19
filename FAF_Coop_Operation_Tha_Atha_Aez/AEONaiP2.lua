local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'
local ScenarioFramework = import('/lua/ScenarioFramework.lua')

local Aeon = 4
local Player1 = 1

local Difficulty = ScenarioInfo.Options.Difficulty

local Aeonbase3 = BaseManager.CreateBaseManager()
local Aeonbase1 = BaseManager.CreateBaseManager()
local Aeonbase2 = BaseManager.CreateBaseManager()

function AeonBase1AI()
    Aeonbase1:InitializeDifficultyTables(ArmyBrains[Aeon], 'AeonBase1', 'P2AB1MK', 90, {P2Abase1 = 300})
    Aeonbase1:StartNonZeroBase({{18,22,26}, {16,20,24}})
    Aeonbase1:SetActive('AirScouting', true)

    P2AB1landattacks1()
	P2AB1airattacks1()
end

function AeonBase2AI()
    Aeonbase2:InitializeDifficultyTables(ArmyBrains[Aeon], 'AeonBase2', 'P2AB0MK', 40, {AeonIntel = 300})
    Aeonbase2:StartNonZeroBase({{4,8,10}, {2,6,8}})
    
    AeonIntelattacks()
end

function AeonBase3AI()
    Aeonbase3:InitializeDifficultyTables(ArmyBrains[Aeon], 'AeonBase3', 'P3AB2MK', 60, {P3Abase2 = 300})
    Aeonbase3:StartNonZeroBase({{10,14,18}, {8,12,16}})
    Aeonbase3:SetActive('AirScouting', true)

	AeonNattack2()
end

function P3Aattacks()

    P3AB1landattacks2()
    P3AB1Airattacks2()
	EXpattacks1()
end

function AeonIntelattacks()
   
    local Temp = {
        'P2AB2LandattackTemp0',
        'NoPlan',
        { 'ual0303', 1, 6, 'Attack', 'GrowthFormation' },
	}
	local Builder = {
        BuilderName = 'P2AB2LandattackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'AeonBase2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},
        PlatoonData = {
            PatrolChains = {'P2AB2landattack1', 'P2AB2landattack2'}
        },
	}
	ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
	
	Temp = {
        'P2AB2LandattackTemp1',
        'NoPlan',
        { 'ual0202', 1, 8, 'Attack', 'GrowthFormation' },
	}
	Builder = {
        BuilderName = 'P2AB2LandattackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'AeonBase2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2AB2landattack1', 'P2AB2landattack2'}
        },
	}
	ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
	
	Temp = {
        'P2AB2LandattackTemp2',
        'NoPlan',
        { 'ual0202', 1, 4, 'Attack', 'GrowthFormation' },
		{ 'ual0303', 1, 4, 'Attack', 'GrowthFormation' },
	}
	Builder = {
        BuilderName = 'P2AB2LandattackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'AeonBase2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'}, 
        PlatoonData = {
            PatrolChains = {'P2AB2landattack1', 'P2AB2landattack2'}
        },	
	}
	
	ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
	
   


end

function P2AB1landattacks1()

    local opai = nil
   
	local Temp = {
        'P2AB1LandattackTemp0',
        'NoPlan',
        { 'xal0203', 1, 6, 'Attack', 'GrowthFormation' },
		{ 'ual0205', 1, 4, 'Attack', 'GrowthFormation' },
		{ 'ual0307', 1, 4, 'Attack', 'GrowthFormation' },
	}
	local Builder = {
        BuilderName = 'P2AB1LandattackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 6,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'AeonBase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2AB1landattack1', 'P2AB1landattack2'}
        },
	}
	ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
	
	opai = Aeonbase1:AddOpAI('EngineerAttack', 'M2_AEON_TransportBuilder1',
    {
        MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
        PlatoonData = {
            TransportReturn = 'P2AB1MK',
        },
        Priority = 1000,
    })
    opai:SetChildQuantity('T2Transports', 4)
    opai:SetLockingStyle('None')
    opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
        'HaveLessThanUnitsWithCategory', {'default_brain', 3, categories.uaa0104})
   
   
    opai = Aeonbase1:AddOpAI('BasicLandAttack', 'M2_Aeon_TransportAttack_1',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain =  'P2Aintattack1', 
                LandingChain = 'AeonattackDrop',
                TransportReturn = 'P2AB1MK',
            },
            Priority = 550,
        }
    )
    opai:SetChildQuantity('HeavyTanks', 24)
    opai:SetLockingStyle('DeathTimer', {LockTimer = 30})
	
	opai = Aeonbase1:AddOpAI('BasicLandAttack', 'M2_Aeon_TransportAttack_2',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain =  'P2Aintattack1', 
                LandingChain = 'AeonattackDrop',
                TransportReturn = 'P2AB1MK',
            },
            Priority = 550,
        }
    )
    opai:SetChildQuantity('SiegeBots', 8)
    opai:SetLockingStyle('DeathTimer', {LockTimer = 90})
	
end

function P2AB1airattacks1()
   
	local Temp = {
        'P2AB1airattackTemp1',
        'NoPlan',
        { 'uaa0203', 1, 16, 'Attack', 'AttackFormation' },
	}
	local Builder = {
        BuilderName = 'P2AB1airattackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'AeonBase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread' },     
        PlatoonData = {
            PatrolChains = {'P2AB1airattack1', 'P2AB1airattack2', 'P2AB1airattack3'}
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
	
	Temp = {
        'P2AB1airattackTemp2',
        'NoPlan',
        { 'xaa0202', 1, 16, 'Attack', 'AttackFormation' },
	}
    Builder = {
        BuilderName = 'P2AB1airattackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'AeonBase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread' },     
        PlatoonData = {
            PatrolChains = {'P2AB1airattack1', 'P2AB1airattack2', 'P2AB1airattack3'}
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
	
	Temp = {
        'P2AB1airattackTemp3',
        'NoPlan',
        { 'uaa0303', 1, 8, 'Attack', 'AttackFormation' },
		{ 'xaa0202', 1, 8, 'Attack', 'AttackFormation' },
	}
    Builder = {
        BuilderName = 'P2AB1airattackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'AeonBase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread' },     
        PlatoonData = {
            PatrolChains = {'P2AB1airattack1', 'P2AB1airattack2', 'P2AB1airattack3'}
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
	
	Temp = {
        'P2AB1airattackTemp4',
        'NoPlan',
        { 'xaa0305', 1, 4, 'Attack', 'AttackFormation' },
		{ 'uaa0203', 1, 8, 'Attack', 'AttackFormation' },
	}
    Builder = {
        BuilderName = 'P2AB1airattackBuilder4',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'AeonBase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread' },     
        PlatoonData = {
            PatrolChains = {'P2AB1airattack1', 'P2AB1airattack2', 'P2AB1airattack3'}
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
	
	
	
end

function AeonNattack2()

    local Temp = {
        'P3AB2airTemp1',
        'NoPlan',
        { 'xaa0305', 1, 5, 'Attack', 'GrowthFormation' },
        { 'uaa0203', 1, 15, 'Attack', 'GrowthFormation' },
	}
	local Builder = {
        BuilderName = 'P3AB2airBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 400,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'AeonBase3',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread' },     
        PlatoonData = {
            PatrolChains = {'P3A1B2airattack1', 'P3A1B2airattack2'}
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
	
	Temp = {
        'P3AB2airTemp2',
        'NoPlan',
        { 'uaa0303', 1, 10, 'Attack', 'GrowthFormation' },
	    { 'uaa0304', 1, 5, 'Attack', 'GrowthFormation' },
	}
	Builder = {
        BuilderName = 'P3AB2airBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 400,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'AeonBase3',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread' },     
        PlatoonData = {
            PatrolChains = {'P3A1B2airattack1', 'P3A1B2airattack2'}
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
	
	Temp = {
        'P3AB2airTemp3',
        'NoPlan',
        { 'uaa0303', 1, 15, 'Attack', 'GrowthFormation' },
	}
	Builder = {
        BuilderName = 'P3AB2airBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 400,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'AeonBase3',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread' },     
        PlatoonData = {
            PatrolChains = {'P3A1B2airattack1', 'P3A1B2airattack2'}
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )

    Temp = {
        'AeonNavalTemp1',
        'NoPlan',
        { 'xas0306', 1, 2, 'Attack', 'GrowthFormation' },  --Tac boats
        { 'uas0202', 1, 4, 'Attack', 'GrowthFormation' },  --Crusier
	}
    Builder = {
        BuilderName = 'AeonNavalBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 100,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'AeonBase3',
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P3Anavalattack1'
        },
    }
	ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
	
	Temp = {
        'AeonNavalTemp2',
        'NoPlan',
        { 'uas0202', 1, 3, 'Attack', 'GrowthFormation' },
        { 'uas0201', 1, 3, 'Attack', 'GrowthFormation' },
	}
    Builder = {
        BuilderName = 'AeonNavalBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 400,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'AeonBase3',
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P3Anavalattack1'
        },
    }
	ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
	
	Temp = {
        'AeonNavalTemp3',
        'NoPlan',
        { 'uas0202', 1, 2, 'Attack', 'GrowthFormation' },
        { 'uas0203', 1, 8, 'Attack', 'GrowthFormation' },
	}
    Builder = {
        BuilderName = 'AeonNavalBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 400,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'AeonBase3',
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P3Anavalattack1'
        },
    }
	ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
	
end

function P3AB1landattacks2()
     
	local opai = nil
	 
    opai = Aeonbase1:AddOpAI('EngineerAttack', 'M3_AEON_TransportBuilder2',
     {
        MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
        PlatoonData = {
            TransportReturn = 'P2AB1MK',
        },
        Priority = 2000,
     }
	)
    opai:SetChildQuantity('T2Transports', 8)
    opai:SetLockingStyle('None')
    opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
        'HaveLessThanUnitsWithCategory', {'default_brain', 7, categories.uaa0104})


     opai = Aeonbase1:AddOpAI('BasicLandAttack', 'M3_Aeon_TransportAttack_1',
            {
                MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
                PlatoonData = {
                    AttackChain =  'P3AB1dropattack1', 
                    LandingChain = 'P3AB1drop1',
		    		MovePath = 'P3AB1movedrop1',
                    TransportReturn = 'P2AB1MK',
                },
                Priority = 600,
            }
        )
        opai:SetChildQuantity({'HeavyTanks', 'MobileMissiles'}, {12, 12})
        opai:SetLockingStyle('DeathTimer', {LockTimer = 30})
	
	opai = Aeonbase1:AddOpAI('BasicLandAttack', 'M3_Aeon_TransportAttack_2',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain =  'P3AB1dropattack1', 
                LandingChain = 'P3AB1drop1',
				MovePath = 'P3AB1movedrop1',
                TransportReturn = 'P2AB1MK',
            },
            Priority = 600,
        }
    )
    opai:SetChildQuantity('SiegeBots', 8)
    opai:SetLockingStyle('DeathTimer', {LockTimer = 50})
	
	opai = Aeonbase1:AddOpAI('BasicLandAttack', 'M3_Aeon_TransportAttack_3',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},	
            PlatoonData = {
                AttackChain =  'P3AB1dropattack2', 
                LandingChain = 'P3AB1drop2',
				MovePath = 'P3AB1movedrop2',
                TransportReturn = 'P2AB1MK',
            },
            Priority = 600,
        }
    )
    opai:SetChildQuantity('SiegeBots', 8)
    opai:SetLockingStyle('DeathTimer', {LockTimer = 50})
	
	opai = Aeonbase1:AddOpAI('BasicLandAttack', 'M3_Aeon_TransportAttack_4',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain =  'P3AB1dropattack2', 
                LandingChain = 'P3AB1drop2',
				MovePath = 'P3AB1movedrop2',
                TransportReturn = 'P2AB1MK',
            },
            Priority = 600,
        }
    )
    opai:SetChildQuantity({'HeavyTanks', 'MobileMissiles'}, {12, 12})
    opai:SetLockingStyle('DeathTimer', {LockTimer = 30})
	
	opai = Aeonbase1:AddOpAI('BasicLandAttack', 'M3_Aeon_TransportAttack_5',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain =  'P3AB1dropattack3', 
                LandingChain = 'P3AB1drop3',
                TransportReturn = 'P2AB1MK',
            },
            Priority = 600,
        }
    )
    opai:SetChildQuantity('SiegeBots', 8)
    opai:SetLockingStyle('DeathTimer', {LockTimer = 50})
	
	opai = Aeonbase1:AddOpAI('BasicLandAttack', 'M3_Aeon_TransportAttack_6',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain =  'P3AB1dropattack3', 
                LandingChain = 'P3AB1drop3',
                TransportReturn = 'P2AB1MK',
            },
            Priority = 600,
        }
    )
    opai:SetChildQuantity({'HeavyTanks', 'MobileMissiles'}, {12, 12})
    opai:SetLockingStyle('DeathTimer', {LockTimer = 30})
	
	local Temp = {
        'P3AB1LandattackTemp0',
        'NoPlan',
        { 'xal0203', 1, 8, 'Attack', 'GrowthFormation' },
		{ 'ual0205', 1, 4, 'Attack', 'GrowthFormation' },
		{ 'ual0307', 1, 4, 'Attack', 'GrowthFormation' },
	}
	local Builder = {
        BuilderName = 'P3AB1LandattackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 200,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'AeonBase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2AB1landattack1', 'P2AB1landattack2'}
        },
	}
	ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
	
end

function P3AB1Airattacks2()

    local Temp = {
        'P3AB1airattackTemp0',
        'NoPlan',
        { 'uaa0303', 1, 8, 'Attack', 'AttackFormation' },
	}
	local Builder = {
        BuilderName = 'P3AB1airattackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 300,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'AeonBase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread' },     
        PlatoonData = {
            PatrolChains = {'P3AB1Airattack1', 'P3AB1Airattack2', 'P3AB1Airattack3'}
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
	
	Temp = {
        'P3AB1airattackTemp1',
        'NoPlan',
        { 'uaa0203', 1, 18, 'Attack', 'AttackFormation' },
	}
	Builder = {
        BuilderName = 'P3AB1airattackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 300,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'AeonBase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread' },     
        PlatoonData = {
            PatrolChains = {'P3AB1Airattack1', 'P3AB1Airattack2', 'P3AB1Airattack3'}
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
	
	Temp = {
        'P3AB1airattackTemp2',
        'NoPlan',
        { 'uaa0304', 1, 4, 'Attack', 'AttackFormation' },
	}
	Builder = {
        BuilderName = 'P3AB1airattackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 300,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'AeonBase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread' },     
        PlatoonData = {
            PatrolChains = {'P3AB1Airattack1', 'P3AB1Airattack2', 'P3AB1Airattack3'}
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )
	
	Temp = {
        'P3AB1airattackTemp3',
        'NoPlan',
        { 'uaa0203', 1, 12, 'Attack', 'AttackFormation' },
		{ 'xaa0305', 1, 4, 'Attack', 'AttackFormation' },
	}
	Builder = {
        BuilderName = 'P3AB1airattackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 300,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'AeonBase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread' },     
        PlatoonData = {
            PatrolChains = {'P3AB1Airattack1', 'P3AB1Airattack2', 'P3AB1Airattack3'}
        },
    }
    ArmyBrains[Aeon]:PBMAddPlatoon( Builder )


end

function EXpattacks1()
    local opai = nil
    local quantity = {}
    
    opai = Aeonbase1:AddOpAI('Abot1',
        {
            Amount = 2,
            KeepAlive = true,
           PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P2AB1landattack1', 'P2AB1landattack2'}
        },
            MaxAssist = 4,
            Retry = true,
        }
    )

end

function DisableABase()
    if(Aeonbase1) then
        LOG('Aeonbase1 stopped')
        Aeonbase1:BaseActive(false)
    end
    for _, platoon in ArmyBrains[Aeon]:GetPlatoonsList() do
        platoon:Stop()
        ArmyBrains[Aeon]:DisbandPlatoon(platoon)
    end
    LOG('All Platoons of Aeonbase1 stopped')
end

function DisableABase2()
    if(Aeonbase3) then
        LOG('Aeonbase3 stopped')
        Aeonbase3:BaseActive(false)
    end
    for _, platoon in ArmyBrains[Aeon]:GetPlatoonsList() do
        platoon:Stop()
        ArmyBrains[Aeon]:DisbandPlatoon(platoon)
    end
    LOG('All Platoons of Aeonbase3 stopped')
end

