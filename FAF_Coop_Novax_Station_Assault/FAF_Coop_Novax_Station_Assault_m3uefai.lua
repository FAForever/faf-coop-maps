local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/ScenarioPlatoonAI.lua'

---------
-- Locals
---------
local UEF = 2
local Difficulty = ScenarioInfo.Options.Difficulty

----------------
-- Base Managers
----------------
local UEFM3Base = BaseManager.CreateBaseManager()

-------------------
-- UEF M3 Main Base
-------------------
function UEFM3BaseAI()
    UEFM3Base:InitializeDifficultyTables(ArmyBrains[UEF], 'M3_UEF_Base', 'M3_UEF_Base_Marker', 200, {M3_UEF_Base = 100})
    UEFM3Base:StartNonZeroBase({{18, 23, 28}, {15, 19, 23}})
    UEFM3Base:SetMaximumConstructionEngineers(5)
    
    UEFM3Base:SetActive('AirScouting', true)

    -- Spawn support factories a bit later, else they sometimes bug out and can't build higher tech units.
    ForkThread(function()
        WaitSeconds(1)
        UEFM3Base:AddBuildGroupDifficulty('M3_UEF_Base_Support_Factories', 100, true)
    end)

    UEFM3BaseAirAttacks()
    UEFM3BaseLandAttacks()
    UEFM3BaseNavalAttacks()
end

function UEFM3BaseAirAttacks()
	local opai = nil
	local quantity = {}
	local trigger = {}
end

function UEFM3BaseLandAttacks()
	local opai = nil
	local quantity = {}
	local trigger = {}
end

function UEFM3BaseNavalAttacks()
	local opai = nil
	local quantity = {}
	local trigger = {}
end