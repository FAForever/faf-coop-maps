-- ****************************************************************************
-- **
-- **  File     :  /data/maps/SCCA_E06/SCCA_E06_EditorFunctions.lua
-- **  Author(s): Dru Staltman
-- **
-- **  Summary  : PBM Editor functions for SCCA_E06
-- **
-- **  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
-- ****************************************************************************
local AIUtils = import('/lua/ai/aiutilities.lua')
local ScenarioFramework = import('/lua/scenarioframework.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')

-- #############################################################################################################
-- function: Ariel_M1_Bombers = AddFunction   doc = "Please work function docs."
--
-- parameter 0: string	platoon		= "default_platoon"
--
-- #############################################################################################################
function Ariel_M1_Bombers(platoon)
    local chain = {}
    local aiBrain = platoon:GetBrain()
    if Random(1,2) == 1 then
        chain = ScenarioUtils.ChainToPositions( 'Ariel_M1_Bomber_Route_1_Chain' )
    else
        chain = ScenarioUtils.ChainToPositions( 'Ariel_M1_Bomber_Route_2_Chain' )
    end
    local cmd
    for num,pos in chain do
        cmd = platoon:AggressiveMoveToLocation( pos )
    end
    while aiBrain:PlatoonExists(platoon) and platoon:IsCommandsActive(cmd) do
        WaitSeconds(2)
    end
    ScenarioPlatoonAI.PlatoonAttackHighestThreat( platoon )
end

-- #############################################################################################################
-- function: UEF_M2_Bombers = AddFunction   doc = "Please work function docs."
--
-- parameter 0: string	platoon		= "default_platoon"
--
-- #############################################################################################################
function UEF_M2_Bombers(platoon)
    local chain = {}
    local aiBrain = platoon:GetBrain()
    if Random(1,2) == 1 then
        chain = ScenarioUtils.ChainToPositions( 'UEF_M2_Bomber_Route_Chain_1' )
    else
        chain = ScenarioUtils.ChainToPositions( 'UEF_M2_Bomber_Route_Chain_2' )
    end
    local cmd
    for num,pos in chain do
        cmd = platoon:AggressiveMoveToLocation( pos )
    end
    while aiBrain:PlatoonExists(platoon) and platoon:IsCommandsActive(cmd) do
        WaitSeconds(2)
    end
    ScenarioPlatoonAI.PlatoonAttackHighestThreat( platoon )
end

