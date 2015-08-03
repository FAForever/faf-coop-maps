local BaseManager = import('/lua/ai/opai/basemanager.lua')
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'

# ------
# Locals
# ------
local UEF = 2

# -------------
# Base Managers
# -------------
local UEFM2SouthBase = BaseManager.CreateBaseManager()
local UEFM2T1Base = BaseManager.CreateBaseManager()
local UEFM2EngiBase = BaseManager.CreateBaseManager()

function UEFM2SouthBaseAI()

    # -----------------
    # UEF M2 South Base
    # -----------------
    UEFM2SouthBase:Initialize(ArmyBrains[UEF], 'M2_South_Base', 'M2_South_Base_Marker', 38, {M2_South_Base = 100})
    UEFM2SouthBase:StartNonZeroBase({12, 9})
    UEFM2SouthBase:SetActive('AirScouting', true)

    UEFM2T1Base:Initialize(ArmyBrains[UEF], 'M2_T1_Base', 'M2_T1_Base_Marker', 27, {M2_T1_Base = 100})
    UEFM2T1Base:StartNonZeroBase({8, 6})
    UEFM2T1Base:SetActive('AirScouting', true)

    UEFM2T1Base:AddBuildGroup('M2_Engi_Base', 90)

    UEFM2EngiBase:Initialize(ArmyBrains[UEF], 'M2_Engi_Base', 'M2_Engi_Base_Marker', 10, {M2_Engi_Base = 100})
    UEFM2EngiBase:StartNonZeroBase()
    UEFM2EngiBase:SetActive('LandScouting', false)

    UEFM2SouthBaseAirAttacks()
    UEFM2SouthBaseLandAttacks()

end

function UEFM2SouthBaseAirAttacks()
    
    for i = 1, 3 do
        opai = UEFM2SouthBase:AddOpAI('AirAttacks', 'M2SouthBaseAirAttack2_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
                PlatoonData = {
                    PatrolChains = {'M2_SouthBase_Land_Attack_Chain1', 'M2_SouthBase_Land_Attack_Chain2', 'M2_SouthBase_Land_Attack_Chain3', 'M2_SouthBase_Land_Attack_Chain4', 'M2_SouthBase_Land_Attack_Chain5', 'M2_SouthBase_Land_Attack_Chain6', 'M2_SouthBase_AirAttack_Chain1', 'M2_SouthBase_AirAttack_Chain2', 'M2_SouthBase_AirAttack_Chain3'},
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('Gunships', 4)
    end

    local Temp = {
        'ComabtFighetTemp1',
        'NoPlan',
        { 'dea0202', 1, 3, 'Attack', 'GrowthFormation' },   # T2 CombatFighter
    }
    local Builder = {
        BuilderName = 'CombatFighterAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'M2_South_Base',
        BuildConditions = {
            { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', 10, categories.STRUCTURE * categories.ANTIAIR}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},       
        PlatoonData = {
            PatrolChains = {'M2_SouthBase_Land_Attack_Chain1', 'M2_SouthBase_Land_Attack_Chain2', 'M2_SouthBase_Land_Attack_Chain3', 'M2_SouthBase_Land_Attack_Chain4', 'M2_SouthBase_Land_Attack_Chain5', 'M2_SouthBase_Land_Attack_Chain6'},
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    # Defenses
    for i = 1, 4 do
        opai = UEFM2SouthBase:AddOpAI('AirAttacks', 'M2SouthBaseAirDef1_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M2_SouthBase_Air_Def_Chain',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('Interceptors', 4)
    end

    for i = 1, 4 do
        opai = UEFM2SouthBase:AddOpAI('AirAttacks', 'M2SouthBaseAirDef3_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M2_SouthBase_Air_Def_Chain',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('Gunships', 3)
    end

    for i = 1, 4 do
        opai = UEFM2T1Base:AddOpAI('AirAttacks', 'M2_T1BaseAirAttack1_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
                PlatoonData = {
                    PatrolChains = {'M2_SouthBase_Land_Attack_Chain1', 'M2_SouthBase_Land_Attack_Chain2', 'M2_SouthBase_Land_Attack_Chain3', 'M2_SouthBase_Land_Attack_Chain4', 'M2_SouthBase_Land_Attack_Chain5', 'M2_SouthBase_Land_Attack_Chain6', 'M2_SouthBase_AirAttack_Chain1', 'M2_SouthBase_AirAttack_Chain2', 'M2_SouthBase_AirAttack_Chain3'},
                },
                Priority = 110,
            }
        )
        opai:SetChildQuantity('Bombers', 6)
    end

    for i = 1, 2 do
        opai = UEFM2T1Base:AddOpAI('AirAttacks', 'M2_T1BaseAirAttack2_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
                PlatoonData = {
                    PatrolChains = {'M2_SouthBase_Land_Attack_Chain1', 'M2_SouthBase_Land_Attack_Chain2', 'M2_SouthBase_Land_Attack_Chain3', 'M2_SouthBase_Land_Attack_Chain4', 'M2_SouthBase_Land_Attack_Chain5', 'M2_SouthBase_Land_Attack_Chain6', 'M2_SouthBase_AirAttack_Chain1', 'M2_SouthBase_AirAttack_Chain2', 'M2_SouthBase_AirAttack_Chain3'},
                },
                Priority = 110,
            }
        )
        opai:SetChildQuantity('Interceptors', 6)
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
            {'default_brain', 'Player', 10, categories.AIR + categories.MOBILE})
    end

    # Defenses
    for i = 1, 4 do
        opai = UEFM2T1Base:AddOpAI('AirAttacks', 'M2SouthBaseAirDef2_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M2_SouthBase_Air_Def_Chain',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('Bombers', 3)
    end

end

function UEFM2SouthBaseLandAttacks()

    # sends 8 [heavy tanks] 
    opai = UEFM2SouthBase:AddOpAI('BasicLandAttack', 'M2_SouthBaseLandAttack2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_SouthBase_Land_Attack_Chain1', 'M2_SouthBase_Land_Attack_Chain2', 'M2_SouthBase_Land_Attack_Chain3', 'M2_SouthBase_Land_Attack_Chain4', 'M2_SouthBase_Land_Attack_Chain5', 'M2_SouthBase_Land_Attack_Chain6'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('HeavyTanks', 8)

    local Temp = {
        'T2TanksTemp1',
        'NoPlan',
        { 'uel0202', 1, 10, 'Attack', 'GrowthFormation' },   # T2 Tank
        { 'uel0307', 1, 2, 'Attack', 'GrowthFormation' },   # T2 Mobile Shield
    }
    local Builder = {
        BuilderName = 'T2TankAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'M2_South_Base',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},       
        PlatoonData = {
            PatrolChains = {'M2_SouthBase_Land_Attack_Chain1', 'M2_SouthBase_Land_Attack_Chain2', 'M2_SouthBase_Land_Attack_Chain3', 'M2_SouthBase_Land_Attack_Chain4', 'M2_SouthBase_Land_Attack_Chain5', 'M2_SouthBase_Land_Attack_Chain6'},
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    local Temp = {
        'T2TanksTemp2',
        'NoPlan',
        { 'uel0202', 1, 11, 'Attack', 'GrowthFormation' },   # T2 Tank
        { 'uel0307', 1, 4, 'Attack', 'GrowthFormation' },   # T2 Mobile Shield
    }
    local Builder = {
        BuilderName = 'T2TankAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 130,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'M2_South_Base',
        BuildConditions = {
            { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', 25, categories.LAND * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},       
        PlatoonData = {
            PatrolChains = {'M2_SouthBase_Land_Attack_Chain1', 'M2_SouthBase_Land_Attack_Chain2', 'M2_SouthBase_Land_Attack_Chain3', 'M2_SouthBase_Land_Attack_Chain4', 'M2_SouthBase_Land_Attack_Chain5', 'M2_SouthBase_Land_Attack_Chain6'},
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    # sends 6, 6 [light artillery, mobile missiles] if player has >= 6  Defences
    opai = UEFM2SouthBase:AddOpAI('BasicLandAttack', 'M2_SouthBaseLandAttack5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_SouthBase_Land_Attack_Chain1', 'M2_SouthBase_Land_Attack_Chain2', 'M2_SouthBase_Land_Attack_Chain3', 'M2_SouthBase_Land_Attack_Chain4', 'M2_SouthBase_Land_Attack_Chain5', 'M2_SouthBase_Land_Attack_Chain6'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'LightArtillery', 'MobileMissiles'}, 12)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', 6, categories.DEFENSE * categories.STRUCTURE})

    # sends 8, 8 [light artillery, mobile missiles] if player has >= 25 units
    opai = UEFM2SouthBase:AddOpAI('BasicLandAttack', 'M2_SouthBaseLandAttack6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_SouthBase_Land_Attack_Chain1', 'M2_SouthBase_Land_Attack_Chain2', 'M2_SouthBase_Land_Attack_Chain3', 'M2_SouthBase_Land_Attack_Chain4', 'M2_SouthBase_Land_Attack_Chain5', 'M2_SouthBase_Land_Attack_Chain6'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'LightArtillery', 'MobileMissiles'}, 16)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', 10, categories.DEFENSE * categories.STRUCTURE})

    local Temp = {
        'T2MissilesTemp1',
        'NoPlan',
        { 'uel0111', 1, 11, 'Attack', 'GrowthFormation' },   # T2 MML
        { 'uel0307', 1, 4, 'Attack', 'GrowthFormation' },   # T2 Mobile Shield
    }
    local Builder = {
        BuilderName = 'T2MissilesAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 120,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'M2_South_Base',
        BuildConditions = {
            { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', 12, categories.STRUCTURE * categories.TECH2}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},       
        PlatoonData = {
            PatrolChains = {'M2_SouthBase_Land_Attack_Chain1', 'M2_SouthBase_Land_Attack_Chain2', 'M2_SouthBase_Land_Attack_Chain3', 'M2_SouthBase_Land_Attack_Chain4', 'M2_SouthBase_Land_Attack_Chain5', 'M2_SouthBase_Land_Attack_Chain6'},
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    # sends 20 [heavy tanks, mobile shield] if player has >= 40 DF/IF
    opai = UEFM2SouthBase:AddOpAI('BasicLandAttack', 'M2_SouthBaseLandAttack7',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_SouthBase_Land_Attack_Chain1', 'M2_SouthBase_Land_Attack_Chain2', 'M2_SouthBase_Land_Attack_Chain3', 'M2_SouthBase_Land_Attack_Chain4', 'M2_SouthBase_Land_Attack_Chain5', 'M2_SouthBase_Land_Attack_Chain6'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity({'HeavyTanks', 'MobileShields'}, 20)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', 40, categories.MOBILE * categories.LAND})

    # sends 12 [mobile flak] if player has >= 40 mobile air units
    opai = UEFM2SouthBase:AddOpAI('BasicLandAttack', 'M2_SouthBaseLandAttack9',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_SouthBase_Land_Attack_Chain1', 'M2_SouthBase_Land_Attack_Chain2', 'M2_SouthBase_Land_Attack_Chain3', 'M2_SouthBase_Land_Attack_Chain4', 'M2_SouthBase_Land_Attack_Chain5', 'M2_SouthBase_Land_Attack_Chain6'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('MobileFlak', 12)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', 40, categories.AIR * categories.MOBILE})

    # sends 20 [heavy tanks] if player has >= 50 DF/IF
    opai = UEFM2SouthBase:AddOpAI('BasicLandAttack', 'M2_SouthBaseLandAttack10',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_SouthBase_Land_Attack_Chain1', 'M2_SouthBase_Land_Attack_Chain2', 'M2_SouthBase_Land_Attack_Chain3', 'M2_SouthBase_Land_Attack_Chain4', 'M2_SouthBase_Land_Attack_Chain5', 'M2_SouthBase_Land_Attack_Chain6'},
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('HeavyTanks', 12)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', 50, categories.DIRECTFIRE + categories.INDIRECTFIRE})

    # Land Defenses
    # maintains 2 groups of 8 heavy tanks
    for i = 1 ,2 do
        opai = UEFM2SouthBase:AddOpAI('BasicLandAttack', 'M2_SouthBaseLandDef1_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
                PlatoonData = {
                    PatrolChains = {'M2_SouthBase_Land_Def_Chain1', 'M2_SouthBase_Land_Def_Chain2'},
                },
                Priority = 110,
            }
        )
        opai:SetChildQuantity('HeavyTanks', 8)
    end

    opai = UEFM2SouthBase:AddOpAI('BasicLandAttack', 'M2_SouthBaseLandDef2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_SouthBase_Land_Def_Chain1', 'M2_SouthBase_Land_Def_Chain2'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'MobileFlak'}, 8)

    # sends 20 [light tanks] 
    opai = UEFM2T1Base:AddOpAI('BasicLandAttack', 'M2_SouthBaseT1LandAttack1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_SouthBase_Land_Attack_Chain1', 'M2_SouthBase_Land_Attack_Chain2', 'M2_SouthBase_Land_Attack_Chain3', 'M2_SouthBase_Land_Attack_Chain4', 'M2_SouthBase_Land_Attack_Chain5', 'M2_SouthBase_Land_Attack_Chain6'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('LightTanks', 20)

    local Temp = {
        'T1TanksTemp1',
        'NoPlan',
        { 'uel0201', 1, 10, 'Attack', 'GrowthFormation' },   # T1 Tank
        { 'uel0103', 1, 6, 'Attack', 'GrowthFormation' },   # T1 Arty
    }
    local Builder = {
        BuilderName = 'T1TankAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'M2_South_Base_T1Part',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},       
        PlatoonData = {
            PatrolChains = {'M2_SouthBase_Land_Attack_Chain1', 'M2_SouthBase_Land_Attack_Chain2', 'M2_SouthBase_Land_Attack_Chain3', 'M2_SouthBase_Land_Attack_Chain4', 'M2_SouthBase_Land_Attack_Chain5', 'M2_SouthBase_Land_Attack_Chain6'},
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    local Temp = {
        'T1TanksTemp2',
        'NoPlan',
        { 'uel0201', 1, 12, 'Attack', 'GrowthFormation' },   # T1 Tank
        { 'uel0103', 1, 10, 'Attack', 'GrowthFormation' },   # T1 Arty
    }
    local Builder = {
        BuilderName = 'T1TankAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'M2_South_Base_T1Part',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},       
        PlatoonData = {
            PatrolChains = {'M2_SouthBase_Land_Attack_Chain1', 'M2_SouthBase_Land_Attack_Chain2', 'M2_SouthBase_Land_Attack_Chain3', 'M2_SouthBase_Land_Attack_Chain4', 'M2_SouthBase_Land_Attack_Chain5', 'M2_SouthBase_Land_Attack_Chain6'},
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    # sends 12 [mobile aa] if player has >= 20 mobile air units
    opai = UEFM2T1Base:AddOpAI('BasicLandAttack', 'M2_SouthBaseT1LandAttack2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_SouthBase_Land_Attack_Chain1', 'M2_SouthBase_Land_Attack_Chain2', 'M2_SouthBase_Land_Attack_Chain3', 'M2_SouthBase_Land_Attack_Chain4', 'M2_SouthBase_Land_Attack_Chain5', 'M2_SouthBase_Land_Attack_Chain6'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('MobileAntiAir', 12)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', 15, categories.MOBILE * categories.AIR})

    # Land Defenses

    # maintains 2 groups of 6, 6 LightTanks and artillery
    for i = 3, 4 do
        opai = UEFM2T1Base:AddOpAI('BasicLandAttack', 'M2_SouthBaseT1LandDef1_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
                PlatoonData = {
                    PatrolChains = {'M2_SouthBase_Land_Def_Chain1', 'M2_SouthBase_Land_Def_Chain2'},
                },
                Priority = 110,
            }
        )
        opai:SetChildQuantity({'LightTanks', 'LightArtillery'}, 12)
    end

    for i = 1, 2 do
        opai = UEFM2T1Base:AddOpAI('BasicLandAttack', 'M2_SouthBaseT1LandDef2_' ..i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
                PlatoonData = {
                    PatrolChains = {'M2_SouthBase_Land_Def_Chain1', 'M2_SouthBase_Land_Def_Chain2'},
                },
                Priority = 110,
            }
        )
        opai:SetChildQuantity({'MobileAntiAir'}, 6)
    end

    # Builds Platoon of 1 Engineers 12 times
    local Temp = {
        'EngineerAttackTemp3',
        'NoPlan',
        { 'uel0105', 1, 1, 'Attack', 'GrowthFormation' },   # T1 Engies
    }
    local Builder = {
        BuilderName = 'EngineerAttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 16,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'M2_Engi_Base',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},       
        PlatoonData = {
            PatrolChains = {'M2_SouthBase_Land_Attack_Chain1', 'M2_SouthBase_Land_Attack_Chain2', 'M2_SouthBase_Land_Attack_Chain3', 'M2_SouthBase_Land_Attack_Chain4', 'M2_SouthBase_Land_Attack_Chain5', 'M2_SouthBase_Land_Attack_Chain6'},
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    #------
    # Drops
    #------

    # Transport Builder
    local opai = UEFM2T1Base:AddOpAI('EngineerAttack', 'M2_UEF_TransportBuilder',
    {
        MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
        PlatoonData = {
            AttackChain = 'M2_UEF_Transport_Attack_Chain',
            LandingChain = 'M2_UEF_Landing_Chain',
            MovePath = 'M2_UEF_Transport_Route_Chain',
            TransportReturn = 'M2_Transport_Return_Marker',
        },
        Priority = 1000,
    })
    opai:SetChildActive('All', false)
    opai:SetChildActive('T1Transports', true)
    opai:SetChildQuantity({'T1Transports'}, 2)
    opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
        'HaveLessThanUnitsWithCategory', {'default_brain', 4, categories.uea0107})   # T1 Transport

    opai = UEFM2T1Base:AddOpAI('BasicLandAttack', 'M3_UEFTransportAttack1',
    {
        MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
        PlatoonData = {
            AttackChain = 'M2_UEF_Transport_Attack_Chain',
            LandingChain = 'M2_UEF_Landing_Chain',
            MovePath = 'M2_UEF_Transport_Route_Chain1',
            TransportReturn = 'M2_Transport_Return_Marker',
        },
        Priority = 110,
    })
    opai:SetChildQuantity('LightArtillery', 12)
    opai:SetLockingStyle('BuildTimer', {LockTimer = 240})

    opai = UEFM2T1Base:AddOpAI('BasicLandAttack', 'M3_UEFTransportAttack2',
    {
        MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
        PlatoonData = {
            AttackChain = 'M2_UEF_Transport_Attack_Chain',
            LandingChain = 'M2_UEF_Landing_Chain',
            MovePath = 'M2_UEF_Transport_Route_Chain2',
            TransportReturn = 'M2_Transport_Return_Marker',
        },
        Priority = 110,
    })
    opai:SetChildQuantity('LightArtillery', 12)
    opai:SetLockingStyle('BuildTimer', {LockTimer = 240})

end