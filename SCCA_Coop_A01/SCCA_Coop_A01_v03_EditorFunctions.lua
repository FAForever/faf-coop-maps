#****************************************************************************
#**
#**  File     :  /maps/SCCA_R04/SCCA_Coop_A01_v03_EditorFunctions.lua
#**  Author(s): Greg
#**
#**  Summary  :
#**
#**  Copyright © 2006 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************

##############################################################################################################
# function: LeftoverCleanupBC = BuildCondition   doc = "Please work function docs."
#
# parameter 0: string	aiBrain		= "default_brain"
# parameter 1: string   locationType = "default_location_type"
#
##############################################################################################################

function LeftoverCleanupBC(aiBrain, locationType)
    local pool = aiBrain:GetPlatoonUniquelyNamed(locationType..'_LeftoverUnits')
    if not pool then
        pool = aiBrain:MakePlatoon('', '')
        pool:UniquelyNamePlatoon(locationType..'_LeftoverUnits')
        pool.PlatoonData.AMPlatoons = {locationType..'_LeftoverUnits'}
        pool:SetPartOfAttackForce()
    end
    local numUnits = table.getn(pool:GetPlatoonUnits())
    if numUnits > 3 then
        return true
    else
        return false
    end
end