local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'

---------
-- Locals
---------
local UEF = 3
local Difficulty = ScenarioInfo.Options.Difficulty

----------------
-- Base Managers
----------------
local UEFM2Base = BaseManager.CreateBaseManager()
local UEFM2ArtyNorth = BaseManager.CreateBaseManager()
local UEFM2ArtyMiddle = BaseManager.CreateBaseManager()
local UEFM2ArtySouth = BaseManager.CreateBaseManager()

-------------------
-- UEF M2 Main Base
-------------------
function UEFM2BaseAI()
    UEFM2Base:InitializeDifficultyTables(ArmyBrains[UEF], 'West_Base', 'UEF_West_Base', 90, {West_Base = 100})
    UEFM2Base:StartNonZeroBase({{5, 9, 13}, {3, 7, 10}})
    UEFM2Base:SetActive('AirScouting', true)

    ForkThread(function()
        WaitSeconds(1)
        UEFM2Base:AddBuildGroup('West_Base_Support_Factories', 100, true)
    end)

    UEFM2BaseAirAttacks()
    UEFM2BaseLandAttacks()
end

function UEFM2BaseAirAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}
    
    -- Transport Builder
    opai = UEFM2Base:AddOpAI('EngineerAttack', 'M2_UEF_TransportBuilder',
        {
            MasterPlatoonFunction = {SPAIFileName, 'LandAssaultWithTransports'},
            PlatoonData = {
                TransportReturn = 'UEF_West_Base',
            },
            Priority = 1000,
        }
    )
    opai:SetChildQuantity('T2Transports', 4)
    opai:SetLockingStyle('None')
    opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
        'HaveLessThanUnitsWithCategory', {'default_brain', 7, categories.uea0104})

    quantity = {8, 12, 16}
    opai = UEFM2Base:AddOpAI('AirAttacks', 'M2_UEF_AirAttack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'UEF_M2_Bomber_Chain_1',
                                'UEF_M2_Bomber_Chain_2',
                                'UEF_M2_Bomber_Chain_3',
                                'UEF_M2_Bomber_Chain_4'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    opai:SetLockingStyle('None')

    quantity = {8, 12, 16}
    opai = UEFM2Base:AddOpAI('AirAttacks', 'M2_UEF_AirAttack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'UEF_M2_Bomber_Chain_1',
                                'UEF_M2_Bomber_Chain_2',
                                'UEF_M2_Bomber_Chain_3',
                                'UEF_M2_Bomber_Chain_4'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'AirSuperiority', 'Gunships'}, quantity[Difficulty])
    opai:SetLockingStyle('DeathTimer', {LockTimer = 180})

    quantity = {2, 3, 4}
    opai = UEFM2Base:AddOpAI('AirAttacks', 'M2_UEF_AirAttack_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'UEF_M2_Bomber_Chain_1',
                                'UEF_M2_Bomber_Chain_2',
                                'UEF_M2_Bomber_Chain_3',
                                'UEF_M2_Bomber_Chain_4'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('HeavyGunships', quantity[Difficulty])
    opai:SetLockingStyle('DeathTimer', {LockTimer = 120})

    -- ASFs
    quantity = {4, 8, 12}
    trigger = {10, 14, 16}
    opai = UEFM2Base:AddOpAI('AirAttacks', 'M2_UEF_AirAttack_4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'UEF_M2_Bomber_Chain_1',
                                'UEF_M2_Bomber_Chain_2',
                                'UEF_M2_Bomber_Chain_3',
                                'UEF_M2_Bomber_Chain_4'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.MOBILE * categories.AIR - categories.TECH2, '>='})

    -- Strat attack
    quantity = {2, 3, 4}
    opai = UEFM2Base:AddOpAI('AirAttacks', 'M2_UEF_AirAttack_5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'UEF_M2_Bomber_Chain_1',
                                'UEF_M2_Bomber_Chain_2',
                                'UEF_M2_Bomber_Chain_3',
                                'UEF_M2_Bomber_Chain_4'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('StratBombers', quantity[Difficulty])
    if Difficulty <= 2 then
        opai:SetLockingStyle('DeathTimer', {LockTimer = 180})
    end

    -- Strat bomber hunt
    quantity = {4, 8, 12}
    trigger = {16, 13, 10}
    opai = UEFM2Base:AddOpAI('AirAttacks', 'M2_UEF_AirAttack_6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'CategoryHunterPlatoonAI'},
            PlatoonData = {
                CategoryList = {categories.uaa0304},
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    opai:SetLockingStyle('DeathTimer', {LockTimer = 180})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.uaa0304, '>='})

    -- Defense
    -- UEF_WestBase_Air_Patrol_Chain
end

function UEFM2BaseLandAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    quantity = {8, 12, 20}
    opai = UEFM2Base:AddOpAI('BasicLandAttack', 'M2_UEF_Amphibious_Attack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'UEF_M2_Aphibious_Chain_1',
                                'UEF_M2_Aphibious_Chain_2'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('AmphibiousTanks', quantity[Difficulty])
    opai:SetFormation('AttackFormation')
    opai:SetLockingStyle('None')
    
    -- Drops
    quantity = {4, 6, 8}
    opai = UEFM2Base:AddOpAI('BasicLandAttack', 'M3_TransportAttack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'LandAssaultWithTransports'},
            PlatoonData = {
                AssaultChains = {'UEF_M1_Attack_Chain_1', 'UEF_M1_Attack_Chain_2', 'UEF_M1_Attack_Chain_3', 'UEF_M1_Attack_Chain_4'},
                LandingChain = 'UEF_M2_Landing_Chain_2',
                TransportReturn = 'UEF_West_Base',
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'MobileHeavyArtillery'}, quantity[Difficulty])

    quantity = {6, 12, 18}
    opai = UEFM2Base:AddOpAI('BasicLandAttack', 'M3_TransportAttack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'LandAssaultWithTransports'},
            PlatoonData = {
                AssaultChains = {'UEF_M1_Attack_Chain_1', 'UEF_M1_Attack_Chain_2', 'UEF_M1_Attack_Chain_3', 'UEF_M1_Attack_Chain_4'},
                LandingChain = 'UEF_M2_Landing_Chain_2',
                TransportReturn = 'UEF_West_Base',
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('HeavyTanks', quantity[Difficulty])

    quantity = {6, 9, 12}
    opai = UEFM2Base:AddOpAI('BasicLandAttack', 'M3_TransportAttack_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'LandAssaultWithTransports'},
            PlatoonData = {
                AssaultChains = {'UEF_M1_Attack_Chain_1', 'UEF_M1_Attack_Chain_2', 'UEF_M1_Attack_Chain_3', 'UEF_M1_Attack_Chain_4'},
                LandingChain = 'UEF_M2_Landing_Chain_2',
                TransportReturn = 'UEF_West_Base',
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('SiegeBots', quantity[Difficulty])
end

--------------------
-- UEF M2 Arty Bases
--------------------
function UEFM2ArtyNorthBaseAI()
    UEFM2ArtyNorth:InitializeDifficultyTables(ArmyBrains[UEF], 'North_Artillery_Base', 'North_Artillery_Base_Marker', 40, {North_Artillery_Base = 100})
    UEFM2ArtyNorth:StartNonZeroBase({1, 2, 2})
    UEFM2ArtyNorth:AddBuildGroup('North_Artillery_Build', 90, true) -- Spawn north arty right away
end

function UEFM2ArtyMiddleBaseAI()
    UEFM2ArtyMiddle:InitializeDifficultyTables(ArmyBrains[UEF], 'Middle_Artillery_Base', 'Middle_Artillery_Base_Marker', 40, {Middle_Artillery_Base = 100})
    UEFM2ArtyMiddle:StartNonZeroBase({2, 3, 3})
    UEFM2ArtyMiddle:AddBuildGroup('Middle_Artillery_Build', 90)
end

function UEFM2ArtySouthBaseAI()
    UEFM2ArtySouth:InitializeDifficultyTables(ArmyBrains[UEF], 'South_Artillery_Base', 'South_Artillery_Base_Marker', 40, {South_Artillery_Base = 100})
    UEFM2ArtySouth:StartNonZeroBase({1, 2, 2})
    UEFM2ArtySouth:AddBuildGroup('South_Artillery_Build', 90)
end