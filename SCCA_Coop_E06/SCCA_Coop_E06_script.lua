-- ----------------------------------------------------------------------------
--  File     : /maps/SCCA_Coop_E06/SCCA_Coop_E06_script.lua
--  Author(s): Drew Staltman
--
--  Summary  : Main mission flow script for SCCA_Coop_E06
--
--  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
------------------------------------------------------------------------------
local Objectives = import('/lua/scenarioframework.lua').Objectives
local OpStrings = import('/maps/scca_coop_e06/scca_coop_e06_strings.lua')
local ScenarioFramework = import('/lua/scenarioframework.lua')
local ScenarioPlatoonAI = import('/lua/scenarioplatoonai.lua')
local ScenarioUtils = import('/lua/sim/scenarioutilities.lua')
local Weather = import('/lua/weather.lua')
local AIBuildStructures = import('/lua/ai/aibuildstructures.lua')
local ScenarioStrings = import('/lua/scenariostrings.lua')
local Utilities = import('/lua/utilities.lua')
local Cinematics = import('/lua/cinematics.lua')
local CustomFunctions = import('/maps/scca_coop_e06/scca_coop_e06_customfunctions.lua')
local Buff = import('/lua/sim/buff.lua')
local SimUtils = import('/lua/SimUtils.lua')

local AeonAI = import('/maps/scca_coop_e06/scca_coop_e06_aeonai.lua')
local CybranAI = import('/maps/scca_coop_e06/scca_coop_e06_cybranai.lua')
local UEFAI = import('/maps/scca_coop_e06/scca_coop_e06_uefai.lua')

-- Globals
ScenarioInfo.Player1 = 1
ScenarioInfo.BlackSun = 2
ScenarioInfo.Aeon = 3
ScenarioInfo.Cybran = 4
ScenarioInfo.Component = 5
ScenarioInfo.Player2 = 6
ScenarioInfo.Player3 = 7
ScenarioInfo.Player4 = 8

-- Locals
local Player1 = ScenarioInfo.Player1
local Player2 = ScenarioInfo.Player2
local Player3 = ScenarioInfo.Player3
local Player4 = ScenarioInfo.Player4
local BlackSun = ScenarioInfo.BlackSun
local Aeon = ScenarioInfo.Aeon
local Cybran = ScenarioInfo.Cybran
local Component = ScenarioInfo.Component

local Difficulty = ScenarioInfo.Options.Difficulty
local LeaderFaction
local LocalFaction
local HostileAIs = {Aeon, Cybran}
local AIs = {Aeon, Cybran, BlackSun}

-- These are used to terminate the taunt logic if no taunt could be executed for both characters
local CanRedFogTaunt = true
local CanArnoldTaunt = true

-- Debug variables
local DEBUG = false
local SkipIntro = false

local M1B1EnemiesKilled = 500
local M1B2ExperimentalNeeded = 5

----------------------
-- Mission 1 variables
----------------------
-- M1 Objective reminder
local M1ObjectiveReminderTimer = 450

----------------------
-- Mission 2 variables
----------------------
-- Timer to play objective reminders
local M2ObjectiveReminderTimer = 450

----------------------
-- Mission 3 variables
----------------------
-- Timer for each segment of the final duration countdown, there are 20 segments
local M3ChargeTimerSegmentDuration = tonumber(ScenarioInfo.Options.BlackSunChargeTimer)
-- Timer for the 3 main attack waves during phase 3
local M3AttackWaveDelay = tonumber(ScenarioInfo.Options.AttackWaveDelay)

------------------------
-- AI buffing functions
------------------------
-- ACUs and sACUs belong to both ECONOMIC and ENGINEER categories.

-- Buffs AI factory structures, and engineer units
function BuffAIBuildPower()
	--Build Rate multiplier values, depending on the Difficulty
	local Rate = {1.0, 1.5, 2.0}
	--Buff definitions
	local buffDef = Buffs['CheatBuildRate']
	local buffAffects = buffDef.Affects
	buffAffects.BuildRate.Mult = Rate[Difficulty]

	while true do
		if not table.empty(HostileAIs) then
			for i, j in HostileAIs do
				local buildpower = ArmyBrains[j]:GetListOfUnits(categories.FACTORY + categories.ENGINEER, false)
				-- Check if there is anything to buff
				if not table.empty(buildpower) then
					for k, v in buildpower do
						-- Apply buff to the entity if it hasn't been buffed yet
						if not v.BuildBuffed then
							Buff.ApplyBuff(v, 'CheatBuildRate')
							-- Flag the entity as buffed
							v.BuildBuffed = true
						end
					end
				end
			end
		end
		WaitSeconds(60)
	end
end

-- Buffs resource producing structures, (and ACU variants.)
function BuffAIEconomy()
	-- Resource production multipliers, depending on the Difficulty
	local Rate = {2.5, 5.0, 10.0}
	-- Buff definitions
	local buffDef = Buffs['CheatIncome']
	local buffAffects = buffDef.Affects
	buffAffects.EnergyProduction.Mult = Rate[Difficulty]
	buffAffects.MassProduction.Mult = Rate[Difficulty]
	
	while true do
		if not table.empty(HostileAIs) then
			for i, j in HostileAIs do
				local economy = ArmyBrains[j]:GetListOfUnits(categories.ECONOMIC, false)
				-- Check if there is anything to buff
				if not table.empty(economy) then
					for k, v in economy do
						-- Apply buff to the entity if it hasn't been buffed yet
						if not v.EcoBuffed then
							Buff.ApplyBuff(v, 'CheatIncome')
							-- Flag the entity as buffed
							v.EcoBuffed = true
						end
					end
				end
			end
		end
		WaitSeconds(60)
	end
end

-----------------
-- Initialization
-----------------
function OnPopulate()
    ScenarioUtils.InitializeScenarioArmies()
	LeaderFaction, LocalFaction = ScenarioFramework.GetLeaderAndLocalFactions()
	
    -- Components
    ScenarioInfo.DeathTransport = ScenarioUtils.CreateArmyUnit('Black_Sun', 'Death_Transport_Unit')
    ScenarioInfo.DeathTransport:SetCanBeKilled(false)
    ScenarioInfo.InvincibleTransports = ScenarioUtils.CreateArmyGroupAsPlatoon('Black_Sun', 'Invincible_Transports', 'ChevronFormation')
    ScenarioInfo.InvincibleComponents = ScenarioUtils.CreateArmyGroup('Black_Sun', 'Extra_Components')
    for num,unit in ScenarioInfo.InvincibleComponents do
        unit:SetCanTakeDamage(false)
        unit:SetCanBeKilled(false)
        unit:SetDoNotTarget(true)
        unit:SetReclaimable(false)
        unit:SetCapturable(false)
    end
    for num,unit in ScenarioInfo.InvincibleTransports:GetPlatoonUnits() do
        unit:SetCanTakeDamage(false)
        unit:SetCanBeKilled(false)
        unit:SetDoNotTarget(true)
    end
	
	-- ASF escorts
    ScenarioInfo.BlackSunEscorts = ScenarioUtils.CreateArmyGroup('Black_Sun', 'Escorts')
    ScenarioInfo.BlackSunComponent = ScenarioUtils.CreateArmyUnit('Component', 'Black_Sun_Component_Unit')
	
    -- Aeon interception force
    ScenarioInfo.AeonIntroAirPlatoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'Air_Group_Intro', 'ChevronFormation')
    ScenarioInfo.AeonIntroNavalPlatoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'Naval_Group_Intro', 'AttackFormation')
	
	-- Spawn in the relevant armies
	SpawnPlayer()
	M1SpawnAeon()
	
	-- Start AI buffing threads
	ForkThread(BuffAIEconomy)
	ForkThread(BuffAIBuildPower)
end

function SpawnPlayer()
	-- Player Base, depending on chosen lobby option
	if ScenarioInfo.Options.InitialBase == 4  then
		ScenarioUtils.CreateArmyGroup('Player1', 'Player_Base_D' .. Difficulty)
	else
		ScenarioUtils.CreateArmyGroup('Player1', 'Player_Base_D' .. ScenarioInfo.Options.InitialBase)
	end
	
	-- Control Center Defenses
    ScenarioUtils.CreateArmyGroup('Player1', 'Control_Center_Defenses')
    ScenarioUtils.CreateArmyGroup('Player1', 'NukeMeClumps')
    ScenarioInfo.AikoUnit = ScenarioUtils.CreateArmyUnit('Player1', 'Aiko')
    ScenarioInfo.AikoUnit:SetCustomName(LOC '{i sCDR_Aiko}')
	
	-- Triggers for Aiko
    ScenarioFramework.CreateUnitDestroyedTrigger(AikoDestroyed, ScenarioInfo.AikoUnit)
    ScenarioFramework.CreateUnitGivenTrigger(AikoGiven, ScenarioInfo.AikoUnit)
	-- Prevent the unit from transferring, otherwise the secondary objective to move her to the SE island would fail
	-- SimObjectives.lua would have to be modified to allow updating the objective's target units
	if ScenarioInfo.Options.BlackSunSupportAI == 2 then
		ScenarioInfo.AikoUnit:SetCanBeGiven(false)
	end
	
	-- Initial Air patrols
    local group = ScenarioUtils.CreateArmyGroup('Player1', 'Starting_Air_1')
    ScenarioFramework.GroupPatrolChain(group, 'Player_Base_Patrol_Chain')
    local group = ScenarioUtils.CreateArmyGroup('Player1', 'Starting_Air_2')
    ScenarioFramework.GroupPatrolChain(group, 'Player_Base_Patrol_Chain')
    local group = ScenarioUtils.CreateArmyGroup('Player1', 'Starting_Air_North')
    ScenarioFramework.GroupPatrolChain(group, 'Player_North_Patrol_Chain')
	
	-- Initial Navy, with basic veterancy
	local navy = ScenarioUtils.CreateArmyGroup('Player1', 'Starting_Navy')
	for _, unit in navy do
		if unit and not unit:IsDead() then
			unit:SetVeterancy(6 - Difficulty)
		end
	end

    -- Give Player Anti-Nukes
    for num, unit in ScenarioFramework.GetListOfHumanUnits(categories.ueb4302, false) do
        unit:GiveTacticalSiloAmmo(2)
    end
	
	-- Control Center
    ScenarioInfo.BlackSunControlCenter = ScenarioUtils.CreateArmyUnit('Black_Sun', 'Black_Sun_Control_Center')
    ScenarioInfo.BlackSunControlCenter:SetCanBeKilled(false)
    ScenarioInfo.BlackSunControlCenter:SetCanTakeDamage(false)
    ScenarioInfo.BlackSunControlCenter:SetReclaimable(false)
    ScenarioInfo.BlackSunControlCenter:SetDoNotTarget(true)
    ScenarioInfo.BlackSunControlCenter:SetCustomName(LOC '{i BlackSunControlTower}')
    ScenarioFramework.CreateUnitCapturedTrigger(false, M2BlackSunControlCenterCaptured, ScenarioInfo.BlackSunControlCenter)

	-- Black Sun
    ScenarioInfo.BlackSunCannon = ScenarioUtils.CreateArmyUnit('Player1', 'Black_Sun_Cannon')
    ScenarioInfo.BlackSunCannon:SetCustomName(LOC '{i BlackSunCannon}')
    ScenarioInfo.BlackSunCannon:SetReclaimable(false)
    ScenarioInfo.BlackSunCannon:SetCapturable(false)
	ScenarioInfo.BlackSunCannon:SetCanBeGiven(false)
    ScenarioInfo.BlackSunCannon:RemoveToggleCap('RULEUTC_SpecialToggle')
    ScenarioFramework.CreateUnitDestroyedTrigger(BlackSunCannonDestroyed, ScenarioInfo.BlackSunCannon)
	
	-- Black Sun support structures
    local supportBuildings = ScenarioUtils.CreateArmyGroup('Black_Sun', 'Black_Sun_Support')
    for k, v in supportBuildings do
		v:SetDoNotTarget(true)
        v:SetUnSelectable(true)
        v:SetCanTakeDamage(false)
        v:SetCanBeKilled(false)
    end
end

function M1SpawnAeon()
	-- Spawn in Ariel as the Aeon Commander for part 2, and restrict her from building anything on the sea
	-- In SC1 we couldn't encounter her during the UEF campaign, so I picked her character for the otherwise unknown Aeon Commander for this Phase
	ScenarioInfo.Ariel = ScenarioFramework.SpawnCommander('Aeon', 'Ariel_ACU', false, LOC('{i CDR_Ariel}'), true, M2KillAeonBase, {'ShieldHeavy', 'CrysalisBeam', 'HeatSink'})
	-- Prevent Ariel from building stuff on water
	-- T1 Naval Factory, T3 Naval Support Factory, T2 Torpedo Launcher, T3 SAM Launcher, T2 TMD, T2 Sonar
	ScenarioInfo.Ariel:AddBuildRestriction(categories.uab0103 + categories.zab9603 + categories.uab2205 + categories.uab2304 + categories.uab4201 + categories.uab3202)
	ScenarioInfo.Ariel:SetVeterancy(Difficulty + 2)
	ScenarioInfo.Ariel:SetAutoOvercharge(true)
	
	AeonAI.M2AeonSEBaseAI()
end

function M2SpawnCybran()
	if ScenarioInfo.Options.FullMapAccess == 2 then
		-- Spawn in RedFog, and restrict him from building Naval factory, Torp def and AA
		ScenarioInfo.RedFog = ScenarioFramework.SpawnCommander('Cybran', 'RedFog_ACU', false, LOC('{i RedFog}'), true, false, {'T3Engineering', 'CloakingGenerator', 'MicrowaveLaserGenerator'})
		-- T1 Naval Factory, T3 Naval Support Factory, T2 Torpedo Launcher, T3 SAM Launcher, T2 Sonar
		ScenarioInfo.RedFog:AddBuildRestriction(categories.urb0103 + categories.zrb9603 + categories.urb2205 + categories.urb2304 + categories.urb3202)
		ScenarioInfo.RedFog:SetVeterancy(Difficulty + 2)
		ScenarioInfo.RedFog:SetAutoOvercharge(true)
		
		-- Spawn in Jericho
		ScenarioInfo.Jericho = ScenarioFramework.SpawnCommander('Cybran', 'Jericho_sACU', false, LOC '{i sCDR_Jericho}', false, false, {'NaniteMissileSystem', 'ResourceAllocation', 'Switchback'})
		ScenarioInfo.Jericho:SetVeterancy(Difficulty + 2)
	end

	CybranAI.M3CybranBaseAI()
	CybranAI.M3CybranNavalBaseAI()
end

function M3SpawnAeon()
	if ScenarioInfo.Options.FullMapAccess == 2 then
		ScenarioInfo.SE_sACU = ScenarioFramework.SpawnCommander('Aeon', 'Matilda_sACU', false, 'sCDR Matilda', false, false)
		ScenarioInfo.SE_sACU:SetVeterancy(Difficulty + 2)
	end
	
	AeonAI.M3AeonArnoldBaseAI()
	AeonAI.M3AeonSWBaseAI()
end

function OnStart()
	ScenarioFramework.SetUEFColor(Player1)
    ScenarioFramework.SetUEFAllyColor(BlackSun)
    ScenarioFramework.SetUEFAllyColor(Component)
    ScenarioFramework.SetCybranColor(Cybran)
    ScenarioFramework.SetAeonColor(Aeon)

    local colors = {
        ['Player2'] = {67, 110, 238}, 
        ['Player3'] = {97, 109, 126}, 
        ['Player4'] = {255, 255, 255}
    }
    local tblArmy = ListArmies()
	
    for army, color in colors do
        if tblArmy[ScenarioInfo[army]] then
            ScenarioFramework.SetArmyColor(ScenarioInfo[army], unpack(color))
        end
    end
	
	-- Adjust buildable categories for Players
    ScenarioFramework.AddRestrictionForAllHumans(
        -- All non vanilla units
        categories.PRODUCTFA + -- All FA units
		categories.PRODUCTDL + -- All SC1 update (Hoplites, Corsairs, Mercy, etc.), and T3 MAA units

        -- Actual mission restrictions
		categories.ueb2401 +  -- UEF Experimental Artillery (Mavor)
        categories.ueb2302 +  -- UEF T3 Artillery
        categories.ueb4301 +  -- UEF T3 Heavy Shield
        categories.ues0304    -- UEF T3 Strategic Missile Submarine
    )
	
    ScenarioFramework.SetPlayableArea('M1_Playable_Area', false)
	
	-- Used for debugging
	--ScenarioFramework.SetPlayableArea('M3_Playable_Area_FullMap', false)
	
	ScenarioFramework.SetSharedUnitCap(500)
	SetArmyUnitCap(Aeon, 2000)
    SetArmyUnitCap(Cybran, 2000)
	
	for _, army in AIs do
		ArmyBrains[army].IMAPConfig = {
				OgridRadius = 0,
				IMAPSize = 0,
				Rings = 0,
		}
		ArmyBrains[army]:IMAPConfiguration()
	end
	
	if not SkipIntro then
        --ScenarioFramework.StartOperationJessZoom('Start_Camera_Area', IntroMission1)
		ForkThread(IntroCutscene)
    else
        IntroMission1()
    end
end

function IntroCutscene()
    Cinematics.EnterNISMode()
	WaitSeconds(0.5)
    ForkThread(IntroMission1)
    Cinematics.CameraMoveToRectangle(ScenarioUtils.AreaToRect('Start_Camera_Area'), 2.5)
    WaitSeconds(2.0)
    Cinematics.CameraMoveToRectangle(ScenarioUtils.AreaToRect('M1_Playable_PreArea'), 1.5)
    Cinematics.ExitNISMode()
end

function IntroMission1()
    WaitSeconds(2.0)
	ScenarioInfo.HumanACUs = {}
	
	-- Spawn in player ACUs, and insert them into the HumanACUs table
    ForkThread(function()
        local tblArmy = ListArmies()
        for name, _ in ScenarioInfo.HumanPlayers do
            ScenarioInfo[name .. 'CDR'] = ScenarioFramework.SpawnCommander(name, name .. 'CDR', 'Warp', true, false, PlayerCommanderDestroyed)	-- No pause on death, otherwise the death is registered too late
			table.insert(ScenarioInfo.HumanACUs, ScenarioInfo[name .. 'CDR'])
            WaitSeconds(2)
        end
    end)

    WaitSeconds(1.0)
    IntroNIS()
    WaitSeconds(2.0)
    -- Opening dialogue
    ScenarioFramework.Dialogue(OpStrings.E06_M01_005, nil, true)
end

function IntroNIS()
    -- Attach units to transports
    ScenarioFramework.AttachUnitsToTransports({ScenarioInfo.BlackSunComponent}, {ScenarioInfo.DeathTransport})

    -- Move Transports to Blacksun
    for num, unit in ScenarioInfo.InvincibleTransports:GetPlatoonUnits() do
        ScenarioFramework.AttachUnitsToTransports({ScenarioInfo.InvincibleComponents[num]}, {unit})
    end
    ArmyBrains[Component]:AssignUnitsToPlatoon(ScenarioInfo.InvincibleTransports, {ScenarioInfo.DeathTransport}, 'Attack', 'ChevronFormation')
    local unloadCmd = ScenarioInfo.InvincibleTransports:UnloadAllAtLocation(ScenarioUtils.MarkerToPosition('M1_Transport_Unload'))

    local newGroup = {}
    for k, v in ScenarioInfo.BlackSunEscorts do
        table.insert(newGroup, ScenarioFramework.GiveUnitToArmy(v, Player1))
    end
	
	IssueMove(newGroup, ScenarioUtils.MarkerToPosition('Player_Attack_Black_Sun'))
	
    ScenarioInfo.AeonIntroAirPlatoon:Patrol(ScenarioUtils.MarkerToPosition('INTRO_West_Island_Marker'))
    ScenarioInfo.AeonIntroAirPlatoon:Patrol(ScenarioUtils.MarkerToPosition('Player_Attack_Black_Sun'))

    -- Check if the transport is in range to die
    ScenarioFramework.CreateUnitToMarkerDistanceTrigger(IntroKillTransport, ScenarioInfo.DeathTransport, 'INTRO_Island_Death_Marker', 12)
    ForkThread(MoveComponents, unloadCmd)
end

function MoveComponents(unloadCmd)
    while ScenarioInfo.InvincibleTransports:IsCommandsActive(unloadCmd) do
        WaitSeconds(2)
    end
    for num, unit in ScenarioInfo.InvincibleTransports:GetPlatoonUnits() do
        if unit then
            unit:SetCanTakeDamage(true)
            unit:SetCanBeKilled(true)
            if not unit:IsDead() then
                ScenarioFramework.GiveUnitToArmy(unit, Player1)
            end
        end
    end
    for k, v in ScenarioInfo.InvincibleComponents do
        IssueMove({v}, ScenarioUtils.MarkerToPosition('Component_Move_Marker_'..k))
    end
end

function IntroKillTransport(unit)
    unit:SetCanBeKilled(true)

    -- Transport dying camera
    local camInfo = {
        blendTime = 1.0,
        holdTime = 3,
        orientationOffset = { 2.6, 0.9, 0 },
        positionOffset = { -7, 0.5, 0 },
        zoomVal = 45,
        vizRadius = 25,
        markerCam = true,
    }
    ScenarioFramework.OperationNISCamera(ScenarioUtils.MarkerToPosition("INTRO_Component_Move"), camInfo)

    unit:Kill()
    ScenarioInfo.BlackSunComponent:Destroy()
    StartMission1()
end

----------
-- Phase 1
----------
function StartMission1()
	if DEBUG then
		LOG('Black Sun Charge Timer set to: ' .. repr(M3ChargeTimerSegmentDuration))
		SetUnitEssential(ScenarioInfo.Player1CDR)
		SetUnitEssential(ScenarioInfo.BlackSunCannon)
		SetUnitEssential(ScenarioInfo.AikoUnit)
	end
    -- 'Aiko: Transport got yeeted.'
    ScenarioFramework.Dialogue(OpStrings.E06_M01_010)
	-- 'Aiko: Btw I'm Aiko, this shitshow is now your responsibility.'
    ScenarioFramework.Dialogue(OpStrings.E06_M01_020, ComponentSighted)
    ScenarioInfo.MissionNumber = 1
    ScenarioFramework.CreateTimerTrigger(M1ObjectiveReminder, M1ObjectiveReminderTimer)

	----------------------------------------
    -- Primary Objective - Protect Black Sun
	----------------------------------------
    ScenarioInfo.M1P1Obj = Objectives.Protect(
		'primary',
		'incomplete',
		OpStrings.M1P1Title,
		OpStrings.M1P1Description,
		{ 
			Units = {ScenarioInfo.BlackSunCannon},
		}
	)
end

-- Dialogue prior to spawning the Component
function ComponentSighted()
    if not ScenarioInfo.M1PlayerSightedComponent then
        ScenarioInfo.M1PlayerSightedComponent = true
        if not ScenarioInfo.AikoUnitDestroyed and ScenarioInfo.AikoUnit:GetHealthPercent() >= .5 then
            ScenarioFramework.Dialogue(OpStrings.E06_M01_030)
        else
            ScenarioFramework.Dialogue(OpStrings.E06_M01_035)
        end
        ForkThread(ComponentSightedThread)
    end
end

-- Spawns the Component, and assigns its objective
function ComponentSightedThread()
    ScenarioInfo.BlackSunComponent = ScenarioUtils.CreateArmyUnit('Component', 'Black_Sun_Component_Unit')
    ScenarioInfo.BlackSunComponent = ScenarioFramework.GiveUnitToArmy(ScenarioInfo.BlackSunComponent, Player1)
    Warp(ScenarioInfo.BlackSunComponent, ScenarioUtils.MarkerToPosition('INTRO_Component_Move'))
    ScenarioInfo.BlackSunComponent:SetCanTakeDamage(false)
    ScenarioInfo.BlackSunComponent:SetCanBeKilled(false)
    ScenarioInfo.BlackSunComponent:SetReclaimable(false)
    ScenarioInfo.BlackSunComponent:SetCapturable(false)

	ScenarioInfo.M1P2Obj = Objectives.SpecificUnitsInArea(
		'primary',
		'incomplete',
		OpStrings.M1P2Title,
		OpStrings.M1P2Description,
        --Objectives.GetActionIcon('move'),
        {
            Units = {ScenarioInfo.BlackSunComponent},
            Area = 'Black_Sun_Component_Area',
            MarkArea = true,
            MarkUnits = true,
        }
	)
	-- Using a different objective type for this one, it's triggered even if the Component is on a transport
	-- To avoid any issues, we simply zoom in on Black Sun instead of the Component, and during this time, if the Component is on a transport, the transport will load it off at its current position
	ScenarioInfo.M1P2Obj:AddResultCallback(
        function(result)
			ForkThread(
				function()
					local camInfo = {
						blendTime = 1.0,
						holdTime = 5,
						orientationOffset = { 0, 0.3, 0 },
						positionOffset = { 0, 0.5, 0 },
						zoomVal = 50,
					}
					ScenarioFramework.OperationNISCamera(ScenarioInfo.BlackSunCannon, camInfo)
					
					ScenarioFramework.Dialogue(OpStrings.E06_M01_050, StartMission2)
					
					-- If the Component is on a Transport when it reaches Black Sun
					local parent = ScenarioInfo.BlackSunComponent:GetParent()
					if parent and IsUnit(parent) then
						-- Do a full stop, and unload the Component at the Transport's position
						IssueClearCommands({parent})
						IssueTransportUnload({parent}, parent:GetPosition())
						
						-- Wait until the Component has been dropped
						while ScenarioInfo.BlackSunComponent:IsUnitState('Attached') do
							WaitTicks(5)
						end
					end
					
					local newUnit = ScenarioFramework.GiveUnitToArmy(ScenarioInfo.BlackSunComponent, BlackSun)

					WaitTicks(1)
					IssueMove({newUnit}, ScenarioUtils.MarkerToPosition('Component_Move_Marker_1'))
				end
			)
        end
	)
	
	-- Give reinforcements shortly after the component has been spotted
	ScenarioFramework.CreateTimerTrigger(M2TransferUnitsToPlayer, 45)

    while ScenarioInfo.MissionNumber == 1 do
        local parent
        while ScenarioInfo.MissionNumber == 1 and not ScenarioInfo.BlackSunComponent:BeenDestroyed() and not ScenarioInfo.BlackSunComponent:IsUnitState('Attached') do
            WaitSeconds(2)
        end

        if not ScenarioInfo.BlackSunComponent:BeenDestroyed() then
            parent = ScenarioInfo.BlackSunComponent:GetParent()
            if parent and IsUnit(parent) then
                parent:SetCanTakeDamage(false)
                parent:SetCanBeKilled(false)

                while not ScenarioInfo.BlackSunComponent:BeenDestroyed() and ScenarioInfo.BlackSunComponent:IsUnitState('Attached') do
                    WaitSeconds(2)
                end

                parent:SetCanTakeDamage(true)
                parent:SetCanBeKilled(true)
            end
        end
        WaitSeconds(1)
    end
end

-- function BPlayerBuiltExperimentals()
-- ScenarioInfo.ExperimentalBonus = Objectives.Basic('bonus', 'complete', OpStrings.M1B2Title, LOCF(OpStrings.M1B2Description,M1B2ExperimentalNeeded))
-- ScenarioInfo.ExperimentalBonus:ManualResult(true)
-- ScenarioFramework.Dialogue(ScenarioStrings.BObjComp)
-- end

-- function BPlayerKill500Enemy()
-- ScenarioInfo.KillBonus = Objectives.Basic('bonus', 'complete', OpStrings.M1B1Title, LOCF(OpStrings.M1B1Description,M1B1EnemiesKilled))
-- ScenarioInfo.KillBonus:ManualResult(true)
-- ScenarioFramework.Dialogue(ScenarioStrings.BObjComp)
-- end

function M1ObjectiveReminder()
    if ScenarioInfo.MissionNumber == 1 then
        if Random(1, 2) == 1 then
            ScenarioFramework.Dialogue(OpStrings.E06_M01_060)
        else
            ScenarioFramework.Dialogue(OpStrings.E06_M01_065)
        end
        ScenarioFramework.CreateTimerTrigger(M1ObjectiveReminder, M1ObjectiveReminderTimer)
    end
end

----------
-- Phase 2
----------

-- Escalate the situation
function StartMission2()
    -- Phase 2 begins
    ScenarioInfo.MissionNumber = 2
	ScenarioFramework.SetSharedUnitCap(750)
    ScenarioFramework.SetPlayableArea('M2_Playable_Area_1')
    if not ScenarioInfo.AikoUnitDestroyed then
        ScenarioFramework.Dialogue(OpStrings.E06_M02_010)
    else
        ScenarioFramework.Dialogue(OpStrings.E06_M02_015)
    end
    ScenarioFramework.Dialogue(OpStrings.E06_M02_020)
	
	-- Add HLRA to be built for Hard difficulty
	if Difficulty == 3 then
		AeonAI.M2AddHLRA()
	end

	-- Update player restrictions
    ScenarioFramework.RemoveRestrictionForAllHumans(
        categories.ueb2302 +
        categories.ueb4301 +
        categories.uel0401 +
        categories.ues0304
    )

    -- Spawn in Aeon naval response
    for i = 1, Difficulty do
        local plat = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M2_Aeon_Naval_Group_' .. i, 'AttackFormation')
		ScenarioFramework.PlatoonPatrolChain(plat, 'Aeon_M2_Defensive_Fleets_Chain_' .. i)
    end

    -- Objective Reminder Timer
    ScenarioFramework.CreateTimerTrigger(M2ObjectiveReminder, M2ObjectiveReminderTimer)
    Objectives.UpdateBasicObjective(ScenarioInfo.M1P1Obj, 'description', OpStrings.M2P1Description)
	
	-- Warn player about Aeon base to the South East; create LOS intel trigger of new island
	ScenarioFramework.CreateArmyIntelTrigger(M2AeonBaseSighted, ArmyBrains[Player1], 'LOSNow', false, true,categories.STRUCTURE, true, ArmyBrains[Aeon])
	
	-----------------------------------------------------------
    -- Primary Objective - Destroy South Eastern Aeon Commander
	-----------------------------------------------------------
    ScenarioInfo.M2P1 = Objectives.Kill(
		'primary',								-- type
		'incomplete',							-- status
		OpStrings.M2P2Title,					-- title
		OpStrings.M2P2Description,				-- description
        {
			--ShowFaction = 'Aeon',
			Units = {ScenarioInfo.Ariel},
        }
   )
   ScenarioInfo.M2P1:AddResultCallback(
        function(result)
			if (result) then
				-- Flag the Aeon base as destroyed, clean up the Aeon PBM List
				ScenarioInfo.M2AeonBaseDefeatedBool = true
				ArmyBrains[Aeon]:PBMClearPlatoonList(true)
				-- Ariel death cam
				ScenarioFramework.CDRDeathNISCamera(ScenarioInfo.Ariel, 2)
				--Begin Cybran assault after VO
				ScenarioFramework.Dialogue(OpStrings.E06_M02_035A, M2CybranAttackBegin)
			end
        end
   )
end

-- Confirm dialogue when Aeon Base sighted, Ariel reveals herself
function M2AeonBaseSighted()
    if not ScenarioInfo.AikoUnitDestroyed and ScenarioInfo.AikoUnit:GetHealthPercent() >= .5 then
        ScenarioFramework.Dialogue(OpStrings.E06_M02_030, M2NukeAttackStart)
    else
        ScenarioFramework.Dialogue(OpStrings.E06_M02_035, M2NukeAttackStart)
    end
end

-- Phase 2 objective reminder
function M2ObjectiveReminder()
    if ScenarioInfo.MissionNumber == 2 and not ScenarioInfo.M2AeonBaseDefeatedBool then
        if Random(1,2) == 1 then
            ScenarioFramework.Dialogue(OpStrings.E06_M02_150)
        else
            ScenarioFramework.Dialogue(OpStrings.E06_M02_155)
        end
        ScenarioFramework.CreateTimerTrigger(M2ObjectiveReminder, M2ObjectiveReminderTimer)
    end
end

-- Attack player with a nuke from Aeon Base
function M2NukeAttackStart()
    local nukeLaunchers = ArmyBrains[Aeon]:GetListOfUnits(categories.uab2305, false)
	
	-- Make sure there's at least 1 SML, and Ariel is still alive
	if nukeLaunchers[1] and ScenarioInfo.Ariel and not ScenarioInfo.Ariel:IsDead() then
		-- Zoom in on the nuke launcher in Ariel's base, fire off a dialogue
		local camInfo = {
				blendTime = 1.0,
				holdTime = 12,
				orientationOffset = { 2.5, 0.5, 0 },
				positionOffset = { 0, 0.5, 0 },
				zoomVal = 45,
				vizRadius = 30,
		}
		ScenarioFramework.OperationNISCamera(nukeLaunchers[1], camInfo)
		ScenarioFramework.Dialogue(OpStrings.E06_M02_030A)
	end
	
	-- Begin taunts shortly after strategic missile launch
	ScenarioFramework.CreateTimerTrigger(ArielTaunt, 30)
	
    for num, unit in nukeLaunchers do
        if not unit:IsDead() then
            IssueNuke({unit}, ScenarioUtils.MarkerToPosition('Aeon_M2_Nuke_Target'))
            break
        end
    end
	-- Begin nuke thread
    ScenarioFramework.CreateTimerTrigger(M2AeonNukeClump, 90 / Difficulty)
end

-- Nuke clumping thread for Phase 2
function M2AeonNukeClump()
	while ScenarioInfo.Ariel and not ScenarioInfo.Ariel:IsDead() do
		local clumpNum = GetLowestNonNegativeClumpThread(Aeon)
		if clumpNum > 0 then
			local nukeLaunchers = ArmyBrains[Aeon]:GetListOfUnits(categories.uab2305, false)
			for num, unit in nukeLaunchers do
				if not unit:IsDead() and unit:GetNukeSiloAmmoCount() > 0 then
					IssueNuke({unit}, ScenarioUtils.MarkerToPosition('Nuke_Me_Clump_' .. clumpNum))
					WaitSeconds(15)
					IssueClearCommands({unit})
				end
			end
		end
		WaitSeconds(10)
	end
end

-- Self-destructs Ariel's base
function M2KillAeonBase()
	-- Gotta fork this thread because of the delay between unit self-destruction
	ForkThread(
		function()
			-- Kill all units belonging to Aeon inside the rectangle with a slight delay
			local units = GetUnitsInRect(ScenarioUtils.AreaToRect('M2_Aeon_Base_Area'))
			for _, unit in units do
				if (unit and not unit:IsDead()) and unit:GetAIBrain() == ArmyBrains[Aeon] then
					unit:Kill()
					WaitSeconds(0.25)
				end
			end
	
			-- Kill any remaining units that slipped because of the delay
			units = GetUnitsInRect(ScenarioUtils.AreaToRect('M2_Aeon_Base_Area'))
			for _, unit in units do
				if (unit and not unit:IsDead()) and unit:GetAIBrain() == ArmyBrains[Aeon] then
				unit:Kill()
				end
			end
			
			-- Add secondary objective after Ariel's base has been cleaned out
			if not ScenarioInfo.AikoDestroyed and ScenarioInfo.Options.BlackSunSupportAI == 2 then
				M2SecondaryObjective()
			end
		end
	)
	
end

-- Objective for moving Aiko to Ariel's former base to build her own instead, entirely up to the Players
function M2SecondaryObjective()
	---------------------------------------------------
    -- Secondary Objective - Move Aiko to the SE Island
	---------------------------------------------------
    ScenarioInfo.M2S1 = Objectives.SpecificUnitsInArea(
		'secondary',								-- type
		'incomplete',							-- status
		OpStrings.M2S1Title,					-- title
		OpStrings.M2S1Description,				-- description
        {
			ShowFaction = 'UEF',
			Units = {ScenarioInfo.AikoUnit},
			Area = 'M3_Aiko_Transfer_Area',
			MarkUnits = true,
			MarkArea = true,
        }
   )
   ScenarioInfo.M2S1:AddResultCallback(
        function(result)
			if (result) then
				-- Transfer Aiko to BlackSun, activate base AI
				ForkThread(
					function()
						-- If Aiko is on a Transport when it reaches the SE area
						local parent = ScenarioInfo.AikoUnit:GetParent()
						if parent and IsUnit(parent) then
						
							-- Do a full stop, and unload Aiko at the Transport's position
							IssueClearCommands({parent})
							IssueTransportUnload({parent}, parent:GetPosition())
						
							-- Wait until Aiko has been dropped
							while ScenarioInfo.AikoUnit:IsUnitState('Attached') do
								WaitSeconds(1)
							end
						end
						
						if not ScenarioInfo.AikoDestroyed then
							ScenarioInfo.AikoUnit:SetCanBeGiven(true)
							--ScenarioFramework.GiveUnitToArmy(ScenarioInfo.AikoUnit, BlackSun, true)
							SimUtils.TransferUnitsOwnership({ScenarioInfo.AikoUnit}, 'Black_Sun')	-- This expects the army name as a string
							WaitTicks(1)
							IssueMove({ScenarioInfo.AikoUnit}, ScenarioUtils.MarkerToPosition('M2_Aeon_SE_Base_Marker'))
							UEFAI.M3AikoSEBaseAI()
						
							-- Camera over Aiko
							local camInfo = {
								blendTime = 1.0,
								holdTime = 3,
								orientationOffset = { 2.5, 0.5, 0 },
								positionOffset = { 0, 0.5, 0 },
								zoomVal = 50,
								vizRadius = 35,
							}
							ScenarioFramework.OperationNISCamera(ScenarioInfo.AikoUnit, camInfo)
						
							-- Gate in engineers to help her build up faster
							for i = 1, 4 do
								local GateEngineer = ScenarioUtils.CreateArmyUnit('Black_Sun', 'M3_SE_GateEngineer_' .. i)
								if GateEngineer then
									ScenarioFramework.FakeGateInUnit(GateEngineer)
									WaitSeconds(0.5)
								end
							end
						end
					end
				)
			end
        end
   )
end

-- Wait a number of seconds then fly in units and transfer them to the player.
function M2TransferUnitsToPlayer()
    while GetArmyUnitCostTotal(Player1) > 450 do
        WaitSeconds(10)
    end
	
    local transports = ScenarioUtils.CreateArmyGroupAsPlatoon('Black_Sun', 'M2_Transports', 'GrowthFormation')
    local units = ScenarioUtils.CreateArmyGroup('Black_Sun', 'M2_Units')
    ScenarioFramework.AttachUnitsToTransports(units, transports:GetPlatoonUnits())
    local cmd = transports:UnloadAllAtLocation(ScenarioUtils.MarkerToPosition('Player_M2_Transfer_Unit_Landing_Marker'))
    while transports:IsCommandsActive(cmd) do
        WaitSeconds(2)
        if not ArmyBrains[BlackSun]:PlatoonExists(transports) then
            for k, v in units do
                if not v:IsDead() then
                    ScenarioFramework.GiveUnitToArmy(v, Player1)
                end
            end
            return
        end
    end
	if not ScenarioInfo.AikoUnitDestroyed and ScenarioInfo.AikoUnit:GetHealthPercent() >= .5  then
		ScenarioFramework.Dialogue(OpStrings.E06_M02_050)
	--else
		--ScenarioFramework.Dialogue(OpStrings.E06_M02_055)	-- This one doesn't exist in the strings.lua file, no idea if a VO was made for it
	end
    for k,v in units do
        if not v:IsDead() then
            ScenarioFramework.GiveUnitToArmy(v,Player1)
        end
    end
    for k,v in transports:GetPlatoonUnits() do
        if not v:IsDead() then
            ScenarioFramework.GiveUnitToArmy(v, Player1)
        end
    end
end

-- Send Spider bot attack and start timer for capturing the control center
function M2CybranAttackBegin()
    if not ScenarioInfo.AikoUnitDestroyed and ScenarioInfo.AikoUnit:GetHealthPercent() >= .5  then
        ScenarioFramework.Dialogue(OpStrings.E06_M02_040)
    else
        ScenarioFramework.Dialogue(OpStrings.E06_M02_045)
    end
	
    ScenarioFramework.SetPlayableArea('M2_Playable_Area_2')
	ScenarioFramework.SetSharedUnitCap(900)

	M2SpawnCybran()
	M3SpawnAeon()
	
	local SpiderbotFound = false
    local lastSpiderBot
	local SpiderPlatoons = {}

    -- Create Monkeylords with escorts, and have them patrol the Control Center
	-- 1-1-1 platoons for each difficulty
	for i = 1, Difficulty do
		local SpiderPlatoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2_Spider_Platoon_D' .. i, 'AttackFormation')
		ScenarioFramework.PlatoonPatrolChain(SpiderPlatoon, 'Control_Center_Patrol_Chain')
		
		-- Insert all units into a table for the objective, and get the first Monkeylord so we can zoom in on it for cinematic effect
		for num, unit in SpiderPlatoon:GetPlatoonUnits() do
			table.insert(SpiderPlatoons, unit)
			
			if EntityCategoryContains(categories.EXPERIMENTAL, unit) and not SpiderbotFound then
				lastSpiderBot = unit
				SpiderbotFound = true
			end
		end
	end

    -- Create and move Air units
    local plat = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2_Spider_Air_Attack_D' .. Difficulty, 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(plat, 'Cybran_M2_Spider_Air_Chain')
	ScenarioFramework.CreateTimerTrigger(M2CybranRepeatSpiderAir, 300 / Difficulty)
    -- Nuke Clump 4
	
    if ScenarioInfo.Options.Difficulty > 1 then
        local nukeLaunchers = ArmyBrains[Cybran]:GetListOfUnits(categories.urb2305, false)
		local clumpNum = GetLowestNonNegativeClumpThread(Cybran)
		if clumpNum > 0 then
			for num, unit in nukeLaunchers do
				if not unit:IsDead() then
					IssueNuke({unit}, ScenarioUtils.MarkerToPosition('Nuke_Me_Clump_' .. clumpNum))
				end
			end
		end
    end

    -- Set triggers for Cybran attack events
    ScenarioFramework.CreateAreaTrigger(M2CybranCaptureBegin, 'Control_Center_Area', categories.url0402, true, false, ArmyBrains[Cybran])
    ScenarioFramework.CreateTimerTrigger(M2CybranCaptureBegin, 90)
	-- Begin taunting
	ScenarioFramework.CreateTimerTrigger(PlayTaunt, 30)

	-----------------------------------------------
    -- Primary Objective - Eliminate Cybran Assault
    -----------------------------------------------
    ScenarioInfo.M2P3Objective = Objectives.KillOrCapture(
        'primary',
        'incomplete',
        OpStrings.M2P3Title,
        OpStrings.M2P3Description,
        {
            Units = SpiderPlatoons,
            MarkUnits = true,
        }
    )
    ScenarioInfo.M2P3Objective:AddResultCallback(
        function(result)
            if result and ScenarioInfo.BlackSunControlCenter:GetAIBrain() == ArmyBrains[BlackSun] then
                EndMission2()
            end
        end
    )

	-- Spiderbot introduction
    local camInfo = {
        blendTime = 1.0,
        holdTime = 4,
        orientationOffset = { -2.5, 0.5, 0 },
        positionOffset = { 0, 0.5, 10 },
        zoomVal = 40,
        vizRadius = 30,
    }
    ScenarioFramework.OperationNISCamera(lastSpiderBot, camInfo)
end

-- Constant stream of additional Air units, let the players feel the care
function M2CybranRepeatSpiderAir()
    if ScenarioInfo.MissionNumber == 2 then
        local plat = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2_Spider_Air_Attack_D' .. Difficulty, 'AttackFormation')
        ScenarioFramework.PlatoonPatrolChain(plat, 'Cybran_M2_Spider_Air_Chain')
		
        ScenarioFramework.CreateTimerTrigger(M2CybranRepeatSpiderAir, 630 / Difficulty)
    end
end

-- Send out the transports with engineers the first time
function M2CybranCaptureBegin()
    if not ScenarioInfo.M2CybranCaptureBlackSunGroupSent then
        if not ScenarioInfo.AikoUnitDestroyed and ScenarioInfo.AikoUnit:GetHealthPercent() >= .5  then
            ScenarioFramework.Dialogue(OpStrings.E06_M02_060)
        else
            ScenarioFramework.Dialogue(OpStrings.E06_M02_065)
        end
        ScenarioInfo.M2CybranCaptureBlackSunGroupSent = true
        M2CybranCaptureSend(true)
    end
end

-- Send the capture group and repeat if needed
function M2CybranCaptureSend(forceSend)
    if ScenarioInfo.M2P3Objective.Active or forceSend then

        local transports = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2_Capture_Transports_D' .. Difficulty, 'ChevronFormation')
        local passengers = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2_Capture_Passengers_D' .. Difficulty, 'AttackFormation')
        local escorts = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2_Capture_Escort_D'..Difficulty, 'AttackFormation')
        ScenarioFramework.AttachUnitsToTransports(passengers:GetPlatoonUnits(), transports:GetPlatoonUnits())
		
		-- Re-send the capture group after some time if it's been destroyed
        ScenarioFramework.CreatePlatoonDeathTrigger(M2CybranCaptureEngineersDestroyed, passengers)
        ScenarioFramework.PlatoonPatrolChain(escorts, 'Control_Center_Patrol_Chain')

        WaitSeconds(10)
		
        local LoadCommand = transports:UnloadAllAtLocation(ScenarioUtils.MarkerToPosition('Black_Sun_Control_Center_Marker'))
		
        while not table.empty(transports:GetPlatoonUnits()) and transports:IsCommandsActive(LoadCommand) do
            WaitSeconds(1)
        end
		
        --transports:MoveToLocation(ScenarioUtils.MarkerToPosition('Cybran_Transport_Pool_Marker'), false)
        --ArmyBrains[Cybran]:AssignUnitsToPlatoon('TransportPool', transports, 'Scout', 'ChevronFormation')
        if ArmyBrains[Cybran]:PlatoonExists(passengers) and ScenarioInfo.BlackSunControlCenter:GetAIBrain() ~= ArmyBrains[Cybran] then
            for num, unit in passengers:GetPlatoonUnits() do
                if EntityCategoryContains(categories.ENGINEER, unit) then
                    IssueCapture({unit}, ScenarioInfo.BlackSunControlCenter)
                end
            end
        end
    end
end

-- Creates a timer trigger to respawn the Cybran capture engineers if they are destroyed
function M2CybranCaptureEngineersDestroyed()
	ScenarioFramework.CreateTimerTrigger(M2CybranCaptureSend, 45 / Difficulty)
end

-- Dialogue, mission, and necessary script triggers if the Cybrans capture the Control Center
function M2BlackSunControlCenterCaptured(newUnit, captor)
	-- Set the captured Control Center invunerable, update global to point to the 'new' unit
	SetUnitEssential(newUnit)
	ScenarioInfo.BlackSunControlCenter = newUnit
	
	-- Dialogue of the Control Center being captured
	ScenarioFramework.Dialogue(OpStrings.E06_M02_070)
	
	-- Control Center captured by bad guys camera
	ForkThread(
		function()
			local camInfo = {
				blendTime = 1.0,
				holdTime = 4,
				orientationOffset = { -2.1, 0.15, 0 },
				positionOffset = { 0, 0.5, 0 },
				zoomVal = 30,
				vizRadius = 30
			}
			ScenarioFramework.OperationNISCamera(ScenarioInfo.BlackSunControlCenter, camInfo)
		end
	)
	
	-----------------------------------------------
	-- Primary Objective - Recapture Control Center
	-----------------------------------------------
	ScenarioInfo.M2P4Objective = Objectives.Capture(
		'primary',
		'incomplete',
		OpStrings.M2P4Title,
		OpStrings.M2P4Description,
		{
			Units = {ScenarioInfo.BlackSunControlCenter},
		}
	)
		
	ScenarioInfo.M2P4Objective:AddResultCallback(
		function(result, units)
			if result then
				-- Player regained control, set it invunerable, then give it to BlackSun in a ForkThread, we gotta wait a tick for the 'new' unit to exist
				SetUnitEssential(units[1])
				
				ForkThread(
					function()
						ScenarioInfo.BlackSunControlCenter = ScenarioFramework.GiveUnitToArmy(units[1], BlackSun)
						WaitTicks(1)
						
						ScenarioInfo.BlackSunControlCenter:SetCustomName(LOC '{i BlackSunControlTower}')
						ScenarioInfo.BlackSunControlCenter:SetCanTakeDamage(false)
						ScenarioInfo.BlackSunControlCenter:SetCanBeKilled(false)
						ScenarioInfo.BlackSunControlCenter:SetReclaimable(false)
						--ScenarioInfo.BlackSunControlCenter:SetCanBeGiven(false)	-- Prevents re-capture by Cybrans
						ScenarioInfo.BlackSunControlCenter:SetDoNotTarget(true)
						if ScenarioInfo.M2P3Objective.Active then
							ScenarioFramework.CreateUnitCapturedTrigger(false, M2BlackSunControlCenterCaptured, ScenarioInfo.BlackSunControlCenter)
						end
					end
				)
				
				ForkThread(
					function()
						-- Blacksun control center captured cam
						local camInfo = {
							blendTime = 1.0,
							holdTime = 4,
							orientationOffset = { -2.1, 0.15, 0 },
							positionOffset = { 0, 0.5, 0 },
							zoomVal = 30,
						}
						ScenarioFramework.OperationNISCamera(ScenarioInfo.BlackSunControlCenter, camInfo)
					end
				)
				
				if not ScenarioInfo.AikoUnitDestroyed and ScenarioInfo.AikoUnit:GetHealthPercent() >= .5  then
					ScenarioFramework.Dialogue(OpStrings.E06_M02_080)
				else
					ScenarioFramework.Dialogue(OpStrings.E06_M02_085)
				end
				
				if not ScenarioInfo.M2P3Objective.Active and ScenarioInfo.MissionNumber == 2 then
					EndMission2()
				end
			end
		end
	)
	
end

-- Cleanup for mission 2
function EndMission2()
    if not ScenarioInfo.AikoUnitDestroyed and ScenarioInfo.AikoUnit:GetHealthPercent() >= .5  then
        ScenarioFramework.Dialogue(OpStrings.E06_M02_100, StartMission3)
    else
        ScenarioFramework.Dialogue(OpStrings.E06_M02_105, StartMission3)
    end
end

----------
-- Phase 3
----------

-- We're in the endgame now
function StartMission3()
    if ScenarioInfo.MissionNumber ~= 3 then
		ScenarioFramework.SetSharedUnitCap(1200)
		-- Prevent the CC from being captured in case the Cybran assault force got yeeted waaaaaay before the engineers arrive
		ScenarioInfo.BlackSunControlCenter:SetCanBeGiven(false)
        
		-- Show progress bar below Black Sun
        ScenarioInfo.BlackSunCannon:SetWorkProgress(.01)
		
        ScenarioInfo.MissionNumber = 3

        -- Give the Player ability to make le Mavor
        ScenarioFramework.RemoveRestrictionForAllHumans(categories.ueb2401)

        if not ScenarioInfo.AikoUnitDestroyed and ScenarioInfo.AikoUnit:GetHealthPercent() >= .5  then
            ScenarioFramework.Dialogue(OpStrings.E06_M03_010)
        else
            ScenarioFramework.Dialogue(OpStrings.E06_M03_015)
        end

        -- Create 20 timer with updates
        ScenarioFramework.CreateTimerTrigger(M3ChargeTimer, M3ChargeTimerSegmentDuration)
		
		-- Start Cybran transport attacks
		ForkThread(M3CybranTransportAssaultThread)
        Objectives.UpdateBasicObjective(ScenarioInfo.M1P1Obj, 'description', OpStrings.M3P1Description)
    end
end

-- Secondary objective if players chose full map access, eliminate RedFog
function M3AddSecondaryObjectives()
	--------------------------------------
    -- Secondary Objective: Destroy RedFog
	--------------------------------------
    ScenarioInfo.M3S2Obj = Objectives.Kill(
		'secondary',
		'incomplete',
		OpStrings.M3S2Title,
		OpStrings.M3S2Description,
        {
            Units = {ScenarioInfo.RedFog},
        }
   )
   ScenarioInfo.M3S2Obj:AddResultCallback(
        function(result)
			if (result) then
				-- Cybran death cam
                ScenarioFramework.CDRDeathNISCamera(ScenarioInfo.RedFog, 5)
				ScenarioFramework.Dialogue(OpStrings.E06_M03_75)
			end
        end
   )
end

-- Callback for timer; Creates self and handles proper number
function M3ChargeTimer()
	
    if not ScenarioInfo.M3ChargeCounter then
		-- Initialize charge counter, update UI objective information for phase 3, and create timer trigger for the next charge check
        ScenarioInfo.M3ChargeCounter = 1
        ScenarioFramework.CreateTimerTrigger(M3ChargeTimer, M3ChargeTimerSegmentDuration)
        Objectives.UpdateBasicObjective(ScenarioInfo.M1P1Obj, 'progress', OpStrings.M3P1Progress1)
    elseif not ScenarioInfo.M3ChargeComplete and ScenarioInfo.M3ChargeCounter < 20 then
		-- Increment the charge counter by 1, update UI informations, and create timer trigger for the next charge check
        ScenarioInfo.M3ChargeCounter = ScenarioInfo.M3ChargeCounter + 1
        Objectives.UpdateBasicObjective(ScenarioInfo.M1P1Obj, 'progress', OpStrings['M3P1Progress'..ScenarioInfo.M3ChargeCounter])
		ScenarioInfo.BlackSunCannon:SetWorkProgress(ScenarioInfo.M3ChargeCounter/20)
        ScenarioFramework.CreateTimerTrigger(M3ChargeTimer, M3ChargeTimerSegmentDuration)
		
        -- Dialogue, and attack waves
        if ScenarioInfo.M3ChargeCounter == 4 then
            if not ScenarioInfo.AikoUnitDestroyed and ScenarioInfo.AikoUnit:GetHealthPercent() >= .5  then
                ScenarioFramework.Dialogue(OpStrings.E06_M03_020)
            else
                ScenarioFramework.Dialogue(OpStrings.E06_M03_025)
            end
			M3AttackWaveOne()
        elseif ScenarioInfo.M3ChargeCounter == 8 then
            if not ScenarioInfo.AikoUnitDestroyed and ScenarioInfo.AikoUnit:GetHealthPercent() >= .5  then
                ScenarioFramework.Dialogue(OpStrings.E06_M03_030)
            else
                ScenarioFramework.Dialogue(OpStrings.E06_M03_035)
            end
			M3AttackWaveTwo()
        elseif ScenarioInfo.M3ChargeCounter == 12 then
            if not ScenarioInfo.AikoUnitDestroyed and ScenarioInfo.AikoUnit:GetHealthPercent() >= .5  then
                ScenarioFramework.Dialogue(OpStrings.E06_M03_040)
            else
                ScenarioFramework.Dialogue(OpStrings.E06_M03_045)
            end
			M3AttackWaveThree()
        elseif ScenarioInfo.M3ChargeCounter == 16 then
            if not ScenarioInfo.AikoUnitDestroyed and ScenarioInfo.AikoUnit:GetHealthPercent() >= .5  then
                ScenarioFramework.Dialogue(OpStrings.E06_M03_060)
            else
                ScenarioFramework.Dialogue(OpStrings.E06_M03_065)
            end
			M3FinalAttack()
        end
    end
end

-- Constant Cybran off-map spawned transport attacks, the Cybran PBM has enough platoons to build as it is
function M3CybranTransportAssaultThread()
	-- Create transports, and assign them to the transport pool
	local Transports = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M3_Cybran_TransportPool_D' .. Difficulty, 'GrowthFormation')
	Transports:ForkAIThread(CustomFunctions.TransportPool)
	
	-- Wait a second for all transports to register properly
	-- Without it, only half transport capacities are used, and the remaining land units are just ignored (about half)
	WaitSeconds(1)
	
	-- Create land units, assign platoon data, activate AI function
	local AssaultForce = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M3_Cybran_Drop_Force_D' .. Difficulty, 'AttackFormation')
	AssaultForce.PlatoonData.AttackChain = 'Player_Attack_Locations_Chain'
    AssaultForce.PlatoonData.LandingChain = 'Aeon_M2_Land_Assault_Landing_Chain'
	AssaultForce:ForkAIThread(CustomFunctions.LandAssaultWithTransports)
	
	-- Repeat until the full map expands
	if ScenarioInfo.MissionNumber <= 3 then
		ScenarioFramework.CreateTimerTrigger(M3CybranTransportAssaultThread, 180 / Difficulty)
	end
end

-- Attack wave support meant to clean up clump areas to clear the path for the actual attack waves
function M3AttackWaveNukeClump()
    local clumpNumCybran = GetLowestNonNegativeClumpThread(Cybran)
	local clumpNumAeon = GetLowestNonNegativeClumpThread(Aeon)
	
	local nukeLaunchersAeon = ArmyBrains[Aeon]:GetListOfUnits(categories.uab2305, false)
	local nukeLaunchersCybran = ArmyBrains[Cybran]:GetListOfUnits(categories.urb2305, false)
	
	-- Make sure we have a SML, and a valid clump to nuke
	if nukeLaunchersAeon[1] and  clumpNumAeon > 0 then
		IssueNuke(nukeLaunchersAeon, ScenarioUtils.MarkerToPosition('Nuke_Me_Clump_' .. clumpNumAeon))
	end
	
	-- Make sure we have a SML, and a valid clump to nuke
	if nukeLaunchersCybran[1] and clumpNumCybran > 0 then
		IssueNuke(nukeLaunchersCybran, ScenarioUtils.MarkerToPosition('Nuke_Me_Clump_' .. clumpNumCybran))
	end
	
	-- Make sure we have a valid clump
	if clumpNumAeon > 0 then
		local AeonAirPlatoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M3A0_Air_Attack_G1_D' .. Difficulty, 'AttackFormation')
		AeonAirPlatoon:Patrol(ScenarioUtils.MarkerToPosition('Nuke_Me_Clump_' .. clumpNumAeon))
		AeonAirPlatoon:Patrol(ScenarioUtils.MarkerToPosition('Player_Attack_Black_Sun'))
	end
	
	-- Make sure we have a valid clump
	if clumpNumCybran > 0 then
		local CybranAirPlatoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M3A0_Air_Attack_G1_D' .. Difficulty, 'AttackFormation')
		CybranAirPlatoon:Patrol(ScenarioUtils.MarkerToPosition('Nuke_Me_Clump_' .. clumpNumCybran))
		CybranAirPlatoon:Patrol(ScenarioUtils.MarkerToPosition('Player_Attack_Black_Sun'))
	end
end

-- First attack wave for phase 3, Aeon and Cybran Naval attacks
function M3AttackWaveOne()
	M3AttackWaveNukeClump()
	WaitSeconds(M3AttackWaveDelay)
	
    local aeonNavy = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M3A1_Naval_D' .. Difficulty, 'AttackFormation')
    ScenarioFramework.PlatoonAttackChain(aeonNavy, 'Aeon_M3_Attack_One_Chain')

    -- 6 minutes for destroyers to hit land
    local cybNavyGroup = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M3A1_Naval_G1_D' .. Difficulty, 'AttackFormation')
    ScenarioFramework.PlatoonAttackChain(cybNavyGroup,'Cybran_M3_Attack_One_Group_Chain')

    local cybNavyDest = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M3A1_Naval_G2_D' .. Difficulty, 'AttackFormation')
    ScenarioFramework.PlatoonAttackChain(cybNavyDest, 'Cybran_M3_Attack_One_Dest_Chain')

    local cybNavyWest = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran','M3A1_Naval_West_D' .. Difficulty, 'AttackFormation')
    ScenarioFramework.PlatoonAttackChain(cybNavyWest, 'Cybran_M3_Attack_One_West_Chain')
end

-- Second attack wave for phase 3 - Cybran Land attacks
function M3AttackWaveTwo()
	M3AttackWaveNukeClump()
	WaitSeconds(M3AttackWaveDelay)
	
    -- Massive Spiderbot platoon, chooses a random chain
    local SpiderPlatoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M3A2_Land_Spiders_D' .. Difficulty, 'AttackFormation')
	SpiderPlatoon.PlatoonData.PatrolChains = {
		'Cybran_M3_Attack_Two_Spider1_Chain',
		'Cybran_M3_Attack_Two_Spider2_Chain',
		'Cybran_M3_Attack_Two_Spider3_Chain',
		'Cybran_M3_Attack_Two_Spider4_Chain',
	}
	ScenarioPlatoonAI.PatrolChainPickerThread(SpiderPlatoon)

    local cybLandGroup1 = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M3A2_Land_Attack_G1_D' .. Difficulty, 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(cybLandGroup1, 'Cybran_M3_Attack_Two_Land_G1_Chain')

    local cybLandGroup2 = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M3A2_Land_Attack_G2_D' .. Difficulty, 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(cybLandGroup2, 'Cybran_M3_Attack_Two_Land_G2_Chain')

    local cybAir = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M3A2_Air_Attack_D' .. Difficulty, 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(cybAir, 'Cybran_M3_Attack_Two_Air_Chain')

    -- Aeon Clearing Attacks
    WaitSeconds(150)
    local aeonAirGroup1 = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M3A2_Air_Attack_G1_D' .. Difficulty, 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(aeonAirGroup1, 'Aeon_M3_Attack_Two_Air_G1_Chain')

    local aeonAirGroup2 = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M3A2_Air_Attack_G2_D' .. Difficulty, 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(aeonAirGroup2, 'Aeon_M3_Attack_Two_Air_G2_Chain')
end

-- Third attack wave for phase 3 - Cybran Transport assault, along with massive Air force, and an Aeon Tempest force
function M3AttackWaveThree()
	M3AttackWaveNukeClump()
	WaitSeconds(M3AttackWaveDelay)

    -- Cybran Attacks, multiply according to difficulty, this should be a massive assault
	for i = 1, Difficulty do
		local transports = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M3A3_Transports_Assault_D' .. Difficulty, 'AttackFormation')
		local units = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M3A3_Land_Assault_D' .. Difficulty, 'AttackFormation')
		ScenarioFramework.AttachUnitsToTransports(units:GetPlatoonUnits(), transports:GetPlatoonUnits())
		ForkThread(M3CybranLandAssault, units, transports)
		
		-- Delay the transport wave spawns a bit
		WaitSeconds(10)
	end

    local cybAir1 = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M3A3_Air_Attack_G1_D' .. Difficulty, 'AttackFormation')
    ScenarioFramework.PlatoonAttackChain(cybAir1, 'Cybran_M3_Attack_Two_Land_G1_Chain')

    local soulRippers = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M3A3_SoulRippers_D' .. Difficulty, 'AttackFormation')
    ScenarioFramework.PlatoonAttackChain(soulRippers, 'Cybran_M3_Attack_Two_Land_G1_Chain')
	ForkThread(ScenarioPlatoonAI.PlatoonEnableStealth, soulRippers)

    local cybAir2 = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M3A3_Air_Attack_G2_D' .. Difficulty, 'AttackFormation')
    ScenarioFramework.PlatoonAttackChain(cybAir2, 'Cybran_M3_Attack_Three_Air_G2_Chain')

    -- Send in Aeon Navy
    local aeonNavyPlat = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M3A3_Navy_Attack_D' .. Difficulty, 'AttackFormation')
    ScenarioFramework.PlatoonAttackChain(aeonNavyPlat, 'Aeon_M3_Attack_Three_Navy_G1_Chain')
end

-- Thread for the Cybran Transport assault
function M3CybranLandAssault(platoon, transports)
    local aiBrain = platoon:GetBrain()
    local cmd = transports:UnloadAllAtLocation(ScenarioUtils.MarkerToPosition('Cybran_M3_Land_Assault_Landing_Marker'))
    while transports:IsCommandsActive(cmd) do
        WaitSeconds(1)
        if not aiBrain:PlatoonExists(transports) then
            return
        end
    end
    --transports:MoveToLocation(ScenarioUtils.MarkerToPosition('Cybran_TransportReturn'), false)
    --aiBrain:AssignUnitsToPlatoon('TransportPool', transports:GetPlatoonUnits(), 'Scout', 'None')
	
	-- Safety checks, though they aren't really mandatory, might remove them later
	if ArmyBrains[Cybran]:PlatoonExists(platoon) then
		ScenarioFramework.PlatoonPatrolChain(platoon, 'Cybran_M3_Attack_Three_Land_Assault_Chain')
	end
	if ArmyBrains[Cybran]:PlatoonExists(transports) then
		ScenarioFramework.PlatoonPatrolChain(transports, 'Cybran_M3_Attack_Three_Land_Assault_Chain')
	end
end

-- Black Sun is almost ready, Arnold begins a last ditch effort, the final Aeon assault begins
function M3FinalAttack()
	M3AttackWaveNukeClump()
	WaitSeconds(M3AttackWaveDelay)
	
	-- Expand the map, start Phase 4, and add additional AI stuff if we've enabled full map access in the lobby
	if ScenarioInfo.Options.FullMapAccess == 2 then
		ScenarioFramework.SetSharedUnitCap(1500)
		ScenarioInfo.MissionNumber = 4
		ScenarioFramework.SetPlayableArea('M3_Playable_Area_FullMap')
		AeonAI.M3EnableSWTMLs()
		-- Add HLRA for Hard only
		if Difficulty == 3 then
			AeonAI.M3AddHLRA()
			CybranAI.M3AddHLRA()
		end
		M3AddSecondaryObjectives()
	end
	
	-- Navy
    local navy = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M3AF_Naval_Group_D' .. Difficulty, 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(navy, 'Aeon_M3_Attack_Final_Naval_Chain')
	
    -- Escorts
    local escorts = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M3AF_Air_Escort_D' .. Difficulty, 'AttackFormation')
    ScenarioFramework.PlatoonAttackChain(escorts, 'Aeon_M3_Attack_Final_Czar_Escorts_Chain')
	
	-- Torpedo Bombers
    local tBombers = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M3AF_Air_Torp_Bombers_D' .. Difficulty, 'AttackFormation')
    ScenarioFramework.PlatoonAttackChain(tBombers, 'Aeon_M3_Attack_Final_Torpedo_Chain')

    -- Czar and its stored units
	-- The idea is to create max 20-unit platoons and load them into the Czar
    local czarPlat = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M3AF_Czar', 'AttackFormation')
    ScenarioInfo.Czar = czarPlat:GetPlatoonUnits()[1]
    local airCzarStorage = ScenarioUtils.CreateArmyGroup('Aeon', 'M3AF_Storage_Czar_D' .. Difficulty)
	local CzarStorageUnitCount = table.getn(airCzarStorage)
    local unitCount = 0
    local czarStoragePlatoons = {}
    local currPlatoon = ArmyBrains[Aeon]:MakePlatoon('','')
	
	for _, unit in airCzarStorage do
		-- If we hit 20 units, we got our platoon, insert it into the platoons table, and start over with the counter
		if unitCount > 20 then
			currPlatoon = ArmyBrains[Aeon]:MakePlatoon('','')
			table.insert(czarStoragePlatoons, currPlatoon)
			unitCount = 0
		end
		
		ArmyBrains[Aeon]:AssignUnitsToPlatoon(currPlatoon, {unit}, 'Attack', 'AttackFormation')
		ScenarioInfo.Czar:AddUnitToStorage(unit)
		unitCount = unitCount + 1
	end
	
	-- Insert non-complete platoon into the platoons table
	if ArmyBrains[Aeon]:PlatoonExists(currPlatoon) and not table.empty(currPlatoon:GetPlatoonUnits()) and 20 > table.getn(currPlatoon:GetPlatoonUnits()) then
		table.insert(czarStoragePlatoons, currPlatoon)
	end
	
    czarPlat:ForkAIThread(M3FinalAttackCzarAI, czarStoragePlatoons)

	-- Only Arnold is required to be killed, if he's dead before the Czar is, you can still fire Black Sun
	------------------------------------
    -- Secondary Objective: Destroy Czar
	------------------------------------
    ScenarioInfo.M3S1Obj = Objectives.Kill(
		'secondary',
		'incomplete',
		OpStrings.M3S1Title,
		OpStrings.M3S1Description,
        {
            Units = {ScenarioInfo.Czar},
        }
   )
   ScenarioInfo.M3S1Obj:AddResultCallback(
        function(result)
			if (result) then
				if not ScenarioInfo.AikoUnitDestroyed and ScenarioInfo.AikoUnit:GetHealthPercent() >= .5  then
					ScenarioFramework.Dialogue(OpStrings.E06_M03_080)
				else
					ScenarioFramework.Dialogue(OpStrings.E06_M03_085)
				end
				
				local camInfo = {
					blendTime = 1.0,
					holdTime = 3,
					orientationOffset = { 0.25, 0.5, 0 },
					positionOffset = { 0, 0, 0 },
					zoomVal = 150,
					vizRadius = 40
				}
				
				ScenarioFramework.OperationNISCamera(ScenarioInfo.Czar, camInfo)
			end
        end
   )
   
    WaitSeconds(60)

    -- Land assaults, multiply according to difficulty, this should be a massive assault
	for i = 1, Difficulty + 1 do
		local trans1 = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M3AF_Transports_G1_D' .. Difficulty, 'ChevronFormation')
		local land1 = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M3AF_Land_G1_D' .. Difficulty, 'AttackFormation')
		ForkThread(M3LandAttack, trans1, land1, 1)

		local trans2 = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M3AF_Transports_G2_D' .. Difficulty, 'ChevronFormation')
		local land2 = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M3AF_Land_G2_D' .. Difficulty, 'AttackFormation')
		ForkThread(M3LandAttack, trans2, land2, 2)

		local trans3 = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M3AF_Transports_G3_D' .. Difficulty, 'ChevronFormation')
		local land3 = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M3AF_Land_G3_D' .. Difficulty, 'AttackFormation')
		ForkThread(M3LandAttack, trans3, land3, 3)
		
		-- Delay the transport wave spawns a bit
		WaitSeconds(10)
	end
	
	-- Go nuts with nukes for the final part, no mercy whatsoever
	CybranAI.M3AddNukePlatoon()
	AeonAI.M3AddNukePlatoon()
end

-- Thread for Arnold, teleports when final Aeon land assault force lands, or is otherwise destroyed
function M3ArnoldAIThread()
	-- Prevent him from spawning again if he was already spawned
	if ScenarioInfo.Arnold then
		return
	end
	
	-- Spawn Arnold
	ScenarioInfo.Arnold = ScenarioFramework.SpawnCommander('Aeon', 'Arnold_ACU', 'Warp', LOC('{i CDR_Arnold}'), true, false, {'ShieldHeavy', 'FAF_CrysalisBeamAdvanced', 'HeatSink'})
	ScenarioInfo.Arnold:SetVeterancy(Difficulty + 2)
	ScenarioInfo.Arnold:SetAutoOvercharge(true)
	-- Bool used for taunts
	ScenarioInfo.ArnoldSpawned = true
	
	------------------------------------
    -- Primary Objective: Destroy Arnold
	------------------------------------
    ScenarioInfo.M3P2Obj = Objectives.Kill(
		'primary',
		'incomplete',
		OpStrings.M3P2Title,
		OpStrings.M3P2Description,
        {
            Units = {ScenarioInfo.Arnold},
        }
   )
   ScenarioInfo.M3P2Obj:AddResultCallback(
        function(result)
			if (result) then
				ScenarioFramework.CDRDeathNISCamera(ScenarioInfo.Arnold, 3)
				ScenarioFramework.Dialogue(OpStrings.E06_M03_070)
				
				if not ScenarioInfo.AikoUnitDestroyed and ScenarioInfo.AikoUnit:GetHealthPercent() >= .5  then
                    ScenarioFramework.Dialogue(OpStrings.E06_M03_066, M3TransferCannon)
                else
                    ScenarioFramework.Dialogue(OpStrings.E06_M03_067, M3TransferCannon)
                end
			end
        end
   )
	
	local platoon = ArmyBrains[Aeon]:MakePlatoon('', '')
	ArmyBrains[Aeon]:AssignUnitsToPlatoon(platoon, {ScenarioInfo.Arnold}, 'Attack', 'NoFormation')
	
	-- I'm keeping this around if we ever need to buff Arnold's OC capabilities, but the gun upgrades should be more than enough
		--local weapon = ScenarioInfo.Arnold:GetWeaponByLabel('OverCharge')
		--weapon:ChangeMaxRadius(20)
	
    WaitSeconds(1)
    platoon:Stop()
    platoon:MoveToLocation(ScenarioUtils.MarkerToPosition('Player_Attack_Black_Sun'), false)
    while ArmyBrains[Aeon]:PlatoonExists(platoon) do
        if not ScenarioInfo.BlackSunCannon:IsDead() and not ScenarioInfo.Arnold:IsDead() and (Utilities.XZDistanceTwoVectors(ScenarioInfo.Arnold:GetPosition(), ScenarioInfo.BlackSunCannon:GetPosition()) < 25) then
            IssueClearCommands({ScenarioInfo.Arnold})
            --IssueOverCharge({ScenarioInfo.Arnold}, ScenarioInfo.BlackSunCannon)
            IssueAttack({ScenarioInfo.Arnold}, ScenarioInfo.BlackSunCannon)
            WaitSeconds(5)
            break
        end
        WaitSeconds(5)
    end
end

-- Thread for the Czar, moves via a path, and unloads if units are near it, which will then attack the closest enemy unit, while the Czar proceeds to Black Sun
function M3FinalAttackCzarAI(platoon, cargoPlatoons)
    local Czar = platoon:GetPlatoonUnits()[1]
    local released = false
    -- Move through locations
    local posChain = ScenarioUtils.ChainToPositions('Aeon_M3_Attack_Final_Czar_Chain')
    local i = 1
	
    while i <= table.getn(posChain) do
        local cmd = platoon:MoveToLocation(posChain[i], false)
		
        -- while the command is active and we haven't released the units
        while platoon:IsCommandsActive(cmd) and not released do
            local PlatoonPosition = platoon:GetPlatoonPosition()
            local target = platoon:FindClosestUnit('attack', 'Enemy', false, categories.ALLUNITS - categories.WALL)
            local targetPos = false
            if target and not target:IsDead() then
                targetPos = target:GetPosition()
            end
            if targetPos ~= false then
                PlatoonPosition = platoon:GetPlatoonPosition()
                -- Iff closest non-wall is less than 100 away, release the 'cargo'
                if VDist2(PlatoonPosition[1], PlatoonPosition[3], targetPos[1], targetPos[3]) < 100 then
                    released = true
                    IssueStop({Czar})
                    IssueClearCommands({Czar})
                    IssueTransportUnload({Czar}, posChain[i])
                    WaitSeconds(10)
                    if not ArmyBrains[Aeon]:PlatoonExists(platoon) then
                        return
                    end
					
                    for num, subPlat in cargoPlatoons do
						if ArmyBrains[Aeon]:PlatoonExists(subPlat) then
							subPlat:ForkAIThread(ScenarioPlatoonAI.PlatoonAttackClosestUnit)
						end
                    end
					
                    platoon:MoveToLocation(posChain[i], false)
                end
            end
            WaitSeconds(3)
            if not ArmyBrains[Aeon]:PlatoonExists(platoon) then
                return
            end
        end
        i = i + 1
    end
end

-- Thread for the Aeon Transport assault, which triggers Arnold to spawn
function M3LandAttack(transports, landPlat, num)
	-- Transport the final land assault force
    ScenarioFramework.AttachUnitsToTransports(landPlat:GetPlatoonUnits(), transports:GetPlatoonUnits())
    local cmd = transports:UnloadAllAtLocation(ScenarioUtils.MarkerToPosition('Aeon_M3_Attack_Final_Transport_Landing_'..num..'_Marker'))
    while transports:IsCommandsActive(cmd) do
        WaitSeconds(1)
		-- If the transports got intercepted, spawn Arnold anyway
        if not ArmyBrains[Aeon]:PlatoonExists(transports) then
            ForkThread(M3ArnoldAIThread)
            return
        end
    end
	-- Land assault force has landed, Arnold gates in
    ForkThread(M3ArnoldAIThread)
	-- Safety checks, though they aren't really mandatory, might remove them later
    if ArmyBrains[Aeon]:PlatoonExists(landPlat) then
		ScenarioFramework.PlatoonPatrolChain(landPlat, 'Player_Attack_Locations_Chain')
    end
	if ArmyBrains[Aeon]:PlatoonExists(transports) then
		ScenarioFramework.PlatoonPatrolChain(transports, 'Player_Attack_Locations_Chain')
    end
end

-- Phase 3 completion cutscene, and dialogue
function M3TransferCannon()
    ScenarioFramework.Dialogue(OpStrings.E06_M03_090, M3EnableCannon)
    
    -- Blacksun Ready to Fire cam
    local camInfo = {
        blendTime = 1,
        holdTime = 4,
        orientationOffset = { 2.5, 0.5, 0 },
        positionOffset = { 0, 1, 0 },
        zoomVal = 65,
        overrideCam = true,
    }
    ScenarioFramework.OperationNISCamera(ScenarioInfo.BlackSunCannon, camInfo)
	-- Objective Reminders timer
    ScenarioFramework.CreateTimerTrigger(M4ObjectiveReminder, 450)
end

-- Update Black Sun's UI, and allow the players to fire it via a toggleable ability
function M3EnableCannon()
	-- Update Black Sun UI progress bar
    ScenarioInfo.BlackSunCannon:SetWorkProgress(1)
	ScenarioInfo.M3ChargeComplete = true
	
	Objectives.UpdateBasicObjective(ScenarioInfo.M1P1Obj, 'progress', OpStrings['M3P1Progress20'])
	
	ScenarioInfo.M3P3Obj = Objectives.Basic(
		'primary',
		'incomplete',
		OpStrings.M3P3Title,
		OpStrings.M3P3Description,
		Objectives.GetActionIcon('kill'),
        {
            Units = {ScenarioInfo.BlackSunCannon},
        }
    )
	
	if not ScenarioInfo.BlackSunCannon:IsDead() then
        ScenarioInfo.BlackSunCannon:AddToggleCap('RULEUTC_SpecialToggle')
        ScenarioInfo.BlackSunCannon:SetCanTakeDamage(false)
        ScenarioInfo.BlackSunCannon:SetCanBeKilled(false)
        ScenarioInfo.BlackSunCannon:AddSpecialToggleEnable(M3BlackSunFired)
		-- The ability is a toggleable one, make sure both enabling and disabling triggers a game win
        ScenarioInfo.BlackSunCannon:AddSpecialToggleDisable(M3BlackSunFired)
    end
end

-- Black Sun fired, trigger end of operation
function M3BlackSunFired(unit)
    if not ScenarioInfo.BlackSunFiredBool then
        ScenarioInfo.BlackSunFiredBool = true
        WinGame()
    end
end

-- Phase 4 objective reminder
function M4ObjectiveReminder()
    if ScenarioInfo.MissionNumber == 4 then
        if Random(1,2) == 1 then
            ScenarioFramework.Dialogue(OpStrings.E06_M03_110)
        else
            ScenarioFramework.Dialogue(OpStrings.E06_M03_115)
        end
    end
end

--------------------
-- Utility Functions
--------------------

-- Sets the given unit as invunerable, but not uncaptureable
function SetUnitEssential(unit)
	unit:SetDoNotTarget(true)
    unit:SetCanBeKilled(false)
    unit:SetCanTakeDamage(false)
    unit:SetReclaimable(false)
end

-- Returns the clump number of the lowest enemy unit density clumpity clump clump
function GetLowestNonNegativeClumpThread(brainNum)
    local aiBrain = ArmyBrains[brainNum]
    local clumpNum = 0
    local lowCount = 0
    for i = 1, 9 do
        local count = table.getn(aiBrain:GetUnitsAroundPoint(categories.ALLUNITS - categories.WALL, ScenarioUtils.MarkerToPosition('Nuke_Me_Clump_'..i), 30, 'Enemy'))
		-- Pick the lowest, but also make sure there are at least some units
        if (count < lowCount or(count > 0 and lowCount == 0)) and count > 5 then
            clumpNum = i
            lowCount = count
        end
    end
    return clumpNum
end

-- Players have won, end the operation
function WinGame()
	ScenarioFramework.EndOperationSafety()
    if ScenarioInfo.M1P1Obj then
        ScenarioInfo.M1P1Obj:ManualResult(true)
    end
    if ScenarioInfo.M3P3Obj then
        ScenarioInfo.M3P3Obj:ManualResult(true)
    end
	
    ScenarioInfo.OpComplete = true
    ScenarioFramework.EndOperation(ScenarioInfo.OpComplete, ScenarioInfo.OpComplete, true)
end

-- Player ACU died, but if other player ACUs are still alive, continue
function PlayerCommanderDestroyed(unit)
    -- Abnormally, you don't necessarily 'lose' if you're killed on this mission: so long as Black Sun survives, and at least 1 player ACU remains
	-- REMINDER: This won't work if there's a pause set on ACU death
    -- Are all the ACUs dead?
    for index, unit in ScenarioInfo.HumanACUs do
        if not unit.Dead then
            -- Somebody is still alive
            return
        end
    end

    -- Everyone is dead, but is Black Sun?
    if ScenarioInfo.BlackSunDestroyed then
        return
    end

    ScenarioFramework.PlayerDeath(unit, OpStrings.E06_D01_010)
end

-- Black Sun death cam, and end operation as failure
function BlackSunCannonDestroyed(unit)
	-- ScenarioFramework.EndOperationCamera(unit)
    local camInfo = {
        blendTime = 2.5,
        holdTime = nil,
        orientationOffset = { math.pi, 0.7, 0 },
        positionOffset = { 0, 1, 0 },
        zoomVal = 65,
        spinSpeed = 0.03,
        overrideCam = true,
    }
    ScenarioFramework.OperationNISCamera(unit, camInfo)

    ScenarioInfo.BlackSunDestroyed = true
    if not ScenarioInfo.CDRDeath then
		ScenarioInfo.OpComplete = false
		ScenarioInfo.OpEnded = false
        ScenarioFramework.EndOperationSafety()
        ScenarioFramework.FlushDialogueQueue()
		
	-- There are 2 ways to do this, both should have the same results:
		-- First, we fire off the dialogue, last param indicates if it is a critical dialogue, which forces it to play over any other queued ones.
        --ScenarioFramework.Dialogue(OpStrings.E06_M02_110, ScenarioFramework.PlayerLose, true)
		
		-- Second, we call the lose function with the dialogue, add the table of objectives to manually set to failed, last param indicates if we want to ignore an already ongoing mission failure event
		ScenarioFramework.PlayerLose(OpStrings.E06_M02_110, {ScenarioInfo.M1P1Obj}, true)
    end
end

-- Dialogue and death cam for Aiko
function AikoDestroyed()
    ScenarioInfo.AikoUnitDestroyed = true
    ScenarioFramework.Dialogue(OpStrings.E06_M01_040)
    ScenarioFramework.CDRDeathNISCamera(ScenarioInfo.AikoUnit, 7)
end

-- Script updates if Aiko is given to a different army
function AikoGiven(oldAiko, newAiko)
    ScenarioInfo.AikoUnit = newAiko
	ScenarioFramework.CreateUnitDestroyedTrigger(AikoDestroyed, ScenarioInfo.AikoUnit)
    ScenarioFramework.CreateUnitGivenTrigger(AikoGiven, ScenarioInfo.AikoUnit)
end

---------
-- Taunts
---------
function RedFogTaunt()
	if ScenarioInfo.Options.FullMapAccess == 1 or (ScenarioInfo.RedFog and not ScenarioInfo.RedFog:IsDead()) then
		ScenarioFramework.Dialogue(OpStrings['TAUNT' .. Random(1, 8)])
		ScenarioFramework.CreateTimerTrigger(PlayTaunt, 180)
	else
		CanRedFogTaunt = false
		PlayTaunt()
	end
end

function ArnoldTaunt()
	if (not ScenarioInfo.ArnoldSpawned) or (ScenarioInfo.Arnold and not ScenarioInfo.Arnold:IsDead()) then
		ScenarioFramework.Dialogue(OpStrings['TAUNT' .. Random(9, 16)])
		ScenarioFramework.CreateTimerTrigger(PlayTaunt, 180)
	else
		CanArnoldTaunt = false
		PlayTaunt()
	end
end

function ArielTaunt()
	if ScenarioInfo.Ariel and not ScenarioInfo.Ariel:IsDead() then
		ScenarioFramework.Dialogue(OpStrings['TAUNT' .. Random(17, 22)])
		ScenarioFramework.CreateTimerTrigger(ArielTaunt, 180)
	end
end

function PlayTaunt()
	if CanArnoldTaunt or CanRedFogTaunt then
		local choice = Random(1, 2)
		if choice == 1 then
			RedFogTaunt()
		elseif choice == 2 and CanArnoldTaunt then
			ArnoldTaunt()
		end
	end
end