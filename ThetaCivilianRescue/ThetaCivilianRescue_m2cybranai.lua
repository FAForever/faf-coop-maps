local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local Objectives = import('/lua/ScenarioFramework.lua').Objectives
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local Utilities = import('/lua/Utilities.lua')
local TCRUtil = import('/maps/ThetaCivilianRescue/ThetaCivilianRescue_CustomFunctions.lua')
local ThisFile = '/maps/ThetaCivilianRescue/ThetaCivilianRescue_m2cybranai.lua'

---------
-- Locals
---------
local Cybran = 2
local Difficulty = ScenarioInfo.Options.Difficulty

local numberOfAirLimit = {70,60,50}
local spawnMonkeylords = 0
local spawnMegaliths = 0
local spawnCorsairs = 0
local singleMega = false
local timeBeforeFocus = 5

----------------
-- Base Managers
----------------
local CybranM2EastBase = BaseManager.CreateBaseManager()


----------------------
-- Cybran M2 East Base
----------------------
function CybranM2EastBaseAI()
    CybranM2EastBase:InitializeDifficultyTables(ArmyBrains[Cybran], 'M2_Cybran_East_Base', 'M2_Cybran_East_Base_Marker', 80, {M2_Cybran_East_Base = 100})
	local extraEngies = math.max(0 , ScenarioInfo.NumberOfPlayers * (Difficulty-1))
    CybranM2EastBase:StartNonZeroBase({{7 + extraEngies, 14 + extraEngies, 22 + extraEngies}, {3 + extraEngies, 5 + extraEngies, 8 + extraEngies}})
	
    ForkThread(function()
		for i = 1,ScenarioInfo.NumberOfPlayers do
			CybranM2EastBase:AddBuildGroupDifficulty('M2_Cybran_East_Base_Engineers_C' .. i, 100, true)
		end
    end)
	
    ForkThread(function()
        WaitSeconds(1)
        CybranM2EastBase:AddBuildGroupDifficulty('M2_Cybran_East_Base_Support_Factories', 100, true)
    end)
	
	
	
    ForkThread(function()
        WaitSeconds(1)
        CybranM2EastBase:AddBuildGroupDifficulty('M2_Cybran_East_Base_Defenses', 90, true)
    end)
	
	
    ForkThread(function()
        WaitSeconds(1)
		if ScenarioInfo.NumberOfPlayers >= 3 then
			CybranM2EastBase:AddBuildGroupDifficulty('M2_Forward_Defenses', 100, true)
		end
    end)
	
	
	CybranM2EastBaseDefensePatrols()
	CybranM2EastBaseLandAttacks()
	CybranM2EastBaseAirAttacks()
	CybranM2EastBaseUnitDrops()
	
	
	ScenarioFramework.CreateAreaTrigger( ExtraAADefense, 'M2_Area', categories.AIR, true, false, ArmyBrains[ScenarioInfo.Player], numberOfAirLimit[Difficulty], true)
end

function CybranM2EastBaseDefensePatrols()
	local platoon
	
	-- Patroling interceptors
	platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2_Cybran_Air_Patrol_D' .. Difficulty, 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M2_Cybran_Air_Patrol_Chain')
	
	-- Patroling landforces
	platoon = ScenarioUtils.CreateArmyGroupAsPlatoon('Cybran', 'M2_Cybran_Land_Patrol_D' .. Difficulty, 'GrowthFormation')
    ScenarioFramework.PlatoonPatrolChain(platoon, 'M2_Cybran_Land_Patrol_Chain')

end


function CybranM2EastBaseLandAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}
	
	
	-- Rhino patrol (2 times)
	quantity = {6, 10, 14}
	for i = 1,2 do
		opai = CybranM2EastBase:AddOpAI('BasicLandAttack', 'M2_EastLandAttack3_' .. i,
			{
				MasterPlatoonFunction = {ThisFile, 'M2WestBaseLandPlatoonAI'},
				Priority = 120,
			}
		)
		opai:SetChildQuantity({'HeavyTanks'}, quantity[Difficulty])
	end
	
	-- light artillery patrol 
	quantity = {15, 20, 25}
	opai = CybranM2EastBase:AddOpAI('BasicLandAttack', 'M2_EastLandAttack4',
		{
			MasterPlatoonFunction = {ThisFile, 'M2WestBaseLandPlatoonAI'},
			Priority = 110,
		}
	)
	opai:SetChildQuantity({'LightArtillery'}, quantity[Difficulty])
	
	if (Difficulty > 1) then
		-- Loyalists patrol
		quantity = {0, 2, 4}
		for i = 1,3 do
			opai = CybranM2EastBase:AddOpAI('BasicLandAttack', 'M2_EastLandAttack1_' .. i,
				{
					MasterPlatoonFunction = {ThisFile, 'M2WestBaseLandPlatoonAI'},
					Priority = 100,
				}
			)
			opai:SetChildQuantity({'SiegeBots'}, quantity[Difficulty])
		end
			
		-- heavy artillery patrol.
		quantity = {0, 1, 2}
		trigger = {0,150,100}
		local Temp = {
		   'LandAttackTemp1',
		   'NoPlan',
		   { 'url0304', 1, quantity[Difficulty], 'Attack', 'AttackFormation' },   # MobileHeavyArtillery
		   { 'url0306', 1, 1, 'Attack', 'AttackFormation' },   # MobileStealth
	   }
		local Builder = {
		   BuilderName = 'LandAttackBuilder1',
		   PlatoonTemplate = Temp,
		   InstanceCount = 1,
		   Priority = 120,
		   PlatoonType = 'Land',
		   RequiresConstruction = true,
		   LocationType = 'M2_Cybran_East_Base',
		   BuildConditions = {
			   { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
		   {'default_brain', 'Player', trigger[Difficulty], categories.LAND * categories.MOBILE}},
		   },
		   PlatoonAIFunction = {ThisFile, 'M2WestBaseLandPlatoonAI'},
	   }
	   ArmyBrains[Cybran]:PBMAddPlatoon( Builder )
		
	end

end


function CybranM2EastBaseAirAttacks()
   local opai = nil
   local quantity = {}
   local trigger = {}


   quantity = {4, 6, 8}
   trigger = {30, 25, 20}
   opai = CybranM2EastBase:AddOpAI('AirAttacks', 'M2_EastAirAttack1',
       {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Cybran_Air_Attack_Chain_1', 'M2_Cybran_Air_Attack_Chain_2','M2_Cybran_Air_Attack_Chain_3'},
            },
           Priority = 100,
       }
   )
   opai:SetChildQuantity({'Gunships'}, quantity[Difficulty])
   

   quantity = {4,6,8}   
   opai = CybranM2EastBase:AddOpAI('AirAttacks', 'M2_EastAirAttack2',
       {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Cybran_Air_Attack_Chain_1', 'M2_Cybran_Air_Attack_Chain_2','M2_Cybran_Air_Attack_Chain_3'},
            },
           Priority = 100,
       }
   )
   opai:SetChildQuantity({'CombatFighters'}, quantity[Difficulty])
   

   quantity = {2, 4, 6}
   trigger = {20, 15, 10}
   opai = CybranM2EastBase:AddOpAI('AirAttacks', 'M2_EastAirAttack3',
       {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Cybran_Air_Attack_Chain_1', 'M2_Cybran_Air_Attack_Chain_2','M2_Cybran_Air_Attack_Chain_3'},
            },
           Priority = 100,
       }
   )
   opai:SetChildQuantity({'AirSuperiority'}, quantity[Difficulty])
   opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.TECH2 * categories.AIR})
end


-------------------------------------------
-- Function that picks land patrols for AI
-------------------------------------------
function M2WestBaseLandPlatoonAI(platoon)
	--only pick chain 1 if base is destroyed!!
	local start = 2
	if Objectives.IsComplete(ScenarioInfo.M1S1) then
		start = 1
	end
	local rand = Random(start, 4)
	local chains = {'M2_Cybran_Land_Attack_Chain_1', 'M2_Cybran_Land_Attack_Chain_2','M2_Cybran_Land_Attack_Chain_3','M2_Cybran_Land_Attack_Chain_4'}
	
    platoon:Stop()
	ScenarioFramework.PlatoonPatrolRoute(platoon, ScenarioUtils.ChainToPositions(chains[rand]))
end

----------------------
-- Drop units at start
----------------------
function CybranM2EastBaseUnitDrops()
	TCRUtil.DropUnits('Rhino_1_D' .. Difficulty, 'M1_Forward_S1_Patrol_Chain_0', 'Transport_End_Point', 'M1_Forward_S1_Patrol_Chain')
	TCRUtil.DropUnits('Loya_3_D' .. Difficulty, 'M2_Cybran_Drop_Loya_Chain_3_0', 'Transport_End_Point', 'M2_Cybran_Drop_Loya_Chain_3')
	TCRUtil.DropUnits('Loya_4_D' .. Difficulty, 'M2_Cybran_Drop_Loya_Chain_4_0', 'Transport_End_Point', 'M2_Cybran_Drop_Loya_Chain_4')
	
	if Objectives.IsComplete(ScenarioInfo.M1S1) then
		TCRUtil.DropUnits('Rhino_2_D' .. Difficulty, 'M2_Cybran_Drop_Rhino_Chain_2_0', 'Transport_End_Point', 'M2_Cybran_Drop_Rhino_Chain_2')
		TCRUtil.DropUnits('Loya_5_D' .. Difficulty, 'M2_Cybran_Drop_Loya_Chain_5_0', 'Transport_End_Point', 'M2_Cybran_Drop_Loya_Chain_5')
	else
		TCRUtil.DropUnits('Rhino_2_D' .. Difficulty, 'M2_Cybran_Drop_Rhino_Alternative', 'Transport_End_Point', 'M1_Forward_S1_Patrol_Chain')
		TCRUtil.DropUnits('Loya_5_D' .. Difficulty, 'M2_Cybran_Drop_Loya_Alternative', 'Transport_End_Point', 'M2_Cybran_Drop_Loya_Chain_4')
	end
end

--------------------------------------
-- Anti-Air Defenses against air abuse
--------------------------------------
function ExtraAADefense()
	
	--build more AA turrets 
	
    CybranM2EastBase:AddBuildGroupDifficulty('M2_Cybran_East_Base_Extra_AA_Defenses', 80, false)
	
	--Patroling cloud of interceptors
   local opai = nil
   local quantity = {}
   local trigger = {}


   quantity = {10,20,30}
   opai = CybranM2EastBase:AddOpAI('AirAttacks', 'M2_AntiAir_AirDefense_1',
       {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Cybran_Air_Patrol_Chain'},
            },
           Priority = 80,
       }
   )
   opai:SetChildQuantity({'Interceptors'}, quantity[Difficulty])
   
	--spawn flak assault groups
	quantity = {4, 6, 8}
	trigger = {70,60,50}
	opai = CybranM2EastBase:AddOpAI('BasicLandAttack', 'M2_AntiAir_LandAttack_1',
		{
			MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
			PlatoonData = {
				PatrolChains = {'M2_Cybran_Land_Attack_Chain_1', 'M2_Cybran_Land_Attack_Chain_2','M2_Cybran_Land_Attack_Chain_3','M2_Cybran_Land_Attack_Chain_4'},
			},
			Priority = 80,
		}
	)
	opai:SetChildQuantity({'MobileFlak', 'MobileStealth'}, quantity[Difficulty])
	opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
		{'default_brain', 'Player', trigger[Difficulty], categories.AIR})
	
end


----------------------
--Spawn Experimentals
----------------------

function DropExperimental(deathCallback)
	
	
	if spawnMonkeylords <= spawnMegaliths then
		spawnMonkeylords = spawnMonkeylords + 1
	else
		spawnMegaliths = spawnMegaliths + 1
	end
	
	--some changes to have a better increase of difficulty.
	if spawnMonkeylords == 1 and spawnMegaliths == 1 and (not singleMega) then
		spawnMonkeylords = 0
		singleMega = true
	end
	
	for i = 1,spawnMonkeylords do
		local units = {}
		local move1 = math.random(10)
		local move2 = math.random(10)
		local monkeylord = CreateUnitHPR("url0402", "Cybran", 240 + move1, 6.75, 10 + move2,0,0,0)
		ScenarioFramework.CreateUnitDeathTrigger(deathCallback, monkeylord)
		table.insert(units, monkeylord )
		local transport = CreateUnitHPR("ura0104", "Cybran", 240 + move1, 6.75, 10 + move2,0,0,0)
		table.insert(units, transport )
		TCRUtil.DropUnits(units, 'M2_Exp_Drop_Location', 'Transport_End_Point', 'M2_Cybran_Exp_Attack_Chain_1')
		FocusACUs(monkeylord)
	end
	for i = 1,spawnMegaliths do
		local units = {}
		local move1 = math.random(10)
		local move2 = math.random(10)
		local megalith = CreateUnitHPR("xrl0403", "Cybran", 240 + move1, 6.75, 10 + move2,0,0,0)
		ScenarioFramework.CreateUnitDeathTrigger(deathCallback, megalith)
		table.insert(units, megalith )
		local transport = CreateUnitHPR("ura0104", "Cybran", 240 + move1, 6.75, 10 + move2,0,0,0)
		table.insert(units, transport )
		TCRUtil.DropUnits(units, 'M2_Exp_Drop_Location', 'Transport_End_Point', 'M2_Cybran_Exp_Attack_Chain_1')
		FocusACUs(megalith)
	end
	

end

function FocusACUs(unit)
	TCRUtil.CreateFocusACUTrigger( unit, ScenarioInfo.PlayerCDR, 30, timeBeforeFocus )
	for i = 2,ScenarioInfo.NumberOfPlayers do
		TCRUtil.CreateFocusACUTrigger( unit, ScenarioInfo.CoopCDR[i - 1], 30 , timeBeforeFocus)
	end
end

function AfterExperimentalDrops()

	-- 2 times 2 loyalists
	local dropLocations = {'M1_Forward_S1_Patrol_Chain_0', 'M2_Cybran_Drop_Rhino_Chain_2_0'}
	local attackChains = {'M1_Forward_S1_Patrol_Chain', 'M2_Cybran_Drop_Rhino_Chain_2'}
	for i = 1,2 do
		local units = {}
		for i = 1,2 do
			local loyalist = CreateUnitHPR("url0303", "Cybran", 250, 6.75, 15,0,0,0)
			table.insert(units, loyalist )
		end
		local transport = CreateUnitHPR("ura0104", "Cybran", 250, 6.75, 15,0,0,0)
		table.insert(units, transport )
		TCRUtil.DropUnits(units, dropLocations[i], 'Transport_End_Point', attackChains[i])
	end
	
	-- 3 times 1 brick
	dropLocations = {'M2_Cybran_Drop_Loya_Chain_3_0', 'M2_Cybran_Drop_Loya_Chain_4_0', 'M2_Cybran_Drop_Loya_Chain_5_0'}
	attackChains = {'M2_Cybran_Drop_Loya_Chain_3', 'M2_Cybran_Drop_Loya_Chain_4', 'M2_Cybran_Drop_Loya_Chain_5'}
	for i = 1,3 do
		local units = {}
		local brick = CreateUnitHPR("xrl0305", "Cybran", 250, 6.75, 15,0,0,0)
		table.insert(units, brick )
		local transport = CreateUnitHPR("ura0104", "Cybran", 250, 6.75, 15,0,0,0)
		table.insert(units, transport )
		TCRUtil.DropUnits(units, dropLocations[i], 'Transport_End_Point', attackChains[i])
	end
	
end

function SnipeACUs()
	local units = TCRUtil.GetAllCatUnitsInArea(categories.COMMAND, 'M2_Area')
	spawnCorsairs = spawnCorsairs + 5
	if spawnCorsairs < 21 then
		for _, cdr in units do
			for i = 1,spawnCorsairs do
				local corsair = CreateUnitHPR("dra0202", "Cybran", 245 + math.random(10), 6.75, 10 + math.random(10),0,0,0)
				IssueAttack({corsair}, cdr)
			end
		end
	else
		for _, cdr in units do
			local spawnStrats = spawnCorsairs / 5
			for i = 1,spawnStrats do
				local strat = CreateUnitHPR("ura0304", "Cybran", 245 + math.random(10), 6.75, 10 + math.random(10),0,0,0)
				IssueAttack({strat}, cdr)
			end
		end
	end
end
