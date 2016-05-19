local BaseManager = import('/lua/ai/opai/basemanager.lua')
local ScenarioFramework = import('/lua/ScenarioFramework.lua')

local SPAIFileName = '/lua/scenarioplatoonai.lua'

---------
-- Locals
---------
local UEFAlly = 3
local Difficulty = ScenarioInfo.Options.Difficulty

----------------
-- Base Managers
----------------
local UEFAllyM5Base = BaseManager.CreateBaseManager()
local UEFAllyM5GateBase = BaseManager.CreateBaseManager()

function UEFAllyM5BaseAI()
	local Base = ScenarioFramework.GetCatUnitsInArea((categories.ALLUNITS), 'M1_Civilian_Area', ArmyBrains[UEFAlly])
    UEFAllyM5Base:Initialize(ArmyBrains[UEFAlly], 'M5_UEFAlly_Base', 'M5_UEFAlly_Base_Marker', 60, {Base = 100})
    UEFAllyM5Base:SetEngineerCount({4, 3})
    UEFAllyM5Base:SetActive('AirScouting', true)

    UEFAllyM5BaseAirAttacks()
    UEFAllyM5BaseLandAttacks()
end

function UEFAllyM5BaseAirAttacks()
	local opai = nil
	
	-- Air Defense over Civs
	-- Maintains 12 Interceptors
    for i = 1, 3 do
        opai = UEFAllyM5Base:AddOpAI('AirAttacks', 'M5_UEFAlly_AirDefense1_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M5_UEFAlly_Island_Civs_AirDef_Chain',
                },
                Priority = 110,
            }
        )
        opai:SetChildQuantity({'Interceptors'}, 4)
    end

    -- Maintains 8 Gunships
    for i = 1, 4 do
        opai = UEFAllyM5Base:AddOpAI('AirAttacks', 'M5_UEFAlly_AirDefense2_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M5_UEFAlly_Island_Civs_AirDef_Chain',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity({'Gunships'}, 2)
    end
end

function UEFAllyM5BaseLandAttacks()
	local opai = nil
	for i = 1, 2 do
        opai = UEFAllyM5Base:AddOpAI('BasicLandAttack', 'M5_UEFAllyTransportAttack1_' .. i,
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain = 'M5_UEFAlly_Transport_Attack_Chain',
                LandingChain = 'M5_UEFAlly_Transport_Landing_Chain',
                MovePath = 'M5_UEFAlly_Transport_Route',
                TransportReturn = 'M5_UEFAlly_Transport_Return',
            },
            Priority = 130,
        })
        opai:SetChildQuantity({'HeavyTanks'}, 6)
    end

    -- Base Defense
    for i = 1, 2 do
        opai = UEFAllyM5Base:AddOpAI('BasicLandAttack', 'M5_UEFAllyLandDef1_' .. i,
	        {
	            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
	            PlatoonData = {
	            	PatrolChain = 'M5_UEFAlly_Base_LandDef_Chain1',
	        	},
	            Priority = 120,
	        }
        )
        opai:SetChildQuantity({'MobileFlak'}, 2)
    end

    for i = 1, 2 do
        opai = UEFAllyM5Base:AddOpAI('BasicLandAttack', 'M5_UEFAllyLandDef2_' .. i,
        	{
	            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
	            PlatoonData = {
	            	PatrolChain = 'M5_UEFAlly_Base_LandDef_Chain2',
	        	},
	            Priority = 120,
	        }
        )
        opai:SetChildQuantity({'MobileFlak'}, 2)
    end

    for i = 1, 2 do
        opai = UEFAllyM5Base:AddOpAI('BasicLandAttack', 'M5_UEFAllyGateLandDef1_' .. i,
        	{
	            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
	            PlatoonData = {
	            	PatrolChain = 'M5_UEFAlly_Base_Gate_LandDef_Chain',
	        	},
	            Priority = 120,
	        }
        )
        opai:SetChildQuantity({'MobileFlak'}, 2)
    end

    -- Civ Defense
    for i = 1, 3 do
        opai = UEFAllyM5Base:AddOpAI('BasicLandAttack', 'M5_UEFAllyTransportDef1_' .. i,
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain = 'M5_UEFAlly_Transport_Def_Chain',
                LandingChain = 'M5_UEFAlly_Transport_Landing_Chain',
                MovePath = 'M5_UEFAlly_Transport_Route',
                TransportReturn = 'M5_UEFAlly_Transport_Return',
            },
            Priority = 100,
        })
        opai:SetChildQuantity({'MobileFlak'}, 2)
    end
end

function UEFAllyM5GateBaseAI()
	local GateBase = ScenarioFramework.GetCatUnitsInArea((categories.ALLUNITS), 'Gate_Area', ArmyBrains[UEFAlly])
    UEFAllyM5GateBase:Initialize(ArmyBrains[UEFAlly], 'M5_UEFAlly_Gate_Base', 'M5_UEFAlly_Gate_Base_Marker', 40, {GateBase = 100})
    UEFAllyM5GateBase:SetEngineerCount({2, 1})
    UEFAllyM5GateBase:SetActive('AirScouting', true)

    UEFAllyM5GateBase:AddBuildGroup('Quantum_Gate_Afterbuild', 90)
    UEFAllyM5GateBase:AddBuildGroup('M5_UEFAlly_Walls_1', 85)
    UEFAllyM5GateBase:AddBuildGroup('M5_UEFAlly_Walls_2', 80)
    UEFAllyM5GateBase:AddBuildGroup('M5_UEFAlly_Walls_3', 75)

    UEFAllyM5GateBaseAirAttacks()
end

function UEFAllyM5GateBaseAirAttacks()
	local opai = nil
	-- Transport Builder
    opai = UEFAllyM5GateBase:AddOpAI('EngineerAttack', 'M5_UEFAlly_TransportBuilder',
    {
        MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
        PlatoonData = {
            AttackChain = 'M5_UEFAlly_Transport_Attack_Chain',
            LandingChain = 'M5_UEFAlly_Transport_Landing_Chain',
            TransportReturn = 'M5_UEFAlly_Transport_Return',
        },
        Priority = 200,
    })
    opai:SetChildActive('All', false)
    opai:SetChildActive('T2Transports', true)
    opai:SetChildQuantity({'T2Transports'}, 1)
    opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
        'HaveLessThanUnitsWithCategory', {'default_brain', 4, categories.uea0104})   -- T2 Transport
end