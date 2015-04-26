#****************************************************************************
#**
#**  File     : /maps/X1CA_Coop_002_v03/X1CA_Coop_002_v03_m3qaiai.lua
#**  Author(s): Jessica St. Croix
#**
#**  Summary  : QAI army AI for Mission 3 - X1CA_Coop_002_v03
#**
#**  Copyright © 2007 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************
local BaseManager = import('/lua/ai/opai/basemanager.lua')

local SPAIFileName = '/lua/scenarioplatoonai.lua'

# ------
# Locals
# ------
local QAI = 3

# -------------
# Base Managers
# -------------
local QAIM3NavalBase = BaseManager.CreateBaseManager()

function QAIM3NavalBaseAI()

    # -----------------
    # QAI M3 Naval Base
    # -----------------
    QAIM3NavalBase:InitializeDifficultyTables(ArmyBrains[QAI], 'M3_QAI_Naval_Base', 'M3_QAI_Naval_Base_Marker', 60, {M3_QAI_Naval_Base = 100})
    QAIM3NavalBase:StartNonZeroBase({{2,4,6}, {1, 2, 3}})
    QAIM3NavalBase:SetBuild('Defenses', false)

    QAIM3NavalBaseNavalAttacks()
end

function QAIM3NavalBaseNavalAttacks()
    local opai = nil

    # --------------------------------------
    # QAI M3 Naval Base Op AI, Naval Attacks
    # --------------------------------------

    # Naval Attack
    opai = QAIM3NavalBase:AddOpAI('NavalFleet', 'M3_NavalFleet',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_QAI_NavalAttack_Destro_Chain'
            },
            Priority = 100,
        }
    )
    opai:SetChildCount(1)
    opai:SetChildActive('All', false)
    opai:SetChildActive('Destroyer', true)
end