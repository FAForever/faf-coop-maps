------------------------------
-- Seraphim Campaign - Mission 5
--
-- Author: Shadowlorda1
-- Map: !MarLo
------------------------------
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local Buff = import('/lua/sim/Buff.lua')
local Cinematics = import('/lua/cinematics.lua')
local Objectives = import('/lua/ScenarioFramework.lua').Objectives
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local Utilities = import('/lua/Utilities.lua')
local P1SeraphimAI = import('/maps/FAF_Coop_Operation_Overlord_Surth_Velsok/SeraphimaiP1.lua')
local P2SeraphimAI = import('/maps/FAF_Coop_Operation_Overlord_Surth_Velsok/SeraphimaiP2.lua')
local P3SeraphimAI = import('/maps/FAF_Coop_Operation_Overlord_Surth_Velsok/SeraphimaiP3.lua')
local P2CybranAI = import('/maps/FAF_Coop_Operation_Overlord_Surth_Velsok/CybranaiP2.lua')
local P3CybranAI = import('/maps/FAF_Coop_Operation_Overlord_Surth_Velsok/CybranaiP3.lua')
local OpStrings = import('/maps/FAF_Coop_Operation_Overlord_Surth_Velsok/FAF_Coop_Operation_Overlord_Surth_Velsok_strings.lua') 
local CustomFunctions = import('/maps/FAF_Coop_Operation_Overlord_Surth_Velsok/FAF_Coop_Operation_Overlord_Surth_Velsok_CustomFunctions.lua')

local TauntManager = import('/lua/TauntManager.lua')

local SeraphimTM = TauntManager.CreateTauntManager('SeraphimTM', '/maps/FAF_Coop_Operation_Overlord_Surth_Velsok/FAF_Coop_Operation_Overlord_Surth_Velsok_strings.lua')
local CybranTM = TauntManager.CreateTauntManager('CybranTM', '/maps/FAF_Coop_Operation_Overlord_Surth_Velsok/FAF_Coop_Operation_Overlord_Surth_Velsok_strings.lua')

local Difficulty = ScenarioInfo.Options.Difficulty

ScenarioInfo.Player1 = 1
ScenarioInfo.Seraphim = 2
ScenarioInfo.Cybran = 3
ScenarioInfo.Player2 = 4
ScenarioInfo.Player3 = 5
ScenarioInfo.Player4 = 6

local Player1 = ScenarioInfo.Player1
local Seraphim = ScenarioInfo.Seraphim
local Cybran = ScenarioInfo.Cybran
local Player2 = ScenarioInfo.Player2
local Player3 = ScenarioInfo.Player3
local Player4 = ScenarioInfo.Player4

local LeaderFaction
local LocalFaction
local AIs = {Seraphim, Cybran}
local BuffCategories = {
    BuildPower = (categories.FACTORY * categories.STRUCTURE) + categories.ENGINEER,
    Economy = categories.ECONOMIC,
}

local AssignedObjectives = {}
local ExpansionTimer = ScenarioInfo.Options.Expansion == 'true'
local Debug = false

function OnPopulate(scen)
    ScenarioUtils.InitializeScenarioArmies()
    
    ScenarioFramework.SetPlayableArea('AREA_1', false)
    
    ScenarioFramework.SetSeraphimColor(Player1)
    ScenarioFramework.SetCybranPlayerColor(Cybran)
    
     local colors = {
        
        ['Player2'] = {255, 191, 128}, 
        ['Player3'] = {189, 116, 16}, 
        ['Player4'] = {89, 133, 39},
        ['Seraphim'] = {95, 1, 165},      
       }
    local tblArmy = ListArmies()
    for army, color in colors do
        if tblArmy[ScenarioInfo[army]] then
            ScenarioFramework.SetArmyColor(ScenarioInfo[army], unpack(color))
        end
    end
    
    SetArmyUnitCap(Seraphim, 2000)
    SetArmyUnitCap(Cybran, 2000)
    ForkThread(BuffAIEconomy)  
    ScenarioFramework.SetSharedUnitCap(4800)         
end
   
function OnStart(scen)
     
    ScenarioFramework.AddRestrictionForAllHumans(
            categories.UEF + -- UEF faction
            categories.url0401 +
            categories.xab1401 +
            categories.xab2307 +
            categories.xsb2401  -- Seraph exp Nuke       
    )  
    ForkThread(IntroP1)

    for _, army in AIs do
        ArmyBrains[army].IMAPConfig = {
                OgridRadius = 0,
                IMAPSize = 0,
                Rings = 0,
        }
        ArmyBrains[army]:IMAPConfiguration()
    end
end

-- Part 1
   
function IntroP1()

    ScenarioInfo.MissionNumber = 1
   
    ScenarioUtils.CreateArmyGroup('Seraphim', 'P1Swalls') 
    ScenarioUtils.CreateArmyGroup( 'Seraphim', 'P1SBase2Eng_D' .. Difficulty)
    ScenarioUtils.CreateArmyGroup( 'Seraphim', 'P1SBase3Eng_D' .. Difficulty)
    
    ScenarioInfo.Comtower = ScenarioUtils.CreateArmyUnit('Seraphim', 'P1Obj')
    ScenarioInfo.Comtower:SetCustomName("Quantum Broadcast Station")
    ScenarioInfo.Comtower:SetReclaimable(false)
    ScenarioInfo.Comtower:SetCapturable(false)
    ScenarioInfo.Comtower:SetCanTakeDamage(true)
    ScenarioInfo.Comtower:SetCanBeKilled(true) 
    ScenarioInfo.Comtower:SetMaxHealth(10000)
    ScenarioInfo.Comtower:SetHealth(ScenarioInfo.Comtower, 10000)
     
    P1SeraphimAI.P1S1Base1AI()
    P1SeraphimAI.P1S1Base2AI()
    P1SeraphimAI.P1S1Base3AI()
    P1SeraphimAI.P1S1Base4AI()
    
    Cinematics.EnterNISMode()
    
        WaitSeconds(1)
        ScenarioFramework.Dialogue(OpStrings.IntroP1, nil, true)
        local P1Vision1 = ScenarioFramework.CreateVisibleAreaLocation(90, ScenarioUtils.MarkerToPosition('P1Vision1'), 0, ArmyBrains[Player1]) 
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P1Cam1'), 0)
        WaitSeconds(2)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P1Cam2'), 3)
        WaitSeconds(3)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P1Cam3'), 3)
        WaitSeconds(2)
        ForkThread(
            function()
                WaitSeconds(1)
                P1Vision1:Destroy()
                WaitSeconds(1)
                ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('P1Vision1'), 100)
            end
        )

        -- Gets player number and joins it to a string to make it refrence a camera marker e.g 'Cam_M1_Intro_Player1'
        local army = GetFocusArmy()
        if army == -1 then
        army = 1
        end
        local tblArmy = ListArmies()
        ScenarioInfo.PlayerCamString = tostring(tblArmy[army])

        Cinematics.CameraMoveToMarker('P1C' .. ScenarioInfo.PlayerCamString)
          
        WaitSeconds(1)

        ScenarioInfo.PlayersACUs = {}
    
        ScenarioInfo.PlayerCDR = ScenarioFramework.SpawnCommander('Player1', 'Commander', 'Warp', true, true, PlayerDeath)
        table.insert(ScenarioInfo.PlayersACUs, ScenarioInfo.PlayerCDR)

        -- spawn coop players too
        ScenarioInfo.CoopCDR = {}
        local tblArmy = ListArmies()
        coop = 1
        for iArmy, strArmy in pairs(tblArmy) do
            if iArmy >= ScenarioInfo.Player2 then
                factionIdx = GetArmyBrain(strArmy):GetFactionIndex()
                if (factionIdx == 3) then
                    ScenarioInfo.CoopCDR[coop] = ScenarioFramework.SpawnCommander(strArmy, 'CCommander', 'Warp', true, true, PlayerDeath)
                    table.insert(ScenarioInfo.PlayersACUs, ScenarioInfo.CoopCDR[coop])
                elseif (factionIdx == 2) then
                    ScenarioInfo.CoopCDR[coop] = ScenarioFramework.SpawnCommander(strArmy, 'ACommander', 'Warp', true, true, PlayerDeath)
                    table.insert(ScenarioInfo.PlayersACUs, ScenarioInfo.CoopCDR[coop])
                else
                    ScenarioInfo.CoopCDR[coop] = ScenarioFramework.SpawnCommander(strArmy, 'Commander', 'Warp', true, true, PlayerDeath)
                    table.insert(ScenarioInfo.PlayersACUs, ScenarioInfo.CoopCDR[coop])   
                end
                coop = coop + 1
                WaitSeconds(0.5)
            end
        end 
        
    Cinematics.ExitNISMode()    
    
    ForkThread(MissionP1)  
    ScenarioFramework.CreateTimerTrigger(SecondaryMissionP1, 180) 
    SetupSeraTM1TauntTriggers() 
end

function MissionP1()
    
    local function MissionNameAnnouncement()
        ScenarioFramework.SimAnnouncement(ScenarioInfo.name, "Mission by Shadowlorda1, Map by !MarLo")
    end

    ScenarioFramework.CreateTimerTrigger(MissionNameAnnouncement, 12)

    ScenarioInfo.M1P1 = Objectives.Kill(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Destroy the Broadcast Tower',                 -- title
        'Velsok is broadcasting an SOS to the Coalition, destroy it.',  -- description
        
        {                               -- target
             MarkUnits = true,
             Units = {ScenarioInfo.Comtower}
             
          }
    )
    ScenarioInfo.M1P1:AddResultCallback(
        function(result)
            if(result) then
                ForkThread(IntroP2) 
            end
        end
    )  
    if ExpansionTimer then
        local M1MapExpandDelay = {40*60, 30*60, 25*60}
        ScenarioFramework.CreateTimerTrigger(IntroP2, M1MapExpandDelay[Difficulty])
    end
end

function SecondaryMissionP1()

    ScenarioFramework.Dialogue(OpStrings.SecondaryP1, nil, true)

    ScenarioInfo.S1P1 = Objectives.CategoriesInArea(
    'secondary',                      -- type
    'incomplete',                   -- complete
    'Destroy Seraphim Support Bases',    -- title
    'Velsok has built several small bases to constest your landing zone, clear them out.',  -- description
    'kill',                         -- action
       {                               -- target
        MarkUnits = true,
        Requirements = {
            {   
                Area = 'P1SObj1',
                Category = categories.FACTORY + categories.TECH2 * categories.ECONOMIC,
                CompareOp = '<=',
                Value = 0,
                ArmyIndex = Seraphim,
            },
            {   
                Area = 'P1SObj2',
                Category = categories.FACTORY + categories.TECH2 * categories.ECONOMIC,
                CompareOp = '<=',
                Value = 0,
                ArmyIndex = Seraphim,
            },
            {   
                Area = 'P1SObj3',
                Category = categories.FACTORY + categories.TECH2 * categories.ECONOMIC,
                CompareOp = '<=',
                Value = 0,
                ArmyIndex = Seraphim,
            },
        },
        Category = categories.xsb0202,
       }
    )
    ScenarioInfo.S1P1:AddResultCallback(
        function(result)
            if(result) then
                ScenarioFramework.Dialogue(OpStrings.SecondaryEndP1, nil, true)
            end
        end
    )  
end

function MidP1()

    ScenarioFramework.Dialogue(OpStrings.MidP1, nil, true)
end

-- Part 2

function IntroP2()
    ScenarioFramework.FlushDialogueQueue()
    WaitSeconds(5)
    
    if ScenarioInfo.MissionNumber ~= 1 then
        return
    end
    ScenarioInfo.MissionNumber = 2
    
    ScenarioFramework.SetPlayableArea('AREA_2', false)
   
    ScenarioUtils.CreateArmyGroup('Seraphim', 'P2SWalls')
    ScenarioUtils.CreateArmyGroup('Cybran', 'P2CWalls')
    ScenarioUtils.CreateArmyGroup('Seraphim', 'P2SEco')    
    
    P2SeraphimAI.P2S1Base1AI()
    P2SeraphimAI.P2S1Base2AI()
    P2SeraphimAI.P2S1Base3AI()
    P2CybranAI.P2C1Base1AI()

    local Antinukes = ArmyBrains[Seraphim]:GetListOfUnits(categories.xsb4302, false)
    for _, v in Antinukes do
        v:GiveTacticalSiloAmmo(5)
    end
    
    ScenarioInfo.P2SACU = ScenarioFramework.SpawnCommander('Seraphim', 'P2SACU', false, 'Overlord Surth-Velsok', true, false,
    {'RateOfFire', 'DamageStabilization', 'DamageStabilizationAdvanced', 'AdvancedEngineering', 'T3Engineering'})
    ScenarioInfo.P2SACU:SetCanBeKilled(false)
    ScenarioInfo.P2SACU:SetAutoOvercharge(true)
    ScenarioInfo.P2SACU:SetVeterancy(1 + Difficulty)
    ScenarioFramework.CreateUnitDamagedTrigger(SeraACUDamaged, ScenarioInfo.P2SACU, .2)  
    ScenarioInfo.P2SACU:AddBuildRestriction(categories.ARTILLERY) 
    
    ScenarioInfo.P2Gate = ScenarioUtils.CreateArmyUnit('Seraphim', 'P2SGate')
    ScenarioInfo.P2Gate:SetCustomName("Velsok's Gate")
    ScenarioInfo.P2Gate:SetReclaimable(false)
    ScenarioInfo.P2Gate:SetCapturable(false)
    ScenarioInfo.P2Gate:SetCanTakeDamage(true)
    ScenarioInfo.P2Gate:SetCanBeKilled(true)   
    
    units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'P2SB1LandPatrol1_D' .. Difficulty, 'GrowthFormation')
    for _, v in units:GetPlatoonUnits() do
       ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P2SB1LandPatrol')))
    end
    
    units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'P2SB2LandPatrol1_D' .. Difficulty, 'GrowthFormation')
    for _, v in units:GetPlatoonUnits() do
       ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P2SB2LandPatrol')))
    end
    
    units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'P2SB3LandPatrol1_D' .. Difficulty, 'GrowthFormation')
    for _, v in units:GetPlatoonUnits() do
       ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P2SB3LandPatrol')))
    end
    
    Cinematics.EnterNISMode()
        Cinematics.SetInvincible('AREA_1') 
        WaitSeconds(1)
    
        local P2Vision1 = ScenarioFramework.CreateVisibleAreaLocation(40, ScenarioUtils.MarkerToPosition('P2Vision1'), 0, ArmyBrains[Player1]) 
        local P2Vision2 = ScenarioFramework.CreateVisibleAreaLocation(80, ScenarioUtils.MarkerToPosition('P2Vision2'), 0, ArmyBrains[Player1]) 
        local P2Vision3 = ScenarioFramework.CreateVisibleAreaLocation(70, ScenarioUtils.MarkerToPosition('P2Vision3'), 0, ArmyBrains[Player1]) 
        ScenarioFramework.Dialogue(OpStrings.IntroP2, nil, true)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P2Cam2'), 0)
        WaitSeconds(3)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P2Cam3'), 3)
        ForkThread(SeraCounterAttack)
        WaitSeconds(4)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P2Cam1'), 2)
        WaitSeconds(3)
            ForkThread(
                function()
                    WaitSeconds(1)
                    P2Vision1:Destroy()
                    P2Vision2:Destroy()
                    P2Vision3:Destroy()
                    WaitSeconds(1)
                    ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('P2Vision1'), 60)
                    ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('P2Vision2'), 100)
                    ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('P2Vision3'), 90)  
                end
            )
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P1CPlayer1'), 2)
          
        WaitSeconds (1)
        Cinematics.SetInvincible('AREA_1', true) 
    Cinematics.ExitNISMode()    

    ForkThread(MissionP2) 
    ScenarioFramework.CreateTimerTrigger(SecondaryMissionP2, 360)  
    ScenarioFramework.CreateTimerTrigger(Part2Mid1, 5*60)  
    ScenarioFramework.CreateTimerTrigger(Part2Mid2, 15*60)  
    SetupSeraTM2TauntTriggers()      
end

function MissionP2()

    ScenarioInfo.M1P2 = Objectives.Kill(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Kill Velsok',                 -- title
        'Velsok is trying to escape with a gate, stop him.',  -- description
        {                               -- target
            MarkUnits = true,
            Units = {ScenarioInfo.P2SACU}   
        }
    )
    
    ScenarioInfo.M2P2 = Objectives.Kill(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Destroy the Gate',                 -- title
        'Velsok is trying to escape with a gate, stop him.',  -- description
        {                               -- target
            MarkUnits = true,
            Units = {ScenarioInfo.P2Gate}
             
        }
    )

    ScenarioInfo.M2Objectives = Objectives.CreateGroup('M3Objectives', IntroStartP3)
    ScenarioInfo.M2Objectives:AddObjective(ScenarioInfo.M2P2)
    ScenarioInfo.M2Objectives:AddObjective(ScenarioInfo.M1P2)

    if ExpansionTimer then
        local M2MapExpandDelay = {40*60, 30*60, 25*60}
        ScenarioFramework.CreateTimerTrigger(IntroStartP3, M2MapExpandDelay[Difficulty])  
    end
end

function SecondaryMissionP2()

    ScenarioFramework.Dialogue(OpStrings.SecondaryP2, nil, true)
    WaitSeconds(5)

    ScenarioInfo.S1P2 = Objectives.CategoriesInArea(
    'secondary',                      -- type
    'incomplete',                   -- complete
    'Destroy Cybran base',    -- title
    'A Cybran base is set up to the east of your location.',  -- description
    'kill',                         -- action
        {                               -- target
            MarkUnits = true,
            Requirements = {
                {   
                    Area = 'P2SObj1',
                    Category = categories.FACTORY + categories.TECH2 * categories.ECONOMIC,
                    CompareOp = '<=',
                    Value = 0,
                    ArmyIndex = Cybran,
                },
            },
        }
    )

    WaitSeconds(140)
    ScenarioFramework.Dialogue(OpStrings.Secondary2P2, nil, true)
    WaitSeconds(5)
    ScenarioInfo.S2P2 = Objectives.ArmyStatCompare(
        'secondary',                      -- type
        'incomplete',                   -- complete
        'Build 3 Anti Nuke Defenses',                 -- title
        'Velsok is constructing a Experimental nuke launcher farther north. In case he finishes it you should be prepared',  -- description
        'build',                        -- action
        {                               -- target
            Armies = {'HumanPlayers'},
            StatName = 'Units_Active',
            CompareOp = '>=',
            Value = 1,
            Category = categories.xsb4302 + categories.urb4302 + categories.uab4302,
        }
    )
    ScenarioInfo.S2P2:AddResultCallback(
        function(result)
            if(result) then
                ScenarioFramework.Dialogue(OpStrings.Secondary2EndP2, nil, true)
                local Antinukes = ArmyBrains[Player1]:GetListOfUnits(categories.xsb4302, false)
                for _, v in Antinukes do
                    v:GiveTacticalSiloAmmo(1)
                end
            end
        end
    )  
end

function SeraACUDamaged()
    ForkThread(SeraACUWarp1)
end

function SeraACUWarp1()
    ScenarioInfo.P2SACU:SetCanTakeDamage(false)
    ScenarioFramework.FakeTeleportUnit(ScenarioInfo.P2SACU, true)
    ScenarioInfo.M1P2:ManualResult(true)
end

function SeraCounterAttack()

    local units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'P2SIntLandattack1_D' .. Difficulty, 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(units, 'P2SIntlandattack1' )
    
    units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'P2SIntLandattack2_D' .. Difficulty, 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(units, 'P2SIntlandattack2' )

    local quantity = {}
    local trigger = {}
    local platoon

    -- sends Gunships if player has more than [60, 50, 40] Units, up to 10, 1 group per 14, 11, 10
    num = ScenarioFramework.GetNumOfHumanUnits(categories.ALLUNITS - categories.WALL)
    quantity = {200, 150, 100}
    trigger = {40, 35, 30}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 5) then
            num = 5
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Seraphim', 'P2SIntGunships', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P2SIntAirattack' .. Random(1, 4))
        end
    end

    -- sends ASF if player has more than [30, 20, 10] Air, up to 3, 1 group per 3, 2, 1
    num = ScenarioFramework.GetNumOfHumanUnits(categories.AIR * categories.MOBILE)
    quantity = {30, 20, 10}
    trigger = {20, 15, 10}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 5) then
            num = 5
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Seraphim', 'P2SIntFighters', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P2SIntAirattack' .. Random(1, 4))
        end
    end

    -- sends EXP if player has more than [3, 2, 1] EXP
    num = ScenarioFramework.GetNumOfHumanUnits(categories.EXPERIMENTAL)
    quantity = {3, 2, 1}
    if num > quantity[Difficulty] then
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Seraphim', 'P2Expattack', 'GrowthFormation', 5)
        ScenarioFramework.PlatoonPatrolChain(platoon, 'P2SIntlandattack1')
    end
end

function Part2Mid1()
    ScenarioFramework.Dialogue(OpStrings.MidP2, nil, true)
end

function Part2Mid2()
    ScenarioFramework.Dialogue(OpStrings.Mid2P2, nil, true)
end

-- Part 3
function IntroStartP3()
    ScenarioFramework.Dialogue(OpStrings.EndP2, nil, true)
    ForkThread(IntroP3)
end

function IntroP3()
    ScenarioFramework.FlushDialogueQueue()
    WaitSeconds(5)
    
    if ScenarioInfo.MissionNumber ~= 2  then
        return
    end
    ScenarioInfo.MissionNumber = 3
    
    ScenarioFramework.SetPlayableArea('AREA_3', false)

    ScenarioUtils.CreateArmyGroup('Cybran', 'P3CArtyBase1')
    P3CybranAI.P3C1Base1AI()
    P3CybranAI.P3C1Base2AI()

    local Antinukes = ArmyBrains[Cybran]:GetListOfUnits(categories.urb4302, false)
    for _, v in Antinukes do
        v:GiveTacticalSiloAmmo(4)
    end

    if ScenarioInfo.M1P2.Active then
        SeraACUDamaged()
    end
    ForkThread(CybranCounterAttack)

    local units = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'P3CAssaultAir', 'GrowthFormation')
    for _, v in units:GetPlatoonUnits() do
       ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P3CB1Airpatrol1')))
    end
    units = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'P3CAssaultAir', 'GrowthFormation')
    for _, v in units:GetPlatoonUnits() do
       ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P3CB1Airpatrol2')))
    end
    units = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'P3CAssaultAir', 'GrowthFormation')
    for _, v in units:GetPlatoonUnits() do
       ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P3CB1Airpatrol3')))
    end

    Cinematics.EnterNISMode()
        Cinematics.SetInvincible('AREA_1')
        WaitSeconds(1)
    
        local P3Vision1 = ScenarioFramework.CreateVisibleAreaLocation(60, ScenarioUtils.MarkerToPosition('P3Vision1'), 0, ArmyBrains[Player1]) 
        local P3Vision2 = ScenarioFramework.CreateVisibleAreaLocation(70, ScenarioUtils.MarkerToPosition('P3Vision2'), 0, ArmyBrains[Player1]) 
        local P3Vision3 = ScenarioFramework.CreateVisibleAreaLocation(70, ScenarioUtils.MarkerToPosition('P3Vision3'), 0, ArmyBrains[Player1]) 
        ScenarioFramework.Dialogue(OpStrings.IntroP3, nil, true)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P3Cam1'), 0)
        WaitSeconds(2)   
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P3Cam2'), 4)
        WaitSeconds(3)
        ForkThread(SubNukeparty)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P3Cam3'), 4)
        WaitSeconds(3)
        ForkThread(
            function()
               WaitSeconds(1)
               P3Vision1:Destroy()
               P3Vision2:Destroy()
               P3Vision3:Destroy()
               WaitSeconds(1)
               ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('P3Vision1'), 70)
               ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('P3Vision2'), 80)
               ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('P3Vision3'), 80)  
            end
        )
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P1CPlayer1'), 1)
          
        WaitSeconds(1)
        Cinematics.SetInvincible('AREA_1', true) 
    Cinematics.ExitNISMode()    
    
    ForkThread(MissionP3)
    ForkThread(EnableStealthOnAir)   
    SetupCybranTM3TauntTriggers()
end

function CybranCounterAttack()
    local quantity = {}
    local trigger = {}
    local platoon

    ScenarioInfo.M3CounterAttackUnits = {}

    local function AddUnitsToObjTable(platoon)
        for _, v in platoon:GetPlatoonUnits() do
            if not EntityCategoryContains(categories.TRANSPORTATION + categories.SCOUT + categories.SHIELD, v) then
                table.insert(ScenarioInfo.M3CounterAttackUnits, v)
            end
        end
    end

    -- land attacks
    for i = 1, 3 do
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Cybran', 'P3CAssaultLand'.. i ..'_D' .. Difficulty, 'GrowthFormation', 5)
        ScenarioFramework.PlatoonPatrolChain(platoon, 'P3C1IntLandattack' .. i)
        AddUnitsToObjTable(platoon)
    end

    for i = 1, 3 do
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Cybran', 'P3CAssaultLandExp'.. i, 'GrowthFormation', 5)
        ScenarioFramework.PlatoonPatrolChain(platoon, 'P3C1IntLandattack' .. i)
        AddUnitsToObjTable(platoon)
    end

    quantity = {1, 2, 3}
    for i = 1, quantity[Difficulty] do
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Cybran', 'P3CAssaultMega', 'GrowthFormation', 5)
        ScenarioFramework.PlatoonPatrolChain(platoon, 'P3C1IntLandattack' .. i)
        AddUnitsToObjTable(platoon)
    end

    -- naval attacks
    for i = 1, 2 do
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Cybran', 'P3CNaval'.. i, 'GrowthFormation', 5)
        ScenarioFramework.PlatoonPatrolChain(platoon, 'P3C1IntNavalattack' .. i)
        AddUnitsToObjTable(platoon)
    end

    local NukeDefense = ScenarioFramework.GetListOfHumanUnits( categories.xsb4302 + categories.urb4302 + categories.uab4302)
    local num = table.getn(NukeDefense)
    if num > 0 then
        if (num > 2) then
            num = 2
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'P3CAssaultBombersSnipe_D'.. Difficulty, 'GrowthFormation')
            IssueAttack(platoon:GetPlatoonUnits(), NukeDefense[i])
            IssueAggressiveMove(platoon:GetPlatoonUnits(), ScenarioUtils.MarkerToPosition('Player1'))
            AddUnitsToObjTable(platoon)
        end
    end

    local NukeDefense2 = ArmyBrains[Seraphim]:GetListOfUnits(categories.xsb4302)
    local num = table.getn(NukeDefense2)
    if num > 0 then
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'P3CAssaultBombersSnipe', 'GrowthFormation')
            IssueAttack(platoon:GetPlatoonUnits(), NukeDefense2[i])
            IssueAggressiveMove(platoon:GetPlatoonUnits(), ScenarioUtils.MarkerToPosition('Player1'))
            AddUnitsToObjTable(platoon)
        end
    end

    WaitSeconds(12)

    -- sends Gunships if player has more than [60, 50, 40] Units, up to 10, 1 group per 14, 11, 10
    num = ScenarioFramework.GetNumOfHumanUnits(categories.ALLUNITS - categories.WALL)
    quantity = {400, 350, 300}
    trigger = {250, 200, 150}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 5) then
            num = 5
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Cybran', 'P3CAssaultGunships', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P3C1IntAirattack' .. i)
            AddUnitsToObjTable(platoon)
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Cybran', 'P3CAssaultGunships2', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P3C1IntAirattack' .. Random(1, 8))
            AddUnitsToObjTable(platoon)
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Cybran', 'P3CAssaultBombers', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P3C1IntAirattack' .. i)
            AddUnitsToObjTable(platoon)
        end
    end

    WaitSeconds(12)

    -- sends ASF if player has more than [30, 20, 10] Air, up to 3, 1 group per 3, 2, 1
    num = ScenarioFramework.GetNumOfHumanUnits(categories.AIR * categories.MOBILE)
    quantity = {30, 25, 20}
    trigger = {30, 25, 20}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 5) then
            num = 5
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Cybran', 'P3CAssaultAir', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P3C1IntAirattack' .. Random(1, 8))
            AddUnitsToObjTable(platoon)
        end
    end

    -- sends ASF if player has more than [30, 20, 10] Air, up to 3, 1 group per 3, 2, 1
    num = ScenarioFramework.GetNumOfHumanUnits(categories.EXPERIMENTAL)
    quantity = {3, 2, 1}
    trigger = {3, 2, 1}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 3) then
            num = 3
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Cybran', 'P3CAssaultExp', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P3C1IntAirattack' .. i)
            AddUnitsToObjTable(platoon)
        end
    end

    WaitSeconds(12)

    local EXPs = ArmyBrains[Seraphim]:GetListOfUnits( categories.EXPERIMENTAL)
    local num = table.getn(EXPs)
    if num > 0 then
        
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'P3CAssaultGunships', 'GrowthFormation')
            IssueAttack(platoon:GetPlatoonUnits(), EXPs[i])
            IssueAggressiveMove(platoon:GetPlatoonUnits(), ScenarioUtils.MarkerToPosition('Player1'))
            AddUnitsToObjTable(platoon)
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'P3CAssaultBombersSnipe', 'GrowthFormation')
            IssueAttack(platoon:GetPlatoonUnits(), EXPs[i])
            IssueAggressiveMove(platoon:GetPlatoonUnits(), ScenarioUtils.MarkerToPosition('Player1'))
            AddUnitsToObjTable(platoon)
        end
    end

    local EXPsP = ScenarioFramework.GetListOfHumanUnits( categories.EXPERIMENTAL - categories.AIR)
    local num = table.getn(EXPsP)
    if num > 0 then
        if (num > 4) then
            num = 4
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'P3CAssaultGunships', 'GrowthFormation')
            IssueAttack(platoon:GetPlatoonUnits(), EXPsP[i])
            IssueAggressiveMove(platoon:GetPlatoonUnits(), ScenarioUtils.MarkerToPosition('Player1'))
            AddUnitsToObjTable(platoon)
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'P3CAssaultGunships2', 'GrowthFormation')
            IssueAttack(platoon:GetPlatoonUnits(), EXPsP[i])
            IssueAggressiveMove(platoon:GetPlatoonUnits(), ScenarioUtils.MarkerToPosition('Player1'))
            AddUnitsToObjTable(platoon)
        end
    end

    local EXPsP2 = ScenarioFramework.GetListOfHumanUnits( categories.EXPERIMENTAL * categories.AIR)
    local num = table.getn(EXPsP2)
    if num > 0 then
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'P3CAssaultAir', 'GrowthFormation')
            IssueAttack(platoon:GetPlatoonUnits(), EXPsP2[i])
            IssueAggressiveMove(platoon:GetPlatoonUnits(), ScenarioUtils.MarkerToPosition('Player1'))
            AddUnitsToObjTable(platoon)
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'P3CAssaultAir', 'GrowthFormation')
            IssueAttack(platoon:GetPlatoonUnits(), EXPsP2[i])
            IssueAggressiveMove(platoon:GetPlatoonUnits(), ScenarioUtils.MarkerToPosition('Player1'))
            AddUnitsToObjTable(platoon)
        end
    end

    WaitSeconds(10)

    quantity = {2, 3, 5}
    for i = 1, quantity[Difficulty] do
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Cybran', 'P3CAssaultGunships', 'GrowthFormation', 5)
        ScenarioFramework.PlatoonPatrolChain(platoon, 'P3C1IntAirattack' .. i)
        AddUnitsToObjTable(platoon)
    end

    quantity = {2, 3, 5}
    for i = 1, quantity[Difficulty] do
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Cybran', 'P3CAssaultGunships2', 'GrowthFormation', 5)
        ScenarioFramework.PlatoonPatrolChain(platoon, 'P3C1IntAirattack' .. i)
        AddUnitsToObjTable(platoon)
    end

    quantity = {2, 3, 5}
    for i = 1, quantity[Difficulty] do
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Cybran', 'P3CAssaultBombers', 'GrowthFormation', 5)
        ScenarioFramework.PlatoonPatrolChain(platoon, 'P3C1IntAirattack' .. i)
        AddUnitsToObjTable(platoon)
    end

    quantity = {2, 3, 5}
    for i = 1, quantity[Difficulty] do
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'P3CAssaultDrops', 'GrowthFormation')
        CustomFunctions.PlatoonAttackWithTransports(platoon, 'P3Slandingchain' .. Random(1, 3), 'P3U1Intlandingattack1', 'P4CB1MK', true)
        AddUnitsToObjTable(platoon)
    end 
end

function MissionP3()

    ScenarioInfo.M1P3 = Objectives.Kill(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Survive Cybran Assault',                 -- title
        'Kill all Cybran forces attacking you.',  -- description
        {                               -- target
            ShowProgress = true,
            ShowFaction = 'Cybran',
            Units = ScenarioInfo.M3CounterAttackUnits 
        }
    )
    ScenarioInfo.M1P3:AddResultCallback(
        function(result)
            if result then
                ForkThread(IntroStartP4)
            end
        end
    )

    ForkThread(AttackCheck)
    ScenarioFramework.CreateTimerTrigger(SecondaryMissionP3, 90)
end

function SubNukeparty()

    local NukeSub1 = ScenarioUtils.CreateArmyUnit('Cybran', 'P3CNSub1')
    local NukeSub2 = ScenarioUtils.CreateArmyUnit('Cybran', 'P3CNSub2')
    local NukeSub3 = ScenarioUtils.CreateArmyUnit('Cybran', 'P3CNSub3')

    WaitSeconds(4)

    ScenarioInfo.S1P3 = Objectives.Kill(
        'secondary',                      -- type
        'incomplete',                   -- complete
        'Find and Kill the Nuclear subs',                 -- title
        'There are 3 nuclear subs in the area find and destroy them.',  -- description
        {                               -- target
            ShowProgress = true,
            Units = {NukeSub1, NukeSub2, NukeSub3}
            
        }
    )

    NukeSub1:GiveNukeSiloAmmo(1)
    NukeSub2:GiveNukeSiloAmmo(1)
    NukeSub3:GiveNukeSiloAmmo(1)

    IssueNuke({NukeSub1}, ScenarioUtils.MarkerToPosition('P2SB2MK'))
    WaitSeconds(6)
    IssueNuke({NukeSub2}, ScenarioUtils.MarkerToPosition('P2SB1MK'))
    WaitSeconds(6)
    IssueNuke({NukeSub3}, ScenarioUtils.MarkerToPosition('P3Nuke1'))

    WaitSeconds(40)
    NukeSub1:GiveNukeSiloAmmo(1)
    NukeSub2:GiveNukeSiloAmmo(1)
    NukeSub3:GiveNukeSiloAmmo(1)

    IssueClearCommands({NukeSub1})
    IssueClearCommands({NukeSub2})
    IssueClearCommands({NukeSub3})

    IssueNuke({NukeSub1}, ScenarioUtils.MarkerToPosition('P1SB2MK'))
    WaitSeconds(6)
    IssueNuke({NukeSub2}, ScenarioUtils.MarkerToPosition('P2SB3MK'))
    WaitSeconds(6)
    IssueNuke({NukeSub3}, ScenarioUtils.MarkerToPosition('P1SB1MK'))

    WaitSeconds(40)
    NukeSub1:GiveNukeSiloAmmo(1)
    NukeSub2:GiveNukeSiloAmmo(1)
    NukeSub3:GiveNukeSiloAmmo(1)

    IssueClearCommands({NukeSub1})
    IssueClearCommands({NukeSub2})
    IssueClearCommands({NukeSub3})

    local plat = ArmyBrains[Cybran]:MakePlatoon('', '')
        ArmyBrains[Cybran]:AssignUnitsToPlatoon(plat, {NukeSub1}, 'Attack', 'NoFormation')
        ArmyBrains[Cybran]:AssignUnitsToPlatoon(plat, {NukeSub2}, 'Attack', 'NoFormation')
        ArmyBrains[Cybran]:AssignUnitsToPlatoon(plat, {NukeSub3}, 'Attack', 'NoFormation')
        plat:ForkAIThread(plat.NukeAI)
end

function AttackCheck()

    WaitSeconds(15*60)
    if ScenarioInfo.M1P3.Active then
        ScenarioInfo.M1P3:ManualResult(true)   
    end
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

function SecondaryMissionP3()

    ScenarioInfo.S1P3 = Objectives.CategoriesInArea(
    'secondary',                      -- type
    'incomplete',                   -- complete
    'Destroy Cybran Artillery',    -- title
    'The Cybran is trying to set up several T3 artillery bases.',  -- description
    'kill',                         -- action
       {                               -- target
        MarkUnits = true,
        Requirements = {
            {   
                Area = 'P3CObj1',
                Category = categories.urb2302 + categories.ENGINEER,
                CompareOp = '<=',
                Value = 0,
                ArmyIndex = Cybran,
            },
            {   
                Area = 'P3CObj2',
                Category = categories.urb2302 + categories.ENGINEER,
                CompareOp = '<=',
                Value = 0,
                ArmyIndex = Cybran,
            },
            {   
                Area = 'P3CObj3',
                Category = categories.urb2302 + categories.ENGINEER,
                CompareOp = '<=',
                Value = 0,
                ArmyIndex = Cybran,
            },
        },
        
       }
    )
end

-- Part 4

function IntroStartP4()
    ScenarioFramework.Dialogue(OpStrings.EndP3, nil, true)
    ForkThread(IntroP4)
end

function IntroP4()
    ScenarioFramework.FlushDialogueQueue()
    WaitSeconds(5)
    
    if ScenarioInfo.MissionNumber ~= 3 then
        return
    end
    ScenarioInfo.MissionNumber = 4
    
    ScenarioFramework.SetPlayableArea('AREA_4', false)
   
    ScenarioUtils.CreateArmyGroup('Seraphim', 'P4SWalls')
    ScenarioUtils.CreateArmyGroup('Seraphim', 'P4SBaseNuke_D' .. Difficulty)
    ScenarioUtils.CreateArmyGroup('Cybran', 'P4CWalls')
    
    P3SeraphimAI.P4S1Base1AI()
    P3CybranAI.P4C1Base1AI()
    P3CybranAI.P4C1Base3AI()
    P3CybranAI.P4C1Base4AI()
    ScenarioUtils.CreateArmyGroup('Cybran', 'P4Cbase2')

    local Antinukes = ArmyBrains[Seraphim]:GetListOfUnits(categories.xsb4302, false)
    for _, v in Antinukes do
        v:GiveTacticalSiloAmmo(4)
    end

    local Antinukes = ArmyBrains[Cybran]:GetListOfUnits(categories.urb4302, false)
    for _, v in Antinukes do
        v:GiveTacticalSiloAmmo(4)
    end


    local units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'P4SintExpP_D' .. Difficulty, 'GrowthFormation')
    for _, v in units:GetPlatoonUnits() do
       ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P4SB1LandPatrol1')))
    end

    units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'P4SintAirP_D' .. Difficulty, 'GrowthFormation')
    for _, v in units:GetPlatoonUnits() do
       ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P4SB1AirPatrol1')))
    end

    units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'P4SIntCut2', 'GrowthFormation')
    for _, v in units:GetPlatoonUnits() do
       ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P4IntCut2')))
    end

    units = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'P4CPatrol_D' .. Difficulty, 'GrowthFormation')
    for _, v in units:GetPlatoonUnits() do
       ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P4CB1AirPatrol1')))
    end

    local units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'P4SIntattack1_D' .. Difficulty, 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(units, 'P4IntLandattack1' )
    units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'P4SIntCut1', 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(units, 'P4IntCut1' )
    units = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'P4CIntnaval', 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(units, 'P4IntCut1' )
    units = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'P4CIntUnits1', 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(units, 'P4SB1LandPatrol1' )

    ScenarioInfo.P4SACU = ScenarioFramework.SpawnCommander('Seraphim', 'P4SACU', false, 'Overlord Surth-Velsok', true, false,
    {'RateOfFire', 'DamageStabilization', 'DamageStabilizationAdvanced', 'AdvancedEngineering', 'T3Engineering'})
    ScenarioInfo.P4SACU:SetAutoOvercharge(true)
    ScenarioInfo.P4SACU:SetVeterancy(1 + Difficulty)
    ScenarioInfo.P4SACU:AddBuildRestriction(categories.xsb2205 + categories.xsb2304 + categories.xsb4201 + categories.zsb9603 + categories.xsb0303)
    
    ScenarioInfo.P4CACU = ScenarioFramework.SpawnCommander('Cybran', 'P4CACU', false, 'Elite Teko6', true, false,
    {'AdvancedEngineering', 'T3Engineering', 'StealthGenerator', 'CloakingGenerator', 'NaniteTorpedoTube'})
    ScenarioInfo.P4CACU:SetAutoOvercharge(true)
    ScenarioInfo.P4CACU:SetVeterancy(1 + Difficulty)

    Cinematics.EnterNISMode()
        Cinematics.SetInvincible('AREA_2')
        WaitSeconds(1)
        ScenarioFramework.Dialogue(OpStrings.IntroP4, nil, true)
        local P4Vision1 = ScenarioFramework.CreateVisibleAreaLocation(100, ScenarioUtils.MarkerToPosition('P4Vision1'), 0, ArmyBrains[Player1]) 
        local P4Vision2 = ScenarioFramework.CreateVisibleAreaLocation(100, ScenarioUtils.MarkerToPosition('P4Vision2'), 0, ArmyBrains[Player1]) 
        local P4Vision3 = ScenarioFramework.CreateVisibleAreaLocation(100, ScenarioUtils.MarkerToPosition('P4Vision3'), 0, ArmyBrains[Player1]) 
    
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P4Cam0'), 0)
        ForkThread(SeraNukeparty)
        WaitSeconds(5)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P4Cam1'), 6)
        WaitSeconds(5)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P4Cam2'), 6)
        WaitSeconds(5)
        ScenarioFramework.Dialogue(OpStrings.Intro2P4, nil, true)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P4Cam3'), 5)
        WaitSeconds(4)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P4Cam4'), 4)
        WaitSeconds(4)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('P4Cam5'), 4)
        ForkThread(
            function()
                WaitSeconds(1)
                P4Vision1:Destroy()
                P4Vision2:Destroy()
                P4Vision3:Destroy()
                WaitSeconds(1)
                ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('P4Vision1'), 110)
                ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('P4Vision2'), 110)
                ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('P4Vision3'), 110)  
            end
        )
        WaitSeconds(2)
        Cinematics.SetInvincible('AREA_2', true) 
    Cinematics.ExitNISMode()  

    SetAlliance(Cybran, Seraphim, 'Ally')
    SetAlliance(Seraphim, Cybran, 'Ally') 

    ForkThread(MissionP4)
    ForkThread(SecondaryMissionP4)
    ForkThread(P4RandomPicker)
    ForkThread(P4Tech)
    ForkThread(P4SeraCounterAttack)
    SetupTM4TauntTriggers()
end

function MissionP4()

    ScenarioInfo.M1P4 = Objectives.Kill(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Kill Surth-Velsok',                 -- title
        'He has no escape routes this time, end this fight.',  -- description
        {                               -- target
            ShowProgress = true,
            Units = {ScenarioInfo.P4SACU}
        }
    )
    ScenarioInfo.M1P4:AddResultCallback(
        function(result)
            if result then
                ForkThread(Sera1CommanderKilled)
            end
        end
    )
end

function SecondaryMissionP4()

    ScenarioInfo.S1P4 = Objectives.Kill(
        'secondary',                      -- type
        'incomplete',                   -- complete
        'Kill The Cybran',                 -- title
        'The Cybran is to the Northwest, kill him if you have the chance.',  -- description
        {                               -- target
            ShowProgress = true,
            Units = {ScenarioInfo.P4CACU} 
        }
    )
    ScenarioInfo.S1P4:AddResultCallback(
        function(result)
            if result then
                ForkThread(Cybran1CommanderKilled)
            end
        end
    )
end

function SeraNukeparty()

    local SeraNuke = ArmyBrains[Seraphim]:GetListOfUnits(categories.xsb2401, false)

    SeraNuke[1]:GiveNukeSiloAmmo(1)

    IssueNuke({SeraNuke[1]}, ScenarioUtils.MarkerToPosition('P4Nuke1'))

    WaitSeconds(40)

    local plat = ArmyBrains[Seraphim]:MakePlatoon('', '')
        ArmyBrains[Seraphim]:AssignUnitsToPlatoon(plat, {SeraNuke[1]}, 'Attack', 'NoFormation')
        plat:ForkAIThread(plat.NukeAI)
end

function P4RandomPicker()
    
    ScenarioInfo.Specialfunction = Random(1, 3)
    
    if  ScenarioInfo.Specialfunction == 1 then
    
        P3SeraphimAI.P4S1Random1AI()
        
        else
        if  ScenarioInfo.Specialfunction == 2 then
        
            P3SeraphimAI.P4S1Random2AI()

        else
            if  ScenarioInfo.Specialfunction == 3 then

            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Seraphim', 'P4SRandom3_D' .. Difficulty, 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P3C1IntAirattack' .. Random(1, 7))
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Seraphim', 'P4SRandom3_D' .. Difficulty, 'GrowthFormation', 5)
                for _, v in platoon:GetPlatoonUnits() do
                    ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('P4SB1AirPatrol1')))
                end
            end
        end
    end
end

function P4Tech()
    WaitSeconds(25)

    ScenarioFramework.Dialogue(OpStrings.TechP4, nil, true)
    ScenarioFramework.PlayUnlockDialogue()

    for _, Player in ScenarioInfo.HumanPlayers do
    
        ScenarioFramework.RemoveRestriction(Player,
            categories.xsb2401 + -- Exp Nuke
            categories.xab1401 + -- Exp paragon 
            categories.xab2307 + -- Exp Arty 
            categories.url0401   -- Exp C Arty     
        )
    end
end

function P4SeraCounterAttack()

    local units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'P4SintExpP_D' .. Difficulty, 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(units, 'P4IntLandattack1' )

    units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'P4SIntNaval_D' .. Difficulty, 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(units, 'P4SB1Navalattack2' )
    
    local quantity = {}
    local trigger = {}
    local platoon

    -- sends Gunships if player has more than [60, 50, 40] Units, up to 10, 1 group per 14, 11, 10
    num = ScenarioFramework.GetNumOfHumanUnits(categories.ALLUNITS * categories.TECH3)
    quantity = {150, 100, 50}
    trigger = {75, 50, 30}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 8) then
            num = 8
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Seraphim', 'P4SIntGunships_D'.. Difficulty, 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P3C1IntAirattack' .. i)
        end
    end

    -- sends Gunships if player has more than [60, 50, 40] Units, up to 10, 1 group per 14, 11, 10
    num = ScenarioFramework.GetNumOfHumanUnits(categories.AIR * categories.MOBILE)
    quantity = {40, 30, 20}
    trigger = {30, 20, 10}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 8) then
            num = 8
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Seraphim', 'P4SIntASF', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(platoon, 'P3C1IntAirattack' .. i)
        end
    end

    -- sends ASF if player has more than [30, 20, 10] Air, up to 3, 1 group per 3, 2, 1
    num = ScenarioFramework.GetNumOfHumanUnits(categories.ALLUNITS - categories.WALL)
    quantity = {500, 400, 300}
    trigger = {250, 200, 150}
    if num > quantity[Difficulty] then
        num = math.ceil(num/trigger[Difficulty])
        if(num > 7) then
            num = 7
        end
        for i = 1, num do
            platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'P4SIntDrop_D'.. Difficulty, 'GrowthFormation')
            CustomFunctions.PlatoonAttackWithTransports(platoon, 'P3Slandingchain' .. Random(1, 3), 'P3U1Intlandingattack1', 'P4SB1MK', true)
        end
    end
end

function Sera1CommanderKilled()

    ScenarioFramework.CDRDeathNISCamera(ScenarioInfo.P4SACU, 3)
    ScenarioFramework.Dialogue(OpStrings.ACUDeath1, nil, true)
    PlayerWin()
end

function Cybran1CommanderKilled()

    ScenarioFramework.CDRDeathNISCamera(ScenarioInfo.P4CACU, 3)
    ScenarioFramework.Dialogue(OpStrings.ACUDeath2, nil, true)
    if Difficulty < 3 then
        ForkThread(P4KillCybran1Base)  
    end
end

function P4KillCybran1Base()
    local Cybran1Units = ScenarioFramework.GetCatUnitsInArea((categories.ALLUNITS), 'AREA_4', ArmyBrains[Cybran])
        for k, v in UEF1Units do
            if v and not v.Dead then
                v:Kill()
            end
        end
end

-- Misc Functions

function PlayerWin()
    if not ScenarioInfo.OpEnded then
        ScenarioInfo.OpComplete = true
        ScenarioFramework.Dialogue(OpStrings.PlayerWin, nil, true)
        ForkThread(KillGame)
    end
end

function KillGame()
    WaitSeconds(5)
    UnlockInput()
    ScenarioFramework.EndOperation(ScenarioInfo.OpComplete, ScenarioInfo.OpComplete, true)
end

function PlayerDeath()
    if Debug then return end
    if (not ScenarioInfo.OpEnded) then
        ScenarioFramework.CDRDeathNISCamera(ScenarioInfo.PlayerCDR)
        ScenarioFramework.EndOperationSafety()
        ScenarioInfo.OpComplete = false
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
        ForkThread(
            function()
                WaitSeconds(3)
                KillGame()
            end
        )
    end
end

-- Buffs resource producing structures, (and ACU variants.)
function BuffAIEconomy()
    -- Resource production multipliers, depending on the Difficulty
    local Rate = {1.5, 2.0, 2.5}
    -- Buff definitions
    local buffDef = Buffs['CheatIncome']
    local buffAffects = buffDef.Affects
    buffAffects.EnergyProduction.Mult = Rate[Difficulty]
    buffAffects.MassProduction.Mult = Rate[Difficulty]
    
    while true do
        if not table.empty(AIs) then
            for i, j in AIs do
                local economy = ArmyBrains[j]:GetListOfUnits(BuffCategories.Economy, false)
                -- Check if there is anything to buff
                if table.getn(economy) > 0 then
                    for k, v in economy do
                        -- Apply buff to the entity if it hasn't been buffed yet
                        if not v.EcoBuffed then
                            Buff.ApplyBuff( v, 'CheatIncome' )
                            -- Flag the entity as buffed
                            v.EcoBuffed = true
                        end
                    end
                end
            end
        end
        WaitSeconds(60)
    end
end

-- Taunts

function SetupSeraTM1TauntTriggers()

    SeraphimTM:AddEnemiesKilledTaunt('TAUNT1P1', ArmyBrains[Seraphim], categories.STRUCTURE, 15)
    SeraphimTM:AddUnitsKilledTaunt('TAUNT2P1', ArmyBrains[Seraphim], categories.AIR * categories.MOBILE, 50)
    SeraphimTM:AddUnitsKilledTaunt('TAUNT3P1', ArmyBrains[Seraphim], categories.STRUCTURE * categories.FACTORY, 3)
end

function SetupSeraTM2TauntTriggers()

    SeraphimTM:AddEnemiesKilledTaunt('TAUNT1P2', ArmyBrains[Seraphim], categories.ALLUNITS, 50)
    SeraphimTM:AddUnitsKilledTaunt('TAUNT2P2', ArmyBrains[Seraphim], categories.AIR * categories.MOBILE, 80)
    SeraphimTM:AddUnitsKilledTaunt('TAUNT3P2', ArmyBrains[Seraphim], categories.STRUCTURE * categories.FACTORY, 4)
end

function SetupCybranTM3TauntTriggers()

    CybranTM:AddEnemiesKilledTaunt('TAUNT1P3', ArmyBrains[Cybran], categories.ALLUNITS, 30)
    CybranTM:AddUnitsKilledTaunt('TAUNT2P3', ArmyBrains[Cybran], categories.AIR * categories.MOBILE, 90)
    CybranTM:AddUnitsKilledTaunt('TAUNT3P3', ArmyBrains[Cybran], categories.STRUCTURE , 10)
end

function SetupTM4TauntTriggers()

    SeraphimTM:AddEnemiesKilledTaunt('TAUNT1P4', ArmyBrains[Seraphim], categories.ALLUNITS, 40)
    SeraphimTM:AddUnitsKilledTaunt('TAUNT2P4', ArmyBrains[Seraphim], categories.AIR * categories.MOBILE, 100)
    SeraphimTM:AddUnitsKilledTaunt('TAUNT3P4', ArmyBrains[Seraphim], categories.STRUCTURE , 20)
    CybranTM:AddUnitsKilledTaunt('TAUNT4P4', ArmyBrains[Cybran], categories.AIR * categories.MOBILE, 40)
    CybranTM:AddUnitsKilledTaunt('TAUNT5P4', ArmyBrains[Cybran], categories.STRUCTURE , 10)
end