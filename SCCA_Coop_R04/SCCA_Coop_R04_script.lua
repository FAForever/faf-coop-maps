-- ****************************************************************************
-- **
-- **  File     :  /maps/SCCA_Coop_R04/SCCA_Coop_R04_script.lua
-- **  Author(s):  David Tomandl
-- **
-- **  Summary  :  This is the main file in control of the events during
-- **              Cybran operation 4.
-- **
-- **  Copyright © 2006 Gas Powered Games, Inc.  All rights reserved.
-- ****************************************************************************

local ScenarioFramework = import( '/lua/ScenarioFramework.lua' )
local Objectives = ScenarioFramework.Objectives
local ScenarioUtils = import( '/lua/sim/ScenarioUtilities.lua' )
local AIBuildStructures = import( '/lua/ai/AIBuildStructures.lua' )
local Cinematics = import( '/lua/cinematics.lua' )
local ScenarioStrings = import('/lua/ScenarioStrings.lua')
local OpStrings = import ('/maps/SCCA_Coop_R04/SCCA_Coop_R04_strings.lua')
local VizMarker = import('/lua/sim/VizMarker.lua').VizMarker
local Weather = import('/lua/weather.lua')

------------------------
-- Local Tuning Variables
------------------------

-- What should the player's army unit cap be in each mission?
local M1ArmyCap = 1000
local M2ArmyCap = 1000
local M3ArmyCap = 1000

-- For the first bonus objective, how many units does the player need to build
-- local M1B1BuildAmount = 300 # more than this number
-- local M1B2KillAmount = 50 # more than this number

-- When 3 values are given for a variable, they
-- apply to Easy, Medium, Hard difficulty in that order

-- Mission 1

-- The player starts with a base that is damaged.
-- How damaged?  Each piece will have these
-- percentages applied to them.
local PlayerBaseMinHealthPercentage = 55
local PlayerBaseMaxHealthPercentage = 90

-- Extra defenses have been placed in the player's base.
-- What percentage of them should start out destroyed?
-- This is a percentage.
local PlayerBaseChanceOfDefensesKilled = 30

-- How long to delay the dialog, in seconds
local M1_1_Dialogue_Delay = 120
local M1_2_Dialogue_Delay = 360
local M1_3_Dialogue_Delay = 600
local M1_4_Dialogue_Delay = 840

-- How long to delay the waves of attack
-- (These attacks are currently disabled for Easy difficulty)
local M1AirAttackInitialDelay = { 300, 420, 240 }
local M1NavalAttackInitialDelay = { 900, 900, 600 }

-- Once unleashed, how long between waves are sent
local M1AirAttackDelay = { 300, 300, 180 }
local M1NavalAttackDelay = { 600, 600, 360 }

-- When the Aeon commander's health drops below what
-- amount will she teleport away?
local AeonCommanderHealthThreshold = 0.20 -- 20%

-- How long to delay between reminders
local M1P1InitialReminderDelay = 900000
local M1P1ReoccuringReminderDelay = 600000

local M1P2InitialReminderDelay = 300000
local M1P2ReoccuringReminderDelay = 600000

-- Mission 2

-- If this number of civilian buildings are destroyed,
-- the player will fail the secondary objective.
local M2TooManyDestroyedBuildings = 3
local CivilianBuildingSurvivePercentage = 80

-- This is the delay after the mission starts
local M2_2_Dialogue_Delay = 240
local M2_3_Dialogue_Delay = 480

-- This is the delay after PO#1 is completed
local M2_4_Dialogue_Delay = 120

-- The attacks that are sent against the player
-- (These attacks are disabled for Easy difficulty)
local M2ReoccuringBaseAttackInitialDelay = { 240, 240, 60 }
local M2ReoccuringBaseAttackDelay = { 120, 120, 60 }

-- How long to wait after the colony is freed before launching the attack
local M2Wave1Delay = 120

-- How long to wait after the previous wave dies before launching the attack
local M2Wave2Delay = 30

-- How long to wait after the previous wave dies before launching the attack
local M2Wave3Delay = 30

-- How long to delay between reminders
local M2P1InitialReminderDelay = 300000
local M2P1ReoccuringReminderDelay = 600000

-- Mission 3

-- How long to delay the dialog after the EMP goes off
local M3_5_Dialogue_Delay = 240

-- Before the player captures the nodes, the Aeon
-- base isn't allowed to be attacked.  If it is, the player
-- is warned.  After the Aeon base has been attacked, how
-- long to delay before re-enabling the trigger to check for
-- damage to the units?
local ReenableM3BaseDamageTriggersDelay = 15

-- When attacks are sent, we can send air and land attacks.
-- What are the relative chances of sending air, land, or both?
-- These don't need to add up to 100; it is a strict ratio between them.
local M3AttackWaveLandOnlyChance = 30
local M3AttackWaveAirOnlyChance = 30
local M3AttackWaveCombinedChance = 40

-- When attacks are sent against the player, route1 is the north route and
-- route2 is the south route.  When attacks are sent against node 2, route1
-- is the east route and route2 is the west route.  This can be seperated
-- if desired, but I'm guessing that these variables won't actually
-- be used much...
-- These don't need to add up to 100; it is a strict ratio between them.
local M3AttackWaveUseRoute1 = 50
local M3AttackWaveUseRoute2 = 50

-- Which destination will they attack?  The player's base or Node 2?
-- These don't need to add up to 100; it is a strict ratio between them.
local M3AttackWaveAgainstPlayerBaseChance = 40
local M3AttackWaveAgainstNode2Chance = 60

-- How long to delay the waves of attack
-- (These attacks are disabled on Easy)
local M3AttackInitialDelay = { 300, 300, 300 }

-- Once unleashed, how long between waves are sent
local M3AttackDelay = { 180, 180, 180 }

-- How long after the player has all 4 nodes before the EMP goes off?
local EMPDelay = 30

-- How long should the stun from the EMP last?
local StunDuration = { 1800, 600, 600 }

-- How long to delay between reminders
local M3P1InitialReminderDelay = 900
local M3P1ReoccuringReminderDelay = 600

local M3P3InitialReminderDelay = 300
local M3P3ReoccuringReminderDelay = 600

-- ### Global variables
ScenarioInfo.MissionNumber = 1

ScenarioInfo.Player = 1
ScenarioInfo.Aeon = 2
ScenarioInfo.Civilian = 3
ScenarioInfo.Neutral = 4
ScenarioInfo.Coop1 = 5
ScenarioInfo.Coop2 = 6
ScenarioInfo.Coop3 = 7
ScenarioInfo.HumanPlayers = {}

ScenarioInfo.VarTable = {}
ScenarioInfo.FirstAirAttackSent = false
ScenarioInfo.M1PrimaryObjectivesComplete = 0
ScenarioInfo.M1CommanderDeathHasBeenCalled = false
ScenarioInfo.Node3Captured = false
ScenarioInfo.Node4Captured = false
ScenarioInfo.AllNodesCaptured = false
ScenarioInfo.M3BaseDamageWarnings = 0
ScenarioInfo.DisableM3BaseDamagedTriggers = false
ScenarioInfo.AeonCommanderDead = false
ScenarioInfo.AeonCommanderBaseDestroyed = false

-- #### LOCALS #####
local MissionTexture = '/textures/ui/common/missions/mission.dds'

local Difficulty = ScenarioInfo.Options.Difficulty or 2

local Difficulty1_Suffix = '_D1'
local Difficulty2_Suffix = '_D2'
local Difficulty3_Suffix = '_D3'

local Player = ScenarioInfo.Player
local Coop1 = ScenarioInfo.Coop1
local Coop2 = ScenarioInfo.Coop2
local Coop3 = ScenarioInfo.Coop3
local Aeon = ScenarioInfo.Aeon
local Civilian = ScenarioInfo.Civilian
local Neutral = ScenarioInfo.Neutral

local Players = {ScenarioInfo.Player, ScenarioInfo.Coop1, ScenarioInfo.Coop2, ScenarioInfo.Coop3}

local TauntTable = {
    OpStrings.TAUNT1,
    OpStrings.TAUNT2,
    OpStrings.TAUNT3,
    OpStrings.TAUNT4,
    OpStrings.TAUNT5,
    OpStrings.TAUNT6,
    OpStrings.TAUNT7,
    OpStrings.TAUNT8,
}

-- #### Difficulty-based adjustments to platoon sizes

if Difficulty == 1 then
    ScenarioInfo.VarTable['M1NavalAttackerInstances'] = 1
    ScenarioInfo.VarTable['M1NavalAntiAirInstances'] = 1
elseif Difficulty == 2 then
    ScenarioInfo.VarTable['M1NavalAttackerInstances'] = 2
    ScenarioInfo.VarTable['M1NavalAntiAirInstances'] = 2
elseif Difficulty == 3 then
    ScenarioInfo.VarTable['M1NavalAttackerInstances'] = 3
    ScenarioInfo.VarTable['M1NavalAntiAirInstances'] = 4
end


-- ### Routes and other tables of goodies
local AeonM3NWPatrolNaval01Route = {
    ScenarioUtils.MarkerToPosition( 'M3_NW_Patrol_1' ),
    ScenarioUtils.MarkerToPosition( 'M3_NW_Patrol_2' ),
}

local AeonM3NWPatrolNaval02Route = {
    ScenarioUtils.MarkerToPosition( 'M3_NW_Patrol_3' ),
    ScenarioUtils.MarkerToPosition( 'M3_NW_Patrol_4' ),
}

local AeonM3NWPatrolLand01Route = {
    ScenarioUtils.MarkerToPosition( 'M3_NW_Patrol_5' ),
    ScenarioUtils.MarkerToPosition( 'M3_NW_Patrol_6' ),
}

local AeonM3NEPatrolLand01Route = {
    ScenarioUtils.MarkerToPosition( 'M3_NE_Patrol_1' ),
    ScenarioUtils.MarkerToPosition( 'M3_NE_Patrol_2' ),
}

local AeonM3NEPatrolLand02Route = {
    ScenarioUtils.MarkerToPosition( 'M3_NE_Patrol_2' ),
    ScenarioUtils.MarkerToPosition( 'M3_NE_Patrol_3' ),
}

local AeonM3NEPatrolLand03Route = {
    ScenarioUtils.MarkerToPosition( 'M3_NE_Patrol_3' ),
    ScenarioUtils.MarkerToPosition( 'M3_NE_Patrol_4' ),
}

local AeonM3NEPatrolNaval01Route = {
    ScenarioUtils.MarkerToPosition( 'M3_NE_Patrol_5' ),
    ScenarioUtils.MarkerToPosition( 'M3_NE_Patrol_6' ),
}

-- ##### Starter Functions ######
function OnPopulate(scenario)
    -- Initial Unit Creation
    ScenarioUtils.InitializeScenarioArmies()
    ScenarioFramework.GetLeaderAndLocalFactions()

    -- Add in the base locations for the PBM
    ArmyBrains[Aeon]:PBMAddBuildLocation( ScenarioUtils.MarkerToPosition( 'Aeon_Base_M1_Naval' ), 40, 'Aeon_Base_M1_Naval' )
    ArmyBrains[Aeon]:PBMAddBuildLocation( ScenarioUtils.MarkerToPosition( 'Aeon_Base_M1_Air' ), 40, 'Aeon_Base_M1_Air' )
    ArmyBrains[Aeon]:PBMAddBuildLocation( ScenarioUtils.MarkerToPosition( 'Aeon_Base_M1_Land' ), 40, 'Aeon_Base_M1_Land' )
    ArmyBrains[Aeon]:PBMAddBuildLocation( ScenarioUtils.MarkerToPosition( 'Aeon_Base_M3' ), 100, 'Aeon_Base_M3' )
    ArmyBrains[Aeon]:PBMAddBuildLocation( ScenarioUtils.MarkerToPosition( 'M1_Center' ), 600, 'M1_Anywhere' )
    ArmyBrains[Aeon]:PBMAddBuildLocation( ScenarioUtils.MarkerToPosition( 'M2_Wave1_Location' ), 40, 'M2_Wave1_Location' )
    ArmyBrains[Aeon]:PBMAddBuildLocation( ScenarioUtils.MarkerToPosition( 'M2_Wave2_Location' ), 40, 'M2_Wave2_Location' )
    ArmyBrains[Aeon]:PBMAddBuildLocation( ScenarioUtils.MarkerToPosition( 'M2_Wave3_Location' ), 40, 'M2_Wave3_Location' )


    if not ArmyBrains[Aeon].BaseTemplates then
        ArmyBrains[Aeon].BaseTemplates = {}
    end

    -- Define the bases for the different difficulties
    ArmyBrains[Aeon].BaseTemplates['M1_Base_Air_D2'] = { Template = {}, List = {} }
    AIBuildStructures.AppendBuildingTemplate( ArmyBrains[Aeon], 'Aeon', 'M1_Base_Air_Defenses_D2', 'M1_Base_Air_D2' )
    AIBuildStructures.AppendBuildingTemplate( ArmyBrains[Aeon], 'Aeon', 'M1_Base_Air_Factories_D2', 'M1_Base_Air_D2' )
    -- AIBuildStructures.AppendBuildingTemplate( ArmyBrains[Aeon], 'Aeon', 'M1_Base_Air_Misc_D2', 'M1_Base_Air_D2' )
    AIBuildStructures.AppendBuildingTemplate( ArmyBrains[Aeon], 'Aeon', 'M1_Base_Air_Economy_D2', 'M1_Base_Air_D2' )

    ArmyBrains[Aeon].BaseTemplates['M1_Base_Air_D1'] = { Template = {}, List = {} }
    AIBuildStructures.AppendBuildingTemplate( ArmyBrains[Aeon], 'Aeon', 'M1_Base_Air_Defenses_D1', 'M1_Base_Air_D1' )
    AIBuildStructures.AppendBuildingTemplate( ArmyBrains[Aeon], 'Aeon', 'M1_Base_Air_Factories_D1', 'M1_Base_Air_D1' )
    -- AIBuildStructures.AppendBuildingTemplate( ArmyBrains[Aeon], 'Aeon', 'M1_Base_Air_Misc_D1', 'M1_Base_Air_D1' )
    AIBuildStructures.AppendBuildingTemplate( ArmyBrains[Aeon], 'Aeon', 'M1_Base_Air_Economy_D1', 'M1_Base_Air_D1' )

    ArmyBrains[Aeon].BaseTemplates['M1_Base_Naval_D2'] = { Template = {}, List = {} }
    AIBuildStructures.AppendBuildingTemplate( ArmyBrains[Aeon], 'Aeon', 'M1_Base_Naval_Defenses_D2', 'M1_Base_Naval_D2' )
    AIBuildStructures.AppendBuildingTemplate( ArmyBrains[Aeon], 'Aeon', 'M1_Base_Naval_Factories_D2', 'M1_Base_Naval_D2' )
    -- AIBuildStructures.AppendBuildingTemplate( ArmyBrains[Aeon], 'Aeon', 'M1_Base_Naval_Misc_D2', 'M1_Base_Naval_D2' )
    AIBuildStructures.AppendBuildingTemplate( ArmyBrains[Aeon], 'Aeon', 'M1_Base_Naval_Economy_D2', 'M1_Base_Naval_D2' )

    ArmyBrains[Aeon].BaseTemplates['M1_Base_Naval_D1'] = { Template = {}, List = {} }
    AIBuildStructures.AppendBuildingTemplate( ArmyBrains[Aeon], 'Aeon', 'M1_Base_Naval_Defenses_D1', 'M1_Base_Naval_D1' )
    AIBuildStructures.AppendBuildingTemplate( ArmyBrains[Aeon], 'Aeon', 'M1_Base_Naval_Factories_D1', 'M1_Base_Naval_D1' )
    -- AIBuildStructures.AppendBuildingTemplate( ArmyBrains[Aeon], 'Aeon', 'M1_Base_Naval_Misc_D1', 'M1_Base_Naval_D1' )
    AIBuildStructures.AppendBuildingTemplate( ArmyBrains[Aeon], 'Aeon', 'M1_Base_Naval_Economy_D1', 'M1_Base_Naval_D1' )

    ArmyBrains[Aeon].BaseTemplates['M1_Base_Land_D2'] = { Template = {}, List = {} }
    AIBuildStructures.AppendBuildingTemplate( ArmyBrains[Aeon], 'Aeon', 'M1_Base_Land_Defenses_D2', 'M1_Base_Land_D2' )
    AIBuildStructures.AppendBuildingTemplate( ArmyBrains[Aeon], 'Aeon', 'M1_Base_Land_Factories_D2', 'M1_Base_Land_D2' )
    -- AIBuildStructures.AppendBuildingTemplate( ArmyBrains[Aeon], 'Aeon', 'M1_Base_Land_Misc_D2', 'M1_Base_Land_D2' )
    AIBuildStructures.AppendBuildingTemplate( ArmyBrains[Aeon], 'Aeon', 'M1_Base_Land_Economy_D2', 'M1_Base_Land_D2' )

    ArmyBrains[Aeon].BaseTemplates['M1_Base_Land_D1'] = { Template = {}, List = {} }
    AIBuildStructures.AppendBuildingTemplate( ArmyBrains[Aeon], 'Aeon', 'M1_Base_Land_Defenses_D1', 'M1_Base_Land_D1' )
    AIBuildStructures.AppendBuildingTemplate( ArmyBrains[Aeon], 'Aeon', 'M1_Base_Land_Factories_D1', 'M1_Base_Land_D1' )
    -- AIBuildStructures.AppendBuildingTemplate( ArmyBrains[Aeon], 'Aeon', 'M1_Base_Land_Misc_D1', 'M1_Base_Land_D1' )
    AIBuildStructures.AppendBuildingTemplate( ArmyBrains[Aeon], 'Aeon', 'M1_Base_Land_Economy_D1', 'M1_Base_Land_D1' )

    ArmyBrains[Aeon].BaseTemplates['M3_Base_D2'] = { Template = {}, List = {} }
    AIBuildStructures.AppendBuildingTemplate( ArmyBrains[Aeon], 'Aeon', 'M3_Base_Defenses_D2', 'M3_Base_D2' )
    AIBuildStructures.AppendBuildingTemplate( ArmyBrains[Aeon], 'Aeon', 'M3_Base_Factories_D2', 'M3_Base_D2' )
    -- AIBuildStructures.AppendBuildingTemplate( ArmyBrains[Aeon], 'Aeon', 'M3_Base_Misc_D2', 'M3_Base_D2' )
    AIBuildStructures.AppendBuildingTemplate( ArmyBrains[Aeon], 'Aeon', 'M3_Base_Economy_D2', 'M3_Base_D2' )

    ArmyBrains[Aeon].BaseTemplates['M3_Base_D1'] = { Template = {}, List = {} }
    AIBuildStructures.AppendBuildingTemplate( ArmyBrains[Aeon], 'Aeon', 'M3_Base_Defenses_D1', 'M3_Base_D1' )
    AIBuildStructures.AppendBuildingTemplate( ArmyBrains[Aeon], 'Aeon', 'M3_Base_Factories_D1', 'M3_Base_D1' )
    -- AIBuildStructures.AppendBuildingTemplate( ArmyBrains[Aeon], 'Aeon', 'M3_Base_Misc_D1', 'M3_Base_D1' )
    AIBuildStructures.AppendBuildingTemplate( ArmyBrains[Aeon], 'Aeon', 'M3_Base_Economy_D1', 'M3_Base_D1' )


    -- Create some of the key units and save handles to them

    local Gate = ScenarioUtils.CreateArmyUnit( 'Player', 'Gate' )
    -- Gate:SetCanBeKilled(false)
    Gate:SetReclaimable(false)
    Gate:SetCapturable(false)

    -- Spawn the player's base
    local maxHealth
    local newHealth
    local tempGroup = ScenarioUtils.CreateArmyGroup( 'Player', 'Initial_Factories' )
    for k, unit in tempGroup do
        maxHealth = unit:GetMaxHealth()
        newHealth = maxHealth * ( Random( PlayerBaseMinHealthPercentage, PlayerBaseMaxHealthPercentage ) / 100 )
        unit:SetHealth( unit, newHealth )
    end

    tempGroup = ScenarioUtils.CreateArmyGroup( 'Player', 'Initial_Defenses' )
    for k, unit in tempGroup do
        if Random(1, 100) < PlayerBaseChanceOfDefensesKilled then
            unit:Kill()
        else
            maxHealth = unit:GetMaxHealth()
            newHealth = maxHealth * ( Random( PlayerBaseMinHealthPercentage, PlayerBaseMaxHealthPercentage ) / 100 )
            unit:SetHealth( unit, newHealth )
        end
    end

    tempGroup = ScenarioUtils.CreateArmyGroup( 'Player', 'Initial_Economy' )
    for k, unit in tempGroup do
        maxHealth = unit:GetMaxHealth()
        newHealth = maxHealth * ( Random( PlayerBaseMinHealthPercentage, PlayerBaseMaxHealthPercentage ) / 100 )
        unit:SetHealth( unit, newHealth )
    end


    -- Spawn the enemy bases
    ScenarioUtils.CreateArmyGroup( 'Aeon', AdjustForDifficulty( 'M1_Base_Naval_Defenses' ))
    ScenarioUtils.CreateArmyGroup( 'Aeon', AdjustForDifficulty( 'M1_Base_Naval_Economy' ))
    ScenarioUtils.CreateArmyGroup( 'Aeon', AdjustForDifficulty( 'M1_Base_Naval_Factories' ))
    ScenarioUtils.CreateArmyGroup( 'Aeon', AdjustForDifficulty( 'M1_Base_Naval_Misc' ))

    ScenarioUtils.CreateArmyGroup( 'Aeon', AdjustForDifficulty( 'M1_Base_Air_Defenses' ))
    ScenarioUtils.CreateArmyGroup( 'Aeon', AdjustForDifficulty( 'M1_Base_Air_Economy' ))
    ScenarioUtils.CreateArmyGroup( 'Aeon', AdjustForDifficulty( 'M1_Base_Air_Factories' ))
    ScenarioUtils.CreateArmyGroup( 'Aeon', AdjustForDifficulty( 'M1_Base_Air_Misc' ))

    ScenarioUtils.CreateArmyGroup( 'Aeon', AdjustForDifficulty( 'M1_Base_Land_Defenses' ))
    ScenarioUtils.CreateArmyGroup( 'Aeon', AdjustForDifficulty( 'M1_Base_Land_Economy' ))
    ScenarioUtils.CreateArmyGroup( 'Aeon', AdjustForDifficulty( 'M1_Base_Land_Factories' ))
    ScenarioUtils.CreateArmyGroup( 'Aeon', AdjustForDifficulty( 'M1_Base_Land_Misc' ))

    ScenarioInfo.AeonCommanderM1 = ScenarioUtils.CreateArmyUnit( 'Aeon', 'M1_Commander' )
    ScenarioInfo.AeonCommanderM1:CreateEnhancement('AdvancedEngineering')
    ScenarioInfo.AeonCommanderM1:CreateEnhancement('Teleporter')
    IssuePatrol({ ScenarioInfo.AeonCommanderM1 }, ScenarioUtils.MarkerToPosition( 'M1_Commander_Patrol_1' ))
    IssuePatrol({ ScenarioInfo.AeonCommanderM1 }, ScenarioUtils.MarkerToPosition( 'M1_Commander_Patrol_2' ))

    -- Redefine the commander's OnDamage function so that when she is about to go below
    -- a certain threshold, she will teleport away instead
    ScenarioInfo.AeonCommanderM1.OnDamage = function(self, instigator, amount, vector, damageType)
        local health = self:GetHealth()
        local maxHealth = self:GetMaxHealth()
        local newHealthPercentage = (health - amount) / maxHealth
        if newHealthPercentage < AeonCommanderHealthThreshold then
            if not ScenarioInfo.M1CommanderDeathHasBeenCalled then
                ScenarioInfo.M1CommanderDeathHasBeenCalled = true
                M1CommanderDefeated()
            end
        else
            self:DoOnDamagedCallbacks(instigator)
            self:DoTakeDamage(instigator, amount, vector, damageType)
        end
    end

    -- Create the nodes, and make triggers to go off if they die or are captured.
    -- Set them to non-reclaimable, as a convenience
    ScenarioInfo.Node1 = ScenarioUtils.CreateArmyUnit( 'Neutral', 'Node_1' )
    ScenarioInfo.Node2 = ScenarioUtils.CreateArmyUnit( 'Neutral', 'Node_2' )
    ScenarioInfo.Node3 = ScenarioUtils.CreateArmyUnit( 'Neutral', 'Node_3' )
    ScenarioInfo.Node4 = ScenarioUtils.CreateArmyUnit( 'Neutral', 'Node_4' )

    ScenarioInfo.Node1:SetReclaimable(false)
    ScenarioInfo.Node2:SetReclaimable(false)
    ScenarioInfo.Node3:SetReclaimable(false)
    ScenarioInfo.Node4:SetReclaimable(false)

    ScenarioInfo.Node1:SetCustomName(LOC '{i R04_NodeName}')
    ScenarioInfo.Node2:SetCustomName(LOC '{i R04_NodeName}')
    ScenarioInfo.Node3:SetCustomName(LOC '{i R04_NodeName}')
    ScenarioInfo.Node4:SetCustomName(LOC '{i R04_NodeName}')

    -- The mainframe is supposed to be completely invincible, so take away its ability to get damaged
    ScenarioInfo.Mainframe = ScenarioUtils.CreateArmyUnit( 'Neutral', 'Mainframe' )
    ScenarioInfo.Mainframe:SetCustomName(LOC '{i R04_MainframeName}')
    ScenarioInfo.Mainframe.OnDamage = function(self, instigator, amount, vector, damageType) end

    ScenarioFramework.CreateUnitDeathTrigger( NodeDied, ScenarioInfo.Node1 )
    ScenarioFramework.CreateUnitDeathTrigger( NodeDied, ScenarioInfo.Node2 )
    ScenarioFramework.CreateUnitDeathTrigger( NodeDied, ScenarioInfo.Node3 )
    ScenarioFramework.CreateUnitDeathTrigger( NodeDied, ScenarioInfo.Node4 )
    ScenarioFramework.CreateUnitReclaimedTrigger( NodeDied, ScenarioInfo.Node1 )
    ScenarioFramework.CreateUnitReclaimedTrigger( NodeDied, ScenarioInfo.Node2 )
    ScenarioFramework.CreateUnitReclaimedTrigger( NodeDied, ScenarioInfo.Node3 )
    ScenarioFramework.CreateUnitReclaimedTrigger( NodeDied, ScenarioInfo.Node4 )
    ScenarioFramework.CreateUnitCapturedTrigger( false, Node1Captured, ScenarioInfo.Node1 )
    ScenarioFramework.CreateUnitCapturedTrigger( false, Node2Captured, ScenarioInfo.Node2 )
    ScenarioFramework.CreateUnitCapturedTrigger( false, Node3Captured, ScenarioInfo.Node3 )
    ScenarioFramework.CreateUnitCapturedTrigger( false, Node4Captured, ScenarioInfo.Node4 )
end

function OnStart(self)
    if ( Difficulty == 1 ) then
        ScenarioInfo.VarTable['DifficultyIs1'] = true
    elseif ( Difficulty == 2 ) then
        ScenarioInfo.VarTable['DifficultyIs2'] = true
    elseif ( Difficulty == 3 ) then
        ScenarioInfo.VarTable['DifficultyIs3'] = true
    end

    ScenarioFramework.SetPlayableArea('M1_Playable_Area', false)
    ScenarioFramework.CreateVisibleAreaLocation( 5, ScenarioInfo.Node1:GetPosition(), 10, ArmyBrains[Player] )

    SetAlliance( Player, Aeon, 'Enemy' )
    SetAlliance( Civilian, Aeon, 'Enemy' )
    SetAlliance( Player, Civilian, 'Neutral' )
    SetAlliance( Neutral, Aeon, 'Neutral' )
    SetAlliance( Neutral, Player, 'Neutral' )
    SetAlliance( Neutral, Civilian, 'Neutral' )

    SetIgnorePlayableRect( Aeon, true )
    SetIgnorePlayableRect( Civilian, true )
    SetIgnorePlayableRect( Neutral, true )

    ScenarioFramework.SetCybranColor(Player)
    ScenarioFramework.SetAeonColor(Aeon)
    local colors = {
        ['Coop1'] = {183, 101, 24}, 
        ['Coop2'] = {255, 135, 62}, 
        ['Coop3'] = {255, 191, 128}
    }
    local tblArmy = ListArmies()
    for army, color in colors do
        if tblArmy[ScenarioInfo[army]] then
            ScenarioFramework.SetArmyColor(ScenarioInfo[army], unpack(color))
        end
    end

    -- Setting some variables for Mission 2
    ScenarioInfo.VarTable['EnableWave1'] = false
    ScenarioInfo.VarTable['EnableWave2'] = false
    ScenarioInfo.VarTable['EnableWave3'] = false

    -- These variables will get used in Attack Managers in missions 1 and 3
    ScenarioInfo.VarTable['AttackBase1'] = false
    ScenarioInfo.VarTable['AttackBase2'] = false
    ScenarioInfo.VarTable['LaunchLandAttack'] = false
    ScenarioInfo.VarTable['LaunchNavalAttack'] = false
    ScenarioInfo.VarTable['LaunchAirAttack'] = false
    ScenarioInfo.VarTable['UseLandRoute1'] = false
    ScenarioInfo.VarTable['UseLandRoute2'] = false
    ScenarioInfo.VarTable['UseAirRoute1'] = false
    ScenarioInfo.VarTable['UseAirRoute2'] = false

    -- Take away units that the player shouldn't have access to

    local tblArmy = ListArmies()
    for _, player in Players do
        for iArmy, strArmy in pairs(tblArmy) do
            if iArmy == player then
                ScenarioFramework.AddRestriction(player,
                    categories.PRODUCTFA + -- ALl FA Units
                    categories.TECH3 +  -- All T3 units
                    categories.EXPERIMENTAL + -- All experimental units
                    categories.urb4202 + -- T2 Shield Generator
                    categories.urb4204 +
                    categories.urb4205 +
                    categories.urb4206 +
                    categories.urb4207 +
                    categories.urb2303 + -- Light Artillery Installation
                    categories.urb2108 + -- Tactical Missile Launcher
                    categories.ura0104 + -- T2 Transport
                    categories.ura0302 + -- Spy Plane
                    categories.url0306 + -- Mobile Stealth Generator
                    categories.urs0202 + -- Cruiser
                    categories.urb5202 + -- Air Staging Platform
                    categories.urb4201 ) -- T2 Anti-Missile Gun

                ScenarioFramework.RestrictEnhancements({'StealthGenerator',
                    'T3Engineering',
                    'Teleporter',})

                ScenarioFramework.StartOperationJessZoom( 'Start_Camera_Area', BeginMission1)
            end
        end
    end
end

function BeginMission1()
    ScenarioInfo.VarTable['Mission1'] = true

    -- Set the maximum number of units that the player is allowed to have
    SetArmyUnitCap( Player, M1ArmyCap )

    -- Delay opening dialogue a bit, so the player commander is fully in.
    ScenarioFramework.CreateTimerTrigger( OpeningDialogue, 5)

    ScenarioInfo.M1P1Objective = Objectives.Basic(
        'primary',
        'incomplete',
        OpStrings.M1P1Text,
        OpStrings.M1P1Detail,
        Objectives.GetActionIcon('kill'),
        {
            Units = { ScenarioInfo.AeonCommanderM1 },
            MarkUnits = true,
        }
    )

    ScenarioInfo.M1P2Objective = Objectives.Basic(
        'primary',
        'incomplete',
        OpStrings.M1P2Text,
        OpStrings.M1P2Detail,
        Objectives.GetActionIcon('capture'),
        {
            Units = { ScenarioInfo.Node1 },
            MarkUnits = true,
        }
    )

    local numCurrentUnits = table.getn( ArmyBrains[ Player ]:GetListOfUnits( categories.ALLUNITS, false ))

    -- ScenarioFramework.CreateArmyStatTrigger( M1B1Complete, ArmyBrains[Player], 'B1Trigger',
    -- {{ StatType = 'Units_History', CompareType = 'GreaterThan', Value = numCurrentUnits + M1B1BuildAmount, Category = categories.CYBRAN, },} )

    -- ScenarioFramework.CreateArmyStatTrigger( M1B2Complete, ArmyBrains[Player], 'B2Trigger',
    -- {{ StatType = 'Enemies_Killed', CompareType = 'GreaterThan', Value = M1B2KillAmount, Category = categories.ARTILLERY, },} )

    ScenarioFramework.Dialogue( ScenarioStrings.NewPObj )

    -- Dialog that will appear after a certain amount of time
    ScenarioFramework.CreateTimerTrigger( Dialogue_M1_1, M1_1_Dialogue_Delay )
    ScenarioFramework.CreateTimerTrigger( Dialogue_M1_2, M1_2_Dialogue_Delay )
    ScenarioFramework.CreateTimerTrigger( Dialogue_M1_3, M1_3_Dialogue_Delay )
    ScenarioFramework.CreateTimerTrigger( Dialogue_M1_4, M1_4_Dialogue_Delay )

    -- If the player doesn't complete the objective soon, remind him that it's important
    ScenarioFramework.CreateTimerTrigger( M1P1Reminder, M1P1InitialReminderDelay )

    -- Set the air and naval attacks to start after a delay
    ScenarioFramework.CreateTimerTrigger( M1LaunchAirAttackReoccurring, M1AirAttackInitialDelay[ Difficulty ] )
    ScenarioFramework.CreateTimerTrigger( M1LaunchNavalAttackReoccurring, M1NavalAttackInitialDelay[ Difficulty ] )

    -- Player commander unit
    ScenarioInfo.PlayerCDR = ScenarioUtils.CreateArmyUnit( 'Player', 'Commander' )
    ScenarioInfo.PlayerCDR:SetCustomName(ArmyBrains[Player].Nickname)
    ScenarioFramework.FakeGateInUnit( ScenarioInfo.PlayerCDR )
    ScenarioFramework.PauseUnitDeath(ScenarioInfo.PlayerCDR)
    ScenarioFramework.CreateUnitDeathTrigger(PlayerCommanderDied, ScenarioInfo.PlayerCDR)

    IssueMove({ ScenarioInfo.PlayerCDR}, ScenarioUtils.MarkerToPosition( 'M1_Commander_Walk_1' ))
    IssueMove({ ScenarioInfo.PlayerCDR}, ScenarioUtils.MarkerToPosition( 'M1_Commander_Walk_2' ))
    WaitSeconds(1.8)

    ScenarioInfo.CoopCDR = {}
    local tblArmy = ListArmies()
    coop = 1
    for iArmy, strArmy in pairs(tblArmy) do
        if iArmy >= ScenarioInfo.Coop1 then
            ScenarioInfo.CoopCDR[coop] = ScenarioUtils.CreateArmyUnit(strArmy, 'Commander')
            ScenarioFramework.FakeGateInUnit( ScenarioInfo.CoopCDR[coop] )
            ScenarioInfo.CoopCDR[coop]:SetCustomName(ArmyBrains[iArmy].Nickname)
            IssueMove({ ScenarioInfo.CoopCDR[coop]}, ScenarioUtils.MarkerToPosition( 'M1_Commander_Walk_1' ))
            IssueMove({ ScenarioInfo.CoopCDR[coop]}, ScenarioUtils.MarkerToPosition( 'M1_Commander_Walk_2' ))
            coop = coop + 1
            WaitSeconds(1.8)
        end
    end
    for index, coopACU in ScenarioInfo.CoopCDR do
        ScenarioFramework.PauseUnitDeath(coopACU)
        ScenarioFramework.CreateUnitDeathTrigger(PlayerCommanderDied, coopACU)
    end
end

function OpeningDialogue()
    ScenarioFramework.Dialogue( OpStrings.C04_M01_010 )
end

function Dialogue_M1_1()
    if ScenarioInfo.MissionNumber == 1 and not ScenarioInfo.OpEnded then
        ScenarioFramework.Dialogue( OpStrings.C04_M01_020 )
    end
end

function Dialogue_M1_2()
    if ScenarioInfo.MissionNumber == 1 and not ScenarioInfo.OpEnded then
        ScenarioFramework.Dialogue( OpStrings.C04_M01_030 )
    end
end

function Dialogue_M1_3()
    if ScenarioInfo.MissionNumber == 1 and not ScenarioInfo.OpEnded then
        ScenarioFramework.Dialogue( OpStrings.C04_M01_040 )
    end
end

function Dialogue_M1_4()
    if ScenarioInfo.MissionNumber == 1 and not ScenarioInfo.OpEnded then
        ScenarioFramework.Dialogue( OpStrings.C04_M01_050 )
    end
end

function M1LaunchAirAttackReoccurring()
    -- These attacks are disabled for Easy difficulty
    if ScenarioInfo.MissionNumber == 1 and Difficulty ~= 1 then
        if not ScenarioInfo.FirstAirAttackSent then
            ScenarioInfo.FirstAirAttackSent = true
            local Attackers = ScenarioUtils.CreateArmyGroup( 'Aeon', AdjustForDifficulty( 'M1_Initial_Air_Attack' ))
            IssueFormAggressiveMove( Attackers, ScenarioUtils.MarkerToPosition( 'M3_Air_Attack_Base1_06' ), 'ChevronFormation', 0 )
        else
            LaunchAirAttack()
        end
        ScenarioFramework.CreateTimerTrigger( M1LaunchAirAttackReoccurring, M1AirAttackDelay[ Difficulty ])
    end
end

function M1LaunchNavalAttackReoccurring()
    -- These attacks are disabled for Easy difficulty
    if ScenarioInfo.MissionNumber == 1 and Difficulty ~= 1 then
        LaunchNavalAttack()
        ScenarioFramework.CreateTimerTrigger( M1LaunchNavalAttackReoccurring, M1NavalAttackDelay[ Difficulty ])
    end
end

function M1CommanderDefeated()

-- Commander defeated camera
    ScenarioFramework.CDRDeathNISCamera( ScenarioInfo.AeonCommanderM1, 7 )

    -- play the effects for the commander "escaping"
    ForkThread( M1CommanderEscapeEffect )

    -- Dialog
    ScenarioFramework.Dialogue( ScenarioStrings.PObjComp )
    ScenarioFramework.Dialogue( OpStrings.C04_M01_060 )
    ScenarioInfo.M1P1Objective:ManualResult( true )
    ForkThread( M1PrimaryObjectiveCompleted )

    -- Stop the reminder text from playing
    ScenarioInfo.M1P1Complete = true

    -- If the player doesn't complete the objective soon, remind him that it's important
    ScenarioFramework.CreateTimerTrigger( M1P2Reminder, M1P2InitialReminderDelay )
end

function M1CommanderEscapeEffect()
    -- play the effects for the commander "escaping"
    ScenarioFramework.FakeTeleportUnit( ScenarioInfo.AeonCommanderM1 , true)
end

function Node1Captured( newNodeHandle )
    -- record the new handle for the node
    ScenarioInfo.Node1 = newNodeHandle

    -- Track it to see if it ever dies
    ScenarioFramework.CreateUnitDeathTrigger( NodeDied, ScenarioInfo.Node1 )
    ScenarioFramework.CreateUnitReclaimedTrigger( NodeDied, ScenarioInfo.Node1 )

    -- Stop the reminder text from playing
    ScenarioInfo.M1P2Complete = true

-- 1st Node captured camera
    local camInfo = {
        blendTime = 1.0,
        holdTime = 4,
        orientationOffset = { 2.8, 0.2, 0 },
        positionOffset = { 0, 0.5, 0 },
        zoomVal = 35,
    }
    ScenarioFramework.OperationNISCamera( ScenarioInfo.Node1, camInfo )

    -- Congratulate the player, update the objective
    ScenarioFramework.Dialogue( ScenarioStrings.PObjComp )
    ScenarioFramework.Dialogue( OpStrings.C04_M01_070 )
    ScenarioInfo.M1P2Objective:ManualResult( true )
    ForkThread( M1PrimaryObjectiveCompleted )
end

-- This function is called from both primary objectives.
-- Once they both call this, it should end the mission.
function M1PrimaryObjectiveCompleted()
    ScenarioInfo.M1PrimaryObjectivesComplete = ScenarioInfo.M1PrimaryObjectivesComplete + 1
    if ScenarioInfo.M1PrimaryObjectivesComplete == 2 then
        EndMission1()
    end
end

function EndMission1()
    ScenarioFramework.Dialogue( ScenarioStrings.MissionSuccessDialogue )
    ScenarioFramework.Dialogue( OpStrings.C04_M01_100 )

    ForkThread( BeginMission2 )
end

function BeginMission2()
    -- Update the playable area
    ScenarioFramework.SetPlayableArea('M2_Playable_Area')
    ScenarioFramework.Dialogue( ScenarioStrings.MapExpansion )

    -- Set the maximum number of units that the player is allowed to have
    SetArmyUnitCap( Player, M2ArmyCap )

    -- Create the Civilian Base
    ScenarioInfo.CivilianBase = ScenarioUtils.CreateArmyGroup( 'Civilian', 'Civilian_Base' )

    -- Create the Civilian structures that need to be protected for the secondary objective
    ScenarioInfo.CivilianStructuresToBeProtected = ScenarioUtils.CreateArmyGroup( 'Civilian', 'Civilian_Structures' )

    for k, unit in ScenarioInfo.CivilianStructuresToBeProtected do
        ScenarioFramework.CreateUnitDeathTrigger( M2CivilianBuildingDestroyed, unit )
    end

    -- ScenarioFramework.CreateVisibleAreaLocation( 5, ScenarioInfo.Node2:GetPosition(), 10, ArmyBrains[Player] )

    AddTechMission2()
    ScenarioInfo.MissionNumber = 2
    ScenarioInfo.VarTable['Mission1'] = false
    ScenarioInfo.VarTable['Mission2'] = true

    -- Show the civilian base
    local pos = ScenarioInfo.Node2:GetPosition()
    local spec = {
        X = pos[1],
        Z = pos[2],
        Radius = 50,
        LifeTime = 0.2,
        Omni = false,
        Vision = true,
        Radar = false,
        Army = GetFocusArmy(),
    }
    local vizmarker = VizMarker( spec )
    ScenarioInfo.Node2.Trash:Add( vizmarker )
    vizmarker:AttachBoneTo( -1, ScenarioInfo.Node2, -1 )

    -- Create area trigger for the player's units that will cause the attackers to spawn in
    ScenarioFramework.CreateAreaTrigger( M2SpawnAttackers, ScenarioUtils.AreaToRect( 'M2_Trigger_Attack_Area' ), categories.ALLUNITS, true, false, ArmyBrains[Player], 1 )

    -- The distress call comes in
    ScenarioFramework.Dialogue( OpStrings.C04_M02_010 )

    -- Add initial objectives
    ScenarioInfo.M2P1Objective = Objectives.Basic(
        'primary',
        'incomplete',
        OpStrings.M2P1Text,
        OpStrings.M2P1Detail,
        Objectives.GetActionIcon('protect'),
        {
            Units = { ScenarioInfo.Node2 },
            MarkUnits = true,
        }
    )

    ScenarioInfo.M2S1Objective = Objectives.Basic(
        'secondary',
        'incomplete',
        OpStrings.M2S1Text,
        LOCF( OpStrings.M2S1Detail, CivilianBuildingSurvivePercentage ),
        Objectives.GetActionIcon('protect'),
        {
            Units = ScenarioInfo.CivilianStructuresToBeProtected,
            MarkUnits = true,
        }
    )

    ScenarioFramework.Dialogue( ScenarioStrings.NewPObj )

    ScenarioFramework.CreateTimerTrigger( Dialogue_M2_2, M2_2_Dialogue_Delay )
    ScenarioFramework.CreateTimerTrigger( Dialogue_M2_3, M2_3_Dialogue_Delay )

    ScenarioFramework.CreateTimerTrigger( M2LaunchAttackReoccurring, M2ReoccuringBaseAttackInitialDelay[ Difficulty ])

    ScenarioInfo.M2CivilianBuildingsDestroyed = 0

    -- If the player doesn't complete the objective soon, remind him that it's important
    ScenarioFramework.CreateTimerTrigger( M2P1Reminder, M2P1InitialReminderDelay )
end

function M2SpawnAttackers()
    -- Spawn the Aeon attackers
    local AeonAttackers = ScenarioUtils.CreateArmyGroup( 'Aeon', AdjustForDifficulty( 'M2_Initial_Attackers' ))
    -- IssueAggressiveMove( AeonAttackers, ScenarioUtils.MarkerToPosition( 'Node_2' ))
    IssuePatrol( AeonAttackers, ScenarioUtils.MarkerToPosition( 'Node_2' ))
    IssuePatrol( AeonAttackers, ScenarioUtils.MarkerToPosition( 'M3_Air_Attack_07' ))
    IssuePatrol( AeonAttackers, ScenarioUtils.MarkerToPosition( 'M3_Air_Attack_08' ))
    IssuePatrol( AeonAttackers, ScenarioUtils.MarkerToPosition( 'M3_Air_Attack_11' ))

    local NextAttackers = ScenarioUtils.CreateArmyGroup( 'Aeon', AdjustForDifficulty( 'M2_Initial_Attackers' ))
    -- IssueAggressiveMove( NextAttackers, ScenarioUtils.MarkerToPosition( 'Node_2' ))
    IssuePatrol( NextAttackers, ScenarioUtils.MarkerToPosition( 'Node_2' ))
    IssuePatrol( NextAttackers, ScenarioUtils.MarkerToPosition( 'M3_Air_Attack_07' ))
    IssuePatrol( NextAttackers, ScenarioUtils.MarkerToPosition( 'M3_Air_Attack_08' ))
    IssuePatrol( NextAttackers, ScenarioUtils.MarkerToPosition( 'M3_Air_Attack_11' ))

    local AirAttackers = ScenarioUtils.CreateArmyGroup( 'Aeon', AdjustForDifficulty( 'M2_Initial_Air_Attackers' ))
    IssuePatrol( AirAttackers, ScenarioUtils.MarkerToPosition( 'Node_2' ))
    IssuePatrol( AirAttackers, ScenarioUtils.MarkerToPosition( 'M3_Air_Attack_07' ))
    IssuePatrol( AirAttackers, ScenarioUtils.MarkerToPosition( 'M3_Air_Attack_08' ))
    IssuePatrol( AirAttackers, ScenarioUtils.MarkerToPosition( 'M3_Air_Attack_11' ))

    for k, unit in NextAttackers do
        table.insert( AeonAttackers, unit )
    end
    for k, unit in AirAttackers do
        table.insert( AeonAttackers, unit )
    end

    -- And track when they die
    ScenarioFramework.CreateGroupDeathTrigger( M2BaseSaved, AeonAttackers )

    -- let 5 seconds pass before we reveal everything so that shots will be in the air, etc.
    ScenarioFramework.CreateTimerTrigger( CivilianAllyWithPlayer, 5 )
end

function CivilianAllyWithPlayer()
    SetAlliance( Player, Civilian, 'Ally' )
end

function M2LaunchAttackReoccurring()
    -- These attacks are disabled for Easy difficulty
    if ScenarioInfo.MissionNumber == 2 and Difficulty ~= 1 then
        local Attackers = ScenarioUtils.CreateArmyGroup( 'Aeon', AdjustForDifficulty( 'M2_Base_Attackers' ))
        IssuePatrol( Attackers, ScenarioUtils.MarkerToPosition( 'M1_Attack_Patrol_4' ))
        IssuePatrol( Attackers, ScenarioUtils.MarkerToPosition( 'M1_Attack_Patrol_5' ))
        IssuePatrol( Attackers, ScenarioUtils.MarkerToPosition( 'M1_Attack_Patrol_6' ))
        IssuePatrol( Attackers, ScenarioUtils.MarkerToPosition( 'M1_Attack_Patrol_7' ))
        ScenarioFramework.CreateTimerTrigger( M2LaunchAttackReoccurring, M2ReoccuringBaseAttackDelay[ Difficulty ])
    end
end

function Dialogue_M2_2()
    if ScenarioInfo.MissionNumber == 2 and not ScenarioInfo.OpEnded then
        ScenarioFramework.Dialogue( OpStrings.C04_M02_020 )
    end
end

function Dialogue_M2_3()
    if ScenarioInfo.MissionNumber == 2 and not ScenarioInfo.OpEnded then
        ScenarioFramework.Dialogue( OpStrings.C04_M02_030 )
    end
end

function M2CivilianBuildingDestroyed()
    ScenarioInfo.M2CivilianBuildingsDestroyed = ScenarioInfo.M2CivilianBuildingsDestroyed + 1
    if ScenarioInfo.M2CivilianBuildingsDestroyed == M2TooManyDestroyedBuildings then
        Objectives.UpdateBasicObjective( ScenarioInfo.M2S1Objective, 'description', LOCF( OpStrings.M2S1Fail, CivilianBuildingSurvivePercentage ))
        ScenarioInfo.M2S1Objective:ManualResult( false )
    end
end

function M2BaseSaved()
    ScenarioFramework.Dialogue( ScenarioStrings.PObjComp )
    ScenarioFramework.Dialogue( OpStrings.C04_M02_050 )
    -- update objectives
    ScenarioInfo.M2P1Objective:ManualResult( true )
    if ScenarioInfo.M2CivilianBuildingsDestroyed < M2TooManyDestroyedBuildings then
        ScenarioInfo.M2S1Objective:ManualResult( true )
        ScenarioFramework.Dialogue( OpStrings.C04_M02_040 )
    end

    -- Stop the reminder text from playing
    ScenarioInfo.M2P1Complete = true

    -- Give ally base buildings to the player
    for k, unit in ScenarioInfo.CivilianBase do
        if not unit:IsDead() and unit:GetArmy() ~= Player then
            ScenarioFramework.GiveUnitToArmy( unit, Player )
        end
    end

    if (ScenarioInfo.Node2:GetArmy() ~= Player) then
        ScenarioInfo.Node2 = ScenarioFramework.GiveUnitToArmy( ScenarioInfo.Node2, Player )
        ScenarioFramework.CreateUnitDeathTrigger( NodeDied, ScenarioInfo.Node2 )
        ScenarioFramework.CreateUnitReclaimedTrigger( NodeDied, ScenarioInfo.Node2 )
    end

    ScenarioInfo.M2P2Objective = Objectives.Basic(
        'primary',
        'incomplete',
        OpStrings.M2P2Text,
        OpStrings.M2P2Detail,
        Objectives.GetActionIcon('protect'),
        {
            Units = { ScenarioInfo.Node2 },
            MarkUnits = true,
        }
    )

-- Saved station 04
    local camInfo = {
        blendTime = 1.0,
        holdTime = 4,
        orientationOffset = { 2.95, 0.2, 0 },
        positionOffset = { 0, 0.5, 0 },
        zoomVal = 30,
    }
    ScenarioFramework.OperationNISCamera( ScenarioInfo.Node2, camInfo )

    ScenarioFramework.Dialogue( ScenarioStrings.NewPObj )
    ScenarioFramework.CreateTimerTrigger( Dialogue_M2_4, M2_4_Dialogue_Delay )
    ScenarioFramework.CreateTimerTrigger( M2LaunchWave1, M2Wave1Delay )
end

function M2LaunchWave1()
    if ScenarioInfo.MissionNumber ~= 2 then return end -- in case we skipped mission 2 via debug
    ScenarioInfo.AeonWave1 = ScenarioUtils.CreateArmyGroup( 'Aeon', AdjustForDifficulty( 'M2_Wave_1' ))
    ScenarioInfo.VarTable['EnableWave1'] = true

    -- No need to give them orders -- the platoons set up in the editor will do that

    -- trigger to keep track of them
    ScenarioFramework.CreateGroupDeathTrigger( M2Wave1Killed, ScenarioInfo.AeonWave1 )
end

function M2Wave1Killed()
    if ScenarioInfo.MissionNumber ~= 2 then return end -- in case we skipped mission 2 via debug
    ScenarioFramework.CreateTimerTrigger( M2LaunchWave2, M2Wave2Delay )
    ScenarioInfo.VarTable['EnableWave1'] = false
end

function M2LaunchWave2()
    if ScenarioInfo.MissionNumber ~= 2 then return end -- in case we skipped mission 2 via debug
    ScenarioInfo.AeonWave2 = ScenarioUtils.CreateArmyGroup( 'Aeon', AdjustForDifficulty( 'M2_Wave_2' ))
    ScenarioInfo.AeonWave2Transports = ScenarioUtils.CreateArmyGroup( 'Aeon', AdjustForDifficulty( 'M2_Wave2_Transports' ))
    ScenarioInfo.VarTable['EnableWave2'] = true

    -- No need to give them orders -- the platoons set up in the editor will do that

    -- trigger to keep track of them
    ScenarioFramework.CreateGroupDeathTrigger( M2Wave2Killed, ScenarioInfo.AeonWave2 )
end

function M2Wave2Killed()
    if ScenarioInfo.MissionNumber ~= 2 then return end -- in case we skipped mission 2 via debug
    ScenarioFramework.CreateTimerTrigger( M2LaunchWave3, M2Wave3Delay )
    ScenarioInfo.VarTable['EnableWave2'] = false
end

function M2LaunchWave3()
    if ScenarioInfo.MissionNumber ~= 2 then return end -- in case we skipped mission 2 via debug
    ScenarioInfo.AeonWave3 = ScenarioUtils.CreateArmyGroup( 'Aeon', AdjustForDifficulty( 'M2_Wave_3' ))
    ScenarioInfo.AeonWave3Transports = ScenarioUtils.CreateArmyGroup( 'Aeon', AdjustForDifficulty( 'M2_Wave3_Transports' ))
    ScenarioInfo.VarTable['EnableWave3'] = true

    -- No need to give them orders -- the platoons set up in the editor will do that

    -- trigger to keep track of them
    ScenarioFramework.CreateGroupDeathTrigger( M2Wave3Killed, ScenarioInfo.AeonWave3 )
end

-- Done with mission 2!
function M2Wave3Killed()
    -- Clean up the extra transports that were spawned in waves 2 and 3 while they are still
    -- out of the playable area
    for k, unit in ScenarioInfo.AeonWave2Transports do
        if not unit:IsDead() then
            unit:Destroy()
        end
    end
    for k, unit in ScenarioInfo.AeonWave3Transports do
        if not unit:IsDead() then
            unit:Destroy()
        end
    end

    ScenarioInfo.VarTable['EnableWave3'] = false
    ScenarioInfo.M2P2Objective:ManualResult( true )
    ScenarioFramework.Dialogue( ScenarioStrings.PObjComp )
    ScenarioFramework.Dialogue( ScenarioStrings.MissionSuccessDialogue )
    ScenarioFramework.Dialogue( OpStrings.C04_M02_070 )
    BeginMission3()
end

function Dialogue_M2_4()
    if ScenarioInfo.MissionNumber == 2 and not ScenarioInfo.OpEnded then
        ScenarioFramework.Dialogue( OpStrings.C04_M02_060 )
    end
end

function Node2Captured( newNodeHandle )
    ScenarioInfo.Node2 = newNodeHandle
    ScenarioFramework.CreateUnitDeathTrigger( NodeDied, ScenarioInfo.Node2 )
    ScenarioFramework.CreateUnitReclaimedTrigger( NodeDied, ScenarioInfo.Node2 )

    -- fix up objective icon, if needed
    if ScenarioInfo.M2P1Objective.Active then
        ScenarioInfo.M2P1Objective:AddBasicUnitTarget (newNodeHandle)
    elseif ScenarioInfo.M2P2Objective.Active then
        ScenarioInfo.M2P2Objective:AddBasicUnitTarget (newNodeHandle)
    end
end

function BeginMission3()

    -- Set the playable area
    ScenarioFramework.SetPlayableArea('M3_Playable_Area')
    ScenarioFramework.Dialogue( ScenarioStrings.MapExpansion )

    -- Show the location of the nodes and mainframe
    ScenarioFramework.CreateVisibleAreaLocation( 5, ScenarioInfo.Node3:GetPosition(), 10, ArmyBrains[Player] )
    ScenarioFramework.CreateVisibleAreaLocation( 5, ScenarioInfo.Node4:GetPosition(), 10, ArmyBrains[Player] )
    ScenarioFramework.CreateVisibleAreaLocation( 5, ScenarioInfo.Mainframe:GetPosition(), 10, ArmyBrains[Player] )

    -- Set the maximum number of units that the player is allowed to have
    SetArmyUnitCap( Player, M3ArmyCap )

    ScenarioInfo.AeonCommanderM3 = ScenarioUtils.CreateArmyUnit( 'Aeon', 'M3_Commander' )
    ScenarioInfo.AeonCommanderM3:CreateEnhancement('AdvancedEngineering')
    ScenarioInfo.AeonCommanderM3:CreateEnhancement('Teleporter')
    ScenarioInfo.AeonCommanderM3:SetDoNotTarget(true) -- prevent auto-targetting until the EMP goes off
    ScenarioFramework.CreateUnitDeathTrigger( EnemyCommanderDied, ScenarioInfo.AeonCommanderM3 )
    -- Delay the explosion so that we can catch it on camera
    ScenarioFramework.PauseUnitDeath( ScenarioInfo.AeonCommanderM3 )

    IssuePatrol({ ScenarioInfo.AeonCommanderM3 }, ScenarioUtils.MarkerToPosition( 'Aeon_Patrol_Air_M3_1' ))
    IssuePatrol({ ScenarioInfo.AeonCommanderM3 }, ScenarioUtils.MarkerToPosition( 'Aeon_Patrol_Air_M3_2' ))
    IssuePatrol({ ScenarioInfo.AeonCommanderM3 }, ScenarioUtils.MarkerToPosition( 'Aeon_Patrol_Air_M3_3' ))

    -- Create the units that will be guarding the NW and NE nodes, and set them patrolling
    ScenarioUtils.CreateArmyGroup( 'Aeon', AdjustForDifficulty( 'M3_NW_Defenders' ))
    ScenarioUtils.CreateArmyGroup( 'Aeon', AdjustForDifficulty( 'M3_NE_Defenders' ))

    ScenarioInfo.AeonNWLandPatrol01 = ScenarioUtils.CreateArmyGroup( 'Aeon', AdjustForDifficulty( 'M3_NW_Patrol_Land01' ))
    ScenarioInfo.AeonNWNavalPatrol01 = ScenarioUtils.CreateArmyGroup( 'Aeon', AdjustForDifficulty( 'M3_NW_Patrol_Naval01' ))
    ScenarioInfo.AeonNWNavalPatrol02 = ScenarioUtils.CreateArmyGroup( 'Aeon', AdjustForDifficulty( 'M3_NW_Patrol_Naval02' ))

    ScenarioInfo.AeonNELandPatrol01 = ScenarioUtils.CreateArmyGroup( 'Aeon', AdjustForDifficulty( 'M3_NE_Patrol_Land01' ))
    ScenarioInfo.AeonNELandPatrol02 = ScenarioUtils.CreateArmyGroup( 'Aeon', AdjustForDifficulty( 'M3_NE_Patrol_Land02' ))
    ScenarioInfo.AeonNELandPatrol03 = ScenarioUtils.CreateArmyGroup( 'Aeon', AdjustForDifficulty( 'M3_NE_Patrol_Land03' ))
    ScenarioInfo.AeonNENavalPatrol01 = ScenarioUtils.CreateArmyGroup( 'Aeon', AdjustForDifficulty( 'M3_NE_Patrol_Naval01' ))
    ScenarioInfo.AeonNENavalPatrol02 = ScenarioUtils.CreateArmyGroup( 'Aeon', AdjustForDifficulty( 'M3_NE_Patrol_Naval02' ))

    IssuePatrol( ScenarioInfo.AeonNWLandPatrol01, ScenarioUtils.MarkerToPosition( 'M3_NW_Patrol_5' ))
    IssuePatrol( ScenarioInfo.AeonNWLandPatrol01, ScenarioUtils.MarkerToPosition( 'M3_NW_Patrol_6' ))

    IssuePatrol( ScenarioInfo.AeonNWNavalPatrol01, ScenarioUtils.MarkerToPosition( 'M3_NW_Patrol_1' ))
    IssuePatrol( ScenarioInfo.AeonNWNavalPatrol01, ScenarioUtils.MarkerToPosition( 'M3_NW_Patrol_2' ))

    IssuePatrol( ScenarioInfo.AeonNWNavalPatrol02, ScenarioUtils.MarkerToPosition( 'M3_NW_Patrol_3' ))
    IssuePatrol( ScenarioInfo.AeonNWNavalPatrol02, ScenarioUtils.MarkerToPosition( 'M3_NW_Patrol_4' ))

    IssuePatrol( ScenarioInfo.AeonNENavalPatrol01, ScenarioUtils.MarkerToPosition( 'M3_NE_Patrol_5' ))
    IssuePatrol( ScenarioInfo.AeonNENavalPatrol01, ScenarioUtils.MarkerToPosition( 'M3_NE_Patrol_6' ))

    IssuePatrol( ScenarioInfo.AeonNENavalPatrol02, ScenarioUtils.MarkerToPosition( 'M3_NE_Patrol_7' ))
    IssuePatrol( ScenarioInfo.AeonNENavalPatrol02, ScenarioUtils.MarkerToPosition( 'M3_NE_Patrol_8' ))

    -- IssuePatrol( ScenarioInfo.AeonNELandPatrol01, ScenarioUtils.MarkerToPosition( 'M3_NE_Patrol_1' ))
    -- IssuePatrol( ScenarioInfo.AeonNELandPatrol01, ScenarioUtils.MarkerToPosition( 'M3_NE_Patrol_2' ))

    IssuePatrol( ScenarioInfo.AeonNELandPatrol02, ScenarioUtils.MarkerToPosition( 'M3_NE_Patrol_1' ))
    IssuePatrol( ScenarioInfo.AeonNELandPatrol02, ScenarioUtils.MarkerToPosition( 'M3_NE_Patrol_2' ))
    IssuePatrol( ScenarioInfo.AeonNELandPatrol02, ScenarioUtils.MarkerToPosition( 'M3_NE_Patrol_3' ))
    IssuePatrol( ScenarioInfo.AeonNELandPatrol02, ScenarioUtils.MarkerToPosition( 'M3_NE_Patrol_2' ))

    -- IssuePatrol( ScenarioInfo.AeonNELandPatrol03, ScenarioUtils.MarkerToPosition( 'M3_NE_Patrol_3' ))
    -- IssuePatrol( ScenarioInfo.AeonNELandPatrol03, ScenarioUtils.MarkerToPosition( 'M3_NE_Patrol_4' ))

    -- Spawn the M3 base adjusted for difficulty, and put all of those units into a single group handle
    ScenarioInfo.M3_Base = ScenarioUtils.CreateArmyGroup( 'Aeon', AdjustForDifficulty( 'M3_Base_Economy' ))
    local tempUnitGroup
    tempUnitGroup = ScenarioUtils.CreateArmyGroup( 'Aeon', AdjustForDifficulty( 'M3_Base_Defenses' ))
    for k, unit in tempUnitGroup do
        -- Filter out walls, they don't need to get killed for the base to be considered dead
        if not EntityCategoryContains( categories.uab5101, unit ) then
            table.insert( ScenarioInfo.M3_Base, unit )
            unit:SetDoNotTarget(true)
        end
    end
    tempUnitGroup = ScenarioUtils.CreateArmyGroup( 'Aeon', AdjustForDifficulty( 'M3_Base_Factories' ))
    for k, unit in tempUnitGroup do
        table.insert( ScenarioInfo.M3_Base, unit )
    end
    tempUnitGroup = ScenarioUtils.CreateArmyGroup( 'Aeon', AdjustForDifficulty( 'M3_Base_Misc' ))
    for k, unit in tempUnitGroup do
        table.insert( ScenarioInfo.M3_Base, unit )
    end

    -- Keep track of all spawned units to see if they come under attack early
    for k, unit in ScenarioInfo.M3_Base do
        ScenarioFramework.CreateUnitDamagedTrigger( M3BaseDamaged, unit )
    end

    AddTechMission3()
    ScenarioInfo.MissionNumber = 3
    ScenarioInfo.VarTable['Mission2'] = false
    ScenarioInfo.VarTable['Mission3'] = true

    -- Briefing
    ScenarioFramework.Dialogue( OpStrings.C04_M03_010 )
    ScenarioFramework.Dialogue( OpStrings.C04_M03_020 )

    ScenarioInfo.M3P1Objective = Objectives.Basic(
        'primary',
        'incomplete',
        OpStrings.M3P1Text,
        OpStrings.M3P1Detail,
        Objectives.GetActionIcon('capture'),
        {
            Units = { ScenarioInfo.Node3 },
            MarkUnits = true,
        }
    )

    ScenarioInfo.M3P2Objective = Objectives.Basic(
        'primary',
        'incomplete',
        OpStrings.M3P2Text,
        OpStrings.M3P2Detail,
        Objectives.GetActionIcon('capture'),
        {
            Units = { ScenarioInfo.Node4 },
            MarkUnits = true,
        }
    )

    ScenarioInfo.M3P4Objective = Objectives.Basic(
        'primary',
        'incomplete',
        OpStrings.M3P4Text,
        OpStrings.M3P4Detail,
        Objectives.GetActionIcon('protect'),
        {
            Areas = { 'Aeon_Base_M3'},
            ShowFaction = 'Aeon',
            -- Units = ScenarioInfo.M3_Base,
            -- MarkUnits = false,
        }
    )

    ScenarioFramework.Dialogue( ScenarioStrings.NewPObj )
    ScenarioFramework.CreateTimerTrigger( M3LaunchAttackReoccurring, M3AttackInitialDelay[ Difficulty ])

    -- If the player doesn't complete the objective soon, remind him that it's important
    ScenarioFramework.CreateTimerTrigger( M3P1Reminder, M3P1InitialReminderDelay )
end

function M3BaseDamaged()
    if not ScenarioInfo.DisableM3BaseDamagedTriggers then
-- base mainframe camera settings
        local camInfo = {
            blendTime = 1.0,
            holdTime = 4,
            orientationOffset = { -2.78, 0.8, 0 },
            positionOffset = { 0, 4, 0 },
            zoomVal = 45,
        }
        ScenarioInfo.DisableM3BaseDamagedTriggers = true
        if ScenarioInfo.M3BaseDamageWarnings == 2 then
            -- Mainfram destroyed cam values
            camInfo.blendTime = 2.5
            camInfo.holdTime = nil
            camInfo.orientationOffset[1] = math.pi
            camInfo.spinSpeed = 0.03
            camInfo.overrideCam = true
            -- Detonate the mainframe
            ScenarioInfo.Mainframe:Kill()
            -- player loses
            ScenarioFramework.PlayerLose(OpStrings.C04_M03_050)
        elseif ScenarioInfo.M3BaseDamageWarnings == 1 then
            -- strong warning
            ScenarioFramework.Dialogue( OpStrings.C04_M03_040 )
        else
            -- weak warning
            ScenarioFramework.Dialogue( OpStrings.C04_M03_030 )
        end
        ScenarioFramework.OperationNISCamera( ScenarioInfo.Mainframe, camInfo )
        -- Show the mainframe camera
        ScenarioInfo.M3BaseDamageWarnings = ScenarioInfo.M3BaseDamageWarnings + 1
        ForkThread( EnableM3BaseDamagedTriggersAfterDelay )
    end
end

function EnableM3BaseDamagedTriggersAfterDelay()
    WaitSeconds( ReenableM3BaseDamageTriggersDelay )
    for k, unit in ScenarioInfo.M3_Base do
        if not unit:IsDead() then
            ScenarioFramework.CreateUnitDamagedTrigger( M3BaseDamaged, unit )
        end
    end
    ScenarioInfo.DisableM3BaseDamagedTriggers = false
end

function M3LaunchAttackReoccurring()
    -- These attacks are disabled for Easy difficulty
    if ScenarioInfo.MissionNumber == 3 and Difficulty ~= 1 then
        local TotalChance = M3AttackWaveAgainstPlayerBaseChance + M3AttackWaveAgainstNode2Chance
        local RandomNumber = Random( 1, TotalChance )

        if RandomNumber <= M3AttackWaveAgainstPlayerBaseChance then
            ScenarioInfo.VarTable['AttackBase1'] = true
        else
            ScenarioInfo.VarTable['AttackBase2'] = true
        end

        TotalChance = M3AttackWaveUseRoute1 + M3AttackWaveUseRoute2
        RandomNumber = Random( 1, TotalChance )
        ScenarioInfo.VarTable['UseLandRoute1'] = true

        if RandomNumber <= M3AttackWaveUseRoute1 then
            -- LOG( 'using route 1')
            ScenarioInfo.VarTable['UseAirRoute1'] = true
        else
            -- LOG( 'using route 2')
            -- ScenarioInfo.VarTable['UseLandRoute2'] = true
            ScenarioInfo.VarTable['UseAirRoute2'] = true
        end

        TotalChance = M3AttackWaveLandOnlyChance + M3AttackWaveAirOnlyChance + M3AttackWaveCombinedChance
        RandomNumber = Random( 1, TotalChance )

        if RandomNumber <= M3AttackWaveLandOnlyChance then
            LaunchLandAttack()
        elseif RandomNumber <= M3AttackWaveAirOnlyChance then
            LaunchAirAttack()
        else
            LaunchLandAttack()
            LaunchAirAttack()
        end

        -- LOG( 'AttackBase1 = ', ScenarioInfo.VarTable['AttackBase1'] )
        -- LOG( 'AttackBase2 = ', ScenarioInfo.VarTable['AttackBase2'] )
        -- LOG( 'UseLandRoute1 = ', ScenarioInfo.VarTable['UseLandRoute1'] )
        -- LOG( 'UseLandRoute2 = ', ScenarioInfo.VarTable['UseLandRoute2'] )
        -- LOG( 'UseAirRoute1 = ', ScenarioInfo.VarTable['UseAirRoute1'] )
        -- LOG( 'UseAirRoute2 = ', ScenarioInfo.VarTable['UseAirRoute2'] )

        ScenarioFramework.CreateTimerTrigger( M3LaunchAttackReoccurring, M3AttackDelay[ Difficulty ])
    end
end

-- Northwest node
function Node3Captured( newNodeHandle )
    ScenarioInfo.Node3 = newNodeHandle
    ScenarioInfo.Node3Captured = true
    ScenarioFramework.CreateUnitDeathTrigger( NodeDied, ScenarioInfo.Node3 )
    ScenarioFramework.CreateUnitReclaimedTrigger( NodeDied, ScenarioInfo.Node3 )

    ScenarioInfo.M3P1Objective:ManualResult( true )
    ScenarioFramework.Dialogue( ScenarioStrings.PObjComp )

    -- to do: update with new dialog for stealth unit condition
    -- ...looks like they decided not to have alternate dialog
    -- if ScenarioFramework.UnitsInAreaCheck( categories.url0306, 'Node3_Area' ) then
        ScenarioFramework.Dialogue( OpStrings.C04_M03_060, false, true )
    -- else
    -- ScenarioFramework.Dialogue( OpStrings.M3_2Dialogue )
    -- end

    if ScenarioInfo.Node3Captured and ScenarioInfo.Node4Captured then
        ForkThread( AllNodesCaptured )
    else
        ScenarioFramework.Dialogue( OpStrings.C04_M03_063 )
    end

-- NW Node captured camera
    local camInfo = {
        blendTime = 1.0,
        holdTime = 4,
        orientationOffset = { -1.38, 0.3, 0 },
        positionOffset = { 0, 0.5, 0 },
        zoomVal = 35,
    }
    ScenarioFramework.OperationNISCamera( ScenarioInfo.Node3, camInfo )
end

function Node4Captured( newNodeHandle )
    ScenarioInfo.Node4 = newNodeHandle
    ScenarioInfo.Node4Captured = true
    ScenarioFramework.CreateUnitDeathTrigger( NodeDied, ScenarioInfo.Node4 )
    ScenarioFramework.CreateUnitReclaimedTrigger( NodeDied, ScenarioInfo.Node4 )

    ScenarioInfo.M3P2Objective:ManualResult( true )
    ScenarioFramework.Dialogue( ScenarioStrings.PObjComp )

    ScenarioFramework.Dialogue( OpStrings.C04_M03_065, false, true )

    if ScenarioInfo.Node3Captured and ScenarioInfo.Node4Captured then
        ForkThread( AllNodesCaptured )
    else
        ScenarioFramework.Dialogue( OpStrings.C04_M03_063 )
    end

-- NE Node captured camera
    local camInfo = {
        blendTime = 1.0,
        holdTime = 4,
        orientationOffset = { 0.3927, 0.1, 0 },
        positionOffset = { 0, 2, 0 },
        zoomVal = 40,
    }
    ScenarioFramework.OperationNISCamera( ScenarioInfo.Node4, camInfo )
end

function AllNodesCaptured()
    ScenarioInfo.AllNodesCaptured = true

    -- Stop the reminder text from playing
    ScenarioInfo.M3P1Complete = true

    ScenarioFramework.Dialogue( OpStrings.C04_M03_070, AllNodesCapturedPart2, true )
end

function AllNodesCapturedPart2()
    if ScenarioInfo.AeonCommanderDead then
        ForkThread( PlayerWin )
    else
        ScenarioFramework.CreateTimerTrigger( EMPTriggered, EMPDelay )
    end
end

function EMPTriggered()

    -- NOW turn on kill commander objective
    ScenarioInfo.M3P3Objective = Objectives.Kill(
        'primary',
        'incomplete',
        OpStrings.M3P3Text,
        OpStrings.M3P3Detail,
        {
            Units = { ScenarioInfo.AeonCommanderM3 },
        }
    )

    ScenarioInfo.M3P4Objective:ManualResult( true )
    -- If the player doesn't complete the objective soon, remind him that it's important
    ScenarioFramework.CreateTimerTrigger( M3P3Reminder, M3P3InitialReminderDelay )

    -- Show the base
    local pos = ScenarioInfo.Mainframe:GetPosition()
    local spec = {
        X = pos[1],
        Z = pos[2],
        Radius = 50,
        LifeTime = 30,
        Omni = false,
        Vision = true,
        Radar = false,
        Army = GetFocusArmy(),
    }
    local vizmarker = VizMarker( spec )
    ScenarioInfo.Mainframe.Trash:Add( vizmarker )
    vizmarker:AttachBoneTo( -1, ScenarioInfo.Mainframe, -1 )

    -- Spawn the effect
    local myproj = ScenarioInfo.Mainframe:CreateProjectile('/projectiles/CIFEMPFluxWarhead02/CIFEMPFluxWarhead02_proj.bp', 0, 0, 0, nil, nil, nil):SetCollision(false)
    -- This effect is a neutered nuke, so set the damage to zero
    myproj.NukeOuterRingDamage = 1
    myproj.NukeOuterRingRadius = 1
    myproj.NukeOuterRingTicks = 1
    myproj.NukeOuterRingTotalTime = 1
    myproj.NukeInnerRingDamage = 1
    myproj.NukeInnerRingRadius = 1
    myproj.NukeInnerRingTicks = 1
    myproj.NukeInnerRingTotalTime = 1
    myproj:CreateNuclearExplosion()

    -- set off the EMP -- all Aeon units in the base get stunned
    -- except for air units, which just die
    local AeonUnits = GetUnitsInRect( ScenarioUtils.AreaToRect( 'Aeon_Base_M3' ))
    for k, unit in AeonUnits do
        if EntityCategoryContains( categories.AEON * categories.AIR, unit ) or EntityCategoryContains( categories.AEON * categories.uab4202, unit ) then
            unit:Kill()
        elseif EntityCategoryContains( categories.AEON - categories.uab5101, unit ) then
            unit:SetStunned( StunDuration[ Difficulty ])
            unit:SetDoNotTarget(false)
        end
    end

    ScenarioFramework.Dialogue( OpStrings.C04_M03_080 )
    ScenarioFramework.CreateTimerTrigger( Dialogue_M3_5, M3_5_Dialogue_Delay )

    -- Allow the player to attack the main base now
    ScenarioInfo.DisableM3BaseDamagedTriggers = true

    -- Turn auto-targetting back on
    ScenarioInfo.AeonCommanderM3:SetDoNotTarget(false)

-- Show the mainframe for emp event
    local camInfo = {
        blendTime = 1.0,
        holdTime = 8,
        orientationOffset = { -2.78, 0.8, 0 },
        positionOffset = { 0, 4, 0 },
        zoomVal = 45,
    }
    ScenarioFramework.OperationNISCamera( ScenarioInfo.Mainframe, camInfo )
end

function Dialogue_M3_5()
    if not ScenarioInfo.AeonCommanderDead and not ScenarioInfo.OpEnded then
        ScenarioFramework.Dialogue( OpStrings.C04_M03_090 )
    end
end

function EnemyCommanderDied()
-- Spin the camera around the explosion
-- ScenarioFramework.EndOperationCamera( ScenarioInfo.AeonCommanderM3, true )
    ScenarioFramework.CDRDeathNISCamera( ScenarioInfo.AeonCommanderM3 )

    -- Aeon commander's death cry
    ScenarioFramework.Dialogue( OpStrings.C04_M03_095, false, true )

    ScenarioInfo.AeonCommanderDead = true

    -- Stop the reminder text from playing
    ScenarioInfo.M3P3Complete = true

    if ScenarioInfo.AllNodesCaptured then
        ScenarioFramework.Dialogue( ScenarioStrings.PObjComp )
        PlayerWin()
    end
end

function AddTechMission2()
    ScenarioFramework.RemoveRestrictionForAllHumans(
        categories.urb4202 + -- T2 Shield Generator
        categories.urb4204 + -- T2 Shield upgrade 1
        categories.urb4205 + -- T2 Shield upgrade 2
        categories.urb2303 + -- Light Artillery Installation
        categories.ura0104 + -- T2 Transport
        categories.ura0302   -- Spy Plane
    )
end

function AddTechMission3()
    ScenarioFramework.RemoveRestrictionForAllHumans(
        categories.urb5202 + -- Air Staging Platform
        categories.urb4201 + -- T2 Anti-Missile Gun
        categories.url0306   -- Mobile Stealth Generator
    )
end

function PlayerCommanderDied(deadCommander)
    ScenarioFramework.PlayerDeath(deadCommander, OpStrings.C04_D01_010)
end

function NodeDied(unit)
    -- Let the player know what happened
    -- And end the game

    if ScenarioInfo.M1P2Objective.Active then
        ScenarioInfo.M1P2Objective:ManualResult( false )
    elseif ScenarioInfo.M2P1Objective.Active then
        ScenarioInfo.M2P1Objective:ManualResult( false )
    elseif ScenarioInfo.M2P2Objective.Active then
        ScenarioInfo.M2P2Objective:ManualResult( false )
    end

-- set base camera values if a node dies
    local camInfo = {
        blendTime = 2.5,
        holdTime = nil,
        spinSpeed = 0.03,
        overrideCam = true,
    }
    if unit == ScenarioInfo.Node1 then
        camInfo.orientationOffset = { math.pi, 0.2, 0 }
        camInfo.positionOffset = { 0, 0.5, 0 }
        camInfo.zoomVal = 35
    elseif unit == ScenarioInfo.Node2 then
        camInfo.orientationOffset = { math.pi, 0.2, 0 }
        camInfo.positionOffset = { 0, 0.5, 0 }
        camInfo.zoomVal = 30
    elseif unit == ScenarioInfo.Node3 then
        camInfo.orientationOffset = { math.pi, 0.3, 0 }
        camInfo.positionOffset = { 0, 1, 0 }
        camInfo.zoomVal = 30
    elseif unit == ScenarioInfo.Node4 then
        camInfo.orientationOffset = { math.pi, 0.1, 0 }
        camInfo.positionOffset = { 0, 2, 0 }
        camInfo.zoomVal = 40
    end
    ScenarioFramework.OperationNISCamera( unit, camInfo )
    ScenarioFramework.PlayerLose(OpStrings.C04_M01_110)
end

-- Signal the Attack Manager that it is allowed to take existing platoons and attack with them
function LaunchAirAttack()
    ScenarioInfo.VarTable['LaunchAirAttack'] = true
end

function LaunchNavalAttack()
    ScenarioInfo.VarTable['LaunchNavalAttack'] = true
end

function LaunchLandAttack()
    ScenarioInfo.VarTable['LaunchLandAttack'] = true
end

function AdjustForDifficulty( string_in )
    local string_out = string_in
    if Difficulty == 1 then
        string_out = string_out .. Difficulty1_Suffix
    elseif Difficulty == 2 then
        string_out = string_out .. Difficulty2_Suffix
    elseif Difficulty == 3 then
        string_out = string_out .. Difficulty3_Suffix
    end
    return string_out
end

function M1P1Reminder()
    if not ScenarioInfo.M1P1Complete and not ScenarioInfo.OpEnded then
        if not ScenarioInfo.M1P1ReminderAlternate then
            ScenarioInfo.M1P1ReminderAlternate = 1
            ScenarioFramework.Dialogue( OpStrings.C04_M01_080 )
        elseif ScenarioInfo.M1P1ReminderAlternate == 1 then
            ScenarioInfo.M1P1ReminderAlternate = 2
            ScenarioFramework.Dialogue( OpStrings.C04_M01_085 )
        else
            ScenarioInfo.M1P1ReminderAlternate = false
            ScenarioFramework.Dialogue( ScenarioStrings.CybranGenericReminder )
        end
        ScenarioFramework.CreateTimerTrigger( M1P1Reminder, M1P1ReoccuringReminderDelay )
    end
end

function M1P2Reminder()
    if not ScenarioInfo.M1P2Complete and not ScenarioInfo.OpEnded then
        if not ScenarioInfo.M1P2ReminderAlternate then
            ScenarioInfo.M1P2ReminderAlternate = 1
            ScenarioFramework.Dialogue( OpStrings.C04_M01_090 )
        elseif ScenarioInfo.M1P2ReminderAlternate == 1 then
            ScenarioInfo.M1P2ReminderAlternate = 2
            ScenarioFramework.Dialogue( OpStrings.C04_M01_095 )
        else
            ScenarioInfo.M1P2ReminderAlternate = false
            ScenarioFramework.Dialogue( ScenarioStrings.CybranGenericReminder )
        end
        ScenarioFramework.CreateTimerTrigger( M1P2Reminder, M1P2ReoccuringReminderDelay )
    end
end

function M2P1Reminder()
    if not ScenarioInfo.M2P1Complete and not ScenarioInfo.OpEnded then
        if not ScenarioInfo.M2P1ReminderAlternate then
            ScenarioInfo.M2P1ReminderAlternate = 1
            ScenarioFramework.Dialogue( OpStrings.C04_M02_080 )
        elseif ScenarioInfo.M2P1ReminderAlternate == 1 then
            ScenarioInfo.M2P1ReminderAlternate = 2
            ScenarioFramework.Dialogue( OpStrings.C04_M02_085 )
        else
            ScenarioInfo.M2P1ReminderAlternate = false
            ScenarioFramework.Dialogue( ScenarioStrings.CybranGenericReminder )
        end
        ScenarioFramework.CreateTimerTrigger( M2P1Reminder, M2P1ReoccuringReminderDelay )
    end
end

function M3P1Reminder()
    if not ScenarioInfo.M3P1Complete and not ScenarioInfo.OpEnded then
        if not ScenarioInfo.M3P1ReminderAlternate then
            ScenarioInfo.M3P1ReminderAlternate = 1
            ScenarioFramework.Dialogue( OpStrings.C04_M03_100 )
        elseif ScenarioInfo.M3P1ReminderAlternate == 1 then
            ScenarioInfo.M3P1ReminderAlternate = 2
            ScenarioFramework.Dialogue( OpStrings.C04_M03_105 )
        else
            ScenarioInfo.M3P1ReminderAlternate = false
            ScenarioFramework.Dialogue( ScenarioStrings.CybranGenericReminder )
        end
        ScenarioFramework.CreateTimerTrigger( M3P1Reminder, M3P1ReoccuringReminderDelay )
    end
end

function M3P3Reminder()
    if not ScenarioInfo.M3P3Complete and not ScenarioInfo.OpEnded then
        if not ScenarioInfo.M3P3ReminderAlternate then
            ScenarioInfo.M3P3ReminderAlternate = 1
            ScenarioFramework.Dialogue( OpStrings.C04_M03_110 )
        elseif ScenarioInfo.M3P3ReminderAlternate == 1 then
            ScenarioInfo.M3P3ReminderAlternate = 2
            ScenarioFramework.Dialogue( OpStrings.C04_M03_115 )
        else
            ScenarioInfo.M3P3ReminderAlternate = false
            ScenarioFramework.Dialogue( ScenarioStrings.CybranGenericReminder )
        end
        ScenarioFramework.CreateTimerTrigger( M3P3Reminder, M3P3ReoccuringReminderDelay )
    end
end

----------
-- End Game
----------
function PlayerWin()
    if not ScenarioInfo.OpEnded then
        -- Turn units neutral
        ScenarioFramework.EndOperationSafety()

        -- Computer voice saying op complete
        ScenarioFramework.Dialogue( ScenarioStrings.OperationSuccessDialogue, WinGame, true )
    end
end

function WinGame()
    WaitSeconds(5)
    -- local bonus = Objectives.IsComplete( ScenarioInfo.M1B1Objective ) and Objectives.IsComplete( ScenarioInfo.M1B2Objective )
    local secondary = Objectives.IsComplete( ScenarioInfo.M2S1Objective )
    ScenarioFramework.EndOperation( 'SCCA_Coop_R04', true, ScenarioInfo.Options.Difficulty, true, secondary ) -- , bonus )
end
