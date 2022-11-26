local BaseManager = import('/lua/ai/opai/basemanager.lua')
local OpScript = import('/maps/FAF_Coop_Operation_Tight_Spot/FAF_Coop_Operation_Tight_Spot_script.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')

local SPAIFileName = '/lua/ScenarioPlatoonAI.lua'
local ThisFile = '/maps/FAF_Coop_Operation_Tight_Spot/FAF_Coop_Operation_Tight_Spot_m3qaiai.lua'

---------
-- Locals
---------
local QAI = 3
local Difficulty = ScenarioInfo.Options.Difficulty

-- The bases send either Zeus or Jester
local attackAirUnit
if Random(1, 2) == 1 then
    attackAirUnit = 'Bombers'
else
    attackAirUnit = 'LightGunships'
end

----------------
-- Base Managers
----------------
local QAIM3NorthEastBase = BaseManager.CreateBaseManager()
local QAIM3NorthBase = BaseManager.CreateBaseManager()
local QAIM3NorthWestBase = BaseManager.CreateBaseManager()
local QAIM3SouthEastBase = BaseManager.CreateBaseManager()
local QAIM3SouthWestBase = BaseManager.CreateBaseManager()
local QAIM3WestBase = BaseManager.CreateBaseManager()
local QAIM3MainBase = BaseManager.CreateBaseManager()
local QAIM3DefenseBase = BaseManager.CreateBaseManager()
local QAIM3PlateauDefenseBase = BaseManager.CreateBaseManager()
local QAIM3ExperimentalBase = BaseManager.CreateBaseManager()

-------------------------
-- QAI M3 North East Base
-------------------------
function QAIM3NorthEastBaseAI()
    QAIM3NorthEastBase:Initialize(ArmyBrains[QAI], 'M3_QAI_NE_Base', 'M3_QAI_NE_Base_Marker', 30, {M3_QAI_NE_1 = 100, M3_QAI_NE_Eng = 100})
    QAIM3NorthEastBase:StartNonZeroBase(2)

    ForkThread(NorthEastBaseExpandThread)

    QAIM3NorthEastBaseLandAttacks()
end

function NorthEastBaseExpandThread()
    QAIM3NorthEastBase:AddBuildGroup('M3_QAI_NE_2', 90)
    --WaitSeconds(7*60)
    QAIM3NorthEastBase:AddBuildGroup('M3_QAI_NE_3', 80)
    --WaitSeconds(6*60)
    QAIM3NorthEastBase:AddBuildGroup('M3_QAI_NE_4', 70)
    --WaitSeconds(7*60)
    QAIM3NorthEastBase:AddBuildGroup('M3_QAI_NE_Def', 60)
    QAIM3NorthEastBase:AddBuildGroup('M3_QAI_NE_Arty', 50)
end

function QAIM3NorthEastBaseLandAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}
    local defaultChains =  {
        'M3_QAI_NE_Attack_Chain_1',
        'M3_QAI_NE_Attack_Chain_2',
        'M3_QAI_NE_Attack_Chain_3',
    }

    -- Engineer for reclaiming if there's less than 2000 Mass in the storage, starting after 5 minutes
    quantity = {3, 4, 6}
    opai = QAIM3NorthEastBase:AddOpAI('EngineerAttack', 'M3_QAI_NE_Reclaim_Engineers',
        {
            MasterPlatoonFunction = {SPAIFileName, 'SplitPatrolThread'},
            PlatoonData = {
                PatrolChains = defaultChains,
            },
            Priority = 200,
        }
    )
    opai:SetChildQuantity('T1Engineers', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/economybuildconditions.lua', 'LessThanMassStorageCurrent', {600})

    ----------
    -- Attacks
    ----------
    quantity = {3, 4, 5}
    opai = QAIM3NorthEastBase:AddOpAI('BasicLandAttack', 'M3_QAI_NE_LandAttack_1',
        {
            MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
            PlatoonData = {
                AttackChains = defaultChains,
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('LightBots', quantity[Difficulty])

    quantity = {4, 6, 9}
    trigger = {50, 40, 30}
    opai = QAIM3NorthEastBase:AddOpAI('BasicLandAttack', 'M3_QAI_NE_LandAttack_2',
        {
            MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
            PlatoonData = {
                AttackChains = defaultChains,
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('LightArtillery', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL, '>='})
    opai:SetFormation('AttackFormation')

    quantity = {2, 3, 4}
    trigger = {10, 8, 6}
    opai = QAIM3NorthEastBase:AddOpAI('BasicLandAttack', 'M3_QAI_NE_LandAttack_3',
        {
            MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
            PlatoonData = {
                AttackChains = defaultChains,
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('HeavyTanks', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.LAND * categories.TECH2 - categories.ENGINEER, '>='})

    quantity = {2, 3, 4}
    trigger = {18, 15, 12}
    opai = QAIM3NorthEastBase:AddOpAI('BasicLandAttack', 'M3_QAI_NE_LandAttack_4',
        {
            MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
            PlatoonData = {
                AttackChains = defaultChains,
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('MobileMissiles', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.DEFENSE - categories.TECH1, '>='})

    quantity = {2, 3, 4}
    trigger = {20, 15, 10}
    opai = QAIM3NorthEastBase:AddOpAI('BasicLandAttack', 'M3_QAI_NE_LandAttack_5',
        {
            MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
            PlatoonData = {
                AttackChains = defaultChains,
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('MobileFlak', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE, '>='})

    quantity = {4, 6, 8}
    trigger = {5, 4, 3}
    opai = QAIM3NorthEastBase:AddOpAI('BasicLandAttack', 'M3_QAI_NE_LandAttack_6',
        {
            MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
            PlatoonData = {
                AttackChains = defaultChains,
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity({'RangeBots', 'LightArtillery'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.MASSEXTRACTION * categories.TECH2, '>='})
    
    quantity = {6, 6, 9}
    trigger = {12, 10, 8}
    opai = QAIM3NorthEastBase:AddOpAI('BasicLandAttack', 'M3_QAI_NE_LandAttack_7',
        {
            MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
            PlatoonData = {
                AttackChains = defaultChains,
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity({'SiegeBots', 'HeavyTanks', 'LightBots'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.LAND * categories.TECH3 * categories.MOBILE, '>='})
    opai:SetFormation('AttackFormation')

    quantity = {2, 2, 3}
    trigger = {6, 5, 4}
    opai = QAIM3NorthEastBase:AddOpAI('BasicLandAttack', 'M3_QAI_NE_LandAttack_8',
        {
            MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
            PlatoonData = {
                AttackChains = defaultChains,
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('SiegeBots', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.LAND * categories.TECH3 * categories.MOBILE, '>='})

    quantity = {8, 10, 12}
    trigger = {50, 40, 30}
    opai = QAIM3NorthEastBase:AddOpAI('BasicLandAttack', 'M3_QAI_NE_LandAttack_9',
        {
            MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
            PlatoonData = {
                AttackChains = defaultChains,
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('HeavyTanks', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.LAND * categories.MOBILE - categories.TECH1, '>='})
    opai:SetFormation('AttackFormation')

    if Difficulty >= 2 then
        quantity = {0, 2, 4}
        trigger = {0, 8, 5}
        opai = QAIM3NorthEastBase:AddOpAI('BasicLandAttack', 'M3_QAI_NE_LandAttack_10',
            {
                MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
                PlatoonData = {
                    AttackChains = defaultChains,
                },
                Priority = 140,
            }
        )
        opai:SetChildQuantity('MobileMissiles', quantity[Difficulty])
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
            'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.SHIELD * categories.STRUCTURE, '>='})
    end

    quantity = {2, 4, 8}
    trigger = {25, 20, 15}
    opai = QAIM3NorthEastBase:AddOpAI('BasicLandAttack', 'M3_QAI_NE_LandAttack_11',
        {
            MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
            PlatoonData = {
                AttackChains = defaultChains,
            },
            Priority = 140,
        }
    )
    opai:SetChildQuantity({'HeavyBots', 'MobileFlak'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.TECH3 - categories.ENGINEER, '>='})

    if Difficulty >= 2 then
        quantity = {0, 1, 2}
        trigger = {0, 2, 1}
        opai = QAIM3NorthEastBase:AddOpAI('BasicLandAttack', 'M3_QAI_NE_LandAttack_12',
            {
                MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
                PlatoonData = {
                    AttackChains = defaultChains,
                },
                Priority = 140,
            }
        )
        opai:SetChildQuantity('MobileHeavyArtillery', quantity[Difficulty])
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
            'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.TACTICALMISSILEPLATFORM, '>='})
    end
end

--------------------
-- QAI M3 North Base
--------------------
function QAIM3NorthBaseAI(plan)
    QAIM3NorthBase:InitializeDifficultyTables(ArmyBrains[QAI], 'M3_QAI_N_Base', 'M3_QAI_N_Base_Marker', 45, {M3_QAI_N = 100})
    QAIM3NorthBase:StartNonZeroBase(2)

    if plan == 'push' then
        QAIM3NorthBase:AddBuildGroupDifficulty('M3_QAI_N_Defense', 90, true)
    end

    QAIM3NorthBase:SetActive('AirScouting', true)

    QAIM3NorthBaseAirAttacks(plan)
end

function QAIM3NorthBaseAirAttacks(plan)
    local opai = nil
    local quantity = {}
    local trigger = {}
    local defaultChains =  {
        'M3_QAI_N_Base_Air_Attack_Chain_1',
        'M3_QAI_N_Base_Air_Attack_Chain_2',
    }

    if plan == 'push' then
        -- Reinforce the plateau air patrol each X seconds
        local timer = {120, 90, 60}
        opai = QAIM3NorthBase:AddOpAI('AirAttacks', 'M3_QAI_N_Plateau_Air_Patrol_1',
            {
                MasterPlatoonFunction = {ThisFile, 'SplitAirPlatoon'},
                PlatoonData = {
                    PatrolChain = 'M3_QAI_Plateau_Air_Patrol_Chain',
                    AttackChains = {
                        'M3_QAI_N_Base_Air_Attack_Chain_1',
                        'M3_QAI_N_Base_Air_Attack_Chain_2',
                    },
                },
                Priority = 200,
            }
        )
        opai:SetChildQuantity({'AirSuperiority', 'Gunships', 'Bombers'}, 6)
        opai:SetLockingStyle('BuildTimer', {LockTimer = timer[Difficulty]})
        opai:SetFormation("NoFormation")
        opai:AddFormCallback(SPAIFileName, 'PlatoonEnableStealth')
    end


    -- Attacks to player
    quantity = {2, 3, 4}
    opai = QAIM3NorthBase:AddOpAI('AirAttacks', 'M3_QAI_N_AirAttack_1',
        {
            MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
            PlatoonData = {
                AttackChains = defaultChains,
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity(attackAirUnit, quantity[Difficulty])

    quantity = {3, 4, 5}
    trigger = {60, 50, 40}
    opai = QAIM3NorthBase:AddOpAI('AirAttacks', 'M3_QAI_N_AirAttack_2',
        {
            MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
            PlatoonData = {
                AttackChains = defaultChains,
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity(attackAirUnit, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL, '>='})

    quantity = {3, 4, 5}
    trigger = {6, 4, 2}
    opai = QAIM3NorthBase:AddOpAI('AirAttacks', 'M3_QAI_N_AirAttack_3',
        {
            MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
            PlatoonData = {
                AttackChains = defaultChains,
                CategoryList = {
                    categories.AIR,
                    categories.ALLUNITS - categories.WALL,
                },
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Interceptors', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE, '>='})

    quantity = {2, 2, 3}
    trigger = {15, 12, 9}
    opai = QAIM3NorthBase:AddOpAI('AirAttacks', 'M3_QAI_N_AirAttack_4',
        {
            MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
            PlatoonData = {
                AttackChains = defaultChains,
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.TECH2 - categories.ECONOMIC - categories.ENGINEER, '>='})

    quantity = {6, 8, 10}
    trigger = {8, 6, 4}
    opai = QAIM3NorthBase:AddOpAI('AirAttacks', 'M3_QAI_N_AirAttack_5',
        {
            MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
            PlatoonData = {
                AttackChains = defaultChains,
                CategoryList = {
                    categories.AIR,
                    categories.ALLUNITS - categories.WALL,
                },
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Interceptors', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE - categories.ANTIAIR, '>='})

    quantity = {4, 6, 8}
    trigger = {30, 25, 20}
    opai = QAIM3NorthBase:AddOpAI('AirAttacks', 'M3_QAI_N_AirAttack_6',
        {
            MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
            PlatoonData = {
                AttackChains = defaultChains,
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.TECH2, '>='})

    quantity = {2, 4, 6}
    trigger = {9, 6, 3}
    opai = QAIM3NorthBase:AddOpAI('AirAttacks', 'M3_QAI_N_AirAttack_7',
        {
            MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
            PlatoonData = {
                AttackChains = defaultChains,
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('FighterBombers', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.SHIELD, '>='})

    quantity = {4, 6, 8}
    trigger = {10, 8, 6}
    opai = QAIM3NorthBase:AddOpAI('AirAttacks', 'M3_QAI_N_AirAttack_8',
        {
            MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
            PlatoonData = {
                AttackChains = defaultChains,
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity({'Gunships', 'Bombers'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.ANTIAIR * categories.STRUCTURE, '>='})

    quantity = {2, 2, 3}
    trigger = {6, 5, 4}
    opai = QAIM3NorthBase:AddOpAI('AirAttacks', 'M3_QAI_N_AirAttack_9',
        {
            MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
            PlatoonData = {
                AttackChains = defaultChains,
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('HeavyGunships', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.MASSEXTRACTION * categories.TECH3, '>='})

    quantity = {6, 9, 12}
    trigger = {8, 6, 4}
    opai = QAIM3NorthBase:AddOpAI('AirAttacks', 'M3_QAI_N_AirAttack_10',
        {
            MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
            PlatoonData = {
                AttackChains = defaultChains,
                CategoryList = {
                    categories.AIR,
                    categories.ALLUNITS - categories.WALL,
                },
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity({'AirSuperiority', 'Gunships', 'Interceptors'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.TECH3 * categories.MOBILE, '>='})
    opai:AddFormCallback(SPAIFileName, 'PlatoonEnableStealth')
    opai:SetFormation('NoFormation')

    quantity = {3, 4, 6}
    trigger = {30, 25, 20}
    opai = QAIM3NorthBase:AddOpAI('AirAttacks', 'M3_QAI_N_AirAttack_11',
        {
            MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
            PlatoonData = {
                AttackChains = defaultChains,
            },
            Priority = 140,
        }
    )
    opai:SetChildQuantity('HeavyGunships', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.TECH3 * categories.MOBILE - categories.ENGINEER, '>='})

    trigger = {3, 2, 1}
    opai = QAIM3NorthBase:AddOpAI('AirAttacks', 'M3_QAI_N_AirAttack_12',
        {
            MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
            PlatoonData = {
                AttackChains = defaultChains,
            },
            Priority = 140,
        }
    )
    opai:SetChildQuantity({'StratBombers', 'Gunships', 'Bombers'}, 6)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.TECH3 * categories.ENERGYPRODUCTION * categories.STRUCTURE, '>='})
    opai:AddFormCallback(SPAIFileName, 'PlatoonEnableStealth')
    opai:SetFormation('NoFormation')
end

-------------------------
-- QAI M3 North West Base
-------------------------
function QAIM3NorthWestBaseAI()
    QAIM3NorthWestBase:Initialize(ArmyBrains[QAI], 'M3_QAI_NW_Base', 'M3_QAI_NW_Base_Marker', 40, {M3_QAI_NW_1 = 100})
    QAIM3NorthWestBase:StartNonZeroBase({5, 2})

    --ForkThread(NorthEastBaseExpandThread)
    QAIM3NorthWestBase:AddBuildGroup('M3_QAI_NW_2', 90)
    QAIM3NorthWestBase:AddBuildGroup('M3_QAI_NW_3', 90)
    QAIM3NorthWestBase:AddBuildGroup('M3_QAI_NW_4', 90)
    QAIM3NorthWestBase:AddBuildGroup('M3_QAI_NW_Arty', 90)

    QAIM3NorthWestBaseAirAttacks()
    QAIM3NorthWestBaseLandAttacks()
    QAIM3NorthWestBaseConditionalBuilds()
end

function QAIM3NorthWestBaseAirAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}
    local defaultChains =  {
        'M3_QAI_NW_Attack_Chain_1',
        'M3_QAI_NW_Attack_Chain_2',
        'M3_QAI_NW_Attack_Chain_3',
    }

    quantity = {2, 3, 4}
    trigger = {8, 7, 6}
    opai = QAIM3NorthWestBase:AddOpAI('AirAttacks', 'M3_QAI_NW_AirAttack_1',
        {
            MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
            PlatoonData = {
                AttackChains = defaultChains,
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity(attackAirUnit, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.FACTORY * categories.STRUCTURE, '>='})

    quantity = {4, 5, 6}
    trigger = {80, 70, 60}
    opai = QAIM3NorthWestBase:AddOpAI('AirAttacks', 'M3_QAI_NW_AirAttack_2',
        {
            MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
            PlatoonData = {
                AttackChains = defaultChains,
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity(attackAirUnit, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL, '>='})

    quantity = {2, 3, 4}
    trigger = {100, 90, 80}
    opai = QAIM3NorthWestBase:AddOpAI('AirAttacks', 'M3_QAI_NW_AirAttack_3',
        {
            MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
            PlatoonData = {
                AttackChains = defaultChains,
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL, '>='})

    quantity = {2, 3, 4}
    trigger = {55, 50, 45}
    opai = QAIM3NorthWestBase:AddOpAI('AirAttacks', 'M3_QAI_NW_AirAttack_4',
        {
            MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
            PlatoonData = {
                AttackChains = defaultChains,
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('CombatFighters', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.LAND * categories.MOBILE, '>='})

    quantity = {4, 6, 8}
    trigger = {6, 5, 4}
    opai = QAIM3NorthWestBase:AddOpAI('AirAttacks', 'M3_QAI_NW_AirAttack_5',
        {
            MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
            PlatoonData = {
                AttackChains = defaultChains,
            },
            Priority = 140,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.MASSEXTRACTION - categories.TECH1, '>='})

    quantity = {8, 10, 12}
    trigger = {7, 6, 5}
    opai = QAIM3NorthWestBase:AddOpAI('AirAttacks', 'M3_QAI_NW_AirAttack_6',
        {
            MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
            PlatoonData = {
                AttackChains = defaultChains,
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.TECH3 - categories.ENGINEER, '>='})

    quantity = {2, 2, 3}
    trigger = {300, 280, 260}
    opai = QAIM3NorthWestBase:AddOpAI('AirAttacks', 'M3_QAI_NW_AirAttack_7',
        {
            MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
            PlatoonData = {
                AttackChains = defaultChains,
            },
            Priority = 160,
        }
    )
    opai:SetChildQuantity('HeavyGunships', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL, '>='})

    quantity = {3, 6, 9}
    trigger = {40, 35, 30}
    opai = QAIM3NorthWestBase:AddOpAI('AirAttacks', 'M3_QAI_NW_AirAttack_8',
        {
            MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
            PlatoonData = {
                AttackChains = defaultChains,
            },
            Priority = 160,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE - categories.TECH1, '>='})
    opai:AddFormCallback(SPAIFileName, 'PlatoonEnableStealth')

    quantity = {3, 4, 6}
    trigger = {15, 13, 10}
    opai = QAIM3NorthWestBase:AddOpAI('AirAttacks', 'M3_QAI_NW_AirAttack_9',
        {
            MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
            PlatoonData = {
                AttackChains = defaultChains,
            },
            Priority = 170,
        }
    )
    opai:SetChildQuantity('HeavyGunships', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.TECH3 - categories.ENGINEER, '>='})

    quantity = {3, 6, 9}
    trigger = {20, 15, 10}
    opai = QAIM3NorthWestBase:AddOpAI('AirAttacks', 'M3_QAI_NW_AirAttack_10',
        {
            MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
            PlatoonData = {
                AttackChains = defaultChains,
            },
            Priority = 170,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE * categories.TECH3, '>='})
    opai:AddFormCallback(SPAIFileName, 'PlatoonEnableStealth')

    quantity = {2, 2, 3}
    trigger = {20, 18, 16}
    opai = QAIM3NorthWestBase:AddOpAI('AirAttacks', 'M3_QAI_NW_AirAttack_11',
        {
            MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
            PlatoonData = {
                AttackChains = defaultChains,
            },
            Priority = 170,
        }
    )
    opai:SetChildQuantity('StratBombers', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.TECH3, '>='})
    opai:AddFormCallback(SPAIFileName, 'PlatoonEnableStealth')
end

function QAIM3NorthWestBaseLandAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}
    local defaultChains =  {
        'M3_QAI_NW_Attack_Chain_1',
        'M3_QAI_NW_Attack_Chain_2',
        'M3_QAI_NW_Attack_Chain_3',
    }

    -- Engineer for reclaiming if there's less than 2000 Mass in the storage, starting after 5 minutes
    quantity = {3, 4, 6}
    opai = QAIM3NorthWestBase:AddOpAI('EngineerAttack', 'M3_QAI_NW_Reclaim_Engineers',
        {
            MasterPlatoonFunction = {SPAIFileName, 'SplitPatrolThread'},
            PlatoonData = {
                PatrolChains = defaultChains,
            },
            Priority = 200,
        }
    )
    opai:SetChildQuantity('T1Engineers', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/economybuildconditions.lua', 'LessThanMassStorageCurrent', {1000})

    quantity = {4, 5, 6}
    opai = QAIM3NorthWestBase:AddOpAI('BasicLandAttack', 'M3_QAI_NW_LandAttack_1',
        {
            MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
            PlatoonData = {
                AttackChains = defaultChains,
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('LightBots', quantity[Difficulty])

    quantity = {4, 5, 6}
    trigger = {60, 50, 40}
    opai = QAIM3NorthWestBase:AddOpAI('BasicLandAttack', 'M3_QAI_NW_LandAttack_2',
        {
            MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
            PlatoonData = {
                AttackChains = defaultChains,
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('LightArtillery', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL, '>='})

    quantity = {4, 5, 6}
    trigger = {30, 25, 20}
    opai = QAIM3NorthWestBase:AddOpAI('BasicLandAttack', 'M3_QAI_NW_LandAttack_3',
        {
            MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
            PlatoonData = {
                AttackChains = defaultChains,
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('LightArtillery', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.DIRECTFIRE + categories.INDIRECTFIRE, '>='})

    quantity = {4, 5, 6}
    trigger = {8, 6, 4}
    opai = QAIM3NorthWestBase:AddOpAI('BasicLandAttack', 'M3_QAI_NW_LandAttack_4',
        {
            MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
            PlatoonData = {
                AttackChains = defaultChains,
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('MobileAntiAir', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE, '>='})

    quantity = {4, 5, 6}
    trigger = {20, 18, 16}
    opai = QAIM3NorthWestBase:AddOpAI('BasicLandAttack', 'M3_QAI_NW_LandAttack_5',
        {
            MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
            PlatoonData = {
                AttackChains = defaultChains,
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('HeavyTanks', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.MASSSTORAGE, '>='})
    opai:SetFormation('AttackFormation')

    quantity = {3, 4, 5}
    trigger = {16, 12, 8}
    opai = QAIM3NorthWestBase:AddOpAI('BasicLandAttack', 'M3_QAI_NW_LandAttack_6',
        {
            MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
            PlatoonData = {
                AttackChains = defaultChains,
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('MobileMissiles', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.DEFENSE - categories.TECH1, '>='})
    opai:SetFormation('AttackFormation')

    quantity = {3, 4, 5}
    trigger = {12, 10, 8}
    opai = QAIM3NorthWestBase:AddOpAI('BasicLandAttack', 'M3_QAI_NW_LandAttack_7',
        {
            MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
            PlatoonData = {
                AttackChains = defaultChains,
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('MobileFlak', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE - categories.TECH1, '>='})
    opai:SetFormation('AttackFormation')

    quantity = {1, 2, 3}
    trigger = {12, 10, 8}
    opai = QAIM3NorthWestBase:AddOpAI('BasicLandAttack', 'M3_QAI_NW_LandAttack_8',
        {
            MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
            PlatoonData = {
                AttackChains = defaultChains,
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('SiegeBots', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.TECH2 * categories.MASSEXTRACTION + categories.FACTORY, '>='})

    quantity = {8, 10, 12}
    trigger = {150, 140, 130}
    opai = QAIM3NorthWestBase:AddOpAI('BasicLandAttack', 'M3_QAI_NW_LandAttack_9',
        {
            MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
            PlatoonData = {
                AttackChains = defaultChains,
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('HeavyTanks', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL, '>='})
    opai:SetFormation('AttackFormation')

    quantity = {6, 8, 10}
    trigger = {25, 20, 15}
    opai = QAIM3NorthWestBase:AddOpAI('BasicLandAttack', 'M3_QAI_NW_LandAttack_10',
        {
            MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
            PlatoonData = {
                AttackChains = defaultChains,
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('MobileMissiles', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.DEFENSE - categories.TECH1, '>='})
    opai:SetFormation('AttackFormation')

    quantity = {3, 4, 6}
    trigger = {6, 5, 4}
    opai = QAIM3NorthWestBase:AddOpAI('BasicLandAttack', 'M3_QAI_NW_LandAttack_11',
        {
            MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
            PlatoonData = {
                AttackChains = defaultChains,
            },
            Priority = 140,
        }
    )
    opai:SetChildQuantity('SiegeBots', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.TECH3 - categories.ENGINEER, '>='})
    opai:SetFormation('AttackFormation')

    quantity = {2, 4, 6}
    trigger = {220, 200, 180}
    opai = QAIM3NorthWestBase:AddOpAI('BasicLandAttack', 'M3_QAI_NW_LandAttack_12',
        {
            MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
            PlatoonData = {
                AttackChains = defaultChains,
            },
            Priority = 140,
        }
    )
    opai:SetChildQuantity('HeavyBots', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL, '>='})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, 3, categories.TECH3, '>='})
    opai:SetFormation('AttackFormation')

    quantity = {3, 4, 5}
    trigger = {25, 21, 17}
    opai = QAIM3NorthWestBase:AddOpAI('BasicLandAttack', 'M3_QAI_NW_LandAttack_13',
        {
            MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
            PlatoonData = {
                AttackChains = defaultChains,
            },
            Priority = 140,
        }
    )
    opai:SetChildQuantity('MobileHeavyArtillery', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], (categories.DEFENSE - categories.TECH1) + categories.TECH3, '>='})
    opai:SetFormation('AttackFormation')

    quantity = {4, 6, 9}
    trigger = {30, 25, 20}
    opai = QAIM3NorthWestBase:AddOpAI('BasicLandAttack', 'M3_QAI_NW_LandAttack_14',
        {
            MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
            PlatoonData = {
                AttackChains = defaultChains,
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity('HeavyBots', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.TECH3 * categories.MOBILE, '>='})

    quantity = {2, 4, 6}
    trigger = {15, 12, 9}
    opai = QAIM3NorthWestBase:AddOpAI('BasicLandAttack', 'M3_QAI_NW_LandAttack_15',
        {
            MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
            PlatoonData = {
                AttackChains = defaultChains,
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity('HeavyMobileAntiAir', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.MOBILE * categories.AIR * categories.TECH3, '>='})
    opai:SetFormation('AttackFormation')
end

function QAIM3NorthWestBaseConditionalBuilds()
    -- Triggered by player starting to build experimentals
    local opai = nil
    local engineers = {2, 3, 4}

    if Difficulty <= 2 then
        -- Build one spider, either when players start to build their own experimental or when they have enough T3 land units
        opai = QAIM3NorthWestBase:AddOpAI('M3_NW_Spider_1',
            {
                Amount = 1,
                KeepAlive = true,
                PlatoonAIFunction = {ThisFile, 'AttackThenHunt'},
                PlatoonData = {
                    AttackChains = {
                        'M3_QAI_NW_Attack_Chain_1',
                        'M3_QAI_NW_Attack_Chain_2',
                        'M3_QAI_NW_Attack_Chain_3',
                    },
                },
                BuildCondition = {
                    {'/lua/editor/otherarmyunitcountbuildconditions.lua', 'FocusBrainBeingBuiltOrActiveCategoryCompare',
                        {1, {categories.EXPERIMENTAL}, '>='}},
                    {'/lua/editor/unitcountbuildconditions.lua', 'HaveLessThanUnitsWithCategory',
                        {1, categories.url0402}},
                },
                MaxAssist = engineers[Difficulty],
                Retry = true,
            }
        )

        trigger = {40, 32, 24}
        opai = QAIM3NorthWestBase:AddOpAI('M3_NW_Spider_2',
            {
                Amount = 1,
                KeepAlive = true,
                PlatoonAIFunction = {ThisFile, 'AttackThenHunt'},
                PlatoonData = {
                    AttackChains = {
                        'M3_QAI_NW_Attack_Chain_1',
                        'M3_QAI_NW_Attack_Chain_2',
                        'M3_QAI_NW_Attack_Chain_3',
                    },
                },
                BuildCondition = {
                    {'/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
                        {{'HumanPlayers'}, trigger[Difficulty], categories.TECH3 * categories.LAND * categories.MOBILE - categories.ENGINEER, '>='}},
                    {'/lua/editor/unitcountbuildconditions.lua', 'HaveLessThanUnitsWithCategory', {1, categories.url0402}},
                },
                MaxAssist = engineers[Difficulty],
                Retry = true,
            }
        )
    else
        -- Build one megalith, either when players start to build their own experimental or when they have enough T3 land units
        opai = QAIM3NorthWestBase:AddOpAI('M3_NW_Mega_1',
            {
                Amount = 1,
                KeepAlive = true,
                PlatoonAIFunction = {ThisFile, 'AttackThenHunt'},
                PlatoonData = {
                    AttackChains = {
                        'M3_QAI_NW_Attack_Chain_1',
                        'M3_QAI_NW_Attack_Chain_2',
                        'M3_QAI_NW_Attack_Chain_3',
                    },
                },
                BuildCondition = {
                    {'/lua/editor/otherarmyunitcountbuildconditions.lua', 'FocusBrainBeingBuiltOrActiveCategoryCompare',
                        {1, {categories.EXPERIMENTAL}, '>='}},
                    {'/lua/editor/unitcountbuildconditions.lua', 'HaveLessThanUnitsWithCategory',
                        {1, categories.xrl0403}},
                },
                MaxAssist = engineers[Difficulty],
                Retry = true,
            }
        )

        trigger = {45, 38, 30}
        opai = QAIM3NorthWestBase:AddOpAI('M3_NW_Mega_2',
            {
                Amount = 1,
                KeepAlive = true,
                PlatoonAIFunction = {ThisFile, 'AttackThenHunt'},
                PlatoonData = {
                    AttackChains = {
                        'M3_QAI_NW_Attack_Chain_1',
                        'M3_QAI_NW_Attack_Chain_2',
                        'M3_QAI_NW_Attack_Chain_3',
                    },
                },
                BuildCondition = {
                    {'/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
                        {{'HumanPlayers'}, trigger[Difficulty], categories.TECH3 * categories.LAND * categories.MOBILE - categories.ENGINEER, '>='}},
                    {'/lua/editor/unitcountbuildconditions.lua', 'HaveLessThanUnitsWithCategory', {1, categories.xrl0403}},
                },
                MaxAssist = engineers[Difficulty],
                Retry = true,
            }
        )
    end
end

-------------------------
-- QAI M3 South East Base
-------------------------
function QAIM3SouthEastBaseAI()
    QAIM3SouthEastBase:Initialize(ArmyBrains[QAI], 'M3_QAI_SE_Base', 'M3_QAI_SE_Base_Marker', 40, {M3_QAI_SE_1 = 100, M3_QAI_SE_Eng = 100})
    QAIM3SouthEastBase:StartNonZeroBase(2)
    QAIM3SouthEastBase:SetActive('AirScouting', true)

    ForkThread(SouthEastBaseExpandThread)

    QAIM3SouthEastBaseAirAttacks()
    QAIM3SouthEastBaseLandAttacks()
end

function SouthEastBaseExpandThread()
    QAIM3SouthEastBase:AddBuildGroup('M3_QAI_SE_Def_1', 90)
    WaitSeconds(3*60)
    QAIM3SouthEastBase:AddBuildGroup('M3_QAI_SE_2', 80)
    WaitSeconds(3*60)
    QAIM3SouthEastBase:AddBuildGroup('M3_QAI_SE_Def_2', 70)
    WaitSeconds(3*60)
    QAIM3SouthEastBase:AddBuildGroup('M3_QAI_SE_3', 60)
    WaitSeconds(2*60)
    QAIM3SouthEastBase:AddBuildGroup('M3_QAI_SE_Def_3', 50)
end

function QAIM3SouthEastBaseAirAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}
    local defaultChains =  {
        'M3_QAI_SE_Attack_Chain_1',
        'M3_QAI_SE_Attack_Chain_2',
        'M3_QAI_SE_Attack_Chain_3',
    }

    trigger = {50, 40, 30}
    opai = QAIM3SouthEastBase:AddOpAI('AirAttacks', 'M3_QAI_SE_AirAttack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'SplitPatrolThread'},
            PlatoonData = {
                PatrolChains = defaultChains,
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity(attackAirUnit, 3)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.ENERGYPRODUCTION * categories.STRUCTURE, '>='})

    trigger = {70, 60, 50}
    opai = QAIM3SouthEastBase:AddOpAI('AirAttacks', 'M3_QAI_SE_AirAttack_2',
        {
            MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
            PlatoonData = {
                AttackChains = defaultChains,
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity(attackAirUnit, 3)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL, '>='})

    quantity = {2, 3, 4}
    trigger = {10, 8, 5}
    opai = QAIM3SouthEastBase:AddOpAI('AirAttacks', 'M3_QAI_SE_AirAttack_3',
        {
            MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
            PlatoonData = {
                AttackChains = defaultChains,
                CategoryList = {
                    categories.AIR,
                    categories.ALLUNITS - categories.WALL,
                },
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Interceptors', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE, '>='})

    trigger = {110, 100, 90}
    opai = QAIM3SouthEastBase:AddOpAI('AirAttacks', 'M3_QAI_SE_AirAttack_4',
        {
            MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
            PlatoonData = {
                AttackChains = defaultChains,
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Gunships', 3)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL, '>='})

    trigger = {60, 50, 40}
    opai = QAIM3SouthEastBase:AddOpAI('AirAttacks', 'M3_QAI_SE_AirAttack_5',
        {
            MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
            PlatoonData = {
                AttackChains = defaultChains,
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('FighterBombers', 3)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.LAND * categories.MOBILE, '>='})

    quantity = {4, 5, 6}
    trigger = {6, 4, 2}
    opai = QAIM3SouthEastBase:AddOpAI('AirAttacks', 'M3_QAI_SE_AirAttack_6',
        {
            MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
            PlatoonData = {
                AttackChains = defaultChains,
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.ENERGYPRODUCTION * categories.STRUCTURE - categories.TECH1, '>='})

    quantity = {4, 5, 6}
    trigger = {25, 20, 15}
    opai = QAIM3SouthEastBase:AddOpAI('AirAttacks', 'M3_QAI_SE_AirAttack_7',
        {
            MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
            PlatoonData = {
                AttackChains = defaultChains,
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('FighterBombers', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.DEFENSE, '>='})

    quantity = {6, 8, 10}
    trigger = {25, 20, 15}
    opai = QAIM3SouthEastBase:AddOpAI('AirAttacks', 'M3_QAI_SE_AirAttack_8',
        {
            MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
            PlatoonData = {
                AttackChains = defaultChains,
                CategoryList = {
                    categories.AIR,
                    categories.ALLUNITS - categories.WALL,
                },
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('Interceptors', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE - categories.TECH1, '>='})

    quantity = {6, 9, 12}
    trigger = {250, 225, 200}
    opai = QAIM3SouthEastBase:AddOpAI('AirAttacks', 'M3_QAI_SE_AirAttack_9',
        {
            MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
            PlatoonData = {
                AttackChains = defaultChains,
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL, '>='})

    quantity = {6, 9, 12}
    trigger = {16, 14, 12}
    opai = QAIM3SouthEastBase:AddOpAI('AirAttacks', 'M3_QAI_SE_AirAttack_10',
        {
            MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
            PlatoonData = {
                AttackChains = defaultChains,
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('FighterBombers', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.TECH3, '>='})

    --[[
    -- Send 3, 3, 6 Interceptors if player has more than 80, 70, 60 units
    quantity = {3, 3, 6}
    trigger = {8, 6, 4}
    opai = QAIM3SouthEastBase:AddOpAI('AirAttacks', 'M3_QAI_SE_AirAttack_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = defaultChains,
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Bombers', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE, '>='})
    --]]
end

function QAIM3SouthEastBaseLandAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}
    local defaultChains =  {
        'M3_QAI_SE_Attack_Chain_1',
        'M3_QAI_SE_Attack_Chain_2',
        'M3_QAI_SE_Attack_Chain_3',
    }

    -- Engineer for reclaiming if there's less than 2000 Mass in the storage, starting after 5 minutes
    quantity = {3, 4, 6}
    opai = QAIM3SouthEastBase:AddOpAI('EngineerAttack', 'M3_QAI_SE_Reclaim_Engineers',
        {
            MasterPlatoonFunction = {SPAIFileName, 'SplitPatrolThread'},
            PlatoonData = {
                PatrolChains = defaultChains,
            },
            Priority = 200,
        }
    )
    opai:SetChildQuantity('T1Engineers', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/economybuildconditions.lua', 'LessThanMassStorageCurrent', {1000})

    ----------
    -- Attacks
    ----------
    -- Sends 6 LABs
    quantity = {4, 5, 6}
    opai = QAIM3SouthEastBase:AddOpAI('BasicLandAttack', 'M3_QAI_SE_LandAttack_1',
        {
            MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
            PlatoonData = {
                AttackChains = defaultChains,
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('LightBots', quantity[Difficulty])

    -- Sends 3, 6, 9 Atry if player has more than 3 factories
    quantity = {4, 6, 9}
    opai = QAIM3SouthEastBase:AddOpAI('BasicLandAttack', 'M3_QAI_SE_LandAttack_2',
        {
            MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
            PlatoonData = {
                AttackChains = defaultChains,
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('LightArtillery', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, 3, categories.FACTORY, '>='})
    opai:SetFormation('AttackFormation')

    trigger = {70, 60, 50}
    opai = QAIM3SouthEastBase:AddOpAI('BasicLandAttack', 'M3_QAI_SE_LandAttack_3',
        {
            MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
            PlatoonData = {
                AttackChains = defaultChains,
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('HeavyTanks', 3)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.ENGINEER - categories.WALL, '>='})

    if Difficulty >= 2 then
        quantity = {0, 1, 2}
        trigger = {0, 140, 120}
        opai = QAIM3SouthEastBase:AddOpAI('BasicLandAttack', 'M3_QAI_SE_LandAttack_4',
            {
                MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
                PlatoonData = {
                    AttackChains = defaultChains,
                },
                Priority = 130,
            }
        )
        opai:SetChildQuantity('SiegeBots', quantity[Difficulty])
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
            'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL, '>='})
    end

    quantity = {3, 4, 5}
    trigger = {50, 45, 40}
    opai = QAIM3SouthEastBase:AddOpAI('BasicLandAttack', 'M3_QAI_SE_LandAttack_5',
        {
            MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
            PlatoonData = {
                AttackChains = defaultChains,
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('RangedBots', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.LAND * categories.MOBILE - categories.ENGINEER, '>='})
    opai:SetFormation('AttackFormation')

    quantity = {4, 5, 6}
    trigger = {16, 14, 12}
    opai = QAIM3SouthEastBase:AddOpAI('BasicLandAttack', 'M3_QAI_SE_LandAttack_6',
        {
            MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
            PlatoonData = {
                AttackChains = defaultChains,
            },
            Priority = 140,
        }
    )
    opai:SetChildQuantity('MobileMissiles', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.DEFENSE - categories.TECH1, '>='})
    opai:SetFormation('AttackFormation')

    quantity = {3, 4, 5}
    trigger = {20, 17, 14}
    opai = QAIM3SouthEastBase:AddOpAI('BasicLandAttack', 'M3_QAI_SE_LandAttack_7',
        {
            MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
            PlatoonData = {
                AttackChains = defaultChains,
            },
            Priority = 140,
        }
    )
    opai:SetChildQuantity('MobileFlak', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE, '>='})
    opai:SetFormation('AttackFormation')

    quantity = {8, 10, 12}
    trigger = {22, 18, 14}
    opai = QAIM3SouthEastBase:AddOpAI('BasicLandAttack', 'M3_QAI_SE_LandAttack_8',
        {
            MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
            PlatoonData = {
                AttackChains = defaultChains,
            },
            Priority = 140,
        }
    )
    opai:SetChildQuantity('HeavyTanks', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.TECH2 * categories.STRUCTURE, '>='})
    opai:SetFormation('AttackFormation')

    quantity = {4, 5, 6}
    trigger = {160, 150, 140}
    opai = QAIM3SouthEastBase:AddOpAI('BasicLandAttack', 'M3_QAI_SE_LandAttack_9',
        {
            MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
            PlatoonData = {
                AttackChains = defaultChains,
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity('SiegeBots', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL, '>='})
    opai:SetFormation('AttackFormation')

    quantity = {4, 6, 8}
    trigger = {10, 8, 6}
    opai = QAIM3SouthEastBase:AddOpAI('BasicLandAttack', 'M3_QAI_SE_LandAttack_10',
        {
            MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
            PlatoonData = {
                AttackChains = defaultChains,
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity({'HeavyBots', 'MobileFlak'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.TECH3, '>='})

    quantity = {3, 4, 6}
    trigger = {16, 14, 12}
    opai = QAIM3SouthEastBase:AddOpAI('BasicLandAttack', 'M3_QAI_SE_LandAttack_11',
        {
            MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
            PlatoonData = {
                AttackChains = defaultChains,
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity('MobileHeavyArtillery', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.TECH3, '>='})
    opai:SetFormation('AttackFormation')

    quantity = {9, 12, 15}
    trigger = {30, 25, 20}
    opai = QAIM3SouthEastBase:AddOpAI('BasicLandAttack', 'M3_QAI_SE_LandAttack_12',
        {
            MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
            PlatoonData = {
                AttackChains = defaultChains,
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity('MobileMissiles', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.DEFENSE - categories.TECH1, '>='})
    opai:SetFormation('AttackFormation')

    quantity = {6, 9, 12}
    trigger = {50, 40, 30}
    opai = QAIM3SouthEastBase:AddOpAI('BasicLandAttack', 'M3_QAI_SE_LandAttack_13',
        {
            MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
            PlatoonData = {
                AttackChains = defaultChains,
            },
            Priority = 160,
        }
    )
    opai:SetChildQuantity('HeavyBots', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.TECH3 * categories.MOBILE + (categories.DEFENSE - categories.TECH1), '>='})
    opai:SetFormation('AttackFormation')

    if Difficulty >= 2 then
        quantity = {0, 1, 2}
        trigger = {0, 2, 1}
        opai = QAIM3SouthEastBase:AddOpAI('BasicLandAttack', 'M3_QAI_SE_LandAttack_14',
            {
                MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
                PlatoonData = {
                    AttackChains = defaultChains,
                },
                Priority = 140,
            }
        )
        opai:SetChildQuantity('MobileHeavyArtillery', quantity[Difficulty])
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
            'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.TACTICALMISSILEPLATFORM, '>='})
    end

    --[[
    -- Sends 3, 6, 9 Mantis if player has more than 8, 10, 12 units
    quantity = {3, 6, 9}
    trigger = {8, 10, 12}
    opai = QAIM3SouthEastBase:AddOpAI('BasicLandAttack', 'M3_QAI_SE_LandAttack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = defaultChains,
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('HeavyBots', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL, '>='})
    --]]
end

-------------------------
-- QAI M3 South West Base
-------------------------
function QAIM3SouthWestBaseAI()
    QAIM3SouthWestBase:Initialize(ArmyBrains[QAI], 'M3_QAI_SW_Base', 'M3_QAI_SW_Base_Marker', 30, {M3_QAI_SW_1 = 100, M3_QAI_SW_Eng = 100})
    QAIM3SouthWestBase:StartNonZeroBase({5, 2})

    ForkThread(SouthWestBaseExpandThread)

    QAIM3SouthWestBaseLandAttacks()
end

function SouthWestBaseExpandThread()
    QAIM3SouthWestBase:AddBuildGroup('M3_QAI_SW_2', 90)
    QAIM3SouthWestBase:AddBuildGroup('M3_QAI_SW_3', 80)
    QAIM3SouthWestBase:AddBuildGroup('M3_QAI_SW_4', 70)
    --WaitSeconds(18*60)
    QAIM3SouthWestBase:AddBuildGroup('M3_QAI_NW_Arty', 60)
end

function QAIM3SouthWestBaseLandAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}
    local defaultChains =  {
        'M3_QAI_SW_Attack_Chain_1',
        'M3_QAI_SW_Attack_Chain_2',
        'M3_QAI_SW_Attack_Chain_3',
    }

    -- Engineer for reclaiming if there's less than 2000 Mass in the storage, starting after 5 minutes
    quantity = {3, 4, 6}
    opai = QAIM3SouthEastBase:AddOpAI('EngineerAttack', 'M3_QAI_SW_Reclaim_Engineers',
        {
            MasterPlatoonFunction = {SPAIFileName, 'SplitPatrolThread'},
            PlatoonData = {
                PatrolChains = defaultChains,
            },
            Priority = 200,
        }
    )
    opai:SetChildQuantity('T1Engineers', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/economybuildconditions.lua', 'LessThanMassStorageCurrent', {500})

    ----------
    -- Attacks
    ----------
    quantity = {3, 4, 5}
    opai = QAIM3SouthWestBase:AddOpAI('BasicLandAttack', 'M3_QAI_SW_LandAttack_1',
        {
            MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
            PlatoonData = {
                AttackChains = defaultChains,
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('HeavyBots', quantity[Difficulty])

    quantity = {3, 4, 5}
    trigger = {8, 7, 6}
    opai = QAIM3SouthWestBase:AddOpAI('BasicLandAttack', 'M3_QAI_SW_LandAttack_2',
        {
            MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
            PlatoonData = {
                AttackChains = defaultChains,
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('LightArtillery', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.FACTORY, '>='})

    quantity = {3, 4, 5}
    trigger = {6, 5, 4}
    opai = QAIM3SouthWestBase:AddOpAI('BasicLandAttack', 'M3_QAI_SW_LandAttack_3',
        {
            MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
            PlatoonData = {
                AttackChains = defaultChains,
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('MobileAntiAir', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE, '>='})

    quantity = {1, 2, 3}
    trigger = {85, 75, 65}
    opai = QAIM3SouthWestBase:AddOpAI('BasicLandAttack', 'M3_QAI_SW_LandAttack_4',
        {
            MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
            PlatoonData = {
                AttackChains = defaultChains,
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('HeavyTanks', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL, '>='})

    quantity = {6, 8, 10}
    trigger = {20, 15, 10}
    opai = QAIM3SouthWestBase:AddOpAI('BasicLandAttack', 'M3_QAI_SW_LandAttack_5',
        {
            MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
            PlatoonData = {
                AttackChains = defaultChains,
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('HeavyBots', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.TECH2, '>='})
    opai:SetFormation('AttackFormation')

    quantity = {6, 8, 10}
    trigger = {90, 80, 70}
    opai = QAIM3SouthWestBase:AddOpAI('BasicLandAttack', 'M3_QAI_SW_LandAttack_6',
        {
            MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
            PlatoonData = {
                AttackChains = defaultChains,
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('LightArtillery', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL, '>='})
    opai:SetFormation('AttackFormation')

    quantity = {4, 5, 6}
    trigger = {140, 130, 120}
    opai = QAIM3SouthWestBase:AddOpAI('BasicLandAttack', 'M3_QAI_SW_LandAttack_7',
        {
            MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
            PlatoonData = {
                AttackChains = defaultChains,
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('HeavyTanks', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL, '>='})
    opai:SetFormation('AttackFormation')

    quantity = {3, 5, 7}
    trigger = {20, 18, 16}
    opai = QAIM3SouthWestBase:AddOpAI('BasicLandAttack', 'M3_QAI_SW_LandAttack_8',
        {
            MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
            PlatoonData = {
                AttackChains = defaultChains,
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('MobileMissiles', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.DEFENSE - categories.TECH1, '>='})
    opai:SetFormation('AttackFormation')

    quantity = {4, 5, 6}
    trigger = {40, 35, 30}
    opai = QAIM3SouthWestBase:AddOpAI('BasicLandAttack', 'M3_QAI_SW_LandAttack_9',
        {
            MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
            PlatoonData = {
                AttackChains = defaultChains,
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('RangedBots', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.LAND * categories.MOBILE - categories.TECH1, '>='})
    opai:SetFormation('AttackFormation')

    quantity = {4, 5, 6}
    trigger = {25, 20, 15}
    opai = QAIM3SouthWestBase:AddOpAI('BasicLandAttack', 'M3_QAI_SW_LandAttack_10',
        {
            MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
            PlatoonData = {
                AttackChains = defaultChains,
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('MobileFlak', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE - categories.TECH1, '>='})
    opai:SetFormation('AttackFormation')

    quantity = {6, 12, 18}
    trigger = {250, 230, 210}
    opai = QAIM3SouthWestBase:AddOpAI('BasicLandAttack', 'M3_QAI_SW_LandAttack_11',
        {
            MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
            PlatoonData = {
                AttackChains = defaultChains,
            },
            Priority = 140,
        }
    )
    opai:SetChildQuantity('HeavyTanks', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL, '>='})
    opai:SetFormation('AttackFormation')

    if Difficulty >= 2 then
        quantity = {0, 6, 8}
        trigger = {0, 2, 1}
        opai = QAIM3SouthWestBase:AddOpAI('BasicLandAttack', 'M3_QAI_SW_LandAttack_12',
            {
                MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
                PlatoonData = {
                    AttackChains = defaultChains,
                },
                Priority = 140,
            }
        )
        opai:SetChildQuantity('MobileMissiles', quantity[Difficulty])
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
            'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.TACTICALMISSILEPLATFORM, '>='})
    end
end

-------------------
-- QAI M3 West Base
-------------------
function QAIM3WestBaseAI(plan)
    if plan == 'push' then
        QAIM3WestBase:InitializeDifficultyTables(ArmyBrains[QAI], 'M3_QAI_W_Base', 'M3_QAI_West_Base_Marker', 40, {M3_QAI_W_First = 105, M3_QAI_W = 100})
        QAIM3WestBase:StartEmptyBase(8, 4)
        QAIM3WestBase:SetMaximumConstructionEngineers(4)
        -- 'East' AA position (from the plateau view) in the 'West' base (from the player's view), great naming, but whatever! 
        QAIM3WestBase:AddBuildGroup('M3_Plateau_AA_Positions_East', 110)
        QAIM3ExperimentalBase:AddExpansionBase('M3_QAI_W_Base', 2)
    else
        QAIM3WestBase:InitializeDifficultyTables(ArmyBrains[QAI], 'M3_QAI_W_Base', 'M3_QAI_West_Base_Marker', 40, {M3_QAI_W_First = 105, M3_QAI_W = 100})
        QAIM3WestBase:StartNonZeroBase({5, 3})
    end

    QAIM3WestBaseAirAttacks(plan)
    QAIM3WestBaseLandAttacks(plan)
end

function QAIM3WestBaseAirAttacks(plan)
    local opai = nil
    local quantity = {}
    local trigger = {}
    local defaultChains =  {
        'M3_QAI_W_Air_Attack_Chain_1',
        'M3_QAI_W_Air_Attack_Chain_2',
    }

    -- Transport builder
    opai = QAIM3WestBase:AddOpAI('EngineerAttack', 'M3_QAI_N_TransportBuilder',
        {
            MasterPlatoonFunction = {SPAIFileName, 'TransportPool'},
            PlatoonData = {
                TransportMoveLocation = 'M3_QAI_Plateau_Transport_Return',
            },
            Priority = 1000,
        }
    )
    opai:SetChildQuantity('T2Transports', 3)
    opai:SetLockingStyle('None')
    opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
        'HaveLessThanUnitsWithCategory', {3, categories.ura0104})

    if plan == 'push' then
        quantity = {4, 5, 6}
        opai = QAIM3WestBase:AddOpAI('AirAttacks', 'M3_QAI_W_AirAttack_To_Loyalist_1',
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M3_QAI_West_Base_To_Loyalist_Attack_Chain',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('Bombers', quantity[Difficulty])
        opai:SetFormation('NoFormation')

        quantity = {3, 5, 8}
        opai = QAIM3WestBase:AddOpAI('AirAttacks', 'M3_QAI_W_AirAttack_To_Loyalist_2',
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M3_QAI_West_Base_To_Loyalist_Attack_Chain',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('Interceptors', quantity[Difficulty])

        quantity = {3, 4, 5}
        opai = QAIM3WestBase:AddOpAI('AirAttacks', 'M3_QAI_W_AirAttack_To_Loyalist_3',
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M3_QAI_West_Base_To_Loyalist_Attack_Chain',
                },
                Priority = 110,
            }
        )
        opai:SetChildQuantity('Gunships', quantity[Difficulty])

        quantity = {2, 2, 3}
        opai = QAIM3WestBase:AddOpAI('AirAttacks', 'M3_QAI_W_AirAttack_To_Loyalist_4',
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M3_QAI_West_Base_To_Loyalist_Attack_Chain',
                },
                Priority = 110,
            }
        )
        opai:SetChildQuantity('CombatFighters', quantity[Difficulty])
        opai:SetFormation('NoFormation')
    end

    -----------------
    -- Attack players
    -----------------
    opai = QAIM3WestBase:AddOpAI('AirAttacks', 'M3_QAI_W_AirAttack_To_Player_1',
        {
            MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
            PlatoonData = {
                AttackChains = defaultChains,
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity(attackAirUnit, 2)

    trigger = {120, 100, 80}
    opai = QAIM3WestBase:AddOpAI('AirAttacks', 'M3_QAI_W_AirAttack_To_Player_2',
        {
            MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
            PlatoonData = {
                AttackChains = defaultChains,
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity(attackAirUnit, 4)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL, '>='})

    quantity = {2, 3, 4}
    trigger = {12, 10, 8}
    opai = QAIM3WestBase:AddOpAI('AirAttacks', 'M3_QAI_W_AirAttack_To_Player_3',
        {
            MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
            PlatoonData = {
                AttackChains = defaultChains,
                CategoryList = {
                    categories.AIR,
                    categories.ALLUNITS - categories.WALL,
                },
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Interceptors', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE, '>='})

    quantity = {4, 5, 6}
    trigger = {50, 40, 30}
    opai = QAIM3WestBase:AddOpAI('AirAttacks', 'M3_QAI_W_AirAttack_To_Player_4',
        {
            MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
            PlatoonData = {
                AttackChains = defaultChains,
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.DIRECTFIRE + categories.INDIRECTFIRE, '>='})

    quantity = {4, 6, 8}
    trigger = {20, 15, 10}
    opai = QAIM3WestBase:AddOpAI('AirAttacks', 'M3_QAI_W_AirAttack_To_Player_5',
        {
            MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
            PlatoonData = {
                AttackChains = defaultChains,
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.TECH2 * categories.MOBILE - categories.ENGINEER, '>='})

    quantity = {2, 4, 6}
    trigger = {9, 6, 3}
    opai = QAIM3WestBase:AddOpAI('AirAttacks', 'M3_QAI_W_AirAttack_To_Player_6',
        {
            MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
            PlatoonData = {
                AttackChains = defaultChains,
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('FighterBombers', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.SHIELD, '>='})

    quantity = {6, 9, 12}
    trigger = {35, 30, 25}
    opai = QAIM3WestBase:AddOpAI('AirAttacks', 'M3_QAI_W_AirAttack_To_Player_7',
        {
            MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
            PlatoonData = {
                AttackChains = defaultChains,
                CategoryList = {
                    categories.AIR,
                    categories.ALLUNITS - categories.WALL,
                },
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('Interceptors', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE, '>='})

    quantity = {4, 6, 8}
    trigger = {12, 10, 8}
    opai = QAIM3WestBase:AddOpAI('AirAttacks', 'M3_QAI_W_AirAttack_To_Player_8',
        {
            MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
            PlatoonData = {
                AttackChains = defaultChains,
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity({'Gunships', 'Bombers'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.ANTIAIR * categories.STRUCTURE - categories.TECH1, '>='})
end

function QAIM3WestBaseLandAttacks(plan)
    local opai = nil
    local quantity = {}
    local trigger = {}

    if plan == 'push' then
        quantity = {6, 9, 12}
        opai = QAIM3WestBase:AddOpAI('BasicLandAttack', 'M3_QAI_W_LandAttack_To_Loyalist_1',
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M3_QAI_West_Base_To_Loyalist_Attack_Chain',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('LightArtillery', quantity[Difficulty])
        opai:SetFormation('AttackFormation')

        quantity = {6, 8, 10}
        opai = QAIM3WestBase:AddOpAI('BasicLandAttack', 'M3_QAI_W_LandAttack_To_Loyalist_2',
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M3_QAI_West_Base_To_Loyalist_Attack_Chain',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('HeavyTanks', quantity[Difficulty])
        opai:SetFormation('AttackFormation')

        quantity = {2, 3, 5}
        opai = QAIM3WestBase:AddOpAI('BasicLandAttack', 'M3_QAI_W_LandAttack_To_Loyalist_3',
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M3_QAI_West_Base_To_Loyalist_Attack_Chain',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('MobileMissiles', quantity[Difficulty])

        quantity = {2, 4, 6}
        opai = QAIM3WestBase:AddOpAI('BasicLandAttack', 'M3_QAI_W_LandAttack_To_Loyalist_4',
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M3_QAI_West_Base_To_Loyalist_Attack_Chain',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('MobileFlak', quantity[Difficulty])

        quantity = {3, 5, 7}
        opai = QAIM3WestBase:AddOpAI('BasicLandAttack', 'M3_QAI_W_LandAttack_To_Loyalist_5',
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M3_QAI_West_Base_To_Loyalist_Attack_Chain',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('RangedBots', quantity[Difficulty])
        opai:SetFormation('AttackFormation')
    end

    --------
    -- Drops
    --------
    trigger = {90, 80, 60}
    opai = QAIM3WestBase:AddOpAI('BasicLandAttack', 'M3_QAI_W_TransportAttack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain = 'M3_QAI_West_Transport_Attack_Chain',
                LandingChain = 'M3_QAI_West_Landing_Chain',
                TransportReturn = 'M3_QAI_Plateau_Transport_Return',
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity('LightArtillery', 8)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL, '>='})

    trigger = {120, 110, 100}
    opai = QAIM3WestBase:AddOpAI('BasicLandAttack', 'M3_QAI_W_TransportAttack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain = 'M3_QAI_West_Transport_Attack_Chain',
                LandingChain = 'M3_QAI_West_Landing_Chain',
                TransportReturn = 'M3_QAI_Plateau_Transport_Return',
            },
            Priority = 160,
        }
    )
    opai:SetChildQuantity('HeavyTanks', 4)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL, '>='})

    quantity = {4, 6, 8}
    trigger = {150, 140, 130}
    opai = QAIM3WestBase:AddOpAI('BasicLandAttack', 'M3_QAI_W_TransportAttack_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain = 'M3_QAI_West_Transport_Attack_Chain',
                LandingChain = 'M3_QAI_West_Landing_Chain',
                TransportReturn = 'M3_QAI_Plateau_Transport_Return',
            },
            Priority = 160,
        }
    )
    opai:SetChildQuantity('HeavyTanks', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL, '>='})

    quantity = {3, 6, 9}
    trigger = {8, 6, 4}
    opai = QAIM3WestBase:AddOpAI('BasicLandAttack', 'M3_QAI_W_TransportAttack_4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain = 'M3_QAI_West_Transport_Attack_Chain',
                LandingChain = 'M3_QAI_West_Landing_Chain',
                TransportReturn = 'M3_QAI_Plateau_Transport_Return',
            },
            Priority = 170,
        }
    )
    opai:SetChildQuantity({'SiegeBots', 'MobileStealth', 'LightBots'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.TECH3, '>='})
end

-------------------
-- QAI M3 Main Base
-------------------
function QAIM3MainBaseAI()
    QAIM3MainBase:InitializeDifficultyTables(ArmyBrains[QAI], 'M3_QAI_Main_Base', 'M3_QAI_Main_Base_Marker', 40, {M3_Main_Base = 100, M3_Main_Base_Side = 90})
    QAIM3MainBase:StartNonZeroBase({{6, 8, 11}, {5, 6, 8}})

    QAIM3MainBaseAirAttacks()
    QAIM3MainBaseLandAttacks()
    QAIM3MainBaseConditionalBuilds()
end

function QAIM3MainBaseAirAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    quantity = {4, 5, 6}
    opai = QAIM3MainBase:AddOpAI('AirAttacks', 'M3_QAI_M_AirAttack_To_Loyalist_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M3_QAI_M_Base_To_Loyalist_Land_Attack_Chain_1',
                    'M3_QAI_M_Base_To_Loyalist_Land_Attack_Chain_2',
                },
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Bombers', quantity[Difficulty])
    opai:SetFormation('NoFormation')

    quantity = {5, 7, 9}
    opai = QAIM3MainBase:AddOpAI('AirAttacks', 'M3_QAI_M_AirAttack_To_Loyalist_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M3_QAI_M_Base_To_Loyalist_Land_Attack_Chain_1',
                    'M3_QAI_M_Base_To_Loyalist_Land_Attack_Chain_2',
                },
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Interceptors', quantity[Difficulty])

    quantity = {4, 6, 9}
    opai = QAIM3MainBase:AddOpAI('AirAttacks', 'M3_QAI_M_AirAttack_To_Loyalist_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M3_QAI_M_Base_To_Loyalist_Land_Attack_Chain_1',
                    'M3_QAI_M_Base_To_Loyalist_Land_Attack_Chain_2',
                },
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])

    quantity = {2, 4, 6}
    opai = QAIM3MainBase:AddOpAI('AirAttacks', 'M3_QAI_M_AirAttack_To_Loyalist_4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M3_QAI_M_Base_To_Loyalist_Land_Attack_Chain_1',
                    'M3_QAI_M_Base_To_Loyalist_Land_Attack_Chain_2',
                },
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('CombatFighters', quantity[Difficulty])
    opai:SetFormation('NoFormation')

    quantity = {9, 9, 9}
    opai = QAIM3MainBase:AddOpAI('AirAttacks', 'M3_QAI_M_AirAttack_To_Loyalist_5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M3_QAI_M_Base_To_Loyalist_Land_Attack_Chain_1',
                    'M3_QAI_M_Base_To_Loyalist_Land_Attack_Chain_2',
                },
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity({'HeavyGunships', 'Gunships', 'Bombers'}, quantity[Difficulty])
    opai:SetFormation('NoFormation')
end

function QAIM3MainBaseLandAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    -- Reclaiming Engineers
    quantity = {6, 5, 4}
    opai = QAIM3MainBase:AddOpAI('EngineerAttack', 'M3_QAI_M_Reclaim_Engineers_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_QAI_Main_Base_EngineerChain',
            },
            Priority = 200,
        })
    opai:SetChildQuantity('T1Engineers', quantity[Difficulty])
    opai:SetFormation('NoFormation')
    opai:AddBuildCondition('/lua/editor/economybuildconditions.lua',
        'LessThanMassStorageCurrent', {8000})

    quantity = {6, 8, 10}
    opai = QAIM3MainBase:AddOpAI('EngineerAttack', 'M3_QAI_M_Reclaim_Engineers_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'SplitPatrolThread'},
            PlatoonData = {
                PatrolChains = {
                    'M3_QAI_M_Base_To_Loyalist_Land_Attack_Chain_1',
                    'M3_QAI_M_Base_To_Loyalist_Land_Attack_Chain_2',
                },
            },
            Priority = 190,
        })
    opai:SetChildQuantity('T1Engineers', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/economybuildconditions.lua',
        'LessThanMassStorageCurrent', {5000})

    -- Attack Loyalist
    quantity = {6, 8, 10}
    opai = QAIM3MainBase:AddOpAI('BasicLandAttack', 'M3_QAI_M_LandAttack_To_Loyalist_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M3_QAI_M_Base_To_Loyalist_Land_Attack_Chain_1',
                    'M3_QAI_M_Base_To_Loyalist_Land_Attack_Chain_2',
                },
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('HeavyTanks', quantity[Difficulty])

    quantity = {6, 6, 9}
    opai = QAIM3MainBase:AddOpAI('BasicLandAttack', 'M3_QAI_M_LandAttack_To_Loyalist_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M3_QAI_M_Base_To_Loyalist_Land_Attack_Chain_1',
                    'M3_QAI_M_Base_To_Loyalist_Land_Attack_Chain_2',
                },
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity({'SiegeBots', 'HeavyTanks', 'LightBots'}, quantity[Difficulty])

    quantity = {3, 4, 6}
    opai = QAIM3MainBase:AddOpAI('BasicLandAttack', 'M3_QAI_M_LandAttack_To_Loyalist_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M3_QAI_M_Base_To_Loyalist_Land_Attack_Chain_1',
                    'M3_QAI_M_Base_To_Loyalist_Land_Attack_Chain_2',
                },
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('MobileMissiles', quantity[Difficulty])

    quantity = {6, 6, 9}
    opai = QAIM3MainBase:AddOpAI('BasicLandAttack', 'M3_QAI_M_LandAttack_To_Loyalist_4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M3_QAI_M_Base_To_Loyalist_Land_Attack_Chain_1',
                    'M3_QAI_M_Base_To_Loyalist_Land_Attack_Chain_2',
                },
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity({'SiegeBots', 'MobileStealth', 'LightBots'}, quantity[Difficulty])

    quantity = {6, 6, 9}
    opai = QAIM3MainBase:AddOpAI('BasicLandAttack', 'M3_QAI_M_LandAttack_To_Loyalist_5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M3_QAI_M_Base_To_Loyalist_Land_Attack_Chain_1',
                    'M3_QAI_M_Base_To_Loyalist_Land_Attack_Chain_2',
                },
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity({'SiegeBots', 'HeavyTanks', 'HeavyBots'}, quantity[Difficulty])

    quantity = {6, 6, 6}
    opai = QAIM3MainBase:AddOpAI('BasicLandAttack', 'M3_QAI_M_LandAttack_To_Loyalist_6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M3_QAI_M_Base_To_Loyalist_Land_Attack_Chain_1',
                    'M3_QAI_M_Base_To_Loyalist_Land_Attack_Chain_2',
                },
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity({'HeavyTanks', 'HeavyBots'}, quantity[Difficulty])

    quantity = {6, 6, 6}
    opai = QAIM3MainBase:AddOpAI('BasicLandAttack', 'M3_QAI_M_LandAttack_To_Loyalist_7',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M3_QAI_M_Base_To_Loyalist_Land_Attack_Chain_1',
                    'M3_QAI_M_Base_To_Loyalist_Land_Attack_Chain_2',
                },
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity({'HeavyBots', 'MobileFlak'}, quantity[Difficulty])

    quantity = {2, 2, 3}
    opai = QAIM3MainBase:AddOpAI('BasicLandAttack', 'M3_QAI_M_LandAttack_To_Loyalist_8',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M3_QAI_M_Base_To_Loyalist_Land_Attack_Chain_1',
                    'M3_QAI_M_Base_To_Loyalist_Land_Attack_Chain_2',
                },
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('MobileHeavyArtillery', quantity[Difficulty])

    -- Attack Player
    -- M3_QAI_M_Base_To_Player_Land_Attack_Chain_1
    ---[[
    quantity = {5, 10, 15}
    trigger = {270, 250, 230}
    opai = QAIM3MainBase:AddOpAI('BasicLandAttack', 'M3_QAI_M_LandAttack_To_Player_1',
        {
            MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
            PlatoonData = {
                AttackChain = 'M3_QAI_M_Base_To_Player_Land_Attack_Chain_1',
            },
            Priority = 140,
        }
    )
    opai:SetChildQuantity('HeavyTanks', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL, '>='})
    opai:SetFormation('AttackFormation')

    quantity = {6, 8, 10}
    trigger = {250, 230, 210}
    opai = QAIM3MainBase:AddOpAI('BasicLandAttack', 'M3_QAI_M_LandAttack_To_Player_2',
        {
            MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
            PlatoonData = {
                AttackChain = 'M3_QAI_M_Base_To_Player_Land_Attack_Chain_1',
            },
            Priority = 140,
        }
    )
    opai:SetChildQuantity('RangedBots', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL, '>='})
    opai:SetFormation('AttackFormation')

    quantity = {4, 6, 8}
    trigger = {60, 50, 40}
    opai = QAIM3MainBase:AddOpAI('BasicLandAttack', 'M3_QAI_M_LandAttack_To_Player_3',
        {
            MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
            PlatoonData = {
                AttackChain = 'M3_QAI_M_Base_To_Player_Land_Attack_Chain_1',
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity('SiegeBots', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.LAND * categories.MOBILE - categories.TECH1, '>='})
    opai:SetFormation('AttackFormation')

    quantity = {5, 7, 10}
    trigger = {25, 20, 15}
    opai = QAIM3MainBase:AddOpAI('BasicLandAttack', 'M3_QAI_M_LandAttack_To_Player_4',
        {
            MasterPlatoonFunction = {ThisFile, 'AttackThenHunt'},
            PlatoonData = {
                AttackChain = 'M3_QAI_M_Base_To_Player_Land_Attack_Chain_1',
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity('HeavyBots', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {{'HumanPlayers'}, trigger[Difficulty], categories.LAND * categories.MOBILE * categories.TECH3, '>='})
    opai:SetFormation('AttackFormation')
    --]]
    -- 'MobileHeavyArtillery'
    --{'MobileFlak', 'MobileAntiAir'}
    --{'MobileMissiles', 'LightArtillery'}
    --{'MobileMissiles', 'MobileAntiAir'}
    --{'LightArtillery'}
    --{'RangeBots'}
    --{'RangeBots', 'LightArtillery'}
    --{'HeavyMobileAntiAir'}
end

function QAIM3MainBaseConditionalBuilds()
    local opai = nil
    local engineers = {2, 3, 4}

    -- Build one spider, either when players start to build their own experimental or when they have enough T3 land units
    opai = QAIM3MainBase:AddOpAI('M3_Main_Base_Spider_1',
        {
            Amount = 1,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_QAI_Spider_Patrol_3_Chain',
            },
            BuildCondition = {
                {'/lua/editor/otherarmyunitcountbuildconditions.lua', 'FocusBrainBeingBuiltOrActiveCategoryCompare', {1, {categories.EXPERIMENTAL}, '>='}},
                {'/lua/editor/unitcountbuildconditions.lua', 'HaveLessThanUnitsWithCategoryInArea', {3, categories.url0402, 'M3_QAI_Main_Base_Area'}},
            },
            MaxAssist = engineers[Difficulty],
            Retry = true,
        }
    )

    trigger = {40, 32, 24}
    opai = QAIM3MainBase:AddOpAI('M3_Main_Base_Spider_2',
        {
            Amount = 1,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_QAI_Spider_Patrol_3_Chain',
            },
            BuildCondition = {
                {'/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
                    {{'HumanPlayers'}, 3, categories.TECH3 * categories.LAND * categories.MOBILE - categories.ENGINEER, '>='}},
                {'/lua/editor/unitcountbuildconditions.lua', 'HaveLessThanUnitsWithCategoryInArea', {3, categories.url0402, 'M3_QAI_Main_Base_Area'}},
            },
            MaxAssist = engineers[Difficulty],
            Retry = true,
        }
    )
end

----------------------
-- QAI M3 Defense Base
----------------------
function QAIM3DefenseBaseAI()
    QAIM3DefenseBase:InitializeDifficultyTables(ArmyBrains[QAI], 'M3_QAI_Defense_Base', 'M3_QAI_Defense_Base_Marker', 15, {M3_Defences = 100})
    local quantity = {1, 2, 3}
    QAIM3DefenseBase:StartNonZeroBase(quantity[Difficulty])
    QAIM3DefenseBase:SetMaximumConstructionEngineers(quantity[Difficulty])

    QAIM3MainBase:AddExpansionBase('M3_QAI_Defense_Base', quantity[Difficulty])

    QAIM3DefenseBase:AddBuildGroupDifficulty('M3_Defences_South', 90)
end

------------------------------
-- QAI M3 Plateau Defense Base
------------------------------
function QAIM3PlateauDefenseBaseAI()
    QAIM3PlateauDefenseBase:Initialize(ArmyBrains[QAI], 'M3_QAI_Plateau_Defense_Base', 'M3_QAI_Plateau_Defense_Base_Marker', 15,
        {
            --M3_Plateau_Mexes = 110,
            M3_Plateau_AA_Positions_North = 100,
            M3_Plateau_Extra_Structures = 90,
        }
    )
    QAIM3PlateauDefenseBase:StartEmptyBase(2)

    QAIM3ExperimentalBase:AddExpansionBase('M3_QAI_Plateau_Defense_Base', 2)
end

---------------------------
-- QAI M3 Experimental Base
---------------------------
function QAIM3ExperimentalBaseAI()
    QAIM3ExperimentalBase:InitializeDifficultyTables(ArmyBrains[QAI], 'M3_QAI_Experimental_Base', 'M3_QAI_Experimental_Base_Marker', 20, {M3_Experimental_Base = 100})
    QAIM3ExperimentalBase:StartNonZeroBase({{3, 5, 7}, {2, 3, 4}})

    QAIM3ExperimentalBaseLandAttacks()
    QAIM3ExperimentalBaseConditionalBuilds()
end

function QAIM3ExperimentalBaseLandAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    quantity = {6, 6, 9}
    opai = QAIM3ExperimentalBase:AddOpAI('BasicLandAttack', 'M3_QAI_Experimental_LandAttack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_QAI_Experimental_Attack_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'SiegeBots', 'MobileStealth', 'LightBots'}, quantity[Difficulty])

    quantity = {6, 6, 9}
    opai = QAIM3ExperimentalBase:AddOpAI('BasicLandAttack', 'M3_QAI_Experimental_LandAttack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_QAI_Experimental_Attack_Chain',
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'SiegeBots', 'HeavyTanks', 'HeavyBots'}, quantity[Difficulty])

    quantity = {6, 6, 6}
    opai = QAIM3ExperimentalBase:AddOpAI('BasicLandAttack', 'M3_QAI_Experimental_LandAttack_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_QAI_Experimental_Attack_Chain',
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity({'HeavyTanks', 'HeavyBots'}, quantity[Difficulty])

    quantity = {4, 4, 6}
    opai = QAIM3ExperimentalBase:AddOpAI('BasicLandAttack', 'M3_QAI_Experimental_LandAttack_4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_QAI_Experimental_Attack_Chain',
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity({'HeavyBots', 'MobileFlak'}, quantity[Difficulty])

    ----------
    -- Patrols
    ----------
    quantity = {2, 2, 3}
    for i = 1, 5 do
        opai = QAIM3ExperimentalBase:AddOpAI('BasicLandAttack', 'M3_QAI_Experimental_AA_Patrol_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M3_QAI_Plateau_AA_Patrol_Chain_' .. i,
                },
                Priority = 200,
            }
        )
        opai:SetChildQuantity("HeavyMobileAntiAir", quantity[Difficulty])
    end
end

function QAIM3ExperimentalBaseConditionalBuilds()
    local opai = nil
    local quantity = {}
    local trigger = {}

    local rnd = Random(1, 3)
    if rnd == 1 then
        quantity = {2, 3, 4}
        opai = QAIM3ExperimentalBase:AddOpAI('M3_Experimental_Megalith',
            {
                Amount = 2,
                KeepAlive = true,
                PlatoonAIFunction = {ThisFile, 'AddExperimentalToPlatoon'},
                PlatoonData = {
                    PlatoonAIFunction = {ThisFile, 'QAIExperimentalAttack'},
                    Name = 'ExperimentalBase_SpiderBots_Platoon',
                    AttackChain = 'M3_QAI_Experimental_Attack_Chain',
                    TargetMarker = 'M3_QAI_Experimental_Attack_Target',
                    NumRequired = 2,
                },
                MaxAssist = Difficulty,
                Retry = true,
            }
        )
    elseif rnd == 2 then
        quantity = {2, 3, 4}
        opai = QAIM3ExperimentalBase:AddOpAI('M3_Experimental_Spider',
            {
                Amount = 4,
                KeepAlive = true,
                PlatoonAIFunction = {ThisFile, 'AddExperimentalToPlatoon'},
                PlatoonData = {
                    PlatoonAIFunction = {ThisFile, 'QAIExperimentalAttack'},
                    Name = 'ExperimentalBase_SpiderBots_Platoon',
                    AttackChain = 'M3_QAI_Experimental_Attack_Chain',
                    TargetMarker = 'M3_QAI_Experimental_Attack_Target',
                    NumRequired = 4,
                },
                MaxAssist = Difficulty,
                Retry = true,
            }
        )
    else
        quantity = {1, 2, 3}
        opai = QAIM3ExperimentalBase:AddOpAI('M3_Experimental_Bug',
            {
                Amount = 2,
                KeepAlive = true,
                PlatoonAIFunction = {ThisFile, 'AddExperimentalToPlatoon'},
                PlatoonData = {
                    PlatoonAIFunction = {ThisFile, 'QAIExperimentalAttack'},
                    Name = 'ExperimentalBase_SoulRipper_Platoon',
                    AttackChain = 'M3_QAI_Experimental_Attack_Chain',
                    TargetMarker = 'M3_QAI_Experimental_Attack_Target',
                    NumRequired = 2,
                },
                MaxAssist = Difficulty,
                Retry = true,
            }
        )
    end
end

--------------------------
-- Custom platon functions
--------------------------
--- Merges units produced by the Base Manager conditional build into the same platoon.
-- PlatoonData = {
--     Name - String, unique name for this platoon
--     NumRequired - Number of experimentals to start moving the platoon
--     PatrolChain - Name of the chain to use
-- }
function AddExperimentalToPlatoon(platoon)
    local brain = platoon:GetBrain()
    local data = platoon.PlatoonData

    if not (data.Name and data.NumRequired and data.PlatoonAIFunction) then
        error('*SCENARIO PLATOON AI ERROR: AddExperimentalToPlatoon requires Name, NumRequired and PlatoonAIFunction to operate', 2)
    end

    local unit = platoon:GetPlatoonUnits()[1]
    local plat = brain:GetPlatoonUniquelyNamed(data.Name)

    if not plat then
        plat = brain:MakePlatoon('', '')
        plat:UniquelyNamePlatoon(data.Name)
        plat:SetPlatoonData(data)
        plat:ForkAIThread(MultipleExperimentalsThread)
    end

    brain:AssignUnitsToPlatoon(plat, {unit}, 'Attack', 'AttackFormation')
    brain:DisbandPlatoon(platoon)
end

--- Handles an unique platoon of multiple experimentals.
function MultipleExperimentalsThread(platoon)
    local brain = platoon:GetBrain()
    local data = platoon.PlatoonData

    while brain:PlatoonExists(platoon) do
        if not platoon.CommandSet then
            local numAlive = 0
            for _, v in platoon:GetPlatoonUnits() do
                if not v.Dead then
                    numAlive = numAlive + 1
                end
            end

            if numAlive == data.NumRequired then
                platoon.CommandSet = true
                OpScript.QAIExperimentalAttack(platoon)
            end
        end
        WaitSeconds(10)
    end
end

--- Custom platoon AI function that attacks chain and then reguraly attack moves to Player's ACU.
-- First the players will be around the crash site, but as they start moving out,
-- it would be impossible to bump into them with normal patrols.
function AttackThenHunt(platoon)
    local aiBrain = platoon:GetBrain()
    local data = platoon.PlatoonData

    if not (data.AttackChain or data.AttackChains or data.AttackRoute) then
        error('*SCENARIO PLATOON AI ERROR: AttackThenHunt requires AttackChains OR AttackChains OR AttackRoute to operate', 2)
    end

    local categoryList = data.CategoryList or {
        categories.COMMAND,
        categories.ALLUNITS - categories.WALL,
    }
    
    local cmd = nil
    local target = nil

    -- Assign the attack move commands
    if data.AttackRoute then
        for _, pos in data.AttackRoute do
            if type(pos) == 'string' then
                cmd = platoon:AggressiveMoveToLocation(ScenarioUtils.MarkerToPosition(pos))
            else
                cmd = platoon:AggressiveMoveToLocation(pos)
            end
        end
    else
        local chain = data.AttackChain or data.AttackChains[Random(1, table.getn(data.AttackChains))]
        for _, pos in ScenarioUtils.ChainToPositions(chain) do
            cmd = platoon:AggressiveMoveToLocation(pos)
        end
    end

    while aiBrain:PlatoonExists(platoon) do
        -- If the platoon has no active command, attack move to set priority target.
        if not platoon:IsCommandsActive(cmd) or (target and target.Dead) then
            for _, category in categoryList do
                target = platoon:FindClosestUnit('Attack', 'Enemy', true, category)

                if target then
                    platoon:Stop()
                    cmd = platoon:AggressiveMoveToLocation(target:GetPosition())
                    break
                end
            end
        end

        WaitSeconds(5)
    end
end

function SplitAirPlatoon(platoon)
    local aiBrain = platoon:GetBrain()
    local data = platoon.PlatoonData

    -- Split non ASFs from the platoon and send them on normal attack
    local cats = categories.TECH3 * categories.ANTIAIR

    local others = {}
    for _, unit in platoon:GetPlatoonUnits() do
        if not EntityCategoryContains(cats, unit) then
            table.insert(others, unit)
        end
    end

    if others[1] then
        local newPlat = aiBrain:MakePlatoon('', '')
        aiBrain:AssignUnitsToPlatoon(newPlat, others, 'Attack', 'GrowthFormation')

        newPlat:SetPlatoonData(data)
        newPlat:ForkAIThread(AttackThenHunt)
    end

    -- Do normal patrol with ASFs
    ScenarioPlatoonAI.RandomDefensePatrolThread(platoon)
end

function PlayersACUFarFromBase(brain, position, distance)
    if type(position) == 'string' then
        position = ScenarioUtils.MarkerToPosition(position)
    end

    for _, ACU in ScenarioInfo.PlayersACUs do
        local ACUPos = ACU:GetPosition()
        if not ACU.Dead and VDist2(position[1], position[3], ACUPos[1], ACUPos[3]) > distance then
            return true
        end
    end
    return false
end