-- ****************************************************************************
-- **
-- **  File     :  /maps/SCCA_Coop_R06_v01/SCCA_Coop_R06_v01_uefplan.lua
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
    if(not ScenarioInfo.UEFPlanRunOnce) then
        brain:PBMRemoveBuildLocation(nil, 'MAIN')        
        brain:PBMAddBuildLocation(ScenarioUtils.MarkerToPosition('M2Engineers'), 10, 'M2Engineers')
        brain:PBMAddBuildLocation(ScenarioUtils.MarkerToPosition('UEFBase'), 200, 'UEFBase')
        brain:PBMAddBuildLocation(ScenarioUtils.MarkerToPosition('UEF_Mobile_Fac_Build_Location_Marker'), 100, 'MobileFactories')
        
        AIBuildStructures.CreateBuildingTemplate(brain, 'UEF', 'ControlCenterDefenses_EMPTY')
        AIBuildStructures.AppendBuildingTemplate(brain, 'UEF', 'ControlCenterDefensesPreBuilt_D' .. ScenarioInfo.Options.Difficulty, 'ControlCenterDefenses_EMPTY')
        AIBuildStructures.AppendBuildingTemplate(brain, 'UEF', 'ControlCenterDefensesPostBuilt_D' .. ScenarioInfo.Options.Difficulty, 'ControlCenterDefenses_EMPTY')
        
        AIBuildStructures.CreateBuildingTemplate(brain, 'UEF', 'BaseStructures_EMPTY')
        AIBuildStructures.AppendBuildingTemplate(brain, 'UEF', 'BaseStructuresPreBuilt_D' .. ScenarioInfo.Options.Difficulty, 'BaseStructures_EMPTY')
        AIBuildStructures.AppendBuildingTemplate(brain, 'UEF', 'BaseStructuresPostBuilt_D' .. ScenarioInfo.Options.Difficulty, 'BaseStructures_EMPTY')

        AIBuildStructures.CreateBuildingTemplate(brain, 'UEF', 'M2DefensiveLine_EMPTY')
        AIBuildStructures.AppendBuildingTemplate(brain, 'UEF', 'M2DefensiveLine_D' .. ScenarioInfo.Options.Difficulty, 'M2DefensiveLine_EMPTY')
        
        ScenarioInfo.UEFPlanRunOnce = true
    end
end
