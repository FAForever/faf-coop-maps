local BaseManager = import('/lua/ai/opai/basemanager.lua')
local CustomFunctions = '/maps/FortClarkeAssault/FortClarkeAssault_CustomFunctions.lua'
local SPAIFileName = '/lua/scenarioplatoonai.lua'

---------
-- Locals
---------
local Order = 3
local Difficulty = ScenarioInfo.Options.Difficulty

---------------
-- Base Managers
---------------
local OrderM2MainBase = BaseManager.CreateBaseManager()
local OrderM2NavalBase = BaseManager.CreateBaseManager()
local OrderM2ExpansionBase = BaseManager.CreateBaseManager()

---------------------
-- Order M2 Main Base
---------------------
function OrderM2MainBaseAI()
    OrderM2MainBase:InitializeDifficultyTables(ArmyBrains[Order], 'M2_Order_Main_Base', 'M2_Main_Base_Marker', 70, {M2_Main_Base = 100})
    OrderM2MainBase:StartNonZeroBase({{11, 14, 17}, {9, 12, 14}})
    OrderM2MainBase:SetActive('AirScouting', true)

    OrderM2MainBaseAirAttacks()
    OrderM2MainBaseLandAttacks()
end

function OrderM2MainBaseAirAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    for i = 1, 2 do
        quantity = {14, 12, 10}
        opai = OrderM2MainBase:AddOpAI('AirAttacks', 'M2_Order_AirAttack_Cybran_1_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M2_Oder_LandAttack_Cybran_Chain',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('Gunships', quantity[Difficulty])
    end

    quantity = {12, 10, 8}
    opai = OrderM2MainBase:AddOpAI('AirAttacks', 'M2_Order_AirAttack_UEF_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Order_Naval_Attack_Chain_1',
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
            'BrainGreaterThanOrEqualNumCategory', {'default_brain', 'UEF', 20, categories.AIR * categories.MOBILE})

    -- Air Defense
    quantity = {8, 7, 6}
    for i = 1, 2 do
        opai = OrderM2MainBase:AddOpAI('AirAttacks', 'M2_Order_AirDefense' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M2_Order_Main_Base_Air_Patrol_Chain',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('HeavyGunships', quantity[Difficulty])
        opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    end

    quantity = {14, 12, 10}
    for i = 3, 4 do
        opai = OrderM2MainBase:AddOpAI('AirAttacks', 'M2_Order_AirDefense' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M2_Order_Main_Base_Air_Patrol_Chain',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
        opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    end

    quantity = {7, 6, 5}
    opai = OrderM2MainBase:AddOpAI('AirAttacks', 'M2_Order_AirDefense6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Order_Naval_Defense_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('HeavyTorpedoBombers', 6)
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    --[[
    -- CZAR Build
    quantity = {1, 2, 4}
    opai = OrderM2MainBase:AddOpAI('M2_Order_CZAR',
        {
            Amount = 1,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Order_Main_Base_Air_Patrol_Chain',
            },
            MaxAssist = quantity[Difficulty],
            Retry = true,
            WaitSecondsAfterDeath = 120,
        }
    )
    ]]--
end

function OrderM2MainBaseLandAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    for i = 1, 2 do
        quantity = {12, 10, 8}
        opai = OrderM2MainBase:AddOpAI('BasicLandAttack', 'M2_LandAttack_Cybran_1_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M2_Oder_LandAttack_Cybran_Chain',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('HeavyTanks', quantity[Difficulty])
        opai:SetFormation('AttackFormation')
        opai:AddBuildCondition('/lua/editor/BaseManagerBuildConditions.lua', 'BaseActive', {'M3_Cybran_Base'})
    end

    for i = 3, 4 do
        quantity = {10, 8, 6}
        opai = OrderM2MainBase:AddOpAI('BasicLandAttack', 'M2_LandAttack_Cybran_1_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M2_Oder_LandAttack_Cybran_Chain',
                },
                Priority = 110,
            }
        )
        opai:SetChildQuantity('SiegeBots', quantity[Difficulty])
        opai:SetFormation('AttackFormation')
        opai:AddBuildCondition('/lua/editor/BaseManagerBuildConditions.lua', 'BaseActive', {'M3_Cybran_Base'})
    end

    for i = 1, 2 do
        quantity = {12, 10, 8}
        opai = OrderM2MainBase:AddOpAI('BasicLandAttack', 'M2_LandAttack_Aeon_1_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M2_Oder_LandAttack_Aeon_Chain',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('HeavyTanks', quantity[Difficulty])
        opai:SetFormation('AttackFormation')
        opai:AddBuildCondition('/lua/editor/BaseManagerBuildConditions.lua', 'BaseActive', {'M3_Aeon_Base'})
    end

    for i = 3, 4 do
        quantity = {10, 8, 6}
        opai = OrderM2MainBase:AddOpAI('BasicLandAttack', 'M2_LandAttack_Aeon_1_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M2_Oder_LandAttack_Aeon_Chain',
                },
                Priority = 110,
            }
        )
        opai:SetChildQuantity('SiegeBots', quantity[Difficulty])
        opai:SetFormation('AttackFormation')
        opai:AddBuildCondition('/lua/editor/BaseManagerBuildConditions.lua', 'BaseActive', {'M3_Aeon_Base'})
    end

    for i = 1, 2 do
        quantity = {14, 12, 10}
        opai = OrderM2MainBase:AddOpAI('BasicLandAttack', 'M2_LandAmph_Ataack_1_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M2_Order_Amph_Chain',
                },
                Priority = 110,
            }
        )
        opai:SetChildQuantity('AmphibiousTanks', quantity[Difficulty])
        opai:SetFormation('AttackFormation')
        --opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua', 'HaveLessThanUnitsWithCategoryInArea',
            --{'default_brain', 5, categories.NAVAL * categories.MOBILE * categories.TECH2, 'M2_Order_Naval_Area'})
    end


    -- Defense
    for i = 1, 3 do
        quantity = {4, 3, 2}
        opai = OrderM2MainBase:AddOpAI('BasicLandAttack', 'M2_Order_LandDef_1_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M2_Order_LandDef_Chain_' .. i,
                },
                Priority = 190,
            }
        )
        opai:SetChildQuantity('HeavyMobileAntiAir', quantity[Difficulty])
    end

    for i = 1, 3 do
        quantity = {6, 5, 4}
        opai = OrderM2MainBase:AddOpAI('BasicLandAttack', 'M2_Order_LandDef_2_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M2_Order_LandDef_Chain_' .. i,
                },
                Priority = 200,
            }
        )
        opai:SetChildQuantity('SiegeBots', quantity[Difficulty])
    end
end

function M3OrderExperimentals()
    -- GCs
    local quantity = {3, 3, 2}
    local numEngies = {3, 3, 4}
    local opai = OrderM2MainBase:AddOpAI('M3_Order_Defensive_GC',
        {
            Amount = quantity[Difficulty],
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Order_Main_Base_Exp_Patrol_Chain',
            },
            MaxAssist = numEngies[Difficulty],
            Retry = true,
        }
    )
end

----------------------
-- Order M3 Naval Base
----------------------
function OrderM2NavalBaseAI()
    OrderM2NavalBase:InitializeDifficultyTables(ArmyBrains[Order], 'M2_Order_Naval_Base', 'M2_Naval_Base_Marker', 50, {M2_Naval_Base = 100})
    OrderM2NavalBase:StartNonZeroBase({{4, 5, 6}, {3, 4, 5}})

    OrderM2NavalBaseNavalAttacks()
end

function OrderM2NavalBaseNavalAttacks()
    local opai = nil
    local trigger = {}

    opai = OrderM2NavalBase:AddNavalAI('M2_NavalAttack1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Order_Naval_Attack_Chain_1',
            },
            EnabledTypes = {'Submarine'},
            MaxFrigates = 10,
            MinFrigates = 10,
            Priority = 100,
        }
    )
    opai:SetChildActive('T2', false)
    opai:SetChildActive('T3', false)
    opai:SetFormation('AttackFormation')
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainGreaterThanOrEqualNumCategory', {'default_brain', 'UEF', 5, categories.NAVAL})

    opai = OrderM2NavalBase:AddNavalAI('M2_NavalAttack2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Order_Naval_Attack_Chain_1',
            },
            EnabledTypes = {'Destroyer', 'Cruiser'},
            MaxFrigates = 15,
            MinFrigates = 15,
            Priority = 110,
        }
    )
    opai:SetChildActive('T3', false)
    opai:SetFormation('AttackFormation')
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainGreaterThanOrEqualNumCategory', {'default_brain', 'UEF', 5, (categories.NAVAL * categories.MOBILE) - categories.TECH1})

    opai = OrderM2NavalBase:AddNavalAI('M2_NavalAttack3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Order_Naval_Attack_Chain_1',
            },
            EnabledTypes = {'Destroyer', 'Cruiser'},
            MaxFrigates = 19,
            MinFrigates = 19,
            Priority = 120,
        }
    )
    opai:SetChildActive('T3', false)
    opai:SetFormation('AttackFormation')
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainGreaterThanOrEqualNumCategory', {'default_brain', 'UEF', 10, (categories.NAVAL * categories.MOBILE) - categories.TECH1})

    opai = OrderM2NavalBase:AddNavalAI('M2_NavalAttack4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Order_Naval_Attack_Chain_1',
            },
            EnabledTypes = {'Battleship'},
            MaxFrigates = 75,
            MinFrigates = 75,
            Priority = 130,
        }
    )
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainGreaterThanOrEqualNumCategory', {'default_brain', 'UEF', 3, categories.BATTLESHIP})

    -- Naval Defense
    opai = OrderM2NavalBase:AddNavalAI('M2_Order_NavalDefense_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Order_Naval_Defense_Chain',
            },
            EnabledTypes = {'Destroyer', 'Cruiser'},
            MaxFrigates = 20,
            MinFrigates = 20,
            Priority = 200,
            Overrides = {
                CORE_TO_CRUISERS = 2,
            }
        }
    )
    opai:SetChildActive('T1', false)
    opai:SetChildActive('T3', false)
    opai:SetLockingStyle('DeathRatio', {Ratio = .5})

    -- Sonar
    opai = OrderM2NavalBase:AddOpAI('Order_T3_Sonar',
        {
            Amount = 1,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Order_Sonar_Chain_1',
            },
            MaxAssist = 1,
            Retry = true,
        }
    )
end

--------------------------
-- Order M2 Expansion Base
--------------------------
function OrderM2ExpansionBaseAI()
    OrderM2MainBase:AddExpansionBase('OrderM2ExpansionBase', 1)
    OrderM2ExpansionBase:InitializeDifficultyTables(ArmyBrains[Order], 'OrderM2ExpansionBase', 'Order_M2_Expansion_One_Marker', 50,
        {
           M2_EOne_First = 100,
           M2_EOne_Second = 90,
           M2_EOne_Third = 80,
        }
    )
    OrderM2ExpansionBase:StartDifficultyBase({'M2_EOne_First'}, 3)
    OrderM2ExpansionBase:AddBuildGroup('M2_Main_Adapt_Lines', 70, true)
end

-----------
-- Carriers
-----------
function M2OrderCarriers()
    for i = 1, 4 - Difficulty do
        ArmyBrains[Order]:PBMAddBuildLocation('M2_Order_AirCraft_Carrier_Marker_' .. i, 40, 'AircraftCarrier' .. i)
    end

    local Temp = {
        'M2_Order_Carrier_1',
        'NoPlan',
        { 'uas0303', 1, 4 - Difficulty, 'Attack', 'AttackFormation' },  -- Carrier
    }
    local Builder = {
        BuilderName = 'M2_Order_Carrier_Builder_1',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 500,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'M2_Order_Naval_Base',
        BuildConditions = {
            { '/lua/editor/BaseManagerBuildConditions.lua', 'BaseActive', {'M2_Order_Naval_Base'} },
        },
        PlatoonAIFunction = {CustomFunctions, 'CarrierAI'},       
        PlatoonData = {
            MoveChain = 'M2_Order_Carrier_Chain',
            Location = 'AircraftCarrier',
        },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )

    quantity = {12, 10, 8}
    trigger = {15, 20, 25}
    Temp = {
        'M2_Order_Carrier1_Air_Attack_1',
        'NoPlan',
        { 'uaa0204', 1, quantity[Difficulty], 'Attack', 'AttackFormation' }, -- T2 Torp Bomber
    }
    Builder = {
        BuilderName = 'M2_Order_Carrier1_Air_Builder_1',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 110,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'AircraftCarrier1',
        BuildConditions = {
            { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
                {'default_brain', 'UEF', trigger[Difficulty], categories.NAVAL * categories.MOBILE}},
            { '/lua/editor/BaseManagerBuildConditions.lua', 'BaseActive', {'M2_Order_Naval_Base'} },
        },
        PlatoonAIFunction = {CustomFunctions, 'PatrolThread'},       
        PlatoonData = {
            PatrolChain = 'M2_Order_Naval_Attack_Chain_1',
        },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )

    quantity = {7, 6, 5}
    Temp = {
        'M2_Order_Carrier1_Air_Attack_2',
        'NoPlan',
        { 'xaa0305', 1, quantity[Difficulty], 'Attack', 'AttackFormation' }, -- Restorer
    }
    Builder = {
        BuilderName = 'M2_Order_Carrier1_Air_Builder_2',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'AircraftCarrier1',
        PlatoonAIFunction = {CustomFunctions, 'PatrolThread'},       
        PlatoonData = {
            PatrolChain = 'M2_Order_Naval_Attack_Chain_1',
        },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )


    if Difficulty <= 2 then
        quantity = {7, 6}
        trigger = {20, 25}
        Temp = {
            'M2_Order_Carrier2_Air_Attack_1',
            'NoPlan',
            { 'uaa0303', 1, quantity[Difficulty], 'Attack', 'AttackFormation' }, -- ASF
        }
        Builder = {
            BuilderName = 'M2_Order_Carrier2_Air_Builder_1',
            PlatoonTemplate = Temp,
            InstanceCount = 1,
            Priority = 100,
            PlatoonType = 'Air',
            RequiresConstruction = true,
            LocationType = 'AircraftCarrier2',
            BuildConditions = {
                { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
                    {'default_brain', 'UEF', trigger[Difficulty], categories.AIR * categories.MOBILE * categories.TECH3}},
                { '/lua/editor/BaseManagerBuildConditions.lua', 'BaseActive', {'M2_Order_Naval_Base'} },
            },
            PlatoonAIFunction = {CustomFunctions, 'PatrolThread'},       
            PlatoonData = {
                PatrolChain = 'M2_Order_Naval_Attack_Chain_1',
            },
        }
        ArmyBrains[Order]:PBMAddPlatoon( Builder )

        Builder = {
            BuilderName = 'M2_Order_Carrier2_Air_Builder_2',
            PlatoonTemplate = Temp,
            InstanceCount = 1,
            Priority = 110,
            PlatoonType = 'Air',
            RequiresConstruction = true,
            LocationType = 'AircraftCarrier2',
            BuildConditions = {
                { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
                    {'default_brain', 'Cybran', trigger[Difficulty], categories.AIR * categories.MOBILE * categories.TECH3}},
                { '/lua/editor/BaseManagerBuildConditions.lua', 'BaseActive', {'M2_Order_Naval_Base'} },
            },
            PlatoonAIFunction = {CustomFunctions, 'PatrolThread'},       
            PlatoonData = {
                PatrolChain = 'M2_Order_Carrier_Attack_Cybran_Chain',
            },
        }
        ArmyBrains[Order]:PBMAddPlatoon( Builder )
    end

    if Difficulty == 1 then
        Temp = {
            'M2_Order_Carrier3_Air_Attack_1',
            'NoPlan',
            { 'xaa0305', 1, 6, 'Attack', 'AttackFormation' }, -- Restorer
        }
        Builder = {
            BuilderName = 'M2_Order_Carrier3_Air_Builder_1',
            PlatoonTemplate = Temp,
            InstanceCount = 2,
            Priority = 110,
            PlatoonType = 'Air',
            RequiresConstruction = true,
            LocationType = 'AircraftCarrier3',
            BuildConditions = {
                { '/lua/editor/BaseManagerBuildConditions.lua', 'BaseActive', {'M2_Order_Naval_Base'} },
            },
            PlatoonAIFunction = {CustomFunctions, 'PatrolThread'},       
            PlatoonData = {
                PatrolChain = 'M2_Order_Carrier_Attack_Cybran_Chain',
            },
        }
        ArmyBrains[Order]:PBMAddPlatoon( Builder )
    end
end

function DisableBase()
    if(OrderM2MainBase) then
        LOG('OrderM2MainBase stopped')
        OrderM2MainBase:BaseActive(false)
    end
    if(OrderM2NavalBase) then
        LOG('OrderM2NavalBase stopped')
        OrderM2NavalBase:BaseActive(false)
    end
    if(OrderM2ExpansionBase) then
        LOG('OrderM2ExpansionBase stopped')
        OrderM2ExpansionBase:BaseActive(false)
    end
    for _, platoon in ArmyBrains[Order]:GetPlatoonsList() do
        platoon:Stop()
        ArmyBrains[Order]:DisbandPlatoon(platoon)
    end
    LOG('All Platoons of Order stopped')
end