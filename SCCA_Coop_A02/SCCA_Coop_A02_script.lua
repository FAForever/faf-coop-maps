-- ****************************************************************************
-- **
-- **  File     :  /maps/SCCA_Coop_A02/SCCA_Coop_A02_script.lua
-- **  Author(s):  David Tomandl
-- **
-- **  Summary  :  This is the main file in control of the events during
-- **              operation A2.
-- **
-- **  Copyright © 2006 Gas Powered Games, Inc.  All rights reserved.
-- ****************************************************************************

local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local Objectives = ScenarioFramework.Objectives
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local AIBuildStructures = import('/lua/ai/AIBuildStructures.lua')
local Cinematics = import('/lua/cinematics.lua')
local ScenarioStrings = import('/lua/ScenarioStrings.lua')
local OpStrings = import ('/maps/SCCA_Coop_A02/SCCA_Coop_A02_strings.lua')
local Weather = import('/lua/weather.lua')

-------------------------
-- Misc Global Definitions
-------------------------
ScenarioInfo.Player = 1
ScenarioInfo.Cybran = 2
ScenarioInfo.NeutralCybran = 3
ScenarioInfo.Coop1 = 4
ScenarioInfo.Coop2 = 5
ScenarioInfo.Coop3 = 6

ScenarioInfo.VarTable = {}
ScenarioInfo.M1P1Complete = false
ScenarioInfo.M1P2Complete = false

------------------------
-- Misc Local Definitions
------------------------
local MissionTexture = '/textures/ui/common/missions/mission.dds'

local Difficulty = ScenarioInfo.Options.Difficulty or 2

local Difficulty1_Suffix = '_D1'
local Difficulty2_Suffix = '_D2'
local Difficulty3_Suffix = '_D3'

local Player = ScenarioInfo.Player
local Coop1 = ScenarioInfo.Coop1
local Coop2 = ScenarioInfo.Coop2
local Coop3 = ScenarioInfo.Coop3
local Cybran = ScenarioInfo.Cybran
local NeutralCybran = ScenarioInfo.NeutralCybran

local TauntTable = {
    OpStrings.TAUNT1,
    OpStrings.TAUNT2,
    OpStrings.TAUNT3,
    OpStrings.TAUNT4,
    OpStrings.TAUNT5,
    OpStrings.TAUNT6,
    OpStrings.TAUNT7,
    OpStrings.TAUNT8,
}

-----------------
-- Debug Variables
-----------------

------------------------
-- Local Tuning Variables
------------------------

-- What should the player's army unit cap be in each mission?
local M1ArmyCap = 300
local M2ArmyCap = 400
local M3ArmyCap = 500

-- The computer's unit cap
local CybranUnitCap = 1000

-- How many of these are on the map (for a bonus objective)
-- local NumberOfHydrocarbonSpots = 13

-- Various counts of patrols, etc.
if Difficulty == 1 then
    ScenarioInfo.VarTable['M2NorthAirPatrolCount'] = 3
    ScenarioInfo.VarTable['M2SouthAirPatrolCount'] = 1
    ScenarioInfo.VarTable['M2NorthNavalReinforceCount'] = 1
    ScenarioInfo.VarTable['M2EastNavalReinforceCount'] = 1
    ScenarioInfo.VarTable['M2SouthNavalReinforceCount'] = 1
    ScenarioInfo.VarTable['M3WestNavalPatrolCount'] = 1
    ScenarioInfo.VarTable['M3WestAirPatrolCount'] = 1
    ScenarioInfo.VarTable['M3EastNavalPatrolCount'] = 1
    ScenarioInfo.VarTable['M3EastAirPatrolCount'] = 1
elseif Difficulty == 2 then
    ScenarioInfo.VarTable['M2NorthAirPatrolCount'] = 6
    ScenarioInfo.VarTable['M2SouthAirPatrolCount'] = 2
    ScenarioInfo.VarTable['M2NorthNavalReinforceCount'] = 2
    ScenarioInfo.VarTable['M2EastNavalReinforceCount'] = 2
    ScenarioInfo.VarTable['M2SouthNavalReinforceCount'] = 4
    ScenarioInfo.VarTable['M3WestNavalPatrolCount'] = 3
    ScenarioInfo.VarTable['M3WestAirPatrolCount'] = 3
    ScenarioInfo.VarTable['M3EastNavalPatrolCount'] = 3
    ScenarioInfo.VarTable['M3EastAirPatrolCount'] = 3
else
    ScenarioInfo.VarTable['M2NorthAirPatrolCount'] = 12
    ScenarioInfo.VarTable['M2SouthAirPatrolCount'] = 4
    ScenarioInfo.VarTable['M2NorthNavalReinforceCount'] = 4
    ScenarioInfo.VarTable['M2EastNavalReinforceCount'] = 4
    ScenarioInfo.VarTable['M2SouthNavalReinforceCount'] = 8
    ScenarioInfo.VarTable['M3WestNavalPatrolCount'] = 5
    ScenarioInfo.VarTable['M3WestAirPatrolCount'] = 6
    ScenarioInfo.VarTable['M3EastNavalPatrolCount'] = 5
    ScenarioInfo.VarTable['M3EastAirPatrolCount'] = 6
end

-- When 3 values are given for a variable, they
-- apply to Easy, Medium, Hard difficulty in that order

-- Mission 1

-- How long before a scout is sent to fly over the player's base, encouragaing anti-air
local M1ScoutPlayerDelay = { 300, 300, 180 }

-- How long before the wimpy ground forces are sent in, encouraging anti-ground
local M1EarlyAttack1Delay = { 420, 420, 280 }
local M1EarlyAttack2Delay = { 660, 660, 440 }

-- How long after the mission begins before the 'retaliation' attack is sent at the player
local M1AttackPlayerDelay = { 900, 900, 600 }

-- How long to delay the reoccurring attacks against the player from off-map
-- The first attack is half-strength
local M1ReoccurringAttackInitialDelay = { 1200, 1200, 840 }
local M1ReoccurringAttackDelay = { 300, 300, 300 }

-- How long to delay the reminders initially and how much thereafter
local M1P1InitialReminderDelay = 900
local M1P1ReoccuringReminderDelay = 600

-- How much of the city needs to die
local M1DestroyCityGoalPercentage = 80

-- If the attackers are still around after this long, you've weathered the storm
local M1AttackerTimeoutDelay = 600

-- Mission 2

-- The various dialog delays
local M2DialogDelay1 = 10 -- second primary objective
local M2DialogDelay2 = 480 -- advice for how to beat the base

-- These days are after Primary Objective #3 is revealed
local M2DialogDelay3 = 60 -- talk about getting the objective
local M2DialogDelay4 = 120 -- the cruiser will launch soon -- kill it
local M2DialogDelay5 = 180 -- a taunt from the Cybran
local M2DialogDelay6 = 300 -- another taunt

-- The attacks that are sent against the player
local M2ReoccuringNorthAttackInitialDelay = { 120, 120, 30 }
local M2ReoccuringNorthAttackDelay = { 300, 180, 90 }

-- Note: the South initial delay is after the base is revealed, not after mission 2 begins
local M2ReoccuringSouthAttackInitialDelay = { 120, 120, 30 }
local M2ReoccuringSouthAttackDelay = { 300, 180, 90 }

-- The secret base launches a special attack after it is found
local M2RevealAttackDelay = 300

-- The player can lose this many buildings and not lose
local M2CityBuildingsDestroyable = 3
-- This will display as this percentage must survive
local M2CityBuildingsPercentageMustSurvive = 80

-- How long to delay the reminders initially and how much thereafter
local M2P1InitialReminderDelay = 900
local M2P1ReoccuringReminderDelay = 600

-- When will the secret base reveal on its own
local M2SecretBaseTimeoutReveal = 600

-- Mission 3

-- How long to delay the reminders initially and how much thereafter
local M3P2InitialReminderDelay = 300
local M3P2ReoccuringReminderDelay = 600
local M3P4InitialReminderDelay = 300
local M3P4ReoccuringReminderDelay = 600

-- The attacks that are sent against the player
local M3ReoccuringEastAttackInitialDelay = { 600, 300, 90 }
local M3ReoccuringEastAttackDelay = { 600, 300, 90 }
local M3ReoccuringWestAttackInitialDelay = { 180, 180, 45 }
local M3ReoccuringWestAttackDelay = { 600, 300, 90 }

local M3DialogDelay1 = 180
local M3DialogDelay2 = 300
local M3DialogDelay3 = 480
local M3DialogDelay4 = 960

local LeaderFaction
local LocalFaction

-- ##### Starter Functions ######
function OnPopulate(scenario)
    -- Initial Unit Creation
    ScenarioUtils.InitializeScenarioArmies()
    LeaderFaction, LocalFaction = ScenarioFramework.GetLeaderAndLocalFactions()
end

function OnStart(self)

    -- Restrict access to most of the map
    ScenarioFramework.SetPlayableArea('M1_Playable_Area', false)

    -- Set the mission number
    ScenarioInfo.MissionNumber = 1

    -- Add in the base locations for the PBM
    ArmyBrains[Cybran]:PBMAddBuildLocation(ScenarioUtils.MarkerToPosition('M2_Base_North'), 80, 'M2_Base_North')
    ArmyBrains[Cybran]:PBMAddBuildLocation(ScenarioUtils.MarkerToPosition('M2_Base_South'), 80, 'M2_Base_South')
    ArmyBrains[Cybran]:PBMAddBuildLocation(ScenarioUtils.MarkerToPosition('M3_Base_West'), 80, 'M3_Base_West')
    ArmyBrains[Cybran]:PBMAddBuildLocation(ScenarioUtils.MarkerToPosition('M3_Base_East'), 80, 'M3_Base_East')

    -- Define the bases for the different difficulties
    if not ArmyBrains[Cybran].BaseTemplates then
        ArmyBrains[Cybran].BaseTemplates = {}
    end

    ArmyBrains[Cybran].BaseTemplates['M2_North_Base'] = { Template = {}, List = {} }
    ArmyBrains[Cybran].BaseTemplates['M2_South_Base'] = { Template = {}, List = {} }
    ArmyBrains[Cybran].BaseTemplates['M3_West_Base'] = { Template = {}, List = {} }
    ArmyBrains[Cybran].BaseTemplates['M3_East_Base'] = { Template = {}, List = {} }

    if Difficulty == 1 then
        AIBuildStructures.AppendBuildingTemplate(ArmyBrains[Cybran], 'Cybran', 'M2_North_Base_D1', 'M2_North_Base')
        AIBuildStructures.AppendBuildingTemplate(ArmyBrains[Cybran], 'Cybran', 'M2_South_Base_D1', 'M2_South_Base')
        AIBuildStructures.AppendBuildingTemplate(ArmyBrains[Cybran], 'Cybran', 'M3_West_Base_D1', 'M3_West_Base')
        AIBuildStructures.AppendBuildingTemplate(ArmyBrains[Cybran], 'Cybran', 'M3_East_Base_D1', 'M3_East_Base')
        -- AIBuildStructures.AppendBuildingTemplate(ArmyBrains[Cybran], 'Cybran', 'M3_Base_Defenses_D2', 'M2_North_Base')
        -- AIBuildStructures.AppendBuildingTemplate(ArmyBrains[Cybran], 'Cybran', 'M3_Base_Factories_D2', 'M2_North_Base')
        -- AIBuildStructures.AppendBuildingTemplate(ArmyBrains[Cybran], 'Cybran', 'M3_Base_Economy_D2', 'M2_North_Base')
    elseif Difficulty == 2 then
        AIBuildStructures.AppendBuildingTemplate(ArmyBrains[Cybran], 'Cybran', 'M2_North_Base_D2', 'M2_North_Base')
        AIBuildStructures.AppendBuildingTemplate(ArmyBrains[Cybran], 'Cybran', 'M2_South_Base_D2', 'M2_South_Base')
        AIBuildStructures.AppendBuildingTemplate(ArmyBrains[Cybran], 'Cybran', 'M3_West_Base_D2', 'M3_West_Base')
        AIBuildStructures.AppendBuildingTemplate(ArmyBrains[Cybran], 'Cybran', 'M3_East_Base_D2', 'M3_East_Base')
    else
        AIBuildStructures.AppendBuildingTemplate(ArmyBrains[Cybran], 'Cybran', 'M2_North_Base_D3', 'M2_North_Base')
        AIBuildStructures.AppendBuildingTemplate(ArmyBrains[Cybran], 'Cybran', 'M2_South_Base_D3', 'M2_South_Base')
        AIBuildStructures.AppendBuildingTemplate(ArmyBrains[Cybran], 'Cybran', 'M3_West_Base_D3', 'M3_West_Base')
        AIBuildStructures.AppendBuildingTemplate(ArmyBrains[Cybran], 'Cybran', 'M3_East_Base_D3', 'M3_East_Base')
    end


    ScenarioInfo.M1CityBuildingsAlive = 0

    -- Spawn the city that the player needs to destroy
    ScenarioInfo.M1City = ScenarioUtils.CreateArmyGroup('Cybran', 'M1_City')
    for k, unit in ScenarioInfo.M1City do
        ScenarioFramework.CreateUnitDestroyedTrigger(M1CityBuildingDestroyed, unit)
        ScenarioInfo.M1CityBuildingsAlive = ScenarioInfo.M1CityBuildingsAlive + 1
    end

    ScenarioInfo.M1CityBuildingsTotal = ScenarioInfo.M1CityBuildingsAlive

    -- And the defenders of the city
    ScenarioUtils.CreateArmyGroup('Cybran', AdjustForDifficulty('M1_Forces'))

    -- Spawn the groups that will attack the player during M1
    ScenarioInfo.M1Attackers = ScenarioUtils.CreateArmyGroup('Cybran', AdjustForDifficulty('M1_Attackers'))
    ScenarioInfo.M1EarlyAttackers1 = ScenarioUtils.CreateArmyGroup('Cybran', AdjustForDifficulty('M1_First_Attack'))
    ScenarioInfo.M1EarlyAttackers2 = ScenarioUtils.CreateArmyGroup('Cybran', AdjustForDifficulty('M1_Second_Attack'))

    -- Spawn the enemy bases
-- ScenarioUtils.CreateArmyGroup('Cybran', AdjustForDifficulty('M1_Base_Naval_Defenses'))
-- ScenarioUtils.CreateArmyGroup('Cybran', AdjustForDifficulty('M1_Base_Naval_Economy'))
-- ScenarioUtils.CreateArmyGroup('Cybran', AdjustForDifficulty('M1_Base_Naval_Factories'))
-- ScenarioUtils.CreateArmyGroup('Cybran', AdjustForDifficulty('M1_Base_Naval_Misc'))

    -- These used to be capturable for a secondary objective; that was cut
    ScenarioInfo.Extractor1 = ScenarioUtils.CreateArmyUnit('Cybran', 'Extractor1')
    ScenarioInfo.Extractor2 = ScenarioUtils.CreateArmyUnit('Cybran', 'Extractor2')

    -- This override will make sure that the Cybran army doesn't run into the unit cap
    SetArmyUnitCap(Cybran, CybranUnitCap)

    SetIgnorePlayableRect(Cybran, true)
    SetIgnorePlayableRect(NeutralCybran, true)

    ScenarioFramework.SetCybranColor(Cybran)
    -- ScenarioFramework.SetCybranColor(NeutralCybran)
    ScenarioFramework.SetAeonColor(Player)
    local colors = {
        ['Coop1'] = {47, 79, 79}, 
        ['Coop2'] = {46, 139, 87}, 
        ['Coop3'] = {102, 255, 204}
    }
    local tblArmy = ListArmies()
    for army, color in colors do
        if tblArmy[ScenarioInfo[army]] then
            ScenarioFramework.SetArmyColor(ScenarioInfo[army], unpack(color))
        end
    end

    -- Take away units that the player shouldn't have access to
    for _, player in ScenarioInfo.HumanPlayers do
         ScenarioFramework.AddRestriction(player, categories.TECH2 +
                                      categories.TECH3 +
                                      categories.EXPERIMENTAL +
                                      categories.PRODUCTFA + -- All FA Units
                                      categories.uaa0107 ) -- t1 transport
    end

    ScenarioFramework.RestrictEnhancements({'AdvancedEngineering',
                                            'ChronoDampener',
                                            'EnhancedSensors',
                                            'T3Engineering',
                                            'ResourceAllocationAdvanced',
                                            'ShieldHeavy',
                                            'Teleporter',})

    -- Take away units that the computer shouldn't have access to
    ScenarioFramework.AddRestriction(Cybran, categories.TECH3 + categories.EXPERIMENTAL)
    -- remove all tech 2 except for structures and engineers
    ScenarioFramework.AddRestriction(Cybran, categories.TECH2 - categories.STRUCTURE - categories.ENGINEER)

    -- Allow T2 cruiser
    ScenarioFramework.RemoveRestriction(Cybran, categories.urs0202)

    ScenarioInfo.VarTable['Mission1'] = true

    -- Set the maximum number of units that the player is allowed to have

    -- ScenarioInfo.Mission1ObjectiveGroup = Objectives.CreateGroup('Mission 1 Objectives', EndMission1)

    -- Add the objective to kill the city buildings
    ScenarioInfo.M1P1Objective = Objectives.Basic(
        'primary',
        'incomplete',
        OpStrings.M1P1Text,
        LOCF(OpStrings.M1P1Detail, M1DestroyCityGoalPercentage),
        Objectives.GetActionIcon('kill'),
        {
            Units = ScenarioInfo.M1City,
            MarkUnits = true,
        }
   )

    -- ScenarioInfo.M1B1Objective = Objectives.Basic(
    -- 'bonus',
    -- 'incomplete',
    -- OpStrings.M1B1Text,
    -- OpStrings.M1B1Detail,
    -- Objectives.GetActionIcon('build'),
    -- {
    -- }
    -- )

    -- ScenarioInfo.Mission1ObjectiveGroup:AddObjective(ScenarioInfo.M1P1Objective)

    ForkThread(InitialUpdateM1P1)

    ScenarioFramework.Dialogue(ScenarioStrings.NewPObj)

    -- If the player doesn't complete the objective soon, remind him that it's important
    ScenarioFramework.CreateTimerTrigger(M1P1Reminder, M1P1InitialReminderDelay)

    -- Set a scout to fly over the player's base after a delay
    ScenarioFramework.CreateTimerTrigger(M1ScoutPlayer, M1ScoutPlayerDelay[ Difficulty ])

    -- The 'retaliation attack' is suprising players before they build ground defenses,
    -- so we're going to send these little attacks first in order to encourage the player
    -- to build ground defenses.  -DT 10/5/06
    ScenarioFramework.CreateTimerTrigger(M1EarlyAttack1, M1EarlyAttack1Delay[ Difficulty ])
    ScenarioFramework.CreateTimerTrigger(M1EarlyAttack2, M1EarlyAttack2Delay[ Difficulty ])

    -- Set the 'retaliation attack' to launch after a delay
    ScenarioFramework.CreateTimerTrigger(M1AttackPlayer, M1AttackPlayerDelay[ Difficulty ])

    -- Kick off the reoccurring attacks
    ScenarioFramework.CreateTimerTrigger(M1ReoccurringAttack, M1ReoccurringAttackInitialDelay [ Difficulty ])

    -- Trigger the bonus objective when the player has built on all hydrocarbon spots
    -- ScenarioFramework.CreateArmyStatTrigger(AllHydrocarbonBuilt, ArmyBrains[Player], 'HydrocarbonTrigger',
    --                                        {
    --                                            {
    --                                                StatType = 'Units_Active',
    --                                                CompareType = 'GreaterThanOrEqual',
    --                                                Value = NumberOfHydrocarbonSpots,
    --                                                Category = categories.HYDROCARBON,
    --                                            },
    --                                        }
    --                                   )
    ScenarioFramework.StartOperationJessZoom('Start_Camera_Area', CreatePlayer)
    -- Delay opening dialogue a bit, so player is warped in first
    ScenarioFramework.CreateTimerTrigger(OpeningDialogue, 7.6)

    -- These guys will patrol the area around the civilian buildings
    CreateM1Patrol()
end

function CreatePlayer()
    -- Create some of the key units and save handles to them
    ScenarioInfo.PlayerCDR = ScenarioUtils.CreateArmyUnit('Player', 'Commander')
    ScenarioInfo.PlayerCDR:PlayCommanderWarpInEffect()
    ScenarioInfo.PlayerCDR:SetCustomName(ArmyBrains[Player].Nickname)

    -- spawn coop players too
    ScenarioInfo.CoopCDR = {}
    local tblArmy = ListArmies()
    coop = 1
    for iArmy, strArmy in pairs(tblArmy) do
        if iArmy >= ScenarioInfo.Coop1 then
            ScenarioInfo.CoopCDR[coop] = ScenarioUtils.CreateArmyUnit(strArmy, 'Commander')
            ScenarioInfo.CoopCDR[coop]:PlayCommanderWarpInEffect()
            ScenarioInfo.CoopCDR[coop]:SetCustomName(ArmyBrains[iArmy].Nickname)
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
    ScenarioFramework.Dialogue(OpStrings.A02_M01_010)
end

function CreateM1Patrol()
    local patrollers = ScenarioUtils.CreateArmyGroup('Cybran', AdjustForDifficulty('M1_Patrol'))
    IssuePatrol(patrollers, ScenarioUtils.MarkerToPosition('M1_Land_Patrol_01'))
    IssuePatrol(patrollers, ScenarioUtils.MarkerToPosition('M1_Land_Patrol_02'))
    IssuePatrol(patrollers, ScenarioUtils.MarkerToPosition('M1_Land_Patrol_03'))
end

-- Delay this update just a bit so that there isn't a UI error
function InitialUpdateM1P1()
    WaitSeconds(0.5)
    Objectives.UpdateBasicObjective(ScenarioInfo.M1P1Objective, 'progress', LOCF(OpStrings.M1P1Progress,(ScenarioInfo.M1CityBuildingsTotal - ScenarioInfo.M1CityBuildingsAlive) / ScenarioInfo.M1CityBuildingsTotal, M1DestroyCityGoalPercentage))
    -- LOG('progress for M1P1: ', LOCF(OpStrings.M1P1Progress,(ScenarioInfo.M1CityBuildingsTotal - ScenarioInfo.M1CityBuildingsAlive) / ScenarioInfo.M1CityBuildingsTotal, M1DestroyCityGoalPercentage))
end

function M1CityBuildingDestroyed(unit)
    ScenarioInfo.M1CityBuildingsAlive = ScenarioInfo.M1CityBuildingsAlive - 1

    if not ScenarioInfo.M1P1Complete then
        Objectives.UpdateBasicObjective(ScenarioInfo.M1P1Objective, 'progress', LOCF(OpStrings.M1P1Progress, math.floor(((ScenarioInfo.M1CityBuildingsTotal - ScenarioInfo.M1CityBuildingsAlive) / ScenarioInfo.M1CityBuildingsTotal) * 100), M1DestroyCityGoalPercentage))

        if(ScenarioInfo.M1CityBuildingsAlive <(ScenarioInfo.M1CityBuildingsTotal - ScenarioInfo.M1CityBuildingsTotal *(M1DestroyCityGoalPercentage / 100))) then
        LOG("city destroyed")
-- new catalon destroyed
            local citymarker = ScenarioUtils.MarkerToPosition("M1_New_Catalon")
            local camInfo = {
                blendTime = 1.0,
                holdTime = 5,
                orientationOffset = { -2.4, 0.3, 0 },
                positionOffset = { 0, 0, 0 },
                zoomVal = 25,
                markerCam = true,
            }
--        ScenarioFramework.OperationNISCamera(citymarker, camInfo)

            ScenarioInfo.M1P1Complete = true
            -- finish the objective
            ScenarioInfo.M1P1Objective:ManualResult(true)
            -- check to see if both objectives are complete
            LOG("city destroyed")
            LOG(ScenarioInfo.M1P2Complete)
            if ScenarioInfo.M1P2Complete then
                EndMission1()
            end
        end
    end

    -- Removed due to player confusion over the two civilian groups (kill one, protect the other)
    -- if ScenarioInfo.M1CityBuildingsAlive == 0 then
    -- # The player has finished a bonus objective
    -- Objectives.Kill(
    --    'bonus',
    --    'complete',
    --    OpStrings.M1B2Text,
    --    OpStrings.M1B2Detail,
    --    {
    --        Units = ScenarioInfo.M1City,
    --    }
    -- )
    -- end
end

function M1EarlyAttack1()
    for k, PatrolPoint in ScenarioUtils.ChainToPositions('Attack_Route1') do
        IssuePatrol(ScenarioInfo.M1EarlyAttackers1, PatrolPoint)
    end
end

function M1EarlyAttack2()
    for k, PatrolPoint in ScenarioUtils.ChainToPositions('Attack_Route1') do
        IssuePatrol(ScenarioInfo.M1EarlyAttackers2, PatrolPoint)
    end
end

function M1AttackPlayer()
    for k, PatrolPoint in ScenarioUtils.ChainToPositions('Attack_Route1') do
        IssuePatrol(ScenarioInfo.M1Attackers, PatrolPoint)
    end
    -- Tell the player that it's coming
    ScenarioFramework.Dialogue(OpStrings.A02_M01_030)

    ScenarioInfo.M1P2Objective = Objectives.KillOrCapture (
        'primary',
        'incomplete',
        OpStrings.M1P2Text,
        OpStrings.M1P2Detail,
        {
            Units = ScenarioInfo.M1Attackers,
            MarkUnits = false,
        }
   )
    -- check for the odd case where they're dead already
    if ScenarioFramework.GroupDeathCheck(ScenarioInfo.M1Attackers) then
        ForkThread(M1AttackersDestroyed)
        -- Objective will clean up itself now -Matt 8.31.06
    else
        ScenarioInfo.M1P2Objective:AddResultCallback(M1AttackersDestroyed)
        ScenarioFramework.CreateTimerTrigger(M1AttackerTimeout, M1AttackerTimeoutDelay)
    end
    -- ScenarioInfo.Mission1ObjectiveGroup:AddObjective(ScenarioInfo.M1P2Objective)
end

function M1ScoutPlayer()
    local scout = ScenarioUtils.CreateArmyUnit('Cybran', 'M1Scout')
    for k, PatrolPoint in ScenarioUtils.ChainToPositions('Attack_Route1') do
        IssuePatrol({ scout }, PatrolPoint)
    end

    WaitSeconds(7)
    -- Send a second one, just to make more of an impact
    scout = ScenarioUtils.CreateArmyUnit('Cybran', 'M1Scout')
    for k, PatrolPoint in ScenarioUtils.ChainToPositions('Attack_Route1') do
        IssuePatrol({ scout }, PatrolPoint)
    end

    -- Adding land scouts so that the player is encouraged to build anti-ground defenses
    WaitSeconds(30)
    scout = ScenarioUtils.CreateArmyUnit('Cybran', 'M1ScoutLand')
    for k, PatrolPoint in ScenarioUtils.ChainToPositions('Attack_Route1') do
        IssuePatrol({ scout }, PatrolPoint)
    end

    WaitSeconds(7)
    scout = ScenarioUtils.CreateArmyUnit('Cybran', 'M1ScoutLand')
    for k, PatrolPoint in ScenarioUtils.ChainToPositions('Attack_Route1') do
        IssuePatrol({ scout }, PatrolPoint)
    end
end

function M1AttackerTimeout()
    if ScenarioInfo.M1P2Objective.Active then
        -- Back to longhand , unit ManualResult is resolved -Matt 8.25.06
        Objectives.UpdateObjective(ScenarioInfo.M1P2Objective.Title, 'complete', "complete", ScenarioInfo.M1P2Objective.Tag)
        ScenarioInfo.M1P2Objective.Active = false
        ScenarioInfo.M1P2Objective:OnResult(true)
    end
end

function M1AttackersDestroyed()
    -- Tell the player
    ScenarioFramework.Dialogue(OpStrings.A02_M01_040)
    ScenarioInfo.M1P2Complete = true
    if ScenarioInfo.M1P1Complete then
        EndMission1()
    end
end

function M1ReoccurringAttack()
    if ScenarioInfo.MissionNumber == 1 then
        local Transports = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M1_Reoccurring_Transports', 'ChevronFormation')
        local GroundUnits = ScenarioUtils.CreateArmyGroup('Cybran', AdjustForDifficulty('M1_Reoccurring_Ground'))
        local AirUnits = ScenarioUtils.CreateArmyGroup('Cybran', AdjustForDifficulty('M1_Reoccurring_Air'))

        -- The first time the attack comes, make it half-strength
        if not ScenarioInfo.M1ReoccurringAttackFirstTimeFinished then
            ScenarioInfo.M1ReoccurringAttackFirstTimeFinished = true
            local x = 0
            for k, unit in GroundUnits do
                if x == 0 then
                    x = 1
                    unit:Destroy()
                else
                    x = 0
                end
            end
            for k, unit in AirUnits do
                if x == 0 then
                    x = 1
                    unit:Destroy()
                else
                    x = 0
                end
            end
        end


        ScenarioFramework.AttachUnitsToTransports(GroundUnits, Transports:GetPlatoonUnits())

        Transports:UnloadAllAtLocation(ScenarioUtils.MarkerToPosition('M1_Landing_Zone'))
        ForkThread(WaitForUnload, GroundUnits, Transports, AirUnits)

        ScenarioFramework.CreateTimerTrigger(M1ReoccurringAttack, M1ReoccurringAttackDelay [ Difficulty ])
    end
end

function WaitForUnload(GroundUnits, Transports, AirUnits)
    WaitSeconds(2)
    local AllUnloaded = true
    for k, unit in GroundUnits do
        if(not unit:IsDead()) and unit:IsUnitState('Attached') then
            AllUnloaded = false
            break
        end
    end

    if AllUnloaded then
        local myNum = Random(1, 3)
        if myNum == 1 then
            IssueFormAggressiveMove(GroundUnits, ScenarioUtils.MarkerToPosition('Attack_Route1_1'), 'AttackFormation', 0)
            IssuePatrol(GroundUnits, ScenarioUtils.MarkerToPosition('Attack_Route1_2'))
            IssuePatrol(GroundUnits, ScenarioUtils.MarkerToPosition('Attack_Route1_3'))
            IssuePatrol(GroundUnits, ScenarioUtils.MarkerToPosition('Attack_Route1_4'))
        elseif myNum == 2 then
            IssueFormAggressiveMove(GroundUnits, ScenarioUtils.MarkerToPosition('M1_Attack_Route_01'), 'AttackFormation', 0)
            IssuePatrol(GroundUnits, ScenarioUtils.MarkerToPosition('M1_Attack_Route_02'))
            IssuePatrol(GroundUnits, ScenarioUtils.MarkerToPosition('M1_Attack_Route_03'))
            IssuePatrol(GroundUnits, ScenarioUtils.MarkerToPosition('M1_Attack_Route_04'))
            IssuePatrol(GroundUnits, ScenarioUtils.MarkerToPosition('M1_Attack_Route_05'))
        else
            IssueFormAggressiveMove(GroundUnits, ScenarioUtils.MarkerToPosition('M1_Attack_Route_06'), 'AttackFormation', 0)
            IssuePatrol(GroundUnits, ScenarioUtils.MarkerToPosition('M1_Attack_Route_07'))
            IssuePatrol(GroundUnits, ScenarioUtils.MarkerToPosition('M1_Attack_Route_04'))
            IssuePatrol(GroundUnits, ScenarioUtils.MarkerToPosition('M1_Attack_Route_05'))
        end

        local myNum = Random(1, 2)
        if myNum == 1 then
            IssueFormAggressiveMove(AirUnits, ScenarioUtils.MarkerToPosition('Attack_Route1_1'), 'ChevronFormation', 0)
            IssuePatrol(AirUnits, ScenarioUtils.MarkerToPosition('Attack_Route1_2'))
            IssuePatrol(AirUnits, ScenarioUtils.MarkerToPosition('Attack_Route1_3'))
            IssuePatrol(AirUnits, ScenarioUtils.MarkerToPosition('Attack_Route1_4'))
        else
            IssueFormAggressiveMove(AirUnits, ScenarioUtils.MarkerToPosition('M2_South_Naval_Attack_04'), 'ChevronFormation', 0)
            IssuePatrol(AirUnits, ScenarioUtils.MarkerToPosition('M2_South_Naval_Attack_07'))
            IssuePatrol(AirUnits, ScenarioUtils.MarkerToPosition('M1_Attack_Route_03'))
            IssuePatrol(AirUnits, ScenarioUtils.MarkerToPosition('Attack_Route1_3'))
        end

        Transports:MoveToLocation(ScenarioUtils.MarkerToPosition('Transport_Storage'), false)
        WaitSeconds(30)
        for k, unit in Transports:GetPlatoonUnits() do
            if not unit:IsDead() then
                unit:Destroy()
            end
        end
    else
        -- LOG('Still loaded, checking again...')
        WaitSeconds(2)
        WaitForUnload(GroundUnits, Transports, AirUnits)
    end
end

function AllHydrocarbonBuilt()
    ScenarioInfo.M1B1Objective:ManualResult(true)
end

function EndMission1()
    ScenarioFramework.Dialogue(OpStrings.A02_M01_060, BeginMission2)
end

function BeginMission2()
    -- Update the playable area
    ScenarioFramework.SetPlayableArea('M2_Playable_Area')
    ScenarioFramework.Dialogue(ScenarioStrings.MapExpansion)

    ScenarioFramework.Dialogue(OpStrings.A02_M02_010)

    AddTechMission2()

    -- Set the maximum number of units that the player is allowed to have

    -- ScenarioInfo.Mission2ObjectiveGroup = Objectives.CreateGroup('Mission 2 Objectives')

    ScenarioInfo.NorthBase = ScenarioUtils.CreateArmyGroup('Cybran', AdjustForDifficulty('M2_North_Base'))
    ScenarioInfo.SouthBase = ScenarioUtils.CreateArmyGroup('Cybran', AdjustForDifficulty('M2_South_Base'))
    ScenarioInfo.SouthNavalFactory = ScenarioUtils.CreateArmyUnit('Cybran', 'South_Naval_Factory')
    ScenarioInfo.SouthNavalFactory:SetCapturable(false)
    ScenarioInfo.SouthNavalFactory:SetReclaimable(false)

    -- Tag every fifth unit; if the player sees that unit, they will have "spotted the secret base"
    local i = 0
    for k, unit in ScenarioInfo.SouthBase do
        i = i + 1
        if i == 5 then
            i = 0
            ScenarioFramework.CreateArmyIntelTrigger(M2SecretBaseSpotted, ArmyBrains[Player], 'LOSNow', unit, true, categories.ALLUNITS, true, ArmyBrains[ Cybran ])
        end
    end

    ScenarioInfo.M2City = ScenarioUtils.CreateArmyGroup('NeutralCybran', 'M2_City')
    ScenarioInfo.TotalCityUnits = table.getn(ScenarioInfo.M2City)
    ScenarioInfo.CurrentCityUnits = ScenarioInfo.TotalCityUnits

    -- Add the bonus objective to capture the civilians
    -- ScenarioInfo.M2B2Objective = Objectives.Capture(
    -- 'bonus',
    -- 'incomplete',
    -- OpStrings.M2B2Text,
    -- OpStrings.M2B2Detail,
    -- {
    --    Units = ScenarioInfo.M2City,
    -- }
    -- )

    for k, unit in ScenarioInfo.M2City do
        ScenarioFramework.CreateUnitCapturedTrigger(nil, M2CivilianBuildingCaptured, unit)
        ScenarioFramework.CreateUnitDeathTrigger(M2CivilianBuildingKilled, unit)
    end

    -- ScenarioInfo.M2B1Objective = Objectives.Protect(
    -- 'bonus',
    -- 'incomplete',
    -- OpStrings.M2B1Text,
    -- OpStrings.M2B1Detail,
    -- {
    --    Units = ScenarioInfo.M2City,
    --    nil,       # if nil, requires a manual update for completion
    --    NumRequired = ScenarioInfo.TotalCityUnits,    # How many must survive
    -- }
    -- )

    -- Test of whether specified categories are in an area
    ScenarioInfo.M2P1Objective = Objectives.CategoriesInArea(
        'primary',
        'incomplete',
        OpStrings.M2P1Text,
        OpStrings.M2P1Detail,
        'Kill',
        { -- Target
            MarkArea = false,
            ShowFaction = 'Cybran',
            Requirements = {
                {
                    Area = 'M2_North_Base_Area',
                    ArmyIndex = Cybran,
                    Category =(categories.CYBRAN * categories.STRUCTURE) - categories.WALL,
                    CompareOp = '==',
                    Value = 0,
                },
            },
        }
   )
-- obj:AddResultCallback(function(result) LOG('CategoriesInArea Result: ',result) end)
    ScenarioInfo.M2P1Objective:AddResultCallback(M2P1Done)
    -- ScenarioInfo.Mission2ObjectiveGroup:AddObjective(ScenarioInfo.M2P1Objective)

    local PatrolUnits = ScenarioUtils.CreateArmyGroup('Cybran', AdjustForDifficulty('M2_Initial_North_Patrol'))
    ScenarioFramework.GroupPatrolChain(PatrolUnits, 'M2_North_Water_Patrol')

    PatrolUnits = ScenarioUtils.CreateArmyGroup('Cybran', AdjustForDifficulty('M2_Initial_South_Patrol'))
    ScenarioFramework.GroupPatrolChain(PatrolUnits, 'M2_South_Water_Patrol')

    PatrolUnits = ScenarioUtils.CreateArmyGroup('Cybran', AdjustForDifficulty('M2_Initial_East_Patrol'))
    ScenarioFramework.GroupPatrolChain(PatrolUnits, 'M2_East_Water_Patrol')

    ScenarioInfo.M2_South_Attackers = ScenarioUtils.CreateArmyGroup('Cybran', AdjustForDifficulty('M2_Initial_South_Attackers'))
    ScenarioFramework.GroupPatrolChain(ScenarioInfo.M2_South_Attackers, 'M2_South_Water_Patrol')


    ScenarioInfo.MissionNumber = 2
    ScenarioInfo.VarTable['Mission1'] = false
    ScenarioInfo.VarTable['Mission2'] = true

    -- If the player doesn't see the SouthEast base, after a certain amount of time it is revealed anyway
    ScenarioFramework.CreateTimerTrigger(M2SecretBaseTimeout, M2SecretBaseTimeoutReveal)

    ScenarioFramework.CreateTimerTrigger(M2LaunchNorthAttack, M2ReoccuringNorthAttackInitialDelay[ Difficulty ])

    -- Dialog that is delayed from the start of the mission
    ScenarioFramework.CreateTimerTrigger(M2Dialog1, M2DialogDelay1)
    ScenarioFramework.CreateTimerTrigger(M2Dialog2, M2DialogDelay2)

    -- If the player doesn't complete the objective soon, remind him that it's important
    ScenarioFramework.CreateTimerTrigger(M2P1Reminder, M2P1InitialReminderDelay)
end

function M2Dialog1()
    if ScenarioInfo.MissionNumber == 2 then
        ScenarioFramework.Dialogue(OpStrings.A02_M02_020, AddM2P2)
    end
end

function AddM2P2()
    ScenarioInfo.M2P2Objective = Objectives.Basic(
        'primary',
        'incomplete',
        OpStrings.M2P2Text,
        LOCF(OpStrings.M2P2Detail, M2CityBuildingsPercentageMustSurvive),
        Objectives.GetActionIcon('protect'),
        {
            Units = ScenarioInfo.M2City,
            MarkUnits = true,
            NumRequired = ScenarioInfo.TotalCityUnits - M2CityBuildingsDestroyable,    -- How many must survive
        }
   )
    ScenarioInfo.M2P2Objective:AddResultCallback(M2P2Done)
    -- ScenarioInfo.Mission2ObjectiveGroup:AddObjective(ScenarioInfo.M2P2Objective)
    UpdateM2P2() -- this will update the progress field
end

function M2Dialog2()
    if ScenarioInfo.MissionNumber == 2 then
        ScenarioFramework.Dialogue(OpStrings.A02_M02_030)
    end
end

function M2Dialog3()
    if ScenarioInfo.MissionNumber == 2 then
        ScenarioFramework.Dialogue(OpStrings.A02_M02_070)
    end
end

function M2Dialog4()
    if ScenarioInfo.MissionNumber == 2 and not ScenarioInfo.SouthNavalFactory:IsDead() then
        ScenarioFramework.Dialogue(OpStrings.A02_M02_080)

        -- Create the cruiser
        ScenarioInfo.VarTable['LaunchCruiserAttack'] = true
        ScenarioInfo.M2S1Objective = Objectives.Basic(
            'secondary',
            'incomplete',
            OpStrings.M2S1Text,
            OpStrings.M2S1Detail,
            Objectives.GetActionIcon('kill'),
            {
                Units = {ScenarioInfo.SouthNavalFactory},
            } -- Target
       )
    end
end

function M2CruiserBuilt(CruiserPlatoon)
    if ScenarioInfo.M2S1Objective.Active then
        -- Objectives.UpdateBasicObjective(ScenarioInfo.M2S1Objective, 'complete', 'failed')
        -- ScenarioInfo.M2S1Objective.Active = false
        ScenarioInfo.M2S1Objective:ManualResult(false)
        Objectives.UpdateBasicObjective(ScenarioInfo.M2S1Objective, 'description', OpStrings.M2S1Fail)

        ScenarioFramework.Dialogue(OpStrings.A02_M02_090)
        ScenarioInfo.VarTable['AllowSouthReinforce'] = true
    end
end

function M2Dialog5()
    if ScenarioInfo.MissionNumber == 2 then
        ScenarioFramework.Dialogue(OpStrings.A02_M02_110)
    end
end

function M2Dialog6()
    if ScenarioInfo.MissionNumber == 2 then
        ScenarioFramework.Dialogue(OpStrings.A02_M02_120)
    end
end

function M2CivilianBuildingCaptured(unit)
    -- Create a trigger to watch for the new unit's death
    ScenarioFramework.CreateUnitDeathTrigger(M2CivilianBuildingKilled, unit)
end

function M2CivilianBuildingKilled(unit)
    ScenarioInfo.CurrentCityUnits = ScenarioInfo.CurrentCityUnits - 1
    UpdateM2P2()
end

function M2SecretBaseSpotted()
    if not ScenarioInfo.SecretBaseRevealed then
        ScenarioInfo.SecretBaseRevealed = true
        ScenarioFramework.Dialogue(OpStrings.A02_M02_040)
        M2SecretBaseDialogAndObjective()
        ScenarioFramework.CreateTimerTrigger(M2LaunchSouthAttack, M2ReoccuringSouthAttackInitialDelay[ Difficulty ])
    end
end

function M2SecretBaseTimeout()
    if not ScenarioInfo.SecretBaseRevealed then
        ScenarioInfo.SecretBaseRevealed = true
        ScenarioFramework.Dialogue(OpStrings.A02_M02_050)
        M2SecretBaseDialogAndObjective()
        ScenarioFramework.CreateTimerTrigger(M2LaunchSouthAttack, M2ReoccuringSouthAttackInitialDelay[ Difficulty ])
    end
end

function M2SecretBaseDialogAndObjective()
    ScenarioInfo.M2P3Objective = Objectives.CategoriesInArea(
        'primary',
        'incomplete',
        OpStrings.M2P3Text,
        OpStrings.M2P3Detail,
        'Kill',
        { -- Target
            MarkArea = false,
            ShowFaction = 'Cybran',
            Requirements = {
                {
                  Area = 'M2_South_Base_Area',
                  ArmyIndex = Cybran,
                  Category =(categories.CYBRAN * categories.STRUCTURE) - categories.WALL,
                  CompareOp = '==',
                  Value = 0,
                },
            },
        }
   )
    ScenarioInfo.M2P3Objective:AddResultCallback(M2P3Done)
    -- ScenarioInfo.Mission2ObjectiveGroup:AddObjective(ScenarioInfo.M2P3Objective)

    -- ScenarioFramework.Dialogue(ScenarioStrings.NewPObj)

    ScenarioFramework.CreateTimerTrigger(M2Dialog3, M2DialogDelay3)
    ScenarioFramework.CreateTimerTrigger(M2Dialog4, M2DialogDelay4)
    ScenarioFramework.CreateTimerTrigger(M2Dialog5, M2DialogDelay5)
    ScenarioFramework.CreateTimerTrigger(M2Dialog6, M2DialogDelay6)
    ScenarioFramework.CreateTimerTrigger(M2LaunchRevealAttack, M2RevealAttackDelay)
end

function M2LaunchRevealAttack()
    if not ScenarioFramework.GroupDeathCheck(ScenarioInfo.M2_South_Attackers) then
        ScenarioFramework.Dialogue(OpStrings.A02_M02_060)
        -- send a bunch of stuff at the player from the SE
        ScenarioFramework.GroupPatrolChain(ScenarioInfo.M2_South_Attackers, 'M2_South_Naval_Attack')
    end
end

function UpdateM2P2()
    local Total = ScenarioInfo.TotalCityUnits
    local Current = ScenarioInfo.CurrentCityUnits

    -- debug:
    -- if not Total or Total == 0 then LOG('************* Total is ', Total) end
    local PercentageRequired = M2CityBuildingsPercentageMustSurvive
    local PercentageCurrent = 100
    if Total and Total ~= 0 then
        PercentageCurrent = math.floor(Current * 100 / Total)
    end

    if ScenarioInfo.MissionNumber == 2 then
        Objectives.UpdateObjective(OpStrings.M2P2Text, 'progress', LOCF(OpStrings.M2P2Progress, PercentageCurrent, PercentageRequired), ScenarioInfo.M2P2Objective.Tag)
        -- See if the mission has been failed
        if(Total - Current) > M2CityBuildingsDestroyable then
            ScenarioInfo.M2P2Objective:ManualResult(false)
        end
    end
end

-- function EndM2BonusObjective()
-- if ScenarioInfo.M2B1Objective.Active then
--    ScenarioInfo.M2B1Objective:ManualResult(true)
-- end
-- end

function M2P1Done(result)
    if ScenarioInfo.M2P3Objective and not ScenarioInfo.M2P3Objective.Active and
        ScenarioInfo.M2P2Objective and ScenarioInfo.M2P2Objective.Active
    then
        EndMission2()
    end
end

function M2P2Done(result)
    if not result and ScenarioInfo.MissionNumber == 2 then
        -- Let the player know what happened (too many buildings lost) and end the game
        ScenarioFramework.Dialogue(OpStrings.A02_M02_150, false, true)
        ScenarioFramework.PlayerLose()
    end
end

function M2P3Done()
    ScenarioFramework.Dialogue(OpStrings.A02_M02_130)
    if ScenarioInfo.M2P1Objective and not ScenarioInfo.M2P1Objective.Active and
        ScenarioInfo.M2P2Objective and ScenarioInfo.M2P2Objective.Active
    then
        EndMission2()
    end
end

function M2LaunchNorthAttack()
    if ScenarioInfo.MissionNumber == 2 then
        ScenarioInfo.VarTable['LaunchNorthAttack'] = true
        ScenarioFramework.CreateTimerTrigger(M2LaunchNorthAttack, M2ReoccuringNorthAttackDelay[ Difficulty ])
    end
end

function M2LaunchSouthAttack()
    if ScenarioInfo.MissionNumber == 2 then
        ScenarioInfo.VarTable['LaunchSouthAttack'] = true
        ScenarioFramework.CreateTimerTrigger(M2LaunchSouthAttack, M2ReoccuringSouthAttackDelay[ Difficulty ])
    end
end

function M2CreateCruiserDeathTrigger()
    WaitSeconds(0.1)
    ScenarioInfo.Cruiser = ScenarioInfo.SouthNavalFactory.UnitBeingBuilt
    ScenarioFramework.CreateUnitDestroyedTrigger(M2CruiserDeath, ScenarioInfo.Cruiser)
end

function M2CruiserDeath()
    if not ScenarioInfo.CruiserFinished then
        -- IssueClearCommands({ ArmyBrains[Cybran].PBM.Locations['name_of_location'].PrimaryFactories.Sea })
        IssueClearCommands({ ScenarioInfo.SouthNavalFactory })
        -- Success!
        ScenarioInfo.M2S1Objective:ManualResult(true)
        -- Objectives.UpdateBasicObjective(ScenarioInfo.M2S1Objective, 'complete', 'complete')
        -- ScenarioInfo.M2S1Objective.Active = false
        ScenarioFramework.Dialogue(OpStrings.A02_M02_100)
        ScenarioInfo.VarTable['AllowSouthReinforce'] = true
    end
end

function EndMission2()
    ForkThread(BeginMission3)
    if(ScenarioInfo.M2P2Objective and ScenarioInfo.M2P2Objective.Active) then
        ScenarioInfo.M2P2Objective:ManualResult(true)
    end
end

function BeginMission3()

    -- Set the maximum number of units that the player is allowed to have

    -- Spawn the bases
    ScenarioInfo.WestBase = ScenarioUtils.CreateArmyGroup('Cybran', AdjustForDifficulty('M3_West_Base'))
    ScenarioInfo.EastBase = ScenarioUtils.CreateArmyGroup('Cybran', AdjustForDifficulty('M3_East_Base'))

    ScenarioInfo.CybranCommander = ScenarioUtils.CreateArmyUnit('Cybran', 'Commander')
    ScenarioInfo.CybranCommander:SetReclaimable(false)
    ScenarioInfo.CybranCommander:SetCapturable(false)

    IssuePatrol({ ScenarioInfo.CybranCommander }, ScenarioUtils.MarkerToPosition('M3_Commander_Patrol_1'))
    IssuePatrol({ ScenarioInfo.CybranCommander }, ScenarioUtils.MarkerToPosition('M3_Commander_Patrol_2'))

    ScenarioInfo.M3Attackers = ScenarioUtils.CreateArmyGroup('Cybran', AdjustForDifficulty('M3_Attackers'))
    ScenarioInfo.M3Transports = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', AdjustForDifficulty('M3_Transports'), 'ChevronFormation')
    local Scout = ScenarioUtils.CreateArmyUnit('Cybran', 'M1Scout')

    ScenarioFramework.AttachUnitsToTransports(ScenarioInfo.M3Attackers, ScenarioInfo.M3Transports:GetPlatoonUnits())

    ScenarioInfo.M3Transports:UnloadAllAtLocation(ScenarioUtils.MarkerToPosition('M1_Landing_Zone'))

    ForkThread(WaitForUnload, ScenarioInfo.M3Attackers, ScenarioInfo.M3Transports, Scout)


    ScenarioInfo.Mission3ObjectiveGroup = Objectives.CreateGroup('Mission 3 Objectives', PlayerWin)

    ScenarioInfo.M3P1Objective = Objectives.Kill(
        'primary',
        'incomplete',
        OpStrings.M3P1Text,
        OpStrings.M3P1Detail,
        { Units = ScenarioInfo.M3Attackers } -- Targets
   )
    ScenarioInfo.M3P1Objective:AddResultCallback(M3AttackersDestroyed)
    ScenarioInfo.Mission3ObjectiveGroup:AddObjective(ScenarioInfo.M3P1Objective)

    -- Spawn the M3 base adjusted for difficulty, and put all of those units into a single group handle
-- ScenarioInfo.M3_Base = ScenarioUtils.CreateArmyGroup('Aeon', AdjustForDifficulty('M3_Base_Economy'))
--
-- tempUnitGroup = ScenarioUtils.CreateArmyGroup('Aeon', AdjustForDifficulty('M3_Base_Defenses'))
-- tempUnitGroup = ScenarioUtils.CreateArmyGroup('Aeon', AdjustForDifficulty('M3_Base_Factories'))
-- tempUnitGroup = ScenarioUtils.CreateArmyGroup('Aeon', AdjustForDifficulty('M3_Base_Misc'))
--

    ScenarioUtils.CreateArmyGroup('Cybran', AdjustForDifficulty('Artillery_Defenses'))
    ScenarioInfo.Artillery = ScenarioUtils.CreateArmyGroup('NeutralCybran', 'Artillery')

    AddTechMission3()
    ScenarioInfo.MissionNumber = 3
    ScenarioInfo.VarTable['Mission2'] = false
    ScenarioInfo.VarTable['Mission3'] = true

    -- Briefing
    ScenarioFramework.Dialogue(OpStrings.A02_M03_010)

    ScenarioFramework.Dialogue(ScenarioStrings.NewPObj)

    ScenarioFramework.CreateTimerTrigger(M3LaunchWestAttack, M3ReoccuringWestAttackInitialDelay[ Difficulty ])
    ScenarioFramework.CreateTimerTrigger(M3LaunchEastAttack, M3ReoccuringEastAttackInitialDelay[ Difficulty ])

    -- If the player doesn't complete the objectives soon, remind him that it's important
    ScenarioFramework.CreateTimerTrigger(M3P2Reminder, M3P2InitialReminderDelay)
    ScenarioFramework.CreateTimerTrigger(M3P4Reminder, M3P4InitialReminderDelay)

    ScenarioFramework.CreateTimerTrigger(M3Dialog3, M3DialogDelay3)
    ScenarioFramework.CreateTimerTrigger(M3Dialog4, M3DialogDelay4)
end

function M3LaunchWestAttack()
    if ScenarioInfo.MissionNumber == 3 then
        ScenarioInfo.VarTable['LaunchWestAttack'] = true
        ScenarioFramework.CreateTimerTrigger(M3LaunchWestAttack, M3ReoccuringWestAttackDelay[ Difficulty ])
    end
end

function M3LaunchEastAttack()
    if ScenarioInfo.MissionNumber == 3 then
        ScenarioInfo.VarTable['LaunchEastAttack'] = true
        ScenarioFramework.CreateTimerTrigger(M3LaunchEastAttack, M3ReoccuringEastAttackDelay[ Difficulty ])
    end
end

function ArtilleryCapturedOrDestroyed()
    ScenarioInfo.VarTable['LaunchArtilleryAttack'] = true
end

function M3AttackersDestroyed()
    ScenarioFramework.Dialogue(OpStrings.A02_M03_020)
    ScenarioFramework.CreateTimerTrigger(M3Dialog1, M3DialogDelay1)
    ScenarioFramework.CreateTimerTrigger(M3Dialog2, M3DialogDelay2)


    ScenarioInfo.M3P4Objective = Objectives.Kill(
        'primary',
        'incomplete',
        OpStrings.M3P4Text,
        OpStrings.M3P4Detail,
        { Units = { ScenarioInfo.CybranCommander }} -- Target
   )
    ScenarioInfo.M3P4Objective:AddResultCallback(M3CybranCommanderKilled)
    ScenarioInfo.Mission3ObjectiveGroup:AddObjective(ScenarioInfo.M3P4Objective)

    ScenarioInfo.M3P3Objective = Objectives.CategoriesInArea(
        'primary',
        'incomplete',
        OpStrings.M3P3Text,
        OpStrings.M3P3Detail,
        'Kill',
        { -- Target
            MarkArea = false,
            ShowFaction = 'Cybran',
            Requirements = {
                {
                    Area = 'M3_West_Base_Area',
                    ArmyIndex = Cybran,
                    Category =(categories.CYBRAN * categories.STRUCTURE) - categories.WALL,
                    CompareOp = '==', Value=0,
                },
            },
        }
   )
    ScenarioInfo.M3P3Objective:AddResultCallback(M3WestBaseKilled)
    ScenarioInfo.Mission3ObjectiveGroup:AddObjective(ScenarioInfo.M3P3Objective)

    ScenarioInfo.M3P2Objective = Objectives.CategoriesInArea(
        'primary',
        'incomplete',
        OpStrings.M3P2Text,
        OpStrings.M3P2Detail,
        'Kill',
        { -- Target
            MarkArea = false,
            ShowFaction = 'Cybran',
            Requirements = {
                {
                    Area = 'M3_East_Base_Area',
                    ArmyIndex = Cybran,
                    Category =(categories.CYBRAN * categories.STRUCTURE) - categories.WALL,
                    CompareOp = '==', Value=0,
                },
            },
        }
   )
    ScenarioInfo.M3P2Objective:AddResultCallback(M3EastBaseKilled)
    ScenarioInfo.Mission3ObjectiveGroup:AddObjective(ScenarioInfo.M3P2Objective)

    ScenarioInfo.M3S1Objective = Objectives.KillOrCapture(
        'secondary',
        'incomplete',
        OpStrings.M3S1Text,
        OpStrings.M3S1Detail,
        {
            MarkUnits = true,
            Units = ScenarioInfo.Artillery,
        }
   )
    ScenarioInfo.M3S1Objective:AddResultCallback(ArtilleryCapturedOrDestroyed)

    -- Set the playable area
    ScenarioFramework.SetPlayableArea(Rect(0, 0, 512, 512))
    ScenarioFramework.Dialogue(ScenarioStrings.MapExpansion)
end

function M3Dialog1()
    ScenarioFramework.Dialogue(OpStrings.A02_M03_030)
end

function M3Dialog2()
    ScenarioFramework.Dialogue(OpStrings.A02_M03_040)
end

function M3Dialog3()
    if not ScenarioInfo.CybranCommanderDead then
        PlayRandomTaunt()
    end
end

function M3Dialog4()
    if not ScenarioInfo.CybranCommanderDead then
        PlayRandomTaunt()
    end
end

function M3WestBaseKilled()
    ScenarioFramework.Dialogue(OpStrings.A02_M03_050, false, true)
    local unit = ScenarioUtils.MarkerToPosition("M3_Base_West")
    local camInfo = {
        blendTime = 1.0,
        orientationOffset = { 0.15, 0.1, 0 },
        positionOffset = { 0, 0, 0 },
        zoomVal = 35,
        markerCam = true,
    }
    if not ScenarioInfo.M3P2Objective.Active and not ScenarioInfo.M3P4Objective.Active then
-- west base killed and op is over
--    ScenarioFramework.EndOperationCameraLocation(ScenarioUtils.MarkerToPosition("M3_Base_West"))
        camInfo.holdTime = nil
        camInfo.spinSpeed = 0.03
        camInfo.overrideCam = true
        ScenarioFramework.OperationNISCamera(unit, camInfo)
    else
-- west base killed and op not over
        camInfo.holdTime = 6
        ScenarioFramework.OperationNISCamera(unit, camInfo)

        if not ScenarioInfo.M3P2Objective.Active then
            -- The commander death is the last objective left; delay his death for the camera spin
            ScenarioFramework.PauseUnitDeath(ScenarioInfo.CybranCommander)
        end
    end
end

function M3EastBaseKilled()
    ScenarioFramework.Dialogue(OpStrings.A02_M03_060, false, true)
    local unit = ScenarioUtils.MarkerToPosition("M3_Base_East")
    local camInfo = {
        blendTime = 1.0,
        orientationOffset = { -0.6, 0.2, 0 },
        positionOffset = { 0, 0, 0 },
        zoomVal = 35,
        markerCam = true,
    }

    if not ScenarioInfo.M3P3Objective.Active and not ScenarioInfo.M3P4Objective.Active then
-- east base destroyed and the op is over
        camInfo.holdTime = nil
        camInfo.spinSpeed = 0.03
        camInfo.overrideCam = true
        ScenarioFramework.OperationNISCamera(unit, camInfo)
    else
-- east base destroyed and the op isn't over
        camInfo.holdTime = 3.5
        ScenarioFramework.OperationNISCamera(unit, camInfo)

        if not ScenarioInfo.M3P3Objective.Active then
            -- The commander death is the last objective left; delay his death for the camera spin
            ScenarioFramework.PauseUnitDeath(ScenarioInfo.CybranCommander)
        end
    end
end

function M3CybranCommanderKilled()
    -- Commander's death cry
    ScenarioFramework.Dialogue(OpStrings.A02_M03_070, false, true)
    ScenarioInfo.CybranCommanderDead = true
    local unit = ScenarioInfo.CybranCommander
    if not ScenarioInfo.M3P2Objective.Active and not ScenarioInfo.M3P3Objective.Active then
-- cybran cdr death if this is the last objective
--    ScenarioFramework.EndOperationCamera(unit, true)
        ScenarioFramework.CDRDeathNISCamera(unit)
    else
-- cybran cdr death if this is not the last objective
        ScenarioFramework.CDRDeathNISCamera(unit, 7)
    end
end

function AddTechMission2()
    ScenarioFramework.RemoveRestrictionForAllHumans(
        categories.uab0202 + -- T2 Air Factory
        categories.zab9502 + -- T2 Support Air Factory
        categories.uaa0107 + -- T1 Transport
        categories.uaa0204   -- Torpedo Bomber
    )

    -- if needed, add tech that the Cybran get here as well
end

function AddTechMission3()
    ScenarioFramework.RemoveRestrictionForAllHumans(
        categories.ual0208 + -- T2 Engineer
        categories.uab2301 + -- T2 Heavy Gun Tower
        categories.uab2204 + -- T2 Anti-Air Gun Tower
        categories.uab1201 + -- T2 Power Generator
        categories.uab1202   -- T2 Mass Extractor
    )

    -- if needed, add tech that the Cybran get here as well
end

function PlayerCommanderDied(commander)
    ScenarioFramework.PlayerDeath(commander, OpStrings.A02_D01_010)
end

function PlayRandomTaunt()
    if not ScenarioInfo.OpEnded then
        local randomIndex = Random(1, table.getn(TauntTable))
        ScenarioFramework.Dialogue(TauntTable[ randomIndex ])
    end
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
    if ScenarioInfo.M1P1Objective and ScenarioInfo.M1P1Objective.Active and not ScenarioInfo.OpEnded then
        if not ScenarioInfo.M1P1ReminderAlternate then
            ScenarioInfo.M1P1ReminderAlternate = 1
            ScenarioFramework.Dialogue(OpStrings.A02_M01_050)
        elseif ScenarioInfo.M1P1ReminderAlternate == 1 then
            ScenarioInfo.M1P1ReminderAlternate = 2
            ScenarioFramework.Dialogue(OpStrings.A02_M01_055)
        else
            ScenarioInfo.M1P1ReminderAlternate = false
            ScenarioFramework.Dialogue(ScenarioStrings.AeonGenericReminder)
        end
        ScenarioFramework.CreateTimerTrigger(M1P1Reminder, M1P1ReoccuringReminderDelay)
    end
end

function M2P1Reminder()
    if ScenarioInfo.M2P1Objective and ScenarioInfo.M2P1Objective.Active and not ScenarioInfo.OpEnded then
        if not ScenarioInfo.M2P1ReminderAlternate then
            ScenarioInfo.M2P1ReminderAlternate = 1
            ScenarioFramework.Dialogue(OpStrings.A02_M02_140)
        elseif ScenarioInfo.M2P1ReminderAlternate == 1 then
            ScenarioInfo.M2P1ReminderAlternate = 2
            ScenarioFramework.Dialogue(OpStrings.A02_M02_145)
        else
            ScenarioInfo.M2P1ReminderAlternate = false
            ScenarioFramework.Dialogue(ScenarioStrings.AeonGenericReminder)
        end
        ScenarioFramework.CreateTimerTrigger(M2P1Reminder, M2P1ReoccuringReminderDelay)
    end
end

function M3P2Reminder()
    if ScenarioInfo.M3P2Objective and ScenarioInfo.M3P2Objective.Active and not ScenarioInfo.OpEnded then
        if not ScenarioInfo.M3P2ReminderAlternate then
            ScenarioInfo.M3P2ReminderAlternate = 1
            ScenarioFramework.Dialogue(OpStrings.A02_M03_080)
        elseif ScenarioInfo.M3P2ReminderAlternate == 1 then
            ScenarioInfo.M3P2ReminderAlternate = 2
            ScenarioFramework.Dialogue(OpStrings.A02_M03_085)
        else
            ScenarioInfo.M3P2ReminderAlternate = false
            ScenarioFramework.Dialogue(ScenarioStrings.AeonGenericReminder)
        end
        ScenarioFramework.CreateTimerTrigger(M3P2Reminder, M3P2ReoccuringReminderDelay)
    end
end

function M3P4Reminder()
    if ScenarioInfo.M3P4Objective and ScenarioInfo.M3P4Objective.Active and not ScenarioInfo.OpEnded then
        if not ScenarioInfo.M3P4ReminderAlternate then
            ScenarioInfo.M3P4ReminderAlternate = 1
            ScenarioFramework.Dialogue(OpStrings.A02_M03_090)
        elseif ScenarioInfo.M3P4ReminderAlternate == 1 then
            ScenarioInfo.M3P4ReminderAlternate = 2
            ScenarioFramework.Dialogue(OpStrings.A02_M03_095)
        else
            ScenarioInfo.M3P4ReminderAlternate = false
            ScenarioFramework.Dialogue(ScenarioStrings.AeonGenericReminder)
        end
        ScenarioFramework.CreateTimerTrigger(M3P4Reminder, M3P4ReoccuringReminderDelay)
    end
end

----------
-- End Game
----------
function PlayerWin()
    if not ScenarioInfo.OpEnded then
        -- Computer voice saying op complete
        ScenarioFramework.Dialogue(ScenarioStrings.OpComp, false, true)

        -- ForkThread(EndM2BonusObjective)

        -- Turn everything neutral; protect the player commander
        ScenarioFramework.EndOperationSafety()

        -- Celebration dialogue
        ScenarioFramework.Dialogue(OpStrings.A02_M03_100, WinGame, true)
    end
end

function WinGame()
    ScenarioInfo.OpComplete = true
    WaitSeconds(5)
    -- local bonus = Objectives.IsComplete(ScenarioInfo.M1B1Objective) and Objectives.IsComplete(ScenarioInfo.M2B1Objective) and Objectives.IsComplete(ScenarioInfo.M2B2Objective)
    local secondary = Objectives.IsComplete(ScenarioInfo.M2S1Objective) and Objectives.IsComplete(ScenarioInfo.M3S1Objective)
    ScenarioFramework.EndOperation(ScenarioInfo.OpComplete, ScenarioInfo.OpComplete, secondary)
end
