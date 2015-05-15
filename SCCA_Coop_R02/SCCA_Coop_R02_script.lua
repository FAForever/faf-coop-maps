-- ****************************************************************************
-- **
-- **  File     :  /maps/SCCA_Coop_R02/SCCA_Coop_R02_script.lua
-- **  Author(s):  Grant Roberts
-- **
-- **  Summary  :  Cybran Campaign, Operation 2
-- **
-- **  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
-- ****************************************************************************

----------------------------------------------------------------------------- #
-- === GLOBAL VARIABLES ====================================================== #
----------------------------------------------------------------------------- #
ScenarioInfo.MissionNumber  = 1

ScenarioInfo.Player         = 1
ScenarioInfo.Aeon           = 2
ScenarioInfo.CybranJanus    = 3
ScenarioInfo.Civilian       = 4
ScenarioInfo.FakeAeon       = 5
ScenarioInfo.FakeJanus      = 6
ScenarioInfo.Coop1 = 7
ScenarioInfo.Coop2 = 8
ScenarioInfo.Coop3 = 9
ScenarioInfo.HumanPlayers = {}
ScenarioInfo.M1P3Given      = false
ScenarioInfo.M1P4Given      = false

ScenarioInfo.M1NETechFound                  = false
ScenarioInfo.M1SETechFound                  = false
ScenarioInfo.M1DestinationIsNE              = true

ScenarioInfo.M1TechsPickedUp                = 0
ScenarioInfo.M1TempleDefendersAlive         = 0
ScenarioInfo.M1TempleDefenseSkippedNE       = false
ScenarioInfo.M1TempleDefenseSkippedSE       = false
ScenarioInfo.M1RemainderDead                = false
ScenarioInfo.M1SecondTechDefenseCount       = 0
ScenarioInfo.M1_SecondTechDef_Spawned       = false
ScenarioInfo.M1P6_Assigned                  = false

ScenarioInfo.M2OffscreenPlatoonsKilled      = 0
ScenarioInfo.M2OffscreenPlatoonsAlive       = 0
ScenarioInfo.M2AeonAttackSize               = 1
ScenarioInfo.M2AMLandPlatoonsKilled         = 0
ScenarioInfo.M2AMNavalPlatoonsKilled        = 0
ScenarioInfo.M2PrimaryObjectivesComplete    = 0
ScenarioInfo.M2OffscreenAttacksDone         = false

ScenarioInfo.M3JanusNorthDefensesCount      = 0
ScenarioInfo.M3JanusNorthDefensesKilled     = 0
ScenarioInfo.M3AeonCommanderAssaultTime     = false
ScenarioInfo.M3AeonAMPlatoonsKilled         = 0
ScenarioInfo.M3JanusAMPlatoonsKilled        = 0

ScenarioInfo.M3JanusAttacksIncreaseAfter    = 3
ScenarioInfo.M3AeonAttacksIncreaseAfter     = 3

ScenarioInfo.VarTable                       = {}

ScenarioInfo.OperationEnding                = false
----------------------------------------------------------------------------- #
-- === LOCAL VARIABLES ======================================================= #
----------------------------------------------------------------------------- #
local ScenarioFramework = import('/lua/scenarioframework.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local AIBuildStructures = import('/lua/ai/AIBuildStructures.lua')
local Cinematics = import('/lua/cinematics.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local OpStrings = import('/maps/SCCA_Coop_R02/SCCA_Coop_R02_strings.lua')
local OpEditorFns = import ('/maps/SCCA_Coop_R02/SCCA_Coop_R02_EditorFunctions.lua')
local Utilities = import('/lua/Utilities.lua')
local ScenarioStrings = import('/lua/ScenarioStrings.lua')
local MissionTexture = '/textures/ui/common/missions/mission.dds'
local Objectives = ScenarioFramework.Objectives
local EffectTemplate = import('/lua/EffectTemplates.lua')

local Player = ScenarioInfo.Player
local Coop1 = ScenarioInfo.Coop1
local Coop2 = ScenarioInfo.Coop2
local Coop3 = ScenarioInfo.Coop3
local Aeon = ScenarioInfo.Aeon
local CybranJanus = ScenarioInfo.CybranJanus
local Civilian = ScenarioInfo.Civilian
local FakeAeon = ScenarioInfo.FakeAeon
local FakeJanus = ScenarioInfo.FakeJanus

local M1NETechPickupRequirements    = 0
local M1SETechPickupRequirements    = 0



----------------------------------------------------------------------------- #
-- === TUNING VARIABLES ====================================================== #
----------------------------------------------------------------------------- #
local EasyV         = 0
local MediumV       = 1
local HardV         = 0
local DifficultyV   = (1 * EasyV) + (2 * MediumV) + (3 * HardV)
ScenarioInfo.Difficulty = ScenarioInfo.Options.Difficulty or DifficultyV

if ScenarioInfo.Difficulty == 1 then
    EasyV         = 1
    MediumV       = 0
    HardV         = 0
elseif ScenarioInfo.Difficulty == 2 then
    EasyV         = 0
    MediumV       = 1
    HardV         = 0
elseif ScenarioInfo.Difficulty == 3 then
    EasyV         = 0
    MediumV       = 0
    HardV         = 1
end

local Difficulty1_Suffix = '_D1'
local Difficulty2_Suffix = '_D2'
local Difficulty3_Suffix = '_D3'

ScenarioInfo.VarTable['M1AeonNETechDefenseGroups']              = (1 * EasyV) + (3 * MediumV) + (5 * HardV)
ScenarioInfo.VarTable['M1AeonSETechDefenseGroups']              = (1 * EasyV) + (3 * MediumV) + (5 * HardV)

ScenarioInfo.VarTable['M1AeonTech1ResponseGroups']              = (3 * EasyV) + (4 * MediumV) + (8 * HardV)

ScenarioInfo.VarTable['M1AeonSecondTechDefenseGroups']          = (2 * EasyV) + (2 * MediumV) + (2 * HardV)
ScenarioInfo.VarTable['M1AeonFinalAssaultNavalGroups']          = (2 * EasyV) + (4 * MediumV) + (6 * HardV)
ScenarioInfo.VarTable['M1AeonFinalAssaultAirGroups']            = (1 * EasyV) + (4 * MediumV) + (6 * HardV)

ScenarioInfo.VarTable['M2AeonAMLandTankPlatoonsAllowed']        = (1 * EasyV) + (3 * MediumV) + (5 * HardV)
ScenarioInfo.VarTable['M2AeonAMLandAntiAirPlatoonsAllowed']     = (1 * EasyV) + (1 * MediumV) + (3 * HardV)
ScenarioInfo.VarTable['M2AeonAMLandOtherPlatoonsAllowed']       = (1 * EasyV) + (2 * MediumV) + (4 * HardV)
ScenarioInfo.VarTable['M2AeonAMLandPlatoonsNeeded']             = (3 * EasyV) + (6 * MediumV) + (12 * HardV)

ScenarioInfo.VarTable['M2AeonAMNavalPlatoonsAllowed']           = (2 * EasyV) + (4 * MediumV) + (6 * HardV)
ScenarioInfo.VarTable['M2AeonAMNavalPlatoonsNeeded']            = (2 * EasyV) + (4 * MediumV) + (6 * HardV)
ScenarioInfo.VarTable['M2AeonAMNavalDefenseAllowed']            = (1 * EasyV) + (1 * MediumV) + (3 * HardV)
ScenarioInfo.VarTable['M2AeonAMLandBaseDefenseAllowed']         = (2 * EasyV) + (4 * MediumV) + (6 * HardV)

ScenarioInfo.VarTable['M2AeonT1EngineersAllowed']               = (2 * EasyV) + (4 * MediumV) + (6 * HardV)
ScenarioInfo.VarTable['M2AeonT2EngineersAllowed']               = (2 * EasyV) + (4 * MediumV) + (6 * HardV)

ScenarioInfo.VarTable['M2AeonFrigatesAllowed']                  = (4 * EasyV) + (6 * MediumV) + (14 * HardV)
ScenarioInfo.VarTable['M2AeonLightAttackBoatsAllowed']          = (6 * EasyV) + (8 * MediumV) + (12 * HardV)

ScenarioInfo.VarTable['M2AeonOffscreenNavalPlatoonsAllowed']    = (1 * EasyV) + (1 * MediumV) + (3 * HardV)

ScenarioInfo.VarTable['M3AeonBaseDefenseAllowed']               = (1 * EasyV) + (2 * MediumV) + (3 * HardV)
ScenarioInfo.VarTable['M3JanusBaseDefenseAllowed']              = (2 * EasyV) + (4 * MediumV) + (6 * HardV)

ScenarioInfo.VarTable['M3AeonT1EngineersAllowed']               = (2 * EasyV) + (4 * MediumV) + (6 * HardV)
ScenarioInfo.VarTable['M3AeonT2EngineersAllowed']               = (2 * EasyV) + (4 * MediumV) + (6 * HardV)
ScenarioInfo.VarTable['M3JanusT1EngineersAllowed']              = (2 * EasyV) + (4 * MediumV) + (6 * HardV)
ScenarioInfo.VarTable['M3JanusT2EngineersAllowed']              = (2 * EasyV) + (4 * MediumV) + (6 * HardV)

----------------------------------------------------------------------------- #
-- === TUNING AND TIMING VARIABLES FOR DESIGN ================================ #
----------------------------------------------------------------------------- #
-- Counts
local M1AeonAirAttackCount = 3
local M1AeonNavalAttackCount = 3

local M2AeonAttacksBecomeLarge = 20     -- divide by 2 for actuall number of waves
local M2AeonAttacksBecomeMedium = 14     -- divide by 2 for actuall number of waves
local M2MaximumOffscreenPlatoonsAlive = 2

local M3NorthDefensesPercentage = 0.5

-- Times
local M1AeonAirAttackDelay = (280 * EasyV) + (210 * MediumV) + (170 * HardV)
local M1AeonAirAttackTime = (340 * EasyV) + (300 * MediumV) + (220 * HardV)
local M1AeonNavalAttackDelay = (900 * EasyV) + (630 * MediumV) + (470 * HardV)
local M1AeonNavalAttackTime = (790 * EasyV) + (600 * MediumV) + (360 * HardV)
local M1JanusPickupDelayTime = 5
local M1JanusCommanderLeavesDelayTime = 6.5
local M1TempleDefenseDelayTime = 6
local M1SecondTechDefenseDelayTime = 9
local M1FinalAssaultDelayTime = 15
local M1FinalAssaultSafetyTime = 300
local M1SecondTechDefenseSafetyTime = 300
local M1CompleteDelayTime = 1.5

local M1P1Reminder1Delay = 900 -- 15 minutes
local M1P1Reminder2Delay = 600 -- 25 minutes
local M1P2Reminder1Delay = 900 -- 15 minutes
local M1P2Reminder2Delay = 600 -- 25 minutes
local M1P3Reminder1Delay = 900 -- 15 minutes
local M1P3Reminder2Delay = 600 -- 25 minutes
local M1P4Reminder1Delay = 900 -- 15 minutes
local M1P4Reminder2Delay = 600 -- 25 minutes

local M1ToM2Delay = 5

local M2AeonScoutDelay = 30
local M2AeonOffscreenAttackDelay = (580 * EasyV) + (340 * MediumV) + (230 * HardV)
local M2AeonOffscreenAttackRepeatDelay = (530 * EasyV) + (340 * MediumV) + (240 * HardV)
local M2AeonOffscreenNavalAssaultDelay = 900 -- not tweaking this based on difficulty because the force is a different size
local M2LandAssaultAttackTime = (60 * EasyV) + (45 * MediumV) + (30 * HardV)
local M2NavalAssaultAttackTime = (60 * EasyV) + (45 * MediumV) + (30 * HardV)
local M2JanusPickupDelayTime = 1

local M2AeonFirstVODelay = 240
local M2AeonSecondVODelay = 480
local M2AeonThirdVODelay = 960

local M2P1Reminder1Delay = 900 -- 15 minutes
local M2P1Reminder2Delay = 600 -- 25 minutes

local M2ToM3Delay = 5

local M3JanusAttackTime = (360 * EasyV) + (300 * MediumV) + (240 * HardV)
local M3AeonAttackTime = (360 * EasyV) + (300 * MediumV) + (240 * HardV)

local Mission3Begun = false

local M3AeonFirstTauntDelay = 300
local M3AeonSecondTauntDelay = 600
local M3AeonThirdTauntDelay = 900

local M3ScoutDelayTime = 60

local M3P1Reminder1Delay = 900 -- 15 minutes
local M3P1Reminder2Delay = 600 -- 25 minutes
local M3P2Reminder1Delay = 900 -- 15 minutes
local M3P2Reminder2Delay = 600 -- 25 minutes

local M3FinishedDelay = 1

-- Distances
local M1JanusSafeRadius = 20

-- Mission 1 Land Tech Allowance: Heavy Tank, Mobile Flak
-- Mission 1 Building Tech Allowance: T2 Land Factory
local M1CybranLandTechAllowance = categories.url0202 + categories.url0205
local M1CybranBuildingTechAllowance = categories.urb0201

local M1AeonLandTechAllowance = categories.ual0202 + categories.ual0205 + categories.ual0208
local M1AeonBuildingTechAllowance = categories.uab0201

-- Mission 2 Building Tech Allowance: T2 Heavy Gun Tower + T2 Anti-Air Flak Cannon
-- Mission 2 Land Tech Allowance: T2 Engineer
local M2CybranBuildingTechAllowance = categories.urb2204 + categories.urb2301
local M2CybranLandTechAllowance = categories.url0208

local M2AeonBuildingTechAllowance = categories.uab2204 +categories.uab2301
local M2AeonLandTechAllowance = categories.ual0208

local M2JanusDoesntNeedTheseGone = categories.WALL + categories.ECONOMIC + categories.INTELLIGENCE

-- Mission 3 Land Tech Allowance: Mobile Missile Launcher
local M3CybranLandTechAllowance = categories.url0111
local M3AeonLandTechAllowance = categories.ual0111

-- Taunt related
local PlayerUnitsLost = 50
local UnitsLostGrowth = 5
local AeonTauntNumber = 0
local TauntTriggerCount = 0
ScenarioInfo.TauntsAllowed = true

ScenarioInfo.M3AeonCDRDead = false


--------------------------------------------------------------------------- #
-- === STARTER FUNCTIONS ===================================================== #
----------------------------------------------------------------------------- #
function OnPopulate(scenario)
    ScenarioUtils.InitializeScenarioArmies()
    ScenarioFramework.GetLeaderAndLocalFactions()

    ScenarioFramework.SetCybranColor(Player)
    ScenarioFramework.SetAeonColor(Aeon)
    ScenarioFramework.SetAeonColor(FakeAeon)
    ScenarioFramework.SetAeonColor(Civilian)

    -- ScenarioFramework.SetCybranAllyColor(CybranJanus)
    -- ScenarioFramework.SetCybranAllyColor(FakeJanus)

    -- Civilian stuff (temples, etc)
    ScenarioInfo.CivilianTemple1 = ScenarioUtils.CreateArmyUnit('Civilian', 'Village_1_Temple')
    ScenarioInfo.CivilianTemple2 = ScenarioUtils.CreateArmyUnit('Civilian', 'Village_2_Temple')
    ScenarioInfo.CivilianTemple3 = ScenarioUtils.CreateArmyUnit('Civilian', 'Village_3_Temple')
    ScenarioInfo.CivilianTempleNE = ScenarioUtils.CreateArmyUnit('Civilian', 'NE_Temple')
    ScenarioInfo.CivilianTempleSE = ScenarioUtils.CreateArmyUnit('Civilian', 'SE_Temple')
    ScenarioUtils.CreateArmyGroup('Civilian', 'Villiage_Structures')

    ScenarioInfo.CivilianTempleNE:SetReclaimable(false)
    ScenarioInfo.CivilianTempleNE:SetCapturable(false)
    ScenarioInfo.CivilianTempleSE:SetReclaimable(false)
    ScenarioInfo.CivilianTempleSE:SetCapturable(false)
    ScenarioInfo.CivilianTemple1:SetReclaimable(false)
    ScenarioInfo.CivilianTemple1:SetCapturable(false)
    ScenarioInfo.CivilianTemple2:SetReclaimable(false)
    ScenarioInfo.CivilianTemple2:SetCapturable(false)
    ScenarioInfo.CivilianTemple3:SetReclaimable(false)
    ScenarioInfo.CivilianTemple3:SetCapturable(false)

    ScenarioInfo.M1_TempleCombinedTable = {}
    table.insert(ScenarioInfo.M1_TempleCombinedTable, ScenarioInfo.CivilianTemple1)
    table.insert(ScenarioInfo.M1_TempleCombinedTable, ScenarioInfo.CivilianTemple2)
    table.insert(ScenarioInfo.M1_TempleCombinedTable, ScenarioInfo.CivilianTemple3)
    table.insert(ScenarioInfo.M1_TempleCombinedTable, ScenarioInfo.CivilianTempleNE)
    table.insert(ScenarioInfo.M1_TempleCombinedTable, ScenarioInfo.CivilianTempleSE)
end

function OnStart(self)
    ScenarioFramework.SetPlayableArea('M1_Playable_Area', false)

    if(ScenarioInfo.Difficulty == 1) then
        ScenarioInfo.VarTable['DifficultyIs1'] = true
    elseif(ScenarioInfo.Difficulty == 2) then
        ScenarioInfo.VarTable['DifficultyIs2'] = true
    elseif(ScenarioInfo.Difficulty == 3) then
        ScenarioInfo.VarTable['DifficultyIs3'] = true
    end

    ForkThread(IntroNIS)
end

function IntroNIS()
    ScenarioFramework.StartOperationJessZoom('CDRZoom', StartMission1)
end

----------------------------------------------------------------------------- #
-- === MISSION 1 ============================================================= #
----------------------------------------------------------------------------- #
function StartMission1()
    for _, player in ScenarioInfo.HumanPlayers do
        SetArmyUnitCap(player, 300)
    end
    SetArmyUnitCap(2, 400)
    SetArmyUnitCap(3, 500)

    -- Player stuff
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

    ScenarioFramework.PauseUnitDeath(ScenarioInfo.PlayerCDR)

    for index, coopACU in ScenarioInfo.CoopCDR do
        ScenarioFramework.PauseUnitDeath(coopACU)
        ScenarioFramework.CreateUnitDeathTrigger(PlayerCDRKilled, coopACU)
    end

    -- Player death trigger
    ScenarioFramework.CreateUnitDeathTrigger(PlayerCDRKilled, ScenarioInfo.PlayerCDR)

    M1CreateUnits()
    M1SetupTriggers()
    M1GiveTech()

    ForkThread(M1SpawnAeonAirAttack)
    ForkThread(M1SpawnAeonNavalAttack)

    ForkThread(M1JanusLeaves)

    -- Seed our aeon taunt playing cycle: 50 units will kick it off
    ScenarioFramework.CreateArmyStatTrigger(PlayAeonTaunt, ArmyBrains[Aeon], 'AeonTauntStartTrigger',
        {{ StatType = 'Enemies_Killed', CompareType = 'GreaterThan', Value = PlayerUnitsLost, Category = categories.CYBRAN, },}) -- Player units killed by Aeon
end

function RandomizeLocationsInPlatoon(platoon, shuffleRadius)
    local position = nil
    local amount = shuffleRadius * 10
    for counter, unit in platoon:GetPlatoonUnits() do
        position = unit:GetPosition()
        Warp(unit, {position[1] + (Random(amount * -1,amount) / 10), position[2], position[3] - (Random(amount * -1,amount) / 10)})
    end
end

function PatrolAtLocation(platoon)
    local initialPoint = platoon.PlatoonData.Location
    local multiplier = 1

    if Random(0,1) == 0 then
        multiplier = -1
    end

    local offsetPoint = { initialPoint[1] +(10 * multiplier), initialPoint[2], initialPoint[3] +(10 * multiplier) }
    local firstMove = platoon:Patrol(initialPoint)
    local secondMove = platoon:Patrol(offsetPoint)
end

function MakeGroupsIntoPlatoon(brain, ...)
    local newPlatoon = brain:MakePlatoon('', '')
    local name = brain.Name

    local i = 1
    while i <= arg['n'] do
        local group = ScenarioUtils.CreateArmyGroup(name, arg[i])
        for counter, unit in group do
            brain:AssignUnitsToPlatoon(newPlatoon, {unit}, 'Attack', 'ChevronFormation')
        end
        i = i + 1
    end

    return newPlatoon
end

function M1CreateUnits()
    -- Defeat all the units defending the NE temple
    ScenarioInfo.NeTempleDefenders = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', AdjustForDifficulty('M1_NE_Village_Defenders'), 'TravellingFormation')
    ScenarioFramework.CreatePlatoonDeathTrigger(M1NEDefendersKilled, ScenarioInfo.NeTempleDefenders)
    ScenarioFramework.PlatoonPatrolRoute(ScenarioInfo.NeTempleDefenders, ScenarioUtils.ChainToPositions('TempleNE_Route'))

    -- Defeat all the units defending the SE temple
    local seTempleDefenders = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', AdjustForDifficulty('M1_SE_Village_Defenders'), 'TravellingFormation')
    ScenarioFramework.CreatePlatoonDeathTrigger(M1SEDefendersKilled, seTempleDefenders)
    ScenarioFramework.PlatoonPatrolRoute(seTempleDefenders, ScenarioUtils.ChainToPositions('TempleSE_Route'))

    -- Cheat for Janus so he can capture things
    ScenarioInfo.JanusEnergyCheat = ScenarioUtils.CreateArmyUnit('CybranJanus', 'Janus_Energy_Cheat')
end

function PlayAeonTaunt()
    -- Make new value for next taunt
    PlayerUnitsLost = ArmyBrains[Aeon]:GetArmyStat('Enemies_Killed',0).Value + 50 + UnitsLostGrowth

    -- create a new stats trigger again, if we arent at the end of our taunts.
    -- Concatenate using taunt number, so each new instance of this trigger is uniquely named
    TauntTriggerCount = TauntTriggerCount + 1
    if AeonTauntNumber < 7 then
        ScenarioFramework.CreateArmyStatTrigger(PlayAeonTaunt, ArmyBrains[Aeon], 'AeonTauntTrigger'..TauntTriggerCount,
            {{ StatType = 'Enemies_Killed', CompareType = 'GreaterThan', Value = PlayerUnitsLost, Category = categories.CYBRAN, },}) -- Player units killed by Aeon
    end

    -- Have we waited at least three minutes since our last taunt? Aeon CDR still around? We run out of our 8 taunts yet?
    if ScenarioInfo.TauntsAllowed == true and ScenarioInfo.M3AeonCDRDead == false and AeonTauntNumber < 8 then
        -- Increment to next taunt
        AeonTauntNumber = AeonTauntNumber + 1 -- starts at zero, so keep this before the actual dialogue call below

        -- Increase the length of time between taunts just a tad over time
        UnitsLostGrowth = UnitsLostGrowth + 5

        -- Play an incremented taunt
        ScenarioFramework.Dialogue(OpStrings['TAUNT' .. AeonTauntNumber])

        -- no taunts for a little bit, and start a timer trigger to re-allow after a wait
        -- (so we dont get back-to-back taunts if the player is losing a lot of units)
        ScenarioInfo.TauntsAllowed = false
        ScenarioFramework.CreateTimerTrigger(ReAllowTaunts, 180)
    end
end

function ReAllowTaunts()
    -- Allow taunts to be played, now that a few minutes have passed since the last one.
    ScenarioInfo.TauntsAllowed = true
end

-- ====================================== #
-- Copied from Brian's E03:
-- SpawnM1AirAttack: spawn [M1AirAttackCount] to attack the player base until killed every [M1AirAttackTime] seconds
-- ====================================== #
function M1SpawnAeonAirAttack()
    WaitSeconds(M1AeonAirAttackDelay)
    if ScenarioInfo.MissionNumber == 1 then
        for attackCounter = 1, M1AeonAirAttackCount do
            ForkThread(M1AeonAirAttack)
            WaitSeconds(3)
        end
    end
end
function M1RespawnAeonAirAttack()
    ScenarioInfo.M1InitialAirAttackDead = true
    if ScenarioInfo.MissionNumber == 1 then
        ForkThread(M1AeonAirAttack)
    end
end
function M1AeonAirAttack()
    WaitSeconds(M1AeonAirAttackTime)
    if ScenarioInfo.MissionNumber == 1 then

        local m1AeonAir = nil

        if ScenarioInfo.M1InitialAirAttackDead then
            m1AeonAir = MakeGroupsIntoPlatoon(ArmyBrains[Aeon], AdjustForDifficulty('M1_Aeon_AirAttack_Interceptors'), AdjustForDifficulty('M1_Aeon_AirAttack_Bombers'))
        else
            m1AeonAir = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', AdjustForDifficulty('M1_Aeon_AirAttack_Initial'), 'TravellingFormation')
        end

        RandomizeLocationsInPlatoon(m1AeonAir, 5)

        local spawnPoint = ScenarioFramework.GetRandomEntry(ScenarioUtils.ChainToPositions('M1_Aeon_Offscreen_Points'))
        local attackPoint = ScenarioFramework.GetRandomEntry(ScenarioUtils.ChainToPositions('M1_Aeon_AirAttack_Attackpoints'))

        ScenarioFramework.CreatePlatoonDeathTrigger(M1RespawnAeonAirAttack, m1AeonAir)
        m1AeonAir:MoveToLocation(spawnPoint, false)
        m1AeonAir:Patrol(attackPoint)
        m1AeonAir:Patrol(ScenarioUtils.MarkerToPosition('Initial_Player_Pos'))
    end
end

-- ====================================== #
-- Copied from Brian's E03:
-- SpawnM1NavalAttack: spawn [M1NavalAttackCount] to attack the player base until killed every [M1NavalAttackTime] seconds
-- ====================================== #
function M1SpawnAeonNavalAttack()
    WaitSeconds(M1AeonNavalAttackDelay)
    if ScenarioInfo.MissionNumber == 1 then
        for attackCounter = 1, M1AeonNavalAttackCount do
            ForkThread(M1AeonNavalAttack)
            WaitSeconds(3)
        end
    end
end
function M1RespawnAeonNavalAttack()
    ScenarioInfo.M1InitialNavalAttackDead = true
    if ScenarioInfo.MissionNumber == 1 then
        ForkThread(M1AeonNavalAttack)
    end
end
function M1AeonNavalAttack()
    WaitSeconds(M1AeonNavalAttackTime)
    if ScenarioInfo.MissionNumber == 1 then
        local m1AeonNaval = nil

        if ScenarioInfo.M1InitialNavalAttackDead then
            local frigates = ScenarioUtils.CreateArmyGroup('Aeon', AdjustForDifficulty('M1_Aeon_NavalAttack_Frigates'))

            m1AeonNaval = ArmyBrains[Aeon]:MakePlatoon('', '')

            for counter, unit in frigates do
                ArmyBrains[Aeon]:AssignUnitsToPlatoon(m1AeonNaval, {unit}, 'Attack', 'ChevronFormation')
            end
        else
            m1AeonNaval = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', AdjustForDifficulty('M1_Aeon_NavalAttack_Initial'), 'TravellingFormation')
        end

        RandomizeLocationsInPlatoon(m1AeonNaval, 5)

        local spawnPoint = ScenarioFramework.GetRandomEntry(ScenarioUtils.ChainToPositions('M1_Aeon_NavalAttack_Spawnpoints'))
        local attackPoint = ScenarioFramework.GetRandomEntry(ScenarioUtils.ChainToPositions('M1_Aeon_NavalAttack_Attackpoints'))

        ScenarioFramework.CreatePlatoonDeathTrigger(M1RespawnAeonNavalAttack, m1AeonNaval)
        m1AeonNaval:MoveToLocation(spawnPoint, false)
        m1AeonNaval:Patrol(attackPoint)
        m1AeonNaval:Patrol(ScenarioUtils.MarkerToPosition('M1_Aeon_Naval_PatrolPoint'))
    end
end

function M1SetupTriggers()
    local platoon = nil
    local counter = 0

    -- Blow up the "first" temple at NE that contains tech
    ScenarioFramework.CreateUnitDeathTrigger(M1P2Complete, ScenarioInfo.CivilianTempleNE)
    -- Blow up the "second" temple at SE that contains tech
    ScenarioFramework.CreateUnitDeathTrigger(M1P3Complete, ScenarioInfo.CivilianTempleSE)

    -- Spot the temple in the northeast
    ScenarioFramework.CreateArmyIntelTrigger(M1P2Activate, ArmyBrains[Player], 'LOSNow', ScenarioInfo.CivilianTempleNE, true, categories.ALLUNITS, true, ArmyBrains[Civilian])

    -- Reminders
    ScenarioFramework.CreateTimerTrigger(M1P1Reminder1, M1P1Reminder1Delay)
end

function M1JanusLeaves()
    WaitSeconds(1.5)

    -- === M1P1. Clear Village of Aeon Units ================================ #
    local m1JanusCDR = ScenarioUtils.CreateArmyGroupAsPlatoon('CybranJanus', 'M1_Janus', 'TravellingFormation')
    local m1JanusCDRUnit = ScenarioInfo.UnitNames[CybranJanus]['M1_Janus_Commander']
    m1JanusCDRUnit:SetCustomName(LOC '{i CDR_Mach}')
    m1JanusCDRUnit:CreateEnhancement('Teleporter')
    ForkThread (WarpInEffectThread,m1JanusCDRUnit)
    m1JanusCDRUnit:SetCapturable(false)
    m1JanusCDRUnit:SetReclaimable(false)
    m1JanusCDRUnit:SetCanBeKilled(false)
    m1JanusCDRUnit:SetCanTakeDamage(false)


    ForkThread(TrackIntialJanusThread,m1JanusCDRUnit)

    WaitSeconds(M1JanusCommanderLeavesDelayTime)

    local objUnits = ScenarioInfo.NeTempleDefenders:GetPlatoonUnits()

    ScenarioInfo.M1P1 = Objectives.Basic(
        'primary',
        'incomplete',
        OpStrings.M1P1Title,
        OpStrings.M1P1Description,
        Objectives.GetActionIcon('kill'),
        {
            Units = objUnits,
            MarkUnits = true,
        }
    )

    ScenarioFramework.Dialogue(ScenarioStrings.NewPObj)
    ScenarioFramework.Dialogue(OpStrings.C02_M01_010)

    local m1JanusLeaves = m1JanusCDR:MoveToLocation(ScenarioUtils.MarkerToPosition('Janus_Teleport_Point'), false)

    while m1JanusCDR:IsCommandsActive(m1JanusLeaves) == true do
        WaitSeconds(1)
    end

    ScenarioFramework.FakeTeleportUnit(m1JanusCDRUnit, true)
end

function WarpInEffectThread(unit)
    unit:HideBone(0, true)
    unit:SetUnSelectable(true)
    unit:SetBusy(true)
    unit:PlayUnitSound('CommanderArrival')
    unit:CreateProjectile('/effects/entities/UnitTeleport02/UnitTeleport02_proj.bp', 0, 1.35, 0, nil, nil, nil):SetCollision(false)
    WaitSeconds(2.1)
    unit:SetMesh('/units/url0001/URL0001_PhaseShield_mesh', true)
    unit:ShowBone(0, true)
    unit:HideBone('Back_Upgrade', true)
    unit:HideBone('Right_Upgrade', true)
    unit:SetUnSelectable(false)
    unit:SetBusy(false)

    local totalBones = unit:GetBoneCount() - 1
    local army = unit:GetArmy()
    for k, v in EffectTemplate.UnitTeleportSteam01 do
        for bone = 1, totalBones do
            CreateAttachedEmitter(unit,bone,army, v)
        end
    end

    WaitSeconds(6)
    unit:SetMesh(unit:GetBlueprint().Display.MeshBlueprint, true)
end

function TrackIntialJanusThread(unit)
    while not unit:IsDead() do
        WaitSeconds(1)
    end
    for _, player in ScenarioInfo.HumanPlayers do
        SetAlliance(player, CybranJanus, 'Ally')
        SetAlliance(CybranJanus, player, 'Ally')
    end
end

function M1GiveTech()
    -- No one should be able to build any T3 units
    for _, player in ScenarioInfo.HumanPlayers do
         ScenarioFramework.AddRestriction(player, categories.TECH3)
    end
    ScenarioFramework.AddRestriction(CybranJanus, categories.TECH3)
    ScenarioFramework.AddRestriction(Aeon, categories.TECH3)

    -- Most T2 units are not buildable at the start of this mission
    for _, player in ScenarioInfo.HumanPlayers do
         ScenarioFramework.AddRestriction(player, categories.TECH2)
    end
    ScenarioFramework.AddRestriction(CybranJanus, categories.TECH2)
    ScenarioFramework.AddRestriction(Aeon, categories.TECH2)

    -- Aeon shouldn't be able to build the Attack submarine
    ScenarioFramework.AddRestriction(Aeon, categories.uas0203)

    -- Now, let's add some stuff back in that everyone CAN build
    -- Heavy Tank and Mobile Flak
    -- T2 Land Factory
    -- T2 Land Defense and T2 Anti-Air Defense
    ScenarioFramework.RemoveRestrictionForAllHumans(M1CybranLandTechAllowance + M1CybranBuildingTechAllowance )

    ScenarioFramework.RemoveRestriction(CybranJanus, M1CybranLandTechAllowance +
                                          M1CybranBuildingTechAllowance)

    ScenarioFramework.RemoveRestriction(Aeon, M1AeonLandTechAllowance +
                                   M1AeonBuildingTechAllowance)

    -- Commander enhancements
    ScenarioFramework.RestrictEnhancements({'AdvancedEngineering', -- 1
                                            'CloakingGenerator',
                                            'T3Engineering',
                                            'NaniteTorpedoTube',
                                            'StealthGenerator',
                                            'Teleporter'})
end

function M1P6Assign(tech)
    if not ScenarioInfo.M1P6_Assigned then
        ScenarioInfo.M1P6_Assigned = true
        ScenarioInfo.M1P6 = Objectives.Basic(
            'primary', 'incomplete', OpStrings.M1P6Title, OpStrings.M1P6Description,
            Objectives.GetActionIcon('protect'),
            {
                Units = {tech},
                -- MarkUnits = true,
            }
        )
    end
end

function M1P2Complete()
    -- The player has blown up the northeast temple

    ScenarioInfo.M1P2Complete = true

    local northeastPickupPoint = ScenarioUtils.MarkerToPosition('M1_NE_Village_LZ')
    local northeastTechSpot = ScenarioUtils.MarkerToPosition('M1_NE_Village_Tech_Spot')

    ScenarioInfo.M1NETechFound = true

    ScenarioInfo.CivilianTempleNETech = ScenarioUtils.CreateArmyUnit('Civilian', 'NE_Tech')
    ScenarioInfo.CivilianTempleNETech:SetCustomName(LOC '<LOC opc2002_desc>Seraphim Tech')

    -- Make the tech impervious to everything
    ScenarioInfo.CivilianTempleNETech:SetCanTakeDamage(false)
    ScenarioInfo.CivilianTempleNETech:SetCanBeKilled(false)
    ScenarioInfo.CivilianTempleNETech:SetReclaimable(false)
    ScenarioInfo.CivilianTempleNETech:SetCapturable(false)

    -- reveal NE tech cam
    ForkThread(TechRevealedNISCamera, ScenarioInfo.CivilianTempleNETech)

    ScenarioFramework.CreateUnitCapturedTrigger(nil, M1TechTranslation, ScenarioInfo.CivilianTempleNETech)

    if not ScenarioInfo.M1P2 then
        M1P2Activate()
    end
    ScenarioInfo.M1P2:ManualResult(true)
    ScenarioFramework.Dialogue(ScenarioStrings.PObjComp)

    M1NETechPickupRequirements = M1NETechPickupRequirements + 1

    -- Check to see what order the player is doing things in.  Did he already find the tech to the SE?
    if M1NETechPickupRequirements > 1 then
    -- If the defenders were already taken out, then we're ready to bring in Janus for the pickup.  Otherwise, we do nothing here.
        if ScenarioInfo.M1SETechFound == false then
            -- This is the first piece of tech
            ScenarioFramework.CreateAreaTrigger(M1JanusClearedForTakeoffToNE, ScenarioUtils.AreaToRect('NE_Temple_Safe_Zone'), categories.ALLUNITS, true, true, ArmyBrains[Aeon], 1, false)
            M1P6Assign(ScenarioInfo.CivilianTempleNETech)
        else
            ScenarioInfo.M1DestinationIsNE = true
            ForkThread(M1SpawnSecondTechDefense)
        end
    end
end

function M1P2Activate()
    -- Theoretically, this is only supposed to happen when you see the T1 units guarding the NORTHEAST temple, specifically.

    -- === M1P2. Destroy Temple to Find Tech ========================================= #
    ScenarioInfo.M1P2 = Objectives.Basic(
        'primary', 'incomplete', OpStrings.M1P2Title, OpStrings.M1P2Description,
        Objectives.GetActionIcon('kill'),
        {
            Units = {ScenarioInfo.CivilianTempleNE},
            MarkUnits = true,
        }
    )
    ScenarioFramework.Dialogue(ScenarioStrings.NewPObj)

    ScenarioFramework.CreateTimerTrigger(M1P2Reminder1, M1P2Reminder1Delay)
    ScenarioFramework.CreateTimerTrigger(M1P2Reminder2, M1P2Reminder2Delay)
end

function M1NEDefendersDeathCheck(deadPlatoon)
    ScenarioInfo.VarTable['M1AeonNETechDefenseGroups'] = ScenarioInfo.VarTable['M1AeonNETechDefenseGroups'] - 1

    if ScenarioInfo.VarTable['M1AeonNETechDefenseGroups'] < 1 then
        ForkThread(M1NEDefendersKilled)
    end
end



function M1NEDefendersKilled()
    -- Player has killed the defenders to the NE.  This one could also be called "M1P1Complete".
    ScenarioInfo.M1P1Complete = true

    local destination = ScenarioUtils.MarkerToPosition('M1_NE_Village_LZ')
    local techSpot = ScenarioUtils.MarkerToPosition('M1_NE_Village_Tech_Spot')

    ScenarioInfo.M1P1:ManualResult(true)
    ScenarioFramework.Dialogue(ScenarioStrings.PObjComp)

    M1NETechPickupRequirements = M1NETechPickupRequirements + 1

    if M1NETechPickupRequirements > 1 then
    -- If the temple was already blown up, then we're ready to bring in Janus for the pickup.  Otherwise, we do nothing here.
        if ScenarioInfo.M1TechsPickedUp == 0 then
            ScenarioFramework.CreateAreaTrigger(M1JanusClearedForTakeoffToNE, ScenarioUtils.AreaToRect('NE_Temple_Safe_Zone'), categories.ALLUNITS, true, true, ArmyBrains[Aeon], 1, false)
            M1P6Assign(ScenarioInfo.CivilianTempleNETech)
        else
            ScenarioInfo.M1DestinationIsNE = true
            ForkThread(M1SpawnSecondTechDefense)
        end
    end
end

function M1SEDefendersDeathCheck(deadPlatoon)
    ScenarioInfo.VarTable['M1AeonSETechDefenseGroups'] = ScenarioInfo.VarTable['M1AeonSETechDefenseGroups'] - 1

    if ScenarioInfo.VarTable['M1AeonSETechDefenseGroups'] < 1 then
        ForkThread(M1SEDefendersKilled)
    end
end

function M1SEDefendersKilled()
    -- Player has taken out the defenders at the southeast temple.  Note that these defenders are not mentioned in the doc -- I put them
    -- in here because it would be weird for the player to just march in to the SE temple area and take it over with no resistance.
    local destination = ScenarioUtils.MarkerToPosition('M1_SE_Village_LZ')
    local techSpot = ScenarioUtils.MarkerToPosition('M1_SE_Village_Tech_Spot')

    M1SETechPickupRequirements = M1SETechPickupRequirements + 1

    if M1SETechPickupRequirements > 1 then
    -- If the temple was already blown up, then we're ready to bring in Janus for the pickup.  Otherwise, we do nothing here.
        if ScenarioInfo.M1TechsPickedUp == 0 then
            ScenarioFramework.CreateAreaTrigger(M1JanusClearedForTakeoffToSE, ScenarioUtils.AreaToRect('SE_Temple_Safe_Zone'), categories.ALLUNITS, true, true, ArmyBrains[Aeon], 1, false)
            M1P6Assign(ScenarioInfo.CivilianTempleSETech)
        else
            ScenarioInfo.M1DestinationIsNE = false
            ForkThread(M1SpawnSecondTechDefense)
        end
    end
end
function M1P3Assign()
    ScenarioInfo.M1P3 = Objectives.Basic(
        'primary', 'incomplete', OpStrings.M1P3Title, OpStrings.M1P3Description,
        Objectives.GetActionIcon('locate'),
        {
            Units = ScenarioInfo.M1_TempleCombinedTable,
            MarkUnits = true,
        }
    )
end

function M1P4Assign(objArea)
    ScenarioInfo.M1P4 = Objectives.Basic(
        'primary', 'incomplete', OpStrings.M1P4Title, OpStrings.M1P4Description,
        Objectives.GetActionIcon('kill'),
        {
            Area = objArea,
            ShowFaction = 'Aeon',
            -- MarkUnits = true,
        }
    )
end
function M1P3Complete()
    -- Player has blown up the temple to the SE.  This one is a little tricky, because P1 (Investigate Village for Tech) is specifically called out
    -- as being in the northeast by VO.  But what happens if the player goes to the southeast temple first?  See below.
    ScenarioInfo.M1P3Complete = true

    local southeastPickupPoint = ScenarioUtils.MarkerToPosition('M1_SE_Village_LZ')
    local southeastTechSpot = ScenarioUtils.MarkerToPosition('M1_SE_Village_Tech_Spot')

    ScenarioInfo.M1SETechFound = true
    ScenarioInfo.M1DestinationIsNE = false

    ScenarioInfo.CivilianTempleSETech = ScenarioUtils.CreateArmyUnit('Civilian', 'SE_Tech')
    ScenarioInfo.CivilianTempleSETech:SetCustomName(LOC '<LOC opc2002_desc>Seraphim Tech')

    -- Make the tech impervious to everything
    ScenarioInfo.CivilianTempleSETech:SetCanTakeDamage(false)
    ScenarioInfo.CivilianTempleSETech:SetCanBeKilled(false)
    ScenarioInfo.CivilianTempleSETech:SetReclaimable(false)
    ScenarioInfo.CivilianTempleSETech:SetCapturable(false)

    -- reveal SE tech cam
    ForkThread(TechRevealedNISCamera, ScenarioInfo.CivilianTempleSETech)

    ScenarioFramework.CreateUnitCapturedTrigger(nil, M1TechTranslation, ScenarioInfo.CivilianTempleSETech)

    if not ScenarioInfo.M1P3Given then
        ScenarioInfo.M1P3Given = true
    else
        ScenarioInfo.M1P3:ManualResult(true)
    end

    ScenarioFramework.Dialogue(ScenarioStrings.PObjComp)

    M1SETechPickupRequirements = M1SETechPickupRequirements + 1

    -- Check to see what order the player is doing things in.  Did he already find the tech to the NE?
    if M1SETechPickupRequirements > 1 then
    -- If the defenders were already taken out, then we're ready to bring in Janus for the pickup.  Otherwise, we do nothing here.
        if ScenarioInfo.M1NETechFound == false then
            ScenarioFramework.CreateAreaTrigger(M1JanusClearedForTakeoffToSE, ScenarioUtils.AreaToRect('SE_Temple_Safe_Zone'), categories.ALLUNITS, true, true, ArmyBrains[Aeon], 1, false)

            M1P6Assign(ScenarioInfo.CivilianTempleSETech)
        else
        -- === M1P4. Defeat Aeon Defense Force ===================================== #
            M1P4Assign('SE_Temple_Reinforce')

            ScenarioFramework.Dialogue(OpStrings.C02_M01_080)

            ScenarioFramework.CreateTimerTrigger(M1P4Reminder1, M1P4Reminder1Delay)
            ScenarioFramework.CreateTimerTrigger(M1P4Reminder2, M1P4Reminder2Delay)

            ScenarioInfo.M1P4Given = true

            ForkThread(M1SpawnSecondTechDefense)
        end
    end
end

function M1JanusClearedForTakeoffToNE()
    -- It's time for Janus to pick up a piece of tech.  This only fires if there are no Aeon within 20 units of the tech, to make sure it's a safe LZ.

    if ScenarioInfo.M1TechsPickedUp == 2 then
        return
    end

    if not ScenarioInfo.JanusCrewIsActive then
        ScenarioInfo.JanusCrewIsActive = true

        if ScenarioInfo.M1TechsPickedUp == 0 then
            M1JanusPickupDelayTime = 5
        else
            M1JanusPickupDelayTime = 8
        end

        ForkThread(M1JanusTechPickupStart, ScenarioUtils.MarkerToPosition('M1_NE_Village_LZ'),
            ScenarioUtils.MarkerToPosition('M1_NE_Village_Tech_Spot'), ScenarioInfo.CivilianTempleNETech, M1JanusPickupDelayTime)
    else
        while ScenarioInfo.JanusCrewIsActive == true do
            WaitSeconds(1)
        end

        ForkThread(M1JanusClearedForTakeoffToNE)
    end
end

function M1JanusClearedForTakeoffToSE()
    -- It's time for Janus to pick up a piece of tech.  This only fires if there are no Aeon within 20 units of the tech, to make sure it's a safe LZ.

    if ScenarioInfo.M1TechsPickedUp == 2 then
    -- A little safety to make sure Janus doesn't come out when he's not supposed to
        return
    end

    if not ScenarioInfo.JanusCrewIsActive then
        if ScenarioInfo.M1TechsPickedUp == 0 then
            M1JanusPickupDelayTime = 5
        else
            M1JanusPickupDelayTime = 8
        end

        ForkThread(M1JanusTechPickupStart, ScenarioUtils.MarkerToPosition('M1_SE_Village_LZ'),
            ScenarioUtils.MarkerToPosition('M1_SE_Village_Tech_Spot'), ScenarioInfo.CivilianTempleSETech, M1JanusPickupDelayTime)
    else
        while ScenarioInfo.JanusCrewIsActive == true do
            WaitSeconds(1)
        end

        ForkThread(M1JanusClearedForTakeoffToSE)
    end
end

----------------------------------------------------------------------------- #
-- === JANUS COMES IN FROM OFFSCREEN TO PICK UP A PIECE OF TECH ============== #
----------------------------------------------------------------------------- #
function M1TechTranslation(unit)
    ScenarioInfo.CapturedTech = unit

    ScenarioInfo.CapturedTech:SetCanTakeDamage(false)
    ScenarioInfo.CapturedTech:SetCanBeKilled(false)
    ScenarioInfo.CapturedTech:SetCapturable(false)
    ScenarioInfo.CapturedTech:SetReclaimable(false)
end

function M1JanusTechPickupStart(PickupPoint, TechSpot, Tech, DelayTime)
    -- Player has taken out the defenders at a temple and blown that temple up.  He's also cleared out any other extraneous Aeon defenders.
    ScenarioInfo.JanusCrewIsActive = true

    if ScenarioInfo.M1TechsPickedUp == 1 then
        ScenarioInfo.M1P7 = Objectives.Basic(
            'primary', 'incomplete', OpStrings.M1P7Title, OpStrings.M1P7Description,
            Objectives.GetActionIcon('protect'),
            {
                Units = {Tech},
                MarkUnits = true,
            }
        )
    end

    WaitSeconds(DelayTime)

    ScenarioFramework.CreateUnitCapturedTrigger(nil, M1TechTranslation, Tech)

    local pickupPlatoon = ScenarioUtils.SpawnPlatoon('CybranJanus', 'M1_Tech_Pickup')
    local transport = ScenarioInfo.UnitNames[CybranJanus]['M1_Janus_Transport']
    local engineer = ScenarioInfo.UnitNames[CybranJanus]['M1_Tech_Pickup_Engineer']

    for counter, unit in pickupPlatoon:GetPlatoonUnits() do
        unit:SetCanTakeDamage(false)
        unit:SetCanBeKilled(false)
        unit:SetCapturable(false)
        unit:SetReclaimable(false)
    end

    -- Instant attach units to transports
    ScenarioFramework.AttachUnitsToTransports({engineer}, {transport})

    -- Janus drops off the engineer, who then moves to the tech location
    local unloadCommand = pickupPlatoon:UnloadAllAtLocation(PickupPoint)
    while pickupPlatoon:IsCommandsActive(unloadCommand) == true do
        WaitSeconds(1)
    end

    -- Move engineer to tech after been dropped off
    IssueMove({engineer}, TechSpot)
    WaitTicks(1)
    local autoFlip = false
    local counter = 0
    while engineer:IsUnitState('Moving') do
        if counter == 10 then
            autoFlip = true
            IssueClearCommands({engineer})
            ScenarioInfo.CapturedTech = ScenarioFramework.GiveUnitToArmy(Tech, CybranJanus)
            break
        end
        WaitSeconds(1)
        counter = counter + 1
    end

    if not autoFlip then
        -- Bool so we know if there is or isn't a tech at this point
        ScenarioInfo.CapturedTech = false
        Tech:SetCapturable(true)
        IssueCapture({engineer}, Tech)
        WaitSeconds(1)

        counter = 0
        while engineer:IsUnitState('Moving') or engineer:IsUnitState('Capturing')do
            WaitSeconds(1)
            counter = counter + 1
            if counter == 20 then
                autoFlip = true
                IssueClearCommands({engineer})
                ScenarioInfo.CapturedTech = ScenarioFramework.GiveUnitToArmy(Tech, CybranJanus)
                break
            end
        end

    end

    if ScenarioInfo.M1TechsPickedUp == 0 then
        ScenarioInfo.M1P6:ManualResult(true)
    elseif ScenarioInfo.M1TechsPickedUp == 1 then
        ScenarioInfo.M1P7:ManualResult(true)
    else
        -- Mission 2 tech
        ScenarioInfo.M2P3:ManualResult(true)
    end

    IssueClearCommands({transport})
    -- IssuePatrol({Transport}, TechSpot)
    pickupPlatoon = ArmyBrains[CybranJanus]:MakePlatoon('', '')

    -- Wait till we have a captured tech unit thing
    while not ScenarioInfo.CapturedTech do
        WaitSeconds(1)
    end

    local pickupUnits = { engineer, transport, ScenarioInfo.CapturedTech }
    ArmyBrains[CybranJanus]:AssignUnitsToPlatoon(pickupPlatoon, pickupUnits, 'Scout', 'ChevronFormation')

    ScenarioInfo.M1TechsPickedUp = ScenarioInfo.M1TechsPickedUp + 1

    local allLoaded = false
    local loadCam = false
    repeat
        IssueClearCommands(pickupUnits)
        local techPos = ScenarioInfo.CapturedTech:GetPosition()
        IssueMove({ScenarioInfo.CapturedTech}, { techPos[1] + .1, techPos[2], techPos[3] })
        local cmd = pickupPlatoon:LoadUnits(categories.ALLUNITS)

        -- Pickup tech cam
        WaitSeconds(1)
        if not loadCam then
            local camInfo = {
                blendTime = 1.0,
                holdTime = 6,
                orientationOffset = { 0, 0.2, 0 },
                positionOffset = { 0, 0.5, 0 },
                zoomVal = 30,
            }
            ScenarioFramework.OperationNISCamera(ScenarioInfo.CapturedTech, camInfo)
        end
        loadCam = true

        counter = 0
        while ArmyBrains[CybranJanus]:PlatoonExists(pickupPlatoon) and pickupPlatoon:IsCommandsActive(cmd) do
            counter = counter + 1
            if counter == 20 then
                pickupPlatoon:Stop()
                ScenarioFramework.AttachUnitsToTransports({engineer, ScenarioInfo.CapturedTech}, {transport})
                break
            end
            WaitSeconds(1)
        end

        allLoaded = true
        for k,v in pickupPlatoon:GetPlatoonUnits() do
            if EntityCategoryContains(categories.ALLUNITS - categories.TRANSPORTATION, v) and not v:BeenDestroyed() and not v:IsUnitState('Attached') then
                allLoaded = false
                break
            end
        end
    until allLoaded

    -- local pickupLoad = PickupPlatoon:LoadUnits(categories.ALLUNITS)
    local pickupUnload = pickupPlatoon:UnloadAllAtLocation(ScenarioUtils.MarkerToPosition('Tech_Pickup_Offscreen'))
    while ArmyBrains[CybranJanus]:PlatoonExists(pickupPlatoon) and pickupPlatoon:IsCommandsActive(pickupUnload) do
        WaitSeconds(1)
    end
    pickupPlatoon:Destroy()

    if ScenarioInfo.M1TechsPickedUp == 1 then
        ScenarioFramework.Dialogue(OpStrings.C02_M01_060)
        ForkThread(M1JanusFirstTechReturnHome, PickupPoint)
    elseif ScenarioInfo.M1TechsPickedUp == 2 then
        ScenarioFramework.Dialogue(OpStrings.C02_M01_090)
        ForkThread(M1JanusSecondTechReturnHome)
    else
        ForkThread(M2JanusReturnHome)
    end
end

function M1JanusFirstTechReturnHome(PickupPoint)

    ScenarioFramework.Dialogue(OpStrings.C02_M01_070)

    if ScenarioInfo.M1SETechFound == false then
    -- If the player's already found the temple to the SE, then these objectives are obsolete
    -- === M1P3. Search Surrounding Temples for More Tech ================== #
        if not ScenarioInfo.M1P3Given then
            ScenarioInfo.M1P3Given = true

            ScenarioFramework.Dialogue(ScenarioStrings.NewPObj)

            ScenarioFramework.CreateTimerTrigger(M1P3Reminder1, M1P3Reminder1Delay)
            ScenarioFramework.CreateTimerTrigger(M1P3Reminder2, M1P3Reminder2Delay)

            M1P3Assign()
        end
    end

    ScenarioInfo.M1CommArrayObjectiveGiven = true

    ScenarioInfo.JanusCrewIsActive = false

    local airPlatoon = nil
    local counter = 0

    -- Spawn the large air force to come attack the player
    counter = ScenarioInfo.VarTable['M1AeonTech1ResponseGroups']
    while counter > 0 do
        airPlatoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M1_Tech1_Response_Bombers', 'AttackChevron')
        RandomizeLocationsInPlatoon(airPlatoon, 10)
        airPlatoon.PlatoonData.Location = PickupPoint
        airPlatoon:ForkAIThread(PatrolAtLocation)

        if ArmyBrains[Player]:GetCurrentUnits(categories.AIR * categories.MOBILE) > 0 then
            airPlatoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M1_Tech1_Response_AirOnly', 'AttackChevron')
            RandomizeLocationsInPlatoon(airPlatoon, 10)
            airPlatoon.PlatoonData.Location = PickupPoint
            airPlatoon:ForkAIThread(PatrolAtLocation)
        end

        counter = counter - 1
    end

    WaitSeconds(5)
    ForkThread(M1SpawnFirstTechResponse, ScenarioInfo.M1DestinationIsNE)
end

function M1JanusSecondTechReturnHome()
    ScenarioInfo.JanusCrewIsActive = false

    ForkThread(M1SpawnSecondTechResponse)
end

function M1SpawnFirstTechResponse(DestinationIsNE)
    -- "[Units] swoop in from the east and attack the units in and around the village and temples",
    -- as well as the "large Aeon forces of air and land units (Transported in) which will begin coming in from the east and
    -- west to protect the temples."

    -- This happens when Janus has picked up the first piece of tech.
    if DestinationIsNE then
        ForkThread(M1SpawnTempleDefense, true)
    else
        ForkThread(M1SpawnTempleDefense, false)
    end
end

function M1SpawnTempleDefense(DestinationIsNE)
    -- "Large Aeon forces of air and land units (Transported in) which will begin coming in from the east and west to protect the temples."
    -- This happens when Janus is finished picking up the first piece of tech.

    ScenarioInfo.M1Temple1DefensePlatoon = ScenarioUtils.SpawnPlatoon('Aeon', AdjustForDifficulty('M1_Temple_Land_Defense'))
    ScenarioInfo.M1Temple2DefensePlatoon = ScenarioUtils.SpawnPlatoon('Aeon', AdjustForDifficulty('M1_Temple_Land_Defense'))
    ScenarioInfo.M1Temple3DefensePlatoon = ScenarioUtils.SpawnPlatoon('Aeon', AdjustForDifficulty('M1_Temple_Land_Defense'))

    if not ScenarioInfo.M1NETechFound then
    -- If the player has found tech at a temple, then don't send a force there
        ScenarioInfo.M1TempleNEDefensePlatoon = ScenarioUtils.SpawnPlatoon('Aeon', AdjustForDifficulty('M1_Temple_Land_Defense'))
        ForkThread(M1TempleDefense, ScenarioInfo.M1TempleNEDefensePlatoon, ScenarioUtils.MarkerToPosition('M1_NE_Village_LZ'), ScenarioUtils.MarkerToPosition('Temple3_TakeoffSpot'), ScenarioUtils.ChainToPositions('TempleNE_Route'))
    else
        ScenarioInfo.M1TempleDefenseSkippedNE = true
    end

    if not ScenarioInfo.M1SETechFound then
    -- If the player has found tech at a temple, then don't send a force there
        ScenarioInfo.M1TempleSEDefensePlatoon = ScenarioUtils.SpawnPlatoon('Aeon', AdjustForDifficulty('M1_Temple_Land_Defense'))
        ForkThread(M1TempleDefense, ScenarioInfo.M1TempleSEDefensePlatoon, ScenarioUtils.MarkerToPosition('M1_SE_Village_LZ'), ScenarioUtils.MarkerToPosition('Temple3_TakeoffSpot'), ScenarioUtils.ChainToPositions('TempleSE_Route'))
    else
        ScenarioInfo.M1TempleDefenseSkippedSE = true
    end

    ForkThread(M1TempleDefense, ScenarioInfo.M1Temple1DefensePlatoon, ScenarioUtils.MarkerToPosition('M1_NoTech_Village_1'), ScenarioUtils.MarkerToPosition('Temple1_TakeoffSpot'), ScenarioUtils.ChainToPositions('Temple1_Route'))
    ForkThread(M1TempleDefense, ScenarioInfo.M1Temple2DefensePlatoon, ScenarioUtils.MarkerToPosition('M1_NoTech_Village_2'), ScenarioUtils.MarkerToPosition('Temple2_TakeoffSpot'), ScenarioUtils.ChainToPositions('Temple2_Route'))
    ForkThread(M1TempleDefense, ScenarioInfo.M1Temple3DefensePlatoon, ScenarioUtils.MarkerToPosition('M1_NoTech_Village_3'), ScenarioUtils.MarkerToPosition('Temple3_TakeoffSpot'), ScenarioUtils.ChainToPositions('Temple3_Route'))

    -- Send a small air attack to the player base area, to warn them of attacks to come.
    ForkThread(M1_AdditionalAirResponseThread)
end

function M1_AdditionalAirResponseThread()
    -- Send some air to the player base area. 1 group, + 1 more per difficulty
    local airPlatoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M1_EarlyAirResponse', 'ChevronFormation')
    ScenarioFramework.PlatoonPatrolChain(airPlatoon, 'PlayerBase_Area_PatrolChain')
    WaitSeconds(1)
    for i = 1, ScenarioInfo.Difficulty do
        local airPlatoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M1_EarlyAirResponse', 'ChevronFormation')
        ScenarioFramework.PlatoonPatrolChain(airPlatoon, 'PlayerBase_Area_PatrolChain')
        WaitSeconds(1)
    end
end

function M1TempleDefense(DefPlatoon, UnloadSpot, OffScreenSpot, PatrolRoute)
    WaitSeconds(M1TempleDefenseDelayTime)

    local counter = 0
    local loc = OffScreenSpot
    local landUnits = DefPlatoon:GetSquadUnits('attack')
    local transport = DefPlatoon:GetSquadUnits('support')
    local airPlatoon = ScenarioUtils.SpawnPlatoon('Aeon', AdjustForDifficulty('M1_Temple_Air_Defense'))

    for counter, unit in DefPlatoon:GetPlatoonUnits() do
        Warp(unit, {loc[1] + (Random(-50,50) / 10), loc[2], loc[3] - (Random(-50,50) / 10)})
    end

    for counter, unit in airPlatoon:GetPlatoonUnits() do
        Warp(unit, {loc[1] + (Random(-50,50) / 10), loc[2], loc[3] - (Random(-50,50) / 10)})
    end

    airPlatoon:MoveToLocation(UnloadSpot, false)

    ScenarioFramework.AttachUnitsToTransports(landUnits, transport)
    DefPlatoon:UnloadAllAtLocation(UnloadSpot)

    ScenarioFramework.PlatoonPatrolRoute(DefPlatoon, PatrolRoute)
    ScenarioFramework.PlatoonPatrolRoute(airPlatoon, PatrolRoute)

    -- Now move the transports off-map and kill 'em
    DefPlatoon:MoveToLocation(OffScreenSpot, false, 'Support')
    DefPlatoon:Destroy('Support')
end

function M1SpawnSecondTechDefense()
    if not ScenarioInfo.M1_SecondTechDef_Spawned then
        ScenarioInfo.M1_SecondTechDef_Spawned = true
        -- Units should be spawned in that consist of "transported land units and accompanying air units, will arrive in two
        -- wings: one from the south and one from the east, converging on the tech location. These units will advance towards the
        -- player to attack and must be defeated before Janus will show up to get the tech.
        -- This happens when the player blows up the second temple.

        WaitSeconds(M1SecondTechDefenseDelayTime)

        -- Send a small transport force to the players base, as an indication of attacks to come.
        for i = 1, ScenarioInfo.Difficulty do
            local xportAttackers = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon' ,'M1_FirstTempResponse_Land', 'AttackFormation')
            local xportTransports = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon' ,'M1_FirstTempResponse_Trans', 'ChevronFormation')
            ForkThread(TransportLandAttack,xportTransports, xportAttackers, i)
        end

        if ScenarioInfo.M1P4Given == false then
        -- === M1P4. Defeat Aeon Defense Force ===================================== #
            if ScenarioInfo.M1DestinationIsNE then
                M1P4Assign('NE_Temple_Reinforce')
            else
                M1P4Assign('SE_Temple_Reinforce')
            end

            ScenarioFramework.Dialogue(OpStrings.C02_M01_080)

            ScenarioFramework.CreateTimerTrigger(M1P4Reminder1, M1P4Reminder1Delay)
            ScenarioFramework.CreateTimerTrigger(M1P4Reminder2, M1P4Reminder2Delay)

            ScenarioInfo.M1P4Given = true
        end

        local counter = ScenarioInfo.VarTable['M1AeonSecondTechDefenseGroups']
        local landGroup = nil
        local transportGroup = nil
        local secondTechDefensePlatoon = ArmyBrains[Aeon]:MakePlatoon('', '')
        local unloadSpot = nil
        local takeoffSpot = ScenarioFramework.GetRandomEntry(ScenarioUtils.ChainToPositions('M1_Aeon_Offscreen_Points'))
        local loc = takeoffSpot

        while counter > 0 do
            landGroup = ScenarioUtils.CreateArmyGroup('Aeon', AdjustForDifficulty('M1_Tech2_Defense_Land'))
            ScenarioFramework.CreateGroupDeathTrigger(M1SecondTechDefenseDeathCounter, landGroup)
            ScenarioInfo.M1SecondTechDefenseCount = ScenarioInfo.M1SecondTechDefenseCount + 1

            transportGroup = ScenarioUtils.CreateArmyGroup('Aeon', AdjustForDifficulty('M1_Tech2_Defense_Transports'))

            for secondCounter, unit in landGroup do
                Warp(unit, {loc[1], loc[2], loc[3]})
                ArmyBrains[Aeon]:AssignUnitsToPlatoon(secondTechDefensePlatoon, {unit}, 'Attack', 'ChevronFormation')
            end

            for thirdCounter, unit in transportGroup do
                Warp(unit, {loc[1] + (Random(-50,50) / 10), loc[2], loc[3] - (Random(-50,50) / 10)})
                ArmyBrains[Aeon]:AssignUnitsToPlatoon(secondTechDefensePlatoon, {unit}, 'Support', 'ChevronFormation')
            end

            local airGroup = ScenarioUtils.CreateArmyGroup('Aeon', AdjustForDifficulty('M1_Tech2_Defense_Air'))
            ScenarioFramework.CreateGroupDeathTrigger(M1SecondTechDefenseDeathCounter, airGroup)
            ScenarioInfo.M1SecondTechDefenseCount = ScenarioInfo.M1SecondTechDefenseCount + 1

            for counter, unit in airGroup do
                Warp(unit, {loc[1] + (Random(-50,50) / 10), loc[2], loc[3] - (Random(-50,50) / 10)})
                ArmyBrains[Aeon]:AssignUnitsToPlatoon(secondTechDefensePlatoon, {unit}, 'Scout', 'ChevronFormation')

                -- Sticking this IssueGuard here so the air units will stick by the rest of their platoon
                IssueGuard({unit}, landGroup[1])
            end

            if ScenarioInfo.M1DestinationIsNE then
                unloadSpot = ScenarioUtils.MarkerToPosition('M1_NE_Village_LZ')
            else
                unloadSpot = ScenarioUtils.MarkerToPosition('M1_SE_Village_LZ')
            end

            counter = counter - 1
        end

        ScenarioFramework.CreateTimerTrigger(M1SecondTechDefenseSafetyTimerUp, M1SecondTechDefenseSafetyTime)

        local landUnits  = secondTechDefensePlatoon:GetSquadUnits('Attack')
        local transports = secondTechDefensePlatoon:GetSquadUnits('Support')

        ScenarioFramework.AttachUnitsToTransports(landUnits, transports)
        local techUnloadCommand = secondTechDefensePlatoon:UnloadAllAtLocation(unloadSpot)
        secondTechDefensePlatoon:MoveToLocation(ScenarioUtils.MarkerToPosition('M1_Aeon_Offscreen_South'), false, 'Support')
        secondTechDefensePlatoon:Destroy('Support')

        -- Fork thread that will watch for when the unload command is complete, and then send the air onto a patrol
        ForkThread(SecondTechUnloadCheckThread, secondTechDefensePlatoon, techUnloadCommand)
    end
end

function SecondTechUnloadCheckThread(platoon, command)
    while platoon:IsCommandsActive(command) == true do
        WaitSeconds(1)
    end
    if ArmyBrains[Aeon]:PlatoonExists(platoon) then
        if ScenarioInfo.M1DestinationIsNE then
            for i = 1,3 do
                platoon:Patrol(ScenarioUtils.MarkerToPosition('SecondTechAirPatrol_N_'..i), 'Scout')
            end
        else
            for i = 1,3 do
                platoon:Patrol(ScenarioUtils.MarkerToPosition('SecondTechAirPatrol_S_'..i), 'Scout')
            end
        end
    end
end

function TransportLandAttack(transports, landPlat, count)
    ScenarioFramework.AttachUnitsToTransports(landPlat:GetPlatoonUnits(), transports:GetPlatoonUnits())
    local cmd = transports:UnloadAllAtLocation(ScenarioUtils.MarkerToPosition('M1_AeonIntialTransport_Landing_'..count))
    while ArmyBrains[Aeon]:PlatoonExists(transports) and transports:IsCommandsActive(cmd) do
        WaitSeconds(1)
    end
    if ArmyBrains[Aeon]:PlatoonExists(landPlat) then
        ScenarioFramework.PlatoonPatrolChain(landPlat, 'M1_PlayerArea_Chain')
    end
    if ArmyBrains[Aeon]:PlatoonExists(transports) then
        transports:MoveToLocation(ScenarioUtils.MarkerToPosition('M1_AeonInitialTrans_Return'), false)
        transports:Destroy()
    end
end

function M1SecondTechDefenseSafetyTimerUp()

    if not ScenarioInfo.SecondTechDefenseGroupDestroyed then
        if ScenarioInfo.M1DestinationIsNE then
            ScenarioFramework.CreateAreaTrigger(M1JanusPicksUpSecondTechAtNE, ScenarioUtils.AreaToRect('NE_Temple_Safe_Zone'), categories.ALLUNITS, true, true, ArmyBrains[Aeon], 1, false)
        else
            ScenarioFramework.CreateAreaTrigger(M1JanusPicksUpSecondTechAtSE, ScenarioUtils.AreaToRect('SE_Temple_Safe_Zone'), categories.ALLUNITS, true, true, ArmyBrains[Aeon], 1, false)
        end
    end
end

function M1SecondTechDefenseDeathCounter()
    ScenarioInfo.M1SecondTechDefenseCount = ScenarioInfo.M1SecondTechDefenseCount - 1

    if ScenarioInfo.M1SecondTechDefenseCount < 1 then
        -- LOG("debug: all t3 defense destroyed")

        ScenarioInfo.SecondTechDefenseGroupDestroyed = true

        if ScenarioInfo.M1DestinationIsNE then
            M1JanusPicksUpSecondTechAtNE()
        else
            M1JanusPicksUpSecondTechAtSE()
        end
    end
end

function M1JanusPicksUpSecondTechAtNE()
    -- Now that the player has taken out the "Aeon Defense Force" that defends the second piece of tech, let's bring in our special guest.

    -- MAtt 12/01/06
    -- crappy bandaid, more risky to unwind
    if ScenarioInfo.M1SecondTechPickupStarted then
        return
    else
        ScenarioInfo.M1SecondTechPickupStarted = true
    end

    if ScenarioInfo.M1P4Given == false then
        -- If not, then we should "silently" activate and complete the objective.
    -- === M1P4. Defeat Aeon Defense Force ===================================== #
        ScenarioInfo.M1P4 = Objectives.Basic(
            'primary', 'incomplete', OpStrings.M1P4Title, OpStrings.M1P4Description,
            Objectives.GetActionIcon('kill'),
            {
                ShowFaction = 'Aeon',
                -- Units = {},
                -- MarkUnits = true,
            }
        )
        ScenarioInfo.M1P4Given = true

        ScenarioFramework.CreateTimerTrigger(M1P4Reminder1, M1P4Reminder1Delay)
        ScenarioFramework.CreateTimerTrigger(M1P4Reminder2, M1P4Reminder2Delay)

        ScenarioFramework.Dialogue(OpStrings.C02_M01_080)
    end

    ScenarioInfo.M1P4:ManualResult(true)

    ScenarioFramework.Dialogue(ScenarioStrings.PObjComp)

    ScenarioFramework.CreateAreaTrigger(M1JanusClearedForTakeoffToNE, ScenarioUtils.AreaToRect('NE_Temple_Safe_Zone'), categories.ALLUNITS, true, true, ArmyBrains[Aeon], 1, false)
end

function M1JanusPicksUpSecondTechAtSE()
    -- MAtt 12/01/06
    -- crappy bandaid, more risky to unwind
    if ScenarioInfo.M1SecondTechPickupStarted then
        return
    else
        ScenarioInfo.M1SecondTechPickupStarted = true
    end

    -- Now that the player has taken out the "Aeon Defense Force" that defends the second piece of tech, let's bring in our special guest.
    ScenarioInfo.M1P4Complete = true

    ScenarioInfo.M1P4:ManualResult(true)
    ScenarioFramework.Dialogue(ScenarioStrings.PObjComp)

    ScenarioFramework.CreateAreaTrigger(M1JanusClearedForTakeoffToSE, ScenarioUtils.AreaToRect('SE_Temple_Safe_Zone'), categories.ALLUNITS, true, true, ArmyBrains[Aeon], 1, false)
end

function M1SpawnSecondTechResponse()
    -- The doc says that this should be "a [Aeon] large naval force with air cover at the player. A good-sized naval force will come from the south
    -- (from the naval base down there) along with Interceptor cover and some Bombers." M1 ends when these guys are defeated.

    -- This happens when Janus picks up the second piece of tech.

    -- === M1P5. Defeat Aeon Assault =========================================== #
    ScenarioInfo.M1P5 = Objectives.Basic(
        'primary', 'incomplete', OpStrings.M1P5Title, OpStrings.M1P5Description,
        Objectives.GetActionIcon('protect'),
        {
            Area = 'M1_Defend_Area',
            ShowFaction = 'Aeon',
            -- MarkUnits = true,
        }
    )
    ScenarioFramework.Dialogue(ScenarioStrings.NewPObj)
    ScenarioFramework.Dialogue(OpStrings.C02_M01_100)

    WaitSeconds(M1FinalAssaultDelayTime)

    local remainderPlatoon = ArmyBrains[Aeon]:MakePlatoon('', '')
    local aeonRemainingUnits = ArmyBrains[Aeon]:GetListOfUnits(categories.MOBILE, false)

    for counter, unit in aeonRemainingUnits do
        IssueClearCommands({unit})
        ArmyBrains[Aeon]:AssignUnitsToPlatoon(remainderPlatoon, {unit}, 'Attack', 'TravellingFormation')
    end

    ScenarioFramework.CreatePlatoonDeathTrigger(M1FinalAssaultRemainderCounter, remainderPlatoon)
    remainderPlatoon.PlatoonData.Location = ScenarioUtils.MarkerToPosition('Initial_Player_Pos')
    remainderPlatoon:ForkAIThread(PatrolAtLocation)

    local navalCounter = ScenarioInfo.VarTable['M1AeonFinalAssaultNavalGroups']
    local airCounter = ScenarioInfo.VarTable['M1AeonFinalAssaultAirGroups']
    local position = nil

    while navalCounter > 0 do
        local navalPlatoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M1_Final_Assault_Naval', 'TravellingFormation')
        ScenarioFramework.CreatePlatoonDeathTrigger(M1FinalAssaultNavalDeathCounter, navalPlatoon)

        for teleportCounter, unit in navalPlatoon:GetPlatoonUnits() do
            position = unit:GetPosition()
            -- Move these guys apart a little bit
            Warp(unit, {position[1] + (navalCounter * 2), position[2], position[3]})
        end

        navalPlatoon.PlatoonData.Location = ScenarioUtils.MarkerToPosition('M1_FinalAssault_NavalPoint')
        navalPlatoon:ForkAIThread(ScenarioPlatoonAI.PlatoonAttackLocation)

        navalCounter = navalCounter - 1
    end

    local airCounter = ScenarioInfo.VarTable['M1AeonFinalAssaultAirGroups']

    while airCounter > 0 do
        local airPlatoon = MakeGroupsIntoPlatoon(ArmyBrains[Aeon], 'M1_Final_Assault_Bombers', 'M1_Final_Assault_Interceptors')

        ScenarioFramework.CreatePlatoonDeathTrigger(M1FinalAssaultAirDeathCounter, airPlatoon)
        RandomizeLocationsInPlatoon(airPlatoon, 10)

        airPlatoon.PlatoonData.Location = ScenarioFramework.GetRandomEntry(ScenarioUtils.ChainToPositions('M1_Aeon_AirAttack_Attackpoints'))
        airPlatoon:ForkAIThread(PatrolAtLocation)

        airCounter = airCounter - 1
    end

    ScenarioFramework.CreateTimerTrigger(M1Complete, M1FinalAssaultSafetyTime)
end

function M1FinalAssaultRemainderCounter(deadPlatoon)
    ScenarioInfo.M1RemainderDead = true

    if(ScenarioInfo.VarTable['M1AeonFinalAssaultNavalGroups'] < 1) and
     (ScenarioInfo.VarTable['M1AeonFinalAssaultAirGroups'] < 1) and
      ScenarioInfo.M1RemainderDead == true then
        ForkThread(M1Complete)
    end
end

function M1FinalAssaultNavalDeathCounter(deadPlatoon)
    ScenarioInfo.VarTable['M1AeonFinalAssaultNavalGroups'] = ScenarioInfo.VarTable['M1AeonFinalAssaultNavalGroups'] - 1

    if(ScenarioInfo.VarTable['M1AeonFinalAssaultNavalGroups'] < 1) and
     (ScenarioInfo.VarTable['M1AeonFinalAssaultAirGroups'] < 1) and
      ScenarioInfo.M1RemainderDead == true then
        ForkThread(M1Complete)
    end
end

function M1FinalAssaultAirDeathCounter(deadPlatoon)
    ScenarioInfo.VarTable['M1AeonFinalAssaultAirGroups'] = ScenarioInfo.VarTable['M1AeonFinalAssaultAirGroups'] - 1

    if(ScenarioInfo.VarTable['M1AeonFinalAssaultNavalGroups'] < 1) and
     (ScenarioInfo.VarTable['M1AeonFinalAssaultAirGroups'] < 1) and
      ScenarioInfo.M1RemainderDead == true then
        ForkThread(M1Complete)
    end
end

----------------------------------------------------------------------------- #
-- === M1 REMINDERS ========================================================== #
----------------------------------------------------------------------------- #
function M1P1Reminder1()
    if not ScenarioInfo.M1P1Complete and ScenarioInfo.MissionNumber == 1 then
        ScenarioFramework.Dialogue(OpStrings.C02_M01_210)
        ScenarioFramework.CreateTimerTrigger(M1P1Reminder2, M1P1Reminder2Delay)
    end
end

function M1P1Reminder2()
    if not ScenarioInfo.M1P1Complete and ScenarioInfo.MissionNumber == 1 then
        ScenarioFramework.Dialogue(OpStrings.C02_M01_215)
        ScenarioFramework.CreateTimerTrigger(M1P1Reminder3, M1P1Reminder2Delay)
    end
end

function M1P1Reminder3()
    if not ScenarioInfo.M1P1Complete and ScenarioInfo.MissionNumber == 1 then
        ScenarioFramework.Dialogue(ScenarioStrings.CybranGenericReminder)
        ScenarioFramework.CreateTimerTrigger(M1P1Reminder1, M1P1Reminder2Delay)
    end
end

    ---

function M1P2Reminder1()
    if not ScenarioInfo.M1P2Complete and ScenarioInfo.MissionNumber == 1 then
        ScenarioFramework.Dialogue(OpStrings.C02_M01_200)
        ScenarioFramework.CreateTimerTrigger(M1P2Reminder2, M1P2Reminder2Delay)
    end
end

function M1P2Reminder2()
    if not ScenarioInfo.M1P2Complete and ScenarioInfo.MissionNumber == 1 then
        ScenarioFramework.Dialogue(OpStrings.C02_M01_205)
        ScenarioFramework.CreateTimerTrigger(M1P2Reminder3, M1P2Reminder2Delay)
    end
end

function M1P2Reminder3()
    if not ScenarioInfo.M1P2Complete and ScenarioInfo.MissionNumber == 1 then
        ScenarioFramework.Dialogue(ScenarioStrings.CybranGenericReminder)
        ScenarioFramework.CreateTimerTrigger(M1P2Reminder1, M1P2Reminder2Delay)
    end
end

    ---

function M1P3Reminder1()
    if not ScenarioInfo.M1P3Complete and ScenarioInfo.MissionNumber == 1 then
        ScenarioFramework.Dialogue(OpStrings.C02_M01_220)
        ScenarioFramework.CreateTimerTrigger(M1P3Reminder2, M1P3Reminder2Delay)
    end
end

function M1P3Reminder2()
    if not ScenarioInfo.M1P3Complete and ScenarioInfo.MissionNumber == 1 then
        ScenarioFramework.Dialogue(OpStrings.C02_M01_225)
        ScenarioFramework.CreateTimerTrigger(M1P3Reminder3, M1P3Reminder2Delay)
    end
end

function M1P3Reminder2()
    if not ScenarioInfo.M1P3Complete and ScenarioInfo.MissionNumber == 1 then
        ScenarioFramework.Dialogue(ScenarioStrings.CybranGenericReminder)
        ScenarioFramework.CreateTimerTrigger(M1P3Reminder1, M1P3Reminder2Delay)
    end
end

    ---

function M1P4Reminder1()
    if not ScenarioInfo.M1P4Complete and ScenarioInfo.MissionNumber == 1 then
        ScenarioFramework.Dialogue(OpStrings.C02_M01_230)
        ScenarioFramework.CreateTimerTrigger(M1P4Reminder2, M1P4Reminder2Delay)
    end
end

function M1P4Reminder2()
    if not ScenarioInfo.M1P4Complete and ScenarioInfo.MissionNumber == 1 then
        ScenarioFramework.Dialogue(OpStrings.C02_M01_235)
        ScenarioFramework.CreateTimerTrigger(M1P4Reminder3, M1P4Reminder2Delay)
    end
end

function M1P4Reminder2()
    if not ScenarioInfo.M1P4Complete and ScenarioInfo.MissionNumber == 1 then
        ScenarioFramework.Dialogue(ScenarioStrings.CybranGenericReminder)
        ScenarioFramework.CreateTimerTrigger(M1P4Reminder1, M1P4Reminder2Delay)
    end
end

----------------------------------------------------------------------------- #
-- === MISSION 1 COMPLETE ==================================================== #
----------------------------------------------------------------------------- #
function M1Complete()


    if not ScenarioInfo.M1CompleteTriggerFired then
    -- Adding safety in case we run into the "unit gets stuck off-map" issue again  -GKR 7/30

        ScenarioInfo.M1CompleteTriggerFired = true
        WaitSeconds(M1CompleteDelayTime)
        ScenarioInfo.M1P5:ManualResult(true)
        ScenarioFramework.Dialogue(ScenarioStrings.PObjComp)
        ScenarioFramework.Dialogue(ScenarioStrings.MissionSuccessDialogue)
        ScenarioFramework.Dialogue(OpStrings.C02_M01_120)

        WaitSeconds(M1ToM2Delay)

        StartMission2()
    end
end

----------------------------------------------------------------------------- #
-- === MISSION 2 ============================================================= #
----------------------------------------------------------------------------- #
function StartMission2()
    ScenarioFramework.Dialogue(OpStrings.C02_M02_010)
    ScenarioFramework.SetPlayableArea('M2_Playable_Area')

    for _, player in ScenarioInfo.HumanPlayers do
        SetArmyUnitCap(player, 400)
    end
    SetArmyUnitCap(2, 500)
    SetArmyUnitCap(3, 500)

    ScenarioInfo.MissionNumber = 2

    ScenarioInfo.M2Temple = ScenarioUtils.CreateArmyUnit('Civilian', 'E_Temple')
    local otherTemple = ScenarioUtils.CreateArmyUnit('Civilian', 'S_Temple')

    ForkThread(M2AeonPatrols)
    ForkThread(M2AeonScouting)
    ForkThread(M2OffscreenLaunchAttack)

    M2LaunchLandAssault()
    M2LaunchNavalAssault()
    M2CreateUnits()
    M2SetupTriggers()
    M2GiveTech()

    -- === M2P1. Defeat Eastern Aeon Base and Recover Its Tech ================================ #
    -- ScenarioFramework.AddObjective('primary', 'incomplete', OpStrings.M2P1Title, OpStrings.M2P1Description, Objectives.GetActionIcon('kill'))
    ScenarioInfo.M2P1 = Objectives.Basic(
        'primary', 'incomplete', OpStrings.M2P1Title, OpStrings.M2P1Description,
        Objectives.GetActionIcon('kill'),
        {
            ShowFaction = 'Aeon',
            Area = 'M2_Aeon_Land_Base_Area',
            -- MarkUnits = true,
        }
    )
    ScenarioFramework.Dialogue(ScenarioStrings.NewPObj)

    -- === M2P2. Defeat Southern Aeon Base  =================================================== #
    ScenarioInfo.M2P2 = Objectives.Basic(
        'primary', 'incomplete', OpStrings.M2P2Title, OpStrings.M2P2Description,
        Objectives.GetActionIcon('kill'),
        {
            ShowFaction = 'Aeon',
            Area = 'M2_Aeon_Naval_Base_Area',
            -- MarkUnits = true,
        }
    )
    ScenarioFramework.Dialogue(ScenarioStrings.NewPObj)
end

function M2CreateUnits()
    local aeonNavalEngineers = ScenarioUtils.CreateArmyGroup('Aeon', AdjustForDifficulty('M2_Naval_Base_Engineers'))
    local aeonNavalBuildings = ScenarioUtils.CreateArmyGroup('Aeon', 'M2_Naval_Base')
    local aeonNavalWalls = ScenarioUtils.CreateArmyGroup('Aeon', 'M2_Naval_Base_Walls')
    ScenarioUtils.CreateArmyGroup('Aeon', AdjustForDifficulty('M2_Naval_Base_Defense'))


    local aeonLandEngineers = ScenarioUtils.CreateArmyGroup('Aeon', AdjustForDifficulty('M2_Land_Base_Engineers'))
    local aeonLandBuildings = ScenarioUtils.CreateArmyGroup('Aeon', 'M2_Land_Base')
    local aeonLandWalls = ScenarioUtils.CreateArmyGroup('Aeon', 'M2_Land_Base_Walls')
end

function M2SetupTriggers()
    -- Blow up the temple at the eastern base that contains tech
    ScenarioFramework.CreateUnitDeathTrigger(M2TempleDestroyed, ScenarioInfo.M2Temple)

    -- Aeon commander says things after 4 minutes, 8 minutes, and 16 minutes
    ScenarioFramework.CreateTimerTrigger(M2AeonFirstVO, M2AeonFirstVODelay)
    ScenarioFramework.CreateTimerTrigger(M2AeonSecondVO, M2AeonSecondVODelay)
    ScenarioFramework.CreateTimerTrigger(M2AeonThirdVO, M2AeonThirdVODelay)

    -- Aeon send in a naval force from the top right corner of the map every once in a while
    -- Start it after a certain time...
    ScenarioFramework.CreateTimerTrigger(M2AeonOffscreenNavalAssaultPrepare, M2AeonOffscreenNavalAssaultDelay)
    -- ...or start it when the player has two frigates near the Aeon Naval base.
    ScenarioFramework.CreateAreaTrigger(M2AeonOffscreenNavalAssaultPrepare, ScenarioUtils.AreaToRect('M2_Aeon_Naval_Base_Rear_Area'), categories.urs0103, true, false, ArmyBrains[Player], 2, false)

    ScenarioFramework.CreateAreaTrigger(M2AeonNavalBaseDestroyed, ScenarioUtils.AreaToRect('M2_Aeon_Naval_Base_Area'), categories.ALLUNITS - M2JanusDoesntNeedTheseGone, true, true, ArmyBrains[Aeon], 1, false)

    -- Reminders
    ScenarioFramework.CreateTimerTrigger(M2P1Reminder1, M2P1Reminder1Delay)
end

function M2AeonFirstVO()
    if not ScenarioInfo.M3AeonCDRDead then
        ScenarioFramework.Dialogue(OpStrings.C02_M02_050)

        -- Dont allow taunts for a few minutes
        ScenarioInfo.TauntsAllowed = false
        ScenarioFramework.CreateTimerTrigger(ReAllowTaunts, 180)
    end
end

function M2AeonSecondVO()
    if not ScenarioInfo.M3AeonCDRDead then
        ScenarioFramework.Dialogue(OpStrings.C02_M02_060)

        -- Dont allow taunts for a few minutes
        ScenarioInfo.TauntsAllowed = false
        ScenarioFramework.CreateTimerTrigger(ReAllowTaunts, 180)
    end
end

function M2AeonThirdVO()
    if not ScenarioInfo.M3AeonCDRDead then
        ScenarioFramework.Dialogue(OpStrings.C02_M02_070)

        -- Dont allow taunts for a few minutes
        ScenarioInfo.TauntsAllowed = false
        ScenarioFramework.CreateTimerTrigger(ReAllowTaunts, 180)
    end
end

function M2AeonOffscreenNavalAssaultPrepare()
    if not ScenarioInfo.M2AeonOffscreenNavalAssaultFired then
        ScenarioInfo.M2AeonOffscreenNavalAssaultFired = true
        ForkThread(M2AeonOffscreenNavalAssault)
    end
end

function M2AeonOffscreenNavalAssault()
    -- As these appear from within a later playable area, make sure this only runs during mission 2
    if ScenarioInfo.MissionNumber == 2 then
        local navalPlatoon = nil
        local navalPlatoonCounter = ScenarioInfo.VarTable['M2AeonOffscreenNavalPlatoonsAllowed']

        while navalPlatoonCounter > 0 do
            navalPlatoonCounter = navalPlatoonCounter - 1
            navalPlatoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M2_Offscreen_Naval', 'TravellingFormation')
            navalPlatoon.PlatoonData.Location = ScenarioUtils.MarkerToPosition('Initial_Player_Pos')
            navalPlatoon:ForkAIThread(ScenarioPlatoonAI.PlatoonAttackLocation)
            WaitSeconds(10)
        end
    end
end

function M2GiveTech()
    -- T2 Engineer
    -- T2 Anti-Air and Point Defense
    ScenarioFramework.RemoveRestrictionForAllHumans(M2CybranLandTechAllowance + M2CybranBuildingTechAllowance)
    ScenarioFramework.RemoveRestriction(CybranJanus, M2CybranLandTechAllowance + M2CybranBuildingTechAllowance)
    ScenarioFramework.RemoveRestriction(Aeon, M2AeonLandTechAllowance + M2AeonBuildingTechAllowance)

end

function M2AeonPatrols()
    local mobileAAPlatoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', AdjustForDifficulty('M2_Naval_Base_Mobile_AA'), 'TravellingFormation')
    ScenarioFramework.PlatoonPatrolRoute(mobileAAPlatoon, ScenarioUtils.ChainToPositions('M2_Aeon_Naval_Base_MobileAA_Route'))

    local frigateGroup = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', AdjustForDifficulty('M2_Naval_Base_Frigates'), 'NoFormation')
    local laBoatGroup = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', AdjustForDifficulty('M2_Naval_Base_LABoats'), 'NoFormation')
    ScenarioFramework.PlatoonPatrolChain(frigateGroup, 'M2_Aeon_Frigate_Patrol')
    ScenarioFramework.PlatoonPatrolChain(laBoatGroup, 'M2_Aeon_Frigate_Patrol')
end

function M2AeonScouting()
    WaitSeconds(M2AeonScoutDelay)

    local aeonScouts = ScenarioUtils.SpawnPlatoon('Aeon', 'M2_Offscreen_Scouts')
    RandomizeLocationsInPlatoon(aeonScouts, 5)

    ScenarioFramework.PlatoonPatrolRoute(aeonScouts, ScenarioUtils.ChainToPositions('M2_Aeon_Air_Patrol'))
end

function M2OffscreenPlatoonDeathCounter()
    ScenarioInfo.M2OffscreenPlatoonsKilled = ScenarioInfo.M2OffscreenPlatoonsKilled + 1
    ScenarioInfo.M2OffscreenPlatoonsAlive = ScenarioInfo.M2OffscreenPlatoonsAlive - 1

    ScenarioFramework.CreateTimerTrigger(M2OffscreenPrepareForAttack, M2AeonOffscreenAttackRepeatDelay)
end

function M2OffscreenPrepareForAttack()
    -- Only do this if Janus hasn't been called in to pick up the second tech
    if not ScenarioInfo.M2OffscreenAttacksPaused then
        -- Make this not as fancy for safety's sake
        -- if ScenarioInfo.M2OffscreenPlatoonsAlive < M2MaximumOffscreenPlatoonsAlive then
        if ScenarioInfo.M2OffscreenPlatoonsAlive == 0 then
            if ScenarioInfo.M2OffscreenPlatoonsKilled > M2AeonAttacksBecomeLarge then
                ScenarioInfo.M2AeonAttackSize = 3
            elseif ScenarioInfo.M2OffscreenPlatoonsKilled > M2AeonAttacksBecomeMedium then
                ScenarioInfo.M2AeonAttackSize = 2
            else
                ScenarioInfo.M2AeonAttackSize = 1
            end

            ForkThread(M2OffscreenLaunchAttack)
        end
    end
end

function M2OffscreenLaunchAttack()
    if not ScenarioInfo.OffscreenAttacksAlreadyStarted then
        WaitSeconds(M2AeonOffscreenAttackDelay)
    end

    ScenarioInfo.OffscreenAttacksAlreadyStarted = true

    local bombers = nil
    local interceptors = nil

    if ScenarioInfo.M2AeonAttackSize == 1 then
        ScenarioInfo.M2OffscreenLandPlatoon = ScenarioUtils.SpawnPlatoon('Aeon', AdjustForDifficulty('M2_Offscreen_Small_Land'))
        ScenarioInfo.M2OffscreenPlatoonsAlive = ScenarioInfo.M2OffscreenPlatoonsAlive + 1
        ScenarioInfo.M2OffscreenAirPlatoon = MakeGroupsIntoPlatoon(ArmyBrains[Aeon], AdjustForDifficulty('M2_Offscreen_Small_Bombers'), AdjustForDifficulty('M2_Offscreen_Small_Interceptors'))
        ScenarioInfo.M2OffscreenPlatoonsAlive = ScenarioInfo.M2OffscreenPlatoonsAlive + 1

    elseif ScenarioInfo.M2AeonAttackSize == 2 then
        ScenarioInfo.M2OffscreenLandPlatoon = ScenarioUtils.SpawnPlatoon('Aeon', AdjustForDifficulty('M2_Offscreen_Medium_Land'))
        ScenarioInfo.M2OffscreenPlatoonsAlive = ScenarioInfo.M2OffscreenPlatoonsAlive + 1
        ScenarioInfo.M2OffscreenAirPlatoon = MakeGroupsIntoPlatoon(ArmyBrains[Aeon], AdjustForDifficulty('M2_Offscreen_Medium_Bombers'), AdjustForDifficulty('M2_Offscreen_Medium_Interceptors'))

        ScenarioInfo.M2OffscreenPlatoonsAlive = ScenarioInfo.M2OffscreenPlatoonsAlive + 1
    else
        ScenarioInfo.M2OffscreenLandPlatoon = ScenarioUtils.SpawnPlatoon('Aeon', AdjustForDifficulty('M2_Offscreen_Large_Land'))
        ScenarioInfo.M2OffscreenPlatoonsAlive = ScenarioInfo.M2OffscreenPlatoonsAlive + 1
        ScenarioInfo.M2OffscreenAirPlatoon = MakeGroupsIntoPlatoon(ArmyBrains[Aeon], AdjustForDifficulty('M2_Offscreen_Large_Bombers'), AdjustForDifficulty('M2_Offscreen_Large_Interceptors'))
        ScenarioInfo.M2OffscreenPlatoonsAlive = ScenarioInfo.M2OffscreenPlatoonsAlive + 1
    end

    ScenarioInfo.M2OffscreenTransports = ScenarioUtils.SpawnPlatoon('Aeon', 'M2_Offscreen_Transports')

    local landUnits = ScenarioInfo.M2OffscreenLandPlatoon:GetSquadUnits('attack')
    local transports = ScenarioInfo.M2OffscreenTransports:GetSquadUnits('support')

    ScenarioInfo.M2OffscreenTakeoffSpot = ScenarioFramework.GetRandomEntry(ScenarioUtils.ChainToPositions('Offscreen_Launch_Points'))
    local loc = ScenarioInfo.M2OffscreenTakeoffSpot

    for counter, unit in ScenarioInfo.M2OffscreenAirPlatoon:GetPlatoonUnits() do
        -- Throwing in a little randomness here so these guys don't stack on top of each other
        Warp(unit, {loc[1] + (Random(-50,50) / 10), loc[2], loc[3] - (Random(-50,50) / 10)})
    end

    for counter, unit in ScenarioInfo.M2OffscreenLandPlatoon:GetPlatoonUnits() do
        Warp(unit, {loc[1], loc[2], loc[3]})
    end

    for counter, unit in ScenarioInfo.M2OffscreenTransports:GetPlatoonUnits() do
        -- Throwing in a little randomness here so these guys don't stack on top of each other
        Warp(unit, {loc[1] + (Random(-50,50) / 10), loc[2], loc[3] - (Random(-50,50) / 10)})
    end

    ScenarioFramework.AttachUnitsToTransports(landUnits, transports)

    local attackGrid = nil

    if ScenarioInfo.MissionNumber == 2 then
        attackGrid = ScenarioUtils.ChainToPositions('M2_Attack_Grid')
    else
        attackGrid = ScenarioUtils.ChainToPositions('M3_Attack_Grid')
    end

    ScenarioInfo.M2OffscreenLandPlatoon.PlatoonData.Location = ScenarioFramework.DetermineBestAttackLocation(ArmyBrains[Aeon], ArmyBrains[Player], 'enemy', attackGrid, 64)
    ScenarioInfo.M2OffscreenAirPlatoon.PlatoonData.Location = ScenarioInfo.M2OffscreenLandPlatoon.PlatoonData.Location

    -- ScenarioFramework.CreateTimerTrigger(M2OffscreenPrepareForAttack, M2AeonOffscreenAttackRepeatDelay) #Doesnt actually do anything
    ScenarioFramework.CreatePlatoonDeathTrigger(M2OffscreenPlatoonDeathCounter, ScenarioInfo.M2OffscreenLandPlatoon)
    ScenarioFramework.CreatePlatoonDeathTrigger(M2OffscreenPlatoonDeathCounter, ScenarioInfo.M2OffscreenAirPlatoon)

    ScenarioInfo.M2OffscreenTransports:UnloadAllAtLocation(ScenarioInfo.M2OffscreenLandPlatoon.PlatoonData.Location)

    ScenarioInfo.M2OffscreenAirPlatoon:ForkAIThread(PatrolAtLocation)
    ScenarioInfo.M2OffscreenLandPlatoon:ForkAIThread(ScenarioPlatoonAI.PlatoonAttackLocation)

    ScenarioInfo.M2OffscreenTransports:MoveToLocation(ScenarioInfo.M2OffscreenTakeoffSpot, false, 'Support')
    ScenarioInfo.M2OffscreenTransports:Destroy('Support')
end

function M2LaunchLandAssault()
    ScenarioInfo.VarTable['M2LandAssaultReady'] = true
end

function M2LandAssaultRepeatDelay()
    local repeattime = M2LandAssaultAttackTime
    return repeattime
end

function M2LaunchNavalAssault()
    ScenarioInfo.VarTable['M2NavalAssaultReady'] = true
end

function M2NavalAssaultRepeatDelay()
    local repeattime = M2NavalAssaultAttackTime
    return repeattime
end

function M2TechTranslation(unit)
    ScenarioInfo.M2Tech = unit
end

function M2TempleDestroyed()
    ScenarioInfo.M2Tech = ScenarioUtils.CreateArmyUnit('Civilian', 'E_Tech')
    ScenarioInfo.M2Tech:SetCustomName(LOC '<LOC opc2002_desc>Seraphim Tech')

    -- Make the tech impervious to everything
    ScenarioInfo.M2Tech:SetCanTakeDamage(false)
    ScenarioInfo.M2Tech:SetCanBeKilled(false)
    ScenarioInfo.M2Tech:SetReclaimable(false)
    ScenarioInfo.M2Tech:SetCapturable(false)

    -- reveal M2 tech cam
    ForkThread(TechRevealedNISCamera, ScenarioInfo.M2Tech)

    ScenarioFramework.CreateUnitCapturedTrigger(nil, M2TechTranslation, ScenarioInfo.M2Tech)

    ScenarioFramework.CreateAreaTrigger(M2JanusClearedForTakeoff, ScenarioUtils.AreaToRect('M2_Aeon_Land_Base_Area'), categories.ALLUNITS - M2JanusDoesntNeedTheseGone, true, true, ArmyBrains[Aeon], 1, false)

    ScenarioFramework.Dialogue(OpStrings.C02_M02_020)

    ScenarioInfo.M2P3 = Objectives.Basic(
        'primary', 'incomplete', OpStrings.M2P3Title, OpStrings.M2P3Description,
        Objectives.GetActionIcon('protect'),
        {
            Units = {ScenarioInfo.M2Tech},
            MarkUnits = true,
        }
    )
end

function M2AeonNavalBaseDestroyed()
    ScenarioInfo.M2P2:ManualResult(true)
    ScenarioFramework.Dialogue(ScenarioStrings.PObjComp)
    ScenarioFramework.Dialogue(OpStrings.C02_M02_040)

-- NIS for destruction of naval base
    local camInfo = {
        blendTime = 1.0,
        holdTime = 4,
        orientationOffset = { 2.5, 0.2, 0 },
        positionOffset = { 0, 1, 0 },
        zoomVal = 30,
        markerCam = true,
        }
    ScenarioFramework.OperationNISCamera(ScenarioUtils.MarkerToPosition("M2_Naval_Factory"), camInfo)

    if Objectives.IsComplete(ScenarioInfo.M2P1) and Objectives.IsComplete(ScenarioInfo.M2P2) then
        ForkThread(M2Complete)
    end
end

function M2JanusClearedForTakeoff()
    ScenarioInfo.M2OffscreenAttacksPaused = true
    ForkThread(M1JanusTechPickupStart, ScenarioUtils.MarkerToPosition('M2_Janus_LZ'), ScenarioUtils.MarkerToPosition('M2_Tech_Spot'), ScenarioInfo.M2Tech, M2JanusPickupDelayTime)
end

function M2JanusReturnHome()
    ScenarioInfo.M2P1:ManualResult(true)
    ScenarioInfo.M2P1Complete = true
    if Objectives.IsComplete(ScenarioInfo.M2P1) and Objectives.IsComplete(ScenarioInfo.M2P2) then
        ForkThread(M2Complete)
    end
end

----------------------------------------------------------------------------- #
-- === M2 REMINDERS ========================================================== #
----------------------------------------------------------------------------- #
function M2P1Reminder1()
    if not ScenarioInfo.M2P1Complete and ScenarioInfo.MissionNumber == 2 then
        ScenarioFramework.Dialogue(OpStrings.C02_M02_150)
        ScenarioFramework.CreateTimerTrigger(M2P1Reminder2, M2P1Reminder2Delay)
    end
end

function M2P1Reminder2()
    if not ScenarioInfo.M2P3 and ScenarioInfo.MissionNumber == 2 then
        ScenarioFramework.Dialogue(OpStrings.C02_M02_155)
        ScenarioFramework.CreateTimerTrigger(M2P1Reminder2, M2P1Reminder2Delay)
    end
end

function M2P1Reminder3()
    if not ScenarioInfo.M2P1Complete and ScenarioInfo.MissionNumber == 2 then
        ScenarioFramework.Dialogue(ScenarioStrings.CybranGenericReminder)
        ScenarioFramework.CreateTimerTrigger(M2P1Reminder1, M2P1Reminder2Delay)
    end
end

----------------------------------------------------------------------------- #
-- === MISSION 2 COMPLETE ==================================================== #
----------------------------------------------------------------------------- #
function M2Complete()
    if not Mission3Begun then
        Mission3Begun = true
        ScenarioInfo.JanusEnergyCheat:Destroy()
        ScenarioFramework.Dialogue(OpStrings.C02_M02_080,StartMission3)
        ScenarioFramework.Dialogue(ScenarioStrings.MissionSuccessDialogue)
    end
end

----------------------------------------------------------------------------- #
-- === MISSION 3 ============================================================= #
----------------------------------------------------------------------------- #
function StartMission3()
    for _, player in ScenarioInfo.HumanPlayers do
        SetArmyUnitCap(player, 500)
    end
    SetArmyUnitCap(2, 500)
    SetArmyUnitCap(3, 500)

    ScenarioFramework.Dialogue(OpStrings.C02_M03_010)
    ScenarioFramework.SetPlayableArea('M3_Playable_Area')

    ScenarioInfo.MissionNumber = 3

    for _, player in ScenarioInfo.HumanPlayers do
        SetAlliance(player, CybranJanus, 'Enemy')
        SetAlliance(CybranJanus, player, 'Enemy')
    end
    SetAlliance(Aeon, CybranJanus, 'Enemy')
    SetAlliance(CybranJanus, Aeon, 'Enemy')

    -- Re-enable the Aeon offscreen attacks from M2 that were paused when Janus came to pick up the tech
    ScenarioInfo.M2OffscreenAttacksPaused = false

    M3CreateUnits()
    M3SetupTriggers()
    M3GiveTech()
    M3JanusAttack()
    ForkThread(M3JanusScouting)
    ForkThread(M3AeonScouting)
end

function M3CreateUnits()
    ScenarioUtils.CreateArmyGroup('Aeon', 'M3_Aeon_Base')

    ScenarioInfo.M3JanusCDR = ScenarioUtils.CreateArmyUnit('CybranJanus', 'M3_Janus_Commander')
    ScenarioInfo.M3JanusCDR:SetCustomName(LOC '{i CDR_Mach}')
    ScenarioFramework.CreateUnitDeathTrigger(M3_CybranCDRDestroyed, ScenarioInfo.M3JanusCDR) -- For death nis

    ScenarioInfo.AeonCDR = ScenarioUtils.CreateArmyUnit('Aeon', 'M3_Aeon_Commander')
    ScenarioInfo.AeonCDR:SetCustomName(LOC '{i CDR_Ariel}')
    ScenarioFramework.CreateUnitDeathTrigger(M3_AeonCDRDestroyed, ScenarioInfo.AeonCDR) -- For death nis

    ScenarioInfo.M3Gate = ScenarioUtils.CreateArmyUnit('FakeAeon', 'M3_Gate')
    ScenarioInfo.M3Gate:SetCanTakeDamage(false)
    ScenarioInfo.M3Gate:SetCanBeKilled(false)
    ScenarioInfo.M3Gate:SetCapturable(false)
    ScenarioInfo.M3Gate:SetReclaimable(false)

    ScenarioInfo.M3Techs = ScenarioUtils.CreateArmyGroup('FakeJanus', 'M3_Janus_Tech')
    for counter, unit in ScenarioInfo.M3Techs do
        unit:SetCanTakeDamage(false)
        unit:SetCanBeKilled(false)
        unit:SetCapturable(false)
        unit:SetReclaimable(false)
    end

    ScenarioUtils.CreateArmyGroup('Aeon', AdjustForDifficulty('M3_Aeon_Base_Engineers'))
    ScenarioUtils.CreateArmyGroup('Aeon', 'M3_Aeon_Base_Walls')

    ScenarioUtils.CreateArmyGroup('CybranJanus', AdjustForDifficulty('M3_Janus_Engineers'))
    ScenarioUtils.CreateArmyGroup('CybranJanus', 'M3_Janus_Base')
    ScenarioUtils.CreateArmyGroup('CybranJanus', 'M3_Janus_Base_Walls')

    ScenarioUtils.CreateArmyGroup('CybranJanus', 'M3_Janus_NorthDefense_Walls')
    ScenarioUtils.CreateArmyGroup('CybranJanus', 'M3_Janus_Other_Walls')
    ScenarioUtils.CreateArmyGroup('CybranJanus', 'M3_Janus_Economy_Zone')

    local leftDefenses = ScenarioUtils.CreateArmyGroupAsPlatoon('CybranJanus', 'M3_Janus_NorthDefense_Left_Defenses', 'TravellingFormation')

    for counter, unit in leftDefenses:GetPlatoonUnits() do
        ScenarioInfo.M3JanusNorthDefensesCount = ScenarioInfo.M3JanusNorthDefensesCount + 1
        ScenarioFramework.CreateUnitDeathTrigger(M3JanusNorthDefensesCheck, unit)
    end

    local leftEngineer = ScenarioUtils.CreateArmyGroupAsPlatoon('CybranJanus', 'M3_Janus_NorthDefense_Left_Engineer', 'AttackFormation')
    leftEngineer.PlatoonData.MaintainBaseTemplate = 'M3_Janus_NorthDefense_Left_Defenses'
    leftEngineer:ForkAIThread(ScenarioPlatoonAI.StartBaseEngineerThread)

    local centerDefenses = ScenarioUtils.CreateArmyGroupAsPlatoon('CybranJanus', 'M3_Janus_NorthDefense_Center_Defenses', 'TravellingFormation')

    for counter, unit in centerDefenses:GetPlatoonUnits() do
        ScenarioInfo.M3JanusNorthDefensesCount = ScenarioInfo.M3JanusNorthDefensesCount + 1
        ScenarioFramework.CreateUnitDeathTrigger(M3JanusNorthDefensesCheck, unit)
    end

    local centerEngineer = ScenarioUtils.CreateArmyGroupAsPlatoon('CybranJanus', 'M3_Janus_NorthDefense_Center_Engineer', 'AttackFormation')
    centerEngineer.PlatoonData.MaintainBaseTemplate = 'M3_Janus_NorthDefense_Center_Defenses'
    centerEngineer:ForkAIThread(ScenarioPlatoonAI.StartBaseEngineerThread)

    local rightDefenses = ScenarioUtils.CreateArmyGroupAsPlatoon('CybranJanus', 'M3_Janus_NorthDefense_Right_Defenses', 'TravellingFormation')

    for counter, unit in rightDefenses:GetPlatoonUnits() do
        ScenarioInfo.M3JanusNorthDefensesCount = ScenarioInfo.M3JanusNorthDefensesCount + 1
        ScenarioFramework.CreateUnitDeathTrigger(M3JanusNorthDefensesCheck, unit)
    end

    local rightEngineer = ScenarioUtils.CreateArmyGroupAsPlatoon('CybranJanus', 'M3_Janus_NorthDefense_Right_Engineer', 'AttackFormation')
    rightEngineer.PlatoonData.MaintainBaseTemplate = 'M3_Janus_NorthDefense_Right_Defenses'
    rightEngineer:ForkAIThread(ScenarioPlatoonAI.StartBaseEngineerThread)

    local economyEngineers = ScenarioUtils.CreateArmyGroupAsPlatoon('CybranJanus', AdjustForDifficulty('M3_Janus_Economy_Engineers'), 'AttackFormation')
    economyEngineers.PlatoonData.MaintainBaseTemplate = 'M3_Janus_Economy_Zone'
    economyEngineers:ForkAIThread(ScenarioPlatoonAI.StartBaseEngineerThread)
end

function M3JanusScouting()
    local janusScouts = nil
    local counter = 0

    while counter < 5 do
        if not ScenarioInfo.JanusDead then
            WaitSeconds(Random(M3ScoutDelayTime / 2, M3ScoutDelayTime))
            janusScouts = ScenarioUtils.CreateArmyGroupAsPlatoon('CybranJanus', 'M3_Janus_Scouts', 'ChevronFormation')
            janusScouts.PlatoonData.PatrolChain = 'M3_Janus_Attack_Points'
            janusScouts:ForkAIThread(ScenarioPlatoonAI.RandomPatrolThread)
        end
        counter = counter + 1
    end

    while counter < 20 do
        if not ScenarioInfo.JanusDead then
            WaitSeconds(Random(M3ScoutDelayTime / 2, M3ScoutDelayTime) + Random(120, 240))
            aeonScouts = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M3_Aeon_Scouts', 'ChevronFormation')
            aeonScouts.PlatoonData.PatrolChain = 'M3_Aeon_Attack_Points'
            aeonScouts:ForkAIThread(ScenarioPlatoonAI.RandomPatrolThread)
        end
        counter = counter + 1
    end
end

function M3AeonScouting()
    local aeonScouts = nil
    local counter = 0

    while counter < 4 do
        if not ScenarioInfo.AeonCDRDead then
            WaitSeconds(Random(M3ScoutDelayTime / 2, M3ScoutDelayTime))
            aeonScouts = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M3_Aeon_Scouts', 'ChevronFormation')
            aeonScouts.PlatoonData.PatrolChain = 'M3_Aeon_Attack_Points'
            aeonScouts:ForkAIThread(ScenarioPlatoonAI.RandomPatrolThread)
        end
        counter = counter + 1
    end

    while counter < 20 do
        if not ScenarioInfo.AeonCDRDead then
            WaitSeconds(Random(M3ScoutDelayTime / 2, M3ScoutDelayTime) + Random(120, 240))
            aeonScouts = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M3_Aeon_Scouts', 'ChevronFormation')
            aeonScouts.PlatoonData.PatrolChain = 'M3_Aeon_Attack_Points'
            aeonScouts:ForkAIThread(ScenarioPlatoonAI.RandomPatrolThread)
        end
        counter = counter + 1
    end
end

function M3SetupTriggers()
    -- === M3P1. Defeat Janus ================================================================= #
    ScenarioInfo.M3P1 = Objectives.Kill(
        'primary',
        'incomplete',
        OpStrings.M3P1Title,
        OpStrings.M3P1Description,
        { Units = { ScenarioInfo.M3JanusCDR } }
   )
    ScenarioInfo.M3P1:AddResultCallback(M3P1Complete)

    -- === M3S1. Defeat the Aeon Commander  =================================================== #
    ScenarioInfo.M3S1 = Objectives.Kill(
        'secondary',
        'incomplete',
        OpStrings.M3S1Title,
        OpStrings.M3S1Description,
        { Units = { ScenarioInfo.AeonCDR } }
   )
    ScenarioInfo.M3S1:AddResultCallback(M3S1Complete)

    -- Reminders
    ScenarioFramework.CreateTimerTrigger(M3P1Reminder1, M3P1Reminder1Delay)
end

function M3GiveTech()
    -- T2 Land Factory can build the Mobile Missile Launcher
    ScenarioFramework.RemoveRestrictionForAllHumans(M3CybranLandTechAllowance)
    ScenarioFramework.RemoveRestriction(CybranJanus, M3CybranLandTechAllowance)
    ScenarioFramework.RemoveRestriction(Aeon, M3AeonLandTechAllowance)

    -- print('Factories can now build the Mobile Missile Launcher!')
end

function M3JanusNorthDefensesCheck()
    -- When a certain percentage of Janus's northern defenses has been killed, send in the Aeon Commander
    if not ScenarioInfo.M3AeonCDRDead then
        if not ScenarioInfo.M3AeonCommanderAssaultTime then
            ScenarioInfo.M3JanusNorthDefensesKilled = ScenarioInfo.M3JanusNorthDefensesKilled + 1
            -- LOG('GKR DEBUG: ' .. ScenarioInfo.M3JanusNorthDefensesKilled .. ' out of ' .. ScenarioInfo.M3JanusNorthDefensesCount .. ' defenses killed!')

            if ScenarioInfo.M3JanusNorthDefensesKilled >=(M3NorthDefensesPercentage * ScenarioInfo.M3JanusNorthDefensesCount) then
                -- Get 'em, boys... er... girl!
                ScenarioInfo.M3AeonCommanderAssaultTime = true
                ForkThread(M3AeonCDRAttacksJanus)
            end
        end
    end
end

function M3JanusAttack()
    ScenarioInfo.VarTable['M3JanusAttackReady'] = true
end

function M3JanusAttackRepeatDelay()
    local repeattime = M3JanusAttackTime
    return repeattime
end

function M3AeonAttack()
    ScenarioInfo.VarTable['M3AeonAttackReady'] = true
end

function M3AeonAttackRepeatDelay()
    local repeattime = M3AeonAttackTime
    return repeattime
end

function M3P1Complete()
    ScenarioFramework.Dialogue(ScenarioStrings.PObjComp)
    ScenarioFramework.CreateUnitNearTypeTrigger(M3PlayerReachedGate, ScenarioInfo.M3Gate, ArmyBrains[Player], categories.url0001, 2)
    ScenarioFramework.KillBaseInArea(ArmyBrains[CybranJanus], 'Mach_BaseDestroy_Area')
    ScenarioInfo.JanusDead = true

    -- === M3P2. Move Your Commander to the Gate ============================================== #
    ScenarioInfo.M3P2 = Objectives.Basic(
        'primary', 'incomplete', OpStrings.M3P2Title, OpStrings.M3P2Description,
        Objectives.GetActionIcon('move'),
        {
            Units = {ScenarioInfo.M3Gate},
            MarkUnits = true,
            AlwaysVisible = true,
        }
    )
    ScenarioFramework.Dialogue(ScenarioStrings.NewPObj)
    ScenarioFramework.Dialogue(OpStrings.C02_M03_030)

    ScenarioFramework.CreateTimerTrigger(M3P2Reminder1, M3P2Reminder1Delay)
    ScenarioFramework.CreateTimerTrigger(M3P2Reminder2, M3P2Reminder2Delay)
end

function M3S1Complete()
    ScenarioInfo.M3AeonCDRDead = true
    ScenarioFramework.Dialogue(ScenarioStrings.SObjComp)
    ScenarioFramework.Dialogue(OpStrings.C02_M03_020)
end

function M3_AeonCDRDestroyed(unit)
    -- Aeon Commander destroyed, NIS (secondary)
    ScenarioFramework.CDRDeathNISCamera(unit, 7)
end

function M3_CybranCDRDestroyed(unit)
    -- Cybran Commander destroyed, NIS (primary)
    ScenarioFramework.CDRDeathNISCamera(unit, 7)
end

function M3PlayerReachedGate()
    ScenarioInfo.M3P2:ManualResult(true)
    ScenarioFramework.Dialogue(ScenarioStrings.PObjComp)

    -- Reached Qgate cam
-- ScenarioFramework.EndOperationCamera(ScenarioInfo.PlayerCDR, false)
    ScenarioFramework.CDRDeathNISCamera(ScenarioInfo.PlayerCDR)

    ScenarioFramework.FakeTeleportUnit(ScenarioInfo.PlayerCDR,true)

    for k,unit in ScenarioInfo.M3Techs do
        ScenarioFramework.FakeTeleportUnit(unit,true)
    end

    ForkThread(M3Complete)
end

function M3AeonCDRAttacksJanus()
    local aeonCDRUnits = GetUnitsInRect(ScenarioUtils.AreaToRect('M3_EastCoast_Area'))
    local aeonAirUnits = ArmyBrains[Aeon]:GetListOfUnits(categories.AIR + categories.MOBILE, false)
    local aeonUnitsExcluded = categories.ENGINEER + categories.SCOUT + categories.TRANSPORTATION + categories.ual0001
    local janusCDRPosition
    if not ScenarioInfo.M3JanusCDR:IsDead() then
        janusCDRPosition = ScenarioInfo.M3JanusCDR:GetPosition()
    else
        janusCDRPosition = ScenarioUtils.MarkerToPosition('Aeon_Alternate_AttackPoint')
    end

    ScenarioInfo.M3AeonCDRPlatoon = ArmyBrains[Aeon]:MakePlatoon('', '')

    IssueClearCommands({ScenarioInfo.AeonCDR})
-- IssuePatrol({ScenarioInfo.AeonCDR}, janusCDRPosition)
-- ArmyBrains[Aeon]:AssignUnitsToPlatoon(ScenarioInfo.M3AeonCDRPlatoon, {ScenarioInfo.AeonCDR}, 'Attack', 'TravellingFormation')

    local aeonCDRMoves = IssueMove({ScenarioInfo.AeonCDR}, ScenarioUtils.MarkerToPosition('M3_Aeon_CDR_Destination'))
    ForkThread(M3AeonCDRArrivesAtBase, aeonCDRMoves, janusCDRPosition)

    for counter, unit in aeonCDRUnits do
        if(unit:GetAIBrain() == ArmyBrains[Aeon]) then
            if EntityCategoryContains(categories.MOBILE, unit) and not EntityCategoryContains(aeonUnitsExcluded, unit) then
                IssueClearCommands({unit})
                ArmyBrains[Aeon]:AssignUnitsToPlatoon(ScenarioInfo.M3AeonCDRPlatoon, {unit}, 'Attack', 'TravellingFormation')
            end
        end
    end

    for secondCounter, unit in aeonAirUnits do
        if not EntityCategoryContains(aeonUnitsExcluded, unit) then
            IssueClearCommands({unit})
            ArmyBrains[Aeon]:AssignUnitsToPlatoon(ScenarioInfo.M3AeonCDRPlatoon, {unit}, 'Attack', 'TravellingFormation')
        end
    end

    ScenarioInfo.M3AeonCDRPlatoon.PlatoonData.Location = janusCDRPosition
    ScenarioInfo.M3AeonCDRPlatoon:ForkAIThread(PatrolAtLocation)
end

function M3AeonCDRArrivesAtBase(MoveCommand, JanusPosition)
    while(not IsCommandDone(MoveCommand)) do
        WaitSeconds(1)
    end

    IssuePatrol({ScenarioInfo.AeonCDR}, JanusPosition)
end

----------------------------------------------------------------------------- #
-- === M3 REMINDERS ========================================================== #
----------------------------------------------------------------------------- #
function M3P1Reminder1()
    if not ScenarioInfo.JanusDead then
        ScenarioFramework.Dialogue(OpStrings.C02_M03_050)
        ScenarioFramework.CreateTimerTrigger(M3P1Reminder2, M3P1Reminder2Delay)
    end
end

function M3P1Reminder2()
    if not ScenarioInfo.JanusDead then
        ScenarioFramework.Dialogue(OpStrings.C02_M03_055)
        ScenarioFramework.CreateTimerTrigger(M3P1Reminder3, M3P1Reminder2Delay)
    end
end

function M3P1Reminder3()
    if not ScenarioInfo.JanusDead then
        ScenarioFramework.Dialogue(ScenarioStrings.CybranGenericReminder)
        ScenarioFramework.CreateTimerTrigger(M3P1Reminder1, M3P1Reminder2Delay)
    end
end

    ---

function M3P2Reminder1()
    ScenarioFramework.Dialogue(OpStrings.C02_M03_060)
    ScenarioFramework.CreateTimerTrigger(M3P2Reminder2, M3P2Reminder2Delay)
end

function M3P2Reminder2()
    ScenarioFramework.Dialogue(OpStrings.C02_M03_065)
    ScenarioFramework.CreateTimerTrigger(M3P2Reminder3, M3P2Reminder2Delay)
end

function M3P2Reminder3()
    ScenarioFramework.Dialogue(ScenarioStrings.CybranGenericReminder)
    ScenarioFramework.CreateTimerTrigger(M3P2Reminder1, M3P2Reminder2Delay)
end

----------------------------------------------------------------------------- #
-- === MISSION 3 COMPLETE ==================================================== #
----------------------------------------------------------------------------- #
function M3Complete()
    if not ScenarioInfo.OperationEnding then
        ScenarioInfo.OperationEnding = true
        ScenarioFramework.EndOperationSafety()
        WaitSeconds(M3FinishedDelay)
        ScenarioFramework.Dialogue(ScenarioStrings.OperationSuccessDialogue, WinGame, true)
    end
end

function PlayerCDRKilled(unit)
    if not ScenarioInfo.OperationEnding then
        ScenarioInfo.OperationEnding = true
        PlayerLose(OpStrings.C02_D02_010)
--    ScenarioFramework.EndOperationCamera(unit, false)
        ScenarioFramework.CDRDeathNISCamera(unit)
    end
end

function PlayerLose(dialogueTable)
    ScenarioFramework.FlushDialogueQueue()
    ScenarioFramework.EndOperationSafety()
    if (dialogueTable) then
        ScenarioFramework.Dialogue(dialogueTable, LoseGame, true)
    else
        ForkThread(LoseGame)
    end
end

function WinGame()
    WaitSeconds(5)
    ScenarioInfo.OpComplete = true
    local secondaries = Objectives.IsComplete(ScenarioInfo.M3S1)
    ScenarioFramework.EndOperation(ScenarioInfo.OpComplete, ScenarioInfo.OpComplete, secondaries)
end

function LoseGame()
    WaitSeconds(5)
    ScenarioInfo.OpComplete = false
    ScenarioFramework.EndOperation(ScenarioInfo.OpComplete, ScenarioInfo.OpComplete, false)
end

function TechRevealedNISCamera(unit)
    local camInfo = {
        blendTime = 1.0,
        holdTime = 4,
        orientationOffset = { math.pi, 0.2, 0 },
        positionOffset = { 0, 0.5, 0 },
        zoomVal = 20,
    }
    ScenarioFramework.OperationNISCamera(unit, camInfo)
end

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
