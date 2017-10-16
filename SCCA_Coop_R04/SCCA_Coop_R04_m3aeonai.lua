local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'

---------
-- Locals
---------
local Aeon = 2
local Difficulty = ScenarioInfo.Options.Difficulty

----------------
-- Base Managers
----------------
local AeonM3Base = BaseManager.CreateBaseManager()

-------------------
-- Aeon M1 Air Base
-------------------
function AeonM3BaseAI()
    AeonM3Base:InitializeDifficultyTables(ArmyBrains[Aeon], 'M3_Aeon_Base', 'M3_Aeon_Base_Marker', 60, {M3_Aeon_Base = 100})
    AeonM3Base:StartNonZeroBase({6, 5})
    AeonM3Base:SetActive('AirScouting', true)
    AeonM3Base:SetActive('LandScouting', true)

    AeonM3BaseAirAttacks()
    AeonM3BaseLandAttacks()
end

function AeonM3BaseAirAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    quantity = {4, 8, 12}
    opai = AeonM3Base:AddOpAI('AirAttacks', 'M3_Aeon_AirAttack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M3_Attack_Base1_Air1',
                    'M3_Attack_Base1_Air2',
                    'M3_Attack_Base2_Air1',
                    'M3_Attack_Base2_Air2',
                },
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Bombers', quantity[Difficulty])

    quantity = {4, 8, 12}
    opai = AeonM3Base:AddOpAI('AirAttacks', 'M3_Aeon_AirAttack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M3_Attack_Base1_Air1',
                    'M3_Attack_Base1_Air2',
                    'M3_Attack_Base2_Air1',
                    'M3_Attack_Base2_Air2',
                },
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])

    -- M3_Patrol_Air
end

function AeonM3BaseLandAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    -- Transport builder
    opai = AeonM3Base:AddOpAI('EngineerAttack', 'M3_Aeon_TransportBuilder',
        {
            MasterPlatoonFunction = {SPAIFileName, 'LandAssaultWithTransports'},
            PlatoonData = {
                TransportReturn = 'M3_Transport_Staging_Area',
            },
            Priority = 1000,
        }
    )
    opai:SetChildQuantity('T2Transports', 2)
    opai:SetLockingStyle('None')
    opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
        'HaveLessThanUnitsWithCategory', {'default_brain', 6, categories.uaa0104})

    --------
    -- Drops
    --------
    for i = 1, 2 do
        opai = AeonM3Base:AddOpAI('BasicLandAttack', 'M3_Aeon_TransportAttack_1_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'LandAssaultWithTransports'},
                PlatoonData = {
                    AttackChain = 'M1_Player_Base_Attack_Chain',
                    LandingChain = 'M3_Landing_Chain',
                    TransportReturn = 'M3_Transport_Staging_Area',
                },
                Priority = 110,
            }
        )
        opai:SetChildQuantity('HeavyTanks', 6)
    end

    ----------
    -- Defense
    ----------
    opai = AeonM3Base:AddOpAI('AirAttacks', 'M3_Aeon_Base_Land_Patrol_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Patrol_Land',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('HeavyTanks', 4)
    opai:SetFormation('NoFormation')
end