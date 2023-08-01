-- ****************************************************************************
-- **
-- **  File     :  /maps/SCCA_Coop_R04/SCCA_Coop_R04_script.lua
-- **  Author(s):  David Tomandl
-- **
-- **  Summary  :  This is the main file in control of the events during
-- **              Cybran operation 4.
-- **
-- **  Copyright © 2006 Gas Powered Games, Inc.  All rights reserved.
-- ****************************************************************************
local AIBuildStructures = import('/lua/ai/AIBuildStructures.lua')
local Cinematics = import('/lua/cinematics.lua')
local M1AeonAI = import('/maps/SCCA_Coop_R04/SCCA_Coop_R04_m1aeonai.lua')
local M3AeonAI = import('/maps/SCCA_Coop_R04/SCCA_Coop_R04_m3aeonai.lua')
local NukeDamage = import('/lua/sim/NukeDamage.lua').NukeAOE
local Objectives = import('/lua/SimObjectives.lua')
local OpStrings = import('/maps/SCCA_Coop_R04/SCCA_Coop_R04_strings.lua')
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioStrings = import('/lua/ScenarioStrings.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local VizMarker = import('/lua/sim/VizMarker.lua').VizMarker
local Weather = import('/lua/weather.lua')

-- The attacks that are sent against the player
local M2ReoccuringBaseAttackInitialDelay = {240, 240, 60}
local M2ReoccuringBaseAttackDelay = {120, 120, 60}

----------
-- Globals
----------
ScenarioInfo.Player1 = 1
ScenarioInfo.Aeon = 2
ScenarioInfo.Civilian = 3
ScenarioInfo.Neutral = 4
ScenarioInfo.Player2 = 5
ScenarioInfo.Player3 = 6
ScenarioInfo.Player4 = 7

ScenarioInfo.Node3Captured = false
ScenarioInfo.Node4Captured = false
ScenarioInfo.AllNodesCaptured = false
ScenarioInfo.EMPFired = false
ScenarioInfo.MainFrameIsAlive = true
ScenarioInfo.M3BaseDamageWarnings = 0
ScenarioInfo.DisableM3BaseDamagedTriggers = false

---------
-- Locals
---------
local Difficulty = ScenarioInfo.Options.Difficulty

local Player1 = ScenarioInfo.Player1
local Player2 = ScenarioInfo.Player2
local Player3 = ScenarioInfo.Player3
local Player4 = ScenarioInfo.Player4
local Aeon = ScenarioInfo.Aeon
local Civilian = ScenarioInfo.Civilian
local Neutral = ScenarioInfo.Neutral

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

-----------
-- Start up
-----------
function OnPopulate(scenario)
    -- Initial Unit Creation
    ScenarioUtils.InitializeScenarioArmies()
    ScenarioFramework.GetLeaderAndLocalFactions()

    Weather.CreateWeather()

    ----------
    -- Aeon AI
    ----------
    M1AeonAI.AeonM1AirBaseAI()
    M1AeonAI.AeonM1LandBaseAI()
    M1AeonAI.AeonM1NavalBaseAI()

    -- Walls, medium diff, let's not walls off the bases completelly.
    ScenarioUtils.CreateArmyGroup('Aeon', 'M1_Walls_D2')

    -- Eris' ACU
    ScenarioInfo.ErisACU = ScenarioFramework.SpawnCommander('Aeon', 'M1_Commander', false, LOC '{i CDR_Eris}', false, false,
        {'AdvancedEngineering', 'Teleporter', 'EnhancedSensors'})
    ScenarioInfo.ErisACU:SetCanBeKilled(false)
    ScenarioFramework.CreateUnitDamagedTrigger(M1CommanderDefeated, ScenarioInfo.ErisACU, .8)

    ScenarioFramework.RefreshRestrictions('Aeon')

    -- Since there aren't many bases, let's check for building new platoons faster
    ArmyBrains[Aeon]:PBMSetCheckInterval(7)

    -- Initial attacks
    local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M1_Initial_Air_Attack_D' .. Difficulty, 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M1_Air_Attack_Chain_' .. Random(1, 3))

    ---------
    -- Player
    ---------
    local Gate = ScenarioUtils.CreateArmyUnit('Player1', 'Gate')
    Gate:SetReclaimable(false)
    Gate:SetCapturable(false)

    -- Spawn the player's base
    local tempGroup = ScenarioUtils.CreateArmyGroup('Player1', 'Initial_Factories')
    for k, unit in tempGroup do
        local maxHealth = unit:GetMaxHealth()
        local newHealth = maxHealth * (Random(55, 90) / 100)
        unit:SetHealth(unit, newHealth)
    end

    tempGroup = ScenarioUtils.CreateArmyGroup('Player1', 'Initial_Defenses')
    for k, unit in tempGroup do
        if Random(1, 100) < 30 then
            unit:Kill()
        else
            local maxHealth = unit:GetMaxHealth()
            local newHealth = maxHealth * (Random(55, 90) / 100)
            unit:SetHealth(unit, newHealth)
        end
    end

    tempGroup = ScenarioUtils.CreateArmyGroup('Player1', 'Initial_Economy')
    for k, unit in tempGroup do
        local maxHealth = unit:GetMaxHealth()
        local newHealth = maxHealth * (Random(55, 90) / 100)
        unit:SetHealth(unit, newHealth)
    end

    ScenarioFramework.RefreshRestrictions('Player1')

    -------------
    -- Objectives
    -------------
    -- Create the nodes, and make triggers to go off if they die or are captured.
    -- Set them to non-reclaimable, as a convenience
    ScenarioInfo.Node1 = ScenarioUtils.CreateArmyUnit('Neutral', 'Node_1')
    ScenarioInfo.Node1:SetReclaimable(false)
    ScenarioInfo.Node1:SetCustomName(LOC '{i R04_NodeName}')
end

function OnStart(self)
    -- Colors
    ScenarioFramework.SetCybranColor(Player1)
    ScenarioFramework.SetAeonColor(Aeon)
    ScenarioFramework.SetCybranNeutralColor(Civilian)
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

    -- Set the maximum number of units that the player is allowed to have
    ScenarioFramework.SetSharedUnitCap(480)

    -- Disable friendly AI sharing resources to players
    ArmyBrains[Civilian]:SetResourceSharing(false)

    -- Take away units that the player shouldn't have access to
    ScenarioFramework.AddRestrictionForAllHumans(
        categories.PRODUCTFA + -- ALl FA Units
        categories.TECH3 +  -- All T3 units
        categories.EXPERIMENTAL + -- All experimental units
        categories.urb4202 + -- T2 Shield Generator
        categories.urb4204 +
        categories.urb4205 +
        categories.urb4206 +
        categories.urb4207 +
        categories.urb2303 + -- Light Artillery Installation
        categories.urb2108 + -- Tactical Missile Launcher
        categories.ura0104 + -- T2 Transport
        categories.ura0302 + -- Spy Plane
        categories.url0306 + -- Mobile Stealth Generator
        categories.urs0202 + -- Cruiser
        categories.urb4201 + -- T2 Anti-Missile Gun
        categories.daa0206 + -- Mercy
        categories.dra0202 + -- Corsair
        categories.drl0204   -- Hoplite
    )

    -- Allowed AdvancedEngineering, CoolingUpgrade, NaniteTorpedoTube, ResourceAllocation, StealthGenerator
    ScenarioFramework.RestrictEnhancements({
        'MicrowaveLaserGenerator',
        'CloakingGenerator',
        'T3Engineering',
        'Teleporter',
   })

    -- Playable area
    ScenarioFramework.SetPlayableArea('M1_Playable_Area', false)

    -- Zoom in the camera
    ScenarioFramework.StartOperationJessZoom('Start_Camera_Area', IntroMission1)
end

----------
-- End Game
----------
function PlayerWin()
    -- Finish bonus obj to protect civilians
    if ScenarioInfo.M2B1Objective.Active then
        ScenarioInfo.M2B1Objective:ManualResult(true)
    end

    if not ScenarioInfo.OpEnded then
        -- Turn units neutral
        ScenarioFramework.EndOperationSafety()

        -- Computer voice saying op complete
        ForkThread(WinGame)
    end
end

function WinGame()
    WaitSeconds(2)
    local bonus = Objectives.IsComplete(ScenarioInfo.M1B1Objective) and Objectives.IsComplete(ScenarioInfo.M2B1Objective)
    local secondary = Objectives.IsComplete(ScenarioInfo.M2S1Objective)
    ScenarioFramework.EndOperation(true, true, secondary, bonus)
end

function PlayerCommanderDied(deadCommander)
    ScenarioFramework.PlayerDeath(deadCommander, OpStrings.C04_D01_010)
end

------------
-- Mission 1
------------
function IntroMission1()
    ScenarioInfo.MissionNumber = 1

    -- Give initial resources to AI
    ArmyBrains[Aeon]:GiveResource('MASS', 2000)

    -- Delay opening dialogue a bit, so the player commander is fully in.
    ScenarioFramework.CreateTimerTrigger(OpeningDialogue, 4)

    -- Spawn players ACUs
    local tblArmy = ListArmies()
    local i = 1
    while tblArmy[ScenarioInfo['Player' .. i]] do
        ScenarioInfo['Player' .. i .. 'CDR'] = ScenarioFramework.SpawnCommander('Player' .. i, 'Commander', 'Gate', true, true, PlayerCommanderDied)
        IssueMove({ScenarioInfo['Player' .. i .. 'CDR']}, ScenarioUtils.MarkerToPosition('M1_Commander_Walk'))
        IssueMove({ScenarioInfo['Player' .. i .. 'CDR']}, ScenarioUtils.MarkerToPosition('M1_Commander_Destination_' .. i))
        i = i + 1
        WaitSeconds(2)
    end
end

function OpeningDialogue()
    ScenarioFramework.Dialogue(OpStrings.C04_M01_010, StartMission1, true)
end

function StartMission1()
    ScenarioInfo.M1ObjectiveGroup = Objectives.CreateGroup('Mission 1 Objectives', EndMission1, 2)
    --------------------------------
    -- Primary Objective - Kill Eris
    --------------------------------
    ScenarioInfo.M1P1Objective = Objectives.Basic(
        'primary',
        'incomplete',
        OpStrings.M1P1Text,
        OpStrings.M1P1Detail,
        Objectives.GetActionIcon('kill'),
        {
            Units = {ScenarioInfo.ErisACU},
        }
    )
    ScenarioInfo.M1ObjectiveGroup:AddObjective(ScenarioInfo.M1P1Objective)

    --------------------------------
    -- Primary Objective - Capture Node
    --------------------------------
    ScenarioInfo.M1P2Objective = Objectives.Capture(
        'primary',
        'incomplete',
        OpStrings.M1P2Text,
        OpStrings.M1P2Detail,
        {
            Units = {ScenarioInfo.Node1},
            FlashVisible = true,
        }
    )
    ScenarioInfo.M1P2Objective:AddResultCallback(
        function(result, units)
            if result then
                -- record the new handle for the node
                ScenarioInfo.Node1 = units[1]

                -- Track it to see if it ever dies
                ScenarioFramework.CreateUnitDeathTrigger(NodeDied, ScenarioInfo.Node1)
                ScenarioFramework.CreateUnitReclaimedTrigger(NodeDied, ScenarioInfo.Node1)

                -- 1st Node captured camera
                local camInfo = {
                    blendTime = 1.0,
                    holdTime = 4,
                    orientationOffset = {2.8, 0.2, 0},
                    positionOffset = {0, 0.5, 0},
                    zoomVal = 35,
                }
                ScenarioFramework.OperationNISCamera(ScenarioInfo.Node1, camInfo)

                -- Congratulate the player, update the objective
                ScenarioFramework.Dialogue(OpStrings.C04_M01_070)
            else
                NodeDied(ScenarioInfo.Node1)
            end
        end
    )
    ScenarioInfo.M1ObjectiveGroup:AddObjective(ScenarioInfo.M1P2Objective)

    --------------------------------
    -- Bonus Objective - Build units
    --------------------------------
    local num = {280, 340, 400}
    local currentUnitsNum = ScenarioFramework.GetNumOfHumanUnits(categories.ALLUNITS)
    ScenarioInfo.M1B1Objective = Objectives.ArmyStatCompare(
        'bonus',
        'incomplete',
        OpStrings.M1B1Text,
        LOCF(OpStrings.M1B1Detail, num[Difficulty]),
        'build',
        {
            Armies = {'HumanPlayers'},
            StatName = 'Units_History',
            CompareOp = '>=',
            Value = num[Difficulty] + currentUnitsNum,
            Category = categories.ALLUNITS - categories.WALL,
            Hidden = true,
        }
    )

    -- ScenarioFramework.CreateArmyStatTrigger(M1B2Complete, ArmyBrains[Player1], 'B2Trigger',
    -- {{StatType = 'Enemies_Killed', CompareType = 'GreaterThan', Value = 50, Category = categories.ARTILLERY,},})

    -- Dialog that will appear after a certain amount of time
    ScenarioFramework.CreateTimerTrigger(M1Dialogue1, 120)
    ScenarioFramework.CreateTimerTrigger(M1Dialogue2, 360)
    ScenarioFramework.CreateTimerTrigger(M1Dialogue3, 600)
    ScenarioFramework.CreateTimerTrigger(M1Dialogue4, 840)

    -- If the player doesn't complete the objective soon, remind him that it's important
    ScenarioFramework.CreateTimerTrigger(M1P1Reminder, 900)
end

function M1Dialogue1()
    if ScenarioInfo.MissionNumber == 1 and not ScenarioInfo.OpEnded then
        ScenarioFramework.Dialogue(OpStrings.C04_M01_020)
    end
end

function M1Dialogue2()
    if ScenarioInfo.MissionNumber == 1 and not ScenarioInfo.OpEnded then
        ScenarioFramework.Dialogue(OpStrings.C04_M01_030)
    end
end

function M1Dialogue3()
    if ScenarioInfo.MissionNumber == 1 and not ScenarioInfo.OpEnded then
        ScenarioFramework.Dialogue(OpStrings.C04_M01_040)
    end
end

function M1Dialogue4()
    if ScenarioInfo.MissionNumber == 1 and not ScenarioInfo.OpEnded then
        ScenarioFramework.Dialogue(OpStrings.C04_M01_050)
    end
end

function M1CommanderDefeated()
    -- Commander defeated camera
    ScenarioFramework.CDRDeathNISCamera(ScenarioInfo.ErisACU, 7)

    -- play the effects for the commander "escaping"
    ForkThread(ScenarioFramework.FakeTeleportUnit, ScenarioInfo.ErisACU, true)

    -- Dialog
    ScenarioFramework.Dialogue(OpStrings.C04_M01_060)
    ScenarioInfo.M1P1Objective:ManualResult(true)

    -- If the player doesn't complete the objective soon, remind him that it's important
    ScenarioFramework.CreateTimerTrigger(M1P2Reminder, 300)
end

function EndMission1()
    ScenarioFramework.Dialogue(OpStrings.C04_M01_100, IntroMission2, true)
end

------------
-- Mission 2
------------
function IntroMission2()
    ScenarioInfo.MissionNumber = 2

    -- Update the playable area
    ScenarioFramework.SetPlayableArea('M2_Playable_Area')

    -- Set the maximum number of units that the player is allowed to have
    ScenarioFramework.SetSharedUnitCap(660)

    -- Create the Civilian Base
    ScenarioInfo.CivilianBase = ScenarioUtils.CreateArmyGroup('Civilian', 'Civilian_Base')

    -- Create the Civilian structures that need to be protected for the secondary objective
    ScenarioInfo.CivilianStructures = ScenarioUtils.CreateArmyGroup('Civilian', 'Civilian_Structures')

    ScenarioFramework.RemoveRestrictionForAllHumans(
        categories.urb4202 + -- T2 Shield Generator
        categories.urb4204 + -- T2 Shield upgrade 1
        categories.urb4205 + -- T2 Shield upgrade 2
        categories.urb2303 + -- Light Artillery Installation
        categories.ura0104 + -- T2 Transport
        categories.ura0302   -- Spy Plane
    )

    -- Offmap resources for Aeon shields
    ScenarioUtils.CreateArmyGroup('Aeon', 'M2_Offmap_Resources')

    -------------
    -- Objectives
    -------------
    ScenarioInfo.Node2 = ScenarioUtils.CreateArmyUnit('Neutral', 'Node_2')
    ScenarioInfo.Node2:SetReclaimable(false)
    ScenarioInfo.Node2:SetCustomName(LOC '{i R04_NodeName}')
    ScenarioFramework.CreateUnitDeathTrigger(NodeDied, ScenarioInfo.Node2)
    ScenarioFramework.CreateUnitCapturedTrigger(false, Node2Captured, ScenarioInfo.Node2)

    -- Show the civilian base
    local pos = ScenarioInfo.Node2:GetPosition()
    local spec = {
        X = pos[1],
        Z = pos[2],
        Radius = 50,
        LifeTime = .1,
        Omni = false,
        Vision = true,
        Radar = false,
        Army = 1,
   }
    local vizmarker = VizMarker(spec)
    ScenarioInfo.Node2.Trash:Add(vizmarker)
    vizmarker:AttachBoneTo(-1, ScenarioInfo.Node2, -1)

    -- Create area trigger for the player's units that will cause the attackers to spawn in
    for _, player in ScenarioInfo.HumanPlayers do
        ScenarioFramework.CreateAreaTrigger(M2SpawnAttackers, ScenarioUtils.AreaToRect('M2_Trigger_Attack_Area'), categories.ALLUNITS, true, false, ArmyBrains[player], 1)
    end

    -- The distress call comes in
    ScenarioFramework.Dialogue(OpStrings.C04_M02_010, StartMission2, true)
end

function StartMission2()
    ---------------------------------------------
    -- Primary Objective - Defeath Aeon Attackers
    ---------------------------------------------
    ScenarioInfo.M2P1Objective = Objectives.Basic(
        'primary',
        'incomplete',
        OpStrings.M2P1Text,
        OpStrings.M2P1Detail,
        Objectives.GetActionIcon('protect'),
        {
            Units = {ScenarioInfo.Node2},
            MarkUnits = true,
        }
    )

    ------------------------------------------
    -- Secondary Objective - Protect Civilians
    ------------------------------------------
    ScenarioInfo.M2S1Objective = Objectives.Protect(
        'secondary',
        'incomplete',
        OpStrings.M2S1Text,
        LOCF(OpStrings.M2S1Detail, 80),
        {
            Units = ScenarioInfo.CivilianStructures,
            PercentProgress = true,
            NumRequired = math.ceil(table.getn(ScenarioInfo.CivilianStructures) * .8),
        }
    )
    ScenarioInfo.M2S1Objective:AddResultCallback(
        function(result)
            if result then
                ScenarioFramework.Dialogue(OpStrings.C04_M02_040)
            else
                Objectives.UpdateBasicObjective(ScenarioInfo.M2S1Objective, 'description', LOCF(OpStrings.M2S1Fail, 80))
            end
        end
    )

    -------------------------------------------
    -- Bonus Objective - No civilian casualties
    -------------------------------------------
    ScenarioInfo.M2B1Objective = Objectives.Protect(
        'bonus',
        'incomplete',
        OpStrings.M2B1Text,
        OpStrings.M2B1Detail,
        {
            Units = ScenarioInfo.CivilianStructures,
            MarkUnits = false,
            Hidden = true,
        }
    )

    ScenarioFramework.CreateTimerTrigger(M2Dialogue2, 240)
    ScenarioFramework.CreateTimerTrigger(M2Dialogue3, 480)

    ScenarioFramework.CreateTimerTrigger(M2LaunchAttackReoccurring, M2ReoccuringBaseAttackInitialDelay[Difficulty])

    -- If the player doesn't complete the objective soon, remind him that it's important
    ScenarioFramework.CreateTimerTrigger(M2P1Reminder, 300)
end

function M2SpawnAttackers()
    if ScenarioInfo.M2AttackSpawned then
        return
    end
    ScenarioInfo.M2AttackSpawned = true

    -- Spawn the Aeon attackers
    local AeonAttackers = ScenarioUtils.CreateArmyGroup('Aeon', 'M2_Initial_Attackers_D' .. Difficulty)
    ForkThread(M2StartFirstLandAttack, AeonAttackers)

    -- Spawn sea units
    local SeaAttackers = ScenarioUtils.CreateArmyGroup('Aeon', 'M2_Initial_Sea_Attackers_D' .. Difficulty)
    IssueAggressiveMove(SeaAttackers, ScenarioUtils.MarkerToPosition('M3_Air_Attack_11'))

    -- Spawn air units
    local AirAttackers = ScenarioUtils.CreateArmyGroup('Aeon', 'M2_Initial_Air_Attackers_D' .. Difficulty)

    -- Dispatch air units onto several attack/patrol paths for more fun:
    -- bombers have 3 alternative attack moves, scouts/interceptors 2 alternative patrol paths
    local i_AttackPoint = 1
    local i_PatrolPath = 1
    for k, unit in AirAttackers do
        if EntityCategoryContains(categories.BOMBER, unit) then -- If unit is a bomber
            if i_AttackPoint == 1 then
                IssueAggressiveMove({unit}, ScenarioUtils.MarkerToPosition('M3_Air_Attack_07'))
                i_AttackPoint = 2
            elseif i_AttackPoint == 2 then
                IssueAggressiveMove({unit}, ScenarioUtils.MarkerToPosition('M3_Air_Attack_08'))
                i_AttackPoint = 3
            else
                IssueAggressiveMove({unit}, ScenarioUtils.MarkerToPosition('M3_Air_Attack_11'))
                i_AttackPoint = 1
            end
        
        else -- If unit is a scout/interceptor
            if i_PatrolPath == 1 then
                IssuePatrol({unit}, ScenarioUtils.MarkerToPosition('M3_Air_Attack_08'))
                IssuePatrol({unit}, ScenarioUtils.MarkerToPosition('M3_Air_Attack_11'))
                IssuePatrol({unit}, ScenarioUtils.MarkerToPosition('M3_Air_Attack_07'))
                i_PatrolPath = 2
            else
                IssuePatrol({unit}, ScenarioUtils.MarkerToPosition('M3_Air_Attack_07'))
                IssuePatrol({unit}, ScenarioUtils.MarkerToPosition('M3_Air_Attack_11'))
                IssuePatrol({unit}, ScenarioUtils.MarkerToPosition('M3_Air_Attack_08'))
                i_PatrolPath = 1
            end
        end
    end

    for k, unit in SeaAttackers do
        table.insert(AeonAttackers, unit)
    end

    for k, unit in AirAttackers do
        table.insert(AeonAttackers, unit)
    end

    -- And track when they die
    ScenarioFramework.CreateGroupDeathTrigger(M2BaseSaved, AeonAttackers)

    for _, player in ScenarioInfo.HumanPlayers do
        SetAlliance(player, Civilian, 'Ally')
    end
end

function M2StartFirstLandAttack(unitGroup)
    local tbl_entities
    local nb_entities = 0
    
    -- First, make the attackers advance towards west (if they are given the attack order directly,
    -- lots of them will get stuck because of the hill in front of the base)
    IssueMove(unitGroup, ScenarioUtils.MarkerToPosition('M2_Land_Attack_Dest_Point1'))
    
    -- Wait for attackers having passed the hill
    while true do
        tbl_entities = GetUnitsInRect(ScenarioUtils.AreaToRect('M2_StartLand_Attack_Area'))
        nb_entities = 0
        if tbl_entities then
            for k, entity in tbl_entities do
                if EntityCategoryContains(categories.LAND, entity) and entity:GetAIBrain() == ArmyBrains[Aeon] then
                    nb_entities = nb_entities + 1
                end
            end
        end
        
        if nb_entities >= 5 then
            break
        end
        
        WaitSeconds(1)
    end
    
    -- Wait a bit more again...
    WaitSeconds(3)
    
    -- Get the surviving units (some may have died because of the cybran defenses)
    local currentUnitGroup = {}
    for k, v in unitGroup do
        if not v.Dead then
            table.insert(currentUnitGroup, v)
        end
    end
    
    -- Cancel move order, and make them attack. Now this is going to hurt!!!
    if(table.getn(currentUnitGroup) > 0) then
        IssueClearCommands(currentUnitGroup)
        IssuePatrol(currentUnitGroup, ScenarioUtils.MarkerToPosition('Node_2'))
        IssuePatrol(currentUnitGroup, ScenarioUtils.MarkerToPosition('M3_Air_Attack_07'))
        IssuePatrol(currentUnitGroup, ScenarioUtils.MarkerToPosition('M3_Air_Attack_08'))
        IssuePatrol(currentUnitGroup, ScenarioUtils.MarkerToPosition('M3_Air_Attack_11'))
    end
end

function M2LaunchAttackReoccurring()
    -- These attacks are disabled for Easy difficulty
    if ScenarioInfo.MissionNumber == 2 then
        local Attackers = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M2_Base_Attackers_D' .. Difficulty, 'GrowthFormation')
        ScenarioFramework.PlatoonPatrolChain(Attackers, 'M2_Offmap_Attach_Chain_' .. Random(1, 2))
        ScenarioFramework.CreateTimerTrigger(M2LaunchAttackReoccurring, M2ReoccuringBaseAttackDelay[Difficulty])
    end
end

function M2Dialogue2()
    if ScenarioInfo.MissionNumber == 2 and not ScenarioInfo.OpEnded then
        ScenarioFramework.Dialogue(OpStrings.C04_M02_020)
    end
end

function M2Dialogue3()
    if ScenarioInfo.MissionNumber == 2 and not ScenarioInfo.OpEnded then
        ScenarioFramework.Dialogue(OpStrings.C04_M02_030)
    end
end

function M2BaseSaved()
    ScenarioFramework.Dialogue(OpStrings.C04_M02_050)

    -- update objectives
    ScenarioInfo.M2P1Objective:ManualResult(true)

    if ScenarioInfo.M2S1Objective.Active then
        ScenarioInfo.M2S1Objective:ManualResult(true)
    end

    -- Give ally base buildings to the player
    for _, unit in ScenarioInfo.CivilianBase do
        if not unit.Dead and unit:GetArmy() ~= Player1 then
            ScenarioFramework.GiveUnitToArmy(unit, Player1)
        end
    end

    if ScenarioInfo.Node2:GetArmy() ~= Player1 then
        ScenarioInfo.Node2 = ScenarioFramework.GiveUnitToArmy(ScenarioInfo.Node2, Player1)
        ScenarioFramework.CreateUnitDeathTrigger(NodeDied, ScenarioInfo.Node2)
        ScenarioFramework.CreateUnitReclaimedTrigger(NodeDied, ScenarioInfo.Node2)
    end

    --------------------------------------
    -- Primary Objective - Defend the Node
    --------------------------------------
    ScenarioInfo.M2P2Objective = Objectives.Basic(
        'primary',
        'incomplete',
        OpStrings.M2P2Text,
        OpStrings.M2P2Detail,
        Objectives.GetActionIcon('protect'),
        {
            Units = {ScenarioInfo.Node2},
            MarkUnits = true,
        }
    )

    -- Saved station 04
    local camInfo = {
        blendTime = 1.0,
        holdTime = 4,
        orientationOffset = {2.95, 0.2, 0},
        positionOffset = {0, 0.5, 0},
        zoomVal = 30,
    }
    ScenarioFramework.OperationNISCamera(ScenarioInfo.Node2, camInfo)

    ScenarioFramework.CreateTimerTrigger(M2Dialogue4, 120)
    ScenarioFramework.CreateTimerTrigger(M2LaunchWave1, 120)
end

function M2LaunchWave1()
    if ScenarioInfo.MissionNumber ~= 2 then return end -- in case we skipped mission 2 via debug
    local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M2_Wave_1_D' .. Difficulty, 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M2_Air_Attack_City')

    -- trigger to keep track of them
    ScenarioFramework.CreatePlatoonDeathTrigger(M2Wave1Killed, platoon)
end

function M2Wave1Killed()
    if ScenarioInfo.MissionNumber ~= 2 then return end -- in case we skipped mission 2 via debug
    ScenarioFramework.CreateTimerTrigger(M2LaunchWave2, 30)
end

function M2LaunchWave2()
    if ScenarioInfo.MissionNumber ~= 2 then return end -- in case we skipped mission 2 via debug
    local tempGroup = {}
    local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M2_Wave_2_D' .. Difficulty, 'NoFormation')
    ScenarioFramework.PlatoonAttackWithTransports(platoon, 'M2_Landing_Chain', 'M2_Node_Chain', true)
    for _, v in platoon:GetPlatoonUnits() do
        if not EntityCategoryContains(categories.TRANSPORTATION, v) then
            table.insert(tempGroup, v)
        end
    end

    -- trigger to keep track of them
    ScenarioFramework.CreateGroupDeathTrigger(M2Wave2Killed, tempGroup)
end

function M2Wave2Killed()
    if ScenarioInfo.MissionNumber ~= 2 then return end -- in case we skipped mission 2 via debug
    ScenarioFramework.CreateTimerTrigger(M2LaunchWave3, 30)
end

function M2LaunchWave3()
    if ScenarioInfo.MissionNumber ~= 2 then return end -- in case we skipped mission 2 via debug
    local tempGroup = {}
    local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M2_Wave_3_D' .. Difficulty, 'NoFormation')
    ScenarioFramework.PlatoonAttackWithTransports(platoon, 'M2_Landing_Chain', 'M2_Node_Chain', true)
    for _, v in platoon:GetPlatoonUnits() do
        if not EntityCategoryContains(categories.TRANSPORTATION, v) then
            table.insert(tempGroup, v)
        end
    end

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M2_Wave3_Air_D' .. Difficulty, 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M2_Air_Attack_City')
    for _, v in platoon:GetPlatoonUnits() do
        table.insert(tempGroup, v)
    end

    -- trigger to keep track of them
    ScenarioFramework.CreateGroupDeathTrigger(M2Wave3Killed, tempGroup)
end

-- Done with mission 2!
function M2Wave3Killed()
    AssignTransportsToPoll(ArmyBrains[Aeon], 'M3_Transport_Staging_Area')
    ScenarioInfo.M2P2Objective:ManualResult(true)
    ScenarioFramework.Dialogue(OpStrings.C04_M02_070, IntroMission3, true)
end

function M2Dialogue4()
    if ScenarioInfo.MissionNumber == 2 and not ScenarioInfo.OpEnded then
        ScenarioFramework.Dialogue(OpStrings.C04_M02_060)
    end
end

function Node2Captured(newNodeHandle)
    ScenarioInfo.Node2 = newNodeHandle
    ScenarioFramework.CreateUnitDeathTrigger(NodeDied, ScenarioInfo.Node2)
    ScenarioFramework.CreateUnitReclaimedTrigger(NodeDied, ScenarioInfo.Node2)

    -- fix up objective icon, if needed
    if ScenarioInfo.M2P1Objective.Active then
        ScenarioInfo.M2P1Objective:AddBasicUnitTarget (newNodeHandle)
    elseif ScenarioInfo.M2P2Objective.Active then
        ScenarioInfo.M2P2Objective:AddBasicUnitTarget (newNodeHandle)
    end
end

------------
-- Mission 3
------------
function IntroMission3()
    ScenarioInfo.MissionNumber = 3

    -- Set the playable area
    ScenarioFramework.SetPlayableArea('M3_Playable_Area')

    ScenarioFramework.RemoveRestrictionForAllHumans(
        categories.urb4201 + -- T2 Anti-Missile Gun
        categories.url0306   -- Mobile Stealth Generator
    )

    -- Set the maximum number of units that the player is allowed to have
    ScenarioFramework.SetSharedUnitCap(840)

    ----------
    -- Aeon AI
    ----------
    M3AeonAI.AeonM3BaseAI()

    -- Eris ACU
    ScenarioInfo.M3ErisACU = ScenarioFramework.SpawnCommander('Aeon', 'M3_Commander', false, LOC '{i CDR_Eris}', false, false,
        {'AdvancedEngineering', 'Teleporter', 'EnhancedSensors'})
    ScenarioInfo.M3ErisACU:SetDoNotTarget(true) -- prevent auto-targetting until the EMP goes off

    ScenarioFramework.RefreshRestrictions('Aeon')

    -- Walls
    ScenarioUtils.CreateArmyGroup('Aeon', 'M3_Walls_D2')

    -- Set trigger on the base when damaged
    ScenarioInfo.M3_Base = ScenarioFramework.GetCatUnitsInArea(categories.STRUCTURE - categories.WALL, 'Aeon_Base_M3', ArmyBrains[Aeon]) 
    for _, unit in ScenarioInfo.M3_Base do
        if EntityCategoryContains(categories.DEFENSE, unit) then
            unit:SetDoNotTarget(true)
        end
        ScenarioFramework.CreateUnitDamagedTrigger(M3BaseDamaged, unit)
    end
    
    -- include com in units that should not be attacked
    ScenarioFramework.CreateUnitDamagedTrigger(M3BaseDamaged, ScenarioInfo.M3ErisACU)

    -- Patrols
    -- Create the units that will be guarding the NW and NE nodes, and set them patrolling
    ScenarioUtils.CreateArmyGroup('Aeon', 'M3_NW_Defenders_D' .. Difficulty)
    ScenarioUtils.CreateArmyGroup('Aeon', 'M3_NE_Defenders_D' .. Difficulty)

    -- North West
    local units = ScenarioUtils.CreateArmyGroup('Aeon', 'M3_NW_Patrol_Land01_D' .. Difficulty)
    IssuePatrol(units, ScenarioUtils.MarkerToPosition('M3_NW_Patrol_5'))
    IssuePatrol(units, ScenarioUtils.MarkerToPosition('M3_NW_Patrol_6'))

    units = ScenarioUtils.CreateArmyGroup('Aeon', 'M3_NW_Patrol_Naval01_D' .. Difficulty)
    IssuePatrol(units, ScenarioUtils.MarkerToPosition('M3_NW_Patrol_1'))
    IssuePatrol(units, ScenarioUtils.MarkerToPosition('M3_NW_Patrol_2'))

    units = ScenarioUtils.CreateArmyGroup('Aeon', 'M3_NW_Patrol_Naval02_D' .. Difficulty)
    IssuePatrol(units, ScenarioUtils.MarkerToPosition('M3_NW_Patrol_3'))
    IssuePatrol(units, ScenarioUtils.MarkerToPosition('M3_NW_Patrol_4'))

    -- North East
    units = ScenarioUtils.CreateArmyGroup('Aeon', 'M3_NE_Patrol_Land01_D' .. Difficulty)
    IssuePatrol(units, ScenarioUtils.MarkerToPosition('M3_NE_Patrol_1'))
    IssuePatrol(units, ScenarioUtils.MarkerToPosition('M3_NE_Patrol_2'))

    units = ScenarioUtils.CreateArmyGroup('Aeon', 'M3_NE_Patrol_Land02_D' .. Difficulty)
    IssuePatrol(units, ScenarioUtils.MarkerToPosition('M3_NE_Patrol_1'))
    IssuePatrol(units, ScenarioUtils.MarkerToPosition('M3_NE_Patrol_2'))
    IssuePatrol(units, ScenarioUtils.MarkerToPosition('M3_NE_Patrol_3'))
    IssuePatrol(units, ScenarioUtils.MarkerToPosition('M3_NE_Patrol_2'))

    units = ScenarioUtils.CreateArmyGroup('Aeon', 'M3_NE_Patrol_Land03_D' .. Difficulty)
    IssuePatrol(units, ScenarioUtils.MarkerToPosition('M3_NE_Patrol_3'))
    IssuePatrol(units, ScenarioUtils.MarkerToPosition('M3_NE_Patrol_4'))

    units = ScenarioUtils.CreateArmyGroup('Aeon', 'M3_NE_Patrol_Naval01_D' .. Difficulty)
    IssuePatrol(units, ScenarioUtils.MarkerToPosition('M3_NE_Patrol_5'))
    IssuePatrol(units, ScenarioUtils.MarkerToPosition('M3_NE_Patrol_6'))

    units = ScenarioUtils.CreateArmyGroup('Aeon', 'M3_NE_Patrol_Naval02_D' .. Difficulty)
    IssuePatrol(units, ScenarioUtils.MarkerToPosition('M3_NE_Patrol_7'))
    IssuePatrol(units, ScenarioUtils.MarkerToPosition('M3_NE_Patrol_8'))

    -------------
    -- Objectives
    -------------
    -- North West Node
    ScenarioInfo.Node3 = ScenarioUtils.CreateArmyUnit('Neutral', 'Node_3')
    ScenarioInfo.Node3:SetReclaimable(false)
    ScenarioInfo.Node3:SetCustomName(LOC '{i R04_NodeName}')
    ScenarioFramework.CreateUnitDeathTrigger(NodeDied, ScenarioInfo.Node3)
    ScenarioFramework.CreateUnitCapturedTrigger(false, Node3Captured, ScenarioInfo.Node3)

    -- North East Node
    ScenarioInfo.Node4 = ScenarioUtils.CreateArmyUnit('Neutral', 'Node_4')
    ScenarioInfo.Node4:SetReclaimable(false)
    ScenarioInfo.Node4:SetCustomName(LOC '{i R04_NodeName}')
    ScenarioFramework.CreateUnitDeathTrigger(NodeDied, ScenarioInfo.Node4)
    ScenarioFramework.CreateUnitCapturedTrigger(false, Node4Captured, ScenarioInfo.Node4)

    -- Mainframe
    -- Needs to be invincible
    ScenarioInfo.Mainframe = ScenarioUtils.CreateArmyUnit('Neutral', 'Mainframe')
    ScenarioInfo.Mainframe:SetCustomName(LOC '{i R04_MainframeName}')
    ScenarioInfo.Mainframe:SetCanTakeDamage(false)

    -- Show the location of the nodes and mainframe
    ScenarioFramework.CreateVisibleAreaLocation(5, ScenarioInfo.Node3:GetPosition(), 10, ArmyBrains[Player1])
    ScenarioFramework.CreateVisibleAreaLocation(5, ScenarioInfo.Node4:GetPosition(), 10, ArmyBrains[Player1])
    ScenarioFramework.CreateVisibleAreaLocation(5, ScenarioInfo.Mainframe:GetPosition(), 10, ArmyBrains[Player1])

    -- Briefing
    ScenarioFramework.Dialogue(OpStrings.C04_M03_010, StartMission3, true)
end

function StartMission3()
    ScenarioFramework.Dialogue(OpStrings.C04_M03_020, nil, true)

    -----------------------------------
    -- Primary Objective - Capture Node
    -----------------------------------
    ScenarioInfo.M3P1Objective = Objectives.Basic(
        'primary',
        'incomplete',
        OpStrings.M3P1Text,
        OpStrings.M3P1Detail,
        Objectives.GetActionIcon('capture'),
        {
            Units = {ScenarioInfo.Node3},
            MarkUnits = true,
        }
    )

    -----------------------------------
    -- Primary Objective - Capture Node
    -----------------------------------
    ScenarioInfo.M3P2Objective = Objectives.Basic(
        'primary',
        'incomplete',
        OpStrings.M3P2Text,
        OpStrings.M3P2Detail,
        Objectives.GetActionIcon('capture'),
        {
            Units = {ScenarioInfo.Node4},
            MarkUnits = true,
        }
    )

    ----------------------------------------
    -- Primary Objective - Protect Mainframe
    ----------------------------------------
    ScenarioInfo.M3P4Objective = Objectives.Basic(
        'primary',
        'incomplete',
        OpStrings.M3P4Text,
        OpStrings.M3P4Detail,
        Objectives.GetActionIcon('protect'),
        {
            Areas = {'Aeon_Base_M3'},
            ShowFaction = 'Aeon',
        }
    )

    -- Reminder
    ScenarioFramework.CreateTimerTrigger(M3P1Reminder, 900)
end

function M3BaseDamaged(unit)
    -- No more threatening if main frame is already dead, or EMP has been fired!
    if ScenarioInfo.MainFrameIsAlive and not ScenarioInfo.EMPFired then
        
        local playerWarned = false
        local health    = ScenarioInfo.M3ErisACU:GetHealth()
        local maxHealth = ScenarioInfo.M3ErisACU:GetMaxHealth()
        local AeonComHealthPercent = health / maxHealth
        
        -- In case player tries to kill the aeon com without having captured all nodes: If com health is too low, detonate main frame immediatly!
        if AeonComHealthPercent < 0.5 then -- 50%
            -- Disable warnings, as they have no sense anymore
            ScenarioInfo.DisableM3BaseDamagedTriggers = true
            -- Destroy main frame (and lose)
            ForkThread(DetonateMainFrame)
            -- Mark Main frame as dead to stop any form of warning (Actually it's still alive now, but not for long!)
            ScenarioInfo.MainFrameIsAlive = false
        end
        
        if not ScenarioInfo.DisableM3BaseDamagedTriggers then
            ScenarioInfo.DisableM3BaseDamagedTriggers = true
            if ScenarioInfo.M3BaseDamageWarnings == 2 then
                -- Destroy main frame (and lose)
                ForkThread(DetonateMainFrame)
            else
                if ScenarioInfo.M3BaseDamageWarnings == 1 then
                    -- strong warning
                    ScenarioFramework.Dialogue(OpStrings.C04_M03_040)
                else
                    -- weak warning
                    ScenarioFramework.Dialogue(OpStrings.C04_M03_030)
                end
                
                -- camera settings
                local camInfo = {
                    blendTime = 1.0,
                    holdTime = 4,
                    orientationOffset = {-2.78, 0.8, 0},
                    positionOffset = {0, 4, 0},
                    zoomVal = 45,
                    vizRadius = 10,
                }
                
                -- Show the attack
                ScenarioFramework.OperationNISCamera(unit, camInfo)
                ScenarioInfo.M3BaseDamageWarnings = ScenarioInfo.M3BaseDamageWarnings + 1
                playerWarned = true
            end
        end
        
        -- Reenable trigger function for this unit
        ForkThread(EnableM3BaseDamagedTriggersAfterDelay, unit, playerWarned)
    end
end

function EnableM3BaseDamagedTriggersAfterDelay(unit, playerWarned)
    if not unit.Dead then
        ScenarioFramework.CreateUnitDamagedTrigger(M3BaseDamaged, unit)
    end
    
    if playerWarned then
        WaitSeconds(15)
        ScenarioInfo.DisableM3BaseDamagedTriggers = false
    end
end

function DetonateMainFrame()
    -- Mainfram destroyed cam values
    local camInfo = {
        blendTime = 2.0,
        holdTime = nil,
        orientationOffset = {math.pi, 0.8, 0},
        positionOffset = {0, 4, 0},
        spinSpeed = 0.03,
        zoomVal = 45,
        overrideCam = true,
        vizRadius = 30,
   }
        
    -- "Do not attack" objective failed
    ScenarioInfo.M3P4Objective:ManualResult(false)
    
    while ScenarioInfo.DialogueLock do
        WaitTicks(1)
    end
    
    -- Zoom on main frame
    ScenarioFramework.OperationNISCamera(ScenarioInfo.Mainframe, camInfo)
    
    -- Wait for the camera move, and detonate main frame
    WaitSeconds(3)
    ScenarioInfo.Mainframe:Kill()
    
    -- player loses
    WaitSeconds(1)
    ScenarioFramework.PlayerLose(OpStrings.C04_M03_050)
end

-- Northwest node
function Node3Captured(newNodeHandle)
    ScenarioInfo.Node3 = newNodeHandle
    ScenarioInfo.Node3Captured = true
    ScenarioFramework.CreateUnitDeathTrigger(NodeDied, ScenarioInfo.Node3)
    ScenarioFramework.CreateUnitReclaimedTrigger(NodeDied, ScenarioInfo.Node3)

    ScenarioInfo.M3P1Objective:ManualResult(true)

    ScenarioFramework.Dialogue(OpStrings.C04_M03_060, false, true)

    if ScenarioInfo.Node3Captured and ScenarioInfo.Node4Captured then
        ForkThread(AllNodesCaptured)
    else
        ScenarioFramework.Dialogue(OpStrings.C04_M03_063)
    end

    -- NW Node captured camera
    local camInfo = {
        blendTime = 1.0,
        holdTime = 4,
        orientationOffset = {-1.38, 0.3, 0},
        positionOffset = {0, 0.5, 0},
        zoomVal = 35,
    }
    ScenarioFramework.OperationNISCamera(ScenarioInfo.Node3, camInfo)
end

function Node4Captured(newNodeHandle)
    ScenarioInfo.Node4 = newNodeHandle
    ScenarioInfo.Node4Captured = true
    ScenarioFramework.CreateUnitDeathTrigger(NodeDied, ScenarioInfo.Node4)
    ScenarioFramework.CreateUnitReclaimedTrigger(NodeDied, ScenarioInfo.Node4)

    ScenarioInfo.M3P2Objective:ManualResult(true)

    ScenarioFramework.Dialogue(OpStrings.C04_M03_065, false, true)

    if ScenarioInfo.Node3Captured and ScenarioInfo.Node4Captured then
        ForkThread(AllNodesCaptured)
    else
        ScenarioFramework.Dialogue(OpStrings.C04_M03_063)
    end

    -- NE Node captured camera
    local camInfo = {
        blendTime = 1.0,
        holdTime = 4,
        orientationOffset = {0.3927, 0.1, 0},
        positionOffset = {0, 2, 0},
        zoomVal = 40,
    }
    ScenarioFramework.OperationNISCamera(ScenarioInfo.Node4, camInfo)
end

function AllNodesCaptured()
    ScenarioInfo.AllNodesCaptured = true

    -- Stop the reminder text from playing
    ScenarioInfo.M3P1Complete = true

    ScenarioFramework.Dialogue(OpStrings.C04_M03_070, AllNodesCapturedPart2, true)
end

function AllNodesCapturedPart2()
    if ScenarioInfo.M3ErisACU.Dead then
        ForkThread(PlayerWin)
    else
        ScenarioFramework.CreateTimerTrigger(EMPTriggered, 30)
    end
end

function EMPTriggered()
    --------------------------------
    -- Primary Objective - Kill Eris
    --------------------------------
    ScenarioInfo.M3P3Objective = Objectives.Kill(
        'primary',
        'incomplete',
        OpStrings.M3P3Text,
        OpStrings.M3P3Detail,
        {
            Units = {ScenarioInfo.M3ErisACU},
        }
    )
    ScenarioInfo.M3P3Objective:AddResultCallback(
        function(result)
            if result then                
                -- Skip this if EMP has not been fired (in this case, the aeon destroys main frame and player loses)
                if ScenarioInfo.EMPFired then
                    -- Spin the camera around the explosion
                    -- ScenarioFramework.EndOperationCamera(ScenarioInfo.M3ErisACU, true)
                    ScenarioFramework.CDRDeathNISCamera(ScenarioInfo.M3ErisACU)

                    -- Aeon commander's death cry
                    ScenarioFramework.Dialogue(OpStrings.C04_M03_095, false, true)

                    -- Stop the reminder text from playing
                    ScenarioInfo.M3P3Complete = true

                    if ScenarioInfo.AllNodesCaptured then
                        PlayerWin()
                    end
                end
            end
        end
    )
    
    -- Now it's legitimate to kill commander, delay the explosion so we can watch it on camera
    ScenarioFramework.PauseUnitDeath(ScenarioInfo.M3ErisACU)

    ScenarioInfo.M3P4Objective:ManualResult(true)
    -- If the player doesn't complete the objective soon, remind him that it's important
    ScenarioFramework.CreateTimerTrigger(M3P3Reminder, 300)

    -- Show the base
    local pos = ScenarioInfo.Mainframe:GetPosition()
    local spec = {
        X = pos[1],
        Z = pos[2],
        Radius = 50,
        LifeTime = 30,
        Omni = false,
        Vision = true,
        Radar = false,
        Army = 1,
   }
    local vizmarker = VizMarker(spec)
    ScenarioInfo.Mainframe.Trash:Add(vizmarker)
    vizmarker:AttachBoneTo(-1, ScenarioInfo.Mainframe, -1)

    -- Spawn the effect
    local myproj = ScenarioInfo.Mainframe:CreateProjectile('/projectiles/CIFEMPFluxWarhead02/CIFEMPFluxWarhead02_proj.bp', 0, 0, 0, nil, nil, nil):SetCollision(false)
    -- This effect is a neutered nuke, so set the damage to zero
    myproj.InnerRing = NukeDamage()
    myproj.InnerRing:OnCreate(1, 1, 1, 1)
    myproj.OuterRing = NukeDamage()
    myproj.OuterRing:OnCreate(1, 1, 1, 1)
    
    -- Do nuke effect
    myproj:ForkThread(myproj.EffectThread)
    
    -- BOOM!!!
    myproj:OnImpact('Terrain', nil)

    -- set off the EMP -- all Aeon units in the base get stunned
    -- except for air units and shields, which just die
    local AeonUnits = GetUnitsInRect(ScenarioUtils.AreaToRect('Aeon_Base_M3'))
    local StunDuration = {600, 450, 300}
    for k, unit in AeonUnits do
        if EntityCategoryContains(categories.AEON * categories.AIR - categories.STRUCTURE, unit) or EntityCategoryContains(categories.AEON * categories.uab4202, unit) then
            unit:Kill()
        elseif EntityCategoryContains(categories.AEON - categories.uab5101, unit) then
            unit:SetStunned(StunDuration[Difficulty])
            unit:SetDoNotTarget(false)
        end
    end

    ScenarioFramework.Dialogue(OpStrings.C04_M03_080)
    ScenarioFramework.CreateTimerTrigger(M3Dialogue5, 240)

    -- Allow the player to attack the main base now
    ScenarioInfo.DisableM3BaseDamagedTriggers = true
    ScenarioInfo.EMPFired = true

    -- Turn auto-targetting back on
    ScenarioInfo.M3ErisACU:SetDoNotTarget(false)

    -- Show the mainframe for emp event
    local camInfo = {
        blendTime = 1.0,
        holdTime = 8,
        orientationOffset = {-2.78, 0.8, 0},
        positionOffset = {0, 4, 0},
        zoomVal = 45,
   }
    ScenarioFramework.OperationNISCamera(ScenarioInfo.Mainframe, camInfo)
end

function M3Dialogue5()
    if not ScenarioInfo.M3ErisACU.Dead and not ScenarioInfo.OpEnded then
        ScenarioFramework.Dialogue(OpStrings.C04_M03_090)
    end
end

function NodeDied(unit)
    -- Let the player know what happened
    -- And end the game

    if ScenarioInfo.M1P2Objective.Active then
        ScenarioInfo.M1P2Objective:ManualResult(false)
    elseif ScenarioInfo.M2P1Objective.Active then
        ScenarioInfo.M2P1Objective:ManualResult(false)
    elseif ScenarioInfo.M2P2Objective.Active then
        ScenarioInfo.M2P2Objective:ManualResult(false)
    end

    -- set base camera values if a node dies
    local camInfo = {
        blendTime = 2.5,
        holdTime = nil,
        spinSpeed = 0.03,
        overrideCam = true,
    }
    if unit == ScenarioInfo.Node1 then
        camInfo.orientationOffset = {math.pi, 0.2, 0}
        camInfo.positionOffset = {0, 0.5, 0}
        camInfo.zoomVal = 35
    elseif unit == ScenarioInfo.Node2 then
        camInfo.orientationOffset = {math.pi, 0.2, 0}
        camInfo.positionOffset = {0, 0.5, 0}
        camInfo.zoomVal = 30
    elseif unit == ScenarioInfo.Node3 then
        camInfo.orientationOffset = {math.pi, 0.3, 0}
        camInfo.positionOffset = {0, 1, 0}
        camInfo.zoomVal = 30
    elseif unit == ScenarioInfo.Node4 then
        camInfo.orientationOffset = {math.pi, 0.1, 0}
        camInfo.positionOffset = {0, 2, 0}
        camInfo.zoomVal = 40
    end
    ScenarioFramework.OperationNISCamera(unit, camInfo)
    ScenarioFramework.PlayerLose(OpStrings.C04_M01_110)
end

------------
-- Reminders
------------
function M1P1Reminder()
    if ScenarioInfo.M1P1Objective.Active and not ScenarioInfo.OpEnded then
        if not ScenarioInfo.M1P1ReminderAlternate then
            ScenarioInfo.M1P1ReminderAlternate = 1
            ScenarioFramework.Dialogue(OpStrings.C04_M01_080)
        elseif ScenarioInfo.M1P1ReminderAlternate == 1 then
            ScenarioInfo.M1P1ReminderAlternate = 2
            ScenarioFramework.Dialogue(OpStrings.C04_M01_085)
        else
            ScenarioInfo.M1P1ReminderAlternate = false
            ScenarioFramework.Dialogue(ScenarioStrings.CybranGenericReminder)
        end
        ScenarioFramework.CreateTimerTrigger(M1P1Reminder, 600)
    end
end

function M1P2Reminder()
    if ScenarioInfo.M1P2Objective.Active and not ScenarioInfo.OpEnded then
        if not ScenarioInfo.M1P2ReminderAlternate then
            ScenarioInfo.M1P2ReminderAlternate = 1
            ScenarioFramework.Dialogue(OpStrings.C04_M01_090)
        elseif ScenarioInfo.M1P2ReminderAlternate == 1 then
            ScenarioInfo.M1P2ReminderAlternate = 2
            ScenarioFramework.Dialogue(OpStrings.C04_M01_095)
        else
            ScenarioInfo.M1P2ReminderAlternate = false
            ScenarioFramework.Dialogue(ScenarioStrings.CybranGenericReminder)
        end
        ScenarioFramework.CreateTimerTrigger(M1P2Reminder, 600)
    end
end

function M2P1Reminder()
    if ScenarioInfo.M2P1Objective.Active and not ScenarioInfo.OpEnded then
        if not ScenarioInfo.M2P1ReminderAlternate then
            ScenarioInfo.M2P1ReminderAlternate = 1
            ScenarioFramework.Dialogue(OpStrings.C04_M02_080)
        elseif ScenarioInfo.M2P1ReminderAlternate == 1 then
            ScenarioInfo.M2P1ReminderAlternate = 2
            ScenarioFramework.Dialogue(OpStrings.C04_M02_085)
        else
            ScenarioInfo.M2P1ReminderAlternate = false
            ScenarioFramework.Dialogue(ScenarioStrings.CybranGenericReminder)
        end
        ScenarioFramework.CreateTimerTrigger(M2P1Reminder, 600)
    end
end

function M3P1Reminder()
    if ScenarioInfo.M3P1Objective.Active and not ScenarioInfo.OpEnded then
        if not ScenarioInfo.M3P1ReminderAlternate then
            ScenarioInfo.M3P1ReminderAlternate = 1
            ScenarioFramework.Dialogue(OpStrings.C04_M03_100)
        elseif ScenarioInfo.M3P1ReminderAlternate == 1 then
            ScenarioInfo.M3P1ReminderAlternate = 2
            ScenarioFramework.Dialogue(OpStrings.C04_M03_105)
        else
            ScenarioInfo.M3P1ReminderAlternate = false
            ScenarioFramework.Dialogue(ScenarioStrings.CybranGenericReminder)
        end
        ScenarioFramework.CreateTimerTrigger(M3P1Reminder, 600)
    end
end

function M3P3Reminder()
    if ScenarioInfo.M3P3Objective.Active and not ScenarioInfo.OpEnded then
        if not ScenarioInfo.M3P3ReminderAlternate then
            ScenarioInfo.M3P3ReminderAlternate = 1
            ScenarioFramework.Dialogue(OpStrings.C04_M03_110)
        elseif ScenarioInfo.M3P3ReminderAlternate == 1 then
            ScenarioInfo.M3P3ReminderAlternate = 2
            ScenarioFramework.Dialogue(OpStrings.C04_M03_115)
        else
            ScenarioInfo.M3P3ReminderAlternate = false
            ScenarioFramework.Dialogue(ScenarioStrings.CybranGenericReminder)
        end
        ScenarioFramework.CreateTimerTrigger(M3P3Reminder, 600)
    end
end

-------------------
-- Custom Functions
-------------------
function AssignTransportsToPoll(brain, moveMarker)
    local pool = brain:GetPlatoonUniquelyNamed('TransportPool')
    if not pool then
        pool = brain:MakePlatoon('None', 'None')
        pool:UniquelyNamePlatoon('TransportPool')
    end
    local poolUnits = pool:GetPlatoonUnits()
    local transports = brain:GetListOfUnits(categories.TRANSPORTATION - categories.uea0203, false)
    for _, transport in transports do
        local found = false
        for _, unit in poolUnits do
            if transport == unit then
                found = true
                break
            end
        end
        if not found then
            if moveMarker then
                IssueMove({transport}, ScenarioUtils.MarkerToPosition(moveMarker))
            end
            brain:AssignUnitsToPlatoon('TransportPool', {transport}, 'Scout', 'None')
        end
    end
end

------------------
-- Debug Functions
------------------
--[[
function OnCtrlF4()
    if ScenarioInfo.MissionNumber == 1 then
        M1CommanderDefeated()

        for _, v in ArmyBrains[Aeon]:GetListOfUnits(categories.ALLUNITS - categories.WALL, false) do
            v:Kill()
        end
    end
end

local i = 1
function OnShiftF4()
    if i == 1 then
        M2LaunchWave2()
        i = i + 1
    else
        M2LaunchWave3()
    end
end
--]]

