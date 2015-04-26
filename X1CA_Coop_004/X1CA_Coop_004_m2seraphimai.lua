-- ****************************************************************************
-- **
-- **  File     : /maps/X1CA_Coop_004/X1CA_Coop_004_v04_m2seraphimai.lua
-- **  Author(s): Jessica St. Croix
-- **
-- **  Summary  : Seraphim army AI for Mission 2 - X1CA_Coop_004
-- **
-- **  Copyright © 2007 Gas Powered Games, Inc.  All rights reserved.
-- ****************************************************************************
local BaseManager = import('/lua/ai/opai/basemanager.lua')

local SPAIFileName = '/lua/ScenarioPlatoonAI.lua'

-- ------
-- Locals
-- ------
local Seraphim = 3
local Difficulty = ScenarioInfo.Options.Difficulty

-- -------------
-- Base Managers
-- -------------
local SeraphimM2Lower = BaseManager.CreateBaseManager()
local SeraphimM2Upper = BaseManager.CreateBaseManager()

function SeraphimM2LowerAI()

    -- -----------------
    -- Seraphim M2 Lower
    -- -----------------
    SeraphimM2Lower:InitializeDifficultyTables(ArmyBrains[Seraphim], 'M2_Seraph_LowerBase', 'Seraphim_M2_Lower', 50, {M2_Seraph_LowerBase = 100,})
    SeraphimM2Lower:StartNonZeroBase({{3, 5, 7}, {3, 4, 6}})
    SeraphimM2Lower:SetActive('LandScouting', true)
    SeraphimM2Lower:SetBuild('Defenses', false)
	
	SeraphimM2Lower:AddBuildGroup('M1_Seraph_West', 90)

    SeraphimM2LowerLandAttacks()
end

function SeraphimM2LowerLandAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    -- -------------------------------------
    -- Seraphim M2 Lower Op AI, Land Attacks
    -- -------------------------------------

    -- sends 12, 16, 18 [Heavy Tanks] to Dostya
    quantity = {12, 16, 18}
    opai = SeraphimM2Lower:AddOpAI('BasicLandAttack', 'M2_LandAttackDostya_1',
        {
            MasterPlatoonFunction = {'/lua/scenarioplatoonai.lua', 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Seraph_LandAttack_Dostya_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('HeavyTanks', quantity[Difficulty])
    opai:SetLockingStyle('None')
	
	-- sends 12, 16, 18 [Mobile Flak] to Dostya
    quantity = {12, 16, 18}
    opai = SeraphimM2Lower:AddOpAI('BasicLandAttack', 'M2_LandAttackDostya_2',
        {
            MasterPlatoonFunction = {'/lua/scenarioplatoonai.lua', 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Seraph_LandAttack_Dostya_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('MobileFlak', quantity[Difficulty])
    opai:SetLockingStyle('None')

    -- sends 8, 12, 14 [light tanks, heavy tanks]
    quantity = {8, 12, 14}
    opai = SeraphimM2Lower:AddOpAI('BasicLandAttack', 'M2_LandAttack1',
        {
            MasterPlatoonFunction = {'/lua/scenarioplatoonai.lua', 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Seraph_LandAttack_1_Chain', 'M2_Seraph_LandAttack_2_Chain', 'M2_Seraph_LandAttack_3_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'LightTanks', 'HeavyTanks'}, quantity[Difficulty])
    opai:SetLockingStyle('None')

    -- sends 8, 12, 14 [light artillery, mobile missiles]
    quantity = {8, 12, 14}
    opai = SeraphimM2Lower:AddOpAI('BasicLandAttack', 'M2_LandAttack2',
        {
            MasterPlatoonFunction = {'/lua/scenarioplatoonai.lua', 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Seraph_LandAttack_1_Chain', 'M2_Seraph_LandAttack_2_Chain', 'M2_Seraph_LandAttack_3_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'LightArtillery', 'MobileMissiles'}, quantity[Difficulty])
    opai:SetLockingStyle('None')

    -- sends 4, 6, 8 [mobile flak, mobile shields] if player has >= 60, 40, 40 mobile air
    quantity = {4, 6, 8}
    trigger = {60, 40, 40}
    opai = SeraphimM2Lower:AddOpAI('BasicLandAttack', 'M2_LandAttack3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Seraph_LandAttack_1_Chain', 'M2_Seraph_LandAttack_2_Chain', 'M2_Seraph_LandAttack_3_Chain'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'MobileFlak', 'MobileShields'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.MOBILE * categories.AIR})

    -- sends 4, 6, 8 [mobile flak, mobile shields] if player has >= 50, 30, 30 gunships
    quantity = {4, 6, 8}
    trigger = {50, 30, 30}
    opai = SeraphimM2Lower:AddOpAI('BasicLandAttack', 'M2_LandAttack4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Seraph_LandAttack_1_Chain', 'M2_Seraph_LandAttack_2_Chain', 'M2_Seraph_LandAttack_3_Chain'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'MobileFlak', 'MobileShields'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.uaa0203 + categories.uea0203 + categories.ura0203})

    -- sends 6, 8, 10 [siege bots, heavy bots] if player has >= 60, 40, 20 T3 units
    quantity = {6, 8, 10}
    trigger = {60, 40, 20}
    opai = SeraphimM2Lower:AddOpAI('BasicLandAttack', 'M2_LandAttack5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Seraph_LandAttack_1_Chain', 'M2_Seraph_LandAttack_2_Chain', 'M2_Seraph_LandAttack_3_Chain'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity({'SiegeBots', 'HeavyBots'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.TECH3})

    -- sends 4, 6, 7 [mobile flak] if player has >= 1 strat bomber
    quantity = {4, 6, 7}
    opai = SeraphimM2Lower:AddOpAI('BasicLandAttack', 'M2_LandAttack6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Seraph_LandAttack_1_Chain', 'M2_Seraph_LandAttack_2_Chain', 'M2_Seraph_LandAttack_3_Chain'},
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity({'MobileFlak'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', 1, categories.uaa0304 + categories.uea0304 + categories.ura0304})

    -- sends 6, 9, 12 [mobile heavy artillery, mobile missiles, light artillery] if player has >= 450, 400, 350 units
    quantity = {6, 9, 12}
    trigger = {450, 400, 350}
    opai = SeraphimM2Lower:AddOpAI('BasicLandAttack', 'M2_LandAttack7',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Seraph_LandAttack_1_Chain', 'M2_Seraph_LandAttack_2_Chain', 'M2_Seraph_LandAttack_3_Chain'},
            },
            Priority = 140,
        }
    )
    opai:SetChildQuantity({'MobileHeavyArtillery', 'MobileMissiles', 'LightArtillery'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.ALLUNITS - categories.WALL})

    -- Land Defense
    -- Maintains 16, 24, 28 Heavy Tanks
    quantity = {4, 6, 7}
    for i = 1, 4 do
        opai = SeraphimM2Lower:AddOpAI('BasicLandAttack', 'M2_LandDefense1_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M2_Seraph_LandDef_' .. i .. '_Chain',
                },
                Priority = 200,
            }
        )
        opai:SetChildQuantity({'HeavyTanks'}, quantity[Difficulty])
    end

    -- Maintains 12, 18, 21 Mobile Flak
    quantity = {4, 6, 7}
    for i = 1, 3 do
        opai = SeraphimM2Lower:AddOpAI('BasicLandAttack', 'M2_LandDefense2_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M2_Seraph_LandDef_' .. i .. '_Chain',
                },
                Priority = 200,
            }
        )
        opai:SetChildQuantity({'MobileFlak'}, quantity[Difficulty])
    end
end

function SeraphimM2UpperAI()

    -- -----------------
    -- Seraphim M2 Upper
    -- -----------------
    SeraphimM2Upper:InitializeDifficultyTables(ArmyBrains[Seraphim], 'M2_Seraph_UpperBase', 'Seraphim_M2_Upper', 50, {M2_Seraph_UpperBase = 100,})
    SeraphimM2Upper:StartNonZeroBase({{3, 5, 8}, {3, 4, 7}})
    SeraphimM2Upper:SetActive('AirScouting', true)
    SeraphimM2Upper:SetBuild('Defenses', false)

    SeraphimM2Upper:AddReactiveAI('ExperimentalLand', 'AirRetaliation', 'SeraphimM2Upper_ExperimentalLand')
    SeraphimM2Upper:AddReactiveAI('ExperimentalAir', 'AirRetaliation', 'SeraphimM2Upper_ExperimentalAir')
    SeraphimM2Upper:AddReactiveAI('Nuke', 'AirRetaliation', 'SeraphimM2Upper_Nuke')
    SeraphimM2Upper:AddReactiveAI('HLRA', 'AirRetaliation', 'SeraphimM2Upper_HLRA')

    SeraphimM2UpperAirAttacks()
end

function SeraphimM2UpperAirAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    -- ------------------------------------
    -- Seraphim M2 Upper Op AI, Air Attacks
    -- ------------------------------------

    quantity = {12, 16, 18}
    opai = SeraphimM2Lower:AddOpAI('AirAttacks', 'M2_AirAttackDostya_1',
        {
            MasterPlatoonFunction = {'/lua/scenarioplatoonai.lua', 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Seraph_LandAttack_Dostya_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'Gunships', 'CombatFighters'}, quantity[Difficulty])
    opai:SetLockingStyle('None')
	
    -- sends 4, 8, 15 [bombers]
    quantity = {4, 8, 15}
    opai = SeraphimM2Upper:AddOpAI('AirAttacks', 'M2_AirAttacks1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Seraph_AirAttack_1_Chain', 'M2_Seraph_AirAttack_2_Chain', 'M2_Seraph_AirAttack_3_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Bombers', quantity[Difficulty])
    opai:SetLockingStyle('None')

    -- sends 4, 8, 15 [interceptors]
    quantity = {4, 8, 15}
    opai = SeraphimM2Upper:AddOpAI('AirAttacks', 'M2_AirAttacks2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Seraph_AirAttack_1_Chain', 'M2_Seraph_AirAttack_2_Chain', 'M2_Seraph_AirAttack_3_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Interceptors', quantity[Difficulty])
    opai:SetLockingStyle('None')

    -- sends 4, 8, 14 [gunships, combat fighters]
    quantity = {4, 8, 14}
    opai = SeraphimM2Upper:AddOpAI('AirAttacks', 'M2_AirAttacks3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Seraph_AirAttack_1_Chain', 'M2_Seraph_AirAttack_2_Chain', 'M2_Seraph_AirAttack_3_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'Gunships', 'CombatFighters'}, quantity[Difficulty])
    opai:SetLockingStyle('None')

    -- sends 6, 8, 15 [gunships] if player has >= 100, 80, 60 mobile land
    quantity = {6, 8, 15}
    trigger = {100, 80, 60}
    opai = SeraphimM2Upper:AddOpAI('AirAttacks', 'M2_AirAttacks4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Seraph_AirAttack_1_Chain', 'M2_Seraph_AirAttack_2_Chain', 'M2_Seraph_AirAttack_3_Chain'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], (categories.MOBILE * categories.LAND) - categories.CONSTRUCTION})

    -- sends 6, 8, 15 [air superiority] if player has >= 60, 40, 40 mobile air
    quantity = {6, 8, 15}
    trigger = {60, 40, 40}
    opai = SeraphimM2Upper:AddOpAI('AirAttacks', 'M2_AirAttacks5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Seraph_AirAttack_1_Chain', 'M2_Seraph_AirAttack_2_Chain', 'M2_Seraph_AirAttack_3_Chain'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.MOBILE * categories.AIR})

    -- sends 6, 8, 15 [air superiority] if player has >= 50, 30, 30 gunships
    quantity = {6, 8, 15}
    trigger = {50, 30, 30}
    opai = SeraphimM2Upper:AddOpAI('AirAttacks', 'M2_AirAttacks6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Seraph_AirAttack_1_Chain', 'M2_Seraph_AirAttack_2_Chain', 'M2_Seraph_AirAttack_3_Chain'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.uaa0203 + categories.uea0203 + categories.ura0203})

    -- sends 8, 12, 14 [combat fighters, gunships] if player has >= 60, 40, 20 T3 units
    quantity = {8, 12, 14}
    trigger = {60, 40, 20}
    opai = SeraphimM2Upper:AddOpAI('AirAttacks', 'M2_AirAttacks7',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Seraph_AirAttack_1_Chain', 'M2_Seraph_AirAttack_2_Chain', 'M2_Seraph_AirAttack_3_Chain'},
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity({'Gunships', 'CombatFighters'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainGreaterThanOrEqualNumCategory', {'default_brain', 'Player', trigger[Difficulty], categories.TECH3})

    -- sends 4, 8, 10 [air superiority] if player has >= 1 strat bomber
    quantity = {4, 8, 10}
    opai = SeraphimM2Upper:AddOpAI('AirAttacks', 'M2_AirAttacks8',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Seraph_AirAttack_1_Chain', 'M2_Seraph_AirAttack_2_Chain', 'M2_Seraph_AirAttack_3_Chain'},
            },
            Priority = 140,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainGreaterThanOrEqualNumCategory', {'default_brain', 'Player', 1, categories.uaa0304 + categories.uea0304 + categories.ura0304})

    -- sends 8, 12, 20 [bombers, gunships] if player has >= 350, 400, 450 units
    quantity = {8, 12, 20}
    trigger = {350, 400, 450}
    opai = SeraphimM2Upper:AddOpAI('AirAttacks', 'M2_AirAttacks9',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Seraph_AirAttack_1_Chain', 'M2_Seraph_AirAttack_2_Chain', 'M2_Seraph_AirAttack_3_Chain'},
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity({'Bombers', 'Gunships'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainGreaterThanOrEqualNumCategory', {'default_brain', 'Player', trigger[Difficulty], categories.ALLUNITS - categories.WALL})

    -- Air Defense
    quantity = {4, 5, 6}
    for i = 1, 5 do
        opai = SeraphimM2Upper:AddOpAI('AirAttacks', 'M2_AirDefense' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M2_Seraph_AirDef_Chain',
                },
                Priority = 200,
            }
        )
        opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
		
        opai = SeraphimM2Upper:AddOpAI('AirAttacks', 'M2_AirDefense2' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M2_Seraph_AirDef_Chain',
                },
                Priority = 200,
            }
        )
        opai:SetChildQuantity('Gunships', quantity[Difficulty])
    end
end
