-- Custom Mission
-- Author: speed2

local BaseManager = import('/lua/ai/opai/basemanager.lua')
local Cinematics = import('/lua/cinematics.lua')
local CustomFunctions = import('/maps/Prothyon16/Prothyon16_CustomFunctions.lua')
local EffectUtilities = import('/lua/effectutilities.lua')
local M1UEFAI = import('/maps/Prothyon16/Prothyon16_m1uefai.lua')
local M2UEFAI = import('/maps/Prothyon16/Prothyon16_m2uefai.lua')
local M3UEFAI = import('/maps/Prothyon16/Prothyon16_m3uefai.lua')
local M5UEFAI = import('/maps/Prothyon16/Prothyon16_m5uefai.lua')
local M5UEFALLYAI = import('/maps/Prothyon16/Prothyon16_m5uefallyai.lua')
local M5SeraphimAI = import('/maps/Prothyon16/Prothyon16_m5seraphimai.lua')
local M6SeraphimAI = import('/maps/Prothyon16/Prothyon16_m6seraphimai.lua')
local Objectives = import('/lua/ScenarioFramework.lua').Objectives
local OpStrings = import('/maps/Prothyon16/Prothyon16_strings.lua')
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local Utilities = import('/lua/utilities.lua')
local TauntManager = import('/lua/TauntManager.lua')
local Weather = import('/lua/weather.lua')

----------
-- Globals
----------

-- Army IDs
ScenarioInfo.Player = 1
ScenarioInfo.UEF = 2
ScenarioInfo.UEFAlly = 3
ScenarioInfo.Objective = 4
ScenarioInfo.Seraphim = 5
ScenarioInfo.Coop1 = 6
ScenarioInfo.Coop2 = 7
ScenarioInfo.Coop3 = 8

---------
-- Locals
---------
local Player = ScenarioInfo.Player
local UEF = ScenarioInfo.UEF
local UEFAlly = ScenarioInfo.UEFAlly
local Objective = ScenarioInfo.Objective
local Seraphim = ScenarioInfo.Seraphim
local Coop1 = ScenarioInfo.Coop1
local Coop2 = ScenarioInfo.Coop2
local Coop3 = ScenarioInfo.Coop3

local AssignedObjectives = {}
local Difficulty = ScenarioInfo.Options.Difficulty

local ReminderTaunts = {
    {OpStrings.HQcapremind1, 0},
    {OpStrings.HQcapremind2, 0},
    {OpStrings.HQcapremind3, 0},
    {OpStrings.HQcapremind4, 0},
}

--------------
-- Debug only!
--------------
local Debug = false
local SkipNIS1 = false
local SkipNIS2 = false
local SkipNIS3 = false
local SkipNIS5 = false

-----------------
-- Taunt Managers
-----------------
local ZottooWestTM = TauntManager.CreateTauntManager('ZottooWestTM', '/maps/Prothyon16/Prothyon16_strings.lua')
local SACUTM = TauntManager.CreateTauntManager('SACUTM', '/maps/Prothyon16/Prothyon16_strings.lua')

-- How long should we wait at the beginning of the NIS to allow slower machines to catch up?
local NIS1InitialDelay = 3

--------------------------
-- UEF Secondary variables
--------------------------
local MaxTrucks = 20
local RequiredTrucks = 15

----------
-- Startup
----------
function OnPopulate(scenario)
    -- Spawning clouds on the map
    Weather.CreateWeather()

    ScenarioUtils.InitializeScenarioArmies()

    -- Sets Army Colors
    ScenarioFramework.SetUEFPlayerColor(Player)
	ScenarioFramework.SetUEFAllyColor(UEF)
    SetArmyColor('UEFAlly', 71, 134, 226)
    SetArmyColor('Objective', 71, 134, 226)
    ScenarioFramework.SetSeraphimColor(Seraphim)

    local colors = {
        ['Coop1'] = {47, 79, 79}, 
        ['Coop2'] = {46, 139, 87}, 
        ['Coop3'] = {102, 255, 204}
    }

    local tblArmy = ListArmies()
    for army, color in colors do
        if tblArmy[ScenarioInfo[army]] then
            ScenarioFramework.SetArmyColor(ScenarioInfo[army], unpack(color))
        end
    end

    -- Unit cap
    SetArmyUnitCap(UEF, 1000)
    SetArmyUnitCap(Seraphim, 2000)

    -- Spawn Player initial base
    ScenarioUtils.CreateArmyGroup('Player', 'Starting Base')

    ------
    -- UEF
    ------
    -- UEF Bases
    M1UEFAI.UEFM1WestBaseAI()
    M1UEFAI.UEFM1EastBaseAI()

    -- This will make AI to assembly platoons faster (qeue up new units). Default value is 15. Use this only for small bases!!
    ArmyBrains[UEF]:PBMSetCheckInterval(6)

    -- Slight delay for giving resources, else they are not given
    ForkThread(function()
        WaitSeconds(2)
        ArmyBrains[UEF]:GiveResource('MASS', 4000)
        ArmyBrains[UEF]:GiveResource('ENERGY', 6000)
    end)

    -- Walls
    ScenarioUtils.CreateArmyGroup('UEF', 'M1_Walls')

    -- Initial Patrols
    local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'EastBaseAirDef_D' .. Difficulty, 'GrowthFormation')
    for k, v in platoon:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M1_East_Base_Air_Defence_Chain')))
    end

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'EastBaseLandDef_D' .. Difficulty, 'GrowthFormation')
    for k, v in platoon:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolChain({v}, 'M1_East_Defence_Chain1')
    end

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'WestBaseAirDef_D' .. Difficulty, 'GrowthFormation')
    for k, v in platoon:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M1_WestBase_Air_Def_Chain')))
    end

    -----------------------
    -- Objective Structures
    -----------------------
    ScenarioInfo.M1_Eco_Tech_Centre = ScenarioUtils.CreateArmyUnit('Objective', 'M1_Eco_Tech_Centre')
    ScenarioInfo.M1_Eco_Tech_Centre:SetDoNotTarget(true)
    ScenarioInfo.M1_Eco_Tech_Centre:SetCanTakeDamage(false)
    ScenarioInfo.M1_Eco_Tech_Centre:SetCanBeKilled(false)
    ScenarioInfo.M1_Eco_Tech_Centre:SetReclaimable(false)
    ScenarioInfo.M1_Eco_Tech_Centre:SetCustomName("T2 Economy Tech Centre")

    ScenarioInfo.M1_T2_Land_Tech_Centre = ScenarioUtils.CreateArmyUnit('Objective', 'M1_T2_Land_Tech_Centre')
    ScenarioInfo.M1_T2_Land_Tech_Centre:SetDoNotTarget(true)
    ScenarioInfo.M1_T2_Land_Tech_Centre:SetCanTakeDamage(false)
    ScenarioInfo.M1_T2_Land_Tech_Centre:SetCanBeKilled(false)
    ScenarioInfo.M1_T2_Land_Tech_Centre:SetReclaimable(false)
    ScenarioInfo.M1_T2_Land_Tech_Centre:SetCustomName("T2 Land Tech Centre")

    -- Other Structures
    ScenarioInfo.M1_Other_Buildings = ScenarioUtils.CreateArmyGroup('Objective', 'M1_Other_Buildings')
    for k,v in ScenarioInfo.M1_Other_Buildings do
        v:SetCapturable(false)
        v:SetReclaimable(false)
        v:SetCanTakeDamage(false)
        v:SetCanBeKilled(false)
    end
end

function OnStart(scenario)
    -- Build Restrictions
    for _, player in ScenarioInfo.HumanPlayers do
         ScenarioFramework.AddRestriction(player, categories.TECH2 + categories.TECH3 + categories.EXPERIMENTAL)
    end
    
    -- Lock off cdr upgrades
    for _, player in ScenarioInfo.HumanPlayers do
    	ScenarioFramework.RestrictEnhancements({'ResourceAllocation',
                                            	'DamageStablization',
                                            	'AdvancedEngineering',
                                            	'T3Engineering',
                                            	'LeftPod',
                                            	'RightPod',
                                            	'Shield',
                                            	'ShieldGeneratorField',
                                            	'TacticalMissile',
                                            	'TacticalNukeMissile',
                                            	'Teleporter'})
    end

    -- Set up initial camera
    if not SkipNIS1 then
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_1_1'), 0)
    end

    -- ForkThread is needed here since we are using WaitSecond() inside IntroMission1NIS function.
    ForkThread(IntroMission1NIS)
end

-----------
-- End Game
-----------
function PlayerWin()
    if not ScenarioInfo.OpEnded then
        ScenarioInfo.OpComplete = true
        ScenarioFramework.Dialogue(OpStrings.PlayerWin, KillGame, true)
    end
end

function PlayerLoseToAI(commander)
    -- Stop both player's and UEF army base. No explosion during this end, just voice over with failed training exercise.
    if(not ScenarioInfo.OpEnded) and (ScenarioInfo.MissionNumber <= 3) then
        -- Stop ACU
        IssueClearCommands({commander})

        -- Make sure no one will fire anymore
        for _, player in ScenarioInfo.HumanPlayers do
            SetAlliance(player, UEF, 'Neutral')
            SetAlliance(UEF, player, 'Neutral')
        end

        -- Stop all units
        local units = ArmyBrains[Player]:GetListOfUnits(categories.ALLUNITS - categories.FACTORY, false)
        IssueClearCommands(units)

        units = ArmyBrains[UEF]:GetListOfUnits(categories.ALLUNITS - categories.FACTORY, false)
        IssueClearCommands(units)

        -- Look at ACU
        ScenarioFramework.CDRDeathNISCamera(commander)
        ScenarioFramework.EndOperationSafety()
        ScenarioInfo.OpComplete = false

        -- Mark objectives as failed
        for k, v in AssignedObjectives do
            if(v and v.Active) then
                v:ManualResult(false)
            end
        end

        -- Play dialogue and end game
        ScenarioFramework.Dialogue(OpStrings.PlayerLoseToAI, KillGame, true)
    end
end

function PlayerDeath(deadCommander)
    ScenarioFramework.PlayerDeath(deadCommander, nil, AssignedObjectives)
end

function PlayerLose()
    if(not ScenarioInfo.OpEnded) then
        ScenarioFramework.CDRDeathNISCamera(ScenarioInfo.PlayerCDR)
        ScenarioFramework.EndOperationSafety()
        ScenarioInfo.OpComplete = false

        for k, v in AssignedObjectives do
            if(v and v.Active) then
                v:ManualResult(false)
            end
        end
        
        WaitSeconds(3)
        ScenarioFramework.Dialogue(OpStrings.sACUDie, KillGame, true)
    end
end

function KillGame()
    UnlockInput()
    ScenarioFramework.EndOperation(ScenarioInfo.OpComplete, ScenarioInfo.OpComplete, true)
end

------------
-- Intro NIS
------------
function IntroMission1NIS()
    ScenarioFramework.SetPlayableArea('M1_Area', false)

    if not SkipNIS1 then
        Cinematics.EnterNISMode()

        -- Vision for players
        local VisMarker1_1 = ScenarioFramework.CreateVisibleAreaLocation(30, ScenarioUtils.MarkerToPosition('M1_Vis_1_1'), 0, ArmyBrains[Player])
        local VisMarker1_2 = ScenarioFramework.CreateVisibleAreaLocation(50, ScenarioUtils.MarkerToPosition('M1_Vis_1_2'), 0, ArmyBrains[Player])
        local VisMarker1_3 = ScenarioFramework.CreateVisibleAreaLocation(20, ScenarioUtils.MarkerToPosition('M1_Vis_1_3'), 0, ArmyBrains[Player])


        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_1_1'), 0)

        -- Let slower machines catch up before we get going
        WaitSeconds(NIS1InitialDelay)

        WaitSeconds(1)
        ScenarioFramework.Dialogue(OpStrings.intro1, nil, true)

        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_1_2'), 15)

        ScenarioFramework.Dialogue(OpStrings.intro2, nil, true)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_1_3'), 3)
        WaitSeconds(3)

        -- ForkThread so ACU are spawned while other code is executed
        ForkThread(function()
            -- This ForkThread will make all ACU's spawn at the same time
            ForkThread(function()
                -- Spawn ACU without any effect and name it
                ScenarioInfo.PlayerCDR = ScenarioFramework.SpawnCommander('Player', 'Commander', false, true)

                -- End the mission if player nearly dies
                ScenarioFramework.CreateUnitDamagedTrigger(PlayerLoseToAI, ScenarioInfo.PlayerCDR, .99)
                -- Make sure that player won't die during the first part of the mission
                ScenarioInfo.PlayerCDR:SetCanBeKilled(false)

                -- Spawn transport, drop ACU to targer location
                local transport = ScenarioUtils.CreateArmyUnit('Player', 'Transport')

                IssueTransportLoad({ScenarioInfo.PlayerCDR}, transport)
                IssueTransportUnload({transport}, ScenarioUtils.MarkerToPosition('M3_UEF_Landing_1'))

                WaitSeconds(8)

                while(not ScenarioInfo.PlayerCDR:IsDead() and ScenarioInfo.PlayerCDR:IsUnitState('Attached')) do
                    WaitSeconds(.5)
                end

                IssueMove({transport}, ScenarioUtils.MarkerToPosition('Transport_Delete'))
                IssueMove({ScenarioInfo.PlayerCDR}, ScenarioUtils.MarkerToPosition('Commander_Walk_1'))

                WaitSeconds(1)

                while(not transport:IsDead() and transport:IsUnitState('Moving')) do
                    WaitSeconds(.5)
                end
                transport:Destroy()
            end)

            -- spawn coop players too
            ScenarioInfo.CoopCDR = {}
            local tblArmy = ListArmies()
            coop = 1
            for iArmy, strArmy in pairs(tblArmy) do
                if iArmy >= ScenarioInfo.Coop1 then
                    ForkThread(CreateAndMoveCDRByTransport, strArmy, coop, ScenarioUtils.MarkerToPosition('M3_UEF_Landing_1'))
                    coop = coop + 1
                end
            end
        end)
        
        ScenarioFramework.Dialogue(OpStrings.intro3, nil, true)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_1_4'), 7)
        WaitSeconds(3)

        ForkThread(
            function()
                WaitSeconds(2)

                -- No more vision
                VisMarker1_1:Destroy()
                VisMarker1_2:Destroy()
                VisMarker1_3:Destroy()

                -- Clear intel so players need to scout the base
                if Difficulty == 3 then
                    WaitSeconds(2)
                    ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('M1_Vis_1_1'), 40)
                    ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('M1_Vis_1_2'), 60)
                    ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('M1_Vis_1_3'), 30)
                end
            end
       )
        Cinematics.CameraTrackEntity( ScenarioInfo.PlayerCDR, 80, 3 )
        WaitSeconds(6)
        Cinematics.CameraTrackEntity( ScenarioInfo.PlayerCDR, 30, 0 )
        WaitSeconds(6)
        ScenarioFramework.Dialogue(OpStrings.postintro, nil, true)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_1_7'), 2)

        Cinematics.ExitNISMode()
    else
        -- This part is similart to above, just not moving camera around, for debugging.
        ForkThread(function()
            ScenarioInfo.PlayerCDR = ScenarioFramework.SpawnCommander('Player', 'Commander', false, true)

            ScenarioFramework.CreateUnitDamagedTrigger(PlayerLoseToAI, ScenarioInfo.PlayerCDR, .99)
            ScenarioInfo.PlayerCDR:SetCanBeKilled(false)

            local transport = ScenarioUtils.CreateArmyUnit('Player', 'Transport')

            IssueTransportLoad({ScenarioInfo.PlayerCDR}, transport)
            IssueTransportUnload({transport}, ScenarioUtils.MarkerToPosition('M3_UEF_Landing_1'))

            WaitSeconds(8)

            while(not ScenarioInfo.PlayerCDR:IsDead() and ScenarioInfo.PlayerCDR:IsUnitState('Attached')) do
                WaitSeconds(.5)
            end

            IssueMove({transport}, ScenarioUtils.MarkerToPosition('Transport_Delete'))
            IssueMove({ScenarioInfo.PlayerCDR}, ScenarioUtils.MarkerToPosition('Commander_Walk_1'))

            WaitSeconds(1)

            while(not transport:IsDead() and transport:IsUnitState('Moving')) do
                WaitSeconds(.5)
            end
            transport:Destroy()
        end)

        -- spawn coop players too
    	ScenarioInfo.CoopCDR = {}
    	local tblArmy = ListArmies()
    	coop = 1
    	for iArmy, strArmy in pairs(tblArmy) do
        	if iArmy >= ScenarioInfo.Coop1 then
                ForkThread(CreateAndMoveCDRByTransport, strArmy, coop, ScenarioUtils.MarkerToPosition('M3_UEF_Landing_1'))
            	coop = coop + 1
        	end
    	end

        WaitSeconds(0.1)
    end

    IntroMission1()
end

function CreateAndMoveCDRByTransport(brain, coop, position)
    ScenarioInfo.CoopCDR[coop] = ScenarioFramework.SpawnCommander(brain, 'Commander', false, true)
    ScenarioFramework.CreateUnitDamagedTrigger(PlayerLoseToAI, ScenarioInfo.CoopCDR[coop], .99)
    ScenarioInfo.CoopCDR[coop]:SetCanBeKilled(false)

    local transport = ScenarioUtils.CreateArmyUnit(brain, 'Transport')

    IssueTransportLoad({ScenarioInfo.CoopCDR[coop]}, transport)
    IssueTransportUnload({transport}, ScenarioUtils.MarkerToPosition('M3_UEF_Landing_1'))

    WaitSeconds(8)

    while(not ScenarioInfo.CoopCDR[coop]:IsDead() and ScenarioInfo.CoopCDR[coop]:IsUnitState('Attached')) do
        WaitSeconds(.5)
    end

    IssueMove({transport}, ScenarioUtils.MarkerToPosition('Transport_Delete'))
    IssueMove({ScenarioInfo.CoopCDR[coop]}, ScenarioUtils.MarkerToPosition('Commander_Walk_1'))

    WaitSeconds(1)

    while(not transport:IsDead() and transport:IsUnitState('Moving')) do
        WaitSeconds(.5)
    end
    transport:Destroy()
end

------------
-- Mission 1
------------
function IntroMission1()
    ScenarioInfo.MissionNumber = 1

    StartMission1()
end

function StartMission1()
    -----------------------------------------------
    -- Primary Objective 1 - Destroy First UEF Base
    -----------------------------------------------
    ScenarioInfo.M1P1 = Objectives.CategoriesInArea(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Destroy UEF Forward Bases',                 -- title
        'Eliminate the marked UEF structures to establish a foothold on the main island.',  -- description
        'kill',                         -- action
        {                               -- target
            MarkUnits = true,
            Requirements = {
                {   
                    Area = 'M1_UEF_WestBase_Area',
                    Category = categories.FACTORY,
                    CompareOp = '<=',
                    Value = 0,
                    ArmyIndex = UEF,
                },
                {   
                    Area = 'M1_UEF_EastBase_Area',
                    Category = categories.FACTORY,
                    CompareOp = '<=',
                    Value = 0,
                    ArmyIndex = UEF
                },
            },
        }
   )
    ScenarioInfo.M1P1:AddResultCallback(
        function(result)
            if(result) then
                if not Debug then
                    ScenarioFramework.Dialogue(OpStrings.base2killed, IntroMission2, true)
                else
                    IntroMission2()
                end
            end
        end
    )
    table.insert(AssignedObjectives, ScenarioInfo.M1P1)
    ScenarioFramework.CreateTimerTrigger(M1P1Reminder1, 15*60)

    -- Feedback dialogue when the first base is destroyed
    ScenarioFramework.CreateAreaTrigger(M1FirstBaseDestroyed, 'M1_UEF_WestBase_Area',
        categories.UEF * categories.FACTORY, true, true, ArmyBrains[UEF])

    ------------------------------------------------
    -- Secondary Objective 1 - Capture Tech Centre
    ------------------------------------------------
    ScenarioInfo.M1S1 = Objectives.Capture(
        'secondary',                      -- type
        'incomplete',                   -- complete
        'Capture Economy Tech Centre',  -- title
        'Capture this building to gain access to T2 Economy',  -- description
        {
            Units = {ScenarioInfo.M1_Eco_Tech_Centre},
            FlashVisible = true,
        }
    )
    ScenarioInfo.M1S1:AddResultCallback(
        function(result)
            if(result) then
                ScenarioFramework.PlayUnlockDialogue()
                for _, player in ScenarioInfo.HumanPlayers do
                    ScenarioFramework.RemoveRestriction(player, categories.TECH2 * categories.STRUCTURE 
                                                                                    - categories.ueb2108    -- TML
                                                                                    - categories.ueb2303    -- T2 Arty
                                                                                    - categories.ueb0203    -- T2 NAval HQ
                                                                                    - categories.ueb2301    -- T2 PD
                                                                                    - categories.ueb0202    -- T2 Air HQ
                                                                                    - categories.ueb4202    -- Static Shield
                                                                                    - categories.ueb4203)   -- Stealth
                    ScenarioFramework.RemoveRestriction(player, categories.uel0208 + categories.xel0209)    -- T2 Engineer and Sparky
                end
                ScenarioFramework.RestrictEnhancements({'ResourceAllocation',
                                                        'T3Engineering',
                                                        'Shield',
                                                        'ShieldGeneratorField',
                                                        'TacticalMissile',
                                                        'TacticalNukeMissile',
                                                        'Teleporter'})
            end
        end
    )
    table.insert(AssignedObjectives, ScenarioInfo.M1S1)
    ScenarioFramework.CreateTimerTrigger(M1S1Reminder, 20*60)

    ------------------------------------------------
    -- Secondary Objective 2 - Capture Tech Centre
    ------------------------------------------------
    ScenarioInfo.M1S2 = Objectives.Capture(
        'secondary',                      -- type
        'incomplete',                   -- complete
        'Capture T2 Land Tech Centre',  -- title
        'Capture this building to gain access to T2 Land units',  -- description
        {
            Units = {ScenarioInfo.M1_T2_Land_Tech_Centre},
            FlashVisible = true,
        }
    )
    ScenarioInfo.M1S2:AddResultCallback(
        function(result)
            if(result) then
                -- "Schematics downloaded voice over"
                ScenarioFramework.PlayUnlockDialogue()

                for _, player in ScenarioInfo.HumanPlayers do
                     ScenarioFramework.RemoveRestriction(player, categories.TECH2 * categories.LAND)
                end
            end
        end
    )
    table.insert(AssignedObjectives, ScenarioInfo.M1S2)

    -- Voice reminder for objective after 20 minutes
    ScenarioFramework.CreateTimerTrigger(M1S2Reminder, 20*60)
end

function M1FirstBaseDestroyed()
    if not ScenarioInfo.M1BaseDialoguePlayer and ScenarioInfo.M1P1.Active then
        ScenarioInfo.M1BaseDialoguePlayer = true
        ScenarioFramework.Dialogue(OpStrings.base1killed)
        ScenarioFramework.CreateTimerTrigger(M1P1Reminder3, 20*60)
    end
end

------------
-- Mission 2
------------
function IntroMission2()
    ScenarioInfo.MissionNumber = 2

    ---------
    -- UEF AI
    ---------
    -- UEF Bases
    M2UEFAI.UEFM2SouthBaseAI()
    M2UEFAI.UEFM2T1BaseAI()

    -- Fill the storages
    ArmyBrains[UEF]:GiveResource('MASS', 4000)
    ArmyBrains[UEF]:GiveResource('ENERGY', 8000)

    -- UEF Forward buildings
    ScenarioUtils.CreateArmyGroup('UEF', 'Forward_Structures')

    ------------------
    -- Initial Patrols
    ------------------
    local units = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M2_SouthBaseAirDef_D' .. Difficulty, 'GrowthFormation')
    for k, v in units:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M2_SouthBase_Air_Def_Chain')))
    end

    units = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M2_SouthBaseLandDef1_D' .. Difficulty, 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(units, 'M2_SouthBase_Land_Def_Chain1')

    units = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M2_SouthBaseLandDef2_D' .. Difficulty, 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(units, 'M2_SouthBase_Land_Def_Chain2')

    units = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M2_SouthBaseLandDef3_D' .. Difficulty, 'GrowthFormation')
    for k, v in units:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolChain({v}, 'M2_SouthBase_Land_Def_Chain2')
    end

    -- Spawn some engies for reclaiming, putting them inside a platoon so the BaseManager won't steal them
    for i = 1, 6 do
        ScenarioInfo.Engineer = ScenarioUtils.CreateArmyUnit('UEF', 'M2_SouthBase_Engi' .. i)
        local platoon = ArmyBrains[UEF]:MakePlatoon('', '')
        ArmyBrains[UEF]:AssignUnitsToPlatoon(platoon, {ScenarioInfo.Engineer}, 'Attack', 'GrowthFormation')
        ScenarioFramework.PlatoonPatrolChain(platoon, 'M2_SouthBase_Land_Attack_Chain' .. i)
    end

    ------------------
    -- Initial Attacks
    ------------------
    -- Land Attacks - spawning now because it takes a while for land units to move
    for i = 1, 6 do
        units = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M2_SouthBaseInitAttack' .. i .. '_D' .. Difficulty, 'AttackFormation')
        ScenarioFramework.PlatoonPatrolChain(units, 'M2_SouthBase_Land_Attack_Chain' .. i)
    end

    -----------------------
    -- Objective Structures
    -----------------------
    ScenarioInfo.M2_T2_Air_Tech_Centre = ScenarioUtils.CreateArmyUnit('Objective', 'M2_T2_Air_Tech_Centre')
    ScenarioInfo.M2_T2_Air_Tech_Centre:SetDoNotTarget(true)
    ScenarioInfo.M2_T2_Air_Tech_Centre:SetCanTakeDamage(false)
    ScenarioInfo.M2_T2_Air_Tech_Centre:SetCanBeKilled(false)
    ScenarioInfo.M2_T2_Air_Tech_Centre:SetReclaimable(false)
    ScenarioInfo.M2_T2_Air_Tech_Centre:SetCustomName("T2 Air Tech Centre")

    -------------------
    -- Other Structures
    -------------------
    ScenarioInfo.M2_Other_Buildings = ScenarioUtils.CreateArmyGroup('Objective', 'M2_Other_Buildings')
    for k,v in ScenarioInfo.M2_Other_Buildings do
        v:SetCapturable(false)
        v:SetReclaimable(false)
        v:SetCanTakeDamage(false)
        v:SetCanBeKilled(false)
    end

    ScenarioInfo.UEFGate = ScenarioUtils.CreateArmyGroup('Objective', 'Quantum_Gate_Prebuild')
    for k,v in ScenarioInfo.UEFGate do
        v:SetCapturable(false)
        v:SetReclaimable(false)
        v:SetCanTakeDamage(false)
        v:SetCanBeKilled(false)
    end
    
    IntroMission2NIS()
end

function IntroMission2NIS()
    ScenarioFramework.SetPlayableArea('M2_Area', false)

    if not SkipNIS2 then
        Cinematics.EnterNISMode()
        -- Make sure that some accidental death won't happen
        Cinematics.SetInvincible('M2_Area')

        -- Vision for players
        local VisMarker2_1 = ScenarioFramework.CreateVisibleAreaLocation(40, ScenarioUtils.MarkerToPosition('M2_Vis_1'), 0, ArmyBrains[Player])
        local VisMarker2_2 = ScenarioFramework.CreateVisibleAreaLocation(40, ScenarioUtils.MarkerToPosition('M2_Vis_2'), 0, ArmyBrains[Player])
        local VisMarker2_3 = ScenarioFramework.CreateVisibleAreaLocation(40, ScenarioUtils.MarkerToPosition('M2_Vis_3'), 0, ArmyBrains[Player])

        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_2_1'), 0)
        ScenarioFramework.Dialogue(OpStrings.southbase1, nil, true)
        WaitSeconds(3)
        --Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_2_2'), 4)
        --Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_2_3'), 3)
        --Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_2_4'), 4)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_2_5'), 10)
        ScenarioFramework.Dialogue(OpStrings.southbase2, nil, true)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_2_6'), 3)
        ForkThread(
            function()
                WaitSeconds(1)

                -- Remove vision
                VisMarker2_1:Destroy()
                VisMarker2_2:Destroy()
                VisMarker2_3:Destroy()

                if Difficulty == 3 then
                    WaitSeconds(1)
                    ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('M2_Vis_1'), 50)
                    ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('M2_Vis_2'), 50)
                    ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('M2_Vis_3'), 50)
                end
            end
        )
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_2_7'), 3)
        WaitSeconds(2)
        
        Cinematics.SetInvincible('M2_Area', true)
        Cinematics.ExitNISMode()
    end

    M2InitialAirAttack()
    StartMission2()
end

function M2InitialAirAttack()
    -- If player > 100 units, spawns Bombers for every 20 land units, up to 6 groups
    local num = 0
    for _, player in ScenarioInfo.HumanPlayers do
        num = num + table.getn(ArmyBrains[player]:GetListOfUnits(categories.ALLUNITS - categories.WALL, false))
    end

    if(num > 100) then
        local num = 0
        for _, player in ScenarioInfo.HumanPlayers do
            num = num + table.getn(ArmyBrains[player]:GetListOfUnits((categories.LAND * categories.MOBILE) - categories.CONSTRUCTION, false))
        end

        if(num > 0) then
            num = math.ceil(num/20)
            if(num > 6) then
                num = 6
            end
            for i = 1, num do
                units = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('UEF', 'M2_UEF_Adapt_Bombers', 'GrowthFormation', 5)
                ScenarioFramework.PlatoonPatrolChain(units, 'M2_SouthBase_Land_Attack_Chain' .. Random(1,6))
            end
        end
    end

    -- Spawns Interceptors for every 10 Air units, up to 5 groups
    local num = 0
    for _, player in ScenarioInfo.HumanPlayers do
        num = num + table.getn(ArmyBrains[player]:GetListOfUnits(categories.AIR * categories.MOBILE, false))
    end

    if(num > 0) then
        num = math.ceil(num/10)
        if(num > 5) then
            num = 5
        end
        for i = 1, num do
            units = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('UEF', 'M2_UEF_Adapt_Intie', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(units, 'M2_SouthBase_Land_Attack_Chain' .. Random(1,6))
        end
    end
end

function StartMission2()
    -------------------------------------------
    -- Primary Objective 1 - Destroy Enemy Base
    -------------------------------------------
    ScenarioInfo.M2P1 = Objectives.CategoriesInArea(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Eliminate Southern Base',                 -- title
        'Destroy the base to your south in order to secure the entire main island.',  -- description
        'kill',                         -- action
        {                               -- target
            MarkUnits = true,
            Requirements = {
                {   
                    Area = 'M2_UEF_SouthBase_Area',
                    Category = categories.FACTORY + categories.ueb1302 + (categories.TECH2 * categories.ECONOMIC),    -- T3 Mex
                    CompareOp = '<=',
                    Value = 0,
                    ArmyIndex = UEF
                },
            },
        }
   )
    ScenarioInfo.M2P1:AddResultCallback(
        function(result)
            if(result) then
                if not Debug then
                    ScenarioFramework.Dialogue(OpStrings.airbase1, IntroMission3)
                else
                    IntroMission3()
                end
            end
        end
    )
    table.insert(AssignedObjectives, ScenarioInfo.M2P1)

    -- Voice reminder for objective after 15 minutes
    ScenarioFramework.CreateTimerTrigger(M2P1Reminder1, 15*60)

    -- Secondary Objectives
    -- Kill titan patrol, once player spots them
    ScenarioFramework.CreateArmyIntelTrigger(M2SecondaryTitans, ArmyBrains[Player], 'LOSNow', false, true, categories.uel0303, true, ArmyBrains[UEF])
    -- Capture another tech centre
    ScenarioFramework.Dialogue(OpStrings.airhqtechcentre, M2SecondaryCaptureTech)
end

function M2SecondaryCaptureTech()
    ----------------------------------------------
    -- Secondary Objective 3 - Capture Tech Centre
    ----------------------------------------------
    ScenarioInfo.M2S1 = Objectives.Capture(
        'secondary',                      -- type
        'incomplete',                   -- complete
        'Capture T2 Air Tech Centre',  -- title
        'Capture this building to gain access to T2 Air units.',  -- description
        {
            Units = {ScenarioInfo.M2_T2_Air_Tech_Centre},
            FlashVisible = true,
        }
    )
    ScenarioInfo.M2S1:AddResultCallback(
        function(result)
            if(result) then
                -- "Schematics downloaded voice over"
                ScenarioFramework.PlayUnlockDialogue()

                for _, player in ScenarioInfo.HumanPlayers do
                    ScenarioFramework.RemoveRestriction(player, categories.TECH2 * categories.AIR)
                    ScenarioFramework.RemoveRestriction(player, (categories.TECH2 * categories.NAVAL * categories.STRUCTURE) + categories.DESTROYER)
                end

                ScenarioFramework.RestrictEnhancements({'ResourceAllocation',
                                                        'T3Engineering',
                                                        'Shield',
                                                        'ShieldGeneratorField',
                                                        'TacticalNukeMissile',
                                                        'Teleporter'})
            end
        end
    )
    table.insert(AssignedObjectives, ScenarioInfo.M2S1)

    ScenarioFramework.CreateTimerTrigger(M2S1Reminder, 20*60)
end

function M2SecondaryTitans()
    ScenarioFramework.Dialogue(OpStrings.titankill)

    local units = ScenarioFramework.GetCatUnitsInArea(categories.uel0303, 'M2_Area', ArmyBrains[UEF])

    --------------------------------------
    -- Secondary Objective 4 - Kill Titans
    --------------------------------------
    ScenarioInfo.M2S2 = Objectives.KillOrCapture(
        'secondary',                      -- type
        'incomplete',                   -- complete
        'Dispatch Titan Squad',                 -- title
        'Destroy the Titan patrol around the southern base',  -- description
        {                               -- target
            Units = units,
            MarkUnits = true,
        }
   )
    ScenarioInfo.M2S2:AddResultCallback(
        function(result)
            if(result) then
                ScenarioFramework.Dialogue(OpStrings.titankilled)
            end
        end
    )
    table.insert(AssignedObjectives, ScenarioInfo.M2S2)
end

function UEFBattleships()
    WaitSeconds(60)

    ScenarioFramework.Dialogue(OpStrings.unitmove)

    ScenarioInfo.Battleships = ScenarioUtils.CreateArmyGroupAsPlatoon('UEFAlly', 'Battleships', 'AttackFormation')
    ScenarioInfo.Battleships.PlatoonData = {}
    ScenarioInfo.Battleships.PlatoonData.MoveRoute = {'BattleshipsDeath'}
    ScenarioPlatoonAI.MoveToThread(ScenarioInfo.Battleships)
    
    WaitSeconds(5)
    ScenarioInfo.Battleships:Destroy()
end

function UEFFlyover()
    WaitSeconds(120)
    ScenarioInfo.Flyover = ScenarioUtils.CreateArmyGroupAsPlatoon('UEFAlly', 'Flyover', 'AttackFormation')
    ScenarioInfo.Flyover.PlatoonData = {}
    ScenarioInfo.Flyover.PlatoonData.MoveRoute = {'BattleshipsDeath'}
    ScenarioPlatoonAI.MoveToThread(ScenarioInfo.Flyover)
    WaitSeconds(5)
    KillFlyover()
end

function KillFlyover()
    ScenarioInfo.Flyover:Destroy()
end

------------
-- Mission 3
------------
function IntroMission3()
    ScenarioInfo.MissionNumber = 3

    ------------------
    -- UEF Island Base
    ------------------
    M3UEFAI.UEFM3AirBaseAI()
    M3UEFAI.UEFM3SouthNavalBaseAI()
    M3UEFAI.UEFM3WestNavalBaseAI()
    ArmyBrains[UEF]:GiveResource('MASS', 12000)
    ArmyBrains[UEF]:GiveResource('ENERGY', 10000)

    -- Allow player to build Destroyers (T2 Naval Factory + Support Factory)
    for _, player in ScenarioInfo.HumanPlayers do
        ScenarioFramework.RemoveRestriction(player, categories.ues0201 + categories.ueb0203 + categories.zeb9503)
    end

    ------------------
    -- Initial Patrols
    ------------------
    local units = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M3_AirBaseAirDef_D' .. Difficulty, 'GrowthFormation')
    for k, v in units:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M3_Air_Base_Defense_Chain')))
    end

    for i = 1, 6 do
        ScenarioInfo.Engineer = ScenarioUtils.CreateArmyUnit('UEF', 'M3_Engie' .. i)
        local platoon = ArmyBrains[UEF]:MakePlatoon('', '')
        ArmyBrains[UEF]:AssignUnitsToPlatoon(platoon, {ScenarioInfo.Engineer}, 'Attack', 'GrowthFormation')
        ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_Air_Attack_Chain' .. i)
    end

    -- Walls
    ScenarioUtils.CreateArmyGroup('UEF', 'M3_Walls')
    -----------------------
    -- Objective Structures
    -----------------------
    
    IntroMission3NIS()
end

function IntroMission3NIS()
    ScenarioFramework.SetPlayableArea('M3_Area', false)

    if not SkipNIS3 then
        Cinematics.EnterNISMode()
        Cinematics.SetInvincible( 'M2_Area' )

        local VisMarker3_1 = ScenarioFramework.CreateVisibleAreaLocation(40, ScenarioUtils.MarkerToPosition('M3_Vis_1'), 0, ArmyBrains[Player])
        local VisMarker3_2 = ScenarioFramework.CreateVisibleAreaLocation(40, ScenarioUtils.MarkerToPosition('M3_Vis_2'), 0, ArmyBrains[Player])
        local VisMarker3_3 = ScenarioFramework.CreateVisibleAreaLocation(50, ScenarioUtils.MarkerToPosition('M3_Vis_3'), 0, ArmyBrains[Player])
        local VisMarker3_4 = ScenarioFramework.CreateVisibleAreaLocation(50, ScenarioUtils.MarkerToPosition('M3_Vis_4'), 0, ArmyBrains[Player])

        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_3_1'), 0)
        ScenarioFramework.Dialogue(OpStrings.airbase2, nil, true)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_3_2'), 4)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_3_3'), 5)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_3_4'), 2)
        ForkThread(
            function()
                WaitSeconds(1)
                VisMarker3_1:Destroy()
                VisMarker3_2:Destroy()
                VisMarker3_3:Destroy()
                VisMarker3_4:Destroy()
                if Difficulty == 3 then
                    WaitSeconds(1)
                    ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('M3_Vis_1'), 50)
                    ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('M3_Vis_2'), 50)
                    ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('M3_Vis_3'), 60)
                    ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('M3_Vis_4'), 60)
                end
            end
        )
        WaitSeconds(2)
        
        Cinematics.SetInvincible( 'M2_Area', true )
        Cinematics.ExitNISMode()
    end

    ScenarioFramework.Dialogue(OpStrings.postintro3, nil, true)
    M3InitialAttack()
    StartMission3()
end

function M3InitialAttack()
    local units = nil

    -- Hover Attacks
    units = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M3_UEF_InitAttack_Hover1', 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(units, 'M3_Air_Hover_Chain1')

    units = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M3_UEF_InitAttack_Hover2', 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(units, 'M3_Air_Hover_Chain2')

    -- Spawns transport attacks for every 8 defensive structures, up to 4 x 5 groups
    local num = 0
    for _, player in ScenarioInfo.HumanPlayers do
        num = num + table.getn(ArmyBrains[player]:GetListOfUnits(categories.STRUCTURE * categories.DEFENSE, false))
    end

    if(num > 0) then
        num = math.ceil(num/8)
        if(num > 5) then
            num = 5
        end
        for i = 1, num do
            for j = 1, 4 do
                units = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M3_UEF_InitAttack_Trans' .. j, 'AttackFormation')
                for k,v in units:GetPlatoonUnits() do
                    if(v:GetUnitId() == 'uea0104') then
                        local interceptors = ScenarioUtils.CreateArmyGroup('UEF', 'M3_UEF_Trans_Interceptors')
                        IssueGuard(interceptors, v)
                        break
                    end
                end
                CustomFunctions.PlatoonAttackWithTransports(units, 'M3_Init_Landing_Chain', 'M3_Init_TransAttack_Chain' .. Random(1,2), true)
            end
        end
    end

    -- Air Attacks
    units = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M3_UEF_InitAttack_AirNorth', 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(units, 'M3_Air_Attack_Chain3')

    units = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M3_UEF_InitAttack_AirSouth', 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(units, 'M3_Air_Attack_Chain6')

    -- If player > 250 units, spawns gunships for every 40 land units, up to 7 groups
    local num = 0
    for _, player in ScenarioInfo.HumanPlayers do
        num = num + table.getn(ArmyBrains[player]:GetListOfUnits(categories.ALLUNITS - categories.WALL, false))
    end

    if(num > 250) then
        local num = 0
        for _, player in ScenarioInfo.HumanPlayers do
            num = num + table.getn(ArmyBrains[player]:GetListOfUnits((categories.LAND * categories.MOBILE) - categories.CONSTRUCTION, false))
        end

        if(num > 0) then
            num = math.ceil(num/40)
            if(num > 7) then
                num = 7
            end
            for i = 1, num do
                units = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('UEF', 'M3_UEF_Adapt_Gunships', 'GrowthFormation', 5)
                ScenarioFramework.PlatoonPatrolChain(units, 'M3_Air_Attack_Chain' .. Random(1,6))
            end
        end
    end

    -- Spawns Interceptors for every 20 Air units, up to 10 groups
    local num = 0
    for _, player in ScenarioInfo.HumanPlayers do
        num = num + table.getn(ArmyBrains[player]:GetListOfUnits(categories.AIR * categories.MOBILE, false))
    end

    if(num > 0) then
        num = math.ceil(num/20)
        if(num > 10) then
            num = 10
        end
        for i = 1, num do
            units = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('UEF', 'M3_UEF_Adapt_Intie', 'GrowthFormation', 5)
            ScenarioFramework.PlatoonPatrolChain(units, 'M3_Air_Attack_Chain' .. Random(1,6))
        end
    end

    -- Spawns Destroyers for every 30 Riptides, up to 2 x 4 groups
    local num = 0
    for _, player in ScenarioInfo.HumanPlayers do
        num = num + table.getn(ArmyBrains[player]:GetListOfUnits(categories.uel0203, false))
    end

    if(num > 0) then
        num = math.ceil(num/30)
        if(num > 4) then
            num = 4
        end
        for i = 1, num do
            for j = 1, 2 do
                units = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('UEF', 'M3_UEF_Adapt_Destr' .. j, 'AttackFormation', 5)
                ScenarioFramework.PlatoonPatrolChain(units, 'M3_Air_Base_NavalAttack_Chain' .. Random(1,2))
            end
        end
    end
end

function StartMission3()
    -------------------------------------------
    -- Primary Objective 1 - Destroy Enemy Base
    -------------------------------------------
    ScenarioInfo.M3P1 = Objectives.CategoriesInArea(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Destroy The Island Air Base',                 -- title
        'Eliminate the Island Air base to your north-west',  -- description
        'kill',                         -- action
        {                               -- target
            MarkUnits = true,
            Requirements = {
                {   
                    Area = 'M3_UEF_AirBase_Area',
                    Category = categories.FACTORY + (categories.TECH2 * categories.ECONOMIC),
                    CompareOp = '<=',
                    Value = 0,
                    ArmyIndex = UEF
                },
            },
        }
   )
    table.insert(AssignedObjectives, ScenarioInfo.M3P1)
    ScenarioFramework.CreateTimerTrigger(M3P1Reminder1, 25*60)

    ScenarioFramework.CreateArmyStatTrigger(SeraphimReveal, ArmyBrains[UEF], 'SeraphimReveal',
        {{StatType = 'Units_Active', CompareType = 'LessThanOrEqual', Value = 5, Category = categories.FACTORY}})
end

------------
-- Mission 4
------------
function SeraphimReveal()
    ScenarioFramework.Dialogue(OpStrings.M4intro1, false, true)
    for i = 1, 5 do
        ForkThread(function(i)
            local unit = ScenarioUtils.CreateArmyUnit('Seraphim', 'Sera_Scout_' .. i)
            IssueMove({unit}, ScenarioUtils.MarkerToPosition('ScoutsDeath_' .. i))
            WaitSeconds(1)
            while(not unit:IsDead() and unit:IsUnitState('Moving')) do
                WaitSeconds(.5)
            end
            unit:Destroy()
        end, i)
    end
    ScenarioInfo.M3P1:ManualResult(true)
    -- WaitSeconds(30)
    ScenarioFramework.Dialogue(OpStrings.M4intro2, IntroMission4, true)
end

function IntroMission4()
    ForkThread(
        function()
            -- New Alliances
            for _, player in ScenarioInfo.HumanPlayers do
                SetAlliance(player, UEF, 'Ally')
                SetAlliance(UEF, player, 'Ally')
                SetAlliance(player, Objective, 'Ally')
                SetAlliance(Objective, player, 'Ally')
            end

            -- Give civilian bases to 'UEFAlly' army. I didn't want them to give any intel until now, that's why there were in neutral army.
            local units = ScenarioFramework.GetCatUnitsInArea((categories.ALLUNITS - categories.uec1101 - categories.uec1201 - categories.uec1301 - categories.uec1401 - categories.uec1501 - categories.xec1301 - categories.uec0001), 'M2_Area', ArmyBrains[Objective])
            for k, v in units do
                if v and not v:IsDead() and (v:GetAIBrain() == ArmyBrains[Objective]) then
                    ScenarioFramework.GiveUnitToArmy( v, UEFAlly )
                end
            end

            -- Give rest of the UEF base to player.
            local UEFunits = ScenarioFramework.GetCatUnitsInArea((categories.ALLUNITS), 'M3_Area', ArmyBrains[UEF])
            for k, v in UEFunits do
                if v and not v:IsDead() and (v:GetAIBrain() == ArmyBrains[UEF]) then
                    ScenarioFramework.GiveUnitToArmy( v, Player )
                end
            end

            -- Allow player to build T2 units, T3 radar and sonar
            for _, player in ScenarioInfo.HumanPlayers do
                ScenarioFramework.RemoveRestriction(player, categories.TECH2 + categories.ueb3104 + categories.ues0305)
            end
            ScenarioFramework.PlayUnlockDialogue()
            ScenarioFramework.RestrictEnhancements({'T3Engineering',
                                                    'ShieldGeneratorField',
                                                    'TacticalNukeMissile',
                                                    'Teleporter'})
            IntroMission5()
        end
    )
end

------------
-- Mission 5
------------
function IntroMission5()
    ScenarioInfo.MissionNumber = 5

    -- No invincible ACU anymore
    ScenarioInfo.PlayerCDR:SetCanBeKilled(true)
    -- Set up trigger if player dies
    ScenarioFramework.CreateUnitDeathTrigger(PlayerDeath, ScenarioInfo.PlayerCDR)

    coop = 1
    for iArmy, strArmy in pairs(ListArmies()) do
        if iArmy >= ScenarioInfo.Coop1 then
            ScenarioInfo.CoopCDR[coop]:SetCanBeKilled(true)
            -- ScenarioFramework.CreateUnitDeathTrigger(PlayerDeath, ScenarioInfo.CoopCDR[coop])
            coop = coop + 1
        end
    end
    
    ---------
    -- UEF AI
    ---------
    -- Island base with sACU
    M5UEFAI.UEFM5IslandBaseAI()
    
    -- Fill the storages
    ArmyBrains[UEF]:GiveResource('MASS', 8000)
    ArmyBrains[UEF]:GiveResource('ENERGY', 30000)

    -- Spawn sACU
    ScenarioInfo.UEFSACU = ScenarioFramework.SpawnCommander('UEF', 'M5_UEF_Island_sACU', false, 'sCDR Morax', true, false,
        {'AdvancedCoolingUpgrade', 'HighExplosiveOrdnance', 'Shield'})

    --------------
    -- UEF Ally AI
    --------------
    -- Start unit production from the civilian bases
    M5UEFALLYAI.UEFAllyM5BaseAI()
    M5UEFALLYAI.UEFAllyM5GateBaseAI()

    ScenarioUtils.CreateArmyGroup('UEFAlly', 'M5_Island_Defences_Buildings')

    --------------
    -- Seraphim AI
    --------------
    M5SeraphimAI.SeraphimM5MainBaseAI()
    M5SeraphimAI.SeraphimM5IslandMiddleBaseAI()
    M5SeraphimAI.SeraphimM5IslandWestBaseAI()

    ArmyBrains[Seraphim]:GiveResource('MASS', 15000)
    ArmyBrains[Seraphim]:GiveResource('ENERGY', 30000)

    ScenarioInfo.M5SeraBase = ScenarioFramework.GetCatUnitsInArea(categories.FACTORY + categories.TECH2 * categories.ECONOMIC + categories.TECH3 * categories.ECONOMIC, 'M5_Sera_Main_Base_Area', ArmyBrains[Seraphim])

    ------------------
    -- Initial Patrols
    ------------------
    -- Seraphim
    local platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M5_Sera_Main_DefGroup', 'GrowthFormation')
    for _, v in platoon:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M5_Sera_Main_Base_Air_Def_Chain')))
    end

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M5_Sera_West_DefGroup', 'GrowthFormation')
    for _, v in platoon:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M5_Sera_Island_West_AirDef_Chain')))
    end

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M5_Sera_Middle_DefGroup', 'GrowthFormation')
    for _, v in platoon:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M5_Sera_Island_Middle_AirDef_Chain')))
    end

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M5_Attack_UEF', 'AttackFormation')
    for _, v in EntityCategoryFilterDown(categories.xss0201, platoon:GetPlatoonUnits()) do
        IssueDive({v})
    end
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M5_UEF_Island_Naval_Defense_Chain1')

    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M5_Attack_UEF2', 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M5_Sera_Init_Attack_UEF')
    for i = 1, 3 do
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M5_Air_Attack_UEF' .. i, 'AttackFormation')
        ScenarioFramework.PlatoonPatrolChain(platoon, 'M5_Sera_Init_Attack_UEF')
    end
    
    -- UEF
    platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M5_Init_UEF_Air', 'GrowthFormation')
    for _, v in platoon:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M5_UEF_Island_Air_Defense_Chain')))
    end

    for i = 1, 2 do
        platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M5_Init_UEF_Naval_' .. i, 'AttackFormation')
        ScenarioFramework.PlatoonPatrolChain(platoon, 'M5_UEF_Island_Naval_Defense_Chain' ..i)
    end

    ---------------
    -- Seraphim ACU
    ---------------
    ScenarioInfo.SeraACU = ScenarioFramework.SpawnCommander('Seraphim', 'M5_Sera_ACU', false, 'Zottoo-Zithutin', false, false,
        {'AdvancedEngineering', 'DamageStabilization', 'DamageStabilizationAdvanced', 'RateOfFire'})
    ScenarioInfo.SeraACU:SetCanBeKilled(false)
    ScenarioInfo.SeraACU:SetCapturable(false)
    ScenarioInfo.SeraACU:SetReclaimable(false)
    ScenarioFramework.CreateUnitDamagedTrigger(SeraACUWarp, ScenarioInfo.SeraACU, .8)
    ZottooWestTM:AddTauntingCharacter(ScenarioInfo.SeraACU)

    -----------------------
    -- Objective Structures
    -----------------------
    ScenarioInfo.M5_Other_Buildings = ScenarioUtils.CreateArmyGroup('Objective', 'M5_Other_Buildings')
    for _, v in ScenarioInfo.M5_Other_Buildings do
        v:SetCapturable(false)
        v:SetReclaimable(false)
    end
    -- No more invincible civilian buildings
    for _, v in ScenarioInfo.M1_Other_Buildings do
        v:SetCanTakeDamage(true)
        v:SetCanBeKilled(true)
    end
    for _, v in ScenarioInfo.M2_Other_Buildings do
        v:SetCanTakeDamage(true)
        v:SetCanBeKilled(true)
    end
    for _, v in ScenarioInfo.UEFGate do
        v:SetCanTakeDamage(true)
        v:SetCanBeKilled(true)
    end

    -----------
    -- Wreckage
    -----------
    ScenarioUtils.CreateArmyGroup('UEFAlly', 'M5_Wrecks', true)
    
    ForkThread(IntroMission5NIS)
end

function IntroMission5NIS()
    ScenarioFramework.SetPlayableArea('M5_Area', false)
    if not SkipNIS5 then
        Cinematics.EnterNISMode()
        Cinematics.SetInvincible( 'M3_Area' )

        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_5_1'), 0)
        ScenarioFramework.Dialogue(OpStrings.obj5intro1, nil, true)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_5_2'), 5)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_5_3'), 7)
        Cinematics.CameraTrackEntity( ScenarioInfo.UEFSACU, 30, 6 )
        WaitSeconds(1.5)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_5_4'), 3)
        
        WaitSeconds(2)
        
        Cinematics.SetInvincible( 'M3_Area', true )
        Cinematics.ExitNISMode()
                            
    else
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_5_4'), 0)

        WaitSeconds(0.1)
    end

    M5InitialAttack()
    StartMission5()
end

function M5InitialAttack()
    local units = nil

    -- Land Attacks
    for i = 1, 2 do
        units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M5_Init_Land_Attack_' .. i, 'GrowthFormation')
        ScenarioFramework.PlatoonPatrolChain(units, 'M5_Sera_Island_West_Land_Attack_Chain')
    end

    -- Naval Attacks
    for i = 1, 2 do
        units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M5_Init_Destroyers' .. i ..'_D' .. Difficulty, 'AttackFormation')
        for k, v in EntityCategoryFilterDown(categories.xss0201, units:GetPlatoonUnits()) do
            IssueDive({v})
        end
        ScenarioFramework.PlatoonPatrolChain(units, 'M5_Sera_Init_Naval_Attack_Chain1')
    end

    units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M5_Init_Destroyers3_D' .. Difficulty, 'AttackFormation')
    for k, v in EntityCategoryFilterDown(categories.xss0201, units:GetPlatoonUnits()) do
        IssueDive({v})
    end
    ScenarioFramework.PlatoonPatrolChain(units, 'M5_Sera_Init_Naval_Attack_Chain2')

    for i = 1, 2 do
        units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M5_Init_Frigates' .. i .. '_D' .. Difficulty, 'AttackFormation')
        ScenarioFramework.PlatoonPatrolChain(units, 'M5_Sera_Init_Naval_Attack_Chain2')
    end

    units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M5_Init_Frigates3_D' .. Difficulty, 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(units, 'M5_Sera_Init_Naval_Attack_Chain1')

    if Difficulty == 3 then
        units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M5_Init_Battleship', 'AttackFormation')
        ScenarioFramework.PlatoonPatrolChain(units, 'M5_Sera_Init_Naval_Attack_Chain1')
    end

    -- Naval Attacks on UEF
    for i = 1, 2 do
        units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', 'M5_Init_AttackUEF_' .. i, 'AttackFormation')
        ScenarioFramework.PlatoonPatrolChain(units, 'M5_Sera_Main_Naval_AttackUEF_Chain2')
    end

    -- Air Attacks
    -- Spawns Interceptors for every 20 Air units, up to 5 groups
    local num = 0
    for _, player in ScenarioInfo.HumanPlayers do
        num = num + table.getn(ArmyBrains[player]:GetListOfUnits(categories.AIR * categories.MOBILE, false))
    end

    if(num > 0) then
        num = math.ceil(num/20)
        if(num > 5) then
            num = 5
        end
        for i = 1, num do
            for j = 1, 2 do
                units = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Seraphim', 'M5_Sera_Adapt_Intie' .. j .. '_D' .. Difficulty, 'GrowthFormation', 5)
                ScenarioFramework.PlatoonPatrolChain(units, 'M5_Sera_Init_AirAttack_Chain' .. Random(1,3))
            end
        end
    end

    -- Spawns Bombers for every 30 Land units, up to 4 groups
    local num = 0
    for _, player in ScenarioInfo.HumanPlayers do
        num = num + table.getn(ArmyBrains[player]:GetListOfUnits(categories.LAND * categories.MOBILE, false))
    end

    if(num > 0) then
        num = math.ceil(num/30)
        if(num > 4) then
            num = 4
        end
        for i = 1, num do
            for j = 1, 3 do
                units = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Seraphim', 'M5_Sera_Adapt_Bombers' .. j .. '_D' .. Difficulty, 'GrowthFormation', 5)
                ScenarioFramework.PlatoonPatrolChain(units, 'M5_Sera_Init_AirAttack_Chain' .. Random(1,3))
            end
        end
    end

    -- Spawns Gunships for every 20 Land units, up to 6 groups
    local num = 0
    for _, player in ScenarioInfo.HumanPlayers do
        num = num + table.getn(ArmyBrains[player]:GetListOfUnits(categories.LAND * categories.MOBILE, false))
    end

    if(num > 0) then
        num = math.ceil(num/20)
        if(num > 6) then
            num = 6
        end
        for i = 1, num do
            for j = 1, 2 do
                units = ScenarioUtils.CreateArmyGroupAsPlatoonVeteran('Seraphim', 'M5_Sera_Adapt_Gunships' .. j .. '_D' .. Difficulty, 'GrowthFormation', 5)
                ScenarioFramework.PlatoonPatrolChain(units, 'M5_Sera_Init_AirAttack_Chain' .. Random(1,3))
            end
        end
    end
end

function StartMission5()
    ScenarioFramework.Dialogue(OpStrings.ProtectsACU, false, true)
    -----------------------------------------
    -- Primary Objective 1 - Protect UEF sACU
    -----------------------------------------
    ScenarioInfo.M5P1 = Objectives.Protect(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Protect sACU',                 -- title
        'Protect Morax at all costs, until he is able to withdraw to the quantum gateway',         -- description
        {                               -- target
            Units = {ScenarioInfo.UEFSACU},
        }
   )
    ScenarioInfo.M5P1:AddResultCallback(
        function(result)
            if(not result and not ScenarioInfo.OpEnded) then
                PlayerLose()
            end
        end
   )
    table.insert(AssignedObjectives, ScenarioInfo.M5P1)

    SetupSACUM5Warnings()
    ScenarioFramework.CreateUnitDamagedTrigger(M5sACUTakingDamage1, ScenarioInfo.UEFSACU, .01)  --guanranteed first-damaged warning

    ScenarioFramework.CreateAreaTrigger(KillSeraphimCommander, ScenarioUtils.AreaToRect('M5_Sera_Main_Base_Area'), categories.ALLUNITS, true, false, ArmyBrains[Player], 1, false)

    ScenarioFramework.CreateTimerTrigger(ProtectCivilians, 30)
    ScenarioFramework.CreateTimerTrigger(SecondSeraACUIntro, 30*60)
    ScenarioFramework.CreateTimerTrigger(BackgroundCivilianLeaving1, 10*60)

    SetupWestM5Taunts()
end

function KillSeraphimCommander()
    ScenarioFramework.Dialogue(OpStrings.M5KillSeraACU)
    --------------------------------------------
    -- Primary Objective 2 - Defeat Seraphim ACU
    --------------------------------------------
    ScenarioInfo.M5P2 = Objectives.KillOrCapture(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Defeat Seraphim Commander',  -- title
        'Kill the Seraphim Commander in order to buy more time for your evacuation',  -- description
        {                               -- target
            Units = {ScenarioInfo.SeraACU},
            MarkUnits = true,
        }
   )
    ScenarioInfo.M5P2:AddResultCallback(
        function(result)
            if(result) then
                -- Checks if Seraphim main base is destroyed, if not then assign objective to kill it before we evacuate Morax
                if not ScenarioFramework.GroupDeathCheck(ScenarioInfo.M5SeraBase) then
                    ScenarioFramework.Dialogue(OpStrings.M5SeraDefeated, Mission5Part2, true)
                else
                    ScenarioFramework.Dialogue(OpStrings.M5SeraDefeated, sACUstartevac, true)
                end
            end
        end
   )
    table.insert(AssignedObjectives, ScenarioInfo.M5P2)
end

function ProtectCivilians()
    ScenarioFramework.Dialogue(OpStrings.M5ProtectCivs, false, true)
    local units = ScenarioFramework.GetCatUnitsInArea((categories.uec1101 + categories.uec1201 + categories.uec1301 + categories.uec1401 + categories.uec1501 + categories.xec1301), 'M5_Area', ArmyBrains[Objective])
    --------------------------------------------
    -- Secondary Objective 1 - Protect Civilians
    --------------------------------------------
    ScenarioInfo.M5S1 = Objectives.Protect(
        'secondary',                              -- type
        'incomplete',                           -- complete
        'Protect Civilian Cities',          -- title
        'At least 80% of the civilian buildings must survive the Seraphim onslaught until the planet is evacuated',          -- description
        {                                       -- target
            Units = units,
            NumRequired = math.ceil(table.getn(units)/1.25),
            PercentProgress = true,
            ShowFaction = 'UEF',
        }
    )
    ScenarioInfo.M5S1:AddResultCallback(
        function(result)
            if(not result and not ScenarioInfo.OpEnded) then
                ScenarioFramework.Dialogue(OpStrings.M5CivsDied)
            end
        end
    )
    table.insert(AssignedObjectives, ScenarioInfo.M5S1)

    ScenarioInfo.M5CivBuildingCount = table.getn(units)
    ScenarioInfo.M5BuildingFailLimit = math.ceil(table.getn(units)/1.25)
    for i = 1, ScenarioInfo.M5CivBuildingCount do
        ScenarioFramework.CreateUnitDeathTrigger(M5S1Warnings, units[i])
    end

    ScenarioFramework.Dialogue(OpStrings.obj5intro2, nil, true)
    ----------------------------------------------------
    -- Secondary Objective 2 - Destroy Sera Island Bases
    ----------------------------------------------------
    ScenarioInfo.M5S2 = Objectives.CategoriesInArea(
        'secondary',                              -- type
        'incomplete',                           -- complete
        'Eliminate Seraphim Forces on the Island',          -- title
        'Secure the island by destroying the Seraphim bases located on it, allowing the evacuation to begin',          -- description
        'kill',                         -- action
        {                                       -- target
            MarkUnits = true,
            Requirements = {
                {   
                    Area = 'M5_Sera_Island_West_Base_Area',
                    Category = categories.FACTORY + (categories.TECH2 * categories.ECONOMIC),
                    CompareOp = '<=',
                    Value = 0,
                    ArmyIndex = Seraphim
                },
                {   
                    Area = 'M5_Sera_Island_Middle_Base_Area',
                    Category = categories.FACTORY + (categories.TECH2 * categories.ECONOMIC),
                    CompareOp = '<=',
                    Value = 0,
                    ArmyIndex = Seraphim
                },
            },
        }
    )
    ScenarioInfo.M5S2:AddResultCallback(
        function(result)
            if(result) then
                if ScenarioInfo.M5S1.Active then
                    ScenarioInfo.TrucksCreated = 0
                    ScenarioInfo.TrucksDestroyed = 0
                    ScenarioInfo.TrucksEscorted = 0
                    ScenarioInfo.Trucks = {}

                    ScenarioInfo.M5S1:ManualResult(true)

                    ScenarioFramework.Dialogue(OpStrings.IslandBaseAllKilled, Mission5Secondary2, true)
                else
                    ScenarioFramework.Dialogue(OpStrings.IslandBaseAllKilledNoCiv, nil, true)
                end
            end
        end
    )
    table.insert(AssignedObjectives, ScenarioInfo.M5S2)
end

function SeraACUWarp()
    ScenarioFramework.Dialogue(OpStrings.TAUNT34)
    -- ScenarioFramework.Dialogue(OpStrings.X03_M03_200, nil, true)
    ForkThread(
        function()
            ScenarioFramework.FakeTeleportUnit(ScenarioInfo.SeraACU, true)
        end
    )  
    ScenarioInfo.M5P2:ManualResult(true)
end

function M5sACUTakingDamage1()
    if not ScenarioInfo.UEFSACU:IsDead() then
        ScenarioFramework.Dialogue(OpStrings.sACUTakesDmg)
    end
end

function M5S1Warnings()
    ScenarioInfo.M5CivBuildingCount = ScenarioInfo.M5CivBuildingCount - 1

    -- if we have only 3 buildings more than the min, play a warning
    if ScenarioInfo.M5CivBuildingCount == (ScenarioInfo.M5BuildingFailLimit + 4) and ScenarioInfo.M5S1.Active then
        ScenarioFramework.Dialogue(OpStrings.LosingCivs1)
    end

    -- if we have only 1 building more than the min, play another
    if ScenarioInfo.M5CivBuildingCount == (ScenarioInfo.M5BuildingFailLimit + 1) and ScenarioInfo.M5S1.Active then
        ScenarioFramework.Dialogue(OpStrings.LosingCivs2)
    end
end

function Mission5Part2()
    -- Objective to kill rest of the main seraphim base after killing ACU if it's not dead yet.
    ScenarioFramework.Dialogue(OpStrings.M5SeraBaseRemains, false, true)
    -------------------------------------------
    -- Primary Objective 3 - Destroy Enemy Base
    -------------------------------------------
    ScenarioInfo.M5P3 = Objectives.CategoriesInArea(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Destroy Seraphim Base',                 -- title
        'Eliminate the Seraphim base of operations in the area',  -- description
        'kill',                         -- action
        {                               -- target
            MarkUnits = true,
            Requirements = {
                {   
                    Area = 'M5_Sera_Main_Base_Area',
                    Category = categories.FACTORY + (categories.TECH2 * categories.ECONOMIC) + (categories.TECH3 * categories.ECONOMIC),
                    CompareOp = '<=',
                    Value = 0,
                    ArmyIndex = Seraphim
                },
            },
        }
   )
    ScenarioInfo.M5P3:AddResultCallback(
        function(result)
            if(result) then
                ScenarioFramework.Dialogue(OpStrings.sACURescued1, sACUstartevac)
            end
        end
    )
    table.insert(AssignedObjectives, ScenarioInfo.M5P3)
end

function Mission5Secondary2()
    local watchCommands = {}
    ScenarioFramework.Dialogue(OpStrings.M5TrucksReady)
    ScenarioInfo.AllowTruckWarning = true
    ScenarioInfo.M5TruckWarningDialogue = 0
    for i = 1, MaxTrucks do
        ScenarioInfo.TrucksCreated = i
        local unit = ScenarioUtils.CreateArmyUnit('Player', 'M5_Truck_'..ScenarioInfo.TrucksCreated)
        ScenarioFramework.CreateUnitDamagedTrigger(M5TruckDamageWarning, unit, .01)
        ScenarioFramework.CreateUnitDestroyedTrigger(TruckDestroyed, unit)
        ScenarioFramework.CreateUnitToMarkerDistanceTrigger(TruckRescued, unit, ScenarioUtils.MarkerToPosition('UEF_Secondary_Escort_Marker'), 20)
        ScenarioFramework.CreateUnitToMarkerDistanceTrigger(TruckInBuilding, unit, ScenarioUtils.MarkerToPosition('UEF_Secondary_Escort_Marker'), 3)
        table.insert(ScenarioInfo.Trucks, unit)

        IssueMove({unit}, ScenarioUtils.MarkerToPosition('M5_Truck_ParkSpot_' .. i))
    end

    ------------------------------------------------------
    -- Mission 5 Secondary 3 - Evacuate Civilians - Part 1
    ------------------------------------------------------
    ScenarioInfo.M5S3 = Objectives.Basic(
        'secondary',                                        -- type
        'incomplete',                                       -- complete
        'Evacuate Cicilians',                      -- title
        'Evacuate the civilians by transporting all the civilian trucks to the Quantum Gateway',                      -- description
        Objectives.GetActionIcon('move'),
        {                                                   -- target
            Area = 'UEF_Evac_Area',
            MarkArea = true,
        }
    )
    table.insert(AssignedObjectives, ScenarioInfo.M5S3)
    -- ScenarioFramework.CreateTimerTrigger(M5S5Reminder1, 10*60)
end

function M5TruckDamageWarning()
    if ScenarioInfo.AllowTruckWarning then
        ScenarioInfo.M5TruckWarningDialogue = ScenarioInfo.M2TruckWarningDialogue + 1
        if ScenarioInfo.M5TruckWarningDialogue == 1 then
            ScenarioFramework.Dialogue(OpStrings.M5TruckDamaged1)
            ScenarioInfo.AllowTruckWarning = false
            ScenarioFramework.CreateTimerTrigger(M5TruckWarningUnlock, 30)
        end
        if ScenarioInfo.M5TruckWarningDialogue == 2 then
            ScenarioFramework.Dialogue(OpStrings.M5TruckDamaged2)
            ScenarioInfo.AllowTruckWarning = false
            ScenarioFramework.CreateTimerTrigger(M5TruckWarningUnlock, 30)
        end
    end
end

function M5TruckWarningUnlock()
    ScenarioInfo.AllowTruckWarning = true
end

function TruckDestroyed()
    ScenarioInfo.TrucksDestroyed = ScenarioInfo.TrucksDestroyed + 1
    if(ScenarioInfo.TrucksDestroyed == 1) then
        ScenarioFramework.Dialogue(OpStrings.M5TruckDestroyed1)
    elseif(ScenarioInfo.TrucksDestroyed == 2) then
        ScenarioFramework.Dialogue(OpStrings.M5TruckDestroyed2)
    elseif(ScenarioInfo.TrucksDestroyed == 3) then
        ScenarioFramework.Dialogue(OpStrings.M5TruckDestroyed3)
    end
    if((MaxTrucks - ScenarioInfo.TrucksDestroyed) < RequiredTrucks and ScenarioInfo.M5S3) then
        ScenarioInfo.M5S3:ManualResult(false)
        ScenarioFramework.Dialogue(OpStrings.M5AllTrucksDestroyed)
    end
end

function TruckRescued(unit)
    for k,v in ScenarioInfo.Trucks do
        if(v == unit) then
            table.remove(ScenarioInfo.Trucks, k)
        end
    end
    unit:SetCanBeKilled(false)
    IssueStop({unit})
    IssueMove({unit}, ScenarioUtils.MarkerToPosition('UEF_Secondary_Escort_Marker'))
    ScenarioInfo.TrucksEscorted = ScenarioInfo.TrucksEscorted + 1

    if(ScenarioInfo.TrucksEscorted == RequiredTrucks) then
        ScenarioInfo.M5S3:ManualResult(true)
        ScenarioFramework.Dialogue(OpStrings.M5AllTruckRescued)
    
    elseif(not ScenarioInfo.TruckArriveLock) then
        if(ScenarioInfo.TrucksEscorted == 1) then
            ScenarioInfo.TruckArriveLock = true
            ScenarioFramework.Dialogue(OpStrings.M5TruckRescued1)
            ScenarioFramework.CreateTimerTrigger(M5UnlockTruckArriveDialogue, 15)
        elseif(ScenarioInfo.TrucksEscorted == 2) then
            ScenarioInfo.TruckArriveLock = true
            ScenarioFramework.Dialogue(OpStrings.M5TruckRescued2)
            ScenarioFramework.CreateTimerTrigger(M5UnlockTruckArriveDialogue, 15)
        end
    end
end

function M5UnlockTruckArriveDialogue()
    ScenarioInfo.TruckArriveLock = false
end

function TruckInBuilding(unit)
    ScenarioFramework.FakeTeleportUnit(unit, true)
end

function sACUstartevac()
    -- Build Transport
    M5UEFAI.EscapeTransportBuilder()
    LOG('speed2 >>> Transport for sACU under construction')

    ScenarioFramework.CreateArmyStatTrigger(SACUescape, ArmyBrains[UEF], 'SACUescape',
        {{StatType = 'Units_Active', CompareType = 'GreaterThanOrEqual', Value = 1, Category = categories.uea0104}})
end

function SACUescape()
    if ScenarioInfo.M5P1.Active then
        ForkThread(function()
            M5UEFAI.DisbandSACUPlatoon()

            WaitSeconds(2)

            ScenarioInfo.sACUTransport = ScenarioFramework.GetCatUnitsInArea((categories.uea0104), 'M5_UEF_Island_Base_Area', ArmyBrains[UEF])
            IssueClearCommands({ScenarioInfo.UEFSACU})

            -- Platoon for sACU to make sure BaseManager won't steal it back.
            local platoon = ArmyBrains[UEF]:MakePlatoon('', '')
            ArmyBrains[UEF]:AssignUnitsToPlatoon(platoon, {ScenarioInfo.UEFSACU}, 'Attack', 'GrowthFormation')

            IssueTransportLoad({ScenarioInfo.UEFSACU}, ScenarioInfo.sACUTransport[1])
            IssueMove({ScenarioInfo.sACUTransport[1]}, ScenarioUtils.MarkerToPosition('M5_Transport_Marker1'))
            IssueTransportUnload({ScenarioInfo.sACUTransport[1]}, ScenarioUtils.MarkerToPosition('M5_Transport_Drop'))

            local AirUnits = ScenarioFramework.GetCatUnitsInArea(categories.AIR * categories.MOBILE - categories.uea0104, 'M5_UEF_Island_Base_Area', ArmyBrains[UEF])
            for k, unit in AirUnits do
                if (unit and not unit:IsDead()) then
                    IssueClearCommands({ unit })
                    IssueGuard({ unit }, ScenarioInfo.sACUTransport[1])
                end
            end

            while(not ScenarioInfo.UEFSACU:IsDead() and not ScenarioInfo.UEFSACU:IsUnitState('Attached')) do
                WaitSeconds(.5)
            end

            ScenarioFramework.CreateUnitToMarkerDistanceTrigger(SACUInBuilding, ScenarioInfo.UEFSACU, ScenarioUtils.MarkerToPosition('UEF_Secondary_Escort_Marker'), 5)

            WaitSeconds(5)

            while(not ScenarioInfo.UEFSACU:IsDead() and ScenarioInfo.UEFSACU:IsUnitState('Attached')) do
                WaitSeconds(.5)
            end

            IssueMove({ScenarioInfo.UEFSACU}, ScenarioUtils.MarkerToPosition('UEF_Secondary_Escort_Marker'))

            for k, unit in AirUnits do
                if (unit and not unit:IsDead()) then
                    IssueClearCommands({ unit })
                    IssueGuard({ unit }, ScenarioInfo.UEFSACU)
                end
            end
        end)
    end
end

function SACUInBuilding()
    ScenarioFramework.FakeTeleportUnit(ScenarioInfo.UEFSACU, true)
    ScenarioFramework.Dialogue(OpStrings.sACURescued2, LeavePlanetObjective, true)
    ScenarioInfo.M5P1:ManualResult(true)
end

function LeavePlanetObjective()
    ---------------------------------------
    -- Primary Objective - Leave the Planet
    ---------------------------------------
    ScenarioInfo.M6P1 = Objectives.SpecificUnitsInArea(
        'primary',                      -- type
        'incomplete',                   -- status
        'Leave the Planet',  -- title
        'Escape the planet using the Quantum Gateway',  -- description
        {                               -- target
            Units = {ScenarioInfo.PlayerCDR},
            Area = 'ACU_Evac_Area',
            MarkArea = true,
        }
   )
    ScenarioInfo.M6P1:AddResultCallback(
        function(result)
            if result then
                ScenarioFramework.FakeTeleportUnit(ScenarioInfo.PlayerCDR, true)
                ScenarioFramework.CDRDeathNISCamera(ScenarioInfo.PlayerCDR)

                --ScenarioInfo.PlayerCDRThroughTheGate = true
                PlayerWin()
            end
        end
   )
    table.insert(AssignedObjectives, ScenarioInfo.M3P1)
end

-----------------------------
-- Mission 5 Civilians moving
-----------------------------
function BackgroundCivilianLeaving1()
    -- Just to add some movent on the map (not that there wouldn't be enough already)
    ForkThread(
        function()
            for i = 1, 6 do
                local unit = ScenarioUtils.CreateArmyUnit('UEFAlly', 'M5_UEFAlly_Truck_' .. i)
                IssueMove({unit}, ScenarioUtils.MarkerToPosition('UEF_Secondary_Escort_Marker'))
                ScenarioFramework.CreateUnitToMarkerDistanceTrigger(TruckInBuilding, unit, ScenarioUtils.MarkerToPosition('UEF_Secondary_Escort_Marker'), 3)
            end

            WaitSeconds(4*60)

            for i = 7, 12 do
                local unit = ScenarioUtils.CreateArmyUnit('UEFAlly', 'M5_UEFAlly_Truck_' .. i)
                IssueMove({unit}, ScenarioUtils.MarkerToPosition('UEF_Secondary_Escort_Marker'))
                ScenarioFramework.CreateUnitToMarkerDistanceTrigger(TruckInBuilding, unit, ScenarioUtils.MarkerToPosition('UEF_Secondary_Escort_Marker'), 3)
            end

            WaitSeconds(2*60)

            for i = 13, 14 do
                local unit = ScenarioUtils.CreateArmyUnit('UEFAlly', 'M5_UEFAlly_Truck_' .. i)
                IssueMove({unit}, ScenarioUtils.MarkerToPosition('UEF_Secondary_Escort_Marker'))
                ScenarioFramework.CreateUnitToMarkerDistanceTrigger(TruckInBuilding, unit, ScenarioUtils.MarkerToPosition('UEF_Secondary_Escort_Marker'), 3)
            end
        end
    )
    ScenarioFramework.CreateTimerTrigger(BackgroundCivilianLeaving2, 5*60)
end

function BackgroundCivilianLeaving2()
    -- Sends some transports to evacuate civ trucks through gate.
    ForkThread(
        function()
            local route, civiliantrucks, transport = 0, nil, nil

            ScenarioInfo.DestroyTrigger = ScenarioFramework.CreateAreaTrigger(DestroyUnit, ScenarioUtils.AreaToRect('M5_TransportDeath_Area'), categories.UEF * categories.TRANSPORTATION, false, false, ArmyBrains[UEFAlly])
            
            while route < 3 do
                civiliantrucks = ScenarioUtils.CreateArmyGroup('UEFAlly', 'M5_Transport_Units_P2')
                transport = ScenarioUtils.CreateArmyGroup('UEFAlly', 'M5_Transports_P2')
                ScenarioFramework.AttachUnitsToTransports(civiliantrucks, transport)
                IssueTransportUnload(transport, ScenarioUtils.MarkerToPosition('M5_Transport_Drop'))
                IssueMove(transport, ScenarioUtils.MarkerToPosition('M5_Transport_Death'))
                for k, v in civiliantrucks do
                    IssueMove({v}, ScenarioUtils.MarkerToPosition('UEF_Secondary_Escort_Marker'))
                    ScenarioFramework.CreateUnitToMarkerDistanceTrigger(TruckInBuilding, v, ScenarioUtils.MarkerToPosition('UEF_Secondary_Escort_Marker'), 3)
                end
                route = route + 1
                WaitSeconds(Random(60, 120))
            end
            while route < 8 do
                civiliantrucks = ScenarioUtils.CreateArmyGroup('UEFAlly', 'M5_Transport_Units_P1')
                transport = ScenarioUtils.CreateArmyGroup('UEFAlly', 'M5_Transports_P1')
                ScenarioFramework.AttachUnitsToTransports(civiliantrucks, transport)
                IssueTransportUnload(transport, ScenarioUtils.MarkerToPosition('M5_Transport_Drop'))
                IssueMove(transport, ScenarioUtils.MarkerToPosition('M5_Transport_Death'))
                for k, v in civiliantrucks do
                    IssueMove({v}, ScenarioUtils.MarkerToPosition('UEF_Secondary_Escort_Marker'))
                    ScenarioFramework.CreateUnitToMarkerDistanceTrigger(TruckInBuilding, v, ScenarioUtils.MarkerToPosition('UEF_Secondary_Escort_Marker'), 3)
                end
                route = route + 1
                WaitSeconds(Random(60, 120))
            end
            
        end
    )
end

function DestroyUnit(unit)
    unit:Destroy()
end

-------------
-- Final Part
-------------
function SecondSeraACUIntro()
    ScenarioFramework.Dialogue(OpStrings.M6SecondSeraACU, SecondSeraACU, true)
end

function SecondSeraACU()
    ScenarioFramework.SetPlayableArea('M6_Area', true)
    -- ScenarioUtils.CreateArmyGroup('Seraphim', 'M6_Island_Base')
    ScenarioUtils.CreateArmyGroup('Seraphim', 'M6_Sera_MEX1')
    ScenarioUtils.CreateArmyGroup('Seraphim', 'M6_Sera_FACT1')
    ScenarioUtils.CreateArmyGroup('Seraphim', 'M6_Sera_FACT2')
    ScenarioUtils.CreateArmyGroup('Seraphim', 'M6_Sera_FACN')
    ScenarioUtils.CreateArmyGroup('Seraphim', 'M6_Sera_MEX2')

    -------------
    -- Second ACU
    -------------
    ScenarioInfo.EastSeraCDR = ScenarioUtils.CreateArmyUnit('Seraphim', 'M6_SeraACU')
    -- ScenarioInfo.EastSeraCDR:PlayCommanderWarpInEffect()
    ScenarioInfo.EastSeraCDR:CreateEnhancement('ResourceAllocationAdvanced')
    ScenarioInfo.EastSeraCDR:CreateEnhancement('T3Engineering')
    ScenarioInfo.EastSeraCDR:CreateEnhancement('RateOfFire')
    
    -- ScenarioFramework.CreateUnitDamagedTrigger(FletcherWarp, ScenarioInfo.FletcherCDR, .8)
    -- FletcherTM:AddTauntingCharacter(ScenarioInfo.FletcherCDR)
    ScenarioInfo.EastSeraCDR:SetCustomName( "Evil One" )

    M6SeraphimAI.SeraphimM6IslandBaseAI()

    ScenarioFramework.CreateTimerTrigger(FinalAttacksIntro1, 5*60)
end

function FinalAttacksIntro1()
    ScenarioFramework.Dialogue(OpStrings.M6InvCount1, false, true)
    ScenarioFramework.CreateTimerTrigger(FinalAttacksIntro2, 15*60)
end

function FinalAttacksIntro2()
    ScenarioFramework.Dialogue(OpStrings.M6InvCount2, false, true)
    ScenarioFramework.CreateTimerTrigger(FinalAttacksIntro3, 10*60)
end

function FinalAttacksIntro3()
    ScenarioFramework.Dialogue(OpStrings.M6InvCount3, false, true)
    ScenarioFramework.CreateTimerTrigger(FinalAttacks, 5*60)
end

function FinalAttacks()
    -- function for continuous attacks that very nicely replaces time limit. If you dont finish the mission before this function kicks in, too bad.
    -- Spawns random attack group sends on patrol. Waits a bit and repeat. Strenght of groups is from 1 to 3 where 3 has the most fire power.

    -- Tell player that he's pretty much fucked.
    ScenarioFramework.Dialogue(OpStrings.M6SeraAttack, false, true)
    ----------------
    -- Naval Attacks
    ----------------
    -- North Naval Attacks
    ForkThread(
        function()      
            local NorthNavalGroups = {
                "FA_NavalN1_P1",
                "FA_NavalN1_P2",
                "FA_NavalN1_P3",
                "FA_NavalN2_P1",
                "FA_NavalN2_P2",
                "FA_NavalN2_P3",
                "FA_NavalN3_P1",
                "FA_NavalN3_P2",
                "FA_NavalN3_P3",
            }
             
            local NorthNavalChains = {
                "FA_North_Naval_Chain_1",
                "FA_North_Naval_Chain_2",
                "FA_North_Naval_Chain_3",
            }
            local N_units = nil
            while true do
                local N_group = NorthNavalGroups[math.random(1, table.getn(NorthNavalGroups))]
                local N_chain = NorthNavalChains[math.random(1, table.getn(NorthNavalChains))]
         
                local N_units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', N_group, 'GrowthFormation')
                for k, v in EntityCategoryFilterDown(categories.xss0201, N_units:GetPlatoonUnits()) do
                    IssueDive({v})
                end
                ScenarioFramework.PlatoonPatrolChain(N_units, N_chain)
                LOG('speed2 >>> Spawned units of group "'..N_group..'" for chain "'..N_chain..'"')
                WaitSeconds(Random(90, 120))
            end
        end
    )
    -- West Naval Attacks
    ForkThread(
        function()      
            local WestNavalGroups = {
                "FA_NavalW1_P1",
                "FA_NavalW1_P2",
                "FA_NavalW1_P3",
                "FA_NavalW2_P1",
                "FA_NavalW2_P2",
                "FA_NavalW2_P3",
            }
             
            local WestNavalChains = {
                "M5_Sera_Main_Naval_AttackPlayer_Chain1",
                "M5_Sera_Main_Naval_AttackPlayer_Chain2",
                "M5_Sera_Main_Naval_AttackPlayer_Chain3",
            }

            local W_units = nil
            while true do
                local W_group = WestNavalGroups[math.random(1, table.getn(WestNavalGroups))]
                local W_chain = WestNavalChains[math.random(1, table.getn(WestNavalChains))]
         
                local W_units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', W_group, 'GrowthFormation')
                for k, v in EntityCategoryFilterDown(categories.xss0201, W_units:GetPlatoonUnits()) do
                    IssueDive({v})
                end
                ScenarioFramework.PlatoonPatrolChain(W_units, W_chain)
                LOG('speed2 >>> Spawned units of group "'..W_group..'" for chain "'..W_chain..'"')
                WaitSeconds(Random(100, 115))
            end
        end
    )
    -- East Naval Attacks
    ForkThread(
        function()
            local EastNavalGroups = {
                "FA_NavalE1_P1",
                "FA_NavalE1_P2",
                "FA_NavalE1_P3",
                "FA_NavalE2_P1",
                "FA_NavalE2_P2",
                "FA_NavalE2_P3",
                "FA_NavalE3_P1",
                "FA_NavalE3_P2",
                "FA_NavalE3_P3",
            }
             
            local EastNavalChains = {
                "FA_East_Naval_Chain_1",
                "FA_East_Naval_Chain_2",
            }

            local E_units = nil
            while true do
                local E_group = EastNavalGroups[math.random(1, table.getn(EastNavalGroups))]
                local E_chain = EastNavalChains[math.random(1, table.getn(EastNavalChains))]
         
                local E_units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', E_group, 'GrowthFormation')
                for k, v in EntityCategoryFilterDown(categories.xss0201, E_units:GetPlatoonUnits()) do
                    IssueDive({v})
                end
                ScenarioFramework.PlatoonPatrolChain(E_units, E_chain)
                LOG('speed2 >>> Spawned units of group "'..E_group..'" for chain "'..E_chain..'"')
                WaitSeconds(Random(85, 125))
            end
        end
    )

    --------------
    -- Air Attacks
    --------------
    -- North Air Attacks
    ForkThread(
        function()      
            local NorthAirGroups = {
                "FA_AirN1_P1",
                "FA_AirN1_P2",
                "FA_AirN1_P3",
                "FA_AirN2_P1",
                "FA_AirN2_P2",
                "FA_AirN2_P3",
                "FA_AirN3_P1",
                "FA_AirN3_P2",
                "FA_AirN3_P3",
                "FA_AirN4_P1",
                "FA_AirN4_P2",
                "FA_AirN4_P3",
                "FA_AirN5_P1",
                "FA_AirN5_P2",
                "FA_AirN5_P3",
                "FA_AirN6_P1",
                "FA_AirN6_P2",
                "FA_AirN6_P3",
            }
             
            local NorthAirChains = {
                "M5_Sera_Main_AirAttackPlayer_Chain1",
                "M5_Sera_Main_AirAttackPlayer_Chain2",
                "M5_Sera_Main_AirAttackPlayer_Chain3",
                "M5_Sera_Main_AirAttackPlayer_Chain4",
                "M5_Sera_Main_Naval_AttackPlayer_Chain1",
                "M5_Sera_Main_Naval_AttackPlayer_Chain2",
                "M5_Sera_Main_Naval_AttackPlayer_Chain3",
            }
            local N_Air_units = nil
            while true do
                local N_Air_group = NorthAirGroups[math.random(1, table.getn(NorthAirGroups))]
                local N_Air_chain = NorthAirChains[math.random(1, table.getn(NorthAirChains))]
         
                local N_Air_units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', N_Air_group, 'GrowthFormation')
                ScenarioFramework.PlatoonPatrolChain(N_Air_units, N_Air_chain)
                LOG('speed2 >>> Spawned units of group "'..N_Air_group..'" for chain "'..N_Air_chain..'"')
                WaitSeconds(Random(30, 40))
            end
        end
    )
    -- West Air Attacks
    ForkThread(
        function()      
            local WestAirGroups = {
                "FA_AirW1_P1",
                "FA_AirW1_P2",
                "FA_AirW1_P3",
                "FA_AirW2_P1",
                "FA_AirW2_P2",
                "FA_AirW2_P3",
                "FA_AirW3_P1",
                "FA_AirW3_P2",
                "FA_AirW3_P3",
                "FA_AirW4_P1",
                "FA_AirW4_P2",
                "FA_AirW4_P3",
                "FA_AirW5_P1",
                "FA_AirW5_P2",
                "FA_AirW5_P3",
                "FA_AirW6_P1",
                "FA_AirW6_P2",
                "FA_AirW6_P3",
            }
             
            local WestAirChains = {
                "M5_Sera_Main_AirAttackPlayer_Chain1",
                "M5_Sera_Main_AirAttackPlayer_Chain2",
                "M5_Sera_Main_AirAttackPlayer_Chain3",
                "M5_Sera_Main_AirAttackPlayer_Chain4",
                "M5_Sera_Main_Naval_AttackPlayer_Chain1",
                "M5_Sera_Main_Naval_AttackPlayer_Chain2",
                "M5_Sera_Main_Naval_AttackPlayer_Chain3",
            }

            local W_Air_units = nil
            while true do
                local W_Air_group = WestAirGroups[math.random(1, table.getn(WestAirGroups))]
                local W_Air_chain = WestAirChains[math.random(1, table.getn(WestAirChains))]
         
                local W_Air_units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', W_Air_group, 'GrowthFormation')
                ScenarioFramework.PlatoonPatrolChain(W_Air_units, W_Air_chain)
                LOG('speed2 >>> Spawned units of group "'..W_Air_group..'" for chain "'..W_Air_chain..'"')
                WaitSeconds(Random(25, 35))
            end
        end
    )
    -- East Air Attacks
    ForkThread(
        function()
            local EastAirGroups = {
                "FA_AirE1_P1",
                "FA_AirE1_P2",
                "FA_AirE1_P3",
                "FA_AirE2_P1",
                "FA_AirE2_P2",
                "FA_AirE2_P3",
                "FA_AirE3_P1",
                "FA_AirE3_P2",
                "FA_AirE3_P3",
                "FA_AirE4_P1",
                "FA_AirE4_P2",
                "FA_AirE4_P3",
                "FA_AirE5_P1",
                "FA_AirE5_P2",
                "FA_AirE5_P3",
                "FA_AirE6_P1",
                "FA_AirE6_P2",
                "FA_AirE6_P3",
            }
             
            local EastAirChains = {
                "M6_Sera_Island_Air_Attack_Chain_1",
                "M6_Sera_Island_Air_Attack_Chain_2",
                "M6_Sera_Island_Air_Attack_Chain_3",
                "M6_Sera_Island_Air_Attack_Chain_4",
            }

            local E_Air_units = nil
            while true do
                local E_Air_group = EastAirGroups[math.random(1, table.getn(EastAirGroups))]
                local E_Air_chain = EastAirChains[math.random(1, table.getn(EastAirChains))]
         
                local E_Air_units = ScenarioUtils.CreateArmyGroupAsPlatoon('Seraphim', E_Air_group, 'GrowthFormation')
                ScenarioFramework.PlatoonPatrolChain(E_Air_units, E_Air_chain)
                LOG('speed2 >>> Spawned units of group "'..E_Air_group..'" for chain "'..E_Air_chain..'"')
                WaitSeconds(Random(20, 30))
            end
        end
    )
end

----------------------
-- Objective Reminders
----------------------

-- M1
function M1P1Reminder1()
    if ScenarioInfo.M1BaseDialoguePlayer == false and ScenarioInfo.M1P1.Active then
        ScenarioFramework.Dialogue(OpStrings.base1remind1)
        ScenarioFramework.CreateTimerTrigger(M1P1Reminder2, 15*60)
    end
end

function M1P1Reminder2()
    if ScenarioInfo.M1BaseDialoguePlayer == false and ScenarioInfo.M1P1.Active then
        ScenarioFramework.Dialogue(OpStrings.base1remind2)
    end
end

function M1P1Reminder3()
    if ScenarioInfo.M1BaseDialoguePlayer == true and ScenarioInfo.M1P1.Active then
        ScenarioFramework.Dialogue(OpStrings.base2remind1)
    end
end

function M1S1Reminder()
    while ScenarioInfo.M1S1.Active do
        PlayRandomReminderTaunt()
        WaitSeconds(20*60)
    end
end

function M1S2Reminder()
    while ScenarioInfo.M1S2.Active and not ScenarioInfo.M1S1.Active do
        PlayRandomReminderTaunt()
        WaitSeconds(20*60)
    end
end

-- M2
function M2P1Reminder1()
    if ScenarioInfo.M2P1.Active then
        ScenarioFramework.Dialogue(OpStrings.southbaseremind1)
        ScenarioFramework.CreateTimerTrigger(M2P1Reminder2, 15*60)
    end
end

function M2P1Reminder2()
    if ScenarioInfo.M2P1.Active then
        ScenarioFramework.Dialogue(OpStrings.southbaseremind2)
    end
end

function M2S1Reminder()
    while ScenarioInfo.M2S1.Active do
        PlayRandomReminderTaunt()
        WaitSeconds(20*60)
    end
end

-- M3
function M3P1Reminder1()
    if ScenarioInfo.M3P1.Active then
        ScenarioFramework.Dialogue(OpStrings.airbaseremind1)
        ScenarioFramework.CreateTimerTrigger(M3P1Reminder2, 25*60)
    end
end

function M3P1Reminder2()
    if ScenarioInfo.M3P1.Active then
        ScenarioFramework.Dialogue(OpStrings.airbaseremind2)
    end
end

-- Epic random reminders by Washy
function PlayRandomReminderTaunt()
    local minPlayed = ReminderTaunts[1][2]
    for _, taunt in ReminderTaunts do
        if (taunt[2] < minPlayed) then
            minPlayed = taunt[2]
        end
    end
   
    while (true) do
        tauntToTest = ReminderTaunts[math.random(1, table.getn(ReminderTaunts))]
        if(tauntToTest[2] == minPlayed) then
            tauntToTest[2] = tauntToTest[2] + 1
            ScenarioFramework.Dialogue(tauntToTest[1], nil, true)
            break
        end
    end
end

---------
-- Taunts
---------

function SetupWestM5Taunts()
    --ZottooWestTM:AddUnitKilledTaunt('TAUNT1', ScenarioInfo.UnitNames[Seraphim]['M1_Seraph_East_AC'])
    ZottooWestTM:AddUnitsKilledTaunt('TAUNT2', ArmyBrains[Seraphim], categories.FACTORY * categories.NAVAL, 5)
    ZottooWestTM:AddUnitsKilledTaunt('TAUNT3', ArmyBrains[UEF], categories.NAVAL * categories.MOBILE, 20)
    ZottooWestTM:AddUnitsKilledTaunt('TAUNT4', ArmyBrains[Player], categories.TECH2 * categories.NAVAL, 10)
    ZottooWestTM:AddDamageTaunt('TAUNT5', ScenarioInfo.PlayerCDR, .02)
end

function SetupSACUM5Warnings()
    SACUTM:AddDamageTaunt('sACUDamaged25', ScenarioInfo.UEFSACU, .25)            --SACU damaged to x
    SACUTM:AddDamageTaunt('sACUDamaged50', ScenarioInfo.UEFSACU, .50)
    SACUTM:AddDamageTaunt('sACUDamaged75', ScenarioInfo.UEFSACU, .75)
    SACUTM:AddDamageTaunt('sACUDamaged90', ScenarioInfo.UEFSACU, .90)
end

------------------
-- Debug Functions
------------------

function OnShiftF4()
    sACUstartevac()
end

function OnCtrlF4()
    for k, v in ArmyBrains[UEF]:GetListOfUnits(categories.ALLUNITS, false) do
        v:Kill()
    end
end