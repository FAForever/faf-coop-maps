local BaseManager = import('/lua/ai/opai/basemanager.lua')
local CustomFunctions = '/maps/Prothyon16/Prothyon16_CustomFunctions.lua'
local SPAIFileName = '/lua/scenarioplatoonai.lua'

---------
-- Locals
---------
local UEF = 2
local Difficulty = ScenarioInfo.Options.Difficulty

----------------
-- Base Managers
----------------
local UEFM2SouthBase = BaseManager.CreateBaseManager()
local UEFM2T1Base = BaseManager.CreateBaseManager()

--------------------
-- UEF M2 South Base
--------------------
function UEFM2SouthBaseAI()
    UEFM2SouthBase:InitializeDifficultyTables(ArmyBrains[UEF], 'M2_South_Base', 'M2_South_Base_Marker', 38, {M2_South_Base = 100})
    UEFM2SouthBase:StartNonZeroBase({{8, 10, 12}, {6, 8, 9}})
    UEFM2SouthBase:SetActive('AirScouting', true)

    UEFM2SouthBaseAirAttacks()
    UEFM2SouthBaseLandAttacks()
end

function UEFM2SouthBaseAirAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    for i = 1, 3 do
        quantity = {2, 3, 4}
        opai = UEFM2SouthBase:AddOpAI('AirAttacks', 'M2SouthBaseAirAttack1_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
                PlatoonData = {
                    PatrolChains = {'M2_SouthBase_Land_Attack_Chain1',
                                    'M2_SouthBase_Land_Attack_Chain2',
                                    'M2_SouthBase_Land_Attack_Chain3',
                                    'M2_SouthBase_Land_Attack_Chain4',
                                    'M2_SouthBase_Land_Attack_Chain5',
                                    'M2_SouthBase_Land_Attack_Chain6',
                                    'M2_SouthBase_AirAttack_Chain1',
                                    'M2_SouthBase_AirAttack_Chain2',
                                    'M2_SouthBase_AirAttack_Chain3'},
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('Gunships', quantity[Difficulty])
    end

    for i = 1, 3 do
        opai = UEFM2SouthBase:AddOpAI('AirAttacks', 'M2SouthBaseAirAttack2_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
                PlatoonData = {
                    PatrolChains = {'M2_SouthBase_Land_Attack_Chain1',
                                    'M2_SouthBase_Land_Attack_Chain2',
                                    'M2_SouthBase_Land_Attack_Chain3',
                                    'M2_SouthBase_Land_Attack_Chain4',
                                    'M2_SouthBase_Land_Attack_Chain5',
                                    'M2_SouthBase_Land_Attack_Chain6'},
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('CombatFighters', 3)
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
            {'default_brain', 'Player', 10, categories.STRUCTURE * categories.ANTIAIR})
    end

    -- Defenses
    for i = 1, 3 do
        quantity = {2, 3, 4}
        opai = UEFM2SouthBase:AddOpAI('AirAttacks', 'M2SouthT2BaseAirDef1_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M2_SouthBase_Air_Def_Chain',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('CombatFighters', quantity[Difficulty])
    end

    for i = 1, 3 do
        quantity = {2, 3, 4}
        opai = UEFM2SouthBase:AddOpAI('AirAttacks', 'M2SouthT2BaseAirDef2_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M2_SouthBase_Air_Def_Chain',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('Gunships', quantity[Difficulty])
    end
end

function UEFM2SouthBaseLandAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    -- sends 8 [heavy tanks]
    quantity = {4, 6, 8}
    opai = UEFM2SouthBase:AddOpAI('BasicLandAttack', 'M2_SouthBaseLandAttack2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_SouthBase_Land_Attack_Chain1',
                                'M2_SouthBase_Land_Attack_Chain2',
                                'M2_SouthBase_Land_Attack_Chain3',
                                'M2_SouthBase_Land_Attack_Chain4',
                                'M2_SouthBase_Land_Attack_Chain5',
                                'M2_SouthBase_Land_Attack_Chain6'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('HeavyTanks', quantity[Difficulty])

    quantity = {6, 8, 10}
    local Temp = {
        'T2TanksTemp1',
        'NoPlan',
        { 'uel0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   -- T2 Tank
        { 'uel0307', 1, 2, 'Attack', 'GrowthFormation' },   -- T2 Mobile Shield
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
            PatrolChains = {'M2_SouthBase_Land_Attack_Chain1',
                            'M2_SouthBase_Land_Attack_Chain2',
                            'M2_SouthBase_Land_Attack_Chain3',
                            'M2_SouthBase_Land_Attack_Chain4',
                            'M2_SouthBase_Land_Attack_Chain5',
                            'M2_SouthBase_Land_Attack_Chain6'},
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    quantity = {7, 9, 11}
    trigger = {35, 30, 25}
    local Temp = {
        'T2TanksTemp2',
        'NoPlan',
        { 'uel0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   -- T2 Tank
        { 'uel0307', 1, 4, 'Attack', 'GrowthFormation' },   -- T2 Mobile Shield
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
        {'default_brain', 'Player', trigger[Difficulty], categories.LAND * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},       
        PlatoonData = {
            PatrolChains = {'M2_SouthBase_Land_Attack_Chain1',
                            'M2_SouthBase_Land_Attack_Chain2',
                            'M2_SouthBase_Land_Attack_Chain3',
                            'M2_SouthBase_Land_Attack_Chain4',
                            'M2_SouthBase_Land_Attack_Chain5',
                            'M2_SouthBase_Land_Attack_Chain6'},
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    -- sends 6, 6 [light artillery, mobile missiles] if player has >= 6  Defences
    quantity = {8, 10, 12}
    trigger = {20, 14, 8}
    opai = UEFM2SouthBase:AddOpAI('BasicLandAttack', 'M2_SouthBaseLandAttack5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_SouthBase_Land_Attack_Chain1',
                                'M2_SouthBase_Land_Attack_Chain2',
                                'M2_SouthBase_Land_Attack_Chain3',
                                'M2_SouthBase_Land_Attack_Chain4',
                                'M2_SouthBase_Land_Attack_Chain5',
                                'M2_SouthBase_Land_Attack_Chain6'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'LightArtillery', 'MobileMissiles'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.DEFENSE * categories.STRUCTURE})

    -- sends 8, 8 [light artillery, mobile missiles] if player has >= 25 units
    quantity = {8, 12, 16}
    trigger = {28, 21, 14}
    opai = UEFM2SouthBase:AddOpAI('BasicLandAttack', 'M2_SouthBaseLandAttack6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_SouthBase_Land_Attack_Chain1',
                                'M2_SouthBase_Land_Attack_Chain2',
                                'M2_SouthBase_Land_Attack_Chain3',
                                'M2_SouthBase_Land_Attack_Chain4',
                                'M2_SouthBase_Land_Attack_Chain5',
                                'M2_SouthBase_Land_Attack_Chain6'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'LightArtillery', 'MobileMissiles'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.DEFENSE * categories.STRUCTURE})

    if (Difficulty == 3) then
        local Temp = {
            'T2MissilesTemp1',
            'NoPlan',
            { 'uel0111', 1, 11, 'Attack', 'GrowthFormation' },   -- T2 MML
            { 'uel0307', 1, 4, 'Attack', 'GrowthFormation' },   -- T2 Mobile Shield
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
            {'default_brain', 'Player', 20, categories.STRUCTURE * categories.TECH2}},
            },
            PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},       
            PlatoonData = {
                PatrolChains = {'M2_SouthBase_Land_Attack_Chain1',
                                'M2_SouthBase_Land_Attack_Chain2',
                                'M2_SouthBase_Land_Attack_Chain3',
                                'M2_SouthBase_Land_Attack_Chain4',
                                'M2_SouthBase_Land_Attack_Chain5',
                                'M2_SouthBase_Land_Attack_Chain6'},
            },
        }
        ArmyBrains[UEF]:PBMAddPlatoon( Builder )
    end

    -- sends 20 [heavy tanks, mobile shield] if player has >= 40 DF/IF
    quantity = {12, 16, 20}
    trigger ={55, 47, 40}
    opai = UEFM2SouthBase:AddOpAI('BasicLandAttack', 'M2_SouthBaseLandAttack7',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_SouthBase_Land_Attack_Chain1',
                                'M2_SouthBase_Land_Attack_Chain2',
                                'M2_SouthBase_Land_Attack_Chain3',
                                'M2_SouthBase_Land_Attack_Chain4',
                                'M2_SouthBase_Land_Attack_Chain5',
                                'M2_SouthBase_Land_Attack_Chain6'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity({'HeavyTanks', 'MobileShields'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.MOBILE * categories.LAND})

    -- sends 12 [mobile flak] if player has >= 40 mobile air units
    quantity = {8, 10, 12}
    trigger = {55, 47, 50}
    opai = UEFM2SouthBase:AddOpAI('BasicLandAttack', 'M2_SouthBaseLandAttack9',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_SouthBase_Land_Attack_Chain1',
                                'M2_SouthBase_Land_Attack_Chain2',
                                'M2_SouthBase_Land_Attack_Chain3',
                                'M2_SouthBase_Land_Attack_Chain4',
                                'M2_SouthBase_Land_Attack_Chain5',
                                'M2_SouthBase_Land_Attack_Chain6'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('MobileFlak', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.AIR * categories.MOBILE})

    -- sends 20 [heavy tanks] if player has >= 50 DF/IF
    quantity = {8, 10, 12}
    trigger = {64, 58, 50}
    opai = UEFM2SouthBase:AddOpAI('BasicLandAttack', 'M2_SouthBaseLandAttack10',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_SouthBase_Land_Attack_Chain1',
                                'M2_SouthBase_Land_Attack_Chain2',
                                'M2_SouthBase_Land_Attack_Chain3',
                                'M2_SouthBase_Land_Attack_Chain4',
                                'M2_SouthBase_Land_Attack_Chain5',
                                'M2_SouthBase_Land_Attack_Chain6'},
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('HeavyTanks', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.LAND + categories.MOBILE})

    -- Land Defenses
    -- maintains 2 groups of 8 heavy tanks
    for i = 1 ,2 do
        quantity = {6, 6, 8}
        opai = UEFM2SouthBase:AddOpAI('BasicLandAttack', 'M2_SouthBaseLandDef1_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
                PlatoonData = {
                    PatrolChains = {'M2_SouthBase_Land_Def_Chain1', 'M2_SouthBase_Land_Def_Chain2'},
                },
                Priority = 110,
            }
        )
        opai:SetChildQuantity('HeavyTanks', quantity[Difficulty])
    end

    quantity = {4, 6, 8}
    opai = UEFM2SouthBase:AddOpAI('BasicLandAttack', 'M2_SouthBaseLandDef2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_SouthBase_Land_Def_Chain1', 'M2_SouthBase_Land_Def_Chain2'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'MobileFlak'}, quantity[Difficulty])
end

----------
-- T1 Base
----------
function UEFM2T1BaseAI()
    UEFM2T1Base:InitializeDifficultyTables(ArmyBrains[UEF], 'M2_T1_Base', 'M2_T1_Base_Marker', 27, {M2_T1_Base = 100})
    UEFM2T1Base:StartNonZeroBase({{4, 6, 8}, {3, 5, 6}})
    UEFM2T1Base:SetActive('AirScouting', true)

    UEFM2T1BaseAirAttacks()
    UEFM2T1BaseLandAttacks()
end

function UEFM2T1BaseAirAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    for i = 1, 4 do
        quantity = {4, 4, 6}
        opai = UEFM2T1Base:AddOpAI('AirAttacks', 'M2_T1BaseAirAttack1_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
                PlatoonData = {
                    PatrolChains = {'M2_SouthBase_Land_Attack_Chain1',
                                    'M2_SouthBase_Land_Attack_Chain2',
                                    'M2_SouthBase_Land_Attack_Chain3',
                                    'M2_SouthBase_Land_Attack_Chain4',
                                    'M2_SouthBase_Land_Attack_Chain5',
                                    'M2_SouthBase_Land_Attack_Chain6',
                                    'M2_SouthBase_AirAttack_Chain1',
                                    'M2_SouthBase_AirAttack_Chain2',
                                    'M2_SouthBase_AirAttack_Chain3'},
                },
                Priority = 110,
            }
        )
        opai:SetChildQuantity('Bombers', quantity[Difficulty])
    end

    for i = 1, 2 do
        quantity = {4, 4, 6}
        trigger = {16, 13, 10}
        opai = UEFM2T1Base:AddOpAI('AirAttacks', 'M2_T1BaseAirAttack2_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
                PlatoonData = {
                    PatrolChains = {'M2_SouthBase_Land_Attack_Chain1',
                                    'M2_SouthBase_Land_Attack_Chain2',
                                    'M2_SouthBase_Land_Attack_Chain3',
                                    'M2_SouthBase_Land_Attack_Chain4',
                                    'M2_SouthBase_Land_Attack_Chain5',
                                    'M2_SouthBase_Land_Attack_Chain6',
                                    'M2_SouthBase_AirAttack_Chain1',
                                    'M2_SouthBase_AirAttack_Chain2',
                                    'M2_SouthBase_AirAttack_Chain3'},
                },
                Priority = 110,
            }
        )
        opai:SetChildQuantity('Interceptors', quantity[Difficulty])
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
            {'default_brain', 'Player', trigger[Difficulty], categories.AIR + categories.MOBILE})
    end

    -- Defenses
    for i = 1, 2 do
        quantity = {2, 3, 4}
        opai = UEFM2T1Base:AddOpAI('AirAttacks', 'M2SouthT1BaseAirDef1_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M2_SouthBase_Air_Def_Chain',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('Bombers', quantity[Difficulty])
    end

    for i = 1, 2 do
        quantity = {2, 3, 4}
        opai = UEFM2T1Base:AddOpAI('AirAttacks', 'M2SouthT1BaseAirDef2_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M2_SouthBase_Air_Def_Chain',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('Interceptors', quantity[Difficulty])
    end
end

function UEFM2T1BaseLandAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    -- sends 20 [light tanks] 
    quantity = {12, 16, 20}
    opai = UEFM2T1Base:AddOpAI('BasicLandAttack', 'M2_SouthBaseT1LandAttack1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_SouthBase_Land_Attack_Chain1',
                                'M2_SouthBase_Land_Attack_Chain2',
                                'M2_SouthBase_Land_Attack_Chain3',
                                'M2_SouthBase_Land_Attack_Chain4',
                                'M2_SouthBase_Land_Attack_Chain5',
                                'M2_SouthBase_Land_Attack_Chain6'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('LightTanks', quantity[Difficulty])

    local Temp = {
        'T1TanksTemp1',
        'NoPlan',
        { 'uel0201', 1, 10, 'Attack', 'GrowthFormation' },   -- T1 Tank
        { 'uel0103', 1, 6, 'Attack', 'GrowthFormation' },   -- T1 Arty
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
            PatrolChains = {'M2_SouthBase_Land_Attack_Chain1',
                            'M2_SouthBase_Land_Attack_Chain2',
                            'M2_SouthBase_Land_Attack_Chain3',
                            'M2_SouthBase_Land_Attack_Chain4',
                            'M2_SouthBase_Land_Attack_Chain5',
                            'M2_SouthBase_Land_Attack_Chain6'},
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    if (Difficulty == 3) then
        local Temp = {
            'T1TanksTemp2',
            'NoPlan',
            { 'uel0201', 1, 12, 'Attack', 'GrowthFormation' },   -- T1 Tank
            { 'uel0103', 1, 10, 'Attack', 'GrowthFormation' },   -- T1 Arty
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
                PatrolChains = {'M2_SouthBase_Land_Attack_Chain1',
                                'M2_SouthBase_Land_Attack_Chain2',
                                'M2_SouthBase_Land_Attack_Chain3',
                                'M2_SouthBase_Land_Attack_Chain4',
                                'M2_SouthBase_Land_Attack_Chain5',
                                'M2_SouthBase_Land_Attack_Chain6'},
            },
        }
        ArmyBrains[UEF]:PBMAddPlatoon( Builder )
    end
    -- sends 12 [mobile aa] if player has >= 20 mobile air units
    quantity = {8, 10, 12}
    trigger = {25, 20, 15}
    opai = UEFM2T1Base:AddOpAI('BasicLandAttack', 'M2_SouthBaseT1LandAttack2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_SouthBase_Land_Attack_Chain1',
                                'M2_SouthBase_Land_Attack_Chain2',
                                'M2_SouthBase_Land_Attack_Chain3',
                                'M2_SouthBase_Land_Attack_Chain4',
                                'M2_SouthBase_Land_Attack_Chain5',
                                'M2_SouthBase_Land_Attack_Chain6'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('MobileAntiAir', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.MOBILE * categories.AIR})

    -- Land Defenses
    -- maintains 2 groups of 6, 6 LightTanks and artillery
    for i = 3, 4 do
        quantity = {8, 10, 12}
        opai = UEFM2T1Base:AddOpAI('BasicLandAttack', 'M2_SouthBaseT1LandDef1_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
                PlatoonData = {
                    PatrolChains = {'M2_SouthBase_Land_Def_Chain1', 'M2_SouthBase_Land_Def_Chain2'},
                },
                Priority = 110,
            }
        )
        opai:SetChildQuantity({'LightTanks', 'LightArtillery'}, quantity[Difficulty])
    end

    for i = 1, 2 do
        quantity = {4, 4, 6}
        opai = UEFM2T1Base:AddOpAI('BasicLandAttack', 'M2_SouthBaseT1LandDef2_' ..i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
                PlatoonData = {
                    PatrolChains = {'M2_SouthBase_Land_Def_Chain1', 'M2_SouthBase_Land_Def_Chain2'},
                },
                Priority = 110,
            }
        )
        opai:SetChildQuantity({'MobileAntiAir'}, quantity[Difficulty])
    end

    opai = UEFM2T1Base:AddOpAI('EngineerAttack', 'M2_South_Reclaim_Engineers',
    {
        MasterPlatoonFunction = {SPAIFileName, 'SplitPatrolThread'},
        PlatoonData = {
            PatrolChains = {'M2_SouthBase_Land_Attack_Chain1',
                            'M2_SouthBase_Land_Attack_Chain2',
                            'M2_SouthBase_Land_Attack_Chain3',
                            'M2_SouthBase_Land_Attack_Chain4',
                            'M2_SouthBase_Land_Attack_Chain5',
                            'M2_SouthBase_Land_Attack_Chain6'},
        },
        Priority = 200,
    })
    opai:SetChildQuantity('T1Engineers', 12)
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})

    --------
    -- Drops
    --------
    -- Transport Builder
    opai = UEFM2T1Base:AddOpAI('EngineerAttack', 'M2_UEF_TransportBuilder',
    {
        MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
        PlatoonData = {
            TransportReturn = 'M2_Transport_Return_Marker',
        },
        Priority = 1000,
    })
    opai:SetChildQuantity('T1Transports', 2)
    opai:SetLockingStyle('None')
    opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
        'HaveLessThanUnitsWithCategory', {'default_brain', 4, categories.uea0107})   -- T1 Transport

    opai = UEFM2T1Base:AddOpAI('BasicLandAttack', 'M2_UEFTransportAttack1',
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

    if (Difficulty == 3) then
        opai = UEFM2T1Base:AddOpAI('BasicLandAttack', 'M2_UEFTransportAttack2',
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
end