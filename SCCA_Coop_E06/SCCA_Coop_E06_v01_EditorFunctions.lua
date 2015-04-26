-- ****************************************************************************
-- **
-- **  File     :  /data/maps/SCCA_Coop_E06_v01/SCCA_Coop_E06_v01_EditorFunctions.lua
-- **  Author(s): Dru Staltman
-- **
-- **  Summary  : PBM Editor functions for SCCA_Coop_E06_v01
-- **
-- **  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
-- ****************************************************************************
local AIUtils = import('/lua/ai/aiutilities.lua')
local ScenarioFramework = import('/lua/scenarioframework.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local MainScript = import('/maps/SCCA_Coop_E06_v01/SCCA_Coop_E06_v01_script.lua')

-- #############################################################################################################
-- function: AeonM2NavyMaster = BuildCondition   doc = "Please work function docs."
--
-- parameter 0: string	brain		= "default_brain"		
--
-- #############################################################################################################
function AeonM2NavyMaster(brain)
    local navyPlatoonCount = ScenarioFramework.AMPlatoonCounter(brain, 'Aeon_M2_AM_Navy_Master')
    if navyPlatoonCount >= 2 then
        return true
    else
        return false
    end
end

-- #############################################################################################################
-- function: AeonM2NavyTopChild = BuildCondition   doc = "Please work function docs."
--
-- parameter 0: string	brain		= "default_brain"		
--
-- #############################################################################################################
function AeonM2NavyTopChild(brain)
    local topPlatoonCount = ScenarioFramework.AMPlatoonCounter(brain, 'Aeon_M2_AM_Navy_Top_Child')
    if topPlatoonCount < 1 then
        return true
    else
        return false
    end
end

-- #############################################################################################################
-- function: AeonM2NavyBottomChild = BuildCondition   doc = "Please work function docs."
--
-- parameter 0: string	brain		= "default_brain"		
--
-- #############################################################################################################
function AeonM2NavyBottomChild(brain)
    local bottomPlatoonCount = ScenarioFramework.AMPlatoonCounter(brain, 'Aeon_M2_AM_Navy_Bottom_Child')
    if bottomPlatoonCount < 1 then
        return true
    else
        return false
    end
end

-- #############################################################################################################
-- function: EngineersBC = BuildCondition   doc = "Please work function docs."
--
-- parameter 0: string	brain		= "default_brain"
-- parameter 1: string   area            = "area_name"
--
-- #############################################################################################################
function EngineersBC(brain, area)
    local numEngs = ScenarioFramework.NumCatUnitsInArea(categories.ENGINEER, ScenarioUtils.AreaToRect(area), brain)
    local numFacs = ScenarioFramework.NumCatUnitsInArea(categories.FACTORY, ScenarioUtils.AreaToRect(area), brain)
    if ScenarioInfo.Options.Difficulty == 1 and numEngs < numFacs then
        return true
    elseif ScenarioInfo.Options.Difficulty == 2 and numEngs < ( numFacs * 2 ) then
        return true
    elseif ScenarioInfo.Options.Difficulty == 3 and numEngs < ( numFacs * 3 ) then
        return true
    else
        return false
    end
end

-- #############################################################################################################
-- function: AeonBomberEscort = BuildCondition   doc = "Please work function docs."
--
-- parameter 0: string	brain		= "default_brain"
--
-- #############################################################################################################
function AeonBomberEscort(brain)
    if ScenarioInfo.MissionNumber > 2 or ScenarioInfo.Options.Difficulty >= 1 then
        return true
    else
        return false
    end
end

