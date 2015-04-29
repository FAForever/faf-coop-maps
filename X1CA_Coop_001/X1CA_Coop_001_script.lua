-- ****************************************************************************
-- **
-- **  File     : /maps/X1CA_Coop_001/X1CA_Coop_001_script.lua
-- **  Author(s): Jessica St. Croix
-- **
-- **  Summary  : Main mission flow script for X1CA_Coop_001
-- **
-- **  Copyright © 2007 Gas Powered Games, Inc.  All rights reserved.
-- ****************************************************************************
local BaseManager = import('/lua/ai/opai/basemanager.lua')
local Cinematics = import('/lua/cinematics.lua')
local M1OrderAI = import('/maps/X1CA_Coop_001/X1CA_Coop_001_m1orderai.lua')
local M2OrderAI = import('/maps/X1CA_Coop_001/X1CA_Coop_001_m2orderai.lua')
local M2UEFAI = import('/maps/X1CA_Coop_001/X1CA_Coop_001_m2uefai.lua')
local M3OrderAI = import('/maps/X1CA_Coop_001/X1CA_Coop_001_m3orderai.lua')
local M4UEFAI = import('/maps/X1CA_Coop_001/X1CA_Coop_001_m4uefai.lua')
local M4SeraphimAI = import('/maps/X1CA_Coop_001/X1CA_Coop_001_m4seraphimai.lua')
local Objectives = import('/lua/ScenarioFramework.lua').Objectives
local OpStrings = import('/maps/X1CA_Coop_001/X1CA_Coop_001_strings.lua')
local PingGroups = import('/lua/ScenarioFramework.lua').PingGroups
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local TauntManager = import('/lua/TauntManager.lua')
local Utilities = import('/lua/utilities.lua')
local FactionData = import('/lua/factions.lua')

local SPAIFileName = '/lua/scenarioplatoonai.lua'

---------
-- Globals
---------
ScenarioInfo.Player = 1
ScenarioInfo.Seraphim = 2
ScenarioInfo.Order = 3
ScenarioInfo.UEF = 4
ScenarioInfo.Civilians = 5
ScenarioInfo.Coop1 = 6
ScenarioInfo.Coop2 = 7
ScenarioInfo.Coop3 = 8
ScenarioInfo.HumanPlayers = {ScenarioInfo.Player}
--------
-- Locals
--------
local Player = ScenarioInfo.Player
local Coop1 = ScenarioInfo.Coop1
local Coop2 = ScenarioInfo.Coop2
local Coop3 = ScenarioInfo.Coop3
local Seraphim = ScenarioInfo.Seraphim
local Order = ScenarioInfo.Order
local UEF = ScenarioInfo.UEF
local Civilians = ScenarioInfo.Civilians

-- Maps readable IDs to faction-specific voice-overs. The "common" object holds voiceovers that lack
-- a specific faction.
local VoiceOvers = {
    common = {
        ColossusWarning = OpStrings.X01_M02_281,
        SniperBotWarning = OpStrings.X01_M02_245,
        NukeWarning = OpStrings.X01_M02_410,
        EmotionalNukeWarning = OpStrings.X01_M02_420,
        CollossusDestroyed = OpStrings.X01_M03_292,

        -- If you're slow killing the artillery...
        ArtilleryReminder1 = OpStrings.X01_M01_210,
        ArtilleryReminder2 = OpStrings.X01_M01_220,

        Victory = OpStrings.X01_M03_297,

        -- The initial cutscene.
        Introduction = OpStrings.X01_M01_010,
        IntroductionArtillery = OpStrings.X01_M01_011,
        IntroductionGunshipPanic = OpStrings.X01_M01_012,
        IntroductionGatePanic = OpStrings.X01_M01_013,

        -- Played immediately after you successfully gate in.
        IntroductionLanded = OpStrings.X01_M01_014,

        -- Suggestion to repair the shield.
        RepairShield = OpStrings.X01_M01_260,
        ShieldRepaired = OpStrings.X01_M01_270,

        -- Suggestion to kill the submarines
        KillSubmarines = OpStrings.X01_M01_240,
        SubmarinesKilled = OpStrings.X01_M01_250,

        -- The civilians want to talk...
        CivvyTalk = OpStrings.X01_M02_010,
        CivvyMessage = OpStrings.X01_M02_011,
        CivvyDefense = OpStrings.X01_M02_012,
        CivvyDefenseFailed = OpStrings.X01_M02_040,
        CivvyDefenseSucceeded = OpStrings.X01_M02_039,

        -- Defend the western town (the one that gets nuked)
        OtherCivvyDefenseRequest = OpStrings.X01_M02_041,

        -- "I'll kill everyone"
        AeonThreats = OpStrings.X01_M02_013,

        -- Played when the Aeon counterattack.
        AeonRevenge1 = OpStrings.X01_M02_340,
        AeonRevenge2 = OpStrings.X01_M02_350,

        -- After you destroy the factories in the first base.
        FactoriesDestroyed = OpStrings.X01_M01_140,

        -- When you destroy the first base.
        FirstBaseDestroyed = OpStrings.X01_M01_130,

        -- As you destroy each artilley installation.
        ArtyDestroyed1 = OpStrings.X01_M01_160,
        ArtyDestroyed2 = OpStrings.X01_M01_170,
        ArtyDestroyed3 = OpStrings.X01_M01_180,
        ArtyDestroyed4 = OpStrings.X01_M01_190, -- Unused.

        AllArtyDestroyed = OpStrings.X01_M01_200,

        -- When you fail to defend the town.
        SadCivvies = OpStrings.X01_M02_160,
        ManiacialAeonCackling = OpStrings.X01_M02_161,

        TownDefenseSuccess = OpStrings.X01_M02_043,
        NavalAttackWarning = OpStrings.X01_M02_045,

        -- When the truck-defense starts.
        TruckNotification = OpStrings.X01_M02_042,
        AeonTruckThreat = OpStrings.X01_M02_044,
        TruckDamage1 = OpStrings.X01_M02_075,
        TruckDamage2 = OpStrings.X01_M02_077,

        TruckDefenseFailed = OpStrings.X01_M02_200,

        -- Played when the corresponding number of trucks is lost. You lose if four die.
        TruckLost1 = OpStrings.X01_M02_080,
        TruckLost2 = OpStrings.X01_M02_090,
        TruckLost3 = OpStrings.X01_M02_100,

        TruckDefenseComplete1 = OpStrings.X01_M02_190,
        TruckDefenseComplete2 = OpStrings.X01_M02_210,

        -- Played when the corresponding number of trucks are rescued.
        TrucksRescued1 = OpStrings.X01_M02_170,
        TrucksRescued2 = OpStrings.X01_M02_180,

        KillSeraphimIntroduction = OpStrings.X01_M03_010,
        DyingSeraphim = OpStrings.X01_M03_295
    },
    uef = {
        BeamIn = OpStrings.X01_M01_030,
        SiegeBotReveal = OpStrings.X01_M01_070,
        MoveInland = OpStrings.X01_M01_117,
        LosingBuildingsWarning1 = OpStrings.X01_M02_030,
        LosingBuildingsWarning2 = OpStrings.X01_M02_020,
        AeonDefeated = OpStrings.X01_M02_320,
        CounterattackWarning = OpStrings.X01_M02_250,
        AttackSeraphimInstruction = OpStrings.X01_M03_122,
        M4Subplot = OpStrings.X01_M03_300,

        -- If you're slow about destroying the first base...
        FirstBaseReminder1 = OpStrings.X01_M01_090,
        FirstBaseReminder2 = OpStrings.X01_M01_100,

        -- The UEF-specific secondary mission.
        ProtectTownReminder1 = OpStrings.X01_M02_360,
        ProtectTrucksReminder1 = OpStrings.X01_M02_050,
        ProtectTrucksReminder2 = OpStrings.X01_M02_060,
        ProtectTrucksReminder3 = OpStrings.X01_M02_070,

        -- ... Or the Aeon
        KillOrderReminder1 = OpStrings.X01_M02_380,

        -- ... Or the Seraphim,
        KillSeraphimReminder1 = OpStrings.X01_M03_200,
        KillSeraphimReminder2 = OpStrings.X01_M03_210,

        -- Customised rude things for Gari to say to you before you kill her.
        AeonTaunt1 = OpStrings.TAUNT15,
        AeonTaunt2 = OpStrings.TAUNT16,
    },
    cybran = {
        BeamIn = OpStrings.X01_M01_040,
        SiegeBotReveal = OpStrings.X01_M01_080,
        LosingBuildingsWarning1 = OpStrings.X01_M02_035,
        LosingBuildingsWarning2 = OpStrings.X01_M02_036,
        AeonDefeated = OpStrings.X01_M02_320,
        CounterattackWarning = OpStrings.X01_M02_260,
        AttackSeraphimInstruction = OpStrings.X01_M03_133,
        FirstBaseReminder1 = OpStrings.X01_M01_105,
        FirstBaseReminder2 = OpStrings.X01_M01_106,
        KillOrderReminder1 = OpStrings.X01_M02_390,
        KillSeraphimReminder1 = OpStrings.X01_M03_220,
        KillSeraphimReminder2 = OpStrings.X01_M03_230,
        AeonTaunt1 = OpStrings.TAUNT17,
        AeonTaunt2 = OpStrings.TAUNT18,
    },
    aeon = {
        BeamIn = OpStrings.X01_M01_050,
        SiegeBotReveal = OpStrings.X01_M01_032,
        MoveInland = OpStrings.X01_M01_118,
        LosingBuildingsWarning1 = OpStrings.X01_M02_037,
        LosingBuildingsWarning2 = OpStrings.X01_M02_038,
        T2FighterUnlocked = OpStrings.X01_M01_031,
        AeonDefeated = OpStrings.X01_M02_330,
        CounterattackWarning = OpStrings.X01_M02_270,
        AttackSeraphimInstruction = OpStrings.X01_M03_142,
        M4Subplot = OpStrings.X01_M03_300,
        FirstBaseReminder1 = OpStrings.X01_M01_110,
        FirstBaseReminder2 = OpStrings.X01_M01_116,
        KillOrderReminder1 = OpStrings.X01_M02_400,
        KillSeraphimReminder1 = OpStrings.X01_M03_240,
        KillSeraphimReminder2 = OpStrings.X01_M03_250,
        AeonTaunt1 = OpStrings.TAUNT19,
        AeonTaunt2 = OpStrings.TAUNT20,
    }
}

local AssignedObjectives = {}
local Difficulty = ScenarioInfo.Options.Difficulty

-- The faction of player 1: determines the dialog and suchlike you get.
local LeaderFaction

-- The faction of the local player. Determines a few other bits and bobs.
local LocalFaction

-- How long should we wait at the beginning of the NIS to allow slower machines to catch up?
local NIS1InitialDelay = 3

-------------------
-- UEF Base Managers
-------------------
local UEFM3EasternTown = BaseManager.CreateBaseManager()

----------------
-- Taunt Managers
----------------
local GariM1M2TM = TauntManager.CreateTauntManager('GariM1M2TM', '/maps/X1CA_Coop_001/X1CA_Coop_001_Strings.lua') -- M1 / M2 Gari related taunts (ie, when she is not onmap)
local GariTM = TauntManager.CreateTauntManager('GariTM', '/maps/X1CA_Coop_001/X1CA_Coop_001_Strings.lua')
local FletcherTM = TauntManager.CreateTauntManager('FletcherTM', '/maps/X1CA_Coop_001/X1CA_Coop_001_Strings.lua')
local SeraphTM = TauntManager.CreateTauntManager('SeraphTM', '/maps/X1CA_Coop_001/X1CA_Coop_001_Strings.lua')

-------------------------
-- UEF Secondary variables
-------------------------
local MaxTrucks = 10
local RequiredTrucks = {6, 6, 6}

---------
-- Startup
---------
function OnPopulate(scenario)
    ScenarioUtils.InitializeScenarioArmies()
    LeaderFaction, LocalFaction = ScenarioFramework.GetLeaderAndLocalFactions()

    -- Build the faction-specific voiceover table.
    VoiceOvers = table.assimilate(VoiceOvers[LeaderFaction], VoiceOvers.common)

    -- Army Colors
    ScenarioFramework.SetUEFAlly1Color(Player)      -- starting base units are "originally" from the UEF, before being given to player
    ScenarioFramework.SetSeraphimColor(Seraphim)
    ScenarioFramework.SetAeonEvilColor(Order)
    ScenarioFramework.SetUEFAlly1Color(UEF)
    ScenarioFramework.SetUEFAlly2Color(Civilians)

    -- Unit Cap
    SetArmyUnitCap(Seraphim, 800)
    SetArmyUnitCap(Order, 550)
    SetArmyUnitCap(UEF, 800)
    SetArmyUnitCap(Civilians, 250)

    -- Walls
    ScenarioUtils.CreateArmyGroup('Civilians', 'Walls')

    -------------
    -- Player Base
    -------------
    local units = ScenarioUtils.CreateArmyGroup('UEF', 'Starting_Base')
    for k, v in units do
        v:AdjustHealth(v, Random(0, v:GetHealth()/3) * -Difficulty)
    end
    units = ScenarioUtils.CreateArmyGroup('UEF', 'Player_Starting_Defenses_D' .. Difficulty)
    for k, v in units do
        v:AdjustHealth(v, Random(0, v:GetHealth()/3) * -Difficulty)
    end
    ScenarioInfo.M1ObjectiveShield = ScenarioUtils.CreateArmyUnit('UEF', 'M1_UEF_StartShield')
    ScenarioInfo.M1ObjectiveShield:AdjustHealth(ScenarioInfo.M1ObjectiveShield, ScenarioInfo.M1ObjectiveShield:GetHealth()/-4)

    ------------------------
    -- Player Initial Patrols
    ------------------------
    units = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M1_Start_Patrol', 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(units, 'Player_PercivalPatrol_Chain')
    units = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M1_Start_Naval_Patrol', 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(units, 'Player_Start_NavalPatrol_Chain')

    -------------
    -- Order M1 AI
    -------------
    M1OrderAI.OrderM1WestBaseAI()
    M1OrderAI.OrderM1EastBaseAI()

    ScenarioInfo.UnitNames[Order]['East_Base_sACU']:CreateEnhancement('EngineeringFocusingModule')
    ScenarioInfo.UnitNames[Order]['East_Base_sACU']:CreateEnhancement('ResourceAllocation')
    ScenarioInfo.UnitNames[Order]['East_Base_sACU']:SetCustomName(LOC '{i sCDR_Victoria}')

    -----------------------
    -- Order Initial Patrols
    -----------------------

    -- Order Sub Patrols
    ScenarioInfo.M1Subs = {}
    for i = 1, 2 do
        local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'M1_Subs_' .. i .. '_D' .. Difficulty, 'AttackFormation')
        ScenarioFramework.PlatoonPatrolChain(platoon, 'Order_M1_Sub_Patrol_Chain')
        for k, v in platoon:GetPlatoonUnits() do
            table.insert(ScenarioInfo.M1Subs, v)
        end
    end

    -- Order Beach Patrols
    for i = 1, 3 do
        local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'M1_Init_Beach_' .. i .. '_D' .. Difficulty, 'AttackFormation')
        ScenarioFramework.PlatoonPatrolChain(platoon, 'Order_M1_Beach' .. i .. '_Chain')
    end

    -----------------------------
    -- Beach Defense and Artillery
    -----------------------------
    ScenarioUtils.CreateArmyGroup('Order', 'M1_West_Bluffs_D' .. Difficulty)
    ScenarioUtils.CreateArmyGroup('Order', 'M1_East_Bluffs_D' .. Difficulty)
    ScenarioUtils.CreateArmyGroup('Order', 'Shoreline_Ground_D' .. Difficulty)
    ScenarioUtils.CreateArmyGroup('Order', 'M1_Order_Bridge_Defense')

    ScenarioFramework.SetPlayableArea('M1_Playable_Area', false)
end

function OnStart(self)
    --------------------
    -- Build Restrictions
    --------------------
    for _, player in ScenarioInfo.HumanPlayers do
        ScenarioFramework.AddRestriction(player,
            categories.xal0305 + -- Aeon Sniper Bot
            categories.xaa0202 + -- Aeon Mid Range fighter (Swift Wind)
            categories.xal0203 + -- Aeon Assault Tank (Blaze)
            categories.xab1401 + -- Aeon Quantum Resource Generator
            categories.xas0204 + -- Aeon Submarine Hunter
            categories.xaa0306 + -- Aeon Torpedo Bomber
            categories.xas0306 + -- Aeon Missile Ship
            categories.xab3301 + -- Aeon Quantum Optics Device
            categories.xab2307 + -- Aeon Rapid Fire Artillery
            categories.xaa0305 + -- Aeon AA Gunship
            categories.xrl0302 + -- Cybran Mobile Bomb
            categories.xra0105 + -- Cybran Light Gunship
            categories.xrs0204 + -- Cybran Sub Killer
            categories.xrs0205 + -- Cybran Counter-Intelligence Boat
            categories.xrb2308 + -- Cybran Torpedo Ambushing System
            categories.xrb0104 + -- Cybran Engineering Station 1
            categories.xrb0204 + -- Cybran Engineering Station 2
            categories.xrb0304 + -- Cybran Engineering Station 3
            categories.xrb3301 + -- Cybran Perimeter Monitoring System
            categories.xra0305 + -- Cybran Heavy Gunship
            categories.xrl0305 + -- Cybran Brick
            categories.xrl0403 + -- Cybran Amphibious Mega Bot
            categories.xeb2306 + -- UEF Heavy Point Defense
            categories.xel0305 + -- UEF Percival
            categories.xel0306 + -- UEF Mobile Missile Platform
            categories.xes0102 + -- UEF Torpedo Boat
            categories.xes0205 + -- UEF Shield Boat
            categories.xes0307 + -- UEF Battlecruiser
            categories.xeb0104 + -- UEF Engineering Station 1
            categories.xeb0204 + -- UEF Engineering Station 2
            categories.xea0306 + -- UEF Heavy Air Transport
            categories.xeb2402 + -- UEF Sub-Orbital Defense System
            categories.xsl0305 + -- Seraph Sniper Bot
            categories.xsa0402 + -- Seraph Exp Bomb
            categories.xss0304 + -- Seraph Sub Hunter
            categories.xsb0304 + -- Seraph Gate
            categories.xsl0301 + -- Seraph sACU
            categories.xsb2401   -- Seraph exp Nuke
        )
    end

    -- Initialize camera
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_1_1'))
    ForkThread(IntroNISPart1)
end

----------
-- End Game
----------
function PlayerWin()
    ForkThread(
        function()
            if(not ScenarioInfo.OpEnded) then
                ScenarioFramework.EndOperationSafety()
                ScenarioFramework.FlushDialogueQueue()
                ScenarioFramework.Dialogue(VoiceOvers.Victory, KillGame, true)
                ScenarioInfo.OpComplete = true
            end
        end
    )
end

function PlayerDeath()
    -- TODO: need death VO
    if(not ScenarioInfo.OpEnded) then
        ScenarioFramework.CDRDeathNISCamera(ScenarioInfo.PlayerCDR)
        ScenarioFramework.EndOperationSafety()
        ScenarioInfo.OpComplete = false
        for k, v in AssignedObjectives do
            if(v and v.Active) then
                v:ManualResult(false)
            end
        end
        ForkThread(
            function()
                WaitSeconds(3)
                UnlockInput()
                KillGame()
            end
        )
    end
end

function PlayerLose()
    if(not ScenarioInfo.OpEnded) then
        ScenarioFramework.EndOperationSafety()
        ScenarioInfo.OpComplete = false
        for k, v in AssignedObjectives do
            if(v and v.Active) then
                v:ManualResult(false)
            end
        end
        KillGame()
    end
end

function KillGame()
    ForkThread(
        function()
            local secondaries = Objectives.IsComplete(ScenarioInfo.M1S1)
            ScenarioFramework.EndOperation(ScenarioInfo.OpComplete, ScenarioInfo.OpComplete, secondaries)
        end
    )
end

-----------
-- Intro NIS
-----------
function IntroNISPart1()
    ScenarioInfo.NISShield = ScenarioInfo.UnitNames[UEF]['Player_NIS_Shield']
    ScenarioInfo.NISGate = ScenarioInfo.UnitNames[UEF]['Player_Quantum_Gate']

    -- These groups of units will be guaranteed to have over 90% and 80% health left after the NIS is over
    ScenarioInfo.NIS1Over90 = { ScenarioInfo.UnitNames[UEF]['M1Start_4'] }
    ScenarioInfo.NIS1Over80 = {
        ScenarioInfo.UnitNames[UEF]['M1Start_1'],
        ScenarioInfo.UnitNames[UEF]['M1Start_2'],
        ScenarioInfo.UnitNames[UEF]['M1Start_3']
    }
    if (Difficulty == 1) then
        table.insert( ScenarioInfo.NIS1Over80, ScenarioInfo.UnitNames[UEF]['M1Start_D1_1'] )
    end
    if (Difficulty <= 2) then
        table.insert( ScenarioInfo.NIS1Over80, ScenarioInfo.UnitNames[UEF]['M1Start_D2_1'] )
        table.insert( ScenarioInfo.NIS1Over80, ScenarioInfo.UnitNames[UEF]['M1Start_D2_2'] )
    end
    if (Difficulty <= 3) then
        table.insert( ScenarioInfo.NIS1Over80, ScenarioInfo.UnitNames[UEF]['M1Start_D3_1'] )
    end

    for k, unit in ScenarioInfo.NIS1Over90 do
        if (unit and not unit:IsDead()) then
            unit:SetCanBeKilled( false )
        end
    end
    for k, unit in ScenarioInfo.NIS1Over80 do
        if (unit and not unit:IsDead()) then
            unit:SetCanBeKilled( false )
        end
    end

    Cinematics.EnterNISMode()

    ScenarioInfo.NISAntiAir = ScenarioUtils.CreateArmyUnit('UEF', 'NIS_AA')
    ScenarioInfo.NISAntiAir:SetCanBeKilled( false )
    ScenarioInfo.NISGate:SetCanBeKilled( false )

    -- Vis markers near base, artillery, etc.
    -- ScenarioFramework.CreateVisibleAreaLocation( 30, ScenarioUtils.MarkerToPosition( 'M1_NIS_Vis_1' ), 25, ArmyBrains[Player] )
    ScenarioFramework.CreateVisibleAreaLocation( 30, ScenarioUtils.MarkerToPosition( 'M1_NIS_Vis_2' ), 25 + NIS1InitialDelay, ArmyBrains[Player] )
    ScenarioFramework.CreateVisibleAreaLocation( 200, ScenarioUtils.MarkerToPosition( 'M1_NIS_Vis_3' ), 35 + NIS1InitialDelay, ArmyBrains[Player] )
    ScenarioFramework.CreateVisibleAreaLocation( 30, ScenarioUtils.MarkerToPosition( 'M1_NIS_Vis_4' ), 25 + NIS1InitialDelay, ArmyBrains[Player] )
    ScenarioFramework.CreateVisibleAreaLocation( 30, ScenarioUtils.MarkerToPosition( 'M1_NIS_Vis_5' ), 25 + NIS1InitialDelay, ArmyBrains[Player] )

    -- Grant intel on the enemy base locations
    ScenarioFramework.CreateVisibleAreaLocation( 50, ScenarioUtils.MarkerToPosition( 'Order_M1_West_Base_Marker' ), 1, ArmyBrains[Player] )
    ScenarioFramework.CreateVisibleAreaLocation( 50, ScenarioUtils.MarkerToPosition( 'Order_M1_East_Base_Marker' ), 25 + NIS1InitialDelay, ArmyBrains[Player] )
    ScenarioFramework.CreateVisibleAreaLocation( 30, ScenarioUtils.MarkerToPosition( 'Order_M1_East_Bluffs_Patrol_3' ), 1, ArmyBrains[Player] )
    ScenarioFramework.CreateVisibleAreaLocation( 30, ScenarioUtils.MarkerToPosition( 'Order_M1_West_Bluffs_Patrol_1' ), 1, ArmyBrains[Player] )

    -- Let slower machines catch up before we get going
    WaitSeconds(NIS1InitialDelay)

    -- Start talking
    ScenarioFramework.Dialogue(VoiceOvers.Introduction, nil, true)

    -- Look at the enemy base
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_1_1'), 0)
    WaitSeconds(1)
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_1_2'), 5)
    WaitSeconds(1)

    -- Look at the artillery
    ScenarioFramework.Dialogue(VoiceOvers.IntroductionArtillery, nil, true)
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_1_3'), 4)

    WaitSeconds(2)

    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_1_4'), 4)
    ScenarioFramework.Dialogue(VoiceOvers.IntroductionGunshipPanic, nil, true)
    WaitSeconds(2)

    ScenarioInfo.NISGunships = {}
    ScenarioInfo.NISGunshipPlatoons = {}
    for i = 1, 6 do
        local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'M1_NIS_Gunships' .. i, 'StaggeredChevronFormation')
        table.insert(ScenarioInfo.NISGunshipPlatoons, platoon)
        for k, v in platoon:GetPlatoonUnits() do
            table.insert(ScenarioInfo.NISGunships, v)
        end
    end
    for i = 1, 2 do
        ScenarioInfo.UnitNames[Order]['Gunship_Tracker' .. i]:SetDoNotTarget(true)
        ScenarioInfo.UnitNames[Order]['Gunship_Tracker' .. i]:SetCanTakeDamage(false)
    end

    -- Make one in ten guys attack the anti-air gun to give some plausibility to its death
    -- And another one in ten attack the shield for the same reason
    local i = 0
    for k, v in ScenarioInfo.NISGunshipPlatoons do
        i = math.mod( (i + 1), 10 )
        if ( i == 5 ) then
            v:AttackTarget( ScenarioInfo.NISAntiAir )
        elseif ( i == 6 ) then
            v:AttackTarget( ScenarioInfo.NISShield )
        else
            v:AttackTarget( ScenarioInfo.UnitNames[UEF]['Player_Quantum_Gate'] )
        end
    end

    WaitSeconds(0.5)
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_1_5'), 0)
    WaitSeconds(1)

    local NISTrackTarget = ScenarioInfo.UnitNames[Order]['M1_Gunship_NIS_Track']
    Cinematics.CameraTrackEntity( NISTrackTarget, 60, 1 )

    WaitSeconds(3)
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_1_6'), 2)
    WaitSeconds(1)

    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_1_7'), 0)
    WaitSeconds(1)
    ScenarioFramework.Dialogue(VoiceOvers.IntroductionGatePanic, nil, true)
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_Warp1'), 4)

	SetAreaKillable('M1_Playable_Area', true)
    ForkThread(IntroNISPart2)
end

function SetAreaKillable(area, val)
    for k,v in GetUnitsInRect( ScenarioUtils.AreaToRect(area) ) do
        v:SetCanTakeDamage(val)
        v:SetCanBeKilled(val)
    end
end

function IntroNISPart2()
    -- set faction color before spawning in player CDR
    if(LeaderFaction == 'cybran') then
        ScenarioFramework.SetCybranPlayerColor(Player)
    elseif(LeaderFaction == 'uef') then
        ScenarioFramework.SetUEFPlayerColor(Player)
    elseif(LeaderFaction == 'aeon') then
        ScenarioFramework.SetAeonAllyColor(Player)
    end

    if(LeaderFaction == 'cybran') then
        ScenarioInfo.PlayerCDR = ScenarioUtils.CreateArmyUnit('Player', 'CybranPlayer')
    elseif(LeaderFaction == 'uef') then
        ScenarioInfo.PlayerCDR = ScenarioUtils.CreateArmyUnit('Player', 'UEFPlayer')
    elseif(LeaderFaction == 'aeon') then
        ScenarioInfo.PlayerCDR = ScenarioUtils.CreateArmyUnit('Player', 'AeonPlayer')
    end

    -- Give the special NIS units to the player
    if ScenarioInfo.NISAntiAir and not ScenarioInfo.NISAntiAir:IsDead() then
        ScenarioInfo.NISAntiAir = ScenarioFramework.GiveUnitToArmy( ScenarioInfo.NISAntiAir, Player )
    end
    if ScenarioInfo.NISShield and not ScenarioInfo.NISShield:IsDead() then
        ScenarioInfo.NISShield = ScenarioFramework.GiveUnitToArmy( ScenarioInfo.NISShield, Player )
    end
    if ScenarioInfo.NISGate and not ScenarioInfo.NISGate:IsDead() then
        ScenarioInfo.NISGate = ScenarioFramework.GiveUnitToArmy( ScenarioInfo.NISGate, Player )
    end

    local NIS1Over90PostConversion = {}
    local NIS1Over80PostConversion = {}

    for k, unit in ScenarioInfo.NIS1Over90 do
        if (unit and not unit:IsDead()) then
            local tempUnit = ScenarioFramework.GiveUnitToArmy( unit, Player )
            table.insert( NIS1Over90PostConversion, tempUnit )
            tempUnit:SetCanBeKilled( false )
        end
    end
    for k, unit in ScenarioInfo.NIS1Over80 do
        if (unit and not unit:IsDead()) then
            local tempUnit = ScenarioFramework.GiveUnitToArmy( unit, Player )
            table.insert( NIS1Over80PostConversion, tempUnit )
            tempUnit:SetCanBeKilled( false )
        end
    end

    -- These are filled with invalid unit handles now, so might as well clear them out
    ScenarioInfo.NIS1Over80 = nil
    ScenarioInfo.NIS1Over90 = nil

    -- Give objective shield to player
    if(ScenarioInfo.M1ObjectiveShield and not ScenarioInfo.M1ObjectiveShield:IsDead()) then
        local unit = ScenarioFramework.GiveUnitToArmy(ScenarioInfo.M1ObjectiveShield, Player)
        ScenarioInfo.M1ObjectiveShield = unit
        ScenarioFramework.CreateUnitDestroyedTrigger(M1ShieldDestroyed, ScenarioInfo.M1ObjectiveShield)
    end

    -- Swap beach units to player
    local units = GetUnitsInRect(ScenarioUtils.AreaToRect('M1_Player_Base_Area'))
    for k, v in units do
        if v and not v:IsDead() and (v:GetAIBrain() == ArmyBrains[UEF]) then
            ScenarioFramework.GiveUnitToArmy( v, Player )
        end
    end

    -- Set the gate back to being unkillable
    if ScenarioInfo.NISGate and not ScenarioInfo.NISGate:IsDead() then
        ScenarioInfo.NISGate:SetCanBeKilled( false )
    end

    -- Percivals back on patrol
    local percivals = ArmyBrains[Player]:GetListOfUnits(categories.xel0305, false)
    local percivalPlatoon = ArmyBrains[Player]:MakePlatoon(' ', ' ')
    ArmyBrains[Player]:AssignUnitsToPlatoon( percivalPlatoon, percivals, 'Attack', 'AttackFormation' )
    ScenarioFramework.PlatoonPatrolChain(percivalPlatoon, 'Player_PercivalPatrol_Chain')

    -- Subs back on patrol
    local subs = ArmyBrains[Player]:GetListOfUnits(categories.ues0203, false)
    local platoon = ArmyBrains[Player]:MakePlatoon('', '')
    ArmyBrains[Player]:AssignUnitsToPlatoon(platoon, subs, 'Attack', 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'Player_Start_NavalPatrol_Chain')

    local cmd = IssueMove({ScenarioInfo.PlayerCDR}, ScenarioUtils.MarkerToPosition('CDRWarp'))
    ScenarioFramework.FakeGateInUnit(ScenarioInfo.PlayerCDR)
    --ScenarioInfo.PlayerCDR:SetCustomName(LOC '{i CDR_Player}')

	ScenarioInfo.CoopCDR = {}
	local tblArmy = ListArmies()
	coop = 1
	for iArmy, strArmy in pairs(tblArmy) do
		if iArmy >= ScenarioInfo.Coop1 then
			factionIdx = GetArmyBrain(strArmy):GetFactionIndex()
			if(factionIdx == 1) then
				ScenarioInfo.CoopCDR[coop] = ScenarioUtils.CreateArmyUnit(strArmy, 'UEFPlayer')
			elseif(factionIdx == 2) then
				ScenarioInfo.CoopCDR[coop] = ScenarioUtils.CreateArmyUnit(strArmy, 'AeonPlayer')
			else
				ScenarioInfo.CoopCDR[coop] = ScenarioUtils.CreateArmyUnit(strArmy, 'CybranPlayer')
			end
			IssueMove({ScenarioInfo.CoopCDR[coop]}, ScenarioUtils.MarkerToPosition('CDRWarp'))
			ScenarioFramework.FakeGateInUnit(ScenarioInfo.CoopCDR[coop])
			coop = coop + 1
			WaitSeconds(2)
		end
	end

    ForkThread( NIS1KillUnits )

    ScenarioInfo.PlayerCDR:SetDoNotTarget(true)
    ScenarioInfo.PlayerCDR:SetCanTakeDamage(false)

    ForkThread( NISKillGunshipsSlowly )
    ScenarioInfo.NISAntiAir:SetCanBeKilled( true )
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_Warp2'), 2)

    WaitSeconds(1)

    ForkThread( NIS1KillUnits2 )

    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_Warp3'), 3)
    ScenarioFramework.Dialogue(VoiceOvers.IntroductionLanded, nil, true)

    ScenarioInfo.PlayerCDR:SetDoNotTarget(false)
    ScenarioInfo.PlayerCDR:SetCanTakeDamage(true)
    Cinematics.ExitNISMode()

    -- Get rid of intel on the enemy bases
    -- ...no longer!  Word has come down that the player should see the enemy base info.
    -- ScenarioFramework.ClearIntel( ScenarioUtils.MarkerToPosition( 'M1_NIS_Vis_1' ), 40 )
    -- ScenarioFramework.ClearIntel( ScenarioUtils.MarkerToPosition( 'M1_NIS_Vis_2' ), 40 )
    -- ScenarioFramework.ClearIntel( ScenarioUtils.MarkerToPosition( 'M1_NIS_Vis_4' ), 40 )
    -- ScenarioFramework.ClearIntel( ScenarioUtils.MarkerToPosition( 'M1_NIS_Vis_5' ), 40 )

    for k, unit in NIS1Over90PostConversion do
        if (unit and not unit:IsDead()) then
            unit:SetCanBeKilled( true )
            unit:SetHealth( unit, Random(( unit:GetMaxHealth() * 0.9), unit:GetMaxHealth() ))
        end
    end
    for k, unit in NIS1Over80PostConversion do
        if (unit and not unit:IsDead()) then
            unit:SetCanBeKilled( true )
            unit:SetHealth( unit, Random(( unit:GetMaxHealth() * 0.8), unit:GetMaxHealth() ))
        end
    end

    ScenarioFramework.PauseUnitDeath(ScenarioInfo.PlayerCDR)
    ScenarioFramework.CreateUnitDeathTrigger(PlayerDeath, ScenarioInfo.PlayerCDR)


    for index, coopACU in ScenarioInfo.CoopCDR do
        ScenarioFramework.PauseUnitDeath(coopACU)
        ScenarioFramework.CreateUnitDeathTrigger(PlayerDeath, coopACU)
    end
    IntroMission1()
end


function NIS1KillUnits()
    WaitSeconds(2)

    -- Kill the NIS shield if it's still there
    if ScenarioInfo.NISShield and not ScenarioInfo.NISShield:IsDead() then
        ScenarioInfo.NISShield:Kill()
    end

    -- Set gate killable so that the units firing on it in the NIS will kill it
    if ScenarioInfo.NISGate and not ScenarioInfo.NISGate:IsDead() then
        ScenarioInfo.NISGate:SetCanBeKilled(true)
    end
    WaitSeconds(1)

    -- If it's still alive a second later, kill it ourselves
    if ScenarioInfo.NISGate and not ScenarioInfo.NISGate:IsDead() then
        ScenarioInfo.NISGate:Kill()
    end
end

function NISKillGunshipsSlowly()
    local flipToggle = false
    for k, unit in ScenarioInfo.NISGunships do
        if ( unit and not unit:IsDead()) then
            unit:Kill()
            if flipToggle then
                WaitSeconds(0.3)
                flipToggle = false
            else
                WaitSeconds(0.2)
                flipToggle = true
            end
        end
    end
end

function NIS1KillUnits2()
    if (ScenarioInfo.NISAntiAir and not ScenarioInfo.NISAntiAir:IsDead()) then
        ScenarioInfo.NISAntiAir:Kill()
    end

    local iterator = 2
    for k, unit in ScenarioInfo.NISGunships do
        if ( unit and not unit:IsDead()) then
            iterator = iterator + 1
            if ( math.mod( iterator, 4 ) == 0 ) then
                WaitSeconds(0.1)
            end
            unit:Kill()
        end
    end

    for i = 1, 2 do
        WaitSeconds(0.1)
        ScenarioInfo.UnitNames[Order]['Gunship_Tracker' .. i]:SetCanTakeDamage(true)
        if ScenarioInfo.UnitNames[Order]['Gunship_Tracker' .. i] and not ScenarioInfo.UnitNames[Order]['Gunship_Tracker' .. i]:IsDead() then
            ScenarioInfo.UnitNames[Order]['Gunship_Tracker' .. i]:Kill()
        end
    end
end

-----------
-- Mission 1
-----------
function IntroMission1()
    ScenarioInfo.MissionNumber = 1
    StartMission1()
end

function StartMission1()
    -----------------------------------------
    -- Primary Objective 1 - Destroy Factories
    -----------------------------------------
    ScenarioInfo.M1P1 = Objectives.CategoriesInArea(
        'primary',                      -- type
        'incomplete',                   -- status
        OpStrings.X01_M01_OBJ_010_010,  -- title
        OpStrings.X01_M01_OBJ_010_020,  -- description
        'kill',
        {                               -- target
            MarkUnits = true,
            Requirements = {
                {Area = 'M1_North_Base_Area', Category = categories.FACTORY, CompareOp = '<=', Value = 0, ArmyIndex = Order},
                {Area = 'M1_South_Base_Area', Category = categories.FACTORY, CompareOp = '<=', Value = 0, ArmyIndex = Order},
            },
        }
    )
    ScenarioInfo.M1P1:AddResultCallback(
        function(result)
            if(result) then
                ScenarioFramework.Dialogue(VoiceOvers.FactoriesDestroyed, IntroMission2)
            end
        end
    )
    table.insert(AssignedObjectives, ScenarioInfo.M1P1)
    ScenarioFramework.CreateTimerTrigger(M1P1Reminder1, 900)

    -- Feedback dialogue when the first base is destroyed
    ScenarioInfo.M1BaseDialoguePlayer = false
    ScenarioFramework.CreateAreaTrigger(M1FirstBaseDestroyed, ScenarioUtils.AreaToRect('M1_North_Base_Area'),
        categories.AEON * categories.CONSTRUCTION, true, true, ArmyBrains[Order])
    ScenarioFramework.CreateAreaTrigger(M1FirstBaseDestroyed, ScenarioUtils.AreaToRect('M1_South_Base_Area'),
        categories.AEON * categories.CONSTRUCTION, true, true, ArmyBrains[Order])

    if(Difficulty == 3) then
        -------------------------------------------
        -- Secondary Objective 1 - Destroy Artillery
        -------------------------------------------
        ScenarioInfo.M1S1 = Objectives.CategoriesInArea(
            'secondary',                    -- type
            'incomplete',                   -- status
            OpStrings.X01_M01_OBJ_020_010,  -- title
            OpStrings.X01_M01_OBJ_020_020,  -- description
            'kill',
            {                               -- target
                MarkUnits = true,
                Requirements = {
                    {Area = 'M1_Artillery_Area_1', Category = categories.uab2303, CompareOp = '<=', Value = 0, ArmyIndex = Order},
                    {Area = 'M1_Artillery_Area_2', Category = categories.uab2303, CompareOp = '<=', Value = 0, ArmyIndex = Order},
                    {Area = 'M1_Artillery_Area_3', Category = categories.uab2303, CompareOp = '<=', Value = 0, ArmyIndex = Order},
                    {Area = 'M1_Artillery_Area_4', Category = categories.uab2303, CompareOp = '<=', Value = 0, ArmyIndex = Order},
                },
            }
        )
    else
        -------------------------------------------
        -- Secondary Objective 1 - Destroy Artillery
        -------------------------------------------
        ScenarioInfo.M1S1 = Objectives.CategoriesInArea(
            'secondary',                    -- type
            'incomplete',                   -- status
            OpStrings.X01_M01_OBJ_020_010,  -- title
            OpStrings.X01_M01_OBJ_020_020,  -- description
            'kill',
            {                               -- target
                MarkUnits = true,
                Requirements = {
                    {Area = 'M1_Artillery_Area_2', Category = categories.uab2303, CompareOp = '<=', Value = 0, ArmyIndex = Order},
                    {Area = 'M1_Artillery_Area_3', Category = categories.uab2303, CompareOp = '<=', Value = 0, ArmyIndex = Order},
                },
            }
        )
    end
    local m1ArtilleryDestroyed = 0
    ScenarioInfo.M1S1:AddProgressCallback(
        function()
            if ScenarioInfo.MissionNumber == 1 then
                -- VO feedback confirming each artillery position as its destroyed
                m1ArtilleryDestroyed = m1ArtilleryDestroyed + 1
                if m1ArtilleryDestroyed == 1 then
                    ScenarioFramework.Dialogue(VoiceOvers.ArtyDestroyed1)
                elseif m1ArtilleryDestroyed == 2 then
                    -- Play a "second art area destroyed" only if there are going to more areas to clear (ie, diff 3 only).
                    if Difficulty == 3 then
                        ScenarioFramework.Dialogue(VoiceOvers.ArtyDestroyed2)
                    end
                elseif m1ArtilleryDestroyed == 3 then
                    ScenarioFramework.Dialogue(VoiceOvers.ArtyDestroyed3)
                end
            end
        end
    )
    ScenarioInfo.M1S1:AddResultCallback(
        function(result)
            if(result) then
                ScenarioFramework.Dialogue(VoiceOvers.AllArtyDestroyed)
            end
        end
    )
    table.insert(AssignedObjectives, ScenarioInfo.M1S1)
    ScenarioFramework.CreateTimerTrigger(M1S1Reminder1, 1000)
    ScenarioFramework.CreateTimerTrigger(M1SubPlot, 240)
    ScenarioFramework.CreateTimerTrigger(M1TechReveal, 55)
    SetupGariM1M2TauntTriggers()

    ScenarioFramework.Dialogue(VoiceOvers.BeamIn)
    ScenarioFramework.CreateTimerTrigger(M1S2Reveal, 30)

    -- turn on air scouting
    M1OrderAI.BuildAirScouts()
end

function M1SubPlot()
    if ScenarioInfo.MissionNumber == 1 then
        ScenarioFramework.Dialogue(VoiceOvers.MoveInland)
    end
end

function M1TechReveal()
    -- tech reveal dialogue, siege bots
    ScenarioFramework.Dialogue(VoiceOvers.SiegeBotReveal)

    -- Unlock Percival, Bricks, and Blaze assault tank
    ScenarioFramework.RemoveRestrictionForAllHumans(categories.xel0305)
    ScenarioFramework.RemoveRestrictionForAllHumans(categories.xrl0305)
    ScenarioFramework.RemoveRestrictionForAllHumans(categories.xal0203)
end

function M1FirstBaseDestroyed()
    if ScenarioInfo.M1BaseDialoguePlayer == false and ScenarioInfo.M1P1.Active then
        ScenarioInfo.M1BaseDialoguePlayer = true
        ScenarioFramework.Dialogue(VoiceOvers.FirstBaseDestroyed)
    end
end

function M1S2Reveal()
    if ScenarioInfo.M1ObjectiveShield and not ScenarioInfo.M1ObjectiveShield:IsDead() then
        ScenarioFramework.Dialogue(VoiceOvers.RepairShield, M1S2Assign)
    end
end

function M1S2Assign()
    ---------------------------------------
    -- Secondary Objective 2 - Repair Shield
    ---------------------------------------
    ScenarioInfo.M1S2 = Objectives.Basic(
        'secondary',                        -- type
        'incomplete',                       -- status
        OpStrings.X01_M01_OBJ_020_030,      -- title
        OpStrings.X01_M01_OBJ_020_040,      -- description
        Objectives.GetActionIcon('repair'),
        {
            Units = {ScenarioInfo.M1ObjectiveShield},
        }
    )
    ScenarioInfo.M1S2:AddResultCallback(
        function(result)
            if result then
                ScenarioFramework.Dialogue(VoiceOvers.ShieldRepaired)
            end

            -- Assign M1S3 whether or not the shield was repaired or destroyed
            ScenarioFramework.CreateTimerTrigger(M1S3Reveal, 30)
        end
    )
    table.insert(AssignedObjectives, ScenarioInfo.M1S2)

    ForkThread(CheckShieldHealth)
end

function M1ShieldDestroyed()
    if(ScenarioInfo.M1S2 and ScenarioInfo.M1S2.Active) then
        ScenarioInfo.M1S2:ManualResult(false)
    elseif(ScenarioInfo.MissionNumber == 1) then
        -- Assign M1S3 if shield is destroyed before shield objective is assigned and we're still in M1
        ScenarioFramework.CreateTimerTrigger(M1S3Reveal, 30)
    end
end

function CheckShieldHealth()
    while(ScenarioInfo.M1ObjectiveShield and not ScenarioInfo.M1ObjectiveShield:IsDead() and ScenarioInfo.M1ObjectiveShield:GetHealthPercent() ~= 1) do
        WaitSeconds(1)
    end
    if(ScenarioInfo.MissionNumber == 1 and ScenarioInfo.M1ObjectiveShield and not ScenarioInfo.M1ObjectiveShield:IsDead()) then
        ScenarioInfo.M1S2:ManualResult(true)
    end
end

function M1S3Reveal()
    if ScenarioInfo.MissionNumber == 1 then
        local subsAlive = 0
        for k, sub in ScenarioInfo.M1Subs do
            if sub and not sub:IsDead() then
                subsAlive = subsAlive + 1
            end
        end
        if ScenarioInfo.M1Subs and subsAlive > 0 and not ScenarioInfo.M1S3.Active then
            ScenarioFramework.Dialogue(VoiceOvers.KillSubmarines, M1S3Assign)
        end
    end
end

function M1S3Assign()
    --------------------------------------
    -- Secondary Objective 3 - Destroy Subs
    --------------------------------------
    ScenarioInfo.M1S3 = Objectives.KillOrCapture(
        'secondary',
        'incomplete',
        OpStrings.X01_M01_OBJ_020_050,
        OpStrings.X01_M01_OBJ_020_060,
        {
            Units = ScenarioInfo.M1Subs,
        }
    )
    ScenarioInfo.M1S3:AddResultCallback(
        function(result)
            if(result) then
                ScenarioFramework.Dialogue(VoiceOvers.SubmarinesKilled)
            end
        end
    )
    table.insert(AssignedObjectives, ScenarioInfo.M1S3)
end

-----------
-- Mission 2
-----------
function IntroMission2()
    ForkThread(
        function()
            ScenarioFramework.FlushDialogueQueue()
            -- "Grahm wants to talk to you"
            ScenarioFramework.Dialogue(VoiceOvers.CivvyTalk, nil, true) -- 3 sec
            while(ScenarioInfo.DialogueLock) do
                WaitSeconds(0.2)
            end

            ScenarioInfo.MissionNumber = 2
            local opai = nil

            -- Fail M1 secondaries, if not yet completed
            if(ScenarioInfo.M1S2 and ScenarioInfo.M1S2.Active) then
                ScenarioInfo.M1S2:ManualResult(false)
            end
            if(ScenarioInfo.M1S3 and ScenarioInfo.M1S3.Active) then
                ScenarioInfo.M1S3:ManualResult(false)
            end

            -----------------------
            -- Western Civilian Town
            -----------------------
            ScenarioInfo.M2CivilianBuildings = ScenarioUtils.CreateArmyGroup('Civilians', 'M2_Civilian_Buildings')
            ScenarioUtils.CreateArmyGroup('Civilians', 'M2_Wreckage', true)

            -----------
            -- UEF M2 AI
            -----------
            M2UEFAI.UEFM2WesternTownAI()

            --------------------
            -- UEF Initial Attack
            --------------------
            for i = 1, 2 do
                local units = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M2_Town_Init_Land' .. i .. '_D' .. Difficulty, 'AttackFormation')
                ScenarioFramework.PlatoonPatrolChain(units, 'UEF_M2_West_Town_Patrol_Chain')
            end

            -------------
            -- Order M2 AI
            -------------
            M2OrderAI.OrderM2MainBaseAI()
            M2OrderAI.OrderM2AirNorthBaseAI()
            M2OrderAI.OrderM2AirSouthBaseAI()
            M2OrderAI.OrderM2LandNorthBaseAI()
            M2OrderAI.OrderM2LandSouthBaseAI()

            -----------------------
            -- Order Initial Patrols
            -----------------------

            -- Default
            local units = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'M2_Order_InitPatrol_Air_D' .. Difficulty, 'GrowthFormation')
            for k, v in units:GetPlatoonUnits() do
                ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('Order_M2_BaseAir_Chain')))
            end

            units = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'M2_Order_InitPatrol2_Air_D' .. Difficulty, 'GrowthFormation')
            for k, v in units:GetPlatoonUnits() do
                ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('Order_M2_BaseAir2_Chain')))
            end

            for i = 1, 2 do
                units = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'M2_Order_InitPatrol' .. i .. '_Land_D' .. Difficulty, 'AttackFormation')
                for k, v in units:GetPlatoonUnits() do
                    ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('Order_M2_BaseLand' .. i .. '_Chain')))
                end
            end

            -- Player has > 65, 50, 35 T2/T3 planes, 1 group AA for every 15
            local trigger = {65, 50, 35}
            local num = 0
            for _, player in ScenarioInfo.HumanPlayers do
                num = num + table.getn(ArmyBrains[player]:GetListOfUnits((categories.MOBILE * categories.AIR) - categories.TECH1, false))
            end

            if(num > trigger[Difficulty]) then
                num = num - trigger[Difficulty]
                num = math.ceil(num/15)
                if(num > 5) then
                    num = 5
                end
                for i = 1, num do
                    units = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'M2_Order_Adapt_AntiAir', 'GrowthFormation')
                    for k, v in units:GetPlatoonUnits() do
                        local random = Random(1, 2)
                        if(random == 1) then
                            ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('Order_M2_BaseAir_Chain')))
                        else
                            ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('Order_M2_BaseAir2_Chain')))
                        end
                    end
                end
            end

            -- Player has >= 1 air experimental
            local num = 0
            for _, player in ScenarioInfo.HumanPlayers do
                num = num + table.getn(ArmyBrains[player]:GetListOfUnits(categories.AIR * categories.EXPERIMENTAL, false))
            end
            if (num >= 1) then
                local numGroups = {3, 4, 5}
                for i = 1, numGroups[Difficulty] do
                    units = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'M2_Order_Adapt_AntiAir', 'GrowthFormation')
                    for k, v in units:GetPlatoonUnits() do
                        if(Random(1, 2) == 1) then
                            ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('Order_M2_BaseAir_Chain')))
                        else
                            ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('Order_M2_BaseAir2_Chain')))
                        end
                    end
                end
            end

            -- Player has > 15, 30, 45 T2/T3 mobile land
            trigger = {45, 30, 15}
            local num = 0
            for _, player in ScenarioInfo.HumanPlayers do
                num = num + table.getn(ArmyBrains[player]:GetListOfUnits((categories.MOBILE * categories.LAND) - categories.CONSTRUCTION - categories.TECH1, false))
            end

            if(num > trigger[Difficulty]) then
                num = num - trigger[Difficulty]
                num = math.ceil(num/15)
                if(num > 5) then
                    num = 5
                end
                for i = 1, num do
                    units = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'M2_Order_Adapt_Gunship', 'GrowthFormation')
                    for k, v in units:GetPlatoonUnits() do
                        if(Random(1, 2) == 1) then
                            ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('Order_M2_BaseAir_Chain')))
                        else
                            ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('Order_M2_BaseAir2_Chain')))
                        end
                    end
                end
            end

            -- Player has >= 1 land experimental
            local num = 0
            for _, player in ScenarioInfo.HumanPlayers do
                num = num + table.getn(ArmyBrains[player]:GetListOfUnits(categories.LAND * categories.EXPERIMENTAL, false))
            end
            if (num >= 1) then
                local numGroups = {3, 4, 5}
                for i = 1, numGroups[Difficulty] do
                    units = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'M2_Order_Adapt_Gunship', 'GrowthFormation')
                    for k, v in units:GetPlatoonUnits() do
                        if(Random(1, 2) == 1) then
                            ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('Order_M2_BaseAir_Chain')))
                        else
                            ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('Order_M2_BaseAir2_Chain')))
                        end
                    end
                end
            end

            ----------------------
            -- Order Initial Attack
            ----------------------
            for i = 1, 2 do
                local units = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'M2_Init_BaseAttack_Land' .. i .. '_D' .. Difficulty, 'AttackFormation')
                for k, v in units:GetPlatoonUnits() do
                    IssueMove({v}, ScenarioUtils.MarkerToPosition('M2_Town_Order_InitialLand_' .. Random(1, 3)))
                end
            end
            units = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'M2_Init_BaseAttack_Air1_D' .. Difficulty, 'AttackFormation')
            ScenarioFramework.PlatoonPatrolChain(units, 'Order_M2_Town_AirPatrol_Chain')

            ------------------------
            -- Order Secondary Attack
            ------------------------
            ScenarioInfo.OrderSecondaryAttack1 = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'M2_Init_BaseAttack_Land3_D' .. Difficulty, 'AttackFormation')
            ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.OrderSecondaryAttack1, 'Order_M2_BaseLand1_Chain')

            ScenarioInfo.OrderSecondaryAttack2 = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'M2_Init_BaseAttack_Land4_D' .. Difficulty, 'AttackFormation')
            ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.OrderSecondaryAttack2, 'Order_M2_NorthPatrol_Land_Chain')

            ScenarioInfo.OrderSecondaryAttack3 = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'M2_Init_BaseAttack_Land5_D' .. Difficulty, 'AttackFormation')
            ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.OrderSecondaryAttack3, 'Order_M2_BaseLand1_Chain')

            ScenarioInfo.OrderSecondaryAttack4 = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'M2_Init_BaseAttack_Land6_D' .. Difficulty, 'AttackFormation')
            ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.OrderSecondaryAttack4, 'Order_M2_NorthPatrol_Land_Chain')

            -- NIS-specific attackers and defenders; these units are guaranteed to die
            ScenarioInfo.NISOrderAttackers = ScenarioUtils.CreateArmyGroup( 'Order', 'M2_NIS' )
            IssueAggressiveMove(ScenarioInfo.NISOrderAttackers, ScenarioUtils.MarkerToPosition( 'M2_Order_TownAttack_1' ))

            ScenarioInfo.NISCivilianDefenders = ScenarioUtils.CreateArmyGroup( 'Civilians', 'M2_NIS' )

            -- Adjust the NIS units to have less health
            for k, unit in ScenarioInfo.NISCivilianDefenders do
                if ( unit and not unit:IsDead() ) then
                    unit:AdjustHealth(unit, (unit:GetHealth() * 0.8) * -1)
                end
            end

            for k, unit in ScenarioInfo.NISOrderAttackers do
                if ( unit and not unit:IsDead() ) then
                    unit:AdjustHealth(unit, (unit:GetHealth() * 0.6) * -1)
                end
            end

            ForkThread(IntroMission2NIS)
        end
    )
end

function IntroMission2NIS()
    ScenarioFramework.SetPlayableArea('M2_Playable_Area', false)
    Cinematics.EnterNISMode()
    Cinematics.SetInvincible( 'M1_Playable_Area' )
    -- "Yeah, hi...we're totally getting attacked"
    ScenarioFramework.Dialogue(VoiceOvers.CivvyMessage, nil, true) -- 9 sec

    -- Give intel on the enemy bases briefly, so the buildings are visible under fog
    ScenarioFramework.CreateVisibleAreaLocation( 50, ScenarioUtils.MarkerToPosition( 'M2_NIS_Vis_1' ), 1, ArmyBrains[Player] )
    ScenarioFramework.CreateVisibleAreaLocation( 50, ScenarioUtils.MarkerToPosition( 'M2_NIS_Vis_2' ), 1, ArmyBrains[Player] )
    ScenarioFramework.CreateVisibleAreaLocation( 50, ScenarioUtils.MarkerToPosition( 'M2_NIS_Vis_3' ), 1, ArmyBrains[Player] )
    ScenarioFramework.CreateVisibleAreaLocation( 50, ScenarioUtils.MarkerToPosition( 'M2_NIS_Vis_4' ), 1, ArmyBrains[Player] )
    WaitSeconds(1)

    -- Sweep over the action northwards
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_2_1'), 0)
    WaitSeconds(1)
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_2_2'), 5)
    WaitSeconds(1)

    -- Sweep over the action southwards
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_2_3'), 5)
    WaitSeconds(2)

    -- We might not need these cameras after all...
    -- Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_2_4'), 9)
    -- WaitSeconds(1)
    -- Look to where the attacks are coming from
    -- Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_2_5'), 3)

    -- "Go save them"
    ScenarioFramework.Dialogue(VoiceOvers.CivvyDefense, nil, true) -- 10 sec
    -- WaitSeconds(1)
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_2_6'), 3)
    WaitSeconds(1)

    -- Kill all of the featured attackers and defenders while the we're looking elsewhere
    for k, unit in ScenarioInfo.NISCivilianDefenders do
        if ( unit and not unit:IsDead() ) then
            unit:Kill()
        end
    end
    for k, unit in ScenarioInfo.NISOrderAttackers do
        if ( unit and not unit:IsDead() ) then
            unit:Kill()
        end
    end

    -- Snap to an enemy base, then zoom out
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_2_7'), 3)
    WaitSeconds(1)
    -- "I'll kill everyone"
    ScenarioFramework.Dialogue(VoiceOvers.AeonThreats, nil, true) -- 5 sec
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_2_8'), 3)
    WaitSeconds(1)

    Cinematics.SetInvincible( 'M1_Playable_Area', true )
    Cinematics.ExitNISMode()
    StartMission2()
end

function StartMission2()
    ----------------------------------------
    -- Primary Objective 1 - Protect the Town
    ----------------------------------------
    ScenarioInfo.M2P1 = Objectives.Protect(
        'primary',
        'incomplete',
        OpStrings.X01_M02_OBJ_010_010,
        OpStrings.X01_M02_OBJ_010_020,
        {
            Units = ScenarioInfo.M2CivilianBuildings,
            NumRequired = math.ceil(table.getn(ScenarioInfo.M2CivilianBuildings)/2),
            PercentProgress = true,
            ShowFaction = 'UEF',
        }
    )
    ScenarioInfo.M2P1:AddResultCallback(
        function(result)
            if(result == false) then
                ScenarioFramework.Dialogue(VoiceOvers.CivvyDefenseFailed, nil, true)
                PlayerLose()
            end
        end
    )
    table.insert(AssignedObjectives, ScenarioInfo.M2P1)

    ------------------------------------------
    -- Primary Objective 2 - Destroy Order Base
    ------------------------------------------
    ScenarioInfo.M2P2 = Objectives.CategoriesInArea(
        'primary',                      -- type
        'incomplete',                   -- status
        OpStrings.X01_M02_OBJ_010_070,  -- title
        OpStrings.X01_M02_OBJ_010_080,  -- description
        'Kill',
        {                               -- target
            MarkUnits = true,
            Requirements = {
                {Area = 'M2_ObjArea_1', Category = categories.FACTORY, CompareOp = '<=', Value = 0, ArmyIndex = Order},
                {Area = 'M2_ObjArea_2', Category = categories.FACTORY, CompareOp = '<=', Value = 0, ArmyIndex = Order},
                {Area = 'M2_ObjArea_3', Category = categories.FACTORY, CompareOp = '<=', Value = 0, ArmyIndex = Order},
                {Area = 'M2_ObjArea_4', Category = categories.FACTORY, CompareOp = '<=', Value = 0, ArmyIndex = Order},
                {Area = 'M2_ObjArea_5', Category = categories.FACTORY, CompareOp = '<=', Value = 0, ArmyIndex = Order},
            },
        }
    )
    ScenarioInfo.M2P2:AddResultCallback(
        function(result)
            if(result) then
                ScenarioInfo.M2P1:ManualResult(true)
                IntroMission3()
            end
        end
    )
    table.insert(AssignedObjectives, ScenarioInfo.M2P2)
    ScenarioInfo.M2CivBuildingCount = table.getn(ScenarioInfo.M2CivilianBuildings)
    ScenarioInfo.M2BuildingFailLimit = math.ceil(table.getn(ScenarioInfo.M2CivilianBuildings)/2)
    for i = 1, ScenarioInfo.M2CivBuildingCount do
        ScenarioFramework.CreateUnitDeathTrigger(M2P1Warnings, ScenarioInfo.M2CivilianBuildings[i])
    end

    -- Secondary Attacks
    ScenarioFramework.CreateTimerTrigger(OrderSecondaryAttack1, 15)
    ScenarioFramework.CreateTimerTrigger(OrderSecondaryAttack2, 30)
    ScenarioFramework.CreateTimerTrigger(OrderSecondaryAttack3, 45)
    ScenarioFramework.CreateTimerTrigger(OrderSecondaryAttack4, 60)

    -- Tech unlock, Aeon t2 fighter
    ScenarioFramework.UnrestrictWithVoiceoverAndDelay(categories.xaa0202, "aeon", 45, VoiceOvers.T2FighterUnlocked)
end

--- Called when one of the civilian buildings you must defend in the main settlement is destroyed.
function M2P1Warnings()
    ScenarioInfo.M2CivBuildingCount = ScenarioInfo.M2CivBuildingCount - 1

    if not ScenarioInfo.M2P1.Active then
        return
    end

    -- if we've only 3 buildings more than the min, play a warning
    if ScenarioInfo.M2CivBuildingCount == ScenarioInfo.M2BuildingFailLimit + 4 then
        ScenarioFramework.Dialogue(VoiceOvers.LosingBuildingsWarning1)
    end

    -- if we've only 1 building more than the min, play another
    if ScenarioInfo.M2CivBuildingCount == ScenarioInfo.M2BuildingFailLimit + 1 then
        ScenarioFramework.Dialogue(VoiceOvers.LosingBuildingsWarning2)
    end
end

function OrderSecondaryAttack1()
    if(ScenarioInfo.OrderSecondaryAttack1 and ArmyBrains[Order]:PlatoonExists(ScenarioInfo.OrderSecondaryAttack1)) then
        for k, v in ScenarioInfo.OrderSecondaryAttack1:GetPlatoonUnits() do
            if(v and not v:IsDead()) then
                IssueClearCommands({v})
            end
        end
        ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.OrderSecondaryAttack1, 'Order_M2_TownAttack_Chain')
    end
end

function OrderSecondaryAttack2()
    if(ScenarioInfo.OrderSecondaryAttack2 and ArmyBrains[Order]:PlatoonExists(ScenarioInfo.OrderSecondaryAttack2)) then
        for k, v in ScenarioInfo.OrderSecondaryAttack2:GetPlatoonUnits() do
            if(v and not v:IsDead()) then
                IssueClearCommands({v})
            end
        end
        ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.OrderSecondaryAttack2, 'Order_M2_TownAttack_Chain')
    end
end

function OrderSecondaryAttack3()
    if(ScenarioInfo.OrderSecondaryAttack3 and ArmyBrains[Order]:PlatoonExists(ScenarioInfo.OrderSecondaryAttack3)) then
        for k, v in ScenarioInfo.OrderSecondaryAttack3:GetPlatoonUnits() do
            if(v and not v:IsDead()) then
                IssueClearCommands({v})
            end
        end
        ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.OrderSecondaryAttack3, 'Order_M2_TownAttack_Chain')
    end
end

function OrderSecondaryAttack4()
    if(ScenarioInfo.OrderSecondaryAttack4 and ArmyBrains[Order]:PlatoonExists(ScenarioInfo.OrderSecondaryAttack4)) then
        for k, v in ScenarioInfo.OrderSecondaryAttack4:GetPlatoonUnits() do
            if(v and not v:IsDead()) then
                IssueClearCommands({v})
            end
        end
        ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.OrderSecondaryAttack4, 'Order_M2_TownAttack_Chain')
    end
end

-----------
-- Mission 3
-----------
function IntroMission3()
    ForkThread(
        function()
            ScenarioFramework.FlushDialogueQueue()
            while(ScenarioInfo.DialogueLock) do
                WaitSeconds(0.2)
            end

            ScenarioInfo.MissionNumber = 3
            GariM1M2TM:Activate(false)

            -- Disable the UEF Town in M2
            M2UEFAI.DisableBase()

            ScenarioFramework.Dialogue(OpStrings.X01_M02_240)

            ------------------
            -- UEF Eastern Town
            ------------------
            UEFM3EasternTown:InitializeDifficultyTables(ArmyBrains[UEF], 'M2_South_Town_Defense', 'UEF_M2_South_Base_Marker', 50, {M2_South_Town_Defense = 100})
            UEFM3EasternTown:StartNonZeroBase(0)

            -----------
            -- Civilians
            -----------
            ScenarioUtils.CreateArmyGroup('Civilians', 'M2_Civilian_WreckedCity_South', true)
            ScenarioUtils.CreateArmyGroup('Civilians', 'M3_Wreckage', true)
            ScenarioInfo.M3CivilianCity = ScenarioUtils.CreateArmyGroup('Civilians', 'M2_Civilian_South_City')
            ScenarioInfo.M3CivilianCityNum = table.getn(ScenarioInfo.M3CivilianCity)
            ScenarioUtils.CreateArmyGroup('Civilians', 'M2_Civilian_Middle_City')

            -------------
            -- Order M3 AI
            -------------
            M3OrderAI.OrderM3MainBaseAI()
            M3OrderAI.OrderM3NavalBaseAI()
            M3OrderAI.OrderM3ExpansionBaseAI()

            -- Order CDR
            ScenarioInfo.OrderCDR = ScenarioUtils.CreateArmyUnit('Order', 'Order_ACU')
            ScenarioInfo.OrderCDR:SetCustomName(LOC '{i Gari}')

            -----------------------
            -- Order Initial Patrols
            -----------------------
            local units = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'M2_Main_Adapt_Colos_' .. Difficulty, 'AttackFormation')
            for k, v in units:GetPlatoonUnits() do
                ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('Order_M2_Main_Exp_Chain')))
            end

            for i = 1, 2 do
                units = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'M2_Main_Adapt_Air', 'GrowthFormation')
                for k, v in units:GetPlatoonUnits() do
                    if(Random(1, 2)== 1) then
                        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('Order_M3Main_MidAirDef_Chain')))
                    else
                        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('Order_M3Main_NearAirDef_Chain')))
                    end
                end
            end

            units = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'M2_Naval_Start_Patrol_D' .. Difficulty, 'AttackFormation')
            for k, v in units:GetPlatoonUnits() do
                if(Random(1,2) == 1) then
                    ScenarioFramework.GroupPatrolChain({v}, 'Order_M2_NavalBasePatrol_Chain')
                else
                    ScenarioFramework.GroupPatrolChain({v}, 'Order_M2_NavalBasePatrol2_Chain')
                end
            end

            M3CounterAttack()
        end
    )
end

function M3CounterAttack()
    local quantity = {}
    local trigger = {}

    -- Default
    local units = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'M2_Air_Counter_1', 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(units, 'Order_M2_East_Air_Counter_Chain')

    units = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'M2_Air_Counter_2', 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(units, 'Order_M2_Middle_Air_Counter_Chain')

    units = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'M2_Air_Counter_3', 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(units, 'Order_M2_West_Air_Counter_Chain')

    units = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'M2_West_Bridge_Counter', 'AttackFormation')
    ScenarioFramework.PlatoonAttackWithTransports(units, 'WestBridgeLandingChain', 'WestBridgeAttackChain', true)

    units = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'M2_East_Bridge_Counter', 'AttackFormation')
    ScenarioFramework.PlatoonAttackWithTransports(units, 'EastBridgeLandingChain', 'EastBridgeAttackChain', true)

    units = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'M2_Naval_Counter', 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(units, 'M3_Order_NavalAttack_Chain')

    local colossus = ScenarioUtils.CreateArmyUnit('Order', 'M3_Order_Colos') -- associated warning VO played elsewhere, X01_M02_281
    local platoon = ArmyBrains[Order]:MakePlatoon('', '')
    ArmyBrains[Order]:AssignUnitsToPlatoon(platoon, {colossus}, 'Attack', 'AttackFormation')
    if(Difficulty < 3) then
        ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_Order_Counter_EastAttack_Chain')
    else
        ScenarioFramework.PlatoonPatrolChain(platoon, 'Order_M1_LandAttack_Chain')
    end

    -- sends gunships at mass extractors on the beach, up to 2, 4, 6 if < 400 units, up to 4, 6, 10 if >= 400 units
    local extractors = ScenarioFramework.GetCatUnitsInArea(categories.MASSEXTRACTION, ScenarioUtils.AreaToRect('M3_IslandMass_South_Area'), ArmyBrains[Player])
    local num = table.getn(extractors)
    local total = 0
    quantity = {2, 4, 6}
    if(num > 0) then
        local num = 0
        for _, player in ScenarioInfo.HumanPlayers do
            num = num + table.getn(ArmyBrains[player]:GetListOfUnits(categories.ALLUNITS - categories.WALL, false))
        end
        if (num < 400) then
            if(num > quantity[Difficulty]) then
                num = quantity[Difficulty]
            end
        else
            quantity = {4, 6, 10}
            if(num > quantity[Difficulty]) then
                num = quantity[Difficulty]
            end
        end
        for i = 1, num do
            units = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'M2_Main_Adapt_3Gunship_D' .. Difficulty, 'GrowthFormation')
            IssueAttack(units:GetPlatoonUnits(), extractors[i])
            ScenarioFramework.PlatoonPatrolChain(units, 'M1_Order_E_AirAttack_1_Chain')
            total = total + 1
        end
    end
    if(total < quantity[Difficulty]) then
        extractors = ScenarioFramework.GetCatUnitsInArea(categories.MASSEXTRACTION, ScenarioUtils.AreaToRect('M3_IslandMass_North_Area'), ArmyBrains[Player])
        num = table.getn(extractors)
        if(num > 0) then
            if(num > quantity[Difficulty] - total) then
                num = quantity[Difficulty] - total
            end
            for i = 1, num do
                units = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'M2_Main_Adapt_3Gunship_D' .. Difficulty, 'GrowthFormation')
                IssueAttack(units:GetPlatoonUnits(), extractors[i])
                ScenarioFramework.PlatoonPatrolChain(units, 'M1_Order_E_AirAttack_1_Chain')
            end
        end
    end

    -- sends aa gunships at each SCU, up to [2, 5, 7]
    quantity = {2, 5, 7}
    for _, player in ScenarioInfo.HumanPlayers do
        local scus = ArmyBrains[player]:GetListOfUnits(categories.SUBCOMMANDER, false)
        num = table.getn(scus)
        if(num > 0) then
            if(num > quantity[Difficulty]) then
                num = quantity[Difficulty]
            end
            for i = 1, num do
                units = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Order', 'M2_Main_Adapt_T3AAGunship', 'GrowthFormation', 5)
                IssueAttack(units:GetPlatoonUnits(), scus[i])
                ScenarioFramework.PlatoonPatrolChain(units, 'M1_Order_E_AirAttack_1_Chain')
            end
        end
    end

    -- sends aa gunships at every other shield, up to [1, 3, 10]
    quantity = {1, 3, 10}
    for _, player in ScenarioInfo.HumanPlayers do
        local shields = ArmyBrains[player]:GetListOfUnits(categories.SHIELD * categories.STRUCTURE, false)
        num = table.getn(shields)
        if(num > 0) then
            num = math.ceil(num/2)
            if(num > quantity[Difficulty]) then
                num = quantity[Difficulty]
            end
            for i = 1, num do
                units = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Order', 'M2_Main_Adapt_T3AAGunship', 'GrowthFormation', 5)
                IssueAttack(units:GetPlatoonUnits(), shields[i])
                ScenarioFramework.PlatoonPatrolChain(units, 'M1_Order_E_AirAttack_1_Chain')
            end
        end
    end

    -- sends strat bombers at each battleship, up to [1, 3, 5]
    quantity = {1, 3, 5}
    for _, player in ScenarioInfo.HumanPlayers do
        local battleships = ArmyBrains[player]:GetListOfUnits(categories.BATTLESHIP, false)
        num = table.getn(battleships)
        if(num > 0) then
            if(num > quantity[Difficulty]) then
                num = quantity[Difficulty]
            end
            for i = 1, num do
                units = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Order', 'M2_Main_Adapt_Bomber', 'GrowthFormation', 5)
                IssueAttack(units:GetPlatoonUnits(), battleships[i])
                ScenarioFramework.PlatoonPatrolChain(units, 'M1_Order_E_AirAttack_1_Chain')
            end
        end
    end

    -- Structure Experimentals, up to 2, 5, 7
    quantity = {2, 5, 7}
    total = 0

    -- sends [1, 2, 3] strat bomber groups at each mavor
    for _, player in ScenarioInfo.HumanPlayers do
        local exp = ArmyBrains[player]:GetListOfUnits(categories.ueb2401, false)
        num = table.getn(exp)
        if(num > 0) then
            if(num > quantity[Difficulty]) then
                num = quantity[Difficulty]
            end
            for i = 1, num do
                for j = 1, Difficulty do
                    units = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Order', 'M2_Main_Adapt_Bomber', 'GrowthFormation', 5)
                    IssueAttack(units:GetPlatoonUnits(), exp[i])
                    ScenarioFramework.PlatoonPatrolChain(units, 'M1_Order_E_AirAttack_1_Chain')
                    local guards = ScenarioUtils.CreateArmyGroup('Order', 'M2_Main_Adapt_StratGuards')
                    IssueGuard(guards, units:GetPlatoonUnits()[1])
                end
                total = total + 1
            end
        end
    end

    -- sends [1, 2, 3] strat bomber groups at each hlra
    if(total < quantity[Difficulty]) then
        for _, player in ScenarioInfo.HumanPlayers do
            local exp = ArmyBrains[player]:GetListOfUnits(categories.TECH3 * categories.ARTILLERY * categories.STRUCTURE, false)
                num = table.getn(exp)
                if(num > 0) then
                    if(num > quantity[Difficulty] - total) then
                        num = quantity[Difficulty] - total
                    end
                end
        end
        for i = 1, num do
            for j = 1, Difficulty do
                units = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Order', 'M2_Main_Adapt_Bomber', 'GrowthFormation', 5)
                IssueAttack(units:GetPlatoonUnits(), exp[i])
                ScenarioFramework.PlatoonPatrolChain(units, 'M1_Order_E_AirAttack_1_Chain')
                local guards = ScenarioUtils.CreateArmyGroup('Order', 'M2_Main_Adapt_StratGuards')
                IssueGuard(guards, units:GetPlatoonUnits()[1])
            end
            total = total + 1
        end
    end

    -- sends 1 strat bomber group at each nuke
    if(total < quantity[Difficulty]) then
        for _, player in ScenarioInfo.HumanPlayers do
            local exp = ArmyBrains[player]:GetListOfUnits(categories.NUKE * categories.STRUCTURE, false)
			num = table.getn(exp)
			if(num > 0) then
				if(num > quantity[Difficulty] - total) then
					num = quantity[Difficulty] - total
				end
			end

			for i = 1, num do
				units = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Order', 'M2_Main_Adapt_Bomber', 'GrowthFormation', 5)
				IssueAttack(units:GetPlatoonUnits(), exp[i])
				ScenarioFramework.PlatoonPatrolChain(units, 'M1_Order_E_AirAttack_1_Chain')
				local guards = ScenarioUtils.CreateArmyGroup('Order', 'M2_Main_Adapt_StratGuards')
				IssueGuard(guards, units:GetPlatoonUnits()[1])
			end
		end
    end

    -- Mobile Land Experimentals, up to 2, 5, 8
    quantity = {2, 5, 8}
    total = 0

    -- sends strat bombers and gunships at each fatboy
    for _, player in ScenarioInfo.HumanPlayers do
        local exp = ArmyBrains[player]:GetListOfUnits(categories.uel0401, false)
        num = table.getn(exp)
        if(num > 0) then
            if(num > quantity[Difficulty]) then
                num = quantity[Difficulty]
            end
            for i = 1, num do
                units = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Order', 'M2_Main_Adapt_Bomber', 'GrowthFormation', 5)
                IssueAttack(units:GetPlatoonUnits(), exp[i])
                ScenarioFramework.PlatoonPatrolChain(units, 'M1_Order_E_AirAttack_1_Chain')
                units = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Order', 'M2_Main_Adapt_Gunship', 'GrowthFormation', 5)
                IssueAttack(units:GetPlatoonUnits(), exp[i])
                ScenarioFramework.PlatoonPatrolChain(units, 'M1_Order_E_AirAttack_1_Chain')
                total = total + 1
            end
        end
    end

    -- sends strat bombers at each spiderbot
    if(total < quantity[Difficulty]) then
        for _, player in ScenarioInfo.HumanPlayers do
            local exp = ArmyBrains[player]:GetListOfUnits(categories.url0402, false)
                num = table.getn(exp)
                if(num > 0) then
                    if(num > quantity[Difficulty] - total) then
                        num = quantity[Difficulty] - total
                    end
                    for i = 1, num do
                        units = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Order', 'M2_Main_Adapt_Bomber', 'GrowthFormation', 5)
                        IssueAttack(units:GetPlatoonUnits(), exp[i])
                        ScenarioFramework.PlatoonPatrolChain(units, 'M1_Order_E_AirAttack_1_Chain')
                        local guards = ScenarioUtils.CreateArmyGroup('Order', 'M2_Main_Adapt_StratGuards')
                        IssueGuard(guards, units:GetPlatoonUnits()[1])
                        total = total + 1
                    end
                end
        end
    end

    -- sends [1, 2, 3] strat bomber groups at each colossus
    if(total < quantity[Difficulty]) then
        for _, player in ScenarioInfo.HumanPlayers do
            local exp = ArmyBrains[player]:GetListOfUnits(categories.ual0401, false)
			num = table.getn(exp)
			if(num > 0) then
				if(num > quantity[Difficulty] - total) then
					num = quantity[Difficulty] - total
				end
				for i = 1, num do
					units = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Order', 'M2_Main_Adapt_Bomber', 'GrowthFormation', 5)
					IssueAttack(units:GetPlatoonUnits(), exp[i])
					ScenarioFramework.PlatoonPatrolChain(units, 'M1_Order_E_AirAttack_1_Chain')
					local guards = ScenarioUtils.CreateArmyGroup('Order', 'M2_Main_Adapt_StratGuards')
					IssueGuard(guards, units:GetPlatoonUnits()[1])
				end
			end
        end
    end

    -- Mobile Air Experimentals, up to 2, 5, 7
    quantity = {2, 5, 7}
    total = 0

    -- sends air superiority at each czar
    for _, player in ScenarioInfo.HumanPlayers do
        local exp = ArmyBrains[player]:GetListOfUnits(categories.uaa0310, false)
        num = table.getn(exp)
        if(num > 0) then
            if(num > quantity[Difficulty]) then
                num = quantity[Difficulty]
            end
            for i = 1, num do
                for j = 1, 2 do
                    units = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Order', 'M2_Main_Adapt_AirSup', 'GrowthFormation', 5)
                    IssueAttack(units:GetPlatoonUnits(), exp[i])
                    ScenarioFramework.PlatoonPatrolChain(units, 'M1_Order_E_AirAttack_1_Chain')
                end
                total = total + 1
            end
        end
    end

    -- sends air superiority at each soul ripper
    if(total < quantity[Difficulty]) then
        for _, player in ScenarioInfo.HumanPlayers do
            local exp = ArmyBrains[player]:GetListOfUnits(categories.ura0401, false)
                num = table.getn(exp)
                if(num > 0) then
                    if(num > quantity[Difficulty] - total) then
                        num = quantity[Difficulty] - total
                    end
                    for i = 1, num do
                        for j = 1, 2 do
                            units = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Order', 'M2_Main_Adapt_AirSup', 'GrowthFormation', 5)
                            IssueAttack(units:GetPlatoonUnits(), exp[i])
                            ScenarioFramework.PlatoonPatrolChain(units, 'M1_Order_E_AirAttack_1_Chain')
                        end
                    end
                end
        end
    end

    -- sends transport attacks for every other T2/T3 tower, up to [2, 6, 10]
    local num = 0
    for _, player in ScenarioInfo.HumanPlayers do
        num = num + table.getn(ArmyBrains[player]:GetListOfUnits((categories.STRUCTURE * categories.DEFENSE) - categories.TECH1, false))
    end

    quantity = {2, 6, 10}
    if(num > 0) then
        num = math.ceil(num/2)
        if(num > quantity[Difficulty]) then
            num = quantity[Difficulty]
        end
        for i = 1, num do
            units = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'M2_Main_Adapt_Xport' .. Random(1, 2), 'AttackFormation')
            for k, v in units:GetPlatoonUnits() do
                if(v:GetUnitId() == 'uaa0104') then
                    local guards = ScenarioUtils.CreateArmyGroup('Order', 'M2_Main_Adapt_XportDef')
                    IssueGuard(guards, v)
                    break
                end
            end
            ScenarioFramework.PlatoonAttackWithTransports(units, 'PlayerBaseArea_Landing_Chain', 'PlayerBaseArea_Attack_Chain', false)
        end
    end

    -- sends air superiority if player has more than [60, 40, 20] t2/t3 planes, up to 5, 1 group per 30, 20, 10
    local num = 0
    for _, player in ScenarioInfo.HumanPlayers do
        num = num + table.getn(ArmyBrains[player]:GetListOfUnits((categories.AIR * categories.MOBILE) - categories.TECH1, false))
    end

    quantity = {60, 40, 20}
    trigger = {30, 20, 10}
    if(num > quantity[Difficulty]) then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 5) then
            num = 5
        end
        for i = 1, num do
            units = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Order', 'M2_Main_Adapt_AirSup', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(units, 'M3_OrderCounter_WestAir_Chain')
        end
    end

    -- sends gunships if player has more than [70, 50, 30] t2/t3 land, up to 7, 1 group per 40, 25, 15
    local num = 0
    for _, player in ScenarioInfo.HumanPlayers do
        num = num + table.getn(ArmyBrains[player]:GetListOfUnits((categories.LAND * categories.MOBILE) - categories.TECH1 - categories.CONSTRUCTION, false))
    end

    quantity = {70, 50, 30}
    trigger = {40, 25, 15}
    if(num > quantity[Difficulty]) then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 7) then
            num = 7
        end
        for i = 1, num do
            units = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Order', 'M2_Main_Adapt_Gunship', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(units, 'M3_OrderCounter_WestAir_Chain')
        end
    end

    -- sends gunships if player has more than [475, 450, 425] units
    local num = 0
    for _, player in ScenarioInfo.HumanPlayers do
        num = num + table.getn(ArmyBrains[player]:GetListOfUnits(categories.ALLUNITS - categories.WALL, false))
    end

    quantity = {475, 450, 425}
    if(num > quantity[Difficulty]) then
        for i = 1, Difficulty do
            units = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Order', 'M2_Main_Adapt_Gunship', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(units, 'M3_OrderCounter_WestAir_Chain')
        end
    end

    -- sends amphibious attack for each naval factory, up to 1, 3, 5
    quantity = {1, 3, 5}
    local num = 0
    for _, player in ScenarioInfo.HumanPlayers do
        num = num + table.getn(ArmyBrains[player]:GetListOfUnits(categories.NAVAL * categories.FACTORY, false))
    end

    if(num > 0) then
        if(num > quantity[Difficulty]) then
            num = quantity[Difficulty]
        end
        for i = 1, num do
            units = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Order', 'M2_Main_Adapt_Xport_Amphib_D' .. Difficulty, 'AttackFormation', 5)
            ScenarioFramework.PlatoonAttackWithTransports(units, 'M3_Order_AmphibLanding_Chain', 'M3_Order_AmphibAttack_Chain', false)
        end
    end

    -- sends destroyers if player has [15, 10, 5] T2/T3 boats or [5, 3, 1] T3 boats
    local t2limits = {15, 10, 5}
    local t3limits = {5, 3, 1}
    if(table.getn(ArmyBrains[Player]:GetListOfUnits((categories.NAVAL * categories.MOBILE) - categories.TECH1, false)) >= t2limits[Difficulty] or
       table.getn(ArmyBrains[Player]:GetListOfUnits(categories.NAVAL * categories.MOBILE * categories.TECH3, false)) >= t3limits[Difficulty]) then
        units = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Order', 'M2_Adapt_Naval_Destro', 'AttackFormation', 5)
        ScenarioFramework.PlatoonPatrolChain(units, 'M3_Order_Adapt_NavalAttack_Chain')
    end

    -- sends cruisers if player has [24, 20, 16] T2/T3 boats or [6, 4, 2] T3 boats
    t2limits = {24, 20, 16}
    t3limits = {6, 4 ,2}
    if(table.getn(ArmyBrains[Player]:GetListOfUnits((categories.NAVAL * categories.MOBILE) - categories.TECH1, false)) >= t2limits[Difficulty] or
       table.getn(ArmyBrains[Player]:GetListOfUnits(categories.NAVAL * categories.MOBILE * categories.TECH3, false)) >= t3limits[Difficulty]) then
        units = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Order', 'M2_Adapt_Naval_Cruiser', 'AttackFormation', 5)
        ScenarioFramework.PlatoonPatrolChain(units, 'M3_Order_Adapt_NavalAttack_Chain')
    end

    -- sends torpedo bombers if player has [20, 10, 5] navy
    quantity = {20, 10, 5}
    if(table.getn(ArmyBrains[Player]:GetListOfUnits(categories.NAVAL, false)) > quantity[Difficulty]) then
        units = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Order', 'M2_Main_Adapt_Torpedo', 'GrowthFormation', 5)
        ScenarioFramework.PlatoonPatrolChain(units, 'M3_Order_Torpedo_Patrol_Chain')
    end

    -- sends torpedo bombers for every [20, 15, 10] T1 boats, up to 1, 2, 3
    local num = 0
    for _, player in ScenarioInfo.HumanPlayers do
        num = num + table.getn(ArmyBrains[player]:GetListOfUnits(categories.NAVAL * categories.MOBILE * categories.TECH1, false))
    end

    quantity = {20, 15, 10}
    trigger = {1, 2, 3}
    if(num > quantity[Difficulty]) then
        num = math.ceil(num/quantity[Difficulty])
        if(num > trigger[Difficulty]) then
            num = trigger[Difficulty]
        end
        for i = 1, num do
            units = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Order', 'M2_Main_Adapt_Torpedo', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(units, 'M3_Order_Torpedo_Patrol_Chain')
        end
    end

    -- sends torpedo bombers for every [14, 10, 6] T2 boats, up to 1, 2, 3
    local num = 0
    for _, player in ScenarioInfo.HumanPlayers do
        num = num + table.getn(ArmyBrains[player]:GetListOfUnits(categories.NAVAL * categories.MOBILE * categories.TECH2, false))
    end

    quantity = {14, 10, 6}
    trigger = {1, 2, 3}
    if(num > quantity[Difficulty]) then
        num = math.ceil(num/quantity[Difficulty])
        if(num > trigger[Difficulty]) then
            num = trigger[Difficulty]
        end
        for i = 1, num do
            units = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Order', 'M2_Main_Adapt_Torpedo', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(units, 'M3_Order_Torpedo_Patrol_Chain')
        end
    end

    -- sends torpedo bombers if player for every [3, 2, 1] T3 boats, up to 1, 2, 3
    local num = 0
    for _, player in ScenarioInfo.HumanPlayers do
        num = num + table.getn(ArmyBrains[player]:GetListOfUnits(categories.NAVAL * categories.MOBILE * categories.TECH3, false))
    end

    quantity = {3, 2, 1}
    trigger = {1, 2, 3}
    if(num > quantity[Difficulty]) then
        num = math.ceil(num/quantity[Difficulty])
        if(num > trigger[Difficulty]) then
            num = trigger[Difficulty]
        end
        for i = 1, num do
            units = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Order', 'M2_Main_Adapt_Torpedo', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(units, 'M3_Order_Torpedo_Patrol_Chain')
        end
    end

    ------------------
    -- Retake the beach
    ------------------

    -- Snipers on the bluffs
    local veterancy = 0
    if Difficulty == 3 then
        veterancy = 5
    end
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Order', 'M3_Order_SniperGroup_1_D' .. Difficulty, 'AttackFormation', veterancy)
    platoon:MoveToLocation(ScenarioUtils.MarkerToPosition('Order_M1_East_Bluffs_Patrol_1'), false)
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Order', 'M3_Order_SniperGroup_2_D' .. Difficulty, 'AttackFormation', veterancy)
    platoon:MoveToLocation(ScenarioUtils.MarkerToPosition('Order_M1_East_Bluffs_Patrol_3'), false)
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Order', 'M3_Order_SniperGroup_3_D' .. Difficulty, 'AttackFormation', veterancy)
    platoon:MoveToLocation(ScenarioUtils.MarkerToPosition('Order_M1_West_Bluffs_Patrol_1'), false)
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Order', 'M3_Order_SniperGroup_4_D' .. Difficulty, 'AttackFormation', veterancy)
    platoon:MoveToLocation(ScenarioUtils.MarkerToPosition('Order_M1_West_Bluffs_Patrol_3'), false)

    -- "Good job beating mission 2"
    ScenarioFramework.Dialogue(VoiceOvers.CivvyDefenseSucceeded, Mission3NIS)
end

function StartMission3()

    -- Taunts, dialogue
    SetupGariTauntTriggers()
    ScenarioFramework.CreateTimerTrigger(M3ColosWarningDialogue, 25)
    ScenarioFramework.CreateTimerTrigger(M3SniperBotDialogue, 80)
    ScenarioFramework.CreateTimerTrigger(M3GariTaunt1, 600)
    ScenarioFramework.CreateTimerTrigger(M3GariTaunt2, 1200)

    --------------------------------------
    -- Primary Objective 1 - Kill Order ACU
    --------------------------------------
    ScenarioInfo.M3P1 = Objectives.KillOrCapture(
        'primary',                      -- type
        'incomplete',                   -- complete
        OpStrings.X01_M02_OBJ_010_050,  -- title
        OpStrings.X01_M02_OBJ_010_060,  -- description
        {                               -- target
            Units = {ScenarioInfo.OrderCDR},
            MarkUnits = true,
            FlashVisible = true,
        }
    )
    ScenarioInfo.M3P1:AddResultCallback(
        function(result)
            if(result) then
                ScenarioFramework.Dialogue(OpStrings.TAUNT23)
                ForkThread(OrderCDRDeathNIS)
                ForkThread(KillOrder)
                ScenarioFramework.Dialogue(VoiceOvers.AeonDefeated, IntroMission4)
            end
        end
    )
    table.insert(AssignedObjectives, ScenarioInfo.M3P1)
    ScenarioFramework.CreateTimerTrigger(M3P1Reminder1, 2700)
    ScenarioFramework.CreateTimerTrigger(CounterAttackWarning, 5)

    if LeaderFaction == 'uef' then
        -- For UEF, assign the Truck Town objective after a bit of a pause. We'll send in the
        -- attack where we assign, as it is dialogue-callback based (ie, in case dialogue gets stacked
        -- up, we don't have the attack sent before the late dialogue)
        ScenarioFramework.CreateTimerTrigger(NavalTownAssign, 70)
    end

    -- ForkThread(Mission3NIS)
end

function M3ColosWarningDialogue()
    -- Warn of impending incarna
    ScenarioFramework.Dialogue(VoiceOvers.ColossusWarning)
end

function M3SniperBotDialogue()
    -- Point out that enemy has sent in the new sniper bot unit.
    ScenarioFramework.Dialogue(VoiceOvers.SniperBotWarning)
end

function OrderCDRDeathNIS()
    ScenarioFramework.CDRDeathNISCamera(ScenarioInfo.OrderCDR, 5)
end

function Mission3NIS()
    ScenarioFramework.SetPlayableArea('M3_Playable_Area')
    Cinematics.EnterNISMode()
    Cinematics.SetInvincible( 'M2_Playable_Area' )
    WaitSeconds(1)

    -- One vis marker with a huge radius will work for this
    local M3VizMarker = ScenarioFramework.CreateVisibleAreaLocation( 200, ScenarioUtils.MarkerToPosition( 'M3_NIS_Vis_1' ), 0, ArmyBrains[Player] )
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_3_1'), 0)
    ScenarioFramework.Dialogue(VoiceOvers.AeonRevenge1, nil, true)
    WaitSeconds(1)

    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_3_2'), 4)
    WaitSeconds(1)

    ScenarioFramework.Dialogue(VoiceOvers.AeonRevenge2, nil, true)
    Cinematics.CameraTrackEntity( ScenarioInfo.OrderCDR, 20, 4 )
    WaitSeconds(3)

-- Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_3_3'), 7)
-- WaitSeconds(2)

    M3VizMarker:Destroy()
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_3_4'), 3)

    Cinematics.SetInvincible( 'M2_Playable_Area', true )
    Cinematics.ExitNISMode()

    ForkThread( StartMission3 )
end

function CounterAttackWarning()
    ScenarioFramework.Dialogue(VoiceOvers.CounterattackWarning)
end

function NavalTownAssign()
    ScenarioFramework.Dialogue(VoiceOvers.OtherCivvyDefenseRequest, M3UEFSecondaryPart1)
end

function M3UEFSecondaryPart1()
    ScenarioInfo.NavalTownAttack = ScenarioUtils.CreateArmyGroup('Order', 'M2_Naval_Attack_D' .. Difficulty)
    ScenarioFramework.CreateGroupDeathTrigger(M3UEFTownSaved, ScenarioInfo.NavalTownAttack)

    --------------------------------------------------------
    -- UEF Secondary Objective 1 - Protect Civilians - Part 1
    --------------------------------------------------------
    ScenarioInfo.M3S1UEF = Objectives.Protect(
        'secondary',                    -- type
        'incomplete',                   -- complete
        OpStrings.X01_M02_OBJ_020_010,  -- title
        OpStrings.X01_M02_OBJ_020_020,  -- description
        {
            Units = ScenarioInfo.M3CivilianCity,
            NumRequired = math.ceil(table.getn(ScenarioInfo.M3CivilianCity)/2),
            PercentProgress = true,
            ShowFaction = 'UEF',
        }
    )
    ScenarioInfo.M3S1UEF:AddResultCallback(
        function(result)
            if(result) then
                ScenarioInfo.TrucksCreated = 0
                ScenarioInfo.TrucksDestroyed = 0
                ScenarioInfo.TrucksEscorted = 0
                ScenarioInfo.Trucks = {}

                ScenarioFramework.Dialogue(VoiceOvers.TownDefenseSuccess, TruckNIS)
            else
                ScenarioFramework.Dialogue(VoiceOvers.SadCivvies)
                ScenarioFramework.Dialogue(VoiceOvers.ManiacialAeonCackling, nil, false, ScenarioInfo.OrderCDR)
            end
        end
    )
    table.insert(AssignedObjectives, ScenarioInfo.M3S1UEF)

    -- Reminder, and death trigger for the town (for fail case)
    ScenarioFramework.CreateTimerTrigger(M3S1UEFReminder1, 540)
    ScenarioFramework.CreateTimerTrigger(NavalTownAttack, 100)
end

function NavalTownAttack()
    -- Warn of the incoming naval attack, and spawn the attack in
    ScenarioFramework.Dialogue(VoiceOvers.NavalAttackWarning)
    for k,v in ScenarioInfo.NavalTownAttack do
        local platoon = ArmyBrains[Order]:MakePlatoon('','')
        ArmyBrains[Order]:AssignUnitsToPlatoon(platoon, {v}, 'Attack', 'AttackFormation')
        platoon:MoveToLocation(ScenarioUtils.MarkerToPosition('M3_Order_TownAttackNaval_1'), false)
        ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_Order_NavalTown_Chain')
    end
end

function M3UEFTownSaved()
    if(ScenarioInfo.M3S1UEF.Active) then
        ScenarioInfo.M3S1UEF:ManualResult(true)
    end
end

function TruckNIS()
    local watchCommands = {}
    ScenarioFramework.Dialogue(VoiceOvers.TruckNotification)
    ScenarioFramework.Dialogue(VoiceOvers.TruckThread, nil, false, ScenarioInfo.OrderCDR)
    ScenarioInfo.AllowTruckWarning = true
    ScenarioInfo.M2TruckWarningDialogue = 0
    for i = 1, MaxTrucks do
        ScenarioInfo.TrucksCreated = i
        local unit = ScenarioUtils.CreateArmyUnit('Civilians', 'Civilian_Truck_'..ScenarioInfo.TrucksCreated)
        ScenarioFramework.CreateUnitDamagedTrigger(M3TruckDamageWarning, unit, .01)
        ScenarioFramework.CreateUnitDestroyedTrigger(TruckDestroyed, unit)
        ScenarioFramework.CreateUnitToMarkerDistanceTrigger(TruckRescued, unit, ScenarioUtils.MarkerToPosition('UEF_M2_Secondary_Escort_Marker'), 20)
        ScenarioFramework.CreateUnitToMarkerDistanceTrigger(TruckInBuilding, unit, ScenarioUtils.MarkerToPosition('UEF_M2_Secondary_Escort_Marker'), 10)
        table.insert(ScenarioInfo.Trucks, unit)

        if ScenarioInfo.TrucksCreated < 7 then
            IssueMove({unit}, ScenarioUtils.MarkerToPosition('M3_Truck_Waypoint_1'))
        end
        IssueMove({unit}, ScenarioUtils.MarkerToPosition('M3_Truck_Waypoint_2'))
        IssueMove({unit}, ScenarioUtils.MarkerToPosition('M3_Truck_Waypoint_3'))
        IssueMove({unit}, ScenarioUtils.MarkerToPosition('M3_Truck_ParkSpot_' .. i))
    end

    --------------------------------------------------------
    -- UEF Secondary Objective 1 - Protect Civilians - Part 2
    --------------------------------------------------------
    ScenarioInfo.M3S2UEF = Objectives.Basic(
        'secondary',                                        -- type
        'incomplete',                                       -- complete
        OpStrings.X01_M02_OBJ_020_030,                      -- title
        OpStrings.X01_M02_OBJ_020_040,                      -- description
        Objectives.GetActionIcon('move'),
        {                                                   -- target
            Area = 'M2_UEF_Secondary_Move_Area',
            MarkArea = true,
        }
    )
    table.insert(AssignedObjectives, ScenarioInfo.M3S2UEF)
    ScenarioFramework.CreateTimerTrigger(M3S2UEFReminder1, 1000)

    -- Setup ping
    ScenarioInfo.TruckPing = PingGroups.AddPingGroup(OpStrings.X01_M01_OBJ_010_030, 'uec0001', 'move', OpStrings.X01_M01_OBJ_010_035 )
    ScenarioInfo.TruckPing:AddCallback(MoveTrucks)
end

function MoveTrucks(location)
    if(ScenarioInfo.Trucks) then
        for k,v in ScenarioInfo.Trucks do
            if(not v:IsDead()) then
                IssueStop({v})
                IssueClearCommands({v})
                IssueMove({v}, location)
            end
        end
    end
end

function M3TruckDamageWarning()
    if ScenarioInfo.AllowTruckWarning then
        ScenarioInfo.M2TruckWarningDialogue = ScenarioInfo.M2TruckWarningDialogue + 1
        if ScenarioInfo.M2TruckWarningDialogue == 1 then
            ScenarioFramework.Dialogue(VoiceOvers.TruckDamage1)
        end
        if ScenarioInfo.M2TruckWarningDialogue == 2 then
            ScenarioFramework.Dialogue(VoiceOvers.TruckDamage2)
        end
        ScenarioInfo.AllowTruckWarning = false
        ScenarioFramework.CreateTimerTrigger(M2TruckWarningUnlock, 30)
    end
end

function M2TruckWarningUnlock()
    ScenarioInfo.AllowTruckWarning = true
end

function TruckDestroyed()
    ScenarioInfo.TrucksDestroyed = ScenarioInfo.TrucksDestroyed + 1
    if MaxTrucks - ScenarioInfo.TrucksDestroyed < RequiredTrucks[Difficulty] and ScenarioInfo.M3S2UEF.Active then
        ScenarioInfo.M3S2UEF:ManualResult(false)
        ScenarioInfo.TruckPing:Destroy()
        ScenarioFramework.Dialogue(VoiceOvers.TruckDefenseFailed)
        return
    end

    ScenarioFramework.Dialogue(VoiceOvers[TruckLost .. tostring(ScenarioInfo.TrucksDestroyed)])
end

function TruckRescued(unit)
    for k,v in ScenarioInfo.Trucks do
        if(v == unit) then
            table.remove(ScenarioInfo.Trucks, k)
        end
    end
    unit:SetCanBeKilled(false)
    IssueStop({unit})
    IssueMove({unit}, ScenarioUtils.MarkerToPosition('UEF_M2_Secondary_Escort_Marker'))
    ScenarioInfo.TrucksEscorted = ScenarioInfo.TrucksEscorted + 1

    if ScenarioInfo.TrucksEscorted == RequiredTrucks[Difficulty] then
        ScenarioInfo.M3S2UEF:ManualResult(true)
        ScenarioInfo.TruckPing:Destroy()
        ScenarioFramework.Dialogue(VoiceOvers.TruckDefenseComplete1)
        ScenarioFramework.Dialogue(VoiceOvers.TruckDefenseComplete2)
        ScenarioFramework.Dialogue(OpStrings.TAUNT7, nil, nil, ScenarioInfo.UnitNames[Order]['Order_ACU'])
    elseif not ScenarioInfo.TruckArriveLock then
        if ScenarioInfo.TrucksEscorted < 3 then
            ScenarioInfo.TruckArriveLock = true
            ScenarioFramework.Dialogue(VoiceOvers["TrucksRescued" .. ScenarioInfo.TrucksEscorted])
            ScenarioFramework.CreateTimerTrigger(function() ScenarioInfo.TruckArriveLock = false end, 15)
        end
    end
end

function TruckInBuilding(unit)
    unit:Destroy()
end

function KillOrder()
    local units = ArmyBrains[Order]:GetListOfUnits(categories.ALLUNITS - (categories.NAVAL * categories.MOBILE), false)
    local waitNum = math.floor(table.getn(units) / 20)
    for k,v in units do
        if(not v:IsDead()) then
            v:Kill()
        end
        WaitSeconds(.1)
    end
end

-----------
-- Mission 4
-----------
function IntroMission4()
    ForkThread(
        function()
            ScenarioFramework.FlushDialogueQueue()
            while(ScenarioInfo.DialogueLock) do
                WaitSeconds(0.2)
            end

            ScenarioInfo.MissionNumber = 4

            -----------
            -- Civilians
            -----------
            ScenarioUtils.CreateArmyGroup('Civilians', 'M3_Civilian_Buildings')
            ScenarioUtils.CreateArmyGroup('Civilians', 'M4_Wreckage', true)

            -----------
            -- M4 UEF AI
            -----------
            M4UEFAI.FortClarkeAI()
            M4UEFAI.UEFM4ForwardOneAI()
            M4UEFAI.UEFM4ForwardTwoAI()

            ScenarioFramework.CreateTimerTrigger(M4UEFAI.FortClarkeTransportAttacks, 1200)

            ---------------------
            -- UEF Initial Patrols
            ---------------------

            -- Land Fort Clarke Interior
            for i = 1, 2 do
                local units = ScenarioUtils.CreateArmyGroup('UEF', 'M4_UEF_Clarke_Def' .. i .. '_D' .. Difficulty)
                for k,v in units do
                    local platoon = ArmyBrains[UEF]:MakePlatoon('', '')
                    ArmyBrains[UEF]:AssignUnitsToPlatoon(platoon, {v}, 'Attack', 'AttackFormation')
                    ScenarioFramework.PlatoonPatrolChain(platoon, 'UEF_M4_BasePatrol' .. i .. '_Chain')
                end
            end

            -- Land Fort Clarke Front
            local units = ScenarioUtils.CreateArmyGroup('UEF', 'M4_UEF_Clarke_DefFront_D' .. Difficulty)
            for k,v in units do
                local platoon = ArmyBrains[UEF]:MakePlatoon('', '')
                ArmyBrains[UEF]:AssignUnitsToPlatoon(platoon, {v}, 'Attack', 'AttackFormation')
                platoon.PlatoonData = {}
                platoon.PlatoonData.PatrolChain = 'M4_UEF_BaseFrontPatrol_Chain'
                platoon:ForkAIThread(ScenarioPlatoonAI.RandomPatrolThread)
            end

            -- Air
            units = ScenarioUtils.CreateArmyGroup('UEF', 'M4_UEF_Clarke_DefAir_D' .. Difficulty)
            for k,v in units do
                local platoon = ArmyBrains[UEF]:MakePlatoon('', '')
                ArmyBrains[UEF]:AssignUnitsToPlatoon(platoon, {v}, 'Attack', 'AttackFormation')
                platoon.PlatoonData = {}
                platoon.PlatoonData.PatrolChain = 'M4_UEF_AirPatrol1_Chain'
                platoon:ForkAIThread(ScenarioPlatoonAI.RandomPatrolThread)
            end

            -- Scouts
            units = ScenarioUtils.CreateArmyGroup('UEF', 'M3_Starting_Air_Scouts')
            for k,v in units do
                ScenarioFramework.GroupPatrolChain({v}, 'M4_UEF_AirPatrol1_Chain')
            end

            -----------------------------
            -- UEF Spawned Misc Structures
            -----------------------------
            ScenarioUtils.CreateArmyGroup('UEF', 'Bridge_Defenses_D' .. Difficulty)
            ScenarioUtils.CreateArmyGroup('UEF', 'M3_Walls')

            -- Clarke Monument
            ScenarioInfo.ClarkeMonument = ScenarioUtils.CreateArmyUnit('UEF', 'Clarke_Monument')
            ScenarioFramework.PauseUnitDeath(ScenarioInfo.ClarkeMonument)
            ScenarioInfo.ClarkeMonument:SetCustomName(LOC '{i Coalition_HQ}')
            ScenarioInfo.ClarkeMonument:SetReclaimable(false)

            ----------------
            -- M4 Seraphim AI
            ----------------
            M4SeraphimAI.SeraphimM4NorthMainBaseAI()
            M4SeraphimAI.SeraphimM4SouthMainBaseAI()
            M4SeraphimAI.SeraphimM4AirMainBaseAI()
            M4SeraphimAI.SeraphimM4ForwardOneAI()
            M4SeraphimAI.SeraphimM4ForwardTwoAI()
            M4SeraphimAI.SeraphimM4NavalBaseAI()

            ----------------------------------
            -- Seraphim Spawned Misc Structures
            ----------------------------------
            ScenarioUtils.CreateArmyGroup('Seraphim', 'M3_West_Mass_D' .. Difficulty)
            ScenarioUtils.CreateArmyGroup('Seraphim', 'M3_East_Mass_D'.. Difficulty)
            ScenarioUtils.CreateArmyGroup('Seraphim', 'M3_Middle_Defenses_D' .. Difficulty)

            -------------------------------
            -- Seraphim Spawned Base Patrols
            -------------------------------

            -- Air Defense
            local units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M3_Patrolling_Air_Groups', 'GrowthFormation')
            for k, v in units:GetPlatoonUnits() do
                local chains = {'Seraphim_Air_Patrol_Far_Chain', 'Seraphim_Air_Patrol_Base_Chain', 'Seraph_Main_NearAirDef_Chain', 'Seraph_Main_MidAirDef_Chain'}
                local num = Random(1, 4)
                ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions(chains[num])))
            end

            -- Air Attack
            units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M4_Seraph_AirAttack_1', 'GrowthFormation')
            for k, v in units:GetPlatoonUnits() do
                ScenarioFramework.GroupPatrolChain({v}, 'Seraph_M4_SouthAttack_Chain')
            end

            -- Naval Defense
            units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M4_Naval_Patrol1_D' .. Difficulty, 'NoFormation')
            ScenarioFramework.PlatoonPatrolChain(units, 'M4_Seraph_Naval_Chain')

            -- Land Attacks
            units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M4_Seraph_LandAttack_1', 'AttackFormation')
            for k, v in units:GetPlatoonUnits() do
                ScenarioFramework.GroupPatrolChain({v}, 'Seraph_M4_SouthAttack_Chain')
            end

            units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M4_Seraph_LandAttack_2', 'AttackFormation')
            for k, v in units:GetPlatoonUnits() do
                ScenarioFramework.GroupPatrolChain({v}, 'Seraph_M4_NorthAttack_Chain')
            end

            units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M4_Seraph_LandAttack_3', 'AttackFormation')
            for k, v in units:GetPlatoonUnits() do
                ScenarioFramework.GroupPatrolChain({v}, 'Seraph_M4_SouthAttack_Chain')
            end

            -- Incarnas
            ScenarioInfo.Incarna1 = ScenarioUtils.CreateArmyUnit('Seraphim', 'M4_Incarna_1')
            local platoon = ArmyBrains[Seraphim]:MakePlatoon('', '')
            ArmyBrains[Seraphim]:AssignUnitsToPlatoon(platoon, {ScenarioInfo.Incarna1}, 'Attack', 'AttackFormation')
            ScenarioFramework.PlatoonPatrolChain(platoon, 'M4_Incarna1_Patrol_Chain')

            if(Difficulty == 3) then
                ScenarioInfo.Incarna3 = ScenarioUtils.CreateArmyUnit('Seraphim', 'M4_Incarna_3')
                local platoon = ArmyBrains[Seraphim]:MakePlatoon('', '')
                ArmyBrains[Seraphim]:AssignUnitsToPlatoon(platoon, {ScenarioInfo.Incarna3}, 'Attack', 'AttackFormation')
                ScenarioFramework.PlatoonPatrolChain(platoon, 'M4_Incarna3_Patrol_Chain')
            end

            M4CounterAttack()

            -- CDR
            ScenarioInfo.SeraphimCDR = ScenarioUtils.CreateArmyUnit('Seraphim', 'Seraphim_CDR')
            ScenarioInfo.SeraphimCDR:SetCustomName(LOC '{i ShunUllevash}')
            for i =1, 6 do
                IssuePatrol({ScenarioInfo.SeraphimCDR}, ScenarioUtils.MarkerToPosition( 'M4_Seraph_CDRPatrol_' .. i ) )
            end

            ScenarioFramework.Dialogue(VoiceOvers.KillSeraphimIntroduction)
            ForkThread(IntroMission4NIS)
        end
    )
end

function CheatEconomy(army)
    ArmyBrains[army]:GiveStorage('ENERGY', 10000)
    ArmyBrains[army]:GiveStorage('MASS', 10000)
    while(true) do
        ArmyBrains[army]:GiveResource('ENERGY', 10000)
        ArmyBrains[army]:GiveResource('MASS', 10000)
        WaitSeconds(1)
    end
end

function M4CounterAttack()
    local trigger = {}
    local num = 0
    local units = nil

    -- sends gunships if player has > [60, 40, 20] T2/T3 land units, 1 group per 10, up to 10 groups, plus 3 transport groups
    trigger = {60, 40, 20}
    num = table.getn(ScenarioFramework.GetCatUnitsInArea((categories.MOBILE * categories.LAND) - categories.TECH1, ScenarioUtils.AreaToRect('M3_North_Area'), ArmyBrains[Player]))
    if(num > trigger[Difficulty]) then
        num = math.ceil(num/10)
        if(num > 10) then
            num = 10
        end
        for i = 1, num do
            units = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Seraphim', 'M4_Seraph_Adapt_Gunships', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(units, 'M4_Seraph_AirCounter_2_Chain')
        end
        for i = 1, 3 do
            units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M4_Seraph_Adapt_Xport1', 'AttackFormation')
            for k, v in units:GetPlatoonUnits() do
                if(v:GetUnitId() == 'xsa0104') then
                    local guards = ScenarioUtils.CreateArmyGroup('Seraphim', 'M4_Seraph_Adapt_StratGuards')
                    IssueGuard(guards, v)
                    break
                end
            end
            ScenarioFramework.PlatoonAttackWithTransports(units, 'M4_Seraph_Counter_Landing_Chain', 'M4_Seraph_Counter_LandAssault_Patrol_Chain', false)
        end
    end

    -- sends air superiority if player has > [80, 60, 40] T2/T3 air units, 1 group per 15, up to 6 groups
    trigger = {80, 60, 40}
    num = table.getn(ScenarioFramework.GetCatUnitsInArea((categories.MOBILE * categories.AIR) - categories.TECH1, ScenarioUtils.AreaToRect('M3_North_Area'), ArmyBrains[Player]))
    if(num > trigger[Difficulty]) then
        num = math.ceil(num/15)
        if(num > 6) then
            num = 6
        end
        for i = 1, num do
            units = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Seraphim', 'M4_Seraph_Adapt_AirSup', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(units, 'M4_Seraph_AirCounter_2_Chain')
        end
    end

    -- sends air superiority at air experimentals, 3 groups each, up to 4 experimentals
    local exp = ScenarioFramework.GetCatUnitsInArea(categories.AIR * categories.EXPERIMENTAL, ScenarioUtils.AreaToRect('M3_North_Area'), ArmyBrains[Player])
    num = table.getn(exp)
    if(num > 0) then
        if(num > 4) then
            num = 4
        end
        for i = 1, num do
            for j = 1, 3 do
                units = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Seraphim', 'M4_Seraph_Adapt_AirSup', 'GrowthFormation', 5)
                IssueAttack(units:GetPlatoonUnits(), exp[i])
                ScenarioFramework.PlatoonPatrolChain(units, 'M4_Seraph_AirCounter_2_Chain')
            end
        end
    end

    -- sends strat bombers at land experimentals, 3 groups each, up to 4 experimentals
    exp = ScenarioFramework.GetCatUnitsInArea(categories.LAND * categories.EXPERIMENTAL, ScenarioUtils.AreaToRect('M3_North_Area'), ArmyBrains[Player])
    num = table.getn(exp)
    if(num > 0) then
        if(num > 4) then
            num = 4
        end
        for i = 1, num do
            for j = 1, Difficulty do
                units = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Seraphim', 'M4_Seraph_Adapt_StratBombers', 'GrowthFormation', 5)
                IssueAttack(units:GetPlatoonUnits(), exp[i])
                ScenarioFramework.PlatoonPatrolChain(units, 'M4_Seraph_AirCounter_2_Chain')
                local guards = ScenarioUtils.CreateArmyGroup('Seraphim', 'M4_Seraph_Adapt_StratGuards')
                IssueGuard(guards, units:GetPlatoonUnits()[1])
            end
        end
    end

    -- sends strat bombers at mavor anywhere, 3 groups each, up to 2 mavors
    for _, player in ScenarioInfo.HumanPlayers do
        local exp = ArmyBrains[player]:GetListOfUnits(categories.ueb2401, false)
        num = table.getn(exp)
        if(num > 0) then
            if(num > 2) then
                num = 2
            end
            for i = 1, num do
                for j = 1, 3 do
                    units = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Seraphim', 'M4_Seraph_Adapt_StratBombers', 'GrowthFormation', 5)
                    IssueAttack(units:GetPlatoonUnits(), exp[i])
                    ScenarioFramework.PlatoonPatrolChain(units, 'M4_Seraph_AirCounter_2_Chain')
                    local guards = ScenarioUtils.CreateArmyGroup('Seraphim', 'M4_Seraph_Adapt_StratGuards')
                    IssueGuard(guards, units:GetPlatoonUnits()[1])
                end
            end
        end
    end

    -- sends naval is player has > [14, 12, 10] T2/T3 navy
    trigger = {14, 12, 10}
    if(table.getn(ArmyBrains[Player]:GetListOfUnits((categories.NAVAL * categories.MOBILE) - categories.TECH1, false)) > trigger[Difficulty]) then
        units = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Seraphim', 'M4_Seraph_Adapt_Naval1_Destro', 'AttackFormation', 5)
        ScenarioFramework.PlatoonPatrolChain(units, 'M3_Naval_Attack1_Chain')
    end

    -- sends naval is player has > [20, 18, 16] T2/T3 navy
    trigger = {20, 18, 16}
    if(table.getn(ArmyBrains[Player]:GetListOfUnits((categories.NAVAL * categories.MOBILE) - categories.TECH1, false)) > trigger[Difficulty]) then
        units = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Seraphim', 'M4_Seraph_Adapt_Naval2_Cruiser', 'AttackFormation', 5)
        ScenarioFramework.PlatoonPatrolChain(units, 'M3_Naval_Attack1_Chain')
    end

    -- sends naval is player has > [26, 24, 22] T2/T3 navy
    trigger = {26, 24, 22}
    if(table.getn(ArmyBrains[Player]:GetListOfUnits((categories.NAVAL * categories.MOBILE) - categories.TECH1, false)) > trigger[Difficulty]) then
        units = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Seraphim', 'M4_Seraph_Adapt_Naval3_Destro', 'AttackFormation', 5)
        ScenarioFramework.PlatoonPatrolChain(units, 'M3_Naval_Attack1_Chain')
    end

    -- sends strat bombers at battleships, 2 groups each, up to 5 battleships
    for _, player in ScenarioInfo.HumanPlayers do
        local exp = ArmyBrains[player]:GetListOfUnits(categories.BATTLESHIP, false)
        num = table.getn(exp)
        if(num > 0) then
            if(num > 5) then
                num = 5
            end
            for i = 1, num do
                for j = 1, 2 do
                    units = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Seraphim', 'M4_Seraph_Adapt_StratBombers', 'GrowthFormation', 5)
                    IssueAttack(units:GetPlatoonUnits(), exp[i])
                    ScenarioFramework.PlatoonPatrolChain(units, 'M4_Seraph_AirCounter_2_Chain')
                    local guards = ScenarioUtils.CreateArmyGroup('Seraphim', 'M4_Seraph_Adapt_StratGuards')
                    IssueGuard(guards, units:GetPlatoonUnits()[1])
                end
            end
        end
    end
end

function IntroMission4NIS()
    ScenarioFramework.SetPlayableArea('M4_Playable_Area')

    WaitSeconds(1)
    Cinematics.EnterNISMode()
    Cinematics.SetInvincible( 'M3_Playable_Area' )

    -- Placeholder NIS length: 26 sec
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_4_1'), 0)
    WaitSeconds(2.5)
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_4_5'), 5)
    WaitSeconds(1)

    -- give intel on the enemy base; this is off-camera and buried in the
    -- NIS script where cameras will not show what we're doing
    ScenarioFramework.CreateVisibleAreaLocation( 130, ScenarioUtils.MarkerToPosition( 'M4_Ser_Incarna1_Patrol_2' ), 1, ArmyBrains[Player] )

    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_4_6'), 0)
    WaitSeconds(1)
    ForkThread( KillDoomedFactory )
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_4_7'), 5)
    WaitSeconds(1)

    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_4_Final'), 3)

    Cinematics.SetInvincible( 'M3_Playable_Area', true )
    Cinematics.ExitNISMode()
    StartMission4()
end

function KillDoomedFactory()
    WaitSeconds(1)
    local factory = ScenarioInfo.UnitNames[UEF]['Doomed_Factory']
    if factory and not factory:IsDead() then
        factory:AdjustHealth(factory, (factory:GetHealth() - 1) * -1)
    end
end

function StartMission4()
    -------------------------------------------
    -- Primary Objective 1 - Protect Fort Clarke
    -------------------------------------------
    ScenarioInfo.M4P1 = Objectives.Protect(
        'primary',                              -- type
        'incomplete',                           -- complete
        OpStrings.X01_M03_OBJ_010_010,          -- title
        OpStrings.X01_M03_OBJ_010_020,          -- description
        {                                       -- target
            Units = {ScenarioInfo.ClarkeMonument},
            PercentProgress = true,
            ShowFaction = 'UEF',
        }
    )
    ScenarioInfo.M4P1:AddResultCallback(
        function(result)
            if(not result and not ScenarioInfo.OpEnded) then
                ScenarioFramework.CDRDeathNISCamera(ScenarioInfo.ClarkeMonument)
                ScenarioFramework.EndOperationSafety()
                ScenarioInfo.OpComplete = false
                ForkThread( KillGame )
            end
        end
    )
    table.insert(AssignedObjectives, ScenarioInfo.M4P1)

    ScenarioFramework.Dialogue(VoiceOvers.AttackSeraphimInstruction, RevealM4P2)
    ScenarioFramework.CreateTimerTrigger(M4Subplot, 300)
    ScenarioFramework.CreateTimerTrigger(IncarnaAttack, 800)

    SetupFletcherTauntTriggers()
    SetupSeraphimTauntTriggers()
end

function RevealM4P2()
    -----------------------------------------
    -- Primary Objective 2 - Kill Seraphim ACU
    -----------------------------------------
    ScenarioInfo.M4P2 = Objectives.KillOrCapture(
        'primary',                              -- type
        'incomplete',                           -- complete
        OpStrings.X01_M03_OBJ_010_030,          -- title
        OpStrings.X01_M03_OBJ_010_040,          -- description
        {                                       -- target
            Units = {ScenarioInfo.SeraphimCDR},
            MarkUnits = true,
            FlashVisible = true,
        }
    )
    ScenarioInfo.M4P2:AddResultCallback(
        function(result)
            if(result) then
                if(not ScenarioInfo.M4P3.Active) then
                    if(ScenarioInfo.M4P1 and ScenarioInfo.M4P1.Active) then
                        ScenarioInfo.M4P1:ManualResult(true)
                    end
                    PlayerWin()
                end
            end
        end
    )
    table.insert(AssignedObjectives, ScenarioInfo.M4P2)

    ------------------------------------------
    -- Primary Objective 3 - Kill Experimentals
    ------------------------------------------
    local units = {ScenarioInfo.Incarna1}
    if(Difficulty == 3) then
        table.insert(units, ScenarioInfo.Incarna3)
    end
    ScenarioInfo.M4P3 = Objectives.KillOrCapture(
        'primary',                              -- type
        'incomplete',                           -- complete
        OpStrings.X01_M03_OBJ_010_050,          -- title
        OpStrings.X01_M03_OBJ_010_060,          -- description
        {                                       -- target
            Units = units,
            MarkUnits = true,
            FlashVisible = true,
        }
    )
    ScenarioInfo.M4P3:AddResultCallback(
        function(result)
            if(result) then
                if(not ScenarioInfo.M4P2.Active) then
                    if(ScenarioInfo.M4P1 and ScenarioInfo.M4P1.Active) then
                        ScenarioInfo.M4P1:ManualResult(true)
                    end
                    PlayerWin()
                end
            end
        end
    )
    table.insert(AssignedObjectives, ScenarioInfo.M4P3)

    -- Set up death NIS's, prompt dialogue
    ScenarioInfo.M4IncarnasDead = 0
    table.insert(units, ScenarioInfo.SeraphimCDR)
    ScenarioInfo.FinalUnits = units
    for i, v in units do
        local unit = v
        ScenarioFramework.CreateUnitDeathTrigger(
            function()
                DeathNIS(unit)
            end
        , unit)
        ScenarioFramework.CreateUnitDeathTrigger(M4IncarnasDeadDialogue, unit)
    end

    -- Seraph CDR death dialogue, reminders
    ScenarioFramework.CreateUnitDeathTrigger(M4SeraphCDRDeadDialogue, ScenarioInfo.SeraphimCDR)
    ScenarioFramework.CreateTimerTrigger(M4P2Reminder1, 900)

    -- Nuke M3 Town (if civ structures are present)
    if ScenarioFramework.NumCatUnitsInArea( categories.ALLUNITS - categories.xec8003, ScenarioUtils.AreaToRect('M4_EasternTownArea'), ArmyBrains[Civilians] ) > 0 then
        local nuke = ScenarioInfo.UnitNames[Seraphim]['M4_Seraph_StratLauncher']
        if(nuke and not nuke:IsDead()) then
            nuke:GiveNukeSiloAmmo(1)
            IssueNuke({nuke}, ScenarioUtils.MarkerToPosition('M4_Seraph_Nuke_Marker'))
            ScenarioFramework.CreateTimerTrigger(M4NukeWarning, 9)
        end
    end
end

function M4NukeWarning()
    -- UEF players whe havent completed the m3 town obj get an emphatic warning. Those who have get the general warning
    if LeaderFaction == 'uef' and ScenarioInfo.M3S1UEF.Active then
        ScenarioFramework.Dialogue(VoiceOvers.NukeWarning)
        return
    end

    ScenarioFramework.Dialogue(VoiceOvers.EmotionalNukeWarning)
end

function DeathNIS(unit)
    ForkThread(
        function()
            local num_alive = 0
            for k, unit in ScenarioInfo.FinalUnits do
                if (unit and not unit:IsDead()) then
                    num_alive = num_alive + 1
                end
            end
            if (num_alive == 0) then
                ScenarioFramework.CDRDeathNISCamera(unit)
            else
                ScenarioFramework.CDRDeathNISCamera(unit, 5)
            end
        end
    )
end

function M4Subplot()
    ScenarioFramework.Dialogue(VoiceOvers.M4Subplot)
end

function M4IncarnasDeadDialogue()
    -- play some dialogue when the 1 exp bot is killed (2, if in hard diff)
    -- ... as long as the enemy commander is still alive
    ScenarioInfo.M4IncarnasDead = ScenarioInfo.M4IncarnasDead + 1
    if (Difficulty < 3 and ScenarioInfo.M4IncarnasDead == 1) or
       (Difficulty == 3 and ScenarioInfo.M4IncarnasDead == 2) then
        ScenarioFramework.Dialogue(VoiceOvers.CollossusDestroyed, nil, ScenarioInfo.SeraphimCDR)
    end
end

function M4SeraphCDRDeadDialogue()
    -- Enemy CDR says this on death
    ScenarioFramework.Dialogue(VoiceOvers.DyingSeraphim)
end

function IncarnaAttack()
    local incarnas = {}
    if(ScenarioInfo.Incarna1 and not ScenarioInfo.Incarna1:IsDead()) then
        IssueStop({ScenarioInfo.Incarna1})
        IssueClearCommands({ScenarioInfo.Incarna1})
        table.insert(incarnas, ScenarioInfo.Incarna1)
    end

    if(Difficulty == 3) then
        if(ScenarioInfo.Incarna3 and not ScenarioInfo.Incarna3:IsDead()) then
            IssueStop({ScenarioInfo.Incarna3})
            IssueClearCommands({ScenarioInfo.Incarna3})
            table.insert(incarnas, ScenarioInfo.Incarna3)
        end
    end

    if(table.getn(incarnas) > 0) then
        local platoon = ArmyBrains[Seraphim]:MakePlatoon('', '')

        ArmyBrains[Seraphim]:AssignUnitsToPlatoon(platoon, incarnas, 'Attack', 'AttackFormation')

        ScenarioFramework.PlatoonPatrolChain(platoon, 'M4_Incarna_Attack_Chain')

        ScenarioFramework.CreateTimerTrigger(IncarnaWarning, 60)
    end
end

function IncarnaWarning()
    -- warn the player of the incoming attack
    if((ScenarioInfo.Incarna1 and not ScenarioInfo.Incarna1:IsDead()) or (ScenarioInfo.Incarna3 and not ScenarioInfo.Incarna3:IsDead())) then
        ScenarioFramework.Dialogue(OpStrings.X01_M03_290)
    end
end

---------------------
-- Objective Reminders
---------------------

-- M1
function M1P1Reminder1()
    if not ScenarioInfo.M1P1.Active then
        return
    end

    ScenarioFramework.Dialogue(VoiceOvers.FirstBaseReminder1)
    ScenarioFramework.CreateTimerTrigger(M1P1Reminder2, 2000)
end

function M1P1Reminder2()
    if not ScenarioInfo.M1P1.Active then
        return
    end

    ScenarioFramework.Dialogue(VoiceOvers.FirstBaseReminder2)
end

function M1S1Reminder1()
    if not ScenarioInfo.M1S1.Active then
        return
    end
    ScenarioFramework.Dialogue(VoiceOvers.ArtilleryReminder)
    ScenarioFramework.CreateTimerTrigger(M1S1Reminder2, 1800)
end

function M1S1Reminder2()
    if not ScenarioInfo.M1S1.Active then
        return
    end

    ScenarioFramework.Dialogue(VoiceOvers.ArtilleryReminder2)
end

-- M2
-- M3
function M3P1Reminder1()
    ScenarioFramework.Dialogue(VoiceOvers.KillOrderReminder1)
end

-- m3 uef secondary
    -- part1
function M3S1UEFReminder1()
    if ScenarioInfo.M3S1UEF.Active then
        ScenarioFramework.Dialogue(VoiceOvers.ProtectTownReminder1)
    end
end

    -- part2
function M3S2UEFReminder1()
    if ScenarioInfo.M3S2UEF.Active then
        ScenarioFramework.Dialogue(VoiceOvers.ProtectTrucksReminder1)
        ScenarioFramework.CreateTimerTrigger(M3S2UEFReminder2, 1500)
    end
end

function M3S2UEFReminder2()
    if ScenarioInfo.M3S2UEF.Active then
        ScenarioFramework.Dialogue(VoiceOvers.ProtectTrucksReminder2)
        ScenarioFramework.CreateTimerTrigger(M3S2UEFReminder3, 1500)
    end
end

function M3S2UEFReminder3()
    if ScenarioInfo.M3S2UEF.Active then
        ScenarioFramework.Dialogue(VoiceOvers.ProtectTrucksReminder3)
    end
end

-- M4
function M4P2Reminder1()
    ScenarioFramework.Dialogue(VoiceOvers.KillSeraphimReminder1)
    ScenarioFramework.CreateTimerTrigger(M4P2Reminder2, 1000)
end

function M4P2Reminder2()
    ScenarioFramework.Dialogue(VoiceOvers.KillSeraphimReminder2)
end

--------
-- Taunts
--------
 --- M1

function SetupGariM1M2TauntTriggers()
    -- not tied to gari's unit, as it is not spawned in m1, m2. So, these are tied to m1/m2 instead.
    GariM1M2TM:AddEnemiesKilledTaunt('TAUNT22', ArmyBrains[Order], categories.uec1101, 2)       -- m2 objective civ buildings
    GariM1M2TM:AddEnemiesKilledTaunt('X01_M01_060', ArmyBrains[Order], categories.uec1101, 8)
end


 --- M3
function SetupGariTauntTriggers()
    GariTM:AddTauntingCharacter(ScenarioInfo.UnitNames[Order]['Order_ACU'])

    -- On losing defensive structures
    GariTM:AddUnitsKilledTaunt('TAUNT4', ArmyBrains[Order], categories.STRUCTURE * categories.DEFENSE, 8)

    -- On losing resource structures
    if(LeaderFaction == 'uef') then
        GariTM:AddUnitsKilledTaunt('TAUNT5', ArmyBrains[Order], categories.STRUCTURE * categories.ECONOMIC, 9)
    end
    GariTM:AddUnitsKilledTaunt('TAUNT6', ArmyBrains[Order], categories.STRUCTURE * categories.ECONOMIC, 14)

    -- On destroying defensive structures
    GariTM:AddEnemiesKilledTaunt('TAUNT9', ArmyBrains[Order], categories.STRUCTURE * categories.DEFENSE, 7)
    GariTM:AddEnemiesKilledTaunt('TAUNT10', ArmyBrains[Order], categories.STRUCTURE * categories.DEFENSE, 14)

    -- On destroying resource structures
    GariTM:AddEnemiesKilledTaunt('TAUNT11', ArmyBrains[Order], categories.STRUCTURE * categories.ECONOMIC, 4)
    if(LeaderFaction == 'aeon') then
        GariTM:AddEnemiesKilledTaunt('TAUNT12', ArmyBrains[Order], categories.STRUCTURE * categories.ECONOMIC, 15)
    end

    -- On destroying experimental
    GariTM:AddUnitsKilledTaunt('TAUNT8',  ArmyBrains[Order], categories.EXPERIMENTAL, 1)
    GariTM:AddEnemiesKilledTaunt('TAUNT13', ArmyBrains[Order], categories.EXPERIMENTAL, 1)

    -- At 50% health
    GariTM:AddDamageTaunt('TAUNT25', ScenarioInfo.UnitNames[Order]['Order_ACU'], .5)

    -- Player CDR is damaged
    GariTM:AddDamageTaunt('TAUNT14', ScenarioInfo.PlayerCDR, .05)
end

function M3GariTaunt1()
    if ScenarioInfo.M3P1.Active then
        ScenarioFramework.Dialogue(VoiceOvers.AeonTaunt1, nil, nil, ScenarioInfo.UnitNames[Order]['Order_ACU'])
    end
end

function M3GariTaunt2()
    if ScenarioInfo.M3P1.Active then
        ScenarioFramework.Dialogue(VoiceOvers.AeonTaunt2, nil, nil, ScenarioInfo.UnitNames[Order]['Order_ACU'])
    end
end

 -- M4

function SetupFletcherTauntTriggers()
    ---- Faction specific Fletcher dialogue, using the taunt system
    if(LeaderFaction == 'uef') then
        FletcherTM:AddDamageTaunt('X01_M03_020', ScenarioInfo.ClarkeMonument, .01)                              -- Admin building taking damage, UEF
        FletcherTM:AddDamageTaunt('X01_M03_030', ScenarioInfo.ClarkeMonument, .40)                              -- Admin building taking damage, UEF
        FletcherTM:AddUnitKilledTaunt('X01_M03_170', ScenarioInfo.UnitNames[Seraphim]['M4_Seraphim_Factory'])   -- Fletcher enjoys a factory being destroyed, UEF
        FletcherTM:AddUnitsKilledTaunt('X01_M03_080', ArmyBrains[UEF], categories.STRUCTURE, 15)                -- Fletcher loses 11 structures, UEF
        FletcherTM:AddUnitsKilledTaunt('X01_M03_090', ArmyBrains[UEF], categories.STRUCTURE, 30)                -- Fletcher loses 11 structures, UEF
                   -- Seraph loses structures, UEF
        FletcherTM:AddUnitsKilledTaunt('X01_M03_270', ArmyBrains[Seraphim], categories.STRUCTURE, 14)           -- Seraph loses structures, UEF
        FletcherTM:AddUnitsKilledTaunt('X01_M03_280', ArmyBrains[Seraphim], categories.STRUCTURE, 28)           -- Seraph loses structures, UEF
    elseif(LeaderFaction == 'cybran') then
        FletcherTM:AddDamageTaunt('X01_M03_040', ScenarioInfo.ClarkeMonument, .95)                              -- Admin building taking damage, Cybran
        FletcherTM:AddDamageTaunt('X01_M03_050', ScenarioInfo.ClarkeMonument, .40)                              -- Admin building taking damage, Cybran
        FletcherTM:AddUnitKilledTaunt('X01_M03_180', ScenarioInfo.UnitNames[Seraphim]['M4_Seraphim_Factory'])   -- Fletcher enjoys a factory being destroyed, Cybran
        FletcherTM:AddUnitsKilledTaunt('X01_M03_100', ArmyBrains[UEF], categories.STRUCTURE, 14)                -- Fletcher loses 14 structures, Cyrban
    elseif(LeaderFaction == 'aeon') then
        FletcherTM:AddDamageTaunt('X01_M03_060', ScenarioInfo.ClarkeMonument, .95)                              -- Admin building taking damage, Aeon
        FletcherTM:AddDamageTaunt('X01_M03_070', ScenarioInfo.ClarkeMonument, .40)                              -- Admin building taking damage, Aeon
        FletcherTM:AddUnitKilledTaunt('X01_M03_190', ScenarioInfo.UnitNames[Seraphim]['M4_Seraphim_Factory'])   -- Fletcher enjoys a factory being destroyed, Aeon
        FletcherTM:AddUnitsKilledTaunt('X01_M03_100', ArmyBrains[UEF], categories.STRUCTURE, 14)                -- Fletcher loses 14 structures, Aeon
    end
    FletcherTM:AddUnitKilledTaunt('TAUNT25', ScenarioInfo.UnitNames[Seraphim]['taunt_unit_1'])                  -- "You freaks..." when a particular outer-ring building is destroyed
    FletcherTM:AddUnitsKilledTaunt('TAUNT29', ArmyBrains[Player], categories.EXPERIMENTAL, 1)                   -- Player loses exp, Sereaphim "hahaha"
    FletcherTM:AddUnitsKilledTaunt('TAUNT26', ArmyBrains[UEF], categories.STRUCTURE, 16)                        -- "...I could use a hand"
    FletcherTM:AddUnitsKilledTaunt('X01_M03_260', ArmyBrains[Seraphim], categories.STRUCTURE, 10)
end

function SetupSeraphimTauntTriggers()
    SeraphTM:AddTauntingCharacter(ScenarioInfo.SeraphimCDR)

    SeraphTM:AddUnitsKilledTaunt('TAUNT30', ArmyBrains[UEF], categories.MOBILE, 60)                           -- seraph taunt
    SeraphTM:AddUnitsKilledTaunt('TAUNT31', ArmyBrains[UEF], categories.MOBILE, 120)                           -- seraph taunt
    SeraphTM:AddUnitsKilledTaunt('TAUNT32', ArmyBrains[UEF], categories.ALLUNITS, 95)                         -- seraph taunt
    SeraphTM:AddUnitsKilledTaunt('TAUNT33', ArmyBrains[Player], categories.TECH3, 15)                         -- seraph taunt
end
