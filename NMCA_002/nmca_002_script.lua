--****************************************************************************
--**
--**  File     :  /maps/NMCA_002/nmca_002_script.lua
--**  Author(s):  JJs_AI, Exotic_Retard, Zesty_Lime, WiseOldDog
--**
--**  Summary  :  The main script for Nomads Mission 2
--**
--****************************************************************************

local Objectives = import('/lua/SimObjectives.lua')
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local Cinematics = import('/lua/cinematics.lua')
local TauntManager = import('/lua/TauntManager.lua')
local PingGroups = import('/lua/ScenarioFramework.lua').PingGroups

----------
-- AI
----------
local M1_Cybran_AI = import('/maps/NMCA_002/M1_Cybran_AI.lua')
--local M2_Cybran_AI = import('/maps/NMCA_002/M2_Cybran_AI.lua')
local M2_Cybran_Main_AI = import('/maps/NMCA_002/M2_Cybran_Main_AI.lua')
local M2_UEF_Artillery_AI = import('/maps/NMCA_002/M2_UEF_Artillery_AI.lua')
local M2_UEF_Firebase_AI = import('/maps/NMCA_002/M2_UEF_Firebase_AI.lua')

----------
-- Units and Teams
----------
ScenarioInfo.Player1 = 1
ScenarioInfo.Cybran = 2
ScenarioInfo.UEF = 3
ScenarioInfo.Civilians = 4
ScenarioInfo.Nomads = 5
ScenarioInfo.Player2 = 6
ScenarioInfo.Player3 = 7
ScenarioInfo.Player4 = 8

local Player1 = ScenarioInfo.Player1
local Cybran = ScenarioInfo.Cybran
local UEF = ScenarioInfo.UEF
local Civilians = ScenarioInfo.Civilians
local Nomads = ScenarioInfo.Nomads
local Player2 = ScenarioInfo.Player2
local Player3 = ScenarioInfo.Player3
local Player4 = ScenarioInfo.Player4

local Difficulty = ScenarioInfo.Options.Difficulty

AssignedObjectives = {}

local debug = false

function OnPopulate()
	ScenarioUtils.InitializeScenarioArmies()
	ScenarioFramework.SetPlayableArea('M1', false)

	-- Set Unit Cap
	ScenarioFramework.SetSharedUnitCap(1000)
	ScenarioFramework.SetArmyUnitCap(UEF, 1000)
	ScenarioFramework.SetArmyUnitCap(Cybran, 1000)
	ScenarioFramework.SetArmyUnitCap(Nomads, 100)
	ScenarioFramework.SetArmyUnitCap(Civilians, 150)

	-- Set Army Colours
	ScenarioFramework.SetUEFColor(UEF)
	ScenarioFramework.SetCybranColor(Cybran)
	ScenarioFramework.SetNeutralColor(Civilians)
	ScenarioFramework.SetArmyColor('Nomads', 255, 135, 62)

	local colors = {
		['Player1'] = {255, 135, 62},
		['Player2'] = {255, 191, 128},
		['Player3'] = {183, 101, 24},
		['Player4'] = {250, 250, 0}
	}

	local tblArmy = ListArmies()
	for army, color in colors do
		if tblArmy[ScenarioInfo[army]] then
			ScenarioFramework.SetArmyColor(ScenarioInfo[army], unpack(color))
		end
	end
end

function OnStart(self)
	tblArmy = ListArmies()

	local function MissionNameAnnouncement()
		ScenarioFramework.SimAnnouncement(ScenarioInfo.name, 'mission by [e]JJs_AI, [e]Exotic_Retard, Zesty_Lime, [Com]Dog')
	end
	ScenarioFramework.CreateTimerTrigger(MissionNameAnnouncement, 7)

	M1_Cybran_AI:M1CybranBaseFunction()

	----------
	-- Restrictions
	----------
	ScenarioFramework.AddRestrictionForAllHumans(categories.TECH2 + categories.TECH3 + categories.EXPERIMENTAL)

	-- Set Playable Area
	ScenarioUtils.CreateArmyGroup('Civilians', 'M1_Civilian_Outpost')
	ScenarioUtils.CreateArmyGroup('Cybran', 'M1_Outpost_Engineers')
	ScenarioUtils.CreateArmyGroup('Cybran', 'M1_Outpost_Walls')
	ScenarioUtils.CreateArmyGroup('Cybran', 'M1_Outpost_Units')
	ScenarioUtils.CreateArmyGroup('Cybran', 'M1_Initial_PD_D' .. Difficulty)
	ScenarioUtils.CreateArmyGroup('UEF', 'Wreckage', true)

	local OutpostPatrol = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M1_Outpost_Land_Patrol', 'GrowthFormation')
	for _, v in OutpostPatrol:GetPlatoonUnits() do
		ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M1_Outpost_Land_Patrol_Chain')))
	end

    ForkThread(Intro_NIS)
end

function Intro_NIS()
	Cinematics.EnterNISMode()
	Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cinematics_Cam_01_A'), 2)
	WaitSeconds(2)
	Cinematics.ExitNISMode()

	ForkThread(SpawnInitalUnits)

	M1_Objectives()
	M1_UEF_Attacks()
end

function M1_Objectives()
	ScenarioInfo.M1P1 = Objectives.CategoriesInArea(
		'primary',                      -- type
		'incomplete',                   -- complete
		'Destroy Cybran Defensive Line',  -- title
		'We need to push through the line of Cybran Defenses. Destroy all Cybran Defensive Structures.',  -- description
		'kill',
		{
			MarkUnits = true,
			Requirements = {
				{
					Area = 'CybranObjectiveArea', 
					Category = categories.DEFENSE - categories.WALL + categories.urb2303, 
					CompareOp = '<=', 
					Value = 0, 
					ArmyIndex = Cybran
				},
			},
		}
	)
	ScenarioInfo.M1P1:AddResultCallback(
		function(result)
			if(result) then
				ForkThread(M2_Intro_NIS)
			end
		end
	)
	table.insert(AssignedObjectives, ScenarioInfo.M1P1)

	ScenarioInfo.M1S1 = Objectives.CategoriesInArea(
		'secondary',                      -- type
		'incomplete',                   -- complete
		'Destroy Cybran Production',  -- title
		'That Cybran outpost will keep sending attacks at you. Destroy the factories at your discretion.',  -- description
		'kill',
		{
			MarkUnits = true,
			Requirements = {
				{
					Area = 'CybranObjectiveArea', 
					Category = categories.FACTORY + categories.ENGINEER, 
					CompareOp = '<=', 
					Value = 0, 
					ArmyIndex = Cybran
				},
			},
		}
	)
	ScenarioInfo.M1S1:AddResultCallback(
		function(result)
			if(result) then
				-- gg
			end
		end
	)
	table.insert(AssignedObjectives, ScenarioInfo.M1S1)
end

function M1_UEF_Attacks()
	-- Spawn and send units to attack
	while ScenarioInfo.M1P1.Active do
		WaitSeconds(120)
		if ScenarioInfo.M1P1.Active then -- Check if the objective is still active to prevent attacks being spawned if the map has expanded.
			ScenarioInfo.M1UEFAirAttack = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M1_Air_Attacks', 'AttackFormation')
			ScenarioInfo.M1UEFAirAttack.PlatoonData = {}
			ScenarioInfo.M1UEFAirAttack.PlatoonData.PatrolChain = 'M1_UEF_Air_Attack'
			ScenarioInfo.M1UEFAirAttack:ForkAIThread(ScenarioPlatoonAI.PatrolThread)

			ScenarioInfo.M1UEFLandAttack = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M1_Land_Attacks', 'AttackFormation')
			ScenarioInfo.M1UEFLandAttack.PlatoonData = {}
			ScenarioInfo.M1UEFLandAttack.PlatoonData.PatrolChain = 'M1_UEF_Land_Attack'
			ScenarioInfo.M1UEFLandAttack:ForkAIThread(ScenarioPlatoonAI.PatrolThread)
		end
	end
end

function M2_Intro_NIS()
	if ScenarioInfo.M1S1.Active then
		ScenarioInfo.M1S1:ManualResult(true)
	end

	-- Create Units
	ScenarioInfo.Colony = ScenarioUtils.CreateArmyGroup('Civilians', 'M2_Settlement')
	ScenarioUtils.CreateArmyGroup('Civilians', 'M2_Settlement_Walls')
	ScenarioUtils.CreateArmyGroup('Cybran', 'M2_Cybran_Civilian_Defenses')
	ScenarioUtils.CreateArmyGroup('UEF', 'M2_Artillery_Engineers')
	ScenarioInfo.CybranACU = ScenarioUtils.CreateArmyUnit('Cybran', 'ACU')
	ScenarioInfo.CybranACU:SetCustomName("CDR Jerrax")

	M2_Cybran_Main_AI.M2CybranBaseFunction()

	ScenarioUtils.CreateArmyGroup('Cybran', 'M2_Cybran_Walls')
	ScenarioUtils.CreateArmyGroup('UEF', 'M2_NIS_Units')
	ScenarioUtils.CreateArmyGroup('UEF', 'M2_Firebase_Walls')
	ScenarioUtils.CreateArmyGroup('UEF', 'M2_Firebase_Engineers')

	-- UEF Outpost
	M2_UEF_Firebase_AI.M2UEFFireBaseFunction()

	-- Relevant Cybran Patrols
	ScenarioInfo.PatrolUnitsNIS = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2_NIS_Units', 'AttackFormation')
	for _, v in ScenarioInfo.PatrolUnitsNIS:GetPlatoonUnits() do
		ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M2_NIS_Remaining_Units_Patrol_Chain')))
	end

	-- Relevant UEF Patrols
	ScenarioInfo.UEFAirPatrol = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M2_Firebase_Air_Patrol', 'AttackFormation')
	for _, v in ScenarioInfo.UEFAirPatrol:GetPlatoonUnits() do
		ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M2_UEF_Firebase_Air_Patrol_Chain')))
	end

	WaitSeconds(5)
	ScenarioUtils.CreateArmyGroup('Cybran', 'M2_Cybran_Main_Base_Support')
	ScenarioUtils.CreateArmyGroup('UEF', 'M2_Firebase_Supports')

	-- Extend Playable Area
	ScenarioFramework.SetPlayableArea('M2', true)

	-- Cinematics
	Cinematics.EnterNISMode()
	Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('M2_NIS_Cam_1'), 2)
	WaitSeconds(7)
	Cinematics.ExitNISMode()

	-- Fix Alliances
	for _, player in ScenarioInfo.HumanPlayers do
		SetAlliance(player, Cybran, 'Ally')
	end
	for _, player in ScenarioInfo.HumanPlayers do
		SetAlliance(Cybran, player, 'Ally')
	end

	-- Call Objectives
	M2_UEF_Artillery_AI.M2UEFArtilleryBaseFunction()
	M2_Objectives()
end

function M2_Objectives()
	ScenarioInfo.M2P1 = Objectives.Protect(
		'primary',
		'incomplete',
		'Defend Cybran Settlement',
		'The Cybran has asked for assistance against the UEF. You must defend the Cybran Settlement from the UEF. In return, the Cybran has offered some valuable information. At least 50% of the Settlement must survive!',
		{
			Units = ScenarioInfo.Colony,
			NumRequired = math.ceil(table.getn(ScenarioInfo.Colony)/2),
			PercentProgress = true,
			ShowFaction = 'Cybran',
		}
	)
	ScenarioInfo.M2P1:AddResultCallback(
		function(result)
			if(result) then
			end
		end
	)
	table.insert(AssignedObjectives, ScenarioInfo.M2P1)

	WaitSeconds(10)

	ScenarioInfo.M2S1 = Objectives.Protect(
		'secondary',
		'incomplete',
		'Ensure Cybran Safety',
		'The Cybran Commander is under heavy attack. His base is formidable but it won\'t survive much longer. Assist the Cybran where necessary.',
		{
			Units = {ScenarioInfo.CybranACU},
			MarkUnits = true,
		}
	)
	ScenarioInfo.M2S1:AddResultCallback(
		function(result)
			if(result) then
			end
		end
	)
	table.insert(AssignedObjectives, ScenarioInfo.M2S1)

	WaitSeconds(30)
	ScenarioInfo.M2P2 = Objectives.CategoriesInArea(
		'primary',
		'incomplete',
		'Destroy UEF Firebase',
		'The Cybran has informed us that there is a UEF Firebase to his north. Destroy all UEF Factories and Engineers.',
		'kill',
		{
			MarkUnits = true,
			Requirements = {
				{
					Area = 'M2_UEF_Firebase_Area', 
					Category = categories.FACTORY + categories.ENGINEER, 
					CompareOp = '<=', 
					Value = 0, 
					ArmyIndex = UEF
				},
			},
		}
	)
	ScenarioInfo.M2P2:AddResultCallback(
		function(result)
			if(result) then
			end
		end
	)
	table.insert(AssignedObjectives, ScenarioInfo.M2P2)
end

-- Utility Functions --

function SpawnInitalUnits()
    LOG("Spawning Players")
    ScenarioInfo.PlayerACUs = {}
    local tblArmy = ListArmies()
    local i = 1
    while tblArmy[ScenarioInfo['Player' .. i]] do
        ScenarioInfo['Player' .. i .. 'CDR'] = ScenarioFramework.SpawnCommander('Player' .. i, 'CDR', 'Warp', true, true, PlayerDeath)
        table.insert(ScenarioInfo.PlayerACUs, ScenarioInfo['Player' .. i .. 'CDR'])
        WaitSeconds(2)
        i = i + 1
    end
end

function PlayerDeath(Player)
	LOG("ACU Death")
	if(not ScenarioInfo.OpEnded) then
		ScenarioFramework.CDRDeathNISCamera(Player)
		ForkThread(Mission_Failed)
	end
end

function Mission_Failed()
	ScenarioFramework.EndOperationSafety()
	ScenarioFramework.FlushDialogueQueue()
	for k, v in AssignedObjectives do
		if(v and v.Active) then
			v:ManualResult(false)
		end
	end
	ScenarioInfo.OpComplete = false
	ForkThread(
		function()
			WaitSeconds(5)
			UnlockInput()
			Kill_Game()
		end
	)
end

function Kill_Game()
    UnlockInput()
    local allPrimaryCompleted = true
    local allSecondaryCompleted = true
    ScenarioFramework.EndOperation(ScenarioInfo.OpComplete, allPrimaryCompleted, allSecondaryCompleted)
end