-- ****************************************************************************
-- **
-- **  File     : /maps/X1CA_Coop_002/X1CA_Coop_002_m3qaiai.lua
-- **  Author(s): Jessica St. Croix
-- **
-- **  Summary  : QAI army AI for Mission 3 - X1CA_Coop_002
-- **
-- **  Copyright © 2007 Gas Powered Games, Inc.  All rights reserved.
-- ****************************************************************************
local BaseManager = import('/lua/ai/opai/basemanager.lua')

local SPAIFileName = '/lua/scenarioplatoonai.lua'

--------
-- Locals
--------
local QAI = 3

---------------
-- Base Managers
---------------
local QAIM3NavalBase = BaseManager.CreateBaseManager()

function QAIM3NavalBaseAI()

    -------------------
    -- QAI M3 Naval Base
    -------------------
    QAIM3NavalBase:InitializeDifficultyTables(ArmyBrains[QAI], 'M3_QAI_Naval_Base', 'M3_QAI_Naval_Base_Marker', 100, {M3_QAI_Naval_Base = 100})
    QAIM3NavalBase:StartNonZeroBase({{2,4,6}, {1, 3, 5}})
    QAIM3NavalBase:SetBuild('Defenses', false)

    QAIM3NavalBaseNavalAttacks()
end

function QAIM3NavalBaseNavalAttacks()
    local opai = nil

    ----------------------------------------
    -- QAI M3 Naval Base Op AI, Naval Attacks
    ----------------------------------------

    -- Naval Attack
    opai = QAIM3NavalBase:AddNavalAI('M3_NavalAttack1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_QAI_NavalAttack_1_Chain', 'M3_QAI_NavalAttack_2_Chain'},
            },
            MaxFrigates = 10,
            MinFrigates = 10,
            Priority = 100,
        }
    )
    opai:SetChildActive('T3', false)
    opai:SetLockingStyle('None')

    opai = QAIM3NavalBase:AddNavalAI('M3_NavalAttack2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_QAI_NavalAttack_1_Chain', 'M3_QAI_NavalAttack_2_Chain'},
            },
            MaxFrigates = 20,
            MinFrigates = 20,
            Priority = 110,
        }
    )
    opai:SetChildActive('T1', false)
    opai:SetChildActive('T3', false)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, 8, (categories.NAVAL * categories.MOBILE) - categories.TECH1, '>='})
end