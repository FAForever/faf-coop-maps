-- ****************************************************************************
-- **
-- **  File     :  /maps/SCCA_Coop_R03/SCCA_Coop_R03_v01_script.lua
-- **  Author(s):  Drew Staltman, Christopher Burns
-- **
-- **  Summary  :
-- **
-- **  Copyright © 2006 Gas Powered Games, Inc.  All rights reserved.
-- ****************************************************************************
local ScenarioFramework = import('/lua/scenarioframework.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local AIBuildStructures = import('/lua/ai/AIBuildStructures.lua')
local Cinematics = import('/lua/cinematics.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local OpStrings = import ('/maps/SCCA_Coop_R03/SCCA_Coop_R03_v01_strings.lua')
local Utilities = import('/lua/Utilities.lua')
local ScenarioStrings = import('/lua/ScenarioStrings.lua')
local MissionTexture = '/textures/ui/common/missions/mission.dds'
local Objectives = ScenarioFramework.Objectives


-- ===  DEBUG VARIABLES === #

-- === GLOBAL VARIABLES === #
ScenarioInfo.MissionNumber = 1

ScenarioInfo.Difficulty = 1

ScenarioInfo.Player = 1
ScenarioInfo.UEF = 2
ScenarioInfo.BrackmanBase = 3
ScenarioInfo.Civilian = 4
ScenarioInfo.CybranCloaked = 5
ScenarioInfo.Coop1 = 6
ScenarioInfo.Coop2 = 7
ScenarioInfo.Coop3 = 8
ScenarioInfo.HumanPlayers = {ScenarioInfo.Player}
truckCam = false


local Player = ScenarioInfo.Player
local Coop1 = ScenarioInfo.Coop1
local Coop2 = ScenarioInfo.Coop2
local Coop3 = ScenarioInfo.Coop3
local UEF = ScenarioInfo.UEF
local Civilian = ScenarioInfo.Civilian
local CybranCloaked = ScenarioInfo.CybranCloaked
local BrackmanBase = ScenarioInfo.BrackmanBase


-- === TRACKING VARIABLES === #
-- Counts
local M1NumberOfYork18AttackWaves = 1
local M1UEFExpansionBasesDefeated = 0
ScenarioInfo.M2BrackmanTrucksCreated = 0
ScenarioInfo.M2BrackmanTrucksDestroyed = 0
ScenarioInfo.M2BrackmanTrucksThroughGate = 0

local ConveyAttackDialoguePlayed    = false

local TauntCount = 0
local DelayToBeginTaunts    =   720
local DelayBetweenTaunts    =   720

-- Used for truck positioning in TrucksNearGate
ScenarioInfo.TruckPosition = 1

 -- reminder timers:
 -- - M1
local Reminder_M1P1_Initial            =   700
local Reminder_M1P1_Subsequent         =   600

local Reminder_M1P2_Initial            =   800
local Reminder_M1P2_Subsequent         =   600

local Reminder_M1P3_Initial            =   800
local Reminder_M1P3_Subsequent         =   600

local Reminder_M1P4_Initial            =   800
local Reminder_M1P4_Subsequent         =   600

 -- - M2
local Reminder_M2P1_Initial            =   800
local Reminder_M2P1_Subsequent         =   600

local Reminder_M2P2_Initial            =   700
local Reminder_M2P2_Subsequent         =   700

local Reminder_M2P3_Initial            =   900
local Reminder_M2P3_Subsequent         =   600

 -- - M3
local Reminder_M3P1_Initial            =   1200
local Reminder_M3P1_Subsequent         =   600

ScenarioInfo.M1P1Complete               = false
ScenarioInfo.M1P2Complete               = false
ScenarioInfo.M1P3Complete               = false
ScenarioInfo.M1P4Complete               = false
ScenarioInfo.M2P1Complete               = false
ScenarioInfo.M2P2Complete               = false
ScenarioInfo.M2P3Complete               = false
ScenarioInfo.M3P1Complete               = false

local M1York18Undamaged = true
local BeginM1AirAttacks = 700
ScenarioInfo.VarTable = {}
ScenarioInfo.VarTable['M1_UEFAir_AttackBegin'] = false

-- === LOCAL VARIABLES === #



-- Import camera class
local SimCamera = import('/lua/SimCamera.lua').SimCamera


    -- === TUNING VARIABLES === #
    -- For timing variables, the units are seconds

local EasyV         = 0
local MediumV       = 1
local HardV         = 0
local DifficultyV    = (1 * EasyV) + (2 * MediumV) + (3 * HardV)
ScenarioInfo.Difficulty = ScenarioInfo.Options.Difficulty or DifficultyV

local Difficulty1_Suffix = '_D1'
local Difficulty2_Suffix = '_D2'
local Difficulty3_Suffix = '_D3'

-- Copied from Dave's E02
function AdjustForDifficulty(string_in)
    local string_out = string_in
    if ScenarioInfo.Difficulty == 1 then
        string_out = string_out .. Difficulty1_Suffix
    elseif ScenarioInfo.Difficulty == 2 then
        string_out = string_out .. Difficulty2_Suffix
    elseif ScenarioInfo.Difficulty == 3 then
        string_out = string_out .. Difficulty3_Suffix
    end
    return string_out
end

-- TEMP: Set back to 120 when done testing
local M1BerryInitialTauntDelay = 120
local M2OffScreenAirAttackDelay = (60 * EasyV) + (30 * MediumV) + (15 * HardV)
local M2AttackersDefeatedToP3RevealedDelay = 10
local M2FirstConvoyLeavingWarningTime = 30
local M2FirstToSecondConvoyLeavingDelay = 60 -- 120
local M2SecondToThirdConvoyLeavingDelay = 60 -- 120
local M2ThirdToFourthConvoyLeavingDelay = 60 -- 120
local M2FourthToFifthConvoyLeavingDelay = 60 -- 120
local M2BrackmanConvoyBreakdownDuration = 10
local M2OffScreenTransportAttackDelay = 30

-- Mission 1 Cybran T1 Land Tech Allowance: T2 Land Factory
-- Mission 1 Cybran T2 Land Tech Allowance: Heavy Tank, Mobile Flak,  T2 Engineer, Amphibious Tank, Mobile Missile Launcher
-- Mission 1 Cybran Building Tech Allowance: T2 Anti-Air Flak Cannon, T2 Heavy Gun Tower, Long Range Radar
-- Mission 1 Cybran Naval Tech Allowance: Attack Submarine, Frigate
local M1CybranT1LandTechAllowance = categories.urb0201
local M1CybranT2LandTechAllowance = categories.url0202 + categories.url0205 + categories.url0208 + categories.url0203 + categories.url0111
local M1CybranBuildingTechAllowance = categories.urb2204 + categories.urb2301 + categories.urb3201
local M1CybranNavalTechAllowance = categories.urs0203 + categories.urs0103

-- Mission 1 UEF T1 Land Tech Allowance: T2 Land Factory
-- Mission 1 UEF T2 Land Tech Allowance: T2 Engineer, Medium Tank, Mobile Flak, Heavy Tank, Amphibious Tank, Mobile Missile Launcher
-- Mission 1 UEF Building Tech Allowance: T2 Anti-Air Flak Cannon, T2 Heavy Gun Tower, Long Range Radar
-- Mission 1 UEF Naval Tech Allowance: Attack Submarine, Frigate
local M1UEFT1LandTechAllowance = categories.ueb0201
local M1UEFT2LandTechAllowance = categories.uel0208 + categories.uel0201 + categories.uel0205 + categories.uel0202 + categories.uel0203 + categories.uel0111
local M1UEFBuildingTechAllowance = categories.ueb2204 + categories.ueb2301 + categories.ueb3201
local M1UEFNavalTechAllowance = categories.ues0203 + categories.ues0103


-- Mission 2 Cybran Building Tech Allowance: T2 Mass Extractor, T2 Power Generator
local M2CybranBuildingTechAllowance = categories.urb1202 + categories.urb1201

-- Mission 2 UEF Building Tech Allowance: T2 Mass Extractor, T2 Power Generator
local M2UEFBuildingTechAllowance = categories.ueb1202 + categories.ueb1201


-- Mission 3 Cybran Building Tech Allowance: T2 Air Factory
-- Mission 3 Cybran Air Tech Allowance: Gunship
local M3CybranBuildingTechAllowance = categories.urb0202
local M3CybranAirTechAllowance = categories.ura0203

-- Mission 3 UEF Building Tech Allowance: T2 Air Factory
-- Mission 3 UEF Air Tech Allowance: Gunship
local M3UEFBuildingTechAllowance = categories.ueb0202
local M3UEFAirTechAllowance = categories.uea0203

function CheatEconomy()
	
    ArmyBrains[UEF]:GiveStorage('MASS', 500000)
    ArmyBrains[UEF]:GiveStorage('ENERGY', 500000)
    while(true) do
		ArmyBrains[UEF]:GiveResource('MASS', 500000)
		ArmyBrains[UEF]:GiveResource('ENERGY', 500000)
		WaitSeconds(.5)
    end
end

-- ##### Starter Functions ######
function OnPopulate(scenario)
    ScenarioUtils.InitializeScenarioArmies()
    ScenarioFramework.GetLeaderAndLocalFactions()

    ScenarioFramework.SetCybranColor(Player)
    ScenarioFramework.SetUEFColor(UEF)
    ScenarioFramework.SetCybranAllyColor(CybranCloaked)
    ScenarioFramework.SetCybranNeutralColor(BrackmanBase)
    ScenarioFramework.SetCybranNeutralColor(Civilian)

    -- Initial player bombers
    local intialBombers = ScenarioUtils.CreateArmyGroupAsPlatoon('Player' ,'M1_Bombers', 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(intialBombers, 'InitialBomber_Chain')

    ScenarioInfo.M1AttackUnits = ScenarioUtils.CreateArmyGroup('Player', 'M1_Initial_Units')
    -- ! Spawn TEST units for degub - REMOVE
    -- ScenarioInfo.M1TestUnits = ScenarioUtils.CreateArmyGroup('Player', 'TEST_UNITS')
    -- ! Spawn Quantum Gate
    ScenarioInfo.Gate = ScenarioUtils.CreateArmyUnit('Player', 'Gate')
    ScenarioInfo.Gate:SetCapturable(false)
    ScenarioInfo.Gate:SetReclaimable(false)

    -- ! Spawn UEF Initial Bases
    ScenarioInfo.UefCDR = ScenarioUtils.CreateArmyUnit('UEF', 'Commander')
    ScenarioFramework.PauseUnitDeath(ScenarioInfo.UefCDR)
    IssuePatrol({ScenarioInfo.UefCDR}, ScenarioUtils.MarkerToPosition('UEF_CMD_Patrol_1'))
    IssuePatrol({ScenarioInfo.UefCDR}, ScenarioUtils.MarkerToPosition('UEF_CMD_Patrol_2'))
    ScenarioInfo.M1UefAirBase = ScenarioUtils.CreateArmyGroup('UEF', 'M1_Air_Base')
    ScenarioInfo.M1UefLandAirBase = ScenarioUtils.CreateArmyGroup('UEF', 'M1_Land_Air_Base')
    ScenarioInfo.M1UefLandBase = ScenarioUtils.CreateArmyGroup('UEF', 'M1_Land_Base')

    -- Spawn wreckage
    ScenarioUtils.CreateArmyGroup('UEF' ,'Wreckage', true)

    -- ! Spawn Civilian town of York18 and give it a death trigger -- 8 buildings must survive
    ScenarioInfo.York18 = ScenarioUtils.CreateArmyGroup('Civilian', 'York18')
    ScenarioFramework.CreateSubGroupDeathTrigger(York18Damaged, ScenarioInfo.York18, 1)
    ScenarioFramework.CreateSubGroupDeathTrigger(York18Destroyed, ScenarioInfo.York18, 8)
    for k,v in ScenarioInfo.York18 do
        v:SetReclaimable(false)
        v:SetCapturable(false)
    end

    -- Per Teh
    for i=2,table.getn(ArmyBrains) do
        if i < ScenarioInfo.Coop1 then
            SetArmyShowScore(i, false)
            SetIgnorePlayableRect(i, true)
        end
    end
end

function OnLoad(self)
end

function OnStart(self)
    ScenarioFramework.SetPlayableArea('M1_PlayableArea', false)
 -- Cinematics.CameraMoveToRectangle(ScenarioUtils.AreaToRect('Start_Camera_Area_Initial'), 0)
    ForkThread(IntroSequenceThread)
    ScenarioFramework.CreateTimerTrigger(OpeningDialogue, 7)
end

function IntroSequenceThread()
    Cinematics.EnterNISMode()
    Cinematics.CameraMoveToRectangle(ScenarioUtils.AreaToRect('Gate_Area'), 2)

    ScenarioInfo.PlayerCDR = ScenarioUtils.CreateArmyUnit('Player', 'Commander')
    ScenarioInfo.PlayerCDR:PlayCommanderWarpInEffect()

    ScenarioFramework.FakeGateInUnit(ScenarioInfo.PlayerCDR)
    ScenarioInfo.PlayerCDR:SetReclaimable(false)
    ScenarioInfo.PlayerCDR:SetCapturable(false)



    WaitSeconds(.8)
    IssueMove({ScenarioInfo.PlayerCDR}, ScenarioUtils.MarkerToPosition('Start_CDR_MovePoint'))
    Cinematics.CameraMoveToRectangle(ScenarioUtils.AreaToRect('Start_Camera_Area'), 3)
    Cinematics.CameraMoveToRectangle(ScenarioUtils.AreaToRect('Start_Camera_Area_2'), 2)
    Cinematics.ExitNISMode()
	
    -- spawn coop players too
    ScenarioInfo.CoopCDR = {}
    local tblArmy = ListArmies()
    coop = 1
    for iArmy, strArmy in pairs(tblArmy) do
        if iArmy >= ScenarioInfo.Coop1 then
            ScenarioInfo.CoopCDR[coop] = ScenarioUtils.CreateArmyUnit(strArmy, 'Commander')
            ScenarioInfo.CoopCDR[coop]:PlayCommanderWarpInEffect()
			ScenarioFramework.FakeGateInUnit(ScenarioInfo.CoopCDR[coop])
			IssueMove({ScenarioInfo.CoopCDR[coop]}, ScenarioUtils.MarkerToPosition('Start_CDR_MovePoint'))
            coop = coop + 1
            WaitSeconds(1.8)
        end
    end

    ScenarioFramework.PauseUnitDeath(ScenarioInfo.PlayerCDR)

    for index, coopACU in ScenarioInfo.CoopCDR do
        ScenarioFramework.PauseUnitDeath(coopACU)
        ScenarioFramework.CreateUnitDeathTrigger(OnCommanderDeath, coopACU)
    end
    ScenarioFramework.CreateUnitDeathTrigger(OnCommanderDeath, ScenarioInfo.PlayerCDR)	

    WaitSeconds(1.5)
    StartMission1()
end

function OpeningDialogue()
    ScenarioFramework.Dialogue(OpStrings.C03_M01_010)
end

-- #### Miscellaneous Functions #####

-- === MISSION 1 FUNCTIONS === #

function StartMission1()
    -- Begin scenario Scripting
    -- Initial dialog from Ops
	for _, player in ScenarioInfo.HumanPlayers do
		SetArmyUnitCap (player, 300)
	end
    SetupM1Triggers()
    GiveMission1Tech()
    ScenarioFramework.CreateTimerTrigger(InitialBerryTaunt, M1BerryInitialTauntDelay)

    -- Trigger the beginning of occasional taunts
    ScenarioFramework.CreateTimerTrigger(PlayTaunt, DelayToBeginTaunts)
    ScenarioFramework.CreateTimerTrigger(M1_BeginAirBaseAttacks, BeginM1AirAttacks)
end

function InitialBerryTaunt()
    ScenarioFramework.Dialogue(OpStrings.C03_M01_020)
end

function SetupM1Triggers()
    ScenarioInfo.York18AttackWave = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M1_Init_Attack', 'AttackFormation')
    -- ScenarioFramework.PlatoonPatrolChain(york18AttackWave, 'York_18_Attack')
    ScenarioFramework.PlatoonPatrolRoute(ScenarioInfo.York18AttackWave, ScenarioUtils.ChainToPositions('York_18_Attack'))

    -- Create death trigger for the UEF Air Base
    ScenarioFramework.CreateAreaTrigger(M1UEFAirBaseDefeated, ScenarioUtils.AreaToRect('M1_UEF_Air_Base_Area'),
                                        categories.STRUCTURE - categories.WALL - categories.ENERGYPRODUCTION - categories.MASSPRODUCTION, true, true, ArmyBrains[UEF])

    -- Create death trigger for the UEF LandAir Base
    ScenarioFramework.CreateAreaTrigger(M1UEFLandAirBaseDefeated, ScenarioUtils.AreaToRect('M1_UEF_Land_Air_Base_Area'),
                                        categories.STRUCTURE - categories.WALL - categories.ENERGYPRODUCTION - categories.MASSPRODUCTION, true, true, ArmyBrains[UEF])

    -- Create death trigger for the UEF Land Base
    ScenarioFramework.CreateAreaTrigger(M1UEFLandBaseDefeated, ScenarioUtils.AreaToRect('M1_UEF_Land_Base_Area'),
                                        categories.STRUCTURE - categories.WALL - categories.ENERGYPRODUCTION - categories.MASSPRODUCTION, true, true, ArmyBrains[UEF])

    -- Defeat all units in the initial UEF attack on York 18
    ScenarioFramework.CreatePlatoonDeathTrigger(M1York18AttackWaveDeathCheck, ScenarioInfo.York18AttackWave)

    -- Assign M1P1: 50% of York18 must survive
    ScenarioInfo.M1P1Obj = Objectives.Basic (
        'primary',
        'incomplete',
        OpStrings.M1P1Title,
        OpStrings.M1P1Description,
        Objectives.GetActionIcon('protect'),
        {
            Units = ScenarioInfo.York18,
        }
   )

    -- Assign M1P5: Defend the Gate
    ScenarioInfo.M1P5Obj = Objectives.Protect('primary', 'incomplete', OpStrings.M1P5Title, OpStrings.M1P5Description,{Units = {ScenarioInfo.Gate}})
    ScenarioFramework.CreateUnitDestroyedTrigger(M1GateDestroyed , ScenarioInfo.Gate)
	ForkThread(CheatEconomy)

end


 -- === OBJECTIVE REMINDER TRIGGERS ===#

function PlayTaunt()
    TauntCount = TauntCount + 1
    if TauntCount <= 8 then
        if (not ScenarioInfo.UefCDR) or (not ScenarioInfo.UefCDR:IsDead()) then
            ScenarioFramework.Dialogue(OpStrings['TAUNT' .. TauntCount])
            ScenarioFramework.CreateTimerTrigger(PlayTaunt, DelayBetweenTaunts)
        end
    end
end

 -- -
function M1P2Reminder1()
    if(not ScenarioInfo.M1P2Complete) then
        ScenarioFramework.Dialogue(OpStrings.C03_M01_110)   -- Western Base
        ScenarioFramework.CreateTimerTrigger(M1P2Reminder2, Reminder_M1P1_Subsequent)
    end
    if ScenarioInfo.M1P2Complete == true then
        if not ScenarioInfo.M1P3Complete then
            M1P3Reminder1()
        elseif not ScenarioInfo.M1P4Complete then
            M1P4Reminder1()
        end
    end
end

function M1P2Reminder2()
    if(not ScenarioInfo.M1P2Complete) then
        ScenarioFramework.Dialogue(OpStrings.C03_M01_115)   -- Western Base
        ScenarioFramework.CreateTimerTrigger(M1P2Reminder3, Reminder_M1P1_Subsequent)
    end
    if ScenarioInfo.M1P2Complete == true then
        if not ScenarioInfo.M1P3Complete then
            M1P3Reminder1()
        elseif not ScenarioInfo.M1P4Complete then
            M1P4Reminder1()
        end
    end
end

function M1P2Reminder3()
    if(not ScenarioInfo.M1P2Complete) then
        ScenarioFramework.Dialogue(ScenarioStrings.CybranGenericReminder)
        ScenarioFramework.CreateTimerTrigger(M1P2Reminder1, Reminder_M1P1_Subsequent)
    end
    if ScenarioInfo.M1P2Complete == true then
        if not ScenarioInfo.M1P3Complete then
            M1P3Reminder1()
        elseif not ScenarioInfo.M1P4Complete then
            M1P4Reminder1()
        end
    end
end

 -- -

function M1P3Reminder1()
    if(not ScenarioInfo.M1P3Complete) then
        ScenarioFramework.Dialogue(OpStrings.C03_M01_120)   -- Northwestern Base
        ScenarioFramework.CreateTimerTrigger(M1P3Reminder2, Reminder_M1P2_Subsequent)
    end
    if ScenarioInfo.M1P3Complete == true then
        if not ScenarioInfo.M1P4Complete then
             M1P4Reminder1()
        end
    end
end

function M1P3Reminder2()
    if(not ScenarioInfo.M1P3Complete) then
        ScenarioFramework.Dialogue(OpStrings.C03_M01_125)   -- Northwestern Base
        ScenarioFramework.CreateTimerTrigger(M1P3Reminder3, Reminder_M1P2_Subsequent)
    end
    if ScenarioInfo.M1P3Complete == true then
        if not ScenarioInfo.M1P4Complete then
             M1P4Reminder1()
        end
    end
end

function M1P3Reminder3()
    if(not ScenarioInfo.M1P3Complete) then
        ScenarioFramework.Dialogue(ScenarioStrings.CybranGenericReminder)
        ScenarioFramework.CreateTimerTrigger(M1P3Reminder1, Reminder_M1P2_Subsequent)
    end
    if ScenarioInfo.M1P3Complete == true then
        if not ScenarioInfo.M1P4Complete then
             M1P4Reminder1()
        end
    end
end

 -- -

function M1P4Reminder1()
    if(not ScenarioInfo.M1P4Complete) then
        ScenarioFramework.Dialogue(OpStrings.C03_M01_130)   -- Northeastern
        ScenarioFramework.CreateTimerTrigger(M1P4Reminder2, Reminder_M1P4_Subsequent)
    end
    if ScenarioInfo.M1P4Complete == true then
        if not ScenarioInfo.M1P3Complete then
             M1P3Reminder1()
        end
    end
end

function M1P4Reminder2()
    if(not ScenarioInfo.M1P4Complete) then
        ScenarioFramework.Dialogue(OpStrings.C03_M01_135)   -- Northeastern
        ScenarioFramework.CreateTimerTrigger(M1P4Reminder3, Reminder_M1P4_Subsequent)
    end
    if ScenarioInfo.M1P4Complete == true then
        if not ScenarioInfo.M1P3Complete then
             M1P3Reminder1()
        end
    end
end

function M1P4Reminder3()
    if(not ScenarioInfo.M1P4Complete) then
        ScenarioFramework.Dialogue(ScenarioStrings.CybranGenericReminder)
        ScenarioFramework.CreateTimerTrigger(M1P4Reminder1, Reminder_M1P4_Subsequent)
    end
    if ScenarioInfo.M1P4Complete == true then
        if not ScenarioInfo.M1P3Complete then
             M1P3Reminder1()
        end
    end
end

-- ###############################

function M2P1Reminder1()
    if(not ScenarioInfo.M2P1Complete) then
        ScenarioFramework.Dialogue(OpStrings.C03_M02_200)
        ScenarioFramework.CreateTimerTrigger(M2P1Reminder2, Reminder_M2P1_Subsequent)
    end
end

function M2P1Reminder2()
    if(not ScenarioInfo.M2P1Complete) then
        ScenarioFramework.Dialogue(OpStrings.C03_M02_205)
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
        ScenarioFramework.Dialogue(OpStrings.C03_M02_210)
        ScenarioFramework.CreateTimerTrigger(M2P2Reminder2, Reminder_M2P2_Subsequent)
    end
end

function M2P2Reminder2()
    if(not ScenarioInfo.M2P2Complete) then
        ScenarioFramework.Dialogue(OpStrings.C03_M02_215)
        ScenarioFramework.CreateTimerTrigger(M2P2Reminder3, Reminder_M2P2_Subsequent)
    end
end

function M2P2Reminder3()
    if(not ScenarioInfo.M2P2Complete) then
        ScenarioFramework.Dialogue(ScenarioStrings.CybranGenericReminder)
        ScenarioFramework.CreateTimerTrigger(M2P2Reminder1, Reminder_M2P2_Subsequent)
    end
end

function M2P3Reminder1()
    if(not ScenarioInfo.M2P3Complete) then
        ScenarioFramework.Dialogue(OpStrings.C03_M02_220)
        ScenarioFramework.CreateTimerTrigger(M2P3Reminder2, Reminder_M2P3_Subsequent)
    end
end

function M2P3Reminder2()
    if(not ScenarioInfo.M2P3Complete) then
        ScenarioFramework.Dialogue(OpStrings.C03_M02_225)
        ScenarioFramework.CreateTimerTrigger(M2P3Reminder3, Reminder_M2P3_Subsequent)
    end
end

function M2P3Reminder3()
    if(not ScenarioInfo.M2P3Complete) then
        ScenarioFramework.Dialogue(ScenarioStrings.CybranGenericReminder)
        ScenarioFramework.CreateTimerTrigger(M2P3Reminder1, Reminder_M2P3_Subsequent)
    end
end

function M3P1Reminder1()
    if(not ScenarioInfo.M3P1Complete) then
        ScenarioFramework.Dialogue(OpStrings.C03_M03_100)
        ScenarioFramework.CreateTimerTrigger(M3P1Reminder2, Reminder_M3P1_Subsequent)
    end
end

function M3P1Reminder2()
    if(not ScenarioInfo.M3P1Complete) then
        ScenarioFramework.Dialogue(OpStrings.C03_M03_105)
        ScenarioFramework.CreateTimerTrigger(M3P1Reminder3, Reminder_M3P1_Subsequent)
    end
end

function M3P1Reminder3()
    if(not ScenarioInfo.M3P1Complete) then
        ScenarioFramework.Dialogue(ScenarioStrings.CybranGenericReminder)
        ScenarioFramework.CreateTimerTrigger(M3P1Reminder1, Reminder_M3P1_Subsequent)
    end
end

function GiveMission1Tech()
    -- No one should be able to build any T3 units
    for _, player in ScenarioInfo.HumanPlayers do
         ScenarioFramework.AddRestriction(player, categories.TECH3)
    end
    ScenarioFramework.AddRestriction(UEF, categories.TECH3)
    -- Most T2 units are not buildable at the start of this mission
    for _, player in ScenarioInfo.HumanPlayers do
         ScenarioFramework.AddRestriction(player, categories.TECH2)
    end
    ScenarioFramework.AddRestriction(UEF, categories.TECH2)

    -- Now, let's add some stuff back in that the player CAN build
    -- T2 Engineer, Heavy Tank and Mobile Flak
    -- T2 Land Factory
    -- Attack Submarine
    ScenarioFramework.RemoveRestrictionForAllHumans(
        M1CybranT2LandTechAllowance +
        M1CybranT1LandTechAllowance +
        M1CybranBuildingTechAllowance +
        M1CybranNavalTechAllowance +
        M1UEFT2LandTechAllowance +
        M1UEFT1LandTechAllowance +
        M1UEFBuildingTechAllowance +
        M1UEFNavalTechAllowance
    )

    ScenarioFramework.RemoveRestriction(UEF, M1UEFT2LandTechAllowance +
                                 M1UEFT1LandTechAllowance +
                                 M1UEFBuildingTechAllowance +
                                 M1UEFNavalTechAllowance)

    -- Commander
    ScenarioFramework.RestrictEnhancements({'T3Engineering',
                                            'NaniteTorpedoTube',
                                            'StealthGenerator',
                                            'T3Engineering',
                                            'Teleporter'})

end

function M1York18AttackWaveDeathCheck(deadPlatoon)
    M1NumberOfYork18AttackWaves = M1NumberOfYork18AttackWaves - 1

    if M1NumberOfYork18AttackWaves < 1 then
       M1York18InitialAttackDefeated()
    end
end

-- End the mission if the York18 is not defended
function York18Destroyed()
    -- print ('debug: YORK18 DESTROYED')

-- York 18 destroyed cam
-- ScenarioFramework.EndOperationCameraLocation(ScenarioUtils.MarkerToPosition('York_18_Attack'))
    local camInfo = {
        blendTime = 2.5,
        holdTime = nil,
        orientationOffset = { math.pi, 0.2, 0 },
        positionOffset = { 0, 0.5, 0 },
        zoomVal = 55,
        spinSpeed = 0.03,
        markerCam = true,
        overrideCam = true,
    }
    ScenarioFramework.OperationNISCamera(ScenarioUtils.MarkerToPosition('York_18_Attack'), camInfo)

    ScenarioInfo.M1P1Obj:ManualResult(false)
    PlayerLose(OpStrings.C03_M01_100)
end

-- End the Operation if the quantum gate is destroyed
function M1GateDestroyed(unit)
-- Qgate destroyed cam
-- ScenarioFramework.EndOperationCamera(unit, false)
    local camInfo = {
        blendTime = 2.5,
        holdTime = nil,
        orientationOffset = { math.pi, 0.3, 0 },
        positionOffset = { 0, 1, 0 },
        zoomVal = 25,
        spinSpeed = 0.03,
        overrideCam = true,
    }
    ScenarioFramework.OperationNISCamera(unit, camInfo)

    PlayerLose(OpStrings.C03_M01_090)
end

function York18Damaged()
    M1York18Undamaged = false
    -- print ('debug: YORK18 FIRST BLDG DESTROYED')
end

function M1York18InitialAttackDefeated()
    -- print ('debug: YORK18 INIT ATTACK WAVE DEAD')
-- York18 defended cam
    local camInfo = {
        blendTime = 1,
        holdTime = 4,
        orientationOffset = { 2.8, 0.2, 0 },
        positionOffset = { 0, 0.5, 0 },
        zoomVal = 55,
        markerCam = true,
    }
    ScenarioFramework.OperationNISCamera(ScenarioUtils.MarkerToPosition('York_18_Attack'), camInfo)

    ScenarioFramework.Dialogue(OpStrings.C03_M01_030)
    ScenarioInfo.M1P1Obj:ManualResult(true)
    ScenarioInfo.M1P1Complete = true
    AssignM1BaseAttackObjectives()
end

function AssignM1BaseAttackObjectives()
    -- Assign M1P2: Defeat Western UEF Base
    if not ScenarioInfo.M1P2Obj then
        ScenarioInfo.M1P2Obj = Objectives.Basic('primary', 'incomplete', OpStrings.M1P2Title, OpStrings.M1P2Description, Objectives.GetActionIcon('kill'),{ShowFaction = 'UEF',Area = 'M1_UEF_Land_Base_Area'})
    end
    ScenarioFramework.CreateTimerTrigger(M1P2Reminder1, Reminder_M1P2_Initial)
    -- Assign M1P3: Defeat Northwest UEF Base
    if not ScenarioInfo.M1P3Obj then
        ScenarioInfo.M1P3Obj = Objectives.Basic('primary', 'incomplete', OpStrings.M1P3Title, OpStrings.M1P3Description, Objectives.GetActionIcon('kill'),{ShowFaction = 'UEF',Area = 'M1_UEF_Land_Air_Base_Area'})
    end
    -- Assign M1P4: Defeat NorthEastern UEF Base
    if not ScenarioInfo.M1P4Obj then
        ScenarioInfo.M1P4Obj = Objectives.Basic('primary', 'incomplete', OpStrings.M1P4Title, OpStrings.M1P4Description, Objectives.GetActionIcon('kill'),{ShowFaction = 'UEF',Area = 'M1_UEF_Air_Base_Area'})
    end
    -- Berry: I©m not done with you, Cybran.
    ScenarioFramework.Dialogue(OpStrings.C03_M01_040)
end

function M1_BeginAirBaseAttacks()
    -- For M1, tell builders to start making some air patrols that roll over the player's base
    ScenarioInfo.VarTable['M1_UEFAir_AttackBegin'] = true
end

-- When the UEF Air Base is defeated increment the counter, update the Objective
function M1UEFAirBaseDefeated()
    M1UEFExpansionBasesDefeated = M1UEFExpansionBasesDefeated + 1
    ScenarioFramework.Dialogue(OpStrings.C03_M01_070)
    if not ScenarioInfo.M1P4Obj then
        ScenarioInfo.M1P4Obj = Objectives.Basic('primary', 'incomplete', OpStrings.M1P4Title, OpStrings.M1P4Description, Objectives.GetActionIcon('kill'),{Area = 'M1_UEF_Air_Base_Area'})
    end
    ScenarioInfo.M1P4Obj:ManualResult(true)
    ScenarioInfo.M1P4Complete = true

-- Airbase destroyed cam
    local camInfo = {
    	blendTime = 1.0,
    	holdTime = 4,
    	orientationOffset = { -2.8, 0.1, 0 },
    	positionOffset = { 0, 1, 0 },
    	zoomVal = 35,
    	markerCam = true,
    }
    ScenarioFramework.OperationNISCamera(ScenarioUtils.MarkerToPosition('M1_UEF_Air_Base'), camInfo)

    -- Check if all of the bases have been destroyed
    if M1UEFExpansionBasesDefeated == 3 then
        ForkThread(EndMission1)
    end
end

-- When the UEF Land Base is defeated increment the counter, update the Objective
function M1UEFLandBaseDefeated()
    M1UEFExpansionBasesDefeated = M1UEFExpansionBasesDefeated + 1
    ScenarioFramework.Dialogue(OpStrings.C03_M01_050)
    if not ScenarioInfo.M1P2Obj then
        ScenarioInfo.M1P2Obj = Objectives.Basic('primary', 'incomplete', OpStrings.M1P2Title, OpStrings.M1P2Description, Objectives.GetActionIcon('kill'),{Area = 'M1_UEF_Land_Base_Area'})
    end
    ScenarioInfo.M1P2Obj:ManualResult(true)
    ScenarioInfo.M1P2Complete = true

-- Land base destroyed cam
    local camInfo = {
    	blendTime = 1.0,
    	holdTime = 4,
    	orientationOffset = { 1.3, 0.15, 0 },
    	positionOffset = { 0, 0.5, 0 },
    	zoomVal = 55,
    	markerCam = true,
    }
    ScenarioFramework.OperationNISCamera(ScenarioUtils.MarkerToPosition('M1_UEF_Land_Base'), camInfo)

    -- Check if all of the bases have been destroyed
    if M1UEFExpansionBasesDefeated == 3 then
        ForkThread(EndMission1)
    end
end

-- When the UEF Land/Air Base is defeated increment the counter, update the Objective
function M1UEFLandAirBaseDefeated()
    M1UEFExpansionBasesDefeated = M1UEFExpansionBasesDefeated + 1
    ScenarioFramework.Dialogue(OpStrings.C03_M01_060)
    if not ScenarioInfo.M1P3Obj then
        ScenarioInfo.M1P3Obj = Objectives.Basic('primary', 'incomplete', OpStrings.M1P3Title, OpStrings.M1P3Description, Objectives.GetActionIcon('kill'),{Area = 'M1_UEF_Land_Air_Base_Area'})
    end
    ScenarioInfo.M1P3Obj:ManualResult(true)
    ScenarioInfo.M1P3Complete = true

-- Combination land/air base destroyed cam
    local camInfo = {
    	blendTime = 1.0,
    	holdTime = 4,
    	orientationOffset = { 0.3269, 0.4, 0 },
    	positionOffset = { 0, 0.75, 0 },
    	zoomVal = 55,
    	markerCam = true,
    }
    ScenarioFramework.OperationNISCamera(ScenarioUtils.MarkerToPosition('M1_UEF_Land_Air_Base'), camInfo)

    -- Check if all of the bases have been destroyed
    if M1UEFExpansionBasesDefeated == 3 then
        ForkThread(EndMission1)
    end
end

function EndMission1()
    ScenarioFramework.Dialogue(OpStrings.C03_M01_080,StartMission2)
end

-- === MISSION 2 FUNCTIONS === #

function StartMission2()
    ScenarioInfo.MissionNumber = 2
	for _, player in ScenarioInfo.HumanPlayers do
		SetArmyUnitCap (player, 400)
	end
    -- ! Expand the map area
    ScenarioFramework.SetPlayableArea('M2_PlayableArea')

    -- ! Spawn Brackman's facility
    ScenarioInfo.Brackman = ScenarioUtils.CreateArmyGroup('BrackmanBase', 'Brackman')
    ScenarioInfo.BrackmanInvincible = ScenarioUtils.CreateArmyGroup('BrackmanBase', 'BrackmanInvincible')
    ScenarioInfo.BrackmanShields = ScenarioUtils.CreateArmyGroup('BrackmanBase', 'BrackmanShields')
    -- Making the Brackman base invulnerable for now, remove if we get a shield that can keep the base alive
    -- MATT 10/5/06 let's make just part of brackmans base invincible
    for counter, unit in ScenarioInfo.BrackmanInvincible do
        unit:SetCanTakeDamage(false)
    end
    for counter, unit in ScenarioInfo.BrackmanShields do
    -- #unit:SetCanTakeDamage(false)
        -- unit:CreateEnhancement('Shield2')
        -- LOG('debug: Op: shield upgrade ',counter)
        if (counter == 2) then
            -- bottom most shield
            -- unit:CreateEnhancement('Shield3')
            -- unit:CreateEnhancement('Shield4')
            unit:SetCanTakeDamage(false)
        end
    end

    -- Spawn an escape convoy from York18 and send them away from town and off the map
    ScenarioInfo.EscapeConvoy = ScenarioUtils.CreateArmyGroup('Civilian', 'Escape_Convoy')
    IssuePatrol(ScenarioInfo.EscapeConvoy, ScenarioUtils.MarkerToPosition('York18_Escape'))


    -- Spawn UEF LAIs and Cruiser
    ScenarioInfo.UEFLAINorth = ScenarioUtils.CreateArmyUnit('UEF', 'LAI_N')
    ScenarioInfo.UEFLAISouth = ScenarioUtils.CreateArmyUnit('UEF', 'LAI_S')
    ScenarioInfo.UEFCruiser = ScenarioUtils.CreateArmyUnit('UEF', 'UEF_Cruiser')
    -- Death triggers for the UEF LAIs and Cruiser
    -- ScenarioFramework.CreateUnitDeathTrigger(UEFLAINorthKilled, ScenarioInfo.UEFLAINorth)
    -- ScenarioFramework.CreateUnitDeathTrigger(UEFLAISouthKilled, ScenarioInfo.UEFLAISouth)
    -- ScenarioFramework.CreateUnitDeathTrigger(UEFCruiserKilled, ScenarioInfo.UEFCruiser)
    -- Spawn support structures and units at UEF LAIs
    ScenarioUtils.CreateArmyGroup('UEF', 'M2_LAI_N_Support')
    ScenarioUtils.CreateArmyGroup('UEF', 'M2_LAI_S_Support')
    ScenarioUtils.CreateArmyGroup('UEF', 'M2_LAI_S_Mobile')
    local LAI_N_Mobile_Platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M2_LAI_N_Mobile', 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(LAI_N_Mobile_Platoon, 'M2_ArtNE_Chain')

    -- Assign M2P1, M2P2
    ScenarioFramework.Dialogue(OpStrings.C03_M02_010)
    ScenarioInfo.M2P1Obj = Objectives.KillOrCapture('primary', 'incomplete', OpStrings.M2P1Title, OpStrings.M2P1Description,{Units = {ScenarioInfo.UEFLAINorth,ScenarioInfo.UEFLAISouth} })
    ScenarioInfo.M2P1Obj:AddResultCallback(UEFLAIsKilled)
    ScenarioFramework.CreateTimerTrigger(M2P1Reminder1, Reminder_M2P1_Initial)

    ScenarioInfo.M2P2Obj = Objectives.KillOrCapture('primary', 'incomplete', OpStrings.M2P2Title, OpStrings.M2P2Description,{Units = {ScenarioInfo.UEFCruiser}})
    ScenarioInfo.M2P2Obj:AddResultCallback(UEFCruiserKilled)
    ScenarioFramework.CreateTimerTrigger(M2P2Reminder1, Reminder_M2P2_Initial)

    -- ! Give access to new units
    M2GiveTech()
end

function M2GiveTech()
    -- T2 Engineer can build the T2 Mass Extractor, T2 Power Generator
    ScenarioFramework.RemoveRestrictionForAllHumans(M2CybranBuildingTechAllowance + M2UEFBuildingTechAllowance)
    ScenarioFramework.RemoveRestriction(UEF, M2UEFBuildingTechAllowance)
end

-- When the UEF LAIs are defeated  update the Objective
function UEFLAIsKilled()
    ScenarioInfo.M2P1Complete = true
    ScenarioFramework.Dialogue(OpStrings.C03_M02_020)
    -- Check if all three of the threats have been destroyed
    if ScenarioInfo.M2P2Complete then
        ForkThread(StartConvoy1)
    end
end


-- When the UEF Cruiser is defeated increment the counter, update the Objective
function UEFCruiserKilled()
-- Cruiser destroyed cam
    local camInfo = {
        blendTime = 1.0,
        holdTime = 4,
        orientationOffset = { -2.7, 0.4, 0 },
        positionOffset = { 0, 0.5, 0 },
        zoomVal = 25,
    }
    ScenarioFramework.OperationNISCamera(ScenarioInfo.UEFCruiser, camInfo)

    ScenarioFramework.Dialogue(OpStrings.C03_M02_030)
    ScenarioInfo.M2P2Complete = true
    -- Check if the LAIs have been destroyed
    if ScenarioInfo.M2P1Complete  then
        ForkThread(StartConvoy1)
    end
end

function M2SpawnTrucks()
    local truck1 = ScenarioUtils.CreateArmyUnit('Player', 'Truck_1')
    local truck2 = ScenarioUtils.CreateArmyUnit('Player', 'Truck_2')
    local truck3 = ScenarioUtils.CreateArmyUnit('Player', 'Truck_3')
    local truck4 = ScenarioUtils.CreateArmyUnit('Player', 'Truck_4')
    local truck5 = ScenarioUtils.CreateArmyUnit('Player', 'Truck_5')
    ScenarioInfo.M2P3Obj:AddBasicUnitTarget (truck1)
    ScenarioInfo.M2P3Obj:AddBasicUnitTarget (truck2)
    ScenarioInfo.M2P3Obj:AddBasicUnitTarget (truck3)
    ScenarioInfo.M2P3Obj:AddBasicUnitTarget (truck4)
    ScenarioInfo.M2P3Obj:AddBasicUnitTarget (truck5)


    -- Track Convoy
    ScenarioFramework.CreateUnitDeathTrigger(M2TruckDead, truck1)
    truck1:SetReclaimable(false)
    ScenarioFramework.CreateUnitToMarkerDistanceTrigger(Truck1NearGate, truck1, ScenarioUtils.MarkerToPosition('Gate_Position'), 30)
    ScenarioFramework.CreateUnitDeathTrigger(M2TruckDead, truck2)
    truck2:SetReclaimable(false)
    ScenarioFramework.CreateUnitToMarkerDistanceTrigger(Truck2NearGate, truck2, ScenarioUtils.MarkerToPosition('Gate_Position'), 30)
    ScenarioFramework.CreateUnitDeathTrigger(M2TruckDead, truck3)
    truck3:SetReclaimable(false)
    ScenarioFramework.CreateUnitToMarkerDistanceTrigger(Truck3NearGate, truck3, ScenarioUtils.MarkerToPosition('Gate_Position'), 30)
    ScenarioFramework.CreateUnitDeathTrigger(M2TruckDead, truck4)
    truck4:SetReclaimable(false)
    ScenarioFramework.CreateUnitToMarkerDistanceTrigger(Truck4NearGate, truck4, ScenarioUtils.MarkerToPosition('Gate_Position'), 30)
    ScenarioFramework.CreateUnitDeathTrigger(M2TruckDead, truck5)
    truck5:SetReclaimable(false)
    ScenarioFramework.CreateUnitToMarkerDistanceTrigger(Truck5NearGate, truck5, ScenarioUtils.MarkerToPosition('Gate_Position'), 30)
    ScenarioInfo.M2BrackmanTrucksCreated = ScenarioInfo.M2BrackmanTrucksCreated + 5

-- Truck Spawn cam
    local camInfo = {
    	blendTime = 1.0,
    	holdTime = 4,
    	orientationOffset = { 2.19, 0.6, 0 },
    	positionOffset = { -2, 0.5, 0 },
    	zoomVal = 15,
    	markerCam = true,
    }
    ScenarioFramework.OperationNISCamera(ScenarioUtils.MarkerToPosition('M2_Brackman_Base'), camInfo)
end

function StartConvoy1()
    -- print('debug: Op: Brackman free to escape')

    ScenarioFramework.CreateTimerTrigger(OffScreenTransportAttack, M2OffScreenTransportAttackDelay)

    WaitSeconds (M2AttackersDefeatedToP3RevealedDelay)
    ScenarioFramework.CreateTimerTrigger(OffScreenAirAttack, M2OffScreenAirAttackDelay)

    ScenarioInfo.M2P3Obj = Objectives.Basic(
        'primary',
        'incomplete',
        OpStrings.M2P3Title,
        OpStrings.M2P3Description,
        Objectives.GetActionIcon('move'),
        {
            Area = 'Gate_Area',
            MarkArea = true,
        }
   )
    ScenarioFramework.CreateTimerTrigger(M2P3Reminder1, Reminder_M2P3_Initial)
    ScenarioInfo.M2S1Obj = Objectives.Basic('secondary', 'incomplete', OpStrings.M2S1Title, OpStrings.M2S1Description, Objectives.GetActionIcon('move'), {Area = 'Gate_Area',})
    ScenarioFramework.Dialogue(OpStrings.C03_M02_040)
    WaitSeconds (M2FirstConvoyLeavingWarningTime)
    ScenarioFramework.Dialogue(OpStrings.C03_M02_070)
    -- Trigger for at gate, used for all trucks
    ScenarioFramework.M2GateTrigger = ScenarioFramework.CreateAreaTrigger(SendTruckThroughGate, ScenarioUtils.AreaToRect('M2_Gate_Delete_Area'),
        (categories.urc0001), false, false, ArmyBrains[ScenarioInfo.Player], 1, true)

    -- Spawn First Convoy
    M2SpawnTrucks()
    ForkThread(StartConvoy2)
end

function OffScreenAirAttack()
    -- Spawn in A2A attackers to harass the player
    local m2FastInterceptors = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', AdjustForDifficulty('M2_Air_Attack'), 'AttackFormation')
    ScenarioFramework.CreatePlatoonDeathTrigger(M2FastInterceptorsKilled, m2FastInterceptors)
    -- ScenarioFramework.PlatoonPatrolRoute(m2FastInterceptors, ScenarioUtils.ChainToPositions('M2_Convoy_Attack_Chain'))
    ScenarioFramework.PlatoonPatrolChain(m2FastInterceptors, 'M2_Convoy_Attack_Chain')
end

-- Repeatedly attack the player from the air throughout the convoy mission
function M2FastInterceptorsKilled()
    if ScenarioInfo.MissionNumber == 2 then
        ScenarioFramework.CreateTimerTrigger(OffScreenAirAttack, M2OffScreenAirAttackDelay)
    end
end

function M2TruckDead(unit)
    ScenarioInfo.M2BrackmanTrucksDestroyed = ScenarioInfo.M2BrackmanTrucksDestroyed + 1

    if (ScenarioInfo.M2S1Obj.Active) then
       ScenarioInfo.M2S1Obj:ManualResult(false)
    end

    if ScenarioInfo.M2BrackmanTrucksDestroyed > 5 then
        -- If the Player loses more than 5 trucks, fail the mission
        if (ScenarioInfo.M2P3Obj.Active) then

-- Trucks destroyed cam
--        ScenarioFramework.EndOperationCamera(unit, false)
            local camInfo = {
                blendTime = 2.5,
                holdTime = nil,
                orientationOffset = { math.pi, 0.4, 0 },
                positionOffset = { 0, 0.5, 0 },
                zoomVal = 15,
                spinSpeed = 0.03,
                overrideCam = true,
            }
            ScenarioFramework.OperationNISCamera(unit, camInfo)

            ScenarioInfo.M2P3Obj:ManualResult(false)
            PlayerLose(OpStrings.C03_M02_160)
        end
    elseif (ScenarioInfo.M2BrackmanTrucksDestroyed + ScenarioInfo.M2BrackmanTrucksThroughGate) > 14  then
        -- last truck destoryed, but we've got enough already
        ScenarioFramework.M2GateTrigger:Destroy()
        StartMission3()
    end
end

function StartConvoy2()
    WaitSeconds (M2FirstToSecondConvoyLeavingDelay)
    -- print('debug: Op: Second Convoy Triggered')
    ScenarioFramework.Dialogue(OpStrings.C03_M02_090)
    -- Spawn Second Convoy
    M2SpawnTrucks()
    ForkThread(StartConvoy3)
end

function OffScreenTransportAttack()
    -- For the first attack, play UEF dialogue
    if ConveyAttackDialoguePlayed == false then
        ConveyAttackDialoguePlayed = true
        ScenarioFramework.Dialogue(OpStrings.C03_M02_080)
    end
    LOG ('debug:---> offscreen attack')
    -- Spawn in A2G attackers to harass the player

    ScenarioInfo.M2TransportAttack = ArmyBrains[ScenarioInfo.UEF]:MakePlatoon(' ', ' ')

    local transportGroup = ScenarioUtils.CreateArmyGroup('UEF', 'M2_Transport_Attack_Transport')
    local attackGroup = ScenarioUtils.CreateArmyGroup('UEF', 'M2_Transport_Attack')

    ArmyBrains[ScenarioInfo.UEF]:AssignUnitsToPlatoon(ScenarioInfo.M2TransportAttack, transportGroup, 'Support', 'AttackFormation')
    ArmyBrains[ScenarioInfo.UEF]:AssignUnitsToPlatoon(ScenarioInfo.M2TransportAttack, attackGroup, 'Attack', 'AttackFormation')

    ScenarioFramework.AttachUnitsToTransports(attackGroup, transportGroup)

    ForkThread(M2TransportAttackersTimer)

    local loadCmd = ScenarioInfo.M2TransportAttack:UnloadAllAtLocation(ScenarioUtils.MarkerToPosition('M2_Landing_Zone_'..Random(1, 6)))
    while table.getn(ScenarioInfo.M2TransportAttack:GetPlatoonUnits()) > 0 and ScenarioInfo.M2TransportAttack:IsCommandsActive(loadCmd) do
        WaitSeconds(1)
    end
    ScenarioPlatoonAI.PlatoonAttackHighestThreat(ScenarioInfo.M2TransportAttack)

end

-- Repeatedly attack the player from the air throughout the convoy mission
function M2TransportAttackersTimer()
    if ScenarioInfo.MissionNumber < 3 then
        ScenarioFramework.CreateTimerTrigger(OffScreenTransportAttack, M2OffScreenTransportAttackDelay)
    end
end


function StartConvoy3()
    WaitSeconds (M2SecondToThirdConvoyLeavingDelay)
    -- print('debug: Op: Third Convoy Triggered')
    ScenarioFramework.Dialogue(OpStrings.C03_M02_130)
    -- Spawn Third Convoy
    M2SpawnTrucks()
    -- ForkThread(StartConvoy4)
end


-- ! If any truck1 gets close to the gate, move it closer and send it through.
function Truck1NearGate(truck)
    LOG('debug: Op: Running Truck1NearGate')
	local x, y, z = unpack(ScenarioInfo.Gate:GetPosition())
    IssueMove({truck}, {x,y,z})
end

-- ! If any truck2 gets close to the gate, move it closer and send it through.
function Truck2NearGate(truck)
    LOG('debug: Op: Running Truck2NearGate')
	local x, y, z = unpack(ScenarioInfo.Gate:GetPosition())
    IssueMove({truck}, {x,y,z})
end

-- ! If any truck3 gets close to the gate, move it closer and send it through.
function Truck3NearGate(truck)
    LOG('debug: Op: Running Truck3NearGate')
	local x, y, z = unpack(ScenarioInfo.Gate:GetPosition())
    IssueMove({truck}, {x,y,z})
end

-- ! If any truck4 gets close to the gate, move it closer and send it through.
function Truck4NearGate(truck)
    LOG('debug: Op: Running Truck4NearGate')
	local x, y, z = unpack(ScenarioInfo.Gate:GetPosition())

    IssueMove({truck}, {x,y,z})
end

-- ! If any truck5 gets close to the gate, move it closer and send it through.
function Truck5NearGate(truck)
    LOG('debug: Op: Running Truck5NearGate')
	local x, y, z = unpack(ScenarioInfo.Gate:GetPosition())

    IssueMove({truck}, {x,y,z})
end

-- ! Send truck through the gate
function SendTruckThroughGate(units)
    for k, truck in units do
        if not truck.GateStarted then
            truck.GateStarted = true
            ScenarioFramework.FakeTeleportUnit(truck,true)
            ScenarioInfo.M2BrackmanTrucksThroughGate = ScenarioInfo.M2BrackmanTrucksThroughGate + 1
        end
    end

    local progress = string.format('(%s/%s)', ScenarioInfo.M2BrackmanTrucksThroughGate, 15)
    Objectives.UpdateBasicObjective(ScenarioInfo.M2P3Obj, 'progress', progress)

    -- Trucks entering Qgate
    if not truckCam then
        truckCam = true
        local camInfo = {
            blendTime = 1.0,
            holdTime = 4,
            orientationOffset = { 2.562, 0.3, 0 },
            positionOffset = { 0, 1, 0 },
            zoomVal = 25,
        }
        ScenarioFramework.OperationNISCamera(ScenarioInfo.Gate, camInfo)
        ForkThread(TruckCamDelay, camInfo)
    end

    if (ScenarioInfo.M2BrackmanTrucksDestroyed + ScenarioInfo.M2BrackmanTrucksThroughGate) > 14  then
        ScenarioFramework.M2GateTrigger:Destroy()
        StartMission3()
    end
end

function TruckCamDelay(camInfo)
    local truckCamDelayTime = 60 + camInfo.blendTime + camInfo.holdTime
    WaitSeconds(truckCamDelayTime)
    truckCam = false
end

-- === MISSION 3 FUNCTIONS === #

function StartMission3()
	for _, player in ScenarioInfo.HumanPlayers do
		SetArmyUnitCap (player, 500)
	end
    for k, truck in ScenarioInfo.EscapeConvoy do
        truck:Destroy() -- clean up convoy
    end
    ScenarioInfo.M2P3Obj:ManualResult(true)
    ScenarioInfo.M2P3Complete = true
    -- Check to see if all trucks made it to the gate
    CheckM2S1()
    ScenarioFramework.Dialogue(OpStrings.C03_M02_050)
    ScenarioFramework.Dialogue(OpStrings.C03_M03_010, StartMission3part2)
end

function StartMission3part2()
    ScenarioInfo.MissionNumber = 3
    M3GiveTech()

    -- ! Expand the map area
    ScenarioFramework.SetPlayableArea('M3_PlayableArea')
    -- Spawn in the hidden research facility
    ScenarioInfo.M3HiddenResearchFacility = ScenarioUtils.CreateArmyGroup('CybranCloaked', 'M3_Hidden_Research_Facility')
    ScenarioInfo.M3Omni = ScenarioUtils.CreateArmyUnit('CybranCloaked', 'M3_Omni')
    -- Hidden Cybran Research Facility spotted
    ScenarioFramework.CreateArmyIntelTrigger(M3H1Achieved, ArmyBrains[Player], 'LOSNow', false, true, categories.urb3104, true, ArmyBrains[CybranCloaked])
    -- Spawn in UEF main base structures
    ScenarioUtils.CreateArmyGroup('UEF', 'M3_Main_Base')
    ScenarioUtils.CreateArmyGroup('UEF', 'M3_Sea_Base')
    -- [Berry]: I may have missed Brackman, but you won©t be so lucky.
    ScenarioFramework.Dialogue(OpStrings.C03_M03_020)

    ScenarioInfo.M3P1 = Objectives.Kill(
        'primary',
        'incomplete',
        OpStrings.M3P1Title,
        OpStrings.M3P1Description,
        { Units = { ScenarioInfo.UefCDR } }
   )
    ScenarioInfo.M3P1:AddResultCallback(PlayerWin)
    ScenarioFramework.CreateTimerTrigger(M3P1Reminder1, Reminder_M3P1_Initial)
end


function M3GiveTech()
    -- T1 Air Factory can upgrade to T2 Air Factory
    -- T2 Air Factory can build Gunship
    ScenarioFramework.RemoveRestrictionForAllHumans(M3CybranBuildingTechAllowance + M3CybranAirTechAllowance + M3UEFBuildingTechAllowance + M3UEFAirTechAllowance)
    ScenarioFramework.RemoveRestriction(UEF, M3UEFBuildingTechAllowance + M3UEFAirTechAllowance)
end

-- Award M2 Secondary Obj if all trucks survived
function CheckM2S1()
    if ScenarioInfo.M2BrackmanTrucksDestroyed == 0 then
        ScenarioInfo.M2S1Obj:ManualResult(true)
    -- else
    -- ScenarioInfo.M2S1Obj:ManualResult(false)
    end
end

function M3H1Achieved()
    ScenarioInfo.M3H1 = Objectives.Basic(   -- Hidden obj, Research base found
        'secondary',
        'incomplete',
        OpStrings.M3H1Title,
        OpStrings.M3H1Description,
        Objectives.GetActionIcon('locate'),
        {
            ShowFaction = 'Cybran',
        }
   )
    for _, player in ScenarioInfo.HumanPlayers do
        SetAlliance(player, CybranCloaked, 'Ally')
    end
    for _, player in ScenarioInfo.HumanPlayers do
        SetAlliance(CybranCloaked, player, 'Ally')
    end
    ScenarioInfo.M3H1:ManualResult(true)
    ScenarioFramework.Dialogue(OpStrings.C03_M03_030)
end

-- === WIN/LOSE === #

function OnCommanderDeath(unit)
    -- ! If your Commander dies, you lose
    -- print('Commander Died')
-- ScenarioFramework.EndOperationCamera(unit, false)
    ScenarioFramework.CDRDeathNISCamera(unit)
    PlayerLose(OpStrings.C03_D01_010)

end

function PlayerWin()
    -- print('debug:Operation Complete')
    -- ScenarioFramework.Dialogue(ScenarioStrings.BObjComp)

-- ScenarioFramework.EndOperationCamera(ScenarioInfo.UefCDR, false)
    ScenarioFramework.CDRDeathNISCamera(ScenarioInfo.UefCDR)

    ScenarioInfo.M1P5Obj:ManualResult(true) -- complete the gate obj
    ScenarioFramework.EndOperationSafety({ScenarioInfo.Gate})
    ScenarioFramework.Dialogue(OpStrings.C03_M03_050,false,true)
    ScenarioInfo.M3P1Complete = true
    ScenarioFramework.Dialogue(ScenarioStrings.OperationSuccessDialogue, WinGame, true)

end

function PlayerLose(dialogueTable)
    ScenarioFramework.EndOperationSafety({ScenarioInfo.Gate})
    if (dialogueTable) then
        ScenarioFramework.Dialogue(dialogueTable, LoseGame, true)
    else
        ForkThread(LoseGame)
    end
end

function WinGame()
    WaitSeconds(5)
	ScenarioInfo.OpComplete = true
    local secondaries = Objectives.IsComplete(ScenarioInfo.M2S1Obj)

    ScenarioFramework.EndOperation(ScenarioInfo.OpComplete, ScenarioInfo.OpComplete, secondaries)
end

function LoseGame()
    WaitSeconds(10)
	ScenarioInfo.OpComplete = false
    ScenarioFramework.EndOperation(ScenarioInfo.OpComplete, ScenarioInfo.OpComplete, false)
end

-- ---------------
-- Debug Functions
-- ---------------
-- function OnCtrlAltF5()
-- ScenarioFramework.EndOperation('SCCA_Coop_R03', true, ScenarioInfo.Options.Difficulty, true, true, true)
-- end
--
-- function OnCtrlF4()
-- ScenarioFramework.EndOperation('SCCA_Coop_R03', true, ScenarioInfo.Options.Difficulty, false, false, false)
-- end
--
-- function OnF4()
-- StartMission2()
-- end
-- function OnShiftF4()
-- #    M3H1Achieved()
-- StartMission2()
-- end
--
-- function OnShiftF3()
-- ScenarioFramework.SetPlayableArea('M3_PlayableArea')
-- ForkThread(OffScreenTransportAttack)
-- end
--
-- function OnF3()
-- ScenarioInfo.M2P3Obj = Objectives.Basic(
--    'primary',
--    'incomplete',
--    OpStrings.M2P3Title,
--    OpStrings.M2P3Description,
--    Objectives.GetActionIcon('move'),
--    {
--        Area = 'Gate_Area',
--        MarkArea = true,
--    }
-- )
-- ScenarioInfo.M2S1Obj = Objectives.Basic('secondary', 'incomplete', OpStrings.M2S1Title, OpStrings.M2S1Description)
-- StartMission3()
-- end

