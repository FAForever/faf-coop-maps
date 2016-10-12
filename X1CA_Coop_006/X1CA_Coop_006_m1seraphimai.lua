-- ****************************************************************************
-- **
-- **  File     : /maps/X1CA_Coop_006/X1CA_Coop_006_m1seraphimai.lua
-- **  Author(s): Jessica St. Croix
-- **
-- **  Summary  : Seraphim army AI for Mission 1 - X1CA_Coop_006
-- **
-- **  Copyright © 2007 Gas Powered Games, Inc.  All rights reserved.
-- ****************************************************************************
local BaseManager = import('/lua/ai/opai/basemanager.lua')

local SPAIFileName = '/lua/ScenarioPlatoonAI.lua'

--------
-- Locals
--------
local Seraphim = 5
local Difficulty = ScenarioInfo.Options.Difficulty

---------------
-- Base Managers
---------------
local SeraphimM1Base = BaseManager.CreateBaseManager()

function SeraphimM1BaseAI()

    ------------------
    -- Seraphim M1 Base
    ------------------
    SeraphimM1Base:InitializeDifficultyTables(ArmyBrains[Seraphim], 'M1_Seraph_Base', 'M1_Seraphim_Main_Base', 100, {M1_Seraph_Base = 100})
    SeraphimM1Base:StartNonZeroBase({{6, 13, 20}, {5, 11, 17}})
    SeraphimM1Base:SetActive('AirScouting', true)
    SeraphimM1Base:SetActive('LandScouting', true)
    SeraphimM1Base:SetBuild('Defenses', false)
    SeraphimM1Base:SetSupportACUCount(1)

    ForkThread(function()
        WaitSeconds(1)
        -- Support factories
        SeraphimM1Base:AddBuildGroup('M1_Seraph_Base_Support_Factories', 100, true)
        -- Rest of the base
        SeraphimM1Base:AddBuildGroupDifficulty('M1_Seraph_BaseExpanded', 90)
    end)

    SeraphimM1BaseAirAttacks()
    SeraphimM1BaseLandAttacks()
end

function SeraphimM1BaseAirAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    -------------------------------------
    -- Seraphim M1 Base Op AI, Air Attacks
    -------------------------------------

    -- sends 6, 12, 18 [bombers], ([gunships] on hard)
    quantity = {6, 12, 18}
    opai = SeraphimM1Base:AddOpAI('AirAttacks', 'M1_AirAttacks1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Seraph_Base_AirAttack_1_Chain', 'M1_Seraph_Base_AirAttack_2_Chain', 'M1_Seraph_Base_AirAttack_3_Chain'},
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

    -- sends 6, 12, 18 [gunships]
    quantity = {6, 12, 18}
    opai = SeraphimM1Base:AddOpAI('AirAttacks', 'M1_AirAttacks2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Seraph_Base_AirAttack_1_Chain', 'M1_Seraph_Base_AirAttack_2_Chain', 'M1_Seraph_Base_AirAttack_3_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    opai:SetLockingStyle('None')

    -- sends 4, 8, 12 [gunships, combat fighters]
    quantity = {4, 8, 12}
    opai = SeraphimM1Base:AddOpAI('AirAttacks', 'M1_AirAttacks3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Seraph_Base_AirAttack_1_Chain', 'M1_Seraph_Base_AirAttack_2_Chain', 'M1_Seraph_Base_AirAttack_3_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'Gunships', 'CombatFighters'}, quantity[Difficulty])
    opai:SetLockingStyle('None')

    -- sends 6, 12, 18 [gunships] if player has >= 100, 80, 60 mobile land
    quantity = {6, 12, 18}
    trigger = {100, 80, 60}
    opai = SeraphimM1Base:AddOpAI('AirAttacks', 'M1_AirAttacks4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Seraph_Base_AirAttack_1_Chain', 'M1_Seraph_Base_AirAttack_2_Chain', 'M1_Seraph_Base_AirAttack_3_Chain'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], (categories.MOBILE * categories.LAND) - categories.CONSTRUCTION, '>='})

    -- sends 6, 12, 18 [air superiority] if player has >= 80, 60, 60 mobile air
    quantity = {6, 12, 18}
    trigger = {80, 60, 60}
    opai = SeraphimM1Base:AddOpAI('AirAttacks', 'M1_AirAttacks5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Seraph_Base_AirAttack_1_Chain', 'M1_Seraph_Base_AirAttack_2_Chain', 'M1_Seraph_Base_AirAttack_3_Chain'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.MOBILE * categories.AIR, '>='})

    -- sends 6, 12, 18 [air superiority] if player has >= 60, 40, 40 gunships
    quantity = {6, 12, 18}
    trigger = {60, 40, 40}
    opai = SeraphimM1Base:AddOpAI('AirAttacks', 'M1_AirAttacks6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Seraph_Base_AirAttack_1_Chain', 'M1_Seraph_Base_AirAttack_2_Chain', 'M1_Seraph_Base_AirAttack_3_Chain'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.uaa0203 + categories.uea0203 + categories.ura0203, '>='})

    -- sends 6, 12, 18 [combat fighters, gunships] if player has >= 60, 40, 20 T3 units
    quantity = {6, 12, 18}
    trigger = {60, 40, 20}
    opai = SeraphimM1Base:AddOpAI('AirAttacks', 'M1_AirAttacks7',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Seraph_Base_AirAttack_1_Chain', 'M1_Seraph_Base_AirAttack_2_Chain', 'M1_Seraph_Base_AirAttack_3_Chain'},
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity({'Gunships', 'CombatFighters'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.TECH3, '>='})

    -- sends 6, 12, 18 [air superiority] if player has >= 1 strat bomber
    quantity = {6, 12, 18}
    opai = SeraphimM1Base:AddOpAI('AirAttacks', 'M1_AirAttacks8',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Seraph_Base_AirAttack_1_Chain', 'M1_Seraph_Base_AirAttack_2_Chain', 'M1_Seraph_Base_AirAttack_3_Chain'},
            },
            Priority = 140,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, 1, categories.uaa0304 + categories.uea0304 + categories.ura0304, '>='})

    -- sends 6, 12, 18 [bombers, gunships] if player has >= 450, 400, 300 units
    quantity = {6, 12, 18}
    trigger = {450, 400, 300}
    opai = SeraphimM1Base:AddOpAI('AirAttacks', 'M1_AirAttacks9',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Seraph_Base_AirAttack_1_Chain', 'M1_Seraph_Base_AirAttack_2_Chain', 'M1_Seraph_Base_AirAttack_3_Chain'},
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity({'Bombers', 'Gunships'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL, '>='})

    -- Air Defense
    quantity = {6, 9, 12}
    for i = 1, Difficulty do
        opai = SeraphimM1Base:AddOpAI('AirAttacks', 'M1_AirDefense' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M1_Seraph_Base_AirDef_Chain',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('Gunships', quantity[Difficulty])
    end
end

function SeraphimM1BaseLandAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    ---------------------------------
    -- Seraphim M1 Op AI, Land Attacks
    ---------------------------------

    -- sends 6, 10, 20 [light tanks, heavy tanks]
    quantity = {6, 10, 20}
    opai = SeraphimM1Base:AddOpAI('BasicLandAttack', 'M1_LandAttack1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Seraph_Base_LandAttack_1_Chain', 'M1_Seraph_Base_LandAttack_2_Chain', 'M1_Seraph_Base_LandAttack_3_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'LightTanks', 'HeavyTanks'}, quantity[Difficulty])
    if(Difficulty > 1) then
        opai:SetLockingStyle('None')
    end

    -- sends 6, 10, 20 [light artillery, mobile missiles]
    quantity = {6, 10, 20}
    opai = SeraphimM1Base:AddOpAI('BasicLandAttack', 'M1_LandAttack2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Seraph_Base_LandAttack_1_Chain', 'M1_Seraph_Base_LandAttack_2_Chain', 'M1_Seraph_Base_LandAttack_3_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'LightArtillery', 'MobileMissiles'}, quantity[Difficulty])
    if(Difficulty > 1) then
        opai:SetLockingStyle('None')
    end

    ----------------------
    -- Hard Difficulty Only
    ----------------------
    if(Difficulty == 3) then
       opai = SeraphimM1Base:AddOpAI('BasicLandAttack', 'M1_LandAttackHard1',
           {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
                PlatoonData = {
                    PatrolChains = {'M1_Seraph_Base_LandAttack_1_Chain', 'M1_Seraph_Base_LandAttack_2_Chain', 'M1_Seraph_Base_LandAttack_3_Chain'},
                },
                Priority = 110,
           }
       )
       opai:SetChildQuantity({'SiegeBots', 'MobileShields'}, 10)

       opai = SeraphimM1Base:AddOpAI('BasicLandAttack', 'M1_LandAttackHard2',
           {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
                PlatoonData = {
                    PatrolChains = {'M1_Seraph_Base_LandAttack_1_Chain', 'M1_Seraph_Base_LandAttack_2_Chain', 'M1_Seraph_Base_LandAttack_3_Chain'},
                },
                Priority = 110,
           }
       )
       opai:SetChildQuantity({'MobileHeavyArtillery' , 'MobileShields'}, 6)
    end

    -- sends 4, 6, 8 [mobile flak, mobile shields] if player has >= 60, 40, 40 mobile air
    quantity = {4, 6, 8}
    trigger = {60, 40, 40}
    opai = SeraphimM1Base:AddOpAI('BasicLandAttack', 'M1_LandAttack3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Seraph_Base_LandAttack_1_Chain', 'M1_Seraph_Base_LandAttack_2_Chain', 'M1_Seraph_Base_LandAttack_3_Chain'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'MobileFlak', 'MobileShields'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.MOBILE * categories.AIR, '>='})

    -- sends 4, 6, 8 [mobile flak, mobile shields] if player has >= 50, 30, 30 gunships
    quantity = {4, 6, 8}
    trigger = {50, 30, 30}
    opai = SeraphimM1Base:AddOpAI('BasicLandAttack', 'M1_LandAttack4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Seraph_Base_LandAttack_1_Chain', 'M1_Seraph_Base_LandAttack_2_Chain', 'M1_Seraph_Base_LandAttack_3_Chain'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'MobileFlak', 'MobileShields'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.uaa0203 + categories.uea0203 + categories.ura0203, '>='})

    -- sends 6, 10, 20 [siege bots, mobile shields] if player has >= 60, 40, 20 T3 units
    quantity = {6, 10, 20}
    trigger = {60, 40, 20}
    opai = SeraphimM1Base:AddOpAI('BasicLandAttack', 'M1_LandAttack5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Seraph_Base_LandAttack_1_Chain', 'M1_Seraph_Base_LandAttack_2_Chain', 'M1_Seraph_Base_LandAttack_3_Chain'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity({'SiegeBots', 'MobileShields'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.TECH3, '>='})

    -- sends 2, 4, 6 [mobile flak] if player has >= 1 strat bomber
    quantity = {2, 4, 6}
    opai = SeraphimM1Base:AddOpAI('BasicLandAttack', 'M1_LandAttack6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Seraph_Base_LandAttack_1_Chain', 'M1_Seraph_Base_LandAttack_2_Chain', 'M1_Seraph_Base_LandAttack_3_Chain'},
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
    opai = SeraphimM1Base:AddOpAI('BasicLandAttack', 'M1_LandAttack7',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Seraph_Base_LandAttack_1_Chain', 'M1_Seraph_Base_LandAttack_2_Chain', 'M1_Seraph_Base_LandAttack_3_Chain'},
            },
            Priority = 140,
        }
    )
    opai:SetChildQuantity({'MobileHeavyArtillery', 'MobileMissiles', 'LightArtillery'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL, '>='})

    -- Land Defense
    -- Maintains 4, 8, 12 Heavy Tanks
    quantity = {2, 4, 6}
    for i = 1, 2 do
        opai = SeraphimM1Base:AddOpAI('BasicLandAttack', 'M1_LandDefense1_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
                PlatoonData = {
                    PatrolChains = {'M1_Seraph_Base_LandDef1_Chain', 'M1_Seraph_Base_LandDef2_Chain'},
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity({'HeavyTanks'}, quantity[Difficulty])
    end

    -- Maintains 4, 8, 12 Mobile Missiles
    quantity = {2, 4, 6}
    for i = 1, 2 do
        opai = SeraphimM1Base:AddOpAI('BasicLandAttack', 'M1_LandDefense2_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
                PlatoonData = {
                    PatrolChains = {'M1_Seraph_Base_LandDef1_Chain', 'M1_Seraph_Base_LandDef2_Chain'},
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity({'MobileMissiles'}, quantity[Difficulty])
    end
end

function M1NavalFactoryBuilt()
    SeraphimM1Base:AddBuildGroup('M1_Naval_Factories_Adapt', 100, false)
    SeraphimM1BaseNavalAttacks()
end

function SeraphimM1BaseNavalAttacks()
    local opai = nil
    local maxQuantity = {}
    local minQuantity = {}
    local trigger = {}

    -- sends 3 frigate power of [frigates] if player has >= 6, 4, 2 boats
    maxQuantity = {3, 3, 3}
    minQuantity = {3, 3, 3}
    trigger = {6, 4, 2}
    opai = SeraphimM1Base:AddNavalAI('M1_NavalAttack1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M1_Seraph_Base_NavalAttack_Chain',
            },
            EnableTypes = {'Frigate'},
            MaxFrigates = maxQuantity[Difficulty],
            MinFrigates = minQuantity[Difficulty],
            Priority = 100,
        }
    )
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE, '>='})

    -- sends 6 frigate power of [frigates, subs] if player has >= 10, 8, 6 boats
    maxQuantity = {6, 6, 6}
    minQuantity = {6, 6, 6}
    trigger = {10, 8, 6}
    opai = SeraphimM1Base:AddNavalAI('M1_NavalAttack2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M1_Seraph_Base_NavalAttack_Chain',
            },
            EnableTypes = {
                'Frigate',
                'Submarine',
            },
            MaxFrigates = maxQuantity[Difficulty],
            MinFrigates = minQuantity[Difficulty],
            Priority = 110,
        }
    )
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE, '>='})

    -- sends 8 frigate power of [all but T3] if player has >= 6, 4, 2 T2/T3 boats
    maxQuantity = {8, 8, 8}
    minQuantity = {8, 8, 8}
    trigger = {6, 4, 2}
    opai = SeraphimM1Base:AddNavalAI('M1_NavalAttack3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M1_Seraph_Base_NavalAttack_Chain',
            },
            MaxFrigates = maxQuantity[Difficulty],
            MinFrigates = minQuantity[Difficulty],
            Priority = 120,
        }
    )
    opai:SetChildActive('T3', false)
    opai:RemoveChildren('T3')
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], (categories.NAVAL * categories.MOBILE) - categories.TECH1, '>='})

    -- sends 12 frigate power of [all but T3] if player has >= 12, 8, 4 T2/T3 boats
    maxQuantity = {12, 12, 12}
    minQuantity = {12, 12, 12}
    trigger = {12, 8, 4}
    opai = SeraphimM1Base:AddNavalAI('M1_NavalAttack4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M1_Seraph_Base_NavalAttack_Chain',
            },
            MaxFrigates = maxQuantity[Difficulty],
            MinFrigates = minQuantity[Difficulty],
            Priority = 130,
        }
    )
    opai:SetChildActive('T3', false)
    opai:RemoveChildren('T3')
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], (categories.NAVAL * categories.MOBILE) - categories.TECH1, '>='})

    -- Naval Defense
    maxQuantity = {4, 8, 12}
    minQuantity = {4, 8, 12}
    opai = SeraphimM1Base:AddNavalAI('M1_NavalDefense',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M1_Seraph_Base_NavalDef_Chain',
            },
            EnableTypes = {'Submarine'},
            MaxFrigates = maxQuantity[Difficulty],
            MinFrigates = minQuantity[Difficulty],
            Priority = 100,
        }
    )
end
