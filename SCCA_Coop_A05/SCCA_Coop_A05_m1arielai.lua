local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'

---------
-- Locals
---------
local Ariel = 2
local Difficulty = ScenarioInfo.Options.Difficulty

----------------
-- Base Managers
----------------
local ArielM1AirBase = BaseManager.CreateBaseManager()

--------------------
-- Ariel M1 Air Base
--------------------
function ArielM1AirBaseAI()
    ArielM1AirBase:InitializeDifficultyTables(ArmyBrains[Ariel], 'M1_Air_Base', 'Ariel_M1_Air_Base_Marker', 50, {M1_Air_Base = 100})
    ArielM1AirBase:StartNonZeroBase({{2, 4, 6}, {2, 3, 4}})
    ArielM1AirBase:SetActive('AirScouting', true)

    ArielM1AirBaseAttacks()
end

function ArielM1AirBaseAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    quantity = {12, 16, 20}
    opai = ArielM1AirBase:AddOpAI('AirAttacks', 'M1_AirAttack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Ariel_M1_Air_Attack_Chain_1',
                                'Ariel_M1_Air_Attack_Chain_2'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'Gunships', 'Interceptors'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumber', {'default_brain', 1})
    opai:SetLockingStyle('DeathTimer', {LockTimer = 120})

    quantity = {12, 16, 20}
    opai = ArielM1AirBase:AddOpAI('AirAttacks', 'M1_AirAttack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Ariel_M1_Air_Attack_Chain_1',
                                'Ariel_M1_Air_Attack_Chain_2'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'Gunships', 'Bombers'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumber', {'default_brain', 1})
    opai:SetLockingStyle('DeathTimer', {LockTimer = 120})

    quantity = {6, 8, 10}
    opai = ArielM1AirBase:AddOpAI('AirAttacks', 'M1_AirAttack_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Ariel_M1_Air_Attack_Chain_1',
                                'Ariel_M1_Air_Attack_Chain_2'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumber', {'default_brain', 1})
end