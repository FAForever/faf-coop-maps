------------------------------
-- Seraphim Campaign - Mission 4
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
local AIBuildStructures = import('/lua/ai/aibuildstructures.lua')
local P1OrderAI = import('/maps/FAF_Coop_Operation_Ioz_Shavoh_Kael/OrderaiP1.lua')
local P2OrderAI = import('/maps/FAF_Coop_Operation_Ioz_Shavoh_Kael/OrderaiP2.lua')
local P4OrderAI = import('/maps/FAF_Coop_Operation_Ioz_Shavoh_Kael/OrderaiP4.lua')
local P3UEFAI = import('/maps/FAF_Coop_Operation_Ioz_Shavoh_Kael/UEFaiP3.lua')
local P4UEFAI = import('/maps/FAF_Coop_Operation_Ioz_Shavoh_Kael/UEFaiP4.lua')
local OpStrings = import('/maps/FAF_Coop_Operation_Ioz_Shavoh_Kael/FAF_Coop_Operation_Ioz_Shavoh_Kael_strings.lua') 
local CustomFunctions = import('/maps/FAF_Coop_Operation_Ioz_Shavoh_Kael/FAF_Coop_Operation_Ioz_Shavoh_Kael_CustomFunctions.lua')

local TauntManager = import('/lua/TauntManager.lua')

local ORDERTM = TauntManager.CreateTauntManager('ORDERTM', '/maps/FAF_Coop_Operation_Ioz_Shavoh_Kael/FAF_Coop_Operation_Ioz_Shavoh_Kael_strings.lua')
local UEFTM = TauntManager.CreateTauntManager('UEFTM', '/maps/FAF_Coop_Operation_Ioz_Shavoh_Kael/FAF_Coop_Operation_Ioz_Shavoh_Kael_strings.lua')

ScenarioInfo.Player1 = 1
ScenarioInfo.Kael = 2
ScenarioInfo.Order = 3
ScenarioInfo.KOrder = 4
ScenarioInfo.UEF = 5
ScenarioInfo.Player2 = 6
ScenarioInfo.Player3 = 7
ScenarioInfo.Player4 = 8

local Difficulty = ScenarioInfo.Options.Difficulty
local ExpansionTimer = ScenarioInfo.Options.Expansion == 'true'

local Player1 = ScenarioInfo.Player1
local Player2 = ScenarioInfo.Player2
local Player3 = ScenarioInfo.Player3
local Player4 = ScenarioInfo.Player4
local Kael = ScenarioInfo.Kael
local Order = ScenarioInfo.Order
local KOrder = ScenarioInfo.KOrder
local UEF = ScenarioInfo.UEF

local LeaderFaction
local LocalFaction
local AIs = {UEF, Order, KOrder, Kael}
local BuffCategories = {
    BuildPower = (categories.FACTORY * categories.STRUCTURE) + categories.ENGINEER,
    Economy = categories.ECONOMIC,
}

local SkipNIS2 = false
local SkipNIS3 = false

local Debug = false

local AssignedObjectives = {}

local NIS1InitialDelay = 3

function OnPopulate(scen)

    ScenarioUtils.InitializeScenarioArmies()
        
    ScenarioFramework.SetSeraphimColor(Player1)
    ScenarioFramework.SetAeonEvilColor(KOrder)
    ScenarioFramework.SetUEFPlayerColor(UEF)
    
    local colors = {
    ['Player2'] = {255, 191, 128}, 
    ['Player3'] = {189, 116, 16}, 
    ['Player4'] = {89, 133, 39},
    ['Order'] = {95, 1, 167},
    ['Kael'] = {123, 255, 125}
    }
    
    local tblArmy = ListArmies()
    for army, color in colors do
        if tblArmy[ScenarioInfo[army]] then
            ScenarioFramework.SetArmyColor(ScenarioInfo[army], unpack(color))
        end
    end

    SetArmyUnitCap(KOrder, 3000)
    SetArmyUnitCap(Order, 3000)
    SetArmyUnitCap(Kael, 3000)
    SetArmyUnitCap(UEF, 3000)
    ScenarioFramework.SetSharedUnitCap(4800)
end

function OnStart(scen)
    
    ScenarioFramework.SetPlayableArea('AREA_1', false)   
    
    for _, Player in ScenarioInfo.HumanPlayers do
        ScenarioFramework.AddRestriction(Player,
            categories.UEF + -- UEF faction 
            categories.xsa0402 + -- Exp bomber
            categories.xsb2401 + -- Super Nuke
            categories.url0401 + -- Scathis
            categories.xrl0403 + -- Megalith
            categories.xab1401 + -- Paragon
            categories.uaa0310 + -- Exp Carrier
            categories.xab2307 -- Salvation
        )
    end
    
    ScenarioUtils.CreateArmyGroup('Order', 'P1O1Intial1')
    ScenarioUtils.CreateArmyGroup('KOrder', 'P1KO1MiscB')
    
    P1OrderAI.P1KO1Base1AI()
    P1OrderAI.P1O1Base1AI()
    
    for _, army in AIs do
        ArmyBrains[army].IMAPConfig = {
                OgridRadius = 0,
                IMAPSize = 0,
                Rings = 0,
        }
        ArmyBrains[army]:IMAPConfiguration()
    end

    ForkThread(BuffAIEconomy)   
    GetArmyBrain(Order):SetResourceSharing(false)
    
    ForkThread(IntroP1)
end

---Part 1

function IntroP1()
    
    ScenarioInfo.MissionNumber = 1

    if not SkipNIS2 then
    Cinematics.EnterNISMode()
    
        ScenarioInfo.M1ObjectiveUnits = {}
    
        ScenarioInfo.P1O1ACU = ScenarioFramework.SpawnCommander('Order', 'O1SACU', false, 'Jareth', true, false,
            {'StabilitySuppressant', 'ShieldHeavy', 'EngineeringFocusingModule'})
    
        local basereval1 = ScenarioFramework.CreateVisibleAreaLocation(50, ScenarioUtils.MarkerToPosition('Vision1P1'), 0, ArmyBrains[Player1])
    
        local units = ScenarioUtils.CreateArmyGroupAsPlatoon('KOrder', 'P1KO1group4', 'GrowthFormation')
        for _, v in units:GetPlatoonUnits() do
            ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P1KOIntCutscene2')))
        end
    
        local NISunits1 = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'P1O1Group1', 'GrowthFormation')
    
        units = ScenarioUtils.CreateArmyGroupAsPlatoon('KOrder', 'P1KO1group5', 'GrowthFormation')
        for _, v in units:GetPlatoonUnits() do
            ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P1KOIntCutscene2')))
        end
    
        local M1Units1 = ScenarioUtils.CreateArmyGroupAsPlatoon('KOrder', 'P1KO1group1_D' .. Difficulty, 'GrowthFormation')
        for _, v in M1Units1:GetPlatoonUnits() do
            ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P1KOIntCutscene1')))
        end
  
        for _, v in M1Units1:GetPlatoonUnits() do
            table.insert(ScenarioInfo.M1ObjectiveUnits, v)
        end
    
        ScenarioFramework.Dialogue(OpStrings.Intro1P1, nil, true)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P1Cam1'), 0)
        WaitSeconds(3)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P1Cam2'), 4)
        WaitSeconds(5)
    
        local M1Units2 = ScenarioUtils.CreateArmyGroupAsPlatoon('KOrder', 'P1KO1group3_D'.. Difficulty, 'GrowthFormation')
        for _, v in M1Units2:GetPlatoonUnits() do
            ScenarioFramework.GroupAttackChain({v}, 'P1KOIntCutscene1')
        end
    
        for _, v in M1Units2:GetPlatoonUnits() do
            table.insert(ScenarioInfo.M1ObjectiveUnits, v)
        end
    
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P1Cam3'), 4)
        WaitSeconds(3)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P1Cam4'), 4)
        WaitSeconds(3)
    
        local Orderunits = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'P1O1Group2', 'GrowthFormation')
        for _, v in Orderunits:GetPlatoonUnits() do
            ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P1OIntCutscene1')))
        end
    
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P1Cam5'), 4)
        WaitSeconds(3)
        ScenarioFramework.Dialogue(OpStrings.Intro2P1, nil, true)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P1Cam6'), 2)
        
        ForkThread(
            function()
                WaitSeconds(2)
                basereval1:Destroy()
            end
        )
        
        DestroyUnit(NISunits1)
    
    Cinematics.ExitNISMode()
    
    ScenarioInfo.PlayerCDR = ScenarioFramework.SpawnCommander('Player1', 'Commander', 'Warp', true, true, PlayerDeath)

    -- spawn coop players too
    ScenarioInfo.CoopCDR = {}
    local tblArmy = ListArmies()
    coop = 1
    for iArmy, strArmy in pairs(tblArmy) do
        if iArmy >= ScenarioInfo.Player2 then
            factionIdx = GetArmyBrain(strArmy):GetFactionIndex()
            if (factionIdx == 3) then
                ScenarioInfo.CoopCDR[coop] = ScenarioFramework.SpawnCommander(strArmy, 'CCommander', 'Warp', true, true, PlayerDeath)
            elseif (factionIdx == 2) then
                ScenarioInfo.CoopCDR[coop] = ScenarioFramework.SpawnCommander(strArmy, 'ACommander', 'Warp', true, true, PlayerDeath)
            else
                ScenarioInfo.CoopCDR[coop] = ScenarioFramework.SpawnCommander(strArmy, 'Commander', 'Warp', true, true, PlayerDeath)   
           end
            coop = coop + 1
            WaitSeconds(0.5)
        end
    end 
   
    for k, v in Orderunits:GetPlatoonUnits() do
        if v and not v:IsDead() and (v:GetAIBrain() == ArmyBrains[Order]) then
                ScenarioFramework.GiveUnitToArmy( v, Player1 )
        end
    end

    local Orderunits2 = ScenarioFramework.GetCatUnitsInArea((categories.ALLUNITS), 'AREA_M1', ArmyBrains[Order])
    for k, v in Orderunits2 do
        if v and not v:IsDead() and (v:GetAIBrain() == ArmyBrains[Order]) then
            ScenarioFramework.GiveUnitToArmy( v, Player1 )
        end
    end
            
    ForkThread(Mission1)
    
    ForkThread(
        function()
            WaitSeconds(90) 
            ScenarioFramework.Dialogue(OpStrings.Intro3P1, nil, true)
            SetupORDERTM1TauntTriggers()
        end
    )

    ForkThread(
        function()
            WaitSeconds(12*60) 
            ScenarioFramework.Dialogue(OpStrings.MidP1, nil, true)
        end
    )

    else
        ScenarioFramework.SpawnCommander( 'Player1', 'ACUP1', 'Warp', true, true, false)
        
        ForkThread(Mission1)
    end 
end

function Mission1()

    local function MissionNameAnnouncement()
        ScenarioFramework.SimAnnouncement(ScenarioInfo.name, "Mission by Shadowlorda1")
    end

    ScenarioFramework.CreateTimerTrigger(MissionNameAnnouncement, 12)

    ScenarioInfo.M1P1 = Objectives.Kill(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Survive Order Assault',                 -- title
        'Destroy the traitorous Order forces.',  -- description
        {                               -- target
            ShowProgress = true,
            Units = ScenarioInfo.M1ObjectiveUnits 
        }
    )
    
    ScenarioInfo.M2P1 = Objectives.CategoriesInArea(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Destroy Kael\'s Order base',                 -- title
        'Eliminate the Order base in the area.',  -- description
        'kill',                         -- action
        {                               -- target
            MarkUnits = true,
            ShowProgress = true,
            Requirements = {
                {   
                    Area = 'AREA_M2',
                    Category = categories.FACTORY + categories.TECH3 * categories.STRUCTURE * categories.ECONOMIC,
                    CompareOp = '<=',
                    Value = 0,
                    ArmyIndex = KOrder,
                },
            },
        }
    )

    ScenarioInfo.M1Objectives = Objectives.CreateGroup('M1Objectives', StartIntroP2)
    ScenarioInfo.M1Objectives:AddObjective(ScenarioInfo.M2P1)
    ScenarioInfo.M1Objectives:AddObjective(ScenarioInfo.M1P1)
   
    if ExpansionTimer then
        local M1MapExpandDelay = {50*60, 40*60, 30*60}
        ScenarioFramework.CreateTimerTrigger(StartIntroP2, M1MapExpandDelay[Difficulty])
    end
    ScenarioFramework.CreateArmyIntelTrigger(SecondaryMissionP1, ArmyBrains[Player1], 'LOSNow', false, true, categories.CARRIER, true, ArmyBrains[KOrder])
end

--Part 2

function StartIntroP2()
    ForkThread(IntroP2)
end

function IntroP2()
    ScenarioFramework.FlushDialogueQueue()
    
    if ScenarioInfo.MissionNumber ~= 1 then
        return
    end
    ScenarioInfo.MissionNumber = 2

    WaitSeconds(5)

    ScenarioFramework.SetPlayableArea('AREA_2', true)
    
    ScenarioUtils.CreateArmyGroup('Order', 'P2O1Bwalls')
    ScenarioUtils.CreateArmyGroup('KOrder', 'P2KO1Bwalls')
    
    P2OrderAI.P2KO1Base1AI()
    P2OrderAI.P2O1Base1AI()
    
    ForkThread(RemoveP1O1ACU)
    
    ScenarioInfo.P1P1ACU = ScenarioFramework.SpawnCommander('Player1', 'P1SACU', false, 'Jareth', true, false,
    {'StabilitySuppressant', 'ShieldHeavy', 'EngineeringFocusingModule'})
    
    if not SkipNIS3 then
    
    Cinematics.EnterNISMode()
        Cinematics.SetInvincible('AREA_1') 
            local units = ScenarioUtils.CreateArmyGroupAsPlatoon('KOrder', 'P2KO1group2', 'GrowthFormation')
            for _, v in units:GetPlatoonUnits() do
                ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P2KOIntCutscene1')))
            end
    
            units = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'P2O1group1', 'GrowthFormation')
            units = ScenarioUtils.CreateArmyGroupAsPlatoon('KOrder', 'P2KO1group1', 'GrowthFormation')
    
            units = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'P2O1group2', 'GrowthFormation')
            for _, v in units:GetPlatoonUnits() do
                ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P2OIntCutscene')))
            end
    
            units = ScenarioUtils.CreateArmyGroupAsPlatoon('KOrder', 'P2KO1group4_D'.. Difficulty, 'GrowthFormation')
            for _, v in units:GetPlatoonUnits() do
                ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P2KOB1Airdefense1')))
            end
        
            units = ScenarioUtils.CreateArmyGroupAsPlatoon('KOrder', 'P2KO1group5_D'.. Difficulty, 'GrowthFormation')
            for _, v in units:GetPlatoonUnits() do
                ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P2KOB1Navaldefense1')))
            end
    
            units = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'P2O1group3', 'GrowthFormation')
            for _, v in units:GetPlatoonUnits() do
                ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P2OB1Airdefense1')))
            end
    
            units = ScenarioUtils.CreateArmyGroupAsPlatoon('KOrder', 'P2KO1group3_D'.. Difficulty, 'GrowthFormation')
            for _, v in units:GetPlatoonUnits() do
                ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P2KOB1Landdefense1')))
            end

            ScenarioFramework.Dialogue(OpStrings.Intro1P2, nil, true)
            Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P2Cam1'), 0)
            ForkThread(Nukeparty)
            WaitSeconds(5)
            Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P2Cam2'), 5)
            WaitSeconds(4)
            ScenarioFramework.Dialogue(OpStrings.Intro2P2, nil, true)
            Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P2Cam3'), 0)
            WaitSeconds(4)

            ScenarioInfo.P2O1ACU = ScenarioFramework.SpawnCommander('Order', 'O1ACU', false, 'Executioner Havra', false, OrderACUdeath,
                {'AdvancedEngineering', 'T3Engineering', 'Shield', 'ShieldHeavy', 'EnhancedSensors'})
                ScenarioInfo.P2O1ACU:SetAutoOvercharge(true)
                ScenarioInfo.P2O1ACU:SetVeterancy(1 + Difficulty)
    
                ScenarioInfo.P2O1ACU:AddBuildRestriction(categories.zab9603 + categories.uab0303 + categories.uab2205 + categories.uab2109 + categories.uab2304 + categories.uab0203 + categories.uab0103)
    
            ScenarioInfo.P2KO1ACU = ScenarioFramework.SpawnCommander('KOrder', 'KO1ACU', false, 'Crusader Keleana', false, KOrderACUdeath,
                {'CrysalisBeam', 'ResourceAllocation', 'ResourceAllocationAdvanced', 'HeatSink'})
                ScenarioInfo.P2KO1ACU:SetAutoOvercharge(true)
                ScenarioInfo.P2KO1ACU:SetVeterancy(1 + Difficulty)
    
                ScenarioInfo.P2KO1ACU:AddBuildRestriction(categories.zab9603 + categories.uab0303 + categories.uab2205 + categories.uab2109 + categories.uab2304 + categories.uab0203 + categories.uab0103)
    
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P2Cam2'), 0)
        WaitSeconds(7)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P2Cam1'), 6)
        WaitSeconds(3)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P2Cam4'), 2)
        WaitSeconds(3)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P1Cam6'), 2)
    
        ScenarioFramework.Dialogue(OpStrings.Intro3P2, nil, true)
     
        for _, player in ScenarioInfo.HumanPlayers do
            SetAlliance(player, Order, 'Enemy')
            SetAlliance(Order, player, 'Enemy')
            SetAlliance(KOrder, Order, 'Ally')
            SetAlliance(Order, KOrder, 'Ally')
        end
    
        local Orderunits = ScenarioFramework.GetCatUnitsInArea((categories.ALLUNITS), 'AREA_M4', ArmyBrains[Order])
            for k, v in Orderunits do
                if v and not v:IsDead() and (v:GetAIBrain() == ArmyBrains[Order]) then
                    ScenarioFramework.GiveUnitToArmy( v, Player1 )
                end
            end
    
        WaitSeconds(1)
    
        ScenarioUtils.CreateArmyGroup('Order', 'P2O1OuterD')
        ScenarioUtils.CreateArmyGroup('KOrder', 'P2KO1OuterD')
    
        units = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'P2O1Exp', 'GrowthFormation')
        ScenarioFramework.PlatoonPatrolChain(units, 'P2OB1Landdefense1')

        local AntinukesOK = ArmyBrains[KOrder]:GetListOfUnits(categories.uab4302, false)
        for _, v in AntinukesOK do
            v:GiveTacticalSiloAmmo(5)
        end

        local AntinukesO = ArmyBrains[Order]:GetListOfUnits(categories.uab4302, false)
        for _, v in AntinukesO do
            v:GiveTacticalSiloAmmo(5)
        end

        Cinematics.SetInvincible('AREA_1', true) 
    Cinematics.ExitNISMode()
    
    ForkThread(Mission2)
    ForkThread(CounterAttackP2)
    ForkThread(SecondaryMissionP2)
    
    else
    
        for _, player in ScenarioInfo.HumanPlayers do
            SetAlliance(player, Order, 'Enemy')
            SetAlliance(Order, player, 'Enemy')
            SetAlliance(KOrder, Order, 'Ally')
            SetAlliance(Order, KOrder, 'Ally')
        end
    
        ScenarioInfo.P2O1ACU = ScenarioFramework.SpawnCommander('Order', 'O1ACU', false, 'Executioner Havra', true, false,
        {'AdvancedEngineering', 'T3Engineering', 'Shield', 'ShieldHeavy', 'EnhancedSensors'})
    
        ScenarioInfo.P2KO1ACU = ScenarioFramework.SpawnCommander('KOrder', 'KO1ACU', false, 'Executioner Keleana', true, false,
        {'CrysalisBeam', 'ResourceAllocation', 'ResourceAllocationAdvanced', 'HeatSink'})
    
        ScenarioUtils.CreateArmyGroup('Order', 'P2O1OuterD')
        ScenarioUtils.CreateArmyGroup('KOrder', 'P2KO1OuterD')
        ForkThread(Mission2)
    end

    SetupORDERTM2TauntTriggers()
    
    ForkThread(
        function()
            WaitSeconds(3*60)
            ScenarioFramework.Dialogue(OpStrings.MidP2, nil, true)
        end
    )
end

function RemoveP1O1ACU()

    ScenarioInfo.P1O1ACU:Destroy()
end

function Nukeparty()

    local AeonNuke = ArmyBrains[Order]:GetListOfUnits(categories.uab2305, false)
        WaitSeconds(2)
        IssueNuke({AeonNuke[1]}, ScenarioUtils.MarkerToPosition('Nuke1'))
        WaitSeconds(6*60)
        if not AeonNuke.Dead then
            local plat = ArmyBrains[Order]:MakePlatoon('', '')
            ArmyBrains[Order]:AssignUnitsToPlatoon(plat, {AeonNuke[1]}, 'Attack', 'NoFormation')
            plat:ForkAIThread(plat.NukeAI)
        end
end

function Mission2()
    
    ScenarioInfo.M1P2 = Objectives.Kill(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Kill Commander Havra',                -- title
        'The Order Commander has betrayed us, kill her.', -- description
        {                              -- target
            MarkUnits = true,
            Units = {ScenarioInfo.P2O1ACU}  
        }
    )
    ScenarioInfo.M1P2:AddResultCallback(
        function(result)
            if (result) then
                ForkThread(P2KillOrderBase)
            end
        end
    )
    
    ScenarioInfo.M2P2 = Objectives.Kill(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Kill Commander Keleana',                -- title
        'Kael\'s Commander has convinced our Order Commander to betray us, kill her.', -- description
        {                              -- target
            MarkUnits = true,
            Units = {ScenarioInfo.P2KO1ACU}  
        }
    )
    ScenarioInfo.M2P2:AddResultCallback(
        function(result)
            if result then
                ForkThread(P2KillKOrderBase)
            end
        end
    )
    
    ScenarioInfo.M1P2S2 = Objectives.Protect(
    'secondary',                      -- type
    'incomplete',                   -- complete
    'Protect Commander Jareth',    -- title
    'Jareth is a loyal and useful assest, insure his survival.',  -- description
        {                               -- target
            MarkUnits = true,
             Units = {ScenarioInfo.P1P1ACU}  
        }  
    )
    ScenarioInfo.M2P2:AddResultCallback(
        function(result, unit)
            if (not result and not ScenarioInfo.OpEnded) then
                ScenarioFramework.CDRDeathNISCamera(unit)
            end
        end
    )

    ScenarioInfo.M2Objectives = Objectives.CreateGroup('M2Objectives', IntroStartP3)
    ScenarioInfo.M2Objectives:AddObjective(ScenarioInfo.M1P2)
    ScenarioInfo.M2Objectives:AddObjective(ScenarioInfo.M2P2)

    if ExpansionTimer then
        local M2MapExpandDelay = {35*60, 30*60, 25*60}
        ScenarioFramework.CreateTimerTrigger(IntroP3, M2MapExpandDelay[Difficulty])
    end
end

function SecondaryMissionP2()

        WaitSeconds(60)
    
        for _, Player in ScenarioInfo.HumanPlayers do
            ScenarioFramework.RemoveRestriction(Player,
                categories.xsa0402 + -- Exp bomber
                categories.uaa0310  -- Exp Carrier          
            )
        end

        ScenarioInfo.M1P2S1 = Objectives.ArmyStatCompare(
        'secondary',                      -- type
        'incomplete',                   -- complete
        'Build A Experimental Bomber',                 -- title
        'We have given you the blueprints to a T4 bomber, use it.',  -- description
        'build',                        -- action
        {                               -- target
            Armies = {'HumanPlayers'},
            StatName = 'Units_Active',
            CompareOp = '>=',
            Value = 1,
            Category = categories.xsa0402,
        }
    )
end

function KOrderACUdeath()
    
    ScenarioFramework.CDRDeathNISCamera(ScenarioInfo.P2KO1ACU, 3)
    ScenarioFramework.Dialogue(OpStrings.ACUDeath1, nil, true)  
end

function OrderACUdeath()
    
    ScenarioFramework.CDRDeathNISCamera(ScenarioInfo.P2O1ACU, 3)
    ScenarioFramework.Dialogue(OpStrings.ACUDeath2, nil, true)  
end

function P2KillKOrderBase()
    for _, unit in ArmyBrains[KOrder]:GetListOfUnits(categories.ALLUNITS, false) do
        if unit and not unit.Dead then
            unit:Kill()
            WaitSeconds(Random(0.1, 0.3))
        end
    end
end

function P2KillOrderBase()
    for _, unit in ArmyBrains[Order]:GetListOfUnits(categories.ALLUNITS, false) do
        if unit and not unit.Dead then
            unit:Kill()
            WaitSeconds(Random(0.2, 0.3))
        end
    end
end

function CounterAttackP2()

    local quantity = {}
    local trigger = {}
    local platoon

    -- sends Gunships if player has more than [60, 50, 40] Units, up to 10, 1 group per 14, 11, 10
    num = ScenarioFramework.GetNumOfHumanUnits(categories.ALLUNITS - categories.WALL)
    quantity = {200, 150, 100}
    trigger = {40, 35, 30}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 6) then
            num = 6
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Order', 'P2O1AssaultGunship', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P2OIntAirattack' .. Random(1, 4))
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
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Order', 'P2O1AssaultIntercept', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P2OIntAirattack' .. Random(1, 4))
        end
    end

    for i = 1, 2 do
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Order', 'P2O1AssaultNaval' .. i .. '_D' .. Difficulty, 'GrowthFormation', 5)
        ScenarioFramework.PlatoonPatrolChain(platoon, 'P2OIntNavalattack' .. i)
    end

    if Difficulty > 1 then
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Order', 'P2O1AssaultBattleship', 'GrowthFormation', 5)
        ScenarioFramework.PlatoonPatrolChain(platoon, 'P2OIntNavalattack1')
    end 
end

--Part 3
function IntroStartP3()

    ForkThread(IntroP3)
end

function IntroP3()
    ScenarioFramework.FlushDialogueQueue()
    
    if ScenarioInfo.MissionNumber ~= 2 then
        return
    end
    ScenarioInfo.MissionNumber = 3
    
    ScenarioFramework.Dialogue(OpStrings.Intro1P3, nil, true)
    
    WaitSeconds(15)
    
    ScenarioFramework.SetPlayableArea('AREA_3', true)
    
    Cinematics.EnterNISMode()
        Cinematics.SetInvincible('AREA_2') 
            local basereveal2 = ScenarioFramework.CreateVisibleAreaLocation(60, ScenarioUtils.MarkerToPosition('Vision1P3'), 0, ArmyBrains[Player1])
            local basereveal3 = ScenarioFramework.CreateVisibleAreaLocation(80, ScenarioUtils.MarkerToPosition('Vision2P3'), 0, ArmyBrains[Player1])
    
            P3UEFAI.M3UEFECOBaseAI()
            ArmyBrains[UEF]:GiveResource('MASS', 25000)
            ArmyBrains[UEF]:GiveResource('ENERGY', 35000)
    
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'P3UAssault1_D' .. Difficulty, 'GrowthFormation')
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P3ULandchain1')
    
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'P3UAssault2_D' .. Difficulty, 'GrowthFormation')
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P3ULandchain2')
    
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'P3UAssaultNaval_D' .. Difficulty, 'GrowthFormation')
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P3Unavalchain1')
    
            ForkThread(TimerCounter)
    
            ScenarioInfo.M2Atlantis = ScenarioUtils.CreateArmyUnit('UEF', 'M2_Atlantis', 'NoFormation')
            ScenarioInfo.M2Atlantis2 = ScenarioUtils.CreateArmyUnit('UEF', 'M2_Atlantis2', 'NoFormation')
    
            ScenarioInfo.M2_Fatboy = ScenarioUtils.CreateArmyUnit('UEF', 'M2_Fatboy', 'NoFormation')
            ScenarioInfo.M2_Fatboy2 = ScenarioUtils.CreateArmyUnit('UEF', 'M2_Fatboy2', 'NoFormation')
    
            P3UEFAI.M3UEFAtlantisBaseAI()
            P3UEFAI.M3UEFFatboyBaseAI()
            P3UEFAI.M3UEFAtlantisBase2AI()
            P3UEFAI.M3UEFFatboyBase2AI()

            local AntinukesU = ArmyBrains[UEF]:GetListOfUnits(categories.ueb4302, false)
            for _, v in AntinukesU do
                v:GiveTacticalSiloAmmo(5)
            end
    
            Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P3Cam1'), 1)
            WaitSeconds(5)
            Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P3Cam2'), 5)
            WaitSeconds(4)
            Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P1Cam6'), 2)
    
            ScenarioFramework.Dialogue(OpStrings.Intro2P3, nil, true)
    
            units = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'P3Units2_D' .. Difficulty, 'GrowthFormation')
            for _, v in units:GetPlatoonUnits() do
                ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P3Uairchain1')))
            end
    
            units = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'P3Units3_D' .. Difficulty, 'GrowthFormation')
            for _, v in units:GetPlatoonUnits() do
                ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P3Uairchain2')))
            end
    
            ForkThread(
                function()
                    WaitSeconds(1)
                    basereveal2:Destroy()
                    basereveal3:Destroy()
                end
            )
        Cinematics.SetInvincible('AREA_2', true) 
    Cinematics.ExitNISMode()
    
    ForkThread(MissionP3)
    ScenarioFramework.CreateTimerTrigger(P3COffmapattacks2, 60)
    ForkThread(P3COffmapattacks1)
    ForkThread(CounterAttackP3)
    
    SetupUEFTM3TauntTriggers()
    
    ScenarioFramework.CreateArmyIntelTrigger(SecondaryMissionP3, ArmyBrains[Player1], 'LOSNow', false, true, categories.ueb4203, true, ArmyBrains[UEF])
end

function MissionP3()
    
    ScenarioInfo.M1P3 = Objectives.Kill(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Clear the Experimental Threats',                 -- title
        'A UEF Commander has moved several experimentals into the area, destroy them.',  -- description
        {                               -- target
            MarkUnits = true,
            ShowProgress = true,
            Units = {ScenarioInfo.M2Atlantis, ScenarioInfo.M2Atlantis2, ScenarioInfo.M2_Fatboy, ScenarioInfo.M2_Fatboy2}  
        
        }
    )

    ScenarioInfo.M3Objectives = Objectives.CreateGroup('M3Objectives', StartIntroP4)
    ScenarioInfo.M3Objectives:AddObjective(ScenarioInfo.M1P3)
    if ScenarioInfo.M1P2.Active then
        ScenarioInfo.M4Objectives:AddObjective(ScenarioInfo.M1P2)
    end
    if ScenarioInfo.M2P2.Active then
        ScenarioInfo.M4Objectives:AddObjective(ScenarioInfo.M2P2)
    end 
   
    if ExpansionTimer then
        local M3MapExpandDelay = {30*60, 25*60, 20*60}
        ScenarioFramework.CreateTimerTrigger(StartIntroP4, M3MapExpandDelay[Difficulty])
    end
end

function SecondaryMissionP3()
       
    ScenarioFramework.Dialogue(OpStrings.Secondary1P3, nil, true)
   
    ScenarioInfo.M3S1 = Objectives.CategoriesInArea(
        'secondary',                      -- type
        'incomplete',                   -- complete
        'Destroy the UEF Resource Island',                 -- title
        'The UEF Commander has a resource base on a small island.',  -- description
        'kill',                         -- action
        {                               -- target
            MarkUnits = true,
            ShowProgress = true,
            Requirements = {
                {   
                    Area = 'AREA_M7',
                    Category = categories.TECH3 * categories.STRUCTURE * categories.ECONOMIC,
                    CompareOp = '<=',
                    Value = 0,
                    ArmyIndex = UEF,
                },
            },
        }
    )
    ScenarioInfo.M3S1:AddResultCallback(
        function(result)
            if(result) then
                ScenarioFramework.Dialogue(OpStrings.SecondaryEnd1P3, nil, true)
            end
        end
    )
end

function P3COffmapattacks1()

    while ScenarioInfo.MissionNumber == 3 do
        local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'P3Uoffattack1_D'.. Difficulty, 'GrowthFormation')
        platoon:MoveToLocation(ScenarioUtils.MarkerToPosition('P3NavalMk1'), false)
        ScenarioFramework.PlatoonPatrolChain(platoon, 'P3UOffmapattack1')
        
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'P3Uoffattack3_D'.. Difficulty, 'GrowthFormation')
        ScenarioFramework.PlatoonPatrolChain(platoon, 'P3UB1airattack' .. Random(1, 3))

        WaitSeconds(Random(180, 240))
    end
end

function P3COffmapattacks2()

    while ScenarioInfo.MissionNumber == 3 do
        local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'P3Uoffattack2_D'.. Difficulty, 'GrowthFormation')
        platoon:MoveToLocation(ScenarioUtils.MarkerToPosition('P3NavalMk2'), false)
        ScenarioFramework.PlatoonPatrolChain(platoon, 'P3UOffmapattack2')
        
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'P3Uoffattack4_D'.. Difficulty, 'GrowthFormation')
        ScenarioFramework.PlatoonPatrolChain(platoon, 'P3ULandchain1')


        WaitSeconds(Random(160, 220))
    end
end

function TimerCounter()
        
    if ScenarioInfo.M2P2.Active then
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'P3UExtra', 'GrowthFormation')
        ScenarioFramework.PlatoonPatrolChain(platoon, 'P3ULandchain1')
    
        units = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'P3UExtra2', 'GrowthFormation')
        for _, v in units:GetPlatoonUnits() do
            ScenarioFramework.GroupAttackChain({v}, 'P3Uairchain4')
        end

    else
    
    end
end

function CounterAttackP3()

    local quantity = {}
    local trigger = {}
    local platoon

    -- sends Gunships if player has more than [60, 50, 40] Units, up to 10, 1 group per 40, 35, 30
    num = ScenarioFramework.GetNumOfHumanUnits(categories.ALLUNITS - categories.WALL)
    quantity = {200, 150, 100}
    trigger = {40, 35, 30}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 6) then
            num = 6
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('UEF', 'P3UAssaultGunship', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P3UAirassault' .. Random(1, 5))
        end
    end

    -- sends ASF if player has more than [30, 20, 10] Air, up to 3, 1 group per 20, 15, 10
    num = ScenarioFramework.GetNumOfHumanUnits(categories.AIR * categories.MOBILE)
    quantity = {30, 20, 10}
    trigger = {20, 15, 10}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 6) then
            num = 6
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('UEF', 'P3UAssaultIntercept', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P3UAirassault' .. Random(1, 5))
        end
    end

    -- sends Torpbombers if player has more than [30, 20, 10] Naval, up to 3, 1 group per 20, 15, 10
    num = ScenarioFramework.GetNumOfHumanUnits(categories.NAVAL * categories.MOBILE)
    quantity = {30, 20, 10}
    trigger = {20, 15, 10}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 5) then
            num = 5
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('UEF', 'P3UAssaultTorp', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P3UAirassault' .. Random(1, 5))
        end
    end

    -- sends Strats if player has more than [30, 20, 10] Defenses, up to 3, 1 group per 3, 2, 1
    num = ScenarioFramework.GetNumOfHumanUnits(categories.STRUCTURE * categories.DEFENSE - categories.TECH1)
    quantity = {50, 40, 30}
    trigger = {35, 25, 15}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 5) then
            num = 5
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('UEF', 'P3UAssaultBomber', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P3UAirassault' .. Random(1, 5))
        end
    end

    local battleships = ScenarioFramework.GetListOfHumanUnits( categories.BATTLESHIP)
    local num = table.getn(battleships)
    if num > 0 then
        quantity = {3, 2, 1}
        if num > quantity[Difficulty] then
            num = 4
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'P3UAssaultTorp', 'GrowthFormation')
            IssueAttack(platoon:GetPlatoonUnits(), battleships[i])
            IssueAggressiveMove(platoon:GetPlatoonUnits(), ScenarioUtils.MarkerToPosition('Player1'))
        end
    end

    local EXP = ScenarioFramework.GetListOfHumanUnits( categories.EXPERIMENTAL)
    local num = table.getn(EXP)
    if num > 0 then
        quantity = {3, 2, 1}
        if num > quantity[Difficulty] then
            num = 4
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'P3UAssaultGunship', 'GrowthFormation')
            IssueAttack(platoon:GetPlatoonUnits(), EXP[i])
            IssueAggressiveMove(platoon:GetPlatoonUnits(), ScenarioUtils.MarkerToPosition('Player1'))
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'P3UAssaultBomber', 'GrowthFormation')
            IssueAttack(platoon:GetPlatoonUnits(), battleships[i])
            IssueAggressiveMove(platoon:GetPlatoonUnits(), ScenarioUtils.MarkerToPosition('Player1'))
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'P3UAssaultTorp', 'GrowthFormation')
            IssueAttack(platoon:GetPlatoonUnits(), battleships[i])
            IssueAggressiveMove(platoon:GetPlatoonUnits(), ScenarioUtils.MarkerToPosition('Player1'))
        end
    end

    for i = 1, 5 do
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('UEF', 'P3UAssaultDrop', 'GrowthFormation', 5)
        CustomFunctions.PlatoonAttackWithTransports(platoon, 'P3UDropchain1', 'P3ULandchain3', 'P3UBECO', true)
    end
end

--Part 4

function StartIntroP4()

    ForkThread(IntroP4)
end

function IntroP4()
    ScenarioFramework.FlushDialogueQueue()
    
    if ScenarioInfo.MissionNumber ~= 3 then
        return
    end
    ScenarioInfo.MissionNumber = 4
    
    WaitSeconds(5)

    ScenarioFramework.SetPlayableArea('AREA_4', true)
    
    Cinematics.EnterNISMode()
        Cinematics.SetInvincible('AREA_3') 
    
        local basereveal1 = ScenarioFramework.CreateVisibleAreaLocation(80, ScenarioUtils.MarkerToPosition('Vision1P4'), 0, ArmyBrains[Player1])
        local basereveal2 = ScenarioFramework.CreateVisibleAreaLocation(80, ScenarioUtils.MarkerToPosition('Vision2P4'), 0, ArmyBrains[Player1])
        local basereveal3 = ScenarioFramework.CreateVisibleAreaLocation(80, ScenarioUtils.MarkerToPosition('Vision3P4'), 0, ArmyBrains[Player1])
        local basereveal4 = ScenarioFramework.CreateVisibleAreaLocation(80, ScenarioUtils.MarkerToPosition('Vision4P4'), 0, ArmyBrains[Player1])
    
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Kael', 'P4EXPp1', 'GrowthFormation')
        ScenarioFramework.PlatoonPatrolChain(platoon, 'P4KEXPpatrol1')
    
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Kael', 'P4EXPp2', 'GrowthFormation')
        ScenarioFramework.PlatoonPatrolChain(platoon, 'P4KEXPpatrol2')
    
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Kael', 'P4EXPp3', 'GrowthFormation')
        ScenarioFramework.PlatoonPatrolChain(platoon, 'P4KEXPpatrol3')
    
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Kael', 'P4EXPp4', 'GrowthFormation')
        ScenarioFramework.PlatoonPatrolChain(platoon, 'P4KEXPpatrol4')
    
        local units = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'P4UDefenseU_D' .. Difficulty, 'GrowthFormation')
        for _, v in units:GetPlatoonUnits() do
            ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P4UB1Airfdefense')))
        end
    
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'P4UDefensesea1_D' .. Difficulty, 'GrowthFormation')
        for _, v in platoon:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P4UDefensesea1Patrol')))
        end
    
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'P4UDefensesea2_D' .. Difficulty, 'GrowthFormation')
        for _, v in platoon:GetPlatoonUnits() do
            ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P4UDefensesea2Patrol')))
        end
        units = ScenarioUtils.CreateArmyGroupAsPlatoon('Kael', 'P4KAirdefense', 'GrowthFormation')
        for _, v in units:GetPlatoonUnits() do
            ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P4KB1Airdefense1')))
        end
    
        units = ScenarioUtils.CreateArmyGroupAsPlatoon('Kael', 'P4KUnits1_D'.. Difficulty, 'GrowthFormation')
        for _, v in units:GetPlatoonUnits() do
            ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P4KSeadefense1')))
        end
    
        units = ScenarioUtils.CreateArmyGroupAsPlatoon('Kael', 'P4KUnits2_D'.. Difficulty, 'GrowthFormation')
        for _, v in units:GetPlatoonUnits() do
            ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P4KSeadefense2')))
        end

        units = ScenarioUtils.CreateArmyGroupAsPlatoon('Kael', 'P4KAssaultNaval1_D'.. Difficulty, 'AttackFormation')
        ScenarioFramework.PlatoonPatrolChain(units, 'P4Kintattack1')
        units = ScenarioUtils.CreateArmyGroupAsPlatoon('Kael', 'P4KAssaultNaval2_D'.. Difficulty, 'AttackFormation')
        ScenarioFramework.PlatoonPatrolChain(units, 'P4Kintattack2')
        units = ScenarioUtils.CreateArmyGroupAsPlatoon('Kael', 'P4KAssaultNaval3_D'.. Difficulty, 'AttackFormation')
        ScenarioFramework.PlatoonPatrolChain(units, 'P4Kintattack3')

        ScenarioInfo.Palace = ScenarioUtils.CreateArmyUnit('Kael', 'Kaelpalace')
            ScenarioInfo.Palace:SetCustomName("Kael\'s Palace")
            ScenarioInfo.Palace:SetMaxHealth(10000)
            ScenarioInfo.Palace:SetHealth(ScenarioInfo.Palace, 10000)
            ScenarioInfo.Palace:SetReclaimable(false)
            ScenarioInfo.Palace:SetCapturable(false)

        ScenarioUtils.CreateArmyGroup('Kael', 'P4KOuterD_D'.. Difficulty)
        ScenarioUtils.CreateArmyGroup('Kael', 'P4KWalls')
        ScenarioUtils.CreateArmyGroup('Kael', 'P4KCivilain')
        ScenarioUtils.CreateArmyGroup('UEF', 'P4UBwalls')
        P4UEFAI.P4UEFbase1AI()
        P4UEFAI.P4UEFbase2AI()
        P4OrderAI.P4Kaelbase1AI()
        P4OrderAI.P4Kaelbase2AI()
        P4OrderAI.P4Kaelbase3AI()

        local AntinukesK = ArmyBrains[Kael]:GetListOfUnits(categories.uab4302, false)
        for _, v in AntinukesK do
            v:GiveTacticalSiloAmmo(5)
        end

        local AntinukesU = ArmyBrains[UEF]:GetListOfUnits(categories.ueb4302, false)
        for _, v in AntinukesU do
            v:GiveTacticalSiloAmmo(5)
        end
    
        ScenarioInfo.P4UACU = ScenarioFramework.SpawnCommander('UEF', 'UACU1', false, 'Brigadier General Valerie', false, UEFACUdeath,
            {'T3Engineering', 'Shield', 'ShieldGeneratorField', 'HeavyAntiMatterCannon'})
            ScenarioInfo.P4UACU:SetAutoOvercharge(true)
            ScenarioInfo.P4UACU:SetVeterancy(1 + Difficulty)

        ScenarioInfo.P4KACU = ScenarioFramework.SpawnCommander('Kael', 'P4KACU', false, 'Kael\'s High Executioner', false, KaelACUdeath,
            {'T3Engineering', 'Shield', 'ShieldHeavy', 'EnhancedSensors'})
            ScenarioInfo.P4KACU:SetAutoOvercharge(true)
            ScenarioInfo.P4KACU:SetVeterancy(1 + Difficulty)
    
        ScenarioFramework.Dialogue(OpStrings.Intro1P4, nil, true)
    
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P4Cam1'), 0)
        WaitSeconds(3)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P4Cam2'), 4)
        WaitSeconds(4)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P4Cam3'), 2)
        WaitSeconds(3)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P4Cam4'), 2)
        WaitSeconds(3)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P1Cam6'), 2)
    
        ForkThread(
            function()
                WaitSeconds(1)
                basereveal1:Destroy()
                basereveal2:Destroy()
                basereveal3:Destroy()
                basereveal4:Destroy()
                WaitSeconds(1)
                ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('Vision1P4'), 90)
                ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('Vision2P4'), 90)
                ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('Vision3P4'), 90)
                ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('Vision4P4'), 90)
            end
        )
        
        Cinematics.SetInvincible('AREA_3', true)
    Cinematics.ExitNISMode()
       
    ForkThread(function()
            -- Wait for satellite to be launched
            WaitSeconds(5)
            local orbital = ArmyBrains[UEF]:GetListOfUnits(categories.xea0002, false)
            if(orbital[1] and not orbital[1]:IsDead()) then
                local platoon = ArmyBrains[UEF]:MakePlatoon('', '')
                ArmyBrains[UEF]:AssignUnitsToPlatoon(platoon, {orbital[1]}, 'Attack', 'GrowthFormation')
                ScenarioFramework.PlatoonPatrolChain(platoon, 'P4UIntattack2')
            end
        end)   
    
    ForkThread(MissionP4)
    ForkThread(P4Specialattack)
    ForkThread(P4USpecialattack)
    ForkThread(CounterAttackP4)
    
    ScenarioFramework.CreateArmyIntelTrigger(MissionSecondaryP4, ArmyBrains[Player1], 'LOSNow', false, true, categories.xab1401, true, ArmyBrains[Kael])
end

function MissionP4()
    
    ScenarioInfo.M1P4 = Objectives.Kill(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Kill Kael',                -- title
        'Evaluator Kael is hiding in her personal palace, destroy it and end her rebellion.', -- description
        {                              -- target
            MarkUnits = true,
            Units = {ScenarioInfo.Palace}  
        }
    )
    ScenarioInfo.M1P4:AddResultCallback(
        function(result, unit)
            ScenarioFramework.CDRDeathNISCamera(unit)
        end
    )
    
    ScenarioInfo.S1P4 = Objectives.Kill(
        'secondary',                      -- type
        'incomplete',                   -- complete
        'Kill The UEF Commander',                -- title
        'To the north of your position is a UEF Commander, although not the target, kill her if given the chance.', -- description
        {                              -- target
            MarkUnits = true,
            Units = {ScenarioInfo.P4UACU}  
        }
    )
    ScenarioInfo.S1P4:AddResultCallback(
        function(result)
            ForkThread(P4KillUEFBase)
        end
    )

    ScenarioInfo.S2P4 = Objectives.Kill(
        'secondary',                      -- type
        'incomplete',                   -- complete
        'Kill Kael\'s Commander',                -- title
        'To the north of Kael is her personal Champion, although not the target, kill her if given the chance.', -- description
        {                              -- target
            MarkUnits = true,
            Units = {ScenarioInfo.P4KACU}  
        }
    )
    ScenarioInfo.S2P4:AddResultCallback(
        function(result)
            ForkThread(P4KillOrderBase)
        end
    )

    ScenarioInfo.M4Objectives = Objectives.CreateGroup('M4Objectives', PlayerWin)
    ScenarioInfo.M4Objectives:AddObjective(ScenarioInfo.M1P4)
    if ScenarioInfo.M1P3.Active then
        ScenarioInfo.M4Objectives:AddObjective(ScenarioInfo.M1P3)
    end
    if ScenarioInfo.M2P3.Active then
        ScenarioInfo.M4Objectives:AddObjective(ScenarioInfo.M2P3)
    end   
end

function MissionSecondaryP4()

    ScenarioInfo.S2P4 = Objectives.CategoriesInArea(
        'secondary',                      -- type
        'incomplete',                   -- complete
        'Destroy Kael\'s Paragon',                 -- title
        'Kael has a Paragon, destroy it to cripple her resources.',  -- description
        'kill',                         -- action
        {                               -- target
            MarkUnits = true,
            ShowProgress = true,
            Requirements = {
                {   
                    Area = 'AREA_M8',
                    Category = categories.xab1401,
                    CompareOp = '<=',
                    Value = 0,
                    ArmyIndex = Kael,
                },
            },
            Category = categories.xab1401,
        }
   )
end

function P4KillOrderBase()
    if Difficulty < 3 then
        local CUnits = ScenarioFramework.GetCatUnitsInArea((categories.ALLUNITS), 'AREA_MS2', ArmyBrains[Kael])
            for k, v in CUnits do
                if v and not v.Dead then
                v:Kill()
                WaitSeconds(Random(0.001, 0.003))
                end
            end
    end
end

function P4KillUEFBase()
    if Difficulty < 3 then
        for _, unit in ArmyBrains[UEF]:GetListOfUnits(categories.ALLUNITS, false) do
            if unit and not unit.Dead then
                unit:Kill()
                WaitSeconds(Random(0.1, 0.3))
            end
        end
    end
end

function UEFACUdeath()
        
    ScenarioFramework.CDRDeathNISCamera(ScenarioInfo.P4UACU, 3)
    ScenarioFramework.Dialogue(OpStrings.ACUDeath3, nil, true)  
end

function KaelACUdeath()
        
    ScenarioFramework.CDRDeathNISCamera(ScenarioInfo.P4KACU, 3)
    ScenarioFramework.Dialogue(OpStrings.ACUDeath4, nil, true)
end

function P4Specialattack()
    
    ScenarioInfo.Specialfunction = Random(1, 2)
    
    if  ScenarioInfo.Specialfunction == 1 then
    
        ScenarioUtils.CreateArmyGroup('Kael', 'P4KSpeical1_D'.. Difficulty)
    
        else
        if  ScenarioInfo.Specialfunction == 2 then
        
            ScenarioUtils.CreateArmyGroup('Kael', 'P4KSpeical2_D'.. Difficulty)
            ForkThread(Nukeparty2)
        end
    end
end

function P4USpecialattack()
    
    ScenarioInfo.USpecialfunction = Random(1, 2)
    
    if  ScenarioInfo.USpecialfunction == 1 then
    
        P4UEFAI.M4UEFSBase1AI()
    
        else
        if  ScenarioInfo.USpecialfunction == 2 then
        
            P4UEFAI.M4UEFSBase2AI()
        end
    end
end

--Kael Nuke AI during Phase 3, platoon.lua is used in this case
function Nukeparty2()
    --Get a table of all UEF SMLs
    local AeonNuke2 = ArmyBrains[Kael]:GetListOfUnits(categories.uab2305, false)
        
        --Only do something if there is at least 1 SML in the table
        if table.getn(AeonNuke2) > 0 then
            for k, v in AeonNuke2 do
                --Loop through each SML, and only enable the NukeAI for an instance if it hasn't been enabled yet
                if not v.SiloAIEnabled and not v:IsDead() then
                    --Make a single unit platoon for each SML
                    local SiloPlatoon = ArmyBrains[Kael]:MakePlatoon('','')
                    ArmyBrains[Kael]:AssignUnitsToPlatoon(SiloPlatoon, {v}, 'Attack', 'None')
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

function CounterAttackP4()

    local quantity = {}
    local trigger = {}
    local platoon

    -- sends Gunships if player has more than [60, 50, 40] Units, up to 10, 1 group per 40, 35, 30
    num = ScenarioFramework.GetNumOfHumanUnits(categories.ALLUNITS - categories.WALL)
    quantity = {200, 150, 100}
    trigger = {40, 35, 30}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 6) then
            num = 6
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Kael', 'P4KAssaultGunships', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P4Kintattack' .. Random(1, 5))
        end
    end

    -- sends ASF if player has more than [30, 20, 10] Air, up to 3, 1 group per 20, 15, 10
    num = ScenarioFramework.GetNumOfHumanUnits(categories.AIR * categories.MOBILE)
    quantity = {30, 20, 10}
    trigger = {20, 15, 10}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 6) then
            num = 6
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Kael', 'P4KAssaultIntercept', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P4Kintattack' .. Random(1, 5))
        end
    end

    -- sends Torpbombers if player has more than [30, 20, 10] Naval, up to 3, 1 group per 20, 15, 10
    num = ScenarioFramework.GetNumOfHumanUnits(categories.NAVAL * categories.MOBILE)
    quantity = {30, 20, 10}
    trigger = {20, 15, 10}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 6) then
            num = 6
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Kael', 'P4KAssaultTorps', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P4Kintattack' .. Random(1, 5))
        end
    end

    -- sends Strats if player has more than [30, 20, 10] Defenses, up to 3, 1 group per 3, 2, 1
    num = ScenarioFramework.GetNumOfHumanUnits(categories.STRUCTURE * categories.DEFENSE - categories.TECH1)
    quantity = {50, 40, 30}
    trigger = {35, 25, 15}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 6) then
            num = 6
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('UEF', 'P3UAssaultBomber', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P4UIntattack' .. Random(1, 4))
        end
    end

    -- sends ASF if player has more than [30, 20, 10] Air, up to 3, 1 group per 20, 15, 10
    num = ScenarioFramework.GetNumOfHumanUnits(categories.AIR * categories.MOBILE)
    quantity = {30, 20, 10}
    trigger = {20, 15, 10}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 6) then
            num = 6
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('UEF', 'P4UAssaultIntercept', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P4UIntattack' .. Random(1, 4))
        end
    end

    ScenarioInfo.CzarPlanes = ScenarioUtils.CreateArmyGroupAsPlatoon('Kael', 'P4KAirdefense', 'StaggeredChevronFormation')
    ScenarioInfo.Czar = ScenarioUtils.CreateArmyUnit('Kael', 'P4KCzar')
    
    IssueTransportLoad(ScenarioInfo.CzarPlanes:GetPlatoonUnits(), ScenarioInfo.Czar)

    
    ScenarioFramework.GroupPatrolChain({ScenarioInfo.Czar}, 'P4Kintattack2')

    
    ScenarioFramework.CreateUnitNearTypeTrigger(CzarAI, ScenarioInfo.Czar, ArmyBrains[Player1], categories.ALLUNITS, 70)


    units = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'P4UAssaultLand1_D'.. Difficulty, 'AttackFormation')
        ScenarioFramework.PlatoonPatrolChain(units, 'P4UIntattack3')

    units = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'P4UAssaultLand2_D'.. Difficulty, 'AttackFormation')
        ScenarioFramework.PlatoonPatrolChain(units, 'P4UIntattack2')

    units = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'P4Uintialattack1_D'.. Difficulty, 'AttackFormation')
        ScenarioFramework.PlatoonPatrolChain(units, 'P4UIntattack1')
end

function CzarAI()
    --Release aircraft
    IssueClearCommands({ScenarioInfo.Czar})
    IssueTransportUnload({ScenarioInfo.Czar}, ScenarioInfo.Czar:GetPosition())
    
    for _, unit in ScenarioInfo.CzarPlanes:GetPlatoonUnits() do
        while not unit.Dead and unit:IsUnitState('Attached') do
            WaitSeconds(.5)
        end
    end
    
    --Dive, and patrol player base area
    if not ScenarioInfo.Czar.Dead then
        IssuePatrol({ScenarioInfo.Czar}, ScenarioUtils.MarkerToPosition('Player1'))
        IssuePatrol({ScenarioInfo.Czar}, ScenarioUtils.MarkerToPosition('Player2'))
    end
    --Aircraft patrols the player base area
    if ArmyBrains[Kael]:PlatoonExists(ScenarioInfo.CzarPlanes) then
        IssueClearCommands(ScenarioInfo.CzarPlanes:GetPlatoonUnits())
        ScenarioInfo.CzarPlanes:Stop()
        ScenarioInfo.CzarPlanes:Patrol(ScenarioUtils.MarkerToPosition('Player1'))
        ScenarioInfo.CzarPlanes:Patrol(ScenarioUtils.MarkerToPosition('Player2'))
        ScenarioInfo.CzarPlanes:Patrol(ScenarioUtils.MarkerToPosition('Player3'))
    end
end

--Misc Functions

function DestroyUnit(unit)
    unit:Destroy()
end

--End Functions

function PlayerWin()
    
    ScenarioInfo.M1P2S2:ManualResult(true)
    
    ScenarioFramework.Dialogue(OpStrings.EndP4, nil, true)
    
    if(not ScenarioInfo.OpEnded) then
        ScenarioInfo.OpComplete = true
        KillGame()
    end
end

function KillGame()
    UnlockInput()
    ScenarioFramework.EndOperation(ScenarioInfo.OpComplete, ScenarioInfo.OpComplete, true)
end

function PlayerDeath(deadCommander)
    if Debug then return end
     ScenarioFramework.PlayerDeath(deadCommander, nil, AssignedObjectives)
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

-- taunts

function SetupORDERTM1TauntTriggers()

    ORDERTM:AddEnemiesKilledTaunt('TAUNT1P1', ArmyBrains[KOrder], categories.STRUCTURE, 10)
    ORDERTM:AddUnitsKilledTaunt('TAUNT2P1', ArmyBrains[KOrder], categories.AIR * categories.MOBILE, 50)
    ORDERTM:AddUnitsKilledTaunt('TAUNT3P1', ArmyBrains[KOrder], categories.STRUCTURE * categories.FACTORY, 2)
end

function SetupORDERTM2TauntTriggers()

    ORDERTM:AddEnemiesKilledTaunt('TAUNT1P2', ArmyBrains[KOrder], categories.ALLUNITS, 30)
    ORDERTM:AddUnitsKilledTaunt('TAUNT2P2', ArmyBrains[KOrder], categories.AIR * categories.MOBILE, 50)
    ORDERTM:AddUnitsKilledTaunt('TAUNT3P2', ArmyBrains[KOrder], categories.STRUCTURE * categories.FACTORY, 4)
end

function SetupUEFTM3TauntTriggers()

    UEFTM:AddEnemiesKilledTaunt('TAUNT1P3', ArmyBrains[UEF], categories.ALLUNITS, 30)
    UEFTM:AddUnitsKilledTaunt('TAUNT2P3', ArmyBrains[UEF], categories.AIR * categories.MOBILE, 40)
    UEFTM:AddUnitsKilledTaunt('TAUNT3P3', ArmyBrains[UEF], categories.STRUCTURE , 10)
end
