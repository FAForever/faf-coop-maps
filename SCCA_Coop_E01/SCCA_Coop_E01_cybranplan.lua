-- ****************************************************************************
-- **
-- **  File     :  /maps/SCCA_Coop_E01/SCCA_Coop_E01_v04_cybranplan.lua
-- **  Author(s):  Jessica St. Croix
-- **
-- **  Summary  :
-- **
-- **  Copyright © 2006 Gas Powered Games, Inc.  All rights reserved.
-- ****************************************************************************
local AIBuildStructures = import('/lua/ai/aibuildstructures.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')

function EvaluatePlan(brain)
    return 100
end

function ExecutePlan(brain)
    if(not ScenarioInfo.CybranPlanRunOnce) then
        brain:PBMRemoveBuildLocation(nil, 'MAIN')
        brain:PBMAddBuildLocation(ScenarioUtils.MarkerToPosition('Cybran_AirBase'), 100, 'Cybran_AirBase')
        brain:PBMAddBuildLocation(ScenarioUtils.MarkerToPosition('Defensive_Line'), 40, 'Defensive_Line')
        brain:PBMAddBuildLocation(ScenarioUtils.MarkerToPosition('Power_Base'), 80, 'Power_Base')
        brain:PBMAddBuildLocation(ScenarioUtils.MarkerToPosition('Cybran_MainBase'), 20, 'Cybran_MainBase')
        brain:PBMAddBuildLocation(ScenarioUtils.MarkerToPosition('Cybran_MainBaseResearch'), 20, 'Cybran_MainBaseResearch')

        AIBuildStructures.CreateBuildingTemplate(brain, 'Cybran', 'AirBasePreBuilt')
        AIBuildStructures.AppendBuildingTemplate(brain, 'Cybran', 'AirBasePostBuilt_D' .. ScenarioInfo.Options.Difficulty, 'AirBasePreBuilt')
        
        AIBuildStructures.CreateBuildingTemplate(brain, 'Cybran', 'DefensiveLineStructures_EMPTY')
        AIBuildStructures.AppendBuildingTemplate(brain, 'Cybran', 'DefensiveLineStructures_D' .. ScenarioInfo.Options.Difficulty, 'DefensiveLineStructures_EMPTY')

        AIBuildStructures.CreateBuildingTemplate(brain, 'Cybran', 'PowerBaseStructures_EMPTY')
        AIBuildStructures.AppendBuildingTemplate(brain, 'Cybran', 'PowerBaseStructures', 'PowerBaseStructures_EMPTY')
        
        AIBuildStructures.CreateBuildingTemplate(brain, 'Cybran', 'MainBaseStructures_EMPTY')
        AIBuildStructures.AppendBuildingTemplate(brain, 'Cybran', 'MainBaseStructures_D' .. ScenarioInfo.Options.Difficulty, 'MainBaseStructures_EMPTY')
        
        ScenarioInfo.CybranPlanRunOnce = true
    end
end
