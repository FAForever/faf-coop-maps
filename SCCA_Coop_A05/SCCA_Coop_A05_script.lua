-- ****************************************************************************
-- **
-- **  File     :  /maps/SCCA_Coop_A05/SCCA_Coop_A05_script.lua
-- **  Author(s):  Drew Staltman
-- **
-- **  Summary  :
-- **
-- **  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
-- ****************************************************************************
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local AIBuildStructures = import('/lua/ai/aibuildstructures.lua')
local Objectives = import('/lua/SimObjectives.lua')
local OpStrings = import('/maps/SCCA_Coop_A05/SCCA_Coop_A05_Strings.lua')
local ScenarioStrings = import('/lua/scenariostrings.lua')
local Behaviors = import('/lua/ai/OpAI/OpBehaviors.lua')



-- === GLOBAL VARIABLES === #
ScenarioInfo.Player = 1
ScenarioInfo.AeonAriel = 2
ScenarioInfo.UEF = 3
ScenarioInfo.Colonies = 4
ScenarioInfo.FakeUEF = 5
ScenarioInfo.Coop1 = 6
ScenarioInfo.Coop2 = 7
ScenarioInfo.Coop3 = 8

-- === LOCAL VARIABLES === #
local Player = ScenarioInfo.Player
local Coop1 = ScenarioInfo.Coop1
local Coop2 = ScenarioInfo.Coop2
local Coop3 = ScenarioInfo.Coop3
local AeonAriel = ScenarioInfo.AeonAriel
local UEF = ScenarioInfo.UEF
local Colonies = ScenarioInfo.Colonies
local FakeUEF = ScenarioInfo.FakeUEF

local DiffLevel = ScenarioInfo.Options.Difficulty



-- === TUNING VARIABLES === #

local TauntTimer = 900
local ObjectiveReminderTimer = 600

-- ! MISSION ONE VARIABLES

-- Delay before revealing first objective
local M1SecondDialogueDelayTime = 15

-- Delay before blake talks to player
local M1BlakeIntroDelay = 300

-- Delay before Ariel attacks
local M1ArielAttackDelay = 180

-- Time before attacks against shields come whether they are up or not
local M1AttackShieldsTimer = 900

-- Timer before nuking colonies
local M1NukeDefensesTimer = 900

-- Time after shields hold that nuke objective starts
local M1DelayNukeTime = 30

-- Time after nuke objective revealed that the next attacks start
local M1AttackOneTimer = 200

-- Time after nukes are launched that we say they have been destroyed
local M1NukesShotDownTimer = 300

-- Time after first wave is announced that the wave is sent
local M1FirstAttackDelay = 40

-- Time after Wave 1 is sent that Wave 2 begins
local M1AttackWaveTwoTimer = 150

-- Time after Wave 2 announced that it is sent
local M1AttackTwoDelayTime = 15

-- Time after Wave 2 is send that Wave 3 is announced
local M1AttackThreeTimer = 200

-- Time after Wave 3 announced that it is sent in
local M1AttackThreeDelayTimer = 15

-- Time after Wave 3 sent that nukes are sent
local M1AfterAttack3Time = 480 -- 240

-- Time after nuke shown down to start M2
local EndMissionOneTimer = 10


-- ! MISSION TWO VARIABLES

local M2MiddleArtilleryUnlockTimer = 180

local M2NorthArtilleryUnlockTimer = 60

local M2SouthArtilleryUnlockTimer = 300

-- Time to remind player about shields
local M2ShieldReminderTimer = 120

-- Tell player Ariel is playing with the other Mermaids for M2
local M2ArielMessageTimer = 240

-- Time after something that somehing.
local M2WestBaseHelpTimer = 180

-- ! MISSION THREE VARIABLES

local M3ArielTaunt1Timer = 360

local M3ColWaitD1 = 600
local M3ColWaitD2 = 420
local M3ColWaitD3 = 60

local LeaderFaction
local LocalFaction

-- ##### Starter Functions ######
function OnPopulate(scenario)
    ScenarioUtils.InitializeScenarioArmies()
    LeaderFaction, LocalFaction = ScenarioFramework.GetLeaderAndLocalFactions()

    ScenarioFramework.SetPlayableArea('M1_Playable_Area', false)
    ScenarioFramework.SetAeonColor(Player)
    ScenarioFramework.SetAeonNeutralColor(AeonAriel)
    ScenarioFramework.SetUEFColor(UEF)
    ScenarioFramework.SetUEFAllyColor(Colonies)
    ScenarioFramework.SetUEFColor(FakeUEF)
    local colors = {
        ['Coop1'] = {165, 200, 102}, 
        ['Coop2'] = {46, 139, 87}, 
        ['Coop3'] = {102, 255, 204}
    }
    local tblArmy = ListArmies()
    for army, color in colors do
        if tblArmy[ScenarioInfo[army]] then
            ScenarioFramework.SetArmyColor(ScenarioInfo[army], unpack(color))
        end
    end

    -- === Create Units  === #
    -- Player
    ScenarioInfo.RhizaUnit = ScenarioUtils.CreateArmyUnit('Player', 'Rhiza_Unit')
    ScenarioInfo.RhizaUnit:SetCustomName(LOC '{i sCDR_Rhiza}')
    ScenarioFramework.CreateUnitDestroyedTrigger(RhizaDestroyed, ScenarioInfo.RhizaUnit)
    IssueMove({ ScenarioInfo.RhizaUnit }, ScenarioUtils.MarkerToPosition('Rhiza_MoveTo_Marker'))
    ScenarioUtils.CreateArmyGroup('Player', 'Player_Base')
-- local plat = ScenarioUtils.CreateArmyGroupAsPlatoon('Player', 'Gunships')
-- ScenarioFramework.PlatoonPatrolChain(plat, 'Player_Patrol_Chain')
-- plat = ScenarioUtils.CreateArmyGroupAsPlatoon('Player', 'Gunships')
-- ScenarioFramework.PlatoonPatrolChain(plat, 'Player_Patrol_Chain')

    local airPatrol = ScenarioUtils.CreateArmyGroupAsPlatoon('Player', 'Air_Patrol', 'NoFormation')
    ScenarioFramework.PlatoonPatrolChain(airPatrol, 'Player_Air_Patrol_Chain')
    local groundPatrol = ScenarioUtils.CreateArmyGroupAsPlatoon('Player', 'Ground_Patrol', 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(groundPatrol, 'Player_Land_Patrol_Chain')

    -- Some activity in the player base
    local trans1 = ScenarioUtils.CreateArmyUnit('Player', 'Start_Trans1')
    local trans2 = ScenarioUtils.CreateArmyUnit('Player', 'Start_Trans2')
    IssueMove({ trans1 }, ScenarioUtils.MarkerToPosition('Start_TransMove_1'))
    IssueMove({ trans2 }, ScenarioUtils.MarkerToPosition('Start_TransMove_2'))
    local eng1 = ScenarioInfo.UnitNames[Player]['Start_Engineer_1']
    IssueMove({ eng1 }, ScenarioUtils.MarkerToPosition('Start_Eng_Moveto_1'))

    ScenarioFramework.RestrictEnhancements({ 'Teleporter', })

    -- Colonies
    ScenarioInfo.NumColonyBuildings = 0
    ScenarioInfo.ColonyBuildingsLost = 0
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

    -- Ariel
    ArmyBrains[AeonAriel]:PBMAddBuildLocation('Ariel_Main_Base', 60, 'MainBase')
    ArmyBrains[AeonAriel]:PBMAddBuildLocation('Ariel_M1_Air_Base', 60, 'ArielM1AirBase')
    ScenarioUtils.CreateArmyGroup('Ariel', 'M1_Air_Base')

    -- UEF
    ScenarioUtils.CreateArmyGroup('UEF', 'West_Base_D'..DiffLevel)
end

function OnStart(self)
    SetArmyUnitCap(1, 300)
    ScenarioFramework.StartOperationJessZoom('Start_Camera_Area', IntroNIS)
end

function RhizaDestroyed()
    ScenarioInfo.RhizaUnitDestroyed = true
    ScenarioFramework.Dialogue(OpStrings.A05_M01_130)
end



function PlayTaunt()
    ScenarioFramework.CreateTimerTrigger(PlayTaunt, TauntTimer)
    if ScenarioInfo.MissionNumber == 2 then
        ScenarioFramework.Dialogue(OpStrings['TAUNT'..Random(9,16)])
    else
        ScenarioFramework.Dialogue(OpStrings['TAUNT'..Random(1,8)])
    end
end






-- === INTRO NIS === #
function IntroNIS()
    ScenarioInfo.PlayerCDR = ScenarioUtils.CreateArmyUnit('Player', 'Player_CDR_Unit')
    ScenarioInfo.PlayerCDR:PlayCommanderWarpInEffect()
    ScenarioInfo.PlayerCDR:SetCustomName(ArmyBrains[Player].Nickname)

    -- spawn coop players too
    ScenarioInfo.CoopCDR = {}
    local tblArmy = ListArmies()
    coop = 1
    for iArmy, strArmy in pairs(tblArmy) do
        if iArmy >= ScenarioInfo.Coop1 then
            ScenarioInfo.CoopCDR[coop] = ScenarioUtils.CreateArmyUnit(strArmy, 'Player_CDR_Unit')
            ScenarioInfo.CoopCDR[coop]:PlayCommanderWarpInEffect()
            ScenarioInfo.CoopCDR[coop]:SetCustomName(ArmyBrains[iArmy].Nickname)
            coop = coop + 1
            WaitSeconds(0.5)
        end
    end

    ScenarioFramework.CreateUnitDestroyedTrigger(PlayerCDRDestroyed, ScenarioInfo.PlayerCDR)
    ScenarioFramework.PauseUnitDeath(ScenarioInfo.PlayerCDR)

    for index, coopACU in ScenarioInfo.CoopCDR do
        ScenarioFramework.PauseUnitDeath(coopACU)
        ScenarioFramework.CreateUnitDeathTrigger(PlayerCDRDestroyed, coopACU)
    end
    IssueMove({ ScenarioInfo.PlayerCDR }, ScenarioUtils.MarkerToPosition('Start_PlayerMove_1'))

    -- Delay opening of mission till after player is warped in
    ScenarioFramework.CreateTimerTrigger(StartMission1, 3.3)
end






-- === MISSION ONE FUNCTIONS === #
function StartMission1()
    -- Set up
    ScenarioInfo.MissionNumber = 1
    ScenarioFramework.Dialogue(OpStrings.A05_M01_010, M1SecondDialogueDelay)

    -- Timer triggers
    ScenarioFramework.CreateTimerTrigger(M1BlakeIntro, M1BlakeIntroDelay)
    -- ScenarioFramework.CreateTimerTrigger(M1ArielAttackDialogue, M1ArielAttackDelay)

    -- Lock off buildable tech for player and his buddies the enemy
    for _, player in ScenarioInfo.HumanPlayers do
         ScenarioFramework.AddRestriction(player, (categories.NAVAL * categories.TECH3) +
                                      categories.EXPERIMENTAL +
                                      categories.PRODUCTFA + -- All FA Units
     
                                      categories.uab4302 +
                                      categories.uab0301 +
                                      categories.uab2305 +
                                      categories.uab3104 +
                                      categories.uab2302 +
                                      categories.uab0304 +
     
                                      categories.ueb0301 +
                                      categories.ueb2305 +
                                      categories.ueb3104 +
                                      categories.ueb2302 +
                                      categories.ueb0304 )
    end

    -- Aeon Tech locking
    ScenarioFramework.AddRestriction(AeonAriel, categories.ual0303 +
                                    categories.ual0304 +
                                    categories.uaa0304)

    -- Assist engineers in M1
    local plat = ScenarioUtils.CreateArmyGroupAsPlatoon('Ariel', 'M1_Air_Base_Engineers_D'..DiffLevel, 'NoFormation')
    plat.PlatoonData.AssistFactories = true
    plat.PlatoonData.LocationType = 'ArielM1AirBase'
    plat:ForkAIThread(ScenarioPlatoonAI.StartBaseEngineerThread)

    ScenarioFramework.CreateTimerTrigger(PlayTaunt, TauntTimer)
end

-- Delay second dialogue at beginning of M1
function M1SecondDialogueDelay()
    -- Protect the colonies objective
    -- Protect objective
    local objUnits = ScenarioInfo.EastColony
    for num, unit in ScenarioInfo.WestColony do
        table.insert(objUnits, unit)
    end
-- for num, unit in objUnits do
--    ScenarioFramework.CreateUnitDestroyedTrigger(M1CivilianStructureDestroyed, unit)
-- end
    ScenarioInfo.M1NumberCivBuildings = table.getn(objUnits)
    ScenarioInfo.M1CivBuildingThreshold = math.ceil(ScenarioInfo.M1NumberCivBuildings / 2)

    ScenarioInfo.M1P3Obj = Objectives.Protect('primary', 'incomplete', OpStrings.M1P3Title, LOCF(OpStrings.M1P3Description, 50),
        {
            Units = objUnits,
            MarkUnits = true,
            PercentProgress = true,
            NumRequired = math.ceil(ScenarioInfo.M1NumberCivBuildings / 2)
        }
   )
    ScenarioInfo.M1P3Obj:AddResultCallback(M1P3ResultCallback)
    WaitSeconds(M1SecondDialogueDelayTime)
    ScenarioFramework.Dialogue(OpStrings.A05_M01_020, M1RevealShieldsObjective)
end

function M1CivilianStructureDestroyed()
    if not ScenarioInfo.M1CivBuildingsDestroyed then
        ScenarioInfo.M1CivBuildingsDestroyed = 1
    else
        ScenarioInfo.M1CivBuildingsDestroyed = ScenarioInfo.M1CivBuildingsDestroyed + 1
    end
    if ScenarioInfo.M1CivBuildingsDestroyed > ScenarioInfo.M1CivBuildingThreshold then
        ScenarioInfo.M1P3Obj:ManualResult(false)
    end
end

-- Tell the player to be awesome and make stuff
function M1RevealShieldsObjective()
    -- Primary Objective 1
    ScenarioInfo.M1P1Obj = Objectives.CategoriesInArea(
        'secondary',                      -- type
        'incomplete',                   -- complete
        OpStrings.M1P1Title,     -- title
        OpStrings.M1P1Description,      -- description
        'build',                        -- action
        {                               -- target
            MarkArea = true,
            Requirements = {
                {Area = 'M1P1_West_Area', Category = categories.uab4301, CompareOp='>=', Value = 1,},
                {Area = 'M1P1_East_Area', Category = categories.uab4301, CompareOp='>=', Value = 1,},
            },
            Category = categories.uab4301,
        }
   )
    ScenarioInfo.M1P1Obj:AddResultCallback(M1ShieldsBuilt)
    ScenarioFramework.CreateTimerTrigger(M1ShieldTimerCall, M1AttackShieldsTimer)
end

-- Shield timer thing of whatever
function M1ShieldTimerCall()
    if ScenarioInfo.MissionNumber == 1 then
        if not ScenarioInfo.M1ShieldAttackSent then
            ScenarioInfo.M1ShieldsFailed = true
            ScenarioInfo.M1P1Obj:ManualResult(false)
        end
    end
end

function M1ShieldsBuilt(result)
    if ScenarioInfo.MissionNumber == 1 then
        if not ScenarioInfo.M1ShieldComplete then
            ScenarioInfo.M1ShieldComplete = true
            if not ScenarioInfo.M1ShieldsFailed then
                ScenarioFramework.Dialogue(OpStrings.A05_M01_040, M1ShieldsBuiltThread)
            else
                ForkThread(M1ShieldsBuiltThread)
            end
        end
    end
end

function M1ShieldsBuiltThread()
    WaitSeconds(10)
    ScenarioFramework.Dialogue(OpStrings.A05_M01_050, M1AttackShields)
end

-- ZE SHIELDS! Send in attacks
function M1AttackShields()
    if not ScenarioInfo.M1ShieldAttackSent and ScenarioInfo.MissionNumber == 1 then
        ScenarioInfo.M1ShieldAttackSent = true
        -- Attack players shields
        local westPlat = ScenarioUtils.CreateArmyGroupAsPlatoon('Ariel', 'M1_West_Colony_Bombers_D'..DiffLevel, 'NoFormation')
        westPlat:AggressiveMoveToLocation(ScenarioUtils.MarkerToPosition('West_Colony_Marker'))
        local eastPlat = ScenarioUtils.CreateArmyGroupAsPlatoon('Ariel', 'M1_East_Colony_Bombers_D'..DiffLevel, 'NoFormation')
        eastPlat:AggressiveMoveToLocation(ScenarioUtils.MarkerToPosition('East_Colony_Marker'))
        local bombers = {}
        for num, unit in westPlat:GetPlatoonUnits() do
            table.insert(bombers, unit)
        end
        for num, unit in eastPlat:GetPlatoonUnits() do
            table.insert(bombers, unit)
        end
        local deathPlat = ArmyBrains[AeonAriel]:MakePlatoon('', '')
        ArmyBrains[AeonAriel]:AssignUnitsToPlatoon(deathPlat, bombers, 'attack', 'Noformation')
        ScenarioFramework.CreatePlatoonDeathTrigger(M1ShieldsHeld, deathPlat)
    end
end

-- Shield has held, talk amongst yourselves then start the nuke delay
function M1ShieldsHeld()
    ScenarioFramework.Dialogue(OpStrings.A05_M01_060, M1DelayNukes)
end

-- Delay before nuke objective revealed
function M1DelayNukes()
    WaitSeconds(M1DelayNukeTime)
    ScenarioFramework.Dialogue(OpStrings.A05_M01_070, M1RevealNukeObjective)
end

-- Reveal that the player has work yet to be finished
function M1RevealNukeObjective()
    ScenarioFramework.RemoveRestrictionForAllHumans(categories.uab4302)

    -- Primary Objective 2
    ScenarioInfo.M1P2Obj = Objectives.Basic(
        'secondary',                           -- type
        'incomplete',                          -- complete
        OpStrings.M1P2Title,                   -- title
        OpStrings.M1P2Description,             -- description
        Objectives.GetActionIcon('build'),  -- action
        {                                      -- target
            MarkArea = true,
            Areas = { 'M1P2_West_Area', 'M1P2_East_Area', },
            Category = categories.uab4302,
        }
   )

    ScenarioInfo.NukeDefensesCount = 0
    ForkThread(SiloAmmoThread, M1NukeDefensesBuilt, 'M1P2_West_Area')
    ForkThread(SiloAmmoThread, M1NukeDefensesBuilt, 'M1P2_East_Area')

    ScenarioFramework.CreateTimerTrigger(M1AttackWaveOne, M1AttackOneTimer)
    ScenarioFramework.CreateTimerTrigger(M1ObjectiveReminder, ObjectiveReminderTimer)
end

function SiloAmmoThread(callback, areaName)
    local hasAmmo = false
    local rect = ScenarioUtils.AreaToRect(areaName)
    while not hasAmmo do
        local units = GetUnitsInRect(rect)
        for k,v in units do
            if not v:IsDead() and v:GetAIBrain():GetArmyIndex() == 1 and EntityCategoryContains(categories.SILO * categories.ANTIMISSILE, v) then
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
    if not ScenarioInfo.M1NukesSent then
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
            ScenarioFramework.Dialogue(OpStrings.A05_M01_080)

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
            ScenarioFramework.CreateTimerTrigger(M1ArielNukes, (M1AfterAttack3Time / 4)) -- launch quick now, for show
        end
    end
end

-- Nuke the player and then talk smack, timer after nukes to start realz attacks
function M1ArielNukes()
    -- LOG('debug:Nuke...')
    if not ScenarioInfo.M1ArielNukesSent then
        ScenarioInfo.M1ArielNukesSent = true
        if not ScenarioInfo.NukesBuilt then
    -- comment next line out to make it work with function key
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
        ScenarioFramework.CreateTimerTrigger(M1NukeShotDown, M1NukesShotDownTimer)
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
-- ScenarioFramework.OperationNISCamera(unit, camInfo)
end

function M1NukeShotDown(projectile)
    if not ScenarioInfo.NukesShotDown then
        ScenarioInfo.NukesShotDown = 1
    else
        ScenarioInfo.NukesShotDown = ScenarioInfo.NukesShotDown + 1
    end
    if ScenarioInfo.NukesShotDown == 2 then
        M1NukesAllShotDown()
    end
end

-- When Ariel's nukes are pwned send in the first attack
function M1NukesAllShotDown()
    ScenarioFramework.CreateTimerTrigger(EndMission1, EndMissionOneTimer)
-- ScenarioInfo.M1P3Obj = Objectives.Basic('primary', 'incomplete', OpStrings.M1P3Title, OpStrings.M1P3Description, Objectives.GetActionIcon('protect'))
    -- Send first attack wave
end

-- Send first attack
function M1AttackWaveOne()
    ScenarioFramework.Dialogue(OpStrings.A05_M01_100)
    WaitSeconds(M1FirstAttackDelay)
    local plat = ScenarioUtils.CreateArmyGroupAsPlatoon('Ariel', 'M1A1_Air_Group_D'..DiffLevel, 'ChevronFormation')
    plat:AggressiveMoveToLocation(ScenarioUtils.MarkerToPosition('East_Colony_Marker'))
    -- ScenarioFramework.CreatePlatoonDeathTrigger(M1AttackWaveTwo, plat)
    ScenarioFramework.CreateTimerTrigger(M1AttackWaveTwo, M1AttackWaveTwoTimer)
end

-- Function to play dialogue then begin Attack Two when dialogue over
function M1AttackWaveTwo()
    if not ScenarioInfo.M1AttackTwoStarted then
        ScenarioInfo.M1AttackTwoStarted = true
        ScenarioFramework.Dialogue(OpStrings.A05_M01_110, M1AttackTwoDelay)
    end
end

-- Attack two which is a land attack via transports
function M1AttackTwoDelay()
    WaitSeconds(M1AttackTwoDelayTime)
    local escorts = ScenarioUtils.CreateArmyGroupAsPlatoon('Ariel', 'M1A2_Escorts_D'..DiffLevel, 'NoFormation')
    ScenarioFramework.PlatoonPatrolChain(escorts, 'Ariel_M1_West_Air_Patrol_Chain')
    local units = ScenarioUtils.CreateArmyGroupAsPlatoon('Ariel', 'M1A2_Unit_Group_D'..DiffLevel, 'AttackFormation')
    local transports = ScenarioUtils.CreateArmyGroupAsPlatoon('Ariel', 'M1A2_Transport_Group_D'..DiffLevel, 'NoFormation')
    -- ScenarioFramework.CreatePlatoonDeathTrigger(M1AttackThree, units)
    ScenarioFramework.CreateTimerTrigger(M1AttackThree, M1AttackThreeTimer)
    ForkThread(M1LandAttack, units, transports, 'West')
end

-- Function to play attack three dialogue then start the attack after dialogue
function M1AttackThree()
    if not ScenarioInfo.M1AttackThreeStarted then
        ScenarioInfo.M1AttackThreeStarted = true
        ScenarioFramework.Dialogue(OpStrings.A05_M01_120 ,M1AttackThreeDelay)
    end
end

-- Attack Three which is combined attacks on both targets
function M1AttackThreeDelay()
    WaitSeconds(M1AttackThreeDelayTimer)
    local westAir = ScenarioUtils.CreateArmyGroupAsPlatoon('Ariel', 'M1A3_West_Air_Attack_D'..DiffLevel, 'ChevronFormation')
    westAir:AggressiveMoveToLocation(ScenarioUtils.MarkerToPosition('West_Colony_Marker'))
    local westUnits = ScenarioUtils.CreateArmyGroupAsPlatoon('Ariel', 'M1A3_West_Ground_Units_D'..DiffLevel, 'AttackFormation')
    local westTransports = ScenarioUtils.CreateArmyGroupAsPlatoon('Ariel', 'M1A3_West_Transports_D'..DiffLevel, 'NoFormation')
-- ScenarioFramework.CreatePlatoonDeathTrigger(M1AttackThreePlatDeath, westUnits)
-- ScenarioFramework.CreatePlatoonDeathTrigger(M1AttackThreePlatDeath, westAir)
    ForkThread(M1LandAttack, westUnits, westTransports, 'West')


    local eastAir = ScenarioUtils.CreateArmyGroupAsPlatoon('Ariel', 'M1A3_East_Air_Attack_D'..DiffLevel, 'ChevronFormation')
    eastAir:AggressiveMoveToLocation(ScenarioUtils.MarkerToPosition('East_Colony_Marker'))
    local eastUnits = ScenarioUtils.CreateArmyGroupAsPlatoon('Ariel', 'M1A3_East_Ground_Units_D'..DiffLevel, 'AttackFormation')
    local eastTransports = ScenarioUtils.CreateArmyGroupAsPlatoon('Ariel', 'M1A3_East_Transports_D'..DiffLevel, 'NoFormation')
-- ScenarioFramework.CreatePlatoonDeathTrigger(M1AttackThreePlatDeath, eastUnits)
-- ScenarioFramework.CreatePlatoonDeathTrigger(M1AttackThreePlatDeath, eastAir)
    ForkThread(M1LandAttack, eastUnits, eastTransports, 'East')

    ScenarioFramework.CreateTimerTrigger(M1ArielNukes, M1AfterAttack3Time)
end

-- When a freaking Attack three platoon dies horrifically
function M1AttackThreePlatDeath(platoon)
    if not ScenarioInfo.M1A3PlatDeathCounter then
        ScenarioInfo.M1A3PlatDeathCounter = 1
    else
        ScenarioInfo.M1A3PlatDeathCounter = ScenarioInfo.M1A3PlatDeathCounter + 1
        if ScenarioInfo.M1A3PlatDeathCounter == 4 then
            EndMission1()
        end
    end
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
    while ArmyBrains[AeonAriel]:PlatoonExists(transports) and transports:IsCommandsActive(cmd) do
        WaitSeconds(5)
    end
    if ArmyBrains[AeonAriel]:PlatoonExists(transports) then
        for num, unit in transports:GetPlatoonUnits() do
            if not unit:IsDead() then
                unit:Destroy()
            end
        end
    end
end

-- Blake talky-talky scene
function M1BlakeIntro()
    ScenarioFramework.Dialogue(OpStrings.A05_M01_030)
end

-- Ariel attacks with bombers and light attacks begin
-- function M1ArielAttackDialogue()
-- ScenarioFramework.Dialogue(OpStrings.A05_M01_050, M1ArielFirstAttack)
-- end

-- Trigger ariel to attack and send in weak bombers
function M1ArielFirstAttack()
    ScenarioInfo.VarTable['M1EnableArielAir'] = true
end

function M1P3ResultCallback(result)
    if result then
    else
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
end

-- Hooray! Le Player winz ze first mission!
function EndMission1()
    if not ScenarioInfo.MissionOneOver then
        ScenarioInfo.M1P3Obj:ManualResult(true)
        ScenarioInfo.MissionOneOver = true
        ScenarioFramework.Dialogue(OpStrings.A05_M01_160, StartMission2)
    end
end

function M1ObjectiveReminder()
    if ScenarioInfo.MissionNumber == 1 and not ScenarioInfo.NukesBuilt then
        ScenarioFramework.CreateTimerTrigger(M1ObjectiveReminder, ObjectiveReminderTimer)
        if Random(1,2) == 1 then
            ScenarioFramework.Dialogue(OpStrings.A05_M01_140)
        else
            ScenarioFramework.Dialogue(OpStrings.A05_M01_145)
        end
    end
end

-- === MISSION TWO FUNCTIONS === #
function StartMission2()
    local plat = {}
    SetArmyUnitCap(1, 400)
    ScenarioInfo.MissionNumber = 2
    ScenarioFramework.SetPlayableArea('M2_Playable_Area')

    ScenarioFramework.Dialogue(OpStrings.A05_M02_010)

    -- Disable Ariel air attacks
    ScenarioInfo.VarTable['M1EnableArielAir'] = false

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
    SetAlliance(AeonAriel, Colonies, 'Neutral')

    -- Allow player to build awesomeness
    ScenarioFramework.RemoveRestrictionForAllHumans(categories.uab0301 + categories.zab9601 + categories.ueb0301 + categories.zeb9601)
    ScenarioFramework.RemoveRestriction(UEF, categories.uel0303 + categories.uel0304)

    -- UEF Setup
    ArmyBrains[UEF]:PBMAddBuildLocation('UEF_West_Base', 100, 'WestBase')

    AIBuildStructures.CreateBuildingTemplate(ArmyBrains[UEF], 'UEF', 'West_Base')
    AIBuildStructures.AppendBuildingTemplate(ArmyBrains[UEF], 'UEF', 'West_Base_D'..DiffLevel, 'West_Base')

    ScenarioUtils.CreateArmyGroup('UEF', 'West_Base_Walls')
    ScenarioUtils.CreateArmyGroup('UEF', 'West_Base_North_Defenses_D'..DiffLevel)
    ScenarioUtils.CreateArmyGroup('UEF', 'West_Base_South_Defenses_D'..DiffLevel)
    ScenarioInfo.WestArtillery = ScenarioUtils.CreateArmyGroup('UEF', 'West_Base_Artillery_D'..DiffLevel)
    for num, unit in ScenarioInfo.WestArtillery do
        ScenarioFramework.CreateArmyIntelTrigger(M2PlayerSeesWestArtillery, ArmyBrains[Player], 'LOSNow', unit, true, categories.ALLUNITS, true, ArmyBrains[UEF])
    end

    ScenarioUtils.CreateArmyGroup('UEF' ,'Wreck_M2', true) -- Storing all wreckage in UEF army

    plat = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'West_Base_Engineers_D'..DiffLevel, 'NoFormation')
    plat.PlatoonData.AssistFactories = true
    plat.PlatoonData.LocationType = 'WestBase'
    plat.PlatoonData.MaintainBaseTemplate = 'West_Base'
    plat:ForkAIThread(ScenarioPlatoonAI.StartBaseEngineerThread)

    plat = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'Blake_Group', 'NoFormation')
    ScenarioInfo.BlakeUnit = plat:GetPlatoonUnits()[1]
    ScenarioInfo.BlakeUnit:SetCustomName(LOC '{i CDR_Blake}')
    ScenarioInfo.BlakeUnit:CreateEnhancement('Shield')
    ScenarioInfo.BlakeUnit:CreateEnhancement('DamageStablization')
    ScenarioInfo.BlakeUnit:CreateEnhancement('ResourceAllocation')
    M2RevealObjectives() -- Cant assign this before blake exists

    -- delay his death
    ScenarioFramework.PauseUnitDeath(ScenarioInfo.BlakeUnit)

    plat.PlatoonData.AssistFactories = true
    plat.PlatoonData.LocationType = 'WestBase'
    plat.PlatoonData.MaintainBaseTemplate = 'West_Base'
    plat:ForkAIThread(ScenarioPlatoonAI.StartBaseEngineerThread)

    plat.CDRData = {}
    plat.CDRData.LeashPosition = 'Blake_Leash_Marker'
    plat.CDRData.LeashRadius = 50
    plat:ForkThread(Behaviors.CDROverchargeBehavior)

    M2SetupArtilleryPositions()

    ScenarioFramework.CreateTimerTrigger(M2ShieldReminder, M2ShieldReminderTimer)
    ScenarioFramework.CreateTimerTrigger(M2ArielMessage, M2ArielMessageTimer)
    ScenarioFramework.CreateArmyStatTrigger(EnableUEFT3Land, ArmyBrains[Player], 'T3LandUnitCounter',
        {
            { StatType = 'Units_Active', CompareType = 'GreaterThanOrEqual', Value = 0, Category =(categories.LAND * categories.TECH3 * categories.MOBILE) - categories.ual0309, },
        }
   )
    ScenarioFramework.CreateTimerTrigger(M2ObjectiveReminder, ObjectiveReminderTimer)
end

-- Setup the artillery positions and engineers and all that nonsens
function M2SetupArtilleryPositions()
    AIBuildStructures.CreateBuildingTemplate(ArmyBrains[UEF], 'UEF', 'North_Artillery')
    AIBuildStructures.AppendBuildingTemplate(ArmyBrains[UEF], 'UEF', 'North_Artillery_D'..DiffLevel, 'North_Artillery')

    AIBuildStructures.CreateBuildingTemplate(ArmyBrains[UEF], 'UEF', 'Middle_Artillery')
    AIBuildStructures.AppendBuildingTemplate(ArmyBrains[UEF], 'UEF', 'Middle_Artillery_D'..DiffLevel, 'Middle_Artillery')

    AIBuildStructures.CreateBuildingTemplate(ArmyBrains[UEF], 'UEF', 'South_Artillery')
    AIBuildStructures.AppendBuildingTemplate(ArmyBrains[UEF], 'UEF', 'South_Artillery_D'..DiffLevel, 'South_Artillery')

    AIBuildStructures.AppendBuildingTemplate(ArmyBrains[UEF], 'UEF', 'South_Artillery_Build', 'South_Artillery')
    AIBuildStructures.AppendBuildingTemplate(ArmyBrains[UEF], 'UEF', 'Middle_Artillery_Build', 'Middle_Artillery')
    AIBuildStructures.AppendBuildingTemplate(ArmyBrains[UEF], 'UEF', 'North_Artillery_HLRA_Add', 'North_Artillery')


    ScenarioUtils.CreateArmyGroup('UEF', 'North_Artillery_D'..DiffLevel)
    ScenarioUtils.CreateArmyGroup('UEF', 'Middle_Artillery_D'..DiffLevel)
    ScenarioUtils.CreateArmyGroup('UEF', 'South_Artillery_D'..DiffLevel)

    plat = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'North_Unit_Defenses_D'..DiffLevel, 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(plat, 'UEF_M2_North_Artillery_Patrol_Chain')
    plat = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'Middle_Unit_Defenses_D'..DiffLevel, 'AttackFormation')
    plat = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'South_Unit_Defenses_D'..DiffLevel, 'NoFormation')
    ScenarioFramework.PlatoonPatrolChain(plat, 'UEF_M2_South_Artillery_Patrol_Chain')

    plat = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'North_Engineers_D'..DiffLevel, 'NoFormation')
    plat.PlatoonData.MaintainBaseTemplate = 'North_Artillery'
    plat.PlatoonData.PatrolChain = 'UEF_M2_North_Eng_Art_Patrol_Chain'
    plat:ForkAIThread(ScenarioPlatoonAI.StartBaseEngineerThread)

    plat = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'Middle_Engineers_D'..DiffLevel, 'NoFormation')
    plat.PlatoonData.MaintainBaseTemplate = 'Middle_Artillery'
    plat.PlatoonData.MaintainDiffLevel = 1
    plat.PlatoonData.PatrolChain = 'UEF_M2_Middle_Eng_Art_Patrol_Chain'
    plat:ForkAIThread(ScenarioPlatoonAI.StartBaseEngineerThread)
    for num, unit in plat:GetPlatoonUnits() do
        ScenarioFramework.CreateUnitBuiltTrigger(M2ArtilleryBuilt, unit, categories.ueb2302)
    end

    plat = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'South_Engineers_D'..DiffLevel, 'NoFormation')
    plat.PlatoonData.MaintainBaseTemplate = 'South_Artillery'
    plat.PlatoonData.MaintainDiffLevel = 1
    plat.PlatoonData.PatrolChain = 'UEF_M2_South_Eng_Art_Patrol_Chain'
    plat:ForkAIThread(ScenarioPlatoonAI.StartBaseEngineerThread)
    for num, unit in plat:GetPlatoonUnits() do
        ScenarioFramework.CreateUnitBuiltTrigger(M2ArtilleryBuilt, unit, categories.ueb2302)
    end

    ScenarioInfo.NorthArtilleryPiece = ScenarioUtils.CreateArmyUnit('FakeUEF', 'North_Artillery_Unit')

    ScenarioFramework.CreateTimerTrigger(M2OpenNorthArtillery, M2NorthArtilleryUnlockTimer)
end

function EnableUEFT3Land()
    ScenarioFramework.PlayUnlockDialogue()
    ScenarioFramework.RemoveRestriction(UEF, categories.uel0303 + categories.uel0304)
end

-- Switch North HLRA to UEF
function M2OpenNorthArtillery()
    if not ScenarioInfo.NorthArtilleryPiece:IsDead() then
        ScenarioFramework.GiveUnitToArmy(ScenarioInfo.NorthArtilleryPiece, UEF)
    end
    ScenarioFramework.CreateAreaTrigger(M2NorthArtilleryDefeated, 'North_Artillery_Area', categories.uel0309 + categories.ueb2302, true, true, ArmyBrains[UEF])
end

-- Reveal to the player that artillyer and Blake needed a good thumpin
function M2RevealObjectives()
    ScenarioInfo.M2P1Obj = Objectives.CategoriesInArea('primary', 'incomplete', OpStrings.M2P1Title,
                                                     OpStrings.M2P1Description, 'kill',
                {
                    Requirements = {
                        { Area='North_Artillery_Area', Category = categories.uel0309 + categories.ueb2302,
                          CompareOp = '==', Value = 0, ArmyIndex = UEF },
                        { Area='Middle_Artillery_Area', Category = categories.uel0309 + categories.ueb2302,
                          CompareOp = '==', Value = 0, ArmyIndex = UEF },
                        { Area='South_Artillery_Area', Category = categories.uel0309 + categories.ueb2302,
                          CompareOp = '==', Value = 0, ArmyIndex = UEF },
                    },
                    MarkArea = true,
                    Category = categories.ueb2302,  -- forces icon
                }
           )
    ScenarioInfo.M2P1Obj:AddResultCallback(M2ArtilleryDestroyed)

    
    ScenarioFramework.CreateAreaTrigger(M2MiddleArtilleryDefeated, 'Middle_Artillery_Area', categories.uel0309 + categories.ueb2302, true, true, ArmyBrains[UEF])
    ScenarioFramework.CreateAreaTrigger(M2SouthArtilleryDefeated, 'South_Artillery_Area', categories.uel0309 + categories.ueb2302, true, true, ArmyBrains[UEF])

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

-- Blake will do stuff to hinder things for the player, somehow
function M2BlakeAIThread(platoon)
    platoon.PlatoonData.LocationType = 'WestBase'
    platoon:PatrolLocationFactoriesAI()
end

function M2ArtilleryDestroyed(result)
    if result then
        ScenarioInfo.M2ArtilleryDestroyedBool = true
        ScenarioFramework.CreateTimerTrigger(M2WestBaseHelp, M2WestBaseHelpTimer)
    end
end

function M2CheckObjectives()
    if ScenarioInfo.M2BlakeDestroyedBool and ScenarioInfo.M2ArtilleryDestroyedBool then
        ForkThread(EndMission2)
    end
end

function M2ShieldReminder()
    ScenarioFramework.Dialogue(OpStrings.A05_M02_030)
end

function M2ArielMessage()
    ScenarioFramework.Dialogue(OpStrings.A05_M02_070)
end

function M2PlayerSeesWestArtillery()
    if not ScenarioInfo.PlayerSeesWestArtilleryBool then
        ScenarioInfo.PlayerSeesWestArtilleryBool = true
        ScenarioFramework.Dialogue(OpStrings.A05_M02_090)
        local westArtilUnits = {}
        for num, unit in ScenarioInfo.WestArtillery do
            if EntityCategoryContains(categories.ueb2303, unit) then
                table.insert(westArtilUnits, unit)
            end
        end
        ScenarioInfo.M2S2Obj = Objectives.KillOrCapture('secondary', 'incomplete', OpStrings.M2S1Title, OpStrings.M2S1Description,
            {
                Units = westArtilUnits,
            }
       )
    end
end

function M2WestBaseHelp()
    if ScenarioInfo.MissionNumber == 2 and not ScenarioInfo.M2BlakeDestroyedBool then
        ScenarioFramework.Dialogue(OpStrings.A05_M02_100)
    end
end

function EndMission2()
    ScenarioFramework.Dialogue(OpStrings.A05_M02_150, StartMission3)
end

function M2ObjectiveReminder()
    if ScenarioInfo.MissionNumber == 2 then
        ScenarioFramework.CreateTimerTrigger(M2ObjectiveReminder, ObjectiveReminderTimer)
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








-- === MISSION THREE FUNCTIONS === #
function StartMission3()
    -- Setup and stuff
    ScenarioInfo.MissionNumber = 3
    SetArmyUnitCap(1, 500)
    ScenarioFramework.SetPlayableArea('M3_Playable_Area')
    ScenarioFramework.Dialogue(OpStrings.A05_M03_010, M3P1ObjectiveDialogue)
    ScenarioInfo.VarTable['M1EnableArielAir'] = true

    -- Unlock le nukes
    ScenarioFramework.RemoveRestrictionForAllHumans(categories.uab2305 + categories.ueb2305)
    ScenarioFramework.RemoveRestriction(AeonAriel, categories.uaa0304 + categories.ual0303)

    ScenarioFramework.CreateTimerTrigger(M3ArielTaunt1, M3ArielTaunt1Timer)

    -- Spawn le Ariel
    ScenarioUtils.CreateArmyGroup('Ariel', 'M3_Main_Base_D'..DiffLevel)
    ScenarioUtils.CreateArmyGroup('Ariel', 'M3_Extra_Mass')
    ScenarioUtils.CreateArmyGroup('Ariel', 'M3_Walls')
    ScenarioUtils.CreateArmyGroup('Ariel', 'M3_Defensive_Line')

    AIBuildStructures.CreateBuildingTemplate(ArmyBrains[AeonAriel], 'Ariel', 'Main_Base')
    AIBuildStructures.AppendBuildingTemplate(ArmyBrains[AeonAriel], 'Ariel', 'M3_Main_Base_D'..DiffLevel, 'Main_Base')

    local antiNukes = ArmyBrains[AeonAriel]:GetListOfUnits(categories.ueb4302, false)
    for num, unit in antiNukes do
        unit:GiveTacticalSiloAmmo(3)
    end

    -- Base Air Patrols
    local plat
    plat = ScenarioUtils.CreateArmyGroupAsPlatoon('Ariel', 'M3_Eastern_Patrol', 'NoFormation')
    ScenarioFramework.PlatoonPatrolChain(plat, 'Ariel_M3_East_Patrol_Chain')
    plat = ScenarioUtils.CreateArmyGroupAsPlatoon('Ariel', 'M3_Main_Base_Patrol', 'NoFormation')
    ScenarioFramework.PlatoonPatrolChain(plat, 'Ariel_MainBase_BasePatrolChain')
    plat = ScenarioUtils.CreateArmyGroupAsPlatoon('Ariel', 'M3_NW_Patrol', 'NoFormation')
    ScenarioFramework.PlatoonPatrolChain(plat, 'Ariel_M3_NW_Patrol_Chain')

    ScenarioInfo.ArielPlatoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Ariel', 'Ariel_Group', 'NoFormation')
    ScenarioInfo.ArielUnit = ScenarioInfo.ArielPlatoon:GetPlatoonUnits()[1]
    ScenarioFramework.PauseUnitDeath(ScenarioInfo.ArielUnit)
    ScenarioInfo.ArielUnit:SetCustomName(LOC '{i CDR_Ariel}')
    ScenarioInfo.ArielUnit:CreateEnhancement('Shield')
    ScenarioInfo.ArielUnit:CreateEnhancement('CrysalisBeam')

    ScenarioInfo.ArielPlatoon.PlatoonData.AssistFactories = true
    ScenarioInfo.ArielPlatoon.PlatoonData.LocationType = 'MainBase'
    ScenarioInfo.ArielPlatoon.PlatoonData.MaintainBaseTemplate = 'Main_Base'
    ScenarioInfo.ArielPlatoon:ForkAIThread(ScenarioPlatoonAI.StartBaseEngineerThread)

    ScenarioInfo.ArielPlatoon.CDRData = {}
    ScenarioInfo.ArielPlatoon.CDRData.LeashPosition = 'Ariel_Leash_Marker'
    ScenarioInfo.ArielPlatoon.CDRData.LeashRadius = 50
    ScenarioInfo.ArielPlatoon:ForkThread(Behaviors.CDROverchargeBehavior)

    local plat = ScenarioUtils.CreateArmyGroupAsPlatoon('Ariel', 'M3_Main_Base_Engineers_D'..DiffLevel, 'NoFormation')
    plat.PlatoonData.AssistFactories = true
    plat.PlatoonData.MaintainBaseTemplate = 'Main_Base'
    plat.PlatoonData.LocationType = 'MainBase'
    plat:ForkAIThread(ScenarioPlatoonAI.StartBaseEngineerThread)

    -- Colossus Spawn in and stuff
    ScenarioInfo.ColTransports = ScenarioUtils.CreateArmyGroupAsPlatoon('Ariel', 'Colossus_Transports_D'..DiffLevel, 'NoFormation')
    ScenarioInfo.ColLand = ScenarioUtils.CreateArmyGroupAsPlatoon('Ariel', 'Colossus_Land_Units_D'..DiffLevel, 'AttackFormation')
    ScenarioInfo.ColHover = ScenarioUtils.CreateArmyGroupAsPlatoon('Ariel', 'Colossus_Hover_Units_D'..DiffLevel, 'AttackFormation')
    ScenarioInfo.ColAir = ScenarioUtils.CreateArmyGroupAsPlatoon('Ariel', 'Colossus_Air_Units_D'..DiffLevel, 'NoFormation')
    ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.ColAir, 'Ariel_M3_Col_Air_Patrol')
    ScenarioInfo.ColossusPlat = ScenarioUtils.CreateArmyGroupAsPlatoon('Ariel', 'Colossus', 'AttackFormation')
    for k, unit in ScenarioInfo.ColossusPlat:GetPlatoonUnits() do
        ScenarioInfo.Colossus = unit
    end
    ScenarioFramework.PauseUnitDeath(ScenarioInfo.Colossus)
    ScenarioFramework.AttachUnitsToTransports(ScenarioInfo.ColLand:GetPlatoonUnits(), ScenarioInfo.ColTransports:GetPlatoonUnits())

    ScenarioFramework.CreateTimerTrigger(M3ObjectiveReminder, ObjectiveReminderTimer)

    M3RevealPrimaryTwo()
    ScenarioInfo.M3P1Obj = Objectives.KillOrCapture('secondary', 'incomplete', OpStrings.M3P1Title, OpStrings.M3P1Description,
        {
            Units = ScenarioInfo.ColossusPlat:GetPlatoonUnits(),
        }
   )
    ScenarioInfo.M3P1Obj:AddResultCallback(M3ColossusDefeated)

    -- Create wrecked colony (storing all wreckage in UEF army)
    ScenarioUtils.CreateArmyGroup('UEF' ,'Wreck_M3', true)
end

function M3ArielAIThread(platoon)
    platoon.PlatoonData.LocationType = 'MainBase'
    platoon:PatrolLocationFactoriesAI()
end

function M3P1ObjectiveDialogue()
    ScenarioFramework.Dialogue(OpStrings.A05_M03_020, M3RevealPrimaryOne)
end

function M3RevealPrimaryOne()
    -- Start moving the Colossus attack at player
    for num, loc in ScenarioUtils.ChainToPositions('Ariel_M3_Colossus_Chain') do
        if num >= 3 then
            ScenarioInfo.ColHover:AggressiveMoveToLocation(loc)
        end
    end
    if DiffLevel == 1 then
        WaitSeconds(M3ColWaitD1)
    elseif DiffLevel == 2 then
        WaitSeconds(M3ColWaitD2)
    elseif DiffLevel == 3 then
        WaitSeconds(M3ColWaitD3)
    end
    if ArmyBrains[AeonAriel]:PlatoonExists(ScenarioInfo.ColAir) then
        ScenarioInfo.ColAir:Stop()
        ScenarioFramework.PlatoonAttackChain(ScenarioInfo.ColAir, 'Ariel_M3_Colossus_Chain')
    end
    if ArmyBrains[AeonAriel]:PlatoonExists(ScenarioInfo.ColossusPlat) then
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

function M3ColossusDefeated(result)
    if result then
-- Colossus defeated camera
        local camInfo = {
            blendTime = 1.0,
            holdTime = 8,
            orientationOffset = { math.pi, 0.15, 0 },
            positionOffset = { 0, 3, 0 },
            zoomVal = 45,
        }
        ScenarioFramework.OperationNISCamera(ScenarioInfo.Colossus, camInfo)

        ScenarioFramework.Dialogue(OpStrings.A05_M03_040)
    end
end

function M3RevealPrimaryTwo()
    if not ScenarioInfo.M3PrimaryTwoRevealed then
        ScenarioInfo.M3PrimaryTwoRevealed = true
        ScenarioInfo.M3P2Obj = Objectives.KillOrCapture('primary', 'incomplete', OpStrings.M3P2Title, OpStrings.M3P2Description,
            {
                Units = { ScenarioInfo.ArielUnit },
            }
       )
        ScenarioInfo.M3P2Obj:AddResultCallback(M3ArielDefeated)
    end
end

function M3ArielDefeated(result, unit)
    if result then
        ScenarioFramework.EndOperationSafety()
-- Ariel killed and end of op
--    ScenarioFramework.EndOperationCamera(unit)
        ScenarioFramework.CDRDeathNISCamera(unit)

        ScenarioFramework.Dialogue(OpStrings.A05_M03_050, false, true)
        ScenarioFramework.Dialogue(OpStrings.A05_M03_070, WinGame, true)
    end
end

function M3ArielTaunt1()
    ScenarioFramework.Dialogue(OpStrings.A05_M03_030)
end

function M3ObjectiveReminder()
    if ScenarioInfo.MissionNumber == 3 then
        ScenarioFramework.CreateTimerTrigger(M3ObjectiveReminder, ObjectiveReminderTimer)
        if Random(1,2) == 1 then
            ScenarioFramework.Dialogue(OpStrings.A05_M03_060)
        else
            ScenarioFramework.Dialogue(OpStrings.A05_M03_065)
        end
    end
end

function PlayerCDRDestroyed(unit)
    ScenarioFramework.PlayerDeath(unit, OpStrings.A05_D01_010)
end

function WinGame()
    ScenarioInfo.OpComplete = true
    WaitSeconds(5)
    local secondaries = Objectives.IsComplete(ScenarioInfo.M1P1Obj) and Objectives.IsComplete(ScenarioInfo.M1P2Obj) and Objectives.IsComplete(ScenarioInfo.M2S2Obj)
    local bonus = Objectives.IsComplete(ScenarioInfo.BonusArtillery) and Objectives.IsComplete(ScenarioInfo.BonusAir)
    ScenarioFramework.EndOperation(ScenarioInfo.OpComplete, ScenarioInfo.OpComplete, secondaries)
end
