local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'

local UEF = 3

local Difficulty = ScenarioInfo.Options.Difficulty

local M2_Firebase_AI = BaseManager.CreateBaseManager()

function M2UEFFireBaseFunction()
	M2_Firebase_AI:Initialize(ArmyBrains[UEF], 'M2_Firebase_Buildings', 'M2_UEF_Firebase_Marker', 30, {M2_Firebase_Buildings = 100})
	M2_Firebase_AI:StartNonZeroBase(8, 4)

	M2UEFFirebaseCybranLandAttacks()
	M2UEFFirebaseCybranAirAttacks()

	M2UEFFireBasePlayerLandAttacks()
	M2UEFFireBasePlayerAirAttacks()
end

function M2UEFFirebaseCybranAirAttacks()
end

function M2UEFFirebaseCybranLandAttacks()
end

function M2UEFFireBasePlayerAirAttacks()
	local opai = nil
	local quantity = nil

	quantity = {10, 12, 14}
	opai = M2_Firebase_AI:AddOpAI('AirAttacks', 'M2_UEF_Base_Air_Attack_1',
		{
			MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
			PlatoonData = {
				PatrolChains = 'M2_UEF_To_Player_Chain_1'
			},
			Priority = 85,
		}
	)
	opai:SetChildQuantity('Interceptors', quantity[Difficulty])

	quantity = {2, 4, 6}
	opai = M2_Firebase_AI:AddOpAI('AirAttacks', 'M2_UEF_Base_Air_Attack_2',
		{
			MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
			PlatoonData = {
				PatrolChains = {'M2_UEF_To_Player_Chain_1', 'M2_UEF_To_Player_Chain_1'}
			},
			Priority = 85,
		}
	)
	opai:SetChildQuantity('Bombers', quantity[Difficulty])
end

function M2UEFFireBasePlayerLandAttacks()
	local opai = nil
	local quantity = nil

	quantity = {4, 5, 6}
	opai = M2_Firebase_AI:AddOpAI('BasicLandAttack', 'M2_UEF_Base_Land_Attack_1',
		{
			MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
			PlatoonData = {
				PatrolChain = 'M2_UEF_To_Player_Chain_1'
			},
			Priority = 85,
		}
	)
	opai:SetChildQuantity('HeavyTanks', quantity[Difficulty])

	quantity = {8, 10, 12}
	opai = M2_Firebase_AI:AddOpAI('BasicLandAttack', 'M2_UEF_Base_Land_Attack_2',
		{
			MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
			PlatoonData = {
				PatrolChains = {'M2_UEF_To_Player_Chain_1', 'M2_UEF_To_Player_Chain_2'}
			},
			Priority = 85,
		}
	)
	opai:SetChildQuantity('LightTanks', quantity[Difficulty])

	opai = M2_Firebase_AI:AddOpAI('BasicLandAttack', 'M2_UEF_Base_Land_Attack_3',
		{
			MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
			PlatoonData = {
				PatrolChain = {'M2_UEF_To_Player_Chain_1', 'M2_UEF_To_Player_Chain_2'}
			},
			Priority = 85,
		}
	)
	opai:SetChildQuantity('MobileFlak', 4)

	quantity = {2, 4, 6}
	opai = M2_Firebase_AI:AddOpAI('BasicLandAttack', 'M2_UEF_Base_Land_Attack_4',
		{
			MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
			PlatoonData = {
				PatrolChain = 'M2_UEF_To_Player_Chain_1'
			},
			Priority = 85,
		}
	)
	opai:SetChildQuantity('LightArtillery', quantity[Difficulty])
end

function DisableBase()
    if(M2_Firebase_AI) then
        M2_Firebase_AI:BaseActive(false)
    end
end