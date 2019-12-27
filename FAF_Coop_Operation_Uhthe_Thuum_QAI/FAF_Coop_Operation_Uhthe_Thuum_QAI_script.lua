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
local P1CybranAI = import('/maps/FAF_Coop_Operation_Uhthe_Thuum_QAI/CybranaiP1.lua')
local P2CybranAI = import('/maps/FAF_Coop_Operation_Uhthe_Thuum_QAI/CybranaiP2.lua')
local P3CybranAI = import('/maps/FAF_Coop_Operation_Uhthe_Thuum_QAI/CybranaiP3.lua')
local P2QAIAI = import('/maps/FAF_Coop_Operation_Uhthe_Thuum_QAI/QAIaiP2.lua')
local OpStrings = import('/maps/FAF_Coop_Operation_Uhthe_Thuum_QAI/FAF_Coop_Operation_Uhthe_Thuum_QAI_strings.lua')
local CustomFunctions = '/maps/FAF_Coop_Operation_Uhthe_Thuum_QAI/FAF_Coop_Operation_Uhthe_Thuum_QAI_CustomFunctions.lua'  
local TauntManager = import('/lua/TauntManager.lua')

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

local TimedAttackP1 = {26*60, 23*60, 20*60}

local Debug = false
local NIS1InitialDelay = 3
  
function OnPopulate(Self)
 
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
    ScenarioUtils.CreateArmyGroup('Cybran1', 'OuterDefenses')
    ScenarioUtils.CreateArmyGroup('Cybran1', 'Wreakbase1', true)
    ScenarioUtils.CreateArmyGroup('Cybran1', 'Wreakbase2')
     
    ScenarioInfo.Node1 = ScenarioUtils.CreateArmyUnit('Cybran1', 'Node1')
    ScenarioInfo.Node1:SetCustomName("QAI Data Node 1")
    ScenarioInfo.Node1:SetReclaimable(false)
    ScenarioInfo.Node1:SetCapturable(true)
    ScenarioInfo.Node1:SetCanTakeDamage(false)
    ScenarioInfo.Node1:SetCanBeKilled(false)
    ScenarioInfo.Node1:SetDoNotTarget(true)
     
    buffDef = Buffs['CheatIncome']
    buffAffects = buffDef.Affects
    buffAffects.EnergyProduction.Mult = 1.5
    buffAffects.MassProduction.Mult = 1.5

       for _, u in GetArmyBrain(QAI):GetPlatoonUniquelyNamed('ArmyPool'):GetPlatoonUnits() do
               Buff.ApplyBuff(u, 'CheatIncome')
       end
     
    buffDef = Buffs['CheatIncome']
    buffAffects = buffDef.Affects
    buffAffects.EnergyProduction.Mult = 2
    buffAffects.MassProduction.Mult = 2

       for _, u in GetArmyBrain(Cybran1):GetPlatoonUniquelyNamed('ArmyPool'):GetPlatoonUnits() do
               Buff.ApplyBuff(u, 'CheatIncome')
       end
    
    buffDef = Buffs['CheatIncome']
    buffAffects = buffDef.Affects
    buffAffects.EnergyProduction.Mult = 2
    buffAffects.MassProduction.Mult = 2

       for _, u in GetArmyBrain(Cybran2):GetPlatoonUniquelyNamed('ArmyPool'):GetPlatoonUnits() do
               Buff.ApplyBuff(u, 'CheatIncome')
       end
     
end

function OnStart(Self)

    ScenarioFramework.SetPlayableArea('AREA_2', false)   
    
    ScenarioFramework.AddRestrictionForAllHumans(
            categories.UEF + -- UEF faction 
            categories.CYBRAN + -- Cybran faction
            categories.xsa0402 + -- Super bomber
			categories.xab1401 + -- Paragon
			categories.uaa0310 + -- Exp Carrier
			categories.xab2307 + -- Salvation
            categories.xsb2401  -- Super Nuke
            )

    
    P1CybranAI.P1C1base1AI()
    P1CybranAI.P1C1base2AI()
    
	ScenarioUtils.CreateArmyGroup('Nodes', 'Mainframe_Walls')
    ScenarioUtils.CreateArmyGroup('Nodes', 'Mainframe_Defenses')
	
    ScenarioInfo.MF1 = ScenarioUtils.CreateArmyUnit('Nodes', 'Mainframe_Unit')
    ScenarioInfo.MF1:SetCanTakeDamage(false)
    ScenarioInfo.MF1:SetCanBeKilled(false)
	
	GetArmyBrain(Nodes):SetResourceSharing(false)
	GetArmyBrain(QAI):SetResourceSharing(false)
	
    ForkThread(
    function()
    WaitSeconds(TimedAttackP1[Difficulty])
    
    ScenarioFramework.Dialogue(OpStrings.MidP1, nil, true)
    
    WaitSeconds(3*60)

     local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran2', 'P1Attacks1', 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'P1C2Sattack1')
  
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran2', 'P1Attacks2', 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'P1C2Sattack2')
    
    local units = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran2', 'P1Attacks3_D' .. Difficulty, 'AttackFormation')
    for _, v in units:GetPlatoonUnits() do
       ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P1C2Sattack3')))
     end
    end
    )
    
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
	WaitSeconds(2)
	ScenarioInfo.P1QACU = ScenarioFramework.SpawnCommander('QAI', 'P1QACU', 'Warp', 'QAI', false, false)
	ScenarioInfo.P1QACU:PlayCommanderWarpInEffect()
    WaitSeconds(3)
	Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P1Cam4'), 2)
	WaitSeconds(2)
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
            if (factionIdx == 3) then
                ScenarioInfo.CoopCDR[coop] = ScenarioFramework.SpawnCommander(strArmy, 'Commander', 'Warp', true, true, PlayerDeath)
            elseif (factionIdx == 2) then
                ScenarioInfo.CoopCDR[coop] = ScenarioFramework.SpawnCommander(strArmy, 'ACommander', 'Warp', true, true, PlayerDeath)	
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
    
	buffDef = Buffs['CheatIncome']
    buffAffects = buffDef.Affects
    buffAffects.EnergyProduction.Mult = 1.5
    buffAffects.MassProduction.Mult = 1.5

       for _, u in GetArmyBrain(Cybran1):GetPlatoonUniquelyNamed('ArmyPool'):GetPlatoonUnits() do
               Buff.ApplyBuff(u, 'CheatIncome')
       end
	
    ForkThread(MissionP1)
	ForkThread(EnableStealthOnAirC1)
	ForkThread(QAIhelp)
end

function MissionP1()
   
    ScenarioInfo.M1P1 = Objectives.Capture(
     'primary',                      -- type
     'incomplete',                   -- complete
     'Capture QAIs Data Node',    -- title
     'Capturing the node will help QAI access the mainframe.',  -- description
    
    {                              -- target
        MarkUnits = true,
        ShowFaction = 'Cybran',
        Units = {ScenarioInfo.Node1},
        }
    
   )
     ScenarioInfo.M1P1:AddResultCallback(
     function(result)
        if(result) then
		if ScenarioInfo.MissionNumber == 1 then
        ForkThread(IntroP2Dialogue)	
		else
		
		end
        end
     end
     )
    
    ScenarioInfo.M2P1 = Objectives.CategoriesInArea(
    'primary',                      -- type
    'incomplete',                   -- complete
    'Destroy Cybran Forces In The Area',    -- title
    'We need to secure this area so the node is safe from counter attacks.',  -- description
    'kill',                         -- action
       {                               -- target
        MarkUnits = true,
        Requirements = {
            {   
                Area = 'AREA_1',
                Category = categories.FACTORY,
                CompareOp = '<=',
                Value = 0,
                ArmyIndex = Cybran1,
            },
        },
        Category = categories.urb0202,
       }
    )
     ScenarioInfo.M2P1:AddResultCallback(
     function(result)
        if(result) then
		ScenarioFramework.Dialogue(OpStrings.IntroP1CybranbaseDestroyed, nil, true)
        end
     end
     )
    
	ScenarioFramework.CreateArmyIntelTrigger(SecondaryMissionP1, ArmyBrains[Player1], 'LOSNow', false, true, categories.urc1301, true, ArmyBrains[Cybran1])
	
    SetupCybranM1TauntTriggers()
    
     local M1MapExpandDelay = {45*60, 40*60, 35*60}
    ScenarioFramework.CreateTimerTrigger(IntroP2Dialogue, M1MapExpandDelay[Difficulty])
    
end

function SecondaryMissionP1()
     
    ScenarioFramework.Dialogue(OpStrings.SecondaryObj1, nil, true)
     
    ScenarioInfo.M1P1S1 = Objectives.CategoriesInArea(
        'secondary',                      -- type
        'incomplete',                   -- complete
        'Purge the Cybran city',                 -- title
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

function QAIhelp()	
	
	WaitSeconds(15*60)
	
	ScenarioFramework.Dialogue(OpStrings.QAIhelp, nil, true)
	
	local units = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'P1QAIhelp_D'.. Difficulty, 'GrowthFormation')
	ScenarioFramework.PlatoonPatrolChain(units, 'P1QAIhelpmove')
 
    WaitSeconds(25)
    
	local QAIUnits = ScenarioFramework.GetCatUnitsInArea((categories.ALLUNITS), 'QAIhelp', ArmyBrains[QAI])
            for k, v in QAIUnits do
                if v and not v:IsDead() and (v:GetAIBrain() == ArmyBrains[QAI]) then
                    ScenarioFramework.GiveUnitToArmy( v, Player1 )
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
    
	if ScenarioInfo.MissionNumber == 2 or ScenarioInfo.MissionNumber == 3 then
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
    P2CybranAI.P2C1base3AI()
    P2QAIAI.P2Q1base1AI()
    P2CybranAI.P2C2base1AI()
    P2CybranAI.P2C2base2AI()
    
    ArmyBrains[Cybran1]:PBMSetCheckInterval(6)
    ArmyBrains[Cybran2]:PBMSetCheckInterval(6)
    
    ScenarioInfo.P2C1ACU = ScenarioFramework.SpawnCommander('Cybran1', 'C1ACU', false, 'Commander Corva', true, false,
    {'T3Engineering', 'CloakingGenerator', 'NaniteTorpedoTube'})
    
	ScenarioInfo.P2C1ACU:AddBuildRestriction(categories.urb2301 + categories.urb1302 + categories.urb1202 + categories.urb1103 + categories.urb1106 + categories.urb1105 + categories.urb1201)
    
    ScenarioInfo.P2QACU = ScenarioFramework.SpawnCommander('QAI', 'QACU', false, 'QAI', false, false,
    {'T3Engineering', 'ResourceAllocation'})
    
    ScenarioInfo.P2QACU:AddBuildRestriction(categories.urb2301 + categories.urb1302 + categories.urb1202 + categories.urb1103 + categories.urb1106 + categories.urb1105 + categories.urb1201)
    
    local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran1', 'P2Navalattack1_D' .. Difficulty, 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'P2C1intnavalattack1')
    
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran1', 'P2Expattack1_D' .. Difficulty, 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'P2C1intnavalattack1')
    
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran1', 'P2Landattack1', 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'P2C1Intlandattack1')
    
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran1', 'P2Landattack2', 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'P2C1Intlandattack2')
    
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran1', 'P2Landattack3', 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'P2C1Intlandattack3')
    
    ForkThread(
    function()
    
    WaitSeconds(15)
    
    local units = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran1', 'P2Airattack1_D'.. Difficulty, 'AttackFormation')
    for _, v in units:GetPlatoonUnits() do
      ScenarioFramework.GroupAttackChain({v}, 'P2C1intAirattack1')
    end
    end
    )

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
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P2Cam2'), 4)
        WaitSeconds(2)
		Cinematics.CameraTrackEntity(ScenarioInfo.P2QACU, 30, 2)
		WaitSeconds(2)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P2Cam3'), 3)
        WaitSeconds(2)
		Cinematics.CameraTrackEntity(ScenarioInfo.PlayerCDR, 30, 2)
		Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P1Cam2'), 0)
        ScenarioFramework.Dialogue(OpStrings.Intro2P2, nil, true)
          ForkThread(
           function ()
                WaitSeconds(1)
                VisMarker2_1:Destroy()
                VisMarker2_2:Destroy()
            end )
            
    Cinematics.SetInvincible('AREA_1', true) 
    Cinematics.ExitNISMode()
     
    buffDef = Buffs['CheatIncome']
    buffAffects = buffDef.Affects
    buffAffects.EnergyProduction.Mult = 1.5
    buffAffects.MassProduction.Mult = 2

       for _, u in GetArmyBrain(Cybran1):GetPlatoonUniquelyNamed('ArmyPool'):GetPlatoonUnits() do
               Buff.ApplyBuff(u, 'CheatIncome')
       end
    
    buffDef = Buffs['CheatIncome']
    buffAffects = buffDef.Affects
    buffAffects.EnergyProduction.Mult = 1.5
    buffAffects.MassProduction.Mult = 1.5

       for _, u in GetArmyBrain(QAI):GetPlatoonUniquelyNamed('ArmyPool'):GetPlatoonUnits() do
               Buff.ApplyBuff(u, 'CheatIncome')
       end
    
    buffDef = Buffs['CheatIncome']
    buffAffects = buffDef.Affects
    buffAffects.EnergyProduction.Mult = 1.5
    buffAffects.MassProduction.Mult = 2

       for _, u in GetArmyBrain(Cybran2):GetPlatoonUniquelyNamed('ArmyPool'):GetPlatoonUnits() do
               Buff.ApplyBuff(u, 'CheatIncome')
       end
     
     ForkThread(MissionP2)
	 ForkThread(Nukeparty)
	 ForkThread(EnableStealthOnAirC2)
	 ForkThread(P2COffmapattacks)
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
    function(result)
            if (not result and not ScenarioInfo.OpEnded) then
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
		ScenarioFramework.Dialogue(OpStrings.NodeCapturedP2, nil, true)
        end
     end
     )
    
	ScenarioInfo.M2Objectives = Objectives.CreateGroup('M2Objectives', Part3start)
    ScenarioInfo.M2Objectives:AddObjective(ScenarioInfo.M3P2)
    if ScenarioInfo.M1P1.Active then
        ScenarioInfo.M2Objectives:AddObjective(ScenarioInfo.M1P1)
    end
     
    ForkThread(SetupCybranM2TauntTriggers)
    ForkThread(P2Timer)
    ForkThread(P2ArtyObj)
  
end

function P2ArtyObj()

    WaitSeconds(2*60)
     
    ScenarioFramework.Dialogue(OpStrings.SecondaryObj2, nil, true)
     
    ScenarioInfo.M1P2S1 = Objectives.CategoriesInArea(
    'secondary',                      -- type
    'incomplete',                   -- complete
    'Destroy long ranged artillery',    -- title
    'The Cybran is constructing a series of heavy artillery in one of her bases.',  -- description
    'kill',                         -- action
        {                               -- target
            MarkUnits = true,
            Requirements = {
                {   
                    Area = 'P2SObj',
                    Category = categories.urb2302 + categories.url0309
,
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
    
	WaitSeconds(5*60)
	
    local M2MapExpandDelay = {40*60, 35*60, 30*60}
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

function P2COffmapattacks()
        local attackGroups = {
        'P2Offmapattack1',
        'P2Offmapattack2',
        'P2Offmapattack3',

    }
    attackGroups.num = table.getn(attackGroups)

    while ScenarioInfo.MissionNumber == 2 do
        local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran2', attackGroups[Random(1, attackGroups.num)] .. '_D' .. Difficulty, 'GrowthFormation')
        ScenarioFramework.PlatoonPatrolChain(platoon, 'P2C2Offmapattack' .. Random(1, 3))

        WaitSeconds(Random(3*60, 5*60))
    end

end

function Nukeparty()
    
	if Difficulty == 3 then
	
    local CybranNuke = ArmyBrains[Cybran1]:GetListOfUnits(categories.urb2305, false)
    WaitSeconds(7*60)
    IssueNuke({CybranNuke[1]}, ScenarioUtils.MarkerToPosition('Nuke1'))
    WaitSeconds(5*60)
    IssueNuke({CybranNuke[1]}, ScenarioUtils.MarkerToPosition('Nuke2'))
	WaitSeconds(5*60)
	IssueNuke({CybranNuke[1]}, ScenarioUtils.MarkerToPosition('Nuke3'))
	WaitSeconds(5*60)
	IssueNuke({CybranNuke[1]}, ScenarioUtils.MarkerToPosition('Nuke4'))
	WaitSeconds(5*60)
	IssueNuke({CybranNuke[1]}, ScenarioUtils.MarkerToPosition('Nuke5'))
	WaitSeconds(5*60)
	
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
	WaitSeconds(5)
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

-- Part 3

function Part3start()

    ForkThread(IntroP3)

end

function IntroP3()
    
	if ScenarioInfo.MissionNumber == 3 then
        return
    end
    ScenarioInfo.MissionNumber = 3
	
	ScenarioInfo.M4P2:ManualResult(true)  
	
    WaitSeconds(5)
    
    ScenarioFramework.Dialogue(OpStrings.IntroP3, nil, true)
    
    ScenarioFramework.SetPlayableArea('AREA_3', true)
    
    ScenarioInfo.P3C2ACU = ScenarioFramework.SpawnCommander('Cybran2', 'C2ACU', false, 'Elite Commander Vladimir', true, Cybran2ACUdeath,
    {'T3Engineering', 'CloakingGenerator', 'MicrowaveLaserGenerator'})
    
	ScenarioInfo.P3C2ACU:AddBuildRestriction(categories.urb2301 + categories.urb1302 + categories.urb1202 + categories.urb1103 + categories.urb1106 + categories.urb1105 + categories.urb1201)
	
    P3CybranAI.C2P3Base1AI()
    P3CybranAI.C2P3Base2AI()
    P3CybranAI.C2P3Base3AI()
	P2CybranAI.P2C2B1base1EXD()
    P2QAIAI.P3Q1base1EXD()
    
    ScenarioUtils.CreateArmyGroup('Cybran2', 'P3C2wall')
    
	-- Cybran Objective attacks on QAI
	
    ScenarioInfo.Meg2 = ScenarioUtils.CreateArmyUnit('Cybran2', 'Meg2')
     ScenarioFramework.GroupMoveChain({ScenarioInfo.Meg2}, 'P3C2Objective2')
    
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran2', 'P3Attack1_D' .. Difficulty, 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'P3C2Objective2Land2')
    
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran2', 'P3Attack2_D' .. Difficulty, 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'P3C2Objective2Land1')
    
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran2', 'P3Attack3_D' .. Difficulty, 'GrowthFormation')
    for _, v in platoon:GetPlatoonUnits() do
       ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P2C2B1Airpatrol1')))
    end
    
	-- Second Megalith attack
	
    ForkThread(
      function()
       WaitSeconds(6*60)
       platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran2', 'P3Attack4', 'GrowthFormation')
       ScenarioFramework.PlatoonPatrolChain(platoon, 'P3C2Objective1')
    
       ScenarioInfo.Meg1 = ScenarioUtils.CreateArmyUnit('Cybran2', 'Meg1')
       ScenarioFramework.GroupMoveChain({ScenarioInfo.Meg1}, 'P3C2Objective1')
      end
    )
    
	-- Player Targeted attacks
	
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran2', 'P3Attack5_D'.. Difficulty, 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'P3C2Intailattack1')
    
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran2', 'P3Attack6_D'.. Difficulty, 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'P3C2Intailattack2')
    
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
        
        WaitSeconds(1)
        local Nodeunits = ScenarioFramework.GetCatUnitsInArea((categories.ALLUNITS), 'AREA_3', ArmyBrains[Nodes])
            for k, v in Nodeunits do
                if v and not v:IsDead() and (v:GetAIBrain() == ArmyBrains[Nodes]) then
                    ScenarioFramework.GiveUnitToArmy( v, QAI )
                end
            end
        WaitSeconds(1)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P3Cam1'), 2)
        WaitSeconds(2)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P3Cam2'), 4)
        WaitSeconds(3)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P3Cam3'), 3)
        WaitSeconds(3)
          ForkThread(
           function ()
                WaitSeconds(1)
                VisMarker3_1:Destroy()
                VisMarker3_2:Destroy()
                VisMarker3_3:Destroy()
				ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('P3Vision1'), 70)
				ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('P3Vision2'), 85)
				ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('P3Vision3'), 60)
            end )
            

    Cinematics.ExitNISMode()
    
	-- Complete QAI ACU objective
	
    ScenarioInfo.M2P2:ManualResult(true)    
	
    -- Player Air attack, Delayed till after Cutscene	
	
	local units = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran2', 'P3Attack7_D'.. Difficulty, 'AttackFormation')
    for _, v in units:GetPlatoonUnits() do
       ScenarioFramework.GroupAttackChain({v}, 'P3C2Intailattack3')
    end
	 
    -- Cybran Eco buffs 
	 
    buffDef = Buffs['CheatIncome']
    buffAffects = buffDef.Affects
    buffAffects.EnergyProduction.Mult = 2
    buffAffects.MassProduction.Mult = 1.5

       for _, u in GetArmyBrain(Cybran2):GetPlatoonUniquelyNamed('ArmyPool'):GetPlatoonUnits() do
               Buff.ApplyBuff(u, 'CheatIncome')
       end
     
    ForkThread(MissionP3)
    ForkThread(SetupCybranM3TauntTriggers)  
    ForkThread(Nukeparty2)	
    
end

function MissionP3()
    
    ScenarioInfo.M1P3 = Objectives.Kill(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Kill the second Cybran commander',                 -- title
        'Eliminate the Cybran commander east of the mainframe.',  -- description
        
        {                               -- target
            
             Units = {ScenarioInfo.P3C2ACU}
             
          }
   )
    ScenarioInfo.M1P3:AddResultCallback(
    function(result)
        if(result) then

        end
    end
        )
    
    WaitSeconds(2)
    
    ScenarioInfo.M2P3 = Objectives.Kill(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Destroy the Megalith',                 -- title
        'The Cybran has deployed a Megalith with the same technology that stoped QAI the first time, destroy it.',  -- description
        
        {                               -- target
             MarkUnits = true,
             Units = {ScenarioInfo.Meg2}
             
          }
   )
    ScenarioInfo.M2P3:AddResultCallback(
    function(result)
        if(result) then

        end
    end
    )
    
    ScenarioInfo.M4P3 = Objectives.CategoriesInArea(
    'primary',                      -- type
    'incomplete',                   -- complete
    'Protect QAI\'s Mainframe',    -- title
    'QAI\'s central Mainframe is still vulnerable defend it.',  -- description
    'protect',                         -- action
        {                               -- target
            MarkUnits = true,
            Requirements = {
                {   
                    Area = 'P3Obj',
                    Category = categories.urc1901
,
                    CompareOp = '<=',
                    Value = 0,
                    ArmyIndex = QAI,
                },
            },
        }
    
   )
   ScenarioInfo.M4P3:AddResultCallback(
        function(result)
            if (result and not ScenarioInfo.OpEnded) then
                ScenarioFramework.Dialogue(OpStrings.Objectivefailed1, PlayerLose, true)
            end
        end
        )   
    
	ScenarioFramework.CreateArmyIntelTrigger(P3ScathisSecondary, ArmyBrains[Player1], 'LOSNow', false, true, categories.url0401, true, ArmyBrains[Cybran1])
	ForkThread(P3SecondMegalith)
	
	ScenarioInfo.M3Objectives = Objectives.CreateGroup('M3Objectives', PlayerWin)
    ScenarioInfo.M3Objectives:AddObjective(ScenarioInfo.M1P3)
    if ScenarioInfo.M1P2.Active then
        ScenarioInfo.M3Objectives:AddObjective(ScenarioInfo.M1P2)
    end
    if ScenarioInfo.M2P1.Active then
        ScenarioInfo.M3Objectives:AddObjective(ScenarioInfo.M2P1)
    end
	
end

function P3SecondMegalith()

    WaitSeconds(6.5*60)
    ScenarioInfo.M3P3 = Objectives.Kill(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Destroy the second Megalith',                 -- title
        'The Cybran has deployed Megaliths with the same technology that stoped QAI the first time, destroy them.',  -- description
        
        {                               -- target
             MarkUnits = true,
             Units = {ScenarioInfo.Meg1}
             
          }
   )
    ScenarioInfo.M3P3:AddResultCallback(
    function(result)
        if(result) then
     
        end
    end
       )
        
 
    
end

function P3ScathisSecondary()

    
    ScenarioInfo.M1P3S1 = Objectives.CategoriesInArea(
    'secondary',                      -- type
    'incomplete',                   -- complete
    'Eliminate Enemy Experimental Artillary Unit',    -- title
    'The Cybran is constructing a experimental artillary unit in a small hidden base.',  -- description
    'kill',                         -- action
        {                               -- target
            MarkUnits = true,
            Requirements = {
                {   
                    Area = 'P3SObj',
                    Category = categories.urb2302 + categories.url0309 + categories.FACTORY + categories.TECH3 * categories.ECONOMIC
,
                    CompareOp = '==',
                    Value = 0,
                    ArmyIndex = Cybran2,
                },
            },
        }
    
   )
   ScenarioInfo.M1P3S1:AddResultCallback(
    function(result)
        if(result) then

        end
    end
    )   

end

function Nukeparty2()
	
    local CybranNuke2 = ArmyBrains[Cybran2]:GetListOfUnits(categories.urb2305, false)
    WaitSeconds(7*60)
	if ScenarioInfo.M1P3.Active then
    IssueNuke({CybranNuke2[1]}, ScenarioUtils.MarkerToPosition('Nuke1'))
    WaitSeconds(5*60)
    IssueNuke({CybranNuke2[1]}, ScenarioUtils.MarkerToPosition('Nuke2'))
	WaitSeconds(5*60)
	IssueNuke({CybranNuke2[1]}, ScenarioUtils.MarkerToPosition('Nuke3'))
	WaitSeconds(5*60)
	IssueNuke({CybranNuke2[1]}, ScenarioUtils.MarkerToPosition('Nuke4'))
	WaitSeconds(5*60)
	IssueNuke({CybranNuke2[1]}, ScenarioUtils.MarkerToPosition('Nuke5'))
	WaitSeconds(5*60)
	end
end

function Cybran2ACUdeath()

    ScenarioFramework.CDRDeathNISCamera(ScenarioInfo.P3C2ACU, 4)
    ScenarioFramework.Dialogue(OpStrings.Death2, nil, true)

end

-- Misc Functions

function PlayerWin()
    if(not ScenarioInfo.OpEnded) then
        ScenarioInfo.OpComplete = true
        ScenarioInfo.M4P3:ManualResult(true)
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
        ScenarioFramework.Dialogue(OpStrings.Objectivefailed2, nil, true)
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

