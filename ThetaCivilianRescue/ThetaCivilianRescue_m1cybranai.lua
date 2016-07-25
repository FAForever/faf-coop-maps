local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local TCRUtil = import('/maps/ThetaCivilianRescue/ThetaCivilianRescue_CustomFunctions.lua')


---------
-- Locals
---------
local Cybran = 2
local Difficulty = ScenarioInfo.Options.Difficulty


----------------
-- Base Managers
----------------
local CybranM1WestBase = BaseManager.CreateBaseManager()

-------
-- Misc
-------
local MMLPlatoon

----------------------
-- Cybran M1 West Base
----------------------
function CybranM1WestBaseAI()
    CybranM1WestBase:InitializeDifficultyTables(ArmyBrains[Cybran], 'M1_Cybran_West_Base', 'M1_Cybran_West_Base_Marker', 80, {M1_Cybran_West_Base = 100})
	local extraEngies = ScenarioInfo.NumberOfPlayers * Difficulty
    CybranM1WestBase:StartNonZeroBase({{8 + extraEngies, 12 + extraEngies, 16 + extraEngies}, {2 + extraEngies, 4 + extraEngies, 6 + extraEngies}})
	
	
    ForkThread(function()
        WaitSeconds(1)
        CybranM1WestBase:AddBuildGroupDifficulty('M1_Cybran_West_Base_Support_Factories', 100, true)
    end)
	
    ForkThread(function()
        WaitSeconds(1)
		for i = 1,ScenarioInfo.NumberOfPlayers do
			CybranM1WestBase:AddBuildGroupDifficulty('M1_Cybran_West_Base_Engineers_C' .. i, 100, true)
		end
    end)
	
	
    ForkThread(function()
        WaitSeconds(1)
        CybranM1WestBase:AddBuildGroupDifficulty('M1_Cybran_West_Base_Defenses', 90, false)
    end)
	
	
    ForkThread(function()
        WaitSeconds(1)
		if ScenarioInfo.NumberOfPlayers >= 3 then
			CybranM1WestBase:AddBuildGroupDifficulty('M1_Forward_Defenses', 100, true)
		end
    end)
	
	
    --CybranM1WestBase:SetActive('LandScouting', true)
    CybranM1WestBase:SetActive('AirScouting', true)
	
	CybranM1WestBaseDefensePatrols()
	CybranM1WestBaseForwardPatrols()
	CybranM1WestBaseLandAttacks() --needed to prevent wrong priorities caused by different patrol make
	CybranM1WestBaseAirAttacks()
end

function CybranM1WestBaseDefensePatrols()
	local platoon
	
	-- Patroling interceptors
	platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M1_Cybran_Air_Patrol_D' .. Difficulty, 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M1_Cybran_Air_Patrol_Chain')
	
	-- Patroling landforces
	platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M1_Cybran_Land_Patrol_D' .. Difficulty, 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M1_Cybran_Land_Patrol_Chain')

	
	MMLPlatoon = ScenarioUtils.CreateArmyGroup('Cybran', 'M1_Cybran_Land_MML_D' .. Difficulty, false)
	TCRUtil.CreateAreaTrigger(MMLAttackACU, 'M1_Cybran_Base_Area' , categories.COMMAND, true, false, 1)
	
end

function MMLAttackACU()
	units = TCRUtil.GetAllCatUnitsInArea(categories.COMMAND, 'M1_Cybran_Base_Area')
	for _,unit in units do
		IssueAttack( MMLPlatoon, unit)
		break
	end
	
end

function CybranM1WestBaseForwardPatrols()
	local platoon
	
	if ScenarioInfo.NumberOfPlayers >= 3 then
	-- Patroling interceptors
		if Difficulty >= 1 then 
			platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'Hunter_S1', 'GrowthFormation')
			ScenarioFramework.PlatoonPatrolChain(platoon, 'M1_Forward_S1_Patrol_Chain')
			
			platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'Mixed_S2', 'GrowthFormation')
			ScenarioFramework.PlatoonPatrolChain(platoon, 'M1_Forward_S2_Patrol_Chain')
		end
		if Difficulty >= 2 then 
			ForkThread(function()
				WaitSeconds(30) -- 30seconds
				platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'Medusa_S3', 'GrowthFormation')
				ScenarioFramework.PlatoonAttackChain(platoon, 'M1_Forward_S3_Attack_Chain')
			
			end)
			
			platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'Mixed_S4', 'GrowthFormation')
			ScenarioFramework.PlatoonPatrolChain(platoon, 'M1_Forward_S4_Patrol_Chain')
		end
		if Difficulty >= 3 then 
			
			ForkThread(function()
				WaitSeconds(600) -- 10min0sec
				-- Dialog?
				platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'Delayed_Assault_S6', 'GrowthFormation')
				ScenarioFramework.PlatoonAttackChain(platoon, 'M1_Forward_S6_Attack_Chain')
			
			end)
		end
	end
end

function CybranM1WestBaseLandAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}
	
	-- LightBots patrol until X amount of landforces (2 times)
	quantity = {6, 8, 10}
    trigger = {30, 25, 20}
	for i = 1,2 do
		opai = CybranM1WestBase:AddOpAI('BasicLandAttack', 'M1_WestLandAttack1_' .. i,
			{
				MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
				PlatoonData = {
					PatrolChains = {'M1_Cybran_Land_Attack_Chain_1', 'M1_Cybran_Land_Attack_Chain_2','M1_Cybran_Land_Attack_Chain_3', 'M1_Cybran_Land_Attack_Chain_4'},
				},
				Priority = 110,
			}
		)
		opai:SetChildQuantity({'LightBots'}, quantity[Difficulty])
		opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainLessThanOrEqualNumCategory',
			{'default_brain', 'Player', trigger[Difficulty], categories.LAND * categories.MOBILE - categories.ENGINEER})
			
	end
	
	-- LightArtillery patrol the entire time (2 times)
	quantity = {6, 8, 10}
	local quantityMantis = {1,2,3}
		local Temp = {
			'M1_LandAttackTemp1',
			'NoPlan',
			{ 'url0103', 1, quantity[Difficulty] - quantityMantis[Difficulty], 'Attack', 'AttackFormation' },   # Medusa
			{ 'url0107', 1, quantityMantis[Difficulty], 'Attack', 'AttackFormation' },   # Mantis
			{ 'url0101', 1, 1, 'Attack', 'AttackFormation' },   # Mole
		}
		local Builder = {
			BuilderName = 'M1_LandAttackBuilder1',
			PlatoonTemplate = Temp,
			InstanceCount = 2,
			Priority = 100,
			PlatoonType = 'Land',
			RequiresConstruction = true,
			LocationType = 'M1_Cybran_West_Base',
			PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
			PlatoonData = {
					PatrolChains = {'M1_Cybran_Land_Attack_Chain_1', 'M1_Cybran_Land_Attack_Chain_2','M1_Cybran_Land_Attack_Chain_3','M1_Cybran_Land_Attack_Chain_4'},
			},
		}
	   ArmyBrains[Cybran]:PBMAddPlatoon( Builder )
	
	
	--[[quantity = {6, 8, 10}
	for i = 1,2 do
		opai = CybranM1WestBase:AddOpAI('BasicLandAttack', 'M1_WestLandAttack2_' .. i,
			{
				MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
				PlatoonData = {
					PatrolChains = {'M1_Cybran_Land_Attack_Chain_1', 'M1_Cybran_Land_Attack_Chain_2','M1_Cybran_Land_Attack_Chain_3', 'M1_Cybran_Land_Attack_Chain_4'},
				},
				Priority = 100,
			}
		)
		opai:SetChildQuantity({'LightArtillery','HeavyBots'}, quantity[Difficulty])
	end]]--
	
	
	-- HeavyBots(Mantis) patrol the entire time (or after you have some units on easier difficulties)
	quantity = {6, 8, 10}
	local quantityMedusa = {1,2,3}
    trigger = {10, 5, 0}
	local Temp = {
		'M1_LandAttackTemp2',
		'NoPlan',
		{ 'url0107', 1, quantity[Difficulty] - quantityMedusa[Difficulty], 'Attack', 'AttackFormation' },   # Mantis
		{ 'url0103', 1, quantityMedusa[Difficulty], 'Attack', 'AttackFormation' },   # Medusa
		{ 'url0101', 1, 1, 'Attack', 'AttackFormation' },   # Mole
	}
	local Builder = {
		BuilderName = 'M1_LandAttackBuilder2',
		PlatoonTemplate = Temp,
		InstanceCount = 1,
		Priority = 100,
		PlatoonType = 'Land',
		RequiresConstruction = true,
		LocationType = 'M1_Cybran_West_Base',
		BuildConditions = {
			{ '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
			{'default_brain', 'Player', trigger[Difficulty], categories.LAND * categories.MOBILE - categories.ENGINEER}},
		},
		PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
		PlatoonData = {
				PatrolChains = {'M1_Cybran_Land_Attack_Chain_1', 'M1_Cybran_Land_Attack_Chain_2','M1_Cybran_Land_Attack_Chain_3','M1_Cybran_Land_Attack_Chain_4'},
		},
	}
   ArmyBrains[Cybran]:PBMAddPlatoon( Builder )
	
	--[[quantity = {6, 8, 10}
    trigger = {10, 5, 0}
	opai = CybranM1WestBase:AddOpAI('BasicLandAttack', 'M1_WestLandAttack3',
		{
			MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
			PlatoonData = {
				PatrolChains = {'M1_Cybran_Land_Attack_Chain_1', 'M1_Cybran_Land_Attack_Chain_2','M1_Cybran_Land_Attack_Chain_3', 'M1_Cybran_Land_Attack_Chain_4'},
			},
			Priority = 100,
		}
	)
	opai:SetChildQuantity({'HeavyBots'}, quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.LAND * categories.MOBILE - categories.ENGINEER})]]--
	
	--Small HeavyTanks patrol starting from X amount of units.
	quantity = {2, 3, 4}
    trigger = {20, 15, 10}
    opai = CybranM1WestBase:AddOpAI('BasicLandAttack', 'M1_WestLandAttack4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Cybran_Land_Attack_Chain_1', 'M1_Cybran_Land_Attack_Chain_2','M1_Cybran_Land_Attack_Chain_3', 'M1_Cybran_Land_Attack_Chain_4'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity({'HeavyTanks'}, quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.LAND * categories.MOBILE - categories.ENGINEER})
	
	--Big HeavyTanks patrol starting from X amount of units.
	quantity = {6, 8, 10}
    trigger = {10, 5, 2}
    opai = CybranM1WestBase:AddOpAI('BasicLandAttack', 'M1_WestLandAttack5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Cybran_Land_Attack_Chain_1', 'M1_Cybran_Land_Attack_Chain_2','M1_Cybran_Land_Attack_Chain_3', 'M1_Cybran_Land_Attack_Chain_4'},
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity({'HeavyTanks'}, quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.TECH2 * categories.LAND * categories.MOBILE - categories.ENGINEER - categories.COMMAND})
		
	if Difficulty >= 3 then
		quantity = {4, 8, 12,16}
		trigger = {20, 15, 10, 6}
		opai = CybranM1WestBase:AddOpAI('BasicLandAttack', 'M1_WestLandAttack6',
			{
				MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
				PlatoonData = {
					PatrolChains = {'M1_Cybran_Land_Attack_Chain_1', 'M1_Cybran_Land_Attack_Chain_2','M1_Cybran_Land_Attack_Chain_3'},
				},
				Priority = 130,
			}
		)
		opai:SetChildQuantity({'MobileMissiles'}, quantity[ScenarioInfo.NumberOfPlayers])
		opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
			{'default_brain', 'Player', trigger[Difficulty], categories.FACTORY + categories.MASSEXTRACTION + categories.ENERGYPRODUCTION})
	end
end

function CybranM1WestBaseAirAttacks()
   local opai = nil
    local quantity = {}
    local trigger = {}


   quantity = {4, 6, 8}
   trigger = {30, 25, 20}
   opai = CybranM1WestBase:AddOpAI('AirAttacks', 'M1_WestAirAttack1',
       {
           MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
           PlatoonData = {
               PatrolChain = 'M1_Cybran_Land_Attack_Chain_1'
           },
           Priority = 100,
       }
   )
   opai:SetChildQuantity({'Bombers'}, quantity[Difficulty])
   opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.ALLUNITS - categories.WALL})
   
   
   quantity = {6, 8, 10}
   trigger = {10, 8, 6}
   opai = CybranM1WestBase:AddOpAI('AirAttacks', 'M1_WestAirAttack2',
       {
           MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
           PlatoonData = {
               PatrolChain = 'M1_Cybran_Land_Attack_Chain_1'
           },
           Priority = 100,
       }
   )
   opai:SetChildQuantity({'Interceptors'}, quantity[Difficulty])
   opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.AIR})
end


