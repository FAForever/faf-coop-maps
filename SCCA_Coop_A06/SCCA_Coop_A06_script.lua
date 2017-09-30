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

ScenarioInfo.VarTable = {}

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

-------------
-- Debug Only
-------------
local SkipIntroDialogue = false

-----------
-- Start up
-----------
function OnPopulate(scenario)
    -- Initial Unit Creation
    ScenarioUtils.InitializeScenarioArmies()
    LeaderFaction, LocalFaction = ScenarioFramework.GetLeaderAndLocalFactions()

    Weather.CreateWeather()

    -- Spawn the enemy bases
    ScenarioUtils.CreateArmyGroup('UEF', 'M1_Defenses_D' .. Difficulty)
    ScenarioUtils.CreateArmyGroup('UEF', 'M1_Walls')

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
    -- ScenarioInfo.BlackSunControlCenter:SetCanTakeDamage(false)
    -- ScenarioInfo.BlackSunControlCenter:SetCanBeKilled(false)
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
    ScenarioFramework.SetSharedUnitCap(480)

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
        if i ~= 2 then
            ScenarioInfo['Player' .. i .. 'CDR'] = ScenarioFramework.SpawnCommander('Player' .. i, 'Commander', 'Warp', true, true, PlayerCommanderDied)
            WaitSeconds(2)
        end
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
            --FlashVisible = true,
        }
    )
    ScenarioInfo.M1P1Objective:AddResultCallback(
        function(result, units)
            if result then
                local newHandle = units[1]
                ScenarioFramework.Dialogue(OpStrings.A06_M01_040, nil, true)

                -- speed2: for now make player lose if it's killed

                -- pull a switcheroo here, as soon as the player captures it, set it
                -- back to neutral, but painted with the player's color
                -- Now it won't get attacked, but it looks like it belongs to the player.
                -- ScenarioFramework.SetAeonColor(Neutral)
                -- ScenarioInfo.BlackSunControlCenter = ScenarioFramework.GiveUnitToArmy(newHandle, Neutral)
                -- ScenarioInfo.BlackSunControlCenter:SetCanTakeDamage(false)
                -- ScenarioInfo.BlackSunControlCenter:SetCanBeKilled(false)
                -- ScenarioInfo.BlackSunControlCenter:SetCapturable(false)
                ScenarioInfo.BlackSunControlCenter = newHandle
                ScenarioInfo.BlackSunControlCenter:SetReclaimable(false)
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
                        if not ScenarioInfo.M1NavalAttackLaunched then
                            M1NavalAttack()
                        else
                            WaitSeconds(7)
                            IntroMission2()
                        end
                    end
                )
            else
                --ScenarioFramework.Dialogue(OpStrings.A06_M01_080, nil, true)
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
    -- Player sees the control center
    ScenarioFramework.CreateArmyIntelTrigger(M1ControlCenterSpotted, ArmyBrains[Player1], 'LOSNow', ScenarioInfo.BlackSunControlCenter, true, categories.ALLUNITS, true, ArmyBrains[Neutral])

    -- Kick off the reoccurring attacks
    local delay = {300, 180, 60}
    ScenarioFramework.CreateTimerTrigger(M1ReoccurringLightAttack, delay[Difficulty])
    delay = {600, 420, 300}
    ScenarioFramework.CreateTimerTrigger(M1ReoccurringMediumAttack, delay[Difficulty])
    delay = {900, 540, 420}
    ScenarioFramework.CreateTimerTrigger(M1ReoccurringHeavyAttack, delay[Difficulty])

    -- Send scouts at the player to encourage them to build defenses
    delay = {120, 60, 30}
    ScenarioFramework.CreateTimerTrigger(M1Scout, delay[Difficulty])

    -- Dialog that is delayed from the start of the mission
    ScenarioFramework.CreateTimerTrigger(M1DialoguesThread, 5*60)
end

function M1ControlCenterSpotted()
    ScenarioFramework.Dialogue(OpStrings.A06_M01_030)
end

--[[
    -- speed2: Replaced by one function since they all have same time between dialogues 
    function M1Dialog1()
        if (ScenarioInfo.MissionNumber == 1) and not ScenarioInfo.OpEnded then
            ScenarioFramework.Dialogue(RandomAikoTaunt())
            ScenarioFramework.CreateTimerTrigger(M1Dialog2, 3*60)
        end
    end

    function M1Dialog2()
        if (ScenarioInfo.MissionNumber == 1) and not ScenarioInfo.OpEnded then
            ScenarioFramework.Dialogue(RandomRedTaunt())
            ScenarioFramework.CreateTimerTrigger(M1Dialog3, 3*60)
        end
    end

    function M1Dialog3()
        if (ScenarioInfo.MissionNumber == 1) and not ScenarioInfo.OpEnded then
            ScenarioFramework.Dialogue(RandomAikoTaunt())
            ScenarioFramework.CreateTimerTrigger(M1Dialog4, 3*60)
        end
    end

    function M1Dialog4()
        if (ScenarioInfo.MissionNumber == 1) and not ScenarioInfo.OpEnded then
            ScenarioFramework.Dialogue(RandomRedTaunt())
            ScenarioFramework.CreateTimerTrigger(M1Dialog5, 3*60)
        end
    end

    function M1Dialog5()
        if (ScenarioInfo.MissionNumber == 1) and not ScenarioInfo.OpEnded then
            ScenarioFramework.Dialogue(RandomAikoTaunt())
            ScenarioFramework.CreateTimerTrigger(M1Dialog6, 3*60)
        end
    end

    function M1Dialog6()
        if (ScenarioInfo.MissionNumber == 1) and not ScenarioInfo.OpEnded then
            ScenarioFramework.Dialogue(RandomRedTaunt())
        end
    end
--]]

function M1DialoguesThread()
    WaitSeconds(3*60)

    local i = 1
    while i <= 6 and ScenarioInfo.MissionNumber == 1 and not ScenarioInfo.OpEnded do
        if math.mod(i, 2) == 0 then
            ScenarioFramework.Dialogue(RandomRedTaunt())
        else
            ScenarioFramework.Dialogue(RandomAikoTaunt())
        end
        WaitSeconds(3*60)
    end
end

function M1NavalAttack()
    if not ScenarioInfo.M1NavalAttackLaunched then
        ScenarioInfo.M1NavalAttackLaunched = true
    end

    local CybranNavy = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M1_Naval_Attack_D' .. Difficulty, 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(CybranNavy, 'M1_Cybran_Naval_Attack_Chain')
    
    local UEFNavy = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M1_Naval_Attack_D' .. Difficulty, 'AttackFormation')
    for _, v in UEFNavy:GetPlatoonUnits() do
        if EntityCategoryContains(categories.ues0401 ,v) then
            IssueDive({v})
        end
    end
    ScenarioFramework.PlatoonPatrolChain(UEFNavy, 'M1_UEF_Naval_Attack_Chain')

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
        local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M1_Light_Attack_D' .. Difficulty, 'AttackFormation')
        if Random(0, 100) < 30 then
            ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_Naval_Patrol')
        else
            ScenarioFramework.PlatoonPatrolChain(platoon, 'M1_UEF_Light_Attack_Chain')
        end

        local delay = {240, 120, 80}
        ScenarioFramework.CreateTimerTrigger(M1ReoccurringLightAttack, delay[Difficulty])

        ScenarioFramework.CreateTimerTrigger(M1CybranLightAttack, 30)
    end
end

function M1CybranLightAttack()
    if ScenarioInfo.MissionNumber == 1 then
        local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M1_Light_Attack_D' .. Difficulty, 'AttackFormation')
        if Random(0, 100) < 30 then
            ScenarioFramework.PlatoonPatrolChain(platoon, 'M2_Cybran_Naval_Patrol')
        else
            ScenarioFramework.PlatoonPatrolChain(platoon, 'M1_Cybran_Light_Attack_Chain')
        end
    end
end

function M1ReoccurringMediumAttack()
    if ScenarioInfo.MissionNumber == 1 then     
        local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M1_Medium_Attack_D' .. Difficulty, 'AttackFormation')
        ScenarioFramework.PlatoonPatrolChain(platoon, 'M1_UEF_Medium_Attack_Chain')

        local delay = {600, 480, 300}
        ScenarioFramework.CreateTimerTrigger(M1ReoccurringMediumAttack, delay[Difficulty])

        ScenarioFramework.CreateTimerTrigger(M1CybranMediumAttack, 30)
    end
end

function M1CybranMediumAttack()
    if ScenarioInfo.MissionNumber == 1 then
        local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M1_Medium_Attack_D' .. Difficulty, 'AttackFormation')
        if Random(0, 100) < 30 then
            ScenarioFramework.PlatoonPatrolChain(platoon, 'M2_Cybran_Naval_Patrol')
        else
            ScenarioFramework.PlatoonPatrolChain(platoon, 'M1_Cybran_Medium_Attack_Chain')
        end
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
    ScenarioFramework.SetSharedUnitCap(660)

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
    ScenarioInfo.CybranCommander = ScenarioFramework.SpawnCommander('Cybran', 'Commander', false, LOC '{i RedFog}', true, false,
        {'AdvancedEngineering', 'T3Engineering', 'Teleporter', 'MicrowaveLaserGenerator'})
    -- Restrict building Naval factory, Torp def and AA
    ScenarioInfo.CybranCommander:AddBuildRestriction(categories.urb0103 + categories.zrb9603 + categories.urb2205 + categories.urb2304)

    -- sACU
    ScenarioFramework.SpawnCommander('Cybran', 'SubCommander', false, LOC '{i sCDR_Jericho}', false, false,
        {'NaniteMissileSystem', 'ResourceAllocation', 'Switchback'})

    -- Defense
    local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2_Initial_Air_Patrol_D' .. Difficulty, 'NoFormation')
    for _, v in platoon:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M2_Cybran_Air_Patrol')))
    end

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2_Initial_Land_Patrol_D' .. Difficulty, 'AttackFormation')
    for _, v in platoon:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolChain({v}, 'M2_Cybran_Land_Patrol')
    end

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2_Initial_Naval_Patrol_D' .. Difficulty, 'GrowthFormation')
    for _, v in platoon:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolChain({v}, 'M2_Cybran_Base_Naval_Patrol')
    end

    -- Attack
    ScenarioInfo.M2Attackers = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2_Attackers_D' .. Difficulty, 'AttackFormation')
    ScenarioInfo.M2Attackers:AddDestroyCallback(M2CybranAttackDefeated)
    ScenarioInfo.M2Attackers:MoveToLocation(ScenarioUtils.MarkerToPosition('M2_Cybran_Initial_Move'), false)

    ForkThread(CustomFunctions.EnableStealthOnAir)
    ForkThread(CustomFunctions.CheatEco)

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
    ScenarioFramework.CreateAreaTrigger(CybranNearControlCenter, ScenarioUtils.AreaToRect('M1_Control_Center_Near_Area'), categories.CYBRAN, true, false, ArmyBrains[Cybran], 1, false)

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
    if ScenarioInfo.M2P2Objective.Active then
       ScenarioFramework.Dialogue(OpStrings.A06_M02_050, nil, true)
       ScenarioFramework.CreateTimerTrigger(M2PreAttack2, 120)
    end
end

function M2PreAttack2()
    if ScenarioInfo.M2P2Objective.Active then
       ScenarioFramework.Dialogue(OpStrings.A06_M02_060, nil, true)
       ScenarioFramework.CreateTimerTrigger(M2AttackNow, 60)
    end
end

function M2AttackNow()
    if ScenarioInfo.M2P2Objective.Active then
        ScenarioFramework.Dialogue(OpStrings.A06_M02_070, nil, true)

        ScenarioInfo.M2Attackers:Stop()
        ScenarioInfo.M2Attackers:AggressiveMoveToLocation(ScenarioUtils.MarkerToPosition('M2_Cybran_Target'))
        ScenarioInfo.M2Attackers:Patrol(ScenarioUtils.MarkerToPosition('AttackMarker'))
        ScenarioInfo.M2Attackers:Patrol(ScenarioUtils.MarkerToPosition('M1_Air_Defense_1'))
    end
end

function M2CybranAttackDefeated()
    ScenarioFramework.Dialogue(OpStrings.A06_M02_080)
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
    ScenarioFramework.SetSharedUnitCap(720)

    -- Create the wreckage of the UEF base that was "defeated" during mission 2
    ScenarioUtils.CreateArmyGroup('UEF', 'M3_Wreckage', true)

    -- Update the playable area
    ScenarioFramework.SetPlayableArea('M3_Playable_Area', true)

    -- Spawn the bases
    M3AeonAI.AeonM3BaseAI()
    M3AeonAI.AeonM3NavalBaseAI()
    M3AeonAI.AeonM3IslandBaseAI()
    
    local Antinukes = ArmyBrains[Aeon]:GetListOfUnits(categories.uab4302, false)
    for k, unit in Antinukes do
        unit:GiveTacticalSiloAmmo(3)
    end

    -- Walls
    ScenarioUtils.CreateArmyGroup('Aeon', 'M3_Base_Walls_D2')

    -- Marxon
    ScenarioInfo.AeonCommander = ScenarioFramework.SpawnCommander('Aeon', 'Commander', false, LOC '{i Marxon}', true, false,
        {'CrysalisBeam', 'ShieldHeavy', 'EnhancedSensors'})

    -- Arnold
    ScenarioInfo.FriendlyCommander = ScenarioUtils.CreateArmyUnit('Aeon', 'Friendly_Commander')
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

    -- Spawn a naval force and move them to the player's base
    local AeonNavy = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M3_Naval_Attack_D' .. Difficulty, 'GrowthFormation')
    AeonNavy:AggressiveMoveToLocation(ScenarioUtils.MarkerToPosition('M3_Naval_Patrol_1'))
    AeonNavy:Patrol(ScenarioUtils.MarkerToPosition('M3_Naval_Patrol_2'))
    AeonNavy:Patrol(ScenarioUtils.MarkerToPosition('M3_Naval_Patrol_1'))

    -- Briefing
    ScenarioFramework.Dialogue(OpStrings.A06_M03_010, IntroMission3NIS, true)
end

function IntroMission3NIS()
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
end

function M3IslandExperimentalCompleted()
    -- If the bonus objective is still active, mark is as lost
    if ScenarioInfo.M3B1Objective.Active then
        ScenarioInfo.M3B1Objective:ManualResult(false)
    end
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
--[[
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
--]]
