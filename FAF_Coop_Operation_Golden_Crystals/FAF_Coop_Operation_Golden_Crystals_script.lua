------------------------------
-- Coalition Campaign - Mission 3
--
-- Author: Shadowlorda1
------------------------------
local Objectives = import('/lua/ScenarioFramework.lua').Objectives
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local AIBuildStructures = import('/lua/ai/aibuildstructures.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local Utilities = import('/lua/Utilities.lua')
local Cinematics = import('/lua/cinematics.lua')
local Buff = import('/lua/sim/Buff.lua')
local CustomFunctions = import('/maps/FAF_Coop_Operation_Golden_Crystals/FAF_Coop_Operation_Golden_Crystals_CustomFunctions.lua')
local P1QAIAI = import('/maps/FAF_Coop_Operation_Golden_Crystals/QAIaiP1.lua')
local P2QAIAI = import('/maps/FAF_Coop_Operation_Golden_Crystals/QAIaiP2.lua')
local P3QAIAI = import('/maps/FAF_Coop_Operation_Golden_Crystals/QAIaiP3.lua')
local P4QAIAI = import('/maps/FAF_Coop_Operation_Golden_Crystals/QAIaiP4.lua')
local OpStrings = import('/maps/FAF_Coop_Operation_Golden_Crystals/FAF_Coop_Operation_Golden_Crystals_strings.lua')  
local TauntManager = import('/lua/TauntManager.lua')

QAITM = TauntManager.CreateTauntManager('QAI1TM', '/maps/FAF_Coop_Operation_Golden_Crystals/FAF_Coop_Operation_Golden_Crystals_strings.lua')

ScenarioInfo.Player1 = 1
ScenarioInfo.Civilians = 2
ScenarioInfo.QAI = 3
ScenarioInfo.Player2 = 4
ScenarioInfo.Player3 = 5
ScenarioInfo.Player4 = 6

local Difficulty = ScenarioInfo.Options.Difficulty

local Player1 = ScenarioInfo.Player1
local Civilians = ScenarioInfo.Civilians
local QAI = ScenarioInfo.QAI
local Player2 = ScenarioInfo.Player2
local Player3 = ScenarioInfo.Player3
local Player4 = ScenarioInfo.Player4

local LeaderFaction
local LocalFaction
local AIs = {QAI}
local BuffCategories = {
    BuildPower = (categories.FACTORY * categories.STRUCTURE) + categories.ENGINEER,
    Economy = categories.ECONOMIC,
}

local AssignedObjectives = {}
local ExpansionTimer = ScenarioInfo.Options.Expansion == 'true'

local P1Offmaptriggered = false
local ConvoyCounter = 0

local Debug = false

local NIS1InitialDelay = 3

function OnPopulate(scen) 
    ScenarioUtils.InitializeScenarioArmies()
    LeaderFaction, LocalFaction = ScenarioFramework.GetLeaderAndLocalFactions()
    
    ScenarioFramework.SetUEFAlly1Color(Civilians)
    ScenarioFramework.SetCybranEvilColor(QAI)
    SetArmyUnitCap(QAI, 4000)
    ScenarioFramework.SetSharedUnitCap(4000)
    
    -- Army Colors
    if(LeaderFaction == 'cybran') then
        ScenarioFramework.SetCybranPlayerColor(Player1)
    elseif(LeaderFaction == 'uef') then
        ScenarioFramework.SetUEFPlayerColor(Player1)
    elseif(LeaderFaction == 'aeon') then
        ScenarioFramework.SetAeonPlayerColor(Player1)
    end
    
    local colors = {
        ['Player2'] = {250, 250, 0}, 
        ['Player3'] = {255, 255, 255}, 
        ['Player4'] = {97, 109, 126}
    }
    local tblArmy = ListArmies()
    for army, color in colors do
        if tblArmy[ScenarioInfo[army]] then
            ScenarioFramework.SetArmyColor(ScenarioInfo[army], unpack(color))
        end
    end
    
    ScenarioUtils.CreateArmyGroup('Civilians', 'CiviliansP1')
    ScenarioUtils.CreateArmyGroup('Civilians', 'CbaseP1', true)
    ScenarioUtils.CreateArmyGroup('QAI', 'P1QOuterEco')
    ScenarioUtils.CreateArmyGroup('QAI', 'P1Crystals')
end
 
function OnStart(scen) 
    ScenarioFramework.SetPlayableArea('AREA_1', false)  
    
    for _, army in AIs do
        ArmyBrains[army].IMAPConfig = {
                OgridRadius = 0,
                IMAPSize = 0,
                Rings = 0,
        }
        ArmyBrains[army]:IMAPConfiguration()
    end

    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P1Cam1'), 0)
    ForkThread(Intro1)
end 

--Part 1 Functions

function Intro1()

    Cinematics.EnterNISMode()
    
        P1QAIAI.QAIbase1AI()
        P1QAIAI.QAIbase2AI()
    
        if (LeaderFaction == 'aeon') then
            ScenarioInfo.PlayerCDR = ScenarioFramework.SpawnCommander('Player1', 'AeonPlayer', 'Warp', true, true, PlayerDeath)
        elseif (LeaderFaction == 'cybran') then
            ScenarioInfo.PlayerCDR = ScenarioFramework.SpawnCommander('Player1', 'CybranPlayer', 'Warp', true, true, PlayerDeath)
        elseif (LeaderFaction == 'uef') then
            ScenarioInfo.PlayerCDR = ScenarioFramework.SpawnCommander('Player1', 'UEFPlayer', 'Warp', true, true, PlayerDeath)
        end

        -- spawn coop players too
        ScenarioInfo.CoopCDR = {}
        local tblArmy = ListArmies()
        coop = 1
        for iArmy, strArmy in pairs(tblArmy) do
            if iArmy >= ScenarioInfo.Player2 then
                factionIdx = GetArmyBrain(strArmy):GetFactionIndex()
                if (factionIdx == 1) then
                    ScenarioInfo.CoopCDR[coop] = ScenarioFramework.SpawnCommander(strArmy, 'UEFPlayer', 'Warp', true, true, PlayerDeath)
                elseif (factionIdx == 2) then
                    ScenarioInfo.CoopCDR[coop] = ScenarioFramework.SpawnCommander(strArmy, 'AeonPlayer', 'Warp', true, true, PlayerDeath)
                else
                    ScenarioInfo.CoopCDR[coop] = ScenarioFramework.SpawnCommander(strArmy, 'CybranPlayer', 'Warp', true, true, PlayerDeath)
                end
                coop = coop + 1
                WaitSeconds(0.5)
            end
        end
    
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P1Cam1'), 0)
    
        ScenarioFramework.Dialogue(OpStrings.IntroP1, nil, true)
        WaitSeconds(1)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P1Cam2'), 2)
        WaitSeconds(1)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P1Cam3'), 2)
        WaitSeconds(1)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P1Cam4'), 2)
        WaitSeconds(1)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P1Cam1'), 2)
    
    Cinematics.ExitNISMode()
    
    ForkThread(BuffAIEconomy)   
    ForkThread(MissionP1)
    SetupQAIM1Taunts()

    for _, player in ScenarioInfo.HumanPlayers do
    ScenarioFramework.CreateAreaTrigger(P1QOffmapattacks, 'AREA_2', categories.ALLUNITS * categories.TECH3, true, false, ArmyBrains[player], 4)
    end
end

function MissionP1()

    ScenarioInfo.MissionNumber = 1

    local function MissionNameAnnouncement()
        ScenarioFramework.SimAnnouncement(ScenarioInfo.name, "Mission by Shadowlorda1, Map improved by !MarLo")
    end

    ScenarioFramework.CreateTimerTrigger(MissionNameAnnouncement, 12)

    ScenarioInfo.M1P1 = Objectives.CategoriesInArea(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Build Tech 3 Radar',                 -- title
        'We need to locate the power signature of the crystals. A Omni radar can help.',  -- description
        'build',                         -- action
        {                               -- target
            ShowProgress = true,
            Requirements = {
                {   
                    Area = 'AREA_1',
                    Category = categories.STRUCTURE * categories.TECH3 * categories.OMNI,
                    CompareOp = '>=',
                    Value = 1,
                    Armies = {'HumanPlayers'},
                }, 
            },
        }
    )
    ScenarioInfo.M1P1:AddResultCallback(
    function(result)
            if(result) then
                ForkThread(StartIntroP2)
            end
        end
    )
    
    ScenarioFramework.CreateArmyIntelTrigger(SecondaryMissionP1, ArmyBrains[Player1], 'LOSNow', false, true,  categories.FACTORY, true, ArmyBrains[QAI] )   

    if ExpansionTimer then
        local M1MapExpandDelay = {45*60, 35*60, 28*60}
        ScenarioFramework.CreateTimerTrigger(StartIntroP2, M1MapExpandDelay[Difficulty])
    end
end

function SecondaryMissionP1()

    ScenarioFramework.Dialogue(OpStrings.Secondary1P1, nil, true)

    ScenarioInfo.M1P1S1 = Objectives.CategoriesInArea(
        'secondary',                      -- type
        'incomplete',                   -- complete
        'Destroy the Cybran Bases',                 -- title
        'You are surrounded by Cybran forces clear them out.',  -- description
        'kill',                         -- action
        {                               -- target
            MarkUnits = true,
            ShowProgress = true,
            ShowFaction = 'Cybran',
            Requirements = {
                {   
                    Area = 'objsec1',
                    Category = categories.FACTORY + categories.ECONOMIC * categories.TECH2,
                    CompareOp = '<=',
                    Value = 0,
                    ArmyIndex = QAI,
                },
                {   
                    Area = 'objsec2',
                    Category = categories.FACTORY + categories.ECONOMIC * categories.TECH2,
                    CompareOp = '<=',
                    Value = 0,
                    ArmyIndex = QAI,
                },
            },
        }
    )
    
    ScenarioInfo.M1P1S1:AddResultCallback(
        function(result)
            if result then
                ScenarioFramework.Dialogue(OpStrings.Secondary1endP1, nil, true)
            end
        end
    )    
end

function P1QOffmapattacks()
    if (not P1Offmaptriggered) then
        P1Offmaptriggered = true
        WaitSeconds(60)   
        while ScenarioInfo.MissionNumber == 1 or ScenarioInfo.MissionNumber == 2 do
        local attackGroups = {
            'P1QOffmapattack1',
            'P1QOffmapattack2',
            'P1QOffmapattack3',
        }
        attackGroups.num = table.getn(attackGroups)

            platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', attackGroups[Random(1, attackGroups.num)] .. '_D' .. Difficulty, 'GrowthFormation')
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P1QOffmapattack' .. Random(1, 3))

            WaitSeconds(Random(120, 240))
        end
    end
end

--Part 2 Functions

function StartIntroP2()

    ForkThread(IntroP2)
end

function IntroP2()
    if ScenarioInfo.MissionNumber ~= 1 then
        return
    end
    ScenarioInfo.MissionNumber = 2

    WaitSeconds(3)

    ScenarioFramework.SetPlayableArea('AREA_2', true)   
    
    P2QAIAI.QAIP2base1AI()
    P2QAIAI.QAIP2base2AI()
    
    ScenarioInfo.P2Gate = ScenarioUtils.CreateArmyUnit('QAI', 'P2Gate')
    ScenarioUtils.CreateArmyGroup('QAI', 'P2Depots' )
    ScenarioUtils.CreateArmyGroup('QAI', 'P2QOutDefenses_D'.. Difficulty)
    ScenarioUtils.CreateArmyGroup('QAI', 'P2Qwalls')
    ScenarioUtils.CreateArmyGroup('QAI', 'P2Crystals')

    Cinematics.EnterNISMode()
        Cinematics.SetInvincible('AREA_1')

        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P1Cam1'), 0)
        local VisMarker1_1 = ScenarioFramework.CreateVisibleAreaLocation(50, 'P2Vision1', 0, ArmyBrains[Player1])
        local VisMarker1_2 = ScenarioFramework.CreateVisibleAreaLocation(50, 'P2Vision2', 0, ArmyBrains[Player1])
        ScenarioFramework.Dialogue(OpStrings.IntroP2, nil, true)
        WaitSeconds(1)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P2Cam1'), 3)
        WaitSeconds(3)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P2Cam2'), 3)
        WaitSeconds(4)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P1Cam1'), 3)
    
        ForkThread(
            function()
                WaitSeconds(2)
                    VisMarker1_1:Destroy()
                    VisMarker1_2:Destroy()
                    WaitSeconds(1)
                    ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('P2Vision1'), 60)
                    ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('P2Vision2'), 60)

            end
        )
        Cinematics.SetInvincible('AREA_1', true)
    Cinematics.ExitNISMode()
    
    local ConvyTrigger0 = {5*60, 4*60, 1*60}
    ScenarioFramework.CreateTimerTrigger(Convoy1, ConvyTrigger0[Difficulty])
    ForkThread(CounterAttackP2)
    ForkThread(MissionP2)
    ForkThread(MissionSecondaryP2)
    ForkThread(EnableStealthOnAir)
    SetupQAIM2Taunts()
end

function TeleportOut(unit)

    ScenarioFramework.FakeTeleportUnit(unit, true)
    ConvoyCounter = ConvoyCounter + 1
    ForkThread(Missionfailcheck)
end

function Convoy1()
    if ScenarioFramework.NumCatUnitsInArea(categories.STRUCTURE * categories.CIVILIAN, 'P2objsec1', ArmyBrains[QAI]) > 0 then
        ScenarioInfo.Convoy1 = {}
        ScenarioFramework.Dialogue(OpStrings.ConvoySpawnP2, nil, true)
        local Convoy1 = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'P2Convoy1', 'GrowthFormation')
        ScenarioFramework.PlatoonMoveChain(Convoy1, 'P2QConvoys2')
        ScenarioFramework.CreateGroupDeathTrigger(ConvoyDestroyed, Convoy1)

        for k, v in Convoy1:GetPlatoonUnits() do
            ScenarioFramework.CreateUnitToMarkerDistanceTrigger(TeleportOut, v, ScenarioUtils.MarkerToPosition( 'ConvoyMK' ), 10)
        end

        local ConvyTrigger1 = {5*60, 4*60, 3*60}
        ScenarioFramework.CreateTimerTrigger(Convoy2, ConvyTrigger1[Difficulty])
    
         ------------------------------------------------
        -- Secondary Objective 1 - Capture Control Center
        ------------------------------------------------
        ScenarioInfo.M2P2 = Objectives.Basic(
            'primary',                            -- type
            'incomplete',                           -- status
            'Destroy the Convoys',                -- title
            'We can not allow the crystal to get off world.', -- description
            Objectives.GetActionIcon('kill'),
            {                                       -- target
                FlashVisible = true,
                MarkUnits = true,
                Units = Convoy1:GetPlatoonUnits(),
            }
    )
    else
        ScenarioFramework.CreateTimerTrigger(Convoy2, 10)
    end
end

function Convoy2()
    if ScenarioInfo.M7P2.Active then
        if ScenarioFramework.NumCatUnitsInArea(categories.STRUCTURE * categories.CIVILIAN, 'P2objsec2', ArmyBrains[QAI]) > 0 then

            ScenarioInfo.Convoy2 = {}
            ScenarioFramework.Dialogue(OpStrings.ConvoySpawnP2, nil, true)
            local Convoy2 = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'P2Convoy2', 'AttackFormation')
            ScenarioFramework.PlatoonPatrolChain(Convoy2, 'P2QConvoys1')
            ScenarioFramework.CreateGroupDeathTrigger(ConvoyDestroyed, Convoy2)

            for k, v in Convoy2:GetPlatoonUnits() do
                ScenarioFramework.CreateUnitToMarkerDistanceTrigger(TeleportOut, v, ScenarioUtils.MarkerToPosition( 'ConvoyMK' ), 10)
            end

            local ConvyTrigger2 = {5*60, 4*60, 3*60}
            ScenarioFramework.CreateTimerTrigger(Convoy3, ConvyTrigger2[Difficulty])
            
            for k, v in Convoy2:GetPlatoonUnits() do
                ScenarioInfo.M2P2:AddBasicUnitTarget(v)
            end
        else
            ScenarioFramework.CreateTimerTrigger(Convoy3, 10)
        end
    end
end

function Convoy3()
    if ScenarioInfo.M7P2.Active then
        if ScenarioFramework.NumCatUnitsInArea(categories.STRUCTURE * categories.CIVILIAN, 'P2objsec2', ArmyBrains[QAI]) > 0 then

            ScenarioInfo.Convoy3 = {}
            ScenarioFramework.Dialogue(OpStrings.ConvoySpawnP2, nil, true)
            local Convoy3 = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'P2Convoy3', 'AttackFormation')
            ScenarioFramework.PlatoonPatrolChain(Convoy3, 'P2QConvoys1')
            ScenarioFramework.CreateGroupDeathTrigger(ConvoyDestroyed, Convoy3)

            for k, v in Convoy3:GetPlatoonUnits() do
                ScenarioFramework.CreateUnitToMarkerDistanceTrigger(TeleportOut, v, ScenarioUtils.MarkerToPosition( 'ConvoyMK' ), 10)
            end

            local ConvyTrigger3 = {5*60, 4*60, 3*60}
            ScenarioFramework.CreateTimerTrigger(Convoy4, ConvyTrigger3[Difficulty])
            
            for k, v in Convoy3:GetPlatoonUnits() do
                ScenarioInfo.M2P2:AddBasicUnitTarget(v)
            end

        else
            ScenarioFramework.CreateTimerTrigger(Convoy4, 10)
        end
    end
end

function Convoy4()
    if ScenarioInfo.M7P2.Active then
        if ScenarioFramework.NumCatUnitsInArea(categories.STRUCTURE * categories.CIVILIAN, 'P2objsec1', ArmyBrains[QAI]) > 0 then

            ScenarioInfo.Convoy4 = {}
            ScenarioFramework.Dialogue(OpStrings.ConvoySpawnP2, nil, true)
            local Convoy4 = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'P2Convoy4', 'AttackFormation')
            ScenarioFramework.PlatoonPatrolChain(Convoy4, 'P2QConvoys2')
            ScenarioFramework.CreateGroupDeathTrigger(ConvoyDestroyed, Convoy4)
    
            for k, v in Convoy4:GetPlatoonUnits() do
                ScenarioFramework.CreateUnitToMarkerDistanceTrigger(TeleportOut, v, ScenarioUtils.MarkerToPosition( 'ConvoyMK' ), 10)
            end

            local ConvyTrigger4 = {5*60, 4*60, 3*60}
            ScenarioFramework.CreateTimerTrigger(Convoy5, ConvyTrigger4[Difficulty])
    
            for k, v in Convoy4:GetPlatoonUnits() do
                ScenarioInfo.M2P2:AddBasicUnitTarget(v)
            end

        else
            ScenarioFramework.CreateTimerTrigger(Convoy5, 10)
        end
    end
end

function Convoy5()
    if ScenarioInfo.M7P2.Active then
        if ScenarioFramework.NumCatUnitsInArea(categories.STRUCTURE * categories.CIVILIAN, 'P2objsec2', ArmyBrains[QAI]) > 0 then

            ScenarioInfo.Convoy5 = {}
            ScenarioFramework.Dialogue(OpStrings.ConvoySpawnP2, nil, true)
            local Convoy4 = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'P2Convoy5', 'AttackFormation')
            ScenarioFramework.PlatoonPatrolChain(Convoy5, 'P2QConvoys1')
            ScenarioFramework.CreateGroupDeathTrigger(ConvoyDestroyed, Convoy5)
    
            for k, v in Convoy5:GetPlatoonUnits() do
                ScenarioFramework.CreateUnitToMarkerDistanceTrigger(TeleportOut, v, ScenarioUtils.MarkerToPosition( 'ConvoyMK' ), 10)
            end

            local ConvyTrigger5 = {5*60, 4*60, 3*60}
            ScenarioFramework.CreateTimerTrigger(Convoy6, ConvyTrigger5[Difficulty])
    
            for k, v in Convoy5:GetPlatoonUnits() do
                ScenarioInfo.M2P2:AddBasicUnitTarget(v)
            end

        else
            ScenarioFramework.CreateTimerTrigger(Convoy6, 10)
        end
    end
end

function Convoy6()
    if ScenarioInfo.M7P2.Active then
        if ScenarioFramework.NumCatUnitsInArea(categories.STRUCTURE * categories.CIVILIAN, 'P2objsec1', ArmyBrains[QAI]) > 0 then

            ScenarioInfo.Convoy6 = {}
            ScenarioFramework.Dialogue(OpStrings.ConvoySpawnP2, nil, true)
            local Convoy4 = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'P2Convoy6', 'AttackFormation')
            ScenarioFramework.PlatoonPatrolChain(Convoy6, 'P2QConvoys1')
            ScenarioFramework.CreateGroupDeathTrigger(ConvoyDestroyed, Convoy6)
    
            for k, v in Convoy6:GetPlatoonUnits() do
                ScenarioFramework.CreateUnitToMarkerDistanceTrigger(TeleportOut, v, ScenarioUtils.MarkerToPosition( 'ConvoyMK' ), 10)
            end

            local ConvyTrigger6 = {5*60, 4*60, 3*60}
            ScenarioFramework.CreateTimerTrigger(Convoy7, ConvyTrigger6[Difficulty])
    
            for k, v in Convoy6:GetPlatoonUnits() do
                ScenarioInfo.M2P2:AddBasicUnitTarget(v)
            end

        else
            ScenarioFramework.CreateTimerTrigger(Convoy7, 10)
        end
    end
end

function Convoy7()
   if ScenarioInfo.M7P2.Active then

        ScenarioInfo.Convoy7 = {}
        ScenarioFramework.Dialogue(OpStrings.ConvoySpawnP2, nil, true)
        local Convoy5 = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'P2Convoy7', 'AttackFormation')
        ScenarioFramework.PlatoonPatrolChain(Convoy7, 'P2QConvoys3')
        ScenarioFramework.CreateGroupDeathTrigger(Endconvoys, Convoy7)
    
        for k, v in Convoy7:GetPlatoonUnits() do
            ScenarioFramework.CreateUnitToMarkerDistanceTrigger(TeleportOut, v, ScenarioUtils.MarkerToPosition( 'ConvoyMK' ), 10)
        end

        for k, v in Convoy7:GetPlatoonUnits() do
            ScenarioInfo.M2P2:AddBasicUnitTarget(v)
        end
    end
end

function Endconvoys()
    
    ScenarioInfo.M2P2:ManualResult(true)
end

function ConvoyDestroyed()

    ScenarioFramework.Dialogue(OpStrings.ConvoyDeathP2, nil, true)
end

function MissionP2()
    local quantity = {}
    quantity = {18, 14, 10}

    ScenarioInfo.M7P2 = Objectives.Kill(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Destroy the Gate',                -- title
        'If '..quantity[Difficulty]..' Trucks escape this mission is a loss. destroy the convoys as they appear or the gate.', -- description
        {                              -- target
            MarkUnits = true,
            Units = {ScenarioInfo.P2Gate}  
        }
    )
    ScenarioInfo.M7P2:AddResultCallback(
        function(result)
            if result then
                ForkThread(StartIntroP3)  
            else
                PlayerLose()
            end
        end
    )

    if ExpansionTimer then
        local M2MapExpandDelay = {45*60, 35*60, 25*60}
        ScenarioFramework.CreateTimerTrigger(StartIntroP3, M2MapExpandDelay[Difficulty])
    end
end

function MissionSecondaryP2()

    WaitSeconds(30)
    
    ScenarioFramework.Dialogue(OpStrings.Secondary1P2, nil, true)

    ScenarioInfo.M1P1S1 = Objectives.CategoriesInArea(
        'secondary',                      -- type
        'incomplete',                   -- complete
        'Destroy the Cybran Depots',                 -- title
        'Destroying the storage depots will prevent more getting off world.',  -- description
        'kill',                         -- action
        {                               -- target
            MarkUnits = true,
            ShowProgress = true,
            Requirements = {
                {   
                    Area = 'P2objsec1',
                    Category = categories.urc1501,
                    CompareOp = '<=',
                    Value = 0,
                    ArmyIndex = QAI,
                },
                {   
                    Area = 'P2objsec2',
                    Category = categories.urc1501,
                    CompareOp = '<=',
                    Value = 0,
                    ArmyIndex = QAI,
                },
            },
        }
    )
    
    ScenarioInfo.M1P1S1:AddResultCallback(
        function(result)
            if result then
                ScenarioFramework.Dialogue(OpStrings.Secondary1endP2, nil, true)
            end
        end
    )
end

function CounterAttackP2()
    local quantity = {}
    local trigger = {}
    local platoon

    -- sends Gunships if player has more than [60, 50, 40] Tech 2 and Tech 3 Units, up to 10, 1 group per 14, 11, 10
    num = ScenarioFramework.GetNumOfHumanUnits(categories.ALLUNITS - categories.TECH1)
    quantity = {150, 100, 50}
    trigger = {40, 30, 20}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 5) then
            num = 5
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('QAI', 'P2QGunships', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P2QIntattack' .. Random(1, 3))
        end
    end

    -- sends Gunships if player has more than [60, 50, 40] Units, up to 10, 1 group per 14, 11, 10
    num = ScenarioFramework.GetNumOfHumanUnits(categories.ALLUNITS - categories.WALL)
    quantity = {200, 200, 100}
    trigger = {40, 35, 30}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 6) then
            num = 6
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('QAI', 'P2QBombers', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P2QIntattack' .. Random(1, 3))
        end
    end

    -- sends ASF if player has more than [30, 20, 10] Air, up to 3, 1 group per 3, 2, 1
    num = ScenarioFramework.GetNumOfHumanUnits(categories.AIR * categories.MOBILE)
    quantity = {30, 20, 10}
    trigger = {20, 15, 10}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 5) then
            num = 5
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('QAI', 'P2QFighters', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P2QIntattack' .. Random(1, 3))
        end
    end

    for i = 1, 2 do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('QAI', 'P2QUnits' .. i .. '_D' .. Difficulty, 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P2QIntattack' .. i)
        end

    for i = 1, 4 do
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('QAI', 'P2QTransport', 'GrowthFormation', 5)
        CustomFunctions.PlatoonAttackWithTransports(platoon, 'P2QDrop', 'P2QDropattack','DeleteMK', true)
    end   
end

function Missionfailcheck()
    local quantity = {}
   
    quantity = {18, 14, 10}
    if (ConvoyCounter == quantity[Difficulty]) then
     ScenarioInfo.M7P2:ManualResult(false)
    end
end

function EnableStealthOnAir()
    local T3AirUnits = {}
    while true do
        for _, v in ArmyBrains[QAI]:GetListOfUnits(categories.ura0303 + categories.ura0304 + categories.ura0401, false) do
            if not ( T3AirUnits[v:GetEntityId()] or v:IsBeingBuilt() ) then
                v:ToggleScriptBit('RULEUTC_StealthToggle')
                T3AirUnits[v:GetEntityId()] = true
            end
        end
        WaitSeconds(10)
    end
end

---part 3 functions
    
function StartIntroP3()

    ForkThread(IntroP3)
end

function IntroP3()
    ScenarioFramework.FlushDialogueQueue()
    while ScenarioInfo.DialogueLock do
        WaitSeconds(0.2)
    end
    if ScenarioInfo.MissionNumber ~= 2 then
        return
    end
    ScenarioInfo.MissionNumber = 3

    if  ScenarioInfo.M2P2.Active then
        ScenarioInfo.M2P2:ManualResult(true)
    end

    WaitSeconds(3)

    ScenarioFramework.SetPlayableArea('AREA_3', true)  

    P3QAIAI.QAIP3base1AI()
    P3QAIAI.QAIP3base2AI()
    P3QAIAI.QAIP3base3AI()

    ScenarioUtils.CreateArmyGroup('Civilians', 'CbaseP3', true)
    ScenarioInfo.P3Admin = ScenarioUtils.CreateArmyUnit('Civilians', 'P3Admin')
    ScenarioInfo.P3Admin:SetCustomName("Central Administration")
    ScenarioInfo.P3Admin:SetReclaimable(false)
    ScenarioInfo.P3Admin:SetCapturable(true)
    ScenarioInfo.P3Admin:SetCanTakeDamage(false)
    ScenarioInfo.P3Admin:SetCanBeKilled(false)
    ScenarioInfo.P3Admin:SetDoNotTarget(true)

    ScenarioInfo.P3Satillite = ScenarioUtils.CreateArmyUnit('Civilians', 'P3Satillite')
    ScenarioInfo.P3Satillite:SetReclaimable(false)
    ScenarioInfo.P3Satillite:SetCapturable(false)
    ScenarioInfo.P3Satillite:SetCanTakeDamage(false)
    ScenarioInfo.P3Satillite:SetCanBeKilled(false)
    ScenarioInfo.P3Satillite:SetDoNotTarget(true)
    
    ScenarioInfo.P3QACU2 = ScenarioFramework.SpawnCommander('QAI', 'P3QACU1', false, 'QAI Drone', true, false,
    {'MicrowaveLaserGenerator', 'StealthGenerator', 'CloakingGenerator', 'T3Engineering'})
    ScenarioInfo.P3QACU2:SetAutoOvercharge(true)
    ScenarioInfo.P3QACU2:SetVeterancy(1 + Difficulty)

    ScenarioInfo.P3QACU1 = ScenarioFramework.SpawnCommander('QAI', 'P3QACU2', false, 'QAI Drone', true, false,
    {'MicrowaveLaserGenerator', 'StealthGenerator', 'CloakingGenerator', 'CoolingUpgrade'})
    ScenarioInfo.P3QACU1:SetAutoOvercharge(true)
    ScenarioInfo.P3QACU1:SetVeterancy(1 + Difficulty)

    ScenarioInfo.P2Arty1 = ScenarioUtils.CreateArmyGroup('QAI', 'P3QArty1')
    ScenarioInfo.P3Arty2 = ScenarioUtils.CreateArmyGroup('QAI', 'P3QArty5')
    ScenarioUtils.CreateArmyGroup('QAI', 'P3QOuterD_D'.. Difficulty)
    ScenarioUtils.CreateArmyGroup('QAI', 'P3QWalls')
    ScenarioUtils.CreateArmyGroup('QAI', 'P3Crystals')

    Cinematics.EnterNISMode()
        Cinematics.SetInvincible('AREA_1')

        local units = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'P3QB1Airpatrol_D'.. Difficulty, 'GrowthFormation')
        for _, v in units:GetPlatoonUnits() do
            ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P3QB1Airdefense1')))
        end
    
        units = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'P3QB2Airpatrol_D'.. Difficulty, 'GrowthFormation')
        for _, v in units:GetPlatoonUnits() do
            ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P3QB2Airdefense1')))
        end

        units = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'P3QB3Airpatrol_D'.. Difficulty, 'GrowthFormation')
        for _, v in units:GetPlatoonUnits() do
            ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P3QB3Airdefense1')))
        end
    
        local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'P3QIntLandattack1_D'.. Difficulty, 'AttackFormation')
        ScenarioFramework.PlatoonPatrolChain(platoon, 'P3QIntattack1')
    
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'P3QIntLandattack2_D'.. Difficulty, 'AttackFormation')
        ScenarioFramework.PlatoonPatrolChain(platoon, 'P3QIntattack2')

        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P3Cam1'), 0)
        local VisMarker3_1 = ScenarioFramework.CreateVisibleAreaLocation(60, 'P3Vision1', 0, ArmyBrains[Player1])
        local VisMarker3_2 = ScenarioFramework.CreateVisibleAreaLocation(50, 'P3Vision2', 0, ArmyBrains[Player1])
        local VisMarker3_3 = ScenarioFramework.CreateVisibleAreaLocation(80, 'P3Vision3', 0, ArmyBrains[Player1])
        ScenarioFramework.Dialogue(OpStrings.IntroP3, nil, true)
        WaitSeconds(1)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P3Cam1'), 3)
        WaitSeconds(2)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P3Cam2'), 3)
        WaitSeconds(3)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P3Cam3'), 3)
        WaitSeconds(2)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P3Cam4'), 3)
        WaitSeconds(2)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P1Cam1'), 3)
        WaitSeconds(1)
    
        ForkThread(
            function()
                WaitSeconds(2)
                    VisMarker3_1:Destroy()
                    VisMarker3_2:Destroy()
                    VisMarker3_3:Destroy()
                    WaitSeconds(1)
                    ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('P3Vision1'), 70)
                    ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('P3Vision2'), 60)
                    ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('P3Vision3'), 90)

            end
        )
        Cinematics.SetInvincible('AREA_1', true)
    Cinematics.ExitNISMode()  

    ForkThread(MissionP3)
    ForkThread(MissionSecondaryP3)
    ForkThread(CounterAttackP3)
    ForkThread(P3T3Arty)
    ScenarioFramework.CreateTimerTrigger(Nukeparty, 90)
    SetupQAIM3Taunts() 
end

function P3T3Arty()

    AIBuildStructures.CreateBuildingTemplate( ArmyBrains[QAI], 'QAI', 'QAIArtybase1' )
    AIBuildStructures.AppendBuildingTemplate(ArmyBrains[QAI], 'QAI', 'P3QArty2', 'QAIArtybase1')
    
    plat = ScenarioUtils.CreateArmyGroupAsPlatoon( 'QAI', 'P3Qeng1', 'NoFormation' )
    plat.PlatoonData.MaintainBaseTemplate = 'QAIArtybase1'
    plat.PlatoonData.PatrolChain = 'P3QENG1'
    plat:ForkAIThread(ScenarioPlatoonAI.StartBaseEngineerThread)

    AIBuildStructures.CreateBuildingTemplate( ArmyBrains[QAI], 'QAI', 'QAIArtybase2' )
    AIBuildStructures.AppendBuildingTemplate(ArmyBrains[QAI], 'QAI', 'P3QArty3', 'QAIArtybase2')
    
    plat = ScenarioUtils.CreateArmyGroupAsPlatoon( 'QAI', 'P3Qeng2', 'NoFormation' )
    plat.PlatoonData.MaintainBaseTemplate = 'QAIArtybase2'
    plat.PlatoonData.PatrolChain = 'P3QENG2'
    plat:ForkAIThread(ScenarioPlatoonAI.StartBaseEngineerThread)

    AIBuildStructures.CreateBuildingTemplate( ArmyBrains[QAI], 'QAI', 'QAIArtybase3' )
    AIBuildStructures.AppendBuildingTemplate(ArmyBrains[QAI], 'QAI', 'P3QArty4', 'QAIArtybase3')
    
    plat = ScenarioUtils.CreateArmyGroupAsPlatoon( 'QAI', 'P3Qeng3', 'NoFormation' )
    plat.PlatoonData.MaintainBaseTemplate = 'QAIArtybase3'
    plat.PlatoonData.PatrolChain = 'P3QENG3'
    plat:ForkAIThread(ScenarioPlatoonAI.StartBaseEngineerThread)
end

function MissionP3()

    ScenarioInfo.M1P3 = Objectives.Kill(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Destroy Western QAI ACU',                -- title
        'We detect two ACUs to your north, destroy them.', -- description
        {                              -- target
            MarkUnits = true,
            Units = {ScenarioInfo.P3QACU1},   
        }
    )
    
    ScenarioInfo.M2P3 = Objectives.Kill(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Destroy Eastern QAI ACU',                -- title
        'We detect two ACUs to your north, destroy them.', -- description
        {                              -- target
            MarkUnits = true,
            Units = {ScenarioInfo.P3QACU2},   
        }
    )

    ScenarioInfo.M3Objectives = Objectives.CreateGroup('M3Objectives', StartIntroP4)
    ScenarioInfo.M3Objectives:AddObjective(ScenarioInfo.M2P3)
    ScenarioInfo.M3Objectives:AddObjective(ScenarioInfo.M1P3)
    if ScenarioInfo.M7P2.Active then
        ScenarioInfo.M3Objectives:AddObjective(ScenarioInfo.M7P2)
    end

    if ExpansionTimer then
        local M3MapExpandDelay = {45*60, 35*60, 25*60}
        ScenarioFramework.CreateTimerTrigger(StartIntroP4, M3MapExpandDelay[Difficulty])
    end
end

function MissionSecondaryP3()

    WaitSeconds(90)

    ScenarioFramework.Dialogue(OpStrings.Secondary1P3, nil, true)

    ScenarioInfo.M1S1P3 = Objectives.Capture(
        'secondary',                      -- type
        'incomplete',                   -- complete
        'Capture the Control Center',                -- title
        'The Central Command Structure for the mining operation is still intact, capture it.', -- description
        {                              -- target
            MarkUnits = true,
            ShowProgress = true,
            Units = {ScenarioInfo.P3Admin}, 
        }
    )
    ScenarioInfo.M1S1P3:AddResultCallback(
        function(result, units)
            if result then
                local newHandle = units[1]
                ScenarioFramework.Dialogue(OpStrings.Secondary1endP3, nil, true)

                
                ScenarioInfo.P3Admin = newHandle
                ScenarioInfo.P3Admin:SetCustomName("Central Administration")
                ScenarioInfo.P3Admin:SetReclaimable(false)
                ScenarioInfo.P3Admin:SetCapturable(true)

                ScenarioFramework.GiveUnitToArmy(ScenarioInfo.P3Satillite, Player1)
                ForkThread(MissionSecondary2P3)

            end
        end
    ) 
end

function MissionSecondary2P3()

    ScenarioInfo.S2P3 = Objectives.Protect(
        'secondary',                      -- type
        'incomplete',                   -- complete
        'Protect the Control Center',                -- title
        'The Central Command Structure for the mining operation is still intact, Protect it.', -- description
        {                              -- target
            MarkUnits = true,
            ShowProgress = true,
            Units = {ScenarioInfo.P3Admin}, 
        }
    )
    ScenarioInfo.S2P3:AddResultCallback(
        function(result)
            if (not result) then
                ScenarioFramework.Dialogue(OpStrings.Secondary2FailP3, nil, true)
            else
                ScenarioFramework.Dialogue(OpStrings.Secondary2endP3, nil, true)

                local ARTY = ScenarioFramework.GetCatUnitsInArea((categories.ALLUNITS), 'AREA_4', ArmyBrains[Civilians])
                for k, v in ARTY do
                    if v and not v:IsDead() and (v:GetAIBrain() == ArmyBrains[Civilians]) then
                        ScenarioFramework.GiveUnitToArmy( v, Player1 )
                    end
                end
            end
        end
    ) 
end

function CounterAttackP3()
    local quantity = {}
    local trigger = {}
    local platoon

    -- sends Gunships if player has more than [60, 50, 40] Units, up to 10, 1 group per 14, 11, 10
    num = ScenarioFramework.GetNumOfHumanUnits(categories.ALLUNITS - categories.WALL)
    quantity = {200, 150, 100}
    trigger = {90, 70, 50}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 10) then
            num = 10
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('QAI', 'P3QGunships', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P3Intattack' .. Random(1, 4))
        end
    end

    -- sends Gunships if player has more than [60, 50, 40] Units, up to 10, 1 group per 14, 11, 10
    num = ScenarioFramework.GetNumOfHumanUnits(categories.ALLUNITS - categories.TECH1)
    quantity = {250, 200, 150}
    trigger = {70, 60, 50}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 8) then
            num = 8
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('QAI', 'P3QBomber', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P3Intattack' .. Random(1, 4))
        end
    end

    -- sends ASF if player has more than [30, 20, 10] Air, up to 5, 1 group per 10, 20, 30
    num = ScenarioFramework.GetNumOfHumanUnits(categories.AIR * categories.MOBILE)
    quantity = {30, 20, 10}
    trigger = {20, 15, 10}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 8) then
            num = 8
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('QAI', 'P3QFighter', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P3Intattack' .. Random(1, 4))
        end
    end

    local LandExp = ScenarioFramework.GetListOfHumanUnits(categories.EXPERIMENTAL * categories.LAND)
    local num = table.getn(LandExp)

    if num > 0 then
            quantity = {4, 3, 2}
            if num > quantity[Difficulty] then
                num = num
            end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('QAI', 'P3QBomber', 'GrowthFormation', 5)
            IssueAttack(platoon:GetPlatoonUnits(), LandExp[i])
            IssueAggressiveMove(platoon:GetPlatoonUnits(), ScenarioUtils.MarkerToPosition('Player1'))
        end
    end

    local AirExp = ScenarioFramework.GetListOfHumanUnits(categories.EXPERIMENTAL * categories.AIR)
    local num = table.getn(AirExp)
    
    if num > 0 then
            quantity = {4, 3, 2}
            if num > quantity[Difficulty] then
                num = num
            end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('QAI', 'P3QFighter', 'GrowthFormation', 5)
            IssueAttack(platoon:GetPlatoonUnits(), AirExp[i])
            IssueAggressiveMove(platoon:GetPlatoonUnits(), ScenarioUtils.MarkerToPosition('Player1'))
        end
    end

    -- sends ASF if player has more than [30, 20, 10] Air, up to 5, 1 group per 10, 20, 30
    num = ScenarioFramework.GetNumOfHumanUnits(categories.EXPERIMENTAL * categories.MOBILE)
    quantity = {3, 2, 1}
    trigger = {3, 2, 1}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 4) then
            num = 4
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('QAI', 'P3QBug', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P3Intattack' .. i)
        end
    end
end

function Nukeparty()

    local QAINuke1 = ArmyBrains[QAI]:GetListOfUnits(categories.urb2305, false)
    local plat = ArmyBrains[QAI]:MakePlatoon('', '')
        ArmyBrains[QAI]:AssignUnitsToPlatoon(plat, {QAINuke1[1]}, 'Attack', 'NoFormation')
        plat:ForkAIThread(plat.NukeAI)
end

--Part 4 functions

function StartIntroP4()

    ForkThread(IntroP4)
end

function IntroP4()
    if ScenarioInfo.MissionNumber ~= 3 then
        return
    end
    ScenarioInfo.MissionNumber = 4

    WaitSeconds(5)

    ScenarioFramework.SetPlayableArea('AREA_4', true)   
    
    P4QAIAI.QAIP4base1AI()
    P4QAIAI.QAIP4base2AI()
    P4QAIAI.QAIP4base3AI()
    P4QAIAI.QAIP4base4AI()
    P4QAIAI.QAIP4base5AI()
    P4QAIAI.QAIP4base6AI()
    ScenarioUtils.CreateArmyGroup('QAI', 'P4QWalls')
    ScenarioUtils.CreateArmyGroup('QAI', 'P4Crystals')
    ScenarioUtils.CreateArmyGroup('QAI', 'P4QOuter')
    
    ScenarioInfo.P4Gate1 = ScenarioUtils.CreateArmyUnit('QAI', 'P4QACUF1')
    ScenarioInfo.P4Gate1:SetMaxHealth(100000)             
    ScenarioInfo.P4Gate1:SetHealth(ScenarioInfo.P4Gate1, 100000)

    ScenarioInfo.P4Gate2 = ScenarioUtils.CreateArmyUnit('QAI', 'P4QACUF2')
    ScenarioInfo.P4Gate2:SetMaxHealth(100000)             
    ScenarioInfo.P4Gate2:SetHealth(ScenarioInfo.P4Gate2, 100000)

    ScenarioInfo.P4Gate3 = ScenarioUtils.CreateArmyUnit('QAI', 'P4QACUF3')
    ScenarioInfo.P4Gate3:SetMaxHealth(100000)             
    ScenarioInfo.P4Gate3:SetHealth(ScenarioInfo.P4Gate3, 100000)

    ScenarioUtils.CreateArmyGroup('QAI', 'P4QACUFACsuport')
    ScenarioUtils.CreateArmyGroup('QAI', 'P4QFACdefense1_D'.. Difficulty)
    ScenarioUtils.CreateArmyGroup('QAI', 'P4QFACdefense2_D'.. Difficulty)
    ScenarioUtils.CreateArmyGroup('QAI', 'P4QFACdefense3_D'.. Difficulty)

    ScenarioUtils.CreateArmyGroup('Civilians', 'P4Artybase1')
    ScenarioUtils.CreateArmyGroup('Civilians', 'P4Artybase2')

    ArmyBrains[QAI]:GiveResource('MASS', 600000)
    ArmyBrains[QAI]:GiveResource('ENERGY', 900000)

    local Antinukes = ArmyBrains[QAI]:GetListOfUnits(categories.urb4302, false)
    for _, v in Antinukes do
        v:GiveTacticalSiloAmmo(4)
    end

    local ACUPlatoon1 = ArmyBrains[QAI]:MakePlatoon('', '')
    local ACUPlatoon2 = ArmyBrains[QAI]:MakePlatoon('', '')
    local ACUPlatoon3 = ArmyBrains[QAI]:MakePlatoon('', '')
    local ACUPlatoon4 = ArmyBrains[QAI]:MakePlatoon('', '')
    local ACUPlatoon5 = ArmyBrains[QAI]:MakePlatoon('', '')

    local units = ScenarioFramework.SpawnCommander('QAI', 'SDrone1', false, 'QAI Drone', false, false,
    {'MicrowaveLaserGenerator','StealthGenerator', 'CloakingGenerator', 'T3Engineering'})
    
    units1 = ScenarioFramework.SpawnCommander('QAI', 'SDrone2', false, 'QAI Drone', false, false,
    {'MicrowaveLaserGenerator','StealthGenerator', 'CloakingGenerator', 'T3Engineering'})

    ArmyBrains[QAI]:AssignUnitsToPlatoon(ACUPlatoon1, {units}, 'Attack', 'AttackFormation')
    ArmyBrains[QAI]:AssignUnitsToPlatoon(ACUPlatoon1, {units1}, 'Attack', 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(ACUPlatoon1, 'P4Intattack1')

    units2 = ScenarioFramework.SpawnCommander('QAI', 'SDrone3', false, 'QAI Drone', false, false,
    {'MicrowaveLaserGenerator','StealthGenerator', 'CloakingGenerator', 'T3Engineering'})

    units3 = ScenarioFramework.SpawnCommander('QAI', 'SDrone4', false, 'QAI Drone', false, false,
    {'MicrowaveLaserGenerator','StealthGenerator', 'CloakingGenerator', 'T3Engineering'})

    ArmyBrains[QAI]:AssignUnitsToPlatoon(ACUPlatoon2, {units2}, 'Attack', 'AttackFormation')
    ArmyBrains[QAI]:AssignUnitsToPlatoon(ACUPlatoon2, {units3}, 'Attack', 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(ACUPlatoon2, 'P4Intattack2')

    units4 = ScenarioFramework.SpawnCommander('QAI', 'SDrone5', false, 'QAI Drone', false, false,
    {'MicrowaveLaserGenerator','StealthGenerator', 'CloakingGenerator', 'T3Engineering'})

    units5 = ScenarioFramework.SpawnCommander('QAI', 'SDrone6', false, 'QAI Drone', false, false,
    {'MicrowaveLaserGenerator','StealthGenerator', 'CloakingGenerator', 'T3Engineering'})

    ArmyBrains[QAI]:AssignUnitsToPlatoon(ACUPlatoon3, {units4}, 'Attack', 'AttackFormation')
    ArmyBrains[QAI]:AssignUnitsToPlatoon(ACUPlatoon3, {units5}, 'Attack', 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(ACUPlatoon3, 'P4Intattack3')
    
    units6 = ScenarioFramework.SpawnCommander('QAI', 'SDrone7', false, 'QAI Drone', false, false,
    {'MicrowaveLaserGenerator','StealthGenerator', 'CloakingGenerator', 'T3Engineering'})
    
    units7 = ScenarioFramework.SpawnCommander('QAI', 'SDrone8', false, 'QAI Drone', false, false,
    {'MicrowaveLaserGenerator','StealthGenerator', 'CloakingGenerator', 'T3Engineering'})

    ArmyBrains[QAI]:AssignUnitsToPlatoon(ACUPlatoon4, {units6}, 'Attack', 'AttackFormation')
    ArmyBrains[QAI]:AssignUnitsToPlatoon(ACUPlatoon4, {units7}, 'Attack', 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(ACUPlatoon4, 'P4Intattack4')
    
    units8 = ScenarioFramework.SpawnCommander('QAI', 'SDrone9', false, 'QAI Drone', false, false,
    {'MicrowaveLaserGenerator','StealthGenerator', 'CloakingGenerator', 'T3Engineering'})
    
    units9 = ScenarioFramework.SpawnCommander('QAI', 'SDrone10', false, 'QAI Drone', false, false,
    {'MicrowaveLaserGenerator','StealthGenerator', 'CloakingGenerator', 'T3Engineering'})

    ArmyBrains[QAI]:AssignUnitsToPlatoon(ACUPlatoon5, {units8}, 'Attack', 'AttackFormation')
    ArmyBrains[QAI]:AssignUnitsToPlatoon(ACUPlatoon5, {units9}, 'Attack', 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(ACUPlatoon5, 'P4Intattack5')
   
    buffDef = Buffs['CheatIncome']
    buffAffects = buffDef.Affects
    buffAffects.EnergyProduction.Mult = 2.5
    buffAffects.MassProduction.Mult = 2.5

    for _, u in GetArmyBrain(QAI):GetPlatoonUniquelyNamed('ArmyPool'):GetPlatoonUnits() do
        Buff.ApplyBuff(u, 'CheatIncome')
    end     

    Cinematics.EnterNISMode()
        Cinematics.SetInvincible('AREA_3')

        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P4Cam1'), 0)
        local VisMarker4_1 = ScenarioFramework.CreateVisibleAreaLocation(90, 'P4Vision1', 0, ArmyBrains[Player1])
        ScenarioFramework.Dialogue(OpStrings.IntroP4, nil, true)
        WaitSeconds(1)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P4Cam1'), 3)
        WaitSeconds(2)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P4Cam2'), 3)
        WaitSeconds(2)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P4Cam3'), 3)
        local units = ScenarioFramework.SpawnCommander('QAI', 'P4ACU1', false, 'QAI Drone', false, false,
            {'MicrowaveLaserGenerator', 'StealthGenerator', 'CloakingGenerator', 'AdvancedEngineering', 'T3Engineering'})
            ScenarioFramework.GroupMoveChain({units}, 'P4QACUattack1')
        WaitSeconds(4)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P1Cam1'), 3)
        WaitSeconds(1)
    
        ForkThread(
            function()
                WaitSeconds(2)
                VisMarker4_1:Destroy()
                WaitSeconds(1)
                ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('P4Vision1'), 100)

            end
        )
        Cinematics.SetInvincible('AREA_3', true)
    Cinematics.ExitNISMode()

    ForkThread(MissionP4)
    ForkThread(SecondaryMissionP4)
    ScenarioFramework.CreateTimerTrigger(EnableQAINukeAI, 90)
    ForkThread(CounterAttackP4)
    ForkThread(P4QAIACUAttack1)
    ForkThread(P4QAIACUAttack2)
    ForkThread(P4QAIACUAttack3)
    SetupQAIM4Taunts()
end

function MissionP4()

    ScenarioInfo.M1P4 = Objectives.Kill(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Destroy Northern ACU Factory',                -- title
        'QAI is using the Crystals to mass produce ACUs, Stop him.', -- description
        {                              -- target
            MarkUnits = true,
            Units = {ScenarioInfo.P4Gate3},   
        }
    )
    

    ScenarioInfo.M2P4 = Objectives.Kill(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Destroy Northeastern ACU Factory',                -- title
        'QAI is using the Crystals to mass produce ACUs, Stop him.', -- description
        {                              -- target
            MarkUnits = true,
            Units = {ScenarioInfo.P4Gate2},   
        }
    )
    

    ScenarioInfo.M3P4 = Objectives.Kill(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Destroy Eastern ACU Factory',                -- title
        'QAI is using the Crystals to mass produce ACUs, Stop him.', -- description
        {                              -- target
            MarkUnits = true,
            Units = {ScenarioInfo.P4Gate1},   
        }
    )
    

    ScenarioInfo.M4Objectives = Objectives.CreateGroup('M4Objectives', EndgameCheck)
    ScenarioInfo.M4Objectives:AddObjective(ScenarioInfo.M1P4)
    ScenarioInfo.M4Objectives:AddObjective(ScenarioInfo.M2P4)
    ScenarioInfo.M4Objectives:AddObjective(ScenarioInfo.M3P4)
    if ScenarioInfo.M1P3.Active then
        ScenarioInfo.M4Objectives:AddObjective(ScenarioInfo.M1P3)
    end
    if ScenarioInfo.M2P3.Active then
        ScenarioInfo.M4Objectives:AddObjective(ScenarioInfo.M2P3)
    end   
end

function SecondaryMissionP4()

    if ScenarioInfo.S2P3.Active then
    
    ScenarioInfo.S2P3:ManualResult(true)   
    else
    WaitSeconds(30)
    ForkThread(SecondaryMissionP4)
    end
end

function P4QAIACUAttack1()
    if ScenarioInfo.M1P4.Active then
        WaitSeconds(2*60) 
        local ACUPlatoon6 = ArmyBrains[QAI]:MakePlatoon('', '')
        local units = ScenarioFramework.SpawnCommander('QAI', 'P4ACU1', false, 'QAI Drone', false, false,
            {'MicrowaveLaserGenerator','StealthGenerator', 'CloakingGenerator', 'T3Engineering'})
            ArmyBrains[QAI]:AssignUnitsToPlatoon(ACUPlatoon6, {units}, 'Attack', 'AttackFormation')
            ScenarioFramework.PlatoonPatrolChain(ACUPlatoon6, 'P4QACUattack1')
        return        
    end
end

function P4QAIACUAttack2()
    if ScenarioInfo.M2P4.Active then
        WaitSeconds(2*60) 
        local ACUPlatoon7 = ArmyBrains[QAI]:MakePlatoon('', '')
        local units = ScenarioFramework.SpawnCommander('QAI', 'P4ACU2', false, 'QAI Drone', false, false,
            {'MicrowaveLaserGenerator','StealthGenerator', 'CloakingGenerator', 'T3Engineering'})
            ArmyBrains[QAI]:AssignUnitsToPlatoon(ACUPlatoon7, {units}, 'Attack', 'AttackFormation')
            ScenarioFramework.PlatoonPatrolChain(ACUPlatoon7, 'P4QACUattack2') 
        return        
    end
end

function P4QAIACUAttack3()
    if ScenarioInfo.M3P4.Active then
        WaitSeconds(2*60) 
        local ACUPlatoon8 = ArmyBrains[QAI]:MakePlatoon('', '')
        local units = ScenarioFramework.SpawnCommander('QAI', 'P4ACU3', false, 'QAI Drone', false, false,
            {'MicrowaveLaserGenerator','StealthGenerator', 'CloakingGenerator', 'T3Engineering'})
            ArmyBrains[QAI]:AssignUnitsToPlatoon(ACUPlatoon8, {units}, 'Attack', 'AttackFormation')
            ScenarioFramework.PlatoonPatrolChain(ACUPlatoon8, 'P4QACUattack3') 
        return        
    end
end

function CounterAttackP4()
    local quantity = {}
    local trigger = {}
    local platoon = nil

    -- sends Gunships if player has more than [60, 50, 40] Units, up to 10, 1 group per 14, 11, 10
    num = ScenarioFramework.GetNumOfHumanUnits(categories.ALLUNITS - categories.WALL)
    quantity = {200, 150, 100}
    trigger = {50, 40, 30}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 10) then
            num = 10
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('QAI', 'P4QGunships', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P4Intattack' .. Random(1, 5))
        end
    end

    -- sends Gunships if player has more than [60, 50, 40] Units, up to 10, 1 group per 14, 11, 10
    num = ScenarioFramework.GetNumOfHumanUnits(categories.ALLUNITS - categories.WALL)
    quantity = {200, 150, 100}
    trigger = {70, 60, 50}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 10) then
            num = 10
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('QAI', 'P4QBombers', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P4Intattack' .. Random(1, 5))
        end
    end

    -- sends ASF if player has more than [30, 20, 10] Air, up to 5, 1 group per 10, 20, 30
    num = ScenarioFramework.GetNumOfHumanUnits(categories.AIR * categories.MOBILE)
    quantity = {30, 20, 10}
    trigger = {20, 15, 10}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 15) then
            num = 15
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('QAI', 'P4QFighters', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P4Intattack' .. Random(1, 5))
        end
    end

    -- sends ASF if player has more than [30, 20, 10] Air, up to 5, 1 group per 10, 20, 30
    num = ScenarioFramework.GetNumOfHumanUnits(categories.EXPERIMENTAL * categories.MOBILE)
    quantity = {3, 2, 1}
    trigger = {3, 2, 1}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 5) then
            num = 5
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('QAI', 'P4QBug', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P4Intattack' .. i)
        end
    end

    local LandExp = ScenarioFramework.GetListOfHumanUnits(categories.EXPERIMENTAL * categories.LAND)
    local num = table.getn(LandExp)

    if num > 0 then
            quantity = {4, 3, 2}
            if num > quantity[Difficulty] then
                num = num
            end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('QAI', 'P4QExphunter', 'GrowthFormation', 5)
            IssueAttack(platoon:GetPlatoonUnits(), LandExp[i])
            IssueAggressiveMove(platoon:GetPlatoonUnits(), ScenarioUtils.MarkerToPosition('Player1'))
        end
    end

    local AirExp = ScenarioFramework.GetListOfHumanUnits(categories.EXPERIMENTAL * categories.AIR)
    local num = table.getn(AirExp)
    
    if num > 0 then
            quantity = {4, 3, 2}
            if num > quantity[Difficulty] then
                num = num
            end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('QAI', 'P4QIntercept', 'GrowthFormation', 5)
            IssueAttack(platoon:GetPlatoonUnits(), AirExp[i])
            IssueAggressiveMove(platoon:GetPlatoonUnits(), ScenarioUtils.MarkerToPosition('Player1'))
        end
    end

    for i = 1, 6 do
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('QAI', 'P4QDrops', 'GrowthFormation', 5)
        CustomFunctions.PlatoonAttackWithTransports(platoon, 'P2QDrop', 'P2QDropattack', 'DeleteMK', true)
    end 
end

--UEF Nuke AI during Phase 3, platoon.lua is used in this case
function EnableQAINukeAI()
    --Get a table of all QAI SMLs
    local QAISilos = ArmyBrains[QAI]:GetListOfUnits(categories.urb2305, false)
        
        --Only do something if there is at least 1 SML in the table
        if table.getn(QAISilos) > 0 then
            for k, v in QAISilos do
                --Loop through each SML, and only enable the NukeAI for an instance if it hasn't been enabled yet
                if not v.SiloAIEnabled and not v:IsDead() then
                    --Make a single unit platoon for each SML
                    local SiloPlatoon = ArmyBrains[QAI]:MakePlatoon('','')
                    ArmyBrains[QAI]:AssignUnitsToPlatoon(SiloPlatoon, {v}, 'Attack', 'None')
                    --Platoon gets the AI function called
                    SiloPlatoon:ForkAIThread(SiloPlatoon.NukeAI)
                    --Flag to check if the NukeAI has already been called for the SML instance
                    v.SiloAIEnabled = true
                end
            end
        end
    --Check for SMLs every 60 seconds
    ScenarioFramework.CreateTimerTrigger(EnableQAINukeAI, 60)
end

function EndgameCheck()

    if Difficulty == 3 then

        ScenarioInfo.M1P5 = Objectives.CategoriesInArea(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Destroy all Enemy forces',                 -- title
        'Clean out all bases.',  -- description
        'kill',                         -- action
        {                               -- target
            MarkUnits = true,
            ShowProgress = true,
            ShowFaction = 'Cybran',
            Requirements = {
                {   
                    Area = 'AREA_4',
                    Category = categories.FACTORY + (categories.ECONOMIC * categories.TECH2) + (categories.ECONOMIC * categories.TECH3),
                    CompareOp = '<=',
                    Value = 0,
                    ArmyIndex = QAI,
                },
            },
        }
    )
    
    ScenarioInfo.M1P5:AddResultCallback(
        function(result)
            if result then
                PlayerWin()
            end
        end
    )    
    else
        PlayerWin()
    end
end

--Extra functions

function PlayerWin()
    if not ScenarioInfo.OpEnded then
        ScenarioInfo.OpComplete = true
        ScenarioFramework.Dialogue(OpStrings.PlayerWin, nil, true)
        ForkThread(KillGame)
    end
end

function KillGame()
    WaitSeconds(5)
    UnlockInput()
    ScenarioFramework.EndOperation(ScenarioInfo.OpComplete, ScenarioInfo.OpComplete, true)
end

function PlayerDeath()
    if Debug then return end
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
                WaitSeconds(1)
                UnlockInput()
                KillGame()
            end
       )
    end
end

function PlayerLose()
    if(not ScenarioInfo.OpEnded) then
        ScenarioFramework.CDRDeathNISCamera(ScenarioInfo.PlayerCDR)
        ScenarioFramework.EndOperationSafety()
        ScenarioInfo.OpComplete = false
        for _, v in AssignedObjectives do
            if(v and v.Active) then
                v:ManualResult(false)
            end
        end
        WaitSeconds(3)
       KillGame()
  end    
end

-- Buffs resource producing structures, (and ACU variants.)
function BuffAIEconomy()
    -- Resource production multipliers, depending on the Difficulty
    local Rate = {1.5, 2.0, 2.5}
    -- Buff definitions
    local buffDef = Buffs['CheatIncome']
    local buffAffects = buffDef.Affects
    buffAffects.EnergyProduction.Mult = Rate[Difficulty]
    buffAffects.MassProduction.Mult = Rate[Difficulty]
    
    while true do
        if not table.empty(AIs) then
            for i, j in AIs do
                local economy = ArmyBrains[j]:GetListOfUnits(BuffCategories.Economy, false)
                -- Check if there is anything to buff
                if table.getn(economy) > 0 then
                    for k, v in economy do
                        -- Apply buff to the entity if it hasn't been buffed yet
                        if not v.EcoBuffed then
                            Buff.ApplyBuff( v, 'CheatIncome' )
                            -- Flag the entity as buffed
                            v.EcoBuffed = true
                        end
                    end
                end
            end
        end
        WaitSeconds(60)
    end
end


-- Taunts

function SetupQAIM1Taunts()
    -- QAITM taunt, when Player1 is spotted
    QAITM:AddIntelCategoryTaunt('RevealP1', ArmyBrains[QAI], ArmyBrains[Player1], categories.ALLUNITS)

    -- On losing first defensive structures
    QAITM:AddUnitsKilledTaunt('TAUNT1P1', ArmyBrains[QAI], categories.STRUCTURE * categories.DEFENSE, 1)
    -- On losing factories
    QAITM:AddUnitsKilledTaunt('TAUNT2P1', ArmyBrains[QAI], categories.STRUCTURE * categories.FACTORY, 3)
    -- On destroying enemy units
    QAITM:AddEnemiesKilledTaunt('TAUNT3P1', ArmyBrains[QAI], categories.MOBILE, 100)
end

function SetupQAIM2Taunts()
    -- On destroying enemy air units
    QAITM:AddEnemiesKilledTaunt('TAUNT1P2', ArmyBrains[QAI], categories.AIR * categories.MOBILE, 100)
    -- On losing structures
    QAITM:AddUnitsKilledTaunt('TAUNT2P2', ArmyBrains[QAI], categories.STRUCTURE, 6)
    -- On destroying enemy structures
    QAITM:AddEnemiesKilledTaunt('TAUNT3P2', ArmyBrains[QAI], categories.STRUCTURE, 10)
end

function SetupQAIM3Taunts()

    -- On destroying enemy T2 ships
    QAITM:AddEnemiesKilledTaunt('TAUNT1P3', ArmyBrains[QAI], categories.LAND * categories.MOBILE * categories.TECH3, 20)
    -- On destroying enemy T2 land units
    QAITM:AddEnemiesKilledTaunt('TAUNT2P3', ArmyBrains[QAI], categories.LAND * categories.MOBILE * categories.TECH2, 50)
    -- On losing structures
    QAITM:AddUnitsKilledTaunt('TAUNT3P3', ArmyBrains[QAI], categories.STRUCTURE - categories.WALL, 8)
end

function SetupQAIM4Taunts()

    -- On destroying enemy T2 ships
    QAITM:AddEnemiesKilledTaunt('TAUNT1P4', ArmyBrains[QAI], categories.LAND * categories.MOBILE * categories.TECH3, 20)
    -- On destroying enemy T2 land units
    QAITM:AddEnemiesKilledTaunt('TAUNT2P4', ArmyBrains[QAI], categories.LAND * categories.MOBILE * categories.TECH2, 50)
    -- On losing structures
    QAITM:AddUnitsKilledTaunt('TAUNT3P4', ArmyBrains[QAI], categories.STRUCTURE - categories.WALL, 8)
end
