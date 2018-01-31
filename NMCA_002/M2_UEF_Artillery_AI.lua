local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'

local UEF = 3

local Difficulty = ScenarioInfo.Options.Difficulty

local M2_Artillery_AI_Base = BaseManager.CreateBaseManager()

function M2UEFArtilleryBaseFunction()
	M2_Artillery_AI_Base:Initialize(ArmyBrains[UEF], 'M2_Artillery_Base', 'M2_UEF_Artillery_Marker', 50, {M2_Artillery_Base = 100})
	M2_Artillery_AI_Base:StartEmptyBase(3, 1)
end

function DisableBase()
    if(M2_Artillery_AI_Base) then
        M2_Artillery_AI_Base:BaseActive(false)
    end
end