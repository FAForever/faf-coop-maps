local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'

---------
-- Locals
---------
local Ariel = 2
local Difficulty = ScenarioInfo.Options.Difficulty

----------------
-- Base Managers
----------------
local ArielM3Base = BaseManager.CreateBaseManager()

---------------------
-- Ariel M3 Main Base
---------------------
function ArielM3BaseAI()
    ArielM3Base:InitializeDifficultyTables(ArmyBrains[Ariel], 'M3_Ariel_Base', 'Ariel_Base_Marker', 90, {M3_Ariel_Base = 100})
    ArielM3Base:StartNonZeroBase({{7, 13, 19}, {5, 10, 15}})
    ArielM3Base:SetActive('AirScouting', true)

    ForkThread(function()
        WaitSeconds(1)
        ArielM3Base:AddBuildGroup('M3_Ariel_Base_Support_Factories', 100, true)
    end)

    ArielM3BaseAirAttacks()
    ArielM3BaseLandAttacks()
end

function ArielM3BaseAirAttacks()
	local opai = nil
	local quantity = {}
	local trigger = {}

    -- Transport builder, maintain 8 transports
    opai = ArielM3Base:AddOpAI('EngineerAttack', 'M3_TransportBuilder',
        {
            MasterPlatoonFunction = {SPAIFileName, 'LandAssaultWithTransports'},
            PlatoonData = {
                TransportReturn = 'Ariel_Base_Marker',
            },
            Priority = 1000,
        }
    )
    opai:SetChildQuantity('T2Transports', 5)
    opai:SetLockingStyle('None')
    opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
        'HaveLessThanUnitsWithCategory', {'default_brain', 8, categories.uaa0104})

    quantity = {10, 15, 20}
    opai = ArielM3Base:AddOpAI('AirAttacks', 'M3_Aeon_Base_AirAttack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'Ariel_M3_Air_Attack_Chain_1',
                    'Ariel_M3_Air_Attack_Chain_2',
                    'Ariel_M3_Air_Attack_Chain_3',
                    'Ariel_M3_Air_Attack_Chain_4',
                    'Ariel_M3_Air_Attack_Chain_5',
                },
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])

    opai = ArielM3Base:AddOpAI('AirAttacks', 'M3_Aeon_Base_AirAttack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'Ariel_M3_Air_Attack_Chain_1',
                    'Ariel_M3_Air_Attack_Chain_2',
                    'Ariel_M3_Air_Attack_Chain_3',
                    'Ariel_M3_Air_Attack_Chain_4',
                    'Ariel_M3_Air_Attack_Chain_5',
                },
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('StratBombers', 5)

    quantity = {5, 10, 15}
    trigger = {10, 11, 12}
    opai = ArielM3Base:AddOpAI('AirAttacks', 'M3_Aeon_Base_AirAttack_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'Ariel_M3_Air_Attack_Chain_1',
                    'Ariel_M3_Air_Attack_Chain_2',
                    'Ariel_M3_Air_Attack_Chain_3',
                    'Ariel_M3_Air_Attack_Chain_4',
                    'Ariel_M3_Air_Attack_Chain_5',
                },
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE, '>='})
end

function ArielM3BaseLandAttacks()
	local opai = nil
	local quantity = {}
	local trigger = {}

    --------
    -- Drops
    --------
    quantity = {6, 8, 10}
    for i = 1, 2 do
        opai = ArielM3Base:AddOpAI('BasicLandAttack', 'M3_Aeon_Drop_1_' .. i,
            {
                MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
                PlatoonData = {
                    AttackChain = 'Ariel_M3_Attack_Chain',
                    LandingChain = 'Ariel_M3_Landing_Chain',
                },
                Priority = 200,
            }
        )
        opai:SetChildQuantity('SiegeBots', quantity[Difficulty])
        opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
            'HaveGreaterThanUnitsWithCategory', {'default_brain', 4, categories.uaa0104})
        opai:SetLockingStyle('DeathTimer', {LockTimer = 240})
    end
end