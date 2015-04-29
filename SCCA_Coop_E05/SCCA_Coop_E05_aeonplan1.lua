-- ****************************************************************************
-- **
-- **  File     :  /maps/SCCA_Coop_E05/SCCA_Coop_E05_v01_aeonplan1.lua
-- **  Author(s):  David Tomandl
-- **
-- **  Summary  :
-- **
-- **  Copyright © 2006 Gas Powered Games, Inc.  All rights reserved.
-- ****************************************************************************

function EvaluatePlan( brain )
    return 100
end

function ExecutePlan( brain )
end

--[[
local AIBuildConditions = import('/lua/modules/ai/aibuildconditions.lua')
local AIBuildStructures = import('/lua/modules/ai/aibuildstructures.lua')
local AIBuildUnits = import('/lua/modules/ai/aibuildunits.lua')
local BaseTemplates = import('/lua/modules/basetemplates.lua')
local MapScript = import('/maps/SCCA_Coop_E05/SCCA_Coop_E05_v01_script.lua')
local ScenarioFramework = import('/lua/modules/scenarioframework.lua')
local ScenarioPlatoonAI = import('/lua/modules/ScenarioPlatoonAI.lua')
local ScenarioUtils = import('/lua/ScenarioUtilities.lua')

--------------------------
-- Platoon Build Conditions
--------------------------

------------
-- Platoon AI
------------

local PlayerBaseLocations = {
    ScenarioUtils.MarkerToPosition('Research_Facility_1'),
    ScenarioUtils.MarkerToPosition('Research_Facility_2'),
    ScenarioUtils.MarkerToPosition('Research_Facility_3'),
    ScenarioUtils.MarkerToPosition('Player'),
}

-- ### TARGETTING THINGS
-- These are prioritized lists of targets.  Platoons can be handed these lists so that
-- the units will target whatever is the highest on the list first.
-- This allows the AI programmer to have units attack things in order like power first for instance.
-- The first entries are the first targetted.
local LandGroupDefenseTarget = {
-- categories.AIR * categories.ANTIAIR,
-- categories.AIR,
-- categories.ANTIAIR,
-- categories.MOBILE - categories.COMMAND,
-- categories.ENERGYPRODUCTION - categories.COMMAND,
    categories.ALLUNITS,
}

local AirGroupGroundTarget = {
    categories.ANTIAIR * categories.TECH3,
    categories.ANTIAIR * categories.TECH2,
    categories.ANTIAIR * categories.TECH1,
    categories.COMMAND,
    categories.DEFENSE,
    categories.ENERGYPRODUCTION * categories.TECH3,
    categories.ENERGYPRODUCTION * categories.TECH2,
    categories.ENERGYPRODUCTION * categories.TECH1,
    categories.MASSEXTRACTION,
    categories.ALLUNITS,
}

-- I hand this to platoon AI threads so that I can give the target lists to multiple squads in a platoon
local LandSquadsTarget = {
    { Squad='Attack', TargetList=LandGroupDefenseTarget, },
}

local AirSquadsTarget = {
    { Squad='Attack', TargetList=LandGroupDefenseTarget, },
    { Squad='Artillery', TargetList=AirGroupGroundTarget, },
}

function AeonNukeThread(platoon)
    -- local aiBrain = platoon:GetBrain()
    local platoonUnits = platoon:GetPlatoonUnits()
    -- local data = platoon.PlatoonData
    -- local baseName = data.BaseName
    if not ( table.getn( platoonUnits ) == 1 ) then
        error ( 'Expected one unit in the Aeon Nuke platoon!  Found ', table.getn( platoonUnits ) )
    end

    ScenarioInfo.AeonNuke = platoonUnits[1]
    MapScript.FireAeonNukeInitial()
end

function GenericAttack(platoon)
-- LOG( '*********** EXECUTING NEW GROUP AI **************' )
    platoon.PlatoonData.LocationList = PlayerBaseLocations
    platoon.PlatoonData.High = false
    platoon.PlatoonData.AttackTable = LandSquadsTarget

    platoon:ForkThread( ScenarioPlatoonAI.PlatoonAttackLocationList ) -- , PlayerBaseLocations, false, LandSquadsTarget )
end

-------------------------
-- Platoon Build Callbacks
-------------------------

--------------
-- Platoon List
--------------
local PlatoonList = {

    ---------------
    -- Nuke Building
    ---------------
    {
        PlatoonTemplate = Scenario.Platoons['UEF_Nuke_Silo'],
        InstanceCount = 1,
        Priority = 100,
        BuildConditions = {
            {AIBuildConditions.AIBCTrue, {}}
        },
        LocationType = 'Aeon_Nuke_Base_Location',
        BuildTimeOut = 1800,
        PlatoonType = 'Land',
        RequiresConstruction = false,
        PlatoonAIFunction = AeonNukeThread,
    },

    -------------------
    -- M1 Aeon attackers
    -------------------
    {
        PlatoonTemplate = Scenario.Platoons['UEF_LandAttack1'],
        InstanceCount = 2,
        Priority = 90,
        BuildConditions = {
            {ScenarioFramework.CheckScenarioInfoVarTable, {'M1_CanBuildUEFAttack1'}},
        },
        LocationType = 'Aeon_UEF_Factories',
        BuildTimeOut = 1800,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        PlatoonData = {
            AttackPoints = {
                ScenarioUtils.MarkerToPosition('Research_Facility_1'),
                ScenarioUtils.MarkerToPosition('Research_Facility_2'),
                ScenarioUtils.MarkerToPosition('Research_Facility_3'),
                ScenarioUtils.MarkerToPosition('Player'),
            },
        },
        PlatoonAIFunction = GenericAttack,
    },

    {
        PlatoonTemplate = Scenario.Platoons['UEF_AirAttack1'],
        InstanceCount = 2,
        Priority = 50,
        BuildConditions = {
            {ScenarioFramework.CheckScenarioInfoVarTable, {'M1_CanBuildUEFAttack1'}},
        },
        LocationType = 'Aeon_UEF_Factories',
        BuildTimeOut = 1800,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        PlatoonData = {
            AttackPoints = {
                ScenarioUtils.MarkerToPosition('Research_Facility_1'),
                ScenarioUtils.MarkerToPosition('Research_Facility_2'),
                ScenarioUtils.MarkerToPosition('Research_Facility_3'),
                ScenarioUtils.MarkerToPosition('Player'),
            },
        },
        PlatoonAIFunction = GenericAttack,
    },

    {
        PlatoonTemplate = Scenario.Platoons['UEF_AirAttack2'],
        InstanceCount = 2,
        Priority = 50,
        BuildConditions = {
            {ScenarioFramework.CheckScenarioInfoVarTable, {'M1_CanBuildUEFAttack1'}},
        },
        LocationType = 'Aeon_UEF_Factories',
        BuildTimeOut = 1800,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        PlatoonData = {
            AttackPoints = {
                ScenarioUtils.MarkerToPosition('Research_Facility_1'),
                ScenarioUtils.MarkerToPosition('Research_Facility_2'),
                ScenarioUtils.MarkerToPosition('Research_Facility_3'),
                ScenarioUtils.MarkerToPosition('Player'),
            },
        },
        PlatoonAIFunction = GenericAttack,
    },
    {
        PlatoonTemplate = Scenario.Platoons['UEF_AirAttack3'],
        InstanceCount = 1,
        Priority = 45,
        BuildConditions = {
            {ScenarioFramework.CheckScenarioInfoVarTable, {'M1_CanBuildUEFAttack1'}},
        },
        LocationType = 'Aeon_UEF_Factories',
        BuildTimeOut = 1800,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        PlatoonData = {
            AttackPoints = {
                ScenarioUtils.MarkerToPosition('Research_Facility_1'),
                ScenarioUtils.MarkerToPosition('Research_Facility_2'),
                ScenarioUtils.MarkerToPosition('Research_Facility_3'),
                ScenarioUtils.MarkerToPosition('Player'),
            },
        },
        PlatoonAIFunction = GenericAttack,
    },
    {
        PlatoonTemplate = Scenario.Platoons['UEF_AirAttack4'],
        InstanceCount = 2,
        Priority = 140,
        BuildConditions = {
            {ScenarioFramework.CheckScenarioInfoVarTable, {'M1_CanBuildUEFAttack1'}},
        },
        LocationType = 'Aeon_UEF_Factories',
        BuildTimeOut = 1800,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        PlatoonData = {
            AttackPoints = {
                ScenarioUtils.MarkerToPosition('Research_Facility_1'),
                ScenarioUtils.MarkerToPosition('Research_Facility_2'),
                ScenarioUtils.MarkerToPosition('Research_Facility_3'),
                ScenarioUtils.MarkerToPosition('Player'),
            },
        },
        PlatoonAIFunction = GenericAttack,
    },
    {
        PlatoonTemplate = Scenario.Platoons['Aeon_LandAttack1'],
        InstanceCount = 1,
        Priority = 90,
        BuildConditions = {
        },
        LocationType = 'Aeon_Nuke_Base_Location',
        BuildTimeOut = 1800,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        PlatoonAIFunction = GenericAttack,
    },
    {
        PlatoonTemplate = Scenario.Platoons['Aeon_LandAttack2'],
        InstanceCount = 2,
        Priority = 110,
        BuildConditions = {
        },
        LocationType = 'Aeon_Nuke_Base_Location',
        BuildTimeOut = 1800,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        PlatoonAIFunction = GenericAttack,
    },
    {
        PlatoonTemplate = Scenario.Platoons['Aeon_LandAttack3'],
        InstanceCount = 1,
        Priority = 100,
        BuildConditions = {
        },
        LocationType = 'Aeon_Nuke_Base_Location',
        BuildTimeOut = 1800,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        PlatoonAIFunction = GenericAttack,
    },
    --------------------------
    -- M1 Aeon base maintenance
    --------------------------
    {
        PlatoonTemplate = Scenario.Platoons['Aeon_Engineer'],
        InstanceCount = 3,
        Priority = 100,
        BuildConditions = {
            {AIBuildConditions.AIBCHaveLessThanUnitsWithCategory, {6, categories.ENGINEER}},
        },
        LocationType = 'Aeon_Nuke_Base_Location',
        BuildTimeOut = 600,
        PlatoonType = 'Land',
        RequiresConstruction = true,
    },
    {
        PlatoonTemplate = Scenario.Platoons['Aeon_T2_Engineer'],
        InstanceCount = 3,
        Priority = 100,
        BuildConditions = {
        },
        LocationType = 'Aeon_Nuke_Base_Location',
        -- BuildTimeOut = 600,
        PlatoonType = 'Land',
        RequiresConstruction = false,
    },
    {
        PlatoonTemplate = Scenario.Platoons['Aeon_T3_Engineer'],
        InstanceCount = 2,
        Priority = 100,
        BuildConditions = {
            {ScenarioFramework.CheckScenarioInfoVarTable, {'M1_CanBuildUEFAttack1'}},
        },
        LocationType = 'Aeon_Nuke_Base_Location',
        BuildTimeOut = 600,
        PlatoonType = 'Land',
        RequiresConstruction = false,
        PlatoonData = {
            MaintainBaseTemplate = 'Nuke_Base_Additions_Defense',
        },
        PlatoonAIFunction = ScenarioPlatoonAI.StartBaseEngineerThread,
    },
    {
        PlatoonTemplate = Scenario.Platoons['Aeon_T3_Engineer'],
        InstanceCount = 1,
--    InstanceCount = 2,
        Priority = 110,
        BuildConditions = {
            {ScenarioFramework.CheckScenarioInfoVarTable, {'M1_CanBuildUEFAttack1'}},
            {AIBuildConditions.AIBCHaveLessThanUnitsWithCategory, {4, categories.FACTORY}},
        },
        LocationType = 'Aeon_Nuke_Base_Location',
        BuildTimeOut = 600,
        PlatoonType = 'Land',
        RequiresConstruction = false,
        PlatoonData = {
--        Construction = {
--            BaseTemplate = 'Nuke_Base_Additions_Factories',
--        },
            MaintainBaseTemplate = 'Nuke_Base_Additions_Factories',
        },
        PlatoonAIFunction = ScenarioPlatoonAI.StartBaseEngineerThread,
    },


    -------------------
    -- M2 Aeon Air Base
    -------------------
    {
        PlatoonTemplate = Scenario.Platoons['Aeon_Engineer'],
        InstanceCount = 3,
        Priority = 100,
        BuildConditions = {
            {ScenarioFramework.CheckScenarioInfoVarTable, {'Mission2'}},
            {AIBuildConditions.AIBCHaveLessThanUnitsWithCategoryInArea, {5, categories.ENGINEER, 'Aeon_Air_Base_Area'}},
        },
        LocationType = 'Aeon_Air_Base_Location',
        BuildTimeOut = 600,
        PlatoonType = 'Air',
        RequiresConstruction = true,
    },
    {
        PlatoonTemplate = Scenario.Platoons['Aeon_T2_Engineer'],
        InstanceCount = 3,
        Priority = 100,
        BuildConditions = {
        },
        LocationType = 'Aeon_Air_Base_Location',
        PlatoonType = 'Land',
        RequiresConstruction = false,
    },
    {
        PlatoonTemplate = Scenario.Platoons['Aeon_T1_Air_Factory_Upgrade'],
        InstanceCount = 1,
        Priority = 50,
        BuildConditions = {
        },
        LocationType = 'Aeon_Air_Base_Location',
        PlatoonType = 'Air',
        RequiresConstruction = false,
    },
    {
        PlatoonTemplate = Scenario.Platoons['Aeon_T2_Air_Factory_Upgrade'],
        InstanceCount = 1,
        Priority = 50,
        BuildConditions = {
        },
        LocationType = 'Aeon_Air_Base_Location',
        PlatoonType = 'Air',
        RequiresConstruction = false,
    },
    {
        PlatoonTemplate = Scenario.Platoons['Aeon_T1_Radar_Upgrade'],
        InstanceCount = 1,
        Priority = 50,
        BuildConditions = {
        },
        LocationType = 'Aeon_Air_Base_Location',
        PlatoonType = 'Land',
        RequiresConstruction = false,
    },
    {
        PlatoonTemplate = Scenario.Platoons['Aeon_Mass_Extractor_Upgrade'],
        InstanceCount = 1,
        Priority = 50,
        BuildConditions = {
        },
        LocationType = 'Aeon_Air_Base_Location',
        PlatoonType = 'Land',
        RequiresConstruction = false,
    },
    -- Engineers go from more specialized to less specialized
    {
        PlatoonTemplate = Scenario.Platoons['Aeon_T3_Engineer'],
        InstanceCount = 2,
        Priority = 150,
        BuildConditions = {
            {ScenarioFramework.CheckScenarioInfoVarTable, {'Mission2'}},
            {AIBuildConditions.AIBCHaveLessThanUnitsWithCategoryInArea, {5, categories.MASSPRODUCTION, 'Aeon_Air_Base_Area'}},
        },
        LocationType = 'Aeon_Air_Base_Location',
        PlatoonType = 'Land',
        BuildTimeOut = 1800,
        RequiresConstruction = false,
        PlatoonData = {
            BuildBaseTemplate = 'Aeon_Air_Base_Economy_Mass',
        },
        PlatoonAIFunction = ScenarioPlatoonAI.StartBaseEngineerThread,
    },
    {
        PlatoonTemplate = Scenario.Platoons['Aeon_T3_Engineer'],
        InstanceCount = 2,
        Priority = 150,
        BuildConditions = {
            {ScenarioFramework.CheckScenarioInfoVarTable, {'Mission2'}},
            {AIBuildConditions.AIBCHaveLessThanUnitsWithCategoryInArea, {7, categories.ENERGYPRODUCTION, 'Aeon_Air_Base_Area'}},
        },
        LocationType = 'Aeon_Air_Base_Location',
        PlatoonType = 'Land',
        BuildTimeOut = 1800,
        RequiresConstruction = false,
        PlatoonData = {
            BuildBaseTemplate = 'Aeon_Air_Base_Economy_Energy',
        },
        PlatoonAIFunction = ScenarioPlatoonAI.StartBaseEngineerThread,
    },
    {
        PlatoonTemplate = Scenario.Platoons['Aeon_T3_Engineer'],
        InstanceCount = 1,
        Priority = 140,
        BuildConditions = {
            {ScenarioFramework.CheckScenarioInfoVarTable, {'Mission2'}},
            {AIBuildConditions.AIBCHaveLessThanUnitsWithCategoryInArea, {2, categories.FACTORY, 'Aeon_Air_Base_Area'}},
        },
        LocationType = 'Aeon_Air_Base_Location',
        PlatoonType = 'Land',
        RequiresConstruction = false,
        PlatoonData = {
            BuildBaseTemplate = 'Aeon_Air_Base_Factories',
        },
        PlatoonAIFunction = ScenarioPlatoonAI.StartBaseEngineerThread,
    },
    {
        PlatoonTemplate = Scenario.Platoons['Aeon_T3_Engineer'],
        InstanceCount = 1,
        Priority = 130,
        BuildConditions = {
            {ScenarioFramework.CheckScenarioInfoVarTable, {'Mission2'}},
            {AIBuildConditions.AIBCHaveLessThanUnitsWithCategoryInArea, {4, categories.ENERGYSTORAGE * categories.MASSSTORAGE, 'Aeon_Air_Base_Area'}},
        },
        LocationType = 'Aeon_Air_Base_Location',
        PlatoonType = 'Land',
        RequiresConstruction = false,
        PlatoonData = {
            BuildBaseTemplate = 'Aeon_Air_Base_Economy_Storage',
        },
        PlatoonAIFunction = ScenarioPlatoonAI.StartBaseEngineerThread,
    },
    {
        PlatoonTemplate = Scenario.Platoons['Aeon_T3_Engineer'],
        InstanceCount = 1,
        Priority = 120,
        BuildConditions = {
            {ScenarioFramework.CheckScenarioInfoVarTable, {'Mission2'}},
            {AIBuildConditions.AIBCHaveLessThanUnitsWithCategoryInArea, {10, categories.DEFENSE, 'Aeon_Air_Base_Area'}},
        },
        LocationType = 'Aeon_Air_Base_Location',
        PlatoonType = 'Land',
        RequiresConstruction = false,
        PlatoonData = {
            BuildBaseTemplate = 'Aeon_Air_Base_Defenses',
        },
        PlatoonAIFunction = ScenarioPlatoonAI.StartBaseEngineerThread,
    },
    {
        PlatoonTemplate = Scenario.Platoons['Aeon_T3_Engineer'],
        InstanceCount = 1,
        Priority = 110,
        BuildConditions = {
            {ScenarioFramework.CheckScenarioInfoVarTable, {'Mission2'}},
            {AIBuildConditions.AIBCHaveLessThanUnitsWithCategoryInArea, {1, categories.INTEL, 'Aeon_Air_Base_Area'}},
        },
        LocationType = 'Aeon_Air_Base_Location',
        PlatoonType = 'Land',
        RequiresConstruction = false,
        PlatoonData = {
            BuildBaseTemplate = 'Aeon_Air_Base_Intel',
        },
        PlatoonAIFunction = ScenarioPlatoonAI.StartBaseEngineerThread,
    },
    -- Maintenance engineers
    {
        PlatoonTemplate = Scenario.Platoons['Aeon_T3_Engineer'],
        InstanceCount = 1,
        Priority = 100,
        BuildConditions = {
        },
        LocationType = 'Aeon_Air_Base_Location',
        PlatoonType = 'Land',
        RequiresConstruction = false,
        PlatoonData = {
            BuildBaseTemplate = 'Aeon_Air_Base_Defenses',
            MaintainBaseTemplate = 'Aeon_Air_Base',
        },
        PlatoonAIFunction = ScenarioPlatoonAI.StartBaseEngineerThread,
    },
    {
        PlatoonTemplate = Scenario.Platoons['Aeon_T3_Engineer'],
        InstanceCount = 1,
        Priority = 100,
        BuildConditions = {
        },
        LocationType = 'Aeon_Air_Base_Location',
        PlatoonType = 'Land',
        RequiresConstruction = false,
        PlatoonData = {
            BuildBaseTemplate = 'Aeon_Air_Base_Economy',
            MaintainBaseTemplate = 'Aeon_Air_Base',
        },
        PlatoonAIFunction = ScenarioPlatoonAI.StartBaseEngineerThread,
    },
    -- Attack platoons
    {
        PlatoonTemplate = Scenario.Platoons['Aeon_AirAttack1'],
        InstanceCount = 1,
        Priority = 100,
        BuildConditions = {
            {ScenarioFramework.CheckScenarioInfoVarTable, {'M2_CanBuildAirAttack'}},
        },
        LocationType = 'Aeon_Air_Base_Location',
        BuildTimeOut = 1800,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        PlatoonData = {
            AttackPoints = {
                ScenarioUtils.MarkerToPosition('Research_Facility_1'),
                ScenarioUtils.MarkerToPosition('Research_Facility_2'),
                ScenarioUtils.MarkerToPosition('Research_Facility_3'),
                ScenarioUtils.MarkerToPosition('Player'),
            },
        },
        PlatoonAIFunction = GenericAttack,
    },
    {
        PlatoonTemplate = Scenario.Platoons['Aeon_AirAttack2'],
        InstanceCount = 1,
        Priority = 90,
        BuildConditions = {
            {ScenarioFramework.CheckScenarioInfoVarTable, {'M2_CanBuildAirAttack'}},
        },
        LocationType = 'Aeon_Air_Base_Location',
        BuildTimeOut = 1800,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        PlatoonData = {
            AttackPoints = {
                ScenarioUtils.MarkerToPosition('Research_Facility_1'),
                ScenarioUtils.MarkerToPosition('Research_Facility_2'),
                ScenarioUtils.MarkerToPosition('Research_Facility_3'),
                ScenarioUtils.MarkerToPosition('Player'),
            },
        },
        PlatoonAIFunction = GenericAttack,
    },
    {
        PlatoonTemplate = Scenario.Platoons['Aeon_AirAttack3'],
        InstanceCount = 1,
        Priority = 80,
        BuildConditions = {
            {ScenarioFramework.CheckScenarioInfoVarTable, {'M2_CanBuildAirAttack'}},
        },
        LocationType = 'Aeon_Air_Base_Location',
        BuildTimeOut = 1800,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        PlatoonData = {
            AttackPoints = {
                ScenarioUtils.MarkerToPosition('Research_Facility_1'),
                ScenarioUtils.MarkerToPosition('Research_Facility_2'),
                ScenarioUtils.MarkerToPosition('Research_Facility_3'),
                ScenarioUtils.MarkerToPosition('Player'),
            },
        },
        PlatoonAIFunction = GenericAttack,
    },



    -------------------------
    -- M2 Aeon Land Base South
    -------------------------
    {
        PlatoonTemplate = Scenario.Platoons['Aeon_Engineer'],
        InstanceCount = 3,
        Priority = 100,
        BuildConditions = {
            {ScenarioFramework.CheckScenarioInfoVarTable, {'Mission2'}},
            {AIBuildConditions.AIBCHaveLessThanUnitsWithCategoryInArea, {5, categories.ENGINEER, 'Aeon_Land_Base_South_Area'}},
        },
        LocationType = 'Aeon_Land_Base_South_Location',
        BuildTimeOut = 600,
        PlatoonType = 'Land',
        RequiresConstruction = true,
    },
    {
        PlatoonTemplate = Scenario.Platoons['Aeon_T2_Engineer'],
        InstanceCount = 3,
        Priority = 100,
        BuildConditions = {
        },
        LocationType = 'Aeon_Land_Base_South_Location',
        PlatoonType = 'Land',
        RequiresConstruction = false,
    },
    {
        PlatoonTemplate = Scenario.Platoons['Aeon_T1_Land_Factory_Upgrade'],
        InstanceCount = 1,
        Priority = 50,
        BuildConditions = {
        },
        LocationType = 'Aeon_Land_Base_South_Location',
        PlatoonType = 'Land',
        RequiresConstruction = false,
    },
    {
        PlatoonTemplate = Scenario.Platoons['Aeon_T2_Land_Factory_Upgrade'],
        InstanceCount = 1,
        Priority = 50,
        BuildConditions = {
        },
        LocationType = 'Aeon_Land_Base_South_Location',
        PlatoonType = 'Land',
        RequiresConstruction = false,
    },
    {
        PlatoonTemplate = Scenario.Platoons['Aeon_T1_Radar_Upgrade'],
        InstanceCount = 1,
        Priority = 50,
        BuildConditions = {
        },
        LocationType = 'Aeon_Land_Base_South_Location',
        PlatoonType = 'Land',
        RequiresConstruction = false,
    },
    {
        PlatoonTemplate = Scenario.Platoons['Aeon_Mass_Extractor_Upgrade'],
        InstanceCount = 1,
        Priority = 50,
        BuildConditions = {
        },
        LocationType = 'Aeon_Land_Base_South_Location',
        PlatoonType = 'Land',
        RequiresConstruction = false,
    },
    -- Engineers go from more specialized to less specialized
    {
        PlatoonTemplate = Scenario.Platoons['Aeon_T3_Engineer'],
        InstanceCount = 2,
        Priority = 150,
        BuildConditions = {
            {ScenarioFramework.CheckScenarioInfoVarTable, {'Mission2'}},
            {AIBuildConditions.AIBCHaveLessThanUnitsWithCategoryInArea, {5, categories.MASSPRODUCTION, 'Aeon_Land_Base_South_Area'}},
        },
        LocationType = 'Aeon_Land_Base_South_Location',
        PlatoonType = 'Land',
        BuildTimeOut = 1800,
        RequiresConstruction = false,
        PlatoonData = {
            BuildBaseTemplate = 'Aeon_Land_Base_South_Economy_Mass',
        },
        PlatoonAIFunction = ScenarioPlatoonAI.StartBaseEngineerThread,
    },
    {
        PlatoonTemplate = Scenario.Platoons['Aeon_T3_Engineer'],
        InstanceCount = 2,
        Priority = 150,
        BuildConditions = {
            {ScenarioFramework.CheckScenarioInfoVarTable, {'Mission2'}},
            {AIBuildConditions.AIBCHaveLessThanUnitsWithCategoryInArea, {7, categories.ENERGYPRODUCTION, 'Aeon_Land_Base_South_Area'}},
        },
        LocationType = 'Aeon_Land_Base_South_Location',
        PlatoonType = 'Land',
        BuildTimeOut = 1800,
        RequiresConstruction = false,
        PlatoonData = {
            BuildBaseTemplate = 'Aeon_Land_Base_South_Economy_Energy',
        },
        PlatoonAIFunction = ScenarioPlatoonAI.StartBaseEngineerThread,
    },
    {
        PlatoonTemplate = Scenario.Platoons['Aeon_T3_Engineer'],
        InstanceCount = 1,
        Priority = 140,
        BuildConditions = {
            {ScenarioFramework.CheckScenarioInfoVarTable, {'Mission2'}},
            {AIBuildConditions.AIBCHaveLessThanUnitsWithCategoryInArea, {2, categories.FACTORY, 'Aeon_Land_Base_South_Area'}},
        },
        LocationType = 'Aeon_Land_Base_South_Location',
        PlatoonType = 'Land',
        RequiresConstruction = false,
        PlatoonData = {
            BuildBaseTemplate = 'Aeon_Land_Base_South_Factories',
        },
        PlatoonAIFunction = ScenarioPlatoonAI.StartBaseEngineerThread,
    },
    {
        PlatoonTemplate = Scenario.Platoons['Aeon_T3_Engineer'],
        InstanceCount = 1,
        Priority = 130,
        BuildConditions = {
            {ScenarioFramework.CheckScenarioInfoVarTable, {'Mission2'}},
            {AIBuildConditions.AIBCHaveLessThanUnitsWithCategoryInArea, {4, categories.ENERGYSTORAGE * categories.MASSSTORAGE, 'Aeon_Land_Base_South_Area'}},
        },
        LocationType = 'Aeon_Land_Base_South_Location',
        PlatoonType = 'Land',
        RequiresConstruction = false,
        PlatoonData = {
            BuildBaseTemplate = 'Aeon_Land_Base_South_Economy_Storage',
        },
        PlatoonAIFunction = ScenarioPlatoonAI.StartBaseEngineerThread,
    },
    {
        PlatoonTemplate = Scenario.Platoons['Aeon_T3_Engineer'],
        InstanceCount = 1,
        Priority = 120,
        BuildConditions = {
            {ScenarioFramework.CheckScenarioInfoVarTable, {'Mission2'}},
            {AIBuildConditions.AIBCHaveLessThanUnitsWithCategoryInArea, {10, categories.DEFENSE, 'Aeon_Land_Base_South_Area'}},
        },
        LocationType = 'Aeon_Land_Base_South_Location',
        PlatoonType = 'Land',
        RequiresConstruction = false,
        PlatoonData = {
            BuildBaseTemplate = 'Aeon_Land_Base_South_Defenses',
        },
        PlatoonAIFunction = ScenarioPlatoonAI.StartBaseEngineerThread,
    },
    {
        PlatoonTemplate = Scenario.Platoons['Aeon_T3_Engineer'],
        InstanceCount = 1,
        Priority = 110,
        BuildConditions = {
            {ScenarioFramework.CheckScenarioInfoVarTable, {'Mission2'}},
            {AIBuildConditions.AIBCHaveLessThanUnitsWithCategoryInArea, {1, categories.INTEL, 'Aeon_Land_Base_South_Area'}},
        },
        LocationType = 'Aeon_Land_Base_South_Location',
        PlatoonType = 'Land',
        RequiresConstruction = false,
        PlatoonData = {
            BuildBaseTemplate = 'Aeon_Land_Base_South_Intel',
        },
        PlatoonAIFunction = ScenarioPlatoonAI.StartBaseEngineerThread,
    },
    -- Maintenance engineers
    {
        PlatoonTemplate = Scenario.Platoons['Aeon_T3_Engineer'],
        InstanceCount = 1,
        Priority = 100,
        BuildConditions = {
        },
        LocationType = 'Aeon_Land_Base_South_Location',
        PlatoonType = 'Land',
        RequiresConstruction = false,
        PlatoonData = {
            BuildBaseTemplate = 'Aeon_Land_Base_South_Defenses',
            MaintainBaseTemplate = 'Aeon_Land_Base_South',
        },
        PlatoonAIFunction = ScenarioPlatoonAI.StartBaseEngineerThread,
    },
    {
        PlatoonTemplate = Scenario.Platoons['Aeon_T3_Engineer'],
        InstanceCount = 1,
        Priority = 100,
        BuildConditions = {
        },
        LocationType = 'Aeon_Land_Base_South_Location',
        PlatoonType = 'Land',
        RequiresConstruction = false,
        PlatoonData = {
            BuildBaseTemplate = 'Aeon_Land_Base_South_Economy',
            MaintainBaseTemplate = 'Aeon_Land_Base_South',
        },
        PlatoonAIFunction = ScenarioPlatoonAI.StartBaseEngineerThread,
    },
    -- Attack platoons
    {
        PlatoonTemplate = Scenario.Platoons['Aeon_LandAttack1'],
        InstanceCount = 1,
        Priority = 100,
        BuildConditions = {
            {ScenarioFramework.CheckScenarioInfoVarTable, {'M2_CanBuildLandAttackSouth'}},
        },
        LocationType = 'Aeon_Land_Base_South_Location',
        BuildTimeOut = 1800,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        PlatoonData = {
            AttackPoints = {
                ScenarioUtils.MarkerToPosition('Research_Facility_1'),
                ScenarioUtils.MarkerToPosition('Research_Facility_2'),
                ScenarioUtils.MarkerToPosition('Research_Facility_3'),
                ScenarioUtils.MarkerToPosition('Player'),
            },
        },
        PlatoonAIFunction = GenericAttack,
    },
    {
        PlatoonTemplate = Scenario.Platoons['Aeon_LandAttack2'],
        InstanceCount = 1,
        Priority = 90,
        BuildConditions = {
            {ScenarioFramework.CheckScenarioInfoVarTable, {'M2_CanBuildLandAttackSouth'}},
        },
        LocationType = 'Aeon_Land_Base_South_Location',
        BuildTimeOut = 1800,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        PlatoonData = {
            AttackPoints = {
                ScenarioUtils.MarkerToPosition('Research_Facility_1'),
                ScenarioUtils.MarkerToPosition('Research_Facility_2'),
                ScenarioUtils.MarkerToPosition('Research_Facility_3'),
                ScenarioUtils.MarkerToPosition('Player'),
            },
        },
        PlatoonAIFunction = GenericAttack,
    },
    {
        PlatoonTemplate = Scenario.Platoons['Aeon_LandAttack3'],
        InstanceCount = 1,
        Priority = 80,
        BuildConditions = {
            {ScenarioFramework.CheckScenarioInfoVarTable, {'M2_CanBuildLandAttackSouth'}},
        },
        LocationType = 'Aeon_Land_Base_South_Location',
        BuildTimeOut = 1800,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        PlatoonData = {
            AttackPoints = {
                ScenarioUtils.MarkerToPosition('Research_Facility_1'),
                ScenarioUtils.MarkerToPosition('Research_Facility_2'),
                ScenarioUtils.MarkerToPosition('Research_Facility_3'),
                ScenarioUtils.MarkerToPosition('Player'),
            },
        },
        PlatoonAIFunction = GenericAttack,
    },

    -------------------------
    -- M2 Aeon Land Base North
    -------------------------
    {
        PlatoonTemplate = Scenario.Platoons['Aeon_Engineer'],
        InstanceCount = 3,
        Priority = 100,
        BuildConditions = {
            {ScenarioFramework.CheckScenarioInfoVarTable, {'Mission2'}},
            {AIBuildConditions.AIBCHaveLessThanUnitsWithCategoryInArea, {5, categories.ENGINEER, 'Aeon_Land_Base_North_Area'}},
        },
        LocationType = 'Aeon_Land_Base_North_Location',
        BuildTimeOut = 600,
        PlatoonType = 'Land',
        RequiresConstruction = true,
    },
    {
        PlatoonTemplate = Scenario.Platoons['Aeon_T2_Engineer'],
        InstanceCount = 3,
        Priority = 100,
        BuildConditions = {
        },
        LocationType = 'Aeon_Land_Base_North_Location',
        PlatoonType = 'Land',
        RequiresConstruction = false,
    },
    {
        PlatoonTemplate = Scenario.Platoons['Aeon_T1_Land_Factory_Upgrade'],
        InstanceCount = 1,
        Priority = 50,
        BuildConditions = {
        },
        LocationType = 'Aeon_Land_Base_North_Location',
        PlatoonType = 'Land',
        RequiresConstruction = false,
    },
    {
        PlatoonTemplate = Scenario.Platoons['Aeon_T2_Land_Factory_Upgrade'],
        InstanceCount = 1,
        Priority = 50,
        BuildConditions = {
        },
        LocationType = 'Aeon_Land_Base_North_Location',
        PlatoonType = 'Land',
        RequiresConstruction = false,
    },
    {
        PlatoonTemplate = Scenario.Platoons['Aeon_T1_Radar_Upgrade'],
        InstanceCount = 1,
        Priority = 50,
        BuildConditions = {
        },
        LocationType = 'Aeon_Land_Base_North_Location',
        PlatoonType = 'Land',
        RequiresConstruction = false,
    },
    {
        PlatoonTemplate = Scenario.Platoons['Aeon_Mass_Extractor_Upgrade'],
        InstanceCount = 1,
        Priority = 50,
        BuildConditions = {
        },
        LocationType = 'Aeon_Land_Base_North_Location',
        PlatoonType = 'Land',
        RequiresConstruction = false,
    },
    -- Engineers go from more specialized to less specialized
    {
        PlatoonTemplate = Scenario.Platoons['Aeon_T3_Engineer'],
        InstanceCount = 2,
        Priority = 150,
        BuildConditions = {
            {ScenarioFramework.CheckScenarioInfoVarTable, {'Mission2'}},
            {AIBuildConditions.AIBCHaveLessThanUnitsWithCategoryInArea, {5, categories.MASSPRODUCTION, 'Aeon_Land_Base_North_Area'}},
        },
        LocationType = 'Aeon_Land_Base_North_Location',
        PlatoonType = 'Land',
        BuildTimeOut = 1800,
        RequiresConstruction = false,
        PlatoonData = {
            BuildBaseTemplate = 'Aeon_Land_Base_North_Economy_Mass',
        },
        PlatoonAIFunction = ScenarioPlatoonAI.StartBaseEngineerThread,
    },
    {
        PlatoonTemplate = Scenario.Platoons['Aeon_T3_Engineer'],
        InstanceCount = 2,
        Priority = 150,
        BuildConditions = {
            {ScenarioFramework.CheckScenarioInfoVarTable, {'Mission2'}},
            {AIBuildConditions.AIBCHaveLessThanUnitsWithCategoryInArea, {7, categories.ENERGYPRODUCTION, 'Aeon_Land_Base_North_Area'}},
        },
        LocationType = 'Aeon_Land_Base_North_Location',
        PlatoonType = 'Land',
        BuildTimeOut = 1800,
        RequiresConstruction = false,
        PlatoonData = {
            BuildBaseTemplate = 'Aeon_Land_Base_North_Economy_Energy',
        },
        PlatoonAIFunction = ScenarioPlatoonAI.StartBaseEngineerThread,
    },
    {
        PlatoonTemplate = Scenario.Platoons['Aeon_T3_Engineer'],
        InstanceCount = 1,
        Priority = 140,
        BuildConditions = {
            {ScenarioFramework.CheckScenarioInfoVarTable, {'Mission2'}},
            {AIBuildConditions.AIBCHaveLessThanUnitsWithCategoryInArea, {2, categories.FACTORY, 'Aeon_Land_Base_North_Area'}},
        },
        LocationType = 'Aeon_Land_Base_North_Location',
        PlatoonType = 'Land',
        RequiresConstruction = false,
        PlatoonData = {
            BuildBaseTemplate = 'Aeon_Land_Base_North_Factories',
        },
        PlatoonAIFunction = ScenarioPlatoonAI.StartBaseEngineerThread,
    },
    {
        PlatoonTemplate = Scenario.Platoons['Aeon_T3_Engineer'],
        InstanceCount = 1,
        Priority = 130,
        BuildConditions = {
            {ScenarioFramework.CheckScenarioInfoVarTable, {'Mission2'}},
            {AIBuildConditions.AIBCHaveLessThanUnitsWithCategoryInArea, {4, categories.ENERGYSTORAGE * categories.MASSSTORAGE, 'Aeon_Land_Base_North_Area'}},
        },
        LocationType = 'Aeon_Land_Base_North_Location',
        PlatoonType = 'Land',
        RequiresConstruction = false,
        PlatoonData = {
            BuildBaseTemplate = 'Aeon_Land_Base_North_Economy_Storage',
        },
        PlatoonAIFunction = ScenarioPlatoonAI.StartBaseEngineerThread,
    },
    {
        PlatoonTemplate = Scenario.Platoons['Aeon_T3_Engineer'],
        InstanceCount = 1,
        Priority = 120,
        BuildConditions = {
            {ScenarioFramework.CheckScenarioInfoVarTable, {'Mission2'}},
            {AIBuildConditions.AIBCHaveLessThanUnitsWithCategoryInArea, {10, categories.DEFENSE, 'Aeon_Land_Base_North_Area'}},
        },
        LocationType = 'Aeon_Land_Base_North_Location',
        PlatoonType = 'Land',
        RequiresConstruction = false,
        PlatoonData = {
            BuildBaseTemplate = 'Aeon_Land_Base_North_Defenses',
        },
        PlatoonAIFunction = ScenarioPlatoonAI.StartBaseEngineerThread,
    },
    {
        PlatoonTemplate = Scenario.Platoons['Aeon_T3_Engineer'],
        InstanceCount = 1,
        Priority = 110,
        BuildConditions = {
            {ScenarioFramework.CheckScenarioInfoVarTable, {'Mission2'}},
            {AIBuildConditions.AIBCHaveLessThanUnitsWithCategoryInArea, {1, categories.INTEL, 'Aeon_Land_Base_North_Area'}},
        },
        LocationType = 'Aeon_Land_Base_North_Location',
        PlatoonType = 'Land',
        RequiresConstruction = false,
        PlatoonData = {
            BuildBaseTemplate = 'Aeon_Land_Base_North_Intel',
        },
        PlatoonAIFunction = ScenarioPlatoonAI.StartBaseEngineerThread,
    },
    -- Maintenance engineers
    {
        PlatoonTemplate = Scenario.Platoons['Aeon_T3_Engineer'],
        InstanceCount = 1,
        Priority = 100,
        BuildConditions = {
        },
        LocationType = 'Aeon_Land_Base_North_Location',
        PlatoonType = 'Land',
        RequiresConstruction = false,
        PlatoonData = {
            BuildBaseTemplate = 'Aeon_Land_Base_North_Defenses',
            MaintainBaseTemplate = 'Aeon_Land_Base_North',
        },
        PlatoonAIFunction = ScenarioPlatoonAI.StartBaseEngineerThread,
    },
    {
        PlatoonTemplate = Scenario.Platoons['Aeon_T3_Engineer'],
        InstanceCount = 1,
        Priority = 100,
        BuildConditions = {
        },
        LocationType = 'Aeon_Land_Base_North_Location',
        PlatoonType = 'Land',
        RequiresConstruction = false,
        PlatoonData = {
            BuildBaseTemplate = 'Aeon_Land_Base_North_Economy',
            MaintainBaseTemplate = 'Aeon_Land_Base_North',
        },
        PlatoonAIFunction = ScenarioPlatoonAI.StartBaseEngineerThread,
    },
    -- Attack platoons
    {
        PlatoonTemplate = Scenario.Platoons['Aeon_LandAttack1'],
        InstanceCount = 1,
        Priority = 100,
        BuildConditions = {
            {ScenarioFramework.CheckScenarioInfoVarTable, {'M2_CanBuildLandAttackNorth'}},
        },
        LocationType = 'Aeon_Land_Base_North_Location',
        BuildTimeOut = 1800,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        PlatoonData = {
            AttackPoints = {
                ScenarioUtils.MarkerToPosition('Research_Facility_1'),
                ScenarioUtils.MarkerToPosition('Research_Facility_2'),
                ScenarioUtils.MarkerToPosition('Research_Facility_3'),
                ScenarioUtils.MarkerToPosition('Player'),
            },
        },
        PlatoonAIFunction = GenericAttack,
    },
    {
        PlatoonTemplate = Scenario.Platoons['Aeon_LandAttack2'],
        InstanceCount = 1,
        Priority = 90,
        BuildConditions = {
            {ScenarioFramework.CheckScenarioInfoVarTable, {'M2_CanBuildLandAttackNorth'}},
        },
        LocationType = 'Aeon_Land_Base_North_Location',
        BuildTimeOut = 1800,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        PlatoonData = {
            AttackPoints = {
                ScenarioUtils.MarkerToPosition('Research_Facility_1'),
                ScenarioUtils.MarkerToPosition('Research_Facility_2'),
                ScenarioUtils.MarkerToPosition('Research_Facility_3'),
                ScenarioUtils.MarkerToPosition('Player'),
            },
        },
        PlatoonAIFunction = GenericAttack,
    },
    {
        PlatoonTemplate = Scenario.Platoons['Aeon_LandAttack3'],
        InstanceCount = 1,
        Priority = 80,
        BuildConditions = {
            {ScenarioFramework.CheckScenarioInfoVarTable, {'M2_CanBuildLandAttackNorth'}},
        },
        LocationType = 'Aeon_Land_Base_North_Location',
        BuildTimeOut = 1800,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        PlatoonData = {
            AttackPoints = {
                ScenarioUtils.MarkerToPosition('Research_Facility_1'),
                ScenarioUtils.MarkerToPosition('Research_Facility_2'),
                ScenarioUtils.MarkerToPosition('Research_Facility_3'),
                ScenarioUtils.MarkerToPosition('Player'),
            },
        },
        PlatoonAIFunction = GenericAttack,
    },



-- # --------
-- # Air Base
-- # --------
-- {
--    PlatoonTemplate = PlatoonTemplates.Engineer,
--    InstanceCount = 2,
--    Priority = 100,
--    BuildConditions = {},
--    LocationType = 'M1_Airbase',
--    BuildTimeOut = 600,
--    PlatoonType = 'Air',
--    RequiresConstruction = true,
--    PlatoonData = {
--        Construction = {
--            BaseTemplate = 'M1_AIR_BASE',
--            BuildingTemplate = BaseTemplates.BuildingTemplates[3],
--            BuildClose = true,
--            BuildRelative = false,
--            BuildSpecificTemplates = true,
--            BuildStructures = {
--                'T1MassCreation',
--                'T1MassCreation',
--                'MassStorage',
--                'MassStorage',
--                'EnergyStorage',
--                'EnergyStorage',
--                'EnergyStorage',
--                'EnergyStorage',
--            },
--        },
--        BaseName = 'M1_AIR_BASE',
--        TechLevel = 2,
--        Template = BaseTemplates.BuildingTemplates[3],
--    },
--    PlatoonAIFunction = ScenarioPlatoonAI.StartBaseEngineerThread,
-- },
-- {
--    PlatoonTemplate = PlatoonTemplates.AirAttack,
--    Priority = 90,
--    BuildConditions = {
--        {ScenarioFramework.CheckScenarioInfoVarTable, {'M1_CanBuildAirAttack'}},
--    },
--    LocationType = 'M1_Airbase',
--    BuildTimeOut = 1800,
--    PlatoonType = 'Air',
--    RequiresConstruction = true,
--    PlatoonAIFunction = ScenarioPlatoonAI.PlatoonAttackHighestThreat,
-- },
--
-- # ------------
-- # Land Base #1
-- # ------------
-- {
--    PlatoonTemplate = PlatoonTemplates.Engineer,
--    InstanceCount = 2,
--    Priority = 100,
--    BuildConditions = {},
--    LocationType = 'M1_Landbase1',
--    BuildTimeOut = 600,
--    PlatoonType = 'Land',
--    RequiresConstruction = true,
--    PlatoonData = {
--        Construction = {
--            BaseTemplate = 'M1_LAND_BASE_1',
--            BuildingTemplate = BaseTemplates.BuildingTemplates[3],
--            BuildClose = true,
--            BuildRelative = false,
--            BuildSpecificTemplates = true,
--            BuildStructures = {
--                'T2AirFactory',
--                'T1MassCreation',
--                'T1MassCreation',
--                'MassStorage',
--                'MassStorage',
--                'EnergyStorage',
--                'EnergyStorage',
--                'EnergyStorage',
--                'EnergyStorage',
--            },
--        },
--        BaseName = 'M1_LAND_BASE_1',
--        TechLevel = 2,
--        Template = BaseTemplates.BuildingTemplates[3],
--    },
--    PlatoonAIFunction = ScenarioPlatoonAI.StartBaseEngineerThread,
-- },
-- {
--    PlatoonTemplate = PlatoonTemplates.Transport,
--    Priority = 90,
--    BuildConditions = {
--        {AIBuildConditions.AIBCHaveLessThanUnitsWithCategory, {8, categories.TRANSPORTATION}},
--        {ScenarioFramework.CheckScenarioInfoVarTable, {'M1_CanBuildLand1Attack'}},
--    },
--    LocationType = 'M1_Landbase1',
--    BuildTimeOut = 600,
--    PlatoonType = 'Air',
--    RequiresConstruction = true,
--    PlatoonAIFunction = ScenarioPlatoonAI.TransportPool,
-- },
-- {
--    PlatoonTemplate = PlatoonTemplates.LandAttack,
--    Priority = 90,
--    BuildConditions = {
--        {ScenarioFramework.CheckScenarioInfoVarTable, {'M1_CanBuildLand1Attack'}},
--    },
--    LocationType = 'M1_Landbase1',
--    BuildTimeOut = 1800,
--    PlatoonType = 'Land',
--    RequiresConstruction = true,
--    PlatoonData = {
--        AttackPoints = {
--            ScenarioUtils.MarkerToPosition('M1_LANDING1'),
--            ScenarioUtils.MarkerToPosition('M1_LANDING2'),
--            ScenarioUtils.MarkerToPosition('M1_LANDING3'),
--            ScenarioUtils.MarkerToPosition('M1_LANDING4'),
--            ScenarioUtils.MarkerToPosition('M1_LANDING5'),
--            ScenarioUtils.MarkerToPosition('M1_ATTACK1'),
--            ScenarioUtils.MarkerToPosition('M1_ATTACK2'),
--        },
--        LandingList = {
--            ScenarioUtils.MarkerToPosition('M1_LANDING1'),
--            ScenarioUtils.MarkerToPosition('M1_LANDING2'),
--            ScenarioUtils.MarkerToPosition('M1_LANDING3'),
--            ScenarioUtils.MarkerToPosition('M1_LANDING4'),
--            ScenarioUtils.MarkerToPosition('M1_LANDING5'),
--        },
--        NumTransports = 3,
--        TransportReturn = ScenarioUtils.MarkerToPosition('M1_LAND_BASE1')
--    },
--    PlatoonAIFunction = ScenarioPlatoonAI.LandAssaultWithTransports,
-- },
-- {
--    PlatoonTemplate = PlatoonTemplates.Amphibious,
--    Priority = 85,
--    BuildConditions = {
--        {ScenarioFramework.CheckScenarioInfoVarTable, {'M1_CanBuildLand1Attack'}},
--    },
--    LocationType = 'M1_Landbase1',
--    BuildTimeOut = 1800,
--    PlatoonType = 'Land',
--    RequiresConstruction = true,
--    PlatoonAiFunction = ScenarioPlatoonAI.PlatoonAttackHighestThreat,
-- },
--
-- # ------------
-- # Land Base #2
-- # ------------
-- {
--    PlatoonTemplate = PlatoonTemplates.Engineer,
--    InstanceCount = 2,
--    Priority = 100,
--    BuildConditions = {},
--    LocationType = 'M1_Landbase2',
--    BuildTimeOut = 600,
--    PlatoonType = 'Land',
--    RequiresConstruction = true,
--    PlatoonData = {
--        Construction = {
--            BaseTemplate = 'M1_LAND_BASE_2',
--            BuildingTemplate = BaseTemplates.BuildingTemplates[3],
--            BuildClose = true,
--            BuildRelative = false,
--            BuildSpecificTemplates = true,
--            BuildStructures = {
--                'T2AirFactory',
--                'T1MassCreation',
--                'T1MassCreation',
--                'MassStorage',
--                'MassStorage',
--                'EnergyStorage',
--                'EnergyStorage',
--                'EnergyStorage',
--                'EnergyStorage',
--            },
--        },
--        BaseName = 'M1_LAND_BASE_2',
--        TechLevel = 2,
--        Template = BaseTemplates.BuildingTemplates[3],
--    },
--    PlatoonAIFunction = ScenarioPlatoonAI.StartBaseEngineerThread,
-- },
-- {
--    PlatoonTemplate = PlatoonTemplates.Transport,
--    Priority = 90,
--    BuildConditions = {
--        {AIBuildConditions.AIBCHaveLessThanUnitsWithCategory, {8, categories.TRANSPORTATION}},
--        {ScenarioFramework.CheckScenarioInfoVarTable, {'M1_CanBuildLand2Attack'}},
--    },
--    LocationType = 'M1_Landbase2',
--    BuildTimeOut = 600,
--    PlatoonType = 'Air',
--    RequiresConstruction = true,
--    PlatoonAIFunction = ScenarioPlatoonAI.TransportPool,
-- },
-- {
--    PlatoonTemplate = PlatoonTemplates.LandAttack,
--    Priority = 90,
--    BuildConditions = {
--        {ScenarioFramework.CheckScenarioInfoVarTable, {'M1_CanBuildLand2Attack'}},
--    },
--    LocationType = 'M1_Landbase2',
--    BuildTimeOut = 1800,
--    PlatoonType = 'Land',
--    RequiresConstruction = true,
--    PlatoonData = {
--        AttackPoints = {
--            ScenarioUtils.MarkerToPosition('M1_LANDING1'),
--            ScenarioUtils.MarkerToPosition('M1_LANDING2'),
--            ScenarioUtils.MarkerToPosition('M1_LANDING3'),
--            ScenarioUtils.MarkerToPosition('M1_LANDING4'),
--            ScenarioUtils.MarkerToPosition('M1_LANDING5'),
--            ScenarioUtils.MarkerToPosition('M1_ATTACK1'),
--            ScenarioUtils.MarkerToPosition('M1_ATTACK2'),
--        },
--        LandingList = {
--            ScenarioUtils.MarkerToPosition('M1_LANDING1'),
--            ScenarioUtils.MarkerToPosition('M1_LANDING2'),
--            ScenarioUtils.MarkerToPosition('M1_LANDING3'),
--            ScenarioUtils.MarkerToPosition('M1_LANDING4'),
--            ScenarioUtils.MarkerToPosition('M1_LANDING5'),
--        },
--        NumTransports = 3,
--        TransportReturn = ScenarioUtils.MarkerToPosition('M1_LAND_BASE2')
--    },
--    PlatoonAIFunction = ScenarioPlatoonAI.LandAssaultWithTransports,
-- },
-- {
--    PlatoonTemplate = PlatoonTemplates.Amphibious,
--    Priority = 85,
--    BuildConditions = {
--        {ScenarioFramework.CheckScenarioInfoVarTable, {'M1_CanBuildLand2Attack'}},
--    },
--    LocationType = 'M1_Landbase2',
--    BuildTimeOut = 1800,
--    PlatoonType = 'Land',
--    RequiresConstruction = true,
--    PlatoonAiFunction = ScenarioPlatoonAI.PlatoonAttackHighestThreat,
-- },
}

function EvaluatePlan(brain)
    if(ScenarioInfo.MissionState == 1) then
        return 100
    else
        return 0
    end
end

function ExecutePlan(brain)
    if(not brain:PBMHasPlatoonList()) then
--         brain:PBMSetCheckInterval(47)

        brain:PBMRemoveBuildLocation(nil, 'MAIN')

        local NukeBasePosition = ScenarioUtils.MarkerToPosition('Neutral_Nuke_Base')
        local CapturedUEFFactories = ScenarioUtils.MarkerToPosition('Neutral_UEF_Factories')
        local Aeon_Land_Base_North = ScenarioUtils.MarkerToPosition('Aeon_Land_Base_North')
        local Aeon_Land_Base_South = ScenarioUtils.MarkerToPosition('Aeon_Land_Base_South')
        local Aeon_Air_Base = ScenarioUtils.MarkerToPosition('Aeon_Air_Base')

        brain:PBMAddBuildLocation(NukeBasePosition, 40, 'Aeon_Nuke_Base_Location')
        brain:PBMAddBuildLocation(CapturedUEFFactories, 40, 'Aeon_UEF_Factories')
        brain:PBMAddBuildLocation(Aeon_Land_Base_North, 100, 'Aeon_Land_Base_North_Location')
        brain:PBMAddBuildLocation(Aeon_Land_Base_South, 100, 'Aeon_Land_Base_South_Location')
        brain:PBMAddBuildLocation(Aeon_Air_Base, 100, 'Aeon_Air_Base_Location')

        AIBuildStructures.CreateBuildingTemplate(brain, 'Aeon', 'Nuke_Base_Additions_Factories')
        AIBuildStructures.CreateBuildingTemplate(brain, 'Aeon', 'Nuke_Base_Additions_Defense')

        AIBuildStructures.CreateBuildingTemplate(brain, 'Aeon', 'Aeon_Air_Base')
        AIBuildStructures.CreateBuildingTemplate(brain, 'Aeon', 'Aeon_Air_Base_Defenses')
        AIBuildStructures.CreateBuildingTemplate(brain, 'Aeon', 'Aeon_Air_Base_Economy')
        AIBuildStructures.CreateBuildingTemplate(brain, 'Aeon', 'Aeon_Air_Base_Economy_Energy')
        AIBuildStructures.CreateBuildingTemplate(brain, 'Aeon', 'Aeon_Air_Base_Economy_Mass')
        AIBuildStructures.CreateBuildingTemplate(brain, 'Aeon', 'Aeon_Air_Base_Economy_Storage')
        AIBuildStructures.CreateBuildingTemplate(brain, 'Aeon', 'Aeon_Air_Base_Factories')
        AIBuildStructures.CreateBuildingTemplate(brain, 'Aeon', 'Aeon_Air_Base_Intel')

        AIBuildStructures.CreateBuildingTemplate(brain, 'Aeon', 'Aeon_Land_Base_South')
        AIBuildStructures.CreateBuildingTemplate(brain, 'Aeon', 'Aeon_Land_Base_South_Defenses')
        AIBuildStructures.CreateBuildingTemplate(brain, 'Aeon', 'Aeon_Land_Base_South_Economy')
        AIBuildStructures.CreateBuildingTemplate(brain, 'Aeon', 'Aeon_Land_Base_South_Economy_Energy')
        AIBuildStructures.CreateBuildingTemplate(brain, 'Aeon', 'Aeon_Land_Base_South_Economy_Mass')
        AIBuildStructures.CreateBuildingTemplate(brain, 'Aeon', 'Aeon_Land_Base_South_Economy_Storage')
        AIBuildStructures.CreateBuildingTemplate(brain, 'Aeon', 'Aeon_Land_Base_South_Factories')
        AIBuildStructures.CreateBuildingTemplate(brain, 'Aeon', 'Aeon_Land_Base_South_Intel')

        AIBuildStructures.CreateBuildingTemplate(brain, 'Aeon', 'Aeon_Land_Base_North')
        AIBuildStructures.CreateBuildingTemplate(brain, 'Aeon', 'Aeon_Land_Base_North_Defenses')
        AIBuildStructures.CreateBuildingTemplate(brain, 'Aeon', 'Aeon_Land_Base_North_Economy')
        AIBuildStructures.CreateBuildingTemplate(brain, 'Aeon', 'Aeon_Land_Base_North_Economy_Energy')
        AIBuildStructures.CreateBuildingTemplate(brain, 'Aeon', 'Aeon_Land_Base_North_Economy_Mass')
        AIBuildStructures.CreateBuildingTemplate(brain, 'Aeon', 'Aeon_Land_Base_North_Economy_Storage')
        AIBuildStructures.CreateBuildingTemplate(brain, 'Aeon', 'Aeon_Land_Base_North_Factories')
        AIBuildStructures.CreateBuildingTemplate(brain, 'Aeon', 'Aeon_Land_Base_North_Intel')

        AIBuildUnits.AIExecutePlanUnitListTwo(brain, PlatoonList)
    end

-- UpgradeStructures(brain)
end

-- function LandPicker(platoon)
-- ScenarioFramework.CreateTimerTrigger( LandUnpause, LandPauseTimer )
-- if ScenarioInfo.SymbiotSuccess then
--    platoon:Patrol( ScenarioUtils.MarkerToPosition('WestDefense') )
--    LandFork(platoon)
-- else
--    LandFork(platoon)
--    platoon:ForkThread( ScenarioPlatoonAI.AttackLocationList, PlayerBaseLocations, false, AirSquadsTarget )
-- end
-- end


-- function UpgradeStructures(brain)
-- local available = ScenarioFramework.GetFactories(brain)
-- for k, v in available.T1Land do
--    ScenarioFramework.UpgradeUnit(v)
-- end
-- for k, v in available.T1Air do
--    ScenarioFramework.UpgradeUnit(v)
-- end
-- for k, v in available.T1Naval do
--    ScenarioFramework.UpgradeUnit(v)
-- end
-- end
]]--
