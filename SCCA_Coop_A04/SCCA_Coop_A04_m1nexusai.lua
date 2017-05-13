local BaseManager = import('/lua/ai/opai/basemanager.lua')

---------
-- Locals
---------
local Nexus_Defense = 5
local Difficulty = ScenarioInfo.Options.Difficulty

----------------
-- Base Managers
----------------
local M1NexusBase = BaseManager.CreateBaseManager()

-------------
-- Nexus_Base
-------------
function NexusM1BaseAI()
    M1NexusBase:InitializeDifficultyTables(ArmyBrains[Nexus_Defense], 'Nexus_Base', 'Nexus_Base_Marker', 50, {Nexus_Base = 100})
    M1NexusBase:SetDefaultEngineerPatrolChain('Nexus_North_Patrol_Chain')
    M1NexusBase:StartNonZeroBase({2, 4, 6})
    
end

function NexusBuildArty()
    M1NexusBase:AddBuildGroupDifficulty('Nexus_Artillery', 90)
end