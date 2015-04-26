-- ****************************************************************************
-- **
-- **  File     :  /maps/SCCA_Coop_A06_v03/SCCA_Coop_A06_v03_script.lua
-- **  Author(s):  David Tomandl
-- **
-- **  Summary  :  This is the main file in control of the events during
-- **              operation A6.
-- **
-- **  Copyright © 2006 Gas Powered Games, Inc.  All rights reserved.
-- ****************************************************************************

local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local Objectives = ScenarioFramework.Objectives
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local AIBuildStructures = import('/lua/ai/AIBuildStructures.lua')
local Cinematics = import('/lua/cinematics.lua')
local ScenarioStrings = import('/lua/ScenarioStrings.lua')
local OpStrings = import ('/maps/SCCA_Coop_A06_v03/SCCA_Coop_A06_v03_strings.lua')
local Weather = import('/lua/weather.lua')

-- -----------------------
-- Misc Global Definitions
-- -----------------------
ScenarioInfo.MissionNumber = 1

ScenarioInfo.Player = 1
ScenarioInfo.UEF = 2
ScenarioInfo.Cybran = 3
ScenarioInfo.Aeon = 4
ScenarioInfo.Neutral = 5
ScenarioInfo.Coop1 = 6
ScenarioInfo.Coop2 = 7
ScenarioInfo.Coop3 = 8
ScenarioInfo.HumanPlayers = {ScenarioInfo.Player}
ScenarioInfo.VarTable = {}
ScenarioInfo.M1CityBuildingsAlive = 0
ScenarioInfo.M1CityBuildingsTotal = 0
ScenarioInfo.M1P1Complete = false
ScenarioInfo.M1P2Complete = false
ScenarioInfo.Mission2ObjectiveGroup = nil


-- ----------------------
-- Misc Local Definitions
-- ----------------------
local MissionTexture = '/textures/ui/common/missions/mission.dds'

local Difficulty = ScenarioInfo.Options.Difficulty or 2

local Difficulty1_Suffix = '_D1'
local Difficulty2_Suffix = '_D2'
local Difficulty3_Suffix = '_D3'

local Player = ScenarioInfo.Player
local Coop1 = ScenarioInfo.Coop1
local Coop2 = ScenarioInfo.Coop2
local Coop3 = ScenarioInfo.Coop3
local UEF = ScenarioInfo.UEF
local Cybran = ScenarioInfo.Cybran
local Aeon = ScenarioInfo.Aeon
local Neutral = ScenarioInfo.Neutral

local TauntTableRed = {
    OpStrings.TAUNT1,
    OpStrings.TAUNT2,
    OpStrings.TAUNT3,
    OpStrings.TAUNT4,
    OpStrings.TAUNT5,
    OpStrings.TAUNT6,
    OpStrings.TAUNT7,
    OpStrings.TAUNT8,
}

local TauntTableMarxon = {
    OpStrings.TAUNT9,
    OpStrings.TAUNT10,
    OpStrings.TAUNT11,
    OpStrings.TAUNT12,
    OpStrings.TAUNT13,
    OpStrings.TAUNT14,
    OpStrings.TAUNT15,
    OpStrings.TAUNT16,
}

local TauntTableAiko = {
    OpStrings.TAUNT17,
    OpStrings.TAUNT18,
    OpStrings.TAUNT19,
    OpStrings.TAUNT20,
    OpStrings.TAUNT21,
    OpStrings.TAUNT22,
    OpStrings.TAUNT23,
    OpStrings.TAUNT24,
}

-- ---------------
-- Debug Variables
-- ---------------

-- ----------------------
-- Local Tuning Variables
-- ----------------------

-- What should the player's army unit cap be in each mission?
local M1ArmyCap = 300
local M2ArmyCap = 400
local M3ArmyCap = 500

-- How many units need to be killed for bonus objective #1?
-- local M1B1KillAmount = 300 # more than this number

-- The computer's unit cap
local CybranUnitCap = 1000
local AeonUnitCap = 1000
local UEFUnitCap = 1000
local NeutralUnitCap = 1000

if Difficulty == 1 then
    ScenarioInfo.VarTable['M2EngineerCount'] = 8
    ScenarioInfo.VarTable['M2SpiderbotEngineerCount'] = 1
    ScenarioInfo.VarTable['M3EngineerMaintenanceCount'] = 6
    ScenarioInfo.VarTable['M3EngineerAssistCount'] = 6
elseif Difficulty == 2 then
    ScenarioInfo.VarTable['M2EngineerCount'] = 15
    ScenarioInfo.VarTable['M2SpiderbotEngineerCount'] = 2
    ScenarioInfo.VarTable['M3EngineerMaintenanceCount'] = 9
    ScenarioInfo.VarTable['M3EngineerAssistCount'] = 9
else
    ScenarioInfo.VarTable['M2EngineerCount'] = 25
    ScenarioInfo.VarTable['M2SpiderbotEngineerCount'] = 3
    ScenarioInfo.VarTable['M3EngineerMaintenanceCount'] = 12
    ScenarioInfo.VarTable['M3EngineerAssistCount'] = 12
end

-- When 3 values are given for a variable, they
-- apply to Easy, Medium, Hard difficulty in that order

-- Mission 1

-- When the first attack will get launched
local M1ScoutDelay = { 120, 60, 30 }

local M1ReoccurringLightAttackInitialDelay = { 300, 180, 60 }
local M1ReoccurringLightAttackDelay = { 240, 120, 80 }

local M1ReoccurringMediumAttackInitialDelay = { 600, 420, 300 }
local M1ReoccurringMediumAttackDelay = { 600, 480, 300 }

-- After each light and medium attack that comes from the UEF
-- one will come from the Cybran.  How long should the Cybran
-- wait before launching their attack?
local M1CybranDelay = { 30, 30, 30 }

local M1ReoccurringHeavyAttackInitialDelay = { 900, 540, 420 }
local M1ReoccurringHeavyAttackDelay = { 600, 480, 360 }

-- How long after being defeated will these platoons be reinforced
local M1AirDefenseRespawnTimer = { 300, 180, 120 }
local M1GroundDefenseRespawnTimer = { 300, 180, 120 }

-- How many groups of attackers should we spawn per wave
local M1NumberOfAttackerSpawns = { 1, 2, 3 }
local M1GroundDefenseGroups = { 1, 1, 2 }
local M1AirDefenseGroups = { 1, 1, 2 }

local M1GroundRespawnDelay = { 900, 480, 180 }
local M1AirRespawnDelay = { 900, 480, 180 }

-- Dialog delays, all following each other
local M1DialogDelay1 = 300
local M1DialogDelay2 = 180
local M1DialogDelay3 = 180
local M1DialogDelay4 = 180
local M1DialogDelay5 = 180
local M1DialogDelay6 = 180

local M1ScoutPlayerDelay = { 300, 300, 180 }

-- How long to delay the reminders initially and how much thereafter
local M1P1InitialReminderDelay = 900
local M1P1ReoccuringReminderDelay = 600

-- Mission 2

-- How many units should be created?
-- Preattack = they will go with the attack
-- Postattack = they will patrol the base after the attack is launched

local PreAttackM2SpiderCount = { 3, 4, 5 }
local PreAttackM2SiegebotCount = { 2, 4, 6 }
local PreAttackM2FlakCount = { 1, 2, 4 }
local PreAttackM2BomberCount = { 1, 2, 4 }
local PreAttackM2FighterCount = { 1, 2, 4 }
local PreAttackM2ArtilleryCount = { 1, 2, 4 }
local PreAttackM2TankCount = { 1, 2, 4 }

ScenarioInfo.VarTable['M2SpiderCount'] = PreAttackM2SpiderCount[ Difficulty ]
ScenarioInfo.VarTable['M2SiegebotCount'] = PreAttackM2SiegebotCount[ Difficulty ]
ScenarioInfo.VarTable['M2FlakCount'] = PreAttackM2FlakCount[ Difficulty ]
ScenarioInfo.VarTable['M2BomberCount'] = PreAttackM2BomberCount[ Difficulty ]
ScenarioInfo.VarTable['M2FighterCount'] = PreAttackM2FighterCount[ Difficulty ]
ScenarioInfo.VarTable['M2ArtilleryCount'] = PreAttackM2ArtilleryCount[ Difficulty ]
ScenarioInfo.VarTable['M2TankCount'] = PreAttackM2TankCount[ Difficulty ]

local PostAttackM2SpiderCount = { 0, 1, 2 }
local PostAttackM2SiegebotCount = { 1, 2, 3 }
local PostAttackM2FlakCount = { 1, 1, 2 }
local PostAttackM2BomberCount = { 1, 1, 2 }
local PostAttackM2FighterCount = { 1, 1, 2 }
local PostAttackM2ArtilleryCount = { 1, 1, 2 }
local PostAttackM2TankCount = { 1, 1, 2 }

-- The Cybran base has several shields.  They will upgrade
-- based on these percentages.  These numbers are successive
-- "slices" of 100.  So when the first number is 30, it's a 30%
-- chance.  When the next number is 50, it's a 20% chance.  Etc.

-- Note: there are no M2D1 variables because they will all stay
-- level 1 on difficulty 1

local M2D2ShieldLevel1Threshold = 20
local M2D2ShieldLevel2Threshold = 70
local M2D2ShieldLevel3Threshold = 100
local M2D2ShieldLevel4Threshold = -1 -- not applicable

local M2D3ShieldLevel1Threshold = -1 -- not applicable
local M2D3ShieldLevel2Threshold = 20
local M2D3ShieldLevel3Threshold = 70
local M2D3ShieldLevel4Threshold = 100


-- The various dialog delays, all following each other
local M2DialogDelay1 = 180
local M2DialogDelay2 = 120
local M2DialogDelay3 = 120
local M2DialogDelay4 = 60
local M2DialogDelay5 = 180
local M2DialogDelay6 = 240

local M2OffscreenCommanderDialogDelay1 = 30
local M2OffscreenCommanderDialogDelay2 = 90
local M2OffscreenCommanderDialogDelay3 = 60
local M2OffscreenCommanderDialogDelay4 = 30

-- This is another chain of delays for dialog and actions
-- local M2PreAttack1Delay = 600
-- local M2PreAttack2Delay = 120
-- We're trying starting the attack much sooner
local M2AttackDelay = 30 -- 60

-- How long to delay the reminders initially and how much thereafter
local M2P2InitialReminderDelay = 900
local M2P2ReoccuringReminderDelay = 600

-- Mission 3

-- The various dialog delays, all following each other
local M3DialogDelay1 = 360
local M3DialogDelay2 = 120
local M3DialogDelay3 = 120
local M3DialogDelay4 = 180
local M3DialogDelay5 = 120

-- How long to delay the reminders initially and how much thereafter
local M3P1InitialReminderDelay = 1200
local M3P1ReoccuringReminderDelay = 900

-- ##### Starter Functions ######
function OnPopulate(scenario)
    -- Initial Unit Creation
    ScenarioUtils.InitializeScenarioArmies()
    ScenarioFramework.fillCoop()

    factionIdx = GetArmyBrain('Player'):GetFactionIndex()
    if(factionIdx == 1) then
        Faction = "uef"
    elseif(factionIdx == 2) then
        Faction = "aeon"
    else 
        Faction = "cybran"
    end
    -- Weather.CreateWeather()
end

function OnStart(self)

    -- Hide scores for non-player armies
    for i = 2, table.getn(ArmyBrains) do
        if i < ScenarioInfo.Coop1 then
            SetArmyShowScore(i, false)
            SetIgnorePlayableRect(i, true)
        end
    end

    -- Add in the base locations for the PBM
    ArmyBrains[UEF]:PBMAddBuildLocation(ScenarioUtils.MarkerToPosition('M1_Offense_Location'), 40, 'M1_Offense_Location')
    ArmyBrains[UEF]:PBMAddBuildLocation(ScenarioUtils.MarkerToPosition('M1_UEF_Water_Attacks'), 60, 'M1_UEF_Water_Attacks')
    ArmyBrains[Cybran]:PBMAddBuildLocation(ScenarioUtils.MarkerToPosition('M1_Cybran_Offense_Spawn'), 75, 'M1_Cybran_Offense_Spawn')
    ArmyBrains[Cybran]:PBMAddBuildLocation(ScenarioUtils.MarkerToPosition('M2_Cybran_Base'), 100, 'M2_Cybran_Base')
    ArmyBrains[Aeon]:PBMAddBuildLocation(ScenarioUtils.MarkerToPosition('M3_Aeon_Base'), 300, 'M3_Aeon_Base')
    ArmyBrains[Aeon]:PBMAddBuildLocation(ScenarioUtils.MarkerToPosition('Experimental_Island'), 50, 'Experimental_Island')

    -- Define the bases for the different difficulties
    if not ArmyBrains[Cybran].BaseTemplates then
        ArmyBrains[Cybran].BaseTemplates = {}
    end
    if not ArmyBrains[Aeon].BaseTemplates then
        ArmyBrains[Aeon].BaseTemplates = {}
    end
    ArmyBrains[Cybran].BaseTemplates['M2_Base'] = { Template = {}, List = {} }
    ArmyBrains[Cybran].BaseTemplates['M2_Spiderbots'] = { Template = {}, List = {} }
    ArmyBrains[Aeon].BaseTemplates['M3_Base'] = { Template = {}, List = {} }

    if Difficulty == 1 then
        AIBuildStructures.AppendBuildingTemplate(ArmyBrains[Cybran], 'Cybran', 'M2_Base_D1', 'M2_Base')
        AIBuildStructures.AppendBuildingTemplate(ArmyBrains[Cybran], 'Cybran', 'M2_Walls_D1', 'M2_Base')
        AIBuildStructures.AppendBuildingTemplate(ArmyBrains[Cybran], 'Cybran', 'M2_Spiderbots_D1', 'M2_Spiderbots')
        AIBuildStructures.AppendBuildingTemplate(ArmyBrains[Aeon], 'Aeon', 'M3_Base_Defenses_D1', 'M3_Base')
        AIBuildStructures.AppendBuildingTemplate(ArmyBrains[Aeon], 'Aeon', 'M3_Base_Economy_D1', 'M3_Base')
        AIBuildStructures.AppendBuildingTemplate(ArmyBrains[Aeon], 'Aeon', 'M3_Base_Factories_D1', 'M3_Base')
    elseif Difficulty == 2 then
        AIBuildStructures.AppendBuildingTemplate(ArmyBrains[Cybran], 'Cybran', 'M2_Base_D2', 'M2_Base')
        AIBuildStructures.AppendBuildingTemplate(ArmyBrains[Cybran], 'Cybran', 'M2_Walls_D2', 'M2_Base')
        AIBuildStructures.AppendBuildingTemplate(ArmyBrains[Cybran], 'Cybran', 'M2_Spiderbots_D2', 'M2_Spiderbots')
        AIBuildStructures.AppendBuildingTemplate(ArmyBrains[Aeon], 'Aeon', 'M3_Base_Defenses_D2', 'M3_Base')
        AIBuildStructures.AppendBuildingTemplate(ArmyBrains[Aeon], 'Aeon', 'M3_Base_Economy_D2', 'M3_Base')
        AIBuildStructures.AppendBuildingTemplate(ArmyBrains[Aeon], 'Aeon', 'M3_Base_Factories_D2', 'M3_Base')
    else
        AIBuildStructures.AppendBuildingTemplate(ArmyBrains[Cybran], 'Cybran', 'M2_Base_D3', 'M2_Base')
        AIBuildStructures.AppendBuildingTemplate(ArmyBrains[Cybran], 'Cybran', 'M2_Walls_D3', 'M2_Base')
        AIBuildStructures.AppendBuildingTemplate(ArmyBrains[Cybran], 'Cybran', 'M2_Spiderbots_D3', 'M2_Spiderbots')
        AIBuildStructures.AppendBuildingTemplate(ArmyBrains[Aeon], 'Aeon', 'M3_Base_Defenses_D3', 'M3_Base')
        AIBuildStructures.AppendBuildingTemplate(ArmyBrains[Aeon], 'Aeon', 'M3_Base_Economy_D3', 'M3_Base')
        AIBuildStructures.AppendBuildingTemplate(ArmyBrains[Aeon], 'Aeon', 'M3_Base_Factories_D3', 'M3_Base')
    end

    -- And the defenders of the control center
    -- ScenarioUtils.CreateArmyGroup('UEF', AdjustForDifficulty('M1_Forces'))

    -- Spawn the enemy bases
    ScenarioUtils.CreateArmyGroup('UEF', AdjustForDifficulty('M1_Defenses'))
    ScenarioUtils.CreateArmyGroup('UEF', AdjustForDifficulty('M1_Walls'))
-- ScenarioUtils.CreateArmyGroup('Cybran', AdjustForDifficulty('M1_Base_Naval_Factories'))
-- ScenarioUtils.CreateArmyGroup('Cybran', AdjustForDifficulty('M1_Base_Naval_Misc'))

    -- Spawn the mobile patrollers, watch for when they die
    for i = 1, M1AirDefenseGroups[ Difficulty ] do
        local AirDefense = ScenarioUtils.CreateArmyGroup('UEF', AdjustForDifficulty('M1_Air_Defense'))
        for k, location in ScenarioUtils.ChainToPositions('M1_Air_Defense') do
            IssuePatrol(AirDefense, location)
        end
        ScenarioFramework.CreateGroupDeathTrigger(M1RespawnAirDefense, AirDefense)
    end
    for i = 1, M1GroundDefenseGroups[ Difficulty ] do
        local GroundDefense = ScenarioUtils.CreateArmyGroup('UEF', AdjustForDifficulty('M1_Ground_Defense'))
        for k, location in ScenarioUtils.ChainToPositions('M1_Ground_Defense') do
            IssuePatrol(GroundDefense, location)
        end
        ScenarioFramework.CreateGroupDeathTrigger(M1RespawnGroundDefense, GroundDefense)
    end

    -- This override will make sure that the Cybran army doesn't run into the unit cap
    SetArmyUnitCap(Cybran, CybranUnitCap)
    SetArmyUnitCap(Aeon, AeonUnitCap)
    SetArmyUnitCap(UEF, UEFUnitCap)
    SetArmyUnitCap(Neutral, NeutralUnitCap)

    for _, player in ScenarioInfo.HumanPlayers do
        SetAlliance(player, UEF, 'Enemy')
    end
    for _, player in ScenarioInfo.HumanPlayers do
        SetAlliance(player, Cybran, 'Enemy')
    end
    for _, player in ScenarioInfo.HumanPlayers do
        SetAlliance(player, Aeon, 'Enemy')
    end
    for _, player in ScenarioInfo.HumanPlayers do
        SetAlliance(player, Neutral, 'Neutral')
    end

    for _, player in ScenarioInfo.HumanPlayers do
        SetAlliance(UEF, player, 'Enemy')
    end
    SetAlliance(UEF, Cybran, 'Enemy')
    SetAlliance(UEF, Aeon, 'Enemy')
    SetAlliance(UEF, Neutral, 'Neutral')

    for _, player in ScenarioInfo.HumanPlayers do
        SetAlliance(Cybran, player, 'Enemy')
    end
    SetAlliance(Cybran, UEF, 'Enemy')
    SetAlliance(Cybran, Aeon, 'Enemy')
    SetAlliance(Cybran, Neutral, 'Neutral')

    for _, player in ScenarioInfo.HumanPlayers do
        SetAlliance(Aeon, player, 'Enemy')
    end
    SetAlliance(Aeon, UEF, 'Enemy')
    SetAlliance(Aeon, Cybran, 'Enemy')
    SetAlliance(Aeon, Neutral, 'Neutral')

    for _, player in ScenarioInfo.HumanPlayers do
        SetAlliance(Neutral, player, 'Neutral')
    end
    SetAlliance(Neutral, UEF, 'Neutral')
    SetAlliance(Neutral, Cybran, 'Neutral')
    SetAlliance(Neutral, Aeon, 'Neutral')

    SetIgnorePlayableRect(UEF, true)
    SetIgnorePlayableRect(Cybran, true)
    SetIgnorePlayableRect(Aeon, true)
    SetIgnorePlayableRect(Neutral, true)

    -- ScenarioFramework.SetAeonColor(Aeon)
    ScenarioFramework.SetCybranColor(Cybran)
    ScenarioFramework.SetUEFColor(UEF)
    ScenarioFramework.SetUEFColor(Neutral)
    ScenarioFramework.SetAeonColor(Player)

    -- Take away units that the player shouldn't have access to
    for _, player in ScenarioInfo.HumanPlayers do
         ScenarioFramework.AddRestriction(player, categories.uab0304 + -- Quantum Gate
                                      categories.ual0301 + -- Sub Commander
                                      categories.ual0401 + -- Giant Assault Bot
                                      categories.uas0401 + -- Submersible Battleship
                                      categories.uas0304 + -- Strategic Missile Submarine
                                      categories.uaa0310 ) -- Death Saucer
    end

    -- If needed, take away units that the computer shouldn't have access to

    -- Set the maximum number of units that the player is allowed to have

    -- The control center that the player will be attempting to capture
    ScenarioInfo.BlackSunControlCenter = ScenarioUtils.CreateArmyUnit('Neutral', 'Black_Sun_Control_Center')
    ScenarioInfo.BlackSunControlCenter:SetCanTakeDamage(false)
    ScenarioInfo.BlackSunControlCenter:SetCanBeKilled(false)
    ScenarioInfo.BlackSunControlCenter:SetReclaimable(false)

    -- Set up a trigger to go off if it dies
    ScenarioFramework.CreateUnitCapturedTrigger(nil, M1ControlCenterCaptured, ScenarioInfo.BlackSunControlCenter)
    ScenarioFramework.CreateArmyIntelTrigger(M1ControlCenterSpotted, ArmyBrains[Player], 'LOSNow', ScenarioInfo.BlackSunControlCenter, true, categories.ALLUNITS, true, ArmyBrains[ Neutral ])

    -- Add the objective to kill the city buildings
    ScenarioInfo.M1P1Objective = Objectives.Capture(
        'primary',
        'incomplete',
        OpStrings.M1P1Text,
        OpStrings.M1P1Detail,
        {
            Units = { ScenarioInfo.BlackSunControlCenter },
            FlashVisible = true,
        }
   )

    ScenarioFramework.Dialogue(ScenarioStrings.NewPObj)

    -- If the player doesn't complete the objective soon, remind him that it's important
    ScenarioFramework.CreateTimerTrigger(M1P1Reminder, M1P1InitialReminderDelay)

    -- ScenarioFramework.CreateArmyStatTrigger(M1B1Complete, ArmyBrains[Aeon], 'B1Trigger',
    -- {{ StatType = 'Units_Killed', CompareType = 'GreaterThan', Value = M1B1KillAmount, Category = categories.AEON, },}) #300 of Marxon's units

    -- build one of each of the experimental units
    -- ScenarioFramework.CreateArmyStatTrigger(M1B2UnitBuilt, ArmyBrains[Player], 'B2Trigger1',
    -- {{ StatType = 'Units_History', CompareType = 'GreaterThanOrEqual', Value = 1, Category = categories.ual0401, },})
    -- ScenarioFramework.CreateArmyStatTrigger(M1B2UnitBuilt, ArmyBrains[Player], 'B2Trigger2',
    -- {{ StatType = 'Units_History', CompareType = 'GreaterThanOrEqual', Value = 1, Category = categories.uas0401, },})
    -- ScenarioFramework.CreateArmyStatTrigger(M1B2UnitBuilt, ArmyBrains[Player], 'B2Trigger3',
    -- {{ StatType = 'Units_History', CompareType = 'GreaterThanOrEqual', Value = 1, Category = categories.uaa0310, },})

    -- Set the naval attack to launch after a delay
    -- Right now this is automatically launched when M1P1 is completed
    -- ScenarioFramework.CreateTimerTrigger(M1NavalAttack, M1NavalAttackDelay[ Difficulty ])

    -- Kick off the reoccurring attacks
    ScenarioFramework.CreateTimerTrigger(M1ReoccurringLightAttack, M1ReoccurringLightAttackInitialDelay[ Difficulty ])
    ScenarioFramework.CreateTimerTrigger(M1ReoccurringMediumAttack, M1ReoccurringMediumAttackInitialDelay[ Difficulty ])
    ScenarioFramework.CreateTimerTrigger(M1ReoccurringHeavyAttack, M1ReoccurringHeavyAttackInitialDelay[ Difficulty ])

    -- Send scouts at the player to encourage them to build defenses
    ScenarioFramework.CreateTimerTrigger(M1Scout, M1ScoutDelay[ Difficulty ])

    -- Dialog that is delayed from the start of the mission
    ScenarioFramework.CreateTimerTrigger(M1Dialog1, M1DialogDelay1)

    -- Restrict access to most of the map
    ScenarioFramework.SetPlayableArea('M1_Playable_Area', false)

    -- Intro camera
    ScenarioFramework.StartOperationJessZoom('Start_Camera_Area', CreatePlayer)
    -- Delay opening dialogue until Commander is largely warped in
    ScenarioFramework.CreateTimerTrigger(OpeningDialogue, 6.5)
end

function CreatePlayer()
    -- Enter...the commander!
    ScenarioInfo.PlayerCDR = ScenarioUtils.CreateArmyUnit('Player', 'Commander')
    ScenarioInfo.PlayerCDR:PlayCommanderWarpInEffect()

    -- spawn coop players too
    ScenarioInfo.CoopCDR = {}
    local tblArmy = ListArmies()
    coop = 1
    for iArmy, strArmy in pairs(tblArmy) do
        if iArmy >= ScenarioInfo.Coop1 then
            ScenarioInfo.CoopCDR[coop] = ScenarioUtils.CreateArmyUnit(strArmy, 'Commander')
            ScenarioInfo.CoopCDR[coop]:PlayCommanderWarpInEffect()
            coop = coop + 1
            WaitSeconds(0.5)
        end
    end

    -- Set up a trigger to go off if the commander dies
    ScenarioFramework.CreateUnitDeathTrigger(PlayerCommanderDied, ScenarioInfo.PlayerCDR)
    -- Delay the explosion so that we can catch it on camera
    ScenarioFramework.PauseUnitDeath(ScenarioInfo.PlayerCDR)

    for index, coopACU in ScenarioInfo.CoopCDR do
        ScenarioFramework.PauseUnitDeath(coopACU)
        ScenarioFramework.CreateUnitDeathTrigger(PlayerCommanderDied, coopACU)
    end
end

function OpeningDialogue()
    ScenarioFramework.Dialogue(OpStrings.A06_M01_010)
    ScenarioFramework.Dialogue(OpStrings.A06_M01_020)
end

function M1ControlCenterSpotted()
    ScenarioFramework.Dialogue(OpStrings.A06_M01_030)
end

function M1ControlCenterCaptured(newHandle)
    ScenarioFramework.Dialogue(OpStrings.A06_M01_040)
    -- pull a switcheroo here, as soon as the player captures it, set it
    -- back to neutral, but painted with the player's color
    -- Now it won't get attacked, but it looks like it belongs to the player.
    ScenarioFramework.SetAeonColor(Neutral)
    ScenarioInfo.BlackSunControlCenter = ScenarioFramework.GiveUnitToArmy(newHandle, Neutral)
    ScenarioInfo.BlackSunControlCenter:SetCanTakeDamage(false)
    ScenarioInfo.BlackSunControlCenter:SetCanBeKilled(false)
    ScenarioInfo.BlackSunControlCenter:SetCapturable(false)
    ScenarioInfo.BlackSunControlCenter:SetReclaimable(false)
    -- M1NavalAttack()
    -- Cutting the naval attack; going straight to mission 2 from here
    ScenarioInfo.M1P1Complete = true
    ForkThread(ShowM1P1NIS)
end

function ShowM1P1NIS()
    -- Blacksun control center captured cam
    local camInfo = {
        blendTime = 1.0,
        holdTime = 4,
        orientationOffset = { -2.1, 0.15, 0 },
        positionOffset = { 0, 0.5, 0 },
        zoomVal = 25,
    }
    ScenarioFramework.OperationNISCamera(ScenarioInfo.BlackSunControlCenter, camInfo)

    WaitSeconds(7)
    EndMission1()
end

function M1Dialog1()
    if(ScenarioInfo.MissionNumber == 1) and not ScenarioInfo.OpEnded then
        ScenarioFramework.Dialogue(RandomAikoTaunt())
        ScenarioFramework.CreateTimerTrigger(M1Dialog2, M1DialogDelay2)
    end
end

function M1Dialog2()
    if(ScenarioInfo.MissionNumber == 1) and not ScenarioInfo.OpEnded then
        ScenarioFramework.Dialogue(RandomRedTaunt())
        ScenarioFramework.CreateTimerTrigger(M1Dialog3, M1DialogDelay3)
    end
end

function M1Dialog3()
    if(ScenarioInfo.MissionNumber == 1) and not ScenarioInfo.OpEnded then
        ScenarioFramework.Dialogue(RandomAikoTaunt())
        ScenarioFramework.CreateTimerTrigger(M1Dialog4, M1DialogDelay4)
    end
end

function M1Dialog4()
    if(ScenarioInfo.MissionNumber == 1) and not ScenarioInfo.OpEnded then
        ScenarioFramework.Dialogue(RandomRedTaunt())
        ScenarioFramework.CreateTimerTrigger(M1Dialog5, M1DialogDelay5)
    end
end

function M1Dialog5()
    if(ScenarioInfo.MissionNumber == 1) and not ScenarioInfo.OpEnded then
        ScenarioFramework.Dialogue(RandomAikoTaunt())
        ScenarioFramework.CreateTimerTrigger(M1Dialog6, M1DialogDelay6)
    end
end

function M1Dialog6()
    if(ScenarioInfo.MissionNumber == 1) and not ScenarioInfo.OpEnded then
        ScenarioFramework.Dialogue(RandomRedTaunt())
    end
end

function M1RespawnAirDefense()
    WaitSeconds(M1AirRespawnDelay[ Difficulty ])
    if(ScenarioInfo.MissionNumber == 1) and(ScenarioInfo.M1P1Objective.Active) then
        local AirDefense = ScenarioUtils.CreateArmyGroup('UEF', AdjustForDifficulty('M1_Air_Defense'))
        for k, location in ScenarioUtils.ChainToPositions('M1_Air_Defense') do
            IssuePatrol(AirDefense, location)
        end
        ScenarioFramework.CreateGroupDeathTrigger(M1RespawnAirDefense, AirDefense)
    end
end

function M1RespawnGroundDefense()
    WaitSeconds(M1GroundRespawnDelay[ Difficulty ])
    if(ScenarioInfo.MissionNumber == 1) and(ScenarioInfo.M1P1Objective.Active) then
        local GroundDefense = ScenarioUtils.CreateArmyGroup('UEF', AdjustForDifficulty('M1_Ground_Defense'))
        for k, location in ScenarioUtils.ChainToPositions('M1_Ground_Defense') do
            IssuePatrol(GroundDefense, location)
        end
        ScenarioFramework.CreateGroupDeathTrigger(M1RespawnGroundDefense, GroundDefense)
    end
end


function M1NavalAttack()
    ScenarioInfo.M1P1Complete = true

    -- spawn naval armies
    local CybranNavy = ScenarioUtils.CreateArmyGroupAsPlatoonCoopBalanced('Cybran', AdjustForDifficulty('M1_Naval_Attack'), 'AttackFormation')
    local UEFNavy = ScenarioUtils.CreateArmyGroupAsPlatoonCoopBalanced('UEF', AdjustForDifficulty('M1_Naval_Attack'), 'AttackFormation')

    -- move them to the player's base
    CybranNavy:AggressiveMoveToLocation(ScenarioUtils.MarkerToPosition('M1_Naval_Attack_1'))
    CybranNavy:AggressiveMoveToLocation(ScenarioUtils.MarkerToPosition('M1_Naval_Attack_2'))
    CybranNavy:AggressiveMoveToLocation(ScenarioUtils.MarkerToPosition('M1_Naval_Attack_3'))
    CybranNavy:AggressiveMoveToLocation(ScenarioUtils.MarkerToPosition('M1_Naval_Attack_4'))
    CybranNavy:AggressiveMoveToLocation(ScenarioUtils.MarkerToPosition('M1_Naval_Attack_5'))

    UEFNavy:AggressiveMoveToLocation(ScenarioUtils.MarkerToPosition('M1_Naval_Attack_6'))
    UEFNavy:AggressiveMoveToLocation(ScenarioUtils.MarkerToPosition('M1_Naval_Attack_7'))
    UEFNavy:AggressiveMoveToLocation(ScenarioUtils.MarkerToPosition('M1_Naval_Attack_4'))
    UEFNavy:AggressiveMoveToLocation(ScenarioUtils.MarkerToPosition('M1_Naval_Attack_5'))

    local CombinedGroup = CybranNavy:GetPlatoonUnits()
    for k, unit in UEFNavy:GetPlatoonUnits() do
        table.insert(CombinedGroup, unit)
    end

    -- Add the objective to kill the naval units
    ScenarioInfo.M1P2Objective = Objectives.KillOrCapture(
        'primary',
        'incomplete',
        OpStrings.M1P2Text,
        OpStrings.M1P2Detail,
        {
            Units = CombinedGroup,
            MarkUnits = true,
        }
   )

    ScenarioFramework.Dialogue(OpStrings.A06_M01_050)
    ScenarioInfo.M1P2Objective:AddResultCallback(EndMission1)
    ScenarioFramework.Dialogue(ScenarioStrings.NewPObj)
end

function M1Scout()
    if ScenarioInfo.MissionNumber == 1 then
        local Scout = ScenarioUtils.CreateArmyGroup('UEF', AdjustForDifficulty('M1_Scout'))
        IssuePatrol(Scout, ScenarioUtils.MarkerToPosition('Player_Base_Landing_5'))
        IssuePatrol(Scout, ScenarioUtils.MarkerToPosition('Player_Base_Landing_1'))
        IssuePatrol(Scout, ScenarioUtils.MarkerToPosition('M1_Air_Offense_5'))
    end
end

function M1ReoccurringLightAttack()
    if ScenarioInfo.MissionNumber == 1 then
        if(Random(0, 100) < 30) then
            -- create as platoon, send on patrol
            local platoon = ScenarioUtils.CreateArmyGroupAsPlatoonCoopBalanced('UEF', AdjustForDifficulty('M1_Light_Attack'), 'AttackFormation')
            for k, location in ScenarioUtils.ChainToPositions('M3_Naval_Patrol') do
                platoon:Patrol(location)
            end
        else
            -- let the PBM grab them
            ScenarioUtils.CreateArmyGroup('UEF', AdjustForDifficulty('M1_Light_Attack'))
        end

        ScenarioFramework.CreateTimerTrigger(M1ReoccurringLightAttack, M1ReoccurringLightAttackDelay[ Difficulty ])

        ScenarioFramework.CreateTimerTrigger(M1CybranLightAttack, M1CybranDelay[ Difficulty ])
    end
end

function M1CybranLightAttack()
    if ScenarioInfo.MissionNumber == 1 then
        if(Random(0, 100) < 30) then
            -- create as platoon, send on patrol
            local platoon = ScenarioUtils.CreateArmyGroupAsPlatoonCoopBalanced('Cybran', AdjustForDifficulty('M1_Light_Attack'), 'AttackFormation')
            for k, location in ScenarioUtils.ChainToPositions('M2_Cybran_Naval_Patrol') do
                platoon:Patrol(location)
            end
        else
            -- let the PBM grab them
            ScenarioUtils.CreateArmyGroup('Cybran', AdjustForDifficulty('M1_Light_Attack'))
        end
    end
end

function M1ReoccurringMediumAttack()
    if ScenarioInfo.MissionNumber == 1 then
        ScenarioUtils.CreateArmyGroup('UEF', AdjustForDifficulty('M1_Medium_Attack'))

        ScenarioFramework.CreateTimerTrigger(M1ReoccurringMediumAttack, M1ReoccurringMediumAttackDelay[ Difficulty ])

        ScenarioFramework.CreateTimerTrigger(M1CybranMediumAttack, M1CybranDelay[ Difficulty ])
    end
end

function M1CybranMediumAttack()
    if ScenarioInfo.MissionNumber == 1 then
        if(Random(0, 100) < 30) then
            -- create as platoon, send on patrol
            local platoon = ScenarioUtils.CreateArmyGroupAsPlatoonCoopBalanced('Cybran', AdjustForDifficulty('M1_Medium_Attack'), 'AttackFormation')
            for k, location in ScenarioUtils.ChainToPositions('M2_Cybran_Naval_Patrol') do
                platoon:Patrol(location)
            end
        else
            -- let the PBM grab them
            ScenarioUtils.CreateArmyGroup('Cybran', AdjustForDifficulty('M1_Medium_Attack'))
        end
    end
end

function M1ReoccurringHeavyAttack()
    if ScenarioInfo.MissionNumber == 1 then
        for i = 1, M1NumberOfAttackerSpawns[ Difficulty ] do
            ScenarioUtils.CreateArmyGroup('UEF', AdjustForDifficulty('M1_Air_Offense'))
            if not ScenarioInfo.M1FirstAttackersSpawned then
                ScenarioInfo.M1FirstAttackersSpawned = true
                break
            end
        end

        ScenarioFramework.CreateTimerTrigger(M1ReoccurringHeavyAttack, M1ReoccurringHeavyAttackDelay[ Difficulty ])
    end
end

function EndMission1()
    ScenarioInfo.M1P2Complete = true
    -- ScenarioFramework.Dialogue(OpStrings.A06_M01_090)
    BeginMission2()
end

function BeginMission2()
    -- Update the playable area
    ScenarioFramework.SetPlayableArea('M2_Playable_Area')
    ScenarioFramework.Dialogue(ScenarioStrings.MapExpansion)

    ScenarioFramework.Dialogue(OpStrings.A06_M02_010)

    AddTechMission2()

    -- Set the maximum number of units that the player is allowed to have

    ScenarioInfo.Mission2ObjectiveGroup = Objectives.CreateGroup('Mission 2 Objectives', EndMission2)

    ScenarioInfo.M2Base = ScenarioUtils.CreateArmyGroup('Cybran', AdjustForDifficulty('M2_Base'))
    ScenarioUtils.CreateArmyGroup('Cybran', AdjustForDifficulty('M2_Walls'))
    ScenarioUtils.CreateArmyGroup('Cybran', AdjustForDifficulty('M2_Misc'))
    ScenarioInfo.CybranCommander = ScenarioUtils.CreateArmyUnit('Cybran', 'Commander')
    ScenarioFramework.PauseUnitDeath(ScenarioInfo.CybranCommander)
    ScenarioInfo.CybranCommander:SetCustomName(LOC '{i RedFog}')
    ScenarioInfo.CybranCommander:CreateEnhancement('T3Engineering')
    ScenarioInfo.CybranCommander:CreateEnhancement('Teleporter')
    ScenarioInfo.CybranCommander:CreateEnhancement('MicrowaveLaserGenerator')
    ScenarioInfo.CybranSubCommander = ScenarioUtils.CreateArmyUnit('Cybran', 'SubCommander')
    IssuePatrol({ ScenarioInfo.CybranCommander }, ScenarioUtils.MarkerToPosition('M2_Engineer_Patrol_Chain_1'))
    IssuePatrol({ ScenarioInfo.CybranCommander }, ScenarioUtils.MarkerToPosition('M2_Engineer_Patrol_Chain_2'))
    IssueGuard({ ScenarioInfo.CybranSubCommander }, ScenarioInfo.CybranCommander)
    local Antinukes = ScenarioUtils.CreateArmyGroup('Cybran', 'M2_Antinukes')
    for k, unit in Antinukes do
        unit:GiveTacticalSiloAmmo(5)
    end

-- for k, unit in ScenarioInfo.M2Base do
--    if unit:GetUnitId() == "urb4202" then
--        if Difficulty == 2 then
--            local ShieldLevel = Random(1, 100)
--            if ShieldLevel < M2D2ShieldLevel1Threshold then
--                # Level 1, do nothing
--            elseif ShieldLevel < M2D2ShieldLevel2Threshold then
--                # Level 2
--                unit:CreateEnhancement('Shield2')
--            elseif ShieldLevel < M2D2ShieldLevel3Threshold then
--                # Level 3
--                unit:CreateEnhancement('Shield3')
--            elseif ShieldLevel < M2D2ShieldLevel4Threshold then
--                # Level 4
--                unit:CreateEnhancement('Shield4')
--            end
--        elseif Difficulty == 3 then
--            local ShieldLevel = Random(1, 100)
--            if ShieldLevel < M2D3ShieldLevel1Threshold then
--                # Level 1, do nothing
--            elseif ShieldLevel < M2D3ShieldLevel2Threshold then
--                # Level 2
--                unit:CreateEnhancement('Shield2')
--            elseif ShieldLevel < M2D3ShieldLevel3Threshold then
--                # Level 3
--                unit:CreateEnhancement('Shield3')
--            elseif ShieldLevel < M2D3ShieldLevel4Threshold then
--                # Level 4
--                unit:CreateEnhancement('Shield4')
--            end
--        end
--    end
-- end

    ScenarioInfo.M2Attackers = ScenarioUtils.CreateArmyGroup('Cybran', AdjustForDifficulty('M2_Attackers'))

    ScenarioInfo.M2P1Objective = Objectives.Protect(
        'primary',
        'incomplete',
        OpStrings.M2P1Text,
        OpStrings.M2P1Detail,
        {
            Units = { ScenarioInfo.BlackSunControlCenter },
        }
   )
    ScenarioInfo.Mission2ObjectiveGroup:AddObjective(ScenarioInfo.M2P1Objective)

    -- Kill the enemy commander
    ScenarioInfo.M2P2Objective = Objectives.Kill(
        'primary',
        'incomplete',
        OpStrings.M2P2Text,
        OpStrings.M2P2Detail,
        {
            Units = { ScenarioInfo.CybranCommander },
            NumRequired = 1,
        }
   )
    ScenarioInfo.M2P2Objective:AddResultCallback(M2P2Done)
    ScenarioInfo.Mission2ObjectiveGroup:AddObjective(ScenarioInfo.M2P2Objective)

    ScenarioFramework.CreateAreaTrigger(CybranNearControlCenter, ScenarioUtils.AreaToRect('M1_Control_Center_Near_Area'), categories.CYBRAN, true, false, ArmyBrains[Cybran], 1, false)

    ScenarioInfo.MissionNumber = 2

    -- Deliver some story information via dialog from an offscreen commander
    ScenarioFramework.CreateTimerTrigger(M2OffscreenCommanderDialog1, M2OffscreenCommanderDialogDelay1)

    -- If the player doesn't complete the objectives soon, remind him that it's important
    ScenarioFramework.CreateTimerTrigger(M2P2Reminder, M2P2InitialReminderDelay)

    -- Dialog that is delayed from the start of the mission
    ScenarioFramework.CreateTimerTrigger(M2Dialog1, M2DialogDelay1)

    -- Dialog about the attack that will happen soon
    ScenarioFramework.CreateTimerTrigger(M2AttackNow, M2AttackDelay)
    -- ScenarioFramework.CreateTimerTrigger(M2PreAttack1, M2PreAttack1Delay)
end

-- Cybran units have made it to the control center!
-- Does the player still have defending units there?
function CybranNearControlCenter()
    if ScenarioInfo.MissionNumber == 2 then
        if not ScenarioFramework.UnitsInAreaCheck(categories.AEON, 'M1_Control_Center_Far_Area') then
            -- No defenders.  The Cybran capture the building -- the player loses
            ControlCenterCapturedByEnemy()
        else
            -- They're still fighting, check later
            ScenarioFramework.CreateTimerTrigger(M2ResetControlCenterAreaTrigger, 5)
        end
    end
end

function M2ResetControlCenterAreaTrigger()
    ScenarioFramework.CreateAreaTrigger(CybranNearControlCenter, ScenarioUtils.AreaToRect('M1_Control_Center_Near_Area'), categories.CYBRAN, true, false, ArmyBrains[Cybran], 1, false)
end

-- function M2PreAttack1()
-- if ScenarioInfo.M2P2Objective and ScenarioInfo.M2P2Objective.Active then
--    ScenarioFramework.Dialogue(OpStrings.A06_M02_050)
--    ScenarioFramework.CreateTimerTrigger(M2PreAttack2, M2PreAttack2Delay)
-- end
-- end
--
-- function M2PreAttack2()
-- if ScenarioInfo.M2P2Objective and ScenarioInfo.M2P2Objective.Active then
--    ScenarioFramework.Dialogue(OpStrings.A06_M02_060)
--    ScenarioFramework.CreateTimerTrigger(M2AttackNow, M2AttackDelay)
-- end
-- end

function M2AttackNow()
    if ScenarioInfo.M2P2Objective and ScenarioInfo.M2P2Objective.Active then
        ScenarioFramework.Dialogue(OpStrings.A06_M02_070)
        ScenarioInfo.VarTable['M2SendHugeAttack'] = true

        -- Build fewer units after the big attack; these will be used just for base defense
        ScenarioInfo.VarTable['M2SpiderCount'] = PostAttackM2SpiderCount[ Difficulty ]
        ScenarioInfo.VarTable['M2SiegebotCount'] = PostAttackM2SiegebotCount[ Difficulty ]
        ScenarioInfo.VarTable['M2FlakCount'] = PostAttackM2FlakCount[ Difficulty ]
        ScenarioInfo.VarTable['M2BomberCount'] = PostAttackM2BomberCount[ Difficulty ]
        ScenarioInfo.VarTable['M2FighterCount'] = PostAttackM2FighterCount[ Difficulty ]
        ScenarioInfo.VarTable['M2ArtilleryCount'] = PostAttackM2ArtilleryCount[ Difficulty ]
        ScenarioInfo.VarTable['M2TankCount'] = PostAttackM2TankCount[ Difficulty ]
    end
end

function M2P2Done()
-- Cybran death cam
    ScenarioFramework.CDRDeathNISCamera(ScenarioInfo.CybranCommander, 7)

    ScenarioFramework.Dialogue(OpStrings.A06_M02_100)
    ScenarioInfo.M2P1Objective:ManualResult(true)
end

function M2OffscreenCommanderDialog1()
    if ScenarioInfo.MissionNumber == 2 and not ScenarioInfo.OpEnded then
        ScenarioFramework.Dialogue(OpStrings.A06_M02_020)
        ScenarioFramework.Dialogue(OpStrings.A06_M02_030)
        ScenarioFramework.CreateTimerTrigger(M2OffscreenCommanderDialog2, M2OffscreenCommanderDialogDelay2)
    end
end

function M2OffscreenCommanderDialog2()
    if ScenarioInfo.MissionNumber == 2 and not ScenarioInfo.OpEnded then
        ScenarioFramework.Dialogue(OpStrings.A06_M02_040)
        ScenarioFramework.CreateTimerTrigger(M2OffscreenCommanderDialog3, M2OffscreenCommanderDialogDelay3)
    end
end

function M2OffscreenCommanderDialog3()
    if ScenarioInfo.MissionNumber == 2 and not ScenarioInfo.OpEnded then
        ScenarioFramework.Dialogue(OpStrings.A06_M02_090)
        ScenarioFramework.CreateTimerTrigger(M2OffscreenCommanderDialog4, M2OffscreenCommanderDialogDelay4)
    end
end

function M2OffscreenCommanderDialog4()
    if ScenarioInfo.MissionNumber == 2 and not ScenarioInfo.OpEnded then
        ScenarioFramework.Dialogue(OpStrings.A06_M02_140, M2KillOffscreenCommander)
    end
end

function M2KillOffscreenCommander()
    if ScenarioInfo.M2P2Objective and ScenarioInfo.M2P2Objective.Active then
        local DeadGuy = ScenarioUtils.CreateArmyUnit('UEF', 'Offscreen_Commander')
        DeadGuy:Kill()
        WaitSeconds(5)
        ScenarioFramework.Dialogue(OpStrings.A06_M02_115)
    end
end

function M2Dialog1()
    if ScenarioInfo.MissionNumber == 2 and not ScenarioInfo.OpEnded then
        -- Dialog removed to the offscreen commander dialog functions
        ScenarioFramework.CreateTimerTrigger(M2Dialog2, M2DialogDelay2)
    end
end

function M2Dialog2()
    if ScenarioInfo.MissionNumber == 2 and not ScenarioInfo.OpEnded then
        ScenarioFramework.Dialogue(RandomRedTaunt())
        ScenarioFramework.CreateTimerTrigger(M2Dialog3, M2DialogDelay3)
    end
end

function M2Dialog3()
    if ScenarioInfo.MissionNumber == 2 and not ScenarioInfo.OpEnded then
        ScenarioFramework.Dialogue(RandomRedTaunt())
        ScenarioFramework.CreateTimerTrigger(M2Dialog4, M2DialogDelay4)
    end
end

function M2Dialog4()
    if ScenarioInfo.MissionNumber == 2 and not ScenarioInfo.OpEnded then
        -- Dialog removed to the offscreen commander dialog functions
        ScenarioFramework.CreateTimerTrigger(M2Dialog5, M2DialogDelay5)
    end
end

function M2Dialog5()
    if ScenarioInfo.MissionNumber == 2 and not ScenarioInfo.OpEnded then
        ScenarioFramework.Dialogue(RandomRedTaunt())
        ScenarioFramework.CreateTimerTrigger(M2Dialog6, M2DialogDelay6)
    end
end

function M2Dialog6()
    if ScenarioInfo.MissionNumber == 2 and not ScenarioInfo.OpEnded then
        ScenarioFramework.Dialogue(RandomRedTaunt())
    end
end

function EndMission2()
    ForkThread(BeginMission3)
end

function BeginMission3()

    -- Set the maximum number of units that the player is allowed to have

    -- Create the wreckage of the UEF base that was "defeated" during mission 2
    ScenarioUtils.CreateArmyGroup('UEF', 'M3_Wreckage', true)

    -- Update the playable area
    ScenarioFramework.SetPlayableArea('M3_Playable_Area')
    ScenarioFramework.Dialogue(ScenarioStrings.MapExpansion)

    -- Spawn the bases
    ScenarioUtils.CreateArmyGroup('Aeon', AdjustForDifficulty('M3_Base_Defenses'))
    ScenarioUtils.CreateArmyGroup('Aeon', AdjustForDifficulty('M3_Base_Economy'))
    ScenarioUtils.CreateArmyGroup('Aeon', AdjustForDifficulty('M3_Base_Factories'))
    ScenarioUtils.CreateArmyGroup('Aeon', AdjustForDifficulty('M3_Base_Misc'))
    ScenarioUtils.CreateArmyGroup('Aeon', AdjustForDifficulty('M3_Base_Walls'))
    ScenarioUtils.CreateArmyGroup('Aeon', AdjustForDifficulty('M3_Island_Defenses'))
    local Antinukes = ScenarioUtils.CreateArmyGroup('Aeon', 'M3_Antinukes')
    for k, unit in Antinukes do
        unit:GiveTacticalSiloAmmo(5)
    end

    ScenarioInfo.FriendlyCommander = ScenarioUtils.CreateArmyUnit('Aeon', 'Friendly_Commander')
    local AeonCommanderPlatoon = ScenarioUtils.CreateArmyGroupAsPlatoonCoopBalanced('Aeon', 'Commander_Group', 'NoFormation')
    for k, unit in AeonCommanderPlatoon:GetPlatoonUnits() do
        ScenarioInfo.AeonCommander = unit
        -- Delay the explosion so that we can catch it on camera
        ScenarioFramework.PauseUnitDeath(unit)
    end
    ScenarioInfo.AeonCommander:SetCustomName(LOC '{i Marxon}')
    ScenarioInfo.AeonCommander:CreateEnhancement('CrysalisBeam')
    ScenarioInfo.AeonCommander:CreateEnhancement('ShieldHeavy')
    ScenarioInfo.AeonCommander:CreateEnhancement('EnhancedSensors')

    AeonCommanderPlatoon.CDRData = {}
    AeonCommanderPlatoon.CDRData.LeashPosition = 'M3_Commander_Leash'
    AeonCommanderPlatoon.CDRData.LeashRadius = 60
    AeonCommanderPlatoon:ForkThread(import('/lua/ai/OpAI/OpBehaviors.lua').CDROverchargeBehavior)
    AeonCommanderPlatoon:ForkAIThread(M3AeonCommanderAIThread)

    IssuePatrol({ ScenarioInfo.AeonCommander }, ScenarioUtils.MarkerToPosition('M3_Commander_Patrol_1'))
    IssuePatrol({ ScenarioInfo.AeonCommander }, ScenarioUtils.MarkerToPosition('M3_Commander_Patrol_2'))

    ScenarioInfo.FriendlyCommander:SetCanTakeDamage(false)
    ScenarioInfo.FriendlyCommander:SetCanBeKilled(false)
    ScenarioInfo.FriendlyCommander:SetReclaimable(false)
    ScenarioInfo.FriendlyCommander:SetCapturable(false)

    ScenarioInfo.AeonCommander:SetReclaimable(false)
    ScenarioInfo.AeonCommander:SetCapturable(false)

    local Colossus = ScenarioUtils.CreateArmyUnit('Aeon', 'Colossus')
    IssuePatrol({ Colossus }, ScenarioUtils.MarkerToPosition('Colossus_Patrol_1'))
    IssuePatrol({ Colossus }, ScenarioUtils.MarkerToPosition('Colossus_Patrol_2'))

    -- invincible by design
    ScenarioInfo.BlackSun = ScenarioUtils.CreateArmyUnit('Aeon', 'Black_Sun')
    ScenarioInfo.BlackSun:SetCanTakeDamage(false)
    ScenarioInfo.BlackSun:SetCanBeKilled(false)
    ScenarioInfo.BlackSun:SetReclaimable(false)

    -- we rotate these buildings, so they are unselectable (otherwise players would see
    -- the selection rotated, and would perhaps want to know how to rotate their own buildings)
    local SupportBuildings = ScenarioUtils.CreateArmyGroup('Aeon', 'Black_Sun_Support')
    for k, unit in SupportBuildings do
        unit:SetUnSelectable(true)
        unit:SetCanTakeDamage(false)
        unit:SetCanBeKilled(false)
        unit:SetReclaimable(false)
    end

    ScenarioInfo.Mission3ObjectiveGroup = Objectives.CreateGroup('Mission 2 Objectives', PlayerWin)

    ScenarioInfo.M3P1Objective = Objectives.Kill(
        'primary',
        'incomplete',
        OpStrings.M3P1Text,
        OpStrings.M3P1Detail,
        { Units = { ScenarioInfo.AeonCommander }} -- Target
   )
    ScenarioInfo.M3P1Objective:AddResultCallback(M3CommanderDefeated)
    ScenarioInfo.Mission3ObjectiveGroup:AddObjective(ScenarioInfo.M3P1Objective)

-- ScenarioInfo.M3P2Objective = Objectives.Basic(
--    'primary',
--    'incomplete',
--    OpStrings.M3P2Text,
--    OpStrings.M3P2Detail,
--    Objectives.GetActionIcon('kill'),
--    {
--        MarkArea = true,
--        Area = 'M3_Black_Sun_Area',
--    }
-- )
-- ScenarioInfo.Mission3ObjectiveGroup:AddObjective(ScenarioInfo.M3P2Objective)
--
-- # Test of whether specified categories are in an area
-- ScenarioFramework.CreateAreaTrigger(M3P2Complete, ScenarioUtils.AreaToRect('M3_Black_Sun_Area'),(categories.AEON * categories.STRUCTURE) - categories.WALL, true, true, ArmyBrains[Aeon])

    -- Spawn the M3 base adjusted for difficulty
-- ScenarioInfo.M3_Base = ScenarioUtils.CreateArmyGroup('Aeon', AdjustForDifficulty('M3_Base_Economy'))

    AddTechMission3()
    ScenarioInfo.MissionNumber = 3

    -- Spawn a naval force and move them to the player's base
    local AeonNavy = ScenarioUtils.CreateArmyGroupAsPlatoonCoopBalanced('Aeon', AdjustForDifficulty('M3_Naval_Attack'), 'GrowthFormation')
    AeonNavy:AggressiveMoveToLocation(ScenarioUtils.MarkerToPosition('M3_Naval_Patrol_1'))
    AeonNavy:Patrol(ScenarioUtils.MarkerToPosition('M3_Naval_Patrol_2'))
    AeonNavy:Patrol(ScenarioUtils.MarkerToPosition('M3_Naval_Patrol_1'))

    -- Briefing
    ScenarioFramework.Dialogue(OpStrings.A06_M03_010, KillFriendlyCommander)

    ScenarioFramework.Dialogue(ScenarioStrings.NewPObj)

    -- If the player doesn't complete the objectives soon, remind him that it's important
    ScenarioFramework.CreateTimerTrigger(M3P1Reminder, M3P1InitialReminderDelay)

    ScenarioFramework.CreateTimerTrigger(M3Dialog1, M3DialogDelay1)
end

function M3AeonCommanderAIThread(platoon)
    platoon.PlatoonData.LocationType = 'M3_Aeon_Base'
    platoon:PatrolLocationFactoriesAI()
end

function M3CommanderDefeated()
-- Marxon killed
-- ScenarioFramework.EndOperationCamera(ScenarioInfo.AeonCommander, true)
    ScenarioFramework.CDRDeathNISCamera(ScenarioInfo.AeonCommander)

    -- All of his units die when he does
    for k, unit in ArmyBrains[Aeon]:GetListOfUnits(categories.ALLUNITS, false) do
        unit:Kill()
    end
end

function M3P2Complete()
    ScenarioInfo.M3P2Objective:ManualResult(true)
end

function KillFriendlyCommander()
-- Arnold death cam (not using CDRDeathNISCamera because I need to use vizradius)
    local camInfo = {
        blendTime = 1,
        holdTime = 7,
        orientationOffset = { math.pi, 0.7, 0 },
        positionOffset = { 0, 1, 0 },
        zoomVal = 65,
        vizRadius = 26,
    }
    ScenarioFramework.OperationNISCamera(ScenarioInfo.FriendlyCommander, camInfo)

    ScenarioInfo.FriendlyCommander:SetCanBeKilled(true)
    ScenarioInfo.FriendlyCommander:Kill()
    ScenarioFramework.Dialogue(OpStrings.A06_M03_020)
end

function M3Dialog1()
    if ScenarioInfo.M3P1Objective.Active and not ScenarioInfo.OpEnded then
        ScenarioFramework.Dialogue(RandomMarxonTaunt())
        ScenarioFramework.CreateTimerTrigger(M3Dialog2, M3DialogDelay2)
    end
end

function M3Dialog2()
    if ScenarioInfo.M3P1Objective.Active and not ScenarioInfo.OpEnded then
        ScenarioFramework.Dialogue(RandomMarxonTaunt())
        ScenarioFramework.CreateTimerTrigger(M3Dialog3, M3DialogDelay3)
    end
end

function M3Dialog3()
    if ScenarioInfo.M3P1Objective.Active and not ScenarioInfo.OpEnded then
        ScenarioFramework.Dialogue(OpStrings.A06_M03_040)
        ScenarioFramework.CreateTimerTrigger(M3Dialog4, M3DialogDelay4)
    end
end

function M3Dialog4()
    if ScenarioInfo.M3P1Objective.Active and not ScenarioInfo.OpEnded then
        ScenarioFramework.Dialogue(RandomMarxonTaunt())
        ScenarioFramework.CreateTimerTrigger(M3Dialog5, M3DialogDelay5)
    end
end

function M3Dialog5()
    if ScenarioInfo.M3P1Objective.Active and not ScenarioInfo.OpEnded then
        ScenarioFramework.Dialogue(RandomMarxonTaunt())
    end
end

function AddTechMission2()
    ScenarioFramework.PlayUnlockDialogue()
    for _, player in ScenarioInfo.HumanPlayers do
         ScenarioFramework.RemoveRestriction(player, categories.uab0304 + -- Quantum Gate
                                         categories.ual0301 + -- Sub Commander
                                         categories.uas0304 + -- Strategic Missile Submarine
                                         categories.ual0401 + -- Giant Assault Bot
                                         categories.uas0401 + -- Submersible Battleship
                                         categories.uaa0310 ) -- Death Saucer
    end
end

function AddTechMission3()
    -- Currently empty
end

function ControlCenterCapturedByEnemy()
    -- Let the player know what happened

    ScenarioInfo.M2P1Objective:ManualResult(false)

    ScenarioFramework.Dialogue(OpStrings.A06_M02_130, false, true)
    PlayerLose()
end

function PlayerCommanderDied()
-- Player death cam
-- ScenarioFramework.EndOperationCamera(ScenarioInfo.PlayerCDR, true)
    ScenarioFramework.CDRDeathNISCamera(ScenarioInfo.PlayerCDR)

    -- Let the player know what happened
    ScenarioFramework.Dialogue(OpStrings.A06_D01_010, false, true)
    PlayerLose()
end

-- function M1B1Complete()
-- if(not ScenarioInfo.M3P1Objective) or(ScenarioInfo.M3P1Objective and ScenarioInfo.M3P1Objective.Active) then
--    ScenarioInfo.M1B1Objective = Objectives.Basic(
--        'bonus',
--        'incomplete',
--        OpStrings.M1B1Text,
--        LOCF(OpStrings.M1B1Detail, M1B1KillAmount),
--        Objectives.GetActionIcon('kill'),
--        {
--        }
--   )
--    ScenarioInfo.M1B1Objective:ManualResult(true)
-- end
-- end

-- function M1B2UnitBuilt()
-- if not ScenarioInfo.M1B2UnitsBuilt then
--    ScenarioInfo.M1B2UnitsBuilt = 1
-- else
--    ScenarioInfo.M1B2UnitsBuilt = ScenarioInfo.M1B2UnitsBuilt + 1
-- end
-- if ScenarioInfo.M1B2UnitsBuilt == 3 then
--    M1B2Complete()
-- end
-- end

-- function M1B2Complete()
-- ScenarioInfo.M1B2Objective = Objectives.Basic(
--    'bonus',
--    'incomplete',
--    OpStrings.M1B2Text,
--    OpStrings.M1B2Detail,
--    Objectives.GetActionIcon('build'),
--    {
--    }
-- )
-- ScenarioInfo.M1B2Objective:ManualResult(true)
-- end

function RandomAikoTaunt()
    local randomIndex = Random(1, table.getn(TauntTableAiko))
    return(TauntTableAiko[ randomIndex ])
end

function RandomRedTaunt()
    local randomIndex = Random(1, table.getn(TauntTableRed))
    return(TauntTableRed[ randomIndex ])
end

function RandomMarxonTaunt()
    local randomIndex = Random(1, table.getn(TauntTableMarxon))
    return(TauntTableMarxon[ randomIndex ])
end

function AdjustForDifficulty(string_in)
    local string_out = string_in
    if Difficulty == 1 then
        string_out = string_out .. Difficulty1_Suffix
    elseif Difficulty == 2 then
        string_out = string_out .. Difficulty2_Suffix
    elseif Difficulty == 3 then
        string_out = string_out .. Difficulty3_Suffix
    end
    return string_out
end

function M1P1Reminder()
    if not ScenarioInfo.M1P1Complete and not ScenarioInfo.OpEnded then
        if not ScenarioInfo.M1P1ReminderAlternate then
            ScenarioInfo.M1P1ReminderAlternate = 1
            ScenarioFramework.Dialogue(OpStrings.A06_M01_060)
        elseif ScenarioInfo.M1P1ReminderAlternate == 1 then
            ScenarioInfo.M1P1ReminderAlternate = 2
            ScenarioFramework.Dialogue(OpStrings.A06_M01_070)
        else
            ScenarioInfo.M1P1ReminderAlternate = false
            ScenarioFramework.Dialogue(ScenarioStrings.AeonGenericReminder)
        end
        ScenarioFramework.CreateTimerTrigger(M1P1Reminder, M1P1ReoccuringReminderDelay)
    end
end

function M2P2Reminder()
    if ScenarioInfo.M2P2Objective and ScenarioInfo.M2P2Objective.Active and not ScenarioInfo.OpEnded then
        if not ScenarioInfo.M2P2ReminderAlternate then
            ScenarioInfo.M2P2ReminderAlternate = 1
            ScenarioFramework.Dialogue(OpStrings.A06_M02_110)
        elseif ScenarioInfo.M2P2ReminderAlternate == 1 then
            ScenarioInfo.M2P2ReminderAlternate = 2
            ScenarioFramework.Dialogue(OpStrings.A06_M02_120)
        else
            ScenarioInfo.M2P2ReminderAlternate = false
            ScenarioFramework.Dialogue(ScenarioStrings.AeonGenericReminder)
        end
        ScenarioFramework.CreateTimerTrigger(M2P2Reminder, M2P2ReoccuringReminderDelay)
    end
end

function M3P1Reminder()
    if ScenarioInfo.M3P1Objective and ScenarioInfo.M3P1Objective.Active and not ScenarioInfo.OpEnded then
        if not ScenarioInfo.M3P1ReminderAlternate then
            ScenarioInfo.M3P1ReminderAlternate = 1
            ScenarioFramework.Dialogue(OpStrings.A06_M03_060)
        elseif ScenarioInfo.M3P1ReminderAlternate == 1 then
            ScenarioInfo.M3P1ReminderAlternate = 2
            ScenarioFramework.Dialogue(OpStrings.A06_M03_070)
        else
            ScenarioInfo.M3P1ReminderAlternate = false
            ScenarioFramework.Dialogue(ScenarioStrings.AeonGenericReminder)
        end
        ScenarioFramework.CreateTimerTrigger(M3P1Reminder, M3P1ReoccuringReminderDelay)
    end
end

-- --------
-- End Game
-- --------
function PlayerWin()
    if not ScenarioInfo.OpEnded then
        -- Turn everything neutral; protect the player commander
        ScenarioFramework.EndOperationSafety()

        -- Computer voice saying op complete
        ScenarioFramework.Dialogue(ScenarioStrings.OpComp, false, true)

        -- Celebration dialogue
        ScenarioFramework.Dialogue(OpStrings.A06_M03_080, WinGame, true)
    end
end

function PlayerLose()
    if not ScenarioInfo.OpEnded then
        -- Turn everything neutral
        ScenarioFramework.EndOperationSafety()

        ScenarioFramework.Dialogue(ScenarioStrings.OpFail, LoseGame, true)
    end
end

function LoseGame()
    ScenarioInfo.OpComplete = false
    WaitSeconds(5)
    ScenarioFramework.EndOperation(ScenarioInfo.OpComplete, ScenarioInfo.OpComplete, false)
end

function WinGame()
    ScenarioInfo.OpComplete = true
    -- ScenarioFramework.PlayEndGameMovie(2, EndGame)
    -- local bonus = Objectives.IsComplete(ScenarioInfo.M1B1Objective) and Objectives.IsComplete(ScenarioInfo.M1B2Objective)
    -- this now plays the movie directly
    ScenarioFramework.EndOperation(ScenarioInfo.OpComplete, ScenarioInfo.OpComplete, false)
end


-- --------------
-- Test functions
-- --------------
-- function OnF3()
-- for k, unit in ArmyBrains[UEF]:GetListOfUnits(categories.ALLUNITS, false) do
--    unit:Destroy()
-- end
--
-- Objectives.UpdateObjective(ScenarioInfo.M1P1Objective.Title, 'complete', "complete", ScenarioInfo.M1P1Objective.Tag)
-- ScenarioInfo.M1P1Objective.Active = false
-- ScenarioInfo.M1P1Objective:OnResult(true)
--
-- #    Objectives.UpdateObjective(ScenarioInfo.M1P2Objective.Title, 'complete', "complete", ScenarioInfo.M1P2Objective.Tag)
-- #    ScenarioInfo.M1P2Objective.Active = false
-- #    ScenarioInfo.M1P2Objective:OnResult(true)
--
-- EndMission1()
-- end
--
-- function OnCtrlF3()
-- for k, unit in ArmyBrains[UEF]:GetListOfUnits(categories.ALLUNITS, false) do
--    unit:Destroy()
-- end
--
-- Objectives.UpdateObjective(ScenarioInfo.M1P1Objective.Title, 'complete', "complete", ScenarioInfo.M1P1Objective.Tag)
-- ScenarioInfo.M1P1Objective.Active = false
-- ScenarioInfo.M1P1Objective:OnResult(true)
--
-- ScenarioInfo.MissionNumber = 2
-- end
--
-- function OnShiftF3()
-- PlayerWin()
-- end
--
-- function OnF4()
-- for k, unit in ArmyBrains[Cybran]:GetListOfUnits(categories.ALLUNITS, false) do
--    unit:Destroy()
-- end
--
-- ScenarioInfo.M2P1Objective:ManualResult(true)
--
-- Objectives.UpdateObjective(ScenarioInfo.M2P2Objective.Title, 'complete', "complete", ScenarioInfo.M2P2Objective.Tag)
-- ScenarioInfo.M2P2Objective.Active = false
-- ScenarioInfo.M2P2Objective:OnResult(true)
-- end
--
-- function OnShiftF4()
-- ScenarioInfo.VarTable['M2SendHugeAttack'] = true
-- end
--
--
-- function OnShiftF5()
-- #M1B1Complete()
-- #M1B2Complete()
-- end
--
-- function OnCtrlF5()
-- LOG('Player army: ' .. GetArmyUnitCostTotal(ScenarioInfo.Player) .. ' out of ' .. GetArmyUnitCap(ScenarioInfo.Player))
-- LOG('UEF army: ' .. GetArmyUnitCostTotal(ScenarioInfo.UEF) .. ' out of ' .. GetArmyUnitCap(ScenarioInfo.UEF))
-- LOG('Cybran army: ' .. GetArmyUnitCostTotal(ScenarioInfo.Cybran) .. ' out of ' .. GetArmyUnitCap(ScenarioInfo.Cybran))
-- LOG('Aeon army: ' .. GetArmyUnitCostTotal(ScenarioInfo.Aeon) .. ' out of ' .. GetArmyUnitCap(ScenarioInfo.Aeon))
-- end
--
-- function OnCtrlAltF5()
-- ScenarioFramework.EndOperation('SCCA_Coop_A06_v03', true, ScenarioInfo.Options.Difficulty, true, true, true)
-- end
