--****************************************************************************
--**
--**  File     :  /maps/NMCA_001/NMCA_001_script.lua
--**  Author(s):  JJs_AI, Tokyto_
--**
--**  Summary  :  Ths script for the first mission of the Nomads campaign.
--**
--****************************************************************************

local Objectives = import('/lua/SimObjectives.lua')
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local Cinematics = import('/lua/cinematics.lua')
local OpStrings = import('/maps/NMCA_001/NMCA_001_strings.lua')
local TauntManager = import('/lua/TauntManager.lua')
local PingGroups = import('/lua/ScenarioFramework.lua').PingGroups

----------
-- AI
----------
local M1OutpostAI = import('/maps/NMCA_001/NMCA_001_M1_AI.lua')
local M2FirebaseAI = import('/maps/NMCA_001/NMCA_001_M2_AI.lua')
local M3BaseAI = import('/maps/NMCA_001/NMCA_001_M3_AI.lua')
local M3FirebaseAI_1 = import('/maps/NMCA_001/NMCA_001_M3_Firebase_1_AI.lua')
local M3FirebaseAI_2 = import('/maps/NMCA_001/NMCA_001_M3_Firebase_2_AI.lua')

ScenarioInfo.Player1 = 1
ScenarioInfo.UEF = 2
ScenarioInfo.Civilian = 3
ScenarioInfo.Nomads = 4
ScenarioInfo.Coop1 = 5
ScenarioInfo.Coop2 = 6
ScenarioInfo.Coop3 = 7

local Player1 = ScenarioInfo.Player1
local UEF = ScenarioInfo.UEF
local Civilian = ScenarioInfo.Civilian
local Nomads = ScenarioInfo.Nomads
local Player2 = ScenarioInfo.Coop1
local Player3 = ScenarioInfo.Coop2
local Player4 = ScenarioInfo.Coop3

local Difficulty = ScenarioInfo.Options.Difficulty

local UEFM1Timer = {900, 600, 450}
local TMLTimer = {450, 375, 300}
local M1TransportTimer = {450, 400, 350}
local BombAbilCoolDown = {240, 300, 420}

local Spotted = false
local PlayerLost = false
local FactoryCaptured = false

local AssignedObjectives = {}

----------------
-- Taunt Managers
----------------
local M1UEFTM = TauntManager.CreateTauntManager('M1UEFTM', '/maps/NMCA_001/NMCA_001_strings.lua')
local M3UEFTM = TauntManager.CreateTauntManager('M3UEFTM', '/maps/NMCA_001/NMCA_001_strings.lua')
  
function OnPopulate()
    ScenarioUtils.InitializeScenarioArmies()

    SetArmyColor('Player1', 225, 135, 62)
    SetArmyColor('UEF', 41, 40, 140)
    SetArmyColor('Civilian', 71, 114, 148)
    SetArmyColor('Nomads', 225, 135, 62)

	----------
	-- Coop Colours
	----------
    local colors = {
        ['Player2'] = {250, 250, 0}, 
        ['Player3'] = {183, 101, 24}, 
        ['Player4'] = {255, 191, 128}
    }
    local tblArmy = ListArmies()
    for army, color in colors do
       if tblArmy[ScenarioInfo[army]] then
           ScenarioFramework.SetArmyColor(ScenarioInfo[army], unpack(color))
       end
    end

	----------
	-- Unit Cap
	----------
	SetArmyUnitCap(Player1, 300)
	SetArmyUnitCap(UEF, 450)
end
  
function OnStart(self)
	ScenarioFramework.SetPlayableArea('M1', false)
	----------
	-- Restrictions
	----------
    ScenarioFramework.AddRestrictionForAllHumans(categories.TECH2 + categories.TECH3 + categories.EXPERIMENTAL)
    ScenarioFramework.AddRestrictionForAllHumans(categories.ina1003) # Attack Bomber
    ScenarioFramework.AddRestrictionForAllHumans(categories.uel0105) # UEF Engineer
    ScenarioFramework.AddRestrictionForAllHumans(categories.ina1005) # Transport Drone
    ScenarioFramework.AddRestrictionForAllHumans(categories.inu1004) # Medium Tank
    ScenarioFramework.AddRestrictionForAllHumans(categories.inu1008) # Tank Destroyer
    ScenarioFramework.AddRestrictionForAllHumans(categories.NAVAL) # Navy

	----------
	-- Set Storage
	----------
	ForkThread(function()
        for _, player in ScenarioInfo.HumanPlayers do
    		ArmyBrains[player]:GiveStorage('ENERGY', 4000)
    		ArmyBrains[player]:GiveStorage('MASS', 650)
            WaitSeconds(2)
            ArmyBrains[player]:GiveResource('ENERGY', 4000)
    		ArmyBrains[player]:GiveResource('MASS', 650)
    	end
    end)

	----------
	-- Spawn Things
	----------
	local Engineers = ScenarioUtils.CreateArmyGroup('Player1', 'Engineers')
	ScenarioInfo.Ship = ScenarioUtils.CreateArmyUnit('Player1', 'Ship')

	ScenarioUtils.CreateArmyGroup('Civilian', 'CivilianGroup')
	ScenarioInfo.UEFTech = ScenarioUtils.CreateArmyUnit('UEF', 'TechCentre')

    ScenarioInfo.UEFTech:SetCanTakeDamage(false)
    ScenarioInfo.UEFTech:SetCanBeKilled(false)
    ScenarioInfo.UEFTech:SetDoNotTarget(true)
    ScenarioInfo.UEFTech:SetReclaimable(false)

	ScenarioUtils.CreateArmyGroup('UEF', 'M1Walls')

	ScenarioInfo.Ship:SetCustomName('Command Ship')
    ScenarioInfo.Ship:SetCanBeKilled(false)
    ScenarioInfo.Ship:SetReclaimable(false)
	ScenarioInfo.UEFTech:SetCustomName('Tech Centre')

    IssueMove(Engineers, ScenarioUtils.MarkerToPosition('M1_Nomads_Engineer_Move_Marker'))

    local units = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'AirPatrol_' .. Difficulty, 'NoFormation')

    for _, v in units:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M1_AirPatrol_Chain')))
    end

    local units = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'LabPatrol_1', 'GrowthFormation')

    for _, v in units:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('LabPatrol_1_Chain')))
    end

    local units = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'LabPatrol_2', 'GrowthFormation')

    for _, v in units:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('LabPatrol_2_Chain')))
    end

    local units = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'LabPatrol_3', 'GrowthFormation')

    for _, v in units:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('LabPatrol_3_Chain')))
    end

    ----------
    -- Remove the Pesky Ship
    ----------
    for _, player in ScenarioInfo.HumanPlayers do
        local ship = GetEntityById('INO0001')
        ship:Destroy()
    end

    ----------
    -- Run AI
    ----------
    M1OutpostAI.UEFOutpostAI()

    ----------
    -- Cinematics
    ----------
    ForkThread(M1NIS)
end

function PlayerWin()
    -- Mark objectives as failed
    for k, v in AssignedObjectives do
        if(v and v.Active) then
            v:ManualResult(true)
        end
    end

    KillGame()
end

function PlayerLose(Ship)
	----------
	-- Player Lost Game
	----------
    PlayerLost = true
    
    -- Mark objectives as failed
    for k, v in AssignedObjectives do
        if(v and v.Active) then
            v:ManualResult(false)
        end
    end

	ScenarioFramework.CDRDeathNISCamera(Ship)

    M1OutpostAI.DisableBase()
    M3BaseAI.DisableBase()
    ScenarioFramework.EndOperationSafety()
end

function KillGame()
    local secondaries = Objectives.IsComplete(ScenarioInfo.M2S1) and Objectives.IsComplete(ScenarioInfo.M3S1) and Objectives.IsComplete(ScenarioInfo.M3S2) and Objectives.IsComplete(ScenarioInfo.M3S3)
    ScenarioFramework.EndOperation(true, true, secondaries)
end

function M1NIS()
	local Engineer1 = ScenarioInfo.UnitNames[Player1]['Engineer_1']
    local Engineer2 = ScenarioInfo.UnitNames[Player1]['Engineer_2']
    local Engineer3 = ScenarioInfo.UnitNames[Player1]['Engineer_3']
    local Engineer4 = ScenarioInfo.UnitNames[Player1]['Engineer_4']

	ScenarioFramework.CreateUnitDamagedTrigger(PlayerLose, ScenarioInfo.Ship, .75)

	WaitSeconds(1)

	Cinematics.EnterNISMode()

	ScenarioFramework.Dialogue(OpStrings.IntroNIS_Dialogue, nil, true)
	Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cutscene_01a'), 0)
	WaitSeconds(.5)
	Cinematics.CameraTrackEntity(Engineer1, 40, 3)

	WaitSeconds(7)

	Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cutscene_01b'), 2)

	Cinematics.ExitNISMode()

    if table.getn(ScenarioInfo.HumanPlayers) == 2 then
        ScenarioFramework.GiveUnitToArmy(Engineer2, Player2)
        ScenarioFramework.GiveUnitToArmy(Engineer3, Player2)
    elseif table.getn(ScenarioInfo.HumanPlayers) == 3 then
        ScenarioFramework.GiveUnitToArmy(Engineer2, Player2)
        ScenarioFramework.GiveUnitToArmy(Engineer3, Player3)
    elseif table.getn(ScenarioInfo.HumanPlayers) == 4 then
        ScenarioFramework.GiveUnitToArmy(Engineer2, Player2)
        ScenarioFramework.GiveUnitToArmy(Engineer3, Player3)
        ScenarioFramework.GiveUnitToArmy(Engineer4, Player4)
    end

	WaitSeconds(1)
	M1()
end


function M1()
	ScenarioFramework.CreateTimerTrigger(M1StartUEFScouting, UEFM1Timer[Difficulty])

	local function MissionNameAnnouncement()
        ScenarioFramework.SimAnnouncement(ScenarioInfo.name, 'mission by [e]JJs_AI & [e]Tokyto_')
    end

    ScenarioFramework.CreateTimerTrigger(MissionNameAnnouncement, 7)

    ScenarioInfo.M1P1 = Objectives.Protect(
        'primary',                    -- type
        'incomplete',                   -- complete
        OpStrings.M1P1Text,  -- title
        OpStrings.M1P1Desc,  -- description
        {                               -- target
            Units = {ScenarioInfo.Ship},
        }
    )
    table.insert(AssignedObjectives, ScenarioInfo.M1P1)

	ScenarioFramework.CreateArmyIntelTrigger(ForkAttackThread, ArmyBrains[UEF], 'LOSNow', false, true,  categories.NOMADS, true, ArmyBrains[Player1] )
end

function M1StartUEFScouting()
    if ScenarioInfo.M2P1.Active then
    	----------
    	-- Scouting Starts
    	----------
    	local Scouts = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'Scouts','NoFormation')

    	for k, v in Scouts:GetPlatoonUnits() do
        	ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M1_UEF_Scout_Chain')))
        end
    end
end

function ForkAttackThread()
    ForkThread(M1StartUEFAttacks)
end

function M1StartUEFAttacks()
	if not Spotted then
		ScenarioFramework.Dialogue(OpStrings.UEF_Notice, nil, true)
		
		WaitSeconds(7)	

		local VisMarker1_1 = ScenarioFramework.CreateVisibleAreaLocation(10, 'M1_Vis_1_1', 0, ArmyBrains[Player1])
		ScenarioInfo.TacLauncher = ScenarioInfo.UnitNames[UEF]['TacMissile']

		Cinematics.EnterNISMode()

		Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cutscene_01c'), 0)
		WaitSeconds(4)
		IssueTactical({ScenarioInfo.TacLauncher}, ScenarioUtils.MarkerToPosition('M1_TacMissile_Target'))
		WaitSeconds(5)	

		Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cutscene_01b'), 2)

		VisMarker1_1:Destroy()

		Cinematics.ExitNISMode()

		WaitSeconds(10)	
		ScenarioFramework.Dialogue(OpStrings.M1_Scream_Incoming, nil, true)
		WaitSeconds(9)
		ScenarioFramework.Dialogue(OpStrings.M1_Update_Commander, nil, true)

	    Spotted = true

		----------
		-- Start Attacks
		----------
		M1OutpostAI.M1LandAttacks()
		M1OutpostAI.M1AirAttacks()

		----------
		-- Set Timer for Missile Launches
		----------
		ScenarioFramework.CreateUnitDeathTrigger(TacDead, ScenarioInfo.TacLauncher)
		ScenarioFramework.CreateTimerTrigger(LaunchTac, TMLTimer[Difficulty])
		ScenarioFramework.CreateTimerTrigger(M1Reinforcements, M1TransportTimer[Difficulty])

		WaitSeconds(10)

        UEFM1Taunts()

		M2()

        WaitSeconds(8)
        ScenarioFramework.PlayUnlockDialogue()
        ScenarioFramework.RemoveRestrictionForAllHumans(categories.ina1003)
        ScenarioFramework.RemoveRestrictionForAllHumans(categories.ina1005)
	end
end

function M1Reinforcements()
    if not PlayerLost and ScenarioInfo.M2P1.Active then
    	----------
    	-- Transports
    	----------
    	local allUnits = {}

    	local base_platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M2_Reinforcements','AttackFormation')
    	local attack_platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M2_Reinforcements_Attack', 'AttackFormation')

    	for i = 1, 4 do
    	   	local transport = ScenarioUtils.CreateArmyUnit('UEF', 'M2_Transport')

    	    for _, v in attack_platoon:GetPlatoonUnits() do
    	        table.insert(allUnits, v)
    	    end

    	    ScenarioFramework.AttachUnitsToTransports(attack_platoon:GetPlatoonUnits(), {transport})
    	    WaitSeconds(0.5)
    		IssueTransportUnload({transport}, ScenarioUtils.MarkerToPosition('M2_Transport_Drop_' .. i))
    		IssueMove({transport}, ScenarioUtils.MarkerToPosition('UEF_Main_Base'))
            ScenarioFramework.PlatoonPatrolChain(attack_platoon, 'M2_Transport_Attack_Route')
    	end

    	for i = 1, 2 do
    	   	local transport = ScenarioUtils.CreateArmyUnit('UEF', 'M2_Transport')

    	    for _, v in base_platoon:GetPlatoonUnits() do
    	        table.insert(allUnits, v)
    	    end

    	    ScenarioFramework.AttachUnitsToTransports(base_platoon:GetPlatoonUnits(), {transport})
    	    WaitSeconds(0.5)
    		IssueTransportUnload({transport}, ScenarioUtils.MarkerToPosition('M2_Transport_Base_Drop_' .. i))
    		IssueMove({transport}, ScenarioUtils.MarkerToPosition('UEF_Main_Base'))
    		ScenarioFramework.PlatoonPatrolChain(base_platoon, 'M2_Outpost_Patrol')
    	end
    end
end

function M2()
    ----------
    -- Timer Triggers (Reminders)
    ----------
    ScenarioFramework.CreateTimerTrigger(TacticalLauncherReminder, 600)
    ScenarioFramework.CreateTimerTrigger(OutpostReminder, 600)

	----------
	-- Objectives
	----------
	ScenarioInfo.M2P1 = Objectives.CategoriesInArea(
        'primary',                      -- type
        'incomplete',                   -- complete
        OpStrings.M2P1Text,  -- title
        OpStrings.M2P1Desc,  -- description
        'kill',
        {
            MarkUnits = false,
            Requirements = {
                { Area = 'M1Outpost', Category = categories.FACTORY + categories.ENGINEER, CompareOp = '<=', Value = 0, ArmyIndex = UEF},
            },
        }
    )
    ScenarioInfo.M2P1:AddResultCallback(
        function(result)
            if(result) then
                M1OutpostAI.DisableBase()
                ScenarioFramework.Dialogue(OpStrings.UEFOutpost_Dead, nil, true)
                Cinematics.EnterNISMode()
                Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cutscene_02b'), 1)
                WaitSeconds(4)
                Cinematics.ExitNISMode()
                M2Capture()
            end
        end
    )
    table.insert(AssignedObjectives, ScenarioInfo.M2P1)

    ----------
    -- Destroy Tac Objective
    ----------
    ScenarioInfo.M2P2 = Objectives.KillOrCapture(
        'primary',                      -- type
        'incomplete',                   -- complete
        OpStrings.M2P2Text,  -- title
        OpStrings.M2P2Desc,  -- description
        {                               -- target
            Units = {ScenarioInfo.TacLauncher}
        }
    )
    table.insert(AssignedObjectives, ScenarioInfo.M2P2)
end

function M2Capture()
    ScenarioUtils.CreateArmyGroup('Civilian', 'M2')
    ScenarioFramework.SetPlayableArea('M2', true)
    ScenarioInfo.UEFFactory = ScenarioInfo.UnitNames[Civilian]['Factory']

    ----------
    -- Spawn Base
    ----------
    ScenarioUtils.CreateArmyGroup('UEF', 'M3Walls')
    ScenarioUtils.CreateArmyGroup('UEF', 'M3Engineers')

    ----------
    -- Run AI
    ----------
    M2FirebaseAI.UEFFireBaseAI()
    ScenarioUtils.CreateArmyGroup('UEF', 'M2Walls')

    M3BaseAI.UEFBaseAI()
    ScenarioInfo.EnemyCommander = ScenarioUtils.CreateArmyUnit('UEF', 'Commander')
    ScenarioInfo.EnemyCommander:SetCustomName("CDR Parker")

    M3FirebaseAI_1:UEFM3FireBase1()
    M3FirebaseAI_2:UEFM3FireBase2()

    if Difficulty == 1 then
        ScenarioInfo.EnemyCommander:CreateEnhancement('AdvancedEngineering')
        ScenarioInfo.EnemyCommander:CreateEnhancement('LeftPod')
        ScenarioInfo.EnemyCommander:CreateEnhancement('RightPod')
    elseif Difficulty == 2 then
        ScenarioInfo.EnemyCommander:CreateEnhancement('AdvancedEngineering')
        ScenarioInfo.EnemyCommander:CreateEnhancement('Shield')
        ScenarioInfo.EnemyCommander:CreateEnhancement('ResourceAllocation')   
    elseif Difficulty == 3 then
        ScenarioInfo.EnemyCommander:CreateEnhancement('AdvancedEngineering')
        ScenarioInfo.EnemyCommander:CreateEnhancement('Shield')
        ScenarioInfo.EnemyCommander:CreateEnhancement('HeavyAntiMatterCannon')
    end

    ----------
    -- Spawn PBase
    ----------
    ScenarioUtils.CreateArmyGroup('UEF', 'PowerBase')
    ScenarioUtils.CreateArmyGroup('UEF', 'M3PWalls')
    ScenarioUtils.CreateArmyGroup('UEF', 'M3Shields')

    ----------
    -- Spawn Patrols
    ----------
    local units = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M3_AirPatrol_' .. Difficulty, 'NoFormation')

    for k, v in units:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M3_AirPatrol_Chain')))
    end

    local AttackUnits = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M3_Init_Attack_' .. Difficulty, 'GrowthFormation')

    for k, v in AttackUnits:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M3_LandAttack_Chain')))
    end

    local PBasePatrol = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M3PBasePatrol', 'GrowthFormation')

    for k, v in PBasePatrol:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M3_PBase_Patrol_Chain')))
    end

    local BasePatrol = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M3BasePatrol_' .. Difficulty, 'GrowthFormation')

    for k, v in BasePatrol:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M3_Base_Patrol_Chain')))
    end

    ----------
    -- Dialogue
    ----------
    ScenarioFramework.Dialogue(OpStrings.M2_Update_Commander, M2ObjectviesExtended, true)
end

function M2ObjectviesExtended()
    ----------
    -- Timer Triggers (Reminders)
    ----------
    ScenarioFramework.CreateTimerTrigger(TechReminder, 450)

    ----------
    -- Objectives
    ----------
    ScenarioInfo.M2P3 = Objectives.Capture(
        'primary',                      -- type
        'incomplete',                   -- complete
        OpStrings.M2P3Text,  -- title
        OpStrings.M2P3Desc,  -- description
        {
            FlashVisible = true,
            Units = {ScenarioInfo.UEFTech},
        }
    )
    ScenarioInfo.M2P3:AddResultCallback(
        function(result)
            if(result) then
                ScenarioFramework.Dialogue(OpStrings.M2TechCaptured, M3, true)
            end
        end
    )
    table.insert(AssignedObjectives, ScenarioInfo.M2P3)

    ----------
    -- Capture UEF Factory
    ----------
    ScenarioInfo.M2S1 = Objectives.Capture(
        'secondary',                      -- type
        'incomplete',                   -- complete
        OpStrings.M2S1Text,  -- title
        OpStrings.M2S1Desc,  -- description
        {                            -- target
            Units = {ScenarioInfo.UEFFactory},
        }
    )
    ScenarioInfo.M2S1:AddResultCallback(
        function(result, units)
            ScenarioFramework.PlayUnlockDialogue()
            ScenarioFramework.RemoveRestrictionForAllHumans(categories.inu1004)

            ScenarioInfo.NFactory = units[1]
            FactoryCaptured = true
            if not ScenarioInfo.NFactory:IsDead() then
                ScenarioFramework.Dialogue(OpStrings.UEFTauntFactory, nil, true)
            end
        end
    )
    table.insert(AssignedObjectives, ScenarioInfo.M2S1)
end

function M3()
    ScenarioFramework.SetPlayableArea('M3', true)

    ScenarioFramework.Dialogue(OpStrings.M3_Update_Commander, nil, true)
    if FactoryCaptured then
        ScenarioFramework.CreateTimerTrigger(M3SetFactoryObjective, 120)
    end

    ----------
    -- Timer Triggers (Reminders)
    ----------
    ScenarioFramework.CreateTimerTrigger(EnemyReminder, 550)

    ----------
    -- Cinematics
    ----------
    local VisMarker3_1 = ScenarioFramework.CreateVisibleAreaLocation(80, 'M3_UEF_Base_Marker', 0, ArmyBrains[Player1])
    local VisMarker3_2 = ScenarioFramework.CreateVisibleAreaLocation(40, 'M3PBase', 0, ArmyBrains[Player1])

    ForkThread(function()
        Cinematics.EnterNISMode()
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cutscene_03a'), 1)
        WaitSeconds(1)
        Cinematics.CameraTrackEntity(ScenarioInfo.EnemyCommander, 40, 2)
        WaitSeconds(5)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cutscene_03b'), 1)
        WaitSeconds(5)
        VisMarker3_1:Destroy()
        VisMarker3_2:Destroy()
        Cinematics:ExitNISMode()
    end)

    ----------
    -- Unlock T2 Air Factory
    ----------
    ScenarioFramework.PlayUnlockDialogue()
    ScenarioFramework.RemoveRestrictionForAllHumans(categories.inb0202)
    ScenarioFramework.RemoveRestrictionForAllHumans(categories.inb0212)

    ----------
    -- Objectives
    ----------
    ScenarioInfo.M3P1 = Objectives.KillOrCapture(
        'primary',                      -- type
        'incomplete',                   -- complete
        OpStrings.M3P1Text,  -- title
        OpStrings.M3P1Desc, -- description
        {                               -- target
            Units = {ScenarioInfo.EnemyCommander}
        }
    )
    ScenarioInfo.M3P1:AddResultCallback(
        function(result)
            if(result) then
                ScenarioFramework.CDRDeathNISCamera(ScenarioInfo.EnemyCommander)
                M3BaseAI.DisableBase()
                ScenarioFramework.EndOperationSafety()
                ScenarioFramework.Dialogue(OpStrings.EnemyDead, PlayerWin, true)
            end
        end
    )
    table.insert(AssignedObjectives, ScenarioInfo.M3P1) 

    ----------
    -- Destroy Power Base
    ----------
    ScenarioInfo.M3S1 = Objectives.CategoriesInArea(
        'secondary',                      -- type
        'incomplete',                   -- complete
        OpStrings.M3S1Text,  -- title
        OpStrings.M3S1Desc,  -- description
        'kill',
        {
            MarkUnits = true,
            Requirements = {
                { Area = 'M3Power', Category = categories.ueb1201, CompareOp = '<=', Value = 0, ArmyIndex = UEF},
                { Area = 'M3Power', Category = categories.ueb1201, CompareOp = '<=', Value = 0, ArmyIndex = UEF},
                { Area = 'M3Power', Category = categories.ueb1201, CompareOp = '<=', Value = 0, ArmyIndex = UEF},
            },
        }
    )
    ScenarioInfo.M3S1:AddResultCallback(
        function(result)
            if(result) then
                M3BaseAI.DisableShields()
                ScenarioFramework.Dialogue(OpStrings.M3ShieldsDead, nil, true)
            end
        end
    )
    table.insert(AssignedObjectives, ScenarioInfo.M3S1)

    ----------
    -- Build T2 Air Factory
    ----------
    ScenarioInfo.M3S2 = Objectives.CategoriesInArea(
        'secondary',                      -- type
        'incomplete',                   -- complete
        OpStrings.M3S2Text,  -- title
        OpStrings.M3S2Desc,  -- description
        'Build',
        {
            MarkUnits = false,
            MarkArea = false,
            Requirements =
            {
                {Area = 'M3', Category = categories.inb0202, CompareOp = '>=', Value = 1, ArmyIndex = Player1},
            },
        }
    )
    ScenarioInfo.M3S2:AddResultCallback(
        function(result)
            if(result) then
                ScenarioFramework.Dialogue(OpStrings.Tech2AirFactoryBuilt, nil, true)
                ForkThread(GiveOrbitalBombardmentAbil)
            end
        end
    )  
    table.insert(AssignedObjectives, ScenarioInfo.M3S2)
end

function M3SetFactoryObjective()
    ScenarioFramework.Dialogue(OpStrings.M3_ProtectFactory, nil, true)

    ScenarioInfo.M3S3 = Objectives.Protect(
        'secondary',                      -- type
        'incomplete',                   -- complete
        OpStrings.M3S3Text,  -- title
        OpStrings.M3S3Desc,  -- description
        {
            Units = {ScenarioInfo.NFactory},
        }
    )
    table.insert(AssignedObjectives, ScenarioInfo.M3S3)
    
    ScenarioFramework.CreateUnitDeathTrigger(FacDead, ScenarioInfo.NFactory)
end

function TacDead()
	ScenarioInfo.M2P2:ManualResult(true)
    ScenarioFramework.Dialogue(OpStrings.M1_Tac_Dead, nil, true)
end

function LaunchTac()
	if not ScenarioInfo.TacLauncher:IsDead() then
		IssueTactical({ScenarioInfo.TacLauncher}, ScenarioUtils.MarkerToPosition('M1_TacMissile_Target'))
		ScenarioFramework.CreateTimerTrigger(LaunchTac, TMLTimer[Difficulty])
	else
		return
	end
end

function FacDead()
    ScenarioInfo.M3S1:ManualResult(false)
    ScenarioFramework.Dialogue(OpStrings.M3FactoryDead, nil, true)
    ScenarioFramework.AddRestrictionForAllHumans(categories.inu1004) # Medium Tank
end

function GiveOrbitalBombardmentAbil()
    ScenarioFramework.Dialogue(OpStrings.OrbStrikeReady, nil, true)
    ScenarioInfo.M2AttackPing = PingGroups.AddPingGroup('Signal Air Strike', nil, 'attack', 'Mark a location for the bombers to attack')
    ScenarioInfo.M2AttackPing:AddCallback(SendBombers)
end

function SendBombers(location)
    ForkThread(function()
        local Bombers = ScenarioUtils.CreateArmyGroup('Nomads', 'OrbStrikeBombers_' .. Difficulty)
        local delBomb = ScenarioUtils.MarkerToPosition('DestroyBombers')
        ScenarioInfo.M2AttackPing:Destroy()

        ----------
        -- Send Bombers
        ----------
        for _, v in Bombers do
            if(v and not v:IsDead()) then
                IssueStop({v})
                IssueClearCommands({v})
                v:SetFireState('GroundFire')
                IssueAttack({v}, location)
                IssueMove({v}, delBomb)
            end
        end

        ----------
        -- Trigger a Remove
        ----------
        for _, v in Bombers do
            WaitSeconds(10)
            ScenarioFramework.CreateUnitToMarkerDistanceTrigger(DestroyUnit, v, delBomb, 15)
        end

        ScenarioFramework.CreateTimerTrigger(GiveOrbitalBombardmentAbil, BombAbilCoolDown[Difficulty])
    end)
end

function DestroyUnit(unit)
    unit:Destroy()
end


----------
-- Taunts
----------
function UEFM1Taunts()
    M1UEFTM:AddUnitsKilledTaunt('TAUNT1', ArmyBrains[Player1], categories.MOBILE, 60)
    M1UEFTM:AddUnitsKilledTaunt('TAUNT2', ArmyBrains[Player1], categories.ALLUNITS, 95)
    M1UEFTM:AddDamageTaunt('TAUNT3', ScenarioInfo.Ship, .50)
    M1UEFTM:AddUnitsKilledTaunt('TAUNT4', ArmyBrains[Player1], categories.MOBILE, 120)
    M1UEFTM:AddUnitsKilledTaunt('TAUNT5', ArmyBrains[Player1], categories.STRUCTURE, 10)
    M1UEFTM:AddUnitsKilledTaunt('TAUNT6', ArmyBrains[Player1], categories.STRUCTURE, 16)   
end

function UEFM3Taunts()
    M3UEFTM:AddTauntingCharacter(ScenarioInfo.UnitNames[UEF]['Commander'])
end

----------
-- Reminders
----------
function TacticalLauncherReminder()
    ScenarioFramework.Dialogue(OpStrings.M2P2Reminder, nil, true)
end

function OutpostReminder()
    ScenarioFramework.Dialogue(OpStrings.M2P1Reminder, nil, true)
end

function TechReminder()
    ScenarioFramework.Dialogue(OpStrings.M2P3Reminder, nil, true)
end

function EnemyReminder()
    ScenarioFramework.Dialogue(OpStrings.M3P1Reminder, nil, true)
end