-- ****************************************************************************
-- **
-- **  File     : /maps/X1CA_Coop_005/X1CA_Coop_005_script.lua
-- **  Author(s): Jessica St. Croix
-- **
-- **  Summary  : Main mission flow script for X1CA_Coop_005
-- **
-- **  Copyright 2007 Gas Powered Games, Inc.  All rights reserved.
-- ****************************************************************************

local Cinematics = import('/lua/cinematics.lua')
local EffectUtilities = import('/lua/effectutilities.lua')
local M1Hex5AI = import('/maps/X1CA_Coop_005/X1CA_Coop_005_m1hex5ai.lua')
local M2FletcherAI = import('/maps/X1CA_Coop_005/X1CA_Coop_005_m2fletcherai.lua')
local M2Hex5AI = import('/maps/X1CA_Coop_005/X1CA_Coop_005_m2hex5ai.lua')
local M3QAIAI = import('/maps/X1CA_Coop_005/X1CA_Coop_005_m3qaiai.lua')
local Objectives = import('/lua/ScenarioFramework.lua').Objectives
local OpStrings = import('/maps/X1CA_Coop_005/X1CA_Coop_005_strings.lua')
local PingGroups = import('/lua/ScenarioFramework.lua').PingGroups
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local TauntManager = import('/lua/TauntManager.lua')
local Utilities = import('/lua/utilities.lua')

---------
-- Globals
---------
ScenarioInfo.Player = 1
ScenarioInfo.Fletcher = 2
ScenarioInfo.Hex5 = 3
ScenarioInfo.QAI = 4
ScenarioInfo.AeonArmy = 5
ScenarioInfo.UEFArmy = 6
ScenarioInfo.Order = 7
ScenarioInfo.Brackman = 8
ScenarioInfo.Coop1 = 9
ScenarioInfo.Coop2 = 10
ScenarioInfo.Coop3 = 11
ScenarioInfo.HumanPlayers = {}
--------
-- Locals
--------
local Player = ScenarioInfo.Player
local Coop1 = ScenarioInfo.Coop1
local Coop2 = ScenarioInfo.Coop2
local Coop3 = ScenarioInfo.Coop3
local Fletcher = ScenarioInfo.Fletcher
local Hex5 = ScenarioInfo.Hex5
local QAI = ScenarioInfo.QAI
local AeonArmy = ScenarioInfo.AeonArmy
local UEFArmy = ScenarioInfo.UEFArmy
local Order = ScenarioInfo.Order
local Brackman = ScenarioInfo.Brackman

local AssignedObjectives = {}
local Difficulty = ScenarioInfo.Options.Difficulty

-- How long should we wait at the beginning of the NIS to allow slower machines to catch up?
local NIS1InitialDelay = 3

----------------
-- Taunt Managers
----------------
local QAITM = TauntManager.CreateTauntManager('QAITM', '/maps/X1CA_Coop_005/X1CA_Coop_005_Strings.lua')
local Hex5TM = TauntManager.CreateTauntManager('Hex5TM', '/maps/X1CA_Coop_005/X1CA_Coop_005_Strings.lua')
local BrackmanTM = TauntManager.CreateTauntManager('BrackmanTM', '/maps/X1CA_Coop_005/X1CA_Coop_005_Strings.lua')
local FletcherTM = TauntManager.CreateTauntManager('FletcherTM', '/maps/X1CA_Coop_005/X1CA_Coop_005_Strings.lua')

local LeaderFaction
local LocalFaction

---------
-- Startup
---------
function OnPopulate(scenario)
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
    ScenarioFramework.SetUEFAlly1Color(Fletcher)
    ScenarioFramework.SetCybranEvilColor(Hex5)
    ScenarioFramework.SetCybranEvilColor(QAI)
    ScenarioFramework.SetCybranEvilColor(AeonArmy)
    ScenarioFramework.SetCybranEvilColor(UEFArmy)
    ScenarioFramework.SetAeonEvilColor(Order)
    ScenarioFramework.SetCybranAllyColor(Brackman)

    -- Unit cap
    -- TODO: recheck these numbers, probably too high
    SetArmyUnitCap(Fletcher, 300)
    SetArmyUnitCap(Hex5, 800)
    SetArmyUnitCap(QAI, 900)

    ------------
    -- M1 Hex5 AI
    ------------
    M1Hex5AI.Hex5M1BaseAI()
    M1Hex5AI.Hex5M1ResourceBase1AI()
    M1Hex5AI.Hex5M1ResourceBase2AI()
    M1Hex5AI.Hex5M1ResourceBase3AI()

    ----------------------
    -- Hex5 Initial Patrols
    ----------------------
    local units = ScenarioUtils.CreateArmyGroupAsPlatoon('Hex5', 'M1_Hex5_Main_LandDefWest_D' .. Difficulty, 'GrowthFormation')
    for k, v in units:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolChain({v}, 'M1_Hex5_Main_LandDefWest_Chain')
    end

    units = ScenarioUtils.CreateArmyGroupAsPlatoon('Hex5', 'M1_Hex5_Main_LandDefEast_D' .. Difficulty, 'GrowthFormation')
    for k, v in units:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolChain({v}, 'M1_Hex5_Main_LandDefEast_Chain')
    end

    units = ScenarioUtils.CreateArmyGroupAsPlatoon('Hex5', 'M1_Hex5_Main_AirDef_D' .. Difficulty, 'GrowthFormation')
    for k, v in units:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M1_Hex5_Main_AirDef_Chain')))
    end

    units = ScenarioUtils.CreateArmyGroupAsPlatoon('Hex5', 'M1_Hex5_Resource1_LandDef_D' .. Difficulty, 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(units, 'M1_Hex5_Resource1_Def1_Chain')

    units = ScenarioUtils.CreateArmyGroupAsPlatoon('Hex5', 'M1_Hex5_Resource2_AirDef_D' .. Difficulty, 'GrowthFormation')
    for k, v in units:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M1_Hex5_Resource2_AirDef_Chain')))
    end

    ----------------------
    -- Hex5 Static Defenses
    ----------------------
    ScenarioUtils.CreateArmyGroup('Hex5', 'M1_Hex5_AA_Camps_D' .. Difficulty)

    ----------------------
    -- Objective Structures
    ----------------------
    ScenarioInfo.Prison = ScenarioUtils.CreateArmyUnit('Hex5', 'M1_Hex5_Prison')
    ScenarioInfo.Prison:SetDoNotTarget(true)
    ScenarioInfo.Prison:SetCanTakeDamage(false)
    ScenarioInfo.Prison:SetCanBeKilled(false)
    ScenarioInfo.Prison:SetReclaimable(false)
    ScenarioUtils.CreateArmyGroup('Hex5', 'M1_Hex5_Prison_D' .. Difficulty)
    units = ScenarioUtils.CreateArmyGroupAsPlatoon('Hex5', 'M1_Hex5_Prison_LandDef_D' .. Difficulty, 'GrowthFormation')
    for k, v in units:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolChain({v}, 'M1_Hex5_Prison_LandDef_Chain')
    end
end

function OnStart(scenario)
    --------------------
    -- Build Restrictions
    --------------------
    for _, player in ScenarioInfo.HumanPlayers do
        ScenarioFramework.AddRestriction(player,
            categories.xaa0305 + -- Aeon AA Gunship
            categories.xra0305 + -- Cybran Heavy Gunship
            categories.xrl0403 + -- Cybran Amphibious Mega Bot
            categories.xea0306 + -- UEF Heavy Air Transport
            categories.xeb2402 + -- UEF Sub-Orbital Defense System
            categories.xsb2401   -- Seraphim Strategic Missile Launcher
        )
    end

    -- Lock off T1/T2 engineers so Fletcher/Brackman doesnt build them
    ScenarioFramework.AddRestriction(Fletcher, categories.uel0105 + categories.uel0208)
    ScenarioFramework.AddRestriction(Brackman, categories.url0105 + categories.url0208)

    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_1_1'), 0)

    ForkThread(IntroMission1NIS)
end

----------
-- End Game
----------
function PlayerWin()
    if(not ScenarioInfo.OpEnded) then
        -- IssueClearCommands({ScenarioInfo.UnitNames[Player]['Brackman']})
        ScenarioFramework.EndOperationSafety({ScenarioInfo.NISCrab})
        -- ScenarioFramework.EndOperationCamera(ScenarioInfo.BrackmanCrab)
        ScenarioInfo.OpComplete = true
        -- ScenarioFramework.Dialogue(OpStrings.X05_M03_325, nil, true)
        if(ScenarioInfo.M2S1.Active) then
            ScenarioInfo.M2S1:ManualResult(true)
        end
        if(ScenarioInfo.M3P2 and ScenarioInfo.M3P2.Active) then
            -- complete the accompanying protect objective as well
            ScenarioInfo.M3P2:ManualResult(true)
        end
        -- ScenarioFramework.Dialogue(OpStrings.X05_M03_330, KillGame, true)
        KillGame()
    end
end

function PlayerDeath()
    ScenarioFramework.PlayerDeath(deadCommander, nil, AssignedObjectives)
end

function KillGame()
    UnlockInput()
    ScenarioFramework.EndOperation(ScenarioInfo.OpComplete, ScenarioInfo.OpComplete)
end

-----------
-- Intro NIS
-----------
function IntroMission1NIS()
    ScenarioFramework.SetPlayableArea('M1Area', false)

    Cinematics.EnterNISMode()

    local VisMarker1 = ScenarioFramework.CreateVisibleAreaLocation(50, ScenarioUtils.MarkerToPosition('M1_Vis_1'), 0, ArmyBrains[Player])
    local VisMarker2 = ScenarioFramework.CreateVisibleAreaLocation(20, ScenarioUtils.MarkerToPosition('M1_Vis_2'), 0, ArmyBrains[Player])
    local VisMarker3 = ScenarioFramework.CreateVisibleAreaLocation(20, ScenarioUtils.MarkerToPosition('M1_Vis_3'), 0, ArmyBrains[Player])

    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_1_1'), 0)

    -- Let slower machines catch up before we get going
    WaitSeconds(NIS1InitialDelay)

    WaitSeconds(1)
    ScenarioFramework.Dialogue(OpStrings.X05_M01_010, nil, true)
    WaitSeconds(3)
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_1_2'), 5)
    WaitSeconds(3)

    ScenarioFramework.Dialogue(OpStrings.X05_M01_011, nil, true)

    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_1_3'), 3)
    WaitSeconds(2)
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_1_4'), 3)
    WaitSeconds(2)
    ForkThread(function()
        WaitSeconds(2)
        VisMarker1:Destroy()
        VisMarker2:Destroy()
        VisMarker3:Destroy()
        WaitSeconds(4)
        ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('M1_Vis_1'), 60)
        ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('M1_Vis_2'), 30)
        ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('M1_Vis_3'), 30)
    end)
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_1_5'), 4)

    if (LeaderFaction == 'aeon') then
        ScenarioInfo.PlayerCDR = ScenarioUtils.CreateArmyUnit('Player', 'AeonPlayer')
    elseif (LeaderFaction == 'cybran') then
        ScenarioInfo.PlayerCDR = ScenarioUtils.CreateArmyUnit('Player', 'CybranPlayer')
    elseif (LeaderFaction == 'uef') then
        ScenarioInfo.PlayerCDR = ScenarioUtils.CreateArmyUnit('Player', 'UEFPlayer')
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
            if (factionIdx == 1) then
                ScenarioInfo.CoopCDR[coop] = ScenarioUtils.CreateArmyUnit(strArmy, 'UEFPlayer')
            elseif (factionIdx == 2) then
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

    ScenarioFramework.Dialogue(OpStrings.X05_M01_012, nil, true)
    WaitSeconds(2)

    Cinematics.ExitNISMode()

    IntroMission1()
end

-----------
-- Mission 1
-----------
function IntroMission1()
    ScenarioInfo.MissionNumber = 1

    StartMission1()
end

function StartMission1()
    ----------------------------------
    -- Primary Objective 1 - Clear Area
    ----------------------------------
    ScenarioInfo.M1P1 = Objectives.CategoriesInArea(
        'primary',                      -- type
        'incomplete',                   -- complete
        OpStrings.X05_M01_OBJ_010_010,  -- title
        OpStrings.X05_M01_OBJ_010_020,  -- description
        'kill',                         -- action
        {                               -- target
            MarkArea = true,
            Requirements = {
                {
                    Area = 'M1_FletcherLandingArea',
                    Category = (categories.CONSTRUCTION + categories.DEFENSE + categories.MOBILE) - categories.WALL - categories.ura0101 - categories.ura0102 - categories.ura0302 - categories.ura0303,
                    CompareOp = '<=',
                    Value = 0,
                    ArmyIndex = Hex5,
                },
            },
        }
   )
    ScenarioInfo.M1P1:AddResultCallback(
        function(result)
            if(result) then
                ScenarioFramework.FlushDialogueQueue()
                while(ScenarioInfo.DialogueLock) do
                    WaitSeconds(0.2)
                end
                -- Warp in and buff Fletcher
                ScenarioInfo.FletcherCDR = ScenarioUtils.CreateArmyUnit('Fletcher', 'Fletcher')
                ScenarioInfo.FletcherCDR:CreateEnhancement('ResourceAllocation')
                ScenarioInfo.FletcherCDR:CreateEnhancement('T3Engineering')
                ScenarioInfo.FletcherCDR:CreateEnhancement('LeftPod')
                ScenarioInfo.FletcherCDR:CreateEnhancement('RightPod')
                ScenarioInfo.FletcherCDR:SetCanBeKilled(false)
                ScenarioInfo.FletcherCDR:PlayCommanderWarpInEffect()
                ScenarioFramework.CreateUnitDamagedTrigger(FletcherWarp, ScenarioInfo.FletcherCDR, .8)
                FletcherTM:AddTauntingCharacter(ScenarioInfo.FletcherCDR)
                ScenarioInfo.FletcherCDR:SetCustomName(LOC '{i Fletcher}')
                WaitSeconds(2.5)
                ScenarioInfo.FletcherCDR:ShowBone('Left_Upgrade', true)
                ScenarioInfo.FletcherCDR:ShowBone('Right_Upgrade', true)
                ScenarioInfo.FletcherCDR:ShowBone('Back_Upgrade_B01', true)
                IntroMission2()
            end
        end
   )
    table.insert(AssignedObjectives, ScenarioInfo.M1P1)

    -- Reminders, secondaries, extra dialogue
    ScenarioFramework.CreateTimerTrigger(M1P1Reminder1, 1800)
    ScenarioFramework.Dialogue(OpStrings.X05_M01_070, AssignM1S1)
    ScenarioFramework.CreateTimerTrigger(AssignM1S2Dialogue, 20)
    ScenarioFramework.CreateTimerTrigger(M1SubPlotDialogue, 700)
    SetupM1Taunts()
end

function Hex5_Brack_Dialogue()
    ScenarioFramework.Dialogue(OpStrings.x05_m01_0000_00)
end

function AssignM1S1()
    ---------------------------------------------------
    -- Secondary Objective 1 - Destroy Hex5©s Fire Bases
    ---------------------------------------------------
    ScenarioInfo.M1S1 = Objectives.CategoriesInArea(
        'secondary',                    -- type
        'incomplete',                   -- complete
        OpStrings.X05_M01_OBJ_010_030,  -- title
        OpStrings.X05_M01_OBJ_010_040,  -- description
        'kill',                         -- action
        {                               -- target
            MarkUnits = true,
            Requirements = {
                {
                    Area = 'M1_ResourceBase1_Area',
                    ArmyIndex = Hex5,
                    Category = categories.FACTORY + (categories.ENERGYPRODUCTION * categories.TECH2) + (categories.RADAR * categories.STRUCTURE),
                    CompareOp = '<=',
                    MarkArea = true,
                    Value = 0,
                },
                {
                    Area = 'M1_ResourceBase2_Area',
                    ArmyIndex = Hex5,
                    Category = categories.FACTORY + (categories.ENERGYPRODUCTION * categories.TECH2) + (categories.RADAR * categories.STRUCTURE) + categories.AIRSTAGINGPLATFORM,
                    CompareOp = '<=',
                    MarkArea = true,
                    Value = 0,
                },
                {
                    Area = 'M1_ResourceBase3_Area',
                    ArmyIndex = Hex5,
                    Category = categories.FACTORY + (categories.ENERGYPRODUCTION * categories.TECH2) + (categories.COUNTERINTELLIGENCE * categories.STRUCTURE) + categories.AIRSTAGINGPLATFORM,
                    CompareOp = '<=',
                    MarkArea = true,
                    Value = 0,
                },
            },
        }
   )
    ScenarioInfo.M1S1:AddResultCallback(
        function(result)
            if(result) then
                ScenarioFramework.Dialogue(OpStrings.X05_M01_100)
            end
        end
   )
    table.insert(AssignedObjectives, ScenarioInfo.M1S1)
    ScenarioFramework.CreateTimerTrigger(M1S1Reminder1, 1890)
end

function AssignM1S2Dialogue()
    ScenarioFramework.Dialogue(OpStrings.X05_M01_140, AssignM1S2)
end

function AssignM1S2()
    ---------------------------------------------------
    -- Secondary Objective 2 - Rescue Loyalist Commander
    ---------------------------------------------------
    ScenarioInfo.M1S2 = Objectives.Capture(
        'secondary',                    -- type
        'incomplete',                   -- complete
        OpStrings.X05_M01_OBJ_010_050,  -- title
        OpStrings.X05_M01_OBJ_010_060,  -- description
        {
            Units = {ScenarioInfo.Prison},
            FlashVisible = true,
        }
   )
    ScenarioInfo.M1S2:AddResultCallback(
        function(result)
            if(result) then
                if(LeaderFaction == 'uef') then
                    ScenarioFramework.Dialogue(OpStrings.X05_M01_180)
                elseif(LeaderFaction == 'cybran') then
                    ScenarioFramework.Dialogue(OpStrings.X05_M01_180)
                elseif(LeaderFaction == 'aeon') then
                    if(ScenarioInfo.MissionNumber == 3) then
                        ScenarioFramework.Dialogue(OpStrings.X05_M01_180)
                    else
                        ScenarioFramework.Dialogue(OpStrings.X05_M01_170)
                    end
                end
                ScenarioFramework.Dialogue(OpStrings.TAUNT5)

                -- Create Amalia, dialogue triggers for her getting damaged (12 percent), and killed
                ScenarioInfo.Amalia = ScenarioUtils.CreateArmyUnit('Player', 'Rescued_sCDR')
                ScenarioInfo.Amalia:SetCustomName(LOC '{i Amalia}')
                if(LeaderFaction == 'aeon') then
                    -- to support the Aeon subplot, play some damage related dialogue from her.
                    ScenarioFramework.CreateUnitDamagedTrigger(AmaliaDamaged, ScenarioInfo.Amalia, .02)
                    ScenarioFramework.CreateUnitDamagedTrigger(AmaliaDamaged2, ScenarioInfo.Amalia, .90)
                    ScenarioFramework.CreateUnitDeathTrigger(AmaliaDestroyed, ScenarioInfo.Amalia)
                end
            end
        end
   )
    table.insert(AssignedObjectives, ScenarioInfo.M1S2)
    ScenarioFramework.CreateTimerTrigger(M1S2Reminder1, 750)
end

function M1SubPlotDialogue()
    if(LeaderFaction == 'uef') then
        ScenarioFramework.Dialogue(OpStrings.X05_M01_110)
    elseif(LeaderFaction == 'cybran') then
        ScenarioFramework.Dialogue(OpStrings.X05_M01_120)
    elseif(LeaderFaction == 'aeon') then
        ScenarioFramework.Dialogue(OpStrings.X05_M01_130)
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

            ----------------
            -- M2 Fletcher AI
            ----------------
            M2FletcherAI.FletcherBaseAI()

            ArmyBrains[Fletcher]:PBMSetCheckInterval(6)

            ScenarioFramework.CreateTimerTrigger(ResetBuildInterval, 300)

            ScenarioFramework.CreateArmyStatTrigger(M2T1FactoryBuilt, ArmyBrains[Fletcher], 'M2T1FactoryBuilt',
                {{StatType = 'Units_Active', CompareType = 'GreaterThanOrEqual', Value = 2, Category = categories.FACTORY * categories.TECH1 * categories.AIR}})

            ScenarioFramework.CreateArmyStatTrigger(M2T3FactoryBuilt, ArmyBrains[Fletcher], 'M2T3FactoryBuilt',
                {{StatType = 'Units_Active', CompareType = 'GreaterThanOrEqual', Value = 4, Category = categories.uel0309}})

            ScenarioFramework.CreateArmyStatTrigger(M2FletcherAI.NewEngineerCount, ArmyBrains[Fletcher], 'NewEngCount',
                {{StatType = 'Units_Active', CompareType = 'GreaterThanOrEqual', Value = 17, Category = categories.ueb1301}})

            ScenarioFramework.CreateArmyStatTrigger(   M2FletcherAI.M2FletcherBaseAirAttacks, ArmyBrains[Fletcher], '2+T3AirFacs',
                {{StatType = 'Units_Active', CompareType = 'GreaterThanOrEqual', Value = 1, Category = categories.ueb0302}})

            ScenarioFramework.CreateArmyStatTrigger(   M2FletcherAI.FletcherBaseLandAttacks, ArmyBrains[Fletcher], '2+T3LandFacs',
                {{StatType = 'Units_Active', CompareType = 'GreaterThanOrEqual', Value = 1, Category = categories.ueb0301}})

            ------------
            -- M2 Hex5 AI
            ------------
            M2Hex5AI.Hex5M2BaseAI()

            ------
            -- Hex5
            ------
            ScenarioInfo.Hex5CDR = ScenarioUtils.CreateArmyUnit('Hex5', 'Hex5_Unit')
            ScenarioFramework.PauseUnitDeath(ScenarioInfo.Hex5CDR)
            if(Difficulty > 1) then
                ScenarioInfo.Hex5CDR:CreateEnhancement('CloakingGenerator')
                if(Difficulty == 3) then
                    ScenarioInfo.Hex5CDR:CreateEnhancement('StealthGenerator')
                    -- ScenarioInfo.Hex5CDR:AddKills(2000)
                end
            end
            ScenarioInfo.Hex5CDR:CreateEnhancement('MicrowaveLaserGenerator')
            ScenarioInfo.Hex5CDR:CreateEnhancement('CoolingUpgrade')
            ScenarioInfo.Hex5CDR:SetCustomName(LOC '{i Hex5}')
            Hex5TM:AddTauntingCharacter(ScenarioInfo.Hex5CDR)
            ScenarioFramework.CreateArmyStatTrigger(EconomyDestroyed, ArmyBrains[Hex5], 'EconomyDestroyed',
                {{StatType = 'Units_Active', CompareType = 'LessThanOrEqual', Value = 0, Category = categories.ENERGYPRODUCTION * categories.STRUCTURE * categories.TECH3}})

            ----------------------
            -- Hex5 Initial Patrols
            ----------------------
            local units = ScenarioUtils.CreateArmyGroupAsPlatoon('Hex5', 'M2_Hex5_InitAir_North_D' .. Difficulty, 'GrowthFormation')
            for k, v in units:GetPlatoonUnits() do
                ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M2_Hex5_Main_AirDef_N_Chain')))
            end

            units = ScenarioUtils.CreateArmyGroupAsPlatoon('Hex5', 'M2_Hex5_InitAir_West_D' .. Difficulty, 'GrowthFormation')
            for k, v in units:GetPlatoonUnits() do
                ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M2_Hex5_Main_AirDef_W_Chain')))
            end

            for i = 1, 2 do
                units = ScenarioUtils.CreateArmyGroupAsPlatoon('Hex5', 'M2_Hex5_InitGround_North' .. i .. '_D' .. Difficulty, 'GrowthFormation')
                ScenarioFramework.PlatoonPatrolChain(units, 'M2_Hex5_Main_LandDef_N' .. i .. '_Chain')
            end

            units = ScenarioUtils.CreateArmyGroupAsPlatoon('Hex5', 'M2_Hex5_InitGround_West_D' .. Difficulty, 'GrowthFormation')
            ScenarioFramework.PlatoonPatrolChain(units, 'M2_Hex5_Main_LandDef_W_Chain')

            --------------------
            -- Hex5 Experimentals
            --------------------
            ScenarioInfo.M2NumSpiderKilled = 0

            local spider = ScenarioUtils.CreateArmyUnit('Hex5', 'M2_Hex5_Spider1')
            spider:DisableIntel('RadarStealth')
            spider:DisableIntel('RadarStealthField')
            local platoon = ArmyBrains[Hex5]:MakePlatoon('', '')
            ArmyBrains[Hex5]:AssignUnitsToPlatoon(platoon, {spider}, 'Attack', 'GrowthFormation')
            ScenarioFramework.PlatoonPatrolChain(platoon, 'M2_Hex5_N_Spider_Chain')
            ScenarioFramework.CreateUnitDeathTrigger(M2SpiderbotsDestroyed, spider)

            spider = ScenarioUtils.CreateArmyUnit('Hex5', 'M2_Hex5_Spider2')
            spider:DisableIntel('RadarStealth')
            spider:DisableIntel('RadarStealthField')
            platoon = ArmyBrains[Hex5]:MakePlatoon('', '')
            ArmyBrains[Hex5]:AssignUnitsToPlatoon(platoon, {spider}, 'Attack', 'GrowthFormation')
            ScenarioFramework.PlatoonPatrolChain(platoon, 'M2_Hex5_N_Spider_Chain')
            ScenarioFramework.CreateUnitDeathTrigger(M2SpiderbotsDestroyed, spider)

            spider = ScenarioUtils.CreateArmyUnit('Hex5', 'M2_Hex5_Spider3')
            spider:DisableIntel('RadarStealth')
            spider:DisableIntel('RadarStealthField')
            platoon = ArmyBrains[Hex5]:MakePlatoon('', '')
            ArmyBrains[Hex5]:AssignUnitsToPlatoon(platoon, {spider}, 'Attack', 'GrowthFormation')
            ScenarioFramework.PlatoonPatrolChain(platoon, 'M2_Hex5_S_Spider_Chain')
            ScenarioFramework.CreateUnitDeathTrigger(M2SpiderbotsDestroyed, spider)

            if(Difficulty > 1) then
                spider = ScenarioUtils.CreateArmyUnit('Hex5', 'M2_Hex5_Spider4')
                spider:DisableIntel('RadarStealth')
                spider:DisableIntel('RadarStealthField')
                platoon = ArmyBrains[Hex5]:MakePlatoon('', '')
                ArmyBrains[Hex5]:AssignUnitsToPlatoon(platoon, {spider}, 'Attack', 'GrowthFormation')
                ScenarioFramework.PlatoonPatrolChain(platoon, 'M2_Hex5_S_Spider_Chain')
                ScenarioFramework.CreateUnitDeathTrigger(M2SpiderbotsDestroyed, spider)
            end

            spider = ScenarioUtils.CreateArmyUnit('Hex5', 'M2_Hex5_Spider5')
            spider:DisableIntel('RadarStealth')
            spider:DisableIntel('RadarStealthField')
            platoon = ArmyBrains[Hex5]:MakePlatoon('', '')
            ArmyBrains[Hex5]:AssignUnitsToPlatoon(platoon, {spider}, 'Attack', 'GrowthFormation')
            ScenarioFramework.PlatoonPatrolChain(platoon, 'M2_Hex5_NW_Spider_Chain')
            ScenarioFramework.CreateUnitDeathTrigger(M2SpiderbotsDestroyed, spider)

            if(Difficulty > 1) then
                spider = ScenarioUtils.CreateArmyUnit('Hex5', 'M2_Hex5_Spider6')
                spider:DisableIntel('RadarStealth')
                spider:DisableIntel('RadarStealthField')
                platoon = ArmyBrains[Hex5]:MakePlatoon('', '')
                ArmyBrains[Hex5]:AssignUnitsToPlatoon(platoon, {spider}, 'Attack', 'GrowthFormation')
                ScenarioFramework.PlatoonPatrolChain(platoon, 'M2_Hex5_SW_Spider_Chain')
                ScenarioFramework.CreateUnitDeathTrigger(M2SpiderbotsDestroyed, spider)

                if(Difficulty == 3) then
                    spider = ScenarioUtils.CreateArmyUnit('Hex5', 'M2_Hex5_Spider7')
                    spider:DisableIntel('RadarStealth')
                    spider:DisableIntel('RadarStealthField')
                    platoon = ArmyBrains[Hex5]:MakePlatoon('', '')
                    ArmyBrains[Hex5]:AssignUnitsToPlatoon(platoon, {spider}, 'Attack', 'GrowthFormation')
                    ScenarioFramework.PlatoonPatrolChain(platoon, 'M2_Hex5_FarWestSpider_Chain')
                    ScenarioFramework.CreateUnitDeathTrigger(M2SpiderbotsDestroyed, spider)
                end
            end

            local scathis = ScenarioUtils.CreateArmyUnit('Hex5', 'M2_Hex5_Scath')
            ScenarioFramework.CreateUnitDeathTrigger(M2ScathisDestroyed, scathis)
            ScenarioInfo.M2FletcherWarningPlayed = false
            for i = 1, 2 do
                local soul = ScenarioUtils.CreateArmyUnit('Hex5', 'M2_Hex5_Soul' .. i)
                local platoon = ArmyBrains[Hex5]:MakePlatoon('', '')
                ArmyBrains[Hex5]:AssignUnitsToPlatoon(platoon, {soul}, 'Attack', 'GrowthFormation')
                ScenarioFramework.PlatoonPatrolRoute(platoon, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M2_Hex5_SoulNorth_Chain')))
                ScenarioFramework.CreateUnitNearTypeTrigger (M2FletcherHelpDialogue, soul, ArmyBrains[Fletcher], categories.uel0401, 16)
            end

            if(Difficulty > 1) then
                local soul = ScenarioUtils.CreateArmyUnit('Hex5', 'M2_Hex5_Soul3')
                local platoon = ArmyBrains[Hex5]:MakePlatoon('', '')
                ArmyBrains[Hex5]:AssignUnitsToPlatoon(platoon, {soul}, 'Attack', 'GrowthFormation')
                ScenarioFramework.PlatoonPatrolRoute(platoon, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M2_Hex5_SoulMid_Chain')))
                ScenarioFramework.CreateUnitNearTypeTrigger (M2FletcherHelpDialogue, soul, ArmyBrains[Fletcher], categories.uel0401, 16)
            end

            if(Difficulty == 3) then
                for i = 4, 5 do
                    local soul = ScenarioUtils.CreateArmyUnit('Hex5', 'M2_Hex5_Soul' .. i)
                    local platoon = ArmyBrains[Hex5]:MakePlatoon('', '')
                    ArmyBrains[Hex5]:AssignUnitsToPlatoon(platoon, {soul}, 'Attack', 'GrowthFormation')
                    ScenarioFramework.PlatoonPatrolRoute(platoon, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M2_Hex5_SoulNorth_Chain')))
                    ScenarioFramework.CreateUnitNearTypeTrigger (M2FletcherHelpDialogue, soul, ArmyBrains[Fletcher], categories.uel0401, 16)
                end
            end

            if(Difficulty > 1) then
                for i = 6, 7 do
                    local soul = ScenarioUtils.CreateArmyUnit('Hex5', 'M2_Hex5_Soul' .. i)
                    local platoon = ArmyBrains[Hex5]:MakePlatoon('', '')
                    ArmyBrains[Hex5]:AssignUnitsToPlatoon(platoon, {soul}, 'Attack', 'GrowthFormation')
                    ScenarioFramework.PlatoonPatrolRoute(platoon, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M2_Hex5_SoulWest_Chain')))
                    ScenarioFramework.CreateUnitNearTypeTrigger (M2FletcherHelpDialogue, soul, ArmyBrains[Fletcher], categories.uel0401, 22)
                end
            end

            ----------------------
            -- Hex5 Static Defenses
            ----------------------
            ScenarioUtils.CreateArmyGroup('Hex5', 'M2_Hex5_MountainDefense_D' .. Difficulty)

            ForkThread(IntroMission2NIS)
            ScenarioFramework.Dialogue(OpStrings.TAUNT4, nil, true)
        end
   )
end

function EconomyDestroyed()
    if(ScenarioInfo.Hex5CDR and not ScenarioInfo.Hex5CDR:IsDead()) then
        ScenarioInfo.Hex5CDR:CreateEnhancement('CloakingGeneratorRemove')
        if(Difficulty == 3) then
            ScenarioInfo.Hex5CDR:CreateEnhancement('StealthGeneratorRemove')
        end
    end
end

function IntroMission2NIS()
    ScenarioFramework.SetPlayableArea('M2Area', false)
    Cinematics.EnterNISMode()
    Cinematics.SetInvincible('M1Area')

    -- Ensure that Fletcher starts building his base sooner rather than later
    ArmyBrains[Fletcher]:PBMSetCheckInterval(2)

    WaitSeconds(1)
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_2_1'), 0)
    WaitSeconds(1)

    -- Play faction appropriate dialogue from Fletcher
    if (LeaderFaction == 'uef') then
        ScenarioFramework.Dialogue(OpStrings.X05_M01_040, nil, true)
    elseif (LeaderFaction == 'cybran') then
        ScenarioFramework.Dialogue(OpStrings.X05_M01_050, nil, true)
    elseif (LeaderFaction == 'aeon') then
        ScenarioFramework.Dialogue(OpStrings.X05_M01_060, nil, true)
    end

    WaitSeconds(1)
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_2_2'), 3)

    Cinematics.SetInvincible('M1Area', true)
    Cinematics.ExitNISMode()
    -- Post-NIS comment from Brackman
    ScenarioFramework.Dialogue(OpStrings.X05_M01_190)
    -- Set back to default
    ArmyBrains[Fletcher]:PBMSetCheckInterval(6)

    M2Counterattack()
    StartMission2()
end

function ResetBuildInterval()
    ArmyBrains[Fletcher]:PBMSetCheckInterval(6)
end

function M2T1FactoryBuilt()
    local factory = ArmyBrains[Fletcher]:GetListOfUnits(categories.FACTORY * categories.AIR, false)
    IssueGuard({ScenarioInfo.FletcherCDR}, factory[1])
end

function M2T3FactoryBuilt()
    local factory = ArmyBrains[Fletcher]:GetListOfUnits(categories.FACTORY * categories.AIR, false)

    IssueStop({ScenarioInfo.FletcherCDR})
    IssueClearCommands({ScenarioInfo.FletcherCDR})

    IssueGuard({ScenarioInfo.FletcherCDR}, factory[2])

    ScenarioFramework.CreateArmyStatTrigger(M2T3AirFactory2Built, ArmyBrains[Fletcher], 'M2T3AirFactory2Built',
        {{StatType = 'Units_Active', CompareType = 'GreaterThanOrEqual', Value = 2, Category = categories.ueb0302}})
end

function M2T3AirFactory2Built()
    local factory = ArmyBrains[Fletcher]:GetListOfUnits(categories.FACTORY * categories.LAND, false)

    IssueStop({ScenarioInfo.FletcherCDR})
    IssueClearCommands({ScenarioInfo.FletcherCDR})

    IssueGuard({ScenarioInfo.FletcherCDR}, factory[1])

    ScenarioFramework.CreateArmyStatTrigger(M2T3LandFactoryBuilt, ArmyBrains[Fletcher], 'M2T3LandFactoryBuilt',
        {{StatType = 'Units_Active', CompareType = 'GreaterThanOrEqual', Value = 1, Category = categories.ueb0301}})
end

function M2T3LandFactoryBuilt()
    IssueStop({ScenarioInfo.FletcherCDR})
    IssueClearCommands({ScenarioInfo.FletcherCDR})
end

function M2Counterattack()
    ScenarioInfo.M2SpiderbotSpawned = false
    local units = nil
    local trigger = {}

    -- Default Air Attacks
    for i = 1, 3 do
        units = ScenarioUtils.CreateArmyGroupAsPlatoon('Hex5', 'M2_Hex5_InitAir_' .. i .. '_D' .. Difficulty, 'GrowthFormation')
        ScenarioFramework.PlatoonPatrolChain(units, 'M2_Hex5_InitAir_Attack_Chain')
    end

    -- Default Land Attacks
    local landChains = {'M2_Hex5_InitLand_3_Chain', 'M2_Hex5_InitLand_2_Chain', 'M2_Hex5_InitLand_2_Chain', 'M2_Hex5_InitLand_2_Chain', 'M2_Hex5_InitLand_2_Chain', 'M2_Hex5_InitLand_1_Chain'}
    for i = 1, 6 do
        units = ScenarioUtils.CreateArmyGroupAsPlatoon('Hex5', 'M2_Hex5_InitLand_' .. i .. '_D' .. Difficulty, 'GrowthFormation')
        ScenarioFramework.PlatoonPatrolChain(units, landChains[i])
    end

    -- If player > [225, 200, 25] structures, spawns land attack
    local num = 0
    for _, player in ScenarioInfo.HumanPlayers do
        num = num + table.getn(ArmyBrains[player]:GetListOfUnits(categories.STRUCTURE - categories.WALL, false))
    end

    trigger = {225, 200, 25}
    if(num > trigger[Difficulty]) then
        units = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Hex5', 'M2_Hex5_Adapt_InitLandAtack_1', 'GrowthFormation', 5)
        ScenarioFramework.PlatoonPatrolChain(units, 'M2_Hex5_InitLand_3_Chain')
        -- If player > [250, 225, 50] structures, spawns land attack
        trigger = {250, 225, 50}
        if(num > trigger[Difficulty]) then
            units = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Hex5', 'M2_Hex5_Adapt_InitLandAtack_2', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(units, 'M2_Hex5_InitLand_3_Chain')
            -- If player > [275, 250, 75] structures, spawns land attack
            trigger = {275, 250, 75}
            if(num > trigger[Difficulty]) then
                units = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Hex5', 'M2_Hex5_Adapt_InitLandAtack_3', 'GrowthFormation', 5)
                ScenarioFramework.PlatoonPatrolChain(units, 'M2_Hex5_InitLand_2_Chain')
            end
        end
    end

    -- If player > [25, 15, 5] T2/T3 DF or artillery structures, spawns land attack
    local num = 0
    for _, player in ScenarioInfo.HumanPlayers do
        num = num + table.getn(ArmyBrains[player]:GetListOfUnits(((categories.STRUCTURE * categories.DIRECTFIRE) - categories.TECH1) + ((categories.STRUCTURE * categories.ARTILLERY) - categories.TECH1), false))
    end

    trigger = {25, 15, 5}
    if(num > trigger[Difficulty]) then
        units = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Hex5', 'M2_Hex5_Adapt_InitLandAtack_4', 'GrowthFormation', 5)
        ScenarioFramework.PlatoonPatrolChain(units, 'M2_Hex5_InitLand_2_Chain')
        -- If player > [30, 20, 10] T2/T3 DF or artillery structures, spawns land attack
        trigger = {30, 20, 10}
        if(num > trigger[Difficulty]) then
            units = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Hex5', 'M2_Hex5_Adapt_InitLandAtack_5', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(units, 'M2_Hex5_InitLand_2_Chain')
            -- If player > [35, 25, 15] T2/T3 DF or artillery structures, spawns land attack
            trigger = {35, 25, 15}
            if(num > trigger[Difficulty]) then
                units = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Hex5', 'M2_Hex5_Adapt_InitLandAtack_6', 'GrowthFormation', 5)
                ScenarioFramework.PlatoonPatrolChain(units, 'M2_Hex5_InitLand_1_Chain')
            end
        end
    end

    -- If player has > [20, 10, 5] T2/T3 factories, spawn siege bots
    local num = 0
    for _, player in ScenarioInfo.HumanPlayers do
        num = num + table.getn(ArmyBrains[player]:GetListOfUnits(categories.FACTORY - categories.TECH1, false))
    end

    trigger = {20, 10, 5}
    if(num > trigger[Difficulty]) then
        units = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Hex5', 'M2_Hex5_Adapt_L_Siege', 'GrowthFormation', 5)
        ScenarioFramework.PlatoonPatrolChain(units, 'M2_Hex5_LandAdapt_Chain')
        -- If player has > [40, 15, 8] T2/T3 factories, spawn siege bots
        trigger = {40, 15, 8}
        if(num > trigger[ScenarioInfo.Options.Diffculty]) then
            units = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Hex5', 'M2_Hex5_Adapt_L_Siege_b', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(units, 'M2_Hex5_LandAdapt_Chain')
        end
    end

    -- If player has > [450, 400, 200] units, spawn mobile missiles
    local num = 0
    for _, player in ScenarioInfo.HumanPlayers do
        num = num + table.getn(ArmyBrains[player]:GetListOfUnits(categories.ALLUNITS - categories.WALL, false))
    end

    trigger = {450, 400, 200}
    if(num > trigger[Difficulty]) then
        units = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Hex5', 'M2_Hex5_Adapt_L_Missile', 'GrowthFormation', 5)
        ScenarioFramework.PlatoonPatrolChain(units, 'M2_Hex5_LandAdapt_Chain')
        -- If player has > [475, 450, 200] units, spawn mobile missiles
        trigger = {475, 450, 200}
        if(num > trigger[Difficulty]) then
            units = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Hex5', 'M2_Hex5_Adapt_L_Missile_b', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(units, 'M2_Hex5_LandAdapt_Chain')
        end
    end

    -- If player has > [30, 20, 5] shields, spawn artillery
    local num = 0
    for _, player in ScenarioInfo.HumanPlayers do
        num = num + table.getn(ArmyBrains[player]:GetListOfUnits(categories.STRUCTURE * categories.SHIELD, false))
    end

    trigger = {30, 20, 5}
    if(num > trigger[Difficulty]) then
        units = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Hex5', 'M2_Hex5_Adapt_L_Artil', 'GrowthFormation', 5)
        ScenarioFramework.PlatoonPatrolChain(units, 'M2_Hex5_LandAdapt_Chain')
        -- If player has > [35, 25, 5] shields, spawn artillery
        trigger = {35, 25, 5}
        if(num > trigger[Difficulty]) then
            units = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Hex5', 'M2_Hex5_Adapt_L_Artil_b', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(units, 'M2_Hex5_LandAdapt_Chain')
        end
    end

    -- If player has > [475, 450, 300] units, spawn spiderbot
    local num = 0
    for _, player in ScenarioInfo.HumanPlayers do
        num = num + table.getn(ArmyBrains[player]:GetListOfUnits(categories.ALLUNITS - categories.WALL, false))
    end

    trigger = {475, 450, 300}
    if(num > trigger[Difficulty]) then
        spider = ScenarioUtils.CreateArmyUnit('Hex5', 'M2_Hex5_Init_Spider1')
        platoon = ArmyBrains[Hex5]:MakePlatoon('', '')
        ArmyBrains[Hex5]:AssignUnitsToPlatoon(platoon, {spider}, 'Attack', 'GrowthFormation')
        ScenarioFramework.PlatoonPatrolChain(platoon, 'M2_Hex5_InitLand_3_Chain')
        ScenarioInfo.M2SpiderbotSpawned = true  -- we check this to see if spiderbot-warning VO is to be played
    end

    -- If player has > [25, 15, 5] T2/T3 DF or artillery structures, spawn spiderbot
    local num = 0
    for _, player in ScenarioInfo.HumanPlayers do
        num = num + table.getn(ArmyBrains[player]:GetListOfUnits(((categories.STRUCTURE * categories.DIRECTFIRE) - categories.TECH1) + ((categories.STRUCTURE * categories.ARTILLERY) - categories.TECH1), false))
    end

    trigger = {25, 15, 5}
    if(num > trigger[Difficulty]) then
        spider = ScenarioUtils.CreateArmyUnit('Hex5', 'M2_Hex5_Init_Spider2')
        platoon = ArmyBrains[Hex5]:MakePlatoon('', '')
        ArmyBrains[Hex5]:AssignUnitsToPlatoon(platoon, {spider}, 'Attack', 'GrowthFormation')
        ScenarioFramework.PlatoonPatrolChain(platoon, 'M2_Hex5_InitLand_3_Chain')
        ScenarioInfo.M2SpiderbotSpawned = true
    end

    -- If player has > [100, 75, 25] gunships/bombers, spawn spiderbot
    local num = 0
    for _, player in ScenarioInfo.HumanPlayers do
        num = num + table.getn(ArmyBrains[player]:GetListOfUnits((categories.MOBILE * categories.AIR) * (categories.GROUNDATTACK + categories.BOMBER), false))
    end

    trigger = {100, 75, 25}
    if(num > trigger[Difficulty]) then
        spider = ScenarioUtils.CreateArmyUnit('Hex5', 'M2_Hex5_Init_Spider3')
        platoon = ArmyBrains[Hex5]:MakePlatoon('', '')
        ArmyBrains[Hex5]:AssignUnitsToPlatoon(platoon, {spider}, 'Attack', 'GrowthFormation')
        ScenarioFramework.PlatoonPatrolChain(platoon, 'M2_Hex5_InitLand_2_Chain')
        ScenarioInfo.M2SpiderbotSpawned = true
    end

    -- Spawns transport attacks for every [10, 4, 1] T2/T3 point defense
    local num = 0
    for _, player in ScenarioInfo.HumanPlayers do
        num = num + table.getn(ArmyBrains[player]:GetListOfUnits((categories.STRUCTURE * categories.DIRECTFIRE) - categories.TECH1, false))
    end

    if(num > 0) then
        trigger = {10, 4, 1}
        num = math.ceil(num/trigger[Difficulty])
        if(num > 8) then
            num = 8
        end
        for i = 1, num do
            units = ScenarioUtils.CreateArmyGroupAsPlatoon('Hex5', 'M2_Hex5_Adapt_Xport1', 'GrowthFormation')
            for k,v in units:GetPlatoonUnits() do
                if(v:GetUnitId() == 'ura0104') then
                    local interceptors = ScenarioUtils.CreateArmyGroup('Hex5', 'M2_Hex5_Adapt_Xport_Interceptors')
                    IssueGuard(interceptors, v)
                    break
                end
            end
            ScenarioFramework.PlatoonAttackWithTransports(units, 'M2_Hex5_Transport_Landing_Chain', 'M2_Hex5_Transport_Attack_Chain', false)
        end
    end

    -- Experimental Response
    for _, player in ScenarioInfo.HumanPlayers do
        local experimentals = ArmyBrains[player]:GetListOfUnits(categories.EXPERIMENTAL - categories.AIR, false)
        num = table.getn(experimentals)
        if(num > 0) then
            if(num > 4) then
                num = 4
            end
            for i = 1, num do
                for j = 1, Difficulty do
                    units = ScenarioUtils.CreateArmyGroupAsPlatoon('Hex5', 'M2_Hex5_Adapt_Bombers', 'GrowthFormation')
                    IssueAttack(units:GetPlatoonUnits(), experimentals[i])
                    ScenarioFramework.PlatoonPatrolChain(units, 'M2_Hex5_InitAir_Attack_Chain')
                end
            end
        end
    end

    -- Shield Response
    local num = 0
    for _, player in ScenarioInfo.HumanPlayers do
        num = num + table.getn(ArmyBrains[player]:GetListOfUnits(categories.STRUCTURE * categories.SHIELD, false))
    end

    if(num > 0) then
        num = math.ceil(num/2)
        trigger = {6, 8, 10}
        if(num > trigger[Difficulty]) then
            num = trigger[Difficulty]
        end
        for i = 1, num do
            units = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Hex5', 'M2_Hex5_Adapt_Gunships', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(units, 'M2_Hex5_InitAir_Attack_Chain')
        end
    end

    -- Plane Response
    local num = 0
    for _, player in ScenarioInfo.HumanPlayers do
        num = num + table.getn(ArmyBrains[player]:GetListOfUnits((categories.MOBILE * categories.AIR) * (categories.GROUNDATTACK + categories.BOMBER), false))
    end

    trigger = {50, 30, 15}
    if(num >= trigger[Difficulty]) then
        num = math.ceil(num/15)
        if(num > 6) then
            num = 6
        end
        for i = 1, num do
            units = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Hex5', 'M2_Hex5_Adapt_AirSup', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(units, 'M2_Hex5_InitAir_Attack_Chain')
        end
    end
end

function StartMission2()
    -----------------------------------
    -- Primary Objective 1 - Defeat Hex5
    -----------------------------------
    ScenarioInfo.M2P1 = Objectives.KillOrCapture(
        'primary',                      -- type
        'incomplete',                   -- complete
        OpStrings.X05_M02_OBJ_010_010,  -- title
        OpStrings.X05_M02_OBJ_010_020,  -- description
        {                               -- target
            Units = {ScenarioInfo.Hex5CDR},
            MarkUnits = true,
        }
   )
    ScenarioInfo.M2P1:AddResultCallback(
        function(result)
            if(result) then
                ScenarioFramework.FlushDialogueQueue()
                while(ScenarioInfo.DialogueLock) do
                    WaitSeconds(0.2)
                end
                ScenarioFramework.CDRDeathNISCamera(ScenarioInfo.Hex5CDR, 5)
                ScenarioFramework.Dialogue(OpStrings.X05_M02_200, IntroMission3, true)
                -- torch Hex5s remaining units
                -- local units = ArmyBrains[Hex5]:GetListOfUnits(categories.ALLUNITS, false)
                -- for k,v in units do
                    -- if v and (not v:IsDead()) then
                        -- v:Kill()
                    -- end
                -- end
            end
        end
   )
    table.insert(AssignedObjectives, ScenarioInfo.M2P1)

    ScenarioFramework.CreateTimerTrigger(Hex5_Brack_Dialogue, 120)

    ------------------------------------------
    -- Secondary Objective 1 - Protect Fletcher
    ------------------------------------------
    ScenarioFramework.Dialogue(OpStrings.X05_M02_210)   -- Assist fletcher, vo
    ScenarioInfo.M2S1 = Objectives.Protect(
        'secondary',                    -- type
        'incomplete',                   -- complete
        OpStrings.X05_M02_OBJ_020_010,  -- title
        OpStrings.X05_M02_OBJ_020_020,  -- description
        {                               -- target
            Units = {ScenarioInfo.FletcherCDR},
        }
   )
    table.insert(AssignedObjectives, ScenarioInfo.M2S1)

    -- Dialogue triggers: sighting experimentals, updates from Fletcher as he builds stuff, subplot:
    ScenarioFramework.CreateTimerTrigger(M2ExperSightedTrigger, 180)

    -- updates from fletcher as he builds
    ScenarioFramework.CreateArmyStatTrigger(M2FletcherEconDialogue, ArmyBrains[Fletcher], 'FletcherEcon',
           {{ StatType = 'Units_Active', CompareType = 'GreaterThanOrEqual', Value = 1, Category = categories.ueb1301, },}) -- starting to build up economy

    ScenarioFramework.CreateArmyStatTrigger(M2FletcherTech2Dialogue, ArmyBrains[Fletcher], 'FletcherTech2',
           {{ StatType = 'Units_BeingBuilt', CompareType = 'GreaterThanOrEqual', Value = 1, Category = categories.FACTORY * categories.TECH2, },}) -- starting to build T3 factory

    ScenarioFramework.CreateArmyStatTrigger(M2FletcherTech3Dialogue, ArmyBrains[Fletcher], 'FletcherTech3',
            {{ StatType = 'Units_Active', CompareType = 'GreaterThanOrEqual', Value = 1, Category = categories.uel0309, },}) -- has hit tech 3

    ScenarioFramework.CreateArmyStatTrigger(M2FletcherExpDialogue, ArmyBrains[Fletcher], 'FletcherExper',
            {{ StatType = 'Units_BeingBuilt', CompareType = 'GreaterThanOrEqual', Value = 1, Category = categories.UEF * categories.EXPERIMENTAL, },}) -- has started a fatboy

    ScenarioFramework.CreateArmyStatTrigger(M2FletcherSpyPlane, ArmyBrains[Fletcher], 'FletcherSpyPlane',
            {{ StatType = 'Units_Active', CompareType = 'GreaterThanOrEqual', Value = 1, Category = categories.uel0401, },}) -- has hit tech 3

    ScenarioFramework.CreateArmyStatTrigger(M2FletcherBuildLandDialogue, ArmyBrains[Fletcher], 'FletcherLandbuilt',
            {{ StatType = 'Units_BeingBuilt', CompareType = 'GreaterThanOrEqual', Value = 1, Category = (categories.UEF * categories.LAND) - categories.uel0309 - categories.STRUCTURE - categories.EXPERIMENTAL - categories.uel0101, },}) -- has  built Land

    ScenarioFramework.CreateArmyStatTrigger(M2FletcherBuildAirDialogue, ArmyBrains[Fletcher], 'FletcherAirbuilt',
            {{ StatType = 'Units_BeingBuilt', CompareType = 'GreaterThanOrEqual', Value = 1, Category = (categories.UEF * categories.AIR) - categories.STRUCTURE - categories.uea0101 - categories.uea0302, },}) -- has  built Air

    -- subplot, tech reveal, warning, taunts
    ScenarioFramework.CreateTimerTrigger(M2SubplotDialogue, 600)

    -- T3 aa gunship, T3 xport, t3 gunship.
    ScenarioFramework.UnrestrictWithVoiceoverAndDelay(categories.xaa0305, "aeon", 120, OpStrings.X05_M01_210)
    ScenarioFramework.UnrestrictWithVoiceoverAndDelay(categories.xea0306, "uef", 120, OpStrings.X05_M01_200)
    ScenarioFramework.UnrestrictWithVoiceoverAndDelay(categories.xra0305, "cybran", 120, OpStrings.X05_M01_220)

    if ScenarioInfo.M2SpiderbotSpawned == true then
        -- If we spawned in spiderbots for counterattack, play some VO warning
        ScenarioFramework.CreateTimerTrigger(M2CounterSpiderebotWarning, 10)
    end
    SetupM2Taunts()
end

function M2FletcherHelpDialogue()
    if ScenarioInfo.M2FletcherWarningPlayed == false then
        -- fletcher asks for help when fatboys near soulripper
        ScenarioFramework.Dialogue(OpStrings.X05_M02_240)
        ScenarioInfo.M2FletcherWarningPlayed = true
    end
end

function M2CounterSpiderebotWarning()
    -- warning of incoming spiderbots in counterattack
    ScenarioFramework.Dialogue(OpStrings.X05_M02_220)
end

function FletcherWarp()
    ScenarioFramework.Dialogue(OpStrings.X05_M03_329)
    ForkThread(
        function()
            ScenarioFramework.FakeTeleportUnit(ScenarioInfo.FletcherCDR, true)
        end
   )
    M2FletcherAI.DisableBase()
    if(ScenarioInfo.M2S1.Active) then
        ScenarioInfo.M2S1:ManualResult(false)
    end
end

function M2ExperSightedTrigger()
    -- delay creation of these triggers, to avoid NIS intel, and to keep dialogue from stacking up a tad
    ScenarioFramework.CreateArmyIntelTrigger(M2SpiderbotSighted, ArmyBrains[Player], 'LOSNow', false, true, categories.url0402, true, ArmyBrains[Hex5])
    ScenarioFramework.CreateArmyIntelTrigger(M2ScathisSighted, ArmyBrains[Player], 'LOSNow', false, true, categories.url0401, true, ArmyBrains[Hex5])
end

function M2SpiderbotSighted()
     ScenarioFramework.Dialogue(OpStrings.X05_M02_020)
end

function M2SpiderbotsDestroyed()
    -- when all Hex5s spider bots are killed, play some dialogue noting this.
    ScenarioInfo.M2NumSpiderKilled = ScenarioInfo.M2NumSpiderKilled + 1
    local spiderCount = {4, 6, 7}
    if(ScenarioInfo.M2NumSpiderKilled == spiderCount[Difficulty]) then
         if(ScenarioInfo.M2P1.Active) then
            ScenarioFramework.Dialogue(OpStrings.X05_M02_030)
         end
    end
end

function M2ScathisSighted()
     ScenarioFramework.Dialogue(OpStrings.X05_M02_040)
end

function M2ScathisDestroyed()
    -- let player know Scathis is gone
    if (ScenarioInfo.M2P1.Active) then
        ScenarioFramework.Dialogue(OpStrings.X05_M02_050)
    end
end

function M2FletcherEconDialogue()
    -- update from fletcher, as he hits next tech level
    ScenarioFramework.Dialogue(OpStrings.X05_M02_290)
end

function M2FletcherTech2Dialogue()
    ScenarioFramework.Dialogue(OpStrings.X05_M02_055)
end

function M2FletcherTech3Dialogue()
    ScenarioFramework.Dialogue(OpStrings.X05_M02_060)
end

function M2FletcherBuildLandDialogue()
    ScenarioFramework.Dialogue(OpStrings.X05_M02_075)
end

function M2FletcherBuildAirDialogue()
    ScenarioFramework.Dialogue(OpStrings.X05_M02_070)
end

function M2FletcherExpDialogue()
    ScenarioFramework.Dialogue(OpStrings.X05_M02_065)   -- "Fletcher: building a fatboy"
    ScenarioFramework.Dialogue(OpStrings.X05_M02_250)   -- "HQ: Defend base untill operational"
end

function M2FletcherSpyPlane()
    if(ScenarioInfo.MissionNumber == 2) then
        if (Difficulty < 3) then
            ScenarioFramework.Dialogue(OpStrings.X05_M02_350)   -- "make a spy plane to find cloaked Hex5"
        elseif (Difficulty == 3) then
            ScenarioFramework.Dialogue(OpStrings.X05_M02_360)   -- "make a spy plane to find cloaked and stealthed Hex5"
        end
    end
end

function M2SubplotDialogue()
    if(LeaderFaction == 'uef') then
        ScenarioFramework.Dialogue(OpStrings.X05_M02_090)
    elseif(LeaderFaction == 'cybran') then
        ScenarioFramework.Dialogue(OpStrings.X05_M02_100)
    end
end

function AmaliaDamaged()
    ScenarioFramework.Dialogue(OpStrings.X05_M02_160)
end

function AmaliaDamaged2()
    ScenarioFramework.Dialogue(OpStrings.X05_M02_170)
end

function AmaliaDestroyed()
    ScenarioFramework.Dialogue(OpStrings.X05_M02_190)
end

function KillOrder()
    local units = ArmyBrains[Hex5]:GetListOfUnits(categories.ALLUNITS, false)
    for k,v in units do
        if(not v:IsDead()) then
            v:Kill()
        end
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

            ForkThread(CheatExpEconomy)

            -----------
            -- M3 QAI AI
            -----------
            M3QAIAI.QAIMainBaseAI()
            M3QAIAI.QAILandBaseAI()
            M3QAIAI.QAIAirBaseAI()
            M3QAIAI.QAINavalBaseAI()
            M3QAIAI.QAICybranExpBaseAI()
            M3QAIAI.QAIAeonExpBaseAI()
            M3QAIAI.QAIUEFExpBaseAI()

            ---------------------
            -- QAI Initial Patrols
            ---------------------
            local units = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'M3_QAI_InitialAir_Defense_D' .. Difficulty, 'GrowthFormation')
            for k, v in units:GetPlatoonUnits() do
                ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M3_QAI_AirBase_Def_Chain')))
            end

            units = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'M3_QAI_LandBase_InitLand_Def1_D' .. Difficulty, 'GrowthFormation')
            for k, v in units:GetPlatoonUnits() do
                ScenarioFramework.GroupPatrolChain({v}, 'M3_QAI_LandBase_LandDef_Chain')
            end

            units = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'M3_QAI_Main_Base_InitLand_Defense_D' .. Difficulty, 'GrowthFormation')
            for k, v in units:GetPlatoonUnits() do
                ScenarioFramework.GroupPatrolChain({v}, 'M3_QAI_Main_Base_LandDef_Chain')
            end

            units = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'M3_QAI_Main_Base_InitAir_Defense_D' .. Difficulty, 'GrowthFormation')
            for k, v in units:GetPlatoonUnits() do
                ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M3_QAI_Main_Base_AirDef_Chain')))
            end

            for i = 1, 2 do
                units = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'M3_QAI_Naval_Def' .. i .. '_D' .. Difficulty, 'GrowthFormation')
                ScenarioFramework.PlatoonPatrolChain(units, 'M3_QAI_NavalBase_Def' .. i .. '_Chain')
            end

            -------------------
            -- QAI Experimentals
            -------------------
            local exp = ScenarioUtils.CreateArmyUnit('QAI', 'M3_QAI_Def_Spider1')
            local platoon = ArmyBrains[QAI]:MakePlatoon('', '')
            ArmyBrains[QAI]:AssignUnitsToPlatoon(platoon, {exp}, 'Attack', 'GrowthFormation')
            ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_QAI_Spider1_Def_Chain')

            exp = ScenarioUtils.CreateArmyUnit('QAI', 'M3_QAI_Def_Colos1')
            platoon = ArmyBrains[QAI]:MakePlatoon('', '')
            ArmyBrains[QAI]:AssignUnitsToPlatoon(platoon, {exp}, 'Attack', 'GrowthFormation')
            ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_QAI_Colos_Def_Chain')

            if(Difficulty == 3) then
                exp = ScenarioUtils.CreateArmyUnit('QAI', 'M3_QAI_Def_Scath1')
                platoon = ArmyBrains[QAI]:MakePlatoon('', '')
                ArmyBrains[QAI]:AssignUnitsToPlatoon(platoon, {exp}, 'Attack', 'GrowthFormation')
                ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_QAI_Scathis_Def_Chain')
            end

            for i = 1, Difficulty do
                exp = ScenarioUtils.CreateArmyUnit('QAI', 'M3_QAI_Def_Destro' .. i)
                platoon = ArmyBrains[QAI]:MakePlatoon('', '')
                ArmyBrains[QAI]:AssignUnitsToPlatoon(platoon, {exp}, 'Attack', 'GrowthFormation')
                ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_QAI_Destro' .. i .. '_Def_Chain')
            end

            exp = ScenarioUtils.CreateArmyUnit('QAI', 'M3_QAI_Def_Fatboy1')
            platoon = ArmyBrains[QAI]:MakePlatoon('', '')
            ArmyBrains[QAI]:AssignUnitsToPlatoon(platoon, {exp}, 'Attack', 'GrowthFormation')
            ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_QAI_Destro1_Def_Chain')

            if(Difficulty > 1) then
                exp = ScenarioUtils.CreateArmyUnit('QAI', 'M3_QAI_CounterFletcher_Fatboy')
                platoon = ArmyBrains[QAI]:MakePlatoon('', '')
                ArmyBrains[QAI]:AssignUnitsToPlatoon(platoon, {exp}, 'Attack', 'GrowthFormation')
                ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_QAI_Destro1_Def_Chain')
            end

            if(Difficulty > 1) then
                exp = ScenarioUtils.CreateArmyUnit('QAI', 'M3_QAI_Def_Soulrip1')
                platoon = ArmyBrains[QAI]:MakePlatoon('', '')
                ArmyBrains[QAI]:AssignUnitsToPlatoon(platoon, {exp}, 'Attack', 'GrowthFormation')
                ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_QAI_Soulrip1_Chain')
            end

            exp = ScenarioUtils.CreateArmyUnit('QAI', 'M3_QAI_Def_Soulrip2')
            platoon = ArmyBrains[QAI]:MakePlatoon('', '')
            ArmyBrains[QAI]:AssignUnitsToPlatoon(platoon, {exp}, 'Attack', 'GrowthFormation')
            ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_QAI_Soulrip2_Def_Chain')

            ---------------------
            -- QAI Static Defenses
            ---------------------
            ScenarioUtils.CreateArmyGroup('QAI', 'M3_QAI_ResourceBase1_D' .. Difficulty)
            ScenarioUtils.CreateArmyGroup('QAI', 'M3_QAI_Eastern_Defense_Camp_D' .. Difficulty)

            ---------------
            -- QAI Mainframe
            ---------------
            ScenarioInfo.QAIBuildingGroup = ScenarioUtils.CreateArmyGroup('QAI', 'M3_Main_Objective_Buildings')
            for k, v in ScenarioInfo.QAIBuildingGroup do
                v:SetCanBeKilled(false)
                v:SetDoNotTarget(true)
                v:SetCanTakeDamage(false)
                v:SetReclaimable(false)
                v:SetCapturable(false)
            end
            ScenarioInfo.QAIBuilding = ScenarioInfo.UnitNames[QAI]['QAI_Main_Building']
            ScenarioInfo.QAIBuilding:SetCustomName(LOC '{i QAI}')

            ----------
            -- Brackman
            ----------
            ScenarioInfo.BrackmanCrab = ScenarioUtils.CreateArmyUnit('Brackman', 'Brackman')
            ScenarioInfo.BrackmanCrab:SetCapturable(false)
            ScenarioInfo.BrackmanCrab:SetReclaimable(false)
            ScenarioInfo.BrackmanCrab:ShowBone('Missile_Turret', true)
            ScenarioInfo.BrackmanCrab:SetRegenRate(50)
            ScenarioFramework.PauseUnitDeath(ScenarioInfo.BrackmanCrab)
            BrackmanTM:AddTauntingCharacter(ScenarioInfo.BrackmanCrab)
            IssueMove({ ScenarioInfo.BrackmanCrab }, ScenarioUtils.MarkerToPosition('M1_Hex5_Main_LandAttack1_5'))

            --------------------------------
            -- Aeon Secondary Objective Units
            --------------------------------
            if(LeaderFaction == 'aeon' and ScenarioInfo.Amalia and not ScenarioInfo.Amalia:IsDead()) then
                ScenarioUtils.CreateArmyGroup('Order', 'M3_Order_ResearchBase_D' .. Difficulty)
                local units = ScenarioUtils.CreateArmyGroup('Order', 'M3_Order_NonObjective_Buildings')
                for k,v in units do
                    v:SetCanBeKilled(false)
                    v:SetDoNotTarget(true)
                    v:SetCanTakeDamage(false)
                    v:SetReclaimable(false)
                    v:SetCapturable(false)
                end
                ScenarioInfo.ResearchStation = ScenarioUtils.CreateArmyUnit('Order', 'M3_Order_Obj_Building')
                ScenarioInfo.ResearchStation:SetCanBeKilled(false)
                ScenarioInfo.ResearchStation:SetDoNotTarget(true)
                ScenarioInfo.ResearchStation:SetCanTakeDamage(false)
                ScenarioInfo.ResearchStation:SetReclaimable(false)
                ScenarioInfo.OrderColossus = ScenarioUtils.CreateArmyUnit('Order', 'M3_Order_Obj_Colos')
                ScenarioFramework.CreateUnitDeathTrigger(M3ColossusDeath, ScenarioInfo.OrderColossus)
                ScenarioInfo.OrderColossus:SetAllWeaponsEnabled(false)
                ScenarioFramework.CreateTimerTrigger(M3S1Failed, 1200)
            end

            ScenarioFramework.Dialogue(OpStrings.X05_M03_010)          -- Not using this currently, as we dont allow Hex5s base to persist into M3.
            ForkThread(IntroMission3NIS)
        end
   )
end

function CheatExpEconomy()
    for i = 5, 6 do
        ArmyBrains[i]:GiveStorage('MASS', 10000)
        ArmyBrains[i]:GiveStorage('ENERGY', 10000)
    end
    while(true) do
        for i = 5, 6 do
            ArmyBrains[i]:GiveResource('MASS', 10000)
            ArmyBrains[i]:GiveResource('ENERGY', 10000)
            WaitSeconds(1)
        end
    end
end

function IntroMission3NIS()

    ScenarioFramework.SetPlayableArea('M3Area', false)

    -- Visibility on QAI
    ScenarioFramework.CreateVisibleAreaLocation(40, ScenarioUtils.MarkerToPosition('M3_Vis_1'), 2, ArmyBrains[Player])

    Cinematics.EnterNISMode()
    Cinematics.SetInvincible('M2Area')

    WaitSeconds(1)

    ScenarioFramework.Dialogue(OpStrings.X05_M02_201, nil, true)

    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_3_1_2'), 0)
    WaitSeconds(1)
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_3_1'), 4)
    WaitSeconds(1)

    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_3_2'), 3)
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_3_3'), 4)

    ScenarioFramework.Dialogue(OpStrings.X05_M02_202, nil, true)
    ScenarioFramework.Dialogue(OpStrings.X05_M02_203, nil, true)

    -- WaitSeconds(1)
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_3_4'), 3)
    WaitSeconds(3)

    Cinematics.SetInvincible('M2Area', true)
    Cinematics.ExitNISMode()

    M3Counterattack()
    StartMission3()
end

function M3Counterattack()
    local trigger = {}

    ---------------
    -- Counterattack
    ---------------

    -- Default Fletcher Attacks
    units = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'M3_QAI_Counter_Fletcher_Land_D' .. Difficulty, 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(units, 'M3_QAI_Fatboy_AttackFletcher_Chain')

    units = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'M3_QAI_Counter_Fletcher_Air_D' .. Difficulty, 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(units, 'M3_QAI_AirBase_AttackFletcher_Chain')

    -- If Fletcher > X fatboys, spawn spiderbots
    local num = table.getn(ArmyBrains[Fletcher]:GetListOfUnits(categories.uel0401, false))
    if(num > 0) then
        trigger = {1, 2, 3}
        if(num > trigger[Difficulty]) then
            num = trigger[Difficulty]
        end
        for i = 1, num do
            exp = ScenarioUtils.CreateArmyUnit('QAI', 'M3_QAI_EasternSpider_' .. i)
            platoon = ArmyBrains[QAI]:MakePlatoon('', '')
            ArmyBrains[QAI]:AssignUnitsToPlatoon(platoon, {exp}, 'Attack', 'GrowthFormation')
            ScenarioFramework.PlatoonPatrolRoute(platoon, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M3_QAI_Easter_Adapt_Spider123_Chain')))
        end
    end

    -- Default Air Attacks
    local airChains = {'M3_QAI_ExpBase_Attack_Chain', 'M3_QAI_ExpBase_Attack_Chain', 'M3_QAI_AirBase_Attack_1_Chain'}
    for i = 1, 3 do
        units = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'M3_QAI_CounterAttack_Air' .. i .. '_D' .. Difficulty, 'GrowthFormation')
        ScenarioFramework.PlatoonPatrolChain(units, airChains[i])
    end

    -- Default Land Attacks
    local landChains = {'M3_QAI_ExpBase_Attack_Chain', 'M3_QAI_ExpBase_Attack_Chain', 'M3_QAI_LandBase_Attack1_Chain', 'M3_QAI_Main_Base_LandAttack_Chain', 'M3_QAI_Main_Base_LandAttack_Chain', 'M3_QAI_Main_Base_LandAttack_Chain'}
    for i = 1, 6 do
        units = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'M3_QAI_CounterAttack_Land' .. i .. '_D' .. Difficulty, 'GrowthFormation')
        ScenarioFramework.PlatoonPatrolChain(units, landChains[i])
    end

    -- If player > [225, 200, 25] structures, spawns land attack
    local num = 0
    for _, player in ScenarioInfo.HumanPlayers do
        num = num + table.getn(ArmyBrains[player]:GetListOfUnits(categories.STRUCTURE - categories.WALL, false))
    end

    trigger = {225, 200, 25}
    if(num > trigger[Difficulty]) then
        units = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('QAI', 'M3_QAI_Counter_Land_Adapt_1', 'GrowthFormation', 5)
        ScenarioFramework.PlatoonPatrolChain(units, 'M3_QAI_ExpBase_Attack_Chain')
        -- If player > [250, 225, 50] structures, spawns land attack
        trigger = {250, 225, 50}
        if(num > trigger[Difficulty]) then
            units = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('QAI', 'M3_QAI_Counter_Land_Adapt_2', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(units, 'M3_QAI_ExpBase_Attack_Chain')
            -- If player > [275, 250, 75] structures, spawns land attack
            trigger = {275, 250, 75}
            if(num > trigger[Difficulty]) then
                units = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('QAI', 'M3_QAI_Counter_Land_Adapt_3', 'GrowthFormation', 5)
                ScenarioFramework.PlatoonPatrolChain(units, 'M3_QAI_ExpBase_Attack_Chain')
            end
        end
    end

    -- If player > [25, 15, 5] T2/T3 DF or artillery structures, spawns land attack
    local num = 0
    for _, player in ScenarioInfo.HumanPlayers do
        num = num + table.getn(ArmyBrains[player]:GetListOfUnits(((categories.STRUCTURE * categories.DIRECTFIRE) - categories.TECH1) + ((categories.STRUCTURE * categories.ARTILLERY) - categories.TECH1), false))
    end

    trigger = {25, 15, 5}
    if(num > trigger[Difficulty]) then
        units = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('QAI', 'M3_QAI_Counter_Land_Adapt_4', 'GrowthFormation', 5)
        ScenarioFramework.PlatoonPatrolChain(units, 'M3_QAI_ExpBase_Attack_Chain')
        -- If player > [30, 20, 10] T2/T3 DF or artillery structures, spawns land attack
        trigger = {30, 20, 10}
        if(num > trigger[Difficulty]) then
            units = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('QAI', 'M3_QAI_Counter_Land_Adapt_5', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(units, 'M3_QAI_ExpBase_Attack_Chain')
            -- If player > [35, 25, 15] T2/T3 DF or artillery structures, spawns land attack
            trigger = {35, 25, 15}
            if(num > trigger[Difficulty]) then
                units = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('QAI', 'M3_QAI_Counter_Land_Adapt_6', 'GrowthFormation', 5)
                ScenarioFramework.PlatoonPatrolChain(units, 'M3_QAI_ExpBase_Attack_Chain')
            end
        end
    end

    -- If player has > [20, 10, 5] T2/T3 factories, spawns land attack
    local num = 0
    for _, player in ScenarioInfo.HumanPlayers do
        num = num + table.getn(ArmyBrains[player]:GetListOfUnits(categories.FACTORY - categories.TECH1, false))
    end

    trigger = {20, 10, 5}
    if(num > trigger[Difficulty]) then
        units = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('QAI', 'M3_QAI_Counter_Land_Adapt_7', 'GrowthFormation', 5)
        ScenarioFramework.PlatoonPatrolChain(units, 'M3_QAI_ExpBase_Attack_Chain')
        -- If player has > [40, 15, 8] T2/T3 factories, spawns land attack
        trigger = {40, 15, 8}
        if(num > trigger[Difficulty]) then
            units = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('QAI', 'M3_QAI_Counter_Land_Adapt_8', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(units, 'M3_QAI_ExpBase_Attack_Chain')
        end
    end

    -- If player has > [30, 20, 5] shields, spawns land attack
    local num = 0
    for _, player in ScenarioInfo.HumanPlayers do
        num = num + table.getn(ArmyBrains[player]:GetListOfUnits(categories.STRUCTURE * categories.SHIELD, false))
    end

    trigger = {30, 20, 5}
    if(num > trigger[Difficulty]) then
        units = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('QAI', 'M3_QAI_Counter_Land_Adapt_9', 'GrowthFormation', 5)
        ScenarioFramework.PlatoonPatrolChain(units, 'M3_QAI_ExpBase_Attack_Chain')
        -- If player has > [35, 25, 5] T2/T3 factories, spawns land attack
        trigger = {35, 25, 5}
        if(num > trigger[Difficulty]) then
            units = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('QAI', 'M3_QAI_Counter_Land_Adapt_10', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(units, 'M3_QAI_ExpBase_Attack_Chain')
        end
    end

    -- If player has > [475, 450, 350] units, spawn fatboy
    local num = 0
    for _, player in ScenarioInfo.HumanPlayers do
        num = num + table.getn(ArmyBrains[player]:GetListOfUnits(categories.ALLUNITS - categories.WALL, false))
    end

    trigger = {475, 450, 350}
    if(num > trigger[Difficulty]) then
        local exp = ScenarioUtils.CreateArmyUnit('QAI', 'M3_QAI_Adapt_Fatboy_1')
        platoon = ArmyBrains[QAI]:MakePlatoon('', '')
        ArmyBrains[QAI]:AssignUnitsToPlatoon(platoon, {exp}, 'Attack', 'GrowthFormation')
        ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_QAI_ExpBase_Attack_Chain')
    end

    -- If player has > [4, 2, 0] experimentals, spawn fatboy
    local num = 0
    for _, player in ScenarioInfo.HumanPlayers do
        num = num + table.getn(ArmyBrains[player]:GetListOfUnits(categories.EXPERIMENTAL, false))
    end

    trigger = {4, 2, 0}
    if(num > trigger[Difficulty]) then
        local exp = ScenarioUtils.CreateArmyUnit('QAI', 'M3_QAI_Adapt_Fatboy_2')
        platoon = ArmyBrains[QAI]:MakePlatoon('', '')
        ArmyBrains[QAI]:AssignUnitsToPlatoon(platoon, {exp}, 'Attack', 'GrowthFormation')
        ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_QAI_ExpBase_Attack_Chain')
    end

    -- If player has > [25, 15, 8] shields, spawn fatboy
    local num = 0
    for _, player in ScenarioInfo.HumanPlayers do
        num = num + table.getn(ArmyBrains[player]:GetListOfUnits(categories.STRUCTURE * categories.SHIELD, false))
    end

    trigger = {25, 15, 8}
    if(num > trigger[Difficulty]) then
        local exp = ScenarioUtils.CreateArmyUnit('QAI', 'M3_QAI_Adapt_Fatboy_3')
        platoon = ArmyBrains[QAI]:MakePlatoon('', '')
        ArmyBrains[QAI]:AssignUnitsToPlatoon(platoon, {exp}, 'Attack', 'GrowthFormation')
        ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_QAI_ExpBase_Attack_Chain')
    end

    -- Spawns Air Superiority for every [25, 15, 10] T2/T3 planes, max 5 groups
    local num = 0
    for _, player in ScenarioInfo.HumanPlayers do
        num = num + table.getn(ArmyBrains[player]:GetListOfUnits((categories.MOBILE * categories.AIR) - categories.TECH1, false))
    end

    trigger = {25, 15, 10}
    if(num > 0) then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 5) then
            num = 5
        end
        for i = 1, num do
            units = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'M3_QAI_Adapt_AirSup', 'GrowthFormation')
            ScenarioFramework.PlatoonPatrolChain(units, 'M3_QAI_AirBase_Attack_2_Chain')
        end
    end

    -- Experimental Response
    if(Difficulty > 1) then
        for _, player in ScenarioInfo.HumanPlayers do
            local experimentals = ArmyBrains[player]:GetListOfUnits(categories.EXPERIMENTAL, false)
                num = table.getn(experimentals)
                if(num > 0) then
                    if(num > 3) then
                        num = 3
                    end
                    for i = 1, num do
                        for j = 1, Difficulty do
                            units = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'M3_QAI_Adapt_Bombers', 'GrowthFormation')
                            IssueAttack(units:GetPlatoonUnits(), experimentals[i])
                            ScenarioFramework.PlatoonPatrolChain(units, 'M3_QAI_AirBase_Attack_1_Chain')
                        end
                    end
                end
        end
    end

    -- spawns gunships for every 3, 2, 1 shields, up to 5 groups
    local num = 0
    for _, player in ScenarioInfo.HumanPlayers do
        num = num + table.getn(ArmyBrains[player]:GetListOfUnits(categories.STRUCTURE * categories.SHIELD, false))
    end

    if(num > 0) then
        trigger = {3, 2, 1}
        num = math.ceil(num/trigger[Difficulty])
        if(num > 5) then
            num = 5
        end
        for i = 1, num do
            units = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'M3_QAI_Adapt_Gunships', 'GrowthFormation')
            ScenarioFramework.PlatoonPatrolChain(units, 'M3_QAI_AirBase_Attack_1_Chain')
        end
    end

    -- Spawns transport attacks for every 3, 2, 1 T2/T3 defensive structure
    local num = 0
    for _, player in ScenarioInfo.HumanPlayers do
        num = num + table.getn(ArmyBrains[player]:GetListOfUnits((categories.STRUCTURE * categories.DEFENSE) - categories.TECH1, false))
    end

    if(num > 0) then
        trigger = {3, 2, 1}
        num = math.ceil(num/trigger[Difficulty])
        if(num > 6) then
            num = 6
        end
        for i = 1, num do
            units = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'M3_QAI_Adapt_Xport', 'GrowthFormation')
            for k,v in units:GetPlatoonUnits() do
                if(v:GetUnitId() == 'ura0104') then
                    local interceptors = ScenarioUtils.CreateArmyGroup('QAI', 'M3_QAI_Adapt_Xport_Interceptors')
                    IssueGuard(interceptors, v)
                    break
                end
            end
            ScenarioFramework.PlatoonAttackWithTransports(units, 'M2_Hex5_Transport_Landing_Chain', 'M2_Hex5_Transport_Attack_Chain', false)
        end
    end

    -- If player has > [100, 60, 20] T2/T3 planes, spawn Czar, 3, 4, 5 groups max
    local num = 0
    for _, player in ScenarioInfo.HumanPlayers do
        num = num + table.getn(ArmyBrains[player]:GetListOfUnits((categories.MOBILE * categories.AIR) - categories.TECH1, false))
    end

    trigger = {100, 60, 20}
    if(num > trigger[Difficulty]) then
        ScenarioInfo.M3Czar = ScenarioUtils.CreateArmyUnit('QAI', 'M3_QAI_Counter_Czar')
        ScenarioInfo.M3CzarPassengers = {}
        local quantity = {50, 30, 10}
        num = math.ceil(num/quantity[Difficulty])
        local total = {3, 4, 5}
        if(num > total[Difficulty]) then
            num = total[Difficulty]
        end
        for i = 1, num do
            units = ScenarioUtils.CreateArmyGroup('QAI', 'M3_QAI_Czar_Aircraft')
            for k, v in units do
                IssueStop({v})
                ScenarioInfo.M3Czar:AddUnitToStorage(v)
                table.insert(ScenarioInfo.M3CzarPassengers, v)
            end
        end

        ScenarioFramework.CreateUnitDamagedTrigger(CzarDamaged, ScenarioInfo.M3Czar)

        platoon = ArmyBrains[QAI]:MakePlatoon('', '')
        ArmyBrains[QAI]:AssignUnitsToPlatoon(platoon, {ScenarioInfo.M3Czar}, 'Attack', 'GrowthFormation')
        ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_QAI_AirBase_Attack_1_Chain')
    end
end

function CzarDamaged()
    ForkThread(
        function()
            if(not ScenarioInfo.BombersReleased) then
                ScenarioInfo.BombersReleased = true
                IssueClearCommands({ScenarioInfo.M3Czar})
                IssueTransportUnload({ScenarioInfo.M3Czar}, ScenarioInfo.M3Czar:GetPosition())
                WaitSeconds(5)
            end
        end
   )
end

function StartMission3()
    -- Just in case any of this was un-done by the SetInvincible call earlier...
    for k, v in ScenarioInfo.QAIBuildingGroup do
        v:SetCanBeKilled(false)
        v:SetDoNotTarget(true)
        v:SetCanTakeDamage(false)
        v:SetReclaimable(false)
        v:SetCapturable(false)
    end

    -- HQ explains the ping setup for controlling Brackman
    ScenarioFramework.Dialogue(OpStrings.X05_M03_015)
    ScenarioFramework.Dialogue(OpStrings.X05_M02_280)

    -- Soon after start, warn player of incoming initial attack
    ScenarioFramework.CreateTimerTrigger(M3WarnAttack, 16)

    -- Dialogue triggered by first sighting of QAI experimental
    ScenarioFramework.CreateArmyIntelTrigger(M3QAIExperSpotted, ArmyBrains[Player],
        'LOSNow', false, true, categories.EXPERIMENTAL, true, ArmyBrains[QAI])

    ScenarioFramework.CreateTimerTrigger(M3Subplot, 430)

    ------------------------------------------------------------
    -- Primary Objective 1 - Escort Dr. Brackman to the Mainframe
    ------------------------------------------------------------
    ScenarioInfo.M3P1 = Objectives.SpecificUnitsInArea(
        'primary',                      -- type
        'incomplete',                   -- status
        OpStrings.X05_M03_OBJ_010_030,  -- title
        OpStrings.X05_M03_OBJ_010_040,  -- description
        {                               -- target
            Units = {ScenarioInfo.BrackmanCrab},
            Area = 'M3_BrackmanEscortArea',
            MarkArea = true,
        }
   )
    ScenarioInfo.M3P1:AddResultCallback(
        function(result)
            if result then
                ForkThread(FinalNIS)
            end
        end
   )
    table.insert(AssignedObjectives, ScenarioInfo.M3P1)
    ScenarioFramework.CreateTimerTrigger(M3P1Reminder1, 1860)

    --------------------------------------------
    -- Primary Objective 2 - Protect Dr. Brackman
    --------------------------------------------
    ScenarioInfo.M3P2 = Objectives.Protect(
        'primary',                              -- type
        'incomplete',                           -- complete
        OpStrings.X05_M03_OBJ_010_010,          -- title
        OpStrings.X05_M03_OBJ_010_020,          -- description
        {                                       -- target
            Units = {ScenarioInfo.BrackmanCrab},
        }
   )
    ScenarioInfo.M3P2:AddResultCallback(
        function(result)
            if(not result and not ScenarioInfo.OpEnded) then
                ScenarioFramework.Dialogue(OpStrings.X05_M03_130, nil, true)
                ScenarioFramework.PlayerLose(OpStrings.X05_M03_135, AssignedObjectives)
            end
        end
   )
    table.insert(AssignedObjectives, ScenarioInfo.M3P2)

    if(LeaderFaction == 'aeon' and ScenarioInfo.Amalia and not ScenarioInfo.Amalia:IsDead()) then
        -------------------------------------------------------
        -- Secondary Objective 1 Aeon - Capture Science Building
        -------------------------------------------------------
        ScenarioInfo.M3S1 = Objectives.Capture(
            'secondary',                    -- type
            'incomplete',                   -- complete
            OpStrings.X05_M03_OBJ_010_070,  -- title
            OpStrings.X05_M03_OBJ_010_080,  -- description
            {
                Units = {ScenarioInfo.ResearchStation},
                FlashVisible = true,
            }
       )
        ScenarioInfo.M3S1:AddResultCallback(
            function(result)
                if(result and ScenarioInfo.OrderColossus and not ScenarioInfo.OrderColossus:IsDead()) then
                    ScenarioFramework.GiveUnitToArmy(ScenarioInfo.OrderColossus, Player)
                     ScenarioFramework.Dialogue(OpStrings.X05_M03_320)
                elseif (not result) then
                    -- Failure stuff here
                end
            end
       )
        table.insert(AssignedObjectives, ScenarioInfo.M3S1)
        ScenarioFramework.Dialogue(OpStrings.X05_M03_290)
        ScenarioFramework.CreateTimerTrigger(M3S1Reminder1, 1600)
    end

    -- Setup ping, dialogue, taunt-controlled health warnings
    ScenarioInfo.BrackmanPing = PingGroups.AddPingGroup(OpStrings.X05_M01_OBJ_010_070, 'xrl0403', 'move', OpStrings.X05_M01_OBJ_010_075)
    ScenarioInfo.BrackmanPing:AddCallback(MoveBrackman)
    SetupBrackmanM3Warnings()
    ScenarioFramework.CreateUnitDamagedTrigger(M2BrackmanTakingDamage1, ScenarioInfo.BrackmanCrab, .01)  -- guanranteed first-damaged warning

    SetupM3Taunts()

    -- Unlock novax after 2 minutes.
    ScenarioFramework.UnrestrictWithVoiceoverAndDelay(categories.xeb2402, "uef", 120, OpStrings.X05_M02_012)
end

function M3S1Failed()
    if (ScenarioInfo.M3S1.Active and ScenarioInfo.OrderColossus and not ScenarioInfo.OrderColossus:IsDead()) then
        ScenarioInfo.M3S1:ManualResult(false)
        ScenarioFramework.Dialogue(OpStrings.X05_M03_340)
        ScenarioInfo.OrderColossus:SetAllWeaponsEnabled(true)
        local platoon = ArmyBrains[Order]:MakePlatoon('', '')
        ArmyBrains[Order]:AssignUnitsToPlatoon(platoon, {ScenarioInfo.OrderColossus}, 'Attack', 'GrowthFormation')
        ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_Order_Colos_Attack_Chain')
    end
end

function M3ColossusDeath()
    -- player destroys coloss, instead of capturing it.
    if (ScenarioInfo.M3S1.Active) then
        ScenarioInfo.M3S1:ManualResult(true)
        ScenarioFramework.Dialogue(OpStrings.X05_M03_350)
    end
end

function MoveBrackman(location)
    if(ScenarioInfo.BrackmanCrab and not ScenarioInfo.BrackmanCrab:IsDead()) then
        IssueStop({ScenarioInfo.BrackmanCrab})
        IssueClearCommands({ScenarioInfo.BrackmanCrab})
        IssueMove({ScenarioInfo.BrackmanCrab}, location)
    end
end

 -- Brackman taking damage warnings

function M2BrackmanTakingDamage1()
    if not ScenarioInfo.BrackmanCrab:IsDead() then
        ScenarioFramework.Dialogue(OpStrings.X05_M03_020)
    end
end

function M3WarnAttack()
    ScenarioFramework.Dialogue(OpStrings.X05_M03_140)
end

function M3QAIExperSpotted()
    ScenarioFramework.Dialogue(OpStrings.X05_M03_150)
end

function M3Subplot()
    if(LeaderFaction == 'uef') then
        ScenarioFramework.Dialogue(OpStrings.X05_M03_270)
    end
end

function FinalNIS()
    -- Keep the player from dying during this
    ScenarioInfo.PlayerCDR:SetCanBeKilled(false)

    ScenarioFramework.FlushDialogueQueue()
    while(ScenarioInfo.DialogueLock) do
        WaitSeconds(0.2)
    end

    Cinematics.EnterNISMode()
    WaitSeconds(1)

    -- Make absolutely sure that nothing is going to attack the NIS Brackman crab or QAI
    SetAlliance(Brackman, Fletcher, 'Ally')
    SetAlliance(Brackman, Hex5, 'Neutral')
    SetAlliance(Brackman, QAI, 'Neutral')
    SetAlliance(Brackman, AeonArmy, 'Neutral')
    SetAlliance(Brackman, UEFArmy, 'Neutral')
    SetAlliance(Brackman, Order, 'Neutral')

    for _, player in ScenarioInfo.HumanPlayers do
        SetAlliance(QAI, player, 'Neutral')
    end
    SetAlliance(QAI, Fletcher, 'Neutral')
    SetAlliance(QAI, Hex5, 'Neutral')
    SetAlliance(QAI, Brackman, 'Neutral')
    SetAlliance(QAI, AeonArmy, 'Neutral')
    SetAlliance(QAI, UEFArmy, 'Neutral')
    SetAlliance(QAI, Order, 'Neutral')

    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_4_Intro_1'), 0)

    local tempUnits = ArmyBrains[QAI]:GetListOfUnits(categories.ALLUNITS, false)
    for k, unit in tempUnits do
        if (unit and not unit:IsDead()) then
            IssueClearCommands({ unit })
        end
    end

    tempUnits = ScenarioFramework.GetCatUnitsInArea(categories.MOBILE, 'Final_NIS_Area_SW', ArmyBrains[QAI])
    for k, unit in tempUnits do
        if (unit and not unit:IsDead()) then
            IssueMove({ unit },  ScenarioUtils.MarkerToPosition('NIS_Final_Destination_SW'))
        end
    end
    tempUnits = ScenarioFramework.GetCatUnitsInArea(categories.MOBILE, 'Final_NIS_Area_SW', ArmyBrains[Player])
    for k, unit in tempUnits do
        if (unit and not unit:IsDead()) then
            IssueClearCommands({ unit })
            IssueMove({ unit },  ScenarioUtils.MarkerToPosition('NIS_Final_Destination_SW'))
        end
    end

    tempUnits = ScenarioFramework.GetCatUnitsInArea(categories.MOBILE, 'Final_NIS_Area_SE', ArmyBrains[QAI])
    for k, unit in tempUnits do
        if (unit and not unit:IsDead()) then
            IssueMove({ unit },  ScenarioUtils.MarkerToPosition('NIS_Final_Destination_SE'))
        end
    end
    tempUnits = ScenarioFramework.GetCatUnitsInArea(categories.MOBILE, 'Final_NIS_Area_SE', ArmyBrains[Player])
    for k, unit in tempUnits do
        if (unit and not unit:IsDead()) then
            IssueClearCommands({ unit })
            IssueMove({ unit },  ScenarioUtils.MarkerToPosition('NIS_Final_Destination_SE'))
        end
    end

    tempUnits = ScenarioFramework.GetCatUnitsInArea(categories.MOBILE, 'Final_NIS_Area_NW', ArmyBrains[QAI])
    for k, unit in tempUnits do
        if (unit and not unit:IsDead()) then
            IssueMove({ unit },  ScenarioUtils.MarkerToPosition('NIS_Final_Destination_NW'))
        end
    end
    tempUnits = ScenarioFramework.GetCatUnitsInArea(categories.MOBILE, 'Final_NIS_Area_NW', ArmyBrains[Player])
    for k, unit in tempUnits do
        if (unit and not unit:IsDead()) then
            IssueClearCommands({ unit })
            IssueMove({ unit },  ScenarioUtils.MarkerToPosition('NIS_Final_Destination_NW'))
        end
    end

    tempUnits = ScenarioFramework.GetCatUnitsInArea(categories.MOBILE, 'Final_NIS_Area_NE', ArmyBrains[QAI])
    for k, unit in tempUnits do
        if (unit and not unit:IsDead()) then
            IssueMove({ unit },  ScenarioUtils.MarkerToPosition('NIS_Final_Destination_NE'))
        end
    end
    tempUnits = ScenarioFramework.GetCatUnitsInArea(categories.MOBILE, 'Final_NIS_Area_NE', ArmyBrains[Player])
    for k, unit in tempUnits do
        if (unit and not unit:IsDead()) then
            IssueClearCommands({ unit })
            IssueMove({ unit },  ScenarioUtils.MarkerToPosition('NIS_Final_Destination_NE'))
        end
    end

    -- While looking elsewhere, delete the old Brackman and spawn in our NIS version of him
    -- Set his health to the same value so that the damage effects will be consistent
    -- Then make him as invincible as we can
    local healthValue = ScenarioInfo.BrackmanCrab:GetHealth()
    ScenarioInfo.BrackmanCrab:Destroy()
    ScenarioInfo.NISCrab = ScenarioUtils.CreateArmyUnit('Brackman', 'NIS_Brackman')

    ScenarioInfo.NISCrab:ShowBone('Missile_Turret', true)

    ScenarioInfo.NISCrab:AdjustHealth(ScenarioInfo.NISCrab, healthValue)
    ScenarioInfo.NISCrab:SetCanBeKilled(false)
    ScenarioInfo.NISCrab:SetDoNotTarget(true)
    ScenarioInfo.NISCrab:SetCanTakeDamage(false)

    -- Let QAI be targetted
    ScenarioInfo.QAIBuilding:SetDoNotTarget(false)

    ScenarioInfo.NISCrab:DisableAllButHackPegLauncher()
    ScenarioInfo.NISCrab:EnableHackPegLauncher()

    WaitSeconds(1)
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_4_Intro_2'), 3)
    WaitSeconds(1)

    -- Brackman starting things up
    ScenarioFramework.Dialogue(OpStrings.X05_M03_322, FinalNISPart2, true)
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_4_Crab_1'), 0)
    WaitSeconds(1)
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_4_Crab_2'), 8)
end

function FinalNISPart2()
    -- QAI being confident
    ScenarioFramework.Dialogue(OpStrings.X05_M03_323, AttackQAI, true)
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_4_QAI_1'), 0)
    WaitSeconds(1)
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_4_QAI_2'), 6)
end

function AttackQAI()
    -- Brackman being sneaky
    ScenarioFramework.Dialogue(OpStrings.X05_M03_324, FinalNISPart4, true)

    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_4_Shot_1'), 0)
    WaitSeconds(3)

    SetAllianceOneWay(Brackman, QAI, 'Enemy')
    IssueAttack({ ScenarioInfo.NISCrab }, ScenarioInfo.QAIBuilding)

    ForkThread(
        function()
            -- Safety, so that a second projectile doesn't get fired
            WaitSeconds(1.5)
            SetAllianceOneWay(Brackman, QAI, 'Neutral')
            IssueClearCommands({ ScenarioInfo.NISCrab })
        end
   )

    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_4_Shot_2'), 4)
    WaitSeconds(0.2)

    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_4_Shot_3'), 1.5)
    WaitSeconds(1)
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_4_Shot_4'), 8)
end

function FinalNISPart4()
    -- QAI becoming afraid
    WaitSeconds(3)
    ScenarioFramework.Dialogue(OpStrings.X05_M03_325, FinalNISPart5, true)
    -- Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_4_QAI_1'), 0)
    -- WaitSeconds(1)
    -- Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_4_QAI_2'), 6)
end

function FinalNISPart5()
    -- "Goodbye, QAI..."
    ScenarioFramework.Dialogue(OpStrings.X05_M03_326, KillQAI, true)
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_4_Crab_3'), 0)
    WaitSeconds(1)
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_4_Crab_4'), 3)
end

function KillQAI()
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_4_QAI_3'), 0)
    WaitSeconds(1)
    if (ScenarioInfo.QAIBuilding and not ScenarioInfo.QAIBuilding:IsDead()) then
        ScenarioInfo.QAIBuilding:SetCanBeKilled(true)
        ScenarioInfo.QAIBuilding:Kill()
    end
    ForkThread(KillQAIBuildingGroup)
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_4_QAI_4'), 2)
    WaitSeconds(1)

    -- "Goodbye."
    ScenarioFramework.Dialogue(OpStrings.X05_M03_327, FinalNISOver, true)
end

function FinalNISOver()
    WaitSeconds(2)

    ScenarioInfo.OpEnded = false
    ForkThread(PlayerWin)

    -- Move the crab out of the scene
    IssueClearCommands({ ScenarioInfo.NISCrab })
    IssueMove({ ScenarioInfo.NISCrab }, ScenarioUtils.MarkerToPosition('M3_QAI_LandBase_LandDef_3'))
    IssueMove({ ScenarioInfo.NISCrab }, ScenarioUtils.MarkerToPosition('Blank Marker 13'))

    WaitSeconds(2)

    -- Show the outlying buildings that aren't shown by the crab's line-of-sight
    ScenarioFramework.CreateVisibleAreaLocation(3, ScenarioUtils.MarkerToPosition('Final_NIS_Vismarker_1'), 1, ArmyBrains[Player])
    ScenarioFramework.CreateVisibleAreaLocation(3, ScenarioUtils.MarkerToPosition('Final_NIS_Vismarker_2'), 1, ArmyBrains[Player])
    ScenarioFramework.CreateVisibleAreaLocation(3, ScenarioUtils.MarkerToPosition('Final_NIS_Vismarker_3'), 1, ArmyBrains[Player])

    WaitSeconds(1)

    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_4_Overview'), 10)
end

function KillQAIBuildingGroup()
    for k, unit in ScenarioInfo.QAIBuildingGroup do
        if (unit and not unit:IsDead()) then
            WaitSeconds(0.3)
            unit:SetCanBeKilled(true)
            unit:Kill()
        end
    end
end

------------------------
-- Taunt Manager Dialogue
------------------------

function SetupM1Taunts()
    local resource1Struct = ArmyBrains[Hex5]:GetUnitsAroundPoint(categories.STRUCTURE - categories.WALL,
                                  ScenarioUtils.MarkerToPosition('M1_Hex5_Resource1_Marker'), 17, 'Ally')

    Hex5TM:AddUnitsKilledTaunt('TAUNT25', ArmyBrains[Hex5], categories.FACTORY, 3)
    Hex5TM:AddUnitGroupDeathPercentTaunt('TAUNT20', resource1Struct, .85)
    Hex5TM:AddEnemiesKilledTaunt('TAUNT19', ArmyBrains[Hex5], categories.FACTORY, 1)
    Hex5TM:AddUnitsKilledTaunt('X05_M02_010', ArmyBrains[Hex5], categories.urb1301, 1)

    QAITM:AddUnitsKilledTaunt('TAUNT12', ArmyBrains[Hex5], categories.urb4206, 2)
    QAITM:AddConstructionTaunt('TAUNT14', ArmyBrains[Player], categories.TECH3, 1)
end

function SetupM2Taunts()
    Hex5TM:AddEnemiesKilledTaunt('TAUNT23', ArmyBrains[Player], (categories.DEFENSE - (categories.SHIELD + categories.WALL)), 2)
    Hex5TM:AddDamageTaunt('TAUNT24', ScenarioInfo.PlayerCDR, .02)
    Hex5TM:AddEnemiesKilledTaunt('TAUNT21', ArmyBrains[Player], (categories.DEFENSE - (categories.SHIELD + categories.WALL)), 7)
    Hex5TM:AddUnitsKilledTaunt('TAUNT22', ArmyBrains[Player], categories.SHIELD, 2)
    Hex5TM:AddDamageTaunt('TAUNT26', ScenarioInfo.PlayerCDR, .30)

    QAITM:AddUnitsKilledTaunt('TAUNT11', ArmyBrains[Hex5], categories.ura0401, 1)

    -- play some encouragement from Fletcher as Hex5's base gets tooled
    local structures = ArmyBrains[Hex5]:GetListOfUnits(categories.STRUCTURE - (categories.FACTORY + categories.WALL), false)
    Hex5TM:AddUnitGroupDeathPercentTaunt('X05_M02_120', structures, .25)
    Hex5TM:AddUnitGroupDeathPercentTaunt('X05_M02_130', structures, .50)
    Hex5TM:AddUnitGroupDeathPercentTaunt('X05_M02_140', structures, .75)

    if (LeaderFaction == 'uef') then
        FletcherTM:AddDamageTaunt('X05_M02_310', ScenarioInfo.FletcherCDR, .1) -- UEF
    elseif (LeaderFaction == 'aeon') then
        FletcherTM:AddDamageTaunt('X05_M02_300', ScenarioInfo.FletcherCDR, .1) -- Aeon
    elseif (LeaderFaction == 'cybran') then
        FletcherTM:AddDamageTaunt('X05_M02_320', ScenarioInfo.FletcherCDR, .1) -- Cybran
    end
    FletcherTM:AddUnitsKilledTaunt('X05_M02_340', ArmyBrains[Fletcher], categories.ueb1301, 1)
    FletcherTM:AddUnitsKilledTaunt('X05_M02_330', ArmyBrains[Fletcher], categories.ueb1303, 4)
end

function SetupM3Taunts()
    local navalStruct = ArmyBrains[Hex5]:GetUnitsAroundPoint(categories.STRUCTURE - categories.WALL,
                                  ScenarioUtils.MarkerToPosition('M3_QAI_Naval_Base_Marker'), 40, 'Ally')
    local landStruct = ArmyBrains[Hex5]:GetUnitsAroundPoint(categories.STRUCTURE - categories.WALL,
                                  ScenarioUtils.MarkerToPosition('M3_QAI_LandBase_Marker'), 12, 'Ally')

    QAITM:AddUnitGroupDeathPercentTaunt('TAUNT7', navalStruct, .85)
    QAITM:AddUnitGroupDeathPercentTaunt('TAUNT8', landStruct, .80)
    QAITM:AddUnitsKilledTaunt('TAUNT9', ArmyBrains[QAI], (categories.MOBILE * categories.TECH3), 37)
    QAITM:AddEnemiesKilledTaunt('TAUNT10', ArmyBrains[QAI], categories.SHIELD, 2)
    QAITM:AddEnemiesKilledTaunt('TAUNT13', ArmyBrains[QAI], categories.EXPERIMENTAL, 1)
end

function SetupBrackmanM3Warnings()
    BrackmanTM:AddDamageTaunt('X05_M03_016', ScenarioInfo.BrackmanCrab, .15)          -- BrackmanCrab damaged to x
    BrackmanTM:AddDamageTaunt('X05_M03_040', ScenarioInfo.BrackmanCrab, .25)
    BrackmanTM:AddDamageTaunt('X05_M03_050', ScenarioInfo.BrackmanCrab, .50)
    BrackmanTM:AddDamageTaunt('X05_M03_060', ScenarioInfo.BrackmanCrab, .70)
    BrackmanTM:AddDamageTaunt('X05_M03_070', ScenarioInfo.BrackmanCrab, .80)
    BrackmanTM:AddDamageTaunt('X05_M03_090', ScenarioInfo.BrackmanCrab, .90)
    BrackmanTM:AddDamageTaunt('X05_M03_100', ScenarioInfo.BrackmanCrab, .94)
end

-----------------
-- Objective Reminders
-----------------

 -- M1
function M1P1Reminder1()
    if(ScenarioInfo.M1P1.Active) then
        ScenarioFramework.Dialogue(OpStrings.X05_M01_020)
        ScenarioFramework.CreateTimerTrigger(M1P1Reminder2, 1860)
    end
end

function M1P1Reminder2()
    if(ScenarioInfo.M1P1.Active) then
        ScenarioFramework.Dialogue(OpStrings.X05_M01_030)
        ScenarioFramework.CreateTimerTrigger(M1P1Reminder1, 1900)
    end
end

function M1S1Reminder1()
    if(ScenarioInfo.M1S1.Active) then
        ScenarioFramework.Dialogue(OpStrings.X05_M01_080)
        ScenarioFramework.CreateTimerTrigger(M1S1Reminder2, 1900)
    end
end

function M1S1Reminder2()
    if(ScenarioInfo.M1S1.Active) then
        ScenarioFramework.Dialogue(OpStrings.X05_M01_090)
    end
end

function M1S2Reminder1()
    if(ScenarioInfo.M1S2.Active) then
        ScenarioFramework.Dialogue(OpStrings.X05_M01_150)
        ScenarioFramework.CreateTimerTrigger(M1S2Reminder2, 1910)
    end
end

function M1S2Reminder2()
    if(ScenarioInfo.M1S2.Active) then
        ScenarioFramework.Dialogue(OpStrings.X05_M01_160)
    end
end

 -- M3
function M3P1Reminder1()
    if(ScenarioInfo.M3P1.Active) then
        ScenarioFramework.Dialogue(OpStrings.X05_M03_110)
        ScenarioFramework.CreateTimerTrigger(M3P1Reminder2, 2000)
    end
end

function M3P1Reminder2()
    if(ScenarioInfo.M3P1.Active) then
        ScenarioFramework.Dialogue(OpStrings.X05_M03_120)
        -- ScenarioFramework.CreateTimerTrigger(M3P1Reminder1, 2000)
    end
end

function M3S1Reminder1()
    if(ScenarioInfo.M3S1.Active) then
        ScenarioFramework.Dialogue(OpStrings.X05_M03_300)
        ScenarioFramework.CreateTimerTrigger(M3S1Reminder2, 2000)
    end
end

function M3S1Reminder2()
    if(ScenarioInfo.M3S1.Active) then
        ScenarioFramework.Dialogue(OpStrings.X05_M03_310)
    end
end
