local BaseManager = import('/lua/ai/opai/basemanager.lua')
local CustomFunctions = '/maps/FortClarkeAssault/FortClarkeAssault_CustomFunctions.lua'
local SPAIFileName = '/lua/scenarioplatoonai.lua'

---------
-- Locals
---------
local UEF = 4
local Difficulty = ScenarioInfo.Options.Difficulty

----------------
-- Base Managers
----------------
local FortClarke = BaseManager.CreateBaseManager()
local UEFM3WestTown = BaseManager.CreateBaseManager()
local UEFM3Base = BaseManager.CreateBaseManager()
local UEFM3BaseNaval = BaseManager.CreateBaseManager()

--------------
-- Fort Clarke
--------------
function FortClarkeAI()
    FortClarke:InitializeDifficultyTables(ArmyBrains[UEF], 'UEF_Fort_Clarke_Base', 'M3_UEF_Fort_Clarke_Marker', 210, {UEF_Fort_Clarke_Base = 100})
    FortClarke:StartNonZeroBase({{8, 10, 12}, {6, 8, 10}})
    FortClarke:SetActive('AirScouting', true)

    FortClarkeAirAttacks()
    FortClarkeLandAttacks()
    FortClarkeExperimentals()
end

function FortClarkeAirAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    quantity = {16, 20, 24}
    opai = FortClarke:AddOpAI('AirAttacks', 'M3_Fort_Clarke_AirAttack1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_UEF_LandAttack_Mid_Chain_1', 'M3_UEF_LandAttack_Mid_Chain_2'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'HeavyGunships', 'Gunships'}, quantity[Difficulty])
    opai:SetLockingStyle('None')

    quantity = {3, 4, 6}
    opai = FortClarke:AddOpAI('AirAttacks', 'M3_Fort_Clarke_AirAttack2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_UEF_LandAttack_Mid_Chain_1', 'M3_UEF_LandAttack_Mid_Chain_2'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('StratBombers', quantity[Difficulty])

    -- Yotha sniping platoon
    quantity = {8, 12, 16}
    trigger = {4, 3, 2}
    opai = FortClarke:AddOpAI('AirAttacks', 'M3_Fort_Clarke_AirAttack3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'CategoryHunterPlatoonAI'},
            PlatoonData = {
                CategoryList = { categories.EXPERIMENTAL * categories.LAND },
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity('StratBombers', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.EXPERIMENTAL * categories.LAND, '>='})

    quantity = {8, 12, 16}
    opai = FortClarke:AddOpAI('AirAttacks', 'M3_Fort_Clarke_AirAttack4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_UEF_LandAttack_Mid_Chain_1', 'M3_UEF_LandAttack_Mid_Chain_2'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])

    quantity = {16, 24, 32}
    trigger = {70, 60, 50}
    opai = FortClarke:AddOpAI('AirAttacks', 'M3_Fort_Clarke_AirAttack5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_UEF_LandAttack_Mid_Chain_1', 'M3_UEF_LandAttack_Mid_Chain_2'},
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE, '>='})

    -- Air Defense
    for i = 1, 3 do
        quantity = {5, 6, 7}
        opai = FortClarke:AddOpAI('AirAttacks', 'M3_Fort_Clarke_AirDef1' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M3_UEF_FC_AirPatrol_Chain_1',
                },
                Priority = 210,
            }
        )
        opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
        opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    end

    for i = 1, 2 do
        quantity = {4, 5, 6}
        opai = FortClarke:AddOpAI('AirAttacks', 'M3_Fort_Clarke_AirDef2' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M3_UEF_FC_AirPatrol_Chain_1',
                },
                Priority = 200,
            }
        )
        opai:SetChildQuantity('HeavyGunships', 5)
        opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})

        quantity = {2, 3, 4}
        opai = FortClarke:AddOpAI('AirAttacks', 'M3_Fort_Clarke_AirDef3' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M3_UEF_FC_AirPatrol_Chain_1',
                },
                Priority = 200,
            }
        )
        opai:SetChildQuantity('StratBombers', 3)
        opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    end
end

function FortClarkeLandAttacks()
    local opai = nil

    ---------------------------------
    -- Fort Clarke Op AI, Land Attacks
    ---------------------------------

    -- sends [siege bots, mobile shields, mobile missile platforms]
    local template = {
        'HeavyLandAttack1',
        'NoPlan',
        { 'uel0303', 1, 8, 'Attack', 'GrowthFormation' },    -- Siege Bots
        { 'xel0306', 1, 4, 'Attack', 'GrowthFormation' },    -- Mobile Missile Platforms
        { 'uel0307', 1, 4, 'Attack', 'GrowthFormation' },    -- Mobile Shields
    }
    local builder = {
        BuilderName = 'HeavyLandAttack1',
        PlatoonTemplate = template,
        InstanceCount = 2,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'UEF_Fort_Clarke_Base',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},
        PlatoonData = {
            PatrolChains = {'M3_UEF_LandAttack_Mid_Chain_1', 'M3_UEF_LandAttack_Mid_Chain_2'},
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( builder )

    template = {
        'HeavyLandAttack2',
        'NoPlan',
        { 'uel0303', 1, 4, 'Attack', 'GrowthFormation' },    -- Siege Bots
        { 'xel0305', 1, 4, 'Attack', 'GrowthFormation' },    -- Mobile Missile Platforms
    }
    builder = {
        BuilderName = 'HeavyLandAttack2',
        PlatoonTemplate = template,
        InstanceCount = 3,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'UEF_Fort_Clarke_Base',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},
        PlatoonData = {
            PatrolChains = {'M3_UEF_LandAttack_Mid_Chain_1', 'M3_UEF_LandAttack_Mid_Chain_2'},
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( builder )

    template = {
        'HeavyLandAttack3',
        'NoPlan',
        { 'uel0202', 1, 8, 'Attack', 'GrowthFormation' },    -- Heavy Tanks
        { 'uel0205', 1, 4, 'Attack', 'GrowthFormation' },    -- Mobile Flak
    }
    builder = {
        BuilderName = 'HeavyLandAttack3',
        PlatoonTemplate = template,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'UEF_Fort_Clarke_Base',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},
        PlatoonData = {
            PatrolChains = {'M3_UEF_LandAttack_Mid_Chain_1', 'M3_UEF_LandAttack_Mid_Chain_2'},
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( builder )

    template = {
        'HeavyLandAttack4',
        'NoPlan',
        { 'uel0303', 1, 8, 'Attack', 'GrowthFormation' },    -- Siege Bots
        { 'uel0111', 1, 8, 'Attack', 'GrowthFormation' },    -- Mobile Missiles
    }
    builder = {
        BuilderName = 'HeavyLandAttack4',
        PlatoonTemplate = template,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'UEF_Fort_Clarke_Base',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},
        PlatoonData = {
            PatrolChains = {'M3_UEF_LandAttack_Mid_Chain_1', 'M3_UEF_LandAttack_Mid_Chain_2'},
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( builder )

    template = {
        'HeavyLandAttack5',
        'NoPlan',
        { 'uel0303', 1, 4, 'Attack', 'GrowthFormation' },    -- Siege Bots
        { 'uel0202', 1, 4, 'Attack', 'GrowthFormation' },    -- Heavy Tanks
        { 'uel0103', 1, 4, 'Attack', 'GrowthFormation' },    -- Mobile Light Artillery
    }
    builder = {
        BuilderName = 'HeavyLandAttack5',
        PlatoonTemplate = template,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'UEF_Fort_Clarke_Base',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},
        PlatoonData = {
            PatrolChains = {'M3_UEF_LandAttack_Mid_Chain_1', 'M3_UEF_LandAttack_Mid_Chain_2'},
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( builder )

    -- [mobile flak, mobile aa] patrols
    --[[
    for i = 1, 2 do
    for x = 1, 2 do
        opai = FortClarke:AddOpAI('BasicLandAttack', 'FortClarkeLandBasePatrol' .. i .. x,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'UEF_M3_BasePatrol' .. i .. '_Chain',
                },
                Priority = 110,
            }
        )
        opai:SetChildQuantity({'MobileFlak', 'MobileAntiAir'}, 4)
    end
    end

    -- [siege bots] patrols
    for i = 1, 2 do
        opai = FortClarke:AddOpAI('BasicLandAttack', 'FortClarkeFrontLandBasePatrol' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomPatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M3_UEF_BaseFrontPatrol_Chain',
                },
                Priority = 120,
            }
        )
        opai:SetChildQuantity({'SiegeBots'}, 8)
    end
    ]]--
end

function FortClarkeExperimentals()
    local quantity = {1, 1, 2}
    local engineers = {2, 3, 4}
    local opai = FortClarke:AddOpAI('M4_FC_Fatboy_2',
        {
            Amount = quantity[Difficulty],
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_UEF_LandAttack_Mid_Chain_1', 'M3_UEF_LandAttack_Mid_Chain_2'},
            },
            MaxAssist = engineers[Difficulty],
            Retry = true,
        }
    )

    opai = FortClarke:AddOpAI('M4_FC_Fatboy_1',
        {
            Amount = 1,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M4_Fort_Clarke_Fatboy_Chain',
            },
            MaxAssist = engineers[Difficulty],
            Retry = true,
        }
    )
end

------------
-- West Town
------------
function UEFM3WestTownAI()
    UEFM3WestTown:InitializeDifficultyTables(ArmyBrains[UEF], 'M3_UEF_West_Town_Base', 'M3_UEF_West_Town_Base_Marker', 70, {M3_UEF_West_Town_Base = 100})
    UEFM3WestTown:StartNonZeroBase({{3, 4, 5}, {2, 3, 3}})

    -- UEFM3WestTown:AddBuildGroupDifficulty('M3_West_Town_Rebuild', 90)
    UEFM3WestTown:SetActive('AirScouting', true)

    UEFM3WestTownLandAttacks()
    UEFM3WestTownAirAttacks()
end

function UEFM3WestTownLandAttacks()
    local opai = nil

    -- sends [mobile missiles]
    opai = UEFM3WestTown:AddOpAI('BasicLandAttack', 'M3_LandAttack1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_UEF_West_Town_Patrol_Chain',
            },
        }
    )
    opai:SetChildQuantity('MobileMissiles', 6)

    -- sends [heavy tanks]
    opai = UEFM3WestTown:AddOpAI('BasicLandAttack', 'M3_LandAttack2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_UEF_West_Town_Patrol_Chain',
            },
        }
    )
    opai:SetChildQuantity('HeavyTanks', 6)

    -- sends [light bots]
    opai = UEFM3WestTown:AddOpAI('BasicLandAttack', 'M3_LandAttack3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_UEF_West_Town_Patrol_Chain',
            },
        }
    )
    opai:SetChildQuantity('SiegeBots', 6)

    -- sends [light artillery]
    opai = UEFM3WestTown:AddOpAI('BasicLandAttack', 'M3_LandAttack4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_UEF_West_Town_Patrol_Chain',
            },
        }
    )
    opai:SetChildQuantity('LightArtillery', 6)
end

function UEFM3WestTownAirAttacks()
    local opai = nil

    -- air defense
    for i = 1, 6 do
        opai = UEFM3WestTown:AddOpAI('AirAttacks', 'M3_AirDefense' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M3_UEF_West_Town_Patrol_Chain',
                },
            }
        )
        opai:SetChildQuantity('Gunships', 1)
    end
end

----------------
-- UEF Main Base
----------------
function UEFM3BaseAI()
    UEFM3Base:InitializeDifficultyTables(ArmyBrains[UEF], 'M3_UEF_Base', 'M3_UEF_Base_Marker', 35, {M3_UEF_Base = 100})
    UEFM3Base:StartNonZeroBase({{8, 11, 14}, {6, 9, 11}})
    UEFM3Base:SetActive('AirScouting', true)

    UEFM3BaseAirAttacks()
    UEFM3BaseLandAttacks()
end

function UEFM3BaseAirAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    quantity = {12, 16, 20}
    for i = 1, 2 do
        opai = UEFM3Base:AddOpAI('AirAttacks', 'M2_UEF_AirAttack_1' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M3_UEF_Base_NavalAttack_Chain',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('Gunships', quantity[Difficulty])
    end

    quantity = {8, 10, 12}
    for i = 1, 2 do
        opai = UEFM3Base:AddOpAI('AirAttacks', 'M2_UEF_AirAttack_2' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M3_UEF_Base_NavalAttack_Chain',
                },
                Priority = 110,
            }
        )
        opai:SetChildQuantity('TorpedoBombers', quantity[Difficulty])
    end

    quantity = {8, 10, 12}
    for i = 1, 2 do
        opai = UEFM3Base:AddOpAI('AirAttacks', 'M2_UEF_AirAttack_3' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M3_UEF_Base_NavalAttack_Chain',
                },
                Priority = 110,
            }
        )
        opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    end
end

function UEFM3BaseLandAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    opai = UEFM3Base:AddOpAI('EngineerAttack', 'M2_UEF_TransportBuilder',
    {
        MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
        PlatoonData = {
            TransportReturn = 'M3_UEF_Base_Marker',
        },
        Priority = 1000,
    })
    opai:SetChildQuantity('T2Transports', 4)
    opai:SetLockingStyle('None')
    opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua', 'HaveLessThanUnitsWithCategory', {'default_brain', 5, categories.uea0104})

    opai = UEFM3Base:AddOpAI('BasicLandAttack', 'M2_UEF_TransportAttack_1',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain =  'M2_UEF_Support_Civ_Chain', 
                --PatrolChain = 'M2_UEF_Support_Civ_Chain',
                LandingList = {'M2_UEF_Civ_Support_Drop_Marker'},
                TransportReturn = 'M3_UEF_Base_Marker',
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity('SiegeBots', 12)
    opai:SetLockingStyle('DeathTimer', {LockTimer = 60})
    opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumber', {'default_brain', 2})
end

--------
-- Naval
--------
function UEFM3BaseNavalAI()
    UEFM3BaseNaval:InitializeDifficultyTables(ArmyBrains[UEF], 'M3_UEF_Base_Naval', 'M3_UEF_Base_Naval_Marker', 60, {M3_UEF_Base_Naval = 100})
    UEFM3BaseNaval:StartNonZeroBase({{5, 8, 11}, {3, 6, 9}})
    
    UEFM3BaseNavalAttacks()
end

function UEFM3BaseNavalAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    opai = UEFM3BaseNaval:AddNavalAI('M2_UEF_NavalAttack1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_UEF_Base_NavalAttack_Chain',
            },
            EnabledTypes = {'Submarine'},
            MaxFrigates = 18,
            MinFrigates = 18,
            Priority = 100,
        }
    )
    opai:SetChildActive('T2', false)
    opai:SetChildActive('T3', false)
    --opai:SetFormation('AttackFormation')
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', 'Order', 1, categories.NAVAL * categories.MOBILE, '>='})

    opai = UEFM3BaseNaval:AddNavalAI('M2_UEF_NavalAttack2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_UEF_Base_NavalAttack_Chain',
            },
            EnabledTypes = {'Destroyer', 'Cruiser', 'Submarine'},
            MaxFrigates = 30,
            MinFrigates = 30,
            Priority = 110,
            Overrides = {
                CORE_TO_CRUISERS = 2,
                CORE_TO_SUBS = 1,
            },
            DisableTypes = {['T2Submarine'] = true}
        }
    )
    opai:SetChildActive('T3', false)
    --opai:SetFormation('AttackFormation')
    opai:SetLockingStyle('DeathRatio', {Ratio = .8})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', 'Order', 1, categories.NAVAL * categories.MOBILE, '>='})

    opai = UEFM3BaseNaval:AddNavalAI('M2_UEF_NavalAttack3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_UEF_Base_NavalAttack_Chain',
            },
            EnabledTypes = {'Destroyer', 'Cruiser', 'Submarine'},
            MaxFrigates = 34,
            MinFrigates = 34,
            Priority = 120,
            Overrides = {
                CORE_TO_CRUISERS = 2,
                CORE_TO_SUBS = 1,
            },
            DisableTypes = {['T2Submarine'] = true}
        }
    )
    opai:SetChildActive('T3', false)
    --opai:SetFormation('AttackFormation')
    opai:SetLockingStyle('DeathRatio', {Ratio = .8})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', 'Order', 1, categories.NAVAL * categories.MOBILE, '>='})
end

function M3UEFBattleshipsAttacks()
    ---------------------
    -- Battleship attacks
    ---------------------
    -- Only in last part of the mission

    -- Sends 2 Battleships and 4 Cruisers if player has more than {4, 3, 2} Battleships.
    trigger = {4, 3, 2}
    opai = UEFM3BaseNaval:AddNavalAI('M3_UEF_Base_BattleshipAttack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_UEF_Base_NavalAttack_Chain',
            },
            EnabledTypes = {'Battleship', 'Cruiser'},
            MaxFrigates = 50,
            MinFrigates = 50,
            Priority = 130,
            Overrides = {
                CORE_TO_CRUISERS = 0.5,
            },
        }
    )
    --opai:SetFormation('AttackFormation')
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.BATTLESHIP, '>='})

    -- Sends 3 Battleships and Cruisers if player has more than {6, 5, 4} Battleships
    trigger = {6, 5, 4}
    opai = UEFM3BaseNaval:AddNavalAI('M3_UEF_Base_BattleshipAttack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_UEF_Base_NavalAttack_Chain',
            },
            EnabledTypes = {'Battleship', 'Cruiser'},
            MaxFrigates = 75,
            MinFrigates = 75,
            Priority = 140,
            Overrides = {
                CORE_TO_CRUISERS = 1,
            },
        }
    )
    --opai:SetFormation('AttackFormation')
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.BATTLESHIP, '>='})
    
    -- Sends 3 Battleships if Player has no naval.
    opai = UEFM3BaseNaval:AddNavalAI('M3_UEF_Base_BattleshipAttack_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_UEF_Base_NavalAttack_Chain',
            },
            EnabledTypes = {'Battleship'},
            MaxFrigates = 75,
            MinFrigates = 75,
            Priority = 150,
        }
    )
    opai:SetFormation('AttackFormation')
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainLessThanOrEqualNumCategory',
        {'default_brain', {'HumanPlayers'}, 0, categories.NAVAL * categories.FACTORY, '>='})

    ------------------
    -- Nuke Submarines
    ------------------
    -- Only if player thinks that winning using nukes is a good idea against speed2's AI...
    -- 3 Nuke Submarines with special orders only if player has more than 3 nukes (Battleships don't count)
    -- yet to be coded :|
    --[[
    opai = UEFM3BaseNaval:AddNavalAI('M3_UEF_Base_NukeSubsAttack_1',
        {
            MasterPlatoonFunction = {CustomFunctions, NukeSubAI},
            PlatoonData = {
                PatrolChain = 'M3_UEF_Base_NavalAttack_Chain',
            },
            EnabledTypes = {'NukeSubmarine'},
            MaxFrigates = 225,
            MinFrigates = 225,
            Priority = 500,
        }
    )
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, 3, categories.STRUCTURE * categories.NUKE, '>='})
    ]]--
end

-----------------
-- Other Funcions
-----------------
function DisableBase()
    if(UEFM3Base) then
        LOG('UEFM3Base stopped')
        UEFM3Base:BaseActive(false)
    end
end

function DisableFortClarkeBase()
    if(FortClarke) then
        LOG('FortClarke stopped')
        FortClarke:BaseActive(false)
    end
end