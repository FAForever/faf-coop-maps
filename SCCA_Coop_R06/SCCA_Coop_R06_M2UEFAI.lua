--------------------------------------------------------------------------------
--  File     : /maps/SCCA_Coop_R06/SCCA_Coop_R06_M2UEFAI.lua
--  Author(s): Dhomie42
--
--  Summary  : UEF army AI for Mission 1-2 - SCCA_Coop_R06
--------------------------------------------------------------------------------
local BaseManager = import('/lua/ai/opai/basemanager.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')

-- ------
-- Locals
-- ------
local UEF = 3
local Difficulty = ScenarioInfo.Options.Difficulty
local SPAIFileName = '/lua/ScenarioPlatoonAI.lua'
local CustomFunctions = '/maps/SCCA_Coop_R06/SCCA_Coop_R06_CustomFunctions.lua'

-- -------------
-- Base Managers
-- -------------
local UEFControlCenterBase = BaseManager.CreateBaseManager()
local UEFDefensiveLineBase = BaseManager.CreateBaseManager()

function M2UEFControlCenterExpansion()
	UEFControlCenterBase:AddBuildGroup('ControlCenterDefensesPostBuilt_D' .. Difficulty, 100)
	ScenarioInfo.ControlCenterExpansionAuthorized = true
end

function M2DefensiveLineExpansion()
	UEFControlCenterBase:AddExpansionBase('M2_UEF_DefensiveLine', Difficulty)
end

function UEFControlCenterAI()
    -- -------------------------------------
    -- Black Sun Control Center Expansion.
	-- Major defensive line for the UEF.
    -- -------------------------------------
    UEFControlCenterBase:InitializeDifficultyTables(ArmyBrains[UEF], 'UEF_Control_Center_Base', 'ControlCenter', 25,
        {
			ControlCenterDefensesPreBuilt = 150,
        }
    )
	UEFControlCenterBase:StartNonZeroBase({3, 6, 9})
	UEFControlCenterBase:SetMaximumConstructionEngineers(9)
end

function UEFDefensiveLineBaseAI()
    -- ---------------------------------------------------
    -- Black Sun Control Center Defensive Line Expansion.
	-- Minor defensive line for the UEF. 
    -- ---------------------------------------------------
    UEFDefensiveLineBase:InitializeDifficultyTables(ArmyBrains[UEF], 'M2_UEF_DefensiveLine', 'M2_DefensiveLine_Base_Marker', 30,
        {
			M2DefensiveLine = 100,
        }
    )

	UEFDefensiveLineBase:StartEmptyBase({1, 2, 3})
	UEFDefensiveLineBase:SetMaximumConstructionEngineers(3)
end

function MobileFactoryAI(unit, i)
    -- Adding build location for AI
    ArmyBrains[UEF]:PBMAddBuildLocation('UEF_Mobile_Factory_Marker_' .. i, 20, 'MobileFactory' .. i)

    for num, loc in ArmyBrains[UEF].PBM.Locations do
        if loc.LocationType == 'MobileFactory' .. i then
            loc.PrimaryFactories.Land = unit.ExternalFactory
            break
        end
    end
	
	IssueClearFactoryCommands({unit.ExternalFactory})
    IssueFactoryRallyPoint({unit.ExternalFactory}, ScenarioUtils.MarkerToPosition('UEF_Mobile_Factory_Rally_' .. i))

    MobileFactoryAttacks(i)
end

function MobileFactoryAttacks(i)
	local T1Quantity = {8, 6, 4}
    local DirectQuantity = {2, 3, 4}
    local SupportQuantity = {1, 2, 3}
	
    if i == 1 then
		-- 1st Fatboy platoon, mix of T3 and T2
        local Builder = {
			BuilderName = 'M2_UEF_Heavy_Fatboy_Attack_Builder',
			PlatoonTemplate = {
			'M2_UEF_Fatboy_Heavy_Attack_Platoon_Template',
			'NoPlan',
				{'uel0303', 0, DirectQuantity[Difficulty], 'Attack', 'AttackFormation'}, -- T3 Siege Bot
				{'uel0304', 0, SupportQuantity[Difficulty], 'Attack', 'AttackFormation'}, -- T3 Mobile Artillery
				{'uel0202', 0, DirectQuantity[Difficulty], 'Attack', 'AttackFormation'}, -- T2 Tank
				{'uel0205', 0, SupportQuantity[Difficulty], 'Attack', 'AttackFormation'}, -- T2 Flak
				{'uel0111', 0, SupportQuantity[Difficulty], 'Attack', 'AttackFormation'}, -- T2 MML
				{'uel0307', 0, SupportQuantity[Difficulty], 'Attack', 'AttackFormation'}, -- T2 Mobile Shield
			},
			InstanceCount = Difficulty,
			Priority = 100,
			PlatoonType = 'Land',
			RequiresConstruction = true,
			LocationType = 'MobileFactory1',
			PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},
			PlatoonData = {
				PatrolChains = {
					'M2LandAttack_Chain1',
					'M2LandAttack_Chain2',
					'M2LandAttack_Chain3',
					'M2LandAttack_Chain4',
					'M2LandAttack_Chain5',
				},
			},
		}
		ArmyBrains[UEF]:PBMAddPlatoon( Builder )
    elseif i == 2 then
		-- 2nd Fatboy platoon, mix of T2 and T1
		local Builder = {
			BuilderName = 'M2_UEF_Medium_Fatboy_Attack_Builder',
			PlatoonTemplate = {
			'M2_UEF_Fatboy_Medium_Attack_Platoon_Template',
			'NoPlan',
				{'uel0201', 0, T1Quantity[Difficulty], 'Attack', 'AttackFormation'}, -- T1 Tank
				{'uel0103', 0, T1Quantity[Difficulty], 'Attack', 'AttackFormation'}, -- T1 Artillery
				{'uel0202', 0, DirectQuantity[Difficulty], 'Attack', 'AttackFormation'}, -- T2 Tank
				{'uel0205', 0, SupportQuantity[Difficulty], 'Attack', 'AttackFormation'}, -- T2 Flak
				{'uel0111', 0, SupportQuantity[Difficulty], 'Attack', 'AttackFormation'}, -- T2 MML
				{'uel0307', 0, SupportQuantity[Difficulty], 'Attack', 'AttackFormation'}, -- T2 Mobile Shield
			},
			InstanceCount = Difficulty,
			Priority = 100,
			PlatoonType = 'Land',
			RequiresConstruction = true,
			LocationType = 'MobileFactory2',
			PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},
			PlatoonData = {
				PatrolChains = {
					'M2LandAttack_Chain1',
					'M2LandAttack_Chain2',
					'M2LandAttack_Chain3',
					'M2LandAttack_Chain4',
					'M2LandAttack_Chain5',
				},
			},
		}
		ArmyBrains[UEF]:PBMAddPlatoon( Builder )
    end
end