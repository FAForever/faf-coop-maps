local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'

local Cybran = 2

local Difficulty = ScenarioInfo.Options.Difficulty

local M2_Cybran_AI_Base = BaseManager.CreateBaseManager()

function M2CybranBaseFunction()
	M2_Cybran_AI_Base:Initialize(ArmyBrains[Cybran], 'M2_Cybran_Main_Base', 'M2_Cybran_Base_Marker', 30, {M2_Cybran_Main_Base = 100})
	M2_Cybran_AI_Base:StartNonZeroBase(12, 6)

	M2CybranLandAttacks()
	M2CybranAirAttacks()

	M2BuildPatrols()
end

function M2CybranLandAttacks()
	local opai = nil
	local quantity = nil

	opai = M2_Cybran_AI_Base:AddOpAI('BasicLandAttack', 'M2_Cybran_Base_Land_Attack_1',
		{
			MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
			PlatoonData = {
				PatrolChain = 'M2_Cybran_To_UEF_Land_Chain'
			},
			Priority = 100,
		}
	)
	opai:SetChildQuantity('HeavyBots', 10)

	opai = M2_Cybran_AI_Base:AddOpAI('BasicLandAttack', 'M2_Cybran_Base_Land_Attack_2',
		{
			MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
			PlatoonData = {
				PatrolChain = 'M2_Cybran_To_UEF_Land_Chain'
			},
			Priority = 85,
		}
	)
	opai:SetChildQuantity('HeavyTanks', 6)

	opai = M2_Cybran_AI_Base:AddOpAI('BasicLandAttack', 'M2_Cybran_Base_Land_Attack_3',
		{
			MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
			PlatoonData = {
				PatrolChain = 'M2_Cybran_To_UEF_Land_Chain'
			},
			Priority = 70,
		}
	)
	opai:SetChildQuantity('MobileFlak', 4)

	opai = M2_Cybran_AI_Base:AddOpAI('BasicLandAttack', 'M2_Cybran_Base_Land_Attack_4',
		{
			MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
			PlatoonData = {
				PatrolChain = 'M2_Cybran_To_UEF_Land_Chain'
			},
			Priority = 125,
		}
	)
	opai:SetChildQuantity('LightArtillery', 8)

	opai = M2_Cybran_AI_Base:AddOpAI('BasicLandAttack', 'M2_Cybran_Base_Land_Attack_5',
		{
			MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
			PlatoonData = {
				PatrolChain = 'M2_Cybran_To_UEF_Land_Chain'
			},
			Priority = 85,
		}
	)
	opai:SetChildQuantity('AmphibiousTanks', 4)

	opai = M2_Cybran_AI_Base:AddOpAI('BasicLandAttack', 'M2_Cybran_Base_Land_Attack_6',
		{
			MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
			PlatoonData = {
				PatrolChain = 'M2_Cybran_To_UEF_Land_Chain'
			},
			Priority = 90,
		}
	)
	opai:SetChildQuantity('MobileBombs', 6)
end

function M2CybranAirAttacks()
	local opai = nil

	opai = M2_Cybran_AI_Base:AddOpAI('AirAttacks', 'M2_Cybran_Base_Air_Attack_1',
		{
			MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
			PlatoonData = {
				PatrolChain = 'M2_Cybran_To_UEF_Air_Chain'
			},
			Priority = 100,
		}
	)
	opai:SetChildQuantity('Bombers', 6)

	opai = M2_Cybran_AI_Base:AddOpAI('AirAttacks', 'M2_Cybran_Base_Air_Attack_2',
		{
			MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
			PlatoonData = {
				PatrolChain = 'M2_Cybran_To_UEF_Air_Chain'
			},
			Priority = 85,
		}
	)
	opai:SetChildQuantity('Interceptors', 12)

	opai = M2_Cybran_AI_Base:AddOpAI('AirAttacks', 'M2_Cybran_Base_Air_Attack_3',
		{
			MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
			PlatoonData = {
				PatrolChain = 'M2_Cybran_To_UEF_Air_Chain'
			},
			Priority = 90,
		}
	)
	opai:SetChildQuantity('Gunships', 6)

	opai = M2_Cybran_AI_Base:AddOpAI('AirAttacks', 'M2_Cybran_Base_Air_Attack_4',
		{
			MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
			PlatoonData = {
				PatrolChain = 'M2_Cybran_To_UEF_Air_Chain'
			},
			Priority = 95,
		}
	)
	opai:SetChildQuantity('CombatFighters', 4)
end

function M2BuildPatrols()
	local opai = nil

	opai = M2_Cybran_AI_Base:AddOpAI('BasicLandAttack', 'M2_Cybran_Base_Land_Patrol_South',
		{
			MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
			PlatoonData = {
				PatrolChain = 'M2_Cybran_Base_Southern_Patrol_Chain'
			},
			Priority = 100,
		}
	)
	opai:SetChildQuantity('HeavyTanks', 6)

	opai = M2_Cybran_AI_Base:AddOpAI('BasicLandAttack', 'M2_Cybran_Base_Land_Patrol_West',
		{
			MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
			PlatoonData = {
				PatrolChain = 'M2_Cybran_Base_Western_Patrol_Chain'
			},
			Priority = 100,
		}
	)
	opai:SetChildQuantity('HeavyTanks', 6)
end

function DisableBase()
    if(M2_Cybran_AI_Base) then
        M2_Cybran_AI_Base:BaseActive(false)
    end
end