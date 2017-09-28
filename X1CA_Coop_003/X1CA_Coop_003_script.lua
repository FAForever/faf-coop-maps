-- ****************************************************************************
-- **
-- **  File     :  /maps/X1CA_Coop_003/X1CA_Coop_003_script.lua
-- **  Author(s):  Jessica St. Croix
-- **
-- **  Summary  : Main mission flow script for X1CA_Coop_003
-- **
-- **  Copyright © 2007 Gas Powered Games, Inc.  All rights reserved.
-- ****************************************************************************
local BaseManager = import('/lua/ai/opai/basemanager.lua')
local Cinematics = import('/lua/cinematics.lua')
local M1SeraphimAI = import('/maps/X1CA_Coop_003/X1CA_Coop_003_m1seraphimai.lua')
local M1RhizaAI = import('/maps/X1CA_Coop_003/X1CA_Coop_003_m1rhizaai.lua')
local M2SeraphimAI = import('/maps/X1CA_Coop_003/X1CA_Coop_003_m2seraphimai.lua')
local M3PrincessAI = import('/maps/X1CA_Coop_003/X1CA_Coop_003_m3princessai.lua')
local M3SeraphimAI = import('/maps/X1CA_Coop_003/X1CA_Coop_003_m3seraphimai.lua')
local Objectives = import('/lua/ScenarioFramework.lua').Objectives
local OpStrings = import('/maps/X1CA_Coop_003/X1CA_Coop_003_strings.lua')
local PingGroups = import('/lua/ScenarioFramework.lua').PingGroups
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local Utilities = import('/lua/utilities.lua')
local TauntManager = import('/lua/TauntManager.lua')

local ScriptFile = '/maps/X1CA_Coop_003/X1CA_Coop_003_script.lua'
local SPAIFileName = '/lua/ScenarioPlatoonAI.lua'

---------
-- Globals
---------
ScenarioInfo.Player1 = 1
ScenarioInfo.Seraphim = 2
ScenarioInfo.Rhiza = 3
ScenarioInfo.Princess = 4
ScenarioInfo.Crystals = 5
ScenarioInfo.Player2 = 6
ScenarioInfo.Player3 = 7
ScenarioInfo.Player4 = 8
ScenarioInfo.NumBombersDestroyed = 0

--------
-- Locals
--------
local Player1 = ScenarioInfo.Player1
local Player2 = ScenarioInfo.Player2
local Player3 = ScenarioInfo.Player3
local Player4 = ScenarioInfo.Player4
local Seraphim = ScenarioInfo.Seraphim
local Rhiza = ScenarioInfo.Rhiza
local Princess = ScenarioInfo.Princess
local Crystals = ScenarioInfo.Crystals

local AssignedObjectives = {}
local Difficulty = ScenarioInfo.Options.Difficulty

local NumBombers = 0

-- How long should we wait at the beginning of the NIS to allow slower machines to catch up?
local NIS1InitialDelay = 1

----------------
-- Taunt Managers
----------------
local ZanNorthTM = TauntManager.CreateTauntManager('ZanNorthTM', '/maps/X1CA_Coop_003/X1CA_Coop_003_Strings.lua')
local ThelWestTM = TauntManager.CreateTauntManager('ThelWestTM', '/maps/X1CA_Coop_003/X1CA_Coop_003_Strings.lua')
local PrincTM = TauntManager.CreateTauntManager('PrincTM', '/maps/X1CA_Coop_003/X1CA_Coop_003_Strings.lua')
local PrincNorthTM = TauntManager.CreateTauntManager('PrincNorthTM', '/maps/X1CA_Coop_003/X1CA_Coop_003_Strings.lua')  -- for taunts related to north seraph from princess
local PrincWestTM = TauntManager.CreateTauntManager('PrincWestTM', '/maps/X1CA_Coop_003/X1CA_Coop_003_Strings.lua')   -- for taunts related to west seraph from princess
local HQTM = TauntManager.CreateTauntManager('HQTM', '/maps/X1CA_Coop_003/X1CA_Coop_003_Strings.lua')
local ExperimentalTM = TauntManager.CreateTauntManager('ExperimentalTM', '/maps/X1CA_Coop_003/X1CA_Coop_003_Strings.lua')

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
        ScenarioFramework.SetCybranPlayerColor(Player1)
    elseif(LeaderFaction == 'uef') then
        ScenarioFramework.SetUEFPlayerColor(Player1)
    elseif(LeaderFaction == 'aeon') then
        ScenarioFramework.SetAeonPlayerColor(Player1)
    end
    ScenarioFramework.SetSeraphimColor(Seraphim)
    ScenarioFramework.SetAeonAlly1Color(Rhiza)
    ScenarioFramework.SetAeonAlly2Color(Princess)
    ScenarioFramework.SetNeutralColor(Crystals)
    local colors = {
        ['Player2'] = {250, 250, 0}, 
        ['Player3'] = {255, 255, 255}, 
        ['Player4'] = {97, 109, 126}
    }
    local tblArmy = ListArmies()
    for army, color in colors do
        if tblArmy[ScenarioInfo[army]] then
            ScenarioFramework.SetArmyColor(ScenarioInfo[army], unpack(color))
        end
    end

    -- Unit Cap
    ScenarioFramework.SetSharedUnitCap(1000)
    SetArmyUnitCap(Seraphim, 750)
    SetArmyUnitCap(Rhiza, 280)
    SetArmyUnitCap(Princess, 250)

    -- Disable friendly AI sharing resources to players
    GetArmyBrain(Rhiza):SetResourceSharing(false)
    GetArmyBrain(Princess):SetResourceSharing(false)

    -- Crystals
    ScenarioUtils.CreateArmyGroup('Crystals', 'M1_Crystals')

    ----------------
    -- Seraphim M1 AI
    ----------------
    M1SeraphimAI.SeraphimM1NorthBaseAI()
    M1SeraphimAI.SeraphimM1MiddleBaseAI()

    --------------------------
    -- Seraphim Initial Patrols
    --------------------------
    local units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M1_Seraph_Init_AirDef1_D' .. Difficulty, 'GrowthFormation')
    for k, v in units:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M1_Seraph_Main_AirDef_Chain')))
    end

    for i = 1, 2 do
        units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M1_Seraph_Init_NavalDef' .. i .. '_D' .. Difficulty, 'AttackFormation')
        for k, v in units:GetPlatoonUnits() do
            ScenarioFramework.GroupPatrolChain({v}, 'M1_Seraph_Main_NavalDef' .. i .. '_Chain')
        end
    end

    units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M1_Seraph_MidFleet_West_D' .. Difficulty, 'AttackFormation')
    for k, v in units:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolChain({v}, 'M1_Seraph_MidPatrol_West' .. Random(1,2) .. '_Chain')
    end

    units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M1_Seraph_MidFleet_East_D' .. Difficulty, 'AttackFormation')
    for k, v in units:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolChain({v}, 'M1_Seraph_MidPatrol_East' .. Random(1,2) .. '_Chain')
    end

    units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M1_Seraph_MidFleet_General_D' .. Difficulty, 'AttackFormation')
    for k, v in units:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolChain({v}, 'M1_Sub_Patrol_Chain')
    end

    units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M1_Seraph_Mid_InitAir_D' .. Difficulty, 'GrowthFormation')
    for k, v in units:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M1_Seraph_MidAir_Def_Chain')))
    end

    --------------------------
    -- Seraphim Initial Attacks
    --------------------------
    units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M1_Seraph_InitAttack_Air_1', 'GrowthFormation')
    for k, v in units:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M1_Seraph_InitAir_Attack_Chain')))
    end

    units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M1_Seraph_InitAttack_Air_2', 'GrowthFormation')
    for k, v in units:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M1_Seraph_Air_Attack1_Chain')))
    end

    for i = 1, 2 do
        units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M1_Seraph_InitAttack_Naval_' .. i, 'AttackFormation')
        ScenarioFramework.PlatoonPatrolChain(units, 'M1_Seraph_Init_Naval_2_Chain')
    end

    units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M1_Seraph_InitAttack_Naval_3', 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(units, 'M1_Seraph_Naval_Attack2_Chain')

    --------------------------
    -- Seraphim Special Attacks
    --------------------------

    -- East Carrier
    ScenarioInfo.M1EastCarrier = ScenarioUtils.CreateArmyUnit('Seraphim', 'M1_Seraph_East_AC')
    ScenarioInfo.M1EastCarrierPassengers = {}
    for i = 1, 5 do
        units = ScenarioUtils.CreateArmyGroup('Seraphim', 'M1_Seraph_AirCraftCarrier_Units')
        for k, v in units do
            IssueStop({v})
            ScenarioInfo.M1EastCarrier:AddUnitToStorage(v)
            table.insert(ScenarioInfo.M1EastCarrierPassengers, v)
        end
    end
    ScenarioFramework.GroupPatrolChain({ScenarioInfo.M1EastCarrier}, 'M1_Seraph_MidPatrol_East' .. Random(1,2) .. '_Chain')
    ScenarioFramework.CreateAreaTrigger(M1EastCarrierRelease, ScenarioUtils.AreaToRect('M1_Mid_Area_East'), categories.AIR * categories.MOBILE, true, false, ArmyBrains[Player1], 10, false)

    -- West Carrier
    ScenarioInfo.M1WestCarrier = ScenarioUtils.CreateArmyUnit('Seraphim', 'M1_Seraph_West_AC')
    ScenarioInfo.M1WestCarrierPassengers = {}
    for i = 1, 5 do
        units = ScenarioUtils.CreateArmyGroup('Seraphim', 'M1_Seraph_AirCraftCarrier_Units')
        for k, v in units do
            IssueStop({v})
            ScenarioInfo.M1WestCarrier:AddUnitToStorage(v)
            table.insert(ScenarioInfo.M1WestCarrierPassengers, v)
        end
    end
    ScenarioFramework.GroupPatrolChain({ScenarioInfo.M1WestCarrier}, 'M1_Seraph_MidPatrol_West' .. Random(1,2) .. '_Chain')
    ScenarioFramework.CreateAreaTrigger(M1WestCarrierRelease, ScenarioUtils.AreaToRect('M1_Mid_Area_West'), categories.AIR * categories.MOBILE, true, false, ArmyBrains[Player1], 10, false)

    -- Middle Battleship
    ScenarioInfo.M1MiddleBattleship = ScenarioUtils.CreateArmyGroup('Seraphim', 'M1_Seraph_Battleship_Mid_D' .. Difficulty)
    for k, v in ScenarioInfo.M1MiddleBattleship do
        ScenarioFramework.GroupPatrolChain({v}, 'M1_Seraph_Battle_2_Patrol_Chain')
    end
    ScenarioFramework.CreateArmyStatTrigger(M1MiddleBattleshipAttack, ArmyBrains[Player1], 'M1MiddleBattleshipAttack',
        {{StatType = 'Units_Active', CompareType = 'GreaterThanOrEqual', Value = 15, Category = categories.TECH3 - categories.ENGINEER}})

    -- North Battleship
    ScenarioInfo.M1NorthBattleship = ScenarioUtils.CreateArmyGroup('Seraphim', 'M1_Seraph_Battleship_Main_D' .. Difficulty)
    for k, v in ScenarioInfo.M1NorthBattleship do
        ScenarioFramework.GroupPatrolChain({v}, 'M1_Seraph_Battle_1_Patrol_Chain')
    end
    ScenarioFramework.CreateArmyStatTrigger(M1NorthBattleshipAttack, ArmyBrains[Player1], 'M1NorthBattleshipAttack',
        {{StatType = 'Units_Active', CompareType = 'GreaterThanOrEqual', Value = 30, Category = categories.TECH3 - categories.ENGINEER}})

    -------------
    -- Rhiza M1 AI
    -------------
    M1RhizaAI.M1RhizaBaseAI()

    -----------------------
    -- Rhiza Initial Patrols
    -----------------------
    units = ScenarioUtils.CreateArmyGroupAsPlatoon('Rhiza', 'M1_Rhiza_Init_AirDef_D' .. Difficulty, 'GrowthFormation')
    for k, v in units:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M1_Rhiza_AirDef_Chain')))
    end

    units = ScenarioUtils.CreateArmyGroupAsPlatoon('Rhiza', 'M1_Rhiza_Init_NavalDef_D' .. Difficulty, 'AttackFormation')
    for k, v in units:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolChain({v}, 'M1_Rhiza_NavalDef_Chain')
    end

    -- Rhiza
    ScenarioInfo.RhizaACU = ScenarioFramework.SpawnCommander('Rhiza', 'Rhiza', false, LOC '{i Rhiza}', false, false,
        {'Shield', 'AdvancedEngineering', 'T3Engineering', 'EnhancedSensors'})
    ScenarioInfo.RhizaACU:SetCanBeKilled(false)
    ScenarioFramework.GroupPatrolChain({ScenarioInfo.RhizaACU}, 'M1_Rhiza_Base_EngineerChain')
    ScenarioFramework.CreateUnitDamagedTrigger(RhizaWarp, ScenarioInfo.RhizaACU, .8)

    ScenarioFramework.SetPlayableArea('M1_Playable_Area', false)
end 

function OnStart()
    --------------------
    -- Build Restrictions
    --------------------
    for _, player in ScenarioInfo.HumanPlayers do
        ScenarioFramework.AddRestriction(player,
            categories.xas0204 + -- Aeon Submarine Hunter
            categories.xaa0306 + -- Aeon Torpedo Bomber
            categories.xas0306 + -- Aeon Missile Ship
            categories.xab3301 + -- Aeon Quantum Optics Device
            categories.xab2307 + -- Aeon Rapid Fire Artillery
            categories.xaa0305 + -- Aeon AA Gunship
            categories.xrs0204 + -- Cybran Sub Killer
            categories.xrs0205 + -- Cybran Counter-Intelligence Boat
            categories.xrb2308 + -- Cybran Torpedo Ambushing System
            categories.xrb0104 + -- Cybran Engineering Station 1
            categories.xrb0204 + -- Cybran Engineering Station 2
            categories.xrb0304 + -- Cybran Engineering Station 3
            categories.xrb3301 + -- Cybran Perimeter Monitoring System
            categories.xra0305 + -- Cybran Heavy Gunship
            categories.xrl0403 + -- Cybran Amphibious Mega Bot
            categories.xes0102 + -- UEF Torpedo Boat
            categories.xes0205 + -- UEF Shield Boat
            categories.xes0307 + -- UEF Battlecruiser
            categories.xeb0104 + -- UEF Engineering Station 1
            categories.xeb0204 + -- UEF Engineering Station 2
            categories.xea0306 + -- UEF Heavy Air Transport
            categories.xeb2402 + -- UEF Sub-Orbital Defense System
            categories.xsa0402 + -- Seraph Exp Bomb
            categories.xss0304 + -- Seraph Sub Hunter
            categories.xsb0304 + -- Seraph Gate
            categories.xsl0301 + -- Seraph sACU
            categories.xsb2401   -- Seraph exp Nuke
        )
    end

    ScenarioFramework.AddRestriction(Rhiza, categories.uas0302) -- Aeon Battleship

    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_1_1'), 0)

    ForkThread(IntroNIS)
end

function RhizaWarp()
    ScenarioFramework.Dialogue(OpStrings.X03_M03_235)
    ForkThread(
        function()
            ScenarioFramework.FakeTeleportUnit(ScenarioInfo.RhizaACU, true)
        end
    )
    M1RhizaAI.DisableBase()
end

----------
-- End Game
----------
function PlayerWin()
    if(not ScenarioInfo.OpEnded) then
        ScenarioFramework.EndOperationSafety()
        ScenarioInfo.OpComplete = true
        if(ScenarioInfo.M3P3.Active) then
            ScenarioInfo.M3P3:ManualResult(true)
        end
        ForkThread( KillGame )
    end
end

function PlayerDeath(deadPlayer)
    ScenarioFramework.PlayerDeath(deadPlayer, OpStrings.X03_DB01_030, AssignedObjectives)
end

function PlayerLosePrincess()
    if(not ScenarioInfo.OpEnded) then
        if not ScenarioInfo.M2Ending then
            ScenarioFramework.CDRDeathNISCamera(ScenarioInfo.PrincessPalace)
        end
        ScenarioFramework.EndOperationSafety()
        ScenarioInfo.OpComplete = false
        for k, v in AssignedObjectives do
            if(v and v.Active) then
                v:ManualResult(false)
            end
        end
        ScenarioFramework.FlushDialogueQueue()
        ScenarioFramework.Dialogue(OpStrings.X03_M02_109, nil, true)
        ScenarioFramework.Dialogue(OpStrings.X03_M02_115, nil, true)
        ForkThread(
            function()
                WaitSeconds(3)
                UnlockInput()
                KillGame()
            end
        )
    end
end

function KillGame()
    ForkThread(
        function()
            ScenarioFramework.EndOperation(ScenarioInfo.OpComplete, ScenarioInfo.OpComplete, true)
        end
    )
end

-----------
-- Intro NIS
-----------
function IntroNIS()
    -- Show the north base buildings
    local NorthVisMarker = ScenarioFramework.CreateVisibleAreaLocation( 100, ScenarioUtils.MarkerToPosition( 'M1_North_Vis_Marker' ), 0, ArmyBrains[Player1] )

    Cinematics.EnterNISMode()

    -- I'm not sure that the player can really see these ships much with the current pan speed we're using
    -- So, commenting out for now
    -- local VisMarker = ScenarioFramework.CreateVisibleAreaLocation(30, ScenarioUtils.MarkerToPosition('NIS1_VisMarker'), 25, ArmyBrains[Player1])

    -- Turn off her shields for more visibility during the NIS
    local AllShieldUnits = ArmyBrains[Rhiza]:GetListOfUnits(categories.SHIELD, false)
    ForkThread(ShieldToggle, AllShieldUnits, false, false)


    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_1_1'), 0)

    -- Let slower machines catch up before we get going
    WaitSeconds(NIS1InitialDelay)

    ScenarioFramework.Dialogue(OpStrings.X03_M01_010, nil, true)

    WaitSeconds(2)

    local NISUnits1 = ScenarioUtils.CreateArmyGroup('Seraphim', 'Initial_NIS')
    local NISUnits2 = ScenarioUtils.CreateArmyGroup('Rhiza', 'Initial_NIS')

    WaitSeconds(1)
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_1_2'), 4)
    WaitSeconds(0.5)
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_1_3'), 2)
    WaitSeconds(0.5)

    if (LeaderFaction == 'uef') then
        ScenarioFramework.Dialogue(OpStrings.X03_M01_020, nil, true)
        ScenarioFramework.Dialogue(OpStrings.X03_M01_021, nil, true)
    elseif (LeaderFaction == 'cybran') then
        ScenarioFramework.Dialogue(OpStrings.X03_M01_030, nil, true)
        ScenarioFramework.Dialogue(OpStrings.X03_M01_031, nil, true)
    elseif (LeaderFaction == 'aeon') then
        ScenarioFramework.Dialogue(OpStrings.X03_M01_040, nil, true)
        ScenarioFramework.Dialogue(OpStrings.X03_M01_041, nil, true)
    end

    if (Difficulty == 3) then
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_1_4_Hard'), 3)
    else
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_1_4'), 3)
    end
    WaitSeconds(1)
    if (Difficulty == 3) then
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_1_5_Hard'), 6)
    else
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_1_5'), 6)
    end
    WaitSeconds(1)

    -- Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_1_1_2'), 0)
    -- Cinematics.CameraTrackEntity( ScenarioInfo.RhizaACU, 20, 0 )
    Cinematics.CameraTrackEntity(ScenarioInfo.RhizaACU, 30, 4)
    WaitSeconds(1.5)
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_1_6'), 3)

    if (LeaderFaction == 'aeon') then
        ScenarioInfo.PlayerCDR = ScenarioFramework.SpawnCommander('Player1', 'AeonPlayer', 'Warp', true, true, PlayerDeath)
    elseif (LeaderFaction == 'uef') then
        ScenarioInfo.PlayerCDR = ScenarioFramework.SpawnCommander('Player1', 'UEFPlayer', 'Warp', true, true, PlayerDeath)
    elseif (LeaderFaction == 'cybran') then
        ScenarioInfo.PlayerCDR = ScenarioFramework.SpawnCommander('Player1', 'CybranPlayer', 'Warp', true, true, PlayerDeath)
    end

    -- spawn coop players too
    ScenarioInfo.CoopCDR = {}
    local tblArmy = ListArmies()
    coop = 1
    for iArmy, strArmy in pairs(tblArmy) do
        if iArmy >= ScenarioInfo.Player2 then
            factionIdx = GetArmyBrain(strArmy):GetFactionIndex()
            if (factionIdx == 1) then
                ScenarioInfo.CoopCDR[coop] = ScenarioFramework.SpawnCommander(strArmy, 'UEFPlayer', 'Warp', true, true, PlayerDeath)
            elseif (factionIdx == 2) then
                ScenarioInfo.CoopCDR[coop] = ScenarioFramework.SpawnCommander(strArmy, 'AeonPlayer', 'Warp', true, true, PlayerDeath)
            else
                ScenarioInfo.CoopCDR[coop] = ScenarioFramework.SpawnCommander(strArmy, 'CybranPlayer', 'Warp', true, true, PlayerDeath)
            end
            coop = coop + 1
            WaitSeconds(0.5)
        end
    end

    WaitSeconds(2)

    if (LeaderFaction == 'aeon') then
        ScenarioFramework.Dialogue(OpStrings.X03_M01_042, nil, true)
    elseif (LeaderFaction == 'uef') then
        ScenarioFramework.Dialogue(OpStrings.X03_M01_022, nil, true)
    elseif (LeaderFaction == 'cybran') then
        ScenarioFramework.Dialogue(OpStrings.X03_M01_032, nil, true)
    end

    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_1_7'), 3)

    for k, unit in NISUnits1 do
        if unit and not unit:IsDead() then
            unit:Kill()
        end
    end

    for k, unit in NISUnits2 do
        if unit and not unit:IsDead() then
            unit:Kill()
        end
    end

    -- Turn her shields back on
    ForkThread(ShieldToggle, AllShieldUnits, true, false)

    Cinematics.ExitNISMode()

    NorthVisMarker:Destroy()
    IntroMission1()
end

function IntroMission1()
    ScenarioInfo.MissionNumber = 1

    if(LeaderFaction == 'uef') then
        ScenarioFramework.Dialogue(OpStrings.X03_M01_050, StartMission1)
    elseif(LeaderFaction == 'cybran') then
        ScenarioFramework.Dialogue(OpStrings.X03_M01_050, StartMission1)
    elseif(LeaderFaction == 'aeon') then
        ScenarioFramework.Dialogue(OpStrings.X03_M01_060, StartMission1)
    end
end

function StartMission1()
    local units = ArmyBrains[Seraphim]:GetListOfUnits(categories.FACTORY * categories.STRUCTURE, false)

    --------------------------------------------------
    -- Primary Objective 1 - Defeat Seraphim Naval Base
    --------------------------------------------------
    ScenarioInfo.M1P1 = Objectives.KillOrCapture(
        'primary',                      -- type
        'incomplete',                   -- status
        OpStrings.X03_M01_OBJ_010_010,  -- title
        OpStrings.X03_M01_OBJ_010_020,  -- description
        {                               -- target
            Units = units,
        }
    )
    ScenarioInfo.M1P1:AddResultCallback(
        function(result)
            if(result) then
                ScenarioFramework.Dialogue(OpStrings.X03_M01_150, IntroMission2)
            end
        end
    )
    table.insert(AssignedObjectives, ScenarioInfo.M1P1)
    ScenarioFramework.CreateTimerTrigger(M1P1Reminder1, 1080)

    ScenarioFramework.CreateTimerTrigger(M1Crystals, 120)
    ScenarioFramework.UnrestrictWithVoiceoverAndDelay(categories.xes0205, "uef", 140, OpStrings.X03_M01_067)
    ScenarioFramework.UnrestrictWithVoiceoverAndDelay(categories.xrb2308, "cybran", 140, OpStrings.X03_M01_066)
    ScenarioFramework.CreateTimerTrigger(M1Subplot1, 300)
    ScenarioFramework.CreateTimerTrigger(M1Subplot2, 600)
    -- Rebuild Rhiza's base once player clears the middle island
    ScenarioFramework.CreateAreaTrigger(M1RhizaAI.M1RhizaRebuildWreckages, 'M1_MiddleIsland_Area', categories.ALLUNITS - categories.WALL, true, true, ArmyBrains[Seraphim])

    -- taunts for the 2 Seraphim commanders (not in-map until M3)
    SetupNorthM1Taunts()
    SetupWestM1Taunts()
end

function M1NorthBattleshipAttack()
    if(ScenarioInfo.M1NorthBattleship) then
        for k,v in ScenarioInfo.M1NorthBattleship do
            if(v and not v:IsDead()) then
                IssueClearCommands({v})
                ScenarioFramework.GroupPatrolChain({v}, 'M1_Seraph_Battle_1_Attack_Chain')
            end
        end
    end
end

function M1MiddleBattleshipAttack()
    if(ScenarioInfo.M1MiddleBattleship) then
        for k,v in ScenarioInfo.M1MiddleBattleship do
            if(v and not v:IsDead()) then
                IssueClearCommands({v})
                ScenarioFramework.GroupPatrolChain({v}, 'M1_Seraph_Battle_2_Attack_Chain')
            end
        end
    end
end

function M1EastCarrierRelease()
    ForkThread(
        function()
            if(ScenarioInfo.M1EastCarrier and not ScenarioInfo.M1EastCarrier:IsDead() and ScenarioInfo.M1EastCarrierPassengers) then
                IssueClearCommands({ScenarioInfo.M1EastCarrier})
                IssueTransportUnload({ScenarioInfo.M1EastCarrier}, ScenarioInfo.M1EastCarrier:GetPosition())
                WaitSeconds(5)
                ScenarioFramework.GroupPatrolChain({ScenarioInfo.M1EastCarrier}, 'M1_Seraph_MidPatrol_East' .. Random(1,2) .. '_Chain')
                for k,v in ScenarioInfo.M1EastCarrierPassengers do
                    if(v and not v:IsDead()) then
                        IssueClearCommands({v})
                        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M1_Sub_Patrol_Chain')))
                    end
                end
                WaitSeconds(30)
                ScenarioFramework.CreateMultipleAreaTrigger(M1EastCarrierLoad, {ScenarioUtils.AreaToRect('M1_Mid_Area_East'), ScenarioUtils.AreaToRect('M1_Mid_Area_West')}, categories.AIR * categories.MOBILE, true, true, ArmyBrains[Player1])
            end
        end
    )
end

function M1EastCarrierLoad()
    if(ScenarioInfo.M1EastCarrier and not ScenarioInfo.M1EastCarrier:IsDead() and ScenarioInfo.M1EastCarrierPassengers) then
        IssueClearCommands({ScenarioInfo.M1EastCarrier})
        for k,v in ScenarioInfo.M1EastCarrierPassengers do
            if(v and not v:IsDead() and not v:IsUnitState('Attached')) then
                IssueClearCommands({v})
                IssueTransportLoad({v}, ScenarioInfo.M1EastCarrier)
            end
        end
        ScenarioFramework.GroupPatrolChain({ScenarioInfo.M1EastCarrier}, 'M1_Seraph_MidPatrol_East' .. Random(1,2) .. '_Chain')
        ScenarioFramework.CreateAreaTrigger(M1EastCarrierRelease, ScenarioUtils.AreaToRect('M1_Mid_Area_East'), categories.AIR * categories.MOBILE, true, false, ArmyBrains[Player1], 10, false)
    end
end

function M1WestCarrierRelease()
    ForkThread(
        function()
            if(ScenarioInfo.M1WestCarrier and not ScenarioInfo.M1WestCarrier:IsDead() and ScenarioInfo.M1WestCarrierPassengers) then
                IssueClearCommands({ScenarioInfo.M1WestCarrier})
                IssueTransportUnload({ScenarioInfo.M1WestCarrier}, ScenarioInfo.M1WestCarrier:GetPosition())
                WaitSeconds(5)
                ScenarioFramework.GroupPatrolChain({ScenarioInfo.M1WestCarrier}, 'M1_Seraph_MidPatrol_West' .. Random(1,2) .. '_Chain')
                for k,v in ScenarioInfo.M1WestCarrierPassengers do
                    if(v and not v:IsDead()) then
                        IssueClearCommands({v})
                        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M1_Sub_Patrol_Chain')))
                    end
                end
                WaitSeconds(30)
                ScenarioFramework.CreateMultipleAreaTrigger(M1WestCarrierLoad, {ScenarioUtils.AreaToRect('M1_Mid_Area_West'), ScenarioUtils.AreaToRect('M1_Mid_Area_East')}, categories.AIR * categories.MOBILE, true, true, ArmyBrains[Player1])
            end
        end
    )
end

function M1WestCarrierLoad()
    if(ScenarioInfo.M1WestCarrier and not ScenarioInfo.M1WestCarrier:IsDead() and ScenarioInfo.M1WestCarrierPassengers) then
        IssueClearCommands({ScenarioInfo.M1WestCarrier})
        for k,v in ScenarioInfo.M1WestCarrierPassengers do
            if(v and not v:IsDead() and not v:IsUnitState('Attached')) then
                IssueClearCommands({v})
                IssueTransportLoad({v}, ScenarioInfo.M1WestCarrier)
            end
        end
        ScenarioFramework.GroupPatrolChain({ScenarioInfo.M1WestCarrier}, 'M1_Seraph_MidPatrol_West' .. Random(1,2) .. '_Chain')
        ScenarioFramework.CreateAreaTrigger(M1WestCarrierRelease, ScenarioUtils.AreaToRect('M1_Mid_Area_West'), categories.AIR * categories.MOBILE, true, false, ArmyBrains[Player1], 10, false)
    end
end

function M1Crystals()
    ScenarioFramework.Dialogue(OpStrings.X03_M01_064)
end

function M1Subplot1()
    if(LeaderFaction == 'uef') then
        ScenarioFramework.Dialogue(OpStrings.X03_M01_070)
    elseif(LeaderFaction == 'cybran') then
        ScenarioFramework.Dialogue(OpStrings.X03_M01_080)
    elseif(LeaderFaction == 'aeon') then
        ScenarioFramework.Dialogue(OpStrings.X03_M01_090)
    end
end

function M1Subplot2()
    ScenarioFramework.Dialogue(OpStrings.X03_M01_100)
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
            local units = nil

            -- Crystals
            ScenarioUtils.CreateArmyGroup('Crystals', 'M2_Crystals')

            ----------------
            -- Seraphim M2 AI
            ----------------
            M2SeraphimAI.SeraphimM2NorthBaseAI()
            M2SeraphimAI.SeraphimM2SouthBaseAI()

            --------------------------
            -- Seraphim Static Defenses
            --------------------------
            ScenarioUtils.CreateArmyGroup('Seraphim', 'M2_Seraph_NorthIsland_Defense_D' .. Difficulty)
            ScenarioUtils.CreateArmyGroup('Seraphim', 'M2_Seraph_SouthIsland_Defense_D' .. Difficulty)

            --------------------------
            -- Seraphim Initial Patrols
            --------------------------
            units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M2_Seraph_North_Base_AirDef_D' .. Difficulty, 'GrowthFormation')
            for k, v in units:GetPlatoonUnits() do
                ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M2_Seraph_MainNorth_AirDef_Chain')))
            end

            units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M2_Seraph_NorthBase_NavalDef_N_D' .. Difficulty, 'AttackFormation')
            for k, v in units:GetPlatoonUnits() do
                ScenarioFramework.GroupPatrolChain({v}, 'M2_Seraph_MainNorth_NavalDef_North_Chain')
            end

            units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M2_Seraph_NorthBase_NavalDef_S_D' .. Difficulty, 'AttackFormation')
            for k, v in units:GetPlatoonUnits() do
                ScenarioFramework.GroupPatrolChain({v}, 'M2_Seraph_MainNorth_NavalDef_South_Chain')
            end

            units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M2_Seraph_South_Base_AirDef_D' .. Difficulty, 'GrowthFormation')
            for k, v in units:GetPlatoonUnits() do
                ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M2_Seraph_MainSouth_AirDef_Chain')))
            end

            units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M2_Seraph_SouthBase_NavalDef_W_D' .. Difficulty, 'AttackFormation')
            for k, v in units:GetPlatoonUnits() do
                ScenarioFramework.GroupPatrolChain({v}, 'M2_Seraph_MainSouth_NavalDef_West_Chain')
            end

            units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M2_Seraph_SouthBase_NavalDef_E_D' .. Difficulty, 'AttackFormation')
            for k, v in units:GetPlatoonUnits() do
                ScenarioFramework.GroupPatrolChain({v}, 'M2_Seraph_MainSouth_NavalDef_East_Chain')
            end

            units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M2_Seraph_MidNaval_Patrol_D' .. Difficulty, 'AttackFormation')
            ScenarioFramework.PlatoonPatrolChain(units, 'M2_Seraph_Patrol_MidNaval_Chain')

            units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M2_Seraph_Subs_D' .. Difficulty, 'AttackFormation')
            for k, v in units:GetPlatoonUnits() do
                ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M2_Seraph_Exper_NavalDef' .. Random(1,2) .. '_Chain')))
            end

            --------------------------
            -- Seraphim Initial Attacks
            --------------------------
            units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M2_Seraph_InitAir_Attack_D' .. Difficulty, 'GrowthFormation')
            ScenarioFramework.PlatoonPatrolChain(units, 'M2_Seraph_North_AirMain_1_Chain')

            units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M2_Seraph_InitNaval_Attack_D' .. Difficulty, 'AttackFormation')
            ScenarioFramework.PlatoonPatrolChain(units, 'M2_Seraph_South_NavalMain_1_Chain')

            --------------------------
            -- Seraphim Special Attacks
            --------------------------

            -- North Carrier
            ScenarioInfo.M2NorthCarrier = ScenarioUtils.CreateArmyUnit('Seraphim', 'M2_Seraph_North_Carrier')
            ScenarioInfo.M2NorthCarrierPassengers = {}
            for i = 1, 5 do
                units = ScenarioUtils.CreateArmyGroup('Seraphim', 'M2_Seraph_NorthCarrier_Units')
                for k, v in units do
                    IssueStop({v})
                    ScenarioInfo.M2NorthCarrier:AddUnitToStorage(v)
                    table.insert(ScenarioInfo.M2NorthCarrierPassengers, v)
                end
            end
            ScenarioFramework.GroupPatrolChain({ScenarioInfo.M2NorthCarrier}, 'M2_Seraph_Carrier_North_Chain')
            ScenarioFramework.CreateAreaTrigger(M2NorthCarrierRelease, ScenarioUtils.AreaToRect('M2_NorthBase_Carrier_Area'), categories.AIR * categories.MOBILE, true, false, ArmyBrains[Player1], 10, false)

            -- South Carrier
            ScenarioInfo.M2SouthCarrier = ScenarioUtils.CreateArmyUnit('Seraphim', 'M2_Seraph_South_Carrier')
            ScenarioInfo.M2SouthCarrierPassengers = {}
            for i = 1, 5 do
                units = ScenarioUtils.CreateArmyGroup('Seraphim', 'M2_Seraph_SouthCarrier_Units')
                for k, v in units do
                    IssueStop({v})
                    ScenarioInfo.M2SouthCarrier:AddUnitToStorage(v)
                    table.insert(ScenarioInfo.M2SouthCarrierPassengers, v)
                end
            end
            ScenarioFramework.GroupPatrolChain({ScenarioInfo.M2SouthCarrier}, 'M2_Seraph_Carrier_South_Chain')
            ScenarioFramework.CreateAreaTrigger(M2SouthCarrierRelease, ScenarioUtils.AreaToRect('M2_SouthBase_Carrier_Area'), categories.AIR * categories.MOBILE, true, false, ArmyBrains[Player1], 10, false)

            -------------------
            -- Experimental Base
            -------------------
            ScenarioUtils.CreateArmyGroup('Seraphim', 'M2_North_Experimental_Base_D' .. Difficulty)
            units = ArmyBrains[Seraphim]:GetListOfUnits(categories.xsb4302, false)
            if(table.getn(units) > 0) then
                for k, v in units do
                    v:GiveTacticalSiloAmmo(5)
                end
            end

            -------------------
            -- Rhiza's Colossus
            -------------------
            M1RhizaAI.M1RhizaBaseExperimentalAttacks()

            ----------------
            -- Aeon Secondary
            ----------------
            if(LeaderFaction == 'aeon') then
                units = ScenarioUtils.CreateArmyGroup('Princess', 'M2_Priest_Base')
                for k, v in units do
                    v:SetDoNotTarget(true)
                end

                -- Give Princess energy to support the omni
                ForkThread(CheatPrincessEconomy)

                ScenarioInfo.SPriestPlanes = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M2_Seraph_AeonOnly_Defense_D' .. Difficulty, 'GrowthFormation')
                for k, v in ScenarioInfo.SPriestPlanes:GetPlatoonUnits() do
                    ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M2_Seraph_MainSouth_AirDef_Chain')))
                end

                ScenarioInfo.NPriestPlanes = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M2_SeraphNorth_AeonOnly_Defense', 'GrowthFormation')
                for k, v in ScenarioInfo.NPriestPlanes:GetPlatoonUnits() do
                    ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M2_Seraph_MainNorth_AirDef_Chain')))
                end
            end

            ForkThread(IntroMission2NIS)
        end
    )
end

function ColossusPing(platoon)
    local Colossus = ArmyBrains[Rhiza]:GetListOfUnits(categories.ual0401, false)

    ScenarioInfo.RhizaColossus = Colossus[1]
    ScenarioInfo.ColossusPing = PingGroups.AddPingGroup(OpStrings.X03_M01_PNG_010_010, 'ual0401', 'move', OpStrings.X03_M01_PNG_010_015)
    ScenarioInfo.ColossusPing:AddCallback(ColossusPingActivate)

    ScenarioFramework.CreateUnitDestroyedTrigger(ColossusDead, ScenarioInfo.RhizaColossus)

end

function ColossusPingActivate(location)
    IssueStop({ScenarioInfo.RhizaColossus})
    IssueClearCommands({ScenarioInfo.RhizaColossus})
    IssueMove({ScenarioInfo.RhizaColossus}, location)
end

function ColossusDead()
    ScenarioInfo.ColossusPing:Destroy()
end

function CheatPrincessEconomy()
    ArmyBrains[Princess]:GiveStorage('ENERGY', 200000)
    while(ScenarioInfo.MissionNumber == 2) do
        ArmyBrains[Princess]:GiveResource('ENERGY', 200000)
        WaitSeconds(10)
    end
end

function M2NorthCarrierRelease()
    ForkThread(
        function()
            if(ScenarioInfo.M2NorthCarrier and not ScenarioInfo.M2NorthCarrier:IsDead() and ScenarioInfo.M2NorthCarrierPassengers) then
                IssueClearCommands({ScenarioInfo.M2NorthCarrier})
                IssueTransportUnload({ScenarioInfo.M2NorthCarrier}, ScenarioInfo.M2NorthCarrier:GetPosition())
                WaitSeconds(5)
                ScenarioFramework.GroupPatrolChain({ScenarioInfo.M2NorthCarrier}, 'M2_Seraph_Carrier_North_Chain')
                for k,v in ScenarioInfo.M2NorthCarrierPassengers do
                    if(v and not v:IsDead()) then
                        IssueClearCommands({v})
                        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M2_Seraph_MainNorth_AirDef_Chain')))
                    end
                end
                WaitSeconds(30)
                ScenarioFramework.CreateAreaTrigger(M2NorthCarrierLoad, ScenarioUtils.AreaToRect('M2_NorthBase_Carrier_Area'), categories.AIR * categories.MOBILE, true, true, ArmyBrains[Player1])
            end
        end
    )
end

function M2NorthCarrierLoad()
    if(ScenarioInfo.M2NorthCarrier and not ScenarioInfo.M2NorthCarrier:IsDead() and ScenarioInfo.M2NorthCarrierPassengers) then
        IssueClearCommands({ScenarioInfo.M2NorthCarrier})
        for k,v in ScenarioInfo.M2NorthCarrierPassengers do
            if(v and not v:IsDead() and not v:IsUnitState('Attached')) then
                IssueClearCommands({v})
                IssueTransportLoad({v}, ScenarioInfo.M2NorthCarrier)
            end
        end
        ScenarioFramework.GroupPatrolChain({ScenarioInfo.M2NorthCarrier}, 'M2_Seraph_Carrier_North_Chain')
        ScenarioFramework.CreateAreaTrigger(M2NorthCarrierRelease, ScenarioUtils.AreaToRect('M2_NorthBase_Carrier_Area'), categories.AIR * categories.MOBILE, true, false, ArmyBrains[Player1], 10, false)
    end
end

function M2SouthCarrierRelease()
    ForkThread(
        function()
            if(ScenarioInfo.M2SouthCarrier and not ScenarioInfo.M2SouthCarrier:IsDead() and ScenarioInfo.M2SouthCarrierPassengers) then
                IssueClearCommands({ScenarioInfo.M2SouthCarrier})
                IssueTransportUnload({ScenarioInfo.M2SouthCarrier}, ScenarioInfo.M2SouthCarrier:GetPosition())
                WaitSeconds(5)
                ScenarioFramework.GroupPatrolChain({ScenarioInfo.M2SouthCarrier}, 'M2_Seraph_Carrier_South_Chain')
                for k,v in ScenarioInfo.M2SouthCarrierPassengers do
                    if(v and not v:IsDead()) then
                        IssueClearCommands({v})
                        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M2_Seraph_MainSouth_AirDef_Chain')))
                    end
                end
                WaitSeconds(30)
                ScenarioFramework.CreateAreaTrigger(M2SouthCarrierLoad, ScenarioUtils.AreaToRect('M2_SouthBase_Carrier_Area'), categories.AIR * categories.MOBILE, true, true, ArmyBrains[Player1])
            end
        end
    )
end

function M2SouthCarrierLoad()
    if(ScenarioInfo.M2SouthCarrier and not ScenarioInfo.M2SouthCarrier:IsDead() and ScenarioInfo.M2SouthCarrierPassengers) then
        IssueClearCommands({ScenarioInfo.M2SouthCarrier})
        for k,v in ScenarioInfo.M2SouthCarrierPassengers do
            if(v and not v:IsDead() and not v:IsUnitState('Attached')) then
                IssueClearCommands({v})
                IssueTransportLoad({v}, ScenarioInfo.M2SouthCarrier)
            end
        end
        ScenarioFramework.GroupPatrolChain({ScenarioInfo.M2SouthCarrier}, 'M2_Seraph_Carrier_South_Chain')
        ScenarioFramework.CreateAreaTrigger(M2SouthCarrierRelease, ScenarioUtils.AreaToRect('M2_SouthBase_Carrier_Area'), categories.AIR * categories.MOBILE, true, false, ArmyBrains[Player1], 10, false)
    end
end

function IntroMission2NIS()
    ScenarioFramework.SetPlayableArea('M2_Playable_Area', false)

    -- Get those engineers building the bombers, guaranteed
    ArmyBrains[Seraphim]:PBMSetCheckInterval(2)

    local AllShieldUnits = ArmyBrains[Seraphim]:GetListOfUnits(categories.SHIELD, false)

    ForkThread(ShieldToggle, AllShieldUnits, false, false)

    local VisMarker = ScenarioFramework.CreateVisibleAreaLocation(75, ScenarioUtils.MarkerToPosition('M2_Seraph_Exper_Base'), 0, ArmyBrains[Player1])
    ScenarioFramework.CreateVisibleAreaLocation(50, ScenarioUtils.MarkerToPosition('M2_Resource_Base'), 0.1, ArmyBrains[Player1])

    Cinematics.EnterNISMode()
    Cinematics.SetInvincible('M1_Playable_Area')

    WaitSeconds(3.5)

    ScenarioFramework.Dialogue(OpStrings.X03_M02_016, nil, true)
    ScenarioFramework.Dialogue(OpStrings.X03_M02_017, nil, true)

    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_2_1'), 0)
    WaitSeconds(1)
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_2_2'), 7)
    WaitSeconds(1)

    -- Set it back to the default
    ArmyBrains[Seraphim]:PBMSetCheckInterval(13)

    -- Look north
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_2_3'), 4)
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_2_4'), 3)
    WaitSeconds(1)
    ScenarioFramework.Dialogue(OpStrings.X03_M02_018, nil, true)
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_2_5'), 5)
    WaitSeconds(2)
    -- Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_2_6'), 3)
    Cinematics.CameraTrackEntity(ScenarioInfo.PlayerCDR, 40, 4)
    VisMarker:Destroy()

    local fakeMarker1 = {
        ['zoom'] = FLOAT(140),
        ['canSetCamera'] = BOOLEAN(true),
        ['canSyncCamera'] = BOOLEAN(true),
        ['color'] = STRING('ff808000'),
        ['editorIcon'] = STRING('/textures/editor/marker_mass.bmp'),
        ['type'] = STRING('Camera Info'),
        ['prop'] = STRING('/env/common/props/markers/M_Camera_prop.bp'),
        ['orientation'] = VECTOR3(-3.14159, 1.19772, 0),
        ['position'] = ScenarioInfo.PlayerCDR:GetPosition(),
    }
    Cinematics.CameraMoveToMarker(fakeMarker1, 1.5)

    -- WaitSeconds(1)

    ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('M2_Seraph_Exper_Base'), 80)
    ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('M2_Resource_Base'), 80)
    Cinematics.SetInvincible('M1_Playable_Area', true)
    Cinematics.ExitNISMode()

    ForkThread(ShieldToggle, AllShieldUnits, true, true)

    StartMission2()

    WaitSeconds(1)
    ScenarioFramework.ClearIntel( ScenarioUtils.MarkerToPosition('M2_Seraph_Exper_Base'), 100 )
end

function ShieldToggle( ShieldUnits, ToggleOn, Wait )
    if Wait then
        WaitSeconds(5)
    end
    for k, unit in ShieldUnits do
        if unit and not unit:IsDead() then
            if ToggleOn then
                unit:EnableShield()
            else
                unit:DisableShield()
            end
        end
    end
end

function StartMission2()
    local bombers = {}
    for k, v in ScenarioInfo.ExperimentalEngineers do
        if(v and not v:IsDead()) then
            table.insert(bombers, v.UnitBeingBuilt)
        end
    end

    ----------------------------------------------------
    -- Primary Objective 1 - Destroy Experimental Bombers
    ----------------------------------------------------
    ScenarioInfo.M2P1 = Objectives.KillOrCapture(
        'primary',                      -- type
        'incomplete',                   -- status
        OpStrings.X03_M02_OBJ_010_010,  -- title
        OpStrings.X03_M02_OBJ_010_020,  -- description
        {                               -- target
            FlashVisible = true,
            -- Units = ScenarioInfo.ExperimentalEngineers,
            Units = bombers,
        }
    )
    for k, v in ScenarioInfo.ExperimentalEngineers do
        ScenarioFramework.CreateUnitDestroyedTrigger(M2ExperimentalEngineerDeath, v)
    end
    ScenarioInfo.M2P1:AddResultCallback(
        function(result)
            if(result) then
                ScenarioFramework.Dialogue(OpStrings.X03_M02_300, IntroMission3)
            end
        end
    )
    ScenarioInfo.M2P1:AddProgressCallback(
        function()
            ScenarioInfo.NumBombersDestroyed = ScenarioInfo.NumBombersDestroyed + 1
        end
    )
    table.insert(AssignedObjectives, ScenarioInfo.M2P1)
    ScenarioInfo.M2BomberFirstVOPlayed = false
    ScenarioInfo.M2P1:AddProgressCallback( M2FirstBomberKilled )

    ScenarioFramework.CreateTimerTrigger(M2ResourceBase, 60)
    ScenarioFramework.CreateTimerTrigger(M2PreTechReveal, 130)
    ScenarioFramework.CreateTimerTrigger(M2KaelTaunt, 180)
    ScenarioFramework.CreateTimerTrigger(M2OpticalPingNotification, 240)
    ScenarioFramework.CreateTimerTrigger(M2Subplot, 410)

    if(LeaderFaction == 'aeon') then
        ScenarioFramework.CreateTimerTrigger(M2RevealAeonSecondary, 300)
    end

    -- Cybran Counter-Intelligence Boat
    ScenarioFramework.UnrestrictWithVoiceover(categories.xrs0205, "cybran", OpStrings.X03_M02_011)

    SetupNorthM2Taunts()
    SetupWestM2Taunts()

    ScenarioFramework.CreateTimerTrigger(M2SeraphimUnitCap, 300)
    ScenarioFramework.CreateTimerTrigger(M2RhizaCleanupDialogue, 15)

    -- Warnings for the Bombers
    ScenarioFramework.CreateTimerTrigger(M2BomberWarning1, 300)
    ScenarioFramework.CreateTimerTrigger(M2BomberWarning2, 600)
    ScenarioFramework.CreateTimerTrigger(M2BomberWarning3, 900)
    ScenarioFramework.CreateTimerTrigger(M2BomberWarning4, 1400)
    ScenarioFramework.CreateTimerTrigger(M2BomberWarning5, 1700)
end

function M2RhizaCleanupDialogue()
    if ScenarioInfo.RhizaACU and not ScenarioInfo.RhizaACU:IsDead() then
        ScenarioFramework.Dialogue(OpStrings.X03_M01_220)
    end
end

function M2ExperimentalEngineerDeath(unit)
    local bomber = unit.UnitBeingBuilt
    if(bomber and not bomber:IsDead()) then
        bomber:Kill()
        ScenarioInfo.NumBombersDestroyed = ScenarioInfo.NumBombersDestroyed + 1
    end
end

function M2ExperimentalBomberStarted(unit)
    -- Passed in unit is the experimental bomber; Only called once
    -- Update the objective with the unit here
end

function M2ExperimentalBuildPercentUpdate(percent)
    -- LOG('*DEBUG: Updated Percent = ' .. percent)
end

function M2ExperimentalFinishBuild(unit)
    -- LOG('*DEBUG: Bomber Finished')
    NumBombers = NumBombers + 1
    if(NumBombers + ScenarioInfo.NumBombersDestroyed == 6) then
        ScenarioInfo.M2P1:ManualResult(false)
        ScenarioFramework.FlushDialogueQueue()
        ForkThread( M2PrincessBombedNIS )
    end
end

function M2PrincessBombedNIS()

    ScenarioInfo.M2Ending = true

    -- Create these groups:

    ScenarioUtils.CreateArmyGroup('Princess', 'M3_Princess_Base_D' .. Difficulty)
    ScenarioUtils.CreateArmyGroup('Princess', 'Palace_Buildings')

    WaitSeconds( 0.5 )
    ScenarioFramework.SetPlayableArea('M3_Playable_Area', false)
    Cinematics.EnterNISMode()
    Cinematics.SetInvincible( 'M2_Playable_Area' )

    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_Lose_1'), 0)
    -- Chastise the player
    ScenarioFramework.Dialogue(OpStrings.X03_M02_100, nil, true)
    if (not NumBombers) or NumBombers < 1 or NumBombers > 6 then NumBombers = 6 end
    for i = 1, NumBombers do
        local Bomber
        if i == NumBombers then
            Bomber = ScenarioUtils.CreateArmyUnit('Seraphim', 'Fail_Bomber_South')
            IssueAttack({Bomber}, ScenarioInfo.UnitNames[Princess]['M3_Princess_Palace'])
        elseif i == 1 then
            Bomber = ScenarioUtils.CreateArmyUnit('Seraphim', 'Fail_Bomber_North')
            IssueAttack({Bomber}, ScenarioInfo.UnitNames[Princess]['Princess_Death_Target_' .. i])
            IssueAttack({Bomber}, ScenarioInfo.UnitNames[Princess]['M3_Princess_Palace'])
        elseif i == 2 then
            Bomber = ScenarioUtils.CreateArmyUnit('Seraphim', 'Fail_Bomber_West')
            IssueAttack({Bomber}, ScenarioInfo.UnitNames[Princess]['Princess_Death_Target_' .. i])
            IssueAttack({Bomber}, ScenarioInfo.UnitNames[Princess]['M3_Princess_Palace'])
        elseif i == 3 then
            Bomber = ScenarioUtils.CreateArmyUnit('Seraphim', 'Fail_Bomber_South')
            IssueAttack({Bomber}, ScenarioInfo.UnitNames[Princess]['Princess_Death_Target_' .. i])
            IssueAttack({Bomber}, ScenarioInfo.UnitNames[Princess]['M3_Princess_Palace'])
        elseif i == 4 then
            Bomber = ScenarioUtils.CreateArmyUnit('Seraphim', 'Fail_Bomber_North')
            IssueAttack({Bomber}, ScenarioInfo.UnitNames[Princess]['Princess_Death_Target_' .. i])
            IssueAttack({Bomber}, ScenarioInfo.UnitNames[Princess]['M3_Princess_Palace'])
        elseif i == 5 then
            Bomber = ScenarioUtils.CreateArmyUnit('Seraphim', 'Fail_Bomber_West')
            IssueAttack({Bomber}, ScenarioInfo.UnitNames[Princess]['Princess_Death_Target_' .. i])
            IssueAttack({Bomber}, ScenarioInfo.UnitNames[Princess]['M3_Princess_Palace'])
        end
        -- Move them out of the way afterwards
        IssueMove({Bomber}, ScenarioUtils.MarkerToPosition('M3_Seraph_AirDef_5'))
        WaitSeconds(0.5)
    end

    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_Lose_2'), 5)

    ScenarioInfo.OpEnded = false
    ForkThread( PlayerLosePrincess )

    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_Lose_3'), 25)
end

function M2ResourceBase()
    -- ScenarioFramework.Dialogue(OpStrings.X03_M02_013)
end

function M2PreTechReveal()
    -- tech dialogue, dramatic slight pause before a bit more VO and the reveal

    -- UEF Torpedo Boat, Cybran Sub Killer, and Aeon Submarine Hunter
    ScenarioFramework.UnrestrictWithVoiceoverAndDelay(categories.xes0102, "uef", 3, OpStrings.X03_M02_022)
    ScenarioFramework.UnrestrictWithVoiceoverAndDelay(categories.xrs0204, "cybran", 3, OpStrings.X03_M02_023)
    ScenarioFramework.UnrestrictWithVoiceoverAndDelay(categories.xas0204, "aeon", 3, OpStrings.X03_M02_024)

    ScenarioFramework.Dialogue(OpStrings.X03_M02_021)
end

function M2KaelTaunt()
    ScenarioFramework.Dialogue(OpStrings.X03_M02_015)
end

function M2OpticalPingNotification()
    ScenarioFramework.Dialogue(OpStrings.X03_M02_025, M2OpticalPing)
end

function M2OpticalPing()
    if(ScenarioInfo.MissionNumber == 2) then
        ScenarioInfo.M2OpticalPing = PingGroups.AddPingGroup(OpStrings.X03_M01_OBJ_010_030, 'xab3301', 'alert', OpStrings.X03_M01_OBJ_010_035)
        ScenarioInfo.M2OpticalPing:AddCallback(M2ActivateEye)
    end
end

function M2ActivateEye(location)
    ScenarioFramework.CreateVisibleAreaLocation(45, location, 20, ArmyBrains[Player1])
    ScenarioFramework.CreateTimerTrigger(M2OpticalPing, 240)

    ScenarioInfo.M2OpticalPing:Destroy()
end

function M2RevealAeonSecondary()
    ScenarioFramework.Dialogue(OpStrings.X03_M02_120, M2AssignAeonSecondary)
end

function M2AssignAeonSecondary()
    ScenarioInfo.Priests = ScenarioUtils.CreateArmyUnit('Princess', 'M2_Priest_Boat')
    ScenarioInfo.Priests:SetDoNotTarget(true)
    ScenarioFramework.CreateUnitDeathTrigger(PriestsKilled, ScenarioInfo.Priests)

    -------------------------------------------------
    -- Aeon Secondary Objective 1 - Rescue the Priests
    -------------------------------------------------
    ScenarioInfo.M2S1Aeon = Objectives.Basic(
        'secondary',                    -- type
        'incomplete',                   -- status
        OpStrings.X03_M02_OBJ_020_010,  -- title
        OpStrings.X03_M02_OBJ_020_020,  -- description
        'move',
        {                               -- target
            Area = 'M2_Priest_Destination_Area',
            MarkArea = true,
            Units = {ScenarioInfo.Priests},
            MarkUnits = true,
        }
    )
    table.insert(AssignedObjectives, ScenarioInfo.M2S1Aeon)
    ScenarioFramework.CreateTimerTrigger(M2S1AeonReminder1, 1200)

    ScenarioFramework.CreateUnitToMarkerDistanceTrigger(PriestsRescued, ScenarioInfo.Priests, ScenarioUtils.MarkerToPosition('M2_Priest_Destination_Marker'), 20)

    SetupPrincM2Taunts()

    -- Setup ping
    ScenarioInfo.M2PriestPing = PingGroups.AddPingGroup(OpStrings.X03_M01_OBJ_010_040, 'xac0101', 'move', OpStrings.X03_M01_OBJ_010_045)
    ScenarioInfo.M2PriestPing:AddCallback(MovePriests)
end

function PriestsKilled()
    if(ScenarioInfo.M2S1Aeon.Active) then
        ScenarioInfo.M2S1Aeon:ManualResult(false)
        ScenarioFramework.Dialogue(OpStrings.X03_M02_170)
    end
    if(ScenarioInfo.M2PriestPing) then
        ScenarioInfo.M2PriestPing:Destroy()
    end
    if(ScenarioInfo.SPriestPlanes and ArmyBrains[Seraphim]:PlatoonExists(ScenarioInfo.SPriestPlanes)) then
        for k, v in ScenarioInfo.SPriestPlanes:GetPlatoonUnits() do
            if(v and not v:IsDead()) then
                IssueStop({v})
                IssueClearCommands({v})
                ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M2_Seraph_MainNorth_AirDef_Chain')))
            end
        end
    end
    if(ScenarioInfo.NPriestPlanes and ArmyBrains[Seraphim]:PlatoonExists(ScenarioInfo.NPriestPlanes)) then
        for k, v in ScenarioInfo.NPriestPlanes:GetPlatoonUnits() do
            if(v and not v:IsDead()) then
                IssueStop({v})
                IssueClearCommands({v})
                ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M2_Seraph_MainNorth_AirDef_Chain')))
            end
        end
    end
end

function PriestsRescued()
    ScenarioFramework.Dialogue(OpStrings.X03_M02_160)

    if(ScenarioInfo.M2S1Aeon.Active) then
        ScenarioInfo.M2S1Aeon:ManualResult(true)
    end
    if(ScenarioInfo.M2PriestPing) then
        ScenarioInfo.M2PriestPing:Destroy()
    end

    if(ScenarioInfo.SPriestPlanes and ArmyBrains[Seraphim]:PlatoonExists(ScenarioInfo.SPriestPlanes)) then
        for k, v in ScenarioInfo.SPriestPlanes:GetPlatoonUnits() do
            if(v and not v:IsDead()) then
                IssueStop({v})
                IssueClearCommands({v})
                ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M2_Seraph_MainNorth_AirDef_Chain')))
            end
        end
    end
    if(ScenarioInfo.NPriestPlanes and ArmyBrains[Seraphim]:PlatoonExists(ScenarioInfo.NPriestPlanes)) then
        for k, v in ScenarioInfo.NPriestPlanes:GetPlatoonUnits() do
            if(v and not v:IsDead()) then
                IssueStop({v})
                IssueClearCommands({v})
                ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M2_Seraph_MainNorth_AirDef_Chain')))
            end
        end
    end

    ForkThread(
        function()
            if(ScenarioInfo.Priests and not ScenarioInfo.Priests:IsDead()) then
                local cmd = IssueMove({ScenarioInfo.Priests}, ScenarioUtils.MarkerToPosition('M2_Priest_Offmap_Marker'))
                while(not IsCommandDone(cmd)) do
                    WaitSeconds(1)
                end
                if(ScenarioInfo.Priests and not ScenarioInfo.Priests:IsDead()) then
                    ScenarioInfo.Priests:Destroy()
                end
            end
        end
    )

    ScenarioInfo.M2PriestRewardPing = PingGroups.AddPingGroup(OpStrings.X03_M01_OBJ_010_050, nil, 'attack', OpStrings.X03_M01_OBJ_010_055)
    ScenarioInfo.M2PriestRewardPing:AddCallback(PriestReward)
    ScenarioFramework.Dialogue(OpStrings.X03_M02_210)
end

function MovePriests(location)
    if(ScenarioInfo.Priests and not ScenarioInfo.Priests:IsDead()) then
        ScenarioInfo.Priests:SetDoNotTarget(false)
        IssueStop({ScenarioInfo.Priests})
        IssueClearCommands({ScenarioInfo.Priests})
        IssueMove({ScenarioInfo.Priests}, location)
    end

    AttackPriests()
end

function AttackPriests()
    if(not ScenarioInfo.PriestsAttacked) then
        ScenarioInfo.PriestsAttacked = true

        if(ScenarioInfo.SPriestPlanes and ArmyBrains[Seraphim]:PlatoonExists(ScenarioInfo.SPriestPlanes)) then
            for k, v in ScenarioInfo.SPriestPlanes:GetPlatoonUnits() do
                if(v and not v:IsDead()) then
                    IssueStop({v})
                    IssueClearCommands({v})
                    IssueAttack({v}, ScenarioInfo.Priests)
                end
            end
        end

        if(ScenarioInfo.NPriestPlanes and ArmyBrains[Seraphim]:PlatoonExists(ScenarioInfo.NPriestPlanes)) then
            for k, v in ScenarioInfo.NPriestPlanes:GetPlatoonUnits() do
                if(v and not v:IsDead()) then
                    IssueStop({v})
                    IssueClearCommands({v})
                    IssueAttack({v}, ScenarioInfo.Priests)
                end
            end
        end
    end
end

function PriestReward(location)
    ScenarioInfo.M2RewardUsed = true
    ScenarioInfo.M2PriestRewardPing:Destroy()

    local radius = 15

    ScenarioFramework.CreateVisibleAreaLocation(radius, location, 30, ArmyBrains[Player1])

    ForkThread(
        function()
            local enemies = ArmyBrains[Seraphim]:GetUnitsAroundPoint(categories.ALLUNITS, location, radius)
            if(enemies) then
                for k,v in enemies do
                    v:SetAllWeaponsEnabled(false)
                end
                WaitSeconds(30)
                for k,v in enemies do
                    if(v and not v:IsDead()) then
                        v:SetAllWeaponsEnabled(true)
                    end
                end
            end
        end
    )
end

function M2Subplot()
    if(LeaderFaction == 'uef') then
        ScenarioFramework.Dialogue(OpStrings.X03_M02_116)
    elseif(LeaderFaction == 'cybran') then
        ScenarioFramework.Dialogue(OpStrings.X03_M02_117)
    end
end

function M2SeraphimUnitCap()
    SetArmyUnitCap(Seraphim, 550)
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

            -- Experimental taunts from m2 turned off, incase some engineers were left
            ExperimentalTM:Activate(false)

            -- Remove optical ping
            if(ScenarioInfo.M2OpticalPing) then
                ScenarioInfo.M2OpticalPing:Destroy()
            end

            -- Crystals
            ScenarioUtils.CreateArmyGroup('Crystals', 'M3_Crystals')

            -- Wreckage
            ScenarioUtils.CreateArmyGroup('Princess', 'M3_Wreckage', true)

            ----------------
            -- Seraphim M3 AI
            ----------------
            M3SeraphimAI.SeraphimM3MiniBasesAI()
            M3SeraphimAI.SeraphimM3SouthBaseAI()
            ScenarioUtils.CreateArmyGroup('Seraphim', 'M3_Seraph_North_D' .. Difficulty)

            --------------------------
            -- Seraphim Initial Patrols
            --------------------------

            units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M3_SeraphNorth_Init_LandDef_D' .. Difficulty, 'AttackFormation')
            for k, v in units:GetPlatoonUnits() do
                ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M3_Seraph_North_LandDef_Chain')))
            end

            units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M3_SeraphNorth_Init_AirDef_D' .. Difficulty, 'GrowthFormation')
            for k, v in units:GetPlatoonUnits() do
                ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M3_Seraph_North_AirDef_Chain')))
            end

            units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M3_SeraphSouth_Init_AirDef_D' .. Difficulty, 'GrowthFormation')
            for k, v in units:GetPlatoonUnits() do
                ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M3_Seraph_South_AirDef_Chain')))
            end

            units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M3_SeraphSouth_Init_NavalDef_D' .. Difficulty, 'AttackFormation')
            for k, v in units:GetPlatoonUnits() do
                ScenarioFramework.GroupPatrolChain({v}, 'M3_Seraph_South_NavalDef_Chain')
            end

            units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M3_Seraph_NavalMid_D' .. Difficulty, 'AttackFormation')
            for k, v in units:GetPlatoonUnits() do
                ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M3_Seraph_NavalMid_Chain')))
            end

            units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M3_Seraph_NavalSouth_D' .. Difficulty, 'AttackFormation')
            for k, v in units:GetPlatoonUnits() do
                ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M3_Seraph_NavalSouth_Chain')))
            end

            units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M3_Seraph_NavalNW_D' .. Difficulty, 'AttackFormation')
            for k, v in units:GetPlatoonUnits() do
                ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M3_Seraph_NavalNW_Chain')))
            end

            units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M3_Seraph_NavalSW_D' .. Difficulty, 'AttackFormation')
            for k, v in units:GetPlatoonUnits() do
                ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M3_Seraph_NavalSW_Chain')))
            end

            --------------------------
            -- Seraphim Initial Attacks
            --------------------------
            for i = 1, 3 do
                units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M3_SeraphNorth_Init_Stream' .. i, 'AttackFormation')
                for k, v in units:GetPlatoonUnits() do
                    IssueMove({v}, ScenarioUtils.MarkerToPosition('M3_Seraph_Stream' .. i .. '_Marker'))
                end
            end

            units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M3_StreamNorth_Init_Air', 'GrowthFormation')
            ScenarioFramework.PlatoonPatrolChain(units, 'M3_Seraph_North_AirAttack_Chain')

            units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M3_SeraphSouth_Init_AirAttack_D' .. Difficulty, 'GrowthFormation')
            for k, v in units:GetPlatoonUnits() do
                ScenarioFramework.GroupMoveChain({v}, 'M3_Seraph_InitAir_Chain')
            end

            ---------------
            -- Seraphim ACUs
            ---------------
            ScenarioInfo.NorthACU = ScenarioFramework.SpawnCommander('Seraphim', 'M3_Seraphim_ACU_North', false, LOC '{i ZanAishahesh}', false, NorthACUDestroyed, 
                {'BlastAttack', 'DamageStabilization', 'DamageStabilizationAdvanced', 'RateOfFire'})
            ScenarioInfo.NorthACU:SetCapturable(false)
            ScenarioInfo.NorthACU:SetReclaimable(false)
            ScenarioFramework.GroupPatrolChain({ScenarioInfo.NorthACU}, 'M3_SeraphNorth_CDRPatrol_Chain')
            ZanNorthTM:AddTauntingCharacter(ScenarioInfo.NorthACU)
            PrincNorthTM:AddTauntingCharacter(ScenarioInfo.NorthACU)

            ScenarioInfo.WestACU = ScenarioFramework.SpawnCommander('Seraphim', 'M3_Seraphim_ACU_South', false, LOC '{i ThelUuthow}', false, false,
                {'BlastAttack', 'DamageStabilization', 'DamageStabilizationAdvanced', 'RateOfFire'})
            ScenarioInfo.WestACU:SetCanBeKilled(false)
            ScenarioInfo.WestACU:SetCapturable(false)
            ScenarioInfo.WestACU:SetReclaimable(false)
            ScenarioFramework.CreateUnitDamagedTrigger(WestACUWarp, ScenarioInfo.WestACU, .8)
            ThelWestTM:AddTauntingCharacter(ScenarioInfo.WestACU)
            PrincWestTM:AddTauntingCharacter(ScenarioInfo.WestACU)

            ----------------
            -- Princess M3 AI
            ----------------
            M3PrincessAI.PrincessBaseAI()

            --------------------------
            -- Princess Initial Patrols
            --------------------------
            units = ScenarioUtils.CreateArmyGroupAsPlatoon('Princess', 'M3_Princess_Init_AirDef_D' .. Difficulty, 'GrowthFormation')
            for k, v in units:GetPlatoonUnits() do
                ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M3_Princess_AirDef_Chain')))
            end

            -----------------
            -- Princess Palace
            -----------------
            ScenarioUtils.CreateArmyGroup('Princess', 'Palace_Buildings')
            for i = 1, 4 do
                ScenarioUtils.CreateArmyGroup('Princess', 'M3_Princess_Line_' .. i .. '_D' .. Difficulty)
            end
            ScenarioUtils.CreateArmyGroup('Princess', 'M3_Princess_Defense_D' .. Difficulty)

            ForkThread(IntroMission3NIS)
        end
    )
end

function IntroMission3NIS()
    ScenarioFramework.SetPlayableArea('M3_Playable_Area', false)

    Cinematics.EnterNISMode()
    Cinematics.SetInvincible( 'M2_Playable_Area' )

    -- Turn off her shields for more visibility during the NIS
    local AllShieldUnits = ArmyBrains[Princess]:GetListOfUnits(categories.SHIELD, false)
    ForkThread( ShieldToggle, AllShieldUnits, false, false )

    WaitSeconds(1)
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_3_1'), 0)
    ScenarioFramework.Dialogue(OpStrings.X03_M03_240, nil, true)
    ScenarioFramework.Dialogue(OpStrings.X03_M03_250, nil, true)
    WaitSeconds(1)
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_3_2'), 9)
    WaitSeconds(1)

    ScenarioFramework.Dialogue(OpStrings.X03_M03_260, nil, true)

    local GroundUnits = ScenarioUtils.CreateArmyGroup('Seraphim', 'M3_NIS')
    IssueMove( GroundUnits, ScenarioUtils.MarkerToPosition('M3_Rhiza_AirAttack_9'))

    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_3_3_2'), 5)
    ForkThread( ShieldToggle, AllShieldUnits, true, false )
    WaitSeconds(2)

    ScenarioFramework.Dialogue(OpStrings.X03_M03_270, nil, true)
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_3_4'), 4)

    Cinematics.SetInvincible( 'M2_Playable_Area', true )
    Cinematics.ExitNISMode()

    for k, unit in GroundUnits do
        if unit and not unit:IsDead() then
            unit:Kill()
        end
    end

    ScenarioFramework.Dialogue(OpStrings.X03_M03_280)
    StartMission3()
end

function StartMission3()

    ---------------------------------------
    -- Primary Objective 1 - Defeat the ACUs
    ---------------------------------------
    ScenarioInfo.M3P1 = Objectives.KillOrCapture(
        'primary',                      -- type
        'incomplete',                   -- status
        OpStrings.X03_M03_OBJ_010_010,  -- title
        OpStrings.X03_M03_OBJ_010_020,  -- description
        {                               -- target
            Units = {ScenarioInfo.NorthACU, ScenarioInfo.WestACU},
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
    ScenarioFramework.CreateTimerTrigger(M3Reminder1, 1000)

    ScenarioInfo.PrincessPalace = ScenarioInfo.UnitNames[Princess]['M3_Princess_Palace']
    ScenarioInfo.PrincessPalace:SetReclaimable(false)
    ScenarioInfo.PrincessPalace:SetCapturable(false)
    ScenarioFramework.PauseUnitDeath(ScenarioInfo.PrincessPalace)

    ------------------------------------------
    -- Primary Objective 3 - Protect the Palace
    ------------------------------------------
    ScenarioInfo.M3P3 = Objectives.Protect(
        'primary',                      -- type
        'incomplete',                   -- status
        OpStrings.X03_M03_OBJ_010_050,  -- title
        OpStrings.X03_M03_OBJ_010_060,  -- description
        {                               -- target
            Units = {ScenarioInfo.PrincessPalace},
        }
    )
    ScenarioInfo.M3P3:AddResultCallback(
        function(result)
            if(result == false) then
                PlayerLosePrincess()
            end
        end
    )
    table.insert(AssignedObjectives, ScenarioInfo.M3P3)

    ScenarioFramework.CreateTimerTrigger(M3Crystals, 50)

    if(LeaderFaction == 'cybran') then
        ScenarioFramework.CreateTimerTrigger(M3Subplot, 300)
    end

    ScenarioFramework.CreateTimerTrigger(M3RhizaCleanupDialogue, 15)

    -- Taunts, warnings, tech reveal:
    ScenarioInfo.M3_Taunt1_Unit = ScenarioInfo.UnitNames[Princess]['M3_Taunt1_Unit']
    ScenarioInfo.M3_Taunt2_Unit = ScenarioInfo.UnitNames[Princess]['M3_Taunt2_Unit']
    ScenarioInfo.M3_Taunt3_Unit = ScenarioInfo.UnitNames[Princess]['M3_Taunt3_Unit']
    ScenarioInfo.M3_Taunt4_Unit = ScenarioInfo.UnitNames[Princess]['M3_Taunt4_Unit']
    ScenarioInfo.M3_Taunt5_Unit = ScenarioInfo.UnitNames[Princess]['M3_Taunt5_Unit']

    ScenarioFramework.CreateUnitDamagedTrigger(M3PrincessWarning5, ScenarioInfo.PrincessPalace, .01)
    ScenarioFramework.CreateUnitDeathTrigger(M3PrincessWarning3, ScenarioInfo.M3_Taunt3_Unit) -- warning 3 and 4 should play no matter what, instead of using taunt system
    ScenarioFramework.CreateUnitDeathTrigger(M3PrincessWarning4, ScenarioInfo.M3_Taunt4_Unit)
    ScenarioFramework.CreateUnitDeathTrigger(M3PrincessWarning6, ScenarioInfo.M3_Taunt5_Unit)

    SetupPrincM3Taunts()
    SetupNorthM3Taunts()
    SetupWestM3Taunts()

    ScenarioFramework.UnrestrictWithVoiceoverAndDelay(categories.xes0307, "uef", 15, OpStrings.X03_M02_220)
    ScenarioFramework.UnrestrictWithVoiceoverAndDelay(categories.xas0306, "aeon", 15, OpStrings.X03_M02_230)
end

function NorthACUDestroyed()
    ScenarioFramework.Dialogue(OpStrings.X03_M03_160, nil, true)
    if(ScenarioInfo.WestACUWarp) then
        ScenarioInfo.M3P1:ManualResult(true)
    end
end

function WestACUWarp()
    ScenarioInfo.WestACUWarp = true
    ScenarioFramework.Dialogue(OpStrings.TAUNT34)
    ScenarioFramework.Dialogue(OpStrings.X03_M03_200, nil, true)
    ForkThread(
        function()
            ScenarioFramework.FakeTeleportUnit(ScenarioInfo.WestACU, true)
        end
    )
    if(ScenarioInfo.NorthACU and not ScenarioInfo.NorthACU:IsDead()) then
        Objectives.UpdateObjective(OpStrings.X03_M03_OBJ_010_010, 'Progress', '(1/2)', ScenarioInfo.M3P1.Tag )
        ScenarioInfo.M3P1:OnProgress(1, 2)
    else
        ScenarioInfo.M3P1:ManualResult(true)
    end
    M3SeraphimAI.DisableBase()
end

function M3RhizaCleanupDialogue()
    if ScenarioInfo.RhizaACU and not ScenarioInfo.RhizaACU:IsDead() then
        ScenarioFramework.Dialogue(OpStrings.X03_M01_230)
    end
end

function M3PrincessWarning3()
    ScenarioFramework.Dialogue(OpStrings.X03_M03_080)
end

function M3PrincessWarning4()
    ScenarioFramework.Dialogue(OpStrings.X03_M03_090)
end

function M3PrincessWarning5()
    ScenarioFramework.Dialogue(OpStrings.X03_M03_201)
end

function M3PrincessWarning6()
    ScenarioFramework.Dialogue(OpStrings.X03_M03_204)
end

function M3Crystals()
    if LeaderFaction == 'cybran' or LeaderFaction == 'uef' then
        ScenarioFramework.Dialogue(OpStrings.X03_M03_020)
    end

    -- Aeon Quantum Optics Device
    ScenarioFramework.UnrestrictWithVoiceover(categories.xab3301, "aeon", OpStrings.X03_M03_025)
end

function M3Subplot()
    ScenarioFramework.Dialogue(OpStrings.X03_M03_015)
end

---------------------
-- Objective Reminders
---------------------
function M1P1Reminder1()
    if(ScenarioInfo.M1P1.Active) then
        ScenarioFramework.Dialogue(OpStrings.X03_M01_200)
        ScenarioFramework.CreateTimerTrigger(M1P1Reminder2, 2500)
    end
end

function M1P1Reminder2()
    if(ScenarioInfo.M1P1.Active) then
        ScenarioFramework.Dialogue(OpStrings.X03_M01_210)
    end
end

function M2S1AeonReminder1()
    if(ScenarioInfo.M2S1Aeon.Active) then
        ScenarioFramework.Dialogue(OpStrings.X03_M02_180)
        ScenarioFramework.CreateTimerTrigger(M2S1AeonReminder2, 1700)
    end
end

function M2S1AeonReminder2()
    if(ScenarioInfo.M2S1Aeon.Active) then
        ScenarioFramework.Dialogue(OpStrings.X03_M02_190)
    end
end

function M3Reminder1()
    if(ScenarioInfo.M3P1.Active) then
        ScenarioFramework.Dialogue(OpStrings.X03_M03_124)
        ScenarioFramework.CreateTimerTrigger(M3Reminder2, 1900)
    end
end

function M3Reminder2()
    if(ScenarioInfo.M3P1.Active) then
        ScenarioFramework.Dialogue(OpStrings.X03_M03_125)
    end
end

 -- bomber updates
function M2BomberWarning1()
    if (ScenarioInfo.M2P1.Active) then
        ScenarioFramework.Dialogue(OpStrings.X03_M02_060)   -- If they get in the air...
    end
end

function M2BomberWarning2()
    if (ScenarioInfo.M2P1.Active) then
        ScenarioFramework.Dialogue(OpStrings.X03_M02_019)   -- We must destroy
    end
end

function M2BomberWarning3()
    if (ScenarioInfo.M2P1.Active) then
        ScenarioFramework.Dialogue(OpStrings.X03_M02_070)   -- halfway
    end
end

function M2BomberWarning4()
    if (ScenarioInfo.M2P1.Active) then
        ScenarioFramework.Dialogue(OpStrings.X03_M02_080)   -- nearly finished
    end
end

function M2BomberWarning5()
    if (ScenarioInfo.M2P1.Active) then
        ScenarioFramework.Dialogue(OpStrings.X03_M02_081)   -- last chance
    end
end

-------
-- Taunts
-------

-- M1
function SetupNorthM1Taunts()
    ZanNorthTM:AddUnitKilledTaunt('TAUNT22', ScenarioInfo.UnitNames[Seraphim]['M1_Seraph_West_AC'])
    ZanNorthTM:AddUnitsKilledTaunt('TAUNT31', ArmyBrains[Seraphim], categories.FACTORY * categories.AIR, 2)
    ZanNorthTM:AddUnitsKilledTaunt('TAUNT28', ArmyBrains[Player1], categories.STRUCTURE * categories.TECH3, 3)
    ZanNorthTM:AddUnitsKilledTaunt('TAUNT33', ArmyBrains[Player1], categories.TECH2 * categories.AIR, 40)
end

function SetupWestM1Taunts()
    ThelWestTM:AddUnitKilledTaunt('TAUNT3', ScenarioInfo.UnitNames[Seraphim]['M1_Seraph_East_AC'])
    ThelWestTM:AddUnitsKilledTaunt('TAUNT4', ArmyBrains[Seraphim], categories.FACTORY * categories.NAVAL, 6)
    ThelWestTM:AddUnitsKilledTaunt('TAUNT7', ArmyBrains[Rhiza], categories.FACTORY * categories.AIR, 1)
    ThelWestTM:AddUnitsKilledTaunt('TAUNT8', ArmyBrains[Player1], categories.TECH2 * categories.NAVAL, 10)
    ThelWestTM:AddDamageTaunt('TAUNT11', ScenarioInfo.PlayerCDR, .02)
end

-- M2
function SetupPrincM2Taunts()
    PrincTM:AddDamageTaunt('X03_M02_140', ScenarioInfo.Priests, .03)     -- Priest boat is damaged by 3 %
    PrincTM:AddDamageTaunt('X03_M02_150', ScenarioInfo.Priests, .65)     -- Priest boat is damaged by 65%
end

function SetupNorthM2Taunts()
    ZanNorthTM:AddEnemiesKilledTaunt('TAUNT24', ArmyBrains[Seraphim], categories.EXPERIMENTAL, 1)
    ZanNorthTM:AddStartBuildTaunt('TAUNT27', ArmyBrains[Player1], categories.EXPERIMENTAL, 1 )
    ZanNorthTM:AddStartBuildTaunt('TAUNT3', ArmyBrains[Player1], categories.EXPERIMENTAL, 2 )
    ZanNorthTM:AddUnitDestroyedTaunt('TAUNT33', ScenarioInfo.UnitNames[Seraphim]['M2_Taunt_Factory'])
    ZanNorthTM:AddUnitsKilledTaunt('TAUNT19', ArmyBrains[Seraphim], categories.NAVAL, 30)
    ZanNorthTM:AddUnitsKilledTaunt('TAUNT21', ArmyBrains[Seraphim], categories.MOBILE * categories.TECH3, 1)
end

function SetupWestM2Taunts()
    ThelWestTM:AddEnemiesKilledTaunt('TAUNT12', ArmyBrains[Seraphim], categories.EXPERIMENTAL, 2)
    ThelWestTM:AddStartBuildTaunt('TAUNT14', ArmyBrains[Player1], categories.EXPERIMENTAL, 4 )
    ThelWestTM:AddStartBuildTaunt('TAUNT16', ArmyBrains[Player1], categories.EXPERIMENTAL, 6 )
    ThelWestTM:AddUnitDestroyedTaunt('TAUNT18', ScenarioInfo.UnitNames[Seraphim]['M2_Taunt_Factory_2'])
    ThelWestTM:AddUnitsKilledTaunt('TAUNT7', ArmyBrains[Seraphim], categories.FACTORY * categories.AIR, 5)
end

function M2FirstBomberKilled()
    -- Play feedback VO that is specific the first bomber killed, and begin normal taunt-feedbacks
    -- (starting them here, so we know the first one to play is the one we want)
    if not ScenarioInfo.M2BomberFirstVOPlayed then
        ScenarioInfo.M2BomberFirstVOPlayed = true
        if (ScenarioInfo.M2P1.Active) then
            ScenarioFramework.Dialogue(OpStrings.X03_M02_240)
            SetupExperM2Taunts()
        end
    end
end

function SetupExperM2Taunts()
    if (ScenarioInfo.ExperimentalEngineers[2] and not ScenarioInfo.ExperimentalEngineers[2]:IsDead()) then
        ExperimentalTM:AddUnitDestroyedTaunt('X03_M02_250', ScenarioInfo.ExperimentalEngineers[2])
    end
    if (ScenarioInfo.ExperimentalEngineers[3] and not ScenarioInfo.ExperimentalEngineers[3]:IsDead()) then
        ExperimentalTM:AddUnitDestroyedTaunt('X03_M02_260', ScenarioInfo.ExperimentalEngineers[3])
    end
    if (ScenarioInfo.ExperimentalEngineers[4] and not ScenarioInfo.ExperimentalEngineers[4]:IsDead()) then
        ExperimentalTM:AddUnitDestroyedTaunt('X03_M02_270', ScenarioInfo.ExperimentalEngineers[4])
    end
    if (ScenarioInfo.ExperimentalEngineers[5] and not ScenarioInfo.ExperimentalEngineers[5]:IsDead()) then
        ExperimentalTM:AddUnitDestroyedTaunt('X03_M02_280', ScenarioInfo.ExperimentalEngineers[5])
    end
    if (ScenarioInfo.ExperimentalEngineers[6] and not ScenarioInfo.ExperimentalEngineers[6]:IsDead()) then
        ExperimentalTM:AddUnitDestroyedTaunt('X03_M02_290', ScenarioInfo.ExperimentalEngineers[6])
    end
end

-- M3
function SetupPrincM3Taunts()
    local northStruct = ArmyBrains[Seraphim]:GetUnitsAroundPoint( categories.STRUCTURE - categories.WALL,
                                  ScenarioUtils.MarkerToPosition('M3_Seraph_Mini_3_BaseMarker'), 70, 'Ally' )
    local westStruct  = ArmyBrains[Seraphim]:GetUnitsAroundPoint( categories.STRUCTURE - categories.WALL,
                                  ScenarioUtils.MarkerToPosition('M3_Seraph_South'), 70, 'Ally' )

    -- North Seraph, base getting damaged encouragement
    PrincNorthTM:AddUnitGroupDeathPercentTaunt('X03_M03_130', northStruct, .25)
    PrincNorthTM:AddUnitGroupDeathPercentTaunt('X03_M03_140', northStruct, .50)
    PrincNorthTM:AddUnitGroupDeathPercentTaunt('X03_M03_150', northStruct, .75)

    -- West Seraph, base getting damaged encouragement
    PrincWestTM:AddUnitGroupDeathPercentTaunt('X03_M03_170', westStruct, .25)
    PrincWestTM:AddUnitGroupDeathPercentTaunt('X03_M03_180', westStruct, .50)
    PrincWestTM:AddUnitGroupDeathPercentTaunt('X03_M03_190', westStruct, .75)

    -- warnings from princess. 2 more are set up without taunt system elsewhere, to guarantee they play.
    PrincTM:AddUnitDestroyedTaunt('X03_M03_060', ScenarioInfo.M3_Taunt1_Unit)
    PrincTM:AddUnitDestroyedTaunt('X03_M03_070', ScenarioInfo.M3_Taunt2_Unit)
end

function SetupNorthM3Taunts()
    ZanNorthTM:AddDamageTaunt('TAUNT22', ScenarioInfo.PlayerCDR, .02)
    ZanNorthTM:AddStartBuildTaunt('TAUNT31', ArmyBrains[Player1], categories.EXPERIMENTAL, 1 )
    if(LeaderFaction == 'uef') then
        ZanNorthTM:AddUnitsKilledTaunt('TAUNT25', ArmyBrains[Player1], categories.STRUCTURE, 7)
    elseif(LeaderFaction == 'cybran') then
        ZanNorthTM:AddUnitsKilledTaunt('TAUNT27', ArmyBrains[Player1], categories.STRUCTURE, 7)
    elseif(LeaderFaction == 'aeon') then
        ZanNorthTM:AddUnitsKilledTaunt('TAUNT29', ArmyBrains[Player1], categories.STRUCTURE, 7)
    end
end

function SetupWestM3Taunts()
    if(LeaderFaction == 'uef') then
        ThelWestTM:AddUnitsKilledTaunt('TAUNT24', ArmyBrains[Player1], categories.NAVAL * (categories.TECH2 + categories.TECH3), 6)
        ThelWestTM:AddUnitsKilledTaunt('TAUNT26', ArmyBrains[Player1], categories.TECH3, 2)
    elseif(LeaderFaction == 'cybran') then
        ThelWestTM:AddUnitsKilledTaunt('TAUNT28', ArmyBrains[Player1], categories.NAVAL * (categories.TECH2 + categories.TECH3), 6)
    elseif(LeaderFaction == 'aeon') then
        ThelWestTM:AddUnitsKilledTaunt('TAUNT30', ArmyBrains[Player1], categories.NAVAL * (categories.TECH2 + categories.TECH3), 6)
    end
    ThelWestTM:AddUnitsKilledTaunt('TAUNT23', ArmyBrains[Seraphim], categories.FACTORY * categories.NAVAL, 3)
    ThelWestTM:AddUnitsKilledTaunt('TAUNT30', ArmyBrains[Player1], categories.AIR, 30)
    ThelWestTM:AddDamageTaunt('TAUNT32', ScenarioInfo.WestACU, .12)
end
