local BaseManager = import('/lua/ai/opai/basemanager.lua')
local CustomFunctions = '/maps/Prothyon16/Prothyon16_CustomFunctions.lua'
local SPAIFileName = '/lua/scenarioplatoonai.lua'

---------
-- Locals
---------
local UEF = 2
local Difficulty = ScenarioInfo.Options.Difficulty

----------------
-- Base Managers
----------------
local UEFM1WestBase = BaseManager.CreateBaseManager()
local UEFM1EastBase = BaseManager.CreateBaseManager()

-------------------
-- UEF M1 West Base
-------------------
function UEFM1WestBaseAI()
    UEFM1WestBase:InitializeDifficultyTables(ArmyBrains[UEF], 'M1_WestLand_Base', 'M1_West_Base_Marker', 40, {M1_WestBase = 100})
    UEFM1WestBase:StartNonZeroBase({{4, 5, 7}, {3, 4, 5}})
    UEFM1WestBase:SetActive('AirScouting', true)
    UEFM1WestBase:SetActive('LandScouting', true)

    UEFM1WestBase:AddBuildGroup('M1_WestBaseExtended', 90, false)

    UEFM1WestBaseAirAttacks()
    UEFM1WestBaseLandAttacks()
end

function UEFM1WestBaseAirAttacks()
    local opai = nil
    local quantity = {}

    -- Builds platoon of 2/3/4 Bombers
    quantity = {2, 3, 4}
    opai = UEFM1WestBase:AddOpAI('AirAttacks', 'M1_WestAirAttack1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M1_Land_Attack_Chain'
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Bombers', quantity[Difficulty])
end

function UEFM1WestBaseLandAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    -- Builds platoon of 6/7/8 LABs
    quantity = {6, 7, 8}
    opai = UEFM1WestBase:AddOpAI('BasicLandAttack', 'M1_WestLandAttack1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M1_Land_Attack_Chain'
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity('LightBots', quantity[Difficulty])

    -- Builds platoon of 4/5/6 T1 Arties
    quantity = {4, 5, 6}
    opai = UEFM1WestBase:AddOpAI('BasicLandAttack', 'M1_WestLandAttack2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M1_Land_Attack_Chain'
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity('LightArtillery', quantity[Difficulty])

    -- Builds platoon of 12 T1 Tanks
    quantity = {6, 8, 10}
    opai = UEFM1WestBase:AddOpAI('BasicLandAttack', 'M1_WestLandAttack3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M1_Land_Attack_Chain'
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity('LightTanks', quantity[Difficulty])

    -- Builds Platoon of 4 Engineers
    opai = UEFM1WestBase:AddOpAI('EngineerAttack', 'M1_West_Reclaim_Engineers',
    {
        MasterPlatoonFunction = {SPAIFileName, 'SplitPatrolThread'},
        PlatoonData = {
            PatrolChains = {'M1_Land_Attack_Chain'},
        },
        Priority = 150,
    })
    opai:SetChildQuantity('T1Engineers', 4)
end

-------------------
-- UEF M1 East Base
-------------------
function UEFM1EastBaseAI()
    UEFM1EastBase:InitializeDifficultyTables(ArmyBrains[UEF], 'M1_East_Base', 'M1_East_Base_Marker', 40, {M1_EastBase = 100})
    UEFM1EastBase:StartNonZeroBase({{6,8,10}, {4, 6, 8}})
    UEFM1EastBase:SetActive('AirScouting', true)
    UEFM1EastBase:SetActive('LandScouting', true)

    ForkThread(
        function()
            WaitSeconds(1)
            UEFM1EastBase:AddBuildGroup('M1_East_Base_Support_Factory', 100, true)
            UEFM1EastBase:AddBuildGroup('M1_EastBaseExtended', 90, false)
        end
    )

    UEFM1EastBaseAirAttacks()
    UEFM1EastBaseLandAttacks()
end

function UEFM1EastBaseAirAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    -- Builds platoon of 6 Bombers
    quantity = {4, 5, 6}
    trigger = {42, 36, 30}
    opai = UEFM1EastBase:AddOpAI('AirAttacks', 'M1_EastAirAttack1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_East_Attack_Chain1', 'M1_East_Attack_Chain2', 'M1_East_Attack_Chain3', 'M1_East_Attack_Chain4'},
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity('Bombers', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.LAND * categories.MOBILE})

    -- Builds platoon of 8 Bombers
    quantity = {4, 6, 8}
    trigger = {55, 50, 45}
    opai = UEFM1EastBase:AddOpAI('AirAttacks', 'M1_EastAirAttack2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_East_Attack_Chain1', 'M1_East_Attack_Chain2', 'M1_East_Attack_Chain3', 'M1_East_Attack_Chain4'},
            },
            Priority = 160,
        }
    )
    opai:SetChildQuantity('Bombers', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.LAND * categories.MOBILE})

    -- Builds platoon of 8 Interceptor when Player has 10+ air units
    quantity = {6, 7, 8}
    trigger = {20, 15, 10}
    opai = UEFM1EastBase:AddOpAI('AirAttacks', 'M1_EastAirAttack3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_East_Attack_Chain1', 'M1_East_Attack_Chain2', 'M1_East_Attack_Chain3', 'M1_East_Attack_Chain4'},
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity('Interceptors', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.AIR * categories.MOBILE})

    -- Builds platoon of 12 Interceptor when Player has 20+ air units
    quantity = {6, 9, 12}
    trigger = {30, 25, 20}
    opai = UEFM1EastBase:AddOpAI('AirAttacks', 'M1_EastAirAttack4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_East_Attack_Chain1', 'M1_East_Attack_Chain2', 'M1_East_Attack_Chain3', 'M1_East_Attack_Chain4'},
            },
            Priority = 160,
        }
    )
    opai:SetChildQuantity('Interceptors', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.AIR * categories.MOBILE})

    -- Builds platoon of 12 Interceptor when Player has 2+ Transports
    quantity = {6, 9, 12}
    opai = UEFM1EastBase:AddOpAI('AirAttacks', 'M1_EastAirAttack5',
        {
            MasterPlatoonFunction = { '/lua/ScenarioPlatoonAI.lua', 'CategoryHunterPlatoonAI' },
            PlatoonData = {
                CategoryList = { categories.uea0107 },
            },
            Priority = 170,
        }
    )
    opai:SetChildQuantity('Interceptors', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', 2, categories.uea0107})

    -- Air Defense
    -- Maintains 6/9/12 Interceptors
    for i = 1, 2 do
        quantity = {2, 3, 4}
        opai = UEFM1EastBase:AddOpAI('AirAttacks', 'M1_East_Base_AirDefense1_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M1_East_Base_Air_Defence_Chain',
                },
                Priority = 150,
            }
        )
        opai:SetChildQuantity('Interceptors', quantity[Difficulty])
    end

    -- Maintains 4/6/8 Bombers
    for i = 1, 2 do
        quantity = {2, 3, 4}
        opai = UEFM1EastBase:AddOpAI('AirAttacks', 'M1_East_Base_AirDefense2_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M1_East_Base_Air_Defence_Chain',
                },
                Priority = 150,
            }
        )
        opai:SetChildQuantity('Bombers', quantity[Difficulty])
    end

    -- Maintains 4 Gunships at Hard Difficulty
    if Difficulty == 3 then
        opai = UEFM1EastBase:AddOpAI('AirAttacks', 'M1_East_Base_AirDefense3',
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M1_East_Base_Air_Defence_Chain',
                },
                Priority = 160,
            }
        )
        opai:SetChildQuantity({'Gunships'}, 4)
    end
end

function UEFM1EastBaseLandAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    ---------------------------------------
    -- UEF M1 East Base Op AI, Land Attacks
    ---------------------------------------

    -- Builds Platoon of 8 Engineers
    opai = UEFM1EastBase:AddOpAI('EngineerAttack', 'M1_East_Reclaim_Engineers',
    {
        MasterPlatoonFunction = {SPAIFileName, 'SplitPatrolThread'},
        PlatoonData = {
            PatrolChains = {'M1_East_Attack_Chain1',
                            'M1_East_Attack_Chain2',
                            'M1_East_Attack_Chain3',
                            'M1_East_Attack_Chain4'},
        },
        Priority = 90,
    })
    opai:SetChildQuantity('T1Engineers', 8)
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})

    -- Builds platoon of 4/6/8 T1 Arties
    quantity = {4, 6, 8}
    trigger = {34 ,28 ,22}
    opai = UEFM1EastBase:AddOpAI('BasicLandAttack', 'M1_EastLandAttack1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_East_Attack_Chain1', 'M1_East_Attack_Chain2', 'M1_East_Attack_Chain3', 'M1_East_Attack_Chain4'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('LightArtillery', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.DIRECTFIRE + categories.INDIRECTFIRE})


    -- Builds platoon of 6/8/10 T1 Tanks
    quantity = {6, 8, 10}
    trigger = {48 ,42, 36}
    opai = UEFM1EastBase:AddOpAI('BasicLandAttack', 'M1_EastLandAttack2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_East_Attack_Chain1', 'M1_East_Attack_Chain2', 'M1_East_Attack_Chain3', 'M1_East_Attack_Chain4'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('LightTanks', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.DIRECTFIRE + categories.INDIRECTFIRE})

    -- Builds platoon of 3/3/4 T1 Tanks and 3/3/4 T1 Arties
    quantity = {6, 6, 8}
    trigger = {50, 44, 38}
    opai = UEFM1EastBase:AddOpAI('BasicLandAttack', 'M1_EastLandAttack3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_East_Attack_Chain1', 'M1_East_Attack_Chain2', 'M1_East_Attack_Chain3', 'M1_East_Attack_Chain4'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'LightTanks', 'LightArtillery'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.DIRECTFIRE + categories.INDIRECTFIRE})

    -- sends 8/10/12 [light tanks]
    quantity = {8, 10, 12}
    trigger = {60 ,53, 47}
    opai = UEFM1EastBase:AddOpAI('BasicLandAttack', 'M1_EastLandAttack4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_East_Attack_Chain1', 'M1_East_Attack_Chain2', 'M1_East_Attack_Chain3', 'M1_East_Attack_Chain4'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('LightTanks', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.DIRECTFIRE + categories.INDIRECTFIRE})

    -- sends 8/10/12 [light artillery] if player has >= 80/70/60 units
    quantity = {8, 10, 12}
    trigger = {80, 70, 60}
    opai = UEFM1EastBase:AddOpAI('BasicLandAttack', 'M1_EastLandAttack5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_East_Attack_Chain1', 'M1_East_Attack_Chain2', 'M1_East_Attack_Chain3', 'M1_East_Attack_Chain4'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('LightArtillery', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.ALLUNITS - categories.WALL})

    -- sends 10 [mobile aa] if player has >= 6 planes
    quantity = {6, 8, 10}
    trigger = {12, 9, 6}
    opai = UEFM1EastBase:AddOpAI('BasicLandAttack', 'M1_EastLandAttack6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_East_Attack_Chain1', 'M1_East_Attack_Chain2', 'M1_East_Attack_Chain3', 'M1_East_Attack_Chain4'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('MobileAntiAir', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.MOBILE * categories.AIR})

    -- sends 16 [light tanks]
    quantity = {10, 12, 16}
    trigger = {120 ,110, 100}
    opai = UEFM1EastBase:AddOpAI('BasicLandAttack', 'M1_EastLandAttack7',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_East_Attack_Chain1', 'M1_East_Attack_Chain2', 'M1_East_Attack_Chain3', 'M1_East_Attack_Chain4'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('LightTanks', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.ALLUNITS - categories.WALL})

    -- sends 16 [light artillery] if player has >= 20 units
    quantity = {10, 12, 16}
    trigger = {120 ,110, 100}
    opai = UEFM1EastBase:AddOpAI('BasicLandAttack', 'M1_EastLandAttack8',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_East_Attack_Chain1', 'M1_East_Attack_Chain2', 'M1_East_Attack_Chain3', 'M1_East_Attack_Chain4'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('LightArtillery', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.ALLUNITS - categories.WALL})

    -- sends 20 [light artillery, tanks] if player has >= 30 units
    quantity = {12, 16, 20}
    trigger = {120, 110, 100}
    opai = UEFM1EastBase:AddOpAI('BasicLandAttack', 'M1_EastLandAttack9',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_East_Attack_Chain1', 'M1_East_Attack_Chain2', 'M1_East_Attack_Chain3', 'M1_East_Attack_Chain4'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'LightArtillery', 'LightTanks'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.ALLUNITS - categories.WALL})

    ---------------
    -- Land Defense
    ---------------
    quantity = {6, 6, 8}
    opai = UEFM1EastBase:AddOpAI('BasicLandAttack', 'M1_EastBase_Land_Defense1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_East_Defence_Chain1', 'M1_East_Defence_Chain2'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('LightTanks', quantity[Difficulty])

    quantity = {8, 10, 12}
    opai = UEFM1EastBase:AddOpAI('BasicLandAttack', 'M1_EastBase_Land_Defense2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_East_Defence_Chain1', 'M1_East_Defence_Chain2'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('MobileAntiAir', quantity[Difficulty])

    quantity = {6, 6, 8}
    opai = UEFM1EastBase:AddOpAI('BasicLandAttack', 'M1_EastBase_Land_Defense3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_East_Defence_Chain1', 'M1_East_Defence_Chain2'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('LightArtillery', quantity[Difficulty])

    quantity = {12, 14, 16}
    opai = UEFM1EastBase:AddOpAI('BasicLandAttack', 'M1_EastBase_Land_Defense4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_East_Defence_Chain1', 'M1_East_Defence_Chain2'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('LightTanks', quantity[Difficulty])
end