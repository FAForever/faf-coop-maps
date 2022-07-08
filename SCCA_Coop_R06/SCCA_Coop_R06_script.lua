-- ****************************************************************************
-- **
-- **  File     : /maps/SCCA_Coop_R06/SCCA_Coop_R06_script.lua
-- **  Author(s): Jessica St. Croix
-- **
-- **  Summary  :
-- **
-- **  Copyright © 2006 Gas Powered Games, Inc.  All rights reserved.
-- ****************************************************************************
local AeonAI = import('/maps/SCCA_Coop_R06/SCCA_Coop_R06_AeonAI.lua')
local Behaviors = import('/lua/ai/opai/OpBehaviors.lua')
local Buff = import('/lua/sim/Buff.lua')
local Objectives = import('/lua/SimObjectives.lua')
local OpStrings = import('/maps/SCCA_Coop_R06/SCCA_Coop_R06_strings.lua')
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local UEFAI = import('/maps/SCCA_Coop_R06/SCCA_Coop_R06_UEFAI.lua')
local Weather = import('/lua/weather.lua')

----------
-- Globals
----------
ScenarioInfo.Player1 = 1
ScenarioInfo.Aeon = 2
ScenarioInfo.UEF = 3
ScenarioInfo.BlackSun = 4
ScenarioInfo.Player2 = 5
ScenarioInfo.Player3 = 6
ScenarioInfo.Player4 = 7

---------
-- Locals
---------
local Player1 = ScenarioInfo.Player1
local Aeon = ScenarioInfo.Aeon
local UEF = ScenarioInfo.UEF
local BlackSun = ScenarioInfo.BlackSun
local Player2 = ScenarioInfo.Player2
local Player3 = ScenarioInfo.Player3
local Player4 = ScenarioInfo.Player4

local Difficulty = ScenarioInfo.Options.Difficulty

local LeaderFaction
local LocalFaction

local aikoTaunt = 1
local arnoldTaunt = 9

---------------------------
-- Objective Reminder Times
---------------------------
local M2P1Time = 300
local M2P2Time = 300
local M2P3Time = 300
local M3P2Time = 300
local SubsequentTime = 600

--------------
-- Debug Only!
--------------
local DEBUG = false
local SkipIntro = false

-----------
-- Start up
-----------
function OnPopulate(scenario)
    ScenarioUtils.InitializeScenarioArmies()
    LeaderFaction, LocalFaction = ScenarioFramework.GetLeaderAndLocalFactions()

    Weather.CreateWeather()

    ---------
    -- Player
    ---------
    -- Base
    ScenarioUtils.CreateArmyGroup('Player1', 'Base_D' .. Difficulty)

    -- Jericho
    ScenarioInfo.Jericho = ScenarioFramework.SpawnCommander('Player1', 'Jericho', false, LOC('{i sCDR_Jericho}'), false, JerichoKilled,
        {'FocusConvertor', 'NaniteMissileSystem', 'Switchback'})
    ScenarioFramework.CreateUnitGivenTrigger(JerichoGiven, ScenarioInfo.Jericho)

    -- Player Engineers
    local engineers = ScenarioUtils.CreateArmyGroup('Player1', 'Engineers')
    ScenarioFramework.GroupPatrolChain(engineers, 'Player_Jericho_Patrol_Chain')

    -- Player Mobile Defense
    local subs = ScenarioUtils.CreateArmyGroupAsPlatoon('Player1', 'Subs', 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(subs, 'Player_Subs_Patrol_Chain')

    local sonar = ScenarioUtils.CreateArmyUnit('Player1', 'MobileSonar')
    ScenarioFramework.GroupPatrolChain({sonar}, 'Player_Subs_Patrol_Chain')

    local landPatrol1 = ScenarioUtils.CreateArmyGroupAsPlatoon('Player1', 'LandPatrol1', 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(landPatrol1, 'Player_Land_Patrol_Chain')

    local landPatrol2 = ScenarioUtils.CreateArmyGroupAsPlatoon('Player1', 'LandPatrol2', 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(landPatrol2, 'Player_Land_Patrol_Chain')

    local airPatrol = ScenarioUtils.CreateArmyGroupAsPlatoon('Player1', 'AirPatrol', 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(airPatrol, 'Player_Air_Patrol_Chain')

    -------
    -- Aeon
    -------
    -- Aeon Base
    AeonAI.AeonBaseAI()

    -- Arnold ACU
    ScenarioInfo.Arnold = ScenarioFramework.SpawnCommander('Aeon', 'Arnold', false, LOC('{i CDR_Arnold}'), false, ArnoldDestroyed,
        {'Shield', 'ShieldHeavy', 'HeatSink', 'CrysalisBeam'})
    local cdrPlatoon = ArmyBrains[Aeon]:MakePlatoon('','')
    cdrPlatoon.PlatoonData = {
        LocationType = 'Aeon_Main_Base',
    }
    ArmyBrains[Aeon]:AssignUnitsToPlatoon(cdrPlatoon, {ScenarioInfo.Arnold}, 'Attack', 'AttackFormation')
    cdrPlatoon:SetAIPlan('PatrolLocationFactoriesAI')
    cdrPlatoon.CDRData = {
        LeashPosition = 'CzarStart',
        LeashRadius = 50,
    }
    cdrPlatoon:ForkThread(Behaviors.CDROverchargeBehavior)

    ScenarioInfo.ColossusPlatoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'Colossus', 'AttackFormation')
    ScenarioInfo.Colossus = ScenarioInfo.ColossusPlatoon:GetPlatoonUnits()[1]
    ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.ColossusPlatoon, 'Aeon_Base_Land_Patrol_Chain')
    ScenarioFramework.CreateUnitDeathTrigger(AeonAI.StartBuildingGCs, ScenarioInfo.Colossus)

    ScenarioInfo.ColossusGuards = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'ColossusGuards_D' .. Difficulty, 'NoFormation')
    ScenarioInfo.ColossusGuards:GuardTarget(ScenarioInfo.Colossus)

    -- Stationary naval
    ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'StationaryNaval', 'NoFormation')

    -- Aeon Mobile Defense
    local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'SubPatrolSouth', 'AttackFormation')
    ScenarioFramework.PlatoonPatrolRoute(platoon, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('AeonNaval_Chain')))

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'SubPatrolNorth', 'AttackFormation')
    ScenarioFramework.PlatoonPatrolRoute(platoon, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('AeonNavalN_Chain')))

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'SurfacePatrol', 'NoFormation')
    for _, v in platoon:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('AeonNaval_Chain')))
    end

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'LandPatrol_D' .. Difficulty, 'NoFormation')
    for _, v in platoon:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('AeonBase_Chain')))
    end

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'TorpedoBombers_D' .. Difficulty, 'NoFormation')
    for _, v in platoon:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('Aeon_Chain')))
    end

    ScenarioInfo.CzarBombers = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'CzarBombers_D' .. Difficulty, 'NoFormation')
    for _, v in ScenarioInfo.CzarBombers:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('Aeon_Chain')))
    end

    local scouts = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'Scouts', 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(scouts, 'Player_Air_Patrol_Chain')

    ------
    -- UEF
    ------
    -- Main base
    UEFAI.UEFMainBaseAI()

    local nukes = ArmyBrains[UEF]:GetListOfUnits(categories.NUKE * categories.SILO * categories.STRUCTURE, false)
    IssueStop(nukes)

    UEFAI.ControlCenterAI()
    -- Control Center
    for i = 1, 5 do
        local patrol = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'ControlCenterPatrol', 'AttackFormation')
        ScenarioFramework.PlatoonPatrolRoute(patrol, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('ControlCenter_Chain')))
    end

    -- UEF ACU Aiko
    ScenarioInfo.Aiko = ScenarioFramework.SpawnCommander('UEF', 'Aiko', false, LOC('{i CDR_Aiko}'), false, AikoDestroyed,
        {'DamageStabilization', 'HeavyAntiMatterCannon', 'Shield'})
    --ScenarioInfo.Aiko:SetAutoOvercharge(true)

    local cdrPlatoon = ArmyBrains[UEF]:MakePlatoon('','')
    cdrPlatoon.PlatoonData = {
        LocationType = 'UEF_Main_Base',
    }
    ArmyBrains[UEF]:AssignUnitsToPlatoon(cdrPlatoon, {ScenarioInfo.Aiko}, 'Attack', 'AttackFormation')
    cdrPlatoon:SetAIPlan('PatrolLocationFactoriesAI')
    cdrPlatoon.CDRData = {
        LeashPosition = 'UEFBase_Patrol2',
        LeashRadius = 50,
    }
    cdrPlatoon:ForkThread(Behaviors.CDROverchargeBehavior)

    ------------
    -- Objective
    ------------
    -- Control Center
    ScenarioInfo.ControlCenter = ScenarioUtils.CreateArmyUnit('BlackSun', 'ControlCenter')
    ScenarioInfo.ControlCenter:SetReclaimable(false)
    ScenarioInfo.ControlCenter:SetCapturable(false)
    ScenarioFramework.PauseUnitDeath(ScenarioInfo.ControlCenter)
    ScenarioFramework.CreateUnitDeathTrigger(ControlCenterDestroyed, ScenarioInfo.ControlCenter)

    -- Black Sun
    ScenarioInfo.BlackSunWeapon = ScenarioUtils.CreateArmyUnit('BlackSun', 'BlackSun')
    ScenarioInfo.BlackSunWeapon:SetCanTakeDamage(false)
    ScenarioInfo.BlackSunWeapon:SetCanBeKilled(false)
    ScenarioInfo.BlackSunWeapon:SetReclaimable(false)
    local support = ScenarioUtils.CreateArmyGroup('BlackSun', 'Black_Sun_Support')
    for k, v in support do
        v:SetReclaimable(false)
        v:SetCapturable(false)
        v:SetUnSelectable(true)
        v:SetDoNotTarget(true)
        v:SetCanTakeDamage(false)
        v:SetCanBeKilled(false)
    end
end

function JerichoKilled()
    ScenarioFramework.Dialogue(OpStrings.C06_M01_080)
    ScenarioFramework.CDRDeathNISCamera(ScenarioInfo.Jericho, 7)
end

function JerichoGiven(oldJericho, newJericho)
    ScenarioInfo.Jericho = newJericho
    ScenarioFramework.CreateUnitGivenTrigger(JerichoGiven, ScenarioInfo.Jericho)
end

function OnStart(self)
    -- Army colors
    ScenarioFramework.SetCybranColor(Player1)
    ScenarioFramework.SetAeonColor(Aeon)
    ScenarioFramework.SetUEFColor(UEF)
    ScenarioFramework.SetUEFColor(BlackSun)
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

    -- Adjust buildable categories for Players
    ScenarioFramework.AddRestrictionForAllHumans(
        -- All non vanilla units
        categories.PRODUCTFA + -- All FA Units
        categories.drlk001 +   -- Cybran T3 Mobile AA
        categories.dra0202 +   -- Corsairs
        categories.drl0204 +   -- Hoplites
        categories.delk002 +   -- UEF T3 Mobile AA
        categories.del0204 +   -- Mongoose
        categories.dea0202 +   -- Janus
        categories.dalk003 +   -- Aeon M3 Mobile AA
        categories.dal0310 +   -- T3 Absolver
        categories.daa0206 +   -- Mercy

        -- Actual mission restrictions
        categories.urb2305 +   -- Cybran Strategic Missile Launcher
        categories.urb4302 +   -- Cybran Strategic Missile Defense
        categories.urs0304 +   -- Cybran Strategic Missile Submarine
        categories.urb0304 +   -- Cybran Quantum Gate
        categories.url0301 +   -- Cybran Sub Commander
        categories.url0402 +   -- Spider Bot

        categories.ueb2305 +   -- UEF Strategic Missile Launcher
        categories.ueb4302 +   -- UEF Strategic Missile Defense
        categories.ues0304 +   -- UEF Strategic Missile Submarine
        categories.ueb0304 +   -- UEF Quantum Gate
        categories.uel0301 +   -- UEF Sub Commander
        categories.uel0401 +   -- Fatboy

        categories.uab2305 +   -- Aeon Strategic Missile Launcher
        categories.uab4302 +   -- Aeon Strategic Missile Defense
        categories.uas0304 +   -- Aeon Strategic Missile Submarine
        categories.uab0304 +   -- Aeon Quantum Gate
        categories.ual0301 +   -- Aeon Sub Commander
        categories.ual0401     -- GC
    )

    ScenarioFramework.SetSharedUnitCap(660)
    SetArmyUnitCap(Aeon, 1000)
    SetArmyUnitCap(UEF, 1000)

    if not SkipIntro then
        ScenarioFramework.SetPlayableArea('M1Area', false)

        ScenarioFramework.StartOperationJessZoom('CDRZoom', IntroMission1)
    else
        IntroMission1()
    end
end

------------
-- Mission 1
------------
function IntroMission1()
    ScenarioInfo.MissionNumber = 1

    -- Queue up units at player factories
    local land = {'url0202', 'url0205', 'url0303'}
    local air = {'ura0204', 'ura0303', 'ura0304'}
    local sea = {'urs0201', 'urs0202','urs0203'}
    local num = (-1 * Difficulty) + 4
    local landPlatoon = {'', '',}
    local airPlatoon = {'', '',}
    local seaPlatoon = {'', '',}
    for i = 1, num do
        table.insert(landPlatoon, {land[i], 5, 5, 'attack', 'AttackFormation'})
        table.insert(airPlatoon, {air[i], 5, 5, 'attack', 'ChevronFormation'})
        table.insert(seaPlatoon, {sea[i], 5, 5, 'attack', 'AttackFormation'})
    end
    local landFactories = ScenarioFramework.GetListOfHumanUnits(categories.urb0301, false)
    local airFactories = ScenarioFramework.GetListOfHumanUnits(categories.urb0302, false)
    local seaFactories = ScenarioFramework.GetListOfHumanUnits(categories.urb0303, false)
    IssueClearFactoryCommands(landFactories)
    IssueClearFactoryCommands(airFactories)
    IssueClearFactoryCommands(seaFactories)
    IssueFactoryRallyPoint(landFactories, ScenarioUtils.MarkerToPosition('LandFactoryRally'))
    IssueFactoryRallyPoint(airFactories, ScenarioUtils.MarkerToPosition('AirFactoryRally'))
    IssueFactoryRallyPoint(seaFactories, ScenarioUtils.MarkerToPosition('SeaFactoryRally'))
    ArmyBrains[Player1]:BuildPlatoon(landPlatoon, landFactories, 1)
    ArmyBrains[Player1]:BuildPlatoon(airPlatoon, airFactories, 1)
    ArmyBrains[Player1]:BuildPlatoon(seaPlatoon, seaFactories, 1)

    ForkThread(function()
        local tblArmy = ListArmies()
        local i = 1
        while tblArmy[ScenarioInfo['Player' .. i]] do
            ScenarioInfo['Player' .. i .. 'CDR'] = ScenarioFramework.SpawnCommander('Player' .. i, 'Commander', 'Warp', true, true, PlayerKilled)
            WaitSeconds(2)
            i = i + 1
        end
    end)

    -- Jericho strut
    IssueMove({ScenarioInfo.Jericho}, ScenarioUtils.MarkerToPosition('JerichoDestination'))
    ScenarioFramework.GroupPatrolChain({ScenarioInfo.Jericho}, 'Player_Jericho_Patrol_Chain')

    -- After 2 minutes: Jericho VO trigger
    ScenarioFramework.CreateTimerTrigger(M1JerichoVO, 120)

    -- Cybran in Aeon LOS VO trigger
    ScenarioFramework.CreateArmyIntelTrigger(CybranSpotted, ArmyBrains[Aeon], 'LOSNow', false, true, categories.ALLUNITS, true, ArmyBrains[Player1])

    -- UEF vs Aeon attacks
    local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'SpawnedAir', 'NoFormation')
    for _, unit in platoon:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({unit}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('AeonNaval_Chain')))
    end

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'InitialNaval', 'NoFormation')
    for _, unit in platoon:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({unit}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('AeonNaval_Chain')))
    end

    ScenarioFramework.Dialogue(OpStrings.C06_M01_010, StartMission1, true)
end

function StartMission1()
    ScenarioFramework.CreateTimerTrigger(Taunt, Random(600, 900))

    BuildCZAR()

    --------------------------------
    -- Primary Objective - Kill CZAR
    --------------------------------
    ScenarioInfo.M1P1 = Objectives.Basic(
        'primary',
        'incomplete',
        OpStrings.OpC06_M1P1_Title,
        OpStrings.OpC06_M1P1_Desc,
        Objectives.GetActionIcon('kill'),
        {}
    )

    ScenarioFramework.CreateUnitDeathTrigger(CzarEngineerDefeated, ScenarioInfo.CzarEngineer)
end

function M1JerichoVO()
    if not ScenarioInfo.Jericho.Dead then
        ScenarioFramework.Dialogue(OpStrings.C06_M01_020)
    else
        ScenarioFramework.Dialogue(OpStrings.C06_M01_022)
    end
end

function CybranSpotted()
    ScenarioFramework.Dialogue(OpStrings.C06_M01_030)
end

-- CZAR, AI builds it, it gets loaded with units and attacks the Control Center
function BuildCZAR()
    -- Makes the CZAR take 45, 34, 28 minutes to build
    local multiplier = {0.5, 0.75, 1}

    BuffBlueprint {
        Name = 'R06_EngBuildRate',
        DisplayName = 'R06_EngBuildRate',
        BuffType = 'AIBUILDRATE',
        Stacks = 'REPLACE',
        Duration = -1,
        EntityCategory = 'ENGINEER',
        Affects = {
            BuildRate = {
                Add = 0,
                Mult = multiplier[Difficulty],
            },
        },
    }

    ScenarioInfo.CzarEngineer = ScenarioUtils.CreateArmyUnit('Aeon', 'CzarEngineer')
    -- Apply buff here
    Buff.ApplyBuff(ScenarioInfo.CzarEngineer, 'R06_EngBuildRate')

    -- Trigger to kill the Tempest if the engineer dies
    ScenarioFramework.CreateUnitDestroyedTrigger(CzarEngineerDefeated, ScenarioInfo.CzarEngineer)

    local platoon = ArmyBrains[Aeon]:MakePlatoon('', '')
    platoon.PlatoonData = {
        NamedUnitBuild = {'Czar'},
        NamedUnitBuildReportCallback = CzarBuildProgressUpdate,
        NamedUnitFinishedCallback = CzarFullyBuilt,
    }

    ArmyBrains[Aeon]:AssignUnitsToPlatoon(platoon, {ScenarioInfo.CzarEngineer}, 'Support', 'None')

    platoon:ForkAIThread(ScenarioPlatoonAI.StartBaseEngineerThread)
end

local LastUpdate = 0
function CzarBuildProgressUpdate(unit, eng)
    if unit.Dead then
        return
    end

    if not unit.UnitPassedToScript then
        unit.UnitPassedToScript = true
        ScenarioInfo.M1P1:AddUnitTarget(unit)
        ScenarioFramework.CreateUnitDeathTrigger(CZARKilled, unit)
    end

    local fractionComplete = unit:GetFractionComplete()
    if math.floor(fractionComplete * 100) > math.floor(LastUpdate * 100) then
        LastUpdate = fractionComplete
        CZARBuildPercentUpdate(math.floor(LastUpdate * 100))
    end
end

function CZARBuildPercentUpdate(percent)
    if percent == 25 and not ScenarioInfo.CZAR25Dialogue then
        ScenarioInfo.CZAR25Dialogue = true
        ScenarioFramework.Dialogue(OpStrings.C06_M01_070)
    elseif percent == 50 and not ScenarioInfo.CZAR50Dialogue then
        ScenarioInfo.CZAR50Dialogue = true
        ScenarioFramework.Dialogue(OpStrings.C06_M01_076)
    elseif percent == 75 and not ScenarioInfo.CZARDialogue then
        ScenarioInfo.CZARDialogue = true
        ScenarioFramework.Dialogue(OpStrings.C06_M01_075)
    end
end

function CzarFullyBuilt()
    ScenarioInfo.CzarFullyBuilt = true
    ForkThread(CzarAI)

    ScenarioFramework.SetPlayableArea('M2Area')

    ScenarioFramework.CreateAreaTrigger(CzarOverLand, 'CzarOverLand', categories.uaa0310, true, false, ArmyBrains[Aeon])
end

function CZARKilled(unit)
    ScenarioInfo.M1P1:ManualResult(true)

    -- Make Control Center invulnerable
    ScenarioInfo.ControlCenter:SetCanTakeDamage(false)
    ScenarioInfo.ControlCenter:SetCanBeKilled(false)
    ScenarioInfo.ControlCenter:SetDoNotTarget(true)

    -- Rebuild the CZAR to attack player's base
    AeonAI.StartBuildingCZARs()

    if ScenarioInfo.Czar then
        -- Show the Czar dying, if the Czar was completely built when the player killed it
        local camInfo = {
            blendTime = 1.0,
            holdTime = 8,
            orientationOffset = { math.pi, 0.8, 0 },
            positionOffset = { 0, 0, 0 },
            zoomVal = 150,
        }
        ScenarioFramework.OperationNISCamera( ScenarioInfo.Czar[1], camInfo )
    end

    if not ScenarioInfo.Arnold.Dead then
        ScenarioFramework.Dialogue(OpStrings.C06_M01_100, nil, true)
        ScenarioFramework.Dialogue(OpStrings.C06_M01_110, IntroMission2, true)
    else
        ScenarioFramework.Dialogue(OpStrings.C06_M01_100, IntroMission2, true)
    end
end

function CzarAI()
    ScenarioInfo.Czar = ArmyBrains[Aeon]:GetListOfUnits(categories.uaa0310, false)
    
    if ArmyBrains[Aeon]:PlatoonExists(ScenarioInfo.CzarBombers) then
        if table.getn(ScenarioInfo.CzarBombers:GetPlatoonUnits()) > 0 then
            ScenarioInfo.CzarBombers:Stop()
            local units = {}
            for _, unit in ScenarioInfo.CzarBombers:GetPlatoonUnits() do
                if not unit.Dead and not unit:IsUnitState('Attached') then
                    table.insert(units, unit)
                end
            end
            IssueTransportLoad(units, ScenarioInfo.Czar[1])
            WaitSeconds(5)
        end
    end
    IssueAttack(ScenarioInfo.Czar, ScenarioInfo.ControlCenter)
    ScenarioFramework.Dialogue(OpStrings.C06_M01_050, nil, true)

    ScenarioFramework.CreateUnitDamagedTrigger(ReleaseBombers, ScenarioInfo.Czar[1])
end

function CzarEngineerDefeated()
    if not ScenarioInfo.CzarFullyBuilt and ScenarioInfo.CzarEngineer.UnitBeingBuilt then
        ScenarioInfo.CzarEngineer.UnitBeingBuilt:Kill()
    end
end

function CzarOverLand()
    if ScenarioInfo.M1P1.Active then
        ScenarioFramework.Dialogue(OpStrings.C06_M01_060)
    end
    
    ReleaseBombers()
end

function ReleaseBombers()
    if ScenarioInfo.BombersReleased then
        return
    end
    ScenarioInfo.BombersReleased = true

    ForkThread(function()
        IssueClearCommands(ScenarioInfo.Czar)
        IssueTransportUnload(ScenarioInfo.Czar, ScenarioInfo.ControlCenter:GetPosition())--ScenarioInfo.Czar[1]:GetPosition())
        --WaitSeconds(5)
        IssueAttack(ScenarioInfo.Czar, ScenarioInfo.ControlCenter)
        --if ScenarioInfo.CzarBombers and table.getn(ScenarioInfo.CzarBombers:GetPlatoonUnits()) > 0 then
        --    ScenarioInfo.CzarBombers:Stop()
        --    ScenarioInfo.CzarBombers:AggressiveMoveToLocation(ScenarioInfo.ControlCenter:GetPosition())
        --end
    end)
end

------------
-- Mission 2
------------
function IntroMission2()
    if ScenarioInfo.MissionNumber ~= 1 then
        return
    end
    ScenarioInfo.MissionNumber = 2

    UEFAI.ForwardBaseAI()
    UEFAI.ControlCenterBuildExtraDefences()
    -- Start attacking player from the main base
    UEFAI.M2UEFMainBaseAirAttacks()
    UEFAI.M2UEFMainBaseLandAttacks()
    UEFAI.M2UEFMainBaseNavalAttacks()

    ScenarioFramework.SetSharedUnitCap(720)

    ForkThread(M2MobileFactoriesThread)

    -- UEF Naval Attack
    local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M2NavalPatrol', 'AttackFormation')
    platoon:Patrol(ScenarioUtils.MarkerToPosition('PlayerSub_Patrol1'))
    platoon:Patrol(ScenarioUtils.MarkerToPosition('PlayerSub_Patrol2'))

    -- UEF Land Attack
    for i = 1, 3 do
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M2LandPatrol_D1_' .. i, 'AttackFormation')
        ScenarioFramework.PlatoonPatrolChain(platoon, 'M2LandAttack_Chain' .. i)
    end

    if Difficulty >= 2 then
        for i = 1, 2 do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M2LandPatrol_D2_' .. i, 'AttackFormation')
            ScenarioFramework.PlatoonPatrolChain(platoon, 'M2LandAttack_Chain' .. i)
        end
    end

    if Difficulty >= 3 then
        for i = 1, 3 do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M2LandPatrol_D3_' .. i, 'AttackFormation')
            ScenarioFramework.PlatoonPatrolChain(platoon, 'M2LandAttack_Chain' .. i)
        end
    end

    -- UEF Air Attack
    for i = 1, 2 do
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M2AirPatrol_D1_' .. i, 'NoFormation')
        for _, unit in platoon:GetPlatoonUnits() do
            ScenarioFramework.GroupPatrolRoute({unit}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('ControlCenterAir_Chain')))
        end
    end

    if Difficulty >= 2 then
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M2AirPatrol_D2_1', 'NoFormation')
        for _, unit in platoon:GetPlatoonUnits() do
            ScenarioFramework.GroupPatrolRoute({unit}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('ControlCenterAir_Chain')))
        end
    end

    if Difficulty >= 3 then
        for i = 1, 2 do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M2AirPatrol_D3_' .. i, 'NoFormation')
            for _, unit in platoon:GetPlatoonUnits() do
                ScenarioFramework.GroupPatrolRoute({unit}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('ControlCenterAir_Chain')))
            end
        end
    end

    -- UEF Engineers from offmap to build control centre defences and forward defensive line.
    local engs = ScenarioUtils.CreateArmyGroup('UEF', 'M2Engineers')
    local shields = ScenarioUtils.CreateArmyGroup('UEF', 'M2Shields')
    for i = 1, table.getn(shields) do
        if engs[i] then
            IssueGuard({shields[i]}, engs[i])
        end
    end

    -- This is shove them into the base managers even when they are out of the base radius.
    local platoon = ArmyBrains[UEF]:MakePlatoon('', '')
    platoon.PlatoonData = {BaseName = 'Forward_Base'}
    for i = 1, 9 do
        if engs[i] then
            ArmyBrains[UEF]:AssignUnitsToPlatoon(platoon, {engs[i]}, 'Support', 'NoFormation')
        end
    end
    platoon:ForkAIThread(import('/lua/ai/opai/BaseManagerPlatoonThreads.lua').BaseManagerEngineerPlatoonSplit)

    platoon = ArmyBrains[UEF]:MakePlatoon('', '')
    platoon.PlatoonData = {BaseName = 'Control_Center_Base'}
    for i = 10, 18 do
        if engs[i] then
            ArmyBrains[UEF]:AssignUnitsToPlatoon(platoon, {engs[i]}, 'Support', 'NoFormation')
        end
    end
    platoon:ForkAIThread(import('/lua/ai/opai/BaseManagerPlatoonThreads.lua').BaseManagerEngineerPlatoonSplit)

    -- Aeon Air Attack
    M2AeonAirAttack()

    -- Colossus Attack
    if ScenarioInfo.Colossus and not ScenarioInfo.Colossus.Dead then
        ScenarioInfo.ColossusPlatoon:Stop()
        ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.ColossusPlatoon, 'Aeon_AttackChain') --Colossus_Attack_Chain

        -- Move the guarding units into the Player's base once the GC dies
        ScenarioInfo.ColossusGuards:MoveToLocation(ScenarioUtils.MarkerToPosition('Player1'), false)
    end

    ScenarioFramework.RemoveRestrictionForAllHumans(
        categories.urb4302 +   -- Cybran Strategic Missile Defense
        categories.urb0304 +   -- Cybran Quantum Gate
        categories.url0301 +   -- Cybran Sub Commander
        categories.url0402 +   -- Spider Bot

        categories.ueb4302 +   -- UEF Strategic Missile Defense
        categories.ueb0304 +   -- UEF Quantum Gate
        categories.uel0301 +   -- UEF Sub Commander
        categories.uel0401 +   -- Fatboy

        categories.uab4302 +   -- Aeon Strategic Missile Defense
        categories.uab0304 +   -- Aeon Quantum Gate
        categories.ual0301 +   -- Aeon Sub Commander
        categories.ual0401,    -- GC
        true
    )

    ScenarioFramework.Dialogue(OpStrings.C06_M02_010, StartMission2, true)
end

function StartMission2()
    ScenarioFramework.SetPlayableArea('M2Area')

    -- After 3 minutes: Jericho VO trigger
    ScenarioFramework.CreateTimerTrigger(M2JerichoVO, 180)

    -- After 4 minutes: Ops VO trigger
    ScenarioFramework.CreateTimerTrigger(M2OpsVO, 240)

    ---------------------------------
    -- Primary Objective - Build Gate
    ---------------------------------
    ScenarioInfo.M2P1 = Objectives.ArmyStatCompare(
        'primary',
        'incomplete',
        OpStrings.OpC06_M2P1_Title,
        OpStrings.OpC06_M2P1_Desc,
        'build',
        {
            Armies = {'HumanPlayers'},
            StatName = 'Units_Active',
            CompareOp = '>=',
            Value = 1,
            Category = categories.urb0304,
        }
    )
    ScenarioInfo.M2P1:AddResultCallback(
        function(result)
            if result then
                ScenarioFramework.Dialogue(OpStrings.C06_M02_050, GateBuilt, true)
            end
        end
    )

    -- M2P1 Objective Reminder
    ScenarioFramework.CreateTimerTrigger(M2P1Reminder1, M2P1Time)
end

function GateBuilt()
    -----------------------------------
    -- Primary Objective - Download QAI
    -----------------------------------
    local gates = ScenarioFramework.GetListOfHumanUnits(categories.urb0304, false)
    ScenarioInfo.M2P2 = Objectives.Basic(
        'primary',
        'incomplete',
        OpStrings.OpC06_M2P2_Title,
        OpStrings.OpC06_M2P2_Desc,
        Objectives.GetActionIcon('timer'),
        {
            Units = gates,
        }
    )

    -- Trigger will fire if all of the players gates are destroyed
    ScenarioFramework.CreateArmyStatTrigger(GateDestroyed, ArmyBrains[Player1], 'GateDestroyed',
        {{StatType = 'Units_Active', CompareType = 'LessThan', Value = 1, Category = categories.urb0304}})

    -- Trigger will fire when CDR is near the gate
    ScenarioInfo.CDRNearGate = ScenarioFramework.CreateUnitNearTypeTrigger(CDRNearGate, ScenarioInfo.Player1CDR, ArmyBrains[Player1],
        categories.urb0304, 10)

    -- M2P2 Objective Reminder
    ScenarioFramework.CreateTimerTrigger(M2P2Reminder1, M2P2Time)
end

function GateDestroyed()
    if ScenarioInfo.M2P2.Active then
        ScenarioFramework.Dialogue(OpStrings.C06_M02_040, nil, true)

        if ScenarioInfo.CDRNearGate then
            ScenarioInfo.CDRNearGate:Destroy()
        end

        ScenarioInfo.CDRNearGate = ScenarioFramework.CreateUnitNearTypeTrigger(CDRNearGate, ScenarioInfo.Player1CDR, ArmyBrains[Player1], categories.urb0304, 10)

        if ScenarioInfo.DownloadTimer then
            ScenarioFramework.ResetUITimer()
            ScenarioInfo.DownloadTimer:Destroy()
        end
    end
end

function CDRNearGate()
    local position = ScenarioInfo.Player1CDR:GetPosition()
    local rect = Rect(position[1] - 10, position[3] - 10, position[1] + 10, position[3] + 10)
    ScenarioFramework.CreateAreaTrigger(LeftGate, rect, categories.COMMAND, true, true, ArmyBrains[Player1])
    ScenarioInfo.DownloadTimer = ScenarioFramework.CreateTimerTrigger(DownloadFinished, 120, true)
    ScenarioFramework.Dialogue(OpStrings.C06_M02_060)

    -- Send in UEF attack on CDR
    if not ScenarioInfo.CDRGateAttack then
        ScenarioInfo.CDRGateAttack = true
        local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M2CDRAttack_D' .. Difficulty, 'StaggeredChevronFormation')
        platoon:AttackTarget(ScenarioInfo.Player1CDR)
    end
end

function LeftGate()
    if ScenarioInfo.M2P2.Active and not ScenarioInfo.Player1CDR.Dead then
        ScenarioFramework.Dialogue(OpStrings.C06_M02_070, nil, true)
        ScenarioFramework.ResetUITimer()
        ScenarioInfo.DownloadTimer:Destroy()

        -- Trigger will fire when CDR is near the gate
        ScenarioFramework.CreateUnitNearTypeTrigger(CDRNearGate, ScenarioInfo.Player1CDR, ArmyBrains[Player1], categories.urb0304, 10)
    end
end

function DownloadFinished()
    ScenarioFramework.Dialogue(OpStrings.C06_M02_090, nil, true)
    ScenarioInfo.M2P2:ManualResult(true)

    ScenarioInfo.ControlCenter:SetCapturable(true)

    ---------------------------------------------
    -- Primary Objective - Capture Control Center
    ---------------------------------------------
    ScenarioInfo.M2P3 = Objectives.Capture(
        'primary',
        'incomplete',
        OpStrings.OpC06_M2P3_Title,
        OpStrings.OpC06_M2P3_Desc,
        {
            Units = {
                ScenarioInfo.ControlCenter,
            },
        }
    )
    ScenarioInfo.M2P3:AddResultCallback(
        function(result, units)
            if result then
                -- Make the control center not targetable, if killed by splash damage op fails
                ScenarioInfo.ControlCenter = units[1]
                ScenarioInfo.ControlCenter:SetDoNotTarget(true)
                ScenarioFramework.PauseUnitDeath(ScenarioInfo.ControlCenter)
                ScenarioFramework.CreateUnitDestroyedTrigger(PlayerLose, ScenarioInfo.ControlCenter)

                -- control center captured cam
                local camInfo = {
                    blendTime = 1.0,
                    holdTime = 4,
                    orientationOffset = {-2.6, 0.3, 0},
                    positionOffset = {0, 0.5, 0},
                    zoomVal = 30,
                }
                ScenarioFramework.OperationNISCamera(ScenarioInfo.ControlCenter, camInfo)

                ScenarioFramework.Dialogue(OpStrings.C06_M02_130, IntroMission3, true)
            end
        end
    )

    -- M2P3 Objective Reminder
    ScenarioFramework.CreateTimerTrigger(M2P3Reminder1, M2P3Time)
end

function M2MobileFactoriesThread()
    -- Mobile Factories
    local fatboys = {}
    for i = 1, 2 do
        local fatboy = ScenarioUtils.CreateArmyUnit('UEF', 'MobileFactory' .. i)
        table.insert(fatboys, fatboy)
        IssueMove({fatboy}, ScenarioUtils.MarkerToPosition('MobileFactoryMove' .. i))

        local engineers = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'MobileFactoryEngineers' ..i, 'NoFormation')
        engineers:GuardTarget(fatboy.ExternalFactory)

    end
    UEFAI.MobileFactoryAI(fatboys)
end

function M2AeonAirAttack()
    if ScenarioInfo.MissionNumber == 2 then
        for i = 1, Difficulty do
            local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M2AirPatrol', 'GrowthFormation')
            ScenarioFramework.PlatoonPatrolRoute(platoon, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('ControlCenterAir_Chain')))
        end

        ScenarioFramework.CreateTimerTrigger(M2AeonAirAttack, Random(300, 600))
    end
end

function M2JerichoVO()
    if(not ScenarioInfo.Jericho.Dead) then
        ScenarioFramework.Dialogue(OpStrings.C06_M02_020)
    else
        ScenarioFramework.Dialogue(OpStrings.C06_M02_025)
    end
end

function M2OpsVO()
    ScenarioFramework.Dialogue(OpStrings.C06_M02_030)
end

function Taunt()
    -- Choose Aiko or Arnold
    local choice = Random(0, 1)
    if(choice == 0) then
        -- Play Aiko taunt
        if(not ScenarioInfo.Aiko.Dead and aikoTaunt <= 8) then
            PlayAikoTaunt()
        elseif(not ScenarioInfo.Arnold.Dead and arnoldTaunt <= 16) then
            PlayArnoldTaunt()
        end
    else
        -- Play Arnold taunt
        if(not ScenarioInfo.Arnold.Dead and arnoldTaunt <= 16) then
            PlayArnoldTaunt()
        elseif(not ScenarioInfo.Aiko.Dead and aikoTaunt <= 8) then
            PlayAikoTaunt()
        end
    end
end

function PlayAikoTaunt()
    ScenarioFramework.Dialogue(OpStrings['TAUNT' .. aikoTaunt])
    aikoTaunt = aikoTaunt + 1
    ScenarioFramework.CreateTimerTrigger(Taunt, Random(600, 900))
end

function PlayArnoldTaunt()
    ScenarioFramework.Dialogue(OpStrings['TAUNT' .. arnoldTaunt])
    arnoldTaunt = arnoldTaunt + 1
    ScenarioFramework.CreateTimerTrigger(Taunt, Random(600, 900))
end

function M2P1Reminder1()
    if ScenarioInfo.M2P1.Active then
        ScenarioFramework.Dialogue(OpStrings.C06_M02_150)
        ScenarioFramework.CreateTimerTrigger(M2P1Reminder2, SubsequentTime)
    end
end

function M2P1Reminder2()
    if ScenarioInfo.M2P1.Active then
        ScenarioFramework.Dialogue(OpStrings.C06_M02_155)
        ScenarioFramework.CreateTimerTrigger(M2P1Reminder3, SubsequentTime)
    end
end

function M2P1Reminder3()
    if ScenarioInfo.M2P1.Active then
        ScenarioFramework.Dialogue(OpStrings.C06_M01_076)
        ScenarioFramework.CreateTimerTrigger(M2P1Reminder1, SubsequentTime)
    end
end

function M2P2Reminder1()
    if ScenarioInfo.M2P2.Active then
        ScenarioFramework.Dialogue(OpStrings.C06_M02_160)
        ScenarioFramework.CreateTimerTrigger(M2P2Reminder2, SubsequentTime)
    end
end

function M2P2Reminder2()
    if ScenarioInfo.M2P2.Active then
        ScenarioFramework.Dialogue(OpStrings.C06_M02_165)
        ScenarioFramework.CreateTimerTrigger(M2P2Reminder3, SubsequentTime)
    end
end

function M2P2Reminder3()
    if ScenarioInfo.M2P2.Active then
        ScenarioFramework.Dialogue(OpStrings.C06_M01_076)
        ScenarioFramework.CreateTimerTrigger(M2P2Reminder1, SubsequentTime)
    end
end

function M2P3Reminder1()
    if ScenarioInfo.M2P3.Active then
        ScenarioFramework.Dialogue(OpStrings.C06_M02_170)
        ScenarioFramework.CreateTimerTrigger(M2P3Reminder2, SubsequentTime)
    end
end

function M2P3Reminder2()
    if ScenarioInfo.M2P3.Active then
        ScenarioFramework.Dialogue(OpStrings.C06_M01_076)
        ScenarioFramework.CreateTimerTrigger(M2P3Reminder1, SubsequentTime)
    end
end

------------
-- Mission 3
------------
function IntroMission3()
    ScenarioInfo.MissionNumber = 3

    ---------
    -- UEF AI
    ---------
    UEFAI.M3UEFMainBaseNavalAttacks()
    UEFAI.M3UEFMainBaseConditionalBuilds()
    if Difficulty == 3 then
        UEFAI.UEFMainBaseSpawnHLRA()
    end

    -- Atlantis Assault
    local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M3NavyFleet_D' .. Difficulty, 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'UEF_Atlantis_Attack_Chain')

    ScenarioInfo.AtlantisPlanes = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M3AtlantisPlanes_D' .. Difficulty, 'StaggeredChevronFormation')
    ScenarioInfo.Atlantis = ScenarioUtils.CreateArmyUnit('UEF', 'Atlantis')
    ScenarioFramework.CreateUnitDeathTrigger(UEFAI.StartBuildingAtlantis, ScenarioInfo.Atlantis)

    IssueTransportLoad(ScenarioInfo.AtlantisPlanes:GetPlatoonUnits(), ScenarioInfo.Atlantis)
    IssueDive({ScenarioInfo.Atlantis})

    ScenarioFramework.GroupPatrolChain({ScenarioInfo.Atlantis}, 'UEF_Atlantis_Attack_Chain')

    ScenarioFramework.CreateUnitNearTypeTrigger(StartAtlantisAI, ScenarioInfo.Atlantis, ArmyBrains[Player1], categories.ALLUNITS, 80)

    -- Unit cap
    ScenarioFramework.SetSharedUnitCap(1200)

    -- Adjust buildable categories
    ScenarioFramework.RemoveRestrictionForAllHumans(
        categories.urb2305 +    -- Cybran Strategic Missile Launcher
        categories.urs0304 +    -- Cybran Strategic Missile Submarine

        categories.ueb2305 +    -- UEF Strategic Missile Launcher
        categories.ues0304 +    -- UEF Strategic Missile Submarine

        categories.uab2305 +    -- Aeon Strategic Missile Launcher
        categories.uas0304,     -- Aeon Strategic Missile Submarine
        true
    )

    ScenarioFramework.Dialogue(OpStrings.C06_M03_010, StartMission3, true)
end

function StartMission3()
    ScenarioFramework.SetPlayableArea('M3Area')

    -- Nuke Aeon once Player breaks into UEF base
    for k, v in ArmyBrains[UEF]:GetListOfUnits(categories.ueb2305, false) do
        v:GiveNukeSiloAmmo(5)
    end

    ----------------------------------------
    -- Primary Objective - Capture Black Sun
    ----------------------------------------
    ScenarioInfo.M3P1 = Objectives.Capture(
        'primary',
        'incomplete',
        OpStrings.OpC06_M3P1_Title,
        OpStrings.OpC06_M3P1_Desc,
        {
            Units = {
                ScenarioInfo.BlackSunWeapon,
            },
        }
    )
    ScenarioInfo.M3P1:AddResultCallback(
        function(result, units)
            if result then
                ScenarioInfo.BlackSunWeapon = units[1]

                -- Primary Objective 2
                ScenarioInfo.M3P2 = Objectives.Basic(
                    'primary',                          -- type
                    'incomplete',                       -- complete
                    OpStrings.OpC06_M3P2_Title,         -- title
                    OpStrings.OpC06_M3P2_Desc,          -- description
                    Objectives.GetActionIcon('kill'),   -- action
                    {                                   -- target
                        Units = {
                            ScenarioInfo.BlackSunWeapon,
                        },
                    }
                )
                ScenarioInfo.BlackSunWeapon:AddSpecialToggleEnable(BlackSunFired)
                ScenarioInfo.BlackSunWeapon:SetCanTakeDamage(false)
                ScenarioInfo.BlackSunWeapon:SetCanBeKilled(false)
                ScenarioInfo.BlackSunWeapon:SetReclaimable(false)
                ScenarioInfo.BlackSunWeapon:SetCapturable(false)
                ScenarioInfo.BlackSunWeapon:SetDoNotTarget(true)

                ScenarioFramework.Dialogue(OpStrings.C06_M03_060, nil, true)

                -- Show the captured Black Sun
                local camInfo = {
                    blendTime = 1.0,
                    holdTime = 4,
                    orientationOffset = { 1.8, 0.7, 0 },
                    positionOffset = { 0, 1, 0 },
                    zoomVal = 75,
                }
                ScenarioFramework.OperationNISCamera(ScenarioInfo.BlackSunWeapon, camInfo)

                -- M3P2 Objective Reminder
                ScenarioFramework.CreateTimerTrigger(M3P2Reminder1, M3P2Time)
            end
        end
    )

    -- M3P1 Objective Reminder
    ScenarioFramework.CreateTimerTrigger(M3P1Reminder1, 300)

    -- After 4 minutes: Aiko VO
    ScenarioFramework.CreateTimerTrigger(M3AikoVO, 240)

    -- Trigget to nuke Aeon base once players' units get close to the base.
    for _, playerId in ScenarioInfo.HumanPlayers do 
        ScenarioFramework.CreateAreaTrigger(NukeAeon, 'UEFBaseArea', categories.ALLUNITS, true, false, ArmyBrains[playerId], 1, false)
    end
end

function StartAtlantisAI()
    -- Release the air units
    IssueClearCommands({ScenarioInfo.Atlantis})
    IssueTransportUnload({ScenarioInfo.Atlantis}, ScenarioInfo.Atlantis:GetPosition())

    for _, unit in ScenarioInfo.AtlantisPlanes:GetPlatoonUnits() do
        while not unit.Dead and unit:IsUnitState('Attached') do
            WaitSeconds(.5)
        end
    end

    if not ScenarioInfo.Atlantis.Dead then
        IssueDive({ScenarioInfo.Atlantis})
        IssuePatrol({ScenarioInfo.Atlantis}, ScenarioUtils.MarkerToPosition('PlayerAir_Patrol3'))
        IssuePatrol({ScenarioInfo.Atlantis}, ScenarioUtils.MarkerToPosition('PlayerAir_Patrol2'))
    end

    if ArmyBrains[UEF]:PlatoonExists(ScenarioInfo.AtlantisPlanes) then
        IssueClearCommands(ScenarioInfo.AtlantisPlanes:GetPlatoonUnits())
        ScenarioInfo.AtlantisPlanes:Stop()
        ScenarioInfo.AtlantisPlanes:Patrol(ScenarioUtils.MarkerToPosition('PlayerBase'))
        ScenarioInfo.AtlantisPlanes:Patrol(ScenarioUtils.MarkerToPosition('PlayerAir_Patrol2'))
        ScenarioInfo.AtlantisPlanes:Patrol(ScenarioUtils.MarkerToPosition('PlayerAir_Patrol3'))
    end

    ScenarioFramework.Dialogue(OpStrings.C06_M02_100)
end

function NukeAeon()
    if ScenarioInfo.AeonNuked then
        return
    end

    ScenarioInfo.AeonNuked = true

    if (not ScenarioInfo.Arnold.Dead and ArmyBrains[Aeon]:GetCurrentUnits(categories.STRUCTURE) > 20) then
        local nukes = ArmyBrains[UEF]:GetListOfUnits(categories.ueb2305, false)

        if not nukes[1].Dead then
            IssueNuke({nukes[1]}, ScenarioInfo.Arnold:GetPosition())
            WaitSeconds(10)
        end

        local availableNukes = {}
        for i = 2, table.getn(nukes) do
            table.insert(availableNukes, nukes[i])
        end

        for k, v in availableNukes do
            if not v.Dead then
                IssueNuke({v}, ScenarioUtils.MarkerToPosition('Nuke' .. k))
                WaitSeconds(10)
            end
        end

        WaitSeconds(30)
    end
end

function BlackSunFired()
    if not ScenarioInfo.OpEnded then
        ScenarioFramework.FlushDialogueQueue()
        ScenarioFramework.EndOperationSafety()
        ScenarioInfo.OpComplete = true
        if ScenarioInfo.M3P2 then
            ScenarioInfo.M3P2:ManualResult(true)
        end
        ScenarioFramework.EndOperation(ScenarioInfo.OpComplete, ScenarioInfo.OpComplete, true)
    end
end

function M3AikoVO()
    if ScenarioInfo.Aiko and not ScenarioInfo.Aiko.Dead then
        ScenarioFramework.Dialogue(OpStrings.C06_M03_030)
    end
end

function AikoDestroyed()
    ScenarioFramework.Dialogue(OpStrings.C06_M03_050)
    ScenarioFramework.CDRDeathNISCamera(ScenarioInfo.Aiko, 7)
end

function ArnoldDestroyed()
    ScenarioFramework.Dialogue(OpStrings.C06_M03_055)
    ScenarioFramework.CDRDeathNISCamera(ScenarioInfo.Arnold, 7)
end

function M3P1Reminder1()
    if ScenarioInfo.M3P1.Active then
        ScenarioFramework.Dialogue(OpStrings.C06_M03_070)
        ScenarioFramework.CreateTimerTrigger(M3P1Reminder2, 600)
    end
end

function M3P1Reminder2()
    if ScenarioInfo.M3P1.Active then
        ScenarioFramework.Dialogue(OpStrings.C06_M03_075)
        ScenarioFramework.CreateTimerTrigger(M3P1Reminder3, 600)
    end
end

function M3P1Reminder3()
    if ScenarioInfo.M3P1.Active then
        ScenarioFramework.Dialogue(OpStrings.C06_M01_076)
        ScenarioFramework.CreateTimerTrigger(M3P1Reminder1, 600)
    end
end

function M3P2Reminder1()
    if ScenarioInfo.M3P2.Active then
        ScenarioFramework.Dialogue(OpStrings.C06_M03_080)
        ScenarioFramework.CreateTimerTrigger(M3P2Reminder2, 60)
    end
end

function M3P2Reminder2()
    if ScenarioInfo.M3P2.Active then
        ScenarioFramework.Dialogue(OpStrings.C06_M03_085)
        ScenarioFramework.CreateTimerTrigger(M3P2Reminder1, 180)
    end
end

-----------
-- End Game
-----------
function ControlCenterDestroyed()
    if not ScenarioInfo.OpEnded then
        ScenarioFramework.EndOperationSafety()
        ScenarioInfo.OpComplete = false
        ScenarioFramework.CreateVisibleAreaLocation(100, ScenarioInfo.ControlCenter:GetPosition(), 0, ArmyBrains[Player1])

        -- Control center destroyed cam
        -- ScenarioFramework.EndOperationCamera(ScenarioInfo.ControlCenter)
        local camInfo = {
            blendTime = 2.5,
            holdTime = nil,
            orientationOffset = { 0, 0.3, 0 },
            positionOffset = { 0, 0.5, 0 },
            zoomVal = 30,
            spinSpeed = 0.03,
            overrideCam = true,
        }
        ScenarioFramework.OperationNISCamera( ScenarioInfo.ControlCenter, camInfo )

        ScenarioInfo.M1P1:ManualResult(false)
        ScenarioFramework.Dialogue(OpStrings.C06_M01_090, StartKillGame, true)
    end
end

function PlayerLose()
    if not ScenarioInfo.OpEnded then
        ScenarioFramework.EndOperationSafety()
        ScenarioInfo.OpComplete = false

        -- Control Center destroyed cam
        -- ScenarioFramework.EndOperationCamera(ScenarioInfo.ControlCenter)
        local camInfo = {
            blendTime = 2.5,
            holdTime = nil,
            orientationOffset = { 0, 0.3, 0 },
            positionOffset = { 0, 0.5, 0 },
            zoomVal = 30,
            spinSpeed = 0.03,
            overrideCam = true,
        }
        ScenarioFramework.OperationNISCamera( ScenarioInfo.ControlCenter, camInfo )

        ScenarioFramework.Dialogue(OpStrings.C06_M03_090, StartKillGame, true)
    end
end

function PlayerKilled(deadCommander)
    if DEBUG then
        return
    end
    ScenarioFramework.PlayerDeath(deadCommander, OpStrings.C06_D01_010)
end

function StartKillGame()
    ForkThread(KillGame)
end

function KillGame()
    if not ScenarioInfo.OpComplete then
        WaitSeconds(15)
    end
    ScenarioFramework.EndOperation(ScenarioInfo.OpComplete, ScenarioInfo.OpComplete, true)
end

------------------
-- Debug Functions
------------------
--[[
function OnCtrlF3()
    for _, v in ArmyBrains[UEF]:GetListOfUnits(categories.NAVAL * categories.MOBILE, false) do
        v:Kill()
    end
    for _, v in ArmyBrains[Aeon]:GetListOfUnits(categories.NAVAL * categories.MOBILE, false) do
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
