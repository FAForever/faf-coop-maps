-- ****************************************************************************
-- **
-- **  File     :  /maps/SCCA_Coop_A06/SCCA_Coop_A06_script.lua
-- **  Author(s):  David Tomandl
-- **
-- **  Summary  :  This is the main file in control of the events during
-- **              operation A6.
-- **
-- **  Copyright © 2006 Gas Powered Games, Inc.  All rights reserved.
-- ****************************************************************************

local Cinematics = import('/lua/cinematics.lua')
local CustomFunctions = import('/maps/SCCA_Coop_A06/SCCA_Coop_A06_CustomFunctions.lua')
local M2CybranAI = import('/maps/SCCA_Coop_A06/SCCA_Coop_A06_m2cybranai.lua')
local M3AeonAI = import('/maps/SCCA_Coop_A06/SCCA_Coop_A06_m3aeonai.lua')
local Objectives = import('/lua/SimObjectives.lua')
local OpStrings = import ('/maps/SCCA_Coop_A06/SCCA_Coop_A06_strings.lua')
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioStrings = import('/lua/ScenarioStrings.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local Weather = import('/lua/Weather.lua')

----------
-- Globals
----------
ScenarioInfo.Player1 = 1
ScenarioInfo.UEF = 2
ScenarioInfo.Cybran = 3
ScenarioInfo.Aeon = 4
ScenarioInfo.Neutral = 5
ScenarioInfo.Player2 = 6
ScenarioInfo.Player3 = 7
ScenarioInfo.Player4 = 8

---------
-- Locals
---------
local Player1 = ScenarioInfo.Player1
local Player2 = ScenarioInfo.Player2
local Player3 = ScenarioInfo.Player3
local Player4 = ScenarioInfo.Player4
local UEF = ScenarioInfo.UEF
local Cybran = ScenarioInfo.Cybran
local Aeon = ScenarioInfo.Aeon
local Neutral = ScenarioInfo.Neutral

local Difficulty = ScenarioInfo.Options.Difficulty

local LeaderFaction
local LocalFaction

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

--local numStaticNukes = {2, 2, 3}
local NukeSettings = {
    ActivationTimer = 5 * 60,
    DelayBetweenSalvos = {15 * 60, 11 * 60, 7 * 60},
    LaunchersFilter = categories.STRUCTURE,
    MissileProduction = false,
    MissilesPerSalvo = 3,
    SalvoDelay = {4, 14},
    SingleTarget = false,
    Retry = true,
    TargetCategories = (categories.TECH2 * categories.STRUCTURE) + (categories.TECH3 * categories.STRUCTURE),
    TargetChain = 'M3_Nuke_Chain',
}

-------------
-- Debug Only
-------------
local SkipIntroDialogue = false
local SkipM1NavalAttack = false

-----------
-- Start up
-----------
function OnPopulate(scenario)
    -- Initial Unit Creation
    ScenarioUtils.InitializeScenarioArmies()
    LeaderFaction, LocalFaction = ScenarioFramework.GetLeaderAndLocalFactions()

    Weather.CreateWeather()

    -- Players
    local tblArmy = ListArmies()
    for i = 1, 3 do
        local units = ScenarioUtils.CreateArmyGroup("Player1", "Player" .. i .. "_Base")
        if i >= 2 and tblArmy[ScenarioInfo["Player"..i]] then
            for _, unit in units do
                ScenarioFramework.GiveUnitToArmy(unit, "Player"..i)
            end
        end
    end

    -- Spawn the enemy bases
    ScenarioUtils.CreateArmyGroup('UEF', 'M1_Defenses_D' .. Difficulty)
    ScenarioUtils.CreateArmyGroup('UEF', 'M1_Walls')
    -- Offmap resources
    ScenarioInfo.M1UEFOffmapResources = ScenarioUtils.CreateArmyGroup('UEF', 'M1_Offmap_Resources')

    -- Spawn the mobile patrollers, watch for when they die
    local AirDefense = ScenarioUtils.CreateArmyGroup('UEF', 'M1_Air_Defense_D' .. Difficulty)
    for _, v in AirDefense do
        ScenarioFramework.GroupPatrolChain({v}, 'M1_Air_Defense')
    end
    ScenarioFramework.CreateGroupDeathTrigger(M1RespawnAirDefense, AirDefense)

    local count = {1, 1, 2}
    for i = 1, count[Difficulty] do
        local GroundDefense = ScenarioUtils.CreateArmyGroup('UEF', 'M1_Ground_Defense_D' .. Difficulty)
        ScenarioFramework.GroupPatrolChain(GroundDefense, 'M1_Ground_Defense')
        ScenarioFramework.CreateGroupDeathTrigger(M1RespawnGroundDefense, GroundDefense)
    end

    ------------
    -- Objective
    ------------
    -- The control center that the player will be attempting to capture
    ScenarioInfo.BlackSunControlCenter = ScenarioUtils.CreateArmyUnit('Neutral', 'Black_Sun_Control_Center')
    ScenarioInfo.BlackSunControlCenter:SetCustomName(LOC '{i BlackSunControlTower}')
    ScenarioInfo.BlackSunControlCenter:SetReclaimable(false)
    ScenarioInfo.BlackSunControlCenter:SetDoNotTarget(true)
end

function OnStart(self)
    -- Arny Colors
    ScenarioFramework.SetCybranColor(Cybran)
    ScenarioFramework.SetUEFColor(UEF)
    ScenarioFramework.SetUEFColor(Neutral)
    ScenarioFramework.SetArmyColor(Aeon, 32, 32, 32)
    ScenarioFramework.SetAeonColor(Player1)
    local colors = {
        ['Player2'] = {47, 79, 79}, 
        ['Player3'] = {46, 139, 87}, 
        ['Player4'] = {102, 255, 204}
    }
    local tblArmy = ListArmies()
    for army, color in colors do
        if tblArmy[ScenarioInfo[army]] then
            ScenarioFramework.SetArmyColor(ScenarioInfo[army], unpack(color))
        end
    end

    -- Take away units that the player shouldn't have access to
    ScenarioFramework.AddRestrictionForAllHumans(
        categories.uab0304 +   -- Quantum Gate
        categories.ual0301 +   -- Sub Commander
        categories.ual0401 +   -- Giant Assault Bot
        categories.uas0401 +   -- Submersible Battleship
        categories.uas0304 +   -- Strategic Missile Submarine
        categories.PRODUCTFA + -- All FA Units
        categories.daa0206 +   -- Mercy
        categories.dal0310 +   -- Absolver
        categories.dalk003 +   -- T3 Mobile AA
        categories.uaa0310     -- Death Saucer
    )

    -- Set the maximum number of units that the player is allowed to have
    ScenarioFramework.SetSharedUnitCap(1000)

    -- Restrict access to most of the map
    ScenarioFramework.SetPlayableArea('M1_Playable_Area', false)

    -- Intro camera
    ScenarioFramework.StartOperationJessZoom('Start_Camera_Area', IntroMission1)
end

-----------
-- End Game
-----------
function PlayerCommanderDied(unit)
    ScenarioFramework.PlayerDeath(unit, OpStrings.A06_D01_010)
end

function PlayerWin()
    if not ScenarioInfo.OpEnded then
        -- Turn everything neutral; protect the player commander
        ScenarioFramework.EndOperationSafety()

        -- Celebration dialogue
        ScenarioFramework.Dialogue(OpStrings.A06_M03_090, WinGame, true)
    end
end

function WinGame()
    ScenarioInfo.OpComplete = true
    -- ScenarioFramework.PlayEndGameMovie(2, EndGame)
    local bonus = Objectives.IsComplete(ScenarioInfo.M1B1Objective) and Objectives.IsComplete(ScenarioInfo.M1B2Objective)
    -- this now plays the movie directly
    ScenarioFramework.EndOperation(ScenarioInfo.OpComplete, ScenarioInfo.OpComplete, false, bonus)
end

------------
-- Mission 1
------------
function IntroMission1()
    ScenarioInfo.MissionNumber = 1

    local tblArmy = ListArmies()
    local i = 1
    while tblArmy[ScenarioInfo['Player' .. i]] do
        ScenarioInfo['Player' .. i .. 'CDR'] = ScenarioFramework.SpawnCommander('Player' .. i, 'Commander', 'Warp', true, true, PlayerCommanderDied)
        WaitSeconds(2)
        i = i + 1
    end

    WaitSeconds(2)

    if not SkipIntroDialogue then
        ScenarioFramework.Dialogue(OpStrings.A06_M01_010, nil, true)
        ScenarioFramework.Dialogue(OpStrings.A06_M01_020, StartMission1, true)
    else
        StartMission1()
    end
end

function StartMission1()
    ---------------------------------------------
    -- Primary Objective - Capture Control Center
    ---------------------------------------------
    ScenarioInfo.M1P1Objective = Objectives.Capture(
        'primary',
        'incomplete',
        OpStrings.M1P1Text,
        OpStrings.M1P1Detail,
        {
            Units = {ScenarioInfo.BlackSunControlCenter},
        }
    )
    ScenarioInfo.M1P1Objective:AddResultCallback(
        function(result, units)
            if result then
                ScenarioFramework.Dialogue(OpStrings.A06_M01_040, nil, true)

                -- The control center should not die anymore
                -- TODO: new obj to protect it, if it dies at any point in the mission = fail, dialogue OpStrings.A06_M01_080
                ScenarioInfo.BlackSunControlCenter = units[1]
                ScenarioInfo.BlackSunControlCenter:SetCustomName(LOC '{i BlackSunControlTower}')
                ScenarioInfo.BlackSunControlCenter:SetCanTakeDamage(false)
                ScenarioInfo.BlackSunControlCenter:SetCanBeKilled(false)
                ScenarioInfo.BlackSunControlCenter:SetReclaimable(false)
                ScenarioInfo.BlackSunControlCenter:SetCanBeGiven(false)
                ScenarioInfo.BlackSunControlCenter:SetDoNotTarget(true)

                ForkThread(
                    function()
                        -- Blacksun control center captured cam
                        local camInfo = {
                            blendTime = 1.0,
                            holdTime = 4,
                            orientationOffset = { -2.1, 0.15, 0 },
                            positionOffset = { 0, 0.5, 0 },
                            zoomVal = 25,
                        }
                        ScenarioFramework.OperationNISCamera(ScenarioInfo.BlackSunControlCenter, camInfo)

                        -- Launch naval attack if it hasnt happened yet, else continue to second part of the mission
                        if not ScenarioInfo.M1NavalAttackLaunched and not SkipM1NavalAttack then
                            M1NavalAttack()
                        else
                            WaitSeconds(7)
                            IntroMission2()
                        end
                    end
                )
            else
                -- If the control center dies, the mission has failed
                ScenarioFramework.PlayerDeath(ScenarioInfo.BlackSunControlCenter, OpStrings.A06_M01_080)
            end
        end
    )

    -- If the player doesn't complete the objective soon, remind him that it's important
    ScenarioFramework.CreateTimerTrigger(M1P1Reminder, 900)

    ----------------------------------------
    -- Bonus Objective - Kill Marxon's units 
    ----------------------------------------
    num = {300, 400, 500}
    ScenarioInfo.M1B1 = Objectives.ArmyStatCompare(
        'bonus',
        'incomplete',
        OpStrings.M1B1Text,
        LOCF(OpStrings.M1B1Detail, num[Difficulty]),
        'kill',
        {
            Armies = {'HumanPlayers'},
            StatName = 'Enemies_Killed',
            CompareOp = '>=',
            Value = num[Difficulty],
            Category = categories.AEON,
            Hidden = true,
        }
    )

    -----------------------------------------------------------
    -- Bonus Objective - Build one of each of the experimentals 
    -----------------------------------------------------------
    ScenarioInfo.M1B2ExpsFinished = 0
    ScenarioInfo.M1B2 = Objectives.Basic(
        'bonus',
        'incomplete',
        OpStrings.M1B2Text,
        OpStrings.M1B2Detail,
        Objectives.GetActionIcon('build'),
        {
            Hidden = true,
        }
    )
    for _, army in ScenarioInfo.HumanPlayers do
        ScenarioFramework.CreateArmyStatTrigger(M1B2GCBuilt, ArmyBrains[army], 'B2Trigger1',
            {{ StatType = 'Units_History', CompareType = 'GreaterThanOrEqual', Value = 1, Category = categories.ual0401}})
        ScenarioFramework.CreateArmyStatTrigger(M1B2TempestBuilt, ArmyBrains[army], 'B2Trigger2',
            {{ StatType = 'Units_History', CompareType = 'GreaterThanOrEqual', Value = 1, Category = categories.uas0401}})
        ScenarioFramework.CreateArmyStatTrigger(M1B2CZARBuilt, ArmyBrains[army], 'B2Trigger3',
            {{ StatType = 'Units_History', CompareType = 'GreaterThanOrEqual', Value = 1, Category = categories.uaa0310}})
    end

    -----------
    -- Triggers
    -----------
    -- Launch UEF to Cybran attacks
    ScenarioFramework.CreateTimerTrigger(M1UEFCybranAttack, 10)

    -- Player sees the control center
    ScenarioFramework.CreateArmyIntelTrigger(M1ControlCenterSpotted, ArmyBrains[Player1], 'LOSNow', ScenarioInfo.BlackSunControlCenter, true, categories.ALLUNITS, true, ArmyBrains[Neutral])

    -- Send scouts at the player to encourage them to build defenses
    local delay = {120, 60, 30}
    ScenarioFramework.CreateTimerTrigger(M1Scout, delay[Difficulty])

    -- Kick off the reoccurring attacks
    delay = {180, 120, 60}
    ScenarioFramework.CreateTimerTrigger(M1ReoccurringLightAttack, delay[Difficulty])
    delay = {600, 420, 300}
    ScenarioFramework.CreateTimerTrigger(M1ReoccurringMediumAttack, delay[Difficulty])
    delay = {900, 540, 420}
    ScenarioFramework.CreateTimerTrigger(M1ReoccurringHeavyAttack, delay[Difficulty])

    -- Naval attack from Cybran and UEF
    delay = {35, 30, 25}
    ScenarioFramework.CreateTimerTrigger(M1NavalAttack, delay[Difficulty] * 60)

    -- Dialog that is delayed from the start of the mission
    ScenarioFramework.CreateTimerTrigger(M1DialoguesThread, 5*60)
end

function M1ControlCenterSpotted()
    ScenarioFramework.Dialogue(OpStrings.A06_M01_030)
end

function M1DialoguesThread()
    WaitSeconds(3*60)

    local i = 1
    while i <= 6 and ScenarioInfo.MissionNumber == 1 and not ScenarioInfo.OpEnded do
        if math.mod(i, 2) == 0 then
            ScenarioFramework.Dialogue(RandomRedTaunt())
        else
            ScenarioFramework.Dialogue(RandomAikoTaunt())
        end
        i = i + 1
        WaitSeconds(3*60)
    end
end

function M1NavalAttack()
    if ScenarioInfo.M1NavalAttackLaunched or SkipM1NavalAttack then
        return
    end
    ScenarioInfo.M1NavalAttackLaunched = true

    local CybranNavy = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M1_Naval_Attack_D' .. Difficulty, 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(CybranNavy, 'M1_Cybran_Naval_Attack_Chain')
    
    local UEFNavy = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M1_Naval_Attack_D' .. Difficulty, 'AttackFormation')
    for _, v in UEFNavy:GetPlatoonUnits() do
        if EntityCategoryContains(categories.ues0401, v) then
            IssueDive({v})
        end
    end
    ScenarioFramework.PlatoonPatrolChain(UEFNavy, 'M1_UEF_Naval_Attack_Chain_2')

    local CombinedGroup = CybranNavy:GetPlatoonUnits()
    for k, unit in UEFNavy:GetPlatoonUnits() do
        table.insert(CombinedGroup, unit)
    end

    local function AssignObjective()
        -------------------------------------------
        -- Primary Objective - Kill the naval units
        -------------------------------------------
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
        ScenarioInfo.M1P2Objective:AddResultCallback(
            function(result)
                if ScenarioInfo.MissionNumber == 1 and not ScenarioInfo.M1P1Objective.Active then
                    ScenarioFramework.Dialogue(OpStrings.A06_M01_090, IntroMission2, true)
                end
            end
        )
    end

    -- Play dialogue first
    ScenarioFramework.Dialogue(OpStrings.A06_M01_050, AssignObjective, true)
end

function M1RespawnAirDefense()
    local delay = {7*60, 5*60, 3*60}
    WaitSeconds(delay[Difficulty])

    if ScenarioInfo.MissionNumber == 1 and ScenarioInfo.M1P1Objective.Active then
        local AirDefense = ScenarioUtils.CreateArmyGroup('UEF', 'M1_Air_Defense_D' .. Difficulty)
        ScenarioFramework.GroupPatrolChain(AirDefense, 'M1_Air_Defense')
        ScenarioFramework.CreateGroupDeathTrigger(M1RespawnAirDefense, AirDefense)
    end
end

function M1RespawnGroundDefense()
    local delay = {7*60, 5*60, 3*60}
    WaitSeconds(delay[Difficulty])

    if ScenarioInfo.MissionNumber == 1 and ScenarioInfo.M1P1Objective.Active then
        local GroundDefense = ScenarioUtils.CreateArmyGroup('UEF', 'M1_Ground_Defense_D' .. Difficulty)
        ScenarioFramework.GroupPatrolChain(GroundDefense, 'M1_Ground_Defense')
        ScenarioFramework.CreateGroupDeathTrigger(M1RespawnGroundDefense, GroundDefense)
    end
end

function M1Scout()
    if ScenarioInfo.MissionNumber == 1 then
        local Scout = ScenarioUtils.CreateArmyGroup('UEF', 'M1_Scout_D' .. Difficulty)
        IssuePatrol(Scout, ScenarioUtils.MarkerToPosition('Player_Base_Landing_5'))
        IssuePatrol(Scout, ScenarioUtils.MarkerToPosition('Player_Base_Landing_1'))
        IssuePatrol(Scout, ScenarioUtils.MarkerToPosition('M1_Air_Offense_5'))
    end
end

-- Reoccurring offmap attacks, each uef UEF attack is soon followed by Cybran one
function M1ReoccurringLightAttack()
    if ScenarioInfo.MissionNumber == 1 then
        local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M1_Air_Attack_' .. Random(1, 3) .. '_D' .. Difficulty, 'AttackFormation')
        ScenarioFramework.PlatoonPatrolChain(platoon, 'M1_UEF_Air_Attack_Chain_' .. Random(1, 3))

        local delay = {240, 120, 80}
        ScenarioFramework.CreateTimerTrigger(M1ReoccurringLightAttack, delay[Difficulty])

        ScenarioFramework.CreateTimerTrigger(M1CybranLightAttack, 30)
    end
end

function M1CybranLightAttack()
    if ScenarioInfo.MissionNumber == 1 then
        local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M1_Air_Attack_' .. Random(1, 3) .. '_D' .. Difficulty, 'AttackFormation')
        ScenarioFramework.PlatoonPatrolChain(platoon, 'M1_Cybran_Air_Attack_Chain_' .. Random(1, 3))
    end
end

function M1ReoccurringMediumAttack()
    if ScenarioInfo.MissionNumber == 1 then     
        local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M1_Naval_Attack_' .. Random(1, 3) ..'_D' .. Difficulty, 'AttackFormation')
        ScenarioFramework.PlatoonPatrolChain(platoon, 'M1_UEF_Naval_Attack_Chain_' .. Random(1, 3))

        local delay = {600, 480, 300}
        ScenarioFramework.CreateTimerTrigger(M1ReoccurringMediumAttack, delay[Difficulty])

        ScenarioFramework.CreateTimerTrigger(M1CybranMediumAttack, 30)
    end
end

function M1CybranMediumAttack()
    if ScenarioInfo.MissionNumber == 1 then
        local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M1_Naval_Attack_' .. Random(1, 3) ..'_D' .. Difficulty, 'AttackFormation')
        ScenarioFramework.PlatoonPatrolChain(platoon, 'M1_Cybran_Naval_Attack_Chain_' .. Random(1, 3))
    end
end

function M1ReoccurringHeavyAttack()
    if ScenarioInfo.MissionNumber == 1 then
        for i = 1, Difficulty do
            local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M1_Air_Offense_D' .. Difficulty, 'AttackFormation')
            ScenarioFramework.PlatoonPatrolChain(platoon, 'M1_Air_Offense')

            if not ScenarioInfo.M1FirstAttackersSpawned then
                ScenarioInfo.M1FirstAttackersSpawned = true
                break
            end
        end

        local delay = {600, 480, 360}
        ScenarioFramework.CreateTimerTrigger(M1ReoccurringHeavyAttack, delay[Difficulty])
    end
end

-- UEF to Cybran and vice-versa attack
function M1UEFCybranAttack()
    if ScenarioInfo.MissionNumber ~= 1 then
        return
    end

    local function destroyUnit(unit)
        unit:Destroy()
    end

    local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon("Cybran", "M1_Naval_To_UEF", "AttackFormation")
    ScenarioFramework.PlatoonAttackChain(platoon, "M1_Cybran_UEF_Chain")

    for _, unit in platoon:GetPlatoonUnits() do
        ScenarioFramework.CreateUnitToMarkerDistanceTrigger(destroyUnit, unit, "M1_UEF_Start", 30)
    end

    -- Random delay so the units don't meet at at exactly the same place
    local delay = Random(1, 30)
    WaitSeconds(delay)

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon("UEF", "M1_Naval_To_Cybran", "AttackFormation")
    ScenarioFramework.PlatoonAttackChain(platoon, "M1_UEF_Cybran_Chain")

    for _, unit in platoon:GetPlatoonUnits() do
        ScenarioFramework.CreateUnitToMarkerDistanceTrigger(destroyUnit, unit, "M1_Cybran_Start", 30)
    end

    ScenarioFramework.CreateTimerTrigger(M1UEFCybranAttack, 300 - delay)
end

-- Functions for completing bonus objective
function M1B2GCBuilt()
    if ScenarioInfo.M1B2GCBuilt then
        return
    end
    ScenarioInfo.M1B2GCBuilt = true

    M1B2ExperimentalDone()
end

function M1B2TempestBuilt()
    if ScenarioInfo.M1B2TempestBuilt then
        return
    end
    ScenarioInfo.M1B2TempestBuilt = true

    M1B2ExperimentalDone()
end

function M1B2CZARBuilt()
    if ScenarioInfo.M1B2CZARBuilt then
        return
    end
    ScenarioInfo.M1B2CZARBuilt = true

    M1B2ExperimentalDone()
end

function M1B2ExperimentalDone()
    ScenarioInfo.M1B2ExpsFinished = ScenarioInfo.M1B2ExpsFinished + 1
    if ScenarioInfo.M1B2ExpsFinished == 3 then
        ScenarioInfo.M1B2:ManualResult(true)
    end
end

------------
-- Mission 2
------------
function IntroMission2()
    if ScenarioInfo.MissionNumber ~= 1 then
        return
    end
    ScenarioInfo.MissionNumber = 2

    -- Update the playable area
    ScenarioFramework.SetPlayableArea('M2_Playable_Area', true)

    -- Set the maximum number of units that the player is allowed to have
    ScenarioFramework.SetSharedUnitCap(1250)

    ------------
    -- Cybran AI
    ------------
    M2CybranAI.CybranM2BaseAI()

    local Antinukes = ArmyBrains[Cybran]:GetListOfUnits(categories.urb4302, false)
    for _, v in Antinukes do
        v:GiveTacticalSiloAmmo(3)
    end

    -- Mexes on the map
    ScenarioUtils.CreateArmyGroup('Cybran', 'M2_Extra_Resources')

    -- Walls
    ScenarioUtils.CreateArmyGroup('Cybran', 'M2_Walls')

    -- ACU
    ScenarioInfo.CybranCommander = ScenarioFramework.SpawnCommander('Cybran', 'Commander', false, LOC '{i RedFog}', true, M2CybranCommanderKilled,
        {'AdvancedEngineering', 'T3Engineering', 'StealthGenerator', 'CloakingGenerator', 'MicrowaveLaserGenerator'})
    -- Restrict building Naval factory, Torp def and AA
    ScenarioInfo.CybranCommander:AddBuildRestriction(categories.urb0103 + categories.zrb9603 + categories.urb2205 + categories.urb2304)

    -- sACU
    ScenarioInfo.CybranSubCommander = ScenarioFramework.SpawnCommander('Cybran', 'SubCommander', false, LOC '{i sCDR_Jericho}', false, M2CybranCommanderKilled,
        {'NaniteMissileSystem', 'ResourceAllocation', 'Switchback'})

    -- T3 engineers for assisting naval factories
    for _, factory in ArmyBrains[Cybran]:GetListOfUnits(categories.NAVAL * categories.FACTORY * categories.STRUCTURE, false) do
        local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2_Naval_Engineers_D' .. Difficulty, 'NoFormation')
        platoon:GuardTarget(factory)
    end

    ScenarioFramework.RefreshRestrictions('Cybran')

    -- Patrols
    -- Air
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2_Initial_Air_Patrol_D' .. Difficulty, 'NoFormation')
    for _, v in platoon:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M2_Cybran_Air_Patrol')))
    end

    -- Land
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2_Initial_Land_Patrol_D' .. Difficulty, 'AttackFormation')
    for _, v in platoon:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolChain({v}, 'M2_Cybran_Land_Patrol')
    end

    -- Naval
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2_Initial_Naval_Patrol_D' .. Difficulty, 'GrowthFormation')
    for _, v in platoon:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M2_Cybran_Base_Naval_Patrol')))
    end

    -- Attack group for the control centre
    ScenarioInfo.M2Attackers = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2_Attackers_D' .. Difficulty, 'AttackFormation')
    ScenarioInfo.M2Attackers:AddDestroyCallback(M2CybranAttackDefeated)
    ScenarioInfo.M2Attackers:MoveToLocation(ScenarioUtils.MarkerToPosition('M2_Cybran_Initial_Move'), false)

    ForkThread(CustomFunctions.EnableStealthOnAir)
    ForkThread(CustomFunctions.CheatEco)

    -- Wrecked ships for M3, kill them now so they can sink offmap
    local units = ScenarioUtils.CreateArmyGroup('UEF', 'M2_Wreckage')
    for _, v in units do
        v:Kill()
    end

    ScenarioFramework.Dialogue(OpStrings.A06_M02_010, StartMission2, true)
end

function StartMission2()
    -- Unit Restrictions
    ScenarioFramework.RemoveRestrictionForAllHumans(
        categories.uab0304 + -- Quantum Gate
        categories.ual0301 + -- Sub Commander
        categories.uas0304 + -- Strategic Missile Submarine
        categories.ual0401 + -- Giant Assault Bot
        categories.uas0401 + -- Submersible Battleship
        categories.uaa0310,  -- Death Saucer
        true
    )

    ---------------------------------------------
    -- Primary Objective - Protect Control Center
    ---------------------------------------------
    ScenarioInfo.M2P1Objective = Objectives.Protect(
        'primary',
        'incomplete',
        OpStrings.M2P1Text,
        OpStrings.M2P1Detail,
        {
            Units = {ScenarioInfo.BlackSunControlCenter},
        }
    )

    --------------------------------------
    -- Primary Objective - Kill Cybran ACU
    --------------------------------------
    ScenarioInfo.M2P2Objective = Objectives.Kill(
        'primary',
        'incomplete',
        OpStrings.M2P2Text,
        OpStrings.M2P2Detail,
        {
            Units = {ScenarioInfo.CybranCommander},
        }
    )
    ScenarioInfo.M2P2Objective:AddResultCallback(
        function(result)
            if result then
                -- Cybran death cam
                ScenarioFramework.CDRDeathNISCamera(ScenarioInfo.CybranCommander, 7)

                ScenarioInfo.M2P1Objective:ManualResult(true)
                ScenarioFramework.Dialogue(OpStrings.A06_M02_100, IntroMission3, true)
            end
        end
    )

    -- Lose if cybran units reach control center and player has no units around
    ScenarioFramework.CreateAreaTrigger(CybranNearControlCenter, 'M1_Control_Center_Near_Area', categories.CYBRAN, true, false, ArmyBrains[Cybran], 1, false)

    -- Deliver some story information via dialog from an offscreen commander
    ScenarioFramework.CreateTimerTrigger(M2OffscreenCommanderDialog1, 30)

    -- Dialog about the attack that will happen soon
    ScenarioFramework.CreateTimerTrigger(M2PreAttack1, 60)

    -- If the player doesn't complete the objectives soon, remind him that it's important
    ScenarioFramework.CreateTimerTrigger(M2P2Reminder, 15*60)

    -- Dialog that is delayed from the start of the mission
    ScenarioFramework.CreateTimerTrigger(M2Dialog1, 3*60)
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

function ControlCenterCapturedByEnemy()
    -- Let the player know what happened

    ScenarioInfo.M2P1Objective:ManualResult(false)

    ScenarioFramework.Dialogue(OpStrings.A06_M02_130, nil, true)
    ScenarioFramework.PlayerLose()
end

-- Major Cybran attack
function M2PreAttack1()
    if ScenarioInfo.M2P2Objective.Active and not ScenarioInfo.M2CybranAttackDefeated then
       ScenarioFramework.Dialogue(OpStrings.A06_M02_050, nil, true)
       ScenarioFramework.CreateTimerTrigger(M2PreAttack2, 120)
    end
end

function M2PreAttack2()
    if ScenarioInfo.M2P2Objective.Active and not ScenarioInfo.M2CybranAttackDefeated then
       ScenarioFramework.Dialogue(OpStrings.A06_M02_060, nil, true)
       ScenarioFramework.CreateTimerTrigger(M2AttackNow, 60)
    end
end

function M2AttackNow()
    if ScenarioInfo.M2P2Objective.Active and not ScenarioInfo.M2CybranAttackDefeated then
        ScenarioFramework.Dialogue(OpStrings.A06_M02_070, nil, true)

        ScenarioInfo.M2Attackers:Stop()
        ScenarioInfo.M2Attackers:AggressiveMoveToLocation(ScenarioUtils.MarkerToPosition('M2_Cybran_Target'))
        ScenarioInfo.M2Attackers:Patrol(ScenarioUtils.MarkerToPosition('AttackMarker'))
        ScenarioInfo.M2Attackers:Patrol(ScenarioUtils.MarkerToPosition('M1_Air_Defense_1'))
    end
end

function M2CybranAttackDefeated()
    ScenarioInfo.M2CybranAttackDefeated = true
    ScenarioFramework.Dialogue(OpStrings.A06_M02_080)
end

function M2CybranCommanderKilled()
    if ScenarioInfo.CybranCommander and ScenarioInfo.CybranCommander.Dead and ScenarioInfo.CybranSubCommander and ScenarioInfo.CybranSubCommander.Dead then
        ForkThread(M2KillCybranBase)
    end
end

function M2KillCybranBase()
    for _, unit in ArmyBrains[Cybran]:GetListOfUnits(categories.ALLUNITS - categories.WALL, false) do
        if unit and not unit.Dead then
            unit:Kill()
            WaitSeconds(Random(0.2, 0.5))
        end
    end
    -- Kill any remaining units that slipped cuz of the delay
    for _, unit in ArmyBrains[Cybran]:GetListOfUnits(categories.ALLUNITS - categories.WALL, false) do
        if unit and not unit.Dead then
            unit:Kill()
        end
    end
end

-- Dialogues
function M2OffscreenCommanderDialog1()
    if ScenarioInfo.MissionNumber == 2 and not ScenarioInfo.OpEnded then
        ScenarioFramework.Dialogue(OpStrings.A06_M02_020)
        ScenarioFramework.Dialogue(OpStrings.A06_M02_030)
        ScenarioFramework.CreateTimerTrigger(M2OffscreenCommanderDialog2, 90)
    end
end

function M2OffscreenCommanderDialog2()
    if ScenarioInfo.MissionNumber == 2 and not ScenarioInfo.OpEnded then
        ScenarioFramework.Dialogue(OpStrings.A06_M02_040)
        ScenarioFramework.CreateTimerTrigger(M2OffscreenCommanderDialog3, 60)
    end
end

function M2OffscreenCommanderDialog3()
    if ScenarioInfo.MissionNumber == 2 and not ScenarioInfo.OpEnded then
        ScenarioFramework.Dialogue(OpStrings.A06_M02_090)
        ScenarioFramework.CreateTimerTrigger(M2OffscreenCommanderDialog4, 30)
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
        -- Dialog moved to the offscreen one
        ScenarioFramework.CreateTimerTrigger(M2Dialog2, 2*60)
    end
end

function M2Dialog2()
    if ScenarioInfo.MissionNumber == 2 and not ScenarioInfo.OpEnded then
        ScenarioFramework.Dialogue(RandomRedTaunt())
        ScenarioFramework.CreateTimerTrigger(M2Dialog3, 2*60)
    end
end

function M2Dialog3()
    if ScenarioInfo.MissionNumber == 2 and not ScenarioInfo.OpEnded then
        ScenarioFramework.Dialogue(RandomRedTaunt())
        ScenarioFramework.CreateTimerTrigger(M2Dialog4, 60)
    end
end

function M2Dialog4()
    if ScenarioInfo.MissionNumber == 2 and not ScenarioInfo.OpEnded then
        -- Dialog removed to the offscreen commander dialog functions
        ScenarioFramework.CreateTimerTrigger(M2Dialog5, 3*60)
    end
end

function M2Dialog5()
    if ScenarioInfo.MissionNumber == 2 and not ScenarioInfo.OpEnded then
        ScenarioFramework.Dialogue(RandomRedTaunt())
        ScenarioFramework.CreateTimerTrigger(M2Dialog6, 4*60)
    end
end

function M2Dialog6()
    if ScenarioInfo.MissionNumber == 2 and not ScenarioInfo.OpEnded then
        ScenarioFramework.Dialogue(RandomRedTaunt())
    end
end

------------
-- Mission 3
------------
function IntroMission3()
    if ScenarioInfo.MissionNumber ~= 2 then
        return
    end
    ScenarioInfo.MissionNumber = 3

    -- Set the maximum number of units that the player is allowed to have
    ScenarioFramework.SetSharedUnitCap(1500)

    -- Create the wreckage of the UEF base that was "defeated" during mission 2
    ScenarioUtils.CreateArmyGroup('UEF', 'M3_Wreckage', true)

    -- Update the playable area
    ScenarioFramework.SetPlayableArea('M3_Playable_Area', true)

    -- Destroy UEF Off map resources
    for _, v in ScenarioInfo.M1UEFOffmapResources do
        v:Destroy()
    end

    ----------
    -- Aeon AI
    ----------
    -- Spawn the bases
    M3AeonAI.AeonM3BlackSunBaseAI()
    M3AeonAI.AeonM3BlackSunNavalBaseAI()
    M3AeonAI.AeonM3IslandBaseAI()
    M3AeonAI.AeonM3SouthWestBaseAI()
    M3AeonAI.AeonM3SouthEastBaseAI()
    
    local Antinukes = ArmyBrains[Aeon]:GetListOfUnits(categories.uab4302, false)
    for _, unit in Antinukes do
        unit:GiveTacticalSiloAmmo(3)
    end

    local TMLs = ArmyBrains[Aeon]:GetListOfUnits(categories.uab2108, false)
    for _, unit in TMLs do
        local plat = ArmyBrains[Aeon]:MakePlatoon('', '')
        ArmyBrains[Aeon]:AssignUnitsToPlatoon(plat, {unit}, 'Attack', 'NoFormation')
        plat:ForkAIThread(plat.TacticalAI)
    end

    local Nukes = ArmyBrains[Aeon]:GetListOfUnits(categories.uab2305, false)
    for _, unit in Nukes do
        IssueStop({unit})
    end

    -- Walls, medium walls are enough, we don't want to wall of the base completely.
    ScenarioUtils.CreateArmyGroup('Aeon', 'M3_Black_Sun_Base_Walls_D2')

    -- Marxon
    ScenarioInfo.AeonCommander = ScenarioFramework.SpawnCommander('Aeon', 'Commander', false, LOC '{i Marxon}', true, false,
        {'CrysalisBeam', 'ShieldHeavy', 'EnhancedSensors'})
    ScenarioFramework.CreateUnitDamagedTrigger(MarxonDamaged1, ScenarioInfo.AeonCommander, .5)
    ScenarioInfo.AeonCommander.CanBeKilled = false

    ScenarioFramework.RefreshRestrictions('Aeon')

    -- Arnold
    ScenarioInfo.FriendlyCommander = ScenarioFramework.SpawnCommander('Aeon', 'Friendly_Commander', false, LOC '{i CDR_Arnold}', false, false,
        {'CrysalisBeam', 'Shield', 'EnhancedSensors'})
    ScenarioInfo.FriendlyCommander:SetCanTakeDamage(false)
    ScenarioInfo.FriendlyCommander:SetCanBeKilled(false)
    ScenarioInfo.FriendlyCommander:SetReclaimable(false)
    ScenarioInfo.FriendlyCommander:SetCapturable(false)

    local Colossus = ScenarioUtils.CreateArmyUnit('Aeon', 'Colossus')
    IssuePatrol({Colossus}, ScenarioUtils.MarkerToPosition('Colossus_Patrol_1'))
    IssuePatrol({Colossus}, ScenarioUtils.MarkerToPosition('Colossus_Patrol_2'))

    -- invincible by design
    ScenarioInfo.BlackSun = ScenarioUtils.CreateArmyUnit('Aeon', 'Black_Sun')
    ScenarioInfo.BlackSun:SetCanTakeDamage(false)
    ScenarioInfo.BlackSun:SetDoNotTarget(true)
    ScenarioInfo.BlackSun:SetCanBeKilled(false)
    ScenarioInfo.BlackSun:SetReclaimable(false)

    -- we rotate these buildings, so they are unselectable (otherwise players would see
    -- the selection rotated, and would perhaps want to know how to rotate their own buildings)
    local SupportBuildings = ScenarioUtils.CreateArmyGroup('Aeon', 'Black_Sun_Support')
    for k, unit in SupportBuildings do
        unit:SetUnSelectable(true)
        unit:SetCanTakeDamage(false)
        unit:SetDoNotTarget(true)
        unit:SetCanBeKilled(false)
        unit:SetReclaimable(false)
    end

    -- Patrols
    -- Black sun
    -- Air
    local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M3_Black_Sun_Air_Patrol_D' .. Difficulty, 'NoFormation')
    for _, v in platoon:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M3_Black_Sun_Air_Patrol_Chain')))
    end

    -- Static naval units
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M3_Black_Sun_Static_Naval_Patrol', 'NoFormation')

    -- Island
    -- Naval patrol around the island
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M3_Island_Naval_Patrol_D' .. Difficulty, 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_Island_Naval_Patrol_Chain')

    -- Static naval units
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M3_Island_Naval_Static_Patrol_D' .. Difficulty, 'NoFormation')

    -- SE Base
    -- Air
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M3_SE_Air_Patrol_D' .. Difficulty, 'NoFormation')
    for _, v in platoon:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M3_SE_Air_Patrol_Chain')))
    end

    -- Naval
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M3_SE_Static_Naval_Patrol', 'NoFormation')

    for i = 1, 2 do
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M3_SE_Start_Navy_' .. i, 'GrowthFormation')
        ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_SE_Base_Naval_Patrol_Chain_' .. i)
    end

    -- SW Base
    -- Air
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M3_SW_Air_Patrol_D' .. Difficulty, 'NoFormation')
    for _, v in platoon:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M3_SW_Air_Patrol_Chain')))
    end

    -- Naval
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M3_SW_Static_Naval_Patrol', 'NoFormation')

    for i = 1, 2 do
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M3_SW_Naval_Patrol_' .. i, 'GrowthFormation')
        ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_SW_Base_Naval_Patrol_Chain_' .. i)
    end

    -- CZAR patroling over the base
    if Difficulty >= 2 then
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M3_SW_CZAR', 'NoFormation')
        ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_SW_CZAR_Chain')
    end

    -- Global patrols
    for i = 1, 2 do
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M3_Global_Cruisers_' .. i .. '_D' .. Difficulty, 'GrowthFormation')
        ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_Global_Cruisers_Patrol_Chain_' .. i)
    end

    -- Spawn a naval force and move them to the player's base
    local AeonNavy = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M3_Naval_Attack_D' .. Difficulty, 'GrowthFormation')
    AeonNavy:AggressiveMoveToLocation(ScenarioUtils.MarkerToPosition('M3_Main_Base_Naval_Attack_1'))
    AeonNavy:Patrol(ScenarioUtils.MarkerToPosition('M3_Main_Base_Naval_Attack_2'))
    AeonNavy:Patrol(ScenarioUtils.MarkerToPosition('M3_Main_Base_Naval_Attack_1'))

    -- Initial resources for AI
    local num = {20000, 30000, 40000}
    GetArmyBrain('Aeon'):GiveResource('MASS', num[Difficulty])
    GetArmyBrain('Aeon'):GiveResource('ENERGY', 80000)

    -- Briefing
    ScenarioFramework.Dialogue(OpStrings.A06_M03_010, IntroMission3NIS, true)
end

function IntroMission3NIS()
    -- Arnold death cam
    ScenarioFramework.CreateVisibleAreaLocation(26, ScenarioInfo.FriendlyCommander:GetPosition(), 4, ArmyBrains[Player1])
    ScenarioFramework.CDRDeathNISCamera(ScenarioInfo.FriendlyCommander, 5)

    ScenarioInfo.FriendlyCommander:SetCanBeKilled(true)
    ScenarioInfo.FriendlyCommander:Kill()
    ScenarioFramework.Dialogue(OpStrings.A06_M03_020, StartMission3, true)
end

function StartMission3()
    ScenarioInfo.Mission3ObjectiveGroup = Objectives.CreateGroup('Mission 2 Objectives', PlayerWin)

    ----------------------------------
    -- Primary Objective - Kill Marxon
    ----------------------------------
    ScenarioInfo.M3P1Objective = Objectives.Kill(
        'primary',
        'incomplete',
        OpStrings.M3P1Text,
        OpStrings.M3P1Detail,
        {
            Units = {ScenarioInfo.AeonCommander}
        }
    )
    ScenarioInfo.M3P1Objective:AddResultCallback(
        function(result)
            -- Marxon killed
            ScenarioFramework.CDRDeathNISCamera(ScenarioInfo.AeonCommander, 5)
            ScenarioFramework.Dialogue(OpStrings.A06_M03_080, nil, true)
        end
    )
    ScenarioInfo.Mission3ObjectiveGroup:AddObjective(ScenarioInfo.M3P1Objective)

    --------------------------------------------
    -- Primary Objective - Destroy Marxon's base
    --------------------------------------------
    ScenarioInfo.M3P2Objective = Objectives.CategoriesInArea(
        'primary',
        'incomplete',
        OpStrings.M3P2Text,
        OpStrings.M3P2Detail,
        'kill',
        {
            MarkUnits = false,
            Requirements = {
                {
                    Area = 'M3_Black_Sun_Area',
                    Category = (categories.AEON * categories.STRUCTURE) - categories.WALL,
                    CompareOp = '<=',
                    Value = 0,
                    ArmyIndex = Aeon
                },
            }
        }
    )
    ScenarioInfo.Mission3ObjectiveGroup:AddObjective(ScenarioInfo.M3P2Objective)

    ---------------------------------------
    -- Bonus Objective - Kill island engies
    ---------------------------------------
    local engineers = ScenarioFramework.GetCatUnitsInArea(categories.ENGINEER, 'Experimental_Island_Area', ArmyBrains[Aeon])
    ScenarioInfo.M3B1Objective = Objectives.Kill(
        'bonus',
        'incomplete',
        OpStrings.M3B1Text,
        OpStrings.M3B1Detail,
        {
            Units = engineers,
            MarkUnits = false,
            Hidden = true,
        }
    )

    ScenarioFramework.CreateAreaTrigger(M3IslandExperimentalCompleted, 'Experimental_Island_Area', categories.EXPERIMENTAL, true, false, ArmyBrains[Aeon], 1, true)

    -- If the player doesn't complete the objectives soon, remind him that it's important
    ScenarioFramework.CreateTimerTrigger(M3P1Reminder, 20*60)

    ScenarioFramework.CreateTimerTrigger(M3Dialog1, 6*60)

    -- Start nuking player
    ScenarioFramework.CreateTimerTrigger(M3NukePlayer, 10)--*60)
end

function M3IslandExperimentalCompleted()
    -- If the bonus objective is still active, mark is as lost
    if ScenarioInfo.M3B1Objective.Active then
        ScenarioInfo.M3B1Objective:ManualResult(false)
    end
end

function MarxonDamaged1()
    if ScenarioInfo.AeonCommander:GetHealth() <= 2400 then
        MarxonDamaged2()
    elseif ScenarioFramework.NumCatUnitsInArea(categories.STRUCTURE - categories.WALL, 'M3_SW_Base_Area', ArmyBrains[Aeon]) > 50 then
        ForkThread(TeleportSW)
    elseif ScenarioFramework.NumCatUnitsInArea(categories.STRUCTURE - categories.WALL, 'M3_SE_Base_Area', ArmyBrains[Aeon]) > 50 then
        ForkThread(TeleportSE)
    else
        ScenarioInfo.AeonCommander.CanBeKilled = true
    end
end

function TeleportSW()
    ScenarioInfo.AeonCommander:SetCanTakeDamage(false)
    ScenarioFramework.FakeTeleportUnit(ScenarioInfo.AeonCommander)
    ScenarioFramework.Dialogue(RandomMarxonTaunt())
    Warp(ScenarioInfo.AeonCommander, ScenarioUtils.MarkerToPosition('M2_SW_Teleport'))
    ScenarioFramework.CreateUnitDamagedTrigger(MarxonDamaged2, ScenarioInfo.AeonCommander, .8)
    ScenarioInfo.AeonCommander:SetCanTakeDamage(true)
    UpdateACUPlatoon('M3_SW_Base')
end

function MarxonDamaged2()
    if ScenarioFramework.NumCatUnitsInArea(categories.STRUCTURE - categories.WALL, 'M3_SE_Base_Area', ArmyBrains[Aeon]) > 50 then
        ForkThread(TeleportSE)
    else
        ScenarioInfo.AeonCommander.CanBeKilled = true
    end
end

function TeleportSE()
    ScenarioInfo.AeonCommander:SetCanTakeDamage(false)
    ScenarioFramework.FakeTeleportUnit(ScenarioInfo.AeonCommander)
    ScenarioFramework.Dialogue(RandomMarxonTaunt())
    Warp(ScenarioInfo.AeonCommander, ScenarioUtils.MarkerToPosition('M2_SE_Teleport'))
    --ScenarioFramework.CreateUnitDamagedTrigger(MarxonDamaged2, ScenarioInfo.AeonCommander, .8)
    ScenarioInfo.AeonCommander:SetCanTakeDamage(true)
    ScenarioInfo.AeonCommander.CanBeKilled = true
    UpdateACUPlatoon('M3_SE_Base')
end

function UpdateACUPlatoon(location)
    local function FindACUPlatoon()
        for _, platoon in ArmyBrains[Aeon]:GetPlatoonsList() do
            for _, unit in platoon:GetPlatoonUnits() do
                if unit == ScenarioInfo.AeonCommander then
                    return platoon
                end
            end
        end
        WARN('ACU Platoon Not Found')
    end
    local platoon = FindACUPlatoon()
    if location == 'None' then
        IssueClearCommands({ScenarioInfo.AeonCommander})
        LOG('Stopping CRD Platoon')
        platoon:StopAI()
        ArmyBrains[UEF]:DisbandPlatoon(platoon)
        return
    end
    LOG('Changing ACU platoon for location: ' .. location)
    LOG('Old PlatoonData: ', repr(platoon.PlatoonData))
    platoon:StopAI()
    platoon.PlatoonData = {
        BaseName = location,
        LocationType = location,
    }
    platoon:ForkAIThread(import('/lua/AI/OpAI/BaseManagerPlatoonThreads.lua').BaseManagerSingleEngineerPlatoon)
    LOG('New PlatoonData: ', repr(platoon.PlatoonData))
end

function M3NukePlayer(settings)
    local function getLaunchers(army, filterCat)
        local brain = GetArmyBrain(army)
        local launchers = brain:GetListOfUnits(categories.NUKE * categories.SILO, false)

        if filterCat then
            launchers = EntityCategoryFilterDown(filterCat, launchers)
        end

        return launchers
    end

    --- Wait time in seconds between firing missiles.
    -- @param delay table with {min, max}, int or nil for default.
    local function salvoDelay(delay)
        if not delay then
            return
        elseif type(delay) == "table" then
            delay = Random(delay[1], delay[2])
        end

        WaitSeconds(delay or Random(5, 10))
    end

    local function getTargets(army, cats, locations)
        local brain = GetArmyBrain(army)

        if type(locations) == 'string' then
            locations = ScenarioUtils.ChainToPositions(locations)
        end

        local targets = {}
        for _, pos in locations do
            local num = table.getn(brain:GetUnitsAroundPoint(cats or categories.ALLUNITS - categories.WALL, pos, 30, 'enemy'))

            if num > 5 then
                bestUnitCount = num
                table.insert(targets, {pos = pos, num = num})
            end
        end

        table.sort(targets, function(a, b) return a.num > b.num end)

        return targets
    end

    local function getNextTargetPosition(targets, singleTarget)
        if singleTarget then
            return targets[1].pos
        end

        if not targets.last or not targets[targets.last] then
            targets.last = 1
        else
            targets.last = targets.last + 1
        end

        return targets[targets.last].pos
    end

    settings = settings or NukeSettings

    local launchers = getLaunchers('Aeon')
    local targets = getTargets('Aeon', settings.TargetCategories, settings.TargetChain or settings.TargetPositions)

    if not (launchers[1] and targets[1]) then
        if settings.Retry then
            ScenarioFramework.CreateTimerTrigger(M3NukePlayer, 60)
        end
        LOG("No launchers ... aborting.")
        return
    end

    -- Launch the nukes
    for _, launcher in launchers do
        if not launcher.Dead then
            if launcher:GetNukeSiloAmmoCount() == 0 then
                launcher:GiveNukeSiloAmmo(1)
            end

            local targetPos = getNextTargetPosition(targets, settings.SingleTarget)
            IssueNuke({launcher}, targetPos)

            LOG("Firing nuke at: ".. repr(targetPos))

            salvoDelay(settings.SalvoDelay)
        end
    end

    ScenarioFramework.CreateTimerTrigger(M3NukePlayer, settings.DelayBetweenSalvos[Difficulty])
end

function M3Dialog1()
    if ScenarioInfo.M3P1Objective.Active and not ScenarioInfo.OpEnded then
        ScenarioFramework.Dialogue(RandomMarxonTaunt())
        ScenarioFramework.CreateTimerTrigger(M3Dialog2, 2*60)
    end
end

function M3Dialog2()
    if ScenarioInfo.M3P1Objective.Active and not ScenarioInfo.OpEnded then
        ScenarioFramework.Dialogue(RandomMarxonTaunt())
        ScenarioFramework.CreateTimerTrigger(M3Dialog3, 2*60)
    end
end

function M3Dialog3()
    if ScenarioInfo.M3P1Objective.Active and not ScenarioInfo.OpEnded then
        ScenarioFramework.Dialogue(OpStrings.A06_M03_040)
        ScenarioFramework.CreateTimerTrigger(M3Dialog4, 3*60)
    end
end

function M3Dialog4()
    if ScenarioInfo.M3P1Objective.Active and not ScenarioInfo.OpEnded then
        ScenarioFramework.Dialogue(RandomMarxonTaunt())
        ScenarioFramework.CreateTimerTrigger(M3Dialog5, 2*60)
    end
end

function M3Dialog5()
    if ScenarioInfo.M3P1Objective.Active and not ScenarioInfo.OpEnded then
        ScenarioFramework.Dialogue(RandomMarxonTaunt())
    end
end

---------
-- Taunts
---------
function RandomAikoTaunt()
    local num = Random(1, table.getn(TauntTableAiko))
    return(TauntTableAiko[num])
end

function RandomRedTaunt()
    local num = Random(1, table.getn(TauntTableRed))
    return(TauntTableRed[num])
end

function RandomMarxonTaunt()
    local num = Random(1, table.getn(TauntTableMarxon))
    return(TauntTableMarxon[num])
end

------------
-- Reminders
------------
function M1P1Reminder()
    if ScenarioInfo.M1P1Objective.Active and not ScenarioInfo.OpEnded then
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
        ScenarioFramework.CreateTimerTrigger(M1P1Reminder, 600)
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
        ScenarioFramework.CreateTimerTrigger(M2P2Reminder, 600)
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
        ScenarioFramework.CreateTimerTrigger(M3P1Reminder, 900)
    end
end

------------------
-- Debug Functions
------------------
---[[
function OnCtrlF3()
    for _, v in ArmyBrains[UEF]:GetListOfUnits(categories.NAVAL * categories.MOBILE, false) do
        v:Kill()
    end
    for _, v in ArmyBrains[Cybran]:GetListOfUnits(categories.NAVAL * categories.MOBILE, false) do
        v:Kill()
    end
end

function OnCtrlF4()
    if ScenarioInfo.MissionNumber == 1 then
        IntroMission2()
    elseif ScenarioInfo.MissionNumber == 2 then
        IntroMission3()
    end
end

function OnShiftF3()
    ScenarioInfo.MissionNumber = 2
    ScenarioInfo.BlackSunControlCenter:SetCanTakeDamage(false)
    ScenarioInfo.BlackSunControlCenter:SetCanBeKilled(false)
    IntroMission3()
end
--]]
