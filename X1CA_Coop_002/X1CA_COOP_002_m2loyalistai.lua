-- ****************************************************************************
-- **
-- **  File     : /maps/X1CA_Coop_002/X1CA_Coop_002_m2loyalistai.lua
-- **  Author(s): Jessica St. Croix
-- **
-- **  Summary  : Loyalist army AI for Mission 2 - X1CA_Coop_002
-- **
-- **  Copyright © 2007 Gas Powered Games, Inc.  All rights reserved.
-- ****************************************************************************
local BaseManager = import('/lua/ai/opai/basemanager.lua')
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')

local SPAIFileName = '/lua/ScenarioPlatoonAI.lua'
local ThisFile = '/maps/X1CA_Coop_002/X1CA_Coop_002_m2loyalistai.lua'

-- ------
-- Locals
-- ------
local Loyalist = 4

-- -------------
-- Base Managers
-- -------------
local LoyalistM2EastBase = BaseManager.CreateBaseManager()
local LoyalistM2WestBase = BaseManager.CreateBaseManager()
local LoyalistM2ExpansionBase = BaseManager.CreateBaseManager()

function LoyalistM2EastBaseAI()

    -- ---------------------
    -- Loyalist M2 East Base
    -- ---------------------
    LoyalistM2EastBase:Initialize(ArmyBrains[Loyalist], 'M2_Loyalist_Base_East', 'M2_Loyalist_Base_East_Marker', 40, {M2_Loyalist_Base_East = 100,}) -- M4_Loyalist_PrisonBase = 90
    LoyalistM2EastBase:StartNonZeroBase({3, 3})
    LoyalistM2EastBase:SetActive('AirScouting', true)
    LoyalistM2EastBase:SetActive('LandScouting', true)
	
	-- LoyalistM2ExpansionBaseAI()

    -- disable omni
    local omni = ScenarioFramework.GetCatUnitsInArea(categories.uab3104, ScenarioUtils.AreaToRect('M2_Playable_Area'), ArmyBrains[Loyalist])
    local num = table.getn(omni)
    if(num > 0) then
        for i = 1, num do
            omni[i]:DisableIntel('Omni')
        end
    end

    LoyalistM2EastBaseAirAttacks()
    LoyalistM2EastBaseLandAttacks()
end

function LoyalistM2EastBaseAirAttacks()
    local opai = nil

    -- ----------------------------------------
    -- Loyalist M2 East Base Op AI, Air Attacks
    -- ----------------------------------------

	local template = {
        'M2_AirAttacks',
        'NoPlan',
        { 'uaa0303', 1, 1, 'Attack', 'GrowthFormation' },	-- Air Superiority
        { 'uaa0203', 1, 2, 'Attack', 'GrowthFormation' },	-- Gunships
        { 'uaa0103', 1, 3, 'Attack', 'GrowthFormation' },	-- Bombers
        { 'uaa0101', 1, 1, 'Attack', 'GrowthFormation' },	-- Air Scout
    }
	local builder = {
        BuilderName = 'M2_AirAttacks',
        PlatoonTemplate = template,
		InstanceCount = 2,
        Priority = 105,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'M2_Loyalist_Base_East',
		PlatoonAIFunction = {'/maps/X1CA_Coop_002/X1CA_Coop_002_m2loyalistai.lua', 'LoyalistM2EastAirAttacksAI'},
    }
    ArmyBrains[Loyalist]:PBMAddPlatoon( builder )
	
    -- Air Attack
    -- opai = LoyalistM2EastBase:AddOpAI('AirAttacks', 'M2_AirAttacks',
        -- {
            -- MasterPlatoonFunction = {'/maps/X1CA_Coop_002/X1CA_Coop_002_m2loyalistai.lua', 'LoyalistM2EastAirAttacksAI'},
            -- Priority = 105
        -- }
    -- )
	-- opai:SetChildQuantity({'AirSuperiority', 'Gunships', 'Interceptors'}, 6)

    opai = LoyalistM2EastBase:AddOpAI('AirAttacks', 'M2_AirAttacks2',
        {
            MasterPlatoonFunction = {'/maps/X1CA_Coop_002/X1CA_Coop_002_m2loyalistai.lua', 'LoyalistM2EastAirAttacksAI'},
            Priority = 115,
        }
    )
    opai:SetChildQuantity({'Gunships', 'Bombers'}, 8)

    opai = LoyalistM2EastBase:AddOpAI('AirAttacks', 'M2_AirAttacks3',
        {
            MasterPlatoonFunction = {'/maps/X1CA_Coop_002/X1CA_Coop_002_m2loyalistai.lua', 'LoyalistM2EastAirAttacksAI'},
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'Gunships', 'CombatFighters'}, 8)
    opai:SetLockingStyle('None')
    opai:AddBuildCondition('/lua/editor/MiscBuildConditions.lua', 'MissionNumber', {'default_brain', 4})
end

function LoyalistM2EastAirAttacksAI(platoon)
    local aiBrain = platoon:GetBrain()
    local cmd = false

    -- Switches attack chains based on mission number
    while(aiBrain:PlatoonExists(platoon)) do
        if(not cmd or not platoon:IsCommandsActive(cmd)) then
            if(ScenarioInfo.MissionNumber == 2 or ScenarioInfo.MissionNumber == 3) then
                cmd = ScenarioFramework.PlatoonAttackChain(platoon, 'M2_LoyEast_Attack_Air_Chain')
            elseif(ScenarioInfo.MissionNumber == 4) then
                cmd = ScenarioFramework.PlatoonAttackChain(platoon, 'M4_Loy_East_Attack_Chain')
            end
        end
        WaitSeconds(11)
    end
end

function LoyalistM2EastBaseLandAttacks()
    local opai = nil

    -- -----------------------------------------
    -- Loyalist M2 East Base Op AI, Land Attacks
    -- -----------------------------------------

    -- Land Attack
    opai = LoyalistM2EastBase:AddOpAI('BasicLandAttack', 'M2_LandAttackEast',
        {
            MasterPlatoonFunction = {'/maps/X1CA_Coop_002/X1CA_Coop_002_m2loyalistai.lua', 'LoyalistM2EastLandAttacksAI'},
			Priority = 100,
        }
    )
    opai:SetChildActive('LightBots', false)
	opai:SetChildActive('MobileShields', false)
    opai:SetLockingStyle('BuildTimer', {LockTimer = 1})
end

function LoyalistM2EastLandAttacksAI(platoon)
    local aiBrain = platoon:GetBrain()
    local cmd = false

    -- Switches attack chains based on mission number
    while(aiBrain:PlatoonExists(platoon)) do
        if(not cmd or not platoon:IsCommandsActive(cmd)) then
            if(ScenarioInfo.MissionNumber == 2 or ScenarioInfo.MissionNumber == 3) then
                cmd = ScenarioFramework.PlatoonAttackChain(platoon, 'M2_LoyEast_Attack_' .. Random(1, 2) .. '_Chain')
            elseif(ScenarioInfo.MissionNumber == 4) then
                cmd = ScenarioFramework.PlatoonAttackChain(platoon, 'M4_Loy_East_Attack_Chain')
            end
        end
        WaitSeconds(11)
    end
end

function LoyalistM2WestBaseAI()

    -- ---------------------
    -- Loyalist M2 West Base
    -- ---------------------
    LoyalistM2WestBase:Initialize(ArmyBrains[Loyalist], 'M2_Loyalist_Base_West', 'M2_Loyalist_Base_West_Marker', 35, {M2_Loyalist_Base_West = 100})
    LoyalistM2WestBase:StartNonZeroBase({2, 2})
    LoyalistM2WestBase:SetActive('LandScouting', true)

    LoyalistM2WestBaseLandAttacks()
end

function LoyalistM2WestBaseLandAttacks()
    local opai = nil

    -- -----------------------------------------
    -- Loyalist M2 West Base Op AI, Land Attacks
    -- -----------------------------------------

    -- Land Attack
    for i = 1, 2 do
        opai = LoyalistM2WestBase:AddOpAI('BasicLandAttack', 'M2_LandAttackWest_' .. i,
            {
                MasterPlatoonFunction = {'/maps/X1CA_Coop_002/X1CA_Coop_002_m2loyalistai.lua', 'LoyalistM2WestLandAttacksAI'},
            }
        )
        opai:SetChildQuantity('HeavyTanks', 4)
    end

    opai = LoyalistM2WestBase:AddOpAI('BasicLandAttack', 'M2_LandAttackWest_bis',
        {
            MasterPlatoonFunction = {'/maps/X1CA_Coop_002/X1CA_Coop_002_m2loyalistai.lua', 'LoyalistM2WestLandAttacksAI'},
        }
    )
    opai:SetChildQuantity({'MobileFlak', 'MobileAntiAir'}, 4)

    opai = LoyalistM2WestBase:AddOpAI('BasicLandAttack', 'M4_LandAttackWest_1',
        {
            MasterPlatoonFunction = {'/maps/X1CA_Coop_002/X1CA_Coop_002_m2loyalistai.lua', 'LoyalistM2WestLandAttacksAI'},
        }
    )
    opai:SetChildQuantity({'HeavyTanks', 'LightTanks'}, 4)
    opai:SetLockingStyle('None')
    opai:AddBuildCondition('/lua/editor/MiscBuildConditions.lua', 'MissionNumber', {'default_brain', 4})
	
    opai = LoyalistM2WestBase:AddOpAI('BasicLandAttack', 'M4_LandAttackWest_2',
        {
            MasterPlatoonFunction = {'/maps/X1CA_Coop_002/X1CA_Coop_002_m2loyalistai.lua', 'LoyalistM2WestLandAttacksAI'},
        }
    )
    opai:SetChildQuantity({'MobileMissiles', 'LightArtillery'}, 4)
    opai:SetLockingStyle('None')
    opai:AddBuildCondition('/lua/editor/MiscBuildConditions.lua', 'MissionNumber', {'default_brain', 4})
end

function LoyalistM2WestLandAttacksAI(platoon)
    local aiBrain = platoon:GetBrain()
    local cmd = false

    -- Switches attack chains based on mission number
    while(aiBrain:PlatoonExists(platoon)) do
        if(not cmd or not platoon:IsCommandsActive(cmd)) then
            if(ScenarioInfo.MissionNumber == 2 or ScenarioInfo.MissionNumber == 3) then
                cmd = ScenarioFramework.PlatoonAttackChain(platoon, 'M2_LoyWest_Attack_' .. Random(1, 2) .. '_Chain')
            elseif(ScenarioInfo.MissionNumber == 4) then
                cmd = ScenarioFramework.PlatoonAttackChain(platoon, 'M4_Loy_West_Attack_Chain')
            end
        end
        WaitSeconds(11)
    end
end

function LoyalistM2ExpansionBaseAI()    
    LoyalistM2EastBase:AddBuildGroup('M4_Loyalist_PrisonBase', 90)
	
    LoyalistM2ExpansionBase:Initialize(ArmyBrains[Loyalist], 'M2_Loyalist_Base_Expansion', 'Blank Marker 13', 80, {M4_Loyalist_PrisonBase = 100,})
	LoyalistM2ExpansionBase:StartEmptyBase(8)
	LoyalistM2ExpansionBase:SetMaximumConstructionEngineers(4)
	LoyalistM2ExpansionBase:SetConstructionAlwaysAssist(true)
    LoyalistM2ExpansionBase:SetActive('AirScouting', true)
    LoyalistM2ExpansionBase:SetActive('LandScouting', true)
	
	LoyalistM2ExpansionBaseLandAttacks()
	LoyalistM2ExpansionBaseAirAttacks()
end

function LoyalistM2ExpansionBaseLandAttacks()
    local opai = nil
	
    opai = LoyalistM2ExpansionBase:AddOpAI('BasicLandAttack', 'M4_LandAttackForward1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M4_Order_Land_Attack1_Chain', 'M4_Order_Land_Attack2_Chain'}
            },
        }
    )
    opai:SetChildQuantity({'SiegeBots', 'HeavyTanks', 'LightTanks'}, 6)
    opai:SetLockingStyle('None')
	
    opai = LoyalistM2ExpansionBase:AddOpAI('BasicLandAttack', 'M4_LandAttackForward2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M4_Order_Land_Attack1_Chain', 'M4_Order_Land_Attack2_Chain'}
            },
        }
    )
    opai:SetChildQuantity({'HeavyTanks', 'MobileShields', 'MobileAntiAir'}, 6)
    opai:SetLockingStyle('None')
	
    opai = LoyalistM2ExpansionBase:AddOpAI('BasicLandAttack', 'M4_LandAttackForward3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M4_Order_Land_Attack1_Chain', 'M4_Order_Land_Attack2_Chain'}
            },
        }
    )
    opai:SetChildQuantity({'MobileFlak', 'LightBots'}, 4)
    opai:SetLockingStyle('None')
end

function LoyalistM2ExpansionBaseAirAttacks()
    local opai = nil
	
	opai = LoyalistM2ExpansionBase:AddOpAI('AirAttacks', 'M4_AirAttackForward1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M4_Order_Land_Attack1_Chain', 'M4_Order_Land_Attack2_Chain'}
            },
        }
    )
    opai:SetChildCount(1)
	opai:SetChildActive('StratBombers', false)
	opai:SetChildActive('HeavyGunships', false)
    opai:SetLockingStyle('None')
end
