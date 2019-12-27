local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'
local ScenarioFramework = import('/lua/ScenarioFramework.lua')

local Player1 = 2
local Cybran = 3
local Difficulty = ScenarioInfo.Options.Difficulty

local CybranP3base1 = BaseManager.CreateBaseManager()

function CybranP3base1AI()
	
    CybranP3base1:InitializeDifficultyTables(ArmyBrains[Cybran], 'P3Cybranbase1', 'P3CB1MK', 90, {P3CBase1 = 100})
    CybranP3base1:StartNonZeroBase({{13,17,21}, {10,14,18}})
    CybranP3base1:SetActive('AirScouting', true)
	
	P3CAirattacks1()
	P3CNavalAttacks1()
	P3CLandAttacks1()
	P3CB1EXPattacks1()
	
end

function P3CAirattacks1()

    local Temp = {
       'P3CB1AirattackTemp1',
       'NoPlan',
       { 'ura0203', 1, 12, 'Attack', 'GrowthFormation' },
       { 'xra0305', 1, 4, 'Attack', 'GrowthFormation' }, 
    }
    local Builder = {
       BuilderName = 'P3CB1AirattackBuilder1',
       PlatoonTemplate = Temp,
       InstanceCount = 2,
       Priority = 100,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'P3Cybranbase1',   
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P3CAirattack1', 'P3CAirattack2', 'P3CAirattack3'}
       },
    }
    ArmyBrains[Cybran]:PBMAddPlatoon( Builder )
	
	Temp = {
       'P3CB1AirattackTemp2',
       'NoPlan',
       { 'ura0303', 1, 8, 'Attack', 'GrowthFormation' },
       { 'ura0304', 1, 4, 'Attack', 'GrowthFormation' }, 
    }
    Builder = {
       BuilderName = 'P3CB1AirattackBuilder2',
       PlatoonTemplate = Temp,
       InstanceCount = 2,
       Priority = 100,
       PlatoonType = 'Air',
       RequiresConstruction = true,
       LocationType = 'P3Cybranbase1',   
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P3CAirattack1', 'P3CAirattack2', 'P3CAirattack3'}
       },
    }
    ArmyBrains[Cybran]:PBMAddPlatoon( Builder )

end

function P3CNavalAttacks1()

    local Temp = {
       'P3CB1NavalattackTemp0',
       'NoPlan',
       { 'urs0201', 1, 6, 'Attack', 'GrowthFormation' },
	   { 'urs0202', 1, 4, 'Attack', 'GrowthFormation' },
       { 'urs0303', 1, 1, 'Attack', 'GrowthFormation' }, 
    }
    local Builder = {
       BuilderName = 'P3CB1NavalattackBuilder0',
       PlatoonTemplate = Temp,
       InstanceCount = 1,
       Priority = 100,
       PlatoonType = 'Sea',
       RequiresConstruction = true,
       LocationType = 'P3Cybranbase1',   
       PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
       PlatoonData = {
           PatrolChain = 'P3CNavaldefence1'
       },
    }
    ArmyBrains[Cybran]:PBMAddPlatoon( Builder )

    Temp = {
       'P3CB1NavalattackTemp1',
       'NoPlan',
       { 'urs0201', 1, 4, 'Attack', 'GrowthFormation' },
       { 'urs0202', 1, 4, 'Attack', 'GrowthFormation' }, 
    }
    Builder = {
       BuilderName = 'P3CB1NavalattackBuilder1',
       PlatoonTemplate = Temp,
       InstanceCount = 2,
       Priority = 100,
       PlatoonType = 'Sea',
       RequiresConstruction = true,
       LocationType = 'P3Cybranbase1',   
       PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
       PlatoonData = {
           PatrolChain = 'P3CNavalattack1'
       },
    }
    ArmyBrains[Cybran]:PBMAddPlatoon( Builder )
	
	Temp = {
       'P3CB1NavalattackTemp2',
       'NoPlan',
       { 'xrs0204', 1, 7, 'Attack', 'GrowthFormation' },
       { 'urs0304', 1, 1, 'Attack', 'GrowthFormation' },	   
    }
    Builder = {
       BuilderName = 'P3CB1NavalattackBuilder2',
       PlatoonTemplate = Temp,
       InstanceCount = 1,
       Priority = 100,
       PlatoonType = 'Sea',
       RequiresConstruction = true,
       LocationType = 'P3Cybranbase1',   
       PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
       PlatoonData = {
           PatrolChain = 'P3CNavalattack1'
       },
    }
    ArmyBrains[Cybran]:PBMAddPlatoon( Builder )
	
	Temp = {
       'P3CB1NavalattackTemp3',
       'NoPlan',
       { 'urs0302', 1, 2, 'Attack', 'GrowthFormation' },
       { 'urs0202', 1, 4, 'Attack', 'GrowthFormation' }, 	   
    }
    Builder = {
       BuilderName = 'P3CB1NavalattackBuilder3',
       PlatoonTemplate = Temp,
       InstanceCount = 2,
       Priority = 100,
       PlatoonType = 'Sea',
       RequiresConstruction = true,
       LocationType = 'P3Cybranbase1',   
       PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
       PlatoonData = {
           PatrolChain = 'P3CNavalattack1'
       },
    }
    ArmyBrains[Cybran]:PBMAddPlatoon( Builder )

end

function P3CLandAttacks1()

    local Temp = {
       'P3CB1LandattackTemp1',
       'NoPlan',
       { 'url0203', 1, 6, 'Attack', 'GrowthFormation' },
       { 'xrl0305', 1, 4, 'Attack', 'GrowthFormation' }, 
    }
    local Builder = {
       BuilderName = 'P3CB1LandattackBuilder1',
       PlatoonTemplate = Temp,
       InstanceCount = 5,
       Priority = 100,
       PlatoonType = 'Land',
       RequiresConstruction = true,
       LocationType = 'P3Cybranbase1',   
       PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
       PlatoonData = {
           PatrolChains = {'P3CB1Landattack1', 'P3CB1Landattack2'}
       },
    }
    ArmyBrains[Cybran]:PBMAddPlatoon( Builder )

    opai = CybranP3base1:AddOpAI('EngineerAttack', 'M3_Cybran_TransportBuilder1',
    {
        MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
        PlatoonData = {
            TransportReturn = 'P3CB1MK',
        },
        Priority = 1000,
    })
    opai:SetChildQuantity('T2Transports', 4)
    opai:SetLockingStyle('None')
    opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
        'HaveLessThanUnitsWithCategory', {'default_brain', 4, categories.ura0104})
   
   
    opai = CybranP3base1:AddOpAI('BasicLandAttack', 'M3_Cybran_TransportAttack_1',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain =  'P3CLandingchainA1', 
                LandingChain = 'P3CLandingchain1',
                TransportReturn = 'P3CB1MK',
            },
            Priority = 510,
        }
    )
    opai:SetChildQuantity('HeavyBots', 8)
    opai:SetLockingStyle('BuildTimer', {LockTimer = 60})
	
	opai = CybranP3base1:AddOpAI('BasicLandAttack', 'M3_Cybran_TransportAttack_2',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain =  'P3CLandingchainA1', 
                LandingChain = 'P3CLandingchain1',
                TransportReturn = 'P3CB1MK',
            },
            Priority = 500,
        }
    )
    opai:SetChildQuantity('MobileHeavyArtillery', 8)
    opai:SetLockingStyle('BuildTimer', {LockTimer = 120})


end

function P3CB1EXPattacks1()
    local opai = nil
    local quantity = {}
    
    opai = CybranP3base1:AddOpAI('P3CExp1',
        {
            Amount = 2,
            KeepAlive = true,
           PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
           PlatoonData = {
           PatrolChains = {'P3CAirattack1', 'P3CAirattack2', 'P3CAirattack3'}
       },
            MaxAssist = 3,
            Retry = true,
        }
    )

end


