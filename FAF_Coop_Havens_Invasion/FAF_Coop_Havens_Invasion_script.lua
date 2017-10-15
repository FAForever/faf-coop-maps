-----------------------------------
-- Custom mission: Haven's Invasion
--
-- Author: speed2
-----------------------------------
local Cinematics = import('/lua/cinematics.lua')
local M1UEFAI = import('/maps/FAF_Coop_Havens_Invasion/FAF_Coop_Havens_Invasion_m1uefai.lua')
local M2UEFAI = import('/maps/FAF_Coop_Havens_Invasion/FAF_Coop_Havens_Invasion_m2uefai.lua')
local Objectives = import('/lua/SimObjectives.lua')
local OpStrings = import ('/maps/FAF_Coop_Havens_Invasion/FAF_Coop_Havens_Invasion_strings.lua')
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local TauntManager = import('/lua/TauntManager.lua')

----------
-- Globals
----------
ScenarioInfo.Player1 = 1
ScenarioInfo.UEF = 2
ScenarioInfo.Seraphim = 3
ScenarioInfo.Civilian = 4

---------
-- Locals
---------
local Player1 = ScenarioInfo.Player1
local UEF = ScenarioInfo.UEF
local Seraphim = ScenarioInfo.Seraphim
local Civilian = ScenarioInfo.Civilian

local Difficulty = ScenarioInfo.Options.Difficulty
local AssignedObjectives = {}

local LeaderFaction
local LocalFaction

-------------
-- Debug Only
-------------
local SkipM1NIS = false
local SkipM2NIS = false

-----------------
-- Taunt Managers
-----------------
local UEFTM = TauntManager.CreateTauntManager('UEFTM', '/maps/FAF_Coop_Havens_Invasion/FAF_Coop_Havens_Invasion_strings.lua')

-----------
-- Start up
-----------
function OnPopulate(scenario)
    ScenarioUtils.InitializeScenarioArmies()
    LeaderFaction, LocalFaction = ScenarioFramework.GetLeaderAndLocalFactions()

    FixProps() -- Spawns trees properly
    FlattenMapRect(367, 220, 1, 1, 20) -- Fixes the unwanted passage into the water from the cliff where it should not be possible

    ---------
    -- UEF AI
    ---------
    M1UEFAI.UEFM1BaseAI()

    -- South PDs
    local units = ScenarioUtils.CreateArmyGroup('UEF', 'M1_Extra_Defense_D' .. Difficulty)
    ScenarioFramework.CreateGroupDeathTrigger(M1EvacTrucks, units) -- Move the trucks away when the PDs are destroyed

    ScenarioUtils.CreateArmyGroup('UEF', 'M1_Extra_Resources')

    -- Walls
    ScenarioUtils.CreateArmyGroup('UEF', 'M1_Walls_D' .. Difficulty)

    -- Patrols
    -- Land in the base
    local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M1_UEF_Base_Land_Patrol_D' .. Difficulty, 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M1_UEF_Base_Land_Patrol_Chain')

    -- T1 Arty moves to the ledge
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M1_UEF_Mobile_Arty_D' .. Difficulty, 'NoFormation')
    for k, v in platoon:GetPlatoonUnits() do
        IssueMove({v}, ScenarioUtils.MarkerToPosition('M1_UEF_Arty_Marker_' .. k))
    end

    -- Mongoose patrol
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M1_UEF_Mongoose_Patrol_D' .. Difficulty, 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M1_UEF_Mongoose_Patrol_Chain')

    -----------
    -- Civilian
    -----------
    -- City
    ScenarioUtils.CreateArmyGroup('Civilian', 'M1_Buildings')

    -- Trucks
    ScenarioInfo.M1CivilianTrucks = ScenarioUtils.CreateArmyGroup('Civilian', 'M1_Trucks')

    -- Walls
    ScenarioUtils.CreateArmyGroup('Civilian', 'M1_Walls')
end

function OnStart(scenario)
    -- Unit and upgade restrictions
    ScenarioFramework.AddRestrictionForAllHumans(
        categories.TECH2 +
        categories.TECH3 +
        categories.EXPERIMENTAL -
        categories.xsb1202 -- Sera T2 mex
        -- categories.ueb1202   -- UEF T2 mex
    ) 

    ScenarioFramework.RestrictEnhancements({
        'AdvancedEngineering',
        'T3Engineering',
        'RateOfFire', -- Gun
        'BlastAttack', -- Splash Gun
        --'RegenAura',
        'AdvancedRegenAura',
        'DamageStabilization', -- Nano
        'DamageStabilizationAdvanced',
        'Missile',
        'ResourceAllocation',
        'ResourceAllocationAdvanced',
        'Teleporter',
    })

    -- Colors
    ScenarioFramework.SetSeraphimColor(Player1)
    ScenarioFramework.SetUEFPlayerColor(UEF)
    SetArmyColor(Seraphim, 255, 200, 0)
    ScenarioFramework.SetUEFAlly2Color(Civilian)

    -- Set the maximum number of units that the players is allowed to have
    ScenarioFramework.SetSharedUnitCap(300)

    -- Set playable area
    ScenarioFramework.SetPlayableArea('M1_Area', false)
    ForkThread(IntroMission1NIS)
end

-----------
-- End Game
-----------
function PlayerWins()
    if not ScenarioInfo.OpEnded then
        -- Turn everything neutral; protect the player commander
        ScenarioFramework.EndOperationSafety()

        ScenarioInfo.OpComplete = true

        -- Final dialogue
        ScenarioFramework.Dialogue(OpStrings.PlayerWins, KillGame, true)
    end
end

function PlayerDeath(commander)
    ScenarioFramework.PlayerDeath(commander, OpStrings.PlayerDies)
end

function KillGame()
    local bonus = Objectives.IsComplete(ScenarioInfo.M1B1) 
    --local secondary = Objectives.IsComplete(ScenarioInfo.M1S1Objective)
    ScenarioFramework.EndOperation(ScenarioInfo.OpComplete, ScenarioInfo.OpComplete, false, bonus)
end

------------
-- Mission 1
------------
function IntroMission1NIS()
    if not SkipM1NIS then
        Cinematics.EnterNISMode()

        local VizMarker = ScenarioFramework.CreateVisibleAreaLocation(10, ScenarioUtils.MarkerToPosition('M1_Viz_Marker_1'), 0, ArmyBrains[Player1])

        Cinematics.CameraMoveToMarker('Cam_1_1', 0)
        WaitSeconds(1)

        -- Destroy the UEF stuff
        ScenarioFramework.Dialogue(OpStrings.M1Intro1, nil, true)
        WaitSeconds(5)

        Cinematics.CameraMoveToMarker('Cam_1_2', 4)

        -- Surprise UEF Base
        ScenarioFramework.Dialogue(OpStrings.M1Intro2, nil, true)

        ScenarioInfo.Player1CDR = ScenarioFramework.SpawnCommander('Player1', 'Commander', 'Warp', true, true, PlayerDeath)

        WaitSeconds(3)

        VizMarker:Destroy()

        Cinematics.ExitNISMode()
    else
        ScenarioInfo.Player1CDR = ScenarioFramework.SpawnCommander('Player1', 'Commander', 'Warp', true, true, PlayerDeath)
    end

    IntroMission1()
end

function IntroMission1()
    ScenarioInfo.MissionNumber = 1

    -- Resources for AI
    ArmyBrains[Civilian]:GiveStorage('ENERGY', 5000)
    ArmyBrains[Civilian]:GiveResource('ENERGY', 5000)

    ArmyBrains[UEF]:GiveResource('MASS', 900)
    ArmyBrains[UEF]:GiveResource('ENERGY', 6000)

    StartMission1()
end

function StartMission1()
    ------------------------------------------------------
    -- Primary Objective - Destroy Administrative Building
    ------------------------------------------------------
    ScenarioInfo.M1P1 = Objectives.Kill(
        'primary',
        'incomplete',
        OpStrings.M1P1Title,
        OpStrings.M1P1Description,
        {
            Units = {ScenarioInfo.UnitNames[Civilian]['M1_Administrative_Building']},
        }
    )
    ScenarioInfo.M1P1:AddResultCallback(
        function(result)
            if result then
                -- Move trucks off map if they are still near the building
                M1EvacTrucks()

                ScenarioFramework.Dialogue(OpStrings.M1UEFBuildingDestroyed, IntroMission2, true)
            end
        end
    )

    -----------------------------------------
    -- Bonus Objective - Kill Civilian Trucks
    -----------------------------------------
    ScenarioInfo.M1B1 = Objectives.Kill(
        'bonus',
        'incomplete',
        OpStrings.M1B1Title,
        OpStrings.M1B1Description,
        {
            Units = ScenarioInfo.M1CivilianTrucks,
            MarkUnits = false,
            Hidden = true,
        }
    )
    ScenarioInfo.M1B1:AddResultCallback(
        function(result)
            if result then
                ScenarioFramework.Dialogue(OpStrings.M1TrucksDestroyed)
            end
        end
    )

    -- Taunts
    SetupUEFM1TauntTriggers()

    -- Annnounce the mission name after few seconds
    ScenarioFramework.CreateTimerTrigger(MissionNameAnnouncement, 4)

    -- Drop reinforcements to the player
    ScenarioFramework.CreateTimerTrigger(M1Reinforcements, 8)

    -- Dialogue when the UEF base is destroyed
    local units = ScenarioFramework.GetCatUnitsInArea(categories.STRUCTURE - categories.WALL, 'M1_UEF_Base_Area', ArmyBrains[UEF])
    ScenarioFramework.CreateGroupDeathTrigger(M1UEFBaseDestroyed, units)

    -- Reminder to finish objective
    ScenarioFramework.CreateTimerTrigger(M1Reminder, 4*60)

    -- Evac the trucks after 5 minues
    ScenarioFramework.CreateTimerTrigger(M1EvacTrucks, 5*60)

    -- Expand the map after 6 minues
    ScenarioFramework.CreateTimerTrigger(M1MapExpand, 6*60)
end

function MissionNameAnnouncement()
    ScenarioFramework.SimAnnouncement(OpStrings.OPERATION_NAME, 'mission by [e]speed2')
end

function M1Reinforcements()
    local function SendReinforcements()
        local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M1_Reinforcements_D' .. Difficulty, 'GrowthFormation')
        local units = {}
        local transports = {}

        for _, v in platoon:GetPlatoonUnits() do
            if EntityCategoryContains(categories.TRANSPORTATION, v) then
                table.insert(transports, v)
            else
                table.insert(units, v)
            end
        end

        -- Load the units
        ScenarioFramework.AttachUnitsToTransports(units, transports)

        -- Drop the units and fly back to off map
        IssueTransportUnload(transports, ScenarioUtils.MarkerToPosition('M1_Drop_Marker'))
        IssueMove(transports, ScenarioUtils.MarkerToPosition('M1_Transport_Marker'))

        -- After drop, give the units to the Player
        local givenUnits = {}
        for _, v in units do
            while v:IsUnitState('Attached') do
                WaitSeconds(2)
            end
            local unit = ScenarioFramework.GiveUnitToArmy(v, Player1)
            table.insert(givenUnits, unit)
        end

        -- Destroy the transports once off map
        for _, v in transports do
            ScenarioFramework.CreateUnitToMarkerDistanceTrigger(DestroyUnit, v, 'M1_Transport_Marker', 10)
        end

        IssueFormMove(givenUnits, ScenarioUtils.MarkerToPosition('M1_Drop_Units_Move_Marker'), 'AttackFormation', 0)
    end

    -- Play the dialogue first, then send the untis
    ScenarioFramework.Dialogue(OpStrings.M1Reinforcements, SendReinforcements)
end

function M1UEFBaseDestroyed()
    ScenarioFramework.Dialogue(OpStrings.M1UEFBaseDestroyed)
end

function M1EvacTrucks()
    -- The trucks start moving when the 3 PDs are killed, the objective building is killed or after 5 minutes
    if ScenarioInfo.M1TruckEvacStarted then
        return
    end
    ScenarioInfo.M1TruckEvacStarted = true

    -- UEF dialogue
    ScenarioFramework.Dialogue(OpStrings.M1TruckEvac)

    -- Move the trucks off map
    ScenarioFramework.GroupMoveChain(ScenarioInfo.M1CivilianTrucks, 'M1_Trucks_Escape_Chain')

    -- Destroy the trucks off map and mark bonus obj as failed
    for _, v in ScenarioInfo.M1CivilianTrucks do
        ScenarioFramework.CreateUnitToMarkerDistanceTrigger(M1TruckEscaped, v, 'M1_Trucks_Escape_1', 5)
    end
end

function M1TruckEscaped(unit)
    DestroyUnit(unit)

    -- Objectrive to destroy trucks failed
    if ScenarioInfo.M1B1.Active then
        ScenarioInfo.M1B1:ManualResult(false)
    end
end

function M1MapExpand()
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

    if ScenarioInfo.MissionNumber ~= 1 then
        return
    end
    ScenarioInfo.MissionNumber = 2

    -- Allow gun and advanced regen aura upgrades
    ScenarioFramework.RestrictEnhancements({
        'AdvancedEngineering',
        'T3Engineering',
        --'RateOfFire', -- Gun
        'BlastAttack', -- Splash Gun
        --'RegenAura',
        --'AdvancedRegenAura',
        'DamageStabilization', -- Nano
        'DamageStabilizationAdvanced',
        'Missile',
        'ResourceAllocation',
        'ResourceAllocationAdvanced',
        'Teleporter',
    })

    -- Set the maximum number of units that the players is allowed to have
    ScenarioFramework.SetSharedUnitCap(500)

    ---------
    -- UEF AI
    ---------
    M2UEFAI.UEFM2BaseAI()
    M2UEFAI.UEFM2AirBaseAI()

    ScenarioFramework.RefreshRestrictions('UEF')

    ScenarioUtils.CreateArmyGroup('UEF', 'M2_Extra_Resources')

    -- Extra defenses
    ScenarioUtils.CreateArmyGroup('UEF', 'M2_Middle_Pass_Defense_D' .. Difficulty)
    ScenarioUtils.CreateArmyGroup('UEF', 'M2_West_Island_Defense_D' .. Difficulty)

    -- Walls
    ScenarioUtils.CreateArmyGroup('UEF', 'M2_Walls_D' .. Difficulty)

    -- UEC ACU, more upgrades on higher difficulty, enable auto OC
    local upgrades = {
        {'LeftPod', 'RightPod'},
        {'LeftPod', 'RightPod', 'HeavyAntiMatterCannon'},
        {'LeftPod', 'RightPod', 'HeavyAntiMatterCannon', 'DamageStabilization'},
    }
    ScenarioInfo.UEF_ACU = ScenarioFramework.SpawnCommander('UEF', 'UEF_ACU', false, 'UEF ACU', false, false, upgrades[Difficulty])
    ScenarioInfo.UEF_ACU:SetAutoOvercharge(true)
    -- Restrict building Naval factory, Torp def, AA and sonar
    ScenarioInfo.UEF_ACU:AddBuildRestriction(categories.ueb0103 + categories.ueb2104 + categories.ueb2109 + categories.ueb3102)

    -- Engineer that will start building the air base
    ScenarioUtils.CreateArmyUnit('UEF', 'M2_Air_Base_Engineer')

    -- Patrols
    -- Middle naval patrol
    local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M2_Init_Middle_Naval_Patrol_D' .. Difficulty, 'NoFormation')
    for _, v in platoon:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolChain({v}, 'M2_UEF_Naval_Middle_Patrol_Chain')
    end

    -- Submarine patrol
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M2_Submarine_Patrol_D' .. Difficulty, 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M2_UEF_Submarine_Patrol_Chain')

    -- Main base air patrol
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M2_Init_Base_Air_Patrol_D' .. Difficulty, 'NoFormation')
    for _, v in platoon:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolChain({v}, 'M2_UEF_Base_Air_Patrol_Chain')
    end

    -- Main base land patrol east
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M2_Init_Base_Land_Patrol_East', 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M2_Init_Base_Land_Patrol_East_Chain')

    -- Main base Mongoose patrol
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M2_Init_Base_Mongoose_Patrol_D' .. Difficulty, 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M2_Init_Base_Mongoose_Patrol_Chain')

    -- Main base AA, not patrolling
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M2_Init_Base_AA_D' .. Difficulty, 'AttackFormation')

    -----------
    -- Civilian
    -----------
    -- City
    ScenarioInfo.M2UEFCity = ScenarioUtils.CreateArmyGroup('Civilian', 'M2_Buildings')

    -- Trucks
    ScenarioInfo.M2CivilianTrucks = ScenarioUtils.CreateArmyGroup('Civilian', 'M2_Trucks')

    -- Walls
    ScenarioUtils.CreateArmyGroup('Civilian', 'M2_Walls')

    -- Resources for AI
    ArmyBrains[UEF]:GiveResource('MASS', 4000)
    ArmyBrains[UEF]:GiveResource('ENERGY', 20000)

    ForkThread(IntroMission2NIS)
end

function IntroMission2NIS()
    -- Playable area
    ScenarioFramework.SetPlayableArea('M2_Area')

    if not SkipM2NIS then
        Cinematics.EnterNISMode()
        Cinematics.SetInvincible('M2_Area')

        local VizMarker1 = ScenarioFramework.CreateVisibleAreaLocation(10, ScenarioUtils.MarkerToPosition('M2_Viz_Marker_1'), 0, ArmyBrains[Player1])
        local VizMarker2 = ScenarioFramework.CreateVisibleAreaLocation(35, ScenarioUtils.MarkerToPosition('M2_Viz_Marker_2'), 0, ArmyBrains[Player1])
        local VizMarker3 = ScenarioFramework.CreateVisibleAreaLocation(30, ScenarioUtils.MarkerToPosition('M2_Viz_Marker_3'), 0, ArmyBrains[Player1])

        WaitSeconds(1)

        ScenarioFramework.Dialogue(OpStrings.M2Intro1, nil, true)

        Cinematics.CameraMoveToMarker('Cam_2_1', 2)

        WaitSeconds(2)

        ScenarioFramework.Dialogue(OpStrings.M2Intro2, nil, true)

        Cinematics.CameraMoveToMarker('Cam_2_2', 5)

        WaitSeconds(2)

        ScenarioFramework.Dialogue(OpStrings.M2Intro3, nil, true)

        Cinematics.CameraMoveToMarker('Cam_2_3', 3)

        WaitSeconds(2)

        Cinematics.CameraMoveToMarker('Cam_2_4', 4)

        WaitSeconds(3)

        VizMarker1:Destroy()        
        VizMarker2:Destroy()
        VizMarker3:Destroy()

        Cinematics.SetInvincible('M2_Area', true)
        Cinematics.ExitNISMode()
    end

    StartMission2()
end

function StartMission2()
    ScenarioInfo.M2ObjectiveGroup = Objectives.CreateGroup('Mission 2 Objectives', PlayerWins, 2)

    -----------------------------------
    -- Primary Objective - Kill UEF ACU
    -----------------------------------
    ScenarioInfo.M2P1 = Objectives.Kill(
        'primary',
        'incomplete',
        OpStrings.M2P1Title,
        OpStrings.M2P1Description,
        {
            Units = {ScenarioInfo.UEF_ACU},
            FlashVisible = true,
        }
    )
    ScenarioInfo.M2P1:AddResultCallback(
        function(result, unit)
            if result then
                if ScenarioInfo.M2P2.Active then
                    ScenarioFramework.Dialogue(OpStrings.M2UEFCommanderDead1, nil, true)
                else
                    ScenarioFramework.Dialogue(OpStrings.M2UEFCommanderDead2, nil, true)
                end
            end
        end
    )
    ScenarioInfo.M2ObjectiveGroup:AddObjective(ScenarioInfo.M2P1)

    ---------------------------------------
    -- Primary Objective - Destroy UEF City
    ---------------------------------------
    ScenarioInfo.M2P2 = Objectives.Kill(
        'primary',
        'incomplete',
        OpStrings.M2P2Title,
        OpStrings.M2P2Description,
        {
            Units = ScenarioInfo.M2UEFCity,
        }
    )
    ScenarioInfo.M2P2:AddResultCallback(
        function(result, unit)
            if result then
                if ScenarioInfo.M2P1.Active then
                    ScenarioFramework.Dialogue(OpStrings.M2UEFCityDestroyed1, nil, true)
                else
                    ScenarioFramework.Dialogue(OpStrings.M2UEFCityDestroyed2, nil, true)
                end
            end
        end
    )
    ScenarioInfo.M2ObjectiveGroup:AddObjective(ScenarioInfo.M2P2)

    -- Reminder
    ScenarioFramework.CreateTimerTrigger(M2Reminder1, 15*60)

    -- Taunts
    SetupUEFM2TauntTriggers()

    -- Send engineers to build a proxy naval base
    if Difficulty >= 2 then
        ScenarioFramework.CreateTimerTrigger(M2UEFAI.UEFM2NavalBaseAI, 6*60)
    end

    -- Start sending offmap attacks
    --ForkThread(M2OffMapAttackThread)
end

function M2OffMapAttackThread()
    local attackGroups = {
        'M2_Offmap_Tanks',
        'M2_Offmap_Arty',
        'M2_Offmap_Mongoose',
        --'M2_Offmap_AA',
    }
    attackGroups.num = table.getn(attackGroups)

    while not ScenarioInfo.OpEnded do
        local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', attackGroups[Random(1, attackGroups.num)] .. '_D' .. Difficulty, 'GrowthFormation')
        ScenarioFramework.PlatoonPatrolChain(platoon, 'M2_UEF_Offmap_Attack_Chain_' .. Random(1, 2))

        WaitSeconds(Random(50, 110))
    end
end

-------------------
-- Custom Functions
-------------------
function DestroyUnit(unit)
    unit:Destroy()
end

function FixProps()
    -- The original Haven's Reef map doesn't have tree props on the right side of the map.
    -- It requires much less data to spawn them via script rather than using the fixed version of the map.
    -- Also the minimap is showing water with blue colour (which I prefer).

    -- Table of IDs and positions of all trees
    local fixedPropsTable = import('/maps/FAF_Coop_Havens_Invasion/FAF_Coop_Havens_Invasion_props.lua').Props

    -- Blueprints of props we want to delete from the map
    local bpsToDelete = {
        ['/env/lava/props/trees/groups/dead01_group1_prop.bp'] = true,
        ['/env/lava/props/trees/groups/dead01_group2_prop.bp'] = true,
        ['/env/lava/props/trees/lv_dead01_s1_prop.bp'] = true,
        ['/env/lava/props/trees/xdead01_s1_prop.bp'] = true,
        ['/env/lava/props/trees/xdead01_s2_prop.bp'] = true,
        ['/env/lava/props/trees/xdead01_s3_prop.bp'] = true,
    }

    -- Delete all the tree props on the map to avoid duplicates
    local props = GetReclaimablesInRect(ScenarioUtils.AreaToRect('M2_Area'))
    for _, v in props do
        local ID = v:GetBlueprint().BlueprintId
        if bpsToDelete[ID] then
            v:Destroy()
        end
    end

    -- Create new props
    for _, v in fixedPropsTable do
        CreateProp(v.Position, v.ID)
    end
end

------------
-- Reminders
------------
function M1Reminder()
    if ScenarioInfo.M1P1.Active then
        ScenarioFramework.Dialogue(OpStrings.M1Reminder)
    end
end

function M2Reminder1()
    if ScenarioInfo.M2P1.Active and ScenarioInfo.M2P2.Active then
        ScenarioFramework.Dialogue(OpStrings.M2ReminderBoth)

        ScenarioFramework.CreateTimerTrigger(M2Reminder2, 15*60)
    else
        M2Reminder2()
    end
end

function M2Reminder2()
    if ScenarioInfo.M2P1.Active then
        ScenarioFramework.Dialogue(OpStrings['M2ReminderACU' .. Random(1, 2)])
    elseif ScenarioInfo.M2P2.Active then
        ScenarioFramework.Dialogue(OpStrings['M2ReminderCity' .. Random(1, 2)])
    else
        return
    end
    ScenarioFramework.CreateTimerTrigger(M2Reminder2, 15*60)
end

---------
-- Taunts
---------
function SetupUEFM1TauntTriggers()
    UEFTM:AddUnitsKilledTaunt('TAUNT1', ArmyBrains[UEF], categories.STRUCTURE, 10)
end

function SetupUEFM2TauntTriggers()
    UEFTM:AddTauntingCharacter(ScenarioInfo.UEF_ACU)

    UEFTM:AddEnemiesKilledTaunt('TAUNT4', ArmyBrains[UEF], categories.STRUCTURE, 10)
    UEFTM:AddEnemiesKilledTaunt('TAUNT5', ArmyBrains[UEF], categories.MOBILE - categories.ENGINEER, 60)
    UEFTM:AddUnitsKilledTaunt('TAUNT6', ArmyBrains[UEF], categories.STRUCTURE * categories.ECONOMIC, 14)

    -- At 50% health
    UEFTM:AddDamageTaunt('TAUNT7', ScenarioInfo.UEF_ACU, .5)

    -- Player CDR is damaged
    UEFTM:AddDamageTaunt('TAUNT2', ScenarioInfo.Player1CDR, .5)
    UEFTM:AddDamageTaunt('TAUNT3', ScenarioInfo.Player1CDR, .8)
end

