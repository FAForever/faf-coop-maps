------------------------------
-- Coalition Campaign - Mission 2
--
-- Author: Shadowlorda1
------------------------------
local Objectives = import('/lua/ScenarioFramework.lua').Objectives
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local Utilities = import('/lua/Utilities.lua')
local Cinematics = import('/lua/cinematics.lua')
local Buff = import('/lua/sim/Buff.lua')
local P2OrderAI = import('/maps/FAF_Coop_Operation_Holy Raid/OrderaiP2.lua')
local P3OrderAI = import('/maps/FAF_Coop_Operation_Holy Raid/OrderaiP3.lua')
local P4OrderAI = import('/maps/FAF_Coop_Operation_Holy Raid/OrderaiP4.lua')
local OpStrings = import('/maps/FAF_Coop_Operation_Holy Raid/FAF_Coop_Operation_Holy Raid_strings.lua')  
local TauntManager = import('/lua/TauntManager.lua')

local OrderTM = TauntManager.CreateTauntManager('Order1TM', '/maps/FAF_Coop_Operation_Holy Raid/FAF_Coop_Operation_Holy Raid_strings.lua')

ScenarioInfo.Player1 = 1
ScenarioInfo.Civilians = 4
ScenarioInfo.Order1 = 2
ScenarioInfo.Order2 = 3
ScenarioInfo.Player2 = 5
ScenarioInfo.Player3 = 6
ScenarioInfo.Player4 = 7

local Difficulty = ScenarioInfo.Options.Difficulty

local Player1 = ScenarioInfo.Player1
local Civilians = ScenarioInfo.Civilians
local Order1 = ScenarioInfo.Order1
local Order2 = ScenarioInfo.Order2
local Player2 = ScenarioInfo.Player2
local Player3 = ScenarioInfo.Player3
local Player4 = ScenarioInfo.Player4

local AssignedObjectives = {}
local ExpansionTimer = ScenarioInfo.Options.Expansion

local SkipNIS2 = false

local UEFDead = false

local Debug = false

local NIS1InitialDelay = 3

local Nukedelay = {9*60, 7*60, 5*60}

function OnPopulate(self) 
    ScenarioUtils.InitializeScenarioArmies()
    LeaderFaction, LocalFaction = ScenarioFramework.GetLeaderAndLocalFactions()

    -- Army Colors
    if(LeaderFaction == 'cybran') then
        ScenarioFramework.SetCybranPlayerColor(Player1)
    elseif(LeaderFaction == 'uef') then
        ScenarioFramework.SetUEFPlayerColor(Player1)
    elseif(LeaderFaction == 'aeon') then
        ScenarioFramework.SetAeonPlayerColor(Player1)
    end
    
    ScenarioFramework.SetArmyColor('Civilians', 144, 20, 39)
    ScenarioFramework.SetArmyColor('Order1', 95, 1, 167)
    ScenarioFramework.SetArmyColor('Order2', 159, 216, 2)
    SetArmyUnitCap(Order1, 3000)
    SetArmyUnitCap(Order2, 3000)
    ScenarioFramework.SetSharedUnitCap(4000)
    
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
    
    ScenarioInfo.Labs = ScenarioUtils.CreateArmyGroup('Civilians', 'Labs')
    ScenarioUtils.CreateArmyGroup('Civilians', 'P1Civilianbase1' )
    ScenarioUtils.CreateArmyGroup('Civilians', 'P1Wreaks', true )
    ScenarioUtils.CreateArmyGroup('Player1', 'P1Civilianbase1D' ) 
    ScenarioUtils.CreateArmyGroup('Player1', 'Starting Units' )
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Player1', 'P1PPatrol', 'GrowthFormation')
        ScenarioFramework.PlatoonPatrolChain(platoon, 'P1Ppatrol1')       
end

function OnStart(self) 
    ScenarioFramework.SetPlayableArea('AREA_1', false)   
    
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P1Cam1'), 0)
    ForkThread(Intro1)
end 

-- Part 1

function Intro1()

    Cinematics.EnterNISMode()
    
    ScenarioInfo.PlayersACUs = {}

    if (LeaderFaction == 'aeon') then
        ScenarioInfo.PlayerCDR = ScenarioFramework.SpawnCommander('Player1', 'AeonPlayer', 'Warp', true, true, PlayerDeath)
        table.insert(ScenarioInfo.PlayersACUs, ScenarioInfo.PlayerCDR)
    elseif (LeaderFaction == 'cybran') then
        ScenarioInfo.PlayerCDR = ScenarioFramework.SpawnCommander('Player1', 'CybranPlayer', 'Warp', true, true, PlayerDeath)
        table.insert(ScenarioInfo.PlayersACUs, ScenarioInfo.PlayerCDR)
    elseif (LeaderFaction == 'uef') then
        ScenarioInfo.PlayerCDR = ScenarioFramework.SpawnCommander('Player1', 'UEFPlayer', 'Warp', true, true, PlayerDeath)
        table.insert(ScenarioInfo.PlayersACUs, ScenarioInfo.PlayerCDR)
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
                table.insert(ScenarioInfo.PlayersACUs, ScenarioInfo.CoopCDR[coop])
            elseif (factionIdx == 2) then
                ScenarioInfo.CoopCDR[coop] = ScenarioFramework.SpawnCommander(strArmy, 'AeonPlayer', 'Warp', true, true, PlayerDeath)
                table.insert(ScenarioInfo.PlayersACUs, ScenarioInfo.CoopCDR[coop])
            else
                ScenarioInfo.CoopCDR[coop] = ScenarioFramework.SpawnCommander(strArmy, 'CybranPlayer', 'Warp', true, true, PlayerDeath)
                table.insert(ScenarioInfo.PlayersACUs, ScenarioInfo.CoopCDR[coop])
            end
            coop = coop + 1
            WaitSeconds(0.5)
        end
    end
    
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P1Cam1'), 0)
    ScenarioFramework.Dialogue(OpStrings.IntroP1, nil, true)
    WaitSeconds(3)
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P1Cam2'), 3)
    WaitSeconds(2)
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P1Cam1'), 3)
    WaitSeconds(2)
    ScenarioFramework.Dialogue(OpStrings.Reveal1P1, nil, true)
    
    Cinematics.ExitNISMode()

    ForkThread(P1ProtectObjective)

    WaitSeconds(35)
    ForkThread(P1Intattacks)
end

function P1ProtectObjective()

    ScenarioInfo.M2P1 = Objectives.Protect(
        'primary',                      -- type
        'incomplete',                   -- complete
        'The Labs Must Survive',                -- title
        'We can not let the Order take the labs', -- description
       
        {                              -- target
            Units = ScenarioInfo.Labs,
            MarkUnits = true,
            ShowProgress = true, 
        }
    )
    ScenarioInfo.M2P1:AddResultCallback(
        function(result)
            if (not result and not ScenarioInfo.OpEnded) then
                PlayerLose()  
            end
        end
    )
end

function P1Intattacks()

    local quantity = {}
    local trigger = {}
    local platoon

    ScenarioInfo.M1CounterAttackUnits = {}

    local function AddUnitsToObjTable(platoon)
        for _, v in platoon:GetPlatoonUnits() do
            if not EntityCategoryContains(categories.TRANSPORTATION + categories.SCOUT + categories.SHIELD, v) then
                table.insert(ScenarioInfo.M1CounterAttackUnits, v)
            end
        end
    end
     -- Air attack

    -- Basic air attack
    for i = 1, 4 do
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Order1', 'P1Intattack4_D' .. Difficulty, 'AttackFormation', 1 + Difficulty)
        ScenarioFramework.PlatoonPatrolChain(platoon, 'P1IntAirattack' .. i)
        AddUnitsToObjTable(platoon)

    end

    -- Sends [1, 2, 3] Mercies at players' ACUs
    for _, v in ScenarioInfo.PlayersACUs do
        if not v:IsDead() then
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Order1', 'P1IntattackAirSnipe_D' .. Difficulty, 'NoFormation', 5)
            IssueAttack(platoon:GetPlatoonUnits(), v)
            IssueAggressiveMove(platoon:GetPlatoonUnits(), ScenarioUtils.MarkerToPosition('Player1'))
            AddUnitsToObjTable(platoon)
        end
    end

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Order1', 'P1Intattack1_D' .. Difficulty, 'GrowthFormation')
        ScenarioFramework.PlatoonAttackWithTransports(platoon, 'P1Intdrop1', 'P1IntDropattack1', true)
        AddUnitsToObjTable(platoon)

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Order1', 'P1Intattack2_D' .. Difficulty, 'GrowthFormation')
        ScenarioFramework.PlatoonAttackWithTransports(platoon, 'P1Intdrop2', 'P1Intdropattack2', true)
        AddUnitsToObjTable(platoon)

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Order1', 'P1Intattack3_D' .. Difficulty, 'GrowthFormation')
        ScenarioFramework.PlatoonAttackWithTransports(platoon, 'P1Intdrop3', 'P1Intdropattack3', true)
        AddUnitsToObjTable(platoon)

    StartMission1()    
end

function StartMission1()
    
    ScenarioInfo.MissionNumber = 0
    
    ScenarioInfo.M1P1 = Objectives.Kill(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Survive Order Assault',                 -- title
        'Kill all Order forces attacking you.',  -- description
        {                               -- target
            ShowProgress = true,
            Units = ScenarioInfo.M1CounterAttackUnits
            
        }
    )
    
    ScenarioInfo.M1P1:AddResultCallback(
        function(result)
            if result then
                if ScenarioInfo.MissionNumber == 0 then
                    ForkThread(IntroP2)
                end
            end
        end
    )

    WaitSeconds(3*60)
    ForkThread(AttackCheck)  
end

function AttackCheck()
    
    if ScenarioInfo.M1P1.Active then
    
    ScenarioInfo.M1P1:ManualResult(true)   
    else

    end
end

-- Part 2

function IntroP2()
    
    ScenarioInfo.MissionNumber = 1
    
    WaitSeconds(3)
    
    ScenarioFramework.SetPlayableArea('AREA_2', true)
    
    P2OrderAI.Order1base1AI()
    P2OrderAI.Order1base2AI()
    P2OrderAI.Order2base1AI()

    ArmyBrains[Order1]:PBMSetCheckInterval(6)
    ArmyBrains[Order2]:PBMSetCheckInterval(6)
    
    ScenarioUtils.CreateArmyGroup('Order1', 'ObjectiveBase1') 
    ScenarioUtils.CreateArmyGroup('Order1', 'ObjectiveBase2')
    ScenarioUtils.CreateArmyGroup('Order1', 'P2DefenceS')
    ScenarioUtils.CreateArmyGroup('Order2', 'P1OuterDefences')  
    
    ScenarioInfo.M2CivilianBuildings = ScenarioUtils.CreateArmyGroup('Order1', 'ObjectiveP2')

    Cinematics.EnterNISMode()
        Cinematics.SetInvincible('AREA_1')

        local VisMarker1_1 = ScenarioFramework.CreateVisibleAreaLocation(40, 'P2vision1', 0, ArmyBrains[Player1])
        local VisMarker1_2 = ScenarioFramework.CreateVisibleAreaLocation(40, 'P2vision2', 0, ArmyBrains[Player1])
        local VisMarker1_3 = ScenarioFramework.CreateVisibleAreaLocation(60, 'P2vision3', 0, ArmyBrains[Player1])
        local VisMarker1_4 = ScenarioFramework.CreateVisibleAreaLocation(60, 'P2vision4', 0, ArmyBrains[Player1])
    
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P2Cam1'), 2)
        ScenarioFramework.Dialogue(OpStrings.IntroP2, nil, true)
        WaitSeconds(2)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P2Cam2'), 3)
        WaitSeconds(3)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P2Cam3'), 4)
        WaitSeconds(3)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P2Cam4'), 3)
        WaitSeconds(4)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P1Cam1'), 1)
    
        ForkThread(
            function()
                WaitSeconds(1)
                VisMarker1_1:Destroy()
                VisMarker1_2:Destroy()
                VisMarker1_3:Destroy()
                VisMarker1_4:Destroy()
                WaitSeconds(1)
                ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('P2vision1'), 50)
                ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('P2vision2'), 50)
                ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('P2vision3'), 70)
                ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('P2vision4'), 70)
            end
        )
        Cinematics.SetInvincible('AREA_1', true)
    Cinematics.ExitNISMode()
    
    ForkThread(MissionP2)
    ForkThread(IntroSecObj)
    
    ScenarioFramework.CreateAreaTrigger(P2UEFdeath, 'O1_B1_Obj', categories.FACTORY + categories.ENGINEER + categories.CONSTRUCTION, true, true, ArmyBrains[Order1])

    ScenarioFramework.CreateAreaTrigger(P2UEFdeath, 'O1_B2_Obj', categories.FACTORY + categories.ENGINEER + categories.CONSTRUCTION, true, true, ArmyBrains[Order1])

    ScenarioFramework.CreateTimerTrigger(P2UEFdeath, 20*60)

    SetupOrderM1TauntTriggers()
    
    buffDef = Buffs['CheatIncome']
    buffAffects = buffDef.Affects
    buffAffects.EnergyProduction.Mult = 1.5
    buffAffects.MassProduction.Mult = 2.0

       for _, u in GetArmyBrain(Order1):GetPlatoonUniquelyNamed('ArmyPool'):GetPlatoonUnits() do
               Buff.ApplyBuff(u, 'CheatIncome')
       end     
       
    buffDef = Buffs['CheatIncome']
    buffAffects = buffDef.Affects
    buffAffects.EnergyProduction.Mult = 1.5
    buffAffects.MassProduction.Mult = 2.0

       for _, u in GetArmyBrain(Order2):GetPlatoonUniquelyNamed('ArmyPool'):GetPlatoonUnits() do
               Buff.ApplyBuff(u, 'CheatIncome')
       end        
end

function MissionP2()
    
    ScenarioInfo.M1P2 = Objectives.Kill(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Destroy the Captured Labs',                -- title
        'We can\'t allow the Order acess to the data within the Labs, destroy them.', -- description
        {                              -- target
            Units = ScenarioInfo.M2CivilianBuildings,
            MarkUnits = true,
            ShowProgress = true, 
        }
    )
    ScenarioInfo.M1P2:AddResultCallback(
        function(result)
            if (result) then
                ScenarioFramework.Dialogue(OpStrings.M1ObjectivecompleteP2, nil, true)
            end
        end
    )

    ScenarioInfo.M2P2 = Objectives.CategoriesInArea(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Destroy Order Bases',                 -- title
        'Commander we can\'t risk any of this data getting off world, wipe out all enemy forces.',  -- description
        'kill',                         -- action
        {                               -- target
            MarkUnits = true,
            ShowProgress = true,
            Requirements = {
                {   
                    Area = 'O1_B1_Obj',
                    Category = categories.FACTORY + categories.ECONOMIC * categories.TECH2,
                    CompareOp = '<=',
                    Value = 0,
                    ArmyIndex = Order1,
                },
                {   
                    Area = 'O1_B2_Obj',
                    Category = categories.FACTORY + categories.ECONOMIC * categories.TECH2,
                    CompareOp = '<=',
                    Value = 0,
                    ArmyIndex = Order1,
                },
                {   
                    Area = 'O2_B1_Obj',
                    Category = categories.FACTORY + categories.TECH2 * categories.ECONOMIC + categories.TECH3 * categories.ECONOMIC,
                    CompareOp = '<=',
                    Value = 0,
                    ArmyIndex = Order2,
                },
            },
        }
    )
    
    ScenarioInfo.M2P2:AddResultCallback(
        function(result)
            if result then
                ScenarioFramework.Dialogue(OpStrings.M2ObjectivecompleteP2, nil, true)
            end
        end
    )
    ScenarioInfo.M2Objectives = Objectives.CreateGroup('M2Objectives', IntroP3)
    ScenarioInfo.M2Objectives:AddObjective(ScenarioInfo.M1P2)
    ScenarioInfo.M2Objectives:AddObjective(ScenarioInfo.M2P2)
    if ExpansionTimer then
        local M2MapExpandDelay = {40*60, 35*60, 30*60}
        ScenarioFramework.CreateTimerTrigger(IntroP3, M2MapExpandDelay[Difficulty])  
    end   
end

function IntroSecObj()

    WaitSeconds(2*60)

    ScenarioFramework.Dialogue(OpStrings.SecondaryIntroP2, nil, true)

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Civilians', 'P1Testgroup', 'GrowthFormation')
        ScenarioFramework.PlatoonAttackWithTransports(platoon, 'P1Intdrop2', 'P1IntDropattack2', true)

    WaitSeconds(10)
    ScenarioFramework.Dialogue(OpStrings.SecondaryMidP2, SecondaryMissionP2, true)
end

function SecondaryMissionP2()

    ScenarioInfo.M1P2S1 = Objectives.CategoriesInArea(
        'secondary',                      -- type
        'incomplete',                   -- complete
        'Clear Out AA positions',                 -- title
        ' Commander Fredrick can\'t send you reinforcements with those positions in play, destroy them.',  -- description
        'kill',                         -- action
        {                               -- target
            MarkUnits = true,
            ShowProgress = true,
            Requirements = {
                {   
                    Area = 'P1SecObj1',
                    Category = categories.uab2204 + categories.uab2104 + categories.uab3201,
                    CompareOp = '<=',
                    Value = 0,
                    ArmyIndex = Order1,
                },
                {   
                    Area = 'P1SecObj2',
                    Category = categories.uab2204 + categories.uab2104 + categories.uab3201,
                    CompareOp = '<=',
                    Value = 0,
                    ArmyIndex = Order1,
                },
            },
        }
    )
    
    ScenarioInfo.M1P2S1:AddResultCallback(
        function(result)
            if result then
                ScenarioFramework.Dialogue(OpStrings.SecondaryObj1Complete, P2PlayerReinforcements, true)
            end
        end
    )
end

function P2PlayerReinforcements()
    if ScenarioInfo.MissionNumber == 1 then
        ForkThread(
            function()
    
                local destination = ScenarioUtils.MarkerToPosition('DropZoneP1')

                local transports = ScenarioUtils.CreateArmyGroup('Civilians', 'P1ReinforcementsT_D'..Difficulty)
                local units = ScenarioUtils.CreateArmyGroupAsPlatoon('Civilians', 'P1Reinforcements_D'.. Difficulty, 'AttackFormation')
                WaitSeconds(5)
                import('/lua/ai/aiutilities.lua').UseTransports(units:GetPlatoonUnits(), transports, destination)
                for _, transport in transports do
                    ScenarioFramework.CreateUnitToMarkerDistanceTrigger(DestroyUnit, transport,  ScenarioUtils.MarkerToPosition('TransportDelete'), 15)

                    IssueTransportUnload({transport}, destination)
                    IssueMove({transport}, ScenarioUtils.MarkerToPosition('TransportDelete'))
                end
            
                for k, v in units:GetPlatoonUnits() do
                while (v:IsUnitState('Attached')) do
                    WaitSeconds(1)
                end
                if (v and not v:IsDead()) then
                    ScenarioFramework.GiveUnitToArmy(v, 'Player1')
                end
        
            end
        end)
    end
end

function P2UEFdeath()

    if (not UEFDead) then
        UEFDead = true

        ScenarioFramework.Dialogue(OpStrings.UEFDeath1P2, nil, true)
        WaitSeconds(20)
        ScenarioFramework.Dialogue(OpStrings.UEFDeath2P2, nil, true)
        WaitSeconds(20)
        ScenarioFramework.Dialogue(OpStrings.UEFDeath3P2, nil, true)
        WaitSeconds(10)
        ScenarioFramework.Dialogue(OpStrings.UEFDeath4P2, nil, true)

        if ScenarioInfo.M1P2S1.Active then
            ScenarioInfo.M1P2S1:ManualResult(false)   
        end
    end
end

-- Part 3

function IntroP3()

    if ScenarioInfo.MissionNumber == 2 or ScenarioInfo.MissionNumber == 3 then
        return
    end
    ScenarioInfo.MissionNumber = 2

    WaitSeconds(5)
    ScenarioFramework.SetPlayableArea('AREA_3', true)
     
    P3OrderAI.Order1base1P3AI()
    P3OrderAI.Order1base2P3AI()
    P3OrderAI.Order1base3P3AI()
    P3OrderAI.Order1base4P3AI()
    P3OrderAI.Order2base1P3AI()

    local Antinukes = ArmyBrains[Order1]:GetListOfUnits(categories.uab4302, false)
    for _, v in Antinukes do
        v:GiveTacticalSiloAmmo(3)
    end
     
    ScenarioUtils.CreateArmyGroup('Order1', 'P2A1OuterD_D'.. Difficulty)
     
    ScenarioInfo.P3O1ACU = ScenarioFramework.SpawnCommander('Order1', 'O1ACU', false, 'Executor Havra', false, OrderACUdeath,
    {'AdvancedEngineering','T3Engineering', 'Shield', 'ShieldHeavy', 'HeatSink'})
    ScenarioInfo.P3O1ACU:SetAutoOvercharge(true)
    ScenarioInfo.P3O1ACU:SetVeterancy(1 + Difficulty)
    
    ScenarioUtils.CreateArmyGroup('Civilians', 'P2Civilianbase1', true)
    ScenarioUtils.CreateArmyGroup('Civilians', 'P2Civilianbase2')
    ScenarioUtils.CreateArmyGroup('Civilians', 'P2Cunits')
    ScenarioInfo.Blackbox = ScenarioUtils.CreateArmyUnit('Order1', 'Blackbox')
    ScenarioInfo.Blackbox:SetCustomName("UEF blackbox")
    ScenarioInfo.Blackbox:SetReclaimable(true)
    ScenarioInfo.Blackbox:SetCapturable(false)
    ScenarioInfo.Blackbox:SetCanTakeDamage(false)
    ScenarioInfo.Blackbox:SetCanBeKilled(false)
    ScenarioInfo.Blackbox:SetDoNotTarget(true)
    
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Order2', 'O2P2Unit1', 'AttackFormation')
    ScenarioFramework.PlatoonMoveChain(platoon, 'O2P3B1Landattack1')
    
    local units = ScenarioUtils.CreateArmyGroupAsPlatoon('Order1', 'P3G1cut', 'GrowthFormation')
    for _, v in units:GetPlatoonUnits() do
       ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P3IntattackCAM')))
    end

    local units = ScenarioUtils.CreateArmyGroupAsPlatoon('Order1', 'P3O1LandDefence1_D' .. Difficulty, 'GrowthFormation')
    for _, v in units:GetPlatoonUnits() do
       ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('O1P3B1landDefence1')))
    end

    local units = ScenarioUtils.CreateArmyGroupAsPlatoon('Order1', 'P3O1LandDefence2_D' .. Difficulty, 'GrowthFormation')
    for _, v in units:GetPlatoonUnits() do
       ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('O1P3B2landDefence1')))
    end
    
    local units = ScenarioUtils.CreateArmyGroupAsPlatoon('Order2', 'O2P2Unit2', 'GrowthFormation')
    for _, v in units:GetPlatoonUnits() do
       ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('O2P3B1Airdefence1')))
    end
    
    local units = ScenarioUtils.CreateArmyGroupAsPlatoon('Order2', 'O2P2Unit3', 'GrowthFormation')
    for _, v in units:GetPlatoonUnits() do
       ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('O2P3B1Landdefence1')))
    end
    
    Cinematics.EnterNISMode()
        Cinematics.SetInvincible('AREA_2')
    
    local VisMarker2_1 = ScenarioFramework.CreateVisibleAreaLocation(40, 'P3vision1', 0, ArmyBrains[Player1])
    local VisMarker2_2 = ScenarioFramework.CreateVisibleAreaLocation(40, 'P3vision2', 0, ArmyBrains[Player1])
    local VisMarker2_3 = ScenarioFramework.CreateVisibleAreaLocation(70, 'P3vision3', 0, ArmyBrains[Player1])
    
    ScenarioFramework.Dialogue(OpStrings.IntroP3, nil, true)
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P3Cam1'), 2)
    WaitSeconds(2)
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P3Cam2'), 4)
    WaitSeconds(2)
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P3Cam3'), 3)
    WaitSeconds(3)
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P3Cam4'), 3)
    WaitSeconds(3)
    local AeonNuke = ArmyBrains[Order1]:GetListOfUnits(categories.uab2305, false)
    IssueNuke({AeonNuke[1]}, ScenarioUtils.MarkerToPosition('Nuke1'))
    ForkThread(
            function()
                WaitSeconds(1)
                VisMarker2_1:Destroy()
                VisMarker2_2:Destroy()
                VisMarker2_3:Destroy()
                WaitSeconds(1)
                ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('P3vision1'), 50)
                ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('P3vision2'), 50)
                ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('P3vision3'), 80)
                end
                )
        Cinematics.SetInvincible('AREA_2', true)
    Cinematics.ExitNISMode()
    
    ScenarioInfo.M2P1:ManualResult(true)
    
    ForkThread(MissionP3)
    ForkThread(P3Intattacks)
    
    SetupOrderM2TauntTriggers()
    
    buffDef = Buffs['CheatIncome']
    buffAffects = buffDef.Affects
    buffAffects.EnergyProduction.Mult = 1.5
    buffAffects.MassProduction.Mult = 2.0

       for _, u in GetArmyBrain(Order1):GetPlatoonUniquelyNamed('ArmyPool'):GetPlatoonUnits() do
               Buff.ApplyBuff(u, 'CheatIncome')
       end     
       
    buffDef = Buffs['CheatIncome']
    buffAffects = buffDef.Affects
    buffAffects.EnergyProduction.Mult = 1.5
    buffAffects.MassProduction.Mult = 2.0

       for _, u in GetArmyBrain(Order2):GetPlatoonUniquelyNamed('ArmyPool'):GetPlatoonUnits() do
               Buff.ApplyBuff(u, 'CheatIncome')
       end     
    
    ForkThread(Nukeparty)   
end

function P3Intattacks()

    local quantity = {}
    local trigger = {}
    local platoon

    -- Basic air attack
    -- sends ASF if player has more than [60, 50, 40] planes, up to 10, 1 group per 14, 11, 10
    num = ScenarioFramework.GetNumOfHumanUnits(categories.AIR * categories.MOBILE)
    quantity = {60, 50, 40}
    trigger = {14, 12, 10}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 8) then
            num = 8
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Order1', 'P3O1IntAirIntercept_D' .. Difficulty, 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P3IntAirattack' .. Random(1, 5))
        end
    end

    -- sends Gunships if player has more than [60, 50, 40] Units, up to 10, 1 group per 14, 11, 10
    num = ScenarioFramework.GetNumOfHumanUnits(categories.ALLUNITS - categories.WALL)
    quantity = {200, 150, 100}
    trigger = {40, 35, 30}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 8) then
            num = 8
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Order1', 'P3O1IntAirattack_D' .. Difficulty, 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P3IntAirattack' .. Random(1, 5))
        end
    end

    -- sends Strats if player has more than [50, 40, 30] Tech 2 and 3 defenses, up to 6, 1 group per 25, 20, 15
    num = ScenarioFramework.GetNumOfHumanUnits(categories.STRUCTURE * categories.DEFENSE - categories.TECH1)
    quantity = {50, 40, 30}
    trigger = {25, 20, 15}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 6) then
            num = 6
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Order1', 'P3O1IntAirBomber', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P3IntAirattack' .. Random(1, 5))
        end
    end

    -- sends Exp bomber if player has more than [3, 2, 1] EXP, up to 3, 1 group per 3, 2, 1
    num = ScenarioFramework.GetNumOfHumanUnits(categories.EXPERIMENTAL)
    quantity = {3, 2, 1}
    trigger = {3, 2, 1}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 2) then
            num = 2
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Order1', 'P3O1IntAirEXP', 'GrowthFormation')
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P3IntAirattack' .. i)
        end
    end

    -- sends transports if player has more than [250, 200, 150] Units, up to 3, 1 group per 100, 75, 50
    num = ScenarioFramework.GetNumOfHumanUnits(categories.ALLUNITS - categories.WALL)
    quantity = {250, 200, 150}
    trigger = {100, 75, 50}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 3) then
            num = 3
        end
        for i = 1, num do
             platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Order1', 'P3O1IntDrops', 'GrowthFormation')
            ScenarioFramework.PlatoonAttackWithTransports(platoon, 'P2IntDrop1', 'P2IntDropAttack1', true)
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Order1', 'P3O1IntDrops', 'GrowthFormation')
            ScenarioFramework.PlatoonAttackWithTransports(platoon, 'P2IntDrop2', 'P2IntDropAttack2', true)
        end
    end
end

function MissionP3()
    
    ScenarioInfo.M1P3 = Objectives.Kill(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Eliminate Commander Havra',                -- title
        'Commander Havra is one of two Order commanders on planet, kill her for murdering the UEF science team.', -- description
        {                              -- target
            MarkUnits = true,
            ShowProgress = true,
            Units = {ScenarioInfo.P3O1ACU}, 
        }
    )
    ScenarioInfo.M1P3:AddResultCallback(
        function(result)
            if result then
                ScenarioFramework.Dialogue(OpStrings.M1ObjectivecompleteP3, nil, true)
            end
        end
    )

    ScenarioInfo.M2P3 = Objectives.CategoriesInArea(
        'secondary',                      -- type
        'incomplete',                   -- complete
        'Destroy Order Base',                 -- title
        'The second Order commander has a base in the area supporting Havra, destroy it.',  -- description
        'kill',                         -- action
        {                               -- target
            MarkUnits = true,
            ShowProgress = true,
            Requirements = {
                {   
                    Area = 'O2_B1_Obj2',
                    Category = categories.FACTORY + categories.ECONOMIC * categories.TECH2 + categories.ECONOMIC * categories.TECH3,
                    CompareOp = '<=',
                    Value = 0,
                    ArmyIndex = Order2,
                },
               
            },
        }
    )
    ScenarioInfo.M2P3:AddResultCallback(
        function(result)
            if result then
                ScenarioFramework.Dialogue(OpStrings.SecondaryObjP3Complete2, nil, true)  
            end
        end
    )
    
    ForkThread(
    function()
    WaitSeconds(60)
     ScenarioFramework.Dialogue(OpStrings.SecondaryObj1P3, nil, true)
    
    ScenarioInfo.M1P3S1 = Objectives.Reclaim(
        'secondary',                      -- type
        'incomplete',                   -- complete
        'Recover the UEF blackbox',                -- title
        'The UEF commander was killed defending the station, recover his remains for his family.', -- description
        {                              -- target
            MarkUnits = true,
            ShowProgress = true,
            Units = {ScenarioInfo.Blackbox}, 
        }
    )
    ScenarioInfo.M1P3S1:AddResultCallback(
        function(result)
            if result then
               ScenarioFramework.Dialogue(OpStrings.SecondaryObjP3Complete1, nil, true)  
            end
        end
    )
    end)

    ScenarioInfo.M3Objectives = Objectives.CreateGroup('M3Objectives', startIntroP4)
    ScenarioInfo.M3Objectives:AddObjective(ScenarioInfo.M1P3)
    if ScenarioInfo.M1P2.Active then
        ScenarioInfo.M3Objectives:AddObjective(ScenarioInfo.M1P2)
    end
    if ScenarioInfo.M2P2.Active then
        ScenarioInfo.M3Objectives:AddObjective(ScenarioInfo.M2P2)
    end

    if ExpansionTimer then
        local M3MapExpandDelay = {35*60, 30*60, 25*60}
        ScenarioFramework.CreateTimerTrigger(IntroP4, M3MapExpandDelay[Difficulty])  
    end
end

function Nukeparty()

    local AeonNuke = ArmyBrains[Order1]:GetListOfUnits(categories.uab2305, false)
    WaitSeconds(3)
    WaitSeconds(Nukedelay[Difficulty])
    IssueNuke({AeonNuke[1]}, ScenarioUtils.MarkerToPosition('Nuke2'))
    WaitSeconds(Nukedelay[Difficulty])
    IssueNuke({AeonNuke[1]}, ScenarioUtils.MarkerToPosition('Nuke3'))
    WaitSeconds(Nukedelay[Difficulty])
    IssueNuke({AeonNuke[1]}, ScenarioUtils.MarkerToPosition('Nuke4'))
    local plat = ArmyBrains[Order1]:MakePlatoon('', '')
        ArmyBrains[Order1]:AssignUnitsToPlatoon(plat, {AeonNuke[1]}, 'Attack', 'NoFormation')
        plat:ForkAIThread(plat.NukeAI)
end

function OrderACUdeath()
    
    ScenarioFramework.CDRDeathNISCamera(ScenarioInfo.P3O1ACU, 4)
    ScenarioFramework.Dialogue(OpStrings.Death1, nil, true)
    ForkThread(P3KillOrderBase)
end

function P3KillOrderBase()
    local OrderUnits = ScenarioFramework.GetCatUnitsInArea((categories.ALLUNITS), 'AREA_3', ArmyBrains[Order1])
        for k, v in OrderUnits do
            if v and not v.Dead then
                v:Kill()
                WaitSeconds(Random(0.1, 0.3))
            end
        end
end

-- Part 4

function startIntroP4()

    ForkThread(IntroP4)
end

function IntroP4()

    if ScenarioInfo.MissionNumber == 3 then
        return
    end
    ScenarioInfo.MissionNumber = 3

    WaitSeconds(10)
    ScenarioFramework.SetPlayableArea('AREA_4', true)
     
    P4OrderAI.Order2base1P4AI()
    P4OrderAI.Order2base2P4AI()
    P4OrderAI.Order2base3P4AI()
    P4OrderAI.Order2base4P4AI()

    local Antinukes = ArmyBrains[Order2]:GetListOfUnits(categories.uab4302, false)
    for _, v in Antinukes do
        v:GiveTacticalSiloAmmo(3)
    end
     
    ArmyBrains[Order2]:GiveResource('MASS', 400000)
    ArmyBrains[Order2]:GiveResource('ENERGY', 600000)
     
    ScenarioUtils.CreateArmyGroup('Order2', 'P4A2Walls')
    ScenarioUtils.CreateArmyGroup('Civilians', 'P3Wreaks', true)
     
    ScenarioInfo.P4O2ACU = ScenarioFramework.SpawnCommander('Order2', 'O2ACU', false, 'Crusader Zertha', false, false,
    {'AdvancedEngineering', 'T3Engineering', 'Shield', 'ShieldHeavy', 'EnhancedSensors'})
    ScenarioInfo.P4O2ACU:SetCanBeKilled(false)
    ScenarioInfo.P4O2ACU:SetAutoOvercharge(true)
    ScenarioInfo.P4O2ACU:SetVeterancy(2 + Difficulty)
    ScenarioFramework.CreateUnitDamagedTrigger(Order2ACUWarp, ScenarioInfo.P4O2ACU, .8)

    ScenarioInfo.P4O2ACUS1 = ScenarioFramework.SpawnCommander('Order2', 'O2ACUS1', false, 'Jalen', false, false,
    {'Shield', 'ShieldHeavy', 'EngineeringFocusingModule', 'StabilitySuppressant'})
    ScenarioInfo.P4O2ACUS1:SetVeterancy(2 + Difficulty)

    ScenarioInfo.P4O2ACUS2 = ScenarioFramework.SpawnCommander('Order2', 'O2ACUS2', false, 'Gyira', false, false,
    {'Shield', 'ShieldHeavy', 'EngineeringFocusingModule', 'StabilitySuppressant'})
    ScenarioInfo.P4O2ACUS2:SetVeterancy(2 + Difficulty)

    local units = ScenarioUtils.CreateArmyGroupAsPlatoon('Order2', 'P4Patrols1_D' .. Difficulty, 'GrowthFormation')
    for _, v in units:GetPlatoonUnits() do
       ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('O2P4Patrol1')))
    end

    local units = ScenarioUtils.CreateArmyGroupAsPlatoon('Order2', 'P4Patrols2_D' .. Difficulty, 'GrowthFormation')
    for _, v in units:GetPlatoonUnits() do
       ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('O2P4Patrol2')))
    end

    local units = ScenarioUtils.CreateArmyGroupAsPlatoon('Order2', 'P4Patrols3_D' .. Difficulty, 'GrowthFormation')
    for _, v in units:GetPlatoonUnits() do
       ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('O2P4Patrol3')))
    end
    
    Cinematics.EnterNISMode()
    
    local VisMarker3_1 = ScenarioFramework.CreateVisibleAreaLocation(60, 'P4Vision1', 0, ArmyBrains[Player1])
    local VisMarker3_2 = ScenarioFramework.CreateVisibleAreaLocation(60, 'P4Vision2', 0, ArmyBrains[Player1])

    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P4Cam1'), 2)
    ScenarioFramework.Dialogue(OpStrings.IntroP4, nil, true)
    WaitSeconds(2)
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P4Cam2'), 4)
    WaitSeconds(2)
    Cinematics.CameraTrackEntity(ScenarioInfo.P4O2ACU, 40, 2)
    WaitSeconds(2)
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P1Cam1'), 0)
    
    ForkThread(
            function()
                WaitSeconds(1)
                VisMarker3_1:Destroy()
                VisMarker3_2:Destroy()

                WaitSeconds(1)
                ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('P4Vision1'), 70)
                ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('P4Vision2'), 70)

                end
                )
    
    Cinematics.ExitNISMode()
    
    ForkThread(MissionP4)
    ForkThread(P4Intattacks)
    ForkThread(Nukeparty2)
    
    SetupOrderM3TauntTriggers()
       
    buffDef = Buffs['CheatIncome']
    buffAffects = buffDef.Affects
    buffAffects.EnergyProduction.Mult = 2
    buffAffects.MassProduction.Mult = 2

       for _, u in GetArmyBrain(Order2):GetPlatoonUniquelyNamed('ArmyPool'):GetPlatoonUnits() do
               Buff.ApplyBuff(u, 'CheatIncome')
       end
    ScenarioFramework.CreateArmyIntelTrigger(ParagonspotedP4, ArmyBrains[Player1], 'LOSNow', false, true,  categories.xab1401, true, ArmyBrains[Order2] )        
end

function MissionP4()
    
    ScenarioInfo.M1P4 = Objectives.Kill(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Eliminate Commander Zertha',                -- title
        'Both Commander Zertha and her support commanders are attempting to transfer highly valuable research off world, stop them.', -- description
        {                              -- target
            MarkUnits = true,
            ShowProgress = true,
            Units = {ScenarioInfo.P4O2ACU}, 
        }
    )
    ScenarioInfo.M1P4:AddResultCallback(
        function(result)
            if result then
                ScenarioFramework.Dialogue(OpStrings.ACUleftP4, nil, true)  
            end
        end
    ) 

    ScenarioInfo.M2P4 = Objectives.Kill(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Eliminate Support Commanders',                -- title
        'Both Commander Zertha and her support commanders are attempting to transfer highly valuable research off world, stop them.', -- description
        {                              -- target
            MarkUnits = true,
            ShowProgress = true,
            Units = {ScenarioInfo.P4O2ACUS1, ScenarioInfo.P4O2ACUS2}, 
        }
    )
    ScenarioInfo.M2P4:AddResultCallback(
        function(result)
            if result then
                ScenarioFramework.Dialogue(OpStrings.SACUdeadP4, nil, true)
            end
        end
    ) 
    ScenarioInfo.M4Objectives = Objectives.CreateGroup('M3Objectives', PlayerWin)
    ScenarioInfo.M4Objectives:AddObjective(ScenarioInfo.M2P4)
    ScenarioInfo.M4Objectives:AddObjective(ScenarioInfo.M1P4)
    if ScenarioInfo.M1P3.Active then
        ScenarioInfo.M4Objectives:AddObjective(ScenarioInfo.M1P2)
    end
    if ScenarioInfo.M1P2.Active then
        ScenarioInfo.M4Objectives:AddObjective(ScenarioInfo.M1P2)
    end
    if ScenarioInfo.M2P2.Active then
        ScenarioInfo.M4Objectives:AddObjective(ScenarioInfo.M2P2)
    end
end

function P4Intattacks()

    local quantity = {}
    local trigger = {}
    local platoon

    -- Basic air attack
    -- sends ASF if player has more than [60, 50, 40] planes, up to 10, 1 group per 14, 11, 10
    num = ScenarioFramework.GetNumOfHumanUnits(categories.AIR * categories.MOBILE)
    quantity = {60, 50, 40}
    trigger = {10, 8, 6}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 12) then
            num = 12
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Order2', 'P4IntIntercept', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P4Intattack' .. Random(1, 5))
        end
    end

    -- sends Gunships if player has more than [60, 50, 40] Units, up to 10, 1 group per 14, 11, 10
    num = ScenarioFramework.GetNumOfHumanUnits(categories.ALLUNITS - categories.WALL)
    quantity = {200, 150, 100}
    trigger = {35, 30, 25}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 10) then
            num = 10
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Order2', 'P4IntGunship', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P4Intattack' .. Random(1, 5))
        end
    end

    -- sends Strats if player has more than [70, 60, 50] Land Units, up to 6, 1 group per 14, 12, 10
    num = ScenarioFramework.GetNumOfHumanUnits(categories.LAND * categories.MOBILE)
    quantity = {70, 60, 50}
    trigger = {14, 12, 10}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 6) then
            num = 6
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Order2', 'P4IntBomber', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P4Intattack' .. Random(1, 5))
        end
    end

    -- sends Exp bomber if player has more than [3, 2, 1] EXP, up to 3, 1 group per 3, 2, 1
    num = ScenarioFramework.GetNumOfHumanUnits(categories.EXPERIMENTAL)
    quantity = {3, 2, 1}
    trigger = {3, 2, 1}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 3) then
            num = 4
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Order2', 'P4IntattackEXP', 'GrowthFormation')
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P4Intattack'.. i)
        end
    end

    local extractors = ScenarioFramework.GetListOfHumanUnits(categories.MASSEXTRACTION)
    local num = table.getn(extractors)
    if num > 0 then
            quantity = {5, 6, 7}
            if num > quantity[Difficulty] then
                num = quantity[Difficulty]
            end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Order2', 'P4IntsnipeBomber', 'GrowthFormation')
            IssueAttack(platoon:GetPlatoonUnits(), extractors[i])
            IssueAggressiveMove(platoon:GetPlatoonUnits(), ScenarioUtils.MarkerToPosition('Player1'))
        end
    end

    local factories = ScenarioFramework.GetListOfHumanUnits(categories.EXPERIMENTAL * categories.LAND)
    local num = table.getn(factories)

    if num > 0 then
            quantity = {4, 3, 2}
            if num > quantity[Difficulty] then
                num = num
            end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Order2', 'P4IntsnipeGunship', 'GrowthFormation')
            IssueAttack(platoon:GetPlatoonUnits(), factories[i])
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
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Order2', 'P4IntsnipeGunship', 'GrowthFormation')
            IssueAttack(platoon:GetPlatoonUnits(), AirExp[i])
            IssueAggressiveMove(platoon:GetPlatoonUnits(), ScenarioUtils.MarkerToPosition('Player1'))
        end
    end

    units = ScenarioUtils.CreateArmyGroupAsPlatoon('Order2', 'P4IntattackLand1_D'.. Difficulty, 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(units, 'P4Intattack1')

    units = ScenarioUtils.CreateArmyGroupAsPlatoon('Order2', 'P4IntattackLand2_D'.. Difficulty, 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(units, 'P4Intattack2')

    units = ScenarioUtils.CreateArmyGroupAsPlatoon('Order2', 'P4IntattackLand3_D'.. Difficulty, 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(units, 'P4Intattack3')

    for i = 1, 4 do
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Order2', 'P4IntDropunits', 'GrowthFormation')
        ScenarioFramework.PlatoonAttackWithTransports(platoon, 'P4IntDrop' .. Random(1, 3), 'P4IntDropattack', true)
     end
end

function ParagonspotedP4()

    ScenarioFramework.Dialogue(OpStrings.SecondarystartP4, nil, true)

    ScenarioInfo.M1P4S1 = Objectives.CategoriesInArea(
    'secondary',                      -- type
    'incomplete',                   -- complete
    'Destroy Paragon',                 -- title
    'The Order commander has a paragon and its attmepting to construct a Rapid fire Artillary structure, destroy them.',  -- description
    'kill',                         -- action
    {                               -- target
            MarkUnits = true,
            ShowProgress = true,
            Requirements = {
                {   
                    Area = 'P4SecObj1',
                    Category = categories.xab2307 + categories.xab1401,
                    CompareOp = '<=',
                    Value = 0,
                    ArmyIndex = Order2,
                },
               
            },
        }
    )
    ScenarioInfo.M1P4S1:AddResultCallback(
        function(result)
            if result then
                ScenarioFramework.Dialogue(OpStrings.SecondaryendP4, nil, true)
            end
        end
    )
end

function Order2ACUWarp()

    ForkThread(
        function()
            ScenarioFramework.FakeTeleportUnit(ScenarioInfo.P4O2ACU, true)
        end
    )  
    ScenarioInfo.M1P4:ManualResult(true)
end

function Nukeparty2()

    local AeonNuke2 = ArmyBrains[Order2]:GetListOfUnits(categories.uab2305, false)
    AeonNuke2[1]:GiveNukeSiloAmmo(5)
    WaitSeconds(3)
    WaitSeconds(Nukedelay[Difficulty])
    IssueNuke({AeonNuke2[1]}, ScenarioUtils.MarkerToPosition('Nuke2'))
     WaitSeconds(10)
    IssueNuke({AeonNuke2[1]}, ScenarioUtils.MarkerToPosition('Nuke2'))
    local plat = ArmyBrains[Order2]:MakePlatoon('', '')
        ArmyBrains[Order2]:AssignUnitsToPlatoon(plat, {AeonNuke2[1]}, 'Attack', 'NoFormation')
        plat:ForkAIThread(plat.NukeAI)
end

-- Misc Functions

function PlayerWin()
    if not ScenarioInfo.OpEnded then
        ScenarioInfo.OpComplete = true
        ScenarioFramework.Dialogue(OpStrings.PlayerWin, KillGame, true)
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
        ForkThread(
            function()
                WaitSeconds(3)
                KillGame()
            end
        )
    end
end

function SetupOrderM1TauntTriggers()

    if ScenarioInfo.MissionNumber == 1 then
        OrderTM:AddEnemiesKilledTaunt('TAUNT1P1', ArmyBrains[Order1], categories.STRUCTURE, 10)
        OrderTM:AddUnitsKilledTaunt('TAUNT2P1', ArmyBrains[Order1], categories.STRUCTURE * categories.ECONOMIC, 10)
        OrderTM:AddUnitsKilledTaunt('TAUNT3P1', ArmyBrains[Order1], categories.STRUCTURE * categories.FACTORY, 4)
        return
    end
end

function SetupOrderM2TauntTriggers()
    
    if ScenarioInfo.MissionNumber == 2 then
        OrderTM:AddTauntingCharacter(ScenarioInfo.P3O1ACU)
    
        OrderTM:AddEnemiesKilledTaunt('TAUNT1P2', ArmyBrains[Order1], categories.STRUCTURE, 10)
        OrderTM:AddUnitsKilledTaunt('TAUNT2P2', ArmyBrains[Order1], categories.MOBILE * categories.LAND, 50)
        OrderTM:AddUnitsKilledTaunt('TAUNT3P2', ArmyBrains[Order1], categories.STRUCTURE * categories.FACTORY, 3)
    
        OrderTM:AddDamageTaunt('TAUNT4P2', ScenarioInfo.P3O1ACU, .5)
        return
    end
end

function SetupOrderM3TauntTriggers()
    
    if ScenarioInfo.MissionNumber == 3 then
        OrderTM:AddTauntingCharacter(ScenarioInfo.P4O2ACU)
    
        OrderTM:AddEnemiesKilledTaunt('TAUNT5P2', ArmyBrains[Order2], categories.STRUCTURE, 10)
        OrderTM:AddUnitsKilledTaunt('TAUNT6P2', ArmyBrains[Order2], categories.MOBILE + categories.LAND, 30)
        OrderTM:AddUnitsKilledTaunt('TAUNT7P2', ArmyBrains[Order2], categories.STRUCTURE * categories.FACTORY, 5)
        return  
    end
end
 
function RemoveCommandCapFromPlatoon(platoon)

    for _, unit in platoon:GetPlatoonUnits() do
        unit:RemoveCommandCap('RULEUCC_Reclaim')
        unit:RemoveCommandCap('RULEUCC_Repair')
        unit:RemoveCommandCap('RULEUCC_Guard')
    end 

 end
 
function DestroyUnit(unit)

    unit:Destroy()
end