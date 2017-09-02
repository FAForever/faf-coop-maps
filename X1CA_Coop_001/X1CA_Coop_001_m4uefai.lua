-- ****************************************************************************
-- **
-- **  File     : /maps/X1CA_Coop_001/X1CA_Coop_001_m4uefai.lua
-- **  Author(s): Jessica St. Croix
-- **
-- **  Summary  : UEF army AI for Mission 4 - X1CA_Coop_001
-- **
-- **  Copyright © 2007 Gas Powered Games, Inc.  All rights reserved.
-- ****************************************************************************
local BaseManager = import('/lua/ai/opai/basemanager.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local ScenarioFramework = import('/lua/ScenarioFramework.lua')

local SPAIFileName = '/lua/scenarioplatoonai.lua'

--------
-- Locals
--------
local UEF = 4
local Difficulty = ScenarioInfo.Options.Difficulty

---------------
-- Base Managers
---------------
local FortClarke = BaseManager.CreateBaseManager()
local UEFM4ForwardOne = BaseManager.CreateBaseManager()
local UEFM4ForwardTwo = BaseManager.CreateBaseManager()

function FortClarkeAI()

    -------------
    -- Fort Clarke
    -------------
    ScenarioUtils.CreateArmyGroup('UEF', 'M4_UEF_Clarke_Init_Eng_D' .. Difficulty)
    FortClarke:InitializeDifficultyTables(ArmyBrains[UEF], 'UEF_Fort_Clarke_Base', 'UEF_Fort_Clarke_Marker', 210, {UEF_Fort_Clarke_Base = 100,})
    FortClarke:StartNonZeroBase({40, 32})
    FortClarke:SetMaximumConstructionEngineers(4)
    FortClarke:SetConstructionAlwaysAssist(true)

    ScenarioFramework.AddRestriction(UEF, categories.uel0105) -- UEF T1 Engineer

    -- Expansion setup
    -- FortClarke:AddExpansionBase('UEFM4ForwardOne', 4)
    -- FortClarke:AddExpansionBase('UEFM4ForwardTwo', 4)

    FortClarke:AddBuildGroup('Bridge_Defenses_D1', 95)

    ScenarioFramework.CreateTimerTrigger(FortClarkeExpansionRebuilds, 480)

    ArmyBrains[UEF]:PBMSetCheckInterval(7)

    FortClarkeLandAttacks()
    FortClarkeAirAttacks()
end

function FortClarkeExpansionRebuilds()
    FortClarke:AddBuildGroup('M3_Forward_One_D1', 90)
    FortClarke:AddBuildGroup('M3_Forward_Two_D1', 80)
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
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},
        PlatoonData = {
            PatrolChain = 'M4_UEF_LandAttack_Mid_Chain',
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
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},
        PlatoonData = {
            PatrolChain = 'M4_UEF_LandAttack_Mid_Chain',
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
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},
        PlatoonData = {
            PatrolChain = 'M4_UEF_LandAttack_Mid_Chain',
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
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},
        PlatoonData = {
            PatrolChain = 'M4_UEF_LandAttack_Mid_Chain',
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
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},
        PlatoonData = {
            PatrolChain = 'M4_UEF_LandAttack_Mid_Chain',
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( builder )

    -- [mobile flak, mobile aa] patrols
    for i = 1, 2 do
    for x = 1, 2 do
        opai = FortClarke:AddOpAI('BasicLandAttack', 'FortClarkeLandBasePatrol' .. i .. x,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'UEF_M4_BasePatrol' .. i .. '_Chain',
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
                    PatrolChain = 'M4_UEF_BaseFrontPatrol_Chain',
                },
                Priority = 120,
            }
        )
        opai:SetChildQuantity({'SiegeBots'}, 8)
    end
end

function FortClarkeAirAttacks()
    local opai = nil

    --------------------------------
    -- Fort Clarke Op AI, Air Attacks
    --------------------------------

    -- sends [heavy gunships, gunships, interceptors]
    opai = FortClarke:AddOpAI('AirAttacks', 'M4_AirAttack1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M4_UEF_AirAttack1_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'HeavyGunships', 'Gunships', 'Interceptors'}, 9)
    opai:SetLockingStyle('None')

    -- sends [bombers]
    opai = FortClarke:AddOpAI('AirAttacks', 'M4_AirAttack2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M4_UEF_AirAttack1_Chain',
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Bombers', 8)

    -- sends [air superiority]
    opai = FortClarke:AddOpAI('AirAttacks', 'M4_AirAttack3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'RandomPatrolThread'},
            PlatoonData = {
                PatrolChain = 'M4_UEF_AirAttack1_Chain',
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('AirSuperiority', 8)

    -- Air Defense
    for i = 1, 2 do
    opai = FortClarke:AddOpAI('AirAttacks', 'M4_AirDefense1' .. i,
        {
            MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
            PlatoonData = {
                PatrolChain = 'M4_UEF_AirPatrol1_Chain',
            },
            Priority = 1110,
        }
    )
    opai:SetChildQuantity('AirSuperiority', 8)

    opai = FortClarke:AddOpAI('AirAttacks', 'M4_AirDefense2' .. i,
        {
            MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
            PlatoonData = {
                PatrolChain = 'M4_UEF_AirPatrol1_Chain',
            },
            Priority = 1110,
        }
    )
    opai:SetChildQuantity('HeavyGunships', 8)

    opai = FortClarke:AddOpAI('AirAttacks', 'M4_AirDefense3' .. i,
        {
            MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
            PlatoonData = {
                PatrolChain = 'M4_UEF_AirPatrol1_Chain',
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Interceptors', 8)
    end
end

function FortClarkeTransportAttacks()
    local opai = nil

    opai = FortClarke:AddOpAI('EngineerAttack', 'M4_UEF_TransportBuilder',
    {
        MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
        PlatoonData = {
            AttackChain = 'M4_UEF_Transport_AttackChain',
            LandingChain = 'M4_UEF_Transport_LandingChain',
            TransportReturn = 'M4_UEF_FrontBase_Patrol_5',
            Categories = {'STRUCTURES'},
        },
        Priority = 2000,
    })
    opai:SetChildActive('All', false)
    opai:SetChildActive('T3Transports', true)
    opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
        'HaveLessThanUnitsWithCategory', {'default_brain', 3, categories.uea0104 + categories.xea0306})
 
    opai = FortClarke:AddOpAI('BasicLandAttack', 'M4_UEF_TransportAttack1',
    {
        MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
        PlatoonData = {
            AttackChain = 'M4_UEF_Transport_AttackChain',
            LandingChain = 'M4_UEF_Transport_LandingChain',
            TransportReturn = 'M4_UEF_FrontBase_Patrol_5',
        },
        Priority = 130,
    })
    opai:SetChildQuantity('SiegeBots', 6)
    opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
        'HaveGreaterThanUnitsWithCategory', {'default_brain', 0, categories.xea0306})

    for i = 1, 2 do
        opai = FortClarke:AddOpAI('BasicLandAttack', 'M4_UEF_TransportAttack2' .. i,
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain = 'M4_UEF_Transport_AttackChain',
                LandingChain = 'M4_UEF_Transport_LandingChain',
                TransportReturn = 'M4_UEF_FrontBase_Patrol_5',
            },
            Priority = 130,
        })
        opai:SetChildQuantity('HeavyTanks', 12)
        opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
            'HaveGreaterThanUnitsWithCategory', {'default_brain', 1, categories.xea0306})

        opai = FortClarke:AddOpAI('BasicLandAttack', 'M4_UEF_TransportAttack3' .. i,
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain = 'M4_UEF_Transport_AttackChain',
                LandingChain = 'M4_UEF_Transport_LandingChain',
                TransportReturn = 'M4_UEF_FrontBase_Patrol_5',
            },
            Priority = 0,
        })
        opai:SetChildQuantity('LightTanks', 16)
        opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
            'HaveGreaterThanUnitsWithCategory', {'default_brain', 2, categories.xea0306})
    end

end

function UEFM4ForwardOneAI()

    --------------------
    -- UEF Forward Base 1
    --------------------
    UEFM4ForwardOne:InitializeDifficultyTables(ArmyBrains[UEF], 'M3_Forward_One', 'UEF_M3_Forward_One_Base_Marker', 40, {M3_Forward_One = 100,})
    UEFM4ForwardOne:StartNonZeroBase({6, 4})

    UEFM4ForwardOneLandAttacks()
    UEFM4ForwardOneAirAttacks()
end

function UEFM4ForwardOneLandAttacks()
    local opai = nil

    ----------------------------------------
    -- UEF M4 Forward One Op AI, Land Attacks
    ----------------------------------------

    -- sends [heavy tanks]
    opai = UEFM4ForwardOne:AddOpAI('BasicLandAttack', 'UEF_ForwardOne_LandAttack1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M4_UEF_LandAttack_South_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('HeavyTanks', 4)
    opai:SetLockingStyle('None')

    -- sends [mobile missiles, light artillery]
    opai = UEFM4ForwardOne:AddOpAI('BasicLandAttack', 'UEF_ForwardOne_LandAttack2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M4_UEF_LandAttack_South_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'MobileMissiles', 'LightArtillery'}, 4)
    opai:SetLockingStyle('None')

    -- sends [mobile flak]
    opai = UEFM4ForwardOne:AddOpAI('BasicLandAttack', 'UEF_ForwardOne_LandAttack3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M4_UEF_LandAttack_South_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'MobileFlak', 'LightBots'}, 4)
    opai:SetLockingStyle('None')
end

function UEFM4ForwardOneAirAttacks()
    local opai = nil

    ---------------------------------------
    -- UEF M4 Forward One Op AI, Air Attacks
    ---------------------------------------

    -- sends [gunships, interceptors]
    opai = UEFM4ForwardOne:AddOpAI('AirAttacks', 'UEF_ForwardOne_AirAttack1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M4_UEF_LandAttack_South_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'Gunships', 'Interceptors'}, 4)
    opai:SetLockingStyle('None')

end

function UEFM4ForwardTwoAI()

    --------------------
    -- UEF Forward Base 2
    --------------------
    UEFM4ForwardTwo:InitializeDifficultyTables(ArmyBrains[UEF], 'M3_Forward_Two', 'UEF_M3_Forward_Two_Base_Marker', 60, {M3_Forward_Two = 100,})
    UEFM4ForwardTwo:StartNonZeroBase({6, 4})

    UEFM4ForwardTwoLandAttacks()
end

function UEFM4ForwardTwoLandAttacks()
    local opai = nil

    ----------------------------------------
    -- UEF M4 Forward Two Op AI, Land Attacks
    ----------------------------------------

    -- sends [siege bots, mobile shields, heavy tanks, light bots]
    opai = UEFM4ForwardTwo:AddOpAI('BasicLandAttack', 'UEF_ForwardTwo_LandAttack1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M4_UEF_LandAttack_North_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'SiegeBots', 'MobileShields', 'HeavyTanks', 'LightBots'}, 8)
    opai:SetLockingStyle('None')

    -- sends [mobile missiles, light artillery]
    opai = UEFM4ForwardTwo:AddOpAI('BasicLandAttack', 'UEF_ForwardTwo_LandAttack2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M4_UEF_LandAttack_North_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'MobileMissiles', 'LightArtillery'}, 4)
    opai:SetLockingStyle('None')

    -- sends [mobile flak, mobile anti air]
    opai = UEFM4ForwardTwo:AddOpAI('BasicLandAttack', 'UEF_ForwardTwo_LandAttack3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M4_UEF_LandAttack_North_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'MobileFlak', 'MobileAntiAir'}, 4)
    opai:SetLockingStyle('None')
end
