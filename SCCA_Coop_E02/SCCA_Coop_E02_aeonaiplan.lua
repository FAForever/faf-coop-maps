-- ****************************************************************************
-- **
-- **  File     : /maps/SCCA_Coop_E02/SCCA_Coop_E02_aeonaiplan.lua
-- **  Author(s): David Tomandl
-- **
-- **  Summary  : Functions for the AI to use in Op E2
-- **
-- **  Copyright © 2006 Gas Powered Games, Inc.  All rights reserved.
-- ****************************************************************************
local AIBuildStructures = import('/lua/ai/aibuildstructures.lua')
local AIBuildUnits = import('/lua/ai/aibuildunits.lua')
local AIUtils = import('/lua/ai/aiutilities.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioFramework = import('/lua/scenarioframework.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local Utilities = import('/lua/utilities.lua')

-- ##################
local Player1 = ScenarioInfo.Player1
local Aeon = ScenarioInfo.Aeon
local AllyResearch = ScenarioInfo.AllyResearch
local AllyCivilian = ScenarioInfo.AllyCivilian

-- ## Attack Routes
-- local AeonBasePatrolList = {
-- ScenarioUtils.MarkerToPosition('Aeon_Base_Patrol_1'),
-- ScenarioUtils.MarkerToPosition('Aeon_Base_Patrol_2'),
-- ScenarioUtils.MarkerToPosition('Aeon_Base_Patrol_3'),
-- ScenarioUtils.MarkerToPosition('Aeon_Base_Patrol_4')
-- }

local AeonPeriodicAttackPlayerRoute1 = {
    ScenarioUtils.MarkerToPosition('Aeon_Path_NW_1'),
    ScenarioUtils.MarkerToPosition('Aeon_Path_NW_2'),
    ScenarioUtils.MarkerToPosition('Aeon_Path_NW_3'),
    ScenarioUtils.MarkerToPosition('Aeon_Path_NW_4'),
    ScenarioUtils.MarkerToPosition('Aeon_Path_NW_5'),
    ScenarioUtils.MarkerToPosition('Aeon_Path_NW_6'),
    ScenarioUtils.MarkerToPosition('Aeon_Path_NW_7'),
    ScenarioUtils.MarkerToPosition('Player_Start_Position'),
    ScenarioUtils.MarkerToPosition('Player_Base_1'),
    ScenarioUtils.MarkerToPosition('Player_Base_2'),
    ScenarioUtils.MarkerToPosition('Player_Base_3'),
}

local AeonPeriodicAttackPlayerRoute2 = {
    ScenarioUtils.MarkerToPosition('Aeon_Path_N_1'),
    ScenarioUtils.MarkerToPosition('Aeon_Path_N_2'),
    ScenarioUtils.MarkerToPosition('Aeon_Path_N_3'),
    ScenarioUtils.MarkerToPosition('Aeon_Path_N_4'),
    ScenarioUtils.MarkerToPosition('Aeon_Path_NW_6'),
    ScenarioUtils.MarkerToPosition('Aeon_Path_NW_7'),
    ScenarioUtils.MarkerToPosition('Player_Start_Position'),
    ScenarioUtils.MarkerToPosition('Player_Base_1'),
    ScenarioUtils.MarkerToPosition('Player_Base_2'),
    ScenarioUtils.MarkerToPosition('Player_Base_3'),
}

local AeonPeriodicAttackPlayerRoute3 = {
    ScenarioUtils.MarkerToPosition('Aeon_Path_N_1'),
    ScenarioUtils.MarkerToPosition('Aeon_Path_N_2'),
    ScenarioUtils.MarkerToPosition('Aeon_Path_N_3'),
    ScenarioUtils.MarkerToPosition('Aeon_Path_N_4'),
    ScenarioUtils.MarkerToPosition('Aeon_Path_N_5'),
    ScenarioUtils.MarkerToPosition('Aeon_Path_N_6'),
    ScenarioUtils.MarkerToPosition('Aeon_Path_N_7'),
    ScenarioUtils.MarkerToPosition('Aeon_Path_N_8'),
    ScenarioUtils.MarkerToPosition('Player_Start_Position'),
    ScenarioUtils.MarkerToPosition('Player_Base_1'),
    ScenarioUtils.MarkerToPosition('Player_Base_2'),
    ScenarioUtils.MarkerToPosition('Player_Base_3'),
}

local AeonPeriodicAttackPlayerRouteAirOnly = {
    ScenarioUtils.MarkerToPosition('Aeon_Path_NW_1'),
    ScenarioUtils.MarkerToPosition('Aeon_Path_NW_2'),
    ScenarioUtils.MarkerToPosition('Aeon_Path_NW_3'),
    ScenarioUtils.MarkerToPosition('Aeon_Path_Air_West_1'),
    ScenarioUtils.MarkerToPosition('Aeon_Path_Air_West_2'),
    ScenarioUtils.MarkerToPosition('Aeon_Path_Air_West_3'),
    ScenarioUtils.MarkerToPosition('Player_Base_2'),
    ScenarioUtils.MarkerToPosition('Player_Start_Position'),
    ScenarioUtils.MarkerToPosition('Player_Base_1'),
    ScenarioUtils.MarkerToPosition('Player_Base_3'),
}

local AeonPeriodicAttackResearchRoute1 = {
    ScenarioUtils.MarkerToPosition('Aeon_Path_N_1'),
    ScenarioUtils.MarkerToPosition('Aeon_Path_N_2'),
    ScenarioUtils.MarkerToPosition('Aeon_Path_N_3'),
    ScenarioUtils.MarkerToPosition('Aeon_Path_NE_1'),
    ScenarioUtils.MarkerToPosition('Aeon_Path_NE_2'),
    ScenarioUtils.MarkerToPosition('Research_Facility'),
    ScenarioUtils.MarkerToPosition('Research_Attack_Point_1'),
    ScenarioUtils.MarkerToPosition('Research_Attack_Point_2'),
    ScenarioUtils.MarkerToPosition('Research_Attack_Point_3'),
}

local AeonPeriodicAttackResearchRouteAirOnly = {
    ScenarioUtils.MarkerToPosition('Aeon_Path_N_1'),
    ScenarioUtils.MarkerToPosition('Aeon_Path_N_2'),
    ScenarioUtils.MarkerToPosition('Aeon_Path_N_3'),
    ScenarioUtils.MarkerToPosition('Aeon_Path_N_4'),
    ScenarioUtils.MarkerToPosition('Aeon_Path_N_5'),
    ScenarioUtils.MarkerToPosition('Research_Attack_Point_1'),
    ScenarioUtils.MarkerToPosition('Research_Facility'),
    ScenarioUtils.MarkerToPosition('Research_Attack_Point_2'),
    ScenarioUtils.MarkerToPosition('Research_Attack_Point_3'),
}

-- local LandSquadList = {
-- categories.ARTILLERY,
-- categories.INDIRECTFIRE,
-- categories.ENERGYPRODUCTION * categories.TECH3,
-- categories.ENERGYPRODUCTION * categories.TECH2,
-- categories.ENERGYPRODUCTION * categories.TECH1,
-- categories.DEFENSE * categories.TECH2,
-- categories.DEFENSE * categories.TECH1,
-- categories.MOBILE - categories.COMMAND,
-- categories.ALLUNITS,
-- }
--
-- local AirControlList = {
-- categories.AIR * categories.ANTIAIR,
-- categories.AIR,
-- categories.ANTIAIR,
-- categories.MOBILE,
-- categories.ALLUNITS,
-- }
--
-- local AirBomberList = {
-- categories.ANTIAIR * categories.TECH3,
-- categories.ANTIAIR * categories.TECH2,
-- categories.ANTIAIR * categories.TECH1,
-- categories.ENERGYPRODUCTION * categories.TECH3,
-- categories.ENERGYPRODUCTION * categories.TECH2,
-- categories.ENERGYPRODUCTION * categories.TECH1,
-- categories.MASSEXTRACTION,
-- categories.DEFENSE,
-- categories.COMMAND,
-- categories.ALLUNITS,
-- }

function EvaluatePlan( brain )
    return 100
end

function ExecutePlan( brain )
-- if not ScenarioInfo.AISet then
--    local tempPlatoon = brain:GetPlatoonUniquelyNamed('Commander')
--    if tempPlatoon then
--        ScenarioInfo.AISet = true
--        ScenarioFramework.DisablePoolAI(brain)
--        tempPlatoon:StopAI()
--        tempPlatoon:ForkAIThread(CommanderDefendThread)
--    end
-- end
-- BuildUnits( brain )

    if not ScenarioInfo.AeonPlanRunOnce then
        brain:PBMRemoveBuildLocation( nil, 'MAIN' )
        brain:PBMAddBuildLocation( ScenarioUtils.MarkerToPosition( 'Aeon_Base' ), 80, 'Aeon_Base' )
        brain:PBMAddBuildLocation( ScenarioUtils.MarkerToPosition( 'Aeon_Base_T1_Factories' ), 15, 'Aeon_Base_T1_Factories' )

        AIBuildStructures.CreateBuildingTemplate( brain, 'Aeon', 'M3_Base_D3' )

        -- AppendBuildingTemplate assumes that the template already exists.  This is a barebones definition of one.
        brain.BaseTemplates['M3_Base_D1'] = { Template = {}, List = {} }
        AIBuildStructures.AppendBuildingTemplate( brain, 'Aeon', 'M3_Base_Economy', 'M3_Base_D1' )
        AIBuildStructures.AppendBuildingTemplate( brain, 'Aeon', 'M3_Base_Misc', 'M3_Base_D1' )
        -- commenting this out because rebuilding defenses on difficulty one and two was determined to be too tough
        -- AIBuildStructures.AppendBuildingTemplate( brain, 'Aeon', 'M3_Base_Defenses_Guns_D1', 'M3_Base_D1' )
        AIBuildStructures.AppendBuildingTemplate( brain, 'Aeon', 'M3_Base_Defenses_Shields', 'M3_Base_D1' )
        AIBuildStructures.AppendBuildingTemplate( brain, 'Aeon', 'M3_Base_Defenses_Walls_D1', 'M3_Base_D1' )

        brain.BaseTemplates['M3_Base_D2'] = { Template = {}, List = {} }
        AIBuildStructures.AppendBuildingTemplate( brain, 'Aeon', 'M3_Base_Economy', 'M3_Base_D2' )
        AIBuildStructures.AppendBuildingTemplate( brain, 'Aeon', 'M3_Base_Misc', 'M3_Base_D2' )
        -- commenting this out because rebuilding defenses on difficulty one and two was determined to be too tough
        -- AIBuildStructures.AppendBuildingTemplate( brain, 'Aeon', 'M3_Base_Defenses_Guns_D2', 'M3_Base_D2' )
        AIBuildStructures.AppendBuildingTemplate( brain, 'Aeon', 'M3_Base_Defenses_Shields', 'M3_Base_D2' )
        AIBuildStructures.AppendBuildingTemplate( brain, 'Aeon', 'M3_Base_Defenses_Walls_D2', 'M3_Base_D2' )


        ScenarioInfo.AeonPlanRunOnce = true
    end

end

function DetermineAttackRouteLand(platoon)
    -- Send them at the player
    if ScenarioFramework.UnitsInAreaCheck( categories.UEF, ScenarioUtils.AreaToRect('Player_Base_Area')) then
        local AttackPlayerBase = true
        -- See which route the platoon should follow
        local randomNumber = Random(0, AttackPlayerRoute1Chance + AttackPlayerRoute2Chance + AttackPlayerRoute3Chance + AttackResearchChance)
        if randomNumber < AttackPlayerRoute1Chance then
            LOG( 'Land Attacking Player on Route 1' )
            ScenarioFramework.PlatoonPatrolRoute( Platoon, AeonPeriodicAttackPlayerRoute1 )
        elseif randomNumber < (AttackPlayerRoute1Chance + AttackPlayerRoute2Chance) then
            LOG( 'Land Attacking Player on Route 2' )
            ScenarioFramework.PlatoonPatrolRoute( Platoon, AeonPeriodicAttackPlayerRoute2 )
        elseif randomNumber < (AttackPlayerRoute1Chance + AttackPlayerRoute2Chance + AttackPlayerRoute3Chance) then
            LOG( 'Land Attacking Player on Route 3' )
            ScenarioFramework.PlatoonPatrolRoute( Platoon, AeonPeriodicAttackPlayerRoute3 )
        else
            LOG( 'Land Attacking Research' )
            ScenarioFramework.PlatoonPatrolRoute( Platoon, AeonPeriodicAttackResearchRoute1 )
            AttackPlayerBase = false
        end
    else
        -- Player has moved out of the starting location,
        -- so we send attacks to the research base location
        LOG( 'Land Attacking Research' )
        ScenarioFramework.PlatoonPatrolRoute( newPlatoon, AeonPeriodicAttackResearchRoute1 )
    end
end

function DetermineAttackRouteAir(platoon)
    -- Send them at the player
    if ScenarioFramework.UnitsInAreaCheck( categories.UEF, ScenarioUtils.AreaToRect('Player_Base_Area')) then
        local AttackPlayerBase = true
        -- See which route the platoon should follow
        local randomNumber = Random(0, AttackPlayerRoute1Chance + AttackPlayerRoute2Chance + AttackPlayerRoute3Chance + AttackResearchChance)
        if randomNumber < AttackPlayerRoute1Chance then
            LOG( 'Air Attacking Player on Route 1' )
            ScenarioFramework.PlatoonPatrolRoute( Platoon, AeonPeriodicAttackPlayerRoute1 )
        elseif randomNumber < (AttackPlayerRoute1Chance + AttackPlayerRoute2Chance) then
            LOG( 'Air Attacking Player on Route 2' )
            ScenarioFramework.PlatoonPatrolRoute( Platoon, AeonPeriodicAttackPlayerRoute2 )
        elseif randomNumber < (AttackPlayerRoute1Chance + AttackPlayerRoute2Chance + AttackPlayerRoute3Chance) then
            LOG( 'Air Attacking Player on Route 3' )
            ScenarioFramework.PlatoonPatrolRoute( Platoon, AeonPeriodicAttackPlayerRoute3 )
        else
            LOG( 'Air Attacking Research' )
            ScenarioFramework.PlatoonPatrolRoute( Platoon, AeonPeriodicAttackResearchRoute1 )
            AttackPlayerBase = false
        end
    else
        -- Player has moved out of the starting location,
        -- so we send attacks to the research base location
        LOG( 'Air Attacking Research' )
        ScenarioFramework.PlatoonPatrolRoute( newPlatoon, AeonPeriodicAttackResearchRoute1 )
    end
end

-- function BuildUnits( brain )
-- AIBuildUnits.FormPlatoons(brain)
-- local available = brain:GetAvailableFactories()
-- local airFactories = {}
-- local landFactories = {}
-- for k,v in available do
--    if EntityCategoryContains( categories.LAND, v ) then
--        table.insert( landFactories, v )
--    elseif EntityCategoryContains( categories.AIR, v ) then
--        table.insert( airFactories, v )
--    end
-- end
--
-- local engineerNum = brain:GetCurrentUnits( categories.ENGINEER - categories.COMMAND )
-- local numAA = ArmyBrains[Player1]:GetCurrentUnits( categories.ANTIAIR )
-- local numAir = ArmyBrains[Player1]:GetCurrentUnits( categories.AIR * categories.MOBILE )
-- local numMobile = ArmyBrains[Player1]:GetCurrentUnits( categories.MOBILE )
-- local numLand = ArmyBrains[Player1]:GetCurrentUnits( categories.MOBILE * categories.LAND )
--
-- if engineerNum < 1 and table.getn(landFactories) == brain:GetCurrentUnits(categories.FACTORY * categories.LAND) then
--    AIBuildUnits.BuildPlatoonFactoryList( brain, EngineerPlatoon, 1, landFactories, EngineerPicker )
-- end
--
-- if ScenarioInfo.MissionNumber == 2 then
--    if brain:GetCurrentUnits(categories.MOBILE) < numMobile then
--        local AIThread = PlayerAttackThread
--        if ScenarioInfo.FabricationBuiltFired and not ScenarioInfo.ScienceDefended then
--            AIThread = ScienceAttackThread
--        end
--        if table.getn(landFactories) == brain:GetCurrentUnits( categories.FACTORY * categories.LAND ) then
--            if numLand > (brain:GetCurrentUnits(categories.LAND * categories.MOBILE) * 3 ) and numLand > 50 then
--                AIBuildUnits.BuildPlatoon( brain, LandStrong, 1, AIThread, LandSquadList )
--            else
--                AIBuildUnits.BuildPlatoon( brain, LandWeak, 1, AIThread, LandSquadList )
--            end
--        end
--        if table.getn(airFactories) == brain:GetCurrentUnits( categories.FACTORY * categories.AIR ) then
--            if numAir > ( brain:GetCurrentUnits(categories.AIR * categories.MOBILE ) * 2 ) then
--                AIBuildUnits.BuildPlatoon( brain, AirControl, 1, AIThread, AirControlList )
--            elseif numAA > 30 then
--                AIBuildUnits.BuildPlatoon( brain, AirGunships, 1, PlayerAttackThread, AirControlList )
--            else
--                AIBuildUnits.BuildPlatoon( brain, AirBombers, 1, AIThread, AirBomberList )
--            end
--        end
--    elseif engineerNum < 2 and table.getn(landFactories) == brain:GetCurrentUnits(categories.FACTORY * categories.LAND) then
--        AIBuildUnits.BuildPlatoonFactoryList( brain, EngineerPlatoon, 1, landFactories, EngineerPicker )
--    end
-- end
-- end
--
-- function EngineerPicker(platoon)
-- local BaseEngineer = ArmyBrains[Aeon]:GetPlatoonUniquelyNamed('BaseEngineer')
-- local ExtractorsEngineer = ArmyBrains[Aeon]:GetPlatoonUniquelyNamed('ExtractorEngineer')
--
-- if not BaseEngineer or table.getn(BaseEngineer:GetPlatoonUnits()) == 0 then
--    if BaseEngineer ~= nil then
--        ArmyBrains[Aeon]:DisbandPlatoon(BaseEngineer)
--    end
--    platoon:UniquelyNamePlatoon('BaseEngineer')
--    ForkThread(EngineerThread, platoon)
-- elseif not ExtractorsEngineer or table.getn(ExtractorsEngineer:GetPlatoonUnits()) == 0 then
--    if ExtractorsEngineer ~= nil then
--        ArmyBrains[Aeon]:DisbandPlatoon(ExtractorsEngineer)
--    end
--    platoon:UniquelyNamePlatoon('ExtractorsEngineer')
--    ForkThread( ExtractorsThread, platoon )
-- end
-- end
--
-- function EngineerThread(platoon)
-- while true do
--    AIBuildStructures.PlatoonBuildFromList( ArmyBrains[Aeon], platoon, 'MainPower', 'MainFactories', 'MainExtractors', 'MainDefenses', 'MainExtras', 'MainFabricators' )
--    if ArmyBrains[Player1]:GetCurrentUnits( categories.LAND * categories.MOBILE ) > 50 then
--        AIBuildStructures.PlatoonBuildFromList( ArmyBrains[Aeon], platoon, 'DefensesLand' )
--    end
--    if ArmyBrains[Player1]:GetCurrentUnits( categories.AIR * categories.MOBILE ) > 75 then
--        AIBuildStructures.PlatoonBuildFromList( ArmyBrains[Aeon], platoon, 'DefensesAir' )
--    end
--    local busy = false
--    for k,unit in platoon:GetSquadUnits('support') do
--        if unit:IsUnitState('Building') then
--            busy = true
--        end
--    end
--    if not platoon:IsPatrolling('support') and not busy then
--        ScenarioFramework.PlatoonPatrolRoute(platoon, AeonBasePatrolList)
--    end
--    WaitSeconds(2)
-- end
-- end
--
-- function ExtractorsThread(platoon)
-- while true do
--    AIBuildStructures.PlatoonBuildFromList( ArmyBrains[Aeon], platoon, 'DistantExtractors' )
--    local busy = false
--    for k,unit in platoon:GetSquadUnits('support') do
--        if unit:IsUnitState('Building') then
--            busy = true
--        end
--    end
--    if not platoon:IsPatrolling('support') and not busy then
--        ScenarioFramework.PlatoonPatrolRoute(platoon, AeonBasePatrolList)
--    end
--    WaitSeconds(2)
-- end
-- end
--
-- function CommanderDefendThread(platoon)
-- while true do
--    AIBuildStructures.PlatoonBuildFromList( ArmyBrains[Aeon], platoon, 'MainFactories' )
--    local vector1 = platoon:GetSquadPosition('Support')
--    if not platoon:IsAttacking('Support') then
--        if not platoon:IsMoving('Support') then
--            local vector2 = ScenarioUtils.MarkerToPosition('AeonBase')
--            if Utilities.GetDistanceBetweenTwoVectors(vector1, vector2 ) > 10 then
--                platoon:MoveToLocation( ScenarioUtils.MarkerToPosition('AeonBase'), false)
--            end
--        end
--        local target = platoon:FindClosestUnit('Support', 'Enemy', true, categories.ALLUNITS)
--        if target ~= nil and not platoon:IsMoving('Support') then
--            local vector2 = target:GetPosition()
--            if Utilities.GetDistanceBetweenTwoVectors(vector1, vector2) > 15 then
--                platoon:AttackTarget(target)
--            end
--        end
--    elseif Utilities.GetDistanceBetweenTwoVectors( vector1, ScenarioUtils.MarkerToPosition('AeonBase')) > 25 then
--        platoon:MoveToLocation( ScenarioUtils.MarkerToPosition('AeonBase'), false)
--    end
--    WaitSeconds(1)
-- end
-- end
--
--
-- function PlayerAttackThread(platoon, list)
-- platoon:SetPrioritizedTargetList( 'attack', list )
-- while true do
--    if not platoon:IsAttacking('Attack') then
--        local target = nil
--        if platoon:GetThreatLevel(3) > 0 then
--            target = platoon:FindClosestUnit('Attack', 'Enemy', true, categories.ALLUNITS)
--            if target ~= nil then
--                platoon:Stop()
--                platoon:Patrol(target:GetPosition())
--            end
--        elseif not platoon:IsMoving('Attack') then
--            local frontThreat = ArmyBrains[Aeon]:GetThreatAtPosition( ScenarioUtils.MarkerToPosition('PlayerBaseFront'), 1 )
--            local backThreat = ArmyBrains[Aeon]:GetThreatAtPosition( ScenarioUtils.MarkerToPosition('PlayerBaseBack'), 1 )
--            if frontThreat > backThreat then
--                ScenarioFramework.PlatoonPatrolRoute( platoon, SouthWestAttackRoute )
--            else
--                ScenarioFramework.PlatoonPatrolRoute( platoon, NorthAttackRoute )
--            end
--        end
--    end
--    WaitSeconds(3)
-- end
-- end
--
-- function ScienceAttackThread(platoon, list)
-- platoon:SetPrioritizedTargetList( 'attack', list )
-- while true do
--    if not platoon:IsAttacking('Attack') then
--        if not platoon:IsPatrolling('Attack') then
--            platoon:Patrol(ScenarioUtils.MarkerToPosition('ScienceLab3'))
--        end
--    end
--    WaitSeconds(3)
-- end
-- end
