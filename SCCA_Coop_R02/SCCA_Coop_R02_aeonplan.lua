-- ****************************************************************************
-- **
-- **  File     :  /maps/SCCA_Coop_R02/SCCA_Coop_R02_aeonplan.lua
-- **  Author(s):  Grant Roberts
-- **
-- **  Summary  :
-- **
-- **  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
-- ****************************************************************************
local AIBuildStructures = import('/lua/ai/aibuildstructures.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')

function EvaluatePlan( brain )
    return 100
end

function ExecutePlan( brain )
    if( not ScenarioInfo.AeonPlanRunOnce ) then
        brain:PBMRemoveBuildLocation(nil, 'MAIN')
        brain:PBMAddBuildLocation(ScenarioUtils.MarkerToPosition('M2_Aeon_Land_Base'), 40, 'M2AeonLandBase')
        brain:PBMAddBuildLocation(ScenarioUtils.MarkerToPosition('M2_Aeon_Land_Base_Tanks'), 20, 'M2AeonLandBaseTanks')
        brain:PBMAddBuildLocation(ScenarioUtils.MarkerToPosition('M2_Aeon_Land_Base_AntiAir'), 20, 'M2AeonLandBaseAntiAir')
        brain:PBMAddBuildLocation(ScenarioUtils.MarkerToPosition('M2_Aeon_Land_Base_Other'), 20, 'M2AeonLandBaseOther')
--
        brain:PBMAddBuildLocation(ScenarioUtils.MarkerToPosition('M2_Aeon_Naval_Base_NavalFactories'), 80, 'M2AeonNavalFactories')
        brain:PBMAddBuildLocation(ScenarioUtils.MarkerToPosition('M2_Aeon_Naval_Base_LandFactory'), 40, 'M2AeonNavalLandFactory')
--
    -- brain:PBMAddBuildLocation(ScenarioUtils.MarkerToPosition('M3_Aeon_Base_Land'), 40, 'M3AeonBaseLand')
    -- brain:PBMAddBuildLocation(ScenarioUtils.MarkerToPosition('M3_Aeon_Base_Air'), 40, 'M3AeonBaseAir')
        brain:PBMAddBuildLocation(ScenarioUtils.MarkerToPosition('M3_Aeon_Base'), 80, 'M3AeonBase')
        ScenarioInfo.AeonPlanRunOnce = true
    end
end
