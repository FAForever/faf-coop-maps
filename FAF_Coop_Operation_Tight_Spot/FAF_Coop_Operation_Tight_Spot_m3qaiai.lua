local BaseManager = import('/lua/ai/opai/basemanager.lua')
local CustomFunctions = '/maps/FAF_Coop_Operation_Tight_Spot/FAF_Coop_Operation_Tight_Spot_CustomFunctions.lua'
local SPAIFileName = '/lua/ScenarioPlatoonAI.lua'

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
WARN('QAI is picking: ' .. attackAirUnit)

----------------
-- Base Managers
----------------
local QAIM3NorthEastBase = BaseManager.CreateBaseManager()
local QAIM3NorthBase = BaseManager.CreateBaseManager()
local QAIM3SouthEastBase = BaseManager.CreateBaseManager()
local QAIM3SouthWestBase = BaseManager.CreateBaseManager()

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
    WaitSeconds(7*60)
    QAIM3NorthEastBase:AddBuildGroup('M3_QAI_NE_3', 80)
    WaitSeconds(6*60)
    QAIM3NorthEastBase:AddBuildGroup('M3_QAI_NE_4', 70)
    WaitSeconds(7*60)
    QAIM3NorthEastBase:AddBuildGroup('M3_QAI_NE_Arty', 60)
end

function QAIM3NorthEastBaseLandAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    -- Engineer for reclaiming if there's less than 2000 Mass in the storage, starting after 5 minutes
    quantity = {3, 4, 6}
    opai = QAIM3NorthEastBase:AddOpAI('EngineerAttack', 'M3_QAI_NE_Reclaim_Engineers',
        {
            MasterPlatoonFunction = {SPAIFileName, 'SplitPatrolThread'},
            PlatoonData = {
                PatrolChains = {
                    'M3_QAI_NE_Attack_Chain_1',
                    'M3_QAI_NE_Attack_Chain_2',
                    'M3_QAI_NE_Attack_Chain_3',
                },
            },
            Priority = 200,
        }
    )
    opai:SetChildQuantity('T1Engineers', quantity[Difficulty])
    opai:AddBuildCondition(CustomFunctions, 'LessMassStorageCurrent', {'default_brain', 600})

    ----------
    -- Attacks
    ----------
    quantity = {2, 3, 4}
    opai = QAIM3NorthEastBase:AddOpAI('BasicLandAttack', 'M3_QAI_NE_LandAttack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M3_QAI_NE_Attack_Chain_1',
                    'M3_QAI_NE_Attack_Chain_2',
                    'M3_QAI_NE_Attack_Chain_3',
                },
            },
            Priority = 100,
        }
    )
    if Difficulty <= 2 then
        opai:SetChildQuantity('LightBots', quantity[Difficulty])
    else
        opai:SetChildQuantity('LightArtillery', quantity[Difficulty])
    end
    opai:SetLockingStyle('None')

    quantity = {4, 6, 9}
    trigger = {50, 40, 30}
    opai = QAIM3NorthEastBase:AddOpAI('BasicLandAttack', 'M3_QAI_NE_LandAttack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M3_QAI_NE_Attack_Chain_1',
                    'M3_QAI_NE_Attack_Chain_2',
                    'M3_QAI_NE_Attack_Chain_3',
                },
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('LightArtillery', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL, '>='})

    trigger = {70, 60, 50}
    opai = QAIM3NorthEastBase:AddOpAI('BasicLandAttack', 'M3_QAI_NE_LandAttack_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M3_QAI_NE_Attack_Chain_1',
                    'M3_QAI_NE_Attack_Chain_2',
                    'M3_QAI_NE_Attack_Chain_3',
                },
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('HeavyTanks', 3)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL, '>='})

    quantity = {2, 3, 4}
    trigger = {20, 15, 10}
    opai = QAIM3NorthEastBase:AddOpAI('BasicLandAttack', 'M3_QAI_NE_LandAttack_4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M3_QAI_NE_Attack_Chain_1',
                    'M3_QAI_NE_Attack_Chain_2',
                    'M3_QAI_NE_Attack_Chain_3',
                },
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('MobileMissiles', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.DEFENSE, '>='})

    if Difficulty >= 2 then
        quantity = {0, 1, 2}
        trigger = {0, 7, 5}
        opai = QAIM3NorthEastBase:AddOpAI('BasicLandAttack', 'M3_QAI_NE_LandAttack_5',
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
                PlatoonData = {
                    PatrolChains = {
                        'M3_QAI_NE_Attack_Chain_1',
                        'M3_QAI_NE_Attack_Chain_2',
                        'M3_QAI_NE_Attack_Chain_3',
                    },
                },
                Priority = 110,
            }
        )
        opai:SetChildQuantity('MobileMissiles', quantity[Difficulty])
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
            'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.SHIELD * categories.STRUCTURE, '>='})

        quantity = {0, 1, 2}
        trigger = {0, 80, 70}
        opai = QAIM3NorthEastBase:AddOpAI('BasicLandAttack', 'M3_QAI_NE_LandAttack_6',
            {
                MasterPlatoonFunction = {SPAIFileName, 'SplitPatrolThread'},
                PlatoonData = {
                    PatrolChains = {
                        'M3_QAI_NE_Attack_Chain_1',
                        'M3_QAI_NE_Attack_Chain_2',
                        'M3_QAI_NE_Attack_Chain_3',
                    },
                },
                Priority = 120,
            }
        )
        opai:SetChildQuantity('SiegeBots', quantity[Difficulty])
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
            'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL, '>='})
    end
end

--------------------
-- QAI M3 North Base
--------------------
function QAIM3NorthBaseAI()
    QAIM3NorthBase:InitializeDifficultyTables(ArmyBrains[QAI], 'M3_QAI_N_Base', 'M3_QAI_N_Base_Marker', 45, {M3_QAI_N = 100})
    QAIM3NorthBase:StartNonZeroBase(2, 2)


    QAIM3NorthBaseAirAttacks()
end

function QAIM3NorthBaseAirAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}
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
    WaitSeconds(5*60)
    QAIM3SouthEastBase:AddBuildGroup('M3_QAI_SE_2', 80)
    WaitSeconds(5*60)
    QAIM3SouthEastBase:AddBuildGroup('M3_QAI_SE_Def_2', 70)
    WaitSeconds(5*60)
    QAIM3SouthEastBase:AddBuildGroup('M3_QAI_SE_3', 60)
    WaitSeconds(4*60)
    QAIM3SouthEastBase:AddBuildGroup('M3_QAI_SE_Def_3', 50)
end

function QAIM3SouthEastBaseAirAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    opai = QAIM3SouthEastBase:AddOpAI('AirAttacks', 'M3_QAI_SE_AirAttack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'SplitPatrolThread'},
            PlatoonData = {
                PatrolChains = {
                    'M3_QAI_SE_Attack_Chain_1',
                    'M3_QAI_SE_Attack_Chain_2',
                    'M3_QAI_SE_Attack_Chain_3',
                },
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity(attackAirUnit, 3)

    trigger = {50, 40, 30}
    opai = QAIM3SouthEastBase:AddOpAI('AirAttacks', 'M3_QAI_SE_AirAttack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M3_QAI_SE_Attack_Chain_1',
                    'M3_QAI_SE_Attack_Chain_2',
                    'M3_QAI_SE_Attack_Chain_3',
                },
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity(attackAirUnit, 3)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL, '>='})

    trigger = {80, 70, 60}
    opai = QAIM3SouthEastBase:AddOpAI('AirAttacks', 'M3_QAI_SE_AirAttack_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M3_QAI_SE_Attack_Chain_1',
                    'M3_QAI_SE_Attack_Chain_2',
                    'M3_QAI_SE_Attack_Chain_3',
                },
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Gunships', 3)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL, '>='})

    trigger = {60, 50, 40}
    opai = QAIM3SouthEastBase:AddOpAI('AirAttacks', 'M3_QAI_SE_AirAttack_4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M3_QAI_SE_Attack_Chain_1',
                    'M3_QAI_SE_Attack_Chain_2',
                    'M3_QAI_SE_Attack_Chain_3',
                },
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('FighterBombers', 3)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.LAND * categories.MOBILE, '>='})

    --[[
    -- Send 3, 3, 6 Interceptors if player has more than 80, 70, 60 units
    quantity = {3, 3, 6}
    trigger = {8, 6, 4}
    opai = QAIM3SouthEastBase:AddOpAI('AirAttacks', 'M3_QAI_SE_AirAttack_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M3_QAI_SE_Attack_Chain_1',
                    'M3_QAI_SE_Attack_Chain_2',
                    'M3_QAI_SE_Attack_Chain_3',
                },
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Bombers', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE, '>='})
    --]]
end

function QAIM3SouthEastBaseLandAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    -- Engineer for reclaiming if there's less than 2000 Mass in the storage, starting after 5 minutes
    quantity = {3, 4, 6}
    opai = QAIM3SouthEastBase:AddOpAI('EngineerAttack', 'M3_QAI_SE_Reclaim_Engineers',
        {
            MasterPlatoonFunction = {SPAIFileName, 'SplitPatrolThread'},
            PlatoonData = {
                PatrolChains = {
                    'M3_QAI_SE_Attack_Chain_1',
                    'M3_QAI_SE_Attack_Chain_2',
                    'M3_QAI_SE_Attack_Chain_3',
                },
            },
            Priority = 200,
        }
    )
    opai:SetChildQuantity('T1Engineers', quantity[Difficulty])
    opai:AddBuildCondition(CustomFunctions, 'LessMassStorageCurrent', {'default_brain', 1000})

    ----------
    -- Attacks
    ----------
    -- Sends 6 LABs
    quantity = {4, 5, 6}
    opai = QAIM3SouthEastBase:AddOpAI('BasicLandAttack', 'M3_QAI_SE_LandAttack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M3_QAI_SE_Attack_Chain_1',
                    'M3_QAI_SE_Attack_Chain_2',
                    'M3_QAI_SE_Attack_Chain_3',
                },
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('LightBots', quantity[Difficulty])
    opai:SetLockingStyle('None')

    -- Sends 3, 6, 9 Atry if player has more than 3 factories
    quantity = {4, 6, 9}
    opai = QAIM3SouthEastBase:AddOpAI('BasicLandAttack', 'M3_QAI_SE_LandAttack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M3_QAI_SE_Attack_Chain_1',
                    'M3_QAI_SE_Attack_Chain_2',
                    'M3_QAI_SE_Attack_Chain_3',
                },
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('LightArtillery', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, 3, categories.FACTORY, '>='})

    trigger = {60, 50, 40}
    opai = QAIM3SouthEastBase:AddOpAI('BasicLandAttack', 'M3_QAI_SE_LandAttack_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M3_QAI_SE_Attack_Chain_1',
                    'M3_QAI_SE_Attack_Chain_2',
                    'M3_QAI_SE_Attack_Chain_3',
                },
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('HeavyTanks', 3)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL, '>='})

    if Difficulty >= 2 then
        quantity = {0, 1, 2}
        trigger = {0, 60, 50}
        opai = QAIM3SouthEastBase:AddOpAI('BasicLandAttack', 'M3_QAI_SE_LandAttack_4',
            {
                MasterPlatoonFunction = {SPAIFileName, 'SplitPatrolThread'},
                PlatoonData = {
                    PatrolChains = {
                        'M3_QAI_SE_Attack_Chain_1',
                        'M3_QAI_SE_Attack_Chain_2',
                        'M3_QAI_SE_Attack_Chain_3',
                    },
                },
                Priority = 130,
            }
        )
        opai:SetChildQuantity('SiegeBots', quantity[Difficulty])
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
            'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL, '>='})
    end

    --[[
    -- Sends 3, 6, 9 Mantis if player has more than 8, 10, 12 units
    quantity = {3, 6, 9}
    trigger = {8, 10, 12}
    opai = QAIM3SouthEastBase:AddOpAI('BasicLandAttack', 'M3_QAI_SE_LandAttack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M3_QAI_SE_Attack_Chain_1',
                    'M3_QAI_SE_Attack_Chain_2',
                    'M3_QAI_SE_Attack_Chain_3',
                },
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('HeavyBots', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL, '>='})
    --]]
end

-------------------------
-- QAI M3 South West Base
-------------------------
function QAIM3SouthWestBaseAI()
    QAIM3SouthWestBase:Initialize(ArmyBrains[QAI], 'M3_QAI_SW_Base', 'M3_QAI_SW_Base_Marker', 30, {M3_QAI_SW_1 = 100, M3_QAI_SW_Eng = 100})
    QAIM3SouthWestBase:StartNonZeroBase({4, 2})

    ForkThread(SouthWestBaseExpandThread)

    QAIM3SouthWestBaseLandAttacks()
end

function SouthWestBaseExpandThread()
    QAIM3SouthWestBase:AddBuildGroup('M3_QAI_SW_2', 90)
    QAIM3SouthWestBase:AddBuildGroup('M3_QAI_SW_3', 80)
    QAIM3SouthWestBase:AddBuildGroup('M3_QAI_SW_4', 70)
    WaitSeconds(18*60)
    QAIM3SouthWestBase:AddBuildGroup('M3_QAI_NW_Arty', 60)
end

function QAIM3SouthWestBaseLandAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    -- Engineer for reclaiming if there's less than 2000 Mass in the storage, starting after 5 minutes
    quantity = {3, 4, 6}
    opai = QAIM3SouthEastBase:AddOpAI('EngineerAttack', 'M3_QAI_SW_Reclaim_Engineers',
        {
            MasterPlatoonFunction = {SPAIFileName, 'SplitPatrolThread'},
            PlatoonData = {
                PatrolChains = {
                    'M3_QAI_SW_Attack_Chain_1',
                    'M3_QAI_SW_Attack_Chain_2',
                    'M3_QAI_SW_Attack_Chain_3',
                },
            },
            Priority = 200,
        }
    )
    opai:SetChildQuantity('T1Engineers', quantity[Difficulty])
    opai:AddBuildCondition(CustomFunctions, 'LessMassStorageCurrent', {'default_brain', 500})

    ----------
    -- Attacks
    ----------
    quantity = {3, 4, 5}
    opai = QAIM3SouthWestBase:AddOpAI('BasicLandAttack', 'M3_QAI_SW_LandAttack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M3_QAI_SW_Attack_Chain_1',
                    'M3_QAI_SW_Attack_Chain_2',
                    'M3_QAI_SW_Attack_Chain_3',
                },
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('HeavyBots', quantity[Difficulty])
    opai:SetLockingStyle('None')

    quantity = {3, 4, 5}
    opai = QAIM3SouthWestBase:AddOpAI('BasicLandAttack', 'M3_QAI_SW_LandAttack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M3_QAI_SW_Attack_Chain_1',
                    'M3_QAI_SW_Attack_Chain_2',
                    'M3_QAI_SW_Attack_Chain_3',
                },
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('LightArtillery', quantity[Difficulty])

    quantity = {1, 2, 3}
    trigger = {65, 55, 45}
    opai = QAIM3SouthWestBase:AddOpAI('BasicLandAttack', 'M3_QAI_SW_LandAttack_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M3_QAI_SE_Attack_Chain_1',
                    'M3_QAI_SE_Attack_Chain_2',
                    'M3_QAI_SE_Attack_Chain_3',
                },
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('HeavyTanks', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL, '>='})

    quantity = {6, 8, 10}
    trigger = {70, 60, 50}
    opai = QAIM3SouthWestBase:AddOpAI('BasicLandAttack', 'M3_QAI_SW_LandAttack_4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M3_QAI_SW_Attack_Chain_1',
                    'M3_QAI_SW_Attack_Chain_2',
                    'M3_QAI_SW_Attack_Chain_3',
                },
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('HeavyBots', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL, '>='})

    quantity = {6, 8, 10}
    trigger = {80, 70, 60}
    opai = QAIM3SouthWestBase:AddOpAI('BasicLandAttack', 'M3_QAI_SW_LandAttack_5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M3_QAI_SW_Attack_Chain_1',
                    'M3_QAI_SW_Attack_Chain_2',
                    'M3_QAI_SW_Attack_Chain_3',
                },
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('LightArtillery', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL, '>='})
end
