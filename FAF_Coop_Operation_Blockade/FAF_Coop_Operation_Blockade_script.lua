------------------------------
-- Coalition Campaign - Mission 1
--
-- Author: Shadowlorda1
------------------------------
local OpStrings = import('/maps/FAF_Coop_Operation_Blockade/FAF_Coop_Operation_Blockade_strings.lua')
local Buff = import('/lua/sim/Buff.lua')
local Cinematics = import('/lua/cinematics.lua')
local P3SeraphimAI = import('/maps/FAF_Coop_Operation_Blockade/SeraphimaiP3.lua')
local P2SeraphimAI = import('/maps/FAF_Coop_Operation_Blockade/SeraphimaiP2.lua')
local P1SeraphimAI = import('/maps/FAF_Coop_Operation_Blockade/SeraphimaiP1.lua')
local Objectives = import('/lua/ScenarioFramework.lua').Objectives
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local Utilities = import('/lua/Utilities.lua')
local TauntManager = import('/lua/TauntManager.lua')

local SeraTM = TauntManager.CreateTauntManager('Sera1TM', '/maps/FAF_Coop_Operation_Blockade/FAF_Coop_Operation_Blockade_strings.lua')

ScenarioInfo.Player1 = 1
ScenarioInfo.Seraphim = 2
ScenarioInfo.Seraphim2 = 3
ScenarioInfo.Player2 = 4
ScenarioInfo.Player3 = 5
ScenarioInfo.Player4 = 6

local Difficulty = ScenarioInfo.Options.Difficulty
local ExpansionTimer = ScenarioInfo.Options.Expansion == 'true'

local Player1 = ScenarioInfo.Player1
local Seraphim = ScenarioInfo.Seraphim
local Seraphim2 = ScenarioInfo.Seraphim2
local Player2 = ScenarioInfo.Player2
local Player3 = ScenarioInfo.Player3
local Player4 = ScenarioInfo.Player4

local Debug = false
local timeAttackP3 = {50*60, 35*60, 25*60}

local AssignedObjectives = {}

local NIS1InitialDelay = 3

function OnPopulate(Self)
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
    
    SetArmyColor('Seraphim2', 183, 101, 24)
    ScenarioFramework.SetSeraphimColor(Seraphim)
    SetArmyUnitCap(Seraphim, 3000)
    SetArmyUnitCap(Seraphim2, 3000)
    ScenarioFramework.SetSharedUnitCap(4800)
    
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
    
    ScenarioUtils.CreateArmyGroup('Seraphim', 'Wreakbase1', true)
    ScenarioUtils.CreateArmyGroup('Seraphim', 'P1Bwalls')
    ScenarioUtils.CreateArmyGroup('Seraphim', 'ExtraBases_D' .. Difficulty)
     
    P1SeraphimAI.Seraphimbase1AI()
    P1SeraphimAI.Seraphimbase2AI()

    ArmyBrains[Seraphim]:PBMSetCheckInterval(6)
    
    buffDef = Buffs['CheatIncome']
    buffAffects = buffDef.Affects
    buffAffects.EnergyProduction.Mult = 2
    buffAffects.MassProduction.Mult = 1.5

       for _, u in GetArmyBrain(Seraphim):GetPlatoonUniquelyNamed('ArmyPool'):GetPlatoonUnits() do
               Buff.ApplyBuff(u, 'CheatIncome')
       end       
end

function OnStart(Self)
    ScenarioFramework.SetPlayableArea('AREA_1', false)   
    
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P1Cam1'), 0)
    ForkThread(Intro1)
end

-- Part 1

function Intro1()

    Cinematics.EnterNISMode()
   
    local VisMarker1_1 = ScenarioFramework.CreateVisibleAreaLocation(20, 'P1vision1', 0, ArmyBrains[Player1])
    local VisMarker1_2 = ScenarioFramework.CreateVisibleAreaLocation(20, 'P1vision2', 0, ArmyBrains[Player1])
    local VisMarker1_3 = ScenarioFramework.CreateVisibleAreaLocation(60, 'P1vision3', 0, ArmyBrains[Player1])
   
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P1Cam2'), 0)
    ScenarioFramework.Dialogue(OpStrings.IntroP1, nil, true)
    WaitSeconds(4)
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P1Cam3'), 3)
    WaitSeconds(4)
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P1Cam4'), 3)
    WaitSeconds(4)
    
    ForkThread(
            function()
                WaitSeconds(1)
                VisMarker1_1:Destroy()
                VisMarker1_2:Destroy()
                VisMarker1_3:Destroy()
                WaitSeconds(1)
                ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('P1vision1'), 40)
                ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('P1vision2'), 40)
                ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('P1vision3'), 70)
            end
        )
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P1Cam1'), 2)

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
    
    Cinematics.ExitNISMode()
   
    ForkThread(MissionP1)

    SetupSeraP2TauntTriggers()

    ScenarioFramework.CreateArmyIntelTrigger(MissionP1Secondary, ArmyBrains[Player1], 'LOSNow', false, true, categories.xsb2303, true, ArmyBrains[Seraphim]) 
end

function MissionP1()
    
    ScenarioInfo.MissionNumber = 1
  
    ScenarioInfo.M1P1 = Objectives.CategoriesInArea(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Destroy Seraphim Bases',                 -- title
        'Eliminate the Seraphim bases to move on the gates',  -- description
        'kill',                         -- action
        {                               -- target
            MarkUnits = true,
            ShowProgress = true,
            Requirements = {
                {   
                    Area = 'Objective1',
                    Category = categories.FACTORY + categories.TECH3 * categories.STRUCTURE * categories.ECONOMIC + categories.TECH2 * categories.STRUCTURE * categories.ECONOMIC,
                    CompareOp = '<=',
                    Value = 0,
                    ArmyIndex = Seraphim,
                },
                {   
                    Area = 'Objective2',
                    Category = categories.FACTORY + categories.TECH3 * categories.STRUCTURE * categories.ECONOMIC + categories.TECH2 * categories.STRUCTURE * categories.ECONOMIC,
                    CompareOp = '<=',
                    Value = 0,
                    ArmyIndex = Seraphim,
                },
            },
        }
    )
    ScenarioInfo.M1P1:AddResultCallback(
        function(result)
            if(result) then
                ForkThread(IntroP2)
            end 
        end
    )

    ScenarioFramework.CreateTimerTrigger(P1Serareveal, 2*60)

    ScenarioFramework.CreateTimerTrigger(MidP1, 20*60)

    if ExpansionTimer then
        local M1MapExpandDelay = {40*60, 35*60, 30*60}
        ScenarioFramework.CreateTimerTrigger(IntroP2, M1MapExpandDelay[Difficulty])  
    end 
end

function MissionP1Secondary()

    ScenarioFramework.Dialogue(OpStrings.SecondaryP1, nil, true)

    ScenarioInfo.M1P1S1 = Objectives.CategoriesInArea(
        'secondary',                      -- type
        'incomplete',                   -- complete
        'Destroy Seraphim Artillery Positions',                 -- title
        'Destroy them to clear the water way for your navy.',  -- description
        'kill',                         -- action
        {                               -- target
            MarkUnits = true,
            ShowFaction = true,
            Requirements = {
                {   
                    Area = 'AREA_1',
                    Category = categories.STRUCTURE * categories.ARTILLERY,
                    CompareOp = '<=',
                    Value = 0,
                    ArmyIndex = Seraphim,
                },
               
            },
        }
   )
   ScenarioInfo.M1P1S1:AddResultCallback(
        function(result)
            if(result) then
                ScenarioFramework.Dialogue(OpStrings.SecondaryEndP1, nil, true)
            end
        end
    )
end

function P1Serareveal()

    ScenarioFramework.Dialogue(OpStrings.RevealP1, nil, true)
end

function MidP1()

    ScenarioFramework.Dialogue(OpStrings.MidP1, nil, true)
end

--Part 2

function IntroP2()

    if ScenarioInfo.MissionNumber ~= 1 then
        return
    end
    ScenarioInfo.MissionNumber = 2

    ScenarioFramework.SetPlayableArea('AREA_2', true)
   
    P2SeraphimAI.Seraphimbase1P2AI()
    P2SeraphimAI.Seraphimbase2P2AI()
    P2SeraphimAI.Seraphimbase3P2AI()

    ArmyBrains[Seraphim]:PBMSetCheckInterval(6)
    ArmyBrains[Seraphim2]:PBMSetCheckInterval(6)
   
    ScenarioUtils.CreateArmyGroup('Seraphim', 'Wreakbase2', true)
    ScenarioUtils.CreateArmyGroup('Seraphim', 'P2Bwalls')
    ScenarioUtils.CreateArmyGroup('Seraphim2', 'P2SBwalls')
    
    ScenarioInfo.SeraACU = ScenarioFramework.SpawnCommander('Seraphim', 'SeraCom1', false, 'Vuth-Vuthroz', false, SeraCommanderKilled,
    {'BlastAttack', 'DamageStabilization', 'DamageStabilizationAdvanced', 'RateOfFire'})
    ScenarioInfo.SeraACU:SetAutoOvercharge(true)
    ScenarioInfo.SeraACU:SetVeterancy(1 + Difficulty)
        
    ScenarioInfo.Gate1 = ScenarioUtils.CreateArmyUnit('Seraphim', 'Gate1')
    ScenarioInfo.Gate2 = ScenarioUtils.CreateArmyUnit('Seraphim', 'Gate2')
    ScenarioInfo.Gate3 = ScenarioUtils.CreateArmyUnit('Seraphim2', 'Gate3')
   
    Cinematics.EnterNISMode()
        Cinematics.SetInvincible('AREA_1')
   
        local VisMarker2_1 = ScenarioFramework.CreateVisibleAreaLocation(100, 'P2vision1', 0, ArmyBrains[Player1])
        local VisMarker2_2 = ScenarioFramework.CreateVisibleAreaLocation(100, 'P2vision2', 0, ArmyBrains[Player1])
   
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P2Cam1'), 0)
        ScenarioFramework.Dialogue(OpStrings.IntroP2, nil, true)
        WaitSeconds(2)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P2Cam2'), 3)
        WaitSeconds(1)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P2Cam3'), 3)
        WaitSeconds(1)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P2Cam4'), 3)
        WaitSeconds(2)
        ForkThread(
            function()
                WaitSeconds(1)
                VisMarker2_1:Destroy()
                VisMarker2_2:Destroy()
                WaitSeconds(1)
                ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('P2vision1'), 120)
                ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('P2vision2'), 120)
            end
        )
                
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P1Cam1'), 1)
        Cinematics.SetInvincible('AREA_1', true)
    Cinematics.ExitNISMode()
    
    units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'P2Defense1', 'AttackFormation')
    for _, v in units:GetPlatoonUnits() do
       ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P2Airdefense1')))
    end
    
    units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim2', 'P2S2Defense1', 'AttackFormation')
    for _, v in units:GetPlatoonUnits() do
       ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P2Airdefense2')))
    end
    
    units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'P2Defense2_D' .. Difficulty, 'AttackFormation')
    for _, v in units:GetPlatoonUnits() do
       ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P2Landdefense1')))
    end
    
    units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'P2Defense3_D' .. Difficulty, 'AttackFormation')
    for _, v in units:GetPlatoonUnits() do
       ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P2Landdefense2')))
    end

    ForkThread(MissionP2)
    ForkThread(P2Intattacks)
    ForkThread(EnableOCOnACUs)
    SetupSeraP2TauntTriggers()
    
    buffDef = Buffs['CheatIncome']
    buffAffects = buffDef.Affects
    buffAffects.EnergyProduction.Mult = 2
    buffAffects.MassProduction.Mult = 2

    for _, u in GetArmyBrain(Seraphim):GetPlatoonUniquelyNamed('ArmyPool'):GetPlatoonUnits() do
        Buff.ApplyBuff(u, 'CheatIncome')
    end

    for _, u in GetArmyBrain(Seraphim2):GetPlatoonUniquelyNamed('ArmyPool'):GetPlatoonUnits() do
        Buff.ApplyBuff(u, 'CheatIncome')
    end
    
    ScenarioFramework.CreateTimerTrigger(MissionP2Secondary, 3*60)
end 

function MissionP2()
    
    ScenarioInfo.M1P2 = Objectives.Kill(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Destroy Seraphim Gates',                 -- title
        'Eliminate the Seraphim gates to stop the Seraphim from retreating here.',  -- description
        {                               -- target
            MarkUnits = true,
            ShowProgress = true,
            Units = {ScenarioInfo.Gate1, ScenarioInfo.Gate2, ScenarioInfo.Gate3},
        }
    )
   
    ScenarioInfo.M2P2 = Objectives.Kill(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Kill the Seraphim Commander',                 -- title
        'Eliminate the Seraphim Commander, He is guarding one of the gates',  -- description
        {                               -- target
            MarkUnits = true,
            ShowProgress = true,
            Units = {ScenarioInfo.SeraACU},
        }
    )

    ScenarioFramework.CreateTimerTrigger(MidP2, 15*60)

    if ExpansionTimer then
        local M2MapExpandDelay = {40*60, 35*60, 30*60}
        ScenarioFramework.CreateTimerTrigger(IntroP3, M2MapExpandDelay[Difficulty]) 
    end   

    ScenarioInfo.M2Objectives = Objectives.CreateGroup('M2Objectives', Part3start)
    ScenarioInfo.M2Objectives:AddObjective(ScenarioInfo.M1P2)
    ScenarioInfo.M2Objectives:AddObjective(ScenarioInfo.M2P2)
    if ScenarioInfo.M1P1.Active then
        ScenarioInfo.M2Objectives:AddObjective(ScenarioInfo.M1P1)
    end
end 

function MissionP2Secondary()
    
    P2SeraphimAI.Seraphimbase4P2AI()
    
    ScenarioInfo.SeraSACU = ScenarioFramework.SpawnCommander('Seraphim2', 'P2S2ACU', 'Warp', 'Zorez-thooum', false, SeraCommanderSKilled,
    {'AdvancedEngineering','T3Engineering', 'ResourceAllocation', 'ResourceAllocationAdvanced', 'DamageStabilization', 'DamageStabilizationAdvanced'})
    ScenarioInfo.SeraSACU:SetAutoOvercharge(true)
    ScenarioInfo.SeraSACU:SetVeterancy(2 + Difficulty)
    
    WaitSeconds(6)
    
    Cinematics.EnterNISMode()
   
   local VisMarkerS1_1 = ScenarioFramework.CreateVisibleAreaLocation(100, 'P2Svision1', 0, ArmyBrains[Player1])

   Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P2SCam1'), 0)
    ScenarioFramework.Dialogue(OpStrings.SecondaryP2, nil, true)
    WaitSeconds(2)

   ForkThread(
            function()
                WaitSeconds(1)
                VisMarkerS1_1:Destroy()
                WaitSeconds(1)
                ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('P2Svision1'), 120)
                end 
            )
                
                
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P1Cam1'), 1)
    
    Cinematics.ExitNISMode()
    
    units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim2', 'P2S2AirUnits', 'AttackFormation')
    for _, v in units:GetPlatoonUnits() do
       ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P2S2B2Airdefense1')))
    end
    
    units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim2', 'P2S2NavalUnits', 'AttackFormation')
    for _, v in units:GetPlatoonUnits() do
       ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P2S2B2Navaldefense1')))
    end
    
    ScenarioInfo.M2S1P2 = Objectives.Kill(
        'secondary',                      -- type
        'incomplete',                   -- complete
        'Kill New Seraphim Commander',                 -- title
        'A Seraphim commander has just gated in. Kill them before they can become a threat.',  -- description
        {                               -- target
            MarkUnits = true,
            ShowProgress = true,
            Units = {ScenarioInfo.SeraSACU},
        }
    )
    ScenarioInfo.M2S1P2:AddResultCallback(
    function(result)
        if(result) then
            ScenarioFramework.Dialogue(OpStrings.SecondaryEndP2, nil, true)
        end
    end
    )
end

function SeraCommanderKilled()

    ScenarioFramework.CDRDeathNISCamera(ScenarioInfo.SeraACU, 4)
    ScenarioFramework.Dialogue(OpStrings.Death1P2, nil, true)
    ForkThread(P2KillSeraBase)  
end

function SeraCommanderSKilled()

    ScenarioFramework.CDRDeathNISCamera(ScenarioInfo.SeraSACU, 4)
    ForkThread(P2SKillSeraBase)  
end

function P2KillSeraBase()
    local SeraUnits = ScenarioFramework.GetCatUnitsInArea((categories.ALLUNITS), 'AREA_2', ArmyBrains[Seraphim])
        for k, v in SeraUnits do
            if v and not v.Dead then
                v:Kill()
                WaitSeconds(Random(0.1, 0.3))
            end
        end
end

function P2SKillSeraBase()
    local SeraSUnits = ScenarioFramework.GetCatUnitsInArea((categories.ALLUNITS), 'ACUdeath1', ArmyBrains[Seraphim2])
        for k, v in SeraSUnits do
            if v and not v.Dead then
                v:Kill()
                WaitSeconds(Random(0.1, 0.3))
            end
        end
end

function P2Intattacks()

    local quantity = {}
    local trigger = {}
    local platoon

     -- Air attack

    -- sends ASF if player has more than [50, 40, 30] planes, up to 10, 1 group per 14, 11, 10
    num = ScenarioFramework.GetNumOfHumanUnits(categories.AIR * categories.MOBILE)
    quantity = {30, 20, 10}
    trigger = {20, 15, 10}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 8) then
            num = 8
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Seraphim', 'P2AirIntercept_D' .. Difficulty, 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P2IntAirattack' .. Random(1, 5))
        end
    end

    -- sends swift winds if player has more than [60, 50, 40] planes, up to 10, 1 group per 14, 11, 10
    num = ScenarioFramework.GetNumOfHumanUnits(categories.STRUCTURE * categories.DEFENSE - categories.TECH1)
    quantity = {50, 40, 30}
    trigger = {25, 20, 15}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 6) then
            num = 6
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Seraphim', 'P2AirBomber', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P2IntAirattack' .. Random(1, 5))
        end
    end

    -- sends swift winds if player has more than [60, 50, 40] planes, up to 10, 1 group per 14, 11, 10
    num = ScenarioFramework.GetNumOfHumanUnits(categories.ALLUNITS - categories.WALL)
    quantity = {200, 150, 100}
    trigger = {60, 50, 40}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 8) then
            num = 8
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Seraphim', 'P2AirGunships', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P2IntAirattack' .. Random(1, 5))
        end
    end

    -- Subhunters

    -- sends Subhunters if player has more than [30, 20, 10] Naval Units, up to 4, 1 group per 14, 11, 10
    num = ScenarioFramework.GetNumOfHumanUnits(categories.NAVAL * categories.MOBILE)
    quantity = {30, 20, 10}
    trigger = {14, 12, 10}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 4) then
            num = 4
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Seraphim', 'P2Subhunters', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P2IntNavalattack' .. Random(1, 2))
        end
    end

    -- Battleships, only on medium and high difficulty

    if Difficulty >= 2 then
        num = ScenarioFramework.GetNumOfHumanUnits(categories.NAVAL * categories.MOBILE - categories.TECH1)
        quantity = {0, 25, 20}
        if num > quantity[Difficulty] then
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Seraphim', 'P2Battleships_D' .. Difficulty, 'AttackFormation', 1 + Difficulty)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P2IntNavalattack' .. Random(1, 2))
        end
    end

    -- Basic Naval
    for i = 1, 2 do
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Seraphim', 'P2Navalattack' .. i .. '_D' .. Difficulty, 'AttackFormation', Difficulty)
        ScenarioFramework.PlatoonPatrolChain(platoon, 'P2IntNavalattack' .. i)
    end

    --Basic Land Attacks
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Seraphim', 'P2Landattack1_D' .. Difficulty, 'AttackFormation', 2 + Difficulty)
        ScenarioFramework.PlatoonPatrolChain(platoon, 'P2Intlandattack1')

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Seraphim', 'P2Landattack2_D' .. Difficulty, 'AttackFormation', 2 + Difficulty)
        ScenarioFramework.PlatoonPatrolChain(platoon, 'P2Intlandattack2')

    -- sends EXP if player has more than [3, 2, 1] EXPS, up to 4, 1 group per 3, 2, 1
    num = ScenarioFramework.GetNumOfHumanUnits(categories.EXPERIMENTAL)
    quantity = {3, 2, 1}
    trigger = {3, 2, 1}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 4) then
            num = 4
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Seraphim', 'P2Expattack', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P2Intlandattack' .. Random(1, 2))
        end
    end
end

function MidP2()

    ScenarioFramework.Dialogue(OpStrings.MidP2, nil, true)
end

function EnableOCOnACUs()
    local SACU = {}
    while true do
        for _, v in ArmyBrains[Seraphim]:GetListOfUnits(categories.xsl0301_Rambo + categories.xsl0301_AdvancedCombat, false) do
            if not ( SACU[v:GetEntityId()] or v:IsBeingBuilt() ) then
                v:SetAutoOvercharge(true)
                SACU[v:GetEntityId()] = true
            end
        end
        WaitSeconds(10)
    end
end

--Part 3

function Part3start()

    ForkThread(IntroP3)
end

function IntroP3()
    if ScenarioInfo.MissionNumber ~= 2 then
        return
    end
    ScenarioInfo.MissionNumber = 3

    WaitSeconds(8)
    
    ScenarioFramework.SetPlayableArea('AREA_3', true)
    
    P3SeraphimAI.Seraphimbase1P3AI()
    P3SeraphimAI.Seraphimbase2P3AI()
    P3SeraphimAI.Seraphimbase3P3AI()
    P3SeraphimAI.Seraphimbase4P3AI()

    local Antinukes = ArmyBrains[Seraphim2]:GetListOfUnits(categories.xsb4302, false)
    for _, v in Antinukes do
        v:GiveTacticalSiloAmmo(5)
    end

    ScenarioUtils.CreateArmyGroup('Seraphim2', 'P3Bwalls')

    ScenarioInfo.PSACU1 = ScenarioFramework.SpawnCommander('Seraphim2', 'SeraSub1', 'Gate', 'Touth-Yez', false, false,
    {'EngineeringThroughput', 'Shield', 'Overcharge'})
    ScenarioInfo.PSACU1:SetAutoOvercharge(true)
    ScenarioInfo.PSACU1:SetVeterancy(2 + Difficulty)
    ScenarioInfo.PSACU2 = ScenarioFramework.SpawnCommander('Seraphim2', 'SeraSub2', 'Gate', 'Verkhez-Thui', false, false,
    {'EngineeringThroughput', 'Shield', 'Overcharge'})
    ScenarioInfo.PSACU2:SetAutoOvercharge(true)
    ScenarioInfo.PSACU2:SetVeterancy(2 + Difficulty)
    ScenarioInfo.PSACU3 = ScenarioFramework.SpawnCommander('Seraphim2', 'SeraSub3', 'Gate', 'Thuio-Zui', false, false,
    {'EngineeringThroughput', 'Shield', 'Overcharge'})
    ScenarioInfo.PSACU3:SetAutoOvercharge(true)
    ScenarioInfo.PSACU3:SetVeterancy(2 + Difficulty)
    
    ScenarioInfo.SeraACU2 = ScenarioFramework.SpawnCommander('Seraphim2', 'SeraCom2', false, ' Lord Yuth-Azeath', false, false,
    {'RegenAura', 'AdvancedRegenAura', 'ResourceAllocation', 'ResourceAllocationAdvanced', 'DamageStabilization', 'DamageStabilizationAdvanced'})
    ScenarioInfo.SeraACU2:SetAutoOvercharge(true)
    ScenarioInfo.SeraACU2:SetVeterancy(2 + Difficulty)

    ScenarioInfo.GateP3 = ScenarioUtils.CreateArmyUnit('Seraphim2', 'GateP3')   
    
    Cinematics.EnterNISMode()
        Cinematics.SetInvincible('AREA_2')

        local VisMarker3_1 = ScenarioFramework.CreateVisibleAreaLocation(130, 'P3vision1', 0, ArmyBrains[Player1])
   
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P3Cam1'), 0)
        WaitSeconds(2)
        ScenarioFramework.Dialogue(OpStrings.IntroP3, nil, true)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P3Cam2'), 3)
        WaitSeconds(2)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P3Cam3'), 3)
        WaitSeconds(1)
        ForkThread(
            function()
                WaitSeconds(1)
                VisMarker3_1:Destroy()
                WaitSeconds(1)
                ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('P3vision1'), 150)
            end
        )
                
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P1Cam1'), 1)
        Cinematics.SetInvincible('AREA_2', true)
    Cinematics.ExitNISMode()
    
    ForkThread(nukeparty)

    ArmyBrains[Seraphim2]:GiveResource('MASS', 32000)
    ArmyBrains[Seraphim2]:GiveResource('ENERGY', 130000)
    
    ForkThread(MissionP3)
    ForkThread(P3Intattacks)
    ScenarioFramework.CreateArmyIntelTrigger(MissionP3Secondary, ArmyBrains[Player1], 'LOSNow', false, true, categories.xsl0301, true, ArmyBrains[Seraphim2]) 

    buffDef = Buffs['CheatIncome']
    buffAffects = buffDef.Affects
    buffAffects.EnergyProduction.Mult = 2
    buffAffects.MassProduction.Mult = 2

    for _, u in GetArmyBrain(Seraphim2):GetPlatoonUniquelyNamed('ArmyPool'):GetPlatoonUnits() do
        Buff.ApplyBuff(u, 'CheatIncome')
    end 

    SetupSeraP3TauntTriggers()
end

function P3Intattacks()

    local quantity = {}
    local trigger = {}
    local platoon

     -- Air attack

    -- sends swift winds if player has more than [60, 50, 40] planes, up to 10, 1 group per 14, 11, 10
    num = ScenarioFramework.GetNumOfHumanUnits(categories.AIR * categories.MOBILE)
    quantity = {60, 50, 40}
    trigger = {20, 15, 10}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 15) then
            num = 15
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Seraphim2', 'P3AirIntercept', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P3IntAirattack' .. Random(1, 4))
        end
    end

    -- sends Strat Bombers if player has more than [80, 70, 60] Structures, up to 10, 1 group per 14, 11, 10
    num = ScenarioFramework.GetNumOfHumanUnits(categories.STRUCTURE - categories.WALL)
    quantity = {110, 90, 70}
    trigger = {40, 30, 20}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 10) then
            num = 10
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Seraphim2', 'P3AirBombers', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P3IntAirattack' .. Random(1, 4))
        end
    end

    -- sends Gunships if player has more than [200, 150, 100] Structures, up to 15, 1 group per 14, 11, 10
    num = ScenarioFramework.GetNumOfHumanUnits(categories.ALLUNITS - categories.WALL)
    quantity = {200, 150, 100}
    trigger = {40, 30, 20}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 15) then
            num = 15
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Seraphim2', 'P3AirGunships', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P3IntAirattack' .. Random(1, 4))
        end
    end

    -- sends Exp bomber if player has more than [3, 2, 1] EXp, up to 3, 1 group per 3, 2, 1
    num = ScenarioFramework.GetNumOfHumanUnits(categories.EXPERIMENTAL)
    quantity = {4, 3, 2}
    trigger = {4, 3, 2}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 4) then
            num = 4
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Seraphim2', 'P3EXPBomber', 'GrowthFormation')
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P3IntAirattack' .. i)
        end
    end

    -- Basic Naval
    for i = 1, 3 do
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Seraphim2', 'P3Navalattack' .. i .. '_D' .. Difficulty, 'AttackFormation', Difficulty)
        ScenarioFramework.PlatoonPatrolChain(platoon, 'P3IntNavalattack' .. i)
    end

    -- sends Transports if player has more than [60, 50, 40] Defenses, up to 10, 1 group per 14, 11, 10
    num = ScenarioFramework.GetNumOfHumanUnits(categories.ALLUNITS * categories.TECH3 - categories.ENGINEER)
    quantity = {90, 70, 50}
    trigger = {40, 35, 30}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 6) then
            num = 6
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim2', 'P3Dropattack1_D' .. Difficulty, 'GrowthFormation')
        ScenarioFramework.PlatoonAttackWithTransports(platoon, 'P3Drop1', 'P3Drop1Attack', true)
        end
    end

    local factories = ScenarioFramework.GetListOfHumanUnits(categories.EXPERIMENTAL * categories.LAND)
    local num = table.getn(factories)

    if num > 0 then
            quantity = {4, 3, 2}
            if num > quantity[Difficulty] then
                num = quantity[Difficulty]
            end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim2', 'P3LandSnipeEXP', 'GrowthFormation')
            IssueAttack(platoon:GetPlatoonUnits(), factories[i])
            IssueAggressiveMove(platoon:GetPlatoonUnits(), ScenarioUtils.MarkerToPosition('Player1'))
        end
    end

    local AirExp = ScenarioFramework.GetListOfHumanUnits(categories.EXPERIMENTAL * categories.AIR)
    local num = table.getn(AirExp)
    if num > 0 then
            quantity = {4, 3, 2}
            if num > quantity[Difficulty] then
                num = quantity[Difficulty]
            end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim2', 'P3AirSnipeEXP', 'GrowthFormation')
            IssueAttack(platoon:GetPlatoonUnits(), AirExp[i])
            IssueAggressiveMove(platoon:GetPlatoonUnits(), ScenarioUtils.MarkerToPosition('Player1'))
        end
    end

    local NavalExp = ScenarioFramework.GetListOfHumanUnits(categories.EXPERIMENTAL * categories.NAVAL)
    local num = table.getn(NavalExp)
    if num > 0 then
            quantity = {4, 3, 2}
            if num > quantity[Difficulty] then
                num = quantity[Difficulty]
            end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim2', 'P3NavalSnipeEXP', 'GrowthFormation')
            IssueAttack(platoon:GetPlatoonUnits(), NavalExp[i])
            IssueAggressiveMove(platoon:GetPlatoonUnits(), ScenarioUtils.MarkerToPosition('Player1'))
        end
    end

    if Difficulty >= 2 then
        for i = 1, 3 do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Seraphim2', 'P3EXPattack' .. i, 'AttackFormation', Difficulty)
            ScenarioFramework.PlatoonMoveChain(platoon, 'P3IntEXPattack' .. i)
        end
    end
end

function MissionP3()
    
    ScenarioInfo.M1P3 = Objectives.Kill(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Kill the Last Seraphim Commander',                 -- title
        'This is a higher ranking Seraphim Commander, kill him before he can escape.',  -- description
        {                               -- target
            MarkUnits = true,
            ShowProgress = true,
            Units = {ScenarioInfo.SeraACU2},
        }
   )
    ScenarioInfo.M1P3:AddResultCallback(
    function(result)
        if(result) then
           ForkThread(SeraCommander2Killed)
        end
    end
   )
   
   ScenarioInfo.M2P3 = Objectives.Kill(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Destroy final Seraphim Gate',                 -- title
        'We Cant let this Seraphim warn the others',  -- description
        {                               -- target
            MarkUnits = true,
            ShowProgress = true,
            Units = {ScenarioInfo.GateP3},
        }
   )
    ScenarioInfo.M2P3:AddResultCallback(
    function(result)
        if(result) then
            ScenarioInfo.M3P3:ManualResult(true)
        end
    end
   )
   
   ScenarioInfo.M3P3 = Objectives.Timer(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Time till Quantum Wake Dissipates',                 -- title
        'The Seraphim only has to hold out a limited amount of time.',  -- description          
        {                               -- target
           Timer = (timeAttackP3[Difficulty]),
           ExpireResult = 'Failed',
           }
          )

    ScenarioInfo.M3P3:AddResultCallback(
        function(result)
            if not result then
                PlayerLose()
            end
        end
    )

    ScenarioInfo.M3Objectives = Objectives.CreateGroup('M3Objectives', PlayerWin)
    ScenarioInfo.M3Objectives:AddObjective(ScenarioInfo.M2P3)
    ScenarioInfo.M3Objectives:AddObjective(ScenarioInfo.M1P3)
    if ScenarioInfo.M1P1.Active then
        ScenarioInfo.M3Objectives:AddObjective(ScenarioInfo.M1P1)
    end
    if ScenarioInfo.M1P2.Active then
        ScenarioInfo.M3Objectives:AddObjective(ScenarioInfo.M1P2)
    end
    if ScenarioInfo.M2P2.Active then
        ScenarioInfo.M3Objectives:AddObjective(ScenarioInfo.M2P2)
    end
end

function MissionP3Secondary()

    ScenarioFramework.Dialogue(OpStrings.SecondaryP3, nil, true)

    ScenarioInfo.M1S1P3 = Objectives.Kill(
        'secondary',                      -- type
        'incomplete',                   -- complete
        'Kill the Support Commanders',                 -- title
        'There are several Support commanders helping the main Seraphim Commander, eliminate them.',  -- description
        {                               -- target
            MarkUnits = true,
            ShowProgress = true,
            Units = {ScenarioInfo.PSACU1, ScenarioInfo.PSACU2, ScenarioInfo.PSACU3},
        }
    )
    ScenarioInfo.M1S1P3:AddResultCallback(
        function(result)
            if(result) then
                ScenarioFramework.Dialogue(OpStrings.SecondaryEndP3, nil, true)
            end
        end
    )
end

function SeraCommander2Killed()

    ScenarioFramework.Dialogue(OpStrings.Death2P3, nil, true)
    ScenarioFramework.CDRDeathNISCamera(ScenarioInfo.SeraACU2, 3)
    P3KillSera2Base()  
end

function P3KillSera2Base()
    local Sera2Units = ScenarioFramework.GetCatUnitsInArea((categories.ALLUNITS), 'ACUdeath2', ArmyBrains[Seraphim2])
        for k, v in Sera2Units do
            if v and not v.Dead then
                v:Kill()
                WaitSeconds(Random(0.1, 0.3))
            end
        end
end

function nukeparty()
    local SeraNuke = ArmyBrains[Seraphim2]:GetListOfUnits(categories.xsb2305, false)
    SeraNuke[2]:GiveNukeSiloAmmo(3)
    WaitSeconds(30)
    IssueNuke({SeraNuke[2]}, ScenarioUtils.MarkerToPosition('Nuke1'))
    WaitSeconds(10)
    IssueNuke({SeraNuke[2]}, ScenarioUtils.MarkerToPosition('Nuke2'))
    local plat = ArmyBrains[Seraphim2]:MakePlatoon('', '')
        ArmyBrains[Seraphim2]:AssignUnitsToPlatoon(plat, {SeraNuke[2]}, 'Attack', 'NoFormation')
        plat:ForkAIThread(plat.NukeAI)
end

-- End functions

function PlayerWin()
    if(not ScenarioInfo.OpEnded) then
        ScenarioInfo.OpComplete = true
        KillGame()
    end
end

function KillGame()
    UnlockInput()
    ScenarioFramework.EndOperation(ScenarioInfo.OpComplete, ScenarioInfo.OpComplete, true)
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
  end
    KillGame()
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

function SetupSeraP1TauntTriggers()

    if ScenarioInfo.MissionNumber == 1 then
        SeraTM:AddEnemiesKilledTaunt('TAUNT1P1', ArmyBrains[Seraphim], categories.STRUCTURE, 15)
        SeraTM:AddUnitsKilledTaunt('TAUNT2P1', ArmyBrains[Seraphim], categories.LAND * categories.MOBILE, 50)
        SeraTM:AddUnitsKilledTaunt('TAUNT3P1', ArmyBrains[Seraphim], categories.AIR * categories.MOBILE, 60)
        return
    end
end

function SetupSeraP2TauntTriggers()

    if ScenarioInfo.MissionNumber == 2 then
        SeraTM:AddEnemiesKilledTaunt('TAUNT1P2', ArmyBrains[Seraphim], categories.STRUCTURE, 10)
        SeraTM:AddUnitsKilledTaunt('TAUNT2P2', ArmyBrains[Seraphim], categories.LAND * categories.MOBILE, 60)
        SeraTM:AddUnitsKilledTaunt('TAUNT3P2', ArmyBrains[Seraphim], categories.EXPERIMENTAL, 2)
        SeraTM:AddUnitsKilledTaunt('TAUNT4P2', ArmyBrains[Seraphim2], categories.STRUCTURE * categories.FACTORY, 6)
        return
    end
end

function SetupSeraP3TauntTriggers()

    if ScenarioInfo.MissionNumber == 3 then
        SeraTM:AddEnemiesKilledTaunt('TAUNT1P3', ArmyBrains[Seraphim2], categories.STRUCTURE, 10)
        SeraTM:AddUnitsKilledTaunt('TAUNT2P3', ArmyBrains[Seraphim2], categories.LAND * categories.MOBILE, 60)
        SeraTM:AddUnitsKilledTaunt('TAUNT3P3', ArmyBrains[Seraphim2], categories.EXPERIMENTAL, 3)
        return
    end
end
