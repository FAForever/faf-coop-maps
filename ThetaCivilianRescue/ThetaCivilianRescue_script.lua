-- ****************************************************************************
-- **
-- **  File     : /maps/ThetaCivilianRescue/ThetaCivilianRescue_script.lua
-- **  Author(s): KeyBlue
-- **
-- **  Summary  : Main mission flow script for ThetaCivilianRescue
-- **
-- ****************************************************************************
local Cinematics = import('/lua/cinematics.lua')
local M1CybranAI = import('/maps/ThetaCivilianRescue/ThetaCivilianRescue_m1cybranai.lua')
local M1CybranManual = import('/maps/ThetaCivilianRescue/ThetaCivilianRescue_m1cybran_manual.lua')
local M2CybranAI = import('/maps/ThetaCivilianRescue/ThetaCivilianRescue_m2cybranai.lua')
local M2CybranManual = import('/maps/ThetaCivilianRescue/ThetaCivilianRescue_m2cybran_manual.lua')
local Objectives = import('/lua/ScenarioFramework.lua').Objectives
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local Utilities = import('/lua/Utilities.lua')
local OpStrings = import('/maps/ThetaCivilianRescue/ThetaCivilianRescue_strings.lua')
local TCRUtil = import('/maps/ThetaCivilianRescue/ThetaCivilianRescue_CustomFunctions.lua')

----------
-- Globals
----------
ScenarioInfo.Player = 1
ScenarioInfo.Cybran = 2
ScenarioInfo.Coop1 = 3
ScenarioInfo.Coop2 = 4
ScenarioInfo.Coop3 = 5

ScenarioInfo.hasMonkeylordSpawned = false

---------
-- Locals
---------
local Player = ScenarioInfo.Player
local Cybran = ScenarioInfo.Cybran
local Coop1 = ScenarioInfo.Coop1
local Coop2 = ScenarioInfo.Coop2
local Coop3 = ScenarioInfo.Coop3


local AssignedObjectives = {}
local Difficulty = ScenarioInfo.Options.Difficulty

local M1MapExpandDelay = {30*60, 25*60, 20*60} --30*60, 25*60, 20*60
local M2SpawnMonkeylordTime = {60*60, 45*60, 35*60} --60*60, 45*60, 35*60
local M2SpawnExperimentalsTime = {30*60, 20*60, 10*60} --30*60, 20*60, 10*60
local killedExp = 0
local prematureMonkeylordPreparationTime = 60 --60

--------------
-- Debug only!
--------------
local Debug = false
local SkipNIS1 = false
local SkipMission1 = false

---------
-- Startup
---------
function OnPopulate(scenario)
    ScenarioUtils.InitializeScenarioArmies()
    
    -- Sets Army Colors
    ScenarioFramework.SetUEFPlayerColor(Player)
    ScenarioFramework.SetCybranPlayerColor(Cybran)
    local colors = {
        ['Coop1'] = {81, 82, 241}, --SetUEFAlly1Color
        ['Coop2'] = {133, 148, 255}, --SetUEFAlly2Color
        ['Coop3'] = {71, 114, 148} --SetUEFAllyColor
        }   
    local tblArmy = ListArmies()
    for army, color in colors do
        if tblArmy[ScenarioInfo[army]] then
            ScenarioFramework.SetArmyColor(ScenarioInfo[army], unpack(color))
        end
    end
    
    for index,_ in ScenarioInfo.HumanPlayers do
        ScenarioInfo.NumberOfPlayers = index
    end
    
    
end

function OnStart(self)
    ScenarioUtils.CreateArmyGroup('Player', 'signature', true)

    for _, player in ScenarioInfo.HumanPlayers do
    -- Build Restrictions
        ScenarioFramework.AddRestriction(player, mainRestrictions())
        
        ScenarioFramework.AddRestriction(player, cybranRestrictions())
    
    end
    
    -- Lock off cdr upgrades
    ScenarioFramework.RestrictEnhancements({'ResourceAllocation',
                                            'DamageStablization',
                                            'T3Engineering',
                                            'LeftPod',
                                            'RightPod',
                                            'Shield',
                                            'ShieldGeneratorField',
                                            'TacticalMissile',
                                            'TacticalNukeMissile',
                                            'Teleporter'})
    
    if Debug then
        Utilities.UserConRequest('SallyShears')
    end
    
    if not SkipMission1 then
        IntroMission1()
    else
        ForkThread(SpawnAllACUs)
        IntroMission2()
    end
end

function RemoveAllRestrictions()
    -- Build Restrictions

    for _, player in ScenarioInfo.HumanPlayers do
    -- Build Restrictions
        ScenarioFramework.RemoveRestriction(player, mainRestrictions())
        
        ScenarioFramework.RemoveRestriction(player, cybranRestrictions())
    
    end
    
    -- Lock off cdr upgrades
    ScenarioFramework.RestrictEnhancements({})
    
end

function mainRestrictions()
    return (categories.TECH2 
                + categories.TECH3 
                + categories.EXPERIMENTAL
                + categories.NAVAL
                + categories.TRANSPORTATION -- no transports
                - (categories.TECH2 * categories.LAND)
                - categories.ueb1202 -- T2 mass
                - categories.ueb1201 -- T2 power
                - categories.ueb5202 -- T2 airstaging
                - categories.ueb3201 -- T2 radar
                - categories.ueb2204) -- T2 flak
end

function cybranRestrictions()
    return (categories.Cybran * (categories.TECH2 + categories.TECH3 + categories.EXPERIMENTAL))
end

------------
-- Mission 1
------------
function IntroMission1()
    ScenarioInfo.MissionNumber = 1
    LOG('*DEBUG: Mission' .. ScenarioInfo.MissionNumber)
    -------------------
    -- Cybran West Base
    -------------------
    M1CybranAI.CybranM1WestBaseAI()
    M1CybranManual.CybranM1WestBaseDefensePatrols()
    M1CybranManual.CybranM1WestBaseForwardPatrols()
    
    
    -- Create Objective building
    ScenarioInfo.M1_Cybran_Prison = ScenarioUtils.CreateArmyUnit('Cybran', 'M1_Cybran_Prison')
    ScenarioInfo.M1_Cybran_Prison:SetDoNotTarget(true)
    ScenarioInfo.M1_Cybran_Prison:SetCanTakeDamage(false)
    ScenarioInfo.M1_Cybran_Prison:SetCanBeKilled(false)
    ScenarioInfo.M1_Cybran_Prison:SetReclaimable(false)
    ScenarioInfo.M1_Cybran_Prison:SetCustomName("Cybran Prison")
    
    
    ForkThread(IntroMission1NIS)
end

function IntroMission1NIS()

    ScenarioFramework.SetPlayableArea('M1_Area', false)

    if not SkipNIS1 then
    
        WaitSeconds(2)
        Cinematics.EnterNISMode()

        local VisMarker_West_Base = ScenarioFramework.CreateVisibleAreaLocation(500, ScenarioUtils.MarkerToPosition('NIS_M1_Vis_West_Base'), 0, ArmyBrains[Player])
        
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_Start_Location'), 0)
        
        WaitSeconds(3)
        ScenarioFramework.Dialogue(OpStrings.M1_West_Base_View, nil, true)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_Cybran_West_Base'), 5)
        
        WaitSeconds(2)
        ScenarioFramework.Dialogue(OpStrings.M1_Main_Objective, nil, true)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_Cybran_Prison_1'), 5)
        
        WaitSeconds(5)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_ACU_Spawn'), 3)
        

        WaitSeconds(0.5)
        VisMarker_West_Base:Destroy()
        WaitSeconds(0.5)
        ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('NIS_M1_Vis_West_Base'), 500)
        WaitSeconds(0.5)
        
        Cinematics.ExitNISMode()
                
    end
    
    SpawnAllACUs()
    StartMission1()
end

function SpawnAllACUs()
    ScenarioInfo.PlayerCDR = ScenarioFramework.SpawnCommander('Player', 'Commander', 'Warp', true, true, PlayerDeath)
    
    ScenarioInfo.CoopCDR = {}
    local tblArmy = ListArmies()
    coop = 1
    for iArmy, strArmy in pairs(tblArmy) do
        if iArmy >= ScenarioInfo.Coop1 then
            ScenarioInfo.CoopCDR[coop] = ScenarioFramework.SpawnCommander(strArmy, 'Commander', 'Warp', true, true, PlayerDeath)
            coop = coop + 1
            WaitSeconds(0.5)
        end
    end

end

function StartMission1()
    -----------------------------------------
    -- Primary Objective 1 - Rescue Civilians
    -----------------------------------------
    ScenarioInfo.M1P1 = Objectives.Capture(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Rescue Civilians',  -- title
        'Capture this Cybran prison to free the kidnapped civilians.',  -- description
        {
            Units = {ScenarioInfo.M1_Cybran_Prison},
            FlashVisible = true,
        }
    )
    ScenarioInfo.M1P1:AddResultCallback(
        function(result)
            if(result) then
                LOG('*DEBUG: M1P1')
                if ScenarioInfo.MissionNumber == 1 then
                    ScenarioFramework.Dialogue(OpStrings.M1_Prison_Captured, IntroMission2, true)
                end
            end
        end
    )
    table.insert(AssignedObjectives, ScenarioInfo.M1P1)

    -- Expand map even if objective isn't finished yet
    ScenarioFramework.CreateTimerTrigger(PrematureMission2, M1MapExpandDelay[Difficulty])
    
    ----------------------------------------
    -- Secondary Objective 1 - Destroy Base
    ----------------------------------------
    ScenarioInfo.M1S1 = Objectives.CategoriesInArea(
        'secondary',                      -- type
        'incomplete',                   -- complete
        'Destroy Cybran Base',                 -- title
        'Eliminate the marked Cybran structures to open your path to the prison.',  -- description
        'kill',                         -- action
        {                               -- target
            MarkUnits = true,
            Requirements = {
                {   
                    Area = 'M1_Cybran_Base_Area',
                    Category = categories.FACTORY - categories.EXPERIMENTAL,
                    CompareOp = '<=',
                    Value = 0,
                    ArmyIndex = Cybran,
                },
            },
        }
    )
    ScenarioInfo.M1S1:AddResultCallback(
        function(result)
            LOG('*DEBUG: M1S1')
            if(result) then
                ScenarioFramework.Dialogue(OpStrings.M1_Base_Destroyed, nil, true)
            end
        end
    )
    table.insert(AssignedObjectives, ScenarioInfo.M1S1)
    
    ---------------------------------------------------
    -- Secondary Objective 2 - Destroy Forward Defenses
    ---------------------------------------------------
    if ScenarioInfo.NumberOfPlayers >= 3 then -- only if >=3 players are there forward defenses
        ScenarioFramework.Dialogue(OpStrings.M1_Destroy_Forward_Defenses, nil, true)
        ScenarioInfo.M1S2 = Objectives.CategoriesInArea(
            'secondary',                      -- type
            'incomplete',                   -- complete
            'Destroy Forward Defenses',                 -- title
            'Eliminate the marked Cybran defense structures to open the area for your expansion.',  -- description
            'kill',                         -- action
            {                               -- target
                MarkUnits = true,
                Requirements = {
                    {   
                        Area = 'M1_Forward_Defenses',
                        Category = categories.DEFENSE - categories.WALL,
                        CompareOp = '<=',
                        Value = 0,
                        ArmyIndex = Cybran,
                    },
                },
            }
        )
        ScenarioInfo.M1S2:AddResultCallback(
            function(result)
                LOG('*DEBUG: M1S2')
                if(result) then
                    ScenarioFramework.Dialogue(OpStrings.M1_Forward_Defenses_Destroyed, nil, true)
                end
            end
        )
        table.insert(AssignedObjectives, ScenarioInfo.M1S2)
    end
end

function PrematureMission2()
    if ScenarioInfo.MissionNumber == 1 then
        ScenarioFramework.Dialogue(OpStrings.M1_Too_Slow, IntroMission2, true)
    end
end

function IntroMission2()
    ScenarioInfo.MissionNumber = 2
    LOG('*DEBUG: Mission' .. ScenarioInfo.MissionNumber)
    
    ScenarioFramework.SetPlayableArea('M2_Area', true)
    
    -------------------
    -- Cybran East Base
    -------------------
    M2CybranAI.CybranM2EastBaseAI()
    M2CybranManual.CybranM2EastBaseDefensePatrols()
    M2CybranManual.CybranM2EastBaseUnitDrops()
    
    ----------------------------
    -- Create Objective building
    ----------------------------
    ScenarioInfo.M2_Cybran_Prison = ScenarioUtils.CreateArmyUnit('Cybran', 'M2_Cybran_Prison')
    ScenarioInfo.M2_Cybran_Prison:SetDoNotTarget(true)
    ScenarioInfo.M2_Cybran_Prison:SetCanTakeDamage(false)
    ScenarioInfo.M2_Cybran_Prison:SetCanBeKilled(false)
    ScenarioInfo.M2_Cybran_Prison:SetReclaimable(false)
    ScenarioInfo.M2_Cybran_Prison:SetCustomName("Cybran Prison")
    
    ForkThread(StartMission2)
end

function StartMission2()
    --Wait for everything to be build
    WaitSeconds(2)
    
    -----------------------------------------
    -- Primary Objective 1 - Rescue Civilians
    -----------------------------------------
    ScenarioFramework.Dialogue(OpStrings.M2_Main_Objective, nil, true)
    
    ScenarioInfo.M2P1 = Objectives.Capture(
        'primary',                      -- type
        'incomplete',                   -- complete
        'Rescue Civilians',  -- title
        'Capture this Cybran prison to free the kidnapped civilians.',  -- description
        {
            Units = {ScenarioInfo.M2_Cybran_Prison},
        }
    )
    ScenarioInfo.M2P1:AddResultCallback(
        function(result)
            LOG('*DEBUG: M2P1')
            if(result) then
                if ScenarioInfo.MissionNumber == 2 then
                    ScenarioFramework.Dialogue(OpStrings.M2_Prison_Captured, PlayerWin, true)
                end
            end
        end
    )
    table.insert(AssignedObjectives, ScenarioInfo.M1P1)
    
    ---------------------------------------
    -- Secondary Objective 1 - Destroy Base
    ---------------------------------------
    ScenarioInfo.M2S1 = Objectives.CategoriesInArea(
        'secondary',                      -- type
        'incomplete',                   -- complete
        'Destroy Cybran Base',                 -- title
        'Eliminate the marked Cybran structures to open your path to the prison.',  -- description
        'kill',                         -- action
        {                               -- target
            MarkUnits = true,
            Requirements = {
                {   
                    Area = 'M2_Cybran_Base_Area',
                    Category = categories.FACTORY + categories.DEFENSE - categories.SHIELD - categories.WALL - categories.TECH1 - categories.EXPERIMENTAL,
                    CompareOp = '<=',
                    Value = 0,
                    ArmyIndex = Cybran,
                },
            },
        }
    )
    ScenarioInfo.M2S1:AddResultCallback(
        function(result)
            LOG('*DEBUG: M2S1')
            if(result) then
                ScenarioFramework.Dialogue(OpStrings.M2_Base_Destroyed, nil, true)
            end
        end
    )
    table.insert(AssignedObjectives, ScenarioInfo.M2S1)
    
    ScenarioFramework.CreateArmyIntelTrigger(M2S2MonkeylordObjective, ArmyBrains[Player], 'LOSNow', nil, true, categories.urc1901, true, ArmyBrains[Cybran])
    
    -- Make TimeTrigger in case the player never scouts
    secondsUntilMonkeylord = M2SpawnMonkeylordTime[Difficulty] - math.floor(GetGameTimeSeconds()) + 2 -- add 2 just to make sure there are no race issues, possibly unnecessary
    ScenarioFramework.CreateTimerTrigger(SpawnMonkeyLord, secondsUntilMonkeylord)
    
    if Difficulty >= 3 then
        planPrematureMonkeyLord()
    end
    
    -----------------------------------------------------
    -- Secondary Objective 3+4 - Destroy Forward Defenses
    -----------------------------------------------------
    if ScenarioInfo.NumberOfPlayers >= 3 then -- only if >=3 players are there forward defenses
        ScenarioFramework.Dialogue(OpStrings.M2_Destroy_Forward_Defenses, nil, true)
        ScenarioInfo.M2S3 = Objectives.CategoriesInArea(
            'secondary',                      -- type
            'incomplete',                   -- complete
            'Destroy Forward Defenses 1',                 -- title
            'Eliminate the marked Cybran defense structures to clear the path to the base.',  -- description
            'kill',                         -- action
            {                               -- target
                MarkUnits = true,
                Requirements = {
                    {   
                        Area = 'M2_Forward_Defenses_1',
                        Category = categories.DEFENSE * categories.DIRECTFIRE,
                        CompareOp = '<=',
                        Value = 0,
                        ArmyIndex = Cybran,
                    },
                },
            }
        )
        ScenarioInfo.M2S3:AddResultCallback(
            function(result)
                LOG('*DEBUG: M2S3')
                if(result) then
                    ScenarioFramework.Dialogue(OpStrings.M2_Forward_Defenses_1_Destroyed, nil, true)
                end
            end
        )
        table.insert(AssignedObjectives, ScenarioInfo.M2S3)
        
        if Difficulty >= 3 then
            ScenarioInfo.M2S4 = Objectives.CategoriesInArea(
                'secondary',                      -- type
                'incomplete',                   -- complete
                'Destroy Forward Defenses 2',                 -- title
                'Eliminate the marked Cybran defense structures to clear the path to the base.',  -- description
                'kill',                         -- action
                {                               -- target
                    MarkUnits = true,
                    Requirements = {
                        {   
                            Area = 'M2_Forward_Defenses_2',
                            Category = categories.DEFENSE * categories.DIRECTFIRE,
                            CompareOp = '<=',
                            Value = 0,
                            ArmyIndex = Cybran,
                        },
                    },
                }
            )
            ScenarioInfo.M2S4:AddResultCallback(
                function(result)
                    LOG('*DEBUG: M2S4')
                    if(result) then
                        ScenarioFramework.Dialogue(OpStrings.M2_Forward_Defenses_2_Destroyed, nil, true)
                    end
                end
            )
            table.insert(AssignedObjectives, ScenarioInfo.M2S4)
        end
    end
end

function M2S2MonkeylordObjective(MonkeylordTime)
    ------------------------------------------------------------------------------
    -- Secondary Objective 2 - Complete Primary Objectives before spawn Monkeylord
    ------------------------------------------------------------------------------
    ScenarioFramework.Dialogue(OpStrings.M2_Monkeylord_Detected, nil, true)
    
    secondsUntilMonkeylord = math.max(1, M2SpawnMonkeylordTime[Difficulty] - math.floor(GetGameTimeSeconds()))
    ScenarioInfo.M2S2 = Objectives.Timer(
        'secondary',                      -- type
        'incomplete',                   -- complete
        'Beware of the Monkeylord!',                 -- title
        'Rescue the civilians before the Monkeylord spawns.',  -- description
        {                               -- target
            Timer = secondsUntilMonkeylord,
            ExpireResult = 'failed',
        }
    )
    ScenarioInfo.M2S2:AddResultCallback(
        function(result)
            LOG('*DEBUG: M2S2')
            if (not result) then
                SpawnMonkeyLord()
            end
        end
    )
    table.insert(AssignedObjectives, ScenarioInfo.M2S2)
end

function planPrematureMonkeyLord()
    if ScenarioInfo.NumberOfPlayers >= 3 then
        TCRUtil.CreateMultipleAreaTrigger(prematureMonkeylord, {'M2_Forward_Defenses_1', 'M2_Forward_Defenses_2'} , categories.DEFENSE * categories.CYBRAN - categories.WALL, true, true, 0)
    end
end

function prematureMonkeylord()
    local secondsUntilMonkeylord = M2SpawnMonkeylordTime[Difficulty] - math.floor(GetGameTimeSeconds())
    if ScenarioInfo.hasMonkeylordSpawned or secondsUntilMonkeylord < prematureMonkeylordPreparationTime + 1 then
        return
    end
    
    ScenarioFramework.Dialogue(OpStrings.M2_Scared_Cybran, nil, true)
    if ScenarioInfo.M2S2 then
        ScenarioInfo.M2S2:ManualResult(true)
    end
    
    ------------------------------------------------------------------------------
    -- Secondary Objective 2.1 - Complete Primary Objectives before spawn Monkeylord
    ------------------------------------------------------------------------------
    secondsUntilMonkeylord = M2SpawnMonkeylordTime[Difficulty] - math.floor(GetGameTimeSeconds())
    ScenarioInfo.M2S2_1 = Objectives.Timer(
        'secondary',                      -- type
        'incomplete',                   -- complete
        'Beware of the Monkeylord!',                 -- title
        'Rescue the civilians before the Monkeylord spawns.',  -- description
        {                               -- target
            Timer = prematureMonkeylordPreparationTime,
            ExpireResult = 'failed',
        }
    )
    ScenarioInfo.M2S2_1:AddResultCallback(
        function(result)
            LOG('*DEBUG: M2S2_1')
            if (not result) then
                SpawnMonkeyLord()
            end
        end
    )
    table.insert(AssignedObjectives, ScenarioInfo.M2S2_1)
end

function SpawnMonkeyLord()
    if (not ScenarioInfo.hasMonkeylordSpawned) then
        SpawnExperimental()
    end
end
    
function SpawnExperimental()
    LOG('*DEBUG: SpawnExperimentals')
    if (not ScenarioInfo.hasMonkeylordSpawned) then
        ScenarioInfo.hasMonkeylordSpawned = true
        ScenarioFramework.Dialogue(OpStrings.M2_Monkeylord_Is_Coming, nil, true)
        M2CybranManual.DropExperimental(KilledExperimentals)
    else
        if (math.floor(GetGameTimeSeconds()) > (M2SpawnMonkeylordTime[Difficulty] + M2SpawnExperimentalsTime[Difficulty] - 60)) then
            --Don't allow spawning of experimentals before the first megalith can spawn.
            ScenarioFramework.Dialogue(OpStrings.M2_Time_Is_Up, nil, true)
            M2CybranManual.DropExperimental(KilledExperimentals)
        end
    end
end

function KilledExperimentals()
    --Check if all experimentals are dead
    local exps = TCRUtil.GetAllCatUnitsInArea(categories.EXPERIMENTAL, 'M2_Area')
    for _,unit in exps do
        if not unit:IsDead() then
            return
        end
    end
    
    ForkThread(M2CybranManual.AfterExperimentalDrops)
    ForkThread(M2CybranManual.SnipeACUs)
    
    killedExp = killedExp + 1 
    if killedExp <= 2 then
        ScenarioFramework.Dialogue(OpStrings.M2_Experimental_Destroyed, nil, true)
    else
        ScenarioFramework.Dialogue(OpStrings.M2_Experimentals_Destroyed, nil, true)
    end
    
    --Make new TimerObjective for next wave of experimentals
    secondsUntilExperimentals = M2SpawnExperimentalsTime[Difficulty] + math.max( 0, M2SpawnMonkeylordTime[Difficulty] - math.floor(GetGameTimeSeconds()))
    ScenarioInfo.M2SX = Objectives.Timer(
        'secondary',                      -- type
        'incomplete',                   -- complete
        'Beware of the Experimentals!',                 -- title
        'Rescue the civilians before the Experimentals spawn.',  -- description
        {                               -- target
            Timer = secondsUntilExperimentals,
            ExpireResult = 'failed',
        }
    )
    ScenarioInfo.M2SX:AddResultCallback(
        function(result)
            LOG('*DEBUG: M2SX')
            if (not result) then
                SpawnExperimental()
            end
        end
    )
    table.insert(AssignedObjectives, ScenarioInfo.M2SX)
end

-----------
-- End Game
-----------
function PlayerWin()
    if(not ScenarioInfo.OpEnded) then
        ScenarioInfo.OpComplete = true
        makeCDRImmortal()
        ScenarioFramework.CDRDeathNISCamera(ScenarioInfo.PlayerCDR)
        ScenarioFramework.Dialogue(OpStrings.PlayerWin, KillGame, true)
    end
end

function makeCDRImmortal()
    local units = TCRUtil.GetAllCatUnitsInArea(categories.COMMAND, 'M2_Area')
    for _,cdr in units do
        cdr:SetCanTakeDamage(false)
        cdr:SetCanBeKilled(false)
    end
end

function PlayerDeath(player)
    if(not ScenarioInfo.OpEnded) then
        ScenarioFramework.CDRDeathNISCamera(player)
        ScenarioFramework.EndOperationSafety()
        ScenarioInfo.OpComplete = false
        for k, v in AssignedObjectives do
            if(v and v.Active) then
                v:ManualResult(false)
            end
        end
        ForkThread(
            function()
                WaitSeconds(3)
                UnlockInput()
                KillGame()
            end
        )
    end
end

function KillGame()
    UnlockInput()
    
    local allPrimaryCompleted = true
    local allSecondaryCompleted = true
    
    for _, v in AssignedObjectives do
        if (v == ScenarioInfo.M1P1 or v == ScenarioInfo.M2P1) then
            allPrimaryCompleted = allPrimaryCompleted and v.Complete
        else
            allSecondaryCompleted = allSecondaryCompleted and v.Complete
        end
    end
    
    ScenarioFramework.EndOperation(ScenarioInfo.OpComplete, allPrimaryCompleted, allSecondaryCompleted)
end