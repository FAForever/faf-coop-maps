-- ****************************************************************************
-- **
-- **  File     :  /maps/SCCA_Coop_R02/SCCA_Coop_R02_cybranplan.lua
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
    if( not ScenarioInfo.CybranPlanRunOnce ) then
        brain:PBMRemoveBuildLocation(nil, 'MAIN')
--[[
        brain:PBMAddBuildLocation(ScenarioUtils.MarkerToPosition('M3_Janus_Base_S'), 40, 'M3JanusBaseS')
        brain:PBMAddBuildLocation(ScenarioUtils.MarkerToPosition('M3_Janus_Base_N'), 80, 'M3JanusBaseN')
        brain:PBMAddBuildLocation(ScenarioUtils.MarkerToPosition('M3_Janus_Transports'), 10, 'M3JanusBaseTransports')
]]--
        brain:PBMAddBuildLocation(ScenarioUtils.MarkerToPosition('M3_Janus_Base'), 80, 'M3JanusBase')
        ScenarioInfo.CybranPlanRunOnce = true
    end
end
