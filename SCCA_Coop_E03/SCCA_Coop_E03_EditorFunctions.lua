-- ****************************************************************************
-- **
-- **  File     :  /maps/SCCA_Coop_E03/SCCA_Coop_E03_EditorFunctions.lua
-- **  Author(s):  Brian Fricks
-- **
-- **  Summary  :
-- **
-- **  Copyright © 2006 Gas Powered Games, Inc.  All rights reserved.
-- ****************************************************************************
local ScenarioFramework = import('/lua/scenarioframework.lua')
local OpE3Script = import('/maps/SCCA_Coop_E03/SCCA_Coop_E03_script.lua')


-- ############################################################################################################
-- function: SetM4AirStrikeReady         = AddFunction       doc = "timer reset cue"
--
-- parameter 0:    string brain        = "default_brain"
-- parameter 1:    string dataTable    = "default_table"
--
-- ###########################################################################################################
function SetM4AirStrikeReady(brain, dataTable)
    ScenarioInfo.VarTable['M4AirStrikeReady'] = false
    ScenarioFramework.CreateTimerTrigger( OpE3Script.LaunchM4AirStrike, OpE3Script.M4AirRepeatTime() )
end
-- ############################################################################################################
-- function: SetM4NavalStrikeReady       = AddFunction       doc = "timer reset cue"
--
-- parameter 0:    string brain        = "default_brain"
-- parameter 1:    string dataTable    = "default_table"
--
-- ###########################################################################################################
function SetM4NavalStrikeReady(brain, dataTable)
    ScenarioInfo.VarTable['M4NavalStrikeReady'] = false
    ScenarioFramework.CreateTimerTrigger( OpE3Script.LaunchM4NavalStrike, OpE3Script.M4NavalRepeatTime() )
end
