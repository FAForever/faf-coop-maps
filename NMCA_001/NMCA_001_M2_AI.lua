local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'

local UEF = 2

local Difficulty = ScenarioInfo.Options.Difficulty

local UEFFireBase = BaseManager.CreateBaseManager()

function UEFFireBaseAI()
	UEFFireBase:Initialize(ArmyBrains[UEF], 'M2Base', 'M2_UEF_Firebase', 100, {M2Base = 100})
	UEFFireBase:StartNonZeroBase({4, 2})

	UEFFireBaseLandAttacks()
	UEFFireBaseAirAttacks()
end

function UEFFireBaseLandAttacks()
	local opai = nil
	local quantity = {}

	quantity = {8, 10, 12}
	opai = UEFFireBase:AddOpAI('BasicLandAttack', 'M2_BaseLandAttack1',
		{
			MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
			PlatoonData = {
				PatrolChain = 'M2_OutpostAttack_1'
			},
			Priority = 150,
		}
	)
	opai:SetChildQuantity('LightTanks', quantity[Difficulty])

	quantity = {6, 10, 14}
	opai = UEFFireBase:AddOpAI('BasicLandAttack', 'M2_BaseLandAttack2',
		{
			MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
			PlatoonData = {
				PatrolChains = {'M2_OutpostAttack_1',
	            				'M2_OutpostAttack_2',
	            				'M2_OutpostAttack_3'},
	        },
	        Priority = 125,
	    }
	)
	opai:SetChildQuantity('LightBots', quantity[Difficulty])

	opai = UEFFireBase:AddOpAI('BasicLandAttack', 'M2_BaseLandAttack3',
	    {
	        MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
	        PlatoonData = {
	            PatrolChains = {'M2_OutpostAttack_1',
	            				'M2_OutpostAttack_2',
	            				'M2_OutpostAttack_3'},
	        },
	        Priority = 100,
	    }
	)
	opai:SetChildQuantity('MobileAntiAir', 6)

	quantity = {10, 12, 14}
	opai = UEFFireBase:AddOpAI('BasicLandAttack', 'M2_BaseLandAttack4',
	    {
	        MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
	        PlatoonData = {
	            PatrolChain = 'M2_OutpostAttack_2'
	        },
	        Priority = 150,
	    }
	)
	opai:SetChildQuantity('LightTanks', quantity[Difficulty])
end


function UEFFireBaseAirAttacks()
	local opai = nil
	local quantity = {}

	quantity = {8, 12, 16}
	opai = UEFFireBase:AddOpAI('AirAttacks', 'M2_BaseAirAttack1',
	    {
	        MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
	        PlatoonData = {
	            PatrolChains = {'M2_OutpostAttack_1',
	            				'M2_OutpostAttack_2',
	            				'M2_OutpostAttack_3'},
	        },
	        Priority = 100,
	    }
	)
	opai:SetChildQuantity('Interceptors', quantity[Difficulty])

	quantity = {6, 8, 10}
	opai = UEFFireBase:AddOpAI('AirAttacks', 'M2_BaseAirAttack2',
	    {
	        MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
	        PlatoonData = {
	            PatrolChains = {'M2_OutpostAttack_1',
	            				'M2_OutpostAttack_2',
	            				'M2_OutpostAttack_3'},
	        },
	        Priority = 100,
	    }
	)
	opai:SetChildQuantity('Bombers', quantity[Difficulty])
end

function DisableBase()
    if(UEFFireBase) then
        UEFFireBase:BaseActive(false)
    end
end
