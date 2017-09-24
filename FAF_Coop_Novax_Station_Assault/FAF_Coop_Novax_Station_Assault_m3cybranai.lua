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
    CybranM3Base:InitializeDifficultyTables(ArmyBrains[Cybran], 'M3_Cybran_Main_Base', 'M3_Cybran_Base_Marker', 180, {M3_Cybran_Main_Base = 100})
    CybranM3Base:StartNonZeroBase({{9, 12, 15}, {7, 9, 11}})
    CybranM3Base:SetSupportACUCount(1)
    CybranM3Base:SetSACUUpgrades({'ResourceAllocation', 'Switchback', 'SelfRepairSystem'}, true)
    CybranM3Base:SetMaximumConstructionEngineers(4)
    
    CybranM3Base:SetActive('AirScouting', true)

    -- Spawn support factories a bit later, else they sometimes bug out and can't build higher tech units.
    ForkThread(function()
        WaitSeconds(1)
        CybranM3Base:AddBuildGroupDifficulty('M3_Cybran_Main_Base_Support_Factories', 100, true)
    end)

    CybranM3BaseAirAttacks()
    CybranM3BaseLandAttacks()
    CybranM3BaseNavalAttacks()
end

function CybranM3BaseAirAttacks()
	local opai = nil
	local quantity = {}
	local trigger = {}

    -- M3_Cybran_Base_AirPatrol_Chain
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

    quantity = {50, 75, 100}
    opai = CybranM3Base:AddNavalAI('M3_Cybran_Naval_Attack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M2_Cybran_Base_NavalAttack_Chain_1',
                    'M2_Cybran_Base_NavalAttack_Chain_2',
                },
            },
            EnabledTypes = {'Battleship'},
            MaxFrigates = quantity[Difficulty],
            MinFrigates = quantity[Difficulty],
            Priority = 150,
        }
    )
    opai:SetChildActive('T1', false)
    opai:SetChildActive('T2', false)
end

-- M3_Cybran_Base_Sonar_Chain