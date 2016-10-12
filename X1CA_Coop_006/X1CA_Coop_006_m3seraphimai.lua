-- ****************************************************************************
-- **
-- **  File     : /maps/X1CA_Coop_006/X1CA_Coop_006_m3seraphimai.lua
-- **  Author(s): Jessica St. Croix
-- **
-- **  Summary  : Seraphim army AI for Mission 3 - X1CA_Coop_006
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
local SeraphimM3Base = BaseManager.CreateBaseManager()
local SeraphimM3WestBase = BaseManager.CreateBaseManager()
local SeraphimM3EastBase = BaseManager.CreateBaseManager()

function SeraphimM3BaseAI()

    ------------------
    -- Seraphim M3 Base
    ------------------
    SeraphimM3Base:InitializeDifficultyTables(ArmyBrains[Seraphim], 'M3_Seraph_Base', 'M3_Seraphim_Base_Marker', 120, {M3_Seraph_Base = 100})
    SeraphimM3Base:StartNonZeroBase({{5, 8, 11}, {5, 7, 9}})
    SeraphimM3Base:SetActive('AirScouting', true)
    SeraphimM3Base:SetActive('LandScouting', true)

    ForkThread(function()
        WaitSeconds(1)
        SeraphimM3Base:AddBuildGroup('M3_Seraph_Base_Support_Factories', 100, true)
    end)

    SeraphimM3Base:AddReactiveAI('ExperimentalLand', 'AirRetaliation', 'SeraphimM3Base_ExperimentalLand')
    SeraphimM3Base:AddReactiveAI('ExperimentalAir', 'AirRetaliation', 'SeraphimM3Base_ExperimentalAir')
    SeraphimM3Base:AddReactiveAI('ExperimentalNaval', 'AirRetaliation', 'SeraphimM3Base_ExperimentalNaval')
    SeraphimM3Base:AddReactiveAI('Nuke', 'AirRetaliation', 'SeraphimM3Base_Nuke')
    SeraphimM3Base:AddReactiveAI('HLRA', 'AirRetaliation', 'SeraphimM3Base_HLRA')

    SeraphimM3BaseAirAttacks()
    SeraphimM3BaseLandAttacks()
end

function SeraphimM3BaseAirAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    --------------------------------------
    -- Seraphim M3 Base Op AI - Air Attacks
    --------------------------------------

    -- sends 8, 16, 24 [bombers], ([gunships] on hard)
    quantity = {8, 16, 24}
    opai = SeraphimM3Base:AddOpAI('AirAttacks', 'M3_SeraphimAirAttacks1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Seraph_AirAttack_1_Chain', 'M3_Seraph_AirAttack_2_Chain', 'M3_Seraph_AirAttack_3_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildActive('All', false)
    if(Difficulty < 3) then
        opai:SetChildQuantity('Bombers', quantity[Difficulty])
    else
        opai:SetChildQuantity('Gunships', quantity[Difficulty])
    end
    opai:SetLockingStyle('None')

    -- sends 8, 16, 24 [gunships], ([heavy gunships] on hard)
    quantity = {8, 16, 24}
    opai = SeraphimM3Base:AddOpAI('AirAttacks', 'M3_SeraphimAirAttacks2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Seraph_AirAttack_1_Chain', 'M3_Seraph_AirAttack_2_Chain', 'M3_Seraph_AirAttack_3_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildActive('All', false)
    if(Difficulty < 3) then
        opai:SetChildQuantity('Gunships', quantity[Difficulty])
    else
        opai:SetChildQuantity('HeavyGunships', quantity[Difficulty])
    end
    opai:SetLockingStyle('None')

    -- sends 4, 8, 16 [gunships, combat fighters]
    quantity = {4, 8, 16}
    opai = SeraphimM3Base:AddOpAI('AirAttacks', 'M3_SeraphimAirAttacks3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Seraph_AirAttack_1_Chain', 'M3_Seraph_AirAttack_2_Chain', 'M3_Seraph_AirAttack_3_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'Gunships', 'CombatFighters'}, quantity[Difficulty])
    opai:SetLockingStyle('None')

    -- sends 8, 16, 24 [gunships] if player has >= 100, 80, 60 mobile land
    quantity = {8, 16, 24}
    trigger = {100, 80, 60}
    opai = SeraphimM3Base:AddOpAI('AirAttacks', 'M3_SeraphimAirAttacks4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Seraph_AirAttack_1_Chain', 'M3_Seraph_AirAttack_2_Chain', 'M3_Seraph_AirAttack_3_Chain'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], (categories.MOBILE * categories.LAND) - categories.CONSTRUCTION, '>='})

    -- sends 8, 16, 24 [air superiority] if player has >= 80, 60, 60 mobile air
    quantity = {8, 16, 24}
    trigger = {80, 60, 60}
    opai = SeraphimM3Base:AddOpAI('AirAttacks', 'M3_SeraphimAirAttacks5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Seraph_AirAttack_1_Chain', 'M3_Seraph_AirAttack_2_Chain', 'M3_Seraph_AirAttack_3_Chain'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.MOBILE * categories.AIR, '>='})

    -- sends 8, 16, 24 [air superiority] if player has >= 60, 40, 40 gunships
    quantity = {8, 16, 24}
    trigger = {60, 40, 40}
    opai = SeraphimM3Base:AddOpAI('AirAttacks', 'M3_SeraphimAirAttacks6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Seraph_AirAttack_1_Chain', 'M3_Seraph_AirAttack_2_Chain', 'M3_Seraph_AirAttack_3_Chain'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.uaa0203 + categories.uea0203 + categories.ura0203, '>='})

    -- sends 6, 16, 24 [combat fighters, gunships] if player has >= 60, 40, 20 T3 units
    quantity = {6, 16, 24}
    trigger = {60, 40, 20}
    opai = SeraphimM3Base:AddOpAI('AirAttacks', 'M3_SeraphimAirAttacks7',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Seraph_AirAttack_1_Chain', 'M3_Seraph_AirAttack_2_Chain', 'M3_Seraph_AirAttack_3_Chain'},
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity({'Gunships', 'CombatFighters'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.TECH3, '>='})

    -- sends 8, 16, 24 [air superiority] if player has >= 1 strat bomber
    quantity = {8, 16, 24}
    opai = SeraphimM3Base:AddOpAI('AirAttacks', 'M3_SeraphimAirAttacks8',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Seraph_AirAttack_1_Chain', 'M3_Seraph_AirAttack_2_Chain', 'M3_Seraph_AirAttack_3_Chain'},
            },
            Priority = 140,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, 1, categories.uaa0304 + categories.uea0304 + categories.ura0304, '>='})

    -- sends 8, 16, 24 [bombers, gunships] if player has >= 450, 400, 300 units
    quantity = {8, 16, 24}
    trigger = {450, 400, 300}
    opai = SeraphimM3Base:AddOpAI('AirAttacks', 'M3_SeraphimAirAttacks9',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Seraph_AirAttack_1_Chain', 'M3_Seraph_AirAttack_2_Chain', 'M3_Seraph_AirAttack_3_Chain'},
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity({'Bombers', 'Gunships'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL, '>='})

    -- Air Defense N
    quantity = {2, 3, 4}
    for i = 1, quantity[Difficulty] do
        opai = SeraphimM3Base:AddOpAI('AirAttacks', 'M3_AirDefenseN' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M3_Seraph_AirNorth_Def_Chain',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('AirSuperiority', 8)
    end

    -- Air Defense S
    quantity = {2, 3, 4}
    for i = 1, quantity[Difficulty] do
        opai = SeraphimM3Base:AddOpAI('AirAttacks', 'M3_AirDefenseS' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M3_Seraph_AirSouth_Def_Chain',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('Gunships', 8)
    end
end

function SeraphimM3BaseLandAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    ---------------------------------------
    -- Seraphim M3 Base Op AI - Land Attacks
    ---------------------------------------

    -- sends 4, 6, 8 [heavy bots]
    quantity = {4, 6, 8}
    opai = SeraphimM3Base:AddOpAI('BasicLandAttack', 'M3_LandAttack1',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Seraph_LandAttack1_Chain', 'M3_Seraph_LandAttack2_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('HeavyBots', quantity[Difficulty])
    opai:SetLockingStyle('None')

    -- sends 4, 6, 8 [mobile missiles]
    quantity = {4, 6, 8}
    opai = SeraphimM3Base:AddOpAI('BasicLandAttack', 'M3_LandAttack2',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Seraph_LandAttack1_Chain', 'M3_Seraph_LandAttack2_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('MobileMissiles', quantity[Difficulty])
    opai:SetLockingStyle('None')

    -- sends 4, 6, 8 [heavy tanks]
    quantity = {4, 6, 8}
    opai = SeraphimM3Base:AddOpAI('BasicLandAttack', 'M3_LandAttack3',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Seraph_LandAttack1_Chain', 'M3_Seraph_LandAttack2_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('HeavyTanks', quantity[Difficulty])
    opai:SetLockingStyle('None')

    -- sends 4, 6, 8 [siege bots]
    quantity = {4, 6, 8}
    opai = SeraphimM3Base:AddOpAI('BasicLandAttack', 'M3_LandAttack4',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Seraph_LandAttack1_Chain', 'M3_Seraph_LandAttack2_Chain'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('SiegeBots', quantity[Difficulty])

    -- sends 0, 1, 3 [mobile heavy artillery]
    if(Difficulty > 1) then
        quantity = {0, 1, 3}
        opai = SeraphimM3Base:AddOpAI('BasicLandAttack', 'M3_LandAttack5',
            {
                MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'PatrolChainPickerThread'},
                PlatoonData = {
                    PatrolChains = {'M3_Seraph_LandAttack1_Chain', 'M3_Seraph_LandAttack2_Chain'},
                },
                Priority = 110,
            }
        )
        opai:SetChildQuantity('MobileHeavyArtillery', quantity[Difficulty])
    end

    -- sends 4, 6, 8 [mobile flak,  mobile shields] if player has > 40, 30, 20 T2/T3 planes
    quantity = {4, 6, 8}
    trigger = {40, 30, 20}
    opai = SeraphimM3Base:AddOpAI('BasicLandAttack', 'M3_LandAttack6',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Seraph_LandAttack1_Chain', 'M3_Seraph_LandAttack2_Chain'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity({'MobileFlak', 'MobileShields'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], (categories.AIR * categories.MOBILE) - categories.TECH1, '>='})

    -- sends 4, 6, 8 [siege bots] if player has > 60, 40, 30 T2/T3 land units
    quantity = {4, 6, 8}
    trigger = {60, 40, 30}
    opai = SeraphimM3Base:AddOpAI('BasicLandAttack', 'M3_LandAttack7',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Seraph_LandAttack1_Chain', 'M3_Seraph_LandAttack2_Chain'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('SiegeBots', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], (categories.LAND * categories.MOBILE) - categories.TECH1, '>='})

    -- sends 4, 6, 8 [siege bots] if player has > 60, 40, 30 T2/T3 defense structures + artillery
    quantity = {4, 6, 8}
    trigger = {60, 40, 30}
    opai = SeraphimM3Base:AddOpAI('BasicLandAttack', 'M3_LandAttack8',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Seraph_LandAttack1_Chain', 'M3_Seraph_LandAttack2_Chain'},
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('SiegeBots', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], ((categories.DEFENSE * categories.STRUCTURE) + (categories.ARTILLERY)) - categories.TECH1, '>='})

    -- sends 3, 5, 5 [mobile heavy artillery] if player has > 450, 400, 350 units
    quantity = {3, 5, 5}
    trigger = {450, 400, 350}
    opai = SeraphimM3Base:AddOpAI('BasicLandAttack', 'M3_LandAttack9',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Seraph_LandAttack1_Chain', 'M3_Seraph_LandAttack2_Chain'},
            },
            Priority = 140,
        }
    )
    opai:SetChildQuantity('MobileHeavyArtillery', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL, '>='})

    -------------------
    -- Transport Attacks
    -------------------
    -- sends 1, 2, 3 [heavy tanks]
    quantity = {1, 2, 3}
    opai = SeraphimM3Base:AddOpAI('BasicLandAttack', 'M3_SeraphimTransportAttack1',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain = 'M3_Seraph_Transport1_Attack_Chain',
                LandingChain = 'M3_Seraph_Transport1_Landing_Chain',
                TransportReturn = 'M3_Seraphim_Base_Marker',
            },
            Priority = 100,
        }
    )
    opai:SetChildActive('All', false)
    opai:SetChildActive('T2Transports', true)
    opai:SetChildActive('HeavyTanks', true)
    opai:SetChildCount(quantity[Difficulty])

    -- sends 1, 2, 3 [mobile missiles]
    quantity = {1, 2, 3}
    opai = SeraphimM3Base:AddOpAI('BasicLandAttack', 'M3_SeraphimTransportAttack2',
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain = 'M3_Seraph_Transport1_Attack_Chain',
                LandingChain = 'M3_Seraph_Transport1_Landing_Chain',
                TransportReturn = 'M3_Seraphim_Base_Marker',
            },
            Priority = 100,
        }
    )
    opai:SetChildActive('All', false)
    opai:SetChildActive('T2Transports', true)
    opai:SetChildActive('MobileMissiles', true)
    opai:SetChildCount(quantity[Difficulty])

    ----------------------
    -- Hard Difficulty Only
    ----------------------
    if(Difficulty == 3) then
       opai = SeraphimM3Base:AddOpAI('BasicLandAttack', 'M3_SeraphimTransportAttackHard1',
           {
                MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
                PlatoonData = {
                    AttackChain = 'M3_Seraph_Transport1_Attack_Chain',
                    LandingChain = 'M3_Seraph_Transport1_Landing_Chain',
                    TransportReturn = 'M3_Seraphim_Base_Marker',
                },
                Priority = 110,
           }
       )
       opai:SetChildActive('All', false)
       opai:SetChildActive('T2Transports', true)
       opai:SetChildActive('SiegeBots', true)
       opai:SetChildCount(1)
    end

    ----------------
    -- Land Defense N
    ----------------

    -- maintains 8, 12, 16 [heavy tanks]
    quantity = {4, 6, 8}
    for i = 1, 2 do
        opai = SeraphimM3Base:AddOpAI('BasicLandAttack', 'M3_SeraphimLandDefenseN1_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M3_Seraph_LandNorth_Def_Chain',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('HeavyTanks', quantity[Difficulty])
    end

    -- maintains 6, 10, 16 [mobile missiles]
    quantity = {3, 5, 8}
    for i = 1, 2 do
        opai = SeraphimM3Base:AddOpAI('BasicLandAttack', 'M3_SeraphimLandDefenseN2_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M3_Seraph_LandNorth_Def_Chain',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('MobileMissiles', quantity[Difficulty])
    end

    -- maintains 8, 12, 16 [mobile aa]
    quantity = {4, 6, 8}
    for i = 1, 2 do
        opai = SeraphimM3Base:AddOpAI('BasicLandAttack', 'M3_SeraphimLandDefenseN3_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M3_Seraph_LandNorth_Def_Chain',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('MobileAntiAir', quantity[Difficulty])
    end

    ----------------
    -- Land Defense S
    ----------------

    -- maintains 4, 8, 16 [siege bots]
    quantity = {2, 4, 8}
    for i = 1, 2 do
        opai = SeraphimM3Base:AddOpAI('BasicLandAttack', 'M3_SeraphimLandDefenseS1_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M3_Seraph_LandSouth_Def_Chain',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('SiegeBots', quantity[Difficulty])
    end

    -- maintains 8, 12, 16 [mobile flak]
    quantity = {4, 6, 8}
    for i = 1, 2 do
        opai = SeraphimM3Base:AddOpAI('BasicLandAttack', 'M3_SeraphimLandDefenseS2_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M3_Seraph_LandSouth_Def_Chain',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('MobileFlak', quantity[Difficulty])
    end

    -- maintains 2, 4, 8 [mobile heavy artillery]
    quantity = {2, 4, 8}
    for i = 1, quantity[Difficulty] do
        opai = SeraphimM3Base:AddOpAI('BasicLandAttack', 'M3_SeraphimLandDefenseS3_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M3_Seraph_LandSouth_Def_Chain',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('MobileHeavyArtillery', 1)
    end
end

function SeraphimM3WestBaseAI()

    -----------------------------
    -- Seraphim M3 Naval Base West
    -----------------------------
    SeraphimM3WestBase:InitializeDifficultyTables(ArmyBrains[Seraphim], 'M3_Seraph_Naval_West', 'M3_Seraph_Naval_West', 100, {M3_Seraph_Naval_West = 100})
    SeraphimM3WestBase:StartNonZeroBase({{3, 4, 6}, {3, 3, 5}})

    ForkThread(function()
        WaitSeconds(1)
        SeraphimM3WestBase:AddBuildGroup('M3_Seraph_Naval_West_Support_Factories', 100, true)
    end)

    SeraphimM3WestNavalAttacks()
end

function SeraphimM3WestNavalAttacks()
    local opai = nil
    local maxQuantity = {}
    local minQuantity = {}
    local trigger = {}

    ---------------------------------------
    -- Seraphim M3 West Op AI, Naval Attacks
    ---------------------------------------

    -- sends 2, 5, 8 frigate power of [frigates]
    maxQuantity = {2, 5, 8}
    minQuantity = {2, 5, 8}
    opai = SeraphimM3WestBase:AddNavalAI('M3_WestNavalAttack1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Seraph_Naval_West1_Attack_Chain', 'M3_Seraph_Naval_West2_Attack_Chain'},
            },
            EnableTypes = {'Frigate'},
            MaxFrigates = maxQuantity[Difficulty],
            MinFrigates = minQuantity[Difficulty],
            Priority = 100,
        }
    )

    -- sends 4, 6, 10 frigate power of [frigates, subs] if player has >= 8, 6, 4 boats
    maxQuantity = {4, 6, 10}
    minQuantity = {4, 6, 10}
    trigger = {8, 6, 4}
    opai = SeraphimM3WestBase:AddNavalAI('M3_WestNavalAttack2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Seraph_Naval_West1_Attack_Chain', 'M3_Seraph_Naval_West2_Attack_Chain'},
            },
            EnableTypes = {'Frigate', 'Submarine'},
            MaxFrigates = maxQuantity[Difficulty],
            MinFrigates = minQuantity[Difficulty],
            Priority = 110,
        }
    )
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE, '>='})

    -- sends 6, 9, 12 frigate power of [all but T3] if player has >= 4, 3, 2 T2/T3 boats
    maxQuantity = {6, 9, 12}
    minQuantity = {6, 9, 12}
    trigger = {4, 3, 2}
    opai = SeraphimM3WestBase:AddNavalAI('M3_WestNavalAttack3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Seraph_Naval_West1_Attack_Chain', 'M3_Seraph_Naval_West2_Attack_Chain'},
            },
            MaxFrigates = maxQuantity[Difficulty],
            MinFrigates = minQuantity[Difficulty],
            Priority = 120,
        }
    )
    opai:SetChildActive('T3', false)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], (categories.NAVAL * categories.MOBILE) - categories.TECH1, '>='})

    -- sends 9, 12, 15 frigate power of [all but T3] if player has >= 6, 5, 4 T2/T3 boats
    maxQuantity = {9, 12, 15}
    minQuantity = {9, 12, 15}
    trigger = {6, 5, 4}
    opai = SeraphimM3WestBase:AddNavalAI('M3_WestNavalAttack4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Seraph_Naval_West1_Attack_Chain', 'M3_Seraph_Naval_West2_Attack_Chain'},
            },
            MaxFrigates = maxQuantity[Difficulty],
            MinFrigates = minQuantity[Difficulty],
            Priority = 130,
        }
    )
    opai:SetChildActive('T3', false)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], (categories.NAVAL * categories.MOBILE) - categories.TECH1, '>='})

    -- sends 35, 40, 45 frigate power of [all] if player has >= 8, 7, 6 T2/T3 boats
    maxQuantity = {60, 65, 70}
    minQuantity = {60, 65, 70}
    trigger = {10, 9, 8}
    opai = SeraphimM3WestBase:AddNavalAI('M3_WestNavalAttack5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Seraph_Naval_West1_Attack_Chain', 'M3_Seraph_Naval_West2_Attack_Chain'},
            },
            MaxFrigates = maxQuantity[Difficulty],
            MinFrigates = minQuantity[Difficulty],
            Priority = 140,
        }
    )
    opai:SetChildActive('T1', false)
    opai:SetChildActive('T2', false)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], (categories.NAVAL * categories.MOBILE) - categories.TECH1, '>='})

    -- sends 75, 100, 125 frigate power of [all] if player has >= 6, 5, 4 T3/T4 boats
    maxQuantity = {75, 100, 125}
    minQuantity = {75, 100, 125}
    trigger = {6, 5, 4}
    opai = SeraphimM3WestBase:AddNavalAI('M3_WestNavalAttack6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Seraph_Naval_West1_Attack_Chain', 'M3_Seraph_Naval_West2_Attack_Chain'},
            },
            MaxFrigates = maxQuantity[Difficulty],
            MinFrigates = minQuantity[Difficulty],
            Priority = 150,
            EnabledTypes = {'Battleship'},
        }
    )
    opai:SetChildActive('T1', false)
    opai:SetChildActive('T2', false)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], (categories.NAVAL * categories.MOBILE) - categories.TECH1 - categories.TECH2, '>='})

    -- sends 3, 4, 5 Sub Hunters if player has >= 2, 2, 1 Atlantis + Tempest
    maxQuantity = {150, 200, 250}
    minQuantity = {150, 200, 250}
    trigger = {2, 2, 1}
    opai = SeraphimM3WestBase:AddNavalAI('M3_WestNavalAttack7',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Seraph_Naval_West1_Attack_Chain', 'M3_Seraph_Naval_West2_Attack_Chain'},
            },
            MaxFrigates = maxQuantity[Difficulty],
            MinFrigates = minQuantity[Difficulty],
            Priority = 150,
            EnabledTypes = {'Submarine'},
        }
    )
    opai:SetChildActive('T1', false)
    opai:SetChildActive('T2', false)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.ues0401 + categories.uas0401, '>='})
end

function SeraphimM3EastBaseAI()

    -----------------------------
    -- Seraphim M3 Naval Base East
    -----------------------------
    SeraphimM3EastBase:InitializeDifficultyTables(ArmyBrains[Seraphim], 'M3_Seraph_Naval_East', 'M3_Seraph_Naval_East', 100, {M3_Seraph_Naval_East = 100})
    SeraphimM3EastBase:StartNonZeroBase({{2, 3, 5}, {2, 3, 4}})

    ForkThread(function()
        WaitSeconds(1)
        SeraphimM3EastBase:AddBuildGroup('M3_Seraph_Naval_East_Support_Factories', 100, true)
    end)

    SeraphimM3EastNavalAttacks()
end

function SeraphimM3EastNavalAttacks()
    local opai = nil
    local maxQuantity = {}
    local minQuantity = {}
    local trigger = {}

    ---------------------------------------
    -- Seraphim M3 East Op AI, Naval Attacks
    ---------------------------------------

    -- sends 2, 5, 8 frigate power of [frigates]
    maxQuantity = {2, 5, 8}
    minQuantity = {2, 5, 8}
    opai = SeraphimM3EastBase:AddNavalAI('M3_EastNavalAttack1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Seraph_Naval_East_Attack_Chain',
            },
            EnableTypes = {'Frigate'},
            MaxFrigates = maxQuantity[Difficulty],
            MinFrigates = minQuantity[Difficulty],
            Priority = 100,
        }
    )

    -- sends 4, 6, 10 frigate power of [frigates, subs] if player has >= 8, 6, 4 boats
    maxQuantity = {4, 6, 10}
    minQuantity = {4, 6, 10}
    trigger = {8, 6, 4}
    opai = SeraphimM3EastBase:AddNavalAI('M3_EastNavalAttack2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Seraph_Naval_East_Attack_Chain',
            },
            EnableTypes = {'Frigate', 'Submarine'},
            MaxFrigates = maxQuantity[Difficulty],
            MinFrigates = minQuantity[Difficulty],
            Priority = 110,
        }
    )
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE, '>='})

    -- sends 6, 9, 12 frigate power of [all but T3] if player has >= 4, 3, 2 T2/T3 boats
    maxQuantity = {6, 9, 12}
    minQuantity = {6, 9, 12}
    trigger = {4, 3, 2}
    opai = SeraphimM3EastBase:AddNavalAI('M3_EastNavalAttack3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Seraph_Naval_East_Attack_Chain',
            },
            MaxFrigates = maxQuantity[Difficulty],
            MinFrigates = minQuantity[Difficulty],
            Priority = 120,
        }
    )
    opai:SetChildActive('T3', false)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], (categories.NAVAL * categories.MOBILE) - categories.TECH1, '>='})

    -- sends 9, 12, 15 frigate power of [all but T3] if player has >= 6, 5, 4 T2/T3 boats
    maxQuantity = {9, 12, 15}
    minQuantity = {9, 12, 15}
    trigger = {6, 5, 4}
    opai = SeraphimM3EastBase:AddNavalAI('M3_EastNavalAttack4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Seraph_Naval_East_Attack_Chain',
            },
            MaxFrigates = maxQuantity[Difficulty],
            MinFrigates = minQuantity[Difficulty],
            Priority = 130,
        }
    )
    opai:SetChildActive('T3', false)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], (categories.NAVAL * categories.MOBILE) - categories.TECH1, '>='})

    -- sends 35, 40, 45 frigate power of [all] if player has >= 8, 7, 6 T2/T3 boats
    maxQuantity = {35, 40, 45}
    minQuantity = {35, 40, 45}
    trigger = {8, 7, 6}
    opai = SeraphimM3EastBase:AddNavalAI('M3_EastNavalAttack5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Seraph_Naval_East_Attack_Chain',
            },
            MaxFrigates = maxQuantity[Difficulty],
            MinFrigates = minQuantity[Difficulty],
            Priority = 140,
        }
    )
    opai:SetChildActive('T1', false)
    opai:SetChildActive('T2', false)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], (categories.NAVAL * categories.MOBILE) - categories.TECH1, '>='})

    -- sends 50, 75, 100 frigate power of [all] if player has >= 7, 6, 5 T3/T4 boats
    maxQuantity = {50, 75, 100}
    minQuantity = {50, 75, 100}
    trigger = {7, 6, 5}
    opai = SeraphimM3EastBase:AddNavalAI('M3_EastNavalAttack6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Seraph_Naval_East_Attack_Chain',
            },
            MaxFrigates = maxQuantity[Difficulty],
            MinFrigates = minQuantity[Difficulty],
            Priority = 150,
            EnabledTypes = {'Battleship'},
        }
    )
    opai:SetChildActive('T1', false)
    opai:SetChildActive('T2', false)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], (categories.NAVAL * categories.MOBILE) - categories.TECH1 - categories.TECH2, '>='})

    -- sends 2, 3, 4 Sub Hunters if player has >= 2, 2, 1 Atlantis + Tempest
    maxQuantity = {100, 150, 200}
    minQuantity = {100, 150, 200}
    trigger = {2, 2, 1}
    opai = SeraphimM3EastBase:AddNavalAI('M3_EastNavalAttack7',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Seraph_Naval_East_Attack_Chain',
            },
            MaxFrigates = maxQuantity[Difficulty],
            MinFrigates = minQuantity[Difficulty],
            Priority = 150,
            EnabledTypes = {'Submarine'},
        }
    )
    opai:SetChildActive('T1', false)
    opai:SetChildActive('T2', false)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.ues0401 + categories.uas0401, '>='})
end
