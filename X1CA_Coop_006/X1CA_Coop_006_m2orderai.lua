-- ****************************************************************************
-- **
-- **  File     : /maps/X1CA_Coop_006/X1CA_Coop_006_v02_m2orderai.lua
-- **  Author(s): Jessica St. Croix
-- **
-- **  Summary  : Order army AI for Mission 2 - X1CA_Coop_006
-- **
-- **  Copyright © 2007 Gas Powered Games, Inc.  All rights reserved.
-- ****************************************************************************
local BaseManager = import('/lua/ai/opai/basemanager.lua')

local SPAIFileName = '/lua/ScenarioPlatoonAI.lua'

--------
-- Locals
--------
local Order = 4
local Difficulty = ScenarioInfo.Options.Difficulty

---------------
-- Base Managers
---------------
local OrderM2Base = BaseManager.CreateBaseManager()

function OrderM2BaseAI()

    ---------------
    -- Order M2 Base
    ---------------
    OrderM2Base:InitializeDifficultyTables(ArmyBrains[Order], 'M2_Order_MainBase', 'M2_Order_Base_Marker', 100, {M2_Order_MainBase = 100})
    OrderM2Base:StartNonZeroBase({{6, 11, 23}, {6, 10, 20}})
    OrderM2Base:SetActive('AirScouting', true)

    ArmyBrains[Order]:PBMSetCheckInterval(3)

    OrderM2BaseAirAttacks()
    OrderM2BaseLandAttacks()
    OrderM2BaseNavalAttacks()
end

function OrderM2BaseAirAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}
    local template = {}
    local builder = {}

    -----------------------------------
    -- Order M2 Base Op AI - Air Attacks
    -----------------------------------

    template = {
        'OrderAirToFletcher1',
        'NoPlan',
        { 'xaa0305', 1, 6, 'Attack', 'GrowthFormation' },    -- Heavy Gunships
        { 'uaa0203', 1, 12, 'Attack', 'GrowthFormation' },    -- Gunships
        { 'uaa0303', 1, 6, 'Attack', 'GrowthFormation' },    -- Air Superiority
    }
    builder = {
        BuilderName = 'OrderAirToFletcher1',
        PlatoonTemplate = template,
        InstanceCount = 1,
        Priority = 150,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'M2_Order_MainBase',
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},
        PlatoonData = {
            PatrolChain = 'M2_Rhiza_AirAttack_Fletcher_Chain',
        },
    }
    ArmyBrains[Order]:PBMAddPlatoon( builder )                -- SENDS A SMALL AIRFORCE TO FLETCHER'S BASE

-- ==============================================================================================================

    -- sends 6, 18, 24 [gunships, combat fighters] (to Fletcher)
    quantity = {12, 18, 24}
    opai = OrderM2Base:AddOpAI('AirAttacks', 'M2_OrderAirAttacks_Fletcher_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Rhiza_AirAttack_Fletcher_Chain',
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity({'Gunships', 'CombatFighters'}, quantity[Difficulty])

    -- sends 6, 18, 24 [bombers], ([gunships] on hard)
    quantity = {12, 18, 24}
    opai = OrderM2Base:AddOpAI('AirAttacks', 'M2_OrderAirAttacks1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Order_AirAttack_1_Chain', 'M2_Order_AirAttack_2_Chain'},
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

    -- sends 6, 18, 24 [gunships], ([heavy gunships] on hard)
    quantity = {6, 18, 18}
    opai = OrderM2Base:AddOpAI('AirAttacks', 'M2_OrderAirAttacks2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Order_AirAttack_1_Chain', 'M2_Order_AirAttack_2_Chain'},
            },
            Priority = 100,
        }
    )
    if(Difficulty < 3) then
        opai:SetChildQuantity('Gunships', quantity[Difficulty])
    else
        opai:SetChildQuantity('HeavyGunships', quantity[Difficulty])
    end
    opai:SetLockingStyle('None')

    -- sends 6, 12, 18 [gunships, combat fighters]
    quantity = {6, 12, 18}
    opai = OrderM2Base:AddOpAI('AirAttacks', 'M2_OrderAirAttacks3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Order_AirAttack_1_Chain', 'M2_Order_AirAttack_2_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'Gunships', 'CombatFighters'}, quantity[Difficulty])
    opai:SetLockingStyle('None')

    -- sends 6, 18, 24 [gunships] if player has >= 100, 80, 60 mobile land
    quantity = {6, 18, 24}
    trigger = {100, 80, 60}
    opai = OrderM2Base:AddOpAI('AirAttacks', 'M2_OrderAirAttacks4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Order_AirAttack_1_Chain', 'M2_Order_AirAttack_2_Chain'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], (categories.MOBILE * categories.LAND) - categories.CONSTRUCTION})

    -- sends 6, 18, 24 [air superiority] if player has >= 80, 60, 60 mobile air
    quantity = {6, 18, 24}
    trigger = {80, 60, 60}
    opai = OrderM2Base:AddOpAI('AirAttacks', 'M2_OrderAirAttacks5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Order_AirAttack_1_Chain', 'M2_Order_AirAttack_2_Chain'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.MOBILE * categories.AIR})

    -- sends 6, 18, 24 [air superiority] if player has >= 60, 40, 40 gunships
    quantity = {6, 18, 24}
    trigger = {60, 40, 40}
    opai = OrderM2Base:AddOpAI('AirAttacks', 'M2_OrderAirAttacks6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Order_AirAttack_1_Chain', 'M2_Order_AirAttack_2_Chain'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.uaa0203 + categories.uea0203 + categories.ura0203})

    -- sends 6, 12, 18 [combat fighters, gunships] if player has >= 60, 40, 20 T3 units
    quantity = {6, 12, 18}
    trigger = {60, 40, 20}
    opai = OrderM2Base:AddOpAI('AirAttacks', 'M2_OrderAirAttacks7',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Order_AirAttack_1_Chain', 'M2_Order_AirAttack_2_Chain'},
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity({'Gunships', 'CombatFighters'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainGreaterThanOrEqualNumCategory', {'default_brain', 'Player', trigger[Difficulty], categories.TECH3})

    -- sends 6, 18, 24 [air superiority] if player has >= 1 strat bomber
    quantity = {6, 18, 24}
    opai = OrderM2Base:AddOpAI('AirAttacks', 'M2_OrderAirAttacks8',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Order_AirAttack_1_Chain', 'M2_Order_AirAttack_2_Chain'},
            },
            Priority = 140,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainGreaterThanOrEqualNumCategory', {'default_brain', 'Player', 1, categories.uaa0304 + categories.uea0304 + categories.ura0304})

    -- sends 6, 18, 24 [bombers, gunships] if player has >= 450, 400, 300 units
    quantity = {6, 18, 24}
    trigger = {450, 400, 300}
    opai = OrderM2Base:AddOpAI('AirAttacks', 'M2_OrderAirAttacks9',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Order_AirAttack_1_Chain', 'M2_Order_AirAttack_2_Chain'},
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity({'Bombers', 'Gunships'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainGreaterThanOrEqualNumCategory', {'default_brain', 'Player', trigger[Difficulty], categories.ALLUNITS - categories.WALL})

    -- Air Defense
    quantity = {4, 8, 12}
    for i = 1, Difficulty do
        opai = OrderM2Base:AddOpAI('AirAttacks', 'M2_OrderAirDefense1_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M2_Order_AirDef_Chain',
                },
                Priority = 150,
            }
        )
        opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    end

    quantity = {4, 8, 12}
    for i = 1, Difficulty do
        opai = OrderM2Base:AddOpAI('AirAttacks', 'M2_OrderAirDefense2_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M2_Order_AirDef_Chain',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('TorpedoBombers', quantity[Difficulty])
    end

    if(Difficulty > 1) then
        quantity = {1, 3, 5}
        opai = OrderM2Base:AddOpAI('M2_Order_Czar',
            {
                Amount = 1,
                KeepAlive = true,
                PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},
                PlatoonData = {
                    PatrolChains = {'M2_Order_CzarAttack_Chain', 'M2_Order_CzarAttack2_Chain', 'M2_Order_CzarAttack3_Chain'},
                },
                MaxAssist = quantity[Difficulty],
                Retry = true,
                WaitSecondsAfterDeath = 120,
            }
        )
    end
    if(Difficulty == 1) then
        quantity = {1, 3, 5}
        opai = OrderM2Base:AddOpAI('M2_Order_Czar',
            {
                Amount = 1,
                KeepAlive = true,
                PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},
                -- uses routes that don't go over player's base.
                PlatoonData = {
                    PatrolChains = {'M2_Order_CzarAlt1_Chain', 'M2_Order_CzarAlt2_Chain'},
                },
                MaxAssist = quantity[Difficulty],
                Retry = true,
                WaitSecondsAfterDeath = 180,
            }
        )
    end
end

function OrderM2BaseLandAttacks()
    local opai = nil
    local quantity = {}

    -- Land Defense
    quantity = {4, 8, 12}
    opai = OrderM2Base:AddOpAI('BasicLandAttack', 'M2_OrderLandDefense1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Order_LandDef_1_Chain', 'M2_Order_LandDef_2_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('SiegeBots', quantity[Difficulty])

    quantity = {4, 8, 12}
    opai = OrderM2Base:AddOpAI('BasicLandAttack', 'M2_OrderLandDefense2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Order_LandDef_1_Chain', 'M2_Order_LandDef_2_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('MobileFlak', quantity[Difficulty])

    quantity = {1, 3, 5}
    for i = 1, quantity[Difficulty] do
        opai = OrderM2Base:AddOpAI('BasicLandAttack', 'M2_OrderLandDefenseArt' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
                PlatoonData = {
                    PatrolChains = {'M2_Order_LandDef_1_Chain', 'M2_Order_LandDef_2_Chain'},
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('MobileHeavyArtillery', 1)
    end
end

function OrderM2BaseNavalAttacks()
    local opai = nil
    local maxQuantity = {}
    local minQuantity = {}
    local trigger = {}
    local template = {}
    local builder = {}

    -- ##################
    -- Custom Builders #
    -- ##################

    template = {
        'OrderNavyToFletcher1',
        'NoPlan',
        { 'uas0201', 1, 4, 'Attack', 'GrowthFormation' },    -- Destroyers
        { 'uas0103', 1, 4, 'Attack', 'GrowthFormation' },    -- Frigates
        { 'uas0202', 1, 2, 'Attack', 'GrowthFormation' },    -- Cruisers
        { 'xas0204', 1, 2, 'Attack', 'GrowthFormation' },    -- Sub Hunters
    }
    builder = {
        BuilderName = 'OrderNavyToFletcher1',
        PlatoonTemplate = template,
        InstanceCount = 1,
        Priority = 100,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'M2_Order_MainBase',
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},
        PlatoonData = {
            PatrolChain = 'M2_Rhiza_NavalAttack_Fletcher_Chain',
        },
    }
    ArmyBrains[Order]:PBMAddPlatoon( builder )                -- SENDS A SMALL FLEET TO FLETCHER'S BASE

-- =============================================================================

    -- sends 4 destroyers, 2 subs (to Rhiza)
    opai = OrderM2Base:AddNavalAI('M2_OrderNavalAttack_Rhiza_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Order_NavalAttack_Rhiza_Chain',
            },
            MaxFrigates = 20,
            MinFrigates = 20,
            Priority = 100,
        }
    )
    opai:SetChildActive('T3', false)

    -- sends 4 destroyers, 2 submarines (to Rhiza)
    opai = OrderM2Base:AddNavalAI('M2_OrderNavalAttack_Rhiza_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Order_NavalAttack_Rhiza_Chain',
            },
            MaxFrigates = 20,
            MinFrigates = 20,
            Priority = 100,
        }
    )

    -- sends 4 frigates (to Rhiza)
    opai = OrderM2Base:AddNavalAI('M2_OrderNavalAttack_Rhiza_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Order_NavalAttack_Rhiza_Chain',
            },
            MaxFrigates = 4,
            MinFrigates = 4,
            Priority = 100,
        }
    )
    opai:SetChildActive('T3', false)

    -- sends 4 frigates (to Rhiza)
    opai = OrderM2Base:AddNavalAI('M2_OrderNavalAttack_Rhiza_4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Order_NavalAttack_Rhiza_Chain',
            },
            MaxFrigates = 4,
            MinFrigates = 4,
            Priority = 100,
        }
    )
    opai:SetChildActive('T3', false)

    maxQuantity = {3, 7, 11}
    minQuantity = {3, 7, 11}
    opai = OrderM2Base:AddNavalAI('M2_OrderNavalAttack1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Order_NavalAttack_1_Chain', 'M2_Order_NavalAttack_2_Chain'},
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
    opai = OrderM2Base:AddNavalAI('M2_OrderNavalAttack2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Order_NavalAttack_1_Chain', 'M2_Order_NavalAttack_2_Chain'},
            },
            EnableTypes = {'Frigate', 'Submarine'},
            MaxFrigates = maxQuantity[Difficulty],
            MinFrigates = minQuantity[Difficulty],
            Priority = 110,
        }
    )
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainGreaterThanOrEqualNumCategory', {'default_brain', 'Player', trigger[Difficulty], categories.NAVAL * categories.MOBILE})

    -- sends 6, 9, 12 frigate power of [all but T3] if player has >= 4, 3, 2 T2/T3 boats
    maxQuantity = {6, 9, 12}
    minQuantity = {6, 9, 12}
    trigger = {4, 3, 2}
    opai = OrderM2Base:AddNavalAI('M2_OrderNavalAttack3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Order_NavalAttack_1_Chain', 'M2_Order_NavalAttack_2_Chain'},
            },
            MaxFrigates = maxQuantity[Difficulty],
            MinFrigates = minQuantity[Difficulty],
            Priority = 120,
        }
    )
    opai:SetChildActive('T3', false)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainGreaterThanOrEqualNumCategory', {'default_brain', 'Player', trigger[Difficulty], (categories.NAVAL * categories.MOBILE) - categories.TECH1})

    -- sends 9, 12, 15 frigate power of [all but T3] if player has >= 6, 5, 4 T2/T3 boats
    maxQuantity = {9, 12, 15}
    minQuantity = {9, 12, 15}
    trigger = {6, 5, 4}
    opai = OrderM2Base:AddNavalAI('M2_OrderNavalAttack4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Order_NavalAttack_1_Chain', 'M2_Order_NavalAttack_2_Chain'},
            },
            MaxFrigates = maxQuantity[Difficulty],
            MinFrigates = minQuantity[Difficulty],
            Priority = 130,
        }
    )
    opai:SetChildActive('T3', false)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainGreaterThanOrEqualNumCategory', {'default_brain', 'Player', trigger[Difficulty], (categories.NAVAL * categories.MOBILE) - categories.TECH1})

    -- Naval Defense
    maxQuantity = {6, 9, 12}
    minQuantity = {6, 9, 12}
    for i = 1, 2 do
        opai = OrderM2Base:AddNavalAI('M2_OrderNavalDefense' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M2_Order_NavalDef_' .. i .. '_Chain',
                },
                MaxFrigates = maxQuantity[Difficulty],
                MinFrigates = minQuantity[Difficulty],
                Priority = 140,
            }
        )
        opai:SetChildActive('T3', false)
    end
end

function OrderCaptureControlCenter()

    -- Transport Builder
    local opai = OrderM2Base:AddOpAI('EngineerAttack', 'M2_Order_TransportBuilder',
    {
        MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
        PlatoonData = {
            AttackChain = 'M2_OptionZero_Capture_Chain',
            LandingChain = 'M2_OptionZero_Landing_Chain',
            TransportReturn = 'M2_Order_Base_Marker',
        },
        Priority = 1000,
    })
    opai:SetChildActive('All', false)
    opai:SetChildActive('T2Transports', true)
    opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
        'HaveLessThanUnitsWithCategory', {'default_brain', 6, categories.uaa0104})

    -- sends engineers
    opai = OrderM2Base:AddOpAI('EngineerAttack', 'M2_OrderEngAttack1',
    {
        MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
        PlatoonData = {
            AttackChain = 'M2_OptionZero_Capture_Chain',
            LandingChain = 'M2_OptionZero_Landing_Chain',
            TransportReturn = 'M2_Order_Base_Marker',
            Categories = {'uec1902'},
        },
        Priority = 1000,
    })
    opai:SetChildActive('T1Transports', false)
    opai:SetChildActive('T2Transports', false)
end
