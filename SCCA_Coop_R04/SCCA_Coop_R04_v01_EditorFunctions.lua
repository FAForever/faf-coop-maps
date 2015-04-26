-- ****************************************************************************
-- **
-- **  File     :  /maps/SCCA_Coop_R04_v01/SCCA_Coop_R04_v01_EditorFunctions.lua
-- **  Author(s):  David Tomandl
-- **
-- **  Summary  :  This is a set of functions for the platoon builder, used in
-- **              operation R4.
-- **
-- **  Copyright © 2006 Gas Powered Games, Inc.  All rights reserved.
-- ****************************************************************************

-- local OpScript = import ('/maps/SCCA_Coop_R04_v01/SCCA_Coop_R04_v01_script.lua')

-- #############################################################################################################
-- function: ResetAMVariables = AddFunction   doc = "Reset the AM variables after one gets created"
--
-- parameter 0: string	platoon		= "default_platoon"
--
-- #############################################################################################################
function ResetAMVariables(platoon)
    ScenarioInfo.VarTable['AttackBase1'] = false
    ScenarioInfo.VarTable['AttackBase2'] = false
    ScenarioInfo.VarTable['LaunchLandAttack'] = false
    ScenarioInfo.VarTable['LaunchNavalAttack'] = false
    ScenarioInfo.VarTable['LaunchAirAttack'] = false
    ScenarioInfo.VarTable['UseLandRoute1'] = false
    ScenarioInfo.VarTable['UseLandRoute2'] = false
    ScenarioInfo.VarTable['UseAirRoute1'] = false
    ScenarioInfo.VarTable['UseAirRoute2'] = false
end
