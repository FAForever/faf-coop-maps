------------------------------------
-- Custom mission: Operation Trident
--
-- Author: speed2
------------------------------------
local AeonAI = import('/maps/FAF_Coop_Operation_Trident/FAF_Coop_Operation_Trident_AeonAI.lua')
local CybranAI = import('/maps/FAF_Coop_Operation_Trident/FAF_Coop_Operation_Trident_CybranAI.lua')
local UEFAI = import('/maps/FAF_Coop_Operation_Trident/FAF_Coop_Operation_Trident_UEFAI.lua')
local Cinematics = import('/lua/cinematics.lua')
local CustomFunctions = import('/maps/FAF_Coop_Operation_Trident/FAF_Coop_Operation_Trident_CustomFunctions.lua')
local Objectives = import('/lua/SimObjectives.lua')
local OpStrings = import('/maps/FAF_Coop_Operation_Trident/FAF_Coop_Operation_Trident_strings.lua')
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local PingGroups = ScenarioFramework.PingGroups
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local TauntManager = import('/lua/TauntManager.lua')

----------
-- Globals
----------
ScenarioInfo.Player1 = 1
ScenarioInfo.Aeon = 2
ScenarioInfo.UEF = 3
ScenarioInfo.Cybran = 4
ScenarioInfo.Civilians = 5
ScenarioInfo.Player2 = 6

---------
-- Locals
---------
local Player1 = ScenarioInfo.Player1
local Player2 = ScenarioInfo.Player2
local Aeon = ScenarioInfo.Aeon
local UEF = ScenarioInfo.UEF
local Cybran = ScenarioInfo.Cybran
local Civilians = ScenarioInfo.Civilians

local Difficulty = ScenarioInfo.Options.Difficulty
local AssignedObjectives = {}

local LeaderFaction
local LocalFaction

-----------------
-- Taunt Managers
-----------------
local AeonTM = TauntManager.CreateTauntManager('AeonTM', '/maps/FAF_Coop_Operation_Trident/FAF_Coop_Operation_Trident_strings.lua')
local UEFTM = TauntManager.CreateTauntManager('UEFTM', '/maps/FAF_Coop_Operation_Trident/FAF_Coop_Operation_Trident_strings.lua')

-------------
-- Debug Only
-------------
local SkipNIS1 = false

-----------
-- Start up
-----------
function OnPopulate(scenario)
    ScenarioUtils.InitializeScenarioArmies()
    LeaderFaction, LocalFaction = ScenarioFramework.GetLeaderAndLocalFactions()

    local tblArmy = ListArmies()

    -- If there is not Player2 then use Order AI
    if not tblArmy[ScenarioInfo.Player2] then
        ScenarioInfo.UseCybranAI = true
    end

    ---------
    -- UEF AI
    ---------
    UEFAI.M1UEFShoreBaseAI()
    UEFAI.M1UEFCityBaseAI()

    -- Extra Respirces
    ScenarioUtils.CreateArmyGroup('UEF', 'Shore_Resources_D' .. Difficulty)

    -- Walls
    ScenarioUtils.CreateArmyGroup('UEF', 'M1_Walls')

    ScenarioFramework.RefreshRestrictions('UEF')

    -- Patrols
    -- Air
    local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'Shore_Air_Patrol_D' .. Difficulty, 'NoFormation')
    for _, v in platoon:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolChain({v}, 'M1_UEF_Shore_Base_Air_Patrol_Chain')
    end

    -- Land
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'City_Land_Patrol_1', 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M1_UEF_City_Land_North_Patrol_Chain')

    for i = 1, 3 do
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'Shore_Land_Patrol_' .. i .. '_D' .. Difficulty, 'GrowthFormation')
        ScenarioFramework.PlatoonPatrolChain(platoon, 'M1_UEF_Shore_Base_Land_Patrol_Chain_' .. i)
    end

    -- Naval
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'Initial_Naval_Patrol', 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M1_UEF_Shore_Base_Naval_Patrol_Chain')

    ----------
    -- Aeon AI
    ----------
    -- Initial attacks
    -- Air
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'Initial_Air', 'NoFormation')
    platoon:Patrol(ScenarioUtils.MarkerToPosition('M1_UEF_City_Base_Marker'))
    platoon:Patrol(platoon:GetPlatoonPosition())

    -- Land
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'Initial_Land', 'NoFormation')
    platoon:AggressiveMoveToLocation(ScenarioUtils.MarkerToPosition('M1_UEF_City_Base_Marker'))

    -- Naval
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'Initial_Naval', 'AttackFormation')

    -- Off map eco to power up Aeon shields
    ScenarioUtils.CreateArmyGroup('Aeon', 'M1_OffmapEco')

    ------------
    -- Civilians
    ------------
    -- Objective structures
    ScenarioInfo.M1CivilianCity = ScenarioUtils.CreateArmyGroup('Civilians', 'Civilian_City')
    ScenarioInfo.UnitNames[Civilians]['Node_4']:SetCustomName('Cepheus Node 4') -- TODO: Add loc tag: (LOC '{i Cepheus_Node_4}')

    -- Other buildings
    ScenarioUtils.CreateArmyGroup('Civilians', 'Other_Structures')

    -- Wreckages
    ScenarioUtils.CreateArmyGroup('Civilians', 'M1_Wreckages', true)
end

function OnStart(scenario)
    -- Unit and upgade restrictions
    ScenarioFramework.AddRestrictionForAllHumans(
        categories.TECH3 +
        categories.EXPERIMENTAL +
        categories.urb4206 +       -- Shield ED4
        categories.urb4207 +       -- Shield ED5
        categories.xrb0204 +       -- Engie Station 2
        categories.xrb0304         -- Engie Station 3
    )

    -- Allowed: AdvancedEngineering, CoolingUpgrade, NaniteTorpedoTube, StealthGenerator, ResourceAllocation
    ScenarioFramework.RestrictEnhancements({
        'Teleporter',
        'T3Engineering',
        'CloakingGenerator',
        'MicrowaveLaserGenerator',
    })

    -- Colors
    ScenarioFramework.SetCybranPlayerColor(Player1)
    ScenarioFramework.SetAeonPlayerColor(Aeon)
    ScenarioFramework.SetUEFPlayerColor(UEF)
    ScenarioFramework.SetNeutralColor(Civilians)
    if ScenarioInfo.UseCybranAI then
        ScenarioFramework.SetCybranAllyColor(Cybran)
    else
        ScenarioFramework.SetCybranAllyColor(Player2)
        SetArmyColor(Cybran, 219, 74, 58)
    end

    -- Set the maximum number of units that the players is allowed to have
    ScenarioFramework.SetSharedUnitCap(1000)

    -- Set playable area
    ScenarioFramework.SetPlayableArea('M1_Area', false)

    if not SkipNIS1 then
        Cinematics.CameraMoveToMarker('Cam_1_0', 0)
    end

    IntroMission1()
end

function Player2Units()
    local allUnits = ScenarioUtils.CreateArmyGroup('Cybran', 'Player2_Units')

    if not ScenarioInfo.UseCybranAI then
        local landUnits = DropThread(allUnits, 'M1_Player2_Drop_Marker', 'M1_Cybran_Transport_Delete', Player2)
        for _, unit in landUnits do
            if unit and not unit.Dead then
                ScenarioFramework.GiveUnitToArmy(unit, 'Player2')
            end
        end
    else
        local landUnits = DropThread(allUnits, 'M1_Player2_Drop_Marker', 'M1_Cybran_Transport_Delete', Cybran)

        -- Cybran AI, manage dropped units
        local HoplitePlatoon = ArmyBrains[Cybran]:MakePlatoon('', '')
        local FlakPlatoon = ArmyBrains[Cybran]:MakePlatoon('', '')
        local StealthPlatoon = ArmyBrains[Cybran]:MakePlatoon('', '')
        local EngineerPlatoon = ArmyBrains[Cybran]:MakePlatoon('', '')
        for _, unit in landUnits do
            -- Assign the rest of land units to appropriate platoons
            if EntityCategoryContains(categories.drl0204, unit) then
                ArmyBrains[Cybran]:AssignUnitsToPlatoon(HoplitePlatoon, {unit}, 'Attack', 'AttackFormation')
            elseif EntityCategoryContains(categories.url0205, unit) then
                ArmyBrains[Cybran]:AssignUnitsToPlatoon(FlakPlatoon, {unit}, 'Attack', 'NoFormation')
            elseif EntityCategoryContains(categories.url0306, unit) then
                ArmyBrains[Cybran]:AssignUnitsToPlatoon(StealthPlatoon, {unit}, 'Support', 'NoFormation')
            -- Engineers for reclaim
            elseif EntityCategoryContains(categories.url0105, unit) then
                ArmyBrains[Cybran]:AssignUnitsToPlatoon(EngineerPlatoon, {unit}, 'Support', 'NoFormation')
            end
        end

        -- Patrol aroud the base
        ScenarioFramework.PlatoonPatrolChain(HoplitePlatoon, 'M1_Cybran_Hoplite_Patrol_Chain')
        ScenarioFramework.PlatoonPatrolChain(FlakPlatoon, 'M1_Cybran_Flak_Patrol_Chain')
        for index, unit in StealthPlatoon:GetPlatoonUnits() do
            IssueMove({unit}, ScenarioUtils.MarkerToPosition('M1_Cybran_Stealth_Marker_' .. index))
        end
        for _, unit in EngineerPlatoon:GetPlatoonUnits() do
            ScenarioFramework.GroupPatrolChain({unit}, 'M1_Cybran_Main_Base_EngineerChain')
        end

        M1CybranBaseBuildingThread()
    end
end

function Player1Units()
    local allUnits = ScenarioUtils.CreateArmyGroup('Cybran', 'Player1_Units')
    local landUnits = DropThread(allUnits, 'M1_Player1_Drop_Marker', 'M1_Player_Transport_Delete', Player1)
    WaitSeconds(1)
    for _, unit in landUnits do
        if unit and not unit.Dead then
            ScenarioFramework.GiveUnitToArmy(unit, 'Player1')
        end
    end
end

function DropThread(allUnits, dropMarker, deleteMarker, army, moveChain)
    local landUnits = {}
    local transports = {}

    for _, unit in allUnits do
        if EntityCategoryContains(categories.TRANSPORTATION, unit) then
            table.insert(transports, unit)
        else
            table.insert(landUnits, unit)
        end
    end

    ScenarioFramework.AttachUnitsToTransports(landUnits, transports)

    if moveChain then
        ScenarioFramework.GroupMoveChain(transports, moveChain)
    end

    IssueTransportUnload(transports, ScenarioUtils.MarkerToPosition(dropMarker))

    IssueMove(transports, ScenarioUtils.MarkerToPosition(deleteMarker))

    for _, transport in transports do
        ScenarioFramework.CreateUnitToMarkerDistanceTrigger(DestroyUnit, transport, deleteMarker, 15)
    end

    for _, unit in landUnits do
        while unit and not unit.Dead and unit:IsUnitState('Attached') do
            WaitSeconds(1)
        end

        if army then
            -- Since the player's unit can't move from offmap, we do this switcherino
            if EntityCategoryContains(categories.COMMAND, unit) then
                local position = unit:GetPosition()
                local orientation = unit:GetOrientation()
                unit:Destroy()

                if army == Player1 then
                    ScenarioInfo.Player1ACU = ScenarioFramework.SpawnCommander('Player1', 'Commander', false, true, true, PlayerDeath,
                        {'CoolingUpgrade', 'StealthGenerator'})
                    Warp(ScenarioInfo.Player1ACU, position, orientation)
                elseif army == Player2 then
                    ScenarioInfo.Player2ACU = ScenarioFramework.SpawnCommander('Player2', 'Commander', false, true, true, PlayerDeath,
                        {'AdvancedEngineering', 'ResourceAllocation', 'NaniteTorpedoTube'})
                    Warp(ScenarioInfo.Player2ACU, position, orientation)
                elseif army == Cybran then
                    -- There's no real need to do the same for the Cybran AI as well, but this function is more convenient to set up the ACU
                    ScenarioInfo.CybranACU = ScenarioFramework.SpawnCommander('Cybran', 'Commander', false, 'Wyxe', true, PlayerDeath,
                        {'AdvancedEngineering', 'ResourceAllocation', 'NaniteTorpedoTube'})
                    ScenarioInfo.CybranACU:SetAutoOvercharge(true)
                    Warp(ScenarioInfo.CybranACU, position, orientation)
                end
            end
        end
    end
    return landUnits
end

function M1CybranBaseBuildingThread()
    CybranAI.M1CybranMainBaseAI()
    ArmyBrains[Cybran]:PBMSetCheckInterval(5)

    local function GiveStorageToPlayer()
        local units = ArmyBrains[Cybran]:GetListOfUnits(categories.urb1105, false)
        for _, v in units do
            if v and v:GetFractionComplete() == 1 then
                -- Inform player and give the storage
                ScenarioFramework.Dialogue(OpStrings.M1StorageGiven)

                ScenarioFramework.GiveUnitToArmy(v, 'Player1')
                return
            end
        end
    end

    local function T2RadarBuilt()
        ScenarioFramework.Dialogue(OpStrings.M1RadarBuilt)

        -- Boost the radar a bit so it shows the UEF base.
        local radar = ArmyBrains[Cybran]:GetListOfUnits(categories.urb3201, false)[1]
        if radar then
            radar:SetIntelRadius('Radar', 260)
        end
    end

    local function ACUAssistNavalFactory()
        local factory = ArmyBrains[Cybran]:GetListOfUnits(categories.FACTORY * categories.TECH1 * categories.NAVAL, false)[1]
        IssueGuard({ScenarioInfo.CybranACU}, factory)
    end

    local function ACUStopAssisting()
        IssueStop({ScenarioInfo.CybranACU})
        IssueClearCommands({ScenarioInfo.CybranACU})
    end

    -- Increase engineer count once there's T2 factory to build the rest of the base faster
    ScenarioFramework.CreateArmyStatTrigger(CybranAI.IncreaseEngineerCount, ArmyBrains[Cybran], 'M1_Cybran_Factory_Trigger_1',
        {{StatType = 'Units_Active', CompareType = 'GreaterThanOrEqual', Value = 1, Category = categories.FACTORY * categories.TECH2 * categories.AIR}})

    -- After all T2 factories are placed, start assisting them with the engineers
    ScenarioFramework.CreateArmyStatTrigger(CybranAI.ResetEngineerCount, ArmyBrains[Cybran], 'M1_Cybran_Factory_Trigger_2',
        {{StatType = 'Units_Active', CompareType = 'GreaterThanOrEqual', Value = 8, Category = categories.FACTORY * categories.TECH2}})

    -- Give an energy storage to the player
    ScenarioFramework.CreateArmyStatTrigger(GiveStorageToPlayer, ArmyBrains[Cybran], 'M1_Cybran_Storage_Trigger',
        {{StatType = 'Units_Active', CompareType = 'GreaterThanOrEqual', Value = 1, Category = categories.urb1105}})

    -- Assist upgading the naval factory
    ScenarioFramework.CreateArmyStatTrigger(ACUAssistNavalFactory, ArmyBrains[Cybran], 'M1_Cybran_Naval_Factory_Trigger',
        {{StatType = 'Units_Active', CompareType = 'GreaterThanOrEqual', Value = 1, Category = categories.FACTORY * categories.TECH1 * categories.NAVAL}})

    -- Once the T2 naval is done, return to other building
    ScenarioFramework.CreateArmyStatTrigger(ACUStopAssisting, ArmyBrains[Cybran], 'M1_Cybran_T2_Naval_Factory_Trigger',
        {{StatType = 'Units_Active', CompareType = 'GreaterThanOrEqual', Value = 1, Category = categories.FACTORY * categories.TECH2 * categories.NAVAL}})

    -- Announce construction of a T2 Radar
    ScenarioFramework.CreateArmyStatTrigger(T2RadarBuilt, ArmyBrains[Cybran], 'M1_Cybran_Radar_Trigger',
        {{StatType = 'Units_Active', CompareType = 'GreaterThanOrEqual', Value = 1, Category = categories.urb3201}})
end

-------------
-- Win / Lose
-------------
function PlayerWin()
    ScenarioInfo.OpComplete = true

    ScenarioFramework.EndOperationSafety()
    ScenarioFramework.FlushDialogueQueue()

    ForkThread(KillGame)
end

function PlayerDeath(ACU)
    ScenarioInfo.OpComplete = false

    ScenarioFramework.PlayerDeath(ACU, OpStrings.PlayerDies)
end

function PlayerLose(unit)
    ScenarioInfo.OpComplete = false

    ForkThread(KillGame)
end

function KillGame()
    local secondaries = Objectives.IsComplete(ScenarioInfo.M2S1)
                    and Objectives.IsComplete(ScenarioInfo.M2S2)
    local bonuses = Objectives.IsComplete(ScenarioInfo.M1B1)
                and Objectives.IsComplete(ScenarioInfo.M1B2)
                and Objectives.IsComplete(ScenarioInfo.M2B1)
                and Objectives.IsComplete(ScenarioInfo.M2B2)
                and Objectives.IsComplete(ScenarioInfo.M2B3)

    ScenarioFramework.EndOperation(ScenarioInfo.OpComplete, ScenarioInfo.OpComplete, secondaries, bonuses)
end

------------
-- Mission 1
------------
function IntroMission1()
    ScenarioInfo.MissionNumber = 1

    ForkThread(IntroMission1NIS)
end

function IntroMission1NIS()
    if not SkipNIS1 then
        Cinematics.EnterNISMode()
        
        local VizMarkerCity = ScenarioFramework.CreateVisibleAreaLocation(40, 'Viz_Marker_City1', 0, ArmyBrains[Player1]) -- TODO: Viz_Marker_City2
        local VizMarkerNaval = ScenarioFramework.CreateVisibleAreaLocation(40, 'Viz_Marker_Naval', 0, ArmyBrains[Player1])

        WaitSeconds(2)
        
        -- Look at the City
        ScenarioFramework.Dialogue(OpStrings.M1Intro1, nil, true)
        Cinematics.CameraMoveToMarker('Cam_1_1', 4)
        
        WaitSeconds(3)

        -- Naval cam
        ScenarioFramework.Dialogue(OpStrings.M1Intro2, nil, true)
        Cinematics.CameraMoveToMarker('Cam_1_2', 3)

        WaitSeconds(4)
        
        -- Starting position, send transports in
        ForkThread(Player2Units)
        ForkThread(Player1Units)
        ScenarioFramework.Dialogue(OpStrings.M1Intro3, nil, true)
        Cinematics.CameraMoveToMarker('Cam_1_3', 6)

        WaitSeconds(4)
        
        ScenarioFramework.Dialogue(OpStrings.M1Intro4, nil, true)
        Cinematics.CameraMoveToMarker('Cam_1_4', 5)

        WaitSeconds(5)

        VizMarkerCity:Destroy()
        VizMarkerNaval:Destroy()

        ScenarioFramework.SetPlayableArea('M1_Area', false)
        
        Cinematics.ExitNISMode()
    else
        ForkThread(Player2Units)
        ForkThread(Player1Units)
    end

    StartMission1()
end

function StartMission1()
    ---------------------------------------------
    -- Primary Objective - Secure the Cybran City
    ---------------------------------------------
    ScenarioInfo.M1P1 = Objectives.CategoriesInArea(
        'primary',
        'incomplete',
        OpStrings.M1P1Title,
        OpStrings.M1P1Description,
        'killorcapture',
        {
            MarkUnits = true,
            Requirements = {
                {
                    Area = 'M1_City_Area',
                    Category = categories.DEFENSE - categories.WALL + (categories.LAND * categories.MOBILE),
                    CompareOp = '<=',
                    Value = 0,
                    ArmyIndex = UEF,
                },
            },
        }
    )
    ScenarioInfo.M1P1:AddResultCallback(
        function(result)
            if result then
                -- Finishing the quick strike objective if it's still active
                if ScenarioInfo.M1B1.Active then
                    ScenarioInfo.M1B1:ManualResult(true)
                end

                -- Ally the civs with the players and the Cybran AI
                for _, player in ScenarioInfo.HumanPlayers do
                    SetAlliance(player, Civilians, 'Ally')
                    SetAlliance(Civilians, player, 'Ally')
                end
                SetAlliance(Cybran, Civilians, 'Ally')
                SetAlliance(Civilians, Cybran, 'Ally')

                ScenarioFramework.Dialogue(OpStrings.M1CitySaved, IntroMission2, true)
            end
        end
    )

    ---------------------------------------
    -- Primary Objective - Protect the City
    ---------------------------------------
    ScenarioInfo.M1NumOfCityBuildings = table.getn(ScenarioInfo.M1CivilianCity)
    ScenarioInfo.M1P2 = Objectives.Protect(
        'primary',
        'incomplete',
        OpStrings.M1P2Title,
        LOCF(OpStrings.M1P2Description, 50),
        {
            Units = ScenarioInfo.M1CivilianCity,
            NumRequired = math.floor(ScenarioInfo.M1NumOfCityBuildings / 2),
            PercentProgress = true,
        }
    )
    ScenarioInfo.M1P2:AddProgressCallback(
        function(total, numRequired)
            -- Dialogues the node is getting destroyed, different ones for first and second part of the mission
            -- First building destroyed
            if total == (ScenarioInfo.M1NumOfCityBuildings - 1) then
                ScenarioFramework.Dialogue(OpStrings['M' .. ScenarioInfo.MissionNumber .. 'CityBuildingDestroyed1'], nil, true) -- Marked as critical so it always gets played
            -- Half of the allowed buildings lost
            elseif total == math.floor(ScenarioInfo.M1NumOfCityBuildings * 0.75) then
                ScenarioFramework.Dialogue(OpStrings['M' .. ScenarioInfo.MissionNumber .. 'CityBuildingDestroyed2'])
            -- We're at the treshold, one more and the player fails
            elseif total == numRequired then
                ScenarioFramework.Dialogue(OpStrings['M' .. ScenarioInfo.MissionNumber .. 'CityBuildingDestroyed3'])
            end
        end
    )
    ScenarioInfo.M1P2:AddResultCallback(
        function(result, unit)
            if not result then
                if ScenarioInfo.M1P1.Active then
                    ScenarioInfo.M1P1:ManualResult(false)
                end

                ScenarioFramework.CDRDeathNISCamera(unit)
                ScenarioFramework.EndOperationSafety()

                ScenarioFramework.FlushDialogueQueue()
                ScenarioFramework.Dialogue(OpStrings.CityDestroyed, PlayerLose, true)
            end
        end
    )

    ---------------------------------
    -- Bonus Objective - Quick Strike
    ---------------------------------
    ScenarioInfo.M1B1 = Objectives.Basic(
        'bonus',
        'incomplete',
        OpStrings.M1B1Title,
        OpStrings.M1B1escription,
        Objectives.GetActionIcon('timer'),
        {
            Hidden = true,
        }
    )

    -------------------------------------
    -- Bonus Objective - No building dies
    -------------------------------------
    ScenarioInfo.M1B2 = Objectives.Protect(
        'bonus',
        'incomplete',
        OpStrings.M1B2Title,
        OpStrings.M1B2escription,
        {
            Units = ScenarioInfo.M1CivilianCity,
            Hidden = true,
            MarkUnits = false,
        }
    )

    -- Triggers
    -- Shameless self promotion
    ScenarioFramework.CreateTimerTrigger(MissionNameAnnouncement, 6)

    -- "I will build quickly my base"
    ScenarioFramework.CreateTimerTrigger(M1PostIntroDialogue, 20)

    -- "UEF base is only lightly defended"
    ScenarioFramework.CreateArmyIntelTrigger(M1UEFBaseSpotted, ArmyBrains[Player1], 'LOSNow', false, true, (categories.TECH2 * categories.DEFENSE * categories.STRUCTURE) - categories.ANTINAVY, true, ArmyBrains[UEF])

    -- Aeon sees Cybran, gotta cover both Player2/CybranAI cases as well
    ScenarioFramework.CreateArmyIntelTrigger(M1AeonTaunt, ArmyBrains[Aeon], 'LOSNow', false, true, categories.ALLUNITS, true, ArmyBrains[Player1])
    if ScenarioInfo.UseCybranAI then
        ScenarioFramework.CreateArmyIntelTrigger(M1AeonTaunt, ArmyBrains[Aeon], 'LOSNow', false, true, categories.ALLUNITS, true, ArmyBrains[Cybran])
    else
        ScenarioFramework.CreateArmyIntelTrigger(M1AeonTaunt, ArmyBrains[Aeon], 'LOSNow', false, true, categories.ALLUNITS, true, ArmyBrains[Player2])
    end

    -- Send more UEF units to the settlement when all the engineers are dead
    ScenarioFramework.CreateAreaTrigger(M1SendCitySupport, 'M1_City_Area', categories.ENGINEER * categories.TECH2, true, true, ArmyBrains[UEF], 1)

    -- Aeon attacks on the UEF
    ScenarioFramework.CreateTimerTrigger(M1AeonAirAttack, 100)
    ScenarioFramework.CreateTimerTrigger(M1AeonLandAttack, 110)
    ScenarioFramework.CreateTimerTrigger(M1AeonNavalAttack, 120)

    -- Reminders
    -- Fail the quick strike objective with the first reminder
    ScenarioFramework.CreateTimerTrigger(M1P1Reminder1, 15*60)
    -- Another reminder after next 2 minutes
    ScenarioFramework.CreateTimerTrigger(M1P1Reminder2, 20*60)
    -- Send an attack that should kill the city (let's hope for the best) and fail the mission
    ScenarioFramework.CreateTimerTrigger(M1LaunchAeonAttack, 25*60)

    -- Taunts
    ForkThread(SetupUEFM1Taunts)
end

function MissionNameAnnouncement()
    ScenarioFramework.SimAnnouncement(ScenarioInfo.name, 'mission by [e]speed2')
end

function M1PostIntroDialogue()
    if ScenarioInfo.UseCybranAI then
        ScenarioFramework.Dialogue(OpStrings.M1PostIntro)
    end
end

function M1UEFBaseSpotted()
    if ScenarioInfo.UseCybranAI then
        ScenarioFramework.Dialogue(OpStrings.M1UEFBaseSpotted1)
    else
        ScenarioFramework.Dialogue(OpStrings.M1UEFBaseSpotted2)
    end
end

function M1AeonTaunt()
    if not ScenarioInfo.M1AeonDialoguePlayed then
        ScenarioInfo.M1AeonDialoguePlayed = true
        ScenarioFramework.Dialogue(OpStrings.M1AeonSeesCybran)
    end
end

function M1AeonAirAttack()
    if ScenarioInfo.MissionNumber ~= 1 then
        return
    end

    -- Play a Aeon dialogue with the first attack
    if not ScenarioInfo.M1AeonInitialDialoguePlayed then
        ScenarioInfo.M1AeonInitialDialoguePlayed = true
        ScenarioFramework.Dialogue(OpStrings.M1AeonInitialDialogue)
    end

    local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M1_Air_Attack', 'NoFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M1_Aeon_Air_Attack_Chain_' .. Random(1, 2))

    local delay = {220, 160, 100}
    ScenarioFramework.CreateTimerTrigger(M1AeonAirAttack, delay[Difficulty])
end

function M1AeonLandAttack()
    if ScenarioInfo.MissionNumber ~= 1 then
        return
    end

    local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M1_Land_Attack_' .. Random(1, 2), 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M1_Aeon_Land_Attack_Chain_' .. Random(1, 2))

    local delay = {170, 140, 110}
    ScenarioFramework.CreateTimerTrigger(M1AeonLandAttack, delay[Difficulty])
end

function M1AeonNavalAttack()
    if ScenarioInfo.MissionNumber ~= 1 then
        return
    end

    local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M1_Naval_Attack', 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M1_Aeon_Naval_Attack_Chain')

    local delay = {200, 160, 120}
    ScenarioFramework.CreateTimerTrigger(M1AeonNavalAttack, delay[Difficulty])
end

function M1SendCitySupport()
    -- Send more UEF units to the settlement when all the engineers are dead
    ScenarioFramework.Dialogue(OpStrings.M1CitySupportSent)

    -- Air support coming from offmap
    local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M1_City_Support_Air_D' .. Difficulty, 'NoFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M1_UEF_City_Air_Patrol_Chain')

    -- Drops
    for i = 1, 2 do
        ForkThread(function(i)
            local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M1_City_Support_Land_' .. i, 'GrowthFormation')
            local units = DropThread(platoon:GetPlatoonUnits(), 'M1_UEF_Drop_Marker_' .. i , 'M1_UEF_Drop_Delete_Marker')
            local patrolChain = 'M1_UEF_City_Land_South_Patrol_Chain'
            if i == 1 then
                patrolChain = 'M1_UEF_City_Land_North_Patrol_Chain'
            end
            ScenarioFramework.GroupPatrolChain(units, patrolChain)
        end, i)
    end
end

function M1LaunchAeonAttack()
    if not ScenarioInfo.M1P1.Active then
        return
    end

    -- Notify the player that the impendent  doom is coming
    ScenarioFramework.Dialogue(OpStrings.M1AeonFinalAttack, nil, true)

    for i = 1, 5 do
        local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M1_Final_Attack_Land_' .. i, 'GrowthFormation')
        platoon:AggressiveMoveToLocation(ScenarioUtils.MarkerToPosition('M1_Final_Attack_Marker'))
    end

    for i = 1, 4 do
        local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M1_Final_Attack_Air_' .. i, 'NoFormation')
        platoon:AggressiveMoveToLocation(ScenarioUtils.MarkerToPosition('M1_Final_Attack_Marker'))
    end
end

function M1ScoutPlatoonFormed(platoon)
    if ScenarioInfo.MissionNumber ~= 1 then
        return
    end

    ScenarioInfo.M1ScoutPlatoon = platoon

    -- Remove the button if all scouts get killed before sent
    -- ScenarioInfo.M1ScoutPlatoon:AddDestroyCallback(M1RemoveScoutButton)

    -- Reveal Ping
    if not ScenarioInfo.M1ScoutsRevealed then
        ScenarioInfo.M1ScoutsRevealed = true
        ScenarioFramework.Dialogue(OpStrings.M1ScoutsReady1)
    else
        ScenarioFramework.Dialogue(OpStrings['M1ScoutsReady' .. Random(2, 3)])
    end

    M1ScoutButton()
end

function M1ScoutButton()
    if not ScenarioInfo.M1ScoutPing and ScenarioInfo.MissionNumber == 1 then
        -- Setup ping
        ScenarioInfo.M1ScoutPing = PingGroups.AddPingGroup(OpStrings.M1ScoutButtonTitle, 'ura0101', 'move', OpStrings.M1ScoutButtonDescription)
        ScenarioInfo.M1ScoutPing:AddCallback(M1SendAirScoutToLocation)
    end
end

function M1SendAirScoutToLocation(location)
    -- Play the dialogue the first time and then just on every other launch
    if not ScenarioInfo.M1FirstScoutSent then
        ScenarioInfo.M1FirstScoutSent = true
        ScenarioFramework.Dialogue(OpStrings['M1ScoutSent' .. Random(1, 3)])
    else
        if Random(1, 2) == 1 then
            ScenarioFramework.Dialogue(OpStrings['M1ScoutSent' .. Random(1, 3)])
        end
    end

    ForkThread(M1RemoveScoutButton)

    local scout = M1GetAvailableScout()
    if scout then
        IssueStop({scout})
        IssueClearCommands({scout})
        IssuePatrol({scout}, location)
        IssuePatrol({scout}, ScenarioUtils.MarkerToPosition('M1_Cybran_Main_Base_Marker'))
    end
end

function M1GetAvailableScout()
    if ScenarioInfo.M1ScoutPlatoon then
        for _, scout in ScenarioInfo.M1ScoutPlatoon:GetPlatoonUnits() do
            if not scout.Dead then
                return scout
            end
        end
    end

    return false
end

function M1RemoveScoutButton()
    if ScenarioInfo.M1ScoutPing then
        ScenarioInfo.M1ScoutPing:Destroy()
        ScenarioInfo.M1ScoutPing = nil
    end

    WaitSeconds(20)

    if M1GetAvailableScout() then
        M1ScoutButton()
    end
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

    ----------
    -- Aeon AI
    ----------
    -- Bases
    AeonAI.M2AeonMainBaseAI()
    AeonAI.M2AeonResourceBaseAI()

    -- Air staging on the hill
    ScenarioUtils.CreateArmyGroup('Aeon', 'Air_Refuel_Plateau_D' .. Difficulty)

    -- Off map eco to help build more units. I know, I know, I should teach the AI to reclaim more and what not, but fuck it, this will do for now...
    ScenarioUtils.CreateArmyGroup('Aeon', 'M2_OffmapEco')

    -- Some extra defenses on the way to the base
    ScenarioUtils.CreateArmyGroup('Aeon', 'Extra_Defense_D' .. Difficulty)

    -- Walls
    ScenarioUtils.CreateArmyGroup('Aeon', 'Walls')

    -- ACU, patrol among the air factories. Randomly pick one upgrades variation.
    local upgrades = {
        {'CrysalisBeam', 'HeatSink', 'ChronoDampener'},
        {'AdvancedEngineering', 'HeatSink', 'ChronoDampener'},
        {'CrysalisBeam', 'EnhancedSensors', 'Shield', 'ShieldHeavy'},
        {'AdvancedEngineering', 'EnhancedSensors', 'Shield', 'ShieldHeavy'},
    }
    ScenarioInfo.AeonACU = ScenarioFramework.SpawnCommander('Aeon', 'Commander', false, 'Cora', false, false, upgrades[Random(1, table.getn(upgrades))])
    ScenarioInfo.AeonACU:SetVeterancy(1 + Difficulty)
    ScenarioInfo.AeonACU:SetAutoOvercharge(true)
    ScenarioInfo.AeonACUPlatoon = ArmyBrains[Aeon]:MakePlatoon('', '')
    ArmyBrains[Aeon]:AssignUnitsToPlatoon(ScenarioInfo.AeonACUPlatoon, {ScenarioInfo.AeonACU}, 'Attack', 'NoFormation')
    ScenarioFramework.PlatoonPatrolChain(ScenarioInfo.AeonACUPlatoon, 'M2_Aeon_Commander_Patrol_Chain')

    ScenarioInfo.AeonsACU = ArmyBrains[Aeon]:GetListOfUnits(categories.ual0301, false)[1]
    ScenarioInfo.AeonsACU:SetCustomName('Mila')

    ScenarioFramework.RefreshRestrictions('Aeon')

    ----------
    -- Patrols
    ----------
    -- Air
    local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M2_Base_Air_Patrol_D' .. Difficulty, 'NoFormation')
    for _, v in platoon:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M2_Aeon_Air_Patrol_Chain')))
    end
    -- Land
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M2_Base_Land_Patrol_D' .. Difficulty, 'NoFormation')
    for _, v in platoon:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M2_Aeon_Land_Patrol_Chain')))
    end

    -- Naval
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M2_Base_Naval_Patrol_D' .. Difficulty, 'NoFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M2_Aeon_Naval_Patrol_Chain')

    -- Missile ship for the bonus objective
    if Difficulty >= 2 then
        ScenarioInfo.M2MissileShip = ScenarioUtils.CreateArmyUnit('Aeon', 'Missile_Ship')
        platoon = ArmyBrains[Aeon]:MakePlatoon('', '')
        ArmyBrains[Aeon]:AssignUnitsToPlatoon(platoon, {ScenarioInfo.M2MissileShip}, 'Attack', 'NoFormation')

        -- Trigger for assigning the bonus objective once players see the ship
        ScenarioFramework.CreateArmyIntelTrigger(M2MissileShipSpotted, ArmyBrains[Player1], 'LOSNow', false, true, categories.xas0306, true, ArmyBrains[Aeon])
    end

    ----------
    -- Attacks
    ----------
    -- Air
    local AirChains = {
        'M2_Aeon_Land_Attack_Chain_1',
        'M2_Aeon_Land_Attack_Chain_2',
        'M2_Aeon_Naval_Attack_Player_Chain',
    }

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M2_Initial_Air_Attack_D' .. Difficulty, 'NoFormation')
    for _, unit in platoon:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolChain({unit}, AirChains[Random(1, table.getn(AirChains))])
    end

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M2_Initial_Swiftwinds_D' .. Difficulty, 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M2_Aeon_Land_Attack_Chain_' .. Random(1, 2))

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M2_Initial_Scouts', 'NoFormation')
    for i, unit in platoon:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolChain({unit}, AirChains[i])
    end

    -- Land
    for i = 1, 2 do
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M2_Initial_Land_Attack_' .. i ..'_D' .. Difficulty, 'GrowthFormation')
        ScenarioFramework.PlatoonPatrolChain(platoon, 'M2_Aeon_Land_Attack_Chain_' .. i)
    end

    for i = 3, 4 do
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M2_Initial_Land_Attack_' .. i ..'_D' .. Difficulty, 'AttackFormation')
        ScenarioFramework.PlatoonPatrolChain(platoon, 'M2_Aeon_Land_Attack_Chain_' .. (i - 2))
    end
    
    -- Naval
    -- Attack UEF
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M2_Initial_Naval_Attack_UEF', 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M2_Aeon_Naval_Attack_UEF_Chain')

    -- Attack Player
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'M2_Initial_Naval_Attack_Player_D' .. Difficulty, 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M2_Aeon_Naval_Attack_Player_Chain')

    -- Fill AI's storages
    ArmyBrains[Aeon]:GiveResource('MASS', 10000)

    ---------
    -- UEF AI
    ---------
    UEFAI.M2UEFAtlantisBaseAI()

    -- Shield boats over defenses
    if Difficulty >= 2 then
        ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M2_Shield_Boats_D' .. Difficulty, 'NoFormation')
    end

    -- Naval
    ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'Atlantis_Group_D' .. Difficulty, 'NoFormation')

    ScenarioInfo.M2Atlantis = ScenarioInfo.UnitNames[UEF]['M2_Atlantis']
    ScenarioInfo.M2Atlantis:SetVeterancy(Difficulty) -- More HP for the Atlantis

    ----------
    -- Patrols
    ----------
    -- Air Patrol
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M2_Initial_Air_Patrol_D' .. Difficulty, 'NoFormation')
    for _, v in platoon:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M2_UEF_Air_Patrol_Chain')))
    end
    CustomFunctions.UnitsMultiplyMaxFuel(platoon:GetPlatoonUnits(), 10) -- More fuel for the air units, since they can't refuel in the Atlantis cause it's always building something.

    -- Naval Patrol
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M2_Initial_Naval_Patrol_D' .. Difficulty, 'NoFormation')
    for _, unit in platoon:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolChain({unit}, 'M2_UEF_Naval_Defense_Chain')
    end

    ----------
    -- Attacks
    ----------
    -- Attack Aeon
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M2_Initial_Naval_Attack_Aeon', 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M2_UEF_Naval_Attack_Aeon_Chain')

    -- Attack Cybran
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M2_Initial_Naval_Attack_Cybran_D' .. Difficulty, 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M2_UEF_Naval_Attack_Cybran_Chain')

    -- Off map eco to power up the sea base
    ScenarioUtils.CreateArmyGroup('UEF', 'Offmap_Eco')

    ScenarioFramework.RefreshRestrictions('UEF')

    ------------
    -- Cybran AI
    ------------
    -- Extra mexes after the map expansion
    if ScenarioInfo.UseCybranAI then
        CybranAI.M2BuildExtraEconomy()
        CybranAI.M2CybranMainBaseAirAttacks()
        CybranAI.M2CybranMainBaseLandAttacks()
        CybranAI.M2CybranMainBaseNavalAttacks()
    end

    -- Wreckages
    ScenarioUtils.CreateArmyGroup('Civilians', 'M2_Wreckages', true)

    ForkThread(IntroMission2NIS)
end

function IntroMission2NIS()
    ScenarioFramework.SetPlayableArea('M2_Area', true)

    -- No cinematics, just a dialogue
    ScenarioFramework.Dialogue(OpStrings.M2Intro, StartMission2, true)
end

function StartMission2()
    --------------------------------------
    -- Primary Objective - Locate Atlantis
    --------------------------------------
    ScenarioInfo.M2P1 = Objectives.Locate(
        'primary',
        'incomplete',
        OpStrings.M2P1Title,
        OpStrings.M2P1Description,
        {
            Units = {ScenarioInfo.M2Atlantis},
        }
    )
    ScenarioInfo.M2P1:AddResultCallback(
        function(result)
            if result then
                ScenarioFramework.Dialogue(OpStrings.M2AtlantisLocated, M2KillAtlantisObjective, true)
            end
        end
    )

    --------------------------------
    -- Bonus Objective - Build intel
    --------------------------------
    ScenarioInfo.M2B1 = Objectives.CategoriesInArea(
        'bonus',
        'incomplete',
        OpStrings.M2B1Title,
        OpStrings.M2B1Description,
        'build',
        {
            MarkUnits = false,
            Hidden = true,
            Requirements = {
                {   
                    Area = 'M2_Island_Area',
                    Category = categories.STRUCTURE * categories.TECH2 * categories.RADAR,
                    CompareOp = '>=',
                    Value = 1,
                    Armies = {'HumanPlayers'},
                },
                {   
                    Area = 'M2_Island_Area',
                    Category = categories.STRUCTURE * categories.TECH2 * categories.SONAR,
                    CompareOp = '>=',
                    Value = 1,
                    Armies = {'HumanPlayers'},
                },
            },
        }
    )

    -- Objective to build shields
    ScenarioFramework.CreateTimerTrigger(M2ShieldObjective, 60)

    -- Change Cybran Upgrades
    ScenarioFramework.CreateTimerTrigger(M2ChangeCybranUpgrades, 120)

    -- Objective to kill Aeon commanders
    ScenarioFramework.CreateArmyIntelTrigger(M2KillAeonCommandersObjective, ArmyBrains[Player1], 'LOSNow', false, true, categories.FACTORY, true, ArmyBrains[Aeon])

    -- Start UEF drops after 3 minutes
    ScenarioFramework.CreateTimerTrigger(M2UEFDrops, 3*60)

    -- "Civs getting ready" dialogue
    ScenarioFramework.CreateTimerTrigger(M2Dialog1, 5*60)

    -- Reminder
    ScenarioFramework.CreateTimerTrigger(M2P1Reminder, 6*60)

    -- Taunts
    SetupUEFM2Taunts()
    SetupAeonM2Taunts()
end

function M2KillAtlantisObjective()
    ------------------------------------
    -- Primary Objective - Kill Atlantis
    ------------------------------------
    ScenarioInfo.M2P2 = Objectives.Kill(
        'primary',
        'incomplete',
        OpStrings.M2P2Title,
        OpStrings.M2P2Description,
        {
            Units = {ScenarioInfo.M2Atlantis},
        }
    )
    ScenarioInfo.M2P2:AddResultCallback(
        function(result)
            if result then
                ScenarioFramework.Dialogue(OpStrings.M2AtlantisDestroyed, M2StartEvacuation, true)
            end
        end
    )

    -- Reminder
    ScenarioFramework.CreateTimerTrigger(M2P2Reminder1, 15*60)
end

function M2ShieldObjective()
    ScenarioFramework.Dialogue(OpStrings.M2BuildShields)
    
    --------------------------------------
    -- Secondary Objective - Build Shields
    --------------------------------------
    ScenarioInfo.M2S1 = Objectives.CategoriesInArea(
        'secondary',
        'incomplete',
        OpStrings.M2S1Title,
        OpStrings.M2S1Description,
        'build',
        {
            MarkArea = true,
            Requirements = {
                {   
                    Area = 'M2_Shield_Area_1',
                    Category = categories.urb4205,
                    CompareOp = '>=',
                    Value = 1,
                    Armies = {'HumanPlayers'},
                },
                {   
                    Area = 'M2_Shield_Area_2',
                    Category = categories.urb4205,
                    CompareOp = '>=',
                    Value = 1,
                    Armies = {'HumanPlayers'},
                },
            },
        }
    )
    ScenarioInfo.M2S1:AddResultCallback(
        function(result)
            if result then
                ScenarioFramework.Dialogue(OpStrings.M2hieldsBuilt)
            end
        end
    )
end

function M2ChangeCybranUpgrades()
    if not ScenarioInfo.UseCybranAI and not ScenarioInfo.CybranACU.Dead then
        return
    end

    ScenarioFramework.Dialogue(OpStrings.M2ChangeEnhancements)

    while ScenarioInfo.CybranACU:IsUnitState('Building') do
        WaitSeconds(0.5)
    end

    CybranAI.M2RemoveACUFromConstruction()
    
    --repeat
        ScenarioInfo.CybranACU.PlatoonHandle:StopAI()
        LOG('Cybran ACU trying to remove enhancement')
        local order = {
            TaskName = "EnhanceTask",
            Enhancement = 'ResourceAllocationRemove'
        }
        IssueStop({ScenarioInfo.CybranACU})
        IssueClearCommands({ScenarioInfo.CybranACU})
        IssueScript({ScenarioInfo.CybranACU}, order)
        WaitSeconds(1)
    --until not ScenarioInfo.CybranACU:HasEnhancement('ResourceAllocation')

    CybranAI.M2ChangeACUEnhancements()
end

function M2KillAeonCommandersObjective()
    ScenarioFramework.Dialogue(OpStrings.M2KillAeonCommanders)

    ---------------------------------------------
    -- Secondary Objective - Kill Aeon Commanders
    ---------------------------------------------
    ScenarioInfo.M2S2 = Objectives.Kill(
        'secondary',
        'incomplete',
        OpStrings.M2S2Title,
        OpStrings.M2S2Description,
        {
            Units = {ScenarioInfo.AeonACU, ScenarioInfo.AeonsACU},
        }
    )
    ScenarioInfo.M2S2:AddProgressCallback(
        function(killed, total)
            if ScenarioInfo.AeonACU.Dead then
                ScenarioFramework.Dialogue(OpStrings.M2AeonACUKilled)
            else
                ScenarioFramework.Dialogue(OpStrings.M2AeonsACUKilled)
            end
        end
    )
    ScenarioInfo.M2S2:AddResultCallback(
        function(result)
            if result then
                ScenarioFramework.Dialogue(OpStrings.M2AeonCommandersKilled, M2KillAeonBase)
            end
        end
    )
end

function M2KillAeonBase()
    for _, unit in ArmyBrains[Aeon]:GetListOfUnits(categories.ALLUNITS - categories.WALL, false) do
        if unit and not unit.Dead then
            unit:Kill()
            WaitSeconds(Random(0.2, 0.5))
        end
    end
end

function M2MissileShipSpotted()
    if ScenarioInfo.UseCybranAI and not ScenarioInfo.CybranACU.Dead then
        ScenarioFramework.Dialogue(OpStrings.M2MissileShipSpotted1)
    else
        ScenarioFramework.Dialogue(OpStrings.M2MissileShipSpotted2)
    end

    -- Assign it while the dialogue plays in case the players are sniping it fast.
    M2MissileShipBonusObjective()
end

function M2MissileShipBonusObjective()
    if ScenarioInfo.M2MissileShip.Dead then
        WARN('Something went wrong. The missile ship is already dead.')
        return
    end

    ------------------------------------------
    -- Bonus Objective - Kill the Missile Ship
    ------------------------------------------
    ScenarioInfo.M2B2 = Objectives.Kill(
        'bonus',
        'incomplete',
        OpStrings.M2B2Title,
        OpStrings.M2B2Description,
        {
            MarkUnits = false,
            Hidden = true,
            Units = {ScenarioInfo.M2MissileShip},
        }
    )
    ScenarioInfo.M2B2:AddResultCallback(
        function(result)
            if result then
                if ScenarioInfo.UseCybranAI and not ScenarioInfo.CybranACU.Dead then
                    ScenarioFramework.Dialogue(OpStrings.M2MissileShipKilled1)
                else
                    ScenarioFramework.Dialogue(OpStrings.M2MissileShipKilled2)
                end
            end
        end
    )
end

function M2Dialog1()
    if ScenarioInfo.M1P2.Active then
        ScenarioFramework.Dialogue(OpStrings.M2Dialog1, nil, true)
    end
end

function M2UEFDrops()
    if ScenarioInfo.M2Atlantis and not ScenarioInfo.M2Atlantis.Dead then
        local i = Random(1, 2)
        local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M2_UEF_Drop_1_D' .. Difficulty, 'GrowthFormation')
        local units = DropThread(platoon:GetPlatoonUnits(), 'M2_UEF_Drop_Marker_' .. i, 'M2_UEF_Drop_Delete_Marker', false, 'M2_UEF_Drop_Move_Chain_' .. i)
        ScenarioFramework.GroupPatrolChain(units, 'M2_UEF_Drop_Attack_Chain_' .. i)

        ScenarioFramework.CreateTimerTrigger(M2UEFDrops, 300)
    end
end

function M2StartEvacuation()
    ScenarioFramework.Dialogue(OpStrings.M2CiviliansReady, M2SpawnTrucks, true)
end

function M2SpawnTrucks()
    ScenarioInfo.M2Trucks = {}

    for i = 1, 11 do
        -- Two trucks from the last building
        if i == 11 then
            if not ScenarioInfo.UnitNames[Civilians]['Building_' .. i].Dead then
                local truck = ScenarioUtils.CreateArmyUnit('Cybran', 'Truck_' .. i)
                table.insert(ScenarioInfo.M2Trucks, truck)
                truck = ScenarioUtils.CreateArmyUnit('Cybran', 'Truck_' .. i + 1)
                table.insert(ScenarioInfo.M2Trucks, truck)
            end
        else
            if not ScenarioInfo.UnitNames[Civilians]['Building_' .. i].Dead then
                local truck = ScenarioUtils.CreateArmyUnit('Cybran', 'Truck_' .. i)
                table.insert(ScenarioInfo.M2Trucks, truck)
            end
        end
    end

    M2ProtectTrucksObjective()
end

function M2ProtectTrucksObjective()
    -- Finish the objective to protect the city
    ScenarioInfo.M1P2:ManualResult(true)

    -------------------------------------
    -- Primary Objective - Protect Trucks
    -------------------------------------
    local required = math.max(math.ceil(table.getn(ScenarioInfo.M2Trucks) / 2), 6)
    ScenarioInfo.M2P3 = Objectives.Protect(
        'primary',
        'incomplete',
        OpStrings.M2P3Title,
        LOCF(OpStrings.M2P3Description, required),
        {
            Units = ScenarioInfo.M2Trucks,
            NumRequired = required,
            ShowProgress = true,

        }
    )
    ScenarioInfo.M2P3:AddResultCallback(
        function(result)
            if result then
                ScenarioFramework.Dialogue(OpStrings.M2TrucksEvacuated, PlayerWin, true)
            else
                PlayerLose()
            end
        end
    )

    if ScenarioInfo.M1B2.Active then
        ScenarioInfo.M1B2:ManualResult(true)

        ----------------------------------
        -- Bonus Objective - No truck dies
        ----------------------------------
        ScenarioInfo.M2B3 = Objectives.Protect(
            'bonus',
            'incomplete',
            OpStrings.M2B3Title,
            OpStrings.M2B3Description,
            {
                Units = ScenarioInfo.M2Trucks,
                Hidden = true,
                MarkUnits = false,
            }
        )
    end

    -- Transport out the trucks, if the Aeon base is destroyed, send the transports right away
    if ScenarioInfo.M2S2 and ScenarioInfo.M2S2.Active then
        ScenarioFramework.CreateTimerTrigger(M2TransportEvacuationThread, 60) -- TODO: some better time with some uef attack
    else
        M2TransportEvacuationThread()
    end
end

function M2TransportEvacuationThread()
    local transportPlatoon = ArmyBrains[Cybran]:MakePlatoon('', '')

    local numTrucks = 0
    for _, truck in ScenarioInfo.M2Trucks do
        if truck and not truck.Dead then
            numTrucks = numTrucks + 1
        end
    end

    -- Spawn the transports
    local numTransportsRequired = math.ceil(numTrucks / 4)
    for i = 1, numTransportsRequired do
        local transport = ScenarioUtils.CreateArmyUnit('Cybran', 'Transport_' .. i)
        ArmyBrains[Cybran]:AssignUnitsToPlatoon(transportPlatoon, {transport}, 'Scout', 'GrowthFormation')
        -- Some inties to protect the transport
        local escort = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2_Transport_Escort', 'NoFormation')
        escort:GuardTarget(transport)
    end

    -- Move around the sea
    transportPlatoon:MoveToLocation(ScenarioUtils.MarkerToPosition('M2_Transport_Route_Marker'), false, 'Scout')

    local transports = transportPlatoon:GetPlatoonUnits()
    local group = {}
    local i = 1
    for j, truck in ScenarioInfo.M2Trucks do
        if truck and not truck.Dead then
            table.insert(group, truck)
            if table.getn(group) == 4 or j == numTrucks then
                IssueTransportLoad(group, transports[i])
                group = {}
                i = i + 1
            end
        end
    end

    -- Take the same path back
    transportPlatoon:MoveToLocation(ScenarioUtils.MarkerToPosition('M2_Transport_Route_Marker'), false, 'Scout')

    transportPlatoon:MoveToLocation(ScenarioUtils.MarkerToPosition('M2_Transport_Destination'), false, 'Scout')

    for _, transport in transportPlatoon:GetPlatoonUnits() do
        ScenarioFramework.CreateUnitToMarkerDistanceTrigger(M2CiviliandsEvacuated, transport, 'M2_Transport_Destination', 20)
    end
end

function M2CiviliandsEvacuated()
    if ScenarioInfo.M2CiviliandsEvacuated then
        return
    end

    ScenarioInfo.M2CiviliandsEvacuated = true

    if ScenarioInfo.M2B3 and ScenarioInfo.M2B3.Active then
        ScenarioInfo.M2B3:ManualResult(true)
    end

    if ScenarioInfo.M2P3.Active then
        ScenarioInfo.M2P3:ManualResult(true)
    end
end

------------
-- Reminders
------------
function M1P1Reminder1()
    -- Fail the quick strike objective 
    if ScenarioInfo.M1B1.Active then
        ScenarioInfo.M1B1:ManualResult(false)
    end

    -- Play the dialogue and set up a new one
    if ScenarioInfo.M1P1.Active then
        ScenarioFramework.Dialogue(OpStrings.M1P1Reminder1)

        ScenarioFramework.CreateTimerTrigger(M1P1Reminder2, 5*10)
    end
end

function M1P1Reminder2()
    if ScenarioInfo.M2P1.Active then
        ScenarioFramework.Dialogue(OpStrings.M1P1Reminder2)
    end
end

function M2P1Reminder()
    if ScenarioInfo.M2P1.Active then
        ScenarioFramework.Dialogue(OpStrings.M2LocateReminder)
    end
end

function M2P2Reminder1()
    if ScenarioInfo.M2P2.Active then
        ScenarioFramework.Dialogue(OpStrings.M2KillReminder1)

        ScenarioFramework.CreateTimerTrigger(M2P2Reminder2, 20*60)
    end
end

function M2P2Reminder2()
    if ScenarioInfo.M2P2.Active then
        ScenarioFramework.Dialogue(OpStrings.M2KillReminder2)
    end
end

---------
-- Taunts
---------
function SetupUEFM1Taunts()
    -- UEF taunt, when Player1 is spotted
    UEFTM:AddIntelCategoryTaunt('M1UEFDialogue', ArmyBrains[UEF], ArmyBrains[Player1], categories.ALLUNITS)

    -- Player's ACU is given from the AI after it's dropped, so gotta wait for it to actually exist
    while not ScenarioInfo.Player1ACU do
        WaitSeconds(1)
    end
    
    -- When player's ACU takes damage
    UEFTM:AddDamageTaunt('TAUNT1', ScenarioInfo.Player1ACU, 0.2)

    -- On losing first defensive structures
    UEFTM:AddUnitsKilledTaunt('TAUNT2', ArmyBrains[UEF], categories.STRUCTURE * categories.DEFENSE, 1)
    -- On losing factories
    UEFTM:AddUnitsKilledTaunt('TAUNT4', ArmyBrains[UEF], categories.STRUCTURE * categories.FACTORY, 3)
    -- On destroying enemy units
    UEFTM:AddEnemiesKilledTaunt('TAUNT6', ArmyBrains[UEF], categories.MOBILE, 100)
end

function SetupUEFM2Taunts()
    -- On destroying enemy ships
    UEFTM:AddEnemiesKilledTaunt('TAUNT14', ArmyBrains[UEF], categories.NAVAL * categories.MOBILE, 30)
    -- On destroying enemy air units
    UEFTM:AddEnemiesKilledTaunt('TAUNT15', ArmyBrains[UEF], categories.AIR * categories.MOBILE, 100)
    -- On losing structures
    UEFTM:AddUnitsKilledTaunt('TAUNT16', ArmyBrains[UEF], categories.STRUCTURE, 6)
    -- On losing naval units
    UEFTM:AddUnitsKilledTaunt('TAUNT17', ArmyBrains[UEF], categories.NAVAL * categories.MOBILE * categories.TECH2, 25)
    -- On destroying enemy structures
    UEFTM:AddEnemiesKilledTaunt('TAUNT18', ArmyBrains[UEF], categories.STRUCTURE, 10)
end

function SetupAeonM2Taunts()
    AeonTM:AddTauntingCharacter(ScenarioInfo.AeonACU)

    -- Player ACU is at 50% health
    AeonTM:AddDamageTaunt('TAUNT7', ScenarioInfo.Player1ACU, 0.5)
    -- On destroying enemy T2 ships
    AeonTM:AddEnemiesKilledTaunt('TAUNT8', ArmyBrains[Aeon], categories.NAVAL * categories.MOBILE * categories.TECH2, 20)
    -- On destroying enemy T2 land units
    AeonTM:AddEnemiesKilledTaunt('TAUNT9', ArmyBrains[Aeon], categories.LAND * categories.MOBILE * categories.TECH2, 50)
    -- On losing structures
    AeonTM:AddUnitsKilledTaunt('TAUNT10', ArmyBrains[Aeon], categories.STRUCTURE - categories.WALL, 8)
    -- Damaging Cora's ACU
    AeonTM:AddDamageTaunt('TAUNT11', ScenarioInfo.AeonACU, 0.01)
    -- On losing ships
    AeonTM:AddUnitsKilledTaunt('TAUNT12', ArmyBrains[Aeon], categories.NAVAL * categories.MOBILE * categories.TECH2, 30)
    -- On losing naval factory
    AeonTM:AddUnitsKilledTaunt('TAUNT12', ArmyBrains[Aeon], categories.NAVAL * categories.FACTORY, 1)
end

-----------------
-- Misc Functions
-----------------
function DestroyUnit(unit)
    unit:Destroy()
end

------------------
-- Debug Functions
------------------
function OnCtrlF3()
    ForkThread(CybranDropThread)
end

function OnShiftF3()
end

function OnCtrlF4()
    if ScenarioInfo.MissionNumber == 1 then
        for _, v in ArmyBrains[UEF]:GetListOfUnits(categories.ALLUNITS - categories.WALL, false) do
            v:Kill()
        end
    end
end

function OnShiftF4()
    ScenarioFramework.CreateTimerTrigger(M2UEFDrops, 5)
end
