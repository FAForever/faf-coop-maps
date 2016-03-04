-- ****************************************************************************
-- **
-- **  File     :  /maps/X1CA_Coop_004/X1CA_Coop_004_script.lua
-- **  Author(s):  Jessica St. Croix
-- **
-- **  Summary  : Main mission flow script for X1CA_Coop_004
-- **
-- **  Copyright 2007 Gas Powered Games, Inc.  All rights reserved.
-- ****************************************************************************
local Behaviors = import('/lua/ai/opai/OpBehaviors.lua')
local Cinematics = import('/lua/cinematics.lua')
local M1SeraphimAI = import('/maps/X1CA_Coop_004/X1CA_Coop_004_m1seraphimai.lua')
local M2SeraphimAI = import('/maps/X1CA_Coop_004/X1CA_Coop_004_m2seraphimai.lua')
local M3SeraphimAI = import('/maps/X1CA_Coop_004/X1CA_Coop_004_m3seraphimai.lua')
local Objectives = import('/lua/ScenarioFramework.lua').Objectives
local OpStrings = import('/maps/X1CA_Coop_004/X1CA_Coop_004_strings.lua')
local PingGroups = import('/lua/ScenarioFramework.lua').PingGroups
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local Utilities = import('/lua/utilities.lua')
local TauntManager = import('/lua/TauntManager.lua')

---------
-- Globals
---------
ScenarioInfo.Player = 1
ScenarioInfo.Dostya = 2
ScenarioInfo.Seraphim = 3
ScenarioInfo.SeraphimSecondary = 4
ScenarioInfo.Coop1 = 5
ScenarioInfo.Coop2 = 6
ScenarioInfo.Coop3 = 7

--------
-- Locals
--------
local Player = ScenarioInfo.Player
local Coop1 = ScenarioInfo.Coop1
local Coop2 = ScenarioInfo.Coop2
local Coop3 = ScenarioInfo.Coop3
local Dostya = ScenarioInfo.Dostya
local Seraphim = ScenarioInfo.Seraphim
local SeraphimSecondary = ScenarioInfo.SeraphimSecondary
local Difficulty = ScenarioInfo.Options.Difficulty

local AssignedObjectives = {}
local NukeHandles = {}

-- How long should we wait at the beginning of the NIS to allow slower machines to catch up?
local NIS1InitialDelay = 3

----------------
-- Taunt Managers
----------------
local OumEoshiTM = TauntManager.CreateTauntManager('OumEoshiTM', '/maps/X1CA_Coop_004/X1CA_Coop_004_Strings.lua')
local Hex5TM = TauntManager.CreateTauntManager('Hex5TM', '/maps/X1CA_Coop_004/X1CA_Coop_004_Strings.lua')

local LeaderFaction
local LocalFaction

---------
-- Startup
---------
function OnPopulate(scenario)
    ScenarioUtils.InitializeScenarioArmies()
    LeaderFaction, LocalFaction = ScenarioFramework.GetLeaderAndLocalFactions()

    -- Army Colors
    ScenarioFramework.SetCoalitionColor(Player)
    if(LeaderFaction == 'cybran') then
        ScenarioFramework.SetCybranPlayerColor(Player)
    elseif(LeaderFaction == 'uef') then
        ScenarioFramework.SetUEFPlayerColor(Player)
    elseif(LeaderFaction == 'aeon') then
        ScenarioFramework.SetAeonPlayerColor(Player)
    end
    ScenarioFramework.SetCybranAllyColor(Dostya)
    ScenarioFramework.SetSeraphimColor(Seraphim)
    ScenarioFramework.SetSeraphimColor(SeraphimSecondary)
    local colors = {
        ['Coop1'] = {250, 250, 0}, 
        ['Coop2'] = {255, 255, 255}, 
        ['Coop3'] = {97, 109, 126}
    }
    local tblArmy = ListArmies()
    for army, color in colors do
        if tblArmy[ScenarioInfo[army]] then
            ScenarioFramework.SetArmyColor(ScenarioInfo[army], unpack(color))
        end
    end

    -- Unit cap
    SetArmyUnitCap(Dostya, 200)
    SetArmyUnitCap(Seraphim, 800)

    ----------------
    -- M1 Seraphim AI
    ----------------
    M1SeraphimAI.SeraphimM1WestAI()

    --------------------------
    -- Seraphim Initial Patrols
    --------------------------
    local units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M1_Seraph_InitAir_Def_D' .. Difficulty, 'AttackFormation')
    for k, v in units:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M1_Seraph_AirPatrol_Chain')))
    end

    for i = 1, 2 do
        units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M1_Seraph_InitLand_Def' .. i .. '_D' .. Difficulty, 'AttackFormation')
        for k, v in units:GetPlatoonUnits() do
            ScenarioFramework.GroupPatrolChain({v}, 'M1_Seraph_LandPatrol_' .. i .. '_Chain')
        end
    end
end

function OnStart(self)
    --------------------
    -- Build Restrictions
    --------------------
    for _, player in ScenarioInfo.HumanPlayers do
        ScenarioFramework.AddRestriction(player,
            categories.xab2307 + -- Aeon Rapid Fire Artillery
            categories.xaa0305 + -- Aeon AA Gunship
            categories.xrb0104 + -- Cybran Engineering Station 1
            categories.xrb0204 + -- Cybran Engineering Station 2
            categories.xrb0304 + -- Cybran Engineering Station 3
            categories.xrb3301 + -- Cybran Perimeter Monitoring System
            categories.xra0305 + -- Cybran Heavy Gunship
            categories.xrl0403 + -- Cybran Amphibious Mega Bot
            categories.xeb0104 + -- UEF Engineering Station 1
            categories.xeb0204 + -- UEF Engineering Station 2
            categories.xea0306 + -- UEF Heavy Air Transport
            categories.xeb2402 + -- UEF Sub-Orbital Defense System
            categories.xsb2401   -- Seraphim Strategic Missile Launcher
        )
    end

    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_1_1'), 0)

    ForkThread(IntroMission1NIS)
end

----------
-- End Game
----------
function PlayerWin()
    if(not ScenarioInfo.OpEnded and not ScenarioInfo.TimerExpired) then
        ScenarioFramework.EndOperationSafety()
        ScenarioInfo.OpComplete = true
        ForkThread(KillGame)
    end
end

function PlayerLose(deadCommander)
    ScenarioFramework.PlayerDeath(deadCommander, nil, AssignedObjectives)
end

function KillGame()
    UnlockInput()
    ScenarioFramework.EndOperation(ScenarioInfo.OpComplete, ScenarioInfo.OpComplete, true)
end

-----------
-- Intro NIS
-----------
function IntroMission1NIS()
    Cinematics.EnterNISMode()

    -- Let slower machines catch up before we get going
    WaitSeconds(NIS1InitialDelay)

    ScenarioFramework.Dialogue(OpStrings.X04_M01_010, nil, true)

    ScenarioFramework.CreateVisibleAreaLocation(30, ScenarioUtils.MarkerToPosition('NIS_M1_Reveal_1'), 15, ArmyBrains[Player])
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_1_1'), 0)
    WaitSeconds(2)

    -- Dostya begins constructing a building
    -- If we need her to build another, add
    -- 'Dostya_build_target_2'
    -- to the function

    -- Spawn Dostya for NIS
    -- ScenarioInfo.DostyaCDR = ScenarioUtils.CreateArmyUnit('Dostya', 'Dostya')
    ScenarioInfo.DostyaCDR = ScenarioFramework.EngineerBuildUnits('Dostya', 'Dostya', 'Dostya_build_target_1')
    ScenarioInfo.DostyaCDR:PlayCommanderWarpInEffect()
    ScenarioInfo.DostyaCDR:SetCustomName(LOC '{i Dostya}')
    ScenarioInfo.DostyaCDR:SetCanBeKilled(false)
    ScenarioFramework.CreateUnitDeathTrigger(DostyaDeath, ScenarioInfo.DostyaCDR)

    -- "I am detecting an enemy base two clicks north of my position. I will advance and attack in 10 minutes. Dostya out."
    ScenarioFramework.Dialogue(OpStrings.X04_M01_020, nil, true)
    -- "Roger. HQ out"
    ScenarioFramework.Dialogue(OpStrings.X04_M01_028, nil, true)

    WaitSeconds(1)
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_1_2'), 10)
    WaitSeconds(1)

    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_1_3_2'), 3)

    -- Spawn in player
    ForkThread(SpawnPlayer)

    -- Play dialog: HQ: You're going to have concerns of your own, Commander.
    ScenarioFramework.Dialogue(OpStrings.X04_M01_023, nil, true)
    WaitSeconds(1)
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_1_3'), 4)
    -- WaitSeconds(1)

    -- ScenarioFramework.CreateVisibleAreaLocation(15, ScenarioUtils.MarkerToPosition('NIS_M1_Reveal_2'), 14, ArmyBrains[Player])
    local tempVisMarker = ScenarioFramework.CreateVisibleAreaLocation(50, ScenarioUtils.MarkerToPosition('NIS_M1_Reveal_3'), 0, ArmyBrains[Player])
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_1_4'), 5)
    -- The enemy is west
    ScenarioFramework.Dialogue(OpStrings.X04_M01_024, nil, true)
    -- Kill 'em
    ScenarioFramework.Dialogue(OpStrings.X04_M01_026, nil, true)

    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_1_5'), 8)
    WaitSeconds(1)
    ForkThread(function()
        WaitSeconds(2)
        tempVisMarker:Destroy()
        WaitSeconds(4)
        ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('NIS_M1_Reveal_3'), 50)
    end)
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_1_6'), 4)
    WaitSeconds(1)
    Cinematics.ExitNISMode()

    IntroMission1()
end

function SpawnPlayer()
    WaitSeconds(1.5)
    if(LeaderFaction == 'aeon') then
        ScenarioInfo.PlayerCDR = ScenarioFramework.SpawnCommander('Player', 'AeonPlayer', 'Warp', true, true, PlayerLose)
    elseif(LeaderFaction == 'cybran') then
        ScenarioInfo.PlayerCDR = ScenarioFramework.SpawnCommander('Player', 'CybranPlayer', 'Warp', true, true, PlayerLose)
    elseif(LeaderFaction == 'uef') then
        ScenarioInfo.PlayerCDR = ScenarioFramework.SpawnCommander('Player', 'UEFPlayer', 'Warp', true, true, PlayerLose)
    end

    -- spawn coop players too
    ScenarioInfo.CoopCDR = {}
    local tblArmy = ListArmies()
    coop = 1
    for iArmy, strArmy in pairs(tblArmy) do
        if iArmy >= ScenarioInfo.Coop1 then
            factionIdx = GetArmyBrain(strArmy):GetFactionIndex()
            if(factionIdx == 1) then
                ScenarioInfo.CoopCDR[coop] = ScenarioFramework.SpawnCommander(strArmy, 'UEFPlayer', 'Warp', true, true, PlayerLose)
            elseif(factionIdx == 2) then
                ScenarioInfo.CoopCDR[coop] = ScenarioFramework.SpawnCommander(strArmy, 'AeonPlayer', 'Warp', true, true, PlayerLose)
            else
                ScenarioInfo.CoopCDR[coop] = ScenarioFramework.SpawnCommander(strArmy, 'CybranPlayer', 'Warp', true, true, PlayerLose)
            end
            coop = coop + 1
            WaitSeconds(0.5)
        end
    end
end

-----------
-- Mission 1
-----------
function IntroMission1()
    ScenarioInfo.MissionNumber = 1

    ScenarioFramework.SetPlayableArea('M1Area', false)

    -- play opening dialogue, start mission. Lets not wait till end of dialogue to assign objs, as its a long bit of dialogue.
    ForkThread(M1UnitRevealTrigger)
    ForkThread(StartMission1)
end

function StartMission1()
    ForkThread(CheatEconomy)

    local units = ArmyBrains[Seraphim]:GetListOfUnits(categories.AIRSTAGINGPLATFORM + categories.FACTORY + categories.MASSEXTRACTION, false)
    ---------------------------------------------
    -- Primary Objective 1 - Destroy Seraphim Base
    ---------------------------------------------
    ScenarioInfo.M1P1 = Objectives.KillOrCapture(
        'primary',                      -- type
        'incomplete',                   -- complete
        OpStrings.X04_M01_OBJ_010_010,  -- title
        OpStrings.X04_M01_OBJ_010_020,  -- description
        {                               -- target
            FlashVisible = true,
            Units = units,
        }
   )
    ScenarioInfo.M1P1:AddResultCallback(
        function(result)
            if(result) then
                ScenarioFramework.Dialogue(OpStrings.X04_M01_050, IntroMission2)
            end
        end
   )
    table.insert(AssignedObjectives, ScenarioInfo.M1P1)
    -- Start reminder for M1P1
    ScenarioFramework.CreateTimerTrigger(M1P1Reminder1, 1020)

    ScenarioFramework.CreateTimerTrigger(DostyaBeginMissionDialogue, 420)

    ScenarioFramework.CreateTimerTrigger(M1BrickPingEvent, 1200)

    -- Dostya dialogue from offmap
    ScenarioFramework.CreateArmyStatTrigger(M1DostyaFinished, ArmyBrains[Player], 'M1FactoriesKilled',
        {{StatType = 'Enemies_Killed', CompareType = 'GreaterThanOrEqual', Value = 5, Category = categories.FACTORY}})

    -- A single taunt from Oum, for M1
    SetupOumEoshiM1Taunt()
end

function DostyaBeginMissionDialogue()
    ScenarioFramework.Dialogue(OpStrings.X04_M01_022)
end

function M1UnitRevealTrigger()
    -- Slight delay for unlocked units
    ScenarioFramework.CreateTimerTrigger(M1UnitReveal, 25)
end

function M1UnitReveal()
    -- UEF Engineering Station 1-2
    ScenarioFramework.UnrestrictWithVoiceover(categories.xeb0104, "uef", OpStrings.X04_M01_012)
    ScenarioFramework.RemoveRestrictionForAllHumans(categories.xeb0204)

    -- Cybran Engineering Station 1-3
    ScenarioFramework.Dialogue(OpStrings.X04_M01_013)
    ScenarioFramework.UnrestrictWithVoiceover(categories.xrb0104, "cybran", OpStrings.X04_M01_013)
    ScenarioFramework.RemoveRestrictionForAllHumans(categories.xrb0204)
    ScenarioFramework.RemoveRestrictionForAllHumans(categories.xrb0304)
end

function M1BrickPingEvent()
    if(ScenarioInfo.MissionNumber == 1) then
        ScenarioFramework.Dialogue(OpStrings.X04_M01_025)

        ScenarioInfo.M1BrickPing = PingGroups.AddPingGroup(OpStrings.X04_M01_OBJ_010_030, 'xrl0305', 'attack', OpStrings.X04_M01_OBJ_010_035)
        ScenarioInfo.M1BrickPing:AddCallback(M1BrickAttack)
    end
end

function M1BrickAttack(location)
    if(ScenarioInfo.MissionNumber == 1) then
        ScenarioInfo.M1BrickPingUsed = true
        ScenarioInfo.M1BrickPing:Destroy()

        local units = ScenarioUtils.CreateArmyGroupAsPlatoon('Dostya', 'M1_Dostya_Bricks_D' .. Difficulty, 'AttackFormation')
        units:Patrol(ScenarioUtils.MarkerToPosition('M1_Dostya_Bricks_Entry_Point'))
        units:Patrol(location)
        units:Patrol(ScenarioUtils.MarkerToPosition('M1_Dostya_Bricks_Exit_3'))
        for k, v in units:GetPlatoonUnits() do
            ScenarioFramework.CreateUnitToMarkerDistanceTrigger(KillBrick, v, ScenarioUtils.MarkerToPosition('M1_Dostya_Bricks_Exit_3'), 5)
        end
    end
end

function KillBrick(unit)
    if(ScenarioInfo.MissionNumber ~= 3) then
        if(unit) then
            unit:Destroy()
        end
    end
end

function M1DostyaFinished()
    -- for a touch of flavor, have Dostya mention she has completed her illusory offmap obj
    if(ScenarioInfo.MissionNumber == 1) then
        ScenarioFramework.Dialogue(OpStrings.X04_M01_027)
    end
end

-----------
-- Mission 2
-----------
function IntroMission2()
    ForkThread(
        function()
            ScenarioFramework.FlushDialogueQueue()
            while(ScenarioInfo.DialogueLock) do
                WaitSeconds(0.2)
            end

            ScenarioInfo.MissionNumber = 2

            if(ScenarioInfo.M1BrickPing) then
                ScenarioInfo.M1BrickPing:Destroy()
            end

            ----------------
            -- M2 Seraphim AI
            ----------------
            M2SeraphimAI.SeraphimM2LowerAI()
            M2SeraphimAI.SeraphimM2UpperAI()

            --------------------------
            -- Seraphim Initial Patrols
            --------------------------
            local units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M2_Seraph_AirPatrol_D' .. Difficulty, 'AttackFormation')
            for k, v in units:GetPlatoonUnits() do
                ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M2_Seraph_AirDef_Chain')))
            end

            -- spawns air superiority patrols for every 50 planes
            local num = 0
            for _, player in ScenarioInfo.HumanPlayers do
                num = num + table.getn(ArmyBrains[player]:GetListOfUnits(categories.AIR * categories.MOBILE, false))
            end

            if(num > 0) then
                num = math.ceil(num/50)
                for i = 1, num do
                    units = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Seraphim', 'M2_Seraph_Adapt_AirSup', 'AttackFormation', 5)
                    for k, v in units:GetPlatoonUnits() do
                        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M2_Seraph_AirDef_Chain')))
                    end
                end
            end

            for i = 1, 2 do
                units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M2_Seraph_LandPatrol' .. i .. '_D' .. Difficulty, 'AttackFormation')
                for k,v in units:GetPlatoonUnits() do
                    ScenarioFramework.GroupPatrolChain({v}, 'M2_Seraph_LandDef_' .. i .. '_Chain')
                end
            end

            -----------------
            -- Seraphim Jammer
            -----------------
            ScenarioInfo.Jammer = ScenarioUtils.CreateArmyUnit('Seraphim', 'M2_Seraph_Jammer')

            -------------
            -- Dostya Base
            -------------
            ScenarioUtils.CreateArmyGroup('Dostya', 'Dostya_Base')
            ScenarioUtils.CreateArmyGroup('Dostya', 'M2_Dostya_Base_Defenders')
            ScenarioUtils.CreateArmyGroup('Dostya', 'Dostya_Wreckage', true)

            ScenarioFramework.Dialogue(OpStrings.X04_M02_001, IntroMission2NIS)
        end
   )
end

function IntroMission2NIS()

    ScenarioFramework.SetPlayableArea('M2Area', false)
    -- Show the jammer
    local visMarker = ScenarioFramework.CreateVisibleAreaLocation(3, ScenarioInfo.Jammer:GetPosition(), 2, ArmyBrains[Player])

    Cinematics.EnterNISMode()
    ScenarioFramework.Dialogue(OpStrings.X04_M02_002, nil, true)
    WaitSeconds(2)
    ScenarioFramework.Dialogue(OpStrings.X04_M02_003, nil, true)
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_2_1'), 0)
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_2_2'), 6)
    WaitSeconds(1)
    ScenarioFramework.Dialogue(OpStrings.X04_M02_004, nil, true)

    local fakeMarker = {
        ['zoom'] = FLOAT(65.1),
        ['canSetCamera'] = BOOLEAN(true),
        ['canSyncCamera'] = BOOLEAN(true),
        ['color'] = STRING('ff808000'),
        ['editorIcon'] = STRING('/textures/editor/marker_mass.bmp'),
        ['type'] = STRING('Camera Info'),
        ['prop'] = STRING('/env/common/props/markers/M_Camera_prop.bp'),
        ['orientation'] = VECTOR3(-3.08869, 0.92, 0),
        ['position'] = ScenarioInfo.PlayerCDR:GetPosition(),
    }

    -- Snap back to the commander's position, wherever he is
    Cinematics.CameraMoveToMarker(fakeMarker, 0)
    WaitSeconds(2)

    Cinematics.ExitNISMode()

    -- visMarker:Destroy()

    M2InitialAttack()
    StartMission2()
end

function M2InitialAttack()
    local units = nil
    local trigger = {}

    -- Land Attacks
    units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M2_Seraph_InitAttack_North_D' .. Difficulty, 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(units, 'M2_Seraph_InitAttack_LandNorth_Chain')

    units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M2_Seraph_InitAttack_Mid_D' .. Difficulty, 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(units, 'M1_Seraph_Attack_2_Chain')

    units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M2_Seraph_InitAttack_South_D' .. Difficulty, 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(units, 'M2_Seraph_LandAttack_3_Chain')

    local num = 0
    for _, player in ScenarioInfo.HumanPlayers do
        num = num + table.getn(ArmyBrains[player]:GetListOfUnits(categories.ALLUNITS - categories.WALL, false))
    end
    if (Difficulty >= 2 and num > 250) then
        for i = 1, 2 do
            units = ScenarioUtils.CreateArmyGroup('Seraphim', 'M2_Seraph_InitAttack_Back_' .. i .. '_D' .. Difficulty)
            for k,v in units do
                ScenarioFramework.GroupPatrolChain({v}, 'M1_Seraph_Attack_2_Chain')
            end
        end
    end

    -- Spawns transport attacks for every 6, 4, 4 non-T1 defensive structures, up to 10 groups
    local num = 0
    for _, player in ScenarioInfo.HumanPlayers do
        num = num + table.getn(ArmyBrains[player]:GetListOfUnits((categories.STRUCTURE * categories.DEFENSE) - categories.TECH1, false))
    end

    if(num > 0) then
        trigger = {6, 4, 4}
        num = math.ceil(num/trigger[Difficulty])
        if(num > 10) then
            num = 10
        end
        for i = 1, num do
            for j = 1, 2 do
                units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M2_Seraph_InitAttack_Trans' .. j .. '_D' .. Difficulty, 'AttackFormation')
                for k,v in units:GetPlatoonUnits() do
                    if(v:GetUnitId() == 'xsa0104') then
                        local interceptors = ScenarioUtils.CreateArmyGroup('Seraphim', 'M2_Seraph_Trans_Interceptors')
                        IssueGuard(interceptors, v)
                        break
                    end
                end
                ScenarioFramework.PlatoonAttackWithTransports(units, 'M2_Init_Landing_Chain', 'M2_Init_TransAttack_Chain', false)
            end
        end
    end

    -- Air Attacks
    units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M2_Seraph_InitAttack_AirNorth_D' .. Difficulty, 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(units, 'M2_Seraph_AirAttack_1_Chain')

    units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M2_Seraph_InitAttack_AirSouth_D' .. Difficulty, 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(units, 'M2_Seraph_AirAttack_2_Chain')

    -- If player > 250 units, spawns gunships for every 60, 50, 40 land units, up to 7 groups
    local num = 0
    for _, player in ScenarioInfo.HumanPlayers do
        num = num + table.getn(ArmyBrains[player]:GetListOfUnits(categories.ALLUNITS - categories.WALL, false))
    end

    if(num > 250) then
        local num = 0
        for _, player in ScenarioInfo.HumanPlayers do
            num = num + table.getn(ArmyBrains[player]:GetListOfUnits((categories.LAND * categories.MOBILE) - categories.CONSTRUCTION, false))
        end

        if(num > 0) then
            trigger = {60, 50, 40}
            num = math.ceil(num/trigger[Difficulty])
            if(num > 7) then
                num = 7
            end
            for i = 1, num do
                units = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Seraphim', 'M2_Seraph_Adapt_Gunships', 'GrowthFormation', 5)
                ScenarioFramework.PlatoonPatrolChain(units, 'M2_Seraph_AirAttack_' .. Random(1,2) .. '_Chain')
            end
        end
    end

    -- Spawns Air Superiority for every 30, 25, 20 gunships, up to 10 groups
    local num = 0
    for _, player in ScenarioInfo.HumanPlayers do
        num = num + table.getn(ArmyBrains[player]:GetListOfUnits(categories.AIR * categories.GROUNDATTACK, false))
    end

    if(num > 0) then
        trigger = {30, 25, 20}
        num = math.ceil(num/trigger[Difficulty])
        for i = 1, num do
            units = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Seraphim', 'M2_Seraph_Adapt_AirSup', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(units, 'M2_Seraph_AirAttack_' .. Random(1,2) .. '_Chain')
        end
    end

    -- Spawns land units if player has > 25, 20, 15 T2/T3 defensive & artillery structures
    trigger = {25, 20, 15}
    local num = 0
    for _, player in ScenarioInfo.HumanPlayers do
        num = num + table.getn(ArmyBrains[player]:GetListOfUnits(((categories.DEFENSE * categories.STRUCTURE) + (categories.ARTILLERY * categories.STRUCTURE)) - categories.TECH1, false))
    end

    if(num > trigger[Difficulty]) then
        units = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Seraphim', 'M2_Seraph_InitAttack_North1', 'AttackFormation', 5)
        ScenarioFramework.PlatoonPatrolChain(units, 'M2_Seraph_InitAttack_LandNorth_Chain')
    end
    -- Spawns land units if player has > 40, 35, 25 T2/T3 defensive & artillery structures
    trigger = {40, 35, 25}
    if(num > trigger[Difficulty]) then
        units = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Seraphim', 'M2_Seraph_InitAttack_North2', 'AttackFormation', 5)
        ScenarioFramework.PlatoonPatrolChain(units, 'M2_Seraph_InitAttack_LandNorth_Chain')
    end
    -- Spawns land units if player has > 55, 50, 35 T2/T3 defensive & artillery structures
    trigger = {55, 50, 35}
    if(num > trigger[Difficulty]) then
        units = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Seraphim', 'M2_Seraph_InitAttack_North3', 'AttackFormation', 5)
        ScenarioFramework.PlatoonPatrolChain(units, 'M2_Seraph_InitAttack_LandNorth_Chain')
    end

    -- Spawns land units if player has > 350, 325, 300 units
    local num = 0
    for _, player in ScenarioInfo.HumanPlayers do
        num = num + table.getn(ArmyBrains[player]:GetListOfUnits(categories.ALLUNITS - categories.WALL, false))
    end

    trigger = {350, 325, 300}
    if(num > trigger[Difficulty]) then
        units = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Seraphim', 'M2_Seraph_InitAttack_Mid1', 'AttackFormation', 5)
        ScenarioFramework.PlatoonPatrolChain(units, 'M1_Seraph_Attack_2_Chain')
    end
    -- Spawns land units if player has > 400, 375, 350 units
    trigger = {400, 375, 350}
    if(num > trigger[Difficulty]) then
        units = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Seraphim', 'M2_Seraph_InitAttack_Mid2', 'AttackFormation', 5)
        ScenarioFramework.PlatoonPatrolChain(units, 'M1_Seraph_Attack_2_Chain')
    end
    -- Spawns land units if player has > 450, 425, 400 units
    trigger = {450, 425, 400}
    if(num > trigger[Difficulty]) then
        units = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Seraphim', 'M2_Seraph_InitAttack_Mid3', 'AttackFormation', 5)
        ScenarioFramework.PlatoonPatrolChain(units, 'M1_Seraph_Attack_2_Chain')
    end

    -- Spawns land units if player has > 70, 50, 30 T2/T3 land units
    local num = 0
    for _, player in ScenarioInfo.HumanPlayers do
        num = num + table.getn(ArmyBrains[player]:GetListOfUnits((categories.LAND * categories.MOBILE) - categories.TECH1 - categories.CONSTRUCTION, false))
    end

    trigger = {70, 50, 30}
    if(num > trigger[Difficulty]) then
        units = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Seraphim', 'M2_Seraph_InitAttack_South1', 'AttackFormation', 5)
        ScenarioFramework.PlatoonPatrolChain(units, 'M2_Seraph_LandAttack_3_Chain')
    end
    -- Spawns land units if player has > 140, 100, 50 T2/T3 land units
    trigger = {140, 100, 50}
    if(num > trigger[Difficulty]) then
        units = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Seraphim', 'M2_Seraph_InitAttack_South2', 'AttackFormation', 5)
        ScenarioFramework.PlatoonPatrolChain(units, 'M2_Seraph_LandAttack_3_Chain')
    end

    -- Spawns land units if player has > 50, 30, 20 T3 land units
    local num = 0
    for _, player in ScenarioInfo.HumanPlayers do
        num = num + table.getn(ArmyBrains[player]:GetListOfUnits((categories.LAND * categories.MOBILE * categories.TECH3) - categories.CONSTRUCTION, false))
    end

    trigger = {50, 30, 20}
    if(num > trigger[Difficulty]) then
        units = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Seraphim', 'M2_Seraph_InitAttack_South3', 'AttackFormation', 5)
        ScenarioFramework.PlatoonPatrolChain(units, 'M2_Seraph_LandAttack_3_Chain')
    end

    -- sends 2 groups of gunships at each land experimental, up to 5
    for _, player in ScenarioInfo.HumanPlayers do
        local exp = ArmyBrains[player]:GetListOfUnits(categories.LAND * categories.EXPERIMENTAL, false)
        num = table.getn(exp)
        if(num > 0) then
            if(num > 5) then
                num = 5
            end
            for i = 1, num do
                for j = 1, 2 do
                    units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M2_Seraph_Adapt_Gunships', 'GrowthFormation')
                    IssueAttack(units:GetPlatoonUnits(), exp[i])
                    ScenarioFramework.PlatoonPatrolChain(units, 'M2_Seraph_AirAttack_' .. Random(1,2) .. '_Chain')
                end
            end
        end
    end

    -- sends 2 groups of air superiority fighters at each air experimental, up to 5
    for _, player in ScenarioInfo.HumanPlayers do
        local exp = ArmyBrains[player]:GetListOfUnits(categories.AIR * categories.EXPERIMENTAL, false)
        num = table.getn(exp)
        if(num > 0) then
            if(num > 5) then
                num = 5
            end
            for i = 1, num do
                for j = 1, 2 do
                    units = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Seraphim', 'M2_Seraph_Adapt_AirSup', 'GrowthFormation', 5)
                    IssueAttack(units:GetPlatoonUnits(), exp[i])
                    ScenarioFramework.PlatoonPatrolChain(units, 'M2_Seraph_AirAttack_' .. Random(1,2) .. '_Chain')
                end
            end
        end
    end
end

function StartMission2()
    --------------------------------------
    -- Primary Objective 1 - Destroy Jammer
    --------------------------------------
    ScenarioInfo.M2P1 = Objectives.KillOrCapture(
        'primary',                          -- type
        'incomplete',                       -- complete
        OpStrings.X04_M02_OBJ_010_010,      -- title
        OpStrings.X04_M02_OBJ_010_020,      -- description
        {                                   -- target
            Units = {ScenarioInfo.Jammer},
        }
   )
    ScenarioInfo.M2P1:AddResultCallback(
        function(result)
            if(result) then
                -- play confirmation dialogue that you have destroyed jammer, and alude to incoming attack
                -- Then fire off the setup for Dostya's NIS, which contains the next batch of dialogue.
                ScenarioFramework.Dialogue(OpStrings.X04_M02_050, PreAttackDostya)
            end
        end
   )
    table.insert(AssignedObjectives, ScenarioInfo.M2P1)
    ScenarioFramework.CreateTimerTrigger(M2P1Reminder1, 900)

    -- Taunts starting in M2
    SetupOumEoshiTaunts()

    -- VO about jammer, when player is near it
    ScenarioFramework.CreateUnitNearTypeTrigger(M2JammerSpottedDialogue, ScenarioInfo.Jammer, ArmyBrains[Player], categories.ALLUNITS, 30)

    -- An expansion on the jammer topic by Rhiza, intended to be post NIS.
    -- Delayed a tad here, so we dont get things to back-to-back
    ScenarioFramework.CreateTimerTrigger(M2OpeningMoreInfoDialogue, 6)
    ScenarioFramework.CreateTimerTrigger(DostyaAirAttack, 300)

    if(LeaderFaction == 'cybran') then
        ScenarioFramework.CreateTimerTrigger(M2PingEvent, 600)

        -- Cybran Perimeter Monitoring System
        ScenarioFramework.UnrestrictWithVoiceoverAndDelay(categories.xrb3301, "cybran", 90, OpStrings.X04_M02_060)
    end
end

function M2JammerSpottedDialogue()
    ScenarioFramework.Dialogue(OpStrings.X04_M02_020)
end

function M2OpeningMoreInfoDialogue()
    ScenarioFramework.Dialogue(OpStrings.X04_M02_010)
end

function DostyaAirAttack()
    if(ScenarioInfo.MissionNumber == 2) then
    local units = ScenarioUtils.CreateArmyGroupAsPlatoon('Dostya', 'M2_Dostya_AirAttack_' .. Random(1, 3) .. '_D' .. Difficulty, 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(units, 'M2_Dostya_AirAttack_' .. Random(1, 2) .. '_Chain')

    ScenarioFramework.CreateTimerTrigger(DostyaAirAttack, 300)
    end
end

function M2PingEvent()
    if(ScenarioInfo.MissionNumber == 2) then
        ScenarioFramework.Dialogue(OpStrings.X04_M02_045)
        ScenarioInfo.M2Ping = PingGroups.AddPingGroup(OpStrings.X04_M01_OBJ_010_040, 'ura0304', 'attack', OpStrings.X04_M01_OBJ_010_045)
        ScenarioInfo.M2Ping:AddCallback(M2PingAttack)
    end
end

function M2PingAttack(location)
    if(ScenarioInfo.MissionNumber == 2) then
        ScenarioInfo.M2PingUsed = true
        ScenarioInfo.M2Ping:Destroy()

        local units = ScenarioUtils.CreateArmyGroupAsPlatoon('Dostya', 'M2_Dostya_Air_Ping', 'GrowthFormation')
        units:Patrol(ScenarioUtils.MarkerToPosition('M2_AirPing_Entry'))
        units:Patrol(location)
    end
end

function PreAttackDostya()
    ForkThread(
        function()
            ScenarioFramework.FlushDialogueQueue()
            while(ScenarioInfo.DialogueLock) do
                WaitSeconds(0.2)
            end

            ScenarioFramework.Dialogue(OpStrings.X04_M02_051, AttackDostya, true)
        end
   )
end

function AttackDostya()
    local units = nil

    IssueMove({ ScenarioInfo.DostyaCDR }, ScenarioUtils.MarkerToPosition('Dostya_Destination'))

    units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M2DostyaAttackAir', 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(units, 'DostyaAttackChain')

    units = ScenarioUtils.CreateArmyGroup('Seraphim', 'M2DostyaAttackLandEast')
    ScenarioFramework.GroupPatrolChain(units, 'DostyaAttackChain')

    units = ScenarioUtils.CreateArmyGroup('Seraphim', 'M2DostyaAttackLandWest')
    ScenarioFramework.GroupPatrolChain(units, 'DostyaAttackChain')

    -- Hex5
    ScenarioInfo.Hex5 = ScenarioFramework.SpawnCommander('Seraphim', 'M2_Hex5', false, LOC '{i Hex5}')
    ScenarioInfo.Hex5:SetCanTakeDamage(false)
    ScenarioFramework.CreateTimerTrigger(Hex5Vanish, 60)

    ForkThread(IntroMission3NIS)
end

function IntroMission3NIS()
    ScenarioFramework.SetPlayableArea('DostyaDeath')

    ScenarioInfo.NIS3_VisMarker = ScenarioFramework.CreateVisibleAreaLocation(100, ScenarioInfo.DostyaCDR:GetPosition(), 0, ArmyBrains[Player])
    Cinematics.EnterNISMode()
    WaitSeconds(1)
    NIS3Reinforcments()
    Cinematics.SetInvincible('M2Area')
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_3_1'), 0)
    -- Put Hex5 in place, with footprints showing that he came from somewhere
    IssueMove({ ScenarioInfo.Hex5 }, ScenarioUtils.MarkerToPosition('Hex5_Start'))
    ScenarioFramework.FlushDialogueQueue()
    -- And now, I present: Dave T.'s dialog summary
    -- HQ: "What's up?"
    ScenarioFramework.Dialogue(OpStrings.X04_M03_011, nil, true)
    -- Dostya: "Lots of dudes--like whoa it's a Cybran guy."
    ScenarioFramework.Dialogue(OpStrings.X04_M03_012, nil, true) -- , NIS3Reinforcments, true)
    -- Hex5: "Hi."
    ScenarioFramework.Dialogue(OpStrings.X04_M03_013, nil, true)
    -- Dostya: "You suck!"
    ScenarioFramework.Dialogue(OpStrings.X04_M03_014, NIS3Reinforcments, true)
    -- Hex5: "No, YOU suck.  Die."
    ScenarioFramework.Dialogue(OpStrings.X04_M03_015, nil, true)
    -- Dostya: "Aah! I'm dying!"
    ScenarioFramework.Dialogue(OpStrings.X04_M03_016, KillDostya, true)
    -- HQ: "Dostya! You died!"
    ScenarioFramework.Dialogue(OpStrings.X04_M03_017, nil, true)

    WaitSeconds(1)
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_3_2'), 8)

    WaitSeconds(1)
    IssueAggressiveMove({ ScenarioInfo.Hex5 }, ScenarioUtils.MarkerToPosition('Hex5_Destination'))
    WaitSeconds(1)
    Cinematics.CameraTrackEntity(ScenarioInfo.Hex5, 20, 2)
    WaitSeconds(2)
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_3_3'), 4)
    WaitSeconds(2)

    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_3_4'), 0)
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_3_5'), 8)
    WaitSeconds(1)
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_3_6'), 0)
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_3_7'), 5)
    WaitSeconds(1)

    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_3_8'), 0)
    WaitSeconds(1)
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_3_9'), 7)
    WaitSeconds(1)

    WaitSeconds(1)
    ScenarioInfo.NIS3_VisMarker:Destroy()
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_3_10'), 3)
    Cinematics.SetInvincible('M2Area', true)
    Cinematics.ExitNISMode()

    IntroMission3()
end

function NIS3Reinforcments()
    local units = ScenarioUtils.CreateArmyGroup('Seraphim', 'M2DostyaAttackLandEast')
    ScenarioFramework.GroupPatrolChain(units, 'DostyaAttackChain')

    units = ScenarioUtils.CreateArmyGroup('Seraphim', 'M2DostyaAttackLandWest')
    ScenarioFramework.GroupPatrolChain(units, 'DostyaAttackChain')
end

function Hex5Vanish()
    ScenarioInfo.Hex5:Destroy()
end

function KillDostya()
    if(ScenarioInfo.DostyaCDR and not ScenarioInfo.DostyaCDR:IsDead()) then
        ScenarioInfo.DostyaCDR:SetCanTakeDamage(true)
        ScenarioInfo.DostyaCDR:SetCanBeKilled(true)
        ScenarioInfo.DostyaCDR:Kill()
    end
end

function DostyaDeath()
    -- Spawn in Dostya's remains
    local px, py, pz = unpack(ScenarioInfo.DostyaCDR:GetPosition())
    local ox, oy, oz = unpack(ScenarioInfo.DostyaCDR:GetOrientation())

    ScenarioInfo.DostyaRemains = CreateUnitHPR('XRO4001', 'Dostya', px, py, pz, ox, oy, oz)
    ScenarioInfo.DostyaRemains:SetCapturable(false)
    ScenarioInfo.DostyaRemains:SetCanTakeDamage(false)
    ScenarioInfo.DostyaRemains:SetCanBeKilled(false)
    ScenarioInfo.DostyaRemains:SetDoNotTarget(true)

    -- Destroy all siege bots and the experimental
    local seraphimKillUnits = ScenarioFramework.GetCatUnitsInArea(categories.xsl0303 + categories.xsl0401, 'DostyaBase', ArmyBrains[Seraphim])
    if(seraphimKillUnits) then
        for k, v in seraphimKillUnits do
            v:Kill()
        end
    end

    -- Damage the remaining Seraphim attack
    local seraphimAttack = ScenarioFramework.GetCatUnitsInArea(categories.LAND * categories.MOBILE, 'DostyaBase', ArmyBrains[Seraphim])
    if(seraphimAttack) then
        for k, v in seraphimAttack do
            v:AdjustHealth(v, Random(v:GetHealth() * 3/4, v:GetHealth() - 1) * -1)
        end
    end
end

-----------
-- Mission 3
-----------
function IntroMission3()
    ScenarioInfo.MissionNumber = 3

    SetArmyUnitCap(Seraphim, 900)

    ----------------
    -- M3 Seraphim AI
    ----------------
    if(Difficulty > 1) then
        M3SeraphimAI.SeraphimM3SouthWestAI()
        M3SeraphimAI.SeraphimM3EastSouthEastAI()
    end
    M3SeraphimAI.SeraphimM3SouthAI()
    M3SeraphimAI.SeraphimM3NorthEastAI()
    M3SeraphimAI.SeraphimM3NorthAI()
    M3SeraphimAI.SeraphimM3NorthWestAI()
    M3SeraphimAI.SeraphimM3WestAI()
    M3SeraphimAI.SeraphimM3SouthEastAI()
    M3SeraphimAI.SeraphimM3EastAI()
    local towers = ArmyBrains[Seraphim]:GetListOfUnits(categories.xsb2303 + categories.xsb2204 + categories.xsb2304 + categories.xsb2301, false)
    for k,v in towers do
        v:SetVeterancy(5)
    end

    -------------------------
    -- Seraphim Initial Attack
    -------------------------

    local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M3_Seraph_InitAttack_S_D' .. Difficulty, 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_Seraph_AirAttack_Chain')

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M3_Seraph_InitAttack_NE_D' .. Difficulty, 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_NorthEast_LandAttack_Chain')

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M3_Seraph_InitAttack_N_D' .. Difficulty, 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_Seraph_AirAttack_Chain')

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M3_Seraph_InitAttack_NW_D' .. Difficulty, 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_NorthWest_LandAttack_Chain')

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M3_Seraph_InitAttack_W_D' .. Difficulty, 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_Seraph_AirAttackb_Chain')

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Seraphim', 'M3_Seraph_OuterAir_North_D' .. Difficulty, 'GrowthFormation', 5)
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_PlayerArea_AirPatrol_North_Chain')

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Seraphim', 'M3_Seraph_OuterAir_South_D' .. Difficulty, 'GrowthFormation', 5)
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_PlayerArea_AirPatrol_South_Chain')

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M3_Seraph_InitAttack_SE_D' .. Difficulty, 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_SouthEast_LandAttack_Chain')

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M3_Seraph_InitAttack_E_D' .. Difficulty, 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_East_LandAttack_Chain')

    if (Difficulty > 1) then
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M3_Seraph_InitAttack_SW_D' .. Difficulty, 'AttackFormation')
        ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_SouthWest_LandAttack_Chain')

        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M3_Seraph_InitAttack_ESE_D' .. Difficulty, 'GrowthFormation')
        ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_Seraph_AirAttack_Chain')
    end

    --------------------------------
    -- Seraphim Experimental Response
    --------------------------------
    for _, player in ScenarioInfo.HumanPlayers do
        local airExp = ArmyBrains[player]:GetListOfUnits(categories.EXPERIMENTAL * categories.AIR, false)
        if(table.getn(airExp) > 0) then
            local num = table.getn(airExp)
            if(num > 5) then
                num = 5
            end
            for i = 1, num do
                for j = 1, 2 do
                    platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Seraphim', 'Seraph_M3Adapt_AirSup_' .. j, 'GrowthFormation', 5)
                    for k, v in airExp do
                        if(v and not v:IsDead()) then
                            platoon:AttackTarget(v)
                        end
                    end
                    if(j == 1) then
                        ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_PlayerArea_AirPatrol_North_Chain')
                    else
                        ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_PlayerArea_AirPatrol_South_Chain')
                    end
                end
            end
        end
    end

    for _, player in ScenarioInfo.HumanPlayers do
        local landExp = ArmyBrains[player]:GetListOfUnits(categories.EXPERIMENTAL - categories.AIR, false)
        if(table.getn(landExp) > 0) then
            local num = table.getn(landExp)
            if(num > 5) then
                num = 5
            end
            for i = 1, num do
                platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Seraphim', 'Seraph_M3Adapt_StratBomb', 'GrowthFormation', 5)
                for k, v in landExp do
                    if(v and not v:IsDead()) then
                        platoon:AttackTarget(v)
                    end
                end
                local artillery = ArmyBrains[Player]:GetListOfUnits(categories.ARTILLERY * categories.STRUCTURE, false)
                if(table.getn(artillery) > 0) then
                    for k, v in artillery do
                        if(v and not v:IsDead()) then
                            platoon:AttackTarget(v)
                        end
                    end
                end
                if(Random(1,2) == 1) then
                    ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_PlayerArea_AirPatrol_North_Chain')
                else
                    ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_PlayerArea_AirPatrol_South_Chain')
                end
            end
        end
    end

    M3Experimentals()
    M3Nukes()

    ---------------------------
    -- Secondary Objective Units
    ---------------------------
    ScenarioUtils.CreateArmyGroup('Seraphim', 'M3_Seraph_NE_Radar_D' .. Difficulty)
    ScenarioUtils.CreateArmyGroup('Seraphim', 'M3_Seraph_NW_Radar_D' .. Difficulty)
    ScenarioUtils.CreateArmyGroup('Seraphim', 'M3_Seraph_SW_Radar_D' .. Difficulty)

    ScenarioInfo.NERadar = ScenarioUtils.CreateArmyUnit('Seraphim', 'M3_Seraph_Radar_NE')
    ScenarioInfo.NERadar:SetDoNotTarget(true)
    ScenarioInfo.NERadar:SetCanTakeDamage(false)
    ScenarioInfo.NERadar:SetReclaimable(false)
    ScenarioInfo.NWRadar = ScenarioUtils.CreateArmyUnit('Seraphim', 'M3_Seraph_Radar_NW')
    ScenarioInfo.NWRadar:SetDoNotTarget(true)
    ScenarioInfo.NWRadar:SetCanTakeDamage(false)
    ScenarioInfo.NWRadar:SetReclaimable(false)
    ScenarioInfo.SWRadar = ScenarioUtils.CreateArmyUnit('Seraphim', 'M3_Seraph_Radar_SW')
    ScenarioInfo.SWRadar:SetDoNotTarget(true)
    ScenarioInfo.SWRadar:SetCanTakeDamage(false)
    ScenarioInfo.SWRadar:SetReclaimable(false)

    ScenarioUtils.CreateArmyGroup('SeraphimSecondary', 'M3_Secondary_DefenseSwap_D' .. Difficulty)

    StartMission3()
end

function CheatEconomy()
    ArmyBrains[Seraphim]:GiveStorage('MASS', 10000)
    ArmyBrains[Seraphim]:GiveStorage('ENERGY', 300000)
    while(true) do
        ArmyBrains[Seraphim]:GiveResource('MASS', 10000)
        ArmyBrains[Seraphim]:GiveResource('ENERGY', 250000)
        WaitSeconds(1)
    end
end

function M3Experimentals()
    local platoon = nil

    if(Difficulty > 1) then
        ScenarioInfo.Experimental7 = ScenarioUtils.CreateArmyUnit('Seraphim', 'M3_SW_Experimental')
        ScenarioInfo.Experimental7:SetVeterancy(5)
        platoon = ArmyBrains[Seraphim]:MakePlatoon('', '')
        ArmyBrains[Seraphim]:AssignUnitsToPlatoon(platoon, {ScenarioInfo.Experimental7}, 'Attack', 'AttackFormation')
        ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_SouthWest_Exp_Chain')

        ScenarioInfo.Experimental17 = ScenarioUtils.CreateArmyUnit('Seraphim', 'M3_SW_Experimental_2')
        ScenarioInfo.Experimental17:SetVeterancy(5)
        platoon = ArmyBrains[Seraphim]:MakePlatoon('', '')
        ArmyBrains[Seraphim]:AssignUnitsToPlatoon(platoon, {ScenarioInfo.Experimental17}, 'Attack', 'AttackFormation')
        ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_SouthWest_Exp_Chain')

        ScenarioInfo.Experimental1 = ScenarioUtils.CreateArmyUnit('Seraphim', 'M3_ESE_Experimental')
        ScenarioInfo.Experimental1:SetVeterancy(5)
        platoon = ArmyBrains[Seraphim]:MakePlatoon('', '')
        ArmyBrains[Seraphim]:AssignUnitsToPlatoon(platoon, {ScenarioInfo.Experimental1}, 'Attack', 'AttackFormation')
        ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_EastSouthEast_Exp_Chain')

        ScenarioInfo.Experimental10 = ScenarioUtils.CreateArmyUnit('Seraphim', 'M3_ESE_Experimental_2')
        ScenarioInfo.Experimental10:SetVeterancy(5)
        platoon = ArmyBrains[Seraphim]:MakePlatoon('', '')
        ArmyBrains[Seraphim]:AssignUnitsToPlatoon(platoon, {ScenarioInfo.Experimental10}, 'Attack', 'AttackFormation')
        ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_EastSouthEast_Exp_Chain')
    end

    ScenarioInfo.Experimental6 = ScenarioUtils.CreateArmyUnit('Seraphim', 'M3_SE_Experimental')
    ScenarioInfo.Experimental6:SetVeterancy(5)
    platoon = ArmyBrains[Seraphim]:MakePlatoon('', '')
    ArmyBrains[Seraphim]:AssignUnitsToPlatoon(platoon, {ScenarioInfo.Experimental6}, 'Attack', 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_SouthEast_Exp_Chain')

    ScenarioInfo.Experimental16 = ScenarioUtils.CreateArmyUnit('Seraphim', 'M3_SE_Experimental_2')
    ScenarioInfo.Experimental16:SetVeterancy(5)
    platoon = ArmyBrains[Seraphim]:MakePlatoon('', '')
    ArmyBrains[Seraphim]:AssignUnitsToPlatoon(platoon, {ScenarioInfo.Experimental16}, 'Attack', 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_SouthEast_Exp_Chain')

    ScenarioInfo.Experimental2 = ScenarioUtils.CreateArmyUnit('Seraphim', 'M3_E_Experimental')
    ScenarioInfo.Experimental2:SetVeterancy(5)
    platoon = ArmyBrains[Seraphim]:MakePlatoon('', '')
    ArmyBrains[Seraphim]:AssignUnitsToPlatoon(platoon, {ScenarioInfo.Experimental2}, 'Attack', 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_East_Exp_Chain')

    ScenarioInfo.Experimental12 = ScenarioUtils.CreateArmyUnit('Seraphim', 'M3_E_Experimental_2')
    ScenarioInfo.Experimental12:SetVeterancy(5)
    platoon = ArmyBrains[Seraphim]:MakePlatoon('', '')
    ArmyBrains[Seraphim]:AssignUnitsToPlatoon(platoon, {ScenarioInfo.Experimental12}, 'Attack', 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_East_Exp_Chain')

    ScenarioInfo.Experimental3 = ScenarioUtils.CreateArmyUnit('Seraphim', 'M3_NE_Experimental')
    ScenarioInfo.Experimental3:SetVeterancy(5)
    platoon = ArmyBrains[Seraphim]:MakePlatoon('', '')
    ArmyBrains[Seraphim]:AssignUnitsToPlatoon(platoon, {ScenarioInfo.Experimental3}, 'Attack', 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_NorthEast_Exp_Chain')

    ScenarioInfo.Experimental4 = ScenarioUtils.CreateArmyUnit('Seraphim', 'M3_N_Experimental')
    ScenarioInfo.Experimental4:SetVeterancy(5)
    platoon = ArmyBrains[Seraphim]:MakePlatoon('', '')
    ArmyBrains[Seraphim]:AssignUnitsToPlatoon(platoon, {ScenarioInfo.Experimental4}, 'Attack', 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_North_Exp_Chain')

    ScenarioInfo.Experimental5 = ScenarioUtils.CreateArmyUnit('Seraphim', 'M3_NW_Experimental')
    ScenarioInfo.Experimental5:SetVeterancy(5)
    platoon = ArmyBrains[Seraphim]:MakePlatoon('', '')
    ArmyBrains[Seraphim]:AssignUnitsToPlatoon(platoon, {ScenarioInfo.Experimental5}, 'Attack', 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_NorthWest_Exp_Chain')

    ScenarioInfo.Experimental8 = ScenarioUtils.CreateArmyUnit('Seraphim', 'M3_S_Experimental')
    ScenarioInfo.Experimental8:SetVeterancy(5)
    platoon = ArmyBrains[Seraphim]:MakePlatoon('', '')
    ArmyBrains[Seraphim]:AssignUnitsToPlatoon(platoon, {ScenarioInfo.Experimental8}, 'Attack', 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_South_Exp_Chain')

    ScenarioInfo.Experimental9 = ScenarioUtils.CreateArmyUnit('Seraphim', 'M3_W_Experimental')
    ScenarioInfo.Experimental9:SetVeterancy(5)
    platoon = ArmyBrains[Seraphim]:MakePlatoon('', '')
    ArmyBrains[Seraphim]:AssignUnitsToPlatoon(platoon, {ScenarioInfo.Experimental9}, 'Attack', 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_West_Exp_Chain')

    ScenarioInfo.Experimental13 = ScenarioUtils.CreateArmyUnit('Seraphim', 'M3_NE_Experimental_2')
    ScenarioInfo.Experimental13:SetVeterancy(5)
    platoon = ArmyBrains[Seraphim]:MakePlatoon('', '')
    ArmyBrains[Seraphim]:AssignUnitsToPlatoon(platoon, {ScenarioInfo.Experimental13}, 'Attack', 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_NorthEast_Exp_Chain')

    ScenarioInfo.Experimental14 = ScenarioUtils.CreateArmyUnit('Seraphim', 'M3_N_Experimental_2')
    ScenarioInfo.Experimental14:SetVeterancy(5)
    platoon = ArmyBrains[Seraphim]:MakePlatoon('', '')
    ArmyBrains[Seraphim]:AssignUnitsToPlatoon(platoon, {ScenarioInfo.Experimental14}, 'Attack', 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_North_Exp_Chain')

    ScenarioInfo.Experimental15 = ScenarioUtils.CreateArmyUnit('Seraphim', 'M3_NW_Experimental_2')
    ScenarioInfo.Experimental15:SetVeterancy(5)
    platoon = ArmyBrains[Seraphim]:MakePlatoon('', '')
    ArmyBrains[Seraphim]:AssignUnitsToPlatoon(platoon, {ScenarioInfo.Experimental15}, 'Attack', 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_NorthWest_Exp_Chain')

    ScenarioInfo.Experimental18 = ScenarioUtils.CreateArmyUnit('Seraphim', 'M3_S_Experimental_2')
    ScenarioInfo.Experimental18:SetVeterancy(5)
    platoon = ArmyBrains[Seraphim]:MakePlatoon('', '')
    ArmyBrains[Seraphim]:AssignUnitsToPlatoon(platoon, {ScenarioInfo.Experimental18}, 'Attack', 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_South_Exp_Chain')

    ScenarioInfo.Experimental19 = ScenarioUtils.CreateArmyUnit('Seraphim', 'M3_W_Experimental_2')
    ScenarioInfo.Experimental19:SetVeterancy(5)
    platoon = ArmyBrains[Seraphim]:MakePlatoon('', '')
    ArmyBrains[Seraphim]:AssignUnitsToPlatoon(platoon, {ScenarioInfo.Experimental19}, 'Attack', 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_West_Exp_Chain')
end

function Experimental1Attack()
    if(ScenarioInfo.Experimental1 and not ScenarioInfo.Experimental1:IsDead()) then     -- ESE
        IssueStop({ScenarioInfo.Experimental1})
        IssueClearCommands({ScenarioInfo.Experimental1})
        ScenarioFramework.GroupPatrolChain({ScenarioInfo.Experimental1}, 'M3_Seraph_AirAttack_Chain')
    end
end

function Experimental2Attack()
    if(ScenarioInfo.Experimental2 and not ScenarioInfo.Experimental2:IsDead()) then     -- E
        IssueStop({ScenarioInfo.Experimental2})
        IssueClearCommands({ScenarioInfo.Experimental2})
        ScenarioFramework.GroupPatrolChain({ScenarioInfo.Experimental2}, 'M3_East_LandAttack_Chain')
    end
end

function Experimental3Attack()
    if(ScenarioInfo.Experimental3 and not ScenarioInfo.Experimental3:IsDead()) then     -- NE
        IssueStop({ScenarioInfo.Experimental3})
        IssueClearCommands({ScenarioInfo.Experimental3})
        ScenarioFramework.GroupPatrolChain({ScenarioInfo.Experimental3}, 'M3_NorthEast_LandAttack_Chain')
    end
end

function Experimental4Attack()
    if(ScenarioInfo.Experimental4 and not ScenarioInfo.Experimental4:IsDead()) then     -- N
        IssueStop({ScenarioInfo.Experimental4})
        IssueClearCommands({ScenarioInfo.Experimental4})
        ScenarioFramework.GroupPatrolChain({ScenarioInfo.Experimental4}, 'M3_SeraphNorth_Exp_Attack_Chain')
    end
end

function Experimental5Attack()
    if(ScenarioInfo.Experimental5 and not ScenarioInfo.Experimental5:IsDead()) then     -- NW
        IssueStop({ScenarioInfo.Experimental5})
        IssueClearCommands({ScenarioInfo.Experimental5})
        ScenarioFramework.GroupPatrolChain({ScenarioInfo.Experimental5}, 'M3_NorthWest_LandAttack_Chain')
    end
end

function Experimental6Attack()
    if(ScenarioInfo.Experimental6 and not ScenarioInfo.Experimental6:IsDead()) then     -- SE
        IssueStop({ScenarioInfo.Experimental6})
        IssueClearCommands({ScenarioInfo.Experimental6})
        ScenarioFramework.GroupPatrolChain({ScenarioInfo.Experimental6}, 'M3_SouthEast_LandAttack_Chain')
    end
end

function Experimental7Attack()
    if(ScenarioInfo.Experimental7 and not ScenarioInfo.Experimental7:IsDead()) then     -- SW
        IssueStop({ScenarioInfo.Experimental7})
        IssueClearCommands({ScenarioInfo.Experimental7})
        ScenarioFramework.GroupPatrolChain({ScenarioInfo.Experimental7}, 'M3_SouthWest_LandAttack_Chain')
    end
end

function Experimental8Attack()
    if(ScenarioInfo.Experimental8 and not ScenarioInfo.Experimental8:IsDead()) then     -- S
        IssueStop({ScenarioInfo.Experimental8})
        IssueClearCommands({ScenarioInfo.Experimental8})
        ScenarioFramework.GroupPatrolChain({ScenarioInfo.Experimental8}, 'M3_Seraph_AirAttack_Chain')
    end
end

function Experimental9Attack()
    if(ScenarioInfo.Experimental9 and not ScenarioInfo.Experimental9:IsDead()) then     -- W
        IssueStop({ScenarioInfo.Experimental9})
        IssueClearCommands({ScenarioInfo.Experimental9})
        ScenarioFramework.GroupPatrolChain({ScenarioInfo.Experimental9}, 'M3_SeraphWest_Exp_Attack_Chain')
    end
end

function D2ExperimentalAttack1()
    local num = 0
    for _, player in ScenarioInfo.HumanPlayers do
        num = num + table.getn(ArmyBrains[player]:GetListOfUnits(categories.EXPERIMENTAL, false))
    end
    if (num > 4) then
        if(ScenarioInfo.Experimental12 and not ScenarioInfo.Experimental12:IsDead()) then   -- E2
            IssueStop({ScenarioInfo.Experimental12})
            IssueClearCommands({ScenarioInfo.Experimental12})
            ScenarioFramework.GroupPatrolChain({ScenarioInfo.Experimental12}, 'M3_East_LandAttack_Chain')
        end
    end
end

function D2ExperimentalAttack2()
    local num = 0
    for _, player in ScenarioInfo.HumanPlayers do
        num = num + table.getn(ArmyBrains[player]:GetListOfUnits(categories.EXPERIMENTAL, false))
    end
    if (num > 3) then
        if(ScenarioInfo.Experimental17 and not ScenarioInfo.Experimental17:IsDead()) then   -- SW2
            IssueStop({ScenarioInfo.Experimental17})
            IssueClearCommands({ScenarioInfo.Experimental17})
            ScenarioFramework.GroupPatrolChain({ScenarioInfo.Experimental17}, 'M3_SouthWest_LandAttack_Chain')
        end
    end
end

function D2ExperimentalAttack3()
    local num = 0
    for _, player in ScenarioInfo.HumanPlayers do
        num = num + table.getn(ArmyBrains[player]:GetListOfUnits((categories.TECH3 * categories.MOBILE) - categories.ENGINEER, false))
    end
    if (num > 40) then
        if(ScenarioInfo.Experimental18 and not ScenarioInfo.Experimental18:IsDead()) then   -- S2
            IssueStop({ScenarioInfo.Experimental18})
            IssueClearCommands({ScenarioInfo.Experimental18})
            ScenarioFramework.GroupPatrolChain({ScenarioInfo.Experimental18}, 'M3_Seraph_AirAttack_Chain')
        end
    end
end

function D3ExperimentalAttack1()
    -- send E & SW
    if(ScenarioInfo.Experimental12 and not ScenarioInfo.Experimental12:IsDead()) then   -- E2
        IssueStop({ScenarioInfo.Experimental12})
        IssueClearCommands({ScenarioInfo.Experimental12})
        ScenarioFramework.GroupPatrolChain({ScenarioInfo.Experimental12}, 'M3_East_LandAttack_Chain')
    end
    if(ScenarioInfo.Experimental17 and not ScenarioInfo.Experimental17:IsDead()) then   -- SW2
         IssueStop({ScenarioInfo.Experimental17})
         IssueClearCommands({ScenarioInfo.Experimental17})
         ScenarioFramework.GroupPatrolChain({ScenarioInfo.Experimental17}, 'M3_SouthWest_LandAttack_Chain')
    end
end

function D3ExperimentalAttack2()
    -- send NE & W
    if(ScenarioInfo.Experimental13 and not ScenarioInfo.Experimental13:IsDead()) then   -- NE2
        IssueStop({ScenarioInfo.Experimental13})
        IssueClearCommands({ScenarioInfo.Experimental13})
        ScenarioFramework.GroupPatrolChain({ScenarioInfo.Experimental13}, 'M3_NorthEast_LandAttack_Chain')
    end
    if(ScenarioInfo.Experimental19 and not ScenarioInfo.Experimental19:IsDead()) then   -- W2
        IssueStop({ScenarioInfo.Experimental19})
        IssueClearCommands({ScenarioInfo.Experimental19})
        ScenarioFramework.GroupPatrolChain({ScenarioInfo.Experimental19}, 'M3_SeraphWest_Exp_Attack_Chain')
    end
end

function D3ExperimentalAttack3()
    -- send NW & SE
    if(ScenarioInfo.Experimental15 and not ScenarioInfo.Experimental15:IsDead()) then   -- NW2
        IssueStop({ScenarioInfo.Experimental15})
        IssueClearCommands({ScenarioInfo.Experimental15})
        ScenarioFramework.GroupPatrolChain({ScenarioInfo.Experimental15}, 'M3_NorthWest_LandAttack_Chain')
    end
    if(ScenarioInfo.Experimental16 and not ScenarioInfo.Experimental16:IsDead()) then   -- SE2
        IssueStop({ScenarioInfo.Experimental16})
        IssueClearCommands({ScenarioInfo.Experimental16})
        ScenarioFramework.GroupPatrolChain({ScenarioInfo.Experimental16}, 'M3_SouthEast_LandAttack_Chain')
    end
end

function D3ExperimentalAttack4()
    -- send ESE & N & S
    if(ScenarioInfo.Experimental10 and not ScenarioInfo.Experimental10:IsDead()) then   -- ESE2
        IssueStop({ScenarioInfo.Experimental10})
        IssueClearCommands({ScenarioInfo.Experimental10})
        ScenarioFramework.GroupPatrolChain({ScenarioInfo.Experimental10}, 'M3_Seraph_AirAttack_Chain')
    end
    if(ScenarioInfo.Experimental14 and not ScenarioInfo.Experimental14:IsDead()) then   -- N2
        IssueStop({ScenarioInfo.Experimental14})
        IssueClearCommands({ScenarioInfo.Experimental14})
        ScenarioFramework.GroupPatrolChain({ScenarioInfo.Experimental14}, 'M3_SeraphNorth_Exp_Attack_Chain')
    end
    if(ScenarioInfo.Experimental18 and not ScenarioInfo.Experimental18:IsDead()) then   -- S2
        IssueStop({ScenarioInfo.Experimental18})
        IssueClearCommands({ScenarioInfo.Experimental18})
        ScenarioFramework.GroupPatrolChain({ScenarioInfo.Experimental18}, 'M3_Seraph_AirAttack_Chain')
    end
end

function M3Nukes()
    local nukes = ScenarioUtils.CreateArmyGroup('Seraphim', 'M3_Seraph_Nukes_D' .. Difficulty)
    for k,v in nukes do
        v:GiveNukeSiloAmmo(1)
    end
end

function CreateProjectileAtMuzzle(self,muzzle)
    local proj = self:CreateProjectileForWeapon(muzzle)
    if not proj or proj:BeenDestroyed()then
        return proj
    end
    local bp = self:GetBlueprint()
    if bp.DetonatesAtTargetHeight == true then
        local pos = self:GetCurrentTargetPos()
        if pos then
            local theight = GetSurfaceHeight(pos[1], pos[3])
            local hght = pos[2] - theight
            proj:ChangeDetonateAboveHeight(hght)
        end
    end
    if bp.Flare then
        proj:AddFlare(bp.Flare)
    end
    if self.unit:GetCurrentLayer() == 'Water' and bp.Audio.FireUnderWater then
        self:PlaySound(bp.Audio.FireUnderWater)
    elseif bp.Audio.Fire then
        self:PlaySound(bp.Audio.Fire)
    end
    table.insert(NukeHandles, proj)
    return proj
end

function M3LaunchNukes()
    ForkThread(
        function()
            local nuke = nil

            ForkThread(WaitDeleteNukes, 22)

            for i = 1, 3 do
                nuke = ScenarioInfo.UnitNames[Seraphim]['M3_Seraph_Nuke_NE_' .. i]
                if(nuke and not nuke:IsDead()) then
                    nuke:GetWeapon(1)['CreateProjectileAtMuzzle'] = CreateProjectileAtMuzzle
                    IssueNuke({nuke}, ScenarioUtils.MarkerToPosition('M1_Seraph_AttackPlateau_' .. Random(1, 16)))
                end
            end

            WaitSeconds(.5)

            for i = 1, 3 do
                nuke = ScenarioInfo.UnitNames[Seraphim]['M3_Seraph_Nuke_NW_' .. i]
                if(nuke and not nuke:IsDead()) then
                    nuke:GetWeapon(1)['CreateProjectileAtMuzzle'] = CreateProjectileAtMuzzle
                    IssueNuke({nuke}, ScenarioUtils.MarkerToPosition('M1_Seraph_AttackPlateau_' .. Random(1, 16)))
                end
            end

            WaitSeconds(.5)

            for i = 1, 3 do
                nuke = ScenarioInfo.UnitNames[Seraphim]['M3_Seraph_Nuke_N_' .. i]
                if(nuke and not nuke:IsDead()) then
                    nuke:GetWeapon(1)['CreateProjectileAtMuzzle'] = CreateProjectileAtMuzzle
                    IssueNuke({nuke}, ScenarioUtils.MarkerToPosition('M1_Seraph_AttackPlateau_' .. Random(1, 16)))
                end
            end

            WaitSeconds(.5)

            for i = 1, 3 do
                nuke = ScenarioInfo.UnitNames[Seraphim]['M3_Seraph_Nuke_SE_' .. i]
                if(nuke and not nuke:IsDead()) then
                    nuke:GetWeapon(1)['CreateProjectileAtMuzzle'] = CreateProjectileAtMuzzle
                    IssueNuke({nuke}, ScenarioUtils.MarkerToPosition('M1_Seraph_AttackPlateau_' .. Random(1, 16)))
                end
            end
            WaitSeconds(.5)

            if (Difficulty > 1) then
                for i = 1, 3 do
                    nuke = ScenarioInfo.UnitNames[Seraphim]['M3_Seraph_Nuke_SW_' .. i]
                    if(nuke and not nuke:IsDead()) then
                        nuke:GetWeapon(1)['CreateProjectileAtMuzzle'] = CreateProjectileAtMuzzle
                        IssueNuke({nuke}, ScenarioUtils.MarkerToPosition('M1_Seraph_AttackPlateau_' .. Random(1, 16)))
                    end
                end
                WaitSeconds(.5)
            end

            for i = 1, 3 do
                nuke = ScenarioInfo.UnitNames[Seraphim]['M3_Seraph_Nuke_S_' .. i]
                if(nuke and not nuke:IsDead()) then
                    nuke:GetWeapon(1)['CreateProjectileAtMuzzle'] = CreateProjectileAtMuzzle
                    IssueNuke({nuke}, ScenarioUtils.MarkerToPosition('M1_Seraph_AttackPlateau_' .. Random(1, 16)))
                end
            end

            WaitSeconds(.5)

            if (Difficulty > 1) then
                for i = 1, 3 do
                    nuke = ScenarioInfo.UnitNames[Seraphim]['M3_Seraph_Nuke_ESE_' .. i]
                    if(nuke and not nuke:IsDead()) then
                        nuke:GetWeapon(1)['CreateProjectileAtMuzzle'] = CreateProjectileAtMuzzle
                        IssueNuke({nuke}, ScenarioUtils.MarkerToPosition('M1_Seraph_AttackPlateau_' .. Random(1, 16)))
                    end
                end
            end

            WaitSeconds(.5)

            for i = 1, 3 do
                nuke = ScenarioInfo.UnitNames[Seraphim]['M3_Seraph_Nuke_E_' .. i]
                if(nuke and not nuke:IsDead()) then
                    nuke:GetWeapon(1)['CreateProjectileAtMuzzle'] = CreateProjectileAtMuzzle
                    IssueNuke({nuke}, ScenarioUtils.MarkerToPosition('M1_Seraph_AttackPlateau_' .. Random(1, 16)))
                end
            end

            WaitSeconds(.5)

            for i = 1, 3 do
                nuke = ScenarioInfo.UnitNames[Seraphim]['M3_Seraph_Nuke_W_' .. i]
                if(nuke and not nuke:IsDead()) then
                    nuke:GetWeapon(1)['CreateProjectileAtMuzzle'] = CreateProjectileAtMuzzle
                    IssueNuke({nuke}, ScenarioUtils.MarkerToPosition('M1_Seraph_AttackPlateau_' .. Random(1, 16)))
                end
            end
        end
   )
end

function StartMission3()
    ----------------------------------------------
    -- Primary Objective 1 - Survive Until Recalled
    ----------------------------------------------
    ScenarioInfo.M3P1 = Objectives.Timer(
        'primary',                      -- type
        'incomplete',                   -- complete
        OpStrings.X04_M03_OBJ_010_010,  -- title
        OpStrings.X04_M03_OBJ_010_020,  -- description
        {                               -- target
            Timer = 1200,
            ExpireResult = 'complete',
        }
   )
    ScenarioInfo.M3P1:AddResultCallback(
        function(result)
            if(result) then
                PlayerWin()
            end
        end
   )
    table.insert(AssignedObjectives, ScenarioInfo.M3P1)

    -- Trigger to win the game if you kill all factories and nuke launchers
    ScenarioFramework.CreateArmyStatTrigger(M3Destroyed, ArmyBrains[Seraphim], 'M3Destroyed',
        {{StatType = 'Units_Active', CompareType = 'LessThanOrEqual', Value = 0, Category = categories.xsb2305 + categories.FACTORY}})

    -- Play update at 15, 10, and ~5 minutes
    ScenarioFramework.CreateTimerTrigger(M3RecallCountdown3, 900)
    ScenarioFramework.CreateTimerTrigger(M3RecallCountdown2, 600)
    ScenarioFramework.CreateTimerTrigger(M3RecallCountdown1, 330)

    if(Difficulty > 1) then
        ScenarioFramework.CreateTimerTrigger(Experimental1Attack, 1134)  -- ESE
        ScenarioFramework.CreateTimerTrigger(Experimental7Attack, 1115)  -- SW
    end
    ScenarioFramework.CreateTimerTrigger(Experimental2Attack, 1159)  -- E
    ScenarioFramework.CreateTimerTrigger(Experimental3Attack, 1055)  -- NE
    ScenarioFramework.CreateTimerTrigger(Experimental4Attack, 1010)  -- N
    ScenarioFramework.CreateTimerTrigger(Experimental5Attack, 1034)  -- NW
    ScenarioFramework.CreateTimerTrigger(Experimental6Attack, 1150)  -- SE
    ScenarioFramework.CreateTimerTrigger(Experimental8Attack, 1140)  -- S
    ScenarioFramework.CreateTimerTrigger(Experimental9Attack, 1055)  -- W
    ScenarioFramework.CreateTimerTrigger(M3PreNukeDialogue, 1170)    -- this should slightly preceed the nuke launch
    ScenarioFramework.CreateTimerTrigger(M3LaunchNukes, 1178)
    ScenarioFramework.CreateTimerTrigger(OutroNIS, 1195)

    if(Difficulty == 2) then
        ScenarioFramework.CreateTimerTrigger(D2ExperimentalAttack1, 300)
        ScenarioFramework.CreateTimerTrigger(D2ExperimentalAttack2, 600)
        ScenarioFramework.CreateTimerTrigger(D2ExperimentalAttack3, 900)
    end

    if(Difficulty == 3) then
        D3ExperimentalAttack1()
        ScenarioFramework.CreateTimerTrigger(D3ExperimentalAttack2, 240)
        ScenarioFramework.CreateTimerTrigger(D3ExperimentalAttack3, 480)
        ScenarioFramework.CreateTimerTrigger(D3ExperimentalAttack4, 720)
    end

    -- Non NIS dialogue, telling the player to hang in there
    ScenarioFramework.Dialogue(OpStrings.X04_M03_020)

    -- Some faction-specific additional dialogue, with secondaries
    if(LeaderFaction == 'uef') then
        ScenarioFramework.Dialogue(OpStrings.X04_M03_040)
    end
    if(LeaderFaction == 'cybran') then
        ScenarioFramework.Dialogue(OpStrings.X04_M03_050, M3CybranSecondary)
    end
    if(LeaderFaction == 'aeon') then
        ScenarioFramework.Dialogue(OpStrings.X04_M03_030, M3AeonSecondary)
    end

    -- Wrap it up with some smack talk from the Seraph, in response (trigger some reveal dialogue thereafter)
    ScenarioFramework.Dialogue(OpStrings.X04_M03_055, M3AeonTechRevealTrigger)

    -- Hex5 taunts for Mission 3
    SetupHex5M3Taunts()
    ScenarioFramework.SetPlayableArea('M3Area')
end

function M3Destroyed()
    if(ScenarioInfo.M3P1.Active) then
        ScenarioInfo.M3P1:ManualResult(true)
    end
end

function M3AeonTechRevealTrigger()
    -- Aeon rapid fire artillery.
    ScenarioFramework.UnrestrictWithVoiceoverAndDelay(categories.xab2307, "aeon", 20, OpStrings.X04_M03_056)
end

function M3RecallCountdown1()
    -- 20 mins left
    ScenarioFramework.Dialogue(OpStrings.X04_M03_060) -- TODO: replace this dialogue with non-time-specific VO
end

function M3RecallCountdown2()
    -- 13 mins left
    ScenarioFramework.Dialogue(OpStrings.X04_M03_070) -- TODO: replace this dialogue with non-time-specific VO
end

function M3RecallCountdown3()
    -- 4 mins left
    ScenarioFramework.Dialogue(OpStrings.X04_M03_080)
end

function M3PreNukeDialogue()
    -- Some faction-specific smack talk just before the nukes are launched
    if(LeaderFaction == 'uef') then
        ScenarioFramework.Dialogue(OpStrings.X04_M03_090)
    end
    if(LeaderFaction == 'cybran') then
        ScenarioFramework.Dialogue(OpStrings.X04_M03_100)
    end
    if(LeaderFaction == 'aeon') then
        ScenarioFramework.Dialogue(OpStrings.X04_M03_110)
    end
end

function M3CybranSecondary()
    --------------------------------------------------
    -- Secondary Objective 1 - Recover Dostya©s Remains
    --------------------------------------------------
    ScenarioInfo.M3S1Cybran = Objectives.Reclaim(
        'secondary',                    -- type
        'incomplete',                   -- complete
        OpStrings.X04_M03_OBJ_010_030,  -- title
        OpStrings.X04_M03_OBJ_010_040,  -- description
        {                               -- target
            Units = {ScenarioInfo.DostyaRemains},
        }
   )
    ScenarioInfo.M3S1Cybran:AddResultCallback(
        function(result)
            if(result) then
                ScenarioFramework.Dialogue(OpStrings.X04_M03_160)
            end
        end
   )
    table.insert(AssignedObjectives, ScenarioInfo.M3S1Cybran)
    -- obj dialogue, start timer for reminder
    ScenarioFramework.Dialogue(OpStrings.X04_M03_130)
    ScenarioFramework.CreateTimerTrigger(M3S1CybranReminder1, 600)
end

function M3AeonSecondary()
    ----------------------------------------------
    -- Secondary Objective - Capture Seraphim Radar
    ----------------------------------------------
    ScenarioInfo.M3S1Aeon = Objectives.Capture(
        'secondary',                    -- type
        'incomplete',                   -- complete
        OpStrings.X04_M03_OBJ_010_050,  -- title
        OpStrings.X04_M03_OBJ_010_060,  -- description
        {                               -- target
            FlashVisible = true,
            NumRequired = 1,
            Units = {ScenarioInfo.NERadar, ScenarioInfo.NWRadar, ScenarioInfo.SWRadar},
        }
   )
    ScenarioInfo.M3S1Aeon:AddResultCallback(
        function(result)
            if(result) then
                SetAlliance(SeraphimSecondary, Seraphim, 'Enemy')
                SetAlliance(Seraphim, SeraphimSecondary, 'Enemy')
                ScenarioFramework.Dialogue(OpStrings.X04_M03_200)
            end
        end
   )
    table.insert(AssignedObjectives, ScenarioInfo.M3S1Aeon)
    -- obj dialogue, start timer for reminder
    ScenarioFramework.Dialogue(OpStrings.X04_M03_175)
    ScenarioFramework.CreateTimerTrigger(M3S1AeonReminder1, 600)
end

function OutroNIS()
    if(ScenarioInfo.PlayerCDR and not ScenarioInfo.PlayerCDR:IsDead()) then
        ForkThread(
            function()
                ScenarioInfo.TimerExpired = true
                ScenarioInfo.OpComplete = true
                ScenarioInfo.PlayerCDR:SetCanTakeDamage(false)
                ScenarioInfo.PlayerCDR:SetCanBeKilled(false)

                Cinematics.EnterNISMode()

                -- commander goes to Outro_Commander_Destination
                IssueClearCommands({ ScenarioInfo.PlayerCDR })
                -- IssueMove(ScenarioInfo.PlayerCDR, ScenarioUtils.MarkerToPosition('Outro_Commander_Destination'))
                IssueMove({ ScenarioInfo.PlayerCDR }, { ScenarioInfo.PlayerCDR:GetPosition()[1], ScenarioInfo.PlayerCDR:GetPosition()[2], ScenarioInfo.PlayerCDR:GetPosition()[3] + 1.5 })

                ScenarioFramework.FlushDialogueQueue()
                ScenarioFramework.Dialogue(OpStrings.X04_M03_250, nil, true)
                ScenarioFramework.Dialogue(OpStrings.X04_M03_120, nil, true)

                -- Looks like the area that the player will be allowed in will be much larger than anticipated.
                -- Accordingly, static cameras won't work.  These "markers" will be set to be right at the player
                -- commander's position, wherever he may happen to be.
                local fakeMarker1 = {
                    ['zoom'] = FLOAT(143.553467),
                    ['canSetCamera'] = BOOLEAN(true),
                    ['canSyncCamera'] = BOOLEAN(true),
                    ['color'] = STRING('ff808000'),
                    ['editorIcon'] = STRING('/textures/editor/marker_mass.bmp'),
                    ['type'] = STRING('Camera Info'),
                    ['prop'] = STRING('/env/common/props/markers/M_Camera_prop.bp'),
                    ['orientation'] = VECTOR3(-3.14159, 1.19772, 0),
                    ['position'] = ScenarioInfo.PlayerCDR:GetPosition(),
                }

                local fakeMarker2 = {
                    ['zoom'] = FLOAT(15.621324),
                    ['canSetCamera'] = BOOLEAN(true),
                    ['canSyncCamera'] = BOOLEAN(true),
                    ['color'] = STRING('ff808000'),
                    ['editorIcon'] = STRING('/textures/editor/marker_mass.bmp'),
                    ['type'] = STRING('Camera Info'),
                    ['prop'] = STRING('/env/common/props/markers/M_Camera_prop.bp'),
                    ['orientation'] = VECTOR3(-3.05207, 0.558943, 0),
                    ['position'] = ScenarioInfo.PlayerCDR:GetPosition(),
                }

                local fakeMarker3 = {
                    ['zoom'] = FLOAT(62.485283),
                    ['canSetCamera'] = BOOLEAN(true),
                    ['canSyncCamera'] = BOOLEAN(true),
                    ['color'] = STRING('ff808000'),
                    ['editorIcon'] = STRING('/textures/editor/marker_mass.bmp'),
                    ['type'] = STRING('Camera Info'),
                    ['prop'] = STRING('/env/common/props/markers/M_Camera_prop.bp'),
                    ['orientation'] = VECTOR3(-3.08869, 0.664748, 0),
                    ['position'] = ScenarioInfo.PlayerCDR:GetPosition(),
                }


                Cinematics.CameraMoveToMarker(fakeMarker1, 0)
                WaitSeconds(1)

                -- Ensure that the nukes that are spawned in do not get spawned in out of the playable area
                local PlayableAreaMinX = 58
                local PlayableAreaMinZ = 102
                local PlayableAreaMaxX = 836
                local PlayableAreaMaxZ = 917
                local NukeX, NukeZ
                local CommanderX, CommanderY, CommanderZ = unpack(ScenarioInfo.DostyaCDR:GetPosition())

                if ((CommanderX - 80) <= PlayableAreaMinX) then
                    NukeX = 80
                else
                    NukeX = -80
                end
                if ((CommanderZ - 40) <= PlayableAreaMinZ) then
                    NukeZ = 40
                else
                    NukeZ = -40
                end

                FakeNuke(NukeX, NukeZ)

                if ((CommanderX + 5) >= PlayableAreaMaxX) then
                    NukeX = -5
                else
                    NukeX = 5
                end
                if ((CommanderZ - 140) <= PlayableAreaMinZ) then
                    NukeZ = 140
                else
                    NukeZ = -140
                end

                FakeNuke(NukeX, NukeZ)

                Cinematics.CameraMoveToMarker(fakeMarker2, 3)
                WaitSeconds(2)
                WaitSeconds(1)

                ForkThread(
                    function()
                        WaitSeconds(1.5)
                        Cinematics.CameraMoveToMarker(fakeMarker3, 3)
                    end
               )
                -- play teleport effect on the commander, then delete him
                ScenarioFramework.FakeTeleportUnit(ScenarioInfo.PlayerCDR, true)

                if ((CommanderX + 10) >= PlayableAreaMaxX) then
                    NukeX = -10
                else
                    NukeX = 10
                end
                if ((CommanderZ - 10) <= PlayableAreaMinZ) then
                    NukeZ = 10
                else
                    NukeZ = -10
                end

                FakeNuke(NukeX, NukeZ)
                WaitSeconds(4)

                -- "you made it!"
                ScenarioFramework.Dialogue(OpStrings.X04_M03_270, nil, true)
                WaitSeconds(9)

                -- ScenarioFramework.EndOperationSafety()

                KillGame()
            end
       )
    end
end

function WaitDeleteNukes(seconds)
    WaitSeconds(seconds)
    for k, nuke in NukeHandles do
        if nuke then
            nuke:Destroy()
        end
    end
end

function FakeNuke(posX, posZ)
    local tempNuke = ScenarioInfo.PlayerCDR:CreateProjectile('/effects/entities/SeraphimNukeEffectController01/SeraphimNukeEffectController01_proj.bp', posX, 0, posZ, nil, nil, nil):SetCollision(false)
    tempNuke.NukeInnerRingDamage = 1000001
    tempNuke.NukeInnerRingRadius = 45
    tempNuke.NukeInnerRingTicks = 24
    tempNuke.NukeInnerRingTotalTime = 12
    tempNuke.NukeOuterRingDamage = 7500
    tempNuke.NukeOuterRingRadius = 60
    tempNuke.NukeOuterRingTicks = 20
    tempNuke.NukeOuterRingTotalTime = 5
    tempNuke:CreateNuclearExplosion()
end

--------
-- Taunts
--------

function SetupOumEoshiM1Taunt()
    OumEoshiTM:AddUnitsKilledTaunt('TAUNT7', ArmyBrains[Seraphim], categories.FACTORY, 1)
end

function SetupOumEoshiTaunts()
    OumEoshiTM:AddEnemiesKilledTaunt('TAUNT6', ArmyBrains[Seraphim], categories.STRUCTURE * categories.TECH3, 15)       -- Seraph kills a a moderate number of structures
    OumEoshiTM:AddDamageTaunt('TAUNT4', ScenarioInfo.PlayerCDR, .75)                                                    -- Player CDR is reduced to 75% health
    OumEoshiTM:AddIntelCategoryTaunt('X04_M03_057', ArmyBrains[Player], ArmyBrains[Seraphim], categories.xsl0401, 1)    -- Player sights exp bot
    OumEoshiTM:AddUnitsKilledTaunt('TAUNT5', ArmyBrains[Seraphim], categories.xsb5202, 2)                               -- Seraph loses two air staging plats (focuses this taunt in M2)
end

function SetupHex5M3Taunts()
    Hex5TM:AddUnitsKilledTaunt('TAUNT9', ArmyBrains[Seraphim], categories.ALLUNITS, 125)        -- Seraph loses 125 units
    Hex5TM:AddUnitsKilledTaunt('TAUNT8', ArmyBrains[Seraphim], categories.xsl0401, 1)           -- Seraph loses an exp bot
    Hex5TM:AddAreaTaunt('TAUNT10', 'M1Area', categories.xsl0401, ArmyBrains[Seraphim], 1)       -- Seraph exp bot enters m1 area
end

-----------
-- Reminders
-----------

 -- M1
function M1P1Reminder1()
    if(ScenarioInfo.M1P1.Active) then
        ScenarioFramework.Dialogue(OpStrings.X04_M01_030)
        ScenarioFramework.CreateTimerTrigger(M1P1Reminder2, 900)
    end
end

function M1P1Reminder2()
    if(ScenarioInfo.M1P1.Active) then
        ScenarioFramework.Dialogue(OpStrings.X04_M01_040)
        ScenarioFramework.CreateTimerTrigger(M1P1Reminder1, 900)
    end
end

 -- M2
function M2P1Reminder1()
    if(ScenarioInfo.M2P1.Active) then
        ScenarioFramework.Dialogue(OpStrings.X04_M02_030)
        ScenarioFramework.CreateTimerTrigger(M2P1Reminder2, 900)
    end
end

function M2P1Reminder2()
    if(ScenarioInfo.M2P1.Active) then
        ScenarioFramework.Dialogue(OpStrings.X04_M02_040)
        ScenarioFramework.CreateTimerTrigger(M2P1Reminder1, 900)
    end
end

 -- M3
function M3S1CybranReminder1()
    if(ScenarioInfo.M3S1Cybran.Active) then
        ScenarioFramework.Dialogue(OpStrings.X04_M03_140)
        -- not much time left in this 20 minute mission, so play reminder 2 soon (as well
        -- we don't want to play anything too near the end, which could interfere with
        -- the final dialogue for the mission)
        ScenarioFramework.CreateTimerTrigger(M3S1CybranReminder2, 300)
    end
end

function M3S1CybranReminder2()
    -- dont retrigger for reminder loop: timed mission, and we don't want anything playing
    -- too close to the end.
    if(ScenarioInfo.M3S1Cybran.Active) then
        ScenarioFramework.Dialogue(OpStrings.X04_M03_150)
    end
end

function M3S1AeonReminder1()
    if(ScenarioInfo.M3S1Aeon.Active) then
        ScenarioFramework.Dialogue(OpStrings.X04_M03_180)
        ScenarioFramework.CreateTimerTrigger(M3S1AeonReminder, 300)
    end
end

function M3S1AeonReminder()
    -- dont re-trigger reminders
    if(ScenarioInfo.M3S1Aeon.Active) then
        ScenarioFramework.Dialogue(OpStrings.X04_M03_190)
    end
end
