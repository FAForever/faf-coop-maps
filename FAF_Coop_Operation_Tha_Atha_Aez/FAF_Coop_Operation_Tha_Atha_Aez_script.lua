------------------------------
-- Seraphim Campaign - Mission 2
--
-- Author: Shadowlorda1
--
-- Map Edited By: MadMax
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
local P4CoalitionAI = import('/maps/FAF_Coop_Operation_Tha_Atha_Aez/CoalitionaiP4.lua')
local Buff = import('/lua/sim/Buff.lua')
local OpStrings = import('/maps/FAF_Coop_Operation_Tha_Atha_Aez/FAF_Coop_Operation_Tha_Atha_Aez_strings.lua')
local TauntManager = import('/lua/TauntManager.lua')
local CustomFunctions = import('/maps/FAF_Coop_Operation_Tha_Atha_Aez/FAF_Coop_Operation_Tha_Atha_Aez_CustomFunctions.lua') 

local UEFTM = TauntManager.CreateTauntManager('UEF1TM', '/maps/FAF_Coop_Operation_Tha_Atha_Aez/FAF_Coop_Operation_Tha_Atha_Aez_strings.lua')
local AeonTM = TauntManager.CreateTauntManager('UEF1TM', '/maps/FAF_Coop_Operation_Tha_Atha_Aez/FAF_Coop_Operation_Tha_Atha_Aez_strings.lua')

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

local AIs = {UEF, Aeon}
local BuffCategories = {
    BuildPower = (categories.FACTORY * categories.STRUCTURE) + categories.ENGINEER,
    Economy = categories.ECONOMIC,
}

local AssignedObjectives = {}

local P2Offmaptriggered = false
local ExpansionTimer = ScenarioInfo.Options.Expansion == 'true'

local SupportBtimer = {12*60, 9*60, 6*60}  

local Debug = false
local SkipNIS2 = false
local SkipNIS3 = false
local NIS1InitialDelay = 3

function OnPopulate(scen) 
    ScenarioUtils.InitializeScenarioArmies()
   
    ScenarioFramework.SetSeraphimColor(Player1)
    ScenarioFramework.SetUEFPlayerColor(UEF)
    ScenarioFramework.SetNeutralColor (WarpComs)
    ScenarioFramework.SetAeonPlayerColor (Aeon)
    ScenarioFramework.SetAeonEvilColor (SeraphimAlly2)
    local colors = {
        ['Player2'] = {255, 191, 128}, 
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
    GetArmyBrain(WarpComs):SetResourceSharing(false)
    GetArmyBrain(SeraphimAlly2):SetResourceSharing(false)
    
    SetArmyUnitCap(UEF, 1500)
    SetArmyUnitCap(Aeon, 1500)
    ScenarioFramework.SetSharedUnitCap(4800)
end 

function OnStart(scen)

    ScenarioFramework.AddRestrictionForAllHumans(
        categories.UEF + -- UEF faction 
        categories.CYBRAN + -- Cybran faction
        categories.xsa0402 + -- Super bomber
        categories.xsb0304 + -- Seraph Gate
        categories.xsl0301 + -- Seraph sACU
        categories.xsb2302 + -- T3 Arty
        categories.uaa0310 + -- Aeon Exp Carrier
        categories.uab0304 + -- Aeon Gate
        categories.xab2307 + -- Aeon EXP arty
        categories.ual0301 + -- Aeon sACU
        categories.xab1401 + -- Aeon exp Generator
        categories.uab2302 + -- Aeon T3 Arty
        categories.xsb2401  -- Super Nuke
    )

    for _, army in AIs do
        ArmyBrains[army].IMAPConfig = {
                OgridRadius = 0,
                IMAPSize = 0,
                Rings = 0,
        }
        ArmyBrains[army]:IMAPConfiguration()
    end

    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Commanderwarp'), 0)
    
    ForkThread(IntroP1)
end

--Part 1

function IntroP1()

    ScenarioInfo.MissionNumber = 1

    ScenarioFramework.SetPlayableArea('AREA_1', false)
    
    ScenarioUtils.CreateArmyGroup('UEF', 'P1energy')
    
    ScenarioUtils.CreateArmyGroup('Player1', 'P1Pbase1_D'.. Difficulty)
    ScenarioUtils.CreateArmyGroup('WarpComs', 'Pintbasewreak', true)
    ScenarioUtils.CreateArmyGroup('WarpComs', 'Gatebase1')
    ScenarioInfo.M1ObjectiveGate = ScenarioUtils.CreateArmyUnit('WarpComs', 'Gate1')
    
    local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'P1CutsceneUnits', 'GrowthFormation')
    for k, v in platoon:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P1UCutsceneattack')))
    end
    
    Cinematics.EnterNISMode()
    
        local VisMarkerP1_1 = ScenarioFramework.CreateVisibleAreaLocation(100, 'P1Vision1', 0, ArmyBrains[Player1])
    
        WaitSeconds(1)
        ScenarioInfo.Player1CDR = ScenarioFramework.SpawnCommander('Player1', 'Commander', 'Gate', true, true, PlayerDeath)
    
        -- spawn coop players too
        ScenarioInfo.CoopCDR = {}
        local tblArmy = ListArmies()
        coop = 1
        for iArmy, strArmy in pairs(tblArmy) do
            if iArmy >= ScenarioInfo.Player2 then
                factionIdx = GetArmyBrain(strArmy):GetFactionIndex()
                if (factionIdx == 2) then
                    ScenarioInfo.CoopCDR[coop] = ScenarioFramework.SpawnCommander(strArmy, 'ACommander', 'Warp', true, true, PlayerDeath)
                else
                    ScenarioInfo.CoopCDR[coop] = ScenarioFramework.SpawnCommander(strArmy, 'Commander', 'Warp', true, true, PlayerDeath)
                end
                coop = coop + 1
                WaitSeconds(0.5)
            end
        end
    
        local cmd = IssueMove({ScenarioInfo.Player1CDR}, ScenarioUtils.MarkerToPosition('ComMove'))
 
        ScenarioFramework.Dialogue(OpStrings.IntroP1, nil, true)
    
        WaitSeconds(2)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Pintattackcam1'), 3)
        WaitSeconds(1)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Pintattackcam2'), 3)
        WaitSeconds(1)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Pintattackcam3'), 3)
        WaitSeconds(1)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Commanderwarp'), 2)

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
    
    local function MissionNameAnnouncement()
        ScenarioFramework.SimAnnouncement(ScenarioInfo.name, "Mission by Shadowlorda1 and Map by MadMax")
    end

    ScenarioFramework.CreateTimerTrigger(MissionNameAnnouncement, 12)

    ScenarioInfo.M2P1 = Objectives.Protect(
        'primary',                      -- type
        'incomplete',                   -- complete
        'The Gate Must Survive',                -- title
        'Without the gate the retreat is over.', -- description
       
        {                              -- target
            MarkUnits = true,
            Units = {ScenarioInfo.M1ObjectiveGate}, 
        }
    )
    ScenarioInfo.M2P1:AddResultCallback(
        function(result, unit)
            if (not result and not ScenarioInfo.OpEnded) then
                ScenarioFramework.CDRDeathNISCamera(unit)
                ScenarioFramework.EndOperationSafety()

                ScenarioFramework.FlushDialogueQueue()
                ScenarioFramework.Dialogue(OpStrings.Comsdeath, PlayerLose, true)
            end
        end
    )

    ScenarioInfo.M1P1 = Objectives.Basic(
        'primary',
        'incomplete',
        'Prepare for UEF Assault',                -- title
        'UEF forces are inbound, you only have a few minutes to prepare.', -- description
        Objectives.GetActionIcon('kill'),
        {
        ShowFaction = 'UEF',
        }
    )

    ScenarioFramework.CreateTimerTrigger(IntAssaultP1, 20)

    WaitSeconds(60)
    ScenarioFramework.Dialogue(OpStrings.UEFReveal1, nil, true)
end

function IntAssaultP1()
    if not SkipNIS2 then

        WaitSeconds(2*60)

        ScenarioInfo.M1P1:ManualResult(true)

        ScenarioFramework.Dialogue(OpStrings.AssaultP1, nil, true)
        
        ScenarioInfo.M1CounterAttackUnits = {}

        local quantity = {}
        local trigger = {}
        local platoon

        local function AddUnitsToObjTable(platoon)
            for _, v in platoon:GetPlatoonUnits() do
                if not EntityCategoryContains(categories.TRANSPORTATION + categories.SCOUT + categories.SHIELD, v) then
                    table.insert(ScenarioInfo.M1CounterAttackUnits, v)
                end
            end
        end

        -- Air attack

        -- Basic air attack
        for i = 1, 3 do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('UEF', 'P1UAirattack1_D' .. Difficulty, 'AttackFormation', 2 + Difficulty)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P1UAirattack' .. i)
            AddUnitsToObjTable(platoon)
        end

        for i = 1, 3 do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('UEF', 'P1UAirattack2_D' .. Difficulty, 'AttackFormation', 2 + Difficulty)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P1UAirattackN' .. i)
            AddUnitsToObjTable(platoon)
        end

        -- Sends fighters if players has more than [20, 15, 10] air fighters
        num = ScenarioFramework.GetNumOfHumanUnits(categories.AIR * categories.MOBILE - categories.SCOUT)
        quantity = {15, 10, 5}
        trigger = {15, 10, 5}
        if num > quantity[Difficulty] then
            num = math.ceil(num/trigger[Difficulty])
            if(num > 3) then
                num = 3
            end
            for i = 1, num do
                platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('UEF', 'P1UIntercept', 'AttackFormation', 2 + Difficulty)
                for k, v in platoon:GetPlatoonUnits() do
                    ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P1UDropattack')))
                end
                AddUnitsToObjTable(platoon)
            end
            
        end
    
        for i = 1, 3 do
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'P1UDrop'.. i .. '_D' .. Difficulty, 'AttackFormation')
            CustomFunctions.PlatoonAttackWithTransports(platoon, 'P1UDrop' .. i, 'P1UDropattack', 'P2UB1MK', true)
            AddUnitsToObjTable(platoon)
        end

        ForkThread(IntAssaultMissionP1)
        
    else
        IntroP2()
    end
end

function IntAssaultMissionP1()

    ScenarioInfo.M3P1 = Objectives.Kill(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Survive Second UEF Assault',                 -- title
        'Kill all UEF forces attacking your position.',  -- description
        {                               -- target
            ShowProgress = true,
            Units = ScenarioInfo.M1CounterAttackUnits     
        }
    
    )
    ScenarioInfo.M3P1:AddResultCallback(
        function(result)
            if result then
                ScenarioFramework.Dialogue(OpStrings.AssaultEndP1, IntroP2, true)
            end
        end
    )

    ScenarioFramework.CreateTimerTrigger(IntroP2, 3*60)
end

--Part 2

function IntroP2()
    ScenarioFramework.FlushDialogueQueue()
    
    if ScenarioInfo.MissionNumber ~= 1 then
        return
    end
    ScenarioInfo.MissionNumber = 2

    ScenarioFramework.SetPlayableArea('AREA_2', true)

    P2SERAAI.SeraphimBaseAI()
    P2AEONAI.AeonBase1AI()
    P2AEONAI.AeonBase2AI()
    P2UEFAI.P2UEFbase1AI()
    P2UEFAI.P2UEFbase2AI()

    if Difficulty == 3 then
        ArmyBrains[UEF]:PBMSetCheckInterval(6)
    end

    if ScenarioInfo.M1P1.Active then
        ScenarioInfo.M1P1:ManualResult(true)
    end
    
    ScenarioUtils.CreateArmyGroup('Aeon', 'P2AbaseWalls')
    ScenarioUtils.CreateArmyGroup('UEF', 'P2UWalls')

    ScenarioUtils.CreateArmyGroup('SeraphimAlly', 'SeraDefenses')

    ScenarioUtils.CreateArmyGroup('WarpComs', 'Gatebase2')
    ScenarioInfo.M2ObjectiveGate = ScenarioUtils.CreateArmyUnit('WarpComs', 'Gate2')
    
    ScenarioInfo.SeraACU = ScenarioFramework.SpawnCommander('SeraphimAlly', 'SeraCom', false, 'Vuth-Vuthroz', false, false,
        {'AdvancedEngineering', 'DamageStabilization', 'RateOfFire'})
        ScenarioInfo.SeraACU:SetAutoOvercharge(true)
        ScenarioInfo.SeraACU:SetVeterancy(5 - Difficulty)

    ScenarioInfo.SeraACU:AddBuildRestriction(categories.xsb2301 + categories.xsb2304 + categories.xsb2104 + categories.xsb1103 + categories.xsb1106 + categories.xsb1105 + categories.xsb1201 + categories.xsb2101 + categories.xsb5101)
    
    ArmyBrains[SeraphimAlly]:PBMSetCheckInterval(6)
    
    local units = ScenarioUtils.CreateArmyGroupAsPlatoon('SeraphimAlly', 'SApatrolG2', 'AttackFormation')
    for _, v in units:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P2S1B1defence1')))
    end
   
    units = ScenarioUtils.CreateArmyGroupAsPlatoon('SeraphimAlly', 'SApatrolG1', 'AttackFormation')
    for _, v in units:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P2S1B1defence2')))
    end
   
    units = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'P2ACutsceneattack', 'GrowthFormation')
    for _, v in units:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolChain({v}, 'P2Aintattack1')
    end
   
    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Commanderwarp'), 0)
    
    ScenarioFramework.Dialogue(OpStrings.IntroP2, nil, true)
   
    Cinematics.EnterNISMode()
        Cinematics.SetInvincible('AREA_1')
   
        local VisMarker2_1 = ScenarioFramework.CreateVisibleAreaLocation(50, 'P2Vision1', 0, ArmyBrains[Player1])
        local VisMarker2_2 = ScenarioFramework.CreateVisibleAreaLocation(50, 'P2Vision2', 0, ArmyBrains[Player1])
   
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P2Cam1'), 4)
        WaitSeconds(3)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P2Cam2'), 4)
        WaitSeconds(3)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P2Cam3'), 3)
        WaitSeconds(3)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P2Cam4'), 5)
        WaitSeconds(3)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Commanderwarp'), 1)
        ForkThread(
            function()
                WaitSeconds(1)
                VisMarker2_1:Destroy()
                VisMarker2_2:Destroy()
                WaitSeconds(1)
                ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('P2Vision1'), 60)
                ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('P2Vision2'), 60)
            end
        )
        Cinematics.SetInvincible('AREA_1', true)
    Cinematics.ExitNISMode()
    
    buffDef = Buffs['CheatIncome']
    buffAffects = buffDef.Affects
    buffAffects.EnergyProduction.Mult = 1.5
    buffAffects.MassProduction.Mult = 2

       for _, u in GetArmyBrain(UEF):GetPlatoonUniquelyNamed('ArmyPool'):GetPlatoonUnits() do
               Buff.ApplyBuff(u, 'CheatIncome')
       end

       for _, u in GetArmyBrain(Aeon):GetPlatoonUniquelyNamed('ArmyPool'):GetPlatoonUnits() do
               Buff.ApplyBuff(u, 'CheatIncome')
       end

    ArmyBrains[UEF]:GiveResource('MASS', 4000)
    ArmyBrains[UEF]:GiveResource('ENERGY', 6000) 
     
    ArmyBrains[Aeon]:GiveResource('MASS', 4000)
    ArmyBrains[Aeon]:GiveResource('ENERGY', 6000)

    ArmyBrains[SeraphimAlly]:GiveResource('MASS', 4000)
    ArmyBrains[SeraphimAlly]:GiveResource('ENERGY', 6000) 
    
    ForkThread(MissionP2)

    SetupUEFP2TauntTriggers()

    ScenarioFramework.CreateTimerTrigger(AeonRevealP2, 60)

    ScenarioFramework.CreateTimerTrigger(SecondaryMissionP2, 3*60)

    ScenarioFramework.CreateTimerTrigger(SecondaryMissionAeonP2, 5*60)

    ScenarioFramework.CreateTimerTrigger(SupportBasesP2, SupportBtimer[Difficulty])

    for _, player in ScenarioInfo.HumanPlayers do
    ScenarioFramework.CreateAreaTrigger(P2UOffmapattacks, 'P2DefenseArea', categories.EXPERIMENTAL * categories.MOBILE, true, false, ArmyBrains[player], 1)
    end

    for _, player in ScenarioInfo.HumanPlayers do
    ScenarioFramework.CreateAreaTrigger(P2UOffmapattacks, 'P2DefenseArea', categories.STRUCTURE * categories.DEFENSE - categories.WALL, true, false, ArmyBrains[player], 15)
    end

    for _, player in ScenarioInfo.HumanPlayers do
    ScenarioFramework.CreateAreaTrigger(P2UOffmapattacks, 'P2DefenseArea', categories.LAND * categories.MOBILE - categories.TECH1, true, false, ArmyBrains[player], 30)
    end
end

function MissionP2()
   
    ScenarioInfo.M1P2 = Objectives.CategoriesInArea(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Clear the Area',                 -- title
        'Destroy all UEF Bases in the area.',  -- description
        'kill',                         -- action
        {                               -- target
            MarkUnits = true,
            ShowProgress = true,
            ShowFaction = 'UEF',
            Requirements = {
                {   
                    Area = 'P2UObj1',
                    Category = categories.FACTORY + categories.TECH3 * categories.STRUCTURE * categories.ECONOMIC + categories.TECH2 * categories.STRUCTURE * categories.ECONOMIC,
                    CompareOp = '<=',
                    Value = 0,
                    ArmyIndex = UEF,
                },
                {   
                    Area = 'P2UObj2',
                    Category = categories.FACTORY + categories.TECH3 * categories.STRUCTURE * categories.ECONOMIC + categories.TECH2 * categories.STRUCTURE * categories.ECONOMIC,
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
                if ScenarioInfo.MissionNumber == 2 then
                    ScenarioFramework.Dialogue(OpStrings.CompleteP2, EscortACU1, true)
                end
            end
        end
    )
    
    ScenarioInfo.M2P2 = Objectives.Protect(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Assist Vuth',                -- title
        'Vuth is defending the retreat gate help him when able.', -- description
        {                              -- target
            MarkUnits = true,
            Units = {ScenarioInfo.SeraACU, ScenarioInfo.M2ObjectiveGate} 
        }
    )
    ScenarioInfo.M2P2:AddResultCallback(
        function(result, unit)
            if (not result and not ScenarioInfo.OpEnded) then
                ScenarioFramework.CDRDeathNISCamera(unit)
                ScenarioFramework.EndOperationSafety()

                ScenarioFramework.FlushDialogueQueue()
                ScenarioFramework.Dialogue(OpStrings.Comsdeath, PlayerLose, true)
            end
        end
    ) 

    if ExpansionTimer then
        local M2MapExpandDelay = {50*60, 35*60, 30*60}
        ScenarioFramework.CreateTimerTrigger(EscortACU1, M2MapExpandDelay[Difficulty])  
    end  
end

function AeonRevealP2()

    ScenarioFramework.Dialogue(OpStrings.AeonReveal1, nil, true)

    SetupAeonP2TauntTriggers()
end

function SecondaryMissionAeonP2()

    ScenarioFramework.Dialogue(OpStrings.SecondaryObjP2, nil, true)

    WaitSeconds(5)

    ScenarioInfo.S1P2 = Objectives.CategoriesInArea(
        'secondary',                      -- type
        'incomplete',                   -- complete
        'Destroy Aeon Support Base',                -- title
        'Destroy the Aeon support base to help your ally', -- description
        'kill',
        {                              -- target
            MarkUnits = true,
            ShowProgress = true,
            ShowFaction = 'Aeon',
            Requirements = {
                {   
                    Area = 'P2AbaseSec1',
                    Category = categories.FACTORY + categories.TECH3 * categories.STRUCTURE * categories.ECONOMIC + categories.TECH2 * categories.STRUCTURE * categories.ECONOMIC,
                    CompareOp = '<=',
                    Value = 0,
                    ArmyIndex = Aeon,
                },
            },
        }
    )
    ScenarioInfo.S1P2:AddResultCallback(
        function(result)
            if result then
               ScenarioFramework.Dialogue(OpStrings.SecondaryObjEndP2, nil, true)
            end 
        end
    )
end

function SupportBasesP2()

    P2UEFAI.P2UEFbase3AI()
    P2UEFAI.P2UEFbase4AI()
end

function SecondaryMissionP2()
     
    ScenarioFramework.Dialogue(OpStrings.SecondaryObj2P2, nil, true)

    WaitSeconds(3)

    local Nodeunits = ScenarioFramework.GetCatUnitsInArea((categories.ALLUNITS - categories.xsb0304), 'EvacZone', ArmyBrains[WarpComs])
        for k, v in Nodeunits do
            if v and not v:IsDead() and (v:GetAIBrain() == ArmyBrains[WarpComs]) then
                ScenarioFramework.GiveUnitToArmy( v, Player1 )
            end
        end
        
    ScenarioInfo.S2P2 = Objectives.CategoriesInArea(
    'secondary',
    'incomplete',
    'Upgrade the Shields',                 -- title
    'Upgrade the two shield generators to T3 to better protect the exit gate.',
    'build',
    {
        MarkArea = true,
        Requirements = {
            {   
                Area = 'M2_Shield_Area_1',
                Category = categories.xsb4301,
                CompareOp = '>=',
                Value = 1,
                Armies = {'HumanPlayers'},
            },
            {   
                Area = 'M2_Shield_Area_2',
                Category = categories.xsb4301,
                CompareOp = '>=',
                Value = 1,
                Armies = {'HumanPlayers'},
            },
        },
    }
    )
    ScenarioInfo.S2P2:AddResultCallback(
        function(result)
            if result then
                ScenarioFramework.Dialogue(OpStrings.SecondaryObj2EndP2, nil, true)
            end
        end
    )      
end

function P2UOffmapattacks()
    if (not P2Offmaptriggered) then
        P2Offmaptriggered = true
        WaitSeconds(60)   
        while ScenarioInfo.MissionNumber == 2 do
        
            local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'P2UOffmapattackDrop_D' .. Difficulty, 'AttackFormation')
            ScenarioFramework.PlatoonAttackWithTransports(platoon, 'P2UOffmapattackDrop', 'P2UOffmapattackDropA', false)

            platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'P2UOffmapattack1_D' .. Difficulty, 'GrowthFormation')
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P2UOffmapattack1')

            WaitSeconds(Random(160, 280))
        end
    end
end

--First batch of commanders

function EscortACU1()
    ScenarioFramework.FlushDialogueQueue()
    
    if ScenarioInfo.MissionNumber ~= 2 then
        return
    end
    ScenarioInfo.MissionNumber = 3

    if not SkipNIS3 then
        
        ScenarioInfo.ComACUs = {}

        ScenarioInfo.AeonACU1 = ScenarioFramework.SpawnCommander('WarpComs', 'G1U1', 'Gate', 'Havra', false, false,
            {'CrysalisBeam', 'HeatSink', 'Shield', 'ShieldHeavy'})
            ScenarioInfo.AeonACU1:SetVeterancy(5 - Difficulty)
            ScenarioFramework.GroupMoveChain({ScenarioInfo.AeonACU1}, 'WarpComChain1')
            table.insert(ScenarioInfo.ComACUs, ScenarioInfo.AeonACU1)

        WaitSeconds(5)

        ScenarioInfo.AeonACU2 = ScenarioFramework.SpawnCommander('WarpComs', 'G1U2', 'Gate', 'Oum-Eoshi', false, false,
            {'AdvancedRegenAura', 'DamageStabilization', 'DamageStabilizationAdvanced', 'RateOfFire'})
            ScenarioInfo.AeonACU2:SetVeterancy(5 - Difficulty)
            ScenarioFramework.GroupMoveChain({ScenarioInfo.AeonACU2}, 'WarpComChain1')
            table.insert(ScenarioInfo.ComACUs, ScenarioInfo.AeonACU2)

        Cinematics.EnterNISMode()
            Cinematics.SetInvincible('AREA_2')

            Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('GateCam1'), 0)
            WaitSeconds(5)

            ScenarioInfo.AeonACU3 = ScenarioFramework.SpawnCommander('WarpComs', 'G1U3', 'Gate', 'Zertha', false, false,
                {'CrysalisBeam', 'Shield', 'ShieldHeavy', 'HeatSink'}) 
                ScenarioInfo.AeonACU3:SetVeterancy(5 - Difficulty)
                ScenarioFramework.GroupMoveChain({ScenarioInfo.AeonACU3}, 'WarpComChain1')
                table.insert(ScenarioInfo.ComACUs, ScenarioInfo.AeonACU3)

            Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Commanderwarp'), 1)

            Cinematics.SetInvincible('AREA_2', true)
        Cinematics.ExitNISMode() 

         ScenarioFramework.Dialogue(OpStrings.UEFTaunt4, nil, true)

        ForkThread(MissionEscortP2)

    else 
        ForkThread(IntroP3)
    end
end

function MissionEscortP2()

    ScenarioInfo.M3P2 = Objectives.SpecificUnitsInArea(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Protect the retreating commanders',                -- title
        'We need every commander we can get, defend them at all costs.', -- description
        {                              -- target
            MarkUnits = true,
            Units = ScenarioInfo.ComACUs,
            Area = 'EvacZone',
        }
    )
   
    ScenarioInfo.M3P2:AddResultCallback(
        function(result, unit)
            if (not result and not ScenarioInfo.OpEnded) then
                ScenarioFramework.CDRDeathNISCamera(unit)
                ScenarioFramework.EndOperationSafety()

                ScenarioFramework.FlushDialogueQueue()
                ScenarioFramework.Dialogue(OpStrings.Comsdeath, PlayerLose, true)
            end

            if result then
                ScenarioFramework.FakeTeleportUnit(ScenarioInfo.AeonACU1, true)
                ScenarioFramework.FakeTeleportUnit(ScenarioInfo.AeonACU2, true)
                ScenarioFramework.FakeTeleportUnit(ScenarioInfo.AeonACU3, true)

                ForkThread(EscortACU2) 
            end
        end
    )
    
    ForkThread(Failsafe1)

    ForkThread(UEFInterceptattacksP2)
end

function Failsafe1()
    
    WaitSeconds(4*60)
    if ScenarioInfo.M3P2.Active then
        ScenarioInfo.M3P2:ManualResult(true)   
    end
end

function UEFInterceptattacksP2()

    local quantity = {}
    local trigger = {}
    local platoon

    -- Basic air attack

    WaitSeconds(30)

    for _, v in ScenarioInfo.ComACUs do
        if not v:IsDead() then
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('UEF', 'P2UComAttackSnipe_D' .. Difficulty, 'NoFormation', 5)
            IssueAttack(platoon:GetPlatoonUnits(), v)
            IssueAggressiveMove(platoon:GetPlatoonUnits(), ScenarioUtils.MarkerToPosition('Player1'))   
        end
    end

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'P2UComAttackDrop_D'.. Difficulty, 'GrowthFormation')
    CustomFunctions.PlatoonAttackWithTransports(platoon, 'P2UComDrop', 'P2UComDropattack', 'P3UB1MK', true)

    WaitSeconds(40)

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'P2UComAttackDrop_D'.. Difficulty, 'GrowthFormation')
    CustomFunctions.PlatoonAttackWithTransports(platoon, 'P2UComDrop2', 'P2UComDropattack', 'P3UB1MK', true)

    WaitSeconds(40)

    -- sends ASF if player has more than [30, 20, 10] Air, up to 3, 1 group per 3, 2, 1
    num = ScenarioFramework.GetNumOfHumanUnits(categories.AIR * categories.MOBILE)
    quantity = {55, 35, 25}
    trigger = {40, 30, 20}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 3) then
            num = 3
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('UEF', 'P2UComAttackintercept', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P2UComAttack' .. i)
            WaitSeconds(2)
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('UEF', 'P2UComAttackintercept', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P2UComAttack' .. i)
        end
    end

    WaitSeconds(3)

    -- sends Gunships if player has more than [60, 50, 40] Units, up to 10, 1 group per 14, 11, 10
    num = ScenarioFramework.GetNumOfHumanUnits(categories.ALLUNITS - categories.WALL)
    quantity = {300, 250, 200}
    trigger = {200, 150, 100}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 3) then
            num = 3
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('UEF', 'P2UComAttackGunships', 'GrowthFormation', 2 + Difficulty)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P2UComAttack' .. i)
            WaitSeconds(2)
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('UEF', 'P2UComAttackGunships', 'GrowthFormation', 2 + Difficulty)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P2UComAttack' .. i)
        end
    end

    WaitSeconds(3)

    -- sends Strats if player has more than [40, 30, 20] Land Units, up to 6, 1 group per 14, 12, 10
    num = ScenarioFramework.GetNumOfHumanUnits(categories.STRUCTURE * categories.DEFENSE - categories.TECH1)
    quantity = {90, 70, 50}
    trigger = {70, 50, 30}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 3) then
            num = 3
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('UEF', 'P2UComAttackBombers', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P2UComAttack' .. i)
            WaitSeconds(2)
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('UEF', 'P2UComAttackBombers', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P2UComAttack' .. i)
        end
    end
end

--Second batch of commanders

function EscortACU2()

    WaitSeconds(10)

    ScenarioInfo.ComACU2s = {}

    ScenarioInfo.AeonACUG1 = ScenarioFramework.SpawnCommander('WarpComs', 'G1U4', 'Gate', 'Zorez-thooum', false, false,
        {'DamageStabilization', 'RateOfFire', 'RegenAura'})
        ScenarioInfo.AeonACUG1:SetVeterancy(4 - Difficulty)
        ScenarioFramework.GroupMoveChain({ScenarioInfo.AeonACUG1}, 'WarpComChain1')
        table.insert(ScenarioInfo.ComACU2s, ScenarioInfo.AeonACUG1)

    WaitSeconds(5)

    ScenarioInfo.AeonACUG2 = ScenarioFramework.SpawnCommander('WarpComs', 'G1U5', 'Gate', 'Thuma-thooum', false, false,
        {'DamageStabilization', 'RateOfFire', 'RegenAura'})
        ScenarioInfo.AeonACUG2:SetVeterancy(4 - Difficulty)
        ScenarioFramework.GroupMoveChain({ScenarioInfo.AeonACUG2}, 'WarpComChain1')
        table.insert(ScenarioInfo.ComACU2s, ScenarioInfo.AeonACUG2)

    Cinematics.EnterNISMode()
        Cinematics.SetInvincible('AREA_2')

        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('GateCam1'), 0)

        WaitSeconds(5)

        ScenarioInfo.AeonACUG3 = ScenarioFramework.SpawnCommander('WarpComs', 'G1U6', 'Gate', 'Keleana', false, false,
            {'CrysalisBeam', 'Shield', 'HeatSink'})
            ScenarioInfo.AeonACUG3:SetVeterancy(4 - Difficulty)
            ScenarioFramework.GroupMoveChain({ScenarioInfo.AeonACUG3}, 'WarpComChain1')
            table.insert(ScenarioInfo.ComACU2s, ScenarioInfo.AeonACUG3)

        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Commanderwarp'), 1)

        Cinematics.SetInvincible('AREA_2', true)
    Cinematics.ExitNISMode()

    ForkThread(MissionEscort2P2) 
end

function MissionEscort2P2()

    ScenarioInfo.M4P2 = Objectives.SpecificUnitsInArea(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Protect Retreating Commanders',                -- title
        'We need every able commander, defend them at all costs.', -- description    
        {                              -- target
            MarkUnits = true,
            Units = ScenarioInfo.ComACU2s,
            Area = 'EvacZone',
        }
    )
   
    ScenarioInfo.M4P2:AddResultCallback(
        function(result, unit)
            if(not result and not ScenarioInfo.OpEnded) then
                ScenarioFramework.CDRDeathNISCamera(unit)
                ScenarioFramework.EndOperationSafety()

                ScenarioFramework.FlushDialogueQueue()
                ScenarioFramework.Dialogue(OpStrings.Comsdeath, PlayerLose, true)
            end

            if result then
                ScenarioFramework.FakeTeleportUnit(ScenarioInfo.AeonACUG1, true)
                ScenarioFramework.FakeTeleportUnit(ScenarioInfo.AeonACUG2, true)
                ScenarioFramework.FakeTeleportUnit(ScenarioInfo.AeonACUG3, true)

                ForkThread(IntroP3)
            end
        end
    )
    
    ScenarioInfo.M2P2:ManualResult(true)
    ---------------------------------
    -- Bonus Objective - Zuth Survives
    ---------------------------------
    ScenarioInfo.M2B2 = Objectives.Protect(
        'bonus',
        'incomplete',
        'Have Mercy, my lord',
        'Make sure Zuth survives the mission',
        {                              -- target
            Units = {ScenarioInfo.SeraACU} 
        }
    )

    ForkThread(Failsafe2)
    ForkThread(AeonInterceptattacksP2)
end

function Failsafe2()
    
    WaitSeconds(4*60)
    if ScenarioInfo.M4P2.Active then
        ScenarioInfo.M4P2:ManualResult(true)
    end
end

function AeonInterceptattacksP2()

    local quantity = {}
    local trigger = {}
    local platoon

    -- Basic air attack

    WaitSeconds(40)

    for _, v in ScenarioInfo.ComACU2s do
        if not v:IsDead() then
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Aeon', 'P2AComAttackSnipe_D' .. Difficulty, 'NoFormation', 5)
            IssueAttack(platoon:GetPlatoonUnits(), v)
            IssueAggressiveMove(platoon:GetPlatoonUnits(), ScenarioUtils.MarkerToPosition('Player1')) 
        end  
    end

    WaitSeconds(30)

    for _, v in ScenarioInfo.ComACU2s do
        if not v:IsDead() then
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Aeon', 'P2AComAttackSnipe2_D' .. Difficulty, 'NoFormation', 5)
            IssueAttack(platoon:GetPlatoonUnits(), v)
            IssueAggressiveMove(platoon:GetPlatoonUnits(), ScenarioUtils.MarkerToPosition('Player1'))
        end
    end

    WaitSeconds(30)

    for _, v in ScenarioInfo.ComACU2s do
        if not v:IsDead() then
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Aeon', 'P2AComAttackSnipe_D' .. Difficulty, 'NoFormation', 5)
            IssueAttack(platoon:GetPlatoonUnits(), v)
            IssueAggressiveMove(platoon:GetPlatoonUnits(), ScenarioUtils.MarkerToPosition('Player1')) 
        end  
    end

    for i = 1, 3 do
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Aeon', 'P2AComAttackland' .. i .. '_D' .. Difficulty, 'GrowthFormation', 2 + Difficulty)
        ScenarioFramework.PlatoonPatrolChain(platoon, 'P2AComAttack' .. i)
    end

    WaitSeconds(10)

    -- sends ASF if player has more than [30, 20, 10] Air, up to 5, 1 group per 20, 15, 10
    num = ScenarioFramework.GetNumOfHumanUnits(categories.AIR * categories.MOBILE)
    quantity = {30, 20, 10}
    trigger = {20, 15, 10}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 3) then
            num = 3
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Aeon', 'P2AComAttackIntercept', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P2AComAttack' .. i)
            WaitSeconds(2)
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Aeon', 'P2AComAttackIntercept', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P2AComAttack' .. i)
        end
    end

    WaitSeconds(5)

    -- sends Drops if player has more than [60, 50, 40] Units, up to 10, 1 group per 14, 11, 10
    num = ScenarioFramework.GetNumOfHumanUnits(categories.ALLUNITS - categories.WALL)
    quantity = {300, 250, 200}
    trigger = {200, 150, 100}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 5) then
            num = 5
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'P2AComAttackDrop_D'.. Difficulty, 'GrowthFormation')
            CustomFunctions.PlatoonAttackWithTransports(platoon, 'P2AComDrop', 'P2AComDropattack', 'P2AB1MK', true)
        end
    end
end

--Part 3

function IntroP3()
    ScenarioFramework.FlushDialogueQueue()
    
    WaitSeconds(10)
    if ScenarioInfo.MissionNumber ~= 3 then
        return
    end
    ScenarioInfo.MissionNumber = 4

    ScenarioFramework.SetPlayableArea('AREA_3', true)

    -- Part 3 Enemy bases

    P3UEFAI.P3UEFbase1AI()
    P3UEFAI.P3UEFbase2AI()
    P3UEFAI.P3UEFbase3AI()
    P2AEONAI.AeonBase3AI()
    P2AEONAI.P3Aattacks()
    P3SERAAI.OrderBase1AI()
    
    ScenarioFramework.Dialogue(OpStrings.IntroP3, nil, true)

    --Spawn UEF ACU

    ScenarioInfo.UEFACU = ScenarioFramework.SpawnCommander('UEF', 'UEFCom', false, 'Colonel Griff', true, false,
        {'AdvancedEngineering', 'T3Engineering', 'Shield', 'ShieldGeneratorField', 'HeavyAntiMatterCannon'})
        ScenarioInfo.UEFACU:SetAutoOvercharge(true)
        ScenarioInfo.UEFACU:SetVeterancy(2 + Difficulty)

    --Spawn Aeon ACU

    ScenarioInfo.AEONACU = ScenarioFramework.SpawnCommander('Aeon', 'AeonCom', false, 'Crusader Thaila', true, false,
        {'Shield', 'ShieldHeavy', 'CrysalisBeam', 'EnhancedSensors'})
        ScenarioInfo.AEONACU:SetAutoOvercharge(true)
        ScenarioInfo.AEONACU:SetVeterancy(2 + Difficulty)

    ScenarioUtils.CreateArmyGroup('WarpComs', 'P3CivilanbaseWrek', true)
    ScenarioUtils.CreateArmyGroup('WarpComs', 'Gatebase3')
    ScenarioUtils.CreateArmyGroup('SeraphimAlly2', 'SA2Walls')
    ScenarioUtils.CreateArmyGroup('UEF', 'P3UEFwalls')
    ScenarioUtils.CreateArmyGroup('UEF', 'P3UDefenses_D'.. Difficulty)
    ScenarioUtils.CreateArmyGroup('Aeon', 'P3AbaseWalls')

    ScenarioInfo.P3SecObj1 = ScenarioUtils.CreateArmyUnit('UEF', 'P3SecObj1')

    ScenarioInfo.P3SecObj2 = ScenarioUtils.CreateArmyUnit('UEF', 'P3SecObj2')

    ScenarioInfo.M3ObjectiveGate = ScenarioUtils.CreateArmyUnit('WarpComs', 'Gate3')
    
    ScenarioInfo.SeraACU2 = ScenarioFramework.SpawnCommander('SeraphimAlly2', 'SeraCom2', false, 'Executor Jareth', false, false,
        {'T3Engineering', 'Shield', 'ShieldHeavy', 'EnhancedSensors'})
        ScenarioInfo.SeraACU2:SetAutoOvercharge(true)
        ScenarioInfo.SeraACU2:SetVeterancy(5 - Difficulty)
    
    local AntinukesA = ArmyBrains[Aeon]:GetListOfUnits(categories.uab4302, false)
            for _, v in AntinukesA do
                v:GiveTacticalSiloAmmo(5)
            end
    local AntinukesU = ArmyBrains[UEF]:GetListOfUnits(categories.ueb4302, false)
            for _, v in AntinukesU do
                v:GiveTacticalSiloAmmo(5)
            end

    --Eco boosts for AI
    
    buffDef = Buffs['CheatIncome']
    buffAffects = buffDef.Affects
    buffAffects.EnergyProduction.Mult = 2.0
    buffAffects.MassProduction.Mult = 2.0

    for _, u in GetArmyBrain(UEF):GetPlatoonUniquelyNamed('ArmyPool'):GetPlatoonUnits() do
        Buff.ApplyBuff(u, 'CheatIncome')
    end

    for _, u in GetArmyBrain(Aeon):GetPlatoonUniquelyNamed('ArmyPool'):GetPlatoonUnits() do
        Buff.ApplyBuff(u, 'CheatIncome')
    end
    
    buffAffects.EnergyProduction.Mult = 1.5
    buffAffects.MassProduction.Mult = 1.5

    for _, u in GetArmyBrain(SeraphimAlly2):GetPlatoonUniquelyNamed('ArmyPool'):GetPlatoonUnits() do
        Buff.ApplyBuff(u, 'CheatIncome')
    end

    -- P3 Cutscene Units

    local units = ScenarioUtils.CreateArmyGroupAsPlatoon('SeraphimAlly2', 'P3S2UnitEXP', 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(units, 'P3S2B1Defense2')

    units = ScenarioUtils.CreateArmyGroupAsPlatoon('SeraphimAlly2', 'P3S2UnitAir', 'GrowthFormation')
    for _, v in units:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P3S2B1Defense2')))
    end
   
    units = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'P3UCutsceneattack1', 'GrowthFormation')
    for _, v in units:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P3UCutsceneattack')))
    end

    units = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'P3UCutsceneattack2', 'GrowthFormation')
    for _, v in units:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P3UCutsceneattack')))
    end
    
    local units = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'P3Uintattack1_D'.. Difficulty, 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(units, 'P3UIntattack1')

    local units = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'P3Uintattack2_D'.. Difficulty, 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(units, 'P3UIntattack2')

    -- P3 UEF Patrols

    units = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'P3UDefence1_D'.. Difficulty, 'GrowthFormation')
    for _, v in units:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P3UB1AirDefense1')))
    end

    units = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'P3UNavalpatrol_D'.. Difficulty, 'GrowthFormation')
    for _, v in units:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P3UB1NavalPatrol1')))
    end

    local quantity = {1, 2, 2}
    for i = 1, quantity[Difficulty] do
        units = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'P3UExpDefend', 'GrowthFormation')
        for _, v in units:GetPlatoonUnits() do
            ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P3UB1LandDefense')))
        end
    end
    
    -- P3 Aeon Patrols

    units = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'P3APatrolUnits_D'.. Difficulty, 'GrowthFormation')
    for _, v in units:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P3AB2NavalPatrol')))
    end
    
    -- P3 Cutscene

    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Commanderwarp'), 0)
    
    Cinematics.EnterNISMode()
        Cinematics.SetInvincible('AREA_2')
    
        local VisMarker3_1 = ScenarioFramework.CreateVisibleAreaLocation(80, 'P3Vision1', 0, ArmyBrains[Player1])
        local VisMarker3_2 = ScenarioFramework.CreateVisibleAreaLocation(80, 'P3Vision2', 0, ArmyBrains[Player1])
        local VisMarker3_3 = ScenarioFramework.CreateVisibleAreaLocation(80, 'P3Vision3', 0, ArmyBrains[Player1])
        local VisMarker3_4 = ScenarioFramework.CreateVisibleAreaLocation(80, 'P3Vision4', 0, ArmyBrains[Player1])

        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P3Cam1'), 3)
        WaitSeconds(3)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P3Cam2'), 4)
        WaitSeconds(3)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P3Cam3'), 4)
        WaitSeconds(3)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P3Cam4'), 4)
        WaitSeconds(3)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P3Cam5'), 4)
        WaitSeconds(2)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Commanderwarp'), 2)

        ForkThread(
            function()
                WaitSeconds(1)
                VisMarker3_1:Destroy()
                VisMarker3_2:Destroy()
                VisMarker3_3:Destroy()
                VisMarker3_4:Destroy()
                WaitSeconds(1)
                ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('P3Vision1'), 90)
                ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('P3Vision2'), 90)
                ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('P3Vision3'), 90)
                ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('P3Vision4'), 90)
            end
        )
    
        Cinematics.SetInvincible('AREA_2', true)    
    Cinematics.ExitNISMode() 
    
    --Start Missions and secondary objectives
    
    ForkThread(MissionP3)
    ForkThread(nukeparty)
    ForkThread(CounterAttackP3)
    ForkThread(P3Randoms)
    ForkThread(BonusMissionsP3)

    SetupUEFP3TauntTriggers()
    SetupAeonP3TauntTriggers()

    ScenarioFramework.CreateTimerTrigger(SACUunlocks, 2*60)

    ScenarioFramework.CreateTimerTrigger(SecondaryMissionOrderP3, 3*60)

    ScenarioFramework.CreateTimerTrigger(SeraphimAllyRetreatP3, 4*60)
    
    ScenarioFramework.CreateArmyIntelTrigger(SecondaryMissionAeonP3, ArmyBrains[Player1], 'LOSNow', false, true,  categories.COMMAND, true, ArmyBrains[Aeon] )
end

function SACUunlocks()
    
    WaitSeconds(10)
    
    ScenarioFramework.Dialogue(OpStrings.SACUsIntroP3)
    
    ScenarioInfo.PSACU1 = ScenarioFramework.SpawnCommander('Player1', 'PSACU1', 'Gate', 'Touth-yez', false, false,
        {'EngineeringThroughput', 'Shield', 'Overcharge'})
    WaitSeconds(2)  
    ScenarioInfo.PSACU2 = ScenarioFramework.SpawnCommander('Player1', 'PSACU2', 'Gate', 'Verkhez-thui', false, false,
        {'EngineeringThroughput', 'Shield', 'Overcharge'})
    
    ScenarioFramework.PlayUnlockDialogue()
    
    ScenarioFramework.RemoveRestrictionForAllHumans(
        categories.xsb0304 + -- Seraph Gate
        categories.xsl0301 + -- Seraph sACU
        categories.uab0304 + -- Aeon Gate
        categories.ual0301  -- Aeon sACU

    )
        
    ScenarioInfo.S1P3 = Objectives.Protect(
        'secondary',                      -- type
        'incomplete',                   -- complete
        'Keep your Support Commanders alive',                -- title
        'Seraphim lives are valuable, keep them alive.', -- description
        {                              -- target
            MarkUnits = true,
            Units = {ScenarioInfo.PSACU1, ScenarioInfo.PSACU2}   
        }
    )
    ScenarioInfo.S1P3:AddResultCallback(
        function(result)
            if (not result and not ScenarioInfo.OpEnded) then
                ScenarioFramework.Dialogue(OpStrings.SACUsDeathP3)
            end
        end
    )
end

function MissionP3()

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
                ForkThread(EscortACU3)
                ForkThread(UEFCommanderKilled)
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
        function(result, unit)
            if (not result and not ScenarioInfo.OpEnded) then
                ScenarioFramework.CDRDeathNISCamera(unit)
                ScenarioFramework.EndOperationSafety()

                ScenarioFramework.FlushDialogueQueue()
                ScenarioFramework.Dialogue(OpStrings.Comsdeath, PlayerLose, true)
            end
        end
    )
    if ExpansionTimer then
        local M3MapExpandDelay = {35*60, 30*60, 25*60}
        ScenarioFramework.CreateTimerTrigger(EscortACU3, M3MapExpandDelay[Difficulty])  
    end    
end

function CounterAttackP3()

    local quantity = {}
    local trigger = {}
    local platoon

    -- sends Gunships if player has more than [60, 50, 40] Units, up to 6, 1 group per 14, 11, 10
    num = ScenarioFramework.GetNumOfHumanUnits(categories.ALLUNITS - categories.WALL)
    quantity = {200, 150, 100}
    trigger = {100, 75, 50}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 4) then
            num = 4
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('UEF', 'P3UIntGunships', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P3UIntAirattack' .. i)
        end
    end

    -- sends Strats if player has more than [70, 60, 50] Tech 2 Defenses, up to 6, 1 group per 25, 20, 15
    num = ScenarioFramework.GetNumOfHumanUnits(categories.STRUCTURE * categories.DEFENSE - categories.TECH1)
    quantity = {75, 50, 40}
    trigger = {55, 35, 20}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 4) then
            num = 4
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('UEF', 'P3UIntBombers', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P3UIntAirattack' .. i)
        end
    end

    -- sends ASF if player has more than [30, 20, 10] Air, up to 3, 1 group per 3, 2, 1
    num = ScenarioFramework.GetNumOfHumanUnits(categories.AIR * categories.MOBILE)
    quantity = {75, 50, 25}
    trigger = {50, 45, 20}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 4) then
            num = 4
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('UEF', 'P3UIntFighters', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P3UIntAirattack' .. i)
            WaitSeconds(2)
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('UEF', 'P3UIntFighters', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P3UIntAirattack' .. i)
        end
    end

    num = ScenarioFramework.NumCatUnitsInArea(categories.ALLUNITS - categories.WALL, 'P2DefenseArea', ArmyBrains[Player1])
    quantity = {70, 50, 40}
    trigger = {50, 30, 20}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 4) then
            num = 4
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Aeon', 'P3AIntDrop', 'GrowthFormation', 5)
            CustomFunctions.PlatoonAttackWithTransports(platoon, 'P2UOffmapattackDrop', 'P2AComDropattack', 'P2AB1MK', true)
        end
    end

    num = ScenarioFramework.NumCatUnitsInArea(categories.ALLUNITS - categories.WALL, 'P2DefenseArea', ArmyBrains[Player1])
    quantity = {40, 30, 20}
    trigger = {40, 30, 20}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 4) then
            num = 4
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Aeon', 'P3AIntGunships', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P2AB1airattack' .. Random(1, 3))
        end
    end

    WaitSeconds(5)

    num = ScenarioFramework.NumCatUnitsInArea(categories.ALLUNITS - categories.WALL, 'P2DefenseArea', ArmyBrains[SeraphimAlly])
    quantity = {70, 50, 40}
    trigger = {50, 30, 20}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 3) then
            num = 3
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Aeon', 'P3AIntDrop', 'GrowthFormation', 5)
            CustomFunctions.PlatoonAttackWithTransports(platoon, 'P2UOffmapattackDrop', 'P2AComDropattack', 'P2AB1MK', true)
        end
    end

    num = ScenarioFramework.NumCatUnitsInArea(categories.ALLUNITS - categories.WALL, 'P2DefenseArea', ArmyBrains[SeraphimAlly])
    quantity = {40, 30, 20}
    trigger = {40, 30, 20}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 3) then
            num = 3
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Aeon', 'P3AIntGunships', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P2AB1airattack' .. Random(1, 3))
        end
    end
end

function SecondaryMissionAeonP3()

    ScenarioInfo.S2P3 = Objectives.Kill(
        'secondary',                      -- type
        'incomplete',                   -- complete
        'Kill The Aeon Commander',                -- title
        'Kill the Aeon Commander if you get the chance', -- description
        {                              -- target
            MarkUnits = true,
            Units = {ScenarioInfo.AEONACU}  
        }
    )   
    ScenarioInfo.S2P3:AddResultCallback(
        function(result)
            if result then
               ForkThread(AeonCommanderKilled)
            end
        end
    )
end

function SecondaryMissionOrderP3()

    ScenarioFramework.Dialogue(OpStrings.OrderNukeP3)

    WaitSeconds(5)

    ScenarioInfo.S3P3 = Objectives.Kill(
        'secondary',                      -- type
        'incomplete',                   -- complete
        'Destroy Nuke Defenses',                -- title
        'Jareth has several nukes ready, he just needs an opening.', -- description
        {                              -- target
            MarkUnits = true,
            Units = {ScenarioInfo.P3SecObj1, ScenarioInfo.P3SecObj2}  
        }
    )   
    ScenarioInfo.S3P3:AddResultCallback(
        function(result)
            if result then
                ScenarioFramework.Dialogue(OpStrings.OrderNukeEndP3)
                ForkThread(nukepartyOrder)
            end
        end
    )
end

function SeraphimAllyRetreatP3()

    if ScenarioInfo.SeraACU and not ScenarioInfo.SeraACU.Dead then

        ScenarioFramework.Dialogue(OpStrings.ZuthAliveP3)

        ScenarioInfo.M2B2:ManualResult(true)

        ScenarioFramework.FakeTeleportUnit(ScenarioInfo.SeraACU, true)

        WaitSeconds(3)

        local SeraUnits = ScenarioFramework.GetCatUnitsInArea((categories.ALLUNITS), 'P2DefenseArea', ArmyBrains[SeraphimAlly])
            for k, v in SeraUnits do
                if v and not v:IsDead() and (v:GetAIBrain() == ArmyBrains[SeraphimAlly]) then
                    ScenarioFramework.GiveUnitToArmy( v, Player1 )
                end
            end
    else

        ScenarioFramework.Dialogue(OpStrings.ZuthDeadP3)

        local SeraUnits = ScenarioFramework.GetCatUnitsInArea((categories.ALLUNITS), 'AREA_2', ArmyBrains[SeraphimAlly])
            for k, v in SeraUnits do
                if v and not v.Dead then
                    v:Kill()
                    WaitSeconds(Random(0.1, 0.3))
                end
            end
    end
end

function P3Randoms()

    ScenarioInfo.Specialfunction = Random(1, 3)
    
    if  ScenarioInfo.Specialfunction == 1 then
        
        local destination = ScenarioUtils.MarkerToPosition('P3ARMK')
        local transports = ScenarioUtils.CreateArmyGroup('Aeon', 'P3Transport_D'.. Difficulty)
        local units = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'P3Eng_D'.. Difficulty, 'NoFormation')

        WaitSeconds(2)
        import('/lua/ai/aiutilities.lua').UseTransports(units:GetPlatoonUnits(), transports, destination)

        WaitSeconds(6)

        for _, transport in transports do
            ScenarioFramework.CreateUnitToMarkerDistanceTrigger(DestroyUnit, transport,  ScenarioUtils.MarkerToPosition('P4AB1MK'), 15)

            IssueTransportUnload({transport}, destination)
            IssueMove({transport}, ScenarioUtils.MarkerToPosition('P4AB1MK'))
        end
        
        -- Disband the Platoon
        ArmyBrains[Aeon]:DisbandPlatoon(units)
        P2AEONAI:AeonBaseR1AI()
    
        else
        if  ScenarioInfo.Specialfunction == 2 then
        
        local destination = ScenarioUtils.MarkerToPosition('P3ARMK')
        local transports = ScenarioUtils.CreateArmyGroup('Aeon', 'P3Transport_D'.. Difficulty)
        local units = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'P3Eng_D'.. Difficulty, 'NoFormation')

        WaitSeconds(2)
        import('/lua/ai/aiutilities.lua').UseTransports(units:GetPlatoonUnits(), transports, destination)

        WaitSeconds(6)

        for _, transport in transports do
            ScenarioFramework.CreateUnitToMarkerDistanceTrigger(DestroyUnit, transport,  ScenarioUtils.MarkerToPosition('P4AB1MK'), 15)

            IssueTransportUnload({transport}, destination)
            IssueMove({transport}, ScenarioUtils.MarkerToPosition('P4AB1MK'))
        end
        
        -- Disband the Platoon
        ArmyBrains[Aeon]:DisbandPlatoon(units)
        P2AEONAI:AeonBaseR2AI()
        else
            if  ScenarioInfo.Specialfunction == 3 then
                ScenarioUtils.CreateArmyGroup('UEF', 'P3URandom1_D'.. Difficulty)
                ForkThread(nukepartyUEF)
            end    
        end
    end
end

--hidden bonus missions
function BonusMissionsP3()

    ---------------------------------------------------
    -- Bonus Objective - kill 5 Experimentals
    ---------------------------------------------------
    ScenarioInfo.M2B1 = Objectives.ArmyStatCompare(
        'bonus',
        'incomplete',
        'Stay down fatty',
        'Kill 5 Experimental Fatboys',
        'kill',
        {
            Armies = {'HumanPlayers'},
            StatName = 'Enemies_Killed',
            CompareOp = '>=',
            Value = 5,
            Category = categories.uel0401,
            Hidden = true,
        }
    )   
end

--Commander Death functions

function UEFCommanderKilled()
    ForkThread(Part4Bases)
    ScenarioFramework.Dialogue(OpStrings.UEFdeath1, nil, true)
    ScenarioFramework.CDRDeathNISCamera(ScenarioInfo.UEFACU, 3)
    if Difficulty < 3 then
        ForkThread(P3KillUEFBase)  
    end

    WaitSeconds(5)

    if ScenarioInfo.AEONACU and not ScenarioInfo.AEONACU.Dead then
            ScenarioFramework.Dialogue(OpStrings.UEFReact1, nil, true)
    else

    end
end

function P3KillUEFBase()
    local UEFUnits = ScenarioFramework.GetCatUnitsInArea((categories.ALLUNITS), 'AREA_3', ArmyBrains[UEF])
        for k, v in UEFUnits do
            if v and not v.Dead then
                v:Kill()
                WaitSeconds(Random(0.1, 0.3))
            end
        end      
end

function AeonCommanderKilled()
    
    ScenarioFramework.Dialogue(OpStrings.Aeondeath1, nil, true)
    ScenarioFramework.CDRDeathNISCamera(ScenarioInfo.AEONACU, 3)
    if Difficulty < 3 then
       ForkThread(P3KillAeonBase)
    end

    WaitSeconds(5)

    if ScenarioInfo.UEFACU and not ScenarioInfo.UEFACU.Dead then
        ScenarioFramework.Dialogue(OpStrings.AeonReact1, nil, true)
    else

    end
end

function P3KillAeonBase()
    local AeonUnits = ScenarioFramework.GetCatUnitsInArea((categories.ALLUNITS), 'AREA_3', ArmyBrains[Aeon])
        for k, v in AeonUnits do
            if v and not v.Dead then
                v:Kill()
                WaitSeconds(Random(0.1, 0.3))
            end
        end
end

--Final batch of commanders

function EscortACU3()
    ScenarioFramework.FlushDialogueQueue()

    if ScenarioInfo.MissionNumber ~= 4 then
        return
    end
    ScenarioInfo.MissionNumber = 5

    WaitSeconds(20)

    ScenarioInfo.ComACU3s = {}

    ScenarioInfo.FinalACU1 = ScenarioFramework.SpawnCommander('WarpComs', 'G1U7', 'Gate', ' Executor Vara', false, false,
    {'Shield', 'ShieldHeavy', 'EnhancedSensors', 'AdvancedEngineering', 'T3Engineering'})
    ScenarioInfo.FinalACU1:SetVeterancy(5 - Difficulty)
    ScenarioFramework.GroupMoveChain({ScenarioInfo.FinalACU1}, 'WarpComChain2')
    table.insert(ScenarioInfo.ComACU3s, ScenarioInfo.FinalACU1)

    WaitSeconds(5)

    ScenarioInfo.FinalACU2 = ScenarioFramework.SpawnCommander('WarpComs', 'G1U8', 'Gate', 'Unknown Cybran ACU', false, false,
    {'MicrowaveLaserGenerator','ResourceAllocation', 'AdvancedEngineering', 'T3Engineering'})
    ScenarioInfo.FinalACU2:SetVeterancy(5)
    ScenarioFramework.GroupMoveChain({ScenarioInfo.FinalACU2}, 'WarpComChain2')
    table.insert(ScenarioInfo.ComACU3s, ScenarioInfo.FinalACU2)

    WaitSeconds(5)

    ScenarioInfo.FinalACU3 = ScenarioFramework.SpawnCommander('WarpComs', 'G1U9', 'Gate', 'Overlord Voth-Othum', false, false,
    {'RegenAura', 'AdvancedRegenAura', 'DamageStabilization', 'DamageStabilizationAdvanced', 'AdvancedEngineering', 'T3Engineering'})
    ScenarioInfo.FinalACU3:SetVeterancy(5 - Difficulty)
    ScenarioFramework.GroupMoveChain({ScenarioInfo.FinalACU3}, 'WarpComChain2')
    table.insert(ScenarioInfo.ComACU3s, ScenarioInfo.FinalACU3)

    WaitSeconds(5)
    
    ForkThread(MissionEscort1P3)
end

function MissionEscort1P3()

    ScenarioInfo.M3P3 = Objectives.SpecificUnitsInArea(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Protect the last retreating commanders',                -- title
        'We need every able commander, defend them at all costs.', -- description    
        {                              -- target
            MarkUnits = true,
            Units = ScenarioInfo.ComACU3s,
            Area = 'EvacZone',
        }
    )
    ScenarioInfo.M3P3:AddResultCallback(
        function(result)
            if(not result and not ScenarioInfo.OpEnded) then
                ScenarioFramework.Dialogue(OpStrings.Comsdeath, PlayerLose, true)
            end

            if result then
                ScenarioFramework.FakeTeleportUnit(ScenarioInfo.FinalACU1, true)
                ScenarioFramework.FakeTeleportUnit(ScenarioInfo.FinalACU2, true)
                ScenarioFramework.FakeTeleportUnit(ScenarioInfo.FinalACU3, true)
                ScenarioInfo.M2P1:ManualResult(true)
                ScenarioInfo.S1P3:ManualResult(true)
                ScenarioFramework.Dialogue(OpStrings.Victory, PlayerWin, true)
                
            end
        end
    )
    
    ForkThread(Failsafe3)
    ForkThread(CoalitionInterceptattacksP3)
    
    ScenarioFramework.Dialogue(OpStrings.IntroP4, nil, true)
    
    WaitSeconds(25)
    
    -- Warp Jareth out for story purposes
    
    ScenarioInfo.M2P3:ManualResult(true)
    ScenarioFramework.FakeTeleportUnit(ScenarioInfo.SeraACU2, true) 
    ForkThread(P3GiveOrderBase)
end

function Failsafe3()
    
    WaitSeconds(9*60)
    if ScenarioInfo.M3P3.Active then
        ScenarioInfo.M3P3:ManualResult(true)
    end
end

function Part4Bases()

    -- Offmap bases (adds more "activity" to the map during final escort)

    P4CoalitionAI.P4UBase1AI()
    P4CoalitionAI.P4UBase2AI()
    P4CoalitionAI.P4ABase1AI()
    P4CoalitionAI.P4ABase2AI()

    local AntinukesA = ArmyBrains[Aeon]:GetListOfUnits(categories.uab4302, false)
        for _, v in AntinukesA do
            v:GiveTacticalSiloAmmo(5)
        end
    local AntinukesU = ArmyBrains[UEF]:GetListOfUnits(categories.ueb4302, false)
        for _, v in AntinukesU do
            v:GiveTacticalSiloAmmo(5)
        end

    buffDef = Buffs['CheatIncome']
    buffAffects = buffDef.Affects
    buffAffects.EnergyProduction.Mult = 2
    buffAffects.MassProduction.Mult = 2

    for _, u in GetArmyBrain(UEF):GetPlatoonUniquelyNamed('ArmyPool'):GetPlatoonUnits() do
        Buff.ApplyBuff(u, 'CheatIncome')
    end
    
    for _, u in GetArmyBrain(Aeon):GetPlatoonUniquelyNamed('ArmyPool'):GetPlatoonUnits() do
        Buff.ApplyBuff(u, 'CheatIncome')
    end
end

function CoalitionInterceptattacksP3()

    local quantity = {}
    local trigger = {}
    local platoon

    -- Basic air attack

    WaitSeconds(10)

    for _, v in ScenarioInfo.ComACU3s do
        if not v:IsDead() then
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('UEF', 'P4UComSnipe_D' .. Difficulty, 'NoFormation', 5)
            IssueAttack(platoon:GetPlatoonUnits(), v)
            IssueAggressiveMove(platoon:GetPlatoonUnits(), ScenarioUtils.MarkerToPosition('Player1')) 
        end  
    end

    WaitSeconds(40)
    i = Difficulty
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('UEF', 'P4UComExp_D' .. Difficulty, 'AttackFormation', 2 + Difficulty)
    ScenarioFramework.PlatoonPatrolChain(platoon, 'P4IntAttackExp')
    local guard = ScenarioUtils.CreateArmyGroup('UEF', 'P4UComExpGuard')
        IssueGuard(guard, platoon:GetPlatoonUnits()[i])

    for i = 1, 2 do
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('UEF', 'P4UComLand_D' .. Difficulty, 'GrowthFormation', 5)
        ScenarioFramework.PlatoonPatrolChain(platoon, 'P4UB1Landattack' .. i)
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('UEF', 'P4UComAir_D' .. Difficulty, 'GrowthFormation', 5)
        ScenarioFramework.PlatoonPatrolChain(platoon, 'P4UB1Landattack' .. i)
    end

    for _, v in ScenarioInfo.ComACU3s do
        if not v:IsDead() then
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Aeon', 'P4AComSnipe_D' .. Difficulty, 'NoFormation', 5)
            IssueAttack(platoon:GetPlatoonUnits(), v)
            IssueAggressiveMove(platoon:GetPlatoonUnits(), ScenarioUtils.MarkerToPosition('Player1'))
        end
    end

    WaitSeconds(40)

    for i = 1, 2 do
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('UEF', 'P4UComLand_D' .. Difficulty, 'GrowthFormation', 5)
        ScenarioFramework.PlatoonPatrolChain(platoon, 'P4UB1Landattack' .. i)
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('UEF', 'P4UComAir_D' .. Difficulty, 'GrowthFormation', 5)
        ScenarioFramework.PlatoonPatrolChain(platoon, 'P4UB1Landattack' .. i)
    end

    -- sends Gunships if player has more than [60, 50, 40] Units, up to 10, 1 group per 14, 11, 10
    num = ScenarioFramework.GetNumOfHumanUnits(categories.ALLUNITS - categories.WALL)
    quantity = {200, 150, 100}
    trigger = {70, 60, 50}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 10) then
            num = 10
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('UEF', 'P4UComGunships', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P4IntAttack' .. Random(1, 5))
        end
    end

    -- sends ASF if player has more than [30, 20, 10] Air, up to 5, 1 group per 20, 15, 10
    num = ScenarioFramework.GetNumOfHumanUnits(categories.AIR * categories.MOBILE)
    quantity = {30, 20, 10}
    trigger = {20, 15, 10}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 10) then
            num = 10
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('UEF', 'P4UComFighters', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P4IntAttack' .. Random(1, 5))
        end
    end

    WaitSeconds(40)

    for i = 1, 2 do
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('UEF', 'P4UComLand_D' .. Difficulty, 'GrowthFormation', 5)
        ScenarioFramework.PlatoonPatrolChain(platoon, 'P4UB1Landattack' .. i)
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('UEF', 'P4UComAir_D' .. Difficulty, 'GrowthFormation', 5)
        ScenarioFramework.PlatoonPatrolChain(platoon, 'P4UB1Landattack' .. i)
    end

    -- sends Drops if player has more than [50, 40, 30] Air, up to 5, 1 group per 45, 35, 25
    num = ScenarioFramework.GetNumOfHumanUnits(categories.AIR * categories.MOBILE)
    quantity = {50, 40, 30}
    trigger = {45, 35, 25}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 5) then
            num = 5
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Aeon', 'P4AComDrop', 'GrowthFormation', 5)
            CustomFunctions.PlatoonAttackWithTransports(platoon, 'P4Intdrop', 'P4Intdropattack','P4AB1MK', true)
        end
    end

    for _, v in ScenarioInfo.ComACU3s do
        if not v:IsDead() then
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('UEF', 'P4UComSnipe_D' .. Difficulty, 'NoFormation', 5)
            IssueAttack(platoon:GetPlatoonUnits(), v)
            IssueAggressiveMove(platoon:GetPlatoonUnits(), ScenarioUtils.MarkerToPosition('Player1')) 
        end  
    end

    -- sends Drops if player has more than [250, 200, 150] All, up to 5, 1 group per 70, 60, 50
    num = ScenarioFramework.GetNumOfHumanUnits(categories.ALLUNITS - categories.WALL)
    quantity = {250, 200, 150}
    trigger = {150, 100, 75}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 5) then
            num = 5
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Aeon', 'P4AComDrop2', 'GrowthFormation', 5)
            CustomFunctions.PlatoonAttackWithTransports(platoon, 'P4Intdrop2', 'P4Intdropattack2','P4AB1MK', true)
        end
    end

    -- sends Gunships if player has more than [60, 50, 40] Units, up to 10, 1 group per 14, 11, 10
    num = ScenarioFramework.GetNumOfHumanUnits(categories.ALLUNITS - categories.WALL)
    quantity = {400, 300, 200}
    trigger = {200, 150, 100}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 10) then
            num = 10
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Aeon', 'P4Agunships', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P4Aintattack' .. Random(1, 4))
        end
    end

    -- sends Gunships if player has more than [60, 50, 40] Units, up to 10, 1 group per 14, 11, 10
    num = ScenarioFramework.GetNumOfHumanUnits(categories.AIR * categories.MOBILE)
    quantity = {30, 20, 10}
    trigger = {30, 20, 10}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 10) then
            num = 10
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Aeon', 'P4AFighters', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P4Aintattack' .. Random(1, 4))
        end
    end

    -- sends Gunships if player has more than [60, 50, 40] Units, up to 10, 1 group per 14, 11, 10
    num = ScenarioFramework.GetNumOfHumanUnits(categories.EXPERIMENTAL * categories.MOBILE)
    quantity = {3, 2, 1}
    trigger = {3, 2, 1}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 3) then
            num = 4
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Aeon', 'P4AExp', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P4Aintattack' .. i)
        end
    end
    ScenarioFramework.SetPlayableArea('AREA_4', true)

    ScenarioUtils.CreateArmyGroup('UEF', 'P4UArty_D'.. Difficulty)
    ScenarioUtils.CreateArmyGroup('Aeon', 'P4AArty_D'.. Difficulty)

    WaitSeconds(40)

    for _, v in ScenarioInfo.ComACU3s do
        if not v:IsDead() then
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Aeon', 'P4AComSnipe_D' .. Difficulty, 'NoFormation', 5)
            IssueAttack(platoon:GetPlatoonUnits(), v)
            IssueAggressiveMove(platoon:GetPlatoonUnits(), ScenarioUtils.MarkerToPosition('Player1'))
        end
    end

    WaitSeconds(40)

    for _, v in ScenarioInfo.ComACU3s do
        if not v:IsDead() then
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('UEF', 'P4UComSnipe_D' .. Difficulty, 'NoFormation', 5)
            IssueAttack(platoon:GetPlatoonUnits(), v)
            IssueAggressiveMove(platoon:GetPlatoonUnits(), ScenarioUtils.MarkerToPosition('Player1')) 
        end  
    end  
end

function P3GiveOrderBase()
    local OrderUnits = ScenarioFramework.GetCatUnitsInArea((categories.ALLUNITS), 'AREA_3', ArmyBrains[SeraphimAlly2])
            for k, v in OrderUnits do
                if v and not v:IsDead() and (v:GetAIBrain() == ArmyBrains[SeraphimAlly2]) then
                    ScenarioFramework.GiveUnitToArmy( v, Player1 )
                end
            end
end

--Aeon Nuke function

function nukeparty()
    local AeonNuke = ArmyBrains[Aeon]:GetListOfUnits(categories.uab2305, false)
    if AeonNuke and not AeonNuke.Dead then
        AeonNuke[1]:GiveNukeSiloAmmo(2)
        WaitSeconds(30)
        IssueNuke({AeonNuke[1]}, ScenarioUtils.MarkerToPosition('Nuke1'))
        WaitSeconds(5)
        IssueNuke({AeonNuke[1]}, ScenarioUtils.MarkerToPosition('Nuke2'))
        WaitSeconds(7*60)
        local plat = ArmyBrains[Aeon]:MakePlatoon('', '')
        ArmyBrains[Aeon]:AssignUnitsToPlatoon(plat, {AeonNuke[1]}, 'Attack', 'NoFormation')
        plat:ForkAIThread(plat.NukeAI)
    end
end

function nukepartyUEF()
    local UEFNuke = ArmyBrains[UEF]:GetListOfUnits(categories.ueb2305, false)
    if UEFNuke and not UEFNuke.Dead then
        UEFNuke[1]:GiveNukeSiloAmmo(2)
        WaitSeconds(8*60)
        local plat = ArmyBrains[UEF]:MakePlatoon('', '')
        ArmyBrains[UEF]:AssignUnitsToPlatoon(plat, {UEFNuke[1]}, 'Attack', 'NoFormation')
        plat:ForkAIThread(plat.NukeAI)
        return
    end
end

function nukepartyOrder()
    local OrderNuke = ArmyBrains[SeraphimAlly2]:GetListOfUnits(categories.uab2305, false)
    if OrderNuke and not OrderNuke.Dead then
        OrderNuke[1]:GiveNukeSiloAmmo(4)
        WaitSeconds(1)
        IssueNuke({OrderNuke[1]}, ScenarioUtils.MarkerToPosition('NukeS1'))
        WaitSeconds(10)
        IssueNuke({OrderNuke[1]}, ScenarioUtils.MarkerToPosition('NukeS2'))
        WaitSeconds(10)
        IssueNuke({OrderNuke[1]}, ScenarioUtils.MarkerToPosition('NukeS3'))
        WaitSeconds(10)
        IssueNuke({OrderNuke[1]}, ScenarioUtils.MarkerToPosition('NukeS4'))
        WaitSeconds(10)
        local plat = ArmyBrains[SeraphimAlly2]:MakePlatoon('', '')
        ArmyBrains[SeraphimAlly2]:AssignUnitsToPlatoon(plat, {OrderNuke[1]}, 'Attack', 'NoFormation')
        plat:ForkAIThread(plat.NukeAI)
    end
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

function PlayerDeath()
    if Debug then return end
    if (not ScenarioInfo.OpEnded) then
        ScenarioFramework.CDRDeathNISCamera(ScenarioInfo.Player1CDR)
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

function DestroyUnit(unit)
    unit:Destroy()
end

function SetupUEFP2TauntTriggers()

    if ScenarioInfo.MissionNumber == 2 then
        UEFTM:AddEnemiesKilledTaunt('UEFTaunt3', ArmyBrains[UEF], categories.STRUCTURE, 15)
        UEFTM:AddUnitsKilledTaunt('UEFTaunt2', ArmyBrains[UEF], categories.LAND * categories.MOBILE, 50)
        UEFTM:AddUnitsKilledTaunt('UEFTaunt1', ArmyBrains[UEF], categories.STRUCTURE * categories.FACTORY, 5)
        return
    end
end

function SetupUEFP3TauntTriggers()

    if ScenarioInfo.MissionNumber == 4 then
        UEFTM:AddEnemiesKilledTaunt('UEFTaunt5', ArmyBrains[UEF], categories.STRUCTURE, 10)
        UEFTM:AddUnitsKilledTaunt('UEFTaunt6', ArmyBrains[UEF], categories.LAND * categories.MOBILE, 60)
        UEFTM:AddUnitsKilledTaunt('UEFTaunt2', ArmyBrains[UEF], categories.STRUCTURE * categories.FACTORY, 6)
        return
    end
end

function SetupAeonP2TauntTriggers()

    if ScenarioInfo.MissionNumber == 2 then
        AeonTM:AddUnitsKilledTaunt('AeonTaunt1', ArmyBrains[Aeon], categories.AIR * categories.MOBILE, 80)
        return
    end
end

function SetupAeonP3TauntTriggers()

    if ScenarioInfo.MissionNumber == 4 then
        AeonTM:AddUnitsKilledTaunt('AeonTaunt2', ArmyBrains[Aeon], categories.AIR * categories.MOBILE, 80)
        AeonTM:AddUnitsKilledTaunt('AeonTaunt3', ArmyBrains[Aeon], categories.STRUCTURE * categories.FACTORY, 6)
        return
    end
end
