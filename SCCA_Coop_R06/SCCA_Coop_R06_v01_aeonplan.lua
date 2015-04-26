-- ****************************************************************************
-- **
-- **  File     :  /maps/SCCA_Coop_R06_v01/SCCA_Coop_R06_v01_aeonplan.lua
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
    if(not ScenarioInfo.AeonPlanRunOnce) then
        brain:PBMRemoveBuildLocation(nil, 'MAIN')        
        brain:PBMAddBuildLocation(ScenarioUtils.MarkerToPosition('AeonBase'), 200, 'AeonBase')
        
        AIBuildStructures.CreateBuildingTemplate(brain, 'Aeon', 'MainBaseStructures_EMPTY')
        AIBuildStructures.AppendBuildingTemplate(brain, 'Aeon', 'MainBaseStructuresPreBuilt_D' .. ScenarioInfo.Options.Difficulty, 'MainBaseStructures_EMPTY')
        AIBuildStructures.AppendBuildingTemplate(brain, 'Aeon', 'MainBaseStructuresPostBuilt_D' .. ScenarioInfo.Options.Difficulty, 'MainBaseStructures_EMPTY')
        
        ScenarioInfo.AeonPlanRunOnce = true
    end
end
