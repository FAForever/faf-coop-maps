------------------------------
-- Seraphim Campaign - Mission 2
--
-- Author: Shadowlorda1
------------------------------
local Objectives = import('/lua/ScenarioFramework.lua').Objectives
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local Utilities = import('/lua/Utilities.lua')
local Cinematics = import('/lua/cinematics.lua')
local P2UEFAI = import('/maps/FAF_Coop_Operation_Tha_Atha_Aez/UEFaiP2.lua')
local P3UEFAI = import('/maps/FAF_Coop_Operation_Tha_Atha_Aez/UEFaiP3.lua')
local P3SERAAI = import('/maps/FAF_Coop_Operation_Tha_Atha_Aez/SERAaiP3.lua')
local P2SERAAI = import('/maps/FAF_Coop_Operation_Tha_Atha_Aez/SERAaiP2.lua')
local P2AEONAI = import('/maps/FAF_Coop_Operation_Tha_Atha_Aez/AEONaiP2.lua')
local Buff = import('/lua/sim/Buff.lua')
local OpStrings = import('/maps/FAF_Coop_Operation_Tha_Atha_Aez/FAF_Coop_Operation_Tha_Atha_Aez_strings.lua')
local TauntManager = import('/lua/TauntManager.lua')

local UEFTM = TauntManager.CreateTauntManager('UEF1TM', '/maps/FAF_Coop_Operation_Tha_Atha_Aez/FAF_Coop_Operation_Tha_Atha_Aez_strings.lua')

ScenarioInfo.Player1 = 1
ScenarioInfo.SeraphimAlly = 2
ScenarioInfo.UEF = 3
ScenarioInfo.Aeon = 4
ScenarioInfo.WarpComs = 5
ScenarioInfo.SeraphimAlly2 = 6
ScenarioInfo.Player2 = 7
ScenarioInfo.Player3 = 8
ScenarioInfo.Player4 = 9

local Difficulty = ScenarioInfo.Options.Difficulty

local Player1 = ScenarioInfo.Player1
local SeraphimAlly = ScenarioInfo.SeraphimAlly
local Aeon = ScenarioInfo.Aeon
local UEF = ScenarioInfo.UEF
local WarpComs = ScenarioInfo.WarpComs
local SeraphimAlly2 = ScenarioInfo.SeraphimAlly2
local Player2 = ScenarioInfo.Player2
local Player3 = ScenarioInfo.Player3
local Player4 = ScenarioInfo.Player4
local AssignedObjectives = {}

local timeAttackP2 = {12*60, 10*60, 9*60}
local timedExpandP2 = {45*60, 35*60, 30*60}
local timedExpandP4 = {45*60, 40*60, 35*60}

local Debug = false
local SkipNIS2 = false
local NIS1InitialDelay = 3

function OnPopulate(Scenario) 
    ScenarioUtils.InitializeScenarioArmies()
   
    ScenarioFramework.SetSeraphimColor(Player1)
    ScenarioFramework.SetUEFPlayerColor(UEF)
    ScenarioFramework.SetNeutralColor (WarpComs)
    ScenarioFramework.SetAeonPlayerColor (Aeon)
	ScenarioFramework.SetAeonEvilColor (SeraphimAlly2)
    local colors = {
        ['Player2'] = {270, 270, 0}, 
        ['Player3'] = {189, 116, 16}, 
        ['Player4'] = {89, 133, 39},
		['SeraphimAlly'] = {183, 101, 24}, 
    }
	local tblArmy = ListArmies()
    for army, color in colors do
        if tblArmy[ScenarioInfo[army]] then
            ScenarioFramework.SetArmyColor(ScenarioInfo[army], unpack(color))
        end
    end
	
	 GetArmyBrain(SeraphimAlly):SetResourceSharing(false)
	  GetArmyBrain(SeraphimAlly2):SetResourceSharing(false)
	
	SetArmyUnitCap(UEF, 2000)
    SetArmyUnitCap(Aeon, 2000)
    ScenarioFramework.SetSharedUnitCap(4800)
	 
    ScenarioUtils.CreateArmyGroup('Player1', 'P1Pbase1_D'.. Difficulty)
    ScenarioUtils.CreateArmyGroup('Player1', 'Pintbasewreak', true)
    ScenarioUtils.CreateArmyGroup('WarpComs', 'Gatebase1')
    ScenarioInfo.M1ObjectiveGate = ScenarioUtils.CreateArmyUnit('WarpComs', 'Gate1')

    
    local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'P1attack1_D' .. Difficulty, 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'P1intattack1')
  
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'P1attack2_D' .. Difficulty, 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'P1intattack2')
    
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'P1attack3_D'.. Difficulty, 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'P1intattack3')
  
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'P1attack4_D'.. Difficulty, 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'P1intattack4' )
	
	local units = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'P1Aattack1_D' .. Difficulty, 'AttackFormation')
    for _, v in units:GetPlatoonUnits() do
       ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P2intattack5')))
    end
   
    buffDef = Buffs['CheatIncome']
    buffAffects = buffDef.Affects
    buffAffects.EnergyProduction.Mult = 1.5
    buffAffects.MassProduction.Mult = 1.5

       for _, u in GetArmyBrain(UEF):GetPlatoonUniquelyNamed('ArmyPool'):GetPlatoonUnits() do
               Buff.ApplyBuff(u, 'CheatIncome')
       end
	   
	buffDef = Buffs['CheatIncome']
    buffAffects = buffDef.Affects
    buffAffects.EnergyProduction.Mult = 1.5
    buffAffects.MassProduction.Mult = 1.5

       for _, u in GetArmyBrain(Aeon):GetPlatoonUniquelyNamed('ArmyPool'):GetPlatoonUnits() do
               Buff.ApplyBuff(u, 'CheatIncome')
       end
	 
end 

function OnStart(Scenario)

   ScenarioFramework.AddRestrictionForAllHumans(
	        categories.UEF + -- UEF faction 
			categories.AEON + -- Aeon faction
			categories.CYBRAN + -- Cybran faction
			categories.xsa0402 + -- Super bomber
			categories.xsb2305 + -- Nuke
			categories.xsb2401  -- Super Nuke
			)
  
   
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Commanderwarp'), 0)
    
    ForkThread(IntroP1)
end

function IntroP1()
    ScenarioFramework.SetPlayableArea('AREA_1', false)
 
    Cinematics.EnterNISMode()
	
	local VisMarkerP1_1 = ScenarioFramework.CreateVisibleAreaLocation(100, 'P1Vision1', 0, ArmyBrains[Player1])
	
    WaitSeconds(1)
    ScenarioInfo.Player1CDR = ScenarioFramework.SpawnCommander('Player1', 'Commander', 'Gate', true, true, PlayerDeath)
    
	ForkThread(
        function()
            local tblArmy = ListArmies()
            if tblArmy[ScenarioInfo.Player2] then
                ScenarioInfo.Player2CDR = ScenarioFramework.SpawnCommander('Player2', 'Commander', 'Warp', true, true, PlayerDeath)
            end

            WaitSeconds(3)

            if tblArmy[ScenarioInfo.Player3] then
                ScenarioInfo.Player3CDR = ScenarioFramework.SpawnCommander('Player3', 'Commander', 'Warp', true, true, PlayerDeath)
            end

            WaitSeconds(3)

            if tblArmy[ScenarioInfo.Player4] then
                ScenarioInfo.Player4CDR = ScenarioUtils.CreateArmyUnit('Player4', 'Commander', 'Warp', true, true, PlayerDeath)
            end
        end
    )
	
    local cmd = IssueMove({ScenarioInfo.Player1CDR}, ScenarioUtils.MarkerToPosition('ComMove'))
 
    ScenarioFramework.Dialogue(OpStrings.IntroP1, nil, true)
 
    WaitSeconds(2)
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Pintattackcam1'), 2)
    WaitSeconds(1)
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Pintattackcam2'), 2)
    WaitSeconds(1)
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Pintattackcam3'), 2)
    WaitSeconds(1)

	ForkThread(
        function()
            WaitSeconds(1)
            VisMarkerP1_1:Destroy()
	    end
		)
	
    Cinematics.ExitNISMode()
   
    ForkThread(MissionP1)
	
end

function MissionP1()
  
    ScenarioInfo.M1P1 = Objectives.CategoriesInArea(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Survive UEF Assault',                 -- title
        'Kill all UEF forces attacking your position.',  -- description
        'kill',                         -- action
        {                               -- target
            MarkUnits = true,
            ShowProgress = true,
            Requirements = {
                {   
                    Area = 'AREA_1',
                    Category = categories.UEF,
                    CompareOp = '<=',
                    Value = 0,
                    ArmyIndex = UEF,
                },
            },
        }
    )
    ScenarioInfo.M1P1:AddResultCallback(
        function(result)
            if result then
                ForkThread(IntroP2)
            end
        end
    )
 
    ScenarioInfo.M2P1 = Objectives.Protect(
        'primary',                      -- type
        'incomplete',                   -- complete
        'The gate must survive',                -- title
        'Without the gate the retreat is over.', -- description
       
        {                              -- target
            MarkUnits = true,
            Units = {ScenarioInfo.M1ObjectiveGate}, 
        }
    )
    ScenarioInfo.M2P1:AddResultCallback(
        function(result)
    	    if (not result and not ScenarioInfo.OpEnded) then
                ScenarioFramework.Dialogue(OpStrings.Comsdeath, PlayerLose, true)
    	    end
        end
    )
	
	WaitSeconds(15)
	ScenarioFramework.Dialogue(OpStrings.Reveal1, nil, true)
	
end

function IntroP2()
    if not SkipNIS2 then
   
        ScenarioFramework.Dialogue(OpStrings.IntroP2, nil, true)
		
       ForkThread(
        function()
		WaitSeconds(240)
	    ScenarioFramework.Dialogue(OpStrings.MidP2, nil, true)
	    end
		)
        ScenarioInfo.M1P2 = Objectives.Timer(
            'primary',                      -- type
            'incomplete',                   -- complete
            'Prepare for second UEF assault',                 -- title
            'Rebuild your defences. Expect the next wave to be much stronger, with T3 gunships in mass',  -- description
            {                               -- target
                Timer = (timeAttackP2[Difficulty]),
                ExpireResult = 'complete',
            }
        )

        ScenarioInfo.M1P2:AddResultCallback(
            function(result)
                if result then
                    ForkThread(MissionP2)
                end
            end
        )
    else
        MissionP2()
    end
end

function MissionP2()
    ScenarioUtils.CreateArmyGroup('UEF', 'UEFForwardefences')

    local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'P2attack1_D'.. Difficulty, 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'P2intattack1')

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'P2attack2_D'.. Difficulty, 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'P2intattack2')
    
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'P2attack3_D'.. Difficulty, 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'P2intattack3')
	
	platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'P2attack4_D'.. Difficulty, 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'P2intattack4')
	
	local units = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'P2attack5_D'.. Difficulty, 'AttackFormation')
    for _, v in units:GetPlatoonUnits() do
       ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P2intattack5')))
    end

    ScenarioInfo.M3P1 = Objectives.CategoriesInArea(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Survive Second UEF Assault',                 -- title
        'Kill all UEF forces attacking your position.',  -- description
        'kill',                         -- action
        {                               -- target
            MarkUnits = true,
            ShowProgress = true,
            Requirements = {
                {   
                    Area = 'AREA_2',
                    Category = categories.MOBILE,
                    CompareOp = '<=',
                    Value = 0,
                    ArmyIndex = UEF,
                }, 
            },
        }
    )
    ScenarioInfo.M3P1:AddResultCallback(
        function(result)
            if result then
                ForkThread(IntroP3) 
            end
        end
    )
end

--Part 3

function IntroP3()
 
    ScenarioFramework.SetPlayableArea('AREA_2', true)

    P2SERAAI.SeraphimBaseAI()
    P2AEONAI.AeonBase1AI()
	P2AEONAI.AeonBase2AI()
    P2UEFAI.UEFNbaseAI()
    P2UEFAI.UEFSbaseAI()
    P2UEFAI.UEFS2baseAI()
	
    ScenarioUtils.CreateArmyGroup('WarpComs', 'Gatebase2')
    ScenarioInfo.M2ObjectiveGate = ScenarioUtils.CreateArmyUnit('WarpComs', 'Gate2')

    ScenarioInfo.SeraACU = ScenarioFramework.SpawnCommander('SeraphimAlly', 'SeraCom', false, 'Vuth-Vuthroz', false, false,
        {'AdvancedEngineering', 'DamageStabilization', 'DamageStabilizationAdvanced', 'RateOfFire'})

    local units = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'SbaseDefence1_D' .. Difficulty, 'AttackFormation')
    for _, v in units:GetPlatoonUnits() do
       ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P2UB2Defence1')))
    end

    units = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'SbaseDefence2_D' .. Difficulty, 'AttackFormation')
    for _, v in units:GetPlatoonUnits() do
       ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P2UB3Defence1')))
    end
        
    units = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'NbaseD', 'AttackFormation')
    for _, v in units:GetPlatoonUnits() do
       ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P2UB1Defence1')))
    end
   
    units = ScenarioUtils.CreateArmyGroupAsPlatoon('SeraphimAlly', 'SApatrolG2', 'AttackFormation')
    for _, v in units:GetPlatoonUnits() do
       ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P2S1B1defence1')))
    end
   
    units = ScenarioUtils.CreateArmyGroupAsPlatoon('SeraphimAlly', 'SApatrolG1', 'AttackFormation')
    for _, v in units:GetPlatoonUnits() do
       ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P2S1B1defence2')))
    end
   
    units = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'AP2attack1', 'GrowthFormation')
    for _, v in units:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolChain({v}, 'P2Aintattack1')
    end
   
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Commanderwarp'), 0)
	
	ScenarioFramework.Dialogue(OpStrings.IntroP3, nil, true)
   
    Cinematics.EnterNISMode()
   
    local VisMarker2_1 = ScenarioFramework.CreateVisibleAreaLocation(50, 'CaminfoP2_3', 0, ArmyBrains[Player1])
    local VisMarker2_2 = ScenarioFramework.CreateVisibleAreaLocation(50, 'CamnfoP2_1', 0, ArmyBrains[Player1])
    local VisMarker2_3 = ScenarioFramework.CreateVisibleAreaLocation(50, 'CamnfoP2_2', 0, ArmyBrains[Player1])
   
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('CamP2_1'), 3)
    WaitSeconds(1)
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('CamP2_2'), 3)
    WaitSeconds(1)
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('CamP2_3'), 3)
    WaitSeconds(1)
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('CamP2_4'), 3)
    WaitSeconds(2)
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('CamP2_5'), 5)
    WaitSeconds(2)
    ForkThread(
        function()
            WaitSeconds(2)
            VisMarker2_1:Destroy()
            VisMarker2_2:Destroy()
            VisMarker2_3:Destroy()
        end
    )
  
    Cinematics.ExitNISMode()
	
	ScenarioFramework.RemoveRestrictionForAllHumans(
            categories.xsb2302 + -- T2 arty
            categories.xsb2108 + -- Tac launcher
			categories.xsl0305 + -- Seraph Sniper Bot
            categories.xsl0304  -- Seraph Arty Unit
	)
	
	SetupUEFP2TauntTriggers()
	
	buffDef = Buffs['CheatIncome']
    buffAffects = buffDef.Affects
	buffAffects.EnergyProduction.Mult = 1.5
    buffAffects.MassProduction.Mult = 1.5

       for _, u in GetArmyBrain(UEF):GetPlatoonUniquelyNamed('ArmyPool'):GetPlatoonUnits() do
               Buff.ApplyBuff(u, 'CheatIncome')
       end
	  
    buffDef = Buffs['CheatIncome']
    buffAffects = buffDef.Affects	  
	buffAffects.EnergyProduction.Mult = 1.5
    buffAffects.MassProduction.Mult = 1.5

       for _, u in GetArmyBrain(Aeon):GetPlatoonUniquelyNamed('ArmyPool'):GetPlatoonUnits() do
               Buff.ApplyBuff(u, 'CheatIncome')
       end
	
	ForkThread(MissionP3)

end

function MissionP3() 
   
    ScenarioInfo.M1P2 = Objectives.CategoriesInArea(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Go On The Offensive ',                 -- title
        'Destroy all UEF forces in the area.',  -- description
        'kill',                         -- action
        {                               -- target
            MarkUnits = true,
            ShowProgress = true,
            ShowFaction = 'UEF',
            Requirements = {
                {   
                    Area = 'P2NbaseArea',
                    Category = categories.FACTORY,
                    CompareOp = '<=',
                    Value = 0,
                    ArmyIndex = UEF,
                },
                {   
                    Area = 'P2S1baseArea',
                    Category = categories.FACTORY,
                    CompareOp = '<=',
                    Value = 0,
                    ArmyIndex = UEF,
                },
                {   
                    Area = 'P2S2baseArea',
                    Category = categories.FACTORY,
                    CompareOp = '<=',
                    Value = 0,
                    ArmyIndex = UEF,
                },
            },
        }
    )
    ScenarioInfo.M1P2:AddResultCallback(
        function(result)
            if result then
			if ScenarioInfo.M3P2.Active then
		    ScenarioFramework.Dialogue(OpStrings.CompleteP3, ACU1, true)
			 ScenarioInfo.M3P2:ManualResult(true)
		else
             
			 end
            end
        end
    )
	
	ScenarioInfo.M2P2S1 = Objectives.CategoriesInArea(
        'secondary',                      -- type
        'incomplete',                   -- complete
        'Destroy Aeon support base',                -- title
        'Destroy the Aeon support base to help your ally', -- description
        'kill',
        {                              -- target
            MarkUnits = true,
            ShowProgress = true,
            ShowFaction = 'Aeon',
            Requirements = {
                {   
                    Area = 'P2AbaseSec1',
                    Category = categories.FACTORY,
                    CompareOp = '<=',
                    Value = 0,
                    ArmyIndex = Aeon,
                },
            },
		}
    )
	ScenarioInfo.M2P2S1:AddResultCallback(
        function(result)
           if result then
             ScenarioFramework.Dialogue(OpStrings.CompleteP2S, nil, true)
            end 
        end
    )
   
    ScenarioInfo.M2P2 = Objectives.Protect(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Assist Zuth when you can',                -- title
        'Zuth is defending the retreat gate help him when able.', -- description
        {                              -- target
            MarkUnits = true,
            Units = {ScenarioInfo.SeraACU, ScenarioInfo.M2ObjectiveGate} 
        }
    )
    ScenarioInfo.M2P2:AddResultCallback(
        function(result)
            if (not result and not ScenarioInfo.OpEnded) then
                ScenarioFramework.Dialogue(OpStrings.Comsdeath, PlayerLose, true)
            end
        end
    )
	
	ScenarioInfo.M3P2 = Objectives.Timer(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Complete Objectives',                 -- title
        'The retreating commanders will gate in if its safe or not, you must hurry.',  -- description
       {                               -- target
                Timer = (timedExpandP2[Difficulty]),
                ExpireResult = 'complete',
            }
   )
    ScenarioInfo.M3P2:AddResultCallback(
    function(result)
        if result then
		if ScenarioInfo.M1P2.Active then
             ScenarioFramework.Dialogue(OpStrings.CompleteP3, ACU1, true)
		else
             
			  end
           end 
    end
   )
	
	ArmyBrains[UEF]:GiveResource('MASS', 4000)
    ArmyBrains[UEF]:GiveResource('ENERGY', 6000) 
	 
	ArmyBrains[Aeon]:GiveResource('MASS', 4000)
    ArmyBrains[Aeon]:GiveResource('ENERGY', 6000)
   
end

--Part 4

function ACU1()
    
	DropReinforcements('Aeon', 'Aeon', 'Comintercept4_D' .. Difficulty, 'P2DropMk1', 'Tdeath1')
	
    ScenarioInfo.AeonACU1 = ScenarioFramework.SpawnCommander('WarpComs', 'G1U1', 'Gate', 'Havra', false, false,
        {'CrysalisBeam', 'Shield', 'ShieldHeavy'})
    ScenarioFramework.GroupMoveChain({ScenarioInfo.AeonACU1}, 'WarpComChain1')

    WaitSeconds(5)
	ForkThread(ACU2)
end

function ACU2()
    ScenarioInfo.AeonACU2 = ScenarioFramework.SpawnCommander('WarpComs', 'G1U2', 'Gate', 'Oum-Eoshi', false, false,
        {'BlastAttack', 'DamageStabilization', 'DamageStabilizationAdvanced'})
    ScenarioFramework.GroupMoveChain({ScenarioInfo.AeonACU2}, 'WarpComChain1')
	
	Cinematics.EnterNISMode()
 
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('GateCam1'), 0)
    WaitSeconds(5)

    Cinematics.ExitNISMode() 
	
    ForkThread(ACU3)
end

function ACU3() 

    ScenarioInfo.AeonACU3 = ScenarioFramework.SpawnCommander('WarpComs', 'G1U3', 'Gate', 'Zertha', false, false,
        {'Shield', 'EnhancedSensors'}) 
    ScenarioFramework.GroupMoveChain({ScenarioInfo.AeonACU3}, 'WarpComChain1')
	
    ForkThread(MissionP4)
	
end

function MissionP4()

     ScenarioInfo.M1P3 = Objectives.SpecificUnitsInArea(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Protect the retreating commanders',                -- title
        'We need every commander we can get, defend them at all costs.', -- description
        {                              -- target
            MarkUnits = true,
            Units = {ScenarioInfo.AeonACU1, ScenarioInfo.AeonACU2, ScenarioInfo.AeonACU3},
            Area = 'EvacZone',
        }
    )
   
    ScenarioInfo.M1P3:AddResultCallback(
        function(result)
            if (not result and not ScenarioInfo.OpEnded) then
                ScenarioFramework.Dialogue(OpStrings.Comsdeath, PlayerLose, true)
            end

            if result then
                ScenarioFramework.FakeTeleportUnit(ScenarioInfo.AeonACU1, true)
                ScenarioFramework.FakeTeleportUnit(ScenarioInfo.AeonACU2, true)
                ScenarioFramework.FakeTeleportUnit(ScenarioInfo.AeonACU3, true)

                ForkThread(ACU4) 
    		end
        end
    )
	
	ForkThread(Failsafe1)
	
	WaitSeconds(60)
    local units = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'UEFComintercept2_D'.. Difficulty, 'AttackFormation')
    for _, v in units:GetPlatoonUnits() do
       ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P3AirPatrol1')))
    end
	WaitSeconds(60)
	 local units = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'Comintercept1_D'.. Difficulty, 'AttackFormation')
    for _, v in units:GetPlatoonUnits() do
       ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P3AirPatrol1')))
    end

end

function Failsafe1()
    
	WaitSeconds(5*60)
    if ScenarioInfo.M1P3.Active then
		 ScenarioInfo.M1P3:ManualResult(true)
		 else
		 
    end

end

--Second batch of commanders

function ACU4()
    ScenarioInfo.AeonACU4 = ScenarioFramework.SpawnCommander('WarpComs', 'G1U4', 'Gate', 'Zorez-thooum', false, false,
        {'DamageStabilization', 'RateOfFire'})
    ScenarioFramework.GroupMoveChain({ScenarioInfo.AeonACU4}, 'WarpComChain1')

	local units = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'UEFComintercept1_D' .. Difficulty, 'GrowthFormation')
    ScenarioFramework.PlatoonMoveChain(units, 'UEFintercept2')
    WaitSeconds(5)
	
	ForkThread(ACU5) 
	
end

function ACU5()
    ScenarioInfo.AeonACU5 = ScenarioFramework.SpawnCommander('WarpComs', 'G1U5', 'Gate', 'Thuma-thooum', false, false,
        {'DamageStabilization'})
    ScenarioFramework.GroupMoveChain({ScenarioInfo.AeonACU5}, 'WarpComChain1')

	Cinematics.EnterNISMode()
 
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('GateCam1'), 0)
    WaitSeconds(5)
	
    ScenarioFramework.Dialogue(OpStrings.Taunt4, nil, true)
	
    Cinematics.ExitNISMode()
	
    ForkThread(ACU6)
end

function ACU6()
    ScenarioInfo.AeonACU6 = ScenarioFramework.SpawnCommander('WarpComs', 'G1U6', 'Gate', 'Kelean', false, false,
        {'AdvancedEngineering', 'HeatSink'})
    ScenarioFramework.GroupMoveChain({ScenarioInfo.AeonACU6}, 'WarpComChain1')

    ScenarioInfo.M3P2 = Objectives.SpecificUnitsInArea(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Protect Retreating Commanders',                -- title
        'We need every able commander, defend them at all costs.', -- description    
        {                              -- target
            MarkUnits = true,
            Units = {ScenarioInfo.AeonACU4, ScenarioInfo.AeonACU5, ScenarioInfo.AeonACU6},
            Area = 'EvacZone',
        }
    )
   
    ScenarioInfo.M3P2:AddResultCallback(
        function(result)
            if(not result and not ScenarioInfo.OpEnded) then
                ScenarioFramework.Dialogue(OpStrings.Comsdeath, PlayerLose, true)
            end

            if result then
                ScenarioFramework.FakeTeleportUnit(ScenarioInfo.AeonACU4, true)
                ScenarioFramework.FakeTeleportUnit(ScenarioInfo.AeonACU5, true)
                ScenarioFramework.FakeTeleportUnit(ScenarioInfo.AeonACU6, true)

                ForkThread(IntroP5)
            end
        end
    )
    
	ForkThread(Failsafe2)
	
	WaitSeconds(10)

	 local units = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'Comintercept2_D' .. Difficulty, 'AttackFormation')
    for _, v in units:GetPlatoonUnits() do
       ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('Aintercept2')))
    end
	
	units = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'Comintercept3_D' .. Difficulty, 'AttackFormation')
    for _, v in units:GetPlatoonUnits() do
       ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('Aintercept2')))
    end
	
	WaitSeconds(15)
	
	local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'UEFComintercept5_D'.. Difficulty, 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'UEFintercept1')

end

function Failsafe2()
    
	WaitSeconds(5*60)
    if ScenarioInfo.M3P2.Active then
		 ScenarioInfo.M3P2:ManualResult(true)
		 else
		 
    end

end

--Part 5

function IntroP5()
    ScenarioFramework.SetPlayableArea('AREA_3', true)
	
	ForkThread(nukeparty)

    P3UEFAI.UEFmain1AI()
	P3UEFAI.UEFmain2AI()
	P3UEFAI.UEFmain3AI()
	P2AEONAI.AeonBase3AI()
	P2AEONAI.P3Aattacks()
	P3SERAAI.OrderBaseAI()
	
	ArmyBrains[UEF]:PBMSetCheckInterval(8)
	ArmyBrains[Aeon]:PBMSetCheckInterval(8)
	
	ScenarioInfo.M2P2:ManualResult(true)
	
	ScenarioFramework.Dialogue(OpStrings.IntroP4, nil, true)
	
   ScenarioFramework.RemoveRestrictionForAllHumans(
            categories.xsb2302 + -- T2 arty
            categories.xsb2108 + -- Tac launcher
            categories.xsb2305 + -- Nuke launcher
            categories.xsl0305 + -- Seraph Sniper Bot
            categories.xsl0304  -- Seraph Arty Unit
        )
    
	
    ScenarioInfo.UEFACU = ScenarioFramework.SpawnCommander('UEF', 'UEFCom', false, 'Colonel Griff', true, false,
        {'T3Engineering', 'ShieldGeneratorField', 'HeavyAntiMatterCannon'})

    ScenarioInfo.AEONACU = ScenarioFramework.SpawnCommander('Aeon', 'AeonCom', false, 'Crusader Thaila', true, false,
        {'ShieldHeavy', 'CrysalisBeam', 'EnhancedSensors'})

    ScenarioUtils.CreateArmyGroup('SeraphimAlly2', 'AeonBaseWK', true)
	ScenarioUtils.CreateArmyGroup('WarpComs', 'P3CivilanbaseWrek', true)
    ScenarioUtils.CreateArmyGroup('WarpComs', 'Gatebase3')
	ScenarioUtils.CreateArmyGroup('WarpComs', 'P3CivilanUnits')
	ScenarioUtils.CreateArmyGroup('UEF', 'P3UEFwalls')
	ScenarioUtils.CreateArmyGroup('Aeon', 'P2AbaseWalls')
	ScenarioUtils.CreateArmyGroup('Aeon', 'P3AbaseWalls')
    ScenarioInfo.M3ObjectiveGate = ScenarioUtils.CreateArmyUnit('WarpComs', 'Gate3')
	ScenarioInfo.P3SU1 = ScenarioUtils.CreateArmyUnit('Player1', 'P3Cunit1')
	ScenarioInfo.P3SU2 = ScenarioUtils.CreateArmyUnit('Player1', 'P3Cunit2')
	ScenarioInfo.P3SU3 = ScenarioUtils.CreateArmyUnit('Player1', 'P3Cunit3')
	ScenarioInfo.P3SU4 = ScenarioUtils.CreateArmyUnit('Player1', 'P3Cunit4')
	ScenarioInfo.P3SU5 = ScenarioUtils.CreateArmyUnit('Player1', 'P3Cunit5')
	ScenarioInfo.P3SU6 = ScenarioUtils.CreateArmyUnit('Player1', 'P3Cunit6')
	
    ScenarioInfo.SeraACU2 = ScenarioFramework.SpawnCommander('SeraphimAlly2', 'SeraCom2', false, 'Jareth', false, false,
        {'AdvancedEngineering', 'ShieldHeavy'})
	
    local units = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'P3Uintattack2_D'.. Difficulty, 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(units, 'P3UEFattack1')
	
	units = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'P3Uintattack3_D'.. Difficulty, 'GrowthFormation')
    for _, v in units:GetPlatoonUnits() do
       ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P3UEFattack1')))
    end
	
	units = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'P3ASecUnits_D'.. Difficulty, 'GrowthFormation')
    for _, v in units:GetPlatoonUnits() do
       ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P3ASecDefence1')))
    end
    
    units = ScenarioUtils.CreateArmyGroupAsPlatoon('SeraphimAlly2', 'Defendunits', 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(units, 'P3S2B1defence2')
    
    units = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'Expattack1_D'.. Difficulty, 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(units, 'P3UIntattack1')
   
    units = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'P3Uintattack1_D'.. Difficulty, 'GrowthFormation')
    for _, v in units:GetPlatoonUnits() do
       ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P3UIntattack2')))
    end
	
	units = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'P3UDefence1_D'.. Difficulty, 'GrowthFormation')
    for _, v in units:GetPlatoonUnits() do
       ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P3UB1Defence1')))
    end
	
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Commanderwarp'), 0)
	
    Cinematics.EnterNISMode()
	
	local VisMarker2_4 = ScenarioFramework.CreateVisibleAreaLocation(50, 'CamnfoP3_1', 0, ArmyBrains[Player1])
    local VisMarker2_5 = ScenarioFramework.CreateVisibleAreaLocation(50, 'CamnfoP3_2', 0, ArmyBrains[Player1])
	local VisMarker2_6 = ScenarioFramework.CreateVisibleAreaLocation(80, 'UEFVison1', 0, ArmyBrains[Player1])
	local VisMarker2_7 = ScenarioFramework.CreateVisibleAreaLocation(80, 'UEFVison2', 0, ArmyBrains[Player1])

    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('CamP3_1'), 3)
    WaitSeconds(2)
	Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('CamP3_2'), 3)
    WaitSeconds(1)
	Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('CamP3_4'), 3)
    WaitSeconds(1)
	Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('CamP3_3'), 3)
    WaitSeconds(2)

	ForkThread(
        function()
            WaitSeconds(2)
            VisMarker2_4:Destroy()
            VisMarker2_5:Destroy()
			VisMarker2_6:Destroy()
			VisMarker2_7:Destroy()
        end
    )
		
    Cinematics.ExitNISMode() 
    
	 buffDef = Buffs['CheatIncome']
    buffAffects = buffDef.Affects
    buffAffects.EnergyProduction.Mult = 1.5
    buffAffects.MassProduction.Mult = 1.5

       for _, u in GetArmyBrain(UEF):GetPlatoonUniquelyNamed('ArmyPool'):GetPlatoonUnits() do
               Buff.ApplyBuff(u, 'CheatIncome')
       end
	   
	  buffDef = Buffs['CheatIncome']
    buffAffects = buffDef.Affects
    buffAffects.EnergyProduction.Mult = 1.5
    buffAffects.MassProduction.Mult = 1.5

       for _, u in GetArmyBrain(Aeon):GetPlatoonUniquelyNamed('ArmyPool'):GetPlatoonUnits() do
               Buff.ApplyBuff(u, 'CheatIncome')
       end
	
	ForkThread(MissionP5)
	
end

function MissionP5()

    ScenarioInfo.M1P3 = Objectives.Kill(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Kill The UEF Commander',                -- title
        'The UEF commander is between you and the third gate, destroy him.', -- description
        {                              -- target
            MarkUnits = true,
            Units = {ScenarioInfo.UEFACU}  
        }
    )
    ScenarioInfo.M1P3:AddResultCallback(
        function(result)
            if result then
                ForkThread(Cleanup)
                UEFCommanderKilled()
            end
        end
    )

	ScenarioInfo.M2P3 = Objectives.Protect(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Assist Jareth Where You Can',                -- title
        'Jareth is defending the second retreat gate help him when able.', -- description
        {                              -- target
            MarkUnits = true,
            Units = {ScenarioInfo.SeraACU2, ScenarioInfo.M3ObjectiveGate}   
        }
    )
    ScenarioInfo.M2P3:AddResultCallback(
        function(result)
            if (not result and not ScenarioInfo.OpEnded) then
                ScenarioFramework.Dialogue(OpStrings.Comsdeath, PlayerLose, true)
            end
        end
    )
    
		ScenarioInfo.M3P3 = Objectives.Timer(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Complete Objectives',                 -- title
        'The retreating commanders will gate in if its safe or not, you must hurry.',  -- description
       {                               -- target
                Timer = (timedExpandP4[Difficulty]),
                ExpireResult = 'complete',
            }
   )
    ScenarioInfo.M3P3:AddResultCallback(
    function(result)
        if result then
		if ScenarioInfo.M1P3.Active then
             ForkThread(ACU7)
			 else
			 
			 end
            end 
    end
   )
	
	ScenarioInfo.M3P3S1 = Objectives.Kill(
        'secondary',                      -- type
        'incomplete',                   -- complete
        'Kill The Aeon Commander',                -- title
        'Kill the Aeon commander if you get the chance', -- description
        {                              -- target
            MarkUnits = true,
            Units = {ScenarioInfo.AEONACU}  
        }
    )	
	ScenarioInfo.M3P3S1:AddResultCallback(
        function(result)
               if result then
			   AeonCommanderKilled()
            end
        end
    )
	
    ForkThread(
    function()
    WaitSeconds(30)	
	ScenarioFramework.Dialogue(OpStrings.IntroP4S, nil, true)
	local P3Secunits = ScenarioFramework.GetCatUnitsInArea((categories.ALLUNITS), 'P3Sobj1', ArmyBrains[WarpComs])
            for k, v in P3Secunits do
                if v and not v:IsDead() and (v:GetAIBrain() == ArmyBrains[WarpComs]) then
                    ScenarioFramework.GiveUnitToArmy( v, Player1 )
                end
            end
	
	ScenarioInfo.M3P3S2 = Objectives.SpecificUnitsInArea(
        'secondary',                      -- type
        'incomplete',                   -- complete
        'Save Seraphim Tech Team',                -- title
        'A group of seraphim civilians are traped on a small land mass, save them if you can.', -- description
        {                              -- target
            MarkUnits = true,
            Units = {ScenarioInfo.P3SU1, ScenarioInfo.P3SU2, ScenarioInfo.P3SU3, ScenarioInfo.P3SU4, ScenarioInfo.P3SU5, ScenarioInfo.P3SU6}, 
            Area = 'EvacZone',			
        }
    )	
	ScenarioInfo.M3P3S2:AddResultCallback(
        function(result)
               if result then
			   ScenarioFramework.Dialogue(OpStrings.CompleteP4S, nil, true)
			   ScenarioFramework.FakeTeleportUnit(ScenarioInfo.P3SU1, true)
			   ScenarioFramework.FakeTeleportUnit(ScenarioInfo.P3SU2, true)
			   ScenarioFramework.FakeTeleportUnit(ScenarioInfo.P3SU3, true)
			   ScenarioFramework.FakeTeleportUnit(ScenarioInfo.P3SU4, true)
			   ScenarioFramework.FakeTeleportUnit(ScenarioInfo.P3SU5, true)
			   ScenarioFramework.FakeTeleportUnit(ScenarioInfo.P3SU6, true)
            end
        end
    )
	end
	)

end

--Clearing UEF remaining factories

function Cleanup()

    ScenarioInfo.M4P1 = Objectives.CategoriesInArea(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Destroy UEF base',                -- title
        'Destroy remaining UEF factories to allow our commanders to travel through this area', -- description
        'kill',
        {                              -- target
            MarkUnits = true,
            ShowProgress = true,
            ShowFaction = 'UEF',
            Requirements = {
                {   
                    Area = 'AREA_3',
                    Category = categories.FACTORY,
                    CompareOp = '<=',
                    Value = 0,
                    ArmyIndex = UEF,
                },
            },
        }
    )
    ScenarioInfo.M4P1:AddResultCallback(
        function(result)
            if(result) then
			if ScenarioInfo.M3P3.Active then
			    ScenarioInfo.M3P3:ManualResult(true)
                ForkThread(ACU7)
				else
				
				end
            end
        end
    )
end

function UEFCommanderKilled()

    ScenarioFramework.Dialogue(OpStrings.UEFdeath1, nil, true)
    ScenarioFramework.CDRDeathNISCamera(ScenarioInfo.UEFACU, 3)
    P3UEFAI.DisableBase()
	P3UEFAI.DisableBase2()
	
end

function AeonCommanderKilled()
    
	 ScenarioFramework.Dialogue(OpStrings.CompleteP4S2, nil, true)
    ScenarioFramework.CDRDeathNISCamera(ScenarioInfo.AEONACU, 3)
    P2AEONAI.DisableABase()
	P2AEONAI.DisableABase2()

end

--Final batch of commanders

function ACU7()

    WaitSeconds(10)

    ScenarioInfo.AeonACU7 = ScenarioFramework.SpawnCommander('WarpComs', 'G1U7', 'Gate', 'Vara', false, false,
        {'ChronoDampener', 'HeatSink'})
    ScenarioFramework.GroupMoveChain({ScenarioInfo.AeonACU7}, 'WarpComChain2')
    
	ScenarioUtils.CreateArmyGroup('Aeon', 'P4Aenergy')
	
    WaitSeconds(5)
	
	ForkThread(ACU8)
	
end

function ACU8()

    ScenarioInfo.AeonACU8 = ScenarioFramework.SpawnCommander('WarpComs', 'G1U8', 'Gate', 'Unknown ACU', false, false,
        {'AdvancedEngineering','NaniteTorpedoTube','ResourceAllocation'})
    ScenarioFramework.GroupMoveChain({ScenarioInfo.AeonACU8}, 'WarpComChain2')

	 local units = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'Comintercept6_D' .. Difficulty, 'GrowthFormation')
    ScenarioFramework.PlatoonMoveChain(units, 'P4Aeonattack2')

    WaitSeconds(5)

	ForkThread(ACU9)
	
end

function ACU9()

    ScenarioInfo.AeonACU9 = ScenarioFramework.SpawnCommander('WarpComs', 'G1U9', 'Gate', 'Overlord Voth-Othum', false, false,
        {'AdvancedEngineering','ResourceAllocation'})
    ScenarioFramework.GroupMoveChain({ScenarioInfo.AeonACU9}, 'WarpComChain2')
	
	 ScenarioUtils.CreateArmyGroup('UEF', 'P4energy')
	
	 ScenarioInfo.M4P2 = Objectives.SpecificUnitsInArea(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Protect the last retreating commanders',                -- title
        'We need every able commander, defend them at all costs.', -- description    
        {                              -- target
            MarkUnits = true,
            Units = {ScenarioInfo.AeonACU7, ScenarioInfo.AeonACU8, ScenarioInfo.AeonACU9},
            Area = 'EvacZone',
        }
    )
    ScenarioInfo.M4P2:AddResultCallback(
        function(result)
            if(not result and not ScenarioInfo.OpEnded) then
                ScenarioFramework.Dialogue(OpStrings.Comsdeath, PlayerLose, true)
            end

            if result then
                ScenarioFramework.FakeTeleportUnit(ScenarioInfo.AeonACU7, true)
                ScenarioFramework.FakeTeleportUnit(ScenarioInfo.AeonACU8, true)
                ScenarioFramework.FakeTeleportUnit(ScenarioInfo.AeonACU9, true)
                ScenarioInfo.M2P1:ManualResult(true)
                 ScenarioFramework.Dialogue(OpStrings.Victory, PlayerWin, true)
				
            end
        end
    )
	
	ForkThread(Failsafe3)
	
    ScenarioFramework.Dialogue(OpStrings.IntroP5, nil, true)
	
    ScenarioInfo.M2P3:ManualResult(true)
	
	local units = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'Comintercept5_D' .. Difficulty, 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(units, 'P4Aeonattack1')
	 
    WaitSeconds(5)
	
	ScenarioInfo.M2P3:ManualResult(true)
	ScenarioFramework.FakeTeleportUnit(ScenarioInfo.SeraACU2, true)
	P3SERAAI.DisableBase1()
	
	WaitSeconds(200)
	
	DropReinforcements2('Aeon', 'Aeon', 'Comintercept7_D' .. Difficulty, 'P3DropMk1', 'Tdeath2')
	
	WaitSeconds(20)
	
	DropReinforcements3('UEF', 'UEF', 'UEFComintercept3_D' .. Difficulty, 'P4DropMk1', 'Tdeath3')
	
	units = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'UEFComintercept4_D'.. Difficulty, 'GrowthFormation')
    for _, v in units:GetPlatoonUnits() do
       ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P4UEFattack1')))
    end
	
	WaitSeconds(55)
	
	DropReinforcements4('UEF', 'UEF', 'UEFComintercept6_D' .. Difficulty, 'P4DropMk2', 'Tdeath4')
	
end

function Failsafe3()
    
	WaitSeconds(10*60)
    if ScenarioInfo.M4P2.Active then
		 ScenarioInfo.M4P2:ManualResult(true)
		 else
		 
    end

end

--Aeon Nuke function

function nukeparty()
    local AeonNuke = ArmyBrains[Aeon]:GetListOfUnits(categories.uab2305, false)
    WaitSeconds(30)
    IssueNuke({AeonNuke[1]}, ScenarioUtils.MarkerToPosition('Nuke1'))
    WaitSeconds(5)
    IssueNuke({AeonNuke[1]}, ScenarioUtils.MarkerToPosition('Nuke2'))
	WaitSeconds(5*60)
	IssueNuke({AeonNuke[1]}, ScenarioUtils.MarkerToPosition('Nuke3'))
	WaitSeconds(5*60)
	IssueNuke({AeonNuke[1]}, ScenarioUtils.MarkerToPosition('Nuke3'))
	WaitSeconds(5*60)
	IssueNuke({AeonNuke[1]}, ScenarioUtils.MarkerToPosition('Nuke3'))
	WaitSeconds(5*60)
	IssueNuke({AeonNuke[1]}, ScenarioUtils.MarkerToPosition('Nuke3'))
	WaitSeconds(5*60)
	IssueNuke({AeonNuke[1]}, ScenarioUtils.MarkerToPosition('Nuke3'))
end

--Utility functions

function PlayerWin()
    if not ScenarioInfo.OpEnded then
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
        ScenarioFramework.CDRDeathNISCamera(ScenarioInfo.Player1CDR)
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

function DropReinforcements(brain, targetBrain, units, DropLocation, TransportDestination)
    local strArmy = targetBrain
    local landUnits = {}
    local allTransports = {}

    ForkThread(
        function()
            local allUnits = ScenarioUtils.CreateArmyGroup(brain, units)

            for _, unit in allUnits do
                if EntityCategoryContains( categories.TRANSPORTATION, unit ) then
                    table.insert(allTransports, unit )
                else
                    table.insert(landUnits, unit )
                end
            end
            
            for _, transport in allTransports do
                ScenarioFramework.AttachUnitsToTransports(landUnits, {transport})
                WaitSeconds(1)
                IssueTransportUnload({transport}, ScenarioUtils.MarkerToPosition(DropLocation))
                IssueMove({transport}, ScenarioUtils.MarkerToPosition(TransportDestination))
                ScenarioFramework.CreateUnitToMarkerDistanceTrigger(DestroyUnit, transport, TransportDestination, 10)
            end

            for _, unit in landUnits do
                while (not unit:IsDead() and unit:IsUnitState('Attached')) do
                    WaitSeconds(1)
                end
                if (unit and not unit:IsDead()) then
                    --ArmyBrains[UEF]:AssignUnitsToPlatoon(platoon, {unit}, 'Attack', 'AttackFormation')
                    IssueAggressiveMove({unit}, ScenarioUtils.MarkerToPosition('P2dropattackMk1'))
                end
            end
        end
    )
end

function DropReinforcements2(brain, targetBrain, units, DropLocation, TransportDestination)
    local strArmy = targetBrain
    local landUnits = {}
    local allTransports = {}

    ForkThread(
        function()
            local allUnits = ScenarioUtils.CreateArmyGroup(brain, units)

            for _, unit in allUnits do
                if EntityCategoryContains( categories.TRANSPORTATION, unit ) then
                    table.insert(allTransports, unit )
                else
                    table.insert(landUnits, unit )
                end
            end
            
            for _, transport in allTransports do
                ScenarioFramework.AttachUnitsToTransports(landUnits, {transport})
                WaitSeconds(1)
                IssueTransportUnload({transport}, ScenarioUtils.MarkerToPosition(DropLocation))
                IssueMove({transport}, ScenarioUtils.MarkerToPosition(TransportDestination))
                ScenarioFramework.CreateUnitToMarkerDistanceTrigger(DestroyUnit, transport, TransportDestination, 10)
            end

            for _, unit in landUnits do
                while (not unit:IsDead() and unit:IsUnitState('Attached')) do
                    WaitSeconds(1)
                end
                if (unit and not unit:IsDead()) then
                    --ArmyBrains[UEF]:AssignUnitsToPlatoon(platoon, {unit}, 'Attack', 'AttackFormation')
                    IssueAggressiveMove({unit}, ScenarioUtils.MarkerToPosition('P3dropattackMk1'))
                end
            end
        end
    )
end

function DropReinforcements3(brain, targetBrain, units, DropLocation, TransportDestination)
    local strArmy = targetBrain
    local landUnits = {}
    local allTransports = {}

    ForkThread(
        function()
            local allUnits = ScenarioUtils.CreateArmyGroup(brain, units)

            for _, unit in allUnits do
                if EntityCategoryContains( categories.TRANSPORTATION, unit ) then
                    table.insert(allTransports, unit )
                else
                    table.insert(landUnits, unit )
                end
            end
            
            for _, transport in allTransports do
                ScenarioFramework.AttachUnitsToTransports(landUnits, {transport})
                WaitSeconds(1)
                IssueTransportUnload({transport}, ScenarioUtils.MarkerToPosition(DropLocation))
                IssueMove({transport}, ScenarioUtils.MarkerToPosition(TransportDestination))
                ScenarioFramework.CreateUnitToMarkerDistanceTrigger(DestroyUnit, transport, TransportDestination, 10)
            end

            for _, unit in landUnits do
                while (not unit:IsDead() and unit:IsUnitState('Attached')) do
                    WaitSeconds(1)
                end
                if (unit and not unit:IsDead()) then
                    --ArmyBrains[UEF]:AssignUnitsToPlatoon(platoon, {unit}, 'Attack', 'AttackFormation')
                    IssueAggressiveMove({unit}, ScenarioUtils.MarkerToPosition('P4DropattackMk1'))
                end
            end
        end
    )
end

function DropReinforcements4(brain, targetBrain, units, DropLocation, TransportDestination)
    local strArmy = targetBrain
    local landUnits = {}
    local allTransports = {}

    ForkThread(
        function()
            local allUnits = ScenarioUtils.CreateArmyGroup(brain, units)

            for _, unit in allUnits do
                if EntityCategoryContains( categories.TRANSPORTATION, unit ) then
                    table.insert(allTransports, unit )
                else
                    table.insert(landUnits, unit )
                end
            end
            
            for _, transport in allTransports do
                ScenarioFramework.AttachUnitsToTransports(landUnits, {transport})
                WaitSeconds(1)
                IssueTransportUnload({transport}, ScenarioUtils.MarkerToPosition(DropLocation))
                IssueMove({transport}, ScenarioUtils.MarkerToPosition(TransportDestination))
                ScenarioFramework.CreateUnitToMarkerDistanceTrigger(DestroyUnit, transport, TransportDestination, 10)
            end

            for _, unit in landUnits do
                while (not unit:IsDead() and unit:IsUnitState('Attached')) do
                    WaitSeconds(1)
                end
                if (unit and not unit:IsDead()) then
                    --ArmyBrains[UEF]:AssignUnitsToPlatoon(platoon, {unit}, 'Attack', 'AttackFormation')
                    IssueAggressiveMove({unit}, ScenarioUtils.MarkerToPosition('P4DropattackMk2'))
                end
            end
        end
    )
end

function DestroyUnit(unit)
    unit:Destroy()
end

function RemoveCommandCapFromPlatoon(platoon)
    for _, unit in platoon:GetPlatoonUnits() do
        unit:RemoveCommandCap('RULEUCC_Reclaim')
        unit:RemoveCommandCap('RULEUCC_Repair')
    end
end

function SetupUEFP2TauntTriggers()

    UEFTM:AddEnemiesKilledTaunt('Taunt3', ArmyBrains[UEF], categories.STRUCTURE, 10)
    UEFTM:AddUnitsKilledTaunt('Taunt2', ArmyBrains[UEF], categories.STRUCTURE * categories.ECONOMIC, 20)
    UEFTM:AddUnitsKilledTaunt('Taunt1', ArmyBrains[UEF], categories.STRUCTURE * categories.FACTORY, 6)

end

