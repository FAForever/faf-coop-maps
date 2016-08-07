-- ****************************************************************************
-- **
-- **  File     : /maps/X1CA_Coop_006/X1CA_Coop_006_m2rhizaai.lua
-- **  Author(s): Jessica St. Croix
-- **
-- **  Summary  : Rhiza army AI for Mission 2 - X1CA_Coop_006
-- **
-- **  Copyright © 2007 Gas Powered Games, Inc.  All rights reserved.
-- ****************************************************************************
local BaseManager = import('/lua/ai/opai/basemanager.lua')

local SPAIFileName = '/lua/ScenarioPlatoonAI.lua'
local ThisFile = '/maps/X1CA_Coop_006/X1CA_Coop_006_m2rhizaai.lua'
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')

--------
-- Locals
--------
local Rhiza = 2
local Difficulty = ScenarioInfo.Options.Difficulty

---------------
-- Base Managers
---------------
local RhizaM2Base = BaseManager.CreateBaseManager()

function RhizaM2BaseAI()

    ---------------
    -- Rhiza M2 Base
    ---------------
    RhizaM2Base:InitializeDifficultyTables(ArmyBrains[Rhiza], 'M2_Rhiza_Base', 'M2_Rhiza_Base_Marker', 150, {M2_Rhiza_Base = 100})
    RhizaM2Base:StartNonZeroBase({{20, 16, 12}, {17, 14, 10}})

    -- Support factories, spawned a bit later
    ForkThread(function()
        WaitSeconds(1)
        RhizaM2Base:AddBuildGroup('M2_Rhiza_Base_Support_Factories', 100, true)
    end)

    -- Spawn wrecked basee and rebuild it
    RhizaM2Base:SpawnGroupAsWreckage('M2_Wreckage')
    RhizaM2Base:AddBuildGroup('M2_Wreckage', 95)

    RhizaM2Base:SetActive('AirScouting', true)

    RhizaM2BaseAirAttacks()
    RhizaM2BaseLandAttacks()
    RhizaM2BaseNavalAttacks()
    RhizaTransportAttacks()
    CustomBuilders()
end

function CustomBuilders()

    -- ################
    -- LAND PLATOONS #
    -- ################

    local PrebuiltLandTemplate = {
        'PrebuiltLandTemplate',
        'NoPlan',
        { 'ual0303', 1, 60, 'Attack', 'GrowthFormation' },    -- Siege Bots
        { 'xal0203', 1, 60, 'Attack', 'GrowthFormation' },    -- Hover Tanks
        { 'ual0304', 1, 60, 'Attack', 'GrowthFormation' },    -- Heavy Arty
    }
    local PrebuiltLandBuilder = {
        BuilderName = 'PrebuiltLandBuilder',
        PlatoonTemplate = PrebuiltLandTemplate,
        InstanceCount = 20,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = false,
        LocationType = 'M2_Rhiza_Base',
        BuildConditions = {
            { '/lua/editor/BaseManagerBuildConditions.lua', 'BaseActive', {'M2_Rhiza_Base'}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},
        PlatoonData = {
            PatrolChain = 'M2_Rhiza_LandDef_Chain',
            NoFormation = true,
        },
    }
    ArmyBrains[Rhiza]:PBMAddPlatoon( PrebuiltLandBuilder )

    -- ###############
    -- AIR PLATOONS #
    -- ###############
    local AirTemplateTRANSPORTS = {
        'AirTemplateTRANSPORTS',
        'NoPlan',
        { 'uaa0104', 1, 8, 'Attack', 'GrowthFormation' },
    }
    local AirTRANSPORTSbuilder = {
        BuilderName = 'AirTRANSPORTS',
        PlatoonTemplate = AirTemplateTRANSPORTS,
        Priority = 5000,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        BuildConditions = {
            { '/lua/editor/BaseManagerBuildConditions.lua', 'BaseActive', {'M2_Rhiza_Base'}},
            { '/lua/editor/unitcountbuildconditions.lua', 'HaveLessThanUnitsWithCategory', {'default_brain', 4, categories.uaa0104}},
        },
        LocationType = 'M2_Rhiza_Base',
        PlatoonAIFunction = {SPAIFileName, 'TransportPool'},
    }
    ArmyBrains[Rhiza]:PBMAddPlatoon( AirTRANSPORTSbuilder )

    local AirTemplateFIGHTER_TORPEDO_SCOUT = {
        'AirTemplateFIGHTER_TORPEDO_SCOUT',
        'NoPlan',
        { 'uaa0303', 1, 4, 'Attack', 'GrowthFormation' },
        { 'xaa0306', 1, 2, 'Attack', 'GrowthFormation' },
        { 'uaa0204', 1, 4, 'Attack', 'GrowthFormation' },
        { 'xaa0202', 1, 4, 'Attack', 'GrowthFormation' },
        { 'uaa0302', 1, 2, 'Attack', 'GrowthFormation' },
    }
    local Air1Builder = {
        BuilderName = 'Air_AntiAir_and_Torpedo',
        PlatoonTemplate = AirTemplateFIGHTER_TORPEDO_SCOUT,
        Priority = 106,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'M2_Rhiza_Base',
        BuildConditions = {
            { '/lua/editor/BaseManagerBuildConditions.lua', 'BaseActive', {'M2_Rhiza_Base'}},
        },
        PlatoonAIFunction = {ThisFile, 'RhizaNavalAI'},
    }
    ArmyBrains[Rhiza]:PBMAddPlatoon( Air1Builder )

    -- ###############
    -- SEA PLATOONS #
    -- ###############
    local NavalFleettemp1 = {
        'NavalFleettemp1',
        'NoPlan',
        { 'uas0201', 1, 2, 'Attack', 'GrowthFormation' },    -- Destroyers
        { 'uas0202', 1, 2, 'Attack', 'GrowthFormation' },    -- Cruisers
        { 'xas0204', 1, 4, 'Attack', 'GrowthFormation' },    -- Sub Hunters
    }
    local Navy1Builder = {
        BuilderName = 'Navy1Builder',
        PlatoonTemplate = NavalFleettemp1,
        Priority = 115,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'M2_Rhiza_Base',
        BuildConditions = {
            { '/lua/editor/BaseManagerBuildConditions.lua', 'BaseActive', {'M2_Rhiza_Base'}},
        },
        PlatoonAIFunction = {ThisFile, 'RhizaNavalAI'},
    }
    ArmyBrains[Rhiza]:PBMAddPlatoon( Navy1Builder )

    local NavalDefensetemp1 = {
        'NavalDefensetemp1',
        'NoPlan',
        { 'uas0202', 1, 3, 'Attack', 'GrowthFormation' },    -- Cruisers
    }
    local NavyDefenseCruisersBuilder = {
        BuilderName = 'NavyDefenseCruisersBuilder',
        PlatoonTemplate = NavalDefensetemp1,
        InstanceCount = 2,
        Priority = 120,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'M2_Rhiza_Base',
        BuildConditions = {
            { '/lua/editor/BaseManagerBuildConditions.lua', 'BaseActive', {'M2_Rhiza_Base'}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},
        PlatoonData = {
            PatrolChain = 'M2_Rhiza_NavalDef_Chain',
        },
    }
    ArmyBrains[Rhiza]:PBMAddPlatoon( NavyDefenseCruisersBuilder )
end

function RhizaM2BaseAirAttacks()
    local opai = nil
    -----------------------------------
    -- Rhiza M2 Base Op AI - Air Attacks
    -----------------------------------

    -- sends [gunships]
    opai = RhizaM2Base:AddOpAI('AirAttacks', 'M2_RhizaAirAttacks1',
        {
            MasterPlatoonFunction = {ThisFile, 'RhizaAirPlatoonsAI'},
            Priority = 105,
        }
    )
    opai:SetChildQuantity('Gunships', 8)

    -- sends [Heavy Gunships, Gunships, Bombers]
    opai = RhizaM2Base:AddOpAI('AirAttacks', 'M2_RhizaAirAttacks2',
        {
            MasterPlatoonFunction = {ThisFile, 'RhizaAirPlatoonsAI'},
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'HeavyGunships', 'Gunships', 'Bombers'}, 9)
    opai:SetLockingStyle('None')

    -- sends [air superiority, gunships, interceptors]
    opai = RhizaM2Base:AddOpAI('AirAttacks', 'M2_RhizaAirAttacks3',
        {
            MasterPlatoonFunction = {ThisFile, 'RhizaAirPlatoonsAI'},
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'AirSuperiority', 'Gunships', 'Interceptors'}, 12)
    opai:SetLockingStyle('None')

    -- sends [torpedo bombers]
    opai = RhizaM2Base:AddOpAI('AirAttacks', 'M2_RhizaAirAttacks4',
        {
            MasterPlatoonFunction = {ThisFile, 'RhizaNavalAI'},
            Priority = 105,
        }
    )
    opai:SetChildQuantity({'TorpedoBombers'}, 8)

    -- Air Defense
    for i = 1, 2 do
        opai = RhizaM2Base:AddOpAI('AirAttacks', 'M2_RhizaAirDefense1' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M2_Rhiza_AirDef_Chain',
                },
                Priority = 1120,
            }
        )
        opai:SetChildQuantity('AirSuperiority', 8)

        opai = RhizaM2Base:AddOpAI('AirAttacks', 'M2_RhizaAirDefense2' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M2_Rhiza_AirDef_Chain',
                },
                Priority = 110,
            }
        )
        opai:SetChildQuantity('CombatFighters', 8)
    end

    opai = RhizaM2Base:AddOpAI('AirAttacks', 'M2_RhizaAirDefense3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Rhiza_AirDef_Chain',
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('HeavyGunships', 8)

    opai = RhizaM2Base:AddOpAI('AirAttacks', 'M2_RhizaAirDefense4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Rhiza_AirDef_Chain',
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('TorpedoBombers', 8)

end

function RhizaAirPlatoonsAI(platoon)
    local moveNum = false

    while(ArmyBrains[2]:PlatoonExists(platoon)) do

        if(ScenarioInfo.MissionNumber == 2) then

            -- First attack Seraphim and Order
            if(ScenarioInfo.OrderACU and not ScenarioInfo.OrderACU:IsDead()) then
                if(not moveNum) then
                    moveNum = 1
                    IssueStop(platoon:GetPlatoonUnits())
                    IssueClearCommands(platoon:GetPlatoonUnits())
                    ScenarioFramework.PlatoonPatrolChain(platoon, 'M2_Rhiza_AirAttack_1_Chain')
                end
               
            -- Now attack Fletcher
            else -- if(ScenarioInfo.OrderACU:IsDead()) then
                if(not moveNum or moveNum ~= 2) then
                    moveNum = 2
                    IssueStop(platoon:GetPlatoonUnits())
                    IssueClearCommands(platoon:GetPlatoonUnits())
                    ScenarioFramework.PlatoonPatrolChain(platoon, 'M2_Rhiza_AirAttack_Fletcher_Chain')
                end
            end

        elseif(ScenarioInfo.MissionNumber == 3) then
            if(not moveNum or moveNum ~= 3) then
                moveNum = 3
                IssueStop(platoon:GetPlatoonUnits())
                IssueClearCommands(platoon:GetPlatoonUnits())
                ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_Rhiza_AirAttack_Chain')
            end

        end
        WaitSeconds(5)
    end
end

function RhizaM2BaseLandAttacks()
    local opai = nil

    ------------------------------------
    -- Rhiza M2 Base Op AI - Land Attacks
    ------------------------------------

    -- Land Defense
    opai = RhizaM2Base:AddOpAI('BasicLandAttack', 'M2_RhizaLandDefense1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Rhiza_LandDef_Chain',
                NoFormation = true,
            },
            Priority = 200,
        }
    )
    opai:SetChildQuantity('MobileMissiles', 3)

    opai = RhizaM2Base:AddOpAI('BasicLandAttack', 'M2_RhizaLandDefense2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Rhiza_LandDef_Chain',
                NoFormation = true,
            },
            Priority = 200,
        }
    )
    opai:SetChildQuantity('MobileFlak', 3)

    opai = RhizaM2Base:AddOpAI('BasicLandAttack', 'M2_RhizaLandDefense3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Rhiza_LandDef_Chain',
                NoFormation = true,
            },
            Priority = 200,
        }
    )
    opai:SetChildQuantity('HeavyBots', 3)
end

function RhizaM2BaseNavalAttacks()
    local ai = {}
    -------------------------------------
    -- Rhiza M2 Base Op AI - Naval Attacks
    -------------------------------------

    -- sends 20 frigate power
    local opai = RhizaM2Base:AddNavalAI('M2_RhizaNavalAttack1',
        {
            MasterPlatoonFunction = {ThisFile, 'RhizaNavalAI'},
            MaxFrigates = 20,        -- No Cruiser
            MinFrigates = 20,
            Priority = 110,
        }
    )

    for i = 1, 2 do
        ai = {'RhizaNavalAI', 'RhizaNavyToFletcherFirstAI'}
        -- sends 15 frigate power
        opai = RhizaM2Base:AddNavalAI('M2_RhizaNavalAttack2' .. i,
            {
                MasterPlatoonFunction = {ThisFile, ai[i]},
                MaxFrigates = 15,
                MinFrigates = 15,
                Priority = 100,
            }
        )
    end

    -- sends 4 frigate power
    opai = RhizaM2Base:AddNavalAI('M2_RhizaNavalAttack3',
        {
            MasterPlatoonFunction = {ThisFile, 'RhizaNavalAI'},
            MaxFrigates = 4,
            MinFrigates = 4,
            Priority = 110,
        }
    )

    -- sends 20 frigate power (To Fletcher first)
    opai = RhizaM2Base:AddNavalAI('M2_RhizaNaval_ToFletcher_Attack1',
        {
            MasterPlatoonFunction = {ThisFile, 'RhizaNavyToFletcherFirstAI'},
            MaxFrigates = 20,
            MinFrigates = 20,
            Priority = 115,
        }
    )
    opai:SetChildActive('T3', false)
    opai:SetLockingStyle('DeathTimer', {LockTimer = 45})

    -- sends 22 frigate power (mission 3)
    opai = RhizaM2Base:AddNavalAI('M3_RhizaNavalAttack1',
        {
            MasterPlatoonFunction = {ThisFile, 'RhizaNavalAI'},
            MaxFrigates = 22,
            MinFrigates = 22,
            Priority = 110,
        }
    )
    opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 3})

    -- Naval Defense
    opai = RhizaM2Base:AddNavalAI('M2_RhizaNavalDefense1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Rhiza_NavalDef_Chain',
            },
            MaxFrigates = 20,
            MinFrigates = 20,
            Priority = 130,
        }
    )
    opai:SetChildActive('T3', false)

    opai = RhizaM2Base:AddNavalAI('M2_RhizaNavalDefense2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Rhiza_NavalDef_Chain',
            },
            MaxFrigates = 15,
            MinFrigates = 15,
            Priority = 125,
        }
    )

    opai = RhizaM2Base:AddNavalAI('M2_RhizaNavalDefense3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Rhiza_NavalDef_Chain',
            },
            MaxFrigates = 4,
            MinFrigates = 4,
            Priority = 120,
        }
    )
end

function RhizaNavalAI(platoon)
    local moveNum = false

    while(ArmyBrains[2]:PlatoonExists(platoon)) do

        if(ScenarioInfo.MissionNumber == 2) then

            -- First attack Seraphim and Order
            if(ScenarioInfo.OrderACU and not ScenarioInfo.OrderACU:IsDead()) then
                if(not moveNum) then
                    moveNum = 1
                    IssueStop(platoon:GetPlatoonUnits())
                    IssueClearCommands(platoon:GetPlatoonUnits())
                    ScenarioFramework.PlatoonPatrolChain(platoon, 'M2_Rhiza_NavalAttack_Chain')
                end
               
            -- Now attack Fletcher
            else -- if(ScenarioInfo.OrderACU:IsDead()) then
                if(not moveNum or moveNum ~= 2) then
                    moveNum = 2
                    IssueStop(platoon:GetPlatoonUnits())
                    IssueClearCommands(platoon:GetPlatoonUnits())
                    ScenarioFramework.PlatoonPatrolChain(platoon, 'M2_Rhiza_NavalAttack_Fletcher_Chain')
                end
            end

        elseif(ScenarioInfo.MissionNumber == 3) then
            if(not moveNum or moveNum ~= 3) then
                moveNum = 3
                IssueStop(platoon:GetPlatoonUnits())
                IssueClearCommands(platoon:GetPlatoonUnits())
                ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_Rhiza_Naval_Chain')
            end

        end
        WaitSeconds(5)
    end
end

function RhizaNavyToFletcherFirstAI(platoon)
    local moveNum = false

    while(ArmyBrains[2]:PlatoonExists(platoon)) do

        if(ScenarioInfo.MissionNumber == 2) then

            -- First attack Fletcher
            if(ScenarioInfo.FletcherACU and not ScenarioInfo.FletcherACU:IsDead()) then
                if(not moveNum) then
                    moveNum = 1
                    IssueStop(platoon:GetPlatoonUnits())
                    IssueClearCommands(platoon:GetPlatoonUnits())
                    ScenarioFramework.PlatoonPatrolChain(platoon, 'M2_Rhiza_NavalAttack_Fletcher_Chain')
                end
               
            -- Now attack Seraphim/Order
            else -- if(ScenarioInfo.OrderACU:IsDead()) then
                if(not moveNum or moveNum ~= 2) then
                    moveNum = 2
                    IssueStop(platoon:GetPlatoonUnits())
                    IssueClearCommands(platoon:GetPlatoonUnits())
                    ScenarioFramework.PlatoonPatrolChain(platoon, 'M2_Rhiza_NavalAttack_Chain')
                end
            end

        elseif(ScenarioInfo.MissionNumber == 3) then
            if(not moveNum or moveNum ~= 3) then
                moveNum = 3
                IssueStop(platoon:GetPlatoonUnits())
                IssueClearCommands(platoon:GetPlatoonUnits())
                ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_Rhiza_Naval_Chain')
            end

        end
        WaitSeconds(5)
    end
end

function RhizaCaptureControlCenter()

    -- sends engineers
    local opai = RhizaM2Base:AddOpAI('EngineerAttack', 'M2_RhizaEngAttack1',
    {
        MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
        PlatoonData = {
            AttackChain = 'M2_OptionZero_Capture_Chain',
            LandingChain = 'M2_OptionZero_Landing_Chain',
            TransportReturn = 'M2_Rhiza_Base_Marker',
            Categories = {'uec1902'},
        },
        Priority = 1000,
    })
    opai:SetChildActive('T1Transports', false)
    opai:SetChildActive('T2Transports', false)
end

function RhizaTransportAttacks()

    local opai = RhizaM2Base:AddOpAI('BasicLandAttack', 'M2_RhizaTransportAttack1',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain = 'M2_Rhiza_Transport_Attack_Chain',
                LandingChain = 'M2_OptionZero_Landing_Chain',
                TransportReturn = 'M2_Rhiza_Base_Marker',
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity({'HeavyTanks', 'LightTanks'}, 8)
    opai:SetLockingStyle('DeathTimer', {LockTimer = 30})

    opai = RhizaM2Base:AddOpAI('BasicLandAttack', 'M2_RhizaTransportAttack2',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain = 'M2_Rhiza_Transport_Attack_Chain',
                LandingChain = 'M2_OptionZero_Landing_Chain',
                TransportReturn = 'M2_Rhiza_Base_Marker',
            },
            Priority = 140,
        }
    )
    opai:SetChildQuantity({'MobileMissiles', 'LightArtillery'}, 8)
    opai:SetLockingStyle('DeathTimer', {LockTimer = 60})

    opai = RhizaM2Base:AddOpAI('BasicLandAttack', 'M2_RhizaTransportAttack3',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain = 'M2_Rhiza_Transport_Attack_Chain',
                LandingChain = 'M2_OptionZero_Landing_Chain',
                TransportReturn = 'M2_Rhiza_Base_Marker',
            },
            Priority = 160,
        }
    )
    opai:SetChildQuantity({'SiegeBots'}, 4)
    opai:SetLockingStyle('DeathTimer', {LockTimer = 60})
    opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua', 'HaveGreaterThanUnitsWithCategory', {'default_brain', 2, categories.uaa0104})

    -- Mission 3
    for i = 1, 2 do
    opai = RhizaM2Base:AddOpAI('BasicLandAttack', 'M3_RhizaTransportAttack1' .. i,
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain = 'M3_Rhiza_AirAttack_Chain',
                LandingChain = 'M2_OptionZero_Landing_Chain',
                TransportReturn = 'M2_Rhiza_Base_Marker',
            },
            Priority = 140,
        }
    )
    opai:SetChildQuantity({'SiegeBots'}, 6)
    opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumber', {'default_brain', 3})
    end

end

function DisableBase()
    if(RhizaM2Base) then
        RhizaM2Base:BaseActive(false)
    end
end
