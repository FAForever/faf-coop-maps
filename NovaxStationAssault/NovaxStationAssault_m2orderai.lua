--##########################################################
--#                    Order Base
--##########################################################
--# Available Chain:
--# Air:
--# {'M2_Order_Base_AirDef_Chain'}
--#
--# Naval:
--# 
--# {'M2_Order_Defensive_Chain_Full', 'M2_Order_Defensive_Chain_West'},
--# {'', ''},
--##########################################################
--# Move Positions:
--# Naval:
--# Left, right side
--# {'M2_Carrier_Move_Order_1', 'M2_Carrier_Move_Order_2'},
--##########################################################
--#                  Aeon Naval Unit IDs
--# { 'uas0102', 1, 1, 'Attack', 'AttackFormation' },  -- AA Boat
--# { 'uas0103', 1, 1, 'Attack', 'AttackFormation' },  -- Frigate
--# { 'uas0203', 1, 1, 'Attack', 'AttackFormation' },  -- Submarine
--# { 'uas0201', 1, 1, 'Attack', 'AttackFormation' },  -- Destroyer
--# { 'uas0202', 1, 1, 'Attack', 'AttackFormation' },  -- Cruiser
--# { 'xas0204', 1, 1, 'Attack', 'AttackFormation' },  -- T2 Sub
--# { 'uas0302', 1, 1, 'Attack', 'AttackFormation' },  -- Battleship
--# { 'uas0303', 1, 1, 'Attack', 'AttackFormation' },  -- Carrier
--# { 'uas0304', 1, 1, 'Attack', 'AttackFormation' },  -- Nuke Sub
--# { 'xas0306', 1, 1, 'Attack', 'AttackFormation' },  -- Missile Ship
--##########################################################

local BaseManager = import('/lua/ai/opai/basemanager.lua')
local CustomFunctions = '/maps/NovaxStationAssault/NovaxStationAssault_CustomFunctions.lua'
local SPAIFileName = '/lua/ScenarioPlatoonAI.lua'

---------
-- Locals
---------
local Order = 3
local Difficulty = ScenarioInfo.Options.Difficulty

----------------
-- Base Managers
----------------
local OrderM2Base = BaseManager.CreateBaseManager()

----------------
-- Order M2 Base
----------------
function OrderM2BaseAI()
    OrderM2Base:Initialize(ArmyBrains[Order], 'M2_Order_Base', 'M2_Order_Base_Marker', 80,
        {
            M2_Order_Mass_1 = 290,
            M2_Order_Mass_2 = 280,
            M2_Order_Air_Factory_1 = 270,
            M2_Order_Energy_1 = 260,
            M2_Order_Air_Factory_2 = 250,
            M2_Order_Def_1 = 245,
            M2_Order_Mass_3 = 240,
            M2_Order_Factory_3 = 230,
            M2_Order_Mass_4 = 220,
            M2_Order_Energy_2 = 210,
            M2_Order_Factory_4 = 200,
            M2_Order_North = 190,
            M2_Order_Factory_5 = 180,
            M2_Order_Main_1 = 170,
            M2_Order_Main_2 = 160,
            M2_Order_Main_3 = 150,
            M2_Order_Torp = 140,
            M2_Order_Sonar = 130,
        }
    )
    OrderM2Base:StartEmptyBase({{15, 13, 11}, {9, 7, 5}})
    OrderM2Base:SetMaximumConstructionEngineers(6)
end

function OrderM2BaseEngieCount()
    OrderM2Base:SetEngineerCount({{15, 13, 11}, {13, 11, 9}})
    OrderM2Base:SetMaximumConstructionEngineers(3)
end

function OrderM2BuildAntiNuke()
    LOG('OrderM2Base: Building Antinuke')
    OrderM2Base:AddBuildGroup('M2_Order_Antinuke', 135)
end

-------------------
-- Order M2 Attacks
-------------------
function OrderM2BaseAirAttacks()
    -- Enable air scouting
    OrderM2Base:SetActive('AirScouting', true)

    local opai = nil
    local quantity = {}
    local trigger = {}

    quantity = {15, 12, 12}
    opai = OrderM2Base:AddOpAI('AirAttacks', 'M2_Order_Base_AirAttack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackLocationList'},
            PlatoonData = {
                LocationChain = 'M2_Cybran_Base_AirDeffense_Chain',
                High = true,
            },
            Priority = 90,
        }
    )
    opai:SetChildQuantity({'Bombers', 'Gunships', 'HeavyGunships'}, quantity[Difficulty])
    opai:SetLockingStyle('None')

    -- Air Defense
    for i = 1, 3 do
        quantity = {4, 3, 3}
        opai = OrderM2Base:AddOpAI('AirAttacks', 'M2_Order_Base_AirDefense1_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M2_Order_Base_AirDef_Chain',
                },
                Priority = 90 + i * 10,
            }
        )
        opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
        opai:SetLockingStyle('DeathRatio', {Ratio = .5})
    end

    for i = 1, 2 do
        quantity = {4, 4, 3}
        opai = OrderM2Base:AddOpAI('AirAttacks', 'M2_Order_Base_AirDefense2_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M2_Order_Base_AirDef_Chain',
                },
                Priority = 90 + i * 10,
            }
        )
        opai:SetChildQuantity('HeavyTorpedoBombers', quantity[Difficulty])
        opai:SetLockingStyle('DeathRatio', {Ratio = .5})
    end

    for i = 1, 2 do
        quantity = {4, 4, 3}
        opai = OrderM2Base:AddOpAI('AirAttacks', 'M2_Order_Base_AirDefense3_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M2_Order_Base_AirDef_Chain',
                },
                Priority = 90 + i * 10,
            }
        )
        opai:SetChildQuantity('HeavyGunships', quantity[Difficulty])
        opai:SetLockingStyle('DeathRatio', {Ratio = .5})
    end
end

function OrderM2BaseLandAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}
end

function OrderM2BaseNavalAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    opai = OrderM2Base:AddNavalAI('M2_Order_NavalAttack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PlatoonAttackLocationList'},
            PlatoonData = {
                LocationChain = 'M2_Cybran_Base_AirDeffense_Chain',
                High = true,
            },
            EnabledTypes = {'Destroyer', 'Frigate'},
            MaxFrigates = 18,
            MinFrigates = 18,
            Priority = 90,
        }
    )

    -- Defense
    -- 2x 3 Destroyers and 3 frigates
    for i = 1, 2 do
        opai = OrderM2Base:AddNavalAI('M2_Order_NavalDef_1_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M2_Order_Defensive_Chain_West',
                },
                EnabledTypes = {'Destroyer', 'Frigate'},
                MaxFrigates = 18,
                MinFrigates = 18,
                Priority = 120,
            }
        )
        --opai:SetChildActive('T3', false)
    end

    -- 3 T2 subs, Cruisers
    opai = OrderM2Base:AddNavalAI('M2_Order_NavalDef_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Order_Defensive_Chain_West',
            },
            EnabledTypes = {'Cruiser', 'Submarine'},
            Overrides = {
                CORE_TO_SUBS = 2,
                CORE_TO_CRUISERS = 2,
            },
            MaxFrigates = 30,
            MinFrigates = 30,
            Priority = 110,
        }
    )
    opai:SetChildActive('T3', false)

    opai = OrderM2Base:AddNavalAI('M2_Order_NavalDef_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Order_Defensive_Chain_Full',
            },
            EnabledTypes = {'Battleship'},
            MaxFrigates = 50,
            MinFrigates = 50,
            Priority = 100,
        }
    )
end

function OrderM2RebuildTempest()
    if not ScenarioInfo.M1_Order_Tempest or ScenarioInfo.M1_Order_Tempest:IsDead() then
        return
    end

    while not ScenarioInfo.M1_Order_Tempest:IsDead() and ScenarioInfo.M1_Order_Tempest:IsUnitState('Building') do
        WaitSeconds(1)
    end

    if not ScenarioInfo.M1_Order_Tempest:IsDead() then
        ScenarioInfo.M1_Order_Tempest:Kill()
    end

    local opai = OrderM2Base:AddOpAI('M2_Tempest_1',
        {
            Amount = 1,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'MoveToThread'},
            PlatoonData = {
                MoveRoute = {'M2_Order_Starting_Tempest'},
            },
            MaxAssist = 3,
            Retry = true,
        }
    )
end

function OrderM2RebuildT3Sonar()
    local opai = OrderM2Base:AddOpAI('M2_Order_T3_Sonar',
        {
            Amount = 1,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Order_Defensive_Chain_Full',
            },
            MaxAssist = 1,
            Retry = true,
        }
    )
end

-----------
-- Carriers
-----------
function OrderM2CarriersAI()
    for i = 1, 2 do
        ArmyBrains[Order]:PBMAddBuildLocation('M2_Order_Carrier_Marker_' .. i, 40, 'OrderM2Carrier' .. i)
    end

    -- Build 2 Carriers
    local Temp = {
        'M2_Order_Carrier_1',
        'NoPlan',
        { 'uas0303', 1, 2, 'Attack', 'AttackFormation' },  -- Carrier
    }
    local Builder = {
        BuilderName = 'M2_Order_Carrier_Builder_1',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 500,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'M2_Order_Base',
        BuildConditions = {
            { '/lua/editor/BaseManagerBuildConditions.lua', 'BaseActive', {'M2_Order_Base'} },
        },
        PlatoonAIFunction = {CustomFunctions, 'CarrierAI'},       
        PlatoonData = {
            MoveChain = 'M2_Order_Carrier_Chain',
            Location = 'OrderM2Carrier',
        },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )

    --------------------
    -- Carrier's attacks
    --------------------
    -- Carrier 1
    --
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
        LocationType = 'OrderM2Carrier1',
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

    -- 
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
        LocationType = 'OrderM2Carrier1',
        PlatoonAIFunction = {CustomFunctions, 'PatrolThread'},       
        PlatoonData = {
            PatrolChain = 'M2_Order_Naval_Attack_Chain_1',
        },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )

    -- Carrier 2
    --
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
        LocationType = 'OrderM2Carrier2',
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
        LocationType = 'OrderM2Carrier2',
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

----------
-- Tempest
----------
function OrderM2TempestAI(unit)
    ArmyBrains[Order]:PBMAddBuildLocation('M2_Order_Starting_Tempest', 60, 'M2_Tempest1')

    local location
    for num, loc in ArmyBrains[Order].PBM.Locations do
        if loc.LocationType == 'M2_Tempest1' then
            location = loc
            OrderM2TempestAttacks()
            break
        end
    end
    location.PrimaryFactories.Sea = unit
end

function OrderM2TempestAttacks()
    local Temp = {}
    local Builder = {}

    -- Engineers patrols
    Temp = {
        'M2_Order_Tempest_Engineers_1',
        'NoPlan',
        { 'ual0105', 1, 4, 'Attack', 'AttackFormation' },  -- T1 Engineer
    }
    local Chains = {'M2_Order_Base_EngineerChain', 'M1_UEF_Base_Naval_Patrol_Chain', 'M2_Order_Base_Tempest_Engineers_Chain'}
    for i = 1, 3 do
        Builder = {
            BuilderName = 'M2_Order_Tempest_Engineer_Builder_' .. i,
            PlatoonTemplate = Temp,
            InstanceCount = 1,
            Priority = 200,
            PlatoonType = 'Sea',
            RequiresConstruction = true,
            LocationType = 'M2_Tempest1',
            PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
            PlatoonData = {
                PatrolChain = Chains[i],
            },
        }
        ArmyBrains[Order]:PBMAddPlatoon( Builder )
    end
    --[[
    -- T3 engies to assist naval factory to get faster to T3
    Temp = {
        'M2_Order_Tempest_T3_Engineers_1',
        'NoPlan',
        { 'ual0105', 1, 4, 'Attack', 'AttackFormation' },  -- T3 Engineer
    }
    Builder = {
        BuilderName = 'M2_Order_Tempest_T3_Engineer_Builder_1',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 200,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'M2_Tempest1',
        PlatoonAIFunction = {CustomFunctions, 'AssistNavalFactory'},
        BuildConditions = {
            { '/lua/editor/unitcountbuildconditions.lua', 'HaveMoreThanUnitsWithCategory',
                {'default_brain', 1, categories.NAVAL * categories.FACTORY * categories.STRUCTURE}})
        },
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )
    ]]--
    -- Naval Defense
    Temp = {
        'M2_Order_Tempest_Naval_1',
        'NoPlan',
        { 'uas0103', 1, 8, 'Attack', 'AttackFormation' },  -- Frigate
    }
    Builder = {
        BuilderName = 'M2_Order_Tempest_Naval_Builder_1',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 110,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'M2_Tempest1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},
        PlatoonData = {
            PatrolChain = 'M2_Order_Defensive_Chain_West',
        },    
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )

    Temp = {
        'M2_Order_Tempest_Naval_2',
        'NoPlan',
        { 'uas0201', 1, 2, 'Attack', 'AttackFormation' },  -- Destroyer
    }
    Builder = {
        BuilderName = 'M2_Order_Tempest_Naval_Builder_2',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 100,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'M2_Tempest1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},
        PlatoonData = {
            PatrolChain = 'M2_Order_Defensive_Chain_West',
        },    
    }
    ArmyBrains[Order]:PBMAddPlatoon( Builder )
end