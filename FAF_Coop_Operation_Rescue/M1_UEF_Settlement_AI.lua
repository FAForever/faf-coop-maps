local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'

local UEF = 3

local Difficulty = ScenarioInfo.Options.Difficulty

local UEFBase = BaseManager.CreateBaseManager()

function UEFAI()
    UEFBase:Initialize(ArmyBrains[UEF], 'Tech', 'Science', 100, {Tech = 100})
    UEFBase:StartNonZeroBase(3, 0)

    EngineerFunction()
end

function EngineerFunction()
    local opai = nil

    opai = UEFBase:AddOpAI('EngineerAttack', 'UEF_Settlement_Reclaim',
    {
        MasterPlatoonFunction = {SPAIFileName, 'SplitPatrolThread'},
        PlatoonData = {
            PatrolChains = {'UEF_Reclaim_Path',
                            'UEF_Reclaim_Path_2'},
        },
        Priority = 200,
    })
    opai:SetChildQuantity('T1Engineers', 3)
end
