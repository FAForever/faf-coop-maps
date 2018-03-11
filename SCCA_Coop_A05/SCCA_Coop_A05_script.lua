-- ****************************************************************************
-- **
-- **  File     :  /maps/SCCA_Coop_A05/SCCA_Coop_A05_script.lua
-- **  Author(s):  Drew Staltman
-- **
-- **  Summary  :
-- **
-- **  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
-- ****************************************************************************
local M1ArielAI = import('/maps/SCCA_Coop_A05/SCCA_Coop_A05_m1arielai.lua')
local M2UEFAI = import('/maps/SCCA_Coop_A05/SCCA_Coop_A05_m2uefai.lua')
local M3ArielAI = import('/maps/SCCA_Coop_A05/SCCA_Coop_A05_m3arielai.lua')
local Objectives = import('/lua/SimObjectives.lua')
local OpStrings = import('/maps/SCCA_Coop_A05/SCCA_Coop_A05_Strings.lua')
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioStrings = import('/lua/scenariostrings.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')

----------
-- Globals
----------
ScenarioInfo.Player1 = 1
ScenarioInfo.Ariel = 2
ScenarioInfo.UEF = 3
ScenarioInfo.Colonies = 4
ScenarioInfo.Player2 = 5
ScenarioInfo.Player3 = 6
ScenarioInfo.Player4 = 7

---------
-- Locals
---------
local Player1 = ScenarioInfo.Player1
local Player2 = ScenarioInfo.Player2
local Player3 = ScenarioInfo.Player3
local Player4 = ScenarioInfo.Player4
local Ariel = ScenarioInfo.Ariel
local UEF = ScenarioInfo.UEF
local Colonies = ScenarioInfo.Colonies

local Difficulty = ScenarioInfo.Options.Difficulty

local LeaderFaction
local LocalFaction

-------------
-- Debug Only
-------------
local SkipM1 = false
local SkipUEFAttack = false

-----------
-- Start up
-----------
function OnPopulate(scenario)
    ScenarioUtils.InitializeScenarioArmies()
    LeaderFaction, LocalFaction = ScenarioFramework.GetLeaderAndLocalFactions()

    local tblArmy = ListArmies()

    -- Give half of the base to player 2
    ScenarioInfo.RhizaUnit = ScenarioUtils.CreateArmyUnit('Player1', 'Rhiza_Unit')
    if tblArmy[ScenarioInfo.Player2] then
        ScenarioInfo.RhizaUnit = ScenarioFramework.GiveUnitToArmy(ScenarioInfo.RhizaUnit, Player2)
    end
    ScenarioInfo.RhizaUnit:SetCustomName(LOC '{i sCDR_Rhiza}')
    ScenarioFramework.CreateUnitDestroyedTrigger(PlayerCDRDestroyed, ScenarioInfo.RhizaUnit)
    IssueMove({ScenarioInfo.RhizaUnit}, ScenarioUtils.MarkerToPosition('Rhiza_MoveTo_Marker'))

    ScenarioUtils.CreateArmyGroup('Player1', 'Player_Base_1')
    local baseToGive = ScenarioUtils.CreateArmyGroup('Player1', 'Player_Base_2')
    if tblArmy[ScenarioInfo.Player2] then
        for _, v in baseToGive do
            ScenarioFramework.GiveUnitToArmy(v, Player2)
        end
    end

    local airPatrol = ScenarioUtils.CreateArmyGroupAsPlatoon('Player1', 'Air_Patrol', 'NoFormation')
    ScenarioFramework.PlatoonPatrolChain(airPatrol, 'Player_Air_Patrol_Chain')

    local groundPatrol = ScenarioUtils.CreateArmyGroup('Player1', 'Ground_Patrol')
    if tblArmy[ScenarioInfo.Player2] then
        local givenPatrol = {}
        for _, v in groundPatrol do
            local unit = ScenarioFramework.GiveUnitToArmy(v, Player2)
            table.insert(givenPatrol, unit)
        end
        ScenarioFramework.GroupFormPatrolChain(givenPatrol, 'Player_Land_Patrol_Chain', 'AttackFormation')
    else
        ScenarioFramework.GroupFormPatrolChain(groundPatrol, 'Player_Land_Patrol_Chain', 'AttackFormation')
    end

    -- Some activity in the player base
    local trans1 = ScenarioUtils.CreateArmyUnit('Player1', 'Start_Trans1')
    local trans2 = ScenarioUtils.CreateArmyUnit('Player1', 'Start_Trans2')
    IssueMove({trans1}, ScenarioUtils.MarkerToPosition('Start_TransMove_1'))
    IssueMove({trans2}, ScenarioUtils.MarkerToPosition('Start_TransMove_2'))
    local eng1 = ScenarioInfo.UnitNames[Player1]['Start_Engineer_1']
    IssueMove({eng1}, ScenarioUtils.MarkerToPosition('Start_Eng_Moveto_1'))

    -- Colonies
    ScenarioInfo.WestColony = ScenarioUtils.CreateArmyGroup('Colonies', 'West_Colony')
    for k,v in ScenarioInfo.WestColony do
        v:SetCapturable(false)
        v:SetReclaimable(false)
    end
    ScenarioInfo.EastColony = ScenarioUtils.CreateArmyGroup('Colonies', 'East_Colony')
    for k,v in ScenarioInfo.EastColony do
        v:SetCapturable(false)
        v:SetReclaimable(false)
    end
    ScenarioUtils.CreateArmyGroup('Colonies', 'Colony_Defenses')
    ArmyBrains[Colonies]:GiveStorage('ENERGY', 5000)

    -- UEF Power for shields
    ScenarioInfo.M1UEFPgenGroup = {}
    local unit = ScenarioUtils.CreateArmyUnit('UEF', 'UEF_Pgen')
    table.insert(ScenarioInfo.M1UEFPgenGroup, unit)
    unit = ScenarioUtils.CreateArmyUnit('UEF', 'UEF_Storage')
    table.insert(ScenarioInfo.M1UEFPgenGroup, unit)

    -- Ariel
    M1ArielAI.ArielM1AirBaseAI()
end

function OnStart(self)
    -- Lock off buildable tech for player and his buddies the enemy
     ScenarioFramework.AddRestrictionForAllHumans(
        (categories.NAVAL * categories.TECH3) +
        categories.EXPERIMENTAL +
        categories.PRODUCTFA + -- All FA Units

        categories.uab4302 +
        categories.uab0301 +
        categories.uab2305 +
        categories.uab3104 +
        categories.uab2302 +
        categories.uab0304 +
        categories.daa0206 +   -- Mercy
        categories.dal0310 +   -- Absolver
        categories.dalk003 +   -- T3 Mobile AA

        categories.ueb0301 +
        categories.ueb2305 +
        categories.ueb3104 +
        categories.ueb2302 +
        categories.ueb0304
    )

    ScenarioFramework.RestrictEnhancements({'Teleporter'})

     -- Colors
    ScenarioFramework.SetAeonColor(Player1)
    ScenarioFramework.SetAeonNeutralColor(Ariel)
    ScenarioFramework.SetUEFColor(UEF)
    ScenarioFramework.SetUEFAllyColor(Colonies)
    local colors = {
        ['Player2'] = {165, 200, 102}, 
        ['Player3'] = {46, 139, 87}, 
        ['Player4'] = {102, 255, 204}
    }
    local tblArmy = ListArmies()
    for army, color in colors do
        if tblArmy[ScenarioInfo[army]] then
            ScenarioFramework.SetArmyColor(ScenarioInfo[army], unpack(color))
        end
    end

    -- Unit Cap
    ScenarioFramework.SetSharedUnitCap(480)

    -- Don't share resources
    ArmyBrains[Colonies]:SetResourceSharing(false)

    -- Playable area
    ScenarioFramework.SetPlayableArea('M1_Playable_Area', false)

    -- Zoom in and start the mission
    ScenarioFramework.StartOperationJessZoom('Start_Camera_Area', IntroMission1)
end

-----------
-- End Game
-----------
function PlayerCDRDestroyed(unit)
    -- Rhiza dies
    if EntityCategoryContains(categories.SUBCOMMANDER, unit) then
        ScenarioFramework.Dialogue(OpStrings.A05_M01_130)
    else
        -- Player dies
        ScenarioFramework.PlayerDeath(unit, OpStrings.A05_D01_010)
    end
end

function PlayerLose()
    ScenarioFramework.EndOperationSafety()
    ScenarioFramework.FlushDialogueQueue()

    ScenarioFramework.Dialogue(OpStrings.A05_M01_150, ScenarioFramework.PlayerLose, true)

    -- colony not defended
    local camInfo = {
        blendTime = 2.5,
        holdTime = nil,
        orientationOffset = { math.pi, 0.7, 0 },
        positionOffset = { 0, 1, 0 },
        zoomVal = 65,
        spinSpeed = 0.03,
        overrideCam = true,
        markerCam = true,
    }
    ScenarioFramework.OperationNISCamera(ScenarioUtils.MarkerToPosition("East_Colony_Marker"), camInfo)
end

function WinGame()
    ScenarioInfo.OpComplete = true

    local secondaries = Objectives.IsComplete(ScenarioInfo.M1P1Obj)
        and Objectives.IsComplete(ScenarioInfo.M1P2Obj)
        and Objectives.IsComplete(ScenarioInfo.M2S2Obj)
        and Objectives.IsComplete(ScenarioInfo.M3S1)

    local bonus = Objectives.IsComplete(ScenarioInfo.M1B1) 
        and Objectives.IsComplete(ScenarioInfo.M1B2)
        and Objectives.IsComplete(ScenarioInfo.M1B3)
        and Objectives.IsComplete(ScenarioInfo.M2B1)
        and Objectives.IsComplete(ScenarioInfo.M3B1)

    ScenarioFramework.EndOperation(ScenarioInfo.OpComplete, ScenarioInfo.OpComplete, secondaries, bonus)
end

function CheatEco(army)
    ArmyBrains[army]:GiveStorage('MASS', 10000)
    ArmyBrains[army]:GiveStorage('ENERGY', 100000)

    while true do
        ArmyBrains[army]:GiveResource('MASS', 1000)
        ArmyBrains[army]:GiveResource('ENERGY', 50000)
        WaitSeconds(10)
    end
end

------------
-- Mission 1
------------
function IntroMission1()
    local tblArmy = ListArmies()
    local i = 1

    ForkThread(
        function()
            while tblArmy[ScenarioInfo['Player' .. i]] do
                if i ~= 2 then
                    ScenarioInfo['Player' .. i .. 'CDR'] = ScenarioFramework.SpawnCommander('Player' .. i, 'Commander', 'Warp', true, true, PlayerCDRDestroyed)
                    WaitSeconds(2)
                end
                i = i + 1
            end
        end
    )
    
    -- Delay opening of mission till after player is warped in
    if SkipM1 then
        IntroMission2()
    else
        ScenarioFramework.CreateTimerTrigger(StartMission1, 3.3)
    end
end

function StartMission1()
    -- Set up
    ScenarioInfo.MissionNumber = 1

    IssueMove({ScenarioInfo.Player1CDR}, ScenarioUtils.MarkerToPosition('Start_PlayerMove_1'))

    ScenarioFramework.Dialogue(OpStrings.A05_M01_010, M1AssignProtectObjective, true)

    -- Timer triggers
    ScenarioFramework.CreateTimerTrigger(M1BlakeIntro, 300)

    -- Start taunt loop
    ScenarioFramework.CreateTimerTrigger(PlayTaunt, 900)

    ForkThread(M1UEFAttacksThread)
    ForkThread(CheatEco, Ariel)
end

function M1BlakeIntro()
    -- Blake talky-talky scene
    ScenarioFramework.Dialogue(OpStrings.A05_M01_030)
end

function M1UEFAttacksThread()
    local attackGroups = {
        Land = {
            {name = 'M1_Titans_1', formation = 'GrowthFormation', chains = {1, 2}},
            {name = 'M1_Titans_2', formation = 'AttackFormation', chains = {3, 4}},
            {name = 'M1_Arty', formation = 'GrowthFormation', chains = {1, 2, 3, 4}},
            {name = 'M1_T2_Attack_1', formation = 'AttackFormation', chains = {1, 2}},
            {name = 'M1_T2_Attack_2', formation = 'AttackFormation', chains = {3, 4}},
            {name = 'M1_Pillars_1', formation = 'GrowthFormation', chains = {1, 2}},
            {name = 'M1_Pillars_2', formation = 'GrowthFormation', chains = {3, 4}},
            {name = 'M1_MMLs_1', formation = 'GrowthFormation', chains = {1, 2}},
            {name = 'M1_MMLs_2', formation = 'GrowthFormation', chains = {3, 4}},
            {name = 'M1_Flak_1', formation = 'AttackFormation', chains = {1, 2}},
            {name = 'M1_Flak_2', formation = 'AttackFormation', chains = {3, 4}},
        },
        Air = {
            'M1_UEF_Bombers', 'M1_UEF_Bombers', 'M1_UEF_Gunships', 'M1_UEF_Gunships', 'M1_UEF_Gunships', 'M1_UEF_ASFs'
        },
    }
    local numAirGroups = table.getn(attackGroups.Air)
    local numLandGroups = table.getn(attackGroups.Land)
    local delay = {{55, 100}, {45, 80}, {35, 60}}

    while ScenarioInfo.MissionNumber == 1 do
        -- Pick random land group
        local group = attackGroups.Land[Random(1, numLandGroups)]
        local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', group.name .. '_D' .. Difficulty, group.formation)
        ScenarioFramework.PlatoonPatrolChain(platoon, 'UEF_M1_Attack_Chain_' .. group.chains[Random(1, table.getn(group.chains))])

        -- Air group, using same formation and all 4 attack chains
        local name = attackGroups.Air[Random(1, numAirGroups)]
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', name .. '_D' .. Difficulty, 'GrowthFormation')
        ScenarioFramework.PlatoonPatrolChain(platoon, 'UEF_M1_Attack_Chain_' .. Random(1, 4))

        WaitSeconds(Random(unpack(delay[Difficulty])))
    end
end

function M1AssignProtectObjective()
    local objUnits = ScenarioInfo.EastColony
    for _, unit in ScenarioInfo.WestColony do
        table.insert(objUnits, unit)
    end
    ScenarioInfo.M1NumberCivBuildings = table.getn(objUnits)

    ---------------------------------------
    -- Primary Objective - Protect Colonies
    ---------------------------------------
    ScenarioInfo.M1P3Obj = Objectives.Protect(
        'primary',                               -- type
        'incomplete',                            -- complete
        OpStrings.M1P3Title,                     -- title
        LOCF(OpStrings.M1P3Description, 50),     -- description
        {                                        -- target
            Units = objUnits,
            MarkUnits = true,
            PercentProgress = true,
            NumRequired = math.ceil(ScenarioInfo.M1NumberCivBuildings / 2)
        }
    )
    ScenarioInfo.M1P3Obj:AddResultCallback(
        function(result)
            if not result then
                PlayerLose()
            else
                ScenarioFramework.Dialogue(OpStrings.A05_M01_160, IntroMission2, true)
            end
        end
    )

    -----------------------------------------
    -- Bonus Objective - Build T3 Mobile Arty
    -----------------------------------------
    local num = {70, 85, 100}
    ScenarioInfo.M1B1 = Objectives.ArmyStatCompare(
        'bonus',
        'incomplete',
        OpStrings.M1B1Title,
        LOCF(OpStrings.M1B1Description, num[Difficulty]),
        'build',
        {
            Armies = {'HumanPlayers'},
            StatName = 'Units_History',
            CompareOp = '>=',
            Value = num[Difficulty],
            Category = categories.ual0304 + categories.uel0304,
            Hidden = true,
        }
    )

    -----------------------------------------
    -- Bonus Objective - Kill Enemy Air units 
    -----------------------------------------
    num = {200, 300, 400}
    ScenarioInfo.M1B2 = Objectives.ArmyStatCompare(
        'bonus',
        'incomplete',
        OpStrings.M1B2Title,
        LOCF(OpStrings.M1B2Description, num[Difficulty]),
        'kill',
        {
            Armies = {'HumanPlayers'},
            StatName = 'Enemies_Killed',
            CompareOp = '>=',
            Value = num[Difficulty],
            Category = categories.AIR * categories.MOBILE,
            Hidden = true,
        }
    )

    -------------------------------------------
    -- Bonus Objective - No cilivian casualties
    -------------------------------------------
    ScenarioInfo.M1B3 = Objectives.Protect(
        'bonus',                                 -- type
        'incomplete',                            -- complete
        OpStrings.M1B3Title,                     -- title
        OpStrings.M1B3Description,               -- description
        {                                        -- target
            Units = objUnits,
            MarkUnits = false,
            Hidden = true,
        }
    )

    -------------------------------------
    -- Bonus Objective - Capture UEF City
    -------------------------------------
    -- ScenarioInfo.M1B4 = Objectives.Capture(
    --     'bonus',                                 -- type
    --     'incomplete',                            -- complete
    --     OpStrings.M1B4Title,                     -- title
    --     OpStrings.M1B4Description,               -- description
    --     {                                        -- target
    --         Units = objUnits,
    --         MarkUnits = false,
    --         Hidden = true,
    --     }
    -- )

    WaitSeconds(15)

    ScenarioFramework.Dialogue(OpStrings.A05_M01_020, M1RevealShieldsObjective, true)
end

function M1RevealShieldsObjective()
    ------------------------------------
    -- Primary Objective - Build Shields
    ------------------------------------
    ScenarioInfo.M1P1Obj = Objectives.CategoriesInArea(
        'secondary',                    -- type
        'incomplete',                   -- complete
        OpStrings.M1P1Title,            -- title
        OpStrings.M1P1Description,      -- description
        'build',                        -- action
        {                               -- target
            MarkArea = true,
            Requirements = {
                {Area = 'M1P1_West_Area', Category = categories.uab4301, CompareOp = '>=', Value = 1},
                {Area = 'M1P1_East_Area', Category = categories.uab4301, CompareOp = '>=', Value = 1},
            },
            Category = categories.uab4301,
        }
    )
    ScenarioInfo.M1P1Obj:AddResultCallback(
        function(result)
            if result then
                ScenarioFramework.Dialogue(OpStrings.A05_M01_040, M1ShieldsBuilt, true)
            else
                ForkThread(M1ShieldsBuilt)
            end
        end
    )

    -- Fail if shields are not up after 12, 9, 6 minutes
    local time = {12, 9, 6}
    ScenarioFramework.CreateTimerTrigger(M1ShieldTimerCall, time[Difficulty]*60)
end

function M1ShieldTimerCall()
    if ScenarioInfo.M1P1Obj.Active then
        ScenarioInfo.M1P1Obj:ManualResult(false)
    end
end

function M1ShieldsBuilt()
    WaitSeconds(10)
    ScenarioFramework.Dialogue(OpStrings.A05_M01_050, M1AttackShields, true)
end

-- Send attacks on the colonies
function M1AttackShields()
    local westPlat = ScenarioUtils.CreateArmyGroupAsPlatoon('Ariel', 'M1_West_Colony_Bombers_D' .. Difficulty, 'NoFormation')
    westPlat:AggressiveMoveToLocation(ScenarioUtils.MarkerToPosition('West_Colony_Marker'))
    local eastPlat = ScenarioUtils.CreateArmyGroupAsPlatoon('Ariel', 'M1_East_Colony_Bombers_D' .. Difficulty, 'NoFormation')
    eastPlat:AggressiveMoveToLocation(ScenarioUtils.MarkerToPosition('East_Colony_Marker'))
    local bombers = {}
    for num, unit in westPlat:GetPlatoonUnits() do
        table.insert(bombers, unit)
    end
    for num, unit in eastPlat:GetPlatoonUnits() do
        table.insert(bombers, unit)
    end
    local deathPlat = ArmyBrains[Ariel]:MakePlatoon('', '')
    ArmyBrains[Ariel]:AssignUnitsToPlatoon(deathPlat, bombers, 'attack', 'Noformation')
    ScenarioFramework.CreatePlatoonDeathTrigger(M1ShieldsHeld, deathPlat)
end

-- Shield has held, talk amongst yourselves then start the nuke delay
function M1ShieldsHeld()
    ScenarioFramework.Dialogue(OpStrings.A05_M01_060, M1DelayNukes, true)
end

-- Delay before nuke objective revealed
function M1DelayNukes()
    WaitSeconds(10)
    ScenarioFramework.Dialogue(OpStrings.A05_M01_070, M1RevealNukeObjective, true)
end

-- Reveal that the player has work yet to be finished
function M1RevealNukeObjective()
    ScenarioFramework.RemoveRestrictionForAllHumans(categories.uab4302, true)

    -- Primary Objective 2
    ScenarioInfo.M1P2Obj = Objectives.Basic(
        'secondary',                           -- type
        'incomplete',                          -- complete
        OpStrings.M1P2Title,                   -- title
        OpStrings.M1P2Description,             -- description
        Objectives.GetActionIcon('build'),     -- action
        {                                      -- target
            MarkArea = true,
            Areas = {'M1P2_West_Area', 'M1P2_East_Area'},
            Category = categories.uab4302,
        }
    )

    ScenarioInfo.NukeDefensesCount = 0
    ForkThread(SiloAmmoThread, M1NukeDefensesBuilt, 'M1P2_West_Area')
    ForkThread(SiloAmmoThread, M1NukeDefensesBuilt, 'M1P2_East_Area')

    ScenarioFramework.CreateTimerTrigger(M1AttackWaveOne, 200)
    ScenarioFramework.CreateTimerTrigger(M1ObjectiveReminder, 600)
end

function SiloAmmoThread(callback, areaName)
    local hasAmmo = false
    local rect = ScenarioUtils.AreaToRect(areaName)
    while not hasAmmo do
        local units = GetUnitsInRect(rect)
        for k,v in units do
            if not v:IsDead() and EntityCategoryContains(categories.SILO * categories.ANTIMISSILE, v) then
                if v:GetTacticalSiloAmmoCount() > 0 then
                    if not hasAmmo then
                        hasAmmo = true
                        callback()
                        break
                    end
                end
            end
        end
        WaitSeconds(.5)
    end
end

function M1NukeDefensesTimerCall()
    if not ScenarioInfo.M1ArielNukesSent then
        ScenarioInfo.M1P2Obj:ManualResult(false)
    end
end

-- Player got them nukes up, give an anti-nuke and start nukes
function M1NukeDefensesBuilt()
    ScenarioInfo.NukeDefensesCount = ScenarioInfo.NukeDefensesCount + 1
    if ScenarioInfo.NukeDefensesCount == 2 then
        ScenarioInfo.NukesBuilt = true
        if not ScenarioInfo.M1ArielNukesSent then
            ScenarioInfo.M1P2Obj:ManualResult(true)
            ScenarioFramework.Dialogue(OpStrings.A05_M01_080, nil, true)

            -- Anti-nukes built camera
            local camInfo = {
                blendTime = 1.0,
                holdTime = 4,
                orientationOffset = { 2.9, 0.3, 0 },
                positionOffset = { 0, 1, 0 },
                zoomVal = 45,
                markerCam = true,
            }
            ScenarioFramework.OperationNISCamera(ScenarioUtils.MarkerToPosition("West_Colony_Marker"), camInfo)
            ScenarioFramework.CreateTimerTrigger(M1ArielNukes, 120) -- launch quick now, for show
        end
    end
end

-- Nuke the player and then talk smack, timer after nukes to start realz attacks
function M1ArielNukes()
    if not ScenarioInfo.M1ArielNukesSent then
        ScenarioInfo.M1ArielNukesSent = true
        if not ScenarioInfo.NukesBuilt then
            ScenarioInfo.M1P2Obj:ManualResult(false)
        end

        local nukeLaunchers = ScenarioUtils.CreateArmyGroup('Ariel', 'M1_Nuke_Silos')
        for num, unit in nukeLaunchers do
            unit:AddProjectileDamagedCallback(M1NukeShotDown)
            unit:GiveNukeSiloAmmo(1)
            if num == 1 then
                IssueNuke({unit}, ScenarioUtils.MarkerToPosition('West_Colony_Marker'))
                ForkThread (M1NukeNISCamera,unit)
            else
                IssueNuke({unit}, ScenarioUtils.MarkerToPosition('East_Colony_Marker'))
            end
        end
        ScenarioFramework.Dialogue(OpStrings.A05_M01_090)
        ScenarioFramework.CreateTimerTrigger(M1NukeShotDown, 300)
    end
end

function M1NukeNISCamera(unit)
    -- Nukes launch camera
    -- need to give the nuke some time to pre-launch
    WaitSeconds(7)

    local camInfo = {
        blendTime = 0,
        holdTime = 7,
        orientationOffset = { 1.1781, 0.3, 0 },
        positionOffset = { 0, 1, 0 },
        zoomVal = 35,
        resetCam = true,
        playableAreaIn = 'M3_Playable_Area',
        playableAreaOut = 'M1_Playable_Area',
        vizRadius = 12,
    }
    ScenarioFramework.OperationNISCamera(unit, camInfo)
end

function M1NukeShotDown(projectile)
    if not ScenarioInfo.NukesShotDown then
        ScenarioInfo.NukesShotDown = 1
    else
        ScenarioInfo.NukesShotDown = ScenarioInfo.NukesShotDown + 1
    end
    if ScenarioInfo.NukesShotDown == 2 then
        ScenarioInfo.M1P3Obj:ManualResult(true)
        if ScenarioInfo.M1B3.Active then
            ScenarioInfo.M1B3:ManualResult(true)
        end
    end
end

function M1AttackWaveOne()
    ScenarioFramework.Dialogue(OpStrings.A05_M01_100, nil, true)

    WaitSeconds(20)
    local plat = ScenarioUtils.CreateArmyGroupAsPlatoon('Ariel', 'M1A1_Air_Group_D' .. Difficulty, 'ChevronFormation')
    plat:AggressiveMoveToLocation(ScenarioUtils.MarkerToPosition('East_Colony_Marker'))
    ScenarioFramework.CreateTimerTrigger(M1AttackWaveTwo, 140)
end

function M1AttackWaveTwo()
    ScenarioFramework.Dialogue(OpStrings.A05_M01_110, nil, true)

    local escorts = ScenarioUtils.CreateArmyGroupAsPlatoon('Ariel', 'M1A2_Escorts_D' .. Difficulty, 'NoFormation')
    ScenarioFramework.PlatoonPatrolChain(escorts, 'Ariel_M1_West_Air_Patrol_Chain')
    local units = ScenarioUtils.CreateArmyGroupAsPlatoon('Ariel', 'M1A2_Unit_Group_D' .. Difficulty, 'AttackFormation')
    local transports = ScenarioUtils.CreateArmyGroupAsPlatoon('Ariel', 'M1A2_Transport_Group_D' .. Difficulty, 'NoFormation')
    ScenarioFramework.CreateTimerTrigger(M1AttackThree, 180)
    ForkThread(M1LandAttack, units, transports, 'West')
end

function M1AttackThree()
    ScenarioFramework.Dialogue(OpStrings.A05_M01_120, nil, true)

    local westAir = ScenarioUtils.CreateArmyGroupAsPlatoon('Ariel', 'M1A3_West_Air_Attack_D' .. Difficulty, 'ChevronFormation')
    westAir:AggressiveMoveToLocation(ScenarioUtils.MarkerToPosition('West_Colony_Marker'))
    local westUnits = ScenarioUtils.CreateArmyGroupAsPlatoon('Ariel', 'M1A3_West_Ground_Units_D' .. Difficulty, 'AttackFormation')
    local westTransports = ScenarioUtils.CreateArmyGroupAsPlatoon('Ariel', 'M1A3_West_Transports_D' .. Difficulty, 'NoFormation')
    ForkThread(M1LandAttack, westUnits, westTransports, 'West')

    local eastAir = ScenarioUtils.CreateArmyGroupAsPlatoon('Ariel', 'M1A3_East_Air_Attack_D' .. Difficulty, 'ChevronFormation')
    eastAir:AggressiveMoveToLocation(ScenarioUtils.MarkerToPosition('East_Colony_Marker'))
    local eastUnits = ScenarioUtils.CreateArmyGroupAsPlatoon('Ariel', 'M1A3_East_Ground_Units_D' .. Difficulty, 'AttackFormation')
    local eastTransports = ScenarioUtils.CreateArmyGroupAsPlatoon('Ariel', 'M1A3_East_Transports_D' .. Difficulty, 'NoFormation')
    ForkThread(M1LandAttack, eastUnits, eastTransports, 'East')

    ScenarioFramework.CreateTimerTrigger(M1ArielNukes, 480)
end

-- Function to attack the colonies with transports
function M1LandAttack(units, transports, direction)
    local chain
    local marker
    if direction == 'West' then
        chain = 'Ariel_M1_West_Colony_Landing_Chain'
        marker = 'West_Colony_Marker'
    else
        chain = 'Ariel_M1_East_Colony_Landing_Chain'
        marker = 'East_Colony_Marker'
    end
    local aiBrain = units:GetBrain()
    ScenarioFramework.AttachUnitsToTransports(units:GetPlatoonUnits(), transports:GetPlatoonUnits())
    local cmd = transports:UnloadAllAtLocation(ScenarioPlatoonAI.PlatoonChooseRandomNonNegative(aiBrain, ScenarioUtils.ChainToPositions(chain), 2))
    while transports:IsCommandsActive(cmd) do
        WaitSeconds(2)
        if not aiBrain:PlatoonExists(transports) then
            return
        end
    end
    cmd = transports:MoveToLocation(ScenarioUtils.MarkerToPosition('Ariel_Transport_Return'), false)
    if aiBrain:PlatoonExists(units) then
        units:AggressiveMoveToLocation(ScenarioUtils.MarkerToPosition(marker))
    end
    while ArmyBrains[Ariel]:PlatoonExists(transports) and transports:IsCommandsActive(cmd) do
        WaitSeconds(5)
    end
    if ArmyBrains[Ariel]:PlatoonExists(transports) then
        for num, unit in transports:GetPlatoonUnits() do
            if not unit:IsDead() then
                unit:Destroy()
            end
        end
    end
end

------------
-- Mission 2
------------
function IntroMission2()
    ScenarioInfo.MissionNumber = 2

    -- Unit Cap
    ScenarioFramework.SetSharedUnitCap(660)
    
    -- Playable area
    ScenarioFramework.SetPlayableArea('M2_Playable_Area', true)

    -- Allow player to build awesomeness
    ScenarioFramework.RemoveRestrictionForAllHumans(
        categories.uab0301 +  -- T3 Land Factories
        categories.zab9601 +
        categories.ueb0301 +
        categories.zeb9601 +
        categories.uab3104 + -- Omni
        categories.ueb3104
    )

    for num, unit in GetUnitsInRect(ScenarioUtils.AreaToRect('M1P2_West_Area')) do
        if EntityCategoryContains(categories.STRUCTURE, unit) then
            unit:SetDoNotTarget(true)
        end
    end
    for num, unit in GetUnitsInRect(ScenarioUtils.AreaToRect('M1P2_East_Area')) do
        if EntityCategoryContains(categories.STRUCTURE, unit) then
            unit:SetDoNotTarget(true)
        end
    end

    -- Set Alliances
    SetAlliance(UEF, Colonies, 'Neutral')
    SetAlliance(Ariel, Colonies, 'Neutral')

    -- Delete M1 Pgens
    for _, v in ScenarioInfo.M1UEFPgenGroup do
        v:Destroy()
    end

    ---------
    -- UEF AI
    ---------
    -- Main base
    M2UEFAI.UEFM2BaseAI()
    
    ScenarioUtils.CreateArmyGroup('UEF', 'West_Base_Walls')
    ScenarioUtils.CreateArmyGroup('UEF', 'West_Base_North_Defenses_D' .. Difficulty)
    ScenarioUtils.CreateArmyGroup('UEF', 'West_Base_South_Defenses_D' .. Difficulty)
    
    -- T2 Arty on the hill
    ScenarioInfo.WestArtillery = ScenarioUtils.CreateArmyGroup('UEF', 'West_Base_Artillery_D' .. Difficulty)
    for num, unit in ScenarioInfo.WestArtillery do
        ScenarioFramework.CreateArmyIntelTrigger(M2PlayerSeesWestT2Artillery, ArmyBrains[Player1], 'LOSNow', unit, true, categories.ALLUNITS, true, ArmyBrains[UEF])
    end

    -- Arty bases
    M2UEFAI.UEFM2ArtyNorthBaseAI()
    M2UEFAI.UEFM2ArtyMiddleBaseAI()
    M2UEFAI.UEFM2ArtySouthBaseAI()

    -- Blake's ACU
    ScenarioInfo.BlakeUnit = ScenarioFramework.SpawnCommander('UEF', 'Blake_Unit', false, LOC '{i CDR_Blake}', true, false,
        {'Shield', 'DamageStabilization', 'ResourceAllocation'})
    ScenarioInfo.BlakeUnit:SetAutoOvercharge(true)

    -- Initial Patrols
    -- Main Base
    local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'West_Base_Initial_Air_Patrol_D' .. Difficulty, 'NoFormation')
    for _, v in platoon:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('UEF_WestBase_Air_Patrol_Chain')))
    end

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'West_Base_Patrol_Arty_North_D' .. Difficulty, 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'UEF_M2_West_Base_Arty_Patrol_North')
    
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'West_Base_Patrol_Arty_South_D' .. Difficulty, 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'UEF_M2_West_Base_Arty_Patrol_South')

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'West_Base_Patrol_Land_1_D' .. Difficulty, 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'UEF_M2_West_Base_Land_Patrol_Chain_1')

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'West_Base_Patrol_Land_2_D' .. Difficulty, 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'UEF_M2_West_Base_Land_Patrol_Chain_2')

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'West_Base_Patrol_Land_3_D' .. Difficulty, 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'UEF_M2_West_Base_Land_Patrol_Chain_3')

    -- Arty bases
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'North_Unit_Defenses_D' .. Difficulty, 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'UEF_M2_North_Artillery_Patrol_Chain')

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'Middle_Unit_Defenses_D' .. Difficulty, 'AttackFormation')

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'South_Unit_Defenses_D' .. Difficulty, 'NoFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'UEF_M2_South_Artillery_Patrol_Chain')

    -- Wreckages
    ScenarioUtils.CreateArmyGroup('UEF' ,'Wreck_M2', true)

    -- Resources for AI
    ArmyBrains[UEF]:GiveResource('MASS', 10000)

    if not SkipUEFAttack then
        Mission2CounterAttack()
    end
    ScenarioFramework.Dialogue(OpStrings.A05_M02_010, StartMission2, true)
end

function Mission2CounterAttack()
    local quantity = {}
    local trigger = {}
    local platoon

    for i = 1, 3 do
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M2_Air_Counter_' ..  i, 'GrowthFormation')
        ScenarioFramework.PlatoonPatrolChain(platoon, 'UEF_M2_Bomber_Chain_' .. i)
    end

    for i = 1, 2 do
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M2_UEF_Drops_Counter_' .. i, 'AttackFormation')
        ScenarioFramework.PlatoonAttackWithTransports(platoon, 'UEF_M2_Landing_Chain', 'UEF_M2_Attack_Chain', true)
    end

    -- sends gunships and strats at mass extractors up to 2, 4, 6 if < 400 units, up to 4, 6, 8 if >= 400 units
    local extractors = ScenarioFramework.GetListOfHumanUnits(categories.MASSEXTRACTION)
    local num = table.getn(extractors)
    quantity = {2, 4, 6}
    if num > 0 then
        if ScenarioFramework.GetNumOfHumanUnits(categories.ALLUNITS - categories.WALL) < 400 then
            if num > quantity[Difficulty] then
                num = quantity[Difficulty]
            end
        else
            quantity = {4, 6, 8}
            if num > quantity[Difficulty] then
                num = quantity[Difficulty]
            end
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M2_UEF_Adapt_Mex_Gunships_D' .. Difficulty, 'GrowthFormation')
            IssueAttack(platoon:GetPlatoonUnits(), extractors[i])
            IssueAggressiveMove(platoon:GetPlatoonUnits(), ScenarioUtils.MarkerToPosition('Start_TransMove_1'))

            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('UEF', 'M2_UEF_Adapt_Strat', 'GrowthFormation', 5)
            IssueAttack(platoon:GetPlatoonUnits(), extractors[i])
            IssueAggressiveMove(platoon:GetPlatoonUnits(), ScenarioUtils.MarkerToPosition('Start_TransMove_1'))

            local guard = ScenarioUtils.CreateArmyGroup('UEF', 'M2_UEF_Adapt_StratGuard')
            IssueGuard(guard, platoon:GetPlatoonUnits()[1])
        end
    end

    -- sends T3 gunships at every other shield, up to [1, 3, 10]
    quantity = {2, 4, 10}
    local shields = ScenarioFramework.GetListOfHumanUnits(categories.SHIELD * categories.STRUCTURE)
    num = table.getn(shields)
    if num > 0 then
        num = math.ceil(num/2)
        if num > quantity[Difficulty] then
            num = quantity[Difficulty]
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('UEF', 'M2_UEF_Adapt_T3Gunship', 'GrowthFormation', 5)
            IssueAttack(platoon:GetPlatoonUnits(), shields[i])
            IssueAggressiveMove(platoon:GetPlatoonUnits(), ScenarioUtils.MarkerToPosition('Start_TransMove_1'))
        end
    end

    -- sends transport attacks for every other T2/T3 tower, up to [2, 6, 10]
    num = ScenarioFramework.GetNumOfHumanUnits((categories.STRUCTURE * categories.DEFENSE) - categories.TECH1)
    quantity = {2, 6, 10}
    if num > 0 then
        num = math.ceil(num/2)
        if num > quantity[Difficulty] then
            num = quantity[Difficulty]
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M2_UEF_Adapt_Def_Drop_' .. Random(1, 2), 'AttackFormation')
            for k, v in platoon:GetPlatoonUnits() do
                if v:GetUnitId() == 'uea0104' then
                    local guards = ScenarioUtils.CreateArmyGroup('UEF', 'M2_UEF_Adapt_Def_Drop_ASF')
                    IssueGuard(guards, v)
                    break
                end
            end
            ScenarioFramework.PlatoonAttackWithTransports(platoon, 'UEF_M2_Landing_Chain', 'UEF_M2_Attack_Chain', false)
        end
    end

    -- sends air superiority if player has more than [60, 40, 20] t2/t3 planes, up to 10, 1 group per 9, 7, 5
    num = ScenarioFramework.GetNumOfHumanUnits((categories.AIR * categories.MOBILE) - categories.TECH1)
    quantity = {60, 40, 20}
    trigger = {9, 7, 5}
    if(num > quantity[Difficulty]) then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 10) then
            num = 10
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('UEF', 'M2_UEF_Adapt_AirSup', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'UEF_M2_Bomber_Chain_' .. Random(1, 3))
        end
    end

    -- sends air superiority if player has more than [60, 40, 20] strats, up to 10, 1 group per 30, 20, 10
    local strats = ScenarioFramework.GetListOfHumanUnits(categories.AIR * categories.TECH3 * categories.BOMBER)
    num = table.getn(strats)
    quantity = {6, 12, 18}
    if num > 0 then
        if num > quantity[Difficulty] then
            num = quantity[Difficulty]
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('UEF', 'M2_UEF_Adapt_StratHunt', 'GrowthFormation', 5)
            IssueAttack(platoon:GetPlatoonUnits(), strats[i])
            ScenarioFramework.PlatoonPatrolChain(platoon, 'UEF_M2_Attack_Chain')
        end
    end

    -- sends gunships if player has more than [70, 50, 30] t2/t3 land, up to 7, 1 group per 40, 25, 15
    num = ScenarioFramework.GetNumOfHumanUnits((categories.LAND * categories.MOBILE) - categories.TECH1 - categories.CONSTRUCTION)
    quantity = {70, 50, 30}
    trigger = {40, 25, 15}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if num > 7 then
            num = 7
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('UEF', 'M2_UEF_Adapt_Gunships', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'UEF_M2_Bomber_Chain_' .. Random(1, 3))
        end
    end

    -- sends gunships if player has more than [475, 450, 425] units
    num = ScenarioFramework.GetNumOfHumanUnits(categories.ALLUNITS - categories.WALL)
    quantity = {475, 450, 425}
    if num > quantity[Difficulty] then
        for i = 1, Difficulty do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('UEF', 'M2_UEF_Adapt_Gunships', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'UEF_M2_Bomber_Chain_' .. Random(1, 3))
        end
    end

    -- Make AI use the transports from initial attack
    ForkThread(
        function()
            WaitSeconds(90)
            AssignTransportsToPoll(ArmyBrains[UEF], 'UEF_West_Base')
        end
    )
end

function StartMission2()
    ------------------------------------------
    -- Primary Objective - Destroy Artilleries
    ------------------------------------------
    ScenarioInfo.M2P1Obj = Objectives.CategoriesInArea(
        'primary',
        'incomplete',
        OpStrings.M2P1Title,
        OpStrings.M2P1Description,
        'killorcapture',
        {
            Requirements = {
                {
                    Area = 'North_Artillery_Area',
                    Category = categories.uel0309 + categories.ueb2302,
                    CompareOp = '==',
                    Value = 0,
                    ArmyIndex = UEF,
                },
                {
                    Area = 'Middle_Artillery_Area',
                    Category = categories.uel0309 + categories.ueb2302,
                    CompareOp = '==',
                    Value = 0,
                    ArmyIndex = UEF,
                },
                {
                    Area = 'South_Artillery_Area',
                    Category = categories.uel0309 + categories.ueb2302,
                    CompareOp = '==',
                    Value = 0,
                    ArmyIndex = UEF,
                },
            },
            MarkArea = true,
            Category = categories.ueb2302,  -- forces icon
        }
    )
    ScenarioInfo.M2P1Obj:AddResultCallback(
        function(result)
            if result then
                ScenarioInfo.M2ArtilleryDestroyedBool = true
                ScenarioFramework.CreateTimerTrigger(M2WestBaseHelpDialogue, 180)
            end
        end
    )

    ----------------------------------------
    -- Bonus Objective - Capture 1 Artillery
    ----------------------------------------
    ScenarioInfo.M2B1 = Objectives.ArmyStatCompare(
        'bonus',
        'incomplete',
        OpStrings.M2B1Title,
        OpStrings.M2B1Description,
        'build',
        {
            Armies = {'HumanPlayers'},
            StatName = 'Units_Active',
            CompareOp = '>=',
            Value = 1,
            Category = categories.ueb2302,
            Hidden = true,
        }
    )

    -- Triggers
    -- middle and south arty once built
    for _, unit in ScenarioFramework.GetCatUnitsInArea(categories.uel0309, 'Middle_Artillery_Area', ArmyBrains[UEF]) do
        ScenarioFramework.CreateUnitBuiltTrigger(M2ArtilleryBuilt, unit, categories.ueb2302)
    end
    for _, unit in ScenarioFramework.GetCatUnitsInArea(categories.uel0309, 'South_Artillery_Area', ArmyBrains[UEF]) do
        ScenarioFramework.CreateUnitBuiltTrigger(M2ArtilleryBuilt, unit, categories.ueb2302)
    end
    
    -- Arty base destroyed
    ScenarioFramework.CreateAreaTrigger(M2NorthArtilleryDefeated, 'North_Artillery_Area', categories.uel0309 + categories.ueb2302, true, true, ArmyBrains[UEF])
    ScenarioFramework.CreateAreaTrigger(M2MiddleArtilleryDefeated, 'Middle_Artillery_Area', categories.uel0309 + categories.ueb2302, true, true, ArmyBrains[UEF])
    ScenarioFramework.CreateAreaTrigger(M2SouthArtilleryDefeated, 'South_Artillery_Area', categories.uel0309 + categories.ueb2302, true, true, ArmyBrains[UEF])

    -------------------------------------------
    -- Primary objective - Defeat UEF Commander
    -------------------------------------------
    ScenarioInfo.M2P2Obj = Objectives.Kill(
        'primary',
        'incomplete',
        OpStrings.M2P2Title,
        OpStrings.M2P2Description,
        {
            Units = {ScenarioInfo.BlakeUnit},
        }
    )
    ScenarioInfo.M2P2Obj:AddResultCallback(
        function(result)
            if result then
                if not ScenarioInfo.M2BlakeDestroyedBool then
                    ScenarioInfo.M2BlakeDestroyedBool = true
                else
                    return
                end
                ScenarioFramework.Dialogue(OpStrings.A05_M02_110, M2CheckObjectives)
            end
        end
    )

    ScenarioFramework.CreateTimerTrigger(M2ShieldReminder, 120)
    ScenarioFramework.CreateTimerTrigger(M2ArielMessage, 240)

    ScenarioFramework.CreateTimerTrigger(M2ObjectiveReminder, 600)
end

function M2ArtilleryBuilt(builder, unit)
    if not unit:IsBeingBuilt() then
        if not ScenarioInfo.SecondBuilt then
            ScenarioInfo.SecondBuilt = true
            ScenarioInfo.M2SecondArtillery = unit
            ScenarioFramework.Dialogue(OpStrings.A05_M02_040)
        elseif unit ~= ScenarioInfo.M2SecondArtillery and unit ~= ScenarioInfo.M2ThirdArtillery then
            ScenarioInfo.M2ThirdArtillery = unit
            ScenarioFramework.Dialogue(OpStrings.A05_M02_050)
        end
    end
end

function M2NorthArtilleryDefeated()
    M2OneArtilleryDefeated('north')
end

function M2MiddleArtilleryDefeated()
    M2OneArtilleryDefeated('middle')
end

function M2SouthArtilleryDefeated()
    M2OneArtilleryDefeated('south')
end

function M2OneArtilleryDefeated(artilleryArea)
    if not ScenarioInfo.M2ArtilleryKilled then
        ScenarioInfo.M2ArtilleryKilled = 1
    else
        ScenarioInfo.M2ArtilleryKilled = ScenarioInfo.M2ArtilleryKilled + 1
    end
    if ScenarioInfo.M2ArtilleryKilled == 1 then
        ScenarioFramework.Dialogue(OpStrings.A05_M02_020)
    elseif ScenarioInfo.M2ArtilleryKilled == 2 then
        ScenarioFramework.Dialogue(OpStrings.A05_M02_045)
    elseif ScenarioInfo.M2ArtilleryKilled == 3 then
        ScenarioFramework.Dialogue(OpStrings.A05_M02_060)
        ScenarioFramework.Dialogue(OpStrings.A05_M02_080, M2CheckObjectives)
    end
    -- primary artillery objective
    local camInfo = {
        blendTime = 1.0,
        holdTime = 4,
        orientationOffset = { 0, 0.2, 0 },
        positionOffset = { 0, 1.5, 0 },
        zoomVal = 25,
        markerCam = true,
    }
    if artilleryArea == 'north' then
        camInfo.orientationOffset[1] = -0.985
        unit = 'UEF_M2_North_Artillery'
    elseif artilleryArea == 'middle' then
        camInfo.orientationOffset[1] = 2.34
        camInfo.positionOffset = { -5, 1.5, 5 }
        unit = 'UEF_M2_Middle_Artillery'
    elseif artilleryArea == 'south' then
        camInfo.orientationOffset[1] = -2.5
        camInfo.positionOffset = { 5, 1.5, 5 }
        unit = 'UEF_M2_South_Artillery'
    end
    ScenarioFramework.OperationNISCamera(ScenarioUtils.MarkerToPosition(unit), camInfo)
end

function M2ShieldReminder()
    ScenarioFramework.Dialogue(OpStrings.A05_M02_030)
end

function M2ArielMessage()
    ScenarioFramework.Dialogue(OpStrings.A05_M02_070)
end

-- Secondary obj to kill T2 Artilleries
function M2PlayerSeesWestT2Artillery()
    if not ScenarioInfo.PlayerSeesWestArtilleryBool then
        ScenarioInfo.PlayerSeesWestArtilleryBool = true

        ScenarioFramework.Dialogue(OpStrings.A05_M02_090, nil, true)

        local westArtilUnits = {}
        for num, unit in ScenarioInfo.WestArtillery do
            if EntityCategoryContains(categories.ueb2303, unit) then
                table.insert(westArtilUnits, unit)
            end
        end

        -------------------------------------
        -- Secondary Objective - Kill T2 Arty
        -------------------------------------
        ScenarioInfo.M2S2Obj = Objectives.KillOrCapture(
            'secondary',
            'incomplete',
            OpStrings.M2S1Title,
            OpStrings.M2S1Description,
            {
                Units = westArtilUnits,
            }
        )
    end
end

function M2WestBaseHelpDialogue()
    if ScenarioInfo.MissionNumber == 2 and ScenarioInfo.M2P2Obj.Active then
        ScenarioFramework.Dialogue(OpStrings.A05_M02_100)
    end
end

function M2CheckObjectives()
    if not ScenarioInfo.M2P2Obj.Active and ScenarioInfo.M2ArtilleryDestroyedBool then
        ForkThread(EndMission2)
    end
end

function EndMission2()
    ScenarioFramework.Dialogue(OpStrings.A05_M02_150, IntroMission3, true)
end

------------
-- Mission 3
------------
function IntroMission3()
    if ScenarioInfo.MissionNumber ~= 2 then
        return
    end
    ScenarioInfo.MissionNumber = 3
    
    ScenarioFramework.SetSharedUnitCap(720)
    ScenarioFramework.SetPlayableArea('M3_Playable_Area', true)

    -----------
    -- Ariel AI
    -----------
    M3ArielAI.ArielM3BaseAI()

    ScenarioInfo.ArielCDR = ScenarioFramework.SpawnCommander('Ariel', 'Ariel_ACU', false, LOC '{i CDR_Ariel}', true, false,
        {'CrysalisBeam', 'Shield', 'ShieldHeavy', 'HeatSink'})

    ScenarioUtils.CreateArmyGroup('Ariel', 'M3_Extra_Mass')
    ScenarioUtils.CreateArmyGroup('Ariel', 'M3_Walls')
    ScenarioUtils.CreateArmyGroup('Ariel', 'M3_Defensive_Line')

    -- Base Air Patrols
    local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Ariel', 'M3_Eastern_Patrol', 'NoFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'Ariel_M3_East_Patrol_Chain')

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Ariel', 'M3_Main_Base_Patrol', 'NoFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'Ariel_MainBase_BasePatrolChain')

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Ariel', 'M3_NW_Patrol', 'NoFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'Ariel_M3_NW_Patrol_Chain')

    -- Colossus Spawn in and stuff
    ScenarioInfo.ColTransports = ScenarioUtils.CreateArmyGroupAsPlatoon('Ariel', 'Colossus_Transports_D' .. Difficulty, 'NoFormation')
    ScenarioInfo.ColLand = ScenarioUtils.CreateArmyGroupAsPlatoon('Ariel', 'Colossus_Land_Units_D' .. Difficulty, 'AttackFormation')
    ScenarioInfo.ColHover = ScenarioUtils.CreateArmyGroupAsPlatoon('Ariel', 'Colossus_Hover_Units_D' .. Difficulty, 'AttackFormation')
    ScenarioInfo.ColAir = ScenarioUtils.CreateArmyGroupAsPlatoon('Ariel', 'Colossus_Air_Units_D' .. Difficulty, 'NoFormation')
    ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.ColAir, 'Ariel_M3_Col_Air_Patrol')
    ScenarioInfo.ColossusPlat = ScenarioUtils.CreateArmyGroupAsPlatoon('Ariel', 'Colossus', 'AttackFormation')
    ScenarioInfo.Colossus = ScenarioInfo.ColossusPlat:GetPlatoonUnits()[1]
    ScenarioFramework.PauseUnitDeath(ScenarioInfo.Colossus)
    ScenarioFramework.AttachUnitsToTransports(ScenarioInfo.ColLand:GetPlatoonUnits(), ScenarioInfo.ColTransports:GetPlatoonUnits())

    -- Wreckages
    ScenarioUtils.CreateArmyGroup('UEF', 'Wreck_M3', true)

    StartMission3()
end

function StartMission3()
    local function AssignObjective()
        ---------------------------------
        -- Primary Objective - Kill Ariel
        ---------------------------------
        ScenarioInfo.M3P1 = Objectives.Kill(
            'primary',
            'incomplete',
            OpStrings.M3P1Title,
            OpStrings.M3P1Description,
            {
                Units = {ScenarioInfo.ArielCDR},
            }
        )
        ScenarioInfo.M3P1:AddResultCallback(
            function(result, unit)
                if result then
                    ScenarioFramework.EndOperationSafety()
                    ScenarioFramework.CDRDeathNISCamera(unit)

                    ScenarioFramework.Dialogue(OpStrings.A05_M03_050, nil, true)
                    ScenarioFramework.Dialogue(OpStrings.A05_M03_070, WinGame, true)
                end
            end
        )
    end
    -- Show the objective after the dialogue
    ScenarioFramework.Dialogue(OpStrings.A05_M03_010, AssignObjective, true)

    -- Attack with GC once it's spotted or after 90 seconds
    ScenarioFramework.CreateArmyIntelTrigger(ColosusObjective, ArmyBrains[Player1], 'LOSNow', ScenarioInfo.Colossus, true, categories.EXPERIMENTAL, true, ArmyBrains[Ariel])
    ScenarioFramework.CreateTimerTrigger(ColosusObjective, 90)

    ScenarioFramework.CreateTimerTrigger(M3ArielTaunt1, 360)
    ScenarioFramework.CreateTimerTrigger(M3ObjectiveReminder, 600)
end

function ColosusObjective()
    if ScenarioInfo.M3S1 then
        return
    end
    ScenarioFramework.Dialogue(OpStrings.A05_M03_020, nil, true)

    --------------------------------
    -- Secondary Objective - Kill GC
    --------------------------------
    ScenarioInfo.M3S1 = Objectives.Kill(
        'secondary',
        'incomplete',
        OpStrings.M3S1Title,
        OpStrings.M3S1Description,
        {
            Units = ScenarioInfo.ColossusPlat:GetPlatoonUnits(),
        }
    )
    ScenarioInfo.M3S1:AddResultCallback(
        function(result) -- (result, unit)
            if result then
                -- Colossus defeated camera
                local camInfo = {
                    blendTime = 1.0,
                    holdTime = 8,
                    orientationOffset = {math.pi, 0.15, 0},
                    positionOffset = {0, 3, 0},
                    zoomVal = 45,
                }
                ScenarioFramework.OperationNISCamera(ScenarioInfo.Colossus, camInfo) --ScenarioFramework.CDRDeathNISCamera(unit)

                ScenarioFramework.Dialogue(OpStrings.A05_M03_040)
            end
        end
    )

    ScenarioFramework.CreateTimerTrigger(M3Dialogue, 40)

    -- Start moving the Colossus attack at player
    for num, loc in ScenarioUtils.ChainToPositions('Ariel_M3_Colossus_Chain') do
        if num >= 3 then
            ScenarioInfo.ColHover:AggressiveMoveToLocation(loc)
        end
    end

    --local waitTime = {300, 180, 60}
    --WaitSeconds(waitTime[Difficulty])

    if ArmyBrains[Ariel]:PlatoonExists(ScenarioInfo.ColAir) then
        ScenarioInfo.ColAir:Stop()
        ScenarioFramework.PlatoonAttackChain(ScenarioInfo.ColAir, 'Ariel_M3_Colossus_Chain')
    end
    if ArmyBrains[Ariel]:PlatoonExists(ScenarioInfo.ColossusPlat) then
        ScenarioFramework.PlatoonAttackChain(ScenarioInfo.ColossusPlat, 'Ariel_M3_Colossus_Chain')
    end
    ForkThread(M3ColossusTransportsThread)
end

function M3ColossusTransportsThread()
    local transports = ScenarioInfo.ColTransports
    local units = ScenarioInfo.ColLand
    local aiBrain = transports:GetBrain()
    local i = 1
    local route = ScenarioUtils.ChainToPositions('Ariel_M3_Colossus_Chain')
    while i < table.getn(route) do
        ScenarioInfo.ColTransports:MoveToLocation(route[i], false)
        i = i + 1
    end

    local landingLocation = ScenarioPlatoonAI.PlatoonChooseRandomNonNegative(aiBrain, ScenarioUtils.ChainToPositions('Ariel_M3_Landing_Chain'), 2)
    cmd = transports:UnloadAllAtLocation(landingLocation)
    while aiBrain:PlatoonExists(transports) and transports:IsCommandsActive(cmd) do
        WaitSeconds(2)
    end
    -- Patrol attack route by creating attack route
    local attackRoute = ScenarioPlatoonAI.PlatoonChooseHighestAttackRoute(aiBrain, ScenarioUtils.ChainToPositions('Ariel_M3_Attack_Chain'), 2)
    if aiBrain:PlatoonExists(transports) then
        transports:MoveToLocation(ScenarioUtils.MarkerToPosition('Ariel_Transport_Return'), false)
        aiBrain:AssignUnitsToPlatoon('TransportPool', transports:GetPlatoonUnits(), 'Scout', 'None')
    end
    if aiBrain:PlatoonExists(units) then
        for k, v in attackRoute do
            units:Patrol(v)
        end
    end
end

-- Unlock nukes, bonus objective
function M3Dialogue()
    ScenarioFramework.RemoveRestrictionForAllHumans(categories.uab2305 + categories.ueb2305, true)

    ScenarioFramework.Dialogue(OpStrings.A05_M03_025)

    ---------------------------------
    -- Bonus Objective - Fire 5 Nukes
    ---------------------------------
    local num = {3, 4, 5}
    ScenarioInfo.M3B1 = Objectives.Basic(
        'bonus',
        'incomplete',
        OpStrings.M3B1Title,
        LOCF(OpStrings.M3B1Description, num[Difficulty]),
        '',
        {
            Hidden = true,
        }
    )
    ForkThread(TrackFiredNukes, num[Difficulty])
end

------------
-- Reminders
------------
function M1ObjectiveReminder()
    if ScenarioInfo.MissionNumber == 1 and not ScenarioInfo.NukesBuilt then
        ScenarioFramework.CreateTimerTrigger(M1ObjectiveReminder, 600)
        if Random(1,2) == 1 then
            ScenarioFramework.Dialogue(OpStrings.A05_M01_140)
        else
            ScenarioFramework.Dialogue(OpStrings.A05_M01_145)
        end
    end
end

function M2ObjectiveReminder()
    if ScenarioInfo.MissionNumber == 2 then
        ScenarioFramework.CreateTimerTrigger(M2ObjectiveReminder, 600)
        if not ScenarioInfo.M2ArtilleryDestroyedBool then
            if Random(1,2) == 1 then
                ScenarioFramework.Dialogue(OpStrings.A05_M02_130)
            else
                ScenarioFramework.Dialogue(OpStrings.A05_M02_135)
            end
        else
            if Random(1,2) == 1 then
                ScenarioFramework.Dialogue(OpStrings.A05_M02_140)
            else
                ScenarioFramework.Dialogue(OpStrings.A05_M02_145)
            end
        end
    end
end

function M3ObjectiveReminder()
    if ScenarioInfo.MissionNumber == 3 then
        ScenarioFramework.CreateTimerTrigger(M3ObjectiveReminder, 600)
        if Random(1,2) == 1 then
            ScenarioFramework.Dialogue(OpStrings.A05_M03_060)
        else
            ScenarioFramework.Dialogue(OpStrings.A05_M03_065)
        end
    end
end

---------
-- Taunts
---------
function PlayTaunt()
    ScenarioFramework.CreateTimerTrigger(PlayTaunt, 900)
    if ScenarioInfo.MissionNumber == 2 then
        ScenarioFramework.Dialogue(OpStrings['TAUNT'..Random(9,16)])
    else
        ScenarioFramework.Dialogue(OpStrings['TAUNT'..Random(1,8)])
    end
end

function M3ArielTaunt1()
    ScenarioFramework.Dialogue(OpStrings.A05_M03_030)
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

function TrackFiredNukes(numReguired)
    local numFiredNuked = 0
    local keepChecking = true
    local launchers = {}

    local function IncrementFiredNukes(projectile)
        numFiredNuked = numFiredNuked + 1

        if numFiredNuked == numReguired then
            keepChecking = false
            ScenarioInfo.M3B1:ManualResult(true)
        end
    end

    while keepChecking do
        for _, v in ScenarioFramework.GetListOfHumanUnits(categories.uab2305) do
            if not (launchers[v:GetEntityId()] or v:IsBeingBuilt()) then
                local oldOnNukeLaunched = v.OnNukeLaunched
                v.OnNukeLaunched = function(self)
                    IncrementFiredNukes()
                    oldOnNukeLaunched(self)
                end
                launchers[v:GetEntityId()] = true
            end
        end

        -- We dont need to check for new nuke launchers very often as they take long to build and load
        WaitSeconds(60)
    end
end

------------------
-- Debug functions
------------------
--[[
function OnCtrlF3()
end

function OnCtrlF4()
    if ScenarioInfo.MissionNumber == 1 then
        IntroMission2()
    elseif ScenarioInfo.MissionNumber == 2 then
        IntroMission3()
    end
end

function OnShiftF3()
end

function OnShiftF4()
end
--]]
