-- ****************************************************************************
-- **
-- **  File     : /maps/X1CA_Coop_006/X1CA_Coop_006_m2fletcherai.lua
-- **  Author(s): Jessica St. Croix
-- **
-- **  Summary  : Fletcher army AI for Mission 2 - X1CA_Coop_006
-- **
-- **  Copyright © 2007 Gas Powered Games, Inc.  All rights reserved.
-- ****************************************************************************
local BaseManager = import('/lua/ai/opai/basemanager.lua')

local SPAIFileName = '/lua/ScenarioPlatoonAI.lua'

--------
-- Locals
--------
local Fletcher = 3
local Difficulty = ScenarioInfo.Options.Difficulty

---------------
-- Base Managers
---------------
local FletcherM2Base = BaseManager.CreateBaseManager()
local FletcherM2ExpBase = BaseManager.CreateBaseManager()

function FletcherM2BaseAI()

    ------------------
    -- Fletcher M2 Base
    ------------------
    FletcherM2Base:Initialize(
        ArmyBrains[Fletcher],
        'M2_Fletcher_Base',
        'M2_Fletcher_Base_Marker',
        170,
        {
            M2_Fletcher_Base_D2 = 100,
            M2_Fletcher_InitStructure = 100,
        }
    )
    FletcherM2Base:StartNonZeroBase({{5, 10, 14}, {5, 9, 12}})
    FletcherM2Base:SetActive('AirScouting', true)

    FletcherM2BaseNavalAttacks()
    FletcherM2BaseAirAttacks()
    FletcherM2BaseLandAttacks()
end

function FletcherM2BaseNavalAttacks()
    local opai = nil

    ---------------------------------------
    -- Fletcher M2 Base Op AI, Naval Attacks
    ---------------------------------------

    local Temp = {
        'NavalAttackTemp',
        'NoPlan',
        { 'ues0201', 1, 4, 'Attack', 'GrowthFormation' },    -- Destroyers
        { 'ues0202', 1, 3, 'Attack', 'GrowthFormation' },    -- Cruisers
        { 'xes0102', 1, 4, 'Attack', 'GrowthFormation' },    -- Torpedo Boat
    }
    local Builder = {
        BuilderName = 'NavyAttackBuilder',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 200,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'M2_Fletcher_Base',
        PlatoonAIFunction = {SPAIFileName, 'RandomPatrolThread'},
        PlatoonData = {
            PatrolChain = 'M2_Rhiza_NavalAttack_Chain',
        },
    }
    ArmyBrains[Fletcher]:PBMAddPlatoon( Builder )
-- =========================================================================================
    Temp = {
        'NavalDefenseTemp',
        'NoPlan',
        { 'ues0201', 1, 2, 'Attack', 'GrowthFormation' },    -- Destroyers
        { 'ues0202', 1, 1, 'Attack', 'GrowthFormation' },    -- Cruisers
    }
    Builder = {
        BuilderName = 'NavyDefenseBuilder',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 300,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'M2_Fletcher_Base',
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},
        PlatoonData = {
            PatrolChain = 'M2_Rhiza_NavalAttack_Fletcher_Chain',
        },
    }
    ArmyBrains[Fletcher]:PBMAddPlatoon( Builder )
end

function FletcherM2BaseAirAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    -------------------------------------
    -- Fletcher M2 Base Op AI, Air Attacks
    -------------------------------------

    local template = {
        'HeavyAir1',
        'NoPlan',
        { 'uea0303', 1, 9, 'Attack', 'GrowthFormation' },    -- Air Superiority
        { 'uea0204', 1, 18, 'Attack', 'GrowthFormation' },    -- Gunships
        { 'uea0305', 1, 9, 'Attack', 'GrowthFormation' },    -- Heavy Gunships
        { 'uea0102', 1, 18, 'Attack', 'GrowthFormation' },    -- Interceptors
    }
    local builder = {
        BuilderName = 'HeavyAir1',
        PlatoonTemplate = template,
        InstanceCount = 2,
        Priority = 220,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'M2_Fletcher_Base',
        PlatoonAIFunction = {SPAIFileName, 'RandomPatrolThread'},
        PlatoonData = {
            PatrolChain = 'M2_Fletcher_AirAttack_MAIN_Chain',
        },
    }
    ArmyBrains[Fletcher]:PBMAddPlatoon( builder )

    -- sends 9, 18, 27 [air superiority, heavy gunships, bombers] all over the map
    quantity = {9, 18, 27}
    for i = 1, 3 do
    opai = FletcherM2Base:AddOpAI('AirAttacks', 'M2_FletcherAirAttacks_MAIN_1' .. i,
        {
            MasterPlatoonFunction = {SPAIFileName, 'RandomPatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Fletcher_AirAttack_MAIN_Chain',
            },
            Priority = 200,
        }
    )
    opai:SetChildQuantity({'AirSuperiority', 'HeavyGunships', 'Bombers'}, quantity[Difficulty])
    end

    -- sends 9, 18, 27 [bombers], ([gunships] on hard)
    quantity = {9, 18, 27}
    opai = FletcherM2Base:AddOpAI('AirAttacks', 'M2_FletcherAirAttacks1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Fletcher_AirAttack1_Chain', 'M2_Fletcher_AirAttack1_Chain'},
            },
            Priority = 110,
        }
    )
    opai:SetChildActive('All', false)
    if(Difficulty < 3) then
        opai:SetChildQuantity('Bombers', quantity[Difficulty])
    else
        opai:SetChildQuantity('Gunships', quantity[Difficulty])
    end

    -- sends 9, 18, 27 [gunships], ([heavy gunships] on hard)
    quantity = {9, 18, 27}
    opai = FletcherM2Base:AddOpAI('AirAttacks', 'M2_FletcherAirAttacks2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Fletcher_AirAttack1_Chain', 'M2_Fletcher_AirAttack1_Chain'},
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

    -- sends 4, 8, 18 [gunships, combat fighters]
    quantity = {4, 8, 18}
    opai = FletcherM2Base:AddOpAI('AirAttacks', 'M2_FletcherAirAttacks3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Fletcher_AirAttack1_Chain', 'M2_Fletcher_AirAttack1_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'Gunships', 'CombatFighters'}, quantity[Difficulty])
    opai:SetLockingStyle('None')

    -- sends 9, 18, 27 [gunships] if player has >= 100, 80, 60 mobile land
    quantity = {9, 18, 27}
    trigger = {100, 80, 60}
    opai = FletcherM2Base:AddOpAI('AirAttacks', 'M2_FletcherAirAttacks4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Fletcher_AirAttack1_Chain', 'M2_Fletcher_AirAttack1_Chain'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], (categories.MOBILE * categories.LAND) - categories.CONSTRUCTION})

    -- sends 9, 18, 27 [air superiority] if player has >= 80, 60, 60 mobile air
    quantity = {9, 18, 27}
    trigger = {80, 60, 60}
    opai = FletcherM2Base:AddOpAI('AirAttacks', 'M2_FletcherAirAttacks5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Fletcher_AirAttack1_Chain', 'M2_Fletcher_AirAttack1_Chain'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.MOBILE * categories.AIR})

    -- sends 9, 18, 27 [air superiority] if player has >= 60, 40, 40 gunships
    quantity = {9, 18, 27}
    trigger = {60, 40, 40}
    opai = FletcherM2Base:AddOpAI('AirAttacks', 'M2_FletcherAirAttacks6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Fletcher_AirAttack1_Chain', 'M2_Fletcher_AirAttack1_Chain'},
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
    opai = FletcherM2Base:AddOpAI('AirAttacks', 'M2_FletcherAirAttacks7',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Fletcher_AirAttack1_Chain', 'M2_Fletcher_AirAttack1_Chain'},
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity({'Gunships', 'CombatFighters'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainGreaterThanOrEqualNumCategory', {'default_brain', 'Player', trigger[Difficulty], categories.TECH3})

    -- sends 9, 18, 27 [air superiority] if player has >= 1 strat bomber
    quantity = {9, 18, 27}
    opai = FletcherM2Base:AddOpAI('AirAttacks', 'M2_FletcherAirAttacks8',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Fletcher_AirAttack1_Chain', 'M2_Fletcher_AirAttack1_Chain'},
            },
            Priority = 140,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainGreaterThanOrEqualNumCategory', {'default_brain', 'Player', 1, categories.uaa0304 + categories.uea0304 + categories.ura0304})

    -- sends 8, 16, 26 [bombers, gunships] if player has >= 450, 400, 300 units
    quantity = {8, 16, 26}
    trigger = {450, 400, 300}
    opai = FletcherM2Base:AddOpAI('AirAttacks', 'M2_FletcherAirAttacks9',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Fletcher_AirAttack1_Chain', 'M2_Fletcher_AirAttack1_Chain'},
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity({'Bombers', 'Gunships'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainGreaterThanOrEqualNumCategory', {'default_brain', 'Player', trigger[Difficulty], categories.ALLUNITS - categories.WALL})

    -- Air Defense
    quantity = {3, 6, 9}
    for i = 1, 3 do
        opai = FletcherM2Base:AddOpAI('AirAttacks', 'M2_FletcherAirDefense1_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M2_Fletcher_AirDef_Chain',
                },
                Priority = 250,
            }
        )
        opai:SetChildQuantity('HeavyGunships', quantity[Difficulty])
    end

    quantity = {3, 6, 9}
    for i = 1, 3 do
        opai = FletcherM2Base:AddOpAI('AirAttacks', 'M2_FletcherAirDefense2_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M2_Fletcher_AirDef_Chain',
                },
                Priority = 250,
            }
        )
        opai:SetChildQuantity('TorpedoBombers', quantity[Difficulty])
    end

    quantity = {3, 6, 9}
    for i = 1, 3 do
        opai = FletcherM2Base:AddOpAI('AirAttacks', 'M2_FletcherAirDefense3_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M2_Fletcher_AirDef_Chain',
                },
                Priority = 250,
            }
        )
        opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    end
end

function FletcherM2BaseLandAttacks()
    local opai = nil
    local quantity = {}

    ------------------------
    -- Fletcher M2 Base Op AI
    ------------------------

    quantity = {1, 3, 5}
    opai = FletcherM2Base:AddOpAI('M2_Fletcher_Main_Fatboy',
        {
            Amount = 2,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Fletcher_ExpAttack_Chain',
            },
            MaxAssist = quantity[Difficulty],
            Retry = true,
        }
    )

    -- Land Defense
    quantity = {5, 10, 15}
    for i = 1, quantity[Difficulty] do
        opai = FletcherM2Base:AddOpAI('BasicLandAttack', 'M2_FletcherLandDefense1_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M2_Fletcher_LandDef_Chain',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('MobileShields', 1)
    end

    quantity = {5, 10, 15}
    for i = 1, quantity[Difficulty] do
        opai = FletcherM2Base:AddOpAI('BasicLandAttack', 'M2_FletcherLandDefense2_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M2_Fletcher_LandDef_Chain',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('MobileMissiles', 1)
    end

    quantity = {5, 10, 15}
    for i = 1, quantity[Difficulty] do
        opai = FletcherM2Base:AddOpAI('BasicLandAttack', 'M2_FletcherLandDefense3_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M2_Fletcher_LandDef_Chain',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('MobileMissilePlatforms', 1)
    end
end

function FletcherCaptureControlCenter()
    -- Transport Builder
    local opai = FletcherM2Base:AddOpAI('EngineerAttack', 'M2_Fletcher_TransportBuilder',
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
    opai:SetChildActive('T3Transports', true)
    opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
        'HaveLessThanUnitsWithCategory', {'default_brain', 3, categories.uea0104})

    -- sends engineers
    opai = FletcherM2Base:AddOpAI('EngineerAttack', 'M2_FletcherEngAttack1',
    {
        MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
        PlatoonData = {
            AttackChain = 'M2_OptionZero_Capture_Chain',
            LandingChain = 'M2_OptionZero_Landing_Chain',
            TransportReturn = 'M2_Fletcher_Base_Marker',
            Categories = {'uec1902'},
        },
        Priority = 1000,
    })
    opai:SetChildActive('T1Transports', false)
    opai:SetChildActive('T2Transports', false)
    opai:SetChildActive('T3Transports', false)

    for i = 1, 4 do
    opai = FletcherM2Base:AddOpAI('BasicLandAttack', 'M2_FletcherTransportAttack_ToSeraphim' .. i,
    {
        MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
        PlatoonData = {
            AttackChain = 'M2_Rhiza_Transport_Attack_Chain',
            LandingChain = 'M1_Fatboy_Move_Chain',
            TransportReturn = 'M2_Fletcher_Base_Marker',
        },
        Priority = 1000,
    })
    opai:SetChildQuantity({'MobileShields', 'HeavyTanks', 'MobileAntiAir'},  12)
    end
end

function FletcherM2ExpBaseAI()

    ----------------------
    -- Fletcher M2 Exp Base
    ----------------------
    FletcherM2ExpBase:InitializeDifficultyTables(ArmyBrains[Fletcher], 'M2_Fletcher_EastExp_Group', 'M2_Fletcher_Exp_Base', 30, {M2_Fletcher_EastExp_Group = 100})
    FletcherM2ExpBase:StartNonZeroBase({0, 1, 2})

    FletcherM2ExpBaseLandAttacks()
end

function FletcherM2ExpBaseLandAttacks()
    local opai = nil

    ------------------------------------------
    -- Fletcher M2 Exp Base Op AI, Land Attacks
    ------------------------------------------

    opai = FletcherM2ExpBase:AddOpAI('M2_Fletcher_East_Fatboy',
        {
            Amount = 1,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Fletcher_EasternExp_Chain',
            },

            MaxAssist = 3,
            Retry = true,
        }
    )
end
