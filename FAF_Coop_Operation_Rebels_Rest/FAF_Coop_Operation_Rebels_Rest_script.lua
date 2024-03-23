------------------------------
-- Coalition Campaign - Mission 4
--
-- Author: Shadowlorda1
------------------------------
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local Buff = import('/lua/sim/Buff.lua')
local Cinematics = import('/lua/cinematics.lua')
local Objectives = import('/lua/ScenarioFramework.lua').Objectives
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local Utilities = import('/lua/Utilities.lua')
local CustomFunctions = import('/maps/FAF_Coop_Operation_Rebels_Rest/FAF_Coop_Operation_Rebels_Rest_CustomFunctions.lua')
local AIBuildStructures = import('/lua/ai/aibuildstructures.lua') 
local P0UEFAI = import('/maps/FAF_Coop_Operation_Rebels_Rest/UEFaiP0.lua')
local P1UEFAI = import('/maps/FAF_Coop_Operation_Rebels_Rest/UEFaiP1.lua')
local P2UEFAI = import('/maps/FAF_Coop_Operation_Rebels_Rest/UEFaiP2.lua')
local P3UEFAI = import('/maps/FAF_Coop_Operation_Rebels_Rest/UEFaiP3.lua')
local OpStrings = import('/maps/FAF_Coop_Operation_Rebels_Rest/FAF_Coop_Operation_Rebels_Rest_strings.lua') 
local TauntManager = import('/lua/TauntManager.lua')

local UEFTM = TauntManager.CreateTauntManager('UEF1TM', '/maps/FAF_Coop_Operation_Rebels_Rest/FAF_Coop_Operation_Rebels_Rest_strings.lua')

local Difficulty = ScenarioInfo.Options.Difficulty

ScenarioInfo.UEF1 = 2
ScenarioInfo.UEF2 = 3
ScenarioInfo.Player1 = 1
ScenarioInfo.Player2 = 4
ScenarioInfo.Player3 = 5
ScenarioInfo.Player4 = 6

local Player1 = ScenarioInfo.Player1
local UEF1 = ScenarioInfo.UEF1
local UEF2 = ScenarioInfo.UEF2
local Player2 = ScenarioInfo.Player2
local Player3 = ScenarioInfo.Player3
local Player4 = ScenarioInfo.Player4

local AssignedObjectives = {}
local ExpansionTimer = ScenarioInfo.Options.Expansion == 'true'
local Debug = false
local SkipNIS1 = true

local NIS1InitialDelay = 3

function OnPopulate(Self)
    ScenarioUtils.InitializeScenarioArmies()
    LeaderFaction, LocalFaction = ScenarioFramework.GetLeaderAndLocalFactions()
    
    ScenarioFramework.SetUEFAlly2Color(UEF1)
    
     -- Army Colors
    if(LeaderFaction == 'cybran') then
        ScenarioFramework.SetCybranPlayerColor(Player1)
    elseif(LeaderFaction == 'uef') then
        ScenarioFramework.SetUEFPlayerColor(Player1)
    elseif(LeaderFaction == 'aeon') then
        ScenarioFramework.SetAeonPlayerColor(Player1)
    end
    
    local colors = {
        ['Player2'] = {250, 250, 0}, 
        ['Player3'] = {255, 255, 255}, 
        ['Player4'] = {97, 109, 126},
        ['UEF2'] = {47, 79, 79}
    }
    local tblArmy = ListArmies()
    for army, color in colors do
        if tblArmy[ScenarioInfo[army]] then
            ScenarioFramework.SetArmyColor(ScenarioInfo[army], unpack(color))
        end
    end

    SetArmyUnitCap(UEF1, 4000)
    SetArmyUnitCap(UEF2, 4000)
    ScenarioFramework.SetSharedUnitCap(4800)         
end
   
function OnStart(Self)
    ScenarioFramework.SetPlayableArea('AREA_1', false)

    ScenarioFramework.AddRestrictionForAllHumans(
        categories.ueb2401 + -- UEF end game
        categories.xeb2402 + -- UEF Novax
        categories.xab1401 + -- Aeon End game
        categories.xab2307 + -- Aeon End game2
        categories.url0401 + -- Cybran End game
        categories.ual0301 + -- Aeon SACU
        categories.url0301 + -- Cybran SACU
        categories.uel0301 + -- UEF SACU
        categories.uab0304 + -- Aeon Gate
        categories.urb0304 + -- Cybran Gate
        categories.ueb0304  -- UEF Gate
    )

    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P0Cam1'), 0)
    ForkThread(IntroP0)
end

--part 0

function IntroP0()
   
    ScenarioUtils.CreateArmyGroup('UEF1', 'P1U1Walls') 
    ScenarioUtils.CreateArmyGroup('UEF1', 'P0U1Mass')
    
    P0UEFAI.P0U1Base1AI()
    ArmyBrains[UEF1]:PBMSetCheckInterval(8)

    ScenarioInfo.P0SACU = ScenarioFramework.SpawnCommander('UEF1', 'UEFSACUP0', false, 'Captain Max', false, false,
    {'ResourceAllocation', 'RadarJammer', 'SensorRangeEnhancer'})
    ScenarioInfo.P0SACU:SetVeterancy(2 + Difficulty)

    Cinematics.EnterNISMode()
    
        WaitSeconds(1)
    
        local P0Vision1 = ScenarioFramework.CreateVisibleAreaLocation(90, ScenarioUtils.MarkerToPosition('P0Vision1'), 0, ArmyBrains[Player1])
        local P0Vision2 = ScenarioFramework.CreateVisibleAreaLocation(90, ScenarioUtils.MarkerToPosition('P0Vision2'), 0, ArmyBrains[Player1]) 
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P0Cam1'), 0)
        ScenarioFramework.Dialogue(OpStrings.IntroP1, nil, true)
        WaitSeconds(3)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P0Cam2'), 3)
        WaitSeconds(3)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P0Cam3'), 3)

        ScenarioInfo.PlayersACUs = {}

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

        WaitSeconds(1)
            ForkThread(
                function()
                    WaitSeconds(1)
                    P0Vision1:Destroy()
                    P0Vision2:Destroy()
                    WaitSeconds(1)
                    ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('P0Vision1'), 100)
                    ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('P0Vision2'), 100)
                end
            )

    Cinematics.ExitNISMode()    
  
    ArmyBrains[UEF1]:GiveResource('MASS', 4000)
    ArmyBrains[UEF1]:GiveResource('ENERGY', 6000)
    
    buffDef = Buffs['CheatIncome']
    buffAffects = buffDef.Affects
    buffAffects.EnergyProduction.Mult = 1.5
    buffAffects.MassProduction.Mult = 1.5

       for _, u in GetArmyBrain(UEF1):GetPlatoonUniquelyNamed('ArmyPool'):GetPlatoonUnits() do
               Buff.ApplyBuff(u, 'CheatIncome')
       end
    
    ForkThread(MissionP0)
    ScenarioFramework.CreateTimerTrigger(MidP0, 90)
    local quantity = {}

    quantity = {18, 14, 10}
    for _, player in ScenarioInfo.HumanPlayers do
        ScenarioFramework.CreateAreaTrigger(Offmapattacks0P0, 'AREA_1', categories.ALLUNITS - categories.TECH1, true, false, ArmyBrains[player], quantity[Difficulty])
    end
    quantity = {55, 45, 35}
    for _, player in ScenarioInfo.HumanPlayers do
        ScenarioFramework.CreateAreaTrigger(Offmapattacks2P0, 'AREA_1', categories.ALLUNITS - categories.TECH1, true, false, ArmyBrains[player], quantity[Difficulty])
    end   
end

function MissionP0()
    
    local function MissionNameAnnouncement()
        ScenarioFramework.SimAnnouncement(ScenarioInfo.name, "Mission by Shadowlorda1")
    end

    ScenarioFramework.CreateTimerTrigger(MissionNameAnnouncement, 12)

    ScenarioInfo.MissionNumber = 0

    ScenarioInfo.M1P0 = Objectives.Kill(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Kill SACU',                -- title
        'The Traitor\'s have a SACU building a base in the landing zone, kill him.', -- description
        {                              -- target
            MarkUnits = true,
            Units = {ScenarioInfo.P0SACU},   
        }
    )
    ScenarioInfo.M1P0:AddResultCallback(
        function(result)
            if result then
                ScenarioFramework.Dialogue(OpStrings.EndP1, nil, true)  
            end
        end
    )  

    ScenarioInfo.M2P0 = Objectives.CategoriesInArea(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Destroy UEF Base',                 -- title
        'Clear out the landing zone.',  -- description
        'kill',                         -- action
        {                               -- target
            MarkUnits = true,
            ShowProgress = true,
            Requirements = {
                {   
                    Area = 'AREA_1',
                    Category = categories.FACTORY + categories.ECONOMIC * (categories.TECH2 + categories.TECH3),
                    CompareOp = '<=',
                    Value = 0,
                    ArmyIndex = UEF1,
                },
            },
        }
    )   

    ScenarioInfo.M0Objectives = Objectives.CreateGroup('M0Objectives', StartIntroP1)
    ScenarioInfo.M0Objectives:AddObjective(ScenarioInfo.M1P0)
    ScenarioInfo.M0Objectives:AddObjective(ScenarioInfo.M2P0)

    if ExpansionTimer then
        local M0MapExpandDelay = {35*60, 25*60, 20*60}
        ScenarioFramework.CreateTimerTrigger(StartIntroP1, M0MapExpandDelay[Difficulty])
    end
end

function OffmapattacksP0()
    if ScenarioInfo.Offmap == 1 then
        return
    end
    ScenarioInfo.Offmap = 1
    
    P0UEFAI.P0ADDTML()

    for i = 1, 4 do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF1', 'P1U1Drop', 'GrowthFormation')
            CustomFunctions.PlatoonAttackWithTransports(platoon, 'P3IntDrop1', 'P3IntDropattack1', 'P3U2B1MK', true)
        end
end

function Offmapattacks2P0()
    if ScenarioInfo.Offmap2 == 1 then
        return
    end
    ScenarioInfo.Offmap2 = 1
    
    while ScenarioInfo.MissionNumber == 0 or ScenarioInfo.MissionNumber == 1 do
        
        local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF2', 'P1U2Drop_D' .. Difficulty, 'AttackFormation')
        CustomFunctions.PlatoonAttackWithTransports(platoon, 'P1U2Drop', 'P1U2Dropattack', 'P1U2TMK', true)

        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF2', 'P1U2Gunships_D' .. Difficulty, 'GrowthFormation')
        ScenarioFramework.PlatoonPatrolChain(platoon, 'P1U2Offmapattack'.. Random(1, 3))

        i = Random(1, 2)
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF2', 'P1U2Hover_D' .. Difficulty, 'GrowthFormation')
        platoon:MoveToLocation(ScenarioUtils.MarkerToPosition('P1U2OffmapattackM'.. i), false)
        ScenarioFramework.PlatoonPatrolChain(platoon, 'P1U2Offmapattack'.. i)

        WaitSeconds(Random(150, 240))
    end
end

function MidP0()

    ScenarioFramework.Dialogue(OpStrings.Jammer1P1, nil, true)
end

-- Part 1
   
function StartIntroP1()

    ForkThread(IntroP1)
end

function IntroP1()
    if ScenarioInfo.MissionNumber ~= 0 then
        return
    end
    ScenarioInfo.MissionNumber = 1
     WaitSeconds(5)
    ScenarioFramework.SetPlayableArea('AREA_2', true)

    P1UEFAI.P1U1Base1AI()
    P1UEFAI.P1U1Base2AI()

    ScenarioUtils.CreateArmyGroup('UEF1', 'P1ObjDefense')
    ScenarioInfo.NetworkCenter = ScenarioUtils.CreateArmyUnit('UEF1', 'P1NetworkCenter')
    ScenarioInfo.NetworkCenter:SetCustomName("Network Center")
    ScenarioInfo.NetworkCenter:SetReclaimable(false)
    ScenarioInfo.NetworkCenter:SetCapturable(true)
    ScenarioInfo.NetworkCenter:SetCanTakeDamage(false)
    ScenarioInfo.NetworkCenter:SetCanBeKilled(false)
    ScenarioInfo.NetworkCenter:SetDoNotTarget(true)
    
    Cinematics.EnterNISMode()
        Cinematics.SetInvincible('AREA_1')
    
        WaitSeconds(1)
    
        local P1Vision1 = ScenarioFramework.CreateVisibleAreaLocation(100, ScenarioUtils.MarkerToPosition('P1Vision1'), 0, ArmyBrains[Player1])
        local P1Vision2 = ScenarioFramework.CreateVisibleAreaLocation(100, ScenarioUtils.MarkerToPosition('P1Vision2'), 0, ArmyBrains[Player1]) 
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P1Cam1'), 0)
        ScenarioFramework.Dialogue(OpStrings.IntroP2, nil, true)
        WaitSeconds(2)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P1Cam2'), 3)
        WaitSeconds(3)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P2Cam1'), 3)
        WaitSeconds(1)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P1Cam3'), 3)
        WaitSeconds(2)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P0Cam3'), 2)
        ForkThread(
            function()
                WaitSeconds(1)
                P1Vision1:Destroy()
                P1Vision2:Destroy()
                WaitSeconds(1)
                ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('P1Vision1'), 110)
                ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('P1Vision2'), 110)
            end
        )
          
        WaitSeconds (1)
        Cinematics.SetInvincible('AREA_1', true)
    Cinematics.ExitNISMode()    
  
    ArmyBrains[UEF1]:GiveResource('MASS', 4000)
    ArmyBrains[UEF1]:GiveResource('ENERGY', 6000)
    
     buffDef = Buffs['CheatIncome']
    buffAffects = buffDef.Affects
    buffAffects.EnergyProduction.Mult = 2
    buffAffects.MassProduction.Mult = 2

       for _, u in GetArmyBrain(UEF1):GetPlatoonUniquelyNamed('ArmyPool'):GetPlatoonUnits() do
               Buff.ApplyBuff(u, 'CheatIncome')
       end
    
    ForkThread(MissionP1)   
    ForkThread(P1Intattacks)
    ForkThread(MissionP1Secondary) 
    SetupUEFP1TauntTriggers()
end

function MissionP1()

        ScenarioInfo.M1P1 = Objectives.Capture(
            'primary',                      -- type
            'incomplete',                   -- complete
            'Capture the Network Center',                -- title
            'We need to hack into the Prison systems. Capture that network center.', -- description
            {                              -- target
                MarkUnits = true,
                ShowProgress = true,
                Units = {ScenarioInfo.NetworkCenter}, 
            }
        )
        ScenarioInfo.M1P1:AddResultCallback(
        function(result)
            if result then
                ScenarioFramework.Dialogue(OpStrings.M1ObjectivecompleteP2, nil, true)  
            end
        end
    )
        
    ScenarioInfo.M1Objectives = Objectives.CreateGroup('M1Objectives', StartIntroP2)
    ScenarioInfo.M1Objectives:AddObjective(ScenarioInfo.M1P1)

    if ExpansionTimer then
        local M1MapExpandDelay = {40*60, 30*60, 25*60}
        ScenarioFramework.CreateTimerTrigger(StartIntroP2, M1MapExpandDelay[Difficulty])
    end
end

function MissionP1Secondary()
   
    ScenarioInfo.S1P1 = Objectives.CategoriesInArea(
        'secondary',                      -- type
        'incomplete',                   -- complete
        'Destroy the UEF Naval Base',                 -- title
        'That naval base is contesting control of the island, take it out.',  -- description
        'kill',                         -- action
        {                               -- target
            MarkUnits = true,
            ShowProgress = true,
            Requirements = {
                {   
                    Area = 'objsec1',
                    Category = categories.FACTORY + categories.ECONOMIC * (categories.TECH2 + categories.TECH3),
                    CompareOp = '<=',
                    Value = 0,
                    ArmyIndex = UEF1,
                },
                {   
                    Area = 'objsec2',
                    Category = categories.FACTORY + categories.ECONOMIC * (categories.TECH2 + categories.TECH3),
                    CompareOp = '<=',
                    Value = 0,
                    ArmyIndex = UEF1,
                },
            },
        }
    )
    ScenarioInfo.S1P1:AddResultCallback(
        function(result)
            if result then
                ScenarioFramework.Dialogue(OpStrings.SecondaryendP2, nil, true)  
            end
        end
    )   
end

function P1Intattacks()

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
        if(num > 5) then
            num = 5
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('UEF1', 'P1U1fighters', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P1U1B1Airattack' .. Random(1, 3))
        end
    end

    -- sends ASF if player has more than [50, 40, 30] planes, up to 10, 1 group per 14, 11, 10
    num = ScenarioFramework.GetNumOfHumanUnits(categories.AIR - categories.TECH1)
    quantity = {30, 15, 5}
    trigger = {20, 10, 5}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 3) then
            num = 3
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('UEF1', 'P1U1fighters2', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P1U1B1Airattack' .. Random(1, 3))
        end
    end

    -- sends swift winds if player has more than [60, 50, 40] planes, up to 10, 1 group per 14, 11, 10
    num = ScenarioFramework.GetNumOfHumanUnits(categories.ALLUNITS - categories.WALL)
    quantity = {200, 150, 100}
    trigger = {60, 50, 40}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 5) then
            num = 5
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('UEF1', 'P1U1Bombers', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P1U1B1Airattack' .. Random(1, 3))
        end
    end

    -- sends swift winds if player has more than [60, 50, 40] planes, up to 10, 1 group per 14, 11, 10
    num = ScenarioFramework.GetNumOfHumanUnits(categories.ALLUNITS - categories.TECH1)
    quantity = {30, 20, 10}
    trigger = {15, 10, 5}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 3) then
            num = 3
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('UEF1', 'P1U1gunships', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P1U1B1Airattack' .. Random(1, 3))
        end
    end

    -- sends Transport drops if player has more than [40, 30, 20] TECH 2, up to 4, 1 group per 20, 15, 10
    num = ScenarioFramework.GetNumOfHumanUnits(categories.ALLUNITS - categories.TECH1)
    quantity = {40, 35, 30}
    trigger = {30, 25, 20}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 3) then
            num = 3
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF1', 'P1U1Drop2', 'GrowthFormation')
            CustomFunctions.PlatoonAttackWithTransports(platoon, 'P3IntDrop1', 'P3IntDropattack1', 'P3U2B1MK', true)
        end
    end

    --Basic Land Attacks
    for i = 1, 3 do
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('UEF1', 'P1U1Land'.. i .. '_D' .. Difficulty, 'AttackFormation', 2 + Difficulty)
        ScenarioFramework.PlatoonPatrolChain(platoon, 'P1U1B1Landattack' .. i)
    end
end

-- Part 2

function StartIntroP2()

    ForkThread(IntroP2)
end

function IntroP2()
    if ScenarioInfo.MissionNumber ~= 1 then
        return
    end
    ScenarioInfo.MissionNumber = 2

    WaitSeconds(5)

    ScenarioFramework.SetPlayableArea('AREA_3', true)

    P2UEFAI.P2U1Base1AI()
    P2UEFAI.P2U1Base2AI()
    P2UEFAI.P2U2Base1AI()
    P2UEFAI.P2U2Base2AI()
    P2UEFAI.P2U2Base3AI()

    ScenarioUtils.CreateArmyGroup('UEF1', 'P2U1Walls')
    ScenarioUtils.CreateArmyGroup('UEF2', 'P2U2Walls') 
    ScenarioUtils.CreateArmyGroup('UEF1', 'P2U1Controlcenter') 
    
    ScenarioInfo.ControlCenter = ScenarioUtils.CreateArmyUnit('UEF1', 'ControlCenter')
    ScenarioInfo.ControlCenter:SetCustomName("Control Center")
    ScenarioInfo.ControlCenter:SetReclaimable(false)
    ScenarioInfo.ControlCenter:SetCapturable(true)
    ScenarioInfo.ControlCenter:SetCanTakeDamage(false)
    ScenarioInfo.ControlCenter:SetCanBeKilled(false)
    ScenarioInfo.ControlCenter:SetDoNotTarget(true)

    ScenarioInfo.Prison1 = ScenarioUtils.CreateArmyGroup('UEF2', 'P2U2Prison1')
    ScenarioInfo.Prison2 = ScenarioUtils.CreateArmyGroup('UEF2', 'P2U2Prison2')
    ScenarioInfo.Prison3 = ScenarioUtils.CreateArmyGroup('UEF2', 'P2U2Prison3')

    ScenarioInfo.PD1 = ScenarioUtils.CreateArmyGroup('UEF2', 'P2U2Prison1Defenses')
    ScenarioInfo.PD2 = ScenarioUtils.CreateArmyGroup('UEF2', 'P2U2Prison2Defenses')
    
    Cinematics.EnterNISMode()
        Cinematics.SetInvincible('AREA_2')
    
        WaitSeconds(1)
    
        local P2Vision1 = ScenarioFramework.CreateVisibleAreaLocation(100, ScenarioUtils.MarkerToPosition('P2Vision1'), 0, ArmyBrains[Player1])
        local P2Vision2 = ScenarioFramework.CreateVisibleAreaLocation(100, ScenarioUtils.MarkerToPosition('P2Vision2'), 0, ArmyBrains[Player1])
        ScenarioInfo.P2Prison1 = ScenarioFramework.CreateVisibleAreaLocation(20, ScenarioUtils.MarkerToPosition('P2Prison1'), 0, ArmyBrains[Player1])
        ScenarioInfo.P2Prison2 = ScenarioFramework.CreateVisibleAreaLocation(20, ScenarioUtils.MarkerToPosition('P2Prison2'), 0, ArmyBrains[Player1]) 
        ScenarioInfo.P2Prison3 = ScenarioFramework.CreateVisibleAreaLocation(20, ScenarioUtils.MarkerToPosition('P2Prison3'), 0, ArmyBrains[Player1])
 
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P2Cam1'), 0)
        ScenarioFramework.Dialogue(OpStrings.IntroP3, nil, true)
        WaitSeconds(2)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P2Cam2'), 3)
        WaitSeconds(3)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P2Cam3'), 3)
        WaitSeconds(1)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P2Cam4'), 3)
        ForkThread(
            function()
                WaitSeconds(1)
                P2Vision1:Destroy()
                P2Vision2:Destroy()
                WaitSeconds(1)
                ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('P2Vision1'), 110)
                ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('P2Vision2'), 110)
            end
        )
          
        WaitSeconds(1)
        Cinematics.SetInvincible('AREA_2', true)
    Cinematics.ExitNISMode()    
  
    ArmyBrains[UEF1]:GiveResource('MASS', 4000)
    ArmyBrains[UEF1]:GiveResource('ENERGY', 6000)
    
    buffDef = Buffs['CheatIncome']
    buffAffects = buffDef.Affects
    buffAffects.EnergyProduction.Mult = 2
    buffAffects.MassProduction.Mult = 2

       for _, u in GetArmyBrain(UEF1):GetPlatoonUniquelyNamed('ArmyPool'):GetPlatoonUnits() do
               Buff.ApplyBuff(u, 'CheatIncome')
       end

       for _, u in GetArmyBrain(UEF2):GetPlatoonUniquelyNamed('ArmyPool'):GetPlatoonUnits() do
               Buff.ApplyBuff(u, 'CheatIncome')
       end
    
    ForkThread(MissionP2)
    ScenarioFramework.CreateTimerTrigger(SecondaryMissionP2, 1*60) 
    ForkThread(P2Intattacks) 
    SetupUEFP2TauntTriggers()
end

function MissionP2()
    
    ScenarioInfo.M1P2 = Objectives.Kill(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Destroy The Northeastern Prison Complex',                -- title
        'We need to stop the prison break at all costs.', -- description
        {                              -- target
            MarkUnits = true,
            Units = ScenarioInfo.Prison1  
        }
    )
    ScenarioInfo.M1P2:AddResultCallback(
        function(result)
            if result then
               ScenarioInfo.P2Prison1:Destroy() 
            end
        end
    )

    ScenarioInfo.M2P2 = Objectives.Kill(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Destroy The Southern Prison Complex',                -- title
        'We need to stop the prison break at all costs.', -- description
        {                              -- target
            MarkUnits = true,
            Units = ScenarioInfo.Prison2  
        }
    )
    ScenarioInfo.M2P2:AddResultCallback(
        function(result)
            if result then
                ScenarioInfo.P2Prison2:Destroy() 
            end
        end
    )

    ScenarioInfo.M3P2 = Objectives.Kill(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Destroy The Northwestern Prison Complex',                -- title
        'We need to stop the prison break at all costs.', -- description
        {                              -- target
            MarkUnits = true,
            Units = ScenarioInfo.Prison3  
        }
    )
    ScenarioInfo.M3P2:AddResultCallback(
        function(result)
            if result then
                ScenarioInfo.P2Prison3:Destroy() 
            end
        end
    )

    ScenarioInfo.M2Objectives = Objectives.CreateGroup('M2Objectives', StartIntroP3)
    ScenarioInfo.M2Objectives:AddObjective(ScenarioInfo.M1P2)
    ScenarioInfo.M2Objectives:AddObjective(ScenarioInfo.M2P2)
    ScenarioInfo.M2Objectives:AddObjective(ScenarioInfo.M3P2)

    if ExpansionTimer then
        local M2MapExpandDelay = {40*60, 35*60, 28*60}
        ScenarioFramework.CreateTimerTrigger(StartIntroP3, M2MapExpandDelay[Difficulty])
    end
end

function SecondaryMissionP2()

    ScenarioInfo.S1P2 = Objectives.Capture(
        'secondary',                      -- type
        'incomplete',                   -- complete
        'Capture Control Center',                -- title
        'We can turn some of the prison defenses against the UEF traitors.', -- description
        {                              -- target
            MarkUnits = true,
            Units = {ScenarioInfo.ControlCenter}  
        }
    )
     ScenarioInfo.S1P2:AddResultCallback(
        function(result)
            if result then
                ForkThread(SecondaryCompleteP2)
            end
        end
    )    
end

function SecondaryCompleteP2()

    local PrisonPD1 = ScenarioFramework.GetCatUnitsInArea((categories.STRUCTURE * categories.DEFENSE), 'P2SecObj1', ArmyBrains[UEF2])
        for k, v in PrisonPD1 do
            if v and not v:IsDead() and (v:GetAIBrain() == ArmyBrains[UEF2]) then
                ScenarioFramework.GiveUnitToArmy( v, Player1 )
            end
        end

    local PrisonPD2 = ScenarioFramework.GetCatUnitsInArea((categories.STRUCTURE * categories.DEFENSE), 'P2SecObj2', ArmyBrains[UEF2])
        for k, v in PrisonPD2 do
            if v and not v:IsDead() and (v:GetAIBrain() == ArmyBrains[UEF2]) then
                ScenarioFramework.GiveUnitToArmy( v, Player1 )
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
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('UEF1', 'P2U1IntFighters', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P2U1IntAir' .. Random(1, 5))
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
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('UEF1', 'P2U1Bombers', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P2U1IntAir' .. Random(1, 5))
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('UEF2', 'P2U2Bombers', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P2U2IntAir' .. Random(1, 3))
        end
    end

    -- sends swift winds if player has more than [60, 50, 40] planes, up to 10, 1 group per 14, 11, 10
    num = ScenarioFramework.GetNumOfHumanUnits(categories.ALLUNITS - categories.WALL)
    quantity = {200, 150, 100}
    trigger = {60, 50, 40}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 6) then
            num = 6
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('UEF1', 'P2U1Intgunships', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P2U1IntAir' .. Random(1, 5))
        end
    end

    -- sends swift winds if player has more than [60, 50, 40] planes, up to 10, 1 group per 14, 11, 10
    num = ScenarioFramework.GetNumOfHumanUnits(categories.ALLUNITS * categories.TECH3)
    quantity = {40, 30, 20}
    trigger = {20, 15, 10}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 6) then
            num = 6
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('UEF2', 'P2U2Gunships', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P2U2IntAir' .. Random(1, 3))
        end
    end

    -- sends swift winds if player has more than [60, 50, 40] planes, up to 10, 1 group per 14, 11, 10
    num = ScenarioFramework.GetNumOfHumanUnits(categories.NAVAL * categories.MOBILE)
    quantity = {20, 15, 10}
    trigger = {15, 10, 5}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 5) then
            num = 5
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('UEF1', 'P2U1IntTorp', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P2U1IntAir' .. Random(1, 5))
            
        end
    end

    --Basic Naval Attacks
    for i = 1, 2 do
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('UEF1', 'P2U1Naval'.. i, 'AttackFormation', 2 + Difficulty)
        ScenarioFramework.PlatoonPatrolChain(platoon, 'P2U1IntNaval' .. i)   
    end

        platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('UEF2', 'P2U2Navalattack1', 'AttackFormation', 2 + Difficulty)
        ScenarioFramework.PlatoonPatrolChain(platoon, 'P2U2IntNaval1')

    --Basic Land Attacks
    for i = 1, 2 do
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('UEF2', 'P2U2Landattack' .. i, 'GrowthFormation', 2 + Difficulty)
        ScenarioFramework.PlatoonPatrolChain(platoon, 'P2U2IntLand'.. i)
    end 
end

-- Part 3

function StartIntroP3()

    ForkThread(IntroP3)
end

function IntroP3()
    if ScenarioInfo.MissionNumber ~= 2 then
        return
    end
    ScenarioInfo.MissionNumber = 3

    WaitSeconds(5)

    ScenarioFramework.SetPlayableArea('AREA_4', true)

    P3UEFAI.P3U1Base1AI()
    P3UEFAI.P3U1Base2AI()
    P3UEFAI.P3U1Base3AI()
    P3UEFAI.P3U1Base4AI()
    P3UEFAI.P3U2Base1AI()
    P3UEFAI.P3U2Base2AI()
    P3UEFAI.P3U2Base3AI()
    P3UEFAI.P3U2Base4AI()

    ScenarioUtils.CreateArmyGroup('UEF1', 'P3U1JammersD_D' .. Difficulty)
    ScenarioInfo.Jammer1 = ScenarioUtils.CreateArmyUnit('UEF1', 'P3U1Jammer1')
    ScenarioInfo.Jammer2 = ScenarioUtils.CreateArmyUnit('UEF1', 'P3U1Jammer2')
    ScenarioInfo.Jammer3 = ScenarioUtils.CreateArmyUnit('UEF1', 'P3U1Jammer3')

    ScenarioUtils.CreateArmyGroup('UEF1', 'P3U1Walls')
    ScenarioUtils.CreateArmyGroup('UEF2', 'P3U2Walls') 
    ScenarioUtils.CreateArmyGroup('UEF2', 'P3U2OutD_D'.. Difficulty) 

    local Antinukes = ArmyBrains[UEF1]:GetListOfUnits(categories.ueb4302, false)
            for _, v in Antinukes do
                v:GiveTacticalSiloAmmo(5)
            end
    local Antinukes2 = ArmyBrains[UEF2]:GetListOfUnits(categories.ueb4302, false)
            for _, v in Antinukes2 do
                v:GiveTacticalSiloAmmo(5)
            end

    local units = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF2', 'P3U2AirPatrol1', 'AttackFormation')
    for _, v in units:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P3U2B1AirPatrol1')))
    end
    units = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF2', 'P3U2AirPatrol2', 'AttackFormation')
    for _, v in units:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P3U2B1AirPatrol2')))
    end
    units = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF2', 'P3U2AirPatrol2', 'AttackFormation')
    for _, v in units:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P3U2B1AirPatrol3')))
    end

    local multiplier = {0, 1, 2}

    BuffBlueprint {
        Name = 'P3ACUEngBuildRate',
        DisplayName = 'P3ACUEngBuildRate',
        BuffType = 'AIBUILDRATE',
        Stacks = 'REPLACE',
        Duration = -1,
        EntityCategory = 'COMMAND',
        Affects = {
            BuildRate = {
                Add = 0,
                Mult = multiplier[Difficulty],
            },
        },
    }

    ScenarioInfo.P3U1ACU = ScenarioFramework.SpawnCommander('UEF1', 'U1ACU', false, 'Major Becca', false, UEF1CommanderKilled,
    {'AdvancedEngineering', 'T3Engineering', 'LeftPod', 'RightPod', 'ResourceAllocation'})
    ScenarioInfo.P3U1ACU:SetCanBeKilled(false)
    ScenarioInfo.P3U1ACU:SetAutoOvercharge(true)
    ScenarioInfo.P3U1ACU:SetVeterancy(2 + Difficulty)
    Buff.ApplyBuff(ScenarioInfo.P3U1ACU, 'P3ACUEngBuildRate')
    ScenarioFramework.CreateUnitDamagedTrigger(ACUDamaged, ScenarioInfo.P3U1ACU, .3)

    ScenarioInfo.P3U2ACU = ScenarioFramework.SpawnCommander('UEF2', 'U2ACU', false, 'Colonel Griff', false, UEF2CommanderKilled,
    {'DamageStabilization', 'Shield', 'ShieldGeneratorField', 'HeavyAntiMatterCannon'})
    ScenarioInfo.P3U2ACU:SetAutoOvercharge(true)
    ScenarioInfo.P3U2ACU:SetVeterancy(2 + Difficulty)

    ScenarioInfo.P3U2ACU:AddBuildRestriction(categories.ueb2301 + categories.ueb1302 + categories.ueb1202 + categories.ueb1103 + categories.ueb1106 + categories.ueb1105 + categories.ueb1201 + categories.ueb2101)

    Cinematics.EnterNISMode()
        Cinematics.SetInvincible('AREA_3')
        WaitSeconds(1)
    
        local P3Vision1 = ScenarioFramework.CreateVisibleAreaLocation(90, ScenarioUtils.MarkerToPosition('P3Vision1'), 0, ArmyBrains[Player1])
        local P3Vision2 = ScenarioFramework.CreateVisibleAreaLocation(90, ScenarioUtils.MarkerToPosition('P3Vision2'), 0, ArmyBrains[Player1]) 
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P3Cam1'), 0)
        ScenarioFramework.Dialogue(OpStrings.IntroP4, nil, true)
        WaitSeconds(2)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P3Cam2'), 3)
        WaitSeconds(3)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P3Cam3'), 3)
        WaitSeconds(3)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P0Cam3'), 2)
        ScenarioFramework.Dialogue(OpStrings.Intro2P4, nil, true)
        ForkThread(
            function()
                WaitSeconds(1)
                P3Vision1:Destroy()
                P3Vision2:Destroy()
                WaitSeconds(1)
                ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('P3Vision1'), 100)
                ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('P3Vision2'), 100)
            end
        )
        Cinematics.SetInvincible('AREA_3', true)
    Cinematics.ExitNISMode()    
    
    buffDef = Buffs['CheatIncome']
    buffAffects = buffDef.Affects
    buffAffects.EnergyProduction.Mult = 2
    buffAffects.MassProduction.Mult = 2

       for _, u in GetArmyBrain(UEF1):GetPlatoonUniquelyNamed('ArmyPool'):GetPlatoonUnits() do
               Buff.ApplyBuff(u, 'CheatIncome')
       end

       for _, u in GetArmyBrain(UEF2):GetPlatoonUniquelyNamed('ArmyPool'):GetPlatoonUnits() do
               Buff.ApplyBuff(u, 'CheatIncome')
       end
    
    ForkThread(MissionP3)   
    ForkThread(P3Intattacks)
    ForkThread(P3T4Arty)
    ForkThread(P3NovaxMonitor) 
    ForkThread(P3RandomPicker)
    ScenarioFramework.CreateTimerTrigger(SecondaryMissionP3, 90)
    ScenarioFramework.CreateArmyIntelTrigger(Secondary2MissionP3, ArmyBrains[Player1], 'LOSNow', false, true,  categories.ueb2401, true, ArmyBrains[UEF2] )
    SetupUEFP3TauntTriggers()
end

function MissionP3()
    
    ScenarioInfo.M1P3 = Objectives.Kill(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Kill the traitor Major Becca',                -- title
        'They must be stopped before they can cause more trouble.', -- description
        {                              -- target
            MarkUnits = true,
            Units = {ScenarioInfo.P3U1ACU}  
        }
    )

    ScenarioInfo.M2P3 = Objectives.Kill(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Kill the traitor Colonel Griff',                -- title
        'They must be stopped before they can cause more trouble.', -- description
        {                              -- target
            MarkUnits = true,
            Units = {ScenarioInfo.P3U2ACU}  
        }
    )

    ScenarioInfo.M3Objectives = Objectives.CreateGroup('M3Objectives', PlayerWin)
    ScenarioInfo.M3Objectives:AddObjective(ScenarioInfo.M1P3)
    ScenarioInfo.M3Objectives:AddObjective(ScenarioInfo.M2P3)
    if ScenarioInfo.M1P2.Active then
        ScenarioInfo.M3Objectives:AddObjective(ScenarioInfo.M1P2)
    end
    if ScenarioInfo.M2P2.Active then
        ScenarioInfo.M3Objectives:AddObjective(ScenarioInfo.M2P2)
    end 
    if ScenarioInfo.M3P2.Active then
        ScenarioInfo.M3Objectives:AddObjective(ScenarioInfo.M3P2)
    end
    if ScenarioInfo.M1P1.Active then
        ScenarioInfo.M3Objectives:AddObjective(ScenarioInfo.M1P1)
    end     
end 

function SecondaryMissionP3()
    
    ScenarioFramework.Dialogue(OpStrings.Secondary1P4, nil, true)

    ScenarioInfo.S1P3 = Objectives.Kill(
        'secondary',                      -- type
        'incomplete',                   -- complete
        'Destroy the Jammers',                -- title
        'If you can destroy the Jammers you will be able to get SACU support in.', -- description
        {                              -- target
            MarkUnits = true,
            FlashVisible = true,
            Units = {ScenarioInfo.Jammer1, ScenarioInfo.Jammer2, ScenarioInfo.Jammer3}  
        }
    )
    ScenarioInfo.S1P3:AddResultCallback(
        function(result)
            if result then
                ScenarioFramework.Dialogue(OpStrings.SecondarycompleteP4, nil, true)
                ScenarioFramework.PlayUnlockDialogue()
    
                ScenarioFramework.RemoveRestrictionForAllHumans(
                    categories.ueb2401 + -- UEF end game
                    categories.xeb2402 + -- UEF Novax
                    categories.xab1401 + -- Aeon End game
                    categories.xab2307 + -- Aeon End game2
                    categories.url0401 + -- Cybran End game
                    categories.ual0301 + -- Aeon SACU
                    categories.url0301 + -- Cybran SACU
                    categories.uel0301 + -- UEF SACU
                    categories.uab0304 + -- Aeon Gate
                    categories.urb0304 + -- Cybran Gate
                    categories.ueb0304  -- UEF Gate
                )
            end
        end
    )
end

function Secondary2MissionP3()
    
    ScenarioFramework.Dialogue(OpStrings.Secondary2P4, nil, true)

    ScenarioInfo.S2P3 = Objectives.CategoriesInArea(
        'secondary',                      -- type
        'incomplete',                   -- complete
        'Destroy the UEF Mavors',                 -- title
        'Both Traitors are constructing Mavors. Destroy them before they become a problem.',  -- description
        'kill',                         -- action
        {                               -- target
            MarkUnits = true,
            ShowProgress = true,
            Requirements = {
                {   
                    Area = 'P3Mavor1',
                    Category = categories.ueb2401 + categories.ENGINEER,
                    CompareOp = '==',
                    Value = 0,
                    ArmyIndex = UEF2,
                },
                {   
                    Area = 'P3Mavor2',
                    Category = categories.ueb2401 + categories.ENGINEER,
                    CompareOp = '==',
                    Value = 0,
                    ArmyIndex = UEF2,
                },
                {   
                    Area = 'P3Mavor3',
                    Category = categories.ueb2401 + categories.ENGINEER,
                    CompareOp = '==',
                    Value = 0,
                    ArmyIndex = UEF1,
                },
            },
        }
    )
    ScenarioInfo.S2P3:AddResultCallback(
        function(result)
            if result then
                ScenarioFramework.Dialogue(OpStrings.Secondary2completeP4, nil, true)
            end
        end
    )
end

function P3Intattacks()

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
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('UEF1', 'P3U1IntFighters', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P3U1IntAirattack' .. Random(1, 5))
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('UEF2', 'P3U2IntFighters', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P3U2IntAirattack' .. Random(1, 5))
        end
    end

    -- sends bombers if player has more than [60, 50, 40] planes, up to 10, 1 group per 14, 11, 10
    num = ScenarioFramework.GetNumOfHumanUnits(categories.STRUCTURE * categories.DEFENSE - categories.TECH1)
    quantity = {50, 40, 30}
    trigger = {25, 20, 15}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 7) then
            num = 7
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('UEF2', 'P3U2Bombers', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P3U2IntAirattack' .. Random(1, 3))
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('UEF1', 'P3U1Bombers', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P3U1IntAirattack' .. Random(1, 3))
        end
    end

    -- sends swift winds if player has more than [60, 50, 40] planes, up to 10, 1 group per 14, 11, 10
    num = ScenarioFramework.GetNumOfHumanUnits(categories.ALLUNITS - categories.WALL)
    quantity = {50, 30, 25}
    trigger = {20, 15, 10}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 7) then
            num = 7
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('UEF2', 'P3U2Gunships', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P3U2IntAirattack' .. Random(1, 3))
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('UEF1', 'P3U1Gunships', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P3U1IntAirattack' .. Random(1, 3))
        end
    end

    -- sends swift winds if player has more than [60, 50, 40] planes, up to 10, 1 group per 14, 11, 10
    num = ScenarioFramework.GetNumOfHumanUnits(categories.NAVAL * categories.MOBILE)
    quantity = {50, 30, 25}
    trigger = {20, 15, 10}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 7) then
            num = 7
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('UEF2', 'P3U2Gunships', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P3U2IntAirattack' .. Random(1, 3))
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('UEF1', 'P3U1Torpbombers', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P3U1IntAirattack' .. Random(1, 3))
        end
    end

    -- sends Exp Sub if player has more than [3, 2, 1] EXP, up to 3, 1 group per 3, 2, 1
    num = ScenarioFramework.GetNumOfHumanUnits(categories.EXPERIMENTAL)
    quantity = {3, 2, 1}
    trigger = {3, 2, 1}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 4) then
            num = 4
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('UEF2', 'P3U2NavalExp', 'GrowthFormation')
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P3U2IntNavalattack' .. Random(1, 3))
        end
    end

    -- sends transports if player has more than [250, 200, 150] Units, up to 3, 1 group per 100, 75, 50
    num = ScenarioFramework.GetNumOfHumanUnits(categories.ALLUNITS - categories.WALL)
    quantity = {250, 200, 150}
    trigger = {100, 75, 50}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 6) then
            num = 6
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF1', 'P3U1Transport', 'GrowthFormation')
            CustomFunctions.PlatoonAttackWithTransports(platoon, 'P3IntDrop1', 'P3IntDropattack1', 'P3U1B1MK', true)
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF2', 'P3U2Transports', 'GrowthFormation')
            CustomFunctions.PlatoonAttackWithTransports(platoon, 'P3IntDrop1', 'P3IntDropattack1', 'P3U2B1MK', true)
            local guard = ScenarioUtils.CreateArmyGroup('UEF2', 'P3U2IntFighters')
            IssueGuard(guard, platoon:GetPlatoonUnits()[1])
        end
    end

    local LandExp = ScenarioFramework.GetListOfHumanUnits(categories.EXPERIMENTAL * categories.LAND)
    local num = table.getn(LandExp)

    if num > 0 then
            quantity = {4, 3, 2}
            if num > quantity[Difficulty] then
                num = num
            end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF2', 'P3U2Landsnipe', 'GrowthFormation')
            IssueAttack(platoon:GetPlatoonUnits(), LandExp[i])
            IssueAggressiveMove(platoon:GetPlatoonUnits(), ScenarioUtils.MarkerToPosition('Player1'))
        end
    end

    local AirExp = ScenarioFramework.GetListOfHumanUnits(categories.EXPERIMENTAL * categories.AIR)
    local num = table.getn(AirExp)
    if num > 0 then
            quantity = {4, 3, 2}
            if num > quantity[Difficulty] then
                num = num
            end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF2', 'P3U2Airsnipe', 'GrowthFormation')
            IssueAttack(platoon:GetPlatoonUnits(), AirExp[i])
            IssueAggressiveMove(platoon:GetPlatoonUnits(), ScenarioUtils.MarkerToPosition('Player1'))
        end
    end

    local NavalExp = ScenarioFramework.GetListOfHumanUnits(categories.EXPERIMENTAL * categories.NAVAL)
    local num = table.getn(AirExp)
    if num > 0 then
            quantity = {4, 3, 2}
            if num > quantity[Difficulty] then
                num = num
            end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF2', 'P3U2Navalsnipe', 'GrowthFormation')
            IssueAttack(platoon:GetPlatoonUnits(), AirExp[i])
            IssueAggressiveMove(platoon:GetPlatoonUnits(), ScenarioUtils.MarkerToPosition('Player1'))
        end
    end

    --Basic Naval Attacks
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('UEF1', 'P3U1Navalattack1_D'.. Difficulty, 'AttackFormation', 2 + Difficulty)
        ScenarioFramework.PlatoonPatrolChain(platoon, 'P3U1IntNavalattack1')

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('UEF2', 'P3U2Navalattack1_D'.. Difficulty, 'AttackFormation', 2 + Difficulty)
        ScenarioFramework.PlatoonPatrolChain(platoon, 'P3U2IntNavalattack1')

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('UEF2', 'P3U2landExp_D'.. Difficulty, 'AttackFormation', 2 + Difficulty)
        ScenarioFramework.PlatoonPatrolChain(platoon, 'P3DropAttack1')
    local guard = ScenarioUtils.CreateArmyGroup('UEF2', 'P3U2IntFighters')
        IssueGuard(guard, platoon:GetPlatoonUnits()[1])
end

function P3T4Arty()

    P3UEFAI.P3U1MavAI()
    P3UEFAI.P3U2Mav1AI()
    P3UEFAI.P3U2Mav2AI()
end

function P3RandomPicker()
    
    ScenarioInfo.Specialfunction = Random(1, 3)
    
    if  ScenarioInfo.Specialfunction == 1 then
    
        P3UEFAI.P3U2NovaxAI()
        local novaxtbl2 = {}
        while true do
        local units = ArmyBrains[UEF2]:GetListOfUnits(categories.xea0002, false)
        for _, v in units do
            local id = v:GetEntityId()
            if not novaxtbl2[id] then
                novaxtbl2[id] = true
                local platoon = ArmyBrains[UEF2]:MakePlatoon('', '')
                ArmyBrains[UEF2]:AssignUnitsToPlatoon(platoon, {v}, 'Attack', 'AttackFormation')
                platoon.PlatoonData.TargetCats =  (categories.EXPERIMENTAL * categories.STRUCTURE) + (categories.EXPERIMENTAL * categories.MOBILE * categories.LAND)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P3U1B2Satattack1')
            end
        end
        WaitSeconds(30)
    end
        else
        if  ScenarioInfo.Specialfunction == 2 then
        
            ScenarioUtils.CreateArmyGroup('UEF2', 'P3Random2')

        else
            if  ScenarioInfo.Specialfunction == 3 then

            ScenarioUtils.CreateArmyGroup('UEF2', 'P3Random3')
            ForkThread(Nukeparty)
            end
        end
    end
end

function Nukeparty()

    WaitSeconds(5)
    local UEFNuke1 = ArmyBrains[UEF2]:GetListOfUnits(categories.ueb2305, false)
    for _, v in UEFNuke1 do
        v:GiveNukeSiloAmmo(4)
    end
    WaitSeconds(1)
    local UEFNukeP4s = {}
    for _, v in UEFNuke1 do
        table.insert(UEFNukeP4s, v)
    end

    local plat = ArmyBrains[UEF2]:MakePlatoon('', '')
    ArmyBrains[UEF2]:AssignUnitsToPlatoon(plat, {UEFNukeP4s[2]}, 'Attack', 'NoFormation')
    plat:ForkAIThread(plat.NukeAI)
end

function P3NovaxMonitor()
        local novaxtbl = {}
    while true do
        local units = ArmyBrains[UEF1]:GetListOfUnits(categories.xea0002, false)
        for _, v in units do
            local id = v:GetEntityId()
            if not novaxtbl[id] then
                novaxtbl[id] = true
                local platoon = ArmyBrains[UEF1]:MakePlatoon('', '')
                ArmyBrains[UEF1]:AssignUnitsToPlatoon(platoon, {v}, 'Attack', 'AttackFormation')
                platoon.PlatoonData.TargetCats =  (categories.EXPERIMENTAL * categories.STRUCTURE) + (categories.EXPERIMENTAL * categories.MOBILE * categories.LAND)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P3U1B2Satattack1')
            end
        end
        WaitSeconds(30)
    end
end

function ACUDamaged()
    if ScenarioFramework.NumCatUnitsInArea(categories.STRUCTURE - categories.WALL, 'P3Base2', ArmyBrains[UEF1]) > 10 then
        ForkThread(TeleportB2)
    elseif ScenarioFramework.NumCatUnitsInArea(categories.STRUCTURE - categories.WALL, 'P3Base3', ArmyBrains[UEF1]) > 10 then
        ForkThread(TeleportB3)
    else
        ForkThread(TeleportB4)
    end
end

function TeleportB2()
    ScenarioInfo.P3U1ACU:SetCanTakeDamage(false)
    ScenarioFramework.FakeTeleportUnit(ScenarioInfo.P3U1ACU)
    Warp(ScenarioInfo.P3U1ACU, ScenarioUtils.MarkerToPosition('P3TeleMK1'))
    ScenarioFramework.CreateUnitDamagedTrigger(ACUDamaged2, ScenarioInfo.P3U1ACU, .5)
    ScenarioInfo.P3U1ACU:SetCanTakeDamage(true)
    UpdateACUPlatoon('P3UEF1Base2')
end

function ACUDamaged2()

    ForkThread(TeleportB4)
end

function TeleportB3()
    ScenarioInfo.P3U1ACU:SetCanTakeDamage(false)
    ScenarioFramework.FakeTeleportUnit(ScenarioInfo.P3U1ACU)
    Warp(ScenarioInfo.P3U1ACU, ScenarioUtils.MarkerToPosition('P3TeleMK2'))
    ScenarioFramework.CreateUnitDamagedTrigger(ACUDamaged2, ScenarioInfo.P3U1ACU, .8)
    ScenarioInfo.P3U1ACU:SetCanTakeDamage(true)
    UpdateACUPlatoon('P3UEF1Base3')
end

function TeleportB4()
    ScenarioInfo.P3U1ACU:SetCanTakeDamage(false)
    ScenarioFramework.FakeTeleportUnit(ScenarioInfo.P3U1ACU)
    Warp(ScenarioInfo.P3U1ACU, ScenarioUtils.MarkerToPosition('P3TeleMK3'))
    ScenarioInfo.P3U1ACU:SetCanTakeDamage(true)
     ScenarioInfo.P3U1ACU:SetCanBeKilled(true)
    UpdateACUPlatoon('P3UEF1Base4')
end

function UpdateACUPlatoon(location)
    local function FindACUPlatoon()
        for _, platoon in ArmyBrains[UEF1]:GetPlatoonsList() do
            for _, unit in platoon:GetPlatoonUnits() do
                if unit == ScenarioInfo.P3U1ACU then
                    return platoon
                end
            end
        end
        WARN('ACU Platoon Not Found')
    end
    local platoon = FindACUPlatoon()
    if location == 'None' then
        IssueClearCommands({ScenarioInfo.P3U1ACU})
        LOG('Stopping CRD Platoon')
        platoon:StopAI()
        ArmyBrains[UEF1]:DisbandPlatoon(platoon)
        return
    end
    LOG('Changing ACU platoon for location: ' .. location)
    LOG('Old PlatoonData: ', repr(platoon.PlatoonData))
    platoon:StopAI()
    platoon.PlatoonData = {
        BaseName = location,
        LocationType = location,
    }
    platoon:ForkAIThread(import('/lua/AI/OpAI/BaseManagerPlatoonThreads.lua').BaseManagerSingleEngineerPlatoon)
    LOG('New PlatoonData: ', repr(platoon.PlatoonData))
end

function UEF1CommanderKilled()

    ScenarioFramework.CDRDeathNISCamera(ScenarioInfo.P3U1ACU, 3)
    ScenarioFramework.Dialogue(OpStrings.Death1, nil, true)
    if Difficulty < 3 then
        ForkThread(P3KillUEF1Base)  
    end
end

function UEF2CommanderKilled()

    ScenarioFramework.CDRDeathNISCamera(ScenarioInfo.P3U2ACU, 3)
    ScenarioFramework.Dialogue(OpStrings.Death2, nil, true)
    if Difficulty < 3 then
        ForkThread(P3KillUEF2Base)  
    end
end

function P3KillUEF1Base()
    local UEF1Units = ScenarioFramework.GetCatUnitsInArea((categories.ALLUNITS), 'AREA_4', ArmyBrains[UEF1])
        for k, v in UEF1Units do
            if v and not v.Dead then
                v:Kill()
            end
        end
end

function P3KillUEF2Base()
    local UEF2Units = ScenarioFramework.GetCatUnitsInArea((categories.ALLUNITS), 'AREA_4', ArmyBrains[UEF2])
        for k, v in UEF2Units do
            if v and not v.Dead then
                v:Kill()
            end
        end
end

-- Misc Functions

function PlayerWin()
    if not ScenarioInfo.OpEnded then
        ScenarioInfo.OpComplete = true
        ScenarioFramework.Dialogue(OpStrings.PlayerWin, KillGame, true)
    end
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

function KillGame()
    UnlockInput()
    ScenarioFramework.EndOperation(ScenarioInfo.OpComplete, ScenarioInfo.OpComplete, true)
end

--Taunts

function SetupUEFP1TauntTriggers()

    UEFTM:AddEnemiesKilledTaunt('TAUNT1P1', ArmyBrains[UEF1], categories.STRUCTURE, 10)
    UEFTM:AddUnitsKilledTaunt('TAUNT2P1', ArmyBrains[UEF1], categories.LAND * categories.MOBILE, 60)
    UEFTM:AddUnitsKilledTaunt('TAUNT3P1', ArmyBrains[UEF1], categories.STRUCTURE * categories.FACTORY, 6)
end

function SetupUEFP2TauntTriggers()

    UEFTM:AddEnemiesKilledTaunt('TAUNT1P2', ArmyBrains[UEF1], categories.STRUCTURE, 10)
    UEFTM:AddUnitsKilledTaunt('TAUNT2P2', ArmyBrains[UEF1], categories.LAND * categories.MOBILE, 60)
    UEFTM:AddUnitsKilledTaunt('TAUNT3P2', ArmyBrains[UEF2], categories.STRUCTURE * categories.FACTORY, 4)
    UEFTM:AddUnitsKilledTaunt('TAUNT4P2', ArmyBrains[UEF1], categories.STRUCTURE * categories.FACTORY, 6)
end

function SetupUEFP3TauntTriggers()

    UEFTM:AddEnemiesKilledTaunt('TAUNT1P3', ArmyBrains[UEF2], categories.STRUCTURE, 10)
    UEFTM:AddUnitsKilledTaunt('TAUNT2P3', ArmyBrains[UEF2], categories.LAND * categories.MOBILE, 60)
    UEFTM:AddUnitsKilledTaunt('TAUNT3P3', ArmyBrains[UEF2], categories.STRUCTURE * categories.FACTORY, 6)
    UEFTM:AddEnemiesKilledTaunt('TAUNT4P3', ArmyBrains[UEF1], categories.STRUCTURE, 10)
    UEFTM:AddUnitsKilledTaunt('TAUNT5P3', ArmyBrains[UEF1], categories.LAND * categories.MOBILE, 60)
end

