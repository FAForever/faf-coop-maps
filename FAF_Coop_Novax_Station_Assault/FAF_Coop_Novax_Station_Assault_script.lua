----------------------------------------
-- Custom mission: Novax Station Assault
--
-- Author: speed2
----------------------------------------
local Cinematics = import('/lua/cinematics.lua')
local CustomFunctions = import('/maps/FAF_Coop_Novax_Station_Assault/FAF_Coop_Novax_Station_Assault_CustomFunctions.lua')
local M1OrderAI = import('/maps/FAF_Coop_Novax_Station_Assault/FAF_Coop_Novax_Station_Assault_m1orderai.lua')
local M1UEFAI = import('/maps/FAF_Coop_Novax_Station_Assault/FAF_Coop_Novax_Station_Assault_m1uefai.lua')
local M2CybranAI = import('/maps/FAF_Coop_Novax_Station_Assault/FAF_Coop_Novax_Station_Assault_m2cybranai.lua')
local M2OrderAI = import('/maps/FAF_Coop_Novax_Station_Assault/FAF_Coop_Novax_Station_Assault_m2orderai.lua')
local M2QAIAI = import('/maps/FAF_Coop_Novax_Station_Assault/FAF_Coop_Novax_Station_Assault_m2qaiai.lua')
local M2UEFAI = import('/maps/FAF_Coop_Novax_Station_Assault/FAF_Coop_Novax_Station_Assault_m2uefai.lua')
local M3CybranAI = import('/maps/FAF_Coop_Novax_Station_Assault/FAF_Coop_Novax_Station_Assault_m3cybranai.lua')
local M3UEFAI = import('/maps/FAF_Coop_Novax_Station_Assault/FAF_Coop_Novax_Station_Assault_m3uefai.lua')
local Objectives = import('/lua/SimObjectives.lua')
local OpStrings = import('/maps/FAF_Coop_Novax_Station_Assault/FAF_Coop_Novax_Station_Assault_strings.lua')
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local PingGroups = ScenarioFramework.PingGroups
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local Utilities = import('/lua/utilities.lua')
local VizMarker = import('/lua/sim/VizMarker.lua').VizMarker
local TauntManager = import('/lua/TauntManager.lua')

----------
-- Globals
----------
ScenarioInfo.Player1 = 1
ScenarioInfo.UEF = 2
ScenarioInfo.Order = 3
ScenarioInfo.Cybran = 4
ScenarioInfo.Objective = 5
ScenarioInfo.QAI = 6
ScenarioInfo.Player2 = 7
ScenarioInfo.Player3 = 8
ScenarioInfo.Player4 = 9

ScenarioInfo.OperationScenarios = {
    M1 = {
        Events = {
            {
                CallFunction = function() M1RiptideAttack() end,
                Delay = {10*60, 8*60, 6*60},
            },
            {
                CallFunction = function() M1SubmarineAttack() end,
                Delay = {9*60, 7*60, 5*60},
            },
        },
    },
    M2 = {
        Bases = {
            {
                CallFunction = function(baseType)
                    M2CybranIslandUnits(baseType)
                    M2CybranAI.CybranM2IslandBaseAI(baseType)
                end,
                Types = {'Naval', 'Arty', 'Eco', 'Air'},
            },
            {
                CallFunction = function(baseType) M2UEFAI.UEFM2IslandBaseAI(baseType) end,
                Types = {'Eco', 'Nuke'}, -- 'Gate'
            },
        },
        Events = {
            {
                CallFunction = function() M2BattleshipAttack() end,
                Delay = {15*60, 11*60, 7*60},
            },
            {
                CallFunction = function() M2CybranNukeSubAttack() end,
                Delay = {19*60, 15*60, 11*60},
            },
            {
                CallFunction = function() M2ExperimentalAttack() end,
                Delay = {17*60, 13*60, 9*60},
            },
        },
    },
    M3 = {
        Bases = {
            {
                CallFunction = function(baseType)
                    if baseType == 'Cybran' then
                        M3CybranAI.CybranM3SeaBaseAI()
                    elseif baseType == 'UEF' then
                        M3UEFAI.UEFM3SeaBaseAI()
                    end
                end,
                Types = {'Cybran', 'UEF'},
            },
        },
        Events = {
            {
                CallFunction = function() M3SoulRipperAttack() end,
                Delay = {16*60, 13*60, 10*60},
            },
            {
                CallFunction = function() M3CybranAI.BuildNukeSubs() end,
                Delay = {20*60, 16*60, 12*60},
            },
            {
                CallFunction = function() M3AtlantisHunters() end,
                Delay = {12*60, 8*60, 4*60},
            },
        },
    },
}

---------
-- Locals
---------
local Player1 = ScenarioInfo.Player1
local UEF = ScenarioInfo.UEF
local Order = ScenarioInfo.Order
local Cybran = ScenarioInfo.Cybran
local Objective = ScenarioInfo.Objective
local QAI = ScenarioInfo.QAI
local Player2 = ScenarioInfo.Player2
local Player3 = ScenarioInfo.Player3
local Player4 = ScenarioInfo.Player4

local Difficulty = ScenarioInfo.Options.Difficulty

-- How long should we wait at the beginning of the NIS to allow slower machines to catch up?
local NIS1InitialDelay = 3

-----------------
-- Taunt Managers
-----------------
local UEFTM = TauntManager.CreateTauntManager('UEFTM', '/maps/FAF_Coop_Novax_Station_Assault/FAF_Coop_Novax_Station_Assault_strings.lua')
local OrderTM = TauntManager.CreateTauntManager('OrderTM', '/maps/FAF_Coop_Novax_Station_Assault/FAF_Coop_Novax_Station_Assault_strings.lua')
local SeraphimTM = TauntManager.CreateTauntManager('SeraphimTM', '/maps/FAF_Coop_Novax_Station_Assault/FAF_Coop_Novax_Station_Assault_strings.lua')

--------------
-- Debug only!
--------------
local Debug = false
local SkipDialogues = false
local SkipNIS1 = false
local SkipNIS2 = false
local SkipNIS3 = false
local M2NoCounterAttack = false

-----------
-- Start Up
-----------
function OnPopulate(scenario)
    ScenarioUtils.InitializeScenarioArmies()

    local tblArmy = ListArmies()
    -- If there is not Player2 then use Order AI
    if not tblArmy[ScenarioInfo.Player2] then
        ScenarioInfo.UseOrderAI = true
    end

    --------
    -- Order
    --------
    -- Economy buildings for Carrier
    ScenarioInfo.M1_Order_Eco = ScenarioUtils.CreateArmyGroup('Order', 'M1_Order_Economy')

    -- Carrier
    ScenarioInfo.M1_Order_Carrier = ScenarioUtils.CreateArmyUnit('Order', 'M1_Order_Carrier')

    -- Carrier fleet
    ScenarioInfo.M1_Carrier_Fleet = ScenarioUtils.CreateArmyGroup('Order', 'M1_Order_Carrier_Fleet_D' .. Difficulty)

    -- Carrier Air units
    local cargoUnits = ScenarioUtils.CreateArmyGroup('Order', 'M1_Oder_Init_Air_D' .. Difficulty)
    for _, unit in cargoUnits do
        IssueStop({unit})
        ScenarioInfo.M1_Order_Carrier:AddUnitToStorage(unit)
    end

    -- Move Carrier to starting position together with the fleet
    IssueMove({ScenarioInfo.M1_Order_Carrier}, ScenarioUtils.MarkerToPosition('M1_Order_Carrier_Start_Marker'))
    IssueMove(ScenarioInfo.M1_Carrier_Fleet, ScenarioUtils.MarkerToPosition('Rally Point 05'))

    ForkThread(function()
        while (ScenarioInfo.M1_Order_Carrier and not ScenarioInfo.M1_Order_Carrier.Dead and ScenarioInfo.M1_Order_Carrier:IsUnitState('Moving')) do
            WaitSeconds(.5)
        end

        -- Give Naval fleet to Player1 and put on a patrol
        local givenNavalUnits = {}

        for _, unit in ScenarioInfo.M1_Carrier_Fleet do
            IssueClearCommands({unit})
            local tempUnit = ScenarioFramework.GiveUnitToArmy(unit, 'Player1')
            table.insert(givenNavalUnits, tempUnit) 
        end

        for k, v in EntityCategoryFilterDown(categories.uas0202, givenNavalUnits) do
            ScenarioInfo['M1B1Cruiser' .. k] = v
            ScenarioFramework.CreateUnitGivenTrigger(M1CruiserGiven, v)
        end

        ScenarioFramework.GroupPatrolChain(givenNavalUnits, 'M1_Oder_Naval_Def_Chain')

        -- Release air units from carrier, give them to Player1 and put on a patrol
        local givenAirUnits = {}

        IssueClearCommands({ScenarioInfo.M1_Order_Carrier})
        IssueTransportUnload({ScenarioInfo.M1_Order_Carrier}, ScenarioInfo.M1_Order_Carrier:GetPosition())

        for _, unit in cargoUnits do
            while (not unit.Dead and unit:IsUnitState('Attached')) do
                WaitSeconds(3)
            end
            IssueClearCommands({unit})
            local tempUnit
            if ScenarioInfo.UseOrderAI then
                tempUnit = ScenarioFramework.GiveUnitToArmy(unit, 'Player1')
            else
                tempUnit = ScenarioFramework.GiveUnitToArmy(unit, 'Player2')
            end
            table.insert(givenAirUnits, tempUnit)
        end

        CustomFunctions.UnitsMultiplyMaxFuel(givenAirUnits, 4) -- More fuel for air units
        ScenarioFramework.GroupPatrolChain(givenAirUnits, 'M1_Oder_Naval_Def_Chain')

        -- Start building units from the carrier once on it's place
        M1OrderAI.OrderCarrierFactory()
    end)

    -- Tempest
    ScenarioInfo.M1_Order_Tempest = ScenarioUtils.CreateArmyUnit('Order', 'M1_Order_Tempest')
    ScenarioInfo.M1_Order_Tempest:HideBone('Turret', true)
    ScenarioInfo.M1_Order_Tempest:HideBone('Turret_Muzzle', true)
    ScenarioInfo.M1_Order_Tempest:SetWeaponEnabledByLabel('MainGun', false)

    -- Move Tempest to starting position
    IssueMove({ScenarioInfo.M1_Order_Tempest}, ScenarioUtils.MarkerToPosition('M1_Order_Tempest_Start_Marker'))

    ForkThread(function()
        while (ScenarioInfo.M1_Order_Tempest and not ScenarioInfo.M1_Order_Tempest.Dead and ScenarioInfo.M1_Order_Tempest:IsUnitState('Moving')) do
            WaitSeconds(.5)
        end

        IssueClearCommands({ScenarioInfo.M1_Order_Tempest})

        -- Start building units from the tempest once on it's place
        M1OrderAI.OrderTempestFactory()
    end)

    -- Sonar, only for easy/medium difficulty
    if Difficulty <= 2 then
        ScenarioInfo.M1_Order_Sonar = ScenarioUtils.CreateArmyUnit('Order', 'M1_Order_Sonar')

        -- Move Sonar to starting position
        IssueMove({ScenarioInfo.M1_Order_Sonar}, ScenarioUtils.MarkerToPosition('M1_Order_Sonar_Start_Marker'))
    end
    
    ---------
    -- UEF AI
    ---------
    M1UEFAI.UEFM1BaseAI()

    -- Refresh build restrictions on engineers and factories
    ScenarioFramework.RefreshRestrictions('UEF')

    -- Walls
    ScenarioUtils.CreateArmyGroup('UEF', 'M1_UEF_Walls')
    
    -- UEF Patrols
    -- Air
    local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M1_UEF_Base_Air_Patrol_D' .. Difficulty, 'NoFormation')
    for _, v in platoon:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M1_UEF_Base_Air_Patrol_Chain')))
    end

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M1_UEF_Random_Air_Patrol_D' .. Difficulty, 'NoFormation')
    for _, v in platoon:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M1_UEF_Naval_Random_Patrol_Chain')))
    end
    
    -- Land
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M1_UEF_Base_Titan_Patrol', 'AttackFormation')
    for _, v in platoon:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolChain({v}, 'M1_UEF_Base_Titan_Patrol_Chain')
    end

    -- Naval
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M1_UEF_Base_Naval_Patrol_D' .. Difficulty, 'NoFormation')
    for _, v in platoon:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolChain({v}, 'M1_UEF_Base_Naval_Patrol_Chain')
    end

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M1_UEF_Patrol_NE_D' .. Difficulty, 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M1_UEF_Naval_NE_Chain')

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M1_UEF_Patrol_West_D' .. Difficulty, 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M1_UEF_Naval_West_Chain')

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M1_UEF_Random_Patrol_D' .. Difficulty, 'GrowthFormation')
    for _, v in platoon:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M1_UEF_Naval_Random_Patrol_Chain')))
    end

    ------------
    -- Civilians
    ------------
    -- Objective target, with extra health
    ScenarioInfo.M1ResearchStation = ScenarioUtils.CreateArmyUnit('Objective', 'M1_Research_Station')
    ScenarioInfo.M1ResearchStation:SetCustomName('Novax Station Gama')
    ScenarioInfo.M1ResearchStation:SetMaxHealth(6250)
    ScenarioInfo.M1ResearchStation:SetHealth(ScenarioInfo.M1ResearchStation, 6250)

    -- Other buildings
    ScenarioUtils.CreateArmyGroup('Objective', 'M1_Civilian_Complex')
    ScenarioUtils.CreateArmyGroup('Objective', 'M1_Walls')

    -- Restrict playable area
    ScenarioFramework.SetPlayableArea('M1_Area', false)
end

function OnStart(scenario)
    -- Sets Army Colors
    ScenarioFramework.SetSeraphimColor(Player1)
    ScenarioFramework.SetUEFPlayerColor(UEF)
    ScenarioFramework.SetCybranPlayerColor(Cybran)
    ScenarioFramework.SetNeutralColor(Objective)
    ScenarioFramework.SetCybranEvilColor(QAI)
    if ScenarioInfo.UseOrderAI then
        ScenarioFramework.SetAeonEvilColor(Order)
    else
        SetArmyColor(Order, 15, 148, 72)
    end

    local colors = {
        ['Player2'] = {159, 216, 2}, 
        ['Player3'] = {255, 200, 0}, 
        ['Player4'] = {123, 255, 125}
    }
    local tblArmy = ListArmies()
    for army, color in colors do
        if tblArmy[ScenarioInfo[army]] then
            SetArmyColor(ScenarioInfo[army], unpack(color))
        end
    end

    ScenarioFramework.AddRestrictionForAllHumans(
        categories.xeb2402 -- UEF Novax Center
    )

    -- Unit Cap
    ScenarioFramework.SetSharedUnitCap(1000)

    -- Disable resource sharing from friendly AI
    GetArmyBrain(Order):SetResourceSharing(false)
    GetArmyBrain(QAI):SetResourceSharing(false)

    -- Initialize camera
    if not SkipNIS1 then
        Cinematics.CameraMoveToMarker('Cam_1_1', 0)
    end

    ForkThread(IntroMission1NIS)
end

------------
-- Mission 1
------------
function IntroMission1NIS()
    if not SkipNIS1 then
        Cinematics.EnterNISMode()

        -- Vision for NIS location
        local VisMarker1_1 = ScenarioFramework.CreateVisibleAreaLocation(60, 'M1_UEF_Base_Marker', 0, ArmyBrains[Player1])
        local VisMarker1_2 = ScenarioFramework.CreateVisibleAreaLocation(25, 'M1_Civilian_Vision_Marker', 0, ArmyBrains[Player1])
        local VisMarker1_3 = ScenarioFramework.CreateVisibleAreaAtUnit(60, ScenarioInfo.UnitNames[UEF]['UEF_NIS_Unit'], 0, ArmyBrains[Player1])

        WaitSeconds(NIS1InitialDelay)
        ScenarioFramework.Dialogue(OpStrings.IntroResearchStation, nil, true)

        WaitSeconds(5)

        ScenarioFramework.Dialogue(OpStrings.IntroUEFBase, nil, true)
        Cinematics.CameraMoveToMarker('Cam_1_2', 4)

        WaitSeconds(2)

        ScenarioFramework.Dialogue(OpStrings.IntroPatrols, nil, true)
        Cinematics.CameraTrackEntity(ScenarioInfo.UnitNames[UEF]['UEF_NIS_Unit'], 40, 4)

        WaitSeconds(2)

        ScenarioFramework.Dialogue(OpStrings.IntroCarriers, nil, true)
        Cinematics.CameraMoveToMarker('Cam_1_3', 5)

        WaitSeconds(3)

        Cinematics.CameraMoveToMarker('Cam_1_4', 4)

        WaitSeconds(3)

        VisMarker1_1:Destroy()
        VisMarker1_2:Destroy()
        VisMarker1_3:Destroy()

        if Difficulty == 3 then
            ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('M1_UEF_Base_Marker'), 80)
        end

        Cinematics.ExitNISMode()
    end
    IntroMission1()
end

function IntroMission1()
    ScenarioInfo.MissionNumber = 1

    -- Resources for AI, slightly delayed cause army didn't recieve it for some reason
    ForkThread(function()
        WaitSeconds(2)
        ArmyBrains[UEF]:GiveResource('MASS', 10000)
        ArmyBrains[Objective]:GiveResource('ENERGY', 10000)
    end)

    if Debug then
        Utilities.UserConRequest('SallyShears')
    end
    if SkipDialogues then
        StartMission1()
    else
        ScenarioFramework.Dialogue(OpStrings.M1KillResearchStation1, StartMission1, true)
    end
end

-- Assign objetives
function StartMission1()
    ----------------------------------------------
    -- Primary Objective 1 - Kill Research Station
    ----------------------------------------------
    ScenarioInfo.M1P1 = Objectives.Kill(
        'primary',
        'incomplete',
        OpStrings.M1P1Title,
        OpStrings.M1P1Description,
        {
            Units = {ScenarioInfo.M1ResearchStation},
            FlashVisible = true,
        }
    )
    ScenarioInfo.M1P1:AddResultCallback(
        function(result)
            if(result) then
                if ScenarioInfo.MissionNumber == 1 then
                    ScenarioFramework.Dialogue(OpStrings.M1ResearchStationKilled1, nil, true)
                elseif ScenarioInfo.MissionNumber == 2 then
                    ScenarioFramework.Dialogue(OpStrings.M1ResearchStationKilled2)
                end
            end
        end
    )

    ----------------------------------------------
    -- Secondary Objective 1 - Clear Landing Areas
    ----------------------------------------------
    ScenarioInfo.M1S1 = Objectives.CategoriesInArea(
        'secondary',
        'incomplete',
        OpStrings.M1S1Title,
        OpStrings.M1S1Description,
        'kill',
        {
            -- MarkArea = true,
            Requirements = {
                {   
                    Area = 'M1_UEF_Base_Area',
                    Category = categories.ALLUNITS - categories.WALL,
                    CompareOp = '<=',
                    Value = 0,
                    ArmyIndex = UEF,
                },
            },
        }
    )
    ScenarioInfo.M1S1:AddResultCallback(
        function(result)
            if(result) then
                -- End other objectives if they are active
                if ScenarioInfo.M1P2.Active then
                    ScenarioInfo.M1P2:ManualResult(true)
                end
                if ScenarioInfo.M1P3.Active then
                    ScenarioInfo.M1P3:ManualResult(true)
                end
                if ScenarioInfo.M1B1.Active then
                    ScenarioInfo.M1B1:ManualResult(true)
                end
                -- Destroy skip button
                if ScenarioInfo.GateInPing then
                    ScenarioInfo.GateInPing:Destroy()
                end
                -- Proceed to next mission if we aren't there yet
                if ScenarioInfo.MissionNumber == 1 then
                    ScenarioFramework.Dialogue(OpStrings.M1LandingAreaCleared, IntroMission2, true)
                end
            end
        end
    )

    -- Assign bonus obj once the naval fleet is given to the player
    ForkThread(M1ProtectCruisersObjective)

    -- Pick a random event for the first part of the mission
    ScenarioFramework.ChooseRandomEvent(true)

    -- Shameless self promotion
    ScenarioFramework.CreateTimerTrigger(MissionNameAnnouncement, 5)

    -- Post objective dialogue
    ScenarioFramework.CreateTimerTrigger(M1PostObjectiveDialogue, 8)
end

function MissionNameAnnouncement()
    ScenarioFramework.SimAnnouncement(ScenarioInfo.name, 'mission by [e]speed2')
end

function M1PostObjectiveDialogue()
    ScenarioFramework.Dialogue(OpStrings.M1KillResearchStation2)

    -- Assign objective to protect mobile factories after a bit
    ScenarioFramework.CreateTimerTrigger(M1ProtectCarriersObjective, 30)
end

function M1CruiserGiven(oldCruiser, newCruiser)
    if ScenarioInfo.M1B1Cruiser1 == oldCruiser then
        ScenarioInfo.M1B1Cruiser1 = newCruiser
    elseif ScenarioInfo.M1B1Cruiser2 == oldCruiser then
        ScenarioInfo.M1B1Cruiser2 = newCruiser
    end
    ScenarioFramework.CreateUnitGivenTrigger(M1CruiserGiven, newCruiser)
end

function M1ProtectCruisersObjective()
    while not ScenarioInfo.M1B1Cruiser1 do
        WaitSeconds(5)
    end
    local cruisers = {ScenarioInfo.M1B1Cruiser1}
    if ScenarioInfo.M1B1Cruiser2 then
        table.insert(cruisers, ScenarioInfo.M1B1Cruiser2)
    end
    -------------------------------------
    -- Bonus Objective - Protect Cruisers
    -------------------------------------
    ScenarioInfo.M1B1 = Objectives.Protect(
        'bonus',
        'incomplete',
        OpStrings.M1B1Title,
        OpStrings.M1B1Description,
        {
            Units = cruisers,
            MarkUnits = false,
            Hidden = true,
        }
    )
end

function M1ProtectCarriersObjective()
    -- Announce protect carriers objective
    ScenarioFramework.Dialogue(OpStrings.M1ProtectCarriers, nil, true)

    --------------------------------------
    -- Primary Objective - Protect Carrier
    --------------------------------------
    ScenarioInfo.M1P2 = Objectives.Protect(
        'primary',
        'incomplete',
        OpStrings.M1P2Title,
        OpStrings.M1P2Description,
        {
            Units = {ScenarioInfo.M1_Order_Carrier, ScenarioInfo.M1_Order_Tempest},
            NumRequired = 1,
        }
    )
    ScenarioInfo.M1P2:AddResultCallback(
        function(result, unit)
            if(not result and not ScenarioInfo.OpEnded) then
                ScenarioFramework.Dialogue(OpStrings.M1CarriersDied, nil, true)
                PlayerLose(unit)
            end
        end
    )

    -- Start a timer after 3 minutes
    ScenarioFramework.CreateTimerTrigger(M1TimerObjective, 3 * 60)
end

function M1TimerObjective()
    if ScenarioInfo.MissionNumber ~= 1 then
        return
    end

    -- Announce the timer objective
    ScenarioFramework.Dialogue(OpStrings.M1RevealTimer, nil, true)

    ------------------------------
    -- Primary Objective 3 - Timer
    ------------------------------
    -- Time limit for the first part of the mission
    local num = {30, 25, 20}
    ScenarioInfo.M1P3 = Objectives.Timer(
        'primary',
        'incomplete',
        OpStrings.M1P3Title,
        OpStrings.M1P3Description,
        {
            Timer = num[Difficulty] * 60,
            ExpireResult = 'failed',
        }
    )
    ScenarioInfo.M1P3:AddResultCallback(
        function(result)
            if not result then
                PlayerLose()
            end
        end
    )

    ScenarioFramework.Dialogue(OpStrings.M1TimerRevealed) --, nil, true)

    -- Objective reminder, 10 minutes before time's up
    num = {20, 15, 10}
    ScenarioFramework.CreateTimerTrigger(M1TimerObjReminder1, num[Difficulty] * 60)

    ScenarioFramework.CreateTimerTrigger(GateInACUsButton, 6 * 60)
end

-- Button to skip first part
function GateInACUsButton()
    -- Reveal Ping
    ScenarioFramework.Dialogue(OpStrings.M1GateInButton, nil, true)

    -- Setup ping
    ScenarioInfo.GateInPing = PingGroups.AddPingGroup(OpStrings.GateInButtonTitle, 'xsl0001', 'attack', OpStrings.GateInButtonDescription)
    ScenarioInfo.GateInPing:AddCallback(GateInDialogue)
end

function GateInDialogue()
    -- Create a comfirmation dialogue for skipping to next part of the mission
    local dialogue = CreateDialogue(OpStrings.GateInDialogue, {'<LOC _Yes>', '<LOC _No>'})
    dialogue.OnButtonPressed = function(self, info)
        dialogue:Destroy()
        if info.buttonID == 1 then
            ScenarioInfo.M1P2:ManualResult(true) -- Protct objective
            ScenarioInfo.M1P3:ManualResult(true) -- Timer
            if ScenarioInfo.M1B1.Active then -- Protect cruisers
                ScenarioInfo.M1B1:ManualResult(true)
            end
            ScenarioInfo.GateInPing:Destroy()
            ForkThread(IntroMission2)
        end
    end
end

-- Random Events
function M1RiptideAttack()
    -- Attack around the west edge of the map, first attacks the Tempest
    ScenarioInfo.RiptidePlatoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M1_Riptides_D' .. Difficulty, 'GrowthFormation') -- TODO: Destroy if map expands
    ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.RiptidePlatoon, 'M1_UEF_Riptide_Chain')

    -- Pick event again
    ScenarioFramework.ChooseRandomEvent(true, {7*60, 5*60, 3*60})
end

function M1SubmarineAttack()
    -- Spawn submarines, move them closer to the Carrier / Tempest and attack it
    ScenarioInfo.SubmarinePlatoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M1_UEF_Submarines_D' .. Difficulty, 'AttackFormation') -- TODO: Destroy if map expands

    ScenarioFramework.PlatoonMoveRoute(ScenarioInfo.SubmarinePlatoon, {'M1_UEF_Submarine_Marker'})

    -- Attack tempest if carries is dead
    if ScenarioInfo.M1_Order_Carrier and not ScenarioInfo.M1_Order_Carrier.Dead then
        ScenarioInfo.SubmarinePlatoon:AttackTarget(ScenarioInfo.M1_Order_Carrier)
    else
        ScenarioInfo.SubmarinePlatoon:AttackTarget(ScenarioInfo.M1_Order_Tempest)
    end

    -- Pick event again
    ScenarioFramework.ChooseRandomEvent(true, {7*60, 5*60, 3*60})
end

-- Reminders
function M1TimerObjReminder1()
    if not ScenarioInfo.M1P3.Active then
        return
    end

    -- 10 minutes remain
    ScenarioFramework.Dialogue(OpStrings.M1TimerObjReminder1)

    ScenarioFramework.CreateTimerTrigger(M1TimerObjReminder2, 5 * 60)
end

function M1TimerObjReminder2()
    if not ScenarioInfo.M1P3.Active then
        return
    end

    -- 5 minutes remain
    ScenarioFramework.Dialogue(OpStrings.M1TimerObjReminder2)

    ScenarioFramework.CreateTimerTrigger(M1TimerObjReminder3, 4 * 60)
end

function M1TimerObjReminder3()
    if not ScenarioInfo.M1P3.Active then
        return
    end

    -- 1 minute remains
    ScenarioFramework.Dialogue(OpStrings.M1TimerObjReminder3)
end

------------
-- Mission 2
------------
function IntroMission2()
    -- Remove any qeued up dialogues
    ScenarioFramework.FlushDialogueQueue()
    -- If there's some dialogue playing, wait until it's finished
    while(ScenarioInfo.DialogueLock) do
        WaitSeconds(0.2)
    end

    if ScenarioInfo.MissionNumber ~= 1 then
        return
    end
    ScenarioInfo.MissionNumber = 2

    -- Don't produce units for player anymore
    ArmyBrains[Order]:PBMRemoveBuildLocation(nil, 'AircraftCarrier1')
    ArmyBrains[Order]:PBMRemoveBuildLocation(nil, 'Tempest1')

    -- Move Carrier, Tempest and Sonar close to the island, make sure they won't die when moving
    local data = {
        ['M2_Order_Carrier_Marker_2'] = ScenarioInfo.M1_Order_Carrier,
        ['M2_Order_Starting_Tempest'] = ScenarioInfo.M1_Order_Tempest,
        ['M2_Order_Base_Marker'] = ScenarioInfo.M1_Order_Sonar,
    }
    for marker, unit in data do
        if unit and not unit.Dead then
            IssueClearCommands({unit})
            IssueMove({unit}, ScenarioUtils.MarkerToPosition(marker))
            unit:SetCanTakeDamage(false)
        end
    end

    -- Units can take damage again once on the playable area
    local function UnitDamageableAgain(unit)
        if unit then
            unit:SetCanTakeDamage(true)
        end
    end

    ScenarioFramework.CreateAreaTrigger(UnitDamageableAgain, 'M2_Area', categories.uas0303, true, false, ArmyBrains[Order])
    ScenarioFramework.CreateAreaTrigger(UnitDamageableAgain, 'M2_Area', categories.uas0401, true, false, ArmyBrains[Order])
    ScenarioFramework.CreateAreaTrigger(UnitDamageableAgain, 'M2_Area', categories.uas0305, true, false, ArmyBrains[Order])

    -- Move players' units to the new playable area and patrol, destroy UEF units
    ForkThread(function()
        WaitSeconds(1) -- wait for the map to expand, since players units can have orders only in the playable area

        for _, unit in GetUnitsInRect(ScenarioUtils.AreaToRect('M2_Offmap_Area')) do
            if unit:GetAIBrain() == ArmyBrains[UEF] then
                unit:Destroy()
            elseif EntityCategoryContains(categories.AIR, unit) and unit:GetAIBrain() ~= ArmyBrains[Order] then
                -- Air units need to be warped to the playable area, else they're getting stucked
                IssueClearCommands({unit})
                Warp(unit, ScenarioUtils.MarkerToPosition('M2_Air_Warp_Marker'))
                ScenarioFramework.GroupPatrolRoute({unit}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M2_Order_Base_AirDef_Chain')))
            elseif EntityCategoryContains(categories.NAVAL, unit) and unit:GetAIBrain() ~= ArmyBrains[Order] then
                IssueClearCommands({unit})
                ScenarioFramework.GroupPatrolChain({unit}, 'M2_Order_Defensive_Chain_West')
            end
        end
    end)

    -- Destroy random attacks if they are spawned, in case they are not off map yet
    if ScenarioInfo.RiptidePlatoon then
        for _, unit in ScenarioInfo.RiptidePlatoon:GetPlatoonUnits() do
            if not unit.Dead then
                unit:Destroy()
            end
        end
    end
    if ScenarioInfo.SubmarinePlatoon then
        for _, unit in ScenarioInfo.SubmarinePlatoon:GetPlatoonUnits() do
            if not unit.Dead then
                unit:Destroy()
            end
        end
    end

    -- Cinematics for the next part start looking at the Order base, so we will either spam Order AI or Player 2, 4, then camera moves to Seraphim starting position
    -- to spawn Player 1, 3
    if ScenarioInfo.UseOrderAI then
        -----------
        -- Order AI
        -----------
        -- Spawn Order ACU, sACU
        ScenarioInfo.OrderACU = ScenarioFramework.SpawnCommander('Order', 'M2_Order_ACU', 'Warp', 'Order Commander', false, false, -- TODO: Come up with a name
            {'ResourceAllocationAdvanced', 'EnhancedSensors', 'AdvancedEngineering', 'T3Engineering'})
        ForkThread(function()
            -- For some mysteriour reason this doesn't work without the delay
            WaitSeconds(3)
            -- Restrict T2 Torp launchers on the ACU so it won't get killed in the water.
            ScenarioInfo.OrderACU:AddBuildRestriction(categories.uab2205)
        end)

        ScenarioInfo.OrdersACU = ScenarioFramework.SpawnCommander('Order', 'M2_Order_sACU', 'Warp', 'Order sCDR', false, false, -- TODO: Come up with a name
            {'EngineeringFocusingModule', 'ResourceAllocation'})

        -- Order base AI and mobile factories AI
        M2OrderAI.OrderM2BaseAI()

        -- Start building from the Tempest once it arrives to the island. Without waiting until the tempest arrives it sometimes did not start moving at all
        --     and start building those units off-map.
        ForkThread(function()
            WaitSeconds(1) -- This makes sure that the carrier gets moving before we start the check below

            -- Some extra logic to make sure the stupid tempest actually gets moving as it likes to get stucked over high waves or some bullshit.
            local counter = 1
            while counter < 20 do
                if not ScenarioInfo.M1_Order_Tempest.Dead and not ScenarioInfo.M1_Order_Tempest:IsUnitState('Moving') then
                    IssueClearCommands({ScenarioInfo.M1_Order_Tempest})
                    IssueMove({ScenarioInfo.M1_Order_Tempest}, ScenarioUtils.MarkerToPosition('M2_Order_Starting_Tempest'))
                end

                WaitSeconds(1)
                counter = counter + 1
            end

            while (ScenarioInfo.M1_Order_Tempest and not ScenarioInfo.M1_Order_Tempest.Dead and ScenarioInfo.M1_Order_Tempest:IsUnitState('Moving')) do
                WaitSeconds(.5)
            end

            M2OrderAI.OrderM2TempestAI(ScenarioInfo.M1_Order_Tempest)
        end)

        -- If there are any units left in the carrier, make them patrol once carrier arrives to the island
        ForkThread(function()
            WaitSeconds(1) -- This makes sure that the carrier gets moving before we start the check below

            while (ScenarioInfo.M1_Order_Carrier and not ScenarioInfo.M1_Order_Carrier.Dead and ScenarioInfo.M1_Order_Carrier:IsUnitState('Moving')) do
                WaitSeconds(.5)
            end

            if ScenarioInfo.M1_Order_Carrier and not ScenarioInfo.M1_Order_Carrier.Dead then
                if table.getn(ScenarioInfo.M1_Order_Carrier:GetCargo()) > 0  then
                    IssueClearCommands({ScenarioInfo.M1_Order_Carrier})
                    IssueTransportUnload({ScenarioInfo.M1_Order_Carrier}, ScenarioInfo.M1_Order_Carrier:GetPosition())

                    -- Just to be sure all units are out
                    WaitSeconds(5)

                    local plat = ArmyBrains[Order]:MakePlatoon('', '')
                    for _, unit in ArmyBrains[Order]:GetListOfUnits(categories.AIR * categories.MOBILE, false) do
                        ArmyBrains[Order]:AssignUnitsToPlatoon(plat, {unit}, 'Attack', 'NoFormation')
                        IssueClearCommands({unit})
                        ScenarioFramework.GroupPatrolRoute({unit}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M2_Order_Base_AirDef_Chain')))
                    end
                end
            end

            M2OrderAI.OrderM2CarriersAI(ScenarioInfo.M1_Order_Carrier)
        end)

        if Difficulty <= 2 and ScenarioInfo.M1_Order_Sonar and not ScenarioInfo.M1_Order_Sonar.Dead then
            -- Make T3 Sonar Patrol, rebuild if killed
            local platoon = ArmyBrains[Order]:MakePlatoon('', '')
            ArmyBrains[Order]:AssignUnitsToPlatoon(platoon, {ScenarioInfo.M1_Order_Sonar}, 'Attack', 'NoFormation')
            ScenarioFramework.PlatoonPatrolChain(platoon, 'M2_Order_Defensive_Chain_Full')
            ScenarioFramework.CreateUnitDeathTrigger(M2OrderAI.OrderM2RebuildT3Sonar, ScenarioInfo.M1_Order_Sonar)
        else
            -- There is no sonar on hard difficulty, so set it to be built after few minutes
            ScenarioFramework.CreateTimerTrigger(M2OrderAI.OrderM2RebuildT3Sonar, 5 * 60)
        end

        -- Make sure the base will get started build fast, reset later
        ArmyBrains[Order]:PBMSetCheckInterval(6)
        ScenarioFramework.CreateTimerTrigger(ResetBuildInterval, 300)

        -- Triggers
        -- Assist first factory once build, get it asap to T3 so T3 engies can build base.
        ScenarioFramework.CreateArmyStatTrigger(M2T1AirFactoryBuilt, ArmyBrains[Order], 'M2T1AirFactoryBuilt',
            {{StatType = 'Units_Active', CompareType = 'GreaterThanOrEqual', Value = 1, Category = categories.FACTORY * categories.TECH1 * categories.AIR}})

        -- Stop assisting factory once it's on T3, get back to base building.
        ScenarioFramework.CreateArmyStatTrigger(M2T3AirFactoryBuilt, ArmyBrains[Order], 'M2T3AirFactoryBuilt',
            {{StatType = 'Units_Active', CompareType = 'GreaterThanOrEqual', Value = 1, Category = categories.FACTORY * categories.TECH3 * categories.AIR}})

        -- Give some mass to the AI at the beginning to speed up the building process.
        ScenarioFramework.CreateArmyStatTrigger(M2MassStoragedBuilt, ArmyBrains[Order], 'M2MassStoragedBuilt',
            {{StatType = 'Units_Active', CompareType = 'GreaterThanOrEqual', Value = 4, Category = categories.MASSSTORAGE * categories.TECH1 * categories.STRUCTURE}})

        -- Rebuild Tempest with a gun once more 7000 mass in the storage
        ScenarioFramework.CreateArmyStatTrigger(M2OrderAI.OrderM2RebuildTempest, ArmyBrains[Order], 'M2RebuildTempest',
            {{StatType = 'Economy_Stored_Mass', CompareType = 'GreaterThanOrEqual', Value = 7000}})
    else
        -- Spawn Player2 ACU
        ScenarioInfo.Player2CDR = ScenarioFramework.SpawnCommander('Player2', 'Commander', 'Warp', true, true, false,
            {'ResourceAllocation', 'AdvancedEngineering', 'T3Engineering'})

        -- Spawn Player4 or sACU for Player2
        local tblArmy = ListArmies()
        if tblArmy[ScenarioInfo.Player4] then
            ScenarioInfo.Player4CDR = ScenarioFramework.SpawnCommander('Player4', 'sACU', 'Warp', true, false, false,
                {'EngineeringFocusingModule', 'ResourceAllocation'})
        else
            ScenarioFramework.SpawnCommander('Player2', 'sACU', 'Warp', false, false, false,
                {'EngineeringFocusingModule', 'ResourceAllocation'})
        end

        -- Give Carrier to Player2 once near island
        ForkThread(function()
            WaitSeconds(1) -- This makes sure that the carrier gets moving before we start the check below

            while (ScenarioInfo.M1_Order_Carrier and not ScenarioInfo.M1_Order_Carrier.Dead and ScenarioInfo.M1_Order_Carrier:IsUnitState('Moving')) do
                WaitSeconds(.5)
            end

            if (ScenarioInfo.M1_Order_Carrier and not ScenarioInfo.M1_Order_Carrier.Dead) then
                IssueClearCommands({ScenarioInfo.M1_Order_Carrier})
                ScenarioFramework.GiveUnitToArmy(ScenarioInfo.M1_Order_Carrier, 'Player2')
            end
        end)

        -- Give Tempest to Player2 once near island
        ForkThread(function()
            WaitSeconds(1) -- This makes sure that the tempest gets moving before we start the check below

            while (ScenarioInfo.M1_Order_Tempest and not ScenarioInfo.M1_Order_Tempest.Dead and ScenarioInfo.M1_Order_Tempest:IsUnitState('Moving')) do
                WaitSeconds(.5)
            end

            if (ScenarioInfo.M1_Order_Tempest and not ScenarioInfo.M1_Order_Tempest.Dead) then
                IssueClearCommands({ScenarioInfo.M1_Order_Tempest})
                ScenarioInfo.M1_Order_Tempest = ScenarioFramework.GiveUnitToArmy(ScenarioInfo.M1_Order_Tempest, 'Player2')
                ScenarioInfo.M1_Order_Tempest:SetCanBeGiven(false)
                -- Disable the main gun again
                ScenarioInfo.M1_Order_Tempest:SetWeaponEnabledByLabel('MainGun', false)
                -- Override the function that enables the gun when unsubmerging
                local oldOnMotionVertEventChange = ScenarioInfo.M1_Order_Tempest.OnMotionVertEventChange
                ScenarioInfo.M1_Order_Tempest.OnMotionVertEventChange = function(self, new, old)
                    oldOnMotionVertEventChange(self, new, old)
                    if new == 'Top' then
                        self:SetWeaponEnabledByLabel('MainGun', false)
                    end
                end
            end
        end)

        -- Give Sonar to Player2 once near island
        ForkThread(function()
            WaitSeconds(1) -- This makes sure that the sonar gets moving before we start the check below
            
            while (ScenarioInfo.M1_Order_Sonar and not ScenarioInfo.M1_Order_Sonar.Dead and ScenarioInfo.M1_Order_Sonar:IsUnitState('Moving')) do
                WaitSeconds(.5)
            end
            if (ScenarioInfo.M1_Order_Sonar and not ScenarioInfo.M1_Order_Sonar.Dead) then
                IssueClearCommands({ScenarioInfo.M1_Order_Sonar})
                ScenarioFramework.GiveUnitToArmy(ScenarioInfo.M1_Order_Sonar, 'Player2')
            end
        end)
    end

    -- Remove off map Order eco buildings from first objective
    ScenarioFramework.DestroyGroup(ScenarioInfo.M1_Order_Eco)

    -- Temporary restrict T1 and T2 engineers for Order so it builds T3 in the base
    ScenarioFramework.AddRestriction(Order, categories.ual0105 + categories.ual0208)

    ---------
    -- Common
    ---------
    -- Spawn small island bases for both Cybran and UEF, type picked randomly
    ScenarioFramework.ChooseRandomBases()

    ------------
    -- Cybran AI
    ------------
    -- Spawn cybran base
    M2CybranAI.CybranM2BaseAI()

    -- Refresh build restrictions on engineers and factories
    ScenarioFramework.RefreshRestrictions('Cybran')

    -- Extra main island defences
    ScenarioUtils.CreateArmyGroup('Cybran', 'M2_Cybran_Base_Front_Defences_D' .. Difficulty)

    -- Initial Patrols
    -- Main Base

    -- Naval Patrol 
    local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2_Cybran_Naval_Patrol_D' .. Difficulty, 'NoFormation')
    for _, v in platoon:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M2_Cybran_Base_Naval_Defense_Chain')))
    end
    -- On medium and hard difficulty send a new patrol from off map once dead
    if Difficulty >= 2 then
        ScenarioFramework.CreatePlatoonDeathTrigger(M2CybranNavalPatrol, platoon)
    end

    -- Torp bombers snipe on tempest after 3 minuts (only if Order is not AI)
    if not ScenarioInfo.UseOrderAI then
        ScenarioFramework.CreateTimerTrigger(M2CybranAI.CybranM2TorpBombersSnipe, 3*60)
    end

    -- Air Patrol
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2_Cybran_Base_Air_Patrol_D' .. Difficulty, 'NoFormation')
    for _, v in platoon:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M2_Cybran_Base_AirDeffense_Chain')))
    end
    -- ASFs (hard difficulty, sent from off map,)
    if Difficulty == 3 then
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2_Cybran_Offmap_ASFs', 'NoFormation')
        for _, v in platoon:GetPlatoonUnits() do
            ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M2_Cybran_Base_AirDeffense_Chain')))
        end
        -- Trigger to rebuild if killed
        ScenarioFramework.CreatePlatoonDeathTrigger(M2CybranASFsPatrol, platoon)
    end

    -- TML Launchers
    for _, unit in ArmyBrains[Cybran]:GetListOfUnits(categories.urb2108, false) do
        local plat = ArmyBrains[Cybran]:MakePlatoon('', '')
        ArmyBrains[Cybran]:AssignUnitsToPlatoon(plat, {unit}, 'Attack', 'NoFormation')
        plat:ForkAIThread(plat.TacticalAI)
    end

    -- Walls
    ScenarioUtils.CreateArmyGroup('Cybran', 'M2_Cybran_Walls')
    
    ---------
    -- UEF AI
    ---------
    M2UEFAI.UEFM2BaseAI()

    -- Refresh build restrictions on engineers and factories
    ScenarioFramework.RefreshRestrictions('UEF')

    -- Initial Patrols
    -- Main Base

    -- Air Patrol
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M2_UEF_Base_Init_Air_Patrol_D' .. Difficulty, 'NoFormation')
    for _, v in platoon:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M2_UEF_Base_AirDef_Chain')))
    end

    -- Walls
    ScenarioUtils.CreateArmyGroup('UEF', 'M2_UEF_Walls')
      
    -- TML Launchers
    for k,unit in ArmyBrains[UEF]:GetListOfUnits(categories.ueb2108, false) do
        local plat = ArmyBrains[UEF]:MakePlatoon('', '')
        ArmyBrains[UEF]:AssignUnitsToPlatoon(plat, {unit}, 'Attack', 'NoFormation')
        plat:ForkAIThread(plat.TacticalAI)
    end

    --------
    -- Other
    --------
    if not SkipNIS2 then
        -- Spawn and open the satellites for the post intro
        ScenarioInfo.M2_Intro_Satellites = ScenarioUtils.CreateArmyGroup('UEF', 'M2_Satellites')
        for _, unit in ScenarioInfo.M2_Intro_Satellites do
            unit:Open()
        end
    end

    -- Destroy all wrecks that are offmap
    for _, prop in GetReclaimablesInRect(ScenarioUtils.AreaToRect('M2_Offmap_Area')) do
        if prop.IsWreckage then
            prop:Destroy()
        end
    end

    -- Give resources to AI armies
    ArmyBrains[UEF]:GiveResource('MASS', 10000)
    ArmyBrains[Cybran]:GiveResource('MASS', 10000)

    -- Launch NIS
    IntroMission2NIS()
end

-- Spawn island patrols depending on the base type
function M2CybranIslandUnits(baseType)
    if baseType == 'Naval' then
        -- Naval patrol around the base
        local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2_Cybran_Island_Naval_Patrol_D' .. Difficulty, 'NoFormation')
        for _, v in platoon:GetPlatoonUnits() do
            ScenarioFramework.GroupPatrolChain({v}, 'M2_Cybran_Island_Naval_Defense_Chain')
        end

    elseif baseType == 'Air' then
        -- Spawn carriers for unit production
        ScenarioUtils.CreateArmyGroup('Cybran', 'M2_Cybran_Carriers')

        -- Air patrol around the base
        local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2_Cybran_Island_Air_Patrol_D' .. Difficulty, 'NoFormation')
        for _, v in platoon:GetPlatoonUnits() do
            ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M2_Cybran_Island_Naval_Defense_Chain')))
        end
    end
end

function IntroMission2NIS()
    ScenarioFramework.SetPlayableArea('M2_Area', false)

    -- Start NIS
    local tblArmy = ListArmies()

    if not SkipNIS2 then
        Cinematics.EnterNISMode()
        -- Ensure that Order starts building base sooner rather than later
        ArmyBrains[Order]:PBMSetCheckInterval(2)

        WaitSeconds(1)
        ScenarioFramework.Dialogue(OpStrings.M2Intro1, nil, true)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_2_1'), 0)
        WaitSeconds(4)
        
        ScenarioFramework.Dialogue(OpStrings.M2Intro2, nil, true)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_2_2'), 3)

        -- Spawn Player1 and Player3
        ScenarioInfo.Player1CDR = ScenarioFramework.SpawnCommander('Player1', 'Commander', 'Warp', true, true, PlayerDeath,
            {'AdvancedEngineering', 'T3Engineering', 'ResourceAllocation'})

        if tblArmy[ScenarioInfo.Player3] then
            ScenarioInfo.Player3CDR = ScenarioFramework.SpawnCommander('Player3', 'sACU', false, true, false, false,
                {'EngineeringThroughput', 'EnhancedSensors'})
        else
            -- TODO: name for the sACU
            ScenarioFramework.SpawnCommander('Player1', 'sACU', 'Warp', false, false, false,
                {'EngineeringThroughput', 'EnhancedSensors'})
        end

        WaitSeconds(3)
        
        Cinematics.ExitNISMode()

        -- Set back to default
        ArmyBrains[Order]:PBMSetCheckInterval(6)
    else
        -- Spawn Player1 and Player3
        ScenarioInfo.Player1CDR = ScenarioFramework.SpawnCommander('Player1', 'Commander', 'Warp', true, true, false,
            {'AdvancedEngineering', 'T3Engineering', 'ResourceAllocation'})

        if tblArmy[ScenarioInfo.Player3] then
            ScenarioInfo.Player3CDR = ScenarioFramework.SpawnCommander('Player3', 'sACU', 'Warp', true, false, false,
                {'EngineeringThroughput', 'EnhancedSensors'})
        else
            -- TODO: name for the sACU
            ScenarioFramework.SpawnCommander('Player1', 'sACU', 'Warp', false, false, false,
                {'EngineeringThroughput', 'EnhancedSensors'})
        end
    end
    
    M2CounterAttack()
    M2PostIntro()
end

-- Order Base building functions
function ResetBuildInterval()
    ArmyBrains[Order]:PBMSetCheckInterval(6)
end

function M2T1AirFactoryBuilt()
    local factory = ArmyBrains[Order]:GetListOfUnits(categories.FACTORY * categories.AIR, false)
    IssueGuard({ScenarioInfo.OrderACU}, factory[1])
end

function M2T3AirFactoryBuilt()
    IssueStop({ScenarioInfo.OrderACU})
    IssueClearCommands({ScenarioInfo.OrderACU})

    -- Allow T1, T2 engineers again
    ScenarioFramework.RemoveRestriction(Order, categories.ual0105 + categories.ual0208)

    -- Trigger to assist naval factory once built
    ScenarioFramework.CreateArmyStatTrigger(M2T1NavalFactoryBuilt, ArmyBrains[Order], 'M2T1NavalFactoryBuilt',
        {{StatType = 'Units_Active', CompareType = 'GreaterThanOrEqual', Value = 1, Category = categories.FACTORY * categories.TECH1 * categories.NAVAL}})

    -- Trigger to start air attacks once at least 1 T3 pgens are built
    ScenarioFramework.CreateArmyStatTrigger(M2OrderAI.OrderM2BaseAirAttacks, ArmyBrains[Order], 'M2OrderT3AirAttacks',
        {{StatType = 'Units_Active', CompareType = 'GreaterThanOrEqual', Value = 1, Category = categories.ENERGYPRODUCTION * categories.STRUCTURE * categories.TECH3}})
end

function M2MassStoragedBuilt()
    ArmyBrains[Order]:GiveResource('MASS', 2500)
end

function M2T1NavalFactoryBuilt()
    local factory = ArmyBrains[Order]:GetListOfUnits(categories.FACTORY * categories.NAVAL * categories.STRUCTURE, false)

    IssueGuard({ScenarioInfo.OrderACU}, factory[1])

    ScenarioFramework.CreateArmyStatTrigger(M2T3NavalFactoryBuilt, ArmyBrains[Order], 'M2T3NavalFactoryBuilt',
        {{StatType = 'Units_Active', CompareType = 'GreaterThanOrEqual', Value = 1, Category = categories.FACTORY * categories.TECH3 * categories.NAVAL * categories.STRUCTURE}})
end

function M2T3NavalFactoryBuilt()
    -- Stop assisting naval HQ with ACU
    IssueStop({ScenarioInfo.OrderACU})
    IssueClearCommands({ScenarioInfo.OrderACU})

    -- Qeue up support factories right away so they are built as soon as possible
    local aiBrain = ScenarioInfo.OrderACU:GetAIBrain()
    local supportFactories = {'M2_Order_Naval_Support_Factory_1', 'M2_Order_Naval_Support_Factory_2'}

    for _, v in supportFactories do
        local unitData = ScenarioUtils.FindUnit(v, Scenario.Armies['Order'].Units)

        if unitData and aiBrain:CanBuildStructureAt(unitData.type, unitData.Position) then
            aiBrain:BuildStructure(ScenarioInfo.OrderACU, unitData.type, {unitData.Position[1], unitData.Position[3], 0}, false)
        end
    end

    ScenarioFramework.CreateArmyStatTrigger(M2T1LandFactoryBuilt, ArmyBrains[Order], 'M2T1LandFactoryBuilt',
        {{StatType = 'Units_Active', CompareType = 'GreaterThanOrEqual', Value = 1, Category = categories.FACTORY * categories.TECH1* categories.LAND * categories.STRUCTURE}})

    -- Start building naval units
    M2OrderAI.OrderM2BaseNavalAttacks()
end

function M2T1LandFactoryBuilt()
    local factory = ArmyBrains[Order]:GetListOfUnits(categories.FACTORY * categories.LAND * categories.STRUCTURE, false)

    IssueGuard({ScenarioInfo.OrdersACU}, factory[1])

    ScenarioFramework.CreateArmyStatTrigger(M2T3LandFactoryBuilt, ArmyBrains[Order], 'M2T3LandFactoryBuilt',
        {{StatType = 'Units_Active', CompareType = 'GreaterThanOrEqual', Value = 1, Category = categories.FACTORY * categories.TECH3 * categories.LAND * categories.STRUCTURE}})
end

function M2T3LandFactoryBuilt()
    -- Start land attacks
    M2OrderAI.OrderM2BaseLandAttacks()

    -- Stop assisting land HQ with ACU
    IssueStop({ScenarioInfo.OrdersACU})
    IssueClearCommands({ScenarioInfo.OrdersACU})

    -- Qeue up support factories right away so they are built as soon as possible
    local aiBrain = ScenarioInfo.OrderACU:GetAIBrain()
    local supportFactories = {'M2_Order_Land_Support_Factory_1', 'M2_Order_Land_Support_Factory_2'}

    for _, v in supportFactories do
        local unitData = ScenarioUtils.FindUnit(v, Scenario.Armies['Order'].Units)

        if unitData and aiBrain:CanBuildStructureAt(unitData.type, unitData.Position) then
            aiBrain:BuildStructure(ScenarioInfo.OrdersACU, unitData.type, {unitData.Position[1], unitData.Position[3], 0}, false)
        end
    end
    
    -- Put more engies on permanent assist
    M2OrderAI.OrderM2BaseEngieCount()
end

-- Initial counter attack
function M2CounterAttack()
    if M2NoCounterAttack then
        return
    end
    local platoon = nil

    ---------
    -- Cybran
    ---------
    -- Air
    for i = 1, 2 do
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2_Cybran_CA_Air_' .. i .. '_D' .. Difficulty, 'GrowthFormation')
        --ScenarioFramework.PlatoonPatrolChain(platoon, 'M2_Cybran_Init_Air_Attack_Chain_' .. i)
        for _, v in platoon:GetPlatoonUnits() do
            ScenarioFramework.GroupPatrolChain({v}, 'M2_Cybran_Init_Air_Attack_Chain_' .. i)
        end
    end

    -- Wagners
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2_Cybran_CA_Wagners_D' .. Difficulty, 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M2_Cybran_Init_Air_Attack_Chain_1')

    -- Naval
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2_Cybran_CA_Destroyers_D' .. Difficulty, 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M2_Cybran_Init_Naval_Attack_Chain')

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2_Cybran_CA_Frigates_D' .. Difficulty, 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M2_Cybran_Init_Naval_Attack_Chain')

    ------
    -- UEF
    ------
    -- Air
    for i = 1, 2 do
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M2_UEF_CA_Air_' .. i .. '_D' .. Difficulty, 'GrowthFormation')
        --ScenarioFramework.PlatoonPatrolChain(platoon, 'M2_UEF_Init_Air_Attack_Chain_' .. i)
        for _, v in platoon:GetPlatoonUnits() do
            ScenarioFramework.GroupPatrolChain({v}, 'M2_UEF_Init_Air_Attack_Chain_' .. i)
        end
    end

    -- Riptides
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M2_UEF_CA_Riptides_D' .. Difficulty, 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M2_UEF_Init_Riptide_Attack_Chain')

    -- Naval
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M2_UEF_CA_Destroyers_D' .. Difficulty, 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M2_UEF_Init_Naval_Attack_Chain')
end

-- Post Intro Satellites
function M2PostIntro()
    -- Pick a random event for second part of the mission
    ScenarioFramework.ChooseRandomEvent(true)

    -- Enable stealth on ASFs
    ForkThread(CustomFunctions.EnableStealthOnAir)

    if SkipNIS2 then
        M2SpawnQAI()
    else
        -- Attack the player with satellites, trigger to destroy them with a dialogue when they get close
        for _, unit in ScenarioInfo.M2_Intro_Satellites do
            -- Mark the units as in objective
            unit:SetStrategicUnderlay('icon_objective_primary')

            IssueAttack({unit}, ScenarioInfo.Player1CDR)
            ScenarioFramework.CreateUnitDistanceTrigger(M2SatellitesNearACU, unit, ScenarioInfo.Player1CDR, 170)

            -- Set up vision on the satellites
            local vizmarker = ScenarioFramework.CreateVisibleAreaAtUnit(20, unit, 0, ArmyBrains[Player1])
            unit.Trash:Add(vizmarker)
            vizmarker:AttachBoneTo(-1, unit, -1)
        end
    end
end

function M2SatellitesNearACU()
    if ScenarioInfo.M2_Intro_Sat_Destroyed then
        return
    end
    ScenarioInfo.M2_Intro_Sat_Destroyed = true

    ScenarioFramework.Dialogue(OpStrings.M2PostIntro1, M2DestroyPostIntroSatellites, true) -- Virus uploaded
end

function M2DestroyPostIntroSatellites()
    for _, unit in ScenarioInfo.M2_Intro_Satellites do
        unit:Kill()
        WaitSeconds(Random(0.5, 0.9))
    end
    ScenarioFramework.Dialogue(OpStrings.M2PostIntro2, M2SpawnQAI, true) -- What's happened to my HBO??
end

-- Spawn QAI
function M2SpawnQAI()
    if ScenarioInfo.QAI_Commander then
        return
    end

    -- Gate in ACU
    ScenarioInfo.QAI_Commander = ScenarioFramework.SpawnCommander('QAI', 'QAI_Commander', 'Warp', 'QAI', false, false,
        {'AdvancedEngineering', 'T3Engineering', 'ResourceAllocation'})

    WaitSeconds(5)

    -- Reclaim walls that are in the way
    IssueClearCommands({ScenarioInfo.QAI_Commander})
    for i = 1, 10 do
        if not ScenarioInfo.UnitNames[Objective]['Wall_' .. i].Dead then
            IssueReclaim({ScenarioInfo.QAI_Commander}, ScenarioInfo.UnitNames[Objective]['Wall_' .. i])
        end
    end

    -- ScenarioUtils.CreateArmyGroup('QAI', 'M2_QAI_Civs') -- TODO: Make QAI build these civ buildings

    WaitSeconds(2)

    -- Make sure everything is reclaimed before moving on
    while ScenarioInfo.QAI_Commander and not ScenarioInfo.QAI_Commander.Dead and not ScenarioInfo.QAI_Commander:IsIdleState() do
        WaitSeconds(1)
    end

    -- Cheat QAI's eco, since we don't want it to steal any mexes
    ScenarioInfo.QAI_Commander:ForkThread(function()
        while true do
            ArmyBrains[QAI]:GiveResource('MASS', 500)
            ArmyBrains[QAI]:GiveResource('ENERGY', 3000)
            WaitSeconds(1)
        end
    end)

    -- Start QAI's base
    M2QAIAI.QAIM2BaseAI()

    local function PerimetrBuilt()
        -- Dialogue to introduce Timer objective
        ScenarioFramework.Dialogue(OpStrings.M2TimerObjective, M2TimerObjective, true)
    end

    -- Trigger for timer objective
    ScenarioFramework.CreateArmyStatTrigger(PerimetrBuilt, ArmyBrains[QAI], 'PerimetrBuilt',
        {{StatType = 'Units_Active', CompareType = 'GreaterThanOrEqual', Value = 1, Category = categories.xrb3301}})

    StartMission2()
end

-- Assign objectives
function StartMission2()
    ----------------------------------
    -- Primary Objective - Protect QAI
    ----------------------------------
    ScenarioInfo.M2P1 = Objectives.Protect(
        'primary',
        'incomplete',
        OpStrings.M2P1Title,
        OpStrings.M2P1Description,
        {
            Units = {ScenarioInfo.QAI_Commander},
        }
    )
    ScenarioInfo.M2P1:AddResultCallback(
        function(result, unit)
            if(not result and not ScenarioInfo.OpEnded) then
                ScenarioFramework.Dialogue(OpStrings.M2QAIDead, nil, true)
                PlayerLose(unit)
            end
        end
    )
end

function M2TimerObjective()
    ------------------------------
    -- Primary Objective 5 - Timer
    ------------------------------
    ScenarioInfo.M2P2 = Objectives.Timer(
        'primary',
        'incomplete',
        OpStrings.M2P2Title,
        OpStrings.M2P2Description,
        {
            Timer = 20 * 60,
            ExpireResult = 'complete',
        }
    )
    ScenarioInfo.M2P2:AddResultCallback(
        function(result)
            if result then
                ScenarioInfo.M2P1:ManualResult(true)

                ScenarioFramework.Dialogue(OpStrings.M2TimerObjDone, IntroMission3, true)
            end
        end
    )

    ScenarioFramework.CreateTimerTrigger(M2TimerObjReminder1, 10 * 60)
end

-- Other M2 functions
function M2CybranASFsPatrol()
    -- Send new group of ASFs after 90 seconds
    ForkThread(function()
        WaitSeconds(90)

        if ScenarioInfo.MissionNumber == 2 then
            local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2_Cybran_Offmap_ASFs', 'NoFormation')
            -- Random patrol for each unit
            for _, v in platoon:GetPlatoonUnits() do
                ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M2_Cybran_Base_Naval_Defense_Chain')))
            end
            -- Trigger to rebuild again if killed
            ScenarioFramework.CreatePlatoonDeathTrigger(M2CybranASFsPatrol, platoon)
        end
    end)
end

function M2CybranNavalPatrol()
    -- Send new naval patrol after 2, 3 minutes
    ForkThread(function()
        WaitSeconds((5 - Difficulty) * 60)

        if ScenarioInfo.MissionNumber == 2 then
            local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2_Cybran_Offmap_Naval_Patrol_D' .. Difficulty, 'AttackFormation')
            -- Move closer to the island
            ScenarioFramework.PlatoonMoveRoute(platoon, {'M2_Cybran_Naval_Def_Regroup_Marker'})
            -- Random Patrol for each unit
            for _, v in platoon:GetPlatoonUnits() do
                ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M2_Cybran_Base_Naval_Defense_Chain')))
            end
            -- Trigger to rebuild again if killed
            ScenarioFramework.CreatePlatoonDeathTrigger(M2CybranNavalPatrol, platoon)
        end
    end)
end

-- Random events
function M2BattleshipAttack()
    -- Send group of battleships/unitities boat on attack. Pick randomly: 1 for west, 2 for east
    local army
    if Random(1, 2) == 1 then
        army = 'Cybran'
    else
        army = 'UEF'
    end

    local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon(army, 'M2_' .. army .. '_Battleship_Attack_D' .. Difficulty, 'GrowthFormation')

    local battleships = {}
    local utilityBoats = {}
    
    for _, unit in platoon:GetPlatoonUnits() do
        if EntityCategoryContains( categories.BATTLESHIP, unit ) then
            table.insert(battleships, unit)
        elseif EntityCategoryContains( categories.DEFENSIVEBOAT, unit ) then
            table.insert(utilityBoats, unit)
        end
    end

    ScenarioFramework.GroupFormPatrolChain(battleships, 'M2_' .. army .. '_Battleship_Chain', 'AttackFormation')

    -- Each battleship is assisted by one utility boat
    for i = 1, 3 do
        IssueGuard({utilityBoats[i]}, battleships[i])
    end
end

function M2CybranNukeSubAttack()
    -- Spawn nuke sub as a platoon for easier moving on thee map
    local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2_Cybran_Nuke_Sub', 'NoFormation')
    local nukeSub = platoon:GetPlatoonUnits()[1]

    local nukeMarkers = {'M2_Nuke_Marker_1', 'M2_Nuke_Marker_2', 'M2_Nuke_Marker_3', 'M2_Nuke_Marker_4'}
    local moveChains = {'M2_Nuke_Sub_Move_Chain_1', 'M2_Nuke_Sub_Move_Chain_2', 'M2_Nuke_Sub_Move_Chain_3'}

    while (nukeSub and not nukeSub.Dead) do
        -- Move it to attack position
        ScenarioFramework.PlatoonMoveChain(platoon, moveChains[Random(1, table.getn(moveChains))])

        -- Wait a bit to be sure it's really moving
        WaitSeconds(2)

        -- Wait till it arrives to the attack position
        while (nukeSub and not nukeSub.Dead and nukeSub:IsUnitState('Moving')) do
            WaitSeconds(5)
        end

        -- Check if sub didn't get killed
        if (not nukeSub or nukeSub.Dead) then
            return
        end

        -- Fire a nuke
        nukeSub:GiveNukeSiloAmmo(1)
        IssueNuke({nukeSub}, ScenarioUtils.MarkerToPosition(nukeMarkers[Random(1, table.getn(nukeMarkers))]))

        WaitSeconds(10)
        -- Check if sub didn't get killed
        if (not nukeSub or nukeSub.Dead) then
            return
        end

        IssueClearCommands({nukeSub})

        -- Move back to the edge of the map
        IssueMove({nukeSub}, ScenarioUtils.MarkerToPosition('M2_Nuke_Sub_Move_2'))

        -- Wait few minutes and repeat
        WaitSeconds((6 - Difficulty) * 60)
    end
end

function M2ExperimentalAttack()
    -- Spawn spider/fatboy and send it to the player's base
    local army
    if Random(1, 2) == 1 then
        army = 'Cybran'
    else
        army = 'UEF'
    end

    local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon(army, 'M2_' .. army ..'_Experimental_Attack', 'NoFormation')
    CustomFunctions.LandExperimentalAttackThread(platoon)
end

-- Reminders
function M2TimerObjReminder1()
    if not ScenarioInfo.M2P2.Active then
        return
    end

    -- 10 minutes remain
    ScenarioFramework.Dialogue(OpStrings.M2TimerObjReminder1)

    ScenarioFramework.CreateTimerTrigger(M2TimerObjReminder2, 5 * 60)
end

function M2TimerObjReminder2()
    if not ScenarioInfo.M2P2.Active then
        return
    end

    -- 5 minutes remain
    ScenarioFramework.Dialogue(OpStrings.M2TimerObjReminder2)
end

------------
-- Mission 3
------------
function IntroMission3()
    -- Remove any qeued up dialogues
    ScenarioFramework.FlushDialogueQueue()
    -- If there's some dialogue playing, wait until it's finished
    while(ScenarioInfo.DialogueLock) do
        WaitSeconds(0.2)
    end

    if ScenarioInfo.MissionNumber ~= 2 then
        return
    end
    ScenarioInfo.MissionNumber = 3

    ------------
    -- Cybran AI
    ------------
    -- Cybran ACU -- TODO: Name
    ScenarioInfo.CybranCommander = ScenarioFramework.SpawnCommander('Cybran', 'M3_Cybran_Commander', false, 'Cybran Commander', false, false,
        {'AdvancedEngineering', 'T3Engineering', 'Teleporter', 'MicrowaveLaserGenerator'})

    -- Main Base
    M3CybranAI.CybranM3BaseAI()

    -- Extra defenses around the base
    ScenarioUtils.CreateArmyGroup('Cybran', 'M3_Cybran_Extra_Defenses_D' .. Difficulty)

    -- Refresh build restrictions on engineers and factories
    ScenarioFramework.RefreshRestrictions('Cybran')

    -- Air Patrol Main Base
    -- Random patrol
    local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M3_Main_Base_Air_Patrol_D' .. Difficulty, 'NoFormation')
    for _, v in platoon:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M3_Cybran_Base_AirPatrol_Chain')))
    end

    -- Chain around the island
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M3_Main_Base_Air_Patrol_2_D' .. Difficulty, 'NoFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_Cybran_Base_NavalPatrol_Full_Chain')

    -- Naval
    -- Naval Patrol Main Base
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M3_Main_Base_Naval_Patrol_D' .. Difficulty, 'NoFormation')
    for _, v in platoon:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M3_Cybran_Base_NavalPatrol_Chain')))
    end

    -- Battleships around the island
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M3_Main_Base_Battleships', 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_Cybran_Base_NavalPatrol_Full_Chain')

    -- T2 groups
    for i = 1, 3 do
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M3_Main_Base_T2_Naval_Patrol_' .. i .. '_D' .. Difficulty, 'AttackFormation')
        ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_Cybran_Base_NavalPatrol_Chain_' .. i)
    end

    -- Subhunteers
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2_Main_Base_Subhunters_D' .. Difficulty, 'NoFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_Cybran_Base_NavalPatrol_Full_Chain')

    -- Carriers and Battleships
    if Difficulty >= 2 then
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M3_Main_Base_Carriers_D' .. Difficulty, 'GrowthFormation')
        ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_Cybran_Base_NavalPatrol_Full_Chain')
    end

    -- Extra sonar to hide units
    if Difficulty >= 3 then
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M3_Main_Base_Sonar_2', 'GrowthFormation')
        ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_Cybran_Base_Sonar_Chain_2')
    end

    -- Static units in the base
    ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M3_Main_Base_Static_Units_D' .. Difficulty, 'NoFormation')

    -- Soul Rippers
    ScenarioInfo.M3SouRipperPlatoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M3_Main_Base_SoulRipper_Patrol_D' .. Difficulty, 'AttackFormation')
    for _, v in ScenarioInfo.M3SouRipperPlatoon:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M3_Cybran_Base_AirPatrol_Chain')))
    end

    ---------
    -- UEF AI
    ---------
    -- UEF ACU -- TODO: Name
    ScenarioInfo.UEFCommander = ScenarioFramework.SpawnCommander('UEF', 'M3_Commander', false, 'UEF Commander', false, UEFCommanderKilled,
        {'AdvancedEngineering', 'T3Engineering', 'ResourceAllocation', 'Shield'})

    ScenarioInfo.M3AtlantisPlatoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M3_Base_Atlantis', 'AttackFormation')
    ScenarioInfo.M3Atlantis = ScenarioInfo.M3AtlantisPlatoon:GetPlatoonUnits()[1]

    -- Main base
    M3UEFAI.UEFM3BaseAI()

    -- Extra defenses around the main base
    ScenarioUtils.CreateArmyGroup('UEF', 'M3_UEF_Extra_Defense_D' .. Difficulty)

    -- Refresh build restrictions on engineers and factories
    ScenarioFramework.RefreshRestrictions('UEF')

    -- Walls
    ScenarioUtils.CreateArmyGroup('UEF', 'M3_Walls')

    -- Manage Novaxes
    ForkThread(M3NovaxMonitor)

    -- Air Patrol Main Base
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M3_Base_Air_Patrol_D' .. Difficulty, 'NoFormation')
    for _, v in platoon:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M3_UEF_Base_Novax_Patrol_Chain')))
    end

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M3_Base_Air_Patrol_2_D' .. Difficulty, 'NoFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_UEF_Naval_Patrol_Chain_Full')

    -- Naval Patrol
    -- Static
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M3_UEF_Naval_Static_D' .. Difficulty, 'NoFormation')

    -- Battleships around island
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M3_UEF_Battleships_1_D' .. Difficulty, 'NoFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_UEF_Naval_Patrol_Chain_Full')

    -- Battleships south of island
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M3_UEF_Battleships_2_D' .. Difficulty, 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_UEF_Battleship_Patrol_Chain')

    -- Battlecruisers south of island
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M3_UEF_Battlecruisers_1_D' .. Difficulty, 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_UEF_Battlecruiser_Patrol_Chain_1')

    -- T3 Navy west of island
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M3_Base_Naval_T3_Patrol_West_D' .. Difficulty, 'NoFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_UEF_Naval_T3_Patrol_West_Chain')

    -- Cruisers
    for i = 1, 3 do
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M3_UEF_Cruisers_' .. i .. '_D' .. Difficulty, 'NoFormation')
        ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_UEF_Cruiser_Patrol_Chain_' .. i)
    end
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M3_UEF_Cruisers_4_D' .. Difficulty, 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_UEF_Cruiser_Patrol_Chain_4')

    -- T2 Groups
    for i = 1, 3 do
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M3_UEF_T2_Naval_' .. i .. '_D' .. Difficulty, 'GrowthFormation')
        ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_UEF_Naval_T2_Patrol_Chain_' .. i)
    end
    
    -- T1 Submarines
    for i = 1, 3 do
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M3_Base_Submarines_' .. i .. '_D' .. Difficulty, 'AttackFormation')
        ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_UEF_Submarines_South_Chain_' .. i)
    end

    -- Frigates on random patrol, for more jamming
    for i = 1, 2 do
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M3_Base_Naval_Patrol_' .. i ..'_D' .. Difficulty, 'NoFormation')
        for _, v in platoon:GetPlatoonUnits() do
            ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M3_UEF_Naval_Patrol_Chain_' .. i)))
        end
    end
    

    -- local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M3_UEF_Naval_Force_D' .. Difficulty, 'NoFormation')
    -- ForkThread(CustomFunctions.NavalForceAI, platoon)

    ---------
    -- Common
    ---------
    -- Random naval base in the middle of sea.
    ScenarioFramework.ChooseRandomBases()

    ------------
    -- Objective
    ------------
    ScenarioInfo.M3_Research_Buildings = ScenarioUtils.CreateArmyGroup('Objective', 'M3_Objective_Structures')

    -- Other civ buildings
    ScenarioUtils.CreateArmyGroup('Objective', 'M3_Other_Structures')
    -- More HP for objective buildings
    local unit = ScenarioInfo.UnitNames[Objective]['Station_Alpha']
    unit:SetCustomName('Novax Station Alpha')
    unit:SetMaxHealth(6250)
    unit:SetHealth(unit, 6250)
    unit = ScenarioInfo.UnitNames[Objective]['Station_Beta']
    unit:SetCustomName('Novax Station Beta')
    unit:SetMaxHealth(6250)
    unit:SetHealth(unit, 6250)

    -- Mass for the AI
    ArmyBrains[Cybran]:GiveResource('Mass', 15000)
    ArmyBrains[UEF]:GiveResource('Mass', 15000)

    -- Unit Cap
    ScenarioFramework.SetSharedUnitCap(2000)

    ForkThread(IntroMission3NIS)
end

function IntroMission3NIS()
    ScenarioFramework.SetPlayableArea('M3_Area', false)

    if not SkipNIS3 then
        -- Vision over the Cybran and UEF base, also on some Novax centers and the research station
        local VisMarker1 = ScenarioFramework.CreateVisibleAreaLocation(30, 'M3_Vision_Marker_Cybran_1', 0, ArmyBrains[Player1])
        local VisMarker2 = ScenarioFramework.CreateVisibleAreaLocation(30, 'M3_Vision_Marker_Cybran_2', 0, ArmyBrains[Player1])
        local VisMarker3 = ScenarioFramework.CreateVisibleAreaLocation(40, 'M3_Vision_Marker_UEF_1', 0, ArmyBrains[Player1])
        local VisMarker4 = ScenarioFramework.CreateVisibleAreaLocation(35, 'M3_Vision_Marker_UEF_2', 0, ArmyBrains[Player1])
        local VisMarker5 = ScenarioFramework.CreateVisibleAreaLocation(20, 'M3_Vision_Marker_UEF_3', 0, ArmyBrains[Player1])
        
        Cinematics.EnterNISMode()
        Cinematics.SetInvincible('M2_Area')

        WaitSeconds(1)

        -- Init cam at the monitoring station
        Cinematics.CameraMoveToMarker('Cam_3_1', 0)
        ScenarioFramework.Dialogue(OpStrings.M3Intro1, nil, true)

        WaitSeconds(3)

        -- Tilt the camera up so see the north islands
        Cinematics.CameraMoveToMarker('Cam_3_2', 2)

        WaitSeconds(3)

        -- Cam at the first island with the Cybran base
        ScenarioFramework.Dialogue(OpStrings.M3Intro2, nil, true)
        Cinematics.CameraMoveToMarker('Cam_3_3', 5)

        WaitSeconds(3)

        -- The other island with UEF base and satellites
        ScenarioFramework.Dialogue(OpStrings.M3Intro3, nil, true)
        Cinematics.CameraMoveToMarker('Cam_3_4', 4)

        WaitSeconds(3)

        -- Zoom to the novax buildings
        ScenarioFramework.Dialogue(OpStrings.M3Intro4, nil, true)
        Cinematics.CameraMoveToMarker('Cam_3_5', 3)

        WaitSeconds(3)

        -- Show the civinian buildings
        ScenarioFramework.Dialogue(OpStrings.M3Intro5, nil, true)
        Cinematics.CameraMoveToMarker('Cam_3_6', 3)

        WaitSeconds(3)

        -- Zoom out to the top view of the UEF island and reset the cam
        Cinematics.CameraMoveToMarker('Cam_3_7', 2)

        WaitSeconds(1)

        -- Remove the vision
        VisMarker1:Destroy()
        VisMarker2:Destroy()
        VisMarker3:Destroy()
        VisMarker4:Destroy()
        VisMarker5:Destroy()

        -- Remove intel on the Aeon base on high difficulty
        --if Difficulty == 3 then
        --    ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('VizMarker_1'), 40)
        --end
        Cinematics.SetInvincible('M2_Area', true)

        Cinematics.ExitNISMode()
    end

    StartMission3()
end

function StartMission3()
    -------------------------------------------------
    -- Primary Objective - Wipe out research stations
    -------------------------------------------------
    ScenarioInfo.M3P1 = Objectives.Kill(
        'primary',
        'incomplete',
        OpStrings.M3P1Title,
        OpStrings.M3P1Description,
        {
            Units = {
                ScenarioInfo.UnitNames[Objective]['Station_Alpha'],
                ScenarioInfo.UnitNames[Objective]['Station_Beta'],
            },
        }
    )
    ScenarioInfo.M3P1:AddResultCallback(
        function(result, unit)
            if result then
                if ScenarioInfo.M3P2.Active then
                    ScenarioFramework.Dialogue(OpStrings.M3AllResearchDestroyed, nil, true)
                else
                    ForkThread(PlayerWin, unit, OpStrings.M3AllResearchDestroyed)
                end
            end
        end
    )
    ScenarioInfo.M3P1:AddProgressCallback(
        function(numKilled, total)
            if numKilled == 1 then
                if ScenarioInfo.OrderACU and not ScenarioInfo.OrderACU.Dead then
                    ScenarioFramework.Dialogue(OpStrings.M3FirstResearchDestroyed)
                else
                    ScenarioFramework.Dialogue(OpStrings.M3FirstResearchDestroyedAlt)
                end
            end
        end
    )

    --------------------------------------
    -- Primary Objective - Destroy Novaxes
    --------------------------------------
    local units = ArmyBrains[UEF]:GetListOfUnits(categories.xeb2402, false)
    ScenarioInfo.M3P2 = Objectives.Kill(
        'primary',
        'incomplete',
        OpStrings.M3P2Title,
        OpStrings.M3P2Description,
        {
            Units = units,
        }
    )
    ScenarioInfo.M3P2:AddResultCallback(
        function(result, unit)
            if result then
                local dialogue = OpStrings.M3AllNovaxesDestroyed
                if ScenarioInfo.OrderACU and ScenarioInfo.OrderACU.Dead then
                    dialogue = OpStrings.M3AllNovaxesDestroyedAlt
                end

                if ScenarioInfo.M3P1.Active then
                    ScenarioFramework.Dialogue(dialogue, nil, true)
                else
                    ForkThread(PlayerWin, unit, dialogue)
                end
            end
        end
    )
    ScenarioInfo.M3P2:AddProgressCallback(
        function(numKilled, total)
            if numKilled == 1 then
                ScenarioFramework.Dialogue(OpStrings.M3FirstNovaxDestroyed)
            elseif numKilled == math.floor(table.getn(units) * 0.75) then
                ScenarioFramework.Dialogue(OpStrings.M3MostNovaxesDestroyed)
            end
        end
    )

    ------------------------------------------------
    -- Secondary Objective - Defeat Cybran Commander
    ------------------------------------------------
    ScenarioInfo.M3S1 = Objectives.Kill(
        'secondary',
        'incomplete',
        OpStrings.M3S1Title,
        OpStrings.M3S1Description,
        {
            Units = {ScenarioInfo.CybranCommander},
            FlashVisible = true,
        }
    )
    ScenarioInfo.M3S1:AddResultCallback(
        function(result, unit)
            if result then
                if ScenarioInfo.OrderACU and not ScenarioInfo.OrderACU.Dead then
                    ScenarioFramework.Dialogue(OpStrings.M3CybranCommanderDefeated)
                else
                    ScenarioFramework.Dialogue(OpStrings.M3CybranCommanderDefeatedAlt)
                end
            end
        end
    )

    -- Pick a random event for the last part of the mission
    ScenarioFramework.ChooseRandomEvent(true)

    -- Restrict UEF from rebuilding destroyed novaxes
    --ScenarioFramework.AddRestriction(UEF, categories.xeb2402)

    -- Dialogue when the player sees the satellites
    ScenarioFramework.CreateArmyIntelTrigger(M3NovaxesSpotted, ArmyBrains[Player1], 'LOSNow', false, true, categories.xea0002, true, ArmyBrains[UEF])

    for i, player in ScenarioInfo.HumanPlayers do
        -- Build T3 arty in the Cybran base if players start building one.
        ScenarioFramework.CreateArmyStatTrigger(M3CybranAIBuildArty, ArmyBrains[player], 'M3ArtyTrigger' .. i,
            {{StatType = 'Units_BeingBuilt', CompareType = 'GreaterThanOrEqual', Value = 1, Category = categories.TECH3 * categories.STRUCTURE * categories.ARTILLERY}})

        -- Build Scathis/Mavor once player starts building some game ender
        ScenarioFramework.CreateArmyStatTrigger(M3AIBuildGameEnders, ArmyBrains[player], 'M3EndGamerTrigger' .. i,
            {{StatType = 'Units_BeingBuilt', CompareType = 'GreaterThanOrEqual', Value = 1, Category = categories.xsb2401 + categories.xab1401 + categories.ueb2401 + categories.xab2307 + categories.url0401}})
    end

    if ScenarioInfo.UseOrderAI then
        -- Allow players to choose target for the order AI
        ScenarioFramework.CreateTimerTrigger(M3StartOrderAttacks, 60)
    end
end

function M3NovaxMonitor()
    local novaxtbl = {}
    while true do
        local units = ArmyBrains[UEF]:GetListOfUnits(categories.xea0002, false)
        for _, v in units do
            local id = v:GetEntityId()
            if not novaxtbl[id] then
                novaxtbl[id] = true
                local platoon = ArmyBrains[UEF]:MakePlatoon('', '')
                ArmyBrains[UEF]:AssignUnitsToPlatoon(platoon, {v}, 'Attack', 'AttackFormation')
                platoon:ForkAIThread(CustomFunctions.ManageNovaxThread)
            end
        end

        WaitSeconds(30)
    end
end

function M3CybranAIBuildArty()
    WARN('M3CybranAIBuildArty')
    if ScenarioInfo.M3CybranArty then
        return
    end
    ScenarioInfo.M3CybranArty = true

    M3CybranAI.BuildArty()
end

function M3AIBuildGameEnders()
    WARN('M3AIBuildGameEnders')
    if ScenarioInfo.M3AIBuildsGameEnders then
        return
    end
    ScenarioInfo.M3AIBuildsGameEnders = true

    M3CybranAI.BuildScathis()
    -- T3 Arty on Easy else Mavor
    M3UEFAI.BuildArty() 
end

-- When player sees the satellites
function M3NovaxesSpotted()
    ScenarioFramework.Dialogue(OpStrings.M3NovaxDialogue)
end

-- Allow player to tell Order AI what to target
function M3StartOrderAttacks()
    -- Tell the player that he can choose the base the Order AI will focus on
    ScenarioFramework.Dialogue(OpStrings.M3StartingOrderAttacks, nil, false, ScenarioInfo.OrderACU)

    M2OrderAI.OrderM3AirAttacks()
    M2OrderAI.OrderM3LandAttacks()
    M2OrderAI.OrderM3NavalAttacks()

    -- Setup ping
    ScenarioInfo.OrderAttackPing = PingGroups.AddPingGroup(OpStrings.M3OrderAttackPingTitle, nil, 'attack', OpStrings.M3OrderAttackPingDescription)
    ScenarioInfo.OrderAttackPing:AddCallback(M3SetNewTarget)

    ScenarioInfo.M3OrderTarget = 'Cybran_Island'
end

local EnemyBasesRectangles = {
    ['Cybran_Island'] = {
        rectangle = ScenarioUtils.AreaToRect('M2_Cybran_Base_Area'),
        dialogue = OpStrings.M3NewOrderTargetCybranIsland,
        cleared = false,
    },
    ['UEF_Island'] = {
        rectangle =  ScenarioUtils.AreaToRect('M2_UEF_Base_Area'),
        dialogue = OpStrings.M3NewOrderTargetUEFIsland,
        cleared = false,
    },
    ['Cybran_Main'] = {
        rectangle = ScenarioUtils.AreaToRect('M3_Cybran_Main_Base_Area'),
        dialogue = OpStrings.M3NewOrderTargetCybranMain,
        cleared = false,
    },
    ['UEF_Main'] = {
        rectangle = ScenarioUtils.AreaToRect('M3_UEF_Main_Base_Area'),
        dialogue = OpStrings.M3NewOrderTargetUEFMain,
        cleared = false,
    },
}
local areaDialogueLock = false

function M3UnlockAreaDialogue()
    areaDialogueLock = false
end

function M3SetNewTarget(location)
    local newTarget = false
    local cleared = false
    local dialogue = false

    for name, data in EnemyBasesRectangles do
        local rec = data.rectangle
        if location[1] > rec.x0 and location[1] < rec.x1 and location[3] > rec.y0 and location[3] < rec.y1 then
            newTarget = name
            cleared = data.cleared
            dialogue = data.dialogue
            break
        end
    end

    if newTarget and newTarget ~= ScenarioInfo.M3OrderTarget and not cleared then
        LOG('*DEBUG: AttackPing: New target set: ' .. newTarget)
        ScenarioInfo.M3OrderTarget = newTarget

        -- Show the players that the target was set successfully
        print(LOC(OpStrings.M3TargetAreaSet))
        -- Prevent the dialogue spam if clicking like a mad man
        if not areaDialogueLock then
            ScenarioFramework.Dialogue(dialogue, nil, false, ScenarioInfo.OrderACU)
            areaDialogueLock = true
            ScenarioFramework.CreateTimerTrigger(M3UnlockAreaDialogue, 20)
        end
        M2OrderAI.SetNewTarget(newTarget)
    elseif newTarget and cleared then
        -- This base is already destroyed
        print(LOC(OpStrings.M3AreaCleared))
        LOG('*DEBUG: AttackPing: Trying to set new area: ' .. newTarget .. ' but it was already destroyed.')
    elseif newTarget and newTarget == ScenarioInfo.M3OrderTarget then
        -- This is a targeted already
        print(LOC(OpStrings.M3SameArea))
        LOG('*DEBUG: AttackPing: Trying to set new area: ' .. newTarget .. ' but it is the current target already.')
    else
        -- Gotta click on some island
        print(LOC(OpStrings.M3InvalidArea))
        LOG('*DEBUG: AttackPing: Ping was not in any area.')
    end
end

function CybranACUWarp()
end

function UEFCommanderKilled()
    ScenarioFramework.Dialogue(OpStrings.M3UEFCommanderKilled)
end

-- Random Events
function M3SoulRipperAttack()
    -- If the Soul Ripper are dead already, pick some different event
    if not ArmyBrains[Cybran]:PlatoonExists(ScenarioInfo.M3SouRipperPlatoon) then
        ScenarioFramework.ChooseRandomEvent(false)
        return
    end

    -- Send the Soul Rippers on attack
    ScenarioInfo.M3SouRipperPlatoon:Stop()
    ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.M3SouRipperPlatoon, 'M3_Cybran_Air_Attack_Chain_' .. Random(1, 4))

    -- Send ASFs to protect the Soul Rippers if there's a carrier in the Cybran base
    local carrier = ScenarioInfo.UnitNames[Cybran]['M3_Carrier']
    local ASFPlatoons = {}
    if carrier and not carrier.Dead then
        -- 15 ASFs for each Sour Ripper
        for i = 1, table.getn(ScenarioInfo.M3SouRipperPlatoon:GetPlatoonUnits()) do
            ASFPlatoons[i] = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M3_Carrier_ASFs', 'AttackFormation')
            for _, v in ASFPlatoons[i]:GetPlatoonUnits() do
                IssueStop({v})
                carrier:AddUnitToStorage(v)
            end
        end

        -- Release the ASFs
        IssueTransportUnload({carrier}, carrier:GetPosition())
        for _, platoon in ASFPlatoons do
            for _, unit in platoon:GetPlatoonUnits() do
                while (not unit.Dead and unit:IsUnitState('Attached')) do
                    WaitSeconds(1)
                end
            end
        end

        for index, platoon in ASFPlatoons do
            platoon:Stop()
            platoon:GuardTarget(ScenarioInfo.M3SouRipperPlatoon:GetPlatoonUnits()[index])
            platoon:AggressiveMoveToLocation(ScenarioUtils.MarkerToPosition('M2_QAI_Base_Marker'))
        end
    end
end

function M3AtlantisHunters()
    -- Atlantis to build ASF platoon to hunt down any air experimental approaching the UEF base.
    if ScenarioInfo.M3Atlantis and not ScenarioInfo.M3Atlantis.Dead then
        --local units = ScenarioUtils.CreateArmyGroup('UEF', 'M3_Atlantis_Support')
        --for _, unit in units do
        --    ScenarioInfo.M3Atlantis:AddUnitToStorage(unit)
        --end
        ScenarioInfo.M3AtlantisPlatoon:ForkAIThread(CustomFunctions.AtlantisThread)
        IssueDive({ScenarioInfo.M3Atlantis})
    end
end

-----------
-- End Game
-----------
function CheckWinCondition()
    if Objectives.IsComplete(ScenarioInfo.M3P1) and Objectives.IsComplete(ScenarioInfo.M3P2) then
        PlayerWin()
    end
end

function PlayerWin(unit, dialogue)
    if not ScenarioInfo.OpEnded then
        ScenarioFramework.EndOperationSafety()
        ScenarioInfo.OpComplete = true

        ScenarioFramework.CDRDeathNISCamera(unit)

        ScenarioFramework.FlushDialogueQueue()

        ScenarioFramework.Dialogue(dialogue, nil, true)

        ScenarioFramework.Dialogue(OpStrings.PlayerWin, KillGame, true)
    end
end

function PlayerLose(unit)
    if Debug then return end
    ForkThread(
        function(unit)
            if unit then
                -- Unit from protect objective dies
                -- Circle camera around the unit
                ScenarioFramework.CDRDeathNISCamera(unit)
                WaitSeconds(8)
            else
                -- Timer runs out (Mission 1)
                if ScenarioInfo.MissionNumber ~= 1 then
                    WARN('Timer from the first mission didn\'t end.')
                    return
                end

                -- Attack with sattelites
                local units = ScenarioUtils.CreateArmyGroup('UEF', 'M1_Satellites')
                for i = 1, 2 do
                    units[i]:Open()
                    IssueAttack({units[i]}, ScenarioInfo.M1_Order_Carrier)
                end
                for i = 3, 5 do
                    units[i]:Open()
                    IssueAttack({units[i]}, ScenarioInfo.M1_Order_Tempest)
                end

                -- Move camera to carriers
                Cinematics.EnterNISMode()

                Cinematics.CameraMoveToMarker('Cam_1_Fail_1', 3)
                ScenarioFramework.Dialogue(OpStrings.M1TimeRanOut, nil, true)
                WaitSeconds(2)
                Cinematics.CameraMoveToMarker('Cam_1_Fail_2', 3)
                WaitSeconds(2)

                -- Track one satellite
                Cinematics.CameraTrackEntity(units[4], 95)

                WaitSeconds(11)
                ScenarioInfo.M1_Order_Carrier:Kill()
                ScenarioInfo.M1_Order_Tempest:Kill()

                WaitSeconds(4)
            end

            -- End the mission
            ScenarioFramework.PlayerLose(OpStrings.KillGameDialogue)
        end, unit
    )
end

function PlayerDeath(deadCommander)
    if Debug then return end
    ScenarioFramework.PlayerDeath(deadCommander, OpStrings.PlayerDead)
end

function KillGame()
    local secondary = Objectives.IsComplete(ScenarioInfo.M1S1) and Objectives.IsComplete(ScenarioInfo.M3S1)
    local bonus = Objectives.IsComplete(ScenarioInfo.M1B1)
    ScenarioFramework.EndOperation(ScenarioInfo.OpComplete, ScenarioInfo.OpComplete, secondary, bonus)
end

---------
-- Taunts
---------
function SetupUEFM1TauntTriggers()
    UEFTM:AddEnemiesKilledTaunt('M1UEFTaunt1', ArmyBrains[UEF], categories.NAVAL, 15)
    UEFTM:AddUnitsKilledTaunt('M1UEFTaunt2', ArmyBrains[UEF], categories.NAVAL, 40)
    UEFTM:AddUnitsKilledTaunt('M1UEFTaunt3', ArmyBrains[UEF], categories.ANTINAVY * categories.DEFENSE, 1)
end

function SetupOrderM2TauntTriggers()
    OrderTM:AddTauntingCharacter(ScenarioInfo.OrderACU)

    OrderTM:AddUnitKilledTaunt('OrdersACUKilled2', ScenarioInfo.OrdersACU)
end

function SetupUEFM2TauntTriggers()
    UEFTM:AddUnitKilledTaunt('OrdersACUKilled1', ScenarioInfo.OrdersACU)
end

function SetupOrderM3TauntTriggers()

end

function SetupUEFM3TauntTriggers()
    UEFTM:AddTauntingCharacter(ScenarioInfo.UEFCommander)
end

    -- Player CDR is damaged
    --GariTM:AddDamageTaunt('TAUNT14', ScenarioInfo.PlayerCDR, .05)

function SetupOrderM3TauntTriggers()
    
end



------------------
-- Debug Functions
------------------
function OnCtrlF3()
    --local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M3_UEF_Naval_Force_D' .. Difficulty, 'NoFormation')
    --ForkThread(CustomFunctions.NavalForceAI, platoon)
    
    M3AtlantisHunters()
end

function OnShiftF3()
    --ScenarioInfo.M3NavalPlatoon:Destroy()
    --ScenarioInfo.M3NavalPlatoon = nil
    ForkThread(M3SoulRipperAttack)
end

function OnCtrlF4()
    if ScenarioInfo.MissionNumber == 1 then
        for _, v in ArmyBrains[UEF]:GetListOfUnits(categories.ALLUNITS, false) do
            v:Kill()
        end
    elseif ScenarioInfo.MissionNumber == 2 then
        ForkThread(IntroMission3)
    end
end

function OnShiftF4()
    for _, v in ArmyBrains[UEF]:GetListOfUnits(categories.ALLUNITS - categories.WALL, false) do
        v:Kill()
    end

    for _, v in ArmyBrains[Cybran]:GetListOfUnits(categories.ALLUNITS - categories.WALL, false) do
        v:Kill()
    end
end
