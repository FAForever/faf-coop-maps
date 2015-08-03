local BaseManager = import('/lua/ai/opai/basemanager.lua')
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')

local SPAIFileName = '/lua/scenarioplatoonai.lua'

ScenarioInfo.Player = 1

# ------
# Locals
# ------
local UEF = 2
local Player = ScenarioInfo.Player

# -------------
# Base Managers
# -------------
local UEFM3AirBase = BaseManager.CreateBaseManager()
local UEFM3LandBase = BaseManager.CreateBaseManager()
local UEFM3EngiBase = BaseManager.CreateBaseManager()
local UEFM3SouthNavalBase = BaseManager.CreateBaseManager()
local UEFM3WestNavalBase = BaseManager.CreateBaseManager()

function UEFM3AirBaseAI()

    # ---------------
    # UEF M3 Air Base
    # ---------------
    UEFM3AirBase:Initialize(ArmyBrains[UEF], 'M3_Air_Base', 'M3_Air_Base_Marker', 40, {M3_Air_Base = 100})
    UEFM3AirBase:StartNonZeroBase({20, 16})
    UEFM3AirBase:SetActive('AirScouting', true)
    UEFM3AirBase:SetActive('LandScouting', false)
    UEFM3AirBase:SetBuild('Defenses', true)

    local opai = UEFM3AirBase:AddReactiveAI('MassedAir', 'AirRetaliation', 'UEFM3AirBase_MassedAir')
    opai:SetChildActive('AirSuperiority', false)
    opai:SetChildActive('CombatFighters', false)

    UEFM3AirBase:AddBuildGroup('M3_Air_Base_Rest', 100, true)

    UEFM3AirBaseAirAttacks()

    --ScenarioFramework.CreateTimerTrigger(UEFM3EngiBaseAI, 10)

    --ScenarioFramework.CreateArmyStatTrigger(UEFM3SouthNavalAI, ArmyBrains[Player], 'M3NavalFactoryBuilt',
        --{{StatType = 'Units_Active', CompareType = 'GreaterThanOrEqual', Value = 1, Category = categories.FACTORY * categories.NAVAL}})
    --ScenarioFramework.CreateArmyStatTrigger(UEFM3WestNavalAI, ArmyBrains[Player], 'M3NavalFactoryBuilt2',
        --{{StatType = 'Units_Active', CompareType = 'GreaterThanOrEqual', Value = 1, Category = categories.FACTORY * categories.NAVAL}})
end

function UEFM3LandBaseAI()
    # ----------------
    # UEF M3 Land Base
    # ----------------
    UEFM3LandBase:Initialize(ArmyBrains[UEF], 'M3_Land_Base', 'M3_Land_Base_Marker', 40, {LandBase = 100})
    UEFM3LandBase:StartNonZeroBase({10, 8})
    UEFM3LandBase:SetBuild('Defenses', true)

    UEFM3LandBase:AddBuildGroup('M3_Air_Base', 95)

    UEFM3LandBaseLandAttacks()

end

function UEFM3EngiBaseAI()
    UEFM3AirBase:AddBuildGroup('EngiBase', 95)

    UEFM3EngiBase:Initialize(ArmyBrains[UEF], 'EngiBase', 'M3_EngiBase_Marker', 30, {EngiBase = 100})
    UEFM3EngiBase:StartNonZeroBase()
    UEFM3EngiBase:SetActive('LandScouting', false)

    UEFM3EngiBaseLandAttacks()
end

function UEFM3SouthNavalBaseAI()  
    UEFM3AirBase:AddBuildGroup('SouthNavalBase', 80)
    
    UEFM3SouthNavalBase:Initialize(ArmyBrains[UEF], 'SouthNavalBase', 'M3_South_NavalBase_Marker', 40, {SouthNavalBase = 100,})
    UEFM3SouthNavalBase:StartNonZeroBase({10, 8})
    UEFM3SouthNavalBase:SetBuild('Defenses', true)
    
    UEFM3SouthNavalAttacks()
end

function UEFM3WestNavalBaseAI()  
    UEFM3AirBase:AddBuildGroup('WestNavalBase', 90)
    
    UEFM3WestNavalBase:Initialize(ArmyBrains[UEF], 'WestNavalBase', 'M3_West_NavalBase_Marker', 40, {WestNavalBase = 100,})
    UEFM3WestNavalBase:StartNonZeroBase({6, 4})
    UEFM3WestNavalBase:SetBuild('Defenses', true)
    
    UEFM3WestNavalAttacks()
end

function UEFM3AirBaseAirAttacks()
    local opai = nil

    # ----------------------------------
    # UEF M3 Air Base Op AI, Air Attacks
    # ----------------------------------

    # Builds platoon of 8 Bombers
    opai = UEFM3AirBase:AddOpAI('AirAttacks', 'M3_AirAttack4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Air_Attack_Chain1', 'M3_Air_Attack_Chain2', 'M3_Air_Attack_Chain3', 'M3_Air_Attack_Chain4', 'M3_Air_Attack_Chain5', 'M3_Air_Attack_Chain6', 'M3_Air_Attack_Chain7'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Bombers', 8)

    # Builds platoon of 8 Gunships
    opai = UEFM3AirBase:AddOpAI('AirAttacks', 'M3_AirAttack19',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Air_Attack_Chain1', 'M3_Air_Attack_Chain2', 'M3_Air_Attack_Chain3', 'M3_Air_Attack_Chain4', 'M3_Air_Attack_Chain5', 'M3_Air_Attack_Chain6', 'M3_Air_Attack_Chain7'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Gunships', 8)

    # sends 10 [bombers] if player has >= 5 AA
    opai = UEFM3AirBase:AddOpAI('AirAttacks', 'M3_AirAttack18',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Air_Attack_Chain1', 'M3_Air_Attack_Chain2', 'M3_Air_Attack_Chain3', 'M3_Air_Attack_Chain4', 'M3_Air_Attack_Chain5', 'M3_Air_Attack_Chain6', 'M3_Air_Attack_Chain7'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Bombers', 10)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', 5, categories.ANTIAIR})

    # sends 12 [bombers] if player has >= 20 land units
    opai = UEFM3AirBase:AddOpAI('AirAttacks', 'M3_AirAttack20',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Air_Attack_Chain1', 'M3_Air_Attack_Chain2', 'M3_Air_Attack_Chain3', 'M3_Air_Attack_Chain4', 'M3_Air_Attack_Chain5', 'M3_Air_Attack_Chain6', 'M3_Air_Attack_Chain7'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Bombers', 10)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', 20, categories.LAND * categories.MOBILE})

    # sends 10 interceptors
    opai = UEFM3AirBase:AddOpAI('AirAttacks', 'M3_AirAttack16',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Air_Attack_Chain1', 'M3_Air_Attack_Chain2', 'M3_Air_Attack_Chain3', 'M3_Air_Attack_Chain4', 'M3_Air_Attack_Chain5', 'M3_Air_Attack_Chain6', 'M3_Air_Attack_Chain7'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Interceptors', 10)

    # sends 10 [bombers interceptors] if player has >= 5 AA + Janus
    opai = UEFM3AirBase:AddOpAI('AirAttacks', 'M3_AirAttack15',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Air_Attack_Chain1', 'M3_Air_Attack_Chain2', 'M3_Air_Attack_Chain3', 'M3_Air_Attack_Chain4', 'M3_Air_Attack_Chain5', 'M3_Air_Attack_Chain6', 'M3_Air_Attack_Chain7'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'Bombers', 'Interceptors'}, 20)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', 5, categories.ANTIAIR + categories.dea0202})

    # sends 8 [gunships, interceptors] if player has >= 8 AA + Janus
    opai = UEFM3AirBase:AddOpAI('AirAttacks', 'M3_AirAttack6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Air_Attack_Chain1', 'M3_Air_Attack_Chain2', 'M3_Air_Attack_Chain3', 'M3_Air_Attack_Chain4', 'M3_Air_Attack_Chain5', 'M3_Air_Attack_Chain6', 'M3_Air_Attack_Chain7'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'Gunships', 'Interceptors'}, 16)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', 8, categories.ANTIAIR + categories.dea0202})

    # sends 12 [gunships, interceptors] if player has >= 8 AA
    opai = UEFM3AirBase:AddOpAI('AirAttacks', 'M3_AirAttack17',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Air_Attack_Chain1', 'M3_Air_Attack_Chain2', 'M3_Air_Attack_Chain3', 'M3_Air_Attack_Chain4', 'M3_Air_Attack_Chain5', 'M3_Air_Attack_Chain6', 'M3_Air_Attack_Chain7'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'Gunships', 'Interceptors'}, 24)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', 25, categories.ALLUNITS - categories.WALL})

    # sends 20 [interceptors] if player has >= 10 mobile air
    opai = UEFM3AirBase:AddOpAI('AirAttacks', 'M3_AirAttack7',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Air_Attack_Chain1', 'M3_Air_Attack_Chain2', 'M3_Air_Attack_Chain3', 'M3_Air_Attack_Chain4', 'M3_Air_Attack_Chain5', 'M3_Air_Attack_Chain6', 'M3_Air_Attack_Chain7'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Interceptors', 20)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', 10, categories.MOBILE * categories.AIR})

    # sends 12 [gunships] if player has >= 10 T2/T3 structures
    opai = UEFM3AirBase:AddOpAI('AirAttacks', 'M3_AirAttack8',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Air_Attack_Chain1', 'M3_Air_Attack_Chain2', 'M3_Air_Attack_Chain3', 'M3_Air_Attack_Chain4', 'M3_Air_Attack_Chain5', 'M3_Air_Attack_Chain6', 'M3_Air_Attack_Chain7'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Gunships', 12)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', 10, categories.TECH2 * categories.MOBILE})

    # sends 20 [gunships] if player has >= 75, 60, 40 mobile land units
    opai = UEFM3AirBase:AddOpAI('AirAttacks', 'M3_AirAttack9',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Air_Attack_Chain1', 'M3_Air_Attack_Chain2', 'M3_Air_Attack_Chain3', 'M3_Air_Attack_Chain4', 'M3_Air_Attack_Chain5', 'M3_Air_Attack_Chain6', 'M3_Air_Attack_Chain7'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Gunships', 20)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', 40, (categories.MOBILE * categories.LAND) - categories.CONSTRUCTION})

    # sends 25 [interceptors] if player has >= 50 mobile air units
    opai = UEFM3AirBase:AddOpAI('AirAttacks', 'M3_AirAttack10',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Air_Attack_Chain1', 'M3_Air_Attack_Chain2', 'M3_Air_Attack_Chain3', 'M3_Air_Attack_Chain4', 'M3_Air_Attack_Chain5', 'M3_Air_Attack_Chain6', 'M3_Air_Attack_Chain7'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Interceptors', 25)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', 50, categories.MOBILE * categories.AIR})

    # sends 10 [interceptors, gunships] if player has >= 20 gunships
    opai = UEFM3AirBase:AddOpAI('AirAttacks', 'M3_AirAttack11',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Air_Attack_Chain1', 'M3_Air_Attack_Chain2', 'M3_Air_Attack_Chain3', 'M3_Air_Attack_Chain4', 'M3_Air_Attack_Chain5', 'M3_Air_Attack_Chain6', 'M3_Air_Attack_Chain7'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'Interceptors', 'CombatFighters'}, 20)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', 20, categories.uea0203})

    # sends 30 [interceptors,] if player has >= 25 air units
    opai = UEFM3AirBase:AddOpAI('AirAttacks', 'M3_AirAttack12',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Air_Attack_Chain1', 'M3_Air_Attack_Chain2', 'M3_Air_Attack_Chain3', 'M3_Air_Attack_Chain4', 'M3_Air_Attack_Chain5', 'M3_Air_Attack_Chain6', 'M3_Air_Attack_Chain7'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Interceptors', 30)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', 25, categories.AIR + categories.MOBILE})

    # sends 10 [gunships] if player has >= 10 T2 units
    opai = UEFM3AirBase:AddOpAI('AirAttacks', 'M3_AirAttack13',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Air_Attack_Chain1', 'M3_Air_Attack_Chain2', 'M3_Air_Attack_Chain3', 'M3_Air_Attack_Chain4', 'M3_Air_Attack_Chain5', 'M3_Air_Attack_Chain6', 'M3_Air_Attack_Chain7'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Gunships', 10)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', 10, categories.TECH2})

    local Temp = {
        'ComabtFighetTemp2',
        'NoPlan',
        { 'dea0202', 1, 10, 'Attack', 'GrowthFormation' },   # T2 CombatFighter
    }
    local Builder = {
        BuilderName = 'CombatFighterAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 110,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'M3_Air_Base',
        BuildConditions = {
            { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', 20, categories.TECH2}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},       
        PlatoonData = {
            PatrolChains = {'M3_Air_Attack_Chain1', 'M3_Air_Attack_Chain2', 'M3_Air_Attack_Chain3', 'M3_Air_Attack_Chain4', 'M3_Air_Attack_Chain5', 'M3_Air_Attack_Chain6', 'M3_Air_Attack_Chain7'},
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    # Air Defense
    # Maintains 40 Interceptors
    for i = 1, 4 do
        opai = UEFM3AirBase:AddOpAI('AirAttacks', 'M3_AirDefense1_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M3_Air_Base_Defense_Chain',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity({'Interceptors'}, 10)
    end

    # Maintains 20 Gunships
    for i = 1, 4 do
        opai = UEFM3AirBase:AddOpAI('AirAttacks', 'M3_AirDefense2_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M3_Air_Base_Defense_Chain',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity({'Gunships'}, 5)
    end

end

function UEFM3LandBaseLandAttacks()
    local opai = nil

    # sends 20 [hover tanks] if player has >=  50 units
    opai = UEFM3LandBase:AddOpAI('BasicLandAttack', 'M3_HoverAttack1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Air_Hover_Chain1', 'M3_Air_Hover_Chain2'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('AmphibiousTanks', 20)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', 50, categories.ALLUNITS - categories.WALL})
    opai:SetLockingStyle('None')

    # sends 10 [hover tanks] if player has >=  25 units
    opai = UEFM3LandBase:AddOpAI('BasicLandAttack', 'M3_HoverAttack2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Air_Hover_Chain1', 'M3_Air_Hover_Chain2'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('AmphibiousTanks', 10)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', 25, categories.ALLUNITS - categories.WALL})
    opai:SetLockingStyle('None')

    #------
    # Drops
    #------
    # Transport Builder
    opai = UEFM3LandBase:AddOpAI('EngineerAttack', 'M3_UEF_TransportBuilder',
    {
        MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
        PlatoonData = {
            LandingChain = 'M3_Init_Landing_Chain',
            TransportReturn = 'M3_Land_Base_Marker',
        },
        Priority = 1000,
    })
    opai:SetChildActive('All', false)
    opai:SetChildActive('T2Transports', true)
    opai:SetChildQuantity({'T2Transports'}, 2)
    opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
        'HaveLessThanUnitsWithCategory', {'default_brain', 5, categories.uea0104})

    for i = 1, 3 do
        opai = UEFM3LandBase:AddOpAI('BasicLandAttack', 'M3_UEFTransportAttack1_' .. i,
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain = 'M3_Init_TransAttack_Chain1',
                LandingChain = 'M3_Init_Landing_Chain',
                TransportReturn = 'M3_Land_Base_Marker',
            },
            Priority = 110,
        })
        opai:SetChildQuantity({'HeavyTanks'}, 6)
        opai:SetLockingStyle('BuildTimer', {LockTimer = 300})
    end

    for i = 1, 2 do
        opai = UEFM3LandBase:AddOpAI('BasicLandAttack', 'M3_UEFTransportAttack2_' .. i,
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain = 'M3_Init_TransAttack_Chain1',
                LandingChain = 'M3_Init_Landing_Chain',
                TransportReturn = 'M3_Land_Base_Marker',
            },
            Priority = 110,
        })
        opai:SetChildQuantity({'LightArtillery'}, 14)
        opai:SetLockingStyle('BuildTimer', {LockTimer = 300})
    end

    for i = 1, 2 do
        opai = UEFM3LandBase:AddOpAI('BasicLandAttack', 'M3_UEFTransportAttack3_' .. i,
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain = 'M3_UEF_Transport_Attack_Chain',
                LandingChain = 'M3_UEF_Landing_Chain' .. i,
                MovePath = 'M3_UEF_Transport_Route_Chain' .. i,
                TransportReturn = 'M3_Land_Base_Marker',
            },
            Priority = 110,
        })
        opai:SetChildQuantity({'HeavyTanks'}, 6)
        opai:SetLockingStyle('BuildTimer', {LockTimer = 300})
    end

    for i = 1, 2 do
        opai = UEFM3LandBase:AddOpAI('BasicLandAttack', 'M3_UEFTransportAttack4_' .. i,
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain = 'M3_UEF_Transport_Attack_Chain',
                LandingChain = 'M3_UEF_Landing_Chain' .. i,
                MovePath = 'M3_UEF_Transport_Route_Chain' .. i,
                TransportReturn = 'M3_Land_Base_Marker',
            },
            Priority = 110,
        })
        opai:SetChildQuantity({'LightArtillery'}, 14)
        opai:SetLockingStyle('BuildTimer', {LockTimer = 300})
    end

    #-------------
    # Land Defense
    #-------------

    opai = UEFM3LandBase:AddOpAI('BasicLandAttack', 'M3_Air_Base_Land_Defense1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Air_Base_Land_Defence_Chain1', 'M3_Air_Base_Land_Defence_Chain2'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('MobileMissiles', 8)

    opai = UEFM3LandBase:AddOpAI('BasicLandAttack', 'M3_Air_Base_Land_Defense2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Air_Base_Land_Defence_Chain1', 'M3_Air_Base_Land_Defence_Chain2'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('HeavyTanks', 12)

    opai = UEFM3LandBase:AddOpAI('BasicLandAttack', 'M3_Air_Base_Land_Defense3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Air_Base_Land_Defence_Chain1', 'M3_Air_Base_Land_Defence_Chain2'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('MobileFlak', 8)

    opai = UEFM3LandBase:AddOpAI('BasicLandAttack', 'M3_Air_Base_Land_Defense4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Air_Base_Land_Defence_Chain1', 'M3_Air_Base_Land_Defence_Chain2'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('HeavyTanks', 16)

end

function UEFM3EngiBaseLandAttacks()

    local opai = nil

    # Builds Platoon of 2 Engineers 12 times
    local Temp = {
        'EngineerAttackTemp4',
        'NoPlan',
        { 'uel0105', 1, 2, 'Attack', 'None' },   # T1 Engies
    }
    local Builder = {
        BuilderName = 'EngineerAttackBuilder4',
        PlatoonTemplate = Temp,
        InstanceCount = 12,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'EngiBase',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},       
        PlatoonData = {
            PatrolChains = {'M3_Air_Attack_Chain1', 'M3_Air_Attack_Chain2', 'M3_Air_Attack_Chain3', 'M3_Air_Attack_Chain4', 'M3_Air_Attack_Chain5', 'M3_Air_Attack_Chain6', 'M3_Air_Attack_Chain7'},
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    # Builds Platoon of 2 Engineers 8 times
    Temp = {
        'EngineerAttackTemp5',
        'NoPlan',
        { 'uel0105', 1, 2, 'Attack', 'None' },   # T1 Engies
    }
    Builder = {
        BuilderName = 'EngineerAttackBuilder5',
        PlatoonTemplate = Temp,
        InstanceCount = 8,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'EngiBase',
        BuildConditions = {
            { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', 1, categories.FACTORY * categories.NAVAL}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},       
        PlatoonData = {
            PatrolChains = {'M3_Air_Base_NavalAttack_Chain1', 'M3_Air_Base_NavalAttack_Chain2', 'M3_Air_Base_NavalAttack_Chain3', 'M3_Air_Base_NavalAttack_Chain4'},
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

end

# ------------------------------------
# UEF M3 Air Base Op AI, Naval Attacks
# ------------------------------------

function UEFM3SouthNavalAttacks()

    local opai = nil

    # Defense
    local Temp = {
        'NavalDefenseTemp1',
        'NoPlan',
        { 'ues0201', 1, 2, 'Attack', 'GrowthFormation' },   # Destroyers
        { 'ues0202', 1, 1, 'Attack', 'GrowthFormation' },   # Cruisers
    }
    local Builder = {
        BuilderName = 'NavyDefenseBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 200,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'SouthNavalBase',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'M3_Air_Base_NavalDef1_Chain', 'M3_Air_Base_NavalDef2_Chain'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    #--------
    # Attacks
    # -------
    Temp = {
        'NavalAttackTemp1',
        'NoPlan',
        { 'ues0201', 1, 2, 'Attack', 'GrowthFormation' },   # Destroyers
        { 'ues0103', 1, 2, 'Attack', 'GrowthFormation' },   # Frigates
        { 'ues0203', 1, 4, 'Attack', 'GrowthFormation' },   # Submarines
    }
    Builder = {
        BuilderName = 'NavyAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 300,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'SouthNavalBase',
        BuildConditions = {
            { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', 12, categories.NAVAL * categories.MOBILE + categories.uel0203}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'M3_Air_Base_NavalAttack_Chain2', 'M3_Air_Base_NavalAttack_Chain4'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    Temp = {
        'NavalAttackTemp2',
        'NoPlan',
        { 'ues0201', 1, 4, 'Attack', 'GrowthFormation' },   # Destroyers
        { 'ues0202', 1, 2, 'Attack', 'GrowthFormation' },   # Cruisers
        { 'xes0205', 1, 2, 'Attack', 'GrowthFormation' },   # Shield Boat
    }
    Builder = {
        BuilderName = 'NavyAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 400,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'SouthNavalBase',
        BuildConditions = {
            { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', 20, categories.NAVAL * categories.MOBILE + categories.uel0203}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'M3_Air_Base_NavalAttack_Chain2', 'M3_Air_Base_NavalAttack_Chain4'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    Temp = {
        'NavalAttackTemp3',
        'NoPlan',
        { 'ues0202', 1, 3, 'Attack', 'GrowthFormation' },   # Cruisers
        { 'xes0205', 1, 1, 'Attack', 'GrowthFormation' },   # Shield Boat
    }
    Builder = {
        BuilderName = 'NavyAttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 400,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'SouthNavalBase',
        BuildConditions = {
            { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', 25, categories.dea0202 + categories.uea0203 + categories.uea0204 + categories.uea0103}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'M3_Air_Base_NavalAttack_Chain2', 'M3_Air_Base_NavalAttack_Chain4'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    Temp = {
        'NavalAttackTemp4',
        'NoPlan',
        { 'ues0103', 1, 4, 'Attack', 'GrowthFormation' },   # Frigates
        { 'ues0203', 1, 4, 'Attack', 'GrowthFormation' },   # Submarines
    }
    Builder = {
        BuilderName = 'NavyAttackBuilder4',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 250,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'SouthNavalBase',
        BuildConditions = {
            { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', 4, categories.NAVAL * categories.MOBILE + categories.uel0203}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'M3_Air_Base_NavalAttack_Chain2', 'M3_Air_Base_NavalAttack_Chain4'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

end

function UEFM3WestNavalAttacks()

    local opai = nil

    # Defense
    local Temp = {
        'NavalDefenseTemp2',
        'NoPlan',
        { 'ues0103', 1, 4, 'Attack', 'GrowthFormation' },   # Frigates
        { 'ues0203', 1, 4, 'Attack', 'GrowthFormation' },   # Submarines
    }
    local Builder = {
        BuilderName = 'NavyDefenseBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 200,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'WestNavalBase',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},       
        PlatoonData = {
            PatrolChains = {'M3_Air_Base_NavalDef1_Chain', 'M3_Air_Base_NavalDef2_Chain'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    #--------
    # Attacks
    # -------
    Temp = {
        'NavalAttackTemp5',
        'NoPlan',
        { 'ues0103', 1, 4, 'Attack', 'GrowthFormation' },   # Frigates
        { 'ues0203', 1, 4, 'Attack', 'GrowthFormation' },   # Submarines
    }
    Builder = {
        BuilderName = 'NavyAttackBuilder5',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 250,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'WestNavalBase',
        BuildConditions = {
            { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', 4, categories.NAVAL * categories.MOBILE + categories.uel0203}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},       
        PlatoonData = {
            PatrolChains = {'M3_Air_Base_NavalAttack_Chain1', 'M3_Air_Base_NavalAttack_Chain3'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    Temp = {
        'NavalAttackTemp6',
        'NoPlan',
        { 'ues0103', 1, 8, 'Attack', 'GrowthFormation' },   # Frigates
        { 'ues0203', 1, 4, 'Attack', 'GrowthFormation' },   # Submarines
    }
    Builder = {
        BuilderName = 'NavyAttackBuilder6',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 300,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'WestNavalBase',
        BuildConditions = {
            { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', 10, categories.NAVAL * categories.MOBILE + categories.uel0203}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},       
        PlatoonData = {
            PatrolChains = {'M3_Air_Base_NavalAttack_Chain1', 'M3_Air_Base_NavalAttack_Chain3'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    Temp = {
        'NavalAttackTemp7',
        'NoPlan',
        { 'ues0103', 1, 12, 'Attack', 'GrowthFormation' },   # Frigates
        { 'ues0203', 1, 6, 'Attack', 'GrowthFormation' },   # Submarines
    }
    Builder = {
        BuilderName = 'NavyAttackBuilder7',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 350,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'WestNavalBase',
        BuildConditions = {
            { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', 16, categories.NAVAL * categories.MOBILE + categories.uel0203}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},       
        PlatoonData = {
            PatrolChains = {'M3_Air_Base_NavalAttack_Chain1', 'M3_Air_Base_NavalAttack_Chain3'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

end