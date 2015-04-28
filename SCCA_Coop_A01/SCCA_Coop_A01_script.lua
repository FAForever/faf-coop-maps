-- ****************************************************************************
-- **
-- **  File     :  /maps/SCCA_Coop_A01/SCCA_Coop_A01_v03_script.lua
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
local OpStrings   = import('/maps/SCCA_Coop_A01/SCCA_Coop_A01_v03_Strings.lua')
local ScenarioStrings = import('/lua/ScenarioStrings.lua')
local AIBuildStructures = import('/lua/ai/aibuildstructures.lua')
local Utilities = import('/lua/utilities.lua')

-- -------
-- Globals
-- -------
ScenarioInfo.Player         = 1
ScenarioInfo.Rhiza          = 2
ScenarioInfo.UEF            = 3
ScenarioInfo.FauxUEF        = 4
ScenarioInfo.FauxRhiza      = 5
ScenarioInfo.Coop1 = 6
ScenarioInfo.Coop2 = 7
ScenarioInfo.Coop3 = 8
ScenarioInfo.HumanPlayers = {ScenarioInfo.Player}
local Player                = ScenarioInfo.Player
local Coop1 = ScenarioInfo.Coop1
local Coop2 = ScenarioInfo.Coop2
local Coop3 = ScenarioInfo.Coop3
local Rhiza                 = ScenarioInfo.Rhiza
local UEF                   = ScenarioInfo.UEF
local FauxUEF               = ScenarioInfo.FauxUEF
local FauxRhiza             = ScenarioInfo.FauxRhiza

local MissionStartDelay     = 1.25

 -- - reminders
ScenarioInfo.M1P1Complete               = false -- power
ScenarioInfo.M1P2Complete               = false -- mass
ScenarioInfo.M2P1Complete               = false -- factory
ScenarioInfo.M3P1Complete               = false -- gunboats
ScenarioInfo.M3P2Complete               = false -- air patrol
ScenarioInfo.M4P1Complete               = false -- build subs
ScenarioInfo.M5P1Complete               = false -- defeat subs
ScenarioInfo.M6P1Complete               = false -- resource base

-- ScenarioInfo.M7P1Complete               = false #destroy ships
ScenarioInfo.M7P2Complete               = false -- destroy aa
ScenarioInfo.M7P3Complete               = false -- defeat uef cdr
ScenarioInfo.M7P4Complete               = false -- "assist" the czar
ScenarioInfo.M7S1Complete               = false -- defeat air base
ScenarioInfo.M7S2Complete               = false -- defeat naval base

ScenarioInfo.AssistCzarAssigned         = false
ScenarioInfo.CzarSpawned                = false

 -- - reminder timers
local ReminderInitialTime1              =   600
local ReminderSubsequentTime1           =   300
local ReminderInitialTime2              =   600
local ReminderSubsequentTime2           =   600

 -- -
local M4_OffmapAir_Counter    = 0
local M4_OffmapAir_Patrol     = 1
local M7_AirPatrolCount       = 0
local M7_AirPatrolThresh      = 3
local M7_NavalPatrolCount     = 0
local M7_NavalPatrolThresh    = 4
local M7_AADeathCount         = 0
local EndOperationCount       = 0

ScenarioInfo.FauxUEFCommanderKilled     = false
ScenarioInfo.SubCommanderDead           = false
ScenarioInfo.OperationEnding            = false

ScenarioInfo.VarTable['M7_BeginAirBuild']   = false
ScenarioInfo.VarTable['M7_BeginNavalBuild'] = false

local M3P1_BuildBoatValue     = 3  -- number Attack Boats to build for m3p1 objective

local LeaderFaction
local LocalFaction

-- --------------------
-- Starter Functions
-- --------------------

function OnPopulate(scenario)
    ScenarioUtils.InitializeScenarioArmies()
    LeaderFaction, LocalFaction = ScenarioFramework.GetLeaderAndLocalFactions()

    M1_UnitsForStart()

    -- Player only gets score
    for i = 2, table.getn(ArmyBrains) do
        if i < ScenarioInfo.Coop1 then
            SetArmyShowScore(i, false)
            SetIgnorePlayableRect(i, true)
        end
    end
end

function OnStart(self)
    -- ScenarioFramework.PlayNIS('/movies/_ph_SCCA_A01_NIS.sfd')
    ScenarioFramework.SetPlayableArea(ScenarioUtils.AreaToRect('PlayableArea_1'), false)
    ForkThread(StartCamera)
    ScenarioFramework.SetAeonColor(1)
    ScenarioFramework.SetAeonAllyColor(2)
    ScenarioFramework.SetUEFColor(3)
    ScenarioFramework.SetUEFColor(4)
    ScenarioFramework.SetAeonAllyColor(5)
end

function M1_UnitsForStart()
    ScenarioInfo.Difficulty = ScenarioInfo.Options.Difficulty or 2

    -- Set difficulty concantenation string
    if ScenarioInfo.Difficulty == 1 then DifficultyConc = 'Light' end
    if ScenarioInfo.Difficulty == 2 then DifficultyConc = 'Medium' end
    if ScenarioInfo.Difficulty == 3 then DifficultyConc = 'Strong' end
end

function StartCamera()
    Cinematics.CameraMoveToRectangle(ScenarioUtils.AreaToRect('PlayableArea_1'), 0)
  -- WaitSeconds(10)
    Cinematics.EnterNISMode()
    ForkThread(CreateCommander)
    Cinematics.CameraMoveToRectangle(ScenarioUtils.AreaToRect('Start_Camera_Area'), 2)
    Cinematics.ExitNISMode()
    BeginOperation()
end

function CreateCommander()
    -- Build cats *before* cdr is created
    BuildCategories1()

    WaitSeconds(1)
    -- Player Commander
    ScenarioInfo.PlayerCDR = ScenarioUtils.CreateArmyUnit('Player', 'Player_Commander')
    ScenarioInfo.PlayerCDR:PlayCommanderWarpInEffect()

    -- spawn coop players too
    ScenarioInfo.CoopCDR = {}
    local tblArmy = ListArmies()
    coop = 1
    for iArmy, strArmy in pairs(tblArmy) do
        if iArmy >= ScenarioInfo.Coop1 then
            ScenarioInfo.CoopCDR[coop] = ScenarioUtils.CreateArmyUnit(strArmy, 'Player_Commander')
            ScenarioInfo.CoopCDR[coop]:PlayCommanderWarpInEffect()
            coop = coop + 1
            WaitSeconds(0.5)
        end
    end

end

-- ------------
-- Mission 1
-- ------------

function BeginOperation()
    for i = 2, table.getn(ArmyBrains) do
    end

    SetArmyUnitCap(1, 300)
    SetArmyUnitCap(3, 500)

    SetArmyUnitCap(2, 300)
    SetArmyUnitCap(4, 300)

    ScenarioInfo.MissionNumber = 1
    ScenarioFramework.CreateUnitDestroyedTrigger(PlayerCommanderDies_Lose, ScenarioInfo.PlayerCDR)
    ScenarioFramework.PauseUnitDeath(ScenarioInfo.PlayerCDR)

    for index, coopACU in ScenarioInfo.CoopCDR do
        ScenarioFramework.PauseUnitDeath(coopACU)
        ScenarioFramework.CreateUnitDeathTrigger(PlayerCommanderDies_Lose, coopACU)
    end

    -- Delay dialogue and assigning objectives, to allow for warp in effect to finish, etc
    ScenarioFramework.CreateTimerTrigger(M1_BeginningDialogue, 4)
    ScenarioFramework.CreateTimerTrigger(M1_BeginningObjectives, 7)
end

function M1_BeginningDialogue()
    ScenarioFramework.Dialogue(OpStrings.A01_M01_020)
end

function M1_BeginningObjectives()
    ScenarioFramework.CreateTimerTrigger(M1P2Reminder1, ReminderInitialTime1)

    -- Primary Objective 1
    ScenarioInfo.M1Objectives = Objectives.CreateGroup('Mission1', M2_StartDelay)

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
            ShowProgress = true,
            Category = categories.uab1103,
        }
   )
    ScenarioInfo.M1P2:AddResultCallback(
        function()
            ScenarioInfo.M1P2Complete = true
            M1_SecondObjective()
        end
   )
    ScenarioInfo.M1Objectives:AddObjective(ScenarioInfo.M1P2)
end

function M1_SecondObjective()
    ScenarioFramework.CreateTimerTrigger(M1P1Reminder1, ReminderInitialTime1)

    -- Primary Objective 2
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
            ShowProgress = true,
            Category = categories.uab1101,
        }
   )
    ScenarioInfo.M1P1:AddResultCallback(
        function()
            ScenarioInfo.M1P1Complete = true
        end
   )
    ScenarioInfo.M1Objectives:AddObjective(ScenarioInfo.M1P1)

end

-- ------------
-- Mission 2
-- ------------

function M2_StartDelay()
    ScenarioFramework.CreateTimerTrigger(M2_Start, MissionStartDelay)
end

function M2_Start()
    ScenarioInfo.MissionNumber = 2
    ScenarioFramework.Dialogue(OpStrings.A01_M01_030, M2_BuildFactoryObj)
    BuildCategories2()
end

function M2_BuildFactoryObj()
    ScenarioFramework.CreateTimerTrigger(M2P1Reminder1, ReminderInitialTime1)
    -- Primary Objective 1
    local m2Objectives = Objectives.CreateGroup('Mission2', M3_StartDelay)
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
            Category = categories.uab0103,
        }
   )
    ScenarioInfo.M2P1:AddResultCallback(
        function()
            ScenarioInfo.M2P1Complete = true
        end
   )
    m2Objectives:AddObjective(ScenarioInfo.M2P1)
end

-- ------------
-- Mission 3
-- ------------

function M3_StartDelay()
    ScenarioFramework.CreateTimerTrigger(M3_Start, MissionStartDelay)
end

function M3_Start()
    ScenarioInfo.M3_UEFInterceptorPatrol = ScenarioUtils.CreateArmyGroup('UEF', 'M3_UEFInterceptors')
    ScenarioFramework.Dialogue(OpStrings.A01_M02_010)
    M3_BuildGunboatsObjective()
    BuildCategories3()
    ScenarioFramework.SetPlayableArea(ScenarioUtils.AreaToRect('PlayableArea_3'), false)
    for k,v in ScenarioInfo.M3_UEFInterceptorPatrol do
        v:SetFuelRatio(0.01)
        IssuePatrol({v}, ScenarioUtils.MarkerToPosition('M3_InterceptorPatrol_1'))
        IssuePatrol({v}, ScenarioUtils.MarkerToPosition('M3_InterceptorPatrol_2'))
        IssuePatrol({v}, ScenarioUtils.MarkerToPosition('M3_InterceptorPatrol_3'))
        IssuePatrol({v}, ScenarioUtils.MarkerToPosition('M3_InterceptorPatrol_4'))
    end
    ScenarioInfo.MissionNumber = 3
end

function M3_BuildGunboatsObjective()
    -- Primary Objective 1, first half
    ScenarioInfo.M3P1 = Objectives.ArmyStatCompare(
        'primary',                      -- type
        'incomplete',                   -- complete
        LOCF(OpStrings.M3P1Text, M3P1_BuildBoatValue),          -- title
        LOCF(OpStrings.M3P1Detail, M3P1_BuildBoatValue, M3P1_BuildBoatValue),        -- description
        'build',                        -- action
        {                               -- target
            Army = Player,
            StatName = 'Units_Active',
            CompareOp = '>=',
            Value = M3P1_BuildBoatValue,
            Category = categories.uas0102,
            ShowProgress = true,
        }
   )
    ScenarioInfo.M3P1:AddResultCallback(
        function()
            ScenarioInfo.M3P1Complete = true
            -- If we havent already completed the second part of the obj (which, currently, isn't possible as it
            -- autocompletes this obj for now), play a prompt to polish off the patrol ...
            if not ScenarioInfo.M3P2Complete then
                -- ... if there are more than 1 left (if there's only 1 left, the player is clearly almost done,
                -- and both doesnt need a prompt, and will soon be hearing more dialogue anyway).
                local airNumber = 0
                for k,v in ScenarioInfo.M3_UEFInterceptorPatrol do
                    if (not v:IsDead()) then
                        airNumber = airNumber + 1
                    end
                end
                if airNumber >= 2 then
                    -- ... then play a prompt to finish off the interceptors (the other obj)
                    ScenarioFramework.Dialogue(OpStrings.A01_M03_020)
                end
            end
        end
   )

    -- Second Half
    ScenarioFramework.CreateTimerTrigger(M3P2Reminder1 ,ReminderInitialTime1)
    ScenarioInfo.M3P2 = Objectives.KillOrCapture(
        'primary',                      -- type
        'incomplete',                   -- complete
        OpStrings.M3P2Text,             -- title
        OpStrings.M3P2Detail,           -- description
        {                               -- target
            Units = ScenarioInfo.M3_UEFInterceptorPatrol,
        }
   )
    ScenarioInfo.M3P2:AddResultCallback(
        function()
            ScenarioInfo.M3P2Complete = true
            -- If the first half isnt completed (ie, we've destroyed the patrol but havent built the required number of
            -- attack boats yet), complete it here anyway.
            if not ScenarioInfo.M3P1Complete then
                ScenarioInfo.M3P1Complete = true
                ScenarioInfo.M3P1:ManualResult(true)
            end
            M4_StartDelay()
        end
   )
end

-- ------------
-- Mission 4
-- ------------
function M4_StartDelay()
    ScenarioFramework.CreateTimerTrigger(M4_Start, 3)
end

function M4_Start()
    ScenarioInfo.MissionNumber = 4
    ScenarioFramework.Dialogue(OpStrings.A01_M03_010, M4_BuildSubsObj)
    BuildCategories4()
    ScenarioFramework.CreateTimerTrigger(M4_OffmapAir1 , 55) -- after a delay, fill the time by sending in the occasion air unit
end

function M4_BuildSubsObj()
    ScenarioFramework.CreateTimerTrigger(M4P1Reminder1 ,ReminderInitialTime1)

    local m4Objectives = Objectives.CreateGroup('Mission4', M5_StartDelay)
    ScenarioInfo.M4P1 = Objectives.ArmyStatCompare(
        'primary',                      -- type
        'incomplete',                   -- complete
        OpStrings.M4P1Text,             -- title
        OpStrings.M4P1Detail,           -- description
        'build',                        -- action
        {                               -- target
            Army = Player,
            StatName = 'Units_Active',
            CompareOp = '>=',
            Value = 3,
            Category = categories.uas0203,
            ShowProgress = true,
        }
   )
    ScenarioInfo.M4P1:AddResultCallback(
        function()
            ScenarioInfo.M4P1Complete = true
        end
   )
    m4Objectives:AddObjective(ScenarioInfo.M4P1)
end

function M4_OffmapAir1()
    M4_OffmapAir_Counter = M4_OffmapAir_Counter + 1
    -- 3 waves of intereceptors
    if ScenarioInfo.MissionNumber == 4 and M4_OffmapAir_Counter <= 3 then
        M4_OffmapAir_Patrol = M4_OffmapAir_Patrol + 1
        -- make a conc. of 1 or 2, for patrols
        if M4_OffmapAir_Patrol == 3 then
            M4_OffmapAir_Patrol = 1
        end
        -- Alternate between two patrol chains
        local air = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M4_UEF_AirGroup_Int', 'ChevronFormation')
        ScenarioFramework.PlatoonPatrolChain(air, 'M4_UEF_AirPatrol_Chain'..M4_OffmapAir_Patrol)
        ScenarioFramework.CreatePlatoonDeathTrigger(M4_OffmapInterlude, air)
    end
end

function M4_OffmapInterlude()
    ScenarioFramework.CreateTimerTrigger(M4_OffmapAir1, 55)
end

-- ------------
-- Mission 5
-- ------------
function M5_StartDelay()
    ScenarioFramework.CreateTimerTrigger(M5_Start, MissionStartDelay)
    ScenarioInfo.MissionNumber = 5 -- set this a bit early, so the interceptor from previous mission dont apear in interum
end

function M5_Start()
    BuildCategories5()
    ScenarioFramework.SetPlayableArea(ScenarioUtils.AreaToRect('PlayableArea_4'))

    ScenarioInfo.SubUnits = {}
    for i = 1, 4 do
        local unit = ScenarioUtils.CreateArmyUnit('UEF', 'M5_UEFSub_'..i)
        ScenarioFramework.GroupPatrolChain({unit}, 'M5_UEFSub'..i..'Patrol_Chain')
        table.insert(ScenarioInfo.SubUnits, unit)
    end
    ScenarioFramework.Dialogue(OpStrings.A01_M04_010)
    M5_DestroyUEFSubsObj()-- Needs to be immediate, so we dont kill the subs before VO is done in conventional scenario
end

function M5_DestroyUEFSubsObj()
    ScenarioFramework.CreateTimerTrigger(M5P1Reminder1 ,ReminderInitialTime1)
    local m5Objectives = Objectives.CreateGroup('Mission5', M6_StartDelay)
    ScenarioInfo.M5P1 = Objectives.KillOrCapture(
        'primary',                      -- type
        'incomplete',                   -- complete
        OpStrings.M5P1Text,             -- title
        OpStrings.M5P1Detail,           -- description
        {                               -- target
            Units = ScenarioInfo.SubUnits,
        }
   )
    ScenarioInfo.M5P1:AddResultCallback(
        function()
            ScenarioInfo.M5P1Complete = true
        end
   )
    m5Objectives:AddObjective(ScenarioInfo.M5P1)
end

-- ------------
-- Mission 6
-- ------------
function M6_StartDelay()
    ScenarioFramework.CreateTimerTrigger(M6_Start, 2)
end

function M6_Start()
    ScenarioInfo.MissionNumber = 6
    ScenarioFramework.Dialogue(OpStrings.A01_M05_010)
    M6_ResourceBaseUnits()
    M6_ResourceBaseObj()
    BuildCategories6()
end

function M6_ResourceBaseObj()
    local m6Objectives = Objectives.CreateGroup('Mission6', M7_BeginMission)-- M7_StartDelay)
    ScenarioInfo.M6P1 = Objectives.KillOrCapture(                          -- Destroy resource base
        'primary',                      -- type
        'incomplete',                   -- complete
        OpStrings.M6P1Text,             -- title
        OpStrings.M6P1Detail,           -- description
        {                               -- target
            Units = ScenarioInfo.M6_ObjectiveUnits,
        }
   )
    ScenarioInfo.M6P1:AddResultCallback(
        function(result, unit)

-- resouce base destroyed camera
            local camInfo = {
                blendTime = 1.0,
                holdTime = 4,
                orientationOffset = { -1.38, 0.3, 0 },
                positionOffset = { 0, 0.5, 0 },
                zoomVal = 35,
            }
            ScenarioFramework.OperationNISCamera(unit, camInfo)

            ScenarioInfo.M6P1Complete = true
            ScenarioFramework.Dialogue(OpStrings.A01_M06_010)
        end
   )
    m6Objectives:AddObjective(ScenarioInfo.M6P1)
end

function M6_ResourceBaseUnits()
    ScenarioFramework.CreateTimerTrigger(M6P1Reminder1 ,ReminderInitialTime1)

    -- Resource Base
    ScenarioInfo.M6_ObjectiveUnits = ScenarioUtils.CreateArmyGroup('UEF', 'M6_UEFBase_Objective')
    ScenarioUtils.CreateArmyGroup('UEF', 'M6_UEFBase_Defense_'..DifficultyConc)
    ScenarioUtils.CreateArmyGroup('UEF', 'M6_UEFBase_Production')
    ScenarioUtils.CreateArmyGroup('UEF', 'M6_UEFBase_Walls')

    if ScenarioInfo.Difficulty == 3 then
        factory = ScenarioInfo.UnitNames[UEF]['M6_UEFBase_Factory']
        engineers = ScenarioUtils.CreateArmyGroup('UEF', 'M6_UEFBase_EngineersHard')
        for k,v in engineers do
            IssueGuard({v}, factory)
        end

        -- Small air group that will patrol over player base area from north, after a brief pause
        ScenarioInfo.M6AirHard1 = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M6_UEFPatrol3_Attack', 'ChevronFormation')
        ScenarioFramework.CreateTimerTrigger(M6_Hard_DelayedAirAttack,10)
    end

    -- Patrolers
    local airPatrol1 = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M6_UEFPatrol1_'..DifficultyConc, 'ChevronFormation')
    local airPatrol2 = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M6_UEFPatrol2_'..DifficultyConc, 'ChevronFormation')
    ScenarioFramework.PlatoonPatrolChain(airPatrol1, 'M6_UEFAirPatrol_Chain1')
    ScenarioFramework.PlatoonPatrolChain(airPatrol2, 'M6_UEFAirPatrol_Chain2')

    ScenarioFramework.SetPlayableArea(ScenarioUtils.AreaToRect('PlayableArea_5'))
end

function M6_Hard_DelayedAirAttack()
    ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.M6AirHard1  , 'M6_UEF_InitialAttackPatrol_Chain')
end
-- ------------
-- Mission 7
-- ------------

function M7_StartDelay()
    ScenarioFramework.CreateTimerTrigger(M7_BeginMission, 3)
end

function M7_BeginMission()
    SetArmyUnitCap(1, 500)

    if ScenarioInfo.Difficulty < 3 then
        M7_AirPatrolThresh = 3
        M7_NavalPatrolThresh = 4
    else
        M7_AirPatrolThresh = 6
        M7_NavalPatrolThresh = 5
    end

    ScenarioInfo.MissionNumber = 7
    ScenarioFramework.Dialogue(OpStrings.A01_M07_015, M7_UnlockAirDialogueDelay) -- Delay before telling player that Air factory is unlocked
    ScenarioFramework.CreateTimerTrigger(M7_BerryBanterDialogue, 180)
    BuildCategories7()
    ScenarioFramework.SetPlayableArea(ScenarioUtils.AreaToRect('PlayableArea_6'))

    -- FauxUEF units
    ScenarioUtils.CreateArmyGroup('FauxUEF', 'M7_FauxUEF_Base')
    ScenarioUtils.CreateArmyGroup('FauxUEF', 'M7_FauxUEFBase_Walls')
    ScenarioUtils.CreateArmyGroup('FauxUEF', 'M7_FauxUEF_InitialEngineers')
    ScenarioInfo.FauxUEF_SpecialDef = ScenarioUtils.CreateArmyGroup('FauxUEF', 'M7_FauxUEF_SpecialDef')
    for x,y in ScenarioInfo.FauxUEF_SpecialDef do
        y:SetReclaimable(false)
        y:SetCapturable(false)
        y:SetCanBeKilled(false)
    end

    for i = 1,5 do
        local factory = ScenarioInfo.UnitNames[FauxUEF]['FauxUEF_f'..i] -- factories uncapturable
        factory:SetReclaimable(false)
        factory:SetCapturable(false)
    end

    ScenarioInfo.M7_FauxUEFCommanderUnit = ScenarioUtils.CreateArmyUnit('FauxUEF', 'M7_UEFCommanderUnit')
    ScenarioInfo.M7_FauxUEFCommanderUnit:CreateEnhancement('ShieldGeneratorField')
    ScenarioInfo.M7_FauxUEFCommanderUnit:SetReclaimable(false)
    ScenarioInfo.M7_FauxUEFCommanderUnit:SetCapturable(false)
    for i = 1, 3 do
        IssuePatrol({ScenarioInfo.M7_FauxUEFCommanderUnit}, ScenarioUtils.MarkerToPosition('M7_FauxUEFCDR_Patrol_'..i))
    end
    ScenarioInfo.M7_FauxUEFCommanderUnit:SetCustomName(LOC '{i CDR_Gart}')
    ScenarioInfo.M7_FauxUEFCommanderUnit:SetReclaimable(false)
    ScenarioInfo.M7_FauxUEFCommanderUnit:SetCapturable(false)
    ScenarioFramework.CreateUnitDeathTrigger(M7_FauxUEFCommanderKilled, ScenarioInfo.M7_FauxUEFCommanderUnit)

    local fauxUEFInitPatrol = ScenarioUtils.CreateArmyGroupAsPlatoon('FauxUEF', 'M7_FauxUEF_InitalPatrol', 'NoFormation')
    ScenarioFramework.PlatoonPatrolChain(fauxUEFInitPatrol  , 'FauxUEF_Air_Patrol_Chain1')

    -- Rhiza base
    ScenarioInfo.M7_RhizaCommanderUnit = ScenarioUtils.CreateArmyUnit('Rhiza', 'Rhiza_Commander')
    ScenarioInfo.M7_RhizaCommanderUnit:CreateEnhancement('Shield')
    ScenarioInfo.M7_RhizaCommanderUnit:SetReclaimable(false)
    ScenarioInfo.M7_RhizaCommanderUnit:SetCapturable(false)
    ScenarioInfo.M7_RhizaCommanderUnit:SetCanBeKilled(false)
    for i = 1, 3 do
        IssuePatrol({ScenarioInfo.M7_RhizaCommanderUnit}, ScenarioUtils.MarkerToPosition('M7_Rhiza_BasePatrol_'..i))
    end
    ScenarioInfo.M7_RhizaCommanderUnit:SetCustomName(LOC '{i CDR_Rhiza}')

    local rhizaDef = ScenarioUtils.CreateArmyGroup('Rhiza', 'M7_RhizaBase_Defense')
    local rhizaProd = ScenarioUtils.CreateArmyGroup('Rhiza', 'M7_RhizaBase_Production')
    local rhizaFact = ScenarioUtils.CreateArmyGroup('Rhiza', 'M7_RhizaBase_Factories')
    local rhizaInEng = ScenarioUtils.CreateArmyGroup('Rhiza', 'M7_Rhiza_InitialEngineers')
    SetGroupFlags(rhizaDef)     -- disable cap/reclaim on these units
    SetGroupFlags(rhizaProd)
    SetGroupFlags(rhizaFact)
    SetGroupFlags(rhizaInEng)

    local rhizaInitPatrol = ScenarioUtils.CreateArmyGroupAsPlatoon('Rhiza', 'M7_Rhiza_InitalPatrol', 'NoFormation')
    ScenarioFramework.PlatoonPatrolChain(rhizaInitPatrol  , 'Rhiza_Init_Attack_Chain')

    -- General UEF
    ScenarioUtils.CreateArmyGroup('UEF', 'M7_UEF_Defensive')

    -- Main Island
    ScenarioUtils.CreateArmyGroup('UEF', 'M7_UEFMain_Defense_'..DifficultyConc)
    ScenarioUtils.CreateArmyGroup('UEF', 'M7_UEFMain_Production_'..DifficultyConc)
    ScenarioUtils.CreateArmyGroup('UEF', 'M7_UEFMain_Walls_'..DifficultyConc)
    if ScenarioInfo.Difficulty == 3 then
        -- Bunch of assisting engineers on hard
        ScenarioUtils.CreateArmyGroup('UEF', 'M7_UEFMain_InitialEngineers_'..DifficultyConc)
    end

    ScenarioInfo.UEFSubCommander = ScenarioUtils.CreateArmyUnit('UEF', 'UEF_SubCommander')
    ScenarioInfo.UEFSubCommander:SetCustomName(LOC '{i CDR_Berry}')
    ScenarioInfo.UEFSubCommander:SetCapturable(false)
    M7_SubCommanderPatrol() -- Send commander on patrol

    ScenarioInfo.UEFAntiAirUnits = ScenarioUtils.CreateArmyGroup('UEF', 'M7_UEFMain_Objective') -- objective aa etc
    ScenarioInfo.UEFAntiAirNumber = table.getn(ScenarioInfo.UEFAntiAirUnits)

    ScenarioInfo.UefSpecialDef = ScenarioUtils.CreateArmyGroup('UEF', 'M7_UEF_SpecialDefGroups') -- non objective AA, torpedo, etc
    for k,v in ScenarioInfo.UefSpecialDef do
        v:SetReclaimable(false)
        v:SetCapturable(false)
        v:SetCanBeKilled(false)
    end

    -- Naval groups, patrols - Main Island. Set the frigates to not use spoofing, so the scene isnt too overwhelming.
    ScenarioInfo.M7UEF_FrigatePlatoon1 = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M7_UEF_Naval_FrigateGroup1_'..DifficultyConc, 'AttackFormation')
    ScenarioInfo.M7UEF_FrigatePlatoon2 = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M7_UEF_Naval_FrigateGroup2_'..DifficultyConc, 'AttackFormation')
    ScenarioInfo.M7UEF_FrigatePlatoon3 = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M7_UEF_Naval_FrigateGroup3_'..DifficultyConc, 'AttackFormation')
    ScenarioInfo.M7UEF_CruiserPlatoon  = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M7_UEF_Naval_CruiserGroup_'..DifficultyConc, 'AttackFormation' )

    local frigateGroup1 = ScenarioInfo.M7UEF_FrigatePlatoon1:GetPlatoonUnits()
    local frigateGroup2 = ScenarioInfo.M7UEF_FrigatePlatoon2:GetPlatoonUnits()
    local frigateGroup3 = ScenarioInfo.M7UEF_FrigatePlatoon3:GetPlatoonUnits()

    M7_ToggleSpoofing(frigateGroup1)
    M7_ToggleSpoofing(frigateGroup2)
    M7_ToggleSpoofing(frigateGroup3)

    ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.M7UEF_FrigatePlatoon1 , 'M7_UEFNaval_Chain1' )
    ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.M7UEF_FrigatePlatoon2 , 'M7_UEFNaval_Chain2' )
    ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.M7UEF_FrigatePlatoon3 , 'M7_UEFNaval_Chain3' )
    ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.M7UEF_CruiserPlatoon  , 'M7_UEFCruiser_Chain')

    -- Air groups, patrols  - Main Island
    ScenarioInfo.M7UEF_AirPlatoon1 = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M7_UEF_AirPatrol1_'..DifficultyConc, 'NoFormation')
    ScenarioInfo.M7UEF_AirPlatoon2 = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M7_UEF_AirPatrol2_'..DifficultyConc, 'NoFormation')
    ScenarioInfo.M7UEF_AirPlatoon3 = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M7_UEF_AirPatrol3_'..DifficultyConc, 'NoFormation')
    ScenarioInfo.M7UEF_AirPlatoon4 = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M7_UEF_AirPatrol4_'..DifficultyConc, 'NoFormation' )

    ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.M7UEF_AirPlatoon1 , 'M7_UEFAir_North_Chain')
    ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.M7UEF_AirPlatoon2 , 'M7_UEFAir_North_Chain')
    ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.M7UEF_AirPlatoon3 , 'M7_UEFAir_South_Chain')
    ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.M7UEF_AirPlatoon4 , 'M7_UEFAir_South_Chain')

    -- Naval Base, objective units, and it's patrols
    ScenarioInfo.M7NavalBase_ObjectiveUnits = ScenarioUtils.CreateArmyGroup('UEF', 'M7_UEF_Naval_Objective')
    local navalBaseDef = ScenarioUtils.CreateArmyGroup('UEF', 'M7_UEF_Naval_Defense_'..DifficultyConc)
    local navalBaseProd = ScenarioUtils.CreateArmyGroup('UEF', 'M7_UEF_Naval_Production')
    local navalBaseWalls = ScenarioUtils.CreateArmyGroup('UEF', 'M7_UEF_Naval_Walls')

    if ScenarioInfo.Difficulty == 3 then -- factory assisting engineers only on hard diff
        local navalBaseEng = ScenarioUtils.CreateArmyGroup('UEF', 'M7_UEFNavalBase_InitialEngineers_Strong')
        M7_CreateUnitDeathTriggerNaval(navalBaseEng)

        local hardAttack = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M7_UEFNavalBase_Patrol3_Hard', 'AttackFormation')
        ScenarioFramework.PlatoonPatrolChain(hardAttack , 'M7_UEFNaval_InitialAttack_Chain')
    end

    local navalBasePatrol1 = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M7_UEFNavalBase_Patrol1_'..DifficultyConc, 'AttackFormation')
    local navalBasePatrol2 = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M7_UEFNavalBase_Patrol2_'..DifficultyConc, 'AttackFormation' )
    local navalBasePatrolUnits1 = navalBasePatrol1:GetPlatoonUnits()
    local navalBasePatrolUnits2 = navalBasePatrol2:GetPlatoonUnits()
 -- local navalBasePatrolUnits2 = navalBasePatrol2:GetPlatoonUnits() #not using the back/east patrol, for now
    ScenarioFramework.PlatoonPatrolChain(navalBasePatrol1 , 'M7_UEFNavalBase_Chain1')
    ScenarioFramework.PlatoonPatrolChain(navalBasePatrol2 , 'M7_UEFNavalBase_Chain2')

    M7_ToggleSpoofing(navalBasePatrolUnits1)
    M7_ToggleSpoofing(navalBasePatrolUnits2)

    M7_CreateUnitDeathTriggerNaval(navalBaseDef)
    M7_CreateUnitDeathTriggerNaval(navalBaseProd)
    M7_CreateUnitDeathTriggerNaval(navalBaseWalls)
    M7_CreateUnitDeathTriggerNaval(navalBasePatrolUnits1) -- just the western group

    -- Air base, objective units, and it's patrols
    ScenarioInfo.M7AirBase_ObjectiveUnits = ScenarioUtils.CreateArmyGroup('UEF', 'M7_UEF_AirBase_Objective')
    local airBaseDef = ScenarioUtils.CreateArmyGroup('UEF', 'M7_UEF_AirBase_Defense_'..DifficultyConc)
    local airBaseProd = ScenarioUtils.CreateArmyGroup('UEF', 'M7_UEF_AirBase_Production')
    local airBaseWalls = ScenarioUtils.CreateArmyGroup('UEF', 'M7_UEF_AirBase_Walls')


    if ScenarioInfo.Difficulty == 3 then -- factory assisting engineers only on hard diff
        local airBaseEng = ScenarioUtils.CreateArmyGroup('UEF', 'M7_UEF_AirBase_InitialEngineers_Strong')
        M7_CreateUnitDeathTriggerAir(airBaseEng)
    end

    local airBasePatrol1 = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M7_UEFAirBase_Patrol1_'..DifficultyConc, 'NoFormation')
    local airBasePatrolUnits1 = airBasePatrol1:GetPlatoonUnits()
    ScenarioFramework.PlatoonPatrolChain(airBasePatrol1 , 'M7_UEFAir_Chain1')

    M7_CreateUnitDeathTriggerAir(airBaseDef)
    M7_CreateUnitDeathTriggerAir(airBaseProd)
    M7_CreateUnitDeathTriggerAir(airBaseWalls)
    M7_CreateUnitDeathTriggerAir(airBasePatrolUnits1)

    -- Set up objectives
    ScenarioFramework.CreateTimerTrigger(M7_Objectives, 4) -- slight pause before we assign

    -- Delay the start of has hard-diff builders a bit, so we transition into full attacks
    ScenarioFramework.CreateTimerTrigger(M7_FlagNavalBuild, 260)
    ScenarioFramework.CreateTimerTrigger(M7_FlagAirBuild, 105)
end

function M7_FlagNavalBuild()
    ScenarioInfo.VarTable['M7_BeginNavalBuild'] = true
end

function M7_FlagAirBuild()
    ScenarioInfo.VarTable['M7_BeginAirBuild']   = true
end


function M6_HardPatrolToPlayer()
    ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.M6_UEFHard_Air , 'M6_UEFAir_AttackPatrol_Hard_Chain')
end

function M7_ToggleSpoofing(units)
    for k,v in units do
        if EntityCategoryContains(categories.ues0103, v) then
            v:ToggleScriptBit('RULEUTC_JammingToggle')
        end
    end
end

function M7_Objectives()
    ScenarioFramework.CreateTimerTrigger(M7P2Reminder1 ,ReminderInitialTime1)

    -- Primary: Destroy the AA units
    ScenarioInfo.M7P2 = Objectives.KillOrCapture(
        'primary',                      -- type
        'incomplete',                   -- complete
        OpStrings.M7P2Text,             -- title
        OpStrings.M7P2Detail,           -- description
        {                               -- target
            Units = ScenarioInfo.UEFAntiAirUnits,
            FlashVisible = true,
        }
   )
    ScenarioInfo.M7P2:AddResultCallback(
        function(result, unit)

--        AA guns destroyed -- commenting out for more CZAR loving
--        local camInfo = {
--            blendTime = 1.0,
--            holdTime = 5,
--            orientationOffset = { -1.38, 0.3, 0 },
--            positionOffset = { 0, 0.5, 0 },
--            zoomVal = 35,
--        }
--        ScenarioFramework.OperationNISCamera(unit, camInfo)

            ScenarioInfo.M7P2Complete = true
        end
   )
    ScenarioInfo.M7P2:AddProgressCallback(M7_CreateCzar)

    -- Primary: Destroy the Subcommander
  -- local m7bObjectives = Objectives.CreateGroup('Mission7b', EndOperationCounter)
    ScenarioInfo.M7P3 = Objectives.KillOrCapture(
        'primary',                      -- type
        'incomplete',                   -- complete
        OpStrings.M7P3Text,             -- title
        OpStrings.M7P3Detail,           -- description
        {                               -- target
            Units = {ScenarioInfo.UEFSubCommander},
        }
   )
    ScenarioInfo.M7P3:AddResultCallback(
        function(result, unit)
            ScenarioInfo.M7P3Complete = true
            ScenarioInfo.SubCommanderDead = true
            EndOperationCounter()
            if EndOperationCount < 3 then
                ScenarioFramework.Dialogue(OpStrings.A01_M07_110)

-- Kill subcommander and continue op cam
                ScenarioFramework.CDRDeathNISCamera(unit, 7)
            else
-- Kill subcommander and end op cam
--            ScenarioFramework.EndOperationCamera(unit)
                ScenarioFramework.CDRDeathNISCamera(unit)
            end
        end
   )
 -- m7bObjectives:AddObjective(ScenarioInfo.M7P3)

    -- Secondary: Destroy the Air base
    ScenarioInfo.M7S1 = Objectives.KillOrCapture(
        'secondary',                    -- type
        'incomplete',                   -- complete
        OpStrings.M7S1Text,             -- title
        OpStrings.M7S1Detail,           -- description
        {                               -- target
            Units = ScenarioInfo.M7AirBase_ObjectiveUnits,
        }
   )
    ScenarioInfo.M7S1:AddResultCallback(
        function(result)
            ScenarioInfo.M7S1Complete = true

-- airbase destroyed cam
            local camInfo = {
                blendTime = 1.0,
                holdTime = 4,
                orientationOffset = { 2.7, 0.1, 0 },
                positionOffset = { 0, 0.5, 0 },
                zoomVal = 25,
                markerCam = true,
            }
            ScenarioFramework.OperationNISCamera(ScenarioUtils.MarkerToPosition("NIS_Airbase_Destroyed"), camInfo)

            if not ScenarioInfo.SubCommanderDead then
                ScenarioFramework.Dialogue(OpStrings.A01_M07_130)
            end
            ScenarioFramework.CreateTimerTrigger(M7_PostAirTaunt, 8) -- taunt, delayed a tad
        end
   )
    ScenarioInfo.M7S1:AddProgressCallback(M7_NavalPatrolsChange)-- increment counter, to make naval patrols shift

    -- Secondary: Destroy the Naval base
    ScenarioInfo.M7S2 = Objectives.KillOrCapture(
        'secondary',                    -- type
        'incomplete',                   -- complete
        OpStrings.M7S2Text,             -- title
        OpStrings.M7S2Detail,           -- description
        {                               -- target
            Units = ScenarioInfo.M7NavalBase_ObjectiveUnits,
        }
   )
    ScenarioInfo.M7S2:AddResultCallback(
        function(result)
            ScenarioInfo.M7S2Complete = true

-- naval base destroyed cam
            local camInfo = {
                blendTime = 1.0,
                holdTime = 4,
                orientationOffset = { 2.67, 0.4, 0 },
                positionOffset = { 0, 0.5, 0 },
                zoomVal = 55,
                markerCam = true,
            }
            ScenarioFramework.OperationNISCamera(ScenarioUtils.MarkerToPosition("NIS_Navalbase_Destroyed"), camInfo)

            ScenarioFramework.Dialogue(OpStrings.A01_M07_140)
            ScenarioFramework.CreateTimerTrigger(M7_PostNavalTaunt, 8) -- taunt, delayed a tad
            ScenarioFramework.CreateTimerTrigger(M7_AirPatrolsReturn, 20) -- Air patrols will revert to patroling the main island after a pause
        end
   )
    ScenarioInfo.M7S2:AddProgressCallback(M7_AirPatrolsChange) -- increment counter, to make air patrols shift
end

function M7_SubCommanderPatrol()
    if (not ScenarioInfo.UEFSubCommander:IsDead()) then
        -- clear cmds, assign patrol
        IssueStop({ScenarioInfo.UEFSubCommander})
        IssueClearCommands({ScenarioInfo.UEFSubCommander})
        for i = 1, 3 do -- patrol for cdr
            IssuePatrol({ScenarioInfo.UEFSubCommander}, ScenarioUtils.MarkerToPosition('M7_UEFCommander_Patrol'..i))
        end

        -- Every 35 seconds, re call this thread, incase SubCDR gets stuck on stuff.
        ScenarioFramework.CreateTimerTrigger(M7_SubCommanderPatrol, 35)
    end
end

function M7_UnlockAirDialogueDelay()
    ScenarioFramework.CreateTimerTrigger(M7_UnlockAirDialogue, 7)
end

function M7_UnlockAirDialogue()
    ScenarioFramework.Dialogue(OpStrings.A01_M07_020)
    BuildCategories7_AirFact()
end

function M7_PostNavalTaunt()
    if ScenarioInfo.SubCommanderDead == false then
        ScenarioFramework.Dialogue(OpStrings.TAUNT1)
    end
end

function M7_PostAirTaunt()
    if ScenarioInfo.SubCommanderDead == false then
        ScenarioFramework.Dialogue(OpStrings.TAUNT3)
    end
end

function M7_CreateUnitDeathTriggerNaval(group)
    for num, unit in group do
        ScenarioFramework.CreateUnitDeathTrigger(M7_AirPatrolsChange, unit)
    end
end

function M7_CreateUnitDeathTriggerAir(group)
    for num, unit in group do
        ScenarioFramework.CreateUnitDeathTrigger(M7_NavalPatrolsChange, unit)
    end
end

function M7_NavalPatrolsChange()
    M7_NavalPatrolCount = M7_NavalPatrolCount + 1
    -- When four or so bits of the Air base are destroyed, send in the naval units
    if M7_NavalPatrolCount == M7_NavalPatrolThresh then
        -- Clear commands of the 3 frigate groups
        if ArmyBrains[UEF]:PlatoonExists(ScenarioInfo.M7UEF_FrigatePlatoon1) then ScenarioInfo.M7UEF_FrigatePlatoon1:Stop() end
        if ArmyBrains[UEF]:PlatoonExists(ScenarioInfo.M7UEF_FrigatePlatoon2) then ScenarioInfo.M7UEF_FrigatePlatoon2:Stop() end
        if ArmyBrains[UEF]:PlatoonExists(ScenarioInfo.M7UEF_FrigatePlatoon3) then ScenarioInfo.M7UEF_FrigatePlatoon3:Stop() end

        -- Give them a new patrol chain, that takes them around the western UEF base.
        if ArmyBrains[UEF]:PlatoonExists(ScenarioInfo.M7UEF_FrigatePlatoon1) then
            ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.M7UEF_FrigatePlatoon1 , 'M7_UEFNaval_Alt_Chain' ) end
        if ArmyBrains[UEF]:PlatoonExists(ScenarioInfo.M7UEF_FrigatePlatoon2) then
            ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.M7UEF_FrigatePlatoon2 , 'M7_UEFNaval_Alt_Chain2' ) end
        if ArmyBrains[UEF]:PlatoonExists(ScenarioInfo.M7UEF_FrigatePlatoon3) then
            ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.M7UEF_FrigatePlatoon3 , 'M7_UEFNaval_Alt_Chain' ) end

        -- Play dialogue, after a delay, confirming the effect
        ForkThread(M7_NavalPatrolChangeDialogueThread)
    end
end

function M7_AirPatrolsChange()
    M7_AirPatrolCount = M7_AirPatrolCount + 1
    -- When three or so bits of the Naval base are destroyed, send in the air units
    if M7_AirPatrolCount == M7_AirPatrolThresh then
        -- Clear commands of the 3 frigate groups
        if ArmyBrains[UEF]:PlatoonExists(ScenarioInfo.M7UEF_AirPlatoon1) then ScenarioInfo.M7UEF_AirPlatoon1:Stop() end
        if ArmyBrains[UEF]:PlatoonExists(ScenarioInfo.M7UEF_AirPlatoon2) then ScenarioInfo.M7UEF_AirPlatoon2:Stop() end
      -- if ArmyBrains[UEF]:PlatoonExists(ScenarioInfo.M7UEF_AirPlatoon3) then ScenarioInfo.M7UEF_AirPlatoon3:Stop() end    #lets leave one group at the island.
        if ArmyBrains[UEF]:PlatoonExists(ScenarioInfo.M7UEF_AirPlatoon4) then ScenarioInfo.M7UEF_AirPlatoon4:Stop() end

        -- Give them a new patrol chain, that takes them around the western UEF base.
        if ArmyBrains[UEF]:PlatoonExists(ScenarioInfo.M7UEF_AirPlatoon1) then
            ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.M7UEF_AirPlatoon1 , 'M7_UEFAir_Alt_Chain' ) end
        if ArmyBrains[UEF]:PlatoonExists(ScenarioInfo.M7UEF_AirPlatoon2) then
            ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.M7UEF_AirPlatoon2 , 'M7_UEFAir_Alt_Chain' ) end
     -- if ArmyBrains[UEF]:PlatoonExists(ScenarioInfo.M7UEF_AirPlatoon3) then
     --  ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.M7UEF_AirPlatoon3 , 'M7_UEFAir_Alt_Chain' ) end             #leave one group at the island
        if ArmyBrains[UEF]:PlatoonExists(ScenarioInfo.M7UEF_AirPlatoon4) then
            ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.M7UEF_AirPlatoon4 , 'M7_UEFAir_Alt_Chain' ) end

        -- Play dialogue, after a delay, confirming the effect
        ForkThread(M7_AirPatrolChangeDialogueThread)
    end
end

function M7_AirPatrolsReturn()
    -- Once the Naval 2ndry obj has been completed, the air units who switched their patrol to their will return to the main island.
    -- Clear commands of the 3 patrol groups
    if ArmyBrains[UEF]:PlatoonExists(ScenarioInfo.M7UEF_AirPlatoon1) then ScenarioInfo.M7UEF_AirPlatoon1:Stop() end
    if ArmyBrains[UEF]:PlatoonExists(ScenarioInfo.M7UEF_AirPlatoon2) then ScenarioInfo.M7UEF_AirPlatoon2:Stop() end
    if ArmyBrains[UEF]:PlatoonExists(ScenarioInfo.M7UEF_AirPlatoon4) then ScenarioInfo.M7UEF_AirPlatoon4:Stop() end

    -- Back to the main island patrol, if they are still around
    if ArmyBrains[UEF]:PlatoonExists(ScenarioInfo.M7UEF_AirPlatoon1) then
        ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.M7UEF_AirPlatoon1 , 'M7_UEFAir_North_Chain' ) end
    if ArmyBrains[UEF]:PlatoonExists(ScenarioInfo.M7UEF_AirPlatoon2) then
        ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.M7UEF_AirPlatoon2 , 'M7_UEFAir_North_Chain' ) end
    if ArmyBrains[UEF]:PlatoonExists(ScenarioInfo.M7UEF_AirPlatoon4) then
        ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.M7UEF_AirPlatoon4 , 'M7_UEFAir_South_Chain' ) end
end

function M7_BerryBanterDialogue()
    if not ScenarioInfo.SubCommanderDead then
        ScenarioFramework.Dialogue(OpStrings.A01_M07_100)
    end
end

function M7_AirPatrolChangeDialogueThread()
    WaitSeconds(4)
    if ScenarioInfo.SubCommanderDead == false then
        ScenarioFramework.Dialogue(OpStrings.TAUNT2)
    end

    -- If the Czar has not yet spawned, then its appropriate to play a confirmation
    -- that the UEF is moving response units to the player
    if not ScenarioInfo.CzarSpawned then
        ScenarioFramework.Dialogue(OpStrings.A01_M07_060)
    end
end

function M7_NavalPatrolChangeDialogueThread()
    WaitSeconds(4)
    if ScenarioInfo.SubCommanderDead == false then
        ScenarioFramework.Dialogue(OpStrings.TAUNT6)
    end
    -- If the AA has not yet spawned, then its appropriate to play a confirmation
    -- that the UEF is moving response units to the player
    if not ScenarioInfo.CzarSpawned then
        ScenarioFramework.Dialogue(OpStrings.A01_M07_070)
    end
end

function M7_CreateCzar()
    M7_AADeathCount = M7_AADeathCount + 1
    if M7_AADeathCount == 4 then
        -- Let the secondary objective dialogue functions know that the Czar is out (ie, the player is not experiencing
        -- a problem with the defense of the base).
        ScenarioInfo.CzarSpawned = true
        -- Create Czar as platoon, and get a handle it to it as a unit
        ScenarioInfo.RhizaCzarPlat = ScenarioUtils.CreateArmyGroupAsPlatoon('FauxRhiza', 'M7_Czar', 'ChevronFormation')
        ScenarioInfo.RhizaCzar = ScenarioInfo.UnitNames[FauxRhiza]['Rhiza_Czar']

        -- Temporarily set czar viz radius to zero, so we dont have any vis to share with player ally
        ScenarioInfo.RhizaCzar:SetIntelRadius('Vision', 0)

        -- Make a platoon to place the aircraft in. Spawn in a 5-unit group multiple times, each time adding
        -- this group to the platoon, clearing the commands of each unit, and loading each unit onto the Czar.
        ScenarioInfo.CzarAircraftPlatoon = ArmyBrains[FauxRhiza]:MakePlatoon(' ', ' ')
        for i = 1,15 do
            local group = ScenarioUtils.CreateArmyGroup('FauxRhiza', 'M7_CzarAircraft')
    	    ArmyBrains[FauxRhiza]:AssignUnitsToPlatoon(ScenarioInfo.CzarAircraftPlatoon, group, 'Attack', 'ChevronFormation')
            for k,unit in group do
                IssueStop({unit})
                ScenarioInfo.RhizaCzar:AddUnitToStorage(unit)
            end
        end

        -- Due to it's size, and location, get its position and warp it west - there isnt enough space for it to spawn
        -- without peeking into the playable area.
        local czarLocation = ScenarioInfo.RhizaCzar:GetPosition()
        Warp(ScenarioInfo.RhizaCzar, {czarLocation[1] - 535, czarLocation[2], czarLocation[3]})

        -- Override the Czars OnDamage to just reduce it's health by X, if it is still greater than Y.
        -- Set it to not reclaimable, cap, killable.
        ScenarioInfo.RhizaCzar.OnDamage = function(self, instigator)
            if self:GetHealth() > 604 then
                self:AdjustHealth(instigator, -4)
            end
        end

        ScenarioInfo.RhizaCzar:SetReclaimable(false)
        ScenarioInfo.RhizaCzar:SetCapturable(false)
        ScenarioInfo.RhizaCzar:SetCanBeKilled(false)

        -- reset czar viz radius back to bp default
        local bpIntel = ScenarioInfo.RhizaCzar:GetBlueprint().Intel
        ScenarioInfo.RhizaCzar:SetIntelRadius('Vision', bpIntel.VisionRadius)

        -- Move to the holding location, where it will hang out waiting for some AA to get destroyed
        -- (this is to speed up the wait for when the player finishes obj's, and the FausUEF cdr is destroyed)
        ScenarioInfo.RhizaCzarPlat:MoveToLocation(ScenarioUtils.MarkerToPosition('RhizaCzar_Move1'), false)

        -- Play a taunt
        if ScenarioInfo.SubCommanderDead == false then
            ScenarioFramework.Dialogue(OpStrings.TAUNT5)
        end
    end

    -- When player is nearing the end of the AA units, move the Czar in a little closer, to further cut down on final travel time.
    -- Play an enemy taunt here
    if M7_AADeathCount == (ScenarioInfo.UEFAntiAirNumber - 3) then
        ScenarioInfo.RhizaCzarPlat:MoveToLocation(ScenarioUtils.MarkerToPosition('RhizaCzar_Move2'), false)
        if ScenarioInfo.SubCommanderDead == false then
            ScenarioFramework.Dialogue(OpStrings.TAUNT4)
        end
    end

    -- Now that an acceptable amount of objective AA is down, send in the Czar from its holding point.
    -- If the UEF commander is already killed by the player (unlikely, but possible), then do an appropriate
    -- set of things instead.
    if M7_AADeathCount == (ScenarioInfo.UEFAntiAirNumber - 0) then -- Set this 0 to some value if we dont mind the player not completely destroying all AA. If greater than zero, we should manuall compelete this objective here.
        ScenarioFramework.Dialogue(OpStrings.A01_M07_112)-- Rhiza, obj complete

-- CZAR starts final attack camera
        local camInfo = {
            blendTime = 1.0,
            holdTime = 4,
            orientationOffset = { 0, 0.6, 0 },
            positionOffset = { 10, 0, 0 },
            zoomVal = 150,
        }
        ScenarioFramework.OperationNISCamera(ScenarioInfo.RhizaCzar, camInfo)

        -- If the other primary obj is done, Assign an objective to fill the gap, so the player always has an ojective.
        if ScenarioInfo.M7P3Complete == true then
            ScenarioInfo.AssistCzarAssigned = true
            ScenarioInfo.M7P4 = Objectives.Basic(
                'primary',
                'incomplete',
                OpStrings.M7P4Text,
                OpStrings.M7P4Detail,
                Objectives.GetActionIcon('protect'),
                {
                    Units = {ScenarioInfo.RhizaCzar},
                }
           )
        end
        if (not ScenarioInfo.M7_FauxUEFCommanderUnit:IsDead()) then
            -- Move to edge of island, queue unload of the aircraft being carried, and start a check for when that unload is done
            ScenarioInfo.CzarMoveCommand = ScenarioInfo.RhizaCzarPlat:MoveToLocation(ScenarioUtils.MarkerToPosition('RhizaCzar_Move3'), false)
            ForkThread(M7_CzarAircraftMoveThread)
            ScenarioInfo.CzarUnloadCommand = ScenarioInfo.RhizaCzarPlat:UnloadAllAtLocation(ScenarioUtils.MarkerToPosition('RhizaCzar_Move3'))
            ForkThread(M7_CzarAircraftAttackThread)

            -- Because the FauxUEF CDR isnt dead, tell the Czar to attack him, make a failsafe timer in case he get stuck or fails
            -- to die for some reason, and start a thread that will send the czar on a patrol once the cdr is dead.
            ScenarioInfo.CzarAttackCDRCommand = ScenarioInfo.RhizaCzarPlat:AttackTarget(ScenarioInfo.M7_FauxUEFCommanderUnit)
            ScenarioFramework.CreateTimerTrigger(M7_FauxUEFCommanderKilled, 173) -- either the commander dies, or this trigger fires, to ultimately increment the End Op counter.
            ForkThread(M7_CzarPatrolCheckThread)

            -- We also need to increment the End Op counter for the "Czar hung out at enemy base" event as well, which in this case
            -- is happening concurrently with the attack against the FauxUEF CDR. This is a token amount of time, because in our
            -- case now, with the enemy CDR still alive, his death will end the Op - instead of a theatrical hanging-out of the Czar
            -- at the FauxUEF main base area.
            ScenarioFramework.CreateTimerTrigger(EndOperationCounter, 60)
        end
        if ScenarioInfo.M7_FauxUEFCommanderUnit:IsDead() then
            -- Move to edge of island, queue unload of the aircraft being carried, and start a check for when that unload is done
            ScenarioInfo.CzarMoveCommand = ScenarioInfo.RhizaCzarPlat:MoveToLocation(ScenarioUtils.MarkerToPosition('RhizaCzar_Move3'), false)
            ForkThread(M7_CzarAircraftMoveThread)
            ScenarioInfo.CzarUnloadCommand = ScenarioInfo.RhizaCzarPlat:UnloadAllAtLocation(ScenarioUtils.MarkerToPosition('RhizaCzar_Move3'))
            ForkThread(M7_CzarAircraftAttackThread)

            -- If the UEF Main Commander is already dead, then send in the Czar on a patrol to mess things up a bit. Start
            -- a timer that will increment the End Op counter after the Czar has had some time to trash the FauxUEF base.
            ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.RhizaCzarPlat, 'M7_FauxRhiza_CzarUnits_Chain1')
            ScenarioFramework.CreateTimerTrigger(EndOperationCounter, 135)
        end

        -- Now that we are at this point in the Op, its ok to let the player mess with the UEF/FauxUEF defenses designed to keep player out.
        for k,v in ScenarioInfo.UefSpecialDef do
            if (not v:IsDead()) then
                v:SetReclaimable(true)
                v:SetCapturable(true)
                v:SetCanBeKilled(true)
            end
        end
        for k,v in ScenarioInfo.FauxUEF_SpecialDef do
            if (not v:IsDead()) then
                v:SetReclaimable(true)
                v:SetCapturable(true)
                v:SetCanBeKilled(true)
            end
        end

        -- Play a taunt
        if ScenarioInfo.SubCommanderDead == false then
            ScenarioFramework.Dialogue(OpStrings.TAUNT7)
        end
    end
end

function M7_CzarAircraftMoveThread()
    while ScenarioInfo.RhizaCzarPlat:IsCommandsActive(ScenarioInfo.CzarMoveCommand) == true do
        WaitSeconds(1)
    end

-- CZAR unload air attack camera
    local camInfo = {
        blendTime = 1.0,
        holdTime = 10,
        orientationOffset = { math.pi, 0.35, 0 },
        positionOffset = { 0, -5, 0 },
        zoomVal = 175,
    }
    ScenarioFramework.OperationNISCamera(ScenarioInfo.RhizaCzar, camInfo)
end

function M7_CzarAircraftAttackThread()
    while ScenarioInfo.RhizaCzarPlat:IsCommandsActive(ScenarioInfo.CzarUnloadCommand) == true do
        WaitSeconds(1)
    end
    WaitSeconds(3)
    ScenarioInfo.CzarAircraftPlatoon:Stop()
    ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.CzarAircraftPlatoon, 'M7_FauxRhiza_CzarUnits_Chain1')
end

function M7_CzarPatrolCheckThread()
    while not ScenarioInfo.FauxUEFCommanderKilled do
        WaitSeconds(3)
    end
    -- Once the FauxUEF Main Commander is dead, send the Czar on a patrol.
    ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.RhizaCzarPlat, 'M7_FauxRhiza_CzarUnits_Chain1')
end

function M7_FauxUEFCommanderKilled()
    -- Two events will potentially call this, so make sure we only increment once for the Main CDR Killed events
    -- (ie, killed, or "got stuck so the failsafe timer kicked in instead")
    if not ScenarioInfo.FauxUEFCommanderKilled then
        ScenarioInfo.FauxUEFCommanderKilled = true
        EndOperationCounter()

            if EndOperationCount < 3 then
                ScenarioFramework.Dialogue(OpStrings.A01_M07_110)
-- Kill Commander and continue op cam
                ScenarioFramework.CDRDeathNISCamera(ScenarioInfo.M7_FauxUEFCommanderUnit, 7)
            else
-- Kill Commander and end op cam
                ScenarioFramework.CDRDeathNISCamera(ScenarioInfo.M7_FauxUEFCommanderUnit)
            end
    end
end

function EndOperationCounter()
    EndOperationCount = EndOperationCount + 1

    -- If the SubCommander is dead, the FauxUEF Main Commander is dead, and the Czar has hung out at the main base a bit,
    if EndOperationCount == 3 then
        if not ScenarioInfo.OperationEnding then
            ScenarioInfo.OperationEnding = true
            ScenarioFramework.KillBaseInArea(ArmyBrains[FauxUEF], 'Final_FauxUEF_DestroyArea')
            ScenarioFramework.KillBaseInArea(ArmyBrains[UEF], 'Final_FauxUEF_DestroyArea')

            -- Dialogue etc. May want to fork off of a dialogue callback instead of what's below
            if ScenarioInfo.AssistCzarAssigned == true then
                ScenarioInfo.M7P4:ManualResult(true)
            end
            if ScenarioInfo.SubCommanderDead then
                -- if subcommander and fauxcommander are dead and CZAR is bored
--            ScenarioFramework.EndOperationCamera(ScenarioInfo.RhizaCzar, true)
                local camInfo = {
                    blendTime = 2.5,
                    holdTime = nil,
                    orientationOffset = { 0, 0.9, 0 },
                    positionOffset = { 0, 0, 0 },
                    zoomVal = 150,
                    spinSpeed = 0.03,
                    overrideCam = true,
                }
                ScenarioFramework.OperationNISCamera(ScenarioInfo.RhizaCzar, camInfo)
            end
            ScenarioFramework.EndOperationSafety()
            ScenarioFramework.Dialogue(OpStrings.A01_M07_116, false, true) -- Rhiza: "Glorious!"
            ScenarioFramework.Dialogue(OpStrings.A01_M07_180, TriggerWinEnd, true)
        end
    end
end

function TriggerWinEnd()
    WaitSeconds(5)
    ForkThread(KillGame_Win)
end

-- ------------
-- Miscellaneous Functions
-- ------------

function SetGroupFlags(group)
    -- Sets a group of units to no cap/reclaim
    for k, v in group do
        if (not v:IsDead()) then
            v:SetReclaimable(false)
            v:SetCapturable(false)
        end
    end
end

 -- - Reminders
 -- - 1
function M1P1Reminder1()
    if not ScenarioInfo.M1P1Complete then
        ScenarioFramework.Dialogue(OpStrings.A01_M01_050)
        ScenarioFramework.CreateTimerTrigger(M1P1Reminder2, ReminderSubsequentTime1)
    end
end

function M1P1Reminder2()
    if not ScenarioInfo.M1P1Complete then
        ScenarioFramework.Dialogue(OpStrings.A01_M01_055)
        ScenarioFramework.CreateTimerTrigger(M1P1Reminder3, ReminderSubsequentTime1)
    end
end

function M1P1Reminder3()
    if not ScenarioInfo.M1P1Complete then
        ScenarioFramework.Dialogue(OpStrings.A01_M01_060) -- general
        ScenarioFramework.CreateTimerTrigger(M1P1Reminder1, ReminderSubsequentTime1)
    end
end

 -- - 1
function M1P2Reminder1()
    if not ScenarioInfo.M1P2Complete then
        ScenarioFramework.Dialogue(OpStrings.A01_M01_065)
        ScenarioFramework.CreateTimerTrigger(M1P2Reminder2, ReminderSubsequentTime1)
    end
end

function M1P2Reminder2()
    if not ScenarioInfo.M1P2Complete then
        ScenarioFramework.Dialogue(OpStrings.A01_M01_070)
        ScenarioFramework.CreateTimerTrigger(M1P2Reminder3, ReminderSubsequentTime1)
    end
end

function M1P2Reminder3()
    if not ScenarioInfo.M1P2Complete then
        ScenarioFramework.Dialogue(OpStrings.A01_M01_060) -- general
        ScenarioFramework.CreateTimerTrigger(M1P2Reminder1, ReminderSubsequentTime1)
    end
end

 -- - 2
function M2P1Reminder1()
    if(not ScenarioInfo.M2P1Complete) then
        ScenarioFramework.Dialogue(OpStrings.A01_M02_020)
        ScenarioFramework.CreateTimerTrigger(M2P1Reminder2, ReminderSubsequentTime1)
    end
end

function M2P1Reminder2()
    if(not ScenarioInfo.M2P1Complete) then
        ScenarioFramework.Dialogue(OpStrings.A01_M02_025)
        ScenarioFramework.CreateTimerTrigger(M2P1Reminder3, ReminderSubsequentTime1)
    end
end

function M2P1Reminder3()
    if(not ScenarioInfo.M2P1Complete) then
        ScenarioFramework.Dialogue(OpStrings.A01_M01_060)
        ScenarioFramework.CreateTimerTrigger(M2P1Reminder1, ReminderSubsequentTime1)
    end
end

 -- -  3
function M3P2Reminder1()
    if(not ScenarioInfo.M3P2Complete) then
        ScenarioFramework.Dialogue(OpStrings.A01_M03_030)
        ScenarioFramework.CreateTimerTrigger(M3P2Reminder2, ReminderSubsequentTime1)
    end
end

function M3P2Reminder2()
    if(not ScenarioInfo.M3P2Complete) then
        ScenarioFramework.Dialogue(OpStrings.A01_M03_020)
        ScenarioFramework.CreateTimerTrigger(M3P2Reminder3, ReminderSubsequentTime1)
    end
end

function M3P2Reminder3()
    if(not ScenarioInfo.M3P2Complete) then
        ScenarioFramework.Dialogue(OpStrings.A01_M01_060)
        ScenarioFramework.CreateTimerTrigger(M3P2Reminder1, ReminderSubsequentTime1)
    end
end

 -- - 4
function M4P1Reminder1()
    if(not ScenarioInfo.M4P1Complete) then
        ScenarioFramework.Dialogue(OpStrings.A01_M04_020)
        ScenarioFramework.CreateTimerTrigger(M4P1Reminder2, ReminderSubsequentTime1)
    end
end

function M4P1Reminder2()
    if(not ScenarioInfo.M4P1Complete) then
        ScenarioFramework.Dialogue(OpStrings.A01_M04_030)
        ScenarioFramework.CreateTimerTrigger(M4P1Reminder3, ReminderSubsequentTime1)
    end
end

function M4P1Reminder3()
    if(not ScenarioInfo.M4P1Complete) then
        ScenarioFramework.Dialogue(OpStrings.A01_M01_060)
        ScenarioFramework.CreateTimerTrigger(M4P1Reminder1, ReminderSubsequentTime1)
    end
end

 -- - 5
function M5P1Reminder1()
    if(not ScenarioInfo.M5P1Complete) then
        ScenarioFramework.Dialogue(OpStrings.A01_M05_020)
        ScenarioFramework.CreateTimerTrigger(M5P1Reminder2, ReminderSubsequentTime1)
    end
end

function M5P1Reminder2()
    if(not ScenarioInfo.M5P1Complete) then
        ScenarioFramework.Dialogue(OpStrings.A01_M05_025)
        ScenarioFramework.CreateTimerTrigger(M5P1Reminder3, ReminderSubsequentTime1)
    end
end

function M5P1Reminder3()
    if(not ScenarioInfo.M5P1Complete) then
        ScenarioFramework.Dialogue(OpStrings.A01_M01_060)
        ScenarioFramework.CreateTimerTrigger(M5P1Reminder1, ReminderSubsequentTime1)
    end
end

 -- - 6
function M6P1Reminder1()
    if(not ScenarioInfo.M6P1Complete) then
        ScenarioFramework.Dialogue(OpStrings.A01_M06_030)
        ScenarioFramework.CreateTimerTrigger(M6P1Reminder2, ReminderSubsequentTime2)
    end
end

function M6P1Reminder2()
    if(not ScenarioInfo.M6P1Complete) then
        ScenarioFramework.Dialogue(OpStrings.A01_M06_035)
        ScenarioFramework.CreateTimerTrigger(M6P1Reminder3, ReminderSubsequentTime2)
    end
end

function M6P1Reminder3()
    if(not ScenarioInfo.M6P1Complete) then
        ScenarioFramework.Dialogue(OpStrings.A01_M01_060)
        ScenarioFramework.CreateTimerTrigger(M6P1Reminder1, ReminderSubsequentTime2)
    end
end

 -- - 7
function M7P2Reminder1()
    if(not ScenarioInfo.M7P2Complete) then
        ScenarioFramework.Dialogue(OpStrings.A01_M07_160)
        ScenarioFramework.CreateTimerTrigger(M7P2Reminder2, ReminderSubsequentTime2)
    end
    if ScenarioInfo.M7P2Complete == true and ScenarioInfo.M7P3Complete == false then
        ScenarioFramework.CreateTimerTrigger(M7P3Reminder1, ReminderSubsequentTime2)
    end
end

function M7P2Reminder2()
    if(not ScenarioInfo.M7P2Complete) then
        ScenarioFramework.Dialogue(OpStrings.A01_M07_165)
        ScenarioFramework.CreateTimerTrigger(M7P2Reminder3, ReminderSubsequentTime2)
    end
    if ScenarioInfo.M7P2Complete == true and ScenarioInfo.M7P3Complete == false then
        ScenarioFramework.CreateTimerTrigger(M7P3Reminder1, ReminderSubsequentTime2)
    end
end

function M7P2Reminder3()
    if(not ScenarioInfo.M7P2Complete) then
        ScenarioFramework.Dialogue(OpStrings.A01_M01_060)
        ScenarioFramework.CreateTimerTrigger(M7P2Reminder1, ReminderSubsequentTime2)
    end
    if ScenarioInfo.M7P2Complete == true and ScenarioInfo.M7P3Complete == false then
        ScenarioFramework.CreateTimerTrigger(M7P3Reminder1, ReminderSubsequentTime2)
    end
end
 -- - 7
function M7P3Reminder1()
    if(not ScenarioInfo.M7P3Complete) then
        ScenarioFramework.Dialogue(OpStrings.A01_M07_170)
        ScenarioFramework.CreateTimerTrigger(M7P3Reminder2, ReminderSubsequentTime2)
    end
end

function M7P3Reminder2()
    if(not ScenarioInfo.M7P3Complete) then
        ScenarioFramework.Dialogue(OpStrings.A01_M07_175)
        ScenarioFramework.CreateTimerTrigger(M7P3Reminder3, ReminderSubsequentTime2)
    end
end

function M7P3Reminder3()
    if(not ScenarioInfo.M7P3Complete) then
        ScenarioFramework.Dialogue(OpStrings.A01_M01_060)
        ScenarioFramework.CreateTimerTrigger(M7P3Reminder1, ReminderSubsequentTime2)
    end
end

 -- - Build categories
function BuildCategories1()

    -- Initially lock all
    for _, player in ScenarioInfo.HumanPlayers do
         ScenarioFramework.AddRestriction(player, categories.ALLUNITS)
    end

    for _, player in ScenarioInfo.HumanPlayers do
         ScenarioFramework.RemoveRestriction(player, categories.uab1103 + -- Mass
                                         -- For use with captured UEF units
                                         categories.ueb1103 ) -- Mass
    end

    ScenarioFramework.RestrictEnhancements({'AdvancedEngineering',
                                            'ChronoDampener',
                                            'CrysalisBeam',
                                            'EnhancedSensors',
                                            'T3Engineering',
                                            'HeatSink',
                                            'ResourceAllocation',
                                            'ResourceAllocationAdvanced',
                                            'Shield',
                                            'Teleporter',
                                            'ShieldHeavy'})
end

function BuildCategories1b()
    ScenarioFramework.PlayUnlockDialogue()
    for _, player in ScenarioInfo.HumanPlayers do
         ScenarioFramework.RemoveRestriction(player, categories.uab1101 + -- Power Gen
     
                                         -- For use with captured UEF units
                                         categories.ueb1101 )
    end
end

function BuildCategories2()
    ScenarioFramework.PlayUnlockDialogue()
    for _, player in ScenarioInfo.HumanPlayers do
         ScenarioFramework.RemoveRestriction(player, categories.uab0103 + -- T1 Naval Factory
                                         categories.uab5101 + -- Wall
                                         categories.uab3101 + -- Radar
     
                                         -- For use with captured UEF units
                                         categories.ueb0103 + -- T1 Naval Factory
                                         categories.ueb5101 + -- Wall
                                         categories.ueb3101)  -- Radar
    end
end

function BuildCategories3()
    ScenarioFramework.PlayUnlockDialogue()
    for _, player in ScenarioInfo.HumanPlayers do
         ScenarioFramework.RemoveRestriction(player, categories.uas0102 + -- Attack boats
                                        categories.ual0105 + -- T1 Engineer
                                        categories.uab3102 + -- Sonar
     
                                        -- For use with captured UEF units
                                        categories.ueb3102 + -- Sonar
                                        categories.uel0105)  -- T1 Engineer
    end
end

function BuildCategories4()
    ScenarioFramework.PlayUnlockDialogue()
    for _, player in ScenarioInfo.HumanPlayers do
         ScenarioFramework.RemoveRestriction(player, categories.uab2109 + -- T1 Torpedo launcher
                                        categories.uas0203 + -- Subs
     
                                        -- For use with captured UEF units
                                        categories.ueb2109 + -- T1 Torpedo launcher
                                        categories.ues0203)  -- Subs
    end
end

function BuildCategories5()
    ScenarioFramework.PlayUnlockDialogue()
    for _, player in ScenarioInfo.HumanPlayers do
         ScenarioFramework.RemoveRestriction(player, categories.uab2104 + -- T1 AA turret
                                        categories.uab2101 + -- T1 land turret
     
                                        -- For use with captured UEF units
                                        categories.ueb2104 + -- T1 AA turret
                                        categories.ueb2101)  -- T1 land turret
    end
end

function BuildCategories6()
    ScenarioFramework.PlayUnlockDialogue()
    for _, player in ScenarioInfo.HumanPlayers do
         ScenarioFramework.RemoveRestriction(player,
     
                                        categories.uas0103 + -- Frigate
     
                                        -- For use with captured UEF units
                                        categories.ues0103)  -- Frigate
    end
end

function BuildCategories7()
    ScenarioFramework.PlayUnlockDialogue()
    -- T1 air for T1 Air factory, Aeon
    for _, player in ScenarioInfo.HumanPlayers do
         ScenarioFramework.RemoveRestriction(player, categories.uaa0101 +  -- Scout
                                        categories.uaa0102 +  -- Interceptor
                                        categories.uaa0103 +  -- Attack Bomber
     
                                        -- For use with captured UEF units
                                        categories.uea0101 +  -- Scout
                                        categories.uea0102 +  -- Interceptor
                                        categories.uea0103)   -- Attack Bomber
    end

    -- Disable some units for FauxUEF, to keep Land Assault reasonable
    ScenarioFramework.AddRestriction(FauxUEF, categories.uel0304 +  -- mobile heavy art
                                 categories.uel0203 +  -- amphib tank
                                 categories.uel0111)   -- mobile missile

    ScenarioFramework.RestrictEnhancements({'AdvancedEngineering',
                                            'ChronoDampener',
                                            'EnhancedSensors',
                                            'T3Engineering',
                                            'ResourceAllocation',
                                            'ResourceAllocationAdvanced',
                                            'Shield',
                                            'Teleporter',
                                            'ShieldHeavy'})
end

function BuildCategories7_AirFact()
    ScenarioFramework.PlayUnlockDialogue()
    for _, player in ScenarioInfo.HumanPlayers do
         ScenarioFramework.RemoveRestriction(player, categories.uab0102 +  -- t1 air factory
                                        categories.ueb0102)   -- t1 air factory
    end
end

 -- - win/lose functions

function PlayerCommanderDies_Lose(unit)
    if not ScenarioInfo.OperationEnding then
        ScenarioInfo.OperationEnding = true
        ScenarioFramework.FlushDialogueQueue()
-- player death
--    ScenarioFramework.EndOperationCamera(unit)
--    ScenarioFramework.EndOperationCamera(ScenarioInfo.PlayerCDR, true)
        ScenarioFramework.CDRDeathNISCamera(unit)
        ScenarioFramework.EndOperationSafety()
        ScenarioFramework.Dialogue(OpStrings.A01_D01_010, KillGame_Fail, true)
    end
end

function KillGame_Win()
    ScenarioInfo.OpComplete = true
    WaitSeconds(8.0)
    local secondaries = Objectives.IsComplete(ScenarioInfo.M7S1) and Objectives.IsComplete(ScenarioInfo.M7S2)
    ScenarioFramework.EndOperation(ScenarioInfo.OpComplete, ScenarioInfo.OpComplete, secondaries)
end

function KillGame_Fail()
    ScenarioInfo.OpComplete = false
    ScenarioFramework.Dialogue(ScenarioStrings.OpFail, false, true)
    WaitSeconds(9.0)
    ScenarioFramework.EndOperation(ScenarioInfo.OpComplete, ScenarioInfo.OpComplete, false)
end

-- ---------------
-- Debug Functions
-- ---------------

-- function OnF4()
-- M3_Start()
-- end
--
-- function OnCtrlF4()
-- #M7_CreateCzar()
-- M7_BeginMission()
-- end
--
-- function OnF5()
-- #EndOperationCounter()
--        local camInfo = {
--            blendTime = 1.0,
--            holdTime = 4,
--            orientationOffset = { 2.67, 0.4, 0 },
--            positionOffset = { 0, 0.5, 0 },
--            zoomVal = 55,
--            markerCam = true,
--        }
--        ScenarioFramework.OperationNISCamera(ScenarioUtils.MarkerToPosition("NIS_Navalbase_Destroyed"), camInfo)
-- end
--
-- function TrackingTest()
-- ScenarioInfo.RhizaCzarPlat = ScenarioUtils.CreateArmyGroupAsPlatoon('FauxRhiza', 'M7_Czar', 'ChevronFormation')
-- ScenarioInfo.RhizaCzar = ScenarioInfo.UnitNames[FauxRhiza]['Rhiza_Czar']
--
-- #Temporarily set czar viz radius to zero, so we dont have any vis to share with player ally
-- ScenarioInfo.RhizaCzar:SetIntelRadius('Vision', 0)
--
-- #Make a platoon to place the aircraft in. Spawn in a 5-unit group multiple times, each time adding
-- #this group to the platoon, clearing the commands of each unit, and loading each unit onto the Czar.
-- ScenarioInfo.CzarAircraftPlatoon = ArmyBrains[FauxRhiza]:MakePlatoon(' ', ' ')
-- for i = 1,15 do
--    local group = ScenarioUtils.CreateArmyGroup('FauxRhiza', 'M7_CzarAircraft')
--    ArmyBrains[FauxRhiza]:AssignUnitsToPlatoon(ScenarioInfo.CzarAircraftPlatoon, group, 'Attack', 'ChevronFormation')
--    for k,unit in group do
--        IssueStop({unit})
--        ScenarioInfo.RhizaCzar:AddUnitToStorage(unit)
--    end
-- end
--
-- #Due to it's size, and location, get its position and warp it west - there isnt enough space for it to spawn
-- #without peeking into the playable area.
-- local czarLocation = ScenarioInfo.RhizaCzar:GetPosition()
-- Warp(ScenarioInfo.RhizaCzar, {czarLocation[1] - 535, czarLocation[2], czarLocation[3]})
--
-- #Override the Czars OnDamage to just reduce it's health by X, if it is still greater than Y.
-- #Set it to not reclaimable, cap, killable.
-- ScenarioInfo.RhizaCzar.OnDamage = function(self, instigator)
--    if self:GetHealth() > 604 then
--        self:AdjustHealth(instigator, -4)
--    end
-- end
--
-- ScenarioInfo.RhizaCzar:SetReclaimable(false)
-- ScenarioInfo.RhizaCzar:SetCapturable(false)
-- ScenarioInfo.RhizaCzar:SetCanBeKilled(false)
--
-- #reset czar viz radius back to bp default
-- local bpIntel = ScenarioInfo.RhizaCzar:GetBlueprint().Intel
-- ScenarioInfo.RhizaCzar:SetIntelRadius('Vision', bpIntel.VisionRadius)
--
-- #Move to the holding location, where it will hang out waiting for some AA to get destroyed
-- #(this is to speed up the wait for when the player finishes obj's, and the FausUEF cdr is destroyed)
-- ScenarioInfo.RhizaCzarPlat:MoveToLocation(ScenarioUtils.MarkerToPosition('RhizaCzar_Move1'), false)
-- Utilities.UserConRequest('DebugSetPlayableRect 0 0 1111 1111')
-- Utilities.UserConRequest('SallyShears')
-- Warp(ScenarioInfo.RhizaCzar, {czarLocation[1], czarLocation[2], czarLocation[3]})
-- WaitSeconds(10)
-- LOG('*Debug: Tracking now')
-- end
--
-- function OnCtrlAltF4()
-- print('OnCtrlAltF4')
-- Utilities.UserConRequest('ui_DebugAltClick')
-- end
--
--
-- function OnCtrlAltF5()
-- ScenarioFramework.EndOperation('SCCA_Coop_A01', true, ScenarioInfo.Options.Difficulty, true, true)
-- end
