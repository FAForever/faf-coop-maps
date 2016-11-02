-- ****************************************************************************
-- **
-- **  File     : /maps/SCCA_Coop_R06/SCCA_Coop_R06_script.lua
-- **  Author(s): Jessica St. Croix
-- **
-- **  Summary  :
-- **
-- **  Copyright © 2006 Gas Powered Games, Inc.  All rights reserved.
-- ****************************************************************************
local Behaviors = import('/lua/ai/opai/OpBehaviors.lua')
local Objectives = import('/lua/ScenarioFramework.lua').Objectives
local OpStrings = import('/maps/SCCA_Coop_R06/SCCA_Coop_R06_strings.lua')
local ScenarioFramework = import('/lua/scenarioframework.lua')
local ScenarioPlatoonAI = import('/lua/scenarioplatoonai.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local Weather = import('/lua/weather.lua')

---------
-- Globals
---------
ScenarioInfo.Player1 = 1
ScenarioInfo.Aeon = 2
ScenarioInfo.UEF = 3
ScenarioInfo.BlackSun = 4
ScenarioInfo.Player2 = 5
ScenarioInfo.Player3 = 6
ScenarioInfo.Player4 = 7

ScenarioInfo.VarTable = {}

local Player1 = ScenarioInfo.Player1
local aeon = ScenarioInfo.Aeon
local uef = ScenarioInfo.UEF
local blackSun = ScenarioInfo.BlackSun
local Player2 = ScenarioInfo.Player2
local Player3 = ScenarioInfo.Player3
local Player4 = ScenarioInfo.Player4

local Players = {ScenarioInfo.Player1, ScenarioInfo.Player2, ScenarioInfo.Player3, ScenarioInfo.Player4}

local aikoTaunt = 1
local arnoldTaunt = 9

--------------------------
-- Objective Reminder Times
--------------------------
local M1P1Time = 600
local M2P1Time = 300
local M2P2Time = 300
local M2P3Time = 300
local M3P1Time = 300
local M3P2Time = 300
local SubsequentTime = 600

---------
-- Startup
---------
function OnPopulate(scenario)
    ScenarioUtils.InitializeScenarioArmies()
    ScenarioFramework.GetLeaderAndLocalFactions()

    SpawnPlayer()
    SpawnUEF()
    SpawnAeon()
end

function SpawnPlayer()
    -- Player Base
    ScenarioUtils.CreateArmyGroup('Player1', 'Base_D' .. ScenarioInfo.Options.Difficulty)

    -- Jericho
    ScenarioInfo.Jericho = ScenarioUtils.CreateArmyUnit('Player1', 'Jericho')
    ScenarioInfo.Jericho:SetCustomName(LOC '{i sCDR_Jericho}')
    ScenarioInfo.Jericho:CreateEnhancement('FocusConvertor')
    ScenarioInfo.Jericho:CreateEnhancement('NaniteMissileSystem')
    ScenarioInfo.Jericho:CreateEnhancement('Switchback')
    ScenarioFramework.CreateUnitDeathTrigger(JerichoKilled, ScenarioInfo.Jericho)

    -- Player Engineers
    local engineers = ScenarioUtils.CreateArmyGroup('Player1', 'Engineers')
    for k, v in engineers do
        for i = 1, 3 do
            IssuePatrol({v}, ScenarioUtils.MarkerToPosition('Jericho_Patrol' .. i))
        end
    end

    -- Player Mobile Defense
    local subs = ScenarioUtils.CreateArmyGroupAsPlatoon('Player1', 'Subs', 'AttackFormation')
    subs:Patrol(ScenarioUtils.MarkerToPosition('PlayerSub_Patrol1'))
    subs:Patrol(ScenarioUtils.MarkerToPosition('PlayerSub_Patrol2'))

    local sonar = ScenarioUtils.CreateArmyUnit('Player1', 'MobileSonar')
    IssuePatrol({sonar}, ScenarioUtils.MarkerToPosition('PlayerSub_Patrol1'))
    IssuePatrol({sonar}, ScenarioUtils.MarkerToPosition('PlayerSub_Patrol2'))

    local landPatrol1 = ScenarioUtils.CreateArmyGroupAsPlatoon('Player1', 'LandPatrol1', 'AttackFormation')
    for i = 1, 4 do
        landPatrol1:Patrol(ScenarioUtils.MarkerToPosition('PlayerLand_Patrol' .. i))
    end

    local landPatrol2 = ScenarioUtils.CreateArmyGroupAsPlatoon('Player1', 'LandPatrol2', 'AttackFormation')
    for i = 1, 4 do
        landPatrol2:Patrol(ScenarioUtils.MarkerToPosition('PlayerLand_Patrol' .. i))
    end

    local airPatrol = ScenarioUtils.CreateArmyGroupAsPlatoon('Player1', 'AirPatrol', 'ChevronFormation')
    for i = 1, 4 do
        airPatrol:Patrol(ScenarioUtils.MarkerToPosition('PlayerAir_Patrol' .. i))
    end
end

function SpawnUEF()
    -- Control Center
    ScenarioInfo.ControlCenter = ScenarioUtils.CreateArmyUnit('BlackSun', 'ControlCenter')
    ScenarioInfo.ControlCenter:SetReclaimable(false)
    ScenarioInfo.ControlCenter:SetCapturable(false)
    ScenarioFramework.PauseUnitDeath(ScenarioInfo.ControlCenter)
    ScenarioFramework.CreateUnitDeathTrigger(ControlCenterDestroyed, ScenarioInfo.ControlCenter)
    ScenarioUtils.CreateArmyGroup('UEF', 'ControlCenterDefensesPreBuilt_D' .. ScenarioInfo.Options.Difficulty)
    for i = 1, 5 do
        local patrol = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'ControlCenterPatrol', 'AttackFormation')
        patrol.PlatoonData = {}
        patrol.PlatoonData.PatrolChain = 'ControlCenter_Chain'
        patrol:ForkAIThread(ScenarioPlatoonAI.RandomPatrolThread)
    end

    -- Naval
    local naval = ScenarioUtils.CreateArmyGroup('UEF', 'InitialNaval')
    for k, v in naval do
        local platoon = ArmyBrains[uef]:MakePlatoon('', '')
        ArmyBrains[uef]:AssignUnitsToPlatoon(platoon, {v}, 'attack', 'AttackFormation')
        platoon.PlatoonData = {}
        platoon.PlatoonData.PatrolChain = 'AeonNaval_Chain'
        platoon:ForkAIThread(ScenarioPlatoonAI.RandomPatrolThread)
    end
    ScenarioFramework.CreateGroupDeathTrigger(SpawnUEFNaval, naval)

    -- Atlantis Assault
    ScenarioInfo.AtlantisBoats = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M3NavyFleet_D' .. ScenarioInfo.Options.Difficulty, 'GrowthFormation')

    -- Base
    ScenarioUtils.CreateArmyGroup('UEF', 'BaseStructuresPreBuilt_D' .. ScenarioInfo.Options.Difficulty)
    ScenarioInfo.Aiko = ScenarioUtils.CreateArmyUnit('UEF', 'Aiko')
    ScenarioInfo.Aiko:SetCustomName(LOC '{i CDR_Aiko}')
    ScenarioInfo.Aiko:CreateEnhancement('HeavyAntiMatterCannon')
    ScenarioInfo.Aiko:CreateEnhancement('Shield')
    ScenarioInfo.Aiko:CreateEnhancement('HeavyAntiMatterCannon')
    ScenarioInfo.Aiko:CreateEnhancement('DamageStablization')
    local cdrPlatoon = ArmyBrains[uef]:MakePlatoon('','')
    ArmyBrains[uef]:AssignUnitsToPlatoon(cdrPlatoon, {ScenarioInfo.Aiko}, 'Attack', 'AttackFormation')
    cdrPlatoon:ForkAIThread(AikoAI)
    cdrPlatoon.CDRData = {}
    cdrPlatoon.CDRData.LeashPosition = 'UEFBase_Patrol2'
    cdrPlatoon.CDRData.LeashRadius = 50
    cdrPlatoon:ForkThread(Behaviors.CDROverchargeBehavior)
    ScenarioFramework.CreateUnitDeathTrigger(AikoDestroyed, ScenarioInfo.Aiko)
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

function AikoAI(platoon)
    platoon.PlatoonData.LocationType = 'UEFBase'
    platoon:PatrolLocationFactoriesAI()
end

function SpawnUEFNaval()
    if(ScenarioInfo.MissionNumber == 1 and not ScenarioInfo.CzarFullyBuilt) then
        local naval = ScenarioUtils.CreateArmyGroup('UEF', 'SpawnedNaval')
        for k, v in naval do
            local platoon = ArmyBrains[uef]:MakePlatoon('', '')
            ArmyBrains[uef]:AssignUnitsToPlatoon(platoon, {v}, 'attack', 'AttackFormation')
            platoon.PlatoonData = {}
            platoon.PlatoonData.PatrolChain = 'AeonNaval_Chain'
            platoon:ForkAIThread(ScenarioPlatoonAI.RandomPatrolThread)
        end
        ScenarioFramework.CreateGroupDeathTrigger(SpawnUEFNaval, naval)
    end
end

function SpawnAeon()
    -- Aeon Base
    ScenarioInfo.Arnold = ScenarioUtils.CreateArmyUnit('Aeon', 'Arnold')
    ScenarioInfo.Arnold:SetCustomName(LOC '{i CDR_Arnold}')
    ScenarioInfo.Arnold:CreateEnhancement('Shield')
    ScenarioInfo.Arnold:CreateEnhancement('HeatSink')
    ScenarioInfo.Arnold:CreateEnhancement('CrysalisBeam')
    local cdrPlatoon = ArmyBrains[aeon]:MakePlatoon('','')
    ArmyBrains[aeon]:AssignUnitsToPlatoon(cdrPlatoon, {ScenarioInfo.Arnold}, 'Attack', 'AttackFormation')
    cdrPlatoon:ForkAIThread(ArnoldAI)
    cdrPlatoon.CDRData = {}
    cdrPlatoon.CDRData.LeashPosition = 'AeonBase'
    cdrPlatoon.CDRData.LeashRadius = 50
    cdrPlatoon:ForkThread(Behaviors.CDROverchargeBehavior)
    ScenarioFramework.CreateUnitDeathTrigger(ArnoldDestroyed, ScenarioInfo.Arnold)
    ScenarioInfo.Colossus = ScenarioUtils.CreateArmyUnit('Aeon', 'Colossus')
    for i = 1, 4 do
        IssuePatrol({ScenarioInfo.Colossus}, ScenarioUtils.MarkerToPosition('AeonBase_Patrol' .. i))
    end
    local colossusGuards = ScenarioUtils.CreateArmyGroup('Aeon', 'ColossusGuards_D' .. ScenarioInfo.Options.Difficulty)
    IssueGuard(colossusGuards, ScenarioInfo.Colossus)
    ScenarioInfo.CzarEngineer = ScenarioUtils.CreateArmyUnit('Aeon', 'CzarEngineer')
    ScenarioUtils.CreateArmyGroup('Aeon', 'MainBaseStructuresPreBuilt_D' .. ScenarioInfo.Options.Difficulty)
    ScenarioUtils.CreateArmyGroup('Aeon', 'StationaryNaval')

    -- Aeon Mobile Defense
    local subPatrolSouth = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'SubPatrolSouth', 'AttackFormation')
    subPatrolSouth.PlatoonData = {}
    subPatrolSouth.PlatoonData.PatrolChain = 'AeonNaval_Chain'
    subPatrolSouth:ForkAIThread(ScenarioPlatoonAI.RandomPatrolThread)

    local subPatrolNorth = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'SubPatrolNorth', 'AttackFormation')
    subPatrolNorth.PlatoonData = {}
    subPatrolNorth.PlatoonData.PatrolChain = 'AeonNavalN_Chain'
    subPatrolNorth:ForkAIThread(ScenarioPlatoonAI.RandomPatrolThread)

    local surfacePatrol = ScenarioUtils.CreateArmyGroup('Aeon', 'SurfacePatrol')
    for k, v in surfacePatrol do
        local platoon = ArmyBrains[aeon]:MakePlatoon('', '')
        ArmyBrains[aeon]:AssignUnitsToPlatoon(platoon, {v}, 'attack', 'AttackFormation')
        platoon.PlatoonData = {}
        platoon.PlatoonData.PatrolChain = 'AeonNaval_Chain'
        platoon:ForkAIThread(ScenarioPlatoonAI.RandomPatrolThread)
    end

    local landPatrol = ScenarioUtils.CreateArmyGroup('Aeon', 'LandPatrol_D' .. ScenarioInfo.Options.Difficulty)
    for k, v in landPatrol do
        local platoon = ArmyBrains[aeon]:MakePlatoon('', '')
        ArmyBrains[aeon]:AssignUnitsToPlatoon(platoon, {v}, 'attack', 'AttackFormation')
        platoon.PlatoonData = {}
        platoon.PlatoonData.PatrolChain = 'AeonBase_Chain'
        platoon:ForkAIThread(ScenarioPlatoonAI.RandomPatrolThread)
    end

    local airPatrol = ScenarioUtils.CreateArmyGroup('Aeon', 'TorpedoBombers_D' .. ScenarioInfo.Options.Difficulty)
    for k, v in airPatrol do
        local platoon = ArmyBrains[aeon]:MakePlatoon('', '')
        ArmyBrains[aeon]:AssignUnitsToPlatoon(platoon, {v}, 'attack', 'ChevronFormation')
        platoon:SetPlatoonFormationOverride('NoFormation')
        platoon.PlatoonData = {}
        platoon.PlatoonData.PatrolChain = 'Aeon_Chain'
        platoon:ForkAIThread(ScenarioPlatoonAI.RandomPatrolThread)
    end

    ScenarioInfo.CzarBombers = ScenarioUtils.CreateArmyGroup('Aeon', 'CzarBombers_D' .. ScenarioInfo.Options.Difficulty)
    for k, v in ScenarioInfo.CzarBombers do
        local chain = ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('Aeon_Chain'))
        for i = 1, table.getn(chain) do
            IssuePatrol({v}, chain[i])
        end
    end

    local scouts = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'Scouts', 'ChevronFormation')
    for i = 1, 4 do
        scouts:Patrol(ScenarioUtils.MarkerToPosition('PlayerAir_Patrol' .. i))
    end
end

function ArnoldAI(platoon)
    platoon.PlatoonData.LocationType = 'AeonBase'
    platoon:PatrolLocationFactoriesAI()
end

function OnStart(self)
    -- Adjust buildable categories for Player
    local tblArmy = ListArmies()
    for _, player in Players do
        for iArmy, strArmy in pairs(tblArmy) do
            if iArmy == player then
                ScenarioFramework.AddRestriction(player,
                    categories.PRODUCTFA + -- All FA Units
                    categories.urb2305 +   -- Strategic Missile Launcher
                    categories.urb4302 +   -- Strategic Missile Defense
                    categories.url0402 +   -- Spider Bot
                    categories.urs0304 +   -- Strategic Missile Submarine
                    categories.drlk001 +   -- Cybran T3 Mobile AA

                    categories.ueb2302 +  -- Long Range Heavy Artillery
                    categories.ueb4301 +  -- T3 Heavy Shield Generator
                    categories.uel0401 +  -- Experimental Mobile Factory
                    categories.delk002 +  -- UEF T3 Mobile AA
                    categories.ues0304 +  -- Strategic Missile Submarine

                    categories.uab0304 + -- Quantum Gate
                    categories.ual0301 + -- Sub Commander
                    categories.dalk003 + -- Aeon M3 Mobile AA
                    categories.uas0304)  -- Strategic Missile Submarine
            end
        end
    end

    ScenarioFramework.SetPlayableArea('M1Area', false)

    ScenarioFramework.SetSharedUnitCap(480)
    SetArmyUnitCap(aeon, 600)
    SetArmyUnitCap(uef, 800)

    -- Army colors
    ScenarioFramework.SetCybranColor(Player1)
    ScenarioFramework.SetAeonColor(aeon)
    ScenarioFramework.SetUEFColor(uef)
    ScenarioFramework.SetUEFColor(blackSun)
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

    ScenarioFramework.StartOperationJessZoom('CDRZoom', IntroMission1)
end

function JerichoKilled()
    ScenarioFramework.Dialogue(OpStrings.C06_M01_080)
    ScenarioFramework.CDRDeathNISCamera( ScenarioInfo.Jericho, 7 )
end

----------
-- End Game
----------
-- rolled into BlackSunFired()
-- function PlayerWin()
-- end

function ControlCenterDestroyed()
    if(not ScenarioInfo.OpEnded) then
        ScenarioFramework.EndOperationSafety()
        ScenarioInfo.OpComplete = false
        ScenarioFramework.CreateVisibleAreaLocation(100, ScenarioUtils.MarkerToPosition('ControlCenter'), 0, ArmyBrains[Player1])

        -- Control center destroyed cam
--    ScenarioFramework.EndOperationCamera(ScenarioInfo.ControlCenter)
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
    if(not ScenarioInfo.OpEnded) then
        ScenarioFramework.EndOperationSafety()
        ScenarioInfo.OpComplete = false

        -- Control Center destroyed cam
--    ScenarioFramework.EndOperationCamera(ScenarioInfo.ControlCenter)
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
    ScenarioFramework.PlayerDeath(deadCommander, OpStrings.C06_D01_010)
end

function StartKillGame()
    ForkThread(KillGame)
end

function KillGame()
    if(not ScenarioInfo.OpComplete) then
        WaitSeconds(15)
    end
    ScenarioFramework.EndOperation(ScenarioInfo.OpComplete, ScenarioInfo.OpComplete, true)
end

-----------
-- Mission 1
-----------
function IntroMission1()
    ScenarioInfo.MissionNumber = 1

    -- Queue up units at player factories
    local land = {'url0202', 'url0205', 'url0303'}
    local air = {'ura0204', 'ura0303', 'ura0304'}
    local sea = {'urs0201', 'urs0202','urs0203'}
    local num = (-1 * ScenarioInfo.Options.Difficulty) + 4
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

    -- Player CDR
    ScenarioInfo.PlayerCDR = ScenarioUtils.CreateArmyUnit('Player1', 'Player')
    ScenarioInfo.PlayerCDR:PlayCommanderWarpInEffect()
    ScenarioInfo.PlayerCDR:SetCustomName(ArmyBrains[Player1].Nickname)

    ScenarioInfo.CoopCDR = {}
    local tblArmy = ListArmies()
    coop = 1
    for iArmy, strArmy in pairs(tblArmy) do
        if iArmy >= ScenarioInfo.Player2 then
            ScenarioInfo.CoopCDR[coop] = ScenarioUtils.CreateArmyUnit(strArmy, 'Player')
            ScenarioInfo.CoopCDR[coop]:PlayCommanderWarpInEffect()
            ScenarioInfo.CoopCDR[coop]:SetCustomName(ArmyBrains[iArmy].Nickname)
            coop = coop + 1
            WaitSeconds(0.5)
        end
    end

    ScenarioFramework.PauseUnitDeath(ScenarioInfo.PlayerCDR)
    for index, coopACU in ScenarioInfo.CoopCDR do
        ScenarioFramework.PauseUnitDeath(coopACU)
        ScenarioFramework.CreateUnitDeathTrigger(PlayerKilled, coopACU)
    end
    ScenarioFramework.CreateUnitDeathTrigger(PlayerKilled, ScenarioInfo.PlayerCDR)

    -- Jericho strut
    local cmd = IssueMove({ScenarioInfo.Jericho}, ScenarioUtils.MarkerToPosition('JerichoDestination'))
    while(not IsCommandDone(cmd)) do
        WaitSeconds(.5)
    end
    ScenarioFramework.Dialogue(OpStrings.C06_M01_010, StartMission1)
    WaitSeconds(5)
    if(ScenarioInfo.Jericho:IsIdleState()) then
        for i = 1, 3 do
            IssuePatrol({ScenarioInfo.Jericho}, ScenarioUtils.MarkerToPosition('Jericho_Patrol' .. i))
        end
    end

    -- After 2 minutes: Jericho VO trigger
    ScenarioFramework.CreateTimerTrigger(M1JerichoVO, 120)

    -- Cybran in Aeon LOS VO trigger
    ScenarioFramework.CreateArmyIntelTrigger(CybranSpotted, ArmyBrains[aeon], 'LOSNow',
        false, true, categories.ALLUNITS, true, ArmyBrains[Player1])

    -- UEF vs Aeon air attacks
    SpawnUEFAir()
end

function StartMission1()
    ScenarioFramework.CreateTimerTrigger(Taunt, Random(600, 900))

    -- Primary Objective 1
    ScenarioFramework.CreateArmyStatTrigger(CzarFullyBuilt, ArmyBrains[aeon], 'CzarFullyBuilt1',
        {{StatType = 'Units_Active', CompareType = 'GreaterThanOrEqual', Value = 1, Category = categories.uaa0310}})
    ScenarioFramework.CreateArmyStatTrigger(CzarDefeated, ArmyBrains[aeon], 'CzarDefeated1',
        {{StatType = 'Units_Killed', CompareType = 'GreaterThanOrEqual', Value = 1, Category = categories.uaa0310}})
    ScenarioFramework.CreateUnitDeathTrigger(CzarEngineerDefeated, ScenarioInfo.CzarEngineer)
    ScenarioInfo.M1P1 = Objectives.Basic(
        'primary',                          -- type
        'incomplete',                       -- complete
        OpStrings.OpC06_M1P1_Title,         -- title
        OpStrings.OpC06_M1P1_Desc,          -- description
        Objectives.GetActionIcon('kill'),   -- action
        {                                   -- target
            -- Category = categories.uaa0310,
        }
    )

    ForkThread(UpdateCzarObjective)

    -- M1P1 Objective Reminder
    ScenarioFramework.CreateTimerTrigger(M1P1Reminder1, M1P1Time)
end

function UpdateCzarObjective()
    local found = false
    while(not found) do
        local czar = ArmyBrains[aeon]:GetListOfUnits(categories.uaa0310, false)
        if(table.getn(czar) >= 1) then
            found = true
            ScenarioInfo.M1P1:AddUnitTarget(czar[1])
        else
            WaitSeconds(2)
        end
    end
end

function M1JerichoVO()
    if(not ScenarioInfo.Jericho:IsDead()) then
        ScenarioFramework.Dialogue(OpStrings.C06_M01_020)
    else
        ScenarioFramework.Dialogue(OpStrings.C06_M01_022)
    end
end

function CybranSpotted()
    ScenarioFramework.Dialogue(OpStrings.C06_M01_030)
    ScenarioInfo.VarTable['CybranSpotted'] = true
end

function CzarFullyBuilt()
    ScenarioInfo.CzarFullyBuilt = true
    ForkThread(CzarAI)

    ScenarioFramework.SetPlayableArea('M2Area')
    ScenarioInfo.M2Area = true

    ScenarioFramework.CreateAreaTrigger(CzarOverLand, ScenarioUtils.AreaToRect('CzarOverLand'),
        categories.uaa0310, true, false, ArmyBrains[aeon])
end

function CzarAI()
    ScenarioInfo.Czar = ArmyBrains[aeon]:GetListOfUnits(categories.uaa0310, false)
    ScenarioFramework.PauseUnitDeath( ScenarioInfo.Czar[1] )
    if(ScenarioInfo.CzarBombers) then
        ScenarioInfo.CzarBomberPlatoon = ArmyBrains[aeon]:MakePlatoon('','')
        for k, v in ScenarioInfo.CzarBombers do
            if(not v:IsDead() and not v:IsUnitState('Attached')) then
                ArmyBrains[aeon]:AssignUnitsToPlatoon(ScenarioInfo.CzarBomberPlatoon, {v}, 'attack', 'NoFormation')
                IssueClearCommands({v})
            end
        end
        if(table.getn(ScenarioInfo.CzarBomberPlatoon:GetPlatoonUnits()) > 0) then
            ScenarioInfo.CzarBomberPlatoon:Stop()
            IssueTransportLoad(ScenarioInfo.CzarBomberPlatoon:GetPlatoonUnits(), ScenarioInfo.Czar[1])
            WaitSeconds(5)
        end
    end
    IssueAttack(ScenarioInfo.Czar, ScenarioInfo.ControlCenter)
    ScenarioFramework.Dialogue(OpStrings.C06_M01_050)

    ScenarioFramework.CreateUnitDamagedTrigger(CzarDamaged, ScenarioInfo.Czar[1])
end

function CzarDamaged()
    ForkThread(ReleaseBombers)
end

function ReleaseBombers()
    if(not ScenarioInfo.BombersReleased) then
        ScenarioInfo.BombersReleased = true
        IssueClearCommands(ScenarioInfo.Czar)
        IssueTransportUnload(ScenarioInfo.Czar, ScenarioInfo.Czar[1]:GetPosition())
        WaitSeconds(5)
        IssueAttack(ScenarioInfo.Czar, ScenarioInfo.ControlCenter)
        if(ScenarioInfo.CzarBomberPlatoon and table.getn(ScenarioInfo.CzarBomberPlatoon:GetPlatoonUnits()) > 0) then
            ScenarioInfo.CzarBomberPlatoon:Stop()
            ScenarioInfo.CzarBomberPlatoon:AggressiveMoveToLocation(ScenarioInfo.ControlCenter:GetPosition())
        end
    end
end

function CzarDefeated()
    if(ScenarioInfo.M1P1.Active) then
        ScenarioInfo.M1P1:ManualResult(true)

        -- Make Control Center invulnerable
        ScenarioInfo.ControlCenter:SetCanTakeDamage(false)
        ScenarioInfo.ControlCenter:SetCanBeKilled(false)
        ScenarioInfo.ControlCenter:SetDoNotTarget(true)

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

        if(not ScenarioInfo.Arnold:IsDead()) then
            ScenarioFramework.Dialogue(OpStrings.C06_M01_100)
            ScenarioFramework.Dialogue(OpStrings.C06_M01_110, IntroMission2)
        else
            ScenarioFramework.Dialogue(OpStrings.C06_M01_100, IntroMission2)
        end
    end
end

function CzarEngineerDefeated()
    if(not ScenarioInfo.CzarFullyBuilt) then
        if(ScenarioInfo.CzarEngineer.UnitBeingBuilt) then
            ScenarioInfo.CzarEngineer.UnitBeingBuilt:Kill()
        end
    end
end

function CzarOverLand()
    if(ScenarioInfo.M1P1.Active) then
        ScenarioFramework.Dialogue(OpStrings.C06_M01_060)
    end
    ForkThread(ReleaseBombers)
end

function SpawnUEFAir()
    if(ScenarioInfo.MissionNumber == 1 and not ScenarioInfo.CzarFullyBuilt) then
        local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'SpawnedAir', 'StaggeredChevronFormation')
        platoon.PlatoonData = {}
        platoon.PlatoonData.PatrolChain = 'AeonBase_Chain'
        platoon:ForkAIThread(ScenarioPlatoonAI.RandomPatrolThread)
        ScenarioFramework.CreatePlatoonDeathTrigger(SpawnUEFAir, platoon)
    end
end

function M1P1Reminder1()
    if(ScenarioInfo.M1P1.Active) then
        ScenarioFramework.Dialogue(OpStrings.C06_M01_070)
        ScenarioFramework.CreateTimerTrigger(M1P1Reminder2, SubsequentTime)
    end
end

function M1P1Reminder2()
    if(ScenarioInfo.M1P1.Active) then
        ScenarioFramework.Dialogue(OpStrings.C06_M01_075)
        ScenarioFramework.CreateTimerTrigger(M1P1Reminder3, SubsequentTime)
    end
end

function M1P1Reminder3()
    if(ScenarioInfo.M1P1.Active) then
        ScenarioFramework.Dialogue(OpStrings.C06_M01_076)
        ScenarioFramework.CreateTimerTrigger(M1P1Reminder1, SubsequentTime)
    end
end

-----------
-- Mission 2
-----------
function IntroMission2()
    ScenarioInfo.MissionNumber = 2

    ScenarioFramework.SetSharedUnitCap(660)

    ForkThread(M2MobileFactoriesThread)

    -- UEF Naval Attack
    local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M2NavalPatrol', 'AttackFormation')
    platoon:Patrol(ScenarioUtils.MarkerToPosition('PlayerSub_Patrol1'))
    platoon:Patrol(ScenarioUtils.MarkerToPosition('PlayerSub_Patrol2'))

    -- UEF Land Attack
    for i = 1, 3 do
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M2LandPatrol_D1_' .. i, 'AttackFormation')
        platoon.PlatoonData = {}
        platoon.PlatoonData.PatrolChain = 'M2LandAttack_Chain' .. i
        platoon:ForkAIThread(ScenarioPlatoonAI.PatrolThread)
    end
    if(ScenarioInfo.Options.Difficulty >= 2) then
        for i = 1, 2 do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M2LandPatrol_D2_' .. i, 'AttackFormation')
            platoon.PlatoonData = {}
            platoon.PlatoonData.PatrolChain = 'M2LandAttack_Chain' .. i
            platoon:ForkAIThread(ScenarioPlatoonAI.PatrolThread)
        end
    end
    if(ScenarioInfo.Options.Difficulty == 3) then
        for i = 1, 3 do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M2LandPatrol_D3_' .. i, 'AttackFormation')
            platoon.PlatoonData = {}
            platoon.PlatoonData.PatrolChain = 'M2LandAttack_Chain' .. i
            platoon:ForkAIThread(ScenarioPlatoonAI.PatrolThread)
        end
    end

    -- UEF Air Attack
    for i = 1, 2 do
        local group = ScenarioUtils.CreateArmyGroup('UEF', 'M2AirPatrol_D1_' .. i)
        for k, v in group do
            platoon = ArmyBrains[uef]:MakePlatoon('','')
            ArmyBrains[uef]:AssignUnitsToPlatoon(platoon, {v}, 'attack', 'NoFormation')
            platoon.PlatoonData = {}
            platoon.PlatoonData.PatrolChain = 'ControlCenterAir_Chain'
            platoon:ForkAIThread(ScenarioPlatoonAI.RandomPatrolThread)
        end
    end
    if(ScenarioInfo.Options.Difficulty >= 2) then
        local group = ScenarioUtils.CreateArmyGroup('UEF', 'M2AirPatrol_D2_1')
        for k, v in group do
            platoon = ArmyBrains[uef]:MakePlatoon('','')
            ArmyBrains[uef]:AssignUnitsToPlatoon(platoon, {v}, 'attack', 'NoFormation')
            platoon.PlatoonData = {}
            platoon.PlatoonData.PatrolChain = 'ControlCenterAir_Chain'
            platoon:ForkAIThread(ScenarioPlatoonAI.RandomPatrolThread)
        end
    end
    if(ScenarioInfo.Options.Difficulty >= 3) then
        for i = 1, 2 do
            local group = ScenarioUtils.CreateArmyGroup('UEF', 'M2AirPatrol_D3_' .. i)
            for k, v in group do
                platoon = ArmyBrains[uef]:MakePlatoon('','')
                ArmyBrains[uef]:AssignUnitsToPlatoon(platoon, {v}, 'attack', 'NoFormation')
                platoon.PlatoonData = {}
                platoon.PlatoonData.PatrolChain = 'ControlCenterAir_Chain'
                platoon:ForkAIThread(ScenarioPlatoonAI.RandomPatrolThread)
            end
        end
    end

    -- UEF Engineers
    local engs = ScenarioUtils.CreateArmyGroup('UEF', 'M2Engineers')
    local shields = ScenarioUtils.CreateArmyGroup('UEF', 'M2Shields')
    for i = 1, 12 do
        IssueGuard({shields[i]}, engs[i])
    end

    -- Aeon Air Attack
    M2AeonAirAttack()

    -- Colossus Attack
    if(ScenarioInfo.Colossus and not ScenarioInfo.Colossus:IsDead()) then
        IssueClearCommands({ScenarioInfo.Colossus})
        IssuePatrol({ScenarioInfo.Colossus}, ScenarioUtils.MarkerToPosition('M2LandAttack_Patrol2'))
        IssuePatrol({ScenarioInfo.Colossus}, ScenarioUtils.MarkerToPosition('M2LandAttack_Patrol3'))
        IssuePatrol({ScenarioInfo.Colossus}, ScenarioUtils.MarkerToPosition('M2LandAttack_Patrol1'))
    end

    ScenarioFramework.RemoveRestrictionForAllHumans(
        categories.urb4302 +    -- T3 Strategic Missile Defense
        categories.url0402 +     -- Spider Bot
        categories.ueb2302 +      -- Long Range Heavy Artillery
        categories.ueb4301 +      -- T3 Heavy Shield Generator
        categories.uel0401 +     -- Experimental Mobile Factory
        categories.ues0304 +       -- Strategic Missile Submarine
        categories.uab0304 +     -- Quantum Gate
        categories.ual0301 +     -- Sub Commander
        categories.uas0304      -- Strategic Missile Submarine
    )

    ScenarioFramework.RemoveRestriction(uef, categories.ueb2302 +  -- Long Range Heavy Artillery
                                categories.ueb4301 +  -- T3 Heavy Shield Generator
                                categories.uel0401 +  -- Experimental Mobile Factory
                                categories.ues0304)   -- Strategic Missile Submarine

    ScenarioFramework.RemoveRestriction(aeon, categories.uab0304 + -- Quantum Gate
                                 categories.ual0301 + -- Sub Commander
                                 categories.uas0304)  -- Strategic Missile Submarine

    ScenarioFramework.Dialogue(OpStrings.C06_M02_010, StartMission2)
end

function StartMission2()
    ScenarioFramework.SetPlayableArea('M2Area')

    -- After 3 minutes: Jericho VO trigger
    ScenarioFramework.CreateTimerTrigger(M2JerichoVO, 180)

    -- After 4 minutes: Ops VO trigger
    ScenarioFramework.CreateTimerTrigger(M2OpsVO, 240)

    -- Primary Objective 1
    ScenarioInfo.M2P1 = Objectives.ArmyStatCompare(
        'primary',                      -- type
        'incomplete',                   -- complete
        OpStrings.OpC06_M2P1_Title,     -- title
        OpStrings.OpC06_M2P1_Desc,      -- description
        'build',                        -- action
        {                               -- target
            Army = Player1,
            StatName = 'Units_Active',
            CompareOp = '>=',
            Value = 1,
            Category = categories.urb0304,
        }
    )
    ScenarioInfo.M2P1:AddResultCallback(
        function()
            ScenarioFramework.Dialogue(OpStrings.C06_M02_050, GateBuilt)
        end
    )

    -- M2P1 Objective Reminder
    ScenarioFramework.CreateTimerTrigger(M2P1Reminder1, M2P1Time)
end

function M2MobileFactoriesThread()
    -- Mobile Factories
    local factory1 = ScenarioUtils.CreateArmyUnit('UEF', 'MobileFactory1')
    local factory2 = ScenarioUtils.CreateArmyUnit('UEF', 'MobileFactory2')
    local cm1 = IssueMove({factory1}, ScenarioUtils.MarkerToPosition('MobileFactory1'))
    local cm2 = IssueMove({factory2}, ScenarioUtils.MarkerToPosition('MobileFactory2'))

    repeat
        WaitSeconds(5)
    until IsCommandDone(cm1) and IsCommandDone(cm2)

    local location
    for num, loc in ArmyBrains[uef].PBM.Locations do
        if loc.LocationType == 'MobileFactories' then
            location = loc
            break
        end
    end

    if not factory1:IsDead() then
        location.PrimaryFactories.Land = factory1
        IssueFactoryRallyPoint({factory1}, ScenarioUtils.MarkerToPosition('UEF_Mobile_Fac_Build_Location_Marker') )
        if not factory2:IsDead() then
            IssueFactoryAssist({factory2}, factory1)
            IssueFactoryRallyPoint({factory2}, ScenarioUtils.MarkerToPosition('UEF_Mobile_Fac_Build_Location_Marker') )
            while not ( factory1:IsDead() and factory2:IsDead() ) do
                WaitSeconds(10)
            end
            if not factory2:IsDead() then
                location.PrimaryFactories.Land = factory2
            end
        end
    else
        if not factory2:IsDead() then
            location.PrimaryFactories.Land = factory2
            IssueFactoryRallyPoint({factory2}, ScenarioUtils.MarkerToPosition('UEF_Mobile_Fac_Build_Location_Marker') )
        end
    end
end

function M2AeonAirAttack()
    if(ScenarioInfo.MissionNumber == 2) then
        for i = 1, ScenarioInfo.Options.Difficulty do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M2AirPatrol', 'ChevronFormation')
            platoon.PlatoonData = {}
            platoon.PlatoonData.PatrolChain = 'ControlCenterAir_Chain'
            platoon:ForkAIThread(ScenarioPlatoonAI.RandomPatrolThread)
        end

        ScenarioFramework.CreateTimerTrigger(M2AeonAirAttack, Random(300, 600))
    end
end

function M2JerichoVO()
    if(not ScenarioInfo.Jericho:IsDead()) then
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
        if(not ScenarioInfo.Aiko:IsDead() and aikoTaunt <= 8) then
            PlayAikoTaunt()
        elseif(not ScenarioInfo.Arnold:IsDead() and arnoldTaunt <= 16) then
            PlayArnoldTaunt()
        end
    else
        -- Play Arnold taunt
        if(not ScenarioInfo.Arnold:IsDead() and arnoldTaunt <= 16) then
            PlayArnoldTaunt()
        elseif(not ScenarioInfo.Aiko:IsDead() and aikoTaunt <= 8) then
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

function GateBuilt()
    -- Primary Objective 2
    local gates = ScenarioFramework.GetListOfHumanUnits(categories.urb0304, false)
    ScenarioInfo.M2P2 = Objectives.Basic(
        'primary',                          -- type
        'incomplete',                       -- complete
        OpStrings.OpC06_M2P2_Title,         -- title
        OpStrings.OpC06_M2P2_Desc,          -- description
        Objectives.GetActionIcon('timer'),  -- action
        {                                   -- target
            Units = gates,
        }
    )

    -- Trigger will fire if all of the players gates are destroyed
    ScenarioFramework.CreateArmyStatTrigger(GateDestroyed, ArmyBrains[Player1], 'GateDestroyed',
        {{StatType = 'Units_Active', CompareType = 'LessThan', Value = 1, Category = categories.urb0304}})

    -- Trigger will fire when CDR is near the gate
    ScenarioInfo.CDRNearGate = ScenarioFramework.CreateUnitNearTypeTrigger(CDRNearGate, ScenarioInfo.PlayerCDR, ArmyBrains[Player1],
        categories.urb0304, 10)

    -- M2P2 Objective Reminder
    ScenarioFramework.CreateTimerTrigger(M2P2Reminder1, M2P2Time)
end

function GateDestroyed()
    if(ScenarioInfo.M2P2.Active) then
        ScenarioFramework.Dialogue(OpStrings.C06_M02_040)
        if(ScenarioInfo.CDRNearGate) then
            ScenarioInfo.CDRNearGate:Destroy()
        end
        ScenarioInfo.CDRNearGate = ScenarioFramework.CreateUnitNearTypeTrigger(CDRNearGate, ScenarioInfo.PlayerCDR, ArmyBrains[Player1],
            categories.urb0304, 10)
        if(ScenarioInfo.DownloadTimer) then
            ScenarioFramework.ResetUITimer()
            ScenarioInfo.DownloadTimer:Destroy()
        end
    end
end

function CDRNearGate()
    local position = ScenarioInfo.PlayerCDR:GetPosition()
    local rect = Rect(position[1] - 10, position[3] - 10, position[1] + 10, position[3] + 10)
    ScenarioFramework.CreateAreaTrigger(LeftGate, rect, categories.url0001, true, true, ArmyBrains[Player1])
    ScenarioInfo.DownloadTimer = ScenarioFramework.CreateTimerTrigger(DownloadFinished, 120, true)
    ScenarioFramework.Dialogue(OpStrings.C06_M02_060)

    -- Send in UEF attack on CDR
    if(not ScenarioInfo.CDRGateAttack) then
        ScenarioInfo.CDRGateAttack = true
        local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M2CDRAttack_D' .. ScenarioInfo.Options.Difficulty, 'StaggeredChevronFormation')
        platoon:AttackTarget(ScenarioInfo.PlayerCDR)
    end
end

function LeftGate()
    if(ScenarioInfo.M2P2.Active and not ScenarioInfo.PlayerCDR:IsDead()) then
        ScenarioFramework.Dialogue(OpStrings.C06_M02_070)
        ScenarioFramework.ResetUITimer()
        ScenarioInfo.DownloadTimer:Destroy()

        -- Trigger will fire when CDR is near the gate
        ScenarioFramework.CreateUnitNearTypeTrigger(CDRNearGate, ScenarioInfo.PlayerCDR, ArmyBrains[Player1],
            categories.urb0304, 10)
    end
end

function DownloadFinished()
    ScenarioFramework.Dialogue(OpStrings.C06_M02_090)
    ScenarioInfo.M2P2:ManualResult(true)

    ScenarioInfo.ControlCenter:SetCapturable(true)

    -- Primary Objective 3
    ScenarioInfo.M2P3 = Objectives.Capture(
        'primary',                      -- type
        'incomplete',                   -- complete
        OpStrings.OpC06_M2P3_Title,     -- title
        OpStrings.OpC06_M2P3_Desc,      -- description
        {                               -- target
            Units = {ScenarioInfo.ControlCenter},
            NumRequired = 1,
        }
    )
    ScenarioInfo.M2P3:AddResultCallback(
        function(result)
            if(result) then
                ScenarioFramework.Dialogue(OpStrings.C06_M02_130)

                -- Make the control center not targetable, if killed by splash damage op fails
                local unit = ScenarioFramework.GetListOfHumanUnits(categories.uec1902, false)
                ScenarioInfo.ControlCenter = unit[1]
                ScenarioInfo.ControlCenter:SetDoNotTarget(true)
                ScenarioFramework.PauseUnitDeath(ScenarioInfo.ControlCenter)
                ScenarioFramework.CreateUnitDestroyedTrigger(ControlCenterLost, ScenarioInfo.ControlCenter)

                -- control center captured cam
                local camInfo = {
                    blendTime = 1.0,
                    holdTime = 4,
                    orientationOffset = { -2.6, 0.3, 0 },
                    positionOffset = { 0, 0.5, 0 },
                    zoomVal = 30,
                }
                ScenarioFramework.OperationNISCamera( ScenarioInfo.ControlCenter, camInfo )

                IntroMission3()
            end
        end
    )

    -- M2P3 Objective Reminder
    ScenarioFramework.CreateTimerTrigger(M2P3Reminder1, M2P3Time)
end

function ControlCenterLost()
    PlayerLose()
end

function M2P1Reminder1()
    if(ScenarioInfo.M2P1.Active) then
        ScenarioFramework.Dialogue(OpStrings.C06_M02_150)
        ScenarioFramework.CreateTimerTrigger(M2P1Reminder2, SubsequentTime)
    end
end

function M2P1Reminder2()
    if(ScenarioInfo.M2P1.Active) then
        ScenarioFramework.Dialogue(OpStrings.C06_M02_155)
        ScenarioFramework.CreateTimerTrigger(M2P1Reminder3, SubsequentTime)
    end
end

function M2P1Reminder3()
    if(ScenarioInfo.M2P1.Active) then
        ScenarioFramework.Dialogue(OpStrings.C06_M01_076)
        ScenarioFramework.CreateTimerTrigger(M2P1Reminder1, SubsequentTime)
    end
end

function M2P2Reminder1()
    if(ScenarioInfo.M2P2.Active) then
        ScenarioFramework.Dialogue(OpStrings.C06_M02_160)
        ScenarioFramework.CreateTimerTrigger(M2P2Reminder2, SubsequentTime)
    end
end

function M2P2Reminder2()
    if(ScenarioInfo.M2P2.Active) then
        ScenarioFramework.Dialogue(OpStrings.C06_M02_165)
        ScenarioFramework.CreateTimerTrigger(M2P2Reminder3, SubsequentTime)
    end
end

function M2P2Reminder3()
    if(ScenarioInfo.M2P2.Active) then
        ScenarioFramework.Dialogue(OpStrings.C06_M01_076)
        ScenarioFramework.CreateTimerTrigger(M2P2Reminder1, SubsequentTime)
    end
end

function M2P3Reminder1()
    if(ScenarioInfo.M2P3.Active) then
        ScenarioFramework.Dialogue(OpStrings.C06_M02_170)
        ScenarioFramework.CreateTimerTrigger(M2P3Reminder2, SubsequentTime)
    end
end

function M2P3Reminder2()
    if(ScenarioInfo.M2P3.Active) then
        ScenarioFramework.Dialogue(OpStrings.C06_M01_076)
        ScenarioFramework.CreateTimerTrigger(M2P3Reminder1, SubsequentTime)
    end
end

-----------
-- Mission 3
-----------
function IntroMission3()
    ScenarioInfo.MissionNumber = 3

    ScenarioFramework.SetSharedUnitCap(720)
    if(ScenarioInfo.Options.Difficulty == 3) then
        ScenarioUtils.CreateArmyGroup('UEF', 'HLRA_D3')
    end

    -- Adjust buildable categories
    ScenarioFramework.PlayUnlockDialogue()
    ScenarioFramework.RemoveRestriction(Player1, categories.urb2305 +    -- Strategic Missile Launcher
                                   categories.urs0304)     -- Strategic Missile Submarine

    local tblArmy = ListArmies()
    for iArmy, strArmy in pairs(tblArmy) do
        if iArmy >= ScenarioInfo.Player2 then
            ScenarioFramework.RemoveRestriction(iArmy,
                categories.urb2305 +    -- Strategic Missile Launcher
                categories.urs0304)     -- Strategic Missile Submarine
        end
    end

    ScenarioFramework.Dialogue(OpStrings.C06_M03_010, StartMission3)
end

function StartMission3()
    ScenarioFramework.SetPlayableArea('M3Area')

    -- Nuke Aeon once Player breaks into UEF base
    for k, v in ArmyBrains[uef]:GetListOfUnits(categories.ueb2305, false) do
        v:GiveNukeSiloAmmo(5)
    end
    ScenarioFramework.CreateAreaTrigger(StartNukeAeon, ScenarioUtils.AreaToRect('UEFBaseArea'), categories.ALLUNITS,
        true, false, ArmyBrains[Player1], 1, false)

    -- Atlantis Assault
    ScenarioInfo.AtlantisPlanes = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M3AtlantisPlanes_D' .. ScenarioInfo.Options.Difficulty, 'StaggeredChevronFormation')
    ScenarioInfo.Atlantis = ScenarioUtils.CreateArmyUnit('UEF', 'Atlantis')
    IssueTransportLoad(ScenarioInfo.AtlantisPlanes:GetPlatoonUnits(), ScenarioInfo.Atlantis)
    IssueDive({ScenarioInfo.Atlantis})
    for i = 1, 9 do
        IssuePatrol({ScenarioInfo.Atlantis}, ScenarioUtils.MarkerToPosition('AtlantisAttack' .. i))
        ScenarioInfo.AtlantisBoats:Patrol(ScenarioUtils.MarkerToPosition('AtlantisAttack' .. i))
    end
    ScenarioFramework.CreateUnitNearTypeTrigger(StartAtlantisAI, ScenarioInfo.Atlantis, ArmyBrains[Player1], categories.ALLUNITS, 80)

    -- After 4 minutes: Aiko VO
    ScenarioFramework.CreateTimerTrigger(M3AikoVO, 240)

    -- Primary Objective 1
    ScenarioInfo.M3P1 = Objectives.Capture(
        'primary',                      -- type
        'incomplete',                   -- complete
        OpStrings.OpC06_M3P1_Title,     -- title
        OpStrings.OpC06_M3P1_Desc,      -- description
        {                               -- target
            Units = {ScenarioInfo.BlackSunWeapon},
            NumRequired = 1,
        }
    )
    ScenarioInfo.M3P1:AddResultCallback(
        function(result)
            if(result) then
                local unit = ScenarioFramework.GetListOfHumanUnits(categories.uec1901, false)

                -- Primary Objective 2
                ScenarioInfo.M3P2 = Objectives.Basic(
                    'primary',                          -- type
                    'incomplete',                       -- complete
                    OpStrings.OpC06_M3P2_Title,         -- title
                    OpStrings.OpC06_M3P2_Desc,          -- description
                    Objectives.GetActionIcon('kill'),   -- action
                    {                                   -- target
                        Units = unit,
                    }
                )
                unit[1]:AddSpecialToggleEnable(BlackSunFired)
                unit[1]:SetCanTakeDamage(false)
                unit[1]:SetCanBeKilled(false)
                unit[1]:SetReclaimable(false)
                unit[1]:SetCapturable(false)
                unit[1]:SetDoNotTarget(true)

                ScenarioFramework.Dialogue(OpStrings.C06_M03_060)

                -- Show the captured Black Sun
                local camInfo = {
                    blendTime = 1.0,
                    holdTime = 4,
                    orientationOffset = { 1.8, 0.7, 0 },
                    positionOffset = { 0, 1, 0 },
                    zoomVal = 75,
                }
                ScenarioFramework.OperationNISCamera( unit[1], camInfo )

                -- M3P2 Objective Reminder
                ScenarioFramework.CreateTimerTrigger(M3P2Reminder1, M3P2Time)
            end
        end
    )

    -- M3P1 Objective Reminder
    ScenarioFramework.CreateTimerTrigger(M3P1Reminder1, M3P1Time)
end

function StartAtlantisAI()
    ForkThread(AtlantisAI)
end

function AtlantisAI()
    IssueClearCommands({ScenarioInfo.Atlantis})
    IssueTransportUnload({ScenarioInfo.Atlantis}, ScenarioInfo.Atlantis:GetPosition())
    for k, v in ScenarioInfo.AtlantisPlanes:GetPlatoonUnits() do
        while(v:IsUnitState('Attached')) do
            WaitSeconds(.5)
        end
    end
    IssueDive({ScenarioInfo.Atlantis})
    IssuePatrol({ScenarioInfo.Atlantis}, ScenarioUtils.MarkerToPosition('PlayerAir_Patrol3'))
    IssuePatrol({ScenarioInfo.Atlantis}, ScenarioUtils.MarkerToPosition('PlayerAir_Patrol2'))
    IssueClearCommands(ScenarioInfo.AtlantisPlanes:GetPlatoonUnits())
    ScenarioInfo.AtlantisPlanes:Stop()
    ScenarioInfo.AtlantisPlanes:Patrol(ScenarioUtils.MarkerToPosition('PlayerBase'))
    ScenarioInfo.AtlantisPlanes:Patrol(ScenarioUtils.MarkerToPosition('PlayerAir_Patrol2'))
    ScenarioInfo.AtlantisPlanes:Patrol(ScenarioUtils.MarkerToPosition('PlayerAir_Patrol3'))

    ScenarioFramework.Dialogue(OpStrings.C06_M02_100)
end

function StartNukeAeon()
    ForkThread(NukeAeon)
end

function NukeAeon()
    if(not ScenarioInfo.Arnold:IsDead() and ArmyBrains[aeon]:GetCurrentUnits(categories.STRUCTURE) > 20) then
        ScenarioInfo.AeonNuked = true
        local nukes = ArmyBrains[uef]:GetListOfUnits(categories.ueb2305, false)
        if(not nukes[1]:IsDead()) then
            IssueClearCommands({ScenarioInfo.Arnold})
            IssueNuke({nukes[1]}, ScenarioInfo.Arnold:GetPosition())
            WaitSeconds(10)
        end
        local availableNukes = {}
        for i = 2, table.getn(nukes) do
            table.insert(availableNukes, nukes[i])
        end
        for k, v in availableNukes do
            if(not v:IsDead()) then
                IssueNuke({v}, ScenarioUtils.MarkerToPosition('Nuke' .. k))
                WaitSeconds(10)
            end
        end
        WaitSeconds(30)
        -- TODO: place trigger for when last nuke has detonated
        for i = 1, 5 do
            local units = GetUnitsInRect(ScenarioUtils.AreaToRect('Death' .. i))
            local aeonUnits = {}
            if(units) then
                for k, v in units do
                    if(not v:IsDead() and v:GetAIBrain() == ArmyBrains[aeon]) then
                        table.insert(aeonUnits, v)
                    end
                end
            end
            if(aeonUnits) then
                for k, v in aeonUnits do
                    v:Kill()
                end
            end
            WaitSeconds(1.5)
        end
    end
end

function BlackSunFired()
    if(not ScenarioInfo.OpEnded) then
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
    if(ScenarioInfo.Aiko and not ScenarioInfo.Aiko:IsDead()) then
        ScenarioFramework.Dialogue(OpStrings.C06_M03_030)
    end
end

function AikoDestroyed()
    ScenarioFramework.Dialogue(OpStrings.C06_M03_050)
    ScenarioFramework.CDRDeathNISCamera( ScenarioInfo.Aiko, 7 )
end

function ArnoldDestroyed()
    ScenarioFramework.Dialogue(OpStrings.C06_M03_055)
    ScenarioFramework.CDRDeathNISCamera( ScenarioInfo.Arnold, 7 )
end

function M3P1Reminder1()
    if(ScenarioInfo.M3P1.Active) then
        ScenarioFramework.Dialogue(OpStrings.C06_M03_070)
        ScenarioFramework.CreateTimerTrigger(M3P1Reminder2, SubsequentTime)
    end
end

function M3P1Reminder2()
    if(ScenarioInfo.M3P1.Active) then
        ScenarioFramework.Dialogue(OpStrings.C06_M03_075)
        ScenarioFramework.CreateTimerTrigger(M3P1Reminder3, SubsequentTime)
    end
end

function M3P1Reminder3()
    if(ScenarioInfo.M3P1.Active) then
        ScenarioFramework.Dialogue(OpStrings.C06_M01_076)
        ScenarioFramework.CreateTimerTrigger(M3P1Reminder1, SubsequentTime)
    end
end

function M3P2Reminder1()
    if(ScenarioInfo.M3P2.Active) then
        ScenarioFramework.Dialogue(OpStrings.C06_M03_080)
        ScenarioFramework.CreateTimerTrigger(M3P2Reminder2, SubsequentTime)
    end
end

function M3P2Reminder2()
    if(ScenarioInfo.M3P2.Active) then
        ScenarioFramework.Dialogue(OpStrings.C06_M03_085)
        ScenarioFramework.CreateTimerTrigger(M3P2Reminder3, SubsequentTime)
    end
end

function M3P2Reminder3()
    if(ScenarioInfo.M3P2.Active) then
        ScenarioFramework.Dialogue(OpStrings.C06_M01_076)
        ScenarioFramework.CreateTimerTrigger(M3P2Reminder1, SubsequentTime)
    end
end
