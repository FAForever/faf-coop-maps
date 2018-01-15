-- ****************************************************************************
-- **
-- **  File     :  /maps/X1CA_Coop_006/X1CA_Coop_006_script.lua
-- **  Author(s):  Jessica St. Croix
-- **
-- **  Summary  : Main mission flow script for X1CA_Coop_006
-- **
-- **  Copyright 2007 Gas Powered Games, Inc.  All rights reserved.
-- ****************************************************************************
local Cinematics = import('/lua/cinematics.lua')
local M1SeraphimAI = import('/maps/X1CA_Coop_006/X1CA_Coop_006_m1seraphimai.lua')
local M2FletcherAI = import('/maps/X1CA_Coop_006/X1CA_Coop_006_m2fletcherai.lua')
local M2OrderAI = import('/maps/X1CA_Coop_006/X1CA_Coop_006_m2orderai.lua')
local M2RhizaAI = import('/maps/X1CA_Coop_006/X1CA_Coop_006_m2rhizaai.lua')
local M2SeraphimAI = import('/maps/X1CA_Coop_006/X1CA_Coop_006_m2seraphimai.lua')
local M3SeraphimAI = import('/maps/X1CA_Coop_006/X1CA_Coop_006_m3seraphimai.lua')
local Objectives = import('/lua/ScenarioFramework.lua').Objectives
local OpStrings = import('/maps/X1CA_Coop_006/X1CA_Coop_006_strings.lua')
local PingGroups = import('/lua/ScenarioFramework.lua').PingGroups
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local TauntManager = import('/lua/TauntManager.lua')
local Utilities = import('/lua/utilities.lua')
local EffectUtilities = import('/lua/EffectUtilities.lua')

---------
-- Globals
---------
ScenarioInfo.Player1 = 1
ScenarioInfo.Rhiza = 2
ScenarioInfo.Fletcher = 3
ScenarioInfo.Order = 4
ScenarioInfo.Seraphim = 5
ScenarioInfo.ControlCenter = 6
ScenarioInfo.OptionZero = 7
ScenarioInfo.Player2 = 8
ScenarioInfo.Player3 = 9
ScenarioInfo.Player4 = 10

ScenarioInfo.ControlCenterPossession = 0
ScenarioInfo.NukesLaunched = 0
ScenarioInfo.NukesAllowed = {1, 3, 4}

--------
-- Locals
--------
local Player1 = ScenarioInfo.Player1
local Player2 = ScenarioInfo.Player2
local Player3 = ScenarioInfo.Player3
local Player4 = ScenarioInfo.Player4
local Rhiza = ScenarioInfo.Rhiza
local Fletcher = ScenarioInfo.Fletcher
local Order = ScenarioInfo.Order
local Seraphim = ScenarioInfo.Seraphim
local ControlCenter = ScenarioInfo.ControlCenter
local OptionZero = ScenarioInfo.OptionZero

local AssignedObjectives = {}
local Difficulty = ScenarioInfo.Options.Difficulty
local ExpansionTimer = ScenarioInfo.Options.Expansion

local WaveDuration          =   30      -- number of units per wave
local WaveDurationNIS       =   20      -- duration of NIS rift "wave"
local TimeBetweenWaves      =   {300, 240, 180}     -- delay between end of wave and start of new one
local RiftNormalSpeed       =   5    -- time between rift unit spawns at normal speed
local RiftFastSpeed         =   {1.25, 1, 0.75}    -- time between rift unit spawns during a "wave"
local RiftNISSpeed          =   0.75    -- time between rift unit spawns during the initial NIS
local RiftTickTime          =   5

local FletcherTurned = false -- to keep track during the second NIS

-- How long should we wait at the beginning of the NIS to allow slower machines to catch up?
local NIS1InitialDelay = 3

----------------
-- Taunt Managers
----------------
local VedettaTM = TauntManager.CreateTauntManager('VedettaTM', '/maps/X1CA_Coop_006/X1CA_Coop_006_Strings.lua')
local FletcherTM = TauntManager.CreateTauntManager('FletcherTM', '/maps/X1CA_Coop_006/X1CA_Coop_006_Strings.lua')
local TauTM = TauntManager.CreateTauntManager('TauTM', '/maps/X1CA_Coop_006/X1CA_Coop_006_Strings.lua')
local HQTM = TauntManager.CreateTauntManager('HQTM', '/maps/X1CA_Coop_006/X1CA_Coop_006_Strings.lua')
local RhizaTM = TauntManager.CreateTauntManager('RhizaTM', '/maps/X1CA_Coop_006/X1CA_Coop_006_Strings.lua')

local LeaderFaction
local LocalFaction
local tblArmy

---------
-- Startup
---------
function OnPopulate(scenario)
    ScenarioUtils.InitializeScenarioArmies()
    LeaderFaction, LocalFaction = ScenarioFramework.GetLeaderAndLocalFactions()
    tblArmy = ListArmies()

    -- Army Colors
    if(LeaderFaction == 'cybran') then
        ScenarioFramework.SetCybranPlayerColor(Player1)
    elseif(LeaderFaction == 'uef') then
        ScenarioFramework.SetUEFPlayerColor(Player1)
    elseif(LeaderFaction == 'aeon') then
        ScenarioFramework.SetAeonPlayerColor(Player1)
    end
    ScenarioFramework.SetAeonAlly1Color(Rhiza)
    ScenarioFramework.SetUEFAlly1Color(Fletcher)
    ScenarioFramework.SetAeonEvilColor(Order)
    ScenarioFramework.SetSeraphimColor(Seraphim)
    ScenarioFramework.SetNeutralColor(ControlCenter)
    ScenarioFramework.SetNeutralColor(OptionZero)
    local colors = {
        ['Player2'] = {250, 250, 0}, 
        ['Player3'] = {255, 255, 255}, 
        ['Player4'] = {97, 109, 126}
    }
    for army, color in colors do
        if tblArmy[ScenarioInfo[army]] then
            ScenarioFramework.SetArmyColor(ScenarioInfo[army], unpack(color))
        end
    end

    -- Unit cap
    ScenarioFramework.SetSharedUnitCap(1000)
    SetArmyUnitCap(Seraphim, 500)

    -- Disable friendly AI sharing resources to players
    GetArmyBrain(Rhiza):SetResourceSharing(false)

    ------------------------------
    -- Rhiza's units for the player
    ------------------------------
    ScenarioInfo.RhizaPlayerBase = ScenarioUtils.CreateArmyGroup('Rhiza', 'M1_Rhiza_PlayerBase')
    ForkThread(RhizaColossusAI)

    ---------------------------------
    -- Fletcher's units for the player
    ---------------------------------
    ScenarioInfo.FletcherPlayerBase = ScenarioUtils.CreateArmyGroup('Fletcher', 'M1_Fletcher_PlayerBase')
    ForkThread(FletcherTransportAI)

    ----------------
    -- M1 Seraphim AI
    ----------------
    M1SeraphimAI.SeraphimM1BaseAI()

    ScenarioInfo.UnitNames[Seraphim]['M1_Seraph_sACU_1']:SetCustomName(LOC '{i sCDR_ElEoshi}')
    if(Difficulty > 1) then
        ScenarioInfo.UnitNames[Seraphim]['M1_Seraph_sACU_1']:CreateEnhancement('DamageStabilization')
        ScenarioInfo.UnitNames[Seraphim]['M1_Seraph_sACU_1']:CreateEnhancement('EngineeringThroughput')
    end

    ScenarioFramework.CreateArmyStatTrigger(M1SeraphimAI.M1NavalFactoryBuilt, ArmyBrains[Player1], 'M1NavalFactoryBuilt',
        {{StatType = 'Units_Active', CompareType = 'GreaterThanOrEqual', Value = 1, Category = categories.FACTORY * categories.NAVAL}})

    --------------------------
    -- Seraphim Initial Patrols
    --------------------------
    local units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M1_Seraph_Air_InitDef_D' .. Difficulty, 'GrowthFormation')
    for k, v in units:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M1_Seraph_Base_AirDef_Chain')))
    end

    for i = 1, 2 do
        units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M1_Seraph_Land' .. i .. '_InitDef_D' .. Difficulty, 'GrowthFormation')
        for k, v in units:GetPlatoonUnits() do
            ScenarioFramework.GroupPatrolChain({v}, 'M1_Seraph_Base_LandDef' .. i .. '_Chain')
        end
    end

    ScenarioInfo.Incarna1 = ScenarioUtils.CreateArmyUnit('Seraphim', 'M1_Seraph_Main_Exp_1')
    local platoon = ArmyBrains[Seraphim]:MakePlatoon('', '')
    ArmyBrains[Seraphim]:AssignUnitsToPlatoon(platoon, {ScenarioInfo.Incarna1}, 'Attack', 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M1_Seraph_Base_ExpDef_Patrol2_Chain')

    ScenarioInfo.Incarna2 = ScenarioUtils.CreateArmyUnit('Seraphim', 'M1_Seraph_Main_Exp_2')
    platoon = ArmyBrains[Seraphim]:MakePlatoon('', '')
    ArmyBrains[Seraphim]:AssignUnitsToPlatoon(platoon, {ScenarioInfo.Incarna2}, 'Attack', 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M1_Seraph_Base_ExpDef_Patrol_Chain')

    ------------------------
    -- Seraphim Resource Base
    ------------------------
    ScenarioUtils.CreateArmyGroup('Seraphim', 'M1_Seraph_ResourceBase_D' .. Difficulty)
end

function sACURhizaAI(unit)
    local cmd = IssueMove({unit}, ScenarioUtils.MarkerToPosition('M1_Rhiza_sACU_Marker'))
    while(not IsCommandDone(cmd)) do
        WaitSeconds(.5)
    end
    WaitSeconds(1)

    if tblArmy[ScenarioInfo.Player2] then
        ScenarioFramework.GiveUnitToArmy(unit, Player2)
        for k, v in ScenarioInfo.RhizaPlayerBase do
            ScenarioFramework.GiveUnitToArmy(v, Player2)
        end
    else
        ScenarioFramework.GiveUnitToArmy(unit, Player1)
        for k, v in ScenarioInfo.RhizaPlayerBase do
            ScenarioFramework.GiveUnitToArmy(v, Player1)
        end
    end
end

function RhizaColossusAI()
    local unit = ScenarioUtils.CreateArmyUnit('Rhiza', 'M1_Rhiza_GiftColos')
    for i = 1, 3 do
        local cmd = IssueMove({unit}, ScenarioUtils.MarkerToPosition('M1_Colos_Move_' .. i))
        while(not IsCommandDone(cmd)) do
            WaitSeconds(.5)
        end
    end
    WaitSeconds(1)
    if tblArmy[ScenarioInfo.Player2] then
        ScenarioFramework.GiveUnitToArmy(unit, Player2)
    else
        ScenarioFramework.GiveUnitToArmy(unit, Player1)
    end
end

function sACUFletcherAI(unit)
    local cmd = IssueMove({unit}, ScenarioUtils.MarkerToPosition('M1_Fletcher_sACU_Marker'))
    while(not IsCommandDone(cmd)) do
        WaitSeconds(.5)
    end
    WaitSeconds(1)
    if tblArmy[ScenarioInfo.Player3] then
        ScenarioFramework.GiveUnitToArmy(unit, Player3)
        for k, v in ScenarioInfo.FletcherPlayerBase do
            ScenarioFramework.GiveUnitToArmy(v, Player3)
        end
    else
        ScenarioFramework.GiveUnitToArmy(unit, Player1)
        for k, v in ScenarioInfo.FletcherPlayerBase do
            ScenarioFramework.GiveUnitToArmy(v, Player1)
        end
    end
end

function FletcherTransportAI()
    WaitSeconds(NIS1InitialDelay)

    local allUnits = {}
    local allTransports = {}
    for i = 1, 5 do
        local transport = ScenarioUtils.CreateArmyUnit('Fletcher', 'M1_Fletcher_GiftMobile_Transport')
        local units = ScenarioUtils.CreateArmyGroup('Fletcher', 'M1_Fletcher_GiftMobile_Units')
        table.insert(allTransports, transport)
        for k, v in units do
            table.insert(allUnits, v)
        end

        ScenarioFramework.AttachUnitsToTransports(units, {transport})
        WaitSeconds(0.5)
        IssueTransportUnload({transport}, ScenarioUtils.MarkerToPosition('M1_FletcherTransport_' .. i))
    end

    for k, v in allUnits do
        while(not v:IsDead() and v:IsUnitState('Attached')) do
            WaitSeconds(.5)
        end
    end

    local posX, posY, posZ = unpack(ScenarioUtils.MarkerToPosition('NIS1_Formation_Marker'))
    local i = 0

    for k, unit in allUnits do
        if(i < 5) then
            IssueMove({ unit }, { posX + (-6 + (i * 3)), posY, posZ - 6 })
            IssueMove({ unit }, { posX + (-6 + (i * 3)), posY, posZ - 4 })
        else
            IssueMove({ unit }, { posX + (-19 + (i * 3)), posY, posZ - 2 })
            IssueMove({ unit }, { posX + (-19 + (i * 3)), posY, posZ })
        end
        i = i + 1
    end

    for k, v in allTransports do
        IssueMove({v}, ScenarioUtils.MarkerToPosition('M1_Fletcher_Transport_Delete'))
    end

    WaitSeconds(1)

    for k, v in allTransports do
        while(not v:IsDead() and v:IsUnitState('Moving')) do
            WaitSeconds(.5)
        end
        v:Destroy()
    end
    if tblArmy[ScenarioInfo.Player3] then
        for k, unit in allUnits do
            ScenarioFramework.GiveUnitToArmy(unit, Player3)
        end
    else
        for k, unit in allUnits do
            ScenarioFramework.GiveUnitToArmy(unit, Player1)
        end
    end
end

function OnStart(self)
    --------------------
    -- Build Restrictions
    --------------------
    for _, player in ScenarioInfo.HumanPlayers do
        -- Seraphim Strategic Missile Launcher and Cybran Amphibious Mega Bot
        ScenarioFramework.AddRestriction(player, categories.xsb2401 + categories.xrl0403)
    end

    ScenarioFramework.SetPlayableArea('M1Area', false)
    IntroMission1NIS()
end

----------
-- End Game
----------
function PlayerWin()
    ForkThread(
        function()
            if(not ScenarioInfo.OpEnded) then
                ScenarioFramework.EndOperationSafety()
                ScenarioInfo.OpComplete = true

                ScenarioFramework.FlushDialogueQueue()
                while(ScenarioInfo.DialogueLock) do
                    WaitSeconds(0.2)
                end
                ScenarioFramework.Dialogue(OpStrings.X06_M03_105, nil, true)

                if(ScenarioInfo.M2S1.Active) then
                    if(ScenarioInfo.ControlCenterPossession == Player1 or ScenarioInfo.ControlCenterPossession == Rhiza) then
                        ScenarioInfo.M2S1:ManualResult(true)
                    else
                        ScenarioInfo.M2S1:ManualResult(false)
                    end
                end

                Cinematics.EnterNISMode()
                local VisMarker = ScenarioFramework.CreateVisibleAreaLocation(50, ScenarioUtils.MarkerToPosition('NIS_M3_Reveal_1'), 0, ArmyBrains[Player1])

                WaitSeconds(1)
                Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_4_1'), 0)
                WaitSeconds(1)
                Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_4_2'), 8)
                WaitSeconds(3)
                Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_4_3'), 4)
                WaitSeconds(3)

                ForkThread(KillGameWin)
            end
        end
   )
end

function PlayerLose(deadCommander)
    ScenarioFramework.PlayerDeath(deadCommander, OpStrings.X06_M01_140, AssignedObjectives)
end

function KillGameWin()
    ScenarioFramework.EndOperation(ScenarioInfo.OpComplete, ScenarioInfo.OpComplete, true)
end

-----------
-- Intro NIS
-----------
function IntroMission1NIS()
    ForkThread(
        function()
            local SubCommanderFletcher = ScenarioUtils.CreateArmyUnit('Fletcher', 'M1_Fletcher_sACU')
            local SubCommanderRhiza = ScenarioUtils.CreateArmyUnit('Rhiza', 'M1_Rhiza_sACU')
            SubCommanderFletcher:SetCustomName(LOC '{i sCDR_Romaska}')
            SubCommanderRhiza:SetCustomName(LOC '{i sCDR_St_Croix}')

            Cinematics.EnterNISMode()

            Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_1_1'), 0)

            -- Let slower machines catch up before we get going
            WaitSeconds(NIS1InitialDelay)

            -- Fletcher's reinforcements
            if (LeaderFaction == 'uef') then
                ScenarioFramework.Dialogue(OpStrings.X06_M01_020, nil, true)
            elseif (LeaderFaction == 'cybran') then
                ScenarioFramework.Dialogue(OpStrings.X06_M01_030, nil, true)
            elseif (LeaderFaction == 'aeon') then
                ScenarioFramework.Dialogue(OpStrings.X06_M01_040, nil, true)
            end

            WaitSeconds(1)
            Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_1_2'), 8)
            ForkThread(sACUFletcherAI, SubCommanderFletcher)
            WaitSeconds(2)

            Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_1_3'), 3)

            -- Rhiza's reinforcements
            if (LeaderFaction == 'aeon') then
                ScenarioFramework.Dialogue(OpStrings.X06_M01_055, nil, true)
            else
                ScenarioFramework.Dialogue(OpStrings.X06_M01_050, nil, true)
            end

            ScenarioFramework.CreateVisibleAreaLocation(100, ScenarioUtils.MarkerToPosition('M3_Seraph_LandAttack2_9'), 1, ArmyBrains[Player1])
            ScenarioFramework.CreateVisibleAreaLocation(30, ScenarioUtils.MarkerToPosition('M2_Order_AirAttack_1_3'), 1, ArmyBrains[Player1])

            WaitSeconds(1)
            Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_1_4'), 3)
            ForkThread(sACURhizaAI, SubCommanderRhiza)
            WaitSeconds(1)

            -- Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_1_5'), 3)
            -- WaitSeconds(1)
            -- The plan of attack
            if (LeaderFaction == 'aeon') then
                ScenarioFramework.Dialogue(OpStrings.X06_M01_065, nil, true)
            else
                ScenarioFramework.Dialogue(OpStrings.X06_M01_060, nil, true)
            end

            ForkThread(function()
                WaitSeconds(1)
                if (LeaderFaction == 'aeon') then
                    ScenarioInfo.PlayerCDR = ScenarioFramework.SpawnCommander('Player1', 'AeonPlayer', 'Warp', true, true, PlayerLose)
                elseif (LeaderFaction == 'cybran') then
                    ScenarioInfo.PlayerCDR = ScenarioFramework.SpawnCommander('Player1', 'CybranPlayer', 'Warp', true, true, PlayerLose)
                elseif (LeaderFaction == 'uef') then
                    ScenarioInfo.PlayerCDR = ScenarioFramework.SpawnCommander('Player1', 'UEFPlayer', 'Warp', true, true, PlayerLose)
                end

                -- Spawn Player4
                local tblArmy = ListArmies()
                if tblArmy[ScenarioInfo.Player4] then
                    factionIdx = GetArmyBrain('Player4'):GetFactionIndex()
                    if (factionIdx == 1) then
                        ScenarioInfo.CoopCDR3 = ScenarioFramework.SpawnCommander('Player4', 'UEFPlayer', 'Warp', true, true, PlayerLose)
                    elseif (factionIdx == 2) then
                        ScenarioInfo.CoopCDR3 = ScenarioFramework.SpawnCommander('Player4', 'AeonPlayer', 'Warp', true, true, PlayerLose)
                    else
                        ScenarioInfo.CoopCDR3 = ScenarioFramework.SpawnCommander('Player4', 'CybranPlayer', 'Warp', true, true, PlayerLose)
                    end
                end
            end)

            Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_1_6'), 3)
            WaitSeconds(1)

            -- Closing statement
            ScenarioFramework.Dialogue(OpStrings.X06_M01_010, nil, true)
            Cinematics.ExitNISMode()

            IntroMission1()
        end
   )
end

-----------
-- Mission 1
-----------
function IntroMission1()
    ScenarioInfo.MissionNumber = 1

    ScenarioFramework.Dialogue(OpStrings.X06_M01_100, StartMission1)
end

function StartMission1()
    local units = ScenarioFramework.GetCatUnitsInArea(categories.FACTORY + (categories.TECH3 * categories.ECONOMIC), 'M1_Seraphim_Base_Area', ArmyBrains[Seraphim])

    ---------------------
    -- Primary Objective 1
    ---------------------
    ScenarioInfo.M1P1 = Objectives.CategoriesInArea(
        'primary',                      -- type
        'incomplete',                   -- complete
        OpStrings.X06_M01_OBJ_010_010,  -- title
        OpStrings.X06_M01_OBJ_010_020,  -- description
        'kill',
        {                               -- target
            MarkUnits = true,
            Requirements = {
                {Area = 'M1_Seraphim_Base_Area', Category = categories.FACTORY + (categories.TECH3 * categories.ECONOMIC), CompareOp = '<=', Value = 0, ArmyIndex = Seraphim},
                -- {Area = 'M1_Seraphim_Base_Area', Category = (categories.TECH3 * categories.ECONOMIC), CompareOp = '<=', Value = 0, ArmyIndex = Seraphim},
            },
            FlashVisible = true,
        }
   )
    ScenarioInfo.M1P1:AddResultCallback(
        function(result)
            if(result) then
                IntroMission2PreNIS()
            end
        end
   )
    table.insert(AssignedObjectives, ScenarioInfo.M1P1)

    if ExpansionTimer then
        -- Continue to other part even if objective isn't finished yet
        local Delay = {25, 20, 15}
        ScenarioFramework.CreateTimerTrigger(IntroMission2PreNIS, Delay[Difficulty] * 60)
    end

    if(false and Difficulty ==3) then
        WaitSeconds(10)
        local units = ScenarioFramework.GetCatUnitsInArea(categories.ALLUNITS, 'M1_Seraphim_Base_Area', ArmyBrains[Seraphim])
        for k, v in units do
            v:Kill()
        end
    end

    -- Cybran megabot.
    ScenarioFramework.UnrestrictWithVoiceoverAndDelay(categories.xrl0403, "cybran", 35, OpStrings.X06_M01_110)

    ScenarioFramework.CreateTimerTrigger(M1Subplot, 360)
    if(Difficulty > 1) then
        ScenarioFramework.CreateArmyStatTrigger(M1ExperimentalBuilt, ArmyBrains[Player1], 'M1ExperimentalBuilt',
            {{StatType = 'Units_Active', CompareType = 'GreaterThanOrEqual', Value = 2, Category = categories.EXPERIMENTAL}})
    end
    ScenarioFramework.Dialogue(OpStrings.X06_M01_120)
end

function M1Subplot()
    if(LeaderFaction == 'uef' and ScenarioInfo.MissionNumber == 1) then
        ScenarioFramework.Dialogue(OpStrings.X06_M01_070)
    elseif(LeaderFaction == 'cybran') then
        ScenarioFramework.Dialogue(OpStrings.X06_M01_080)
    elseif(LeaderFaction == 'aeon') then
        ScenarioFramework.Dialogue(OpStrings.X06_M01_090)
    end
end

function M1ExperimentalBuilt()
    if(ScenarioInfo.Incarna1 and not ScenarioInfo.Incarna1:IsDead()) then
        IssueStop({ScenarioInfo.Incarna1})
        IssueClearCommands({ScenarioInfo.Incarna1})
        ScenarioFramework.GroupPatrolChain({ScenarioInfo.Incarna1}, 'M1_Seraph_Base_LandAttack_3_Chain')
    elseif(ScenarioInfo.Incarna2 and not ScenarioInfo.Incarna2:IsDead()) then
        IssueStop({ScenarioInfo.Incarna2})
        IssueClearCommands({ScenarioInfo.Incarna2})
        ScenarioFramework.GroupPatrolChain({ScenarioInfo.Incarna2}, 'M1_Seraph_Base_LandAttack_3_Chain')
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

            -- Unit caps
            SetArmyUnitCap(Rhiza, 520)
            SetArmyUnitCap(Fletcher, 575)
            SetArmyUnitCap(Order, 575)
            SetArmyUnitCap(Seraphim, 800)

            M2Fletcher()
            M2Order()
            M2Rhiza()
            M2Seraphim()

            ----------------
            -- Control Center
            ----------------
            ScenarioInfo.ControlCenterBldg = ScenarioUtils.CreateArmyUnit('ControlCenter', 'M2_ControlCenter')
            ScenarioInfo.ControlCenterBldg:SetCustomName(LOC '{i Black_Sun_Control_Tower}')
            ScenarioInfo.ControlCenterBldg:SetDoNotTarget(true)
            ScenarioFramework.CreateUnitDeathTrigger(ControlCenterDestroyed, ScenarioInfo.ControlCenterBldg)
            ScenarioFramework.CreateUnitCapturedTrigger(nil, ControlCenterCaptured, ScenarioInfo.ControlCenterBldg)
            ScenarioFramework.CreateUnitReclaimedTrigger(ControlCenterDestroyed, ScenarioInfo.ControlCenterBldg)
            ScenarioUtils.CreateArmyGroup('ControlCenter', 'ControlCenter_Walls')
            ScenarioUtils.CreateArmyGroup('ControlCenter', 'M2_Wreckage', true)

            -------------
            -- Option Zero
            -------------
            ScenarioInfo.OptionZeroNuke = ScenarioUtils.CreateArmyUnit('OptionZero', 'M2_MZero_Nuke_1')
            ScenarioInfo.OptionZeroNuke:SetCanTakeDamage(false)
            ScenarioInfo.OptionZeroNuke:SetCanBeKilled(false)
            ScenarioInfo.OptionZeroNuke:SetCapturable(false)
            ScenarioInfo.OptionZeroNuke:SetReclaimable(false)
            ScenarioInfo.OptionZeroNuke:SetIntelRadius('Vision', 0)

            ForkThread(IntroMission2NIS)

            -- TODO: move to m3 when non-smoking wreckage can be done.
            -- for now, to avoid smoking wreckage, spawn in Black Sun wreckage for m3.
            ScenarioUtils.CreateArmyGroup('Seraphim', 'M3_Wreckage', true)
        end
   )
end

function M2Fletcher()
    ----------------
    -- M2 Fletcher AI
    ----------------
    M2FletcherAI.FletcherM2BaseAI()
    if(Difficulty > 1) then
        M2FletcherAI.FletcherM2ExpBaseAI()
    end

    --------------
    -- Fletcher ACU
    --------------
    ScenarioInfo.FletcherACU = ScenarioFramework.SpawnCommander('Fletcher', 'Fletcher', false, LOC '{i Fletcher}', true)
    if(Difficulty > 1) then
        ScenarioInfo.FletcherACU:CreateEnhancement('DamageStabilization')
        ScenarioInfo.FletcherACU:CreateEnhancement('HeavyAntiMatterCannon')
        ScenarioInfo.FletcherACU:CreateEnhancement('Shield')
        ScenarioInfo.FletcherACU:CreateEnhancement('ShieldGeneratorField')
    end

    --------------------------
    -- Fletcher Initial Patrols
    --------------------------
    local units = ScenarioUtils.CreateArmyGroupAsPlatoon('Fletcher', 'M2_Fletcher_InitAir_Def_D' .. Difficulty, 'GrowthFormation')
    for k, v in units:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M2_Fletcher_AirDef_Chain')))
    end

    units = ScenarioUtils.CreateArmyGroupAsPlatoon('Fletcher', 'M2_Fletcher_InitLand_Def_D' .. Difficulty, 'GrowthFormation')
    for k, v in units:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolChain({v}, 'M2_Fletcher_LandDef_Chain')
    end

    -- TODO: make orbital attack player on hard
    if Difficulty == 3 then
        ForkThread(function()
            -- Wait for satellite to be launched
            WaitSeconds(5)
            local orbital = ArmyBrains[Fletcher]:GetListOfUnits(categories.xea0002, false)
            if(orbital[1] and not orbital[1]:IsDead()) then
                local platoon = ArmyBrains[Fletcher]:MakePlatoon('', '')
                ArmyBrains[Fletcher]:AssignUnitsToPlatoon(platoon, {orbital[1]}, 'Attack', 'GrowthFormation')
                ScenarioFramework.PlatoonPatrolChain(platoon, 'M1_Fletcher_Orbital_Def_Chain')
            end
        end)
    end
end

function M2Order()
    -------------
    -- M2 Order AI
    -------------
    M2OrderAI.OrderM2BaseAI()

    -----------
    -- Order ACU
    -----------
    ScenarioInfo.OrderACU = ScenarioFramework.SpawnCommander('Order', 'M2_Order_Vedetta', false, LOC '{i Vendetta}', true)
    if(Difficulty > 1) then
        ScenarioInfo.OrderACU:CreateEnhancement('Shield')
        ScenarioInfo.OrderACU:CreateEnhancement('ShieldHeavy')
        ScenarioInfo.OrderACU:CreateEnhancement('HeatSink')
        ScenarioInfo.OrderACU:CreateEnhancement('CrysalisBeam')
    end

    -----------------------
    -- Order Initial Patrols
    -----------------------
    local colossus = ScenarioUtils.CreateArmyUnit('Order', 'M2_Order_Colossus')
    local platoon = ArmyBrains[Order]:MakePlatoon('', '')
    ArmyBrains[Order]:AssignUnitsToPlatoon(platoon, {colossus}, 'Attack', 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M2_Order_LandDef_2_Chain')

    for i = 1, 2 do
        local units = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'M2_Order_InitNaval' .. i .. '_Def_D' .. Difficulty, 'GrowthFormation')
        for k, v in units:GetPlatoonUnits() do
            ScenarioFramework.GroupPatrolChain({v}, 'M2_Order_NavalDef_' .. i .. '_Chain')
        end
    end

    for i = 1, 2 do
        local units = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'M2_Order_InitLand' .. i .. '_Def_D' .. Difficulty, 'GrowthFormation')
        for k, v in units:GetPlatoonUnits() do
            ScenarioFramework.GroupPatrolChain({v}, 'M2_Order_LandDef_' .. i .. '_Chain')
        end
    end

    local units = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'M2_Order_InitAir_Def_D' .. Difficulty, 'GrowthFormation')
    for k, v in units:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M2_Order_NavalDef_2_Chain')))
    end
end

function M2Rhiza()
    -------------
    -- M2 Rhiza AI
    -------------
    M2RhizaAI.RhizaM2BaseAI()

    -----------
    -- Rhiza ACU
    -----------
    ScenarioInfo.RhizaACU = ScenarioFramework.SpawnCommander('Rhiza', 'M2_Rhiza', false, LOC '{i Rhiza}', false, RhizaDies, 
        {'Shield', 'ShieldHeavy', 'AdvancedEngineering', 'T3Engineering', 'HeatSink'})

    -----------------------
    -- Rhiza Initial Patrols
    -----------------------
    local units = ScenarioUtils.CreateArmyGroupAsPlatoon('Rhiza', 'M2_Rhiza_InitLand_Def_D' .. Difficulty, 'GrowthFormation')
    for k, v in units:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolChain({v}, 'M2_Rhiza_LandDef_Chain')
    end

    units = ScenarioUtils.CreateArmyGroupAsPlatoon('Rhiza', 'M2_Rhiza_InitAir_Def_D' .. Difficulty, 'GrowthFormation')
    for k, v in units:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M2_Rhiza_AirDef_Chain')))
    end

    units = ScenarioUtils.CreateArmyGroupAsPlatoon('Rhiza', 'M2_Rhiza_InitNaval_Def_D' .. Difficulty, 'GrowthFormation')
    for k, v in units:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolChain({v}, 'M2_Rhiza_NavalDef_Chain')
    end

    -- Wreckage
    -- ScenarioUtils.CreateArmyGroup('Rhiza', 'M2_Wreckage', true)
end

function RhizaNavyPing(platoon)
    local tempest = ArmyBrains[Rhiza]:GetListOfUnits(categories.uas0401, false)

    ScenarioInfo.RhizaTempest = tempest[1]
    ScenarioInfo.RhizaTempestPing = PingGroups.AddPingGroup(OpStrings.X06_M01_OBJ_010_010, 'uas0401', 'move', OpStrings.X06_M01_OBJ_010_020)
    ScenarioInfo.RhizaTempestPing:AddCallback(RhizaTempestPingActivate)

    ScenarioFramework.CreateUnitDestroyedTrigger(RhizaTempestDead, ScenarioInfo.RhizaTempest)
end

function RhizaTempestPingActivate(location)
    IssueStop({ScenarioInfo.RhizaTempest})
    IssueClearCommands({ScenarioInfo.RhizaTempest})
    IssueMove({ScenarioInfo.RhizaTempest}, location)
end

function RhizaTempestDead()
    ScenarioInfo.RhizaTempestPing:Destroy()
end

function RhizaDies()
    ScenarioFramework.Dialogue(OpStrings.X06_M02_270)
    M2RhizaAI.DisableBase()
end

function M2Seraphim()
    ----------------
    -- M2 Seraphim AI
    ----------------
    M2SeraphimAI.SeraphimM2BaseAI()

    --------------------------
    -- Seraphim Initial Patrols
    --------------------------
    for i = 1, 2 do
        local exp = ScenarioUtils.CreateArmyUnit('Seraphim', 'M2_Seraph_Exp_' .. i)
        local platoon = ArmyBrains[Seraphim]:MakePlatoon('', '')
        ArmyBrains[Seraphim]:AssignUnitsToPlatoon(platoon, {exp}, 'Attack', 'GrowthFormation')
        ScenarioFramework.PlatoonPatrolChain(platoon, 'M2_Seraph_Exp_Def_' .. i .. '_Chain')
    end

    for i = 1, 2 do
        local units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M2_Seraph_Init_LandDef_' .. i .. '_D' .. Difficulty, 'GrowthFormation')
        for k, v in units:GetPlatoonUnits() do
            ScenarioFramework.GroupPatrolChain({v}, 'M2_Seraph_Land_Def_' .. i .. '_Chain')
        end
    end

    local units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M2_Seraph_Init_AirDef_D' .. Difficulty, 'GrowthFormation')
    for k, v in units:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M2_Seraph_AirDef_Chain')))
    end

    units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M2_Seraph_Init_NavalDef_D' .. Difficulty, 'GrowthFormation')
    for k, v in units:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolChain({v}, 'M2_Seraph_Naval_Def_Chain')
    end
end

function IntroMission2PreNIS()
    ForkThread(function()
        if not ScenarioInfo.M1Finished then
            ScenarioInfo.M1Finished = true
            ScenarioFramework.Dialogue(OpStrings.X06_M02_010, IntroMission2, true)
        end
    end)
end

function IntroMission2NIS()
    ScenarioFramework.SetPlayableArea('M2Area')

    Cinematics.EnterNISMode()
    Cinematics.SetInvincible('M1Area')

    -- Spawn Seraphim group "M2_NIS_Units", tell them to aggressive move to M2_NIS_Seraphim_Destination
    local SeraphimUnits = ScenarioUtils.CreateArmyGroup('Seraphim', 'M2_NIS_Units')
    IssueAggressiveMove(SeraphimUnits, ScenarioUtils.MarkerToPosition('M2_NIS_Seraphim_Destination'))

    -- Spawn Fletcher group "M2_NIS_Units", tell them to kill enemy units
    local FletcherUnits = ScenarioUtils.CreateArmyGroup('Fletcher', 'M2_NIS_Units')
    for k, target in SeraphimUnits do
        IssueAttack(FletcherUnits, target)
    end

    -- Spawn Rhiza group "M2_NIS_Units", tell them to kill enemy units
    local RhizaUnits = ScenarioUtils.CreateArmyGroup('Rhiza', 'M2_NIS_Units')
    for k, v in RhizaUnits do
        if(v:GetUnitId() == 'uas0201') then
            v:SetWeaponEnabledByLabel('AntiTorpedo', false)
        elseif(v:GetUnitId() == 'uas0103') then
            v:SetWeaponEnabledByLabel('AntiTorpedo01', false)
        end
    end
    for k, target in SeraphimUnits do
        IssueAttack(RhizaUnits, target)
    end

    WaitSeconds(1)

    -- Sneak these intel flashes into the NIS; the player should have intel on the enemy bases afterwards
    ScenarioFramework.CreateVisibleAreaLocation(100, ScenarioUtils.MarkerToPosition('M2_Rhiza_Transport_Attack_1'), 1, ArmyBrains[Player1])
    ScenarioFramework.CreateVisibleAreaLocation(120, ScenarioUtils.MarkerToPosition('M2_Seraph_AirAttack_Rhiza_8'), 1, ArmyBrains[Player1])

    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_2_1'), 0)
    WaitSeconds(1)

    ScenarioFramework.Dialogue(OpStrings.X06_M02_011, FletcherTurns, true)

    -- Make the Seraphim units fragile
    for k, unit in SeraphimUnits do
        if unit and (not unit:IsDead()) then
            unit:AdjustHealth(unit, (unit:GetHealth() - 1) * -1)
        end
    end

    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_2_2'), 10)

    while (not FletcherTurned) do
        WaitSeconds(0.2)
    end

    for _, player in ScenarioInfo.HumanPlayers do
        SetAlliance(player, Fletcher, 'Enemy')
    end
    for _, player in ScenarioInfo.HumanPlayers do
        SetAlliance(Fletcher, player, 'Enemy')
    end
    SetAlliance(Fletcher, Rhiza, 'Enemy')

    -- Clear intel on the experimental base area
    ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('M2_Fletcher_Exp_Base'), 5)

    local unitAttacker = ScenarioInfo.UnitNames[Fletcher]['M2_NIS_Attacker']
    local unitTarget = ScenarioInfo.UnitNames[Rhiza]['M2_NIS_Target']

    -- This is intended to make the bad guys all attack one good guy.  The way that the missiles fly through
    -- the air to this particular target gives a particular camera a great shot.
    -- But for whatever reason, this doesn't seem to work.
    if unitAttacker and unitTarget and not unitAttacker:IsDead() and not unitTarget:IsDead() then
        IssueClearCommands({ unitAttacker })
        IssueAttack({ unitAttacker }, unitTarget)
    end

    -- Tell all of the units to attack their new enemies
    local RhizaNum = table.getn(RhizaUnits)
    for k, unit in FletcherUnits do
        if unit and not unit:IsDead() then
            local target = RhizaUnits[ math.mod(k, RhizaNum)]
            if target and not target:IsDead() then
                IssueAttack({ unit }, target)
            end
        end
    end

    for k, target in RhizaUnits do
        if target and not target:IsDead() then
            IssueAttack(FletcherUnits, target)
        end
    end

    -- WaitSeconds(3)

    ScenarioFramework.Dialogue(OpStrings.X06_M02_012, RhizaRetaliates, true)

    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_2_3'), 4)

    for k, target in FletcherUnits do
        if target and not target:IsDead() then
            IssueAttack(RhizaUnits, target)
        end
    end

    local RhizaUnitsDead = false
    local FletcherUnitsDead = false
    local LoopCount = 0
    local LoopDone = false

    ForkThread(
        function()
            -- If for some reason the ships haven't died by this amount of time, end this camera shot anyway
            -- The primary reason that this would happen is that someone is running the game with
            -- invincible units or damage turned off -- an unlikley event for a regular player.
            WaitSeconds(15)
            LoopDone = true
        end
   )

    ForkThread(
        function()
            while ((RhizaUnitsDead == false) and(FletcherUnitsDead == false)) do

                RhizaUnitsDead = true
                for k, unit in RhizaUnits do
                    if unit and (not unit:IsDead()) and RhizaUnitsDead then
                        RhizaUnitsDead = false
                    end
                    if unit and (not unit:IsDead()) then
                        if LoopCount > 4 then
                            unit:AdjustHealth(unit, (unit:GetHealth() - 1) * -1)
                        end
                    end
                end

                FletcherUnitsDead = true
                for k, unit in FletcherUnits do
                    if unit and (not unit:IsDead()) and FletcherUnitsDead then
                        FletcherUnitsDead = false
                    end
                end

                WaitSeconds(1)
                LoopCount = LoopCount + 1
            end
            LoopDone = true
        end
   )

    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_2_3_2'), 6)

    while not LoopDone do
        WaitSeconds(0.5)
    end

    ScenarioFramework.Dialogue(OpStrings.X06_M02_013, nil, true)

    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_2_4'), 3)
    Cinematics.SetInvincible('M1Area', true)
    Cinematics.ExitNISMode()

    -- Send the NIS units north to Rhiza's base
    for k, unit in FletcherUnits do
        if unit and (not unit:IsDead()) then
            IssueAggressiveMove({ unit }, ScenarioUtils.MarkerToPosition('M2_Seraph_Naval_East_15'))
        end
    end

    for _, player in ScenarioInfo.HumanPlayers do
        SetAlliance(player, Fletcher, 'Enemy')
        SetAlliance(Fletcher, player, 'Enemy')
    end
    SetAlliance(Fletcher, Rhiza, 'Enemy')

    ScenarioFramework.CreateVisibleAreaLocation(100, ScenarioUtils.MarkerToPosition('M2_Rhiza_Transport_Attack_1'), 1, ArmyBrains[Player1])
    ScenarioFramework.CreateVisibleAreaLocation(120, ScenarioUtils.MarkerToPosition('M2_Seraph_AirAttack_Rhiza_8'), 1, ArmyBrains[Player1])

    StartMission2()
end

function FletcherTurns()
    FletcherTurned = true
end

function RhizaRetaliates()
    SetAlliance(Rhiza, Fletcher, 'Enemy')
end

function StartMission2()
    -- Taunts
    SetupVedettaTauntTriggers()
    SetupFletcherTauntTriggers()
    SetupRhizaTauntTriggers()

    M2FletcherCounterattack()
    M2OrderCounterattack()
    M2RhizaCounterattack()
    M2SeraphimCounterattack()

    -- Factional VO, and a sum-up by HQ
    if(LeaderFaction == 'uef') then
        ScenarioFramework.Dialogue(OpStrings.X06_M02_020)
    elseif(LeaderFaction == 'cybran') then
        ScenarioFramework.Dialogue(OpStrings.X06_M02_030)
    elseif(LeaderFaction == 'aeon') then
        ScenarioFramework.Dialogue(OpStrings.X06_M02_040)
    end
    ScenarioFramework.Dialogue(OpStrings.X06_M02_050)

    -- Play Quantum Resource Generator VO when Order's is spotted
    ScenarioFramework.CreateArmyIntelTrigger(M2ParagonSpotted , ArmyBrains[Player1], 'LOSNow', false , true, categories.xab1401, true, ArmyBrains[Order])

    -------------------------------------
    -- Primary Objective 1 - Kill Fletcher
    -------------------------------------
    ScenarioInfo.M2P1 = Objectives.KillOrCapture(
        'primary',                      -- type
        'incomplete',                   -- complete
        OpStrings.X06_M02_OBJ_010_030,  -- title
        OpStrings.X06_M02_OBJ_010_040,  -- description
        {                               -- target
            Units = {ScenarioInfo.FletcherACU}
        }
   )
    ScenarioInfo.M2P1:AddResultCallback(
        function(result)
            if(result) then
                ScenarioFramework.CDRDeathNISCamera(ScenarioInfo.FletcherACU, 5)
                ScenarioFramework.Dialogue(OpStrings.TAUNT50)
                ScenarioFramework.Dialogue(OpStrings.X06_M02_110)

                -- Blow up his base
                local units = ScenarioFramework.GetCatUnitsInArea(categories.ALLUNITS - categories.uec1902, Rect(0, 0, 1024, 1024), ArmyBrains[Fletcher])
                for k, v in units do
                    v:Kill()
                end

                -- Clear nuke timer if he had possession of the controlcenter
                if(ScenarioInfo.ControlCenterPossession and ScenarioInfo.ControlCenterPossession == Fletcher) then
                    if(ScenarioInfo.NukeTimer) then
                        KillThread(ScenarioInfo.NukeTimer)
                    end
                    ScenarioInfo.ControlCenterPossession = nil
                end

                if(ScenarioInfo.M2P2.Active) then
                    ScenarioFramework.CreateTimerTrigger(M2RhizaNuke, 90)
                end
            end
        end
   )
    table.insert(AssignedObjectives, ScenarioInfo.M2P1)
    ScenarioFramework.CreateTimerTrigger(M2P1Reminder1, 2000)

    ------------------------------------
    -- Primary Objective 2 - Kill Vedetta
    ------------------------------------
    ScenarioInfo.M2P2 = Objectives.KillOrCapture(
        'primary',                      -- type
        'incomplete',                   -- complete
        OpStrings.X06_M02_OBJ_010_010,  -- title
        OpStrings.X06_M02_OBJ_010_020,  -- description
        {                               -- target
            Units = {ScenarioInfo.OrderACU}
        }
   )
    ScenarioInfo.M2P2:AddResultCallback(
        function(result)
            if(result) then
                ScenarioFramework.CDRDeathNISCamera(ScenarioInfo.OrderACU, 5)
                ScenarioFramework.Dialogue(OpStrings.X06_M02_140)

                -- Blow up his base
                local units = ScenarioFramework.GetCatUnitsInArea(categories.ALLUNITS - categories.uec1902, Rect(0, 0, 1024, 1024), ArmyBrains[Order])
                for k, v in units do
                    v:Kill()
                end

                -- Clear nuke timer if he had possession of the controlcenter
                if(ScenarioInfo.ControlCenterPossession and ScenarioInfo.ControlCenterPossession == Order) then
                    if(ScenarioInfo.NukeTimer) then
                        KillThread(ScenarioInfo.NukeTimer)
                    end
                    ScenarioInfo.ControlCenterPossession = nil
                end

                if(ScenarioInfo.M2P1.Active) then
                    ScenarioFramework.CreateTimerTrigger(M2RhizaNuke, 90)
                end
            end
        end
   )
    table.insert(AssignedObjectives, ScenarioInfo.M2P2)
    ScenarioFramework.CreateTimerTrigger(M2P2Reminder1, 1060)

    if ExpansionTimer then
        -- Continue to other part even if objective isn't finished yet
        local Delay = {30, 25, 20}
        ScenarioFramework.CreateTimerTrigger(M2EndMission, Delay[Difficulty] * 60)
    end

    local m2Objectives = Objectives.CreateGroup('M2Primaries', M2EndMission, 2)
    m2Objectives:AddObjective(ScenarioInfo.M2P1)
    m2Objectives:AddObjective(ScenarioInfo.M2P2)

    ScenarioFramework.CreateTimerTrigger(StartFletcherCounter, 90)
    ScenarioFramework.CreateTimerTrigger(RevealM2S1, 180) -- changed from a 1 min to 3 min delay after conversation with Brad 6/15

    local time = {900, 600, 180}
    local RhizaTime = {150, 250, 450}
    ScenarioFramework.CreateTimerTrigger(M2FletcherAI.FletcherCaptureControlCenter, time[Difficulty])
    ScenarioFramework.CreateTimerTrigger(M2OrderAI.OrderCaptureControlCenter, time[Difficulty])
    ScenarioFramework.CreateTimerTrigger(M2RhizaAI.RhizaCaptureControlCenter, RhizaTime[Difficulty])

    time = {900, 1800, 3600}
    ScenarioFramework.CreateTimerTrigger(M2RhizaNuke, time[Difficulty])
end

function M2RhizaNuke()
    if(not ScenarioInfo.RhizaNuke) then
        ScenarioInfo.RhizaNuke = true

        ScenarioFramework.Dialogue(OpStrings.TAUNT61)
        WaitSeconds(20)

        local marker = nil
        local numUnits = 0
        for i = 1, 4 do
            local num = table.getn(ArmyBrains[Rhiza]:GetUnitsAroundPoint(categories.ALLUNITS, ScenarioUtils.MarkerToPosition('M2_RhizaNukeTarget_' .. i), 15, 'enemy'))
            if(num > 5) then
                if(num > numUnits) then
                    numUnits = num
                    marker = 'M2_RhizaNukeTarget_' .. i
                end
            end
        end
        local nuke = ScenarioInfo.UnitNames[Rhiza]['M2_Rhiza_Nuke']
        if(marker and nuke and not nuke:IsDead()) then
            nuke:GiveNukeSiloAmmo(2)
            IssueNuke({nuke}, ScenarioUtils.MarkerToPosition(marker))
        end
    end
end

function M2FletcherCounterattack()
    local num = nil
    local quantity = {}
    local trigger = {}
    local units = nil

    ------------------------
    -- Fletcher Counterattack
    ------------------------

    -- Initial trickle
    units = ScenarioUtils.CreateArmyGroupAsPlatoon('Fletcher', 'M2_Fletcher_InitAir_Attack_1', 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(units, 'M2_Fletcher_AirAttack' .. Random(1, 2) .. '_Chain')

    -- Default main counter
    ScenarioInfo.FletcherCounterAttack = {}
    units = ScenarioUtils.CreateArmyGroupAsPlatoon('Fletcher', 'M2_Fletcher_InitAir_Attack_2', 'GrowthFormation')
    table.insert(ScenarioInfo.FletcherCounterAttack, units)
    for k, v in units:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M2_Fletcher_AirDef_Chain')))
    end

    -- Spawns Gunships for every 4, 3, 2 shields, max 6, 8, 10 groups
    quantity = {6, 8, 10}
    trigger = {4, 3, 2}
    local num = ScenarioFramework.GetNumOfHumanUnits(categories.STRUCTURE * categories.SHIELD, false)

    if(num > 0) then
        num = math.ceil(num/trigger[Difficulty])
        if(num > quantity[Difficulty]) then
            num = quantity[Difficulty]
        end
        for i = 1, num do
            units = ScenarioUtils.CreateArmyGroupAsPlatoon('Fletcher', 'M2_Fletcher_Adapt_Gunships', 'GrowthFormation')
            table.insert(ScenarioInfo.FletcherCounterAttack, units)
            for k, v in units:GetPlatoonUnits() do
                ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M2_Fletcher_AirDef_Chain')))
            end
        end
    end

    -- Spawns Air Superiority for every 30, 20, 10 planes, max 3, 5, 7 groups
    quantity = {3, 5, 7}
    trigger = {30, 20, 10}
    local num = ScenarioFramework.GetNumOfHumanUnits(categories.MOBILE * categories.AIR, false)

    if(num > 0) then
        num = math.ceil(num/trigger[Difficulty])
        if(num > quantity[Difficulty]) then
            num = quantity[Difficulty]
        end
        for i = 1, num do
            units = ScenarioUtils.CreateArmyGroupAsPlatoon('Fletcher', 'M2_Fletcher_Adapt_AntiAir', 'GrowthFormation')
            table.insert(ScenarioInfo.FletcherCounterAttack, units)
            for k, v in units:GetPlatoonUnits() do
                ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M2_Fletcher_AirDef_Chain')))
            end
        end
    end
end

function M2OrderCounterattack()
    local num = nil
    local quantity = {}
    local trigger = {}
    local units = nil

    ---------------------
    -- Order Counterattack
    ---------------------

    -- Default Air Attack
    units = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'M2_Order_Init_AirAttack_D' .. Difficulty, 'GrowthFormation')
    for k, v in units:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M2_Order_AirAttack_' .. Random(1, 3) .. '_Chain')))
    end

    -- Default Naval Attack
    units = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'M2_Order_Init_NavalAttack_D' .. Difficulty, 'GrowthFormation')
    for k, v in units:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolChain({v}, 'M2_Order_NavalAttack_' .. Random(1, 2) .. '_Chain')
    end

    -- Spawns transport attacks for every 4, 3, 2 T2/T3 defensive structure, max 4, 6, 8 groups
    quantity = {4, 6, 8}
    trigger = {4, 3, 2}
    local num = ScenarioFramework.GetNumOfHumanUnits((categories.STRUCTURE * categories.DEFENSE) - categories.TECH1, false)

    if(num > 0) then
        num = math.ceil(num/trigger[Difficulty])
        if(num > quantity[Difficulty]) then
            num = quantity[Difficulty]
        end
        for i = 1, num do
            units = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'M2_Order_Adapt_Xport', 'GrowthFormation')
            for k,v in units:GetPlatoonUnits() do
                if(v:GetUnitId() == 'uaa0104') then
                    local interceptors = ScenarioUtils.CreateArmyGroup('Order', 'M2_Order_Adapt_Xport_Interceptors')
                    IssueGuard(interceptors, v)
                    break
                end
            end
            ScenarioFramework.PlatoonAttackWithTransports(units, 'M2_Order_TransportLanding_Chain', 'M2_Order_TransportAttack_Chain', false)
        end
    end

    -- Spawns gunships for every 30, 20, 10 land units, max 3, 5, 7 groups
    quantity = {3, 5, 7}
    trigger = {30, 20, 10}
    local num = ScenarioFramework.GetNumOfHumanUnits(categories.MOBILE * categories.LAND, false)

    if(num > 0) then
        num = math.ceil(num/trigger[Difficulty])
        if(num > quantity[Difficulty]) then
            num = quantity[Difficulty]
        end
        for i = 1, num do
            units = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'M2_Order_Adapt_Gunships', 'GrowthFormation')
            ScenarioFramework.PlatoonPatrolChain(units, 'M2_Order_AirAttack_' .. Random(1, 3) .. '_Chain')
        end
    end

    -- Spawns air superiority for every 40, 20, 10 air units, max 3, 5, 7 groups
    quantity = {3, 5, 7}
    trigger = {40, 20, 10}
    local num = ScenarioFramework.GetNumOfHumanUnits(categories.MOBILE * categories.AIR, false)

    if(num > 0) then
        num = math.ceil(num/trigger[Difficulty])
        if(num > quantity[Difficulty]) then
            num = quantity[Difficulty]
        end
        for i = 1, num do
            units = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'M2_Order_Adapt_AntiAir', 'GrowthFormation')
            ScenarioFramework.PlatoonPatrolChain(units, 'M2_Order_AirAttack_' .. Random(1, 3) .. '_Chain')
        end
    end

    -- Experimental Response, max 2, 5, 10
    quantity = {2, 5, 10}
    local experimentals = ScenarioFramework.GetListOfHumanUnits(categories.EXPERIMENTAL, false)
    num = table.getn(experimentals)
    if(num > 0) then
        if(num > quantity[Difficulty]) then
            num = quantity[Difficulty]
        end
        for i = 1, num do
            units = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'M2_Order_Adapt_Bombers', 'GrowthFormation')
            IssueAttack(units:GetPlatoonUnits(), experimentals[i])
            ScenarioFramework.PlatoonPatrolChain(units, 'M2_Order_AirAttack_' .. Random(1, 3) .. '_Chain')
        end
    end

    -- Battleship Response, max 2, 5, 10
    quantity = {2, 5, 10}
    local experimentals = ScenarioFramework.GetListOfHumanUnits(categories.uas0302 + categories.ues0302 + categories.urs0302, false)
    num = table.getn(experimentals)
    if(num > 0) then
        if(num > quantity[Difficulty]) then
            num = quantity[Difficulty]
        end
        for i = 1, num do
            units = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'M2_Order_Adapt_Bombers', 'GrowthFormation')
            IssueAttack(units:GetPlatoonUnits(), experimentals[i])
            ScenarioFramework.PlatoonPatrolChain(units, 'M2_Order_AirAttack_' .. Random(1, 3) .. '_Chain')
        end
    end

    -- Spawns Cruisers if player has naval and > 60, 40, 20 T2/T3 air
    trigger = {60, 40, 20}
    local num = ScenarioFramework.GetNumOfHumanUnits(categories.MOBILE * categories.NAVAL, false)

    if(num > 0) then
        local num = ScenarioFramework.GetNumOfHumanUnits((categories.MOBILE * categories.AIR) - categories.TECH1, false)

        if(num > quantity[Difficulty]) then
            units = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'M2_Order_Adapt_Naval_Cruiser', 'GrowthFormation')
            for k, v in units:GetPlatoonUnits() do
                ScenarioFramework.GroupPatrolChain({v}, 'M2_Order_NavalAttack_' .. Random(1, 2) .. '_Chain')
            end
        end
    end

    -- Spawns Destroyers if player has > 8, 5, 3 T2/T3 naval
    trigger = {8, 5, 3}
    local num = ScenarioFramework.GetNumOfHumanUnits((categories.MOBILE * categories.NAVAL) - categories.TECH1, false)

    if(num > quantity[Difficulty]) then
        units = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'M2_Order_Adapt_Naval_Destro', 'GrowthFormation')
        for k, v in units:GetPlatoonUnits() do
            ScenarioFramework.GroupPatrolChain({v}, 'M2_Order_NavalAttack_' .. Random(1, 2) .. '_Chain')
        end
    end
end

function M2RhizaCounterattack()
    local units = nil

    ---------------------
    -- Rhiza Counterattack
    ---------------------

    units = ScenarioUtils.CreateArmyGroupAsPlatoon('Rhiza', 'M2_Rhiza_Init_AirAttack_D' .. Difficulty, 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(units, 'M2_Rhiza_Init_AirAttack_Chain')

    units = ScenarioUtils.CreateArmyGroupAsPlatoon('Rhiza', 'M2_Rhiza_Init_XportAttack', 'GrowthFormation')
    ScenarioFramework.PlatoonAttackWithTransports(units, 'M2_Rhiza_Transport_Landing_Chain', 'M2_Rhiza_Transport_Attack_Chain', false)
end

function M2SeraphimCounterattack()
    local units = nil

    ------------------------
    -- Seraphim Counterattack
    ------------------------

    units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M2_Seraph_Init_AirAttack_1', 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(units, 'M2_Seraph_Init_AirAttack_Chain')

    units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M2_Seraph_Init_AirAttack_2_D' .. Difficulty, 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(units, 'M2_Seraph_Init_AirAttack_Chain')

    units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M2_Seraph_Init_NavalAttack_1', 'GrowthFormation')
    for k, v in units:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolChain({v}, 'M2_Seraph_Init_NavalAttack_Chain')
    end

    units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M2_Seraph_Init_NavalAttack_2_D' .. Difficulty, 'GrowthFormation')
    for k, v in units:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolChain({v}, 'M2_Seraph_Init_NavalAttack_Chain')
    end
end

function StartFletcherCounter()
    for k, v in ScenarioInfo.FletcherCounterAttack do
        if(ArmyBrains[Fletcher]:PlatoonExists(v)) then
            IssueClearCommands(v:GetPlatoonUnits())
            ScenarioFramework.PlatoonPatrolChain(v, 'M2_Fletcher_AirAttack' .. Random(1, 2) .. '_Chain')
        end
    end
end

function M2ParagonSpotted()
    -- Paragon comment from HQ
    ScenarioFramework.Dialogue(OpStrings.X06_M02_060)
end

function RevealM2S1()
    if(ScenarioInfo.ControlCenterPossession == 0 and ScenarioInfo.ControlCenterBldg and not ScenarioInfo.ControlCenterBldg:IsDead()) then
        ScenarioFramework.Dialogue(OpStrings.X06_M02_150, AssignM2S1)
    end
end

function AssignM2S1()
    ------------------------------------------------
    -- Secondary Objective 1 - Capture Control Center
    ------------------------------------------------
    ScenarioInfo.M2S1 = Objectives.Basic(
        'secondary',                            -- type
        'incomplete',                           -- status
        OpStrings.X06_M02_OBJ_010_050,          -- title
        OpStrings.X06_M02_OBJ_010_060,          -- description
        Objectives.GetActionIcon('capture'),
        {                                       -- target
            FlashVisible = true,
            MarkUnits = true,
            Units = {ScenarioInfo.ControlCenterBldg},
        }
   )
    table.insert(AssignedObjectives, ScenarioInfo.M2S1)
end

function ControlCenterDestroyed()
    ScenarioFramework.Dialogue(OpStrings.X06_M02_210)
    if(ScenarioInfo.M2S1 and ScenarioInfo.M2S1.Active) then
        if(ScenarioInfo.ControlCenterPossession == Player1) then
            ScenarioInfo.M2S1:ManualResult(true)
        else
            ScenarioInfo.M2S1:ManualResult(false)
        end
    end

    -- Remove any old timers and pings
    if(ScenarioInfo.NukeTimer) then
        KillThread(ScenarioInfo.NukeTimer)
    end
    if(ScenarioInfo.NukePing) then
        ScenarioInfo.NukePing:Destroy()
    end
end

function ControlCenterCaptured(newControlCenter, captor)
    ScenarioInfo.ControlCenterBldg = newControlCenter
    ScenarioInfo.ControlCenterBldg:SetCustomName(LOC '{i Black_Sun_Control_Tower}')
    ScenarioInfo.ControlCenterBldg:SetDoNotTarget(true)
    ScenarioInfo.ControlCenterBldg:SetRegenRate(5)
    local army = captor:GetArmy()

    -- Handle all human players as Player1
    for _, v in ScenarioInfo.HumanPlayers do
        if army == v then
            army = Player1
            break
        end
    end

    if(ScenarioInfo.ControlCenterPossession == Player1 and not army == Player1) then
        ScenarioFramework.Dialogue(OpStrings.X06_M02_160)
    elseif(not ScenarioInfo.ControlCenterPossession == Player1 and not army == Player1) then
        ScenarioFramework.Dialogue(OpStrings.X06_M02_200)
    end

    ScenarioInfo.OptionZeroNuke = ScenarioFramework.GiveUnitToArmy(ScenarioInfo.OptionZeroNuke, army)
    ScenarioInfo.OptionZeroNuke:SetCanTakeDamage(false)
    ScenarioInfo.OptionZeroNuke:SetCanBeKilled(false)
    ScenarioInfo.OptionZeroNuke:SetCapturable(false)
    ScenarioInfo.OptionZeroNuke:SetReclaimable(false)
    ScenarioInfo.OptionZeroNuke:SetIntelRadius('Vision', 0)

    if(army == Fletcher) then
        ScenarioInfo.ControlCenterPossession = Fletcher

        -- Remove any old timers and pings
        if(ScenarioInfo.NukeTimer) then
            KillThread(ScenarioInfo.NukeTimer)
        end
        if(ScenarioInfo.NukePing) then
            ScenarioInfo.NukePing:Destroy()
        end

        ScenarioFramework.Dialogue(OpStrings.X06_M02_170)
        M2OptionZeroFletcherNuke()
    elseif(army == Order) then
        ScenarioInfo.ControlCenterPossession = Order

        -- Remove any old timers and pings
        if(ScenarioInfo.NukeTimer) then
            KillThread(ScenarioInfo.NukeTimer)
        end
        if(ScenarioInfo.NukePing) then
            ScenarioInfo.NukePing:Destroy()
        end

        ScenarioFramework.Dialogue(OpStrings.X06_M02_180)
        M2OptionZeroOrderNuke()
    elseif(army == Rhiza) then
        ScenarioInfo.ControlCenterPossession = Rhiza

        -- Remove any old timers and pings
        if(ScenarioInfo.NukeTimer) then
            KillThread(ScenarioInfo.NukeTimer)
        end
        if(ScenarioInfo.NukePing) then
            ScenarioInfo.NukePing:Destroy()
        end

        M2OptionZeroRhizaNuke()
    elseif(army == Player1) then
        ScenarioInfo.ControlCenterPossession = Player1

        -- Remove any old timers
        if(ScenarioInfo.NukeTimer) then
            KillThread(ScenarioInfo.NukeTimer)
        end

        if(not ScenarioInfo.PlayerFirstCapture) then
            ScenarioFramework.Dialogue(OpStrings.X06_M02_155)
            ScenarioInfo.PlayerFirstCapture = true
        else
            ScenarioFramework.Dialogue(OpStrings.X06_M02_190)
        end
        ScenarioInfo.NukePing = PingGroups.AddPingGroup(OpStrings.X06_M01_OBJ_010_030, nil, 'attack', OpStrings.X06_M01_OBJ_010_040)
        ScenarioInfo.NukePing:AddCallback(M2OptionZeroPlayerNuke)
    end

    -- New trigger for Control Center to be recaptured/destroyed/reclaimed
    ScenarioFramework.CreateUnitCapturedTrigger(nil, ControlCenterCaptured, ScenarioInfo.ControlCenterBldg)
    ScenarioFramework.CreateUnitDeathTrigger(ControlCenterDestroyed, ScenarioInfo.ControlCenterBldg)
    ScenarioFramework.CreateUnitReclaimedTrigger(ControlCenterDestroyed, ScenarioInfo.ControlCenterBldg)
end

function M2OptionZeroFletcherNuke()
    local nukeLocations = {'M2_Player_Nuke_Marker', 'M2_Player_Resource_Nuke_Marker'}
    if(ScenarioInfo.ControlCenterPossession == Fletcher and ScenarioInfo.OptionZeroNuke and not ScenarioInfo.OptionZeroNuke:IsDead()) then
        ScenarioInfo.OptionZeroNuke:GiveNukeSiloAmmo(1)
        IssueNuke({ScenarioInfo.OptionZeroNuke}, ScenarioUtils.MarkerToPosition(nukeLocations[Random(1, 2)]))
        ScenarioInfo.NukeTimer = ScenarioFramework.CreateTimerTrigger(NukeTimer, 300)
        LOG('*DEBUG: fletcher launched nuke')
    end
end

function M2OptionZeroOrderNuke()
    local nukeLocations = {'M2_Player_Nuke_Marker', 'M2_Player_Resource_Nuke_Marker'}
    if(ScenarioInfo.ControlCenterPossession == Order and ScenarioInfo.OptionZeroNuke and not ScenarioInfo.OptionZeroNuke:IsDead()) then
        ScenarioInfo.OptionZeroNuke:GiveNukeSiloAmmo(1)
        IssueNuke({ScenarioInfo.OptionZeroNuke}, ScenarioUtils.MarkerToPosition(nukeLocations[Random(1, 2)]))
        ScenarioInfo.NukeTimer = ScenarioFramework.CreateTimerTrigger(NukeTimer, 300)
        LOG('*DEBUG: order launched nuke')
    end
end

function M2OptionZeroRhizaNuke()
    local nukeLocationsSeraphim = {'M3_Seraph_NukeTarget_9', 'M2_RhizaNukeTarget_3', 'M3_Rhiza_Naval_1'}
    local nukeFletcherOrder = {'M2_Fletcher_Base_Marker', 'M2_Order_Base_Marker'}
    local numS = table.getn(ArmyBrains[Seraphim]:GetListOfUnits(categories.STRUCTURE, false))
    local numO = table.getn(ArmyBrains[Order]:GetListOfUnits(categories.STRUCTURE, false))
    local numF = table.getn(ArmyBrains[Fletcher]:GetListOfUnits(categories.STRUCTURE, false))
    local M3nukeLocations = {'M3_Seraph_Return_Point_1', 'M3_Rhiza_Transport_3', 'M3_Rhiza_Transport_2', 'M2_Seraph_LandSouth_Def_3', 'M2_Seraph_LandSouth_Def_2'}

    if(ScenarioInfo.ControlCenterPossession == Rhiza and ScenarioInfo.OptionZeroNuke and not ScenarioInfo.OptionZeroNuke:IsDead()) then
        ScenarioInfo.OptionZeroNuke:GiveNukeSiloAmmo(1)

        if(ScenarioInfo.MissionNumber == 2) then

            -- nuke Seraphim
            if(numS >= 8) then
                IssueNuke({ScenarioInfo.OptionZeroNuke}, ScenarioUtils.MarkerToPosition(nukeLocationsSeraphim[Random(1, 3)]))
                LOG('*DEBUG: Rhiza launched nuke at Seraphim')

            -- nuke Order / Fletcher
            elseif(not ScenarioInfo.OrderACU:IsDead() and not ScenarioInfo.FletcherACU:IsDead()) then
                if(numO >= numF) then    -- Nuke Vendetta
                    IssueNuke({ScenarioInfo.OptionZeroNuke}, ScenarioUtils.MarkerToPosition(nukeFletcherOrder[2]))
                    LOG('*DEBUG: Rhiza launched nuke at Vendetta')
                elseif(numO < numF) then
                    IssueNuke({ScenarioInfo.OptionZeroNuke}, ScenarioUtils.MarkerToPosition(nukeFletcherOrder[1]))
                    LOG('*DEBUG: Rhiza launched nuke at Fletcher')
                end

            -- nuke Fletcher
            elseif(ScenarioInfo.OrderACU:IsDead() and not ScenarioInfo.FletcherACU:IsDead()) then
                IssueNuke({ScenarioInfo.OptionZeroNuke}, ScenarioUtils.MarkerToPosition(nukeFletcherOrder[1]))
                LOG('*DEBUG: Rhiza launched nuke at Fletcher')

            -- nuke Order
            elseif(not ScenarioInfo.OrderACU:IsDead() and ScenarioInfo.FletcherACU:IsDead()) then
                IssueNuke({ScenarioInfo.OptionZeroNuke}, ScenarioUtils.MarkerToPosition(nukeFletcherOrder[2]))
                LOG('*DEBUG: Rhiza launched nuke at Vendetta')

            end

        elseif(ScenarioInfo.MissionNumber == 3) then
            IssueNuke({ScenarioInfo.OptionZeroNuke}, ScenarioUtils.MarkerToPosition(M3nukeLocations[Random(1, 5)]))
            LOG('*DEBUG: Rhiza launched nuke at Seraphim Main Base')
        end

        ScenarioInfo.NukeTimer = ScenarioFramework.CreateTimerTrigger(NukeTimer, 300)
    end
end

function M2OptionZeroPlayerNuke(location)
    if(ScenarioInfo.ControlCenterPossession == Player1 and ScenarioInfo.OptionZeroNuke and not ScenarioInfo.OptionZeroNuke:IsDead()) then
        ScenarioInfo.NukePing:Destroy()
        ScenarioInfo.OptionZeroNuke:GiveNukeSiloAmmo(1)
        IssueNuke({ScenarioInfo.OptionZeroNuke}, location)
        ScenarioInfo.NukeTimer = ScenarioFramework.CreateTimerTrigger(NukeTimer, 300)
    end
end

function NukeTimer()
    if(ScenarioInfo.ControlCenterPossession == Fletcher) then
        M2OptionZeroFletcherNuke()
        LOG('*DEBUG: Fletcher ready to launch nuke')
    elseif(ScenarioInfo.ControlCenterPossession == Rhiza) then
        M2OptionZeroRhizaNuke()
        LOG('*DEBUG: Rhiza ready to launch nuke')
    elseif(ScenarioInfo.ControlCenterPossession == Order) then
        M2OptionZeroOrderNuke()
        LOG('*DEBUG: Order ready to launch nuke')
    elseif(ScenarioInfo.ControlCenterPossession == Player1) then
        ScenarioInfo.NukePing = PingGroups.AddPingGroup(OpStrings.X06_M01_OBJ_010_030, nil, 'attack', OpStrings.X06_M01_OBJ_010_040)
        ScenarioInfo.NukePing:AddCallback(M2OptionZeroPlayerNuke)
        LOG('*DEBUG: nuke timer fired, added nuke ping')
    end
end

function M2EndMission()
    -- ScenarioFramework.Dialogue(OpStrings.XXXXXXXXXXX, IntroMission3)
    -- Wait for the death spin around the enemy commander to finish
    ForkThread(
        function()
            if not ScenarioInfo.M2Finished then
                ScenarioInfo.M2Finished = true
                WaitSeconds(6)
                IntroMission3()     -- TODO: remove this call, and use the dialogue above for it, when new dialogue is added
            end
        end
   )
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

            -- Unit caps
            SetArmyUnitCap(Seraphim, 1200)

            ----------------
            -- M3 Seraphim AI
            ----------------
            M3SeraphimAI.SeraphimM3BaseAI()
            M3SeraphimAI.SeraphimM3WestBaseAI()
            M3SeraphimAI.SeraphimM3EastBaseAI()

            ----------------
            -- Thel-Uuthow CDR
            ----------------
            ScenarioInfo.Tau = ScenarioFramework.SpawnCommander('Seraphim', 'Tau', false, LOC '{i ThelUuthow}', true)
            if(Difficulty > 1) then
                ScenarioInfo.Tau:CreateEnhancement('DamageStabilizationAdvanced')
                ScenarioInfo.Tau:CreateEnhancement('RateOfFire')
                ScenarioInfo.Tau:CreateEnhancement('BlastAttack')
            end

            --------------------------
            -- Seraphim Initial Patrols
            --------------------------
            local units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M3_Seraph_AirNorth_Def_D' .. Difficulty, 'GrowthFormation')
            for k, v in units:GetPlatoonUnits() do
                ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M3_Seraph_AirNorth_Def_Chain')))
            end

            units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M3_Seraph_AirSouth_Def_D' .. Difficulty, 'GrowthFormation')
            for k, v in units:GetPlatoonUnits() do
                ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M3_Seraph_AirSouth_Def_Chain')))
            end

            for i = 1, 3 do
                units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M3_Seraph_LandNorth_Def_' .. i .. '_D' .. Difficulty, 'GrowthFormation')
                for k, v in units:GetPlatoonUnits() do
                    ScenarioFramework.GroupPatrolChain({v}, 'M3_Seraph_LandNorth_Def_Chain')
                end
            end

            for i = 1, 3 do
                units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M3_Seraph_LandSouth_Def_' .. i .. '_D' .. Difficulty, 'GrowthFormation')
                for k, v in units:GetPlatoonUnits() do
                    ScenarioFramework.GroupPatrolChain({v}, 'M3_Seraph_LandSouth_Def_Chain')
                end
            end

            units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M3_Seraph_NavalWest_Def_D' .. Difficulty, 'GrowthFormation')
            for k, v in units:GetPlatoonUnits() do
                ScenarioFramework.GroupPatrolChain({v}, 'M3_Seraph_NavalWest_Def_Chain')
            end

            units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M3_Seraph_NavalEast_Def_D' .. Difficulty, 'GrowthFormation')
            for k, v in units:GetPlatoonUnits() do
                ScenarioFramework.GroupPatrolChain({v}, 'M3_Seraph_NavalEast_Def_Chain')
            end

            -------------------------
            -- Seraphim Static Defense
            -------------------------
            ScenarioUtils.CreateArmyGroup('Seraphim', 'M3_Seraph_ExternalDef_D' .. Difficulty)

            ---------------
            -- Seraphim Rift
            ---------------
            ScenarioInfo.Rift1 = ScenarioUtils.CreateArmyUnit('Seraphim', 'Quantun_Rift_Support')
            ScenarioInfo.Rift2 = ScenarioUtils.CreateArmyUnit('Seraphim', 'Quantun_Rift_Support2')
            ScenarioInfo.Rift1:SetReclaimable(false)
            ScenarioInfo.Rift1:SetCapturable(false)
            if Difficulty == 2 then
                ScenarioInfo.Rift1:SetRegenRate(50)
                ScenarioInfo.Rift2:SetRegenRate(50)
            elseif Difficulty == 3 then
                ScenarioInfo.Rift1:SetRegenRate(200)
                ScenarioInfo.Rift2:SetRegenRate(200)
            end
            ScenarioInfo.Rift2:SetReclaimable(false)
            ScenarioInfo.Rift2:SetCapturable(false)
            ScenarioUtils.CreateArmyGroup('Seraphim', 'Rift_SideUnits')
            ForkThread(RiftHealth)
            ScenarioFramework.CreateUnitDeathTrigger(Rift1Dead, ScenarioInfo.Rift1)
            ScenarioFramework.CreateUnitDeathTrigger(Rift2Dead, ScenarioInfo.Rift2)

            ScenarioFramework.SetPlayableArea('M3Area')
            IntroMission3NIS()
        end
   )
end

function RiftHealth()
    while(ScenarioInfo.Rift1 and not ScenarioInfo.Rift1:IsDead() and ScenarioInfo.Rift2 and not ScenarioInfo.Rift2:IsDead()) do
        local health1 = ScenarioInfo.Rift1:GetHealth()
        local health2 = ScenarioInfo.Rift2:GetHealth()

        if(health1 < health2) then
            ScenarioInfo.Rift2:SetHealth(ScenarioInfo.Rift2, health1)
        elseif(health2 < health1) then
            ScenarioInfo.Rift1:SetHealth(ScenarioInfo.Rift1, health2)
        end
        WaitSeconds(.5)
    end
end

function Rift1Dead()
    if(ScenarioInfo.Rift2 and not ScenarioInfo.Rift2:IsDead()) then
        ScenarioInfo.Rift2:Kill()
    end
end

function Rift2Dead()
    if(ScenarioInfo.Rift1 and not ScenarioInfo.Rift1:IsDead()) then
        ScenarioInfo.Rift1:Kill()
    end
end

function IntroMission3NIS()
    ForkThread(
        function()
            ScenarioFramework.Dialogue(OpStrings.X06_M02_240, nil, true)
            ScenarioFramework.Dialogue(OpStrings.X06_M02_250, nil, true)

            Cinematics.EnterNISMode()
            Cinematics.SetInvincible('M2Area')

            -- Begin rift spawn, and a timer to increase the rift spawn speed
            -- ScenarioFramework.CreateTimerTrigger(RiftStartWave, 15)
            ForkThread(RiftNISWave)
            ForkThread(Rift)

            local VisMarker1 = ScenarioFramework.CreateVisibleAreaLocation(30, ScenarioUtils.MarkerToPosition('NIS_M3_Reveal_1'), 0, ArmyBrains[Player1])
            local VisMarker2 = ScenarioFramework.CreateVisibleAreaLocation(20, ScenarioUtils.MarkerToPosition('NIS_M3_Reveal_2'), 0, ArmyBrains[Player1])
            local VisMarker3 = ScenarioFramework.CreateVisibleAreaLocation(20, ScenarioUtils.MarkerToPosition('NIS_M3_Reveal_3'), 0, ArmyBrains[Player1])

            WaitSeconds(1)
            Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_3_1'), 0)
            WaitSeconds(1)
            Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_3_2'), 8)
            WaitSeconds(3)
            Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_3_3'), 4)
            WaitSeconds(3)

            Cinematics.SetInvincible('M2Area', true)
            Cinematics.ExitNISMode()
            VisMarker1:Destroy()
            VisMarker2:Destroy()
            VisMarker3:Destroy()

            StartMission3()
        end
   )
end

function StartMission3()
    M3SeraphimCounterattack()

    -- Taunts
    SetupTauTauntTriggers()
    SetupHQTauntTriggers()

    -- Mixed VO exchange, general and faction-specific
    ScenarioFramework.Dialogue(OpStrings.X06_M03_010)
    if(LeaderFaction == 'uef') then
        ScenarioFramework.Dialogue(OpStrings.X06_M03_020)
    elseif(LeaderFaction == 'cybran') then
        ScenarioFramework.Dialogue(OpStrings.X06_M03_030)
    elseif(LeaderFaction == 'aeon') then
        ScenarioFramework.Dialogue(OpStrings.X06_M03_040)
    end
    ScenarioFramework.Dialogue(OpStrings.X06_M03_050, nil, nil, ScenarioInfo.RhizaACU)

    -------------------------------------------
    -- Primary Objective 1 - Destroy the Archway
    -------------------------------------------
    ScenarioInfo.M3P1 = Objectives.Kill(
        'primary',                      -- type
        'incomplete',                   -- complete
        OpStrings.X06_M03_OBJ_010_010,  -- title
        OpStrings.X06_M03_OBJ_010_020,  -- description
        {                               -- target
            Units = {ScenarioInfo.Rift1, ScenarioInfo.Rift2},
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
    ScenarioFramework.CreateTimerTrigger(M3P1Reminder1, 600)

    ScenarioFramework.CreateTimerTrigger(NukeRhiza1, 30)
    ScenarioFramework.CreateTimerTrigger(NukeRhiza2, 90)
    ScenarioFramework.CreateTimerTrigger(NukeRhiza3, 150)
    ScenarioFramework.CreateTimerTrigger(IntroM3S1, 60)
    ScenarioFramework.CreateTimerTrigger(M3Subplot, 300)
    ScenarioFramework.CreateTimerTrigger(NukePlayer, 720)

    if(Difficulty == 2) then
        ScenarioFramework.CreateTimerTrigger(M3ExpBot, 420)
        ScenarioFramework.CreateTimerTrigger(M3RiftGunships, 600)
        ScenarioFramework.CreateTimerTrigger(M3RiftAirSups, 540)
    elseif(Difficulty == 3) then
        ScenarioFramework.CreateTimerTrigger(M3ExpBot, 300)
        ScenarioFramework.CreateTimerTrigger(M3ExpBomber, 420)
        ScenarioFramework.CreateTimerTrigger(M3RiftGunships, 420)
        ScenarioFramework.CreateTimerTrigger(M3RiftAirSups, 360)
    end
    ScenarioFramework.CreateTimerTrigger(M3SACU, 240)
end

function M3ExpBot()
    if(GetArmyUnitCostTotal(Seraphim) < 1000) then
        local limit = 3
        if(Difficulty == 3) then
            limit = 5
        end

        local num = table.getn(ArmyBrains[Seraphim]:GetListOfUnits(categories.xsl0401, false))
        if(num < limit) then
            -- spawn in exp bot
            local unit = ScenarioUtils.CreateArmyUnit('Seraphim', 'M2_Rift_ExpBot')
            if(Difficulty == 3) then
                unit:SetVeterancy(5)
            end
            ForkThread(
                function()
                    EffectUtilities.SeraphimRiftIn(unit)
                    IssueMove({unit}, ScenarioUtils.MarkerToPosition('Rift_InitialMove_5'))
                    IssueAggressiveMove({unit}, ScenarioUtils.MarkerToPosition('Rift_InitialMoveb_5'))
                    IssueAggressiveMove({unit}, ScenarioUtils.MarkerToPosition('Rift_SecondMove_5'))

                    local chains = {'M3_Rift_LandEast_Chain', 'M3_Rift_LandMid_Chain', 'M3_Rift_LandWest_Chain'}
                    ScenarioFramework.GroupPatrolChain({unit}, chains[Random(1, 3)])
                end
           )
        end
    end
    if(Difficulty == 2) then
        ScenarioFramework.CreateTimerTrigger(M3ExpBot, 420)
    else
        ScenarioFramework.CreateTimerTrigger(M3ExpBot, 300)
    end
end

function M3ExpBomber()
    if(GetArmyUnitCostTotal(Seraphim) < 1000) then
        local num = table.getn(ArmyBrains[Seraphim]:GetListOfUnits(categories.xsa0402, false))
        if(num < 1) then
            -- spawn in exp bomber
            local unit = ScenarioUtils.CreateArmyUnit('Seraphim', 'M2_Rift_ExpBomber')
            unit:SetVeterancy(5)

            ForkThread(
                function()
                    EffectUtilities.SeraphimRiftIn(unit)
                    local chains = {'M3_Rift_LandEast_Chain', 'M3_Rift_LandMid_Chain', 'M3_Rift_LandWest_Chain'}
                    ScenarioFramework.GroupPatrolChain({unit}, chains[Random(1, 3)])
                end
           )
        end
    end
    ScenarioFramework.CreateTimerTrigger(M3ExpBomber, 420)
end

function M3SACU()
    if(GetArmyUnitCostTotal(Seraphim) < 1000) then
        local num = table.getn(ArmyBrains[Seraphim]:GetListOfUnits(categories.xsl0301, false))
        if(num < 1) then
            -- spawn in sACU
            local unit = ScenarioUtils.CreateArmyUnit('Seraphim', 'M2_Rift_sACU')
            if(Difficulty > 1) then
                -- give shield
                unit:CreateEnhancement('Shield')
                if(Difficulty == 3) then
                    unit:SetVeterancy(5)
                end
            end

            ForkThread(
                function()
                    EffectUtilities.SeraphimRiftIn(unit)
                    IssueMove({unit}, ScenarioUtils.MarkerToPosition('Rift_InitialMove_5'))
                    IssueAggressiveMove({unit}, ScenarioUtils.MarkerToPosition('Rift_InitialMoveb_5'))
                    IssueAggressiveMove({unit}, ScenarioUtils.MarkerToPosition('Rift_SecondMove_5'))

                    local chains = {'M3_Rift_LandEast_Chain', 'M3_Rift_LandMid_Chain', 'M3_Rift_LandWest_Chain'}
                    ScenarioFramework.GroupPatrolChain({unit}, chains[Random(1, 3)])
                end
           )
        end
    end
    ScenarioFramework.CreateTimerTrigger(M3SACU, 240)
end

function M3RiftGunships()
    ForkThread(
        function()
            local exp = {}
            local limit = 3
            local numGunships = 8
            local timer = 600
            if(Difficulty == 3) then
                limit = 1
                numGunships = 12
                timer = 420
            end

            local searching = true
            while(searching) do
                if(GetArmyUnitCostTotal(Seraphim) < 1000) then
                    local expNum = ScenarioFramework.GetNumOfHumanUnits((categories.EXPERIMENTAL * categories.LAND) + (categories.EXPERIMENTAL * categories.STRUCTURE), false)
                    if(expNum > limit) then
                        searching = false
                    end
                end
                WaitSeconds(1)
            end

            for i = 1, numGunships do
                local position = Random(1, 9)
                local unit = ScenarioUtils.CreateArmyUnit('Seraphim', 'RiftGunship_' .. position)
                unit:SetVeterancy(5)

                ForkThread(
                    function()
                        EffectUtilities.SeraphimRiftIn(unit)
                        for j = 1, table.getn(exp) do
                            if(exp[j] and not exp[j]:IsDead()) then
                                IssueAttack({unit}, exp[j])
                            end
                        end
                        local chains = {'M3_Rift_LandEast_Chain', 'M3_Rift_LandMid_Chain', 'M3_Rift_LandWest_Chain'}
                        ScenarioFramework.GroupPatrolChain({unit}, chains[Random(1, 3)])
                    end
               )
            end

            ScenarioFramework.CreateTimerTrigger(M3RiftGunships, timer)
        end
   )
end

function M3RiftAirSups()
    ForkThread(
        function()
            local exp = {}
            local limit = 3
            local numAirSups = 8
            local timer = 600
            if(Difficulty == 3) then
                limit = 1
                numAirSups = 12
                timer = 420
            end

            local searching = true
            while(searching) do
                if(GetArmyUnitCostTotal(Seraphim) < 1000) then
                    local expNum = ScenarioFramework.GetNumOfHumanUnits(categories.EXPERIMENTAL * categories.AIR, false)
                    if(expNum > limit) then
                        searching = false
                    end
                end
                WaitSeconds(1)
            end

            for i = 1, numAirSups do
                local position = Random(1, 9)
                local unit = ScenarioUtils.CreateArmyUnit('Seraphim', 'RiftSup_' .. position)
                unit:SetVeterancy(5)

                ForkThread(
                    function()
                        EffectUtilities.SeraphimRiftIn(unit)
                        for j = 1, table.getn(exp) do
                            if(exp[j] and not exp[j]:IsDead()) then
                                IssueAttack({unit}, exp[j])
                            end
                        end
                        local chains = {'M3_Rift_LandEast_Chain', 'M3_Rift_LandMid_Chain', 'M3_Rift_LandWest_Chain'}
                        ScenarioFramework.GroupPatrolChain({unit}, chains[Random(1, 3)])
                    end
               )
            end

            ScenarioFramework.CreateTimerTrigger(M3RiftAirSups, timer)
        end
   )
end

function NukePlayer()
    if(ScenarioInfo.NukesLaunched < ScenarioInfo.NukesAllowed[Difficulty]) then
        local marker = nil
        local numUnits = 0
        local searching = true
        while(searching) do
            WaitSeconds(5)
            for i = 1, 10 do
                local num = table.getn(ArmyBrains[Seraphim]:GetUnitsAroundPoint((categories.TECH2 * categories.STRUCTURE) + (categories.TECH3 * categories.STRUCTURE), ScenarioUtils.MarkerToPosition('M3_Seraph_NukeTarget_' .. i), 30, 'enemy'))
                if(num > 3) then
                    if(num > numUnits) then
                        numUnits = num
                        marker = 'M3_Seraph_NukeTarget_' .. i
                    end
                end
                if(i == 10 and marker) then
                    searching = false
                end
            end
        end
        if(ScenarioInfo.UnitNames[Seraphim]['M3_Seraph_Nuke'] and not ScenarioInfo.UnitNames[Seraphim]['M3_Seraph_Nuke']:IsDead()) then
            ScenarioInfo.UnitNames[Seraphim]['M3_Seraph_Nuke']:GiveNukeSiloAmmo(1)
            IssueNuke({ScenarioInfo.UnitNames[Seraphim]['M3_Seraph_Nuke']}, ScenarioUtils.MarkerToPosition(marker))
            ScenarioInfo.NukesLaunched = ScenarioInfo.NukesLaunched + 1
        end
        ScenarioFramework.CreateTimerTrigger(NukePlayer, 720)
    end
end

function M3SeraphimCounterattack()
    local quantity = {}
    local trigger = {}
    local units = {}

    ----------------
    -- Counter Attack
    ----------------

    -- Spawns naval attacks for every 15, 10, 5 T2/T3 naval boats, max 3, 4, 5 groups
    quantity = {3, 4, 5}
    trigger = {15, 10, 5}
    local num = ScenarioFramework.GetNumOfHumanUnits((categories.MOBILE * categories.NAVAL) - categories.TECH1, false)

    if(num > 0) then
        num = math.ceil(num/trigger[Difficulty])
        if(num > quantity[Difficulty]) then
            num = quantity[Difficulty]
        end
        for i = 1, num do
            if(i < 3) then
                units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M3_Seraph_NavWest_Adapt_' .. i, 'GrowthFormation')
                ScenarioFramework.PlatoonPatrolChain(units, 'M3_Seraph_Naval_West1_Attack_Chain')
            elseif (i >= 3 and i < 5) then
                units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M3_Seraph_NavEast_Adapt_' .. i, 'GrowthFormation')
                ScenarioFramework.PlatoonPatrolChain(units, 'M3_Seraph_Naval_East_Attack_Chain')
            end
        end
    end

    -- Spawns air superiority for every 25, 20, 15 planes, max 4, 5, 6 groups
    quantity = {4, 5, 6}
    trigger = {25, 20, 15}
    local num = ScenarioFramework.GetNumOfHumanUnits(categories.MOBILE * categories.AIR, false)

    if(num > 0) then
        num = math.ceil(num/trigger[Difficulty])
        if(num > quantity[Difficulty]) then
            num = quantity[Difficulty]
        end
        for i = 1, num do
            units = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Seraphim', 'M3_Seraph_Air_Adapt_AirSup', 'GrowthFormation', 5)
            for k, v in units:GetPlatoonUnits() do
                ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M3_Seraph_AirAttack_' .. Random(1, 3) .. '_Chain')))
            end
        end
    end

    -- Experimental & HLRA & Battleship Response, max 6, 12, 18 groups
    quantity = {6, 12, 18}
    local experimentals = ScenarioFramework.GetListOfHumanUnits((categories.EXPERIMENTAL - categories.AIR) + (categories.TECH3 * categories.STRUCTURE * categories.ARTILLERY) + categories.BATTLESHIP, false)
    num = table.getn(experimentals)
    if(num > 0) then
        if(num > quantity[Difficulty]) then
            num = quantity[Difficulty]
        end
        for i = 1, num do
            units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M3_Seraph_Air_Adapt_Bomber', 'GrowthFormation')
            IssueAttack(units:GetPlatoonUnits(), experimentals[i])
            ScenarioFramework.PlatoonPatrolChain(units, 'M3_Seraph_AirAttack_' .. Random(1, 3) .. '_Chain')
        end
    end

    -- Spawns gunships for every 4, 3, 2 shields, max 3, 5, 7 groups
    quantity = {3, 5, 7}
    trigger = {4, 3, 2}
    local num = ScenarioFramework.GetNumOfHumanUnits(categories.STRUCTURE * categories.SHIELD, false)

    if(num > 0) then
        num = math.ceil(num/trigger[Difficulty])
        if(num > quantity[Difficulty]) then
            num = quantity[Difficulty]
        end
        for i = 1, num do
            units = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Seraphim', 'M3_Seraph_Air_Adapt_Gunship', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(units, 'M3_Seraph_AirAttack_' .. Random(1, 2) .. '_Chain')
        end
    end

    -- Spawns siege tanks if player has 475, 350, 1 units
    trigger = {475, 350, 1}
    local num = ScenarioFramework.GetNumOfHumanUnits(categories.ALLUNITS, false)

    if(num >= trigger[Difficulty]) then
        units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M3_Seraph_Land_Adapt_1', 'GrowthFormation')
        ScenarioFramework.PlatoonPatrolChain(units, 'M3_Seraph_LandAttack1_Chain')
    end

    -- Spawns siege tanks if player has 100, 60, 20 t3 land units
    trigger = {100, 60, 20}
    local num = ScenarioFramework.GetNumOfHumanUnits((categories.MOBILE * categories.LAND * categories.TECH3) - categories.CONSTRUCTION, false)

    if(num >= trigger[Difficulty]) then
        units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M3_Seraph_Land_Adapt_3', 'GrowthFormation')
        ScenarioFramework.PlatoonPatrolChain(units, 'M3_Seraph_LandAttack2_Chain')
    end

    -- Spawns mobile artillery if player has 6, 3, 1 experimentals
    trigger = {6, 3, 1}
    local num = ScenarioFramework.GetNumOfHumanUnits(categories.EXPERIMENTAL + (categories.TECH3 * categories.STRUCTURE * categories.ARTILLERY), false)

    if(num >= trigger[Difficulty]) then
        units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M3_Seraph_Land_Adapt_2', 'GrowthFormation')
        ScenarioFramework.PlatoonPatrolChain(units, 'M3_Seraph_LandAttack1_Chain')
    end

    -- Spawns experimental if player has 1 experimental or hlra on easy, spawns regardless on med/hard
    if(Difficulty == 1) then
        local num = ScenarioFramework.GetNumOfHumanUnits(categories.EXPERIMENTAL + (categories.TECH3 * categories.STRUCTURE * categories.ARTILLERY), false)

        if(num >= 1) then
            local exp = ScenarioUtils.CreateArmyUnit('Seraphim', 'M3_Seraph_Adapt_Exp_1')
            local platoon = ArmyBrains[Seraphim]:MakePlatoon('', '')
            ArmyBrains[Seraphim]:AssignUnitsToPlatoon(platoon, {exp}, 'Attack', 'GrowthFormation')
            ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_Seraph_LandAttack1_Chain')
        end
    else
        local exp = ScenarioUtils.CreateArmyUnit('Seraphim', 'M3_Seraph_Adapt_Exp_1')
        local platoon = ArmyBrains[Seraphim]:MakePlatoon('', '')
        ArmyBrains[Seraphim]:AssignUnitsToPlatoon(platoon, {exp}, 'Attack', 'GrowthFormation')
        ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_Seraph_LandAttack1_Chain')
    end

    -- Spawns experimental if player has 475, 350, 1 units
    trigger = {475, 350, 1}
    local num = ScenarioFramework.GetNumOfHumanUnits(categories.ALLUNITS, false)

    if(num >= trigger[Difficulty]) then
        local exp = ScenarioUtils.CreateArmyUnit('Seraphim', 'M3_Seraph_Adapt_Exp_2')
        local platoon = ArmyBrains[Seraphim]:MakePlatoon('', '')
        ArmyBrains[Seraphim]:AssignUnitsToPlatoon(platoon, {exp}, 'Attack', 'GrowthFormation')
        ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_Seraph_LandAttack1_Chain')
    end

    -- Spawns experimental if player has 5, 3, 1 experimental or hlra
    trigger = {5, 3, 1}
    local num = ScenarioFramework.GetNumOfHumanUnits(categories.EXPERIMENTAL + (categories.TECH3 * categories.STRUCTURE * categories.ARTILLERY), false)

    if(num >= trigger[Difficulty]) then
        local exp = ScenarioUtils.CreateArmyUnit('Seraphim', 'M3_Seraph_Adapt_Exp_3')
        local platoon = ArmyBrains[Seraphim]:MakePlatoon('', '')
        ArmyBrains[Seraphim]:AssignUnitsToPlatoon(platoon, {exp}, 'Attack', 'GrowthFormation')
        ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_Seraph_LandAttack1_Chain')
    end

    -- Spawns transport attacks for every 3, 1, 1 shields, max 6, 8, 10 groups
    quantity = {6, 8, 10}
    trigger = {3, 1, 1}
    local num = ScenarioFramework.GetNumOfHumanUnits(categories.STRUCTURE * categories.SHIELD, false)

    if(num > 0) then
        num = math.ceil(num/trigger[Difficulty])
        if(num > quantity[Difficulty]) then
            num = quantity[Difficulty]
        end
        for i = 1, num do
            units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M3_Seraph_Adapt_Xport_1', 'GrowthFormation')
            ScenarioFramework.PlatoonAttackWithTransports(units, 'M3_Seraph_Transport1_Landing_Chain', 'M3_Seraph_Transport1_Attack_Chain', false)
        end
    end
end

function Rift()
    -- ScenarioInfo.Count = 0
    ForkThread(
        function()
            while(ScenarioInfo.Rift1 and not ScenarioInfo.Rift1:IsDead() and ScenarioInfo.Rift2 and not ScenarioInfo.Rift2:IsDead()) do
                if(GetArmyUnitCostTotal(Seraphim) < 1000) then
                    local tier = Random(1, 5)
                    -- use one of three selections/tiers of units that exists at each of ten locations.
                    -- 40% chance tier1, 40% chance tier2, 20% chance tier3

                    if Difficulty == 1 then
                        tier = tier - 1
                    elseif Difficulty == 3 then
                        tier = tier + 1
                    end

                    -- #Tier 1, easier units
                    if(tier < 3) then
                        -- pick one of the 10 locations on the rift line, and one of the 5 units available there in tier 1
                        local position = Random(1, 10)
                        local unitNum = Random(1, 2)

                        local unit = ScenarioUtils.CreateArmyUnit('Seraphim', position .. '_' .. unitNum)
                        if(Difficulty == 3) then
                            unit:SetVeterancy(5)
                        elseif(ScenarioInfo.Trickle and Difficulty == 2) then
                            unit:SetVeterancy(5)
                        end
                        -- ScenarioInfo.Count = ScenarioInfo.Count + 1
                        ForkThread(
                            function()
                                EffectUtilities.SeraphimRiftIn(unit)

                                -- force the land units away from the rift, then on with normal behavior to the
                                -- start of the 3 main land attack chains
                                IssueMove({unit}, ScenarioUtils.MarkerToPosition('Rift_InitialMove_' .. position))
                                IssueAggressiveMove({unit}, ScenarioUtils.MarkerToPosition('Rift_InitialMoveb_' .. position))
                                IssueAggressiveMove({unit}, ScenarioUtils.MarkerToPosition('Rift_SecondMove_' .. position))

                                if(position < 4) then
                                    ScenarioFramework.GroupPatrolChain({unit}, 'M3_Rift_LandEast_Chain')
                                elseif(position > 3 and position < 8) then
                                    ScenarioFramework.GroupPatrolChain({unit}, 'M3_Rift_LandMid_Chain')
                                else
                                    ScenarioFramework.GroupPatrolChain({unit}, 'M3_Rift_LandWest_Chain')
                                end
                            end
                       )

                    -- Tier 2, medium-strength units
                    elseif(tier > 2 and tier < 5) then
                        local position = Random(1, 10)
                        local unitNum = Random(21, 26)

                        local unit = ScenarioUtils.CreateArmyUnit('Seraphim', position .. '_' .. unitNum)
                        if(Difficulty == 3) then
                            unit:SetVeterancy(5)
                        elseif(ScenarioInfo.Trickle and Difficulty == 2) then
                            unit:SetVeterancy(5)
                        end
                        -- ScenarioInfo.Count = ScenarioInfo.Count + 1
                        -- if we spawned a mobile shield (number 26 in the series), then disable the shield for a period so the warp
                        -- in effect can play
                        if unitNum == 26 then
                           ForkThread(TempShieldDisable, unit)
                        end
                        ForkThread(
                            function()
                                EffectUtilities.SeraphimRiftIn(unit)

                                IssueMove({unit}, ScenarioUtils.MarkerToPosition('Rift_InitialMove_' .. position))
                                IssueAggressiveMove({unit}, ScenarioUtils.MarkerToPosition('Rift_InitialMoveb_' .. position))
                                IssueAggressiveMove({unit}, ScenarioUtils.MarkerToPosition('Rift_SecondMove_' .. position))

                                if(position < 4) then
                                    ScenarioFramework.GroupPatrolChain({unit}, 'M3_Rift_LandEast_Chain')
                                elseif(position > 3 and position < 8) then
                                    ScenarioFramework.GroupPatrolChain({unit}, 'M3_Rift_LandMid_Chain')
                                else
                                    ScenarioFramework.GroupPatrolChain({unit}, 'M3_Rift_LandWest_Chain')
                                end
                            end
                       )

                    -- Tier 3, very tough units
                    elseif(tier >= 5) then
                        local position = Random(1, 10)
                        local unitNum = Random(41, 44)

                        local unitType = nil
                        if(unitNum < 44) then
                            unitType = 'Land'
                        else
                            unitType = 'Air'
                        end

                        local unit = ScenarioUtils.CreateArmyUnit('Seraphim', position .. '_' .. unitNum)
                        if(Difficulty == 3) then
                            unit:SetVeterancy(5)
                        elseif(ScenarioInfo.Trickle and Difficulty == 2) then
                            unit:SetVeterancy(5)
                        end
                        -- ScenarioInfo.Count = ScenarioInfo.Count + 1
                        ForkThread(
                            function()
                                EffectUtilities.SeraphimRiftIn(unit)

                                if(unitType == 'Land') then
                                    IssueMove({unit}, ScenarioUtils.MarkerToPosition('Rift_InitialMove_' .. position))
                                    IssueAggressiveMove({unit}, ScenarioUtils.MarkerToPosition('Rift_InitialMoveb_' .. position))
                                    IssueAggressiveMove({unit}, ScenarioUtils.MarkerToPosition('Rift_SecondMove_' .. position))
                                end

                                if(position < 4) then
                                    ScenarioFramework.GroupPatrolChain({unit}, 'M3_Rift_' .. unitType .. 'East_Chain')
                                elseif(position > 3 and position < 8) then
                                    ScenarioFramework.GroupPatrolChain({unit}, 'M3_Rift_' .. unitType .. 'Mid_Chain')
                                else
                                    ScenarioFramework.GroupPatrolChain({unit}, 'M3_Rift_' .. unitType .. 'West_Chain')
                                end
                            end
                       )
                    end
                end
                WaitSeconds(RiftTickTime)
            end
        end
   )
end

function RiftEndWave()
    -- set the pause between unit spawns at rift to back down to normal slow speed
    -- Timer to start of new wave
    RiftTickTime = RiftNormalSpeed
    -- ScenarioInfo.Count = 0
    ScenarioInfo.Trickle = true

    ScenarioFramework.CreateTimerTrigger(RiftStartWave, TimeBetweenWaves[Difficulty])
end

function RiftStartWave()
    -- set the pause between unit spawns at rift up to to "wave" speed
    -- Timer to when we will end this wave
    RiftTickTime = RiftFastSpeed[Difficulty]
    -- ScenarioInfo.Count = 0
    ScenarioInfo.Trickle = false

    ScenarioFramework.CreateTimerTrigger(RiftEndWave, WaveDuration)
end

function RiftNISWave()
    -- set the pause between unit spawns at rift up to to "wave" speed
    -- Timer to when we will end this wave
    RiftTickTime = RiftNISSpeed

    ScenarioFramework.CreateTimerTrigger(RiftEndWave, WaveDurationNIS)
end

function TempShieldDisable(unit)
    if (unit and not unit:IsDead()) then
        unit:DisableShield()
    end
    WaitSeconds(3.5)
    if (unit and not unit:IsDead()) then
        unit:EnableShield()
    end
end

function NukeRhiza1()
    if(ScenarioInfo.UnitNames[Seraphim]['M3_Seraph_Nuke'] and not ScenarioInfo.UnitNames[Seraphim]['M3_Seraph_Nuke']:IsDead() and ScenarioInfo.RhizaACU and not ScenarioInfo.RhizaACU:IsDead()) then
        ScenarioInfo.UnitNames[Seraphim]['M3_Seraph_Nuke']:GiveNukeSiloAmmo(1)
        IssueNuke({ScenarioInfo.UnitNames[Seraphim]['M3_Seraph_Nuke']}, ScenarioUtils.MarkerToPosition('Rhiza_Land_Nuke_Point'))
    end
end

function NukeRhiza2()
    if(ScenarioInfo.UnitNames[Seraphim]['M3_Seraph_Nuke'] and not ScenarioInfo.UnitNames[Seraphim]['M3_Seraph_Nuke']:IsDead() and ScenarioInfo.RhizaACU and not ScenarioInfo.RhizaACU:IsDead()) then
        ScenarioInfo.UnitNames[Seraphim]['M3_Seraph_Nuke']:GiveNukeSiloAmmo(1)
        IssueNuke({ScenarioInfo.UnitNames[Seraphim]['M3_Seraph_Nuke']}, ScenarioUtils.MarkerToPosition('Rhiza_Naval_Nuke_Point'))
    end
end

function NukeRhiza3()
    -- TODO: new nuke point for this
    if(ScenarioInfo.UnitNames[Seraphim]['M3_Seraph_Nuke'] and not ScenarioInfo.UnitNames[Seraphim]['M3_Seraph_Nuke']:IsDead() and ScenarioInfo.RhizaACU and not ScenarioInfo.RhizaACU:IsDead()) then
        ScenarioInfo.UnitNames[Seraphim]['M3_Seraph_Nuke']:GiveNukeSiloAmmo(1)
        IssueNuke({ScenarioInfo.UnitNames[Seraphim]['M3_Seraph_Nuke']}, ScenarioUtils.MarkerToPosition('Rhiza_Land_Nuke2_Point'))
    end
end

function IntroM3S1()
    ScenarioFramework.Dialogue(OpStrings.X06_M03_200)
    ScenarioFramework.Dialogue(OpStrings.X06_M03_210, AssignM3S1)
end

function AssignM3S1()
    ------------------------------------
    -- Secondary Objective 1 - Defeat Tau
    ------------------------------------
    ScenarioInfo.M3S1 = Objectives.KillOrCapture(
        'secondary',                    -- type
        'incomplete',                   -- complete
        OpStrings.X06_M03_OBJ_010_030,  -- title
        OpStrings.X06_M03_OBJ_010_040,  -- description
        {                               -- target
            Units = {ScenarioInfo.Tau},
        }
   )
    ScenarioInfo.M3S1:AddResultCallback(
        function(result)
            if(result) then
                ScenarioFramework.CDRDeathNISCamera(ScenarioInfo.Tau, 5)
                ScenarioFramework.Dialogue(OpStrings.X06_M03_240)
            end
        end
   )
    table.insert(AssignedObjectives, ScenarioInfo.M3S1)
    ScenarioFramework.CreateTimerTrigger(M3S1Reminder1, 1200)
end

function M3Subplot()
    ScenarioFramework.Dialogue(OpStrings.X06_M03_060)
end

------------
-- Taunts
------------

function SetupVedettaTauntTriggers()
    VedettaTM:AddTauntingCharacter(ScenarioInfo.OrderACU)

    -- On losing defensive structures
    VedettaTM:AddUnitsKilledTaunt('TAUNT29', ArmyBrains[Order], categories.STRUCTURE * categories.DEFENSE, 12)
    VedettaTM:AddUnitsKilledTaunt('TAUNT8', ArmyBrains[Order], categories.STRUCTURE * categories.DEFENSE, 30)

    if(LeaderFaction == 'uef') then
        VedettaTM:AddEnemiesKilledTaunt('TAUNT22', ArmyBrains[Order], categories.ALLUNITS, 25)
        VedettaTM:AddEnemiesKilledTaunt('TAUNT23', ArmyBrains[Order], categories.ALLUNITS, 55)
    elseif(LeaderFaction == 'cybran') then
        VedettaTM:AddEnemiesKilledTaunt('TAUNT24', ArmyBrains[Order], categories.ALLUNITS, 25)
        VedettaTM:AddEnemiesKilledTaunt('TAUNT25', ArmyBrains[Order], categories.ALLUNITS, 55)
    elseif(LeaderFaction == 'aeon') then
        VedettaTM:AddEnemiesKilledTaunt('TAUNT26', ArmyBrains[Order], categories.ALLUNITS, 25)
        VedettaTM:AddEnemiesKilledTaunt('TAUNT27', ArmyBrains[Order], categories.ALLUNITS, 55)
    end

end

function SetupFletcherTauntTriggers()
    FletcherTM:AddTauntingCharacter(ScenarioInfo.FletcherACU)

    FletcherTM:AddUnitsKilledTaunt('TAUNT34', ArmyBrains[Fletcher], categories.MOBILE, 50)
    FletcherTM:AddUnitsKilledTaunt('TAUNT35', ArmyBrains[Fletcher], categories.MOBILE, 100)

    FletcherTM:AddUnitsKilledTaunt('TAUNT37', ArmyBrains[Fletcher], categories.STRUCTURE * categories.DEFENSE, 13)

    FletcherTM:AddEnemiesKilledTaunt('TAUNT41', ArmyBrains[Fletcher], categories.STRUCTURE * categories.ECONOMIC, 13)
    FletcherTM:AddEnemiesKilledTaunt('TAUNT39', ArmyBrains[Fletcher], categories.ALLUNITS, 50)
    FletcherTM:AddEnemiesKilledTaunt('TAUNT48', ArmyBrains[Fletcher], categories.ALLUNITS, 100)
-- FletcherTM:AddEnemiesKilledTaunt('TAUNT50', ArmyBrains[Fletcher], categories.TECH3, 35)
    FletcherTM:AddEnemiesKilledTaunt('TAUNT48', ArmyBrains[Fletcher], categories.EXPERIMENTAL, 1)
    FletcherTM:AddEnemiesKilledTaunt('TAUNT6', ArmyBrains[Player1], categories.UEF, 40)

    if(LeaderFaction == 'uef') then
        FletcherTM:AddUnitsKilledTaunt('TAUNT36', ArmyBrains[Fletcher], categories.STRUCTURE * categories.DEFENSE, 2)
        FletcherTM:AddEnemiesKilledTaunt('TAUNT42', ArmyBrains[Fletcher], categories.ALLUNITS, 25)
        FletcherTM:AddEnemiesKilledTaunt('TAUNT43', ArmyBrains[Fletcher], categories.ALLUNITS, 55)
    elseif(LeaderFaction == 'cybran') then
        FletcherTM:AddEnemiesKilledTaunt('TAUNT44', ArmyBrains[Fletcher], categories.ALLUNITS, 25)
        FletcherTM:AddEnemiesKilledTaunt('TAUNT45', ArmyBrains[Fletcher], categories.ALLUNITS, 55)
    elseif(LeaderFaction == 'aeon') then
        FletcherTM:AddEnemiesKilledTaunt('TAUNT46', ArmyBrains[Fletcher], categories.ALLUNITS, 25)
        FletcherTM:AddEnemiesKilledTaunt('TAUNT47', ArmyBrains[Fletcher], categories.ALLUNITS, 55)
    end
end

function SetupTauTauntTriggers()
    TauTM:AddTauntingCharacter(ScenarioInfo.Tau)

    TauTM:AddUnitsKilledTaunt('TAUNT4', ArmyBrains[Seraphim], categories.xsb4301, 1)
    TauTM:AddUnitsKilledTaunt('TAUNT7', ArmyBrains[Seraphim], categories.STRUCTURE * categories.ECONOMIC, 10)
    TauTM:AddEnemiesKilledTaunt('TAUNT9', ArmyBrains[Seraphim], categories.EXPERIMENTAL, 20)

    if(LeaderFaction == 'uef') then
        TauTM:AddEnemiesKilledTaunt('TAUNT10', ArmyBrains[Fletcher], categories.ALLUNITS, 50)
        TauTM:AddEnemiesKilledTaunt('TAUNT11', ArmyBrains[Fletcher], categories.ALLUNITS, 100)
    elseif(LeaderFaction == 'cybran') then
        TauTM:AddEnemiesKilledTaunt('TAUNT12', ArmyBrains[Fletcher], categories.ALLUNITS, 50)
        TauTM:AddEnemiesKilledTaunt('TAUNT13', ArmyBrains[Fletcher], categories.ALLUNITS, 100)
    elseif(LeaderFaction == 'aeon') then
        TauTM:AddEnemiesKilledTaunt('TAUNT14', ArmyBrains[Fletcher], categories.ALLUNITS, 50)
        TauTM:AddEnemiesKilledTaunt('TAUNT15', ArmyBrains[Fletcher], categories.ALLUNITS, 100)
    end
end

function SetupRhizaTauntTriggers()
    RhizaTM:AddTauntingCharacter(ScenarioInfo.RhizaACU)

    RhizaTM:AddUnitsKilledTaunt('TAUNT57', ArmyBrains[Player1], categories.EXPERIMENTAL * categories.AIR, 2)
    RhizaTM:AddUnitsKilledTaunt('TAUNT60', ArmyBrains[Player1], categories.EXPERIMENTAL * categories.NAVAL, 2)
    RhizaTM:AddEnemiesKilledTaunt('TAUNT9', ArmyBrains[Seraphim], categories.xsb1301, 6)
end

function SetupHQTauntTriggers()
    HQTM:AddDamageTaunt('X06_M03_057', ScenarioInfo.Rift1, .25)
    HQTM:AddDamageTaunt('X06_M03_056', ScenarioInfo.Rift1, .50)
    HQTM:AddDamageTaunt('X06_M03_055', ScenarioInfo.Rift1, .75)
end

---------------------
-- Objective Reminders
---------------------
function M2P1Reminder1()
    if(ScenarioInfo.M2P1.Active) then
        ScenarioFramework.Dialogue(OpStrings.X06_M02_090)
        ScenarioFramework.CreateTimerTrigger(M2P1Reminder2, 2500)
    end
end

function M2P1Reminder2()
    if(ScenarioInfo.M2P1.Active) then
        if(LeaderFaction == 'uef') then
            ScenarioFramework.Dialogue(OpStrings.X06_M02_101)
        else
            ScenarioFramework.Dialogue(OpStrings.X06_M02_100)
        end
    end
end

function M2P2Reminder1()
    if(ScenarioInfo.M2P2.Active) then
        ScenarioFramework.Dialogue(OpStrings.X06_M02_120)
        ScenarioFramework.CreateTimerTrigger(M2P2Reminder2, 1060)
    end
end

function M2P2Reminder2()
    if(ScenarioInfo.M2P2.Active) then
        ScenarioFramework.Dialogue(OpStrings.X06_M02_130)
        ScenarioFramework.CreateTimerTrigger(M2P2Reminder1, 1060)
    end
end

function M3P1Reminder1()
    if(ScenarioInfo.M3P1.Active) then
        if(LeaderFaction == 'uef') then
            ScenarioFramework.Dialogue(OpStrings.X06_M03_110)
        elseif(LeaderFaction == 'cybran') then
            ScenarioFramework.Dialogue(OpStrings.X06_M03_130)
        elseif(LeaderFaction == 'aeon') then
            ScenarioFramework.Dialogue(OpStrings.X06_M03_150)
        end
        ScenarioFramework.CreateTimerTrigger(M3P1Reminder2, 900)
    end
end

function M3P1Reminder2()
    if(ScenarioInfo.M3P1.Active) then
        if(LeaderFaction == 'uef') then
            ScenarioFramework.Dialogue(OpStrings.X06_M03_120)
        elseif(LeaderFaction == 'cybran') then
            ScenarioFramework.Dialogue(OpStrings.X06_M03_140)
        elseif(LeaderFaction == 'aeon') then
            ScenarioFramework.Dialogue(OpStrings.X06_M03_160)
        end
        ScenarioFramework.CreateTimerTrigger(M3P1Reminder1, 900)
    end
end

function M3S1Reminder1()
    if(ScenarioInfo.M3S1.Active) then
        ScenarioFramework.Dialogue(OpStrings.X06_M03_220)
        ScenarioFramework.CreateTimerTrigger(M3S1Reminder1, 1200)
    end
end
