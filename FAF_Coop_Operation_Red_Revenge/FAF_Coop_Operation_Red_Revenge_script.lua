------------------------------
-- Coalition Campaign - Mission 5
--
-- Author: Shadowlorda1
------------------------------
local OpStrings = import('/maps/FAF_Coop_Operation_Red_Revenge/FAF_Coop_Operation_Red_Revenge_strings.lua')
local Buff = import('/lua/sim/Buff.lua')
local Cinematics = import('/lua/cinematics.lua')
local Objectives = import('/lua/ScenarioFramework.lua').Objectives
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local Utilities = import('/lua/Utilities.lua')  
local AIBuildStructures = import('/lua/ai/aibuildstructures.lua')
local CustomFunctions = import('/maps/FAF_Coop_Operation_Red_Revenge/FAF_Coop_Operation_Red_Revenge_CustomFunctions.lua') 
local P1SeraphimAI = import('/maps/FAF_Coop_Operation_Red_Revenge/SeraphimaiP1.lua')
local P2SeraphimAI = import('/maps/FAF_Coop_Operation_Red_Revenge/SeraphimaiP2.lua')
local P3SeraphimAI = import('/maps/FAF_Coop_Operation_Red_Revenge/SeraphimaiP3.lua')
local P1UEFAI = import('/maps/FAF_Coop_Operation_Red_Revenge/UEFaiP1.lua')
local TauntManager = import('/lua/TauntManager.lua')

local SeraTM = TauntManager.CreateTauntManager('Sera1TM', '/maps/FAF_Coop_Operation_Red_Revenge/FAF_Coop_Operation_Red_Revenge_strings.lua')

ScenarioInfo.Player1 = 1
ScenarioInfo.Order = 2
ScenarioInfo.Seraphim = 3
ScenarioInfo.QAI = 4
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
local Seraphim = ScenarioInfo.Seraphim
local Order = ScenarioInfo.Order
local QAI = ScenarioInfo.QAI
local UEF = ScenarioInfo.UEF
local AssignedObjectives = {}

local SkipNIS2 = false
local SkipNIS3 = false
local P1EndReinforcements = false
local UEFSPAWN = false

local Debug = false

local AssignedObjectives = {}

local NIS1InitialDelay = 3
 
function OnPopulate(scenario)
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

    ScenarioFramework.SetSeraphimColor(Seraphim)
    ScenarioFramework.SetCybranEvilColor(QAI)
    ScenarioFramework.SetAeonEvilColor(Order)
    ScenarioFramework.SetUEFAllyColor(UEF)
    
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

    SetArmyUnitCap(Seraphim, 3000)
    SetArmyUnitCap(Order, 3000)
    ScenarioFramework.SetSharedUnitCap(4800)
end

function OnStart(scenario)
    
    ScenarioFramework.SetPlayableArea('AREA_1', false)   

    ScenarioUtils.CreateArmyGroup('Seraphim', 'P1LabsDF1')

    ScenarioInfo.M1ObjectiveLab1 = ScenarioUtils.CreateArmyUnit('Seraphim', 'P1Lab1')
    ScenarioInfo.M1ObjectiveLab1:SetCustomName("Seraphim Lab")
    ScenarioInfo.M1ObjectiveLab1:SetMaxHealth(5000)             
    ScenarioInfo.M1ObjectiveLab1:SetHealth(ScenarioInfo.M1ObjectiveLab1, 5000)
    ScenarioInfo.M1ObjectiveLab1:SetReclaimable(false)
    ScenarioInfo.M1ObjectiveLab1:SetCapturable(true)
    ScenarioInfo.M1ObjectiveLab1:SetCanTakeDamage(false)
    ScenarioInfo.M1ObjectiveLab1:SetCanBeKilled(false)
    ScenarioInfo.M1ObjectiveLab1:SetDoNotTarget(true)

    ScenarioUtils.CreateArmyGroup('Seraphim', 'Walls')
    ScenarioUtils.CreateArmyGroup('Seraphim', 'P1SDefenses_D'.. Difficulty)
    ScenarioUtils.CreateArmyGroup('Order', 'P1OWalls')
    ScenarioUtils.CreateArmyGroup('Order', 'P1ODefenses_D'.. Difficulty)
    
    P1SeraphimAI.Seraphimbase1AI()
    P1SeraphimAI.Orderbase1AI()
    P1SeraphimAI.Orderbase2AI()
    
    ArmyBrains[Seraphim]:PBMSetCheckInterval(6)
    ArmyBrains[Order]:PBMSetCheckInterval(6)
    ArmyBrains[QAI]:PBMSetCheckInterval(6)

    buffDef = Buffs['CheatIncome']
    buffAffects = buffDef.Affects
    buffAffects.EnergyProduction.Mult = 1.5
    buffAffects.MassProduction.Mult = 1.5

    for _, u in GetArmyBrain(Seraphim):GetPlatoonUniquelyNamed('ArmyPool'):GetPlatoonUnits() do
        Buff.ApplyBuff(u, 'CheatIncome')
    end

    for _, u in GetArmyBrain(Order):GetPlatoonUniquelyNamed('ArmyPool'):GetPlatoonUnits() do
        Buff.ApplyBuff(u, 'CheatIncome')
    end

    ScenarioFramework.AddRestrictionForAllHumans(
        categories.TECH3 + -- All Tech 3 
        categories.EXPERIMENTAL  -- All Experimentals
    )
    
    ForkThread(IntroP1)
end

---Part 1

function IntroP1()
    
    ScenarioInfo.MissionNumber = 1

    for i = 1, 2 do
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'P1SUnits1', 'AttackFormation')
        ScenarioFramework.PlatoonPatrolChain(platoon, 'P1SPatrol'.. i)
    end

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'P1SUnits4', 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'P1SPatrol1')

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'P1SUnits2', 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'P1SPatrol2')


    Cinematics.EnterNISMode()

    	local VisMarker1_1 = ScenarioFramework.CreateVisibleAreaLocation(50, 'P1Vision1', 0, ArmyBrains[Player1])
        local VisMarker1_2 = ScenarioFramework.CreateVisibleAreaLocation(50, 'P1Vision2', 0, ArmyBrains[Player1])
        local VisMarker1_3 = ScenarioFramework.CreateVisibleAreaLocation(120, 'P1Vision3', 0, ArmyBrains[Player1])
        local VisMarker1_4 = ScenarioFramework.CreateVisibleAreaLocation(120, 'P1Vision4', 0, ArmyBrains[Player1])
    
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P1Cam1'), 0)
        WaitSeconds(1)
        ScenarioFramework.Dialogue(OpStrings.IntroP1, nil, true)
        WaitSeconds(4)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P1Cam2'), 4)
        WaitSeconds(5)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P1Cam3'), 4)
        WaitSeconds(3)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P1Cam4'), 2)
        ForkThread(Player1Units)
        WaitSeconds(2)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P1Cam5'), 3)
        ScenarioFramework.Dialogue(OpStrings.Thalia1P1, nil, true)
    
        ForkThread(
            function()
                WaitSeconds(1)
                VisMarker1_1:Destroy()
                VisMarker1_2:Destroy()
                VisMarker1_3:Destroy()
                VisMarker1_4:Destroy()
                WaitSeconds(1)
                ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('P1Vision1'), 60)
                ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('P1Vision2'), 60)

            end
        )
        -- Gets player number and joins it to a string to make it refrence a camera marker e.g 'Cam_M1_Intro_Player1'
        local army = GetFocusArmy()
        if army == -1 then
        army = 1
        end
        local tblArmy = ListArmies()
        ScenarioInfo.PlayerCamString = tostring(tblArmy[army])

        Cinematics.CameraMoveToMarker('P1C' .. ScenarioInfo.PlayerCamString)
    
    Cinematics.ExitNISMode()

    ScenarioInfo.PlayersACUs = {}

    if (LeaderFaction == 'aeon') then
        ScenarioInfo.PlayerCDR = ScenarioFramework.SpawnCommander('Player1', 'AeonPlayer', 'Warp', true, true, PlayerDeath,
        {'HeatSink', 'CrysalisBeam'})
        table.insert(ScenarioInfo.PlayersACUs, ScenarioInfo.PlayerCDR)
    elseif (LeaderFaction == 'cybran') then
        ScenarioInfo.PlayerCDR = ScenarioFramework.SpawnCommander('Player1', 'CybranPlayer', 'Warp', true, true, PlayerDeath,
        {'NaniteTorpedoTube', 'CoolingUpgrade'})
        table.insert(ScenarioInfo.PlayersACUs, ScenarioInfo.PlayerCDR)
    elseif (LeaderFaction == 'uef') then
        ScenarioInfo.PlayerCDR = ScenarioFramework.SpawnCommander('Player1', 'UEFPlayer', 'Warp', true, true, PlayerDeath,
        {'HeavyAntiMatterCannon', 'DamageStabilization'})
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
                ScenarioInfo.CoopCDR[coop] = ScenarioFramework.SpawnCommander(strArmy, 'UEFPlayer', 'Warp', true, true, PlayerDeath,
                {'HeavyAntiMatterCannon', 'DamageStabilization'})
                table.insert(ScenarioInfo.PlayersACUs, ScenarioInfo.CoopCDR[coop])
            elseif (factionIdx == 2) then
                ScenarioInfo.CoopCDR[coop] = ScenarioFramework.SpawnCommander(strArmy, 'AeonPlayer', 'Warp', true, true, PlayerDeath,
                {'HeatSink', 'CrysalisBeam'})
                table.insert(ScenarioInfo.PlayersACUs, ScenarioInfo.CoopCDR[coop])
            else
                ScenarioInfo.CoopCDR[coop] = ScenarioFramework.SpawnCommander(strArmy, 'CybranPlayer', 'Warp', true, true, PlayerDeath,
                {'NaniteTorpedoTube', 'CoolingUpgrade'})
                table.insert(ScenarioInfo.PlayersACUs, ScenarioInfo.CoopCDR[coop])
            end
            coop = coop + 1
            WaitSeconds(0.5)
        end
    end

    ForkThread(MissionP1)
    ForkThread(SetupSeraM1TauntTriggers)
    ScenarioFramework.CreateTimerTrigger(MissionSecondaryP1, 3*60)
    ScenarioFramework.CreateTimerTrigger(P1Serareveal, 2*60)
end

function MissionP1()

    local function MissionNameAnnouncement()
        ScenarioFramework.SimAnnouncement(ScenarioInfo.name, "Mission by Shadowlorda1, Map by speed2")
    end

    ScenarioFramework.CreateTimerTrigger(MissionNameAnnouncement, 12)

	ScenarioInfo.M1P1 = Objectives.Capture(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Capture the Seraphim lab',                -- title
        'We need to know what the Seraphim End plan is.', -- description
       
        {                              -- target
            MarkUnits = true,
            Units = {ScenarioInfo.M1ObjectiveLab1}, 
        }
    )
    ScenarioInfo.M1P1:AddResultCallback(
        function(result, units)
            if result then
                local newHandle = units[1]
                
                ScenarioInfo.P1Lab = newHandle
                ScenarioInfo.P1Lab:SetCustomName("Seraphim Lab")
                ScenarioInfo.P1Lab:SetMaxHealth(5000)             
                ScenarioInfo.P1Lab:SetHealth(ScenarioInfo.P1Lab, 5000)
                ScenarioInfo.P1Lab:SetReclaimable(false)
                ScenarioInfo.P1Lab:SetCapturable(true)
                ForkThread(MissionProtectP1)
            end
        end
    )

    ScenarioInfo.M2P1 = Objectives.CategoriesInArea(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Clear the Area',                 -- title
        'General Valerie needs this zone cleared to gate in.',  -- description
        'kill',                         -- action
        {                               -- target
            MarkArea = true,
            ShowProgress = true,
            ShowFaction = 'UEF',
            Requirements = {
                {   
                    Area = 'P1Obj1',
                    Category = categories.FACTORY + categories.TECH2 * categories.STRUCTURE * categories.ECONOMIC + categories.DEFENSE * categories.STRUCTURE - categories.WALL,
                    CompareOp = '<=',
                    Value = 0,
                    ArmyIndex = Order,
                },
            },
        }
    )
    ScenarioInfo.M2P1:AddResultCallback(
        function(result)
            if result then
                ForkThread(UEFIntroP1)
            end
        end
    )

    ScenarioInfo.M1Objectives = Objectives.CreateGroup('M1Objectives', Part2start)
    ScenarioInfo.M1Objectives:AddObjective(ScenarioInfo.M1P1)
    ScenarioInfo.M1Objectives:AddObjective(ScenarioInfo.M2P1)

    if ExpansionTimer then
        local M1MapExpandDelay = {55*60, 45*60, 35*60}
        ScenarioFramework.CreateTimerTrigger(UEFIntroP1, M1MapExpandDelay[Difficulty])  
    end  
end

function MissionProtectP1()

    ScenarioInfo.M1P2 = Objectives.Protect(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Protect the Seraphim lab',                -- title
        'We are downloading the information from the lab database.', -- description
       
        {                              -- target
            MarkUnits = true,
            Units = {ScenarioInfo.P1Lab}, 
        }
    )
    ScenarioInfo.M1P2:AddResultCallback(
    function(result)
        if (not result) then
            ScenarioFramework.Dialogue(OpStrings.Objectivefailed1, PlayerLose, true)   
        end
    end
    )
end

function MissionSecondaryP1()

    ForkThread(Player1Reinforcements)
    ScenarioFramework.Dialogue(OpStrings.Thalia2P1, nil, true)

    ScenarioInfo.S1P1 = Objectives.Timer(
            'secondary',                      -- type
            'incomplete',                   -- complete
            'Thalia can only send reinforcements for so long',                 -- title
            'With the Tech lock Jammer, Thalia can only send so much help before she has to focus on her own defense.',  -- description
            {                               -- target
                Timer = (733),
                ExpireResult = 'complete',
            }
        )

        ScenarioInfo.S1P1:AddResultCallback(
            function(result)
                if result then
                    P1EndReinforcements = true
                end
            end
        )
end

function P1Serareveal()

    ScenarioFramework.Dialogue(OpStrings.Reveal1P1, nil, true)
end

function Player1Units()

    local platoon

    for i = 1, 3 do
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Player1', 'P1PDrops', 'AttackFormation')
        CustomFunctions.PlatoonAttackWithTransports(platoon, 'P1PDrops', 'P1PDropM', 'P1TDMK', true)
    end
    WaitSeconds(2)
    for i = 1, 4 do
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Player1', 'P1Pbombers', 'AttackFormation')
        for k, v in platoon:GetPlatoonUnits() do
            ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P1PAirPatrol')))
        end        
    end
    WaitSeconds(1)
    for i = 1, 4 do
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Player1', 'P1Pfighters', 'AttackFormation')
        for k, v in platoon:GetPlatoonUnits() do
            ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P1PAirPatrol')))
        end         
    end
    for i = 1, 2 do
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Player1', 'P1PGunships', 'AttackFormation')
        for k, v in platoon:GetPlatoonUnits() do
            ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P1PAirPatrol')))
        end         
    end
    WaitSeconds(5)
    for i = 1, 2 do
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Player1', 'P1PNaval1', 'AttackFormation')
        ScenarioFramework.PlatoonPatrolChain(platoon, 'P1PNavalPatrol')
    end
    WaitSeconds(2)
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Player1', 'P1PNaval2', 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'P1PNavalPatrol')
end

function Player1Reinforcements()

    while (not P1EndReinforcements) do
        
        local platoon

        local quantity = {}
        quantity = {2, 2, 1}

        for i = 1, quantity[Difficulty] do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Player1', 'P1PDrops', 'AttackFormation')
            CustomFunctions.PlatoonAttackWithTransports(platoon, 'P1PDrops', 'P1PDropM', 'P1TDMK', true)
        end
        WaitSeconds(1)
        for i = 1, quantity[Difficulty] do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Player1', 'P1Pbombers', 'AttackFormation')
            for k, v in platoon:GetPlatoonUnits() do
                ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P1PAirPatrol')))
            end        
        end
        WaitSeconds(1)
        for i = 1, quantity[Difficulty] do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Player1', 'P1Pfighters', 'AttackFormation')
            for k, v in platoon:GetPlatoonUnits() do
                ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P1PAirPatrol')))
            end         
        end
        WaitSeconds(1)
        for i = 1, quantity[Difficulty] do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Player1', 'P1PNaval1', 'AttackFormation')
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P1PNavalPatrol')
        end
        WaitSeconds(3*60)
    end
end

function UEFIntroP1()

    if UEFSPAWN == true then
        return
    end
    UEFSPAWN = true

    ScenarioUtils.CreateArmyGroup('UEF', 'P1UECO')
    ScenarioFramework.Dialogue(OpStrings.EndP1, nil, true)

    ScenarioInfo.UEFACU = ScenarioFramework.SpawnCommander('UEF', 'UACU', 'Warp', 'General Valerie', true, false,
    {'AdvancedEngineering', 'T3Engineering', 'ResourceAllocation', 'Shield'}) 
    ScenarioInfo.UEFACU:SetAutoOvercharge(true)
    ScenarioInfo.UEFACU:SetVeterancy(5 - Difficulty)
    WaitSeconds(2)
    SetArmyEconomy(UEF, 10000, 10000)

    P1UEFAI.UEFbase1AI()
    ArmyBrains[UEF]:PBMSetCheckInterval(6)
    ForkThread(UEFMissionP2)

    if ScenarioInfo.M1P1.Active then
        ForkThread(P1SelfDestruct)
    end
end

function UEFMissionP2()

    ScenarioInfo.M2P2 = Objectives.Protect(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Protect General Valerie',                -- title
        'General Valerie is setting up her base, protect her.', -- description
       
        {                              -- target
            MarkUnits = true,
            Units = {ScenarioInfo.UEFACU}, 
        }
    )
    ScenarioInfo.M2P2:AddResultCallback(
    function(result)
        if (not result) then
            ScenarioFramework.Dialogue(OpStrings.Objectivefailed2, PlayerLose, true)   
        end
    end
    )
end

function P1SelfDestruct()

    WaitSeconds(25)

    ScenarioFramework.Dialogue(OpStrings.SelfP1, nil, true)

    ScenarioInfo.M3P1 = Objectives.Timer(
            'primary',                      -- type
            'incomplete',                   -- complete
            'The Seraphim are self-destructing the Lab!',                 -- title
            'You need to capture the lab Now! The Seraphim are attempting to self-destruct it!',  -- description
            {                               -- target
                Timer = (300),
                ExpireResult = 'failed',
            }
        )

        ScenarioInfo.M3P1:AddResultCallback(
            function(result)
                if (not result) then
                    PlayerLose()
                end
            end
        )
end

---Part 2

function Part2start()
    
    ForkThread(IntroP2)
end

function IntroP2()
    if ScenarioInfo.MissionNumber ~= 1 then
        return
    end
    ScenarioInfo.MissionNumber = 2

    if ScenarioInfo.M3P1.Active then
        ScenarioInfo.M3P1:ManualResult(true)  
    end

    WaitSeconds(3)

    ScenarioFramework.SetPlayableArea('AREA_2', true)

    ScenarioFramework.Dialogue(OpStrings.IntroP2, nil, true)

    P1SeraphimAI.Seraphimbase2AI()
    P1SeraphimAI.Orderbase3AI()
    P1SeraphimAI.Orderbase4AI()

    ScenarioUtils.CreateArmyGroup('Order', 'P1ODefenses2_D'.. Difficulty)

    Cinematics.EnterNISMode()
        Cinematics.SetInvincible('AREA_1')    
                        
        Cinematics.CameraTrackEntity(ScenarioInfo.P1Lab, 30, 1)
        WaitSeconds(3)
        Cinematics.CameraTrackEntity(ScenarioInfo.UEFACU, 30, 4)
        WaitSeconds(3)

        -- Gets player number and joins it to a string to make it refrence a camera marker e.g 'Cam_M1_Intro_Player1'
        local army = GetFocusArmy()
        if army == -1 then
        army = 1
        end
        local tblArmy = ListArmies()
        ScenarioInfo.PlayerCamString = tostring(tblArmy[army])

        Cinematics.CameraMoveToMarker('P1C' .. ScenarioInfo.PlayerCamString)
        
            
        Cinematics.SetInvincible('AREA_1', true) 
    Cinematics.ExitNISMode()

    ForkThread(UEFDefense)
    ForkThread(P2Intattacks)

    buffDef = Buffs['CheatIncome']
    buffAffects = buffDef.Affects
    buffAffects.EnergyProduction.Mult = 2
    buffAffects.MassProduction.Mult = 2

        for _, u in GetArmyBrain(Seraphim):GetPlatoonUniquelyNamed('ArmyPool'):GetPlatoonUnits() do
            Buff.ApplyBuff(u, 'CheatIncome')
        end
        for _, u in GetArmyBrain(Order):GetPlatoonUniquelyNamed('ArmyPool'):GetPlatoonUnits() do
            Buff.ApplyBuff(u, 'CheatIncome')
        end
       
    ForkThread(MissionP2)
    ForkThread(SetupSeraM2TauntTriggers)
    ScenarioFramework.CreateTimerTrigger(P2MidDialogue, 10*60)
end

function UEFDefense()

    WaitSeconds(3*60)
    P1UEFAI.ExpandBase()
    ScenarioInfo.UEFACU:AddBuildRestriction(categories.ueb2301 + categories.ueb2104 + categories.ueb4202 + categories.ueb5101 + categories.ueb2204 ) 
end

function P2Intattacks()

    local quantity = {}
    local trigger = {}
    local platoon

    -- Basic Land attack
    for i = 1, 4 do
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Seraphim', 'P1SUnits3', 'GrowthFormation', 2 + Difficulty)
        ScenarioFramework.PlatoonPatrolChain(platoon, 'P1SB1landattack'.. i)
    end

    for i = 1, 3 do
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Order', 'P1OLand1', 'GrowthFormation', 2 + Difficulty)
        ScenarioFramework.PlatoonPatrolChain(platoon, 'P1OB1Landattack'..i)
    end

    --Air attack

    -- sends swift winds if player has more than [60, 50, 40] planes, up to 6, 1 group per 14, 11, 10
    num = ScenarioFramework.GetNumOfHumanUnits(categories.AIR * categories.MOBILE)
    quantity = {40, 30, 20}
    trigger = {15, 13, 10}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 5) then
            num = 5
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Order', 'P1OAirFighter', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P1OB1Airattack' .. Random(1, 3))
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Seraphim', 'P1SFighters', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P1SB1Airattack' .. Random(1, 3))
        end
    end

    -- sends Gunships if player has more than [200, 150, 100] Units, up to 7, 1 group per 14, 11, 10
    num = ScenarioFramework.GetNumOfHumanUnits(categories.ALLUNITS - categories.WALL)
    quantity = {200, 150, 100}
    trigger = {100, 75, 50}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 5) then
            num = 5
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Order', 'P1OAirGunship', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P1OB1Airattack' .. Random(1, 3))
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Seraphim', 'P1SGunships', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P1SB1Airattack' .. Random(1, 3))
        end
    end

    -- Basic Naval
    for i = 1, 2 do
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Order', 'P1ONaval1', 'AttackFormation', Difficulty)
        ScenarioFramework.PlatoonPatrolChain(platoon, 'P1OB4Navalattack'.. i)
    end

    if Difficulty >= 2 then
        num = ScenarioFramework.GetNumOfHumanUnits(categories.TECH2 * categories.NAVAL)
        quantity = {0, 10, 5}
        if num > quantity[Difficulty] then
            num = math.ceil(num/trigger[Difficulty])
        if(num > 4) then
            num = 4
        end
            for i = 1, num do
                platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Order', 'P1ONavalD', 'AttackFormation', 1 + Difficulty)
                ScenarioFramework.PlatoonPatrolChain(platoon, 'P1OB4Navalattack'.. i)
            end
        end
    end
end

function MissionP2()
    if not SkipNIS2 then

        local M2MapExpandDelay = {25*60, 20*60, 15*60}

        ScenarioInfo.M2P2 = Objectives.Timer(
            'primary',                      -- type
            'incomplete',                   -- complete
            'Defend the Lab and General Valerie',                 -- title
            'We are accessing the Lab\'s data, you just need to hold your ground.',  -- description
            {                               -- target
                Timer = (M2MapExpandDelay[Difficulty]),
                ExpireResult = 'complete',
            }
        )
        ScenarioInfo.M2P2:AddResultCallback(
        function(result)
            if result then
                ScenarioInfo.M1P2:ManualResult(true)
                ForkThread(Part3start)
            end    
        end
        )

        ScenarioInfo.S2P2 = Objectives.CategoriesInArea(
        'secondary',                      -- type
        'incomplete',                   -- complete
        'Destroy Seraphim/Order Bases',                 -- title
        'Commander we can\'t risk the Seraphim forces overpowering General Valerie, take them out.',  -- description
        'kill',                         -- action
        {                               -- target
            MarkUnits = true,
            ShowProgress = true,
            Requirements = {
                {   
                    Area = 'P1Obj2',
                    Category = categories.FACTORY + categories.TECH2 * categories.ECONOMIC + categories.TECH3 * categories.ECONOMIC,
                    CompareOp = '<=',
                    Value = 0,
                    ArmyIndex = Seraphim,
                },
                {   
                    Area = 'P1Obj3',
                    Category = categories.FACTORY + categories.TECH2 * categories.ECONOMIC + categories.TECH3 * categories.ECONOMIC,
                    CompareOp = '<=',
                    Value = 0,
                    ArmyIndex = Seraphim,
                },
                {   
                    Area = 'P1Obj4',
                    Category = categories.FACTORY + categories.TECH2 * categories.ECONOMIC + categories.TECH3 * categories.ECONOMIC,
                    CompareOp = '<=',
                    Value = 0,
                    ArmyIndex = Order,
                },
            },
        }
    )

    else
        ForkThread(Part3start)
    end
end

function P2MidDialogue()

    ScenarioFramework.Dialogue(OpStrings.MidP2, nil, true)
end

-- Part 3

function Part3start()
    
    ForkThread(IntroP3)
end

function IntroP3()
    if ScenarioInfo.MissionNumber ~= 2 then
        return
    end
    ScenarioInfo.MissionNumber = 3

    WaitSeconds(3)

    ScenarioFramework.SetPlayableArea('AREA_3', true)

    ScenarioUtils.CreateArmyGroup('Seraphim', 'P1LabsDF2')

    ScenarioInfo.M2ObjectiveLab1 = ScenarioUtils.CreateArmyUnit('Seraphim', 'P1Labs2')
    ScenarioInfo.M2ObjectiveLab1:SetCustomName("Seraphim Tech Jammer")
    ScenarioInfo.M2ObjectiveLab1:SetMaxHealth(10000)             
    ScenarioInfo.M2ObjectiveLab1:SetHealth(ScenarioInfo.M2ObjectiveLab1, 10000)

    ScenarioUtils.CreateArmyGroup('Seraphim', 'P2Walls')
    ScenarioUtils.CreateArmyGroup('Order', 'P2OWalls')
    ScenarioUtils.CreateArmyGroup('QAI', 'P2CWalls')

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Seraphim', 'P2SPatrol', 'GrowthFormation', 2 + Difficulty)
        ScenarioFramework.PlatoonPatrolChain(platoon, 'P2SPatrol')

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'P2SPatrolAir_D'.. Difficulty, 'AttackFormation')
        for k, v in platoon:GetPlatoonUnits() do
            ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P2SB1ADefence1')))
        end 
    
    P2SeraphimAI.P2Seraphimbase1AI()
    P2SeraphimAI.P2Seraphimbase2AI()
    P2SeraphimAI.P2Seraphimbase3AI()
    P2SeraphimAI.P2Seraphimbase4AI()
    P2SeraphimAI.P2Orderbase1AI()
    P2SeraphimAI.P2Orderbase2AI()
    P2SeraphimAI.P2QAIbase1AI()

    ScenarioInfo.P2QACU = ScenarioFramework.SpawnCommander('QAI', 'P2QACU', false, 'QAI Drone', false, QAIACUdeath,
        {'MicrowaveLaserGenerator', 'StealthGenerator', 'CloakingGenerator', 'T3Engineering'})
        ScenarioInfo.P2QACU:SetAutoOvercharge(true)
        ScenarioInfo.P2QACU:SetVeterancy(1 + Difficulty)

    P1UEFAI.P2B1ULandattack()
    P1UEFAI.P2B1UAirattack()
    P1UEFAI.P2B1UNavalattack()

    Cinematics.EnterNISMode()
        Cinematics.SetInvincible('AREA_2')

        local VisMarker2_1 = ScenarioFramework.CreateVisibleAreaLocation(50, 'P2Vision1', 0, ArmyBrains[Player1])
        local VisMarker2_2 = ScenarioFramework.CreateVisibleAreaLocation(100, 'P2Vision2', 0, ArmyBrains[Player1])
        local VisMarker2_3 = ScenarioFramework.CreateVisibleAreaLocation(70, 'P2Vision3', 0, ArmyBrains[Player1])
    
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P2Cam1'), 0)
        ScenarioFramework.Dialogue(OpStrings.IntroP3, nil, true)
        WaitSeconds(4)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P2Cam2'), 4)
        WaitSeconds(5)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P2Cam3'), 4)
        WaitSeconds(4)
    
        ForkThread(
            function()
                WaitSeconds(1)
                VisMarker2_1:Destroy()
                VisMarker2_2:Destroy()
                VisMarker2_3:Destroy()
                WaitSeconds(1)
                ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('P2Vision1'), 60)
                ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('P2Vision2'), 110)
                ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('P2Vision3'), 80)
            end
        )
        -- Gets player number and joins it to a string to make it refrence a camera marker e.g 'Cam_M1_Intro_Player1'
        local army = GetFocusArmy()
        if army == -1 then
        army = 1
        end
        local tblArmy = ListArmies()
        ScenarioInfo.PlayerCamString = tostring(tblArmy[army])

        Cinematics.CameraMoveToMarker('P1C' .. ScenarioInfo.PlayerCamString)

        Cinematics.SetInvincible('AREA_2', true)
    Cinematics.ExitNISMode()

    ForkThread(MissionP3)
    ForkThread(SecondaryMissionP3)
    ForkThread(P3Intattacks)
    ForkThread(EnableStealthOnAirQ)
    ScenarioFramework.CreateTimerTrigger(P3MidDialogue, 15*60)

    buffDef = Buffs['CheatIncome']
    buffAffects = buffDef.Affects
    buffAffects.EnergyProduction.Mult = 2
    buffAffects.MassProduction.Mult = 2

        for _, u in GetArmyBrain(Seraphim):GetPlatoonUniquelyNamed('ArmyPool'):GetPlatoonUnits() do
            Buff.ApplyBuff(u, 'CheatIncome')
        end
        for _, u in GetArmyBrain(Order):GetPlatoonUniquelyNamed('ArmyPool'):GetPlatoonUnits() do
            Buff.ApplyBuff(u, 'CheatIncome')
        end
        for _, u in GetArmyBrain(QAI):GetPlatoonUniquelyNamed('ArmyPool'):GetPlatoonUnits() do
            Buff.ApplyBuff(u, 'CheatIncome')
        end  
    ForkThread(SetupSeraM3TauntTriggers)
end

function P3Intattacks()

    local quantity = {}
    local trigger = {}
    local platoon

    -- Basic Land attack
    for i = 1, 2 do
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Seraphim', 'P2SLand1', 'GrowthFormation', 2 + Difficulty)
        ScenarioFramework.PlatoonPatrolChain(platoon, 'P2SB2Landattack'.. i)

        platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Seraphim', 'P2SLand2', 'GrowthFormation', 2 + Difficulty)
        ScenarioFramework.PlatoonPatrolChain(platoon, 'P2SB3Landattack'.. i)

        platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Order', 'P2OLand', 'GrowthFormation', 2 + Difficulty)
        ScenarioFramework.PlatoonPatrolChain(platoon, 'P2OB1Landattack'..i)
    end

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Seraphim', 'P2SLand3', 'GrowthFormation', 2 + Difficulty)
    ScenarioFramework.PlatoonPatrolChain(platoon, 'P2SB1Landattack1')

    for i = 1, 3 do
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('QAI', 'P2QDrops', 'GrowthFormation', 5)
        CustomFunctions.PlatoonAttackWithTransports(platoon, 'P2CB1Drop1', 'P2CB1Dropattack1', 'P2QB1MK', true)
    end

    --Air attack

    -- sends swift winds if player has more than [60, 50, 40] planes, up to 6, 1 group per 14, 11, 10
    num = ScenarioFramework.GetNumOfHumanUnits(categories.AIR * categories.MOBILE)
    quantity = {40, 30, 20}
    trigger = {20, 15, 10}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 6) then
            num = 6
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Seraphim', 'P2SFighters', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P2SB1Airattack' .. Random(1, 4))
        end
    end

    -- sends Gunships if player has more than [200, 150, 100] Units, up to 7, 1 group per 14, 11, 10
    num = ScenarioFramework.GetNumOfHumanUnits(categories.ALLUNITS - categories.WALL)
    quantity = {200, 150, 100}
    trigger = {100, 75, 50}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 5) then
            num = 5
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Order', 'P2OGunships', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P2OB1Airattack' .. Random(1, 3))
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Seraphim', 'P2SGunship', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P2SB1Airattack' .. Random(1, 4))
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('QAI', 'P2QBombers', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P2CB1Airattack' .. Random(1, 3))
        end
    end

    -- Basic Naval
    for i = 1, 2 do
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Order', 'P2ONaval', 'AttackFormation', Difficulty)
        ScenarioFramework.PlatoonPatrolChain(platoon, 'P2OB1Navalattack'.. i)
    end
    if Difficulty >= 2 then
        num = ScenarioFramework.GetNumOfHumanUnits(categories.NAVAL * categories.TECH2)
        quantity = {0, 35, 25}
        if num > quantity[Difficulty] then
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Seraphim', 'P2SNaval', 'AttackFormation', Difficulty)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P2SB4Navalattack1') 
        end
    end   

    if Difficulty >= 2 then
        num = ScenarioFramework.GetNumOfHumanUnits(categories.NAVAL * categories.TECH2)
        quantity = {0, 45, 35}
        if num > quantity[Difficulty] then
            for i = 1, 2 do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Order', 'P2ONaval1', 'AttackFormation', Difficulty)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P2OB1Navalattack'.. i) 
        end
        end
    end   
end

function MissionP3()

    ScenarioInfo.M1P3 = Objectives.Kill(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Destroy the Tech Jammer',                 -- title
        'That Jammer is preventing access to T3 and Exp units.',  -- description
        {                              -- target
            MarkUnits = true,
            Units = {ScenarioInfo.M2ObjectiveLab1}, 
        }
    )
    ScenarioInfo.M1P3:AddResultCallback(
        function(result)
            if result then
                ForkThread(UnlockTech)
            end    
        end
     )

    ScenarioInfo.M2P3 = Objectives.CategoriesInArea(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Destroy Seraphim Bases',                 -- title
        'Commander we can\'t risk the Seraphim overpowering General Valerie, take them out.',  -- description
        'kill',                         -- action
        {                               -- target
            MarkUnits = true,
            ShowProgress = true,
            ShowFaction = 'Seraphim',
            Requirements = {
                {   
                    Area = 'P2_B1_Obj',
                    Category = categories.FACTORY + categories.TECH2 * categories.ECONOMIC + categories.TECH3 * categories.ECONOMIC,
                    CompareOp = '<=',
                    Value = 0,
                    ArmyIndex = Seraphim,
                },
                {   
                    Area = 'P2_B2_Obj',
                    Category = categories.FACTORY + categories.TECH2 * categories.ECONOMIC + categories.TECH3 * categories.ECONOMIC,
                    CompareOp = '<=',
                    Value = 0,
                    ArmyIndex = Seraphim,
                },
                {   
                    Area = 'P2_B3_Obj',
                    Category = categories.FACTORY + categories.TECH2 * categories.ECONOMIC + categories.TECH3 * categories.ECONOMIC,
                    CompareOp = '<=',
                    Value = 0,
                    ArmyIndex = Seraphim,
                },
                {   
                    Area = 'P2_B4_Obj',
                    Category = categories.FACTORY + categories.TECH2 * categories.ECONOMIC + categories.TECH3 * categories.ECONOMIC,
                    CompareOp = '<=',
                    Value = 0,
                    ArmyIndex = Seraphim,
                },
            },
        }
    )

    ScenarioInfo.M3P3 = Objectives.Kill(
        'secondary',                      -- type
        'incomplete',                   -- complete
        'Destroy QAI\'s ACU',                 -- title
        'QAI has a presence on this planet, destroy him.',  -- description
        {                              -- target
            MarkUnits = true,
            Units = {ScenarioInfo.P2QACU}, 
        }
    )

    ScenarioInfo.M2Objectives = Objectives.CreateGroup('M2Objectives', Part4start)
    ScenarioInfo.M2Objectives:AddObjective(ScenarioInfo.M1P3)
    ScenarioInfo.M2Objectives:AddObjective(ScenarioInfo.M2P3)

    if ExpansionTimer then
        local M3MapExpandDelay = {50*60, 40*60, 30*60}
        ScenarioFramework.CreateTimerTrigger(Part4start, M3MapExpandDelay[Difficulty])  
    end  
end

function SecondaryMissionP3()

    
    ScenarioInfo.Specialfunction = Random(1, 3)
    
    if  ScenarioInfo.Specialfunction == 1 then
    
    ScenarioInfo.M2QJammer = ScenarioUtils.CreateArmyUnit('Order', 'P2OJammer1')
    ScenarioInfo.M2QJammer:SetCustomName("Quantum Jammer")

    ScenarioUtils.CreateArmyGroup('Order', 'P2OJammerDef1')

    else
        if  ScenarioInfo.Specialfunction == 2 then

        ScenarioInfo.M2QJammer = ScenarioUtils.CreateArmyUnit('Order', 'P2OJammer2')
        ScenarioInfo.M2QJammer:SetCustomName("Quantum Jammer")

        ScenarioUtils.CreateArmyGroup('Order', 'P2OJammerDef2')
        else
            if  ScenarioInfo.Specialfunction == 3 then

            ScenarioInfo.M2QJammer = ScenarioUtils.CreateArmyUnit('Order', 'P2OJammer3')
            ScenarioInfo.M2QJammer:SetCustomName("Quantum Jammer")

            ScenarioUtils.CreateArmyGroup('Order', 'P2OJammerDef3')
            end
        end
    end

    WaitSeconds(5*60)

    ScenarioFramework.Dialogue(OpStrings.Thalia1P3, nil, true)

    ScenarioInfo.S2P3 = Objectives.Kill(
        'secondary',                      -- type
        'incomplete',                   -- complete
        'Find and Destroy Quantum Jammer',                 -- title
        'Thalia has requested a Jammer be located and Destroyed.',  -- description
        {                              -- target
            MarkUnits = true,
            Units = {ScenarioInfo.M2QJammer}, 
        }
    )
    ScenarioInfo.S2P3:AddResultCallback(
        function(result)
            if result then
                ForkThread(Player1ReinforcementsP3)
                ScenarioFramework.Dialogue(OpStrings.Thalia2P3, nil, true)
            end    
        end
     )
end

function Player1ReinforcementsP3()
 
    local platoon

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Player1', 'P2PEXP', 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'P1PDropM')
    WaitSeconds(1)
    for i = 1, 3 do
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Player1', 'P2PAir', 'AttackFormation')
        for k, v in platoon:GetPlatoonUnits() do
            ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P1PAirPatrol')))
        end        
    end
    WaitSeconds(1)
    for i = 1, 2 do
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Player1', 'P2PNaval', 'AttackFormation')
        ScenarioFramework.PlatoonPatrolChain(platoon, 'P1PNavalPatrol')
    end
end

function UnlockTech()

    ScenarioFramework.PlayUnlockDialogue()

    ScenarioFramework.RemoveRestrictionForAllHumans(
        categories.TECH3 + -- All Tech 3 
        categories.EXPERIMENTAL  -- All Experimentals
    )

    ScenarioFramework.Dialogue(OpStrings.TechJamDown, nil, true)

    P1UEFAI.ExpandBase2()
end

function QAIACUdeath()
    
    ScenarioFramework.CDRDeathNISCamera(ScenarioInfo.P2QACU, 4)
    ScenarioFramework.Dialogue(OpStrings.Death1, nil, true)

    ForkThread(P2KillQAIBase)
end

function P2KillQAIBase()
    local QAIUnits = ScenarioFramework.GetCatUnitsInArea((categories.ALLUNITS), 'AREA_4', ArmyBrains[QAI])
        for k, v in QAIUnits do
            if v and not v.Dead then
                v:Kill()
                WaitSeconds(Random(0.1, 0.3))
            end
        end
end

function EnableStealthOnAirQ()
    local T3AirUnits = {}
    while true do
        for _, v in ArmyBrains[QAI]:GetListOfUnits(categories.ura0303 + categories.ura0304  + categories.xra0305  + categories.ura0401, false) do
            if not ( T3AirUnits[v:GetEntityId()] or v:IsBeingBuilt() ) then
                v:ToggleScriptBit('RULEUTC_StealthToggle')
                T3AirUnits[v:GetEntityId()] = true
            end
        end
        WaitSeconds(10)
    end
end

function P3MidDialogue()

    ScenarioFramework.Dialogue(OpStrings.MidP3, nil, true)
end

-- Part 4

function Part4start()
    
    ForkThread(IntroP4)
end

function IntroP4()
    if ScenarioInfo.MissionNumber ~= 3 then
        return
    end
    ScenarioInfo.MissionNumber = 4

    WaitSeconds(3)

    ScenarioFramework.SetPlayableArea('AREA_4', true)

    ScenarioUtils.CreateArmyGroup('Seraphim', 'P3Walls')
    
    P3SeraphimAI.P3Seraphimbase1AI()
    P3SeraphimAI.P3Seraphimbase2AI()
    P3SeraphimAI.P3SeraphimbaseEXP1AI()
    P3SeraphimAI.P3SeraphimbaseEXP2AI()
    P3SeraphimAI.P3SeraphimbaseEXP3AI()
    P3SeraphimAI.P3Orderbase1AI()
    P3SeraphimAI.P3Orderbase2AI()
    P3SeraphimAI.P3OrderbaseEXP1AI()
    P3SeraphimAI.P3OrderbaseEXP2AI()

    ArmyBrains[Seraphim]:GiveResource('MASS', 4000)
    ArmyBrains[Seraphim]:GiveResource('ENERGY', 60000)

    ArmyBrains[Order]:GiveResource('MASS', 4000)
    ArmyBrains[Order]:GiveResource('ENERGY', 60000)

    local Antinukes = ArmyBrains[Seraphim]:GetListOfUnits(categories.xsb4302, false)
    for _, v in Antinukes do
        v:GiveTacticalSiloAmmo(4)
    end

    local Antinukes = ArmyBrains[Order]:GetListOfUnits(categories.uab4302, false)
    for _, v in Antinukes do
        v:GiveTacticalSiloAmmo(4)
    end

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'P3SAirPatrol_D'.. Difficulty, 'AttackFormation')
        for k, v in platoon:GetPlatoonUnits() do
            ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P3SAirPatrol')))
        end 

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'P3SBotP1', 'AttackFormation')
        for k, v in platoon:GetPlatoonUnits() do
            ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P3SBotPatrol1')))
        end 

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'P3SBotP2', 'AttackFormation')
        for k, v in platoon:GetPlatoonUnits() do
            ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P3SBotPatrol2')))
        end 

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'P3SBotP3', 'AttackFormation')
        for k, v in platoon:GetPlatoonUnits() do
            ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P3SBotPatrol3')))
        end 

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'P3OAirPatrol_D'.. Difficulty, 'AttackFormation')
        for k, v in platoon:GetPlatoonUnits() do
            ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P3OAirPatrol')))
        end

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'P3OGCP1', 'AttackFormation')
        for k, v in platoon:GetPlatoonUnits() do
            ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P3OGCPatrol1')))
        end 

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'P3OGCP2', 'AttackFormation')
        for k, v in platoon:GetPlatoonUnits() do
            ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P3OGCPatrol2')))
        end 

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'P3OGCP3', 'AttackFormation')
        for k, v in platoon:GetPlatoonUnits() do
            ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P3OGCPatrol3')))
        end  

    ScenarioInfo.P3SACU = ScenarioFramework.SpawnCommander('Seraphim', 'P3SACU', false, 'Oum-Eoshi', false, SeraACUdeath,
        {'AdvancedEngineering', 'T3Engineering', 'DamageStabilization', 'DamageStabilizationAdvanced', 'RateOfFire'})
        ScenarioInfo.P3SACU:SetAutoOvercharge(true)
        ScenarioInfo.P3SACU:SetVeterancy(1 + Difficulty)

    ScenarioInfo.P3OACU = ScenarioFramework.SpawnCommander('Order', 'P3OACU', false, 'Executioner Keleana', false, OrderACUdeath,
        {'EnhancedSensors','Shield', 'ShieldHeavy', 'AdvancedEngineering', 'T3Engineering'})
        ScenarioInfo.P3OACU:SetAutoOvercharge(true)
        ScenarioInfo.P3OACU:SetVeterancy(1 + Difficulty)
    ScenarioInfo.P3OACU:AddBuildRestriction(categories.xab2307) 

    Cinematics.EnterNISMode()
        Cinematics.SetInvincible('AREA_3')

        local VisMarker3_1 = ScenarioFramework.CreateVisibleAreaLocation(100, 'P3Vision1', 0, ArmyBrains[Player1])
        local VisMarker3_2 = ScenarioFramework.CreateVisibleAreaLocation(100, 'P3Vision2', 0, ArmyBrains[Player1])
        local VisMarker3_3 = ScenarioFramework.CreateVisibleAreaLocation(100, 'P3Vision3', 0, ArmyBrains[Player1])

        WaitSeconds(2)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P3Cam1'), 0)
        ScenarioFramework.Dialogue(OpStrings.IntroP4, nil, true)
        WaitSeconds(3)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P3Cam2'), 3)
        WaitSeconds(2)
        ForkThread(P4Intattacks)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P3Cam3'), 2)
        WaitSeconds(3)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P3Cam4'), 4)
        WaitSeconds(2)
        ForkThread(
            function()
                WaitSeconds(1)
                VisMarker3_1:Destroy()
                VisMarker3_2:Destroy()
                VisMarker3_3:Destroy()
                WaitSeconds(1)
                ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('P3Vision1'), 110)
                ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('P3Vision2'), 110)
                ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('P3Vision3'), 110)
            end
        )
        -- Gets player number and joins it to a string to make it refrence a camera marker e.g 'Cam_M1_Intro_Player1'
        local army = GetFocusArmy()
        if army == -1 then
        army = 1
        end
        local tblArmy = ListArmies()
        ScenarioInfo.PlayerCamString = tostring(tblArmy[army])

        Cinematics.CameraMoveToMarker('P1C' .. ScenarioInfo.PlayerCamString)

        Cinematics.SetInvincible('AREA_3', true)
    Cinematics.ExitNISMode()

    ForkThread(MissionP4)
    ForkThread(NukepartyA)
    ForkThread(SetupSeraM4TauntTriggers)

    if ScenarioInfo.M3P3.Active then
        ForkThread(P4QIntattacks)
    end

    buffDef = Buffs['CheatIncome']
    buffAffects = buffDef.Affects
    buffAffects.EnergyProduction.Mult = 2
    buffAffects.MassProduction.Mult = 2

        for _, u in GetArmyBrain(Seraphim):GetPlatoonUniquelyNamed('ArmyPool'):GetPlatoonUnits() do
            Buff.ApplyBuff(u, 'CheatIncome')
        end
        for _, u in GetArmyBrain(Order):GetPlatoonUniquelyNamed('ArmyPool'):GetPlatoonUnits() do
            Buff.ApplyBuff(u, 'CheatIncome')
        end
        for _, u in GetArmyBrain(QAI):GetPlatoonUniquelyNamed('ArmyPool'):GetPlatoonUnits() do
            Buff.ApplyBuff(u, 'CheatIncome')
        end  

    ScenarioFramework.CreateAreaTrigger(NukepartyS, 'AREA_4', categories.xsb2305, true, false, ArmyBrains[Seraphim], 1)

    ScenarioFramework.CreateAreaTrigger(NukepartyS2, 'AREA_4', categories.xsb2401, true, false, ArmyBrains[Seraphim], 1)
end

function MissionP4()

    ScenarioInfo.M1P4 = Objectives.Kill(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Kill The Seraphim and Order Commanders',                 -- title
        'We need finish here quickly, kill the enemy commanders.',  -- description
        {                              -- target
            MarkUnits = true,
            Units = {ScenarioInfo.P3SACU, ScenarioInfo.P3OACU}, 
        }
    )

    ScenarioInfo.M3Objectives = Objectives.CreateGroup('M3Objectives', PlayerWin)
    ScenarioInfo.M3Objectives:AddObjective(ScenarioInfo.M1P4)
    if ScenarioInfo.M1P3.Active then
        ScenarioInfo.M3Objectives:AddObjective(ScenarioInfo.M1P3)
    end   
    if ScenarioInfo.M2P3.Active then
        ScenarioInfo.M3Objectives:AddObjective(ScenarioInfo.M2P3)
    end 
end

function P4Intattacks()

    local quantity = {}
    local trigger = {}
    local platoon

    -- Basic Land attack
    for i = 1, 2 do
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Seraphim', 'P3SBotP1', 'GrowthFormation', 2 + Difficulty)
        ScenarioFramework.PlatoonPatrolChain(platoon, 'P3SB1Landattack'.. i)

        platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Order', 'P3OLand'.. i ..'_D'.. Difficulty, 'GrowthFormation', 2 + Difficulty)
        ScenarioFramework.PlatoonPatrolChain(platoon, 'P3OB1Landattack'..i)
    end

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Seraphim', 'P2SLand3', 'GrowthFormation', 2 + Difficulty)
    ScenarioFramework.PlatoonPatrolChain(platoon, 'P2SB1Landattack1')

    for i = 1, 3 do
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Seraphim', 'P3SDrops_D'.. Difficulty, 'GrowthFormation', 5)
        CustomFunctions.PlatoonAttackWithTransports(platoon, 'P3SDrop'.. i, 'P3SDropattack' .. i, 'P3SB1MK', true)
    end

    for i = 1, 3 do
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Seraphim', 'P3SDrops_D'.. Difficulty, 'GrowthFormation', 5)
        CustomFunctions.PlatoonAttackWithTransports(platoon, 'P3SDrop'.. i, 'P3SDropattack' .. i, 'P3SB1MK', true)
    end

    --Air attack

    -- sends swift winds if player has more than [60, 50, 40] planes, up to 6, 1 group per 14, 11, 10
    num = ScenarioFramework.GetNumOfHumanUnits(categories.AIR * categories.MOBILE)
    quantity = {40, 30, 20}
    trigger = {20, 15, 10}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 6) then
            num = 6
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Seraphim', 'P3SASF', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P3SB1Airattack' .. Random(1, 4))
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Order', 'P3OFighters', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P3OB1Airattack' .. Random(1, 4))
        end
    end

    -- sends Gunships if player has more than [200, 150, 100] Units, up to 7, 1 group per 14, 11, 10
    num = ScenarioFramework.GetNumOfHumanUnits(categories.ALLUNITS - categories.WALL)
    quantity = {200, 150, 100}
    trigger = {100, 75, 50}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 6) then
            num = 6
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Order', 'P3OGunships', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P3OB1Airattack' .. Random(1, 4))
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Seraphim', 'P3SBombers', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P3SB1Airattack' .. Random(1, 4))
        end
    end

    local LandExp = ScenarioFramework.GetListOfHumanUnits(categories.EXPERIMENTAL * categories.LAND)
    local num = table.getn(LandExp)

    if num > 0 then
            quantity = {3, 2, 1}
            if num > quantity[Difficulty] then
                num = 4
            end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'P3OGunships', 'GrowthFormation')
            IssueAttack(platoon:GetPlatoonUnits(), LandExp[i])
            IssueAggressiveMove(platoon:GetPlatoonUnits(), ScenarioUtils.MarkerToPosition('Player1'))
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'P3SBombers', 'GrowthFormation')
            IssueAttack(platoon:GetPlatoonUnits(), LandExp[i])
            IssueAggressiveMove(platoon:GetPlatoonUnits(), ScenarioUtils.MarkerToPosition('Player1'))
        end
    end

    local AirExp = ScenarioFramework.GetListOfHumanUnits(categories.EXPERIMENTAL * categories.AIR)
    local num = table.getn(AirExp)
    if num > 0 then
            quantity = {3, 2, 1}
            if num > quantity[Difficulty] then
                num = 5
            end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'P3SASF', 'GrowthFormation')
            IssueAttack(platoon:GetPlatoonUnits(), AirExp[i])
            IssueAggressiveMove(platoon:GetPlatoonUnits(), ScenarioUtils.MarkerToPosition('Player1'))
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Order', 'P3OFighters', 'GrowthFormation')
            IssueAttack(platoon:GetPlatoonUnits(), AirExp[i])
            IssueAggressiveMove(platoon:GetPlatoonUnits(), ScenarioUtils.MarkerToPosition('Player1'))
        end
    end

    -- Basic Naval
    
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Order', 'P3ONaval1_D'.. Difficulty, 'AttackFormation', Difficulty)
    ScenarioFramework.PlatoonPatrolChain(platoon, 'P3OB2Navalattack1')

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Seraphim', 'P3SNaval_D' .. Difficulty, 'AttackFormation', Difficulty)
    ScenarioFramework.PlatoonPatrolChain(platoon, 'P3SB2Navalattack1')  
end

-- If QAI is still alive expand his base, and launch attack.

function P4QIntattacks()

    local quantity = {}
    local trigger = {}
    local platoon

    P2SeraphimAI.P3QAIbase1AI()
    P2SeraphimAI.P3QAIbase2AI()
    ScenarioUtils.CreateArmyGroup('QAI', 'P3QDefenses_D'.. Difficulty)
    ForkThread(NukepartyQ)

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'P3QAirPatrol_D'.. Difficulty, 'AttackFormation')
        for k, v in platoon:GetPlatoonUnits() do
            ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P2CB1ADefence1')))
        end 

    for i = 1, 3 do
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('QAI', 'P2QDrops', 'GrowthFormation', 5)
        CustomFunctions.PlatoonAttackWithTransports(platoon, 'P2CB1Drop1', 'P2CB1Dropattack1', 'P2QB1MK', true)
    end

    for i = 1, 3 do
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('QAI', 'P2QDrops', 'GrowthFormation', 5)
        CustomFunctions.PlatoonAttackWithTransports(platoon, 'P3SDrop'.. i, 'P3SDropattack' .. i, 'P2QB1MK', true)
    end

    -- sends Gunships if player has more than [200, 150, 100] Units, up to 7, 1 group per 14, 11, 10
    num = ScenarioFramework.GetNumOfHumanUnits(categories.TECH3)
    quantity = {70, 60, 50}
    trigger = {45, 30, 25}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 3) then
            num = 3
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('QAI', 'P3QAirattack_D' .. Difficulty, 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P2CB1Airattack' .. i)
        end
    end

    -- Basic Naval
    
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('QAI', 'P3QNaval_D'.. Difficulty, 'AttackFormation', Difficulty)
    ScenarioFramework.PlatoonPatrolChain(platoon, 'P3CB1Navalattack1')
end

-- Nuke Functions

function NukepartyA()

    WaitSeconds(20)
    local AeonNuke = ArmyBrains[Order]:GetListOfUnits(categories.uab2305, false)
    local plat = ArmyBrains[Order]:MakePlatoon('', '')
        ArmyBrains[Order]:AssignUnitsToPlatoon(plat, {AeonNuke[1]}, 'Attack', 'NoFormation')
        plat:ForkAIThread(plat.NukeAI)
end

function NukepartyQ()

    WaitSeconds(40)
    local QAINuke = ArmyBrains[QAI]:GetListOfUnits(categories.urb2305, false)
    local plat = ArmyBrains[QAI]:MakePlatoon('', '')
        ArmyBrains[QAI]:AssignUnitsToPlatoon(plat, {QAINuke[1]}, 'Attack', 'NoFormation')
        plat:ForkAIThread(plat.NukeAI)
end

function NukepartyS()

    local SeraNuke = ArmyBrains[Seraphim]:GetListOfUnits(categories.xsb2305, false)
    local plat = ArmyBrains[Seraphim]:MakePlatoon('', '')
        ArmyBrains[Seraphim]:AssignUnitsToPlatoon(plat, {SeraNuke[1]}, 'Attack', 'NoFormation')
        plat:ForkAIThread(plat.NukeAI)
end

function NukepartyS2()

    local SeraNuke = ArmyBrains[Seraphim]:GetListOfUnits(categories.xsb2401, false)
    local plat = ArmyBrains[Seraphim]:MakePlatoon('', '')
        ArmyBrains[Seraphim]:AssignUnitsToPlatoon(plat, {SeraNuke[1]}, 'Attack', 'NoFormation')
        plat:ForkAIThread(plat.NukeAI)
end

-- Sera and Order Deaths and Bases Contrl K

function SeraACUdeath()
    
    ScenarioFramework.CDRDeathNISCamera(ScenarioInfo.P3SACU, 4)
    ScenarioFramework.Dialogue(OpStrings.Death2, nil, true)

    ForkThread(P2KillSeraBase)
end

function P2KillSeraBase()
    local SeraUnits = ScenarioFramework.GetCatUnitsInArea((categories.ALLUNITS), 'AREA_4', ArmyBrains[Seraphim])
        for k, v in SeraUnits do
            if v and not v.Dead then
                v:Kill()
                WaitSeconds(Random(0.1, 0.3))
            end
        end
end

function OrderACUdeath()
    
    ScenarioFramework.CDRDeathNISCamera(ScenarioInfo.P3OACU, 4)
    ScenarioFramework.Dialogue(OpStrings.Death3, nil, true)

    ForkThread(P2KillOrderBase)
end

function P2KillOrderBase()
    local OrderUnits = ScenarioFramework.GetCatUnitsInArea((categories.ALLUNITS), 'AREA_4', ArmyBrains[Order])
        for k, v in OrderUnits do
            if v and not v.Dead then
                v:Kill()
                WaitSeconds(Random(0.1, 0.3))
            end
        end
end

-- End game

function PlayerWin()
    if not ScenarioInfo.OpEnded then
        ScenarioInfo.M2P2:ManualResult(true)  
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

--Taunt Functions

function SetupSeraM1TauntTriggers()
  
    SeraTM:AddEnemiesKilledTaunt('P1Taunt3', ArmyBrains[Seraphim], categories.STRUCTURE, 10)
    SeraTM:AddUnitsKilledTaunt('P1Taunt1', ArmyBrains[Seraphim], categories.STRUCTURE * categories.DEFENSE, 10)
    SeraTM:AddUnitsKilledTaunt('P1Taunt2', ArmyBrains[Seraphim], categories.LAND * categories.MOBILE, 50)

    SeraTM:AddUnitsKilledTaunt('P1Taunt4', ArmyBrains[Order], categories.STRUCTURE * categories.ECONOMIC, 10)
    SeraTM:AddUnitsKilledTaunt('P1Taunt5', ArmyBrains[Order], categories.STRUCTURE * categories.FACTORY, 4)
    
end

function SetupSeraM2TauntTriggers()
    
    SeraTM:AddEnemiesKilledTaunt('P2Taunt2', ArmyBrains[Order], categories.NAVAL, 20)
    SeraTM:AddUnitsKilledTaunt('P2Taunt1', ArmyBrains[Seraphim], categories.STRUCTURE + categories.DEFENSE, 5)
    SeraTM:AddUnitsKilledTaunt('P2Taunt3', ArmyBrains[Order], categories.STRUCTURE * categories.FACTORY, 4)

end

function SetupSeraM3TauntTriggers()

        SeraTM:AddTauntingCharacter(ScenarioInfo.P2QACU)
    
        SeraTM:AddEnemiesKilledTaunt('P3Taunt2', ArmyBrains[Order], categories.AIR * categories.MOBILE, 30)
        SeraTM:AddEnemiesKilledTaunt('P3Taunt3', ArmyBrains[Order], categories.LAND * categories.MOBILE, 70)
        SeraTM:AddUnitsKilledTaunt('P3Taunt1', ArmyBrains[Seraphim], categories.EXPERIMENTAL, 1)
        SeraTM:AddUnitsKilledTaunt('P3Taunt4', ArmyBrains[QAI], categories.NAVAL * categories.DESTROYER, 15)
        SeraTM:AddUnitsKilledTaunt('P3Taunt5', ArmyBrains[QAI], categories.STRUCTURE * categories.FACTORY, 3)
    
        SeraTM:AddDamageTaunt('P3Taunt6', ScenarioInfo.P2QACU, .50)

end

function SetupSeraM4TauntTriggers()

        SeraTM:AddTauntingCharacter(ScenarioInfo.P2C1ACU)
        SeraTM:AddTauntingCharacter(ScenarioInfo.P2C1ACU)
    
        SeraTM:AddEnemiesKilledTaunt('P4Taunt1', ArmyBrains[Seraphim], categories.EXPERIMENTAL, 3)
        SeraTM:AddUnitsKilledTaunt('P4Taunt2', ArmyBrains[Seraphim], categories.EXPERIMENTAL, 2)
        SeraTM:AddEnemiesKilledTaunt('P4Taunt3', ArmyBrains[Order], categories.EXPERIMENTAL , 5)
        SeraTM:AddUnitsKilledTaunt('P4Taunt3', ArmyBrains[Order], categories.EXPERIMENTAL, 5)
    
        SeraTM:AddDamageTaunt('P4Taunt5', ScenarioInfo.P3SACU, .50)
    
        SeraTM:AddDamageTaunt('P4Taunt6', ScenarioInfo.P3OACU, .50)

end