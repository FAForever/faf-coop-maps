local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'

local UEF = 3

local Difficulty = ScenarioInfo.Options.Difficulty

local M3_UEF_Defenses = BaseManager.CreateBaseManager()

function RescueFunction()
    M3_UEF_Defenses:Initialize(ArmyBrains[UEF], 'TDefenses', 'M3_Base_Defenses', 100, {TFactory = 100, TDefenses = 90})
    M3_UEF_Defenses:StartEmptyBase(4, 1)
end

function DisableBase()
    if(M3_UEF_Defenses) then
        M3_UEF_Defenses:BaseActive(false)
    end
end