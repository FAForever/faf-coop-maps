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
local PingGroups = import('/lua/SimPingGroup.lua')
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

ScenarioInfo.M3NumLoyalistPlatoonNeeded = 18

---------
-- Locals
---------
local Player1 = ScenarioInfo.Player1
local Player2 = ScenarioInfo.Player2
local Loyalist = ScenarioInfo.Loyalist
local QAI = ScenarioInfo.QAI
local Civilian = ScenarioInfo.Civilian

local Difficulty = ScenarioInfo.Options.Difficulty

local LeaderFaction
local LocalFaction
local Player2Faction

-- Min health for the bonus objective
local PlayerHPObjectiveTreshold = 5000
local PlayerStartingHP = {8961, 7440, 6583}
-- Time in second for charging the gate if player decides to build one.
local GateChargeTimer = 600

-------------
-- Debug Only
-------------
local DEBUG = false
local SkipM1 = false
local SkipM2 = false
local DebugGamePlan = 'build'
local SkipM3NIS = false

-----------
-- Start up
-----------
function OnPopulate(scenario)
    ScenarioUtils.InitializeScenarioArmies()
    LeaderFaction, LocalFaction = ScenarioFramework.GetLeaderAndLocalFactions()

    if SkipM1 then
        return
    end

    ---------
    -- Player
    ---------
    -- Base, damage the buildings a bit
    local base = ScenarioUtils.CreateArmyGroup('Player1', 'M1_Player_Base')
    DamageGroup(base)

    local airFactories = ArmyBrains[Player1]:GetListOfUnits(categories.FACTORY * categories.AIR)
    local landFactories = ArmyBrains[Player1]:GetListOfUnits(categories.FACTORY * categories.LAND)

    -- Rally points
    IssueClearFactoryCommands(airFactories)
    IssueFactoryRallyPoint(airFactories, ScenarioUtils.MarkerToPosition('M1_Player_Air_Rally'))
    IssueClearFactoryCommands(landFactories)
    IssueFactoryRallyPoint(landFactories, ScenarioUtils.MarkerToPosition('M1_Player_Land_Rally'))

    -- Refresh restrictions in the support factory
    ScenarioFramework.RefreshRestrictions('Player1')

    -- Build some things out of the factoriees, leave the T2 air factory ready for the transport
    --IssueBuildFactory({ScenarioInfo.UnitNames[Player1]['T1_Air_Factory_1'], ScenarioInfo.UnitNames[Player1]['T1_Air_Factory_2']}, 'uaa0102', 5) -- T1 Interceptors
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
    local unitData = ScenarioUtils.FindUnit('T2_PD', Scenario.Armies['Civilian'].Units)
    IssueBuildMobile({ScenarioInfo.UnitNames[Player1]['T2_Engineer_3']}, unitData.Position, unitData.type, {})
    --unitData = ScenarioUtils.FindUnit('T2_PD_2', Scenario.Armies['Civilian'].Units)
    --IssueBuildMobile({ScenarioInfo.UnitNames[Player1]['T2_Engineer_4']}, unitData.Position, unitData.type, {})

    -- Spawn ACU 1 second later, else the camera wants to zoom on it right away
    ScenarioInfo.PlayersACUs = {}
    ForkThread(
        function()
            WaitSeconds(1)
            local upgrades
            if Difficulty <= 2 then
                upgrades = {'HeatSink'}
            end
            ScenarioInfo.Player1CDR = ScenarioFramework.SpawnCommander('Player1', 'Aeon_ACU', false, true, false, PlayerDeath, upgrades)
            table.insert(ScenarioInfo.PlayersACUs, ScenarioInfo.Player1CDR)
            IssueMove({ScenarioInfo.Player1CDR}, ScenarioUtils.MarkerToPosition('M1_ACU_Destination'))
            -- Make sure the ACU won't go below the min HP required in one of the bonus objectives.
            ScenarioInfo.Player1CDR:SetHealth(ScenarioInfo.Player1CDR, math.min(PlayerStartingHP[Difficulty], ScenarioInfo.Player1CDR:GetMaxHealth()))
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

    if Difficulty >= 2 then
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'M1_QAI_Land_Attack_7', 'GrowthFormation')
        ScenarioFramework.PlatoonPatrolChain(platoon, 'M1_QAI_Land_Attack_Chain_3')
    end

    -- Air
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'M1_QAI_Air_Attack_North_1', 'GrowthFormation')
    platoon:AggressiveMoveToLocation(ScenarioUtils.MarkerToPosition('M1_QAI_Land_Attack_2'))

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'M1_QAI_Air_Attack_South_1', 'GrowthFormation')
    platoon:AggressiveMoveToLocation(ScenarioUtils.MarkerToPosition('M1_QAI_Land_Attack_2'))

    -- Rest of the attack will spawn later offmap and move in
    ForkThread(M1QAIAttackThread)

    -- Wreckages
    ScenarioUtils.CreateArmyGroup('Civilian', 'M1_Wreckages', true)

    -- Debug preview of the full player's base.
    if false then
        for _, prop in GetReclaimablesInRect(ScenarioUtils.AreaToRect('M1_Area')) do
            if prop.IsWreckage and string.sub(prop.AssociatedBP, 2, 2) == 'a' then
                local x, y, z = unpack(prop:GetPosition())
                local qx, qy, qz, qw = unpack(prop:GetOrientation())
                CreateUnit(prop.AssociatedBP, Player1, x, y, z, qx, qy, qz, qw)
                prop:Destroy()
            end
        end
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
        if Player2Faction == 'aeon' then
            ScenarioFramework.SetAeonAlly2Color(Player2)
        elseif Player2Faction == 'cybran' then
            ScenarioFramework.SetCybranPlayerColor(Player2)
        else
            ScenarioFramework.SetUEFPlayerColor(Player2)
        end
    end

    -- Dont share resource to the players
    ArmyBrains[Loyalist]:SetResourceSharing(false)

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
            ScenarioInfo.Player1CDR = ScenarioFramework.SpawnCommander('Player1', 'Aeon_ACU', false, true, false, PlayerDeath,
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

    WaitSeconds(6)

    if Difficulty >= 2 then
        -- Corsairs to snipe pgen
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'M1_QAI_Air_Attack_North_5', 'GrowthFormation')
        local unit = ScenarioInfo.UnitNames[Player1]['Target_Pgen']
        if unit and not unit.Dead then
            platoon:AttackTarget(unit)
        end
        platoon:AggressiveMoveToLocation(ScenarioUtils.MarkerToPosition('M1_QAI_Land_Attack_2'))
    end

    WaitSeconds(6)

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'M1_QAI_Air_Attack_South_2', 'GrowthFormation')
    platoon:AggressiveMoveToLocation(ScenarioUtils.MarkerToPosition('M1_QAI_Land_Attack_2'))

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'M1_QAI_Air_Attack_North_1', 'GrowthFormation')
    platoon:AggressiveMoveToLocation(ScenarioUtils.MarkerToPosition('M1_QAI_Land_Attack_2'))

    WaitSeconds(15)

    if Difficulty >= 2 then
        -- Corsairs to snipe pgen
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'M1_QAI_Air_Attack_North_5', 'GrowthFormation')
        local unit = ScenarioInfo.UnitNames[Player1]['Target_Pgen']
        if unit and not unit.Dead then
            platoon:AttackTarget(unit)
        end
        platoon:AggressiveMoveToLocation(ScenarioUtils.MarkerToPosition('M1_QAI_Land_Attack_2'))
    end

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'M1_QAI_Air_Attack_North_2', 'GrowthFormation')
    platoon:AggressiveMoveToLocation(ScenarioUtils.MarkerToPosition('M1_QAI_Land_Attack_2'))

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

    WaitSeconds(5)

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'M1_QAI_Land_Attack_5', 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M1_QAI_Land_Attack_Chain_1')

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'M1_QAI_Land_Attack_6', 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M1_QAI_Land_Attack_Chain_2')

    WaitSeconds(5)

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'M1_QAI_Air_Attack_North_3', 'GrowthFormation')
    platoon:AggressiveMoveToLocation(ScenarioUtils.MarkerToPosition('M1_QAI_Land_Attack_2'))

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'M1_QAI_Air_Attack_South_3', 'GrowthFormation')
    platoon:AggressiveMoveToLocation(ScenarioUtils.MarkerToPosition('M1_QAI_Land_Attack_2'))

    WaitSeconds(5)

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'M1_QAI_Air_Attack_North_4', 'GrowthFormation')
    platoon:AggressiveMoveToLocation(ScenarioUtils.MarkerToPosition('M1_QAI_Land_Attack_2'))

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'M1_QAI_Air_Attack_South_4', 'GrowthFormation')
    platoon:AggressiveMoveToLocation(ScenarioUtils.MarkerToPosition('M1_QAI_Land_Attack_2'))
end

-----------
-- End Game
-----------
function PlayerDeath(commander)
    if DEBUG then
        return
    end
    ScenarioFramework.PlayerDeath(commander, OpStrings.PlayerDies)
end

function LeaveCinematics()
    -- Finish bonus objective of lowest ACU HP
    if ScenarioInfo.M3B1.Active then
        ScenarioInfo.M3B1:ManualResult(true)
    end

    while ScenarioInfo.DialogueLock do
        WaitSeconds(0.2)
    end
    ScenarioFramework.FlushDialogueQueue()

    local gates = nil
    if ScenarioInfo.M3PlayersPlan == 'build' then
        gates = {ScenarioInfo.PlayersGate}
    else
        gates = ArmyBrains[Loyalist]:GetListOfUnits(categories.GATE)
    end

    for _, gate in gates do
        -- Make sure the gate doesn't die anymore
        gate.CanBeKilled = false
        gate.CanTakeDamage = false
    end

    local commandersReady = 0
    ScenarioInfo.NumACUGatedOut = 0

    for i, ACU in ScenarioInfo.PlayersACUs do
        ForkThread(
            function(ACU, i)
                -- Set ACU invincible
                ACU.CanBeKilled = false
                ACU.CanTakeDamage = false

                -- Just in case some smarty pants actually manages to sneak their way through all the AA on a transport.
                if ACU:IsUnitState('Attached') then
                    for _, transport in ArmyBrains[ACU.Army]:GetListOfUnits(categories.TRANSPORTATION, false) do
                        for _, carriedUnit in transport:GetCargo() do
                            if carriedUnit == ACU then
                                IssueClearCommands({transport})
                                IssueTransportUnload({transport}, transport:GetPosition())
                                break
                            end
                        end
                    end
                    repeat
                        WaitSeconds(0.5)
                    until not ACU:IsUnitState('Attached')
                end

                commandersReady = commandersReady + 1

                -- Move it into the gate
                IssueStop({ACU})
                IssueClearCommands({ACU})
                local gate = gates[i] or gates[1]
                local cmd = IssueMove({ACU}, gate:GetPosition())

                while not IsCommandDone(cmd) do
                    WaitSeconds(0.1)
                end

                -- Gete out efect
                ScenarioFramework.FakeTeleportUnit(ACU, true)

                -- We need to be carefull to trigger the cam move only once!
                if not ScenarioInfo.FirstPlayerLeft then
                    ScenarioInfo.FirstPlayerLeft = true
                    -- Final dialogue fron HQ
                    ScenarioFramework.Dialogue(OpStrings['PlayerWin_' .. ScenarioInfo.M3PlayersPlan], nil, true)

                    local marker = ScenarioUtils.GetMarker('Cam_M3_Outro_'..ScenarioInfo.M3PlayersPlan)
                    if ScenarioInfo.M3PlayersPlan == 'build' then
                        -- Center the final cam at the gate that player used.
                        marker.position = gate:GetPosition()
                    end

                    Cinematics.CameraMoveToMarker(marker, 3)
                end

                ScenarioInfo.NumACUGatedOut = ScenarioInfo.NumACUGatedOut + 1

                if ScenarioInfo.NumACUGatedOut == table.getn(ScenarioInfo.PlayersACUs) then
                    PlayerWin()
                end
            end, ACU, i
        )
    end

    -- Wait until all commanders are ready to move to the gate.
    while commandersReady ~= table.getn(ScenarioInfo.PlayersACUs) do
        WaitSeconds(0.1)
    end

    Cinematics.EnterNISMode()
    WaitSeconds(2)

    ScenarioFramework.Dialogue(OpStrings['M3PlayerAtGate_' .. ScenarioInfo.M3PlayersPlan], nil, true)

    -- Track the ACU until it leaves
    Cinematics.CameraThirdPerson(ScenarioInfo.Player1CDR, 0.2, 12)
end

function PlayerLose()
    ScenarioInfo.OpComplete = false
    ForkThread(KillGame)
end

function PlayerWin()
    ScenarioInfo.OpComplete = true
    ForkThread(KillGame)
end

function KillGame()
    local secondary = Objectives.IsComplete(ScenarioInfo.M2S1) and
                      Objectives.IsComplete(ScenarioInfo.M3S1)
    local bonus = Objectives.IsComplete(ScenarioInfo.M1B1) and
                  Objectives.IsComplete(ScenarioInfo.M1B2) and
                  Objectives.IsComplete(ScenarioInfo.M2B1)
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

    --------------------------------
    -- Bonus Objective - Upgrade ACU
    --------------------------------
    ScenarioInfo.M1B1 = Objectives.Basic(
        'bonus',
        'incomplete',
        OpStrings.M1B1Title,
        OpStrings.M1B1Description,
        "/game/orders/enhancement_btn_up.dds",
        {
            Hidden = true,
        }
    )

    -- Annnounce the mission name after few seconds
    ScenarioFramework.CreateTimerTrigger(MissionNameAnnouncement, 4)

    -- Spiderbot warning followed by obj to build T2 transport
    ScenarioFramework.CreateTimerTrigger(M1SpiderBotWarning, 8)
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
                    if unit and not unit:IsBeingBuilt() then
                        ScenarioInfo.PlayerTransport = unit
                    end
                end
            end
        end
    )

    -----------------------------------------------------------
    -- Bonus Objective - Finish the transport before MLs arrive
    -----------------------------------------------------------
    ScenarioInfo.M1B2 = Objectives.Basic(
        'bonus',
        'incomplete',
        OpStrings.M1B2Title,
        OpStrings.M1B2Description,
        Objectives.GetActionIcon('timer'),
        {
            Hidden = true,
        }
    )

    -- Inform player to stay in the base
    ForkThread(M1ACUInBaseCheck)

    local delay = {12, 6, 1}
    ScenarioFramework.CreateTimerTrigger(M1SpiderBotAttack, delay[Difficulty])
end

function M1ACUInBaseCheck()
    while ScenarioInfo.M1P2.Active and not ScenarioInfo.CZAR.Dead and not ScenarioInfo.Player1CDR.Dead do
        if not ScenarioFramework.UnitsInAreaCheck(categories.COMMAND, 'M1_ACU_Area') then
            ScenarioFramework.Dialogue(OpStrings['M1ACUInBaseReminder' .. Random(1, 3)])
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
        local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'M1_Spiders_Support', 'NoFormation')
        platoon:GuardTarget(v)
        platoon:SetPrioritizedTargetList('Attack',
            {
                categories.AIR * categories.EXPERIMENTAL,
                categories.AIR * categories.TECH3,
                categories.AIR * categories.TECH2,
                categories.AIR * categories.TECH1,
                categories.ALLUNITS,
            }
        )

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
        ScenarioInfo.M1B2:ManualResult(false)
        ScenarioFramework.Dialogue(OpStrings.M1SpiderBotsSpotted2, nil, true)
    else
        -- Player has the transport
        ScenarioInfo.M1B2:ManualResult(true)
        ScenarioFramework.Dialogue(OpStrings.M1SpiderBotsSpotted1, nil, true)
    end

    -- Send in reinforcements
    ScenarioFramework.CreateTimerTrigger(M1LoyalistReinforcements, 18)
end

function M1LoyalistReinforcements()
    ScenarioFramework.Dialogue(OpStrings.M1ReinforcementsArrived, nil, true)

    -- CZAR, if it dies (player took too long to build the transport, kill the player with T3 air)
    ScenarioInfo.CZAR = ScenarioUtils.CreateArmyUnit('Loyalist', 'CZAR')
    ScenarioFramework.CreateUnitDestroyedTrigger(M1SnipePlayer, ScenarioInfo.CZAR)
    IssueMove({ScenarioInfo.CZAR}, ScenarioUtils.MarkerToPosition('CZAR_Marker_1'))
    for _, unit in ScenarioInfo.M1SpiderBotPlatoon:GetPlatoonUnits() do
        IssueAttack({ScenarioInfo.CZAR}, unit)
    end
    IssueAggressiveMove({ScenarioInfo.CZAR}, ScenarioUtils.MarkerToPosition('CZAR_Marker_2'))

    for _, unit in EntityCategoryFilterDown(categories.EXPERIMENTAL, ScenarioInfo.M1SpiderBotPlatoon:GetPlatoonUnits()) do
        IssueAttack({ScenarioInfo.CZAR}, unit)
    end

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

    -- Fail the objective to build the transport
    if ScenarioInfo.M1P2.Active then
        ScenarioInfo.M1P2:ManualResult(false)
    end

    ScenarioFramework.Dialogue(OpStrings.M1ReinforcementsDestroyed, nil, true)

    local platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('QAI', 'M1_ASFs', 'NoFormation', 5)
    for _, v in platoon:GetPlatoonUnits() do
        v.CanTakeDamage = false
        v.CanBeKilled = false
    end
    platoon:AggressiveMoveToLocation(ScenarioUtils.MarkerToPosition('M1_QAI_Land_Attack_2'))
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M1_QAI_Death_Chain')

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('QAI', 'M1_StratBombers', 'NoFormation', 5)
    for _, v in platoon:GetPlatoonUnits() do
        v.CanTakeDamage = false
        v.CanBeKilled = false
    end
    platoon:AggressiveMoveToLocation(ScenarioUtils.MarkerToPosition('M1_QAI_Land_Attack_2'))
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M1_QAI_Death_Chain')
end

function M1PlayerEvac()
    -- Attack the czar with AA
    local units = ArmyBrains[QAI]:GetListOfUnits(categories.url0205 + categories.drlk001)
    IssueClearCommands(units)
    IssueAttack(units, ScenarioInfo.CZAR)
    IssueFormAggressiveMove(units, ScenarioUtils.MarkerToPosition('M1_QAI_Land_Attack_2'), 'AttackFormation', 0)

    while not ScenarioInfo.PlayerTransport do
        WaitSeconds(1)
    end

    if ScenarioInfo.CZAR.Dead then
        return
    end

    -- Make sure the transport and CZAR won't die anymore
    ScenarioInfo.PlayerTransport.CanTakeDamage = false
    ScenarioInfo.PlayerTransport.CanBeKilled = false
    ScenarioInfo.PlayerTransport:SetDoNotTarget(true)

    ScenarioInfo.CZAR.CanTakeDamage = false
    ScenarioInfo.CZAR.CanBeKilled = false

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
    ScenarioUtils.CreateArmyGroup('Civilian', 'M2_Wreckages', true)

    -- Give initial resources to the Player1 as his storage might be empty if stalling during the first part
    ArmyBrains[Player1]:GiveResource('Energy', 4000)
    ArmyBrains[Player1]:GiveResource('Mass', 650)

    if not SkipM1 then
        ForkThread(IntroMission2NIS)
    elseif not SkipM2 then
        StartMission2()
    else
        ScenarioInfo.M3PlayersPlan = DebugGamePlan
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

    -- Any sneaky transports or anything else that the player would try to sneak with the ACU by guarding the transport
    local guards = ScenarioInfo.Player1CDR:GetGuards()
    if guards[1] then
        IssueClearCommands(guards)
    end

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
    local cargo = ScenarioInfo.PlayerTransport:GetCargo()
    -- Drop Player's ACU
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

    -- Cleanup the units
    for _, unit in GetUnitsInRect(ScenarioUtils.AreaToRect('M1_Area')) do
        if unit ~= ScenarioInfo.CZAR then
            -- TODO: Remove once the restricitons are not bugged when units factory:Destroy()
            if EntityCategoryContains(categories.FACTORY, unit) then
                unit:Kill(unit, 'Normal', 2.0)
            else
                unit:Destroy()
            end
        end
    end


    Cinematics.CameraMoveToMarker('Cam_M2_Intro_3', 3)

    while ScenarioInfo.Player1CDR:IsUnitState('Attached') do
        WaitSeconds(.2)
    end

    -- Kill the transport as soon as it drops the ACU
    ScenarioInfo.PlayerTransport.CanTakeDamage = true
    ScenarioInfo.PlayerTransport.CanBeKilled = true
    ScenarioInfo.PlayerTransport:SetDoNotTarget(false)
    ScenarioInfo.PlayerTransport:Kill()
    -- Kill any other unit on the transport, for the balance reasons.
    for _, unit in cargo do
        if not unit.Dead and unit ~= ScenarioInfo.Player1CDR then
            unit:Kill()
        end
    end

    -- "That was close"
    ScenarioFramework.Dialogue(OpStrings.M2Intro4, nil, true)

    -- CZAR death function, crashes it at the right location
    local function KillCZAR()
        ScenarioInfo.CZAR.CanBeKilled = true
        ScenarioInfo.CZAR:Kill()
        WaitSeconds(3)
        ScenarioInfo.CZAR:Destroy()
    end
    ScenarioFramework.CreateUnitToMarkerDistanceTrigger(KillCZAR, ScenarioInfo.CZAR, 'CZAR_Destination', 30)

    -- Warp CZAR closer to the crash site, damage it for a better effect
    Warp(ScenarioInfo.CZAR, ScenarioUtils.MarkerToPosition('CZAR_Warp_Marker'))
    ScenarioInfo.CZAR.CanTakeDamage = true
    ScenarioInfo.CZAR:SetHealth(ScenarioInfo.CZAR, 8000)
    IssueStop({ScenarioInfo.CZAR})
    IssueClearCommands({ScenarioInfo.CZAR})
    IssueMove({ScenarioInfo.CZAR}, ScenarioUtils.MarkerToPosition('CZAR_Destination'))

    -- Move the
    IssueMove({ScenarioInfo.Player1CDR}, ScenarioUtils.MarkerToPosition('M2_Player_Destination'))

    Cinematics.CameraMoveToMarker('Cam_M2_Intro_4', 5)

    -- Attack the CZAR
    units = ScenarioUtils.CreateArmyGroup('QAI', 'M2_NIS_ASFs_2')
    IssueAttack(units, ScenarioInfo.CZAR)
    ScenarioFramework.GroupPatrolChain(units, 'M2_Loyalist_Initial_Patrol_Chain')

    -- "QAI's air everywhere"
    ScenarioFramework.Dialogue(OpStrings.M2Intro5, nil, true)

    WaitSeconds(2)
    Cinematics.CameraMoveToMarker('Cam_M2_Intro_5', 5)

    WaitSeconds(6)

    Cinematics.ExitNISMode()

    -- Playable area
    ScenarioFramework.SetPlayableArea('M2_Area', false)

    StartMission2()
end

function StartMission2()
    -- Finish the objective to upgrade the ACU
    if ScenarioInfo.M1B1 then
        local hasUpgrade = ScenarioInfo.Player1CDR:HasEnhancement('CrysalisBeam') or ScenarioInfo.Player1CDR:HasEnhancement('Shield') or ScenarioInfo.Player1CDR:HasEnhancement('AdvancedEngineering')
        if hasUpgrade then
            ScenarioInfo.M1B1:ManualResult(true)
        else
            ScenarioInfo.M1B1:ManualResult(false)
        end
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
            MarkArea = true,
        }
    )
    ScenarioInfo.M2P1:AddResultCallback(
        function(result)
            if result then
                M2ChoiceDialogue()
            end
        end
    )

    ------------------------------------------
    -- Bonus Objective - Capture Engie Station
    ------------------------------------------
    ScenarioInfo.M2B1 = Objectives.Capture(
        'bonus',
        'incomplete',
        OpStrings.M2B1Title,
        OpStrings.M2B1Description,
        {
            Units = {ScenarioInfo.UnitNames[QAI]['M2_QAI_Engie_Station']},
            MarkUnits = false,
            Hidden = true,
        }
    )
    ScenarioInfo.M2B1:AddResultCallback(
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

    local delay = {250, 230, 210}
    ScenarioFramework.CreateTimerTrigger(M2ChoiceDialogue, delay[Difficulty])
end

function M2SpawnPlayer2()
    if ArmyBrains[Player2] then
        local function SpawnPlayer2()
            if Player2Faction == 'aeon' then
                ScenarioInfo.Player2CDR = ScenarioFramework.SpawnCommander('Player2', 'Aeon_ACU', 'Warp', true, false, PlayerDeath)
            elseif Player2Faction == 'cybran' then
                ScenarioInfo.Player2CDR = ScenarioFramework.SpawnCommander('Player2', 'Cybran_ACU', 'Warp', true, false, PlayerDeath)
            else
                ScenarioInfo.Player2CDR = ScenarioFramework.SpawnCommander('Player2', 'UEF_ACU', 'Warp', true, false, PlayerDeath)
            end
            table.insert(ScenarioInfo.PlayersACUs, ScenarioInfo.Player2CDR)

            WaitSeconds(5)

            ScenarioFramework.Dialogue(OpStrings.TAUNT1)
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
            ScenarioInfo.CZARWreck.CanTakeDamage = false
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
            ScenarioInfo.M3PlayersPlan = 'push'
            ScenarioFramework.Dialogue(OpStrings.M2UseCharisGate, IntroMission3, true)
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
    M3QAIAI.QAIM3NorthBaseAI(ScenarioInfo.M3PlayersPlan)
    M3QAIAI.QAIM3NorthEastBaseAI()
    M3QAIAI.QAIM3WestBaseAI(ScenarioInfo.M3PlayersPlan)

    local platoon

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'M3_North_East_Air_Patrol_D' .. Difficulty, 'NoFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_QAI_NE_Air_Patrol_Chain')
    platoon:ForkThread(ScenarioPlatoonAI.PlatoonEnableStealth)

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'M3_North_East_Land_Patrol_D' .. Difficulty, 'NoFormation')
    for _, v in platoon:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M3_QAI_NE_Land_Patrol_Chain')))
    end

    if ScenarioInfo.M3PlayersPlan == 'build' then
        -- Allow building Quantum gate
        ScenarioFramework.RemoveRestrictionForAllHumans(categories.GATE)

        ---------
        -- QAI AI
        ---------
        M3QAIAI.QAIM3NorthWestBaseAI()
        M3QAIAI.QAIM3SouthEastBaseAI()
        M3QAIAI.QAIM3SouthWestBaseAI()

        -- Give initial resources to the AI
        ArmyBrains[QAI]:GiveResource('MASS', 3000)
        ArmyBrains[QAI]:GiveResource('ENERGY', 25000)

        -- ScenarioUtils.CreateArmyGroup('QAI', 'Offmap_Arty')

        -- Patrols

        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'M3_South_East_Air_Patrol_D' .. Difficulty, 'NoFormation')
        ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_QAI_SE_Air_Patrol_Chain')
        platoon:ForkThread(ScenarioPlatoonAI.PlatoonEnableStealth)

        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'M3_South_East_Land_Patrol_D' .. Difficulty, 'NoFormation')
        for _, v in platoon:GetPlatoonUnits() do
            ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M3_QAI_SE_Land_Patrol_Chain')))
        end

        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'M3_South_West_Air_Patrol_D' .. Difficulty, 'NoFormation')
        ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_QAI_SW_Air_Patrol_Chain')
        platoon:ForkThread(ScenarioPlatoonAI.PlatoonEnableStealth)

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
    else
        ---------
        -- Player
        ---------
        -- Energy buildings for the player inside Charis' base
        ScenarioUtils.CreateArmyGroup('Player1', 'M3_Eco')

        ---------
        -- QAI AI
        ---------
        M3QAIAI.QAIM3MainBaseAI()
        M3QAIAI.QAIM3ExperimentalBaseAI()
        M3QAIAI.QAIM3DefenseBaseAI()
        M3QAIAI.QAIM3PlateauDefenseBaseAI()

        -- Engineers to build plateau bases
        local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'M3_QAI_Plateau_Defense_Engineers', 'NoFormation')
        if not platoon.PlatoonData then
            platoon.PlatoonData = {}
        end
        platoon.PlatoonData.BaseName = 'M3_QAI_Plateau_Defense_Base'
        platoon:ForkAIThread(import('/lua/ai/opai/basemanagerplatoonthreads.lua').BaseManagerEngineerPlatoonSplit)

        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'M3_QAI_Plateau_West_Engineers', 'NoFormation')
        if not platoon.PlatoonData then
            platoon.PlatoonData = {}
        end
        platoon.PlatoonData.BaseName = 'M3_QAI_W_Base'
        platoon:ForkAIThread(import('/lua/ai/opai/basemanagerplatoonthreads.lua').BaseManagerEngineerPlatoonSplit)

        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'M3_QAI_West_Reclaim_Engineers', 'NoFormation')
        ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_QAI_W_Base_EngineerChain')

        -- Give initial resources to the AI
        ArmyBrains[QAI]:GiveResource('MASS', 10000)
        ArmyBrains[QAI]:GiveResource('ENERGY', 50000)

        -- QAI ACU
        ScenarioInfo.QAIACU = ScenarioFramework.SpawnCommander('QAI', 'QAI_ACU', false, 'QAI', false, false,
            {'MicrowaveLaserGenerator', 'StealthGenerator', 'CloakingGenerator', 'CoolingUpgrade'})
        ScenarioInfo.QAIACU:SetAutoOvercharge(true)

        ScenarioFramework.RefreshRestrictions('QAI')

        -- Walls
        ScenarioUtils.CreateArmyGroup('QAI', 'M3_Walls')

        -- Patrols
        local platoon

        -- Main base
        -- Air
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'M3_Main_Air_Patrol_D' .. Difficulty, 'NoFormation')
        platoon:ForkThread(ScenarioPlatoonAI.PlatoonEnableStealth)
        for _, unit in platoon:GetPlatoonUnits() do
            ScenarioFramework.GroupPatrolRoute({unit}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M3_QAI_Main_Base_Air_Defense_Chain')))
        end

        -- Spider
        for i = 1, 2 do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'M3_Main_Spider_Patrol_' .. i, 'AttackFormation')
            ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_QAI_Spider_Patrol_' .. i .. '_Chain')
            platoon.PlatoonData = {
                PatrolChain = 'M3_QAI_Spider_Patrol_' .. i .. '_Chain',
            }
            platoon:ForkThread(PlatoonTargetSpecificUnitWhenClose)
        end

        -- Land patrol
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'M3_Main_Land_Patrol_1_D' .. Difficulty, 'NoFormation')
        for _, unit in platoon:GetPlatoonUnits() do
            ScenarioFramework.GroupPatrolRoute({unit}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M3_QAI_Main_Base_Land_Defense_Chain')))
        end

        -- North base land patrol
        for i = 1, 2 do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'M3_North_Land_Patrol_' .. i .. '_D' .. Difficulty, 'GrowthFormation')
            ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_QAI_N_Base_Land_Patrol_Chain_' .. i)
        end

        -- Plateau
        -- Units attacking Loyalist proxy bases
        for i = 1, 8 do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'QAI_Proxy_1_Land_Attackers_' .. i, 'AttackFormation')
            ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_QAI_Plateau_Attack_Proxy_1_Chain')
        end

        for i = 1, 4 do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'QAI_Proxy_2_Land_Attackers_' .. i, 'AttackFormation')
            ScenarioFramework.PlatoonAttackChain(platoon, 'M3_QAI_Plateau_Attack_Proxy_2_Chain')
        end

        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'M3_Plateau_Air_Attack_1', 'NoFormation')
        ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_QAI_Plateau_Attack_Proxy_1_Chain')

        -- Static Land Patrol
        for _, pos in ScenarioUtils.ChainToPositions('M3_QAI_Plateau_Static_Patrol_Chain') do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'M3_QAI_Plateau_Static_Patrol', 'GrowthFormation')
            platoon:AggressiveMoveToLocation(pos)
        end

        -- NIS units
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'QAI_NIS_Attackers', 'NoFormation')
        local positions = ScenarioUtils.ChainToPositions('M3_Loyalist_Base_EngineerChain')
        for _, unit in platoon:GetPlatoonUnits() do
            IssueAggressiveMove({unit}, positions[Random(1, table.getn(positions))])
        end

        for i = 1, 2 do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'QAI_Main_Base_Attack_' .. i, 'GrowthFormation')
            ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_QAI_M_Base_To_Loyalist_Land_Attack_Chain_' .. i)
        end

        --------------
        -- Loyalist AI
        --------------
        M3LoyalistAI.LoyalistM3MainBaseAI()
        M3LoyalistAI.LoyalistM3ProxyBase1AI()
        M3LoyalistAI.LoyalistM3ProxyBase2AI()

        ScenarioFramework.RefreshRestrictions('Loyalist')

        ScenarioUtils.CreateArmyGroup('Loyalist', 'Proxy_Structures')
        ScenarioUtils.CreateArmyGroup('Loyalist', 'M3_Walls')

        -- Units for player, part of cinematics
        ForkThread(M3ReinforcementsThread)

        -- Charis ACU
        ScenarioInfo.CharisACU = ScenarioFramework.SpawnCommander('Loyalist', 'Charis_ACU', false, 'Charis', true, M3CharisDies,
            {'CrysalisBeam', 'HeatSink', 'ShieldHeavy'})
        ScenarioInfo.CharisACU:SetAutoOvercharge(true)

        -- Base patrols
        -- Air
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Loyalist', 'M3_Loyalist_Base_Air_Patrol', 'NoFormation')
        ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_Loyalist_Base_Air_Patrol_Chain')

        -- Land
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Loyalist', 'M3_Main_Base_Static_Patrol_D' .. Difficulty, 'NoFormation')

        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Loyalist', 'M3_Loyalist_Main_Base_Land_Patrol_D' .. Difficulty, 'NoFormation')
        for _, v in platoon:GetPlatoonUnits() do
            ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M3_Loyalist_MainBase_GC_Chain')))
        end

        -- Plateau patrols
        for i = 1, 3 do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoon("Loyalist", "Proxy_Base_Patrol_" .. i, "GrowthFormation")
            ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_Loyalist_Proxy_Base_Patrol_' .. i .."_Chain")
        end

        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon("Loyalist", "Proxy_Base_1_Air_Patrol", "GrowthFormation")
        for _, v in platoon:GetPlatoonUnits() do
            ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M3_Loyalist_Proxy_Base_1_Air_Patrol_Chain')))
        end

        -- Give initial resources to the AI
        ArmyBrains[Loyalist]:GiveResource('MASS', 8000)
        ArmyBrains[Loyalist]:GiveResource('ENERGY', 50000)

        ------------
        -- Objective
        ------------
        ScenarioInfo.M3ScienceBuildings = ScenarioUtils.CreateArmyGroup('Civilian', 'West_Science')
        ScenarioUtils.CreateArmyGroup('Civilian', 'West_Walls')

        -- Wreckages
        ScenarioUtils.CreateArmyGroup('Civilian', 'M3_Wreckages', true)
    end

    ForkThread(IntroMission3NIS)
end

function IntroMission3NIS()
    -- No NIS when building a new gate
    if ScenarioInfo.M3PlayersPlan == 'build' then
        -- Playable area
        ScenarioFramework.SetPlayableArea('M3_Build_Area', true)

        -- "Build the gate, QAI is everywhere around"
        ScenarioFramework.Dialogue(OpStrings.M3BuildIntro1, M3BuildGate, true)
    else
        -- Playable area
        ScenarioFramework.SetPlayableArea('M3_Push_Area', true)

        if SkipM2 then
            for _, unit in ScenarioFramework.GetCatUnitsInArea(categories.ALLUNITS, 'M2_Crash_Area', ArmyBrains[QAI]) do
                unit:Kill()
            end
            WaitSeconds(1)
        end

        if not SkipM3NIS then
            -- Visiton over QAI base and defense line
            local VizMarker1 = ScenarioFramework.CreateVisibleAreaLocation(40, 'M3_VizMarker_1', 0, ArmyBrains[Player1])
            local VizMarker2 = ScenarioFramework.CreateVisibleAreaLocation(40, 'M3_VizMarker_2', 0, ArmyBrains[Player1])

            Cinematics.EnterNISMode()
            WaitSeconds(2)

            -- Look as the QAI's base
            ScenarioFramework.Dialogue(OpStrings.M3RunIntro1, nil, true)
            Cinematics.CameraMoveToMarker('Cam_M3_Run_Intro_1', 5)

            WaitSeconds(2)

            -- Cam at the defensive line
            ScenarioFramework.Dialogue(OpStrings.M3RunIntro2, nil, true)
            Cinematics.CameraMoveToMarker('Cam_M3_Run_Intro_2', 3)

            WaitSeconds(3)

            -- Charis' base
            ScenarioFramework.Dialogue(OpStrings.M3RunIntro3, nil, true)
            Cinematics.CameraMoveToMarker('Cam_M3_Run_Intro_3', 5)

            WaitSeconds(4)

            -- Follow the reinforcements
            ScenarioFramework.Dialogue(OpStrings.M3RunIntro4, nil, true)
            Cinematics.CameraTrackEntity(ScenarioInfo.UnitNames[Loyalist]['NISTransport'], 100)

            WaitSeconds(11)

            -- Final zoomed out camera
            ScenarioFramework.Dialogue(OpStrings.M3RunIntro5, nil, true)
            Cinematics.CameraMoveToMarker('Cam_M3_Run_Intro_4', 4)

            -- Clean up the vision markers
            VizMarker1:Destroy()
            VizMarker2:Destroy()

            WaitSeconds(2)
            Cinematics.ExitNISMode()
        end

        M3UseCharisGate()
    end
end

function M3ReinforcementsThread()
    local units = ScenarioUtils.CreateArmyGroup('Loyalist', 'M3_Reinforcements_D' .. Difficulty)
    local transportPlatoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Loyalist', 'M3_Transports_D' .. Difficulty, 'NoFormation')
    ScenarioInfo.LoyalistTransports = transportPlatoon:GetPlatoonUnits()

    -- Trigger to send ASFs to shoot the transports down when they get close to the drop point
    for _, transport in ScenarioInfo.LoyalistTransports do
        ScenarioFramework.CreateUnitToMarkerDistanceTrigger(M3SpawnTransportHunters, transport, 'M3_Loyalist_Transport_Move_02', 20)
    end

    ScenarioFramework.AttachUnitsToTransports(units, ScenarioInfo.LoyalistTransports)

    ScenarioFramework.PlatoonMoveChain(transportPlatoon, 'M3_Loyalist_Transport_Move_Chain')
    local cmd = transportPlatoon:UnloadAllAtLocation(ScenarioUtils.MarkerToPosition('M3_Loyalist_Drop_Marker'))
    transportPlatoon:MoveToLocation(ScenarioUtils.MarkerToPosition('M3_Loyalist_Transport_Move_01'), false)
    transportPlatoon:MoveToLocation(ScenarioUtils.MarkerToPosition('M3_Loyalist_Transport_Return'), false)

    -- Wait until the units are dropped
    while transportPlatoon:IsCommandsActive(cmd) do
        WaitSeconds(1)
        if not ArmyBrains[Loyalist]:PlatoonExists(transportPlatoon) then
            return
        end
    end

    for _, unit in units do
        if not unit.Dead then
            ScenarioFramework.GiveUnitToArmy(unit, Player1)
        end
    end
end

function M3SpawnTransportHunters(transport)
    WaitTicks(Random(3, 8))
    -- Launch ASFs to kill the transports, then patrol over the plateau
    local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'M3_QAI_Transport_Hunerts', 'NoFormation')
    platoon:ForkThread(ScenarioPlatoonAI.PlatoonEnableStealth)
    platoon:AttackTarget(transport)

    for _, unit in platoon:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({unit}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M3_QAI_Plateau_Air_Patrol_Chain')))
    end
end

-------------
-- Build Gate
-------------
function M3BuildGate()
    ScenarioFramework.Dialogue(OpStrings.M3BuildIntro2, nil, true)

    -- This objective might be assigned again if the gate dies while charing, but we don't want to run rest of the logic
    local repeated = ScenarioInfo.M3P1_1
    -----------------------------------------
    -- Primary Objective - Build Quantum Gate
    -----------------------------------------
    ScenarioInfo.M3P1_1 = Objectives.ArmyStatCompare(
        'primary',
        'incomplete',
        OpStrings.M3P1_1_Title,
        OpStrings.M3P1_1_Description,
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
    ScenarioInfo.M3P1_1:AddResultCallback(
        function(result)
            if result then
                ScenarioFramework.Dialogue(OpStrings.M3GateBuilt, M3ChargeGate, true)
            end
        end
    )

    if repeated then
        return
    end

    ForkThread(M3GateMonitorThread)

    -- Bonus objective for lowest player HP
    M3AcuHPObjective()

    -- Charis' dialogue
    ScenarioFramework.CreateTimerTrigger(M3PostIntroBuildDialogue, 30)

    -- Reminder
    ScenarioFramework.CreateTimerTrigger(M3BuildGateReminder1, 10 * 60)

    -- Trigger for capture science buildings objective
    ScenarioFramework.CreateArmyIntelTrigger(M3CaptureScienceBuildingsObjective, ArmyBrains[Player1], 'LOSNow', false, true, categories.CIVILIAN, true, ArmyBrains[Civilian])
end

-- Discover new player gates and start charging them.
function M3GateMonitorThread()
    ScenarioInfo.M3PlayerGates = {}

    local function RemoveGate(gate)
        table.removeByValue(ScenarioInfo.M3PlayerGates, gate)
    end

    local function GateChargeThread(gate)
        gate.GateCharge = GateChargeTimer

        while true do
            WaitSeconds(1)

            gate.GateCharge = gate.GateCharge - 1
            if DEBUG then
                gate:SetCustomName(gate.ChargeName .. ' - Charge: ' .. gate.GateCharge)
            end
            if gate.GateCharge == 0 then
                if DEBUG then
                    gate:SetCustomName(gate.ChargeName .. ' - Fully Charged!')
                end
                return
            end
        end
    end

    local function AddGate(gate)
        table.insert(ScenarioInfo.M3PlayerGates, gate)
        gate.GateChargeThread = gate:ForkThread(GateChargeThread)
        ScenarioFramework.CreateUnitDestroyedTrigger(RemoveGate, gate)

        if DEBUG then
            local name = 'Gate '..table.getn(ScenarioInfo.M3PlayerGates)
            gate.ChargeName = name
            gate:SetCustomName(name)
        end
    end


    while true do
        local gates = ScenarioFramework.GetListOfHumanUnits(categories.GATE, 'M3_Build_Area')
        for _, gate in gates do
            if not gate.Dead and not gate:IsBeingBuilt() and not gate.GateChargeThread then
                AddGate(gate)
            end
        end

        WaitSeconds(5)
    end
end

function GetNextGate()
    local mostCharged = false
    for _, gate in ScenarioInfo.M3PlayerGates do
        if gate.GateCharge == 0 then
            return gate, true
        elseif not mostCharged or mostCharged.GateCharge > gate.GateCharge then
            mostCharged = gate
        end
    end

    return mostCharged, false
end

function M3BuildGateReminder1()
    if ScenarioInfo.M3P1_1.Active then
        ScenarioFramework.Dialogue(OpStrings.M3BuildGateReminder1)

        ScenarioFramework.CreateTimerTrigger(M3BuildGateReminder2, 10 * 60)
    end
end

function M3BuildGateReminder2()
    if ScenarioInfo.M3P1_1.Active then
        ScenarioFramework.Dialogue(OpStrings.M3BuildGateReminder2)

        ScenarioFramework.CreateTimerTrigger(M3GameEnderSpiders, 10 * 60)
    end
end

function M3OffMapAttacks()
    if ScenarioInfo.M3OffMapAttacksStarted then
        return
    end
    ScenarioInfo.M3OffMapAttacksStarted = true


end

function M3CheckGates()
    local gate, charged = GetNextGate()
    if not gate then
        -- Build a new gate
        ScenarioFramework.Dialogue(OpStrings['M2GateKilled' .. Random(1, 2)], M3BuildGate, true)
    elseif charged then
        ScenarioInfo.PlayersGate = gate
        ScenarioFramework.Dialogue(OpStrings.M2GateKilled5, M3LeavePlanet, true)
    else
        -- Protect other gate that is charging
        ScenarioFramework.Dialogue(OpStrings['M2GateKilled' .. Random(3, 4)], M3ChargeGate, true)
    end
end

function M3ChargeGate()
    -- Find the gate
    local gate, charged = GetNextGate()
    if charged then
        ScenarioInfo.PlayersGate = gate
        M3LeavePlanet()
        return
    elseif gate then
        ScenarioInfo.PlayersGate = gate
    end

    -- This objective might be assigned again if the gate dies while the player is moving to it, but we don't want to run rest of the logic
    local repeated = ScenarioInfo.M3P2_1

    -----------------------------------------------
    -- Primary Objective - Protect the Quantum Gate
    -----------------------------------------------
    ScenarioInfo.M3P2_1 = Objectives.Protect(
        'primary',
        'incomplete',
        OpStrings.M3P2_1_Title,
        OpStrings.M3P2_1_Description,
        {
            Units = {ScenarioInfo.PlayersGate},
            Timer = ScenarioInfo.PlayersGate.GateCharge,
        }
    )
    ScenarioInfo.M3P2_1:AddResultCallback(
        function(result)
            if result then
                ScenarioFramework.Dialogue(OpStrings.M3GateCharged, M3LeavePlanet, true)
            else
                M3CheckGates()
            end
        end
    )

    ScenarioInfo.PlayersGate:ForkThread(M3GateChargingDialogueThread)

    if repeated then
        return
    end

    -- Some extra attacks
    ScenarioFramework.CreateTimerTrigger(M3SpiderBotsAttack, 5 * 60)
    ScenarioFramework.CreateTimerTrigger(M3MazerACUAttack, 8 * 60)
end

function M3GateChargingDialogueThread(gate)
    -- Dialogues that notify about the progress, triggering every 25% charge, note: it is counting down to 0
    local progressDialogues = {
        OpStrings.M3GateCharging75,
        OpStrings.M3GateCharging50,
        OpStrings.M3GateChargin25,
    }
    for i = 1, 3 do
        progressDialogues[math.floor(GateChargeTimer * i * 0.25)] = progressDialogues[i]
        progressDialogues[i] = nil
    end

    while true do
        if progressDialogues[gate.GateCharge] then
            ScenarioFramework.Dialogue(progressDialogues[gate.GateCharge])
        end

        if gate.GateCharge == 0 then
            return
        end

        WaitSeconds(1)
    end
end

function M3LeavePlanet()
    -- Make new area for the objective
    local posX, posY, posZ = unpack(ScenarioInfo.PlayersGate:GetPosition())
    Scenario.Areas['M3_Gate_Area'] = {
        ['rectangle'] = RECTANGLE(posX - 8, posZ - 8, posX + 8, posZ + 8),
    }

    ScenarioFramework.CreateUnitDestroyedTrigger(M3ChargedGateDies, ScenarioInfo.PlayersGate)

    ---------------------------------------
    -- Primary Objective - Leave the Planet
    ---------------------------------------
    ScenarioInfo.M3P3_1 = Objectives.SpecificUnitsInArea(
        'primary',
        'incomplete',
        OpStrings.M3P3_1_Title,
        OpStrings.M3P3_1_Description,
        {
            Units = ScenarioInfo.PlayersACUs,
            Area = 'M3_Gate_Area',
            MarkArea = true,
        }
    )
    ScenarioInfo.M3P3_1:AddResultCallback(
        function(result)
            if result then
                LeaveCinematics()
            else
                M3CheckGates()
            end
        end
    )
end

function M3ChargedGateDies()
    if ScenarioInfo.M3P3_1.Active then
        ScenarioInfo.M3P3_1:ManualResult(false)
    end
end

function M3PostIntroBuildDialogue()
    ScenarioFramework.Dialogue(OpStrings.M3PostIntroBuild)
end

function M3StartGateChargingAttacks()
    -- Extra attacks to spice things up
end

function M3SpiderBotsAttack()
    -- Randomly spawns Spider Bots, ammout depending on difficulty, and sends them to Player's base
    local quantity = {2, 3, 4}
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
    for i = 1, 4 do
        local ACU = ScenarioFramework.SpawnCommander('QAI', 'M3_ACU_' .. i, false, LOC('{i QAI}'), false, false,
            {'MicrowaveLaserGenerator', 'CoolingUpgrade', 'StealthGenerator', 'CloakingGenerator'})
        ACU:SetAutoOvercharge(true)
        ACU:SetVeterancy(1 + Difficulty)
        ACU:SetProductionPerSecondEnergy(4000)

        local platoon = ArmyBrains[QAI]:MakePlatoon('', '')
        ArmyBrains[QAI]:AssignUnitsToPlatoon(platoon, {ACU}, 'Attack', 'None')
        platoon:AggressiveMoveToLocation(ScenarioUtils.MarkerToPosition('M3_QAI_PlayerBase_Attack_0'))
        ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_Player_Base_Chain')
    end
end

-----------
-- Run away
-----------
function M3UseCharisGate()
    ---------------------------------------
    -- Primary Objective - Leave the Planet
    ---------------------------------------
    ScenarioInfo.M3P1_2 = Objectives.SpecificUnitsInArea(
        'primary',
        'incomplete',
        OpStrings.M3P1_2_Title,
        OpStrings.M3P1_2_Description,
        {
            Units = ScenarioInfo.PlayersACUs,
            Area = 'M3_Gate_Area',
            MarkArea = true,
        }
    )
    ScenarioInfo.M3P1_2:AddResultCallback(
        function(result)
            if result then
                LeaveCinematics()
            end
        end
    )

    -- Bonus objective for lowest player HP
    M3AcuHPObjective()

    -- Trigger for capture science buildings objective
    ScenarioFramework.CreateArmyIntelTrigger(M3CaptureScienceBuildingsObjective, ArmyBrains[Player1], 'LOSNow', false, true, categories.CIVILIAN, true, ArmyBrains[Civilian])

    -- Trigger for killing QAI's ACU objective
    ScenarioFramework.CreateArmyIntelTrigger(M3KillQAIObjective, ArmyBrains[Player1], 'LOSNow', false, true, categories.COMMAND, true, ArmyBrains[QAI])

    -- Charis' dialogue
    ScenarioFramework.CreateTimerTrigger(M3PostIntroPushDialogue, 15)
end

function M3PostIntroPushDialogue()
    ScenarioFramework.Dialogue(OpStrings.M3PostIntroPush)
end

function M3KillQAIObjective()
    ScenarioFramework.Dialogue(OpStrings.M3QAISpotted)

    ---------------------------------------
    -- Primary Objective - Defeat QAI's ACU
    ---------------------------------------
    ScenarioInfo.M3S2_2 = Objectives.Kill(
        'secondary',
        'incomplete',
        OpStrings.M3S2_2_Title,
        OpStrings.M3S2_2_Description,
        {
            Units = {ScenarioInfo.QAIACU},
        }
    )
    ScenarioInfo.M3S2_2:AddResultCallback(
        function(result)
            if result then
                ScenarioFramework.CDRDeathNISCamera(ScenarioInfo.QAIACU, 7)

                ScenarioFramework.Dialogue(OpStrings.M3QAIDefeated)
            end
        end
    )
end

function M3SetUpAttackPing()
    if ScenarioInfo.LoyalistAttackPing then
        return
    end
    ScenarioFramework.Dialogue(OpStrings.M3CharisReadyToAttack, nil, true)
    -- Setup ping
    ScenarioInfo.LoyalistAttackPing = PingGroups.AddPingGroup(OpStrings.M3LoyalistAttackPingTitle, nil, 'attack', OpStrings.M3LoyalistAttackPingDescription)
    ScenarioInfo.LoyalistAttackPing:AddCallback(M3SetNewTarget)

    -- Reminder to start the assault
    ScenarioFramework.CreateTimerTrigger(M3AttackReadyReminder1, 200)
end

local areaDialogueLockValid = false
function M3UnlockValidAreaDialogue()
    areaDialogueLockValid = false
end

local areaDialogueLockInvalid = false
function M3UnlockInvalidAreaDialogue()
    areaDialogueLockInvalid = false
end

function M3SetNewTarget(position, forced)
    if not ScenarioInfo.M3CharisAttackLaunched then
        ScenarioInfo.M3CharisAttackLaunched = true
    end

    local newTarget = false

    -- Only allow setting targets in QAI's main base.
    local rec = ScenarioUtils.AreaToRect('M3_QAI_Main_Base_Area')
    if position[1] > rec.x0 and position[1] < rec.x1 and position[3] > rec.y0 and position[3] < rec.y1 then
        newTarget = position
    end

    if newTarget then
        --LOG('*DEBUG: AttackPing: New target set: ' .. repr(newTarget))

        -- Show the players that the target was set successfully
        print(LOC(OpStrings.M3TargetAreaSet))
        -- Prevent the dialogue spam if clicking like a mad man
        if not areaDialogueLockValid then
            -- If the player waits too long, start the attack anyway.
            if forced then
                ScenarioFramework.Dialogue(OpStrings.M3CharisAttackStart, nil, false, ScenarioInfo.CharisACU)
            else
                ScenarioFramework.Dialogue(OpStrings['M3NewTargetSet' .. Random(1, 2)], nil, false, ScenarioInfo.CharisACU)
            end
            areaDialogueLockValid = true
            ScenarioFramework.CreateTimerTrigger(M3UnlockValidAreaDialogue, 20)
        end

        M3LoyalistAI.SetNewTarget(newTarget)
    else
        -- Gotta click on QAI's base
        print(LOC(OpStrings.M3InvalidAreaSet))
        --LOG('*DEBUG: AttackPing: Ping was not in QAI base area.')

        if not areaDialogueLockInvalid then
            ScenarioFramework.Dialogue(OpStrings.M3InvalidTarget, nil, false, ScenarioInfo.CharisACU)
            areaDialogueLockInvalid = true
            ScenarioFramework.CreateTimerTrigger(M3UnlockInvalidAreaDialogue, 10)
        end
    end
end

function M3AttackReadyReminder1()
    if not ScenarioInfo.M3CharisAttackLaunched then
        ScenarioFramework.Dialogue(OpStrings.M3CharisReadyReminder1)

        ScenarioFramework.CreateTimerTrigger(M3AttackReadyReminder2, 200)
    end
end

function M3AttackReadyReminder2()
    if not ScenarioInfo.M3CharisAttackLaunched then
        ScenarioFramework.Dialogue(OpStrings.M3CharisReadyReminder2)

        ScenarioFramework.CreateTimerTrigger(M3AttackReadyReminder3, 200)
    end
end

function M3AttackReadyReminder3()
    if not ScenarioInfo.M3CharisAttackLaunched then
        ScenarioFramework.Dialogue(OpStrings.M3CharisReadyReminder3)
    end
end

function M3CharisDies()
    if ScenarioInfo.M3P1_2.Active then
        ScenarioInfo.M3P1_2:ManualResult(false)

        ScenarioFramework.CDRDeathNISCamera(ScenarioInfo.CharisACU)

        ScenarioFramework.Dialogue(OpStrings.M3CharisDies, M3DestroyCharisBase, true)
    end
end

function M3DestroyCharisBase()
    ScenarioFramework.Dialogue(OpStrings.PlayerLose, PlayerLose, true)

    for _, unit in ArmyBrains[Loyalist]:GetListOfUnits(categories.ALLUNITS - categories.WALL, false) do
        if not unit.Dead then
            unit:Kill()
            WaitSeconds(Random(0.2, 0.5))
        end
    end

    -- Catch any remaining units that might have just been finished.
    for _, unit in ArmyBrains[Loyalist]:GetListOfUnits(categories.ALLUNITS - categories.WALL, false) do
        if not unit.Dead then
            unit:Kill()
        end
    end
end

-- Makes the platoon to attack nearby experimentals
function PlatoonTargetSpecificUnitWhenClose(platoon)
    local aiBrain = platoon:GetBrain()
    local data = platoon.PlatoonData

    local target = false
    while aiBrain:PlatoonExists(platoon) do
        if not target or target.Dead then
            local unit = platoon:FindClosestUnit('Attack', 'Enemy', true, categories.EXPERIMENTAL)
            if unit and unit ~= target and VDist3(unit:GetPosition(), platoon:GetPlatoonPosition()) < 50 then
                target = unit
                platoon:Stop()
                platoon:AttackTarget(unit)

                if data.TargetMarker then
                    platoon:AggressiveMoveToLocation(ScenarioUtils.MarkerToPosition(data.TargetMarker))
                elseif data.PatrolChain then
                    ScenarioFramework.PlatoonPatrolChain(platoon, data.PatrolChain)
                else
                    target = platoon:FindClosestUnit('Attack', 'Enemy', true, categories.ALLUNITS - categories.WALL)
                end
            end
        end

        WaitSeconds(5)
    end
end

-- Main attack at the Loyalist base
function QAIExperimentalAttack(platoon)
    local data = platoon.PlatoonData

    if not ScenarioInfo.M3CharisAttackLaunched then
        ScenarioFramework.Dialogue(OpStrings.M3CharisAttackStart)

        -- If the player waits too long, start the attack anyway.
        M3SetNewTarget(ScenarioUtils.MarkerToPosition('M3_Loyalist_Forced_Attack_Target'), true)
    end

    ScenarioPlatoonAI.PlatoonEnableStealth(platoon)
    platoon:ForkThread(PlatoonTargetSpecificUnitWhenClose)

    ForkThread(DispatchASFs, ScenarioUtils.MarkerToPosition(data.TargetMarker))

    ScenarioFramework.PlatoonAttackChain(platoon, data.AttackChain)

    ScenarioFramework.CreateTimerTrigger(M3GameEnderSpiders, 120)
end

-- Grab any ASFs patrolling over the plateau and send them to clear the way
function DispatchASFs(position)
    WaitSeconds(20)
    local units = ScenarioFramework.GetCatUnitsInArea(categories.AIR * categories.ANTIAIR * categories.TECH3, 'M3_Plateau_Area', ArmyBrains[QAI])

    if units[1] then
        IssueClearCommands(units)
        IssueAggressiveMove(units, position)
    end
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
        function(result, capturedUnits)
            if result then
                -- Make QAI not target the civ buildings
                for _, unit in capturedUnits do
                    if not unit.Dead then
                        unit:SetDoNotTarget(true)
                    end
                end

                ScenarioFramework.Dialogue(OpStrings.M3ScienceFacilityCaptured)
                ScenarioFramework.CreateTimerTrigger(M3BonusIntel, 60)
            else
                ScenarioFramework.Dialogue(OpStrings.M3ScienceFacilityDead)
            end
        end
    )
end

function M3BonusIntel()
    if ScenarioInfo.M3PlayersPlan == 'build' then
    else
        -- Show player all experimeeentals in QAI's base
        ScenarioFramework.Dialogue(OpStrings.M3ExtraIntelPush)

        for _, unit in ScenarioFramework.GetCatUnitsInArea(categories.EXPERIMENTAL, 'M3_QAI_Main_Base_Area', ArmyBrains[QAI]) do
            local VizMarker = ScenarioFramework.CreateVisibleAreaAtUnit(6, unit, -1, ArmyBrains[Player1])
            unit.Trash:Add(VizMarker)
            VizMarker:AttachBoneTo(-1, unit, -1)
        end
    end
end

function M3GameEnderSpiders()
    -- Inform the player about the attack, different dialogue if the players are in the starting area.
    if ScenarioFramework.GetNumOfHumanUnits(categories.COMMAND, 'M2_Area') > 0 then
        ScenarioFramework.Dialogue(OpStrings.M3GameEnderDialogue1, nil, true)
    else
        ScenarioFramework.Dialogue(OpStrings.M3GameEnderDialogue2, nil, true)
    end

    -- Spiders coming from offmap, attacking the players' starting location and then hunting down the ACUs.
    for i = 1, 6 do
        local spiders = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'QAI_M3_End_Spider_' .. i, 'AttackFormation')
        local spider = spiders:GetPlatoonUnits()[1]
        if not spiders.PlatoonData then
            spiders.PlatoonData = {}
        end
        spiders.PlatoonData.AttackRoute = {
            'M3_QAI_GameEnd_Attack_' .. i,
        }
        spiders:ForkAIThread(M3QAIAI.AttackThenHunt)

        -- Some AA to guards the spiders
        local support = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'QAI_M3_End_Spider_Support_' .. i, 'AttackFormation')
        support:GuardTarget(spider)
        if ScenarioInfo.M3PlayersPlan == 'push' then
            support:AggressiveMoveToLocation(ScenarioUtils.MarkerToPosition('M3_QAI_Experimental_Attack_Target'))
        end

        -- Soul rippers
        local gunships = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'QAI_M3_End_Spider_Support_Gunships', 'AttackFormation')
        ScenarioPlatoonAI.PlatoonEnableStealth(gunships)
        local gunship = gunships:GetPlatoonUnits()[1]
        -- Guard the spider, then attack loyalist base
        gunships:GuardTarget(spider)
        if ScenarioInfo.M3PlayersPlan == 'push' then
            gunships:AggressiveMoveToLocation(ScenarioUtils.MarkerToPosition('M3_QAI_Experimental_Attack_Target'))
        else
            for _, ACU in ScenarioInfo.PlayersACUs do
                if not ACU.Dead then
                    gunships:AttackTarget(ACU)
                end
            end
        end

        -- Guard the soul ripper, then spider, then attack loyalist base
        local ASFs = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'QAI_M3_End_Spider_Support_ASFs', 'AttackFormation')
        ScenarioPlatoonAI.PlatoonEnableStealth(ASFs)
        ASFs:GuardTarget(gunship)
        ASFs:GuardTarget(spider)
        if ScenarioInfo.M3PlayersPlan == 'push' then
            ASFs:AggressiveMoveToLocation(ScenarioUtils.MarkerToPosition('M3_QAI_Experimental_Attack_Target'))
        end
    end
end

function M3AcuHPObjective()
    ---------------------------
    -- Bonus Objective - ACU HP
    ---------------------------
    ScenarioInfo.M3B1 = Objectives.Basic(
        'bonus',
        'incomplete',
        OpStrings.M3B1Title,
        OpStrings.M3B1Description,
        Objectives.GetActionIcon('protect'),
        {
            Hidden = true,
        }
    )

    ForkThread(PlayersACUsHealthMonitor, PlayerHPObjectiveTreshold)
end

function PlayersACUsHealthMonitor(minHP)
    local treshold = minHP
    local targetList = {}

    for _, index in ScenarioInfo.HumanPlayers do
        local brain = ArmyBrains[index]
        local unit = brain:GetListOfUnits(categories.COMMAND, false)[1]
        if unit then
            targetList[brain] = unit
        end
    end

    -- If HP of any of the players' ACU drop below set treshold, fail the objective
    while ScenarioInfo.M3B1.Active do
        for brain, unit in targetList do
            if brain:GetUnitStat(unit.UnitId, "lowest_health") < treshold then
                ScenarioInfo.M3B1:ManualResult(false)
                return
            end
        end

        WaitSeconds(5)
    end
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
---[[
function OnCtrlF3()
    M3GameEnderSpiders()
end

function OnCtrlF4()
    for _, v in ArmyBrains[QAI]:GetListOfUnits(categories.ALLUNITS - categories.WALL, false) do
        v:Kill()
    end
end

function OnShiftF3()
    M3SpiderBotsAttack()
end

function OnShiftF4()
    M3MazerACUAttack()
end
--]]

