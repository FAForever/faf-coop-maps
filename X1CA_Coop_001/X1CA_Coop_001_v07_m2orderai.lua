-- ****************************************************************************
-- **
-- **  File     : /maps/X1CA_Coop_001_v07/X1CA_Coop_001_v07_m2orderai.lua
-- **  Author(s): Jessica St. Croix
-- **
-- **  Summary  : Order army AI for Mission 2 - X1CA_Coop_001_v07
-- **
-- **  Copyright © 2007 Gas Powered Games, Inc.  All rights reserved.
-- ****************************************************************************
local BaseManager = import('/lua/ai/opai/basemanager.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')

local SPAIFileName = '/lua/scenarioplatoonai.lua'

-- ------
-- Locals
-- ------
local Order = 3
local Difficulty = ScenarioInfo.Options.Difficulty

-- -------------
-- Base Managers
-- -------------
local OrderM2MainBase = BaseManager.CreateBaseManager()
local OrderM2AirNorthBase = BaseManager.CreateBaseManager()
local OrderM2AirSouthBase = BaseManager.CreateBaseManager()
local OrderM2LandNorthBase = BaseManager.CreateBaseManager()
local OrderM2LandSouthBase = BaseManager.CreateBaseManager()

function OrderM2MainBaseAI()

    -- ------------------
    -- Order M2 Main Base
    -- ------------------
    ScenarioUtils.CreateArmyGroup('Order', 'M2_Order_WestCamp_D' .. Difficulty)
    ScenarioUtils.CreateArmyGroup('Order', 'M2_Town_Attack_Base_Eng_D' .. Difficulty)
    OrderM2MainBase:Initialize(ArmyBrains[Order], 'M2_Town_Attack_Base', 'M2_Order_NorthBase', 20, {M2_Town_Attack_Base = 100})
    OrderM2MainBase:StartNonZeroBase({{2, 4, 6}, {1, 3, 5}})
    OrderM2MainBase:SetBuild('Defenses', false)

    OrderM2MainBaseLandAttacks()
end

function OrderM2MainBaseLandAttacks()
    local opai = nil

    -- --------------------------------------
    -- Order M2 Main Base Op AI, Land Attacks
    -- --------------------------------------

    -- sends [siege bots]
    opai = OrderM2MainBase:AddOpAI('BasicLandAttack', 'M2_TownAttackBaseLandAttack1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'Order_M2_TownAttack_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('SiegeBots', 3)
    opai:SetLockingStyle('None')

    -- sends [heavy artillery]
    opai = OrderM2MainBase:AddOpAI('BasicLandAttack', 'M2_TownAttackBaseLandAttack3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'Order_M2_TownAttack_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('MobileHeavyArtillery', 3)
    opai:SetLockingStyle('None')

    -- sends [heavy tanks]
    opai = OrderM2MainBase:AddOpAI('BasicLandAttack', 'M2_TownAttackBaseLandAttack2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'Order_M2_TownAttack_Chain',
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('HeavyTanks', 3)
end

function OrderM2AirNorthBaseAI()

    -- -----------------------
    -- Order M2 Air North Base
    -- -----------------------
    ScenarioUtils.CreateArmyGroup('Order', 'M2_Order_Air_North_Eng_D' .. Difficulty)
    OrderM2AirNorthBase:Initialize(ArmyBrains[Order], 'M2_Order_Air_North', 'M2_Order_Air_North_Marker', 20, {M2_Order_Air_North = 100})
    OrderM2AirNorthBase:StartNonZeroBase({{1, 2, 4}, {1, 2, 4}})
    OrderM2AirNorthBase:SetBuild('Defenses', false)

    OrderM2AirNorthBaseAirAttacks()
end

function OrderM2AirNorthBaseAirAttacks()
    local opai = nil

    -- ------------------------------------------
    -- Order M2 Air North Base Op AI, Air Attacks
    -- ------------------------------------------

    -- sends [bombers]
    opai = OrderM2AirNorthBase:AddOpAI('AirAttacks', 'M2_AirNorthAirAttack1' ,
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'Order_M2_Town_AirPatrol_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Bombers', 2)
    opai:SetLockingStyle('None')

    -- sends [gunships]
    opai = OrderM2AirNorthBase:AddOpAI('AirAttacks', 'M2_AirNorthAirAttack2' ,
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'Order_M2_Town_AirPatrol_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Gunships', 2)
    opai:SetLockingStyle('None')

    -- Air Defense
    for i = 1, 5 do
        opai = OrderM2AirNorthBase:AddOpAI('AirAttacks', 'M2_AirNorthDefense' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'Order_M2_BaseAir_Chain',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('CombatFighters', 2)
    end
end

function OrderM2AirSouthBaseAI()

    -- -----------------------
    -- Order M2 Air South Base
    -- -----------------------
    ScenarioUtils.CreateArmyGroup('Order', 'M2_Order_Air_South_Eng_D' .. Difficulty)
    OrderM2AirSouthBase:Initialize(ArmyBrains[Order], 'M2_Order_Air_South', 'M2_Order_Air_South_Marker', 20, {M2_Order_Air_South = 100})
    OrderM2AirSouthBase:StartNonZeroBase({{1, 2, 4}, {1, 2, 4}})
    OrderM2AirSouthBase:SetBuild('Defenses', false)

    OrderM2AirSouthBaseAirAttacks()
end

function OrderM2AirSouthBaseAirAttacks()
    local opai = nil

    -- ------------------------------------------
    -- Order M2 Air South Base Op AI, Air Attacks
    -- ------------------------------------------

    -- sends [bombers]
    opai = OrderM2AirSouthBase:AddOpAI('AirAttacks', 'M2_AirSouthAirAttack1' ,
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'Order_M2_Town_AirPatrol_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Bombers', 2)
    opai:SetLockingStyle('None')

    -- sends [gunships]
    opai = OrderM2AirSouthBase:AddOpAI('AirAttacks', 'M2_AirSouthAirAttack2' ,
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'Order_M2_Town_AirPatrol_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Gunships', 2)
    opai:SetLockingStyle('None')

    -- Air Defense
    for i = 1, 5 do
        opai = OrderM2AirSouthBase:AddOpAI('AirAttacks', 'M2_AirSouthDefense' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'Order_M2_BaseAir_Chain',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('CombatFighters', 2)
    end
end

function OrderM2LandNorthBaseAI()

    -- ------------------------
    -- Order M2 Land North Base
    -- ------------------------
    ScenarioUtils.CreateArmyGroup('Order', 'M2_Order_Land_North_Eng_D' .. Difficulty)
    OrderM2LandNorthBase:Initialize(ArmyBrains[Order], 'M2_Order_Land_North', 'M2_Order_Land_North_Marker', 20, {M2_Order_Land_North = 100})
    OrderM2LandNorthBase:StartNonZeroBase({{1, 2, 4}, {1, 2, 4}})
    OrderM2LandNorthBase:SetBuild('Defenses', false)

    OrderM2LandNorthBaseLandAttacks()
end

function OrderM2LandNorthBaseLandAttacks()
    local opai = nil

    -- --------------------------------------------
    -- Order M2 Land North Base Op AI, Land Attacks
    -- --------------------------------------------

    -- sends [light tanks, heavy tanks]
    opai = OrderM2LandNorthBase:AddOpAI('BasicLandAttack', 'M2_LandNorthLandAttack1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'Order_M2_TownAttack_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'LightTanks', 'HeavyTanks'}, 2)
    opai:SetLockingStyle('None')

    -- sends [light artillery]
    opai = OrderM2LandNorthBase:AddOpAI('BasicLandAttack', 'M2_LandNorthLandAttack2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'Order_M2_TownAttack_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('LightArtillery', 2)
    opai:SetLockingStyle('None')
end

function OrderM2LandSouthBaseAI()

    -- ------------------------
    -- Order M2 Land South Base
    -- ------------------------
    ScenarioUtils.CreateArmyGroup('Order', 'M2_Order_Land_South_Eng_D' .. Difficulty)
    OrderM2LandSouthBase:Initialize(ArmyBrains[Order], 'M2_Order_Land_South', 'M2_Order_Land_South_Marker', 20, {M2_Order_Land_South = 100})
    OrderM2LandSouthBase:StartNonZeroBase({{1, 3, 5}, {1, 3, 5}})
    OrderM2LandSouthBase:SetBuild('Defenses', false)

    OrderM2LandSouthBaseLandAttacks()
end

function OrderM2LandSouthBaseLandAttacks()
    local opai = nil

    -- --------------------------------------------
    -- Order M2 Land South Base Op AI, Land Attacks
    -- --------------------------------------------

    -- sends [mobile missiles, light artillery]
    opai = OrderM2LandSouthBase:AddOpAI('BasicLandAttack', 'M2_LandSouthLandAttack1',
        {
            PlatoonData = {
                PatrolChain = 'Order_M2_TownAttack_Chain',
            },
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
        }
    )
    opai:SetChildQuantity({'MobileMissiles', 'LightArtillery'}, 2)
    opai:SetLockingStyle('None')

    -- sends [light bots]
    opai = OrderM2LandSouthBase:AddOpAI('BasicLandAttack', 'M2_LandSouthLandAttack2',
        {
            PlatoonData = {
                PatrolChain = 'Order_M2_TownAttack_Chain',
            },
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
        }
    )
    opai:SetChildQuantity('LightBots', 2)
    opai:SetLockingStyle('None')
end
