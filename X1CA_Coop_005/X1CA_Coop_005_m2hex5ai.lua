-- ****************************************************************************
-- **
-- **  File     : /maps/X1CA_Coop_005/X1CA_Coop_005_m2hex5ai.lua
-- **  Author(s): Jessica St. Croix
-- **
-- **  Summary  : Hex5 army AI for Mission 2 - X1CA_Coop_005
-- **
-- **  Copyright © 2007 Gas Powered Games, Inc.  All rights reserved.
-- ****************************************************************************
local BaseManager = import('/lua/ai/opai/basemanager.lua')

local SPAIFileName = '/lua/ScenarioPlatoonAI.lua'

--------
-- Locals
--------
local Hex5 = 3
local Difficulty = ScenarioInfo.Options.Difficulty

---------------
-- Base Managers
---------------
local Hex5M2Base = BaseManager.CreateBaseManager()

function Hex5M2BaseAI()

    --------------
    -- Hex5 M2 Base
    --------------
    Hex5M2Base:InitializeDifficultyTables(ArmyBrains[Hex5], 'M2_Hex5_Main_Base', 'M2_Hex5_Base_Marker', 150, {M2_Hex5_Main_Base = 100})
    Hex5M2Base:StartNonZeroBase({{5, 10, 21}, {5, 8, 18}})
    Hex5M2Base:SetActive('AirScouting', true)
    Hex5M2Base:SetActive('LandScouting', true)
    Hex5M2Base:SetBuild('Defenses', false)
    Hex5M2Base:SetBuild('Shields', true)

    Hex5M2BaseAirAttacks()
    Hex5M2BaseLandAttacks()
end

function Hex5M2BaseAirAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    ---------------------------------
    -- Hex5 M2 Base Op AI, Air Attacks
    ---------------------------------

    -- sends 4, 8, 12 [bombers], ([gunships] on hard)
    quantity = {4, 8, 12}
    opai = Hex5M2Base:AddOpAI('AirAttacks', 'M2_AirAttacks1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Hex5_AirAttack_1_Chain', 'M2_Hex5_AirAttack_2_Chain'},
            },
            Priority = 100,
        }
    )
    if(Difficulty < 3) then
        opai:SetChildQuantity('Bombers', quantity[Difficulty])
    else
        opai:SetChildQuantity('Gunships', quantity[Difficulty])
    end
    opai:SetLockingStyle('None')

    -- sends 4, 8, 12 [interceptors], ([interceptors, air superiority] on hard)
    quantity = {4, 8, 12}
    opai = Hex5M2Base:AddOpAI('AirAttacks', 'M2_AirAttacks2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Hex5_AirAttack_1_Chain', 'M2_Hex5_AirAttack_2_Chain'},
            },
            Priority = 100,
        }
    )
    if(Difficulty < 3) then
        opai:SetChildQuantity('Interceptors', quantity[Difficulty])
    else
        opai:SetChildQuantity({'Interceptors', 'AirSuperiority'}, quantity[Difficulty])
    end
    opai:SetLockingStyle('None')

    -- sends 4, 8, 12 [gunships, combat fighters]
    quantity = {4, 8, 12}
    opai = Hex5M2Base:AddOpAI('AirAttacks', 'M2_AirAttacks3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Hex5_AirAttack_1_Chain', 'M2_Hex5_AirAttack_2_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'Gunships', 'CombatFighters'}, quantity[Difficulty])
    opai:SetLockingStyle('None')

    -- sends 4, 8, 12 [gunships] if player has >= 100, 80, 60 mobile land, ([heavy gunships] on hard)
    quantity = {4, 8, 12}
    trigger = {100, 80, 60}
    opai = Hex5M2Base:AddOpAI('AirAttacks', 'M2_AirAttacks4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Hex5_AirAttack_1_Chain', 'M2_Hex5_AirAttack_2_Chain'},
            },
            Priority = 110,
        }
    )
    if(Difficulty < 3) then
        opai:SetChildQuantity('Gunships', quantity[Difficulty])
    else
        opai:SetChildQuantity('HeavyGunships', quantity[Difficulty])
    end
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], (categories.MOBILE * categories.LAND) - categories.CONSTRUCTION, '>='})

    -- sends 4, 8, 12 [air superiority] if player has >= 60, 40, 40 mobile air
    quantity = {4, 8, 12}
    trigger = {60, 40, 40}
    opai = Hex5M2Base:AddOpAI('AirAttacks', 'M2_AirAttacks5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Hex5_AirAttack_1_Chain', 'M2_Hex5_AirAttack_2_Chain'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.MOBILE * categories.AIR, '>='})

    -- sends 4, 8, 12 [air superiority] if player has >= 50, 30, 30 gunships
    quantity = {4, 8, 12}
    trigger = {50, 30, 30}
    opai = Hex5M2Base:AddOpAI('AirAttacks', 'M2_AirAttacks6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Hex5_AirAttack_1_Chain', 'M2_Hex5_AirAttack_2_Chain'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.uaa0203 + categories.uea0203 + categories.ura0203, '>='})

    -- sends 4, 12, 16 [combat fighters, gunships] if player has >= 60, 40, 20 T3 units
    quantity = {4, 12, 16}
    trigger = {60, 40, 20}
    opai = Hex5M2Base:AddOpAI('AirAttacks', 'M2_AirAttacks7',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Hex5_AirAttack_1_Chain', 'M2_Hex5_AirAttack_2_Chain'},
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity({'Gunships', 'CombatFighters'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.TECH3, '>='})

    -- sends 4, 8, 12 [air superiority] if player has >= 1 strat bomber
    quantity = {4, 8, 12}
    opai = Hex5M2Base:AddOpAI('AirAttacks', 'M2_AirAttacks8',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Hex5_AirAttack_1_Chain', 'M2_Hex5_AirAttack_2_Chain'},
            },
            Priority = 140,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, 1, categories.uaa0304 + categories.uea0304 + categories.ura0304, '>='})

    -- sends 8, 16, 24 [bombers, gunships] if player has >= 450, 400, 300 units, ([heavy gunships] on hard)
    quantity = {8, 16, 24}
    trigger = {450, 400, 300}
    opai = Hex5M2Base:AddOpAI('AirAttacks', 'M2_AirAttacks9',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Hex5_AirAttack_1_Chain', 'M2_Hex5_AirAttack_2_Chain'},
            },
            Priority = 150,
        }
    )
    if(Difficulty < 3) then
        opai:SetChildQuantity({'Bombers', 'Gunships'}, quantity[Difficulty])
    else
        opai:SetChildQuantity('HeavyGunships', quantity[Difficulty])
    end
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL, '>='})

    -- To attack Fletcher
    for i = 1, 2 do
        opai = Hex5M2Base:AddOpAI('AirAttacks', 'M2_AirAttacks_Fletcher_1' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M2_Hex5_AttFletcher_Air_' .. i .. '_Chain',
                },
                Priority = 150,
            }
        )
        opai:SetChildQuantity('Gunships', 8)
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', 'Fletcher', 20, categories.LAND, '>='})

        opai = Hex5M2Base:AddOpAI('AirAttacks', 'M2_AirAttacks_Fletcher_2' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M2_Hex5_AttFletcher_Air_' .. i .. '_Chain',
                },
                Priority = 150,
            }
        )
        opai:SetChildQuantity('Interceptors', 12)
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', 'Fletcher', 20, categories.AIR, '>='})
    end

    -- Air Defense
    for i = 1, Difficulty + 1 do
        opai = Hex5M2Base:AddOpAI('AirAttacks', 'M2_AirDefense' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M2_Hex5_Main_AirDef_N_Chain',
                },
                Priority = 200,
            }
        )
        opai:SetChildQuantity('Gunships', 6)
    end
end

function Hex5M2BaseLandAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    ----------------------------------
    -- Hex5 M2 Base Op AI, Land Attacks
    ----------------------------------

    -- sends 6, 10, 20 [amphibious tanks]
    quantity = {6, 10, 20}
    opai = Hex5M2Base:AddOpAI('BasicLandAttack', 'M2_LandAttack1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Hex5_AmphibAttack_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('AmphibiousTanks', quantity[Difficulty])
    if(Difficulty > 1) then
        opai:SetLockingStyle('None')
    end

    -- sends 6, 10, 20 [light artillery, mobile missiles]
    quantity = {6, 10, 20}
    opai = Hex5M2Base:AddOpAI('BasicLandAttack', 'M2_LandAttack2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Hex5_LandAttack_1_Chain', 'M2_Hex5_LandAttack_2_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'LightArtillery', 'MobileMissiles'}, quantity[Difficulty])
    if(Difficulty > 1) then
        opai:SetLockingStyle('None')
    end

    -- sends 6, 10, 20 [mobile bombs, mobile stealth]
    quantity = {6, 10, 20}
    opai = Hex5M2Base:AddOpAI('BasicLandAttack', 'M2_LandAttack3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Hex5_LandAttack_1_Chain', 'M2_Hex5_LandAttack_2_Chain'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'MobileBombs', 'MobileStealth'}, quantity[Difficulty])

    -- sends 4, 6, 10 [mobile flak, mobile shields] if player has >= 60, 40, 40 mobile air
    quantity = {4, 6, 10}
    trigger = {60, 40, 40}
    opai = Hex5M2Base:AddOpAI('BasicLandAttack', 'M2_LandAttack4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Hex5_LandAttack_1_Chain', 'M2_Hex5_LandAttack_2_Chain'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'MobileFlak', 'MobileShields'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.MOBILE * categories.AIR, '>='})

    -- sends 4, 6, 10 [mobile flak, mobile shields] if player has >= 50, 30, 30 gunships
    quantity = {4, 6, 10}
    trigger = {50, 30, 30}
    opai = Hex5M2Base:AddOpAI('BasicLandAttack', 'M2_LandAttack5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Hex5_LandAttack_1_Chain', 'M2_Hex5_LandAttack_2_Chain'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'MobileFlak', 'MobileShields'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.uaa0203 + categories.uea0203 + categories.ura0203, '>='})

    -- sends 6, 10, 20 [siege bots, heavy bots] if player has >= 60, 40, 20 T3 units
    quantity = {6, 10, 20}
    trigger = {60, 40, 20}
    opai = Hex5M2Base:AddOpAI('BasicLandAttack', 'M2_LandAttack6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Hex5_LandAttack_1_Chain', 'M2_Hex5_LandAttack_2_Chain'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity({'SiegeBots', 'HeavyBots'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.TECH3, '>='})

    -- sends 6, 8, 10 [mobile flak] if player has >= 1 strat bomber
    quantity = {6, 8, 10}
    opai = Hex5M2Base:AddOpAI('BasicLandAttack', 'M2_LandAttack7',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Hex5_LandAttack_1_Chain', 'M2_Hex5_LandAttack_2_Chain'},
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('MobileFlak', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, 1, categories.uaa0304 + categories.uea0304 + categories.ura0304, '>='})

    -- sends 6, 9, 15 [mobile heavy artillery, mobile missiles, light artillery] if player has >= 450, 400, 350 units
    quantity = {6, 9, 15}
    trigger = {450, 400, 350}
    opai = Hex5M2Base:AddOpAI('BasicLandAttack', 'M2_LandAttack8',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Hex5_LandAttack_1_Chain', 'M2_Hex5_LandAttack_2_Chain'},
            },
            Priority = 140,
        }
    )
    opai:SetChildQuantity({'MobileHeavyArtillery', 'MobileMissiles', 'LightArtillery'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL, '>='})

    -- To attack Fletcher
    for i = 1, 2 do
        opai = Hex5M2Base:AddOpAI('BasicLandAttack', 'M2_LandAttack_Fletcher1_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M2_Hex5_AttFletcher_Land_' .. i .. '_Chain',
                },
                Priority = 150,
            }
        )
        opai:SetChildQuantity({'HeavyTanks'}, 8)
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', 'Fletcher', 20, categories.LAND, '>='})

        opai = Hex5M2Base:AddOpAI('BasicLandAttack', 'M2_LandAttack_Fletcher2_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M2_Hex5_AttFletcher_Land_' .. i .. '_Chain',
                },
                Priority = 150,
            }
        )
        opai:SetChildQuantity({'MobileMissiles', 'LightArtillery'}, 8)
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
            {'default_brain', 'Fletcher', 20, categories.LAND, '>='})
    end

    -- Land Defense
    -- Maintains 4, 8, 12 Heavy Tanks
    quantity = {2, 4, 6}
    for i = 1, 2 do
        opai = Hex5M2Base:AddOpAI('BasicLandAttack', 'M2_LandDefense1_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
                PlatoonData = {
                    PatrolChains = {'M2_Hex5_Main_LandDef_N1_Chain', 'M2_Hex5_Main_LandDef_N2_Chain', 'M2_Hex5_Main_LandDef_W_Chain'},
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity({'HeavyTanks'}, quantity[Difficulty])
    end

    -- Maintains 4, 8, 12 Mobile Missiles
    quantity = {2, 4, 6}
    for i = 1, 2 do
        opai = Hex5M2Base:AddOpAI('BasicLandAttack', 'M2_LandDefense2_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
                PlatoonData = {
                    PatrolChains = {'M2_Hex5_Main_LandDef_N1_Chain', 'M2_Hex5_Main_LandDef_N2_Chain', 'M2_Hex5_Main_LandDef_W_Chain'},
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity({'MobileMissiles'}, quantity[Difficulty])
    end
end
