#****************************************************************************
#**
#**  File     :  /maps/SCCA_A03/SCCA_A03_aeonplan_one.lua
#**  Author(s):  Jessica St. Croix
#**
#**  Summary  :
#**
#**  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************
local AIBuildStructures = import('/lua/ai/aibuildstructures.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')

function EvaluatePlan( brain )
    return 100
end

function ExecutePlan( brain )
    if(not ScenarioInfo.AeonPlanRunOnce) then
        brain:PBMRemoveBuildLocation(nil, 'MAIN')
        brain:PBMAddBuildLocation(ScenarioUtils.MarkerToPosition('Aeon'), 40, 'AeonMainBase')
        brain:PBMAddBuildLocation(ScenarioUtils.MarkerToPosition('Aeon_Naval_Base'), 40, 'AeonNavalBase')
        brain:PBMAddBuildLocation(ScenarioUtils.MarkerToPosition('M1_Aeon_Resource_Island_Main'), 40, 'AeonResourceIsland')
        brain:PBMAddBuildLocation(ScenarioUtils.MarkerToPosition('ArnoldIsland'), 100, 'ArnoldIsland')
        
        AIBuildStructures.CreateBuildingTemplate(brain, 'Aeon', 'M4_DefenseTorpedo_EMPTY')
        AIBuildStructures.AppendBuildingTemplate(brain, 'Aeon', 'M4_DefenseTorpedo_D' .. ScenarioInfo.Options.Difficulty, 'M4_DefenseTorpedo_EMPTY')
        AIBuildStructures.CreateBuildingTemplate(brain, 'Aeon', 'M4_DefenseAir_EMPTY')
        AIBuildStructures.AppendBuildingTemplate(brain, 'Aeon', 'M4_DefenseAir_D' .. ScenarioInfo.Options.Difficulty, 'M4_DefenseAir_EMPTY')
        
        ScenarioInfo.AeonPlanRunOnce = true
    end
end