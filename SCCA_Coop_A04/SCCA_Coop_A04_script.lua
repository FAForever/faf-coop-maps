-- ****************************************************************************
-- **
-- **  File     :  /maps/SCCA_Coop_A04/SCCA_Coop_A04_script.lua
-- **  Author(s):  Drew Staltman
-- **
-- **  Summary  :
-- **
-- **  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
-- ****************************************************************************
local M1CybranAI = import('/maps/SCCA_Coop_A04/SCCA_Coop_A04_m1cybranai.lua')
local M1NexusAI = import('/maps/SCCA_Coop_A04/SCCA_Coop_A04_m1nexusai.lua')
local M2CybranAI = import('/maps/SCCA_Coop_A04/SCCA_Coop_A04_m2cybranai.lua')
local Objectives = import('/lua/SimObjectives.lua')
local OpStrings = import('/maps/SCCA_Coop_A04/SCCA_Coop_A04_Strings.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')

----------
-- Globals
----------
ScenarioInfo.Player1 = 1
ScenarioInfo.Cybran = 2
ScenarioInfo.Civilian = 3
ScenarioInfo.Nodes = 4
ScenarioInfo.Nexus_Defense = 5
ScenarioInfo.Player2 = 6
ScenarioInfo.Player3 = 7
ScenarioInfo.Player4 = 8

---------
-- Locals
---------
local Player1 = ScenarioInfo.Player1
local Coop1 = ScenarioInfo.Player2
local Coop2 = ScenarioInfo.Player3
local Coop3 = ScenarioInfo.Player4
local Cybran = ScenarioInfo.Cybran
local Civilian = ScenarioInfo.Civilian
local Nodes = ScenarioInfo.Nodes
local Nexus_Defense = ScenarioInfo.Nexus_Defense

local AssignedObjectives = {}
local Difficulty = ScenarioInfo.Options.Difficulty

local LeaderFaction
local LocalFaction

-----------
-- Start up
-----------
function OnPopulate(scenario)
    ScenarioUtils.InitializeScenarioArmies()
    LeaderFaction, LocalFaction = ScenarioFramework.GetLeaderAndLocalFactions()

    -- Army colors
    ScenarioFramework.SetAeonColor(Player1)
    ScenarioFramework.SetCybranColor(Cybran)
    ScenarioFramework.SetCybranAllyColor(Civilian)
    ScenarioFramework.SetCybranAllyColor(Nodes)
    ScenarioFramework.SetCybranNeutralColor(Nexus_Defense)
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

    -- Army cap, split among all human players
    ScenarioFramework.SetSharedUnitCap(480)

    ---------
    -- Cybran
    ---------
    M1CybranAI.CybranM1NodeBaseAI()
    M1CybranAI.CybranM1NavalBaseAI()
    ScenarioUtils.CreateArmyGroup('Cybran', 'M1_Artillery_Line')

    -- VO trigger
    local nodeBaseUnits = ScenarioFramework.GetCatUnitsInArea(categories.STRUCTURE, 'M1_Node_Base_Area', ArmyBrains[Cybran]) 
    for _, unit in nodeBaseUnits do
        ScenarioFramework.CreateUnitDamagedTrigger(M1NodeBaseDamaged, unit, .01)
    end

    -- Cybran Initial Units
    -- Naval Blockade
    local blockadeDestroyers = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M1_Destroyer_Blockade_D' .. Difficulty, 'GrowthFormation')
    blockadeDestroyers:MoveToLocation(ScenarioUtils.MarkerToPosition('Cybran_M1_Destroyer_Blockade_Marker'), false)
    ScenarioFramework.CreatePlatoonDeathTrigger(M1CybranAI.M1BlockadeDestroyers, blockadeDestroyers)

    local blockadeCruisers = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M1_Cruiser_Blockade_D' .. Difficulty, 'GrowthFormation')
    for i = 1, 3 do
        IssueMove({blockadeCruisers:GetPlatoonUnits()[i]}, ScenarioUtils.MarkerToPosition('Cybran_M1_Cruiser_Blockade_Marker_' .. i))
    end
    ScenarioFramework.CreatePlatoonDeathTrigger(M1CybranAI.M1BlockadeCruisers, blockadeCruisers)

    -- North-east artillery land patrols
    for i = 1, 2 do
        local rhinos = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M1_North_Arty_Rhinos_' .. i .. '_D' .. Difficulty, 'GrowthFormation')
        ScenarioFramework.PlatoonPatrolChain(rhinos, 'M1_North_Arty_Rhino_Chain_' .. i)

        local flak = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M1_North_Arty_Flak_' .. i, 'GrowthFormation')
        ScenarioFramework.PlatoonPatrolChain(flak, 'M1_North_Arty_Flak_Chain_' .. i)
    end

    -- Naval base land patrol
    local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M1_Naval_Land_Def_D' .. Difficulty, 'GrowthFormation')
    for k, v in platoon:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M1_Naval_Base_LandPatrol_Chain')))
    end

    ------------
    -- Civilians
    ------------
    M1NexusAI.NexusM1BaseAI()                                                                       -- Defense Base
    ScenarioFramework.CreateTimerTrigger(M1NexusAI.NexusBuildArty, (12 - Difficulty * 2) * 60)      -- Build artilerry after 10/8/6 minutes
    ScenarioInfo.NexusCivs = ScenarioUtils.CreateArmyGroup('Civilian', 'Nexus_04')                  -- Civilian buildings
    ScenarioUtils.CreateArmyGroup('Civilian', 'Nexus_Pgens')
    ScenarioUtils.CreateArmyGroup('Nexus_Defense', 'Nexus_Walls_D' .. Difficulty)                   -- Walls

    -- Intel on the civilian base
    ScenarioFramework.CreateVisibleAreaLocation(50, 'Nexus_Base_Marker', 1, ArmyBrains[Player1]) -- .5 duration didn't provide intel to all players

    -- Objective Structures
    ScenarioInfo.SWNode = ScenarioUtils.CreateArmyUnit('Nodes', 'SW_Node_Unit')
    ScenarioInfo.SWNode:SetCustomName('Node 73')
    ScenarioInfo.SWNode:SetCanTakeDamage(false)
    ScenarioInfo.SWNode:SetCanBeKilled(false)
    ScenarioInfo.SWNode:SetReclaimable(false)

    -- Starting mass for AI, needs to be delayed a bit
    ForkThread(function()
        WaitSeconds(2)
        ArmyBrains[Cybran]:GiveResource('MASS', 10000)
    end)
end

function OnStart(self)
    -- Unit and upgrades Restrictions
    for _, player in ScenarioInfo.HumanPlayers do
        ScenarioFramework.AddRestriction(player,
            categories.TECH3 +
            categories.EXPERIMENTAL +
            categories.PRODUCTFA +                     -- All FA Units
            categories.daa0206 +                       -- Mercy
            categories.ual0307 +                       -- Mobile Shield
            categories.uab4202 + categories.urb4202 +  -- T2 Shield
            categories.uab4203 + categories.urb4203 +  -- Steahl Generato
            categories.uab2303 + categories.urb2303    -- T2 Arty
        )
    end
    ScenarioFramework.RestrictEnhancements({'Teleporter', 'T3Engineering', 'ShieldHeavy', 'ResourceAllocationAdvanced'})

    ScenarioFramework.SetPlayableArea('M1_Playable_Area', false)
    ScenarioFramework.StartOperationJessZoom('Start_Camera_Area', IntroNIS, 4)
end

function PlayRandomTaunt()
    if not ScenarioInfo.OpEnded then
        local num = Random(1, 8)
        ScenarioFramework.Dialogue(OpStrings['TAUNT'..num])
        ScenarioFramework.CreateTimerTrigger(PlayRandomTaunt, 15 * 60)
    end
end

-----------
-- End Game
-----------
function PlayerWin()
    if ScenarioInfo.MainframeDestroyed then
        return
    end

    ScenarioFramework.EndOperationSafety()
    ScenarioInfo.OpComplete = true

    ScenarioInfo.M2P1:ManualResult(true)
    ScenarioInfo.M2P2:ManualResult(true)
    ScenarioInfo.M2B2:ManualResult(true)

    local camInfo = {
        blendTime = 2.5,
        holdTime = nil,
        orientationOffset = { math.pi, 0.8, 0 },
        positionOffset = { 0, 4, 0 },
        zoomVal = 45,
        spinSpeed = 0.03,
        overrideCam = true,
    }
    ScenarioFramework.OperationNISCamera(ScenarioInfo.Mainframe, camInfo)

    ScenarioFramework.Dialogue(OpStrings.A04_M02_160, KillGame, true)
end

function PlayerLose(dialogue)
    ScenarioFramework.PlayerLose(dialogue, AssignedObjectives)
end

function PlayerCDRDestroyed(unit)
    ScenarioFramework.PlayerDeath(unit, OpStrings.A04_D01_010, AssignedObjectives)
end

function KillGame()
    local secondaries = Objectives.IsComplete(ScenarioInfo.M1S1)
    local bonus = Objectives.IsComplete(ScenarioInfo.M1B1) and Objectives.IsComplete(ScenarioInfo.M2B1) and Objectives.IsComplete(ScenarioInfo.M2B2) and Objectives.IsComplete(ScenarioInfo.M1B4)
    ScenarioFramework.EndOperation(ScenarioInfo.OpComplete, ScenarioInfo.OpComplete, secondaries, bonus)
end

------------
-- Mission 1
------------
function IntroNIS()
    ScenarioInfo.MissionNumber = 1

    -- Spawn Players
    local tblArmy = ListArmies()
    local i = 1
    while tblArmy[ScenarioInfo['Player' .. i]] do
        ScenarioInfo['Player' .. i .. 'CDR'] = ScenarioFramework.SpawnCommander('Player' .. i, 'Player_CDR', 'Warp', true, true, PlayerCDRDestroyed)
        WaitSeconds(2)
        i = i + 1
    end

    StartMission1()
end

function StartMission1()
    ScenarioFramework.Dialogue(OpStrings.A04_M01_010, nil, true)

    -------------------------------------
    -- Primary Objective 1 - Pacify Nexus
    -------------------------------------
    ScenarioInfo.M1P1 = Objectives.CategoriesInArea(
        'primary',
        'incomplete',
        OpStrings.M1P1Title,
        OpStrings.M1P1Description,
        'kill',
        {
            ShowFaction = 'Cybran',
            Requirements = {
                {  
                    Area = 'Nexus04_Area',
                    Category = categories.ALLUNITS - categories.WALL,
                    CompareOp = '==',
                    Value = 0,
                    ArmyIndex = Nexus_Defense
                },
            },
        }
    )
    ScenarioInfo.M1P1:AddResultCallback(
        function(result)
            if result then
                ScenarioInfo.M1NexusDefeated = true
                ScenarioFramework.Dialogue(OpStrings.A04_M01_110, M1CheckPrimaryObjectives, true)

                if ScenarioInfo.M1B4.Active then
                    ScenarioInfo.M1B4:ManualResult(true)
                end
                
                -- Civilian base "pacified" camera
                local camInfo = {
                    blendTime = 1.0,
                    holdTime = 4,
                    orientationOffset = { -2.7, 0.15, 0 },
                    positionOffset = { 0, 3, 10 },
                    zoomVal = 75,
                    markerCam = true,
                }
                ScenarioFramework.OperationNISCamera(ScenarioUtils.MarkerToPosition("Nexus_Base_Marker"), camInfo)
            end
        end
    )
    table.insert(AssignedObjectives, ScenarioInfo.M1P1)

    ------------------------------------
    -- Bonus Objective - Kill Nexus fast
    ------------------------------------
    ScenarioInfo.M1B4 = Objectives.Basic(
        'bonus',
        'incomplete',
        OpStrings.M1B4Title,
        OpStrings.M1B4Description,
        '',
        {
            Hidden = true,
        }
    )
    ScenarioFramework.CreateArmyStatTrigger(M1BonusObjFailed, ArmyBrains[Nexus_Defense], 'M1BonusObjFailed',
        {{StatType = 'Units_Active', CompareType = 'GreaterThanOrEqual', Value = 4, Category = categories.urb2303}})

    ----------------------------------------
    -- Bonus Objective - Capture Cybran City
    ----------------------------------------
    ScenarioInfo.M1B1 = Objectives.Capture(
        'bonus',
        'incomplete',
        OpStrings.M1B3Title,
        OpStrings.M1B3Description,
        {
            Units = ScenarioInfo.NexusCivs,
            MarkUnits = false,
            -- NumRequired = math.ceil(table.getn(ScenarioInfo.NexusCivs) * 0.8),
            Hidden = true,
        }
    )

    -- Triggers
    ScenarioFramework.CreateArmyIntelTrigger(M1NavalObjective, ArmyBrains[Player1], 'LOSNow', false, true, categories.NAVAL, true, ArmyBrains[Cybran])
    ScenarioFramework.CreateAreaTrigger(M1WarnIncomingAttacks, 'M1_VO_Trigger_Area', categories.ALLUNITS - categories.SCOUT, true, false, ArmyBrains[Cybran], 1, false)
    ScenarioFramework.CreateTimerTrigger(M1CaptureNodeObjective, 2 * 60)
    ScenarioFramework.CreateTimerTrigger(M1GaugeTaunt1, 10 * 60)
    -- Tactical Missile Launchers, wait 12/10/8 minutes to give player's time to build TMDs
    ScenarioFramework.CreateTimerTrigger(M1NexusAI.NexusActivateTML, (14 - Difficulty * 2) * 60)
    ScenarioFramework.CreateTimerTrigger(M1GaugeTaunt2, 15 * 60)
    ScenarioFramework.CreateTimerTrigger(M1StaticShieldReveal, 10 * 60)
    ScenarioFramework.CreateTimerTrigger(M1ObjectiveReminder, 12 * 60)
    ScenarioFramework.CreateTimerTrigger(PlayRandomTaunt, 20 * 60)
end

function M1NavalObjective()
    ScenarioFramework.Dialogue(OpStrings.A04_M01_030)
    ScenarioFramework.Dialogue(OpStrings.A04_M01_090)

    ---------------------------------------------
    -- Secondary Objective 1 - Destroy Naval base
    ---------------------------------------------
    ScenarioInfo.M1S1 = Objectives.CategoriesInArea(
        'secondary',
        'incomplete',
        OpStrings.M1S1Title,
        OpStrings.M1S1Description,
        'kill',
        {
            ShowFaction = 'Cybran',
            Requirements = {
                {
                    Area = 'M1_Naval_Area',
                    Category = categories.ALLUNITS - categories.WALL,
                    CompareOp = '==',
                    Value = 0,
                    ArmyIndex = Cybran
                },
            },
        }
    )
    ScenarioInfo.M1S1:AddResultCallback(
        function(result)
            if result then
                ScenarioFramework.Dialogue(OpStrings.A04_M01_040)

                -- Naval base destroyed camera
                local camInfo = {
                    blendTime = 1.0,
                    holdTime = 4,
                    orientationOffset = { 2.8, 0.2, 0 },
                    positionOffset = { -10, 5, 80 },
                    zoomVal = 45,
                    markerCam = true,
                }
                ScenarioFramework.OperationNISCamera(ScenarioUtils.MarkerToPosition("M1_Naval_Base_Marker"), camInfo)
            end
        end
    )
    table.insert(AssignedObjectives, ScenarioInfo.M1S1)
end

function M1BonusObjFailed()
    if ScenarioInfo.M1B4.Active then
        ScenarioInfo.M1B4:ManualResult(false)
    end
end

function M1WarnIncomingAttacks()
    ScenarioFramework.Dialogue(OpStrings.A04_M01_050)
end

function M1CaptureNodeObjective()
    local function AssignObjective()
        -------------------------------------
        -- Primary Objective 2 - Capture Node
        -------------------------------------
        ScenarioInfo.M1P2 = Objectives.Capture(
            'primary',
            'incomplete',
            OpStrings.M1P2Title,
            OpStrings.M1P2Description,
            {
                Units = {ScenarioInfo.SWNode}
            }
        )
        ScenarioInfo.M1P2:AddResultCallback(
            function (result, returnedUnits)
                if result then
                    ScenarioInfo.SWNode = returnedUnits[1]
                    ScenarioInfo.M1NodeCapture = true

                    ScenarioInfo.SWNode:SetCustomName('Node 73')
                    ScenarioInfo.SWNode:SetCanTakeDamage(false)
                    ScenarioInfo.SWNode:SetCanBeKilled(false)

                    -- First Node captured camera
                    local camInfo = {
                        blendTime = 1.0,
                        holdTime = 4,
                        orientationOffset = { 2.9, 0.3, 0 },
                        positionOffset = { 0, 1, 0 },
                        zoomVal = 30,
                    }
                    ScenarioFramework.OperationNISCamera(ScenarioInfo.SWNode, camInfo)

                    M1CheckPrimaryObjectives()
                end
            end
        )
        table.insert(AssignedObjectives, ScenarioInfo.M1P2)
    end

     -- Allow mobile shields once player sees the node
    ScenarioFramework.CreateArmyIntelTrigger(M1PlayerSeesNode, ArmyBrains[Player1], 'LOSNow', ScenarioInfo.SWNode, true, categories.ALLUNITS, true, ArmyBrains[Nodes])

    -- Play the VO before assigning the objective
    ScenarioFramework.Dialogue(OpStrings.A04_M01_020, AssignObjective, true)
end

function M1NodeBaseDamaged()
    if not ScenarioInfo.NodeBaseDamagedBool then
        ScenarioInfo.NodeBaseDamagedBool = true
        ScenarioFramework.Dialogue(OpStrings.A04_M01_120)
    end
end

-- Allow mobile shields
function M1PlayerSeesNode()
    local function UnrestrictUnits()
        ScenarioFramework.RemoveRestrictionForAllHumans(categories.ual0307, true)
    end
    ScenarioFramework.Dialogue(OpStrings.A04_M01_100, UnrestrictUnits, true)
end

function M1GaugeTaunt1()
    if ScenarioInfo.MissionNumber == 1 then
        ScenarioFramework.Dialogue(OpStrings.A04_M01_060)
    end
end

function M1GaugeTaunt2()
    if ScenarioInfo.MissionNumber == 1 then
        ScenarioFramework.Dialogue(OpStrings.A04_M01_080)
    end
end

function M1StaticShieldReveal()
    local function UnrestrictUnits()
        ScenarioFramework.RemoveRestrictionForAllHumans(categories.uab4202 + categories.urb4202, true)
    end
    ScenarioFramework.Dialogue(OpStrings.A04_M01_070, UnrestrictUnits, true)
end

function M1CheckPrimaryObjectives()
    if ScenarioInfo.M1NodeCapture and ScenarioInfo.M1NexusDefeated then
        ScenarioFramework.Dialogue(OpStrings.A04_M01_150, IntroMission2, true)
    end
end

function M1ObjectiveReminder()
    if ScenarioInfo.MissionNumber == 1 then
        ScenarioFramework.CreateTimerTrigger(M1ObjectiveReminder, 600)
        if not ScenarioInfo.M1NexusDefeated then
            if Random(1,2) == 1 then
                ScenarioFramework.Dialogue(OpStrings.A04_M01_130)
            else
                ScenarioFramework.Dialogue(OpStrings.A04_M01_135)
            end
        else
            if Random(1,2) == 1 then
                ScenarioFramework.Dialogue(OpStrings.A04_M01_140)
            else
                ScenarioFramework.Dialogue(OpStrings.A04_M01_145)
            end
        end
    end
end

------------
-- Mission 2
------------
function IntroMission2()
    ScenarioInfo.MissionNumber = 2

    -- New unit cap for players
    ScenarioFramework.SetSharedUnitCap(660)

    -- Buildable Categories
    ScenarioFramework.RemoveRestrictionForAllHumans(
        categories.uab0302 +  -- Aeon T3 Air Factory
        categories.zab9602 +  -- Aeon T3 Support Air Factory
        categories.uab2303 +  -- Aeon T2 Artillery Installation
        categories.uaa0304 +  -- Aeon T3 Strategic Bomber
        categories.urb0302 +  -- Cybran T3 Air Factory
        categories.zrb9602 +  -- Cybran Support T3 Air Factory
        categories.urb2303 +  -- Cybran T2 Artillery Installation
        categories.ura0304    -- Cybran T3 Strategic Bomber
    )

    ScenarioFramework.RestrictEnhancements({'Teleporter', 'T3Engineering', 'ShieldHeavy'})

    ---------
    -- Cybran
    ---------
    -- Mainframe base
    M2CybranAI.CybranM2MainframeBaseAI()

    -- Defense structures around the map
    ScenarioUtils.CreateArmyGroup('Cybran', 'M2_Defenses_D' .. Difficulty)

    -- Initial Patrols
    -- Mainframe
    local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2_Mainframe_SW_Units_D' .. Difficulty, 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'Cybran_M2_Mainframe_SW_Group_Chain')

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2_Mainframe_SE_Units_D' .. Difficulty, 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'Cybran_M2_Mainframe_SE_Group_Chain')

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2_Mainframe_MidWest_Units_D' .. Difficulty, 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'Cybran_M2_Mainframe_MidWest_Group_Chain')

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2_Mainframe_MidEast_Units_D' .. Difficulty, 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'Cybran_M2_Mainframe_MidEast_Group_Chain')

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2_Mainframe_NW_Units_D' .. Difficulty, 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'Cybran_M2_Mainframe_NW_Group_Chain')

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2_Mainframe_NE_Units_D' .. Difficulty, 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'Cybran_M2_Mainframe_NE_Group_Chain')

    -- South
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2_South_Air_Patrol_1_D' .. Difficulty, 'NoFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'Cybran_M2_South_Patrol_Chain')

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2_North_Air_Patrol_1_D' .. Difficulty, 'NoFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'Cybran_M2_North_Patrol_Chain')

    -- North West
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2_North_West_Land_Patrol_D' .. Difficulty, 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M2_North_West_Land_Patrol_Chain')

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2_North_West_Flak', 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M2_North_West_Flak_Chain')

    -- TMLs
    for _, unit in ArmyBrains[Cybran]:GetListOfUnits(categories.urb2108, false) do
        local plat = ArmyBrains[Cybran]:MakePlatoon('', '')
        ArmyBrains[Cybran]:AssignUnitsToPlatoon(plat, {unit}, 'Attack', 'NoFormation')
        plat:ForkAIThread(plat.TacticalAI)
    end

    --------
    -- Nodes
    --------
    -- NW Node
    ScenarioInfo.NWNode = ScenarioUtils.CreateArmyUnit('Nodes', 'NW_Node_Unit')
    ScenarioInfo.NWNode:SetCustomName('Node 72')
    ScenarioInfo.NWNode:SetReclaimable(false)
    ScenarioFramework.CreateUnitDeathTrigger(M2NodeDestroyed, ScenarioInfo.NWNode)
    ScenarioFramework.CreateUnitReclaimedTrigger(M2NodeDestroyed, ScenarioInfo.NWNode)
    ScenarioFramework.CreateUnitCapturedTrigger(nil, M2NWNodeCaptured, ScenarioInfo.NWNode)

    -- SE Node
    ScenarioInfo.SENode = ScenarioUtils.CreateArmyUnit('Nodes', 'SE_Node_Unit')
    ScenarioInfo.SENode:SetCustomName('Node 74')
    ScenarioInfo.SENode:SetReclaimable(false)
    ScenarioFramework.CreateUnitDeathTrigger(M2NodeDestroyed, ScenarioInfo.SENode)
    ScenarioFramework.CreateUnitReclaimedTrigger(M2NodeDestroyed, ScenarioInfo.SENode)
    ScenarioFramework.CreateUnitCapturedTrigger(nil, M2SENodeCaptured, ScenarioInfo.SENode)

    -- SW Node
    ScenarioInfo.SWNode:SetReclaimable(false)
    ScenarioInfo.SWNode:SetCanTakeDamage(true)
    ScenarioInfo.SWNode:SetCanBeKilled(true)
    ScenarioFramework.CreateUnitCapturedTrigger(nil, M2SWNodeCaptured, ScenarioInfo.SWNode)
    ScenarioFramework.CreateUnitDeathTrigger(M2NodeDestroyed, ScenarioInfo.SWNode)
    ScenarioFramework.CreateUnitReclaimedTrigger(M2NodeDestroyed, ScenarioInfo.SWNode)

    -- Mainframe
    ScenarioInfo.Mainframe = ScenarioUtils.CreateArmyUnit('Nodes', 'Mainframe_Unit')
    ScenarioFramework.CreateUnitDeathTrigger(M2MainframeDestroyed, ScenarioInfo.Mainframe)
    ScenarioFramework.CreateUnitReclaimedTrigger(M2MainframeDestroyed, ScenarioInfo.Mainframe)
    ScenarioFramework.CreateUnitCapturedTrigger(nil, M2MainframeCaptured, ScenarioInfo.Mainframe)

    -- Node Defenses
    ScenarioInfo.MainframeDefenses = ScenarioUtils.CreateArmyGroup('Nodes', 'Mainframe_Defenses')
    ScenarioInfo.NWDefenses = ScenarioUtils.CreateArmyGroup('Nodes', 'NW_Defenses')
    ScenarioInfo.SEDefenses = ScenarioUtils.CreateArmyGroup('Nodes', 'SE_Defenses')
    ScenarioUtils.CreateArmyGroup('Nodes', 'Mainframe_Walls')

    -- Starting mass for AI
    ArmyBrains[Cybran]:GiveResource('MASS', 5000)

    StartMission2()
end

function StartMission2()
    ScenarioFramework.SetPlayableArea('M2_Playable_Area')

    ScenarioFramework.Dialogue(OpStrings.A04_M02_010, nil, true)

    ------------------------------------------
    -- Primary Objective 3 - Capture Mainframe
    ------------------------------------------
    ScenarioInfo.M2P1 = Objectives.Capture(
        'primary',
        'incomplete',
        OpStrings.M2P1Title,
        OpStrings.M2P1Description,
        {
            Units = {ScenarioInfo.Mainframe}
        }
    )
    table.insert(AssignedObjectives, ScenarioInfo.M2P1)

    ---------------------------------
    -- Bonus Objective - Build Strats
    ---------------------------------
    local num = {40, 60, 80}
    ScenarioInfo.M2B1 = Objectives.ArmyStatCompare(
        'bonus',
        'incomplete',
        OpStrings.M1B1Title,
        LOCF(OpStrings.M1B1Description, num[Difficulty]),
        'build',
        {
            Armies = {'HumanPlayers'},
            StatName = 'Units_History',
            CompareOp = '>=',
            Value = num[Difficulty],
            Category = categories.uaa0304 + categories.ura0304,
            Hidden = true,
        }
    )

    --------------------------------------
    -- Bonus Objective - All Nodes Survive
    --------------------------------------
    ScenarioInfo.M2B2 = Objectives.Protect(
        'bonus',
        'incomplete',
        OpStrings.M1B2Title,
        OpStrings.M1B2Description,
        {
            Units = {ScenarioInfo.NWNode, ScenarioInfo.SENode, ScenarioInfo.SWNode},
            MarkUnits = false,
            Hidden = true,
        }
    )

    -- M2 Misc Triggers
    -- Taunts
    ScenarioFramework.CreateTimerTrigger(PlayRandomTaunt, 2 * 60)
    ScenarioFramework.CreateTimerTrigger(PlayRandomTaunt, 5 * 60)
    ScenarioFramework.CreateTimerTrigger(PlayRandomTaunt, 7 * 60)
    ScenarioFramework.CreateTimerTrigger(PlayRandomTaunt, 11 * 60)

    -- Objective reminder
    ScenarioFramework.CreateTimerTrigger(M2ObjectiveReminder, 300)
end

function M2MainframeDestroyed(unit)
    ScenarioInfo.MainframeDestroyed = true

    ForkThread(PlayerLose, OpStrings.TAUNT2)

    local camInfo = {
        blendTime = 2.5,
        holdTime = nil,
        orientationOffset = { math.pi, 0.8, 0 },
        positionOffset = { 0, 4, 0 },
        zoomVal = 45,
        spinSpeed = 0.03,
        overrideCam = true,
    }
    ScenarioFramework.OperationNISCamera(unit, camInfo)
end

-- Mainframe captures. Update unit, retrigger unit, spit dialogue if first time, begin scripted attacks
function M2MainframeCaptured(unit, captor)
    ScenarioInfo.Mainframe = unit
    ScenarioInfo.MainframeCaptured = true

    ScenarioFramework.SetSharedUnitCap(840)

    ScenarioFramework.CreateUnitDeathTrigger(M2MainframeDestroyed, ScenarioInfo.Mainframe)
    ScenarioFramework.CreateUnitReclaimedTrigger(M2MainframeDestroyed, ScenarioInfo.Mainframe)
    ScenarioFramework.CreateUnitCapturedTrigger(nil, M2MainframeCaptured, ScenarioInfo.Mainframe)

    if not ScenarioInfo.PlayerCapturedMainframe then
        for num, unit in ScenarioInfo.MainframeDefenses do
            if not unit:IsDead() then
                ScenarioFramework.GiveUnitToArmy(unit, captor:GetArmy())
            end
        end

        ScenarioInfo.PlayerCapturedMainframe = true

        -- Node objective
        ScenarioFramework.Dialogue(OpStrings.A04_M02_020, M2RevealCaptureNodes, true)

        ScenarioInfo.MainframeCountdownCounter = 0

        ScenarioFramework.CreateTimerTrigger(M2MainframeCountdown, 225)

        ScenarioFramework.CreateTimerTrigger(PlayerWin, 900, true)
        SetAlliance(Nodes, Cybran, 'Enemy')

        M2BeginMainframeAttacks()

        -- Mainframe captured camera
        local camInfo = {
            blendTime = 1.0,
            holdTime = 4,
            orientationOffset = { -2.78, 0.8, 0 },
            positionOffset = { 0, 4, 0 },
            zoomVal = 45,
        }
        ScenarioFramework.OperationNISCamera(ScenarioInfo.Mainframe, camInfo)
    end
end

-- Counter that plays dialogue depending on objective progress
function M2MainframeCountdown()
    ScenarioInfo.MainframeCountdownCounter = ScenarioInfo.MainframeCountdownCounter + 1
    if ScenarioInfo.MainframeCountdownCounter == 1 then
        ScenarioFramework.Dialogue(OpStrings.A04_M02_080)
        ScenarioFramework.CreateTimerTrigger(M2MainframeCountdown, 225)
    elseif ScenarioInfo.MainframeCountdownCounter == 2 then
        ScenarioFramework.Dialogue(OpStrings.A04_M02_090)
        ScenarioFramework.CreateTimerTrigger(M2MainframeCountdown, 225)
    elseif ScenarioInfo.MainframeCountdownCounter == 3 then
        ScenarioFramework.Dialogue(OpStrings.A04_M02_100)
        ScenarioFramework.CreateTimerTrigger(M2MainframeCountdown, 225)
    end
end

------------------------------
-- Part 2 - Mainframe captured
------------------------------
function M2BeginMainframeAttacks()
    -- Offmap bases
    M2CybranAI.CybranM2EastBaseAI()
    M2CybranAI.CybranM2NorthWestBaseAI()
    M2CybranAI.CybranM2SouthWestBaseAI()

    -- Spawn engineers, not included directly in the base since bases don't have difficulty settings
    ScenarioUtils.CreateArmyGroup('Cybran', 'M2_East_Engineers_D' .. Difficulty)
    ScenarioUtils.CreateArmyGroup('Cybran', 'M2_SW_Engineers_D' .. Difficulty)
    ScenarioUtils.CreateArmyGroup('Cybran', 'M2_NW_Engineers_D' .. Difficulty)

    
    ScenarioFramework.CreateTimerTrigger(M2AttackOne, 120)
    ScenarioFramework.CreateTimerTrigger(M2AttackTwo, 280)
    ScenarioFramework.CreateTimerTrigger(M2AttackThree, 360)
    ScenarioFramework.CreateTimerTrigger(M2AttackFour, 415)
    ScenarioFramework.CreateTimerTrigger(M2AttackFive, 480)
    ScenarioFramework.CreateTimerTrigger(M2AttackSix, 525)
    ScenarioFramework.CreateTimerTrigger(M2AttackSeven, 600)
    ScenarioFramework.CreateTimerTrigger(M2AttackEight, 700)
    ScenarioFramework.CreateTimerTrigger(M2DestroyerAttack, 380)
end

-- First attack - air sent from east to mainframe
function M2AttackOne()
    ScenarioFramework.Dialogue(OpStrings.A04_M02_070)
    local plat = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2A1_Air_Attack_D' .. Difficulty, 'GrowthFormation')
    ScenarioFramework.PlatoonAttackChain(plat, 'Cybran_M2_East_To_Mainframe_Air_Chain')
end

-- Second attack - transports and air sent to mainframe
function M2AttackTwo()
    local transports = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2A2_Transports_D' .. Difficulty, 'GrowthFormation')
    local landUnits = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2A2_Land_Assault_D' .. Difficulty, 'AttackFormation')
    ScenarioFramework.AttachUnitsToTransports(landUnits:GetPlatoonUnits(), transports:GetPlatoonUnits())
    ForkThread(M2EastLandAssault, landUnits, transports)
    WaitSeconds(23)
    local airPlat = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2A2_Air_Attack_D' .. Difficulty, 'GrowthFormation')
    ScenarioFramework.PlatoonAttackChain(airPlat, 'Cybran_M2_East_To_Mainframe_Air_Chain')
end

-- Third attack - air sent from NW to mainframe over NW node; SW air sent to player initial base then mainframe
function M2AttackThree()
    local nwPlat = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2A3_NW_Air_Attack_D' .. Difficulty, 'GrowthFormation')
    ScenarioFramework.PlatoonAttackChain(nwPlat, 'Cybran_M2_West_NW_Mainframe_Chain')
    WaitSeconds(13)
    local playerPlat = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2A3_Player_Air_Attack_D' .. Difficulty, 'GrowthFormation')
    ScenarioFramework.PlatoonAttackChain(playerPlat, 'Cybran_M2_SouthWest_Player_Mainframe_Chain')
end

-- Fourth attack - Transports sent to attack mainframe; frigates and destroyers from east to SE node and player base
function M2AttackFour()
    -- Transports
    local transports = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2A4_Transports_D' .. Difficulty, 'NoFormation')
    local units = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2A4_Land_Units_D' .. Difficulty, 'NoFormation')
    ScenarioFramework.AttachUnitsToTransports(units:GetPlatoonUnits(), transports:GetPlatoonUnits())
    ForkThread(M2EastLandAssault, units, transports)

    -- Naval attacks
    WaitSeconds(19)
    local frigates = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2A4_Frigates_D' .. Difficulty, 'NoFormation')
    ScenarioFramework.PlatoonAttackChain(frigates, 'Cybran_M2_East_Naval_Chain')
    WaitSeconds(29)
    local destroyers = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2A4_Destroyers_D' .. Difficulty, 'NoFormation')
    ScenarioFramework.PlatoonAttackChain(destroyers, 'Cybran_M2_East_Destroyers_Player_Chain')
end

-- Fifth attack - Navy from NW to mainframe; SW air to player; NW air to mainframe
function M2AttackFive()
    -- Navy
    local navy = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2A5_NW_Naval_D' .. Difficulty, 'NoFormation')
    ScenarioFramework.PlatoonAttackChain(navy, 'Cybran_M2_NW_Naval_Chain')

    -- Player Air Attack
    WaitSeconds(29)
    local airPlat = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2A5_SW_Player_Air_D' .. Difficulty, 'GrowthFormation')
    ScenarioFramework.PlatoonAttackChain(airPlat, 'Cybran_M2_SouthWest_Player_Mainframe_Chain')

    -- Air Attack NW
    WaitSeconds(37)
    local navyCounter = ScenarioFramework.GetNumOfHumanUnits(categories.NAVAL, 'West_Lake_Area')
    if navyCounter > 5 then
        local nwAirPlat = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2A5_NW_Air_Naval_D' .. Difficulty, 'GrowthFormation')
        ScenarioFramework.PlatoonAttackChain(nwAirPlat, 'Cybran_M2_West_NW_Mainframe_Naval_Chain')
    else
        local nwAirPlat = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2A5_NW_Air_No_Naval_D' .. Difficulty, 'GrowthFormation')
        ScenarioFramework.PlatoonAttackChain(nwAirPlat, 'Cybran_M2_West_NW_Mainframe_Chain')
    end
end

-- Sixth attack - NW air to mainframe; East air attack against player base
function M2AttackSix()
    local nwAirPlat = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2A6_NW_Air_Attack_D' .. Difficulty, 'GrowthFormation')
    ScenarioFramework.PlatoonAttackChain(nwAirPlat, 'Cybran_M2_West_NW_Mainframe_Naval_Chain')

    WaitSeconds(17)
    local eastAirPlat = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2A6_East_Player_Attack_D' .. Difficulty, 'GrowthFormation')
    ScenarioFramework.PlatoonAttackChain(eastAirPlat, 'Cybran_M2_East_Player_Chain')
end

-- Seventh attack - SW air to player; East air to mainframe; NW and East destroyers to mainframe
function M2AttackSeven()
    -- Air attacks
    local playerAirPlat = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2A7_Player_Air_D' .. Difficulty, 'GrowthFormation')
    ScenarioFramework.PlatoonAttackChain(playerAirPlat, 'Cybran_M2_SouthWest_Player_Mainframe_Chain')
    local eastAirPlat = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2A7_East_Mainframe_Air_D' .. Difficulty, 'GrowthFormation')
    ScenarioFramework.PlatoonAttackChain(eastAirPlat, 'Cybran_M2_East_To_Mainframe_Air_Chain')
end

function M2DestroyerAttack()
    -- Destroyers
    local eastDest = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2A7_Destroyers_East_D' .. Difficulty, 'AttackFormation')
    ScenarioFramework.PlatoonMoveChain(eastDest, 'Cybran_M2_East_Naval_Mainframe_Chain')
    WaitSeconds(60)
    local westDest = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2A7_Destroyers_NW_D' .. Difficulty, 'AttackFormation')
    ScenarioFramework.PlatoonMoveChain(westDest, 'Cybran_M2_NW_Naval_Chain')
end

-- Eigth attack - East air to mainframe; SW air to player
function M2AttackEight()
    local eastAirPlat = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2A8_East_Air_D' .. Difficulty, 'GrowthFormation')
    ScenarioFramework.PlatoonAttackChain(eastAirPlat, 'Cybran_M2_East_To_Mainframe_Air_Chain')
    local playerPlat = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2A8_Player_Air_D' .. Difficulty, 'GrowthFormation')
    ScenarioFramework.PlatoonAttackChain(playerPlat, 'Cybran_M2_SouthWest_Player_Mainframe_Chain')
end

-- generic function to attack mainframe from the east
function M2EastLandAssault(units, transports)
    local aiBrain = units:GetBrain()
    local cmd = transports:UnloadAllAtLocation(ScenarioPlatoonAI.PlatoonChooseRandomNonNegative(aiBrain, ScenarioUtils.ChainToPositions('Cybran_M2_Mainframe_Landing_Chain'), 2))
    while transports:IsCommandsActive(cmd) do
        WaitSeconds(2)
        if not aiBrain:PlatoonExists(transports) then
            return
        end
    end
    if aiBrain:PlatoonExists(transports) then
        transports:MoveToLocation(ScenarioUtils.MarkerToPosition('Cybran_East_Transport_Return'), false)
        if aiBrain:PlatoonExists('TransportPool') then
            aiBrain:AssignUnitsToPlatoon('TransportPool', transports:GetPlatoonUnits(), 'Scout', 'None')
        end
    end
    if aiBrain:PlatoonExists(units) then
        units:AggressiveMoveToLocation(ScenarioUtils.MarkerToPosition('Mainframe_Marker'))
    end
end

-- Reveal objective to capture the nodes
function M2RevealCaptureNodes()
    ScenarioInfo.M2P2 = Objectives.Basic(
        'primary',
        'incomplete',
        OpStrings.M2P2Title,
        OpStrings.M2P2Description,
        Objectives.GetActionIcon('capture'),
        {
            Units = { ScenarioInfo.NWNode, ScenarioInfo.SENode },
            MarkUnits = true,
            AlwaysVisible = true,
        }
    )
    table.insert(AssignedObjectives, ScenarioInfo.M2P2)
    ScenarioFramework.CreateTimerTrigger(M2RevealNodeAttacks, 180)
end

-- Reveal that attacks are coming against the nodes
function M2RevealNodeAttacks()
    ScenarioFramework.Dialogue(OpStrings.A04_M02_050)
end

-- When a node is destroyed play dialogue or end game if all destroyed
function M2NodeDestroyed(unit)
    -- Base node cam
    local camInfo = {
        blendTime = 1.0,
        holdTime = 4,
        orientationOffset = { math.pi, 0.3, 0 },
        positionOffset = { 0, 1, 0 },
        zoomVal = 30,
    }

    if ScenarioInfo.NWNode == unit then
        -- NW node destroyed cam
        ScenarioInfo.NWNodeHandled = true
        camInfo.orientationOffset[1] = 0.3927
    elseif ScenarioInfo.SENode == unit then
        -- SE node destroyed cam
        ScenarioInfo.SENodeHandled = true
        camInfo.orientationOffset[1] = -1.5708
    elseif ScenarioInfo.SWNode == unit then
        -- First Node destroyed cam
        camInfo.orientationOffset[1] = 2.9
    end

    if not ScenarioInfo.FirstNodeDestroyed then
        ScenarioInfo.FirstNodeDestroyed = true
        ScenarioFramework.Dialogue(OpStrings.A04_M02_110)
        ScenarioFramework.OperationNISCamera(unit, camInfo)
    elseif not ScenarioInfo.SecondNodeDestroyed then
        ScenarioInfo.SecondNodeDestroyed = true
        ScenarioFramework.Dialogue(OpStrings.A04_M02_120)
        ScenarioFramework.OperationNISCamera(unit, camInfo)
    else
        -- All nodes destroyed
        camInfo.blendTime = 2.5
        camInfo.holdTime = nil
        camInfo.spinSpeed = 0.03
        camInfo.overrideCam = true
        ScenarioFramework.OperationNISCamera(unit, camInfo)

        ForkThread(PlayerLose, OpStrings.A04_M02_150)
    end
end

-- When player captures the NW node
function M2NWNodeCaptured(unit, captor)
    ScenarioInfo.NWNode = unit
    if not ScenarioInfo.NWNodeCapturedBool then
        ScenarioInfo.NWNodeCapturedBool = true
        ScenarioFramework.Dialogue(OpStrings.A04_M02_030)
        for num, unit in ScenarioInfo.NWDefenses do
            if not unit:IsDead() then
                ScenarioFramework.GiveUnitToArmy(unit, captor:GetArmy())
            end
        end
    end
    ScenarioInfo.NWNodeHandled = true
    ScenarioFramework.CreateUnitDeathTrigger(M2NodeDestroyed, ScenarioInfo.NWNode)
    ScenarioFramework.CreateUnitReclaimedTrigger(M2NodeDestroyed, ScenarioInfo.NWNode)
    ScenarioFramework.CreateUnitCapturedTrigger(nil, M2NWNodeCaptured, ScenarioInfo.NWNode)
    ScenarioInfo.SENode:SetCustomName('Node 72')
    ScenarioInfo.NWNode:SetReclaimable(false)

    -- NW Node captured camera
    local camInfo = {
        blendTime = 1.0,
        holdTime = 4,
        orientationOffset = { 0.3927, 0.3, 0 },
        positionOffset = { 0, 1, 0 },
        zoomVal = 30,
    }
    ScenarioFramework.OperationNISCamera(ScenarioInfo.NWNode, camInfo)
end

-- When player captures the SE node
function M2SENodeCaptured(unit, captor)
    ScenarioInfo.SENode = unit
    if not ScenarioInfo.SENodeCapturedBool then
        ScenarioInfo.SENodeCapturedBool = true
        ScenarioFramework.Dialogue(OpStrings.A04_M02_040)
        for num, unit in ScenarioInfo.SEDefenses do
            if not unit:IsDead() then
                ScenarioFramework.GiveUnitToArmy(unit, captor:GetArmy())
            end
        end
    end
    ScenarioInfo.SENodeHandled = true
    ScenarioFramework.CreateUnitDeathTrigger(M2NodeDestroyed, ScenarioInfo.SENode)
    ScenarioFramework.CreateUnitReclaimedTrigger(M2NodeDestroyed, ScenarioInfo.SENode)
    ScenarioFramework.CreateUnitCapturedTrigger(nil, M2SENodeCaptured, ScenarioInfo.SENode)
    ScenarioInfo.SENode:SetCustomName('Node 74')
    ScenarioInfo.SENode:SetReclaimable(false)

    -- SE Node captured camera
    local camInfo = {
        blendTime = 1.0,
        holdTime = 4,
        orientationOffset = { -1.5708, 0.3, 0 },
        positionOffset = { 0, 1, 0 },
        zoomVal = 30,
    }
    ScenarioFramework.OperationNISCamera(ScenarioInfo.SENode, camInfo)
end

-- If the player captures the SW Node again
function M2SWNodeCaptured(unit, captor)
    ScenarioInfo.SWNode = unit
    ScenarioFramework.CreateUnitDeathTrigger(M2NodeDestroyed, ScenarioInfo.SWNode)
    ScenarioFramework.CreateUnitReclaimedTrigger(M2NodeDestroyed, ScenarioInfo.SWNode)
    ScenarioFramework.CreateUnitCapturedTrigger(nil, M2SWNodeCaptured, ScenarioInfo.SWNode)
    ScenarioInfo.SWNode:SetCustomName('Node 73')
    ScenarioInfo.SWNode:SetReclaimable(false)
end

function M2ObjectiveReminder()
    if ScenarioInfo.MissionNumber == 2 then
        ScenarioFramework.CreateTimerTrigger(M2ObjectiveReminder, 300)
        if not ScenarioInfo.MainframeCaptured then
            if Random(1,2) == 1 then
                ScenarioFramework.Dialogue(OpStrings.A04_M02_130)
            else
                ScenarioFramework.Dialogue(OpStrings.A04_M02_135)
            end
        elseif not ScenarioInfo.SENodeHandled or not ScenarioInfo.NWNodeHandled then
            if Random(1,2) == 1 then
                ScenarioFramework.Dialogue(OpStrings.A04_M02_140)
            else
                ScenarioFramework.Dialogue(OpStrings.A04_M02_145)
            end
        end
    end
end

------------------
-- Debug functions
------------------
--[[
function OnCtrlF4()
    ScenarioUtils.CreateArmyGroup('Player1', 'Base')
    ScenarioUtils.CreateArmyGroup('Player1', 'DEBUG_BASE')
    ScenarioUtils.CreateArmyGroup('Player1', 'Land_Units')
    local plat = ScenarioUtils.CreateArmyGroupAsPlatoon('Player1', 'Gunships', 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(plat, 'Player_Patrol_Chain')
    plat = ScenarioUtils.CreateArmyGroupAsPlatoon('Player1', 'Interceptors', 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(plat, 'Player_Patrol_Chain')
end

function OnShiftF3()
    if ScenarioInfo.MissionNumber == 1 then
        for _, v in ArmyBrains[Cybran]:GetListOfUnits(categories.ALLUNITS - categories.WALL, false) do
            v:Kill()
        end
        for _, v in ArmyBrains[Nexus_Defense]:GetListOfUnits(categories.ALLUNITS - categories.WALL, false) do
            v:Kill()
        end
    elseif ScenarioInfo.MissionNumber == 2 then
        for _, v in ArmyBrains[Cybran]:GetListOfUnits(categories.ALLUNITS - categories.WALL, false) do
            v:Kill()
        end
    end
end
--]]
