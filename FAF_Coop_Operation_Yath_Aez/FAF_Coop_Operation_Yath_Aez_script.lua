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

function OnPopulate(Self)
    ScenarioUtils.InitializeScenarioArmies()
    LeaderFaction, LocalFaction = ScenarioFramework.GetLeaderAndLocalFactions()
	
	ScenarioFramework.SetUEFPlayerColor(UEF)
	ScenarioFramework.SetSeraphimColor(Player1)
	ScenarioFramework.SetCybranPlayerColor(Cybran)
	ScenarioFramework.SetAeonPlayerColor(Aeon)
	
	 local colors = {
        
        ['Player2'] = {255, 191, 128}, 
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
   
function OnStart(Self)
	 
     ScenarioFramework.AddRestrictionForAllHumans(
	        categories.UEF + -- UEF faction 
			categories.CYBRAN + -- Cybran faction
            categories.xsl0401 + -- Sera Exp Bot
            categories.xsa0402 + -- Sera Exp Bomber
            categories.xsb0304 + -- Sera Gate
            categories.xsl0301 + -- Sera sACU
            categories.xsb2401 + -- Sera exp Nuke
            categories.xss0302 + -- Battleships
            categories.xsb2302 + -- T3 Arty
            categories.xsb2108 + -- Tac launcher
            categories.xsb2305 + -- Sera Nuke launcher
			categories.ual0401 + -- Aeon Exp Bot
            categories.uaa0310 + -- Aeon Exp Carrier
            categories.uab0304 + -- Aeon Gate
			categories.xab2307 + -- Aeon EXP arty
            categories.ual0301 + -- Aeon sACU
            categories.xab1401 + -- Aeon exp Generator
            categories.uas0302 + -- Aeon Battleships
			categories.uas0304 + -- Aeon nuke sub
			categories.xas0306 + -- Aeon missile ship
            categories.uab2302 + -- Aeon T3 Arty
            categories.uab2108 + -- Aeon Tac launcher
            categories.uab2305   -- Aeon Nuke launcher
    )
     
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Commanderwarp'), 0)
	
	 ForkThread(IntroP1)
end

-- Part 1
   
function IntroP1()

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
	 WaitSeconds (1)
   
       ForkThread(
           function()
               WaitSeconds(1)
               P1Vision1:Destroy()
               P1Vision2:Destroy()
           end
      )
		
	Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Commanderwarp'), 4)
		  
	WaitSeconds (1)
		
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
                ScenarioInfo.CoopCDR[coop] = ScenarioFramework.SpawnCommander(strArmy, 'Acommander', 'Warp', true, true, PlayerDeath)
           end
            coop = coop + 1
            WaitSeconds(0.5)
        end
    end
		
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
  
    local timeAttackP1 = {45*60, 40*60, 35*60}  
      
    ScenarioInfo.M1P1 = Objectives.CategoriesInArea(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Destroy UEF Bases',                 -- title
        'Eliminate the UEF\'s bases in the area.',  -- description
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
		if ScenarioInfo.MissionNumber == 1 then
		 ForkThread(IntroP2)
		 else
		  
        end
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
	
	ForkThread(MissionP1secondary)
    
	local M1MapExpandDelay = {50*60, 40*60, 35*60}
    ScenarioFramework.CreateTimerTrigger(IntroP2, M1MapExpandDelay[Difficulty])
	
end
 
function MissionP1secondary()		
	local units = {}

       

    local delay = {10*60, 8*60, 6*60}
    WaitSeconds(delay[Difficulty])
    
	 units = ScenarioUtils.CreateArmyGroup('UEF', 'P1Ubase3EXD_D' .. Difficulty)
	
    for _, v in units do
        if v and not v:IsDead() and EntityCategoryContains(categories.TACTICALMISSILEPLATFORM, v) then
            local plat = ArmyBrains[UEF]:MakePlatoon('', '')
            ArmyBrains[UEF]:AssignUnitsToPlatoon(plat, {v}, 'Attack', 'NoFormation')
            plat:ForkAIThread(plat.TacticalAI)
            WaitSeconds(4)
        end
    end
		
		
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

-- Part 2
 
function IntroP2()

    if ScenarioInfo.MissionNumber == 2 or ScenarioInfo.MissionNumber == 3 then
        return
    end
    ScenarioInfo.MissionNumber = 2
	
	
    ScenarioFramework.SetPlayableArea('AREA_2', true)
    
	P2UEFAI.UEFnavalbaseAI()
    P2UEFAI.UEFmainbaseAI()
    P2CybranAI.Cybranbase1AI()
	P2CybranAI.Cybranbase2AI()
    P2AeonAI.Aeonbase1AI()
	P2AeonAI.Aeonbase2AI()
	
	ScenarioInfo.UEFACU = ScenarioFramework.SpawnCommander('UEF', 'UEFcommander', false, 'Major Fredrick', true, UEFACUdeath,
    {'T3Engineering', 'ResourceAllocation', 'Shield'}) 
	
	ScenarioUtils.CreateArmyGroup( 'UEF', 'P2Uwalls')
	ScenarioUtils.CreateArmyGroup( 'UEF', 'ruin2', true)
	ScenarioUtils.CreateArmyGroup( 'Aeon', 'P2Awalls')
	ScenarioUtils.CreateArmyGroup( 'Cybran', 'P2Cwalls')
	ScenarioUtils.CreateArmyGroup( 'Cybran', 'P2COuterD')
	
	ScenarioFramework.RemoveRestrictionForAllHumans(
	         categories.xss0302 + -- Sera Battleships
			 categories.xsb2108 + -- Sera Tac launcher
			 categories.xsb2305 + -- Sera Nuke Launcher
	         categories.xsl0401 + -- Sera Exp Bot
			 categories.uas0302 + -- Aeon Battleships
			 categories.uab2108 + -- Aeon Tac launcher
			 categories.uab2305 + -- Aeon Nuke Launcher
	         categories.ual0401   -- Aeon Seraph Exp Bot
	)
 
    SetArmyUnitCap(Cybran, 1500)
    SetArmyUnitCap(Aeon, 1500)
  
                units = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'P2UIntlandattack1_D' .. Difficulty , 'AttackFormation')
                ScenarioFramework.PlatoonPatrolChain(units, 'UintattackL' )
          			 
                units = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'P2Unavalattack1_D' .. Difficulty , 'AttackFormation')
                ScenarioFramework.PlatoonPatrolChain(units, 'UintattackN' )
				
                units = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'P2Expattack1_D' .. Difficulty, 'AttackFormation')
                ScenarioFramework.PlatoonPatrolChain(units, 'UintattackL' )
				
			    units = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'P2AIntattack1_D' .. Difficulty , 'AttackFormation')
                ScenarioFramework.PlatoonPatrolChain(units, 'P2AIntlandattack' )
				
				units = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'P2AIntattack2_D' .. Difficulty , 'AttackFormation')
                ScenarioFramework.PlatoonPatrolChain(units, 'P2AIntlandattack' )
				
				units = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'P2AIntattack3_D' .. Difficulty , 'AttackFormation')
                ScenarioFramework.PlatoonPatrolChain(units, 'P2AIntlandattack' )
				
				units = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'P2CIntattack1_D' .. Difficulty , 'AttackFormation')
                ScenarioFramework.PlatoonPatrolChain(units, 'P2CIntNavalattack' )
				
				units = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'P2CIntattack2_D' .. Difficulty , 'AttackFormation')
                ScenarioFramework.PlatoonPatrolChain(units, 'P2CIntlandattack' )
				
				units = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'P2CIntattack3_D' .. Difficulty , 'AttackFormation')
                ScenarioFramework.PlatoonPatrolChain(units, 'P2CIntlandattack' )
				
				units = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'P2CIntattack4_D' .. Difficulty , 'AttackFormation')
                ScenarioFramework.PlatoonPatrolChain(units, 'P2CIntlandattack' )
				
		Cinematics.EnterNISMode()
		Cinematics.SetInvincible('AREA_1')
		Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Commanderwarp'), 0)
		
		WaitSeconds(1)
				
		ScenarioFramework.Dialogue(OpStrings.IntroP2, nil, true)
				
		local VisMarker2_1 = ScenarioFramework.CreateVisibleAreaLocation(60,'UEFattack', 0, ArmyBrains[Player1])
        local VisMarker2_2 = ScenarioFramework.CreateVisibleAreaLocation(90,'UEFnavelattack', 0, ArmyBrains[Player1])
        local VisMarker2_3 = ScenarioFramework.CreateVisibleAreaLocation(90, 'ACattack', 0, ArmyBrains[Player1])
				
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Intattack1'), 3)
		WaitSeconds(1)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Intattack2'), 4)
		WaitSeconds(1)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Intattack3'), 4)
		WaitSeconds(1)
		
		 units = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'P2AIntattack4_D' .. Difficulty , 'AttackFormation')
				 for _, v in units:GetPlatoonUnits() do
                 ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P2AIntairattack')))
                 end
		
		Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Intattack4'), 4)
		WaitSeconds(1)

		  ForkThread(
           function ()
                WaitSeconds(1)
                VisMarker2_1:Destroy()
                VisMarker2_2:Destroy()
                VisMarker2_3:Destroy()
		    end )
			
        Cinematics.SetInvincible('AREA_1', true)
		Cinematics.ExitNISMode()
	
	buffDef = Buffs['CheatIncome']
    buffAffects = buffDef.Affects
    buffAffects.EnergyProduction.Mult = 1.5
    buffAffects.MassProduction.Mult = 2

       for _, u in GetArmyBrain(UEF):GetPlatoonUniquelyNamed('ArmyPool'):GetPlatoonUnits() do
               Buff.ApplyBuff(u, 'CheatIncome')
       end
	
	buffDef = Buffs['CheatIncome']
    buffAffects = buffDef.Affects
    buffAffects.EnergyProduction.Mult = 1.5
    buffAffects.MassProduction.Mult = 2

       for _, u in GetArmyBrain(Cybran):GetPlatoonUniquelyNamed('ArmyPool'):GetPlatoonUnits() do
               Buff.ApplyBuff(u, 'CheatIncome')
       end
	   
	buffDef = Buffs['CheatIncome']
    buffAffects = buffDef.Affects
    buffAffects.EnergyProduction.Mult = 1.5
    buffAffects.MassProduction.Mult = 2

       for _, u in GetArmyBrain(Aeon):GetPlatoonUniquelyNamed('ArmyPool'):GetPlatoonUnits() do
               Buff.ApplyBuff(u, 'CheatIncome')
       end
	
    ArmyBrains[UEF]:GiveResource('MASS', 9000)
    ArmyBrains[UEF]:GiveResource('ENERGY', 60000)
	
	ArmyBrains[Aeon]:GiveResource('MASS', 9000)
    ArmyBrains[Aeon]:GiveResource('ENERGY', 60000)
	
	ArmyBrains[Cybran]:GiveResource('MASS', 9000)
    ArmyBrains[Cybran]:GiveResource('ENERGY', 60000)
	
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
	
		
        end
	end
	)
	
	ForkThread(
	function()
	WaitSeconds(14*60)
	ScenarioFramework.Dialogue(OpStrings.MidP2, nil, true)
	end
	)
	
	ForkThread(SecondaryMissionP2)
	
	local M2MapExpandDelay = {40*60, 35*60, 30*60}
    ScenarioFramework.CreateTimerTrigger(StartPart3, M2MapExpandDelay[Difficulty])
	
	ScenarioInfo.M2Objectives = Objectives.CreateGroup('M2Objectives', StartPart3)
    ScenarioInfo.M2Objectives:AddObjective(ScenarioInfo.M2P1)
    ScenarioInfo.M2Objectives:AddObjective(ScenarioInfo.M2P2)
    if ScenarioInfo.M1P1.Active then
        ScenarioInfo.M2Objectives:AddObjective(ScenarioInfo.M1P1)
    end
	
end

function BonusMissionsP2()


    ---------------------------------------------------
    -- Bonus Objective - Build 10 Experimentals
    ---------------------------------------------------
    ScenarioInfo.M2B1 = Objectives.ArmyStatCompare(
        'bonus',
        'incomplete',
        'Yoth-lo',
        'Build 10 Experimental Units',
        'capture',
        {
            Armies = {'HumanPlayers'},
            StatName = 'Units_Active',
            CompareOp = '>=',
            Value = 10,
            Category = categories.EXPERIMENTAL,
            Hidden = true,
        }
    )
    ScenarioInfo.M2B1:AddResultCallback(
        function(result)
            if result then
              
            end
        end
    )
    
	---------------------------------
    -- Bonus Objective - Kill Spider Bots
    ---------------------------------
    local num = {2, 4, 6}
    ScenarioInfo.M2B2 = Objectives.ArmyStatCompare(
        'bonus',
        'incomplete',
        OpStrings.M2B2Title,
        LOCF(OpStrings.M2B2Description, num[Difficulty]),
        'kill',
        {
            Armies = {'HumanPlayers'},
            StatName = 'Enemies_Killed',
            CompareOp = '>=',
            Value = num[Difficulty],
            Category = categories.url0402,
            Hidden = true,
        }
    )

end

function SecondaryMissionP2()
    
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
                    ArmyIndex = Aeon,
                },
				{
                   Area = 'P2Sec2',
                    Category = categories.FACTORY + categories.TECH3 * categories.STRUCTURE * categories.ECONOMIC + categories.TECH2 * categories.STRUCTURE * categories.ECONOMIC,
                    CompareOp = '==',
                    Value = 0,
                    ArmyIndex = Cybran,
                
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
	


end

function UEFACUdeath()
    
    ScenarioFramework.CDRDeathNISCamera(ScenarioInfo.UEFACU, 3)
    ScenarioFramework.Dialogue(OpStrings.ACUDeath1, nil, true)
	
end

function P2KillUEFBase()
    for _, unit in ArmyBrains[UEF]:GetListOfUnits(categories.ALLUNITS, false) do
        if unit and not unit.Dead then
            unit:Kill()
            WaitSeconds(Random(0.1, 0.3))
        end
    end
end

-- Part 3

function StartPart3()

    ForkThread(IntroP3)

end

function IntroP3()
    
	if ScenarioInfo.MissionNumber == 3 then
        return
    end
    ScenarioInfo.MissionNumber = 3
	
	WaitSeconds(10)
	
    ScenarioFramework.SetPlayableArea('AREA_3', true)
    
	P3AeonAI.AeonP3base1AI()
	P3AeonAI.AeonP3base2AI()
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
	
	 local units = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'P3AIntDefense_D'.. Difficulty , 'AttackFormation')
				 for _, v in units:GetPlatoonUnits() do
                 ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P3AAirdefence1')))
                 end
				 
	units = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'P3AIntDefense2_D' .. Difficulty , 'AttackFormation')
	for _, v in units:GetPlatoonUnits() do
    ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P3AB2AirDefense1')))
    end
	
	units = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'P3AExpDefense1_D' .. Difficulty , 'AttackFormation')
	for _, v in units:GetPlatoonUnits() do
    ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P3AB1Expdefense1')))
    end
	
	units = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'P3AExpDefense2_D' .. Difficulty , 'AttackFormation')
	for _, v in units:GetPlatoonUnits() do
    ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P3AB1Expdefense2')))
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
                 ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P2AIntairattack')))
                 end
	
	ForkThread(function()
	
			local destination = ScenarioUtils.MarkerToPosition('P3MKdrop1')

			local transports = ScenarioUtils.CreateArmyGroup('Cybran', 'P3CIntattacktrans1_D' .. Difficulty)
			local units = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'P3CIntattack1_D' .. Difficulty, 'AttackFormation')
            WaitSeconds(6)
			import('/lua/ai/aiutilities.lua').UseTransports(units:GetPlatoonUnits(), transports, destination)
            
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
            WaitSeconds(9)
			import('/lua/ai/aiutilities.lua').UseTransports(units:GetPlatoonUnits(), transports, destination)
            
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
            WaitSeconds(12)
			import('/lua/ai/aiutilities.lua').UseTransports(units:GetPlatoonUnits(), transports, destination)
            
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
    buffAffects.MassProduction.Mult = 2.0

       for _, u in GetArmyBrain(Aeon):GetPlatoonUniquelyNamed('ArmyPool'):GetPlatoonUnits() do
               Buff.ApplyBuff(u, 'CheatIncome')
       end
	
	ForkThread(MissionP3)
	ForkThread(P3COffmapattacks)
	ForkThread(P3AOffmapattacks)
	ForkThread(P3UOffmapattacks)
	ForkThread(EnableStealthOnAir)

end

function EnableStealthOnAir()
    local T3AirUnits = {}
    while true do
        for _, v in ArmyBrains[Cybran]:GetListOfUnits(categories.ura0303 + categories.ura0304, false) do
            if not ( T3AirUnits[v:GetEntityId()] or v:IsBeingBuilt() ) then
                v:ToggleScriptBit('RULEUTC_StealthToggle')
                T3AirUnits[v:GetEntityId()] = true
            end
        end
        WaitSeconds(10)
    end

end

function MissionP3()
	
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
        'The Support commander is defending the Jammer, kill her if shes in the way.',  --description
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
	
	ScenarioInfo.M3Objectives = Objectives.CreateGroup('M3Objectives', PlayerWin)
    ScenarioInfo.M3Objectives:AddObjective(ScenarioInfo.M1P3)
    if ScenarioInfo.M1P2.Active then
        ScenarioInfo.M3Objectives:AddObjective(ScenarioInfo.M1P2)
    end
    if ScenarioInfo.M2P2.Active then
        ScenarioInfo.M3Objectives:AddObjective(ScenarioInfo.M2P2)
    end

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

        WaitSeconds(Random(110, 140))
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

        WaitSeconds(Random(110, 140))
    end

end

function P3UOffmapattacks()
    WaitSeconds(60)
        local attackGroups = {
        'P3UOffmap1',
        'P3UOffmap2',
        'P3UOffmap3',
		'P3UOffmap4',
    }
    attackGroups.num = table.getn(attackGroups)

    while not ScenarioInfo.OpEnded do
        local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', attackGroups[Random(1, attackGroups.num)] .. '_D' .. Difficulty, 'GrowthFormation')
        ScenarioFramework.PlatoonPatrolChain(platoon, 'P3UOffmapattack' .. Random(1, 2))

        WaitSeconds(Random(80, 90))
    end

end

--misc function

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


