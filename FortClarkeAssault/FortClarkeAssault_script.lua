-- ****************************************************************************
-- **
-- **  File     : /maps/FortClarkeAssault/FortClarkeAssault_script.lua
-- **  Author(s): speed2
-- **
-- **  Summary  : Main mission flow script for FortClarkeAssault
-- **
-- ****************************************************************************
local Cinematics = import('/lua/cinematics.lua')
local CustomFunctions = import('/maps/FortClarkeAssault/FortClarkeAssault_CustomFunctions.lua')
local M1UEFAI = import('/maps/FortClarkeAssault/FortClarkeAssault_m1uefai.lua')
local M2OrderAI = import('/maps/FortClarkeAssault/FortClarkeAssault_m2orderai.lua')
local M2UEFAI = import('/maps/FortClarkeAssault/FortClarkeAssault_m2uefai.lua')
local M3AeonAI = import('/maps/FortClarkeAssault/FortClarkeAssault_m3aeonai.lua')
local M3CybranAI = import('/maps/FortClarkeAssault/FortClarkeAssault_m3cybranai.lua')
local M3UEFAI = import('/maps/FortClarkeAssault/FortClarkeAssault_m3uefai.lua')
local Objectives = import('/lua/ScenarioFramework.lua').Objectives
local OpStrings = import('/maps/FortClarkeAssault/FortClarkeAssault_strings.lua')
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local Utilities = import('/lua/Utilities.lua')

----------
-- Globals
----------
ScenarioInfo.Player = 1
ScenarioInfo.Seraphim = 2
ScenarioInfo.Order = 3
ScenarioInfo.UEF = 4
ScenarioInfo.Aeon = 5
ScenarioInfo.Cybran = 6
ScenarioInfo.Civilians = 7
ScenarioInfo.Coop1 = 8
ScenarioInfo.Coop2 = 9
ScenarioInfo.Coop3 = 10

---------
-- Locals
---------
local Player = ScenarioInfo.Player
local Coop1 = ScenarioInfo.Coop1
local Coop2 = ScenarioInfo.Coop2
local Coop3 = ScenarioInfo.Coop3
local Aeon = ScenarioInfo.Aeon
local Cybran = ScenarioInfo.Cybran
local Order = ScenarioInfo.Order
local Seraphim = ScenarioInfo.Seraphim
local UEF = ScenarioInfo.UEF
local Civilians = ScenarioInfo.Civilians

local AssignedObjectives = {}
local Difficulty = ScenarioInfo.Options.Difficulty

-- How long should we wait at the beginning of the NIS to allow slower machines to catch up?
local NIS1InitialDelay = 3

--------------
-- Debug only!
--------------
local Debug = false
local SkipNIS1 = false
local SkipNIS2 = false
local SkipNIS3 = false
local SkipNIS4 = false

----------
-- Startup
----------
function OnPopulate(scenario)
    ScenarioUtils.InitializeScenarioArmies()

    -- Sets Army Colors
    ScenarioFramework.SetSeraphimColor(Player)
    ScenarioFramework.SetSeraphimColor(Seraphim)
    ScenarioFramework.SetAeonEvilColor(Order)
    ScenarioFramework.SetUEFPlayerColor(UEF)
    ScenarioFramework.SetAeonPlayerColor(Aeon)
    ScenarioFramework.SetCybranPlayerColor(Cybran)
    ScenarioFramework.SetUEFAlly2Color(Civilians)
    local colors = {
        ['Coop1'] = {255, 200, 0}, 
        ['Coop2'] = {189, 116, 16}, 
        ['Coop3'] = {89, 133, 39}
    }
    local tblArmy = ListArmies()
    for army, color in colors do
        if tblArmy[ScenarioInfo[army]] then
            SetArmyColor(ScenarioInfo[army], unpack(color))
        end
    end

    -- Unit Cap
    ScenarioFramework.SetSharedUnitCap(600)

    -- Disable friendly AI sharing resources to players
    GetArmyBrain(Order):SetResourceSharing(false)

    ------------
    -- UEF Bases
    ------------
    M1UEFAI.UEFM1NorthBaseAI()
    M1UEFAI.UEFM1SouthBaseAI()
    M1UEFAI.UEFM1ExpansionBases()
    ArmyBrains[UEF]:PBMSetCheckInterval(5)
    ScenarioUtils.CreateArmyGroup('UEF', 'M1_Mass')

    -- Resources for UEF AI, slightly delayed cause army didn't recieve it for some reason
    ForkThread(function()
        WaitSeconds(2)
        ArmyBrains[UEF]:GiveStorage('ENERGY', 20000)
        ArmyBrains[UEF]:GiveResource('MASS', 4000)
        ArmyBrains[UEF]:GiveResource('ENERGY', 35000)
        ScenarioFramework.UpgradeUnit(ScenarioInfo.UnitNames[UEF]['MexToUpgrade1']) -- Upgrade one of the mexes to T3
    end)

    -- Walls
    ScenarioUtils.CreateArmyGroup('UEF', 'M1_UEF_Walls')
    ScenarioUtils.CreateArmyGroup('Civilians', 'Walls')

    ------------------
    -- Initial Attacks
    ------------------
    local platoon
    for i = 1, 2 do
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M1_Initial_Tanks_North_' .. i, 'GrowthFormation')
        ScenarioFramework.PlatoonPatrolChain(platoon, 'M1_North_Land_Attack_Chain_' .. i)
    end

    for i = 1, 2 do
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M1_Initial_Tanks_South_' .. i, 'GrowthFormation')
        ScenarioFramework.PlatoonPatrolChain(platoon, 'M1_South_Land_Attack_Chain_' .. i)
    end

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M1_Titans_1_D' .. Difficulty, 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M1_Titan_Chain_1')
    ScenarioFramework.CreatePlatoonDeathTrigger(M1SendTitans1, platoon)

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M1_Titans_2_D' .. Difficulty, 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M1_Titan_Chain_2')
    ScenarioFramework.CreatePlatoonDeathTrigger(M1SendTitans2, platoon)

    for i = 1, 3 do
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M1_Engineer' .. i, 'GrowthFormation')
        ScenarioFramework.PlatoonAttackChain(platoon, 'M1_Reclaim_Chain_' .. i)
    end

    -- Wrecks
    ScenarioUtils.CreateArmyGroup('UEF', 'M1_Wrecks', true)

    -- First objective are
    ScenarioFramework.SetPlayableArea('M1_Playable_Area', false)
end

function OnStart(self)
    --------------------
    -- Build Restrictions
    --------------------
    for _, player in ScenarioInfo.HumanPlayers do
        ScenarioFramework.AddRestriction(player,
            categories.xeb2306 + -- UEF Heavy Point Defense
            categories.xel0305 + -- UEF Percival
            categories.xel0306 + -- UEF Mobile Missile Platform
            categories.xes0102 + -- UEF Torpedo Boat
            categories.xes0205 + -- UEF Shield Boat
            categories.xes0307 + -- UEF Battlecruiser
            categories.xeb0104 + -- UEF Engineering Station 1
            categories.xeb0204 + -- UEF Engineering Station 2
            categories.xea0306 + -- UEF Heavy Air Transport
            categories.xeb2402 + -- UEF Sub-Orbital Defense System
            categories.xsl0305 + -- Seraph Sniper Bot
            categories.xsl0401 + -- Seraph Exp Bot
            categories.xsa0402 + -- Seraph Exp Bomb
            categories.xss0304 + -- Seraph Sub Hunter
            categories.xsb0304 + -- Seraph Gate
            categories.xsl0301 + -- Seraph sACU
            categories.xsb2401   -- Seraph exp Nuke
        )
    end

    -- Initialize camera
    if not SkipNIS1 then
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_1_1'))
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
        local VisMarker1_1 = ScenarioFramework.CreateVisibleAreaLocation(110, 'M1_Vis_1_1', 0, ArmyBrains[Player])
        local VisMarker1_2 = ScenarioFramework.CreateVisibleAreaLocation(110, 'M1_Vis_1_2', 0, ArmyBrains[Player])
        -- Intel on enemy bases, since they're not shown during NIS
        local VisMarker1_3 = ScenarioFramework.CreateVisibleAreaLocation(15, 'M1_North_Base_Marker', 1, ArmyBrains[Player])
        local VisMarker1_4 = ScenarioFramework.CreateVisibleAreaLocation(15, 'M1_Vis_1_4', 1, ArmyBrains[Player])

        ForkThread(NISUnits)

        -- Reinforcements
        ForkThread(function()
            WaitSeconds(25)

            local tblArmy = ListArmies()
            coop = 1
            for iArmy, strArmy in pairs(tblArmy) do
                if iArmy >= ScenarioInfo.Coop1 then
                    DropReinforcements('Seraphim', strArmy, 'NIS_Bots_' .. strArmy ..'_D' .. Difficulty, 'NIS_Drop_' .. strArmy, 'NIS_Transport_Death')
                    coop = coop + 1
                end
            end
            if Debug then
                for i = 1, 3 do
                    DropReinforcements('Seraphim', 'Player', 'NIS_Bots_Coop' .. i ..'_D' .. Difficulty, 'NIS_Drop_Coop' .. i, 'NIS_Transport_Death')
                end
            end
            -- Units for player little later else units would die to ahwassa friendly-fire.
            WaitSeconds(3)
            DropReinforcements('Seraphim', 'Player', 'NIS_Bots_Player_D' .. Difficulty, 'NIS_Drop_Player', 'NIS_Transport_Death')
        end)

        ForkThread(function()
            WaitSeconds(30)

            ScenarioInfo.CoopCDR = {}
            local tblArmy = ListArmies()
            if tblArmy[ScenarioInfo.Coop1] then
                ScenarioInfo.CoopCDR1 = ScenarioFramework.SpawnCommander('Coop1', 'Commander', 'Warp', true, true, PlayerDeath)
            end

            WaitSeconds(3)

            if tblArmy[ScenarioInfo.Coop2] then
                ScenarioInfo.CoopCDR2 = ScenarioFramework.SpawnCommander('Coop2', 'Commander', 'Warp', true, true, PlayerDeath)
            end

            WaitSeconds(5)

            ScenarioInfo.PlayerCDR = ScenarioFramework.SpawnCommander('Player', 'Commander', 'Warp', true, true, PlayerDeath)

            WaitSeconds(3)

            if tblArmy[ScenarioInfo.Coop3] then
                ScenarioInfo.CoopCDR3 = ScenarioFramework.SpawnCommander('Coop3', 'Commander', 'Warp', true, true, PlayerDeath)
            end
        end)

        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_1_2'), 18)
        WaitSeconds(4)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_1_3'), 14)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_1_4'), 2)
        WaitSeconds(1)
        VisMarker1_1:Destroy()
        VisMarker1_2:Destroy()

        Cinematics.ExitNISMode()
    else
        DropReinforcements('Seraphim', 'Player', 'NIS_Bots_Player_D' .. Difficulty, 'NIS_Drop_Player', 'NIS_Transport_Death')
        ScenarioInfo.PlayerCDR = ScenarioFramework.SpawnCommander('Player', 'Commander', 'Warp', true, true, PlayerDeath)

        -- spawn coop players too
        ScenarioInfo.CoopCDR = {}
        local tblArmy = ListArmies()
        coop = 1
        for iArmy, strArmy in pairs(tblArmy) do
            if iArmy >= ScenarioInfo.Coop1 then
                ScenarioInfo.CoopCDR[coop] = ScenarioFramework.SpawnCommander(strArmy, 'Commander', 'Warp', true, true, PlayerDeath)
                DropReinforcements('Seraphim', strArmy, 'NIS_Bots_' .. strArmy ..'_D' .. Difficulty, 'NIS_Drop_' .. strArmy, 'NIS_Transport_Death')
                coop = coop + 1
                WaitSeconds(0.5)
            end
        end
    end
    IntroMission1()
end

function NISUnits()
    ----------------------
    -- UEF Bases and units
    ----------------------
    for i = 1, 3 do
        ScenarioUtils.CreateArmyGroup('UEF', 'NIS_Base_' .. i)
    end

    local units = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'NIS_Air', 'GrowthFormation')
    for _, v in units:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('NIS_Air_Chain')))
    end

    for i = 1, 6 do
        units = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'NIS_Tanks_' .. i, 'GrowthFormation')
        ScenarioFramework.PlatoonPatrolChain(units, 'NIS_Tank_Chain_' .. i)
    end

    ForkThread(function()
        WaitSeconds(17)
        local ASFs = ScenarioUtils.CreateArmyGroup('UEF', 'NIS_Bomber_ASFs')
        for _, v in ASFs do
            IssueAttack({v}, ScenarioInfo.UnitNames[Seraphim]['NIS_Bomber_1'])
        end
    end)

    -- Build some units in factories
    local LandFactories = ScenarioFramework.GetCatUnitsInArea(categories.zeb9501, 'NIS_Area', ArmyBrains[UEF])
    local AirFactories = ScenarioFramework.GetCatUnitsInArea(categories.zeb9502, 'NIS_Area', ArmyBrains[UEF])
    local MainLandFactory = ScenarioInfo.UnitNames[UEF]['NIS_Land_Fac']
    local MainAirFactory = ScenarioInfo.UnitNames[UEF]['NIS_Air_Fac']

    for _, v in LandFactories do
        IssueFactoryAssist({v}, MainLandFactory)
    end
    for _, v in AirFactories do
        IssueFactoryAssist({v}, MainAirFactory)
    end

    local landPlatoon = {'', '',}
    local airPlatoon = {'', '',}
    table.insert(landPlatoon, {'uel0202', 5, 5, 'attack', 'AttackFormation'})
    table.insert(airPlatoon, {'uea0103', 10, 10, 'attack', 'AttackFormation'})
    ArmyBrains[UEF]:BuildPlatoon(landPlatoon, {MainLandFactory}, 1)
    ArmyBrains[UEF]:BuildPlatoon(airPlatoon, {MainAirFactory}, 1)

    WaitSeconds(5)

    ------------------
    -- Seraphim Attack
    ------------------
    local ASFs = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'NIS_ASFs', 'GrowthFormation')
    for _, v in ASFs:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('NIS_Air_Chain')))
    end

    local gunships = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'NIS_Gunships', 'GrowthFormation')
    for _, v in gunships:GetPlatoonUnits() do
        IssueAggressiveMove({v}, ScenarioUtils.MarkerToPosition('M1_NIS_Destroy_Marker'))
    end

    WaitSeconds(10)

    for i = 1, 3 do
        local unit = ScenarioUtils.CreateArmyUnit('Seraphim', 'NIS_Bomber_' .. i)
        unit:SetIntelRadius('Vision', 0)
        IssueAttack({unit}, ScenarioInfo.UnitNames[UEF]['M1_NIS_Target_' .. i])
        IssueMove({unit}, ScenarioUtils.MarkerToPosition('M1_NIS_Destroy_Marker'))
        ScenarioFramework.CreateUnitToMarkerDistanceTrigger(DestroyUnit, unit, 'M1_NIS_Destroy_Marker', 10)
    end

    WaitSeconds(13)

    ScenarioInfo.UnitNames[Seraphim]['NIS_Bomber_1']:Kill()

    WaitSeconds(2)

    local AirUnits = ArmyBrains[Seraphim]:GetListOfUnits(categories.xsa0303 + categories.xsa0203, false)
    for _, unit in AirUnits do
        IssueClearCommands({unit})
        IssueMove({unit}, ScenarioUtils.MarkerToPosition('M1_NIS_Destroy_Marker'))
        ScenarioFramework.CreateUnitToMarkerDistanceTrigger(DestroyUnit, unit, 'M1_NIS_Destroy_Marker', 10)
    end

    WaitSeconds(10)

    local UEFAir = ArmyBrains[UEF]:GetListOfUnits(categories.uea0303, false)
    for _, unit in UEFAir do
        if unit and not unit:IsDead() then
            unit:Kill()
        end
    end
end

function DropReinforcements(brain, targetBrain, units, DropLocation, TransportDestination)
    local strArmy = targetBrain
    local landUnits = {}
    local allTransports = {}

    ForkThread(
        function()
            local allUnits = ScenarioUtils.CreateArmyGroup(brain, units)

            for _, unit in allUnits do
                if EntityCategoryContains( categories.TRANSPORTATION, unit ) then
                    table.insert(allTransports, unit )
                else
                    table.insert(landUnits, unit )
                end
            end
            
            for _, transport in allTransports do
                ScenarioFramework.AttachUnitsToTransports(landUnits, {transport})
                WaitSeconds(0.5)
                IssueTransportUnload({transport}, ScenarioUtils.MarkerToPosition(DropLocation))
                IssueMove({transport}, ScenarioUtils.MarkerToPosition(TransportDestination))
                ScenarioFramework.CreateUnitToMarkerDistanceTrigger(DestroyUnit, transport, TransportDestination, 10)
            end

            for _, unit in landUnits do
                while (not unit:IsDead() and unit:IsUnitState('Attached')) do
                    WaitSeconds(.5)
                end
                if (unit and not unit:IsDead()) then
                    ScenarioFramework.GiveUnitToArmy(unit, strArmy)
                end
            end
        end
    )
end

function IntroMission1()
    ScenarioInfo.MissionNumber = 1

    if Debug then
        Utilities.UserConRequest('SallyShears')
        Utilities.UserConRequest('net_lag 0')
        -- path_Armybudget 500
        -- net_Lag 0
        -- sc_FrameTimeClamp 30
        -- Utilities.UserConRequest('ren_IgnoreDecalLOD')
        -- Utilities.UserConRequest('ren_ShadowLOD' 500) -- 250
    end

    StartMission1()
end

function StartMission1()
    ------------------------------------------
    -- Primary Objective 1 - Destroy UEF Bases
    ------------------------------------------
    ScenarioInfo.M1P1 = Objectives.CategoriesInArea(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Destroy UEF Forward Bases',    -- title
        'Secure the area around your starting location.',  -- description
        'kill',                         -- action
        {                               -- target
            MarkUnits = true,
            Requirements = {
                {   
                    Area = 'M1_UEF_North_Base_Area',
                    Category = categories.FACTORY,
                    CompareOp = '<=',
                    Value = 0,
                    ArmyIndex = UEF,
                },
                {   
                    Area = 'M1_UEF_South_Base_Area',
                    Category = categories.FACTORY,
                    CompareOp = '<=',
                    Value = 0,
                    ArmyIndex = UEF
                },
            },
        }
   )
    ScenarioInfo.M1P1:AddResultCallback(
        function(result)
            if(result) then
                if ScenarioInfo.MissionNumber == 1 then
                    -- ScenarioFramework.Dialogue(OpStrings.M1_Bases_Destroyed, IntroMission2, true)
                    IntroMission2()
                else
                    -- ScenarioFramework.Dialogue(OpStrings.M1_Bases_Destroyed, nil, true)
                end
            end
        end
    )
    table.insert(AssignedObjectives, ScenarioInfo.M1P1)
    --ScenarioFramework.CreateTimerTrigger(M1P1Reminder1, 600)

    -- Expand map even if objective isn't finished yet
    local M1MapExpandDelay = {35*60, 30*60, 25*60}
    ScenarioFramework.CreateTimerTrigger(IntroMission2, M1MapExpandDelay[Difficulty])

    if not SkipNIS1 and not Debug then
        ------------------------------------------------
        -- Secondary Objective 1 - Reclaim Ahwassa Wreck
        ------------------------------------------------
        -- Find Ahwassa Wreck, lower it's mass value
        for _, prop in GetReclaimablesInRect(ScenarioUtils.AreaToRect('NIS_Area')) do
            if prop.IsWreckage and prop.AssociatedBP == 'xsa0402' then
                ScenarioInfo.T4BomberWreck = prop
                ScenarioInfo.T4BomberWreck:SetCanTakeDamage(false)
                ScenarioInfo.T4BomberWreck:SetMaxReclaimValues( 1, 20000 - 2000*Difficulty, 0)
                break
            end
        end
        local Viz_Marker_Wreck = ScenarioFramework.CreateVisibleAreaLocation(10, ScenarioInfo.T4BomberWreck:GetPosition(), 0, ArmyBrains[Player])

        ScenarioInfo.M1S1 = Objectives.ReclaimProp(
            'secondary',                    -- type
            'incomplete',                   -- complete
            'Reclaim Experimental Bomber Wreck',  -- title
            'Use the Mass from the wreckage to boost your economy.',  -- description
            {                               -- Target
                Wrecks = {ScenarioInfo.T4BomberWreck},
            }
       )
        ScenarioInfo.M1S1:AddResultCallback(
        function(result)
            if(result) then
                Viz_Marker_Wreck:Destroy()
            end
        end
    )
        table.insert(AssignedObjectives, ScenarioInfo.M1S1)
        --ScenarioFramework.CreateTimerTrigger(M1S1Reminder1, 600)
    end

    -----------
    -- Triggers
    -----------
    -- Send group of percies if players ACUs are close to the UEF bases
    ScenarioInfo.M1Percies1Locked = false
    ScenarioInfo.M1Percies2Locked = false

    ScenarioFramework.CreateUnitToMarkerDistanceTrigger(M1SendPercies1, ScenarioInfo.PlayerCDR, 'M1_South_Base_Marker', 40)
    ScenarioFramework.CreateUnitToMarkerDistanceTrigger(M1SendPercies2, ScenarioInfo.PlayerCDR, 'M1_North_Base_Marker', 40)

    for _, ACU in ScenarioInfo.CoopCDR or {} do
        ScenarioFramework.CreateUnitToMarkerDistanceTrigger(M1SendPercies1, ACU, 'M1_South_Base_Marker', 40)
        ScenarioFramework.CreateUnitToMarkerDistanceTrigger(M1SendPercies2, ACU, 'M1_North_Base_Marker', 40)
    end

    -- Uprade another mex if more than 9 factories
    ScenarioFramework.CreateArmyStatTrigger(UpgradeMex, ArmyBrains[UEF], 'UpgradeMex', 
        {{StatType = 'Units_Active', CompareType = 'GreaterThanOrEqual', Value = 9, Category = categories.FACTORY}})
end

function M1SendTitans1()
    if ScenarioInfo.M1P1.Active then
        ForkThread(function()
            local Delay = {150, 120, 90}
            WaitSeconds(Delay[Difficulty])

            if ScenarioInfo.M1P1.Active then
                local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M1_Titans_1_D' .. Difficulty, 'GrowthFormation')
                ScenarioFramework.PlatoonPatrolChain(platoon, 'M1_Titan_Chain_1')
                ScenarioFramework.CreatePlatoonDeathTrigger(M1SendTitans1, platoon)
            end
        end)
    end
end

function M1SendTitans2()
    if ScenarioInfo.M1P1.Active then
        ForkThread(function()
            local Delay = {160, 130, 100}
            WaitSeconds(Delay[Difficulty])

            if ScenarioInfo.M1P1.Active then
                local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M1_Titans_2_D' .. Difficulty, 'GrowthFormation')
                ScenarioFramework.PlatoonPatrolChain(platoon, 'M1_Titan_Chain_2')
                ScenarioFramework.CreatePlatoonDeathTrigger(M1SendTitans2, platoon)
            end
        end)
    end
end

function M1SendPercies1(unit)
    -- Send only one group of percies even if there are more ACUs in the base range, after 'Delay' set up triggers again
    local unitsTable = {}

    if (ScenarioInfo.MissionNumber == 1 and ScenarioInfo.M1Percies1Locked) then
        table.insert(unitsTable, unit)
    elseif (ScenarioInfo.MissionNumber == 1 and not ScenarioInfo.M1Percies1Locked) then
        ScenarioInfo.M1Percies1Locked = true
        table.insert(unitsTable, unit)

        local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M1_Percies_1_D' .. Difficulty, 'GrowthFormation')
        for _, v in platoon:GetPlatoonUnits() do
            IssueAttack({v}, unit)
        end
        ScenarioFramework.PlatoonPatrolChain(platoon, 'M1_South_Land_Attack_Chain_' .. Random(1,2))

        WaitSeconds(270 - 30 * Difficulty)

        if ScenarioInfo.MissionNumber == 1 then
            for k, _ in unitsTable do
                ScenarioFramework.CreateUnitToMarkerDistanceTrigger(M1SendPercies1, unit, 'M1_South_Base_Marker', 40)
                table.remove(unitsTable, k)
            end
            ScenarioInfo.M1Percies1Locked = false
        end
    end
end

function M1SendPercies2(unit)
    local unitsTable = {}

    if (ScenarioInfo.MissionNumber == 1 and ScenarioInfo.M1Percies2Locked) then
        table.insert(unitsTable, unit)
    elseif (ScenarioInfo.MissionNumber == 1 and not ScenarioInfo.M1Percies2Locked) then
        ScenarioInfo.M1Percies2Locked = true
        table.insert(unitsTable, unit)

        local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M1_Percies_2_D' .. Difficulty, 'GrowthFormation')
        for _, v in platoon:GetPlatoonUnits() do
            IssueAttack({v}, unit)
        end
        ScenarioFramework.PlatoonPatrolChain(platoon, 'M1_North_Land_Attack_Chain_' .. Random(1,2))

        WaitSeconds(280 - 30 * Difficulty)
        
        if ScenarioInfo.MissionNumber == 1 then
            for k, _ in unitsTable do
                ScenarioFramework.CreateUnitToMarkerDistanceTrigger(M1SendPercies2, unit, 'M1_North_Base_Marker', 40)
                table.remove(unitsTable, k)
            end
        end
        ScenarioInfo.M1Percies2Locked = false
    end
end

function UpgradeMex()
    local Mex = ScenarioInfo.UnitNames[UEF]['MexToUpgrade2']
    if Mex and not Mex:IsDead() then
        ScenarioFramework.UpgradeUnit(Mex)
    end
end

------------
-- Mission 2
------------
function IntroMission2()
    if ScenarioInfo.MissionNumber == 2 or ScenarioInfo.MissionNumber == 3 then
        return
    end
    ScenarioInfo.MissionNumber = 2

    -- Unit Cap
    ScenarioFramework.SetSharedUnitCap(1000)

    -------------------
    -- UEF Eastern Town
    -------------------
    ScenarioUtils.CreateArmyGroup('UEF', 'M2_South_Town_Defense_D' .. Difficulty)

    ------------
    -- Civilians
    ------------
    ScenarioInfo.M2CivilianCity = ScenarioUtils.CreateArmyGroup('Civilians', 'M2_Civilian_South_City')

    ---------------
    -- M2 UEF Bases
    ---------------
    M2UEFAI.UEFM2ForwardBase1AI()
    M2UEFAI.UEFM2ForwardBase2AI()
    M2UEFAI.UEFM2ForwardBase3AI()
    M2UEFAI.UEFM2ForwardBase4AI()
    M3UEFAI.UEFM3BaseAI()
    M3UEFAI.UEFM3BaseNavalAI()

    ScenarioUtils.CreateArmyGroup('UEF', 'M2_Walls')
    ScenarioUtils.CreateArmyGroup('UEF', 'M2_Arty')

    -- UEF ACU
    ScenarioInfo.UEFCDR = ScenarioFramework.SpawnCommander('UEF', 'UEF_Commander', false, 'Gorton', true, M4UEFCommanderKilled, 
        {'AdvancedEngineering','T3Engineering','Shield','ShieldGeneratorField','ResourceAllocation'})
    ScenarioInfo.UEFCDR:SetVeterancy(2 + Difficulty)

    -- Initial UEF Units
    local platoon

    for i = 1, 5 do
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M2_UEF_NavalFleet_' .. i, 'AttackFormation')
        if i <= 4 then
            ScenarioFramework.PlatoonPatrolChain(platoon, 'M2_UEF_Init_Naval_Chain_' .. i)
        else
            ScenarioFramework.PlatoonPatrolChain(platoon, 'M2_UEF_Init_Naval_Chain_4')
        end
    end

    ------------
    -- M2 Cybran
    ------------
    M3CybranAI.CybranM3BaseAI()
    ArmyBrains[Cybran]:PBMSetCheckInterval(6)

    -- Cybran ACU
    ScenarioInfo.CybranCDR = ScenarioFramework.SpawnCommander('Cybran', 'Cybran_Commander', false, 'Tokyto', true, M4CybranCommanderKilled, 
        {'AdvancedEngineering','T3Engineering','StealthGenerator','CloakingGenerator','MicrowaveLaserGenerator'})
    ScenarioInfo.CybranCDR:SetVeterancy(2 + Difficulty)

    ----------
    -- M2 Aeon
    ----------
    M3AeonAI.AeonM3BaseAI()
    ArmyBrains[Aeon]:PBMSetCheckInterval(6)

    -- Aeon ACU
    ScenarioInfo.AeonCDR = ScenarioFramework.SpawnCommander('Aeon', 'Aeon_Commander', false, 'Ithilis', true, M4AeonCommanderKilled, 
        {'AdvancedEngineering','T3Engineering','Shield','ShieldHeavy','EnhancedSensors'})
    ScenarioInfo.AeonCDR:SetVeterancy(2 + Difficulty)
    
    ----------------
    -- M2 Order Base
    ----------------
    M2OrderAI.OrderM2MainBaseAI()
    M2OrderAI.OrderM2NavalBaseAI()
    M2OrderAI.OrderM2ExpansionBaseAI()

    if Debug then
        M2OrderAI.M2OrderCarriers() -- Only for Testing
    else
        ScenarioFramework.CreateTimerTrigger(M2OrderAI.M2OrderCarriers, 2 * Difficulty * 60)
    end
    ArmyBrains[Order]:PBMSetCheckInterval(5)

    -- Order CDR
    ScenarioInfo.OrderCDR = ScenarioFramework.SpawnCommander('Order', 'Order_ACU', false, LOC '{i Gari}', false, OrderCommanderKilled, 
        {'AdvancedEngineering','T3Engineering','ResourceAllocationAdvanced','EnhancedSensors'})

    -- Order Initial Patrols
    -- Air
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'M2_Order_Init_Air_Patrol_D' .. Difficulty, 'AttackFormation')
    for _, v in platoon:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M2_Order_Main_Base_Air_Patrol_Chain')))
    end

    -- Land
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'M2_Oder_Init_Colos_' .. Difficulty, 'AttackFormation')
    for _, v in platoon:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M2_Order_Main_Base_Exp_Patrol_Chain')))
    end

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'M2_Order_Init_Air_Patrol_2', 'AttackFormation')
    for _, v in platoon:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M2_Order_Naval_Defense_Chain')))
    end

    for i = 1, 3 do
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'M2_Order_Init_Tanks_' .. i, 'GrowthFormation')
        ScenarioFramework.PlatoonPatrolChain(platoon, 'M2_Oder_LandAttack_Cybran_Chain')
    end

    -- Naval
    for i = 1, 2 do
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'M2_Order_Init_Naval_Patrol_' .. i, 'GrowthFormation')
        ScenarioFramework.PlatoonPatrolChain(platoon, 'M2_Order_Naval_Defense_Chain')
    end

    ScenarioUtils.CreateArmyGroup('Order', 'M2_Order_Init_Naval_1')

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'M2_Order_Init_Naval_2', 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M2_Order_Naval_Attack_Chain_1')

    -- Some initial resources for everyone
    ArmyBrains[Order]:GiveResource('MASS', 10000)
    ArmyBrains[UEF]:GiveResource('MASS', 10000)
    ArmyBrains[Aeon]:GiveResource('MASS', 10000)
    ArmyBrains[Cybran]:GiveResource('MASS', 10000)

    ForkThread(M2CheatEconomy)
    ForkThread(EnableStealthOnAir)
    IntroMission2NIS()
end

function IntroMission2NIS()
    ScenarioFramework.SetPlayableArea('M2_Playable_Area', false)
    if not SkipNIS2 then
        Cinematics.EnterNISMode()
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_2_1'), 0)
        WaitSeconds(2)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_2_2'), 8)
        WaitSeconds(1)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_2_3'), 2)
        Cinematics.ExitNISMode()
    end

    M2InitialAttack()
    StartMission2()
end

function StartMission2()
    ---------------------------------------
    -- Primary Objective 2 - Kill Civilians
    ---------------------------------------
    ScenarioInfo.M2P1 = Objectives.Basic(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Prepare your forces for the incoming couter attack',  -- title
        'Coalition forces are preparing major offensive against your positions. Build up your army to repel their attack.',  -- description
        Objectives.GetActionIcon('build'),
        {                               -- target
            ShowFaction = 'UEF',
        }
   )
    ScenarioInfo.M2P1:AddResultCallback(
        function(result)
            if(result) then
                if ScenarioInfo.MissionNumber == 2 then
                    -- ScenarioFramework.Dialogue(OpStrings.M1_Bases_Destroyed, IntroMission2, true)
                    IntroMission3()
                else
                    -- ScenarioFramework.Dialogue(OpStrings.M1_Bases_Destroyed, nil, true)
                end
            end
        end
    )
    table.insert(AssignedObjectives, ScenarioInfo.M2P1)
    --ScenarioFramework.CreateTimerTrigger(M2P1Reminder1, 600)

    ScenarioFramework.CreateTimerTrigger(M2AssignSecondary, 40)


    -- Expand map even if objective isn't finished yet
    local M2MapExpandDelay = {20*60, 15*60, 10*60}
    ScenarioFramework.CreateTimerTrigger(EndMission2, M2MapExpandDelay[Difficulty])
end

function M2InitialAttack()
    --------------
    -- Air Attacks
    --------------
    local ASFs, gunships, torpbombers

    for i = 1, 5 do
        ASFs = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M2_UEF_Init_ASFs_South_' .. i .. '_D' .. Difficulty, 'AttackFormation')
        ScenarioFramework.PlatoonPatrolChain(ASFs, 'M2_UEF_Air_South_Init_Chain_' .. i)

        gunships = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M2_UEF_Init_Gunships_South_' .. i .. '_D' .. Difficulty, 'AttackFormation')
        ScenarioFramework.PlatoonPatrolChain(gunships, 'M2_UEF_Air_South_Init_Chain_' .. i)

        if i <= 3 then
            torpbombers = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M2_UEF_Init_TorpBombers_South_' .. i .. '_D' .. Difficulty, 'AttackFormation')
            if i == 1 then
                ScenarioFramework.PlatoonPatrolChain(torpbombers, 'M2_UEF_Air_South_Init_Chain_' .. i)
            else
                ScenarioFramework.PlatoonPatrolChain(torpbombers, 'M2_UEF_Init_Naval_Chain_4')
            end
        end
    end

    --------
    -- Drops
    --------
    for i = 1, 4 do
        ForkThread(function(i)
            local landUnits = {}
            local allTransports = {}

            local allUnits = ScenarioUtils.CreateArmyGroup('UEF', 'M2_UEF_Drops_' .. i .. '_D' .. Difficulty)

            for _, unit in allUnits do
                if EntityCategoryContains( categories.TRANSPORTATION, unit ) then
                    table.insert(allTransports, unit )
                else
                    table.insert(landUnits, unit )
                end
            end
            
            for _, transport in allTransports do
                ScenarioFramework.AttachUnitsToTransports(landUnits, {transport})
                WaitSeconds(0.5)
                for j = 1, 3 do
                    if j <= 2 then
                        IssueMove({transport}, ScenarioUtils.MarkerToPosition('M2_Init_Transport_' .. i ..'_' .. j))
                    else
                        IssueTransportUnload({transport}, ScenarioUtils.MarkerToPosition('M2_Init_Transport_' .. i ..'_' .. j))
                    end
                end
                
                IssueMove({transport}, ScenarioUtils.MarkerToPosition('M2_Transport_Death_Marker'))
                ScenarioFramework.CreateUnitToMarkerDistanceTrigger(DestroyUnit, transport, 'M2_Transport_Death_Marker', 10)
            end

            --local platoon = ArmyBrains[UEF]:MakePlatoon('','')
            for _, unit in landUnits do
                while (not unit:IsDead() and unit:IsUnitState('Attached')) do
                    WaitSeconds(.5)
                end
                
                if (unit and not unit:IsDead()) then
                    --ArmyBrains[UEF]:AssignUnitsToPlatoon(platoon, {unit}, 'Attack', 'AttackFormation')
                    IssueAggressiveMove({unit}, ScenarioUtils.MarkerToPosition('M2_UEF_Air_South_Init_1_' .. Random(3,4)))
                end
            end
            --ScenarioFramework.PlatoonPatrolChain(platoon, 'M2_Init_Drop_Attack_Chain_' .. i)
        end, i)
    end   
end

function M2AssignSecondary()
    -- ScenarioFramework.Dialogue(OpStrings.M2_Kill_Civs_Objective, nil, true)
    -----------------------------------------
    -- Secondary Objective 2 - Kill Civilians
    -----------------------------------------
    ScenarioInfo.M2S1 = Objectives.Kill(
        'secondary',                      -- type
        'incomplete',                   -- complete
        'Annihilate Human City',  -- title
        'Destroy UEF City south of your location.',  -- description
        {                               -- target
            Units = ScenarioInfo.M2CivilianCity,
            FlashVisible = true,
        }
   )
    ScenarioInfo.M2S1:AddResultCallback(
        function(result)
            if(result) then
                -- ScenarioFramework.Dialogue(OpStrings.M2_Civs_Killed)
            end
        end
    )
    table.insert(AssignedObjectives, ScenarioInfo.M2S1)
    --ScenarioFramework.CreateTimerTrigger(M2S1Reminder1, 600)
end

function M2CheatEconomy()
    while ScenarioInfo.MissionNumber == 2 do
        ArmyBrains[UEF]:GiveResource('MASS', 200)
        ArmyBrains[UEF]:GiveResource('ENERGY', 6000)
        WaitSeconds(1)
    end
end

function EnableStealthOnAir()
    local T3AirUnits = {}
    while true do
        for _, v in ArmyBrains[Cybran]:GetListOfUnits(categories.ura0303 + categories.ura0304, false) do
            if not ( T3AirUnits[v:GetEntityId()] or v:IsBeingBuilt() ) then
                v:ToggleScriptBit('RULEUTC_StealthToggle')
                T3AirUnits[v:GetEntityId()] = true
            end
        end
        WaitSeconds(10)
    end

    --[[
    for _, spider in ScenarioInfo.M3SpiderbotPlatoon:GetPlatoonUnits() do
        if EntityCategoryContains(categories.url0402, spider) then
            spider:ToggleScriptBit('RULEUTC_StealthToggle')
            ScenarioFramework.CreateArmyIntelTrigger(M3OnSpiderbotSpotted, ArmyBrains[Player], 'LOSNow', spider, true, categories.ALLUNITS, true, ArmyBrains[Cybran])
            break
        end
    end
    ]]--
end

function OrderCommanderKilled()
    ScenarioFramework.Dialogue(OpStrings.M2_OrderCommanderKilled, M2OrderAI.DisableBase, true)
end

function EndMission2()
    ScenarioInfo.M2P1:ManualResult(true)
end

------------
-- Mission 3
------------
function IntroMission3()
    if ScenarioInfo.MissionNumber == 3 then
        return
    end
    ScenarioInfo.MissionNumber = 3

    ScenarioInfo.M3ObjectiveExperimentalas = {}

    ------------
    -- Civilians
    ------------
    ScenarioInfo.M3WestCivilianCity = ScenarioUtils.CreateArmyGroup('Civilians', 'M3_West_Civilian_City')
    ScenarioInfo.M3SouthCivilianCity = ScenarioUtils.CreateArmyGroup('Civilians', 'M3_South_Civilian_City')

    ---------
    -- M3 UEF
    ---------
    M3UEFAI.FortClarkeAI()
    M3UEFAI.UEFM3WestTownAI()
    M3UEFAI.M3UEFBattleshipsAttacks()

    ScenarioUtils.CreateArmyGroup('UEF', 'Bridge_Defenses_D' .. Difficulty)
    ScenarioUtils.CreateArmyGroup('UEF', 'M3_Arty')

    ------------
    -- M3 Cybran
    ------------
    M3CybranAI.M3CybranExperimentals()
    ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M3_Cybran_Destroyers_D' .. Difficulty, 'NoFormation')

    -- Walls
    ScenarioUtils.CreateArmyGroup('Cybran', 'M3_Cybran_Walls')

    ----------
    -- M3 Aeon
    ----------
    M3AeonAI.AeonM3BaseNavalAI()
    M3AeonAI.M3AeonExperimentals()

    -----------
    -- M3 Order
    -----------
    M2OrderAI.M3OrderExperimentals()

    ScenarioUtils.CreateArmyGroup('Order', 'M3_Order_Bases')
    local units = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'M3_Order_Units', 'AttackFormation')
    for _, v in units:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M3_Order_Death_Patrol_Chain')))
    end

    -- Wreckages
    ScenarioUtils.CreateArmyGroup('UEF', 'M3_West_Town_Rebuild_D' .. Difficulty, true)
    ScenarioUtils.CreateArmyGroup('UEF', 'M3_Wrecked_Walls', true)
    ScenarioUtils.CreateArmyGroup('Civilians', 'M3_Civilian_Middle_City', true)
    ScenarioUtils.CreateArmyGroup('Order', 'M3_Order_Wrecks', true)

    -- Army Cap
    SetArmyUnitCap(UEF, 1500)

    -- Spawning Land and Naval units now for Cinematics, Air will follow after Cinematics since it moves much faster.
    M3CounterAttack()

    ForkThread(M3CheatEconomy)
    ForkThread(IntroMission3NIS)
end

-- Land and Naval CounterAttack
function M3CounterAttack()
    local platoon, patrolChain

    local function M3RandomPatrolRoute()
        if Random(1,2) == 1 then
            return 'M3_Exp_Attack_Chain_North'
        else
            return 'M3_Exp_Attack_Chain_South'
        end
    end
    -------
    -- Aeon
    -------
    -- GC
    patrolChain = M3RandomPatrolRoute()
    local M3GCs = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M3_CA_GCs_D' .. Difficulty, 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(M3GCs, patrolChain)
    for _, v in M3GCs:GetPlatoonUnits() do
        table.insert(ScenarioInfo.M3ObjectiveExperimentalas, v)
    end

    -- Harbingers
    patrolChain = M3RandomPatrolRoute()
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M3_CA_Harbingers_D' .. Difficulty, 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, patrolChain)

    -- T3 Mobile AA
    patrolChain = M3RandomPatrolRoute()
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M3_CA_AA_D' .. Difficulty, 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, patrolChain)

    -- Sniperbots
    patrolChain = M3RandomPatrolRoute()
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M3_CA_Snipers_D' .. Difficulty, 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, patrolChain)

    ---------
    -- Cybran
    ---------
    -- Spiders
    patrolChain = M3RandomPatrolRoute()
    local M3Spiders = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M3_CA_Spiders_D' .. Difficulty, 'AttackFormation')  
    ScenarioFramework.PlatoonPatrolChain(M3Spiders, patrolChain)
    for _, v in M3Spiders:GetPlatoonUnits() do
        table.insert(ScenarioInfo.M3ObjectiveExperimentalas, v)
    end

    -- Loyalists
    --[[
    for i = 1, 2 do
        patrolChain = M3RandomPatrolRoute()
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M3_CA_Loyalists_' .. i .. '_D' .. Difficulty, 'GrowthFormation')
        ScenarioFramework.PlatoonPatrolChain(platoon, patrolChain)
    end
    ]]--
    patrolChain = M3RandomPatrolRoute()
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M3_CA_Loyalists_1_D' .. Difficulty, 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, patrolChain)
    
    -- Bricks
    patrolChain = M3RandomPatrolRoute()
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M3_CA_Bricks_D' .. Difficulty, 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, patrolChain)

    -- Mobile Arty
    patrolChain = M3RandomPatrolRoute()
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M3_CA_Arty_D' .. Difficulty, 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, patrolChain)

    -- Mobile T3 AA
    patrolChain = M3RandomPatrolRoute()
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M3_CA_AA_D' .. Difficulty, 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, patrolChain)

    ------
    -- UEF
    ------
    -- Fatboy
    local M3Fatboys = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M3_Fatboys_D' .. Difficulty, 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(M3Fatboys, 'M3_UEF_LandAttack_North_Chain')
    for _, v in M3Fatboys:GetPlatoonUnits() do
        table.insert(ScenarioInfo.M3ObjectiveExperimentalas, v)
    end

    -- Mobile AA for Fatboy
    local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M3_Fatboy_Support_D' .. Difficulty, 'AttackFormation')
    for _, v in platoon:GetPlatoonUnits() do
        IssueGuard({v}, ScenarioInfo.UnitNames[UEF]['UEF_Fatboy'])
    end

    -- Titans, Demoslishers
    for i = 1, 2 do
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M3_Init_Arty_' .. i .. '_D' .. Difficulty, 'GrowthFormation')
        ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_UEF_Init_LandAttack_Chain_' .. i)

        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M3_Init_Titans_' .. i .. '_D' .. Difficulty, 'GrowthFormation')
        ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_UEF_Init_LandAttack_Chain_' .. i)
    end
end

function IntroMission3NIS()
    ScenarioFramework.SetPlayableArea('M3_Playable_Area', false)

    if not SkipNIS3 then
        Cinematics.EnterNISMode()

        local VisMarker3_1 = ScenarioFramework.CreateVisibleAreaLocation(60, 'M3_Vis_1', 0, ArmyBrains[Player])

        Cinematics.CameraMoveToMarker('Cam_3_1', 0)
        WaitSeconds(2)
        Cinematics.CameraMoveToMarker('Cam_3_2', 5)
        WaitSeconds(2)

        VisMarker3_1:Destroy()
        if Difficulty == 3 then
            ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('M3_Vis_1'), 70)
        end
        
        Cinematics.ExitNISMode()
    end

    M3CounterAttackAir()
    StartMission3()
end

-- Air CounterAttack
function M3CounterAttackAir()
    local units = nil
    local trigger = {}


    local num = 0
    for _, player in ScenarioInfo.HumanPlayers do
        num = num + table.getn(ArmyBrains[player]:GetListOfUnits((categories.LAND * categories.MOBILE) - categories.CONSTRUCTION, false))
    end

    if(num > 0) then
        trigger = {60, 50, 40}
        num = math.ceil(num/trigger[Difficulty])
        if(num > 6) then
            num = 6
        end
        for i = 1, num do
            units = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('UEF', 'M3_Init_Gunships_D' .. Difficulty, 'GrowthFormation', 1 + Difficulty)
            ScenarioFramework.PlatoonPatrolChain(units, 'M3_UEF_Init_LandAttack_Chain_' .. Random(1,2))
        end
    end

    -- Spawns Air Superiority
    local num = 0
    for _, player in ScenarioInfo.HumanPlayers do
        num = num + table.getn(ArmyBrains[player]:GetListOfUnits(categories.AIR * categories.MOBILE * categories.TECH3, false))
    end

    if(num > 0) then
        trigger = {24, 20, 16}
        num = math.ceil(num/trigger[Difficulty])
        for i = 1, num do
            units = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('UEF', 'M3_Init_ASFs_D' .. Difficulty, 'GrowthFormation', Difficulty)
            ScenarioFramework.PlatoonPatrolChain(units, 'M3_UEF_Init_LandAttack_Chain_' .. Random(1,2))
        end
    end
end

function StartMission3()
    ---------------------------------------------
    -- Primary Objective 3 - Survive Counterattack
    ---------------------------------------------
    ScenarioInfo.M3P1 = Objectives.Kill(
        'primary',                          -- type
        'incomplete',                       -- complete
        'Survive the Counterattack',      -- title
        'Prevent Coalition forces from overrunning your position.',      -- description
        {                               -- target
            Units = ScenarioInfo.M3ObjectiveExperimentalas,
        }
    )
    ScenarioInfo.M3P1:AddResultCallback(
        function(result)
            if(result) then
                -- ScenarioFramework.Dialogue(OpStrings.M3_All_Exps_Killed, IntroMission4, true)
                IntroMission4()
            end
        end
    )
    table.insert(AssignedObjectives, ScenarioInfo.M3P1)

    -- ScenarioFramework.Dialogue(OpStrings.M3_Reinforcements, M3SeraphimReinforcements, true)
    M3SeraphimReinforcements()
end

function M3SeraphimReinforcements()
    ForkThread(
        function()
            -- Allow players to build T4 Bots and Bombers
            ScenarioFramework.RemoveRestrictionForAllHumans(categories.xsl0401 + categories.xsa0402, true)

            -- Move on map and give T4 Bot
            local units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M3_Sera_Exps_D' .. Difficulty, 'AttackFormation')
            units:MoveToLocation(ScenarioUtils.MarkerToPosition('M3_Yothas_Destination_1'), false)
            WaitSeconds(1)
            for _, v in units:GetPlatoonUnits() do
                while v:IsUnitState('Moving') do
                    WaitSeconds(1)
                end
                ScenarioFramework.GiveUnitToArmy(v, 'Player')
            end
            
            -- T3 Subs
            units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M3_Sera_T3_Subs_D' .. Difficulty, 'AttackFormation')
            units:MoveToLocation(ScenarioUtils.MarkerToPosition('M3_Subs_Destination'), false)
            WaitSeconds(1)
            for _, v in units:GetPlatoonUnits() do
                while v:IsUnitState('Moving') do
                    WaitSeconds(1)
                end
                ScenarioFramework.GiveUnitToArmy(v, 'Player')
            end
        end
    )
end

function M3CheatEconomy()
    while ScenarioInfo.MissionNumber >= 3 do
        ArmyBrains[Aeon]:GiveResource('MASS', 150)
        ArmyBrains[Aeon]:GiveResource('ENERGY', 2000)
        ArmyBrains[Cybran]:GiveResource('MASS', 150)
        ArmyBrains[Cybran]:GiveResource('ENERGY', 2000)
        WaitSeconds(1)
    end
end

------------
-- Mission 4
------------
function IntroMission4()
    if ScenarioInfo.MissionNumber == 4 then
        return
    end
    ScenarioInfo.MissionNumber = 4

    ------------
    -- Civilians
    ------------
    ScenarioInfo.M4FortClarkeCivilians = ScenarioUtils.CreateArmyGroup('Civilians', 'M4_Fork_Clarke_Civilians')

    -------
    -- Aeon
    -------
    M3AeonAI.M4AeonExperimentals()

    ---------
    -- M4 UEF
    ---------
    ScenarioInfo.FortClarkeHQ = ScenarioUtils.CreateArmyUnit('UEF', 'Clarke_Monument')

    ScenarioUtils.CreateArmyGroup('UEF', 'M3_UEF_Base_Walls')

    -- Satellite defense
    local orbital = ArmyBrains[UEF]:GetListOfUnits(categories.xea0002, false)
    if(orbital[1] and not orbital[1]:IsDead()) then
        local platoon = ArmyBrains[UEF]:MakePlatoon('', '')
        ArmyBrains[UEF]:AssignUnitsToPlatoon(platoon, {orbital[1]}, 'Attack', 'GrowthFormation')
        ScenarioFramework.PlatoonPatrolChain(platoon, 'M4_Fort_Clarke_Sat_Chain')
    end

    ForkThread(IntroMission4NIS)
end

function IntroMission4NIS()
    ScenarioFramework.SetPlayableArea('M4_Playable_Area', false)

    if not SkipNIS4 then
        Cinematics.EnterNISMode()

        local VisMarker4_1 = ScenarioFramework.CreateVisibleAreaLocation(120, 'M4_Vis_1', 0, ArmyBrains[Player])

        Cinematics.CameraMoveToMarker('Cam_4_1', 0)
        WaitSeconds(2)
        Cinematics.CameraMoveToMarker('Cam_4_2', 5)
        WaitSeconds(2)

        VisMarker4_1:Destroy()
        if Difficulty == 3 then
            ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('M4_Vis_1'), 130)
        end

        Cinematics.ExitNISMode()
    end

    ForkThread(M4NukeParty)
    StartMisson4()
end

function StartMisson4()
    --------------------------------------------
    -- Primary Objective 4 - Destroy Fort Clarke
    --------------------------------------------
    ScenarioInfo.M4P1 = Objectives.Kill(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Destroy Fort Clarke',  -- title
        'Destroy Fort Clarke.',  -- description
        {                               -- target
            Units = {ScenarioInfo.FortClarkeHQ},
        }
   )
    ScenarioInfo.M4P1:AddResultCallback(
        function(result)
            if(result) then
                if ScenarioInfo.M4P2.Active then
                    -- ScenarioFramework.Dialogue(OpStrings.M3_Fort_Clarke_Destroyd, false, true)
                    M3UEFAI.DisableFortClarkeBase()
                elseif not ScenarioInfo.M4CommandersSpotted then
                    M4AssignSecondPrimary()
                else
                    -- ScenarioFramework.Dialogue(OpStrings.M3_Fort_Clarke_Destroyd, PlayerWin, true)
                    PlayerWin()
                end
            end
        end
    )
    table.insert(AssignedObjectives, ScenarioInfo.M4P1)
    --ScenarioFramework.CreateTimerTrigger(M4P1Reminder1, 600)

    -- Assign objective to kill coalition commander once one of them is spotted.
    ScenarioInfo.M4CommandersSpotted = false
    ScenarioFramework.CreateArmyIntelTrigger(M4AssignSecondPrimary, ArmyBrains[Player], 'LOSNow', false, true, categories.uel0001, true, ArmyBrains[UEF])
    ScenarioFramework.CreateArmyIntelTrigger(M4AssignSecondPrimary, ArmyBrains[Player], 'LOSNow', false, true, categories.ual0001, true, ArmyBrains[Aeon])
    ScenarioFramework.CreateArmyIntelTrigger(M4AssignSecondPrimary, ArmyBrains[Player], 'LOSNow', false, true, categories.url0001, true, ArmyBrains[Cybran])
end

function M4NukeParty()
    local AeonNuke = ArmyBrains[Aeon]:GetListOfUnits(categories.uab2305, false)
    local CybranNuke = ArmyBrains[Cybran]:GetListOfUnits(categories.urb2305, false)
    local OrderNuke = ArmyBrains[Order]:GetListOfUnits(categories.uab2305, false)
    local OrderAntiNuke = ScenarioInfo.UnitNames[Order]['Order_AntiNuke']
    local UEFNuke = ArmyBrains[UEF]:GetListOfUnits(categories.ueb2305, false)

    WaitSeconds(30)
    IssueNuke({OrderNuke[1]}, ScenarioUtils.MarkerToPosition('M4_Order_Nuke_Marker_1'))
    WaitSeconds(45)
    IssueNuke({OrderNuke[1]}, ScenarioUtils.MarkerToPosition('M4_Order_Nuke_Marker_2'))
    WaitSeconds(120)

    --while OrderAntiNuke and not OrderAntiNuke:IsDead() do
        --WaitSeconds(5)
    --end

    local run = 0
    while run < 3 and ScenarioInfo.OrderCDR and not ScenarioInfo.OrderCDR:IsDead() do
        UEFNuke[1]:GiveNukeSiloAmmo(1)
        AeonNuke[1]:GiveNukeSiloAmmo(1)
        CybranNuke[1]:GiveNukeSiloAmmo(1)
        IssueNuke({UEFNuke[1]}, ScenarioUtils.MarkerToPosition('M4_UEF_Nuke_Marker'))
        WaitSeconds(Random(3,6))
        if run == 0 then
            IssueNuke({AeonNuke[1]}, ScenarioUtils.MarkerToPosition('M4_Aeon_Nuke_Marker'))
        else
            IssueNuke({AeonNuke[1]}, ScenarioUtils.MarkerToPosition('M4_Aeon_Nuke_Marker2'))
        end
        WaitSeconds(Random(4,8))
        IssueNuke({CybranNuke[1]}, ScenarioUtils.MarkerToPosition('M4_Cybran_Nuke_Marker'))
        WaitSeconds(80)
        run = run + 1
    end

    WaitSeconds(180)

    -- Activate UEF Nukes
    local plat = ArmyBrains[UEF]:MakePlatoon('', '')
    ArmyBrains[UEF]:AssignUnitsToPlatoon(plat, {UEFNuke[1]}, 'Attack', 'NoFormation')
    plat:ForkAIThread(plat.NukeAI)

    if Difficulty >= 2 then
        WaitSeconds(180)

        -- Activate Aeon Nukes
        local plat = ArmyBrains[Aeon]:MakePlatoon('', '')
        ArmyBrains[Aeon]:AssignUnitsToPlatoon(plat, {AeonNuke[1]}, 'Attack', 'NoFormation')
        plat:ForkAIThread(plat.NukeAI)
    end

    if Difficulty == 3 then
        WaitSeconds(180)

        -- Activate Cybran Nukes
        local plat = ArmyBrains[Cybran]:MakePlatoon('', '')
        ArmyBrains[Cybran]:AssignUnitsToPlatoon(plat, {CybranNuke[1]}, 'Attack', 'NoFormation')
        plat:ForkAIThread(plat.NukeAI)
    end
end

function M4AssignSecondPrimary()
    if ScenarioInfo.M4CommandersSpotted then
        return
    end

    ScenarioInfo.M4CommandersSpotted = true

    ----------------------------------
    -- Primary Objective 5 - Kill ACUs
    ----------------------------------
    ScenarioInfo.M4P2 = Objectives.Kill(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Defeat Coalition Commanders',  -- title
        'Fort Clarke is being reinforced by 3 Coalition commanders. Don\'t let them stay in your way.',  -- description
        {                               -- target
            Units = {ScenarioInfo.AeonCDR, ScenarioInfo.CybranCDR, ScenarioInfo.UEFCDR},
        }
   )
    ScenarioInfo.M4P2:AddResultCallback(
        function(result)
            if(result) then
                if ScenarioInfo.M4P1.Active then
                    -- ScenarioFramework.Dialogue(OpStrings.M3_All_ACUs_Killed, false, true)
                else
                    -- ScenarioFramework.Dialogue(OpStrings.M3_All_ACUs_Killed, PlayerWin, true)
                    PlayerWin()
                end
            end
        end
    )
    table.insert(AssignedObjectives, ScenarioInfo.M4P2)
    --ScenarioFramework.CreateTimerTrigger(M4P2Reminder1, 600)
end

function M4AeonCommanderKilled()
    -- ScenarioFramework.Dialogue(OpStrings.M4_Aeon_ACU_Killed, false, true)
    ScenarioFramework.CDRDeathNISCamera(ScenarioInfo.AeonCDR, 5)
    M3AeonAI.DisableBase()
end

function M4CybranCommanderKilled()
    -- ScenarioFramework.Dialogue(OpStrings.M4_Cybran_ACU_Killed, false, true)
    ScenarioFramework.CDRDeathNISCamera(ScenarioInfo.CybranCDR, 5)
    M3CybranAI.DisableBase()
end

function M4UEFCommanderKilled()
    -- ScenarioFramework.Dialogue(OpStrings.M4_UEF_ACU_Killed, false, true)
    ScenarioFramework.CDRDeathNISCamera(ScenarioInfo.UEFCDR, 5)
    M3UEFAI.DisableBase()
end

-----------
-- End Game
-----------
function PlayerWin()
    if(not ScenarioInfo.OpEnded) then
        ScenarioInfo.OpComplete = true
        ScenarioFramework.Dialogue(OpStrings.PlayerWin, KillGame, true)
    end
end

function PlayerDeath()
    if (not ScenarioInfo.OpEnded) then
        ScenarioFramework.CDRDeathNISCamera(ScenarioInfo.PlayerCDR)
        ScenarioFramework.EndOperationSafety()
        ScenarioInfo.OpComplete = false
        for _, v in AssignedObjectives do
            if(v and v.Active) then
                v:ManualResult(false)
            end
        end
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
    UnlockInput()
    ScenarioFramework.EndOperation(ScenarioInfo.OpComplete, ScenarioInfo.OpComplete, true)
end

------------------
-- Other Functions
------------------
function DestroyUnit(unit)
    unit:Destroy()
end

------------------
-- Debug Functions
------------------
function OnCtrlF3()
    ScenarioInfo.Mega = ScenarioUtils.CreateArmyUnit('Player', 'UNIT_10263')
end

function OnShiftF3()
    --[[
    ForkThread(function()
        Cinematics.EnterNISMode()
        Cinematics.CameraMoveToMarker('Cam_Cyb_0', 0)
        WaitSeconds(2)
        Cinematics.CameraMoveToMarker('Cam_Cyb_1', 15)
        WaitSeconds(2)
        Cinematics.CameraMoveToMarker('Cam_Cyb_2', 2)
        WaitSeconds(1)
        Cinematics.ExitNISMode()
    end)
    ]]--
    ScenarioInfo.Mega:ShowBone('Missile_Turret', true)
end

function OnCtrlF4()
    if ScenarioInfo.MissionNumber == 1 then
        for _, v in ArmyBrains[UEF]:GetListOfUnits(categories.ALLUNITS, false) do
            v:Kill()
        end
    elseif ScenarioInfo.MissionNumber == 2 then
        IntroMission3()
    elseif ScenarioInfo.MissionNumber == 3 then
        for _, v in ScenarioInfo.M3ObjectiveExperimentalas do
            v:Kill()
        end
    end
end

function OnShiftF4()
end