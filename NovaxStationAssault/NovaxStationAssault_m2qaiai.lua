local BaseManager = import('/lua/ai/opai/basemanager.lua')

---------
-- Locals
---------
local QAI = 6
local Difficulty = ScenarioInfo.Options.Difficulty

----------------
-- Base Managers
----------------
local QAIM2Base = BaseManager.CreateBaseManager()

--------------
-- QAI M2 Base
--------------
function QAIM2BaseAI()
    QAIM2Base:Initialize(ArmyBrains[QAI], 'M2_QAI_Base', 'M2_QAI_Base_Marker', 40,
        {
            M2_QAI_Shield = 600,
            M2_QAI_Power_1 = 500,
            M2_QAI_Perimetr = 400,
            M2_QAI_Power_2 = 300,
            M2_QAI_Radar = 200,
            M2_QAI_Civs = 100,
        }
    )
    QAIM2Base:StartEmptyBase(1)
end