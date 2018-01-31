local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'

local Cybran = 2

local Difficulty = ScenarioInfo.Options.Difficulty

local M1_Outpost_AI_Base = BaseManager.CreateBaseManager()

function M1CybranBaseFunction()
	M1_Outpost_AI_Base:Initialize(ArmyBrains[Cybran], 'M1_Outpost_Buildings', 'M1_Cybran_Outpost_Marker', 35, {M1_Outpost_Buildings = 100})
	M1_Outpost_AI_Base:StartNonZeroBase(8, 4)

	M1CybranLandAttacksBasic()
	M1CybranAirAttacksBasic()
end

function M1CybranLandAttacksBasic()
	local opai = nil
	local quantity = {}

	quantity = {3, 5, 7}
	opai = M1_Outpost_AI_Base:AddOpAI('BasicLandAttack', 'M1_Cybran_Base_Land_Attack_1',
		{
			MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
			PlatoonData = {
				PatrolChain = 'M1_Cybran_Base_Land_Attack_Chain'
			},
			Priority = 100,
		}
	)
	opai:SetChildQuantity('LightBots', quantity[Difficulty])

	quantity = {4, 6, 8}
	opai = M1_Outpost_AI_Base:AddOpAI('BasicLandAttack', 'M1_Cybran_Base_Land_Attack_2',
		{
			MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
			PlatoonData = {
				PatrolChain = 'M1_Cybran_Base_Land_Attack_Chain'
			},
			Priority = 75,
		}
	)
	opai:SetChildQuantity('HeavyBots', quantity[Difficulty])
end

function M1CybranAirAttacksBasic()
	local opai = nil
	local quantity = {}

	quantity = {2, 4, 6}
	opai = M1_Outpost_AI_Base:AddOpAI('AirAttacks', 'M1_Cybran_Base_Air_Attack_1',
		{
			MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
			PlatoonData = {
				PatrolChain = 'M1_Cybran_Base_Air_Attack_Chain'
			},
			Priority = 100,
		}
	)
	opai:SetChildQuantity('Bombers', quantity[Difficulty])

	quantity = {3, 5, 7}
	opai = M1_Outpost_AI_Base:AddOpAI('AirAttacks', 'M1_Cybran_Base_Air_Attack_2',
		{
			MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
			PlatoonData = {
				PatrolChain = 'M1_Cybran_Base_Air_Attack_Chain'
			},
			Priority = 100,
		}
	)
	opai:SetChildQuantity('Interceptors', quantity[Difficulty])
end

function DisableBase()
    if(M1_Outpost_AI_Base) then
        M1_Outpost_AI_Base:BaseActive(false)
    end
end