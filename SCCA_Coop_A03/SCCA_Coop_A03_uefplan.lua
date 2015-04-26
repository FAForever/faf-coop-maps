-- ****************************************************************************
-- **
-- **  File     :  /maps/SCCA_Coop_A03/SCCA_Coop_A03_v03_uefplan.lua
-- **  Author(s):  Jessica St. Croix
-- **
-- **  Summary  :
-- **
-- **  Copyright © 2006 Gas Powered Games, Inc.  All rights reserved.
-- ****************************************************************************
local AIBuildStructures = import('/lua/ai/AIBuildStructures.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')

function EvaluatePlan(brain)
    return 100
end

function ExecutePlan(brain)
    if(not ScenarioInfo.UEFPlanRunOnce) then
        brain:PBMRemoveBuildLocation(nil, 'MAIN')        
        brain:PBMAddBuildLocation(ScenarioUtils.MarkerToPosition('UEFNavyBase'), 100, 'UEFNavyBase')
        brain:PBMAddBuildLocation(ScenarioUtils.MarkerToPosition('UEFLandBase'), 100, 'UEFLandBase')
        brain:PBMAddBuildLocation(ScenarioUtils.MarkerToPosition('UEFAirBase'), 100, 'UEFAirBase')
        brain:PBMAddBuildLocation(ScenarioUtils.MarkerToPosition('UEFMainBase'), 200, 'UEFMainBase')
        
        AIBuildStructures.CreateBuildingTemplate(brain, 'UEF', 'LandBase_EMPTY')
        AIBuildStructures.AppendBuildingTemplate(brain, 'UEF', 'LandBasePreBuilt_D' .. ScenarioInfo.Options.Difficulty, 'LandBase_EMPTY')
        AIBuildStructures.AppendBuildingTemplate(brain, 'UEF', 'LandBasePostBuilt_D' .. ScenarioInfo.Options.Difficulty, 'LandBase_EMPTY')
        
        AIBuildStructures.CreateBuildingTemplate(brain, 'UEF', 'NavalBase_EMPTY')
        AIBuildStructures.AppendBuildingTemplate(brain, 'UEF', 'NavalBasePreBuilt_D' .. ScenarioInfo.Options.Difficulty, 'NavalBase_EMPTY')
        AIBuildStructures.AppendBuildingTemplate(brain, 'UEF', 'NavalBasePostBuilt_D' .. ScenarioInfo.Options.Difficulty, 'NavalBase_EMPTY')
        
        AIBuildStructures.CreateBuildingTemplate(brain, 'UEF', 'AirBase_EMPTY')
        AIBuildStructures.AppendBuildingTemplate(brain, 'UEF', 'AirBasePreBuilt_D' .. ScenarioInfo.Options.Difficulty, 'AirBase_EMPTY')
        AIBuildStructures.AppendBuildingTemplate(brain, 'UEF', 'AirBasePostBuilt_D' .. ScenarioInfo.Options.Difficulty, 'AirBase_EMPTY')
        
        AIBuildStructures.CreateBuildingTemplate(brain, 'UEF', 'MainBase_EMPTY')
        AIBuildStructures.AppendBuildingTemplate(brain, 'UEF', 'MainBasePreBuilt_D' .. ScenarioInfo.Options.Difficulty, 'MainBase_EMPTY')
        AIBuildStructures.AppendBuildingTemplate(brain, 'UEF', 'MainBasePostBuilt_D' .. ScenarioInfo.Options.Difficulty, 'MainBase_EMPTY')
        ScenarioInfo.UEFPlanRunOnce = true
    end
end
