-- ****************************************************************************
-- **
-- **  File     : /maps/X1CA_Coop_002_v03/X1CA_Coop_002_v03_m2qaiai.lua
-- **  Author(s): Jessica St. Croix
-- **
-- **  Summary  : QAI army AI for Mission 2 - X1CA_Coop_002_v03
-- **
-- **  Copyright © 2007 Gas Powered Games, Inc.  All rights reserved.
-- ****************************************************************************
local BaseManager = import('/lua/ai/opai/basemanager.lua')

local SPAIFileName = '/lua/scenarioplatoonai.lua'

-- ------
-- Locals
-- ------
local QAI = 3
local Difficulty = ScenarioInfo.Options.Difficulty

-- -------------
-- Base Managers
-- -------------
local QAIM2SouthBase = BaseManager.CreateBaseManager()

function QAIM2SouthBaseAI()

    -- -----------------
    -- QAI M2 South Base
    -- -----------------
    QAIM2SouthBase:InitializeDifficultyTables(ArmyBrains[QAI], 'M2_South_Base', 'M2_QAI_Base_Marker', 50, {M2_South_Base = 100})
    QAIM2SouthBase:StartNonZeroBase({{6, 12, 20}, {5, 10, 18}})
    QAIM2SouthBase:SetBuild('Defenses', false)
    QAIM2SouthBase:SetActive('AirScouting', true)

    QAIM2SouthBase:AddReactiveAI('ExperimentalLand', 'AirRetaliation', 'QAIM2SouthBase_ExperimentalLand')
    QAIM2SouthBase:AddReactiveAI('ExperimentalAir', 'AirRetaliation', 'QAIM2SouthBase_ExperimentalAir')
    QAIM2SouthBase:AddReactiveAI('ExperimentalNaval', 'AirRetaliation', 'QAIM2SouthBase_ExperimentalNaval')
    QAIM2SouthBase:AddReactiveAI('Nuke', 'AirRetaliation', 'QAIM2SouthBase_Nuke')
    QAIM2SouthBase:AddReactiveAI('HLRA', 'AirRetaliation', 'QAIM2SouthBase_HLRA')

    QAIM2SouthBaseAirAttacks()
    QAIM2SouthBaseLandAttacks()
end

function QAIM2SouthBaseAirAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    -- ------------------------------------
    -- QAI M2 South Base Op AI, Air Attacks
    -- ------------------------------------

    -- sends 2, 2, 6 [bombers]
    quantity = {2, 2, 6}
    opai = QAIM2SouthBase:AddOpAI('AirAttacks', 'M2_AirAttacks1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'RandomPatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Combined_AirAttack_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Bombers', quantity[Difficulty])

    -- sends 2, 2, 6 [interceptors]
    quantity = {2, 2, 6}
    opai = QAIM2SouthBase:AddOpAI('AirAttacks', 'M2_AirAttacks2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'RandomPatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Combined_AirAttack_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Interceptors', quantity[Difficulty])

    -- sends 2, 4, 6 [gunships, combat fighters]
    quantity = {2, 4, 6}
    opai = QAIM2SouthBase:AddOpAI('AirAttacks', 'M2_AirAttacks3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'RandomPatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Combined_AirAttack_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'Gunships', 'CombatFighters'}, quantity[Difficulty])

    -- sends 2, 4, 6 [gunships, combat fighters] if player has >= 10, 7, 5 T2/T3 AA
    quantity = {2, 4, 6}
    trigger = {10, 7, 5}
    opai = QAIM2SouthBase:AddOpAI('AirAttacks', 'M2_AirAttacks4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'RandomPatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Combined_AirAttack_Chain',
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'Gunships', 'CombatFighters'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.ANTIAIR - categories.TECH1})

    -- sends 2, 2, 6 [gunships] if player has >= 100, 80, 60 mobile land
    quantity = {2, 2, 6}
    trigger = {100, 80, 60}
    opai = QAIM2SouthBase:AddOpAI('AirAttacks', 'M2_AirAttacks5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'RandomPatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Combined_AirAttack_Chain',
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], (categories.MOBILE * categories.LAND) - categories.CONSTRUCTION})

    -- sends 2, 4, 6 [air superiority] if player has >= 100, 80, 60 mobile air
    quantity = {2, 4, 6}
    trigger = {100, 80, 60}
    opai = QAIM2SouthBase:AddOpAI('AirAttacks', 'M2_AirAttacks6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'RandomPatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Combined_AirAttack_Chain',
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.MOBILE * categories.AIR})

    -- sends 2, 4, 6 [air superiority] if player has >= 60, 50, 40 gunships
    quantity = {2, 4, 6}
    trigger = {60, 50, 40}
    opai = QAIM2SouthBase:AddOpAI('AirAttacks', 'M2_AirAttacks7',
        {
            MasterPlatoonFunction = {SPAIFileName, 'RandomPatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Combined_AirAttack_Chain',
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.uaa0203 + categories.uea0203 + categories.ura0203})

    -- sends 4, 6, 12 [combat fighters, gunships] if player has >= 60, 40, 20 T3 units
    quantity = {4, 6, 12}
    trigger = {60, 40, 20}
    opai = QAIM2SouthBase:AddOpAI('AirAttacks', 'M2_AirAttacks8',
        {
            MasterPlatoonFunction = {SPAIFileName, 'RandomPatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Combined_AirAttack_Chain',
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity({'Gunships', 'CombatFighters'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainGreaterThanOrEqualNumCategory', {'default_brain', 'Player', trigger[Difficulty], categories.TECH3})

    -- sends 2, 2, 6 [air superiority] if player has >= 1 strat bomber
    quantity = {2, 2, 6}
    opai = QAIM2SouthBase:AddOpAI('AirAttacks', 'M2_AirAttacks9',
        {
            MasterPlatoonFunction = {SPAIFileName, 'RandomPatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Combined_AirAttack_Chain',
            },
            Priority = 140,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainGreaterThanOrEqualNumCategory', {'default_brain', 'Player', 1, categories.uaa0304 + categories.uea0304 + categories.ura0304})

    -- sends 6, 9, 12 [bombers, gunships, heavy gunships] if player has >= 350, 400, 450 units
    quantity = {6, 9, 12}
    trigger = {350, 400, 450}
    opai = QAIM2SouthBase:AddOpAI('AirAttacks', 'M2_AirAttacks10',
        {
            MasterPlatoonFunction = {SPAIFileName, 'RandomPatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Combined_AirAttack_Chain',
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity({'Bombers', 'Gunships', 'HeavyGunships'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainGreaterThanOrEqualNumCategory', {'default_brain', 'Player', trigger[Difficulty], categories.ALLUNITS - categories.WALL})
end

function QAIM2SouthBaseLandAttacks()
    local opai = nil

    -- -------------------------------------
    -- QAI M2 South Base Op AI, Land Attacks
    -- -------------------------------------
	
	for i = 1, 2 do
	-- sends 6 [mobile flak, light bots]
    opai = QAIM2SouthBase:AddOpAI('BasicLandAttack', 'M2_LandAttack_LoyEast' .. i,
        {
            MasterPlatoonFunction = {'/maps/X1CA_Coop_002_v03/X1CA_Coop_002_v03_m2orderai.lua', 'LoyEastSiege'},
        }
    )
    opai:SetChildQuantity({'MobileFlak', 'LightBots'}, 6)
	
	-- sends 6 [heavy tanks, light tanks]
    opai = QAIM2SouthBase:AddOpAI('BasicLandAttack', 'M2_LandAttack_LoyWest' .. i,
        {
            MasterPlatoonFunction = {'/maps/X1CA_Coop_002_v03/X1CA_Coop_002_v03_m2orderai.lua', 'LoyWestSiege'},
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'HeavyTanks', 'LightBots'}, 8)
	end

    -- sends 6, 8, 9 [light artillery]
    quantity = {6, 8, 9}
    opai = QAIM2SouthBase:AddOpAI('BasicLandAttack', 'M2_LandAttack1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Combined_LandAttack_Chain', 'M2_Combined_LandAttack2_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('LightArtillery', quantity[Difficulty])
    opai:SetLockingStyle('None')

    -- sends 6, 8, 9 [light bots]
    quantity = {6, 8, 9}
    opai = QAIM2SouthBase:AddOpAI('BasicLandAttack', 'M2_LandAttack2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Combined_LandAttack_Chain', 'M2_Combined_LandAttack2_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('LightBots', quantity[Difficulty])
    opai:SetLockingStyle('None')

    -- sends 6, 8, 9 [light tanks]
    quantity = {6, 8, 9}
    opai = QAIM2SouthBase:AddOpAI('BasicLandAttack', 'M2_LandAttack3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Combined_LandAttack_Chain', 'M2_Combined_LandAttack2_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('LightTanks', quantity[Difficulty])
    opai:SetLockingStyle('None')

    -- sends 6, 8, 9 [heavy tanks]
    quantity = {6, 8, 9}
    opai = QAIM2SouthBase:AddOpAI('BasicLandAttack', 'M2_LandAttack4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Combined_LandAttack_Chain', 'M2_Combined_LandAttack2_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('HeavyTanks', quantity[Difficulty])
    opai:SetLockingStyle('None')

    -- sends 6, 8, 18 [light tanks, heavy tanks] if player has >= 10, 7, 5 T2/T3 DF/IF
    quantity = {6, 8, 18}
    trigger = {10, 7, 5}
    opai = QAIM2SouthBase:AddOpAI('BasicLandAttack', 'M2_LandAttack5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Combined_LandAttack_Chain', 'M2_Combined_LandAttack2_Chain'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'LightTanks', 'HeavyTanks'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], (categories.DIRECTFIRE + categories.INDIRECTFIRE) - categories.TECH1})

    -- sends 6, 8, 18 [mobile bombs, mobile stealth] if player has >= 100, 80, 60 mobile land
    quantity = {6, 8, 18}
    trigger = {100, 80, 60}
    opai = QAIM2SouthBase:AddOpAI('BasicLandAttack', 'M2_LandAttack6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Combined_LandAttack_Chain', 'M2_Combined_LandAttack2_Chain'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity({'MobileBombs', 'MobileStealth'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], (categories.MOBILE * categories.LAND) - categories.CONSTRUCTION})

    -- sends 6, 8, 18 [mobile flak, mobile shields] if player has >= 100, 80, 60 mobile air
    quantity = {6, 8, 18}
    trigger = {100, 80, 60}
    opai = QAIM2SouthBase:AddOpAI('BasicLandAttack', 'M2_LandAttack7',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Combined_LandAttack_Chain', 'M2_Combined_LandAttack2_Chain'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity({'MobileFlak', 'MobileShields'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.MOBILE * categories.AIR})

    -- sends 6, 8, 18 [mobile flak, mobile shields] if player has >= 60, 50, 40 gunships
    quantity = {6, 8, 18}
    trigger = {100, 80, 60}
    opai = QAIM2SouthBase:AddOpAI('BasicLandAttack', 'M2_LandAttack8',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Combined_LandAttack_Chain', 'M2_Combined_LandAttack2_Chain'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity({'MobileFlak', 'MobileShields'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.uaa0203 + categories.uea0203 + categories.ura0203})

    -- sends 6, 8, 18 [siege bots, heavy bots] if player has >= 60, 40, 20 T3 units
    quantity = {6, 8, 18}
    trigger = {60, 40, 20}
    opai = QAIM2SouthBase:AddOpAI('BasicLandAttack', 'M2_LandAttack9',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Combined_LandAttack_Chain', 'M2_Combined_LandAttack2_Chain'},
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity({'SiegeBots', 'HeavyBots'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.TECH3})

    -- sends 6, 8, 9 [mobile flak] if player has >= 1 strat bomber
    quantity = {6, 8, 9}
    opai = QAIM2SouthBase:AddOpAI('BasicLandAttack', 'M2_LandAttack10',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Combined_LandAttack_Chain', 'M2_Combined_LandAttack2_Chain'},
            },
            Priority = 140,
        }
    )
    opai:SetChildQuantity({'MobileFlak'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', 1, categories.uaa0304 + categories.uea0304 + categories.ura0304})

    -- sends 6, 12, 18 [mobile heavy artillery, mobile missiles, light artillery] if player has >= 450, 400, 350 units
    quantity = {6, 12, 18}
    trigger = {450, 400, 350}
    opai = QAIM2SouthBase:AddOpAI('BasicLandAttack', 'M2_LandAttack11',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Combined_LandAttack_Chain', 'M2_Combined_LandAttack2_Chain'},
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity({'MobileHeavyArtillery', 'MobileMissiles', 'LightArtillery'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.uaa0304 + categories.uea0304 + categories.ura0304})

    -- Land Defense
    -- Maintains 8 Heavy Tanks
    for i = 1, 2 do
        opai = QAIM2SouthBase:AddOpAI('BasicLandAttack', 'M2_LandDefense1_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M2_QAI_LandDef' .. i.. '_Chain',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity({'HeavyTanks'}, 4)
    end

    -- Maintains 8 Mobile Flak
    for i = 1, 2 do
        opai = QAIM2SouthBase:AddOpAI('BasicLandAttack', 'M2_LandDefense2_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M2_QAI_LandDef' .. i.. '_Chain',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity({'MobileFlak'}, 4)
    end

    -- Maintains 8 Mobile Missiles
    for i = 1, 2 do
        opai = QAIM2SouthBase:AddOpAI('BasicLandAttack', 'M2_LandDefense3_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M2_QAI_LandDef' .. i.. '_Chain',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity({'MobileMissiles'}, 4)
    end
end
