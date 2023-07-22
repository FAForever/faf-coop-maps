-- ****************************************************************************
-- **
-- **  File     :  /maps/SCCA_Coop_A02/SCCA_Coop_A02_script.lua
-- **  Author(s):  David Tomandl
-- **
-- **  Summary  :  This is the main file in control of the events during
-- **              operation A2.
-- **
-- **  Copyright © 2006 Gas Powered Games, Inc.  All rights reserved.
-- ****************************************************************************
local M2CybranAI = import('/maps/SCCA_Coop_A02/SCCA_Coop_A02_m2cybranai.lua')
local M3CybranAI = import('/maps/SCCA_Coop_A02/SCCA_Coop_A02_m3cybranai.lua')
local Objectives = import('/lua/SimObjectives.lua')
local OpStrings = import ('/maps/SCCA_Coop_A02/SCCA_Coop_A02_strings.lua')
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioStrings = import('/lua/ScenarioStrings.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local Weather = import('/lua/weather.lua')

----------
-- Globals
----------
ScenarioInfo.Player1 = 1
ScenarioInfo.Cybran = 2
ScenarioInfo.NeutralCybran = 3
ScenarioInfo.Player2 = 4
ScenarioInfo.Player3 = 5
ScenarioInfo.Player4 = 6

---------
-- Locals
---------
local Player1 = ScenarioInfo.Player1
local Player2 = ScenarioInfo.Player2
local Player3 = ScenarioInfo.Player3
local Player4 = ScenarioInfo.Player4
local Cybran = ScenarioInfo.Cybran
local NeutralCybran = ScenarioInfo.NeutralCybran

local Difficulty = ScenarioInfo.Options.Difficulty
local AssignedObjectives = {}

local M1ReoccurringAttackDelay = {8*60, 6*60, 4*60}

local LeaderFaction
local LocalFaction

-----------
-- Start up
-----------
function OnPopulate(scenario)
    ScenarioUtils.InitializeScenarioArmies()
    LeaderFaction, LocalFaction = ScenarioFramework.GetLeaderAndLocalFactions()

    Weather.CreateWeather()

    ---------
    -- Cybran
    ---------
    -- Spawn the groups that will attack the player during M1
    ScenarioInfo.M1Attackers = ScenarioUtils.CreateArmyGroup('Cybran', 'M1_Attackers_D' .. Difficulty)
    ScenarioInfo.M1EarlyAttackers1 = ScenarioUtils.CreateArmyGroup('Cybran', 'M1_First_Attack_D' .. Difficulty)
    ScenarioInfo.M1EarlyAttackers2 = ScenarioUtils.CreateArmyGroup('Cybran', 'M1_Second_Attack_D' .. Difficulty)

    -- Mexes for secondary objective
    ScenarioInfo.Extractor1 = ScenarioUtils.CreateArmyUnit('Cybran', 'Extractor1')
    ScenarioInfo.Extractor2 = ScenarioUtils.CreateArmyUnit('Cybran', 'Extractor2')

    ScenarioUtils.CreateArmyUnit('Cybran', 'Hydro1')
    ScenarioUtils.CreateArmyUnit('Cybran', 'Energy_Storage')

    -- Static defences + T1 arty
    ScenarioUtils.CreateArmyGroup('Cybran', 'M1_Defences_D' .. Difficulty)

    -- Land T2 patrol around the city
    local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M1_Patrol_D' .. Difficulty, 'NoFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M1_Land_Defence_Chain')

    ----------------------
    -- Objective buildings
    ----------------------
    -- Spawn the city that the player needs to cleanse
    ScenarioInfo.M1City = ScenarioUtils.CreateArmyGroup('Cybran', 'M1_City')

    -- If player captures the city, make sure Cybran units won't fire at it
    for _, unit in ScenarioInfo.M1City do
        ScenarioFramework.CreateUnitCapturedTrigger(nil, UnitSetDoNotTarget, unit)
    end
end

function OnStart(self)
    -- Unit and upgade restrictions
    ScenarioFramework.AddRestrictionForAllHumans(
        categories.TECH2 +
        categories.TECH3 +
        categories.EXPERIMENTAL +
        categories.PRODUCTFA + -- All FA Units
        categories.uaa0107     -- T1 transport
    )

    ScenarioFramework.RestrictEnhancements({
        'AdvancedEngineering',
        'ResourceAllocation',
        'T3Engineering',
        'ResourceAllocationAdvanced',
        'Shield',
        'ShieldHeavy',
        'Teleporter',
    })

    -- Colors
    ScenarioFramework.SetCybranColor(Cybran)
    ScenarioFramework.SetNeutralColor(NeutralCybran) -- SetCybranNeutralColor
    ScenarioFramework.SetAeonColor(Player1)
    local colors = {
        ['Player2'] = {47, 79, 79},
        ['Player3'] = {46, 139, 87},
        ['Player4'] = {102, 255, 204}
    }
    local tblArmy = ListArmies()
    for army, color in colors do
        if tblArmy[ScenarioInfo[army]] then
            ScenarioFramework.SetArmyColor(ScenarioInfo[army], unpack(color))
        end
    end

    -- Set the maximum number of units that the players is allowed to have
    ScenarioFramework.SetSharedUnitCap(420)

    -- Set playable area
    ScenarioFramework.SetPlayableArea('M1_Playable_Area', false)

    -- Zoom to starting position and then spawn players
    ScenarioFramework.StartOperationJessZoom('Start_Camera_Area', IntroMission1)
end

-----------
-- End Game
-----------
function PlayerWin()
    if not ScenarioInfo.OpEnded then
        -- Turn everything neutral; protect the player commander
        ScenarioFramework.EndOperationSafety()

        ScenarioInfo.OpComplete = true

        -- Celebration dialogue
        ScenarioFramework.Dialogue(OpStrings.A02_M03_100, KillGame, true)
    end
end

function PlayerCommanderDied(commander)
    ScenarioFramework.PlayerDeath(commander, OpStrings.A02_D01_010)
end

function KillGame()
    local bonus = Objectives.IsComplete(ScenarioInfo.M1B1Objective) and Objectives.IsComplete(ScenarioInfo.M1B2Objective) and Objectives.IsComplete(ScenarioInfo.M2B2Objective)
    local secondary = Objectives.IsComplete(ScenarioInfo.M1S1Objective) and Objectives.IsComplete(ScenarioInfo.M2S1Objective) and Objectives.IsComplete(ScenarioInfo.M3S1Objective)
    ScenarioFramework.EndOperation(ScenarioInfo.OpComplete, ScenarioInfo.OpComplete, secondary, bonus)
end

------------
-- Mission 1
------------
function IntroMission1()
    ScenarioInfo.MissionNumber = 1

    -- Spawn Players
    local tblArmy = ListArmies()
    local i = 1
    while tblArmy[ScenarioInfo['Player' .. i]] do
        ScenarioInfo['Player' .. i .. 'CDR'] = ScenarioFramework.SpawnCommander('Player' .. i, 'Commander', 'Warp', true, true, PlayerCommanderDied)
        WaitSeconds(2)
        i = i + 1
    end

    ScenarioFramework.Dialogue(OpStrings.A02_M01_010, StartMission1, true)
end

function StartMission1()
    -------------------------------------------
    -- Primary Objective 1 - Clease Cybran City
    -------------------------------------------
    ScenarioInfo.M1P1Objective = Objectives.KillOrCapture(
        'primary',
        'incomplete',
        OpStrings.M1P1Text,
        LOCF(OpStrings.M1P1Detail, 80),
        {
            Units = ScenarioInfo.M1City,
            PercentProgress = true,
            PercentRequired = 80,
        }
    )
    ScenarioInfo.M1P1Objective:AddResultCallback(
        function(result)
            if result then
                ScenarioFramework.Dialogue(OpStrings.A02_M01_060, IntroMission2, true)
                -- new catalon destroyed
                local citymarker = ScenarioUtils.MarkerToPosition("M1_New_Catalon")
                local camInfo = {
                    blendTime = 1.0,
                    holdTime = 5,
                    orientationOffset = { -2.4, 0.3, 0 },
                    positionOffset = { 0, 0, 0 },
                    zoomVal = 25,
                    markerCam = true,
                }
                ScenarioFramework.OperationNISCamera(citymarker, camInfo)
            end
        end
    )

    ----------------------------------------------
    -- Secondary Objective 1 - Capture Enemy Mexes
    ----------------------------------------------
    ScenarioInfo.M1S1Objective = Objectives.Capture(
        'secondary',
        'incomplete',
        OpStrings.M1S1Text,
        OpStrings.M1S1Detail,
        {
            Units = {ScenarioInfo.Extractor1, ScenarioInfo.Extractor2},
        }
    )
    --[[ -- TODO: The dialogue says "captured pgens" isntead of mexes
    ScenarioInfo.M1S1Objective:AddResultCallback(
        function(result)
            if result then
                ScenarioFramework.Dialogue(OpStrings.A02_M01_020)
            end
        end
    )
    --]]
    --------------------------------------------------
    -- Bonus Objective 1 - Build All Hydros on the map
    --------------------------------------------------
    ScenarioInfo.M1B1Objective = Objectives.ArmyStatCompare(
        'bonus',
        'incomplete',
        OpStrings.M1B1Text,
        OpStrings.M1B1Detail,
        'build',
        {
            Armies = {'HumanPlayers'},
            StatName = 'Units_Active',
            CompareOp = '>=',
            Value = 13,
            Category = categories.uab1102 + categories.urb1102,
            Hidden = true,
        }
    )

    ----------------------------------
    -- Bonus Objective - Build Auroras
    ----------------------------------
    num = {200, 300, 400}
    ScenarioInfo.M1B2Objective = Objectives.ArmyStatCompare(
        'bonus',
        'incomplete',
        OpStrings.M1B2Text,
        LOCF(OpStrings.M1B2Detail, num[Difficulty]),
        'build',
        {
            Armies = {'HumanPlayers'},
            StatName = 'Units_History',
            CompareOp = '>=',
            Value = num[Difficulty],
            Category = categories.ual0201,
            Hidden = true,
        }
    )

    ForkThread(EnableScoutsCloackThread)

    -- Reminder
    ScenarioFramework.CreateTimerTrigger(M1P1Reminder, 900)

    -- Set a scout to fly over the player's base after a delay
    ScenarioFramework.CreateTimerTrigger(M1ScoutPlayer, 30)

    ScenarioFramework.CreateTimerTrigger(M1EarlyAttack1, 60)
    ScenarioFramework.CreateTimerTrigger(M1EarlyAttack2, 90)

    -- Set the 'retaliation attack' to launch after a delay
    ScenarioFramework.CreateTimerTrigger(M1AttackPlayer, 180)
end

function M1EarlyAttack1()
    for k, PatrolPoint in ScenarioUtils.ChainToPositions('M1_Attack_Route' .. Random(1, 3)) do
        IssuePatrol(ScenarioInfo.M1EarlyAttackers1, PatrolPoint)
    end
end

function M1EarlyAttack2()
    for k, PatrolPoint in ScenarioUtils.ChainToPositions('M1_Attack_Route' .. Random(1, 3)) do
        IssuePatrol(ScenarioInfo.M1EarlyAttackers2, PatrolPoint)
    end
end

-- Primary Objective - Kill Attackers
function M1AttackPlayer()
    for _, unit in ScenarioInfo.M1Attackers do
        ScenarioFramework.GroupPatrolChain({unit}, 'M1_Attack_Route' .. Random(1, 3))
    end

    -- Tell the player that it's coming
    ScenarioFramework.Dialogue(OpStrings.A02_M01_030, nil, true)

    -----------------------------------------
    -- Primary Objective 2 - Defeat Attackers
    -----------------------------------------
    ScenarioInfo.M1P2Objective = Objectives.KillOrCapture(
        'primary',
        'incomplete',
        OpStrings.M1P2Text,
        OpStrings.M1P2Detail,
        {
            Units = ScenarioInfo.M1Attackers,
            MarkUnits = false,
            ShowProgress = false,
        }
    )
    ScenarioInfo.M1P2Objective:AddResultCallback(
        function(result)
            if result then
                ScenarioFramework.Dialogue(OpStrings.A02_M01_040, nil, true)
            end
        end
    )

    -- Kick off the reoccurring attacks
    ScenarioFramework.CreateTimerTrigger(M1ReoccurringAttack, M1ReoccurringAttackDelay[Difficulty])
end

function M1ScoutPlayer()
    local scout = ScenarioUtils.CreateArmyUnit('Cybran', 'M1Scout')
    for k, PatrolPoint in ScenarioUtils.ChainToPositions('M1_Attack_Route' .. Random(1, 3)) do
        IssuePatrol({ scout }, PatrolPoint)
    end

    WaitSeconds(7)
    -- Send a second one, just to make more of an impact
    scout = ScenarioUtils.CreateArmyUnit('Cybran', 'M1Scout')
    for k, PatrolPoint in ScenarioUtils.ChainToPositions('M1_Attack_Route' .. Random(1, 3)) do
        IssuePatrol({ scout }, PatrolPoint)
    end

    -- Adding land scouts so that the player is encouraged to build anti-ground defenses
    WaitSeconds(30)
    scout = ScenarioUtils.CreateArmyUnit('Cybran', 'M1ScoutLand')
    for k, PatrolPoint in ScenarioUtils.ChainToPositions('M1_Attack_Route' .. Random(1, 3)) do
        IssuePatrol({ scout }, PatrolPoint)
    end

    WaitSeconds(7)
    scout = ScenarioUtils.CreateArmyUnit('Cybran', 'M1ScoutLand')
    for k, PatrolPoint in ScenarioUtils.ChainToPositions('M1_Attack_Route' .. Random(1, 3)) do
        IssuePatrol({ scout }, PatrolPoint)
    end
end

function M1ReoccurringAttack()
    if ScenarioInfo.MissionNumber <= 2 then
        local GroundUnits = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M1_Reoccurring_Ground_D' .. Difficulty, 'AttackFormation')
        local AirUnits = ScenarioUtils.CreateArmyGroup('Cybran', 'M1_Reoccurring_Air_D' .. Difficulty)

        ForkThread(TransportAssault, GroundUnits, 'M1_Landing_Zone', 'M1_Attack_Route' .. Random(1, 3), AirUnits)

        ScenarioFramework.CreateTimerTrigger(M1ReoccurringAttack, M1ReoccurringAttackDelay[Difficulty])
    end
end

------------
-- Mission 2
------------
function IntroMission2()
    if ScenarioInfo.MissionNumber ~= 1 then
        return
    end
    ScenarioInfo.MissionNumber = 2

    ------------
    -- Cybran AI
    ------------
    M2CybranAI.CybranM2NorthBaseAI()
    M2CybranAI.CybranM2SouthBaseAI()

    ArmyBrains[Cybran]:PBMSetCheckInterval(8)

    -- No T2 navy capturing for player
    ScenarioInfo.SouthNavalFactory = ScenarioInfo.UnitNames[Cybran]['South_Naval_Factory']
    ScenarioInfo.SouthNavalFactory:SetCapturable(false)

    -- Tag every fifth unit; if the player sees that unit, they will have "spotted the secret base"
    for _, unit in ScenarioFramework.GetCatUnitsInArea(categories.CYBRAN * categories.STRUCTURE, 'M2_South_Base_Area', ArmyBrains[Cybran]) do
        ScenarioFramework.CreateArmyIntelTrigger(M2SecretBaseSpotted, ArmyBrains[Player1], 'LOSNow', unit, true, categories.ALLUNITS, true, ArmyBrains[Cybran])
    end

    -- Patrols
    -- North naval
    local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2_Initial_North_Patrol_D' .. Difficulty, 'AttackFormation')
    for _, unit in platoon:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolChain({unit}, 'M2_North_Water_Patrol')
    end

    -- West naval
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2_Initial_West_Patrol_D' .. Difficulty, 'NoFormation')
    for _, unit in platoon:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolChain({unit}, 'M2_North_West_Naval_Patrol')
    end

    -- South naval, rebuild if destroyed
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2_Initial_South_Patrol_D' .. Difficulty, 'AttackFormation')
    for _, unit in platoon:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolChain({unit}, 'M2_South_Water_Patrol')
    end
    platoon:AddDestroyCallback(M2CybranAI.SouthNavalPatrolRebuild)

    -- East patrol reiforces south base if needed, when destroyed it's rebuild by north base
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2_Initial_East_Patrol_D' .. Difficulty, 'AttackFormation')
    platoon:ForkAIThread(NavalPatrolReinforceAI)
    platoon:AddDestroyCallback(M2CybranAI.EastNavalPatrolRebuild)

    ScenarioInfo.M2_South_Attackers = ScenarioUtils.CreateArmyGroup('Cybran', 'M2_Initial_South_Attackers_D' .. Difficulty)
    ScenarioFramework.GroupPatrolChain(ScenarioInfo.M2_South_Attackers, 'M2_South_Water_Patrol')

    -- Attack
    for i = 1, 3 do
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2_Initial_Bombers_D' .. Difficulty, 'AttackFormation')
        ScenarioFramework.PlatoonPatrolChain(platoon, 'M1_Attack_Route' .. i)

        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2_Initial_Inerceptors_D' .. Difficulty, 'AttackFormation')
        ScenarioFramework.PlatoonPatrolChain(platoon, 'M1_Attack_Route' .. i)
    end

    ----------------
    -- Civilian City
    ----------------
    ScenarioInfo.M2City = ScenarioUtils.CreateArmyGroup('NeutralCybran', 'M2_City')

    -- If player captures the city, make Cybran units won't fire at it
    for _, unit in ScenarioInfo.M2City do
        ScenarioFramework.CreateUnitCapturedTrigger(nil, UnitSetDoNotTarget, unit)
    end

    -- Update the playable area
    ScenarioFramework.SetPlayableArea('M2_Playable_Area', true)

    ScenarioFramework.Dialogue(OpStrings.A02_M02_010, StartMission2, true)
end

function NavalPatrolReinforceAI(platoon)
    local aiBrain = platoon:GetBrain()
    local data = platoon.PlatoonData

    if not data[1] then
        data = {
            PatrolChain = 'M2_East_Water_Patrol',
            Area = 'M2_South_Defenses',
            Location = 'M2_South_Water_Patrol_04',
        }
    end

    if not data.PatrolChain then
        error('*SCENARIO PLATOON AI ERROR: NavalPatrolReinforceAI requires PatrolChain in PlatoonData to operate', 2)
    elseif not data.Area then
        error('*SCENARIO PLATOON AI ERROR: NavalPatrolReinforceAI requires Area in PlatoonData to operate', 2)
    elseif not data.Location then
        error('*SCENARIO PLATOON AI ERROR: NavalPatrolReinforceAI requires Location in PlatoonData to operate', 2)
    end

    platoon:Stop()
    if not data.FormationPatrol then
        for _, unit in platoon:GetPlatoonUnits() do
            ScenarioFramework.GroupPatrolChain({unit}, data.PatrolChain)
        end
    else
        ScenarioFramework.PlatoonPatrolRoute(platoon, data.PatrolChain)
    end

    while aiBrain:PlatoonExists(platoon) do
        local entities = GetUnitsInRect(ScenarioUtils.AreaToRect(data.Area))

        if entities then
            local filteredList = EntityCategoryFilterDown(categories.NAVAL * categories.MOBILE, entities)
            local ownUnits = 0
            local enemyUnits = 0

            for _, v in filteredList do
                if v:GetAIBrain() == aiBrain then
                    ownUnits = ownUnits + 1
                else
                    enemyUnits = enemyUnits + 1
                end
            end

            -- Reinforce the position if we have low num of units in the area
            if enemyUnits > ownUnits then
                platoon:Stop()
                local cmd = platoon:AggressiveMoveToLocation(ScenarioUtils.MarkerToPosition(data.Location))

                while platoon:IsCommandsActive(cmd) do
                    WaitSeconds(10)
                    if not aiBrain:PlatoonExists(platoon) then
                        return
                    end
                end

                -- Go back to potrolling if we still exist
                platoon:Stop()
                if not data.FormationPatrol then
                    for _, unit in platoon:GetPlatoonUnits() do
                        ScenarioFramework.GroupPatrolChain({unit}, data.PatrolChain)
                    end
                else
                    ScenarioFramework.PlatoonPatrolRoute(platoon, data.PatrolChain)
                end
            end
        end
        WaitSeconds(13)
    end
end

function StartMission2()
    -- Unit cap
    ScenarioFramework.SetSharedUnitCap(660)

    ScenarioFramework.RemoveRestrictionForAllHumans(
        categories.uab0202 + -- T2 Air Factory
        categories.zab9502 + -- T2 Support Air Factory
        categories.uaa0107 + -- T1 Transport
        categories.uaa0204,  -- Torpedo Bomber
        true
    )

    ScenarioInfo.M2ObjectiveGroup = Objectives.CreateGroup('Mission 2 Objectives', EndMission2, 2)

    ------------------------------------------
    -- Bonus Objective 2 - Capture Cybran City
    ------------------------------------------
    ScenarioInfo.M2B2Objective = Objectives.Capture(
        'bonus',
        'incomplete',
        OpStrings.M2B2Text,
        OpStrings.M2B2Detail,
        {
            Units = ScenarioInfo.M2City,
            MarkUnits = false,
            -- NumRequired = math.ceil(table.getn(ScenarioInfo.M2City) * 0.8),
            Hidden = true,
        }
    )

    -------------------------------------------
    -- Primary Objective 3 - Destroy North Base
    -------------------------------------------
    ScenarioInfo.M2P1Objective = Objectives.CategoriesInArea(
        'primary',
        'incomplete',
        OpStrings.M2P1Text,
        OpStrings.M2P1Detail,
        'Kill',
        {
            MarkArea = false,
            ShowFaction = 'Cybran',
            Requirements = {
                {
                    Area = 'M2_North_Base_Area',
                    ArmyIndex = Cybran,
                    Category = (categories.CYBRAN * categories.STRUCTURE) - categories.WALL,
                    CompareOp = '==',
                    Value = 0,
                },
            },
        }
    )
    ScenarioInfo.M2ObjectiveGroup:AddObjective(ScenarioInfo.M2P1Objective)

    ScenarioFramework.CreateTimerTrigger(M2ProtectCivilians, 10)
    ScenarioFramework.CreateTimerTrigger(M2Dialog1, 480) -- Use torp bombers and transports

    -- If the player doesn't see the SouthEast base, after a certain amount of time it is revealed anyway
    ScenarioFramework.CreateTimerTrigger(M2SecretBaseTimeout, 300)

    -- If the player doesn't complete the objective soon, remind him that it's important
    ScenarioFramework.CreateTimerTrigger(M2P1Reminder, 900)
end

function M2ProtectCivilians()
    local function AddObjective()
        local M2CityBuildingsPercentageMustSurvive = 80
        ----------------------------------------------
        -- Primary Objective 4 - Protect Civilian City
        ----------------------------------------------
        ScenarioInfo.M2P2Objective = Objectives.Protect(
            'primary',
            'incomplete',
            OpStrings.M2P2Text,
            LOCF(OpStrings.M2P2Detail, M2CityBuildingsPercentageMustSurvive),
            {
                Units = ScenarioInfo.M2City,
                MarkUnits = true,
                PercentProgress = true,
                NumRequired = math.ceil(table.getn(ScenarioInfo.M2City) * (M2CityBuildingsPercentageMustSurvive / 100)),
            }
        )
        ScenarioInfo.M2P2Objective:AddResultCallback(
            function(result)
                if not result and ScenarioInfo.MissionNumber == 2 then
                    -- Let the player know what happened (too many buildings lost) and end the game
                    ScenarioFramework.Dialogue(OpStrings.A02_M02_150, ScenarioFramework.PlayerLose, true)
                end
            end
        )
        ScenarioInfo.M2ObjectiveGroup:AddObjective(ScenarioInfo.M2P2Objective)
    end

    ScenarioFramework.Dialogue(OpStrings.A02_M02_020, AddObjective, true)
end

function M2Dialog1()
    if ScenarioInfo.MissionNumber == 2 then
        ScenarioFramework.Dialogue(OpStrings.A02_M02_030)
    end
end

-- South Base
function M2SecretBaseSpotted()
    if not ScenarioInfo.SecretBaseRevealed then
        ScenarioInfo.SecretBaseRevealed = true
        ScenarioFramework.Dialogue(OpStrings.A02_M02_040, nil, true)
        ScenarioFramework.CreateTimerTrigger(M2AssignSecretBaseObjective, 20)
    end
end

function M2SecretBaseTimeout()
    if not ScenarioInfo.SecretBaseRevealed then
        ScenarioInfo.SecretBaseRevealed = true
        ScenarioFramework.Dialogue(OpStrings.A02_M02_050, nil, true)
        ScenarioFramework.CreateTimerTrigger(M2AssignSecretBaseObjective, 20)
    end
end

function M2AssignSecretBaseObjective()
    ScenarioFramework.Dialogue(OpStrings.A02_M02_070, nil, true)

    -------------------------------------------
    -- Primary Objective 5 - Destroy South Base
    -------------------------------------------
    ScenarioInfo.M2P3Objective = Objectives.CategoriesInArea(
        'primary',
        'incomplete',
        OpStrings.M2P3Text,
        OpStrings.M2P3Detail,
        'Kill',
        {
            MarkArea = false,
            ShowFaction = 'Cybran',
            Requirements = {
                {
                  Area = 'M2_South_Base_Area',
                  ArmyIndex = Cybran,
                  Category = (categories.CYBRAN * categories.STRUCTURE) - categories.WALL,
                  CompareOp = '==',
                  Value = 0,
                },
            },
        }
    )
    ScenarioInfo.M2P3Objective:AddResultCallback(
        function(result)
            if result then
                ScenarioFramework.Dialogue(OpStrings.A02_M02_130)
            end
        end
    )
    --Sometimes this objective can trigger before the objective group is created since this is linked to when one of the naval base units is detected
    while not(ScenarioInfo.M2ObjectiveGroup) do
        WaitSeconds(1)
    end
    ScenarioInfo.M2ObjectiveGroup:AddObjective(ScenarioInfo.M2P3Objective)

    ScenarioFramework.CreateTimerTrigger(M2CruiserWarning, 60) -- the cruiser will launch soon -- kill it
    ScenarioFramework.CreateTimerTrigger(M2Taunt1, 4 * 60) -- a taunt from the Cybran
    ScenarioFramework.CreateTimerTrigger(M2Taunt2, 6 * 60) -- another taunt
    ScenarioFramework.CreateTimerTrigger(M2StartSecretBaseAttacks, 3 * 60)
end

function M2CruiserWarning()
    if not ScenarioInfo.SouthNavalFactory:IsDead() then
        ScenarioFramework.Dialogue(OpStrings.A02_M02_080, nil, true)

        -- Create the cruiser and start naval attacks
        M2CybranAI.CybranM2SouthBaseNavalAttacks()
        -------------------------------------------------------
        -- Secondary Objective 1 - Kill Cybran T2 Naval Factory
        -------------------------------------------------------
        ScenarioInfo.M2S1Objective = Objectives.Kill(
            'secondary',
            'incomplete',
            OpStrings.M2S1Text,
            OpStrings.M2S1Detail,
            {
                Units = {ScenarioInfo.SouthNavalFactory},
            }
        )

        ScenarioFramework.CreateArmyStatTrigger(M2CruiserBuilt, ArmyBrains[Cybran], 'M2CruiserBuilt',
            {{StatType = 'Units_Active', CompareType = 'GreaterThanOrEqual', Value = 1, Category = categories.urs0202}})
    end
end

function M2CruiserBuilt()
    if ScenarioInfo.M2S1Objective.Active then
        ScenarioInfo.M2S1Objective:ManualResult(false)
        -- Objectives.UpdateBasicObjective(ScenarioInfo.M2S1Objective, 'description', OpStrings.M2S1Fail)

        ScenarioFramework.Dialogue(OpStrings.A02_M02_090)
    end
end

function M2StartSecretBaseAttacks()
    if not ScenarioFramework.GroupDeathCheck(ScenarioInfo.M2_South_Attackers) then
        ScenarioFramework.Dialogue(OpStrings.A02_M02_060)

        -- Send units from patrol on attack, start producing units.
        ScenarioFramework.GroupPatrolChain(ScenarioInfo.M2_South_Attackers, 'M2_South_Naval_Attack')
    end
    M2CybranAI.CybranM2SouthBaseAirAttacks()
    M2CybranAI.CybranM2SouthBaseLandAttacks()
end

function M2CreateCruiserDeathTrigger(platoon, table)
    ForkThread(function()
        WaitSeconds(0.1)
        ScenarioInfo.Cruiser = ScenarioInfo.SouthNavalFactory.UnitBeingBuilt
        ScenarioFramework.CreateUnitDestroyedTrigger(M2CruiserDeath, ScenarioInfo.Cruiser)
    end)
end

function M2CruiserDeath()
    -- Make sure the cruiser will get built only once
    ArmyBrains[Cybran]:PBMRemoveBuilder('OSB_Child_M2_Cybran_Cruiser_Platoon_2-1_Cybran')
    if ScenarioInfo.M2S1Objective.Active then
        IssueClearCommands({ ScenarioInfo.SouthNavalFactory })
        -- Success!
        ScenarioInfo.M2S1Objective:ManualResult(true)
        ScenarioFramework.Dialogue(OpStrings.A02_M02_100)
    end
end

function EndMission2()
    ForkThread(IntroMission3)
    if(ScenarioInfo.M2P2Objective and ScenarioInfo.M2P2Objective.Active) then
        ScenarioInfo.M2P2Objective:ManualResult(true)
    end
end

------------
-- Mission 3
------------
function IntroMission3()
    if ScenarioInfo.MissionNumber ~= 2 then
        return
    end

    ScenarioInfo.MissionNumber = 3

    ------------
    -- Cybran AI
    ------------
    M3CybranAI.CybranM3WestBaseAI()
    M3CybranAI.CybranM3EastBaseAI()

    -- Cybran ACU, upgrades depending on difficulty
    local upgrades = {
        {'CoolingUpgrade'},
        {'CoolingUpgrade', 'StealthGenerator'},
        {'CoolingUpgrade', 'StealthGenerator', 'NaniteTorpedoTube'},
    }
    ScenarioInfo.CybranCommander = ScenarioFramework.SpawnCommander('Cybran', 'Commander', false, LOC '{i Leopard11}', true, false, upgrades[Difficulty])
    ScenarioInfo.CybranCommander:SetAutoOvercharge(true)
    ScenarioInfo.CybranCommander:AddBuildRestriction(categories.CYBRAN * categories.DEFENSE)

    -- Initial Attack
    ScenarioInfo.M3Attackers = {}

    -- Drops
    local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M3_Attackers_D' .. Difficulty, 'AttackFormation')
    for _, v in platoon:GetPlatoonUnits() do
        if not EntityCategoryContains(categories.TRANSPORTATION, v) then
            table.insert(ScenarioInfo.M3Attackers, v)
        end
    end
    ForkThread(TransportAssault, platoon, 'M2_Landing_Area1_03', 'M1_Attack_Route3')

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M1_Reoccurring_Ground_D' .. Difficulty, 'AttackFormation')
    for _, v in platoon:GetPlatoonUnits() do
        if not EntityCategoryContains(categories.TRANSPORTATION, v) then
            table.insert(ScenarioInfo.M3Attackers, v)
        end
    end
    local AirUnits = ScenarioUtils.CreateArmyGroup('Cybran', 'M1_Reoccurring_Air_D' .. Difficulty)
    for _, v in AirUnits do
        if not EntityCategoryContains(categories.TRANSPORTATION, v) then
            table.insert(ScenarioInfo.M3Attackers, v)
        end
    end
    ForkThread(TransportAssault, platoon, 'M1_Landing_Zone', 'M1_Attack_Route' .. Random(1, 2), AirUnits)

    -- Air
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M3_Air_Attack_D' .. Difficulty, 'NoFormation')
    for _, v in platoon:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolChain({v}, 'M1_Attack_Route' .. Random(1, 3))
        table.insert(ScenarioInfo.M3Attackers, v)
    end

    -- Naval
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M3_Naval_Attack_D' .. Difficulty, 'NoFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M2_North_Naval_Attack')

    -- Initial Patrols
    -- Air
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M3_Air_Patrol_West_D' .. Difficulty, 'NoFormation')
    for _, v in platoon:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M3_West_Air_Patrol')))
    end

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M3_Air_Patrol_East_D' .. Difficulty, 'NoFormation')
    for _, v in platoon:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M3_East_Air_Patrol')))
    end

    -- Naval
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M3_Naval_Patrol_West_D' .. Difficulty, 'NoFormation')
    for _, v in platoon:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolChain({v}, 'M3_West_Naval_Patrol')
    end

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M3_Naval_Patrol_East_D' .. Difficulty, 'NoFormation')
    for _, v in platoon:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolChain({v}, 'M3_East_Naval_Patrol')
    end

    -- Arty defences
    ScenarioUtils.CreateArmyGroup('Cybran', 'Artillery_Defenses_D' .. Difficulty)

    ------------------
    -- Objective Units
    ------------------
    ScenarioInfo.Artillery = ScenarioUtils.CreateArmyGroup('NeutralCybran', 'Artillery')

    -- Announce incoming attack and start 3rd part
    ScenarioFramework.Dialogue(OpStrings.A02_M03_010, StartMission3, true)
end

function StartMission3()
    -- Set the maximum number of units that the players is allowed to have
    ScenarioFramework.SetSharedUnitCap(900)

    ScenarioInfo.M3ObjectiveGroup = Objectives.CreateGroup('Mission 3 Objectives', PlayerWin, 4)

    -------------------------------------------------
    -- Primary Objective 6 - Destroy attacking forces
    -------------------------------------------------
    ScenarioInfo.M3P1Objective = Objectives.Kill(
        'primary',
        'incomplete',
        OpStrings.M3P1Text,
        OpStrings.M3P1Detail,
        {
            Units = ScenarioInfo.M3Attackers,
            MarkUnits = false,
            ShowProgress = false,
        }
    )
    ScenarioInfo.M3P1Objective:AddResultCallback(
        function(result)
            if result then
                ScenarioFramework.Dialogue(OpStrings.A02_M03_020, M3DestroyCybranBases, true)
            end
        end
    )
    ScenarioInfo.M3ObjectiveGroup:AddObjective(ScenarioInfo.M3P1Objective)

    -- Unit restrictions
    ScenarioFramework.RemoveRestrictionForAllHumans(
        categories.ual0208 + -- T2 Engineer
        categories.uab2301 + -- T2 PD
        categories.uab2204 + -- T2 Anti-Air Gun Tower
        categories.uab1201 + -- T2 Power Generator
        categories.uab1202,  -- T2 Mass Extractor
        true
    )

    -- If the player doesn't complete the objectives soon, remind him that it's important
    ScenarioFramework.CreateTimerTrigger(M3P2Reminder, 300)
    ScenarioFramework.CreateTimerTrigger(M3P4Reminder, 600)

    ScenarioFramework.CreateTimerTrigger(M3Taunt2, 400)
    ScenarioFramework.CreateTimerTrigger(M3Taunt3, 960)
end

function M3DestroyCybranBases()
    -- Set the playable area
    ScenarioFramework.SetPlayableArea(Rect(0, 0, 512, 512), true)

    ------------------------------------------
    -- Primary Objective 7 - Destroy East Base
    ------------------------------------------
    ScenarioInfo.M3P2Objective = Objectives.CategoriesInArea(
        'primary',
        'incomplete',
        OpStrings.M3P2Text,
        OpStrings.M3P2Detail,
        'Kill',
        {
            MarkArea = false,
            ShowFaction = 'Cybran',
            Requirements = {
                {
                    Area = 'M3_East_Base_Area',
                    ArmyIndex = Cybran,
                    Category = (categories.CYBRAN * categories.STRUCTURE) - categories.WALL,
                    CompareOp = '==',
                    Value = 0,
                },
            },
        }
    )
    ScenarioInfo.M3P2Objective:AddResultCallback(
        function(result)
            if result then
                ScenarioFramework.Dialogue(OpStrings.A02_M03_060, nil, true)
                local unit = ScenarioUtils.MarkerToPosition("M3_Base_East")
                local camInfo = {
                    blendTime = 1.0,
                    orientationOffset = { -0.6, 0.2, 0 },
                    positionOffset = { 0, 0, 0 },
                    zoomVal = 35,
                    markerCam = true,
                }

                if not ScenarioInfo.M3P3Objective.Active and not ScenarioInfo.M3P4Objective.Active then
                    -- east base destroyed and the op is over
                    camInfo.holdTime = nil
                    camInfo.spinSpeed = 0.03
                    camInfo.overrideCam = true
                    ScenarioFramework.OperationNISCamera(unit, camInfo)
                else
                    -- east base destroyed and the op isn't over
                    camInfo.holdTime = 3.5
                    ScenarioFramework.OperationNISCamera(unit, camInfo)

                    if not ScenarioInfo.M3P3Objective.Active then
                        -- The commander death is the last objective left; delay his death for the camera spin
                        ScenarioFramework.PauseUnitDeath(ScenarioInfo.CybranCommander)
                    end
                end
            end
        end
    )
    ScenarioInfo.M3ObjectiveGroup:AddObjective(ScenarioInfo.M3P2Objective)

    ------------------------------------------
    -- Primary Objective 8 - Destroy West Base
    ------------------------------------------
    ScenarioInfo.M3P3Objective = Objectives.CategoriesInArea(
        'primary',
        'incomplete',
        OpStrings.M3P3Text,
        OpStrings.M3P3Detail,
        'Kill',
        { -- Target
            MarkArea = false,
            ShowFaction = 'Cybran',
            Requirements = {
                {
                    Area = 'M3_West_Base_Area',
                    ArmyIndex = Cybran,
                    Category = (categories.CYBRAN * categories.STRUCTURE) - categories.WALL,
                    CompareOp = '==',
                    Value = 0,
                },
            },
        }
    )
    ScenarioInfo.M3P3Objective:AddResultCallback(
        function(result)
            if result then
                ScenarioFramework.Dialogue(OpStrings.A02_M03_050, false, true)
                local unit = ScenarioUtils.MarkerToPosition("M3_Base_West")
                local camInfo = {
                    blendTime = 1.0,
                    orientationOffset = { 0.15, 0.1, 0 },
                    positionOffset = { 0, 0, 0 },
                    zoomVal = 35,
                    markerCam = true,
                }
                if not ScenarioInfo.M3P2Objective.Active and not ScenarioInfo.M3P4Objective.Active then
                    -- west base killed and op is over
                    --    ScenarioFramework.EndOperationCameraLocation(ScenarioUtils.MarkerToPosition("M3_Base_West"))
                    camInfo.holdTime = nil
                    camInfo.spinSpeed = 0.03
                    camInfo.overrideCam = true
                    ScenarioFramework.OperationNISCamera(unit, camInfo)
                else
                    -- west base killed and op not over
                    camInfo.holdTime = 6
                    ScenarioFramework.OperationNISCamera(unit, camInfo)

                    if not ScenarioInfo.M3P2Objective.Active then
                        -- The commander death is the last objective left; delay his death for the camera spin
                        ScenarioFramework.PauseUnitDeath(ScenarioInfo.CybranCommander)
                    end
                end
            end
        end
    )
    ScenarioInfo.M3ObjectiveGroup:AddObjective(ScenarioInfo.M3P3Objective)

    ----------------------------------------
    -- Primary Objective 9 - Kill Cybran CDR
    ----------------------------------------
    ScenarioInfo.M3P4Objective = Objectives.Kill(
        'primary',
        'incomplete',
        OpStrings.M3P4Text,
        OpStrings.M3P4Detail,
        {
            Units = {ScenarioInfo.CybranCommander},
        }
    )
    ScenarioInfo.M3P4Objective:AddResultCallback(
        function(result)
            if result then
                -- Commander's death cry
                ScenarioFramework.Dialogue(OpStrings.A02_M03_070, nil, true)
                if not ScenarioInfo.M3P2Objective.Active and not ScenarioInfo.M3P3Objective.Active then
                    -- cybran cdr death if this is the last objective
                    --    ScenarioFramework.EndOperationCamera(unit, true)
                    ScenarioFramework.CDRDeathNISCamera(ScenarioInfo.CybranCommander)
                else
                    -- cybran cdr death if this is not the last objective
                    ScenarioFramework.CDRDeathNISCamera(ScenarioInfo.CybranCommander, 7)
                end
            end
        end
    )
    ScenarioInfo.M3ObjectiveGroup:AddObjective(ScenarioInfo.M3P4Objective)

    ScenarioFramework.CreateTimerTrigger(M3Taunt1, 180) -- taunt

    -- Assign objective to capture artilleries once player spots them
    for _, unit in ScenarioInfo.Artillery do
        ScenarioFramework.CreateArmyIntelTrigger(M3CaptureArtilleryObjective, ArmyBrains[Player1], 'LOSNow', unit, true, categories.ALLUNITS, true, ArmyBrains[NeutralCybran])
    end
end

function M3CaptureArtilleryObjective()
    if not ScenarioInfo.ArtyObjectiveAssigned then
        ScenarioInfo.ArtyObjectiveAssigned = true

        -- Temporary allow T2 arty
        -- ScenarioFramework.RemoveRestrictionForAllHumans(categories.urb2303)

        local function AddObjective()
            ----------------------------------------------
            -- Secondary Objective 3 - Capture Artilleries
            ----------------------------------------------
            ScenarioInfo.M3S1Objective = Objectives.KillOrCapture(
                'secondary',
                'incomplete',
                OpStrings.M3S1Text,
                OpStrings.M3S1Detail,
                {
                    MarkUnits = true,
                    Units = ScenarioInfo.Artillery,
                }
            )
            -- ScenarioInfo.M3S1Objective:AddResultCallback(
            --     function(result)
            --         if result then
            --             for _, player in ScenarioInfo.HumanPlayers do
            --                 ScenarioFramework.AddRestriction(player, categories.urb2303)
            --             end
            --         end
            --     end
            -- )
        end
        -- Assign the objective after this VO
        ScenarioFramework.Dialogue(OpStrings.A02_M03_040, AddObjective, true)
    end
end

---------
-- Taunts
---------
function M2Taunt1()
    if ScenarioInfo.MissionNumber == 2 then
        ScenarioFramework.Dialogue(OpStrings.A02_M02_110)
    end
end

function M2Taunt2()
    if ScenarioInfo.MissionNumber == 2 then
        ScenarioFramework.Dialogue(OpStrings.A02_M02_120)
    end
end

function M3Taunt1()
    if not ScenarioInfo.CybranCommander:IsDead() then
        ScenarioFramework.Dialogue(OpStrings.A02_M03_030)
    end
end

function M3Taunt2()
    if not ScenarioInfo.CybranCommander:IsDead() then
        PlayRandomTaunt()
    end
end

function M3Taunt3()
    if not ScenarioInfo.CybranCommander:IsDead() then
        PlayRandomTaunt()
    end
end

function PlayRandomTaunt()
    if not ScenarioInfo.OpEnded then
        local randomIndex = Random(1, 8)
        ScenarioFramework.Dialogue(OpStrings['TAUNT' .. randomIndex])
    end
end

------------
-- Reminders
------------
function M1P1Reminder()
    if ScenarioInfo.M1P1Objective and ScenarioInfo.M1P1Objective.Active and not ScenarioInfo.OpEnded then
        if not ScenarioInfo.M1P1ReminderAlternate then
            ScenarioInfo.M1P1ReminderAlternate = 1
            ScenarioFramework.Dialogue(OpStrings.A02_M01_050)
        elseif ScenarioInfo.M1P1ReminderAlternate == 1 then
            ScenarioInfo.M1P1ReminderAlternate = 2
            ScenarioFramework.Dialogue(OpStrings.A02_M01_055)
        else
            ScenarioInfo.M1P1ReminderAlternate = false
            ScenarioFramework.Dialogue(ScenarioStrings.AeonGenericReminder)
        end
        ScenarioFramework.CreateTimerTrigger(M1P1Reminder, 600)
    end
end

function M2P1Reminder()
    if ScenarioInfo.M2P1Objective and ScenarioInfo.M2P1Objective.Active and not ScenarioInfo.OpEnded then
        if not ScenarioInfo.M2P1ReminderAlternate then
            ScenarioInfo.M2P1ReminderAlternate = 1
            ScenarioFramework.Dialogue(OpStrings.A02_M02_140)
        elseif ScenarioInfo.M2P1ReminderAlternate == 1 then
            ScenarioInfo.M2P1ReminderAlternate = 2
            ScenarioFramework.Dialogue(OpStrings.A02_M02_145)
        else
            ScenarioInfo.M2P1ReminderAlternate = false
            ScenarioFramework.Dialogue(ScenarioStrings.AeonGenericReminder)
        end
        ScenarioFramework.CreateTimerTrigger(M2P1Reminder, 600)
    end
end

function M3P2Reminder()
    if ScenarioInfo.M3P2Objective and ScenarioInfo.M3P2Objective.Active and not ScenarioInfo.OpEnded then
        if not ScenarioInfo.M3P2ReminderAlternate then
            ScenarioInfo.M3P2ReminderAlternate = 1
            ScenarioFramework.Dialogue(OpStrings.A02_M03_080)
        elseif ScenarioInfo.M3P2ReminderAlternate == 1 then
            ScenarioInfo.M3P2ReminderAlternate = 2
            ScenarioFramework.Dialogue(OpStrings.A02_M03_085)
        else
            ScenarioInfo.M3P2ReminderAlternate = false
            ScenarioFramework.Dialogue(ScenarioStrings.AeonGenericReminder)
        end
        ScenarioFramework.CreateTimerTrigger(M3P2Reminder, 600)
    end
end

function M3P4Reminder()
    if ScenarioInfo.M3P4Objective and ScenarioInfo.M3P4Objective.Active and not ScenarioInfo.OpEnded then
        if not ScenarioInfo.M3P4ReminderAlternate then
            ScenarioInfo.M3P4ReminderAlternate = 1
            ScenarioFramework.Dialogue(OpStrings.A02_M03_090)
        elseif ScenarioInfo.M3P4ReminderAlternate == 1 then
            ScenarioInfo.M3P4ReminderAlternate = 2
            ScenarioFramework.Dialogue(OpStrings.A02_M03_095)
        else
            ScenarioInfo.M3P4ReminderAlternate = false
            ScenarioFramework.Dialogue(ScenarioStrings.AeonGenericReminder)
        end
        ScenarioFramework.CreateTimerTrigger(M3P4Reminder, 600)
    end
end

-------------------
-- Custom Funcitons
-------------------
function UnitSetDoNotTarget(unit)
    unit:SetDoNotTarget(true)
end

function EnableScoutsCloackThread()
    local scouts = {}
    while true do
        for _, v in ArmyBrains[Cybran]:GetListOfUnits(categories.url0101, false) do
            if not ( scouts[v:GetEntityId()] or v:IsBeingBuilt() ) then
                v:ToggleScriptBit('RULEUTC_CloakToggle')
                scouts[v:GetEntityId()] = true
            end
        end
        WaitSeconds(10)
    end
end

function TransportAssault(platoon, landingLocation, patrolChain, airUnits)
    -- TODO: This works for both repeating attacks and M3 counter attack but it's ugly AF and should be split in some sexy way
    local aiBrain = platoon:GetBrain()
    local units = {}
    local transports = {}
    for k,v in platoon:GetPlatoonUnits() do
        if EntityCategoryContains(categories.TRANSPORTATION, v) then
            table.insert(transports, v)
        else
            table.insert(units, v)
        end
    end

    ScenarioFramework.AttachUnitsToTransports(units, transports)

    IssueTransportUnload(transports, ScenarioUtils.MarkerToPosition(landingLocation))

    local attached = true
    local allDead = true
    while attached do
        WaitSeconds(2)
        for k,v in transports do
            if not v.Dead then
                allDead = false
                break
            end
        end
        attached = false
        for num, unit in units do
            if not unit.Dead and unit:IsUnitState('Attached') then
                attached = true
                break
            end
        end
    end

    if not allDead then
        ScenarioFramework.GroupFormPatrolChain(units, patrolChain, 'AttackFormation')
    end

    if airUnits then
        local auroras = ScenarioFramework.GetListOfHumanUnits(categories.ual0201 , 'M1_Playable_Area')
        local i = 1
        local max = {1, 3, 9}

        for _, unit in airUnits do
            if EntityCategoryContains(categories.BOMBER, unit) and auroras[i] and i <= max[Difficulty] then
                IssueAttack({unit}, auroras[i])
                IssueAggressiveMove({unit}, ScenarioUtils.MarkerToPosition('Attack_Route1_4'))
                i = i + 1
            else
                ScenarioFramework.GroupPatrolChain({unit}, 'M1_Attack_Route' .. Random(1, 3))
            end
        end
    end

    IssueMove(transports, ScenarioUtils.MarkerToPosition('Transport_Storage'))

    if ScenarioInfo.MissionNumber <= 2 then
        WaitSeconds(30)
        for _, v in transports do
            if not v:IsDead() then
                v:Destroy()
            end
        end
    else
        for _, v in transports do
            aiBrain:AssignUnitsToPlatoon('TransportPool', {v}, 'Scout', 'None')
        end
    end
end

------------------
-- Debug functions
------------------
--[[
function OnCtrlF3()
    IntroMission2()
end

local NorthBaseDead = false
function OnCtrlF4()
    if ScenarioInfo.MissionNumber == 1 then
        for _, v in ScenarioInfo.M1City do
            v:Kill()
        end
    elseif ScenarioInfo.MissionNumber == 2 then
        local area = 'M2_North_Base_Area'
        if NorthBaseDead then
            area = 'M2_South_Base_Area'
        end
        NorthBaseDead = true
        for _, v in ScenarioFramework.GetCatUnitsInArea(categories.STRUCTURE + categories.ENGINEER, area, ArmyBrains[Cybran]) do
            v:Kill()
        end
    end
end

function OnShiftF3()
    ScenarioFramework.EndOperation(true, true, true, true)
end

function OnShiftF4()
    ScenarioUtils.CreateArmyGroup('Player1', 'DEBUG_BASE')
end
--]]

