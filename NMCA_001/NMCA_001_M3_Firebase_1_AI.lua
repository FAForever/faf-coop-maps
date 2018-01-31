local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'

local UEF = 2

local Difficulty = ScenarioInfo.Options.Difficulty

local UEFM3FireBase_1 = BaseManager.CreateBaseManager()

function UEFM3FireBase1()
	UEFM3FireBase_1:Initialize(ArmyBrains[UEF], 'M3Firebase_1', 'M3_Firebase_1_Marker', 100, {M3Firebase_1 = 100})
	UEFM3FireBase_1:StartNonZeroBase({3, 1})

	LandAttacks()
end

function LandAttacks()
	local opai = nil
	local quantity = {}
	local trigger = {}

	quantity = {8, 10, 12}
	opai = UEFM3FireBase_1:AddOpAI('BasicLandAttack', 'M3FirebaseAttack_1',
	    {
	        MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
	        PlatoonData = {
	            PatrolChain = 'M2_OutpostAttack_1'
	        },
	        Priority = 150,
	    }
	)
	opai:SetChildQuantity('LightTanks', quantity[Difficulty])

	quantity = {6, 8, 10}
	opai = UEFM3FireBase_1:AddOpAI('BasicLandAttack', 'M3FirebaseAttack_2',
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
	opai:SetChildQuantity('MobileArtillery', quantity[Difficulty])

	-- Couple of counter attacks
	quantity = {20, 25, 30}
	trigger = {40, 32, 24}
	opai = UEFM3FireBase_1:AddOpAI('BasicLandAttack', 'M3FirebaseAttack_3',
	    {
	        MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
	        PlatoonData = {
	            PatrolChains = {'M2_OutpostAttack_1',
	            				'M2_OutpostAttack_2',
	            				'M2_OutpostAttack_3'},
	        },
	        Priority = 150,
	    }
	)
	opai:SetChildQuantity('LightTanks', quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
    {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.LAND * categories.MOBILE, '>='})

	quantity = {20, 25, 30}
	trigger = {50, 42, 34}
	opai = UEFM3FireBase_1:AddOpAI('BasicLandAttack', 'M3FirebaseAttack_4',
	    {
	        MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
	        PlatoonData = {
	            PatrolChains = {'M2_OutpostAttack_1',
	            				'M2_OutpostAttack_2',
	            				'M2_OutpostAttack_3'},
	        },
	        Priority = 150,
	    }
	)
	opai:SetChildQuantity('LightTanks', quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
    {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.LAND * categories.MOBILE, '>='})
end

function DisableBase()
    if(UEFM3FireBase_1) then
        UEFM3FireBase_1:BaseActive(false)
    end
end
