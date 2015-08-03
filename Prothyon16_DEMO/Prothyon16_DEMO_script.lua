# Custom Mission
# Author: speed2

local BaseManager = import('/lua/ai/opai/basemanager.lua')
local Buff = import('/lua/sim/Buff.lua')
local Cinematics = import('/lua/cinematics.lua')
local EffectUtilities = import('/lua/effectutilities.lua')
local M1UEFAI = import('/maps/Prothyon16_DEMO/Prothyon16_DEMO_m1uefai.lua')
local M2UEFAI = import('/maps/Prothyon16_DEMO/Prothyon16_DEMO_m2uefai.lua')
local M3UEFAI = import('/maps/Prothyon16_DEMO/Prothyon16_DEMO_m3uefai.lua')
local Objectives = import('/lua/ScenarioFramework.lua').Objectives
local OpStrings = import('/maps/Prothyon16_DEMO/Prothyon16_DEMO_strings.lua')
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local Utilities = import('/lua/utilities.lua')
local TauntManager = import('/lua/TauntManager.lua')

# -------
# Globals
# -------

# Army IDs
ScenarioInfo.Player = 1
ScenarioInfo.UEF = 2
ScenarioInfo.UEFAlly = 3
ScenarioInfo.Objective = 4
ScenarioInfo.Seraphim = 5
ScenarioInfo.Coop1 = 6
ScenarioInfo.Coop2 = 7
ScenarioInfo.Coop3 = 8
ScenarioInfo.HumanPlayers = {}

# ------
# Locals
# ------
local Player = ScenarioInfo.Player
local UEF = ScenarioInfo.UEF
local UEFAlly = ScenarioInfo.UEFAlly
local Objective = ScenarioInfo.Objective
local Seraphim = ScenarioInfo.Seraphim
local Coop1 = ScenarioInfo.Coop1
local Coop2 = ScenarioInfo.Coop2
local Coop3 = ScenarioInfo.Coop3

local AssignedObjectives = {}

local ReminderTaunts = {
        {OpStrings.HQcapremind1, 0},
        {OpStrings.HQcapremind2, 0},
        {OpStrings.HQcapremind3, 0},
        {OpStrings.HQcapremind4, 0},
}

# -----------
# Debug only!
# -----------
local SkipNIS1 = false
local SkipNIS2 = false
local SkipNIS3 = false

# How long should we wait at the beginning of the NIS to allow slower machines to catch up?
local NIS1InitialDelay = 3

# -------
# Startup
# -------
function OnPopulate(scenario)
    ScenarioUtils.InitializeScenarioArmies()

    # Sets Army Colors
    ScenarioFramework.SetUEFPlayerColor(Player)
	ScenarioFramework.SetUEFAllyColor(UEF)
    SetArmyColor('UEFAlly', 71, 134, 226)
    SetArmyColor('Objective', 71, 134, 226)

    # Unit cap
    SetArmyUnitCap(UEF, 1000)

    # Spawn Player initial base
    ScenarioUtils.CreateArmyGroup('Player', 'Starting Base')
    ScenarioInfo.Gate = ScenarioUtils.CreateArmyUnit('Player', 'Gate')
    ScenarioInfo.Gate:SetReclaimable(false)

    # ----------
    # M1 UEF AI
    # ----------
    M1UEFAI.UEFM1WestBaseAI()
    M1UEFAI.UEFM1EastBaseAI()
    ArmyBrains[UEF]:GiveResource('MASS', 4000)
    ArmyBrains[UEF]:GiveResource('ENERGY', 6000)

    # Walls
    ScenarioInfo.M1_Walls = ScenarioUtils.CreateArmyGroup('UEF', 'M1_Walls')

    -----------------
    # Initial Patrols
    -----------------
    local units = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'EastBaseAirDef', 'GrowthFormation')
    for k, v in units:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M1_East_Base_Air_Defence_Chain')))
    end

    units = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'EastBaseLandDef', 'GrowthFormation')
    for k, v in units:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolChain({v}, 'M1_East_Defence_Chain1')
    end

    units = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'WestBaseAirDef', 'GrowthFormation')
    for k, v in units:GetPlatoonUnits() do
        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M1_WestBase_Air_Def_Chain')))
    end

    # ------------------------
    # Cheat Economy/Buildpower
    # ------------------------
    buffDef = Buffs['CheatIncome']
    buffAffects = buffDef.Affects
    buffAffects.EnergyProduction.Mult = 1
    buffAffects.MassProduction.Mult = 1.5
       
        for _, u in GetArmyBrain(UEF):GetPlatoonUniquelyNamed('ArmyPool'):GetPlatoonUnits() do
                Buff.ApplyBuff(u, 'CheatIncome')
                --Buff.ApplyBuff(u, 'CheatBuildRate')
        end

    # --------------------
    # Objective Structures
    # --------------------
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

    # Other Structures
    ScenarioInfo.M1_Other_Buildings = ScenarioUtils.CreateArmyGroup('Objective', 'M1_Other_Buildings')
    for k,v in ScenarioInfo.M1_Other_Buildings do
        v:SetCapturable(false)
        v:SetReclaimable(false)
        v:SetCanTakeDamage(false)
        v:SetCanBeKilled(false)
    end
end

function OnStart(scenario)
    # ------------------
    # Build Restrictions
    # ------------------
    for _, player in ScenarioInfo.HumanPlayers do
         ScenarioFramework.AddRestriction(player, categories.TECH2 + categories.TECH3 + categories.EXPERIMENTAL)
    end

    for _, player in ScenarioInfo.HumanPlayers do
         ScenarioFramework.AddRestriction(player, categories.SERAPHIM * categories.TECH3 + categories.SERAPHIM * categories.EXPERIMENTAL)
    end
    
    # Lock off cdr upgrades
    for _, player in ScenarioInfo.HumanPlayers do
    	ScenarioFramework.RestrictEnhancements({'ResourceAllocation',
                                            	'DamageStablization',
                                            	'AdvancedEngineering',
                                            	'T3Engineering',
                                            	'HeavyAntiMatterCannon',
                                            	'LeftPod',
                                            	'RightPod',
                                            	'Shield',
                                            	'ShieldGeneratorField',
                                            	'TacticalMissile',
                                            	'TacticalNukeMissile',
                                            	'Teleporter'})
    end

    Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_1_1'), 0)

    ForkThread(IntroMission1NIS)
end

# --------
# End Game
# --------
function PlayerWin()
    if(not ScenarioInfo.OpEnded) then
        ScenarioInfo.OpComplete = true
        KillGame()
    end
end

function PlayerLoseToAI()
    if(not ScenarioInfo.OpEnded) and (ScenarioInfo.MissionNumber <= 3) then
        IssueClearCommands({ScenarioInfo.PlayerCDR})
        #ScenarioInfo.CDRPlatoon:Stop()
        for _, player in ScenarioInfo.HumanPlayers do
                    SetAlliance(player, UEF, 'Neutral')
                    SetAlliance(UEF, player, 'Neutral')
        end
        local units = ArmyBrains[Player]:GetListOfUnits(categories.ALLUNITS - categories.FACTORY, false)
        IssueClearCommands(units)
        units = ArmyBrains[UEF]:GetListOfUnits(categories.ALLUNITS - categories.FACTORY, false)
        IssueClearCommands(units)
        ScenarioFramework.CDRDeathNISCamera(ScenarioInfo.PlayerCDR)
        ScenarioFramework.EndOperationSafety()
        ScenarioInfo.OpComplete = false
        for k, v in AssignedObjectives do
            if(v and v.Active) then
                v:ManualResult(false)
            end
        end
        ScenarioFramework.Dialogue(OpStrings.PlayerLoseToAI, KillGame, true)
    end
end

function PlayerDeath()
    if(not ScenarioInfo.OpEnded) then
        ScenarioFramework.CDRDeathNISCamera(ScenarioInfo.PlayerCDR)
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
        KillGame()
    end
end

function KillGame()
    UnlockInput()
    ScenarioFramework.EndOperation(ScenarioInfo.OpComplete, ScenarioInfo.OpComplete)
end

# ---------
# Intro NIS
# ---------
function IntroMission1NIS()
    ScenarioFramework.SetPlayableArea('M1_Area', false)

    if not SkipNIS1 then
        Cinematics.EnterNISMode()

        local VisMarker1_1 = ScenarioFramework.CreateVisibleAreaLocation(30, ScenarioUtils.MarkerToPosition('M1_Vis_1_1'), 0, ArmyBrains[Player])
        local VisMarker1_2 = ScenarioFramework.CreateVisibleAreaLocation(50, ScenarioUtils.MarkerToPosition('M1_Vis_1_2'), 0, ArmyBrains[Player])
        local VisMarker1_3 = ScenarioFramework.CreateVisibleAreaLocation(20, ScenarioUtils.MarkerToPosition('M1_Vis_1_3'), 0, ArmyBrains[Player])


        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_1_1'), 0)

        # Let slower machines catch up before we get going
        WaitSeconds(NIS1InitialDelay)

        WaitSeconds(1)
        ScenarioFramework.Dialogue(OpStrings.intro1, nil, true)

        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_1_2'), 15)

        ScenarioFramework.Dialogue(OpStrings.intro2, nil, true)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_1_3'), 3)
        WaitSeconds(3)
        ScenarioFramework.Dialogue(OpStrings.intro3, nil, true)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_1_4'), 7)
        WaitSeconds(3)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_1_5'), 3)

        ForkThread(
            function()
                WaitSeconds(2)
                VisMarker1_1:Destroy()
                VisMarker1_2:Destroy()
                VisMarker1_3:Destroy()
                WaitSeconds(2)
                ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('M1_Vis_1_1'), 40)
                ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('M1_Vis_1_2'), 60)
                ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('M1_Vis_1_3'), 30)
            end
       )

        ScenarioInfo.PlayerCDR = ScenarioUtils.CreateArmyUnit('Player', 'Commander')
    	#ScenarioInfo.PlayerCDR:PlayCommanderWarpInEffect()
    	#ScenarioFramework.FakeGateInUnit(ScenarioInfo.PlayerCDR)
        #ScenarioFramework.PauseUnitDeath(ScenarioInfo.PlayerCDR)
        #ScenarioFramework.CreateUnitDeathTrigger(PlayerDeath, ScenarioInfo.PlayerCDR)
        ScenarioFramework.CreateUnitDamagedTrigger(PlayerLoseToAI, ScenarioInfo.PlayerCDR, .99)
        ScenarioInfo.PlayerCDR:SetCanBeKilled(false)

        local cmd = IssueMove({ScenarioInfo.PlayerCDR}, ScenarioUtils.MarkerToPosition('Commander_Walk_1'))
        ScenarioFramework.FakeGateInUnit(ScenarioInfo.PlayerCDR)

        -- spawn coop players too
    	ScenarioInfo.CoopCDR = {}
    	local tblArmy = ListArmies()
    	coop = 1
    	for iArmy, strArmy in pairs(tblArmy) do
        	if iArmy >= ScenarioInfo.Coop1 then
            	ScenarioInfo.CoopCDR[coop] = ScenarioUtils.CreateArmyUnit(strArmy, 'Commander')
                IssueMove({ScenarioInfo.CoopCDR[coop]}, ScenarioUtils.MarkerToPosition('Commander_Walk_1'))
            	#ScenarioInfo.CoopCDR[coop]:PlayCommanderWarpInEffect()
            	ScenarioFramework.FakeGateInUnit(ScenarioInfo.CoopCDR[coop])
                ScenarioFramework.CreateUnitDamagedTrigger(PlayerLoseToAI, ScenarioInfo.CoopCDR[coop], .99)
                ScenarioInfo.CoopCDR[coop]:SetCanBeKilled(false)
            	coop = coop + 1
            	WaitSeconds(0.5)
        	end
    	end

        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_1_6'), 3)
        WaitSeconds(1)
        ScenarioFramework.Dialogue(OpStrings.postintro, nil, true)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_1_7'), 2)

        Cinematics.ExitNISMode()
			
    else
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_1_7'), 0)

        ScenarioInfo.PlayerCDR = ScenarioUtils.CreateArmyUnit('Player', 'Commander')
    	#ScenarioInfo.PlayerCDR:PlayCommanderWarpInEffect()
    	#ScenarioFramework.FakeGateInUnit(ScenarioInfo.PlayerCDR)
        #ScenarioFramework.PauseUnitDeath(ScenarioInfo.PlayerCDR)
        #ScenarioFramework.CreateUnitDeathTrigger(PlayerDeath, ScenarioInfo.PlayerCDR)
        ScenarioFramework.CreateUnitDamagedTrigger(PlayerLoseToAI, ScenarioInfo.PlayerCDR, .99)
        ScenarioInfo.PlayerCDR:SetCanBeKilled(false)

        local cmd = IssueMove({ScenarioInfo.PlayerCDR}, ScenarioUtils.MarkerToPosition('Commander_Walk_1'))
        ScenarioFramework.FakeGateInUnit(ScenarioInfo.PlayerCDR)

        -- spawn coop players too
    	ScenarioInfo.CoopCDR = {}
    	local tblArmy = ListArmies()
    	coop = 1
    	for iArmy, strArmy in pairs(tblArmy) do
        	if iArmy >= ScenarioInfo.Coop1 then
            	ScenarioInfo.CoopCDR[coop] = ScenarioUtils.CreateArmyUnit(strArmy, 'Commander')
                IssueMove({ScenarioInfo.CoopCDR[coop]}, ScenarioUtils.MarkerToPosition('Commander_Walk_1'))
            	#ScenarioInfo.CoopCDR[coop]:PlayCommanderWarpInEffect()
            	ScenarioFramework.FakeGateInUnit(ScenarioInfo.CoopCDR[coop])
                ScenarioFramework.CreateUnitDamagedTrigger(PlayerLoseToAI, ScenarioInfo.CoopCDR[coop], .99)
                ScenarioInfo.CoopCDR[coop]:SetCanBeKilled(false)
            	coop = coop + 1
            	WaitSeconds(0.5)
        	end
    	end

        WaitSeconds(0.1)
    end

    IntroMission1()
end

# ---------
# Mission 1
# ---------
function IntroMission1()
    ScenarioInfo.MissionNumber = 1

    StartMission1()
end

function StartMission1()
    # --------------------------------------------
    # Primary Objective 1 - Destroy First UEF Base
    # --------------------------------------------
    ScenarioInfo.M1P1 = Objectives.CategoriesInArea(
        'primary',                      # type
        'incomplete',                   # complete
        'Destroy UEF Forward Bases',                 # title
        'Eliminate the marked UEF structures to establish a foothold on the main island.',  # description
        'kill',                         # action
        {                               # target
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
                ForkThread(UEFBattleships)
                ForkThread(UEFFlyover)
                # ScenarioFramework.Dialogue(OpStrings., IntroMission2, true)       # Will get added once done
                IntroMission2()
            end
        end
    )
    table.insert(AssignedObjectives, ScenarioInfo.M1P1)
    ScenarioFramework.CreateTimerTrigger(M1P1Reminder1, 15*60)

    # Feedback dialogue when the first base is destroyed
    ScenarioInfo.M1BaseDialoguePlayer = false
    ScenarioFramework.CreateAreaTrigger(M1FirstBaseDestroyed, ScenarioUtils.AreaToRect('M1_UEF_WestBase_Area'),
        categories.UEF * categories.FACTORY, true, true, ArmyBrains[UEF])

    # ---------------------------------------------
    # Secondary Objective 1 - Capture Tech Centre
    # ---------------------------------------------
    ScenarioInfo.M1S1 = Objectives.Capture(
        'secondary',                      # type
        'incomplete',                   # complete
        'Capture Economy Tech Centre',  # title
        'Capture this building to gain access to T2 Economy.',  # description
        {
            Units = {ScenarioInfo.M1_Eco_Tech_Centre},
            FlashVisible = true,
        }
    )
    ScenarioInfo.M1S1:AddResultCallback(
        function(result)
            if(result) then
                ScenarioFramework.PlayUnlockDialogue()
                
                ScenarioFramework.RemoveRestrictionForAllHumans(categories.TECH2 * categories.STRUCTURE 
                                                                                    - categories.ueb2108    # TML
                                                                                    - categories.ueb2303    # T2 Arty
                                                                                    - categories.ueb0203    # T2 NAval HQ
                                                                                    - categories.ueb2301    # T2 PD
                                                                                    - categories.ueb0202)   # T2 Air HQ
                ScenarioFramework.RemoveRestrictionForAllHumans(categories.uel0208 + categories.xel0209)    # T2 Engineer and Sparky
                for _, player in ScenarioInfo.HumanPlayers do
                    ScenarioFramework.RestrictEnhancements({'ResourceAllocation',
                                                            'DamageStablization',
                                                            'T3Engineering',
                                                            'Shield',
                                                            'ShieldGeneratorField',
                                                            'TacticalMissile',
                                                            'TacticalNukeMissile',
                                                            'Teleporter'})
                end
            end
        end
    )
    table.insert(AssignedObjectives, ScenarioInfo.M1S1)
    ScenarioFramework.CreateTimerTrigger(M1S1Reminder, 20*60)

    # ---------------------------------------------
    # Secondary Objective 2 - Capture Tech Centre
    # ---------------------------------------------
    ScenarioInfo.M1S2 = Objectives.Capture(
        'secondary',                      # type
        'incomplete',                   # complete
        'Capture T2 Land Tech Centre',  # title
        'Capture this building to gain access to T2 Land units.',  # description
        {
            Units = {ScenarioInfo.M1_T2_Land_Tech_Centre},
            FlashVisible = true,
        }
    )
    ScenarioInfo.M1S2:AddResultCallback(
        function(result)
            if(result) then
                ScenarioFramework.PlayUnlockDialogue()
                ScenarioFramework.RemoveRestrictionForAllHumans((categories.TECH2 * categories.LAND 
                                                                            - categories.uel0111    # MML
                                                                            - categories.uel0205    # Mobile Flak
                                                                            - categories.uel0307))  # Mobile Shield
            end
        end
    )
    table.insert(AssignedObjectives, ScenarioInfo.M1S2)
    ScenarioFramework.CreateTimerTrigger(M1S2Reminder, 20*60)
end

function M1FirstBaseDestroyed()
    if ScenarioInfo.M1BaseDialoguePlayer == false and ScenarioInfo.M1P1.Active then
        ScenarioInfo.M1BaseDialoguePlayer = true
        ScenarioFramework.Dialogue(OpStrings.base1killed)
        ScenarioFramework.CreateTimerTrigger(M1P1Reminder3, 20*60)
    end
end

# ---------
# Mission 2
# ---------
function IntroMission2()
    ForkThread(
        function()

            M2UEFAI.UEFM2SouthBaseAI()
            ArmyBrains[UEF]:GiveResource('MASS', 4000)
            ArmyBrains[UEF]:GiveResource('ENERGY', 8000)

            # UEF Forward buildings
            ScenarioInfo.Forward_Structures = ScenarioUtils.CreateArmyGroup('UEF', 'Forward_Structures')

            -----------------
            # Initial Patrols
            -----------------
            local units = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M2_SouthBaseAirDef', 'GrowthFormation')
            for k, v in units:GetPlatoonUnits() do
                ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M2_SouthBase_Air_Def_Chain')))
            end

            units = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M2_SouthBaseLandDef1', 'GrowthFormation')
            for k, v in units:GetPlatoonUnits() do
                ScenarioFramework.GroupPatrolChain({v}, 'M2_SouthBase_Land_Def_Chain1')
            end

            units = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M2_SouthBaseLandDef2', 'GrowthFormation')
            for k, v in units:GetPlatoonUnits() do
                ScenarioFramework.GroupPatrolChain({v}, 'M2_SouthBase_Land_Def_Chain2')
            end

            units = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M2_SouthBaseLandDef3', 'GrowthFormation')
            for k, v in units:GetPlatoonUnits() do
                ScenarioFramework.GroupPatrolChain({v}, 'M2_SouthBase_Land_Def_Chain2')
            end

            for i = 1, 6 do
                ScenarioInfo.Engineer = ScenarioUtils.CreateArmyUnit('UEF', 'M2_SouthBase_Engi' .. i)
                local platoon = ArmyBrains[UEF]:MakePlatoon('', '')
                ArmyBrains[UEF]:AssignUnitsToPlatoon(platoon, {ScenarioInfo.Engineer}, 'Attack', 'GrowthFormation')
                ScenarioFramework.PlatoonPatrolChain(platoon, 'M2_SouthBase_Land_Attack_Chain' .. i)
            end

            -----------------
            # Initial Attacks
            -----------------
            # Land Attacks - spawning now because it takes a while for land units to move
            for i = 1, 6 do
                units = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M2_SouthBaseInitAttack' .. i, 'AttackFormation')
                ScenarioFramework.PlatoonPatrolChain(units, 'M2_SouthBase_Land_Attack_Chain' .. i)
            end

            ScenarioInfo.MissionNumber = 2

            # --------------------
            # Objective Structures
            # --------------------
            ScenarioInfo.M2_T2_Air_Tech_Centre = ScenarioUtils.CreateArmyUnit('Objective', 'M2_T2_Air_Tech_Centre')
            ScenarioInfo.M2_T2_Air_Tech_Centre:SetDoNotTarget(true)
            ScenarioInfo.M2_T2_Air_Tech_Centre:SetCanTakeDamage(false)
            ScenarioInfo.M2_T2_Air_Tech_Centre:SetCanBeKilled(false)
            ScenarioInfo.M2_T2_Air_Tech_Centre:SetReclaimable(false)
            ScenarioInfo.M2_T2_Air_Tech_Centre:SetCustomName("T2 Air Tech Centre")

            #-----------------
            # Other Structures
            #-----------------
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

            # ------------------------
            # Cheat Economy/Buildpower
            # ------------------------
            buffAffects.EnergyProduction.Mult = 1
            buffAffects.MassProduction.Mult = 1.8
           
            for _, u in GetArmyBrain(UEF):GetPlatoonUniquelyNamed('ArmyPool'):GetPlatoonUnits() do
                    Buff.ApplyBuff(u, 'CheatIncome')
                    --Buff.ApplyBuff(u, 'CheatBuildRate')
            end
            
            ForkThread(IntroMission2NIS)
        end
    )
end

function IntroMission2NIS()
    ScenarioFramework.SetPlayableArea('M2_Area', false)
    if not SkipNIS2 then
        Cinematics.EnterNISMode()
        Cinematics.SetInvincible( 'M2_Area' )

        local VisMarker2_1 = ScenarioFramework.CreateVisibleAreaLocation(40, ScenarioUtils.MarkerToPosition('M2_Vis_1'), 0, ArmyBrains[Player])
        local VisMarker2_2 = ScenarioFramework.CreateVisibleAreaLocation(40, ScenarioUtils.MarkerToPosition('M2_Vis_2'), 0, ArmyBrains[Player])
        local VisMarker2_3 = ScenarioFramework.CreateVisibleAreaLocation(40, ScenarioUtils.MarkerToPosition('M2_Vis_3'), 0, ArmyBrains[Player])

        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_2_1'), 0)
        ScenarioFramework.Dialogue(OpStrings.southbase1, nil, true)
        WaitSeconds(3)
        #Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_2_2'), 4)
        #Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_2_3'), 3)
        #Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_2_4'), 4)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_2_5'), 10)
        ScenarioFramework.Dialogue(OpStrings.southbase2, nil, true)
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_2_6'), 3)
        ForkThread(
            function()
                WaitSeconds(1)
                VisMarker2_1:Destroy()
                VisMarker2_2:Destroy()
                VisMarker2_3:Destroy()
                WaitSeconds(1)
                ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('M2_Vis_1'), 50)
                ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('M2_Vis_2'), 50)
                ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('M2_Vis_3'), 50)
            end
        )
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_2_7'), 3)
        WaitSeconds(2)
        
        Cinematics.SetInvincible( 'M2_Area', true )
        Cinematics.ExitNISMode()
                            
    else
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_2_7'), 0)

        WaitSeconds(0.1)
    end
    M2InitialAirAttack()
    StartMission2()
end

function M2InitialAirAttack()

    # If player > 100 units, spawns Bombers for every 20 land units, up to 6 groups
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

    # Spawns Interceptors for every 10 Air units, up to 5 groups
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
    # ----------------------------------------
    # Primary Objective 1 - Destroy Enemy Base
    # ----------------------------------------
    ScenarioInfo.M2P1 = Objectives.CategoriesInArea(
        'primary',                      # type
        'incomplete',                   # complete
        'Eliminate Southern Base',                 # title
        'Destroy the marked UEF structures.',  # description
        'kill',                         # action
        {                               # target
            MarkUnits = true,
            Requirements = {
                {   
                    Area = 'M2_UEF_SouthBase_Area',
                    Category = categories.FACTORY + categories.ueb1302 + (categories.TECH2 * categories.ECONOMIC),    # T3 Mex
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
                ScenarioFramework.Dialogue(OpStrings.airbase1, IntroMission3)
                # IntroMission3 ()
            end
        end
    )
    table.insert(AssignedObjectives, ScenarioInfo.M2P1)
    ScenarioFramework.CreateTimerTrigger(M2P1Reminder1, 15*60)

    # Secondary Objectives
    ScenarioFramework.CreateArmyIntelTrigger(M2SecondaryTitans, ArmyBrains[Player], 'LOSNow', false, true, categories.uel0303, true, ArmyBrains[UEF])
    ScenarioFramework.Dialogue(OpStrings.airhqtechcentre, M2SecondaryCaptureTech)
end

function M2SecondaryCaptureTech()
    # -------------------------------------------
    # Secondary Objective 3 - Capture Tech Centre
    # -------------------------------------------
    ScenarioInfo.M2S1 = Objectives.Capture(
        'secondary',                      # type
        'incomplete',                   # complete
        'Capture T2 Air Tech Centre',  # title
        'Capture this building to gain access to T2 Air units.',  # description
        {
            Units = {ScenarioInfo.M2_T2_Air_Tech_Centre},
            FlashVisible = true,
        }
    )
    ScenarioInfo.M2S1:AddResultCallback(
        function(result)
            if(result) then
                ScenarioFramework.PlayUnlockDialogue()
                ScenarioFramework.RemoveRestrictionForAllHumans(categories.TECH2 * categories.AIR 
                                                                            + categories.uel0111    # MML
                                                                            + categories.uel0205    # Mobile Flak
                                                                            + categories.uel0307)   # Mobile Shield
            end
        end
    )
    table.insert(AssignedObjectives, ScenarioInfo.M2S1)
    ScenarioFramework.CreateTimerTrigger(M2S1Reminder, 20*60)
end

function M2SecondaryTitans()
    ScenarioFramework.Dialogue(OpStrings.titankill)
    local units = ScenarioFramework.GetCatUnitsInArea(categories.uel0303, 'M2_Area', ArmyBrains[UEF])
    # -----------------------------------
    # Secondary Objective 4 - Kill Titans
    # -----------------------------------
    ScenarioInfo.M2S2 = Objectives.KillOrCapture(
        'secondary',                      # type
        'incomplete',                   # complete
        'Dispatch Titan Squad',                 # title
        'Destroy the Titan patrol around the southern base.',  # description
        {                               # target
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
    KillBattleships()
end

function KillBattleships()
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

# ---------
# Mission 3
# ---------
function IntroMission3()
    ForkThread(
        function()

            M3UEFAI.UEFM3AirBaseAI()
            M3UEFAI.UEFM3LandBaseAI()
            M3UEFAI.UEFM3EngiBaseAI()
            M3UEFAI.UEFM3SouthNavalBaseAI()
            M3UEFAI.UEFM3WestNavalBaseAI()
            ArmyBrains[UEF]:GiveResource('MASS', 12000)
            ArmyBrains[UEF]:GiveResource('ENERGY', 10000)

            -----------------
            # Initial Patrols
            -----------------

            local units = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M3_AirBaseAirDef', 'GrowthFormation')
            for k, v in units:GetPlatoonUnits() do
                ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M3_Air_Base_Defense_Chain')))
            end

            for i = 1, 6 do
                ScenarioInfo.Engineer = ScenarioUtils.CreateArmyUnit('UEF', 'M3_Engie' .. i)
                local platoon = ArmyBrains[UEF]:MakePlatoon('', '')
                ArmyBrains[UEF]:AssignUnitsToPlatoon(platoon, {ScenarioInfo.Engineer}, 'Attack', 'GrowthFormation')
                ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_Air_Attack_Chain' .. i)
            end

            ScenarioInfo.MissionNumber = 3

            # --------------------
            # Objective Structures
            # --------------------

            # ------------------------
            # Cheat Economy/Buildpower
            # ------------------------

            buffAffects.EnergyProduction.Mult = 1
            buffAffects.MassProduction.Mult = 2.3
       
            for _, u in GetArmyBrain(UEF):GetPlatoonUniquelyNamed('ArmyPool'):GetPlatoonUnits() do
                    Buff.ApplyBuff(u, 'CheatIncome')
                    --Buff.ApplyBuff(u, 'CheatBuildRate')
            end
            
            ForkThread(IntroMission3NIS)
        end
    )
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
                WaitSeconds(1)
                ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('M3_Vis_1'), 50)
                ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('M3_Vis_2'), 50)
                ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('M3_Vis_3'), 60)
                ScenarioFramework.ClearIntel(ScenarioUtils.MarkerToPosition('M3_Vis_4'), 60)
            end
        )
        WaitSeconds(2)
        
        Cinematics.SetInvincible( 'M2_Area', true )
        Cinematics.ExitNISMode()
                            
    else
        Cinematics.CameraMoveToMarker(ScenarioUtils.GetMarker('Cam_2_7'), 0)

        WaitSeconds(0.1)
    end

    ScenarioFramework.Dialogue(OpStrings.postintro3, nil, true)
    M3InitialAttack()
    StartMission3()
end

function M3InitialAttack()
    local units = nil

    # Hover Attacks
    units = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M3_UEF_InitAttack_Hover1', 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(units, 'M3_Air_Hover_Chain1')

    units = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M3_UEF_InitAttack_Hover2', 'AttackFormation')
    ScenarioFramework.PlatoonPatrolChain(units, 'M3_Air_Hover_Chain2')

    # Spawns transport attacks for every 8 defensive structures, up to 4 x 5 groups
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
                ScenarioFramework.PlatoonAttackWithTransports(units, 'M3_Init_Landing_Chain', 'M3_Init_TransAttack_Chain' .. Random(1,2), false)
            end
        end
    end

    # Air Attacks
    units = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M3_UEF_InitAttack_AirNorth', 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(units, 'M3_Air_Attack_Chain3')

    units = ScenarioUtils.CreateArmyGroupAsPlatoon('UEF', 'M3_UEF_InitAttack_AirSouth', 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(units, 'M3_Air_Attack_Chain6')

    # If player > 250 units, spawns gunships for every 40 land units, up to 7 groups
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

    # Spawns Interceptors for every 20 Air units, up to 10 groups
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

    # Spawns Destroyers for every 30 Riptides, up to 2 x 4 groups
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
    # ----------------------------------------
    # Primary Objective 1 - Destroy Enemy Base
    # ----------------------------------------
    ScenarioInfo.M3P1 = Objectives.CategoriesInArea(
        'primary',                      # type
        'incomplete',                   # complete
        'Destroy The Island Air Base',                 # title
        'Eliminate the marked UEF structures.',  # description
        'kill',                         # action
        {                               # target
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
    ScenarioInfo.M3P1:AddResultCallback(
        function(result)
            if(result) then
                ScenarioFramework.Dialogue(OpStrings.epicEprop, PlayerWin)
                # IntroMission5()
            end
        end
    )
    table.insert(AssignedObjectives, ScenarioInfo.M3P1)
    ScenarioFramework.CreateTimerTrigger(M3P1Reminder1, 25*60)
end

# -------------------
# Objective Reminders
# -------------------

# M1
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

# M2
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

# M3
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

# Epic random reminders by Washy
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