local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/ScenarioPlatoonAI.lua'

---------
-- Locals
---------
local Cybran = 4
local Difficulty = ScenarioInfo.Options.Difficulty

----------------
-- Base Managers
----------------
local CybranM3Base = BaseManager.CreateBaseManager()

----------------------
-- Cybran M3 Main Base
----------------------
function CybranM3BaseAI()
    CybranM3Base:InitializeDifficultyTables(ArmyBrains[Cybran], 'M3_Cybran_Base', 'M3_Cybran_Base_Marker', 100, {M3_Cybran_Base = 100})
    --CybranM3Base:StartNonZeroBase({{10, 13, 16}, {8, 10, 12}})
    --CybranM3Base:SetMaximumConstructionEngineers(4)
    
    CybranM3Base:SetActive('AirScouting', true)

    -- Spawn support factories a bit later, else they sometimes bug out and can't build higher tech units.
    ForkThread(function()
        WaitSeconds(1)
        CybranM3Base:AddBuildGroupDifficulty('M3_Cybran_Base_Support_Factories', 100, true)
    end)

    CybranM3BaseAirAttacks()
    CybranM3BaseLandAttacks()
    CybranM3BaseNavalAttacks()
end

function CybranM3BaseAirAttacks()
	local opai = nil
	local quantity = {}
	local trigger = {}
end

function CybranM3BaseLandAttacks()
	local opai = nil
	local quantity = {}
	local trigger = {}
end

function CybranM3BaseNavalAttacks()
	local opai = nil
	local quantity = {}
	local trigger = {}
end