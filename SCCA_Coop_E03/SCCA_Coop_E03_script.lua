-- ****************************************************************************
-- **
-- **  File     :  /maps/SCCA_Coop_E03/SCCA_Coop_E03_script.lua
-- **  Author(s):  Brian Fricks, Jessica St. Croix
-- **
-- **  Summary  :
-- **
-- **  Copyright © 2006 Gas Powered Games, Inc.  All rights reserved.
-- ****************************************************************************
local Behaviors = import('/lua/ai/opai/OpBehaviors.lua')
local Objectives = import('/lua/ScenarioFramework.lua').Objectives
local OpStrings = import('/maps/SCCA_Coop_E03/SCCA_Coop_E03_strings.lua')
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioPlatoonAI = import('/lua/scenarioplatoonai.lua')
local ScenarioStrings = import('/lua/ScenarioStrings.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local Cinematics = import('/lua/cinematics.lua')

---------
-- Globals
---------
ScenarioInfo.Player = 1
ScenarioInfo.Aeon = 2
ScenarioInfo.Arnold = 3
ScenarioInfo.Coop1 = 4
ScenarioInfo.Coop2 = 5
ScenarioInfo.Coop3 = 6

-------------
-- Misc locals
-------------
local Player = ScenarioInfo.Player
local Coop1 = ScenarioInfo.Coop1
local Coop2 = ScenarioInfo.Coop2
local Coop3 = ScenarioInfo.Coop3
local Aeon = ScenarioInfo.Aeon
local Arnold = ScenarioInfo.Arnold

local M1P1Time = 600
local ReminderDelay = 300

local erisTaunt = 1

---------
-- Startup
---------

function OnPopulate(scenario)
     ScenarioUtils.InitializeScenarioArmies()
    ScenarioFramework.GetLeaderAndLocalFactions()

    -- Player Base
    local units = ScenarioUtils.CreateArmyGroup('Player', 'StartingUnits')
    for k, v in units do
        v:AdjustHealth(v, v:GetHealth() * (-.1 * (Random(2,5))))
    end

    -- Arnold
    ScenarioInfo.ArnoldBase = ScenarioUtils.CreateArmyGroup('Arnold', 'M2_Arnold_Base')
    -- ScenarioInfo.ArnoldCDR = ScenarioUtils.CreateArmyUnit('Arnold', 'Arnold_CDR')

    -- Aeon Resource Island
    ScenarioUtils.CreateArmyGroup('Aeon', 'ResourceIsland_PreBuilt')

    -- Frigates - M1P1 Target
     ScenarioInfo.M1AeonDefenseFrigate = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M1_DefenseFrigate_D' .. ScenarioInfo.Options.Difficulty, 'NoFormation')
     ScenarioInfo.M1AeonDefenseFrigate.PlatoonData = {}
     ScenarioInfo.M1AeonDefenseFrigate.PlatoonData.PatrolChain = 'M1ResourceIslandNaval_Chain1'
     ScenarioInfo.M1AeonDefenseFrigate:ForkAIThread(ScenarioPlatoonAI.PatrolThread)

    -- Attack Boats
    local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M1_DefenseEscort_D' .. ScenarioInfo.Options.Difficulty, 'NoFormation')
    platoon.PlatoonData = {}
    platoon.PlatoonData.PatrolChain = 'M1ResourceIslandNaval_Chain2'
    platoon:ForkAIThread(ScenarioPlatoonAI.PatrolThread)

    -- Subs - M1S1 Target
     ScenarioInfo.M1Subs1 = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M1_DefenseSub_D' .. ScenarioInfo.Options.Difficulty, 'NoFormation')
     ScenarioInfo.M1Subs1.PlatoonData = {}
     ScenarioInfo.M1Subs1.PlatoonData.PatrolChain = 'M1Sub_Chain1'
     ScenarioInfo.M1Subs1:ForkAIThread(ScenarioPlatoonAI.PatrolThread)

    ScenarioInfo.M1Subs2 = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M1_DefenseSub_D' .. ScenarioInfo.Options.Difficulty, 'NoFormation')
     ScenarioInfo.M1Subs2.PlatoonData = {}
     ScenarioInfo.M1Subs2.PlatoonData.PatrolChain = 'M1Sub_Chain2'
     ScenarioInfo.M1Subs2:ForkAIThread(ScenarioPlatoonAI.PatrolThread)

    -- Eris
    ScenarioInfo.AeonCDR = ScenarioUtils.CreateArmyUnit('Aeon', 'Aeon_CDR')
    ScenarioInfo.AeonCDR:SetCustomName(LOC '{i CDR_Eris}')
    ScenarioInfo.AeonCDR:SetCapturable(false)
    ScenarioInfo.AeonCDR:CreateEnhancement('Shield')
    ScenarioInfo.AeonCDR:CreateEnhancement('HeatSink')
    ScenarioInfo.AeonCDR:CreateEnhancement('CrysalisBeam')
    ScenarioFramework.PauseUnitDeath(ScenarioInfo.AeonCDR)
    local cdrPlatoon = ArmyBrains[Aeon]:MakePlatoon('','')
    ArmyBrains[Aeon]:AssignUnitsToPlatoon(cdrPlatoon, {ScenarioInfo.AeonCDR}, 'Attack', 'AttackFormation')
    cdrPlatoon:ForkAIThread(CDRAI)
    cdrPlatoon.CDRData = {}
    cdrPlatoon.CDRData.LeashPosition = 'Aeon'
    cdrPlatoon.CDRData.LeashRadius = 40
    cdrPlatoon:ForkThread(Behaviors.CDROverchargeBehavior)
end

function OnStart(self)
    -- Adjust buildable categories for the Player
    for _, player in ScenarioInfo.HumanPlayers do
         ScenarioFramework.AddRestriction(player, categories.TECH2 +  -- T2
                                     categories.TECH3)   -- T3
    end

    ScenarioFramework.RemoveRestrictionForAllHumans(
        categories.ueb0201 + categories.uab0201 +    -- T2 Land Factory
        categories.zeb9501 + categories.zab9501 +    -- T2 Support Land Factory
        categories.uel0208 + categories.ual0208 +    -- T2 Engineer
        categories.uel0202 + categories.ual0202 +    -- Heavy Tank
        categories.uel0111 + categories.ual0111 +    -- Mobile Missile Launcher
        categories.uel0205 + categories.ual0205 +    -- Mobile AA Flak
        categories.uel0307 + categories.ual0307 +    -- Mobile Sheild Generator
        categories.ueb0202 + categories.uab0202 +    -- T2 Air Factory
        categories.zeb9502 + categories.zab9502 +    -- T2 Support Air Factory
        categories.uea0203 + categories.uaa0203 +    -- Gunship
        categories.uea0204 + categories.uaa0204 +    -- Torpedo Bomber
        categories.ueb1202 + categories.uab1202 +    -- T2 Mass Extractor
        categories.ueb2204 + categories.uab2204 +    -- T2 AA Tower
        categories.ueb2301 + categories.uab2301      -- T2 Gun Tower
    )

    -- Player has access to ResourceAllocation, DamageStabilization, Shield, LeftPod, HeavyAntiMatterCannon and AdvancedEngineering.
    ScenarioFramework.RestrictEnhancements({'T3Engineering',
                                            'RightPod',
                                            'ShieldGeneratorField',
                                            'TacticalMissile',
                                            'TacticalNukeMissile',
                                            'Teleporter'})

    SetIgnorePlayableRect(Aeon, true)

    -- Unit Cap
    ScenarioFramework.SetSharedUnitCap(300)

    -- Army Colors
    ScenarioFramework.SetUEFColor(Player)
    ScenarioFramework.SetAeonColor(Aeon)
    ScenarioFramework.SetUEFAllyColor(Arnold)
    local colors = {
        ['Coop1'] = {67, 110, 238}, 
        ['Coop2'] = {97, 109, 126}, 
        ['Coop3'] = {255, 255, 255}
    }
    local tblArmy = ListArmies()
    for army, color in colors do
        if tblArmy[ScenarioInfo[army]] then
            ScenarioFramework.SetArmyColor(ScenarioInfo[army], unpack(color))
        end
    end

    ScenarioFramework.SetPlayableArea('M1_Playable_Area', false)
    ScenarioFramework.StartOperationJessZoom('CDRZoom', IntroMission1)
end

function CDRAI(platoon)
    platoon.PlatoonData.LocationType = 'AeonMainBase'
    platoon:PatrolLocationFactoriesAI()
end

----------
-- End Game
----------
function KillBase()
    if(not ScenarioInfo.OpEnded) then
        ScenarioFramework.EndOperationSafety()
        ScenarioInfo.OpComplete = true

-- aeon cdr killed
--    ScenarioFramework.EndOperationCamera(ScenarioInfo.AeonCDR)
        ScenarioFramework.CDRDeathNISCamera(ScenarioInfo.AeonCDR)

        WaitSeconds(10)
        for i = 1, 4 do
            local units = GetUnitsInRect(ScenarioUtils.AreaToRect('BlastArea' .. i))
            local aeonUnits = {}
            if(units) then
                for k, v in units do
                    if(not v:IsDead() and v:GetAIBrain() == ArmyBrains[Aeon]) then
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
        ScenarioFramework.Dialogue(OpStrings.E03_M04_070, StartKillGame, true)
    end
end

function PlayerLose(deadCommander)
    ScenarioFramework.PlayerDeath(deadCommander, OpStrings.E03_D01_010)
end

function StartKillGame()
    ForkThread(KillGame)
end

function KillGame()
    if(not ScenarioInfo.OpComplete) then
        WaitSeconds(15)
    end
    local secondaries = Objectives.IsComplete(ScenarioInfo.M1S1) and Objectives.IsComplete(ScenarioInfo.M1S2)
    ScenarioFramework.EndOperation(ScenarioInfo.OpComplete, ScenarioInfo.OpComplete, secondaries)
end

-----------
-- Mission 1
-----------
function IntroMission1()
    ScenarioInfo.MissionNumber = 1

    -- Player CDR
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
        ScenarioFramework.CreateUnitDeathTrigger(PlayerLose, coopACU)
    end
    ScenarioFramework.CreateUnitDeathTrigger(PlayerLose, ScenarioInfo.PlayerCDR)
    WaitSeconds(5)

    ScenarioFramework.Dialogue(OpStrings.E03_M01_020)
    ScenarioFramework.Dialogue(OpStrings.E03_M01_040, StartMission1)
end

function StartMission1()
    -- Kickoff Eris taunts
    ScenarioFramework.CreateTimerTrigger(Taunt, Random(600, 900))

    -- After 2 minutes: EarthCom sub warning
    ScenarioFramework.CreateTimerTrigger(M1SubWarningDialogue, 120)

    -- After 3 minutes:
    ScenarioFramework.CreateTimerTrigger(M1FirstAirAttack, 180)

    -- After 20 minutes: Frigate Attack
    ScenarioFramework.CreateTimerTrigger(M1FrigateAttack, 1200)

    -- Primary Objective 1: Defeat Frigate Force
    ScenarioInfo.M1P1 = Objectives.Kill(
        'primary',                      -- type
        'incomplete',                   -- complete
        OpStrings.M1P1Title,            -- title
        OpStrings.M1P1Description,      -- description
        {                               -- target
            Units = ScenarioInfo.M1AeonDefenseFrigate:GetPlatoonUnits(),
        }
   )
    ScenarioInfo.M1P1:AddResultCallback(
        function()
            ScenarioFramework.Dialogue(OpStrings.E03_M01_080, ArnoldDeath)
        end
   )
    ScenarioFramework.CreateTimerTrigger(M1P1Reminder1, M1P1Time)

    -- Secondary Objective 1: Build Sonar Installation
    ScenarioInfo.M1S1 = Objectives.ArmyStatCompare(
        'secondary',                        -- type
        'incomplete',                       -- complete
        OpStrings.M1S2Title,                -- title
        OpStrings.M1S2Description,          -- description
        'build',                            -- action
        {                                   -- target
            Army = Player,
            StatName = 'Units_Active',
            CompareOp = '>=',
            Value = 1,
            Category = categories.ueb3102 + categories.ueb3202,
            ShowProgress = true,
        }
   )
end

function Taunt()
    if(ScenarioInfo.AeonCDR and not ScenarioInfo.AeonCDR:IsDead() and erisTaunt <= 8) then
        ScenarioFramework.Dialogue(OpStrings['TAUNT' .. erisTaunt])
        erisTaunt = erisTaunt + 1
        ScenarioFramework.CreateTimerTrigger(Taunt, Random(600, 900))
    end
end

function M1SubWarningDialogue()
    ScenarioFramework.Dialogue(OpStrings.E03_M01_030, AddM1SubObjective)
end

function AddM1SubObjective()
    -- Secondary Objective 2: Destroy all Enemy Submarine Groups
    local subs = {}
    for k, v in ScenarioInfo.M1Subs1:GetPlatoonUnits() do
        table.insert(subs, v)
    end
    for k, v in ScenarioInfo.M1Subs2:GetPlatoonUnits() do
        table.insert(subs, v)
    end
    ScenarioInfo.M1S2 = Objectives.Kill(
        'secondary',                        -- type
        'incomplete',                       -- complete
        OpStrings.M1S1Title,                -- title
        OpStrings.M1S1Description,          -- description
        {                                   -- target
            Units = subs,
        }
   )
end

function M1FirstAirAttack()
    if(ScenarioInfo.M1P1.Active) then
        ScenarioFramework.Dialogue(OpStrings.E03_M01_050)
        ScenarioFramework.CreateArmyStatTrigger(M1EnemiesKilled1, ArmyBrains[Player], 'M1EnemiesKilled1',
            {{StatType = 'Enemies_Killed', CompareType = 'GreaterThanOrEqual', Value = 4, Category = categories.ALLUNITS}})
        local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M1_FirstAir_Attack', 'ChevronFormation')
        platoon:MoveToLocation(ScenarioUtils.MarkerToPosition('M1_Spawn_Point' .. Random(1,5)), false)
        platoon:Patrol(ScenarioUtils.MarkerToPosition('Player_Attack_AirMain'))
        platoon:Patrol(ScenarioUtils.MarkerToPosition('M1_Aeon_Resource_Island_Main'))
        ForkThread(M1AirAttack)
    end
end

function M1FrigateAttack()
    if(ScenarioInfo.M1P1.Active) then
        ScenarioInfo.M1AeonDefenseFrigate:Stop()
        ScenarioInfo.M1AeonDefenseFrigate:Patrol(ScenarioUtils.MarkerToPosition('M1_FrigateAttack'))
    end
end

function M1AirAttack()
    WaitSeconds(Random(60, 180))
    if(ScenarioInfo.M1P1.Active) then
        local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M1_AirAttack_D' .. ScenarioInfo.Options.Difficulty, 'ChevronFormation')
        ScenarioFramework.CreatePlatoonDeathTrigger(RespawnM1AirAttack, platoon)
        platoon:MoveToLocation(ScenarioUtils.MarkerToPosition('M1_Spawn_Point' .. Random(1, 5)), false)
        platoon:Patrol(ScenarioUtils.MarkerToPosition('Player_Attack_Point' .. Random(1, 5)))
        platoon:Patrol(ScenarioUtils.MarkerToPosition('Player_Attack_AirMain'))
    end
end

function RespawnM1AirAttack()
    ForkThread(M1AirAttack)
end

function M1EnemiesKilled1()
    if(ScenarioInfo.M1P1.Active) then
        ScenarioFramework.Dialogue(OpStrings.E03_M01_060)
        ScenarioFramework.CreateArmyStatTrigger(M1EnemiesKilled2, ArmyBrains[Player], 'M1EnemiesKilled2',
            {{StatType = 'Enemies_Killed', CompareType = 'GreaterThanOrEqual', Value = 8, Category = categories.ALLUNITS}})
    end
end

function M1EnemiesKilled2()
    if(ScenarioInfo.M1P1.Active) then
        ScenarioFramework.Dialogue(OpStrings.E03_M01_070)
    end
end

function ArnoldDeath()
    if(ScenarioInfo.PlayerCDR and not ScenarioInfo.PlayerCDR:IsDead()) then

        -- Arnolds base should be beat up
        for k, v in ScenarioInfo.ArnoldBase do
            local health = v:GetHealth()
            v:AdjustHealth(v, Random(health / 2, (health - 1)) * -1)
        end

        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M1_Arnold_Attack', 'NoFormation')

        -- Spawn a second Arnold and nuke him too - so the base has the nuke explosion
        local unit = ScenarioUtils.CreateArmyUnit('Arnold', 'Arnold_CDR')

 -- Arnold killed camera stuff
        local camInfo = {
            blendTime = 1,
            holdTime = 13,
            orientationOffset = { math.pi, 0.7, 0 },
            positionOffset = { 0, 1, 0 },
            zoomVal = 65,
            resetCam = true,
            playableAreaIn = 'M3_Playable_Area',
            playableAreaOut = 'M1_Playable_Area',
--        vizRadius = 10,
        }
        ScenarioFramework.OperationNISCamera(unit, camInfo)

        WaitSeconds(3)
        unit:Kill()
        ScenarioFramework.Dialogue(OpStrings.E03_M01_090, ArnoldDeathConfirmed)
        WaitSeconds(10) -- Too long

        -- Destroy Arnold's Base
        for k,v in ScenarioInfo.ArnoldBase do
            if not v:IsDead() then
                v:Kill()
            end
        end
        SetAlliance(Arnold, Aeon, 'Neutral')
        SetAlliance(Aeon, Arnold, 'Neutral')
        for _, player in ScenarioInfo.HumanPlayers do
            SetAlliance(Arnold, player, 'Neutral')
            SetAlliance(player, Arnold,  'Neutral')
        end
    end
end

function ArnoldDeathConfirmed()
    if(ScenarioInfo.PlayerCDR and not ScenarioInfo.PlayerCDR:IsDead()) then
        WaitSeconds(10)
        ScenarioFramework.Dialogue(OpStrings.E03_M01_100, IntroMission2)
    end
end

-----------
-- Mission 2
-----------
function IntroMission2()
    ScenarioInfo.MissionNumber = 2
    ScenarioFramework.RemoveRestrictionForAllHumans(categories.ueb1201 + categories.uab1201) -- T2 Power Generator

    -- Island Engineers
    ScenarioUtils.CreateArmyGroup('Aeon', 'M3_Engineers')

    ScenarioFramework.Dialogue(OpStrings.E03_M02_010, StartMission2)
end

function StartMission2()
    -- Primary Objective 1: Defeat the Aeon Counterattack
    ScenarioInfo.M2P1 = Objectives.Basic(
        'primary',                          -- type
        'incomplete',                       -- complete
        OpStrings.M2P1Title,                -- title
        OpStrings.M2P1Description,          -- description
        Objectives.GetActionIcon('kill'),    -- action
        {
            ShowFaction = "Aeon",
        }
   )
    ScenarioFramework.CreateTimerTrigger(M2Wave1Dialogue, 10)
end

function M2Wave1Dialogue()
    WaitSeconds(10)
    ScenarioFramework.Dialogue(OpStrings.E03_M02_020, M2Wave1)
end

function M2Wave1()
    -- Air Attack
    local platoon = nil
    if(ScenarioInfo.Options.Difficulty == 1) then
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M2_AttackWave1_D1', 'ChevronFormation')
    elseif(ScenarioInfo.Options.Difficulty == 2) then
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M2_AttackWave1_D2', 'StaggeredChevronFormation')
    else
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M2_AttackWave1_D3', 'StaggeredChevronFormation')
    end

    -- 1/5 of platoon damaged 20 - 90%
    for k, v in platoon:GetPlatoonUnits() do
        local num = Random(1, 5)
        if(num == 1) then
            v:AdjustHealth(v, v:GetHealth() * (-.1 * (Random(2,9))))
        end
    end

    ScenarioFramework.CreatePlatoonDeathTrigger(M2Wave1Defeated, platoon)

    platoon:AggressiveMoveToLocation(ScenarioUtils.MarkerToPosition('Player_Attack_Point' .. Random(1,5)))
    platoon:AggressiveMoveToLocation(ScenarioUtils.MarkerToPosition('Player_Attack_AirMain'))
end

function M2Wave1Defeated()
    ScenarioFramework.Dialogue(OpStrings.E03_M02_030)
    ScenarioFramework.CreateTimerTrigger(M2Wave2Dialogue, 120)
end

function M2Wave2Dialogue()
    ScenarioFramework.Dialogue(OpStrings.E03_M02_040, M2Wave2)
end

function M2Wave2()
    -- Naval Attack
    local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M2_AttackWave2_D' .. ScenarioInfo.Options.Difficulty, 'AttackFormation')
    ScenarioFramework.CreatePlatoonDeathTrigger(M2Wave2Defeated, platoon)

    platoon:AggressiveMoveToLocation(ScenarioUtils.MarkerToPosition('M1_Defense_Point4'))
    platoon:AggressiveMoveToLocation(ScenarioUtils.MarkerToPosition('M1_Defense_Point3'))
    platoon:AggressiveMoveToLocation(ScenarioUtils.MarkerToPosition('M2_Aeon_Attack_RallyPoint'))
    platoon:AggressiveMoveToLocation(ScenarioUtils.MarkerToPosition('M2_NavalAttack'))
    platoon:Patrol(ScenarioUtils.MarkerToPosition('M2_Aeon_Attack_RallyPoint'))
    platoon:Patrol(ScenarioUtils.MarkerToPosition('M2_NavalAttack'))
end

function M2Wave2Defeated()
    ScenarioFramework.Dialogue(OpStrings.E03_M02_050)
    ScenarioFramework.CreateTimerTrigger(M2Wave3Dialogue, 120)
end

function M2Wave3Dialogue()
    ScenarioFramework.Dialogue(OpStrings.E03_M02_060, M2Wave3)
end

function M2Wave3()
    -- Air Attack
    local platoon = nil
    if(ScenarioInfo.Options.Difficulty == 1) then
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M2_AttackWave1_D1', 'ChevronFormation')
    elseif(ScenarioInfo.Options.Difficulty == 2) then
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M2_AttackWave1_D2', 'StaggeredChevronFormation')
    else
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M2_AttackWave1_D3', 'StaggeredChevronFormation')
    end
    ScenarioFramework.CreatePlatoonDeathTrigger(M2Wave3AirDefeated, platoon)
    platoon:Patrol(ScenarioUtils.MarkerToPosition('Player_Attack_Point' .. Random(1,5)))
    platoon:Patrol(ScenarioUtils.MarkerToPosition('Player_Attack_AirMain'))

    -- Naval Attack
    local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M2_AttackWave2_D' .. ScenarioInfo.Options.Difficulty, 'AttackFormation')
    ScenarioFramework.CreatePlatoonDeathTrigger(M2Wave3NavalDefeated, platoon)

    platoon:AggressiveMoveToLocation(ScenarioUtils.MarkerToPosition('M1_Defense_Point1'))
    platoon:AggressiveMoveToLocation(ScenarioUtils.MarkerToPosition('M1_Defense_Point2'))
    platoon:AggressiveMoveToLocation(ScenarioUtils.MarkerToPosition('M2_NavalAttack'))
    platoon:AggressiveMoveToLocation(ScenarioUtils.MarkerToPosition('M2_Aeon_Attack_RallyPoint'))
    platoon:Patrol(ScenarioUtils.MarkerToPosition('M2_NavalAttack'))
    platoon:Patrol(ScenarioUtils.MarkerToPosition('M2_Aeon_Attack_RallyPoint'))
end

function M2Wave3AirDefeated()
    ScenarioInfo.Wave3AirDefeated = true
    M2Wave3Defeated()
end

function M2Wave3NavalDefeated()
    ScenarioInfo.Wave3NavalDefeated = true
    M2Wave3Defeated()
end

function M2Wave3Defeated()
    if(ScenarioInfo.Wave3AirDefeated and ScenarioInfo.Wave3NavalDefeated) then
        ScenarioInfo.M2P1:ManualResult(true)
        ScenarioFramework.Dialogue(OpStrings.E03_M02_070, IntroMission3)
    end
end

-----------
-- Mission 3
-----------
function IntroMission3()
    ScenarioInfo.MissionNumber = 3

    ScenarioFramework.SetSharedUnitCap(480)

    -- Arnold's black box
    ScenarioInfo.ArnoldBox = ScenarioUtils.CreateArmyUnit('Arnold', 'Arnold_Black_Box')
    ScenarioInfo.ArnoldBox:SetCapturable(false)
    ScenarioInfo.ArnoldBox:SetCanTakeDamage(false)
    ScenarioInfo.ArnoldBox:SetCanBeKilled(false)

    -- Island Defenses
    local defense = ScenarioUtils.CreateArmyGroup('Aeon', 'M3_Defense_D' .. ScenarioInfo.Options.Difficulty)
    for k, v in defense do
        local platoon = ArmyBrains[Aeon]:MakePlatoon('','')
        ArmyBrains[Aeon]:AssignUnitsToPlatoon(platoon, {v}, 'attack', 'AttackFormation')
        platoon.PlatoonData = {}
        platoon.PlatoonData.PatrolChain = 'M3_Aeon_Defense_Chain'
        platoon:ForkAIThread(ScenarioPlatoonAI.RandomPatrolThread)
    end

    ScenarioFramework.RemoveRestrictionForAllHumans(
        categories.ueb2205 + categories.uab2205 +  -- T2 Torpedo Launcher
        categories.ueb3202 + categories.uab3202    -- Long Range Sonar
    )

    ScenarioFramework.Dialogue(OpStrings.E03_M03_010, StartMission3)
end

function StartMission3()
    ForkThread(M3AirPatrol)
    ForkThread(M3NavyPatrol)
    ForkThread(M3Strike)

    -- After 3 minutes
    ScenarioFramework.CreateTimerTrigger(M3NewSchematic, 180)

    -- After 6 minutes
    ScenarioFramework.CreateTimerTrigger(M3ErisTaunt1, 360)

    -- After 10 minutes
    ScenarioFramework.CreateTimerTrigger(M3ErisTaunt2, 600)

    -- Primary Objective 1: Reclaim Arnold's Black Box
    ScenarioInfo.M3P1 = Objectives.Reclaim(
        'primary',                          -- type
        'incomplete',                       -- complete
        OpStrings.M3P1Title,                -- title
        OpStrings.M3P1Description,          -- description
        {                                   -- target
            Units = {ScenarioInfo.ArnoldBox},
        }
   )
    ScenarioInfo.M3P1:AddResultCallback(
        function()
            ScenarioFramework.Dialogue(OpStrings.E03_M03_050, IntroMission4)
        end
   )
    ScenarioFramework.CreateTimerTrigger(M3P1Reminder1, ReminderDelay)

    ScenarioFramework.SetPlayableArea('M3_Playable_Area')
end

function M3AirPatrol()
    WaitSeconds(Random(30, 120))
    if(ScenarioInfo.M3P1.Active) then
        local air = ScenarioUtils.CreateArmyGroup('Aeon', 'M3_Air_D' .. ScenarioInfo.Options.Difficulty)
        ScenarioFramework.CreateGroupDeathTrigger(RespawnM3AirPatrol, air)
        for k, v in air do
            local chain = ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M3_Aeon_Patrol_Air_Chain'))
            for i = 1, table.getn(chain) do
                IssuePatrol({v}, chain[i])
            end
        end
    end
end

function RespawnM3AirPatrol()
    ForkThread(M3AirPatrol)
end

function M3NavyPatrol()
    WaitSeconds(Random(30, 120))
    if(ScenarioInfo.M3P1.Active) then
        local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M3_Frigate_D' .. ScenarioInfo.Options.Difficulty, 'TravellingFormation')
        ScenarioFramework.CreatePlatoonDeathTrigger(ReSpawnM3NavyPatrol, platoon)
        platoon.PlatoonData = {}
        platoon.PlatoonData.PatrolChain = 'M3_Aeon_Patrol_Navy_Chain'
        platoon:ForkAIThread(ScenarioPlatoonAI.PatrolThread)
    end
end

function ReSpawnM3NavyPatrol()
    ForkThread(M3NavyPatrol)
end

function M3Strike()
    WaitSeconds(Random(180, 300))
    if(ScenarioInfo.M3P1.Active) then
        local attacks = {
            'M3_Air_D' .. ScenarioInfo.Options.Difficulty,
            'M3_Frigate_D' .. ScenarioInfo.Options.Difficulty,
            'M3_Sub_D' .. ScenarioInfo.Options.Difficulty,
            'M3_Torpedo_D' .. ScenarioInfo.Options.Difficulty}
        local formations = {'ChevronFormation', 'AttackFormation', 'AttackFormation', 'ChevronFormation'}
        local num = Random(1,4)
        local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', attacks[num], formations[num])
        ScenarioFramework.CreatePlatoonDeathTrigger(ReSpawnM3Strike, platoon)
        platoon:Patrol(ScenarioUtils.MarkerToPosition('M3_Attack_PlayerBase'))
        platoon:Patrol(ScenarioUtils.MarkerToPosition('M3_Attack_EndPoint'))
    end
end

function ReSpawnM3Strike()
    ForkThread(M3Strike)
end

function M3NewSchematic()
    if ScenarioInfo.M3P1.Active then
        ScenarioFramework.Dialogue(OpStrings.E03_M03_020)
        ScenarioFramework.RemoveRestrictionForAllHumans(categories.ueb3201 + categories.uab3201) -- Long Range Radar
    end
end

function M3ErisTaunt1()
    if(ScenarioInfo.M3P1.Active) then
        ScenarioFramework.Dialogue(OpStrings.E03_M03_030)
    end
end

function M3ErisTaunt2()
    if(ScenarioInfo.M3P1.Active) then
        ScenarioFramework.Dialogue(OpStrings.E03_M03_040)
    end
end

-----------
-- Mission 4
-----------
function IntroMission4()
    ScenarioInfo.MissionNumber = 4

    ScenarioFramework.SetSharedUnitCap(660)

    -- Aeon Base
    ScenarioUtils.CreateArmyGroup('Aeon', 'M4_Aeon_ArtileryIsland')
    ScenarioUtils.CreateArmyGroup('Aeon', 'M4_DefenseAir_D' .. ScenarioInfo.Options.Difficulty)
    ScenarioUtils.CreateArmyGroup('Aeon', 'M4_DefenseTorpedo_D' .. ScenarioInfo.Options.Difficulty)
    ScenarioInfo.AirFactories = ScenarioUtils.CreateArmyGroup('Aeon', 'M4_Aeon_FactoryAir')
    ScenarioInfo.NavalFactories = ScenarioUtils.CreateArmyGroup('Aeon', 'M4_Aeon_FactoryNaval')
    ScenarioUtils.CreateArmyGroup('Aeon', 'M4_Aeon_ResourceProduction')
    ScenarioUtils.CreateArmyGroup('Aeon', 'M4_Engineers_D' .. ScenarioInfo.Options.Difficulty)

    -- T1 Navy
    for i = 1, 5 do
        local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M4_T1DefenseNavy' .. i .. '_D' .. ScenarioInfo.Options.Difficulty, 'AttackFormation')
        platoon.PlatoonData = {}
        platoon.PlatoonData.PatrolChain = 'M4_Aeon_DefenseFar_Chain'
        platoon:ForkAIThread(ScenarioPlatoonAI.RandomPatrolThread)
    end

    -- T2 Navy
    if(ScenarioInfo.Options.Difficulty == 1) then
        local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M4_T2DefenseNavy1_D1', 'AttackFormation')
        platoon.PlatoonData = {}
        platoon.PlatoonData.PatrolChain = 'M4_Aeon_DefenseFar_Chain'
        platoon:ForkAIThread(ScenarioPlatoonAI.RandomPatrolThread)
    elseif(ScenarioInfo.Options.Difficulty == 2) then
        for i = 1, 3 do
            local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M4_T2DefenseNavy' .. i .. '_D2', 'AttackFormation')
            platoon.PlatoonData = {}
            platoon.PlatoonData.PatrolChain = 'M4_Aeon_DefenseFar_Chain'
            platoon:ForkAIThread(ScenarioPlatoonAI.RandomPatrolThread)
        end
    elseif(ScenarioInfo.Options.Difficulty == 3) then
        for i = 1, 4 do
            local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M4_T2DefenseNavy' .. i .. '_D3', 'AttackFormation')
            platoon.PlatoonData = {}
            platoon.PlatoonData.PatrolChain = 'M4_Aeon_DefenseFar_Chain'
            platoon:ForkAIThread(ScenarioPlatoonAI.RandomPatrolThread)
        end
    end

    -- Air Middle
    local airMiddle = ScenarioUtils.CreateArmyGroup('Aeon', 'M4_DefenseAirMiddle_D' .. ScenarioInfo.Options.Difficulty)
    for k, v in airMiddle do
        local chain = ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M4_Aeon_DefenseMiddle_Chain'))
        for i = 1, table.getn(chain) do
            IssuePatrol({v}, chain[i])
        end
    end

    -- Air Base
    local airBase = ScenarioUtils.CreateArmyGroup('Aeon', 'M4_DefenseAirBase_D' .. ScenarioInfo.Options.Difficulty)
    for k, v in airBase do
        local chain = ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M4_Aeon_DefenseAir_Chain'))
        for i = 1, table.getn(chain) do
            IssuePatrol({v}, chain[i])
        end
    end

    -- Subs
    for i = 1, 3 do
        local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M4_DefenseSub' .. i .. '_D' .. ScenarioInfo.Options.Difficulty, 'AttackFormation')
        platoon.PlatoonData = {}
        platoon.PlatoonData.PatrolChain = 'M4_Aeon_DefenseTorpedo_Chain'
        platoon:ForkAIThread(ScenarioPlatoonAI.RandomPatrolThread)
    end

    ScenarioFramework.RemoveRestrictionForAllHumans(
        categories.ueb5202 + categories.uab5202 +  -- Air Staging Platform
        categories.ueb0203 + categories.uab0203 +  -- T2 Naval Factory
        categories.zeb9503 + categories.zab9503 +  -- T2 Support Naval Factory
        categories.ues0201 + categories.uas0201 +  -- Destroyer
        categories.ues0202 + categories.uas0202    -- Cruiser
    )

    ScenarioFramework.Dialogue(OpStrings.E03_M04_010, StartMission4)
end

function StartMission4()
    ScenarioFramework.CreateAreaTrigger(M4IslandApproach, ScenarioUtils.AreaToRect('Aeon_Island_Area'), categories.ALLUNITS, true, false, ArmyBrains[Player], 1, false)

    -- After 4 minutes
    ScenarioFramework.CreateTimerTrigger(M4ErisTaunt1, 240)

    -- After 10 minutes
    ScenarioFramework.CreateTimerTrigger(M4ErisTaunt2, 600)

    -- After 16 minutes
    ScenarioFramework.CreateTimerTrigger(M4ErisTaunt3, 960)

    -- Primary Objective 1: Kill or Capture the Aeon Princess
    ScenarioInfo.M4P1 = Objectives.Basic(
        'primary',
        'incomplete',
        OpStrings.M4P1Title,
        OpStrings.M4P1Description,
        Objectives.GetActionIcon('kill')
   )

    ScenarioFramework.SetPlayableArea(Rect(0, 0, 512, 512))
end

function M4IslandApproach()
    ScenarioFramework.Dialogue(OpStrings.E03_M04_020, AddObjectiveM4P2)
end

function AddObjectiveM4P2()
    ScenarioInfo.M4P1:ManualResult(true)
    ScenarioFramework.CreateUnitDeathTrigger(ErisKilled, ScenarioInfo.AeonCDR)

    -- local unitTable = {}
    -- table.insert(unitTable, ScenarioInfo.AeonCDR)
    -- for k, v in ScenarioInfo.AirFactories do
    -- table.insert(unitTable, v)
    -- end
    -- for k, v in ScenarioInfo.NavalFactories do
    -- table.insert(unitTable, v)
    -- end

    -- Primary Objective 2: Destroy the Aeon Commander's Main Base
    ScenarioInfo.M4P2 = Objectives.Kill(
        'primary',                      -- type
        'incomplete',                   -- complete
        OpStrings.M4P2Title,            -- title
        OpStrings.M4P2Description,      -- description
        {                               -- target
            Units = {ScenarioInfo.AeonCDR},
        }
   )
    ScenarioFramework.CreateTimerTrigger(M4P2Reminder1, ReminderDelay)
end

function ErisKilled()
    ForkThread(KillBase)
end

function M4ErisTaunt1()
    if(ScenarioInfo.AeonCDR and not ScenarioInfo.AeonCDR:IsDead()) then
        ScenarioFramework.Dialogue(OpStrings.E03_M04_030)
    end
end

function M4ErisTaunt2()
    if(ScenarioInfo.AeonCDR and not ScenarioInfo.AeonCDR:IsDead()) then
        ScenarioFramework.Dialogue(OpStrings.E03_M04_040)
    end
end

function M4ErisTaunt3()
    if(ScenarioInfo.AeonCDR and not ScenarioInfo.AeonCDR:IsDead()) then
        ScenarioFramework.Dialogue(OpStrings.E03_M04_050)
    end
end

---------------------
-- Objective Reminders
---------------------
function M1P1Reminder1()
    if(ScenarioInfo.M1P1.Active) then
        ScenarioFramework.Dialogue(OpStrings.E03_M01_120)
        ScenarioFramework.CreateTimerTrigger(M1P1Reminder2, ReminderDelay)
    end
end

function M1P1Reminder2()
    if(ScenarioInfo.M1P1.Active) then
        ScenarioFramework.Dialogue(OpStrings.E03_M01_125)
        ScenarioFramework.CreateTimerTrigger(M1P1Reminder3, ReminderDelay)
    end
end

function M1P1Reminder3()
    if(ScenarioInfo.M1P1.Active) then
        ScenarioFramework.Dialogue(ScenarioStrings.UEFGenericReminder)
        ScenarioFramework.CreateTimerTrigger(M1P1Reminder1, ReminderDelay)
    end
end

function M3P1Reminder1()
    if(ScenarioInfo.M3P1.Active) then
        ScenarioFramework.Dialogue(OpStrings.E03_M03_100)
        ScenarioFramework.CreateTimerTrigger(M3P1Reminder2, ReminderDelay)
    end
end

function M3P1Reminder2()
    if(ScenarioInfo.M3P1.Active) then
        ScenarioFramework.Dialogue(OpStrings.E03_M03_105)
        ScenarioFramework.CreateTimerTrigger(M3P1Reminder3, ReminderDelay)
    end
end

function M3P1Reminder3()
    if(ScenarioInfo.M3P1.Active) then
        ScenarioFramework.Dialogue(ScenarioStrings.UEFGenericReminder)
        ScenarioFramework.CreateTimerTrigger(M3P1Reminder1, ReminderDelay)
    end
end

function M4P2Reminder1()
    if(ScenarioInfo.M4P2.Active) then
        ScenarioFramework.Dialogue(OpStrings.E03_M04_100)
        ScenarioFramework.CreateTimerTrigger(M4P2Reminder2, ReminderDelay)
    end
end

function M4P2Reminder2()
    if(ScenarioInfo.M4P2.Active) then
        ScenarioFramework.Dialogue(OpStrings.E03_M04_105)
        ScenarioFramework.CreateTimerTrigger(M4P2Reminder3, ReminderDelay)
    end
end

function M4P2Reminder3()
    if(ScenarioInfo.M4P2.Active) then
        ScenarioFramework.Dialogue(ScenarioStrings.UEFGenericReminder)
        ScenarioFramework.CreateTimerTrigger(M4P2Reminder1, ReminderDelay)
    end
end
