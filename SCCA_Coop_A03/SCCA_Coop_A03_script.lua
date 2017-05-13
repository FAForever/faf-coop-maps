-- ****************************************************************************
-- **
-- **  File     :  /maps/SCCA_Coop_A03/SCCA_Coop_A03_script.lua
-- **  Author(s):  Jessica St. Croix
-- **
-- **  Summary  :
-- **
-- **  Copyright © 2006 Gas Powered Games, Inc.  All rights reserved.
-- ****************************************************************************
local Cinematics = import('/lua/cinematics.lua')
local M2UEFAI = import('/maps/SCCA_Coop_A03/SCCA_Coop_A03_m2uefai.lua')
local M3UEFAI = import('/maps/SCCA_Coop_A03/SCCA_Coop_A03_m3uefai.lua')
local Objectives = import('/lua/SimObjectives.lua')
local OpStrings = import('/maps/SCCA_Coop_A03/SCCA_Coop_A03_strings.lua')
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioStrings = import('/lua/ScenarioStrings.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')

----------
-- Globals
----------
ScenarioInfo.Player1 = 1
ScenarioInfo.UEF = 2
ScenarioInfo.Eris = 3
ScenarioInfo.Player2 = 4
ScenarioInfo.Player3 = 5
ScenarioInfo.Player4 = 6

ScenarioInfo.FirstWave = 1
ScenarioInfo.SecondWave = 4
ScenarioInfo.ThirdWave = 7

---------
-- Locals
---------
local Player1 = ScenarioInfo.Player1
local Player2 = ScenarioInfo.Player2
local Player3 = ScenarioInfo.Player3
local Player4 = ScenarioInfo.Player4
local UEF = ScenarioInfo.UEF
local Eris = ScenarioInfo.Eris

local Difficulty = ScenarioInfo.Options.Difficulty
local AssignedObjectives = {}

local arnoldTaunt = 1

local LeaderFaction
local LocalFaction

-------------
-- Debug Only
-------------
local SkipM1 = false

-----------
-- Start up
-----------
function OnPopulate(scenario)
    ScenarioUtils.InitializeScenarioArmies()
    LeaderFaction, LocalFaction = ScenarioFramework.GetLeaderAndLocalFactions()

    -- Eris
    ScenarioInfo.ErisCDR = ScenarioFramework.SpawnCommander('Eris', 'Eris', false, LOC '{i CDR_Eris}', false, false,
        {'Shield', 'HeatSink', 'CrysalisBeam'})
    ScenarioInfo.ErisCDR:SetCanTakeDamage(false)
    ScenarioInfo.ErisCDR:SetCanBeKilled(false)
    ScenarioInfo.ErisCDR:SetDoNotTarget(true)
    ScenarioInfo.ErisCDR:AdjustHealth(ScenarioInfo.ErisCDR, ScenarioInfo.ErisCDR:GetHealth() * -.8)

    ScenarioInfo.ErisBase = ScenarioUtils.CreateArmyGroup('Eris', 'Base')
    for k, v in ScenarioInfo.ErisBase do
        v:AdjustHealth(v, Random(1, v:GetHealth()/3 - 5) * -Difficulty)
    end

    ScenarioInfo.ErisEngineers = ScenarioUtils.CreateArmyGroup('Eris', 'Engineers')
    for k, v in ScenarioInfo.ErisEngineers do
        v:AdjustHealth(v, Random(1, v:GetHealth()/3 - 5) * -Difficulty)
    end

    ScenarioInfo.ErisLandPatrol = ScenarioUtils.CreateArmyGroupAsPlatoon('Eris', 'LandUnits', 'AttackFormation')
    for k, v in ScenarioInfo.ErisLandPatrol:GetPlatoonUnits() do
        v:AdjustHealth(v, Random(1, v:GetHealth()/3 - 5) * -Difficulty)
    end
    ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.ErisLandPatrol, 'PlayerBase_Chain')

    ScenarioInfo.ErisNavyPatrol = ScenarioUtils.CreateArmyGroupAsPlatoon('Eris', 'NavalUnits', 'AttackFormation')
    for k, v in ScenarioInfo.ErisNavyPatrol:GetPlatoonUnits() do
        v:AdjustHealth(v, Random(1, v:GetHealth()/3 - 5) * -Difficulty)
    end
    ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.ErisNavyPatrol, 'Navy_Chain')

    -- UEF, power generators for frigate jamming
    ScenarioUtils.CreateArmyGroup('UEF', 'PgensForJamming')

    -- Give UEF vision of player base
    ScenarioInfo.UEFViz = ScenarioFramework.CreateVisibleAreaLocation(100, ScenarioUtils.MarkerToPosition('Player1'), 0, ArmyBrains[UEF])
end

function OnStart(self)
    -- Adjust buildable categories for Players
     ScenarioFramework.AddRestrictionForAllHumans(
        ((categories.TECH2 + categories.TECH3) * categories.AEON) +  -- T2 & T3 Aeon
         (categories.TECH3 * categories.UEF) +                       -- T3 UEF
         categories.PRODUCTFA +                                      -- All FA Units
         categories.uea0204 +                                        -- UEF Torpedo Bomber
         categories.uel0203 +                                        -- UEF Amphibious Tank
         categories.ues0202                                          -- UEF Cruiser
    )

    ScenarioFramework.RemoveRestrictionForAllHumans(
        categories.uab0202 +    -- T2 Air Factory
        categories.zab9502 +    -- T2 Support Air Factory
        categories.ual0208 +    -- T2 Engineer
        categories.uaa0204 +    -- T2 Torpedo Bomber
        categories.uab1201 +    -- T2 Power Generator
        categories.uab1202 +    -- T2 Mass Extractor
        categories.uab1104 +    -- T2 Mass Fab
        categories.uab2204 +    -- T2 AA Tower
        categories.uab2205 +    -- T2 Torpedo Tower
        categories.uab2301 +    -- T2 Point Defense
        categories.uab3201 +    -- T2 Radar
        categories.uab3202 +    -- T2 Sonar
        categories.uab5202      -- T2 Air refuel
    )

    -- Player has access to HeatSink, CrysalisBeam, Chrono, Shield, EnhancedSensors and AdvancedEngineering
    ScenarioFramework.RestrictEnhancements({
        'ResourceAllocation',
        'ResourceAllocationAdvanced',
        'T3Engineering',
        'ShieldHeavy',
        'Teleporter'
    })

    -- Unit Cap
    ScenarioFramework.SetSharedUnitCap(420)

    -- Army colors
    ScenarioFramework.SetAeonColor(Player1)
    ScenarioFramework.SetUEFColor(UEF)
    ScenarioFramework.SetAeonAllyColor(Eris)
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

    ScenarioFramework.SetPlayableArea('M1Area', false)
    ScenarioFramework.StartOperationJessZoom('CDRZoom', IntroMission1)
end

-----------
-- End Game
-----------
function PlayerWin()
    if not ScenarioInfo.OpEnded then
        ScenarioFramework.EndOperationSafety()
        ScenarioInfo.OpComplete = true

        -- Arnold Killed
        ScenarioFramework.CDRDeathNISCamera(ScenarioInfo.ArnoldCDR)
        ScenarioFramework.CreateVisibleAreaAtUnit(60, ScenarioInfo.ArnoldCDR, 0, ArmyBrains[Player1])
        CreateLightParticle(ScenarioInfo.ArnoldCDR, -1, -1, 60, 6000, 'glow_03', 'ramp_orange_02')
        CreateEmitterAtEntity(ScenarioInfo.ArnoldCDR, -1, '/effects/emitters/a3_end_nis_01_emit.bp')
        CreateEmitterAtEntity(ScenarioInfo.ArnoldCDR, -1, '/effects/emitters/a3_end_nis_02_emit.bp')

        ScenarioFramework.Dialogue(OpStrings.A03_M03_090, KillGame, true)
    end
end

function PlayerLose(deadCommander)
    ScenarioFramework.PlayerDeath(deadCommander, OpStrings.A03_D01_010)
end

function KillGame()
    if not ScenarioInfo.OpComplete then
        WaitSeconds(15)
    end
    local secondaries = Objectives.IsComplete(ScenarioInfo.M2S1) and Objectives.IsComplete(ScenarioInfo.M2S2) and Objectives.IsComplete(ScenarioInfo.M2S3)
    local bonus = Objectives.IsComplete(ScenarioInfo.M1B1) and Objectives.IsComplete(ScenarioInfo.M1B2) and Objectives.IsComplete(ScenarioInfo.M1B3)
    ScenarioFramework.EndOperation(ScenarioInfo.OpComplete, ScenarioInfo.OpComplete, secondaries, bonus)
end

------------
-- Mission 1
------------
function IntroMission1()
    ScenarioInfo.MissionNumber = 1

    -- Spawn Players
    local tblArmy = ListArmies()
    local i = 1
    while tblArmy[ScenarioInfo['Player' .. i]] do
        ScenarioInfo['Player' .. i .. 'CDR'] = ScenarioFramework.SpawnCommander('Player' .. i, 'Commander', 'Warp', true, true, PlayerLose)
        WaitSeconds(2)
        i = i + 1
    end

    WaitSeconds(2)
    IssueMove({ScenarioInfo.ErisCDR}, ScenarioUtils.MarkerToPosition('Eris_Marker'))
    ScenarioFramework.Dialogue(OpStrings.A03_M01_010, StartMission1, true)
    WaitSeconds(10)
    ForkThread(ErisLeaves)
end

function StartMission1()
    -- Hand over Eris' base
    local currentHealth = 0
    local originalHealth = 0
    local unit = nil
    local platoon = nil
    for _, v in ScenarioInfo.ErisBase do
        if not v:IsDead() then
            ScenarioFramework.GiveUnitToArmy(v, Player1)
        end
    end

    for _, v in ScenarioInfo.ErisEngineers do
        if not v:IsDead() then
            ScenarioFramework.GiveUnitToArmy(v, Player1)
        end
    end

    platoon = ArmyBrains[Player1]:MakePlatoon('', '')
    for _, v in ScenarioInfo.ErisLandPatrol:GetPlatoonUnits() do
        if not v:IsDead() then
            local unit = ScenarioFramework.GiveUnitToArmy(v, Player1)
            ArmyBrains[Player1]:AssignUnitsToPlatoon(platoon, {unit}, 'attack', 'AttackFormation')
        end
    end
    ScenarioFramework.PlatoonPatrolChain(platoon, 'PlayerBase_Chain')

    platoon = ArmyBrains[Player1]:MakePlatoon('', '')
    for _, v in ScenarioInfo.ErisNavyPatrol:GetPlatoonUnits() do
        if not v:IsDead() then
            local unit = ScenarioFramework.GiveUnitToArmy(v, Player1)
            ArmyBrains[Player1]:AssignUnitsToPlatoon(platoon, {unit}, 'attack', 'AttackFormation')
        end
    end
    ScenarioFramework.PlatoonPatrolChain(platoon, 'Navy_Chain')

    if not SkipM1 then
        -- After 2 minutes
        ScenarioFramework.CreateTimerTrigger(M1Dialogue1, 20) -- 2*60

        -- After 3 minutes
        ScenarioFramework.CreateTimerTrigger(M1Dialogue2, 45) -- 3*60
        ScenarioFramework.CreateTimerTrigger(PreWave, 45) -- 3*60

        -- After 5 minutes
        ScenarioFramework.CreateTimerTrigger(M1Dialogue3, 105) -- 5*60

        -- After 6 minutes
        ScenarioFramework.CreateTimerTrigger(PreWave, 120) -- 6*60

        -- After 8 minutes
        ScenarioFramework.CreateTimerTrigger(M1Dialogue4, 180) -- 8*60

        -- After 10 minutes
        ScenarioFramework.CreateTimerTrigger(M1Dialogue5, 210) -- 10*60

        --------------------------------------------
        -- Primary Objective 1 - Survive UEF Assault
        --------------------------------------------
        ScenarioInfo.M1P1 = Objectives.Basic(
            'primary',                          -- type
            'incomplete',                       -- complete
            OpStrings.OpA03_M1P1_Title,         -- title
            OpStrings.OpA03_M1P1_Desc,          -- description
            Objectives.GetActionIcon('kill'),   -- action
            {                                   -- target
                ShowFaction = 'UEF',
            }
        )

        -----------------------------------
        -- Bonus Objective - Build Defenses
        -----------------------------------
        local num = {100, 125, 150}
        ScenarioInfo.M1B1 = Objectives.ArmyStatCompare(
            'bonus',
            'incomplete',
            OpStrings.OpA03_Bonus1_Title,
            LOCF(OpStrings.OpA03_Bonus1_Desc, num[Difficulty]),
            'build',
            {
                Armies = {'HumanPlayers'},
                StatName = 'Units_History',
                CompareOp = '>=',
                Value = num[Difficulty],
                Category = categories.DEFENSE - categories.WALL,
                Hidden = true,
            }
        )

        -----------------------------------
        -- Bonus Objective - Build Gunships
        -----------------------------------
        num = {150, 175, 200}
        ScenarioInfo.M1B2 = Objectives.ArmyStatCompare(
            'bonus',
            'incomplete',
            OpStrings.OpA03_Bonus2_Title,
            LOCF(OpStrings.OpA03_Bonus2_Desc, num[Difficulty]),
            'build',
            {
                Armies = {'HumanPlayers'},
                StatName = 'Units_History',
                CompareOp = '>=',
                Value = num[Difficulty],
                Category = categories.uaa0203 + categories.uea0203,
                Hidden = true,
            }
        )
        ------------------------------------
        -- Bonus Objective - Kill Destroyers
        ------------------------------------
        num = {30, 40, 50}
        ScenarioInfo.M1B3 = Objectives.ArmyStatCompare(
            'bonus',
            'incomplete',
            OpStrings.OpA03_Bonus3_Title,
            LOCF(OpStrings.OpA03_Bonus3_Desc, num[Difficulty]),
            'kill',
            {
                Armies = {'HumanPlayers'},
                StatName = 'Enemies_Killed',
                CompareOp = '>=',
                Value = num[Difficulty],
                Category = categories.ues0201,
                Hidden = true,
            }
        )
    else
        IntroMission2()
    end

    -- Start taunts
    ScenarioFramework.CreateTimerTrigger(Taunt, Random(600, 900))
end

function ErisLeaves()
    if not ScenarioInfo.OpEnded then
        -- Transport Eris
        ScenarioInfo.Escort = ScenarioUtils.CreateArmyGroupAsPlatoon('Eris', 'TransportEscort', 'GrowthFormation')
        for k, v in ScenarioInfo.Escort:GetPlatoonUnits() do
            v:SetCanTakeDamage(false)
            v:SetCanBeKilled(false)
            v:SetDoNotTarget(true)
        end
        ScenarioInfo.Escort:MoveToLocation(ScenarioUtils.MarkerToPosition('Player1'), false)

        WaitSeconds(10)

        ScenarioInfo.Transport = ScenarioUtils.CreateArmyUnit('Eris', 'Transport')
        ScenarioInfo.Transport:SetCanTakeDamage(false)
        ScenarioInfo.Transport:SetCanBeKilled(false)
        ScenarioInfo.Transport:SetDoNotTarget(true)

        IssueTransportLoad({ScenarioInfo.ErisCDR}, ScenarioInfo.Transport)
        IssueMove({ScenarioInfo.Transport}, ScenarioUtils.MarkerToPosition('ErisDeath'))

        local function KillEris()
            ScenarioInfo.ErisCDR:Destroy()
            ScenarioInfo.Escort:Destroy()
            ScenarioInfo.Transport:Destroy()
        end

        ScenarioFramework.CreateAreaTrigger(KillEris, ScenarioUtils.AreaToRect('ErisDeath'), categories.AEON,
            true, false, ArmyBrains[Eris], 11)

        ScenarioInfo.Escort:MoveToLocation(ScenarioUtils.MarkerToPosition('ErisDeath'), false)
    end
end

function Taunt()
    if arnoldTaunt <= 8 then
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
    for i = 1, Difficulty do
        local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'PreWave_D' .. i, 'GrowthFormation')
        ScenarioFramework.PlatoonPatrolRoute(platoon, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('ErisAll_Chain')))
    end
end

function FirstWave()
    if ScenarioInfo.FirstWave < 4 then
        for i = 1, Difficulty do
            local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M1Wave' .. ScenarioInfo.FirstWave .. '_D' .. i, 'GrowthFormation')
            ScenarioFramework.PlatoonPatrolRoute(platoon, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('ErisAll_Chain')))
        end
        ScenarioInfo.FirstWave = ScenarioInfo.FirstWave + 1
        ScenarioFramework.CreateTimerTrigger(FirstWave, 20) -- 60
    else
        ScenarioFramework.CreateAreaTrigger(FirstWaveDefeated, ScenarioUtils.AreaToRect('M1Area'), categories.ALLUNITS,
            true, true, ArmyBrains[UEF])
    end
end

function FirstWaveDefeated()
    ForkThread(FirstWaveDefeatedDialogue)
    ScenarioFramework.CreateTimerTrigger(SecondWave, 60) -- 120

    -- Set up trigger to kill transports used in following waves
    ScenarioInfo.DestroyTrigger = ScenarioFramework.CreateAreaTrigger(DestroyUnit, ScenarioUtils.AreaToRect('ErisDeath'), categories.UEF,
        false, false, ArmyBrains[UEF])
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
    if ScenarioInfo.SecondWave < 7 then
        for i = 1, Difficulty do
            local airPlatoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M1Wave' .. ScenarioInfo.SecondWave .. '_Air_D' .. i, 'GrowthFormation')
            ScenarioFramework.PlatoonPatrolRoute(airPlatoon, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('ErisAll_Chain')))

            local landPlatoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M1Wave' .. ScenarioInfo.SecondWave .. '_Land_D' .. i, 'AttackFormation')
            local transport = ScenarioUtils.CreateArmyGroup('UEF', 'M1Wave' .. ScenarioInfo.SecondWave .. '_Transport_D' .. i)

            ScenarioFramework.AttachUnitsToTransports(landPlatoon:GetPlatoonUnits(), transport)
            IssueTransportUnload(transport, ScenarioPlatoonAI.PlatoonChooseRandomNonNegative(ArmyBrains[UEF], ScenarioUtils.ChainToPositions('ErisLand_Chain'), 2))
            IssueMove(transport, ScenarioUtils.MarkerToPosition('ErisDeath'))

            ScenarioFramework.PlatoonPatrolRoute(landPlatoon, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('ErisLand_Chain')))
        end
        ScenarioInfo.SecondWave = ScenarioInfo.SecondWave + 1
        ScenarioFramework.CreateTimerTrigger(SecondWave, 60) --90
    else
        ScenarioFramework.CreateAreaTrigger(SecondWaveDefeated, ScenarioUtils.AreaToRect('M1Area'), categories.ALLUNITS,
            true, true, ArmyBrains[UEF])
    end
end

function SecondWaveDefeated()
    ForkThread(SecondWaveDefeatedDialogue)
    ScenarioFramework.CreateTimerTrigger(ThirdWave, 60) --120
end

function SecondWaveDefeatedDialogue()
    WaitSeconds(5)
    ScenarioFramework.Dialogue(OpStrings.A03_M01_100)
    ScenarioFramework.Dialogue(OpStrings.A03_M01_110)
end

function ThirdWave()
    if ScenarioInfo.ThirdWave < 11 then
        for i = 1, Difficulty do
            for j = 1, 2 do
                local airPlatoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M1Wave' .. ScenarioInfo.ThirdWave .. '_Air_D' .. i, 'GrowthFormation')
                ScenarioFramework.PlatoonPatrolRoute(airPlatoon, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('ErisAll_Chain')))
            end

            local navyPlatoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M1Wave' .. ScenarioInfo.ThirdWave .. '_Navy_D' .. i, 'AttackFormation')
            ScenarioFramework.PlatoonPatrolRoute(navyPlatoon, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('ErisNavy_Chain' .. i)))

            if(ScenarioInfo.ThirdWave == 10) then
                local landPlatoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M1Wave' .. ScenarioInfo.ThirdWave .. '_Land_D' .. i, 'AttackFormation')
                local transport = ScenarioUtils.CreateArmyGroup('UEF', 'M1Wave' .. ScenarioInfo.ThirdWave .. '_Transport_D' .. i)

                ScenarioFramework.AttachUnitsToTransports(landPlatoon:GetPlatoonUnits(), transport)
                IssueTransportUnload(transport, ScenarioPlatoonAI.PlatoonChooseRandomNonNegative(ArmyBrains[UEF], ScenarioUtils.ChainToPositions('ErisLand_Chain'), 2))
                IssueMove(transport, ScenarioUtils.MarkerToPosition('ErisDeath'))

                ScenarioFramework.PlatoonPatrolRoute(landPlatoon, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('ErisLand_Chain')))
            end
        end
        ScenarioInfo.ThirdWave = ScenarioInfo.ThirdWave + 1
        ScenarioFramework.CreateTimerTrigger(ThirdWave, 90) -- 120
    else
        ScenarioFramework.CreateAreaTrigger(ThirdWaveDefeated, ScenarioUtils.AreaToRect('M1Area'), categories.ALLUNITS,
            true, true, ArmyBrains[UEF])
    end
end

function ThirdWaveDefeated()
    ForkThread(M1P1Complete)
end

function M1P1Complete()
    WaitSeconds(5)
    ScenarioFramework.Dialogue(OpStrings.A03_M01_120, IntroMission2, true)
    ScenarioInfo.M1P1:ManualResult(true)
    -- Mark bonus objective to build defenses as failed if it's not completed yet
    if ScenarioInfo.M1B1.Active then
        ScenarioInfo.M1B1:ManualResult(false)
    end
    ScenarioInfo.DestroyTrigger:Destroy()
end

------------
-- Mission 2
------------
function IntroMission2()
    ScenarioInfo.MissionNumber = 2

    ScenarioFramework.SetSharedUnitCap(660)

    ScenarioInfo.UEFViz:Destroy()

    -- Adjust buildable categories for player
    ScenarioFramework.RemoveRestrictionForAllHumans(
        categories.uab0203 +    -- T2 Naval Factory
        categories.zab9503 +    -- T2 Support Naval Factory
        categories.uas0201 +    -- Destroyer
        categories.uaa0203,     -- T2 Gunship
        true
    )

    -- Land Base
    M2UEFAI.UEFM2LandBaseAI()
    for i = 1, Difficulty do
        local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'LandBasePatrol_D' .. i, 'AttackFormation')
        ScenarioFramework.PlatoonPatrolRoute(platoon, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('LandBase_Chain')))
    end

    -- Air Base
    M2UEFAI.UEFM2AirBaseAI()
    local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'AirBasePatrol_D' .. Difficulty, 'NoFormation')
    for _, v in platoon:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('AirBaseAir_Chain')))
    end

    -- Naval Base
    M2UEFAI.UEFM2NavalBaseAI()
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'NavalBasePatrol_D' .. Difficulty, 'NoFormation')
    for _, v in platoon:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('NavyBaseSea_Chain')))
    end

    -- Arnold's ACU
    ScenarioInfo.ArnoldCDR = ScenarioFramework.SpawnCommander('UEF', 'Arnold', false, LOC '{i CDR_Arnold}', false, false,
        {'DamageStablization', 'Shield', 'HeavyAntiMatterCannon'})
    ScenarioInfo.ArnoldCDR:SetCanBeKilled(false)
    ScenarioInfo.ArnoldCDR:SetAutoOvercharge(true)
    ScenarioInfo.ArnoldCDR:AddBuildRestriction(categories.UEF * categories.DEFENSE)
    ScenarioFramework.CreateUnitDamagedTrigger(ArnoldDamaged1, ScenarioInfo.ArnoldCDR, .5)

    ScenarioInfo.CDRPlatoon = 

    ArmyBrains[UEF]:PBMSetCheckInterval(8)

    ScenarioFramework.Dialogue(OpStrings.A03_M02_010, StartMission2, true)
end

function StartMission2()
    -------------------------------------------
    -- Primary Objective 2 - Kill UEF Commander
    -------------------------------------------
    ScenarioInfo.M2P1 = Objectives.Kill(
        'primary',                          -- type
        'incomplete',                       -- complete
        OpStrings.OpA03_M2P1_Title,         -- title
        OpStrings.OpA03_M2P1_Desc,          -- description
        {                                   -- target
            Units = {ScenarioInfo.ArnoldCDR},
        }
    )

    -- M2P1 Objective Reminder
    ScenarioFramework.CreateTimerTrigger(M2P1Reminder1, 900)

    --------------------------------------------
    -- Secondary Objective 1 - Destroy Land Base
    --------------------------------------------
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
                    ArmyIndex = UEF,
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
            local unit = ScenarioUtils.MarkerToPosition("M2_Land_Base_Marker")
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

    -------------------------------------------
    -- Secondary Objective 2 - Destroy Air Base
    -------------------------------------------
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
                    ArmyIndex = UEF,
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
            local unit = ScenarioUtils.MarkerToPosition("M2_Air_Base_Marker")
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

    ---------------------------------------------
    -- Secondary Objective 3 - Destroy Naval Base
    ---------------------------------------------
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
                    ArmyIndex = UEF,
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

function ArnoldNavyVO()
    if not ScenarioInfo.ArnoldDamaged1 then
        ScenarioFramework.Dialogue(OpStrings.A03_M02_050)
    end
end

function ArnoldDamaged1()
    ScenarioInfo.ArnoldDamaged1 = true
    if ScenarioInfo.ArnoldCDR:GetHealth() <= 2400 then
        ArnoldDamaged2()
    elseif ScenarioInfo.M2S1.Active then
        ForkThread(TeleportLandBase)
    elseif ScenarioInfo.M2S2.Active then
        ForkThread(TeleportAirBase)
    else
        ArnoldDamaged2()
    end
end

function TeleportLandBase()
    ScenarioInfo.ArnoldCDR:SetCanTakeDamage(false)
    ScenarioFramework.FakeTeleportUnit(ScenarioInfo.ArnoldCDR)
    Warp(ScenarioInfo.ArnoldCDR, ScenarioUtils.MarkerToPosition('M2_Land_Base_Marker'))
    ScenarioFramework.CreateUnitDamagedTrigger(ArnoldDamaged2, ScenarioInfo.ArnoldCDR, .8)
    ScenarioInfo.ArnoldCDR:SetCanTakeDamage(true)
    UpdateACUPlatoon('M2_Land_Base')
    ScenarioFramework.Dialogue(OpStrings.A03_M02_020)
    ScenarioFramework.CreateTimerTrigger(ArnoldLandVO, 60)
end

function TeleportAirBase()
    ScenarioInfo.ArnoldCDR:SetCanTakeDamage(false)
    ScenarioFramework.FakeTeleportUnit(ScenarioInfo.ArnoldCDR)
    Warp(ScenarioInfo.ArnoldCDR, ScenarioUtils.MarkerToPosition('M2_Air_Base_Marker'))
    ScenarioFramework.CreateUnitDamagedTrigger(ArnoldDamaged2, ScenarioInfo.ArnoldCDR, .8)
    ScenarioInfo.ArnoldCDR:SetCanTakeDamage(true)
    UpdateACUPlatoon('M2_Air_Base')
    ScenarioFramework.Dialogue(OpStrings.A03_M02_020)
    ScenarioFramework.CreateTimerTrigger(ArnoldAirVO, 60)
end

function UpdateACUPlatoon(location)
    for _, platoon in ArmyBrains[UEF]:GetPlatoonsList() do
        for _, unit in platoon:GetPlatoonUnits() do
            if EntityCategoryContains(categories.COMMAND, unit) then
                if location == 'None' then
                    IssueClearCommands({unit})
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
                return
            end
        end
    end
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
    Warp(ScenarioInfo.ArnoldCDR, ScenarioUtils.MarkerToPosition('M3_Main_Base_Marker'))
    ScenarioInfo.ArnoldCDR:SetCanTakeDamage(true)
    UpdateACUPlatoon('None')
    ScenarioFramework.Dialogue(OpStrings.A03_M02_090, IntroMission3, true)
    ScenarioInfo.M2P1:ManualResult(true)
end

function M2P1Reminder1()
    if(ScenarioInfo.M2P1.Active) then
        ScenarioFramework.Dialogue(OpStrings.A03_M02_100)
        ScenarioFramework.CreateTimerTrigger(M2P1Reminder2, 600)
    end
end

function M2P1Reminder2()
    if(ScenarioInfo.M2P1.Active) then
        ScenarioFramework.Dialogue(OpStrings.A03_M02_105)
        ScenarioFramework.CreateTimerTrigger(M2P1Reminder3, 600)
    end
end

function M2P1Reminder3()
    if(ScenarioInfo.M2P1.Active) then
        ScenarioFramework.Dialogue(ScenarioStrings.AeonGenericReminder)
        ScenarioFramework.CreateTimerTrigger(M2P1Reminder1, 600)
    end
end

------------
-- Mission 3
------------
function IntroMission3()
    ScenarioInfo.MissionNumber = 3

    ScenarioFramework.SetSharedUnitCap(900)

    -- Adjust buildable categories for player
    ScenarioFramework.RemoveRestrictionForAllHumans(categories.uas0202, true)  -- Cruiser

    -- Main Base
    M3UEFAI.UEFM3MainBaseAI()
    ScenarioInfo.NavalAttack = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'NavalAttack_D' .. Difficulty, 'NoFormation')
    for _, v in ScenarioInfo.NavalAttack:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('MainBaseNaval_Chain')))
    end
    ScenarioFramework.CreatePlatoonDeathTrigger(NavalAttackDestroyed, ScenarioInfo.NavalAttack)

    -- Naval Patrol
    local navalPatrol = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'MainBaseNavyPatrol_D' .. Difficulty, 'NoFormation')
    for _, v in navalPatrol:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('MainBaseNaval_Chain')))
    end

    -- Air Patrol
    local airPatrol = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'MainBaseAirPatrol_D' .. Difficulty, 'NoFormation')
    for _, v in airPatrol:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('MainBaseAir_Chain')))
    end

    -- Land Patrol
    local landPatrol = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'MainBaseLandPatrol_D' .. Difficulty, 'NoFormation')
    for _, v in landPatrol:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M3_Main_Base_EngineerChain')))
    end

    ScenarioFramework.Dialogue(OpStrings.A03_M03_010, StartMission3, true)
end

function StartMission3()
    --UpdateACUPlatoon('M3_Main_Base')
    -- VO Timers
    ScenarioFramework.CreateTimerTrigger(M3Dialogue1, M3VOTimer1) -- 240
    ScenarioFramework.CreateTimerTrigger(M3Dialogue2, M3VOTimer2) -- 480
    ScenarioFramework.CreateTimerTrigger(M3Dialogue3, M3VOTimer3) -- 600
    ScenarioFramework.CreateTimerTrigger(M3Dialogue4, 60) -- 900

    -- Primary Objective 1
    ScenarioInfo.M3P1 = Objectives.Kill(
        'primary',                          -- type
        'incomplete',                       -- complete
        OpStrings.OpA03_M3P1_Title,         -- title
        OpStrings.OpA03_M3P1_Desc,          -- description
        {                                   -- target
            Units = {ScenarioInfo.ArnoldCDR},
        }
    )
    ScenarioInfo.M3P1:AddResultCallback(
        function()
            IssueClearCommands({ScenarioInfo.ArnoldCDR})
            UpdateACUPlatoon('None')
            for _, player in ScenarioInfo.HumanPlayers do
                SetAlliance(player, UEF, 'Neutral')
                SetAlliance(UEF, player, 'Neutral')
            end
            local units = ScenarioFramework.GetListOfHumanUnits(categories.ALLUNITS - categories.FACTORY, false)
            IssueClearCommands(units)
            units = ArmyBrains[UEF]:GetListOfUnits(categories.ALLUNITS - categories.FACTORY, false)
            IssueClearCommands(units)
            PlayerWin()
        end
    )
    ScenarioFramework.CreateUnitDamagedTrigger(ArnoldDamaged3, ScenarioInfo.ArnoldCDR, .95)

    -- M3P1 Objective Reminder
    ScenarioFramework.CreateTimerTrigger(M3P1Reminder1, 1200)

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
        ScenarioFramework.CreateTimerTrigger(M3P1Reminder2, 600)
    end
end

function M3P1Reminder2()
    if(ScenarioInfo.M3P1.Active) then
        ScenarioFramework.Dialogue(OpStrings.A03_M03_085)
        ScenarioFramework.CreateTimerTrigger(M3P1Reminder3, 600)
    end
end

function M3P1Reminder3()
    if(ScenarioInfo.M3P1.Active) then
        ScenarioFramework.Dialogue(ScenarioStrings.AeonGenericReminder)
        ScenarioFramework.CreateTimerTrigger(M3P1Reminder1, 600)
    end
end

------------------
-- Debug Functions
------------------
function OnCtrlF4()
    ForkThread(TeleportMainBase)
end

function OnShiftF4()
    ForkThread(
        function()
            Cinematics.EnterNISMode()
            IssueMove({ScenarioInfo['Player1CDR']}, ScenarioUtils.MarkerToPosition('Cam'))
            WaitSeconds(2)
            Cinematics.CameraThirdPerson(ScenarioInfo['Player1CDR'], 0.2, 15, 30)
            Cinematics.ExitNISMode()
        end
    )
end

function OnCtrlF3()
    LOG('NUM DEFENSES: ' .. ScenarioFramework.GetNumOfHumanUnits(categories.DEFENSE - categories.WALL))
end