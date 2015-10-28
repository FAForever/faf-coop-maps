-- ****************************************************************************
-- **
-- **  File     :  /maps/SCCA_Coop_A04/SCCA_Coop_A04_script.lua
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
local SimObjectives = import('/lua/SimObjectives.lua')
local OpStrings = import('/maps/SCCA_Coop_A04/SCCA_Coop_A04_Strings.lua')
local ScenarioStrings = import('/lua/scenariostrings.lua')
local VizMarker = import('/lua/sim/VizMarker.lua').VizMarker

-- === GLOBAL VARIABLES === #
ScenarioInfo.Player = 1
ScenarioInfo.Cybran = 2
ScenarioInfo.Civilian = 3
ScenarioInfo.Nodes = 4
ScenarioInfo.NexusDefense = 5
ScenarioInfo.Coop1 = 6
ScenarioInfo.Coop2 = 7
ScenarioInfo.Coop3 = 8
ScenarioInfo.HumanPlayers = {}
-- === LOCAL VARIABLES === #
local Player = ScenarioInfo.Player
local Coop1 = ScenarioInfo.Coop1
local Coop2 = ScenarioInfo.Coop2
local Coop3 = ScenarioInfo.Coop3
local Cybran = ScenarioInfo.Cybran
local Civilian = ScenarioInfo.Civilian
local Nodes = ScenarioInfo.Nodes
local NexusDefense = ScenarioInfo.NexusDefense

local DiffLevel = ScenarioInfo.Options.Difficulty

-- === TUNING VARIABLES === #

local ObjectiveReminderTimer = 300
local TauntTimer = 1800


-- ! MISSION ONE VARIABLES

-- Timer to reveal Nexus
local M1RevealNexusTimer = 120

-- Timer to reveal Naval base
local M1RevealNavalTimer = 240

-- Timer before building first offensive units
local M1EnableBombersTimer = 1200

-- Timer to taunt player the first time
local M1GaugeTaunt1Timer = 1400

-- Timer to give the player shield thing
local M1ShieldRevealTimer = 600

-- Timer to taunt player the second time
local M1GaugeTaunt2Timer = 1700

-- Timer to unlock all initial attacks
local M1EnableAttacks = 1200

-- Timer to unlock land assault if not already unlocked
local M1EnableLandAssaultTimer = 1680

-- Timer to allow engs to build artillery at Nexus Base
local M1EnableArtilleryTimer = 1800

-- Timer to allow naval fleet to attack
local M1EnableNavalFleetTimer = 1900


-- ! MISSION TWO VARIABLES

-- Timer to taunt player in M2
local M2GaugeTaunt1Timer = 120

-- Timer to taunt player in M2
local M2GaugeTaunt2Timer = 300

-- Timer to taunt player in M2
local M2GaugeTaunt3Timer = 420

-- Timer to taunt player in M2
local M2GaugeTaunt4Timer = 660

-- Timer for each quarter of the download
local M2MainframeTimer = 225
local M2FullTimer = 900

-- Timer for revealing node attacks
local M2RevealNodeAttacksTimer = 180

-- Timer for revealing nodes are mass
local M2RevealNodePurposeTimer = 300

-- Timer for each scripted attack in M2 after capture
local M2AttackOneTimer = 120
local M2AttackTwoTimer = 280
local M2AttackThreeTimer = 360
local M2AttackFourTimer = 415
local M2AttackFiveTimer = 480
local M2AttackSixTimer = 525
local M2DestroyerTimer = 380
local M2AttackSevenTimer = 600
local M2AttackEightTimer = 700

local LeaderFaction
local LocalFaction

function OnPopulate(scenario)
    ScenarioUtils.InitializeScenarioArmies()
    LeaderFaction, LocalFaction = ScenarioFramework.GetLeaderAndLocalFactions()

    ScenarioFramework.SetAeonColor(Player)
    ScenarioFramework.SetCybranColor(Cybran)
    ScenarioFramework.SetCybranAllyColor(Civilian)
    ScenarioFramework.SetCybranAllyColor(Nodes)
    ScenarioFramework.SetCybranNeutralColor(NexusDefense)
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

    local plat

    -- === Lock off tech === #
    -- Aeon locking
    for _, player in ScenarioInfo.HumanPlayers do
         ScenarioFramework.AddRestriction(player, categories.TECH3 +
                                      categories.EXPERIMENTAL +
                                      categories.PRODUCTFA + -- All FA Units
                                      categories.ual0307 +
                                      categories.uab4202 + categories.urb4202 +
                                      categories.uab4203 + categories.urb4203 +
                                      categories.uab2303 + categories.urb2303 )
    end
    -- Cybran Locking
    ScenarioFramework.AddRestriction(Cybran, categories.ura0203 +
                                 categories.ura0304 +
                                 categories.TECH3 +
                                 categories.urb4201 +
                                 categories.urb4203)

    ScenarioFramework.RestrictEnhancements({ 'Teleporter', 'T3Engineering', 'ShieldHeavy', })


    -- === Player stuff === #

  -- ! No starting base for now
  -- ScenarioUtils.CreateArmyGroup('Player', 'Base')
  -- ScenarioUtils.CreateArmyGroup('Player', 'Land_Units')
  -- local plat = ScenarioUtils.CreateArmyGroupAsPlatoon('Player', 'Gunships', 'ChevronFormation')
  -- ScenarioFramework.PlatoonPatrolChain(plat, 'Player_Patrol_Chain')
  -- plat = ScenarioUtils.CreateArmyGroupAsPlatoon('Player', 'Interceptors', 'ChevronFormation')
  -- ScenarioFramework.PlatoonPatrolChain(plat, 'Player_Patrol_Chain')


    -- === Cybran Stuff === #
    -- Cybran Build Locations
    ArmyBrains[Cybran]:PBMRemoveBuildLocation(nil, 'MAIN')
    ArmyBrains[Cybran]:PBMAddBuildLocation(ScenarioUtils.MarkerToPosition('Cybran_M1_Naval_Base'), 100, 'CybranM1Naval')
    ArmyBrains[Cybran]:PBMAddBuildLocation(ScenarioUtils.MarkerToPosition('Cybran_M1_Node_Base'), 100, 'CybranM1Node')
    ArmyBrains[Cybran]:PBMAddBuildLocation(ScenarioUtils.MarkerToPosition('Cybran_M2_Mainframe_Base'), 100, 'CybranM2MainFrame')

    -- Cybran Build Templates
    AIBuildStructures.CreateBuildingTemplate(ArmyBrains[Cybran], 'Cybran', 'M1_Naval')
    AIBuildStructures.AppendBuildingTemplate(ArmyBrains[Cybran], 'Cybran', 'M1_Naval_Base_D'..DiffLevel, 'M1_Naval')
    AIBuildStructures.CreateBuildingTemplate(ArmyBrains[Cybran], 'Cybran', 'M1_Node')
    AIBuildStructures.AppendBuildingTemplate(ArmyBrains[Cybran], 'Cybran', 'M1_Node_Base_D'..DiffLevel, 'M1_Node')

    -- Cybran Starting Units
    ScenarioUtils.CreateArmyGroup('Cybran', 'M1_Naval_Base_D'..DiffLevel)
    ScenarioUtils.CreateArmyGroup('Cybran', 'M1_Artillery_Line')

    -- Give intel to the middle naval factory in SW.
    local navFact = ScenarioInfo.UnitNames[Cybran]['M1_Cybran_Naval_Factory']
    ScenarioFramework.CreateVisibleAreaLocation(2, navFact:GetPosition(), .5, ArmyBrains[Player])

    -- ScenarioUtils.CreateArmyGroup('Cybran', 'M1_Node_Walls')
    local nodeBaseUnits = ScenarioUtils.CreateArmyGroup('Cybran', 'M1_Node_Base_D'..DiffLevel)
    for num, unit in nodeBaseUnits do
        ScenarioFramework.CreateUnitDamagedTrigger(M1NodeBaseDamaged, unit, .01)
    end

    -- Naval base Engineers
    plat = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M1_Naval_Engineers_D'..DiffLevel, 'AttackFormation')
    plat.PlatoonData.MaintainBaseTemplate = 'M1_Naval'
    plat.PlatoonData.AssistFactories = true
    plat.PlatoonData.LocationType = 'CybranM1Naval'
    plat:ForkAIThread(ScenarioPlatoonAI.StartBaseEngineerThread)
    -- Node base engineers
    if DiffLevel > 1 then
        plat = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M1_Node_Engineers_D'..DiffLevel, 'AttackFormation')
        plat.PlatoonData.MaintainBaseTemplate = 'M1_Node'
        plat.PlatoonData.AssistFactories = true
        plat.PlatoonData.LocationType = 'CybranM1Node'
        plat:ForkAIThread(ScenarioPlatoonAI.StartBaseEngineerThread)
    end
    -- Tactical Missile Launchers
    for k,unit in ArmyBrains[Cybran]:GetListOfUnits(categories.urb2108, false) do
        plat = ArmyBrains[Cybran]:MakePlatoon('', '')
        ArmyBrains[Cybran]:AssignUnitsToPlatoon(plat, {unit}, 'Attack', 'NoFormation')
        plat:ForkAIThread(plat.TacticalAI)
    end


    -- === Civilian Stuff === #
    -- Build locaiton
    ArmyBrains[NexusDefense]:PBMRemoveBuildLocation(nil, 'MAIN')
    ArmyBrains[NexusDefense]:PBMAddBuildLocation(ScenarioUtils.MarkerToPosition('Nexus_Defense_Base'), 100, 'NexusBase')
    -- Build Template
    AIBuildStructures.CreateBuildingTemplate(ArmyBrains[NexusDefense], 'Nexus_Defense', 'Nexus_Base')
    AIBuildStructures.AppendBuildingTemplate(ArmyBrains[NexusDefense], 'Nexus_Defense', 'Nexus_Base_D'..DiffLevel, 'Nexus_Base')
    -- Town and base
    local units = ScenarioUtils.CreateArmyGroup('Civilian', 'Nexus_04')
    ForkThread(UnitsFlash, units)
    units = ScenarioUtils.CreateArmyGroup('Nexus_Defense', 'Nexus_Base_D'..DiffLevel)
    ForkThread(UnitsFlash, units)
    units = ScenarioUtils.CreateArmyGroup('Nexus_Defense', 'Nexus_Walls_D'..DiffLevel)
    ForkThread(UnitsFlash, units)
    -- Nexus04 base Engineers
    ScenarioInfo.CivilianEngineers = ScenarioUtils.CreateArmyGroupAsPlatoon('Nexus_Defense','M1_Nexus_Engineers_D'..DiffLevel,'AttackFormation')
    ScenarioInfo.CivilianEngineers.PlatoonData.MaintainBaseTemplate = 'Nexus_Base'
    ScenarioInfo.CivilianEngineers.PlatoonData.MaintainDiffLevel = 3
    ScenarioInfo.CivilianEngineers.PlatoonData.PatrolChain = 'Nexus_North_Patrol_Chain'
    ScenarioInfo.CivilianEngineers:ForkAIThread(ScenarioPlatoonAI.StartBaseEngineerThread)
    -- Tactical Missile Launchers
    for k,unit in ArmyBrains[NexusDefense]:GetListOfUnits(categories.urb2108, false) do
        plat = ArmyBrains[NexusDefense]:MakePlatoon('', '')
        ArmyBrains[NexusDefense]:AssignUnitsToPlatoon(plat, {unit}, 'Attack', 'NoFormation')
        plat:ForkAIThread(plat.TacticalAI)
    end


    -- === Node Stuff === #
    ScenarioInfo.SWNode = ScenarioUtils.CreateArmyUnit('Nodes', 'SW_Node_Unit')
    ScenarioInfo.SWNode:SetCanTakeDamage(false)
    ScenarioInfo.SWNode:SetCanBeKilled(false)
    ScenarioFramework.CreateVisibleAreaLocation(2, ScenarioInfo.SWNode:GetPosition(), .5, ArmyBrains[Player]) -- give intel on radar
    ScenarioInfo.NWNode = ScenarioUtils.CreateArmyUnit('Nodes', 'NW_Node_Unit')
    ScenarioInfo.NWNode:SetReclaimable(false)
    ScenarioInfo.SENode = ScenarioUtils.CreateArmyUnit('Nodes', 'SE_Node_Unit')
    ScenarioInfo.SENode:SetReclaimable(false)
    ScenarioInfo.Mainframe = ScenarioUtils.CreateArmyUnit('Nodes', 'Mainframe_Unit')


    ScenarioInfo.SWNode:SetReclaimable(false)
end

function BPlayerBuildBombers()
    ScenarioInfo.BombersObjective:ManualResult(true)
    ScenarioFramework.Dialogue(ScenarioStrings.BObjComp)
end

function OnStart(self)
    SetArmyUnitCap(1, 300)
    ScenarioFramework.SetPlayableArea('M1_Playable_Area', false)
    ScenarioFramework.StartOperationJessZoom('Start_Camera_Area', IntroNIS, 4)
end

function UnitsFlash(units)
    WaitSeconds(3)
    for k,v in units do
        FlashViz(v)
    end
end

function FlashViz(object)
    local pos = object:GetPosition()
    local spec = {
        X = pos[1],
        Z = pos[2],
        Radius = 2,
        LifeTime = 1.00,
        Omni = false,
        Vision = true,
        Radar = false,
        Army = 1,
    }
    local vizmarker = VizMarker(spec)
    object.Trash:Add(vizmarker)
    vizmarker:AttachBoneTo(-1,object,-1)
end

function PlayTaunt()
    local num = Random(1, 8)
    ScenarioFramework.Dialogue(OpStrings['TAUNT'..num])
end

function TauntLoop()
    PlayTaunt()
    ScenarioFramework.CreateTimerTrigger(TauntLoop, TauntTimer)
end

-- === INTRO NIS === #
function IntroNIS()
    ScenarioInfo.PlayerCDR = ScenarioUtils.CreateArmyUnit('Player', 'Player_CDR')
    ScenarioInfo.PlayerCDR:PlayCommanderWarpInEffect()
    ScenarioInfo.PlayerCDR:SetCustomName(ArmyBrains[Player].Nickname)

    -- spawn coop players too
    ScenarioInfo.CoopCDR = {}
    local tblArmy = ListArmies()
    coop = 1
    for iArmy, strArmy in pairs(tblArmy) do
        if iArmy >= ScenarioInfo.Coop1 then
            ScenarioInfo.CoopCDR[coop] = ScenarioUtils.CreateArmyUnit(strArmy, 'Player_CDR')
            ScenarioInfo.CoopCDR[coop]:PlayCommanderWarpInEffect()
            ScenarioInfo.CoopCDR[coop]:SetCustomName(ArmyBrains[iArmy].Nickname)
            coop = coop + 1
            WaitSeconds(0.5)
        end
    end

    ScenarioFramework.PauseUnitDeath(ScenarioInfo.PlayerCDR)

    for index, coopACU in ScenarioInfo.CoopCDR do
        ScenarioFramework.PauseUnitDeath(coopACU)
        ScenarioFramework.CreateUnitDeathTrigger(PlayerCDRDestroyed, coopACU)
    end
    ScenarioFramework.CreateUnitDestroyedTrigger(PlayerCDRDestroyed, ScenarioInfo.PlayerCDR)

    -- Delay opening of mission till after player is warped in
    ScenarioFramework.CreateTimerTrigger(StartMission1, 4.8)
end

-- === MISSION ONE FUNCTIONS === #
function StartMission1()
    -- Set stuff up
    ScenarioInfo.MissionNumber = 1
    ScenarioFramework.Dialogue(OpStrings.A04_M01_010, M1RevealNexusObjective)
    --SetArmyUnitCap('Player', 400)

    -- === Spawn units === #
    local blockadeDestroyers = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M1_Destroyer_Blockade_D'..DiffLevel,
                                'GrowthFormation')
    blockadeDestroyers:MoveToLocation(ScenarioUtils.MarkerToPosition('Cybran_M1_Destroyer_Blockade_Marker'), false)
    local blockadeCruisers = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M1_Cruiser_Blockade_D'..DiffLevel,
                                'GrowthFormation')
    marker = 1
    for k,v in blockadeCruisers:GetPlatoonUnits() do
        IssueMove({v}, ScenarioUtils.MarkerToPosition('Cybran_M1_Cruiser_Blockade_Marker_'..marker))
        marker = marker + 1
        marker = 1
        if marker > 3 then
        end
    end
    -- blockadeCruisers:MoveToLocation(ScenarioUtils.MarkerToPosition('Cybran_M1_Cruiser_Blockade_Marker'), false)

    -- === Misc Triggers === #
    -- Triggers to enable builders
    ScenarioFramework.CreateArmyIntelTrigger(M1PlayerSeesNexus, ArmyBrains[Player], 'LOSNow', false, true, categories.ALLUNITS, true, ArmyBrains[NexusDefense])
    ScenarioFramework.CreateArmyIntelTrigger(M1PlayerSeesNavalBase, ArmyBrains[Player], 'LOSNow', false, true, categories.NAVAL, true, ArmyBrains[Cybran])
    ScenarioFramework.CreateArmyIntelTrigger(M1PlayerSeesNode, ArmyBrains[Player], 'LOSNow', ScenarioInfo.SWNode, true, categories.ALLUNITS, true, ArmyBrains[Nodes])
    ScenarioFramework.CreateTimerTrigger(M1EnableBomberEscort, M1EnableBombersTimer)
    ScenarioFramework.CreateTimerTrigger(M1EnableLandAssault, M1EnableLandAssaultTimer)
    ScenarioFramework.CreateTimerTrigger(M1EnableArtilleryConstruction, M1EnableArtilleryTimer)
    ScenarioFramework.CreateTimerTrigger(M1PlayerSeesNexus, M1RevealNexusTimer)
    ScenarioFramework.CreateTimerTrigger(M1RevealNavalObjective, M1RevealNavalTimer)
    ScenarioFramework.CreateTimerTrigger(M1GaugeTaunt1, M1GaugeTaunt1Timer)
    ScenarioFramework.CreateTimerTrigger(M1GaugeTaunt2, M1GaugeTaunt2Timer)
    ScenarioFramework.CreateTimerTrigger(M1ShieldReveal, M1ShieldRevealTimer)
    ScenarioFramework.CreateTimerTrigger(M1EnableNavalFleet, M1EnableNavalFleetTimer)

    ScenarioFramework.CreatePlatoonDeathTrigger(M1EnableCruiserBlockade, blockadeDestroyers)
    ScenarioFramework.CreatePlatoonDeathTrigger(M1EnableDestroyerBlockade, blockadeDestroyers)


    ScenarioInfo.VarTable['M1CybranFleetEnable'] = false
    ScenarioInfo.VarTable['M1BomberEscortEnable'] = false
    ScenarioInfo.VarTable['M1LandAssaultEnable'] = false
    ScenarioInfo.VarTable['M1CruiserBlockadeEnable'] = false
    ScenarioInfo.VarTable['M1DestroyerBlockadeEnable'] = false
    ScenarioInfo.VarTable['M1BomberEscortNoTBombersEnable'] = false

    ScenarioFramework.CreateTimerTrigger(M1ObjectiveReminder, ObjectiveReminderTimer)
    ScenarioFramework.CreateTimerTrigger(TauntLoop, TauntTimer)
end

-- When player sees naval base ... reveal objective (if needed) and spit dialogue
function M1PlayerSeesNavalBase()
    M1RevealNavalObjective()
    ScenarioFramework.Dialogue(OpStrings.A04_M01_090)
end

-- M1 primary objectives.  Pacify town and capture node.
function M1RevealNexusObjective()
    -- Nexus Trigger
    ScenarioInfo.M1P1Obj = SimObjectives.CategoriesInArea('primary', 'incomplete', OpStrings.M1P1Title,
                                                          OpStrings.M1P1Description, 'kill',
                    {
                        ShowFaction = 'Cybran',
                        Requirements = {
                            { Area='Nexus04_Area', Category = categories.ALLUNITS - categories.WALL,
                              CompareOp = '==', Value = 0, ArmyIndex = NexusDefense },
                        },
                    }
               )
    ScenarioInfo.M1P1Obj:AddResultCallback(M1NexusPacified)
    -- Node Trigger
    ScenarioInfo.M1P2Obj= SimObjectives.Capture('primary', 'incomplete', OpStrings.M1P2Title,
                                   OpStrings.M1P2Description, { Units = { ScenarioInfo.SWNode } }
                              )
    ScenarioInfo.M1P2Obj:AddResultCallback(M1SWNodeCaptured)
end

-- If not set, give naval objective dialogue and reveal objective
function M1RevealNavalObjective()
    if not ScenarioInfo.RevealNaval then
        ScenarioInfo.RevealNaval = true
        ScenarioFramework.Dialogue(OpStrings.A04_M01_030, M1NavalObjective)
    end
end

-- Naval objective to destroy base in an area
function M1NavalObjective()
    ScenarioInfo.M1S1Obj = SimObjectives.CategoriesInArea('secondary', 'incomplete', OpStrings.M1S1Title,
                                                          OpStrings.M1S1Description, 'kill',
                    {
                        ShowFaction = 'Cybran',
                        Requirements = {
                            { Area='M1_Naval_Area', Category = categories.ALLUNITS - categories.WALL,
                              CompareOp = '==', Value = 0, ArmyIndex = Cybran },
                        },
                    }
               )
    ScenarioInfo.M1S1Obj:AddResultCallback(M1NavalBaseDestroyed)
end

-- Naval base is destroyed.  Spit dialogue
function M1NavalBaseDestroyed()
    -- LOG('*DEBUG: Naval base destroyed')
    ScenarioFramework.Dialogue(OpStrings.A04_M01_040)

-- Naval base destroyed camera
    local camInfo = {
        blendTime = 1.0,
        holdTime = 4,
        orientationOffset = { 2.8, 0.2, 0 },
        positionOffset = { -10, 5, 80 },
        zoomVal = 45,
        markerCam = true,
    }
    ScenarioFramework.OperationNISCamera(ScenarioUtils.MarkerToPosition("Cybran_M1_Naval_Base"), camInfo)
end

-- Player sees the town for the first time, spit dialogue
function M1PlayerSeesNexus()
    if not ScenarioInfo.RevealNexus then
        -- LOG('*DEBUG: Reveal nexus dialogue')
        ScenarioFramework.Dialogue(OpStrings.A04_M01_020)
        ScenarioInfo.RevealNexus = true
    end
end

-- When one of the buildings at the node base is damaged spit dialogue
function M1NodeBaseDamaged()
    if not ScenarioInfo.NodeBaseDamagedBool then
        ScenarioInfo.NodeBaseDamagedBool = true
        -- LOG('*DEBUG: NODE BASE ATTACKED')
        ScenarioFramework.Dialogue(OpStrings.A04_M01_120)
    end
end

-- When player sees the node spit dialogue.
function M1PlayerSeesNode()
    -- LOG('*DEBUG: NODE SEEN BY PLAYER')
    ScenarioFramework.Dialogue(OpStrings.A04_M01_100)
end

-- First taunt from enemy commander
function M1GaugeTaunt1()
    if ScenarioInfo.MissionNumber == 1 then
        -- LOG('*DEBUG: GAUGE TAUNT 1')
        ScenarioFramework.Dialogue(OpStrings.A04_M01_060)
    end
end

-- Second taunt from enemy commander
function M1GaugeTaunt2()
    if ScenarioInfo.MissionNumber == 1 then
        -- LOG('*DEBUG: GAUGE TAUNT 2')
        ScenarioFramework.Dialogue(OpStrings.A04_M01_080)
    end
end

-- Unlock shields and tell the player about them
function M1ShieldReveal()
    ScenarioFramework.Dialogue(OpStrings.A04_M01_070)
    ScenarioFramework.RemoveRestrictionForAllHumans(categories.uab4202 + categories.urb4202 + categories.ual0307)
end

-- Allow naval attacks to commence
function M1EnableNavalFleet()
    ScenarioInfo.M1NavalBaseAttacked = true
    ScenarioInfo.VarTable['M1NavalFleetEnable'] = true
    ScenarioInfo.VarTable['M1BomberEscortNoTBombersEnable'] = true
end

-- Allow air attacks
function M1EnableBomberEscort()
    ScenarioInfo.VarTable['M1BomberEscortEnable'] = true
end

-- Allow land attacks
function M1EnableLandAssault()
    ScenarioInfo.VarTable['M1LandAssaultEnable'] = true
end

-- When initial cruisers are destroyed allow reinforcements
function M1EnableCruiserBlockade()
    ScenarioInfo.VarTable['M1CruiserBlockadeEnable'] = true
end

-- When initial destroyers are destroyed allow reinforcements
function M1EnableDestroyerBlockade()
    ScenarioInfo.VarTable['M1DestroyerBlockadeEnable'] = true
end

-- Enable gunships to attack player
function M1EnableBomberEscortT2()
    ScenarioFramework.RemoveRestriction(Cybran, categories.ura0203)
end

-- Enable artillery to be constructed at Nexus
function M1EnableArtilleryConstruction()
    if ArmyBrains[Civilian]:PlatoonExists(ScenarioInfo.CivilianEngineers) then
        AIBuildStructures.AppendBuildingTemplate(ArmyBrains[NexusDefense], 'Nexus_Defense', 'Nexus_Artillery_D'..DiffLevel, 'Nexus_Base')
        ScenarioInfo.CivilianEngineers.PlatoonData.MaintainBaseTemplate = 'Nexus_Base'
        ScenarioInfo.CivilianEngineers.PlatoonData.BuildBaseTemplate = 'Nexus_Artillery_D'..DiffLevel
        ScenarioInfo.CivilianEngineers.PlatoonData.MaintainDiffLevel = 3
        ScenarioInfo.CivilianEngineers.PlatoonData.PatrolChain = 'Nexus_North_Patrol_Chain'
        ScenarioInfo.CivilianEngineers:StopAI()
        ScenarioInfo.CivilianEngineers:ForkAIThread(ScenarioPlatoonAI.StartBaseEngineerThread)
    end
end

-- Nexus beat up.  Spit dialogue and check objectives
function M1NexusPacified(result)
    if result then
        M1EnableBomberEscortT2()
        ScenarioInfo.M1NexusDefeated = true
        ScenarioFramework.Dialogue(OpStrings.A04_M01_110)
        M1CheckPrimaryObjectives()

        -- Civilian base "pacified" camera
        local camInfo = {
            blendTime = 1.0,
            holdTime = 4,
            orientationOffset = { -2.7, 0.15, 0 },
            positionOffset = { 0, 3, 10 },
            zoomVal = 75,
            markerCam = true,
        }
        ScenarioFramework.OperationNISCamera(ScenarioUtils.MarkerToPosition("M1_Town_Marker"), camInfo)
    else
        ScenarioFramework.FlushDialogueQueue()
        ScenarioFramework.EndOperationSafety()
        ForkThread(ScenarioFramework.PlayerLose)
    end
end

-- M1 Node captured. Spit dialogue adn check objectives
function M1SWNodeCaptured(result, returnedUnits)
    if result then
        ScenarioInfo.SWNode = returnedUnits[1]
        ScenarioInfo.M1NodeCapture = true

        ScenarioInfo.SWNode:SetCanTakeDamage(false)
        ScenarioInfo.SWNode:SetCanBeKilled(false)

        -- First Node captured camera
        local camInfo = {
            blendTime = 1.0,
            holdTime = 4,
            orientationOffset = { 2.9, 0.3, 0 },
            positionOffset = { 0, 1, 0 },
            zoomVal = 30,
        }
        ScenarioFramework.OperationNISCamera(ScenarioInfo.SWNode, camInfo)

        M1CheckPrimaryObjectives()

        -- M1 Node - Triggers for M2
        ScenarioFramework.CreateUnitCapturedTrigger(nil, M2SWNodeCaptured, ScenarioInfo.SWNode)
        ScenarioFramework.CreateUnitDeathTrigger(M2NodeDestroyed, ScenarioInfo.SWNode)
        ScenarioFramework.CreateUnitReclaimedTrigger(M2NodeDestroyed, ScenarioInfo.SWNode)
        ScenarioInfo.SWNode:SetReclaimable(false)
    else
        ScenarioFramework.FlushDialogueQueue()
        ScenarioFramework.EndOperationSafety()
        ForkThread(ScenarioFramework.PlayerLose)
    end
end

-- Check M1 Objectives
function M1CheckPrimaryObjectives()
    if ScenarioInfo.M1NodeCapture and ScenarioInfo.M1NexusDefeated then
        ScenarioFramework.Dialogue(OpStrings.A04_M01_150, StartMission2)
    end
end

function M1ObjectiveReminder()
    if ScenarioInfo.MissionNumber == 1 then
        ScenarioFramework.CreateTimerTrigger(M1ObjectiveReminder, ObjectiveReminderTimer)
        if not ScenarioInfo.M1NexusDefeated then
            if Random(1,2) == 1 then
                ScenarioFramework.Dialogue(OpStrings.A04_M01_130)
            else
                ScenarioFramework.Dialogue(OpStrings.A04_M01_135)
            end
        else
            if Random(1,2) == 1 then
                ScenarioFramework.Dialogue(OpStrings.A04_M01_140)
            else
                ScenarioFramework.Dialogue(OpStrings.A04_M01_145)
            end
        end
    end
end

-- === MISSION TWO FUNCTIONS === #
function StartMission2()
    SetArmyUnitCap(1, 500)
    ScenarioInfo.MissionNumber = 2
    ScenarioFramework.SetPlayableArea('M2_Playable_Area')
    ScenarioFramework.Dialogue(OpStrings.A04_M02_010, M2RevealCaptureMainframe)

    ScenarioInfo.SWNode:SetCanTakeDamage(true)
    ScenarioInfo.SWNode:SetCanBeKilled(true)

    -- === Buildable Categories === #
    -- Player
    ScenarioFramework.RemoveRestrictionForAllHumans(
        categories.uab0302 +  -- Aeon T3 Air Factory
        categories.zab9602 +  -- Aeon T3 Support Air Factory
        categories.uab2303 +  -- Aeon T2 Artillery Installation
        categories.uaa0304 +  -- Aeon T3 Strategic Bomber
        categories.uab4202 +  -- Aeon T2 Shield Generator
        categories.urb0302 +  -- Cybran T3 Air Factory
        categories.zrb9602 +  -- Cybran Support T3 Air Factory
        categories.urb2303 +  -- Cybran T2 Artillery Installation
        categories.ura0304 +  -- Cybran T3 Strategic Bomber
        categories.urb4202    -- Cybran T2 Shield Generator
    )

    -- Cybran
    -- ScenarioFramework.RemoveRestriction(Cybran, categories.ura0304)

    -- === M2 Misc Triggers === #
    ScenarioFramework.CreateTimerTrigger(PlayTaunt, M2GaugeTaunt1Timer)
    ScenarioFramework.CreateTimerTrigger(PlayTaunt, M2GaugeTaunt2Timer)
    ScenarioFramework.CreateTimerTrigger(PlayTaunt, M2GaugeTaunt3Timer)
    ScenarioFramework.CreateTimerTrigger(PlayTaunt, M2GaugeTaunt4Timer)

    -- === M2 Objective Triggers === #
    -- NW Node
    ScenarioFramework.CreateUnitDeathTrigger(M2NodeDestroyed, ScenarioInfo.NWNode)
    ScenarioFramework.CreateUnitReclaimedTrigger(M2NodeDestroyed, ScenarioInfo.NWNode)
    ScenarioFramework.CreateUnitCapturedTrigger(nil, M2NWNodeCaptured, ScenarioInfo.NWNode)
    -- SE Node
    ScenarioFramework.CreateUnitDeathTrigger(M2NodeDestroyed, ScenarioInfo.SENode)
    ScenarioFramework.CreateUnitReclaimedTrigger(M2NodeDestroyed, ScenarioInfo.SENode)
    ScenarioFramework.CreateUnitCapturedTrigger(nil, M2SENodeCaptured, ScenarioInfo.SENode)

    -- === CREATE UNITS === #
    -- Cybran
    ArmyBrains[Cybran]:PBMAddBuildLocation('Cybran_Mainframe_Base', 60, 'CybranMainframeBase')
    ScenarioUtils.CreateArmyGroup('Cybran', 'M2_Mainframe_Factory_Base')
    ScenarioUtils.CreateArmyGroup('Cybran', 'M2_Defenses_D'..DiffLevel)
    ScenarioUtils.CreateArmyGroup('Cybran', 'M2_Resources_D'..DiffLevel)
    local plat
    plat = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2_Mainframe_Engineers_D'..DiffLevel, 'NoFormation')
    plat.PlatoonData.AssistFactories = true
    plat.PlatoonData.LocationType = 'CybranMainframeBase'
    plat:ForkAIThread(ScenarioPlatoonAI.StartBaseEngineerThread)

    -- Defensive units
    plat = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2_Mainframe_SW_Units_D'..DiffLevel, 'AttackFormation')
    plat.PlatoonData.OrderName = 'Cybran_M2_Mainframe_SW_Group'
    plat:ForkAIThread(ScenarioPlatoonAI.PlatoonAssignOrders)

    plat = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2_Mainframe_SE_Units_D'..DiffLevel, 'AttackFormation')
    plat.PlatoonData.OrderName = 'Cybran_M2_Mainframe_SE_Group'
    plat:ForkAIThread(ScenarioPlatoonAI.PlatoonAssignOrders)

    plat = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2_Mainframe_MidWest_Units_D'..DiffLevel, 'AttackFormation')
    plat.PlatoonData.OrderName = 'Cybran_M2_Mainframe_MidWest_Group'
    plat:ForkAIThread(ScenarioPlatoonAI.PlatoonAssignOrders)

    plat = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2_Mainframe_MidEast_Units_D'..DiffLevel, 'AttackFormation')
    plat.PlatoonData.OrderName = 'Cybran_M2_Mainframe_MidEast_Group'
    plat:ForkAIThread(ScenarioPlatoonAI.PlatoonAssignOrders)

    plat = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2_Mainframe_NW_Units_D'..DiffLevel, 'AttackFormation')
    plat.PlatoonData.OrderName = 'Cybran_M2_Mainframe_NW_Group'
    plat:ForkAIThread(ScenarioPlatoonAI.PlatoonAssignOrders)

    plat = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2_Mainframe_NE_Units_D'..DiffLevel, 'AttackFormation')
    plat.PlatoonData.OrderName = 'Cybran_M2_Mainframe_NE_Group'
    plat:ForkAIThread(ScenarioPlatoonAI.PlatoonAssignOrders)

    plat = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2_South_Air_Patrol_1_D'..DiffLevel, 'ChevronFormation')
    ScenarioFramework.PlatoonPatrolChain(plat, 'Cybran_M2_South_Patrol_Chain')
    plat = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2_North_Air_Patrol_1_D'..DiffLevel, 'ChevronFormation')
    ScenarioFramework.PlatoonPatrolChain(plat, 'Cybran_M2_North_Patrol_Chain')

    for k,unit in ArmyBrains[Cybran]:GetListOfUnits(categories.urb2108, false) do
        plat = ArmyBrains[Cybran]:MakePlatoon('', '')
        ArmyBrains[Cybran]:AssignUnitsToPlatoon(plat, {unit}, 'Attack', 'NoFormation')
        plat:ForkAIThread(plat.TacticalAI)
    end

    -- Node Defenses
    ScenarioInfo.MainframeDefenses = ScenarioUtils.CreateArmyGroup('Nodes', 'Mainframe_Defenses')
    ScenarioInfo.NWDefenses = ScenarioUtils.CreateArmyGroup('Nodes', 'NW_Defenses')
    ScenarioInfo.SEDefenses = ScenarioUtils.CreateArmyGroup('Nodes', 'SE_Defenses')
    ScenarioUtils.CreateArmyGroup('Nodes', 'Mainframe_Walls')

    ScenarioFramework.CreateTimerTrigger(M2ObjectiveReminder, ObjectiveReminderTimer)

    ScenarioFramework.CreateUnitDeathTrigger(M2MainframeDestroyed, ScenarioInfo.Mainframe)
    ScenarioFramework.CreateUnitReclaimedTrigger(M2MainframeDestroyed, ScenarioInfo.Mainframe)
    ScenarioFramework.CreateUnitCapturedTrigger(nil, M2MainframeCaptured, ScenarioInfo.Mainframe)
end

-- Reveal that player must capture mainframe
function M2RevealCaptureMainframe()
    ScenarioInfo.M2P1Obj = SimObjectives.Basic('primary', 'incomplete', OpStrings.M2P1Title, OpStrings.M2P1Description, SimObjectives.GetActionIcon('capture'), { Units = { ScenarioInfo.Mainframe, } })
end

-- Player loses because mainframe is destroyed
function M2MainframeDestroyed(unit)
    ScenarioInfo.MainframeDestroyed = true
    ScenarioFramework.FlushDialogueQueue()
    ScenarioFramework.EndOperationSafety()
    ScenarioFramework.Dialogue(OpStrings.TAUNT2, ScenarioFramework.PlayerLose, true)
    -- Mainframe destroyed
    -- ScenarioFramework.EndOperationCamera(unit)
    local camInfo = {
        blendTime = 2.5,
        holdTime = nil,
        orientationOffset = { math.pi, 0.8, 0 },
        positionOffset = { 0, 4, 0 },
        zoomVal = 45,
        spinSpeed = 0.03,
        overrideCam = true,
    }
    ScenarioFramework.OperationNISCamera(unit, camInfo)

end

-- Mainframe captures. Update unit, retrigger unit, spit dialogue if first time, begin scripted attacks
function M2MainframeCaptured(unit, captor)
    ScenarioInfo.Mainframe = unit
    ScenarioInfo.MainframeCaptured = true
    SetArmyUnitCap('Player', 500)
    ScenarioFramework.CreateUnitDeathTrigger(M2MainframeDestroyed, ScenarioInfo.Mainframe)
    ScenarioFramework.CreateUnitReclaimedTrigger(M2MainframeDestroyed, ScenarioInfo.Mainframe)
    ScenarioFramework.CreateUnitCapturedTrigger(nil, M2MainframeCaptured, ScenarioInfo.Mainframe)
    if not ScenarioInfo.PlayerCapturedMainframe then
        for num, unit in ScenarioInfo.MainframeDefenses do
            if not unit:IsDead() then
                ScenarioFramework.GiveUnitToArmy(unit, Player)
            end
        end
        -- ScenarioInfo.M2P1Obj:ManualResult(true)
        ScenarioInfo.PlayerCapturedMainframe = true
        ScenarioFramework.Dialogue(OpStrings.A04_M02_020, M2RevealCaptureNodes)
        ScenarioInfo.MainframeCountdownCounter = 0
        ScenarioFramework.CreateTimerTrigger(M2MainframeCountdown, M2MainframeTimer)
        ScenarioFramework.CreateTimerTrigger(M2CountdownComplete, M2FullTimer, true)
        SetAlliance(Nodes, Cybran, 'Enemy')
        M2BeginMainframeAttacks()

        -- Mainframe captured camera
        local camInfo = {
            blendTime = 1.0,
            holdTime = 4,
            orientationOffset = { -2.78, 0.8, 0 },
            positionOffset = { 0, 4, 0 },
            zoomVal = 45,
        }
        ScenarioFramework.OperationNISCamera(ScenarioInfo.Mainframe, camInfo)
    end
end

function M2CountdownComplete()
    if not ScenarioInfo.MainframeDestroyed then
        ScenarioFramework.EndOperationSafety()
        ScenarioFramework.Dialogue(OpStrings.A04_M02_160, M2WinOperation, true)
    end
end

-- Counter that plays dialogue depending on objective progress
function M2MainframeCountdown()
    ScenarioInfo.MainframeCountdownCounter = ScenarioInfo.MainframeCountdownCounter + 1
    if ScenarioInfo.MainframeCountdownCounter == 1 then
        ScenarioFramework.Dialogue(OpStrings.A04_M02_080)
        ScenarioFramework.CreateTimerTrigger(M2MainframeCountdown, M2MainframeTimer)
    elseif ScenarioInfo.MainframeCountdownCounter == 2 then
        ScenarioFramework.Dialogue(OpStrings.A04_M02_090)
        ScenarioFramework.CreateTimerTrigger(M2MainframeCountdown, M2MainframeTimer)
    elseif ScenarioInfo.MainframeCountdownCounter == 3 then
        ScenarioFramework.Dialogue(OpStrings.A04_M02_100)
        ScenarioFramework.CreateTimerTrigger(M2MainframeCountdown, M2MainframeTimer)
    elseif ScenarioInfo.MainframeCountdownCounter == 4 then
        -- ScenarioFramework.Dialogue(OpStrings.A04_M02_160, M2WinOperation)
    end
end

-- Begin M2 Attacks against player
function M2BeginMainframeAttacks()
    -- Build bases and crap
    ArmyBrains[Cybran]:PBMAddBuildLocation('Cybran_M2_East_Base', 120, 'CybranEastBase')
    ArmyBrains[Cybran]:PBMAddBuildLocation('Cybran_M2_NW_Base', 120, 'CybranNWBase')
    ArmyBrains[Cybran]:PBMAddBuildLocation('Cybran_M2_SW_Base', 120, 'CybranSWBase')
    -- Off map bases
    ScenarioUtils.CreateArmyGroup('Cybran', 'M2_East_Base')
    if DiffLevel > 1 then
        plat = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2_East_Engineers_D'..DiffLevel, 'NoFormation')
        plat.PlatoonData.AssistFactories = true
        plat.PlatoonData.LocationType = 'CybranEastBase'
        plat:ForkAIThread(ScenarioPlatoonAI.StartBaseEngineerThread)
    end
    ScenarioUtils.CreateArmyGroup('Cybran', 'M2_NW_Base')

    ScenarioUtils.CreateArmyGroup('Cybran', 'M2_SW_Base')
-- plat = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2_SW_Engineers_D'..DiffLevel, 'NoFormation')
-- plat.PlatoonData.AssistFactories = true
-- LocationType = 'CybranSWBase'
-- plat:ForkAIThread(ScenarioPlatoonAI.StartBaseEngineerThread)

    ScenarioFramework.CreateTimerTrigger(M2AttackOne, M2AttackOneTimer)
    ScenarioFramework.CreateTimerTrigger(M2AttackTwo, M2AttackTwoTimer)
    ScenarioFramework.CreateTimerTrigger(M2AttackThree, M2AttackThreeTimer)
    ScenarioFramework.CreateTimerTrigger(M2AttackFour, M2AttackFourTimer)
    ScenarioFramework.CreateTimerTrigger(M2AttackFive, M2AttackFiveTimer)
    ScenarioFramework.CreateTimerTrigger(M2AttackSix, M2AttackSixTimer)
    ScenarioFramework.CreateTimerTrigger(M2AttackSeven, M2AttackSevenTimer)
    ScenarioFramework.CreateTimerTrigger(M2AttackEight, M2AttackEightTimer)
    ScenarioFramework.CreateTimerTrigger(M2DestroyerAttack, M2DestroyerTimer)

-- #    ScenarioFramework.CreateTimerTrigger(M2AttackOne, 1)
-- ScenarioFramework.CreateTimerTrigger(M2AttackTwo, 1)
-- #    ScenarioFramework.CreateTimerTrigger(M2AttackThree, 1)
-- #    ScenarioFramework.CreateTimerTrigger(M2AttackFour, 1)
-- #    ScenarioFramework.CreateTimerTrigger(M2AttackFive, 1)
-- #    ScenarioFramework.CreateTimerTrigger(M2AttackSix, 1)
-- #    ScenarioFramework.CreateTimerTrigger(M2AttackSeven, 1)
-- #    ScenarioFramework.CreateTimerTrigger(M2AttackEight, 1)

end

-- First attack - air sent from east to mainframe
function M2AttackOne()
    ScenarioFramework.Dialogue(OpStrings.A04_M02_070)
    local plat = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2A1_Air_Attack_D'..DiffLevel, 'ChevronFormation')
    ScenarioFramework.PlatoonAttackChain(plat, 'Cybran_M2_East_To_Mainframe_Air_Chain')
end

-- Second attack - transports and air sent to mainframe
function M2AttackTwo()
    local transports = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2A2_Transports_D'..DiffLevel, 'ChevronFormation')
    local landUnits = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2A2_Land_Assault_D'..DiffLevel, 'AttackFormation')
    ScenarioFramework.AttachUnitsToTransports(landUnits:GetPlatoonUnits(), transports:GetPlatoonUnits())
    ForkThread(M2EastLandAssault, landUnits, transports)
    WaitSeconds(23)
    local airPlat = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2A2_Air_Attack_D'..DiffLevel, 'ChevronFormation')
    ScenarioFramework.PlatoonAttackChain(airPlat, 'Cybran_M2_East_To_Mainframe_Air_Chain')
end

-- Third attack - air sent from NW to mainframe over NW node; SW air sent to player initial base then mainframe
function M2AttackThree()
    local nwPlat = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2A3_NW_Air_Attack_D'..DiffLevel, 'ChevronFormation')
    ScenarioFramework.PlatoonAttackChain(nwPlat, 'Cybran_M2_West_NW_Mainframe_Chain')
    WaitSeconds(13)
    local playerPlat = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2A3_Player_Air_Attack_D'..DiffLevel, 'ChevronFormation')
    ScenarioFramework.PlatoonAttackChain(playerPlat, 'Cybran_M2_SouthWest_Player_Mainframe_Chain')
end

-- Fourth attack - Transports sent to attack mainframe; frigates and destroyers from east to SE node and player base
function M2AttackFour()
    -- Transports
    local transports = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2A4_Transports_D'..DiffLevel, 'NoFormation')
    local units = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2A4_Land_Units_D'..DiffLevel, 'NoFormation')
    ScenarioFramework.AttachUnitsToTransports(units:GetPlatoonUnits(), transports:GetPlatoonUnits())
    ForkThread(M2EastLandAssault, units, transports)

    -- Naval attacks
    WaitSeconds(19)
    local frigates = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2A4_Frigates_D'..DiffLevel, 'NoFormation')
    ScenarioFramework.PlatoonAttackChain(frigates, 'Cybran_M2_East_Naval_Chain')
    WaitSeconds(29)
    local destroyers = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2A4_Destroyers_D'..DiffLevel, 'NoFormation')
    ScenarioFramework.PlatoonAttackChain(destroyers, 'Cybran_M2_East_Destroyers_Player_Chain')
end

-- Fifth attack - Navy from NW to mainframe; SW air to player; NW air to mainframe
function M2AttackFive()
    -- Navy
    local navy = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2A5_NW_Naval_D'..DiffLevel, 'NoFormation')
    ScenarioFramework.PlatoonAttackChain(navy, 'Cybran_M2_NW_Naval_Chain')

    -- Player Air Attack
    WaitSeconds(29)
    local airPlat = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2A5_SW_Player_Air_D'..DiffLevel, 'ChevronFormation')
    ScenarioFramework.PlatoonAttackChain(airPlat, 'Cybran_M2_SouthWest_Player_Mainframe_Chain')

    -- Air Attack NW
    WaitSeconds(37)
    local areaUnits = GetUnitsInRect(ScenarioUtils.AreaToRect('West_Lake_Area'))
    local navyCounter = 0
    for num, unit in areaUnits do
        if unit:GetAIBrain() == ArmyBrains[Player] and EntityCategoryContains(categories.NAVAL, unit) then
            navyCounter = navyCounter + 1
        end
    end
    if navyCounter > 5 then
        local nwAirPlat = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2A5_NW_Air_Naval_D'..DiffLevel, 'ChevronFormation')
        ScenarioFramework.PlatoonAttackChain(nwAirPlat, 'Cybran_M2_West_NW_Mainframe_Naval_Chain')
    else
        local nwAirPlat = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2A5_NW_Air_No_Naval_D'..DiffLevel, 'ChevronFormation')
        ScenarioFramework.PlatoonAttackChain(nwAirPlat, 'Cybran_M2_West_NW_Mainframe_Chain')
    end
end

-- Sixth attack - NW air to mainframe; East air attack against player base
function M2AttackSix()
    local nwAirPlat = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2A6_NW_Air_Attack_D'..DiffLevel, 'ChevronFormation')
    ScenarioFramework.PlatoonAttackChain(nwAirPlat, 'Cybran_M2_West_NW_Mainframe_Naval_Chain')

    WaitSeconds(17)
    local eastAirPlat = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2A6_East_Player_Attack_D'..DiffLevel, 'ChevronFormation')
    ScenarioFramework.PlatoonAttackChain(eastAirPlat, 'Cybran_M2_East_Player_Chain')
end

-- Seventh attack - SW air to player; East air to mainframe; NW and East destroyers to mainframe
function M2AttackSeven()
    -- Air attacks
    local playerAirPlat = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2A7_Player_Air_D'..DiffLevel, 'ChevronFormation')
    ScenarioFramework.PlatoonAttackChain(playerAirPlat, 'Cybran_M2_SouthWest_Player_Mainframe_Chain')
    local eastAirPlat = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2A7_East_Mainframe_Air_D'..DiffLevel, 'ChevronFormation')
    ScenarioFramework.PlatoonAttackChain(eastAirPlat, 'Cybran_M2_East_To_Mainframe_Air_Chain')
end

function M2DestroyerAttack()
    -- Destroyers
    local eastDest = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2A7_Destroyers_East_D'..DiffLevel, 'AttackFormation')
    ScenarioFramework.PlatoonMoveChain(eastDest, 'Cybran_M2_East_Naval_Mainframe_Chain')
    WaitSeconds(60)
    local westDest = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2A7_Destroyers_NW_D'..DiffLevel, 'AttackFormation')
    ScenarioFramework.PlatoonMoveChain(westDest, 'Cybran_M2_NW_Naval_Chain')
end

-- Eigth attack - East air to mainframe; SW air to player
function M2AttackEight()
    local eastAirPlat = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2A8_East_Air_D'..DiffLevel, 'ChevronFormation')
    ScenarioFramework.PlatoonAttackChain(eastAirPlat, 'Cybran_M2_East_To_Mainframe_Air_Chain')
    local playerPlat = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2A8_Player_Air_D'..DiffLevel, 'ChevronFormation')
    ScenarioFramework.PlatoonAttackChain(playerPlat, 'Cybran_M2_SouthWest_Player_Mainframe_Chain')
end

-- generic function to attack mainframe from the east
function M2EastLandAssault(units, transports)
    local aiBrain = units:GetBrain()
    local cmd = transports:UnloadAllAtLocation(ScenarioPlatoonAI.PlatoonChooseRandomNonNegative(aiBrain, ScenarioUtils.ChainToPositions('Cybran_M2_Mainframe_Landing_Chain'), 2))
    while transports:IsCommandsActive(cmd) do
        WaitSeconds(2)
        if not aiBrain:PlatoonExists(transports) then
            return
        end
    end
    if aiBrain:PlatoonExists(transports) then
        transports:MoveToLocation(ScenarioUtils.MarkerToPosition('Cybran_East_Transport_Return'), false)
        aiBrain:AssignUnitsToPlatoon('TransportPool', transports:GetPlatoonUnits(), 'Scout', 'None')
    end
    if aiBrain:PlatoonExists(units) then
        units:AggressiveMoveToLocation(ScenarioUtils.MarkerToPosition('Mainframe_Marker'))
    end
end

-- Reveal objective to capture the nodes
function M2RevealCaptureNodes()
    ScenarioInfo.M2P2Obj = SimObjectives.Basic('primary', 'incomplete', OpStrings.M2P2Title,
        OpStrings.M2P2Description, SimObjectives.GetActionIcon('capture'),
        { Units = { ScenarioInfo.NWNode, ScenarioInfo.SENode }, MarkUnits = true, AlwaysVisible = true, }
   )
    ScenarioFramework.CreateTimerTrigger(M2RevealNodeAttacks, M2RevealNodeAttacksTimer)
    -- ScenarioFramework.CreateTimerTrigger(M2RevealNodePurpose, M2RevealNodePurposeTimer)
end

-- Reveal that attacks are coming against the nodes
function M2RevealNodeAttacks()
    ScenarioInfo.M2NodeAttacks = true
    ScenarioFramework.Dialogue(OpStrings.A04_M02_050)
end

-- Reveal that the nodes are mass
function M2RevealNodePurpose()
    ScenarioFramework.Dialogue(OpStrings.A04_M02_060)
end

-- When a node is destroyed play dialogue or end game if all destroyed
function M2NodeDestroyed(unit)
    -- Base node cam
    local camInfo = {
        blendTime = 1.0,
        holdTime = 4,
        orientationOffset = { math.pi, 0.3, 0 },
        positionOffset = { 0, 1, 0 },
        zoomVal = 30,
    }

    if ScenarioInfo.NWNode == unit then
        -- NW node destroyed cam
        ScenarioInfo.NWNodeHandled = true
        camInfo.orientationOffset[1] = 0.3927
    elseif ScenarioInfo.SENode == unit then
        -- SE node destroyed cam
        ScenarioInfo.SENodeHandled = true
        camInfo.orientationOffset[1] = -1.5708
    elseif ScenarioInfo.SWNode == unit then
        -- First Node destroyed cam
        camInfo.orientationOffset[1] = 2.9
    end

    if not ScenarioInfo.FirstNodeDestroyed then
        ScenarioInfo.FirstNodeDestroyed = true
        ScenarioFramework.Dialogue(OpStrings.A04_M02_110)
        ScenarioFramework.OperationNISCamera(unit, camInfo)
    elseif not ScenarioInfo.SecondNodeDestroyed then
        ScenarioInfo.SecondNodeDestroyed = true
        ScenarioFramework.Dialogue(OpStrings.A04_M02_120)
        ScenarioFramework.OperationNISCamera(unit, camInfo)
    else
        ScenarioFramework.FlushDialogueQueue()
        ScenarioFramework.EndOperationSafety()
        ScenarioFramework.Dialogue(OpStrings.A04_M02_150, ScenarioFramework.PlayerLose, true)
        -- All nodes destroyed
        --    ScenarioFramework.EndOperationCamera(unit)
        camInfo.blendTime = 2.5
        camInfo.holdTime = nil
        camInfo.spinSpeed = 0.03
        camInfo.overrideCam = true
        ScenarioFramework.OperationNISCamera(unit, camInfo)

    end
end

-- When player captures the NW node
function M2NWNodeCaptured(unit, captor)
    ScenarioInfo.NWNode = unit
    if not ScenarioInfo.NWNodeCapturedBool then
        ScenarioInfo.NWNodeCapturedBool = true
        ScenarioFramework.Dialogue(OpStrings.A04_M02_030)
        for num, unit in ScenarioInfo.NWDefenses do
            if not unit:IsDead() then
                ScenarioFramework.GiveUnitToArmy(unit, Player)
            end
        end
    end
    ScenarioInfo.NWNodeHandled = true
    ScenarioFramework.CreateUnitDeathTrigger(M2NodeDestroyed, ScenarioInfo.NWNode)
    ScenarioFramework.CreateUnitReclaimedTrigger(M2NodeDestroyed, ScenarioInfo.NWNode)
    ScenarioFramework.CreateUnitCapturedTrigger(nil, M2NWNodeCaptured, ScenarioInfo.NWNode)
    ScenarioInfo.NWNode:SetReclaimable(false)

    -- NW Node captured camera
    local camInfo = {
        blendTime = 1.0,
        holdTime = 4,
        orientationOffset = { 0.3927, 0.3, 0 },
        positionOffset = { 0, 1, 0 },
        zoomVal = 30,
    }
    ScenarioFramework.OperationNISCamera(ScenarioInfo.NWNode, camInfo)
end

-- When player captures the SE node
function M2SENodeCaptured(unit, captor)
    ScenarioInfo.SENode = unit
    if not ScenarioInfo.SENodeCapturedBool then
        ScenarioInfo.SENodeCapturedBool = true
        ScenarioFramework.Dialogue(OpStrings.A04_M02_040)
        for num, unit in ScenarioInfo.SEDefenses do
            if not unit:IsDead() then
                ScenarioFramework.GiveUnitToArmy(unit, Player)
            end
        end
    end
    ScenarioInfo.SENodeHandled = true
    ScenarioFramework.CreateUnitDeathTrigger(M2NodeDestroyed, ScenarioInfo.SENode)
    ScenarioFramework.CreateUnitReclaimedTrigger(M2NodeDestroyed, ScenarioInfo.SENode)
    ScenarioFramework.CreateUnitCapturedTrigger(nil, M2SENodeCaptured, ScenarioInfo.SENode)
    ScenarioInfo.SENode:SetReclaimable(false)

    -- SE Node captured camera
    local camInfo = {
        blendTime = 1.0,
        holdTime = 4,
        orientationOffset = { -1.5708, 0.3, 0 },
        positionOffset = { 0, 1, 0 },
        zoomVal = 30,
    }
    ScenarioFramework.OperationNISCamera(ScenarioInfo.SENode, camInfo)
end

-- If the player captures the SW Node again
function M2SWNodeCaptured(unit, captor)
    ScenarioInfo.SWNode = unit
    ScenarioFramework.CreateUnitDeathTrigger(M2NodeDestroyed, ScenarioInfo.SWNode)
    ScenarioFramework.CreateUnitReclaimedTrigger(M2NodeDestroyed, ScenarioInfo.SWNode)
    ScenarioFramework.CreateUnitCapturedTrigger(nil, M2SWNodeCaptured, ScenarioInfo.SWNode)
    ScenarioInfo.SWNode:SetReclaimable(false)
end

function M2WinOperation()
    -- ScenarioFramework.EndOperationCamera(ScenarioInfo.Mainframe)
    local camInfo = {
        blendTime = 2.5,
        holdTime = nil,
        orientationOffset = { math.pi, 0.8, 0 },
        positionOffset = { 0, 4, 0 },
        zoomVal = 45,
        spinSpeed = 0.03,
        overrideCam = true,
    }
    ScenarioFramework.OperationNISCamera(ScenarioInfo.Mainframe, camInfo)

    ForkThread(WinGame)
    ScenarioInfo.M2P2Obj:ManualResult(true)
    ScenarioInfo.M2P1Obj:ManualResult(true)
end

function M2ObjectiveReminder()
    if ScenarioInfo.MissionNumber == 2 then
        ScenarioFramework.CreateTimerTrigger(M2ObjectiveReminder, ObjectiveReminderTimer)
        if not ScenarioInfo.MainframeCaptured then
            if Random(1,2) == 1 then
                ScenarioFramework.Dialogue(OpStrings.A04_M02_130)
            else
                ScenarioFramework.Dialogue(OpStrings.A04_M02_135)
            end
        elseif not ScenarioInfo.SENodeHandled or not ScenarioInfo.NWNodeHandled then
            if Random(1,2) == 1 then
                ScenarioFramework.Dialogue(OpStrings.A04_M02_140)
            else
                ScenarioFramework.Dialogue(OpStrings.A04_M02_145)
            end
        end
    end
end

-- === WIN LOSS FUNCTIONS === #
function WinGame()
    ScenarioInfo.OpComplete = true
    WaitSeconds(5)
    local secondaries = SimObjectives.IsComplete(ScenarioInfo.M1S1Obj)
    ScenarioFramework.EndOperation(ScenarioInfo.OpComplete, ScenarioInfo.OpComplete, secondaries)
end

function PlayerCDRDestroyed(unit)
    ScenarioFramework.PlayerDeath(unit, OpStrings.A04_D01_010)
end
