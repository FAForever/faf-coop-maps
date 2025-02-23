--****************************************************************************
--**
--**  File     :  /maps/JJ_Rescue/op_rescue_script.lua
--**  Author(s):  JJs_AI
--**
--**  Summary  :  A cheeky idea I had.
--**
--****************************************************************************

local Objectives = import('/lua/SimObjectives.lua')
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local Cinematics = import('/lua/cinematics.lua')
local TauntManager = import('/lua/TauntManager.lua')
local PingGroups = import('/lua/ScenarioFramework.lua').PingGroups
local OpStrings = import('/maps/FAF_Coop_Operation_Rescue/FAF_Coop_Operation_Rescue_strings.lua')

----------
-- AI
----------
local M1CivAI = import('/maps/FAF_Coop_Operation_Rescue/M1_UEF_Settlement_AI.lua')
local M2CybranJammerAI_1 = import('/maps/FAF_Coop_Operation_Rescue/M2_Cybran_Jammer_1_AI.lua')
local M2CybranJammerAI_2 = import('/maps/FAF_Coop_Operation_Rescue/M2_Cybran_Jammer_2_AI.lua')
local M3CybranMainAI_1 = import('/maps/FAF_Coop_Operation_Rescue/M3_Cybran_Base_1_AI.lua')
local M3_Rescue_AI = import('/maps/FAF_Coop_Operation_Rescue/M3_Rescue_AI.lua')

----------
-- Units and Teams
----------
ScenarioInfo.Player1 = 1
ScenarioInfo.Cybran = 2
ScenarioInfo.UEF = 3
ScenarioInfo.Player2 = 4
ScenarioInfo.Player3 = 5
ScenarioInfo.Player4 = 6

local Player1 = ScenarioInfo.Player1
local Cybran = ScenarioInfo.Cybran
local UEF = ScenarioInfo.UEF
local Player2 = ScenarioInfo.Player2
local Player3 = ScenarioInfo.Player3
local Player4 = ScenarioInfo.Player4

local Difficulty = ScenarioInfo.Options.Difficulty

AssignedObjectives = {}

local debug = false

----------
-- Ints
----------
local TruckSpawner = 1
local DeadTrucks = 0
local CAttacks = 1
local TrucksAtDest = 0
local DeadTransports = 0
local DeadEngineers = 0
local M3CAttacks = 1
local MaxTrucks = 10
local RequiredTrucks = {6, 6, 6}

----------
-- Bools
----------
local TrucksAttacked = false
local JammerSpotted = false
local CommsRestored = false -- Used for details. I want multiple death messages.
local CybTeleportedToPlayer = false
local FacilitySpotted = false
local AllTrucksAlive = false

----------------
-- Timers
----------------
local PatrolTimer = {300, 250, 200}
local EvacTimer = {350, 300, 250}
local TruckTimer = {60, 100, 120}
local OffMapAttackTimer = {200, 150, 100}
local CybranTeleportTimer = {250, 200, 150}
local M2P3Timer = {1500, 1350, 1200}
local M3OffMapAttackTimer = {120, 90, 60}
  
function OnPopulate()
    ScenarioUtils.InitializeScenarioArmies()
    ScenarioFramework.SetPlayableArea('M1', false)

    -- Set Unit Cap
    ScenarioFramework.SetSharedUnitCap(1000)

    -- Set Army Colours
    ScenarioFramework.SetUEFColor(Player1)
    ScenarioFramework.SetUEFAllyColor(UEF)
    ScenarioFramework.SetCybranEvilColor(Cybran)

    -- Coop Colours
    local colors = {
        ['Player2'] = {255, 255, 255}, 
        ['Player3'] = {250, 250, 0}, 
        ['Player4'] = {97, 109, 126}
    }
    local tblArmy = ListArmies()
    for army, color in colors do
        if tblArmy[ScenarioInfo[army]] then
            ScenarioFramework.SetArmyColor(ScenarioInfo[army], unpack(color))
        end
    end
end
   
function OnStart(self)
    tblArmy = ListArmies()

    -- Call AI
    M1CivAI:UEFAI()

    GetArmyBrain(UEF):SetResourceSharing(false)

    -- Spawn Units on Start --
    ScenarioInfo.Science = ScenarioInfo.UnitNames[UEF]['Science']
    ScenarioUtils.CreateArmyGroup('UEF', 'Economy')
    ScenarioInfo.CybPat1 = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'Init_Pat_1', 'GrowthFormation')
    ScenarioInfo.CybPat2 = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'Init_Pat_2', 'GrowthFormation')
    ScenarioInfo.CybPatAir = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'Init_Pat_Air', 'GrowthFormation')

    ScenarioInfo.Science:SetCustomName("Science Facility")

    ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.CybPat1, 'Cybran_Patrol_Route_1')
    ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.CybPat2, 'Cybran_Patrol_Route_2')
    ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.CybPatAir, 'Cybran_Air_Patrol')

    -- Call Functions for M1
    ForkThread(Intro_Mission_1)
end

-- Mission 1 --

function Intro_Mission_1()
    Cinematics.EnterNISMode()
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cutscene_01a'), 2)
    WaitSeconds(2)
    Cinematics.ExitNISMode()

    local function MissionNameAnnouncement()
        ScenarioFramework.SimAnnouncement(ScenarioInfo.name, 'mission by [e]JJs_AI')
    end
    ScenarioFramework.CreateTimerTrigger(MissionNameAnnouncement, 7)

    ForkThread(SpawnInitalUnits)
    ForkThread(CreateCybScout)
    ScenarioFramework.Dialogue(OpStrings.IntroNIS_Dialogue, M1_Give_Resources, true)

    -- Objectives
    ScenarioInfo.M1P1 = Objectives.Protect(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Defend Science Facility',  -- title
        'The facility is under threat. Defend it until evacuation methods have been discussed.',  -- description
        {
            Units = {ScenarioInfo.Science},
        }
    )
    ScenarioInfo.M1P1:AddResultCallback(
        function(result)
            if not result then
                ScenarioFramework.Dialogue(OpStrings.Science_Facility_Dead, Mission_Failed, true)
            end
        end
    )
    table.insert(AssignedObjectives, ScenarioInfo.M1P1)
end

function Start_Mission_1()
    if not FacilitySpotted then
        FacilitySpotted = true
        ScenarioFramework.Dialogue(OpStrings.FacilityFound, nil, true)

        ScenarioInfo.M1P2 = Objectives.CategoriesInArea(
            'primary',                      -- type
            'incomplete',                   -- complete
            'Destroy Cybran Patrols',  -- title
            'Our scientists are under threat. Eliminate the Cybran patrols before they discover the science facility. You must hurry, it won\'t be long before the Cybrans extend their patrol route.',  -- description
            'kill',
            {
                Requirements = {
                    {Area = 'M1', Category = categories.CYBRAN, CompareOp = '<=', Value = 0, ArmyIndex = Cybran},
                },
            }
        )
        ScenarioInfo.M1P2:AddResultCallback(
            function(result)
                if(result) then
                    ScenarioFramework.Dialogue(OpStrings.Commander_At_Facility, Finish_Mission_1, true)
                end
            end
        )
        table.insert(AssignedObjectives, ScenarioInfo.M1P2)

        ForkThread(CheatEconomy, UEF)

        -- Send Attacks
        for _, v in ScenarioInfo.CybPat1:GetPlatoonUnits() do
            IssueStop({v})
            IssueClearCommands({v})
        end
        for _, v in ScenarioInfo.CybPat2:GetPlatoonUnits() do
            IssueStop({v})
            IssueClearCommands({v})
        end
        for _, v in ScenarioInfo.CybPatAir:GetPlatoonUnits() do
            IssueStop({v})
            IssueClearCommands({v})
        end
        ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.CybPat1, 'Cybran_Init_Patrol_Attack')
        ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.CybPat2, 'Cybran_Init_Patrol_Attack')
        ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.CybPatAir, 'Cybran_Init_Patrol_Attack')
    end
end

function M1_Give_Resources()
    ScenarioFramework.Dialogue(OpStrings.Resource_Transferred, nil, true)

    local EcoToGiveUnitTable = {
        {'Economy_D1_1', 'Economy_D1_2', 'Economy_D1_3', 'Economy_D2_1', 'Economy_D3_1', 'Economy_D3_2'}, -- Give all of the units to the player.
        {'Economy_D2_1', 'Economy_D3_1', 'Economy_D3_2'}, -- Give roughly half of the economy units to the player.
        {'Economy_D3_1', 'Economy_D3_2'} -- Give 2 of our units to the player.
    }

    for _, v in EcoToGiveUnitTable[Difficulty] do
        ScenarioFramework.GiveUnitToArmy(ScenarioInfo.UnitNames[UEF][v], Player1)
    end
end

function Finish_Mission_1()
    ScenarioFramework.SetPlayableArea('M2', true)
    ForkThread(Start_Mission_2)
end

function CreateCybScout()
    ScenarioFramework.CreateArmyIntelTrigger(Start_Mission_1, ArmyBrains[Cybran], 'LOSNow', false, true, categories.UEF, true, ArmyBrains[UEF])
    WaitSeconds(60)
    local Scout = ScenarioUtils.CreateArmyUnit('Cybran', 'Scout')
    IssueMove({Scout}, ScenarioUtils.MarkerToPosition('M1_Scout_Cybran_Move'))
end

-- Mission 2 --

function Start_Mission_2()
    -- Fix Resources
    ForkThread(CheatEconomy, Cybran)

    -- Patrols
    local JammerPatrol = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'JammerPatrol', 'GrowthFormation')
    for _, v in JammerPatrol:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('Cybran_Jammer_Patrol_Chain')))
    end

    local JammerPatrol2 = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'JammerPatrol_2', 'GrowthFormation')
    for _, v in JammerPatrol2:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('Cybran_Jammer_2_Air_Patrol')))
    end

    local JammerPatrol3 = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'Jammer_Land_1', 'GrowthFormation')
    for _, v in JammerPatrol3:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M2_Jammer_1_Patrol_1')))
    end

    local JammerPatrol4 = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'Jammer_Land_2', 'GrowthFormation')
    for _, v in JammerPatrol4:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M2_Jammer_2_Patrol_2')))
    end

    M2CybranJammerAI_1:M2_Cybran_Base_Function()
    M2CybranJammerAI_2:M2_Cybran_Base_Function()

    -- Walls
    ScenarioUtils.CreateArmyGroup("Cybran", "JammerWalls")
    ScenarioUtils.CreateArmyGroup("Cybran", "JammerWalls_2")

    -- Supports
    WaitSeconds(2)
    ScenarioUtils.CreateArmyGroup("Cybran", "JammerSupport")
    ScenarioUtils.CreateArmyGroup("Cybran", "JammerSupport2")
    ScenarioInfo.Jammer = ScenarioUtils.CreateArmyUnit('Cybran', 'Jammer_' .. Random(1, 2))

    -- Initial Attacks
    ScenarioInfo.InitAttack_1 = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'Initial_Attacks_1', 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolRoute(ScenarioInfo.InitAttack_1, ScenarioUtils.ChainToPositions('M2_Initial_Attack_1'))

    ScenarioInfo.InitAttack_2 = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'Initial_Attacks_2', 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolRoute(ScenarioInfo.InitAttack_2, ScenarioUtils.ChainToPositions('M2_Initial_Attack_2'))

    ScenarioInfo.M2P1 = Objectives.Locate(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Scout For Jammer',  -- title
        'The Scientists are unable to locate the Cybran Jammer. Scout for it.',  -- description
        {
            Units = {ScenarioInfo.Jammer},
            MarkUnits = false,
        }
    )
    ScenarioInfo.M2P1:AddResultCallback(
        function(result)
            if not JammerSpotted then 
                JammerSpotted = true
                ScenarioFramework.Dialogue(OpStrings.Jammer_Spotted, nil, true)

                ScenarioFramework.Dialogue(OpStrings.Destroy_Jammer, nil, true)

                ScenarioInfo.M2P5 = Objectives.KillOrCapture(
                    'primary',                      -- type
                    'incomplete',                   -- complete
                    'Destroy Cybran Jammer',  -- title
                    'Our scientists have decided to evacuate the facility, but they cannot call for help until that Cybran jammer has been destroyed. Locate and destroy the jammer.',  -- description
                    {
                        Units = {ScenarioInfo.Jammer},
                    }
                )
                ScenarioInfo.M2P5:AddResultCallback(
                    function(result)
                        if result then 
                            ScenarioInfo.M2P3:ManualResult(true)
                            CommsRestored = true
                            ScenarioFramework.Dialogue(OpStrings.Jammer_Destroyed, Intro_Mission_3, true)
                        end
                    end
                )
                table.insert(AssignedObjectives, ScenarioInfo.M2P5)

                -- Send an off-map attack whilst the player is distracted.
                local OffMapUnits1 = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'Attack_1', 'AttackFormation')
                ScenarioFramework.PlatoonPatrolChain(OffMapUnits1, 'Offmap_Attack_Chain_1')

                -- Send a constant off-map attack force whilst M2 is still active.
                ForkThread(M2OffMapAttacks)
            end
        end
    )
    table.insert(AssignedObjectives, ScenarioInfo.M2P1)

    ScenarioInfo.M2P2 = Objectives.CategoriesInArea(
        'secondary',                      -- type
        'incomplete',                   -- complete
        'Move to Marked Location',  -- title
        'The Scientists have marked a suitable area for your base. Move there and construct an outpost.',  -- description
        'Move',
        {
            MarkArea = true,
            Requirements =
            {
                {Area = 'Base', Category = categories.ENGINEER * categories.UEF, CompareOp = '>=', Value = 1, ArmyIndex = Player1},
            },
        }
    )
    table.insert(AssignedObjectives, ScenarioInfo.M2P2)

    ScenarioInfo.M2P3 = Objectives.Timer(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Locate and Destroy Jammer',  -- title
        'You\'ve only got a limited amount of time to locate and destroy the Cybran Jammer.',  -- description
        {
            Timer = M2P3Timer[Difficulty],
            ExpireResult = 'failed',
        }
    )
    ScenarioInfo.M2P3:AddResultCallback(
        function(result)
            if not result then
                -- Spawn Spider Group
                local SpiderGroup = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Cybran', 'SpiderGroup_2', 'GrowthFormation', 5)
                SpiderGroup:MoveToLocation(ScenarioUtils.MarkerToPosition('M3_Spider_2_Attack_Destination'), false)
                if ScenarioInfo.M2P5.Active then
                    ScenarioInfo.M2P5:ManualResult(false)
                end
                ScenarioFramework.Dialogue(OpStrings.JammerObjFailed, nil, true)

                WaitSeconds(5)

                ScenarioInfo.M3P6 = Objectives.KillOrCapture(
                    'primary',                      -- type
                    'incomplete',                   -- complete
                    'Survive Assault',  -- title
                    'The Cybran has sent a huge force to finish you off, destory it.',  -- description
                    {
                        MarkUnits = true,
                        Units = SpiderGroup:GetPlatoonUnits(),
                    }
                )
                ScenarioInfo.M3P6:AddResultCallback(
                    function(result)
                        ScenarioFramework.Dialogue(OpStrings.AttackFailed, Intro_Mission_3, true)
                    end
                )
                table.insert(AssignedObjectives, ScenarioInfo.M3P6)
            end
        end
    )
    table.insert(AssignedObjectives, ScenarioInfo.M2P3)
    ScenarioFramework.CreateTimerTrigger(M2P3Reminder1, M2P3Timer[Difficulty] / 2)
end

function M2OffMapAttacks()
    while ScenarioInfo.M2P3.Active do
        WaitSeconds(OffMapAttackTimer[Difficulty])
        if CAttacks == 1 then
            local Units = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'Attack_1', 'AttackFormation')
            ScenarioFramework.PlatoonPatrolChain(Units, 'Offmap_Attack_Chain_1')
            CAttacks = CAttacks + 1
        elseif CAttacks == 2 then
            local Units = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'Attack_2', 'AttackFormation')
            ScenarioFramework.PlatoonPatrolChain(Units, 'Offmap_Attack_Chain_1')
            CAttacks = CAttacks + 1
        elseif CAttacks == 3 then
            local Units = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'Attack_3', 'AttackFormation')
            ScenarioFramework.PlatoonPatrolChain(Units, 'Offmap_Attack_Chain_1')
            CAttacks = CAttacks + 1
        elseif CAttacks == 4 then
            local Units = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'Attack_4', 'AttackFormation')
            ScenarioFramework.PlatoonPatrolChain(Units, 'Offmap_Attack_Chain_1')
            CAttacks = CAttacks + 1
        elseif CAttacks == 5 then
            local Units = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'Attack_5', 'AttackFormation')
            ScenarioFramework.PlatoonPatrolChain(Units, 'Offmap_Attack_Chain_1')
            CAttacks = 1
        end
    end
end

function UnmarkBaseArea()
    ScenarioInfo.M2P2:ManualResult(true)
end

-- Mission 3 --
function Intro_Mission_3()
    ScenarioFramework.Dialogue(OpStrings.Evac, M3Trucks, true)

    -- Handle Cybran Base Stuff --
    ScenarioInfo.CybranCommander = ScenarioFramework.SpawnCommander('Cybran', 'ACU', false, "Jerrax", false, false, {'MicrowaveLaserGenerator', 'Teleporter', 'T3Engineering'})
    ScenarioInfo.CybranCommander:SetAutoOvercharge(true)
    ScenarioUtils.CreateArmyGroup('Cybran', 'Blockade')

    -- Patrols
    local units = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'Cybran_Air_Patrol', 'AttackFormation')
    for _, v in units:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M3_Cybran_Base_Air_Patrol')))
    end

    local units = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'Cybran_Land_Patrol', 'AttackFormation')
    for _, v in units:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M3_Cybran_Base_Land_Patrol')))
    end

    --ForkThread(M3_Handle_Cybran_Teleport)

    -- Disable Old AI
    M2CybranJammerAI_1:DisableBase()
    M2CybranJammerAI_2:DisableBase()

    -- Run AI
    M3CybranMainAI_1:M4_Cybran_Base_1_Function()

    WaitSeconds(2)
    ScenarioUtils.CreateArmyGroup("Cybran", "BaseSupports")
end

function M3Trucks()
    -- Create a trigger to send off-map attacks at the trucks.
    ForkThread(M3_Attack_Trucks_Function)

    WaitSeconds(TruckTimer[Difficulty])

    ScenarioInfo.TrucksCreated = 0
    ScenarioInfo.TrucksDestroyed = 0
    ScenarioInfo.TrucksEscorted = 0
    ScenarioInfo.Trucks = {}

    -- Create Trucks
    for i = 1, MaxTrucks do
        ScenarioInfo.TrucksCreated = i   
        local Truck = ScenarioUtils.CreateArmyUnit('UEF', 'Truck_'..ScenarioInfo.TrucksCreated)

        ScenarioFramework.CreateUnitDamagedTrigger(M3TruckDamaged, Truck, .01)
        ScenarioFramework.CreateUnitDeathTrigger(M3DeadTrucks, Truck)
        ScenarioFramework.CreateUnitToMarkerDistanceTrigger(DestroyUnit, Truck,  ScenarioUtils.MarkerToPosition('TrucksRemove'), 15)

        ScenarioFramework.CreateUnitToMarkerDistanceTrigger(TruckRescued, Truck, ScenarioUtils.MarkerToPosition('M3_Base_Defenses'), 15)
        IssueMove({Truck}, ScenarioUtils.MarkerToPosition('M3_UEF_Truck_Waypoint'))
        table.insert(ScenarioInfo.Trucks, Truck)
        WaitSeconds(3)
    end

    AllTrucksAlive = true
    ScenarioInfo.M1P1:ManualResult(true)

    -- Expand playable area.
    ScenarioFramework.SetPlayableArea('M3', true)
    ScenarioFramework.Dialogue(OpStrings.Trucks_Dispatched, nil, true)
    ForkThread(M3CybranAttacks)

    -- Create Transports, load them and send them to our objective.
    ScenarioInfo.Transports = ScenarioUtils.CreateArmyGroup('UEF', 'TransportTeam')
    ScenarioInfo.HTransports = ScenarioUtils.CreateArmyGroup('UEF', 'HTransportTeam')
    ScenarioInfo.Reinforcements_1 = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'TReinforcements_1', 'GrowthFormation')
    ScenarioInfo.Reinforcements_2 = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'TReinforcements_2', 'GrowthFormation')
    ScenarioInfo.TEngineer = ScenarioUtils.CreateArmyUnit('UEF', 'TEngineer')
    ScenarioInfo.HeavyTrans_1 = ScenarioInfo.UnitNames[UEF]['Tran_1']
    ScenarioInfo.HeavyTrans_2 = ScenarioInfo.UnitNames[UEF]['Tran_2']
    ScenarioInfo.HeavyTrans_3 = ScenarioInfo.UnitNames[UEF]['Tran_3']

    for _, v in ScenarioInfo.Transports do
        ScenarioFramework.CreateUnitDeathTrigger(M3DeadTransports, v)
        ScenarioFramework.CreateUnitToMarkerDistanceTrigger(DestroyUnit, v,  ScenarioUtils.MarkerToPosition('TrucksRemove'), 15)
    end

    ScenarioFramework.AttachUnitsToTransports(ScenarioInfo.Reinforcements_1:GetPlatoonUnits(), {ScenarioInfo.HeavyTrans_1})
    ScenarioFramework.AttachUnitsToTransports(ScenarioInfo.Reinforcements_2:GetPlatoonUnits(), {ScenarioInfo.HeavyTrans_2})
    ScenarioFramework.AttachUnitsToTransports({ScenarioInfo.TEngineer}, {ScenarioInfo.HeavyTrans_3})

    -- Call AI for defense construction
    M3_Rescue_AI:RescueFunction()

    -- Create a death trigger for each engineer. If the engineer is dead, we disable the base.
    ScenarioFramework.CreateUnitDeathTrigger(M3DisableEngineerBase, ScenarioInfo.TEngineer)

    IssueMove(ScenarioInfo.Transports, ScenarioUtils.MarkerToPosition('M3_UEF_Trans_Move'))

    -- Issue an unload for reinforcements
    IssueTransportUnload({ScenarioInfo.HeavyTrans_1}, ScenarioUtils.MarkerToPosition('M3_UEF_Reinforcements_1'))
    IssueTransportUnload({ScenarioInfo.HeavyTrans_2}, ScenarioUtils.MarkerToPosition('M3_UEF_Reinforcements_2'))
    IssueTransportUnload({ScenarioInfo.HeavyTrans_3}, ScenarioUtils.MarkerToPosition('M3_UEF_Trans_Move'))

    -- Issue a patrol for reinforcements
    ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.Reinforcements_1, 'M3_UEF_Reinforcement_Patrol')

    ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.Reinforcements_2, 'M3_UEF_Reinforcement_Patrol')

    WaitSeconds(5)

    -- Create an objective to defend the trucks.
    ScenarioInfo.M3P1 = Objectives.Basic(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Defend Science Trucks',  -- title
        'The Cybran is trying to attack the trucks. Make sure he doesn\'t get close to the civilians. Ensure a safe evacuation for the trucks. \nAt least 6 trucks must survive.',  -- description
        Objectives.GetActionIcon('move'),
        {
            MarkArea = true,
            Area = 'LandingZone',
        }
    )
    table.insert(AssignedObjectives, ScenarioInfo.M3P1)
    ScenarioFramework.CreateTimerTrigger(M3P3Reminder1, 600)

    Objectives.UpdateBasicObjective(ScenarioInfo.M3P1, 'progress', LOCF( '(%s/%s)', 0, 10 ) )

    -- Start moving the trucks to the landing zone.
    ScenarioInfo.M3MovePing = PingGroups.AddPingGroup('Move Scientist Trucks', nil, 'move', 'Mark a location for the trucks to move to.')
    ScenarioInfo.M3MovePing:AddCallback(MoveTruckAbility)

    -- Create a moment for a Spider to come.
    ScenarioInfo.SpiderGroup = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'SpiderGroup', 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolRoute(ScenarioInfo.SpiderGroup, ScenarioUtils.ChainToPositions('M3_Spider_Attack_Chain'))
    ScenarioFramework.Dialogue(OpStrings.SpiderLocated, nil, true)

    WaitSeconds(1)

    -- Create an objective to destroy the Cybran Spider.
    ScenarioInfo.M3P2 = Objectives.KillOrCapture(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Destroy Experimental Force',  -- title
        'The Cybran has sent an experimental force to attack the trucks, destroy it before it reaches them.',  -- description
        {
            MarkUnits = true,
            Units = ScenarioInfo.SpiderGroup:GetPlatoonUnits(),
        }
    )
    ScenarioInfo.M3P2:AddResultCallback(
        function(result)
            ScenarioFramework.Dialogue(OpStrings.SpiderDestroyed, nil, true)
        end
    )
    table.insert(AssignedObjectives, ScenarioInfo.M3P2)

    -- Bonus objective if all trucks are secure
    ScenarioInfo.M3B1 = Objectives.Protect(
        'bonus',
        'incomplete',
        'No Casualties',
        'All 10 of the Civilian Trucks survived.',
        {
            Units = ScenarioInfo.Trucks,
            MarkUnits = false,
            Hidden = true,
        }
    )
    ScenarioInfo.M3B1:AddResultCallback(
        function(result)
            if result then
                ScenarioFramework.Dialogue(OpStrings.BonusComplete, nil, true)
            end
        end
    )
end

function M3_Handle_Cybran_Teleport()
    while not ScenarioInfo.CybranCommander:IsDead() do
        local targets = GetArmyBrain('Player'.. Random(1, table.getsize(ScenarioInfo.HumanPlayers))):GetListOfUnits(categories.LAND * (categories.FACTORY + categories.MOBILE) - categories.WALL - categories.COMMAND, false)
        local target = targets[Random(1, table.getn(targets))]
        WaitSeconds(10)

        ScenarioInfo.CybranCommander:SetCanTakeDamage(false)
        Warp(ScenarioInfo.CybranCommander, target:GetPosition())
        ScenarioInfo.CybranCommander:SetCanTakeDamage(true)
        IssueAttack(ScenarioInfo.CybranCommander, target)

        WaitSeconds(5)

        ScenarioInfo.CybranCommander:SetCanTakeDamage(false)
        Warp(ScenarioInfo.CybranCommander, ScenarioUtils.MarkerToPosition('M3_Cybran_Base_Marker'))
        ScenarioInfo.CybranCommander:SetCanTakeDamage(true)

        WaitSeconds(CybranTeleportTimer[Difficulty])
    end
end

function TruckRescued(unit)
    if not ScenarioInfo.M3P1.Active then
        return
    end

    IssueStop({unit})
    IssueMove({unit}, ScenarioUtils.MarkerToPosition('M3_UEF_Trans_Move'))

    TrucksAtDest = TrucksAtDest + 1
    Objectives.UpdateBasicObjective(ScenarioInfo.M3P1, 'progress', LOCF('(%s/%s)', TrucksAtDest, 10 ))

    -- If not enough trucks
    if (TrucksAtDest < RequiredTrucks[Difficulty]) then
        return
    end

    if AllTrucksAlive then
        -- Bonus Objective here
        ScenarioInfo.M3B1:ManualResult(true)
    end

    local aliveTructs = {}
    for _, truck in ScenarioInfo.Trucks do
        if not truck.Dead then
            table.insert(aliveTructs, truck)
        end
    end

    ScenarioInfo.M3P1:ManualResult(true)

    ScenarioInfo.M3MovePing:Destroy()

    -- Remove Trucks from the map using transports.
    import('/lua/ai/aiutilities.lua').UseTransports(aliveTructs, ScenarioInfo.Transports, ScenarioUtils.MarkerToPosition('TrucksRemove'))
    IssueMove(ScenarioInfo.Transports, ScenarioUtils.MarkerToPosition('TrucksRemove'))
    ForkThread(M3DisableEngineerBase) -- Disable base if trucks have departed.
    ForkThread(M3AttackPlayer)
    ScenarioFramework.Dialogue(OpStrings.HQ_Mission3_1, Intro_Mission_4, true)
end

function M3TruckDamaged(truck)
    if not TrucksAttacked then
        ScenarioFramework.Dialogue(OpStrings.Trucks_Attacked, nil, true)
        TrucksAttacked = true
    end
end

function M3DeadTrucks(truck)
    AllTrucksAlive = false

    if ScenarioInfo.M3P1.Active then
        DeadTrucks = DeadTrucks + 1
        if DeadTrucks >= 4 then
            -- Mission Failed
            ScenarioFramework.Dialogue(OpStrings.Trucks_Lost, Mission_Failed, true)
        end
    end
end

function M3DeadTransports(transport)
    if ScenarioInfo.M3P1.Active then
        DeadTransports = DeadTransports + 1
        if DeadTransports >= 5 then
            -- Mission Failed
            ScenarioFramework.Dialogue(OpStrings.Transports_Lost, Mission_Failed, true)
        end
    end
end

function M3CybranAttacks()
    -- Let's make some drops.
    for i = 1, 3 do
        local attack_platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M3_Offmap_Units_' .. i, 'AttackFormation')

        local transport = ScenarioUtils.CreateArmyUnit('Cybran', 'Off_Trans')

        ScenarioFramework.AttachUnitsToTransports(attack_platoon:GetPlatoonUnits(), {transport})
        WaitSeconds(0.5)
        IssueTransportUnload({transport}, ScenarioUtils.MarkerToPosition('M3_Cybran_Trans_Drop_' .. i))
        IssueMove({transport}, ScenarioUtils.MarkerToPosition('M3_Cybran_Base_Marker'))
        ScenarioFramework.PlatoonPatrolChain(attack_platoon, 'M3_Cybran_Attack_Patrol_' .. i)
    end
end

function M3DisableEngineerBase()
    DeadEngineers = DeadEngineers + 1
    if DeadEngineers >= 2 then
        M3_Rescue_AI:DisableBase() -- Base Disabled.
    end
end

function M3AttackPlayer()
    for _, v in ScenarioInfo.SpiderGroup:GetPlatoonUnits() do
        if v and not v.Dead then
            IssueStop({v})
            IssueClearCommands({v})
        end
    end
end

function M3_Attack_Trucks_Function()
    while ScenarioInfo.M1P1.Active do
        if M3CAttacks == 1 then
            local Units = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M3_Attack_1', 'AttackFormation')
            ScenarioFramework.PlatoonPatrolChain(Units, 'M3_Cybran_Truck_Attacker_Chain')
            M3CAttacks = M3CAttacks + 1
        elseif M3CAttacks == 2 then
            local Units = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M3_Attack_2', 'AttackFormation')
            ScenarioFramework.PlatoonPatrolChain(Units, 'M3_Cybran_Truck_Attacker_Chain')
            M3CAttacks = M3CAttacks + 1
        elseif M3CAttacks == 3 then
            local Units = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M3_Attack_3', 'AttackFormation')
            ScenarioFramework.PlatoonPatrolChain(Units, 'M3_Cybran_Truck_Attacker_Chain')
            M3CAttacks = 1
        end
        WaitSeconds(M3OffMapAttackTimer[Difficulty])
    end
end

function MoveTruckAbility(location)
    for _, v in ScenarioInfo.Trucks do
        if(v and not v:IsDead()) then
            IssueStop({v})
            IssueClearCommands({v})
            IssueMove({v}, location)
        end
    end
end

-- Mission 4 --
function Intro_Mission_4()
    ForkThread(M4_Cybran_Nuke_Function)

    for _, v in ScenarioInfo.HTransports do
        ScenarioFramework.GiveUnitToArmy(v, Player1)
    end

    ScenarioInfo.M4S1 = Objectives.Kill(
        'secondary',                      -- type
        'incomplete',                   -- complete
        'Eliminate Cybran Commander',  -- title
        'Eliminate the Cybran Commander before recalling.',  -- description
        {
            FlashVisible = true,
            Units = {ScenarioInfo.CybranCommander},
        }
    )
    ScenarioInfo.M4S1:AddResultCallback(
        function(result)
            if(result) then
                ForkThread(CybranDeath)
            end
        end
    )  
    table.insert(AssignedObjectives, ScenarioInfo.M4S1)

    ForkThread(Start_Mission_4)
end

-- Mission 4 --
function Start_Mission_4()
    ScenarioInfo.M4P1 = Objectives.CategoriesInArea(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Construct Quantum Gate',  -- title
        'The Cybran Jammer has messed with our Quantum Tech. Build a Quantum Gateway to escape.',  -- description
        'Build',
        {
            MarkUnits = false,
            MarkArea = false,
            Requirements =
            {
                {Area = 'M3', Category = categories.ueb0304, CompareOp = '>=', Value = 1, ArmyIndex = Player1},
            },
        }
    )
    ScenarioInfo.M4P1:AddResultCallback(
        function(result)
            if(result) then
                ForkThread(M4_Gate_Built)
            end
        end
    )  
    table.insert(AssignedObjectives, ScenarioInfo.M4P1)
end

function M4_Cybran_Nuke_Function()
    local Launcher = ScenarioInfo.UnitNames[Cybran]['NukeLauncher']

    local delay = {10, 7, 4}

    while Launcher and not Launcher:IsDead() do
        local marker = nil
        local numUnits = 0
        local searching = true
        while(searching) do
            WaitSeconds(5)
            for i = 0, 2 do
                local num = table.getn(ArmyBrains[Cybran]:GetUnitsAroundPoint((categories.TECH2 * categories.STRUCTURE) + (categories.TECH3 * categories.STRUCTURE), ScenarioUtils.MarkerToPosition('M4_Cybran_Nuke_Chain_' .. i), 30, 'enemy'))
                if(num > 3) then
                    if(num > numUnits) then
                        numUnits = num
                        marker = 'M4_Cybran_Nuke_Chain_' .. i
                    end
                end
                if(i == 2 and marker) then
                    searching = false
                end
            end
        end
        if Launcher and not Launcher:IsDead() then
            Launcher:GiveNukeSiloAmmo(1)
            IssueNuke({Launcher}, ScenarioUtils.MarkerToPosition(marker))
        end
        
        WaitSeconds(delay[Difficulty] * 60)
    end
end

function M4_Gate_Built()
    local gates = ArmyBrains[Player1]:GetListOfUnits(categories.ueb0304, false)
    ScenarioFramework.CreateUnitNearTypeTrigger(CDRNearGate, ScenarioInfo.Player1CDR, ArmyBrains[Player1], categories.ueb0304, 5)
 
    if not ScenarioInfo.CybranCommander:IsDead() then
        ScenarioFramework.Dialogue(OpStrings.M4_Cybran_Teleport, M3_Handle_Cybran_Teleport, true)
    end

    ScenarioInfo.M4P2 = Objectives.Basic(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Leave Planet',  -- title
        'Use the newly constructed Quantum Gate to leave the planet.',  -- description
        Objectives.GetActionIcon('protect'),
        {
            Units = gates,
        }
    )
    table.insert(AssignedObjectives, ScenarioInfo.M4P2)
end

function CDRNearGate(Commander)
    if(ScenarioInfo.M4P2.Active) then
        ScenarioInfo.M4P2:ManualResult(true)
    end

    -- End Scenario Here
    ScenarioFramework.CDRDeathNISCamera(Commander)
    WaitSeconds(4)
    ScenarioFramework.FakeTeleportUnit(Commander, true)
    ForkThread(PlayerWins)
end

-- Utility Functions --
function SpawnInitalUnits()
    LOG("Spawning Players")
    ScenarioInfo.PlayerACUs = {}
    local tblArmy = ListArmies()
    local i = 1
    while tblArmy[ScenarioInfo['Player' .. i]] do
        ScenarioInfo['Player' .. i .. 'CDR'] = ScenarioFramework.SpawnCommander('Player' .. i, 'ACU', 'Warp', true, true, PlayerDeath)
        table.insert(ScenarioInfo.PlayerACUs, ScenarioInfo['Player' .. i .. 'CDR'])
        WaitSeconds(2)
        i = i + 1
    end
end

function PlayerWins()
    if not ScenarioInfo.OpEnded then
        ScenarioFramework.EndOperationSafety()

        ScenarioInfo.OpComplete = true

        -- Final dialogue
        ScenarioFramework.Dialogue(OpStrings.PlayerWins, Kill_Game, true)
    end
end

function PlayerDeath(Player)
    LOG("ACU Death")
    if CommsRestored then
        ScenarioFramework.PlayerDeath(Player, OpStrings.Player_Dead_2, AssignedObjectives)
    else
        ScenarioFramework.PlayerDeath(Player, OpStrings.Player_Dead_1, AssignedObjectives)
    end
end

function Mission_Failed()
    ScenarioFramework.EndOperationSafety()
    ScenarioFramework.FlushDialogueQueue()
    for k, v in AssignedObjectives do
        if(v and v.Active) then
            v:ManualResult(false)
        end
    end
    ScenarioInfo.OpComplete = false
    ForkThread(
        function()
            WaitSeconds(5)
            UnlockInput()
            Kill_Game()
        end
    )
end

function Kill_Game()
    UnlockInput()
    local allPrimaryCompleted = true
    local allSecondaryCompleted = true
    ScenarioFramework.EndOperation(ScenarioInfo.OpComplete, allPrimaryCompleted, allSecondaryCompleted)
end

function CheatEconomy(army)
    ArmyBrains[army]:GiveStorage('MASS', 10000)
    ArmyBrains[army]:GiveStorage('ENERGY', 10000)
    while(true) do
        ArmyBrains[army]:GiveResource('MASS', 10000)
        ArmyBrains[army]:GiveResource('ENERGY', 10000)
        WaitSeconds(1)
    end
end

function DestroyUnit(unit)
    unit:Destroy()
end

function CybranDeath(ACU)
    M3CybranMainAI_1:DisableBase()
    ScenarioFramework.Dialogue(OpStrings.M4_Cybran_Death, nil, true)
end

----------
-- Reminders
----------
function M2P3Reminder1()
    if(ScenarioInfo.M2P1.Active) then
        ScenarioFramework.Dialogue(OpStrings.M2P1Reminder_1, nil, true)
    end
end

function M3P3Reminder1()
    if(ScenarioInfo.M3P1.Active) then
        ScenarioFramework.Dialogue(OpStrings.M3P1Reminder_1, nil, true)
        ScenarioFramework.CreateTimerTrigger(M3P3Reminder1, 350)
    end
end

function M3P3Reminder2()
    if(ScenarioInfo.M3P1.Active) then
        ScenarioFramework.Dialogue(OpStrings.M3P1Reminder_2, nil, true)
    end
end
