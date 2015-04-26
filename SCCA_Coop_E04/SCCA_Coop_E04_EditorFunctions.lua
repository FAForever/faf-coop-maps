-- ****************************************************************************
-- **
-- **  File     :  /maps/SCCA_Coop_E04/SCCA_Coop_E04_v03_EditorFunctions.lua
-- **  Author(s):  Matt Mahon
-- **
-- **  Summary  :
-- **
-- **  Copyright © 2006 Gas Powered Games, Inc.  All rights reserved.
-- ****************************************************************************
local ScenarioFramework = import('/lua/scenarioframework.lua')
local OpScript = import('/maps/SCCA_Coop_E04/SCCA_Coop_E04_v03_script.lua')


-- ############################################################################################################
-- function: StartM1AirStrikeTimer         = AddFunction       doc = "timer reset cue"
--
-- parameter 0:    string brain        = "default_brain"
--
-- ###########################################################################################################
function StartM1AirStrikeTimer(brain)
    OpScript.M1StartAirAttackTimer()
end

-- ############################################################################################################
-- function: StartM1TankStrikeTimer         = AddFunction       doc = "timer reset cue"
--
-- parameter 0:    string brain        = "default_brain"
--
-- ###########################################################################################################
function StartM1TankStrikeTimer(brain)
    OpScript.M1StartTankAttackTimer()
end

-- ############################################################################################################
-- function: StartM2AirStrikeTimer         = AddFunction       doc = "timer reset cue"
--
-- parameter 0:    string brain        = "default_brain"
--
-- ###########################################################################################################
function StartM2AirStrikeTimer(brain)
    OpScript.M2StartAirAttackTimer()
end

-- ############################################################################################################
-- function: StartM2TankStrikeTimer         = AddFunction       doc = "timer reset cue"
--
-- parameter 0:    string brain        = "default_brain"
--
-- ###########################################################################################################
function StartM2TankStrikeTimer(brain)
    OpScript.M2StartTankAttackTimer()
end

-- ############################################################################################################
-- function: StartM2GunshipStrikeTimer         = AddFunction       doc = "timer reset cue"
--
-- parameter 0:    string brain        = "default_brain"
--
-- ###########################################################################################################
function StartM2GunshipStrikeTimer(brain)
    OpScript.M2StartGunshipAttackTimer()
end

-- ############################################################################################################
-- function: StartM2TorpedoPlaneTimer         = AddFunction       doc = "timer reset cue"
--
-- parameter 0:    string brain        = "default_brain"
--
-- ###########################################################################################################
function StartM2TorpedoPlaneTimer(brain)
    OpScript.M2StartTorpedoPlaneTimer()
end

-- *********************TEST STUFF **************************

