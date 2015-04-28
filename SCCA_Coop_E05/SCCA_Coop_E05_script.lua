-- ****************************************************************************
-- **
-- **  File     :  /maps/SCCA_Coop_E05/SCCA_Coop_E05_v01_script.lua
-- **  Author(s):  David Tomandl, Ruth Tomandl
-- **
-- **  Summary  :  This is the main file in control of the events during
-- **              operation E5.
-- **
-- **  Copyright © 2006 Gas Powered Games, Inc.  All rights reserved.
-- ****************************************************************************

local AIBuildStructures = import('/lua/ai/aibuildstructures.lua')
local Cinematics = import('/lua/cinematics.lua')
local Objectives = import('/lua/ScenarioFramework.lua').Objectives
local ScenarioFramework = import('/lua/scenarioframework.lua')
local Utilities = import('/lua/Utilities.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local OpStrings = import ('/maps/SCCA_Coop_E05/SCCA_Coop_E05_v01_strings.lua')
local OpEditorFns = import ('/maps/SCCA_Coop_E05/SCCA_Coop_E05_v01_EditorFunctions.lua')
local OpBehaviors = import('/lua/ai/opai/opbehaviors.lua')

-- ===  Debug Variables === #
local StartM2InsteadOfM1 = false
local StartM3InsteadOfM1 = false

-- # Debug timers to speed up truck spawning.
-- # Delay after the LRHA bases are destroyed, before Truck 1 is spawned
-- ScenarioInfo.M2TruckGroup1Delay = 20 #120 - (2*ScenarioInfo.UEFTruckGroupSize)
-- # Delay after Truck 1 arrives at its destination, before Truck 2 is spawned
-- ScenarioInfo.M2TruckGroup2Delay = 20 #600  - (2*ScenarioInfo.UEFTruckGroupSize)
-- # Delay after Truck 2 arrives at its destination, before Truck 3 is spawned
-- ScenarioInfo.M2TruckGroup3Delay = 20 #600  - (2*ScenarioInfo.UEFTruckGroupSize)
-- # Delay between the truck warning dialogue and when the truck is spawned.
-- ScenarioInfo.M2TruckDialogueToSpawnDelay = 10 #60

    -- easy = 1 medium = 2 hard = 3

ScenarioInfo.Difficulty = ScenarioInfo.Options.Difficulty or 2



-- === Tuning Variables === #
    -- For timing variables, the units are seconds
    -- For tables, the format is {easy number, medium number, hard number}

    -- Delay after start of mission, before the Aeon start attacking the player
local M1AeonWarningDelayTable = {240 , 180 , 120}
local M1AeonWarningDelay = M1AeonWarningDelayTable[ScenarioInfo.Difficulty]
    -- Delay after start of mission, before Arnold launches his first nuke
local M1AeonNukeAttackDelayTable = {480 , 420 , 360}
local M1AeonNukeAttackDelay = M1AeonNukeAttackDelayTable[ScenarioInfo.Difficulty]
    -- How long it takes the nuke to reach its destination
local AeonNukeTravelTime = 33
    -- How often to remind the player to build anti-nukes
local M1P2ReminderTimer = 180
    -- How long between Aeon main base attacks in M1
local M1AeonMainBaseAttackDelayTable = {90,30,0}
ScenarioInfo.M1AeonMainBaseAttackDelay = M1AeonMainBaseAttackDelayTable[ScenarioInfo.Difficulty]
    -- This is now a player fail case only. So I'm being pretty generous with time
local M1AeonTripleNukeDelayTable = {900 , 900 , 600}

local M1AeonTripleNukeDelay = M1AeonTripleNukeDelayTable[ScenarioInfo.Difficulty] -- - AeonNukeTravelTime

-- Number of seconds after Arnold's big attack is built that the player gets warned (based on how long it takes the troops to move out of Arnold's base)
local M1AeonBigAttackWarningDelay = 120


-- Composition of Arnold's big attack (must be changed in the editor)
-- ual0103 {4,8,12}
-- ual0111 {2,8,12}
-- ual0202 {4,8,12}
-- ual0205 {4,8,12}
-- ual0303 {4,8,12}
-- ual0304 {0,4,8}
-- ual0307 {0,4,4}
-- uaa0102 {8,8,8}
-- uaa0103 {4,8,12}
-- uaa0203 {4,8,12}
-- uaa0303 {0,4,8}
-- uaa0304 {0,2,4}

    -- Safety timer to complete M1P3, in case something happens to some of the units in it (i.e. they get stuck)
local M1AeonBigAttackSafetyTimer = 600

    -- How often to remind the player to destroy Arnold's nukes
local M1P4InitialReminderTimer = 900
local M1P4OngoingReminderTimer = 600

    -- Delay after the start of M2 before LRHA start attacking the player (insurance in case the aeon dummy base isn't completely destroyed)
local M2LrhaAttackPlayerDelay = 180
    -- How often to remind the player to destroy the LRHAs
local M2P2ReminderTimer = 600

    -- How many seconds between reminders to move the trucks
local M3P2ReminderTimer = 120
    -- How many trucks can get made in M3 by each facility	
local UEFTruckGroupSizeTable = {8, 8, 8}
ScenarioInfo.UEFTruckGroupSize = UEFTruckGroupSizeTable[ScenarioInfo.Difficulty]

    -- How many total trucks can get made in M3 if three facilities are alive
ScenarioInfo.PotentialUEFTrucks = 3*ScenarioInfo.UEFTruckGroupSize

    -- How many trucks need to be sent to earth to complete M3P2
local RequiredUEFTrucksTable = {12, 12, 12}
ScenarioInfo.RequiredUEFTrucks = RequiredUEFTrucksTable[ScenarioInfo.Difficulty]

    -- Delay after the LRHA bases are destroyed, before Truck 1 is spawned
ScenarioInfo.M2TruckGroup1Delay = 120 - (2*ScenarioInfo.UEFTruckGroupSize)
    -- Delay after Truck 1 arrives at its destination, before Truck 2 is spawned
ScenarioInfo.M2TruckGroup2Delay = 70 -- - (2*ScenarioInfo.UEFTruckGroupSize)
    -- Delay after Truck 2 arrives at its destination, before Truck 3 is spawned
ScenarioInfo.M2TruckGroup3Delay = 70 -- - (2*ScenarioInfo.UEFTruckGroupSize)
    -- Delay between the truck warning dialogue and when the truck is spawned.
ScenarioInfo.M2TruckDialogueToSpawnDelay = 60

    -- If 10% of city is destroyed, bonus objective for Mission 1 is failed
local M1CityDestroyedMilestone1Fraction = 0.1
    -- If 20% of city is destroyed, bonus objective for Mission 2 is failed
local M2CityDestroyedMilestone2Fraction = 0.2

    -- How many seconds between reminders to go through the gate
local M3P3InitialReminderTimer = 450
local M3P3OngoingReminderTimer = 900

-- === GLOBAL VARIABLES === #

    -- === Army Brains === #
ScenarioInfo.Player = 1
ScenarioInfo.Aeon = 2
ScenarioInfo.City = 3
ScenarioInfo.Cybran = 4
ScenarioInfo.Coop1 = 5
ScenarioInfo.Coop2 = 6
ScenarioInfo.Coop3 = 7
ScenarioInfo.HumanPlayers = {ScenarioInfo.Player}
local Player = ScenarioInfo.Player
local Coop1 = ScenarioInfo.Coop1
local Coop2 = ScenarioInfo.Coop2
local Coop3 = ScenarioInfo.Coop3
local Aeon = ScenarioInfo.Aeon
local City = ScenarioInfo.City
local Cybran = ScenarioInfo.Cybran

-- City.SetArmyShowScore = false
-- Aeon.SetArmyShowScore = false
-- Cybran.SetArmyShowScore = false


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


    -- === Tracking Variables === #
    -- How many research facilities have been destroyed
ScenarioInfo.FacilitiesDestroyedNumber = 0
    -- How many anti-nukes the player has built
ScenarioInfo.AntiNukeNumber = 0
    -- How many of Arnold's nukes have been destroyed
ScenarioInfo.AeonNukesDestroyedNumber = 0
    -- How many other Cybran bases have been destroyed
ScenarioInfo.CybranBasesDestroyed = 0
    -- How many total trucks have been created in M3
ScenarioInfo.NumUEFTrucksAlive = 0
    -- How many trucks RF1 has made
ScenarioInfo.ResearchFacility1TrucksProduced = 0
    -- How many trucks RF1 has made
ScenarioInfo.ResearchFacility2TrucksProduced = 0
    -- How many trucks RF1 has made
ScenarioInfo.ResearchFacility3TrucksProduced = 0
    -- How many trucks in the currently active truck group have been killed
ScenarioInfo.CurrentTruckGroupTrucksLost = 0
    -- How many trucks from the current group have gone through the gate
ScenarioInfo.NumCurrentGroupTrucksThroughGate = 0
    -- Which truck group to start with
ScenarioInfo.CurrentTruckGroup = 1
    -- How many trucks have gone back to Earth through the gate
ScenarioInfo.NumUEFTrucksThroughGate = 0
    -- How many total trucks have been lost (for M3B2)
ScenarioInfo.TotalTrucksLost = 0
    -- Used for truck positioning in TrucksNearGate
ScenarioInfo.TruckPosition = 1


-- === LOCAL VARIABLES === #
    -- === Other Variables === #

-- note needed anymore, but left for simplicity Matt 9/7/06
local M1PlayableArea = ScenarioUtils.AreaToRect('M1_PLAYABLE_AREA')
local M2PlayableArea = ScenarioUtils.AreaToRect('M2_PLAYABLE_AREA')
local M3PlayableArea = ScenarioUtils.AreaToRect('M3_PLAYABLE_AREA')

-- === STARTUP === #

-- ! Spawn armies: includes all player bases, research facilities, Aeon main base and little nuke bases, City buildings, gate
function OnPopulate(scenario)
    ScenarioUtils.InitializeScenarioArmies()
    ScenarioFramework.GetLeaderAndLocalFactions()

    ScenarioFramework.SetUEFColor(Player)
    ScenarioFramework.SetAeonColor(Aeon)
    ScenarioFramework.SetCybranColor(Cybran)
    ScenarioFramework.SetNeutralColor(City)

    -- ! Player Bases
    ScenarioInfo.PlayerBase = ScenarioUtils.CreateArmyGroup('Player', 'Player_Main_Base_D'..ScenarioInfo.Difficulty)
    ScenarioInfo.PlayerRF1Base = ScenarioUtils.CreateArmyGroup('Player', 'Player_RF1_Base_D'..ScenarioInfo.Difficulty)
    ScenarioInfo.PlayerRF2Base = ScenarioUtils.CreateArmyGroup('Player', 'Player_RF2_Base_D'..ScenarioInfo.Difficulty)
    ScenarioInfo.PlayerRF3Base = ScenarioUtils.CreateArmyGroup('Player', 'Player_RF3_Base_D'..ScenarioInfo.Difficulty)
    -- ! Player Anti Nuke, with some ammo
    ScenarioInfo.PlayerAntiNuke = ScenarioUtils.CreateArmyUnit('Player', 'Anti_nuke')
    ScenarioInfo.PlayerAntiNuke:GiveTacticalSiloAmmo(1)

    -- ! Research Facilities
    ScenarioInfo.ResearchFacility1 = ScenarioUtils.CreateArmyUnit('Player', 'ResearchFacility1')
    ScenarioInfo.ResearchFacility2 = ScenarioUtils.CreateArmyUnit('Player', 'ResearchFacility2')
    ScenarioInfo.ResearchFacility3 = ScenarioUtils.CreateArmyUnit('Player', 'ResearchFacility3')
    ScenarioInfo.ResearchFacility1:SetCustomName(LOC '{i E5_RF1Name}')
    ScenarioInfo.ResearchFacility2:SetCustomName(LOC '{i E5_RF2Name}')
    ScenarioInfo.ResearchFacility3:SetCustomName(LOC '{i E5_RF3Name}')
        -- ! Death triggers for research facilities
    ScenarioFramework.CreateUnitDeathTrigger(ResearchFacility1Destroyed, ScenarioInfo.ResearchFacility1)
    ScenarioFramework.CreateUnitDeathTrigger(ResearchFacility2Destroyed, ScenarioInfo.ResearchFacility2)
    ScenarioFramework.CreateUnitDeathTrigger(ResearchFacility3Destroyed, ScenarioInfo.ResearchFacility3)
        -- ! The first time each research facility gets damaged, play a taunt from the army that damaged it
    ScenarioInfo.ResearchFacility1.OnDamage =
        function(self, instigator, amount, vector, damageType)
            if self.CanTakeDamage then
                self:DoOnDamagedCallbacks(instigator)
                self:DoTakeDamage(instigator, amount, vector, damageType)
            end
			if instigator then
				local damagerArmy = instigator:GetArmy()
				if (damagerArmy == Aeon) and (not ScenarioInfo.RF1DamagedByAeonTauntPlayed) then
					ForkArnoldTaunt()
					ScenarioInfo.RF1DamagedByAeonTauntPlayed = true
				elseif (damagerArmy == Cybran) and (not ScenarioInfo.RF1DamagedByCybranTauntPlayed) then
					ForkMachTaunt()
					ScenarioInfo.RF1DamagedByCybranTauntPlayed = true
				end
			end
        end
    ScenarioInfo.ResearchFacility2.OnDamage =
        function(self, instigator, amount, vector, damageType)
            if self.CanTakeDamage then
                self:DoOnDamagedCallbacks(instigator)
                self:DoTakeDamage(instigator, amount, vector, damageType)
            end
			if instigator then
				local damagerArmy = instigator:GetArmy()
				if (damagerArmy == Aeon) and (not ScenarioInfo.RF2DamagedByAeonTauntPlayed) then
					ForkArnoldTaunt()
					ScenarioInfo.RF2DamagedByAeonTauntPlayed = true
				elseif (damagerArmy == Cybran) and (not ScenarioInfo.RF2DamagedByCybranTauntPlayed) then
					ForkMachTaunt()
					ScenarioInfo.RF2DamagedByCybranTauntPlayed = true
				end
			end
        end
    ScenarioInfo.ResearchFacility3.OnDamage =
        function(self, instigator, amount, vector, damageType)
            if self.CanTakeDamage then
                self:DoOnDamagedCallbacks(instigator)
                self:DoTakeDamage(instigator, amount, vector, damageType)
            end
			if instigator then
				local damagerArmy = instigator:GetArmy()
				if (damagerArmy == Aeon) and (not ScenarioInfo.RF3DamagedByAeonTauntPlayed) then
					ForkArnoldTaunt()
					ScenarioInfo.RF3DamagedByAeonTauntPlayed = true
				elseif (damagerArmy == Cybran) and (not ScenarioInfo.RF3DamagedByCybranTauntPlayed) then
					ForkMachTaunt()
					ScenarioInfo.RF3DamagedByCybranTauntPlayed = true
				end
			end
        end

    -- ! Aeon Bases
    -- ! Spawn Main base, make a new template for Main base engineers to maintain
    ScenarioInfo.AeonMainBaseEngineers = ScenarioUtils.CreateArmyGroup('Aeon', 'Main_Base_Engineers_D'..ScenarioInfo.Difficulty)
    ScenarioInfo.AeonMainBaseBuildings = ScenarioUtils.CreateArmyGroup('Aeon', 'Main_Base_Buildings_D'..ScenarioInfo.Difficulty)
    AIBuildStructures.CreateBuildingTemplate(ArmyBrains[Aeon], 'Aeon', 'Main_Base_Buildings')
    AIBuildStructures.AppendBuildingTemplate(ArmyBrains[Aeon], 'Aeon', ('Main_Base_Buildings_D'..ScenarioInfo.Difficulty), 'Main_Base_Buildings')
    AIBuildStructures.AppendBuildingTemplate(ArmyBrains[Aeon], 'Aeon', ('Main_Base_Buildings_ToBuild_D'..ScenarioInfo.Difficulty), 'Main_Base_Buildings')
    ScenarioInfo.AeonMainBasePatrolUnits = ScenarioUtils.CreateArmyGroup('Aeon', 'Main_Base_Patrol_Units_D'..ScenarioInfo.Difficulty)
    ScenarioInfo.VarTable['BuildAeonMainBasePatrols'] = true

    -- ! Spawning walls separately because I don't want engineers to maintain them
    ScenarioInfo.AeonMainBaseWalls = ScenarioUtils.CreateArmyGroup('Aeon', 'Main_Base_Walls')

    -- ! Spawn initial Aeon attacks
    ScenarioInfo.AeonAirAttackPlayer = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'Aeon_First_Air_Attack_D'..ScenarioInfo.Difficulty, 'ChevronFormation')
    ScenarioInfo.AeonFirstGroundAttackPlayer = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'Aeon_First_Ground_Attack_D'..ScenarioInfo.Difficulty, 'AttackFormation')
    ScenarioInfo.AeonGroundAttackRF1 = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'Aeon_Initial_Ground_Attack_RF1', 'AttackFormation')
    ScenarioInfo.AeonAirAttackRF2 = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'Aeon_Initial_Air_Attack_RF2', 'ChevronFormation')
    ScenarioInfo.AeonSecondGroundAttackPlayer = ScenarioUtils.CreateArmyGroupAsPlatoon('Aeon', 'Aeon_Second_Ground_Attack_Player', 'AttackFormation')

    -- ! Spawn Nuke 2 base, make a new template for nuke2base engineers to maintain
    ScenarioInfo.AeonNuke2BaseEngineers = ScenarioUtils.CreateArmyGroup('Aeon', 'Nuke2_Base_Engineers_D'..ScenarioInfo.Difficulty)
    ScenarioInfo.AeonNuke2BaseBuildings = ScenarioUtils.CreateArmyGroup('Aeon', 'Nuke2_Base_Buildings_D'..ScenarioInfo.Difficulty)
    AIBuildStructures.CreateBuildingTemplate(ArmyBrains[Aeon], 'Aeon', 'Nuke2_Base_Buildings')
    AIBuildStructures.AppendBuildingTemplate(ArmyBrains[Aeon], 'Aeon', ('Nuke2_Base_Buildings_D'..ScenarioInfo.Difficulty), 'Nuke2_Base_Buildings')


    -- ! Spawn Nuke 3 base, make a new template for nuke3base engineers to maintain
    ScenarioInfo.AeonNuke3BaseEngineers = ScenarioUtils.CreateArmyGroup('Aeon', 'Nuke3_Base_Engineers_D'..ScenarioInfo.Difficulty)
    ScenarioInfo.AeonNuke3BaseBuildings = ScenarioUtils.CreateArmyGroup('Aeon', 'Nuke3_Base_Buildings_D'..ScenarioInfo.Difficulty)
    AIBuildStructures.CreateBuildingTemplate(ArmyBrains[Aeon], 'Aeon', 'Nuke3_Base_Buildings')
    AIBuildStructures.AppendBuildingTemplate(ArmyBrains[Aeon], 'Aeon', ('Nuke3_Base_Buildings_D'..ScenarioInfo.Difficulty), 'Nuke3_Base_Buildings')

    -- ! Aeon nuke launchers
    ScenarioInfo.AeonNuke1 = ScenarioUtils.CreateArmyUnit('Aeon', 'Aeon_nuke_launcher_1')
    ScenarioInfo.AeonNuke2 = ScenarioUtils.CreateArmyUnit('Aeon', 'Aeon_nuke_launcher_2')
    ScenarioInfo.AeonNuke3 = ScenarioUtils.CreateArmyUnit('Aeon', 'Aeon_nuke_launcher_3')
        -- ! Track nuke launcher deaths
    ScenarioFramework.CreateUnitDeathTrigger(AeonNukeHasBeenDestroyed, ScenarioInfo.AeonNuke1)
    ScenarioFramework.CreateUnitDeathTrigger(AeonNukeHasBeenDestroyed, ScenarioInfo.AeonNuke2)
    ScenarioFramework.CreateUnitDeathTrigger(AeonNukeHasBeenDestroyed, ScenarioInfo.AeonNuke3)
    ScenarioInfo.AeonNuke1:SetCapturable(false)
    ScenarioInfo.AeonNuke2:SetCapturable(false)
    ScenarioInfo.AeonNuke3:SetCapturable(false)

    -- ! City buildings
    ScenarioInfo.CityBuildingsGroup = ScenarioUtils.CreateArmyGroup('City', 'City_Buildings')

    -- ! Quantum gate, which should be invincible
    ScenarioInfo.Gate = ScenarioUtils.CreateArmyUnit('City', 'Gate')
    ScenarioInfo.Gate:SetCanTakeDamage(false)
    ScenarioInfo.Gate:SetCanBeKilled(false)
    ScenarioInfo.Gate:SetReclaimable(false)
    ScenarioInfo.Gate:SetCapturable(false)
    ScenarioInfo.Gate:SetUnSelectable(true)

    -- ! Set army unit caps
    SetArmyUnitCap(Aeon, 500)
    SetArmyUnitCap(City, 125)

    ScenarioFramework.RestrictEnhancements({ 'TacticalNukeMissile', 'Teleporter' })

    -- ! Take away units that the player shouldn't have access to
    for _, player in ScenarioInfo.HumanPlayers do
         ScenarioFramework.AddRestriction(player, categories.ueb4302 + -- Strategic Missile Defense
                                      categories.ueb0304 + -- Quantum Gateway
                                      categories.ueb2305 + -- Nuclear Missile Launcher
                                      categories.uel0304 + -- Mobile Heavy Artillery
                                      categories.uel0301 + -- Sub Commander
                                      categories.ueb3104 + -- Omni Detection System
                                      categories.ueb0303 + -- T3 Navy factory
                                      categories.ues0302 + -- Battleship
                                      categories.ues0305 + -- T3 Mobile Sonar
                                      categories.ues0401 + -- Submersible Aircraft Carrier
                                      categories.ueb2302 + -- Long Range Heavy Artillery
                                      categories.uel0401 + -- Experimental Mobile Factory
                                      categories.ues0304 + -- Strategic Missile Submarine
     
                                      categories.uab4302 + -- Strategic Missile Defense
                                      categories.uab0304 + -- Quantum Gateway
                                      categories.uab2305 + -- Nuclear Missile Launcher
                                      categories.ual0304 + -- Mobile Heavy Artillery
                                      categories.ual0301 + -- Sub Commander
                                      categories.uab3104 + -- Omni Detection System
                                      categories.uab0303 + -- T3 Navy factory
                                      categories.uas0302 + -- Battleship
                                      categories.uas0305 + -- T3 Mobile Sonar
                                      categories.uab2302 + -- Long Range Heavy Artillery
                                      categories.uas0304 + -- Strategic Missile Submarine
     
                                      categories.urb4302 + -- Strategic Missile Defense
                                      categories.urb0304 + -- Quantum Gateway
                                      categories.urb2305 + -- Nuclear Missile Launcher
                                      categories.url0304 + -- Mobile Heavy Artillery
                                      categories.url0301 + -- Sub Commander
                                      categories.urb3104 + -- Omni Detection System
                                      categories.urb0303 + -- T3 Navy factory
                                      categories.urs0302 + -- Battleship
                                      categories.urs0305 + -- T3 Mobile Sonar
                                      categories.urb2302 + -- Long Range Heavy Artillery
                                      categories.urs0304 + -- Strategic Missile Submarine
     
                                      categories.EXPERIMENTAL )
    end

    ScenarioFramework.AddRestriction(Aeon, categories.ueb4302 + -- Strategic Missile Defense
                               categories.ueb0304 + -- Quantum Gateway
                               categories.ueb2305 + -- Nuclear Missile Launcher
                               categories.uel0304 + -- Mobile Heavy Artillery
                               categories.uel0301 + -- Sub Commander
                               categories.ueb3104 + -- Omni Detection System
                               categories.ueb0303 + -- T3 Navy factory
                               categories.ues0302 + -- Battleship
                               categories.ues0305 + -- T3 Mobile Sonar
                               categories.ues0401 + -- Submersible Aircraft Carrier
                               categories.ueb2302 + -- Long Range Heavy Artillery
                               categories.ueb4301 + -- Heavy Shield Generator
                               categories.uel0401 + -- Experimental Mobile Factory
                               categories.ues0304 + -- Strategic Missile Submarine

                               categories.uab4302 + -- Strategic Missile Defense
                               categories.uab0304 + -- Quantum Gateway
                               categories.uab2305 + -- Nuclear Missile Launcher
                               categories.ual0304 + -- Mobile Heavy Artillery
                               categories.ual0301 + -- Sub Commander
                               categories.uab3104 + -- Omni Detection System
                               categories.uab0303 + -- T3 Navy factory
                               categories.uas0302 + -- Battleship
                               categories.uas0305 + -- T3 Mobile Sonar
                               categories.uab2302 + -- Long Range Heavy Artillery
                               categories.uab4301 + -- Heavy Shield Generator
                               categories.uas0304 + -- Strategic Missile Submarine

                               categories.urb4302 + -- Strategic Missile Defense
                               categories.urb0304 + -- Quantum Gateway
                               categories.urb2305 + -- Nuclear Missile Launcher
                               categories.url0304 + -- Mobile Heavy Artillery
                               categories.url0301 + -- Sub Commander
                               categories.urb3104 + -- Omni Detection System
                               categories.urb0303 + -- T3 Navy factory
                               categories.urs0302 + -- Battleship
                               categories.urs0305 + -- T3 Mobile Sonar
                               categories.urb2302 + -- Long Range Heavy Artillery
                               categories.urs0304 + -- Strategic Missile Submarine

                               categories.uaa0304 + -- Strategic bomber
                               categories.uea0304 + -- Strategic bomber
                               categories.ura0304 +  -- Strategic bomber

                               categories.EXPERIMENTAL)

    ScenarioFramework.AddRestriction(Cybran, categories.ueb4302 + -- Strategic Missile Defense
                                 categories.ueb0304 + -- Quantum Gateway
                                 categories.ueb2305 + -- Nuclear Missile Launcher
                                 categories.uel0304 + -- Mobile Heavy Artillery
                                 categories.uel0301 + -- Sub Commander
                                 categories.ueb3104 + -- Omni Detection System
                                 categories.ueb0303 + -- T3 Navy factory
                                 categories.ues0302 + -- Battleship
                                 categories.ues0305 + -- T3 Mobile Sonar
                                 categories.ues0401 + -- Submersible Aircraft Carrier
                                 categories.ueb2302 + -- Long Range Heavy Artillery
                                 categories.ueb4301 + -- Heavy Shield Generator
                                 categories.uel0401 + -- Experimental Mobile Factory
                                 categories.ues0304 + -- Strategic Missile Submarine

                                 categories.uab4302 + -- Strategic Missile Defense
                                 categories.uab0304 + -- Quantum Gateway
                                 categories.uab2305 + -- Nuclear Missile Launcher
                                 categories.ual0304 + -- Mobile Heavy Artillery
                                 categories.ual0301 + -- Sub Commander
                                 categories.uab3104 + -- Omni Detection System
                                 categories.uab0303 + -- T3 Navy factory
                                 categories.uas0302 + -- Battleship
                                 categories.uas0305 + -- T3 Mobile Sonar
                                 categories.uab2302 + -- Long Range Heavy Artillery
                                 categories.uab4301 + -- Heavy Shield Generator
                                 categories.uas0304 + -- Strategic Missile Submarine

                                 categories.urb4302 + -- Strategic Missile Defense
                                 categories.urb0304 + -- Quantum Gateway
                                 categories.urb2305 + -- Nuclear Missile Launcher
                                 categories.url0304 + -- Mobile Heavy Artillery
                                 categories.url0301 + -- Sub Commander
                                 categories.urb3104 + -- Omni Detection System
                                 categories.urb0303 + -- T3 Navy factory
                                 categories.urs0302 + -- Battleship
                                 categories.urs0305 + -- T3 Mobile Sonar
                                 categories.urb2302 + -- Long Range Heavy Artillery
                                 categories.urs0304 + -- Strategic Missile Submarine

                                 categories.uaa0304 + -- Strategic bomber
                                 categories.uea0304 + -- Strategic bomber
                                 categories.ura0304 + -- Strategic bomber

                                 categories.EXPERIMENTAL)

    -- Commader
    ScenarioFramework.RestrictEnhancements({'TacticalNukeMissile',
                                            'Teleporter'})
end

function OnStart(self)
    -- ! Set playable area for M1
    ScenarioFramework.SetPlayableArea(M1PlayableArea, false)

    for i = 2, table.getn(ArmyBrains) do
        if i < ScenarioInfo.Coop1 then
            SetArmyShowScore(i, false)
            SetIgnorePlayableRect(i, true)
        end
    end

    -- ! Start intro NIS
    -- ScenarioFramework.StartOperationJessZoom('Start_Camera_Area', IntroNIS)
    ForkThread(StartCamera)
end

function StartCamera()
    Cinematics.EnterNISMode()
    Cinematics.CameraMoveToRectangle(ScenarioUtils.AreaToRect('Initial_Cam_1'), 0)
    WaitSeconds(.25)
    ForkThread(CreatePlayer)
    Cinematics.CameraMoveToRectangle(ScenarioUtils.AreaToRect('Initial_Cam_2'), 3)
    WaitSeconds(0.75)
    ForkThread(OpeningDialogue)
    Cinematics.CameraMoveToRectangle(ScenarioUtils.AreaToRect('Initial_Cam_3'), 2.5)
    Cinematics.ExitNISMode()
    IntroNIS()
    Cinematics.CameraMoveToRectangle(ScenarioUtils.AreaToRect('Initial_Cam_4'), 4)
end

function OpeningDialogue()
    WaitSeconds(2)
    -- ! Assign M1P1: Protect 2/3 research facilities.
    ScenarioFramework.Dialogue(OpStrings.E05_M01_010, M1AssignP1)
end

-- === INTRO NIS === #
function CreatePlayer()
    WaitSeconds(3)
    -- ! Player Commander and his Death Trigger
    ScenarioInfo.PlayerCDR = ScenarioUtils.CreateArmyUnit('Player', 'Commander')
    ScenarioInfo.PlayerCDR:PlayCommanderWarpInEffect()

    -- spawn coop players too
    ScenarioInfo.CoopCDR = {}
    local tblArmy = ListArmies()
    coop = 1
    for iArmy, strArmy in pairs(tblArmy) do
        if iArmy >= ScenarioInfo.Coop1 then
            ScenarioInfo.CoopCDR[coop] = ScenarioUtils.CreateArmyUnit(strArmy, 'Commander')
            ScenarioInfo.CoopCDR[coop]:PlayCommanderWarpInEffect()
			IssueMove({ScenarioInfo.CoopCDR[coop]}, ScenarioUtils.MarkerToPosition('Commander_Start_1'))
			IssueMove({ScenarioInfo.CoopCDR[coop]}, ScenarioUtils.MarkerToPosition('Commander_Start_2'))			
			ScenarioFramework.PauseUnitDeath(ScenarioInfo.CoopCDR[coop])
			ScenarioFramework.CreateUnitDeathTrigger(CommanderDied, ScenarioInfo.CoopCDR[coop])
			ScenarioFramework.FakeGateInUnit(ScenarioInfo.CoopCDR[coop])
            coop = coop + 1
            WaitSeconds(0.5)
        end
    end

    ScenarioFramework.CreateUnitDeathTrigger(CommanderDied, ScenarioInfo.PlayerCDR)
    ScenarioInfo.PlayerCDR:SetReclaimable(false)
    ScenarioInfo.PlayerCDR:SetCapturable(false)
    IssueMove({ScenarioInfo.PlayerCDR}, ScenarioUtils.MarkerToPosition('Commander_Start_1'))
    IssueMove({ScenarioInfo.PlayerCDR}, ScenarioUtils.MarkerToPosition('Commander_Start_2'))

    -- no warp in pls. Matt 9/11/06
    ScenarioFramework.FakeGateInUnit(ScenarioInfo.PlayerCDR)
    ScenarioFramework.PauseUnitDeath(ScenarioInfo.PlayerCDR)


end

function IntroNIS()
-- #! Play the opening NIS
--    #! Show the research facilities and the player commander arriving
    if not StartM2InsteadOfM1 and not StartM3InsteadOfM1 then
        -- ! Set mission state
        ForkThread(StartMission1)
        -- $Utilities.UserConRequest('SallyShears')
    elseif StartM2InsteadOfM1 then
        Utilities.UserConRequest('SallyShears')
        local AeonUnits = ArmyBrains[Aeon]:GetListOfUnits(categories.AEON, false)
        for k, unit in AeonUnits do
            unit:Destroy()
        end
        StartMission2()
    elseif StartM3InsteadOfM1 then
        Utilities.UserConRequest('SallyShears')
        local AeonUnits = ArmyBrains[Aeon]:GetListOfUnits(categories.AEON, false)
        for k, unit in AeonUnits do
            unit:Destroy()
        end
        StartMission3()
    end
end

-- ===
-- === MISSION 1 FUNCTIONS === #

function StartMission1()

    ScenarioInfo.MissionNumber = 1
    -- SetArmyShowScore(ScenarioInfo.City, false)
    LOG('debug: Op: Mission 1 has started dificulty='..ScenarioInfo.Difficulty)

    -- ! Arnold shouldn't taunt until after his presence has been revealed
    ScenarioInfo.ArnoldDontTaunt = true

    ScenarioInfo.M1Objectives = Objectives.CreateGroup('Mission1', function() LOG ('debug: Op:Mission 1 over') end)

    -- ! Check for M1P2 success (Build 2 Anti-missle defenses) #Todo: Use new unit in radius objective when it's made
    ForkThread(SiloAmmoThread, MissileDefenseCreated, 'AntiNuke_Area_1')
    ForkThread(SiloAmmoThread, MissileDefenseCreated, 'AntiNuke_Area_2')
    ForkThread(SiloAmmoThread, MissileDefenseCreated, 'AntiNuke_Area_3')

    -- ! Tell Arnold's nukes to build some missles
    ScenarioInfo.AeonNuke1:GiveNukeSiloAmmo(2)
    ScenarioInfo.AeonNuke2:GiveNukeSiloAmmo(1)
    ScenarioInfo.AeonNuke3:GiveNukeSiloAmmo(1)

    -- ! Warn about Aeon, either timer or LOS
    ScenarioFramework.CreateTimerTrigger(AeonNukeWarning, M1AeonWarningDelay)
    ScenarioFramework.CreateArmyIntelTrigger(AeonNukeWarning, ArmyBrains[Player], 'LOSNow', false, true, categories.ALLUNITS, true, ArmyBrains[Aeon])


    -- ! Arnold fires his first nuke after the M1AeonNukeAttackDelay
    ScenarioFramework.CreateTimerTrigger(FireAeonNuke, M1AeonNukeAttackDelay)


    -- ! Stop building main base patrols so we don't gather units that are supposed to be in an OSB
    ScenarioInfo.VarTable['BuildAeonMainBasePatrols'] = false
end

function M1AssignP1()
    ScenarioInfo.M1P1 = Objectives.Protect(-- Todo: Get a version of Protect that has a marker
        'primary',                      -- type
        'incomplete',                   -- complete
        OpStrings.M1P1Title,            -- title
        OpStrings.M1P1Description,      -- description
        {                               -- target
            Units = {ScenarioInfo.ResearchFacility1, ScenarioInfo.ResearchFacility2, ScenarioInfo.ResearchFacility3},           -- group to protect
            Timer = nil,                -- if nil, requires a manual update for completion
            NumRequired = 2,            -- How many must survive
        }
   )
    ScenarioInfo.M1P1:AddResultCallback(
        function(result,unit)
            if not result then
                PlayerLose(OpStrings.E05_M01_070)
            end
        end
   )
    -- Don't add this one to Objective group, as it is completed when the group is completed
    -- Matt 10.16.06
    -- ScenarioInfo.M1Objectives:AddObjective(ScenarioInfo.M1P1)
	
	ForkThread(CheatEconomy)
end

function SiloAmmoThread(callback, areaName)
    local hasAmmo = false
    local rect = ScenarioUtils.AreaToRect(areaName)
    while not hasAmmo do
        local units = GetUnitsInRect(rect)
        for k,v in units do
            if not v:IsDead() and v:GetAIBrain():GetArmyIndex() == 1 and EntityCategoryContains(categories.SILO * categories.ANTIMISSILE, v) then
                if v:GetTacticalSiloAmmoCount() > 0 then
                    if not hasAmmo then
                        hasAmmo = true
                        callback()
                    end
                end
            end
        end
        WaitSeconds(.5)
    end
end


-- ! Warn the player that Aeon may attack them, assign M1S1 (protect 90% of the city)
function AeonNukeWarning()

    if not ScenarioInfo.AeonNukeWarningPlayed then
        ScenarioInfo.AeonNukeWarningPlayed = true

        LOG('debug: Op: AeonNukeWarning')

        ForkThread(SendInitialAttacks)

        -- ! Check for M1S1 success (protect 90% of the city)
        ScenarioFramework.Dialogue(OpStrings.E05_M01_020)
        local CityDestroyedAmountOne = math.floor(M1CityDestroyedMilestone1Fraction * table.getn(ScenarioInfo.CityBuildingsGroup))
        local CityProtectAmountOne = table.getn(ScenarioInfo.CityBuildingsGroup) - CityDestroyedAmountOne
        ScenarioInfo.M1S1 = Objectives.Protect(
            'secondary',                    -- type
            'incomplete',                   -- complete
            OpStrings.M1S1Title,            -- title
            OpStrings.M1S1Description,      -- description
            {                               -- target
                Units = ScenarioInfo.CityBuildingsGroup,          -- group to protect
                Timer = nil,                -- if nil, requires a manual update for completion
                NumRequired = CityProtectAmountOne,            -- How many must survive
            }
       )
        ScenarioInfo.M1S1:AddResultCallback(
            function(result)
                if not result then -- If you fail to protect the city
                    if ScenarioInfo.MissionNumber == 1 then
                        ScenarioInfo.M1S1:ManualResult(false)
                        ScenarioInfo.M1S1Failed = true
                        LOG('debug: Op: More than 10% of the city has been destroyed')
                    end
                end
            end
       )
    end
end

function OnNukeShotDown()
    if not ScenarioInfo.M1FirstNukeDown then
        M1InitialNukeShotDown()
    else
        M1NukeShotDown()
    end
end


-- ! Send initial small attacks at the player and the research facilities
function SendInitialAttacks()
    ScenarioInfo.AeonAirAttackPlayer:AggressiveMoveToLocation(ScenarioUtils.MarkerToPosition('Gate_Position'))
    ScenarioInfo.AeonFirstGroundAttackPlayer:AggressiveMoveToLocation(ScenarioUtils.MarkerToPosition('Player'))
    WaitSeconds(30)
    -- Aeon.SetArmyShowScore = true
    ScenarioInfo.AeonGroundAttackRF1:AggressiveMoveToLocation(ScenarioUtils.MarkerToPosition('Research_Facility_1'))
    WaitSeconds(30)
    ScenarioInfo.VarTable['BuildAeonMainBaseAttacks'] = true
    ScenarioInfo.AeonAirAttackRF2:AggressiveMoveToLocation(ScenarioUtils.MarkerToPosition('Research_Facility_2'))
    WaitSeconds(30)
    ScenarioInfo.AeonSecondGroundAttackPlayer:AggressiveMoveToLocation(ScenarioUtils.MarkerToPosition('Player'))
end

-- ! Fire the Aeon nuke at the player's outpost
function FireAeonNuke()
    ScenarioInfo.Nuke0Target = ScenarioUtils.MarkerToPosition('Aeon_Nuke_Target')
    ScenarioInfo.AeonNuke1:AddProjectileDamagedCallback(OnNukeShotDown)
    IssueNuke({ ScenarioInfo.AeonNuke1 }, ScenarioInfo.Nuke0Target)
    LOG('debug: Op: Arnold launches 1 nuke')

    ScenarioFramework.CreateTimerTrigger(FirstNukeNIS, 5)

    -- ! The first time the player gets line of sight on a nuke launcher, play an Arnold taunt
    ScenarioFramework.CreateArmyIntelTrigger(ForkArnoldTaunt, ArmyBrains[Player], 'LOSNow', false, true, categories.uab2305, true, ArmyBrains[Aeon])

    -- WaitSeconds(AeonNukeTravelTime)
end

function FirstNukeNIS()
-- NIS for the first nuke. Change delay on timer trigger which calls this nis to start the NIS at a good
-- point during the launch process.
    if not ScenarioInfo.AeonNuke1:IsDead() then
        local unit = ScenarioInfo.AeonNuke1
        local camInfo = {
        	blendTime = 1.0,
        	holdTime = 8,
        	orientationOffset = { 2.3, 0.2, 0 },
        	positionOffset = { 0, 1, 0 },
        	zoomVal = 30,
            vizRadius = 8,
        }
        ScenarioFramework.OperationNISCamera(unit, camInfo)
    end
end

function M1InitialNukeShotDown()
    -- ! Assign M1P2 (build 2 anti-nukes next to research facilities)
    ScenarioInfo.M1FirstNukeDown = true
    ScenarioFramework.Dialogue(OpStrings.E05_M01_030)
    ScenarioFramework.Dialogue(OpStrings.E05_M01_040,M1InitialNukeShotDownPt2)
end

function M1InitialNukeShotDownPt2()
    ScenarioInfo.M1P2 = Objectives.Basic(
        'primary',
        'incomplete',
        OpStrings.M1P2Title,
        OpStrings.M1P2Description,
        Objectives.GetActionIcon('build'),
        {
            -- Area = 'RF1_Truck_Area',
            -- MarkArea = true, #Todo: Change this to mark the research facilities when that's in
            -- Units = {ScenarioInfo.ResearchFacility1, ScenarioInfo.ResearchFacility2, ScenarioInfo.ResearchFacility3},
            Areas = { 'AntiNuke_Area_1', 'AntiNuke_Area_2', 'AntiNuke_Area_3', },
            MarkArea = true,
        }
   )
    ScenarioInfo.M1Objectives:AddObjective(ScenarioInfo.M1P2)

    -- ! Give the player access to anti-nukes
    ScenarioFramework.RemoveRestrictionForAllHumans(categories.ueb4302 + categories.uab4302 + categories.urb4302)

    -- ! Arnold launches three nukes after (a)M1AeonTripleNukeDelay, (b)the player builds two anti-nuke missles, or
    -- !
    ScenarioFramework.CreateTimerTrigger(CallAeonTripleNukeAttack, M1AeonTripleNukeDelay)


    -- ! Remind the player to do M1P2 after M1P2ReminderTimer
    ScenarioInfo.NextM1P2Reminder = 1
    ScenarioFramework.CreateTimerTrigger(M1P2Reminder, M1P2ReminderTimer)
end

-- ! Check for M1P2 success (Create two missle defenses next to research facilities)
function MissileDefenseCreated()

    if (ScenarioInfo.M1P2.Active) then -- now only update objective if its active (ignore if its complete)

        if ScenarioInfo.AntiNukeNumber < 3 then
            ScenarioInfo.AntiNukeNumber = ScenarioInfo.AntiNukeNumber + 1
        end

        -- ! Update objective text
        Objectives.UpdateBasicObjective(ScenarioInfo.M1P2, 'progress', LOCF(OpStrings.M1P2Progress, ScenarioInfo.AntiNukeNumber))

        -- ! Check for objective completion
        if(ScenarioInfo.AntiNukeNumber >= 2) and not ScenarioInfo.MissionFailed and ScenarioInfo.MissionNumber == 1 and not ScenarioInfo.AntiNukesBuilt then
            ScenarioInfo.M1P2:ManualResult(true)

            -- call this manually here, Matt 10.17.06
            CallAeonTripleNukeAttack()

            -- ! Start Aeon transport attacks
            ScenarioInfo.VarTable['BuildAeonLandAssault'] = true

            ScenarioInfo.AntiNukesBuilt = true
        end
    end
end

-- ! Remind the player to build anti-nukes
function M1P2Reminder()
    while not ScenarioInfo.AntiNukesBuilt do
        if ScenarioInfo.NextM1P2Reminder == 1 and not ScenarioInfo.OpEnded then
            ScenarioFramework.Dialogue(OpStrings.E05_M01_100)
            ScenarioInfo.NextM1P2Reminder = 2
        elseif ScenarioInfo.NextM1P2Reminder == 2 and not ScenarioInfo.OpEnded then
            ScenarioFramework.Dialogue(OpStrings.E05_M01_105)
            ScenarioInfo.NextM1P2Reminder = 1
        end
        WaitSeconds(M1P2ReminderTimer)
    end
end

function CallAeonTripleNukeAttack()
    if not ScenarioInfo.TripleNukesLaunched then
        ScenarioInfo.TripleNukesLaunched = true
        ScenarioFramework.Dialogue(OpStrings.E05_M01_050, AeonTripleNukeAttack)
    end
end

-- ! Launch three nukes at player
function AeonTripleNukeAttack()
    -- if not ScenarioInfo.TripleNukesLaunched then
        ScenarioInfo.TripleAttackNukesSent = 0
        if not ScenarioInfo.AeonNuke1:IsDead() then
            -- if ScenarioInfo.Difficulty == 1 then
            -- ScenarioInfo.Nuke1Target = ScenarioUtils.MarkerToPosition('Nuke1_Target_Easy')
            -- else
            -- ScenarioInfo.Nuke1Target = ScenarioUtils.MarkerToPosition('Research_Facility_2')
            -- end
            ScenarioInfo.Nuke1Target = ScenarioUtils.MarkerToPosition('Research_Facility_1')
            ScenarioInfo.AeonNuke1:AddProjectileDamagedCallback(OnNukeShotDown)
            IssueNuke({ ScenarioInfo.AeonNuke1 }, ScenarioInfo.Nuke1Target)
            ScenarioInfo.TripleAttackNukesSent = ScenarioInfo.TripleAttackNukesSent + 1
        end

        if not ScenarioInfo.AeonNuke2:IsDead() then
            ScenarioInfo.Nuke2Target = ScenarioUtils.MarkerToPosition('Research_Facility_2')
            ScenarioInfo.AeonNuke2:AddProjectileDamagedCallback(OnNukeShotDown)
            IssueNuke({ ScenarioInfo.AeonNuke2 }, ScenarioInfo.Nuke2Target)
            ScenarioInfo.TripleAttackNukesSent = ScenarioInfo.TripleAttackNukesSent + 1
        end

        if not ScenarioInfo.AeonNuke3:IsDead() then
            LOG("debugmatt: Nuke3111")
            -- if ScenarioInfo.Difficulty == 1 then
            -- ScenarioInfo.Nuke3Target = ScenarioUtils.MarkerToPosition('Nuke3_Target_Easy')
            -- else
            -- ScenarioInfo.Nuke3Target = ScenarioUtils.MarkerToPosition('Research_Facility_1')
            -- end
            ScenarioInfo.Nuke3Target = ScenarioUtils.MarkerToPosition('Research_Facility_3')
            ScenarioInfo.AeonNuke3:AddProjectileDamagedCallback(OnNukeShotDown)
            IssueNuke({ ScenarioInfo.AeonNuke3 }, ScenarioInfo.Nuke3Target)
            ScenarioInfo.TripleAttackNukesSent = ScenarioInfo.TripleAttackNukesSent + 1
            LOG("debugmatt: Nuke3>>"..ScenarioInfo.TripleAttackNukesSent)
        end
        LOG("debugmatt: Nuke?>>"..ScenarioInfo.TripleAttackNukesSent)
        -- ! On hard difficulty, let the nukes keep nuking stuff.
--    if ScenarioInfo.Difficulty == 3 then
--        ForkThread(AeonContinuedNukeAttacks)
--    end


        -- ! Arnold sends a big attack
        -- Matt send it here to cover the case of all 3 laucher down early
        WaitSeconds(60)

        -- assign here instead of after big attack, better flow.
        if not ScenarioInfo.M1P4Assigned then
            AssignM1P4()
        end

        if not ScenarioInfo.M1BigAttackSent then
            ScenarioInfo.M1BigAttackSent = true
            ScenarioFramework.CreateTimerTrigger(BigAeonAttack, M1AeonBigAttackWarningDelay)
        end
    -- end
end

function M1NukeShotDown()
    -- this whole thing may be obsolete now
    if not ScenarioInfo.NukesShotDown then
        ScenarioInfo.NukesShotDown = 1
    else
        ScenarioInfo.NukesShotDown = ScenarioInfo.NukesShotDown + 1
    end
    -- if ScenarioInfo.NukesShotDown == ScenarioInfo.TripleAttackNukesSent then
    -- #Big attack moved to AeonTripleNukeAttack, for better flow
    -- end
end


-- ! Arnold sends a big attack
function BigAeonAttack()
    ScenarioInfo.ArnoldDontTaunt = false
    -- Matt dont start this if M1 is otherwise over 10.17.06
    if not ScenarioInfo.Mission1Done then
        -- Tell the AM Master platoon to build
        ScenarioInfo.VarTable['BuildBigAeonAttack'] = true
    end
end

function BigAeonAttackBuilt()

    -- Assign M1P3 (repel Arnold's attack)
    ScenarioFramework.Dialogue(OpStrings.E05_M01_060)
    ScenarioInfo.M1P3 = Objectives.Basic(
        'primary',                      -- type
        'incomplete',                   -- complete
        OpStrings.M1P3Title,            -- title
        OpStrings.M1P3Description,      -- description
        Objectives.GetActionIcon('kill'),
        {
            -- Area = 'Aeon_Main_Base_Area',
            -- MarkArea = false,
            Units = ScenarioInfo.M1BigAttackPlatoon:GetPlatoonUnits(),
            MarkUnits = false,
        }
   )
    ScenarioInfo.M1Objectives:AddObjective(ScenarioInfo.M1P3)

    ScenarioFramework.CreateTimerTrigger(UpdateM1P3, M1AeonBigAttackSafetyTimer)
end

-- ! Fires when M1P3 is completed
function UpdateM1P3()
    if ScenarioInfo.M1P3 and not ScenarioInfo.M1P3Updated then
        LOG('debug: Op: Arnold\'s big attack has been defeated.')
        if not ScenarioInfo.MissionFailed then
            ScenarioInfo.M1P3:ManualResult(true)
            ForkArnoldTaunt()

            ForkThread(EndMission1)
        end
        ScenarioInfo.M1P3Updated = true
    end
end

-- ! Assign M1P4 (Destroy all three of Arnold's nuke launchers.)
function AssignM1P4()
    ScenarioInfo.M1P4Assigned = true
    ScenarioFramework.Dialogue(OpStrings.E05_M01_065)
    ScenarioInfo.AeonNukeLaunchers = {ScenarioInfo.AeonNuke1, ScenarioInfo.AeonNuke2, ScenarioInfo.AeonNuke3}
    ScenarioInfo.M1P4 = Objectives.KillOrCapture(
        'primary',                      -- type
        'incomplete',                   -- complete
        OpStrings.M1P4Title,            -- title
        OpStrings.M1P4Description,      -- description
        {                               -- target
            Units = ScenarioInfo.AeonNukeLaunchers,
            FlashVisible = true,
            ShowProgress = true,
        }
   )
    ScenarioInfo.M1P4:AddResultCallback(
        function(result)
            ScenarioInfo.AeonNukesDestroyed = true
            ScenarioFramework.Dialogue(OpStrings.TAUNT15)

            -- Matt  10.16.06
            ForkThread(EndMission1)
        end
   )
    ScenarioInfo.M1Objectives:AddObjective(ScenarioInfo.M1P4)

    -- Todo Addmarker: Mark Arnold's other two nuke launchers

    -- ! Remind the player to do M1P4 after M1P4InitialReminderTimer
    ScenarioInfo.NextM1P4Reminder = 1
    ScenarioFramework.CreateTimerTrigger(M1P4Reminder, M1P4InitialReminderTimer)
end

-- ! Remind the player to destroy Arnold's nukes
function M1P4Reminder()
    while not ScenarioInfo.AeonNukesDestroyed do
        if ScenarioInfo.NextM1P4Reminder == 1 and not ScenarioInfo.OpEnded then
            ScenarioFramework.Dialogue(OpStrings.E05_M01_110)
            ScenarioInfo.NextM1P4Reminder = 2
        elseif ScenarioInfo.NextM1P4Reminder == 2 and not ScenarioInfo.OpEnded then
            ScenarioFramework.Dialogue(OpStrings.E05_M01_115)
            ScenarioInfo.NextM1P4Reminder = 1
        end
        WaitSeconds(M1P4OngoingReminderTimer)
    end
end

-- ! If an aeon nuke is destroyed, assign M1P4.
function AeonNukeHasBeenDestroyed(unit)
    -- If M1P4 hasn't been assigned yet, assign it.
    if not ScenarioInfo.M1P4Assigned then
        AssignM1P4()
    end
-- base Aeon nuke launcher destroyed cam
    local camInfo = {
        blendTime = 1.0,
        holdTime = 4,
        orientationOffset = { 0, 0.4, 0 },
        positionOffset = { 0, 0.5, 0 },
        zoomVal = 55,
    }
    if unit == ScenarioInfo.AeonNuke1 then
        camInfo.orientationOffset[1] = -2.3
    elseif unit == ScenarioInfo.AeonNuke2 then
        camInfo.orientationOffset[1] = -1.17
    elseif unit == ScenarioInfo.AeonNuke3 then
        camInfo.orientationOffset[1] = -2.3
    end
    ScenarioFramework.OperationNISCamera(unit, camInfo)

end

-- ! A facility died; update counters
function ResearchFacility1Destroyed(unit)
    LOG('debug: Op: Research Facility 1 died after making ' .. ScenarioInfo.ResearchFacility1TrucksProduced .. 'trucks')
    -- The trucks that were still in the factory will never be produced now.
    ScenarioInfo.PotentialUEFTrucks = ScenarioInfo.PotentialUEFTrucks - (ScenarioInfo.UEFTruckGroupSize - ScenarioInfo.ResearchFacility1TrucksProduced)

    -- ! Increment the number of dead facilities
    ScenarioInfo.FacilitiesDestroyedNumber = ScenarioInfo.FacilitiesDestroyedNumber + 1

    -- ! This facility is done making trucks.
    ScenarioInfo.ResearchFacility1Destroyed = true

    if ScenarioInfo.MissionNumber == 3 then
        CheckM3P1(unit)
    end
    ForkThread(ResearchFacilityDestroyedNISCamera, unit, ScenarioInfo.FacilitiesDestroyedNumber)
end

-- ! A facility died; update counters
function ResearchFacility2Destroyed(unit)
    LOG('debug: Op: Research Facility 2 died after making ' .. ScenarioInfo.ResearchFacility2TrucksProduced .. 'trucks')
    -- The trucks that were still in the factory will never be produced now.
    ScenarioInfo.PotentialUEFTrucks = ScenarioInfo.PotentialUEFTrucks - (ScenarioInfo.UEFTruckGroupSize - ScenarioInfo.ResearchFacility2TrucksProduced)

    -- ! Increment the number of dead facilities
    ScenarioInfo.FacilitiesDestroyedNumber = ScenarioInfo.FacilitiesDestroyedNumber + 1

    -- ! This facility is done making trucks.
    ScenarioInfo.ResearchFacility2Destroyed = true

    if ScenarioInfo.MissionNumber == 3 then
        CheckM3P1(unit)
    end
    ForkThread(ResearchFacilityDestroyedNISCamera, unit, ScenarioInfo.FacilitiesDestroyedNumber)
end

-- ! A facility died; update counters
function ResearchFacility3Destroyed(unit)
    LOG('debug: Op: Research Facility 3 died after making ' .. ScenarioInfo.ResearchFacility3TrucksProduced .. 'trucks')
    -- The trucks that were still in the factory will never be produced now.
    ScenarioInfo.PotentialUEFTrucks = ScenarioInfo.PotentialUEFTrucks - (ScenarioInfo.UEFTruckGroupSize - ScenarioInfo.ResearchFacility3TrucksProduced)

    -- ! Increment the number of dead facilities
    ScenarioInfo.FacilitiesDestroyedNumber = ScenarioInfo.FacilitiesDestroyedNumber + 1

    -- ! This facility is done making trucks.
    ScenarioInfo.ResearchFacility3Destroyed = true

    if ScenarioInfo.MissionNumber == 3 then
        CheckM3P1(unit)
    end
    ForkThread(ResearchFacilityDestroyedNISCamera, unit, ScenarioInfo.FacilitiesDestroyedNumber)
end

-- ! On hard, Aeon nukes should keep nuking the player
function AeonContinuedNukeAttacks()
    while not ScenarioInfo.AeonNukesDestroyed do
        local nukeSiloTable = ArmyBrains[Aeon]:GetListOfUnits(categories.uab2305, false)
        local nukeTargetTable = ArmyBrains[Player]:GetListOfUnits(categories.STRUCTURE - categories.ECONOMIC, false)
        local rndNuke = ScenarioFramework.GetRandomEntry(nukeSiloTable)
        local rndTarget = ScenarioFramework.GetRandomEntry(nukeTargetTable)
        IssueNuke({ rndNuke }, rndTarget)

        LOG('debug: Op: '..rndNuke.UnitName..' is nuking '..rndTarget.UnitName)

        local rndWait = Random(10, 120)
        WaitSeconds(rndWait)
    end
end

-- ! Check for all primary objectives complete
function EndMission1()
    if not ScenarioInfo.Mission1Done then
        LOG('debug: Op: EndMission1')
        -- m1p4 complete, m1p3 either complete or in a rare case unassigned. -matt 10.16.06
        if ScenarioInfo.AeonNukesDestroyed and not ScenarioInfo.M1P3.Active then
            ScenarioInfo.Mission1Done = true
            ScenarioFramework.Dialogue(OpStrings.E05_M01_080)

            WaitSeconds(2)
            ScenarioInfo.M1P1:ManualResult(true)

	   		-- ! If more than 10% of the town wasn't destroyed in M1, then the town was saved!
		    if not ScenarioInfo.M1S1Failed then
		        ScenarioInfo.M1S1:ManualResult(true)
		    end

            LOG('debug: Op: Mission2 is starting')
            StartMission2()

        end
    end
end

-- ===
-- === MISSION 2 FUNCTIONS === #
function StartMission2()
    ScenarioInfo.MissionNumber = 2

    ScenarioInfo.VarTable['BuildAeonSecondBasePatrols'] = true

    -- ! Set army unit caps
    SetArmyUnitCap(Aeon, 700)
    SetArmyUnitCap(Cybran, 700)
    SetArmyUnitCap(City, 225)

    ScenarioFramework.RemoveRestrictionForAllHumans(
        categories.ueb3104 + -- Omni Radar
        categories.uab3104 + -- Omni Radar
        categories.urb3104 + -- Omni Radar

        categories.ueb0304 + -- Quantum Gateway
        categories.uel0304 + -- Mobile Heavy Artillery
        categories.uel0301 + -- Sub Commander

        categories.uab0304 + -- Quantum Gateway
        categories.ual0304 + -- Mobile Heavy Artillery
        categories.ual0301 + -- Sub Commander

        categories.urb0304 + -- Quantum Gateway
        categories.url0304 + -- Mobile Heavy Artillery
        categories.url0301   -- Sub Commander
    )

    ScenarioFramework.RemoveRestriction(Aeon, categories.ueb0304 + -- Quantum Gateway
                                  categories.uel0301 + -- Sub Commander

                                  categories.uab0304 + -- Quantum Gateway
                                  categories.ual0301 + -- Sub Commander

                                  categories.urb0304 + -- Quantum Gateway
                                  categories.url0301) -- Sub Commander

    ScenarioFramework.RemoveRestriction(Cybran, categories.ueb0304 + -- Quantum Gateway
                                    categories.uel0301 + -- Sub Commander

                                    categories.uab0304 + -- Quantum Gateway
                                    categories.ual0301 + -- Sub Commander

                                    categories.urb0304 + -- Quantum Gateway
                                    categories.url0301) -- Sub Commander

    -- ! If we're on hard difficulty, give mobile heavy artillery to the Aeon and Cybran
    if ScenarioInfo.Difficulty == 3 then
        ScenarioFramework.RemoveRestriction(Aeon, categories.uel0304 + -- Mobile Heavy Artillery
                                      categories.ual0304 + -- Mobile Heavy Artillery
                                      categories.url0304) -- Mobile Heavy Artillery

        ScenarioFramework.RemoveRestriction(Cybran, categories.uel0304 + -- Mobile Heavy Artillery
                                        categories.ual0304 + -- Mobile Heavy Artillery
                                        categories.url0304) -- Mobile Heavy Artillery
    end

    -- ! Expand the map area
    ScenarioFramework.SetPlayableArea(M2PlayableArea)

    -- ! Spawn the Cybran LRA bases and the M2 Aeon bases
    ScenarioInfo.CybranLRA1BaseBuildings = ScenarioUtils.CreateArmyGroup('Cybran', 'LRA1_Base_Buildings_D'..ScenarioInfo.Difficulty)
    ScenarioInfo.CybranLRA2BaseBuildings = ScenarioUtils.CreateArmyGroup('Cybran', 'LRA2_Base_Buildings_D'..ScenarioInfo.Difficulty)
    ScenarioInfo.CybranLRA1 = ScenarioUtils.CreateArmyUnit('Cybran', 'Cybran_LRA_1')
    ScenarioInfo.CybranLRA2 = ScenarioUtils.CreateArmyUnit('Cybran', 'Cybran_LRA_2')
        -- ! Keep track of the Cybran LRHA
    ScenarioFramework.CreateUnitDeathTrigger(CybranLRHADestroyed, ScenarioInfo.CybranLRA1)
    ScenarioFramework.CreateUnitDeathTrigger(CybranLRHADestroyed, ScenarioInfo.CybranLRA2)

    -- ! Spawn 5 Cybran bases
    ScenarioInfo.CybranWBaseEngineers = ScenarioUtils.CreateArmyGroup('Cybran', 'W_Base_Engineers_D'..ScenarioInfo.Difficulty)
    ScenarioInfo.CybranWBaseBuildings = ScenarioUtils.CreateArmyGroup('Cybran', 'W_Base_Buildings_D'..ScenarioInfo.Difficulty)
    AIBuildStructures.CreateBuildingTemplate(ArmyBrains[ScenarioInfo.Cybran], 'Cybran', 'W_Base_Buildings')
    AIBuildStructures.AppendBuildingTemplate(ArmyBrains[ScenarioInfo.Cybran], 'Cybran', ('W_Base_Buildings_D'..ScenarioInfo.Difficulty), 'W_Base_Buildings')
    ScenarioInfo.CybranNWBaseEngineers = ScenarioUtils.CreateArmyGroup('Cybran', 'NW_Base_Engineers_D'..ScenarioInfo.Difficulty)
    ScenarioInfo.CybranNWBaseBuildings = ScenarioUtils.CreateArmyGroup('Cybran', 'NW_Base_Buildings_D'..ScenarioInfo.Difficulty)
    AIBuildStructures.CreateBuildingTemplate(ArmyBrains[ScenarioInfo.Cybran], 'Cybran', 'NW_Base_Buildings')
    AIBuildStructures.AppendBuildingTemplate(ArmyBrains[ScenarioInfo.Cybran], 'Cybran', ('NW_Base_Buildings_D'..ScenarioInfo.Difficulty), 'NW_Base_Buildings')
    ScenarioInfo.CybranNNWBaseEngineers = ScenarioUtils.CreateArmyGroup('Cybran', 'NNW_Base_Engineers_D'..ScenarioInfo.Difficulty)
    ScenarioInfo.CybranNNWBaseBuildings = ScenarioUtils.CreateArmyGroup('Cybran', 'NNW_Base_Buildings_D'..ScenarioInfo.Difficulty)
    AIBuildStructures.CreateBuildingTemplate(ArmyBrains[ScenarioInfo.Cybran], 'Cybran', 'NNW_Base_Buildings')
    AIBuildStructures.AppendBuildingTemplate(ArmyBrains[ScenarioInfo.Cybran], 'Cybran', ('NNW_Base_Buildings_D'..ScenarioInfo.Difficulty), 'NNW_Base_Buildings')
    ScenarioInfo.CybranNNEBaseEngineers = ScenarioUtils.CreateArmyGroup('Cybran', 'NNE_Base_Engineers_D'..ScenarioInfo.Difficulty)
    ScenarioInfo.CybranNNEBaseBuildings = ScenarioUtils.CreateArmyGroup('Cybran', 'NNE_Base_Buildings_D'..ScenarioInfo.Difficulty)
    AIBuildStructures.CreateBuildingTemplate(ArmyBrains[ScenarioInfo.Cybran], 'Cybran', 'NNE_Base_Buildings')
    AIBuildStructures.AppendBuildingTemplate(ArmyBrains[ScenarioInfo.Cybran], 'Cybran', ('NNE_Base_Buildings_D'..ScenarioInfo.Difficulty), 'NNE_Base_Buildings')
    ScenarioInfo.CybranNEBaseEngineers = ScenarioUtils.CreateArmyGroup('Cybran', 'NE_Base_Engineers_D'..ScenarioInfo.Difficulty)
    ScenarioInfo.CybranNEBaseBuildings = ScenarioUtils.CreateArmyGroup('Cybran', 'NE_Base_Buildings_D'..ScenarioInfo.Difficulty)
    AIBuildStructures.CreateBuildingTemplate(ArmyBrains[ScenarioInfo.Cybran], 'Cybran', 'NE_Base_Buildings')
    AIBuildStructures.AppendBuildingTemplate(ArmyBrains[ScenarioInfo.Cybran], 'Cybran', ('NE_Base_Buildings_D'..ScenarioInfo.Difficulty), 'NE_Base_Buildings')
        -- ! Keep track of the Cybran bases
    ScenarioFramework.CreateAreaTrigger(Cybran_W_Base_Area_Destroyed, ScenarioUtils.AreaToRect('Cybran_W_Base_Area'),
        categories.STRUCTURE - categories.WALL, true, true, ArmyBrains[Cybran], 1)
    ScenarioFramework.CreateAreaTrigger(Cybran_NW_Base_Area_Destroyed, ScenarioUtils.AreaToRect('Cybran_NW_Base_Area'),
        categories.STRUCTURE - categories.WALL, true, true, ArmyBrains[Cybran], 1)
    ScenarioFramework.CreateAreaTrigger(Cybran_NNW_Base_Area_Destroyed, ScenarioUtils.AreaToRect('Cybran_NNW_Base_Area'),
        categories.STRUCTURE - categories.WALL, true, true, ArmyBrains[Cybran], 1)
    ScenarioFramework.CreateAreaTrigger(Cybran_NNE_Base_Area_Destroyed, ScenarioUtils.AreaToRect('Cybran_NNE_Base_Area'),
        categories.STRUCTURE - categories.WALL, true, true, ArmyBrains[Cybran], 1)
    ScenarioFramework.CreateAreaTrigger(Cybran_NE_Base_Area_Destroyed, ScenarioUtils.AreaToRect('Cybran_NE_Base_Area'),
        categories.STRUCTURE - categories.WALL, true, true, ArmyBrains[Cybran], 1)

    -- ! Spawn the Cybran walls (kept separate so they aren't counted in the group death triggers)
    ScenarioInfo.CybranWalls = ScenarioUtils.CreateArmyGroup('Cybran', 'Cybran_Walls_D'..ScenarioInfo.Difficulty)

    -- ! Spawn Cybran commander
    ScenarioInfo.CybranCDR = ScenarioUtils.CreateArmyUnit('Cybran', 'Commander')
    ScenarioInfo.CybranCDR:SetReclaimable(false)
    ScenarioInfo.CybranCDR:SetCapturable(false)
    ScenarioInfo.CybranCDR:SetCustomName(LOC '{i CDR_Mach}')
    ScenarioInfo.CybranCDR:CreateEnhancement('AdvancedEngineering')
    ScenarioInfo.CybranCDR:CreateEnhancement('MicrowaveLaserGenerator')
    ScenarioInfo.CybranCDR:CreateEnhancement('CloakingGenerator')


    ScenarioFramework.CreateUnitDeathTrigger(CybranCDRKilled, ScenarioInfo.CybranCDR)


    -- ! Spawn Aeon dummy base to get targeted by LRHA base 2
    ScenarioInfo.AeonDummyBase = ScenarioUtils.CreateArmyGroup('Aeon', 'Aeon_Dummy_Base')
        -- ! Once the Aeon dummy base is dead, LRHA start shelling the player
    ScenarioFramework.CreateGroupDeathTrigger(StartMission2Part2, ScenarioInfo.AeonDummyBase)
    ScenarioFramework.CreateTimerTrigger(StartMission2Part2, M2LrhaAttackPlayerDelay)

    -- ! Spawn the secondary Aeon base and the Aeon commander (Arnold)
    ScenarioInfo.AeonSecondBaseEngineers = ScenarioUtils.CreateArmyGroup('Aeon', 'Second_Base_Engineers_D'..ScenarioInfo.Difficulty)
    ScenarioInfo.AeonSecondBaseBuildings = ScenarioUtils.CreateArmyGroup('Aeon', 'Second_Base_Buildings_D'..ScenarioInfo.Difficulty)
    AIBuildStructures.CreateBuildingTemplate(ArmyBrains[ScenarioInfo.Aeon], 'Aeon', 'Second_Base_Buildings')
    AIBuildStructures.AppendBuildingTemplate(ArmyBrains[ScenarioInfo.Aeon], 'Aeon', ('Second_Base_Buildings_D'..ScenarioInfo.Difficulty), 'Second_Base_Buildings')
        -- ! Spawning walls separately because I don't want engineers to maintain them
    ScenarioInfo.AeonWalls = ScenarioUtils.CreateArmyGroup('Aeon', 'Aeon_Walls_D'..ScenarioInfo.Difficulty)

    -- Arnold
    ScenarioInfo.AeonCDR = ScenarioUtils.CreateArmyUnit('Aeon', 'Commander_Arnold')
    ScenarioInfo.AeonCDR:SetCustomName(LOC '{i CDR_Arnold}')
    ScenarioInfo.AeonCDR:SetReclaimable(false)
    ScenarioInfo.AeonCDR:SetCapturable(false)
    ScenarioInfo.AeonCDR:CreateEnhancement('AdvancedEngineering')
    ScenarioInfo.AeonCDR:CreateEnhancement('ChronoDampener')
    ScenarioInfo.AeonCDR:CreateEnhancement('CrysalisBeam')
    ScenarioInfo.AeonCDR:CreateEnhancement('ShieldHeavy')
        -- ! If Arnold is killed, make him disappear.
    ScenarioInfo.AeonCDR.OnKilled = function(self, instigator, type, overkillRatio)-- Replacing Arnold's normal death function with one that makes him disappear
        AeonCDRDamaged(instigator)
    end

    -- Overcharge manager for Arnold
    ScenarioInfo.AeonCDR.CDRData = {}
    ScenarioInfo.AeonCDR.CDRData.LeashPosition = 'Aeon_Second_Base'
    ScenarioInfo.AeonCDR.CDRData.LeashRadius = 30
    ScenarioInfo.AeonCDR.OverchargeThread = ScenarioInfo.AeonCDR:ForkThread(OpBehaviors.CDROverChargeThread)
    ScenarioInfo.AeonCDR.LeashThread      = ScenarioInfo.AeonCDR:ForkThread(OpBehaviors.CDRLeashThread)
    ScenarioInfo.AeonCDR.RunAwayThread    = ScenarioInfo.AeonCDR:ForkThread(OpBehaviors.CDRRunAwayThread)


    -- ! If the second Aeon base gets destroyed, the W Cybran Base should attack the player
    ScenarioFramework.CreateAreaTrigger(AeonSecondBaseKilled, ScenarioUtils.AreaToRect('Aeon_Second_Base_Area'),
        categories.STRUCTURE - categories.WALL, true, true, ArmyBrains[Aeon], 1)

    -- ! Mach taunts when you see his attacking units
    ScenarioFramework.CreateArmyIntelTrigger(ForkMachTaunt, ArmyBrains[Player], 'LOSNow', false, true, categories.MOBILE, true, ArmyBrains[Cybran])

    -- ! Start attacks between Cybran and Aeon
    ScenarioInfo.VarTable['BuildCybranM2AeonAttack'] = true

    -- ! Assign M2P1: Protect 2/3 research facilities.
    ScenarioInfo.M2Objectives = Objectives.CreateGroup('Mission2', EndMission2) -- function() LOG('debug:M2Objective group complete')  end)
    local researchFacilitiesGroup = {ScenarioInfo.ResearchFacility1, ScenarioInfo.ResearchFacility2, ScenarioInfo.ResearchFacility3}
    ScenarioInfo.M2P1 = Objectives.Protect(-- Todo: Get a version of Protect that has a marker
        'primary',                      -- type
        'incomplete',                   -- complete
        OpStrings.M2P1Title,            -- title
        OpStrings.M2P1Description,      -- description
        {                               -- target
            Units = researchFacilitiesGroup,          -- group to protect
            Timer = nil,                -- if nil, requires a manual update for completion
            NumRequired = 2,            -- How many must survive
        }
   )
    ScenarioInfo.M2P1:AddResultCallback(
        function(result, unit)
            if not result then
                PlayerLose(OpStrings.E05_M01_070)
            end
        end
   )
    -- Matt 11/20/06 removed when combined with m3p1
    -- ScenarioInfo.M2Objectives:AddObjective(ScenarioInfo.M2P1)

    -- ! Tell the LRA bases to start shelling the Aeon
    IssueAttack({ScenarioInfo.CybranLRA1}, ScenarioUtils.MarkerToPosition('LRA1_Aeon_Target'))
    IssueAttack({ScenarioInfo.CybranLRA2}, ScenarioUtils.MarkerToPosition('LRA2_Aeon_Target'))
    LOG('debug: Op: LRHAs are now shelling the Aeon bases')

    -- ! Give missiles to enemy anti-nukes
    local aeonMissileDefense = ArmyBrains[Aeon]:GetListOfUnits(categories.uab4302, false)
    for k, unit in aeonMissileDefense do
        unit:GiveTacticalSiloAmmo(5)
    end

    local cybranMissileDefense = ArmyBrains[Cybran]:GetListOfUnits(categories.urb4302, false)
    for k, unit in cybranMissileDefense do
        unit:GiveTacticalSiloAmmo(5)
    end

end

-- ! Arnold disappears instead of dying.
function AeonCDRDamaged(instigator)
    local damagerArmy = instigator:GetArmy()
    if (damagerArmy == Player) then
        ScenarioFramework.Dialogue(OpStrings.E05_M03_140)
    end

    -- ScenarioInfo.AeonCDR:Destroy() #Polish: maybe a teleport effect?
    ForkThread(function ()
                    -- Start NIS of focused on Arnold, and teleport him out
                    ScenarioFramework.CDRDeathNISCamera(ScenarioInfo.AeonCDR, 7)
                    ScenarioFramework.FakeTeleportUnit(ScenarioInfo.AeonCDR, true)
                end)
    ScenarioInfo.ArnoldDead = true
end

-- ! If Mach is killed, play a dialogue and set his death variable
function CybranCDRKilled(unit)
    ScenarioFramework.Dialogue(OpStrings.E05_M02_030)
    ScenarioInfo.MachDead = true

    -- NIS of the Cybran commander being killed
    ScenarioFramework.CDRDeathNISCamera(unit, 7)
end

-- ! The secondary Aeon base has been destroyed. The West Cybran base should now attack the player (taken care of in Attack Manager)
function AeonSecondBaseKilled()
    ScenarioInfo.VarTable['BuildCybranM2AeonAttack'] = false
    ScenarioInfo.VarTable['BuildCybranWM2PlayerAttack'] = true
end

-- ! After the dummy Aeon base is destroyed, have the LRHA attack the player and assign M2P2.
function StartMission2Part2()
    -- ! Start Cybran attacks against the player
    ScenarioInfo.VarTable['BuildCybranPlayerAttacks'] = true
    LOG('debug: Op: Cybran bases are now attacking the player')
    ScenarioInfo.VarTable['BuildAeonSecondBasePatrols'] = false

    if not ScenarioInfo.StartMission2Part2Ran then
        ScenarioFramework.Dialogue(OpStrings.E05_M02_010)
        -- Todo: Motion capture of LRHAs

        if ScenarioInfo.Difficulty == 3 then
            -- Let LRHAs shell whatever they want on hard
            IssueClearCommands({ScenarioInfo.CybranLRA1})
            IssueClearCommands({ScenarioInfo.CybranLRA2})
        elseif ScenarioInfo.Difficulty == 2 then
            -- Have LRHAs shell Aeon base and near a research facility on medium
            IssueClearCommands({ScenarioInfo.CybranLRA1})
            IssueAttack({ScenarioInfo.CybranLRA1}, ScenarioUtils.MarkerToPosition('LRA1_Player_Target_Medium'))
        else
            -- Have LRHAs shell aeon base and non-essential buildings on easy
            IssueClearCommands({ScenarioInfo.CybranLRA1})
            IssueAttack({ScenarioInfo.CybranLRA1}, ScenarioUtils.MarkerToPosition('LRA1_Player_Target_Easy'))
        end

        -- ! Show the LRA bases to the player
        ScenarioFramework.CreateVisibleAreaLocation(50, ScenarioUtils.MarkerToPosition('Cybran_LRA_Base_1'), 40, ArmyBrains[Player])
        ScenarioFramework.CreateVisibleAreaLocation(50, ScenarioUtils.MarkerToPosition('Cybran_LRA_Base_2'), 40, ArmyBrains[Player])

        -- ! The cybran army is revealed
        -- Cybran.SetArmyShowScore = true

        -- ! Assign M2P2 (Take out cybran LRA bases)
        ScenarioFramework.Dialogue(OpStrings.E05_M02_020)
        ScenarioInfo.CybranLRHA = {ScenarioInfo.CybranLRA1, ScenarioInfo.CybranLRA2}
        ScenarioInfo.M2P2 = Objectives.KillOrCapture(
            'primary',                      -- type
            'incomplete',                   -- complete
            OpStrings.M2P2Title,            -- title
            OpStrings.M2P2Description,      -- description
            {                               -- target
                Units = ScenarioInfo.CybranLRHA,
            }
        )
        ScenarioInfo.M2P2:AddResultCallback(
            function(result)
                ScenarioInfo.M2P2Complete = true
                ScenarioFramework.Dialogue(OpStrings.E05_M02_040)
                -- removed when combined with m3p1
                -- ScenarioInfo.M2P1:ManualResult(true)
            end
        )
        ScenarioInfo.M2Objectives:AddObjective(ScenarioInfo.M2P2)

        -- ! Remind the player to do M2P2 after M2P2ReminderTimer
        ScenarioInfo.NextM2P2Reminder = 1
        ScenarioFramework.CreateTimerTrigger(M2P2Reminder, M2P2ReminderTimer)

        -- ! Give the player access to nukes
        ScenarioFramework.RemoveRestrictionForAllHumans(categories.ueb2305 + categories.uab2305 + categories.urb2305)

        ScenarioInfo.StartMission2Part2Ran = true
    end
end

-- ! If the player kills an LRHA early, run Mission2 Part 2.
function CybranLRHADestroyed(unit)
    if not ScenarioInfo.StartMission2Part2Ran then
        StartMission2Part2()
    end

-- base cybran LRA destroyed cam
    local camInfo = {
        blendTime = 1.0,
        holdTime = 4,
        orientationOffset = { 0, 0.2, 0 },
        positionOffset = { 0, 0.5, 0 },
        zoomVal = 40,
    }
    if unit == ScenarioInfo.CybranLRA1 then
        camInfo.orientationOffset = { -0.7, 0.8, 0 }
    elseif unit == ScenarioInfo.CybranLRA2 then
        camInfo.orientationOffset[1] = 2.3
    end
    ScenarioFramework.OperationNISCamera(unit, camInfo)
end

-- ! Remind the player to do M2P2
function M2P2Reminder()
    while not ScenarioInfo.M2P2Complete do
        if ScenarioInfo.NextM2P2Reminder == 1 and not ScenarioInfo.OpEnded then
            ScenarioFramework.Dialogue(OpStrings.E05_M02_050)
            ScenarioInfo.NextM2P2Reminder = 2
        elseif ScenarioInfo.NextM2P2Reminder == 2 and not ScenarioInfo.OpEnded then
            ScenarioFramework.Dialogue(OpStrings.E05_M02_055)
            ScenarioInfo.NextM2P2Reminder = 1
        end
        WaitSeconds(M2P2ReminderTimer)
    end
end

-- ! Check for all primary objectives complete
function EndMission2()
    if not ScenarioInfo.Mission2Done then
        ScenarioInfo.Mission2Done = true
        -- ! Tell the player the trucks will be ready to leave soon
        ScenarioFramework.Dialogue(OpStrings.E05_M03_010, StartMission3)
    end
end

-- ===
-- === MISSION 3 FUNCTIONS === #
function StartMission3()

    LOG('debug: Op: Mission3 is starting')

    ScenarioInfo.MissionNumber = 3

    -- ! Set army unit caps
    SetArmyUnitCap(Aeon, 500)
    SetArmyUnitCap(Cybran, 500)
    SetArmyUnitCap(City, 125)

    ScenarioFramework.SetPlayableArea(M3PlayableArea)

    -- ! Get ready to spawn truck group 1
    ForkThread(CreateTruckGroup)

    -- ! Assign M3P1: protect the research facilities
    -- ScenarioInfo.M3Objectives = Objectives.CreateGroup('Mission3', PlayerWin)

    -- Matt 11/20/06: this is almost certainly a bad idea. But I'm combining the 2 obectives below.
    ScenarioInfo.M3P1 = ScenarioInfo.M2P1
    -- updating the description doesnt seem to work, and they're pretty similar, so keep m2 desc.
    -- Objectives.UpdateObjective(ScenarioInfo.M3P1.Title, 'description', OpStrings.M3P1Description, ScenarioInfo.M3P1.Tag)
--    Objectives.Basic(
--    'primary',                      # type
--    'incomplete',                   # complete
--    OpStrings.M3P1Title,            # title
--    OpStrings.M3P1Description,      # description
--    Objectives.GetActionIcon('protect'),
--    {                               # target
--        #Area = 'RF1_Truck_Area',
--        #MarkArea = false,
--        Units = researchFacilitiesGroup,          # group to mark
--    }
-- )
-- ScenarioInfo.M3Objectives:AddObjective(ScenarioInfo.M3P1)

    -- ! Assign M3P2: get the trucks to the gate
    ScenarioInfo.M3P2 = Objectives.Basic (
        'primary',                      -- type
        'incomplete',                   -- complete
        OpStrings.M3P2Title,            -- title
        LOCF(OpStrings.M3P2Description, ScenarioInfo.RequiredUEFTrucks),      -- description
        Objectives.GetActionIcon('move'),
        {                               -- target
            Area = 'Gate_Area',
            MarkArea = true, -- Todo: Change this to mark the quantum gate when that's in
            -- Units = {ScenarioInfo.Gate},
            -- MarkUnits = true,
        }
   )
    ScenarioInfo.M3P2:AddResultCallback(
-- NIS for when the sufficient number of trucks makes it through the gate
        function(result)
            local camInfo = {
                blendTime = 1.0,
                holdTime = 4,
                orientationOffset = { -2.2, 0.9, 0 },
                positionOffset = { 0, 0.5, 0 },
                zoomVal = 40,
                markerCam = true,
            }
            ScenarioFramework.OperationNISCamera(ScenarioUtils.MarkerToPosition("Gate_Position"), camInfo)
        end
   )
    -- ScenarioInfo.M3Objectives:AddObjective(ScenarioInfo.M3P2)
    ScenarioFramework.M3GateTrigger = ScenarioFramework.CreateAreaTrigger(SendTruckThroughGate, ScenarioUtils.AreaToRect('CDR_Gate_Area'),
        (categories.uec0001), false, false, ArmyBrains[ScenarioInfo.Player], 1, true)


    -- ! Assign M3S1: destroy all the Cybran bases
    ScenarioInfo.M3S1 = Objectives.Basic(
        'primary',                      -- type
        'incomplete',                   -- complete
        OpStrings.M3S1Title,            -- title
        OpStrings.M3S1Description,      -- description
        Objectives.GetActionIcon('kill'),
        {                               -- target
            ShowFaction = 'Cybran',
            Areas = { 'Cybran_W_Base_Area', 'Cybran_NE_Base_Area', 'Cybran_NNE_Base_Area', 'Cybran_NNW_Base_Area', 'Cybran_NW_Base_Area', },
            MarkArea = true,
        }
   )

    -- ScenarioInfo.M3Objectives:AddObjective(ScenarioInfo.M3S1)

    -- ! Start sending Cybran and Aeon attacks
    LOG('debug: Op: Cybran and Aeon are attacking each other and the player now')
end

-- ! If a research facility dies, check if we fail M3P1
function CheckM3P1(unit)
    if ((ScenarioInfo.PotentialUEFTrucks + ScenarioInfo.NumUEFTrucksAlive + ScenarioInfo.NumUEFTrucksThroughGate) < ScenarioInfo.RequiredUEFTrucks) then
        -- You'll never get enough trucks. You fail.
        ScenarioInfo.M3P1:ManualResult(false)
        ScenarioInfo.MissionFailed = true
        PlayerLose(OpStrings.E05_M03_180)
    end
end


-- ! Track M3S1 (Defeat all 5 Cybran bases). Each base passes in a loc for use if it is the final destroyed base (for NIS)
function Cybran_W_Base_Area_Destroyed()
    CybranBaseDestroyed(ScenarioUtils.MarkerToPosition("Cybran_W_Base_Location"))
    -- Cybran_W_Base_Location
end

function Cybran_NW_Base_Area_Destroyed()
    CybranBaseDestroyed(ScenarioUtils.MarkerToPosition("Cybran_Base_NW"))
    -- Cybran_Base_NW
end

function Cybran_NNW_Base_Area_Destroyed()
    CybranBaseDestroyed(ScenarioUtils.MarkerToPosition("Cybran_NNW_Location"))
    -- Cybran_NNW_Location
end

function Cybran_NNE_Base_Area_Destroyed()
    CybranBaseDestroyed(ScenarioUtils.MarkerToPosition("Cybran_Base_NNE"))
    -- Cybran_Base_NNE
end

function Cybran_NE_Base_Area_Destroyed()
    CybranBaseDestroyed(ScenarioUtils.MarkerToPosition("Cybran_Base_NE"))
    -- Cybran_Base_NE
end

function CybranBaseDestroyed(marker)
    -- ! Count number of Cybran bases that have been destroyed
    ScenarioInfo.CybranBasesDestroyed = ScenarioInfo.CybranBasesDestroyed +1
    -- Todo Addmarker: remove marker from base?

    Objectives.UpdateBasicObjective(ScenarioInfo.M3S1, 'progress', LOCF(OpStrings.M3S1Progress, ScenarioInfo.CybranBasesDestroyed))
	Objectives.UpdateObjective(OpStrings.X03_M03_OBJ_010_010, 'Progress', '(1/2)', ScenarioInfo.M3P1.Tag )

    -- ! If 5 have been destroyed, then complete M3S1, and play an NIS at the marker passed in
    if ScenarioInfo.CybranBasesDestroyed >= 5 then
        ScenarioInfo.M3S1:ManualResult(true)
--    local camInfo = {
--        blendTime = 1.0,
--        holdTime = 4,
--        orientationOffset = { 2.67, 0.4, 0 },
--        positionOffset = { 0, 0.5, 0 },
--        zoomVal = 55,
--        markerCam = true,
--    }
--    ScenarioFramework.OperationNISCamera(marker, camInfo)
    end
end

-- ! 60-second warning for first truck group being spawned
function GiveTruckGroup1DialogueWarning()
    if not ScenarioInfo.ResearchFacility1Destroyed then -- If the facility's dead, it can't make trucks.
        ScenarioFramework.Dialogue(OpStrings.E05_M03_020)
        -- Todo Addmarker: Add or flash marker at RF1
    end
end

-- ! 60-second warning for first truck group being spawned
function GiveTruckGroup2DialogueWarning()
    if not ScenarioInfo.ResearchFacility2Destroyed then -- If the facility's dead, it can't make trucks.
        -- Dialog implies trucks had alread spawn, so lets cut it -matt 10.18.06
        -- ScenarioFramework.Dialogue(OpStrings.E05_M03_050)
        -- Todo Addmarker: Add or flash marker at RF2
    end
end

-- ! 60-second warning for first truck group being spawned
function GiveTruckGroup3DialogueWarning()
    if not ScenarioInfo.ResearchFacility3Destroyed then -- If the facility's dead, it can't make trucks.
        -- Dialog implies trucks had alread spawn, so lets cut it -matt 10.18.06
        -- ScenarioFramework.Dialogue(OpStrings.E05_M03_080)
        -- Todo Addmarker: Add or flash marker at RF3
    end
end

-- ! Spawn the next appropriate Truck Group
function CreateTruckGroup()
    ScenarioInfo.AeonTruckAttack = true -- The Aeon should stop attacking the Cybran and go for the player
    if ScenarioInfo.NumUEFTrucksThroughGate < ScenarioInfo.RequiredUEFTrucks then
        -- ! Make the appropriate truck group
        if ScenarioInfo.CurrentTruckGroup == 1 then
            if not ScenarioInfo.ResearchFacility1Destroyed then -- If the facility's dead, it can't make trucks.
                LOG('debug: Op: Facility 1 has been told to make trucks')
                ScenarioFramework.CreateTimerTrigger(GiveTruckGroup1DialogueWarning, ScenarioInfo.M2TruckGroup1Delay - ScenarioInfo.M2TruckDialogueToSpawnDelay)
                ScenarioFramework.CreateTimerTrigger(CreateTruckGroupAtFacility1, ScenarioInfo.M2TruckGroup1Delay)
            elseif not ScenarioInfo.ResearchFacility2Destroyed then -- If the facility's dead, it can't make trucks.
                LOG('debug: Op: Facility 1 was going to make trucks now, but it\'s destroyed.')
                LOG('debug: Op: Facility 2 has been told to make trucks')
                ScenarioInfo.CurrentTruckGroup = 2
                ScenarioFramework.CreateTimerTrigger(GiveTruckGroup2DialogueWarning, ScenarioInfo.M2TruckGroup2Delay - ScenarioInfo.M2TruckDialogueToSpawnDelay)
                ScenarioFramework.CreateTimerTrigger(CreateTruckGroupAtFacility2, ScenarioInfo.M2TruckGroup2Delay)
            else
                LOG('debug: Op: Facility 2 was going to make trucks now, but it\'s destroyed.')
                LOG('debug: Op: Facility 3 has been told to make trucks')
                ScenarioInfo.CurrentTruckGroup = 3
                ScenarioFramework.CreateTimerTrigger(GiveTruckGroup3DialogueWarning, ScenarioInfo.M2TruckGroup3Delay - ScenarioInfo.M2TruckDialogueToSpawnDelay)
                ScenarioFramework.CreateTimerTrigger(CreateTruckGroupAtFacility3, ScenarioInfo.M2TruckGroup3Delay)
            end
        elseif ScenarioInfo.CurrentTruckGroup == 2 then
            if not ScenarioInfo.ResearchFacility2Destroyed then -- If the facility's dead, it can't make trucks.
                LOG('debug: Op: Facility 2 has been told to make trucks')
                ScenarioFramework.CreateTimerTrigger(GiveTruckGroup2DialogueWarning, ScenarioInfo.M2TruckGroup2Delay - ScenarioInfo.M2TruckDialogueToSpawnDelay)
                ScenarioFramework.CreateTimerTrigger(CreateTruckGroupAtFacility2, ScenarioInfo.M2TruckGroup2Delay)
            elseif not ScenarioInfo.ResearchFacility3Destroyed then -- If the facility's dead, it can't make trucks.
                LOG('debug: Op: Facility 2 was going to make trucks now, but it\'s destroyed.')
                LOG('debug: Op: Facility 3 has been told to make trucks')
                ScenarioInfo.CurrentTruckGroup = 3
                ScenarioFramework.CreateTimerTrigger(GiveTruckGroup3DialogueWarning, ScenarioInfo.M2TruckGroup3Delay - ScenarioInfo.M2TruckDialogueToSpawnDelay)
                ScenarioFramework.CreateTimerTrigger(CreateTruckGroupAtFacility3, ScenarioInfo.M2TruckGroup3Delay)
            else
                LOG('debug: Op: Facility 3 was going to make trucks now, but it\'s destroyed.')
                ScenarioInfo.CurrentTruckGroup = 4
                LOG('debug: Op: Something is wrong; the facilities are done making trucks, but there aren\'t enough.')
            end
        elseif ScenarioInfo.CurrentTruckGroup == 3 then
            if not ScenarioInfo.ResearchFacility3DoneMakingTrucks then -- If the facility's dead, it can't make trucks.
                LOG('debug: Op: Facility 3 has been told to make trucks')
                ScenarioFramework.CreateTimerTrigger(GiveTruckGroup3DialogueWarning, ScenarioInfo.M2TruckGroup3Delay - ScenarioInfo.M2TruckDialogueToSpawnDelay)
                ScenarioFramework.CreateTimerTrigger(CreateTruckGroupAtFacility3, ScenarioInfo.M2TruckGroup3Delay)
            else
                LOG('debug: Op: Facility 3 was going to make trucks now, but it\'s destroyed.')
                ScenarioInfo.CurrentTruckGroup = 4
                LOG('debug: Op: Something is wrong; the facilities are done making trucks, but there aren\'t enough.')
            end
        elseif (ScenarioInfo.CurrentTruckGroup == 4 and ScenarioInfo.NumUEFTrucksThroughGate + ScenarioInfo.NumUEFTrucksAlive < ScenarioInfo.RequiredUEFTrucks) then
            LOG('debug: Op: Something is wrong; the facilities are done making trucks, but there aren\'t enough.')
        end
    end
end

function CreateTruckGroupAtFacility1()
    if not ScenarioInfo.ResearchFacility1Destroyed then -- If the facility's dead, it can't make trucks.
        LOG('debug: Op: Facility 1 is making trucks')
        local n = 1
        -- ! Make as many trucks as are needed to fill the group.
        while (ScenarioInfo.NumUEFTrucksAlive < ScenarioInfo.UEFTruckGroupSize) and not ScenarioInfo.ResearchFacility1Destroyed do
            CreateTruckAtFacility1(n)
            n = n+1
            if not (ScenarioInfo.ResearchFacility1TrucksProduced >= ScenarioInfo.UEFTruckGroupSize) then
                -- ! Adjust truck counters
                if not (ScenarioInfo.Difficulty == 1) then -- Don't deplete potential truck pool on Easy diff, since we can make infinite trucks.
                    ScenarioInfo.PotentialUEFTrucks = ScenarioInfo.PotentialUEFTrucks - 1
                end
                ScenarioInfo.ResearchFacility1TrucksProduced = ScenarioInfo.ResearchFacility1TrucksProduced + 1
            end
            WaitSeconds(4)
        end

        ScenarioFramework.CreateAreaTrigger(RF1TrucksMoved, ScenarioUtils.AreaToRect('RF1_Truck_Area'), categories.uec0001, true, true, ArmyBrains[Player], 1)

        -- ! If we make this truck group again, don't have as long a delay
        ScenarioInfo.M2TruckGroup1Delay = 60

        -- ! Tell the player that the truck is leaving
        if ScenarioInfo.LastCreatedTruckGroup == 1 then
            -- If this truck group has already been made once, play the dialogue for a respawned group
            ScenarioFramework.Dialogue(OpStrings.E05_M03_045)
        else
            -- Otherwise play the dialogue for the first truck group
            ScenarioFramework.Dialogue(OpStrings.E05_M03_030)
        end
        -- NIS for the first group of trucks made from the Facility1 location
        ForkThread(TruckSpawnNISCamera, ScenarioUtils.MarkerToPosition("Research_Facility_1"))
        -- Todo Addmarker: Add or flash marker at RF1 and gate

        -- ! The truck group is alive now
        ScenarioInfo.LastCreatedTruckGroup = 1

        -- ! Remind the player to do M3P2 after M3P2ReminderTimer
        ScenarioInfo.NextM3P2Reminder = 1
        ScenarioFramework.CreateTimerTrigger(M3P2Reminder, M3P2ReminderTimer)
    else
        LOG('debug: Op: Facility 1 was going to make trucks now, but it\'s destroyed.')
        -- ! Don't have as long a delay for the next truck group
        ScenarioInfo.M2TruckGroup2Delay = 60
        ForkThread(CreateTruckGroup)
    end
end

function CreateTruckAtFacility1(n)
    SetIgnoreArmyUnitCap(Player, true)
    local truck = ScenarioUtils.CreateArmyUnit('Player', 'Truck1')
    SetIgnoreArmyUnitCap(Player, false)
    ScenarioFramework.CreateUnitDeathTrigger(TruckKilled, truck)
    ScenarioFramework.CreateUnitToMarkerDistanceTrigger(TruckNearGate, truck, ScenarioUtils.MarkerToPosition('Gate_Position'), 30)
    -- ! Line up the trucks nicely
    local x, y, z = unpack(truck:GetPosition())
    local offset = n
    if offset <= 8 then
        IssueMove({truck}, {x + 3 - offset, y, z + 5})
    else
        IssueMove({truck}, {x + 11 - offset, y, z + 3})
    end
    ScenarioInfo.NumUEFTrucksAlive = ScenarioInfo.NumUEFTrucksAlive + 1
    ScenarioInfo.M3P2:AddBasicUnitTarget (truck)
    -- ! Taunt if a truck is damaged
    truck.OnDamage =
        function(self, instigator, amount, vector, damageType)
            if self.CanTakeDamage then
                self:DoOnDamagedCallbacks(instigator)
                self:DoTakeDamage(instigator, amount, vector, damageType)
            end
            local damagerArmy = instigator:GetArmy()
            if (damagerArmy == Aeon) then
                ForkArnoldTaunt()
            elseif (damagerArmy == Cybran) then
                ForkMachTaunt()
            end
        end
end

function CreateTruckGroupAtFacility2()
    if not ScenarioInfo.ResearchFacility2Destroyed then -- If the facility's dead, it can't make trucks.
        LOG('debug: Op: Facility 2 is making trucks')
        local n = 1
        -- ! Make as many trucks as are needed to fill the group.
        while (ScenarioInfo.NumUEFTrucksAlive < ScenarioInfo.UEFTruckGroupSize) and not ScenarioInfo.ResearchFacility2Destroyed do
            CreateTruckAtFacility2(n)
            n = n+1
            if not (ScenarioInfo.ResearchFacility2TrucksProduced >= ScenarioInfo.UEFTruckGroupSize) then
                -- ! Adjust truck counters
                if not (ScenarioInfo.Difficulty == 1) then -- Don't deplete potential truck pool on Easy diff, since we can make infinite trucks.
                    ScenarioInfo.PotentialUEFTrucks = ScenarioInfo.PotentialUEFTrucks - 1
                end
                ScenarioInfo.ResearchFacility2TrucksProduced = ScenarioInfo.ResearchFacility2TrucksProduced + 1
            end
            WaitSeconds(4)
        end

        ScenarioFramework.CreateAreaTrigger(RF2TrucksMoved, ScenarioUtils.AreaToRect('RF2_Truck_Area'), categories.uec0001, true, true, ArmyBrains[Player], 1)

        -- ! If we make this truck group again, don't have as long a delay
        ScenarioInfo.M2TruckGroup2Delay = 60

        -- ! Tell the player that the truck is leaving
        if ScenarioInfo.LastCreatedTruckGroup == 2 then
            -- If this truck group has already been made once, play the dialogue for a respawned group
            ScenarioFramework.Dialogue(OpStrings.E05_M03_075)
        else
            -- Otherwise play the dialogue for the first truck group
            ScenarioFramework.Dialogue(OpStrings.E05_M03_060)
        end
        -- NIS for the first group of trucks made from the Facility2 location
        ForkThread(TruckSpawnNISCamera, ScenarioUtils.MarkerToPosition("Research_Facility_2"))
        -- Todo Addmarker: Add or flash marker at RF2 and gate

        -- ! The truck group is alive now
        ScenarioInfo.LastCreatedTruckGroup = 2

        -- ! Remind the player to do M3P2 after M3P2ReminderTimer
        ScenarioInfo.NextM3P2Reminder = 1
        ScenarioFramework.CreateTimerTrigger(M3P2Reminder, M3P2ReminderTimer)
    else
        LOG('debug: Op: Facility 2 was going to make trucks now, but it\'s destroyed.')
        -- ! Don't have as long a delay for the next truck group
        ScenarioInfo.M2TruckGroup3Delay = 60
        ForkThread(CreateTruckGroup)
    end
end

function CreateTruckAtFacility2(n)
    SetIgnoreArmyUnitCap(Player, true)
    local truck = ScenarioUtils.CreateArmyUnit('Player', 'Truck2')
    SetIgnoreArmyUnitCap(Player, false)
    ScenarioFramework.CreateUnitDeathTrigger(TruckKilled, truck)
    ScenarioFramework.CreateUnitToMarkerDistanceTrigger(TruckNearGate, truck, ScenarioUtils.MarkerToPosition('Gate_Position'), 30)
    -- ! Line up the trucks nicely
    local x, y, z = unpack(truck:GetPosition())
    local offset = n
    if offset <= 8 then
        IssueMove({truck}, {x - 3 + offset, y, z - 5})
    else
        IssueMove({truck}, {x - 11 + offset, y, z - 3})
    end
    ScenarioInfo.NumUEFTrucksAlive = ScenarioInfo.NumUEFTrucksAlive + 1
    ScenarioInfo.M3P2:AddBasicUnitTarget (truck)
    -- ! Taunt if a truck is damaged
    truck.OnDamage =
        function(self, instigator, amount, vector, damageType)
            if self.CanTakeDamage then
                self:DoOnDamagedCallbacks(instigator)
                self:DoTakeDamage(instigator, amount, vector, damageType)
            end
            local damagerArmy = instigator:GetArmy()
            if (damagerArmy == Aeon) then
                ForkArnoldTaunt()
            elseif (damagerArmy == Cybran) then
                ForkMachTaunt()
            end
        end
end

function CreateTruckGroupAtFacility3()
    if not ScenarioInfo.ResearchFacility3Destroyed then -- If the facility's dead, it can't make trucks.
        LOG('debug: Op: Facility 3 is making trucks')
        local n = 1
        -- ! Make as many trucks as are needed to fill the group.
        while (ScenarioInfo.NumUEFTrucksAlive < ScenarioInfo.UEFTruckGroupSize) and not ScenarioInfo.ResearchFacility3Destroyed do
            CreateTruckAtFacility3(n)
            n = n+1
            if not (ScenarioInfo.ResearchFacility3TrucksProduced >= ScenarioInfo.UEFTruckGroupSize) then
                -- ! Adjust truck counters
                if not (ScenarioInfo.Difficulty == 1) then -- Don't deplete potential truck pool on Easy diff, since we can make infinite trucks.
                    ScenarioInfo.PotentialUEFTrucks = ScenarioInfo.PotentialUEFTrucks - 1
                end
                ScenarioInfo.ResearchFacility3TrucksProduced = ScenarioInfo.ResearchFacility3TrucksProduced + 1
            end
            WaitSeconds(4)
        end

        ScenarioFramework.CreateAreaTrigger(RF3TrucksMoved, ScenarioUtils.AreaToRect('RF3_Truck_Area'), categories.uec0001, true, true, ArmyBrains[Player], 1)

        -- ! If we make this truck group again, don't have as long a delay
        ScenarioInfo.M2TruckGroup3Delay = 60

        -- ! Tell the player that the truck is leaving
        if ScenarioInfo.LastCreatedTruckGroup == 2 then
            -- If this truck group has already been made once, play the dialogue for a respawned group
            ScenarioFramework.Dialogue(OpStrings.E05_M03_105)
        else
            -- Otherwise play the dialogue for the first truck group
            ScenarioFramework.Dialogue(OpStrings.E05_M03_090)
        end
        -- NIS for the first group of trucks made from the Facility3 location
        ForkThread(TruckSpawnNISCamera, ScenarioUtils.MarkerToPosition("Research_Facility_3"))
        -- Todo Addmarker: Add or flash marker at RF3 and gate

        -- ! The truck group is alive now
        ScenarioInfo.LastCreatedTruckGroup = 3

        -- ! Remind the player to do M3P2 after M3P2ReminderTimer
        ScenarioInfo.NextM3P2Reminder = 1
        ScenarioFramework.CreateTimerTrigger(M3P2Reminder, M3P2ReminderTimer)
    else
        LOG('debug: Op: Facility 3 was going to make trucks now, but it\'s destroyed.')
        ForkThread(CreateTruckGroup)
    end
end

function CreateTruckAtFacility3(n)
    SetIgnoreArmyUnitCap(Player, true)
    local truck = ScenarioUtils.CreateArmyUnit('Player', 'Truck3')
    SetIgnoreArmyUnitCap(Player, false)
    ScenarioFramework.CreateUnitDeathTrigger(TruckKilled, truck)
    ScenarioFramework.CreateUnitToMarkerDistanceTrigger(TruckNearGate, truck, ScenarioUtils.MarkerToPosition('Gate_Position'), 30)
    -- ! Line up the trucks nicely
    local x, y, z = unpack(truck:GetPosition())
    local offset = n
    if offset <= 8 then
        IssueMove({truck}, {x + 3 - offset, y, z + 5})
    else
        IssueMove({truck}, {x + 11 - offset, y, z + 3})
    end
    ScenarioInfo.NumUEFTrucksAlive = ScenarioInfo.NumUEFTrucksAlive + 1
    ScenarioInfo.M3P2:AddBasicUnitTarget (truck)
    -- ! Taunt if a truck is damaged
    truck.OnDamage =
        function(self, instigator, amount, vector, damageType)
            if self.CanTakeDamage then
                self:DoOnDamagedCallbacks(instigator)
                self:DoTakeDamage(instigator, amount, vector, damageType)
            end
            local damagerArmy = instigator:GetArmy()
            if (damagerArmy == Aeon) then
                ForkArnoldTaunt()
            elseif (damagerArmy == Cybran) then
                ForkMachTaunt()
            end
        end
end

function TruckSpawnNISCamera(truckMarker)
-- trucks ready cam
    local camInfo = {
        blendTime = 1.0,
        holdTime = 4,
        orientationOffset = { 2.67, 0.4, 0 },
        positionOffset = { 0, 0.5, 0 },
        zoomVal = 25,
        markerCam = true,
    }
    ScenarioFramework.OperationNISCamera(truckMarker, camInfo)
end

-- ! The player has moved the trucks away from RF1
function RF1TrucksMoved()
    LOG('debug: Op: The trucks have been moved away from RF1')
    ScenarioInfo.Truck1AreaEmpty = true
end

-- ! The player has moved the trucks away from RF2
function RF2TrucksMoved()
    LOG('debug: Op: The trucks have been moved away from RF2')
    ScenarioInfo.Truck2AreaEmpty = true
end

-- ! The player has moved the trucks away from RF3
function RF3TrucksMoved()
    LOG('debug: Op: The trucks have been moved away from RF3')
    ScenarioInfo.Truck3AreaEmpty = true
end

-- ! Remind the player to move the trucks
function M3P2Reminder()
    LOG('debug: Op: Reminding the player to move the trucks')
    if ScenarioInfo.LastCreatedTruckGroup == 1 then
        while not ScenarioInfo.Truck1AreaEmpty do
            if ScenarioInfo.NextM3P2Reminder == 1 and not ScenarioInfo.OpEnded then
                ScenarioFramework.Dialogue(OpStrings.E05_M03_110)
                ScenarioInfo.NextM3P2Reminder = 2
            elseif ScenarioInfo.NextM3P2Reminder == 2 and not ScenarioInfo.OpEnded then
                ScenarioFramework.Dialogue(OpStrings.E05_M03_112)
                ScenarioInfo.NextM3P2Reminder = 1
            end
            WaitSeconds(M3P2ReminderTimer)
        end
    elseif ScenarioInfo.LastCreatedTruckGroup == 2 then
        while not ScenarioInfo.Truck2AreaEmpty do
            if ScenarioInfo.NextM3P2Reminder == 1 and not ScenarioInfo.OpEnded then
                ScenarioFramework.Dialogue(OpStrings.E05_M03_110)
                ScenarioInfo.NextM3P2Reminder = 2
            elseif ScenarioInfo.NextM3P2Reminder == 2 and not ScenarioInfo.OpEnded then
                ScenarioFramework.Dialogue(OpStrings.E05_M03_112)
                ScenarioInfo.NextM3P2Reminder = 1
            end
            WaitSeconds(M3P2ReminderTimer)
        end
    elseif ScenarioInfo.LastCreatedTruckGroup == 3 then
        while not ScenarioInfo.Truck3AreaEmpty do
            if ScenarioInfo.NextM3P2Reminder == 1 and not ScenarioInfo.OpEnded then
                ScenarioFramework.Dialogue(OpStrings.E05_M03_110)
                ScenarioInfo.NextM3P2Reminder = 2
            elseif ScenarioInfo.NextM3P2Reminder == 2 and not ScenarioInfo.OpEnded then
                ScenarioFramework.Dialogue(OpStrings.E05_M03_112)
                ScenarioInfo.NextM3P2Reminder = 1
            end
            WaitSeconds(M3P2ReminderTimer)
        end
    end
end

-- ! Track the number of Black Sun Trucks, fail M3P2 if you lose too many.
function TruckKilled(unit)
    -- ! A truck has been killed; there is one less truck.
    LOG('debug: Op: A truck was killed')
    ScenarioInfo.NumUEFTrucksAlive = ScenarioInfo.NumUEFTrucksAlive - 1
    ScenarioInfo.TotalTrucksLost = ScenarioInfo.TotalTrucksLost + 1
    ScenarioInfo.CurrentTruckGroupTrucksLost = ScenarioInfo.CurrentTruckGroupTrucksLost + 1
    if (not ScenarioInfo.OpEnded and (ScenarioInfo.PotentialUEFTrucks + ScenarioInfo.NumUEFTrucksAlive + ScenarioInfo.NumUEFTrucksThroughGate) < ScenarioInfo.RequiredUEFTrucks) then -- You'll never get enough trucks. You fail.
        ScenarioInfo.M3P2:ManualResult(false)
        ScenarioInfo.MissionFailed = true
        PlayerLose(OpStrings.E05_M03_170)

-- too many trucks died cam
--    ScenarioFramework.EndOperationCamera(unit, false)
        local camInfo = {
            blendTime = 2.5,
            holdTime = nil,
            orientationOffset = { 0, 0.3, 0 },
            positionOffset = { 0, 0.5, 0 },
            zoomVal = 30,
            spinSpeed = 0.03,
            overrideCam = true,
        }
        ScenarioFramework.OperationNISCamera(unit, camInfo)
    end
    if ScenarioInfo.CurrentTruckGroupTrucksLost + ScenarioInfo.NumCurrentGroupTrucksThroughGate >= ScenarioInfo.UEFTruckGroupSize then
        LOG('debug: Op: The truck group has been killed.')
        if ScenarioInfo.NumUEFTrucksThroughGate >= ScenarioInfo.RequiredUEFTrucks then
            ForkThread (M3P2EnoughTrucks)
        else
            ScenarioInfo.CurrentTruckGroupTrucksLost = 0
            ScenarioInfo.NumCurrentGroupTrucksThroughGate = 0
            -- ! If we're on easy, make the same truck group again. Otherwise, move to the next one.
            if ScenarioInfo.Difficulty > 1 then
                ScenarioInfo.CurrentTruckGroup = ScenarioInfo.CurrentTruckGroup + 1
                ForkThread(CreateTruckGroup)
            else
                ForkThread(CreateTruckGroup)
            end
       end
    end
end

-- ! If a truck gets close to the gate, move it closer and send it through.
function TruckNearGate(truck)
    LOG('debug: Op: Running TruckNearGate')
    local x, y, z = unpack(ScenarioInfo.Gate:GetPosition())
    -- if ScenarioInfo.TruckPosition <= 4 then
    -- IssueMove({truck}, {x + 5, y, z - 2 + ScenarioInfo.TruckPosition})
    -- elseif ScenarioInfo.TruckPosition <= 8 then
    -- IssueMove({truck}, {x - 6 + ScenarioInfo.TruckPosition, y, z - 5})
    -- elseif ScenarioInfo.TruckPosition <= 12 then
    -- IssueMove({truck}, {x - 5, y, z - 10 + ScenarioInfo.TruckPosition})
    -- elseif ScenarioInfo.TruckPosition <= 16 then
    -- IssueMove({truck}, {x - 14 + ScenarioInfo.TruckPosition, y, z + 5})
    -- else
    -- ScenarioInfo.TruckPosition = 0
    -- end
    -- ScenarioInfo.TruckPosition = ScenarioInfo.TruckPosition + 1
    -- WaitSeconds(15)
    IssueMove({truck}, {x , y, z })
end

-- ! Send the truck through the gate
function SendTruckThroughGate(trucks)
    LOG('debug: Op: Running SendTruckThroughGate')
    IssueClearCommands(trucks)
    for k, truck in trucks do
        if not truck.GateStarted then
            truck.GateStarted = true
            ScenarioFramework.FakeTeleportUnit(truck,true)
            ScenarioInfo.NumUEFTrucksThroughGate = ScenarioInfo.NumUEFTrucksThroughGate + 1
            ScenarioInfo.NumCurrentGroupTrucksThroughGate = ScenarioInfo.NumCurrentGroupTrucksThroughGate + 1
            ScenarioInfo.NumUEFTrucksAlive = ScenarioInfo.NumUEFTrucksAlive - 1
        end
    end

    if (ScenarioInfo.NumUEFTrucksThroughGate <= ScenarioInfo.RequiredUEFTrucks) then
        Objectives.UpdateBasicObjective(ScenarioInfo.M3P2, 'progress', LOCF(OpStrings.M3P2Progress, ScenarioInfo.NumUEFTrucksThroughGate, ScenarioInfo.RequiredUEFTrucks))
    end
    -- LOG ('debug: truck count '..ScenarioInfo.NumUEFTrucksThroughGate..'needed '..ScenarioInfo.RequiredUEFTrucks)

    if ScenarioInfo.CurrentTruckGroupTrucksLost + ScenarioInfo.NumCurrentGroupTrucksThroughGate >= ScenarioInfo.UEFTruckGroupSize then
        ScenarioInfo.CurrentTruckGroup = ScenarioInfo.CurrentTruckGroup + 1
        ScenarioInfo.CurrentTruckGroupTrucksLost = 0
        ScenarioInfo.NumCurrentGroupTrucksThroughGate = 0
        -- ! Tell the player that the trucks have gone through the gate
        if ScenarioInfo.LastCreatedTruckGroup == 3 and not ScenarioInfo.Convoy1ThroughGateDialoguePlayed then
            ScenarioFramework.Dialogue(OpStrings.E05_M03_100)
            ScenarioInfo.Convoy1ThroughGateDialoguePlayed = true
        elseif ScenarioInfo.LastCreatedTruckGroup == 2 and not ScenarioInfo.Convoy2ThroughGateDialoguePlayed then
            ScenarioFramework.Dialogue(OpStrings.E05_M03_070)
            ScenarioInfo.Convoy2ThroughGateDialoguePlayed = true
        elseif ScenarioInfo.LastCreatedTruckGroup == 1 and not ScenarioInfo.Convoy3ThroughGateDialoguePlayed then
            ScenarioFramework.Dialogue(OpStrings.E05_M03_040)
            ScenarioInfo.Convoy3ThroughGateDialoguePlayed = true
        end
        if ScenarioInfo.NumUEFTrucksThroughGate >= ScenarioInfo.RequiredUEFTrucks then
            ForkThread (M3P2EnoughTrucks)
        elseif not (ScenarioInfo.NumUEFTrucksThroughGate >= ScenarioInfo.RequiredUEFTrucks) then
            ForkThread(CreateTruckGroup)
        end
    end
end

function M3P2EnoughTrucks()

    if not ScenarioInfo.M3P2Complete then
        ScenarioInfo.M3P2Complete = true

        LOG ('debug:complete truck tasks')
        ScenarioInfo.M3P2:ManualResult(true)
        ScenarioInfo.M3P1:ManualResult(true)

        if ScenarioInfo.TotalTrucksLost == 0 then
            CompleteM3B2()
        end
        WaitSeconds(5)

        ScenarioFramework.Dialogue(OpStrings.E05_M03_115)

        -- ! Assign M3P3 (Go back to earth through the gate)
        ScenarioInfo.M3P3 = Objectives.CategoriesInArea(
            'primary',                      -- type
            'incomplete',                   -- complete
            OpStrings.M3P3Title,            -- title
            OpStrings.M3P3Description,      -- description
            'move',
            { -- Target
                MarkArea = true,
                Requirements = {
                    { Area = 'CDR_Gate_Area', Category=categories.uel0001, CompareOp='>=', Value=1, },
                },
            }
       )
        ScenarioInfo.M3P3:AddResultCallback(
            function(result)
                -- LOG('debug: Op: The commander is through the gate.')
                ScenarioFramework.FakeTeleportUnit(ScenarioInfo.PlayerCDR, true)
--            ScenarioFramework.EndOperationCamera(ScenarioInfo.PlayerCDR, false)
                ScenarioFramework.CDRDeathNISCamera(ScenarioInfo.PlayerCDR)

                ScenarioInfo.PlayerCDRThroughTheGate = true
                PlayerWin()
            end
       )
        -- ScenarioInfo.M3Objectives:AddObjective(ScenarioInfo.M3P3)

        -- ! Remind the player to do M3P3 after M1P4InitialReminderTimer
        ScenarioInfo.NextM3P3Reminder = 1
        ScenarioFramework.CreateTimerTrigger(M3P3Reminder, M3P3InitialReminderTimer)
    end
end

-- ! Remind the player to go through the gate
function M3P3Reminder()
    while not ScenarioInfo.PlayerCDRThroughTheGate do
        if ScenarioInfo.NextM3P3Reminder == 1 and not ScenarioInfo.OpEnded then
            ScenarioFramework.Dialogue(OpStrings.E05_M03_200)
            ScenarioInfo.NextM3P3Reminder = 2
        elseif ScenarioInfo.NextM3P3Reminder == 2 and not ScenarioInfo.OpEnded then
            ScenarioFramework.Dialogue(OpStrings.E05_M03_205)
            ScenarioInfo.NextM3P3Reminder = 1
        end
        WaitSeconds(M3P3OngoingReminderTimer)
    end
end

-- ! Complete M3B2 (all the trucks reached earth safely)
function CompleteM3B2()
    ScenarioFramework.Dialogue(OpStrings.E05_M03_160)
    ScenarioInfo.M3B2 = Objectives.Basic(
        'secondary',                      -- type
        'incomplete',                   -- complete
        OpStrings.M3B2Title,            -- title
        OpStrings.M3B2Description,      -- description
        Objectives.GetActionIcon('protect'),
        {                               -- target
            Area = 'Gate_Area',
            MarkArea = false, -- Todo: Change this to mark the quantum gate when that's in
        }
   )
    ScenarioInfo.M3B2:ManualResult(true)
end

-- === Taunts === #
local MachTauntTable = {OpStrings.TAUNT1,
                           OpStrings.TAUNT2,
                           OpStrings.TAUNT3,
                           OpStrings.TAUNT4,
                           OpStrings.TAUNT5,
                           OpStrings.TAUNT6,
                           OpStrings.TAUNT7,
                           OpStrings.TAUNT8}

-- removed last 2 taunts, they;re being used explicitly
local ArnoldTauntTable =  {OpStrings.TAUNT9,
                           OpStrings.TAUNT10,
                           OpStrings.TAUNT11,
                           OpStrings.TAUNT12,
                           OpStrings.TAUNT13,
                           OpStrings.TAUNT14}

function ForkArnoldTaunt()
    ForkThread(CallArnoldTaunt)
end

function CallArnoldTaunt()
    if (not ScenarioInfo.ArnoldDead) and (not ScenarioInfo.ArnoldDontTaunt) then
        LOG('debug: Op: Playing a random Arnold Taunt')
        local taunt = ArnoldTauntTable[Random(1, table.getn(ArnoldTauntTable))]
        ScenarioFramework.Dialogue(taunt)
        ScenarioInfo.ArnoldDontTaunt = true
        WaitSeconds(10)
        ScenarioInfo.ArnoldDontTaunt = false
    end
end

function ForkMachTaunt()
    ForkThread(CallMachTaunt)
end

function CallMachTaunt()
    if not ScenarioInfo.MachDead and (not ScenarioInfo.MachDontTaunt) then
        LOG('debug: Op: Playing a random Mach Taunt')
        local taunt = MachTauntTable[Random(1, 8)]
        ScenarioFramework.Dialogue(taunt)
        ScenarioInfo.MachDontTaunt = true
        WaitSeconds(10)
        ScenarioInfo.MachDontTaunt = false
    end
end

-- === Win/Lose === #
-- ! If your Commander dies, you lose
function CommanderDied(unit)
    PlayerLose(OpStrings.E05_D01_010)
-- ScenarioFramework.EndOperationCamera(unit, false)
    ScenarioFramework.CDRDeathNISCamera(unit)

end

function PlayerWin()
    if not ScenarioInfo.PlayerHasWon then
        ScenarioInfo.PlayerHasWon = true
        ScenarioFramework.EndOperationSafety()
        ScenarioFramework.Dialogue(OpStrings.E05_M03_190, WinGame, true)
    end
end


function PlayerLose(dialogueTable)
    ScenarioInfo.MissionFailed = true
    ScenarioFramework.FlushDialogueQueue()
    ScenarioFramework.EndOperationSafety()
    if (dialogueTable) then
        ScenarioFramework.Dialogue(dialogueTable, LoseGame, true)
    else
        ForkThread(LoseGame)
    end
end

function ResearchFacilityDestroyedNISCamera(unit, numDead)
-- Setting up research facility died cam
    local camInfo = {
        blendTime = 1,
        holdTime = 4,
        orientationOffset = { 2.3, 0.3, 0 },
        positionOffset = { 0, 0.5, 0 },
        zoomVal = 30,
    }
    if numDead == 2 then
-- Research facility died and can't continue cam stuff
        camInfo.blendTime = 2.5
        camInfo.holdTime = nil
        camInfo.orientationOffset[1] = math.pi
        camInfo.spinSpeed = 0.03
        camInfo.overrideCam = true
    end
    ScenarioFramework.OperationNISCamera(unit, camInfo)
end

function WinGame()
    ScenarioInfo.OpComplete = true
    WaitSeconds(5)
    local secondaries = Objectives.IsComplete(ScenarioInfo.M1S1Obj) and Objectives.IsComplete(ScenarioInfo.M3S1Obj)
    ScenarioFramework.EndOperation(ScenarioInfo.OpComplete, ScenarioInfo.OpComplete, secondaries)
end

function LoseGame()
    ScenarioInfo.OpComplete = false
    WaitSeconds(5)
    ScenarioFramework.EndOperation(ScenarioInfo.OpComplete, ScenarioInfo.OpComplete, false)
end
