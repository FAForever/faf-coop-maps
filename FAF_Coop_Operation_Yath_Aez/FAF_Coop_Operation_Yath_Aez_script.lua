------------------------------
-- Seraphim Campaign - Mission 1
--
-- Author: Shadowlorda1
------------------------------
local Buff = import('/lua/sim/Buff.lua')
local Cinematics = import('/lua/cinematics.lua')
local P1UEFAI = import('/maps/FAF_Coop_Operation_Yath_Aez/UEFaiP1.lua')
local P2UEFAI = import('/maps/FAF_Coop_Operation_Yath_Aez/UEFaiP2.lua')
local P2AeonAI = import('/maps/FAF_Coop_Operation_Yath_Aez/AeonaiP2.lua')
local P3AeonAI = import('/maps/FAF_Coop_Operation_Yath_Aez/AeonaiP3.lua')
local P2CybranAI = import('/maps/FAF_Coop_Operation_Yath_Aez/CybranaiP2.lua')
local P3CybranAI = import('/maps/FAF_Coop_Operation_Yath_Aez/CybranaiP3.lua')
local Objectives = import('/lua/ScenarioFramework.lua').Objectives
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local Utilities = import('/lua/Utilities.lua')
local OpStrings = import('/maps/FAF_Coop_Operation_Yath_Aez/FAF_Coop_Operation_Yath_Aez_strings.lua')   
local AIBuildStructures = import('/lua/ai/aibuildstructures.lua')
local TauntManager = import('/lua/TauntManager.lua')

local UEFTM = TauntManager.CreateTauntManager('UEF1TM', '/maps/FAF_Coop_Operation_Yath_Aez/FAF_Coop_Operation_Yath_Aez_strings.lua')

local Difficulty = ScenarioInfo.Options.Difficulty

ScenarioInfo.Player1 = 2
ScenarioInfo.UEF = 1
ScenarioInfo.Aeon = 4
ScenarioInfo.Cybran = 3
ScenarioInfo.Player2 = 5
ScenarioInfo.Player3 = 6
ScenarioInfo.Player4 = 7
ScenarioInfo.HumanPlayers = {ScenarioInfo.Player1, ScenarioInfo.Player2, ScenarioInfo.Player3, ScenarioInfo.Player4}

local Player1 = ScenarioInfo.Player1
local Aeon = ScenarioInfo.Aeon
local UEF = ScenarioInfo.UEF
local Cybran = ScenarioInfo.Cybran
local Player2 = ScenarioInfo.Player2
local Player3 = ScenarioInfo.Player3
local Player4 = ScenarioInfo.Player4

local Debug = false

local AssignedObjectives = {}

local NIS1InitialDelay = 3

function OnPopulate(Scenario)
    ScenarioUtils.InitializeScenarioArmies()
	
	ScenarioFramework.SetUEFPlayerColor(UEF)
	ScenarioFramework.SetSeraphimColor(Player1)
	ScenarioFramework.SetCybranPlayerColor(Cybran)
	ScenarioFramework.SetAeonPlayerColor(Aeon)
	
	 local colors = {
        
        ['Player2'] = {270, 270, 0}, 
        ['Player3'] = {189, 116, 16}, 
        ['Player4'] = {89, 133, 39},	
       }
	local tblArmy = ListArmies()
    for army, color in colors do
        if tblArmy[ScenarioInfo[army]] then
            ScenarioFramework.SetArmyColor(ScenarioInfo[army], unpack(color))
        end
    end
	
    SetArmyUnitCap(UEF, 1500)
    ScenarioFramework.SetSharedUnitCap(4800)
    
         
end
   
function OnStart(Scenario)
	 
     ScenarioFramework.AddRestrictionForAllHumans(
	        categories.UEF + -- UEF faction 
			categories.AEON + -- Aeon faction
			categories.CYBRAN + -- Cybran faction
			categories.xsl0304 + -- Seraph Arty Unit
            categories.xsl0401 + -- Seraph Exp Bot
            categories.xsa0402 + -- Seraph Exp Bomber
            categories.xsb0304 + -- Seraph Gate
            categories.xsl0301 + -- Seraph sACU
            categories.xsb2401 + -- Seraph exp Nuke
            categories.xss0302 + -- Battleships
            categories.xsb2302 + -- T3 Arty
            categories.xsb2108 + -- Tac launcher
            categories.xsb2305   -- Nuke launcher
    )
     
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Commanderwarp'), 0)
	
	 ForkThread(IntroPart1)
end
   
function IntroPart1()

    ScenarioFramework.SetPlayableArea('AREA_1', false)
   
    ScenarioUtils.CreateArmyGroup('UEF', 'ruins', true)
	ScenarioUtils.CreateArmyGroup('UEF', 'P1Arty') 
	 
	P1UEFAI.P1EastBaseAI()
	P1UEFAI.UEFM1WestBaseAI()
    P1UEFAI.P1TACBaseAI()
	
    Cinematics.EnterNISMode()
	
	WaitSeconds(1)
	
	ScenarioFramework.Dialogue(OpStrings.IntroP1, nil, true)
   
    local P1Vision1 = ScenarioFramework.CreateVisibleAreaLocation(60, ScenarioUtils.MarkerToPosition('P1Vision1'), 0, ArmyBrains[Player1])
	local P1Vision2 = ScenarioFramework.CreateVisibleAreaLocation(60, ScenarioUtils.MarkerToPosition('P1Vision2'), 0, ArmyBrains[Player1])
	   
	 Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('landbase'), 5)
	 WaitSeconds(3)
	 Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('navelbase'), 7)
	 WaitSeconds (2)
   
       ForkThread(
           function()
               WaitSeconds(1)
               P1Vision1:Destroy()
               P1Vision2:Destroy()
           end
      )
		
	Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Commanderwarp'), 4)
		  
	WaitSeconds (1)
		
	ScenarioInfo.PlayerCDR = ScenarioFramework.SpawnCommander('Player1', 'commander', 'Warp', true, true, PlayerDeath)
		
	ForkThread(
       function()
           local tblArmy = ListArmies()
           if tblArmy[ScenarioInfo.Player2] then
               ScenarioInfo.Player2CDR = ScenarioFramework.SpawnCommander('Player2', 'Commander', 'Warp', true, true, PlayerDeath)
           end

           WaitSeconds(1)

           if tblArmy[ScenarioInfo.Player3] then
               ScenarioInfo.Player3CDR = ScenarioFramework.SpawnCommander('Player3', 'Commander', 'Warp', true, true, PlayerDeath)
           end

           WaitSeconds(1)

           if tblArmy[ScenarioInfo.Player4] then
               ScenarioInfo.Player4CDR = ScenarioUtils.CreateArmyUnit('Player4', 'Commander', 'Warp', true, true, PlayerDeath)
           end
       end
   )
		
    Cinematics.ExitNISMode()	
  
    ArmyBrains[UEF]:GiveResource('MASS', 4000)
    ArmyBrains[UEF]:GiveResource('ENERGY', 6000)
	
	SetupUEFM1TauntTriggers()
	
	 buffDef = Buffs['CheatIncome']
    buffAffects = buffDef.Affects
    buffAffects.EnergyProduction.Mult = 1
    buffAffects.MassProduction.Mult = 1.5

       for _, u in GetArmyBrain(UEF):GetPlatoonUniquelyNamed('ArmyPool'):GetPlatoonUnits() do
               Buff.ApplyBuff(u, 'CheatIncome')
       end
	
    MissionP1()
	
end
   
function MissionP1()
  
    ScenarioInfo.MissionNumber = 1
  
   local timeAttackP1 = {50*60, 45*60, 40*60}  
  
    ScenarioInfo.M1P1 = Objectives.CategoriesInArea(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Destroy UEF Bases',                 -- title
        'Eliminate the UEFs bases in the area.',  -- description
        'kill',                         -- action
        {                               -- target
            MarkUnits = true,
			ShowProgress = true,
			ShowFaction = 'UEF',
            Requirements = {
                {   
                    Area = 'LandB',
                    Category = categories.FACTORY + categories.TECH3 * categories.STRUCTURE * categories.ECONOMIC + categories.TECH2 * categories.STRUCTURE * categories.ECONOMIC,
                    CompareOp = '<=',
                    Value = 0,
                    ArmyIndex = UEF,
                },
                {   
                    Area = 'NavelB',
                    Category = categories.FACTORY + categories.TECH3 * categories.STRUCTURE * categories.ECONOMIC + categories.TECH2 * categories.STRUCTURE * categories.ECONOMIC,
                    CompareOp = '<=',
                    Value = 0,
                    ArmyIndex = UEF,
                },
            },
        }
   )
    ScenarioInfo.M1P1:AddResultCallback(
    function(result)
        if(result and ScenarioInfo.M2P1.Active) then
		 ScenarioInfo.M2P1:ManualResult(true)
		 ForkThread(IntroPart2)
		 else
		  ForkThread(IntroPart2)
        end
    end
   )
   
   ScenarioInfo.M2P1 = Objectives.Timer(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Complete Objectives',                 -- title
        'The retreat is eagerly awaiting confirmation.',  -- description
       {                               -- target
                Timer = (timeAttackP1[Difficulty]),
                ExpireResult = 'failed',
            }
   )
    ScenarioInfo.M2P1:AddResultCallback(
    function(result)
         if (not result and ScenarioInfo.M1P1.Active) then
            ForkThread(IntroPart2)  
           else
		   
            end
    end
   )
   
    ForkThread(
        function()
		
		WaitSeconds(6*60)
		
		ScenarioFramework.Dialogue(OpStrings.Secondary2P1, nil, true)
   
    ScenarioInfo.M1P1S2 = Objectives.CategoriesInArea(
        'secondary',                      -- type
        'incomplete',                   -- complete
        'Build Naval Factories',                 -- title
        'Build 2 naval factories to gain a naval presence.',  -- description
        'build',                         -- action
        {                               -- target
			ShowProgress = true,
            Requirements = {
                {   
                    Area = 'AREA_1',
                    Category = categories.xsb0103,
                    CompareOp = '>=',
                    Value = 2,
                    ArmyIndex = HumanPlayers,
                }, 
            },
        }
    )
    ScenarioInfo.M1P1S2:AddResultCallback(
    function(result)
        if(result) then
         ScenarioFramework.Dialogue(OpStrings.SecondaryEnd2P1, nil, true)     
        end
    end
    )
    end
    )
   
    ForkThread(
        function()
		
		WaitSeconds(6*60)
		
		ScenarioFramework.Dialogue(OpStrings.SecondaryP1, nil, true)
		
           ScenarioInfo.M1P1s1 = Objectives.CategoriesInArea(
        'secondary',                      -- type
        'incomplete',                     -- complete
        'Destroy UEF Tactical Missile launchers',                 -- title
        'Eliminate the tactical missile lanchers and supporting factories to secure your landing zone.',  -- description
        'kill',                         -- action
        {                               -- target
            MarkUnits = true,
			ShowProgress = true,
            Requirements = {
                {   
                    Area = 'Tacbase',
                    Category = categories.TACTICALMISSILEPLATFORM + categories.FACTORY,
                    CompareOp = '==',
                    Value = 0,
                    ArmyIndex = UEF,
                },
               
            },
        }
    )
    ScenarioInfo.M1P1s1:AddResultCallback(
     function(result)
        if(result) then
        ScenarioFramework.Dialogue(OpStrings.SecondaryEndP1, nil, true)  
        end
     end
	 )
    end
    )	
  
    ForkThread(
        function()
		WaitSeconds(3*60)
		ScenarioFramework.Dialogue(OpStrings.RevealP1, nil, true)
        end
    )
	
    ForkThread(
        function()
		WaitSeconds(20*60)
		ScenarioFramework.Dialogue(OpStrings.MidP1, nil, true)
		end
	)
	
  
end
 
function IntroPart2()

    ScenarioFramework.SetPlayableArea('AREA_2', true)
    
	P2UEFAI.UEFnavalbaseAI()
    P2UEFAI.UEFmainbaseAI()
    P2CybranAI.Cybranbase1AI()
	P2CybranAI.Cybranbase2AI()
    P2AeonAI.Aeonbase1AI()
	P2AeonAI.Aeonbase2AI()
	
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

       for _, u in GetArmyBrain(Cybran):GetPlatoonUniquelyNamed('ArmyPool'):GetPlatoonUnits() do
               Buff.ApplyBuff(u, 'CheatIncome')
       end
	   
	buffDef = Buffs['CheatIncome']
    buffAffects = buffDef.Affects
    buffAffects.EnergyProduction.Mult = 1.5
    buffAffects.MassProduction.Mult = 1.5

       for _, u in GetArmyBrain(Aeon):GetPlatoonUniquelyNamed('ArmyPool'):GetPlatoonUnits() do
               Buff.ApplyBuff(u, 'CheatIncome')
       end
	
    ArmyBrains[UEF]:GiveResource('MASS', 9000)
    ArmyBrains[UEF]:GiveResource('ENERGY', 60000)
	
	ArmyBrains[Aeon]:GiveResource('MASS', 9000)
    ArmyBrains[Aeon]:GiveResource('ENERGY', 60000)
	
	ArmyBrains[Cybran]:GiveResource('MASS', 9000)
    ArmyBrains[Cybran]:GiveResource('ENERGY', 60000)
	
	ScenarioInfo.UEFACU = ScenarioFramework.SpawnCommander('UEF', 'UEFcommander', false, 'Major Fredrick', true, UEFACUdeath,
    {'T3Engineering', 'ResourceAllocation', 'Shield'}) 
	
	ScenarioUtils.CreateArmyGroup( 'UEF', 'P2Uwalls')
	ScenarioUtils.CreateArmyGroup( 'UEF', 'ruin2', true)
	ScenarioUtils.CreateArmyGroup( 'Aeon', 'P2Awalls')
	ScenarioUtils.CreateArmyGroup( 'Cybran', 'P2Cwalls')
	ScenarioUtils.CreateArmyGroup( 'Cybran', 'P2COuterD')
	
	ScenarioFramework.RemoveRestrictionForAllHumans(
	         categories.xss0302 + -- Battleships
			 categories.xsl0304 + -- Seraph Arty Unit
			 categories.xsb2108 + -- Tac launcher
			 categories.xsb2305 + --Nuke Launcher
	         categories.xsl0401  -- Seraph Exp Bot
	)
 
    SetArmyUnitCap(Cybran, 1500)
    SetArmyUnitCap(Aeon, 1500)
  
                units = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'landattack' , 'AttackFormation')
                ScenarioFramework.PlatoonPatrolChain(units, 'UintattackL' )
          			 
                units = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'P2Unavalattack1' , 'AttackFormation')
                ScenarioFramework.PlatoonPatrolChain(units, 'UintattackN' )
				
                units = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'P2Expattack1_D' .. Difficulty, 'AttackFormation')
                ScenarioFramework.PlatoonPatrolChain(units, 'UintattackL' )
				
			    units = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'P2AIntattack1' , 'AttackFormation')
                ScenarioFramework.PlatoonPatrolChain(units, 'AintattackL' )
				
				units = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'P2AIntattack2' , 'AttackFormation')
                ScenarioFramework.PlatoonPatrolChain(units, 'AintattackL' )
				
				units = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'P2AIntattack3' , 'AttackFormation')
                ScenarioFramework.PlatoonPatrolChain(units, 'AintattackL' )
				
				units = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'P2CIntattack1' , 'AttackFormation')
                ScenarioFramework.PlatoonPatrolChain(units, 'CintattackN' )
				
				units = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'P2CIntattack2' , 'AttackFormation')
                ScenarioFramework.PlatoonPatrolChain(units, 'CintattackL' )
				
				units = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'P2CIntattack3' , 'AttackFormation')
                ScenarioFramework.PlatoonPatrolChain(units, 'CintattackL' )
				
				units = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'P2CIntattack4' , 'AttackFormation')
                ScenarioFramework.PlatoonPatrolChain(units, 'CintattackL' )
				
		Cinematics.EnterNISMode()
		
		Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Commanderwarp'), 0)
		
		WaitSeconds(1)
				
		ScenarioFramework.Dialogue(OpStrings.IntroP2, nil, true)
				
		local VisMarker2_1 = ScenarioFramework.CreateVisibleAreaLocation(50,'UEFattack', 0, ArmyBrains[Player1])
        local VisMarker2_2 = ScenarioFramework.CreateVisibleAreaLocation(90,'UEFnavelattack', 0, ArmyBrains[Player1])
        local VisMarker2_3 = ScenarioFramework.CreateVisibleAreaLocation(70, 'ACattack', 0, ArmyBrains[Player1])
				
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Intattack1'), 3)
		WaitSeconds(1)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Intattack2'), 4)
		WaitSeconds(1)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Intattack3'), 4)
		WaitSeconds(1)
		
		 units = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'P2AIntattack4' , 'AttackFormation')
				 for _, v in units:GetPlatoonUnits() do
                 ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('AintattackA')))
                 end
		
		Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Intattack4'), 5)
		WaitSeconds(1)

		  ForkThread(
           function ()
                WaitSeconds(1)
                VisMarker2_1:Destroy()
                VisMarker2_2:Destroy()
                VisMarker2_3:Destroy()
		    end )
			

		Cinematics.ExitNISMode()
	
	ForkThread(Artybases)
	ForkThread(MissionP2)
    SetupUEFM2TauntTriggers()
end
 
function Artybases()
 
    AIBuildStructures.CreateBuildingTemplate( ArmyBrains[UEF], 'UEF', 'UEFArtybase1' )
    AIBuildStructures.AppendBuildingTemplate(ArmyBrains[UEF], 'UEF', 'UEFArtybase', 'UEFArtybase1')

    AIBuildStructures.CreateBuildingTemplate( ArmyBrains[Aeon], 'Aeon', 'AeonArtybase1' )
    AIBuildStructures.AppendBuildingTemplate(ArmyBrains[Aeon], 'Aeon', 'AeonArtybase', 'AeonArtybase1')
	
	AIBuildStructures.AppendBuildingTemplate( ArmyBrains[UEF], 'UEF', 'UEFArtybaseBD', 'UEFArtybase1')
    AIBuildStructures.AppendBuildingTemplate( ArmyBrains[Aeon], 'Aeon', 'AeonArtybaseBD', 'AeonArtybase1')
    
	ScenarioUtils.CreateArmyGroup( 'UEF', 'UEFArtybase')
    ScenarioUtils.CreateArmyGroup( 'Aeon', 'AeonArtybase')
	
    plat = ScenarioUtils.CreateArmyGroupAsPlatoon( 'UEF', 'UEFArtybaseENG', 'NoFormation' )
    plat.PlatoonData.MaintainBaseTemplate = 'UEFArtybase1'
    plat.PlatoonData.PatrolChain = 'P2UENG1'
    plat:ForkAIThread(ScenarioPlatoonAI.StartBaseEngineerThread)
	
	plat = ScenarioUtils.CreateArmyGroupAsPlatoon( 'Aeon', 'AeonArtybaseENG', 'NoFormation' )
    plat.PlatoonData.MaintainBaseTemplate = 'AeonArtybase1'
    plat.PlatoonData.PatrolChain = 'P2AENG1'
    plat:ForkAIThread(ScenarioPlatoonAI.StartBaseEngineerThread)
	
 end
 
function MissionP2()
    
	if ScenarioInfo.MissionNumber == 2 or ScenarioInfo.MissionNumber == 3 then
        return
    end
    ScenarioInfo.MissionNumber = 2
	
    ScenarioInfo.M2P1 = Objectives.Kill(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Kill The UEF Commander',                 -- title
        'Eliminate the UEF Commander.',  -- description
        
        {                               -- target
             MarkUnits = true,
             Units = {ScenarioInfo.UEFACU}
             
          }
   )
    ScenarioInfo.M2P1:AddResultCallback(
    function(result)
        if(result) then
		 if ScenarioInfo.MissionNumber == 2 then
		 if ScenarioInfo.M2P2.Active then  
                else
               ForkThread(IntroPart3)
		
            end
			else

			end
            end
        end
		)
		
	ScenarioInfo.M2P2 = Objectives.CategoriesInArea(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Destroy Enemy Bases',                 -- title
        'Eliminate the Aeon and Cybran bases in the area',  --description
        'kill',                         -- action
        {                               -- target
            MarkUnits = true,
			ShowProgress = true,
            Requirements = {
                {   
                    Area = 'Abase1area',
                    Category = categories.FACTORY + categories.TECH3 * categories.STRUCTURE * categories.ECONOMIC + categories.TECH2 * categories.STRUCTURE * categories.ECONOMIC,
                    CompareOp = '<=',
                    Value = 0,
                    ArmyIndex = Aeon,
                },
				{
                   Area = 'Cbase1area',
                    Category = categories.FACTORY + categories.TECH3 * categories.STRUCTURE * categories.ECONOMIC + categories.TECH2 * categories.STRUCTURE * categories.ECONOMIC,
                    CompareOp = '<=',
                    Value = 0,
                    ArmyIndex = Cybran,
                
            },
        },
		}
    )
    ScenarioInfo.M2P2:AddResultCallback(
    function(result)
        if(result) then
		 if ScenarioInfo.MissionNumber == 2 then
		  if ScenarioInfo.M2P1.Active then
                   
                else
                ForkThread(IntroPart3)
		
            end
		else
		end
        end
	end
	)
    
	ForkThread(
	function()
	
	WaitSeconds(20)
	
	ScenarioFramework.Dialogue(OpStrings.Secondary1P2, nil, true)
	
     ScenarioInfo.M1P2S1 = Objectives.CategoriesInArea(
        'secondary',                      -- type
        'incomplete',                     -- complete
        'Destroy the Artillery ',         -- title
        'Eliminate the Artillery Positions',  -- description
        'kill',                         -- action
        {                               -- target
            MarkUnits = true,
			ShowProgress = true,
            Requirements = {
                        { Area='Arty1', Category = categories.uel0309 + categories.ueb2302,
                          CompareOp = '==', Value = 0, ArmyIndex = UEF },
                        { Area='Arty2', Category = categories.ual0309 + categories.uab2302,
                          CompareOp = '==', Value = 0, ArmyIndex = Aeon },
                    },
                    Category = categories.ueb2302,  --forces icon
            }
		  
        )
		
    ScenarioInfo.M1P2S1:AddResultCallback(
    function(result)
        if(result) then
		ScenarioFramework.Dialogue(OpStrings.SecondaryEnd1P2, nil, true) 
        end
	end
	)
	end
	)
  
    ForkThread(
	function()
	
	WaitSeconds(9*60)
	
	ScenarioFramework.Dialogue(OpStrings.Secondary2P2, nil, true)
	
    ScenarioInfo.M2P2S2 = Objectives.CategoriesInArea(
        'secondary',                      -- type
        'incomplete',                   -- complete
        'Destroy Support Bases',                 -- title
        'Eliminate the Aeon and Cybran support bases',  --description
        'kill',                         -- action
        {                               -- target
            MarkUnits = true,
			ShowProgress = true,
            Requirements = {
                {   
                    Area = 'P2Sec1',
                    Category = categories.FACTORY + categories.TECH3 * categories.STRUCTURE * categories.ECONOMIC + categories.TECH2 * categories.STRUCTURE * categories.ECONOMIC,
                    CompareOp = '==',
                    Value = 0,
                    ArmyIndex = Cybran,
                },
				{
                   Area = 'P2Sec2',
                    Category = categories.FACTORY + categories.TECH3 * categories.STRUCTURE * categories.ECONOMIC + categories.TECH2 * categories.STRUCTURE * categories.ECONOMIC,
                    CompareOp = '==',
                    Value = 0,
                    ArmyIndex = Aeon,
                
            },
        },
		}
   )
    ScenarioInfo.M2P2:AddResultCallback(
    function(result)
        if(result) then
        ScenarioFramework.Dialogue(OpStrings.SecondaryEnd2P2, nil, true)
		end
    end
	)
    end
	)
	
	
	ForkThread(
	function()
	WaitSeconds(14*60)
	ScenarioFramework.Dialogue(OpStrings.MidP2, nil, true)
	end
	)
	
	local M2MapExpandDelay = {40*60, 35*60, 30*60}
    ScenarioFramework.CreateTimerTrigger(IntroPart3, M2MapExpandDelay[Difficulty])
	
end

function UEFACUdeath()
    
    ScenarioFramework.CDRDeathNISCamera(ScenarioInfo.UEFACU, 3)
    ScenarioFramework.Dialogue(OpStrings.ACUDeath1, nil, true)
	
end

function IntroPart3()
    
	WaitSeconds(10)
	
    ScenarioFramework.SetPlayableArea('AREA_3', true)
    
	P3AeonAI.AeonP3base1AI()
	P3CybranAI.CybranP3base1AI()
	
	ScenarioUtils.CreateArmyGroup('Aeon', 'P3AextraB_D' .. Difficulty)
	ScenarioUtils.CreateArmyGroup('Cybran', 'P3Cwalls')
	ScenarioUtils.CreateArmyGroup('UEF', 'P3UPower')
	
	ScenarioInfo.Jammer = ScenarioUtils.CreateArmyUnit('Aeon', 'Jammer1')
	 ScenarioInfo.Jammer:SetCustomName("Quantum Jammer")
     ScenarioInfo.Jammer:SetReclaimable(false)
     ScenarioInfo.Jammer:SetCapturable(false)
     ScenarioInfo.Jammer:SetCanTakeDamage(true)
     ScenarioInfo.Jammer:SetCanBeKilled(true)
	
	ScenarioInfo.ASACU = ScenarioFramework.SpawnCommander('Aeon', 'ASACU', false, 'Sivila', false, false,
    {'EngineeringFocusingModule', 'StabilitySuppressant', 'ShieldHeavy'}) 
	
	 local units = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'P3AIntDefense' , 'AttackFormation')
				 for _, v in units:GetPlatoonUnits() do
                 ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P3AAirdefence1')))
                 end
	
	Cinematics.EnterNISMode()	
						
    ScenarioFramework.Dialogue(OpStrings.IntroP3, nil, true)
 						
		local VisMarker3_1 = ScenarioFramework.CreateVisibleAreaLocation(45,'P3Vision1', 0, ArmyBrains[Player1])
        local VisMarker3_2 = ScenarioFramework.CreateVisibleAreaLocation(75,'P3Vision2', 0, ArmyBrains[Player1])
				
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P3Cam1'), 2)
		WaitSeconds(3)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P3Cam2'), 4)
		WaitSeconds(3)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Commanderwarp'), 4)
		WaitSeconds(1)

		  ForkThread(
           function ()
                WaitSeconds(1)
                VisMarker3_1:Destroy()
                VisMarker3_2:Destroy()
		    end )
			

		Cinematics.ExitNISMode()
	
     units = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'P3AIntattack1' , 'AttackFormation')
				 for _, v in units:GetPlatoonUnits() do
                 ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('AintattackA')))
                 end
	
	ForkThread(function()
			local destination = ScenarioUtils.MarkerToPosition('P3MKdrop1')

			local transports = ScenarioUtils.CreateArmyGroup('Cybran', 'P3CIntattacktrans1_D' .. Difficulty)
			local units = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'P3CIntattack1_D' .. Difficulty, 'AttackFormation')

			import('/lua/ai/aiutilities.lua').UseTransports(units:GetPlatoonUnits(), transports, destination)
            WaitSeconds(12)
			for _, transport in transports do
				ScenarioFramework.CreateUnitToMarkerDistanceTrigger(DestroyUnit, transport,  ScenarioUtils.MarkerToPosition('DeleteMK'), 15)

				IssueTransportUnload({transport}, destination)
				IssueMove({transport}, ScenarioUtils.MarkerToPosition('DeleteMK'))
			end
		
			ScenarioFramework.PlatoonPatrolChain(units, 'P3CLandingchainA1')
		end)
		
	ForkThread(function()
			local destination = ScenarioUtils.MarkerToPosition('P3MKdrop2')

			local transports = ScenarioUtils.CreateArmyGroup('Cybran', 'P3CIntattacktrans2_D' .. Difficulty)
			local units = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'P3CIntattack2_D' .. Difficulty, 'AttackFormation')

			import('/lua/ai/aiutilities.lua').UseTransports(units:GetPlatoonUnits(), transports, destination)
            WaitSeconds(12)
			for _, transport in transports do
				ScenarioFramework.CreateUnitToMarkerDistanceTrigger(DestroyUnit, transport,  ScenarioUtils.MarkerToPosition('DeleteMK'), 15)

				IssueTransportUnload({transport}, destination)
				IssueMove({transport}, ScenarioUtils.MarkerToPosition('DeleteMK'))
			end
		
			ScenarioFramework.PlatoonPatrolChain(units, 'P3CLandingchainA2')
		end)
		
	ForkThread(function()
			local destination = ScenarioUtils.MarkerToPosition('P3MKdrop3')

			local transports = ScenarioUtils.CreateArmyGroup('Cybran', 'P3CIntattacktrans3_D' .. Difficulty)
			local units = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'P3CIntattack3_D' .. Difficulty, 'AttackFormation')

			import('/lua/ai/aiutilities.lua').UseTransports(units:GetPlatoonUnits(), transports, destination)
            WaitSeconds(12)
			for _, transport in transports do
				ScenarioFramework.CreateUnitToMarkerDistanceTrigger(DestroyUnit, transport,  ScenarioUtils.MarkerToPosition('DeleteMK'), 15)

				IssueTransportUnload({transport}, destination)
				IssueMove({transport}, ScenarioUtils.MarkerToPosition('DeleteMK'))
			end
		
			ScenarioFramework.PlatoonPatrolChain(units, 'P3CLandingchainA3')
		end)
	
	buffDef = Buffs['CheatIncome']
    buffAffects = buffDef.Affects
    buffAffects.EnergyProduction.Mult = 1.5
    buffAffects.MassProduction.Mult = 2.0

       for _, u in GetArmyBrain(Cybran):GetPlatoonUniquelyNamed('ArmyPool'):GetPlatoonUnits() do
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
	ForkThread(P3COffmapattacks)
	ForkThread(P3AOffmapattacks)
	ForkThread(P3UOffmapattacks)

end

function MissionP3()
    
	if ScenarioInfo.MissionNumber == 3 then
        return
    end
    ScenarioInfo.MissionNumber = 3
	
    ScenarioInfo.M1P3 = Objectives.Kill(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Destroy the Quantum Jammer',                 -- title
        'We can not begin the process to gate you out without the jammer being destroyed.',  -- description
        
        {                               -- target
             MarkUnits = true,
             Units = {ScenarioInfo.Jammer}
             
          }
    )
   
    ScenarioInfo.M1P3:AddResultCallback(
    function(result)
        if(result) then
		PlayerWin()
            end
        end
		)
    
	ScenarioInfo.M1P3S1 = Objectives.CategoriesInArea(
        'secondary',                      -- type
        'incomplete',                   -- complete
        'Destroy Cybran Base',                 -- title
        'The Cybran base is supporting the Jammers defenses, destroy it',  --description
        'kill',                         -- action
        {                               -- target
            MarkUnits = true,
			ShowProgress = true,
            Requirements = {
                {   
                    Area = 'P3Secondary1',
                    Category = categories.FACTORY + categories.TECH3 * categories.STRUCTURE * categories.ECONOMIC + categories.TECH2 * categories.STRUCTURE * categories.ECONOMIC,
                    CompareOp = '<=',
                    Value = 0,
                    ArmyIndex = Cybran,
                },		
        },
		}
    )
    ScenarioInfo.M1P3S1:AddResultCallback(
    function(result)
        if(result) then
		 ScenarioFramework.Dialogue(OpStrings.SecondaryEnd1P3, nil, true)
        end
	end
	)
	
	ScenarioInfo.M1P3S2 = Objectives.Kill(
        'secondary',                      -- type
        'incomplete',                   -- complete
        'Kill Aeon Support Commander',                 -- title
        'The Support commander is defending the Jammer kill her, if shes in the way.',  --description
        {                               -- target
             MarkUnits = true,
             Units = {ScenarioInfo.ASACU}
             
          }
    )
    ScenarioInfo.M1P3S2:AddResultCallback(
    function(result)
        if(result) then

        end
	end
	)

end

function P3COffmapattacks()
        local attackGroups = {
        'P3Coffmap1',
        'P3Coffmap2',
        'P3Coffmap3',
        'P3Coffmap4',
    }
    attackGroups.num = table.getn(attackGroups)

    while not ScenarioInfo.OpEnded do
        local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', attackGroups[Random(1, attackGroups.num)] .. '_D' .. Difficulty, 'GrowthFormation')
        ScenarioFramework.PlatoonPatrolChain(platoon, 'P3COffmapattack' .. Random(1, 3))

        WaitSeconds(Random(100, 130))
    end

end

function P3AOffmapattacks()
        local attackGroups = {
        'P3Aoffmap1',
        'P3Aoffmap2',
        'P3Aoffmap3',
        'P3Aoffmap4',
    }
    attackGroups.num = table.getn(attackGroups)

    while not ScenarioInfo.OpEnded do
        local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', attackGroups[Random(1, attackGroups.num)] .. '_D' .. Difficulty, 'GrowthFormation')
        ScenarioFramework.PlatoonPatrolChain(platoon, 'P3AOffmapattack' .. Random(1, 3))

        WaitSeconds(Random(100, 130))
    end

end

function P3UOffmapattacks()
        local attackGroups = {
        'P3UOffmap1',
        'P3UOffmap2',
        'P3UOffmap3',
    }
    attackGroups.num = table.getn(attackGroups)

    while not ScenarioInfo.OpEnded do
        local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', attackGroups[Random(1, attackGroups.num)] .. '_D' .. Difficulty, 'GrowthFormation')
        ScenarioFramework.PlatoonPatrolChain(platoon, 'P3UOffmapattack' .. Random(1, 2))

        WaitSeconds(Random(70, 90))
    end

end

function PlayerWin()
    
	ScenarioFramework.Dialogue(OpStrings.EndP3, nil, true)
	
    if(not ScenarioInfo.OpEnded) then
        ScenarioInfo.OpComplete = true
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

function SetupUEFM1TauntTriggers()

    UEFTM:AddEnemiesKilledTaunt('TAUNT1P1', ArmyBrains[UEF], categories.STRUCTURE, 10)
    UEFTM:AddUnitsKilledTaunt('TAUNT2P1', ArmyBrains[UEF], categories.STRUCTURE * categories.ECONOMIC, 10)
    UEFTM:AddUnitsKilledTaunt('TAUNT3P1', ArmyBrains[UEF], categories.STRUCTURE * categories.FACTORY, 4)

end

function SetupUEFM2TauntTriggers()
		
    UEFTM:AddEnemiesKilledTaunt('TAUNT1P2', ArmyBrains[UEF], categories.STRUCTURE, 10)
    UEFTM:AddUnitsKilledTaunt('TAUNT2P2', ArmyBrains[UEF], categories.MOBILE + categories.DESTROYER, 5)
    UEFTM:AddUnitsKilledTaunt('TAUNT3P2', ArmyBrains[UEF], categories.STRUCTURE * categories.FACTORY, 3)

end

function DestroyUnit(unit)
	unit:Destroy()
end


