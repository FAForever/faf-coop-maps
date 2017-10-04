-- ****************************************************************************
-- **
-- **  File     : /maps/X1CA_Coop_002/X1CA_Coop_002_m4orderai.lua
-- **  Author(s): Jessica St. Croix
-- **
-- **  Summary  : Order army AI for Mission 4 - X1CA_Coop_002
-- **
-- **  Copyright © 2007 Gas Powered Games, Inc.  All rights reserved.
-- ****************************************************************************
local BaseManager = import('/lua/ai/opai/basemanager.lua')

local SPAIFileName = '/lua/scenarioplatoonai.lua'

--------
-- Locals
--------
local Order = 2

---------------
-- Base Managers
---------------
local OrderM4MainBase = BaseManager.CreateBaseManager()
local OrderM4NorthBase = BaseManager.CreateBaseManager()
local OrderM4CenterBase = BaseManager.CreateBaseManager()
local OrderM4SouthBase = BaseManager.CreateBaseManager()

function OrderM4MainBaseAI()

    --------------------
    -- Order M4 Main Base
    --------------------
    OrderM4MainBase:InitializeDifficultyTables(ArmyBrains[Order], 'M4_Order_Main_Base', 'Order_M4_Main_Base_Marker', 70, {M4_Order_Main_Base = 100})
    OrderM4MainBase:StartNonZeroBase({{5, 2, 2}, {4, 2, 2}})

-- OrderM4MainBase:AddReactiveAI('ExperimentalLand', 'AirRetaliation', 'OrderM4MainBase_ExperimentalLand')
-- OrderM4MainBase:AddReactiveAI('ExperimentalAir', 'AirRetaliation', 'OrderM4MainBase_ExperimentalAir')
-- OrderM4MainBase:AddReactiveAI('ExperimentalNaval', 'AirRetaliation', 'OrderM4MainBase_ExperimentalNaval')
-- OrderM4MainBase:AddReactiveAI('Nuke', 'AirRetaliation', 'OrderM4MainBase_Nuke')
-- OrderM4MainBase:AddReactiveAI('HLRA', 'AirRetaliation', 'OrderM4MainBase_HLRA')

    OrderM4MainBaseAirAttacks()
    OrderM4MainBaseLandAttacks()
end

function OrderM4MainBaseAirAttacks()
    local opai = nil

    ---------------------------------------
    -- Order M4 Main Base Op AI, Air Attacks
    ---------------------------------------

    -- sends [bombers]
    opai = OrderM4MainBase:AddOpAI('AirAttacks', 'M4_AirAttacks1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M4_Order_Air_Attack1_Chain', 'M4_Order_Air_Attack2_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Bombers', 8)

    -- sends [interceptors]
    opai = OrderM4MainBase:AddOpAI('AirAttacks', 'M4_AirAttacks2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M4_Order_Air_Attack1_Chain', 'M4_Order_Air_Attack2_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Interceptors', 8)

    -- sends [gunships, combat fighters]
    opai = OrderM4MainBase:AddOpAI('AirAttacks', 'M4_AirAttacks3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M4_Order_Air_Attack1_Chain', 'M4_Order_Air_Attack2_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'Gunships', 'CombatFighters'}, 10)

    -- Air Defense
    for i = 1, 2 do
        opai = OrderM4MainBase:AddOpAI('AirAttacks', 'M4_AirDefense' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M4_Order_Air_Defense_Chain',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('AirSuperiority', 3)
    end
end

function OrderM4MainBaseLandAttacks()
    local opai = nil

    ----------------------------------------
    -- Order M4 Main Base Op AI, Land Attacks
    ----------------------------------------

    -- sends [light artillery]
    opai = OrderM4MainBase:AddOpAI('BasicLandAttack', 'M4_LandAttack1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M4_Order_Land_Attack1_Chain', 'M4_Order_Land_Attack2_Chain'}
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('LightArtillery', 4)

    -- sends [light bots]
    opai = OrderM4MainBase:AddOpAI('BasicLandAttack', 'M4_LandAttack2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M4_Order_Land_Attack1_Chain', 'M4_Order_Land_Attack2_Chain'}
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'LightBots'}, 6)

    -- sends [light tanks]
    opai = OrderM4MainBase:AddOpAI('BasicLandAttack', 'M4_LandAttack3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M4_Order_Land_Attack1_Chain', 'M4_Order_Land_Attack2_Chain'}
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'LightTanks'}, 8)

    -- sends [heavy tanks]
    opai = OrderM4MainBase:AddOpAI('BasicLandAttack', 'M4_LandAttack4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M4_Order_Land_Attack1_Chain', 'M4_Order_Land_Attack2_Chain'}
            },
            Priority = 90,
        }
    )
    opai:SetChildQuantity({'HeavyTanks'}, 6)
    opai:SetLockingStyle('None')

    -- sends [light artillery, mobile missiles]
    opai = OrderM4MainBase:AddOpAI('BasicLandAttack', 'M4_LandAttack5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M4_Order_Land_Attack1_Chain', 'M4_Order_Land_Attack2_Chain'}
            },
            Priority = 90,
        }
    )
    opai:SetChildQuantity({'LightArtillery', 'MobileMissiles'}, 6)
    opai:SetLockingStyle('None')
end

function OrderM4NorthBaseAI()

    ---------------------
    -- Order M4 North Base
    ---------------------
    OrderM4NorthBase:Initialize(ArmyBrains[Order], 'M4_North_Base', 'Order_M4_North_Base', 40, {M4_North_Base = 100})
    OrderM4NorthBase:StartNonZeroBase()

    OrderM4NorthBaseLandAttacks()
end

function OrderM4NorthBaseLandAttacks()
    local opai = nil

    -----------------------------------------
    -- Order M4 North Base Op AI, Land Attacks
    -----------------------------------------

    -- Land Attack
    opai = OrderM4NorthBase:AddOpAI('BasicLandAttack', 'M4_LandAttack_North',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackLocation'},
            PlatoonData = {
                Location = 'QAI_M4_North_Base',
            },
            Priority = 100,
        }
    )
    opai:SetChildActive('MobileShields', false)
    opai:RemoveChildren('MobileShields')
    opai:SetChildCount(1)
    opai:SetLockingStyle('None')
end

function OrderM4CenterBaseAI()

    ----------------------
    -- Order M4 Center Base
    ----------------------
    OrderM4CenterBase:Initialize(ArmyBrains[Order], 'M4_Middle_Base', 'Order_M4_Middle_Base', 40, {M4_Middle_Base = 100})
    OrderM4CenterBase:StartNonZeroBase()

    OrderM4CenterBaseAirAttacks()
    OrderM4CenterBaseLandAttacks()
end

function OrderM4CenterBaseAirAttacks()
    local opai = nil

    -----------------------------------------
    -- Order M4 Center Base Op AI, Air Attacks
    -----------------------------------------

    -- Air Attack
    opai = OrderM4CenterBase:AddOpAI('AirAttacks', 'M4_AirAttack_Center',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackLocation'},
            PlatoonData = {
                Location = 'QAI_M4_Middle_Base',
            },
            Priority = 100,
        }
    )
    opai:SetChildCount(1)
    opai:SetLockingStyle('None')
end

function OrderM4CenterBaseLandAttacks()
    local opai = nil

    ------------------------------------------
    -- Order M4 Center Base Op AI, Land Attacks
    ------------------------------------------

    -- Land Attack
    opai = OrderM4CenterBase:AddOpAI('BasicLandAttack', 'M4_LandAttack_Center',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackLocation'},
            PlatoonData = {
                Location = 'QAI_M4_Middle_Base',
            },
            Priority = 100,
        }
    )
    opai:SetChildActive('MobileShields', false)
    opai:RemoveChildren('MobileShields')
    opai:SetChildCount(1)
    opai:SetLockingStyle('None')
end

function OrderM4SouthBaseAI()

    ---------------------
    -- Order M4 South Base
    ---------------------
    OrderM4SouthBase:Initialize(ArmyBrains[Order], 'M4_South_Base', 'Order_M4_South_Base', 40, {M4_South_Base = 100})
    OrderM4SouthBase:StartNonZeroBase()

    OrderM4SouthBaseAirAttacks()
    OrderM4SouthBaseLandAttacks()
end

function OrderM4SouthBaseAirAttacks()
    local opai = nil

    ----------------------------------------
    -- Order M4 South Base Op AI, Air Attacks
    ----------------------------------------

    -- Air Attack
    opai = OrderM4SouthBase:AddOpAI('AirAttacks', 'M4_AirAttack_South',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackLocation'},
            PlatoonData = {
                Location = 'QAI_M3_South_Base',
            },
            Priority = 100,
        }
    )
    opai:SetChildCount(1)
    opai:SetLockingStyle('None')
end

function OrderM4SouthBaseLandAttacks()
    local opai = nil

    -----------------------------------------
    -- Order M4 South Base Op AI, Land Attacks
    -----------------------------------------

    -- Land Attack
    opai = OrderM4SouthBase:AddOpAI('BasicLandAttack', 'M4_LandAttack_South',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackLocation'},
            PlatoonData = {
                Location = 'QAI_M3_South_Base',
            },
            Priority = 100,
        }
    )
    opai:SetChildActive('MobileShields', false)
    opai:RemoveChildren('MobileShields')
    opai:SetChildCount(1)
    opai:SetLockingStyle('None')
end
