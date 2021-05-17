---------------------------------------
-- Custom mission: Operation Tight Spot
--
-- Author: speed2
---------------------------------------
local Cinematics = import('/lua/cinematics.lua')
local M3LoyalistAI = import('/maps/FAF_Coop_Operation_Tight_Spot/FAF_Coop_Operation_Tight_Spot_m3loyalistai.lua')
local M3QAIAI = import('/maps/FAF_Coop_Operation_Tight_Spot/FAF_Coop_Operation_Tight_Spot_m3qaiai.lua')
local Objectives = import('/lua/SimObjectives.lua')
local OpStrings = import ('/maps/FAF_Coop_Operation_Tight_Spot/FAF_Coop_Operation_Tight_Spot_strings.lua')
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')

----------
-- Globals
----------
ScenarioInfo.Player1 = 1
ScenarioInfo.Loyalist = 2
ScenarioInfo.QAI = 3
ScenarioInfo.Civilian = 4
ScenarioInfo.Player2 = 5

---------
-- Locals
---------
local Player1 = ScenarioInfo.Player1
local Player2 = ScenarioInfo.Player2
local Loyalist = ScenarioInfo.Loyalist
local QAI = ScenarioInfo.QAI
local Civilian = ScenarioInfo.Civilian

local Difficulty = ScenarioInfo.Options.Difficulty
local AssignedObjectives = {}

local LeaderFaction
local LocalFaction
local Player2Faction

-------------
-- Debug Only
-------------
local SkipM1 = true
local SkipM2 = true
local SkipNIS3 = true

-----------
-- Start up
-----------
function OnPopulate(scenario)
    ScenarioUtils.InitializeScenarioArmies()
    LeaderFaction, LocalFaction = ScenarioFramework.GetLeaderAndLocalFactions()

    if not SkipM1 then
        ---------
        -- Player
        ---------
        -- Base, damage the buildings a bit
        local base = ScenarioUtils.CreateArmyGroup('Player1', 'M1_Player_Base')
        DamageGroup(base)

        local airFactories = {ScenarioInfo.UnitNames[Player1]['T1_Air_Factory_1'], ScenarioInfo.UnitNames[Player1]['T1_Air_Factory_2'], ScenarioInfo.UnitNames[Player1]['T2_Air_Factory']}
        local landFactories = {ScenarioInfo.UnitNames[Player1]['T1_Land_Factory'], ScenarioInfo.UnitNames[Player1]['T2_Land_Factory'], ScenarioInfo.UnitNames[Player1]['T3_Land_Factory']}

        -- Rally points
        IssueClearFactoryCommands(airFactories)
        IssueFactoryRallyPoint(airFactories, ScenarioUtils.MarkerToPosition('M1_Player_Air_Rally'))
        IssueClearFactoryCommands(landFactories)
        IssueFactoryRallyPoint(landFactories, ScenarioUtils.MarkerToPosition('M1_Player_Land_Rally'))

        -- Refresh restrictions in the support factory
        ScenarioFramework.RefreshRestrictions('Player1')

        -- Build some things out of the factoriees, leave the T2 air factory ready for the transport
        IssueBuildFactory({ScenarioInfo.UnitNames[Player1]['T1_Air_Factory_1'], ScenarioInfo.UnitNames[Player1]['T1_Air_Factory_2']}, 'uaa0102', 5) -- T1 Interceptors
        IssueBuildFactory({ScenarioInfo.UnitNames[Player1]['T1_Land_Factory']}, 'ual0201', 5) -- T1 Aurora Tank
        IssueBuildFactory({ScenarioInfo.UnitNames[Player1]['T2_Land_Factory']}, 'ual0202', 5) -- T2 Obsidian Tank
        IssueBuildFactory({ScenarioInfo.UnitNames[Player1]['T3_Land_Factory']}, 'ual0303', 5) -- T3 Harbinger Bot

        -- Make engineers assist their factories
        local assistTbl = {
            ['T1_Engineer_1'] = 'T1_Air_Factory_1',
            ['T1_Engineer_2'] = 'T1_Air_Factory_2',
            ['T1_Engineer_3'] = 'T1_Land_Factory',
            ['T1_Engineer_4'] = 'T2_Land_Factory',
            ['T2_Engineer_1'] = 'T2_Air_Factory',
            ['T2_Engineer_2'] = 'T3_Land_Factory',
        }
        for engie, factory in assistTbl do
            IssueGuard({ScenarioInfo.UnitNames[Player1][engie]}, ScenarioInfo.UnitNames[Player1][factory])
        end

        -- Build few defences with other engineers
        local unitData = ScenarioUtils.FindUnit('T2_PD', Scenario.Armies['Loyalist'].Units)
        IssueBuildMobile({ScenarioInfo.UnitNames[Player1]['T2_Engineer_3']}, unitData.Position, unitData.type, {})
        unitData = ScenarioUtils.FindUnit('T2_PD_2', Scenario.Armies['Loyalist'].Units)
        IssueBuildMobile({ScenarioInfo.UnitNames[Player1]['T2_Engineer_4']}, unitData.Position, unitData.type, {})

        -- Spawn ACU 1 second later, else the camera wants to zoom on it right away
        ScenarioInfo.PlayersACUs = {}
        ForkThread(
            function()
                WaitSeconds(1)
                ScenarioInfo.Player1CDR = ScenarioFramework.SpawnCommander('Player1', 'Aeon_ACU', false, true, true, PlayerDeath,
                    {'HeatSink'})
                table.insert(ScenarioInfo.PlayersACUs, ScenarioInfo.Player1CDR)
                DamageGroup({ScenarioInfo.Player1CDR})
                IssueMove({ScenarioInfo.Player1CDR}, ScenarioUtils.MarkerToPosition('M1_ACU_Destination'))
            end
        )
        
        -- Walls
        ScenarioUtils.CreateArmyGroup('Player1', 'M1_Walls')

        -- Patrols
        -- Mobile AA
        local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Player1', 'M1_AA_Patrol', 'AttackFormation')
        ScenarioFramework.PlatoonPatrolChain(platoon, 'M1_Player_AA_Chain')

        -- Land units
        ScenarioUtils.CreateArmyGroup('Player1', 'M1_Land_Units')

        -- Air patrol
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Player1', 'M1_Air_Patrol', 'NoFormation')
        for _, v in platoon:GetPlatoonUnits() do
            ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M1_Player_Air_Patrol_Chain')))
        end

        ------
        -- QAI
        ------
        -- Offmap eco + radar
        ScenarioUtils.CreateArmyGroup('QAI', 'M1_Economy')

        -- Initial units, those in playable area
        ScenarioUtils.CreateArmyGroup('QAI', 'M1_QAI_Land_Units')

        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'M1_QAI_Land_Attack_1', 'GrowthFormation')
        platoon:AggressiveMoveToLocation(ScenarioUtils.MarkerToPosition('M1_QAI_Land_Attack_2'))

        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'M1_QAI_Land_Attack_2', 'GrowthFormation')
        platoon:AggressiveMoveToLocation(ScenarioUtils.MarkerToPosition('M1_QAI_Land_Attack_2'))

        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'M1_QAI_Land_Attack_3', 'GrowthFormation')
        platoon:AggressiveMoveToLocation(ScenarioUtils.MarkerToPosition('M1_QAI_Land_Attack_2'))

        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'M1_QAI_Land_Attack_4', 'GrowthFormation')
        ScenarioFramework.PlatoonPatrolChain(platoon, 'M1_QAI_Land_Attack_Chain_3')

        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'M1_QAI_Land_Attack_5', 'GrowthFormation')
        ScenarioFramework.PlatoonPatrolChain(platoon, 'M1_QAI_Land_Attack_Chain_1')

        -- Air
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'M1_QAI_Air_Attack_North_1', 'GrowthFormation')
        platoon:AggressiveMoveToLocation(ScenarioUtils.MarkerToPosition('M1_QAI_Land_Attack_2'))

        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'M1_QAI_Air_Attack_South_1', 'GrowthFormation')
        platoon:AggressiveMoveToLocation(ScenarioUtils.MarkerToPosition('M1_QAI_Land_Attack_2'))

        -- Rest of the attack will spawn later offmap and move in
        ForkThread(M1QAIAttackThread)

        -- Wreckages
        ScenarioUtils.CreateArmyGroup('Loyalist', 'M1_Wreckages', true)
    end
end

function OnStart(scenario)
    -- Unit and upgade restrictions
    -- Since it's an escape mission we don't want to summon more pilots to the planet.
    -- Unlock the gate later if player decided to build one
    ScenarioFramework.AddRestrictionForAllHumans(
        categories.GATE +         -- Quantum Gate
        categories.SUBCOMMANDER   -- sACU
    ) 

    -- Restrict teleport
    ScenarioFramework.RestrictEnhancements({
        'Teleporter',
    })

    -- Colors
    ScenarioFramework.SetAeonPlayerColor(Player1)
    ScenarioFramework.SetAeonAlly1Color(Loyalist)
    ScenarioFramework.SetCybranEvilColor(QAI)
    ScenarioFramework.SetCybranEvilColor(Civilian)
    -- Player2's color will depend on picked faction
    local tblArmy = ListArmies()
    if tblArmy[ScenarioInfo.Player2] then
        Player2Faction = import('/lua/factions.lua').Factions[ArmyBrains[Player2]:GetFactionIndex()].Key
        if Player2Faction == 'cybran' then
            ScenarioFramework.SetCybranPlayerColor(Player2)
        elseif Player2Faction == 'uef' then
            ScenarioFramework.SetUEFPlayerColor(Player2)
        elseif Player2Faction == 'aeon' then
            ScenarioFramework.SetAeonAlly2Color(Player2)
        end
    end

    -- Set the maximum number of units that the players is allowed to have
    ScenarioFramework.SetSharedUnitCap(1000)

    -- Set playable area
    ScenarioFramework.SetPlayableArea('M1_Area', false)

    if not SkipM1 then
        ScenarioFramework.StartOperationJessZoom('M1_Camera_Area', IntroMission1)
    else
        ScenarioFramework.SetPlayableArea('M2_Area', false)
        ScenarioInfo.PlayersACUs = {}
        ForkThread(function()
            WaitSeconds(1)
            ScenarioInfo.Player1CDR = ScenarioFramework.SpawnCommander('Player1', 'Aeon_ACU', false, true, true, PlayerDeath,
                {'HeatSink'})
            table.insert(ScenarioInfo.PlayersACUs, ScenarioInfo.Player1CDR)
            Warp(ScenarioInfo.Player1CDR, ScenarioUtils.MarkerToPosition('M2_Player_Destination'))
        end)
        ScenarioFramework.StartOperationJessZoom('M2_Crash_Area', IntroMission2)
    end
end

function M1QAIAttackThread()
    WaitSeconds(12)

    local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'M1_QAI_Air_Attack_North_2', 'GrowthFormation')
    platoon:AggressiveMoveToLocation(ScenarioUtils.MarkerToPosition('M1_QAI_Land_Attack_2'))

    WaitSeconds(10)

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'M1_QAI_Land_Attack_6', 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M1_QAI_Land_Attack_Chain_2')

    WaitSeconds(12)

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'M1_QAI_Air_Attack_South_2', 'GrowthFormation')
    platoon:AggressiveMoveToLocation(ScenarioUtils.MarkerToPosition('M1_QAI_Land_Attack_2'))

    WaitSeconds(15)

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'M1_QAI_Air_Attack_North_3', 'GrowthFormation')
    platoon:AggressiveMoveToLocation(ScenarioUtils.MarkerToPosition('M1_QAI_Land_Attack_2'))

    WaitSeconds(10)
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'M1_QAI_Air_Attack_South_3', 'GrowthFormation')
    platoon:AggressiveMoveToLocation(ScenarioUtils.MarkerToPosition('M1_QAI_Land_Attack_2'))

    WaitSeconds(10)
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'M1_QAI_Air_Attack_North_4', 'GrowthFormation')
    platoon:AggressiveMoveToLocation(ScenarioUtils.MarkerToPosition('M1_QAI_Land_Attack_2'))

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'M1_QAI_Air_Attack_South_4', 'GrowthFormation')
    platoon:AggressiveMoveToLocation(ScenarioUtils.MarkerToPosition('M1_QAI_Land_Attack_2'))
end

-----------
-- End Game
-----------
function PlayerDeath(commander)
    ScenarioFramework.PlayerDeath(commander, OpStrings.PlayerDies)
end

function LeaveCinematics()
    -- Make sure the gate doesn't die anymore
    ScenarioInfo.PlayersGate:SetCanBeKilled(false)
    ScenarioInfo.PlayersGate:SetCanTakeDamage(false)

    for _, ACU in ScenarioInfo.PlayersACUs do
        ForkThread(
            function(ACU)
                -- Set ACU invincible
                ACU:SetCanBeKilled(false)
                ACU:SetCanTakeDamage(false)

                -- Move it into the gate
                IssueStop({ACU})
                IssueClearCommands({ACU})
                local cmd = IssueMove({ACU}, ScenarioInfo.PlayersGate:GetPosition())

                while not IsCommandDone(cmd) do
                    WaitSeconds(.1)
                end

                -- Gete out efect
                ScenarioFramework.FakeTeleportUnit(ACU, true)

                if not ScenarioInfo.OpComplete then
                    PlayerWin()
                end
            end, ACU
        )
    end

    Cinematics.EnterNISMode()
    WaitSeconds(1)

    -- Track the ACU until it leaves
    Cinematics.CameraThirdPerson(ScenarioInfo.Player1CDR, 0.2, 12)
end

function PlayerWin()
    ScenarioInfo.OpComplete = true
    ForkThread(KillGame)
end

function KillGame()
    UnlockInput()
    local secondary = Objectives.IsComplete(ScenarioInfo.M2S1) and
                      Objectives.IsComplete(ScenarioInfo.M3S1)
    local bonus = --Objectives.IsComplete(ScenarioInfo.M1B1) and
                  Objectives.IsComplete(ScenarioInfo.M1B2) and
                  Objectives.IsComplete(ScenarioInfo.M1B3) and
                  Objectives.IsComplete(ScenarioInfo.M2B1) and
                  Objectives.IsComplete(ScenarioInfo.M2B2)
    ScenarioFramework.EndOperation(ScenarioInfo.OpComplete, ScenarioInfo.OpComplete, secondary, bonus)
end

------------
-- Mission 1
------------
function IntroMission1()
    ScenarioInfo.MissionNumber = 1

    ScenarioFramework.Dialogue(OpStrings.M1Intro, StartMission1, true)
end

function StartMission1()
    --------------------------------------------
    -- Primary Objective - Survive QAI's assault
    --------------------------------------------
    ScenarioInfo.M1P1 = Objectives.Basic(
        'primary',
        'incomplete',
        OpStrings.M1P1Title,
        OpStrings.M1P1Description,
        Objectives.GetActionIcon('kill'),
        {
        }
    )

    -------------------------------------------------
    -- Bonus Objective - Kill QAI's Mobile Arilleries
    -------------------------------------------------
    --[[
    local units = ArmyBrains[QAI]:GetListOfUnits(categories.url0304, false)
    ScenarioInfo.M1B1 = Objectives.Kill(
        'bonus',
        'incomplete',
        OpStrings.M1B1Title,
        OpStrings.M1B1Description,
        {
            Units = units,
            MarkUnits = false,
            Hidden = true,
        }
    )
    --]]

    --------------------------------
    -- Bonus Objective - Upgrade ACU
    --------------------------------
    ScenarioInfo.M1B2 = Objectives.Basic(
        'bonus',
        'incomplete',
        OpStrings.M1B2Title,
        OpStrings.M1B2Description,
        "/game/orders/enhancement_btn_up.dds",
        {
            Hidden = true,
        }
    )

    -- Annnounce the mission name after few seconds
    ScenarioFramework.CreateTimerTrigger(MissionNameAnnouncement, 4)

    -- Spiderbot warning followed by obj to build T2 transport
    ScenarioFramework.CreateTimerTrigger(M1SpiderBotWarning, 10)
end

function MissionNameAnnouncement()
    ScenarioFramework.SimAnnouncement(OpStrings.OPERATION_NAME, 'mission by [e]speed2')
end

function M1SpiderBotWarning()
    ScenarioFramework.Dialogue(OpStrings.M1SpiderBotWarning, M1TransportObjective, true)
end

function M1TransportObjective()
    -----------------------------------------
    -- Primary Objective - Build T2 Transport
    -----------------------------------------
    ScenarioInfo.M1P2 = Objectives.ArmyStatCompare(
        'primary',
        'incomplete',
        OpStrings.M1P2Title,
        OpStrings.M1P2Description,
        'build',
        {
            Armies = {'HumanPlayers'},
            StatName = 'Units_Active',
            CompareOp = '>=',
            Value = 1,
            Category = categories.uaa0104,
            ShowProgress = true,
        }
    )
    ScenarioInfo.M1P2:AddResultCallback(
        function(result)
            if result then
                for _, unit in ArmyBrains[Player1]:GetListOfUnits(categories.uaa0104, false) do
                    if unit then
                        ScenarioInfo.PlayerTransport = unit
                    end
                end
            end
        end
    )

    -----------------------------------------------------------
    -- Bonus Objective - Finish the transport before MLs arrive
    -----------------------------------------------------------
    ScenarioInfo.M1B3 = Objectives.Basic(
        'bonus',
        'incomplete',
        OpStrings.M1B3Title,
        OpStrings.M1B3Description,
        Objectives.GetActionIcon('timer'),
        {
            Hidden = true,
        }
    )

    -- Inform player to stay in the base
    ForkThread(M1ACUInBaseCheck)

    ScenarioFramework.CreateTimerTrigger(M1SpiderBotAttack, 12)
end

function M1ACUInBaseCheck()
    while ScenarioInfo.M1P2.Active and not ScenarioInfo.CZAR.Dead do
        if not ScenarioFramework.UnitsInAreaCheck(categories.COMMAND, 'M1_ACU_Area') then
            if Random(1, 2) == 1 then
                ScenarioFramework.Dialogue(OpStrings.M1ACUInBaseReminder1, nil, true)
            else
                ScenarioFramework.Dialogue(OpStrings.M1ACUInBaseReminder2, nil, true)
            end
        end
        WaitSeconds(12)
    end
end

function M1SpiderBotAttack()
    -- Spawn and move in MLs, not using a chain since they tend to regroup at each marker
    ScenarioInfo.M1SpiderBotPlatoon = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'M1_Spiders', 'AttackFormation')
    ScenarioInfo.M1SpiderBotPlatoon:AggressiveMoveToLocation(ScenarioUtils.MarkerToPosition('M1_QAI_Land_Attack_2'))

    -- Mobile AA for each ML and trigger for dialogue once they are in playable area
    for _, v in ScenarioInfo.M1SpiderBotPlatoon:GetPlatoonUnits() do
        local units = ScenarioUtils.CreateArmyGroup('QAI', 'M1_Spiders_Support')
        IssueGuard(units, v)

        ScenarioFramework.CreateUnitToMarkerDistanceTrigger(M1SpiderBotsSpotted, v, 'M1_QAI_Land_Attack_3', 10)
    end
end

function M1SpiderBotsSpotted()
    if ScenarioInfo.M1SpiderBotsSpotted then  
        return
    end
    ScenarioInfo.M1SpiderBotsSpotted = true

    -- Set up vision on the MLs
    for _, unit in ScenarioInfo.M1SpiderBotPlatoon:GetPlatoonUnits() do
        local vizmarker = ScenarioFramework.CreateVisibleAreaAtUnit(20, unit, 0, ArmyBrains[Player1])
        unit.Trash:Add( vizmarker )
        vizmarker:AttachBoneTo(-1, unit, -1)
    end

    if ScenarioInfo.M1P2.Active then
        -- Transport not ready yet
        ScenarioInfo.M1B3:ManualResult(false)
        ScenarioFramework.Dialogue(OpStrings.M1SpiderBotsSpotted2, nil, true)
    else
        -- Player has the transport
        ScenarioInfo.M1B3:ManualResult(true)
        ScenarioFramework.Dialogue(OpStrings.M1SpiderBotsSpotted1, nil, true)
    end

    -- Send in reinforcements
    ScenarioFramework.CreateTimerTrigger(M1LoyalistReinforcements, 18)
end

function M1LoyalistReinforcements()
    ScenarioFramework.Dialogue(OpStrings.M1ReeinforcementsArrived, nil, true)

    -- CZAR, if it dies (player took too long to build the transport, kill the player with T3 air)
    ScenarioInfo.CZAR = ScenarioUtils.CreateArmyUnit('Loyalist', 'CZAR')
    ScenarioFramework.CreateUnitDestroyedTrigger(M1SnipePlayer, ScenarioInfo.CZAR)
    IssueMove({ScenarioInfo.CZAR}, ScenarioUtils.MarkerToPosition('CZAR_Marker_1'))
    IssueAggressiveMove({ScenarioInfo.CZAR}, ScenarioUtils.MarkerToPosition('CZAR_Marker_2'))

    -- ASFs
    ScenarioInfo.ASFPlatoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Loyalist', 'M1_ASFs', 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.ASFPlatoon, 'M1_Player_Air_Patrol_Chain')

    -- Gunships
    ScenarioInfo.GunshipPlatoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Loyalist', 'M1_Gunships', 'AttackFormation')
    ScenarioInfo.GunshipPlatoon:AggressiveMoveToLocation(ScenarioUtils.MarkerToPosition('CZAR_Marker_2'))

    ScenarioFramework.CreateUnitToMarkerDistanceTrigger(M1PlayerEvac, ScenarioInfo.CZAR, 'CZAR_Marker_2', 40)
end

function M1SnipePlayer()
    if ScenarioInfo.MissionNumber ~= 1 then
        return
    end

    ScenarioFramework.Dialogue(OpStrings.M1ReinforcementsDestroyed, nil, true)

    local platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('QAI', 'M1_ASFs', 'NoFormation', 5)
    for _, v in platoon:GetPlatoonUnits() do
        v:SetCanTakeDamage(false)
        v:SetCanBeKilled(false)
    end
    platoon:AggressiveMoveToLocation(ScenarioUtils.MarkerToPosition('M1_QAI_Land_Attack_2'))
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M1_QAI_Death_Chain')

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('QAI', 'M1_StratBombers', 'NoFormation', 5)
    for _, v in platoon:GetPlatoonUnits() do
        v:SetCanTakeDamage(false)
        v:SetCanBeKilled(false)
    end
    platoon:AggressiveMoveToLocation(ScenarioUtils.MarkerToPosition('M1_QAI_Land_Attack_2'))
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M1_QAI_Death_Chain')
end

function M1PlayerEvac()
    while not ScenarioInfo.PlayerTransport do
        WaitSeconds(1)
    end

    if ScenarioInfo.CZAR.Dead then
        return
    end

    -- Make sure the transport and CZAR won't die anymore
    ScenarioInfo.PlayerTransport:SetCanTakeDamage(false)
    ScenarioInfo.PlayerTransport:SetCanBeKilled(false)
    ScenarioInfo.PlayerTransport:SetDoNotTarget(true)

    ScenarioInfo.CZAR:SetCanTakeDamage(false)
    ScenarioInfo.CZAR:SetCanBeKilled(false)

    -- Mark survive objective as completed
    ScenarioInfo.M1P1:ManualResult(true)

    IntroMission2()
end

------------
-- Mission 2
------------
function IntroMission2()
    ScenarioFramework.FlushDialogueQueue()
    while ScenarioInfo.DialogueLock do
        WaitSeconds(0.2)
    end
    ScenarioInfo.MissionNumber = 2

    ---------
    -- QAI AI
    ---------
    -- Small outpost around the crash site
    ScenarioUtils.CreateArmyGroup('QAI', 'M2_NIS_Base_D' .. Difficulty)

    for i = 1, 2 do
        local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'M2_NIS_Bots_' .. i ..'_D' .. Difficulty, 'GrowthFormation')
        ScenarioFramework.PlatoonPatrolChain(platoon, 'M2_QAI_Initial_Patrol_Chain_' .. i)
    end

    -- Wreckages
    ScenarioUtils.CreateArmyGroup('Loyalist', 'M2_Wreckages', true)

    -- Give initial resources to the Player1 as his storage might be empty if stalling during the first part
    ArmyBrains[Player1]:GiveResource('MASS', 650)
    ArmyBrains[Player1]:GiveResource('ENERGY', 4000)

    if not SkipM1 then
        ForkThread(IntroMission2NIS)
    elseif not SkipM2 then
        StartMission2()
    else
        ScenarioInfo.M3PlayersPlan = 'build'
        IntroMission3()
    end
end

function IntroMission2NIS()
    -- Playable area for NIS
    ScenarioFramework.SetPlayableArea('M2_NIS_Area', false)

    Cinematics.EnterNISMode()
    WaitSeconds(1)
    Cinematics.CameraMoveToMarker('Cam_M2_Intro_1', 1)

    -- Get the ACU into the transport and on the move
    local attached = true
    if not ScenarioInfo.Player1CDR:IsUnitState('Attached') then
        attached = false
        IssueStop({ScenarioInfo.PlayerTransport, ScenarioInfo.Player1CDR})
        IssueClearCommands({ScenarioInfo.PlayerTransport, ScenarioInfo.Player1CDR})

        IssueTransportLoad({ScenarioInfo.Player1CDR}, ScenarioInfo.PlayerTransport)   
    end
    IssueMove({ScenarioInfo.PlayerTransport}, ScenarioUtils.MarkerToPosition('M1_Player_Escape'))

    WaitSeconds(2)

    if attached then
        Cinematics.CameraTrackEntity(ScenarioInfo.PlayerTransport, 40, 3)
    else
        ScenarioFramework.Dialogue(OpStrings.M2Intro1, nil, true)
        -- "Lets get you out"
        Cinematics.CameraTrackEntity(ScenarioInfo.Player1CDR, 40, 3)
    end

    -- "Gate is to the west"
    ScenarioFramework.Dialogue(OpStrings.M2Intro2, nil, true)

    ScenarioFramework.CreateUnitToMarkerDistanceTrigger(IntroMission2NISPart2, ScenarioInfo.PlayerTransport, 'M1_Player_Escape', 5)
end

function IntroMission2NISPart2()
    -- Dep Player's ACU
    IssueStop({ScenarioInfo.PlayerTransport})
    IssueClearCommands({ScenarioInfo.PlayerTransport})
    IssueTransportUnload({ScenarioInfo.PlayerTransport}, ScenarioUtils.MarkerToPosition('M2_Player_Drop_Marker'))

    WaitSeconds(2)

    Cinematics.CameraMoveToMarker('Cam_M2_Intro_2', 2)

    -- Some Loyalist air units for a effect
    local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Loyalist', 'M2_NIS_Units', 'GrowthFormation')
    DamageGroup(platoon:GetPlatoonUnits())
    platoon:MoveToLocation(ScenarioUtils.MarkerToPosition('M2_Loyalist_Initial_Patrol_0'), false)
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M2_Loyalist_Initial_Patrol_Chain')

    WaitSeconds(3)

    -- Attack the transport
    local units = ScenarioUtils.CreateArmyGroup('QAI', 'M2_NIS_ASFs_1')
    IssueAttack(units, ScenarioInfo.PlayerTransport)

    -- "Fighters inc!"
    ScenarioFramework.Dialogue(OpStrings.M2Intro3, nil, true)

    --[[
    -- Objective to kill mobile arty failed
    if ScenarioInfo.M1B1.Active then
        ScenarioInfo.M1B1:ManualResult(false)
    end
    --]]

    -- Cleanup the units
    for _, unit in GetUnitsInRect(ScenarioUtils.AreaToRect('M1_Area')) do
        if unit ~= ScenarioInfo.CZAR then
            unit:Destroy()
        end
    end

    Cinematics.CameraMoveToMarker('Cam_M2_Intro_3', 3)

    while ScenarioInfo.Player1CDR:IsUnitState('Attached') do
        WaitSeconds(.2)
    end

    -- Kill the transport as soon as it drops the ACU
    ScenarioInfo.PlayerTransport:SetCanTakeDamage(true)
    ScenarioInfo.PlayerTransport:SetCanBeKilled(true)
    ScenarioInfo.PlayerTransport:SetDoNotTarget(false)
    ScenarioInfo.PlayerTransport:Kill()

    -- "That was close"
    ScenarioFramework.Dialogue(OpStrings.M2Intro4, nil, true)

    -- CZAR death function, crashes it at the right location
    local function KillCZAR()
        ScenarioInfo.CZAR:SetCanBeKilled(true)
        ScenarioInfo.CZAR:Kill()
        WaitSeconds(3)
        ScenarioInfo.CZAR:Destroy()
    end
    ScenarioFramework.CreateUnitToMarkerDistanceTrigger(KillCZAR, ScenarioInfo.CZAR, 'CZAR_Destination', 30)

    -- Warp CZAR closer to the crash site, damage it for a better effect
    Warp(ScenarioInfo.CZAR, ScenarioUtils.MarkerToPosition('CZAR_Warp_Marker'))
    ScenarioInfo.CZAR:SetCanTakeDamage(true)
    ScenarioInfo.CZAR:SetHealth(ScenarioInfo.CZAR, 10000)
    IssueStop({ScenarioInfo.CZAR})
    IssueClearCommands({ScenarioInfo.CZAR})
    IssueMove({ScenarioInfo.CZAR}, ScenarioUtils.MarkerToPosition('CZAR_Destination'))

    -- Move the
    IssueMove({ScenarioInfo.Player1CDR}, ScenarioUtils.MarkerToPosition('M2_Player_Destination'))

    Cinematics.CameraMoveToMarker('Cam_M2_Intro_4', 4)

    -- Attack the CZAR
    units = ScenarioUtils.CreateArmyGroup('QAI', 'M2_NIS_ASFs_2')
    IssueAttack(units, ScenarioInfo.CZAR)
    ScenarioFramework.GroupPatrolChain(units, 'M2_Loyalist_Initial_Patrol_Chain')

    -- "QAI's air everywhere"
    ScenarioFramework.Dialogue(OpStrings.M2Intro5, nil, true)

    WaitSeconds(2)
    Cinematics.CameraMoveToMarker('Cam_M2_Intro_5', 5)

    WaitSeconds(7)

    Cinematics.ExitNISMode()

    -- Playable area
    ScenarioFramework.SetPlayableArea('M2_Area', false)

    StartMission2()
end

function StartMission2()
    -- Finish the objective to upgrade the ACU
    local hasUpgrade = ScenarioInfo.Player1CDR:HasEnhancement('CrysalisBeam') or ScenarioInfo.Player1CDR:HasEnhancement('Shield') or ScenarioInfo.Player1CDR:HasEnhancement('AdvancedEngineering')
    if hasUpgrade then
        ScenarioInfo.M1B2:ManualResult(true)
    else
        ScenarioInfo.M1B2:ManualResult(false)
    end

    --------------------------------------------
    -- Primary Objective - Secure the crash site
    --------------------------------------------
    ScenarioInfo.M2P1 = Objectives.CategoriesInArea(
        'primary',
        'incomplete',
        OpStrings.M2P1Title,
        OpStrings.M2P1Description,
        'killorcapture',
        {
            Requirements = {
                {
                    Area = 'M2_Crash_Area',
                    Category = categories.ALLUNITS - categories.WALL,
                    CompareOp = '<=',
                    Value = 0,
                    ArmyIndex = QAI,
                },
            },
        }
    )
    ScenarioInfo.M2P1:AddResultCallback(
        function(result)
            if result then
                M2ChoiceDialogue()
            end
        end
    )

    ----------------------------------
    -- Bonus Objective - Extra Support
    ----------------------------------
    local resultStr = 'failed'
    local targetCategory = categories.ual0208 + -- T2 Engineer
                           categories.ual0309 + -- T3 Engineer
                           categories.ual0303   -- T3 Harbinger
    local targetUnit = ArmyBrains[Player1]:GetListOfUnits(targetCategory, false)[1]
    if targetUnit then
        resultStr = 'complete'
    end
    ScenarioInfo.M2B1 = Objectives.Basic(
        'bonus',
        resultStr,
        OpStrings.M2B1Title,
        OpStrings.M2B1Description,
        Objectives.GetActionIcon('move'),
        {
            Hidden = true,
        }
    )

    ------------------------------------------
    -- Bonus Objective - Capture Engie Station
    ------------------------------------------
    ScenarioInfo.M2B2 = Objectives.Capture(
        'bonus',
        'incomplete',
        OpStrings.M2B2Title,
        OpStrings.M2B2Description,
        {
            Units = {ScenarioInfo.UnitNames[QAI]['M2_QAI_Engie_Station']},
            MarkUnits = false,
            Hidden = true,
        }
    )
    ScenarioInfo.M2B2:AddResultCallback(
        function(result)
            if result then
                ScenarioFramework.Dialogue(OpStrings.M2EngieStationCaptured)
            end
        end
    )

    -----------
    -- Triggers
    -----------
    ScenarioFramework.CreateTimerTrigger(M2SpawnPlayer2, 12)

    ScenarioFramework.CreateTimerTrigger(M2LoyalistSpiderCounter, 50)

    ScenarioFramework.CreateTimerTrigger(M2ReclaimCZARObjective, 120)

    ScenarioFramework.CreateTimerTrigger(M2ChoiceDialogue, 200)
end

function M2SpawnPlayer2()
    if ArmyBrains[Player2] then
        local function SpawnPlayer2()
            if Player2Faction == 'aeon' then
                ScenarioInfo.Player2CDR = ScenarioFramework.SpawnCommander('Player2', 'Aeon_ACU', 'Warp', true, true, PlayerDeath)
            elseif Player2Faction == 'cybran' then
                ScenarioInfo.Player2CDR = ScenarioFramework.SpawnCommander('Player2', 'Cybran_ACU', 'Warp', true, true, PlayerDeath)
            elseif Player2Faction == 'uef' then
                ScenarioInfo.Player2CDR = ScenarioFramework.SpawnCommander('Player2', 'UEF_ACU', 'Warp', true, true, PlayerDeath)
            end
            table.insert(ScenarioInfo.PlayersACUs, ScenarioInfo.Player2CDR)
        end

        -- Play the dialogue first
        ScenarioFramework.Dialogue(OpStrings.M2Player2GateIn, SpawnPlayer2, true)
    end
end

function M2LoyalistSpiderCounter()
    ScenarioFramework.Dialogue(OpStrings.M2LoyalistSpiderCounter)

    local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Loyalist', 'M2_SpiderCounter', 'AttackFormation')
    ScenarioFramework.PlatoonMoveChain(platoon, 'M2_Loyalist_SpiderCounter_Chain')
    platoon:Destroy()
end

function M2ReclaimCZARObjective()
    ScenarioFramework.Dialogue(OpStrings.M2ReclaimCZAR)
    
    -- Find CZAR wreck, lower it's mass value
    for _, prop in GetReclaimablesInRect(ScenarioUtils.AreaToRect('M2_Crash_Area')) do
        if prop.IsWreckage and prop.AssociatedBP == 'uaa0310' then
            ScenarioInfo.CZARWreck = prop
            ScenarioInfo.CZARWreck:SetCanTakeDamage(false)
            --ScenarioInfo.CZARWreck:SetMaxReclaimValues( 1, 20000 - 2000*Difficulty, 0)
            break
        end
    end

    -------------------------------------------
    -- Secondary Objective - Reclaim CZAR Wreck
    -------------------------------------------
    ScenarioInfo.M2S1 = Objectives.ReclaimProp(
        'secondary',
        'incomplete',
        OpStrings.M2S1Title,
        OpStrings.M2S1Description,
        {
            Wrecks = {ScenarioInfo.CZARWreck},
        }
    )
end

function M2ChoiceDialogue()
    if not ScenarioInfo.M2PlanPicked then
        ScenarioInfo.M2PlanPicked = true
        ScenarioFramework.Dialogue(OpStrings.M2PlayersChoice, M2ScenarioChoice, true)
    end
end

function M2ScenarioChoice()
    local dialogue = CreateDialogue(OpStrings.M2ChoiceTitle, {OpStrings.M2ChoiceBuildGate, OpStrings.M2ChoiceMakeRun})
    dialogue.OnButtonPressed = function(self, info)
        dialogue:Destroy()
        if info.buttonID == 1 then
            -- Build the gate
            ScenarioInfo.M3PlayersPlan = 'build'
            ScenarioFramework.Dialogue(OpStrings.M2BuildGate, IntroMission3, true)
        else
            -- Use Charis' gate
            --ScenarioInfo.M3PlayersPlan = 'push'
            --ScenarioFramework.Dialogue(OpStrings.M2UseCharisGate, IntroMission3, true)
            ScenarioInfo.M3PlayersPlan = 'build'
            ScenarioFramework.Dialogue(OpStrings.M2BuildGate, IntroMission3, true)
        end
    end

    WaitSeconds(10)

    -- Remind player to pick the plan
    if not ScenarioInfo.M3PlayersPlan then
        ScenarioFramework.Dialogue(OpStrings.M2ChoiceReminder, nil, true)
    else
        return
    end

    WaitSeconds(10)

    -- If player takes too long, continue with the mission
    if not ScenarioInfo.M3PlayersPlan then
        dialogue:Destroy()
        ScenarioInfo.M3PlayersPlan = 'build'
        ScenarioFramework.Dialogue(OpStrings.M2ForceChoice, IntroMission3, true)
    end
end

------------
-- Mission 3
------------
function IntroMission3()
    ScenarioFramework.FlushDialogueQueue()
    while ScenarioInfo.DialogueLock do
        WaitSeconds(0.2)
    end
    ScenarioInfo.MissionNumber = 3

    -- Common
    ---------
    -- QAI AI
    ---------
    M3QAIAI.QAIM3NorthBaseAI()

    if ScenarioInfo.M3PlayersPlan == 'build' then
        -- Allow building Quantum gate
        ScenarioFramework.RemoveRestrictionForAllHumans(categories.GATE)

        ---------
        -- QAI AI
        ---------
        M3QAIAI.QAIM3NorthEastBaseAI()
        M3QAIAI.QAIM3SouthEastBaseAI()
        M3QAIAI.QAIM3SouthWestBaseAI()

        -- Give initial resources to the AI
        ArmyBrains[QAI]:GiveResource('MASS', 3000)
        ArmyBrains[QAI]:GiveResource('ENERGY', 25000)

        -- ScenarioUtils.CreateArmyGroup('QAI', 'Offmap_Arty')

        -- Patrols
        local platoon
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'M3_South_East_Air_Patrol_D' .. Difficulty, 'NoFormation')
        ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_QAI_SE_Air_Patrol_Chain')

        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'M3_South_East_Land_Patrol_D' .. Difficulty, 'NoFormation')
        for _, v in platoon:GetPlatoonUnits() do
            ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M3_QAI_SE_Land_Patrol_Chain')))
        end

        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'M3_North_East_Air_Patrol_D' .. Difficulty, 'NoFormation')
        ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_QAI_NE_Air_Patrol_Chain')

        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'M3_North_East_Land_Patrol_D' .. Difficulty, 'NoFormation')
        for _, v in platoon:GetPlatoonUnits() do
            ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M3_QAI_NE_Land_Patrol_Chain')))
        end

        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'M3_South_West_Air_Patrol_D' .. Difficulty, 'NoFormation')
        ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_QAI_SW_Air_Patrol_Chain')

        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'M3_South_West_Land_Patrol_D' .. Difficulty, 'NoFormation')
        for _, v in platoon:GetPlatoonUnits() do
            ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M3_QAI_SW_Land_Patrol_Chain')))
        end

        ------------
        -- Objective
        ------------
        -- Randomly picked location
        if Random(1, 2) == 1 then
            ScenarioInfo.M3ScienceBuildings = ScenarioUtils.CreateArmyGroup('Civilian', 'South_Science')
            ScenarioUtils.CreateArmyGroup('Civilian', 'South_Walls')
        else
            ScenarioInfo.M3ScienceBuildings = ScenarioUtils.CreateArmyGroup('Civilian', 'West_Science')
            ScenarioUtils.CreateArmyGroup('Civilian', 'West_Walls')
        end

        -- "QAI is everywhere around"
        ScenarioFramework.Dialogue(OpStrings.M3BuildIntro1, IntroMission3NIS, true)
    else
        ---------
        -- QAI AI
        ---------
        -- Patrols
        local platoon

        for i = 1, 2 do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'M3_North_Land_Patrol_' .. i .. '_D' .. Difficulty, 'GrowthFormation')
            ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_QAI_N_Base_Land_Patrol_Chain_' .. i)
        end

        --------------
        -- Loyalist AI
        --------------
        M3LoyalistAI.LoyalistM3MainBaseAI()

        ScenarioFramework.RefreshRestrictions('Loyalist')

        -- Charis ACU
        ScenarioInfo.CharisACU = ScenarioFramework.SpawnCommander('Loyalist', 'Charis_ACU', false, 'Charis', false, false,
            {'CrysalisBeam', 'HeatSink', 'ShieldHeavy'})

        ------------
        -- Objective
        ------------
        ScenarioInfo.M3ScienceBuildings = ScenarioUtils.CreateArmyGroup('Civilian', 'West_Science')
        ScenarioUtils.CreateArmyGroup('Civilian', 'West_Walls')

        ForkThread(IntroMission3NIS)
    end
end

function IntroMission3NIS()
    -- No NIS when building a new gate
    if ScenarioInfo.M3PlayersPlan == 'build' then
        -- Playable area
        ScenarioFramework.SetPlayableArea('M3_Build_Area', true)

        -- "Get the Gate asap"
        ScenarioFramework.Dialogue(OpStrings.M3BuildIntro2, M3BuildGate, true)
    else
        -- Playable area
        ScenarioFramework.SetPlayableArea('M3_Push_Area', true)

        if not SkipNIS3 then
            Cinematics.EnterNISMode()
            WaitSeconds(1)

            WaitSeconds(1)
            Cinematics.ExitNISMode()
        end

        M3UseCharisGate()
    end
end

-------------
-- Build Gate
-------------
function M3BuildGate()
    -----------------------------------------
    -- Primary Objective - Build Quantum Gate
    -----------------------------------------
    ScenarioInfo.M3P1 = Objectives.ArmyStatCompare(
        'primary',
        'incomplete',
        OpStrings.M3P1Title,
        OpStrings.M3P1Description,
        'build',
        {
            Armies = {'HumanPlayers'},
            StatName = 'Units_Active',
            CompareOp = '>=',
            Value = 1,
            ShowProgress = true,
            Category = categories.GATE,
        }
    )
    ScenarioInfo.M3P1:AddResultCallback(
        function(result)
            if result then
                ScenarioFramework.Dialogue(OpStrings.M3GateBuilt, M3ChargeGate, true)
            end
        end
    )

    -- Trigger for capture science buildings objective
    ScenarioFramework.CreateArmyIntelTrigger(M3CaptureScienceBuildingsObjective, ArmyBrains[Player1], 'LOSNow', false, true, categories.CIVILIAN, true, ArmyBrains[Civilian])
end

function M3ChargeGate()
    -- Find the gate
    ScenarioInfo.PlayersGate = ScenarioFramework.GetListOfHumanUnits(categories.GATE)[1]

    -----------------------------------------------
    -- Primary Objective - Protect the Quantum Gate
    -----------------------------------------------
    ScenarioInfo.M3P2 = Objectives.Protect(
        'primary',
        'incomplete',
        OpStrings.M3P2Title,
        OpStrings.M3P2Description,
        {
            Units = {ScenarioInfo.PlayersGate},
            Timer = 600,
        }
    )
    ScenarioInfo.M3P2:AddResultCallback(
        function(result)
            if result then
                ScenarioFramework.Dialogue(OpStrings.M3GateCharged, M3LeavePlanet, true)
            else
                if Random(1, 2) == 1 then
                    ScenarioFramework.Dialogue(OpStrings.M2GateKilled1, M3BuildGate, true)
                else
                    ScenarioFramework.Dialogue(OpStrings.M2GateKilled2, M3BuildGate, true)
                end
            end
        end
    )
end

function M3LeavePlanet()
    -- Make new area for the objective
    local posX, posY, posZ = unpack(ScenarioInfo.PlayersGate:GetPosition())
    Scenario.Areas['M3_Gate_Area'] = {
        ['rectangle'] = RECTANGLE(posX - 8, posZ - 8, posX + 8, posZ + 8),
    }

    ---------------------------------------
    -- Primary Objective - Leave the Planet
    ---------------------------------------
    ScenarioInfo.M3P3 = Objectives.SpecificUnitsInArea(
        'primary',
        'incomplete',
        OpStrings.M3P3Title,
        OpStrings.M3P3Description,
        {
            Units = ScenarioInfo.PlayersACUs,
            Area = 'M3_Gate_Area',
            MarkArea = true,
        }
    )
    ScenarioInfo.M3P3:AddResultCallback(
        function(result)
            if result then
                LeaveCinematics()
            end
        end
    )
end

function M3SpiderBotsAttack()
    -- Randomly spawns Spider Bots, ammout depending on difficulty, and sends them to Player's base
    local quantity = {1, 1, 2}
    local platoonNames = {
        'M3_SpiderBots_1',
        'M3_SpiderBots_2',
        'M3_SpiderBots_3',
        'M3_SpiderBots_4',
    }

    for i = 1, quantity[Difficulty] do
        local num = Random(1, table.getn(platoonNames))
        local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', platoonNames[num], 'AttackFormation')
        platoon:AggressiveMoveToLocation(ScenarioUtils.MarkerToPosition('M3_QAI_PlayerBase_Attack_0'))
        ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_Player_Base_Chain')
        table.remove(platoonNames, num)
    end
end

function M3MazerACUAttack()
    local ACU = ScenarioFramework.SpawnCommander('QAI', 'M3_ACU_' .. Random(1, 4), false, LOC '{i QAI}', false, false,
        {'MicrowaveLaserGenerator', 'T3Engineering', 'StealthGenerator', 'CloakingGenerator'})
    ACU:SetAutoOvercharge(true)

    local platoon = ArmyBrains[QAI]:MakePlatoon('', '')
    ArmyBrains[QAI]:AssignUnitsToPlatoon(platoon, {ACU}, 'Attack', 'None')
    platoon:AggressiveMoveToLocation(ScenarioUtils.MarkerToPosition('M3_QAI_PlayerBase_Attack_0'))
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_Player_Base_Chain')
end

-----------
-- Run away
-----------
function M3UseCharisGate()
    M3BuildGate()

    -- Trigger for capture science buildings objective
    --ScenarioFramework.CreateArmyIntelTrigger(M3CaptureScienceBuildingsObjective, ArmyBrains[Player1], 'LOSNow', false, true, categories.CIVILIAN, true, ArmyBrains[Civilian])
end

function M3Dialogue1()
    ScenarioFramework.Dialogue(OpStrings.M3PostIntro)
end

---------------
-- Common stuff
---------------
function M3CaptureScienceBuildingsObjective()
    ScenarioFramework.Dialogue(OpStrings.M3CaptureScienceFacility)

    --------------------------------------------------
    -- Secondary Objective - Capture Science Buildings
    --------------------------------------------------
    ScenarioInfo.M3S1 = Objectives.Capture(
        'secondary',
        'incomplete',
        OpStrings.M3S1Title,
        OpStrings.M3S1Description,
        {
            Units = ScenarioInfo.M3ScienceBuildings,
        }
    )
    ScenarioInfo.M3S1:AddResultCallback(
        function(result)
            if result then
                ScenarioFramework.Dialogue(OpStrings.M3ScienceFacilityCaptured)
            else
                ScenarioFramework.Dialogue(OpStrings.M3ScienceFacilityDead)
            end
        end
    )
end

-------------------
-- Custom Funcitons
-------------------
function DamageGroup(tblUnits)
    for _, unit in tblUnits do
        unit:AdjustHealth(unit, Random(0, unit:GetHealth()/3) * -2)
    end
end

------------------
-- Debug Functions
------------------
function OnCtrlF3()
    ForkThread(function()
    Cinematics.EnterNISMode()
    WaitSeconds(1)

    Cinematics.CameraThirdPerson(ScenarioInfo.Player1CDR, 0.3, 15, 3)
    WaitSeconds(1)
    Cinematics.ExitNISMode()
    end)
end

function OnCtrlF4()
    for _, v in ArmyBrains[QAI]:GetListOfUnits(categories.ALLUNITS - categories.WALL, false) do
        v:Kill()
    end
end

function OnShiftF3()
    M3SpiderBotsAttack()
end

