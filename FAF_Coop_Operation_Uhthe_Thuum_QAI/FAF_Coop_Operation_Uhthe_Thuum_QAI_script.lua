------------------------------
-- Seraphim Campaign - Mission 3
--
-- Author: Shadowlorda1
------------------------------
local Buff = import('/lua/sim/Buff.lua')
local Cinematics = import('/lua/cinematics.lua')
local Objectives = import('/lua/ScenarioFramework.lua').Objectives
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local Utilities = import('/lua/Utilities.lua')
local OpStrings = import('/maps/FAF_Coop_Operation_Uhthe_Thuum_QAI/FAF_Coop_Operation_Uhthe_Thuum_QAI_strings.lua')
local CustomFunctions = import('/maps/FAF_Coop_Operation_Uhthe_Thuum_QAI/FAF_Coop_Operation_Uhthe_Thuum_QAI_CustomFunctions.lua')
local AIBuildStructures = import('/lua/ai/aibuildstructures.lua')  
local TauntManager = import('/lua/TauntManager.lua')

local P1CybranAI = import('/maps/FAF_Coop_Operation_Uhthe_Thuum_QAI/CybranaiP1.lua')
local P2CybranAI = import('/maps/FAF_Coop_Operation_Uhthe_Thuum_QAI/CybranaiP2.lua')
local P3CybranAI = import('/maps/FAF_Coop_Operation_Uhthe_Thuum_QAI/CybranaiP3.lua')
local P2QAIAI = import('/maps/FAF_Coop_Operation_Uhthe_Thuum_QAI/QAIaiP2.lua')

local CybranTM = TauntManager.CreateTauntManager('Cybran1TM', '/maps/FAF_Coop_Operation_Uhthe_Thuum_QAI/FAF_Coop_Operation_Uhthe_Thuum_QAI_strings.lua')

ScenarioInfo.Player1 = 1
ScenarioInfo.Cybran1 = 2
ScenarioInfo.QAI = 3
ScenarioInfo.Nodes = 4
ScenarioInfo.Cybran2 = 5
ScenarioInfo.Player2 = 6
ScenarioInfo.Player4 = 7
ScenarioInfo.Player3 = 8

local Difficulty = ScenarioInfo.Options.Difficulty
local AssignedObjectives = {}

local Player1 = ScenarioInfo.Player1
local Player2 = ScenarioInfo.Player2
local Player3 = ScenarioInfo.Player3
local Player4 = ScenarioInfo.Player4
local Cybran1 = ScenarioInfo.Cybran1
local Cybran2 = ScenarioInfo.Cybran2
local Nodes = ScenarioInfo.Nodes
local QAI = ScenarioInfo.QAI

local LeaderFaction
local LocalFaction
local AIs = {Cybran1, Cybran2, QAI}
local BuffCategories = {
    BuildPower = (categories.FACTORY * categories.STRUCTURE) + categories.ENGINEER,
    Economy = categories.ECONOMIC,
}

local TimedAttackP1 = {20*60, 15*60, 12*60}
local ExpansionTimer = ScenarioInfo.Options.Expansion == "true"

local Debug = false
local NIS1InitialDelay = 3
  
function OnPopulate(scen)
 
    ScenarioUtils.InitializeScenarioArmies()
       
    ScenarioFramework.SetSeraphimColor(Player1)
    
    ScenarioFramework.SetCybranNeutralColor(Cybran1)
    
    local colors = {
    ['Player2'] = {255, 191, 128}, 
    ['Player3'] = {189, 116, 16}, 
    ['Player4'] = {89, 133, 39},
    ['QAI'] = {225, 70, 0},
    ['Cybran2'] = {97, 109, 126}
    }
    local tblArmy = ListArmies()
    for army, color in colors do
        if tblArmy[ScenarioInfo[army]] then
            ScenarioFramework.SetArmyColor(ScenarioInfo[army], unpack(color))
        end
    end
    
    SetArmyUnitCap(Cybran1, 2000)
    SetArmyUnitCap(Cybran2, 2000)
    SetArmyUnitCap(QAI, 1000)
    ScenarioFramework.SetSharedUnitCap(4800)
    
    ScenarioUtils.CreateArmyGroup('Cybran1', 'P1walls')
    ScenarioUtils.CreateArmyGroup('Cybran1', 'P1Civilanbase')
    ScenarioUtils.CreateArmyGroup('Cybran1', 'OuterDefenses_D' .. Difficulty)
    ScenarioUtils.CreateArmyGroup('Cybran1', 'Wreakbase1', true)
    ScenarioUtils.CreateArmyGroup('Cybran1', 'Wreakbase2')
     
    ScenarioInfo.Node1 = ScenarioUtils.CreateArmyUnit('Cybran1', 'Node1')
        ScenarioInfo.Node1:SetCustomName("QAI Data Node 1")
        ScenarioInfo.Node1:SetReclaimable(false)
        ScenarioInfo.Node1:SetCapturable(true)
        ScenarioInfo.Node1:SetCanTakeDamage(false)
        ScenarioInfo.Node1:SetCanBeKilled(false)
        ScenarioInfo.Node1:SetDoNotTarget(true)
end

function OnStart(scen)

    ScenarioFramework.SetPlayableArea('AREA_2', false)   
    
    ScenarioFramework.AddRestrictionForAllHumans(
        categories.UEF + -- UEF faction 
        categories.url0401 + -- Scathis
        categories.xrl0403 + -- Megalith
        categories.ura0401 + -- Exp Gunship
        categories.xsa0402 + -- Super bomber
        categories.xab1401 + -- Paragon
        categories.uaa0310 + -- Exp Carrier
        categories.xab2307 + -- Salvation
        categories.xsb2302 + -- Sera T3 Arty
        categories.uab2302 + -- Aeon T3 Arty
        categories.urb2302 + -- Cybran T3 Arty
        categories.xsb2401  -- Super Nuke
    )
    
    P1CybranAI.P1C1base1AI()
    P1CybranAI.P1C1base2AI()

    if Difficulty == 3 then
        ArmyBrains[Cybran1]:PBMSetCheckInterval(8)
        ArmyBrains[Cybran2]:PBMSetCheckInterval(8)
    end
    
    ScenarioUtils.CreateArmyGroup('Nodes', 'Mainframe_Walls')
    ScenarioUtils.CreateArmyGroup('Nodes', 'Mainframe_Defenses')
    
    ScenarioInfo.MF1 = ScenarioUtils.CreateArmyUnit('Nodes', 'Mainframe_Unit')
    ScenarioInfo.MF1:SetCanTakeDamage(false)
    ScenarioInfo.MF1:SetCanBeKilled(false)
    
    GetArmyBrain(Nodes):SetResourceSharing(false)
    GetArmyBrain(QAI):SetResourceSharing(false)
    
    for _, army in AIs do
        ArmyBrains[army].IMAPConfig = {
                OgridRadius = 0,
                IMAPSize = 0,
                Rings = 0,
        }
        ArmyBrains[army]:IMAPConfiguration()
    end

    ForkThread(IntroP1)
end

-- Part 1

function IntroP1()
    
    ScenarioInfo.MissionNumber = 1
    
    Cinematics.EnterNISMode()  
    
        WaitSeconds(NIS1InitialDelay)
    
        local VisMarker1_1 = ScenarioFramework.CreateVisibleAreaLocation(40, 'P1Vision1', 0, ArmyBrains[Player1])
        local VisMarker1_2 = ScenarioFramework.CreateVisibleAreaLocation(50, 'P1Vision2', 0, ArmyBrains[Player1])
    
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P1Cam1'), 0)
        WaitSeconds(1)
        ScenarioFramework.Dialogue(OpStrings.IntroP1, nil, true)
        WaitSeconds(4)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P1Cam3'), 5)
        WaitSeconds(3)
        ScenarioInfo.P1QACU = ScenarioFramework.SpawnCommander('QAI', 'P1QACU', 'Warp', 'QAI', false, false)
        ScenarioInfo.P1QACU:PlayCommanderWarpInEffect()
        WaitSeconds(4)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P1Cam4'), 3)
        WaitSeconds(3)
        ForkThread(KillP1QACU)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P1Cam2'), 3)
    
        ForkThread(
            function()
                WaitSeconds(1)
                VisMarker1_1:Destroy()
                VisMarker1_2:Destroy()
                WaitSeconds(1)
                ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('P1Vision1'), 50)
                ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('P1Vision2'), 60)
            end
        )
    
        ScenarioFramework.SetPlayableArea('AREA_1', false) 
    
    Cinematics.ExitNISMode()
    
    ScenarioInfo.PlayerCDR = ScenarioFramework.SpawnCommander('Player1', 'Commander', 'Warp', true, true, PlayerDeath)
    
    -- spawn coop players too
    ScenarioInfo.CoopCDR = {}
    local tblArmy = ListArmies()
    coop = 1
    for iArmy, strArmy in pairs(tblArmy) do
        if iArmy >= ScenarioInfo.Player2 then
            factionIdx = GetArmyBrain(strArmy):GetFactionIndex()
            if (factionIdx == 2) then
                ScenarioInfo.CoopCDR[coop] = ScenarioFramework.SpawnCommander(strArmy, 'ACommander', 'Warp', true, true, PlayerDeath)
            else
                ScenarioInfo.CoopCDR[coop] = ScenarioFramework.SpawnCommander(strArmy, 'Commander', 'Warp', true, true, PlayerDeath)   
            end
            coop = coop + 1
            WaitSeconds(0.5)
        end
    end 
    
    ForkThread(
        function()
            WaitSeconds(4*60)
            ScenarioFramework.Dialogue(OpStrings.Reveal1P1, nil, true)
        end
    )
    
    ForkThread(BuffAIEconomy)   

    ArmyBrains[Cybran1]:GiveResource('MASS', 4000)
    ArmyBrains[Cybran1]:GiveResource('ENERGY', 6000)
    
    ForkThread(MissionP1)
    ForkThread(MidAttackP1)
end

function MissionP1()
    WaitSeconds(5)

    local function MissionNameAnnouncement()
        ScenarioFramework.SimAnnouncement(ScenarioInfo.name, "Mission by Shadowlorda1")
    end

    ScenarioFramework.CreateTimerTrigger(MissionNameAnnouncement, 12)

    ScenarioInfo.M1P1 = Objectives.Capture(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Capture Data Node',    -- title
        'Capturing the node will help QAI access the mainframe.',  -- description
        {                              -- target
            MarkUnits = true,
            FlashVisible = true,
            ShowFaction = 'Cybran',
            Units = {ScenarioInfo.Node1},
        }
    )

    ScenarioFramework.CreateArmyIntelTrigger(SecondaryMissionP1, ArmyBrains[Player1], 'LOSNow', false, true, categories.urc1301, true, ArmyBrains[Cybran1])
    
    SetupCybranM1TauntTriggers()
    
    ScenarioInfo.M1Objectives = Objectives.CreateGroup('M1Objectives', IntroP2Dialogue)
    ScenarioInfo.M1Objectives:AddObjective(ScenarioInfo.M1P1)
    
    if ExpansionTimer then
        local M1MapExpandDelay = {50*60, 40*60, 30*60}
        ScenarioFramework.CreateTimerTrigger(IntroP2Dialogue, M1MapExpandDelay[Difficulty])
    end
end

function SecondaryMissionP1()
     
    ScenarioFramework.Dialogue(OpStrings.SecondaryObj1, nil, true)
     
    ScenarioInfo.M1P1S1 = Objectives.CategoriesInArea(
        'secondary',                      -- type
        'incomplete',                   -- complete
        'Purge The Cybran City',                 -- title
        'The cybran is attempting to defend and evacuate civilians, kill them all.',  -- description
        'kill',                         -- action
        {                               -- target
            MarkUnits = true,
            ShowProgress = true,
            Requirements = {
                {   
                    Area = 'C1City',
                    Category = categories.CYBRAN * categories.STRUCTURE,
                    CompareOp = '<=',
                    Value = 0,
                    ArmyIndex = Cybran1,
                },
            },
            Category = categories.urc1301,
        }
    )
    
    ScenarioInfo.M1P1S1:AddResultCallback(
        function(result)
            if result then
                ScenarioFramework.Dialogue(OpStrings.SecondaryObj1Complete, nil, true)
                ScenarioFramework.Dialogue(OpStrings.React1P1, nil, true)
            end
        end
    )
end

function MidAttackP1()

    WaitSeconds(TimedAttackP1[Difficulty])
    
        ScenarioFramework.Dialogue(OpStrings.MidP1, nil, true)
    
        WaitSeconds(2*60)
        local quantity = {}
        quantity = {2, 3, 4}

        for i = 1, quantity[Difficulty] do
            local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran2', 'P1C2Assaultbombers_D' .. Difficulty, 'GrowthFormation')
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P1C2Assaultattack' .. i)
        end 

        for i = 1, quantity[Difficulty] do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran2', 'P1C2Assaultgunships', 'GrowthFormation')
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P1C2Assaultattack' .. i)
        end

        for i = 1, quantity[Difficulty] do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Cybran2', 'P1C2Assaultdrops', 'GrowthFormation', 5)
            CustomFunctions.PlatoonAttackWithTransports(platoon, 'P1C2AssaultattackDrop', 'P1C2AssaultattackDropA', 'P2UTransportdeath', true)
        end

        if Difficulty == 3 then
            units = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran2', 'P1C2Airpatrol', 'AttackFormation')
            for _, v in units:GetPlatoonUnits() do
                ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P1C2B1Airpatrol')))
            end
        end

        local destination = ScenarioUtils.MarkerToPosition('P1C2B1MK')

        local transports = ScenarioUtils.CreateArmyGroup('Cybran2', 'P2C2EngineersTransport')
        local units = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran2', 'P2C2Engineers', 'NoFormation')

        WaitSeconds(2)

        import('/lua/ai/aiutilities.lua').UseTransports(units:GetPlatoonUnits(), transports, destination)

        WaitSeconds(6)

        for _, transport in transports do
            ScenarioFramework.CreateUnitToMarkerDistanceTrigger(DestroyUnit, transport,  ScenarioUtils.MarkerToPosition('P2UTransportdeath'), 15)

            IssueTransportUnload({transport}, destination)
            IssueMove({transport}, ScenarioUtils.MarkerToPosition('P2UTransportdeath'))
        end
        
        -- Disband the Platoon
        ArmyBrains[Cybran2]:DisbandPlatoon(units)
        ScenarioUtils.CreateArmyGroup('Cybran2', 'P1C2Eco')
        P1CybranAI:P1C2base1AI()
end

function KillP1QACU()
    ScenarioInfo.P1QACU:Destroy()
end

-- Part 2

function IntroP2Dialogue()

    if ScenarioInfo.M1P1.Active then
        ScenarioFramework.Dialogue(OpStrings.IntroP2NodeNC, IntroP2, true)
    else
        ScenarioFramework.Dialogue(OpStrings.IntroP2NodeC, IntroP2, true)
    end
end

function IntroP2()
    ScenarioFramework.FlushDialogueQueue()
    
    if ScenarioInfo.MissionNumber ~= 1 then
        return
    end
    ScenarioInfo.MissionNumber = 2
    
    ScenarioFramework.Dialogue(OpStrings.IntroP2P1, nil, true)
    
    ScenarioFramework.SetPlayableArea('AREA_2', true)  

    ScenarioUtils.CreateArmyGroup('Cybran1', 'Outerthings_D'.. Difficulty)
    ScenarioUtils.CreateArmyGroup('Cybran1', 'P2walls')
    ScenarioUtils.CreateArmyGroup('QAI', 'QWreaks', true)
    
    ScenarioUtils.CreateArmyGroup('QAI', 'Qintunits1')
    ScenarioUtils.CreateArmyGroup('QAI', 'P2QWalls')
    
    ScenarioInfo.Node2 = ScenarioUtils.CreateArmyUnit('Cybran1', 'Node2')
        ScenarioInfo.Node2:SetCustomName("QAI Data Node 2")
        ScenarioInfo.Node2:SetReclaimable(false)
        ScenarioInfo.Node2:SetCapturable(true)
        ScenarioInfo.Node2:SetCanTakeDamage(false)
        ScenarioInfo.Node2:SetCanBeKilled(false)
        ScenarioInfo.Node2:SetDoNotTarget(true)
    
    P2CybranAI.P2C1base1AI()
    P2CybranAI.P2C1base2AI()
    P2QAIAI.P2Q1base1AI()
    P2CybranAI.P2C2base1AI()
    P3CybranAI.C2P3Base3AI()

    local Antinukes = ArmyBrains[Cybran1]:GetListOfUnits(categories.urb4302, false)
    for _, v in Antinukes do
        v:GiveTacticalSiloAmmo(4)
    end

    local Antinukes = ArmyBrains[QAI]:GetListOfUnits(categories.urb4302, false)
    for _, v in Antinukes do
        v:GiveTacticalSiloAmmo(4)
    end

    if Difficulty == 3 then
        ArmyBrains[Cybran1]:PBMSetCheckInterval(8)
        ArmyBrains[Cybran2]:PBMSetCheckInterval(8)
    end
    
    ScenarioInfo.P2C1ACU = ScenarioFramework.SpawnCommander('Cybran1', 'C1ACU', false, 'Commander Corva', true, false,
    { 'AdvancedEngineering', 'T3Engineering', 'StealthGenerator', 'CloakingGenerator', 'NaniteTorpedoTube'})
    ScenarioInfo.P2C1ACU:SetAutoOvercharge(true)
    ScenarioInfo.P2C1ACU:SetVeterancy(1 + Difficulty)
    
    ScenarioInfo.P2C1ACU:AddBuildRestriction(categories.urb2301 + categories.urb1302 + categories.urb1202 + categories.urb1103 + categories.urb1106 + categories.urb1105 + categories.urb1201 + categories.urb2101)
    
    ScenarioInfo.P2QACU = ScenarioFramework.SpawnCommander('QAI', 'QACU', false, 'QAI', false, false,
    {'AdvancedEngineering', 'T3Engineering', 'ResourceAllocation'})
    ScenarioInfo.P2QACU:SetAutoOvercharge(true)
    ScenarioInfo.P2QACU:SetVeterancy(4 - Difficulty)
    
    ScenarioInfo.P2QACU:AddBuildRestriction(categories.urb2301 + categories.urb1302 + categories.urb1202 + categories.urb1103 + categories.urb1106 + categories.urb1105 + categories.urb1201 + categories.urb2101)
    
    
    units = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran2', 'P2attacks1_D' .. Difficulty, 'AttackFormation')
    for _, v in units:GetPlatoonUnits() do
       ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P2C2intattack1')))
    end
     
    units = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran2', 'P2attacks2_D' .. Difficulty, 'AttackFormation')
    for _, v in units:GetPlatoonUnits() do
       ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P2C2intattack1')))
    end
     
    units = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran2', 'P2attacks3_D' .. Difficulty, 'AttackFormation')
    for _, v in units:GetPlatoonUnits() do
       ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P2C2intattack1')))
    end
     
    units = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'Qintunits2', 'AttackFormation')
    for _, v in units:GetPlatoonUnits() do
      ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P2QAirD1')))
    end
     
    units = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran1', 'P2Airdefence1_D'.. Difficulty, 'AttackFormation')
    for _, v in units:GetPlatoonUnits() do
       ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P2C1B2Airdefence1')))
    end
    
    units = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran1', 'P2Seadefence1_D'.. Difficulty, 'AttackFormation')
    for _, v in units:GetPlatoonUnits() do
       ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P2C1B2Seadefence1')))
    end
     
    Cinematics.EnterNISMode()
        Cinematics.SetInvincible('AREA_1')    
    
        local VisMarker2_1 = ScenarioFramework.CreateVisibleAreaLocation(50,'Vision1P2', 0, ArmyBrains[Player1])
        local VisMarker2_2 = ScenarioFramework.CreateVisibleAreaLocation(50,'Vision2P2', 0, ArmyBrains[Player1])
                        
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P2Cam1'), 2)
        WaitSeconds(3)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P2Cam2'), 5)
        WaitSeconds(2)
        Cinematics.CameraTrackEntity(ScenarioInfo.P2QACU, 30, 3)
        WaitSeconds(2)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P2Cam3'), 4)
        WaitSeconds(2)
        Cinematics.CameraTrackEntity(ScenarioInfo.PlayerCDR, 30, 2)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P1Cam2'), 0)
        ScenarioFramework.Dialogue(OpStrings.Intro2P2, nil, true)
        ForkThread(
            function ()
                WaitSeconds(1)
                VisMarker2_1:Destroy()
                VisMarker2_2:Destroy()
            end 
        )
            
        Cinematics.SetInvincible('AREA_1', true) 
    Cinematics.ExitNISMode()
     
    ForkThread(MissionP2)
    ForkThread(Nukeparty)
    ForkThread(EnableStealthOnAirC2)
    ForkThread(CounterAttackP2)
    ForkThread(EnableStealthOnAirC1)
end
     
function MissionP2()
         
    ScenarioInfo.M1P2 = Objectives.Kill(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Kill The First Cybran Commander',                 -- title
        'Eliminate the Cybran commander west of the mainframe.',  -- description
        {                               -- target
            Units = {ScenarioInfo.P2C1ACU}  
          }
    )
    ScenarioInfo.M1P2:AddResultCallback(
    function(result)
        if(result) then
            ForkThread(Cybran1ACUdeath) 
        end
    end
    )
        
    ScenarioInfo.M2P2 = Objectives.Protect(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Defend QAI\'s ACU At All Costs',                 -- title
        'QAI is currently attempting to hack his mainframe defend him.',  -- description
        
        {                               -- target
             MarkUnits = true,
             Units = {ScenarioInfo.P2QACU}
          }
    )
    ScenarioInfo.M2P2:AddResultCallback(
        function(result, unit)
            if (not result and not ScenarioInfo.OpEnded) then
                ScenarioFramework.CDRDeathNISCamera(unit)
                ScenarioFramework.EndOperationSafety()

                ScenarioFramework.FlushDialogueQueue()
                ScenarioFramework.Dialogue(OpStrings.Objectivefailed1, PlayerLose, true)
            end
        end
    )
    
    ScenarioInfo.M3P2 = Objectives.Capture(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Capture QAIs Data Node',    -- title
        'Capturing the node will help QAI access the mainframe.',  -- description
    
        {                              -- target
            MarkUnits = true,
            ShowFaction = 'Cybran',
            Units = {ScenarioInfo.Node2},
        }
    )
    ScenarioInfo.M3P2:AddResultCallback(
    function(result)
        if(result) then
            ScenarioFramework.Dialogue(OpStrings.NodeCapturedP2)
        end
    end
    )
    
    ScenarioInfo.M2Objectives = Objectives.CreateGroup('M2Objectives', Part3start)
    ScenarioInfo.M2Objectives:AddObjective(ScenarioInfo.M3P2)
    if ScenarioInfo.M1P1.Active then
        ScenarioInfo.M2Objectives:AddObjective(ScenarioInfo.M1P1)
    end
     
    ForkThread(SetupCybranM2TauntTriggers)
    ForkThread(P2ArtyObj)

    if ExpansionTimer then
        ForkThread(P2Timer)
    end
end

function P2ArtyObj()

    AIBuildStructures.CreateBuildingTemplate( ArmyBrains[Cybran1], 'Cybran1', 'CybranArtybase1' )
    AIBuildStructures.AppendBuildingTemplate(ArmyBrains[Cybran1], 'Cybran1', 'CybranArtybase1', 'CybranArtybase1')
    
    AIBuildStructures.AppendBuildingTemplate( ArmyBrains[Cybran1], 'Cybran1', 'CybranArtybaseBD1', 'CybranArtybase1')
    
    ScenarioUtils.CreateArmyGroup( 'Cybran1', 'CybranArtybase1')
    
    plat = ScenarioUtils.CreateArmyGroupAsPlatoon( 'Cybran1', 'CybranArtybaseENG1', 'NoFormation' )
    plat.PlatoonData.MaintainBaseTemplate = 'CybranArtybase1'
    plat.PlatoonData.PatrolChain = 'P2C1ENG1'
    plat:ForkAIThread(ScenarioPlatoonAI.StartBaseEngineerThread)

    if Difficulty >= 2 then

        AIBuildStructures.CreateBuildingTemplate( ArmyBrains[Cybran1], 'Cybran1', 'CybranArtybase2' )
        AIBuildStructures.AppendBuildingTemplate(ArmyBrains[Cybran1], 'Cybran1', 'CybranArtybase2', 'CybranArtybase2')
    
        AIBuildStructures.AppendBuildingTemplate( ArmyBrains[Cybran1], 'Cybran1', 'CybranArtybaseBD2', 'CybranArtybase2')
    
        ScenarioUtils.CreateArmyGroup( 'Cybran1', 'CybranArtybase2')
    
        plat = ScenarioUtils.CreateArmyGroupAsPlatoon( 'Cybran1', 'CybranArtybaseENG2', 'NoFormation' )
        plat.PlatoonData.MaintainBaseTemplate = 'CybranArtybase2'
        plat.PlatoonData.PatrolChain = 'P2C1ENG1'
        plat:ForkAIThread(ScenarioPlatoonAI.StartBaseEngineerThread)

        if Difficulty == 3 then

            AIBuildStructures.CreateBuildingTemplate( ArmyBrains[Cybran1], 'Cybran1', 'CybranArtybase3' )
            AIBuildStructures.AppendBuildingTemplate(ArmyBrains[Cybran1], 'Cybran1', 'CybranArtybase3', 'CybranArtybase3')
    
            AIBuildStructures.AppendBuildingTemplate( ArmyBrains[Cybran1], 'Cybran1', 'CybranArtybaseBD3', 'CybranArtybase3')
    
            ScenarioUtils.CreateArmyGroup( 'Cybran1', 'CybranArtybase3')
    
            plat = ScenarioUtils.CreateArmyGroupAsPlatoon( 'Cybran1', 'CybranArtybaseENG3', 'NoFormation' )
            plat.PlatoonData.MaintainBaseTemplate = 'CybranArtybase3'
            plat.PlatoonData.PatrolChain = 'P2C1ENG1'
            plat:ForkAIThread(ScenarioPlatoonAI.StartBaseEngineerThread)
            
        end

    end

    WaitSeconds(1*60)
     
    ScenarioFramework.Dialogue(OpStrings.SecondaryObj2, nil, true)

    ScenarioFramework.PlayUnlockDialogue()

    ScenarioFramework.RemoveRestrictionForAllHumans(
        categories.xsb2302 + -- Sera T3 Arty
        categories.uab2302 + -- Aeon T3 Arty
        categories.urb2302  -- Cybran T3 Arty
    )
     
    ScenarioInfo.M1P2S1 = Objectives.CategoriesInArea(
        'secondary',                      -- type
        'incomplete',                   -- complete
        'Destroy long ranged artillery',    -- title
        'The Cybran is constructing a series of heavy artillery near the Node.',  -- description
        'kill',                         -- action
        {                               -- target
            MarkUnits = true,
            Requirements = {
                {   
                    Area = 'P2Arty',
                    Category = categories.urb2302 + categories.url0309,
                    CompareOp = '==',
                    Value = 0,
                    ArmyIndex = Cybran1,
                },
            },
        }
    
    )
    ScenarioInfo.M1P2S1:AddResultCallback(
    function(result)
        if(result) then
            ScenarioFramework.Dialogue(OpStrings.SecondaryObj2Complete, nil, true)
        end
    end
    )     
end

function P2Timer()
    
    WaitSeconds(3*60)

    if ScenarioInfo.MissionNumber == 2 then 
        local M2MapExpandDelay = {50*60, 40*60, 30*60}
        ScenarioInfo.M4P2 = Objectives.Timer(
            'primary',                      -- type
            'incomplete',                   -- complete
            'Capture Node Within Time Limit',                 -- title
            'The Cybran\'s are deleting the Mainframe Codes (MISSION WILL FAIL IF TIME RUNS OUT)',  -- description
            {                               -- target
                Timer = (M2MapExpandDelay[Difficulty]),
                ExpireResult = 'failed',
            }
        )
        ScenarioInfo.M4P2:AddResultCallback(
        function(result)
            if (not result) then
                ScenarioFramework.Dialogue(OpStrings.Objectivefailed3, PlayerLose, true)   
            end
        end
        )
    end
end

function Nukeparty()
    
    if Difficulty == 3 then
    
        local CybranNuke = ArmyBrains[Cybran1]:GetListOfUnits(categories.urb2305, false)
        WaitSeconds(35)
        IssueNuke({CybranNuke[1]}, ScenarioUtils.MarkerToPosition('NukeQ'))
        WaitSeconds(7*60)
        local plat = ArmyBrains[Cybran1]:MakePlatoon('', '')
        ArmyBrains[Cybran1]:AssignUnitsToPlatoon(plat, {CybranNuke[1]}, 'Attack', 'NoFormation')
        plat:ForkAIThread(plat.NukeAI)
        else
    
    end 
end

function EnableStealthOnAirC2()
    local T3AirUnits = {}
    while true do
        for _, v in ArmyBrains[Cybran2]:GetListOfUnits(categories.ura0303 + categories.ura0304, false) do
            if not ( T3AirUnits[v:GetEntityId()] or v:IsBeingBuilt() ) then
                v:ToggleScriptBit('RULEUTC_StealthToggle')
                T3AirUnits[v:GetEntityId()] = true
            end
        end
        WaitSeconds(10)
    end
end

function Cybran1ACUdeath()
    
    ScenarioFramework.CDRDeathNISCamera(ScenarioInfo.P2C1ACU, 4)
    ScenarioFramework.Dialogue(OpStrings.Death1, nil, true)
    ForkThread(P2KillCybran1Base)
    WaitSeconds(6)
    ScenarioFramework.Dialogue(OpStrings.React1P3, nil, true)   
end

function P2KillCybran1Base()
    local C1Units = ScenarioFramework.GetCatUnitsInArea((categories.ALLUNITS), 'ACU1area', ArmyBrains[Cybran1])
            for k, v in C1Units do
                if v and not v.Dead then
                v:Kill()
                WaitSeconds(Random(0.001, 0.003))
                end
            end
end

function EnableStealthOnAirC1()
    local T3AirUnits = {}
    while true do
        for _, v in ArmyBrains[Cybran1]:GetListOfUnits(categories.ura0303 + categories.ura0304, false) do
            if not ( T3AirUnits[v:GetEntityId()] or v:IsBeingBuilt() ) then
                v:ToggleScriptBit('RULEUTC_StealthToggle')
                T3AirUnits[v:GetEntityId()] = true
            end
        end
        WaitSeconds(10)
    end
end

function CounterAttackP2()

    local quantity = {}
    local trigger = {}
    local platoon

    -- sends Gunships if player has more than [60, 50, 40] Units, up to 10, 1 group per 14, 11, 10
    num = ScenarioFramework.GetNumOfHumanUnits(categories.ALLUNITS - categories.WALL)
    quantity = {300, 200, 150}
    trigger = {75, 60, 50}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 6) then
            num = 6
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Cybran1', 'P2C1AssaultGunships_D' .. Difficulty, 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P2C1IntAirattack' .. Random(1, 4))
        end
    end

    -- sends Strats if player has more than [70, 60, 50] Tech 2 Defenses, up to 6, 1 group per 25, 20, 15
    num = ScenarioFramework.GetNumOfHumanUnits(categories.STRUCTURE * categories.DEFENSE - categories.TECH1)
    quantity = {90, 60, 40}
    trigger = {50, 35, 25}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 5) then
            num = 5
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Cybran1', 'P2C1AssaultBomber_D' .. Difficulty, 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P2C1IntAirattack' .. Random(1, 4))
        end
    end

    -- sends ASF if player has more than [30, 20, 10] Air, up to 3, 1 group per 3, 2, 1
    num = ScenarioFramework.GetNumOfHumanUnits(categories.AIR * categories.MOBILE)
    quantity = {50, 25, 10}
    trigger = {25, 15, 10}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 5) then
            num = 5
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Cybran1', 'P2C1AssaultIntercept', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P2C1IntAirattack' .. Random(1, 4))
        end
    end

    for i = 1, Difficulty * 2 do
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Cybran1', 'P2C1AssaultDrops_D'.. Difficulty, 'GrowthFormation', 5)
        CustomFunctions.PlatoonAttackWithTransports(platoon, 'P2C1IntDrop', 'P2C1IntDropattack1', 'P2UTransportdeath', true)
    end

    for i = 1, 2 do
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Cybran1', 'P2C1AssaultNaval' .. i .. '_D' .. Difficulty, 'GrowthFormation', 1)
        ScenarioFramework.PlatoonPatrolChain(platoon, 'P2C1IntNavalattack' .. i)
    end

    -- sends Gunships if player has more than [60, 50, 40] Units, up to 10, 1 group per 14, 11, 10
    num = ScenarioFramework.GetNumOfHumanUnits(categories.TECH3 * categories.ALLUNITS)
    quantity = {150, 100, 80}
    trigger = {90, 70, 50}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 2) then
            num = 2
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Cybran1', 'P2C1AssaultExp', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonMoveChain(platoon, 'P2C1IntEXPattack')
        end
    end
end

-- Part 3

function Part3start()

    ForkThread(IntroP3)
end

function IntroP3()
    ScenarioFramework.FlushDialogueQueue()
    
    if ScenarioInfo.MissionNumber ~= 2 then
        return
    end
    ScenarioInfo.MissionNumber = 3

    if ScenarioInfo.M4P2.Active then
        ScenarioInfo.M4P2:ManualResult(true)  
    end
    
    WaitSeconds(5)
    
    ScenarioFramework.Dialogue(OpStrings.IntroP3, nil, true)
    
    ScenarioFramework.SetPlayableArea('AREA_3', true)
    
    ScenarioInfo.P3C2ACU = ScenarioFramework.SpawnCommander('Cybran2', 'C2ACU', false, 'Elite Commander Vladimir', true, false,
    {'AdvancedEngineering', 'T3Engineering', 'StealthGenerator', 'CloakingGenerator', 'MicrowaveLaserGenerator'})
    ScenarioInfo.P3C2ACU:SetAutoOvercharge(true)
    ScenarioInfo.P3C2ACU:SetVeterancy(2 + Difficulty)
    
    ScenarioInfo.P3C2ACU:AddBuildRestriction(categories.urb2301 + categories.urb1302 + categories.urb1202 + categories.urb1103 + categories.urb1106 + categories.urb1105 + categories.urb1201)
    
    P3CybranAI.C2P3Base1AI()
    P3CybranAI.C2P3Base2AI()
    P3CybranAI.P3C2B3EXPattacks()
    P2CybranAI.P2C2B1base1EXD()

    if Difficulty == 3 then
        ArmyBrains[Cybran1]:PBMSetCheckInterval(8)
        ArmyBrains[Cybran2]:PBMSetCheckInterval(8)
    end

    local Antinukes = ArmyBrains[Cybran2]:GetListOfUnits(categories.urb4302, false)
    for _, v in Antinukes do
        v:GiveTacticalSiloAmmo(4)
    end
    
    ScenarioUtils.CreateArmyGroup('Cybran2', 'P3C2wall')
    
    
    -- Cybran Objective attacks on QAI
    
    ScenarioInfo.Meg2 = ScenarioUtils.CreateArmyUnit('Cybran2', 'Meg2')
    ScenarioFramework.GroupMoveChain({ScenarioInfo.Meg2}, 'P3C2Objective2')
    
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran2', 'P3Attack1_D' .. Difficulty, 'GrowthFormation')
    for _, v in platoon:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P2C2B1Airpatrol1')))
    end
    
    -- Second Megalith attack
    
    ForkThread(
        function()
            WaitSeconds(6*60)
            if Difficulty == 3 then
                platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran2', 'P3Attack2', 'GrowthFormation')
                ScenarioFramework.PlatoonPatrolChain(platoon, 'P3C2Objective1')
            end
    
            ScenarioInfo.Meg1 = ScenarioUtils.CreateArmyUnit('Cybran2', 'Meg1')
            ScenarioFramework.GroupMoveChain({ScenarioInfo.Meg1}, 'P3C2Objective1')
        end
    )
    
    -- Air Defense Groups
    
    local units = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran2', 'P3B1Airunits1_D' .. Difficulty, 'AttackFormation')
    for _, v in units:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P3C2B1Airdef1')))
    end
     
    units = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran2', 'P3B3Airunits1_D' .. Difficulty, 'AttackFormation')
    for _, v in units:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P3C2B3Airdef1')))
    end
    
    -- Naval Defense Groups 
    
    units = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran2', 'P3Navalunits1_D' .. Difficulty, 'AttackFormation')
    for _, v in units:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P3C2Navaldefense1')))
    end
    
    units = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran2', 'P3Navalunits2_D' .. Difficulty, 'AttackFormation')
    for _, v in units:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P3C2Navaldefense2')))
    end
    
    -- Land Defense Groups
    
    units = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran2', 'P3B2Landunits1_D' .. Difficulty, 'AttackFormation')
    for _, v in units:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P3C2B2Landdefence1')))
    end
     
    units = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran2', 'P3B1Landunits1_D' .. Difficulty, 'AttackFormation')
    for _, v in units:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P3C2B1Landdefence1')))
    end
    
    -- Cutscene
    
    Cinematics.EnterNISMode()
                
        local VisMarker3_1 = ScenarioFramework.CreateVisibleAreaLocation(60,'P3Vision1', 0, ArmyBrains[Player1])
        local VisMarker3_2 = ScenarioFramework.CreateVisibleAreaLocation(75,'P3Vision2', 0, ArmyBrains[Player1])
        local VisMarker3_3 = ScenarioFramework.CreateVisibleAreaLocation(50,'P3Vision3', 0, ArmyBrains[Player1])
                        
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P3Cam0'), 2)
        
        local qaiuunits = ScenarioFramework.GetCatUnitsInArea((categories.ALLUNITS), 'AREA_3', ArmyBrains[QAI])
            for k, v in qaiuunits do
                if v and not v:IsDead() and (v:GetAIBrain() == ArmyBrains[QAI]) then
                    ScenarioFramework.GiveUnitToArmy( v, Player1 )
                end
            end

        WaitSeconds(2)
        ScenarioInfo.MF1:Destroy()
        ScenarioInfo.Mainframe = ScenarioUtils.CreateArmyUnit('QAI', 'Mainframe')

        ScenarioFramework.FakeTeleportUnit(ScenarioInfo.P2QACU, true)

        local Nodeunits = ScenarioFramework.GetCatUnitsInArea((categories.ALLUNITS), 'AREA_3', ArmyBrains[Nodes])
            for k, v in Nodeunits do
                if v and not v:IsDead() and (v:GetAIBrain() == ArmyBrains[Nodes]) then
                    ScenarioFramework.GiveUnitToArmy( v, QAI )
                end
            end
        WaitSeconds(2)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P3Cam1'), 3)
        WaitSeconds(3)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P3Cam2'), 5)
        
        WaitSeconds(4)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P3Cam3'), 4)
        WaitSeconds(4)
        ForkThread(
            function ()
                WaitSeconds(1)
                VisMarker3_1:Destroy()
                VisMarker3_2:Destroy()
                VisMarker3_3:Destroy()
                WaitSeconds(1)
                ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('P3Vision1'), 70)
                ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('P3Vision2'), 85)
                ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('P3Vision3'), 60)
            end 
        )
            
    Cinematics.ExitNISMode()
    
    -- Complete QAI ACU objective
    
    ScenarioInfo.M2P2:ManualResult(true)    
    
    -- Cybran Eco buffs 
     
    ForkThread(MissionP3)
    ForkThread(CounterAttackP3)
    ForkThread(P3SecondaryBases)
    ForkThread(SetupCybranM3TauntTriggers)  
    ForkThread(Nukeparty2)  
    ForkThread(P3Specialattack)
end

function MissionP3()
    
    ScenarioInfo.M1P3 = Objectives.Kill(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Kill The Second Cybran Commander',                 -- title
        'Eliminate the Cybran commander east of the mainframe.',  -- description
        {                               -- target
            Units = {ScenarioInfo.P3C2ACU} 
        }
    )
    ScenarioInfo.M1P3:AddResultCallback(
    function(result)
        if(result) then
            ForkThread(Cybran2ACUdeath) 
        end
    end
    )
    
    WaitSeconds(2)
    
    ScenarioInfo.M2P3 = Objectives.Kill(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Destroy The Megalith',                 -- title
        'The Cybran has deployed a Megalith with the same technology that stoped QAI the first time, destroy it.',  -- description
        {                               -- target
            MarkUnits = true,
            Units = {ScenarioInfo.Meg2}  
        }
    )

    ScenarioInfo.M4P3 = Objectives.Protect(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Protect QAI\'s Mainframe',    -- title
        'QAI\'s central Mainframe is still vulnerable defend it.', -- description
       
        {                              -- target
            MarkUnits = true,
            Units = {ScenarioInfo.Mainframe} 
        }
    )   
    ScenarioInfo.M4P3:AddResultCallback(
        function(result, unit)
            if (not result and not ScenarioInfo.OpEnded) then
                ScenarioFramework.CDRDeathNISCamera(unit)
                ScenarioFramework.EndOperationSafety()

                ScenarioFramework.FlushDialogueQueue()
                ScenarioFramework.Dialogue(OpStrings.Objectivefailed1, nil, true)
                PlayerLose()
            end
        end
    )

    ForkThread(P3SecondMegalith)
    
    ScenarioInfo.M3Objectives = Objectives.CreateGroup('M3Objectives', P3End)
    ScenarioInfo.M3Objectives:AddObjective(ScenarioInfo.M1P3)
    if ScenarioInfo.M2P2.Active then
        ScenarioInfo.M3Objectives:AddObjective(ScenarioInfo.M2P2)
    end   
end

function KillP3QNode()
    ScenarioInfo.Node3:Destroy()
end

function P3SecondMegalith()

    WaitSeconds(6.5*60)
    ScenarioFramework.Dialogue(OpStrings.Meg2P3, nil, true)

    ScenarioInfo.M3P3 = Objectives.Kill(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Destroy The Second Megalith',                 -- title
        'The Cybran has deployed Megaliths with the same technology that stoped QAI the first time, destroy them.',  -- description
        {                               -- target
            MarkUnits = true,
            Units = {ScenarioInfo.Meg1}  
        }
    )
end

function P3SecondaryBases()
 
    ScenarioInfo.M1P3S1 = Objectives.CategoriesInArea(
    'secondary',                      -- type
    'incomplete',                   -- complete
    'Destroy Support Bases',    -- title
    'The Cybran has several support bases in the area, destroy them.',  -- description
    'kill',                         -- action
        {                               -- target
            MarkUnits = true,
            Requirements = {
                {   
                    Area = 'P3SObj1',
                    Category = categories.urb2302 + categories.url0309 + categories.FACTORY + categories.TECH3 * categories.ECONOMIC,
                    CompareOp = '==',
                    Value = 0,
                    ArmyIndex = Cybran2,
                },
                {   
                    Area = 'P3SObj2',
                    Category = categories.urb2302 + categories.url0309 + categories.FACTORY + categories.TECH3 * categories.ECONOMIC,
                    CompareOp = '==',
                    Value = 0,
                    ArmyIndex = Cybran2,
                },
                {   
                    Area = 'P3SObj3',
                    Category = categories.urb2302 + categories.url0309 + categories.FACTORY + categories.TECH3 * categories.ECONOMIC,
                    CompareOp = '==',
                    Value = 0,
                    ArmyIndex = Cybran2,
                },
            },
        }
    ) 
end

--Cybran Nuke AI during Phase 3, platoon.lua is used in this case
function Nukeparty2()
    WaitSeconds(1*60)
    --Get a table of all UEF SMLs
    local CybranNuke2 = ArmyBrains[Cybran2]:GetListOfUnits(categories.urb2305, false)
        
        --Only do something if there is at least 1 SML in the table
        if table.getn(CybranNuke2) > 0 then
            for k, v in CybranNuke2 do
                --Loop through each SML, and only enable the NukeAI for an instance if it hasn't been enabled yet
                if not v.SiloAIEnabled and not v:IsDead() then
                    --Make a single unit platoon for each SML
                    local SiloPlatoon = ArmyBrains[Cybran2]:MakePlatoon('','')
                    ArmyBrains[Cybran2]:AssignUnitsToPlatoon(SiloPlatoon, {v}, 'Attack', 'None')
                    --Platoon gets the AI function called
                    SiloPlatoon:ForkAIThread(SiloPlatoon.NukeAI)
                    --Flag to check if the NukeAI has already been called for the SML instance
                    v.SiloAIEnabled = true
                end
            end
        end
    --Check for SMLs every 60 seconds
    ScenarioFramework.CreateTimerTrigger(Nukeparty2, 60)
end

function Cybran2ACUdeath()

    ScenarioFramework.CDRDeathNISCamera(ScenarioInfo.P3C2ACU, 4)
    ScenarioFramework.Dialogue(OpStrings.Death2, nil, true)
end

function CounterAttackP3()

    local quantity = {}
    local trigger = {}
    local platoon

    -- sends Gunships if player has more than [60, 50, 40] Units, up to 10, 1 group per 14, 11, 10
    num = ScenarioFramework.GetNumOfHumanUnits(categories.ALLUNITS * categories.TECH3)
    quantity = {100, 75, 50}
    trigger = {75, 45, 25}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 8) then
            num = 8
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Cybran2', 'P3C2AssaultGunship', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P3C2IntAssault' .. Random(1, 5))
        end
    end

    -- sends Strats if player has more than [70, 60, 50] Tech 2 Defenses, up to 6, 1 group per 25, 20, 15
    num = ScenarioFramework.GetNumOfHumanUnits(categories.STRUCTURE * categories.DEFENSE - categories.TECH1)
    quantity = {90, 70, 50}
    trigger = {50, 35, 25}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 8) then
            num = 8
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Cybran2', 'P3C2AssaultBomber', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P3C2IntAssault' .. Random(1, 5))
        end
    end

    -- sends ASF if player has more than [30, 20, 10] Air, up to 3, 1 group per 3, 2, 1
    num = ScenarioFramework.GetNumOfHumanUnits(categories.AIR * categories.MOBILE)
    quantity = {40, 30, 20}
    trigger = {20, 15, 10}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 8) then
            num = 8
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Cybran2', 'P3C2AssaultIntercept', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P3C2IntAssault' .. Random(1, 5))
        end
    end

    for i = 1, Difficulty * 2 do
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Cybran2', 'P3C2AssaultDrop_D'.. Difficulty, 'GrowthFormation', 5)
        CustomFunctions.PlatoonAttackWithTransports(platoon, 'P3C2IntAssaultDrop', 'P3C2IntAssaultDropA', 'P2UTransportdeath', true)
    end

    -- sends Gunships if player has more than [60, 50, 40] Units, up to 10, 1 group per 14, 11, 10
    num = ScenarioFramework.GetNumOfHumanUnits(categories.EXPERIMENTAL)
    quantity = {3, 2, 1}
    trigger = {3, 2, 1}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 5) then
            num = 5
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Cybran2', 'P3C2AssaultExp', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P3C2IntAssault' .. i)
        end
    end
end

function P3Specialattack()
    
    ScenarioInfo.Specialfunction = Random(1, 3)
    
    if  ScenarioInfo.Specialfunction == 1 then
    
        P3CybranAI.P3R1Base1AI()
    
        else
        if  ScenarioInfo.Specialfunction == 2 then
        
            P3CybranAI.P3R1Base2AI()

            else
            if  ScenarioInfo.Specialfunction == 3 then
        
                ScenarioUtils.CreateArmyGroup('Cybran2', 'P3C2Random3_D'.. Difficulty)
            end
        end
    end
end

-- Misc Functions

function P3End()
    WaitSeconds(2)
    ForkThread(PlayerWin)
end

function PlayerWin()
    if(not ScenarioInfo.OpEnded) then
        WaitSeconds(6)
        ScenarioInfo.OpComplete = true
        ScenarioInfo.M4P3:ManualResult(true)
        WaitSeconds(2)
        KillGame()
    end
end

function KillGame()
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

function KillGame()
    UnlockInput()
    ScenarioFramework.EndOperation(ScenarioInfo.OpComplete, ScenarioInfo.OpComplete, true)
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

--Taunts

function SetupCybranM1TauntTriggers()

    if ScenarioInfo.MissionNumber == 1 then
        CybranTM:AddEnemiesKilledTaunt('TAUNT1P1', ArmyBrains[Cybran1], categories.STRUCTURE, 10)
        CybranTM:AddUnitsKilledTaunt('TAUNT2P1', ArmyBrains[Cybran1], categories.STRUCTURE * categories.ECONOMIC, 10)
        CybranTM:AddUnitsKilledTaunt('TAUNT3P1', ArmyBrains[Cybran1], categories.STRUCTURE * categories.FACTORY, 4)
    end 
end

function SetupCybranM2TauntTriggers()
    
    if ScenarioInfo.MissionNumber == 2 then
        CybranTM:AddTauntingCharacter(ScenarioInfo.P2C1ACU)
    
        CybranTM:AddEnemiesKilledTaunt('TAUNT1P2', ArmyBrains[Cybran1], categories.STRUCTURE, 10)
        CybranTM:AddUnitsKilledTaunt('TAUNT2P2', ArmyBrains[Cybran1], categories.MOBILE + categories.DESTROYER, 5)
        CybranTM:AddUnitsKilledTaunt('TAUNT3P2', ArmyBrains[Cybran1], categories.STRUCTURE * categories.FACTORY, 4)
    
        CybranTM:AddEnemiesKilledTaunt('TAUNT5P2', ArmyBrains[Cybran2], categories.STRUCTURE , 20)
        CybranTM:AddUnitsKilledTaunt('TAUNT6P2', ArmyBrains[Cybran2], categories.MOBILE * categories.TECH3, 40)
    
        CybranTM:AddDamageTaunt('TAUNT4P2', ScenarioInfo.P2C1ACU, .50)
    
        CybranTM:AddDamageTaunt('TAUNT7P2', ScenarioInfo.P2QACU, .50)
    end   
end

function SetupCybranM3TauntTriggers()
    
    if ScenarioInfo.MissionNumber == 3 then
        CybranTM:AddTauntingCharacter(ScenarioInfo.P3C2ACU)
    
        CybranTM:AddEnemiesKilledTaunt('TAUNT1P3', ArmyBrains[Cybran2], categories.STRUCTURE, 10)
        CybranTM:AddUnitsKilledTaunt('TAUNT2P3', ArmyBrains[Cybran2], categories.MOBILE + categories.DESTROYER, 5)
        CybranTM:AddUnitsKilledTaunt('TAUNT3P3', ArmyBrains[Cybran2], categories.STRUCTURE * categories.FACTORY, 3)
    
        CybranTM:AddDamageTaunt('TAUNT4P3', ScenarioInfo.P3C2ACU, .50)
    end 
end

function DestroyUnit(unit)

    unit:Destroy() 
end
