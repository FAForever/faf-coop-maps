-- ****************************************************************************
-- **
-- **  File     :  /maps/SCCA_Coop_A03/SCCA_Coop_A03_script.lua
-- **  Author(s):  Jessica St. Croix
-- **
-- **  Summary  :
-- **
-- **  Copyright © 2006 Gas Powered Games, Inc.  All rights reserved.
-- ****************************************************************************
local Behaviors = import('/lua/ai/opai/OpBehaviors.lua')
local Objectives = import('/lua/ScenarioFramework.lua').Objectives
local OpStrings = import('/maps/SCCA_Coop_A03/SCCA_Coop_A03_strings.lua')
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioStrings = import('/lua/ScenarioStrings.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')

---------
-- Globals
---------
ScenarioInfo.Player = 1
ScenarioInfo.UEF = 2
ScenarioInfo.Eris = 3
ScenarioInfo.Coop1 = 4
ScenarioInfo.Coop2 = 5
ScenarioInfo.Coop3 = 6
ScenarioInfo.HumanPlayers = {}
ScenarioInfo.FirstWave = 1
ScenarioInfo.SecondWave = 4
ScenarioInfo.ThirdWave = 7

ScenarioInfo.VarTable = {}

-------------
-- Misc Locals
-------------

local Player = ScenarioInfo.Player
local Coop1 = ScenarioInfo.Coop1
local Coop2 = ScenarioInfo.Coop2
local Coop3 = ScenarioInfo.Coop3
local uef = ScenarioInfo.UEF
local eris = ScenarioInfo.Eris

-- Dialogue Timers
local M1VOTimer1 = 120
local M1VOTimer2 = 180
local M1VOTimer3 = 300
local M1VOTimer4 = 480
local M1VOTimer5 = 600
local M3VOTimer1 = 240
local M3VOTimer2 = 480
local M3VOTimer3 = 600
local M3VOTimer4 = 900

-- Objective Reminder Timers
local M2P1Time = 900
local M2P1Subsequent = 600
local M3P1Time = 1200
local M3P1Subsequent = 600

-- Prewave Timers
local M1PreWaveTimer1 = 180
local M1PreWaveTimer2 = 360

-- Time between major waves
local StartWave2Delay = 120
local StartWave3Delay = 120

-- Timer between minor waves
local AirWaveDelay = 60
local LandWaveDelay = 90
local NavalWaveDelay = 120

local arnoldTaunt = 1

local LeaderFaction
local LocalFaction

---------
-- Startup
---------
function OnPopulate(scenario)
    ScenarioUtils.InitializeScenarioArmies()
    LeaderFaction, LocalFaction = ScenarioFramework.GetLeaderAndLocalFactions()

    -- Eris
    ScenarioInfo.ErisCDR = ScenarioUtils.CreateArmyUnit('Eris', 'Eris')
    ScenarioInfo.ErisCDR:SetCustomName(LOC '{i CDR_Eris}')
    ScenarioInfo.ErisCDR:SetCanTakeDamage(false)
    ScenarioInfo.ErisCDR:SetCanBeKilled(false)
    ScenarioInfo.ErisCDR:SetReclaimable(false)
    ScenarioInfo.ErisCDR:SetCapturable(false)
    ScenarioInfo.ErisCDR:SetDoNotTarget(true)
    ScenarioInfo.ErisCDR:CreateEnhancement('Shield')
    ScenarioInfo.ErisCDR:CreateEnhancement('HeatSink')
    ScenarioInfo.ErisCDR:CreateEnhancement('CrysalisBeam')
    ScenarioInfo.ErisCDR:AdjustHealth(ScenarioInfo.ErisCDR, ScenarioInfo.ErisCDR:GetHealth() * -.8)

    ScenarioInfo.ErisBase = ScenarioUtils.CreateArmyGroup('Eris', 'Base')
    for k, v in ScenarioInfo.ErisBase do
        v:AdjustHealth(v, Random(0, v:GetHealth()/3) * -ScenarioInfo.Options.Difficulty)
    end
    ScenarioInfo.ErisEngineers = ScenarioUtils.CreateArmyGroup('Eris', 'Engineers')
    for k, v in ScenarioInfo.ErisEngineers do
        v:AdjustHealth(v, Random(0, v:GetHealth()/3) * -ScenarioInfo.Options.Difficulty)
    end
    ScenarioInfo.ErisLandPatrol = ScenarioUtils.CreateArmyGroupAsPlatoon('Eris', 'LandUnits', 'AttackFormation')
    for k, v in ScenarioInfo.ErisLandPatrol:GetPlatoonUnits() do
        v:AdjustHealth(v, Random(0, v:GetHealth()/3) * -ScenarioInfo.Options.Difficulty)
    end
    ScenarioInfo.ErisLandPatrol.PlatoonData = {}
    ScenarioInfo.ErisLandPatrol.PlatoonData.PatrolChain = 'PlayerBase_Chain'
    ScenarioPlatoonAI.PatrolThread(ScenarioInfo.ErisLandPatrol)
    ScenarioInfo.ErisNavyPatrol = ScenarioUtils.CreateArmyGroupAsPlatoon('Eris', 'NavalUnits', 'AttackFormation')
    for k, v in ScenarioInfo.ErisNavyPatrol:GetPlatoonUnits() do
        v:AdjustHealth(v, Random(0, v:GetHealth()/3) * -ScenarioInfo.Options.Difficulty)
    end
    ScenarioInfo.ErisNavyPatrol.PlatoonData = {}
    ScenarioInfo.ErisNavyPatrol.PlatoonData.PatrolChain = 'Navy_Chain'
    ScenarioPlatoonAI.PatrolThread(ScenarioInfo.ErisNavyPatrol)

    -- Give UEF vision of player base
    ScenarioInfo.UEFViz = ScenarioFramework.CreateVisibleAreaLocation(100,
        ScenarioUtils.MarkerToPosition('Player'), 0, ArmyBrains[uef])
end

function OnStart(self)
    -- Adjust buildable categories for Player
    for _, player in ScenarioInfo.HumanPlayers do
         ScenarioFramework.AddRestriction(player, ((categories.TECH2 + categories.TECH3) * categories.AEON) +     -- T2 & T3 Aeon
                                     (categories.TECH3 * categories.UEF) +                           -- T3 UEF
                                     categories.uea0204 +                                            -- UEF Torpedo Bomber
                                     categories.uel0203 +                                            -- UEF Amphibious Tank
                                     categories.ues0202)                                             -- UEF Cruiser
    end

    ScenarioFramework.RemoveRestrictionForAllHumans(
        categories.uab0202 +    -- T2 Air Factory
        categories.zab9502 +    -- T2 Support Air Factory
        categories.ual0208 +    -- T2 Engineer
        categories.uaa0204 +    -- T2 Torpedo Bomber
        categories.uab1201 +    -- T2 Power Generator
        categories.uab1202 +    -- T2 Mass Extractor
        categories.uab2204 +    -- T2 AA Tower
        categories.uab2205 +    -- T2 Torpedo Tower
        categories.uab2301 +    -- T2 Point Defense
        categories.uab3201 +    -- T2 Radar
        categories.uab3202      -- T2 Sonar
    )

    ScenarioFramework.AddRestriction(uef, categories.TECH3 +    -- T3
                             categories.uea0204 +  -- Torpedo Bomber
                             categories.uel0203 +  -- Amphibious Tank
                             categories.ues0202)   -- Cruiser

    -- Player has access to HeatSink, CrysalisBeam, ResourceAllocation, Shield, EnhancedSensors and AdvancedEngineering
    ScenarioFramework.RestrictEnhancements({'ChronoDampener',
                                            'ResourceAllocationAdvanced',
                                            'T3Engineering',
                                            'ShieldHeavy',
                                            'Teleporter'})

    SetIgnorePlayableRect(uef, true)
    SetIgnorePlayableRect(eris, true)

    -- Army colors
    ScenarioFramework.SetAeonColor(Player)
    ScenarioFramework.SetUEFColor(uef)
    ScenarioFramework.SetAeonAllyColor(eris)

    ScenarioFramework.SetPlayableArea('M1Area', false)
    ScenarioFramework.StartOperationJessZoom('CDRZoom', IntroMission1)
end

----------
-- End Game
----------
function PlayerWin()
    if(not ScenarioInfo.OpEnded) then
        ScenarioFramework.EndOperationSafety()
        ScenarioInfo.OpComplete = true
-- Arnold Killed
--    ScenarioFramework.EndOperationCamera(ScenarioInfo.ArnoldCDR)
        ScenarioFramework.CDRDeathNISCamera(ScenarioInfo.ArnoldCDR)
        ScenarioFramework.CreateVisibleAreaAtUnit(60, ScenarioInfo.ArnoldCDR, 0, ArmyBrains[Player])
        CreateLightParticle(ScenarioInfo.ArnoldCDR, -1, -1, 60, 6000, 'glow_03', 'ramp_orange_02')
        CreateEmitterAtEntity(ScenarioInfo.ArnoldCDR, -1, '/effects/emitters/a3_end_nis_01_emit.bp')
        CreateEmitterAtEntity(ScenarioInfo.ArnoldCDR, -1, '/effects/emitters/a3_end_nis_02_emit.bp')
        ScenarioFramework.Dialogue(OpStrings.A03_M03_090, StartKillGame, true)
    end
end

function PlayerLose(deadCommander)
    ScenarioFramework.PlayerDeath(deadCommander, OpStrings.A03_D01_010)
end

function StartKillGame()
    ForkThread(KillGame)
end

function KillGame()
    if(not ScenarioInfo.OpComplete) then
        WaitSeconds(15)
    end
    local secondaries = Objectives.IsComplete(ScenarioInfo.M2S1) and Objectives.IsComplete(ScenarioInfo.M2S2) and Objectives.IsComplete(ScenarioInfo.M2S3)
    ScenarioFramework.EndOperation(ScenarioInfo.OpComplete, ScenarioInfo.OpComplete, secondaries)
end

-----------
-- Mission 1
-----------
function IntroMission1()
    ScenarioInfo.MissionNumber = 1

    -- Player CDR
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

    ScenarioFramework.PauseUnitDeath(ScenarioInfo.PlayerCDR)

    for index, coopACU in ScenarioInfo.CoopCDR do
        ScenarioFramework.PauseUnitDeath(coopACU)
        ScenarioFramework.CreateUnitDeathTrigger(PlayerLose, coopACU)
    end
    ScenarioFramework.CreateUnitDeathTrigger(PlayerLose, ScenarioInfo.PlayerCDR)
    WaitSeconds(2)
    IssueMove({ScenarioInfo.ErisCDR}, ScenarioUtils.MarkerToPosition('Player'))
    ScenarioFramework.Dialogue(OpStrings.A03_M01_010, StartMission1)
    WaitSeconds(10)
    ForkThread(ErisLeaves)
end

function StartMission1()
    -- Hand over Eris' base
    local currentHealth = 0
    local originalHealth = 0
    local unit = nil
    local platoon = nil
    for k, v in ScenarioInfo.ErisBase do
        if(not v:IsDead()) then
            unit = ScenarioFramework.GiveUnitToArmy(v, Player)
        end
    end

    for k, v in ScenarioInfo.ErisEngineers do
        if(not v:IsDead()) then
            currentHealth = v:GetHealth()
            originalHealth = v:GetBlueprint().Defense.Health
            unit = ScenarioFramework.GiveUnitToArmy(v, Player)
            unit:AdjustHealth(unit, currentHealth - originalHealth)
        end
    end

    platoon = ArmyBrains[eris]:MakePlatoon('', '')
    for k, v in ScenarioInfo.ErisLandPatrol:GetPlatoonUnits() do
        if(not v:IsDead()) then
            currentHealth = v:GetHealth()
            originalHealth = v:GetBlueprint().Defense.Health
            unit = ScenarioFramework.GiveUnitToArmy(v, Player)
            unit:AdjustHealth(unit, currentHealth - originalHealth)
            ArmyBrains[eris]:AssignUnitsToPlatoon(platoon, {unit}, 'attack', 'AttackFormation')
        end
    end
    platoon.PlatoonData = {}
    platoon.PlatoonData.PatrolChain = 'PlayerBase_Chain'
    ScenarioPlatoonAI.PatrolThread(platoon)

    platoon = ArmyBrains[eris]:MakePlatoon('', '')
    for k, v in ScenarioInfo.ErisNavyPatrol:GetPlatoonUnits() do
        if(not v:IsDead()) then
            currentHealth = v:GetHealth()
            originalHealth = v:GetBlueprint().Defense.Health
            unit = ScenarioFramework.GiveUnitToArmy(v, Player)
            unit:AdjustHealth(unit, currentHealth - originalHealth)
            ArmyBrains[eris]:AssignUnitsToPlatoon(platoon, {unit}, 'attack', 'AttackFormation')
        end
    end
    platoon.PlatoonData = {}
    platoon.PlatoonData.PatrolChain = 'Navy_Chain'
    ScenarioPlatoonAI.PatrolThread(platoon)

    -- After 2 minutes
    ScenarioFramework.CreateTimerTrigger(M1Dialogue1, M1VOTimer1)

    -- After 3 minutes
    ScenarioFramework.CreateTimerTrigger(M1Dialogue2, M1VOTimer2)
    ScenarioFramework.CreateTimerTrigger(PreWave, M1PreWaveTimer1)

    -- After 5 minutes
    ScenarioFramework.CreateTimerTrigger(M1Dialogue3, M1VOTimer3)

    -- After 6 minutes
    ScenarioFramework.CreateTimerTrigger(PreWave, M1PreWaveTimer2)

    -- After 8 minutes
    ScenarioFramework.CreateTimerTrigger(M1Dialogue4, M1VOTimer4)

    -- After 10 minutes
    ScenarioFramework.CreateTimerTrigger(M1Dialogue5, M1VOTimer5)

    -- Primary Objective 1
    ScenarioInfo.M1P1 = Objectives.Basic(
        'primary',                          -- type
        'incomplete',                       -- complete
        OpStrings.OpA03_M1P1_Title,         -- title
        OpStrings.OpA03_M1P1_Desc,          -- description
        Objectives.GetActionIcon('kill'),   -- action
        {
            ShowFaction = 'UEF',
        }                                  -- target
   )

    -- Start taunts
    ScenarioFramework.CreateTimerTrigger(Taunt, Random(600, 900))
end

function ErisLeaves()
    if(not ScenarioInfo.OpEnded) then
        -- Transport Eris
        ScenarioInfo.Escort = ScenarioUtils.CreateArmyGroupAsPlatoon('Eris', 'TransportEscort', 'ChevronFormation')
        for k, v in ScenarioInfo.Escort:GetPlatoonUnits() do
            v:SetCanTakeDamage(false)
            v:SetCanBeKilled(false)
            v:SetReclaimable(false)
            v:SetCapturable(false)
            v:SetDoNotTarget(true)
        end
        ScenarioInfo.Escort:MoveToLocation(ScenarioUtils.MarkerToPosition('Player'), false)
        WaitSeconds(10)
        ScenarioInfo.Transport = ScenarioUtils.CreateArmyUnit('Eris', 'Transport')
        ScenarioInfo.Transport:SetCanTakeDamage(false)
        ScenarioInfo.Transport:SetCanBeKilled(false)
        ScenarioInfo.Transport:SetReclaimable(false)
        ScenarioInfo.Transport:SetCapturable(false)
        ScenarioInfo.Transport:SetDoNotTarget(true)
        IssueTransportLoad({ScenarioInfo.ErisCDR}, ScenarioInfo.Transport)
        IssueTransportUnload({ScenarioInfo.Transport}, ScenarioUtils.MarkerToPosition('ErisDeath'))
        ScenarioFramework.CreateAreaTrigger(KillEris, ScenarioUtils.AreaToRect('ErisDeath'), categories.AEON,
            true, false, ArmyBrains[eris], 11)

        ScenarioInfo.Escort:MoveToLocation(ScenarioUtils.MarkerToPosition('ErisDeath'), false)
    end
end

function KillEris()
    ScenarioInfo.Escort:Destroy()
    ScenarioInfo.ErisCDR:Destroy()
    ScenarioInfo.Transport:Destroy()
end

function Taunt()
    if(arnoldTaunt <= 8) then
        ScenarioFramework.Dialogue(OpStrings['TAUNT' .. arnoldTaunt])
        arnoldTaunt = arnoldTaunt + 1
        ScenarioFramework.CreateTimerTrigger(Taunt, Random(600, 900))
    end
end

function M1Dialogue1()
    ScenarioFramework.Dialogue(OpStrings.A03_M01_020)
end

function M1Dialogue2()
    ScenarioFramework.Dialogue(OpStrings.A03_M01_030)
end

function M1Dialogue3()
    ScenarioFramework.Dialogue(OpStrings.A03_M01_040)
end

function M1Dialogue4()
    ScenarioFramework.Dialogue(OpStrings.A03_M01_060)
end

function M1Dialogue5()
    ScenarioFramework.Dialogue(OpStrings.A03_M01_070)
    ForkThread(FirstWave)
end

function PreWave()
    for i = 1, ScenarioInfo.Options.Difficulty do
        local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'PreWave_D' .. i, 'ChevronFormation')
        platoon.PlatoonData = {}
        platoon.PlatoonData.PatrolChain = 'ErisAll_Chain'
        platoon:ForkAIThread(ScenarioPlatoonAI.RandomPatrolThread)
    end
end

function FirstWave()
    if(ScenarioInfo.FirstWave < 4) then
        for i = 1, ScenarioInfo.Options.Difficulty do
            local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M1Wave' .. ScenarioInfo.FirstWave .. '_D' .. i, 'ChevronFormation')
            platoon.PlatoonData = {}
            platoon.PlatoonData.PatrolChain = 'ErisAll_Chain'
            platoon:ForkAIThread(ScenarioPlatoonAI.RandomPatrolThread)
        end
        ScenarioInfo.FirstWave = ScenarioInfo.FirstWave + 1
        ScenarioFramework.CreateTimerTrigger(FirstWave, AirWaveDelay)
    else
        ScenarioFramework.CreateAreaTrigger(FirstWaveDefeated, ScenarioUtils.AreaToRect('M1Area'), categories.ALLUNITS,
            true, true, ArmyBrains[uef])
    end
end

function FirstWaveDefeated()
    ForkThread(FirstWaveDefeatedDialogue)
    ScenarioFramework.CreateTimerTrigger(SecondWave, StartWave2Delay)

    -- Set up trigger to kill transports used in following waves
    ScenarioInfo.DestroyTrigger = ScenarioFramework.CreateAreaTrigger(DestroyUnit, ScenarioUtils.AreaToRect('ErisDeath'), categories.UEF,
        false, false, ArmyBrains[uef])
end

function FirstWaveDefeatedDialogue()
    WaitSeconds(5)
    ScenarioFramework.Dialogue(OpStrings.A03_M01_080)
    ScenarioFramework.Dialogue(OpStrings.A03_M01_090)
end

function DestroyUnit(unit)
    unit:Destroy()
end

function SecondWave()
    if(ScenarioInfo.SecondWave < 7) then
        for i = 1, ScenarioInfo.Options.Difficulty do
            local airPlatoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M1Wave' .. ScenarioInfo.SecondWave .. '_Air_D' .. i, 'ChevronFormation')
            airPlatoon.PlatoonData = {}
            airPlatoon.PlatoonData.PatrolChain = 'ErisAll_Chain'
            airPlatoon:ForkAIThread(ScenarioPlatoonAI.RandomPatrolThread)
            local landPlatoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M1Wave' .. ScenarioInfo.SecondWave .. '_Land_D' .. i, 'AttackFormation')
            local transport = ScenarioUtils.CreateArmyGroup('UEF', 'M1Wave' .. ScenarioInfo.SecondWave .. '_Transport_D' .. i)
            ScenarioFramework.AttachUnitsToTransports(landPlatoon:GetPlatoonUnits(), transport)
            IssueTransportUnload(transport, ScenarioPlatoonAI.PlatoonChooseRandomNonNegative(ArmyBrains[uef], ScenarioUtils.ChainToPositions('ErisLand_Chain'), 2))
            IssueMove(transport, ScenarioUtils.MarkerToPosition('ErisDeath'))
            landPlatoon.PlatoonData = {}
            landPlatoon.PlatoonData.PatrolChain = 'ErisLand_Chain'
            landPlatoon:ForkAIThread(ScenarioPlatoonAI.RandomPatrolThread)
        end
        ScenarioInfo.SecondWave = ScenarioInfo.SecondWave + 1
        ScenarioFramework.CreateTimerTrigger(SecondWave, LandWaveDelay)
    else
        ScenarioFramework.CreateAreaTrigger(SecondWaveDefeated, ScenarioUtils.AreaToRect('M1Area'), categories.ALLUNITS,
            true, true, ArmyBrains[uef])
    end
end

function SecondWaveDefeated()
    ForkThread(SecondWaveDefeatedDialogue)
    ScenarioFramework.CreateTimerTrigger(ThirdWave, StartWave3Delay)
end

function SecondWaveDefeatedDialogue()
    WaitSeconds(5)
    ScenarioFramework.Dialogue(OpStrings.A03_M01_100)
    ScenarioFramework.Dialogue(OpStrings.A03_M01_110)
end

function ThirdWave()
    if(ScenarioInfo.ThirdWave < 11) then
        for i = 1, ScenarioInfo.Options.Difficulty do
            for j = 1, 2 do
                local airPlatoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M1Wave' .. ScenarioInfo.ThirdWave .. '_Air_D' .. i, 'ChevronFormation')
                airPlatoon.PlatoonData = {}
                airPlatoon.PlatoonData.PatrolChain = 'ErisAll_Chain'
                airPlatoon:ForkAIThread(ScenarioPlatoonAI.RandomPatrolThread)
            end
            local navyPlatoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M1Wave' .. ScenarioInfo.ThirdWave .. '_Navy_D' .. i, 'AttackFormation')
            navyPlatoon.PlatoonData = {}
            navyPlatoon.PlatoonData.PatrolChain = 'ErisNavy_Chain' .. i
            navyPlatoon:ForkAIThread(ScenarioPlatoonAI.PatrolThread)
            if(ScenarioInfo.ThirdWave == 10) then
                local landPlatoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M1Wave' .. ScenarioInfo.ThirdWave .. '_Land_D' .. i, 'AttackFormation')
                local transport = ScenarioUtils.CreateArmyGroup('UEF', 'M1Wave' .. ScenarioInfo.ThirdWave .. '_Transport_D' .. i)
                ScenarioFramework.AttachUnitsToTransports(landPlatoon:GetPlatoonUnits(), transport)
                IssueTransportUnload(transport, ScenarioPlatoonAI.PlatoonChooseRandomNonNegative(ArmyBrains[uef], ScenarioUtils.ChainToPositions('ErisLand_Chain'), 2))
                IssueMove(transport, ScenarioUtils.MarkerToPosition('ErisDeath'))
                landPlatoon.PlatoonData = {}
                landPlatoon.PlatoonData.PatrolChain = 'ErisLand_Chain'
                landPlatoon:ForkAIThread(ScenarioPlatoonAI.RandomPatrolThread)
            end
        end
        ScenarioInfo.ThirdWave = ScenarioInfo.ThirdWave + 1
        ScenarioFramework.CreateTimerTrigger(ThirdWave, NavalWaveDelay)
    else
        ScenarioFramework.CreateAreaTrigger(ThirdWaveDefeated, ScenarioUtils.AreaToRect('M1Area'), categories.ALLUNITS,
            true, true, ArmyBrains[uef])
    end
end

function ThirdWaveDefeated()
    ForkThread(M1P1Complete)
end

function M1P1Complete()
    WaitSeconds(5)
    ScenarioFramework.Dialogue(OpStrings.A03_M01_120, IntroMission2)
    ScenarioInfo.M1P1:ManualResult(true)
    ScenarioInfo.DestroyTrigger:Destroy()
end

-----------
-- Mission 2
-----------
function IntroMission2()
    ScenarioInfo.MissionNumber = 2
    ScenarioInfo.UEFViz:Destroy()

    -- Adjust buildable categories for player
    ScenarioFramework.RemoveRestrictionForAllHumans(
        categories.uab0203 +    -- T2 Naval Factory
        categories.zab9503 +    -- T2 Support Naval Factory
        categories.uas0201 +    -- Destroyer
        categories.uaa0203      -- T2 Gunship
    )

    -- Land Base
    ScenarioUtils.CreateArmyGroup('UEF', 'LandBasePreBuilt_D' .. ScenarioInfo.Options.Difficulty)
    for i = 1, ScenarioInfo.Options.Difficulty do
        local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'LandBasePatrol_D' .. i, 'AttackFormation')
        platoon.PlatoonData = {}
        platoon.PlatoonData.PatrolChain = 'LandBase_Chain'
        platoon:ForkAIThread(ScenarioPlatoonAI.RandomPatrolThread)
    end

    -- Air Base
    ScenarioUtils.CreateArmyGroup('UEF', 'AirBasePreBuilt_D' .. ScenarioInfo.Options.Difficulty)
    local airPatrol = ScenarioUtils.CreateArmyGroup('UEF', 'AirBasePatrol_D' .. ScenarioInfo.Options.Difficulty)
    for k, v in airPatrol do
        local chain = ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('AirBaseAir_Chain'))
        for i = 1, table.getn(chain) do
            IssuePatrol({v}, chain[i])
        end
    end

    -- Naval Base
    ScenarioUtils.CreateArmyGroup('UEF', 'NavalBasePreBuilt_D' .. ScenarioInfo.Options.Difficulty)
    local navyPatrol = ScenarioUtils.CreateArmyGroup('UEF', 'NavalBasePatrol_D' .. ScenarioInfo.Options.Difficulty)
    for k, v in navyPatrol do
        local platoon = ArmyBrains[uef]:MakePlatoon('','')
        ArmyBrains[uef]:AssignUnitsToPlatoon(platoon, {v}, 'attack', 'AttackFormation')
        platoon.PlatoonData = {}
        platoon.PlatoonData.PatrolChain = 'NavyBaseSea_Chain'
        platoon:ForkAIThread(ScenarioPlatoonAI.RandomPatrolThread)
    end

    ScenarioInfo.ArnoldCDR = ScenarioUtils.CreateArmyUnit('UEF', 'Arnold')
    ScenarioInfo.ArnoldCDR:SetCustomName(LOC '{i CDR_Arnold}')
    ScenarioInfo.ArnoldCDR:SetCanBeKilled(false)
    ScenarioInfo.ArnoldCDR:CreateEnhancement('DamageStablization')
    ScenarioInfo.ArnoldCDR:CreateEnhancement('HeavyAntiMatterCannon')
    ScenarioInfo.ArnoldCDR:CreateEnhancement('Shield')
    ScenarioFramework.CreateUnitDamagedTrigger(ArnoldDamaged1, ScenarioInfo.ArnoldCDR, .5)
    ScenarioInfo.CDRPlatoon = ArmyBrains[uef]:MakePlatoon('','')
    ArmyBrains[uef]:AssignUnitsToPlatoon(ScenarioInfo.CDRPlatoon, {ScenarioInfo.ArnoldCDR}, 'Attack', 'AttackFormation')
    ScenarioInfo.CDRPlatoon:ForkAIThread(CDRAINavy)
    ScenarioInfo.CDRPlatoon.CDRData = {}
    ScenarioInfo.CDRPlatoon.CDRData.LeashPosition = 'UEFNavyBase'
    ScenarioInfo.CDRPlatoon.CDRData.LeashRadius = 50
    ScenarioInfo.CDRPlatoon:ForkThread(Behaviors.CDROverchargeBehavior)

    ScenarioFramework.Dialogue(OpStrings.A03_M02_010, StartMission2)
end

function StartMission2()
    -- Primary Objective 1
    ScenarioInfo.M2P1 = Objectives.Basic(
        'primary',                          -- type
        'incomplete',                       -- complete
        OpStrings.OpA03_M2P1_Title,         -- title
        OpStrings.OpA03_M2P1_Desc,          -- description
        Objectives.GetActionIcon('kill'),   -- action
        {                                   -- target
            Units = {ScenarioInfo.ArnoldCDR},
        }
   )

    -- M2P1 Objective Reminder
    ScenarioFramework.CreateTimerTrigger(M2P1Reminder1, M2P1Time)

    -- Secondary Objective 1: Land Base Destroyed
    ScenarioInfo.M2S1 = Objectives.CategoriesInArea(
        'secondary',                    -- type
        'incomplete',                   -- complete
        OpStrings.OpA03_M2S1_Title,     -- title
        OpStrings.OpA03_M2S1_Desc,      -- description
        'kill',                         -- action
        {                               -- target
            MarkArea = false,
            ShowFaction = 'UEF',
            Requirements = {
                {
                    Area = 'LandBase',
                    ArmyIndex = uef,
                    Category = categories.UEF * categories.STRUCTURE - categories.WALL,
                    CompareOp = '==',
                    Value = 0,
                },
            },
        }
   )
    ScenarioInfo.M2S1:AddResultCallback(
        function()
            ScenarioFramework.Dialogue(OpStrings.A03_M02_060)

-- land base destroyed
            local unit = ScenarioUtils.MarkerToPosition("UEFLandBase")
            local camInfo = {
                blendTime = 1,
                holdTime = 5,
                orientationOffset = { 0.8, 0.1, 0 },
                positionOffset = { 0, 0, 0 },
                zoomVal = 55,
                markerCam = true,
            }
            ScenarioFramework.OperationNISCamera(unit, camInfo)
        end
   )

    -- Secondary Objective 2: Air Base Destroyed
    ScenarioInfo.M2S2 = Objectives.CategoriesInArea(
        'secondary',                    -- type
        'incomplete',                   -- complete
        OpStrings.OpA03_M2S2_Title,     -- title
        OpStrings.OpA03_M2S2_Desc,      -- description
        'kill',                         -- action
        {                               -- target
            MarkArea = false,
            ShowFaction = 'UEF',
            Requirements = {
                {
                    Area = 'AirBase',
                    ArmyIndex = uef,
                    Category = categories.UEF * categories.STRUCTURE - categories.WALL,
                    CompareOp = '==',
                    Value = 0,
                },
            },
        }
   )
    ScenarioInfo.M2S2:AddResultCallback(
        function()
            ScenarioFramework.Dialogue(OpStrings.A03_M02_070)

-- air base destroyed
            local unit = ScenarioUtils.MarkerToPosition("UEFAirBase")
            local camInfo = {
                blendTime = 1,
                holdTime = 5,
                orientationOffset = { 2.456, 0.3, 0 },
                positionOffset = { 0, 0, 0 },
                zoomVal = 45,
                markerCam = true,
            }
            ScenarioFramework.OperationNISCamera(unit, camInfo)
        end
   )

    -- Secondary Objective 3: Naval Base Destroyed
    ScenarioInfo.M2S3 = Objectives.CategoriesInArea(
        'secondary',                    -- type
        'incomplete',                   -- complete
        OpStrings.OpA03_M2S3_Title,     -- title
        OpStrings.OpA03_M2S3_Desc,      -- description
        'kill',                         -- action
        {                               -- target
            MarkArea = false,
            ShowFaction = 'UEF',
            Requirements = {
                {
                    Area = 'NavalBase',
                    ArmyIndex = uef,
                    Category = categories.UEF * categories.STRUCTURE - categories.WALL,
                    CompareOp = '==',
                    Value = 0,
                },
            },
        }
   )
    ScenarioInfo.M2S3:AddResultCallback(
        function()
            ScenarioFramework.Dialogue(OpStrings.A03_M02_080)

-- naval base destroyed
            local unit = ScenarioUtils.MarkerToPosition("UEFNavyBaseCam")
            local camInfo = {
                blendTime = 1,
                holdTime = 5,
                orientationOffset = { -2.5, 0.3, 0 },
                positionOffset = { 0, 1.5, 0 },
                zoomVal = 50,
                markerCam = true,
            }
            ScenarioFramework.OperationNISCamera(unit, camInfo)
        end
   )

    ScenarioFramework.SetPlayableArea('M2Area')
    ScenarioFramework.CreateTimerTrigger(ArnoldNavyVO, 60)
end

function CDRAINavy(platoon)
    ScenarioInfo.VarTable['ArnoldNavy'] = true
    ScenarioInfo.VarTable['ArnoldAir'] = false
    ScenarioInfo.VarTable['ArnoldLand'] = false
    ScenarioInfo.VarTable['ArnoldMain'] = false
    platoon.PlatoonData.LocationType = 'UEFNavyBase'
    platoon:PatrolLocationFactoriesAI()
end

function ArnoldNavyVO()
    if(not ScenarioInfo.ArnoldDamaged1) then
        ScenarioFramework.Dialogue(OpStrings.A03_M02_050)
    end
end

function ArnoldDamaged1()
    ScenarioInfo.ArnoldDamaged1 = true
    if(ScenarioInfo.ArnoldCDR:GetHealth() <= 2400) then
        ArnoldDamaged2()
    elseif(ScenarioInfo.M2S1.Active) then
        ForkThread(TeleportLandBase)
    elseif(ScenarioInfo.M2S2.Active) then
        ForkThread(TeleportAirBase)
    else
        ArnoldDamaged2()
    end
end

function TeleportLandBase()
    ScenarioInfo.ArnoldCDR:SetCanTakeDamage(false)
    ScenarioFramework.FakeTeleportUnit(ScenarioInfo.ArnoldCDR)
    Warp(ScenarioInfo.ArnoldCDR, ScenarioUtils.MarkerToPosition('UEFLandBase'))
    ScenarioFramework.CreateUnitDamagedTrigger(ArnoldDamaged2, ScenarioInfo.ArnoldCDR, .8)
    ScenarioInfo.ArnoldCDR:SetCanTakeDamage(true)
    WaitSeconds(2)
    ScenarioInfo.CDRPlatoon.CDRData.LeashPosition = 'UEFLandBase'
    ScenarioInfo.CDRPlatoon.CDRData.LeashRadius = 50
    ScenarioInfo.CDRPlatoon:StopAI()
    ScenarioInfo.CDRPlatoon:ForkAIThread(CDRAILand)
    ScenarioFramework.Dialogue(OpStrings.A03_M02_020)
    ScenarioFramework.CreateTimerTrigger(ArnoldLandVO, 60)
end

function TeleportAirBase()
    ScenarioInfo.ArnoldCDR:SetCanTakeDamage(false)
    ScenarioFramework.FakeTeleportUnit(ScenarioInfo.ArnoldCDR)
    Warp(ScenarioInfo.ArnoldCDR, ScenarioUtils.MarkerToPosition('UEFAirBase'))
    ScenarioFramework.CreateUnitDamagedTrigger(ArnoldDamaged2, ScenarioInfo.ArnoldCDR, .8)
    ScenarioInfo.ArnoldCDR:SetCanTakeDamage(true)
    WaitSeconds(2)
    ScenarioInfo.CDRPlatoon.CDRData.LeashPosition = 'UEFAirBase'
    ScenarioInfo.CDRPlatoon.CDRData.LeashRadius = 50
    ScenarioInfo.CDRPlatoon:StopAI()
    ScenarioInfo.CDRPlatoon:ForkAIThread(CDRAIAir)
    ScenarioFramework.Dialogue(OpStrings.A03_M02_020)
    ScenarioFramework.CreateTimerTrigger(ArnoldAirVO, 60)
end

function CDRAILand(platoon)
    ScenarioInfo.VarTable['ArnoldNavy'] = false
    ScenarioInfo.VarTable['ArnoldAir'] = false
    ScenarioInfo.VarTable['ArnoldLand'] = true
    ScenarioInfo.VarTable['ArnoldMain'] = false
    platoon.PlatoonData.LocationType = 'UEFLandBase'
    platoon:PatrolLocationFactoriesAI()
end

function CDRAIAir(platoon)
    ScenarioInfo.VarTable['ArnoldNavy'] = false
    ScenarioInfo.VarTable['ArnoldAir'] = true
    ScenarioInfo.VarTable['ArnoldLand'] = false
    ScenarioInfo.VarTable['ArnoldMain'] = false
    platoon.PlatoonData.LocationType = 'UEFAirBase'
    platoon:PatrolLocationFactoriesAI()
end

function ArnoldLandVO()
    if(not ScenarioInfo.ArnoldDamaged2) then
        ScenarioFramework.Dialogue(OpStrings.A03_M02_030)
    end
end

function ArnoldAirVO()
    if(not ScenarioInfo.ArnoldDamaged2) then
        ScenarioFramework.Dialogue(OpStrings.A03_M02_040)
    end
end

function ArnoldDamaged2()
    ScenarioInfo.ArnoldDamaged2 = true
    ForkThread(TeleportMainBase)
end

function TeleportMainBase()
    ScenarioInfo.ArnoldCDR:SetCanTakeDamage(false)
    ScenarioFramework.FakeTeleportUnit(ScenarioInfo.ArnoldCDR)
    Warp(ScenarioInfo.ArnoldCDR, ScenarioUtils.MarkerToPosition('UEFMainBase'))
    ScenarioInfo.ArnoldCDR:SetCanTakeDamage(true)
    ScenarioInfo.CDRPlatoon.CDRData.LeashPosition = 'UEFMainBase'
    ScenarioInfo.CDRPlatoon.CDRData.LeashRadius = 70
    ScenarioInfo.CDRPlatoon:StopAI()
    ScenarioInfo.CDRPlatoon:ForkAIThread(CDRAIMain)
    ScenarioFramework.Dialogue(OpStrings.A03_M02_090, IntroMission3)
    ScenarioInfo.M2P1:ManualResult(true)
end

function CDRAIMain(platoon)
    ScenarioInfo.VarTable['ArnoldNavy'] = false
    ScenarioInfo.VarTable['ArnoldAir'] = false
    ScenarioInfo.VarTable['ArnoldLand'] = false
    ScenarioInfo.VarTable['ArnoldMain'] = true
    platoon.PlatoonData.LocationType = 'UEFMainBase'
    platoon:PatrolLocationFactoriesAI()
end

function M2P1Reminder1()
    if(ScenarioInfo.M2P1.Active) then
        ScenarioFramework.Dialogue(OpStrings.A03_M02_100)
        ScenarioFramework.CreateTimerTrigger(M2P1Reminder2, M2P1Subsequent)
    end
end

function M2P1Reminder2()
    if(ScenarioInfo.M2P1.Active) then
        ScenarioFramework.Dialogue(OpStrings.A03_M02_105)
        ScenarioFramework.CreateTimerTrigger(M2P1Reminder3, M2P1Subsequent)
    end
end

function M2P1Reminder3()
    if(ScenarioInfo.M2P1.Active) then
        ScenarioFramework.Dialogue(ScenarioStrings.AeonGenericReminder)
        ScenarioFramework.CreateTimerTrigger(M2P1Reminder1, M2P1Subsequent)
    end
end

-----------
-- Mission 3
-----------
function IntroMission3()
    ScenarioInfo.MissionNumber = 3

    -- Adjust buildable categories for player
    ScenarioFramework.RemoveRestrictionForAllHumans(categories.uas0202)  -- Cruiser

    -- Main Base
    ScenarioUtils.CreateArmyGroup('UEF', 'MainBasePreBuilt_D' .. ScenarioInfo.Options.Difficulty)
    ScenarioInfo.NavalAttack = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'NavalAttack_D' .. ScenarioInfo.Options.Difficulty, 'NoFormation')
    ScenarioInfo.NavalAttack.PlatoonData = {}
    ScenarioInfo.NavalAttack.PlatoonData.PatrolChain = 'MainBaseNaval_Chain'
    ScenarioInfo.NavalAttack:ForkAIThread(ScenarioPlatoonAI.RandomPatrolThread)
    ScenarioFramework.CreatePlatoonDeathTrigger(NavalAttackDestroyed, ScenarioInfo.NavalAttack)

    -- Naval Patrol
    local navalPatrol = ScenarioUtils.CreateArmyGroup('UEF', 'MainBaseNavyPatrol_D' .. ScenarioInfo.Options.Difficulty)
    for k, v in navalPatrol do
        local platoon = ArmyBrains[uef]:MakePlatoon('', '')
        ArmyBrains[uef]:AssignUnitsToPlatoon(platoon, {v}, 'attack', 'AttackFormation')
        platoon.PlatoonData = {}
        platoon.PlatoonData.PatrolChain = 'MainBaseNaval_Chain'
        platoon:ForkAIThread(ScenarioPlatoonAI.RandomPatrolThread)
    end

    -- Air Patrol
    local airPatrol = ScenarioUtils.CreateArmyGroup('UEF', 'MainBaseAirPatrol_D' .. ScenarioInfo.Options.Difficulty)
    for k, v in airPatrol do
        local chain = ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('MainBaseAir_Chain'))
        for i = 1, table.getn(chain) do
            IssuePatrol({v}, chain[i])
        end
    end

    -- Land Patrol
    for i = 1, ScenarioInfo.Options.Difficulty do
        local landPatrol = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'MainBaseLandPatrol_D' .. i, 'AttackFormation')
        landPatrol.PlatoonData = {}
        landPatrol.PlatoonData.PatrolChain = 'MainBase_Chain'
        landPatrol:ForkAIThread(ScenarioPlatoonAI.RandomPatrolThread)
    end

    ScenarioFramework.Dialogue(OpStrings.A03_M03_010, StartMission3)
end

function StartMission3()
    -- VO Timers
    ScenarioFramework.CreateTimerTrigger(M3Dialogue1, M3VOTimer1)
    ScenarioFramework.CreateTimerTrigger(M3Dialogue2, M3VOTimer2)
    ScenarioFramework.CreateTimerTrigger(M3Dialogue3, M3VOTimer3)
    ScenarioFramework.CreateTimerTrigger(M3Dialogue4, M3VOTimer4)

    -- Primary Objective 1
    ScenarioInfo.M3P1 = Objectives.Basic(
        'primary',                          -- type
        'incomplete',                       -- complete
        OpStrings.OpA03_M3P1_Title,         -- title
        OpStrings.OpA03_M3P1_Desc,          -- description
        Objectives.GetActionIcon('kill'),   -- action
        {                                   -- target
            Units = {ScenarioInfo.ArnoldCDR},
        }
   )
    ScenarioInfo.M3P1:AddResultCallback(
        function()
            IssueClearCommands({ScenarioInfo.ArnoldCDR})
            ScenarioInfo.CDRPlatoon:StopAI()
            for _, player in ScenarioInfo.HumanPlayers do
                        SetAlliance(player, uef, 'Neutral')
                        SetAlliance(uef, player, 'Neutral')
            end
            local units = ArmyBrains[Player]:GetListOfUnits(categories.ALLUNITS - categories.FACTORY, false)
            IssueClearCommands(units)
            units = ArmyBrains[uef]:GetListOfUnits(categories.ALLUNITS - categories.FACTORY, false)
            IssueClearCommands(units)
            PlayerWin()
        end
   )
    ScenarioFramework.CreateUnitDamagedTrigger(ArnoldDamaged3, ScenarioInfo.ArnoldCDR, .95)

    -- M3P1 Objective Reminder
    ScenarioFramework.CreateTimerTrigger(M3P1Reminder1, M3P1Time)

    ScenarioFramework.SetPlayableArea('M3Area')
end

function ArnoldDamaged3()
    ScenarioInfo.M3P1:ManualResult(true)
end

function M3Dialogue1()
    ScenarioFramework.Dialogue(OpStrings.A03_M03_020)
end

function M3Dialogue2()
    ScenarioFramework.Dialogue(OpStrings.A03_M03_060)
end

function M3Dialogue3()
    ScenarioFramework.Dialogue(OpStrings.A03_M03_070)
end

function M3Dialogue4()
    ScenarioFramework.Dialogue(OpStrings.A03_M03_030)
    NavalAttack()
end

function NavalAttack()
    if(not ScenarioInfo.NavalAttackDestroyed) then
        ScenarioInfo.NavalAttack:Stop()
        ScenarioInfo.NavalAttack.PlatoonData = {}
        ScenarioInfo.NavalAttack.PlatoonData.PatrolChain = 'ErisNavy_Chain1'
        ScenarioInfo.NavalAttack:ForkAIThread(ScenarioPlatoonAI.PatrolThread)

        ScenarioFramework.Dialogue(OpStrings.A03_M03_040)
    end
end

function NavalAttackDestroyed()
    ScenarioInfo.NavalAttackDestroyed = true
    ForkThread(NavalAttackDestroyedDialogue)
end

function NavalAttackDestroyedDialogue()
    WaitSeconds(5)
    ScenarioFramework.Dialogue(OpStrings.A03_M03_050)
end

function M3P1Reminder1()
    if(ScenarioInfo.M3P1.Active) then
        ScenarioFramework.Dialogue(OpStrings.A03_M03_080)
        ScenarioFramework.CreateTimerTrigger(M3P1Reminder2, M3P1Subsequent)
    end
end

function M3P1Reminder2()
    if(ScenarioInfo.M3P1.Active) then
        ScenarioFramework.Dialogue(OpStrings.A03_M03_085)
        ScenarioFramework.CreateTimerTrigger(M3P1Reminder3, M3P1Subsequent)
    end
end

function M3P1Reminder3()
    if(ScenarioInfo.M3P1.Active) then
        ScenarioFramework.Dialogue(ScenarioStrings.AeonGenericReminder)
        ScenarioFramework.CreateTimerTrigger(M3P1Reminder1, M3P1Subsequent)
    end
end
