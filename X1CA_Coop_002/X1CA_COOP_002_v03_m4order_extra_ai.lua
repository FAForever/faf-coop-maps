-- ****************************************************************************
-- **
-- **  File     : /maps/X1CA_Coop_002_v03/X1CA_Coop_002_v03_m4order_extra_ai.lua
-- **  Author(s): Greg Van Houdt
-- **
-- **  Summary  : Order extra army AI for Mission 4 - X1CA_Coop_002_v03
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


function OrderM2SupportBaseAI()

    -- ---------------------
    -- Order M2 Support Base
    -- ---------------------
    OrderM2SupportBase:InitializeDifficultyTables(ArmyBrains[Order], 'M2_Order_Support_Base', 'M2_QAI_Base_Marker', 50, {M2_South_Base = 100})
    OrderM2SupportBase:StartEmptyBase({{15, 15, 15}, {12, 12, 12}})

    OrderM2SupportBaseAirAttacks()
    OrderM2SupportBaseLandAttacks()

end

function OrderM2SupportBaseAirAttacks()
    local opai = nil

    -- ----------------------------------------
    -- Order M2 Support Base Op AI, Air Attacks
    -- ----------------------------------------

    -- sends [bombers]
    opai = OrderM2SupportBase:AddOpAI('AirAttacks', 'M2_Support_AirAttacks1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M4_Order_Air_Attack1_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Bombers', 12)

    -- sends [interceptors]
    opai = OrderM2SupportBase:AddOpAI('AirAttacks', 'M2_Support_AirAttacks2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M4_Order_Air_Attack2_Chain'
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Interceptors', 12)

    -- sends [gunships & combat fighters]
    opai = OrderM2SupportBase:AddOpAI('AirAttacks', 'M2_Support_AirAttacks3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M4_Order_Air_Attack2_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'Gunships', 'CombatFighters'}, 8)
end

function OrderM2SupportBaseLandAttacks()
    local opai = nil

    -- -----------------------------------------
    -- Order M3 Support Base Op AI, Land Attacks
    -- -----------------------------------------

    -- sends [light artillery]
-- for i = 1, 3 do
--   opai = OrderM2SupportBase:AddOpAI('BasicLandAttack', 'M2_Support_LandAttack1' .. i,
--       {
--           MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
--           PlatoonData = {
--               PatrolChains = {'M4_Order_Land_Attack1_Chain', 'M4_Order_Land_Attack2_Chain'}
--           },
--           Priority = 100,
--       }
--   )
--   opai:SetChildQuantity('LightArtillery', 12)
-- end

    -- sends [heavy tanks]
-- for i = 1, 3 do
--   opai = OrderM2SupportBase:AddOpAI('BasicLandAttack', 'M2_Support_LandAttack2' .. i,
--       {
--           MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
--           PlatoonData = {
--               PatrolChains = {'M4_Order_Land_Attack1_Chain', 'M4_Order_Land_Attack2_Chain'}
--           },
--           Priority = 100,
--       }
--   )
--   opai:SetChildQuantity('HeavyTanks', 12)
-- end

    -- sends [siege bots]
-- for i = 1, 4 do
--   opai = OrderM2SupportBase:AddOpAI('BasicLandAttack', 'M2_Support_LandAttack3' .. i,
--       {
--           MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
--           PlatoonData = {
--               PatrolChains = {'M4_Order_Land_Attack1_Chain', 'M4_Order_Land_Attack2_Chain'}
--           },
--           Priority = 100,
--       }
--   )
--   opai:SetChildQuantity('SiegeBots', 8)
-- end

    -- sends [random]
    opai = OrderM2SupportBase:AddOpAI('BasicLandAttack', 'M2_Support_LandAttack4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M4_Order_Land_Attack1_Chain', 'M4_Order_Land_Attack2_Chain'}
            },
            Priority = 100,
        }
    )
    opai:SetChildActive('HeavyBots', false)
    opai:SetChildActive('MobileShields', false)
    opai:SetChildCount(1)
    opai:SetLockingStyle('None')
end
