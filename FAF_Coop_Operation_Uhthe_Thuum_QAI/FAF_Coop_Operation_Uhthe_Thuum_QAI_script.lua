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
local TauntManager = import('/lua/TauntManager.lua')

local CybranTM = TauntManager.CreateTauntManager('Cybran1TM', '/maps/FAF_Coop_Operation_Uhthe_Thuum_QAI/FAF_Coop_Operation_Uhthe_Thuum_QAI_strings.lua')

ScenarioInfo.Cybran1 = 1
ScenarioInfo.QAI = 2
ScenarioInfo.Nodes = 3
ScenarioInfo.Cybran2 = 4
ScenarioInfo.Player1 = 5
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

function OnPopulate(Scenario)
    ScenarioUtils.InitializeScenarioArmies()
	
	ScenarioFramework.SetSeraphimColor(Player1)
	
	ScenarioFramework.SetCybranNeutralColor(Cybran1)
	
	local colors = {
    ['Player2'] = {270, 270, 0}, 
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
    buffAffects.EnergyProduction.Mult = 1
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

function OnStart(Scenario)

    ScenarioFramework.SetPlayableArea('AREA_1', false)   
    
	ScenarioFramework.AddRestrictionForAllHumans(
	        categories.UEF + -- UEF faction 
			categories.AEON + -- Aeon faction
			categories.CYBRAN + -- Cybran faction
			categories.xsa0402 + -- Super bomber
			categories.xsb2401  -- Super Nuke
			)

	
	P1CybranAI.P1C1base1AI()
	P1CybranAI.P1C1base2AI()
	
	
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

function IntroP1()

    Cinematics.EnterNISMode()
	
	 local VisMarker1_1 = ScenarioFramework.CreateVisibleAreaLocation(40, 'P1Vision1', 0, ArmyBrains[Player1])
    
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P1Cam1'), 0)
	WaitSeconds(1)
	ScenarioFramework.Dialogue(OpStrings.IntroP1, nil, true)
    WaitSeconds(4)
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P1Cam2'), 3)
    WaitSeconds(1)
	
	ForkThread(
            function()
                WaitSeconds(1)
                VisMarker1_1:Destroy()
                WaitSeconds(1)
                ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('P1Vision1'), 50)
                end
                )
    
    Cinematics.ExitNISMode()

    ScenarioInfo.CoopCDR = {}
            local tblArmy = ListArmies()
            if tblArmy[ScenarioInfo.Player2] then
                ScenarioInfo.CoopCDR1 = ScenarioFramework.SpawnCommander('Player2', 'Commander', 'Warp', true, true, PlayerDeath)
            end

            WaitSeconds(1)
			
            if tblArmy[ScenarioInfo.Player3] then
                ScenarioInfo.CoopCDR2 = ScenarioFramework.SpawnCommander('Player3', 'Commander', 'Warp', true, true, PlayerDeath)
            end

            WaitSeconds(1)

            ScenarioInfo.PlayerCDR = ScenarioFramework.SpawnCommander('Player1', 'Commander', 'Warp', true, true, PlayerDeath)

            WaitSeconds(1)

            if tblArmy[ScenarioInfo.Player4] then
                ScenarioInfo.CoopCDR3 = ScenarioFramework.SpawnCommander('Player4', 'Commander', 'Warp', true, true, PlayerDeath)
            end
        
	
	ForkThread(
            function()
                WaitSeconds(4*60)
				ScenarioFramework.Dialogue(OpStrings.Reveal1P1, nil, true)
			end
		)
	
	ForkThread(MissionP1)
end

function MissionP1()
   
   ScenarioInfo.MissionNumber = 1
   
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
		if ScenarioInfo.M2P1.Active then
		
		else
	  ForkThread(IntroP2) 
	  end
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
	     if ScenarioInfo.MissionNumber == 1 then
		if ScenarioInfo.M1P1.Active then
		
		else
	  ForkThread(IntroP2) 
	  end
	  
	  else 
	  end
     end
	end
    )
	
	ForkThread(
	 function()
	 
	 WaitSeconds(180)
	 
	 ScenarioFramework.Dialogue(OpStrings.SecondaryObj1, nil, true)
	 
	ScenarioInfo.M1P1S1 = Objectives.CategoriesInArea(
        'secondary',                      -- type
        'incomplete',                   -- complete
        'Purge the Cybran city',                 -- title
        'The cybran is attempting to defend and evacuate civilians, kill them all.',  -- description
        'kill',                         -- action
        {                               -- target
            MarkUnits = true,
			FlashVisible = true,
            ShowProgress = true,
            Requirements = {
                {   
                    Area = 'C1City',
                    Category = categories.CYBRAN * categories.STRUCTURE
,
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
    end)
	
	SetupCybranM1TauntTriggers()
    
	 local M1MapExpandDelay = {45*60, 40*60, 35*60}
    ScenarioFramework.CreateTimerTrigger(IntroP2, M1MapExpandDelay[Difficulty])
	
end

function IntroP2()
    
	ScenarioFramework.Dialogue(OpStrings.IntroP2, nil, true)
	
	WaitSeconds(3)
	
	ScenarioFramework.SetPlayableArea('AREA_2', true)  

    ScenarioUtils.CreateArmyGroup('Cybran1', 'Outerthings')
	ScenarioUtils.CreateArmyGroup('Cybran1', 'P2walls')
	ScenarioUtils.CreateArmyGroup('QAI', 'QWreaks', true)
	ScenarioUtils.CreateArmyGroup('Nodes', 'Mainframe_Walls')
	ScenarioUtils.CreateArmyGroup('QAI', 'Qintunits1')
	ScenarioUtils.CreateArmyGroup('QAI', 'P2QWalls')
	ScenarioUtils.CreateArmyGroup('Nodes', 'Mainframe_Defenses')
	ScenarioUtils.CreateArmyUnit('Nodes', 'Mainframe_Unit')
	
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
	
	ScenarioInfo.P2QACU = ScenarioFramework.SpawnCommander('QAI', 'QACU', false, 'QAI', false, false,
    {'T3Engineering', 'ResourceAllocation'})
	
	ScenarioInfo.P2QACU:AddBuildRestriction(categories.urb2301 + categories.urb1302 + categories.urb1106 + categories.urb1105 + categories.urb1201)
	
	local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran1', 'P2Navalattack1', 'GrowthFormation')
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
	
	local units = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran1', 'P2Airattack1', 'AttackFormation')
    for _, v in units:GetPlatoonUnits() do
      ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P2C1intAirattack1')))
    end
	 
	end
	)

	local units = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran2', 'P2attacks1', 'AttackFormation')
    for _, v in units:GetPlatoonUnits() do
       ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P2C2intattack1')))
    end
	 
	local units = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran2', 'P2attacks2', 'AttackFormation')
    for _, v in units:GetPlatoonUnits() do
       ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P2C2intattack1')))
    end
	 
	local units = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran2', 'P2attacks3', 'AttackFormation')
    for _, v in units:GetPlatoonUnits() do
       ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P2C2intattack1')))
    end
	 
	local units = ScenarioUtils.CreateArmyGroupAsPlatoon('QAI', 'Qintunits2', 'AttackFormation')
    for _, v in units:GetPlatoonUnits() do
      ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P2QAirD1')))
    end
	 
	 local units = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran1', 'P2Airdefence1', 'AttackFormation')
    for _, v in units:GetPlatoonUnits() do
       ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P2C1B2Airdefence1')))
     end
	 
	 Cinematics.EnterNISMode()
				
		local VisMarker2_1 = ScenarioFramework.CreateVisibleAreaLocation(50,'Vision1P2', 0, ArmyBrains[Player1])
        local VisMarker2_2 = ScenarioFramework.CreateVisibleAreaLocation(50,'Vision2P2', 0, ArmyBrains[Player1])
						
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P2Cam1'), 2)
		WaitSeconds(3)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P2Cam2'), 4)
		WaitSeconds(2)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P2Cam3'), 3)
		WaitSeconds(2)
		ScenarioFramework.Dialogue(OpStrings.Intro2P2, nil, true)
		  ForkThread(
           function ()
                WaitSeconds(1)
                VisMarker2_1:Destroy()
                VisMarker2_2:Destroy()
		    end )
			

	 Cinematics.ExitNISMode()
	 
	  buffDef = Buffs['CheatIncome']
    buffAffects = buffDef.Affects
    buffAffects.EnergyProduction.Mult = 1.5
    buffAffects.MassProduction.Mult = 1.5

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
    buffAffects.MassProduction.Mult = 1.5

       for _, u in GetArmyBrain(Cybran2):GetPlatoonUniquelyNamed('ArmyPool'):GetPlatoonUnits() do
               Buff.ApplyBuff(u, 'CheatIncome')
       end
	 
	 ForkThread(MissionP2)
end
	 
function MissionP2()
	 
	if ScenarioInfo.MissionNumber == 2 or ScenarioInfo.MissionNumber == 3 then
        return
    end
    ScenarioInfo.MissionNumber = 2
	 
	 ScenarioInfo.M1P2 = Objectives.Kill(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Kill The First Cybran Commander',                 -- title
        'Eliminate the Cybran commander west of the mainframe.',  -- description
        
        {                               -- target
             MarkUnits = true,
             Units = {ScenarioInfo.P2C1ACU}
             
          }
   )
    ScenarioInfo.M1P2:AddResultCallback(
    function(result)
        if(result) then
		 if ScenarioInfo.MissionNumber == 2 then
		   if ScenarioInfo.M3P2.Active then
		   Cybran1ACUdeath()
		
		   else
		   Cybran1ACUdeath()
		
		   
		   ForkThread(IntroP3)
		   end
		else
		Cybran1ACUdeath()
		
        end
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
    'Capture QAI\'s Second Data Node',    -- title
    'The Cybrans have been locked us out of the mainframe. We need the codes from the data nodes.',  -- description
    
    {                              -- target
        MarkUnits = true,
        Units = {ScenarioInfo.Node2},
        }
    
   )
   ScenarioInfo.M3P2:AddResultCallback(
    function(result)
        if(result) then
		 if ScenarioInfo.MissionNumber == 2 then
		if ScenarioInfo.M1P2.Active then
		
		else
		ForkThread(IntroP3)
		
         end
		else 
		
		end
         end
        end
		)
	
	ForkThread(
	function()
	
	 WaitSeconds(60)
	 
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
   )
      
    SetupCybranM2TauntTriggers()
  
     local M2MapExpandDelay = {35*60, 30*60, 25*60}
    ScenarioFramework.CreateTimerTrigger(IntroP3, M2MapExpandDelay[Difficulty])
  
end

function IntroP3()

    WaitSeconds(5)
	
	ScenarioFramework.Dialogue(OpStrings.IntroP3, nil, true)
	
    ScenarioFramework.SetPlayableArea('AREA_3', true)
	
	ScenarioInfo.P3C2ACU = ScenarioFramework.SpawnCommander('Cybran2', 'C2ACU', false, 'Elite Commander Vladimir', true, Cybran2ACUdeath,
    {'T3Engineering', 'CloakingGenerator', 'MicrowaveLaserGenerator'})
	
	P3CybranAI.C2P3Base1AI()
	P3CybranAI.C2P3Base2AI()
	P3CybranAI.C2P3Base3AI()
	P2QAIAI.P3Q1base1EXD()
	
	ScenarioUtils.CreateArmyGroup('Cybran2', 'P3C2wall')
	
	ScenarioInfo.Meg2 = ScenarioUtils.CreateArmyUnit('Cybran2', 'Meg2')
	 ScenarioFramework.GroupMoveChain({ScenarioInfo.Meg2}, 'P3C2Objective2')
	
	platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran2', 'P3Attack1_D' .. Difficulty, 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'P3C2Objective2')
	
	platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran2', 'P3Attack2_D' .. Difficulty, 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'P3C2Objective2')
	
	platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran2', 'P3Attack3_D' .. Difficulty, 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'P3C2Objective2')
	
	ForkThread(
	function()
	WaitSeconds(4.5*60)
	platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran2', 'P3Attack4', 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'P3C2Objective1')
	
	ScenarioInfo.Meg1 = ScenarioUtils.CreateArmyUnit('Cybran2', 'Meg1')
	ScenarioFramework.GroupMoveChain({ScenarioInfo.Meg1}, 'P3C2Objective1')
	end
	)
	
	platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran2', 'P3Attack5', 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'P3C2Intailattack1')
	
	platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran2', 'P3Attack6', 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'P3C2Intailattack2')
	
	local units = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran2', 'P3Attack7', 'AttackFormation')
    for _, v in units:GetPlatoonUnits() do
       ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P3C2Intailattack3')))
     end
	 
	local units = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran2', 'P3B1Airunits1_D' .. Difficulty, 'AttackFormation')
    for _, v in units:GetPlatoonUnits() do
       ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P3C2B1Airdef1')))
     end
	
	local units = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran2', 'P3B2Landunits1_D' .. Difficulty, 'AttackFormation')
    for _, v in units:GetPlatoonUnits() do
       ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P3C2B2Landdefence1')))
     end
	 
	local units = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran2', 'P3B1Landunits1_D' .. Difficulty, 'AttackFormation')
    for _, v in units:GetPlatoonUnits() do
       ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P3C2B1Landdefence1')))
     end
	
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
		    end )
			

	 Cinematics.ExitNISMode()
	 
    
	buffDef = Buffs['CheatIncome']
    buffAffects = buffDef.Affects
    buffAffects.EnergyProduction.Mult = 1.5
    buffAffects.MassProduction.Mult = 1.5

       for _, u in GetArmyBrain(Cybran2):GetPlatoonUniquelyNamed('ArmyPool'):GetPlatoonUnits() do
               Buff.ApplyBuff(u, 'CheatIncome')
       end
	 
	 ForkThread(MissionP3)

end

function MissionP3()
    
	if ScenarioInfo.MissionNumber == 3 then
        return
    end
    ScenarioInfo.MissionNumber = 3
	
	ScenarioInfo.M2P2:ManualResult(true)
	
    ScenarioInfo.M1P3 = Objectives.Kill(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Kill the second Cybran commander',                 -- title
        'Eliminate the Cybran commander east of the mainframe.',  -- description
        
        {                               -- target
             MarkUnits = true,
             Units = {ScenarioInfo.P3C2ACU}
             
          }
   )
    ScenarioInfo.M1P3:AddResultCallback(
    function(result)
        if(result) then
		if ScenarioInfo.M2P3.Active then
		
		else
		PlayerWin()
		ScenarioInfo.M4P3:ManualResult(true)
            end
        end
	end
		)
	
	WaitSeconds(2)
	
	ScenarioInfo.M2P3 = Objectives.Kill(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Destroy the Megalith',                 -- title
        'The Cybran has deployed a Megalith with the same technology that stoped QAI the first time, destroy them.',  -- description
        
        {                               -- target
             MarkUnits = true,
             Units = {ScenarioInfo.Meg2}
             
          }
   )
    ScenarioInfo.M2P3:AddResultCallback(
    function(result)
        if(result) then
		if ScenarioInfo.M1P3.Active then
		
		else
		PlayerWin()
		ScenarioInfo.M4P3:ManualResult(true)
            end
        end
	end
		)
    
	ForkThread(
	function()
	WaitSeconds(4.7*60)
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
		if ScenarioInfo.M1P3.Active and ScenarioInfo.M1P3.Active then
		
		else
		PlayerWin()
		
            end
        end
	end
	   )
		
	
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
                    CompareOp = '==',
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
    
	ForkThread(
	
	function()
	
	WaitSeconds(3*60)
	
	ScenarioInfo.M1P3S1 = Objectives.CategoriesInArea(
    'secondary',                      -- type
    'incomplete',                   -- complete
    'Elimiante Enemy Experimental Artillary Unit',    -- title
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
	)
	
end

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

function PlayerDeath(deadCommander)
    if Debug then return end
    ScenarioFramework.PlayerDeath(deadCommander, OpStrings.Objectivefailed2, AssignedObjectives)
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

function Cybran1ACUdeath()
    
    ScenarioFramework.CDRDeathNISCamera(ScenarioInfo.P2C1ACU, 4)
	ScenarioFramework.Dialogue(OpStrings.Death1, nil, true)
	ScenarioFramework.Dialogue(OpStrings.React1P3, nil, true)
 
end

function Cybran2ACUdeath()

    ScenarioFramework.CDRDeathNISCamera(ScenarioInfo.P3C2ACU, 4)
	ScenarioFramework.Dialogue(OpStrings.Death2, nil, true)

end

function SetupCybranM1TauntTriggers()

    CybranTM:AddEnemiesKilledTaunt('TAUNT1P1', ArmyBrains[Cybran1], categories.STRUCTURE, 10)
    CybranTM:AddUnitsKilledTaunt('TAUNT2P1', ArmyBrains[Cybran1], categories.STRUCTURE * categories.ECONOMIC, 10)
    CybranTM:AddUnitsKilledTaunt('TAUNT3P1', ArmyBrains[Cybran1], categories.STRUCTURE * categories.FACTORY, 4)

end

function SetupCybranM2TauntTriggers()
	
	CybranTM:AddTauntingCharacter(ScenarioInfo.P2C1ACU)
	
    CybranTM:AddEnemiesKilledTaunt('TAUNT1P2', ArmyBrains[Cybran1], categories.STRUCTURE, 10)
    CybranTM:AddUnitsKilledTaunt('TAUNT2P2', ArmyBrains[Cybran1], categories.MOBILE + categories.DESTROYER, 5)
    CybranTM:AddUnitsKilledTaunt('TAUNT3P2', ArmyBrains[Cybran1], categories.STRUCTURE * categories.FACTORY, 3)
	
	CybranTM:AddEnemiesKilledTaunt('TAUNT5P2', ArmyBrains[Cybran2], categories.STRUCTURE + categories.FACTORY, 2)
    CybranTM:AddUnitsKilledTaunt('TAUNT6P2', ArmyBrains[Cybran2], categories.MOBILE + categories.TECH3, 20)
	
	CybranTM:AddDamageTaunt('TAUNT4P2', ScenarioInfo.P2C1ACU, .5)
	
	CybranTM:AddDamageTaunt('TAUNT7P2', ScenarioInfo.P2QACU, .25)

end

function DestroyUnit(Mainframe)

    Mainframe:Destroy()
	
end

