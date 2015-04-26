#****************************************************************************
#**
#**  File     :  /data/maps/SCCA_R04/SCCA_R04_EditorFunctions.lua
#**  Author(s): Dru Staltman
#**
#**  Summary  : PBM Editor functions for SCCA_R04
#**
#**  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************
local AIUtils = import('/lua/ai/aiutilities.lua')
local ScenarioFramework = import('/lua/scenarioframework.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local OpStrings = import('/maps/SCCA_Coop_A04_v04/SCCA_Coop_A04_v04_strings.lua')

##############################################################################################################
# function: CruiserBlockade = AddFunction   doc = "Please work function docs."
# 
# parameter 0: string	platoon		= "default_platoon"
#
##############################################################################################################
function CruiserBlockade(platoon)
    platoon:MoveToLocation(ScenarioUtils.MarkerToPosition('Cybran_M1_Cruiser_Blockade_Marker'), false)
end

##############################################################################################################
# function: DestroyerBlockade = AddFunction     doc = "Please work function docs."
# 
# parameter 0: string	platoon		= "default_platoon"
#
##############################################################################################################
function DestroyerBlockade(platoon)
    platoon:MoveToLocation(ScenarioUtils.MarkerToPosition('Cybran_M1_Destroyer_Blockade_Marker'), false)
end

##############################################################################################################
# function: M1NavalFleet = AddFunction     doc = "Please work function docs."
# 
# parameter 0: string	platoon		= "default_platoon"
#
##############################################################################################################
function M1NavalFleet(platoon)
    local aiBrain = platoon:GetBrain()
    if not ScenarioInfo.M1NavalBaseAttacked then
        platoon:Stop()
        ScenarioFramework.PlatoonPatrolChain( platoon, 'Cybran_M1_Naval_Patrol_Chain' )
        while aiBrain:PlatoonExists(platoon) and 
              not ScenarioInfo.M1NavalBaseAttacked and ScenarioInfo.MissionNumber ~= 2 do
            WaitSeconds(5)
        end
    end
    platoon:Stop()
    ScenarioFramework.PlatoonAttackChain( platoon, 'Cybran_M1_Naval_Attack_Chain' )
end

##############################################################################################################
# function: CybranM1Attack = AddFunction     doc = "Please work function docs."
# 
# parameter 0: string	platoon		= "default_platoon"
#
##############################################################################################################
function CybranM1Attack(platoon)
    if not ScenarioInfo.M1CybranAttackBool then
        ScenarioInfo.M1CybranAttackBool = true
        ScenarioFramework.Dialogue(OpStrings.A04_M01_050)
    end
end