-- ****************************************************************************
-- **
-- **  File     : /maps/X1CA_Coop_002_v03/X1CA_Coop_002_v03_m4orderai.lua
-- **  Author(s): Jessica St. Croix
-- **
-- **  Summary  : Order army AI for Mission 4 - X1CA_Coop_002_v03
-- **
-- **  Copyright © 2007 Gas Powered Games, Inc.  All rights reserved.
-- ****************************************************************************
local BaseManager = import('/lua/ai/opai/basemanager.lua')

local SPAIFileName = '/lua/scenarioplatoonai.lua'

-- ------
-- Locals
-- ------
local Order = 2

-- -------------
-- Base Managers
-- -------------
local OrderM2SupportBase = BaseManager.CreateBaseManager()
local OrderM4MainBase = BaseManager.CreateBaseManager()
local OrderM4NorthBase = BaseManager.CreateBaseManager()
local OrderM4CenterBase = BaseManager.CreateBaseManager()
local OrderM4SouthBase = BaseManager.CreateBaseManager()

function OrderM4MainBaseAI()

    -- ------------------
    -- Order M4 Main Base
    -- ------------------
    OrderM4MainBase:InitializeDifficultyTables(ArmyBrains[Order], 'M4_Order_Main_Base', 'Order_M4_Main_Base_Marker', 120, {M4_Order_Main_Base = 100})
    OrderM4MainBase:StartNonZeroBase({{12, 8, 4}, {9, 6, 3}})

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

    -- -------------------------------------
    -- Order M4 Main Base Op AI, Air Attacks
    -- -------------------------------------

    -- sends [bombers]
    opai = OrderM4MainBase:AddOpAI('AirAttacks', 'M4_Order_AirAttacks1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M4_Order_Air_Attack1_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Bombers', 8)

    -- sends [interceptors]
    opai = OrderM4MainBase:AddOpAI('AirAttacks', 'M4_Order_AirAttacks2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M4_Order_Air_Attack1_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Interceptors', 8)

    -- sends [gunships, combat fighters]
    opai = OrderM4MainBase:AddOpAI('AirAttacks', 'M4_Order_AirAttacks3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M4_Order_Air_Attack2_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'Gunships', 'CombatFighters'}, 8)

    -- sends [combat fighters]
    opai = OrderM4MainBase:AddOpAI('AirAttacks', 'M4_Order_AirAttacks4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M4_Order_Air_Attack2_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('CombatFighters', 6)

    -- sends [gunships, bombers]
    opai = OrderM4MainBase:AddOpAI('AirAttacks', 'M4_Order_AirAttacks5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M4_Order_Air_Attack1_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'Gunships', 'Bombers'}, 8)




    -- Air Defense
    for i = 1, 6 do
        opai = OrderM4MainBase:AddOpAI('AirAttacks', 'M4_Order_AirDefense' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M4_Order_Air_Defense_Chain',
                },
                Priority = 110,
            }
        )
        opai:SetChildQuantity('AirSuperiority', 1)
    end
end

function OrderM4MainBaseLandAttacks()
    local opai = nil

    -- --------------------------------------
    -- Order M4 Main Base Op AI, Land Attacks
    -- --------------------------------------

    -- sends collosus
    opai = OrderM4MainBase:AddOpAI('M4_Order_Colos',
        {
            Amount = 1,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M4_Order_Land_Attack1_Chain', 'M4_Order_Land_Attack2_Chain'},
            },
            MaxAssist = 4,
            Retry = true,
        }
    )

    -- sends [light artillery]
    opai = OrderM4MainBase:AddOpAI('BasicLandAttack', 'M4_Order_LandAttack1',
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
    opai = OrderM4MainBase:AddOpAI('BasicLandAttack', 'M4_Order_LandAttack2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M4_Order_Land_Attack1_Chain', 'M4_Order_Land_Attack2_Chain'}
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('LightBots', 4)

    -- sends [light tanks]
    opai = OrderM4MainBase:AddOpAI('BasicLandAttack', 'M4_Order_LandAttack3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M4_Order_Land_Attack1_Chain', 'M4_Order_Land_Attack2_Chain'}
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('LightTanks', 6)

    -- sends [heavy tanks]
    opai = OrderM4MainBase:AddOpAI('BasicLandAttack', 'M4_Order_LandAttack4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M4_Order_Land_Attack1_Chain', 'M4_Order_Land_Attack2_Chain'}
            },
            Priority = 90,
        }
    )
    opai:SetChildQuantity('HeavyTanks', 4)
    opai:SetLockingStyle('None')

    -- sends [light artillery, mobile missiles]
    opai = OrderM4MainBase:AddOpAI('BasicLandAttack', 'M4_Order_LandAttack5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M4_Order_Land_Attack1_Chain', 'M4_Order_Land_Attack2_Chain'}
            },
            Priority = 90,
        }
    )
    opai:SetChildQuantity({'LightArtillery', 'MobileMissiles'}, 4)
    opai:SetLockingStyle('None')
end

function OrderM4NorthBaseAI()

    -- -------------------
    -- Order M4 North Base
    -- -------------------
    OrderM4NorthBase:Initialize(ArmyBrains[Order], 'M4_Order_NorthBase', 'Order_M4_North_Base', 60, {M4_Order_North_Base = 100})
    OrderM4NorthBase:StartNonZeroBase({10, 7})

    OrderM4NorthBaseLandAttacks()
end

function OrderM4NorthBaseLandAttacks()
    local opai = nil
	local units = {}
	local quantity = {}

    -- ---------------------------------------
    -- Order M4 North Base Op AI, Land Attacks
    -- ---------------------------------------

    -- Land Attacks
	for i = 1, 3 do
	units = {{'Siegebots', 'HeavyTanks', 'LightTanks'}, {'MobileMissiles', 'LightArtillery'}, {'MobileFlak', 'LightBots'}}
	quantity = {6, 8, 6}
    opai = OrderM4NorthBase:AddOpAI('BasicLandAttack', 'M4_Order_LandAttacks_North' .. i,
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackLocation'},
            PlatoonData = {
                Location = 'QAI_M4_North_Base',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity(units[i], quantity[i])
    opai:SetLockingStyle('None')
	end
end

function OrderM4CenterBaseAI()

    -- --------------------
    -- Order M4 Center Base
    -- --------------------
    OrderM4CenterBase:Initialize(ArmyBrains[Order], 'M4_Order_MiddleBase', 'Order_M4_Middle_Base', 60, {M4_Order_Middle_Base = 100})
    OrderM4CenterBase:StartNonZeroBase({15, 7})
	
    OrderM4CenterBase:AddBuildGroup('M4_Order_North_Base', 90)
	OrderM4CenterBase:AddBuildGroup('M4_Order_South_Base', 90)
	OrderM4CenterBase:SetMaximumConstructionEngineers(8)

    OrderM4CenterBaseAirAttacks()
    OrderM4CenterBaseLandAttacks()
end

function OrderM4CenterBaseAirAttacks()
    local opai = nil

    -- ---------------------------------------
    -- Order M4 Center Base Op AI, Air Attacks
    -- ---------------------------------------

    -- Air Attack
    opai = OrderM4CenterBase:AddOpAI('AirAttacks', 'M4_Order_AirAttack_Center_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackLocation'},
            PlatoonData = {
                Location = 'QAI_M4_Middle_Base',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Gunships', 4)
    opai:SetLockingStyle('None')

    opai = OrderM4CenterBase:AddOpAI('AirAttacks', 'M4_Order_AirAttack_Center_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackLocation'},
            PlatoonData = {
                Location = 'QAI_M4_Middle_Base',
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'Gunships', 'Bombers'}, 8)
end

function OrderM4CenterBaseLandAttacks()
    local opai = nil

    -- ----------------------------------------
    -- Order M4 Center Base Op AI, Land Attacks
    -- ----------------------------------------

    -- -- Land Attack
    -- opai = OrderM4CenterBase:AddOpAI('BasicLandAttack', 'M4_Order_LandAttack_Center',
        -- {
            -- MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackLocation'},
            -- PlatoonData = {
                -- Location = 'QAI_M4_Middle_Base',
            -- },
            -- Priority = 100,
        -- }
    -- )
    -- opai:SetChildrenActive({'MobileShields', 'HeavyBots'}, false)
    -- opai:RemoveChildren({'MobileShields', 'HeavyBots'})
    -- opai:SetChildCount(1)
    -- opai:SetLockingStyle('None')
	
	for i = 1, 3 do
	local units = {{'Siegebots', 'HeavyTanks', 'LightTanks'}, {'MobileMissiles', 'LightArtillery'}, {'MobileFlak', 'LightBots'}}
	local quantity = {3, 4, 4}
    opai = OrderM4CenterBase:AddOpAI('BasicLandAttack', 'M4_Order_LandAttack_Center' .. i,
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackLocation'},
            PlatoonData = {
                Location = 'QAI_M4_Middle_Base',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity(units[i], quantity[i])
    opai:SetLockingStyle('None')
	end
end

function OrderM4SouthBaseAI()

    -- -------------------
    -- Order M4 South Base
    -- -------------------
    OrderM4SouthBase:Initialize(ArmyBrains[Order], 'M4_Order_SouthBase', 'Order_M4_South_Base', 60, {M4_Order_South_Base = 100})
    OrderM4SouthBase:StartNonZeroBase({8, 4})

    OrderM4SouthBaseAirAttacks()
    OrderM4SouthBaseLandAttacks()
end

function OrderM4SouthBaseAirAttacks()
    local opai = nil

    -- --------------------------------------
    -- Order M4 South Base Op AI, Air Attacks
    -- --------------------------------------

    -- Air Attack
    opai = OrderM4SouthBase:AddOpAI('AirAttacks', 'M4_Order_AirAttack_South',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackLocation'},
            PlatoonData = {
                Location = 'QAI_M3_South_Base',
            },
            Priority = 100,
        }
    )
    opai:SetChildActive('StratBombers', false)
    opai:SetChildCount(1)
    opai:SetLockingStyle('None')
end

function OrderM4SouthBaseLandAttacks()
    local opai = nil

    -- ---------------------------------------
    -- Order M4 South Base Op AI, Land Attacks
    -- ---------------------------------------

    -- -- Land Attack
    -- opai = OrderM4SouthBase:AddOpAI('BasicLandAttack', 'M4_Order_LandAttack_South',
        -- {
            -- MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackLocation'},
            -- PlatoonData = {
                -- Location = 'QAI_M3_South_Base',
            -- },
            -- Priority = 100,
        -- }
    -- )
    -- opai:SetChildActive('HeavyBots', false)
    -- opai:RemoveChildren({'HeavyBots'})
    -- opai:SetChildCount(1)
    -- opai:SetLockingStyle('None')
	
	for i = 1, 3 do
	local units = {{'Siegebots', 'HeavyTanks', 'LightTanks'}, {'MobileMissiles', 'LightArtillery'}, {'MobileFlak', 'LightBots'}}
	local quantity = {3, 4, 4}
    opai = OrderM4SouthBase:AddOpAI('BasicLandAttack', 'M4_Order_LandAttack_South' .. i,
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackLocation'},
            PlatoonData = {
                Location = 'QAI_M3_South_Base',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity(units[i], quantity[i])
    opai:SetLockingStyle('None')
	end
end
