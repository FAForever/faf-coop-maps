-- ****************************************************************************
-- **
-- **  File     : /maps/SCCA_Coop_E02/SCCA_Coop_E02_v02_EditorFunctions.lua
-- **  Author(s): David Tomandl
-- **
-- **  Summary  : Editor functions for platoons in Op E2
-- **
-- **  Copyright © 2006 Gas Powered Games, Inc.  All rights reserved.
-- ****************************************************************************
-- local ScenarioFramework = import('/lua/scenarioframework.lua')
-- local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')

-- function: ResetAMVariables = AddFunction   doc = "Reset the AM variables after one gets created"
-- parameter 0: string    platoon        = "default_platoon"
function ResetAMVariables(platoon)
    ScenarioInfo.VarTable['AttackStartLocation'] = false
    ScenarioInfo.VarTable['AttackResearchFacility'] = false
    ScenarioInfo.VarTable['LaunchLandAttack'] = false
    ScenarioInfo.VarTable['LaunchAirAttack'] = false
    ScenarioInfo.VarTable['UseLandRoute1'] = false
    ScenarioInfo.VarTable['UseLandRoute2'] = false
    ScenarioInfo.VarTable['UseLandRoute3'] = false
    ScenarioInfo.VarTable['UseAirRoute'] = false
end
