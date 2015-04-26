#****************************************************************************
#**
#**  File     :  /maps/SCCA_Coop_R06_v01/SCCA_Coop_R06_v01_script.lua
#**  Author(s):  Jessica St. Croix
#**
#**  Summary  :  Custom PBM functions
#**
#**  Copyright © 2006 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************
local OpStrings = import('/maps/SCCA_Coop_R06_v01/SCCA_Coop_R06_v01_strings.lua')
local ScenarioFramework = import('/lua/scenarioframework.lua')

################################################################################
# function: CzarAttack = AddFunction	doc = ""
# 
# parameter 0: string	platoon         = "default_platoon"		
#
################################################################################
function CzarAttack(platoon)
    platoon:AttackTarget(ScenarioInfo.ControlCenter)
end