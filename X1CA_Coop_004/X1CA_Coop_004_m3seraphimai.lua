-- ****************************************************************************
-- **
-- **  File     : /maps/X1CA_Coop_004/X1CA_Coop_004_v04_m3seraphimai.lua
-- **  Author(s): Jessica St. Croix
-- **
-- **  Summary  : Seraphim army AI for Mission 3 - X1CA_Coop_004
-- **
-- **  Copyright © 2007 Gas Powered Games, Inc.  All rights reserved.
-- ****************************************************************************
local BaseManager = import('/lua/ai/opai/basemanager.lua')

local SPAIFileName = '/lua/ScenarioPlatoonAI.lua'

-- ------
-- Locals
-- ------
local Player = 1
local Seraphim = 3
local Difficulty = ScenarioInfo.Options.Difficulty

-- -------------
-- Base Managers
-- -------------
local SeraphimM3SouthWest = BaseManager.CreateBaseManager()
local SeraphimM3South = BaseManager.CreateBaseManager()
local SeraphimM3SouthEast = BaseManager.CreateBaseManager()
local SeraphimM3EastSouthEast = BaseManager.CreateBaseManager()
local SeraphimM3East = BaseManager.CreateBaseManager()
local SeraphimM3NorthEast = BaseManager.CreateBaseManager()
local SeraphimM3North = BaseManager.CreateBaseManager()
local SeraphimM3NorthWest = BaseManager.CreateBaseManager()
local SeraphimM3West = BaseManager.CreateBaseManager()

function SeraphimM3SouthWestAI()

    -- ----------------------
    -- Seraphim M3 South West
    -- ----------------------
    SeraphimM3SouthWest:InitializeDifficultyTables(ArmyBrains[Seraphim], 'M3_SouthWest', 'M3_SouthWest_Marker', 50, {M3_SouthWest = 100,})
    SeraphimM3SouthWest:StartNonZeroBase({{7, 7, 7}, {7, 7, 7}})

    SeraphimM3SouthWestLandAttacks()
end

function SeraphimM3SouthWestLandAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    -- ------------------------------------------
    -- Seraphim M3 South West Op AI, Land Attacks
    -- ------------------------------------------

    -- sends 3, 5, 10 [heavy bots]
    quantity = {3, 5, 10}
    opai = SeraphimM3SouthWest:AddOpAI('BasicLandAttack', 'M3_LandAttackSW1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_SouthWest_LandAttack_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('HeavyBots', quantity[Difficulty])
    opai:SetLockingStyle('None')

    -- sends 3, 5, 10 [mobile missiles]
    quantity = {3, 5, 10}
    opai = SeraphimM3SouthWest:AddOpAI('BasicLandAttack', 'M3_LandAttackSW2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_SouthWest_LandAttack_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('MobileMissiles', quantity[Difficulty])
    opai:SetLockingStyle('None')

    -- sends 3, 5, 10 [heavy tanks]
    quantity = {3, 5, 10}
    opai = SeraphimM3SouthWest:AddOpAI('BasicLandAttack', 'M3_LandAttackSW3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_SouthWest_LandAttack_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('HeavyTanks', quantity[Difficulty])
    opai:SetLockingStyle('None')

    -- sends 2, 3, 5 [siege bots]
    quantity = {2, 3, 5}
    opai = SeraphimM3SouthWest:AddOpAI('BasicLandAttack', 'M3_LandAttackSW4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_SouthWest_LandAttack_Chain',
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('SiegeBots', quantity[Difficulty])

    -- sends 0, 1, 3 [mobile heavy artillery]
    if(Difficulty > 1) then
        quantity = {0, 1, 3}
        opai = SeraphimM3SouthWest:AddOpAI('BasicLandAttack', 'M3_LandAttackSW5',
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M3_SouthWest_LandAttack_Chain',
                },
                Priority = 110,
            }
        )
        opai:SetChildQuantity('MobileHeavyArtillery', quantity[Difficulty])
    end

    -- sends 4, 10, 14 [mobile flak,  mobile shields] if player has > 40, 30, 20 T2/T3 planes
    quantity = {4, 10, 14}
    trigger = {40, 30, 20}
    opai = SeraphimM3SouthWest:AddOpAI('BasicLandAttack', 'M3_LandAttackSW6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_SouthWest_LandAttack_Chain',
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity({'MobileFlak', 'MobileShields'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], (categories.AIR * categories.MOBILE) - categories.TECH1})

    -- sends 3, 5, 10 [siege bots] if player has > 60, 40, 30 T2/T3 land units
    quantity = {3, 5, 10}
    trigger = {60, 40, 30}
    opai = SeraphimM3SouthWest:AddOpAI('BasicLandAttack', 'M3_LandAttackSW7',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_SouthWest_LandAttack_Chain',
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('SiegeBots', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], (categories.LAND * categories.MOBILE) - categories.TECH1})

    -- sends 3, 5, 10 [siege bots] if player has > 60, 40, 30 T2/T3 defense structures + artillery
    quantity = {3, 5, 10}
    trigger = {60, 40, 30}
    opai = SeraphimM3SouthWest:AddOpAI('BasicLandAttack', 'M3_LandAttackSW8',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_SouthWest_LandAttack_Chain',
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('SiegeBots', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], ((categories.DEFENSE * categories.STRUCTURE) + (categories.ARTILLERY)) - categories.TECH1})

    -- sends 3, 5, 5 [mobile heavy artillery] if player has > 450, 400, 350 units
    quantity = {3, 5, 5}
    trigger = {450, 400, 350}
    opai = SeraphimM3SouthWest:AddOpAI('BasicLandAttack', 'M3_LandAttackSW9',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_SouthWest_LandAttack_Chain',
            },
            Priority = 140,
        }
    )
    opai:SetChildQuantity('MobileHeavyArtillery', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.ALLUNITS - categories.WALL})
end

function SeraphimM3SouthAI()

    -- -----------------
    -- Seraphim M3 South
    -- -----------------
    SeraphimM3South:InitializeDifficultyTables(ArmyBrains[Seraphim], 'M3_South', 'M3_South_Marker', 50, {M3_South = 100,})
    SeraphimM3South:StartNonZeroBase({{7, 7, 7}, {7, 7, 7}})

    SeraphimM3South:AddReactiveAI('ExperimentalLand', 'AirRetaliation', 'SeraphimM3South_ExperimentalLand')
    SeraphimM3South:AddReactiveAI('ExperimentalAir', 'AirRetaliation', 'SeraphimM3South_ExperimentalAir')
    SeraphimM3South:AddReactiveAI('Nuke', 'AirRetaliation', 'SeraphimM3South_Nuke')
    SeraphimM3South:AddReactiveAI('HLRA', 'AirRetaliation', 'SeraphimM3South_HLRA')

    SeraphimM3SouthAirAttacks()
end

function SeraphimM3SouthAirAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    -- ------------------------------------
    -- Seraphim M3 South Op AI, Air Attacks
    -- ------------------------------------

    -- sends 10, 15, 20 [bombers]
    quantity = {10, 15, 20}
    opai = SeraphimM3South:AddOpAI('AirAttacks', 'M3_AirAttackS1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Seraph_AirAttack_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Bombers', quantity[Difficulty])
    opai:SetLockingStyle('None')

    -- sends 5, 10, 15 [gunships]
    quantity = {5, 10, 15}
    opai = SeraphimM3South:AddOpAI('AirAttacks', 'M3_AirAttackS2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Seraph_AirAttack_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    opai:SetLockingStyle('None')

    -- sends 5, 10, 15 [combat fighters]
    quantity = {5, 10, 15}
    opai = SeraphimM3South:AddOpAI('AirAttacks', 'M3_AirAttackS3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Seraph_AirAttack_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('CombatFighters', quantity[Difficulty])
    opai:SetLockingStyle('None')

    -- sends 5, 10, 15 [air superiority fighters]
    quantity = {5, 10, 15}
    opai = SeraphimM3South:AddOpAI('AirAttacks', 'M3_AirAttackS4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Seraph_AirAttack_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])

    -- sends 5, 10, 15 [air superiority] if player has > 40, 30, 20 T2/T3 planes
    quantity = {5, 10, 15}
    trigger = {40, 30, 20}
    opai = SeraphimM3South:AddOpAI('AirAttacks', 'M3_AirAttackS5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Seraph_AirAttack_Chain',
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], (categories.AIR * categories.MOBILE) - categories.TECH1})

    -- sends 5, 10, 15 [gunships] if player has > 60, 40, 30 T2/T3 land units
    quantity = {5, 10, 15}
    trigger = {60, 40, 30}
    opai = SeraphimM3South:AddOpAI('AirAttacks', 'M3_AirAttackS6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Seraph_AirAttack_Chain',
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], (categories.LAND * categories.MOBILE) - categories.TECH1})

    -- sends 5, 10, 15 [combat fighters] if player has > 80, 60, 40 T2/T3 planes
    quantity = {5, 10, 15}
    trigger = {80, 60, 40}
    opai = SeraphimM3South:AddOpAI('AirAttacks', 'M3_AirAttackS7',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Seraph_AirAttack_Chain',
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], (categories.AIR * categories.MOBILE) - categories.TECH1})

    -- sends 5, 10, 15 [gunships] if player has > 60, 40, 30 T2/T3 defense structures + artillery
    quantity = {5, 10, 15}
    trigger = {60, 40, 30}
    opai = SeraphimM3South:AddOpAI('AirAttacks', 'M3_AirAttackS8',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Seraph_AirAttack_Chain',
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], ((categories.DEFENSE * categories.STRUCTURE) + (categories.ARTILLERY)) - categories.TECH1})

    -- sends 5, 10, 15 [gunships] if player has > 450, 400, 350 units
    quantity = {5, 10, 15}
    trigger = {450, 400, 350}
    opai = SeraphimM3South:AddOpAI('AirAttacks', 'M3_AirAttackS9',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Seraph_AirAttack_Chain',
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.ALLUNITS - categories.WALL})
end

function SeraphimM3SouthEastAI()

    -- ----------------------
    -- Seraphim M3 South East
    -- ----------------------
    SeraphimM3SouthEast:InitializeDifficultyTables(ArmyBrains[Seraphim], 'M3_SouthEast', 'M3_SouthEast_Marker', 50, {M3_SouthEast = 100,})
    SeraphimM3SouthEast:StartNonZeroBase({{7, 7, 7}, {7, 7, 7}})

    SeraphimM3SouthEastLandAttacks()
end

function SeraphimM3SouthEastLandAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    -- ------------------------------------------
    -- Seraphim M3 South East Op AI, Land Attacks
    -- ------------------------------------------

    -- sends 3, 5, 10 [heavy bots]
    quantity = {3, 5, 10}
    opai = SeraphimM3SouthEast:AddOpAI('BasicLandAttack', 'M3_LandAttackSE1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_SouthEast_LandAttack_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('HeavyBots', quantity[Difficulty])
    opai:SetLockingStyle('None')

    -- sends 3, 5, 10 [mobile missiles]
    quantity = {3, 5, 10}
    opai = SeraphimM3SouthEast:AddOpAI('BasicLandAttack', 'M3_LandAttackSE2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_SouthEast_LandAttack_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('MobileMissiles', quantity[Difficulty])
    opai:SetLockingStyle('None')

    -- sends 3, 5, 10[heavy tanks]
    quantity = {3, 5, 10}
    opai = SeraphimM3SouthEast:AddOpAI('BasicLandAttack', 'M3_LandAttackSE3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_SouthEast_LandAttack_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('HeavyTanks', quantity[Difficulty])
    opai:SetLockingStyle('None')

    -- sends 2, 3, 5 [siege bots]
    quantity = {2, 3, 5}
    opai = SeraphimM3SouthEast:AddOpAI('BasicLandAttack', 'M3_LandAttackSE4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_SouthEast_LandAttack_Chain',
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('SiegeBots', quantity[Difficulty])

    -- sends 0, 1, 3 [mobile heavy artillery]
    if(Difficulty > 1) then
        quantity = {0, 1, 3}
        opai = SeraphimM3SouthEast:AddOpAI('BasicLandAttack', 'M3_LandAttackSE5',
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M3_SouthEast_LandAttack_Chain',
                },
                Priority = 110,
            }
        )
        opai:SetChildQuantity('MobileHeavyArtillery', quantity[Difficulty])
    end

    -- sends 4, 10, 14 [mobile flak,  mobile shields] if player has > 40, 30, 20 T2/T3 planes
    quantity = {4, 10, 14}
    trigger = {40, 30, 20}
    opai = SeraphimM3SouthEast:AddOpAI('BasicLandAttack', 'M3_LandAttackSE6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_SouthEast_LandAttack_Chain',
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity({'MobileFlak', 'MobileShields'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], (categories.AIR * categories.MOBILE) - categories.TECH1})

    -- sends 3, 5, 10 [siege bots] if player has > 60, 40, 30 T2/T3 land units
    quantity = {3, 5, 10}
    trigger = {60, 40, 30}
    opai = SeraphimM3SouthEast:AddOpAI('BasicLandAttack', 'M3_LandAttackSE7',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_SouthEast_LandAttack_Chain',
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('SiegeBots', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], (categories.LAND * categories.MOBILE) - categories.TECH1})

    -- sends 3, 5, 10 [siege bots] if player has > 60, 40, 30 T2/T3 defense structures + artillery
    quantity = {3, 5, 10}
    trigger = {60, 40, 30}
    opai = SeraphimM3SouthEast:AddOpAI('BasicLandAttack', 'M3_LandAttackSE8',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_SouthEast_LandAttack_Chain',
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('SiegeBots', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], ((categories.DEFENSE * categories.STRUCTURE) + (categories.ARTILLERY)) - categories.TECH1})

    -- sends 3, 5, 5 [mobile heavy artillery] if player has > 450, 400, 350 units
    quantity = {3, 5, 5}
    trigger = {450, 400, 350}
    opai = SeraphimM3SouthEast:AddOpAI('BasicLandAttack', 'M3_LandAttackSE9',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_SouthEast_LandAttack_Chain',
            },
            Priority = 140,
        }
    )
    opai:SetChildQuantity('MobileHeavyArtillery', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.ALLUNITS - categories.WALL})
end

function SeraphimM3EastSouthEastAI()

    -- ---------------------------
    -- Seraphim M3 East South East
    -- ---------------------------
    SeraphimM3EastSouthEast:InitializeDifficultyTables(ArmyBrains[Seraphim], 'M3_EastSouthEast', 'M3_EastSouthEast_Marker', 50, {M3_EastSouthEast = 100,})
    SeraphimM3EastSouthEast:StartNonZeroBase({{7, 7, 7}, {7, 7, 7}})

    SeraphimM3EastSouthEast:AddReactiveAI('ExperimentalLand', 'AirRetaliation', 'SeraphimM3EastSouthEast_ExperimentalLand')
    SeraphimM3EastSouthEast:AddReactiveAI('ExperimentalAir', 'AirRetaliation', 'SeraphimM3EastSouthEast_ExperimentalAir')
    SeraphimM3EastSouthEast:AddReactiveAI('Nuke', 'AirRetaliation', 'SeraphimM3EastSouthEast_Nuke')
    SeraphimM3EastSouthEast:AddReactiveAI('HLRA', 'AirRetaliation', 'SeraphimM3EastSouthEast_HLRA')

    SeraphimM3EastSouthEastAirAttacks()
end

function SeraphimM3EastSouthEastAirAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    -- ----------------------------------------------
    -- Seraphim M3 East South East Op AI, Air Attacks
    -- ----------------------------------------------

    -- sends 5, 10, 15 [bombers]
    quantity = {5, 10, 15}
    opai = SeraphimM3EastSouthEast:AddOpAI('AirAttacks', 'M3_AirAttackESE1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Seraph_AirAttack_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Bombers', quantity[Difficulty])
    opai:SetLockingStyle('None')

    -- sends 5, 10, 15 [gunships]
    quantity = {5, 10, 15}
    opai = SeraphimM3EastSouthEast:AddOpAI('AirAttacks', 'M3_AirAttackESE2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Seraph_AirAttack_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    opai:SetLockingStyle('None')

    -- sends 5, 10, 15 [combat fighters]
    quantity = {5, 10, 15}
    opai = SeraphimM3EastSouthEast:AddOpAI('AirAttacks', 'M3_AirAttackESE3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Seraph_AirAttack_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('CombatFighters', quantity[Difficulty])
    opai:SetLockingStyle('None')

    -- sends 5, 10, 15 [air superiority fighters]
    quantity = {5, 10, 15}
    opai = SeraphimM3EastSouthEast:AddOpAI('AirAttacks', 'M3_AirAttackESE4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Seraph_AirAttack_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])

    -- sends 5, 10, 15 [air superiority] if player has > 40, 30, 20 T2/T3 planes
    quantity = {5, 10, 15}
    trigger = {40, 30, 20}
    opai = SeraphimM3EastSouthEast:AddOpAI('AirAttacks', 'M3_AirAttackESE5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Seraph_AirAttack_Chain',
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], (categories.AIR * categories.MOBILE) - categories.TECH1})

    -- sends 5, 10, 15 [gunships] if player has > 60, 40, 30 T2/T3 land units
    quantity = {5, 10, 15}
    trigger = {60, 40, 30}
    opai = SeraphimM3EastSouthEast:AddOpAI('AirAttacks', 'M3_AirAttackESE6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Seraph_AirAttack_Chain',
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], (categories.LAND * categories.MOBILE) - categories.TECH1})

    -- sends 5, 10, 15 [combat fighters] if player has > 80, 60, 40 T2/T3 planes
    quantity = {5, 10, 15}
    trigger = {80, 60, 40}
    opai = SeraphimM3EastSouthEast:AddOpAI('AirAttacks', 'M3_AirAttackESE7',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Seraph_AirAttack_Chain',
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], (categories.AIR * categories.MOBILE) - categories.TECH1})

    -- sends 5, 10, 15 [gunships] if player has > 60, 40, 30 T2/T3 defense structures + artillery
    quantity = {5, 10, 15}
    trigger = {60, 40, 30}
    opai = SeraphimM3EastSouthEast:AddOpAI('AirAttacks', 'M3_AirAttackESE8',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Seraph_AirAttack_Chain',
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], ((categories.DEFENSE * categories.STRUCTURE) + (categories.ARTILLERY)) - categories.TECH1})

    -- sends 5, 10, 15 [gunships] if player has > 450, 400, 350 units
    quantity = {5, 10, 15}
    trigger = {450, 400, 350}
    opai = SeraphimM3EastSouthEast:AddOpAI('AirAttacks', 'M3_AirAttackESE9',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Seraph_AirAttack_Chain',
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.ALLUNITS - categories.WALL})
end

function SeraphimM3EastAI()

    -- ----------------
    -- Seraphim M3 East
    -- ----------------
    SeraphimM3East:InitializeDifficultyTables(ArmyBrains[Seraphim], 'M3_East', 'M3_East_Marker', 50, {M3_East = 100,})
    SeraphimM3East:StartNonZeroBase({{7, 7, 7}, {7, 7, 7}})

    SeraphimM3EastLandAttacks()
end

function SeraphimM3EastLandAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    -- ------------------------------------
    -- Seraphim M3 East Op AI, Land Attacks
    -- ------------------------------------

    -- sends 3, 5, 10 [heavy bots]
    quantity = {3, 5, 10}
    opai = SeraphimM3East:AddOpAI('BasicLandAttack', 'M3_LandAttackE1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_East_LandAttack_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('HeavyBots', quantity[Difficulty])
    opai:SetLockingStyle('None')

    -- sends 3, 5, 10 [mobile missiles]
    quantity = {3, 5, 10}
    opai = SeraphimM3East:AddOpAI('BasicLandAttack', 'M3_LandAttackE2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_East_LandAttack_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('MobileMissiles', quantity[Difficulty])
    opai:SetLockingStyle('None')

    -- sends 3, 5, 10 [heavy tanks]
    quantity = {3, 5, 10}
    opai = SeraphimM3East:AddOpAI('BasicLandAttack', 'M3_LandAttackE3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_East_LandAttack_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('HeavyTanks', quantity[Difficulty])
    opai:SetLockingStyle('None')

    -- sends 2, 3, 5 [siege bots]
    quantity = {2, 3, 5}
    opai = SeraphimM3East:AddOpAI('BasicLandAttack', 'M3_LandAttackE4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_East_LandAttack_Chain',
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('SiegeBots', quantity[Difficulty])

    -- sends 0, 1, 3 [mobile heavy artillery]
    if(Difficulty > 1) then
        quantity = {0, 1, 3}
        opai = SeraphimM3East:AddOpAI('BasicLandAttack', 'M3_LandAttackE5',
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M3_East_LandAttack_Chain',
                },
                Priority = 110,
            }
        )
        opai:SetChildQuantity('MobileHeavyArtillery', quantity[Difficulty])
    end

    -- sends 4, 10, 14 [mobile flak,  mobile shields] if player has > 40, 30, 20 T2/T3 planes
    quantity = {4, 10, 14}
    trigger = {40, 30, 20}
    opai = SeraphimM3East:AddOpAI('BasicLandAttack', 'M3_LandAttackE6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_East_LandAttack_Chain',
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity({'MobileFlak', 'MobileShields'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], (categories.AIR * categories.MOBILE) - categories.TECH1})

    -- sends 3, 5, 10 [siege bots] if player has > 60, 40, 30 T2/T3 land units
    quantity = {3, 5, 10}
    trigger = {60, 40, 30}
    opai = SeraphimM3East:AddOpAI('BasicLandAttack', 'M3_LandAttackE7',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_East_LandAttack_Chain',
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('SiegeBots', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], (categories.LAND * categories.MOBILE) - categories.TECH1})

    -- sends 3, 5, 10 [siege bots] if player has > 60, 40, 30 T2/T3 defense structures + artillery
    quantity = {3, 5, 10}
    trigger = {60, 40, 30}
    opai = SeraphimM3East:AddOpAI('BasicLandAttack', 'M3_LandAttackE8',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_East_LandAttack_Chain',
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('SiegeBots', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], ((categories.DEFENSE * categories.STRUCTURE) + (categories.ARTILLERY)) - categories.TECH1})

    -- sends 3, 5, 5 [mobile heavy artillery] if player has > 450, 400, 350 units
    quantity = {3, 5, 5}
    trigger = {450, 400, 350}
    opai = SeraphimM3East:AddOpAI('BasicLandAttack', 'M3_LandAttackE9',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_East_LandAttack_Chain',
            },
            Priority = 140,
        }
    )
    opai:SetChildQuantity('MobileHeavyArtillery', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.ALLUNITS - categories.WALL})
end

function SeraphimM3NorthEastAI()

    -- ----------------------
    -- Seraphim M3 North East
    -- ----------------------
    SeraphimM3NorthEast:InitializeDifficultyTables(ArmyBrains[Seraphim], 'M3_NorthEast', 'M3_NorthEast_Marker', 50, {M3_NorthEast = 100,})
    SeraphimM3NorthEast:StartNonZeroBase({{7, 7, 7}, {7, 7, 7}})

    SeraphimM3NorthEastLandAttacks()
end

function SeraphimM3NorthEastLandAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    -- ------------------------------------------
    -- Seraphim M3 North East Op AI, Land Attacks
    -- ------------------------------------------

    -- sends 3, 5, 10 [heavy bots]
    quantity = {3, 5, 10}
    opai = SeraphimM3NorthEast:AddOpAI('BasicLandAttack', 'M3_LandAttackNE1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_NorthEast_LandAttack_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('HeavyBots', quantity[Difficulty])
    opai:SetLockingStyle('None')

    -- sends 3, 5, 10 [mobile missiles]
    quantity = {3, 5, 10}
    opai = SeraphimM3NorthEast:AddOpAI('BasicLandAttack', 'M3_LandAttackNE2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_NorthEast_LandAttack_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('MobileMissiles', quantity[Difficulty])
    opai:SetLockingStyle('None')

    -- sends 3, 5, 10 [heavy tanks]
    quantity = {3, 5, 10}
    opai = SeraphimM3NorthEast:AddOpAI('BasicLandAttack', 'M3_LandAttackNE3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_NorthEast_LandAttack_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('HeavyTanks', quantity[Difficulty])
    opai:SetLockingStyle('None')

    -- sends 2, 3, 5 [siege bots]
    quantity = {2, 3, 5}
    opai = SeraphimM3NorthEast:AddOpAI('BasicLandAttack', 'M3_LandAttackNE4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_NorthEast_LandAttack_Chain',
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('SiegeBots', quantity[Difficulty])

    -- sends 0, 1, 3 [mobile heavy artillery]
    if(Difficulty > 1) then
        quantity = {0, 1, 3}
        opai = SeraphimM3NorthEast:AddOpAI('BasicLandAttack', 'M3_LandAttackNE5',
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M3_NorthEast_LandAttack_Chain',
                },
                Priority = 110,
            }
        )
        opai:SetChildQuantity('MobileHeavyArtillery', quantity[Difficulty])
    end

    -- sends 4, 10, 14 [mobile flak,  mobile shields] if player has > 40, 30, 20 T2/T3 planes
    quantity = {4, 10, 14}
    trigger = {40, 30, 20}
    opai = SeraphimM3NorthEast:AddOpAI('BasicLandAttack', 'M3_LandAttackNE6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_NorthEast_LandAttack_Chain',
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity({'MobileFlak', 'MobileShields'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], (categories.AIR * categories.MOBILE) - categories.TECH1})

    -- sends 3, 5, 10 [siege bots] if player has > 60, 40, 30 T2/T3 land units
    quantity = {3, 5, 10}
    trigger = {60, 40, 30}
    opai = SeraphimM3NorthEast:AddOpAI('BasicLandAttack', 'M3_LandAttackNE7',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_NorthEast_LandAttack_Chain',
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('SiegeBots', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], (categories.LAND * categories.MOBILE) - categories.TECH1})

    -- sends 3, 5, 10 [siege bots] if player has > 60, 40, 30 T2/T3 defense structures + artillery
    quantity = {3, 5, 10}
    trigger = {60, 40, 30}
    opai = SeraphimM3NorthEast:AddOpAI('BasicLandAttack', 'M3_LandAttackNE8',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_NorthEast_LandAttack_Chain',
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('SiegeBots', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], ((categories.DEFENSE * categories.STRUCTURE) + (categories.ARTILLERY)) - categories.TECH1})

    -- sends 3, 5, 5 [mobile heavy artillery] if player has > 450, 400, 350 units
    quantity = {3, 5, 5}
    trigger = {450, 400, 350}
    opai = SeraphimM3NorthEast:AddOpAI('BasicLandAttack', 'M3_LandAttackNE9',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_NorthEast_LandAttack_Chain',
            },
            Priority = 140,
        }
    )
    opai:SetChildQuantity('MobileHeavyArtillery', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.ALLUNITS - categories.WALL})
end

function SeraphimM3NorthAI()

    -- -----------------
    -- Seraphim M3 North
    -- -----------------
    SeraphimM3North:InitializeDifficultyTables(ArmyBrains[Seraphim], 'M3_North', 'M3_North_Marker', 50, {M3_North = 100,})
    SeraphimM3North:StartNonZeroBase({{7, 7, 7}, {7, 7, 7}})

    SeraphimM3North:AddReactiveAI('ExperimentalLand', 'AirRetaliation', 'SeraphimM3North_ExperimentalLand')
    SeraphimM3North:AddReactiveAI('ExperimentalAir', 'AirRetaliation', 'SeraphimM3North_ExperimentalAir')
    SeraphimM3North:AddReactiveAI('Nuke', 'AirRetaliation', 'SeraphimM3North_Nuke')
    SeraphimM3North:AddReactiveAI('HLRA', 'AirRetaliation', 'SeraphimM3North_HLRA')

    SeraphimM3NorthAirAttacks()
end

function SeraphimM3NorthAirAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    -- ------------------------------------
    -- Seraphim M3 North Op AI, Air Attacks
    -- ------------------------------------

    -- sends 4, 8, 12 [bombers]
    quantity = {4, 8, 12}
    opai = SeraphimM3North:AddOpAI('AirAttacks', 'M3_AirAttackN1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Seraph_AirAttack_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Bombers', quantity[Difficulty])
    opai:SetLockingStyle('None')

    -- sends 4, 8, 12 [gunships]
    quantity = {4, 8, 12}
    opai = SeraphimM3North:AddOpAI('AirAttacks', 'M3_AirAttackN2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Seraph_AirAttack_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    opai:SetLockingStyle('None')

    -- sends 4, 8, 12 [combat fighters]
    quantity = {4, 8, 12}
    opai = SeraphimM3North:AddOpAI('AirAttacks', 'M3_AirAttackN3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Seraph_AirAttack_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('CombatFighters', quantity[Difficulty])
    opai:SetLockingStyle('None')

    -- sends 4, 8, 12 [air superiority fighters]
    quantity = {4, 8, 12}
    opai = SeraphimM3North:AddOpAI('AirAttacks', 'M3_AirAttackN4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Seraph_AirAttack_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])

    -- sends 4, 8, 12 [air superiority] if player has > 40, 30, 20 T2/T3 planes
    quantity = {4, 8, 12}
    trigger = {40, 30, 20}
    opai = SeraphimM3North:AddOpAI('AirAttacks', 'M3_AirAttackN5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Seraph_AirAttack_Chain',
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], (categories.AIR * categories.MOBILE) - categories.TECH1})

    -- sends 4, 8, 12 [gunships] if player has > 60, 40, 30 T2/T3 land units
    quantity = {4, 8, 12}
    trigger = {60, 40, 30}
    opai = SeraphimM3North:AddOpAI('AirAttacks', 'M3_AirAttackN6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Seraph_AirAttack_Chain',
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], (categories.LAND * categories.MOBILE) - categories.TECH1})

    -- sends 4, 8, 12 [combat fighters] if player has > 80, 60, 40 T2/T3 planes
    quantity = {4, 8, 12}
    trigger = {80, 60, 40}
    opai = SeraphimM3North:AddOpAI('AirAttacks', 'M3_AirAttackN7',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Seraph_AirAttack_Chain',
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], (categories.AIR * categories.MOBILE) - categories.TECH1})

    -- sends 4, 8, 12 [gunships] if player has > 60, 40, 30 T2/T3 defense structures + artillery
    quantity = {4, 8, 12}
    trigger = {60, 40, 30}
    opai = SeraphimM3North:AddOpAI('AirAttacks', 'M3_AirAttackN8',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Seraph_AirAttack_Chain',
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], ((categories.DEFENSE * categories.STRUCTURE) + (categories.ARTILLERY)) - categories.TECH1})

    -- sends 4, 8, 12 [gunships] if player has > 450, 400, 350 units
    quantity = {4, 8, 12}
    trigger = {450, 400, 350}
    opai = SeraphimM3North:AddOpAI('AirAttacks', 'M3_AirAttackN9',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Seraph_AirAttack_Chain',
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.ALLUNITS - categories.WALL})

    -- sends [bombers] at player cdr, easy/normal only
    if(Difficulty < 3) then
        quantity = {4, 12}
        opai = SeraphimM3North:AddOpAI('AirAttacks', 'M3_AirAttackN10',
            {
                MasterPlatoonFunction = {'/maps/X1CA_Coop_004/X1CA_Coop_004_v04_m3seraphimai.lua', 'M3AttackCDRAI'},
                Priority = 140,
            }
        )
        opai:SetChildQuantity('Bombers', quantity[Difficulty])
    end

    -- sends [gunships] at player cdr, hard only
    if(Difficulty == 3) then
        opai = SeraphimM3North:AddOpAI('AirAttacks', 'M3_AirAttackN11',
            {
                MasterPlatoonFunction = {'/maps/X1CA_Coop_004/X1CA_Coop_004_v04_m3seraphimai.lua', 'M3AttackCDRAI'},
                Priority = 140,
            }
        )
        opai:SetChildQuantity('Gunships', 12)
    end
end

function M3AttackCDRAI(platoon)
    local commander = ArmyBrains[Player]:GetListOfUnits(categories.COMMAND, false)
    if(commander[1] and not commander[1]:IsDead()) then
        platoon:AttackTarget(commander[1])
    else
        ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_Seraph_AirAttack_Chain')
    end
end

function SeraphimM3NorthWestAI()

    -- ----------------------
    -- Seraphim M3 North West
    -- ----------------------
    SeraphimM3NorthWest:InitializeDifficultyTables(ArmyBrains[Seraphim], 'M3_NorthWest', 'M3_NorthWest_Marker', 50, {M3_NorthWest = 100,})
    SeraphimM3NorthWest:StartNonZeroBase({{7, 7, 7}, {7, 7, 7}})

    SeraphimM3NorthWestLandAttacks()
end

function SeraphimM3NorthWestLandAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    -- ------------------------------------------
    -- Seraphim M3 North West Op AI, Land Attacks
    -- ------------------------------------------

    -- sends 3, 5, 10 [heavy bots]
    quantity = {3, 5, 10}
    opai = SeraphimM3NorthWest:AddOpAI('BasicLandAttack', 'M3_LandAttackNW1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_NorthWest_LandAttack_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('HeavyBots', quantity[Difficulty])
    opai:SetLockingStyle('None')

    -- sends 3, 5, 10 [mobile missiles]
    quantity = {3, 5, 10}
    opai = SeraphimM3NorthWest:AddOpAI('BasicLandAttack', 'M3_LandAttackNW2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_NorthWest_LandAttack_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('MobileMissiles', quantity[Difficulty])
    opai:SetLockingStyle('None')

    -- sends 3, 5, 10 [heavy tanks]
    quantity = {3, 5, 10}
    opai = SeraphimM3NorthWest:AddOpAI('BasicLandAttack', 'M3_LandAttackNW3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_NorthWest_LandAttack_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('HeavyTanks', quantity[Difficulty])
    opai:SetLockingStyle('None')

    -- sends 2, 3, 5 [siege bots]
    quantity = {2, 3, 5}
    opai = SeraphimM3NorthWest:AddOpAI('BasicLandAttack', 'M3_LandAttackNW4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_NorthWest_LandAttack_Chain',
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('SiegeBots', quantity[Difficulty])

    -- sends 0, 1, 3 [mobile heavy artillery]
    if(Difficulty > 1) then
        quantity = {0, 1, 3}
        opai = SeraphimM3NorthWest:AddOpAI('BasicLandAttack', 'M3_LandAttackNW5',
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M3_NorthWest_LandAttack_Chain',
                },
                Priority = 110,
            }
        )
        opai:SetChildQuantity('MobileHeavyArtillery', quantity[Difficulty])
    end

    -- sends 4, 10, 14 [mobile flak,  mobile shields] if player has > 40, 30, 20 T2/T3 planes
    quantity = {4, 10, 14}
    trigger = {40, 30, 20}
    opai = SeraphimM3NorthWest:AddOpAI('BasicLandAttack', 'M3_LandAttackNW6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_NorthWest_LandAttack_Chain',
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity({'MobileFlak', 'MobileShields'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], (categories.AIR * categories.MOBILE) - categories.TECH1})

    -- sends 3, 5, 10 [siege bots] if player has > 60, 40, 30 T2/T3 land units
    quantity = {3, 5, 10}
    trigger = {60, 40, 30}
    opai = SeraphimM3NorthWest:AddOpAI('BasicLandAttack', 'M3_LandAttackNW7',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_NorthWest_LandAttack_Chain',
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('SiegeBots', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], (categories.LAND * categories.MOBILE) - categories.TECH1})

    -- sends 3, 5, 10 [siege bots] if player has > 60, 40, 30 T2/T3 defense structures + artillery
    quantity = {3, 5, 10}
    trigger = {60, 40, 30}
    opai = SeraphimM3NorthWest:AddOpAI('BasicLandAttack', 'M3_LandAttackNW8',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_NorthWest_LandAttack_Chain',
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('SiegeBots', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], ((categories.DEFENSE * categories.STRUCTURE) + (categories.ARTILLERY)) - categories.TECH1})

    -- sends 3, 5, 5 [mobile heavy artillery] if player has > 450, 400, 350 units
    quantity = {3, 5, 5}
    trigger = {450, 400, 350}
    opai = SeraphimM3NorthWest:AddOpAI('BasicLandAttack', 'M3_LandAttackNW9',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_NorthWest_LandAttack_Chain',
            },
            Priority = 140,
        }
    )
    opai:SetChildQuantity('MobileHeavyArtillery', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.ALLUNITS - categories.WALL})
end

function SeraphimM3WestAI()

    -- ----------------
    -- Seraphim M3 West
    -- ----------------
    SeraphimM3West:InitializeDifficultyTables(ArmyBrains[Seraphim], 'M3_West', 'M3_West_Marker', 50, {M3_West = 100,})
    SeraphimM3West:StartNonZeroBase({{9, 9, 9}, {9, 9, 9}})

    SeraphimM3West:AddReactiveAI('ExperimentalLand', 'AirRetaliation', 'SeraphimM3West_ExperimentalLand')
    SeraphimM3West:AddReactiveAI('ExperimentalAir', 'AirRetaliation', 'SeraphimM3West_ExperimentalAir')
    SeraphimM3West:AddReactiveAI('Nuke', 'AirRetaliation', 'SeraphimM3West_Nuke')
    SeraphimM3West:AddReactiveAI('HLRA', 'AirRetaliation', 'SeraphimM3West_HLRA')

    SeraphimM3WestAirAttacks()
end

function SeraphimM3WestAirAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    -- -----------------------------------
    -- Seraphim M3 West Op AI, Air Attacks
    -- -----------------------------------

    -- sends 10, 15, 20 [bombers]
    quantity = {10, 15, 20}
    opai = SeraphimM3West:AddOpAI('AirAttacks', 'M3_AirAttackW1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Seraph_AirAttackb_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Bombers', quantity[Difficulty])
    opai:SetLockingStyle('None')

    -- sends 5, 10, 15 [gunships]
    quantity = {5, 10, 15}
    opai = SeraphimM3West:AddOpAI('AirAttacks', 'M3_AirAttackW2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Seraph_AirAttackb_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    opai:SetLockingStyle('None')

    -- sends 5, 10, 15 [combat fighters]
    quantity = {5, 10, 15}
    opai = SeraphimM3West:AddOpAI('AirAttacks', 'M3_AirAttackW3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Seraph_AirAttackb_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('CombatFighters', quantity[Difficulty])
    opai:SetLockingStyle('None')

    -- sends 5, 10, 15 [air superiority fighters]
    quantity = {5, 10, 15}
    opai = SeraphimM3West:AddOpAI('AirAttacks', 'M3_AirAttackW4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Seraph_AirAttackb_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])

    -- sends 5, 10, 15 [air superiority] if player has > 40, 30, 20 T2/T3 planes
    quantity = {5, 10, 15}
    trigger = {40, 30, 20}
    opai = SeraphimM3West:AddOpAI('AirAttacks', 'M3_AirAttackW5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Seraph_AirAttackb_Chain',
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], (categories.AIR * categories.MOBILE) - categories.TECH1})

    -- sends 5, 10, 15 [gunships] if player has > 60, 40, 30 T2/T3 land units
    quantity = {5, 10, 15}
    trigger = {60, 40, 30}
    opai = SeraphimM3West:AddOpAI('AirAttacks', 'M3_AirAttackW6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Seraph_AirAttackb_Chain',
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], (categories.LAND * categories.MOBILE) - categories.TECH1})

    -- sends 5, 10, 15 [combat fighters] if player has > 80, 60, 40 T2/T3 planes
    quantity = {5, 10, 15}
    trigger = {80, 60, 40}
    opai = SeraphimM3West:AddOpAI('AirAttacks', 'M3_AirAttackW7',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Seraph_AirAttackb_Chain',
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], (categories.AIR * categories.MOBILE) - categories.TECH1})

    -- sends 5, 10, 15 [gunships] if player has > 60, 40, 30 T2/T3 defense structures + artillery
    quantity = {5, 10, 15}
    trigger = {60, 40, 30}
    opai = SeraphimM3West:AddOpAI('AirAttacks', 'M3_AirAttackW8',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Seraph_AirAttackb_Chain',
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], ((categories.DEFENSE * categories.STRUCTURE) + (categories.ARTILLERY)) - categories.TECH1})

    -- sends 5, 10, 15 [gunships] if player has > 450, 400, 350 units
    quantity = {5, 10, 15}
    trigger = {450, 400, 350}
    opai = SeraphimM3West:AddOpAI('AirAttacks', 'M3_AirAttackW9',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Seraph_AirAttackb_Chain',
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.ALLUNITS - categories.WALL})
end
