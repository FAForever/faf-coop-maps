local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'

---------
-- Locals
---------
local UEF = 4
local Difficulty = ScenarioInfo.Options.Difficulty

----------------
-- Base Managers
----------------
local UEFM2ForwardBase1 = BaseManager.CreateBaseManager()
local UEFM2ForwardBase2 = BaseManager.CreateBaseManager()
local UEFM2ForwardBase3 = BaseManager.CreateBaseManager()
local UEFM2ForwardBase4 = BaseManager.CreateBaseManager()

------------------------
-- UEF M2 Forward Base 1
------------------------
function UEFM2ForwardBase1AI()
    UEFM2ForwardBase1:InitializeDifficultyTables(ArmyBrains[UEF], 'M2_UEF_Forward_Base_1', 'M2_UEF_Forward_Base_1_Marker', 30, {M2_UEF_Forward_Base_1 = 30})
    UEFM2ForwardBase1:StartNonZeroBase({{4, 5, 6}, {3, 4, 4}})

    UEFM2ForwardBase1LandAttacks()
end

function UEFM2ForwardBase1LandAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    quantity = {6, 7, 8}
    opai = UEFM2ForwardBase1:AddOpAI('BasicLandAttack', 'M2_UEF_Forward_Base_1_Attack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_UEF_Land_Attack_Chain_1', 'M2_UEF_Land_Attack_Chain_2'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('HeavyTanks', quantity[Difficulty])

    quantity = {6, 7, 8}
    trigger = {50, 40, 30}
    opai = UEFM2ForwardBase1:AddOpAI('BasicLandAttack', 'M2_UEF_Forward_Base_1_Attack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_UEF_Land_Attack_Chain_1', 'M2_UEF_Land_Attack_Chain_2'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('MobileMissiles', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainGreaterThanOrEqualNumCategory', {'default_brain', 'Player', trigger[Difficulty], categories.DEFENSE * categories.TECH2})

    quantity = {6, 7, 8}
    trigger = {40, 30, 20}
    opai = UEFM2ForwardBase1:AddOpAI('BasicLandAttack', 'M2_UEF_Forward_Base_1_Attack_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_UEF_Land_Attack_Chain_1', 'M2_UEF_Land_Attack_Chain_2'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('MobileFlak', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainGreaterThanOrEqualNumCategory', {'default_brain', 'Player', trigger[Difficulty], categories.AIR * categories.MOBILE})

    for i = 1, 2 do
        quantity = {8, 10, 12}
        trigger = {260, 240, 220}
        opai = UEFM2ForwardBase1:AddOpAI('BasicLandAttack', 'M2_UEF_Forward_Base_1_Attack_4_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
                PlatoonData = {
                    PatrolChains = {'M2_UEF_Land_Attack_Chain_1', 'M2_UEF_Land_Attack_Chain_2'},
                },
                Priority = 120,
            }
        )
        opai:SetChildQuantity({'HeavyTanks', 'MobileShields'}, quantity[Difficulty])
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
            'BrainGreaterThanOrEqualNumCategory', {'default_brain', 'Player', trigger[Difficulty], categories.ALLUNITS - categories.WALL})
    end

    quantity = {6, 7, 8}
    trigger = {26, 20, 14}
    opai = UEFM2ForwardBase1:AddOpAI('BasicLandAttack', 'M2_UEF_Forward_Base_1_Attack_5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_UEF_Land_Attack_Chain_1', 'M2_UEF_Land_Attack_Chain_2'},
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('SiegeBots', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainGreaterThanOrEqualNumCategory', {'default_brain', 'Player', trigger[Difficulty], categories.LAND * categories.TECH3 * categories.MOBILE})

    quantity = {6, 7, 8}
    trigger = {39, 32, 25}
    opai = UEFM2ForwardBase1:AddOpAI('BasicLandAttack', 'M2_UEF_Forward_Base_1_Attack_6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_UEF_Land_Attack_Chain_1', 'M2_UEF_Land_Attack_Chain_2'},
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('HeavyBots', quantity[Difficulty])
    opai:SetFormation('AttackFormation')
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainGreaterThanOrEqualNumCategory', {'default_brain', 'Player', trigger[Difficulty], categories.LAND * categories.TECH3 * categories.MOBILE})
end

------------------------
-- UEF M2 Forward Base 2
------------------------
function UEFM2ForwardBase2AI()
    UEFM2ForwardBase2:InitializeDifficultyTables(ArmyBrains[UEF], 'M2_UEF_Forward_Base_2', 'M2_UEF_Forward_Base_2_Marker', 30, {M2_UEF_Forward_Base_2 = 30})
    UEFM2ForwardBase2:StartNonZeroBase({{4, 5, 6}, {3, 4, 4}})

    UEFM2ForwardBase2LandAttacks()
end

function UEFM2ForwardBase2LandAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    quantity = {6, 7, 8}
    opai = UEFM2ForwardBase2:AddOpAI('BasicLandAttack', 'M2_UEF_Forward_Base_2_Attack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_UEF_Land_Attack_Chain_1', 'M2_UEF_Land_Attack_Chain_2'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('HeavyTanks', quantity[Difficulty])

    quantity = {6, 7, 8}
    trigger = {22, 18, 14}
    opai = UEFM2ForwardBase2:AddOpAI('BasicLandAttack', 'M2_UEF_Forward_Base_2_Attack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_UEF_Land_Attack_Chain_1', 'M2_UEF_Land_Attack_Chain_2'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('MobileMissiles', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainGreaterThanOrEqualNumCategory', {'default_brain', 'Player', trigger[Difficulty], categories.DEFENSE * categories.TECH2})

    quantity = {6, 7, 8}
    trigger = {50, 40, 30}
    opai = UEFM2ForwardBase2:AddOpAI('BasicLandAttack', 'M2_UEF_Forward_Base_2_Attack_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_UEF_Land_Attack_Chain_1', 'M2_UEF_Land_Attack_Chain_2'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('MobileFlak', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainGreaterThanOrEqualNumCategory', {'default_brain', 'Player', trigger[Difficulty], categories.AIR * categories.MOBILE})

    for i = 1, 2 do
        quantity = {8, 10, 12}
        trigger = {220, 200, 180}
        opai = UEFM2ForwardBase2:AddOpAI('BasicLandAttack', 'M2_UEF_Forward_Base_2_Attack_4_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
                PlatoonData = {
                    PatrolChains = {'M2_UEF_Land_Attack_Chain_1', 'M2_UEF_Land_Attack_Chain_2'},
                },
                Priority = 120,
            }
        )
        opai:SetChildQuantity({'HeavyTanks', 'MobileShields'}, quantity[Difficulty])
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
            'BrainGreaterThanOrEqualNumCategory', {'default_brain', 'Player', trigger[Difficulty], categories.ALLUNITS - categories.WALL})
    end

    quantity = {6, 7, 8}
    trigger = {32, 26, 20}
    opai = UEFM2ForwardBase2:AddOpAI('BasicLandAttack', 'M2_UEF_Forward_Base_2_Attack_5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_UEF_Land_Attack_Chain_1', 'M2_UEF_Land_Attack_Chain_2'},
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('SiegeBots', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainGreaterThanOrEqualNumCategory', {'default_brain', 'Player', trigger[Difficulty], categories.LAND * categories.TECH3 * categories.MOBILE})

    quantity = {6, 7, 8}
    trigger = {40, 35, 30}
    opai = UEFM2ForwardBase2:AddOpAI('BasicLandAttack', 'M2_UEF_Forward_Base_2_Attack_6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_UEF_Land_Attack_Chain_1', 'M2_UEF_Land_Attack_Chain_2'},
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('HeavyBots', quantity[Difficulty])
    opai:SetFormation('AttackFormation')
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainGreaterThanOrEqualNumCategory', {'default_brain', 'Player', trigger[Difficulty], categories.LAND * categories.TECH3 * categories.MOBILE})
end

------------------------
-- UEF M2 Forward Base 3
------------------------
function UEFM2ForwardBase3AI()
    UEFM2ForwardBase3:InitializeDifficultyTables(ArmyBrains[UEF], 'M2_UEF_Forward_Base_3', 'M2_UEF_Forward_Base_3_Marker', 30, {M2_UEF_Forward_Base_3 = 30})
    UEFM2ForwardBase3:StartNonZeroBase({{4, 5, 6}, {3, 4, 4}})

    UEFM2ForwardBase3AirAttacks()
    UEFM2ForwardBase3LandAttacks()
end

function UEFM2ForwardBase3LandAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    quantity = {6, 7, 8}
    opai = UEFM2ForwardBase3:AddOpAI('BasicLandAttack', 'M2_UEF_Forward_Base_3_Attack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_UEF_Land_Attack_Chain_1', 'M2_UEF_Land_Attack_Chain_2'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('HeavyTanks', quantity[Difficulty])

    quantity = {6, 7, 8}
    trigger = {29, 25, 21}
    opai = UEFM2ForwardBase3:AddOpAI('BasicLandAttack', 'M2_UEF_Forward_Base_3_Attack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_UEF_Land_Attack_Chain_1', 'M2_UEF_Land_Attack_Chain_2'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('MobileMissiles', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainGreaterThanOrEqualNumCategory', {'default_brain', 'Player', trigger[Difficulty], categories.DEFENSE * categories.TECH2})

    quantity = {6, 7, 8}
    trigger = {45, 35, 25}
    opai = UEFM2ForwardBase3:AddOpAI('BasicLandAttack', 'M2_UEF_Forward_Base_3_Attack_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_UEF_Land_Attack_Chain_1', 'M2_UEF_Land_Attack_Chain_2'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('MobileFlak', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainGreaterThanOrEqualNumCategory', {'default_brain', 'Player', trigger[Difficulty], categories.AIR * categories.MOBILE})

    for i = 1, 2 do
        quantity = {8, 10, 12}
        trigger = {210, 190, 170}
        opai = UEFM2ForwardBase3:AddOpAI('BasicLandAttack', 'M2_UEF_Forward_Base_3_Attack_4_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
                PlatoonData = {
                    PatrolChains = {'M2_UEF_Land_Attack_Chain_1', 'M2_UEF_Land_Attack_Chain_2'},
                },
                Priority = 120,
            }
        )
        opai:SetChildQuantity({'HeavyTanks', 'MobileShields'}, quantity[Difficulty])
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
            'BrainGreaterThanOrEqualNumCategory', {'default_brain', 'Player', trigger[Difficulty], categories.ALLUNITS - categories.WALL})
    end

    quantity = {6, 7, 8}
    trigger = {14, 10, 6}
    opai = UEFM2ForwardBase3:AddOpAI('BasicLandAttack', 'M2_UEF_Forward_Base_3_Attack_5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_UEF_Land_Attack_Chain_1', 'M2_UEF_Land_Attack_Chain_2'},
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('SiegeBots', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainGreaterThanOrEqualNumCategory', {'default_brain', 'Player', trigger[Difficulty], categories.LAND * categories.TECH3})

    quantity = {6, 7, 8}
    trigger = {50, 45, 40}
    opai = UEFM2ForwardBase3:AddOpAI('BasicLandAttack', 'M2_UEF_Forward_Base_3_Attack_6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_UEF_Land_Attack_Chain_1', 'M2_UEF_Land_Attack_Chain_2'},
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('HeavyBots', quantity[Difficulty])
    opai:SetFormation('AttackFormation')
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainGreaterThanOrEqualNumCategory', {'default_brain', 'Player', trigger[Difficulty], categories.LAND * categories.TECH3 * categories.MOBILE})
end

function UEFM2ForwardBase3AirAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    quantity = {4, 6, 8}
    opai = UEFM2ForwardBase3:AddOpAI('AirAttacks', 'M2_UEF_Forward_Base_3_AirAttack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_UEF_Land_Attack_Chain_1',
                                'M2_UEF_Land_Attack_Chain_2',
                                'M2_UEF_Land_Attack_Chain_3',
                                'M2_UEF_Land_Attack_Chain_4',
                                'M2_UEF_Air_Attack_Chain_1'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    opai:SetLockingStyle('None')

    quantity = {10, 13, 16}
    trigger = {30, 25, 20}
    opai = UEFM2ForwardBase3:AddOpAI('AirAttacks', 'M2_UEF_Forward_Base_3_AirAttack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_UEF_Land_Attack_Chain_1',
                                'M2_UEF_Land_Attack_Chain_2',
                                'M2_UEF_Land_Attack_Chain_3',
                                'M2_UEF_Land_Attack_Chain_4',
                                'M2_UEF_Air_Attack_Chain_1'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Interceptors', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainGreaterThanOrEqualNumCategory', {'default_brain', 'Player', trigger[Difficulty], categories.AIR * categories.MOBILE})

    quantity = {4, 6, 8}
    trigger = {16, 14, 12}
    opai = UEFM2ForwardBase3:AddOpAI('AirAttacks', 'M2_UEF_Forward_Base_3_AirAttack_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_UEF_Land_Attack_Chain_1',
                                'M2_UEF_Land_Attack_Chain_2',
                                'M2_UEF_Land_Attack_Chain_3',
                                'M2_UEF_Land_Attack_Chain_4',
                                'M2_UEF_Air_Attack_Chain_1'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainGreaterThanOrEqualNumCategory', {'default_brain', 'Player', trigger[Difficulty], categories.AIR * categories.MOBILE * categories.TECH3})

    quantity = {2, 3, 4}
    trigger = {14, 12, 10}
    opai = UEFM2ForwardBase3:AddOpAI('AirAttacks', 'M2_UEF_Forward_Base_3_AirAttack_4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_UEF_Land_Attack_Chain_1',
                                'M2_UEF_Land_Attack_Chain_2',
                                'M2_UEF_Land_Attack_Chain_3',
                                'M2_UEF_Land_Attack_Chain_4',
                                'M2_UEF_Air_Attack_Chain_1'},
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('StratBombers', quantity[Difficulty])
    opai:SetFormation('NoFormation')
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainGreaterThanOrEqualNumCategory', {'default_brain', 'Player', trigger[Difficulty], categories.AIR * categories.MOBILE * categories.TECH3})
end

------------------------
-- UEF M2 Forward Base 4
------------------------
function UEFM2ForwardBase4AI()
    UEFM2ForwardBase4:InitializeDifficultyTables(ArmyBrains[UEF], 'M2_UEF_Forward_Base_4', 'M2_UEF_Forward_Base_4_Marker', 30, {M2_UEF_Forward_Base_4 = 40})
    UEFM2ForwardBase4:StartNonZeroBase({{4, 5, 6}, {3, 4, 4}})

    UEFM2ForwardBase4AirAttacks()
    UEFM2ForwardBase4LandAttacks()
end

function UEFM2ForwardBase4LandAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    quantity = {6, 7, 8}
    opai = UEFM2ForwardBase4:AddOpAI('BasicLandAttack', 'M2_UEF_Forward_Base_4_Attack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_UEF_Land_Attack_Chain_1', 'M2_UEF_Land_Attack_Chain_2'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('HeavyTanks', quantity[Difficulty])

    quantity = {6, 7, 8}
    trigger = {50, 40, 30}
    opai = UEFM2ForwardBase4:AddOpAI('BasicLandAttack', 'M2_UEF_Forward_Base_4_Attack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_UEF_Land_Attack_Chain_1', 'M2_UEF_Land_Attack_Chain_2'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('MobileMissiles', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainGreaterThanOrEqualNumCategory', {'default_brain', 'Player', trigger[Difficulty], categories.DEFENSE * categories.TECH2})

    quantity = {6, 7, 8}
    trigger = {60, 50, 40}
    opai = UEFM2ForwardBase4:AddOpAI('BasicLandAttack', 'M2_UEF_Forward_Base_4_Attack_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_UEF_Land_Attack_Chain_1', 'M2_UEF_Land_Attack_Chain_2'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('MobileFlak', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainGreaterThanOrEqualNumCategory', {'default_brain', 'Player', trigger[Difficulty], categories.AIR * categories.MOBILE})

    for i = 1, 2 do
        quantity = {8, 10, 12}
        trigger = {240, 220, 200}
        opai = UEFM2ForwardBase4:AddOpAI('BasicLandAttack', 'M2_UEF_Forward_Base_4_Attack_4_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
                PlatoonData = {
                    PatrolChains = {'M2_UEF_Land_Attack_Chain_1', 'M2_UEF_Land_Attack_Chain_2'},
                },
                Priority = 120,
            }
        )
        opai:SetChildQuantity({'HeavyTanks', 'MobileShields'}, quantity[Difficulty])
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
            'BrainGreaterThanOrEqualNumCategory', {'default_brain', 'Player', trigger[Difficulty], categories.ALLUNITS - categories.WALL})
    end

    quantity = {6, 7, 8}
    trigger = {30, 25, 20}
    opai = UEFM2ForwardBase4:AddOpAI('BasicLandAttack', 'M2_UEF_Forward_Base_4_Attack_5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_UEF_Land_Attack_Chain_1', 'M2_UEF_Land_Attack_Chain_2'},
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('SiegeBots', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainGreaterThanOrEqualNumCategory', {'default_brain', 'Player', trigger[Difficulty], categories.LAND * categories.TECH3})

    quantity = {6, 7, 8}
    trigger = {50, 45, 40}
    opai = UEFM2ForwardBase4:AddOpAI('BasicLandAttack', 'M2_UEF_Forward_Base_4_Attack_6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_UEF_Land_Attack_Chain_1', 'M2_UEF_Land_Attack_Chain_2'},
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('HeavyBots', quantity[Difficulty])
    opai:SetFormation('AttackFormation')
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainGreaterThanOrEqualNumCategory', {'default_brain', 'Player', trigger[Difficulty], categories.LAND * categories.TECH3 * categories.MOBILE})
end

function UEFM2ForwardBase4AirAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    quantity = {4, 6, 8}
    trigger = {11, 9, 7}
    opai = UEFM2ForwardBase4:AddOpAI('AirAttacks', 'M2_UEF_Forward_Base_4_AirAttack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_UEF_Land_Attack_Chain_1',
                                'M2_UEF_Land_Attack_Chain_2',
                                'M2_UEF_Land_Attack_Chain_3',
                                'M2_UEF_Land_Attack_Chain_4',
                                'M2_UEF_Air_Attack_Chain_1'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainGreaterThanOrEqualNumCategory', {'default_brain', 'Player', trigger[Difficulty], categories.AIR * categories.MOBILE * categories.TECH3})

    quantity = {2, 3, 4}
    trigger = {9, 7, 5}
    opai = UEFM2ForwardBase4:AddOpAI('AirAttacks', 'M2_UEF_Forward_Base_4_AirAttack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_UEF_Land_Attack_Chain_1',
                                'M2_UEF_Land_Attack_Chain_2',
                                'M2_UEF_Land_Attack_Chain_3',
                                'M2_UEF_Land_Attack_Chain_4',
                                'M2_UEF_Air_Attack_Chain_1'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('StratBombers', quantity[Difficulty])
    opai:SetFormation('NoFormation')
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainGreaterThanOrEqualNumCategory', {'default_brain', 'Player', trigger[Difficulty], categories.AIR * categories.MOBILE * categories.TECH3})
end