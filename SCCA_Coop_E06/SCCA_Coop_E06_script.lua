-- ****************************************************************************
-- **
-- **  File     :  /maps/SCCA_Coop_E06/SCCA_Coop_E06_v01_script.lua
-- **  Author(s):  Drew Staltman
-- **
-- **  Summary  : Main mission flow script for SCCA_Coop_E06
-- **
-- **  Copyright ÃÂ© 2005 Gas Powered Games, Inc.  All rights reserved.
-- ****************************************************************************
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local Objectives = ScenarioFramework.Objectives
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local AIBuildStructures = import('/lua/ai/aibuildstructures.lua')
local OpStrings = import('/maps/SCCA_Coop_E06/SCCA_Coop_E06_v01_Strings.lua')
local ScenarioStrings = import('/lua/scenariostrings.lua')
local Utilities = import('/lua/utilities.lua')
local Cinematics = import('/lua/cinematics.lua')
-- local BaseManager = import('/lua/ai/opai/basemanager.lua')



-- === GLOBAL VARIABLES === #
ScenarioInfo.Player = 1
ScenarioInfo.BlackSun = 2
ScenarioInfo.Aeon = 3
ScenarioInfo.Cybran = 4
ScenarioInfo.Component = 5
ScenarioInfo.Coop1 = 6
ScenarioInfo.Coop2 = 7
ScenarioInfo.Coop3 = 8
ScenarioInfo.HumanPlayers = {ScenarioInfo.Player}
-- === LOCAL VARIABLES === #
local Player = ScenarioInfo.Player
local Coop1 = ScenarioInfo.Coop1
local Coop2 = ScenarioInfo.Coop2
local Coop3 = ScenarioInfo.Coop3
local BlackSun = ScenarioInfo.BlackSun
local Aeon = ScenarioInfo.Aeon
local Cybran = ScenarioInfo.Cybran
local Component = ScenarioInfo.Component


local M1B1EnemiesKilled = 500
local M1B2ExperimentalNeeded = 5

-- === TUNING VARIABLES === #

-- ! MISSION ONE VARIABLES
-- Delay before mentioning the transports to the player
local M1FirstTransportPrepTimer = 10

-- Delay before giving the player the component
local M1ComponentSightedTimer = 15

-- Delay after all transports have landed that mission completes
local M1EndMission1Delay = 15

-- M1 Objective reminder
local M1ObjectiveReminderTimer = 300

-- Number of Cybran Transports to build
ScenarioInfo.VarTable['CybranT2TransportCount_D1'] = 12
ScenarioInfo.VarTable['CybranT2TransportCount_D2'] = 18
ScenarioInfo.VarTable['CybranT2TransportCount_D3'] = 18


-- ! MISSION TWO VARIABLES

-- Delay after mission completes that 2nd mission starts
local M2StartMission2Delay = 10

-- Delay after M2 has begun that the player is informed of the Aeon Base
local M2AeonBaseDialogueTimer = 15

-- Time after Spider Bots are sent that the capture transports will be sent
local M2CybranCaptureTimer = 600

-- Timer after M2 Starts that a nuke is launched at the player base
local M2AeonNukeTimer = 120

-- Timer after M2 starts that the Aeon build artillery
local M2AeonArtilleryTimer = 720

-- Timer to repeat sending out the capture groups as long as spider are around
local M2CybranCaptureRepeatTimer = 300

-- Timer to send more air units with the spider bots attack
local M2CybranSpiderAirTimer = 180

-- Timer to nuke again in M2
local M2AeonNukeClumpTimer = 300

-- Timer to play objective reminders
local M2ObjectiveReminderTimer = 300

-- Timer to delay giving units to player
local M2TransferUnitDelay = 10



-- ! MISSION THREE VARIABLES

-- Timer for each segment of the final duration countdown: There are 20 segments
local M3ChargeTimerSegmentDuration = 90

-- Delay after 10 minutes to begin wave 2
local M3AttackTwoDelay = 67

-- Delay after 20 minutes to begin wave 3
local M3AttackThreeDelay = 43

-- Delay for M3 Reminders
local M3ObjectiveReminderTimer = 300

-- Timers for spacing between clump nuking for le fun
ScenarioInfo.VarTable['M3NukeClumpTimer_D1'] = 480
ScenarioInfo.VarTable['M3NukeClumpTimer_D2'] = 300
ScenarioInfo.VarTable['M3NukeClumpTimer_D3'] = 150


function CheatEconomy()
    ArmyBrains[Cybran]:GiveStorage('MASS', 500000)
    ArmyBrains[Cybran]:GiveStorage('ENERGY', 500000)
    ArmyBrains[Aeon]:GiveStorage('MASS', 500000)
    ArmyBrains[Aeon]:GiveStorage('ENERGY', 500000)
    while(true) do
        ArmyBrains[Cybran]:GiveResource('MASS', 500000)
        ArmyBrains[Cybran]:GiveResource('ENERGY', 500000)
		ArmyBrains[Aeon]:GiveResource('MASS', 500000)
		ArmyBrains[Aeon]:GiveResource('ENERGY', 500000)
		WaitSeconds(.5)
    end
end


function OnPopulate(scen)
    ScenarioUtils.InitializeScenarioArmies()
    ScenarioFramework.fillCoop()

    factionIdx = GetArmyBrain('Player'):GetFactionIndex()
    if(factionIdx == 1) then
        Faction = "uef"
    elseif(factionIdx == 2) then
        Faction = "aeon"
    else 
        Faction = "cybran"
    end

    ScenarioFramework.SetUEFColor(Player)
    ScenarioFramework.SetUEFAllyColor(BlackSun)
    ScenarioFramework.SetUEFAllyColor(Component)
    ScenarioFramework.SetCybranColor(Cybran)
    ScenarioFramework.SetAeonColor(Aeon)

    for i = 2, table.getn(ArmyBrains) do
        if i < ScenarioInfo.Coop1 then
            SetArmyShowScore(i, false)
            SetIgnorePlayableRect(i, true)
        end
    end

    for i=2,table.getn(ArmyBrains) do
    end

    -- Player Army
    ScenarioUtils.CreateArmyGroup('Player', 'Naval_Base')
    ScenarioUtils.CreateArmyGroup('Player', 'Black_Sun_Defenses')
    ScenarioUtils.CreateArmyGroup('Player', 'West_Factory_Group')
    ScenarioUtils.CreateArmyGroup('Player', 'Northern_Walls')
    ScenarioUtils.CreateArmyGroup('Player', 'East_Factory_Group')
    ScenarioUtils.CreateArmyGroup('Player', 'Middle_Power_Group')
    ScenarioUtils.CreateArmyGroup('Player', 'Mass_Extractors')
    ScenarioUtils.CreateArmyGroup('Player', 'Central_Structures')
    ScenarioUtils.CreateArmyGroup('Player', 'Control_Center_Defenses')
    ScenarioUtils.CreateArmyGroup('Player', 'NukeMeClumps')
    ScenarioUtils.CreateArmyGroup('Player', 'SW_Energy')
    ScenarioUtils.CreateArmyGroup('Player', 'Starting_Navy')
    ScenarioUtils.CreateArmyGroup('Player', 'West_Naval_Defenses')
    ScenarioInfo.AikoUnit = ScenarioUtils.CreateArmyUnit('Player', 'Aiko')
    ScenarioInfo.AikoUnit:SetCustomName(LOC '{i sCDR_Aiko}')
    ScenarioFramework.CreateUnitDestroyedTrigger(AikoDestroyed, ScenarioInfo.AikoUnit)
    local group = ScenarioUtils.CreateArmyGroup('Player', 'Starting_Air_1')
    ScenarioFramework.GroupPatrolChain(group, 'Player_Base_Patrol_Chain')
    local group = ScenarioUtils.CreateArmyGroup('Player', 'Starting_Air_2')
    ScenarioFramework.GroupPatrolChain(group, 'Player_Base_Patrol_Chain')
    local group = ScenarioUtils.CreateArmyGroup('Player', 'Starting_Air_North')
    ScenarioFramework.GroupPatrolChain(group, 'Player_North_Patrol_Chain')

    -- Give Player Anti-Nukes
    for num,unit in ArmyBrains[Player]:GetListOfUnits(categories.ueb4302, false) do
        unit:GiveTacticalSiloAmmo(2)
    end


    -- Base markers
    ArmyBrains[Aeon]:PBMRemoveBuildLocation(nil, 'MAIN')
    ArmyBrains[Aeon]:PBMAddBuildLocation('Aeon_M2_Base', 120, 'AeonM2Base')
    ArmyBrains[Aeon]:PBMAddBuildLocation('Aeon_Arnold_Base', 120, 'AeonArnoldBase')
    ArmyBrains[Aeon]:PBMAddBuildLocation('Aeon_M3_SW_Base', 120, 'AeonM3Base')

    ArmyBrains[Cybran]:PBMRemoveBuildLocation(nil, 'MAIN')
    ArmyBrains[Cybran]:PBMAddBuildLocation(ScenarioUtils.MarkerToPosition('Cybran_Base'), 75, 'CybranBase')
    ArmyBrains[Cybran]:PBMAddBuildLocation(ScenarioUtils.MarkerToPosition('Cybran_Naval_Base'), 75, 'CybranNaval')

    -- Base Templates
    AIBuildStructures.CreateBuildingTemplate(ArmyBrains[Aeon], 'Aeon', 'M3_Arnold_Base')
    AIBuildStructures.AppendBuildingTemplate(ArmyBrains[Aeon], 'Aeon', 'M3_Arnold_Base_D'..ScenarioInfo.Options.Difficulty, 'M3_Arnold_Base')

    AIBuildStructures.CreateBuildingTemplate(ArmyBrains[Aeon], 'Aeon', 'M3_SW_Base')
    AIBuildStructures.AppendBuildingTemplate(ArmyBrains[Aeon], 'Aeon', 'M3_SW_Base_D'..ScenarioInfo.Options.Difficulty, 'M3_SW_Base')

    AIBuildStructures.CreateBuildingTemplate(ArmyBrains[Aeon], 'Aeon', 'M2_Base')
    AIBuildStructures.AppendBuildingTemplate(ArmyBrains[Aeon], 'Aeon', 'M2_Base_D'..ScenarioInfo.Options.Difficulty, 'M2_Base')

    AIBuildStructures.CreateBuildingTemplate(ArmyBrains[Aeon], 'Aeon', 'M3_Forward_Base')
    AIBuildStructures.AppendBuildingTemplate(ArmyBrains[Aeon], 'Aeon', 'M3_Forward_Base_D'..ScenarioInfo.Options.Difficulty, 'M3_Forward_Base')

    AIBuildStructures.CreateBuildingTemplate(ArmyBrains[Cybran], 'Cybran', 'M2_Base')
    AIBuildStructures.AppendBuildingTemplate(ArmyBrains[Cybran], 'Cybran', 'M2_Base_D'..ScenarioInfo.Options.Difficulty, 'M2_Base')

    AIBuildStructures.CreateBuildingTemplate(ArmyBrains[Cybran], 'Cybran', 'M3_Forward_Base')
    AIBuildStructures.AppendBuildingTemplate(ArmyBrains[Cybran], 'Cybran', 'M3_Forward_Base_D'..ScenarioInfo.Options.Difficulty, 'M3_Forward_Base')

    -- Black_Sun
    ScenarioInfo.BlackSunControlCenter = ScenarioUtils.CreateArmyUnit('Black_Sun', 'Black_Sun_Control_Center')
    ScenarioInfo.BlackSunControlCenter:SetCanBeKilled(false)
    ScenarioInfo.BlackSunControlCenter:SetCanTakeDamage(false)
    ScenarioInfo.BlackSunControlCenter:SetReclaimable(false)
    ScenarioInfo.BlackSunControlCenter:SetDoNotTarget(true)
    ScenarioInfo.BlackSunControlCenter:SetCustomName(LOC '{i BlackSunControlTower}')
    ScenarioFramework.CreateUnitCapturedTrigger(false,M2BlackSunControlCenterCaptured,ScenarioInfo.BlackSunControlCenter)

    ScenarioInfo.BlackSunCannon = ScenarioUtils.CreateArmyGroup('Player', 'Cannon')
    for k,v in ScenarioInfo.BlackSunCannon do
        v:SetCustomName(LOC '{i BlackSunCannon}')
        v:SetReclaimable(false)
        v:SetCapturable(false)
        v:RemoveToggleCap('RULEUTC_SpecialToggle')
        ScenarioFramework.CreateUnitDestroyedTrigger(BlackSunCannonDestroyed, v)
    end
    local supportBuildings = ScenarioUtils.CreateArmyGroup('Black_Sun', 'Black_Sun_Support')
    for k,v in supportBuildings do
        v:SetUnSelectable(true)
        v:SetCanTakeDamage(false)
        v:SetCanBeKilled(false)
    end

    -- Aeon
    ScenarioUtils.CreateArmyGroup('Aeon', 'M2_Base_D' .. ScenarioInfo.Options.Difficulty)
    local plat = ScenarioUtils.CreateArmyGroupAsPlatoonCoopBalanced('Aeon', 'M2_Base_Engineers_D'..ScenarioInfo.Options.Difficulty, 'AttackFormation')
    plat.PlatoonData.MaintainBaseTemplate = 'M2_Base'
    plat.PlatoonData.AssistFactories = true
    plat.PlatoonData.LocationType = 'AeonM2Base'
    plat:ForkAIThread(ScenarioPlatoonAI.StartBaseEngineerThread)

    -- Cybran
    ScenarioUtils.CreateArmyGroup('Cybran', 'M2_Base_D' .. ScenarioInfo.Options.Difficulty)
    local engPlatoon = ScenarioUtils.CreateArmyGroupAsPlatoonCoopBalanced('Cybran', 'M2_Engineer_Platoon_D' .. ScenarioInfo.Options.Difficulty, 'AttackFormation')
    engPlatoon.PlatoonData.AssistFactories = true
    engPlatoon.PlatoonData.LocationType = 'CybranBase'
    engPlatoon:ForkAIThread(ScenarioPlatoonAI.StartBaseEngineerThread)
    local navalEngPlatoon = ScenarioUtils.CreateArmyGroupAsPlatoonCoopBalanced('Cybran', 'M2_Naval_Engineer_Platoon_D'..ScenarioInfo.Options.Difficulty, 'AttackFormation')
    navalEngPlatoon.PlatoonData.AssistFactories = true
    navalEngPlatoon.PlatoonData.LocationType = 'CybranNaval'
    navalEngPlatoon:ForkAIThread(ScenarioPlatoonAI.StartBaseEngineerThread)
    ScenarioInfo.VarTable['CybranT2TransportCount'] = ScenarioInfo.VarTable['CybranT2TransportCount_D'..ScenarioInfo.Options.Difficulty]


    -- Fill Cybran Nuke Launchers
    for num,unit in ArmyBrains[Cybran]:GetListOfUnits(categories.urb2305, false) do
        unit:GiveNukeSiloAmmo(5)
    end



    -- Bonus Objectives
-- ScenarioFramework.CreateArmyStatTrigger(BPlayerBuiltExperimentals, ArmyBrains[Player], 'BonusExperimentalCounter', {
--                                            { StatType = 'Units_History', CompareType = 'GreaterThanOrEqual', Value = M1B2ExperimentalNeeded, Category = categories.EXPERIMENTAL, },
--                                        }
--                                   )
-- ScenarioFramework.CreateArmyStatTrigger(BPlayerKill500Enemy, ArmyBrains[Player], 'BonusPlayerKillCount', {
--                                            { StatType = 'Enemies_Killed', CompareType = 'GreaterThanOrEqual', Value = M1B1EnemiesKilled, Category = categories.ALLUNITS - categories.WALL, },
--                                        }
--                                   )

    -- Buildable Categories
        -- Restrictions
    for _, player in ScenarioInfo.HumanPlayers do
         ScenarioFramework.AddRestriction(player, categories.EXPERIMENTAL +
                                      categories.ueb2302 +
                                      categories.ueb4301 +
                                      categories.ues0304 )
    end
        -- Allowed
    for _, player in ScenarioInfo.HumanPlayers do
         ScenarioFramework.RemoveRestriction(player, categories.ues0401)
    end

    -- NIS Units
        -- Components
    ScenarioInfo.DeathTransport = ScenarioUtils.CreateArmyUnit('Black_Sun', 'Death_Transport_Unit')
    ScenarioInfo.DeathTransport:SetCanBeKilled(false)
    ScenarioInfo.InvincibleTransports = ScenarioUtils.CreateArmyGroupAsPlatoon('Black_Sun', 'Invincible_Transports', 'ChevronFormation')
    ScenarioInfo.InvincibleComponents = ScenarioUtils.CreateArmyGroup('Black_Sun', 'Extra_Components')
    for num,unit in ScenarioInfo.InvincibleComponents do
        unit:SetCanTakeDamage(false)
        unit:SetCanBeKilled(false)
        unit:SetDoNotTarget(true)
        unit:SetReclaimable(false)
        unit:SetCapturable(false)
    end
    for num,unit in ScenarioInfo.InvincibleTransports:GetPlatoonUnits() do
        unit:SetCanTakeDamage(false)
        unit:SetCanBeKilled(false)
        unit:SetDoNotTarget(true)
    end
    ScenarioInfo.BlackSunEscorts = ScenarioUtils.CreateArmyGroup('Black_Sun', 'Escorts')

    ScenarioInfo.BlackSunComponent = ScenarioUtils.CreateArmyUnit('Component', 'Black_Sun_Component_Unit')
        -- Aeon
    ScenarioInfo.AeonIntroAirPlatoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'Air_Group_Intro', 'ChevronFormation')
    ScenarioInfo.AeonIntroNavalPlatoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'Naval_Group_Intro', 'AttackFormation')
end

function OnStart(scen)
    ScenarioFramework.SetPlayableArea('M1_Playable_Area', false)
    ForkThread(IntroCameras)
end

function IntroCameras()
    Cinematics.EnterNISMode()
    WaitSeconds(.25)
    ForkThread(CreatePlayer)
    Cinematics.CameraMoveToRectangle(ScenarioUtils.AreaToRect('Start_Camera_Area'), 4)
    WaitSeconds(5)
    Cinematics.CameraMoveToRectangle(ScenarioUtils.AreaToRect('M1_Playable_PreArea'), 1.3) -- 1.3
    -- Cinematics.CameraMoveToRectangle(ScenarioUtils.AreaToRect('M1_Playable_Area'), .55)
    Cinematics.ExitNISMode()
end

function CreatePlayer()
    WaitSeconds(2.5)
    ScenarioInfo.PlayerCDR = ScenarioUtils.CreateArmyUnit('Player', 'Player_CDR')
    ScenarioInfo.PlayerCDR:PlayCommanderWarpInEffect()

    -- spawn coop players too
    ScenarioInfo.CoopCDR = {}
    local tblArmy = ListArmies()
    coop = 1
    for iArmy, strArmy in pairs(tblArmy) do
        if iArmy >= ScenarioInfo.Coop1 then
            ScenarioInfo.CoopCDR[coop] = ScenarioUtils.CreateArmyUnit(strArmy, 'Player_CDR')
            ScenarioInfo.CoopCDR[coop]:PlayCommanderWarpInEffect()
            coop = coop + 1
            WaitSeconds(0.5)
        end
    end

    ScenarioFramework.CreateUnitDeathTrigger(PlayerCommanderDestroyed, ScenarioInfo.PlayerCDR)
    ScenarioFramework.PauseUnitDeath(ScenarioInfo.PlayerCDR)

    for index, coopACU in ScenarioInfo.CoopCDR do
        ScenarioFramework.PauseUnitDeath(coopACU)
        ScenarioFramework.CreateUnitDeathTrigger(PlayerCommanderDestroyed, coopACU)
    end
    WaitSeconds(1.5)
    IntroNIS()
    WaitSeconds(3)
    -- Opening dialogue
    ScenarioFramework.Dialogue(OpStrings.E06_M01_005)
end

function RedFogTaunt()
    ScenarioFramework.Dialogue(OpStrings['TAUNT' .. Random(1,8)])
end

function ArnoldTaunt()
    SenarioFramework.Dialogue(OpStrings['TAUNT' .. Random(9,16)])
end

function PlayTaunt()
    ScenarioFramework.Dialogue(OpStrings['TAUNT' .. Random(1,16)])
end





-- === INTRO NIS === #
function IntroNIS()
    -- Attach units to transports
    ScenarioFramework.AttachUnitsToTransports({ScenarioInfo.BlackSunComponent}, {ScenarioInfo.DeathTransport})

    -- Move Transports to Blacksun
    for num,unit in ScenarioInfo.InvincibleTransports:GetPlatoonUnits() do
        ScenarioFramework.AttachUnitsToTransports({ScenarioInfo.InvincibleComponents[num]}, {unit})
    end
    ArmyBrains[Component]:AssignUnitsToPlatoon(ScenarioInfo.InvincibleTransports, {ScenarioInfo.DeathTransport}, 'Attack', 'ChevronFormation')
    local unloadCmd = ScenarioInfo.InvincibleTransports:UnloadAllAtLocation(ScenarioUtils.MarkerToPosition('M1_Transport_Unload'))

    local newGroup = {}
    for k,v in ScenarioInfo.BlackSunEscorts do
        table.insert(newGroup, ScenarioFramework.GiveUnitToArmy(v, Player))
    end
    ForkThread(MoveEscorts, newGroup)
    -- ScenarioInfo.BlackSunEscorts:Patrol(ScenarioUtils.MarkerToPosition('INTRO_West_Island_Marker'))
    -- ScenarioInfo.BlackSunEscorts:Patrol(ScenarioUtils.MarkerToPosition('Player_Attack_Black_Sun'))

    ScenarioInfo.AeonIntroAirPlatoon:Patrol(ScenarioUtils.MarkerToPosition('INTRO_West_Island_Marker'))
    ScenarioInfo.AeonIntroAirPlatoon:Patrol(ScenarioUtils.MarkerToPosition('Player_Attack_Black_Sun'))

    -- Check if the transport is in range to die
    ScenarioFramework.CreateUnitToMarkerDistanceTrigger(IntroKillTransport, ScenarioInfo.DeathTransport, 'INTRO_Island_Death_Marker', 12)
    ForkThread(MoveComponents, unloadCmd)
	
	ForkThread(CheatEconomy)
end

function MoveEscorts(group)
    WaitSeconds(3)
    IssuePatrol(group, ScenarioUtils.MarkerToPosition('INTRO_West_Island_Marker'))
    IssuePatrol(group, ScenarioUtils.MarkerToPosition('Player_Attack_Black_Sun'))
end


function MoveComponents(unloadCmd)
    while ScenarioInfo.InvincibleTransports:IsCommandsActive(unloadCmd) do
        WaitSeconds(2)
    end
    for num,unit in ScenarioInfo.InvincibleTransports:GetPlatoonUnits() do
		if unit then
			unit:SetCanTakeDamage(true)
			unit:SetCanBeKilled(true)
			if not unit:IsDead() then
				ScenarioFramework.GiveUnitToArmy(unit, Player)
			end
		end
    end
    for k,v in ScenarioInfo.InvincibleComponents do
        IssueMove({v}, ScenarioUtils.MarkerToPosition('Component_Move_Marker_'..k))
    end
end

function IntroKillTransport(unit)
    unit:SetCanBeKilled(true)

    -- Transport dying camera
    local camInfo = {
        blendTime = 1.0,
        holdTime = 7,
        orientationOffset = { 2.6, 0.9, 0 },
        positionOffset = { -7, 0.5, 0 },
        zoomVal = 45,
        vizRadius = 25,
        markerCam = true,
    }
    ScenarioFramework.OperationNISCamera(ScenarioUtils.MarkerToPosition("INTRO_Component_Move"), camInfo)

    unit:Kill()
    ScenarioInfo.BlackSunComponent:Destroy()
    -- ForkThread(IntroMoveFallenComponent)
    StartMission1()
end






-- === MISSION ONE FUNCTIONS === #
function StartMission1()

    -- Begin scenario Scripting
    ScenarioFramework.Dialogue(OpStrings.E06_M01_010)
    ScenarioFramework.Dialogue(OpStrings.E06_M01_020)
    ScenarioInfo.MissionNumber = 1
    ScenarioFramework.CreateTimerTrigger(M1ObjectiveReminder, M1ObjectiveReminderTimer)
    ScenarioFramework.CreateTimerTrigger(ComponentSighted, M1ComponentSightedTimer)
    ScenarioInfo.M1P1Obj = Objectives.Protect('primary', 'incomplete', OpStrings.M1P1Title, OpStrings.M1P1Description,
        { Units = ScenarioInfo.BlackSunCannon }
   )
end

function ComponentSighted()
    if not ScenarioInfo.M1PlayerSightedComponent then
        ScenarioInfo.M1PlayerSightedComponent = true
        if not ScenarioInfo.AikoUnitDestroyed and ScenarioInfo.AikoUnit:GetHealthPercent() >= .5 then
            ScenarioFramework.Dialogue(OpStrings.E06_M01_030)
        else
            ScenarioFramework.Dialogue(OpStrings.E06_M01_035)
        end
        ForkThread(ComponentSightedThread)
    end
end

function ComponentSightedThread()
    ScenarioInfo.ComponentAreaTrigger = ScenarioFramework.CreateAreaTrigger(CheckComponent, 'Black_Sun_Component_Area', categories.ope6003, false, false, ArmyBrains[Player])
-- ScenarioInfo.BlackSunComponent = ScenarioFramework.GiveUnitToArmy(ScenarioInfo.BlackSunComponent, Player)
-- #WaitTicks(1)
-- ScenarioInfo.BlackSunComponent:SetCanTakeDamage(false)
-- ScenarioInfo.BlackSunComponent:SetCanBeKilled(false)
-- ScenarioInfo.BlackSunComponent:SetReclaimable(false)
-- ScenarioInfo.BlackSunComponent:SetCapturable(false)

    -- if ScenarioInfo.BlackSunComponent:IsDead() then
    -- LOG('*DEBUG: Component was dead')
    ScenarioInfo.BlackSunComponent = ScenarioUtils.CreateArmyUnit('Component', 'Black_Sun_Component_Unit')
    ScenarioInfo.BlackSunComponent = ScenarioFramework.GiveUnitToArmy(ScenarioInfo.BlackSunComponent, Player)
    Warp(ScenarioInfo.BlackSunComponent, ScenarioUtils.MarkerToPosition('INTRO_Component_Move'))
    ScenarioInfo.BlackSunComponent:SetCanTakeDamage(false)
    ScenarioInfo.BlackSunComponent:SetCanBeKilled(false)
    ScenarioInfo.BlackSunComponent:SetReclaimable(false)
    ScenarioInfo.BlackSunComponent:SetCapturable(false)
    -- end

    ScenarioInfo.M1P2Obj = Objectives.Basic('primary', 'incomplete', OpStrings.M1P2Title, OpStrings.M1P2Description,
        Objectives.GetActionIcon('move'),
        {
            Units = {ScenarioInfo.BlackSunComponent},
            Area = 'Black_Sun_Component_Area',
            MarkArea = true,
            MarkUnits = true,
        }
   )

    while ScenarioInfo.MissionNumber == 1 do
        local parent
        while ScenarioInfo.MissionNumber == 1 and not ScenarioInfo.BlackSunComponent:BeenDestroyed() and not ScenarioInfo.BlackSunComponent:IsUnitState('Attached') do
            WaitSeconds(2)
        end

        if not ScenarioInfo.BlackSunComponent:BeenDestroyed() then
            parent = ScenarioInfo.BlackSunComponent:GetParent()
            if parent and IsUnit(parent) then
                parent:SetCanTakeDamage(false)
                parent:SetCanBeKilled(false)

                while not ScenarioInfo.BlackSunComponent:BeenDestroyed() and ScenarioInfo.BlackSunComponent:IsUnitState('Attached') do
                    WaitSeconds(2)
                end

                parent:SetCanTakeDamage(true)
                parent:SetCanBeKilled(true)
            end
        end
        WaitSeconds(1)
    end
end

function CheckComponent(unit)
    if unit == ScenarioInfo.BlackSunComponent and not unit:IsUnitState('Attached') then
        ForkThread(ComponentAtBlackSun)
        local newUnit = ScenarioFramework.GiveUnitToArmy(unit, BlackSun)
-- component reaches blacksun cam
        local camInfo = {
            blendTime = 1.0,
            holdTime = 4,
            orientationOffset = { 0, 0.3, 0 },
            positionOffset = { 0, 0.5, 0 },
            zoomVal = 35,
        }
        ScenarioFramework.OperationNISCamera(newUnit, camInfo)

        WaitTicks(1)
        IssueMove({newUnit}, ScenarioUtils.MarkerToPosition('Component_Move_Marker_1'))
--    local moveDelay = ((camInfo.blendTime + camInfo.holdTime) * 10) + 1
--    WaitTicks(moveDelay)

        ScenarioInfo.ComponentAreaTrigger:Destroy()
    end
end

function ComponentAtBlackSun()
    ScenarioInfo.M1P2Obj:ManualResult(true)
    ScenarioFramework.Dialogue(ScenarioStrings.PObjComp)
    EndMission1()
end

-- function BPlayerBuiltExperimentals()
-- ScenarioInfo.ExperimentalBonus = Objectives.Basic('bonus', 'complete', OpStrings.M1B2Title, LOCF(OpStrings.M1B2Description,M1B2ExperimentalNeeded))
-- ScenarioInfo.ExperimentalBonus:ManualResult(true)
-- ScenarioFramework.Dialogue(ScenarioStrings.BObjComp)
-- end

-- function BPlayerKill500Enemy()
-- ScenarioInfo.KillBonus = Objectives.Basic('bonus', 'complete', OpStrings.M1B1Title, LOCF(OpStrings.M1B1Description,M1B1EnemiesKilled))
-- ScenarioInfo.KillBonus:ManualResult(true)
-- ScenarioFramework.Dialogue(ScenarioStrings.BObjComp)
-- end

function M1ObjectiveReminder()
    if ScenarioInfo.MissionNumber == 1 then
        if Random(1,2) == 1 then
            ScenarioFramework.Dialogue(OpStrings.E06_M01_060)
        else
            ScenarioFramework.Dialogue(OpStrings.E06_M01_065)
        end
        ScenarioFramework.CreateTimerTrigger(M1ObjectiveReminder, M1ObjectiveReminderTimer)
    end
end

function EndMission1()
    ScenarioInfo.MissionNumer = 0
    ScenarioFramework.Dialogue(ScenarioStrings.MissionSuccessDialogue)
    WaitSeconds(M1EndMission1Delay)
    ScenarioFramework.Dialogue(OpStrings.E06_M01_050)
    WaitSeconds(M2StartMission2Delay)
    StartMission2()
end









-- === MISSION 2 FUNCTIONS === #
function StartMission2()
    -- Set MissionNumber, Set Objectives, Play Dialogue, Set Area
    ScenarioInfo.MissionNumber = 2
    ScenarioFramework.SetPlayableArea('M2_Playable_Area_1')
    ScenarioFramework.Dialogue(ScenarioStrings.MapExpansion)
    if not ScenarioInfo.AikoUnitDestroyed then
        ScenarioFramework.Dialogue(OpStrings.E06_M02_010)
    else
        ScenarioFramework.Dialogue(OpStrings.E06_M02_015)
    end
    ScenarioFramework.Dialogue(OpStrings.E06_M02_020)

    -- Allowed restrictions
    for _, player in ScenarioInfo.HumanPlayers do
         ScenarioFramework.RemoveRestriction(player, categories.ueb2302 +
                                         categories.ueb4301 +
                                         categories.uel0401 +
                                         categories.ues0304 )
    end


    -- Create Aeon base and death trigger for the base
    ScenarioUtils.CreateArmyGroup('Aeon', 'M2_Base_Defenses_D'..ScenarioInfo.Options.Difficulty)
    ScenarioUtils.CreateArmyGroup('Aeon', 'M2_Base_Tactical_Missiles_D'..ScenarioInfo.Options.Difficulty)
    AIBuildStructures.AppendBuildingTemplate(ArmyBrains[Aeon], 'Aeon', 'M3_SW_Base_Defenses_D'..ScenarioInfo.Options.Difficulty, 'M2_Base')
    ScenarioFramework.CreateAreaTrigger(M2AeonBaseDefeated, ScenarioUtils.AreaToRect('M2_Aeon_Base_Area'),
                                        categories.STRUCTURE - categories.WALL, true, true, ArmyBrains[Aeon])
    local aeonCDR = ScenarioUtils.CreateArmyGroup('Aeon', 'M2_Commander')
    ScenarioFramework.GroupPatrolChain(aeonCDR, 'Aeon_M2_CDR_Patrol_Chain')
    ScenarioFramework.CreateUnitDestroyedTrigger(M2AeonCDRDestroyed, aeonCDR[1])
    aeonCDR[1]:CreateEnhancement('Shield')
    aeonCDR[1]:CreateEnhancement('CrysalisBeam')

    -- Timers for further Dialogue
    ScenarioFramework.CreateTimerTrigger(M2AeonBaseDialogue, M2AeonBaseDialogueTimer)

    -- Fill Aeon anti-nukes
    for num,unit in ArmyBrains[Aeon]:GetListOfUnits(categories.uab4302, false) do
        unit:GiveTacticalSiloAmmo(3)
    end
    for num,unit in ArmyBrains[Aeon]:GetListOfUnits(categories.uab2305, false) do
        unit:GiveNukeSiloAmmo(3)
    end
    ScenarioFramework.CreateTimerTrigger(M2NukeAttackStart, M2AeonNukeTimer)

    -- Unlock a var table entry to allow Aeon to begin building some freaking artillery
    if ScenarioInfo.Options.Difficulty == 3 then
        ScenarioFramework.CreateTimerTrigger(M2AeonArtilleryUnlock, M2AeonArtilleryTimer)
    end

    -- Spawn in defensive naval units and send them out to their destinations
    for i=1,ScenarioInfo.Options.Difficulty do
        local plat = ScenarioUtils.CreateArmyGroupAsPlatoonCoopBalanced('Aeon', 'M2_Start_Navy_'..i, 'AttackFormation')
        plat.PlatoonData.PatrolChain = 'Aeon_M2_Defensive_Fleets_Chain_' .. i
        plat.PlatoonData.BaseReturnMarker = 'Aeon_M2_Defensive_Fleet_Marker_' .. i
        plat:ForkAIThread(M2AeonNavalGroupThread)
    end

    -- Objective Reminder Timer
    ScenarioFramework.CreateTimerTrigger(M2ObjectiveReminder, M2ObjectiveReminderTimer)
    Objectives.UpdateBasicObjective(ScenarioInfo.M1P1Obj, 'description', OpStrings.M2P1Description)
end

-- Do stuff when player kills the Aeon CDR in M2
function M2AeonCDRDestroyed(unit)
    ScenarioFramework.CDRDeathNISCamera(unit, 7)
end

function M2ObjectiveReminder()
    if ScenarioInfo.MissionNumber == 2 and not ScenarioInfo.M2AeonBaseDefeatedBool then
        if Random(1,2) == 1 then
            ScenarioFramework.Dialogue(OpStrings.E06_M02_150)
        else
            ScenarioFramework.Dialogue(OpStrings.E06_M02_155)
        end
        ScenarioFramework.CreateTimerTrigger(M2ObjectiveReminder, M2ObjectiveReminderTimer)
    end
end

-- Warn player about Aeon base to the south east; create LOS intel trigger of new island
function M2AeonBaseDialogue()
    ScenarioFramework.CreateArmyIntelTrigger(M2AeonBaseSighted, ArmyBrains[Player], 'LOSNow', false, true,
                                             categories.STRUCTURE, true, ArmyBrains[Aeon])
    ScenarioInfo.M2P1Obj = Objectives.Basic('primary', 'incomplete', OpStrings.M2P2Title, OpStrings.M2P2Description, Objectives.GetActionIcon('kill'),
        {
            ShowFaction = 'Aeon',
            Areas = { 'M2_Aeon_Base_Area' },
        }
   )
end

-- Confirm dialogue when Aeon Base sighted
function M2AeonBaseSighted()
    if not ScenarioInfo.AikoUnitDestroyed and ScenarioInfo.AikoUnit:GetHealthPercent() >= .5 then
        ScenarioFramework.Dialogue(OpStrings.E06_M02_030)
    else
        ScenarioFramework.Dialogue(OpStrings.E06_M02_035)
    end
end

-- Unlocks engineers to build Artillery in Aeon Base
function M2AeonArtilleryUnlock()
    -- LOG('*DEBUG: Unlocking Artillery')
    ScenarioInfo.VarTable['AeonM2ArtilleryUnlocked'] = true
end

-- Attack player with a nuke from Aeon Base
function M2NukeAttackStart()
    local nukeLaunchers = ArmyBrains[Aeon]:GetListOfUnits(categories.uab2305, false)
    for num, unit in nukeLaunchers do
        if not unit:IsDead() then
            IssueNuke({unit}, ScenarioUtils.MarkerToPosition('Aeon_M2_Nuke_Target'))
            -- LOG('*DEBUG: NUKE LAUNCH M2 AEON')
            break
        end
    end
    if ScenarioInfo.Options.Difficulty > 1 then
        ScenarioFramework.CreateTimerTrigger(M2AeonNukeClump, M2AeonNukeClumpTimer)
    end
end

-- Nuke a clump in M2
function M2AeonNukeClump()
    local clumpNum = GetLowestNonNegativeClumpThread(Aeon)
    if clumpNum > 0 then
        local nukeLaunchers = ArmyBrains[Aeon]:GetListOfUnits(categories.uab2305, false)
        for num, unit in nukeLaunchers do
            if not unit:IsDead() and unit:GetNukeSiloAmmoCount() > 0 then
                IssueNuke({unit}, ScenarioUtils.MarkerToPosition('Nuke_Me_Clump_'..clumpNum))
                -- LOG('*DEBUG: NUKE LAUNCH M2 AEON')
                break
            end
        end
    end
end

-- Platoon AI that sends naval groups off to fight as needed
function M2AeonNavalGroupThread(platoon)
    ScenarioFramework.PlatoonPatrolChain(platoon, platoon.PlatoonData.PatrolChain)
    local aiBrain = platoon:GetBrain()
    while not ScenarioInfo.M2AeonBaseUnderAttack do
        WaitSeconds(10)
        if not aiBrain:PlatoonExists(platoon) then
            return
        end
    end
    platoon:Stop()
    platoon:MoveToLocation(ScenarioUtils.MarkerToPosition(platoon.PlatoonData.BaseReturnMarker), false)
end

-- When the Aeon base is destroyed begin the cybran assault
function M2AeonBaseDefeated()
    ScenarioInfo.M2AeonBaseDefeatedBool = true
    if not ScenarioInfo.AikoUnitDestroyed and ScenarioInfo.AikoUnit:GetHealthPercent() >= .5  then
        ScenarioFramework.Dialogue(OpStrings.E06_M02_040)
    else
        ScenarioFramework.Dialogue(OpStrings.E06_M02_045)
    end
    ScenarioInfo.M2P1Obj:ManualResult(true)
    ScenarioFramework.Dialogue(ScenarioStrings.PObjComp)
    M2CybranAttackBegin()
    ForkThread(M2TransferUnitsToPlayer)
end

-- Wait a number of seconds then fly in units and transfer them to the player.
function M2TransferUnitsToPlayer()
    WaitSeconds(M2TransferUnitDelay)
    while GetArmyUnitCostTotal(Player) > 425 do
        WaitSeconds(10)
    end
    local transports = ScenarioUtils.CreateArmyGroupAsPlatoonCoopBalanced('Black_Sun', 'M2_Transports', 'ChevronFormation')
    local units = ScenarioUtils.CreateArmyGroup('Black_Sun', 'M2_Units')
    ScenarioFramework.AttachUnitsToTransports(units, transports:GetPlatoonUnits())
    local cmd = transports:UnloadAllAtLocation(ScenarioUtils.MarkerToPosition('Player_M2_Transfer_Unit_Landing_Marker'))
    while transports:IsCommandsActive(cmd) do
        WaitSeconds(2)
        if not ArmyBrains[BlackSun]:PlatoonExists(transports) then
            for k,v in units do
                if not v:IsDead() then
                    ScenarioFramework.GiveUnitToArmy(v, Player)
                end
            end
            return
        end
    end
-- if not ScenarioInfo.AikoUnitDestroyed and ScenarioInfo.AikoUnit:GetHealthPercent() >= .5  then
--    ScenarioFramework.Dialogue(OpStrings.E06_M02_050)
-- else
--    ScenarioFramework.Dialogue(OpStrings.E06_M02_055)
-- end
    for k,v in units do
        if not v:IsDead() then
            ScenarioFramework.GiveUnitToArmy(v,Player)
        end
    end
    for k,v in transports:GetPlatoonUnits() do
        if not v:IsDead() then
            ScenarioFramework.GiveUnitToArmy(v, Player)
        end
    end
end

-- Send Spider bot attack and start timer for capturing the control center
function M2CybranAttackBegin()
    ScenarioInfo.MissionNumber = 2
    ScenarioFramework.SetPlayableArea('M2_Playable_Area_2')

    local lastSpiderBot

    -- Create and move Spider bots
    local spiderBots = ScenarioUtils.CreateArmyGroupAsPlatoonCoopBalanced('Cybran', 'M2_Spider_D'..ScenarioInfo.Options.Difficulty, 'TravellingFormation')
    for num, unit in spiderBots:GetPlatoonUnits() do
        IssueMove({ScenarioInfo.UnitNames[Cybran]['Spider_'..num]}, ScenarioUtils.MarkerToPosition('Cybran_Spider_Move_'..num))
        lastSpiderBot = unit
    end

    -- Create and move light assault bots
    local allBots = {}
    for i=1,ScenarioInfo.Options.Difficulty*2 do
        local bots = ScenarioUtils.CreateArmySubGroup('Cybran', 'M2_Spider_Light_Bots', 'Bot_'..i)
        for k,v in bots do
            table.insert(allBots, v)
        end
        IssueMove(bots, ScenarioUtils.MarkerToPosition('Cybran_Spider_Move_'..i))
        ScenarioFramework.GroupPatrolChain(bots, 'Control_Center_Patrol_Chain')
        ScenarioFramework.CreateGroupDeathTrigger(LightBotsKilled, bots)
    end

    -- Create and move Air units
    local plat = ScenarioUtils.CreateArmyGroupAsPlatoonCoopBalanced('Cybran', 'M2_Spider_Air_Attack_D'..ScenarioInfo.Options.Difficulty, 'ChevronFormation')
    ScenarioFramework.PlatoonPatrolChain(plat, 'Cybran_M2_Spider_Air_Chain')

    -- Nuke Clump 4
    if ScenarioInfo.Options.Difficulty > 1 then
        local nukeLaunchers = ArmyBrains[Cybran]:GetListOfUnits(categories.urb2305, false)
        for num, unit in nukeLaunchers do
            if not unit:IsDead() then
                IssueNuke({unit}, ScenarioUtils.MarkerToPosition('Nuke_Me_Clump_4'))
            end
        end
    end

    -- Set triggers for Cybran attack events
    ScenarioFramework.CreatePlatoonDeathTrigger(M2SpiderBotsDestroyed, spiderBots)
    ScenarioFramework.CreateAreaTrigger(M2CybranCaptureBegin, 'Control_Center_Area', categories.url0402, true, false, ArmyBrains[Cybran])
    ScenarioFramework.CreateTimerTrigger(M2CybranCaptureBegin, M2CybranCaptureTimer)
    ScenarioInfo.VarTable['M2CybranHeavyLandAttack'] = true

    local objUnits = spiderBots:GetPlatoonUnits()
    for k,v in allBots do
        table.insert(objUnits, v)
    end

    ScenarioInfo.M2P3Obj = Objectives.Basic('primary', 'incomplete', OpStrings.M2P3Title, OpStrings.M2P3Description, Objectives.GetActionIcon('kill'),
        {
            Units = objUnits,
            MarkUnits = false,
        }
   )
    ScenarioFramework.Dialogue(ScenarioStrings.NewPObj)
    ScenarioFramework.Dialogue(ScenarioStrings.MapExpansion)

-- Spiderbot introduction
    local camInfo = {
        blendTime = 1.0,
        holdTime = 4,
        orientationOffset = { -2.6, 0.3, 0 },
        positionOffset = { 0, 0.5, 10 },
        zoomVal = 35,
        vizRadius = 25,
    }
    ScenarioFramework.OperationNISCamera(lastSpiderBot, camInfo)

end

-- If Diff > 1 then attack with more air to be cruel and hilarious
function M2CybranRepeatSpiderAir()
    -- LOG('*DEBUG: REPEAT SPIDER AIR ATTACK')
    if ScenarioInfo.MissionNumber == 2 then
        local plat = ScenarioUtils.CreateArmyGroupAsPlatoonCoopBalanced('Cybran', 'M2_Spider_Air_Attack_D'..ScenarioInfo.Options.Difficulty, 'ChevronFormation')
        ScenarioFramework.PlatoonPatrolChain(plat, 'Cybran_M2_Spider_Air_Chain')
        if not ScenarioInfo.M2CybranSpiderAirRepeated then
            ScenarioFramework.CreateTimerTrigger(M2CybranRepeatSpiderAir, M2CybranSpiderAirTimer)
        end
        ScenarioInfo.M2CybranSpiderAirRepeated = true
    end
end

function LightBotsKilled()
    if not ScenarioInfo.M2CybranLightBotsKilled then
        ScenarioInfo.M2CybranLightBotsKilled = 1
    else
        ScenarioInfo.M2CybranLightBotsKilled = ScenarioInfo.M2CybranLightBotsKilled + 1
    end
    if ScenarioInfo.Options.Difficulty > 1 and ScenarioInfo.M2CybranLightBotsKilled == ScenarioInfo.Options.Difficulty * 2 then
        M2CybranRepeatSpiderAir()
    end
end

-- Set bool when the spiders have been killed
function M2SpiderBotsDestroyed()
    ScenarioInfo.M2SpiderBotAttackPlatoonDestroyed = true
    ForkThread(M2CybranCaptureBegin)
    M2CheckCybranGroups()
end

-- Send out the transports with engineers the first time
function M2CybranCaptureBegin()
    if not ScenarioInfo.M2CybranCaptureBlackSunGroupSent then
        if not ScenarioInfo.AikoUnitDestroyed and ScenarioInfo.AikoUnit:GetHealthPercent() >= .5  then
            ScenarioFramework.Dialogue(OpStrings.E06_M02_060)
        else
            ScenarioFramework.Dialogue(OpStrings.E06_M02_065)
        end
        ScenarioInfo.M2CybranCaptureBlackSunGroupSent = true
        M2CybranCaptureSend(true)
    end
end

-- Send the capture group and repeat if needed
function M2CybranCaptureSend(forceSend)
    if not ScenarioInfo.M2SpiderBotAttackPlatoonDestroyed or forceSend then
        -- LOG('*DEBUG: SENDING CYBRAN CAPTURE ATTACK')
        if not ScenarioInfo.M2CaptureGroups then
            ScenarioInfo.M2CaptureGroups = 1
        else
            ScenarioInfo.M2CaptureGroups = ScenarioInfo.M2CaptureGroups + 1
        end
        local transports = ScenarioUtils.CreateArmyGroupAsPlatoonCoopBalanced('Cybran', 'M2_Capture_Transports_D'..ScenarioInfo.Options.Difficulty, 'ChevronFormation')
        local passengers = ScenarioUtils.CreateArmyGroupAsPlatoonCoopBalanced('Cybran', 'M2_Capture_Passengers_D'..ScenarioInfo.Options.Difficulty, 'AttackFormation')
        local escorts = ScenarioUtils.CreateArmyGroupAsPlatoonCoopBalanced('Cybran', 'M2_Capture_Escort_D'..ScenarioInfo.Options.Difficulty, 'ChevronFormation')
        ScenarioFramework.AttachUnitsToTransports(passengers:GetPlatoonUnits(), transports:GetPlatoonUnits())
        ScenarioFramework.CreatePlatoonDeathTrigger(M2CybranPassengersKilled, passengers)
        ScenarioFramework.CreatePlatoonDeathTrigger(M2CybranEscortsKilled, escorts)
        ScenarioFramework.PlatoonPatrolChain(escorts, 'Control_Center_Patrol_Chain')

        -- repeat as needed
        ScenarioFramework.CreateTimerTrigger(M2CybranCaptureSend, M2CybranCaptureRepeatTimer)
        WaitSeconds(10)
        local loadCmd = transports:UnloadAllAtLocation(ScenarioUtils.MarkerToPosition('Black_Sun_Control_Center_Marker'))
        while table.getn(transports:GetPlatoonUnits()) > 0 and transports:IsCommandsActive(loadCmd) do
            WaitSeconds(1)
        end
        transports:MoveToLocation(ScenarioUtils.MarkerToPosition('Cybran_Transport_Pool_Marker'), false)
        ArmyBrains[Cybran]:AssignUnitsToPlatoon('TransportPool', transports, 'Scout', 'ChevronFormation')
        if ArmyBrains[Cybran]:PlatoonExists(passengers) and ScenarioInfo.BlackSunControlCenter:GetAIBrain() ~= ArmyBrains[Cybran]then
            for num, unit in passengers:GetPlatoonUnits() do
                if EntityCategoryContains(categories.ENGINEER, unit) then
                    IssueCapture({unit}, ScenarioInfo.BlackSunControlCenter)
                end
            end
        end
    end
end

-- Dialogue and reset unit when control center captured and update global unit
function M2BlackSunControlCenterCaptured(newUnit, captor)
    ForkThread(M2BlackSunControlCenterCapturedThread, newUnit, captor)
end

function M2BlackSunControlCenterCapturedThread(newUnit, captor)
    if not ScenarioInfo.BlackSunCapturedByCybran then
        ScenarioInfo.BlackSunCapturedByCybran = true
        ScenarioInfo.BlackSunCapturedByPlayer = false
        ScenarioFramework.Dialogue(OpStrings.E06_M02_070)
        ScenarioInfo.BlackSunControlCenter = newUnit
        WaitTicks(1)
        ScenarioInfo.BlackSunControlCenter:SetDoNotTarget(true)
        ScenarioInfo.BlackSunControlCenter:SetCanBeKilled(false)
        ScenarioInfo.BlackSunControlCenter:SetCanTakeDamage(false)
        ScenarioInfo.BlackSunControlCenter:SetReclaimable(false)
        ScenarioInfo.BlackSunControlCenter:SetCustomName(LOC '{i BlackSunControlTower}')
        ScenarioFramework.CreateUnitCapturedTrigger(false, M2PlayerRecaptureControlCenter, ScenarioInfo.BlackSunControlCenter)
        ScenarioInfo.M2P4Obj = Objectives.Basic('primary', 'incomplete', OpStrings.M2P4Title, OpStrings.M2P4Description, Objectives.GetActionIcon('capture'),
            {
                MarkUnits = true,
                Units = { ScenarioInfo.BlackSunControlCenter },
            }
       )

-- Control Center captured by bad guys camera
        local camInfo = {
            blendTime = 1.0,
            holdTime = 4,
            orientationOffset = { -1, 0.5, 0 },
            positionOffset = { 0, 1, 0 },
            zoomVal = 40,
            vizRadius = 25,
        }
        ScenarioFramework.OperationNISCamera(ScenarioInfo.BlackSunControlCenter, camInfo)
    end
end

-- When Player recaptures black sun, dialogue, set up triggers, other awesomeness
function M2PlayerRecaptureControlCenter(newUnit, captor)
    ForkThread(M2PlayerRecaptureControlCenterThread, newUnit, captor)
end

function M2PlayerRecaptureControlCenterThread(newUnit, captor)
    if not ScenarioInfo.BlackSunCapturedByPlayer then
        ScenarioInfo.BlackSunCapturedByPlayer = true
        ScenarioInfo.BlackSunCapturedByCybran = false
        if not ScenarioInfo.AikoUnitDestroyed and ScenarioInfo.AikoUnit:GetHealthPercent() >= .5  then
            ScenarioFramework.Dialogue(OpStrings.E06_M02_080)
        else
            ScenarioFramework.Dialogue(OpStrings.E06_M02_085)
        end
        ScenarioInfo.BlackSunControlCenter = ScenarioFramework.GiveUnitToArmy(newUnit, BlackSun)
        WaitTicks(1)
        ScenarioInfo.BlackSunControlCenter:SetDoNotTarget(true)
        ScenarioInfo.BlackSunControlCenter:SetCanBeKilled(false)
        ScenarioInfo.BlackSunControlCenter:SetCanTakeDamage(false)
        ScenarioInfo.BlackSunControlCenter:SetReclaimable(false)
        ScenarioInfo.BlackSunControlCenter:SetCustomName(LOC '{i BlackSunControlTower}')
        ScenarioFramework.CreateUnitCapturedTrigger(false, M2BlackSunControlCenterCaptured, ScenarioInfo.BlackSunControlCenter)
        ScenarioInfo.M2P4Obj:ManualResult(true)
        ScenarioFramework.Dialogue(ScenarioStrings.PObjComp)
        M2CheckCybranGroups()

-- Control Center captured by player camera
        local camInfo = {
            blendTime = 1.0,
            holdTime = 4,
            orientationOffset = { -2.7, 0.5, 0 },
            positionOffset = { 0, 1, 0 },
            zoomVal = 40,
        }
        ScenarioFramework.OperationNISCamera(ScenarioInfo.BlackSunControlCenter, camInfo)
    end
end

-- When Passengers killed
function M2CybranPassengersKilled()
    if not ScenarioInfo.M2CybranPassengersKilledCounter then
        ScenarioInfo.M2CybranPassengersKilledCounter = 1
    else
        ScenarioInfo.M2CybranPassengersKilledCounter = ScenarioInfo.M2CybranPassengersKilledCounter + 1
    end
    M2CheckCybranGroups()
end

-- When Escorts killed
function M2CybranEscortsKilled()
    if not ScenarioInfo.M2CybranEscortsKilledCounter then
        ScenarioInfo.M2CybranEscortsKilledCounter = 1
    else
        ScenarioInfo.M2CybranEscortsKilledCounter = ScenarioInfo.M2CybranEscortsKilledCounter + 1
    end
    M2CheckCybranGroups()
end

-- Check if all Cybran Attack group units are killed
function M2CheckCybranGroups()
    if ScenarioInfo.M2SpiderBotAttackPlatoonDestroyed and
        ScenarioInfo.M2CybranEscortsKilledCounter == ScenarioInfo.M2CaptureGroups and
        ScenarioInfo.M2CybranPassengersKilledCounter == ScenarioInfo.M2CaptureGroups and
       (ScenarioInfo.BlackSunControlCenter:GetAIBrain() == ArmyBrains[Player] or
        ScenarioInfo.BlackSunControlCenter:GetAIBrain() == ArmyBrains[BlackSun])then
            EndMission2()
    end
end

-- Cleanup for mission 2
function EndMission2()
    if not ScenarioInfo.M2Ended then
        ScenarioInfo.M2Ended = true
        if not ScenarioInfo.AikoUnitDestroyed and ScenarioInfo.AikoUnit:GetHealthPercent() >= .5  then
            ScenarioFramework.Dialogue(OpStrings.E06_M02_100)
        else
            ScenarioFramework.Dialogue(OpStrings.E06_M02_105)
        end
        ScenarioFramework.Dialogue(ScenarioStrings.MissionSuccessDialogue)
        ScenarioInfo.M2P3Obj:ManualResult(true)
        ScenarioFramework.Dialogue(ScenarioStrings.PObjComp)
        StartMission3()
    end
end










-- === MISSION 3 FUNCTIONS === #
function StartMission3()
    if ScenarioInfo.MissionNumber ~= 3 then
        for k,v in ScenarioInfo.BlackSunCannon do
            v:SetWorkProgress(.01)
        end
        SetArmyUnitCap(1, 500)
        ScenarioFramework.SetPlayableArea('M2_Playable_Area_2')
        ScenarioFramework.Dialogue(ScenarioStrings.MapExpansion)
        ScenarioInfo.MissionNumber = 3
        ScenarioFramework.Dialogue(ScenarioStrings.PObjUpdate)

        -- Give the Player ability to make le Mavor
        for _, player in ScenarioInfo.HumanPlayers do
                 ScenarioFramework.RemoveRestriction(player, categories.ueb2401)
        end

        if not ScenarioInfo.AikoUnitDestroyed and ScenarioInfo.AikoUnit:GetHealthPercent() >= .5  then
            ScenarioFramework.Dialogue(OpStrings.E06_M03_010)
        else
            ScenarioFramework.Dialogue(OpStrings.E06_M03_015)
        end

        -- Create Aeon Stuff
        ScenarioInfo.ArnoldPlatoon = ScenarioUtils.CreateArmyGroupAsPlatoonCoopBalanced('Aeon', 'M3_Arnold_Unit', 'AttackFormation')
        ScenarioFramework.CreateUnitDestroyedTrigger(M3ArnoldDefeated, ScenarioInfo.ArnoldPlatoon:GetPlatoonUnits()[1])
        ScenarioInfo.ArnoldPlatoon:ForkAIThread(M3ArnoldAIThread)
        ScenarioInfo.ArnoldPlatoon:GetPlatoonUnits()[1]:SetCustomName(LOC '{i CDR_Arnold}')
        ScenarioInfo.ArnoldPlatoon:GetPlatoonUnits()[1]:CreateEnhancement('Shield')
        ScenarioInfo.ArnoldPlatoon:GetPlatoonUnits()[1]:CreateEnhancement('CrysalisBeam')
        ScenarioInfo.ArnoldPlatoon:GetPlatoonUnits()[1]:CreateEnhancement('HeatSink')

        ScenarioUtils.CreateArmyGroup('Aeon', 'M3_Arnold_Base_D' .. ScenarioInfo.Options.Difficulty)
        ScenarioUtils.CreateArmyGroup('Aeon', 'M3_SW_Base_D' .. ScenarioInfo.Options.Difficulty)
        for num,unit in ArmyBrains[Aeon]:GetListOfUnits(categories.uab2305, false) do
            unit:GiveNukeSiloAmmo(5)
        end

        local plat = ScenarioUtils.CreateArmyGroupAsPlatoonCoopBalanced('Aeon', 'M3_Arnold_Base_Engineers_D'..ScenarioInfo.Options.Difficulty, 'AttackFormation')
        plat.PlatoonData.MaintainBaseTemplate = 'M3_Arnold_Base'
        plat.PlatoonData.AssistFactories = true
        plat.PlatoonData.LocationType = 'AeonArnoldBase'
        plat:ForkAIThread(ScenarioPlatoonAI.StartBaseEngineerThread)

        local plat = ScenarioUtils.CreateArmyGroupAsPlatoonCoopBalanced('Aeon', 'M3_SW_Base_Engineers_D'..ScenarioInfo.Options.Difficulty, 'AttackFormation')
        plat.PlatoonData.MaintainBaseTemplate = 'M3_SW_Base'
        plat.PlatoonData.AssistFactories = true
        plat.PlatoonData.LocationType = 'AeonM3Base'
        plat:ForkAIThread(ScenarioPlatoonAI.StartBaseEngineerThread)

        -- Set Globals for this mission
        ScenarioInfo.VarTable['M3AllowAttacks'] = true
        ScenarioInfo.OSPlatoonCounter['Aeon_LandAssaultTransportCount_D1'] = 20
        ScenarioInfo.OSPlatoonCounter['Aeon_LandAssaultTransportCount_D2'] = 20
        ScenarioInfo.OSPlatoonCounter['Aeon_LandAssaultTransportCount_D3'] = 20

        ScenarioInfo.FinalAttackPlatoonCounter = 0

        -- Create 20 timer with updates
        ScenarioFramework.CreateTimerTrigger(M3ChargeTimer, M3ChargeTimerSegmentDuration)

        -- Objective Reminders timer
        -- ScenarioFramework.CreateTimerTrigger(M3ObjectiveReminder, M3ObjectiveReminderTimer)

        -- Start the first attack wave - Naval
        M3AttackWaveOne()

        Objectives.UpdateBasicObjective(ScenarioInfo.M1P1Obj, 'description', OpStrings.M3P1Description)
        -- ==== DEBUG ==== #
        -- OnF4()

        -- ScenarioUtils.CreateArmyGroup('Cybran', 'M3_Forward_Base_D3')
        -- M3BeforeFinalAttackNavy()
        -- WaitSeconds(120)
        -- M3FinalAttack()
    end
end

function M3ObjectiveReminder()
    if ScenarioInfo.MissionNumber == 3 then
        if Random(1,2) == 1 then
            ScenarioFramework.Dialogue(OpStrings.E06_M03_110)
        else
            ScenarioFramework.Dialogue(OpStrings.E06_M03_115)
        end
    end
end

-- Callback for timer; Creates self and handles proper number
function M3ChargeTimer()
    if not ScenarioInfo.M3ChargeCounter then
        ScenarioInfo.M3ChargeCounter = 1
        ScenarioFramework.CreateTimerTrigger(M3ChargeTimer, M3ChargeTimerSegmentDuration)
        Objectives.UpdateBasicObjective(ScenarioInfo.M1P1Obj, 'progress', OpStrings.M3P1Progress1)
    elseif not ScenarioInfo.M3ChargeComplete then
        ScenarioInfo.M3ChargeCounter = ScenarioInfo.M3ChargeCounter + 1
        if ScenarioInfo.M3ChargeCounter == 20 then
--        ScenarioInfo.M3ChargeComplete = true
--        for k,v in ScenarioInfo.BlackSunCannon do
--            v:SetWorkProgress(1)
--        end
--        ForkThread(M3CheckArnoldAssaultGroups)
--        if not ScenarioInfo.AikoUnitDestroyed and ScenarioInfo.AikoUnit:GetHealthPercent() >= .5  then
--            ScenarioFramework.Dialogue(OpStrings.E06_M03_066)
--        else
--            ScenarioFramework.Dialogue(OpStrings.E06_M03_067)
--        end
            -- LOG('*DEBUG: FINAL CHARGE FINISHED')
        else
            Objectives.UpdateBasicObjective(ScenarioInfo.M1P1Obj, 'progress', OpStrings['M3P1Progress'..ScenarioInfo.M3ChargeCounter])
            ScenarioFramework.CreateTimerTrigger(M3ChargeTimer, M3ChargeTimerSegmentDuration)
            -- Dialogue
            if ScenarioInfo.M3ChargeCounter == 4 then
                if not ScenarioInfo.AikoUnitDestroyed and ScenarioInfo.AikoUnit:GetHealthPercent() >= .5  then
                    ScenarioFramework.Dialogue(OpStrings.E06_M03_020)
                else
                    ScenarioFramework.Dialogue(OpStrings.E06_M03_025)
                end
            elseif ScenarioInfo.M3ChargeCounter == 8 then
                if not ScenarioInfo.AikoUnitDestroyed and ScenarioInfo.AikoUnit:GetHealthPercent() >= .5  then
                    ScenarioFramework.Dialogue(OpStrings.E06_M03_030)
                else
                    ScenarioFramework.Dialogue(OpStrings.E06_M03_035)
                end
            elseif ScenarioInfo.M3ChargeCounter == 12 then
                if not ScenarioInfo.AikoUnitDestroyed and ScenarioInfo.AikoUnit:GetHealthPercent() >= .5  then
                    ScenarioFramework.Dialogue(OpStrings.E06_M03_040)
                else
                    ScenarioFramework.Dialogue(OpStrings.E06_M03_045)
                end
            elseif ScenarioInfo.M3ChargeCounter == 16 then
                if not ScenarioInfo.AikoUnitDestroyed and ScenarioInfo.AikoUnit:GetHealthPercent() >= .5  then
                    ScenarioFramework.Dialogue(OpStrings.E06_M03_060)
                else
                    ScenarioFramework.Dialogue(OpStrings.E06_M03_065)
                end
            end
            -- Attacks
            if ScenarioInfo.M3ChargeCounter == 4 then
                M3AttackWaveZero()
                PlayTaunt()
            elseif ScenarioInfo.M3ChargeCounter == 8 then
                M3AttackWaveTwo()
                PlayTaunt()
            elseif ScenarioInfo.M3ChargeCounter == 12 then
                M3AttackWaveThree()
                PlayTaunt()
            elseif ScenarioInfo.M3ChargeCounter == 15 then
                M3BeforeFinalAttackNavy()
                PlayTaunt()
            elseif ScenarioInfo.M3ChargeCounter == 16 then
                M3FinalAttack()
            end
        end
    end
    if not ScenarioInfo.M3ChargeComplete then
        for k,v in ScenarioInfo.BlackSunCannon do
            v:SetWorkProgress(ScenarioInfo.M3ChargeCounter/20)
        end
    end
    -- LOG('*DEBUG: M3 CHARGE TIMER CALLED - '..ScenarioInfo.M3ChargeCounter)
end

-- First scripted attack of M3 - Naval Cybran and Aeon
function M3AttackWaveOne()
    local aeonNavy = ScenarioUtils.CreateArmyGroupAsPlatoonCoopBalanced('Aeon', 'M3A1_Naval_D'..ScenarioInfo.Options.Difficulty, 'AttackFormation')
    ScenarioFramework.PlatoonAttackChain(aeonNavy, 'Aeon_M3_Attack_One_Chain')

    -- 6 minutes for destroyers to hit land
    local cybNavyGroup = ScenarioUtils.CreateArmyGroupAsPlatoonCoopBalanced('Cybran', 'M3A1_Naval_G1_D'..ScenarioInfo.Options.Difficulty, 'AttackFormation')
    ScenarioFramework.PlatoonAttackChain(cybNavyGroup,'Cybran_M3_Attack_One_Group_Chain')

    local cybNavyDest = ScenarioUtils.CreateArmyGroupAsPlatoonCoopBalanced('Cybran', 'M3A1_Naval_G2_D'..ScenarioInfo.Options.Difficulty, 'AttackFormation')
    ScenarioFramework.PlatoonAttackChain(cybNavyDest, 'Cybran_M3_Attack_One_Dest_Chain')

    local cybNavyWest = ScenarioUtils.CreateArmyGroupAsPlatoonCoopBalanced('Cybran','M3A1_Naval_West_D'..ScenarioInfo.Options.Difficulty, 'AttackFormation')
    ScenarioFramework.PlatoonAttackChain(cybNavyWest, 'Cybran_M3_Attack_One_West_Chain')
end

-- Aeon Nukes followed by Cybran nukes on top of Aeon air ... then cybran air
function M3AttackWaveZero()
    local clumpNum = GetLowestNonNegativeClumpThread(Cybran)
    ForkThread(M3AttackWaveZeroAeon, clumpNum)
    ForkThread(M3AttackWaveZeroCybran, clumpNum)
end

-- Returns the clump number of the highest threat clumpity clump clump
function GetLowestNonNegativeClumpThread(brainNum)
    local aiBrain = ArmyBrains[brainNum]
    local clumpNum = 0
    local lowCount = 0
    for i=1,9 do
        local count = table.getn(ArmyBrains[Aeon]:GetUnitsAroundPoint(categories.ALLUNITS - categories.WALL,
                                  ScenarioUtils.MarkerToPosition('Nuke_Me_Clump_'..i), 30, 'Enemy'))
        if count < lowCount or(count > 0 and lowCount == 0) then
            clumpNum = i
            lowCount = count
        end
    end
    return clumpNum
end

-- Aeon nukes and moves in
function M3AttackWaveZeroAeon(clumpNum)
    local nukeLaunchers = {}
    for i=1,5 do
        table.insert(nukeLaunchers, ScenarioInfo.UnitNames[Aeon]['Arnold_Nuke_'..i])
    end
    IssueNuke({nukeLaunchers[1]}, ScenarioUtils.MarkerToPosition('Nuke_Me_Clump_'..clumpNum))

    local airPlat1 = ScenarioUtils.CreateArmyGroupAsPlatoonCoopBalanced('Aeon', 'M3A0_Air_Attack_G1_D'..ScenarioInfo.Options.Difficulty, 'ChevronFormation')
    airPlat1:Patrol(ScenarioUtils.MarkerToPosition('Nuke_Me_Clump_'..clumpNum))
    airPlat1:Patrol(ScenarioUtils.MarkerToPosition('Player_Attack_Black_Sun'))
end

-- Cybran moves in then nukes
function M3AttackWaveZeroCybran(clumpNum)
    -- nuke 3 or 9
    local nukeNum = 3
    if ArmyBrains[Cybran]:GetThreatAtPosition(ScenarioUtils.MarkerToPosition('Nuke_Me_Clump_3'),2,false) <
        ArmyBrains[Cybran]:GetThreatAtPosition(ScenarioUtils.MarkerToPosition('Nuke_Me_Clump_9'),2,false) then
        nukeNum = 9
    end
    local nukeLaunchers = ArmyBrains[Cybran]:GetListOfUnits(categories.urb2305, false)
    IssueNuke({nukeLaunchers[1]}, ScenarioUtils.MarkerToPosition('Nuke_Me_Clump_4'))


    local airPlat1 = ScenarioUtils.CreateArmyGroupAsPlatoonCoopBalanced('Cybran', 'M3A0_Air_Attack_G1_D'..ScenarioInfo.Options.Difficulty, 'ChevronFormation')
    airPlat1:Patrol(ScenarioUtils.MarkerToPosition('Nuke_Me_Clump_'..clumpNum))
    airPlat1:Patrol(ScenarioUtils.MarkerToPosition('Player_Attack_Black_Sun'))
end

-- Second scripted attack of M3 - Cybran Land attacks - Aeon Nukes with Air and building of Aeon encampments
function M3AttackWaveTwo()
    WaitSeconds(M3AttackTwoDelay)

    -- Move the Cybran Units out
    local cybSpiders = ScenarioUtils.CreateArmyGroup('Cybran', 'M3A2_Land_Spiders')
    for k,v in cybSpiders do
        if v.UnitName == 'AttackTwo_Spider_1' then
            ScenarioFramework.GroupMoveChain({v}, 'Cybran_M3_Attack_Two_Spider1_Chain')
        elseif v.UnitName == 'AttackTwo_Spider_2' then
            ScenarioFramework.GroupMoveChain({v}, 'Cybran_M3_Attack_Two_Spider2_Chain')
        elseif v.UnitName == 'AttackTwo_Spider_3' then
            ScenarioFramework.GroupMoveChain({v}, 'Cybran_M3_Attack_Two_Spider3_Chain')
        elseif v.UnitName == 'AttackTwo_Spider_4' then
            ScenarioFramework.GroupMoveChain({v}, 'Cybran_M3_Attack_Two_Spider4_Chain')
        else
            IssueMove({v}, ScenarioUtils.MarkerToPosition('Player_Attack_Black_Sun'))
        end
    end

    local cybLandGroup1 = ScenarioUtils.CreateArmyGroup('Cybran', 'M3A2_Land_Attack_G1_D'..ScenarioInfo.Options.Difficulty)
    ScenarioFramework.GroupFormPatrolChain(cybLandGroup1, 'Cybran_M3_Attack_Two_Land_G1_Chain', 'AttackFormation')

    local cybLandGroup2 = ScenarioUtils.CreateArmyGroup('Cybran', 'M3A2_Land_Attack_G2_D'..ScenarioInfo.Options.Difficulty)
    ScenarioFramework.GroupFormPatrolChain(cybLandGroup2, 'Cybran_M3_Attack_Two_Land_G2_Chain', 'AttackFormation')

    local cybLandGroup3 = ScenarioUtils.CreateArmyGroup('Cybran', 'M3A2_Land_Attack_G3_D'..ScenarioInfo.Options.Difficulty)
    ScenarioFramework.GroupFormPatrolChain(cybLandGroup3, 'Cybran_M3_Attack_Two_Land_G3_Chain', 'AttackFormation')

    local cybAir = ScenarioUtils.CreateArmyGroup('Cybran', 'M3A2_Air_Attack_D'..ScenarioInfo.Options.Difficulty)
    ScenarioFramework.GroupPatrolChain(cybAir, 'Cybran_M3_Attack_Two_Air_Chain')

    -- Aeon Nukes
    -- 1.5 minutes for units to be in range
    WaitSeconds(120)
    -- LOG('*DEBUG: AEON M3 WAVE TWO NUKES')
    local nukeLaunchers = {}
    for i=1,5 do
        table.insert(nukeLaunchers, ScenarioInfo.UnitNames[Aeon]['Arnold_Nuke_'..i])
    end
    IssueNuke({nukeLaunchers[1]}, ScenarioUtils.MarkerToPosition('Aeon_M3_Attack_Two_Nuke_1'))
    WaitSeconds(3)
    IssueNuke({nukeLaunchers[2]}, ScenarioUtils.MarkerToPosition('Aeon_M3_Attack_Two_Nuke_2'))
    WaitSeconds(5)
    IssueNuke({nukeLaunchers[3]}, ScenarioUtils.MarkerToPosition('Aeon_M3_Attack_Two_Nuke_3'))
    WaitSeconds(7)
    local nukesLeft = 2
    local clumpCounter = 1
    while nukesLeft > 0 and clumpCounter <= 9 do
        if table.getn(ArmyBrains[Aeon]:GetUnitsAroundPoint(categories.ALLUNITS - categories.WALL,
                                                            ScenarioUtils.MarkerToPosition('Nuke_Me_Clump_'..clumpCounter), 30, 'Enemy')) > 0 then
            IssueNuke({nukeLaunchers[3+nukesLeft]}, ScenarioUtils.MarkerToPosition('Nuke_Me_Clump_'..clumpCounter))
            nukesLeft = nukesLeft - 1
            WaitSeconds(2)
        end
        clumpCounter = clumpCounter + 1
    end

    -- Aeon Clearing Attacks
    WaitSeconds(40)
    local aeonAirGroup1 = ScenarioUtils.CreateArmyGroupAsPlatoonCoopBalanced('Aeon', 'M3A2_Air_Attack_G1_D'..ScenarioInfo.Options.Difficulty, 'ChevronFormation')
    ScenarioFramework.GroupPatrolChain(aeonAirGroup1:GetPlatoonUnits(), 'Aeon_M3_Attack_Two_Air_G1_Chain')

    local aeonAirGroup2 = ScenarioUtils.CreateArmyGroupAsPlatoonCoopBalanced('Aeon', 'M3A2_Air_Attack_G2_D'..ScenarioInfo.Options.Difficulty, 'ChevronFormation')
    ScenarioFramework.GroupPatrolChain(aeonAirGroup2:GetPlatoonUnits(), 'Aeon_M3_Attack_Two_Air_G2_Chain')

    -- Aeon Forward Base Building
    WaitSeconds(40)
    local aeonDefenseG1 = ScenarioUtils.CreateArmyGroupAsPlatoonCoopBalanced('Aeon', 'M3A2_Air_Defense_D'..ScenarioInfo.Options.Difficulty, 'ChevronFormation')
    ScenarioFramework.PlatoonPatrolChain(aeonDefenseG1, 'Aeon_M3_Attack_Two_Air_Defense_Chain')
    for i=1,ScenarioInfo.Options.Difficulty do
        local engs = ScenarioUtils.CreateArmyGroupAsPlatoonCoopBalanced('Aeon', 'M3A2_Engineers_D'..i, 'AttackFormation')
        local transports = ScenarioUtils.CreateArmyGroupAsPlatoonCoopBalanced('Aeon', 'M3A2_Transports_D'..i, 'ChevronFormation')
        ScenarioFramework.AttachUnitsToTransports(engs:GetPlatoonUnits(),transports:GetPlatoonUnits())
        ForkThread(M3MoveStartAeonEngineers, engs, transports)
    end
end

-- Move and start building forward bases with transports
function M3MoveStartAeonEngineers(engs,transports)
    local aiBrain = engs:GetBrain()
    local cmd = transports:UnloadAllAtLocation(ScenarioUtils.MarkerToPosition('Aeon_M3_Engineer_Landing_Marker'))
    while transports:IsCommandsActive(cmd) do
        WaitSeconds(2)
        if not ArmyBrains[Aeon]:PlatoonExists(transports) then
            return
        end
    end
    transports:MoveToLocation(ScenarioUtils.MarkerToPosition('Aeon_Arnold_Base'), false)
    aiBrain:AssignUnitsToPlatoon('TransportPool', transports:GetPlatoonUnits(), 'Scout', 'None')
    engs.PlatoonData.Construction = {}
    engs.PlatoonData.Construction.BaseTemplate = 'M3_Forward_Base'
    engs.PlatoonData.Construction.BuildClose = true
    engs.PlatoonData.Construction.BuildStructures = {
        'T3Artillery',
        'T2ShieldDefense',
        'T2ShieldDefense',
        'T3AADefense',
        'T3AADefense',
        'T2Artillery',
        'T2Artillery',
        'T2GroundDefense',
        'T2GroundDefense',
        'T3Artillery',
        'T2ShieldDefense',
        'T2ShieldDefense',
        'T3AADefense',
        'T3AADefense',
        'T2Artillery',
        'T2Artillery',
        'T2GroundDefense',
        'T2GroundDefense',
    }
    engs.PlatoonData.MaintainBaseTemplate = 'M3_Forward_Base'
    engs:ForkAIThread(ScenarioPlatoonAI.StartBaseEngineerThread)
end

-- Cybran take out aeon base with their own - Aeon send in a navy attack
function M3AttackWaveThree()
    WaitSeconds(M3AttackThreeDelay)

    -- Cybran Attacks
    local transports = ScenarioUtils.CreateArmyGroupAsPlatoonCoopBalanced('Cybran', 'M3A3_Transports_Assault_D'..ScenarioInfo.Options.Difficulty, 'AttackFormation')
    local units = ScenarioUtils.CreateArmyGroupAsPlatoonCoopBalanced('Cybran', 'M3A3_Land_Assault_D'..ScenarioInfo.Options.Difficulty, 'AttackFormation')
    ScenarioFramework.AttachUnitsToTransports(units:GetPlatoonUnits(), transports:GetPlatoonUnits())
    ForkThread(M3CybranLandAssault, units, transports)

    local cybAir1 = ScenarioUtils.CreateArmyGroupAsPlatoonCoopBalanced('Cybran', 'M3A3_Air_Attack_G1_D'..ScenarioInfo.Options.Difficulty, 'AttackFormation')
    ScenarioFramework.PlatoonAttackChain(cybAir1, 'Cybran_M3_Attack_Two_Land_G1_Chain')

    local soulRippers = ScenarioUtils.CreateArmyGroupAsPlatoonCoopBalanced('Cybran', 'M3A3_SoulRippers_D'..ScenarioInfo.Options.Difficulty, 'None')
    ScenarioFramework.PlatoonAttackChain(soulRippers, 'Cybran_M3_Attack_Two_Land_G1_Chain')

    local cybAir2 = ScenarioUtils.CreateArmyGroupAsPlatoonCoopBalanced('Cybran', 'M3A3_Air_Attack_G2_D'..ScenarioInfo.Options.Difficulty, 'AttackFormation')
    ScenarioFramework.PlatoonAttackChain(cybAir1, 'Cybran_M3_Attack_Three_Air_G2_Chain')

    -- Send in Aeon Navy
    local aeonNavyPlat = ScenarioUtils.CreateArmyGroupAsPlatoonCoopBalanced('Aeon', 'M3A3_Navy_Attack_D'..ScenarioInfo.Options.Difficulty, 'AttackFormation')
    for k,v in aeonNavyPlat:GetPlatoonUnits() do
        if not v:IsDead() and EntityCategoryContains(categories.uas0401, v) then
            IssueDive({v})
        end
    end
    ScenarioFramework.PlatoonAttackChain(aeonNavyPlat, 'Aeon_M3_Attack_Three_Navy_G1_Chain')

    -- Send in the Cybran Engineers
    WaitSeconds(30)
    local engTrans = ScenarioUtils.CreateArmyGroupAsPlatoonCoopBalanced('Cybran', 'M3A3_Forward_Base_Transports_D'..ScenarioInfo.Options.Difficulty, 'ChevronFormation')
    local engs = ScenarioUtils.CreateArmyGroupAsPlatoonCoopBalanced('Cybran', 'M3A3_Forward_Base_Engineers_D'..ScenarioInfo.Options.Difficulty, 'AttackFormation')
    ScenarioFramework.AttachUnitsToTransports(engs:GetPlatoonUnits(), engTrans:GetPlatoonUnits())
    ForkThread(M3MoveStartCybranEngineers, engs, engTrans)
end

-- Land assault with the cybran
function M3CybranLandAssault(units, transports)
    local aiBrain = units:GetBrain()
    local cmd = transports:UnloadAllAtLocation(ScenarioUtils.MarkerToPosition('Cybran_M3_Land_Assault_Landing_Marker'))
    while transports:IsCommandsActive(cmd) do
        WaitSeconds(2)
        if not aiBrain:PlatoonExists(transports) then
            return
        end
    end
    transports:MoveToLocation(ScenarioUtils.MarkerToPosition('Cybran_TransportReturn'), false)
    aiBrain:AssignUnitsToPlatoon('TransportPool', transports:GetPlatoonUnits(), 'Scout', 'None')
    ScenarioFramework.PlatoonAttackChain(units, 'Cybran_M3_Attack_Three_Land_Assault_Chain')
end

-- Begin building with cybran engineers
function M3MoveStartCybranEngineers(engs,transports)
    local aiBrain = engs:GetBrain()
    local cmd = transports:UnloadAllAtLocation(ScenarioUtils.MarkerToPosition('Cybran_M3_Forward_Base_Landing_Marker'))
    while transports:IsCommandsActive(cmd) do
        WaitSeconds(2)
        if not aiBrain:PlatoonExists(transports) then
            return
        end
    end
    transports:MoveToLocation(ScenarioUtils.MarkerToPosition('Cybran_TransportReturn'), false)
    aiBrain:AssignUnitsToPlatoon('TransportPool', transports:GetPlatoonUnits(), 'Scout', 'None')
    engs.PlatoonData.Construction = {}
    engs.PlatoonData.Construction.BaseTemplate = 'M3_Forward_Base'
    engs.PlatoonData.Construction.BuildClose = true
    engs.PlatoonData.Construction.BuildStructures = {
        'T3Artillery',
        'T2ShieldDefense',
        'T3Artillery',
        'T2ShieldDefense',
        'T3Artillery',
        'T2ShieldDefense',
        'T3AADefense',
        'T3AADefense',
        'T3AADefense',
        'T3AADefense',
        'T2Artillery',
        'T2Artillery',
        'T2Artillery',
        'T2Artillery',
        'T2GroundDefense',
        'T2GroundDefense',
    }
    engs.PlatoonData.MaintainBaseTemplate = 'M3_Forward_Base'
    engs:ForkAIThread(ScenarioPlatoonAI.StartBaseEngineerThread)
end

-- Navy sent 2 minutes before last Aeon attack occurs
function M3BeforeFinalAttackNavy()
    -- Aeon Navy
    local navyPlat = ScenarioUtils.CreateArmyGroupAsPlatoonCoopBalanced('Aeon', 'M3AF_Naval_Group_D'..ScenarioInfo.Options.Difficulty, 'GrowthFormation')
    ScenarioFramework.PlatoonMoveChain(navyPlat, 'Aeon_M3_Attack_Final_Naval_Chain')
    ScenarioFramework.CreatePlatoonDeathTrigger(M3ArnoldAssaultGroupDefeated, navyPlat)
end

-- when blacksun alsmost full, begin the arnold assault.
function M3FinalAttack()
    -- Turn off AMs
    ArmyBrains[Cybran]:AMPauseAttackManager()
    ArmyBrains[Aeon]:AMPauseAttackManager()

    -- Nuke the cybran outpost location
    local nukeLaunchers = {}
    for i=1,5 do
        table.insert(nukeLaunchers, ScenarioInfo.UnitNames[Aeon]['Arnold_Nuke_'..i])
    end
    if table.getn(ArmyBrains[Aeon]:GetUnitsAroundPoint(categories.ALLUNITS - categories.WALL,
                  ScenarioUtils.MarkerToPosition('Aeon_M3_Attack_Final_Nuke_Marker'), 25, 'Enemy')) > 0 then
        IssueNuke({nukeLaunchers[1]}, ScenarioUtils.MarkerToPosition('Aeon_M3_Attack_Final_Nuke_Marker'))
    end

    -- Aeon escorts and t-bombers
    local escorts = ScenarioUtils.CreateArmyGroup('Aeon', 'M3AF_Air_Escort_D'..ScenarioInfo.Options.Difficulty)-- , 'AttackFormation')
    ScenarioFramework.GroupAttackChain(escorts, 'Aeon_M3_Attack_Final_Czar_Escorts_Chain')

    local tBombers = ScenarioUtils.CreateArmyGroup('Aeon', 'M3AF_Air_Torp_Bombers_D'..ScenarioInfo.Options.Difficulty)-- , 'AttackFormation')
    ScenarioFramework.GroupAttackChain(tBombers, 'Aeon_M3_Attack_Final_Torpedo_Chain')

    -- Czar and its stored units
    local czarPlat = ScenarioUtils.CreateArmyGroupAsPlatoonCoopBalanced('Aeon', 'M3AF_Czar_D'..ScenarioInfo.Options.Difficulty, 'AttackFormation')
    local czarUnit = czarPlat:GetPlatoonUnits()[1]
    ScenarioFramework.CreatePlatoonDeathTrigger(M3CzarDestroyed, czarPlat)
    local airCzarStorage = ScenarioUtils.CreateArmyGroup('Aeon', 'M3AF_Storage_Czar_D'..ScenarioInfo.Options.Difficulty)
    local i = 1
    local j = 1
    local czarStoragePlatoons = {}
    local currPlatoon = ArmyBrains[Aeon]:MakePlatoon('','')
    while i <= table.getn(airCzarStorage) do
        if j == 21 then
            currPlatoon = ArmyBrains[Aeon]:MakePlatoon('','')
            table.insert(czarStoragePlatoons, currPlatoon)
            j = 1
        end
        ArmyBrains[Aeon]:AssignUnitsToPlatoon(currPlatoon, {airCzarStorage[i]}, 'Attack', 'ChevronFormation')
        czarUnit:AddUnitToStorage(airCzarStorage[i])
        i = i + 1
        j = j + 1
    end
    if j ~= 21 then
        table.insert(czarStoragePlatoons, currPlatoon)
    end
    for num,platoon in czarStoragePlatoons do
        ScenarioFramework.CreatePlatoonDeathTrigger(M3ArnoldAssaultGroupDefeated, platoon)
        ScenarioInfo.FinalAttackPlatoonCounter = ScenarioInfo.FinalAttackPlatoonCounter + 1
    end
    czarPlat:ForkAIThread(M3FinalAttackCzarAI, czarStoragePlatoons)

    local objectiveUnits = {}
    table.insert(objectiveUnits, czarPlat:GetPlatoonUnits()[1])
    table.insert(objectiveUnits, ScenarioInfo.ArnoldPlatoon:GetPlatoonUnits()[1])
    -- Objectives
    ScenarioInfo.M3P2Obj = Objectives.Kill('primary', 'incomplete', OpStrings.M3P2Title, OpStrings.M3P2Description,
        {
            Units = objectiveUnits,
        }
   )

    WaitSeconds(90)

    -- Land Transports
    local trans1 = ScenarioUtils.CreateArmyGroupAsPlatoonCoopBalanced('Aeon', 'M3AF_Transports_G1_D'..ScenarioInfo.Options.Difficulty, 'ChevronFormation')
    local land1 = ScenarioUtils.CreateArmyGroupAsPlatoonCoopBalanced('Aeon', 'M3AF_Land_G1_D'..ScenarioInfo.Options.Difficulty, 'AttackFormation')
    ScenarioFramework.CreatePlatoonDeathTrigger(M3ArnoldAssaultGroupDefeated, land1)
    ScenarioInfo.FinalAttackPlatoonCounter = ScenarioInfo.FinalAttackPlatoonCounter + 1
    ForkThread(M3LandAttack, trans1, land1, 1)

    local trans2 = ScenarioUtils.CreateArmyGroupAsPlatoonCoopBalanced('Aeon', 'M3AF_Transports_G2_D'..ScenarioInfo.Options.Difficulty, 'ChevronFormation')
    local land2 = ScenarioUtils.CreateArmyGroupAsPlatoonCoopBalanced('Aeon', 'M3AF_Land_G2_D'..ScenarioInfo.Options.Difficulty, 'AttackFormation')
    ScenarioFramework.CreatePlatoonDeathTrigger(M3ArnoldAssaultGroupDefeated, land2)
    ScenarioInfo.FinalAttackPlatoonCounter = ScenarioInfo.FinalAttackPlatoonCounter + 1
    ForkThread(M3LandAttack, trans2, land2, 2)

    local trans3 = ScenarioUtils.CreateArmyGroupAsPlatoonCoopBalanced('Aeon', 'M3AF_Transports_G3_D'..ScenarioInfo.Options.Difficulty, 'ChevronFormation')
    local land3 = ScenarioUtils.CreateArmyGroupAsPlatoonCoopBalanced('Aeon', 'M3AF_Land_G3_D'..ScenarioInfo.Options.Difficulty, 'AttackFormation')
    ScenarioFramework.CreatePlatoonDeathTrigger(M3ArnoldAssaultGroupDefeated, land3)
    ScenarioInfo.FinalAttackPlatoonCounter = ScenarioInfo.FinalAttackPlatoonCounter + 1
    ForkThread(M3LandAttack, trans3, land3, 3)

    ScenarioInfo.NumPlatoonsInPosition = 0
end

-- Thread for arnold and his assault. Teleports when aeon units land
function M3ArnoldAIThread(platoon)
    local aiBrain = platoon:GetBrain()
    local unit = platoon:GetPlatoonUnits()[1]
    local weapon = unit:GetWeaponByLabel('OverCharge')
    weapon:ChangeMaxRadius(20)
    local cannon = ScenarioInfo.BlackSunCannon[1]
    while not ScenarioInfo.NumPlatoonsInPosition or ScenarioInfo.NumPlatoonsInPosition < 3 do
        WaitSeconds(1)
    end
    -- IssueTeleport({unit}, ScenarioUtils.MarkerToPosition('Aeon_Arnold_Assault_Landing_Marker'))
    Warp(unit, ScenarioUtils.MarkerToPosition('Aeon_M3_Attack_Final_Arnold_Teleport_Marker'))
    unit:PlayCommanderWarpInEffect()
    WaitSeconds(1)
    platoon:Stop()
    platoon:MoveToLocation(ScenarioUtils.MarkerToPosition('Player_Attack_Black_Sun'), false)
    while aiBrain:PlatoonExists(platoon) do
        if not cannon:IsDead() and not unit:IsDead() and (Utilities.XZDistanceTwoVectors(unit:GetPosition(), cannon:GetPosition()) < 20) then
            IssueClearCommands({unit})
            IssueOverCharge({unit}, cannon)
            -- IssueAttack({unit}, cannon)
            WaitSeconds(10)
            break
        end
        WaitSeconds(1)
    end
end

function M3FinalAttackCzarAI(platoon, storedPlats)
    local czar = platoon:GetPlatoonUnits()[1]
    local cmd
    local released = false
    -- move through locations
    local posChain = ScenarioUtils.ChainToPositions('Aeon_M3_Attack_Final_Czar_Chain')
    local i = 1
    while i <= table.getn(posChain) do
        cmd = platoon:MoveToLocation(posChain[i], false)
        -- while the command is active and we haven't relased the units
        while platoon:IsCommandsActive(cmd) and not released do
            local czarPos = platoon:GetPlatoonPosition()
            local target = platoon:FindClosestUnit('attack', 'Enemy', false, categories.ALLUNITS - categories.WALL)
            local targetPos = false
            if target and not target:IsDead() then
                targetPos = target:GetPosition()
            end
            if targetPos ~= false then
                czarPos = platoon:GetPlatoonPosition()
                -- if closest non-wall is less than 100 away then release the bombers
                if VDist2(czarPos[1], czarPos[3], targetPos[1], targetPos[3]) < 100 then
                    -- LOG('*DEBUG: UNLOAD CZAR M3')
                    released = true
                    platoon:Stop()
                    IssueStop({czar})
                    IssueClearCommands({czar})
                    IssueTransportUnload({czar}, posChain[i])
                    WaitSeconds(5)
                    if not ArmyBrains[Aeon]:PlatoonExists(platoon) then
                        return
                    end
                    for num,subPlat in storedPlats do
                        subPlat:ForkAIThread(ScenarioPlatoonAI.PlatoonAttackClosestUnit)
                    end
                    platoon:MoveToLocation(posChain[i], false)
                end
            end
            WaitSeconds(3)
            if not ArmyBrains[Aeon]:PlatoonExists(platoon) then
                return
            end
        end
        i = i + 1
    end
end

function SubPlatoonAIThread(platoon)
    local aiBrain = platoon:GetBrain()
    WaitSeconds(10)
    if aiBrain:PlatoonExists(platoon) then
        ScenarioPlatoonAI.PlatoonAttackClosestUnit(platoon)
    end
end

function M3LandAttack(transports, landPlat, num)
    ScenarioFramework.AttachUnitsToTransports(landPlat:GetPlatoonUnits(), transports:GetPlatoonUnits())
    local cmd = transports:UnloadAllAtLocation(ScenarioUtils.MarkerToPosition('Aeon_M3_Attack_Final_Transport_Landing_'..num..'_Marker'))
    while transports:IsCommandsActive(cmd) do
        WaitSeconds(1)
        if not ArmyBrains[Aeon]:PlatoonExists(transports) then
            ScenarioInfo.NumPlatoonsInPosition = ScenarioInfo.NumPlatoonsInPosition + 1
            return
        end
    end
    ScenarioInfo.NumPlatoonsInPosition = ScenarioInfo.NumPlatoonsInPosition + 1
    if ArmyBrains[Aeon]:PlatoonExists(landPlat) then
        landPlat:AggressiveMoveToLocation(ScenarioUtils.MarkerToPosition('Player_Attack_Black_Sun'))
    end
    if ArmyBrains[Aeon]:PlatoonExists(landPlat) then
        transports:MoveToLocation(ScenarioUtils.MarkerToPosition('Aeon_Arnold_Base'), false)
    end
end

function M3ArnoldAssaultGroupDefeated()
    if not ScenarioInfo.M3ArnoldPlatoonsDefeated then
        ScenarioInfo.M3ArnoldPlatoonsDefeated = 1
    else
        ScenarioInfo.M3ArnoldPlatoonsDefeated = ScenarioInfo.M3ArnoldPlatoonsDefeated + 1
    end
    -- M3CheckArnoldAssaultGroups()
end

function M3CzarDestroyed()
    ScenarioInfo.M3CzarUnitDestroyed = true
    if not ScenarioInfo.AikoUnitDestroyed and ScenarioInfo.AikoUnit:GetHealthPercent() >= .5  then
        ScenarioFramework.Dialogue(OpStrings.E06_M03_080)
    else
        ScenarioFramework.Dialogue(OpStrings.E06_M03_085)
    end
-- local camInfo = {
--    blendTime = 1,
--    holdTime = 4,
--    orientationOffset = { 0, 0.5, 0 },
--    positionOffset = { 0, 0, 0 },
--    zoomVal = 120,
-- }
-- ScenarioFramework.OperationNISCamera(?, camInfo)
    M3CheckArnoldAssaultGroups()
end

function M3ArnoldDefeated(unit)
    ScenarioInfo.M3ArnoldUnitDestroyed = true
    ScenarioFramework.Dialogue(OpStrings.E06_M03_070)
-- ScenarioFramework.CDRDeathNISCamera(unit, 7)
    M3CheckArnoldAssaultGroups()
end

function M3CheckArnoldAssaultGroups()
    if ScenarioInfo.M3ArnoldUnitDestroyed and ScenarioInfo.M3CzarUnitDestroyed then
        if not ScenarioInfo.CannonTransfered then
            ScenarioInfo.CannonTransfered = true
            if not ScenarioInfo.M3ChargeComplete then
                Objectives.UpdateBasicObjective(ScenarioInfo.M1P1Obj, 'progress', OpStrings['M3P1Progress20'])
                ScenarioInfo.M3ChargeComplete = true
                for k,v in ScenarioInfo.BlackSunCannon do
                    v:SetWorkProgress(1)
                end
                if not ScenarioInfo.AikoUnitDestroyed and ScenarioInfo.AikoUnit:GetHealthPercent() >= .5  then
                    ScenarioFramework.Dialogue(OpStrings.E06_M03_066)
                else
                    ScenarioFramework.Dialogue(OpStrings.E06_M03_067)
                end
            end
            ScenarioInfo.M3P3Obj = Objectives.Basic('primary', 'incomplete', OpStrings.M3P3Title, OpStrings.M3P3Description, Objectives.GetActionIcon('kill'),
                {
                    Units = ScenarioInfo.BlackSunCannon,
                }
           )
            ScenarioFramework.Dialogue(ScenarioStrings.NewPObj)
            ForkThread(M3TransferCannon)
        end
    end
end

function M3TransferCannon()
    ScenarioFramework.Dialogue(OpStrings.E06_M03_090, false, true)
    for num, unit in ScenarioInfo.BlackSunCannon do
        if not unit:IsDead() then
            unit:AddToggleCap('RULEUTC_SpecialToggle')
            unit:SetCanTakeDamage(false)
            unit:SetCanBeKilled(false)
            unit:AddSpecialToggleEnable(M3BlackSunFired)
            unit:AddSpecialToggleDisable(M3BlackSunFired)
        end
        -- Blacksun Ready to Fire cam
        local camInfo = {
            blendTime = 1,
            holdTime = 4,
            orientationOffset = { 2.3, 0.7, 0 },
            positionOffset = { 0, 1, 0 },
            zoomVal = 65,
            overrideCam = true,
        }
        ScenarioFramework.OperationNISCamera(ScenarioInfo.BlackSunCannon[1], camInfo)
    end
end

function M3BlackSunFired(unit)
    if not ScenarioInfo.BlackSunFiredBool then
        ScenarioInfo.BlackSunFiredBool = true
        ForkThread(EndMission3)
    end
end

-- Player winz
function EndMission3()
    ScenarioFramework.EndOperationSafety()
    if ScenarioInfo.M1P1Obj then
        ScenarioInfo.M1P1Obj:ManualResult(true)
    end
    if ScenarioInfo.M3P3Obj then
        ScenarioInfo.M3P3Obj:ManualResult(true)
    end
    -- ScenarioFramework.PlayEndGameMovie(1 , WinGame)
    WinGame()
end




-- === WIN LOSS FUNCTIONS === #
function WinGame()
    ScenarioInfo.OpComplete = true
    local secondaries = true
    -- local bonus = Objectives.IsComplete(ScenarioInfo.KillBonus) and Objectives.IsComplete(ScenarioInfo.ExperimentalBonus)
    ScenarioFramework.EndOperation(ScenarioInfo.OpComplete, ScenarioInfo.OpComplete, secondaries)
end

function LoseGame()
    ScenarioInfo.OpComplete = false
    WaitSeconds(5)
    ScenarioFramework.EndOperation(ScenarioInfo.OpComplete, ScenarioInfo.OpComplete, false)
end

function PlayerCommanderDestroyed(unit)
-- ScenarioFramework.EndOperationCamera(unit)
    ScenarioFramework.CDRDeathNISCamera(unit)
    ScenarioInfo.CDRDeath = true
    if not ScenarioInfo.BlackSunDestroyed then
        ScenarioFramework.EndOperationSafety()
        ScenarioFramework.FlushDialogueQueue()
        ScenarioFramework.Dialogue(OpStrings.E06_D01_010, false, true)
        ScenarioFramework.Dialogue(ScenarioStrings.CDRKilled, LoseGame, true)
    end
end

function AikoDestroyed()
    ScenarioInfo.AikoUnitDestroyed = true
    ScenarioFramework.Dialogue(OpStrings.E06_M01_040)
    ScenarioFramework.CDRDeathNISCamera(ScenarioInfo.AikoUnit, 7)
end

function BlackSunCannonDestroyed(unit)
-- ScenarioFramework.EndOperationCamera(unit)
    local camInfo = {
        blendTime = 2.5,
        holdTime = nil,
        orientationOffset = { math.pi, 0.7, 0 },
        positionOffset = { 0, 1, 0 },
        zoomVal = 65,
        spinSpeed = 0.03,
        overrideCam = true,
    }
    ScenarioFramework.OperationNISCamera(unit, camInfo)

    ScenarioInfo.BlackSunDestroyed = true
    if not ScenarioInfo.CDRDeath then
        ScenarioFramework.EndOperationSafety()
        ScenarioFramework.FlushDialogueQueue()
        ScenarioFramework.Dialogue(OpStrings.E06_M02_110, false, true)
        ScenarioFramework.Dialogue(ScenarioStrings.PObjFail, LoseGame, true)
    end
end



-- === DEBUG FUNCTIONS === #
-- function OnF3()
-- #LOG('*SCENARIO DEBUG: Player Unit Cap: ', repr(GetArmyUnitCostTotal(Player)))
-- #LOG('*SCENARIO DEBUG: Aeon Unit Cap: ', repr(GetArmyUnitCostTotal(Aeon)))
-- #LOG('*SCENARIO DEBUG: Cybran Unit Cap: ', repr(GetArmyUnitCostTotal(Cybran)))
-- #LOG('*SCENARIO DEBUG: BlackSun Unit Cap: ', repr(GetArmyUnitCostTotal(BlackSun)))
-- #LOG('*SCENARIO DEBUG: Component Unit Cap: ', repr(GetArmyUnitCostTotal(Component)))
-- ScenarioUtils.CreateArmyGroup('Player', 'NavalWestDEBUG')
-- end

-- function OnShiftF3()
-- #ScenarioUtils.CreateArmyGroup('Player', 'NavalEastDEBUG')
-- BPlayerBuiltExperimentals()
-- BPlayerKill500Enemy()
-- end

-- function OnCtrlF3()
-- ScenarioUtils.CreateArmyGroup('Player', 'AirDEBUG')
-- end

-- function OnF4()
-- for k,v in ScenarioInfo.BlackSunEscortsPlatoon:GetPlatoonUnits() do
--    if not v:IsDead() then
--        v:Destroy()
--    end
-- end
-- for k,v in ScenarioInfo.AeonIntroAirPlatoon:GetPlatoonUnits() do
--    if not v:IsDead() then
--        v:Destroy()
--    end
-- end
-- for k,v in ScenarioInfo.AeonIntroNavalPlatoon:GetPlatoonUnits() do
--    if not v:IsDead() then
--        v:Destroy()
--    end
-- end
-- StartMission2()
-- M2NukeAttackStart()
-- end

function OnShiftF3()
-- for num,unit in ArmyBrains[Aeon]:GetListOfUnits(categories.uab2305, false) do
--    unit:GiveNukeSiloAmmo(3)
-- end
-- for num,unit in ArmyBrains[Player]:GetListOfUnits(categories.ueb4302, false) do
--    if unit:GetTacticalSiloAmmoCount() < 5 then
--        unit:GiveTacticalSiloAmmo(1)
--    end
-- end
-- M2NukeAttackStart()
-- M2AeonNukeClump()
-- EndMission2()
    M3BlackSunFired()
end

-- # Allowed restrictions
      for _, player in ScenarioInfo.HumanPlayers do
       -- ScenarioFramework.RemoveRestriction(ArmyBrains[player], categories.ueb2302 +
       --                                            categories.ueb4301 +
       --                                            categories.uel0401 +
       --                                            categories.ues0304 )
      end
-- end

function OnCtrlF4()
    ForkThread(M3FinalAttack)
end

function OnF5()
    ScenarioInfo.M3ChargeCounter = 15
    ForkThread(StartMission3)
end
--
-- function OnF5Thread()
-- local newUnits = {}
-- for num, unit in ScenarioInfo.BlackSunCannon do
--    table.insert(newUnits, ScenarioFramework.GiveUnitToArmy(unit, Player))
-- end
-- ScenarioInfo.BlackSunCannon = newUnits
-- WaitTicks(1)
-- for num, unit in ScenarioInfo.BlackSunCannon do
--    if not unit:IsDead() then
--        unit:AddSpecialToggleEnable(M3BlackSunFired)
--    end
-- end
-- end

-- function OnShiftF5()
-- for i=1,10 do
--     CreateUnitHPR('uel0303', 'Player', 512,30,512+i, 0,0,0)
-- end
-- for i=1,10 do
--     CreateUnitHPR('uel0303', 'Player', 514,30,512+i, 0,0,0)
-- end
-- end

-- function MoveTimer()
-- local recTable = {}
-- table.insert(recTable,ScenarioUtils.AreaToRect('TimingRect'))
-- local tickCounter = 0
-- local category = categories.NAVAL * categories.MOBILE
-- local aiBrain = ArmyBrains[Cybran]
-- while true do
--     local amount = 0
--     local totalEntities = {}
--     for k, v in recTable do
--         local entities = GetUnitsInRect(v)
--         if entities then
--             for ke, ve in entities do
--                 totalEntities[table.getn(totalEntities) + 1] = ve
--             end
--         end
--     end
--     local triggered = false
--     local triggeringEntity
--     local numEntities = table.getn(totalEntities)
--     if numEntities > 0 then
--         for k, v in totalEntities do
--             local contains = EntityCategoryContains(category, v)
--             if contains and (aiBrain and v:GetAIBrain() == aiBrain) then
--                 triggered = true
--                 break
--             end
--         end
--     end
--     if triggered then
--         break
--     end
--     tickCounter = tickCounter + 1
--     WaitTicks(1)
-- end
-- #LOG('*DEBUG: UNITS AT TEST AREA IN '..tickCounter..' TICKS')
-- end

function OnCtrlAltF5()
    ScenarioFramework.EndOperation(ScenarioInfo.OpComplete, ScenarioInfo.OpComplete, secondaries)
end
