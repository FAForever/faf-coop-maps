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
local P3CoalitionAI = import('/maps/FAF_Coop_Operation_Yath_Aez/CoalitionaiP3.lua')
local P2CybranAI = import('/maps/FAF_Coop_Operation_Yath_Aez/CybranaiP2.lua')
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

ScenarioInfo.Player1 = 1
ScenarioInfo.UEF = 2
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
local ExpansionTimer = ScenarioInfo.Options.Expansion

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
        categories.xsb2305 + -- Sera Nuke launcher
        categories.ual0401 + -- Aeon Exp Bot
        categories.uaa0310 + -- Aeon Exp Carrier
        categories.uas0401 + -- Aeon Exp battleship
        categories.uab0304 + -- Aeon Gate
        categories.xab2307 + -- Aeon EXP arty
        categories.ual0301 + -- Aeon sACU
        categories.xab1401 + -- Aeon exp Generator
        categories.uas0302 + -- Aeon Battleships
        categories.uas0304 + -- Aeon nuke sub
        categories.xas0306 + -- Aeon missile ship
        categories.uab2302 + -- Aeon T3 Arty
        categories.uab2305   -- Aeon Nuke launcher
    )
     
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P1Cam1'), 0)
    
    ForkThread(IntroP1)
end

-- Part 1
   
function IntroP1()

    ScenarioInfo.MissionNumber = 1

    ScenarioFramework.SetPlayableArea('AREA_1', false)
   
    ScenarioUtils.CreateArmyGroup('UEF', 'P1Wreaks', true)
    ScenarioUtils.CreateArmyGroup( 'UEF', 'P1UWalls')
 
    P1UEFAI.P1UEFBase1AI()
    P1UEFAI.P1UEFBase2AI()
    P1UEFAI.P1UEFBase3AI()
    
    Cinematics.EnterNISMode()
    
    ScenarioFramework.Dialogue(OpStrings.IntroP1, nil, true)
   
    local P1Vision_1 = ScenarioFramework.CreateVisibleAreaLocation(60, ScenarioUtils.MarkerToPosition('P1Vision1'), 0, ArmyBrains[Player1])
    local P1Vision_2 = ScenarioFramework.CreateVisibleAreaLocation(60, ScenarioUtils.MarkerToPosition('P1Vision2'), 0, ArmyBrains[Player1])
    local P1Vision_3 = ScenarioFramework.CreateVisibleAreaLocation(60, ScenarioUtils.MarkerToPosition('P1Vision3'), 0, ArmyBrains[Player1])
       
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P1Cam1'), 1)
    WaitSeconds(4)
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P1Cam2'), 4)
    WaitSeconds(3)
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P1Cam3'), 4)
    WaitSeconds(2)
       ForkThread(
            function()
                WaitSeconds(1)
                P1Vision_1:Destroy()
                P1Vision_2:Destroy()
                P1Vision_3:Destroy()
                WaitSeconds(1)
                ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('P1Vision1'), 70)
                ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('P1Vision2'), 70)
                ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('P1Vision3'), 70)
            end
      )

    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P1Cam4'), 3)
          
    WaitSeconds (1)
        
    ScenarioInfo.PlayerCDR = ScenarioFramework.SpawnCommander('Player1', 'Commander', 'Warp', true, true, PlayerDeath)
    
     -- spawn coop players too
    ScenarioInfo.CoopCDR = {}
    local tblArmy = ListArmies()
    coop = 1
    for iArmy, strArmy in pairs(tblArmy) do
        if iArmy >= ScenarioInfo.Player2 then
            factionIdx = GetArmyBrain(strArmy):GetFactionIndex()
            if (factionIdx == 2) then
                ScenarioInfo.CoopCDR[coop] = ScenarioFramework.SpawnCommander(strArmy, 'Acommander', 'Warp', true, true, PlayerDeath)
            else
                ScenarioInfo.CoopCDR[coop] = ScenarioFramework.SpawnCommander(strArmy, 'Commander', 'Warp', true, true, PlayerDeath)
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
    buffAffects.EnergyProduction.Mult = 2
    buffAffects.MassProduction.Mult = 1.5

       for _, u in GetArmyBrain(UEF):GetPlatoonUniquelyNamed('ArmyPool'):GetPlatoonUnits() do
               Buff.ApplyBuff(u, 'CheatIncome')
       end
    
    MissionP1()  
end
   
function MissionP1()
   
    ScenarioInfo.M1P1 = Objectives.CategoriesInArea(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Destroy UEF Base',                 -- title
        'Eliminate the UEF\'s primary base in the area.',  -- description
        'kill',                         -- action
        {                               -- target
            MarkUnits = true,
            ShowProgress = true,
            ShowFaction = 'UEF',
            Requirements = {
                {   
                    Area = 'P1Obj1',
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

    ScenarioFramework.CreateTimerTrigger(P1UEFreveal, 2*60)

    ScenarioFramework.CreateTimerTrigger(P1MidDialogue, 20*60)
    
    ScenarioFramework.CreateAreaTrigger(MissionP1secondary, 'AREA_1', categories.ALLUNITS - categories.TECH1, true, false, ArmyBrains[Player1], 5)
    
    if ExpansionTimer then
        local M1MapExpandDelay = {40*60, 35*60, 30*60}
        ScenarioFramework.CreateTimerTrigger(IntroP2, M1MapExpandDelay[Difficulty])  
    end  
end
 
function MissionP1secondary()

    local delay = {6*60, 4*60, 2*60}
    WaitSeconds(delay[Difficulty])

    local units = ScenarioUtils.CreateArmyGroup('UEF', 'P1Taclaunchers')

    for _, v in units do
        if v and not v:IsDead() and EntityCategoryContains(categories.TACTICALMISSILEPLATFORM, v) then
            local plat = ArmyBrains[UEF]:MakePlatoon('', '')
            ArmyBrains[UEF]:AssignUnitsToPlatoon(plat, {v}, 'Attack', 'NoFormation')
            plat:ForkAIThread(plat.TacticalAI)
            WaitSeconds(4)
        end
    end
        
        
    ScenarioFramework.Dialogue(OpStrings.SecondaryP1, nil, true)
        
    ScenarioInfo.M1P1S1 = Objectives.CategoriesInArea(
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
                Area = 'P1SecObj1',
                Category = categories.TACTICALMISSILEPLATFORM + categories.FACTORY + categories.TECH2 * categories.STRUCTURE * categories.ECONOMIC,
                CompareOp = '==',
                Value = 0,
                ArmyIndex = UEF,
            },
            {   
                Area = 'P1SecObj2',
                Category = categories.TACTICALMISSILEPLATFORM + categories.FACTORY + categories.TECH2 * categories.STRUCTURE * categories.ECONOMIC,
                CompareOp = '==',
                Value = 0,
                ArmyIndex = UEF,
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

function P1UEFreveal()

    ScenarioFramework.Dialogue(OpStrings.RevealP1, nil, true)
end

function P1MidDialogue()

    ScenarioFramework.Dialogue(OpStrings.MidP1, nil, true)
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
    P2AeonAI.Aeonbase1AI()
    
    ScenarioInfo.UEFACU = ScenarioFramework.SpawnCommander('UEF', 'UEFcommander', false, 'Major Fredrick', true, false,
    {'T3Engineering', 'ResourceAllocation', 'Shield'}) 
    ScenarioInfo.UEFACU:SetAutoOvercharge(true)
    ScenarioInfo.UEFACU:SetVeterancy(1 + Difficulty)

    ScenarioInfo.Jammer = ScenarioUtils.CreateArmyUnit('UEF', 'Jammer')
        ScenarioInfo.Jammer:SetCustomName("Quantum Jammer")
        ScenarioInfo.Jammer:SetReclaimable(false)
        ScenarioInfo.Jammer:SetCapturable(false)
        ScenarioInfo.Jammer:SetCanTakeDamage(true)
        ScenarioInfo.Jammer:SetCanBeKilled(true)
    
    ScenarioUtils.CreateArmyGroup( 'UEF', 'P2Uwalls')
    ScenarioUtils.CreateArmyGroup( 'UEF', 'P2Wreaks', true)
    ScenarioUtils.CreateArmyGroup( 'Aeon', 'P2Awalls')
    ScenarioUtils.CreateArmyGroup( 'Cybran', 'P2Cwalls')

    ScenarioFramework.PlayUnlockDialogue()
    
    ScenarioFramework.RemoveRestrictionForAllHumans(
             categories.xss0302 + -- Sera Battleships
             categories.xsb2305 + -- Sera Nuke Launcher
             categories.xsl0401 + -- Sera Exp Bot
             categories.uas0302 + -- Aeon Battleships
             categories.uab2305 + -- Aeon Nuke Launcher
             categories.ual0401 + -- Aeon Exp Bot
             categories.uas0401  -- Aeon Exp battleship
    )
 
    SetArmyUnitCap(Cybran, 1500)
    SetArmyUnitCap(Aeon, 1500)
    
    Cinematics.EnterNISMode()
        Cinematics.SetInvincible('AREA_1')
        
        WaitSeconds(1)
                
        ScenarioFramework.Dialogue(OpStrings.IntroP2, nil, true)  

        local VisMarker2_1 = ScenarioFramework.CreateVisibleAreaLocation(80,'P2Vision4', 0, ArmyBrains[Player1])
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P2Cam1'), 3)
        WaitSeconds(2)
        local VisMarker2_2 = ScenarioFramework.CreateVisibleAreaLocation(80,'P2Vision1', 0, ArmyBrains[Player1])
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P2Cam2'), 4)
        WaitSeconds(3)
        local VisMarker2_3 = ScenarioFramework.CreateVisibleAreaLocation(80,'P2Vision2', 0, ArmyBrains[Player1])
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P2Cam3'), 4)
        WaitSeconds(3)
        ForkThread(P2Intattacks)
        local VisMarker2_4 = ScenarioFramework.CreateVisibleAreaLocation(80,'P2Vision3', 0, ArmyBrains[Player1])
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P2Cam4'), 4)
        WaitSeconds(2)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P2Cam5'), 4)
        WaitSeconds(2)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P1Cam4'), 1)

            ForkThread(
                function ()
                    WaitSeconds(1)
                    VisMarker2_1:Destroy()
                    VisMarker2_2:Destroy()
                    VisMarker2_3:Destroy()
                    VisMarker2_4:Destroy()
                    WaitSeconds(1)
                    ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('P2Vision1'), 90)
                    ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('P2Vision2'), 90)
                    ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('P2Vision3'), 90)
                    ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('P2Vision4'), 90)
                end 
            )
            
        Cinematics.SetInvincible('AREA_1', true)
    Cinematics.ExitNISMode()
    
    pcall(IncomebuffsP2)
    ForkThread(ArtybaseP2)
    ForkThread(AeonTacP2)
    ForkThread(MissionP2)

    ScenarioFramework.CreateTimerTrigger(SupportbasesP2, 8*60)
    SetupUEFM2TauntTriggers()
end

function IncomebuffsP2()

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
end

function AeonTacP2()

    local units = ScenarioUtils.CreateArmyGroup('Aeon', 'P2AOuterD_D'.. Difficulty)

    for _, v in units do
        if v and not v:IsDead() and EntityCategoryContains(categories.TACTICALMISSILEPLATFORM, v) then
            local plat = ArmyBrains[UEF]:MakePlatoon('', '')
            ArmyBrains[UEF]:AssignUnitsToPlatoon(plat, {v}, 'Attack', 'NoFormation')
            plat:ForkAIThread(plat.TacticalAI)
            WaitSeconds(4)
        end
    end
end

function SupportbasesP2()

    P2AeonAI.Aeonbase2AI()

    P2CybranAI.Cybranbase2AI()
end

function ArtybaseP2()
 
    AIBuildStructures.CreateBuildingTemplate( ArmyBrains[Aeon], 'Aeon', 'AeonArtybase1' )
    AIBuildStructures.AppendBuildingTemplate(ArmyBrains[Aeon], 'Aeon', 'AeonArtybase', 'AeonArtybase1')
    
    AIBuildStructures.AppendBuildingTemplate( ArmyBrains[Aeon], 'Aeon', 'AeonArtybaseBD', 'AeonArtybase1')
    
    ScenarioUtils.CreateArmyGroup( 'Aeon', 'AeonArtybase')
    
    plat = ScenarioUtils.CreateArmyGroupAsPlatoon( 'Aeon', 'AeonArtybaseENG', 'NoFormation' )
    plat.PlatoonData.MaintainBaseTemplate = 'AeonArtybase1'
    plat.PlatoonData.PatrolChain = 'P2AENG1'
    plat:ForkAIThread(ScenarioPlatoonAI.StartBaseEngineerThread)
end
 
function MissionP2()
    
    ScenarioInfo.M1P2 = Objectives.Kill(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Kill The UEF Commander',                 -- title
        'Eliminate the UEF Commander defending the Jammer.',  -- description
        
        {                               -- target
             MarkUnits = true,
             Units = {ScenarioInfo.UEFACU}
             
          }
   )
    ScenarioInfo.M1P2:AddResultCallback(
    function(result)
        if(result) then
        
         end
    end
    )

    ScenarioInfo.M2P2 = Objectives.Kill(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Destroy the Quantum Jammer',                 -- title
        'We can not begin the process to gate you out without the jammer being destroyed.',  -- description
        
        {                               -- target
             MarkUnits = true,
             Units = {ScenarioInfo.Jammer}
             
          }
    )
   
    ScenarioInfo.M2P2:AddResultCallback(
    function(result)
        if(result) then
        
        end
    end
    )
        
    ScenarioInfo.M2P3 = Objectives.CategoriesInArea(
        'secondary',                      -- type
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
    ScenarioInfo.M2P3:AddResultCallback(
    function(result)
        if(result) then
        
        end
    end
    )
    
    ScenarioFramework.CreateTimerTrigger(SecondaryMissionP2, 1*60)

    ScenarioFramework.CreateTimerTrigger(P2MidDialogue, 14*60)        
    
    if ExpansionTimer then
        local M2MapExpandDelay = {35*60, 30*60, 25*60}
        ScenarioFramework.CreateTimerTrigger(StartPart3, M2MapExpandDelay[Difficulty])
    end
    
    ScenarioInfo.M2Objectives = Objectives.CreateGroup('M2Objectives', StartPart3)
    ScenarioInfo.M2Objectives:AddObjective(ScenarioInfo.M1P2)
    ScenarioInfo.M2Objectives:AddObjective(ScenarioInfo.M2P2)
    if ScenarioInfo.M1P1.Active then
        ScenarioInfo.M2Objectives:AddObjective(ScenarioInfo.M1P1)
    end
end

function P2Intattacks()

    local quantity = {}
    local trigger = {}
    local platoon

    -- Basic Land attack
    for i = 1, 3 do
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Aeon', 'P2AIntattack' .. i .. '_D' .. Difficulty, 'GrowthFormation', 2 + Difficulty)
        ScenarioFramework.PlatoonPatrolChain(platoon, 'P2IntLandattack1')

        platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Cybran', 'P2CIntattack' .. i .. '_D' .. Difficulty, 'GrowthFormation', 2 + Difficulty)
        ScenarioFramework.PlatoonPatrolChain(platoon, 'P2IntLandattack2')

        platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Cybran', 'P2CIntunits1_D' .. Difficulty, 'GrowthFormation', 2 + Difficulty)
        ScenarioFramework.PlatoonPatrolChain(platoon, 'P2IntLandattack'..i)

    end

    --Air attack

    -- sends swift winds if player has more than [60, 50, 40] planes, up to 6, 1 group per 14, 11, 10
    num = ScenarioFramework.GetNumOfHumanUnits(categories.AIR * categories.MOBILE)
    quantity = {40, 30, 20}
    trigger = {15, 13, 10}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 7) then
            num = 7
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Aeon', 'P2AIntIntercept', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P2IntAirattack' .. Random(1, 4))
        end
    end

    -- sends bombers if player has more than [60, 50, 40] Defenses, up to 5, 1 group per 14, 11, 10
    num = ScenarioFramework.GetNumOfHumanUnits(categories.STRUCTURE * categories.DEFENSE - categories.WALL)
    quantity = {30, 25, 20}
    trigger = {14, 12, 10}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 6) then
            num = 6
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Cybran', 'P2CIntBombers', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P2IntAirattack' .. Random(1, 4))
        end
    end

    -- sends Gunships if player has more than [200, 150, 100] Units, up to 7, 1 group per 14, 11, 10
    num = ScenarioFramework.GetNumOfHumanUnits(categories.ALLUNITS - categories.WALL)
    quantity = {200, 150, 100}
    trigger = {30, 25, 20}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 8) then
            num = 8
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('UEF', 'P2UGunships', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P2IntAirattack' .. Random(1, 4))
        end
    end

    -- sends bombers if player has more than [60, 50, 40] Defenses, up to 10, 1 group per 14, 11, 10
    num = ScenarioFramework.GetNumOfHumanUnits(categories.LAND * categories.MOBILE - categories.ENGINEER)
    quantity = {90, 70, 50}
    trigger = {40, 35, 30}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 6) then
            num = 6
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'P2UTransportDrop', 'GrowthFormation')
        ScenarioFramework.PlatoonAttackWithTransports(platoon, 'P2IntDrop', 'P2IntDropattack1', true)
        end
    end

    -- First move ships to the map, then patrol, to make sure they won't shoot from off-map

    -- Subhunters

    -- sends Subhunters if player has more than [30, 20, 10] Naval Units, up to 4, 1 group per 14, 11, 10
    num = ScenarioFramework.GetNumOfHumanUnits(categories.NAVAL * categories.MOBILE)
    quantity = {30, 20, 10}
    trigger = {9, 7, 5}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 4) then
            num = 4
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Cybran', 'P2CIntSub', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P2IntNavalattack' .. Random(1, 2))
        end
    end

    -- Basic Naval
    for i = 1, 2 do
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('UEF', 'P2UNavalattack' .. i .. '_D' .. Difficulty, 'AttackFormation', Difficulty)
        ScenarioFramework.PlatoonPatrolChain(platoon, 'P2IntNavalattack' .. i)
    end

    if Difficulty >= 2 then
        num = ScenarioFramework.GetNumOfHumanUnits(categories.TECH3 * categories.ALLUNITS)
        quantity = {0, 70, 50}
        if num > quantity[Difficulty] then
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('UEF', 'P2UExpattack', 'AttackFormation', 1 + Difficulty)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P2IntLandattack3')
        end
    end
end

--Not in Use yet--
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
--

function SecondaryMissionP2()
     
    ScenarioFramework.Dialogue(OpStrings.Secondary1P2, nil, true)
    
    ScenarioInfo.M1P2S1 = Objectives.CategoriesInArea(
        'secondary',                      -- type
        'incomplete',                     -- complete
        'Destroy the Aeon Artillery ',         -- title
        'Eliminate the Artillery Position.',  -- description
        'kill',                         -- action
        {                               -- target
            MarkUnits = true,
            ShowProgress = true,
            Requirements = {
                        { Area='Arty1', Category = categories.ual0309 + categories.uab2302,
                          CompareOp = '==', Value = 0, ArmyIndex = Aeon },
            },
            Category = categories.uab2302,  --forces icon
        }     
    )  

    ScenarioInfo.M1P2S1:AddResultCallback(
        function(result)
            if(result) then
                ScenarioFramework.Dialogue(OpStrings.Secondary1EndP2, nil, true) 
            end
        end
    )   
end

function P2MidDialogue()

    ScenarioFramework.Dialogue(OpStrings.MidP2, nil, true)
end

function UEFACUdeath()
    
    ScenarioFramework.CDRDeathNISCamera(ScenarioInfo.UEFACU, 3)
    ScenarioFramework.Dialogue(OpStrings.ACUDeath1, nil, true) 
    P2KillUEFBase()
end

function P2KillUEFBase()
    
    local AeonUnits = ScenarioFramework.GetCatUnitsInArea((categories.ALLUNITS), 'AREA_2', ArmyBrains[UEF])
        for k, v in AeonUnits do
            if v and not v.Dead then
                v:Kill()
                WaitSeconds(Random(0.001, 0.003))
            end
        end
end

-- Part 3

function StartPart3()

    if ScenarioInfo.M2P2.Active then
        ForkThread(IntroP3)
    else
        ForkThread(IntroP3)
        ForkThread(MissionP3)
    end
end

function IntroP3()
    
    if ScenarioInfo.MissionNumber == 3 then
        return
    end
    ScenarioInfo.MissionNumber = 3
    
    WaitSeconds(10)
    
    ScenarioFramework.SetPlayableArea('AREA_3', true)
    
    P3CoalitionAI.AeonP3base1AI()
    P3CoalitionAI.UEFP3base1AI()
    P3CoalitionAI.CybranP3base1AI()
    
    ScenarioUtils.CreateArmyGroup('Aeon', 'P3AWalls')
    ScenarioUtils.CreateArmyGroup('Cybran', 'P3CWalls')
    ScenarioUtils.CreateArmyGroup('UEF', 'P3UWalls')
    ScenarioUtils.CreateArmyGroup('UEF', 'P3UPower')
    
                        
    ScenarioFramework.Dialogue(OpStrings.IntroP3, nil, true)
                        
    
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

    buffDef = Buffs['CheatIncome']
    buffAffects = buffDef.Affects
    buffAffects.EnergyProduction.Mult = 1.5
    buffAffects.MassProduction.Mult = 2

       for _, u in GetArmyBrain(UEF):GetPlatoonUniquelyNamed('ArmyPool'):GetPlatoonUnits() do
               Buff.ApplyBuff(u, 'CheatIncome')
       end

    ScenarioFramework.CreateTimerTrigger(SecondaryMissionP3, 2*60)

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
    
    if ScenarioInfo.M1P3.Active then
        return
    end

    ScenarioInfo.M1P3 = Objectives.Timer(
            'primary',                      -- type
            'incomplete',                   -- complete
            'Hold out for Quatum wake dissipation',                 -- title
            'With the Jammer down, you only need to survive 15 minutes.',  -- description
            {                               -- target
                Timer = (15*60),
                ExpireResult = 'complete',
            }
        )

        ScenarioInfo.M1P3:AddResultCallback(
            function(result)
                if result then
                    PlayerWin()
                end
            end
        )
    ScenarioFramework.CreateTimerTrigger(P3FinalAssault, 6*60)
end

function SecondaryMissionP3()
    
    ScenarioInfo.M1P3S1 = Objectives.CategoriesInArea(
        'secondary',                      -- type
        'incomplete',                   -- complete
        'Destroy Coalition Bases',                 -- title
        'Several Bases on the edge of the operational area are seiging your position.',  --description
        'kill',                         -- action
        {                               -- target
            MarkUnits = true,
            ShowProgress = true,
            Requirements = {
                {   
                    Area = 'P3SecObj2',
                    Category = categories.STRUCTURE * categories.FACTORY + categories.TECH3 * categories.STRUCTURE * categories.ECONOMIC + categories.TECH2 * categories.STRUCTURE * categories.ECONOMIC,
                    CompareOp = '<=',
                    Value = 0,
                    ArmyIndex = Cybran,
                },
                {   
                    Area = 'P3SecObj1',
                    Category = categories.STRUCTURE * categories.FACTORY + categories.TECH3 * categories.STRUCTURE * categories.ECONOMIC + categories.TECH2 * categories.STRUCTURE * categories.ECONOMIC,
                    CompareOp = '<=',
                    Value = 0,
                    ArmyIndex = UEF,
                },  
                {   
                    Area = 'P3SecObj3',
                    Category = categories.STRUCTURE * categories.FACTORY + categories.TECH3 * categories.STRUCTURE * categories.ECONOMIC + categories.TECH2 * categories.STRUCTURE * categories.ECONOMIC,
                    CompareOp = '<=',
                    Value = 0,
                    ArmyIndex = Aeon,
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

function P3FinalAssault()
    
    local quantity = {}
    local trigger = {}
    local platoon

    -- Basic EXP attack
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Aeon', 'P3AFinalExp_D' .. Difficulty, 'AttackFormation', 2 + Difficulty)
        ScenarioFramework.PlatoonPatrolChain(platoon, 'P3AFinalExpattack1')

        platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Cybran', 'P3CFinalExp_D' .. Difficulty, 'AttackFormation', 2 + Difficulty)
        ScenarioFramework.PlatoonPatrolChain(platoon, 'P3CFinalExpattack1')


    --Air attack

    for i = 1, 3 do
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('UEF', 'P3UFinalAir' .. i .. '_D' .. Difficulty, 'AttackFormation', Difficulty)
        ScenarioFramework.PlatoonPatrolChain(platoon, 'P3UFinalAirattack' .. i)
    end

    for i = 1, 3 do
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('UEF', 'P3UFinalAir' .. i .. '_D' .. Difficulty, 'AttackFormation', Difficulty)
        ScenarioFramework.PlatoonPatrolChain(platoon, 'P3UFinalAirattack' .. i)
    end

    -- sends swift winds if player has more than [60, 50, 40] planes, up to 7, 1 group per 14, 11, 10
    num = ScenarioFramework.GetNumOfHumanUnits(categories.AIR * categories.MOBILE)
    quantity = {50, 40, 30}
    trigger = {20, 15, 10}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 10) then
            num = 10
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('UEF', 'P3UFinalIntercept', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P3UFinalAirattack' .. Random(1, 3))
        end
    end

    -- Sends [7, 10, 15] Gunships at players' ACUs
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('UEF', 'P3UFinalSnipe_D' .. Difficulty, 'NoFormation', 5)
            IssueAttack(platoon:GetPlatoonUnits(), ScenarioInfo.PlayerCDR)
            IssueAggressiveMove(platoon:GetPlatoonUnits(), ScenarioUtils.MarkerToPosition('Player1'))

    local extractors = ScenarioFramework.GetListOfHumanUnits(categories.MASSEXTRACTION)
    local num = table.getn(extractors)
    quantity = {6, 8, 10}
    if num > 0 then
            if num > quantity[Difficulty] then
                num = quantity[Difficulty]
            end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'P3AFinalGunship2', 'GrowthFormation')
            IssueAttack(platoon:GetPlatoonUnits(), extractors[i])
            IssueAggressiveMove(platoon:GetPlatoonUnits(), ScenarioUtils.MarkerToPosition('Player1'))

            local guard = ScenarioUtils.CreateArmyGroup('Aeon', 'P3AFinalGuard')
            IssueGuard(guard, platoon:GetPlatoonUnits()[1])
        end
    end

    local factory = ScenarioFramework.GetListOfHumanUnits(categories.STRUCTURE * categories.FACTORY)
    local num = table.getn(factory)
    quantity = {3, 4, 5}
    if num > 0 then
            if num > quantity[Difficulty] then
                num = quantity[Difficulty]
            end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'P3CFinalBombers', 'GrowthFormation')
            IssueAttack(platoon:GetPlatoonUnits(), factory[i])
            IssueAggressiveMove(platoon:GetPlatoonUnits(), ScenarioUtils.MarkerToPosition('Player1'))

            local guard = ScenarioUtils.CreateArmyGroup('Cybran', 'P3CFinalGuard')
            IssueGuard(guard, platoon:GetPlatoonUnits()[1])
        end
    end

    local shield = ScenarioFramework.GetListOfHumanUnits(categories.STRUCTURE * categories.SHIELD)
    local num = table.getn(shield)
    quantity = {4, 5, 6}
    if num > 0 then
            if num > quantity[Difficulty] then
                num = quantity[Difficulty]
            end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'P3AFinalGunship1', 'GrowthFormation')
            IssueAttack(platoon:GetPlatoonUnits(), shield[i])
            IssueAggressiveMove(platoon:GetPlatoonUnits(), ScenarioUtils.MarkerToPosition('Player1'))

            local guard = ScenarioUtils.CreateArmyGroup('Aeon', 'P3AFinalGuard')
            IssueGuard(guard, platoon:GetPlatoonUnits()[1])
        end
    end

    -- sends Transports if player has more than [60, 50, 40] Defenses, up to 4, 1 group per 30, 25, 20
    num = ScenarioFramework.GetNumOfHumanUnits(categories.STRUCTURE * categories.DEFENSE - categories.WALL)
    quantity = {40, 30, 20}
    trigger = {25, 20, 15}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 6) then
            num = 6
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'P3CFinalDrop', 'GrowthFormation')
            ScenarioFramework.PlatoonAttackWithTransports(platoon, 'P3CFinalDrop', 'P3FinalDropattack', true)

            platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'P3AFinalDrop', 'GrowthFormation')
            ScenarioFramework.PlatoonAttackWithTransports(platoon, 'P3AFinalDrop', 'P3FinalDropattack', true)

            platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'P3UFinalDrop', 'GrowthFormation')
            ScenarioFramework.PlatoonAttackWithTransports(platoon, 'P3UFinalDrop', 'P3FinalDropattack', true)
        end
    end


    -- Basic Naval
    for i = 1, 2 do
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Cybran', 'P3CFinalNaval' .. i .. '_D' .. Difficulty, 'AttackFormation', Difficulty)
        ScenarioFramework.PlatoonPatrolChain(platoon, 'P3CFinalNavalattack' .. i)
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
    if ScenarioInfo.MissionNumber == 1 then 
    UEFTM:AddEnemiesKilledTaunt('TAUNT2P1', ArmyBrains[UEF], categories.STRUCTURE, 15)
    UEFTM:AddUnitsKilledTaunt('TAUNT1P1', ArmyBrains[UEF], categories.MOBILE * categories.LAND, 50)
    UEFTM:AddUnitsKilledTaunt('TAUNT3P1', ArmyBrains[UEF], categories.STRUCTURE * categories.FACTORY, 4)
        return
    end
end

function SetupUEFM2TauntTriggers()
    if ScenarioInfo.MissionNumber == 2 then 
    UEFTM:AddEnemiesKilledTaunt('TAUNT1P2', ArmyBrains[UEF], categories.STRUCTURE, 15)
    UEFTM:AddUnitsKilledTaunt('TAUNT2P2', ArmyBrains[UEF], categories.LAND * categories.MOBILE, 50)
    UEFTM:AddUnitsKilledTaunt('TAUNT3P2', ArmyBrains[UEF], categories.STRUCTURE * categories.FACTORY, 4)
        return
    end
end

function DestroyUnit(unit)
    unit:Destroy()
end