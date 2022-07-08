local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/ScenarioPlatoonAI.lua'
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')

---------
-- Locals
---------
local UEF = 3
local Difficulty = ScenarioInfo.Options.Difficulty

----------------
-- Base Managers
----------------
local ControlCenter = BaseManager.CreateBaseManager()
local ForwardBase = BaseManager.CreateBaseManager()
local UEFMainBase = BaseManager.CreateBaseManager()

----------------------
-- Control Center Base
----------------------
function ControlCenterAI()
    ControlCenter:InitializeDifficultyTables(ArmyBrains[UEF], 'Control_Center_Base', 'Control_Center_Base_Marker', 25, {Control_Center_Base = 100})
    ControlCenter:StartNonZeroBase(0)
end

function ControlCenterBuildExtraDefences()
    ControlCenter:AddBuildGroupDifficulty('Control_Center_Extra_Defences', 90)

    ControlCenter:SetEngineerCount(9)
    ControlCenter:SetMaximumConstructionEngineers(9)
end

---------------
-- Forward Base
---------------
function ForwardBaseAI()
    ForwardBase:InitializeDifficultyTables(ArmyBrains[UEF], 'Forward_Base', 'Forward_Base_Marker', 30, {M2DefensiveLine = 100})
    ForwardBase:StartEmptyBase(9)

    ForwardBase:SetMaximumConstructionEngineers(9)
end

function MobileFactoryAI(fatboys)
    -- from fatty
    -- Adding build location for AI
    ArmyBrains[UEF]:PBMAddBuildLocation('UEF_Mobile_Factory_Marker', 20, 'MobileFactory')

    local fatboy1, fatboy2 = fatboys[1], fatboys[2]
    local factory1, factory2 = fatboy1.ExternalFactory, fatboy2.ExternalFactory
    local buildLocation

    for _, location in ArmyBrains[UEF].PBM.Locations do
        if location.LocationType == 'MobileFactory' then
            buildLocation = location
            break
        end
    end

    buildLocation.PrimaryFactories.Land = factory1

    local function changePrimaryFactory()
        if not fatboy2.dead then
            buildLocation.PrimaryFactories.Land = factory2
        end
    end

    ScenarioFramework.CreateUnitDeathTrigger(changePrimaryFactory, fatboy1)

    local rally = ScenarioUtils.MarkerToPosition('UEF_Mobile_Factory_Rally')
    IssueClearFactoryCommands({factory1, factory2})
    IssueFactoryRallyPoint({factory1, factory2}, rally)

    IssueFactoryAssist({factory2}, factory1)

    MobileFactoryAttacks()
end

function MobileFactoryAttacks()
    -- 12 titans, 12 demo, 8 flak, 8 shields, 8 pillars
    local Builder = {
        BuilderName = 'UEF_Mobile_Factory_1_Builder_1',
        PlatoonTemplate = {
            'UEF_Mobile_Factory_1_Template_1',
            'NoPlan',
            {'uel0303', 1, 4 + 4 * Difficulty, 'Attack', 'AttackFormation'},   -- T3 Titans
            {'uel0304', 1, 4 + 4 * Difficulty, 'Attack', 'AttackFormation'},   -- T3 Arty
            {'uel0202', 1, 2 + 2 * Difficulty, 'Attack', 'AttackFormation'},   -- T2 Tank
            {'uel0205', 1, 2 + 2 * Difficulty, 'Attack', 'AttackFormation'},   -- T2 Flak
            {'uel0307', 1, 2 + 2 * Difficulty, 'Attack', 'AttackFormation'},   -- T2 Mobile Shield
        },
        InstanceCount = 2,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'MobileFactory',
        BuildConditions = {
        --    { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        --        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.LAND * categories.MOBILE, '>='}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},       
        PlatoonData = {
            PatrolChain = 'M2LandAttack_Chain5',
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon(Builder)
end

----------------
-- UEF Main Base
----------------
function UEFMainBaseAI()
    UEFMainBase:InitializeDifficultyTables(ArmyBrains[UEF], 'UEF_Main_Base', 'UEF_Main_Base_Marker', 200, {UEF_Main_Base = 100})
    UEFMainBase:StartNonZeroBase({{18, 23, 28}, {15, 19, 23}})
    UEFMainBase:SetMaximumConstructionEngineers(5)

    UEFMainBase:AddBuildGroupDifficulty('UEF_Main_Base_Extra', 90)

    M1UEFMainBaseAirAttacks()
    M1UEFMainBaseNavalAttacks()
end

-- M1 Attacks
function M1UEFMainBaseAirAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    -- Attack Aeon
    opai = UEFMainBase:AddOpAI('AirAttacks', 'UEF_To_Aeon_AirAttack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
            PlatoonData = {
                PatrolChain = 'AeonNaval_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Bombers', 15)
    opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua',
        'MissionNumberLessOrEqual', {'default_brain', 2})

    opai = UEFMainBase:AddOpAI('AirAttacks', 'UEF_To_Aeon_AirAttack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
            PlatoonData = {
                PatrolChain = 'AeonNaval_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Interceptors', 15)
    opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua',
        'MissionNumberLessOrEqual', {'default_brain', 2})
end

function M1UEFMainBaseNavalAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    opai = UEFMainBase:AddOpAI('NavalAttacks', 'UEF_To_Aeon_NavalAttack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
            PlatoonData = {
                PatrolChain = 'AeonNaval_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'Destroyers', 'Frigates'}, {2, 4})
    opai:SetLockingStyle('BuildTimer', {LockTimer = 90})
    opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua',
        'MissionNumberLessOrEqual', {'default_brain', 2})
end

-- M2 Attacks
function M2UEFMainBaseAirAttacks()
    UEFMainBase:SetActive('AirScouting', true)

    local opai = nil
    -- Transport builder
    opai = UEFMainBase:AddOpAI('EngineerAttack', 'UEF_TransportBuilder',
        {
            MasterPlatoonFunction = {SPAIFileName, 'TransportPool'},
            PlatoonData = {
                TransportMoveLocation = 'UEF_Main_Base_Transport_Return',
            },
            Priority = 1000,
        }
    )
    opai:SetChildQuantity('T2Transports', 4)
    opai:SetLockingStyle('None')
    opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
        'HaveLessThanUnitsWithCategory', {'default_brain', 6, categories.uea0104})

    -- Topr bombers
    quantity = {8, 12, 16}
    opai = UEFMainBase:AddOpAI('AirAttacks', 'M2_UEF_To_Player_AirAttack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'UEF_Naval_Attack_Chain',
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity('TorpedoBombers', quantity[Difficulty])
end

function M2UEFMainBaseLandAttacks()
    UEFMainBase:SetActive('LandScouting', true)

    local opai = nil
    local quantity = {}
    local trigger = {}

    -- M2
    -- 8 pillars, shields, flak, 16 titans, T3 arty
    --quantity = {7, 9, 11}
    --trigger = {35, 30, 25}
    local Builder = {
        BuilderName = 'UEF_To_Player_Land_Custom_Builder_1',
        PlatoonTemplate = {
            'UEF_To_Player_Land_Custom_Template_1',
            'NoPlan',
            {'uel0303', 1, 4 + 4 * Difficulty, 'Attack', 'AttackFormation'},   -- T3 Titans
            {'uel0304', 1, 4 + 4 * Difficulty, 'Attack', 'AttackFormation'},   -- T3 Arty
            {'uel0202', 1, 2 + 2 * Difficulty, 'Attack', 'AttackFormation'},   -- T2 Tank
            {'uel0205', 1, 2 + 2 * Difficulty, 'Attack', 'AttackFormation'},   -- T2 Flak
            {'uel0307', 1, 2 + 2 * Difficulty, 'Attack', 'AttackFormation'},   -- T2 Mobile Shield
        },
        InstanceCount = 1,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'UEF_Main_Base',
        BuildConditions = {
        --    { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        --        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.LAND * categories.MOBILE, '>='}},
            {'/lua/editor/BaseManagerBuildConditions.lua', 'BaseActive', {'UEF_Main_Base'}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},       
        PlatoonData = {
            PatrolChains = {
                'M2LandAttack_Chain1',
                'M2LandAttack_Chain2',
                'M2LandAttack_Chain3',
                'M2LandAttack_Chain4',
                'M2LandAttack_Chain5',
            },
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon(Builder)

    if false then
        quantity = {4, 6, 8}
        --trigger = {{180, 160, 140}, {160, 140, 120}}
        opai = UEFMainBase:AddOpAI('BasicLandAttack', 'UEF_TransportAttack_1',
            {
                MasterPlatoonFunction = {SPAIFileName, 'LandAssaultWithTransports'},
                PlatoonData = {
                    AttackChain = 'Aeon_AttackChain',
                    LandingChain = 'Aeon_LandingChain',
                    TransportChain = 'M2_UEF_Transport_Move_Chain',
                    TransportReturn = 'UEF_Main_Base_Transport_Return',
                },
                Priority = 200,
            }
        )
        opai:SetChildQuantity('SiegeBots', quantity[Difficulty])
        --opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
        --    'HaveGreaterThanUnitsWithCategory', {'default_brain', math.ceil(quantity[Difficulty] / 2), categories.uea0104})
    end
end

function M2UEFMainBaseNavalAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    opai = UEFMainBase:AddOpAI('NavalAttacks', 'M2_UEF_To_Player_NavalAttack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'UEF_Naval_Attack_Chain',
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity({'Destroyers', 'Cruisers', 'Frigates', 'Submarines'}, {4, 2, 8, 18})
    opai:SetFormation('AttackFormation')
end

-- M3 Attacks
function UEFMainBaseSpawnHLRA()
    UEFMainBase:AddBuildGroup('UEF_Main_Base_HLRA', 80, true)
end

function M3UEFMainBaseNavalAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    quantity = {
        {2, 2, 2},
        {1, 4, 4, 4},
        {2, 6, 6, 6},
    }
    opai = UEFMainBase:AddOpAI('NavalAttacks', 'M3_UEF_To_Player_NavalAttack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'UEF_Naval_Attack_Chain',
            },
            Priority = 200,
        }
    )
    if Difficulty == 1 then
        opai:SetChildQuantity({'Destroyers', 'Cruisers', 'Submarines'}, quantity[Difficulty])
    else
        opai:SetChildQuantity({'Battleships', 'Destroyers', 'Cruisers', 'Submarines'}, quantity[Difficulty])
    end
    opai:SetFormation('AttackFormation')
end

function M3UEFMainBaseConditionalBuilds()
    -- Sonar in the base
    opai = UEFMainBase:AddOpAI('M3_UEF_Sonar',
        {
            Amount = 1,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'UEF_Sonar_Patrol_Chain',
            },
            MaxAssist = 3,
            Retry = true,
        }
    )

    -- Fatboy
    local assisters = {3, 4, 5}
    opai = UEFMainBase:AddOpAI('M3_Attack_Fatboy',
        {
            Amount = 1,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M2LandAttack_Chain1',
                    'M2LandAttack_Chain2',
                    'M2LandAttack_Chain3',
                    'M2LandAttack_Chain4',
                    'M2LandAttack_Chain5',
                },
            },
            MaxAssist = assisters[Difficulty],
            Retry = true,
        }
    )
end

function StartBuildingAtlantis()
    -- Atlantis to attack player
    opai = UEFMainBase:AddOpAI('M3_Attack_Atlantis',
        {
            Amount = 1,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'UEF_Naval_Attack_Chain',
            },
            MaxAssist = 3,
            Retry = true,
        }
    )
end