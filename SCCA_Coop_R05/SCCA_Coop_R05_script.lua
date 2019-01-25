-- ****************************************************************************
-- **
-- **  File     :  /maps/SCCA_Coop_R05/SCCA_Coop_R05_script.lua
-- **  Author(s):  Greg
-- **
-- **  Summary  :
-- **
-- **  Copyright © 2006 Gas Powered Games, Inc.  All rights reserved.
-- ****************************************************************************

local ScenarioFramework = import('/lua/scenarioframework.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local Objectives = import( '/lua/ScenarioFramework.lua' ).Objectives
local SimCamera = import('/lua/SimCamera.lua').SimCamera
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local Cinematics = import('/lua/cinematics.lua')
local OpStrings   = import('/maps/SCCA_Coop_R05/SCCA_Coop_R05_Strings.lua')
local ScenarioStrings = import('/lua/ScenarioStrings.lua')
local AIBuildStructures = import('/lua/ai/aibuildstructures.lua')
local VizMarker = import('/lua/sim/VizMarker.lua').VizMarker
local Utilities = import('/lua/utilities.lua')

---------
-- Globals
---------

ScenarioInfo.Player1         = 1
ScenarioInfo.UEF            = 2
ScenarioInfo.Hex5           = 3
ScenarioInfo.FauxUEF        = 4
ScenarioInfo.Player2            = 5
ScenarioInfo.Player3            = 6
ScenarioInfo.Player4            = 7

local Player1                = ScenarioInfo.Player1
local UEF                   = ScenarioInfo.UEF
local Hex5                  = ScenarioInfo.Hex5
local FauxUEF               = ScenarioInfo.FauxUEF
local Player2                    = ScenarioInfo.Player2
local Player3                    = ScenarioInfo.Player3
local Player4                    = ScenarioInfo.Player4
local Players = {ScenarioInfo.Player1, ScenarioInfo.Player2, ScenarioInfo.Player3, ScenarioInfo.Player4}

 -- reminder timers:
local Reminder_M1P1_Initial            = 2000
local Reminder_M1P1_Subsequent         = 800
local Reminder_M2P1_Initial            = 1300
local Reminder_M2P1_Subsequent         = 600
local Reminder_M2P2_Initial            = 400
local Reminder_M2P2_Subsequent         = 800
local Reminder_M3P1_Initial            = 1200
local Reminder_M3P1_Subsequent         = 600

ScenarioInfo.M1P1Complete               = false
ScenarioInfo.M2P1Complete               = false
ScenarioInfo.M2P2Complete               = false
ScenarioInfo.M3P1Complete               = false

local M1_GeneratorsDestroyed            = 0
local M1_NavalPromptPlayed              = false

 -- m1 attack growth, easy/normal difficulty
local M1_FirstAttacks                   = 600   -- 600   #Delay before UEF will buzz the players base, leading to attacks commencing.
local M1_FirstAttacksIncrease           = 950   -- 950   #increase the stage one attacks to full strength
local M1_SecondAttacks                  = 1350  -- 1350   #Delay between mission start and the second stage of attacks
local M1_ThirdAttacks                   = 1900  -- 1900  #"         "           "
local M1_PostStage3LandAssaultDelay     = 200   -- Pause after start of the 3rd attack stage that we send in the single "warning" land assault
local M1_PostStage3NavalDelay           = 190   -- Pause after start of the 3rd attack stage that we send in the naval attack

 -- m1 attack growth, hard difficulty
local M1_FirstAttacks_HARD              = 360   -- 360   #Delay before UEF will buzz the players base, leading to attacks commencing.
local M1_FirstAttacksIncrease_HARD      = 610   -- 710   #increase the stage one attacks to full strength
local M1_SecondAttacks_HARD             = 900   -- 1110  #Delay between mission start and the second stage of attacks
local M1_ThirdAttacks_HARD              = 1310  -- 1660  #"         "           "

local M1_TransportAttackDone            = false

ScenarioInfo.M2_OmniObjCompleted        = false
ScenarioInfo.M3_VirusUploaded           = false
ScenarioInfo.M3_AirPlatformsDestroyed   = false
ScenarioInfo.UEFCommanderDestroyed      = false
ScenarioInfo.M2_FinalGunshipGroupsDefeated  = 0
ScenarioInfo.GunshipScenarioStarted         = false
ScenarioInfo.M2_OffmapPlatoonsDead          = 0
ScenarioInfo.M2_Hard_OffmapAttackCount      = 0
ScenarioInfo.UEFOmniDestroyedCounter        = 0

local M3_InitGunshipPlatsKilled         = 0
local M2_DelaySecondNavalAttack         = 290   -- Delay after start of M2 that we begin launcher the occasional secondary naval attacks
local M2_GunshipAttackDelay             = 10    -- Delay between warning dialogue and launch of attack. Currently, we want delay + travel time to be about 2 minutes

local Difficulty = ScenarioInfo.Options.Difficulty or 2
function AdjustDifficulty (table)
    return table[Difficulty]
end

 --- hard diff stuff
local M2_OffmapAttack_Land_Inital                   =   300
local M2_OffmapAttack_Land_Delay                    =   500
local M2_OffmapAttack_Air_Inital                    =   160
local M2_OffmapAttack_Air_Delay                     =   290
local M2_OffmapAttack_Air_Delay2                    =   400
ScenarioInfo.M2_OffmapAirDead                       =   0
ScenarioInfo.M2_Hard_OffmapAir_Count                =   0

ScenarioInfo.VarTable['M1_NumEngineers']            = AdjustDifficulty ({2,6,8})
ScenarioInfo.VarTable['M2_Air_NumEngineers']        = AdjustDifficulty ({7,19,27})
ScenarioInfo.VarTable['M2_Naval_NumEngineers']      = AdjustDifficulty ({3,9,15})
ScenarioInfo.VarTable['M2_SW_NumEngineers']         = AdjustDifficulty ({2,6,12})
ScenarioInfo.VarTable['M2_North_NumEngineers']      = AdjustDifficulty ({4,12,18})
ScenarioInfo.VarTable['M3_Air_NumEngineers']        = AdjustDifficulty ({8,16,28})
ScenarioInfo.VarTable['M3_Main_NumEngineers']       = AdjustDifficulty ({9,18,34})
ScenarioInfo.VarTable['M1_GunshipGroupsPer']        = AdjustDifficulty ({1,2,3})

ScenarioInfo.VarTable['M1_UEFAttackBegin']          = false
ScenarioInfo.VarTable['M1_UEFAttackBeginIncrease']  = false
ScenarioInfo.VarTable['M1_UEFAttackBegin2']         = false
ScenarioInfo.VarTable['M1_UEFAttackBegin3']         = false
ScenarioInfo.VarTable['M2_DelayedNaval']            = false
ScenarioInfo.VarTable['M3_VirusUpload']             = false
ScenarioInfo.VarTable['M3_PlayerAtUEFMainBase']     = false

ScenarioInfo.OperationEnding        = false
----------------------
-- Starter Functions
----------------------

function OnPopulate(scenario)
    ScenarioUtils.InitializeScenarioArmies()
    ScenarioFramework.GetLeaderAndLocalFactions()
    M1UnitsForStart()
end

function OnLoad(self)
end

function OnStart(self)
    ScenarioFramework.SetCybranColor(1)
    ScenarioFramework.SetUEFColor(2)
    ScenarioFramework.SetCybranAllyColor(3)
    ScenarioFramework.SetUEFAllyColor(4)
    local colors = {
        ['Player2'] = {183, 101, 24}, 
        ['Player3'] = {255, 135, 62}, 
        ['Player4'] = {255, 191, 128}
    }
    local tblArmy = ListArmies()
    for army, color in colors do
        if tblArmy[ScenarioInfo[army]] then
            ScenarioFramework.SetArmyColor(ScenarioInfo[army], unpack(color))
        end
    end
    ScenarioFramework.SetPlayableArea( ScenarioUtils.AreaToRect('M1_PlayableArea'), false )

    ForkThread(IntroSequenceThread)
end

function IntroSequenceThread()
    Cinematics.EnterNISMode()
    ScenarioFramework.CreateTimerTrigger(CreateCommander_Thread, 1.25)
    Cinematics.CameraMoveToRectangle( ScenarioUtils.AreaToRect('Intro_Camera_1'), .75)
    Cinematics.CameraMoveToRectangle( ScenarioUtils.AreaToRect('Intro_Camera_2'), 3.5)
    WaitSeconds(1.4)
    Cinematics.CameraMoveToRectangle( ScenarioUtils.AreaToRect('Intro_Camera_3'), .75)
    WaitSeconds(1.25)
    Cinematics.ExitNISMode()
    BeginOperation()
end

function CreateCommander_Thread()
    ScenarioInfo.PlayerCommander = ScenarioUtils.CreateArmyUnit ( 'Player1', 'M1_PlayerCDR' )
    ScenarioInfo.PlayerCommander:PlayCommanderWarpInEffect()
    ScenarioInfo.PlayerCommander:SetCustomName(ArmyBrains[Player1].Nickname)

    ScenarioInfo.CoopCDR = {}
    local tblArmy = ListArmies()
    coop = 1
    for iArmy, strArmy in pairs(tblArmy) do
        if iArmy >= ScenarioInfo.Player2 then
            ScenarioInfo.CoopCDR[coop] = ScenarioUtils.CreateArmyUnit (strArmy, 'M1_PlayerCDR' )
            ScenarioInfo.CoopCDR[coop]:PlayCommanderWarpInEffect()
            ScenarioInfo.CoopCDR[coop]:SetCustomName(ArmyBrains[iArmy].Nickname)
            coop = coop + 1
            WaitSeconds(0.5)
        end
    end

    ScenarioFramework.PauseUnitDeath( ScenarioInfo.PlayerCommander )
    for index, coopACU in ScenarioInfo.CoopCDR do
        ScenarioFramework.PauseUnitDeath(coopACU)
        ScenarioFramework.CreateUnitDeathTrigger(PlayerCDRKilled, coopACU)
    end
    ScenarioFramework.CreateUnitDeathTrigger( PlayerCDRKilled, ScenarioInfo.PlayerCommander )
end

function M1UnitsForStart()
    SetArmyUnitCap(UEF, 900)
    ScenarioFramework.SetSharedUnitCap(480)

    for i = 2, table.getn(ArmyBrains) do
        SetIgnorePlayableRect(i, true)
    end

    -- Set difficulty concantenation string
    if ScenarioInfo.Options.Difficulty == 1 then DifficultyConc = 'Light' end
    if ScenarioInfo.Options.Difficulty == 2 then DifficultyConc = 'Medium' end
    if ScenarioInfo.Options.Difficulty == 3 then DifficultyConc = 'Strong' end

    -- Player CDR


    -- UEF Resource Base and generators, initial assist engineers. assign engineers to factories.
    ScenarioUtils.CreateArmyGroup ( 'UEF', 'M1_UEFBase_Defense_'..DifficultyConc )
    ScenarioUtils.CreateArmyGroup ( 'UEF', 'M1_UEFBase_Walls' )
    ScenarioUtils.CreateArmyGroup ( 'UEF', 'M1_UEFBase_Production_Fact' )
    ScenarioUtils.CreateArmyGroup ( 'UEF', 'M1_UEFBase_AssistEngineers_'..DifficultyConc)
    ScenarioUtils.CreateArmyGroup ( 'UEF', 'M1_UEFBase_Production_Sundry' )
    ScenarioInfo.UEFGenerators = ScenarioUtils.CreateArmyGroup ( 'UEF', 'M1_UEFGenerators' )

      --- make a new base maintence template for the base
    AIBuildStructures.CreateBuildingTemplate( ArmyBrains[UEF], 'UEF', 'M1_UEFGenBaseMaintain' )
    AIBuildStructures.AppendBuildingTemplate( ArmyBrains[UEF], 'UEF', ('M1_UEFBase_Defense_'..DifficultyConc), 'M1_UEFGenBaseMaintain')
    AIBuildStructures.AppendBuildingTemplate( ArmyBrains[UEF], 'UEF', ('M1_UEFBase_Production_Fact'), 'M1_UEFGenBaseMaintain')
    AIBuildStructures.AppendBuildingTemplate( ArmyBrains[UEF], 'UEF', ('M1_UEFBase_Production_Sundry'), 'M1_UEFGenBaseMaintain')
    AIBuildStructures.AppendBuildingTemplate( ArmyBrains[UEF], 'UEF', ('M1_UEFBase_Walls'), 'M1_UEFGenBaseMaintain')

    -- UEF Naval Units
    -- Create patrol 1 through 4, and send them on their same-numbered patrol chain 1 through 4
    for i = 1,4 do
        local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon ( 'UEF', 'M1_UEFNavalPatrol'..i..'_'..DifficultyConc, 'AttackFormation' )
        ScenarioFramework.PlatoonPatrolChain( platoon, 'M1_NavalPatrol_'..i )
    end
    ScenarioInfo.M1_UEFNavalPatrol5 = ScenarioUtils.CreateArmyGroupAsPlatoon ( 'UEF', 'M1_UEFNavalPatrol5_'..DifficultyConc, 'AttackFormation' )
    ScenarioFramework.PlatoonPatrolChain( ScenarioInfo.M1_UEFNavalPatrol5, 'M1_UEFNaval_Mid_PatrolChain_1' )

    -- UEF Gunship Patrols
    local gunshipPlatoon1 = ScenarioUtils.CreateArmyGroupAsPlatoon ( 'UEF', 'M1_UEFGunshipsPatrol1_'..DifficultyConc, 'NoFormation' )
    local gunshipPlatoon2 = ScenarioUtils.CreateArmyGroupAsPlatoon ( 'UEF', 'M1_UEFGunshipsPatrol2_'..DifficultyConc, 'NoFormation' )
    local gunshipPlatoon3 = ScenarioUtils.CreateArmyGroupAsPlatoon ( 'UEF', 'M1_UEFGunshipsPatrol3_'..DifficultyConc, 'NoFormation' )
    local gunshipPlatoon4 = ScenarioUtils.CreateArmyGroupAsPlatoon ( 'UEF', 'M1_UEFGunshipsPatrol4_'..DifficultyConc, 'NoFormation' )
    local gunshipPlatoon5 = ScenarioUtils.CreateArmyGroupAsPlatoon ( 'UEF', 'M1_UEFGunshipsPatrol5_'..DifficultyConc, 'NoFormation' )
    ScenarioFramework.PlatoonPatrolChain( gunshipPlatoon1, 'M1_GunshipPatrolChain_4' )
    ScenarioFramework.PlatoonPatrolChain( gunshipPlatoon2, 'M1_GunshipPatrolChain_3' )
    ScenarioFramework.PlatoonPatrolChain( gunshipPlatoon3, 'M1_GunshipPatrolChain_2' )
    ScenarioFramework.PlatoonPatrolChain( gunshipPlatoon4, 'M1_GunshipPatrolChain_1' )
    ScenarioFramework.PlatoonPatrolChain( gunshipPlatoon5, 'M1_GunshipPatrolChain_5' )

    -- UEF Base area ground patrols
    -- 3 patrol groups, each given a similarly numbered patrol
    for i = 1,3 do
        local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon ( 'UEF', 'M1_UEFBase_DefensePatrol_'..i.. '_'..DifficultyConc, 'AttackFormation' )
        ScenarioFramework.PlatoonPatrolChain( platoon, 'M1_UEFLandPatrolChain_'..i )
    end

    -- M2 Area Eastern Omni Base: factories and infrastructure, as we will use this base to make offmap gunships in M1.
    -- Create engineers and get them assisting factories.
    ScenarioUtils.CreateArmyGroup ( 'UEF', 'M2_UEFOmniBaseEast_Production_Fact' )
    ScenarioUtils.CreateArmyGroup ( 'UEF', 'M2_UEFOmniBaseEast_Production_Sundry' )
    ScenarioUtils.CreateArmyGroup ( 'UEF', 'M2_UEFOmniBaseEast_AssistEngineers_'..DifficultyConc )
end


--------------
-- Mission 1
--------------

function BeginOperation()
    ScenarioInfo.MissionNumber = 1
    M1_BuildCategories()

    -- Assign Objectives
    ScenarioFramework.Dialogue(OpStrings.C05_M01_010)
    ScenarioFramework.CreateTimerTrigger(M1P1Reminder1, Reminder_M1P1_Initial)
    ScenarioInfo.M1P1 = Objectives.KillOrCapture(
        'primary',                      -- type
        'incomplete',                   -- complete
        OpStrings.M1P1Text,             -- title
        OpStrings.M1P1Detail,           -- description
        {                               -- target
            Units = ScenarioInfo.UEFGenerators,             -- destroy generators
        }
    )
    ScenarioInfo.M1P1:AddResultCallback(
        function()
            M1_UEFGeneratorsDestroyed()
        end
    )
    ScenarioInfo.M1P1:AddProgressCallback(M1_GeneratorProgressTaunt)
    ScenarioFramework.Dialogue(ScenarioStrings.NewPObj)

    -- Dialogue and Objective timers/assign
    ScenarioFramework.CreateTimerTrigger (M1_PromptObjectiveDialogue, 1100 )
    ScenarioFramework.CreateTimerTrigger (M1_PromptNavalDialogue, 360 )
    ScenarioFramework.CreateArmyIntelTrigger( M1_PromptNavalDialogue, ArmyBrains[Player1], 'Radar', false, true, categories.NAVAL, true, ArmyBrains[UEF] )
    ScenarioFramework.CreateArmyIntelTrigger( M1_PromptNavalDialogue, ArmyBrains[Player1], 'Sonar', false, true, categories.NAVAL, true, ArmyBrains[UEF] )
    ScenarioFramework.CreateArmyIntelTrigger( M1_PromptNavalDialogue, ArmyBrains[Player1], 'LOSNow', false, true, categories.NAVAL, true, ArmyBrains[UEF] )
    ScenarioFramework.CreateArmyIntelTrigger( M1_PromptNavalDialogue, ArmyBrains[Player1], 'Omni', false, true, categories.NAVAL, true, ArmyBrains[UEF] )

    -- Intel trigger for LOS on player
    ScenarioFramework.CreateArmyIntelTrigger( M1_UEFSpotsPlayer, ArmyBrains[UEF], 'LOSNow', false, true, categories.ALLUNITS, true, ArmyBrains[Player1] )

    -- TIMING FRAMEWORK for mission. 3 major types of attacks, with the first transitioning in in two steps.
    if Difficulty == 3 then
        ScenarioFramework.CreateTimerTrigger (M1_BeginFirstAttacks, M1_FirstAttacks_HARD )
        ScenarioFramework.CreateTimerTrigger (M1_ExpandFirstAttacks, M1_FirstAttacksIncrease_HARD )
        ScenarioFramework.CreateTimerTrigger (M1_BeginSecondAttacks, M1_SecondAttacks_HARD )
        ScenarioFramework.CreateTimerTrigger (M1_BeginThirdAttacks, M1_ThirdAttacks_HARD )
    else
        ScenarioFramework.CreateTimerTrigger (M1_BeginFirstAttacks, M1_FirstAttacks )
        ScenarioFramework.CreateTimerTrigger (M1_ExpandFirstAttacks, M1_FirstAttacksIncrease )
        ScenarioFramework.CreateTimerTrigger (M1_BeginSecondAttacks, M1_SecondAttacks )
        ScenarioFramework.CreateTimerTrigger (M1_BeginThirdAttacks, M1_ThirdAttacks )
    end

    -- Taunt when 5th naval unit killed
    ScenarioFramework.CreateArmyStatTrigger( M1_NavalProgressTaunt, ArmyBrains[Player1], 'TauntTrigger',
        {{ StatType = 'Enemies_Killed', CompareType = 'GreaterThan', Value = 4, Category = categories.NAVAL * categories.UEF, },} ) -- 5 uef naval
end

function M1_GeneratorProgressTaunt()
    M1_GeneratorsDestroyed = M1_GeneratorsDestroyed + 1
    if M1_GeneratorsDestroyed == 3 then
        ScenarioFramework.Dialogue(OpStrings.TAUNT4)
    end
end

function M1_PromptObjectiveDialogue()
    if ScenarioInfo.MissionNumber == 1 then
        ScenarioFramework.Dialogue(OpStrings.C05_M01_020)
    end
end

function M1_PromptNavalDialogue()
    if not M1_NavalPromptPlayed then
        M1_NavalPromptPlayed = true
        ScenarioFramework.Dialogue(OpStrings.C05_M01_030)
    end
end

function M1_NavalProgressTaunt()
       ScenarioFramework.Dialogue(OpStrings.TAUNT8)
end

function M1_UEFSpotsPlayer()
    ForkThread(M1_UEFSpotsPlayerThread)
end

function M1_UEFSpotsPlayerThread()
    WaitSeconds(15)
    ScenarioFramework.Dialogue(OpStrings.C05_M01_040)
end

 --- First Stage of attacks: scouts, tell pbm to begin building weak attacks

function M1_BeginFirstAttacks()
    ForkThread(M1_SpawnUEFScoutsThread)
end

function M1_SpawnUEFScoutsThread()
    if ScenarioInfo.MissionNumber ==1 then
        local scoutsOne = ScenarioUtils.CreateArmyGroupAsPlatoon ( 'UEF', 'M1_UEFScouts', 'ChevronFormation' )
        ScenarioFramework.PlatoonPatrolChain( scoutsOne, 'M1_UEFScout_Land_Chain' )
        WaitSeconds(4)
        local scoutsTwo = ScenarioUtils.CreateArmyGroupAsPlatoon ( 'UEF', 'M1_UEFScouts', 'ChevronFormation' )
        ScenarioFramework.PlatoonPatrolChain( scoutsTwo, 'M1_UEFScout_Water_Chain' )
        ScenarioFramework.CreateTimerTrigger(M1_ContinueFirstAttacks, 60)
    end
end

function M1_ContinueFirstAttacks()
    -- Timer for a remind dialogue
    ScenarioFramework.CreateTimerTrigger (M1_ObjectiveReminderDialogue, 60 )

    -- Tell pbm to begin building initial attacks
    ScenarioInfo.VarTable['M1_UEFAttackBegin'] = true
end

function M1_ExpandFirstAttacks()
    -- Flag the second half of wave one attacks to begin production too
    ScenarioInfo.VarTable['M1_UEFAttackBeginIncrease'] = true
end

 --- Second Stage of attacks: attack strength/frequency increase, naval attack (if units from attacking subgroup are remaining) occurs

function M1_BeginSecondAttacks()
    -- Tell pbm to begin building second attacks
    ScenarioInfo.VarTable['M1_UEFAttackBegin'] = false
    ScenarioInfo.VarTable['M1_UEFAttackBegin2'] = true
end


 --- Third Stage of attacks: offmap airbase begins gunship attacks, offmap "warning" land transport comes in

function M1_BeginThirdAttacks()
    ScenarioInfo.VarTable['M1_UEFAttackBegin3'] = true

    ScenarioFramework.CreateTimerTrigger(M1_NavalAttack, M1_PostStage3NavalDelay)

    -- Offmap one-shot transported attack moves in
    if M1_TransportAttackDone == false then
        M1_TransportAttackDone = true
        ScenarioFramework.CreateTimerTrigger(M1_OffmapTransportAttackThread, M1_PostStage3LandAssaultDelay)
    end
end

function M1_NavalAttack()
    -- Send a naval patrol to player area
    if ArmyBrains[UEF]:PlatoonExists( ScenarioInfo.M1_UEFNavalPatrol5 ) == true then
        ScenarioInfo.M1_UEFNavalPatrol5:Stop()
        ScenarioFramework.PlatoonPatrolChain( ScenarioInfo.M1_UEFNavalPatrol5, 'M1_UEFNaval_Mid_PatrolChain_2' )
    end
end

function M1_OffmapTransportAttackThread()
    -- Send out a gunship group, and delay the creation of the transport group (as transports
    -- move faster than gunships, the gunships need a lead-in)
    if ScenarioInfo.MissionNumber == 1 then
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon ( 'UEF', 'M1_UEF_OffmapAttack_'..DifficultyConc, 'ChevronFormation' )
        ScenarioFramework.PlatoonPatrolChain( platoon, 'M1_UEF_OffmapPatrol_Chain' )
        ScenarioFramework.CreateTimerTrigger( M1_OffmapTransportAttackSecondary, 20)
    end
end

function M1_OffmapTransportAttackSecondary()
    -- Send group of transports, and some gunships, to player's base area.
    if ScenarioInfo.MissionNumber == 1 then
        local transport = ScenarioUtils.CreateArmyGroupAsPlatoon ( 'UEF', 'M1_UEF_OffmapAttack_Transport', 'ChevronFormation' )
        local units     = ScenarioUtils.CreateArmyGroupAsPlatoon ( 'UEF', 'M1_UEF_OffmapAttack_Landunits', 'AttackFormation' )
        ForkThread(TransportAttack, transport, units, 2,  'PlayerBaseArea', 'M1_UEF_OffmapPatrol_Chain')
    end
end

function M1_ObjectiveReminderDialogue()
    ScenarioFramework.Dialogue(OpStrings.C05_M01_060)
end

function M1_UEFGeneratorsDestroyed()
    ScenarioInfo.M1P1Complete = true

-- Powergens destroyed cam
    local camInfo = {
        blendTime = 1,
        holdTime = 4,
        orientationOffset = { -0.72, 0.35, 0 },
        positionOffset = { 0, 1.5, 0 },
        zoomVal = 55,
        markerCam = true,
    }
    ScenarioFramework.OperationNISCamera( ScenarioUtils.MarkerToPosition('NIS_M1_PowerGens'), camInfo )

    ScenarioFramework.Dialogue(OpStrings.C05_M01_050, BeginMission2)
    ScenarioFramework.Dialogue(ScenarioStrings.PObjComp)
end


--------------
-- Mission 2
--------------

function BeginMission2()
    ScenarioFramework.SetSharedUnitCap(660)
    M2_CreateUnitsForMission()
    M2_BuildCategories()
    ScenarioInfo.MissionNumber = 2
    ScenarioFramework.SetPlayableArea( ScenarioUtils.AreaToRect('M2_PlayableArea') )

    -- First primary: Destroy the Omni's. Secondary Obj: destroy naval base
    -- Objectives
    ScenarioInfo.M2P1 = Objectives.KillOrCapture(     -- Destroy the Omnis
        'primary',                      -- type
        'incomplete',                   -- complete
        OpStrings.M2P1Text,             -- title
        OpStrings.M2P1Detail,           -- description
        {                               -- target
            Units = ScenarioInfo.M2_ObjectiveOmniTable,
            FlashVisible = true,
            ShowProgress = true,
        }
    )
    ScenarioInfo.M2S1 = Objectives.KillOrCapture(     -- Destroy naval base
        'primary',                      -- type
        'incomplete',                   -- complete
        OpStrings.M2S1Text,             -- title
        OpStrings.M2S1Detail,           -- description
        {                               -- target
            Units = ScenarioInfo.M2_UEFNavalBase_ObjectiveFact,
        }
    )
    ScenarioInfo.M2S1:AddResultCallback(
        function()
            M2_UEFNavalBaseDestroyed()
        end
    )

    ScenarioFramework.Dialogue(ScenarioStrings.NewPObj)
    ScenarioFramework.Dialogue(OpStrings.C05_M02_010)
    ScenarioFramework.Dialogue(ScenarioStrings.NewSObj)
    ScenarioFramework.CreateTimerTrigger(M2P1Reminder1, Reminder_M2P1_Initial)

    -- Timer for some banter from enemy CDR, and tech tree unlock
    ScenarioFramework.CreateTimerTrigger ( M2_EnemyBanterFourMins, 240 )
    ScenarioFramework.CreateTimerTrigger ( M2_UnlockAirSup, 300 )
    ScenarioFramework.CreateTimerTrigger ( M2_EnemyTaunt, 600 )

    ScenarioFramework.CreateTimerTrigger ( M2_BeginSecondNavalAttack, M2_DelaySecondNavalAttack )

    -- Special hard-difficulty offmap attacks.
    if Difficulty == 3 then
        ScenarioFramework.CreateTimerTrigger(M2_Hard_OffmapTransAttack, M2_OffmapAttack_Land_Inital)
        ScenarioFramework.CreateTimerTrigger(M2_Hard_OffmapAirAttack, M2_OffmapAttack_Air_Inital)
    end
end

function M2_CreateUnitsForMission()
    -- Create UEF Omni towers, their death triggers, and add them to a table for the objective system
    ScenarioInfo.M2_UEFOmniEast =  ScenarioUtils.CreateArmyUnit ( 'UEF', 'M2_UEFOmniEast' )
    ScenarioInfo.M2_UEFOmniNorth = ScenarioUtils.CreateArmyUnit ( 'UEF', 'M2_UEFOmniNorth' )
    ScenarioInfo.M2_UEFOmniSouthWest =  ScenarioUtils.CreateArmyUnit ( 'UEF', 'M2_UEFOmniSouthWest' )

    ScenarioFramework.CreateUnitDestroyedTrigger( M2_OmniDestroyed, ScenarioInfo.M2_UEFOmniEast)
    ScenarioFramework.CreateUnitDestroyedTrigger( M2_OmniDestroyed, ScenarioInfo.M2_UEFOmniNorth)
    ScenarioFramework.CreateUnitDestroyedTrigger( M2_OmniDestroyed, ScenarioInfo.M2_UEFOmniSouthWest)

    ScenarioInfo.M2_ObjectiveOmniTable = {}
    table.insert(ScenarioInfo.M2_ObjectiveOmniTable, ScenarioInfo.M2_UEFOmniEast)
    table.insert(ScenarioInfo.M2_ObjectiveOmniTable, ScenarioInfo.M2_UEFOmniNorth)
    table.insert(ScenarioInfo.M2_ObjectiveOmniTable, ScenarioInfo.M2_UEFOmniSouthWest)

    -- Create UEF Omni bases
      ---Eastern (production already created at start of m1, for use in m1.
    ScenarioUtils.CreateArmyGroup ( 'UEF', 'M2_UEFOmniBaseEast_Walls' )
    ScenarioUtils.CreateArmyGroup ( 'UEF', 'M2_UEFOmniBaseEast_Defense_'..DifficultyConc )
    local eastOmniDef1 = ScenarioUtils.CreateArmyGroupAsPlatoon ( 'UEF', 'M2_UEFOmniBaseEast_AirPatrol1_'..DifficultyConc, 'NoFormation' )
    local eastOmniDef2 = ScenarioUtils.CreateArmyGroupAsPlatoon ( 'UEF', 'M2_UEFOmniBaseEast_AirPatrol2_'..DifficultyConc, 'NoFormation' )
    ScenarioFramework.PlatoonPatrolChain( eastOmniDef1, 'M2_UEFOmniEast_AirPatrolChain_1' )
    ScenarioFramework.PlatoonPatrolChain( eastOmniDef2, 'M2_NavalEasternCombo_PatrolChain1' )

    AIBuildStructures.CreateBuildingTemplate( ArmyBrains[UEF], 'UEF', 'M2_UEFOmniBaseEastBaseMaintain' )
    -- AIBuildStructures.AppendBuildingTemplate( ArmyBrains[UEF], 'UEF', ('M2_UEFOmniBaseEast_Defense_'..DifficultyConc), 'M2_UEFOmniBaseEastBaseMaintain') #commenting out, so the engineers just focus on unit production infrastructure
    AIBuildStructures.AppendBuildingTemplate( ArmyBrains[UEF], 'UEF', ('M2_UEFOmniBaseEast_Production' ), 'M2_UEFOmniBaseEastBaseMaintain')
    AIBuildStructures.AppendBuildingTemplate( ArmyBrains[UEF], 'UEF', ('M2_UEFOmniBaseEast_Walls' ), 'M2_UEFOmniBaseEastBaseMaintain')

      ---Southwestern
    ScenarioUtils.CreateArmyGroup ( 'UEF', 'M2_UEFOmniBaseSouthWest_Production_Fact_'..DifficultyConc )
    ScenarioUtils.CreateArmyGroup ( 'UEF', 'M2_UEFOmniBaseSouthWest_Production_Sundry' )
    ScenarioUtils.CreateArmyGroup ( 'UEF', 'M2_UEFOmniBaseSouthWest_'..DifficultyConc )
    ScenarioUtils.CreateArmyGroup ( 'UEF', 'M2_UEFOmniBaseSouthWest_Walls' )
    local swOmniDef1 = ScenarioUtils.CreateArmyGroupAsPlatoon ( 'UEF', 'M2_UEFOmniBaseSouthWest_AirPatrol1_'..DifficultyConc, 'NoFormation' )
    -- local swOmniDef2 = ScenarioUtils.CreateArmyGroupAsPlatoon ( 'UEF', 'M2_UEFOmniBaseSouthWest_LandPatrol1_'..DifficultyConc, 'AttackFormation' ) #Commenting out this group to soften difficulty at SW. OpAI Land Assault accumulations make for enough of a ground fight.
    ScenarioFramework.PlatoonPatrolChain( swOmniDef1, 'M2_UEFOmniSW_LandPatrolChain_1' )
    -- ScenarioFramework.PlatoonPatrolChain( swOmniDef2, 'M2_UEFOmniSW_AirPatrolChain_1' )
    ScenarioUtils.CreateArmyGroup ( 'UEF', 'M2_UEFOmniBaseSouthWest_AssistEngineers_'..DifficultyConc )

    AIBuildStructures.CreateBuildingTemplate( ArmyBrains[UEF], 'UEF', 'M2_UEFOmniBaseSouthWestBaseMaintain' )
    AIBuildStructures.AppendBuildingTemplate( ArmyBrains[UEF], 'UEF', ('M2_UEFOmniBaseSouthWest_'..DifficultyConc), 'M2_UEFOmniBaseSouthWestBaseMaintain')
    AIBuildStructures.AppendBuildingTemplate( ArmyBrains[UEF], 'UEF', ('M2_UEFOmniBaseSouthWest_Production_Fact_'..DifficultyConc), 'M2_UEFOmniBaseSouthWestBaseMaintain')
    AIBuildStructures.AppendBuildingTemplate( ArmyBrains[UEF], 'UEF', ('M2_UEFOmniBaseSouthWest_Production_Sundry' ), 'M2_UEFOmniBaseSouthWestBaseMaintain')
    AIBuildStructures.AppendBuildingTemplate( ArmyBrains[UEF], 'UEF', ('M2_UEFOmniBaseSouthWest_Walls' ), 'M2_UEFOmniBaseSouthWestBaseMaintain')

      ---North
    ScenarioUtils.CreateArmyGroup ( 'UEF', 'M2_UEFOmniBaseNorth_'..DifficultyConc )
    ScenarioUtils.CreateArmyGroup ( 'UEF', 'M2_UEFOmniBaseNorth_Production_fact_'..DifficultyConc )
    ScenarioUtils.CreateArmyGroup ( 'UEF', 'M2_UEFOmniBaseNorth_Production_Sundry' )
    ScenarioUtils.CreateArmyGroup ( 'UEF', 'M2_UEFOmniBaseNorth_Walls' )

    local northAirDef1 = ScenarioUtils.CreateArmyGroupAsPlatoon ( 'UEF', 'M2_UEFOmniBaseNorth_AirPatrol1_'..DifficultyConc, 'NoFormation' )
    -- local northLandDef1 = ScenarioUtils.CreateArmyGroupAsPlatoon ( 'UEF', 'M2_UEFOmniBaseNorth_LandPatrol1_'..DifficultyConc, 'AttackFormation' )  ##Will just rely on the collecting OpAI troops, and one small pbm.
    ScenarioFramework.PlatoonPatrolChain( northAirDef1, 'M2_UEFOmniNorth_AirPatrolChain_1' )
    -- ScenarioFramework.PlatoonPatrolChain( northLandDef1, 'M2_UEFOmniNorth_LandPatrolChain_1' )
    ScenarioUtils.CreateArmyGroup ( 'UEF', 'M2_UEFOmniBaseNorth_AssistEngineers_'..DifficultyConc )

    AIBuildStructures.CreateBuildingTemplate( ArmyBrains[UEF], 'UEF', 'M2_UEFOmniBaseNorthMaintainBase' )
    AIBuildStructures.AppendBuildingTemplate( ArmyBrains[UEF], 'UEF', ('M2_UEFOmniBaseNorth_Production_fact_'..DifficultyConc), 'M2_UEFOmniBaseNorthMaintainBase')
    AIBuildStructures.AppendBuildingTemplate( ArmyBrains[UEF], 'UEF', ('M2_UEFOmniBaseNorth_'..DifficultyConc), 'M2_UEFOmniBaseNorthMaintainBase')
    AIBuildStructures.AppendBuildingTemplate( ArmyBrains[UEF], 'UEF', ('M2_UEFOmniBaseNorth_Production_Sundry' ), 'M2_UEFOmniBaseNorthMaintainBase')
    AIBuildStructures.AppendBuildingTemplate( ArmyBrains[UEF], 'UEF', ('M2_UEFOmniBaseNorth_Walls' ), 'M2_UEFOmniBaseNorthMaintainBase')

     --- in medium and hard dif, add a LAI out front, to discourage small numbers of cyrban land destroyers. A single one should do an ok-ish job at this task, but not make a conventional land assault much harder for the player
    if Difficulty > 1 then
        ScenarioUtils.CreateArmyGroup ( 'UEF', 'M2_OmniBaseNorth_NoMaintain' )
    end

    -- Create UEF Naval base. Structures, defenders, and patrols
    ScenarioInfo.M2_UEFNavalBase_ObjectiveFact = ScenarioUtils.CreateArmyGroup ( 'UEF', 'M2_UEFNavalBase_ObjectiveFactories' )
    ScenarioUtils.CreateArmyGroup ( 'UEF', 'M2_UEFNavalBase_ObjectiveEnergy' ) -- Contains a T3 Mass fab
    ScenarioUtils.CreateArmyGroup ( 'UEF', 'M2_UEFNavalBase_'..DifficultyConc )

    -- group that contains stuff we wont add to base maintain, to ease difficulty
    ScenarioUtils.CreateArmyGroup ( 'UEF', 'M2_UEFNavalBase_NoMaintain_'..DifficultyConc )

    ScenarioUtils.CreateArmyGroup ( 'UEF', 'M2_UEFNavalBase_Production' )
    ScenarioUtils.CreateArmyGroup ( 'UEF', 'M2_UEFNavalBase_Walls' )
    ScenarioUtils.CreateArmyGroup ( 'UEF', 'M2_UEFNavalBase_AssistEngineers_'..DifficultyConc )

       --- base maintain for engineers
    AIBuildStructures.CreateBuildingTemplate( ArmyBrains[UEF], 'UEF', 'M2_UEFNavalBaseMaintain' )
    AIBuildStructures.AppendBuildingTemplate( ArmyBrains[UEF], 'UEF', ('M2_UEFNavalBase_'..DifficultyConc), 'M2_UEFNavalBaseMaintain')
    AIBuildStructures.AppendBuildingTemplate( ArmyBrains[UEF], 'UEF', ('M2_UEFNavalBase_Production' ), 'M2_UEFNavalBaseMaintain')
    AIBuildStructures.AppendBuildingTemplate( ArmyBrains[UEF], 'UEF', ('M2_UEFNavalBase_Walls' ), 'M2_UEFNavalBaseMaintain')

    local navalSeaDef1 = ScenarioUtils.CreateArmyGroupAsPlatoon ( 'UEF', 'M2_UEFNavalBase_NavalPatrol1_'..DifficultyConc, 'AttackFormation' )
    -- local navalSeaDef2 = ScenarioUtils.CreateArmyGroupAsPlatoon ( 'UEF', 'M2_UEFNavalBase_NavalPatrol2_'..DifficultyConc, 'AttackFormation' ) #Commenting out. Made group 1 larger, and will use only it to cut down on congestion in naval area
    ScenarioFramework.PlatoonPatrolChain( navalSeaDef1, 'M2_UEFNaval_SeaPatrolChain_1' )
    -- ScenarioFramework.PlatoonPatrolChain( navalSeaDef2, 'M2_UEFNaval_SeaPatrolChain_2' )

    local navalAirDef1 = ScenarioUtils.CreateArmyGroupAsPlatoon ( 'UEF', 'M2_UEFNavalBase_AirPatrol1_'..DifficultyConc, 'NoFormation' )
    local navalAirDef2 = ScenarioUtils.CreateArmyGroupAsPlatoon ( 'UEF', 'M2_UEFNavalBase_AirPatrol2_'..DifficultyConc, 'NoFormation' )
    ScenarioFramework.PlatoonPatrolChain( navalAirDef1, 'M2_UEFNaval_AirPatrolChain_1' )
    ScenarioFramework.PlatoonPatrolChain( navalAirDef2, 'M2_UEFNaval_AirPatrolChain_2' )

    -- 4 general, not-base-specific patrols of gunships
    for i = 1,4 do
        local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon ( 'UEF', 'M2_UEFGunshipsPatrol'..i.. '_'..DifficultyConc, 'NoFormation' )
        ScenarioFramework.PlatoonPatrolChain( platoon, 'M2_UEFGunshipPatrolGeneral_Chain_'..i )
    end

    -- Create an offmap generator for Hex5, so when he comes onto the map, he has the power to run his Stealth.
    ScenarioInfo.Hex5_Offmap_Generator = ScenarioUtils.CreateArmyUnit ( 'Hex5', 'M2_Hex_Temporary_Generator' )
end

function M2_EnemyBanterFourMins()
    -- Enemy CDR banter, at four minutes
    ScenarioFramework.Dialogue(OpStrings.C05_M02_020)
end

function M2_UnlockAirSup()
    -- Unlock Air Superiority Fighters, associated dialogue
    ScenarioFramework.Dialogue(OpStrings.C05_M02_040)
    M2_BuildCategories2()
end

function M2_EnemyTaunt()
    if ScenarioInfo.MissionNumber == 2 then
        ScenarioFramework.Dialogue(OpStrings.TAUNT1)
    end
end

function M2_BeginSecondNavalAttack()
    -- Begin occasional (every ten minutes or so) extra attacks to compliment the standard naval attacks.
    -- Delayed, so we dont start the mission with both attacks simultaneously.
    ScenarioInfo.VarTable['M2_DelayedNaval'] = true
end

function M2_UEFNavalBaseDestroyed()
    ScenarioFramework.Dialogue( OpStrings.C05_M02_050 )
    ScenarioFramework.Dialogue(ScenarioStrings.SObjComp)

-- Navalbase destroyed cam
    local camInfo = {
        blendTime = 1,
        holdTime = 4,
        orientationOffset = { 0.72, 0.35, 0 },
        positionOffset = { 0, 0.75, 0 },
        zoomVal = 65,
        markerCam = true,
    }
    ScenarioFramework.OperationNISCamera( ScenarioUtils.MarkerToPosition('NIS_M2_Navalbase'), camInfo )
end

function M2_OmniDestroyed(unit)
    ScenarioInfo.UEFOmniDestroyedCounter = ScenarioInfo.UEFOmniDestroyedCounter + 1
    if ScenarioInfo.UEFOmniDestroyedCounter == 1 then
        -- Taunt/banter from enemy CDR
        ScenarioFramework.Dialogue(OpStrings.C05_M02_030)
        ScenarioFramework.Dialogue(OpStrings.C05_M02_060)
        ScenarioFramework.CreateTimerTrigger(M2_OmniTriggeredTaunt1, 75) -- taunt
    end
    if ScenarioInfo.UEFOmniDestroyedCounter == 2 then
        ScenarioFramework.Dialogue(OpStrings.C05_M02_070)
        ScenarioFramework.CreateTimerTrigger(M2_OmniTriggeredTaunt2, 75) -- taunt
    end
    if ScenarioInfo.UEFOmniDestroyedCounter == 3 then
        -- Flag as done, so we don't try to do anything with the research facility.
        ScenarioInfo.M2_OmniObjCompleted = true
        ScenarioFramework.Dialogue(OpStrings.C05_M02_080)
        ScenarioFramework.Dialogue(ScenarioStrings.PObjComp)
        ScenarioInfo.M2P1Complete = true
        M2_Hex5Appears()
    end

-- Omni Destroyed Camera
    local camInfo = {
        blendTime = 1.0,
        holdTime = 4,
        orientationOffset = { 0, 0.1, 0 },
        positionOffset = { 0, 1, 0 },
        zoomVal = 25,
    }
    if unit == ScenarioInfo.M2_UEFOmniEast then
        camInfo.orientationOffset[1] = 1.3
        camInfo.zoomVal = 45
    elseif unit == ScenarioInfo.M2_UEFOmniNorth then
        camInfo.orientationOffset[1] = 0.9269
    elseif unit == ScenarioInfo.M2_UEFOmniSouthWest then
        camInfo.orientationOffset[1] = 2.55
    end
    ScenarioFramework.OperationNISCamera(unit, camInfo )
end

function M2_OmniTriggeredTaunt1()
    if ScenarioInfo.MissionNumber == 2 then
        ScenarioFramework.Dialogue(OpStrings.TAUNT3)
    end
end

function M2_OmniTriggeredTaunt2()
    if ScenarioInfo.MissionNumber == 2 then
        ScenarioFramework.Dialogue(OpStrings.TAUNT6)
    end
end

 --- Hex5 related functions

function M2_Hex5Appears()
    -- Assign the Obj to get to Hex5
-- ScenarioFramework.AddObjective('primary', 'incomplete', OpStrings.M2P2Text, OpStrings.M2P2Detail, Objectives.GetActionIcon('move')) #"Reach Hex5 with Your Commander"
    ScenarioFramework.Dialogue(ScenarioStrings.NewPObj)
    ScenarioFramework.CreateTimerTrigger(M2P2Reminder1, Reminder_M2P2_Initial)
    ScenarioInfo.M2P2 = Objectives.Basic(
        'primary',
        'incomplete',
        OpStrings.M2P2Text,
        OpStrings.M2P2Detail,
        Objectives.GetActionIcon('move'),
        {
            Area = 'M2_Hex5ObjectiveMarker',
            MarkArea = true,
        }
    )

    -- Objective Marker showing destination/location of Hex5

    -- Create Hex5 and Transport, set flags for each.
    ScenarioInfo.M2_Hex5Platoon  = ScenarioUtils.SpawnPlatoon( 'Hex5', 'M2_Hex5Platoon' )
    ScenarioInfo.M2_Hex5_Commander = ScenarioInfo.UnitNames[Hex5]['M2_Hex5_Commander']
    ScenarioInfo.M2_Hex5_Transport = ScenarioInfo.UnitNames[Hex5]['M2_Hex5_Transport']

    ScenarioInfo.M2_Hex5_Commander:SetReclaimable(false)
    ScenarioInfo.M2_Hex5_Commander:SetCapturable(false)
    ScenarioInfo.M2_Hex5_Commander:SetCanBeKilled(false)
    ScenarioInfo.M2_Hex5_Commander:SetCanTakeDamage(false)

    ScenarioInfo.M2_Hex5_Transport:SetReclaimable(false)
    ScenarioInfo.M2_Hex5_Transport:SetCapturable(false)
    ScenarioInfo.M2_Hex5_Transport:SetCanBeKilled(false)
    ScenarioInfo.M2_Hex5_Transport:SetCanTakeDamage(false)

    ScenarioInfo.M2_Hex5_Commander:SetCustomName(LOC '{i R05_Hex5Name}')

    -- Give him cloaking, and turn it on
    ScenarioInfo.M2_Hex5_Commander:InitIntel(3,'CloakField', 8)
    ScenarioInfo.M2_Hex5_Commander:EnableIntel('CloakField')

    -- Send him to the location, create a trigger that detects when he gets near the location so we can uncloak him,
    -- and fork a thread to check when he is unloaded
    ScenarioFramework.AttachUnitsToTransports( {ScenarioInfo.M2_Hex5_Commander}, {ScenarioInfo.M2_Hex5_Transport} )
    ScenarioInfo.M2_CommandHex5Unload = ScenarioInfo.M2_Hex5Platoon:UnloadAllAtLocation( ScenarioUtils.MarkerToPosition('M2_Hex5TransportPoint') )
    ScenarioFramework.CreateAreaTrigger( M2_UncloakHex5, ScenarioUtils.AreaToRect('M2_Hex5Area'), categories.ura0104, true, false, ArmyBrains[Hex5], 1, false)
    ForkThread(M2_Hex5UnloadCheckThread)
end

function M2_UncloakHex5()
    ScenarioInfo.M2_Hex5_Commander:DisableIntel('CloakField')
    SetAlliance( Player1, Hex5, 'Ally' )
    SetAlliance( Hex5, Player1, 'Ally' )

-- Now that Hex5 has been uncloaked enroute to his landing area, kick off the NIS
    WaitSeconds(2)
    local unit = ScenarioInfo.M2_Hex5_Commander
    local camInfo = {
        blendTime = 1.0,
        holdTime = 4,
        orientationOffset = { -2.2, 0.1, 0 },
        positionOffset = { 0, 0.5, 0 },
        zoomVal = 55,
        markerCam = true,
    }
    ScenarioFramework.OperationNISCamera( ScenarioUtils.MarkerToPosition('NIS_M2_Hex5Intro'), camInfo )
end

function M2_Hex5UnloadCheckThread()
    while ScenarioInfo.M2_Hex5Platoon:IsCommandsActive( ScenarioInfo.M2_CommandHex5Unload ) == true do
        WaitSeconds(1)
    end

    -- Move Hex5 away from his transport a bit, and give him a brief time in which to do so
    IssueMove( {ScenarioInfo.M2_Hex5_Commander}, ScenarioUtils.MarkerToPosition('M2_Hex5WalkPoint'))
    WaitSeconds(3)

    -- Once Hex5 is in the area and uncloaked etc, create a trigger to see if the player CDR is present.
    ScenarioFramework.CreateAreaTrigger( M2_DownloadToCommander, ScenarioUtils.AreaToRect('M2_Hex5Area'), categories.url0001, true, false, ArmyBrains[Player1], 1, false)
end

function M2_DownloadToCommander()
    -- Fork thread, so we can have a slight pause before we do the download stuff
    ForkThread(M2_DownloadToCommanderThread)
end

function M2_DownloadToCommanderThread()
    -- Pause so the dialogue/download doesnt happen *immediately* after hitting the area
    WaitSeconds(3)
    ScenarioFramework.Dialogue(OpStrings.C05_M02_090)

-- Hex5 Download Cam
    local camInfo = {
        blendTime = 1.0,
        holdTime = 4,
        orientationOffset = { -2.2, 0.4, 0 },
        positionOffset = { 0, 0.5, 0 },
        zoomVal = 35,
        markerCam = true,
    }
    ScenarioFramework.OperationNISCamera( ScenarioUtils.MarkerToPosition('NIS_M2_Hex5Intro'), camInfo )

    -- Pause a bit to keep hex5 moving taking place after his bit of dialogue plays (instead of at the start of it)
    WaitSeconds(5)

    -- Complete the Hex5 Obj, and assign the Gunship Attack objective
    ScenarioInfo.M2P2:ManualResult(true) -- "Reach Hex5 with Your Commander"
    ScenarioFramework.Dialogue(ScenarioStrings.PObjComp)

    ScenarioInfo.M2P3 = Objectives.Basic(    -- "Defends against incoming gunship attack"
        'primary',
        'incomplete',
        OpStrings.M2P3Text,
        OpStrings.M2P3Detail,
        Objectives.GetActionIcon('protect'),
        {
        }
    )
    ScenarioFramework.Dialogue(ScenarioStrings.NewPObj)
    ScenarioInfo.M2P2Complete = true

    -- Hex5 moves out, heads offmap. Fork thread to check for when his load command is complete, so we can then recloak him.
    ScenarioInfo.M2_Hex5LoadToLeaveCommand = ScenarioInfo.M2_Hex5Platoon:LoadUnits( categories.ALLUNITS )
    ScenarioInfo.M2_Hex5Platoon:MoveToLocation( ScenarioUtils.MarkerToPosition('M2_Hex5_ReturnPoint'), false )
    ScenarioInfo.M2_Hex5Platoon:Destroy()
    ForkThread(M2_Hex5ReloadAndLeaveCheckThread)

    -- Spawn in Gunship Attack, as thread so we can add delays as needed
    ForkThread(M2_UEFGunshipAttackThread)
end

function M2_Hex5ReloadAndLeaveCheckThread()
--    while ScenarioInfo.M2_Hex5Platoon:IsCommandsActive( ScenarioInfo.M2_Hex5LoadToLeaveCommand ) == true do
    WaitSeconds(4)
--    end
    -- Do Stuff
    ForkThread(M2_ActivateHex5CloakThread)
end

function M2_ActivateHex5CloakThread()
    -- Pause before we reenable the cloak, so we see the transport begin moving first (purely for effect)
    WaitSeconds(3)
    -- Set Hex5 back to neutral, so we lose line-of-site
    SetAlliance( Player1, Hex5, 'Neutral' )
    SetAlliance( Hex5, Player1, 'Neutral' )
    ScenarioInfo.M2_Hex5_Commander:EnableIntel('CloakField')
end

function M2_UEFGunshipAttackThread()
    -- Pause a bit, so that this delay + travel time = about two minutes
    WaitSeconds(M2_GunshipAttackDelay)
    ScenarioInfo.M2_GunshipAttackPlatoon1 = ScenarioUtils.CreateArmyGroupAsPlatoon ( 'UEF', 'M2_UEFGunshipAttack1_'..DifficultyConc, 'NoFormation' )
    ScenarioInfo.M2_GunshipAttackPlatoon2 = ScenarioUtils.CreateArmyGroupAsPlatoon ( 'UEF', 'M2_UEFGunshipAttack2_'..DifficultyConc, 'NoFormation' )

    ScenarioFramework.CreatePlatoonDeathTrigger ( M2_GunshipAttackDefeated, ScenarioInfo.M2_GunshipAttackPlatoon1 )
    ScenarioFramework.CreatePlatoonDeathTrigger ( M2_GunshipAttackDefeated, ScenarioInfo.M2_GunshipAttackPlatoon2 )
    ScenarioFramework.PlatoonPatrolChain( ScenarioInfo.M2_GunshipAttackPlatoon1, 'M2_UEFGunshipAttack_Chain2' )
    ScenarioFramework.PlatoonPatrolChain( ScenarioInfo.M2_GunshipAttackPlatoon2, 'M2_UEFGunshipAttack_Chain1' )

    -- Med/Hard, add in some guarding air units
    if Difficulty > 1 then
        local guards = ScenarioUtils.CreateArmyGroupAsPlatoon ( 'UEF', 'M2_UEFGunshipAttackEscort_'..DifficultyConc, 'AttackFormation' )
        local target = ScenarioInfo.UnitNames[UEF]['M2_MedGunship_Point']
        guards:GuardTarget( target )
        ScenarioFramework.PlatoonPatrolChain( guards, 'M2_UEFGunshipAttack_Chain1' )
    end
end

function M2_GunshipAttackDefeated()
    ScenarioInfo.M2_FinalGunshipGroupsDefeated = ScenarioInfo.M2_FinalGunshipGroupsDefeated + 1
    if ScenarioInfo.M2_FinalGunshipGroupsDefeated == 2 then
        -- Complete mission/objective, start M3 with a pause
        ScenarioInfo.M2P3:ManualResult(true) -- "Defends against incoming gunship attack"
        ScenarioFramework.Dialogue(OpStrings.C05_M02_120, BeginMission3)
    end
end

 --- Hard difficulty M2 offmap attacks

 --- Land (west)

function M2_Hard_OffmapAttack_Counter()
    ScenarioInfo.M2_OffmapPlatoonsDead = ScenarioInfo.M2_OffmapPlatoonsDead + 1
    if ScenarioInfo.M2_OffmapPlatoonsDead == 4 then
        ScenarioInfo.M2_OffmapPlatoonsDead = 0
        ScenarioFramework.CreateTimerTrigger(M2_Hard_OffmapTransAttack, M2_OffmapAttack_Land_Delay)
    end
end

function M2_Hard_OffmapTransAttack()
    ForkThread(M2_Hard_OffmapTransAttack_Thread)
end

function M2_Hard_OffmapTransAttack_Thread()
    if ScenarioInfo.MissionNumber == 2 and Difficulty == 3 then
        -- Track number of attacks we've sent
        ScenarioInfo.M2_Hard_OffmapAttackCount = ScenarioInfo.M2_Hard_OffmapAttackCount + 1

        -- 1 - 4, to choose which spot we'll land at
        local rnd = Random(1,4)

        -- Do some normal sized attacks for a while, and eventually kick it up a notch by adding a tougher transport in.
        if ScenarioInfo.M2_Hard_OffmapAttackCount < 3  then
            for i = 1,4 do
                local transport =  ScenarioUtils.CreateArmyGroupAsPlatoon ( 'UEF', 'M2_UEF_Offscreen_Land_Transport', 'ChevronFormation' )
                local units = ScenarioUtils.CreateArmyGroupAsPlatoon ( 'UEF', 'M2_UEF_Offscreen_LandUnits1', 'AttackFormation' )
                local escort =  ScenarioUtils.CreateArmyGroupAsPlatoon ( 'UEF', 'M2_UEF_Offscreen_Land_AirEscort', 'ChevronFormation' )
                M2_Hard_Offmap_AddEscort(escort,transport)
                ForkThread(TransportAttack, transport, units, 2,  'PlayerBase_Attack_'..rnd, 'Player_Base_LandAttackChain')
                ScenarioFramework.CreatePlatoonDeathTrigger(M2_Hard_OffmapAttack_Counter, units)
                WaitSeconds(0.3)
            end
        else
            for i = 1,4 do
                local transport =  ScenarioUtils.CreateArmyGroupAsPlatoon ( 'UEF', 'M2_UEF_Offscreen_Land_Transport', 'ChevronFormation' )
                local units = ScenarioUtils.CreateArmyGroupAsPlatoon ( 'UEF', 'M2_UEF_Offscreen_LandUnits1', 'AttackFormation' )
                local escort =  ScenarioUtils.CreateArmyGroupAsPlatoon ( 'UEF', 'M2_UEF_Offscreen_Land_AirEscort', 'ChevronFormation' )
                M2_Hard_Offmap_AddEscort(escort,transport)
                ForkThread(TransportAttack, transport, units, 2,  'PlayerBase_Attack_'..rnd, 'Player_Base_LandAttackChain')
                ScenarioFramework.CreatePlatoonDeathTrigger(M2_Hard_OffmapAttack_Counter, units)
                WaitSeconds(0.3)
            end
            local transport =  ScenarioUtils.CreateArmyGroupAsPlatoon ( 'UEF', 'M2_UEF_Offscreen_Land_Transport', 'ChevronFormation' )
            local units = ScenarioUtils.CreateArmyGroupAsPlatoon ( 'UEF', 'M2_UEF_Offscreen_LandUnits2', 'AttackFormation' )
            local escort =  ScenarioUtils.CreateArmyGroupAsPlatoon ( 'UEF', 'M2_UEF_Offscreen_Land_AirEscort', 'ChevronFormation' )
            M2_Hard_Offmap_AddEscort(escort,transport)
            ForkThread(TransportAttack, transport, units, 2,  'PlayerBase_Attack_'..rnd, 'Player_Base_LandAttackChain')
        end
    end
end

function M2_Hard_Offmap_AddEscort(escort, transport)
    transUnit = transport:GetPlatoonUnits()
    escort:GuardTarget (transUnit[1], 'Attack')
    ScenarioFramework.PlatoonPatrolChain( escort, 'M2_UEFGunshipAttack_Chain2' )
end

 --- Air (South)

function M2_Hard_OffmapAirAttack_Counter()
    -- increment counter for each platoon death
    ScenarioInfo.M2_OffmapAirDead = ScenarioInfo.M2_OffmapAirDead + 1

    -- if the number of platoons killed matches the number created,
    if ScenarioInfo.M2_OffmapAirDead == ScenarioInfo.M2_Hard_OffMapAirDeath then

        -- reset, and begin a timer for an attack again
        ScenarioInfo.M2_OffmapAirDead = 0
        if ScenarioInfo.M2_Hard_OffmapAir_Count <= 5 then
            ScenarioFramework.CreateTimerTrigger(M2_Hard_OffmapAirAttack, M2_OffmapAttack_Air_Delay)
        else
            ScenarioFramework.CreateTimerTrigger(M2_Hard_OffmapAirAttack, M2_OffmapAttack_Air_Delay2)
        end
    end
end

function M2_Hard_OffmapAirAttack()
    ForkThread(M2_Hard_OffmapAirAttack_Thread)
end

function M2_Hard_OffmapAirAttack_Thread()
    if ScenarioInfo.MissionNumber == 2 and Difficulty == 3 then
        ScenarioInfo.M2_Hard_OffmapAir_Count = ScenarioInfo.M2_Hard_OffmapAir_Count + 1

        -- 3 types of attacks, each using a different number of instances of the base platoon, and a death trigger for each to track.
        -- Set the count-to to that number of platoons. Final attack uses a "tougher" gruop as well.
        if ScenarioInfo.M2_Hard_OffmapAir_Count <= 1 then
            for i = 1,1 do
                local air =  ScenarioUtils.CreateArmyGroupAsPlatoon ( 'UEF', 'M2_UEF_Offscreen_AirUnits_1', 'ChevronFormation' )
                ScenarioFramework.PlatoonPatrolChain( air, 'M1_UEFAirAttack2_Chain' )
                ScenarioFramework.CreatePlatoonDeathTrigger(M2_Hard_OffmapAirAttack_Counter, air)
                WaitSeconds(1.5)
            end
            ScenarioInfo.M2_Hard_OffMapAirDeath = 1
        elseif ScenarioInfo.M2_Hard_OffmapAir_Count > 1 and ScenarioInfo.M2_Hard_OffmapAir_Count <= 5 then
            for i = 1,2 do
                local air =  ScenarioUtils.CreateArmyGroupAsPlatoon ( 'UEF', 'M2_UEF_Offscreen_AirUnits_1', 'ChevronFormation' )
                ScenarioFramework.PlatoonPatrolChain( air, 'M1_UEFAirAttack2_Chain' )
                ScenarioFramework.CreatePlatoonDeathTrigger(M2_Hard_OffmapAirAttack_Counter, air)
                WaitSeconds(1.5)
            end
            ScenarioInfo.M2_Hard_OffMapAirDeath = 2
        elseif ScenarioInfo.M2_Hard_OffmapAir_Count > 5 then
            for i = 1,2 do
                local air = ScenarioUtils.CreateArmyGroupAsPlatoon ( 'UEF', 'M2_UEF_Offscreen_AirUnits_1', 'ChevronFormation' )
                ScenarioFramework.PlatoonPatrolChain( air, 'M1_UEFAirAttack2_Chain' )
                ScenarioFramework.CreatePlatoonDeathTrigger(M2_Hard_OffmapAirAttack_Counter, air)
                WaitSeconds(1.5)
            end
            local air =  ScenarioUtils.CreateArmyGroupAsPlatoon ( 'UEF', 'M2_UEF_Offscreen_AirUnits_2', 'ChevronFormation' )
            ScenarioFramework.PlatoonPatrolChain( air, 'M1_UEFAirAttack2_Chain' )
            ScenarioFramework.CreatePlatoonDeathTrigger(M2_Hard_OffmapAirAttack_Counter, air)
            ScenarioInfo.M2_Hard_OffMapAirDeath = 3
        end
    end
end

--------------
-- Mission 3
--------------

function BeginMission3()
    ScenarioFramework.SetSharedUnitCap(720)
    M3_CreateUnitsForMission()
    ScenarioInfo.MissionNumber = 3
    ScenarioFramework.SetPlayableArea( ScenarioUtils.AreaToRect('M3_PlayableArea') )

    -- Obj
    ScenarioFramework.Dialogue(OpStrings.C05_M03_010)
    ScenarioFramework.Dialogue(OpStrings.C05_M03_030)
    M3_BuildCategories()

    ScenarioInfo.M3P1 = Objectives.KillOrCapture(   -- Kill enemy Commander
        'primary',                      -- type
        'incomplete',                   -- complete
        OpStrings.M3P1Text,             -- title
        OpStrings.M3P1Detail,           -- description
        {                               -- target
            Units = {ScenarioInfo.M3_UEFMainBase_Commander},
        }
    )
    ScenarioInfo.M3P1:AddResultCallback(
        function()
            M3_UEFCommanderDestroyed()
        end
    )

    ScenarioInfo.M3S1 = Objectives.Basic(    -- Gunship Virus, secondary
        'secondary',
        'incomplete',
        OpStrings.M3S1Text,
        OpStrings.M3S1Detail,
        Objectives.GetActionIcon('move'),
        {
            Units = ScenarioInfo.M3_UEFAirBase_ASPlatforms,
            MarkUnits = true,
            FlashVisible = true,
        }
    )

    ScenarioFramework.Dialogue(ScenarioStrings.NewSObj)
    ScenarioFramework.Dialogue(ScenarioStrings.NewPObj)
    ScenarioFramework.CreateTimerTrigger(M3P1Reminder1, Reminder_M3P1_Initial)

    -- Trigger to detect land units of player at UEF backbase
    ScenarioFramework.CreateAreaTrigger( M3_PlayerAtUEFBackBase, ScenarioUtils.AreaToRect('M3_UEFBackBaseArea'), categories.LAND, true, false, ArmyBrains[Player1], 1, false)

    -- Destroy Hex5's offmap generator from M2
    if not ScenarioInfo.Hex5_Offmap_Generator:IsDead() then
        ScenarioInfo.Hex5_Offmap_Generator:Destroy()
    end

    -- Timed dialogue
    ScenarioFramework.CreateTimerTrigger (M3_GodwynThreat1, 60)

    -- If player gets near the souther prison colony, explain what it is
    ScenarioFramework.CreateAreaTrigger( M2_ColonyDialogue, ScenarioUtils.AreaToRect('M3_PrisonColonyArea'), categories.ALLUNITS, true, false, ArmyBrains[Player1], 1, false)
end

function M3_CreateUnitsForMission()
    -- Spawn 3 smallish groups of gunships, so we definitely see gunships early
    for i=1,3 do
        local gunshipPlatoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF' ,'M3_UEF_GunshipAttack_'..i..'_'..DifficultyConc ,'NoFormation')
        gunshipPlatoon:ForkAIThread (ScenarioPlatoonAI.PlatoonAttackHighestThreat)
        ScenarioFramework.CreatePlatoonDeathTrigger(M3_InitialGunshipTaunt, gunshipPlatoon)
    end

    -- Create Air Base, area trigger at Platfrom to start the engineer check
    ScenarioUtils.CreateArmyGroup ( 'UEF', 'M3_UEFAirBase_'..DifficultyConc )
    ScenarioUtils.CreateArmyGroup ( 'UEF', 'M3_UEFAirBase_Walls' )
    ScenarioUtils.CreateArmyGroup ( 'UEF', 'M3_UEFAirBase_Production_Factories' )
    ScenarioUtils.CreateArmyGroup ( 'UEF', 'M3_UEFAirBase_Production_Sundry' )
    ScenarioUtils.CreateArmyGroup ( 'UEF', 'M3_UEFAirBase_AssistEngineers_'..DifficultyConc )

    local airDef1 = ScenarioUtils.CreateArmyGroupAsPlatoon ( 'UEF', 'M3_UEFAirBase_AirPatrol1_'..DifficultyConc, 'NoFormation' )
    local airDef2 = ScenarioUtils.CreateArmyGroupAsPlatoon ( 'UEF', 'M3_UEFAirBase_AirPatrol2_'..DifficultyConc, 'NoFormation' )
    local landDef2 = ScenarioUtils.CreateArmyGroupAsPlatoon ( 'UEF', 'M3_UEFAirBase_LandPatrol1_'..DifficultyConc, 'AttackFormation' )
    ScenarioFramework.PlatoonPatrolChain( airDef1, 'M3_UEFAir_AirPatrolChain_1' )
    ScenarioFramework.PlatoonPatrolChain( airDef2, 'M3_UEFAir_AirPatrolChain_2' )
    ScenarioFramework.PlatoonPatrolChain( landDef2, 'M3_UEFAir_LandPatrolChain_1' )

      --- fail the gunship virus obj if all the platforms get destroyed
    ScenarioInfo.M3_UEFAirBase_ASPlatforms = ScenarioUtils.CreateArmyGroup ( 'UEF', 'M3_UEFAirBase_Platforms' )
    ScenarioFramework.CreateGroupDeathTrigger( M3_PlatformsDestroyedObjFail, ScenarioInfo.M3_UEFAirBase_ASPlatforms )

      --- capture triggers for each plat, to start the gunship destruction
    for k,unit in ScenarioInfo.M3_UEFAirBase_ASPlatforms do
        ScenarioFramework.CreateUnitCapturedTrigger( M3_StartGunshipDestroy, nil, unit )
        unit:SetDoNotTarget(true)
    end

      --- Append build templates for base maintenence
    AIBuildStructures.CreateBuildingTemplate( ArmyBrains[UEF], 'UEF', 'M3_UEFAirBaseMaintainBase' )
    AIBuildStructures.AppendBuildingTemplate( ArmyBrains[UEF], 'UEF', ('M3_UEFAirBase_'..DifficultyConc), 'M3_UEFAirBaseMaintainBase')
    AIBuildStructures.AppendBuildingTemplate( ArmyBrains[UEF], 'UEF', ('M3_UEFAirBase_Production_Sundry'), 'M3_UEFAirBaseMaintainBase')
    AIBuildStructures.AppendBuildingTemplate( ArmyBrains[UEF], 'UEF', ('M3_UEFAirBase_Platforms' ), 'M3_UEFAirBaseMaintainBase')
    AIBuildStructures.AppendBuildingTemplate( ArmyBrains[UEF], 'UEF', ('M3_UEFAirBase_Walls' ), 'M3_UEFAirBaseMaintainBase')
    AIBuildStructures.AppendBuildingTemplate( ArmyBrains[UEF], 'UEF', ('M3_UEFAirBase_Production_Factories' ), 'M3_UEFAirBaseMaintainBase')

    -- Create the Hex5 Prison building (at main base), and the southern Penal Colony
    ScenarioUtils.CreateArmyGroup ( 'FauxUEF', 'M3_FauxUEF_Base_Prison' )
    ScenarioInfo.M2_FauxUEF_PrisonBuilding = ScenarioUtils.CreateArmyUnit ( 'FauxUEF', 'M3_FauxUEF_PrisonBuilding' )
    ScenarioFramework.CreateUnitDeathTrigger( M3_Hex5Destroyed, ScenarioInfo.M2_FauxUEF_PrisonBuilding )
    ScenarioFramework.CreateUnitReclaimedTrigger( M3_Hex5Destroyed, ScenarioInfo.M2_FauxUEF_PrisonBuilding )
    ScenarioFramework.CreateUnitCapturedTrigger( nil, M3_PrisonCaptured, ScenarioInfo.M2_FauxUEF_PrisonBuilding )
    ScenarioInfo.M3_FauxUEF_PrisonShieldUnit = ScenarioUtils.CreateArmyUnit ( 'FauxUEF', 'M3_FauxUEF_PrisonShieldUnit' )
    ScenarioInfo.M3_FauxUEF_PrisonShieldUnit:ToggleScriptBit('RULEUTC_ShieldToggle')
    ScenarioInfo.M2_FauxUEF_PrisonBuilding:SetCustomName(LOC '{i R05_Hex5Prison}')
    ScenarioFramework.PauseUnitDeath( ScenarioInfo.M2_FauxUEF_PrisonBuilding )

    ScenarioUtils.CreateArmyGroup ( 'FauxUEF', 'M3_FauxUEF_Colony_Structures' )
    ScenarioInfo.M3_ColonyPrisonBuilding = ScenarioUtils.CreateArmyUnit ( 'FauxUEF', 'M3_FauxUEF_PrisonUnit' )
    ScenarioInfo.M3_FauxUEF_ColonyShield = ScenarioUtils.CreateArmyUnit ( 'FauxUEF', 'M3_FauxUEF_ColonyShield' )
    ScenarioInfo.M3_FauxUEF_ColonyShield:ToggleScriptBit('RULEUTC_ShieldToggle')
    ScenarioInfo.M3_ColonyPrisonBuilding:SetCustomName(LOC '{i R05_GeneralPrison}')

    -- Create UEF Main base
      --- Base and engineers
    ScenarioUtils.CreateArmyGroup ( 'UEF', 'M3_UEFMainBase_'..DifficultyConc )
    ScenarioUtils.CreateArmyGroup ( 'UEF', 'M3_UEFMainBase_Production_Sundry' )
    ScenarioUtils.CreateArmyGroup ( 'UEF', 'M3_UEFMainBase_Walls' )
    ScenarioUtils.CreateArmyGroup ( 'UEF', 'M3_UEFMainBase_Production_Factories' )
    ScenarioUtils.CreateArmyGroup ( 'UEF', 'M3_UEFMainBase_Production_AssistEngineers_'..DifficultyConc )

      --- take the uef TMLs, enable them
    EnableTMLPlatoon('M3_UEF_TML')
    if Difficulty > 1 then
        EnableTMLPlatoon('M3_UEF_TML2')
    end

      --- Append template for base maintain
    AIBuildStructures.CreateBuildingTemplate( ArmyBrains[UEF], 'UEF', 'M3_UEFMainBaseMaintainBase' )
    if Difficulty == 3 then
        AIBuildStructures.AppendBuildingTemplate( ArmyBrains[UEF], 'UEF', ('M3_UEFMainBase_'..DifficultyConc), 'M3_UEFMainBaseMaintainBase')
        AIBuildStructures.AppendBuildingTemplate( ArmyBrains[UEF], 'UEF', ('M3_UEFMainBase_Production'), 'M3_UEFMainBaseMaintainBase')
        AIBuildStructures.AppendBuildingTemplate( ArmyBrains[UEF], 'UEF', ('M3_UEFMainBase_Walls'), 'M3_UEFMainBaseMaintainBase')
    end

      --- base patrols
    local mainAirDef1 = ScenarioUtils.CreateArmyGroupAsPlatoon ( 'UEF', 'M3_UEFMainBase_AirPatrol1_'..DifficultyConc, 'NoFormation' )
    local mainAirDef2 = ScenarioUtils.CreateArmyGroupAsPlatoon ( 'UEF', 'M3_UEFMainBase_AirPatrol2_'..DifficultyConc, 'NoFormation' )
    local mainLandDef1 = ScenarioUtils.CreateArmyGroupAsPlatoon ( 'UEF', 'M3_UEFMainBase_LandPatrol1_'..DifficultyConc, 'AttackFormation' )
    local mainLandDef2 = ScenarioUtils.CreateArmyGroupAsPlatoon ( 'UEF', 'M3_UEFMainBase_LandPatrol2_'..DifficultyConc, 'AttackFormation' )
    ScenarioFramework.PlatoonPatrolChain( mainAirDef1, 'M3_UEFMainBase_AirPatrolChain_1' )
    ScenarioFramework.PlatoonPatrolChain( mainAirDef2, 'M3_UEFMainBase_AirPatrolChain_2' )
    ScenarioFramework.PlatoonPatrolChain( mainLandDef1, 'M3_UEFMainBase_LandPatrolChain_1' )
    ScenarioFramework.PlatoonPatrolChain( mainLandDef2, 'M3_UEFMainBase_LandPatrolChain_2' )
      --- CDR with a shield, death trigger, patrol
    ScenarioInfo.M3_UEFMainBase_Commander = ScenarioUtils.CreateArmyUnit ( 'UEF', 'M3_UEFMainBase_Commander' )
    ScenarioInfo.M3_UEFMainBase_Commander:CreateEnhancement( 'ShieldGeneratorField' )
    ScenarioInfo.M3_UEFMainBase_Commander:CreateEnhancement( 'ResourceAllocation' )
    ScenarioInfo.M3_UEFMainBase_Commander:CreateEnhancement( 'DamageStabilization' )
    IssuePatrol( {ScenarioInfo.M3_UEFMainBase_Commander}, ScenarioUtils.MarkerToPosition('M3_UEFMainBase_CDRPatrol_1'))
    IssuePatrol( {ScenarioInfo.M3_UEFMainBase_Commander}, ScenarioUtils.MarkerToPosition('M3_UEFMainBase_CDRPatrol_2'))
    ScenarioInfo.M3_UEFMainBase_Commander:SetCustomName(LOC '{i R05_UEFCommander}')
    ScenarioFramework.PauseUnitDeath( ScenarioInfo.M3_UEFMainBase_Commander )
     -- Overcharge manager
    local cdrPlatoon = ArmyBrains[UEF]:MakePlatoon(' ', ' ')
    cdrPlatoon.CDRData = {}
    cdrPlatoon.CDRData.LeashPosition = 'UEF_Commander_Leash'
    cdrPlatoon.CDRData.LeashRadius = 34
    ArmyBrains[UEF]:AssignUnitsToPlatoon( cdrPlatoon, {ScenarioInfo.M3_UEFMainBase_Commander}, 'Attack', 'AttackFormation' )
    import('/lua/ai/AIBehaviors.lua').CommanderBehavior(cdrPlatoon)
    ArmyBrains[UEF]:DisbandPlatoon(cdrPlatoon)

     --- hard difficulty: air superiority patrols, aa patrols, a few engineers to guard CDR
    if Difficulty == 3 then
        local mainExtraAir1 = ScenarioUtils.CreateArmyGroupAsPlatoon ( 'UEF', 'M3_UEFMainBase_AirPatrol3a', 'NoFormation' )
        local mainExtraAir2 = ScenarioUtils.CreateArmyGroupAsPlatoon ( 'UEF', 'M3_UEFMainBase_AirPatrol3b', 'NoFormation' )
        ScenarioFramework.PlatoonPatrolChain( mainExtraAir1, 'M3_UEFMain_Air_HardNorth_Chain' )
        ScenarioFramework.PlatoonPatrolChain( mainExtraAir2, 'M3_UEFMain_Air_HardSouth_Chain' )

        local mainExtraAA1 = ScenarioUtils.CreateArmyGroupAsPlatoon ( 'UEF', 'M3_UEFMainBase_LandPatrol3a', 'AttackFormation' )
        local mainExtraAA2 = ScenarioUtils.CreateArmyGroupAsPlatoon ( 'UEF', 'M3_UEFMainBase_LandPatrol3b', 'AttackFormation' )
        ScenarioFramework.PlatoonPatrolChain( mainExtraAA1, 'M3_UEFMain_AA_HardNorth_Chain' )
        ScenarioFramework.PlatoonPatrolChain( mainExtraAA2, 'M3_UEFMain_AA_HardSouth_Chain' )

        --- engineers guard cdr
        local guards = ScenarioUtils.CreateArmyGroup ( 'UEF', 'M3_UEFMainBase_CDRguards' )
        for k,v in guards do
            IssueGuard( {v}, ScenarioInfo.M3_UEFMainBase_Commander )
        end
    end

    -- Create 4 non-base-specific gunship patrols that wander around the map
    for i = 1,4 do
        local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon ( 'UEF', 'M3_UEFGunshipsPatrol'..i.. '_'..DifficultyConc, 'NoFormation' )
        ScenarioFramework.PlatoonPatrolChain( platoon, 'M3_UEFGunshipPatrolGeneral_Chain_'..i )
    end
end

function M3_PrisonCaptured(unit)
    ScenarioFramework.CreateUnitCapturedTrigger( nil, M3_PrisonCaptured, unit )
    ScenarioFramework.CreateUnitDeathTrigger( M3_Hex5Destroyed, unit )
    ScenarioFramework.CreateUnitReclaimedTrigger( M3_Hex5Destroyed, unit )
    ScenarioInfo.M2_FauxUEF_PrisonBuilding = unit
end

function M3_InitialGunshipTaunt()
    M3_InitGunshipPlatsKilled = M3_InitGunshipPlatsKilled + 1
    if M3_InitGunshipPlatsKilled == 3 then
        if (not ScenarioInfo.M3_UEFMainBase_Commander:IsDead()) then
            ScenarioFramework.Dialogue(OpStrings.TAUNT7)
        end
    end
end

function EnableTMLPlatoon(unitName)
      --- take the uef TML, add it to a platoon, and give that platoon  tml ai.
    local uefTML = ScenarioInfo.UnitNames[UEF][unitName]
    local platoon = ArmyBrains[UEF]:MakePlatoon('', '')
    ArmyBrains[UEF]:AssignUnitsToPlatoon(platoon, {uefTML}, 'attack', 'AttackFormation')
    platoon:ForkAIThread(platoon.TacticalAI)
end

function M3_GodwynThreat1()
    ScenarioFramework.Dialogue(OpStrings.C05_M03_020)
end

function M2_ColonyDialogue()
    ScenarioFramework.Dialogue(OpStrings.C05_M03_060)
end

function M3_PlayerAtUEFBackBase()
    -- Tell PBM to start making patrols for the backbase area
    ScenarioInfo.VarTable['M3_PlayerAtUEFMainBase'] = true

    -- Add new back-base turrets to the base template
    AIBuildStructures.AppendBuildingTemplate( ArmyBrains[UEF], 'UEF', ('M3_UEFMainBase_ExpandBase'), 'M3_UEFMainBaseMaintainBase')
end

 --- Gunship Virus functions

function M3_PlatformsDestroyedObjFail()
    ScenarioInfo.M3_AirPlatformsDestroyed = true
    if ScenarioInfo.M3_VirusUploaded == false then
        ScenarioInfo.M3S1:ManualResult(false)
        ScenarioFramework.Dialogue(ScenarioStrings.SObjFail)
    end
end

function M3_StartGunshipDestroy()
    if ScenarioInfo.GunshipScenarioStarted == false then
        ScenarioInfo.GunshipScenarioStarted = true
        ForkThread(M3_UEFGunshipVirusThread)
    end
end

function M3_UEFGunshipVirusThread()
    -- get all uef gunships and toast them, with a slight pause between each
    -- (we want the destruction to last a bit, for looks).
    ScenarioFramework.AddRestriction( UEF, categories.uea0203 +  categories.uea0305 ) -- UEF Factories no longer can build gunships
    WaitTicks(1)
    -- Clear any gunships that factories may be building
    local uefFactories = ArmyBrains[UEF]:GetListOfUnits(categories.FACTORY * categories.AIR, false)
    for k,v in uefFactories do
        if (not v:IsDead()) and v.UnitBeingBuilt and not v.UnitBeingBuilt:IsDead() and EntityCategoryContains(categories.uea0203 + categories.uea0305, v.UnitBeingBuilt) then
            IssueClearCommands({v})
        end
    end

    -- Play dialogue, compete the Gunship Obj
    ScenarioInfo.M3S1:ManualResult(true)
    ScenarioFramework.Dialogue(ScenarioStrings.SObjComp)
    ScenarioFramework.Dialogue(OpStrings.C05_M03_050)

    ScenarioInfo.M3_VirusUploaded = true
    ScenarioInfo.VarTable['M3_VirusUpload'] = true  -- let pbm know that gunships can no longer be made
    local uefGunships = ArmyBrains[UEF]:GetListOfUnits(categories.uea0203 + categories.uea0305, false)
    for k, v in uefGunships do
        if not v:IsDead() then -- check that the gunship hasnt already been killed in the meantime.

            local pos = v:GetPosition()
            local spec = {
                X = pos[1],
                Z = pos[2],
                Radius = 16,
                LifeTime = 6,
                Omni = false,
                Vision = true,
                Army = 1,
            }
            local vizmarker = VizMarker(spec)
            vizmarker:AttachBoneTo(-1,v,-1)

            v:Kill()
            WaitSeconds(.55)
        end
    end

    -- Timer that will play some dialogue from enemy CDR that is his response to his gunships being destroyed
    ScenarioFramework.CreateTimerTrigger( M3_GodwynGunshipResponseDialogue, 15 )
end

function M3_GodwynGunshipResponseDialogue()
    -- Make sure we arent already in the process of ending the Op due to the enemy CDR being killed
    if ScenarioInfo.UEFCommanderDestroyed == false then
        ScenarioFramework.Dialogue(OpStrings.C05_M03_070)
        ScenarioFramework.CreateTimerTrigger( M3_GodwynGunshipTaunt, 60 )
    end
end

function M3_GodwynGunshipTaunt()
    if ScenarioInfo.UEFCommanderDestroyed == false then
        ScenarioFramework.Dialogue(OpStrings.TAUNT2)
    end
end

--------------
-- Miscellaneous Functions
--------------

function TransportAttack(transports, landPlat, brainNum, landingMarkerName, attackMarkerChain)
    ScenarioFramework.AttachUnitsToTransports(landPlat:GetPlatoonUnits(), transports:GetPlatoonUnits())
    local cmd = transports:UnloadAllAtLocation(ScenarioUtils.MarkerToPosition(landingMarkerName))
    while ArmyBrains[brainNum]:PlatoonExists(transports) and transports:IsCommandsActive(cmd) do
        WaitSeconds(1)
    end

    if ArmyBrains[brainNum]:PlatoonExists(landPlat) then
        for k,v in ScenarioUtils.ChainToPositions(attackMarkerChain) do
            landPlat:Patrol(v)
        end
    end

    if ArmyBrains[brainNum]:PlatoonExists(transports) then
        for k,v in ScenarioUtils.ChainToPositions(attackMarkerChain) do
            transports:Patrol(v)
        end
    end
end

function AddGroupToTable(unitTable, group)
    for k,unit in group do
        table.insert(unitTable, unit)
    end
end

function AddPlatoonToTable(unitTable, platoon)
    local group = platoon:GetPlatoonUnits()
    for k,unit in group do
        table.insert(unitTable, unit)
    end
end
 --- Objective reminder triggers

function M1P1Reminder1()
    if(not ScenarioInfo.M1P1Complete) then
        ScenarioFramework.Dialogue(OpStrings.C05_M01_060)
        ScenarioFramework.CreateTimerTrigger(M1P1Reminder2, Reminder_M1P1_Subsequent)
    end
end

function M1P1Reminder2()
    if(not ScenarioInfo.M1P1Complete) then
        ScenarioFramework.Dialogue(OpStrings.C05_M01_070)
        ScenarioFramework.CreateTimerTrigger(M1P1Reminder3, Reminder_M1P1_Subsequent)
    end
end

function M1P1Reminder3()
    if(not ScenarioInfo.M1P1Complete) then
        ScenarioFramework.Dialogue(ScenarioStrings.CybranGenericReminder)
        ScenarioFramework.CreateTimerTrigger(M1P1Reminder1, Reminder_M1P1_Subsequent)
    end
end

function M2P1Reminder1()
    if(not ScenarioInfo.M2P1Complete) then
        ScenarioFramework.Dialogue(OpStrings.C05_M02_100)
        ScenarioFramework.CreateTimerTrigger(M2P1Reminder2, Reminder_M2P1_Subsequent)
    end
end

function M2P1Reminder2()
    if(not ScenarioInfo.M2P1Complete) then
        ScenarioFramework.Dialogue(OpStrings.C05_M02_105)
        ScenarioFramework.CreateTimerTrigger(M2P1Reminder3, Reminder_M2P1_Subsequent)
    end
end

function M2P1Reminder3()
    if(not ScenarioInfo.M2P1Complete) then
        ScenarioFramework.Dialogue(ScenarioStrings.CybranGenericReminder)
        ScenarioFramework.CreateTimerTrigger(M2P1Reminder1, Reminder_M2P1_Subsequent)
    end
end

function M2P2Reminder1()
    if(not ScenarioInfo.M2P2Complete) then
        ScenarioFramework.Dialogue(OpStrings.C05_M02_110)
        ScenarioFramework.CreateTimerTrigger(M2P2Reminder2, Reminder_M2P2_Subsequent)
    end
end

function M2P2Reminder2()
    if(not ScenarioInfo.M2P2Complete) then
        ScenarioFramework.Dialogue(OpStrings.C05_M02_115)
        ScenarioFramework.CreateTimerTrigger(M2P2Reminder3, Reminder_M2P2_Subsequent)
    end
end

function M2P2Reminder3()
    if(not ScenarioInfo.M2P2Complete) then
        ScenarioFramework.Dialogue(ScenarioStrings.CybranGenericReminder)
        ScenarioFramework.CreateTimerTrigger(M2P2Reminder1, Reminder_M2P2_Subsequent)
    end
end

function M3P1Reminder1()
    if(not ScenarioInfo.M3P1Complete) then
        ScenarioFramework.Dialogue(OpStrings.C05_M03_100)
        ScenarioFramework.CreateTimerTrigger(M3P1Reminder2, Reminder_M3P1_Subsequent)
    end
end

function M3P1Reminder2()
    if(not ScenarioInfo.M3P1Complete) then
        ScenarioFramework.Dialogue(OpStrings.C05_M03_105)
        ScenarioFramework.CreateTimerTrigger(M3P1Reminder3, Reminder_M3P1_Subsequent)
    end
end

function M3P1Reminder3()
    if(not ScenarioInfo.M3P1Complete) then
        ScenarioFramework.Dialogue(ScenarioStrings.CybranGenericReminder)
        ScenarioFramework.CreateTimerTrigger(M3P1Reminder1, Reminder_M3P1_Subsequent)
    end
end


 --- Win/Lose functions

function M3_UEFCommanderDestroyed()
    -- Flag uef cdr as dead for other checks
    ScenarioInfo.UEFCommanderDestroyed = true
    ScenarioInfo.M3P1Complete = true

    -- check that we arent already completing the op
    if not ScenarioInfo.OperationEnding then
        ScenarioInfo.OperationEnding = true
        ScenarioFramework.EndOperationSafety({ ScenarioInfo.M2_FauxUEF_PrisonBuilding })
-- UEF CDR Killed
--    ScenarioFramework.EndOperationCamera( ScenarioInfo.M3_UEFMainBase_Commander, true )
        ScenarioFramework.CDRDeathNISCamera( ScenarioInfo.M3_UEFMainBase_Commander )
        ScenarioFramework.Dialogue(OpStrings.C05_M03_090, KillGame_Win, true)
    end
end

function M3_Hex5Destroyed()

    if not ScenarioInfo.M3P1Complete then
        ScenarioInfo.M3H1 = Objectives.Basic(    -- 'Hidden' obj, Hex5 killed
            'secondary',
            'incomplete',
            OpStrings.M3H1Text,
            OpStrings.M3H1Detail,
            Objectives.GetActionIcon('kill'),
            {
            }
        )

        -- Because this ends the Op, lets flag the M3 main obj as "done", for the purposes of checks, so we dont try to
        -- complete again if UEF cdr is subsequently killed. As well, flag the enemy cdr as dead, so taunts and other
        -- dialogue related to him dont play now (wouldnt be appropriate, as we are ending the op here)
        ScenarioInfo.M3P1Complete = true
        ScenarioInfo.M3H1:ManualResult(true)
        ScenarioInfo.UEFCommanderDestroyed = true

        -- If the op isnt already ending, then allow it to happen here
        if not ScenarioInfo.OperationEnding then
            ScenarioInfo.OperationEnding = true
            ScenarioFramework.EndOperationSafety({ ScenarioInfo.M3_UEFMainBase_Commander })

            -- Hex5 "dying" in prison cam
--        ScenarioFramework.EndOperationCamera( ScenarioInfo.M2_FauxUEF_PrisonBuilding, true )
            local camInfo = {
                blendTime = 2.5,
                holdTime = nil,
                orientationOffset = { 0.7854, 0.8, 0 },
                positionOffset = { 0, 0.5, 0 },
                zoomVal = 45,
                spinSpeed = 0.03,
                overrideCam = true,
            }
            ScenarioFramework.OperationNISCamera( ScenarioInfo.M2_FauxUEF_PrisonBuilding, camInfo )

            ScenarioFramework.Dialogue( OpStrings.C05_M03_080, KillGame_Win, true )
        end
    end
end

function PlayerCDRKilled(deadCommander)
    ScenarioFramework.PlayerDeath(deadCommander, OpStrings.C05_D01_010)
end

function KillGame_Win()
    WaitSeconds(7.0)
    local secondaries = Objectives.IsComplete(ScenarioInfo.M1S1) and Objectives.IsComplete(ScenarioInfo.M2S1) and Objectives.IsComplete(ScenarioInfo.M3S1)
    ScenarioFramework.EndOperation(true, true, secondaries)
end

 --- Build Category functions
function M1_BuildCategories()
    local tblArmy = ListArmies()
    for _, player in Players do
        for iArmy, strArmy in pairs(tblArmy) do
            if iArmy == player then
                ScenarioFramework.AddRestriction(player,
                         categories.PRODUCTFA + -- All FA Units
                         categories.urb0303 + -- T3 Naval Factory
                         categories.urb2302 + -- Long Range Heavy Artillery
                         categories.url0301 + -- Sub Commander
                         categories.urs0302 + -- Battleship
                         categories.urs0303 + -- Aircraft Carrier
                         categories.urb3104 + -- Omni Sensor Suite
                         categories.urb4302 + -- T3 Strategic Missile Defense
                         categories.url0401 + -- Rapid fire heavy art
                         categories.url0402 + -- Spider Bot
                         categories.urb2305 + -- Strategic Missile Launcher
                         categories.urs0304 + -- Strategic Missile Submarine
                         categories.ura0401 + -- Exp. T4 gunship
                         categories.urb4207 + -- Final T2 Shield upgrade
                         categories.drlk001 + -- Cybran T3 Mobile AA
                         categories.dra0202 + -- Corsairs
                         categories.drl0204 + -- Hoplites

                         categories.ueb0302 + -- T3 Naval Factory
                         categories.ueb2302 + -- Long Range Heavy Artillery
                         categories.uel0301 + -- Sub Commander
                         categories.ues0302 + -- Battleship
                         categories.ues0401 + -- Aircraft Carrier
                         categories.ueb3104 + -- Omni Sensor Suite
                         categories.ueb4302 + -- T3 Strategic Missile Defense
                         categories.ueb2305 + -- Strategic Missile Launcher
                         categories.ues0304 + -- Strategic Missile Submarine
                         categories.delk002 + -- UEF T3 Mobile AA
                         categories.del0204 + -- Mongoose
                         categories.dea0202 + -- Janus

                         categories.urb2108 + -- Tactical Missile Launcher
                         categories.urb2304 + -- T3 SAM Launcher
                         categories.ura0304 + -- Strategic Bomber
                         categories.ura0303 + -- Air Superiority Fighter
                         categories.urb0304 + -- Quantum Gate
                         categories.url0303 + -- Siege Assault Bot
                         categories.ueb0303 + -- T3 Naval Factory

                         categories.ueb2108 + -- Tactical Missile Launcher
                         categories.ueb2304 + -- T3 SAM Launcher
                         categories.uea0304 + -- Strategic Bomber
                         categories.uea0303 + -- Air Superiority Fighter
                         categories.ueb0304 + -- Quantum Gate
                         categories.uel0303 ) -- Siege Assault Bot

                ScenarioFramework.AddRestriction( UEF,
                         categories.ueb0302 + -- T3 Naval Factory
                         categories.ueb2302 + -- Long Range Heavy Artillery
                         categories.uel0301 + -- Sub Commander
                         categories.ues0302 + -- Battleship
                         categories.ues0401 + -- Aircraft Carrier
                         categories.ueb3104 + -- Omni Sensor Suite
                         categories.ueb4302 + -- T3 Strategic Missile Defense
                         categories.ueb2305 + -- Strategic Missile Launcher
                         categories.ues0304 + -- Strategic Missile Submarine

                         categories.ueb2108 + -- Tactical Missile Launcher
                         categories.ueb2304 + -- T3 SAM Launcher
                         categories.uea0304 + -- Strategic Bomber
                         categories.uea0303 + -- Air Superiority Fighter
                         categories.ueb0304 + -- Quantum Gate
                         categories.uel0303 ) -- Siege Assault Bot

                ScenarioFramework.RestrictEnhancements({'StealthGenerator', -- 5
                                            'Teleporter'})
            end
        end
    end
end

function M2_BuildCategories()
    -- Player enable for M2, Cybran units:
    ScenarioFramework.RemoveRestrictionForAllHumans(
        categories.urb2108 + -- Tactical Missile Launcher
        categories.urb2304 + -- T3 SAM Launcher
        categories.ura0304   -- Strategic Bomber
    )

    -- Player enable for M2, UEF units:
    ScenarioFramework.RemoveRestrictionForAllHumans(
        categories.ueb2108 + -- Tactical Missile Launcher
        categories.ueb2108 + -- Tactical Missile Launcher
        categories.ueb2304 + -- T3 SAM Launcher
        categories.uea0304 + -- Strategic Bomber

        -- UEF enable for M2+ UEF units:
        categories.uea0304 + -- Strategic Bomber
        categories.uea0303   -- ASF
    )
end

function M2_BuildCategories2()
    -- Unlock ASF
    ScenarioFramework.RemoveRestrictionForAllHumans(categories.ura0303 + categories.uea0303)
end

function M3_BuildCategories()
    ScenarioFramework.RemoveRestrictionForAllHumans(
        categories.url0303 + -- Siege Assault Bot
        categories.uel0303   -- Siege Assault Bot
    )

     -- UEF enable for M3, UEF units:
    ScenarioFramework.RemoveRestriction( UEF,    categories.uel0303 ) -- Siege Assault Bot

    -- Unlock strategic bombers for the uef, on hard dif
    ScenarioFramework.RemoveRestriction( UEF, categories.uea0304 ) -- Strategic Bomber
end
