-- ****************************************************************************
-- **
-- **  File     :  /maps/X1CA_Coop_002/X1CA_Coop_002_script.lua
-- **  Author(s):  Jessica St. Croix
-- **
-- **  Summary  : Main mission flow script for X1CA_Coop_002
-- **
-- **  Copyright © 2007 Gas Powered Games, Inc.  All rights reserved.
-- ****************************************************************************
local BaseManager = import('/lua/ai/opai/basemanager.lua')
local Cinematics = import('/lua/cinematics.lua')
local EffectUtilities = import('/lua/effectutilities.lua')
local M1LoyalistAI = import('/maps/X1CA_Coop_002/X1CA_Coop_002_m1loyalistai.lua')
local M2LoyalistAI = import('/maps/X1CA_Coop_002/X1CA_Coop_002_m2loyalistai.lua')
local M1OrderAI = import('/maps/X1CA_Coop_002/X1CA_Coop_002_m1orderai.lua')
local M2OrderAI = import('/maps/X1CA_Coop_002/X1CA_Coop_002_m2orderai.lua')
local M4OrderAI = import('/maps/X1CA_Coop_002/X1CA_Coop_002_m4orderai.lua')
local M2QAIAI = import('/maps/X1CA_Coop_002/X1CA_Coop_002_m2qaiai.lua')
local M3QAIAI = import('/maps/X1CA_Coop_002/X1CA_Coop_002_m3qaiai.lua')
local M4QAIAI = import('/maps/X1CA_Coop_002/X1CA_Coop_002_m4qaiai.lua')
local Objectives = import('/lua/ScenarioFramework.lua').Objectives
local OpStrings = import('/maps/X1CA_Coop_002/X1CA_Coop_002_Strings.lua')
local PingGroups = import('/lua/ScenarioFramework.lua').PingGroups
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local TauntManager = import('/lua/TauntManager.lua')
local Utilities = import('/lua/utilities.lua')
local VizMarker = import('/lua/sim/VizMarker.lua').VizMarker
local EffectUtilities = import('/lua/EffectUtilities.lua')

local SPAIFileName = '/Lua/Scenarioplatoonai.lua'
local ScriptFile = '/maps/X1CA_Coop_002/X1CA_Coop_002_script.lua'

---------
-- Globals
---------
ScenarioInfo.Player = 1
ScenarioInfo.Order = 2
ScenarioInfo.QAI = 3
ScenarioInfo.Loyalist = 4
ScenarioInfo.OrderNeutral = 5
ScenarioInfo.Coop1 = 6
ScenarioInfo.Coop2 = 7
ScenarioInfo.Coop3 = 8

--------
-- Locals
--------
local Player = ScenarioInfo.Player
local Coop1 = ScenarioInfo.Coop1
local Coop2 = ScenarioInfo.Coop2
local Coop3 = ScenarioInfo.Coop3
local Order = ScenarioInfo.Order
local QAI = ScenarioInfo.QAI
local Loyalist = ScenarioInfo.Loyalist
local OrderNeutral = ScenarioInfo.OrderNeutral

local AssignedObjectives = {}
local Difficulty = ScenarioInfo.Options.Difficulty

ScenarioInfo.HumanPlayers = {}

----------------
-- Taunt Managers
----------------
local CeleneTM = TauntManager.CreateTauntManager('CeleneTM', '/maps/X1CA_Coop_002/X1CA_Coop_002_Strings.lua')
local QAITM = TauntManager.CreateTauntManager('QAITM', '/maps/X1CA_Coop_002/X1CA_Coop_002_Strings.lua')

local LeaderFaction
local LocalFaction

---------
-- Startup
---------
function OnPopulate()
    ScenarioUtils.InitializeScenarioArmies()
    LeaderFaction, LocalFaction = ScenarioFramework.GetLeaderAndLocalFactions()
    
    -- Army Colors
    if(LeaderFaction == 'cybran') then
        ScenarioFramework.SetCybranPlayerColor(Player)
    elseif(LeaderFaction == 'uef') then
        ScenarioFramework.SetUEFPlayerColor(Player)
    elseif(LeaderFaction == 'aeon') then
        ScenarioFramework.SetAeonPlayerColor(Player)
    end
    
    ScenarioFramework.SetAeonEvilColor(Order)
    ScenarioFramework.SetCybranEvilColor(QAI)
    ScenarioFramework.SetAeonAlly1Color(Loyalist)
    ScenarioFramework.SetAeonAlly2Color(OrderNeutral)

    -- Unit Cap
    SetArmyUnitCap(Order, 400)
    SetArmyUnitCap(QAI, 430) --630
    SetArmyUnitCap(Loyalist, 170) --370

    -- Walls
    ScenarioUtils.CreateArmyGroup('Loyalist', 'M1_Walls')

    -------------
    -- Order M1 AI
    -------------
    M1OrderAI.OrderM1MainBaseAI()
    M1OrderAI.OrderM1ResourceBaseAI()

    ScenarioInfo.M1P1Units = ScenarioFramework.GetCatUnitsInArea(categories.FACTORY + (categories.SHIELD * categories.STRUCTURE), 'M1_Order_Factories_Area', ArmyBrains[Order])
    ScenarioInfo.M1S1Units = ScenarioFramework.GetCatUnitsInArea(categories.ENERGYPRODUCTION, 'M1_NE_Base_Area', ArmyBrains[Order])

    -----------------------
    -- Order Initial Patrols
    -----------------------
    for i = 1, 2 do
        local units = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'M1_Order_MainBase_DefPatrol_' .. i .. '_D' .. Difficulty, 'AttackFormation')
        for k, v in units:GetPlatoonUnits() do
            ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M1_Order_BasePatrol_' .. i .. '_Chain')))
        end
    end

    local units = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'M1_Order_Mass_Patrol_D' .. Difficulty, 'AttackFormation')
    for k, v in units:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M1_Order_MassArea_Chain')))
    end

    ----------------------
    -- Order Initial Attack
    ----------------------

    --ScenarioInfo.M1OrderAttack = ScenarioUtils.CreateArmyGroup('Order', 'M1_Starting_Attack_Group_D' .. Difficulty)
    ScenarioInfo.M1OrderAttackPlatoons = {}
    ScenarioInfo.M1OrderAttack = {}
    
    
    for k, player in ScenarioInfo.HumanPlayers do
        local armyGroup = ScenarioUtils.CreateArmyGroup('Order', 'M1_Starting_Attack_Group_D' .. Difficulty)
        local playerPlatoons = {}
        for _, v in armyGroup do
            local platoon = ArmyBrains[Order]:MakePlatoon('', '')
            ArmyBrains[Order]:AssignUnitsToPlatoon(platoon, {v}, 'Attack', 'None')
            platoon:AggressiveMoveToLocation(ScenarioUtils.MarkerToPosition('Loyalist_M1_Pinned_Base'))
            table.insert(ScenarioInfo.M1OrderAttackPlatoons, platoon)
            table.insert(ScenarioInfo.M1OrderAttack, v)
        end

    end
    
    ----------------
    -- Loyalist M1 AI
    ----------------
    M1LoyalistAI.LoyalistM1MainBaseAI()
    ScenarioUtils.CreateArmyGroup('Loyalist', 'M1_Loy_WreckedBase', true)

    ScenarioFramework.SetPlayableArea('M1_Playable_Area', false)
end

function OnStart()
    --------------------
    -- Build Restrictions
    --------------------
    for _, player in ScenarioInfo.HumanPlayers do
        ScenarioFramework.AddRestriction(player,
            categories.xal0305 + -- Aeon Sniper Bot
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
            categories.xrl0403 + -- Cybran Amphibious Mega Bot
            categories.xeb2306 + -- UEF Heavy Point Defense
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

    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_1_1'), 0)

    ForkThread(IntroNIS)
end

----------
-- End Game
----------
function PlayerWin()
    if(not ScenarioInfo.OpEnded) then
        ScenarioInfo.OpComplete = true

        -- "Soon we'll capture this guy."
        ScenarioFramework.Dialogue(OpStrings.X02_M03_310, FinalNIS, true)
    end
end

function FinalNIS()

    ScenarioFramework.EndOperationSafety()
    Cinematics.EnterNISMode()

    local M1VizMarker = ScenarioFramework.CreateVisibleAreaLocation( 50, ScenarioUtils.MarkerToPosition( 'Vis_5_1' ), 0, ArmyBrains[Player] )

    -- Make sure that nobody fires on each other
    for _, player in ScenarioInfo.HumanPlayers do
        SetAlliance(player, QAI, 'Ally')
        SetAlliance(QAI, player, 'Ally')
    end
    SetAlliance(Loyalist, QAI, 'Ally')
    SetAlliance(QAI, Loyalist, 'Ally')

    -- Create the surrounding units
    ScenarioUtils.CreateArmyGroup( 'Loyalist', 'Final_NIS' )

    -- "Here he comes!"
    ScenarioFramework.Dialogue(OpStrings.X02_M03_320, nil, true)

    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_5_1'), 0)
    WaitSeconds(1)
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_5_2'), 5)

    -- Enemy commander appears
    local EnemyCommander = ScenarioUtils.CreateArmyUnit('QAI', 'M4_Seraph_SCU')
    EnemyCommander:SetCustomName(LOC '{i sCDR_AhnUshi}')
    EnemyCommander:SetCanTakeDamage(false)
    ScenarioFramework.FakeGateInUnit(EnemyCommander)

    WaitSeconds(2)

    -- Have it walk out of the gate
    IssueMove({ EnemyCommander }, ScenarioUtils.MarkerToPosition( 'NIS_5_Destination' ))

    WaitSeconds(1)

    EffectUtilities.AeonHackACU( EnemyCommander )

    ForkThread(
        function()
            WaitSeconds(3)
            ScenarioFramework.SetLoyalistColor( QAI )
        end
    )

    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_5_3'), 0)
    WaitSeconds(1)
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_5_4'), 7)
    WaitSeconds(1)

    -- "We got him!"
    ScenarioFramework.Dialogue(OpStrings.X02_M03_330, nil, true)

    -- "We're so awesome."
    ScenarioFramework.Dialogue(OpStrings.X02_M03_340, KillGame, true)
end

function PlayerDeath(deadCommander)
    ScenarioFramework.PlayerDeath(deadCommander, nil, AssignedObjectives)
end

function KillGame()
    ForkThread(
        function()
            UnlockInput()
            local secondaries = Objectives.IsComplete(ScenarioInfo.M2S1Aeon) and Objectives.IsComplete(ScenarioInfo.M4S1Cybran)
            ScenarioFramework.EndOperation(ScenarioInfo.OpComplete, ScenarioInfo.OpComplete, secondaries)
        end
    )
end

-----------
-- Intro NIS
-----------
function IntroNIS()

    Cinematics.EnterNISMode()

    local M1VizMarker = ScenarioFramework.CreateVisibleAreaLocation( 50, ScenarioUtils.MarkerToPosition( 'Viz_1_1' ), 0, ArmyBrains[Player] )
    ScenarioFramework.CreateVisibleAreaLocation( 100, ScenarioUtils.MarkerToPosition( 'Order_M1_Order_MainBase_Marker' ), 1, ArmyBrains[Player] )
    ScenarioFramework.CreateVisibleAreaLocation( 100, ScenarioUtils.MarkerToPosition( 'Order_M1_Resource_Base_Marker' ), 1, ArmyBrains[Player] )

    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_1_1'), 0)
    WaitSeconds(1)
    ScenarioFramework.Dialogue(OpStrings.X02_M01_010, nil, true)
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_1_2'), 5)
    WaitSeconds(1)

    M1VizMarker:Destroy()

    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_1_3'), 2)
    Cinematics.ExitNISMode()

    if(LeaderFaction == 'aeon') then
        ScenarioInfo.PlayerCDR = ScenarioUtils.CreateArmyUnit('Player', 'Aeon_ACU')
    elseif(LeaderFaction == 'uef') then
        ScenarioInfo.PlayerCDR = ScenarioUtils.CreateArmyUnit('Player', 'UEF_ACU')
    elseif(LeaderFaction == 'cybran') then
        ScenarioInfo.PlayerCDR = ScenarioUtils.CreateArmyUnit('Player', 'Cybran_ACU')
    end

    ScenarioInfo.PlayerCDR:PlayCommanderWarpInEffect()
    ScenarioFramework.PauseUnitDeath(ScenarioInfo.PlayerCDR)
    ScenarioFramework.CreateUnitDeathTrigger(PlayerDeath, ScenarioInfo.PlayerCDR)
    
    -- spawn coop players too
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
            ScenarioInfo.CoopCDR[coop]:PlayCommanderWarpInEffect()
            coop = coop + 1
            WaitSeconds(0.5)
        end
    end

    for index, coopACU in ScenarioInfo.CoopCDR do
        ScenarioFramework.PauseUnitDeath(coopACU)
        ScenarioFramework.CreateUnitDeathTrigger(PlayerDeath, coopACU)
    end

    IntroMission1()
end

-----------
-- Mission 1
-----------
function IntroMission1()
    ScenarioInfo.MissionNumber = 1

    for k, v in ScenarioInfo.M1OrderAttackPlatoons do
        if(ArmyBrains[Order]:PlatoonExists(v)) then
            local r = Random(1, table.getn(ScenarioInfo.HumanPlayers))
            if (r==1) then
                v:AttackTarget(ScenarioInfo.PlayerCDR)
            else
                v:AttackTarget(ScenarioInfo.CoopCDR[r-1])
            end
        end
    end

    if(LeaderFaction == 'uef') then
        ScenarioFramework.Dialogue(OpStrings.X02_M01_020)
    elseif(LeaderFaction == 'cybran') then
        ScenarioFramework.Dialogue(OpStrings.X02_M01_025)
    elseif(LeaderFaction == 'aeon') then
        ScenarioFramework.Dialogue(OpStrings.X02_M01_030)
    end

    ScenarioFramework.Dialogue(OpStrings.X02_M01_040)
    StartMission1()
end

function StartMission1()
    -----------------------------------------------
    -- Primary Objective 1 - Defeat the Order Attack
    -----------------------------------------------
    ScenarioInfo.M1P1 = Objectives.KillOrCapture(
        'primary',                      -- type
        'incomplete',                   -- complete
        OpStrings.X02_M01_OBJ_010_010,  -- title
        OpStrings.X02_M01_OBJ_010_020,  -- description
        {                               -- target
            MarkUnits = true,
            Units = ScenarioInfo.M1OrderAttack,
        }
    )
    ScenarioInfo.M1P1:AddResultCallback(
        function(result)
            if(result) then
                M1LoyalistAI.M1P1Response()
                ScenarioFramework.Dialogue(OpStrings.X02_M01_130)
                local num = 0
                for k, v in ScenarioInfo.M1P1Units do
                    if(v and not v:IsDead()) then
                        num = num + 1
                    end
                end
                if(LeaderFaction == 'aeon') then
                    if(num > 0) then
                        ScenarioFramework.Dialogue(OpStrings.X02_M01_046, M1OrderAttackDefeated)
                    else
                        IntroMission2()
                    end
                else
                    if(num > 0) then
                        ScenarioFramework.Dialogue(OpStrings.X02_M01_047, M1OrderAttackDefeated)
                    else
                        IntroMission2()
                    end
                end
            end
        end
    )
    table.insert(AssignedObjectives, ScenarioInfo.M1P1)
    ScenarioFramework.CreateTimerTrigger(M1P1Reminder1, 300)
    ScenarioFramework.CreateTimerTrigger(M1Subplot, 180)

    -- Light gunship
    ScenarioFramework.UnrestrictWithVoiceoverAndDelay(categories.xra0105, "cybran", 105, OpStrings.X02_M01_190)

    -- Sniper bot
    ScenarioFramework.UnrestrictWithVoiceoverAndDelay(categories.xal0305, "aeon", 240, OpStrings.X02_M01_045)
    
    SetupCeleneM1Taunt()
end

function M1OrderAttackDefeated()
    ---------------------------------------------
    -- Primary Objective 2 - Defeat the Order Base
    ---------------------------------------------
    ScenarioInfo.M1P2 = Objectives.KillOrCapture(
        'primary',                      -- type
        'incomplete',                   -- complete
        OpStrings.X02_M01_OBJ_010_030,  -- title
        OpStrings.X02_M01_OBJ_010_040,  -- description
        {                               -- target
            Units = ScenarioInfo.M1P1Units,
        }
    )
    ScenarioInfo.M1P2:AddResultCallback(
        function(result)
            if(result) then
                ScenarioFramework.Dialogue(OpStrings.X02_M01_180, IntroMission2)
            end
        end
    )
    table.insert(AssignedObjectives, ScenarioInfo.M1P2)

    ScenarioFramework.CreateTimerTrigger(M1RevealSecondary, 60)
    ScenarioFramework.UnrestrictWithVoiceoverAndDelay(categories.xra0105, "cybran", 105, OpStrings.X02_M01_190)
    ScenarioFramework.CreateTimerTrigger(M1P2Reminder1, 2700)
end

function M1Subplot()
    if(LeaderFaction == 'uef') then
        ScenarioFramework.Dialogue(OpStrings.X02_M01_090)
    elseif(LeaderFaction == 'cybran') then
        ScenarioFramework.Dialogue(OpStrings.X02_M01_100)
    end
end

function M1RevealSecondary()
    ScenarioFramework.Dialogue(OpStrings.X02_M01_150, M1AssignSecondary)
end

function M1AssignSecondary()
    -----------------------------------------------
    -- Secondary Objective 1 - Destroy Resource Base
    -----------------------------------------------
    ScenarioInfo.M1S1 = Objectives.KillOrCapture(
        'secondary',                    -- type
        'incomplete',                   -- complete
        OpStrings.X02_M01_OBJ_020_010,  -- title
        OpStrings.X02_M01_OBJ_020_015,  -- description
        {                               -- target
            Units = ScenarioInfo.M1S1Units,
        }
    )
    ScenarioInfo.M1S1:AddResultCallback(
        function(result)
            if(result) then
                if(ScenarioInfo.M1P2.Active) then
                    ScenarioFramework.Dialogue(OpStrings.X02_M01_152)
                    ScenarioFramework.Dialogue(OpStrings.TAUNT5)
                    M1OrderAI.M1S1Response()
                end
            end
        end
    )
    table.insert(AssignedObjectives, ScenarioInfo.M1S1)
    ScenarioFramework.Dialogue(OpStrings.X02_M01_151)
    ScenarioFramework.CreateTimerTrigger(M1S1Reminder1, 1200)
end

-----------
-- Mission 2
-----------
function IntroMission2()
    ForkThread(
        function()
            if(ScenarioInfo.M1S1.Active) then
                ScenarioInfo.M1S1:ManualResult(false)
            end

            ScenarioFramework.FlushDialogueQueue()
            while(ScenarioInfo.DialogueLock) do
                WaitSeconds(0.2)
            end

            ScenarioInfo.MissionNumber = 2
            local units = nil

            -------------
            -- M2 Order AI
            -------------
            M2OrderAI.OrderM2NorthBaseAI()

            -----------------------
            -- Order Initial Patrols
            -----------------------

            -- Land Patrol
            units = ScenarioUtils.CreateArmyGroup('Order', 'M2_North_DefPatrol_1_D' .. Difficulty)
            for k,v in units do
                local platoon = ArmyBrains[Order]:MakePlatoon('','')
                ArmyBrains[Order]:AssignUnitsToPlatoon(platoon, {v}, 'Attack', 'None')
                ScenarioFramework.PlatoonPatrolChain(platoon, 'M2_Order_LandDef1_Chain')
            end

            -- Air Patrol
            units = ScenarioUtils.CreateArmyGroup('Order', 'M2_North_DefAir_1_D' .. Difficulty)
            for k,v in units do
                local platoon = ArmyBrains[Order]:MakePlatoon('','')
                ArmyBrains[Order]:AssignUnitsToPlatoon(platoon, {v}, 'Attack', 'None')
                platoon.PlatoonData = {}
                platoon.PlatoonData.PatrolChain = 'M2_Order_AirDef1_Chain'
                platoon:ForkAIThread(ScenarioPlatoonAI.RandomPatrolThread)
            end

            -----------------------
            -- Order Static Defenses
            -----------------------
            ScenarioUtils.CreateArmyGroup('Order', 'M2_Canyon_Defense_D' .. Difficulty)
            ScenarioUtils.CreateArmyGroup('Order', 'M2_Prison_Defenses_D' .. Difficulty)

            ----------------------
            -- Order Initial Attack
            ----------------------
            local routes = {'M2_InitialAttack_Land_A_Chain', 'M2_InitialAttack_Land_B_Chain', 'M2_Combined_LandAttack3_Chain'}
            units = ScenarioUtils.CreateArmyGroup('Order', 'M2_Order_InitialAttack_Land_A_D' .. Difficulty)
            for k,v in units do
                local platoon = ArmyBrains[Order]:MakePlatoon('','')
                ArmyBrains[Order]:AssignUnitsToPlatoon(platoon, {v}, 'Attack', 'None')
                ScenarioFramework.PlatoonPatrolChain(platoon, routes[Random(1, 3)])
            end

            units = ScenarioUtils.CreateArmyGroup('Order', 'M2_Order_InitialAttack_Land_B_D' .. Difficulty)
            for k,v in units do
                local platoon = ArmyBrains[Order]:MakePlatoon('','')
                ArmyBrains[Order]:AssignUnitsToPlatoon(platoon, {v}, 'Attack', 'None')
                ScenarioFramework.PlatoonPatrolChain(platoon, routes[Random(1, 3)])
            end

            units = ScenarioUtils.CreateArmyGroup('Order', 'M2_Order_InitialAttack_Land_C_D' .. Difficulty)
            for k,v in units do
                local platoon = ArmyBrains[Order]:MakePlatoon('','')
                ArmyBrains[Order]:AssignUnitsToPlatoon(platoon, {v}, 'Attack', 'None')
                ScenarioFramework.PlatoonPatrolChain(platoon, routes[Random(1, 3)])
            end

            -----------
            -- M2 QAI AI
            -----------
            M2QAIAI.QAIM2SouthBaseAI()

            ---------------------
            -- QAI Initial Patrols
            ---------------------

            -- Land Patrol 1
            units = ScenarioUtils.CreateArmyGroup('QAI', 'M2_Base_LandDef_1_D' .. Difficulty)
            for k,v in units do
                local platoon = ArmyBrains[QAI]:MakePlatoon('','')
                ArmyBrains[QAI]:AssignUnitsToPlatoon(platoon, {v}, 'Attack', 'None')
                platoon.PlatoonData = {}
                platoon.PlatoonData.PatrolChain = 'M2_QAI_LandDef1_Chain'
                platoon:ForkAIThread(ScenarioPlatoonAI.RandomPatrolThread)
            end

            -- Land Patrol 2
            units = ScenarioUtils.CreateArmyGroup('QAI', 'M2_Base_LandDef_2_D' .. Difficulty)
            for k,v in units do
                local platoon = ArmyBrains[QAI]:MakePlatoon('','')
                ArmyBrains[QAI]:AssignUnitsToPlatoon(platoon, {v}, 'Attack', 'None')
                ScenarioFramework.PlatoonPatrolChain(platoon, 'M2_QAI_LandDef2_Chain')
            end

            -- Air Patrol
            units = ScenarioUtils.CreateArmyGroup('QAI', 'M2_Base_AirDef_1_D' .. Difficulty)
            for k,v in units do
                local platoon = ArmyBrains[QAI]:MakePlatoon('','')
                ArmyBrains[QAI]:AssignUnitsToPlatoon(platoon, {v}, 'Attack', 'None')
                platoon.PlatoonData = {}
                platoon.PlatoonData.PatrolChain = 'M2_QAI_AirDef1_Chain'
                platoon:ForkAIThread(ScenarioPlatoonAI.RandomPatrolThread)
            end

            ---------------------
            -- QAI Static Defenses
            ---------------------
            ScenarioUtils.CreateArmyGroup('QAI', 'M2_QAI_OuterDef_D' .. Difficulty)

            --------------------
            -- QAI Initial Attack
            --------------------
            units = ScenarioUtils.CreateArmyGroup('QAI', 'M2_QAI_InitialAttack_Land_A_D' .. Difficulty)
            for k,v in units do
                local platoon = ArmyBrains[QAI]:MakePlatoon('','')
                ArmyBrains[QAI]:AssignUnitsToPlatoon(platoon, {v}, 'Attack', 'None')
                ScenarioFramework.PlatoonPatrolChain(platoon, routes[Random(1, 3)])
            end

            units = ScenarioUtils.CreateArmyGroup('QAI', 'M2_QAI_InitialAttack_Land_B_D' .. Difficulty)
            for k,v in units do
                local platoon = ArmyBrains[QAI]:MakePlatoon('','')
                ArmyBrains[QAI]:AssignUnitsToPlatoon(platoon, {v}, 'Attack', 'None')
                ScenarioFramework.PlatoonPatrolChain(platoon, routes[Random(1, 3)])
            end

            units = ScenarioUtils.CreateArmyGroup('QAI', 'M2_QAI_InitialAttack_Land_C_D' .. Difficulty)
            for k,v in units do
                local platoon = ArmyBrains[QAI]:MakePlatoon('','')
                ArmyBrains[QAI]:AssignUnitsToPlatoon(platoon, {v}, 'Attack', 'None')
                ScenarioFramework.PlatoonPatrolChain(platoon, routes[Random(1, 3)])
            end

            ----------------
            -- M2 Loyalist AI
            ----------------
            M2LoyalistAI.LoyalistM2EastBaseAI()
            M2LoyalistAI.LoyalistM2WestBaseAI()

            -------------------------
            -- Loyalist Resource Bases
            -------------------------
            ScenarioUtils.CreateArmyGroup('Loyalist', 'M2_Loyalist_Base_Resource')
            ScenarioUtils.CreateArmyGroup('Loyalist', 'M2_Loyalist_Base_Resource2')

            ----------------------
            -- Objective Structures
            ----------------------

            -- Prison
            ScenarioInfo.Prison = ScenarioUtils.CreateArmyUnit('Order', 'M2_Prison')
            ScenarioInfo.Prison:SetCanBeKilled(false)
            ScenarioInfo.Prison:SetCanTakeDamage(false)
            ScenarioInfo.Prison:SetReclaimable(false)
            ScenarioInfo.Prison:SetDoNotTarget(true)
            ScenarioInfo.Prison:SetCustomName(LOC '{i Loyalist_Prison_Building}')

            -- Order Official
            if(LeaderFaction == 'aeon') then
                ScenarioInfo.OrderFacilities = ScenarioUtils.CreateArmyGroup('OrderNeutral', 'M2_Secondary_Facility')
                for k, v in ScenarioInfo.OrderFacilities do
                    if(v and not v:IsDead()) then
                        v:SetDoNotTarget(true)
                        v:SetCanTakeDamage(false)
                        v:SetCanBeKilled(false)
                        v:SetReclaimable(false)
                        v:SetCapturable(false)
                    end
                end
                ScenarioInfo.OrderDefenses = ScenarioUtils.CreateArmyGroup('QAI', 'M2_Island_Secondary_D' .. Difficulty)
            end

            ForkThread(IntroMission2NIS)
        end
    )
end

function IntroMission2NIS()
    ScenarioFramework.SetPlayableArea('M2_Playable_Area', false)

    Cinematics.EnterNISMode()
    Cinematics.SetInvincible('M1_Playable_Area')

    local fakeMarker1 = {
        ['zoom'] = FLOAT(35),
        ['canSetCamera'] = BOOLEAN(true),
        ['canSyncCamera'] = BOOLEAN(true),
        ['color'] = STRING('ff808000'),
        ['editorIcon'] = STRING('/textures/editor/marker_mass.bmp'),
        ['type'] = STRING('Camera Info'),
        ['prop'] = STRING('/env/common/props/markers/M_Camera_prop.bp'),
        ['orientation'] = VECTOR3(-3.14159, 1.19772, 0),
        ['position'] = ScenarioInfo.PlayerCDR:GetPosition(),
    }
    Cinematics.CameraMoveToMarker(fakeMarker1, 0)

    WaitSeconds(1)

    -- Show the prison
    ScenarioFramework.CreateVisibleAreaLocation(4, ScenarioInfo.Prison:GetPosition(), 10, ArmyBrains[Player])
    ScenarioFramework.CreateVisibleAreaLocation(60, ScenarioUtils.MarkerToPosition('M2_QAI_Base_Marker'), 10, ArmyBrains[Player])
    -- ScenarioFramework.CreateVisibleAreaLocation( 60, ScenarioUtils.MarkerToPosition( 'Order_M2_North_Base_Marker' ), 10, ArmyBrains[Player] )
    ScenarioFramework.CreateVisibleAreaLocation(350, ScenarioInfo.Prison:GetPosition(), 1, ArmyBrains[Player])

    WaitSeconds(1)
    ScenarioFramework.Dialogue(OpStrings.X02_M02_010, nil, true)
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_2_1'), 3)
    WaitSeconds(1)

    ScenarioFramework.Dialogue(OpStrings.X02_M02_011, nil, true)
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_2_2'), 3)
    WaitSeconds(1)
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_2_3'), 4)
    WaitSeconds(1)

    ScenarioFramework.Dialogue(OpStrings.X02_M02_012, nil, true)
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_2_4'), 4)
    WaitSeconds(1)

    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_2_5'), 4)
    -- WaitSeconds(1)

    ScenarioFramework.Dialogue(OpStrings.X02_M02_013, nil, true)
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_2_6'), 5)
    WaitSeconds(1)

    ScenarioFramework.Dialogue(OpStrings.X02_M02_014, nil, true)
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_2_7'), 3)

    Cinematics.SetInvincible('M1_Playable_Area', true)
    Cinematics.ExitNISMode()

    StartMission2()
end

function StartMission2()
    --------------------------------------
    -- Primary Objective 1 - Capture Prison
    --------------------------------------
    ScenarioInfo.M2P1 = Objectives.Capture(
        'primary',                      -- type
        'incomplete',                   -- status
        OpStrings.X02_M02_OBJ_010_010,  -- title
        OpStrings.X02_M02_OBJ_010_020,  -- description
        {
            FlashVisible = true,
            NumRequired = 1,
            Units = {ScenarioInfo.Prison},
        }
    )
    ScenarioInfo.M2P1:AddResultCallback(
        function(result)
            if(result) then
                ScenarioFramework.Dialogue(OpStrings.X02_M02_040)
                ScenarioFramework.Dialogue(OpStrings.TAUNT26)
                ScenarioFramework.Dialogue(OpStrings.TAUNT6, IntroMission3)
            end
        end
    )
    table.insert(AssignedObjectives, ScenarioInfo.M2P1)
    ScenarioFramework.CreateTimerTrigger(M2P1Reminder1, 900)

    if(LeaderFaction == 'aeon') then
        ScenarioFramework.CreateTimerTrigger(M2RevealAeonSecondary, 60)
    end
    if(LeaderFaction == 'cybran') then
        ScenarioFramework.CreateTimerTrigger(M2Subplot, 180)
    end
    ScenarioFramework.CreateTimerTrigger(M2NavalAttack, 300)
    ScenarioFramework.CreateTimerTrigger(M2PingEventNotification, 600)
    SetupCeleneM2Taunt()
    SetupQAIM2Taunt()
    
    -- Heavy point defense
    ScenarioFramework.UnrestrictWithVoiceoverAndDelay(categories.xeb2306, "uef", 60, OpStrings.X02_M01_210)
    ScenarioFramework.UnrestrictWithVoiceoverAndDelay(categories.xrl0302, "cybran", 90, OpStrings.X02_M01_200)
end

function M2RevealAeonSecondary()
    ScenarioFramework.Dialogue(OpStrings.X02_M02_120, M2AssignAeonSecondary)
end

function M2AssignAeonSecondary()
    local target = {}
    for k, v in ScenarioInfo.OrderDefenses do
         if(v and not v:IsDead() and EntityCategoryContains(categories.STRUCTURE - categories.WALL, v)) then
            table.insert(target, v)
         end
    end

    ------------------------------------------------------
    -- Secondary Objective 1 - Aeon - Rescue Order Diplomat
    ------------------------------------------------------
    ScenarioInfo.M2S1Aeon = Objectives.KillOrCapture(
        'secondary',                    -- type
        'incomplete',                   -- complete
        OpStrings.X02_M02_OBJ_020_010,  -- title
        OpStrings.X02_M02_OBJ_020_020,  -- description
        {                               -- target
            FlashVisible = true,
            MarkUnits = true,
            Units = target,
        }
    )
    ScenarioInfo.M2S1Aeon:AddResultCallback(
        function(result)
            if(result) then
                ScenarioFramework.Dialogue(OpStrings.X02_M02_150)
                if(ScenarioInfo.OrderFacilities) then
                    for k, v in ScenarioInfo.OrderFacilities do
                        if(v and not v:IsDead()) then
                            ScenarioFramework.GiveUnitToArmy(v, Loyalist)
                        end
                    end
                end
            end
        end
    )
    table.insert(AssignedObjectives, ScenarioInfo.M2S1Aeon)
    ScenarioFramework.CreateTimerTrigger(M2S1AeonReminder1, 1200)
end

function M2Subplot()
    ScenarioFramework.Dialogue(OpStrings.X02_M02_110)
end

function M2NavalAttack()
    if(ScenarioInfo.MissionNumber == 2) then
        local units = ScenarioUtils.CreateArmyGroup('QAI', 'QAI_M2_Naval_1_D' .. Difficulty)
        for k,v in units do
            local platoon = ArmyBrains[QAI]:MakePlatoon('','')
            ArmyBrains[QAI]:AssignUnitsToPlatoon(platoon, {v}, 'Attack', 'None')
            ScenarioFramework.PlatoonPatrolChain(platoon, 'M2_QAI_Naval_Chain')
        end
    end
end

function M2PingEventNotification()
    if(ScenarioInfo.MissionNumber == 2) then
        ScenarioFramework.Dialogue(OpStrings.X02_M02_050, M2PingEvent)
    end
end

function M2PingEvent()
    ScenarioInfo.M2AttackPing = PingGroups.AddPingGroup(OpStrings.X02_M01_OBJ_010_050, nil, 'attack', OpStrings.X02_M01_OBJ_010_055)
    ScenarioInfo.M2AttackPing:AddCallback(M2DestroyRadius)
    ScenarioFramework.CreateTimerTrigger(M2PingReminder, 800)
end

function M2DestroyRadius(location)
    ScenarioInfo.M2PingUsed = true
    local radius = 10

    ScenarioFramework.CreateVisibleAreaLocation(radius, location, 7, ArmyBrains[Player])

    local orderEnemies = ArmyBrains[Order]:GetUnitsAroundPoint(categories.ALLUNITS, location, radius)
    local qaiEnemies = ArmyBrains[QAI]:GetUnitsAroundPoint(categories.ALLUNITS, location, radius)

    if(orderEnemies) then
        for k,v in orderEnemies do
            v:Kill()
        end
    end

    if(qaiEnemies) then
        for k,v in qaiEnemies do
            v:Kill()
        end
    end

    ScenarioInfo.M2AttackPing:Destroy()
end

function M2PingReminder()
    if(ScenarioInfo.M2AttackPing) and (not ScenarioInfo.MissionNumber == 4) then
        ScenarioFramework.Dialogue(OpStrings.X02_M02_051)
    end
end

-----------
-- Mission 3
-----------
function IntroMission3()
    ScenarioInfo.MissionNumber = 3

    -----------
    -- M3 QAI AI
    -----------
    M3QAIAI.QAIM3NavalBaseAI()

    ScenarioInfo.ColossusAttack = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'M2_CounterAttack_Colossus_2', 'None')
    ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.ColossusAttack, 'M3_Land_Attack_Full3_Chain')

    local count = 3
    if(Difficulty == 3) then
        count = 4
    end
    for i = 1, count do
        local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'M3_CounterSpider_' .. i, 'AttackFormation')
        ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_Land_Attack_Full2_Chain')
    end

    -- These are the nukes for mission 4.
    -- We create them early so that their (very long) opening animations are done by the time we look at them.
    ScenarioInfo.M4OrderSouthNuke = ScenarioUtils.CreateArmyUnit('Order', 'M4_Order_Silo_South')
    ScenarioInfo.M4OrderCenterNuke = ScenarioUtils.CreateArmyUnit('Order', 'M4_Order_Silo_Mid')
    ScenarioInfo.M4OrderNorthNuke = ScenarioUtils.CreateArmyUnit('Order', 'M4_Order_Silo_North')

    ForkThread(IntroMission3NIS)
end

function IntroMission3NIS()
    -- Currently cut

    Cinematics.EnterNISMode()
    
    WaitSeconds(1)
    
    ScenarioFramework.Dialogue(OpStrings.X02_M02_160, nil, true)
    
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('M3_NIS_Cam_1'), 0)
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('M3_NIS_Cam_2'), 3)
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('M3_NIS_Cam_3'), 1)
    
    Cinematics.ExitNISMode()

    StartMission3()
end

function StartMission3()
    ---------------------------------------------
    -- Primary Objective 1 - Survive Counterattack
    ---------------------------------------------
    ScenarioInfo.M3P1 = Objectives.Basic(
        'primary',                          -- type
        'incomplete',                       -- complete
        OpStrings.X02_M02_OBJ_010_030,      -- title
        OpStrings.X02_M02_OBJ_010_040,      -- description
        Objectives.GetActionIcon('kill'),
        {                                   -- target
        }
    )
    table.insert(AssignedObjectives, ScenarioInfo.M3P1)

    ScenarioFramework.CreateTimerTrigger(M3PrincessReveal, 60)

    --In case any dialogue is queueing up, turn off Celene's taunt manager early, ahead of the flip.
    CeleneTM:Activate(false)
end

function M3PrincessReveal()
    ScenarioFramework.Dialogue(OpStrings.X02_M02_170)
    ScenarioFramework.Dialogue(OpStrings.X02_M02_171)
    ScenarioFramework.Dialogue(OpStrings.X02_M02_172)
    ScenarioFramework.Dialogue(OpStrings.X02_M02_173)
    ScenarioFramework.Dialogue(OpStrings.X02_M02_174)
    ScenarioFramework.Dialogue(OpStrings.X02_M02_175)
    ScenarioFramework.Dialogue(OpStrings.X02_M02_176, EndMission3)
end

function EndMission3()
    for _, player in ScenarioInfo.HumanPlayers do
        SetAlliance(player, Order, 'Ally')
    end
    SetAlliance(Loyalist, Order, 'Ally')
    SetAlliance(QAI, Order, 'Enemy')
    ScenarioInfo.OrderAlly = true

    if(ScenarioInfo.ColossusAttack and ArmyBrains[Order]:PlatoonExists(ScenarioInfo.ColossusAttack)) then
        ScenarioInfo.ColossusAttack:Stop()
        for k,v in ScenarioInfo.ColossusAttack:GetPlatoonUnits() do
            if(not v:IsDead()) then
                local platoon = ArmyBrains[Order]:MakePlatoon('','')
                ArmyBrains[Order]:AssignUnitsToPlatoon(platoon, {v}, 'Attack', 'None')
                platoon:ForkAIThread(platoon.HuntAI)
            end
        end
    end

    local count = 0
    while(count < 60) do
        if(table.getn(ArmyBrains[Order]:GetListOfUnits(categories.ual0401, false)) > 1 and table.getn(ArmyBrains[QAI]:GetListOfUnits(categories.url0402, false)) > 1) then
            WaitSeconds(1)
            count = count + 1
        else
            count = 60
        end
    end
    IntroMission4()
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

            -- If we used debug commands to get here already, don't run this function again
            if ScenarioInfo.MissionNumber == 4 then
                return
            end

            ScenarioInfo.MissionNumber = 4
            local units = nil

            if(ScenarioInfo.M2AttackPing) then
                ScenarioInfo.M2AttackPing:Destroy()
            end

            if(ScenarioInfo.M3P1.Active) then
                ScenarioInfo.M3P1:ManualResult(true)
            end

            SetArmyUnitCap(Order, 600)
            SetArmyUnitCap(QAI, 830)

            -------------
            -- M4 Order AI
            -------------
            M4OrderAI.OrderM4MainBaseAI()
            M4OrderAI.OrderM4NorthBaseAI()
            M4OrderAI.OrderM4CenterBaseAI()
            M4OrderAI.OrderM4SouthBaseAI()

            -----------------------
            -- Order Initial Patrols
            -----------------------
            units = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'M4_Order_Defense_Air_D' .. Difficulty, 'NoFormation')
            for k, v in units:GetPlatoonUnits() do
                ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M4_Order_Air_Defense_Chain')))
            end

            units = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'M4_Order_Defense_Land_D' .. Difficulty, 'NoFormation')
            for k, v in units:GetPlatoonUnits() do
                ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M4_Order_Main_Land_Defense_Chain')))
            end

            -----------------------
            -- Order Initial Attacks
            -----------------------
            units = ScenarioUtils.CreateArmyGroup('Order', 'M4_Order_NukeNorth_Starter')
            for k, v in units do
                platoon = ArmyBrains[Order]:MakePlatoon('','')
                ArmyBrains[Order]:AssignUnitsToPlatoon(platoon, {v}, 'Attack', 'None')
                platoon.PlatoonData = {}
                platoon.PlatoonData.Location = 'QAI_M4_North_Base'
                platoon:ForkAIThread(ScenarioPlatoonAI.PlatoonAttackLocation)
            end

            units = ScenarioUtils.CreateArmyGroup('Order', 'M4_Order_NukeMid_Starter')
            for k,v in units do
                platoon = ArmyBrains[Order]:MakePlatoon('','')
                ArmyBrains[Order]:AssignUnitsToPlatoon(platoon, {v}, 'Attack', 'None')
                platoon.PlatoonData = {}
                platoon.PlatoonData.Location = 'QAI_M4_Middle_Base'
                platoon:ForkAIThread(ScenarioPlatoonAI.PlatoonAttackLocation)
            end

            units = ScenarioUtils.CreateArmyGroup('Order', 'M4_Order_NukeSouth_Starter')
            for k,v in units do
                platoon = ArmyBrains[Order]:MakePlatoon('','')
                ArmyBrains[Order]:AssignUnitsToPlatoon(platoon, {v}, 'Attack', 'None')
                platoon.PlatoonData = {}
                platoon.PlatoonData.Location = 'QAI_M3_South_Base'
                platoon:ForkAIThread(ScenarioPlatoonAI.PlatoonAttackLocation)
            end

            -------------
            -- Order Nukes
            -------------
            ScenarioInfo.M4OrderNorthNuke:GiveNukeSiloAmmo(1)
            ScenarioInfo.M4OrderCenterNuke:GiveNukeSiloAmmo(1)
            ScenarioInfo.M4OrderSouthNuke:GiveNukeSiloAmmo(1)

            -----------
            -- M4 QAI AI
            -----------
            M4QAIAI.QAIM4MainBaseAI()
            M4QAIAI.QAIM4NavalBaseAI()
            M4QAIAI.QAIM4NorthBaseAI()
            M4QAIAI.QAIM4CenterBaseAI()
            M4QAIAI.QAIM4SouthBaseAI()

            ---------------------
            -- QAI Initial Patrols
            ---------------------
            units = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'M4_Main_Patrol_NW_D' .. Difficulty, 'NoFormation')
            for k, v in units:GetPlatoonUnits() do
                ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M4_Main_Base_NW_Def_Chain')))
            end

            units = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'M4_Main_Patrol_SW_D' .. Difficulty, 'NoFormation')
            for k, v in units:GetPlatoonUnits() do
                ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M4_Main_Base_SW_Def_Chain')))
            end

            units = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'M4_Main_Patrol_East_D' .. Difficulty, 'NoFormation')
            for k, v in units:GetPlatoonUnits() do
                ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M4_Main_Base_East_Def_Chain')))
            end

            units = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'M4_Main_Patrol_Air_D' .. Difficulty, 'NoFormation')
            for k, v in units:GetPlatoonUnits() do
                ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M4_Main_Base_Air_Def_Chain')))
            end

            units = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'M4_Experimentals', 'NoFormation')
            for k, v in units:GetPlatoonUnits() do
                ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M4_Main_Base_East_Def_Chain')))
            end

            for i = 1, 2 do
                units = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'M4_Naval_Patrol' .. i .. '_D' .. Difficulty, 'AttackFormation')
                for k, v in units:GetPlatoonUnits() do
                    ScenarioFramework.GroupPatrolChain({v}, 'M4_Naval_Base_Defense_Chain')
                end
            end

            units = ScenarioUtils.CreateArmyGroup('QAI', 'M4_QAI_NukeNorth_Starter')
            for k, v in units do
                platoon = ArmyBrains[Order]:MakePlatoon('','')
                ArmyBrains[Order]:AssignUnitsToPlatoon(platoon, {v}, 'Attack', 'None')
                platoon.PlatoonData = {}
                platoon.PlatoonData.Location = 'Order_M4_North_Base'
                platoon:ForkAIThread(ScenarioPlatoonAI.PlatoonAttackLocation)
            end

            units = ScenarioUtils.CreateArmyGroup('QAI', 'M4_QAI_NukeMid_Starter')
            for k, v in units do
                platoon = ArmyBrains[Order]:MakePlatoon('','')
                ArmyBrains[Order]:AssignUnitsToPlatoon(platoon, {v}, 'Attack', 'None')
                platoon.PlatoonData = {}
                platoon.PlatoonData.Location = 'Order_M4_Middle_Base'
                platoon:ForkAIThread(ScenarioPlatoonAI.PlatoonAttackLocation)
            end

            units = ScenarioUtils.CreateArmyGroup('QAI', 'M4_QAI_NukeSouth_Starter')
            for k, v in units do
                platoon = ArmyBrains[Order]:MakePlatoon('','')
                ArmyBrains[Order]:AssignUnitsToPlatoon(platoon, {v}, 'Attack', 'None')
                platoon.PlatoonData = {}
                platoon.PlatoonData.Location = 'Order_M4_South_Base'
                platoon:ForkAIThread(ScenarioPlatoonAI.PlatoonAttackLocation)
            end

            -------------------------
            -- QAI Attacks In Progress
            -------------------------

            -- air: 1 via overland route, 2 via normal air attack routes
            local units = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'M4_QAI_InitAir_3_D' .. Difficulty, 'GrowthFormation')   -- air: 1 via overland route, 2 via normal air attack routes
            ScenarioFramework.PlatoonPatrolChain(units, 'M4_QAI_LandAttack_Full1_Chain')
            for i = 1, 2 do
                units = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'M4_QAI_InitAir_' .. i .. '_D' .. Difficulty, 'GrowthFormation')
                ScenarioFramework.PlatoonPatrolChain(units, 'M3_QAI_AirAttack_Mid_Chain')
            end

            for i = 1, 3 do
                units = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'M4_QAI_InitLand_' .. i .. '_D' .. Difficulty, 'GrowthFormation')
                ScenarioFramework.PlatoonPatrolChain(units, 'M4_QAI_LandAttack_Full1_Chain')
            end
            units = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'M4_QAI_InitAir_3_D' .. Difficulty, 'GrowthFormation')
            ScenarioFramework.PlatoonPatrolChain(units, 'M4_QAI_LandAttack_Full1_Chain')

            units = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'M4_QAI_InitNaval_1_D' .. Difficulty, 'GrowthFormation')
            ScenarioFramework.PlatoonPatrolChain(units, 'M3_QAI_NavalAttack_2_Chain')

            for i = 1, Difficulty do
                units = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'M4_QAI_TransportAttack_1', 'GrowthFormation')
                ScenarioFramework.PlatoonAttackWithTransports(units, 'M3_Transport_Landing_Chain', 'M3_Transport_Attack_Chain', false)
            end

            -----------------------
            -- QAI Colossus Response
            -----------------------
            local colossi = ArmyBrains[Order]:GetListOfUnits(categories.ual0401, false)
            if(table.getn(colossi) > 1) then
                for i = 1, Difficulty do
                    local soul = ScenarioUtils.CreateArmyUnit('QAI', 'M4_QAI_Soulripper' .. i)
                    local platoon = ArmyBrains[QAI]:MakePlatoon('','')
                    ArmyBrains[QAI]:AssignUnitsToPlatoon(platoon, {soul}, 'Attack', 'GrowthFormation')
                    for k, v in colossi do
                        if(v and not v:IsDead()) then
                            platoon:AttackTarget(v)
                        end
                    end
                    ScenarioFramework.PlatoonPatrolChain(platoon, 'M4_SoulRipper_Patrol_Chain')
                end
            else
                local soul = ScenarioUtils.CreateArmyUnit('QAI', 'M4_QAI_Soulripper1')
                ScenarioFramework.GroupPatrolRoute({soul}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M4_SoulRipper_Patrol_Chain')))
            end

            if(Difficulty > 1) then
                local spiderbots = ArmyBrains[QAI]:GetListOfUnits(categories.url0401, false)
                if(table.getn(spiderbots) == 0) then
                    units = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'M4_Adaptive_Spiderbots_D' .. Difficulty, 'GrowthFormation')
                    ScenarioFramework.PlatoonPatrolChain(units, 'M4_QAI_LandAttack_Full1_Chain')
                end
            end

            -----------
            -- QAI Nukes
            -----------
            ScenarioInfo.M4QAIMainNuke = ScenarioInfo.UnitNames[QAI]['QAI_Nuke_Launcher']
            ScenarioInfo.M4QAIMainNuke:GiveNukeSiloAmmo(2)

            ScenarioInfo.M4QAINorthNuke = ScenarioUtils.CreateArmyUnit('QAI', 'M4_QAI_North_Silo')
            ScenarioInfo.M4QAINorthNuke:GiveNukeSiloAmmo(1)

            ScenarioInfo.M4QAICenterNuke = ScenarioUtils.CreateArmyUnit('QAI', 'M4_QAI_Mid_Silo')
            ScenarioInfo.M4QAICenterNuke:GiveNukeSiloAmmo(1)

            ScenarioInfo.M4QAISouthNuke = ScenarioUtils.CreateArmyUnit('QAI', 'M4_QAI_South_Silo')
            ScenarioInfo.M4QAISouthNuke:GiveNukeSiloAmmo(1)

            -----------------
            -- Objective Units
            -----------------
            if(LeaderFaction == 'cybran') then
                local units = ScenarioUtils.CreateArmyGroup('QAI', 'M4_QAI_Research_Sundry')
                for k, v in units do
                    v:SetDoNotTarget(true)
                    v:SetCanTakeDamage(false)
                    v:SetCanBeKilled(false)
                    v:SetReclaimable(false)
                    v:SetCapturable(false)
                end
                ScenarioInfo.M3CybranVirusMain = ScenarioUtils.CreateArmyGroup('QAI', 'M4_QAI_Research_Main')
                for k, v in ScenarioInfo.M3CybranVirusMain do
                    v:SetDoNotTarget(true)
                    v:SetCanTakeDamage(false)
                    v:SetCanBeKilled(false)
                    v:SetReclaimable(false)
                    v:SetCapturable(false)
                end
                ScenarioInfo.M4QAIVirusBuilding = ScenarioInfo.UnitNames[QAI]['M4_QAI_VirusBuilding']
                ScenarioInfo.M4QAIVirusBuilding:SetCustomName(LOC '{i Quantum_Comm_Station}')
                ScenarioUtils.CreateArmyGroup('QAI', 'M4_QAI_Research_Defense')
             end

            -- Seraphim Gate
            ScenarioUtils.CreateArmyGroup('QAI', 'Quantum_Gate_Group')
            ScenarioInfo.SeraphimGate = ScenarioInfo.UnitNames[QAI]['M4_Quantum_Gate']
            ScenarioInfo.SeraphimGate:SetCanBeKilled(false)
            ScenarioInfo.SeraphimGate:SetCanTakeDamage(false)
            ScenarioInfo.SeraphimGate:SetReclaimable(false)
            ScenarioInfo.SeraphimGate:SetDoNotTarget(true)
            ScenarioInfo.SeraphimGate:SetCapturable(false)
            ScenarioInfo.SeraphimGate:SetCustomName(LOC '{i Seraphim_Gate}')

            -- QAI Commander
            ScenarioInfo.QAICommander = ScenarioUtils.CreateArmyUnit('QAI', 'M4_QAI_Commander')
            ScenarioInfo.QAICommander:SetCustomName(LOC '{i QAI}')
            ScenarioInfo.QAICommander:CreateEnhancement('T3Engineering')
            ScenarioInfo.QAICommander:CreateEnhancement('StealthGenerator')
            ScenarioInfo.QAICommander:CreateEnhancement('MicrowaveLaserGenerator')
            ScenarioFramework.PauseUnitDeath(ScenarioInfo.QAICommander)

            -- Czar
            if(LeaderFaction == 'aeon') then
                ScenarioInfo.M4Czar = ScenarioUtils.CreateArmyUnit('Order', 'M4_Order_Czar')
                ScenarioInfo.M4CzarPassengers = {}
                ScenarioFramework.CreateUnitDeathTrigger(M4CzarDeath, ScenarioInfo.M4Czar)
                for i = 1, 10 do
                    units = ScenarioUtils.CreateArmyGroup('Order', 'M4_Order_Czar_Aircraft')
                    for k, v in units do
                        IssueStop({v})
                        ScenarioInfo.M4Czar:AddUnitToStorage(v)
                        table.insert(ScenarioInfo.M4CzarPassengers, v)
                    end
                end
            end

            ForkThread(IntroMission4NIS)
        end
    )
end

function IntroMission4NIS()

    -- WaitSeconds(15)
    ForkThread( LaunchOrderNukes )
    WaitSeconds(5)
    ScenarioFramework.SetPlayableArea('M3_Playable_Area', false)

    Cinematics.EnterNISMode()
    Cinematics.SetInvincible( 'M2_Playable_Area' )

    WaitSeconds(1)

    ForkThread(
        function()
            WaitSeconds(6)
            ScenarioFramework.Dialogue(OpStrings.X02_M03_012, nil, true)
        end
    )
    ScenarioFramework.CreateTimerTrigger(NukeResponse, 60)
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_4_1'), 0)
    WaitSeconds(0.5)
    ForkThread( LaunchQAINukes )
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_4_2'), 8)

    ScenarioFramework.CreateVisibleAreaLocation( 5000, ScenarioUtils.MarkerToPosition( 'QAI_M4_Middle_Base' ), 8, ArmyBrains[Player] )

    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_4_3'), 0)
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_4_4'), 8)

    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_4_5'), 3)
    Cinematics.SetInvincible( 'M2_Playable_Area', true )
    Cinematics.ExitNISMode()

    ScenarioFramework.Dialogue(OpStrings.X02_M03_120, StartMission4)
end

function StartMission4()
    ------------------------------------------
    -- Primary Objective 1 - Kill QAI Commander
    ------------------------------------------
    ScenarioInfo.M4P1 = Objectives.KillOrCapture(
        'primary',                      -- type
        'incomplete',                   -- complete
        OpStrings.X02_M03_OBJ_010_070,  -- title
        OpStrings.X02_M03_OBJ_010_080,  -- description
        {                               -- target
            MarkUnits = true,
            Units = {ScenarioInfo.QAICommander},
        }
    )
    ScenarioInfo.M4P1:AddResultCallback(
        function(result)
            if(result) then
                ForkThread(
                    function()
                        ScenarioFramework.CDRDeathNISCamera(ScenarioInfo.QAICommander, 5)
                        WaitSeconds(5)
                        ScenarioFramework.Dialogue(OpStrings.X02_D01_030, PlayerWin)
                    end
                )
            end
         end
    )
    table.insert(AssignedObjectives, ScenarioInfo.M4P1)

    ScenarioFramework.CreateTimerTrigger(M4P1Reminder1, 900)
    if(LeaderFaction == 'cybran') then
        ScenarioFramework.CreateTimerTrigger(StartM4S2Cybran, 45)
    end
    ScenarioFramework.CreateTimerTrigger(M4Subplot, 180)
    if(LeaderFaction == 'aeon') then
        ScenarioFramework.CreateTimerTrigger(M4PingEventNotification, 300)
    end
    ScenarioFramework.Dialogue(OpStrings.X02_M03_021)

    -- Resource generator
    ScenarioFramework.UnrestrictWithVoiceoverAndDelay(categories.xab1401, "aeon", 90, OpStrings.X02_M03_130)
    ScenarioFramework.UnrestrictWithVoiceoverAndDelay(categories.xel0306, "uef", 90, OpStrings.X02_M01_220)
end

function LaunchOrderNukes()
    if(not ScenarioInfo.M4OrderNorthNuke:IsDead()) then
        IssueNuke({ScenarioInfo.M4OrderNorthNuke}, ScenarioUtils.MarkerToPosition('QAI_M4_North_Base'))
    end

    WaitSeconds(1.2)
    if(not ScenarioInfo.M4OrderCenterNuke:IsDead()) then
        IssueNuke({ScenarioInfo.M4OrderCenterNuke}, ScenarioUtils.MarkerToPosition('QAI_M4_Middle_Base'))
    end

    WaitSeconds(0.7)
    if(not ScenarioInfo.M4OrderSouthNuke:IsDead()) then
        IssueNuke({ScenarioInfo.M4OrderSouthNuke}, ScenarioUtils.MarkerToPosition('QAI_M3_South_Base'))
    end
end

function LaunchQAINukes()
    WaitSeconds(3)
    if(not ScenarioInfo.M4QAINorthNuke:IsDead()) then
        IssueNuke({ScenarioInfo.M4QAINorthNuke}, ScenarioUtils.MarkerToPosition('Order_M4_North_Base'))
    end

    WaitSeconds(1)
    if(not ScenarioInfo.M4QAICenterNuke:IsDead()) then
        IssueNuke({ScenarioInfo.M4QAICenterNuke}, ScenarioUtils.MarkerToPosition('Order_M4_Middle_Base'))
    end

    WaitSeconds(1)
    if(not ScenarioInfo.M4QAISouthNuke:IsDead()) then
        IssueNuke({ScenarioInfo.M4QAISouthNuke}, ScenarioUtils.MarkerToPosition('Order_M4_South_Base'))
    end

    WaitSeconds(0.6)
    if(not ScenarioInfo.M4QAIMainNuke:IsDead()) then
        IssueNuke({ScenarioInfo.M4QAIMainNuke}, ScenarioUtils.MarkerToPosition('M4_Nuke_Exchange_Order'))
    end
end

function NukeResponse()
    ScenarioFramework.Dialogue(OpStrings.X02_M03_015)

    SetupQAIM4Taunt()
end

function StartM4S2Cybran()
    ScenarioFramework.Dialogue(OpStrings.X02_M03_260, AssignM4S2Cybran)
end

function AssignM4S2Cybran()
    ------------------------------------
    -- Secondary Objective 2 - Infect QAI
    ------------------------------------
    ScenarioInfo.M4S2Cybran = Objectives.CategoriesInArea(
        'secondary',                        -- type
        'incomplete',                       -- complete
        OpStrings.X02_M03_OBJ_020_010,      -- title
        OpStrings.X02_M03_OBJ_020_015,      -- description
        'move',
        {                                   -- target
            Area = 'Cybran_Secondary_Virus_End',
            MarkArea = true,
            Requirements = {
                {Area = 'Cybran_Secondary_Virus_End', Category = categories.ENGINEER - categories.EXPERIMENTAL, CompareOp = '>=', Value = 1, ArmyIndex = Player},
            },
        }
    )
    ScenarioInfo.M4S2Cybran:AddResultCallback(
        function(result)
            if(result) then
                for k, unit in ScenarioInfo.M3CybranVirusMain do
                    if (unit and not unit:IsDead()) then
                        EffectUtilities.CybranBuildingInfection( unit )
                    end
                end
                if(ScenarioInfo.QAICommander and not ScenarioInfo.QAICommander:IsDead()) then
                    ScenarioFramework.Dialogue(OpStrings.X02_M03_285)
                    local pos = ScenarioInfo.QAICommander:GetPosition()
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
                    ScenarioInfo.QAICommander.Trash:Add( vizmarker )
                    vizmarker:AttachBoneTo(-1, ScenarioInfo.QAICommander, -1)
                end
            end
        end
    )
    table.insert(AssignedObjectives, ScenarioInfo.M4S2Cybran)
    ScenarioFramework.CreateTimerTrigger(M4S2CybranWarning, 120)
    ScenarioFramework.CreateTimerTrigger(M4S2CybranReminder1, 1200)
end

function M4S2CybranWarning()
    ScenarioFramework.Dialogue(OpStrings.X02_M03_280)
end

function M4Subplot()
    if(LeaderFaction == 'uef') then
        ScenarioFramework.Dialogue(OpStrings.X02_M03_240)
    elseif(LeaderFaction == 'aeon') then
        ScenarioFramework.Dialogue(OpStrings.X02_M03_250)
    end
end

function M4PingEventNotification()
    if(ScenarioInfo.M4Czar and not ScenarioInfo.M4Czar:IsDead()) then
        ScenarioFramework.Dialogue(OpStrings.X02_M03_140, M4PingEvent)
    end
end

function M4PingEvent()
    if(ScenarioInfo.M4Czar and not ScenarioInfo.M4Czar:IsDead()) then
        ScenarioInfo.CzarPing = PingGroups.AddPingGroup(OpStrings.X02_M01_OBJ_010_060, 'uaa0310', 'move', OpStrings.X02_M01_OBJ_010_065)
        ScenarioInfo.CzarPing:AddCallback(MoveCzar)
    end
end

function M4CzarDeath()
    if(ScenarioInfo.CzarPing) then
        ScenarioInfo.CzarPing:Destroy()
    end
end

function MoveCzar(location)
    ForkThread(
        function()
            ScenarioInfo.CzarLocation = location
            IssueStop({ScenarioInfo.M4Czar})
            IssueClearCommands({ScenarioInfo.M4Czar})
            local cmd = IssueMove({ScenarioInfo.M4Czar}, location)

            ScenarioFramework.CreateUnitDamagedTrigger(CzarDamaged, ScenarioInfo.M4Czar)

            while(not IsCommandDone(cmd)) do
                WaitSeconds(.5)
            end

            IssueStop({ScenarioInfo.M4Czar})
            IssueClearCommands({ScenarioInfo.M4Czar})
            IssueTransportUnload({ScenarioInfo.M4Czar}, ScenarioInfo.M4Czar:GetPosition())
        end
    )
end

function CzarDamaged()
    ForkThread(
        function()
            if(not ScenarioInfo.BombersReleased) then
                ScenarioInfo.BombersReleased = true
                IssueClearCommands({ScenarioInfo.M4Czar})
                IssueTransportUnload({ScenarioInfo.M4Czar}, ScenarioInfo.M4Czar:GetPosition())
                WaitSeconds(5)
                IssueMove({ScenarioInfo.M4Czar}, ScenarioInfo.CzarLocation)
                IssueMove(ScenarioInfo.M4CzarPassengers, ScenarioInfo.CzarLocation)
            end
        end
    )
end

-----------------
-- Taunts
-----------------
function SetupCeleneM1Taunt()
    CeleneTM:AddEnemiesKilledTaunt('TAUNT8', ArmyBrains[Order], categories.MOBILE, 60)              -- Order destroys 60 mobile units
    CeleneTM:AddDamageTaunt('TAUNT13', ScenarioInfo.PlayerCDR, .15)                                 -- Player CDR is reduced to 90% health
    if(LeaderFaction == 'cybran') then
        CeleneTM:AddEnemiesKilledTaunt('X02_M01_060', ArmyBrains[Order], categories.STRUCTURE, 10)  -- Order destroyes 10 structures
    end
end

function SetupCeleneM2Taunt()
    CeleneTM:AddStartBuildTaunt('TAUNT2', ArmyBrains[Player], categories.EXPERIMENTAL, 2 )          -- Celene responds to experimental
    CeleneTM:AddStartBuildTaunt('TAUNT3', ArmyBrains[Player], categories.EXPERIMENTAL, 3 )          -- Celene responds to experimental
    CeleneTM:AddUnitKilledTaunt('TAUNT9', ScenarioInfo.UnitNames[Order]['M2_TauntUnit'])            -- taunt when an opening stream unit is killed
    CeleneTM:AddDamageTaunt('TAUNT12', ScenarioInfo.PlayerCDR, .01)                                 -- Player CDR touched
    CeleneTM:AddUnitsKilledTaunt('TAUNT10', ArmyBrains[Player], categories.STRUCTURE, 10)           -- Player loses some structures
    CeleneTM:AddUnitsKilledTaunt('TAUNT11', ArmyBrains[Order], categories.STRUCTURE, 18)            -- Order loses some structures
    CeleneTM:AddUnitsKilledTaunt('TAUNT4', ArmyBrains[Loyalist], categories.STRUCTURE, 2)           -- Loyalist lose a structure, tuant relating to them

    if(LeaderFaction == 'uef') then                                        -- factional taunt when bit of Order base is destroyed
        CeleneTM:AddUnitKilledTaunt('TAUNT14', ScenarioInfo.UnitNames[Order]['M2_Order_TauntUnit'])
        CeleneTM:AddUnitsKilledTaunt('X02_M01_050', ArmyBrains[Order], categories.STRUCTURE * categories.TECH3, 2)
    elseif(LeaderFaction == 'cybran') then
        CeleneTM:AddUnitKilledTaunt('TAUNT15', ScenarioInfo.UnitNames[Order]['M2_Order_TauntUnit'])
        CeleneTM:AddUnitsKilledTaunt('TAUNT16', ArmyBrains[Order], categories.STRUCTURE * categories.TECH3, 2)
    elseif(LeaderFaction == 'aeon') then
        CeleneTM:AddUnitKilledTaunt('TAUNT17', ScenarioInfo.UnitNames[Order]['M2_Order_TauntUnit'])
        CeleneTM:AddUnitsKilledTaunt('TAUNT18', ArmyBrains[Order], categories.STRUCTURE * categories.TECH3, 2)
    end
end

function SetupQAIM2Taunt()
    QAITM:AddUnitsKilledTaunt('TAUNT27', ArmyBrains[QAI], categories.STRUCTURE, 3)                  -- QAI loses some structures

    if(LeaderFaction == 'cybran') then                                     -- faction specific taunts, player loses some good stuff
        QAITM:AddUnitsKilledTaunt('TAUNT31', ArmyBrains[Player], categories.MOBILE * categories.TECH3, 15)
    elseif(LeaderFaction == 'aeon') then
        QAITM:AddUnitsKilledTaunt('TAUNT33', ArmyBrains[Player], categories.MOBILE * categories.TECH3, 15)
    end
end

function SetupQAIM4Taunt()
    QAITM:AddAreaTaunt('TAUNT28', 'M1_Playable_Area', categories.ALLUNITS, ArmyBrains[QAI], 10)     -- QAI gets substantively into M1 area
    QAITM:AddDamageTaunt('TAUNT29', ScenarioInfo.PlayerCDR, .02)                                    -- Player CDR is touched

    if(LeaderFaction == 'uef') then                                        -- faction specific taunts, player gets hit a bit
        QAITM:AddUnitsKilledTaunt('TAUNT30', ArmyBrains[Player], categories.STRUCTURE, 4)
    elseif(LeaderFaction == 'cybran') then
        QAITM:AddUnitsKilledTaunt('TAUNT32', ArmyBrains[Player], categories.STRUCTURE, 4)
    elseif(LeaderFaction == 'aeon') then
        QAITM:AddUnitsKilledTaunt('TAUNT34', ArmyBrains[Player], categories.STRUCTURE, 4)
    end
    QAITM:AddDamageTaunt('TAUNT35', ScenarioInfo.QAICommander, .20)

end

---------------------
-- Objective Reminders
---------------------
function M1P1Reminder1()
    if(ScenarioInfo.M1P1.Active) then
        ScenarioFramework.Dialogue(OpStrings.X02_M01_110)
        ScenarioFramework.CreateTimerTrigger(M1P1Reminder2, 600)
    end
end

function M1P1Reminder2()
    if(ScenarioInfo.M1P1.Active) then
        ScenarioFramework.Dialogue(OpStrings.X02_M01_120)
    end
end

function M1P2Reminder1()
    if(ScenarioInfo.M1P1.Active) then
        ScenarioFramework.Dialogue(OpStrings.X02_M01_048)
        ScenarioFramework.CreateTimerTrigger(M1P2Reminder2, 2000)
    end
end

function M1P2Reminder2()
    if(ScenarioInfo.M1P1.Active) then
        ScenarioFramework.Dialogue(OpStrings.X02_M01_049)
    end
end

function M1S1Reminder1()
    if(ScenarioInfo.M1S1.Active and ScenarioInfo.MissionNumber == 1) then
        ScenarioFramework.Dialogue(OpStrings.X02_M01_160)
        ScenarioFramework.CreateTimerTrigger(M1S1Reminder2, 2000)
    end
end

function M1S1Reminder2()
    if(ScenarioInfo.M1S1.Active and ScenarioInfo.MissionNumber == 1) then
        ScenarioFramework.Dialogue(OpStrings.X02_M01_170)
     end
end

function M2P1Reminder1()
    if(ScenarioInfo.M2P1.Active) then
        ScenarioFramework.Dialogue(OpStrings.X02_M02_020)
        ScenarioFramework.CreateTimerTrigger(M2P1Reminder2, 2000)
    end
end

function M2P1Reminder2()
    if(ScenarioInfo.M2P1.Active) then
        ScenarioFramework.Dialogue(OpStrings.X02_M02_030)
    end
end

function M2S1AeonReminder1()
    if(ScenarioInfo.M2S1Aeon.Active) then
        ScenarioFramework.Dialogue(OpStrings.X02_M02_130)
        ScenarioFramework.CreateTimerTrigger(M2S1AeonReminder2, 2000)
    end
end

function M2S1AeonReminder2()
    if(ScenarioInfo.M2S1Aeon.Active) then
        ScenarioFramework.Dialogue(OpStrings.X02_M02_140)
    end
end

function M4P1Reminder1()
    if(ScenarioInfo.M4P1.Active) then
        ScenarioFramework.Dialogue(OpStrings.X02_M03_022)
        ScenarioFramework.CreateTimerTrigger(M4P1Reminder2, 2300)
    end
end

function M4P1Reminder2()
    if(ScenarioInfo.M4P1.Active) then
        ScenarioFramework.Dialogue(OpStrings.X02_M03_230)
    end
end

function M4S2CybranReminder1()
    if(ScenarioInfo.M4S2Cybran.Active) then
        ScenarioFramework.Dialogue(OpStrings.X02_M03_270)
    end
end
