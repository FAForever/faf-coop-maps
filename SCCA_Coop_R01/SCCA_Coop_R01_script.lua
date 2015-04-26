-- ****************************************************************************
-- **
-- **  File     :  /maps/SCCA_Coop_R01/SCCA_Coop_R01_v01_script.lua
-- **  Author(s):  Greg
-- **
-- **  Summary  :
-- **
-- **  Copyright © 2006 Gas Powered Games, Inc.  All rights reserved.
-- ****************************************************************************

local ScenarioFramework = import('/lua/scenarioframework.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local Objectives = import('/lua/ScenarioFramework.lua').Objectives
local SimCamera = import('/lua/SimCamera.lua').SimCamera
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local Cinematics = import('/lua/cinematics.lua')
local OpStrings   = import('/maps/SCCA_Coop_R01/SCCA_Coop_R01_v01_Strings.lua')
local ScenarioStrings = import('/lua/ScenarioStrings.lua')
local Utilities = import('/lua/utilities.lua')

-- ----------------
-- Timing Variables
-- ----------------


-- -------
-- Globals
-- -------
ScenarioInfo.Player             = 1
ScenarioInfo.Aeon               = 2
ScenarioInfo.UEF                = 3
ScenarioInfo.Symbiont           = 4
ScenarioInfo.Dostya             = 5
ScenarioInfo.FauxUEF            = 6
ScenarioInfo.Wreckage_Holding   = 7
ScenarioInfo.Coop1 = 8
ScenarioInfo.Coop2 = 9
ScenarioInfo.Coop3 = 10
ScenarioInfo.HumanPlayers = {ScenarioInfo.Player}
local Player                = ScenarioInfo.Player
local Coop1 = ScenarioInfo.Coop1
local Coop2 = ScenarioInfo.Coop2
local Coop3 = ScenarioInfo.Coop3
local Aeon                  = ScenarioInfo.Aeon
local UEF                   = ScenarioInfo.UEF
local Symbiont              = ScenarioInfo.Symbiont
local Dostya                = ScenarioInfo.Dostya
local FauxUEF               = ScenarioInfo.FauxUEF
local Wreckage_Holding      = ScenarioInfo.Wreckage_Holding

ScenarioInfo.VarTable = {}
ScenarioInfo.VarTable['M3AeonAttackUEF'] = false

local DifficultyConc = 'Medium'

--

local M1_GeneratorsBuilt                = 0
local M1_ExtractorsBuilt                = 0
local M1_BuildObjective1ElementsDone    = 0
local M1_RadarPatrolsDestroyed          = 0
local M1_RadarAndPatrolElementsDone     = 0
local M1_BombersBuilt                   = 0

 -- - reminders
ScenarioInfo.M1P1Complete               = false -- power
ScenarioInfo.M1P2Complete               = false -- mass
ScenarioInfo.M2P1Complete               = false -- factory
ScenarioInfo.M3P1Complete               = false -- bombers
ScenarioInfo.M4P1Complete               = false -- radar patrols
ScenarioInfo.M4P2Complete               = false -- radar cap
ScenarioInfo.M5P1Complete               = false -- destroy mass
ScenarioInfo.M6P1Complete               = false -- uef camps
ScenarioInfo.M6P2Complete               = false -- uef patrols
ScenarioInfo.M7P1Complete               = false -- destroy guards
ScenarioInfo.M7P2Complete               = false -- destroy uef base
ScenarioInfo.M8P1Complete               = false -- defeat aeon cdr


 -- - reminder timers
local ReminderInitialTime1              = 600
local ReminderSubsequentTime1           = 300
local ReminderInitialTime2              = 630
local ReminderSubsequentTime2           = 600
 -- -
ScenarioInfo.Part2PatrolsDestroyed      = 0
ScenarioInfo.Part2CampsDestroyed        = 0
ScenarioInfo.Part2ElementsCompleted     = 0

ScenarioInfo.AeonCommanderKilled        = false
ScenarioInfo.OperationEnding            = false

local UEFMassObjCount               = 0
local M2TransportsUnloaded          = 0
local M2TransDefDone                = false
local M2SymbiontsReturned           = 0
local M2SymbiontsKilled             = 0

local M2TransferLossThreshold       = 5     -- Number of units out of (currently) 12 left over from the M2 transfer that we call our threshold for toning down the stream difficulty.
local Part3EastBaseCounter          = 0
local Part3SymbCleanupCount         = 0
local Part3EastDefDone              = false
local Part3EastBaseDone             = false
local Part3EasternAAGroupsDestroyed = 0

local Part4UEFWaveCount             = 0
ScenarioInfo.TooEarlyForAeonTaunts  = true  -- Part 4, check this before we play a taunt. We set this to false after a minute or so from start of mission, so taunts dont stack up if player is very prepared.

local M3P1_BomberBuildValue         = 5   -- number of bombers the player is to build for the objective M3P1

-- --------------------
-- Starter Functions
-- --------------------

function OnPopulate(scenario)
	ScenarioUtils.InitializeScenarioArmies()

    -- Player only gets score
    for i = 2, table.getn(ArmyBrains) do
        if i < ScenarioInfo.Coop1 then
            SetArmyShowScore(i, false)
            SetIgnorePlayableRect(i, true)
        end
    end

    -- -- Add initial groups here
    M1UnitsForStart()
    local Weather = import('/lua/weather.lua')
    -- Weather.CreateWeather()
end

function M1UnitsForStart()
    ScenarioInfo.Difficulty = ScenarioInfo.Options.Difficulty or 2
    -- Set difficulty concantenation string
    if ScenarioInfo.Difficulty == 1 then DifficultyConc = 'Light' end
    if ScenarioInfo.Difficulty == 2 then DifficultyConc = 'Medium' end
    if ScenarioInfo.Difficulty == 3 then DifficultyConc = 'Strong' end

    -- set our colors
    ScenarioFramework.SetCybranColor(1)
    ScenarioFramework.SetAeonColor(2)
    ScenarioFramework.SetUEFColor(3)
    ScenarioFramework.SetCybranNeutralColor(4)
    ScenarioFramework.SetCybranAllyColor(5)
    ScenarioFramework.SetUEFColor(6)
    ScenarioFramework.SetCybranNeutralColor(7)

    -- Create Dostya's group, name Dostya, move them out
    ScenarioInfo.InitialVizArea = ScenarioFramework.CreateVisibleAreaLocation(30, ScenarioUtils.MarkerToPosition('CommanderStartLocation'), 12, ArmyBrains[Player])
    ScenarioInfo.Dostya_Group = ScenarioUtils.CreateArmyGroup('Dostya' ,'Dosta_IntialGroup')
    ScenarioInfo.Dostya_DostyaUnit = ScenarioInfo.UnitNames[Dostya]['M1_DostyaUnit']
    ScenarioInfo.Dostya_DostyaUnit:SetCustomName(LOC '{i CDR_Dostya}')
    for k,v in ScenarioInfo.Dostya_Group do
        ScenarioFramework.CreateUnitToMarkerDistanceTrigger(StartUnitDestroy, v, ScenarioUtils.MarkerToPosition('SpiderBotDestination'), 16)
        IssueMove({v}, ScenarioUtils.MarkerToPosition('SpiderBotDestination'))
        ForkThread(StartUnitForcedOffmapThread,v)
        v:SetReclaimable(false)
        v:SetCapturable(false)
        v:SetCanBeKilled(false)
        v:SetCanTakeDamage(false)
    end

    ScenarioInfo.FauxUEF_StartGroup = ScenarioUtils.CreateArmyGroup('FauxUEF' ,'FauxUEF_Starting_Enemies')
    ScenarioUtils.CreateArmyGroup('Wreckage_Holding' ,'Part1_UEF_Wreckage', true)

    ScenarioFramework.CreateTimerTrigger(SwapDostyaNeutral, 21)
end

function OnLoad(self)
end

function OnStart(self)
    ScenarioFramework.SetPlayableArea(ScenarioUtils.AreaToRect('PlayableArea_Initial'), false)
    ForkThread(StartCamera)
end

function StartCamera()
    -- WaitSeconds(2)
    Cinematics.EnterNISMode()
    Cinematics.CameraMoveToRectangle(ScenarioUtils.AreaToRect('StartCameraArea'), .65)
    WaitSeconds(.25)
    Cinematics.CameraMoveToRectangle(ScenarioUtils.AreaToRect('CameraArea_1'), 3)
    ScenarioFramework.Dialogue(OpStrings.C01_M01_010)
    ScenarioFramework.CreateTimerTrigger(SecondCamera, 2.5)
end

function SecondCamera()
    Cinematics.CameraMoveToRectangle(ScenarioUtils.AreaToRect('CameraArea_2'), 1.1)
    Cinematics.ExitNISMode()
    BeginOperation()
end

-- ------------
-- Part 1
-- ------------

 -- -- M1 Part1

function BeginOperation()
    BuildCategories1()
    for i = 2, table.getn(ArmyBrains) do
    end
    -- ScenarioFramework.Dialogue(OpStrings.C01_M01_010, CreatePlayerCommander)
    CreatePlayerCommander()

    -- Dialogue (build cats with dialogue after delay)
    ScenarioInfo.MissionNumber = 1

	for _, player in ScenarioInfo.HumanPlayers do
		SetArmyUnitCap(player, 250)
	end
	
	SetArmyUnitCap(2, 700)
    SetArmyUnitCap(3, 700)

    ScenarioFramework.CreateTimerTrigger(BeginningObjectives, 10)
    ScenarioFramework.CreateTimerTrigger(BeginningDialogue, 7)

    -- Send any remaining FauxUEF starting units offmap
    ForkThread(MoveFuaxUEFOutThread)
end

function CreatePlayerCommander()
    -- CDR
    ScenarioInfo.PlayerCDR = ScenarioUtils.CreateArmyUnit('Player', 'M1PlayerCDR')
    ScenarioInfo.PlayerCDR:PlayCommanderWarpInEffect()

    -- spawn coop players too
    ScenarioInfo.CoopCDR = {}
    local tblArmy = ListArmies()
    coop = 1
    for iArmy, strArmy in pairs(tblArmy) do
        if iArmy >= ScenarioInfo.Coop1 then
            ScenarioInfo.CoopCDR[coop] = ScenarioUtils.CreateArmyUnit(strArmy, 'M1PlayerCDR')
            ScenarioInfo.CoopCDR[coop]:PlayCommanderWarpInEffect()
            coop = coop + 1
            WaitSeconds(0.5)
        end
    end

    ScenarioFramework.PauseUnitDeath(ScenarioInfo.PlayerCDR)

    for index, coopACU in ScenarioInfo.CoopCDR do
        ScenarioFramework.PauseUnitDeath(coopACU)
        ScenarioFramework.CreateUnitDeathTrigger(PlayerCDRKilled, coopACU)
    end


    -- set up death/failure trigger for player cdr
    ScenarioFramework.CreateUnitDeathTrigger(PlayerCDRKilled, ScenarioInfo.PlayerCDR)
end

function SwapDostyaNeutral()
    -- Set Dostya to neutral, so we stop getting sight intel from that army as they go offmap.
    for _, player in ScenarioInfo.HumanPlayers do
        SetAlliance(player, Dostya, 'Neutral')
    end
    for _, player in ScenarioInfo.HumanPlayers do
        SetAlliance(Dostya, player, 'Neutral')
    end
end

function BeginningDialogue()
    ScenarioFramework.Dialogue(OpStrings.C01_M01_020)
end

function BeginningObjectives()
    ScenarioFramework.CreateTimerTrigger(M1P2Reminder1, ReminderInitialTime1)

    ScenarioInfo.M1Objectives = Objectives.CreateGroup('Mission1', BuildFactory)
    -- Primary Objective 2
    ScenarioInfo.M1P2 = Objectives.ArmyStatCompare(
        'primary',                      -- type
        'incomplete',                   -- complete
        OpStrings.M1P2Text,             -- title
        OpStrings.M1P2Detail,           -- description
        'build',                        -- action
        {                               -- target
            Army = ScenarioInfo.Player,
            StatName = 'Units_Active',
            CompareOp = '>=',
            Value = 3,
            Category = categories.urb1103,
            ShowProgress = true,

        }
   )
    ScenarioInfo.M1P2:AddResultCallback(
        function()
            ScenarioInfo.M1P2Complete = true
            BeginningObjectivesB()
        end
   )
    ScenarioInfo.M1Objectives:AddObjective(ScenarioInfo.M1P2)
end

function BeginningObjectivesB()
    ScenarioFramework.CreateTimerTrigger(M1P1Reminder1, ReminderInitialTime1)
    BuildCategories1b()
    ScenarioInfo.M1P1 = Objectives.ArmyStatCompare(
        'primary',                      -- type
        'incomplete',                   -- complete
        OpStrings.M1P1Text,             -- title
        OpStrings.M1P1Detail,           -- description
        'build',                        -- action
        {                               -- target
            Army = ScenarioInfo.Player,
            StatName = 'Units_Active',
            CompareOp = '>=',
            Value = 3,
            Category = categories.urb1101,
            ShowProgress = true,
        }
   )
    ScenarioInfo.M1P1:AddResultCallback(
        function()
            ScenarioInfo.M1P1Complete = true
        end
   )
    ScenarioInfo.M1Objectives:AddObjective(ScenarioInfo.M1P1)

end

function StartUnitForcedOffmapThread(unit)
    while not unit:IsDead() do
        IssueStop({unit})
        IssueMove({unit}, ScenarioUtils.MarkerToPosition('SpiderBotDestination'))
        WaitSeconds(7)
    end
end

function MoveFuaxUEFOutThread()
    -- After a slight pause, move all remaining FauxUEF units offmap to be destroyed, just in case any have survived
    WaitSeconds(5)
    for k,v in ScenarioInfo.FauxUEF_StartGroup do
        if not v:IsDead() then
            ScenarioFramework.CreateUnitToMarkerDistanceTrigger(StartUnitDestroy, v, ScenarioUtils.MarkerToPosition('SpiderBotDestination'), 16)
            IssueMove({v}, ScenarioUtils.MarkerToPosition('SpiderBotDestination'))
            ForkThread(StartUnitForcedOffmapThread,v)
        end
    end
end

function StartUnitDestroy(unit)
    unit:Destroy()
end

function BuildFactory()
    ScenarioInfo.MissionNumber = 2
    ScenarioFramework.Dialogue(OpStrings.C01_M02_010, BuildFactory_Obj)
    ScenarioFramework.SetPlayableArea(ScenarioUtils.AreaToRect('PlayableArea_1'))
    BuildCategories2()
end

function BuildFactory_Obj()
    -- Primary Objective 1
    local m2Objectives = Objectives.CreateGroup('Mission2', M1_BuildBomber)
    ScenarioInfo.M2P1 = Objectives.ArmyStatCompare(
        'primary',                      -- type
        'incomplete',                   -- complete
        OpStrings.M2P1Text,             -- title
        OpStrings.M2P1Detail,           -- description
        'build',                        -- action
        {                               -- target
            Army = Player,
            StatName = 'Units_Active',
            CompareOp = '>=',
            Value = 1,
            Category = categories.urb0102,
        }
   )
    ScenarioInfo.M2P1:AddResultCallback(
        function()
            ScenarioInfo.M2P1Complete = true -- ###!!!
        end
   )
    m2Objectives:AddObjective(ScenarioInfo.M2P1)

    -- Reminder
    ScenarioFramework.CreateTimerTrigger(M2P1Reminder1, ReminderInitialTime1)
end

function M1_BuildBomber()
    ScenarioInfo.MissionNumber = 3
    ScenarioFramework.Dialogue(OpStrings.C01_M03_010, M1_BuildBomberObjective)
    BuildCategories3()
end

function M1_BuildBomberObjective()
    ScenarioFramework.CreateTimerTrigger(M3P1Reminder1 ,ReminderInitialTime1)

    -- Primary Objective 1
    local m3Objectives = Objectives.CreateGroup('Mission3', M1_BeginPart2Intro)
    ScenarioInfo.M3P1 = Objectives.ArmyStatCompare(
        'primary',                      -- type
        'incomplete',                   -- complete
        LOCF(OpStrings.M3P1Text, M3P1_BomberBuildValue),   -- title
        LOCF(OpStrings.M3P1Detail, M3P1_BomberBuildValue),  -- description
        'build',                        -- action
        {                               -- target
            Army = Player,
            StatName = 'Units_Active',
            CompareOp = '>=',
            Value = M3P1_BomberBuildValue,
            Category = categories.ura0103,
            ShowProgress = true,
        }
   )
    ScenarioInfo.M3P1:AddResultCallback(
        function()
            ScenarioInfo.M3P1Complete = true
        end
   )
    m3Objectives:AddObjective(ScenarioInfo.M3P1)
end


 -- -- M1 Part2

function M1_BeginPart2Intro()
    -- DIALOGUE
    ScenarioFramework.Dialogue(OpStrings.C01_M04_010, M1_BeginPart2)
end

function M1_BeginPart2()
    ScenarioInfo.MissionNumber = 4

    ScenarioFramework.SetPlayableArea(ScenarioUtils.AreaToRect('PlayableArea_2'))
    ScenarioFramework.CreateTimerTrigger(M4P1Reminder1 ,ReminderInitialTime1)

    -- UEF Radar, invuln for ease of play. Set generators invuln as well.
    ScenarioInfo.M1UEFRadar = ScenarioUtils.CreateArmyUnit('FauxUEF', 'M1_UEFRadar_Structure')
    ScenarioInfo.m1UEFRadarCamp = ScenarioUtils.CreateArmyGroup('FauxUEF', 'M1_UEFRadarCamp')
    ScenarioInfo.M1UEFRadar:SetReclaimable(false)
    ScenarioInfo.M1UEFRadar:SetCanBeKilled(false)
    ScenarioInfo.M1UEFRadar:SetCanTakeDamage(false)
    for k,v in ScenarioInfo.m1UEFRadarCamp do
        v:SetReclaimable(false)
        v:SetCanBeKilled(false)
        v:SetCanTakeDamage(false)
    end
    ScenarioFramework.CreateVisibleAreaLocation(2, ScenarioInfo.M1UEFRadar:GetPosition(), .1, ArmyBrains[Player])


    -- Defenders for it, with patrol and death triggers
    ScenarioInfo.M1RadarPatrol1 = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF' ,'M1_UEFRadar_Patrol1_'..DifficultyConc ,'AttackFormation')
    ScenarioInfo.M1RadarPatrol2 = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF' ,'M1_UEFRadar_Patrol2_'..DifficultyConc ,'AttackFormation')

    ForkThread(PatrolWithPauseThread,'M1_NorthRadarPatrolChain',ScenarioInfo.M1RadarPatrol1)
    ForkThread(PatrolWithPauseThread,'M1_WestRadarPatrolChain',ScenarioInfo.M1RadarPatrol2)

    -- Destroy Patrolers
    local patrolUnits = ScenarioInfo.M1RadarPatrol1:GetPlatoonUnits()
    local patrolUnits2 = ScenarioInfo.M1RadarPatrol2:GetPlatoonUnits()
    for k, v in patrolUnits2 do
        table.insert(patrolUnits, v)
    end
    local m4bObjectives = Objectives.CreateGroup('Mission4b', M1_RadarPatrolDestroyed)
    ScenarioInfo.M4P1 = Objectives.KillOrCapture(
        'primary',                      -- type
        'incomplete',                   -- complete
        OpStrings.M4P1Text,             -- title
        OpStrings.M4P1Detail,           -- description
        {                               -- target
            Units = patrolUnits,
        }
   )
    m4bObjectives:AddObjective(ScenarioInfo.M4P1)

    -- Radar Capture objective
    ScenarioInfo.M4Objectives = Objectives.CreateGroup('Mission4', M1_CaptureRadarObj, 1)
    ScenarioInfo.M4P2 = Objectives.Capture(
        'primary',                      -- type
        'incomplete',                   -- complete
        OpStrings.M4P2Text,             -- title
        OpStrings.M4P2Detail,           -- description
        {                               -- target
            Units = {ScenarioInfo.M1UEFRadar},
        }
   )
    ScenarioInfo.M4P2:AddResultCallback(M1_ShowCapturedRadar)
    ScenarioInfo.M4Objectives:AddObjective(ScenarioInfo.M4P2)
end

function M1_RadarPatrolDestroyed()
    -- ScenarioFramework.UpdateObjective(OpStrings.M4P1Text, 'complete', 'complete')
    ScenarioInfo.M4P1Complete = true

    -- Tell the counter this half of the stage is done.
    M1_RadarAndPatrolCounter()

    if ScenarioInfo.M4P2Complete == false then
        -- PLAY PROMPT TO CAP THE RADAR IF WE HAVENT DONE SO YET
        ScenarioFramework.Dialogue(OpStrings.C01_M04_020)
    end

end

function M1_ShowCapturedRadar(result, units)
    if units then
        local radar
        for k, unit in units do
            radar = unit
        end

-- Radar captured camera
        local camInfo = {
            blendTime = 1.0,
            holdTime = 4,
            orientationOffset = { 0.7854, 0.2, 0 },
            positionOffset = { 0, 0.5, 0 },
            zoomVal = 35,
        }
        ScenarioFramework.OperationNISCamera(radar, camInfo)
    end
end

function M1_CaptureRadarObj()
    ScenarioInfo.M4P2Complete = true

    -- if patrols around the radar are still present
    -- if not ScenarioInfo.M4P1Complete then
    -- #Prompt to finish off the radar patrolers. Dialogue does not yet exist.
    -- end

    -- Tell the counter that one half of the stage is done.
    M1_RadarAndPatrolCounter()

    -- Swap the power etc over to the player, once theyve captured the Radar.
    for k,v in ScenarioInfo.m1UEFRadarCamp do
        if not v:IsDead() then
            ScenarioFramework.GiveUnitToArmy(v, Player)
        end
    end
end

function M1_RadarAndPatrolCounter()
    M1_RadarAndPatrolElementsDone = M1_RadarAndPatrolElementsDone + 1
    if M1_RadarAndPatrolElementsDone == 2 then
        -- Done
        ScenarioFramework.Dialogue(OpStrings.C01_M05_020, M1_RadarAndPatrolClosingPause)
    end
end

function M1_RadarAndPatrolClosingPause()
        ScenarioFramework.CreateTimerTrigger(M1_DestroyMass, 3)-- slight pause between obj's
end

 -- -- M1 Part3

function M1_DestroyMass()
    ScenarioInfo.MissionNumber = 5

    ScenarioFramework.Dialogue(OpStrings.C01_M05_010)
    ScenarioFramework.CreateTimerTrigger(M5P1Reminder1 ,ReminderInitialTime1)

    -- Unlock interceptors, etc. On hard diff, unlock AA towers early.
    BuildCategories4()
    if ScenarioInfo.Difficulty == 3 then
        BuildCategories4b()
    end

    local massExtractors = ScenarioUtils.CreateArmyGroup('UEF', 'M1UEFMassExstractors')
    if ScenarioInfo.Difficulty == 3 then
        ScenarioUtils.CreateArmyGroup('UEF', 'M1UEFMassDefStatic')
    end
    local massDefense = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF' ,'M1UEFMassDefPatrol_'..DifficultyConc ,'AttackFormation')
    ScenarioInfo.MassDefenseAir = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF' ,'M1UEFMassAirPatrol_'..DifficultyConc ,'ChevronFormation')

    -- Send defenders on patrol. Use a pausing patrol for the land defense.
    ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.MassDefenseAir, 'UEFMassAirPatrol_Chain')
    ForkThread(PatrolWithPauseThread,'M1_MassPatrolChain',massDefense)
    ForkThread(UEFIntercepter_CheckThread)

    ScenarioInfo.M5P1 = Objectives.KillOrCapture(
        'primary',                      -- type
        'incomplete',                   -- complete
        OpStrings.M5P1Text,             -- title
        OpStrings.M5P1Detail,           -- description
        {                               -- target
            Units = massExtractors,
        }
   )
    ScenarioInfo.M5P1:AddResultCallback(
        function(result, unit)
-- Extractors destroyed/captured camera
            local camInfo = {
                blendTime = 1.0,
                holdTime = 4,
                orientationOffset = { 0.9, 0.1, 0 },
                positionOffset = { 0, 1.5, 0 },
                zoomVal = 35,
                markerCam = true,
            }
            ScenarioFramework.OperationNISCamera(ScenarioUtils.MarkerToPosition("NIS_Extractors_Destroyed"), camInfo)

            ScenarioInfo.M5P1Complete = true
            ScenarioFramework.CreateTimerTrigger(BeginPart2, 4)-- slight pause between obj's
        end
   )

    ScenarioFramework.SetPlayableArea(ScenarioUtils.AreaToRect('PlayableArea_3'))
end

function UEFIntercepter_CheckThread()
    -- If interceptors get in the player base area, send them back on patrol to the mass area.
    while ArmyBrains[UEF]:PlatoonExists(ScenarioInfo.MassDefenseAir) do
        if ScenarioFramework.NumCatUnitsInArea(categories.uea0102 , ScenarioUtils.AreaToRect('PlayableArea_Initial'), ArmyBrains[UEF]) > 0 then
            ScenarioInfo.MassDefenseAir:Stop()
            ScenarioInfo.MassDefenseAir:MoveToLocation(ScenarioUtils.MarkerToPosition('UEF_Mass_Area'), false)
            ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.MassDefenseAir, 'UEFMassAirPatrol_Chain')
        end
        WaitSeconds(6)
    end
end
-- ------------
-- Part 2
-- ------------

function BeginPart2()
    -- Wreckage
    ScenarioUtils.CreateArmyGroup('Wreckage_Holding' ,'Part2_Aeon_Wreckage', true)
    ScenarioUtils.CreateArmyGroup('Symbiont' ,'Part2_Symb_Wreckage', true)
    ScenarioUtils.CreateArmyGroup('Wreckage_Holding' ,'Part2_UEF_Wreckage', true)

    ScenarioInfo.MissionNumber = 6
	for _, player in ScenarioInfo.HumanPlayers do
		SetArmyUnitCap(player, 400)
	end	

    SetArmyUnitCap(2, 500)
    SetArmyUnitCap(3, 500)

    -- Create units, objs
    Part2CreateSymbionts()
    Part2CreatUEFUnitsObjectives()

    -- Delay expanding the map for a bit, so the player can digest the dialogue: we want Jericho to be
    -- reconized as a friendly when he flees through the players base.
    ScenarioFramework.Dialogue(OpStrings.C01_M06_010)
    ScenarioFramework.CreateTimerTrigger(BeginPart2_DelayedAreaChange, 4)
    BuildCategories5()
    BuildCategories6()

    ScenarioFramework.CreateTimerTrigger(M6P1Reminder1 ,ReminderInitialTime2)
end

function BeginPart2_DelayedAreaChange()
    ScenarioFramework.SetPlayableArea(ScenarioUtils.AreaToRect('PlayableArea_4'))
end

function Part2CreatUEFUnitsObjectives()
    -- Patrolers
    ScenarioInfo.UefPatrol1 = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M2_UEFPatrol_1_'..DifficultyConc, 'NoFormation')
    ScenarioInfo.UefPatrol2 = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M2_UEFPatrol_2_'..DifficultyConc, 'NoFormation')
    ScenarioInfo.UefPatrol3 = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M2_UEFPatrol_3_'..DifficultyConc, 'NoFormation')

    ScenarioFramework.CreatePlatoonDeathTrigger(Part2PatrolsObjective, ScenarioInfo.UefPatrol1)
    ScenarioFramework.CreatePlatoonDeathTrigger(Part2PatrolsObjective, ScenarioInfo.UefPatrol2)
    ScenarioFramework.CreatePlatoonDeathTrigger(Part2PatrolsObjective, ScenarioInfo.UefPatrol3)

    ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.UefPatrol1, 'M2_MiddlePatrolNorth_Chain')
    ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.UefPatrol2, 'M2_MiddlePatrolMid_Chain')
    ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.UefPatrol3, 'M2_MiddlePatrolSouth_Chain')

    -- On hard dif, set the new patrols to go near the player's base
    if ScenarioInfo.Difficulty == 3 then
        ScenarioFramework.CreateTimerTrigger(Part2_Hard_AlternatePatrolThread, 60)
    end

    -- Camps
    ScenarioInfo.Part2UEFTurrets1 = ScenarioUtils.CreateArmyGroup('UEF', 'M2_UEFCamp_1_Turrets_'..DifficultyConc)
    ScenarioInfo.Part2UEFTurrets2 = ScenarioUtils.CreateArmyGroup('UEF', 'M2_UEFCamp_2_Turrets_'..DifficultyConc)
    ScenarioInfo.Part2UEFTurrets3 = ScenarioUtils.CreateArmyGroup('UEF', 'M2_UEFCamp_3_Turrets_'..DifficultyConc)

    ScenarioFramework.CreateGroupDeathTrigger(Part2CampsObjective, ScenarioInfo.Part2UEFTurrets1)
    ScenarioFramework.CreateGroupDeathTrigger(Part2CampsObjective, ScenarioInfo.Part2UEFTurrets2)
    ScenarioFramework.CreateGroupDeathTrigger(Part2CampsObjective, ScenarioInfo.Part2UEFTurrets3)

    ScenarioInfo.M6CampUnits = {}
    AddGroupToTable(ScenarioInfo.M6CampUnits, ScenarioInfo.Part2UEFTurrets1)
    AddGroupToTable(ScenarioInfo.M6CampUnits, ScenarioInfo.Part2UEFTurrets2)
    AddGroupToTable(ScenarioInfo.M6CampUnits, ScenarioInfo.Part2UEFTurrets3)

    ScenarioUtils.CreateArmyGroup('UEF', 'M2_UEFCamp_1_Structures')
    ScenarioUtils.CreateArmyGroup('UEF', 'M2_UEFCamp_2_Structures')
    ScenarioUtils.CreateArmyGroup('UEF', 'M2_UEFCamp_3_Structures')
    ScenarioUtils.CreateArmyGroup('UEF', 'M2_UEFDefenseWallsGeneral')

    -- Objectives
    ScenarioInfo.M6P1 = Objectives.Basic(
        'primary',
        'incomplete',
        OpStrings.M6P1Text,
        OpStrings.M6P1Detail,
        Objectives.GetActionIcon('kill'),
        {
            Units = ScenarioInfo.M6CampUnits,
            MarkUnits = true,
        }
   )

    ScenarioInfo.M6P2 = Objectives.Basic(
        'primary',
        'incomplete',
        OpStrings.M6P2Text,
        OpStrings.M6P2Detail,
        Objectives.GetActionIcon('kill'),
        {
        }
   )
end

function Part2_Hard_AlternatePatrolThread()
        -- Change the patrol to get nearer to players base
        if ArmyBrains[UEF]:PlatoonExists(ScenarioInfo.UefPatrol1) then
            ScenarioInfo.UefPatrol1:Stop()
            ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.UefPatrol1, 'M2_MiddlePatrolNorth_Chain_Hard')
            WaitSeconds(40)
        end
        if ArmyBrains[UEF]:PlatoonExists(ScenarioInfo.UefPatrol1) then
            ScenarioInfo.UefPatrol3:Stop()
            ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.UefPatrol3, 'M2_MiddlePatrolSouth_Chain_Hard')
        end
end

function Part2CampsObjective()
    ScenarioInfo.Part2CampsDestroyed = ScenarioInfo.Part2CampsDestroyed + 1
    if ScenarioInfo.Part2CampsDestroyed == 1 then
        Objectives.UpdateBasicObjective(ScenarioInfo.M6P1, 'progress', OpStrings.M6P1Destroyed1)
    elseif ScenarioInfo.Part2CampsDestroyed == 2 then
        Objectives.UpdateBasicObjective(ScenarioInfo.M6P1, 'progress', OpStrings.M6P1Destroyed2)
    elseif ScenarioInfo.Part2CampsDestroyed == 3 then
        -- let the reminder know we are done
        ScenarioInfo.M6P1Complete = true

-- Defenses destroyed camera
        local camInfo = {
            blendTime = 1.0,
            holdTime = 4,
            orientationOffset = { -1.7, 0.4, 0 },
            positionOffset = { 0, 2, 0 },
            zoomVal = 45,
            markerCam = true,
        }
        ScenarioFramework.OperationNISCamera(ScenarioUtils.MarkerToPosition("NIS_Defenses_Destroyed"), camInfo)

        -- Update progress to final, and complete
        Objectives.UpdateBasicObjective(ScenarioInfo.M6P1, 'progress', OpStrings.M6P1Destroyed3)
        ScenarioInfo.M6P1:ManualResult(true)

        ScenarioFramework.Dialogue(OpStrings.C01_M06_020)

        -- One half of mission done
        Part2FinishCounter()
    end
end

function Part2PatrolsObjective()
    ScenarioInfo.Part2PatrolsDestroyed = ScenarioInfo.Part2PatrolsDestroyed + 1
    if ScenarioInfo.Part2PatrolsDestroyed == 1 then
        Objectives.UpdateBasicObjective(ScenarioInfo.M6P2, 'progress', OpStrings.M6P2Destroyed1)
    end
    if ScenarioInfo.Part2PatrolsDestroyed == 2 then
        Objectives.UpdateBasicObjective(ScenarioInfo.M6P2, 'progress', OpStrings.M6P2Destroyed2)
    end
    if ScenarioInfo.Part2PatrolsDestroyed == 3 then
        -- let the reminder know we are done
        ScenarioInfo.M6P2Complete = true

        -- Update progress to final, and complete
        Objectives.UpdateBasicObjective(ScenarioInfo.M6P2, 'progress', OpStrings.M6P2Destroyed3)
        ScenarioInfo.M6P2:ManualResult(true)
        ScenarioFramework.Dialogue(OpStrings.C01_M06_030)

        -- One half of mission done
        Part2FinishCounter()
    end
end

 -- - Symbiont functions

function Part2CreateSymbionts()
    -- M2 Spawn in the Symbionts
    ScenarioInfo.M2Symb1 = ScenarioUtils.CreateArmyUnit('Symbiont', 'M2Symb1')
    ScenarioInfo.M2Symb2 = ScenarioUtils.CreateArmyUnit('Symbiont', 'M2Symb2')
    ScenarioInfo.M2Symb3 = ScenarioUtils.CreateArmyUnit('Symbiont', 'M2Symb3')
    ScenarioInfo.M2Symb4 = ScenarioUtils.CreateArmyUnit('Symbiont', 'M2Symb4')
    ScenarioInfo.M2Symb5 = ScenarioUtils.CreateArmyUnit('Symbiont', 'M2Symb5')

    ScenarioInfo.M2Symb4:SetCustomName(LOC '{i sCDR_Jericho}')

    -- mess a few of them up a bit, for show
    DamageUnit(ScenarioInfo.M2Symb1)
    DamageUnit(ScenarioInfo.M2Symb2)
    DamageUnit(ScenarioInfo.M2Symb3)
    DamageUnit(ScenarioInfo.M2Symb4)
    DamageUnit(ScenarioInfo.M2Symb5)

    -- Send each to a function that sets their invuln etc flags, and sends them on their way with a distance trigger etc
    Part2SymbiontStart(ScenarioInfo.M2Symb1)
    Part2SymbiontStart(ScenarioInfo.M2Symb2)
    Part2SymbiontStart(ScenarioInfo.M2Symb3)
    Part2SymbiontStart(ScenarioInfo.M2Symb4)
    Part2SymbiontStart(ScenarioInfo.M2Symb5)
end

function Part2SymbiontStart(unit)
    -- Set flags for the unit
    unit:SetReclaimable(false)
    unit:SetCapturable(false)
    unit:SetCanBeKilled(false)
    unit:SetCanTakeDamage(false)

    -- Creat new distance trigger for offmap deletion point
    ScenarioFramework.CreateUnitToMarkerDistanceTrigger(Part2SymbiontOffmapCleanup, unit, ScenarioUtils.MarkerToPosition('M2SymbMovePoint3'), 10)

    -- fork the thread that will keep giving it moves to the offmap deletion point
    ForkThread(Part2SymbMoveRecheckThread, unit)
end

function Part2SymbMoveRecheckThread(unit)
    -- While the travelling symb unit is alive, check its location every 35 seconds.
    -- This is to cover situations where the units may get blocked and stop.
    while not unit:IsDead() do
        IssueStop({unit})
        IssueMove({unit}, ScenarioUtils.MarkerToPosition('M2SymbMovePoint3'))
        WaitSeconds(35)
    end
end

function Part2SymbiontOffmapCleanup(triggeringEntity)
    -- Destroy the Symbiont once they are offmap
    triggeringEntity:Destroy()
end

function Part2FinishCounter()
    ScenarioInfo.Part2ElementsCompleted = ScenarioInfo.Part2ElementsCompleted + 1
    if ScenarioInfo.Part2ElementsCompleted == 2 then
        -- End Part 2 / M2
        ScenarioFramework.CreateTimerTrigger(BeginPart3, 3)-- slight pause between obj's
    end
end

-- ------------
-- Part 3
-- ------------

function BeginPart3()
	for _, player in ScenarioInfo.HumanPlayers do
		SetArmyUnitCap(player, 500)
	end
    SetArmyUnitCap(2, 500)
    SetArmyUnitCap(3, 500)
    ScenarioInfo.MissionNumber = 7

    -- Pause slightly before we assign obj's and do dialogue etc.
    ScenarioFramework.CreateTimerTrigger(Part3OpeningObjs, 2)

    -- Spawn bases and their units
    Part3SpawnEasternUnits()

    -- PlayableArea_5
    ScenarioFramework.SetPlayableArea(ScenarioUtils.AreaToRect('PlayableArea_5'))

    -- Create a timer that will play a mention of the offmap Aeon
    ScenarioFramework.CreateTimerTrigger(OffmapAeonDialogueTimed, 120)

    -- Start some small Aeon air attacks to the east, for show, and a larger attack a bit later
    Part3_OffmapAeonAir()
    ScenarioFramework.CreateTimerTrigger(Part3_DelayedInitialAirFight, 8)
end

function Part3OpeningObjs()
    -- ScenarioFramework.Dialogue(OpStrings.M3MissionStartDialogue)
    ScenarioInfo.M7P1 = Objectives.Basic(   -- Patrols, AA towers
        'primary',
        'incomplete',
        OpStrings.M7P1Text,
        OpStrings.M7P1Detail,
        Objectives.GetActionIcon('kill'),
        {
            MarkUnits = true,
            Units = ScenarioInfo.Part3_DefenseObjUnits,
        }
   )
    ScenarioInfo.M7P2 = Objectives.Basic(   -- Base
        'primary',
        'incomplete',
        OpStrings.M7P2Text,
        OpStrings.M7P2Detail,
        Objectives.GetActionIcon('kill'),
        {
            MarkUnits = true,
            Units = ScenarioInfo.Part3_BaseObjUnits
        }
   )
    ScenarioFramework.Dialogue(OpStrings.C01_M06_040)
    -- Transports and Heavy Assault Bots
    BuildCategories7()
    ScenarioFramework.CreateTimerTrigger(M7P1Reminder1 ,ReminderInitialTime2)
end

function Part3SpawnEasternUnits()
    -- Spawn the Eastern small base
    ScenarioUtils.CreateArmyGroup('UEF', 'UEFM3EastBaseStruct_'..DifficultyConc)
    ScenarioUtils.CreateArmyGroup('UEF', 'UEFM3EastBaseWalls')

    -- Spawn the Eastern small base Factory and Power gens
    ScenarioInfo.M3UEFEastFactory = ScenarioUtils.CreateArmyGroup('UEF', 'UEFM3EastBaseFact')
    ScenarioInfo.M3UEFEastPower = ScenarioUtils.CreateArmyGroup('UEF', 'UEFM3EastBasePower')
    ScenarioFramework.CreateGroupDeathTrigger(Part3EastBaseKilledCounter, ScenarioInfo.M3UEFEastFactory)
    ScenarioFramework.CreateGroupDeathTrigger(Part3EastBaseKilledCounter, ScenarioInfo.M3UEFEastPower)
    ScenarioInfo.Part3_BaseObjUnits = {}
    AddGroupToTable(ScenarioInfo.Part3_BaseObjUnits, ScenarioInfo.M3UEFEastFactory)
    AddGroupToTable(ScenarioInfo.Part3_BaseObjUnits, ScenarioInfo.M3UEFEastPower)

    -- Spawn the Groups of UEF AA, and their death triggers for the Objective
    ScenarioInfo.M3UEFEastAA1 = ScenarioUtils.CreateArmyGroup('UEF', 'UEFM3EastAA1')
    ScenarioInfo.M3UEFEastAA2 = ScenarioUtils.CreateArmyGroup('UEF', 'UEFM3EastAA2')
    ScenarioInfo.M3UEFEastAA3 = ScenarioUtils.CreateArmyGroup('UEF', 'UEFM3EastAA3')
    ScenarioFramework.CreateGroupDeathTrigger(Part3UEFEastAACounter, ScenarioInfo.M3UEFEastAA1)
    ScenarioFramework.CreateGroupDeathTrigger(Part3UEFEastAACounter, ScenarioInfo.M3UEFEastAA2)
    ScenarioFramework.CreateGroupDeathTrigger(Part3UEFEastAACounter, ScenarioInfo.M3UEFEastAA3)
    ScenarioUtils.CreateArmyGroup('UEF', 'UEFM3EastAAWalls') -- Walls around the aa groups.
    ScenarioInfo.Part3_DefenseObjUnits = {}
    AddGroupToTable(ScenarioInfo.Part3_BaseObjUnits, ScenarioInfo.M3UEFEastAA1)
    AddGroupToTable(ScenarioInfo.Part3_BaseObjUnits, ScenarioInfo.M3UEFEastAA2)
    AddGroupToTable(ScenarioInfo.Part3_BaseObjUnits, ScenarioInfo.M3UEFEastAA3)

    -- Spawn the Symbiont buildings and sundry structures.
    local symbiontBuildings = ScenarioUtils.CreateArmyGroup('Symbiont', 'M3SymbiontBuildings')
    ScenarioUtils.CreateArmyGroup('Symbiont', 'M3SymbiontStructures')
    for k,v in symbiontBuildings do
        v:SetReclaimable(false)
        v:SetCanBeKilled(false)
        v:SetCanTakeDamage(false)
    end

    local symbtiontBuilding1 = ScenarioInfo.UnitNames[Symbiont]['SymbBuilding1']
    local symbtiontBuilding2 = ScenarioInfo.UnitNames[Symbiont]['SymbBuilding2']
    symbtiontBuilding1:SetCustomName(LOC '{i BLD_Symb_R1Name}')
    symbtiontBuilding2:SetCustomName(LOC '{i BLD_Symb_R1Name}')

    -- Spawn Heavy UEF Symbiont defenders
    ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M3UEFEastDefender1'..DifficultyConc, 'AttackFormation')
    ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M3UEFEastDefender2'..DifficultyConc, 'AttackFormation')

    -- Spawn the UEF patrolers, send them on a simple patrol
    ScenarioInfo.UEFEastPatrol1 = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M3UEFEastUnits1'..DifficultyConc, 'AttackFormation')
    ScenarioInfo.UEFEastPatrol1:Patrol(ScenarioUtils.MarkerToPosition('M3East1Patrol1'))
    ScenarioInfo.UEFEastPatrol1:Patrol(ScenarioUtils.MarkerToPosition('M3East1Patrol2'))
    ScenarioInfo.UEFEastPatrol1:Patrol(ScenarioUtils.MarkerToPosition('M3East1Patrol3'))
    ScenarioInfo.UEFEastPatrol1:Patrol(ScenarioUtils.MarkerToPosition('M3East1Patrol2'))

    ScenarioInfo.UEFEastPatrol2 = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M3UEFEastUnits2'..DifficultyConc, 'AttackFormation')
    ScenarioInfo.UEFEastPatrol2:Patrol(ScenarioUtils.MarkerToPosition('M3East2Patrol1'))
    ScenarioInfo.UEFEastPatrol2:Patrol(ScenarioUtils.MarkerToPosition('M3East2Patrol2'))
    ScenarioInfo.UEFEastPatrol2:Patrol(ScenarioUtils.MarkerToPosition('M3East2Patrol3'))
    ScenarioInfo.UEFEastPatrol2:Patrol(ScenarioUtils.MarkerToPosition('M3East2Patrol2'))

    ScenarioInfo.UEFEastPatrol3 = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M3UEFEastUnits3'..DifficultyConc, 'AttackFormation')
    ScenarioInfo.UEFEastPatrol3:Patrol(ScenarioUtils.MarkerToPosition('M3East3Patrol1'))
    ScenarioInfo.UEFEastPatrol3:Patrol(ScenarioUtils.MarkerToPosition('M3East3Patrol2'))
    ScenarioInfo.UEFEastPatrol3:Patrol(ScenarioUtils.MarkerToPosition('M3East3Patrol3'))
    ScenarioInfo.UEFEastPatrol3:Patrol(ScenarioUtils.MarkerToPosition('M3East3Patrol2'))

    -- If we are in Hard difficulty, create an air patrol for the eastern UEF area.
    if ScenarioInfo.Difficulty == 3 then
        local eastAirStrong = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'UEFM3EastPatrolStrong', 'AttackChevron')
        for i = 1, 5 do
            eastAirStrong:Patrol(ScenarioUtils.MarkerToPosition('M3UEFEastAirPatrol'..i))
        end
    end

    -- Fork the threads that check to see if any enemy units are alive in the eastern area, and also the final thread that checks to see if
    -- this, and the Destroy UEF Base objectives, are done.
    ForkThread(Part3EastDefenseCheckThread)
    ForkThread(Part3EasternObjectiveCheckThread)

    -- Spawn Symbiont wreckage
    ScenarioUtils.CreateArmyGroup('Symbiont', 'Part3_Symb_Wreckage', true)
end

function Part3_DelayedInitialAirFight()
    local aeonAir1 = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M2_AeonAir_Group1', 'ChevronFormation')
    local aeonAir2 = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M2_AeonAir_Group1', 'ChevronFormation')
    local uefAir = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M2_UEFAir_Group2', 'ChevronFormation')
    ScenarioFramework.PlatoonPatrolChain(aeonAir1, 'M2_AirGroupPatrol_Chain')
    ScenarioFramework.PlatoonPatrolChain(aeonAir2, 'M2_AirGroupPatrol_Chain')
    ScenarioFramework.PlatoonPatrolChain(uefAir, 'M2_AirGroupPatrol_Chain')
end

function Part3_AeonUEFAirFight()
    -- If there are still some of the AA towers left, spawn in the offmap aeon/uef
    if Part3EasternAAGroupsDestroyed < 3 and ScenarioInfo.MissionNumber == 7 then
        -- choose from one of two setups
        local rnd = Random(1,2)
        if rnd == 1 then
            local aeonAirGroup = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M2_AeonAir_Group1', 'ChevronFormation')
            local uefAirGroup = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M2_UEFAir_Group2', 'ChevronFormation')
            ScenarioFramework.PlatoonPatrolChain(aeonAirGroup, 'M2_AirGroupPatrol_Chain')
            ScenarioFramework.PlatoonPatrolChain(uefAirGroup, 'M2_AirGroupPatrol_Chain')
        elseif rnd == 2 then
            local aeonAirGroup = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M2_AeonAir_Group2', 'ChevronFormation')
            local uefAirGroup = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M2_UEFAir_Group1', 'ChevronFormation')
            ScenarioFramework.PlatoonPatrolChain(aeonAirGroup, 'M2_AirGroupPatrol_Chain')
            ScenarioFramework.PlatoonPatrolChain(uefAirGroup, 'M2_AirGroupPatrol_Chain')
        end

    end
end

function Part3_OffmapAeonAir()
    -- While no aa groups to the east have been destroyed, send in 1 of 3 air groups, and send them on a patrol.
    -- Loop via death trigger.

    if ScenarioInfo.MissionNumber == 7 and Part3EasternAAGroupsDestroyed == 0 then
        local rnd = Random(1, 3)
        local aeonPatrol = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M2_AeonAir_Offmap'..rnd, 'ChevronFormation')
        ScenarioFramework.CreatePlatoonDeathTrigger(Part3_OffmapAeonAirPause, aeonPatrol)
        ScenarioFramework.PlatoonPatrolChain(aeonPatrol, 'M2_Aeon_OffmapAir_Chain'..rnd)
    end
end

function Part3_OffmapAeonAirPause()
    local time = Random(25, 70)
    ScenarioFramework.CreateTimerTrigger(Part3_OffmapAeonAir, time)
end

function OffmapAeonDialogueTimed()
    ScenarioFramework.Dialogue(OpStrings.C01_M07_070) -- Mentions Aeon offmap to the south
end

function Part3EastBaseKilledCounter()
    Part3EastBaseCounter = Part3EastBaseCounter +1
    if Part3EastBaseCounter == 1 then
        ScenarioFramework.Dialogue(OpStrings.C01_M07_080) -- Mentions Aeon offmap to the south
        Part3_AeonUEFAirFight()
    end
    if Part3EastBaseCounter == 2 then
        ScenarioInfo.M7P2:ManualResult(true) -- Destroy Eastern UEF Base - completed.
        ScenarioInfo.M7P2Complete = true
        -- If we havent already played a "you've done A, now go do B" prompt, then do so.
        if not ScenarioInfo.M3SymbiontObjPromptDone then
            ScenarioInfo.M3SymbiontObjPromptDone = true
            ScenarioFramework.Dialogue(OpStrings.C01_M07_060) -- play the "Good work on the base. Now go tool the defenders" dialogue prompt
        end
        -- Tell the Main objectives check thread that this Obj is done.
        Part3EastBaseDone = true
    end
end

function Part3UEFEastAACounter()
    -- Increments counter for the Part3EastDefenseCheckThread below to track. These need to be tracked separately from the area
    -- check, as there are AA towers in the UEF base that *arent* objective related.
    Part3EasternAAGroupsDestroyed = Part3EasternAAGroupsDestroyed + 1
    if Part3EasternAAGroupsDestroyed == 2 then
        ScenarioFramework.Dialogue(OpStrings.C01_M07_090) -- Mentions Aeon offmap to the south
        ScenarioFramework.CreateTimerTrigger(Part3_AeonUEFAirFight, 10) -- offmap attack soon after second aa is down
    end
end

function Part3EastDefenseCheckThread()
    -- Paranoia: ensure the just-created units are in.
    WaitSeconds(3)

    -- While the "Destroy the Defenders" obj (PObj1) is not complete, keep checking if
    -- there are any UEF mobile units in the area, and if all 3 AA encampments have been
    -- destroyed. When both these conditions are met, flag the objective as done, etc.
    while not Part3EastDefDone do
        if ScenarioFramework.NumCatUnitsInArea(categories.MOBILE * categories.LAND + categories.BOMBER, ScenarioUtils.AreaToRect('M3EasternArea'), ArmyBrains[UEF]) == 0 and Part3EasternAAGroupsDestroyed == 3 then
            Part3EastDefDone = true
            ScenarioInfo.M7P1:ManualResult(true) -- Destroy Remaining Defenders, AA - completed.
            ScenarioInfo.M7P1Complete = true
            -- If we havent already played a "youve done a, now go do b" prompt, then do so.
            if not ScenarioInfo.M3SymbiontObjPromptDone then
                ScenarioInfo.M3SymbiontObjPromptDone = true
                ScenarioFramework.Dialogue(OpStrings.C01_M07_050) -- play the "Good work on the defenders. Now go tool the UEF base" dialogue prompt
            end
        end
        WaitSeconds(3)
    end
end

function Part3CleanUpSymbs(triggeringEntity)
    -- Track how many fleeing symbs have been Destroyed()
    Part3SymbCleanupCount = Part3SymbCleanupCount + 1
    -- Destroy the Symb
    triggeringEntity:Destroy()
    -- When 6 have been destroyed, get rid of the triggers.
    if Part3SymbCleanupCount == 6 then
        ScenarioInfo.M3SymbCleanupTrigger1:Destroy()
        ScenarioInfo.M3SymbCleanupTrigger2:Destroy()
    end
end

function Part3EasternObjectiveCheckThread()
    -- Wait for both the UEF Base objective, and the UEF Defenders objective, to be completed.
    while Part3EastDefDone == false or Part3EastBaseDone == false do
        WaitSeconds(1)
    end
    ScenarioFramework.Dialogue(OpStrings.C01_M07_100)

    -- Spawn the symbionts, fork a thread that introduces a pause
    ForkThread(Part3SpawnSymbiontsThread)
    ScenarioFramework.CreateTimerTrigger(BeginPart4, 10)-- slight pause before we advance
end

function Part3SpawnSymbiontsThread()
    -- Create cleanup trigger, Spawn south Symbionts, send them offmap
    ScenarioInfo.M3SymbCleanupTrigger1 = ScenarioFramework.CreateAreaTrigger(Part3CleanUpSymbs,  ScenarioUtils.AreaToRect('M3SymbFleeArea1'), categories.ALLUNITS, false, false, ArmyBrains[Symbiont])
    local symb1 = ScenarioUtils.CreateArmyUnit('Symbiont', 'M3Symbiont1')
    local symb2 = ScenarioUtils.CreateArmyUnit('Symbiont', 'M3Symbiont2')
    local symb3 = ScenarioUtils.CreateArmyUnit('Symbiont', 'M3Symbiont3')
    IssueMove({symb1}, ScenarioUtils.MarkerToPosition('M3SymbFleePoint1'))
    IssueMove({symb2}, ScenarioUtils.MarkerToPosition('M3SymbFleePoint2'))
    IssueMove({symb3}, ScenarioUtils.MarkerToPosition('M3SymbFleePoint3'))

    WaitSeconds(.65) -- Slight pause for looks

    -- Create cleanup trigger, spawn north Symbionts send them offmap
    ScenarioInfo.M3SymbCleanupTrigger2 = ScenarioFramework.CreateAreaTrigger(Part3CleanUpSymbs,  ScenarioUtils.AreaToRect('M3SymbFleeArea2'), categories.ALLUNITS, false, false, ArmyBrains[Symbiont])
    local symb4 = ScenarioUtils.CreateArmyUnit('Symbiont', 'M3Symbiont4')
    local symb5 = ScenarioUtils.CreateArmyUnit('Symbiont', 'M3Symbiont5')
    local symb6 = ScenarioUtils.CreateArmyUnit('Symbiont', 'M3Symbiont6')
    IssueMove({symb4}, ScenarioUtils.MarkerToPosition('M3SymbFleePoint4'))
    IssueMove({symb5}, ScenarioUtils.MarkerToPosition('M3SymbFleePoint5'))
    IssueMove({symb6}, ScenarioUtils.MarkerToPosition('M3SymbFleePoint6'))

-- Symbiont truck cam
    local camInfo = {
        blendTime = 1.0,
        holdTime = 4,
        orientationOffset = { -1.5, 0.2, 0 },
        positionOffset = { 0, 1, 0 },
        zoomVal = 35,
        markerCam = true,
    }
    ScenarioFramework.OperationNISCamera(ScenarioUtils.MarkerToPosition("NIS_Symbionts_Spawn"), camInfo)
end

-- ------------
-- Part 4
-- ------------

function BeginPart4()
    ScenarioInfo.MissionNumber = 8
    BuildCategoriesFinal()

    -- Set Dostya back to ally in preperation for getting units
    for _, player in ScenarioInfo.HumanPlayers do
        SetAlliance(player, Dostya, 'Ally')
    end
    for _, player in ScenarioInfo.HumanPlayers do
        SetAlliance(Dostya, player, 'Ally')
    end

    -- Create patrolers for the Aeon base, and CDR Objective
    Part4SpawnAeonUnits()
    Part4DostyaTransfer()
    ScenarioUtils.CreateArmyGroup('Wreckage_Holding' ,'Part3_Aeon_Wreckage', true)
    ScenarioUtils.CreateArmyGroup('Wreckage_Holding' ,'Part3_UEF_Wreckage', true)

    -- Objs
    ScenarioFramework.Dialogue(OpStrings.C01_M08_010)

    -- Grow playable area to reveal Aeon
    ScenarioFramework.SetPlayableArea(ScenarioUtils.AreaToRect('PlayableArea_6'))

    -- Timer which will set var that taunts check against, so we dont play too many too early/fast.
    ScenarioFramework.CreateTimerTrigger(Part4_AllowAeonTaunts, 60)

    -- When the Aeon first spots the player, taunt. At 10, 30 , 60 Aeon units destroyed, taunts
    ScenarioFramework.CreateArmyIntelTrigger(AeonSpotsPlayer, ArmyBrains[Aeon], 'LOSNow', false, true, categories.ALLUNITS, true, ArmyBrains[Player])
    ScenarioFramework.CreateArmyStatTrigger(AeonTauntTenUnits, ArmyBrains[Player], 'Killed10AeonUnits',
        {{ StatType = 'Enemies_Killed', CompareType = 'GreaterThanOrEqual', Value = 16, Category = categories.AEON, },})

    ScenarioFramework.CreateArmyStatTrigger(AeonTauntThirtyUnits, ArmyBrains[Player], 'Killed30AeonUnits',
        {{ StatType = 'Enemies_Killed', CompareType = 'GreaterThanOrEqual', Value = 30, Category = categories.AEON, },})

    ScenarioFramework.CreateArmyStatTrigger(AeonTauntSixtyUnits, ArmyBrains[Player], 'Killed60AeonUnits',
        {{ StatType = 'Enemies_Killed', CompareType = 'GreaterThanOrEqual', Value = 60, Category = categories.AEON, },})
end

function Part4SpawnAeonUnits()
    -- Spawn the Aeon groups in.
    ScenarioUtils.CreateArmyGroup('Aeon', 'M3AeonBaseDefense_'..DifficultyConc)
    ScenarioUtils.CreateArmyGroup('Aeon', 'M3AeonBaseProductionSundry')
    ScenarioInfo.AeonFactories = ScenarioUtils.CreateArmyGroup('Aeon', 'M3AeonBaseProductionFactories')

    ScenarioInfo.M3AeonBaseGenerators = ScenarioUtils.CreateArmyGroup('Aeon', 'M3AeonBaseProductionGenerators')
    ScenarioInfo.M3AeonBaseMass = ScenarioUtils.CreateArmyGroup('Aeon', 'M3AeonBaseProductionMass')

    -- Spawn in starting groups of engineers, one for each factory. Assign them to guard (ie, assist) each
    -- factory. Spawn them as a platoon so the PBM or engineer assist load balance doesnt grab
    -- them. Do an extra group in hard difficulty.
    ScenarioInfo.AeonStartingEngineerPlatoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M3AeonBaseStartEngineers1', 'AttackFormation')
    ScenarioInfo.AeonStartingEngineers = ScenarioInfo.AeonStartingEngineerPlatoon:GetPlatoonUnits()
    for i = 1, 5 do
        IssueGuard({ScenarioInfo.AeonStartingEngineers[i]}, ScenarioInfo.AeonFactories[i])
    end
    if ScenarioInfo.Difficulty == 3 then
        ScenarioInfo.AeonStartingEngineerPlatoon2 = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M3AeonBaseStartEngineers2', 'AttackFormation')
        ScenarioInfo.AeonStartingEngineers2 = ScenarioInfo.AeonStartingEngineerPlatoon2:GetPlatoonUnits()
        for i = 1, 5 do
            IssueGuard({ScenarioInfo.AeonStartingEngineers2[i]}, ScenarioInfo.AeonFactories[i])
        end
    end

    -- Aeon commander, death/reclaim trigger for win, make Aeon CDR uncapturable, give a patrol. Objective
    ScenarioInfo.AeonCommander = ScenarioUtils.CreateArmyUnit('Aeon', 'M3AeonCDR')
    ScenarioFramework.PauseUnitDeath(ScenarioInfo.AeonCommander)
    ScenarioInfo.AeonCommander:SetCustomName(LOC '{i CDR_Min}')
    ScenarioInfo.AeonCommander:SetCapturable(false)
    IssuePatrol({ScenarioInfo.AeonCommander}, ScenarioUtils.MarkerToPosition('AeonCommander_Patrol_1'))
    IssuePatrol({ScenarioInfo.AeonCommander}, ScenarioUtils.MarkerToPosition('AeonCommander_Patrol_2'))
    IssuePatrol({ScenarioInfo.AeonCommander}, ScenarioUtils.MarkerToPosition('AeonCommander_Patrol_3'))

    -- Overcharge manager
    local cdrPlatoon = ArmyBrains[Aeon]:MakePlatoon(' ', ' ')
    ArmyBrains[Aeon]:AssignUnitsToPlatoon(cdrPlatoon, {ScenarioInfo.AeonCommander}, 'Attack', 'AttackFormation')
    cdrPlatoon.CDRData = {}
    cdrPlatoon.CDRData.LeashPosition = 'AeonCommander_Patrol_1'
    cdrPlatoon.CDRData.LeashRadius = 30
    import('/lua/ai/opai/opbehaviors.lua').CDROverchargeBehavior(cdrPlatoon)
    ArmyBrains[Aeon]:DisbandPlatoon(cdrPlatoon)

    ScenarioInfo.M8P1 = Objectives.KillOrCapture(
        'primary',                      -- type
        'incomplete',                   -- complete
        OpStrings.M8P1Text,             -- title
        OpStrings.M8P1Detail,           -- description
        {                               -- target
            Units = {ScenarioInfo.AeonCommander},
        }
   )
    ScenarioInfo.M8P1:AddResultCallback(
        function()
            Part4AeonCommanderDeath()
            ScenarioInfo.M8P1Complete = true
        end
   )
    ScenarioFramework.CreateTimerTrigger(M8P1Reminder1, ReminderSubsequentTime1)

    -- Defenders and patrols for the Aeon base
    ScenarioInfo.M3AeonBaseDef1 = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon' ,'M3PlacedDefenders1_'..DifficultyConc ,'AttackFormation')
    ScenarioInfo.M3AeonBaseDef2 = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon' ,'M3PlacedDefenders2_'..DifficultyConc ,'AttackFormation')
    ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon' ,'M3PlacedDefendersBackAA','AttackFormation')
    ScenarioInfo.M3AeonBaseDef1:Patrol(ScenarioUtils.MarkerToPosition('M3AeonBasePatrolFront1'))
    ScenarioInfo.M3AeonBaseDef1:Patrol(ScenarioUtils.MarkerToPosition('M3AeonBasePatrolFront2'))
    ScenarioInfo.M3AeonBaseDef1:Patrol(ScenarioUtils.MarkerToPosition('M3AeonBasePatrolFront3'))
    ScenarioInfo.M3AeonBaseDef2:Patrol(ScenarioUtils.MarkerToPosition('M3AeonBasePatrolBack1'))
    ScenarioInfo.M3AeonBaseDef2:Patrol(ScenarioUtils.MarkerToPosition('M3AeonBasePatrolBack2'))

    -- Check how many air units the player has, then start spwaning the Aeon air defenders based on difficulty, and player air count.
    ScenarioInfo.M3PlayerAirCount = ArmyBrains[Player]:GetCurrentUnits(categories.AIR)
    -- On easy, no defenders present unless the player has a sizable force of air
    if ScenarioInfo.Difficulty == 2 then
        ScenarioInfo.M3AeonAirDef1 = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon' ,'M3PlacedDefendersAirMedium' ,'AttackChevron')
        ScenarioInfo.M3AeonAirDef1:ForkAIThread(Part4AeonBaseAirPatrolThread)
    end
    if ScenarioInfo.Difficulty == 3 then
        -- Extra AA towers in hard difficulty
        ScenarioInfo.M3AeonAirDef1 = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon' ,'M3PlacedDefendersAirStrong' ,'AttackChevron')
        ScenarioInfo.M3AeonAirDef1:ForkAIThread(Part4AeonBaseAirPatrolThread)
    end
    if ScenarioInfo.M3PlayerAirCount > 10 then
        ScenarioInfo.M3AeonAirDef2 = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon' ,'M3PlacedDefendersAirAdd1' ,'AttackChevron')
        ScenarioInfo.M3AeonAirDef2:ForkAIThread(Part4AeonBaseAirPatrolThread)
    end
    if ScenarioInfo.M3PlayerAirCount > 20 then
        ScenarioInfo.M3AeonAirDef3 = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon' ,'M3PlacedDefendersAirAdd2' ,'AttackChevron')
        ScenarioInfo.M3AeonAirDef3:ForkAIThread(Part4AeonBaseAirPatrolThread)
    end
    -- Send some attacks in from offmap UEF, against the Aeon base
    Part4_UEFAttackAeon()
end

function Part4AeonBaseAirPatrolThread(platoon)
    platoon:Patrol(ScenarioUtils.MarkerToPosition('M3AeonBaseAirPatrol1'))
    platoon:Patrol(ScenarioUtils.MarkerToPosition('M3AeonBaseAirPatrol2'))
    platoon:Patrol(ScenarioUtils.MarkerToPosition('M3AeonBaseAirPatrol3'))
end

function Part4_UEFAttackAeon()
    Part4UEFWaveCount = Part4UEFWaveCount + 1
    if Part4UEFWaveCount < 7 then
        ScenarioInfo.UEFAttackAeonPlatoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'UEFM3_AeonAttacks', 'ChevronFormation')
        ScenarioInfo.UEFAttackAeonPlatoon:MoveToLocation(ScenarioUtils.MarkerToPosition('M3_UEF_AttackAeon_Point_1'), false)
        ScenarioInfo.UEFAttackAeonPlatoon:Patrol(ScenarioUtils.MarkerToPosition('M3_UEF_AttackAeon_Point_2'))
        ScenarioFramework.CreatePlatoonDeathTrigger(Part4_UEFAttackAeonPause, ScenarioInfo.UEFAttackAeonPlatoon)
    end
end

function Part4_UEFAttackAeonPause()
    ForkThread(Part4_UEFAttackAeonPauseThread)
end

function Part4_UEFAttackAeonPauseThread()
    WaitSeconds(9)
    Part4_UEFAttackAeon()
end

-- - Dostya Unit Trasfer functions

function Part4DostyaTransfer()
    -- Spawn in each transport+ground platoon.
    ScenarioInfo.M2TransferGroupAA      = ScenarioUtils.SpawnPlatoon('Dostya', 'M2TransferGroupAA')
    ScenarioInfo.M2TransferGroupMissile = ScenarioUtils.SpawnPlatoon('Dostya', 'M2TransferGroupMissile')
    ScenarioInfo.M2TransferGroupTank    = ScenarioUtils.SpawnPlatoon('Dostya', 'M2TransferGroupTank')

    -- Set the transport (support squad) units to no be killable. Make triggers for each, to disable vis when they get offmap
    ScenarioInfo.TranportOne = ScenarioInfo.M2TransferGroupAA:GetSquadUnits('Support')[1]
    ScenarioInfo.TranportTwo = ScenarioInfo.M2TransferGroupMissile:GetSquadUnits('Support')[1]
    ScenarioInfo.TranportThree = ScenarioInfo.M2TransferGroupTank:GetSquadUnits('Support')[1]

    Part4DostyaTransportFlags(ScenarioInfo.TranportOne)
    Part4DostyaTransportFlags(ScenarioInfo.TranportTwo)
    Part4DostyaTransportFlags(ScenarioInfo.TranportThree)

    ScenarioFramework.CreateUnitToMarkerDistanceTrigger(Part4_Trans1VisOff, ScenarioInfo.TranportOne, ScenarioUtils.MarkerToPosition('M2DostyaTransportReturn'), 5)
    ScenarioFramework.CreateUnitToMarkerDistanceTrigger(Part4_Trans2VisOff, ScenarioInfo.TranportTwo, ScenarioUtils.MarkerToPosition('M2DostyaTransportReturn'), 5)
    ScenarioFramework.CreateUnitToMarkerDistanceTrigger(Part4_Trans3VisOff, ScenarioInfo.TranportThree, ScenarioUtils.MarkerToPosition('M2DostyaTransportReturn'), 5)

    -- Getting handles to the move and load commands, move the platoons out to the player's base area, and unload.
    -- Transports return, and destroy offmap.
    ScenarioFramework.AttachUnitsToTransports(ScenarioInfo.M2TransferGroupAA:GetSquadUnits('attack'), ScenarioInfo.M2TransferGroupAA:GetSquadUnits('support'))
    ScenarioInfo.M2TransferAAUnload     =   ScenarioInfo.M2TransferGroupAA:UnloadAllAtLocation(ScenarioUtils.MarkerToPosition('M2DostyaTransport1'))
    ScenarioInfo.M2TransferGroupAA:MoveToLocation(ScenarioUtils.MarkerToPosition('M2DostyaTransportReturn'), false, 'Support')
    ScenarioInfo.M2TransferGroupAA:Destroy('Support')

    ScenarioFramework.AttachUnitsToTransports(ScenarioInfo.M2TransferGroupMissile:GetSquadUnits('attack'), ScenarioInfo.M2TransferGroupMissile:GetSquadUnits('support'))
    ScenarioInfo.M2TransferMissileUnload =  ScenarioInfo.M2TransferGroupMissile:UnloadAllAtLocation(ScenarioUtils.MarkerToPosition('M2DostyaTransport2'))
    ScenarioInfo.M2TransferGroupMissile:MoveToLocation(ScenarioUtils.MarkerToPosition('M2DostyaTransportReturn'), false, 'Support')
    ScenarioInfo.M2TransferGroupMissile:Destroy('Support')

    ScenarioFramework.AttachUnitsToTransports(ScenarioInfo.M2TransferGroupTank:GetSquadUnits('attack'), ScenarioInfo.M2TransferGroupTank:GetSquadUnits('support'))
    ScenarioInfo.M2TransferTankUnload   =   ScenarioInfo.M2TransferGroupTank:UnloadAllAtLocation(ScenarioUtils.MarkerToPosition('M2DostyaTransport3'))
    ScenarioInfo.M2TransferGroupTank:MoveToLocation(ScenarioUtils.MarkerToPosition('M2DostyaTransportReturn'), false, 'Support')
    ScenarioInfo.M2TransferGroupTank:Destroy('Support')

    -- Fork threads for each platoon, that tracks when the platoons have unloaded, and swaps the units to the player.
    ForkThread(Part4SwapTransferThread, ScenarioInfo.M2TransferGroupAA, ScenarioInfo.M2TransferAAUnload)
    ForkThread(Part4SwapTransferThread, ScenarioInfo.M2TransferGroupMissile, ScenarioInfo.M2TransferMissileUnload)
    ForkThread(Part4SwapTransferThread, ScenarioInfo.M2TransferGroupTank, ScenarioInfo.M2TransferTankUnload)

    -- Fork thread to delay in spawn of defense platoon.
    ForkThread(Part4TransDefenseSpawnThread)
end

function Part4SwapTransferThread(platoon, unloadCommand)
    -- When the load up and unload at destination commands are both done
    while platoon:IsCommandsActive(unloadCommand) == true do
        WaitSeconds(1)
    end
    M2TransportsUnloaded = M2TransportsUnloaded + 1
    -- Swap each member of the platoon's Attack squad to the player.
    for k, v in platoon:GetSquadUnits('Attack') do
        ScenarioFramework.GiveUnitToArmy(v, Player)
    end
end

function Part4DostyaTransportFlags(unit)
    unit:SetReclaimable(false)
    unit:SetCapturable(false)
    unit:SetCanBeKilled(false)
    unit:SetCanTakeDamage(false)
end

function Part4TransDefenseSpawnThread()
    -- Spawn Air, fork thread to check when they need to move off map, send them on a patrol
    ScenarioInfo.M2TransferDefense = ScenarioUtils.SpawnPlatoon('Dostya', 'M2TransferDefensePlatoon')
    for k,v in ScenarioInfo.M2TransferDefense:GetPlatoonUnits() do
        Part4DostyaTransportFlags(v)
    end
    ForkThread(Part4TransDefenseCheckThread)
    ScenarioInfo.M2TransferDefense:Patrol(ScenarioUtils.MarkerToPosition('M2TransDefPatrol1'))
    ScenarioInfo.M2TransferDefense:Patrol(ScenarioUtils.MarkerToPosition('M2TransDefPatrol2'))
    ScenarioInfo.M2TransferDefense:Patrol(ScenarioUtils.MarkerToPosition('M2TransDefPatrol3'))

    -- Just in case something happened to a transport (if it got stuck or destroyed for some reason),
    -- force the defense platoon offmap anyway after a 1.5 minute wait (it should take way less that 1.5
    -- mins to drop off the transfer units). We dont wan't them hanging about.
    ScenarioFramework.CreateTimerTrigger(Part4TransDefMoveOffmap, 90)
end

function Part4TransDefenseCheckThread()
    -- When all 3 transports are done unloading, do function to move them off map.
    while M2TransportsUnloaded < 3 do
        WaitSeconds(1)
    end
    Part4TransDefMoveOffmap()
end

function Part4TransDefMoveOffmap()
    -- Move the transport air defenders offmap, after we check we haven't already done so.
    if M2TransDefDone == false then
        M2TransDefDone = true
        if ArmyBrains[Dostya]:PlatoonExists(ScenarioInfo.M2TransferDefense) then
            ScenarioInfo.M2TransferDefense:MoveToLocation(ScenarioUtils.MarkerToPosition('M2DostyaTransportReturn'), false)
            ScenarioInfo.M2TransferDefense:Destroy()
            ForkThread(Part4RemoveDostyaAirIntel)
        end
    end
end

function Part4RemoveDostyaAirIntel()
    -- Once the Air Sups have had enough to to get near the edge of the map, set their intel radius
    -- to zero, so we dont see their shared intel patch seeping into the map as they hang at
    -- their destroy point that is just offmap.
    WaitSeconds(4)
    if ArmyBrains[Dostya]:PlatoonExists(ScenarioInfo.M2TransferDefense) then
        for k,v in ScenarioInfo.M2TransferDefense:GetPlatoonUnits() do
            v:SetIntelRadius('Vision', 0)
        end
    end
end

function Part4_Trans1VisOff()
    ScenarioInfo.TranportOne:SetIntelRadius('Vision', 0)
end

function Part4_Trans2VisOff()
    ScenarioInfo.TranportTwo:SetIntelRadius('Vision', 0)
end

function Part4_Trans3VisOff()
    ScenarioInfo.TranportThree:SetIntelRadius('Vision', 0)
end

function Part4_AllowAeonTaunts()
    ScenarioInfo.TooEarlyForAeonTaunts = false
end

function AeonSpotsPlayer()
    if not ScenarioInfo.AeonCommanderKilled and not ScenarioInfo.TooEarlyForAeonTaunts then
        ScenarioFramework.Dialogue(OpStrings.TAUNT2)
    end
end

function AeonTauntTenUnits()
    if not ScenarioInfo.AeonCommanderKilled and not ScenarioInfo.TooEarlyForAeonTaunts then
        ScenarioFramework.Dialogue(OpStrings.TAUNT6)
    end
end

function AeonTauntThirtyUnits()
    if not ScenarioInfo.AeonCommanderKilled and not ScenarioInfo.TooEarlyForAeonTaunts then
        ScenarioFramework.Dialogue(OpStrings.TAUNT8)
    end
end

function AeonTauntSixtyUnits()
    if not ScenarioInfo.AeonCommanderKilled then
        ScenarioFramework.Dialogue(OpStrings.TAUNT3)
    end
end

function Part4AeonCommanderDeath()
    if not ScenarioInfo.OperationEnding then
        ScenarioInfo.OperationEnding = true
        -- Aeon Commander killed, op success.
        ScenarioFramework.KillBaseInArea(ArmyBrains[Aeon], 'AeonBaseArea')
        ScenarioInfo.AeonCommanderKilled = true
        ScenarioFramework.EndOperationSafety()
--    ScenarioFramework.EndOperationCamera(ScenarioInfo.AeonCommander, true)
        ScenarioFramework.CDRDeathNISCamera(ScenarioInfo.AeonCommander)

        ScenarioFramework.Dialogue(OpStrings.C01_M08_020, KillGame_Win, true)
    end
end


-- ------------
-- Miscellaneous Functions
-- ------------

function AddGroupToTable(unitTable, group)
    for k,unit in group do
        table.insert(unitTable, unit)
    end
end

 -- - patrol a chain, with pauses at each point
function PatrolWithPauseThread(chain, platoon)
    -- Moves a platoon to a series of points in a chain, with a pause at each point.
    local points = ScenarioUtils.ChainToPositions(chain)
    local numPoints = table.getn(points)
    while ArmyBrains[UEF]:PlatoonExists(platoon) do
        for i = 1, numPoints do
            if ArmyBrains[UEF]:PlatoonExists(platoon) then
                local cmd = platoon:AggressiveMoveToLocation(points[i])
                while platoon:IsCommandsActive(cmd) do
                    WaitSeconds(1)
                    if not ArmyBrains[UEF]:PlatoonExists(platoon) then
                        return
                    end
                end
                WaitSeconds(4) -- pause at spot before continuing
            end
        end
    end
end

 -- - damage unit function
function DamageUnit(unit)
    local rndCheck = Random(1, 5)
    if rndCheck < 4 then -- 3/5 of units are touched
        local unitHealth = unit:GetHealth()
        local healthReduce = (-1 * (unitHealth * (.1 * (Random(4, 9)))))
        unit:AdjustHealth(unit, healthReduce)
    end
end

-- - Failure functions

function PlayerCDRKilled()
    if not ScenarioInfo.OperationEnding then
        ScenarioInfo.OperationEnding = true
        ScenarioFramework.EndOperationSafety()
        ScenarioFramework.FlushDialogueQueue()
--    ScenarioFramework.EndOperationCamera(ScenarioInfo.PlayerCDR, true)
        ScenarioFramework.CDRDeathNISCamera(ScenarioInfo.PlayerCDR)

        ScenarioFramework.Dialogue(OpStrings.C01_D01_010, KillGame_Fail, true )
    end
end

function KillGame_Win()
	ScenarioInfo.OpComplete = true
    WaitSeconds(10.0)
    ScenarioFramework.EndOperation(ScenarioInfo.OpComplete, ScenarioInfo.OpComplete, true)
end

function KillGame_Fail()
	ScenarioInfo.OpComplete = false
        WaitSeconds(10.0)
    ScenarioFramework.EndOperation(ScenarioInfo.OpComplete, ScenarioInfo.OpComplete, false)
end


-- - Build alterations

function BuildCategories1()
    -- Start by restricting all
    for _, player in ScenarioInfo.HumanPlayers do
         ScenarioFramework.AddRestriction(player, categories.ALLUNITS)
    end
    for _, player in ScenarioInfo.HumanPlayers do
         ScenarioFramework.RemoveRestriction(player, categories.urb1103) -- Mass
    end
    ScenarioFramework.RestrictEnhancements({'AdvancedEngineering', -- 1
                                            'CloakingGenerator',
                                            'CoolingUpgrade',
                                            'T3Engineering',
                                            'MicrowaveLaserGenerator',
                                            'NaniteTorpedoTube',
                                            'ResourceAllocation',
                                            'StealthGenerator',
                                            'Teleporter'})
end

function BuildCategories1b()
    ScenarioFramework.PlayUnlockDialogue()
    for _, player in ScenarioInfo.HumanPlayers do
         ScenarioFramework.RemoveRestriction(player, categories.urb1101) -- Power Gen
    end
end

function BuildCategories2()
    ScenarioFramework.PlayUnlockDialogue()
    for _, player in ScenarioInfo.HumanPlayers do
         ScenarioFramework.RemoveRestriction(player, categories.urb0102 + -- Air factory
                                         categories.urb5101 ) -- Wall Piece
    end
end

function BuildCategories3()
    ScenarioFramework.PlayUnlockDialogue()
    for _, player in ScenarioInfo.HumanPlayers do
         ScenarioFramework.RemoveRestriction(player, categories.ura0101 + -- Scout
                                         categories.ura0103 + -- Bomber
                                         categories.url0105 )  -- Engineer
    end
end

function BuildCategories4()
    ScenarioFramework.PlayUnlockDialogue()
    for _, player in ScenarioInfo.HumanPlayers do
         ScenarioFramework.RemoveRestriction(player, categories.ura0102 + -- Interceptor
                                         categories.urb3101 ) -- T1 Radar
    end
end

function BuildCategories4b()
    for _, player in ScenarioInfo.HumanPlayers do
         ScenarioFramework.RemoveRestriction(player, categories.urb2104) -- For Hard difficulty, unlock AA turrets earlier
    end
end

function BuildCategories5()
    ScenarioFramework.PlayUnlockDialogue()
    for _, player in ScenarioInfo.HumanPlayers do
         ScenarioFramework.RemoveRestriction(player,
             categories.uea0101 + categories.uea0102 + categories.uea0103 + categories.uel0105 +
             categories.ura0101 + categories.ura0102 + categories.ura0103 + categories.url0105 +
             categories.uaa0101 + categories.uaa0102 + categories.uaa0103 + categories.ual0105 +
     
             categories.ueb2101 + categories.ueb1101 + categories.ueb1103 + categories.ueb3101 +
             categories.urb2101 + categories.urb1101 + categories.urb1103 + categories.urb3101 +
             categories.uab2101 + categories.uab1101 + categories.uab1103 + categories.uab3101 +
     
             categories.ueb5101 + categories.ueb2104 +
             categories.urb5101 + categories.urb2104 +
             categories.uab5101 + categories.uab2104 )
    end
end

function BuildCategories6()
    for _, player in ScenarioInfo.HumanPlayers do
         ScenarioFramework.RemoveRestriction(player,
             categories.urb0101 + categories.ueb0101 + categories.uab0101 + categories.ueb0102 +
             categories.uel0101 + categories.uel0106 + categories.uel0103 + categories.uel0104 +
             categories.url0101 + categories.url0106 + categories.url0103 + categories.url0104 +
             categories.ual0101 + categories.ual0106 + categories.ual0103 + categories.ual0104 )
    end
end

function BuildCategories7()
    ScenarioFramework.PlayUnlockDialogue()
    for _, player in ScenarioInfo.HumanPlayers do
         ScenarioFramework.RemoveRestriction(player, categories.uea0107 +
                                         categories.ura0107 +
                                         categories.uaa0107 +
                                         categories.url0107 )
    end
end

function BuildCategoriesFinal()
    -- Allow a CDR upgrade here, for the final attack against the Aeon for part4
    ScenarioFramework.RestrictEnhancements({'AdvancedEngineering', -- 1
                                            'CloakingGenerator',
                                            'T3Engineering',
                                            'MicrowaveLaserGenerator',
                                            'NaniteTorpedoTube',
                                            'ResourceAllocation',
                                            'StealthGenerator',
                                            'Teleporter'})
end

 -- - Reminders
 -- - 1
function M1P1Reminder1()
    if not ScenarioInfo.M1P1Complete then
        ScenarioFramework.Dialogue(OpStrings.C01_M01_050)
        ScenarioFramework.CreateTimerTrigger(M1P1Reminder2, ReminderSubsequentTime1)
    end
end

function M1P1Reminder2()
    if not ScenarioInfo.M1P1Complete then
        ScenarioFramework.Dialogue(OpStrings.C01_M01_055)
        ScenarioFramework.CreateTimerTrigger(M1P1Reminder3, ReminderSubsequentTime1)
    end
end

function M1P1Reminder3()
    if not ScenarioInfo.M1P1Complete then
        ScenarioFramework.Dialogue(OpStrings.C01_M01_060)
        ScenarioFramework.CreateTimerTrigger(M1P1Reminder1, ReminderSubsequentTime1)
    end
end

 -- - 1
function M1P2Reminder1()
    if(not ScenarioInfo.M1P2Complete) then
        ScenarioFramework.Dialogue(OpStrings.C01_M01_065)
        ScenarioFramework.CreateTimerTrigger(M1P2Reminder2, ReminderSubsequentTime1)
    end
end

function M1P2Reminder2()
    if(not ScenarioInfo.M1P2Complete) then
        ScenarioFramework.Dialogue(OpStrings.C01_M01_070)
        ScenarioFramework.CreateTimerTrigger(M1P2Reminder3, ReminderSubsequentTime1)
    end
end

function M1P2Reminder3()
    if(not ScenarioInfo.M1P2Complete) then
        ScenarioFramework.Dialogue(OpStrings.C01_M01_060)
        ScenarioFramework.CreateTimerTrigger(M1P2Reminder1, ReminderSubsequentTime1)
    end
end

 -- - 2
function M2P1Reminder1()
    if(not ScenarioInfo.M2P1Complete) then
        ScenarioFramework.Dialogue(OpStrings.C01_M02_020)
        ScenarioFramework.CreateTimerTrigger(M2P1Reminder2, ReminderSubsequentTime1)
    end
end

function M2P1Reminder2()
    if(not ScenarioInfo.M2P1Complete) then
        ScenarioFramework.Dialogue(OpStrings.C01_M02_030)
        ScenarioFramework.CreateTimerTrigger(M2P1Reminder3, ReminderSubsequentTime1)
    end
end

function M2P1Reminder3()
    if(not ScenarioInfo.M2P1Complete) then
        ScenarioFramework.Dialogue(OpStrings.C01_M01_060)
        ScenarioFramework.CreateTimerTrigger(M2P1Reminder1, ReminderSubsequentTime1)
    end
end

 -- -  3
function M3P1Reminder1()
    if(not ScenarioInfo.M3P1Complete) then
        ScenarioFramework.Dialogue(OpStrings.C01_M03_020)
        ScenarioFramework.CreateTimerTrigger(M3P1Reminder2, ReminderSubsequentTime1)
    end
end

function M3P1Reminder2()
    if(not ScenarioInfo.M3P1Complete) then
        ScenarioFramework.Dialogue(OpStrings.C01_M03_025)
        ScenarioFramework.CreateTimerTrigger(M3P1Reminder3, ReminderSubsequentTime1)
    end
end

function M3P1Reminder3()
    if(not ScenarioInfo.M3P1Complete) then
        ScenarioFramework.Dialogue(OpStrings.C01_M01_060)
        ScenarioFramework.CreateTimerTrigger(M3P1Reminder1, ReminderSubsequentTime1)
    end
end

 -- - 4
function M4P1Reminder1()
    if(not ScenarioInfo.M4P1Complete) then
        ScenarioFramework.Dialogue(OpStrings.C01_M04_050)
        ScenarioFramework.CreateTimerTrigger(M4P1Reminder2, ReminderSubsequentTime1)
    end
    if ScenarioInfo.M4P1Complete == true and ScenarioInfo.M4P2Complete == false then
        ScenarioFramework.CreateTimerTrigger(M4P2Reminder1, ReminderSubsequentTime1)
    end
end

function M4P1Reminder2()
    if(not ScenarioInfo.M4P1Complete) then
        ScenarioFramework.Dialogue(OpStrings.C01_M04_055)
        ScenarioFramework.CreateTimerTrigger(M4P1Reminder3, ReminderSubsequentTime1)
    end
    if ScenarioInfo.M4P1Complete == true and ScenarioInfo.M4P2Complete == false then
        ScenarioFramework.CreateTimerTrigger(M4P2Reminder1, ReminderSubsequentTime1)
    end
end

function M4P1Reminder3()
    if(not ScenarioInfo.M4P1Complete) then
        ScenarioFramework.Dialogue(OpStrings.C01_M01_060)
        ScenarioFramework.CreateTimerTrigger(M4P1Reminder1, ReminderSubsequentTime1)
    end
    if ScenarioInfo.M4P1Complete == true and ScenarioInfo.M4P2Complete == false then
        ScenarioFramework.CreateTimerTrigger(M4P2Reminder1, ReminderSubsequentTime1)
    end
end

 -- - 4
function M4P2Reminder1()
    if(not ScenarioInfo.M4P2Complete) then
        ScenarioFramework.Dialogue(OpStrings.C01_M04_060)
        ScenarioFramework.CreateTimerTrigger(M4P2Reminder2, ReminderSubsequentTime1)
    end
end

function M4P2Reminder2()
    if(not ScenarioInfo.M4P2Complete) then
        ScenarioFramework.Dialogue(OpStrings.C01_M04_065)
        ScenarioFramework.CreateTimerTrigger(M4P2Reminder3, ReminderSubsequentTime1)
    end
end

function M4P2Reminder3()
    if(not ScenarioInfo.M4P2Complete) then
        ScenarioFramework.Dialogue(OpStrings.C01_M01_060)
        ScenarioFramework.CreateTimerTrigger(M4P2Reminder1, ReminderSubsequentTime1)
    end
end

 -- - 5
function M5P1Reminder1()
    if(not ScenarioInfo.M5P1Complete) then
        ScenarioFramework.Dialogue(OpStrings.C01_M05_040)
        ScenarioFramework.CreateTimerTrigger(M5P1Reminder2, ReminderSubsequentTime1)
    end
end

function M5P1Reminder2()
    if(not ScenarioInfo.M5P1Complete) then
        ScenarioFramework.Dialogue(OpStrings.C01_M05_045)
        ScenarioFramework.CreateTimerTrigger(M5P1Reminder3, ReminderSubsequentTime1)
    end
end

function M5P1Reminder3()
    if(not ScenarioInfo.M5P1Complete) then
        ScenarioFramework.Dialogue(OpStrings.C01_M01_060)
        ScenarioFramework.CreateTimerTrigger(M5P1Reminder1, ReminderSubsequentTime1)
    end
end

 -- - 6
function M6P1Reminder1()
    if(not ScenarioInfo.M6P1Complete) then
        ScenarioFramework.Dialogue(OpStrings.C01_M06_060)
        ScenarioFramework.CreateTimerTrigger(M6P1Reminder2, ReminderSubsequentTime2)
    end
    if ScenarioInfo.M6P1Complete == true and ScenarioInfo.M6P2Complete == false then
        ScenarioFramework.CreateTimerTrigger(M6P2Reminder1, ReminderSubsequentTime2)
    end
end

function M6P1Reminder2()
    if(not ScenarioInfo.M6P1Complete) then
        ScenarioFramework.Dialogue(OpStrings.C01_M06_070)
        ScenarioFramework.CreateTimerTrigger(M6P1Reminder3, ReminderSubsequentTime2)
    end
    if ScenarioInfo.M6P1Complete == true and ScenarioInfo.M6P2Complete == false then
        ScenarioFramework.CreateTimerTrigger(M6P2Reminder1, ReminderSubsequentTime2)
    end
end

function M6P1Reminder3()
    if(not ScenarioInfo.M6P1Complete) then
        ScenarioFramework.Dialogue(OpStrings.C01_M01_060)
        ScenarioFramework.CreateTimerTrigger(M6P1Reminder1, ReminderSubsequentTime2)
    end
    if ScenarioInfo.M6P1Complete == true and ScenarioInfo.M6P2Complete == false then
        ScenarioFramework.CreateTimerTrigger(M6P2Reminder1, ReminderSubsequentTime2)
    end
end

function M6P2Reminder1()
    if(not ScenarioInfo.M6P2Complete) then
        ScenarioFramework.Dialogue(OpStrings.C01_M06_080)
        ScenarioFramework.CreateTimerTrigger(M6P2Reminder2, ReminderSubsequentTime2)
    end
end

function M6P2Reminder2()
    if(not ScenarioInfo.M6P2Complete) then
        ScenarioFramework.Dialogue(OpStrings.C01_M06_090)
        ScenarioFramework.CreateTimerTrigger(M6P2Reminder3, ReminderSubsequentTime2)
    end
end

function M6P2Reminder3()
    if(not ScenarioInfo.M6P2Complete) then
        ScenarioFramework.Dialogue(OpStrings.C01_M01_060)
        ScenarioFramework.CreateTimerTrigger(M6P2Reminder1, ReminderSubsequentTime2)
    end
end

 -- - 7
function M7P1Reminder1()
    if(not ScenarioInfo.M7P1Complete) then
        ScenarioFramework.Dialogue(OpStrings.C01_M07_170)
        ScenarioFramework.CreateTimerTrigger(M7P1Reminder2, ReminderSubsequentTime2)
    end
    if ScenarioInfo.M7P1Complete == true and ScenarioInfo.M7P2Complete == false then
        ScenarioFramework.CreateTimerTrigger(M7P2Reminder1, ReminderSubsequentTime2)
    end
end

function M7P1Reminder2()
    if(not ScenarioInfo.M7P1Complete) then
        ScenarioFramework.Dialogue(OpStrings.C01_M07_180)
        ScenarioFramework.CreateTimerTrigger(M7P1Reminder3, ReminderSubsequentTime2)
    end
    if ScenarioInfo.M7P1Complete == true and ScenarioInfo.M7P2Complete == false then
        ScenarioFramework.CreateTimerTrigger(M7P2Reminder1, ReminderSubsequentTime2)
    end
end

function M7P1Reminder3()
    if(not ScenarioInfo.M7P1Complete) then
        ScenarioFramework.Dialogue(OpStrings.C01_M01_060)
        ScenarioFramework.CreateTimerTrigger(M7P1Reminder1, ReminderSubsequentTime2)
    end
    if ScenarioInfo.M7P1Complete == true and ScenarioInfo.M7P2Complete == false then
        ScenarioFramework.CreateTimerTrigger(M7P2Reminder1, ReminderSubsequentTime2)
    end
end
 -- - 7
function M7P2Reminder1()
    if(not ScenarioInfo.M7P2Complete) then
        ScenarioFramework.Dialogue(OpStrings.C01_M07_185)
        ScenarioFramework.CreateTimerTrigger(M7P2Reminder2, ReminderSubsequentTime2)
    end
end

function M7P2Reminder2()
    if(not ScenarioInfo.M7P2Complete) then
        ScenarioFramework.Dialogue(OpStrings.C01_M07_190)
        ScenarioFramework.CreateTimerTrigger(M7P2Reminder3, ReminderSubsequentTime2)
    end
end

function M7P2Reminder3()
    if(not ScenarioInfo.M7P2Complete) then
        ScenarioFramework.Dialogue(OpStrings.C01_M01_060)
        ScenarioFramework.CreateTimerTrigger(M7P2Reminder1, ReminderSubsequentTime2)
    end
end

 -- - 8
function M8P1Reminder1()
    if(not ScenarioInfo.M8P1Complete) then
        ScenarioFramework.Dialogue(OpStrings.C01_M08_050)
        ScenarioFramework.CreateTimerTrigger(M8P1Reminder2, ReminderSubsequentTime2)
    end
end

function M8P1Reminder2()
    if(not ScenarioInfo.M8P1Complete) then
        ScenarioFramework.Dialogue(OpStrings.C01_M08_055)
        ScenarioFramework.CreateTimerTrigger(M8P1Reminder3, ReminderSubsequentTime2)
    end
end

function M8P1Reminder3()
    if(not ScenarioInfo.M8P1Complete) then
        ScenarioFramework.Dialogue(OpStrings.C01_M01_060)
        ScenarioFramework.CreateTimerTrigger(M8P1Reminder1, ReminderSubsequentTime2)
    end
end

-- ---------------
-- Debug Functions
-- ---------------
-- function OnCtrlF4()
-- #ScenarioFramework.EndOperation('SCCA_Coop_R01', true, ScenarioInfo.Options.Difficulty, false, false)
-- print('Ctrl f4')
-- BeginPart2()
-- end
--
-- function OnF4()
-- print ('F4')
-- BeginPart3()
-- end
--
-- function OnCtrlAltF4()
-- print('OnCtrlAltF4')
-- #    Utilities.UserConRequest('ui_DebugAltClick')
-- end
--
-- function OnCtrlAltF5()
-- ScenarioFramework.EndOperation('SCCA_Coop_R01', true, ScenarioInfo.Options.Difficulty, true, true)
-- end
