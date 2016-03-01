-- ****************************************************************************
-- **
-- **  File     : /maps/X1CA_Coop_003/X1CA_Coop_003_m3princessai.lua
-- **  Author(s): Jessica St. Croix
-- **
-- **  Summary  : Princess army AI for Mission 3 - X1CA_Coop_003
-- **
-- **  Copyright © 2007 Gas Powered Games, Inc.  All rights reserved.
-- ****************************************************************************
local BaseManager = import('/lua/ai/opai/basemanager.lua')

local SPAIFileName = '/lua/ScenarioPlatoonAI.lua'

--------
-- Locals
--------
local Princess = 4
local Difficulty = ScenarioInfo.Options.Difficulty

---------------
-- Base Managers
---------------
local PrincessBase = BaseManager.CreateBaseManager()
local PrincessDefenseLine_1 = BaseManager.CreateBaseManager()
local PrincessDefenseLine_2 = BaseManager.CreateBaseManager()
local PrincessDefenseLine_3 = BaseManager.CreateBaseManager()
local PrincessDefenseLine_4 = BaseManager.CreateBaseManager()

function PrincessBaseAI()

    ---------------
    -- Princess Base
    ---------------
    PrincessBase:InitializeDifficultyTables(ArmyBrains[Princess], 'M3_Princess_Base', 'Princess_Base', 150, {M3_Princess_Base = 100})
    PrincessBase:StartNonZeroBase({8, 4})
    PrincessBase:SetMaximumConstructionEngineers(4)

    ForkThread(function()
        WaitSeconds(1)
        PrincessBase:AddBuildGroup('M3_Princess_Support_Factories', 100, true)
    end)

    PrincessBase:AddBuildGroupDifficulty('M3_Princess_Defense', 90)

    PrincessBase:AddBuildGroupDifficulty('M3_Princess_Line_1', 50)
    PrincessBase:AddBuildGroupDifficulty('M3_Princess_Line_2', 60)
    PrincessBase:AddBuildGroupDifficulty('M3_Princess_Line_3', 70)
    PrincessBase:AddBuildGroupDifficulty('M3_Princess_Line_4', 80)


    PrincessBaseAirAttacks()
end

function PrincessBaseAirAttacks()
    local opai = nil
    local quantity = {}

    -- sends 8 gunships [north]
    opai = PrincessBase:AddOpAI('AirAttacks', 'PrincessBase_AirAttacks1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackLocation'},
            PlatoonData = {
                Location = 'M3_Seraph_Mini_3_BaseMarker',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Gunships', 8)

    -- sends 8 gunships [west]
    opai = PrincessBase:AddOpAI('AirAttacks', 'PrincessBase_AirAttacks2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackLocation'},
            PlatoonData = {
                Location = 'M3_Seraph_South',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Gunships', 8)

    -- Air Defense
    quantity = {8, 6, 4}
    opai = PrincessBase:AddOpAI('AirAttacks', 'PrincessBase_AirDefense1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Princess_AirDef_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])

    quantity = {12, 8, 6}
    opai = PrincessBase:AddOpAI('AirAttacks', 'PrincessBase_AirDefense2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Princess_AirDef_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('CombatFighters', quantity[Difficulty])

    quantity = {6, 4, 3}
    opai = PrincessBase:AddOpAI('AirAttacks', 'PrincessBase_AirDefense3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Princess_AirDef_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
end
