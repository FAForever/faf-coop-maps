-- ****************************************************************************
-- **
-- **  File     :  /maps/SCCA_Coop_E01/SCCA_Coop_E01_script.lua
-- **  Author(s):  Jessica St. Croix
-- **
-- **  Summary  :  Controls the flow of events in Operation E1
-- **
-- **  Copyright © 2006 Gas Powered Games, Inc.  All rights reserved.
-- ****************************************************************************
local Behaviors = import('/lua/ai/opai/OpBehaviors.lua')
local Objectives = import('/lua/ScenarioFramework.lua').Objectives
local OpStrings = import('/maps/SCCA_Coop_E01/SCCA_Coop_E01_strings.lua')
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local Weather = import('/lua/weather.lua')

---------
-- Globals
---------
ScenarioInfo.Player = 1
ScenarioInfo.Arnold = 2
ScenarioInfo.Cybran = 3
ScenarioInfo.EastResearch = 4
ScenarioInfo.Coop1 = 5
ScenarioInfo.Coop2 = 6
ScenarioInfo.Coop3 = 7
ScenarioInfo.HumanPlayers = {}
local Player = ScenarioInfo.Player
local Coop1 = ScenarioInfo.Coop1
local Coop2 = ScenarioInfo.Coop2
local Coop3 = ScenarioInfo.Coop3
local Arnold = ScenarioInfo.Arnold
local Cybran = ScenarioInfo.Cybran
local eastResearch = ScenarioInfo.EastResearch

ScenarioInfo.PowerGenDestroyed = 0

ScenarioInfo.VarTable['BuildAirMaster'] = false
ScenarioInfo.VarTable['BuildLandMaster'] = true

--------------------------
-- Objective Reminder Times
--------------------------
local M1P1Time = 300
local M1P2Time = 300
local M2P1Time = 300
local M3P1Time = 300
local M4P1Time = 300
local M5P1Time = 900
local M6P1Time = 900
local M7P1Time = 900
local M7P2Time = 900
local M7S1Time = 600
local SubsequentTime = 600

-------------
-- Misc Locals
-------------
local M1P1_MassRequired = 3
local M1P2_PowerRequired = 3
local M3P1_TanksRequired = 3

local CybranNumLandChildrenD1 = 1
local CybranNumLandChildrenD2 = 2
local CybranNumLandChildrenD3 = 3
local CybranNumAirChildrenD1 = 1
local CybranNumAirChildrenD2 = 2
local CybranNumAirChildrenD3 = 3

local leopardTaunt = 1

---------
-- Startup
---------
function OnPopulate(scenario)
    ScenarioUtils.InitializeScenarioArmies()
    ScenarioFramework.GetLeaderAndLocalFactions()
end

function OnStart(self)
    -- Adjust buildable categories for Player
    for _, player in ScenarioInfo.HumanPlayers do
         ScenarioFramework.AddRestriction(player, categories.UEF)
         ScenarioFramework.AddRestriction(player, categories.CYBRAN)
    end

    ScenarioFramework.RemoveRestrictionForAllHumans(categories.ueb1103)  -- T1 Mass Extractor

    -- Lock off cdr upgrades
    ScenarioFramework.RestrictEnhancements({'ResourceAllocation',
                                            'DamageStablization',
                                            'AdvancedEngineering',
                                            'T3Engineering',
                                            'HeavyAntiMatterCannon',
                                            'LeftPod',
                                            'RightPod',
                                            'Shield',
                                            'ShieldGeneratorField',
                                            'TacticalMissile',
                                            'TacticalNukeMissile',
                                            'Teleporter'})
    -- Unit Cap
    ScenarioFramework.SetSharedUnitCap(300)

    -- Army Colors
    ScenarioFramework.SetUEFColor(Player)
    ScenarioFramework.SetUEFAllyColor(Arnold)
    ScenarioFramework.SetCybranColor(Cybran)
    ScenarioFramework.SetUEFNeutralColor(eastResearch)
    local colors = {
        ['Coop1'] = {67, 110, 238}, 
        ['Coop2'] = {97, 109, 126}, 
        ['Coop3'] = {255, 255, 255}
    }
    local tblArmy = ListArmies()
    for army, color in colors do
        if tblArmy[ScenarioInfo[army]] then
            ScenarioFramework.SetArmyColor(ScenarioInfo[army], unpack(color))
        end
    end

    ScenarioFramework.SetPlayableArea('M1Area', false)
    ScenarioFramework.StartOperationJessZoom('CDRZoom', IntroMission1)
end

----------
-- End Game
----------
function KillBase()
    if(not ScenarioInfo.OpEnded) then
        ScenarioFramework.EndOperationSafety()
        ScenarioInfo.OpComplete = true
        ScenarioFramework.Dialogue(OpStrings.E01_M07_090, false, true)
        WaitSeconds(10)
        for i = 1, 5 do
            local units = GetUnitsInRect(ScenarioUtils.AreaToRect('M7Death' .. i))
            local cybranUnits = {}
            if(units) then
                for k, v in units do
                    if(not v:IsDead() and v:GetAIBrain() == ArmyBrains[Cybran]) then
                        table.insert(cybranUnits, v)
                    end
                end
            end
            if(cybranUnits) then
                for k, v in cybranUnits do
                    v:Kill()
                end
            end
            WaitSeconds(1.5)
        end
        ScenarioFramework.Dialogue(OpStrings.E01_M07_080, PlayerWin, true)
    end
end

function PlayerWin()
    ScenarioFramework.Dialogue(OpStrings.E01_M07_130, StartKillGame, true)
end

function PlayerLose(unit)
    ScenarioFramework.PlayerDeath(unit, OpStrings.E01_D01_010)
end

function StartKillGame()
    ForkThread(KillGame)
end

function KillGame()
    if(not ScenarioInfo.OpComplete) then
        WaitSeconds(15)
    end
    local secondaries = Objectives.IsComplete(ScenarioInfo.M7S1)
    ScenarioFramework.EndOperation(ScenarioInfo.OpComplete, ScenarioInfo.OpComplete, secondaries)
end

-----------
-- Mission 1
-----------
function IntroMission1()
    ScenarioInfo.MissionNumber = 1

    -- Player CDR
    ScenarioInfo.PlayerCDR = ScenarioUtils.CreateArmyUnit('Player', 'Commander')
    ScenarioInfo.PlayerCDR:PlayCommanderWarpInEffect()
    ScenarioInfo.PlayerCDR:SetCustomName(ArmyBrains[Player].Nickname)

    -- spawn coop players too
    ScenarioInfo.CoopCDR = {}
    local tblArmy = ListArmies()
    coop = 1
    for iArmy, strArmy in pairs(tblArmy) do
        if iArmy >= ScenarioInfo.Coop1 then
            ScenarioInfo.CoopCDR[coop] = ScenarioUtils.CreateArmyUnit(strArmy, 'Commander')
            ScenarioInfo.CoopCDR[coop]:PlayCommanderWarpInEffect()
            ScenarioInfo.CoopCDR[coop]:SetCustomName(ArmyBrains[iArmy].Nickname)
            coop = coop + 1
            WaitSeconds(0.5)
        end
    end

    ScenarioFramework.PauseUnitDeath(ScenarioInfo.PlayerCDR)

    for index, coopACU in ScenarioInfo.CoopCDR do
        ScenarioFramework.PauseUnitDeath(coopACU)
        ScenarioFramework.CreateUnitDeathTrigger(PlayerLose, coopACU)
    end
    ScenarioFramework.CreateUnitDeathTrigger(PlayerLose, ScenarioInfo.PlayerCDR)
    WaitSeconds(5)

    ScenarioFramework.Dialogue(OpStrings.E01_M01_040, StartMission1Part1)
end

function StartMission1Part1()
    -- Primary Objective 1
    ScenarioInfo.M1P1 = Objectives.ArmyStatCompare(
        'primary',                      -- type
        'incomplete',                   -- complete
        OpStrings.OpE01_M1P2_Title,     -- title
        OpStrings.OpE01_M1P2_Desc,      -- description
        'build',                        -- action
        {                               -- target
            Army = Player,
            StatName = 'Units_Active',
            CompareOp = '>=',
            Value = M1P1_MassRequired,
            Category = categories.ueb1103,
            ShowProgress = true,
        }
   )
    ScenarioInfo.M1P1:AddResultCallback(
        function()
            StartMission1Part2()
        end
   )

    -- Primary Objective 1 Reminder
    ScenarioFramework.CreateTimerTrigger(M1P1Reminder1, M1P1Time)
end

function M1P1Reminder1()
    if(ScenarioInfo.M1P1.Active) then
        ScenarioFramework.Dialogue(OpStrings.E01_M01_065)
        ScenarioFramework.CreateTimerTrigger(M1P1Reminder2, SubsequentTime)
    end
end

function M1P1Reminder2()
    if(ScenarioInfo.M1P1.Active) then
        ScenarioFramework.Dialogue(OpStrings.E01_M01_070)
        ScenarioFramework.CreateTimerTrigger(M1P1Reminder3, SubsequentTime)
    end
end

function M1P1Reminder3()
    if(ScenarioInfo.M1P1.Active) then
        ScenarioFramework.Dialogue(OpStrings.E01_M01_060)
        ScenarioFramework.CreateTimerTrigger(M1P1Reminder1, SubsequentTime)
    end
end


function StartMission1Part2()
    -- Adjust buildable categories for Player
    ScenarioFramework.RemoveRestrictionForAllHumans(categories.ueb1101)  -- T1 Power Generator

    -- Primary Objective 2
    ScenarioInfo.M1P2 = Objectives.ArmyStatCompare(
        'primary',                      -- type
        'incomplete',                   -- complete
        OpStrings.OpE01_M1P1_Title,     -- title
        OpStrings.OpE01_M1P1_Desc,      -- description
        'build',                        -- action
        {                               -- target
            Army = Player,
            StatName = 'Units_Active',
            CompareOp = '>=',
            Value = M1P2_PowerRequired,
            Category = categories.ueb1101,
            ShowProgress = true,
        }
   )
    ScenarioInfo.M1P2:AddResultCallback(
        function()
            IntroMission2()
        end
   )

    -- Primary Objective 2 Reminder
    ScenarioFramework.CreateTimerTrigger(M1P2Reminder1, M1P2Time)
end

function M1P2Reminder1()
    if(ScenarioInfo.M1P2.Active) then
        ScenarioFramework.Dialogue(OpStrings.E01_M01_050)
        ScenarioFramework.CreateTimerTrigger(M1P2Reminder2, SubsequentTime)
    end
end

function M1P2Reminder2()
    if(ScenarioInfo.M1P2.Active) then
        ScenarioFramework.Dialogue(OpStrings.E01_M01_055)
        ScenarioFramework.CreateTimerTrigger(M1P2Reminder3, SubsequentTime)
    end
end

function M1P2Reminder3()
    if(ScenarioInfo.M1P2.Active) then
        ScenarioFramework.Dialogue(OpStrings.E01_M01_060)
        ScenarioFramework.CreateTimerTrigger(M1P2Reminder1, SubsequentTime)
    end
end

-----------
-- Mission 2
-----------
function IntroMission2()
    ScenarioInfo.MissionNumber = 2
    ScenarioFramework.RemoveRestrictionForAllHumans(categories.ueb0101)  -- T1 Land Factory
    ScenarioFramework.Dialogue(OpStrings.E01_M02_010, StartMission2)
end

function StartMission2()
    -- Primary Objective 1
    ScenarioInfo.M2P1 = Objectives.ArmyStatCompare(
        'primary',                      -- type
        'incomplete',                   -- complete
        OpStrings.OpE01_M2P1_Title,     -- title
        OpStrings.OpE01_M2P1_Desc,      -- description
        'build',                        -- action
        {                               -- target
            Army = Player,
            StatName = 'Units_Active',
            CompareOp = '>=',
            Value = 1,
            Category = categories.ueb0101,
            ShowProgress = true,
        }
   )
    ScenarioInfo.M2P1:AddResultCallback(
        function()
            IntroMission3()
        end
   )

    -- M2P1 Objective Reminder
    ScenarioFramework.CreateTimerTrigger(M2P1Reminder1, M2P1Time)
end

function M2P1Reminder1()
    if(ScenarioInfo.M2P1.Active) then
        ScenarioFramework.Dialogue(OpStrings.E01_M02_020)
        ScenarioFramework.CreateTimerTrigger(M2P1Reminder2, SubsequentTime)
    end
end

function M2P1Reminder2()
    if(ScenarioInfo.M2P1.Active) then
        ScenarioFramework.Dialogue(OpStrings.E01_M02_025)
        ScenarioFramework.CreateTimerTrigger(M2P1Reminder3, SubsequentTime)
    end
end

function M2P1Reminder3()
    if(ScenarioInfo.M2P1.Active) then
        ScenarioFramework.Dialogue(OpStrings.E01_M01_060)
        ScenarioFramework.CreateTimerTrigger(M2P1Reminder1, SubsequentTime)
    end
end

-----------
-- Mission 3
-----------
function IntroMission3()
    ScenarioInfo.MissionNumber = 3
    ScenarioFramework.RemoveRestrictionForAllHumans(
        categories.uel0105 + -- T1 Engineer
        categories.uel0201 + -- T1 Medium Tank
        categories.ueb2101 + -- T1 Point Defense
        categories.ueb3101 + -- T1 Radar
        categories.ueb5101   -- Wall
    )

    ScenarioFramework.Dialogue(OpStrings.E01_M03_010, StartMission3)
end

function StartMission3()
    -- Primary Objective 1
    ScenarioInfo.M3P1 = Objectives.ArmyStatCompare(
        'primary',                                              -- type
        'incomplete',                                           -- complete
        LOCF(OpStrings.OpE01_M3P1_Title, M3P1_TanksRequired),   -- title
        LOCF(OpStrings.OpE01_M3P1_Desc, M3P1_TanksRequired),    -- description
        'build',                                                -- action
        {                                                       -- target
            Army = Player,
            StatName = 'Units_Active',
            CompareOp = '>=',
            Value = M3P1_TanksRequired,
            Category = categories.uel0201,
            ShowProgress = true,
        }
   )
    ScenarioInfo.M3P1:AddResultCallback(
        function()
            IntroMission4()
        end
   )

    -- M3P1 Objective Reminder
    ScenarioFramework.CreateTimerTrigger(M3P1Reminder1, M3P1Time)
end

function ArnoldFlyover()
    WaitSeconds(10)
    ScenarioInfo.Flyover = ScenarioUtils.CreateArmyGroupAsPlatoon('Arnold', 'FlyOver', 'StaggeredChevronFormation')
    ScenarioInfo.Flyover.PlatoonData = {}
    ScenarioInfo.Flyover.PlatoonData.MoveRoute = {'FlyoverDeath'}
    ScenarioPlatoonAI.MoveToThread(ScenarioInfo.Flyover)
    WaitSeconds(10)
    KillFlyover()
    --ScenarioFramework.CreateAreaTrigger(KillFlyover, ScenarioUtils.AreaToRect('FlyoverDeath'), categories.UEF,
      -- true, false, ArmyBrains[Arnold], table.getn(ScenarioInfo.Flyover:GetPlatoonUnits()))
end

function KillFlyover()
    ScenarioInfo.Flyover:Destroy()
end

function M3P1Reminder1()
    if(ScenarioInfo.M3P1.Active) then
        ScenarioFramework.Dialogue(OpStrings.E01_M03_050)
        ScenarioFramework.CreateTimerTrigger(M3P1Reminder2, SubsequentTime)
    end
end

function M3P1Reminder2()
    if(ScenarioInfo.M3P1.Active) then
        ScenarioFramework.Dialogue(OpStrings.E01_M03_060)
        ScenarioFramework.CreateTimerTrigger(M3P1Reminder3, SubsequentTime)
    end
end

function M3P1Reminder3()
    if(ScenarioInfo.M3P1.Active) then
        ScenarioFramework.Dialogue(OpStrings.E01_M01_060)
        ScenarioFramework.CreateTimerTrigger(M3P1Reminder1, SubsequentTime)
    end
end

-----------
-- Mission 4
-----------
function IntroMission4()
    ScenarioInfo.MissionNumber = 4

    ScenarioInfo.Radar = ScenarioUtils.CreateArmyUnit('Cybran', 'Radar')
    ScenarioInfo.Radar:SetCapturable(false)
    ScenarioInfo.Radar:SetReclaimable(false)
    local radarPatrol = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'RadarPatrol', 'AttackFormation')
    for i = 1, 3 do
        radarPatrol:Patrol(ScenarioUtils.MarkerToPosition('Radar_Patrol' .. i))
    end
    ScenarioUtils.CreateArmyGroup('Cybran', 'RadarStructures')

    ScenarioFramework.Dialogue(OpStrings.E01_M04_010, StartMission4)
end

function StartMission4()
    ScenarioFramework.SetPlayableArea('M4Area')

    -- Primary Objective 1
    ScenarioInfo.M4P1 = Objectives.KillOrCapture (
        'primary',                      -- type
        'incomplete',                   -- complete
        OpStrings.OpE01_M4P1_Title,     -- title
        OpStrings.OpE01_M4P1_Desc,      -- description
        {                               -- target
            FlashVisible = true,
            Units = {ScenarioInfo.Radar},
        }
   )
    ScenarioInfo.M4P1:AddResultCallback(
        function(result, unit)
--        ScenarioFramework.MidOperationCamera(unit, true, 5)

-- Radar Destroyed
            local camInfo = {
                blendTime = 1.0,
                holdTime = 3.5,
                orientationOffset = { 2.6708, 0.2, 0 },
                positionOffset = { 0, 0.5, 0 },
                zoomVal = 10,
            }
-- Disabled because timing tough to get right.
--        ScenarioFramework.OperationNISCamera(unit, camInfo)
            IntroMission5()
        end
   )

    -- M4P1 Objective Reminder
    ScenarioFramework.CreateTimerTrigger(M4P1Reminder1, M4P1Time)
end

function M4P1Reminder1()
    if(ScenarioInfo.M4P1.Active) then
        ScenarioFramework.Dialogue(OpStrings.E01_M04_050)
        ScenarioFramework.CreateTimerTrigger(M4P1Reminder2, SubsequentTime)
    end
end

function M4P1Reminder2()
    if(ScenarioInfo.M4P1.Active) then
        ScenarioFramework.Dialogue(OpStrings.E01_M04_055)
        ScenarioFramework.CreateTimerTrigger(M4P1Reminder3, SubsequentTime)
    end
end

function M4P1Reminder3()
    if(ScenarioInfo.M4P1.Active) then
        ScenarioFramework.Dialogue(OpStrings.E01_M01_060)
        ScenarioFramework.CreateTimerTrigger(M4P1Reminder1, SubsequentTime)
    end
end

-----------
-- Mission 5
-----------
function IntroMission5()
    ScenarioInfo.MissionNumber = 5

    ScenarioFramework.SetSharedUnitCap(480)

    ScenarioFramework.RemoveRestrictionForAllHumans(
        categories.uel0101 + -- Land Scout
        categories.uel0103 + -- Mobile Light Artillery
        categories.uel0104 + -- Mobile AA Gun
        categories.uel0106   -- Light Assault Bot
    )

    -- Adjust buildable categories for Cybran in case Player captures them
    ScenarioFramework.RemoveRestrictionForAllHumans(
        categories.urb0102 + -- T1 Air Factory
        categories.urb1101 + -- T1 Power Generator
        categories.urb1103 + -- T1 Mass Extractor
        categories.urb2104 + -- T1 AA Tower
        categories.urb3101 + -- T1 Radar
        categories.urb5101 + -- Wall
        categories.ura0101 + -- Air Scout
        categories.ura0102 + -- Interceptor
        categories.ura0103 + -- Attack Bomber
        categories.url0105   -- T1 Engineer
    )

    -- Cybran Air Base
    ScenarioUtils.CreateArmyGroup('Cybran', 'AirBasePreBuilt')
    ScenarioInfo.AirFactory = ScenarioUtils.CreateArmyUnit('Cybran', 'AirFactory')
    ScenarioInfo.AirFactory:SetCapturable(false)

    -- Cybran Air Base Patrols
    for i = 1, ScenarioInfo.Options.Difficulty do
        for j = 1, 2 do
            local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'AirBasePatrol' .. j .. '_D' .. i, 'AttackFormation')
            platoon.PlatoonData = {}
            platoon.PlatoonData.PatrolChain = 'AirBase_Chain'
            platoon:ForkAIThread(ScenarioPlatoonAI.RandomPatrolThread)
        end
    end

    ScenarioFramework.Dialogue(OpStrings.E01_M05_010, StartMission5)
end

function StartMission5()
    ScenarioFramework.CreateAreaTrigger(Leopard11Dialogue, ScenarioUtils.AreaToRect('Cybran_Air_Base'),
        categories.ALLUNITS, true, false, ArmyBrains[Player], 1, false)

    -- Primary Objective 1
    ScenarioInfo.M5P1 = Objectives.KillOrCapture(
        'primary',                      -- type
        'incomplete',                   -- complete
        OpStrings.OpE01_M5P1_Title,     -- title
        OpStrings.OpE01_M5P1_Desc,      -- description
        {                               -- target
            FlashVisible = true,
            Units = {ScenarioInfo.AirFactory},
        }
   )
    ScenarioInfo.M5P1:AddResultCallback(
        function(result, unit)
            ForkThread(ArnoldFlyover)
            ForkThread(TankApproach)
--        ScenarioFramework.MidOperationCamera(unit, true, 3)

-- Air Factory Destroyed
            local camInfo = {
                blendTime = 1.0,
                holdTime = 6,
                orientationOffset = { 1.9, 0.2, 0 },
                positionOffset = { 0, 0.5, 0 },
                zoomVal = 15,
            }
            ScenarioFramework.OperationNISCamera(unit, camInfo)
            IntroMission6()
        end
   )

    -- M5P1 Objective Reminder
    ScenarioFramework.CreateTimerTrigger(M5P1Reminder1, M5P1Time)

    ScenarioFramework.SetPlayableArea('M5Area')
end

function Leopard11Dialogue()
    ScenarioFramework.Dialogue(OpStrings.E01_M01_030)

    -- Kickoff UEF Taunts
    ScenarioFramework.CreateTimerTrigger(Taunt, Random(600, 900))
end

function TankApproach()
    -- WaitSeconds(10)
    ScenarioInfo.PlayerTanks = {}
    local tankNum = 1

    for i = 1, 10 do
        local tank = ScenarioUtils.CreateArmyUnit('Arnold', 'Tank' .. i)
        tank:SetCanTakeDamage(false)
        tank:SetCanBeKilled(false)
        tank:SetReclaimable(false)
        tank:SetCapturable(false)
        IssueMove({tank}, ScenarioUtils.MarkerToPosition('TankStop' .. tankNum))
        tankNum = tankNum + 1
        table.insert(ScenarioInfo.PlayerTanks, tank)
        WaitSeconds(1)
    end
end

function Taunt()
    if(leopardTaunt <= 8) then
        ScenarioFramework.Dialogue(OpStrings['TAUNT' .. leopardTaunt])
        leopardTaunt = leopardTaunt + 1
        ScenarioFramework.CreateTimerTrigger(Taunt, Random(600, 900))
    end
end

function M5P1Reminder1()
    if(ScenarioInfo.M5P1.Active) then
        ScenarioFramework.Dialogue(OpStrings.E01_M05_050)
        ScenarioFramework.CreateTimerTrigger(M5P1Reminder2, SubsequentTime)
    end
end

function M5P1Reminder2()
    if(ScenarioInfo.M5P1.Active) then
        ScenarioFramework.Dialogue(OpStrings.E01_M05_055)
        ScenarioFramework.CreateTimerTrigger(M5P1Reminder3, SubsequentTime)
    end
end

function M5P1Reminder3()
    if(ScenarioInfo.M5P1.Active) then
        ScenarioFramework.Dialogue(OpStrings.E01_M01_060)
        ScenarioFramework.CreateTimerTrigger(M5P1Reminder1, SubsequentTime)
    end
end

-----------
-- Mission 6
-----------
function IntroMission6()
    ScenarioInfo.MissionNumber = 6

    -- Turn off airbase builders
    for k, v in ArmyBrains[Cybran]:GetPlatoonsList() do
        if(v.BuilderName == 'AirBase_Engineers_D' .. ScenarioInfo.Options.Difficulty) then
            v.PlatoonData.MaintainBaseTemplate = false
        end
    end

    -- Cybran Defensive Line
    ScenarioInfo.DefensiveLine = ScenarioUtils.CreateArmyGroup('Cybran', 'DefensiveLineStructures_D' .. ScenarioInfo.Options.Difficulty)
    for i = 1, ScenarioInfo.Options.Difficulty do
        local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'DefensiveLinePatrol_D' .. i, 'AttackFormation')
        platoon.PlatoonData = {}
        platoon.PlatoonData.PatrolChain = 'DefensiveLine_Chain'
        platoon:ForkAIThread(ScenarioPlatoonAI.RandomPatrolThread)
    end
    ScenarioUtils.CreateArmyGroup('Cybran', 'DefensiveLineMass')

    if(ScenarioInfo.Options.Difficulty >= 2) then
        ScenarioUtils.CreateArmyGroup('Cybran', 'DefensiveLineWalls_D2')
        ScenarioUtils.CreateArmyGroup('Cybran', 'DefensiveLineEngineers')
    end

    ScenarioFramework.Dialogue(OpStrings.E01_M05_020, StartMission6)
end

function StartMission6()
    ForkThread(GiveTanks)

    ScenarioFramework.Dialogue(OpStrings.E01_M05_025)
    ScenarioFramework.SetPlayableArea('M6Area')

    -- Primary Objective 1
    ScenarioInfo.M6P1 = Objectives.KillOrCapture (
        'primary',                      -- type
        'incomplete',                   -- complete
        OpStrings.OpE01_M6P1_Title,     -- title
        OpStrings.OpE01_M6P1_Desc,      -- description
        {                               -- target
            FlashVisible = true,
            Units = ScenarioInfo.DefensiveLine,
        }
   )
    ScenarioInfo.M6P1:AddResultCallback(
        function(result, unit)
--        ScenarioFramework.MidOperationCamera(unit, true, 3)
            IntroMission7()
        end
   )

    -- M6P1 Objective Reminder
    ScenarioFramework.CreateTimerTrigger(M6P1Reminder1, M6P1Time)
end

function GiveTanks()
    while(table.getn(ScenarioInfo.PlayerTanks) < 10) do
        WaitSeconds(.5)
    end
    for k, v in ScenarioInfo.PlayerTanks do
        while(v:IsUnitState('Moving') == true) do
            WaitSeconds(.5)
        end
    end
    WaitSeconds(1)
    for k, v in ScenarioInfo.PlayerTanks do
        ScenarioFramework.GiveUnitToArmy(v, Player)
    end
end

function M6P1Reminder1()
    if(ScenarioInfo.M6P1.Active) then
        ScenarioFramework.Dialogue(OpStrings.E01_M06_050)
        ScenarioFramework.CreateTimerTrigger(M6P1Reminder2, SubsequentTime)
    end
end

function M6P1Reminder2()
    if(ScenarioInfo.M6P1.Active) then
        ScenarioFramework.Dialogue(OpStrings.E01_M06_055)
        ScenarioFramework.CreateTimerTrigger(M6P1Reminder3, SubsequentTime)
    end
end

function M6P1Reminder3()
    if(ScenarioInfo.M6P1.Active) then
        ScenarioFramework.Dialogue(OpStrings.E01_M01_060)
        ScenarioFramework.CreateTimerTrigger(M6P1Reminder1, SubsequentTime)
    end
end

-----------
-- Mission 7
-----------
function IntroMission7()
    ScenarioInfo.MissionNumber = 7

    ScenarioFramework.SetSharedUnitCap(660)

    ScenarioFramework.Dialogue(OpStrings.E01_M06_020)

    ScenarioFramework.RemoveRestrictionForAllHumans(
        categories.ueb0102 + -- T1 Air Factory
        categories.ueb2104 + -- T1 AA Tower
        categories.uea0101 + -- Air Scout
        categories.uea0102 + -- Interceptor
        categories.uea0103   -- Attack Bomber
    )

    -- Player has access to ResourceAllocation and DamageStabilization
    ScenarioFramework.RestrictEnhancements({'AdvancedEngineering',
                                            'T3Engineering',
                                            'HeavyAntiMatterCannon',
                                            'LeftPod',
                                            'RightPod',
                                            'Shield',
                                            'ShieldGeneratorField',
                                            'TacticalMissile',
                                            'TacticalNukeMissile',
                                            'Teleporter'})

    -- Adjust buildable categories for Cybran in case Player captures them
    ScenarioFramework.RemoveRestrictionForAllHumans(
        categories.urb0101 + -- T1 Land Factory
        categories.urb2101 + -- T1 Point Defense
        categories.url0101 + -- Land Scout
        categories.url0103 + -- Mobile Light Artillery
        categories.url0104 + -- Mobile AA Gun
        categories.url0106   -- Light Assault Bot
    )

    CybranNumLandChildrenD1 = 3
    CybranNumLandChildrenD2 = 5
    CybranNumLandChildrenD3 = 7
    CybranNumAirChildrenD1 = 3
    CybranNumAirChildrenD2 = 5
    CybranNumAirChildrenD3 = 7

    -- Eastern R&D
    ScenarioUtils.CreateArmyGroup('EastResearch', 'EastResearchStructures_Undamaged')
    local structures = ScenarioUtils.CreateArmyGroup('EastResearch', 'EastResearchStructures_Damaged')
    for k, v in structures do
        v:AdjustHealth(v, Random(0, v:GetHealth()) * -1)
    end
    ScenarioUtils.CreateArmyGroup('EastResearch', 'EastResearchEngineers')

    -- Disable light artillery
    ScenarioInfo.LightArtillery = ScenarioUtils.CreateArmyUnit('EastResearch', 'LightArtillery')
    ScenarioInfo.LightArtillery:SetWeaponEnabledByLabel('MainGun', false)

    -- Cybran Main Base
    ScenarioInfo.CybranCDR = ScenarioUtils.CreateArmyUnit('Cybran', 'Commander')
    ScenarioInfo.CybranCDR:SetCustomName(LOC '{i CDR_Leopard_11}')
    ScenarioInfo.CybranCDR:CreateEnhancement('CoolingUpgrade')
    ScenarioFramework.PauseUnitDeath(ScenarioInfo.CybranCDR)
    local cdrPlatoon = ArmyBrains[Cybran]:MakePlatoon('','')
    ArmyBrains[Cybran]:AssignUnitsToPlatoon(cdrPlatoon, {ScenarioInfo.CybranCDR}, 'Attack', 'AttackFormation')
    cdrPlatoon:ForkAIThread(CDRAI)
    cdrPlatoon.CDRData = {}
    cdrPlatoon.CDRData.LeashPosition = 'Cybran_MainBase'
    cdrPlatoon.CDRData.LeashRadius = 35
    cdrPlatoon:ForkThread(Behaviors.CDROverchargeBehavior)

    ScenarioUtils.CreateArmyGroup('Cybran', 'MainBaseStructures_D' .. ScenarioInfo.Options.Difficulty)

    -- Research Attack
    local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'ResearchAttack', 'AttackFormation')
    platoon.PlatoonData = {}
    platoon.PlatoonData.PatrolChain = 'Research_Chain'
    platoon:ForkAIThread(ScenarioPlatoonAI.PatrolThread)

    -- Cybran Power Base
    ScenarioInfo.PowerGens = ScenarioUtils.CreateArmyGroup('Cybran', 'PowerGens')
    for k, v in ScenarioInfo.PowerGens do
        v:SetDoNotTarget(true)
    end
    ScenarioUtils.CreateArmyGroup('Cybran', 'PowerBaseEngineers')
    ScenarioUtils.CreateArmyGroup('Cybran', 'PowerBaseStructures')
    ScenarioUtils.CreateArmyGroup('Cybran', 'PowerBasePatrol_D' .. ScenarioInfo.Options.Difficulty)

    ScenarioFramework.Dialogue(OpStrings.E01_M07_010, StartMission7)
end

function StartMission7()
    ScenarioFramework.SetPlayableArea('M7Area')

    -- Primary Objective 1
    ScenarioInfo.M7P1 = Objectives.KillOrCapture(
        'primary',                      -- type
        'incomplete',                   -- complete
        OpStrings.OpE01_M7P1_Title,     -- title
        OpStrings.OpE01_M7P1_Desc,      -- description
        {                               -- target
            Units = {ScenarioInfo.CybranCDR},
        }
   )
    ScenarioInfo.M7P1:AddResultCallback(
        function()
--        ScenarioFramework.EndOperationCamera(ScenarioInfo.CybranCDR)

-- enemy CDR destroyed
            ScenarioFramework.CDRDeathNISCamera(ScenarioInfo.CybranCDR)

            ForkThread(KillBase)
        end
   )

    -- M7P1 Objective Reminders
    ScenarioFramework.CreateTimerTrigger(M7P1Reminder1, M7P1Time)

    -- Eastern R&D ally
    ScenarioFramework.Dialogue(OpStrings.E01_M07_020, RDAlly)

    -- After 1 minutes: Secondary Objective 1 revealed
    ScenarioFramework.CreateTimerTrigger(RevealSO1, 60)

    -- After 5 minutes: Thompson VO
    ScenarioFramework.CreateTimerTrigger(ThompsonStrategy, 300)
end

function CDRAI(platoon)
    platoon.PlatoonData.LocationType = 'Cybran_MainBase'
    platoon:PatrolLocationFactoriesAI()
end

function RDAlly()
    for _, player in ScenarioInfo.HumanPlayers do
        SetAlliance(eastResearch, player, 'Ally')
        SetAlliance(player, eastResearch, 'Ally')
    end
end

function RevealSO1()
    ScenarioFramework.Dialogue(OpStrings.E01_M07_030, AssignSO1)
end

function AssignSO1()
    -- Secondary Objective 1
    ScenarioInfo.M7S1 = Objectives.Capture(
        'secondary',                    -- type
        'incomplete',                   -- complete
        OpStrings.OpE01_M7S1_Title,     -- title
        OpStrings.OpE01_M7S1_Desc,      -- description
        {                               -- target
            NumRequired = 1,
            FlashVisible = true,
            Units = ScenarioInfo.PowerGens,
        }
   )
    ScenarioInfo.M7S1:AddResultCallback(
        function(result)
            if(result) then
--            ScenarioFramework.MidOperationCamera(ScenarioInfo.LightArtillery, true, 3)

-- Artillery Activated
                local unit = ScenarioInfo.LightArtillery
                local camInfo = {
                    blendTime = 1.0,
                    holdTime = 7.5,
                    orientationOffset = { 0.9269, 0.2, 0 },
                    positionOffset = { 0, 1, 0 },
                    zoomVal = 30,
                }
                ScenarioFramework.OperationNISCamera(unit, camInfo)

                if(ScenarioInfo.CybranCDR and not ScenarioInfo.CybranCDR:IsDead()) then
                    ScenarioFramework.Dialogue(OpStrings.E01_M07_100)
                end

                -- Activate light artillery
                ForkThread(LRAAttack)
            end
        end
   )
end

function ThompsonStrategy()
    ScenarioFramework.Dialogue(OpStrings.E01_M07_040)
end

function LRAAttack()
    while(true) do
        ScenarioInfo.LightArtillery:SetWeaponEnabledByLabel('MainGun', true)
        IssueClearCommands({ScenarioInfo.LightArtillery})
        local cmd = nil
        local num = Random(1,25)
        local targets = ScenarioFramework.GetCatUnitsInArea(categories.STRUCTURE, ScenarioUtils.AreaToRect('Target' .. num), ArmyBrains[Cybran])
        if(targets and table.getn(targets) >= 1) then
            cmd = IssueAttack({ScenarioInfo.LightArtillery}, targets[1])
        else
            for i = 1, 25 do
                targets = ScenarioFramework.GetCatUnitsInArea(categories.STRUCTURE, ScenarioUtils.AreaToRect('Target' .. i), ArmyBrains[Cybran])
                if(targets and table.getn(targets) >= 1) then
                    cmd = IssueAttack({ScenarioInfo.LightArtillery}, targets[1])
                    break
                end
            end
        end
        if(cmd) then
            while(not IsCommandDone(cmd)) do
                WaitSeconds(.5)
            end
            ScenarioInfo.LightArtillery:SetWeaponEnabledByLabel('MainGun', false)
        end
        WaitSeconds(30)
    end
end

function M7P1Reminder1()
    if(ScenarioInfo.M7P1.Active) then
        ScenarioFramework.Dialogue(OpStrings.E01_M07_160)
        ScenarioFramework.CreateTimerTrigger(M7P1Reminder2, SubsequentTime)
    end
end

function M7P1Reminder2()
    if(ScenarioInfo.M7P1.Active) then
        ScenarioFramework.Dialogue(OpStrings.E01_M07_165)
        ScenarioFramework.CreateTimerTrigger(M7P1Reminder3, SubsequentTime)
    end
end

function M7P1Reminder3()
    if(ScenarioInfo.M7P1.Active) then
        ScenarioFramework.Dialogue(OpStrings.E01_M01_060)
        ScenarioFramework.CreateTimerTrigger(M7P1Reminder1, SubsequentTime)
    end
end

-------------------
-- Attack Conditions
-------------------
function CybranLandMasterFormCondition(num)
    if ScenarioInfo.Options.Difficulty == 1 and num >= CybranNumLandChildrenD1 then
        return true
    elseif ScenarioInfo.Options.Difficulty == 2 and num >= CybranNumLandChildrenD2 then
        return true
    elseif ScenarioInfo.Options.Difficulty == 3 and num >= CybranNumLandChildrenD3 then
        return true
    else
        return false
    end
end

function CybranLandChildBuildCondition(num)
    if ScenarioInfo.Options.Difficulty == 1 and num < CybranNumLandChildrenD1 then
        return true
    elseif ScenarioInfo.Options.Difficulty == 2 and num < CybranNumLandChildrenD2 then
        return true
    elseif ScenarioInfo.Options.Difficulty == 3 and num < CybranNumLandChildrenD3 then
        return true
    else
        return false
    end
end

function CybranAirMasterFormCondition(num)
    if ScenarioInfo.Options.Difficulty == 1 and num >= CybranNumAirChildrenD1 then
        return true
    elseif ScenarioInfo.Options.Difficulty == 2 and num >= CybranNumAirChildrenD2 then
        return true
    elseif ScenarioInfo.Options.Difficulty == 3 and num >= CybranNumAirChildrenD3 then
        return true
    else
        return false
    end
end

function CybranAirChildBuildCondition(num)
    if ScenarioInfo.Options.Difficulty == 1 and num < CybranNumAirChildrenD1 then
        return true
    elseif ScenarioInfo.Options.Difficulty == 2 and num < CybranNumAirChildrenD2 then
        return true
    elseif ScenarioInfo.Options.Difficulty == 3 and num < CybranNumAirChildrenD3 then
        return true
    else
        return false
    end
end
