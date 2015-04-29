-- ****************************************************************************
-- **
-- **  File     :  /maps/SCCA_Coop_E04/SCCA_Coop_E04_v03_script.lua
-- **  Author(s):  Matt Mahon
-- **
-- **  Summary  :
-- **
-- **  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
-- ****************************************************************************
local Cinematics = import('/lua/cinematics.lua')
local Behaviors = import('/lua/ai/opai/OpBehaviors.lua')
local ScenarioFramework = import('/lua/scenarioframework.lua')
local Objectives = ScenarioFramework.Objectives
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local OpStrings = import ('/maps/SCCA_Coop_E04/SCCA_Coop_E04_v03_strings.lua')
local EditorFunctions = import('/maps/SCCA_Coop_E04/SCCA_Coop_E04_v03_EditorFunctions.lua')
local AIBuildStructures = import('/lua/ai/aibuildstructures.lua')
local ScenarioPlatoonAI = import ('/lua/ScenarioPlatoonAI.lua')
local VizMarker = import('/lua/sim/VizMarker.lua').VizMarker

local Utilities = import('/lua/Utilities.lua')


-- Import camera class
local SimCamera = import('/lua/SimCamera.lua').SimCamera

local Difficulty = ScenarioInfo.Options.Difficulty or 2

function AdjustDifficulty (table)
	return table[Difficulty]
end

-- === GLOBAL VARIABLES === #
ScenarioInfo.M3RadarsUp             = 0
M3FleeingEngineersDestroyedCount    = 0
M3FleeingEngineersEscapedCount      = 0
M3FleeingEngineersTotal             = 8

-- === LOCAL VARIABLES === #

-- objective groups
local objGroup1 = false
local objGroup2 = false
local objGroup3 = false
local objGroup3s = false

-- === Tuning Variables === #
 -- all tech1 are available, no tech 3 are available.
                                    -- T2 Shield Generator  T2 Anti-Missile       LRA                 TML                  Radar Jammer           T2 air transport
local M1UEFTech2NotAllowed      =   categories.ueb4202  + categories.ueb4201 + categories.ueb2303 + categories.ueb2108 + categories.ueb4203 + categories.uea0104
local M1CybranTech2NotAllowed   =   categories.urb4202  + categories.urb4201 + categories.urb2303 + categories.urb2108 + categories.urb4203 + categories.ura0104

local M1P2LabCapturedRequired   = 2

-- enemy taunts
local M1GaugeTimer1             = 180   -- 3min
local M1GaugeTimer2             = 360   -- 6min
-- Base gets offensive
local M1BaseTimer               = 600   -- 10Min

-- M1 Objective Prompts
local M1FirstPromptTimer        = 900
local M1SubsequentPromptTimer   = 600

-- M1 attack timers
-- min time between attacks,
-- still build dependant
local M1AirAttackTimer          = AdjustDifficulty ({300,300,300})
local M1TankAttackTimer         = AdjustDifficulty ({300,300,300})


ScenarioInfo.VarTable['M1CybranAirAttackGo'] = true -- 1st ones go when ready
ScenarioInfo.VarTable['M1CybranTankAttackGo'] = true

-- how many platoons needed to build AM
ScenarioInfo.VarTable['M1AMBomberPlatoonsRequired']     = AdjustDifficulty ({1,2,2})

-- for the tanks, this is the 1st attAck, then Subsequent number get swapped in
ScenarioInfo.VarTable['M1AMTankPlatoonsRequired']       = AdjustDifficulty ({1,2,3})
local M1AMTankSubsequentPlatoonsRequired                = AdjustDifficulty ({2,3,6})
-- if < Needed, build more
ScenarioInfo.VarTable['M1EngineersNeeded']              = AdjustDifficulty ({2,4,6})


-- instance counts
ScenarioInfo.VarTable['M1BaseGuardPlatoonsAllowed']     = AdjustDifficulty ({2,2,2})
ScenarioInfo.VarTable['M1AMSUBInterceptorsAllowed']     = AdjustDifficulty ({0,1,1})
ScenarioInfo.VarTable['M1AMSUBBombersAllowed']          = AdjustDifficulty ({1,2,3})
local M1AMBomberSubsequentPlatoonsAllowed               = AdjustDifficulty ({2,4,6})
ScenarioInfo.VarTable['M1AMSUBTanksAllowed']            = AdjustDifficulty ({2,4,8})


-- at some point unlock shields
local M2GaugeTimer              = 120   -- 2min
local M2LAITimer                = 240   -- 4min
local M2SheildsTimer            = 480   -- 8Min
-- Cybrans start building TML's triggers after a timer,
-- or if the Player uses (builds?) LAI's
local M2CybranTMLTimer          = 600   -- 10Min,
-- min after the Cybran start making TML's
local M2AMDTimer                = 60    -- 1Min,
-- time between capturing lab and Dr sweeny finding a truck
local M2TruckFoundTimer         = 30   -- 1Min,
-- time between finding truck and truck moving out
-- now the player owns the truck
-- local M2TruckMoveOutTimer       = 60    #1Min,
-- time between truck moving out and Cybran attack on it
local M2TruckAttackTimer        = 30    -- 30sec,

-- M2 Objective Prompts
local M2P1FirstPromptTimer        = 900
local M2P1SubsequentPromptTimer   = 900
local M2P2FirstPromptTimer        = 180
local M2P2SubsequentPromptTimer   = 300
local M2P3FirstPromptTimer        = 900
local M2P3SubsequentPromptTimer   = 900

-- M2 attack timers
-- min time between AM platoon, still dependant on the unit build rates
local M2AirAttackTimer          = 240
local M2TankAttackTimer         = 300
local M2GunshipAttackTimer      = 302
local M2TorpedoPlaneTimer       = 420

-- if < Needed, build more
ScenarioInfo.VarTable['M2EngineersNeeded'] = AdjustDifficulty ({8,12,16})

ScenarioInfo.VarTable['M2CybranAirAttackGo'] = false
ScenarioInfo.VarTable['M2CybranTankAttackGo'] = false
ScenarioInfo.VarTable['M2CybranGunshipAttackGo'] = false
ScenarioInfo.VarTable['M2CybranTorpedoPlaneGo'] = false

-- Sub platoons needed for AM launch
ScenarioInfo.VarTable['M2AMBomberPlatoonsRequired']         = AdjustDifficulty ({2,2,2})
ScenarioInfo.VarTable['M2AMGunshipPlatoonsRequired']        = AdjustDifficulty ({1,3,5})
ScenarioInfo.VarTable['M2AMTankPlatoonsRequired']           = AdjustDifficulty ({4,6,8})
ScenarioInfo.VarTable['M2AMTorpedoPlanePlatoonsRequired']   = AdjustDifficulty ({1,4,6})

-- instance counts
ScenarioInfo.VarTable['M2AMSUBGunshipsAllowed']             = AdjustDifficulty ({2,5,8})
ScenarioInfo.VarTable['M2AMSUBInterceptorsAllowed']         = AdjustDifficulty ({1,1,1})
ScenarioInfo.VarTable['M2AMSUBBombersAllowed']              = AdjustDifficulty ({3,5,7})
ScenarioInfo.VarTable['M2AMSUBTanksAllowed']                = AdjustDifficulty ({6,10,12})
ScenarioInfo.VarTable['M2AMTorpedoPlanePlatoonsAllowed']    = AdjustDifficulty ({1,4,6})

local M3RadarsNeeded            = 3
local M3RadarTimer              = 90   -- 3min
local M3FrenzyTimer             = AdjustDifficulty ({360,180,120})
local M3FenzyMinTimer           = AdjustDifficulty ({90,90,90})
local M3FrenzyTimerDec          = AdjustDifficulty ({5,10,15})
local M3FrenzyPlatoonCount      = AdjustDifficulty ({1,1,2})
local M3FrenzyPlatoonMax        = AdjustDifficulty ({2,4,5})
local M3FrenzyPlatoonCountInc   = AdjustDifficulty ({0.10,0.25, 0.25})

-- M2 Objective Prompts
local M3P1FirstPromptTimer        = 900
local M3P1SubsequentPromptTimer   = 600
local M3P3FirstPromptTimer        = 900
local M3P3SubsequentPromptTimer   = 900
local M3P4FirstPromptTimer        = 900
local M3P4SubsequentPromptTimer   = 900

-- === Other === #
local MissionTexture = '/textures/ui/common/missions/mission.dds'

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


-------------
-- Army Brains
-------------
ScenarioInfo.Player = 1
ScenarioInfo.Cybran = 2
ScenarioInfo.CybranResearch = 3
ScenarioInfo.Coop1 = 4
ScenarioInfo.Coop2 = 5
ScenarioInfo.Coop3 = 6
ScenarioInfo.HumanPlayers = {ScenarioInfo.Player}

-- ##### Starter Functions ######
function OnPopulate(scenario)
	ScenarioUtils.InitializeScenarioArmies()
    ScenarioFramework.GetLeaderAndLocalFactions()
end

function CheatEconomy()
    ArmyBrains[ScenarioInfo.Cybran]:GiveStorage('MASS', 500000)
    ArmyBrains[ScenarioInfo.Cybran]:GiveStorage('ENERGY', 500000)
    while(true) do
        ArmyBrains[ScenarioInfo.Cybran]:GiveResource('MASS', 500000)
        ArmyBrains[ScenarioInfo.Cybran]:GiveResource('ENERGY', 500000)
		WaitSeconds(.5)
    end
end

function OnLoad(self)
end

function OnStart(self)
    -- Setting Playable area
    ScenarioFramework.SetPlayableArea(ScenarioUtils.AreaToRect('M1_Playable_Area'), false)

    ScenarioFramework.SetUEFColor(ScenarioInfo.Player)
    ScenarioFramework.SetCybranColor(ScenarioInfo.Cybran)
    ScenarioFramework.SetCybranAllyColor(ScenarioInfo.CybranResearch) -- SetNeutralColor
    -- ScenarioFramework.SetNeutralColor(ScenarioInfo.CybranResearch) #

    -- moved here per drew
    ArmyBrains[ScenarioInfo.Cybran]:PBMRemoveBuildLocation(nil, 'MAIN')
    ArmyBrains[ScenarioInfo.Cybran]:PBMAddBuildLocation(ScenarioUtils.MarkerToPosition('Cybran_M1_Base'), 50, 'Cybran_M1_Base')
    ArmyBrains[ScenarioInfo.Cybran]:PBMAddBuildLocation(ScenarioUtils.MarkerToPosition('Cybran_M2_Base'), 40, 'Cybran_M2_Base')
    ArmyBrains[ScenarioInfo.Cybran]:PBMAddBuildLocation(ScenarioUtils.MarkerToPosition('Cybran_M2_T2_Airbase'), 30, 'Cybran_M2_T2_Airbase')
    ScenarioFramework.StartOperationJessZoom('Start_Camera_Area', Intro_NIS)
end

function Intro_NIS()
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

    ScenarioFramework.CreateUnitDeathTrigger(OnCommanderDeath, ScenarioInfo.PlayerCDR)
    ScenarioFramework.PauseUnitDeath(ScenarioInfo.PlayerCDR)

    for index, coopACU in ScenarioInfo.CoopCDR do
        ScenarioFramework.PauseUnitDeath(coopACU)
        ScenarioFramework.CreateUnitDeathTrigger(OnCommanderDeath, coopACU)
    end

    WaitSeconds(3)
    StartMission1()
end

-- === Mission 1 Functions === #
function StartMission1()
    LOG('debugMatt:Difficulty == '..Difficulty )
    ScenarioInfo.MissionNumber = 1
    --SetArmyUnitCap ('Player', 300)
    ScenarioFramework.Dialogue(OpStrings.E04_M01_010)

    -- === Formerly in OnPopualte === #
    -- Spawn in Player CDR

    ScenarioUtils.CreateArmyGroup('Cybran', 'M1_Expansion_Base_Premade_D'..Difficulty)
    ScenarioUtils.CreateArmyGroup('Cybran', 'M1_Research_Base_Defense_D'..Difficulty)

    local plat = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M1_York_Patrol_D'..ScenarioInfo.Options.Difficulty, 'TravellingFormation')
    ScenarioFramework.PlatoonPatrolChain(plat, 'M1_York18_Patrol_Chain')

    -- append difficulty info to make new master base maintenance template

    AIBuildStructures.CreateBuildingTemplate(ArmyBrains[ScenarioInfo.Cybran], 'Cybran', 'M1_Expansion_Base_Maintenance')
    AIBuildStructures.AppendBuildingTemplate(ArmyBrains[ScenarioInfo.Cybran], 'Cybran', ('M1_Expansion_Base_Premade_D'..Difficulty), 'M1_Expansion_Base_Maintenance')
    AIBuildStructures.AppendBuildingTemplate(ArmyBrains[ScenarioInfo.Cybran], 'Cybran', ('M1_Expansion_Base_Constructed_D'..Difficulty), 'M1_Expansion_Base_Maintenance')


    -- spawn research targets
    ScenarioInfo.M1ResearchGroup = ScenarioUtils.CreateArmyGroup('Cybran_Research', 'M1_Science_Buildings')

    -- === (above) Formerly in OnPopualte  === #


    -- Define Tech Restrictions
	for _, player in ScenarioInfo.HumanPlayers do
		-- prevent all units from building t3 units, except t3 air factories, spy planes
		ScenarioFramework.AddRestriction(player, categories.TECH3 - categories.ueb0302 - categories.urb0302 -  categories.uea0302 - categories.ura0302)
		-- prevent building t2 restricted units
		ScenarioFramework.AddRestriction(player, M1UEFTech2NotAllowed)
		-- prevent building cybran t2 restricted units, should the player capture cybran engineers
		ScenarioFramework.AddRestriction(player, M1CybranTech2NotAllowed)
	end
    -- Commander enhancements
    ScenarioFramework.RestrictEnhancements({'T3Engineering',
                                            'ShieldGeneratorField',
                                            'TacticalNukeMissile',
                                            'Teleporter'})

    -- ! Assign M1P1 & 2
    objGroup1 = Objectives.CreateGroup("Mission1", M1Success);


    ScenarioInfo.M1P1 = Objectives.CategoriesInArea(
        'primary',
        'incomplete',
        OpStrings.M1P1Title,
        OpStrings.M1P1Description,
        "Kill",
        {
            MarkArea = false,
            -- FlashVisible = true,
            ShowFaction = 'Cybran',
            Requirements = {
                {
                    Area = 'M1_Expansion_Base',
                    ArmyIndex = ScenarioInfo.Cybran,
                    Category = (categories.FACTORY + categories.ENGINEER),
                    CompareOp = '==',
                    Value = 0,
                },
            },
        }
   )
    ScenarioInfo.M1P1:AddResultCallback(M1OnExpansionBaseDestroyed)
    objGroup1:AddObjective(ScenarioInfo.M1P1)

    ScenarioInfo.M1P2 = Objectives.Capture(
        'primary',
        'incomplete',
        OpStrings.M1P2Title,
        OpStrings.M1P2Description,
        {
            Units = ScenarioInfo.M1ResearchGroup,
            NumRequired = M1P2LabCapturedRequired,
            FlashVisible = true,
        }
   )
    ScenarioInfo.M1P2:AddResultCallback(M1OnLabCaptured)
    objGroup1:AddObjective(ScenarioInfo.M1P2)


    -- objective Prompts
    ScenarioFramework.CreateTimerTrigger(M1OnObjectivePrompt1, M1FirstPromptTimer)


    -- set some timers
    ScenarioFramework.CreateTimerTrigger(M1OnGaugeTimer1, M1GaugeTimer1)    -- 3min
    ScenarioFramework.CreateTimerTrigger(M1OnGaugeTimer2, M1GaugeTimer2)    -- 6min
    ScenarioFramework.CreateTimerTrigger(M1OnBaseTimer, M1BaseTimer)      -- 9min

end

function M1OnAirAttackTimer ()
    LOG('debugMatt:M1CybranAirAttackGo = true' )
    ScenarioInfo.VarTable['M1CybranAirAttackGo'] = true

    -- after the first time  swap in new value
    ScenarioInfo.VarTable['M1AMSUBBombersAllowed'] = M1AMBomberSubsequentPlatoonsAllowed
end

function M1StartAirAttackTimer ()
    -- Called from SCCA_Coop_E04_EditorFunctions
    LOG('debugMatt:M1CybranAirAttackGo = false' )
    ScenarioInfo.VarTable['M1CybranAirAttackGo'] = false
    ScenarioFramework.CreateTimerTrigger(M1OnAirAttackTimer, M1AirAttackTimer)
end

function M1OnTankAttackTimer ()
    LOG('debugMatt:M1CybranTankAttackGo = true' )
    ScenarioInfo.VarTable['M1CybranTankAttackGo'] = true
end

function M1StartTankAttackTimer ()
    -- Called from SCCA_Coop_E04_EditorFunctions
    LOG('debugMatt:M1CybrantankAttackGo = false' )
    ScenarioInfo.VarTable['M1CybranTankAttackGo'] = false
    ScenarioFramework.CreateTimerTrigger(M1OnTankAttackTimer, M1TankAttackTimer)
end

function M1OnObjectivePrompt1()
    if ScenarioInfo.M1P1.Active and not ScenarioInfo.OpEnded then
        -- prompt for Obj1
        ScenarioFramework.Dialogue(OpStrings.E04_M01_100)
    elseif ScenarioInfo.M1P2.Active and not ScenarioInfo.OpEnded then
        -- prompt for Obj2
        ScenarioFramework.Dialogue(OpStrings.E04_M01_110)
    end
    if (ScenarioInfo.M1P1.Active or ScenarioInfo.M1P2.Active) and not ScenarioInfo.OpEnded then
        ScenarioFramework.CreateTimerTrigger(M1OnObjectivePrompt2, M1SubsequentPromptTimer)
    end
end

function M1OnObjectivePrompt2()
    if ScenarioInfo.M1P1.Active  and not ScenarioInfo.OpEnded then
        -- prompt for Obj1
        ScenarioFramework.Dialogue(OpStrings.E04_M01_105)
    elseif ScenarioInfo.M1P2.Active  and not ScenarioInfo.OpEnded then
        -- prompt for Obj2
        ScenarioFramework.Dialogue(OpStrings.E04_M01_115)
    end
    if (ScenarioInfo.M1P1.Active or ScenarioInfo.M1P2.Active)  and not ScenarioInfo.OpEnded then
        ScenarioFramework.CreateTimerTrigger(M1OnObjectivePrompt2, M1SubsequentPromptTimer)
    end
end

function M1OnExpansionBaseDestroyed()
    LOG('debugMatt:Base Destroyed' )
    ScenarioFramework.Dialogue(OpStrings.E04_M01_040)
-- expansion base destroyed cam
    local camInfo = {
        blendTime = 1.0,
        holdTime = 4,
        orientationOffset = { 2.7, 0.1, 0 },
        positionOffset = { 0, 0.5, 0 },
      	zoomVal = 30,
    	markerCam = true,
    }
    ScenarioFramework.OperationNISCamera(ScenarioUtils.MarkerToPosition('Cybran_M1_Base'), camInfo)
end


function M1OnLabCaptured(success, units)
    LOG("debugMatt:M1OnLabCapture: result ",success)
    if (success) then
        ScenarioFramework.Dialogue(OpStrings.E04_M01_050)
-- labs captured cam
        local camInfo = {
        	blendTime = 1.0,
        	holdTime = 4,
        	orientationOffset = { -2.1, 0.4, 0 },
        	positionOffset = { 0, 1, 0 },
        	markerCam = true,
        	zoomVal = 35,
        }
        ScenarioFramework.OperationNISCamera(ScenarioUtils.MarkerToPosition('York18_Cam'), camInfo)
    else
        PlayerLose(OpStrings.E04_M01_060)
-- labs destroyed cam
--    ScenarioFramework.EndOperationCameraLocation(ScenarioUtils.MarkerToPosition('York18_Cam'))
        local camInfo = {
            blendTime = 2.50,
            holdTime = nil,
            orientationOffset = { math.pi, 0.4, 0 },
            positionOffset = { 0, 4, 0 },
            zoomVal = 35,
            spinSpeed = 0.03,
        	markerCam = true,
        	overrideCam = true,
        }
        ScenarioFramework.OperationNISCamera(ScenarioUtils.MarkerToPosition('York18_Cam'), camInfo)
    end
end

function M1OnGaugeTimer1()
    ScenarioFramework.Dialogue(OpStrings.E04_M01_020)
end

function M1OnGaugeTimer2()
    ScenarioFramework.Dialogue(OpStrings.E04_M01_030)
end

function M1OnBaseTimer()
    -- AI Base Gets offensive
    LOG('debugMatt: Cybran Offensive Go!')
    ScenarioInfo.VarTable['M1CybranOffensive'] = true
    -- also start expanding base
    AIBuildStructures.AppendBuildingTemplate(ArmyBrains[ScenarioInfo.Cybran], 'Cybran', ('M1_Expansion_Base_Phase2_D'..Difficulty), 'M1_Expansion_Base_Maintenance')
end

function M1Success()
    LOG('debugMatt:Mission 1 complete')
    ScenarioFramework.Dialogue(OpStrings.E04_M01_070,StartMission2)

    -- StartMission2()
end

-- === Mission 2 Functions === #
function StartMission2()
    ScenarioInfo.MissionNumber = 2
    ScenarioFramework.Dialogue(OpStrings.E04_M02_010)

    -- Setting Playable area
    ScenarioFramework.SetPlayableArea(ScenarioUtils.AreaToRect('M2_Playable_Area'))

    ScenarioFramework.RemoveRestrictionForAllHumans(
        categories.uea0303 + categories.ura0303 +  -- ASFs
        categories.ueb2108 + categories.urb2108    -- TMLs
    )

    ScenarioInfo.CybranCDR = ScenarioUtils.CreateArmyUnit('Cybran', 'Commander')
    ScenarioInfo.CybranCDR:SetCustomName(LOC '{i CDR_Gauge}')
    ScenarioInfo.CybranCDR:CreateEnhancement('AdvancedEngineering')
    ScenarioInfo.CybranCDR:CreateEnhancement('MicrowaveLaserGenerator')
    -- ScenarioInfo.CybranCDR:CreateEnhancement('CloakingGenerator')
    -- ScenarioFramework.CreateUnitDeathTrigger(M2OnCybranLeaderDeath, ScenarioInfo.CybranCDR)

	ForkThread(CheatEconomy)
	
    -- Overcharge manager
    local cdrPlatoon = ArmyBrains[ScenarioInfo.Cybran]:MakePlatoon(' ', ' ')
    ArmyBrains[ScenarioInfo.Cybran]:AssignUnitsToPlatoon(cdrPlatoon, {ScenarioInfo.CybranCDR}, 'Attack', 'AttackFormation')
    --import('/lua/ai/AIBehaviors.lua').CDROverchargeBehavior(cdrPlatoon)
	cdrPlatoon:ForkThread(Behaviors.CDROverchargeBehavior)
    ArmyBrains[ScenarioInfo.Cybran]:DisbandPlatoon(cdrPlatoon)

    -- Outer defense
    ScenarioUtils.CreateArmyGroup('Cybran', 'M2_Outer_Defense_D'..Difficulty)

    -- Main Enemy Base
    ScenarioUtils.CreateArmyGroup('Cybran', 'M2_Base_Premade_D'..Difficulty)

    -- append difficulty info to make new master base maintenance template

    AIBuildStructures.CreateBuildingTemplate(ArmyBrains[ScenarioInfo.Cybran], 'Cybran', 'M2_Base_Maintenance')
    -- Im maintaining difficulty across all levels in this base, but for easy, I only use it to build the
    -- TML when the timer ticks
    if (Difficulty > 1) then
        LOG('Debugmatt: difficulty'..Difficulty)
        AIBuildStructures.AppendBuildingTemplate(ArmyBrains[ScenarioInfo.Cybran], 'Cybran', ('M2_Base_Premade_D'..Difficulty), 'M2_Base_Maintenance')
        AIBuildStructures.AppendBuildingTemplate(ArmyBrains[ScenarioInfo.Cybran], 'Cybran', ('M2_Base_Constructed_D'..Difficulty), 'M2_Base_Maintenance')
    end


    local researchLab = ScenarioUtils.CreateArmyUnit('Cybran_Research', 'M2_Science_Building')

    -- As of 6/30/06 lab can't be destroyed (Klinkhammers was hitting it accidently
    researchLab:SetCanTakeDamage(false)
    researchLab:SetCanBeKilled(false)

    objGroup2 = Objectives.CreateGroup('Mission2', M2Success, 3)


    ScenarioInfo.M2P1 = Objectives.Capture(
        'primary',
        'incomplete',
        OpStrings.M2P1Title,
        OpStrings.M2P1Description,
        {
            Units = {researchLab},
            FlashVisible = true,
        }
   )
    ScenarioInfo.M2P1:AddResultCallback(M2OnLabCaptured)
    objGroup2:AddObjective(ScenarioInfo.M2P1)

    ScenarioInfo.M2P3 = Objectives.Kill(
        'primary',
        'incomplete',
        OpStrings.M2P3Title,
        OpStrings.M2P3Description,
        { Units = {ScenarioInfo.CybranCDR} }
   )
    ScenarioInfo.M2P3:AddResultCallback(M2OnCybranLeaderDeath)
    objGroup2:AddObjective(ScenarioInfo.M2P3)


    -- Primary Objective prompt
    ScenarioFramework.CreateTimerTrigger(M2OnP1Prompt1, M2P1FirstPromptTimer)


    -- set some timers
    ScenarioFramework.CreateTimerTrigger(M2OnGaugeTimer, M2GaugeTimer)
    ScenarioFramework.CreateTimerTrigger(M2OnLAITimer, M2LAITimer)
    ScenarioFramework.CreateTimerTrigger(M2OnSheildsTimer, M2SheildsTimer)
    ScenarioFramework.CreateTimerTrigger(M2UnlockCybranTML, M2CybranTMLTimer)


    -- kick off builders
    ScenarioInfo.VarTable['M2CybranTankAttackGo']       = true
    ScenarioInfo.VarTable['M2CybranAirAttackGo']        = true
    ScenarioInfo.VarTable['M2CybranGunshipAttackGo']    = true
    ScenarioInfo.VarTable['M2CybranTorpedoPlaneGo']     = true


end

function M2RandomTaunt()
    if (not Objectives.IsComplete(ScenarioInfo.M2P3)) then
        ScenarioFramework.Dialogue(TauntTable[Random(1,table.getn(TauntTable))])
    end
end

function M2OnAirAttackTimer()
    LOG('debugMatt:M2CybranAirAttackGo = true' )
    ScenarioInfo.VarTable['M2CybranAirAttackGo'] = true
end

function M2StartAirAttackTimer()
    -- Called from SCCA_Coop_E04_EditorFunctions
    LOG('debugMatt:M2CybranAirAttackGo = false' )
    ScenarioInfo.VarTable['M2CybranAirAttackGo'] = false
    ScenarioFramework.CreateTimerTrigger(M2OnAirAttackTimer, M2AirAttackTimer)
end

function M2OnTankAttackTimer()
    LOG('debugMatt:M2CybranTankAttackGo = true' )
    ScenarioInfo.VarTable['M2CybranTankAttackGo'] = true
end

function M2StartTankAttackTimer()
    -- Called from SCCA_Coop_E04_EditorFunctions
    LOG('debugMatt:M2CybrantankAttackGo = false' )
    ScenarioInfo.VarTable['M2CybranTankAttackGo'] = false
    ScenarioFramework.CreateTimerTrigger(M2OnTankAttackTimer, M2TankAttackTimer)

    -- tanks just ran, swap in new values
    ScenarioInfo.VarTable['M1AMTankPlatoonsRequired'] = M1AMTankSubsequentPlatoonsRequired
end

function M2OnGunshipAttackTimer()
    LOG('debugMatt:M2CybranGunshipAttackGo = true' )
    ScenarioInfo.VarTable['M2CybranGunshipAttackGo'] = true
end

function M2OnTorpedoPlaneTimer()
    LOG('debugMatt:M2OnTopedoPlaneTimer = true' )
    ScenarioInfo.VarTable['M2CybranTorpedoPlaneGo'] = true
end

function M2StartGunshipAttackTimer()
    -- Called from SCCA_Coop_E04_EditorFunctions
    LOG('debugMatt:M2CybranGunshipAttackGo = false' )
    ScenarioInfo.VarTable['M2CybranGunshipAttackGo'] = false
    ScenarioFramework.CreateTimerTrigger(M2OnGunshipAttackTimer, M2GunshipAttackTimer)
end

function M2StartTorpedoPlaneTimer()
    -- Called from SCCA_Coop_E04_EditorFunctions
    LOG('debugMatt:M2StartTorpedoPlaneTimer = false' )
    ScenarioInfo.VarTable['M2CybranTorpedoPlaneGo'] = false
    ScenarioFramework.CreateTimerTrigger(M2OnTorpedoPlaneTimer, M2TorpedoPlaneTimer)
end

function M2OnP1Prompt1()
    if ScenarioInfo.M2P1.Active and not ScenarioInfo.OpEnded then
        -- prompt for P1
        ScenarioFramework.Dialogue(OpStrings.E04_M02_150)
        ScenarioFramework.CreateTimerTrigger(M2OnP1Prompt2, M2P1SubsequentPromptTimer)
    end
end

function M2OnP1Prompt2()
    if ScenarioInfo.M2P1.Active and not ScenarioInfo.OpEnded then
        -- prompt for P1
        ScenarioFramework.Dialogue(OpStrings.E04_M02_155)
        ScenarioFramework.CreateTimerTrigger(M2OnP1Prompt1, M2P1SubsequentPromptTimer)
    end
end

function M2OnP2Prompt1()
    if ScenarioInfo.M2P2.Active and not ScenarioInfo.OpEnded then
        -- prompt for P2
        ScenarioFramework.Dialogue(OpStrings.E04_M02_160)
        ScenarioFramework.CreateTimerTrigger(M2OnP2Prompt2, M2P2SubsequentPromptTimer)
    else
        ScenarioFramework.CreateTimerTrigger(M2OnP3Prompt1, M2P3FirstPromptTimer)
    end
end

function M2OnP2Prompt2()
    if ScenarioInfo.M2P2.Active and not ScenarioInfo.OpEnded then
        -- prompt for P2
        ScenarioFramework.Dialogue(OpStrings.E04_M02_165)
        ScenarioFramework.CreateTimerTrigger(M2OnP2Prompt1, M2P2SubsequentPromptTimer)
    else
        ScenarioFramework.CreateTimerTrigger(M2OnP3Prompt1, M2P3FirstPromptTimer)
    end
end

function M2OnP3Prompt1()
    if ScenarioInfo.M2P3.Active and not ScenarioInfo.OpEnded then
        -- prompt for P3
        ScenarioFramework.Dialogue(OpStrings.E04_M02_170)
        ScenarioFramework.CreateTimerTrigger(M2OnP3Prompt2, M2P3SubsequentPromptTimer)
    end
end

function M2OnP3Prompt2()
    if ScenarioInfo.M2P3.Active and not ScenarioInfo.OpEnded then
        -- prompt for P3
        ScenarioFramework.Dialogue(OpStrings.E04_M02_175)
        ScenarioFramework.CreateTimerTrigger(M2OnP3Prompt1, M2P3SubsequentPromptTimer)
    end
end

function M2OnCybranLeaderDeath(result,unit)
    LOG('debugMatt:Cybran Commander Destroyed')
    ScenarioFramework.KillBaseInArea(ArmyBrains[ScenarioInfo.Cybran],{'M2_Cybran_Base_a','M2_Cybran_Base_b'})
    ScenarioFramework.Dialogue(OpStrings.E04_M02_110)
    ScenarioFramework.CDRDeathNISCamera(unit, 7)

end

function M2OnGaugeTimer()
    ScenarioFramework.Dialogue(OpStrings.E04_M02_030)
end

function M2OnLAITimer()
    -- unlock T2 artillary
    ScenarioFramework.RemoveRestrictionForAllHumans(categories.ueb2303 + categories.urb2303)
    ScenarioFramework.Dialogue(OpStrings.E04_M02_040)
    M2RandomTaunt()
end

function M2OnSheildsTimer()
    -- unlock T2 shields
    ScenarioFramework.RemoveRestrictionForAllHumans(categories.ueb4202 + categories.urb4202)
    ScenarioFramework.Dialogue(OpStrings.E04_M02_020)
    M2RandomTaunt()

end

function M2OnAMDTimer()
    -- unlock T2 anti-missle defense
    ScenarioFramework.RemoveRestrictionForAllHumans(categories.ueb4201 + categories.urb4201)

    if not Objectives.IsComplete(ScenarioInfo.M2P3) then
        ScenarioFramework.Dialogue(OpStrings.E04_M02_050)
        M2RandomTaunt()
    end
end

function M2UnlockCybranTML()
    -- Cybrans now start building TML
    -- Start timer for AntiMissle prompt
    ScenarioFramework.CreateTimerTrigger(M2OnAMDTimer, M2AMDTimer)
    AIBuildStructures.AppendBuildingTemplate(ArmyBrains[ScenarioInfo.Cybran], 'Cybran', ('M2_TMLs'), 'M2_Base_Maintenance')
end

function M2OnLabCaptured()
    LOG('debugMatt:M2 Lab captured')
    ScenarioFramework.Dialogue(OpStrings.E04_M02_060)

    ScenarioFramework.CreateTimerTrigger(M2OnTruckFoundTimer, M2TruckFoundTimer)
end

function M2OnTruckFoundTimer()

    LOG('debugMatt:M2 Truck found')
    ScenarioFramework.Dialogue(OpStrings.E04_M02_070)
    ScenarioFramework.SetPlayableArea('M2_Playable_Area_2')
    ScenarioInfo.M3Gate = ScenarioUtils.CreateArmyUnit('Cybran_Research', 'M3_Gate')
    ScenarioInfo.M3Gate:SetCanTakeDamage(false)
    ScenarioInfo.M3Gate:SetCanBeKilled(false)
    ScenarioInfo.M3Gate:SetCapturable(false)
    ScenarioInfo.M3Gate:SetReclaimable(false)
    -- adding some LOS to gate
    local pos = ScenarioInfo.M3Gate:GetPosition()
    local spec = {
        X = pos[1],
        Z = pos[2],
        Radius = 2,
        LifeTime = -1,
        Omni = false,
        Vision = true,
        Radar = false,
        Army = 1,
    }
    local vizmarker = VizMarker(spec)
    ScenarioInfo.M3Gate.Trash:Add(vizmarker)
    vizmarker:AttachBoneTo(-1, ScenarioInfo.M3Gate, -1)

    ScenarioInfo.M2EscapeTruck = ScenarioUtils.CreateArmyGroupAsPlatoon('Player', 'Escape_Truck', 'TravellingFormation')
    for k,unit in ScenarioInfo.M2EscapeTruck:GetPlatoonUnits() do
        ScenarioFramework.PauseUnitDeath(unit)
    end

    local m2p2Group = ScenarioInfo.M2EscapeTruck:GetPlatoonUnits()
    table.insert (m2p2Group,ScenarioInfo.M3Gate)

    ScenarioInfo.M2P2 = Objectives.SpecificUnitsInArea(
        'primary',
        'incomplete',
        OpStrings.M2P2Title,
        OpStrings.M2P2Description,
        {
            Units = m2p2Group,
            Area = 'M3_Engineer_Teleport', -- instead of m2_truck_escape
            MarkArea = false,
        }
   )

    ScenarioInfo.M2P2:AddResultCallback(M2OnTruckEscaped)
    objGroup2:AddObjective(ScenarioInfo.M2P2)

    -- this trigger is to start the attack timer after they move.
    ScenarioFramework.CreateAreaTrigger(M2OnTruckMoveOut, ScenarioUtils.AreaToRect('M2_Truck_Start'),
    (categories.OPERATION), true, true, ArmyBrains[ScenarioInfo.Player], 1, true)


-- NIS of Truck Spawned
    local unit = ScenarioInfo.M2EscapeTruck:GetPlatoonUnits()[1]
    local camInfo = {
        blendTime = 1.0,
        holdTime = 4,
        orientationOffset = { 2.3, 0.2, 0 },
        positionOffset = { 0, 0.5, 0 },
        zoomVal = 15,
    }
    ScenarioFramework.OperationNISCamera(unit, camInfo)

end

function M2OnTruckMoveOut()
    LOG('debugMatt:M2 Truck Moving Out')

    ScenarioFramework.CreateTimerTrigger(M2OnTruckAttackTimer, M2TruckAttackTimer)
end

function M2OnTruckAttackTimer()
    LOG('debugMatt:M2 Truck Cybran comming')
    ScenarioFramework.Dialogue(OpStrings.E04_M02_090)

    ScenarioInfo.M2TruckHunters = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2_Truck_Chase_D'..Difficulty, 'AttackFormation')
    ScenarioFramework.PlatoonPatrolRoute(ScenarioInfo.M2TruckHunters, ScenarioUtils.ChainToPositions('M2_Truck_Chase_Chain'))
end

function M2OnTruckEscaped(result)
    if result then
        LOG('debugMatt:M2 Truck made it to safety')
        ScenarioFramework.Dialogue(OpStrings.E04_M02_100)

        -- delete the truck, so it cant get blowed up later
        -- ScenarioInfo.M2EscapeTruck:Destroy()

-- NIS of Truck Escaping
        local unit = ScenarioInfo.M2EscapeTruck:GetPlatoonUnits()[1]
        local camInfo = {
        	blendTime = 1.0,
        	holdTime = 4,
        	orientationOffset = { -2.0, 0.6, 0 },
        	positionOffset = { 0, 1, 0 },
        	zoomVal = 30,
        }
        ScenarioFramework.OperationNISCamera(unit, camInfo)

        ScenarioFramework.FakeTeleportUnit(unit,true)

    else
        LOG('debugMatt:Mission 2 FAILED')
        PlayerLose(OpStrings.E04_M02_120) -- lose after dialog
        for k,unit in ScenarioInfo.M2EscapeTruck:GetPlatoonUnits() do
            if not unit:IsDead() then
-- NIS of truck destroyed cam
--            ScenarioFramework.EndOperationCamera(unit, false)
                local camInfo = {
                    blendTime = 2.50,
                    holdTime = nil,
                    orientationOffset = { math.pi, 0.2, 0 },
                    positionOffset = { 0, 0.5, 0 },
                    zoomVal = 15,
                    spinSpeed = 0.03,
                	overrideCam = true,
                }
                ScenarioFramework.OperationNISCamera(unit, camInfo)

                break
            end
        end
    end
end


function M2Success()
    LOG('debugMatt:Mission 2 complete')
    StartMission3()
end


-- === Mission 3 Functions === #

function StartMission3()
    ScenarioInfo.MissionNumber = 3
    SetArmyUnitCap ('Player', 500)

    -- Setting Playable area
    -- In this mission, we dont resize until the player builds 3 towers

    ScenarioFramework.Dialogue(OpStrings.E04_M03_010)

    -- unlock Strategic Bombers
    ScenarioFramework.RemoveRestrictionForAllHumans(
        categories.uea0304 + categories.ura0304 +  -- Strategic bombers
        categories.uea0104 + categories.ura0104 +  -- T2 transports
        categories.ueb4203 + categories.urb4203    -- Radar jammer
    )

    objGroup3 = Objectives.CreateGroup('Mission3',PlayerWin,3)
    objGroup3s = Objectives.CreateGroup('Mission3 Secondary',function() LOG('Seconday complete') end)

    M3RadarsObjectiveSetup()

    ScenarioFramework.CreateTimerTrigger(M3OnFrenzyTimer, M3FrenzyTimer)
end

function M3RadarsObjectiveSetup()

    if ScenarioInfo.M3P2 then
       Objectives.DeleteObjective(ScenarioInfo.M3P1)
    end

    ScenarioInfo.M3P1 = Objectives.CategoriesInArea(
        'primary',
        'incomplete',
        OpStrings.M3P1Title,
        OpStrings.M3P1Description,
        'Build',
        {
            MarkArea = true,
            Category = categories.ueb3201,
            Requirements = {
                { Area = 'M3_Radar_Loc_01', Category = categories.ueb3201, CompareOp = '>=', Value = 1 },
                { Area = 'M3_Radar_Loc_02', Category = categories.ueb3201, CompareOp = '>=', Value = 1 },
                { Area = 'M3_Radar_Loc_03', Category = categories.ueb3201, CompareOp = '>=', Value = 1 },
            }
        }
   )
    -- Matt 8/2/06 removed this one from the group as it repeats, and was screwing up the count
    -- objGroup3:AddObjective(ScenarioInfo.M3P1)
    ScenarioInfo.M3P1:AddResultCallback(M3RadarsBuilt)
    ScenarioInfo.M3P1:AddProgressCallback(M3RadarsProgress)

    -- objective prompt
    ScenarioFramework.CreateTimerTrigger(M3OnP1Prompt1, M3P1FirstPromptTimer)
end

function M3RadarsBuilt(result)
    LOG('debutMatt: radars built')
    if result then
        LOG('debugMatt:radar timer started')
        ScenarioFramework.Dialogue(OpStrings.E04_M03_040)

        ScenarioInfo.M3RadarHalfTimerThread = ScenarioFramework.CreateTimerTrigger(M3OnRadarHalfTimer, (M3RadarTimer/ 2))

        if ScenarioInfo.M3P2 then
           Objectives.DeleteObjective(ScenarioInfo.M3P2)
        end
        ScenarioInfo.M3P2 = Objectives.Protect(
            'primary',
            'incomplete',
            OpStrings.M3P2Title,
            OpStrings.M3P2Description,
            {
                Units = GetRadars(),
                Timer = M3RadarTimer,
            }
       )
        ScenarioInfo.M3P2:AddResultCallback(M3OnRadarTimer)
        objGroup3:AddObjective(ScenarioInfo.M3P2)

        -- let's have some attacks here too
        M3FrenzySpawnPlatoon()
        M3FrenzySpawnPlatoon()
        M3FrenzySpawnPlatoon()
    end
end

function M3RadarsProgress(current,total)
    ScenarioInfo.M3RadarsUp = current
    if current == 1 then
        ScenarioFramework.Dialogue(OpStrings.E04_M03_020)
    elseif current == 2 then
        ScenarioFramework.Dialogue(OpStrings.E04_M03_030)
    end
end

function GetRadars()
   radars = {}
   for k,area in { 'M3_Radar_Loc_01', 'M3_Radar_Loc_02', 'M3_Radar_Loc_03' } do
       local units = GetUnitsInRect(ScenarioUtils.AreaToRect(area))
        if units then
            for y,unit in units do
                if not unit:IsDead() and EntityCategoryContains(categories.ueb3201, unit) then
                    table.insert(radars,unit)
                    break
                end
            end
        end
    end
    return radars
end

function M3OnP1Prompt1()
    if ScenarioInfo.M3P2.Active and ScenarioInfo.M3RadarsUp < 3  and not ScenarioInfo.OpEnded then
        -- prompt for P1
        ScenarioFramework.Dialogue(OpStrings.E04_M03_150)
        ScenarioFramework.CreateTimerTrigger(M3OnP1Prompt2, M3P1SubsequentPromptTimer)
    end
end

function M3OnP1Prompt2()
    if ScenarioInfo.M3P2.Active and ScenarioInfo.M3RadarsUp < 3  and not ScenarioInfo.OpEnded then
        -- prompt for P1
        ScenarioFramework.Dialogue(OpStrings.E04_M03_155)
        ScenarioFramework.CreateTimerTrigger(M3OnP1Prompt1, M3P1SubsequentPromptTimer)
    end
end

function M3OnP3Prompt1()
    if ScenarioInfo.M3P3.Active and not ScenarioInfo.OpEnded then
        -- prompt for P1
        ScenarioFramework.Dialogue(OpStrings.E04_M03_160)
        ScenarioFramework.CreateTimerTrigger(M3OnP3Prompt2, M3P3SubsequentPromptTimer)
     else
        ScenarioFramework.CreateTimerTrigger(M3OnP4Prompt1, M3P4FirstPromptTimer)
    end
end

function M3OnP3Prompt2()
    if ScenarioInfo.M3P3.Active and not ScenarioInfo.OpEnded then
        -- prompt for P1
        ScenarioFramework.Dialogue(OpStrings.E04_M03_165)
        ScenarioFramework.CreateTimerTrigger(M3OnP3Prompt1, M3P3SubsequentPromptTimer)
     else
        ScenarioFramework.CreateTimerTrigger(M3OnP4Prompt1, M3P4FirstPromptTimer)
    end
end

function M3OnP4Prompt1()
    if ScenarioInfo.M3P4.Active and not ScenarioInfo.OpEnded then
        -- prompt for P1
        ScenarioFramework.Dialogue(OpStrings.E04_M03_170)
        ScenarioFramework.CreateTimerTrigger(M3OnP4Prompt2, M3P4SubsequentPromptTimer)
    end
end

function M3OnP4Prompt2()
    if ScenarioInfo.M3P4.Active and not ScenarioInfo.OpEnded then
        -- prompt for P1
        ScenarioFramework.Dialogue(OpStrings.E04_M03_175)
        ScenarioFramework.CreateTimerTrigger(M3OnP4Prompt1, M3P4SubsequentPromptTimer)
    end
end

function M3OnRadarHalfTimer()
    if  not ScenarioInfo.OpEnded  then
        ScenarioFramework.Dialogue(OpStrings.E04_M03_050)
    end
end

function M3OnRadarTimer(result)
    if not ScenarioInfo.OpEnded then
        if result then
            LOG('debugMatt:radar timer ended sucessfully')

            ScenarioFramework.Dialogue(OpStrings.E04_M03_060)
            ScenarioFramework.SetPlayableArea(ScenarioUtils.AreaToRect('M3_Playable_Area'))

            -- M3 gate
            -- ScenarioInfo.M3Gate:SetCanTakeDamage(false)
            -- ScenarioInfo.M3Gate:SetCanBeKilled(false)
            -- ScenarioInfo.M3Gate:SetCapturable(false)

            -- Spawning Spider as a platoon, since he may get company in hard
            ScenarioInfo.M3SpiderbotPlatoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M3_Spiderbot_D'..Difficulty, 'AttackFormation')
            ScenarioFramework.PlatoonPatrolRoute(ScenarioInfo.M3SpiderbotPlatoon, ScenarioUtils.ChainToPositions('M3_SpiderBot_Patrol_Chain'))

            for k, spider in ScenarioInfo.M3SpiderbotPlatoon:GetPlatoonUnits() do
                if EntityCategoryContains(categories.url0402, spider) then
                    spider:ToggleScriptBit('RULEUTC_StealthToggle')
                    ScenarioFramework.CreateArmyIntelTrigger(M3OnSpiderbotSpotted, ArmyBrains[ScenarioInfo.Player], 'LOSNow', spider, true, categories.ALLUNITS, true, ArmyBrains[ScenarioInfo.Cybran])
                    break
                end
            end


            -- Brackmans Lab
            local brackmansLabGroup = ScenarioUtils.CreateArmyGroup('Cybran', 'M3_Brackmans_Lab')
            -- death trigger
            for k, lab in brackmansLabGroup do
                -- instead of damage, lets try LOS
                -- ScenarioFramework.CreateUnitDamagedTrigger(M3OnBrackmanLabDamaged, lab)
                ScenarioFramework.CreateArmyIntelTrigger(M3OnBrackmanLabSpotted, ArmyBrains[ScenarioInfo.Player], 'LOSNow', lab, true, categories.ALLUNITS, true, ArmyBrains[ScenarioInfo.Cybran])
            end

            -- ... and base defense. Spawn shields as separate group, so we can give them an upgraded shield
            -- radius (level 1 shield has only small coverage)
            ScenarioUtils.CreateArmyGroup('Cybran', 'M3_Brackman_Base_D'..Difficulty)
            local shields = ScenarioUtils.CreateArmyGroup('Cybran', 'M3_Brackmans_Shields')
--        for i = 1,3 do
--            shields[i]:CreateEnhancement('Shield3')
--        end

            -- towers
            ScenarioUtils.CreateArmySubGroup('Cybran', 'M3_Brackman_Base','Towers')

            -- update Objectives

            ScenarioInfo.M3P3 = Objectives.KillOrCapture(
                'primary',
                'incomplete',
                OpStrings.M3P3Title,
                OpStrings.M3P3Description,
                {
                    Units = brackmansLabGroup,
                    FlashVisible = true,
                }
           )
            ScenarioInfo.M3P3:AddResultCallback(M3OnBrackmanLabDestroyed)
            objGroup3:AddObjective(ScenarioInfo.M3P3)

            ScenarioFramework.CreateTimerTrigger(M3OnP3Prompt1, M3P3FirstPromptTimer)
        else
            LOG('debugMatt:radar timer failed')

            -- a radar was destroyed, remove this objective and re-add the 'build radars'
            -- objective
            ScenarioFramework.Dialogue(OpStrings.E04_M03_070)
            objGroup3:RemoveObjective(ScenarioInfo.M3P2)
            M3RadarsObjectiveSetup()

            -- kill half-timer thread if it's running
            if ScenarioInfo.M3RadarHalfTimerThread then
                ScenarioInfo.M3RadarHalfTimerThread:Destroy()
                ScenarioInfo.M3RadarHalfTimerThread = false
            end
        end
    end
end

function M3OnBrackmanLabSpotted ()
    -- This can be called multiple times, we only want to trigger once
    if not ScenarioInfo.M3S1 then
    LOG('debugMatt:Brackmans lab damaged, spawn fleeing engineers')

    -- activate gateway
    -- IssueClearCommands({ScenarioInfo.M3Gate})
    -- IssueTransportUnload({ScenarioInfo.M3Gate}, ScenarioUtils.MarkerToPosition('M3_Engineer_Teleport'))

    ScenarioInfo.M3EngineersPlatoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M3_Fleeing_Engineers', 'TravellingFormation')

    ScenarioInfo.M3EngineersPlatoon:MoveToLocation(ScenarioUtils.MarkerToPosition('M3_Engineer_Escape_Spot'), false)

    -- turn on escape trigger
    ScenarioInfo.M3EscapedEngineerTrigger = ScenarioFramework.CreateAreaTrigger(M3OnEngineerAtGate, ScenarioUtils.AreaToRect('M2_Escape_Area'),
        (categories.url0309), true, false, ArmyBrains[ScenarioInfo.Cybran], 1, true)

    ScenarioFramework.Dialogue(OpStrings.E04_M03_110)
        ScenarioInfo.M3S1 = Objectives.KillOrCapture(
            'secondary',
            'incomplete',
            OpStrings.M3S1Title,
            OpStrings.M3S1Description,
            { Units = ScenarioInfo.M3EngineersPlatoon:GetPlatoonUnits() }
       )
        ScenarioInfo.M3S1:AddResultCallback(M3EngineersResult)
        ScenarioInfo.M3S1:AddProgressCallback(M3EngineerProgress)
        objGroup3s:AddObjective(ScenarioInfo.M3S1)
    end
end

function M3EngineerProgress(current,total)
    M3FleeingEngineersDestroyedCount = current
end

function M3EngineersResult(result)
    if not ScenarioInfo.OpEnded  then
        if result then
            ScenarioFramework.Dialogue(OpStrings.E04_M03_120)
        end
    end
end


function M3OnBrackmanLabDestroyed (result, unit)
    LOG('debugMatt:Brackmans lab destroyed!')
    ScenarioFramework.Dialogue(OpStrings.E04_M03_100)
    ScenarioFramework.KillBaseInArea(ArmyBrains[ScenarioInfo.Cybran],{'M3_Brackman_Base'})

-- set the camera up for brackman lab destroyed and op not over
    local camInfo = {
        blendTime = 1.0,
        holdTime = 4,
        orientationOffset = { -1.9, 0.2, 0 },
        positionOffset = { 0, 1, 0 },
        zoomVal = 30,
    }
    if Objectives.IsComplete(ScenarioInfo.M3P4) then
-- brackman lab destroyed and op over
--    ScenarioFramework.EndOperationCamera(unit, false)
        camInfo.blendTime = 2.50
        camInfo.holdTime = nil
        camInfo.orientationOffset[1] = 0
        camInfo.spinSpeed = 0.03
        camInfo.overrideCam = true
    end
    ScenarioFramework.OperationNISCamera(unit, camInfo)
end

function M3FrenzySpawnPlatoon()
    local groupName
    local group = Random(1,2)

    if (group == 1) then
        groupName = 'M3_Offscreen_Gunships_D'..Difficulty
    elseif (group == 2) then
        groupName = 'M3_Offscreen_Mixed_Bombers_D'..Difficulty
    end


    local frenzyPlatoon = ArmyBrains[ScenarioInfo.Cybran]:MakePlatoon(' ', ' ')
    for i = 1,M3FrenzyPlatoonCount do
        local tempUnits = ScenarioUtils.CreateArmyGroup('Cybran', groupName)
	    ArmyBrains[ScenarioInfo.Cybran]:AssignUnitsToPlatoon(frenzyPlatoon, tempUnits, 'Attack', 'AttackFormation')
    end

    local spawnpoint = ScenarioUtils.MarkerToPosition('M3_Spawn_Point_' .. Random(1, 3)..'_'..Random(1, 4))
    for counter, unit in frenzyPlatoon:GetPlatoonUnits() do
        Warp(unit, {spawnpoint[1] + Random(-20,20), spawnpoint[2], spawnpoint[3] + Random(-20,20)})
    end

    frenzyPlatoon:ForkAIThread(ScenarioPlatoonAI.PlatoonAttackHighestThreat)
end


function M3OnEngineerAtGate()

    -- IssueTransportLoad(ScenarioInfo.M3EngineersPlatoon:GetPlatoonUnits() , ScenarioInfo.M3Gate)
    IssueMove(ScenarioInfo.M3EngineersPlatoon:GetPlatoonUnits(), ScenarioUtils.MarkerToPosition('M3_Engineer_Escape_Spot'))

    ScenarioInfo.M3EscapedEngineerTeleportTrigger = ScenarioFramework.CreateAreaTrigger(M3OnEngineerEscaped, ScenarioUtils.AreaToRect('M3_Engineer_Teleport'),
        (categories.url0309), false, false, ArmyBrains[ScenarioInfo.Cybran], 1, true)
end

function M3OnEngineerEscaped(units)

    for k, eng in units do
        if not eng.GateStarted then
            eng.GateStarted = true
            M3FleeingEngineersEscapedCount = M3FleeingEngineersEscapedCount + 1
            LOG('debugMatt:Engineer Escaped, count: '..M3FleeingEngineersEscapedCount)

            -- eng:Destroy()
            ScenarioFramework.FakeTeleportUnit(eng,true)
        end
    end

    if ((M3FleeingEngineersEscapedCount + M3FleeingEngineersDestroyedCount) >= M3FleeingEngineersTotal) then
        ScenarioInfo.M3EscapedEngineerTeleportTrigger:Destroy()
        ScenarioInfo.M3S1:Fail()
    end
end

function M3OnFrenzyTimer()
    LOG('debugMatt:frenzy attack, count: '..M3FrenzyPlatoonCount)

    M3FrenzySpawnPlatoon()
    M3FrenzySpawnPlatoon()
    M3FrenzySpawnPlatoon()

    if (ScenarioInfo.M3P2Complete) then
    -- I'm not going to speed up the frezy until after the radars are done
        -- decrement the timer
        if (M3FrenzyTimer > M3FenzyMinTimer) then
            M3FrenzyTimer = M3FrenzyTimer - M3FrenzyTimerDec
        end


        -- increment the platoons built count for next round
        if ((M3FrenzyPlatoonCount + M3FrenzyPlatoonCountInc) < M3FrenzyPlatoonMax) then
            M3FrenzyPlatoonCount = M3FrenzyPlatoonCount + M3FrenzyPlatoonCountInc
        end
    end

    ScenarioFramework.CreateTimerTrigger(M3OnFrenzyTimer, M3FrenzyTimer)

end


function M3OnSpiderbotSpotted(blip)
    if not ScenarioInfo.OpEnded then
        ScenarioFramework.Dialogue(OpStrings.E04_M03_080)

        ScenarioInfo.M3P4 = Objectives.Kill(
            'primary',
            'incomplete',
            OpStrings.M3P4Title,
            OpStrings.M3P4Description,
            { Units = ScenarioInfo.M3SpiderbotPlatoon:GetPlatoonUnits(), }
       )
        ScenarioInfo.M3P4:AddResultCallback(
            function(result, unit)
                LOG('debugMatt:Spider Bot destroyed!')
                ScenarioFramework.Dialogue(OpStrings.E04_M03_090)
                if Objectives.IsComplete(ScenarioInfo.M3P3) then
-- spider bot killed camera?
--                ScenarioFramework.EndOperationCamera(unit, true)
                    local camInfo = {
                        blendTime = 2.50,
                        holdTime = nil,
                        orientationOffset = { math.pi, 0.1, 0 },
                        positionOffset = { 0, 0.5, 0 },
                        zoomVal = 25,
                        spinSpeed = 0.03,
                    	overrideCam = true,
                    }
                    ScenarioFramework.OperationNISCamera(unit, camInfo)

                end
            end
       )
        objGroup3:AddObjective(ScenarioInfo.M3P4)

    end
-- spiderbot spotted cam
    local unit = blip:GetSource()
    local camInfo = {
        blendTime = 1.0,
        holdTime = 4,
        orientationOffset = { math.pi, 0.1, 0 },
        positionOffset = { 0, 0.5, 0 },
        zoomVal = 25,
    }
    ScenarioFramework.OperationNISCamera(unit, camInfo)
end

-- === Win/Lose === #
function PlayerWin()
    LOG('debugMatt:Operation Complete')
    ScenarioFramework.EndOperationSafety()

    ScenarioFramework.Dialogue(OpStrings.E04_M03_130,false, true)
    ScenarioFramework.Dialogue(OpStrings.E04_M03_140, WinGame, true)

end

function PlayerLose(dialogueTable)
    ScenarioFramework.FlushDialogueQueue()
    ScenarioFramework.EndOperationSafety()
    if (dialogueTable) then
        ScenarioFramework.Dialogue(dialogueTable, LoseGame, true)
    else
        ForkThread(LoseGame)
    end
end

function OnCommanderDeath()
    -- ! If your Commander dies, you lose
    -- print('Commander Died')
    PlayerLose(OpStrings.E04_D01_010)
-- ScenarioFramework.EndOperationCamera(ScenarioInfo.PlayerCDR, false)
    ScenarioFramework.CDRDeathNISCamera(ScenarioInfo.PlayerCDR)
end

function WinGame()
    WaitSeconds(5)
    ScenarioInfo.OpComplete = true
    local secondaries = Objectives.IsComplete(ScenarioInfo.M3S1)

    --LOG ('debug matt: comleted mission '..'SCCA_Coop_E04'..ScenarioInfo.Options.Difficulty,secondaries)

    ScenarioFramework.EndOperation(ScenarioInfo.OpComplete, ScenarioInfo.OpComplete, secondaries)
end

function LoseGame()
    ScenarioInfo.OpComplete = false
    WaitSeconds(5)
    ScenarioFramework.EndOperation(ScenarioInfo.OpComplete, ScenarioInfo.OpComplete, false)
end
