local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/ScenarioPlatoonAI.lua'

---------
-- Locals
---------
local Loyalist = 2
local Difficulty = ScenarioInfo.Options.Difficulty

----------------
-- Base Managers
----------------
local LoyalistM3MainBase = BaseManager.CreateBaseManager()

------------------------
-- Loyalist M3 Main Base
------------------------
function LoyalistM3MainBaseAI()
    LoyalistM3MainBase:Initialize(ArmyBrains[Loyalist], 'M3_Loyalist_Base', 'M3_Loyalist_Base_Marker', 50, {M3_Loyalist_Base = 100})
    LoyalistM3MainBase:StartNonZeroBase({{8, 7, 6}, {7, 6, 5}})
end