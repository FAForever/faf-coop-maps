-- ****************************************************************************
-- **
-- **  File     :  /maps/SCCA_Coop_R02/SCCA_Coop_R02_EditorFunctions.lua
-- **  Author(s):  Grant Roberts
-- **
-- **  Summary  :  This is a set of functions for the platoon builder, used in
-- **              operation R2.
-- **
-- **  Copyright © 2006 Gas Powered Games, Inc.  All rights reserved.
-- ****************************************************************************

local OpScript = import ('/maps/SCCA_Coop_R02/SCCA_Coop_R02_script.lua')
local ScenarioFramework = import( '/lua/scenarioframework.lua' )
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioUtils = import( '/lua/sim/ScenarioUtilities.lua' )

-- ###################################################################################################################
-- ## ChooseAttackLocation
-- ##     - Same functionality as ScenarioFramework.DetermineBestAttackLocation.  That is, we take a table of markers,
-- ##         and find the marker with the most units around it.  Then we attack that location.
-- ##
-- ###################################################################################################################
-- #############################################################################################################
-- function: ChooseAttackLocation = AddFunction    doc = "Please work function docs."
--
-- parameter 0: string   platoon         = "default_platoon"
--
-- #############################################################################################################
function ChooseAttackLocation( platoon )
    local data = platoon.PlatoonData
    local attackingBrain = platoon:GetBrain()
    local markerChain = ScenarioUtils.ChainToPositions( platoon.PlatoonData.TableOfMarkers )

    if(data) then
        platoon:Stop()
        if(data.TableOfMarkers) then
            if ScenarioInfo.MissionNumber == 3 then
            -- Check brain for Janus vs. Aeon
                if platoon.PlatoonData.AttackingBrain == 'CybranJanus' then
                    if math.mod( ScenarioInfo.M3JanusAMPlatoonsKilled, 2 ) == 0 then
                    -- An even number of Janus AM platoons has been killed so we attack the Aeon
                        LOG('GKRDEBUG: M3JanusAMPlatoonsKilled = ' .. ScenarioInfo.M3JanusAMPlatoonsKilled .. ' so we attack the Aeon.')
                        platoon.PlatoonData.Location = ScenarioUtils.MarkerToPosition('M3_Aeon_Base_Land')
                    else
                    -- An odd number of Janus AM platoons has been killed so we attack the player
                        LOG('GKRDEBUG: M3JanusAMPlatoonsKilled = ' .. ScenarioInfo.M3JanusAMPlatoonsKilled .. ' so we attack the Player.')
                        platoon.PlatoonData.Location = ScenarioFramework.DetermineBestAttackLocation( attackingBrain, ArmyBrains[ScenarioInfo.Player1], 'enemy', markerChain, 64 )
                    end

                    platoon:ForkAIThread( ScenarioPlatoonAI.PlatoonAttackLocation )

                elseif platoon.PlatoonData.AttackingBrain == 'Aeon' then
                    local aeonAMPlatoonsKilled = ScenarioInfo.M2AMLandPlatoonsKilled + ScenarioInfo.M2AMNavalPlatoonsKilled
                    if math.mod( aeonAMPlatoonsKilled, 2 ) == 0 then
                        LOG('GKRDEBUG: Aeon AMPlatoonsKilled = ' .. aeonAMPlatoonsKilled .. ' so we attack Janus.')
                        platoon.PlatoonData.Location = ScenarioUtils.MarkerToPosition('M3_Janus_Base_N')
                    else
                        LOG('GKRDEBUG: Aeon AMPlatoonsKilled = ' .. aeonAMPlatoonsKilled .. ' so we attack the player.')
                        platoon.PlatoonData.Location = ScenarioFramework.DetermineBestAttackLocation( attackingBrain, ArmyBrains[ScenarioInfo.Player1], 'enemy', markerChain, 64 )
                    end

                    platoon:ForkAIThread( ScenarioPlatoonAI.PlatoonAttackLocation )

                else
                -- INVALID ATTACKER!
                    error('*AI WARNING: SCCA_Coop_R02/EditorFunctions/ChooseAttackLocation is not using Janus or Aeon!', 2)
                end
            else
            -- Since we're not in Mission 3, the attacker has to be Aeon
                platoon.PlatoonData.Location = ScenarioFramework.DetermineBestAttackLocation( attackingBrain, ArmyBrains[ScenarioInfo.Player1], 'enemy', markerChain, 64 )
                platoon:ForkAIThread( ScenarioPlatoonAI.PlatoonAttackLocation )
            end

            -- This gets called every time, and is the point of the function

        else
            error('*AI WARNING: SCCA_Coop_R02/EditorFunctions/ChooseAttackLocation shows TableOfMarkers not defined', 2)
        end
    else
        error('*AI WARNING: SCCA_Coop_R02/EditorFunctions/ChooseAttackLocation shows PlatoonData not defined', 2)
    end
end

-- ############################################################################################################
-- function: M2AeonLandAMBuilt         = AddFunction       doc = "timer reset cue"
--
-- parameter 0:    string    brain        = "default_brain"
-- parameter 1:    string    dataTable    = "default_table"
--
-- ###########################################################################################################
function M2AeonLandAMBuilt(brain, dataTable)
    ScenarioInfo.VarTable['M2LandAssaultReady'] = false
    ScenarioFramework.CreateTimerTrigger( OpScript.M2LaunchLandAssault, OpScript.M2LandAssaultRepeatDelay() )
end

-- ############################################################################################################
-- function: M2AeonAMLandPlatoonKilled         = BuildCallback       doc = "timer reset cue"
--
-- parameter 0:    string    platoon         = "default_platoon"
--
-- ###########################################################################################################
function M2AeonAMLandPlatoonKilled( platoon )
    ScenarioInfo.M2AMLandPlatoonsKilled = ScenarioInfo.M2AMLandPlatoonsKilled + 1
    ScenarioInfo.VarTable['M2AeonAMLandPlatoonsNeeded'] = ScenarioInfo.VarTable['M2AeonAMLandPlatoonsNeeded'] + ScenarioInfo.Difficulty
    if ScenarioInfo.Difficulty >= 1 then
        ScenarioInfo.VarTable['M2AeonAMLandTankPlatoonsAllowed'] = ScenarioInfo.VarTable['M2AeonAMLandTankPlatoonsAllowed'] + 1
        if ScenarioInfo.Difficulty >= 2 then
            ScenarioInfo.VarTable['M2AeonAMLandAntiAirPlatoonsAllowed'] = ScenarioInfo.VarTable['M2AeonAMLandAntiAirPlatoonsAllowed'] + 1
            if ScenarioInfo.Difficulty >= 3 then
                ScenarioInfo.VarTable['M2AeonAMLandOtherPlatoonsAllowed'] = ScenarioInfo.VarTable['M2AeonAMLandOtherPlatoonsAllowed'] + 1
            end
        end
    end
end

-- ############################################################################################################
-- function: M2AeonNavalAMBuilt         = AddFunction       doc = "timer reset cue"
--
-- parameter 0:    string    brain        = "default_brain"
-- parameter 1:    string    dataTable    = "default_table"
--
-- ###########################################################################################################
function M2AeonNavalAMBuilt(brain, dataTable)
    ScenarioInfo.VarTable['M2NavalAssaultReady'] = false
    ScenarioFramework.CreateTimerTrigger( OpScript.M2LaunchNavalAssault, OpScript.M2NavalAssaultRepeatDelay() )
end

-- ############################################################################################################
-- function: M2AeonAMNavalPlatoonKilled         = BuildCallback       doc = "timer reset cue"
--
-- parameter 0:    string    platoon         = "default_platoon"
--
-- ###########################################################################################################
function M2AeonAMNavalPlatoonKilled( platoon )
    ScenarioInfo.M2AMNavalPlatoonsKilled = ScenarioInfo.M2AMNavalPlatoonsKilled + 1
    ScenarioInfo.VarTable['M2AeonAMNavalPlatoonsNeeded'] = ScenarioInfo.VarTable['M2AeonAMNavalPlatoonsNeeded'] + ScenarioInfo.Difficulty
    ScenarioInfo.VarTable['M2AeonAMNavalPlatoonsAllowed'] = ScenarioInfo.VarTable['M2AeonAMNavalPlatoonsAllowed'] + ScenarioInfo.Difficulty
end

-- ############################################################################################################
-- function: M3JanusAttackPlatoonBuilt         = AddFunction       doc = "timer reset cue"
--
-- parameter 0:    string    brain        = "default_brain"
-- parameter 1:    string    dataTable    = "default_table"
--
-- ###########################################################################################################
function M3JanusAttackPlatoonBuilt(brain, dataTable)
    ScenarioInfo.VarTable['M3JanusAttackReady'] = false
    ScenarioFramework.CreateTimerTrigger( OpScript.M3JanusAttack, OpScript.M3JanusAttackRepeatDelay() )
end

-- ############################################################################################################
-- function: M3JanusAMBuilt         = AddFunction       doc = "timer reset cue"
--
-- parameter 0:    string    brain        = "default_brain"
-- parameter 1:    string    dataTable    = "default_table"
--
-- ###########################################################################################################
function M3JanusAMBuilt(brain, dataTable)
    ScenarioInfo.VarTable['M3JanusAttackReady'] = false
    ScenarioFramework.CreateTimerTrigger( OpScript.M3JanusAttack, OpScript.M3JanusAttackRepeatDelay() )
end

-- ############################################################################################################
-- function: M3JanusAMPlatoonKilled         = BuildCallback       doc = "timer reset cue"
--
-- parameter 0:    string    platoon         = "default_platoon"
--
-- ###########################################################################################################
function M3JanusAMPlatoonKilled( platoon )
    ScenarioInfo.M3JanusAMPlatoonsKilled = ScenarioInfo.M3JanusAMPlatoonsKilled + 1

    if math.mod( ScenarioInfo.M3JanusAMPlatoonsKilled, ScenarioInfo.M3JanusAttacksIncreaseAfter ) == ScenarioInfo.M3JanusAttacksIncreaseAfter - 1 then
    -- For instance, if the attack size increases after 3 attacks, then we want to increase it when the player's
    -- killed 2, 5, 8, 11 attacks.  So 11 / 3 = 3, with a remainder of 2.
        ScenarioInfo.VarTable['M3JanusAMPlatoonsNeeded'] = ScenarioInfo.VarTable['M3JanusAMPlatoonsNeeded'] + ScenarioInfo.Difficulty
        if ScenarioInfo.Difficulty >= 1 then
            if Random(0,1) == 1 then
                ScenarioInfo.VarTable['M3JanusAMLandPlatoonsAllowed'] = ScenarioInfo.VarTable['M3JanusAMLandPlatoonsAllowed'] + 1
            else
                ScenarioInfo.VarTable['M3JanusAMAirPlatoonsAllowed'] = ScenarioInfo.VarTable['M3JanusAMAirPlatoonsAllowed'] + 1
            end
        end
        if ScenarioInfo.Difficulty >= 2 then
            if Random(0,1) == 1 then
                ScenarioInfo.VarTable['M3JanusAMLandPlatoonsAllowed'] = ScenarioInfo.VarTable['M3JanusAMLandPlatoonsAllowed'] + 1
            else
                ScenarioInfo.VarTable['M3JanusAMAirPlatoonsAllowed'] = ScenarioInfo.VarTable['M3JanusAMAirPlatoonsAllowed'] + 1
            end
        end
        if ScenarioInfo.Difficulty >= 3 then
            if Random(0,1) == 1 then
                ScenarioInfo.VarTable['M3JanusAMLandPlatoonsAllowed'] = ScenarioInfo.VarTable['M3JanusAMLandPlatoonsAllowed'] + 1
            else
                ScenarioInfo.VarTable['M3JanusAMAirPlatoonsAllowed'] = ScenarioInfo.VarTable['M3JanusAMAirPlatoonsAllowed'] + 1
            end
        end
    end
end

-- ############################################################################################################
-- function: M3AeonAMBuilt         = AddFunction       doc = "timer reset cue"
--
-- parameter 0:    string    brain        = "default_brain"
-- parameter 1:    string    dataTable    = "default_table"
--
-- ###########################################################################################################
function M3AeonAMBuilt(brain, dataTable)
    ScenarioInfo.VarTable['M3AeonAttackReady'] = false
    ScenarioFramework.CreateTimerTrigger( OpScript.M3AeonAttack, OpScript.M3AeonAttackRepeatDelay() )
end

-- ############################################################################################################
-- function: M3AeonAMPlatoonKilled         = BuildCallback       doc = "timer reset cue"
--
-- parameter 0:    string    platoon         = "default_platoon"
--
-- ###########################################################################################################
function M3AeonAMPlatoonKilled( platoon )
    ScenarioInfo.M3AeonAMPlatoonsKilled = ScenarioInfo.M3AeonAMPlatoonsKilled + 1

    if math.mod( ScenarioInfo.M3AeonAMPlatoonsKilled, ScenarioInfo.M3AeonAttacksIncreaseAfter ) == ScenarioInfo.M3AeonAttacksIncreaseAfter - 1 then
    -- For instance, if the attack size increases after 3 attacks, then we want to increase it when the player's
    -- killed 2, 5, 8, 11 attacks.  So 11 / 3 = 3, with a remainder of 2.
        ScenarioInfo.VarTable['M3AeonAMPlatoonsNeeded'] = ScenarioInfo.VarTable['M3AeonAMPlatoonsNeeded'] + ScenarioInfo.Difficulty
        if ScenarioInfo.Difficulty >= 1 then
            if Random(0,1) == 1 then
                ScenarioInfo.VarTable['M3AeonAMLandPlatoonsAllowed'] = ScenarioInfo.VarTable['M3AeonAMLandPlatoonsAllowed'] + 1
            else
                ScenarioInfo.VarTable['M3AeonAMAirPlatoonsAllowed'] = ScenarioInfo.VarTable['M3AeonAMAirPlatoonsAllowed'] + 1
            end
        end
        if ScenarioInfo.Difficulty >= 2 then
            if Random(0,1) == 1 then
                ScenarioInfo.VarTable['M3AeonAMLandPlatoonsAllowed'] = ScenarioInfo.VarTable['M3AeonAMLandPlatoonsAllowed'] + 1
            else
                ScenarioInfo.VarTable['M3AeonAMAirPlatoonsAllowed'] = ScenarioInfo.VarTable['M3AeonAMAirPlatoonsAllowed'] + 1
            end
        end
        if ScenarioInfo.Difficulty >= 3 then
            if Random(0,1) == 1 then
                ScenarioInfo.VarTable['M3AeonAMLandPlatoonsAllowed'] = ScenarioInfo.VarTable['M3AeonAMLandPlatoonsAllowed'] + 1
            else
                ScenarioInfo.VarTable['M3AeonAMAirPlatoonsAllowed'] = ScenarioInfo.VarTable['M3AeonAMAirPlatoonsAllowed'] + 1
            end
        end
    end
end

-- #############################################################################################################
-- function: M3BomberEscortAttack = AddFunction   doc = "Please work function docs."
--
-- parameter 0: string   platoon     = "default_platoon"
--
-- #############################################################################################################
function M3BomberEscortAttack(platoon)
    local aiBrain = platoon:GetBrain()
    local target = false
    local cmd = false
    while aiBrain:PlatoonExists(platoon) do
        if not cmd or platoon:IsCommandsActive(cmd) then
            if not ScenarioInfo.M3BomberEscortAttacksPlayer then
                -- Attack whoever's not the player, and attack the player next time
                if platoon.PlatoonData.AttackingBrain == 'CybranJanus' then
                    platoon.PlatoonData.Location = ScenarioUtils.MarkerToPosition('M3_Janus_Base_N')
                else
                    platoon.PlatoonData.Location = ScenarioUtils.MarkerToPosition('M3_Aeon_Base_Land')
                end

                ScenarioInfo.M3BomberEscortAttacksPlayer = true
            else
                -- Attack the player, and attack the other army next time
                platoon.PlatoonData.Location = ScenarioFramework.DetermineBestAttackLocation( aiBrain, ArmyBrains[ScenarioInfo.Player1], 'enemy', ScenarioUtils.ChainToPositions( 'M3_Attack_Grid' ), 64 )

                ScenarioInfo.M3BomberEscortAttacksPlayer = false
            end

            platoon:ForkAIThread( OpScript.PatrolAtLocation )

        end

        WaitSeconds(17)
    end
end

-- #############################################################################################################
-- function: M3LandAssaultAttack = AddFunction   doc = "Please work function docs."
--
-- parameter 0: string   platoon     = "default_platoon"
--
-- #############################################################################################################
function M3LandAssaultAttack(platoon)
    local aiBrain = platoon:GetBrain()
    local master = string.sub(platoon.PlatoonData.BuilderName, 12)
    local landingChain = platoon.PlatoonData.LandingChain
    local attackChain = platoon.PlatoonData.AttackChain
    local transportReturn = platoon.PlatoonData.TransportReturn

    if landingChain and attackChain then

        if not ScenarioInfo.M3LandAssaultAttacksPlayer then
            -- Attack whoever's not the player, and attack the player next time
            ScenarioInfo.M3LandAssaultAttacksPlayer = true

        else
            -- Attack the player, and attack the other army next time
            ScenarioInfo.M3LandAssaultAttacksPlayer = false

            local highestUnitCountFound = 0
            local playerUnitCount = 0
            local foundUnits = nil
            local attackLocation = nil
            local tableOfAttackLocations = nil
            local offsetPoint = nil
            local locationSet = false

            if aiBrain == ArmyBrains[ScenarioInfo.CybranJanus] then
                tableOfAttackLocations = ScenarioUtils.ChainToPositions('M3_Janus_Attack_Points')
            elseif aiBrain == ArmyBrains[ScenarioInfo.Aeon] then
                tableOfAttackLocations = ScenarioUtils.ChainToPositions('M3_Aeon_Attack_Points')
            else
                error('*AI ERROR: M3LandAssault is trying to run with a non-Mach and non-Aeon brain!', 2)
            end

            for locationsCount, position in tableOfAttackLocations do
                foundUnits = aiBrain:GetUnitsAroundPoint( categories.ALLUNITS, position, 64, 'Enemy' )

                for throwawayCounter, unit in foundUnits do
                    if unit:GetAIBrain() == ArmyBrains[ScenarioInfo.Player1] then
                        playerUnitCount = playerUnitCount + 1
                    end
                end

                -- Find location with highest number of player units
                if( playerUnitCount > highestUnitCountFound ) or not locationSet then
                    locationSet = true
                    highestUnitCountFound = playerUnitCount
                end

                -- Set chains to nil and set tables with new points
                platoon.PlatoonData.AttackChain = nil
                platoon.PlatoonData.LandingChain = nil

                platoon.PlatoonData.AttackPoints = { }
                table.insert( platoon.PlatoonData.AttackPoints, position )
                platoon.PlatoonData.LandingList = { }
                local secondPosition = { position[1] - 10, position[2], position[3] + 10 }
                table.insert( platoon.PlatoonData.LandingList, secondPosition )

                playerUnitCount = 0
            end
        end

        ScenarioPlatoonAI.LandAssaultWithTransports( platoon )

        -- If the platoon's still alive, then attack the closest unit
        -- Commenting this part out for now, as PlatoonAttackClosestUnit uses FindClosestUnit, which for
        -- some reason that only Drew knows, relies on the target unit having its squad set to 'Attack'.

        -- This is only needed if the platoon gets dropped off somewhere far away from any units, and will
        -- patrol through the AttackChain instead of attacking anything nearby.  -GKR 8/2

--[[
        if aiBrain:PlatoonExists( platoon ) then
            platoon:ForkAIThread( ScenarioPlatoonAI.PlatoonAttackClosestUnit )
        end
]]--

    else
        error('*AI ERROR: LandAssault looking for chains --\"'..master.. '_LandingChain\"-- or --\"'..aiBrain.Name .. '_LandingChain\"-- and --\"'..master.. '_AttackChain\"-- or --\"'..aiBrain.Name .. '_AttackChain\"--', 2)
    end
end

