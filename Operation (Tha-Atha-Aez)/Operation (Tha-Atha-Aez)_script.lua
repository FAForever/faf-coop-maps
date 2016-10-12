local Objectives = import('/lua/ScenarioFramework.lua').Objectives
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local Utilities = import('/lua/Utilities.lua')
local Cinematics = import('/lua/cinematics.lua')
local P2UEFAI = import('/maps/Operation (Tha-Atha-Aez)/UEFaiP2.lua')
local P3UEFAI = import('/maps/Operation (Tha-Atha-Aez)/UEFaiP3.lua')
local P3SERAAI = import('/maps/Operation (Tha-Atha-Aez)/SERAaiP3.lua')
local P2SERAAI = import('/maps/Operation (Tha-Atha-Aez)/SERAaiP2.lua')
local P2AEONAI = import('/maps/Operation (Tha-Atha-Aez)/AEONaiP2.lua')
local Buff = import('/lua/sim/Buff.lua')
local OpStrings = import('/maps/Operation (Tha-Atha-Aez)/Operation (Tha-Atha-Aez)_strings.lua')

ScenarioInfo.Player = 1
ScenarioInfo.SeraphimAlly = 2
ScenarioInfo.UEF = 3
ScenarioInfo.Aeon = 4
ScenarioInfo.WarpComs = 5
ScenarioInfo.SeraphimAlly2 = 6
ScenarioInfo.Coop1= 7
ScenarioInfo.Coop2 = 8
ScenarioInfo.Coop3 = 9

local Difficulty = ScenarioInfo.Options.Difficulty

local Player = ScenarioInfo.Player
local SeraphimAlly = ScenarioInfo.SeraphimAlly
local Aeon = ScenarioInfo.Aeon
local UEF = ScenarioInfo.UEF
local WarpComs = ScenarioInfo.WarpComs
local SeraphimAlly2 = ScenarioInfo.SeraphimAlly2
local Coop1 = ScenarioInfo.Coop1
local Coop2 = ScenarioInfo.Coop2
local Coop3 = ScenarioInfo.Coop3
local AssignedObjectives = {}

local timeAttackP2 = 480

local Debug = false
local SkipNIS2 = false

function OnPopulate() 
    ScenarioUtils.InitializeScenarioArmies()
   
    ScenarioFramework.SetSeraphimColor(Player)
    ScenarioFramework.SetUEFPlayerColor(UEF)
    ScenarioFramework.SetNeutralColor (WarpComs)
    ScenarioFramework.SetAeonAlly1Color (Aeon)
    local colors = {
        ['Coop1'] = {255, 200, 0}, 
        ['Coop2'] = {189, 116, 16}, 
        ['Coop3'] = {89, 133, 39},	
    }
	local tblArmy = ListArmies()
    for army, color in colors do
        if tblArmy[ScenarioInfo[army]] then
            ScenarioFramework.SetArmyColor(ScenarioInfo[army], unpack(color))
        end
    end
     
    ScenarioUtils.CreateArmyGroup('Player', 'Pintbase')
    ScenarioUtils.CreateArmyGroup('Player', 'Pintbasewreak', true)
    ScenarioUtils.CreateArmyGroup('WarpComs', 'Gatebase1')
    ScenarioInfo.M1ObjectiveGate = ScenarioUtils.CreateArmyUnit('WarpComs', 'Gate1')

    
    local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'P1attack1', 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'P1intattack1')
  
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'P1attack2', 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'P1intattack2')
    
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'P1attack3', 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'P1intattack3')
  
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'P1attack4' , 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'P1intattack4' )
   
    
	buffDef = Buffs['CheatIncome']
    buffAffects = buffDef.Affects
    buffAffects.EnergyProduction.Mult = 1.5
    buffAffects.MassProduction.Mult = 1.5
end 

function OnStart(self) 
    ScenarioFramework.AddRestriction(Player,
        categories.xeb2306 + -- UEF Heavy Point Defense
        categories.xel0305 + -- UEF Percival
        categories.xel0306 + -- UEF Mobile Missile Platform
        categories.xes0102 + -- UEF Torpedo Boat
        categories.xes0205 + -- UEF Shield Boat
        categories.xes0307 + -- UEF Battlecruiser
        categories.xeb0104 + -- UEF Engineering Station 1
        categories.xeb0204 + -- UEF Engineering Station 2
        categories.xea0306 + -- UEF Heavy Air Transport
        categories.xeb2402 + -- UEF Sub-Orbital Defense System
        categories.xsl0305 + -- Seraph Sniper Bot
        categories.xsl0304 + -- Seraph Arty Unit
        categories.xsa0402 + -- Seraph Exp Bomb
        categories.xss0304 + -- Seraph Sub Hunter
        categories.xsb0304 + -- Seraph Gate
        categories.xsl0301 + -- Seraph sACU
        categories.xsb2401 + -- Seraph exp Nuke
        categories.xsb2303 + -- T3 Arty
        categories.xsb2108 + -- Tac lancher
        categories.xsb2305   -- Nuke lancher
    )
   
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Commanderwarp'), 0)
    
    ForkThread(IntroPart1)
end

function IntroPart1()
    ScenarioFramework.SetPlayableArea('AREA_1', false)
 
    Cinematics.EnterNISMode()
  
    ScenarioInfo.PlayerCDR = ScenarioFramework.SpawnCommander('Player', 'Commander', 'Gate', true, true, PlayerDeath)
    
	ForkThread(
        function()
            local tblArmy = ListArmies()
            if tblArmy[ScenarioInfo.Coop1] then
                ScenarioInfo.CoopCDR1 = ScenarioFramework.SpawnCommander('Coop1', 'Commander', 'Warp', true, true, PlayerDeath)
            end

            WaitSeconds(3)

            if tblArmy[ScenarioInfo.Coop2] then
                ScenarioInfo.CoopCDR2 = ScenarioFramework.SpawnCommander('Coop2', 'Commander', 'Warp', true, true, PlayerDeath)
            end

            WaitSeconds(3)

            if tblArmy[ScenarioInfo.Coop3] then
                ScenarioInfo.CoopCDR3 = ScenarioUtils.CreateArmyUnit('Coop3', 'Commander', 'Warp', true, true, PlayerDeath)
            end
        end
    )
	
    local cmd = IssueMove({ScenarioInfo.PlayerCDR}, ScenarioUtils.MarkerToPosition('ComMove'))
 
    ScenarioFramework.Dialogue(OpStrings.IntroP1, nil, true)
 
    WaitSeconds(2)
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Pintattackcam1'), 2)
    WaitSeconds(1)
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Pintattackcam2'), 2)
    WaitSeconds(1)
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Pintattackcam3'), 2)
    WaitSeconds(1)

    Cinematics.ExitNISMode()
   
    StartPart1()
end

function StartPart1()
    ----------------------------------------------
    -- Primary Objective 1 - Survive UEF assault
    ----------------------------------------------
    ScenarioInfo.M1P1 = Objectives.CategoriesInArea(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Survive UEF Assault',                 -- title
        'Kill all UEF Forces Attacking You.',  -- description
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
                IntroPart2()
            end
        end
    )
 
    ----------------------------------------------
    -- Primary Objective 2 - The Gate Must Survive
    ----------------------------------------------
    ScenarioInfo.M1P1 = Objectives.Protect(
        'primary',                      -- type
        'incomplete',                   -- complete
        'The Gate Must Survive',                -- title
        'Without The Gate the Retreat is over.', -- description
       
        {                              -- target
            MarkUnits = true,
            Units = {ScenarioInfo.M1ObjectiveGate}, 
        }
    )
    ScenarioInfo.M1P1:AddResultCallback(
        function(result)
    	    if (not result and not ScenarioInfo.OpEnded) then
                ScenarioFramework.Dialogue(OpStrings.Comsdeath, PlayerLose, true)
    	    end
        end
    )
end

function IntroPart2()
    if not SkipNIS2 then
   
        ScenarioFramework.Dialogue(OpStrings.IntroP2, nil, true)
       
        ScenarioInfo.M1P2 = Objectives.Timer(
            'primary',                      -- type
            'incomplete',                   -- complete
            'Prepare For Second UEF Assault',                 -- title
            'Rebuild Your Defences. Expect the Next Wave To Be Much Stronger',  -- description
            {                               -- target
                Timer = timeAttackP2,
                ExpireResult = 'complete',
            }
        )

        ScenarioInfo.M1P2:AddResultCallback(
            function(result)
                if result then
                    StartMission2()
                end
            end
        )
    else
        StartMission2()
    end
end

function StartMission2()
    ScenarioUtils.CreateArmyGroup('UEF', 'UEFForwardefences')

    local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'P2attack1', 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'P2intattack1')

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'P2attack2', 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'P2intattack2')
    
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'P2attack3', 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'P2intattack3')

    --------------------------------------------
    -- Primary Objective 3 - Survive Second UEF assault
    --------------------------------------------
    ScenarioInfo.M1P3 = Objectives.CategoriesInArea(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Survive Second UEF Assault',                 -- title
        'Kill all UEF forces attacking you.',  -- description
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
    ScenarioInfo.M1P3:AddResultCallback(
        function(result)
            if result then
                ForkThread(Start2Mission2) 
            end
        end
    )
end

function Start2Mission2()
    ScenarioFramework.SetPlayableArea('AREA_2', true)

    P2SERAAI.SeraphimBaseAI()
    P2AEONAI.AeonNavalAI()
	P2AEONAI.AeonIntelAI()
    P2UEFAI.UEFNbaseAI()
    P2UEFAI.UEFSbaseAI()
    P2UEFAI.UEFS2baseAI()

    
    ScenarioUtils.CreateArmyGroup('WarpComs', 'Gatebase2')
    ScenarioInfo.M2ObjectiveGate = ScenarioUtils.CreateArmyUnit('WarpComs', 'Gate2')


    ScenarioInfo.SeraACU = ScenarioFramework.SpawnCommander('SeraphimAlly', 'SeraCom', false, 'Vuth-Vuthroz', false, false,
        {'AdvancedEngineering', 'DamageStabilization', 'DamageStabilizationAdvanced', 'RateOfFire'})

    local units = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'SbaseD1', 'AttackFormation')
    for _, v in units:GetPlatoonUnits() do
       ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P2SbaseDchain')))
    end

    units = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'SbaseD2', 'AttackFormation')
    for _, v in units:GetPlatoonUnits() do
       ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P2S2baseDchain')))
    end
        
    units = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'NbaseD', 'AttackFormation')
    for _, v in units:GetPlatoonUnits() do
       ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P2NbaseDchain')))
    end
   
    units = ScenarioUtils.CreateArmyGroupAsPlatoon('SeraphimAlly', 'SApatrolG1', 'AttackFormation')
    for _, v in units:GetPlatoonUnits() do
       ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P2SeraDchain2')))
    end
   
    units = ScenarioUtils.CreateArmyGroupAsPlatoon('SeraphimAlly', 'SApatrolG2', 'AttackFormation')
    for _, v in units:GetPlatoonUnits() do
       ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P2SeraDchain1')))
    end
   
    units = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'AP2attack1', 'GrowthFormation')
    for _, v in units:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolChain({v}, 'P2Aintattack1')
    end
   
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Commanderwarp'), 0)
	
	ScenarioFramework.Dialogue(OpStrings.IntroP3, nil, true)
   
    Cinematics.EnterNISMode()
   
    local VisMarker2_1 = ScenarioFramework.CreateVisibleAreaLocation(50, 'CaminfoP2_3', 0, ArmyBrains[Player])
    local VisMarker2_2 = ScenarioFramework.CreateVisibleAreaLocation(50, 'CamnfoP2_1', 0, ArmyBrains[Player])
    local VisMarker2_3 = ScenarioFramework.CreateVisibleAreaLocation(50, 'CamnfoP2_2', 0, ArmyBrains[Player])
   
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('CamP2_1'), 3)
    WaitSeconds(1)
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('CamP2_2'), 3)
    WaitSeconds(1)
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('CamP2_3'), 3)
    WaitSeconds(1)
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('CamP2_4'), 3)
    WaitSeconds(1)
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('CamP2_5'), 3)
  
    ForkThread(
        function()
            WaitSeconds(2)
            VisMarker2_1:Destroy()
            VisMarker2_2:Destroy()
            VisMarker2_3:Destroy()
        end
    )
  
    Cinematics.ExitNISMode()
   
    --------------------------------------------
    --Primary Objective 4 - Survive Second UEF assault
    --------------------------------------------
    ScenarioInfo.M2P1 = Objectives.CategoriesInArea(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Go On The Offensive ',                 -- title
        'Destroy all UEF Forces In The Area .',  -- description
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
    ScenarioInfo.M2P1:AddResultCallback(
        function(result)
            if result then
                ForkThread(IntroMissionP3)
            end
        end
    )
	
	ScenarioInfo.M2P1S1 = Objectives.CategoriesInArea(
        'secondary',                      -- type
        'incomplete',                   -- complete
        'Destroy Aeon Support Base',                -- title
        'Destroy Aeon support Base to help your ally', -- description
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
   
    ScenarioInfo.M2P2 = Objectives.Protect(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Assist Zuth When You Can',                -- title
        'Zuth is Defending The Retreat Gate Help Him When able.', -- description
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
	
	ArmyBrains[UEF]:GiveResource('MASS', 4000)
    ArmyBrains[UEF]:GiveResource('ENERGY', 6000)
	 
    buffDef = Buffs['CheatIncome']
    buffAffects = buffDef.Affects
    buffAffects.EnergyProduction.Mult = 1.5
    buffAffects.MassProduction.Mult = 1.5
	
	for _, u in GetArmyBrain(UEF):GetPlatoonUniquelyNamed('ArmyPool'):GetPlatoonUnits() do
        Buff.ApplyBuff(u, 'CheatIncome')
    end
	 
	ArmyBrains[Aeon]:GiveResource('MASS', 4000)
    ArmyBrains[Aeon]:GiveResource('ENERGY', 6000)
   
    buffAffects = buffDef.Affects
    buffAffects.EnergyProduction.Mult = 1.5
    buffAffects.MassProduction.Mult = 1.5
	
	for _, u in GetArmyBrain(Aeon):GetPlatoonUniquelyNamed('ArmyPool'):GetPlatoonUnits() do
        Buff.ApplyBuff(u, 'CheatIncome')
    end
end

function IntroMissionP3()
	ScenarioFramework.Dialogue(OpStrings.CompleteP3, ACU1, true)
end

function ACU1()
    local units = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'Comintercept4', 'GrowthFormation')
	ScenarioFramework.PlatoonPatrolChain(units, 'Aintercept3')
    
    ScenarioInfo.AeonACU1 = ScenarioFramework.SpawnCommander('WarpComs', 'G1U1', 'Gate', 'Harva', false, false,
        {'CrysalisBeam', 'Shield', 'ShieldHeavy'})
    ScenarioFramework.GroupMoveChain({ScenarioInfo.AeonACU1}, 'WarpComChain1')

    WaitSeconds(5)
	ACU2()
end

function ACU2()
    ScenarioInfo.AeonACU2 = ScenarioFramework.SpawnCommander('WarpComs', 'G1U2', 'Gate', 'Tuth-Yuthian', false, false,
        {'BlastAttack', 'DamageStabilization', 'DamageStabilizationAdvanced'})
    ScenarioFramework.GroupMoveChain({ScenarioInfo.AeonACU2}, 'WarpComChain1')

	Cinematics.EnterNISMode()
 
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('GateCam1'), 0)
    WaitSeconds(5)

    Cinematics.ExitNISMode() 
	
    ACU3()
end

function ACU3() 
    ScenarioInfo.AeonACU3 = ScenarioFramework.SpawnCommander('WarpComs', 'G1U3', 'Gate', 'Zertha', false, false,
        {'Shield', 'EnhancedSensors'}) 
    ScenarioFramework.GroupMoveChain({ScenarioInfo.AeonACU3}, 'WarpComChain1')

    ScenarioInfo.M3P1 = Objectives.SpecificUnitsInArea(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Protect Retreating Commanders',                -- title
        'We Need Every Able Commander, Defend Them At All Costs', -- description
        {                              -- target
            MarkUnits = true,
            Units = {ScenarioInfo.AeonACU1, ScenarioInfo.AeonACU2, ScenarioInfo.AeonACU3},
            Area = 'EvacZone',
        }
    )
   
    ScenarioInfo.M3P1:AddResultCallback(
        function(result)
            if (not result and not ScenarioInfo.OpEnded) then
                ScenarioFramework.Dialogue(OpStrings.Comsdeath, PlayerLose, true)
            end

            if result then
                ScenarioFramework.FakeTeleportUnit(ScenarioInfo.AeonACU1, true)
                ScenarioFramework.FakeTeleportUnit(ScenarioInfo.AeonACU2, true)
                ScenarioFramework.FakeTeleportUnit(ScenarioInfo.AeonACU3, true)

                ForkThread(MissionM2P3) 
    		end
        end
    )
	
	WaitSeconds(10)
	local units = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'UEFComintercept2', 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(units, 'UEFintercept1')
   
	WaitSeconds(10)
    units = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'Comintercept1', 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(units, 'Aintercept1')
end

function MissionM2P3()
    ACU4()
end

function ACU4()
    ScenarioInfo.AeonACU4 = ScenarioFramework.SpawnCommander('WarpComs', 'G1U4', 'Gate', 'Zorez-thooum', false, false,
        {'DamageStabilization', 'RateOfFire'})
    ScenarioFramework.GroupMoveChain({ScenarioInfo.AeonACU4}, 'WarpComChain1')

	local units = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'UEFComintercept1', 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(units, 'UEFintercept2')
	
    WaitSeconds(5)
	ACU5() 
end

function ACU5()
    ScenarioInfo.AeonACU5 = ScenarioFramework.SpawnCommander('WarpComs', 'G1U5', 'Gate', 'Thuma-thooum', false, false,
        {'DamageStabilization'})
    ScenarioFramework.GroupMoveChain({ScenarioInfo.AeonACU5}, 'WarpComChain1')

	Cinematics.EnterNISMode()
 
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('GateCam1'), 0)
    WaitSeconds(5)

    Cinematics.ExitNISMode()
	
    ACU6()
end

function ACU6()
    ScenarioInfo.AeonACU6 = ScenarioFramework.SpawnCommander('WarpComs', 'G1U6', 'Gate', 'Kelean', false, false,
        {'CrysalisBeam'})
    ScenarioFramework.GroupMoveChain({ScenarioInfo.AeonACU6}, 'WarpComChain1')

    ScenarioInfo.M3P2 = Objectives.SpecificUnitsInArea(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Protect Retreating Commanders',                -- title
        'We Need Every Able Commander Defend Them At All Costs', -- description    
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

                ForkThread(IntroMission4)
            end
        end
    )

	WaitSeconds(10)

	local units = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'Comintercept2', 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(units, 'Aintercept1')
	
    units = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'Comintercept3', 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(units, 'Aintercept3')
end

function IntroMission4()
    ScenarioFramework.SetPlayableArea('AREA_3', true)
	
	ForkThread(nukeparty)

    P3UEFAI.UEFmain1AI()
	P3UEFAI.UEFmain2AI()
	P2AEONAI.AeonNaval2AI()
	P3SERAAI.OrderBaseAI()
	
	ScenarioInfo.M2P2:ManualResult(true)
	
	ScenarioFramework.Dialogue(OpStrings.IntroP4, nil, true)
	
    ScenarioFramework.RemoveRestriction(Player,
        categories.xsb2302 + -- T2 arty
        categories.xsb2108 + -- Tac lancher
        categories.xsb2305 + -- Nuke lancher
        categories.xsl0305 + -- Seraph Sniper Bot
        categories.xsl0304  -- Seraph Arty Unit
    )
	
    ScenarioInfo.UEFACU = ScenarioFramework.SpawnCommander('UEF', 'UEFCom', false, 'Colonel Griff', false, false,
        {'T3Engineering', 'ShieldGeneratorField', 'HeavyAntiMatterCannon'})

    ScenarioInfo.AEONACU = ScenarioFramework.SpawnCommander('Aeon', 'AeonCom', false, 'Crusader Thaila', false, false,
        {'ShieldHeavy', 'CrysalisBeam', 'EnhancedSensors'})

    ScenarioUtils.CreateArmyGroup('SeraphimAlly2', 'AeonBaseWK', true)
    ScenarioUtils.CreateArmyGroup('WarpComs', 'Gatebase3')
    ScenarioInfo.M3ObjectiveGate = ScenarioUtils.CreateArmyUnit('WarpComs', 'Gate3')
	
    ScenarioInfo.SeraACU2 = ScenarioFramework.SpawnCommander('SeraphimAlly2', 'SeraCom2', false, 'Jareth', false, false,
        {'AdvancedEngineering', 'ShieldHeavy'})
	
    local units = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'P3attack1', 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(units, 'P3UEFattack1')
    
    units = ScenarioUtils.CreateArmyGroupAsPlatoon('SeraphimAlly2', 'Defendunits', 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(units, 'DefendUnitschain')
    
    units = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'Expattack1', 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(units, 'Expattackchain')
   
    units = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'ExpattackH', 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(units, 'Expattackchain')
	
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Commanderwarp'), 0)
	
    Cinematics.EnterNISMode()
	
	local VisMarker2_4 = ScenarioFramework.CreateVisibleAreaLocation(50, 'CamnfoP3_1', 0, ArmyBrains[Player])
    local VisMarker2_5 = ScenarioFramework.CreateVisibleAreaLocation(50, 'CamnfoP3_2', 0, ArmyBrains[Player])
	local VisMarker2_6 = ScenarioFramework.CreateVisibleAreaLocation(80, 'UEFVison1', 0, ArmyBrains[Player])
	local VisMarker2_7 = ScenarioFramework.CreateVisibleAreaLocation(80, 'UEFVison2', 0, ArmyBrains[Player])

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

	ScenarioInfo.M3P1 = Objectives.Kill(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Kill The UEF Commander',                -- title
        'The UEF Commander Is Between You On The Thrid Gate, Destory Him.', -- description
        {                              -- target
            MarkUnits = true,
            Units = {ScenarioInfo.UEFACU}  
        }
    )
    ScenarioInfo.M3P1:AddResultCallback(
        function(result)
            if result then
                ForkThread(Cleanup)
                UEFCommanderKilled()
            end
        end
    )

	ScenarioInfo.M3P2 = Objectives.Protect(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Assist Jareth When You Can',                -- title
        'Jareth is Defending The Retreat Gate Help Him When able.', -- description
        {                              -- target
            MarkUnits = true,
            Units = {ScenarioInfo.SeraACU2, ScenarioInfo.M3ObjectiveGate}   
        }
    )
    ScenarioInfo.M3P2:AddResultCallback(
        function(result)
            if (not result and not ScenarioInfo.OpEnded) then
                ScenarioFramework.Dialogue(OpStrings.Comsdeath, PlayerLose, true)
            end
        end
    )

	ScenarioInfo.M3P1S1 = Objectives.Kill(
        'secondary',                      -- type
        'incomplete',                   -- complete
        'Kill The Aeon Commander',                -- title
        'Kill the Aeon commander if you get the chance', -- description
        {                              -- target
            MarkUnits = true,
            Units = {ScenarioInfo.AEONACU}  
        }
    )	
end

function Cleanup()
    ScenarioInfo.M4P1 = Objectives.CategoriesInArea(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Destroy UEF base',                -- title
        'Destroy Reaming UEF Factories to allow our commadners travel thought this area', -- description
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
                ForkThread(ACU7)
            end
        end
    )
end

function UEFCommanderKilled()
    ScenarioFramework.CDRDeathNISCamera(ScenarioInfo.UEFACU, 2)
    P3UEFAI.DisableBase()
	P3UEFAI.DisableBase2()

	ScenarioInfo.M3P2:ManualResult(true)
end

function ACU7()
    WaitSeconds(10)

    ScenarioInfo.AeonACU7 = ScenarioFramework.SpawnCommander('WarpComs', 'G1U7', 'Gate', 'Vara', false, false,
        {'ChronoDampener', 'HeatSink'})
    ScenarioFramework.GroupMoveChain({ScenarioInfo.AeonACU7}, 'WarpComChain2')

	local units = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'P4UEFattack2', 'AttackFormation')
	for _, v in units:GetPlatoonUnits() do
        ScenarioFramework.GroupMoveChain({v}, 'P4UEFattack2')
	end
    WaitSeconds(5)
	ACU8()	
end

function ACU8()
    ScenarioInfo.AeonACU8 = ScenarioFramework.SpawnCommander('WarpComs', 'G1U8', 'Gate', 'Unknown ACU', false, false,
        {'AdvancedEngineering','NaniteTorpedoTube','ResourceAllocation'})
    ScenarioFramework.GroupMoveChain({ScenarioInfo.AeonACU8}, 'WarpComChain2')

	local units = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'Comintercept6', 'AttackFormation')
	for _, v in units:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolChain({v}, 'P4Aeonattack2')
	end

    WaitSeconds(5)

	ACU9()
end

function ACU9()
    ScenarioInfo.AeonACU9 = ScenarioFramework.SpawnCommander('WarpComs', 'G1U9', 'Gate', 'Overlord Voth-Othum', false, false,
        {'AdvancedEngineering','ResourceAllocation'})
    ScenarioFramework.GroupMoveChain({ScenarioInfo.AeonACU9}, 'WarpComChain2')
	
	 ScenarioInfo.M4P2 = Objectives.SpecificUnitsInArea(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Protect Retreating Commanders',                -- title
        'We Need Every Able Commander Defend Them At All Costs', -- description    
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

                ForkThread(PlayerWin)
            end
        end
    )
	
    ScenarioFramework.Dialogue(OpStrings.IntroP5, nil, true)

	local units = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'Comintercept5', 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(units, 'P4Aeonattack1')
	  
	units = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'P4UEFattack1', 'GrowthFormation')
    for _, v in units:GetPlatoonUnits() do
       ScenarioFramework.GroupMoveChain({v}, 'P4UEFattack1')
	end
	 
    WaitSeconds(5)
	
	ScenarioInfo.M3P2:ManualResult(true)
	
	WaitSeconds(180)

	units = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'Comintercept7', 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(units, 'P4Aeonattack3')
	
	units = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'Comintercept8', 'GrowthFormation')
	for _, v in units:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolChain({v}, 'P4Aeonattack4')	
	end
	
	ScenarioUtils.CreateArmyGroup('Aeon', 'Artybase')
end

function nukeparty()
    local AeonNuke = ArmyBrains[Aeon]:GetListOfUnits(categories.uab2305, false)

    WaitSeconds(30)
    IssueNuke({AeonNuke[1]}, ScenarioUtils.MarkerToPosition('Nuke1'))
    WaitSeconds(10)
    IssueNuke({AeonNuke[1]}, ScenarioUtils.MarkerToPosition('Nuke2'))
end

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

function PlayerDeath()
    if Debug then return end
    if not ScenarioInfo.OpEnded then
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
    end
    KillGame()
end