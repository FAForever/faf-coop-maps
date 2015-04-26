-- ****************************************************************************
-- **
-- **  File     :  /maps/SCCA_Coop_A06_v03/SCCA_Coop_A06_v03_EditorFunctions.lua
-- **  Author(s):  David Tomandl
-- **
-- **  Summary  :  This is a set of functions for the platoon builder, used in
-- **              operation A6.
-- **
-- **  Copyright © 2006 Gas Powered Games, Inc.  All rights reserved.
-- ****************************************************************************

local OpStrings = import ('/maps/SCCA_Coop_A06_v03/SCCA_Coop_A06_v03_strings.lua')
local ScenarioUtils = import( '/lua/sim/ScenarioUtilities.lua' )
local ScenarioFramework = import( '/lua/ScenarioFramework.lua' )

-- #############################################################################################################
-- function: M2HugeAttack = AddFunction   doc = "Send the huge attack at the control center"
--
-- parameter 0: string	platoon		= "default_platoon"
--
-- #############################################################################################################
function M2HugeAttack(platoon)
    ScenarioInfo.VarTable['M2SendHugeAttack'] = false
    platoon:Stop()
    platoon:AggressiveMoveToLocation( ScenarioUtils.MarkerToPosition( 'M2_Cybran_Target' ))
    platoon:Patrol( ScenarioUtils.MarkerToPosition( 'AttackMarker' ))
    platoon:Patrol( ScenarioUtils.MarkerToPosition( 'M1_Air_Defense_1' ))
end

-- #############################################################################################################
-- function: SpiderAttackDefeated = BuildCallback   doc = "The huge attack has been defeated"
--
-- parameter 0: string	platoon		= "default_platoon"
-- parameter 1: string   table       = "1"
--
-- #############################################################################################################
function SpiderAttackDefeated( platoon, table )
    if ScenarioInfo.MissionNumber == 2 then
        ScenarioFramework.Dialogue( OpStrings.A06_M02_080 )
    end
end

-- #############################################################################################################
-- function: MoveToExperimentalIsland = AddFunction   doc = "Move to the SE island and disband"
--
-- parameter 0: string	platoon		= "default_platoon"
--
-- #############################################################################################################
function MoveToExperimentalIsland(platoon)
    local aiBrain = platoon:GetBrain()
    platoon:MoveToLocation( ScenarioUtils.MarkerToPosition( 'Experimental_Island' ), true )
    ForkThread( WaitAndDisband, platoon, aiBrain )
end

function WaitAndDisband( platoon, aiBrain )
    local moving = true
    while aiBrain:PlatoonExists(platoon) and moving do
        WaitSeconds( 5 )
        moving = false
        if aiBrain:PlatoonExists(platoon) then
            for k, unit in platoon:GetPlatoonUnits() do
                if not unit:IsDead() and not unit:IsIdleState() then
                    moving = true
                end
            end
        end
    end
    if aiBrain:PlatoonExists(platoon) then
        aiBrain:DisbandPlatoon(platoon)
    end
end
