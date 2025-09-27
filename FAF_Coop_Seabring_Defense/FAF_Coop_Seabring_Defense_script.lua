--
-- A short mission of defending the town that is under attack in the first FA mission.
-- 99% of this mission is extracted from X1CA_Coop_001
-- Slapped together by speed2
--

local Cinematics = import('/lua/cinematics.lua')
local M2OrderAI = import('/maps/FAF_Coop_Seabring_Defense/FAF_Coop_Seabring_Defense_m2orderai.lua')
local Objectives = import('/lua/ScenarioFramework.lua').Objectives
local OpStrings = import('/maps/FAF_Coop_Seabring_Defense/FAF_Coop_Seabring_Defense_strings.lua')
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local TauntManager = import('/lua/TauntManager.lua')

----------
-- Globals
----------
ScenarioInfo.Player1 = 1
ScenarioInfo.Order = 2
ScenarioInfo.UEF = 3
ScenarioInfo.Civilians = 4

---------
-- Locals
---------
local Player1 = ScenarioInfo.Player1
local Order = ScenarioInfo.Order
local UEF = ScenarioInfo.UEF
local Civilians = ScenarioInfo.Civilians

local AssignedObjectives = {}
local Difficulty = ScenarioInfo.Options.Difficulty

-- The faction of player 1: determines the dialog and suchlike you get.
local LeaderFaction

-- The faction of the local player. Determines a few other bits and bobs.
local LocalFaction

-- How long should we wait at the beginning of the NIS to allow slower machines to catch up?
local NIS1InitialDelay = 3

-------------
-- Debug only
-------------
local SkipNIS1 = false

----------
-- Startup
----------
function OnPopulate(scenario)
    ScenarioUtils.InitializeScenarioArmies()
    LeaderFaction, LocalFaction = ScenarioFramework.GetLeaderAndLocalFactions()

    ScenarioFramework.SetUEFPlayerColor(Player1)
    ScenarioFramework.SetAeonEvilColor(Order)
    ScenarioFramework.SetUEFAlly1Color(UEF)
    ScenarioFramework.SetUEFAlly2Color(Civilians)

    -- Disable friendly AI sharing resources to players
    GetArmyBrain(UEF):SetResourceSharing(false)
    GetArmyBrain(Civilians):SetResourceSharing(false)

    ---------
    -- Player
    ---------
    ScenarioUtils.CreateArmyGroup('Player1', 'M2_Town_Defenses')
    ScenarioUtils.CreateArmyGroup('Player1', 'M2_Town_Turrets_D' .. Difficulty)
    ScenarioUtils.CreateArmyGroup('Player1', 'M2_Town_Init_Eng_D' .. Difficulty)

    -- Refresh building restrictions
    ScenarioFramework.RefreshRestrictions('Player1')

    -- Initial Attack
    for i = 1, 2 do
        local units = ScenarioUtils.CreateArmyGroupAsPlatoon('Player1', 'M2_Town_Init_Land' .. i .. '_D' .. Difficulty, 'AttackFormation')
        ScenarioFramework.PlatoonPatrolChain(units, 'UEF_M2_West_Town_Patrol_Chain')
    end

    ----------------
    -- Civilian Town
    ----------------
    ScenarioInfo.M2CivilianBuildings = ScenarioUtils.CreateArmyGroup('Civilians', 'M2_Civilian_Buildings')
    ScenarioUtils.CreateArmyGroup('Civilians', 'M2_Wreckage', true)
    ScenarioUtils.CreateArmyGroup('Civilians', 'Walls')

    --------------
    -- Order M2 AI
    --------------
    M2OrderAI.OrderM2MainBaseAI()
    M2OrderAI.OrderM2AirNorthBaseAI()
    M2OrderAI.OrderM2AirSouthBaseAI()
    M2OrderAI.OrderM2LandNorthBaseAI()
    M2OrderAI.OrderM2LandSouthBaseAI()

    ScenarioFramework.RefreshRestrictions('Order')

    -- Order Initial Patrols
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

    -- Order Initial Attack
    for i = 1, 2 do
        local units = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'M2_Init_BaseAttack_Land' .. i .. '_D' .. Difficulty, 'AttackFormation')
        for k, v in units:GetPlatoonUnits() do
            IssueMove({v}, ScenarioUtils.MarkerToPosition('M2_Town_Order_InitialLand_' .. Random(1, 3)))
        end
    end
    units = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'M2_Init_BaseAttack_Air1_D' .. Difficulty, 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(units, 'Order_M2_Town_AirPatrol_Chain')

    -- Order Secondary Attack
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
end

function OnStart(scenario)
    ---------------------
    -- Build Restrictions
    ---------------------
    ScenarioFramework.AddRestrictionForAllHumans(
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
        categories.delk002 + -- UEF T3 MAA
        categories.xeb2306 + -- UEF Heavy Point Defense
        categories.xel0305 + -- UEF Percival
        categories.xel0306 + -- UEF Mobile Missile Platform
        categories.xes0102 + -- UEF Torpedo Boat
        categories.xes0205 + -- UEF Shield Boat
        categories.xes0307 + -- UEF Battlecruiser
        categories.xeb0104 + -- UEF Engineering Station 1
        categories.xeb0204 + -- UEF Engineering Station 2
        categories.xea0306 + -- UEF Heavy Air Transport
        categories.xeb2402   -- UEF Sub-Orbital Defense System
    )

    -- Initialize camera
    if not SkipNIS1 then
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_2_1'))
    end

    ScenarioFramework.SetPlayableArea('M2_Playable_Area', false)

    ForkThread(IntroMission2NIS)
end

-----------
-- End Game
-----------
function PlayerWin()
    ForkThread(
        function()
            if(not ScenarioInfo.OpEnded) then
                ScenarioFramework.EndOperationSafety()
                ScenarioFramework.FlushDialogueQueue()
                ScenarioInfo.OpComplete = true
                --ScenarioFramework.Dialogue(VoiceOvers.Victory, KillGame, true)
                KillGame()
            end
        end
    )
end

function PlayerDeath(deadCommander)
    ScenarioFramework.PlayerDeath(deadCommander, nil, AssignedObjectives)
end

function KillGame()
    ForkThread(
        function()
            -- local secondaries = Objectives.IsComplete(ScenarioInfo.M1S1)
            ScenarioFramework.EndOperation(ScenarioInfo.OpComplete, ScenarioInfo.OpComplete, false, false)
        end
    )
end

------------
-- Mission 2
------------
function IntroMission2()
    ScenarioInfo.MissionNumber = 2

    -- Player has > 65, 50, 35 T2/T3 planes, 1 group AA for every 15
    local trigger = {65, 50, 35}
    local num = ScenarioFramework.GetNumOfHumanUnits((categories.MOBILE * categories.AIR) - categories.TECH1)

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
    num = ScenarioFramework.GetNumOfHumanUnits(categories.AIR * categories.EXPERIMENTAL)

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
    num = ScenarioFramework.GetNumOfHumanUnits((categories.MOBILE * categories.LAND) - categories.CONSTRUCTION - categories.TECH1)

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
    num = ScenarioFramework.GetNumOfHumanUnits(categories.LAND * categories.EXPERIMENTAL)

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
end

function IntroMission2NIS()
    Cinematics.EnterNISMode()

    -- "Yeah, hi...we're totally getting attacked"
    ScenarioFramework.Dialogue(OpStrings.X01_M02_011, nil, true) -- 9 sec

    -- Give intel on the enemy bases briefly, so the buildings are visible under fog
    ScenarioFramework.CreateVisibleAreaLocation( 50, ScenarioUtils.MarkerToPosition( 'M2_NIS_Vis_1' ), 1, ArmyBrains[Player1] )
    ScenarioFramework.CreateVisibleAreaLocation( 50, ScenarioUtils.MarkerToPosition( 'M2_NIS_Vis_2' ), 1, ArmyBrains[Player1] )
    ScenarioFramework.CreateVisibleAreaLocation( 50, ScenarioUtils.MarkerToPosition( 'M2_NIS_Vis_3' ), 1, ArmyBrains[Player1] )
    ScenarioFramework.CreateVisibleAreaLocation( 50, ScenarioUtils.MarkerToPosition( 'M2_NIS_Vis_4' ), 1, ArmyBrains[Player1] )
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
    ScenarioFramework.Dialogue(OpStrings.X01_M02_012, nil, true) -- 10 sec
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
    ScenarioFramework.Dialogue(OpStrings.X01_M02_013, nil, true) -- 5 sec
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_2_8'), 3)
    WaitSeconds(1)

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
            if not result then
                ScenarioFramework.PlayerLose(OpStrings.X01_M02_040, AssignedObjectives)
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
                ScenarioFramework.Dialogue(OpStrings.X01_M02_039, PlayerWin)
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
    -- ScenarioFramework.UnrestrictWithVoiceoverAndDelay(categories.xaa0202, "aeon", 45, VoiceOvers.T2FighterUnlocked)
end

--- Called when one of the civilian buildings you must defend in the main settlement is destroyed.
function M2P1Warnings()
    ScenarioInfo.M2CivBuildingCount = ScenarioInfo.M2CivBuildingCount - 1

    if not ScenarioInfo.M2P1.Active then
        return
    end

    -- if we've only 3 buildings more than the min, play a warning
    if ScenarioInfo.M2CivBuildingCount == ScenarioInfo.M2BuildingFailLimit + 4 then
        ScenarioFramework.Dialogue(OpStrings.X01_M02_030)
    end

    -- if we've only 1 building more than the min, play another
    if ScenarioInfo.M2CivBuildingCount == ScenarioInfo.M2BuildingFailLimit + 1 then
        ScenarioFramework.Dialogue(OpStrings.X01_M02_020)
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