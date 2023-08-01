local BaseManager = import('/lua/ai/opai/basemanager.lua')
local CustomFunctions = '/maps/FAF_Coop_Novax_Station_Assault/FAF_Coop_Novax_Station_Assault_CustomFunctions.lua'
local SPAIFileName = '/lua/ScenarioPlatoonAI.lua'
local ScenarioPlatoonAI = import(SPAIFileName)
local ThisFile = '/maps/FAF_Coop_Novax_Station_Assault/FAF_Coop_Novax_Station_Assault_m2orderai.lua'

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
            M2_Order_Air_Factory_2 = 260,
            M2_Order_Def_1 = 250,
            M2_Order_Mass_3 = 240,
            M2_Order_Factory_3 = 235,
            M2_Order_Mass_4 = 230,
            M2_Order_Energy_1 = 220,
            M2_Order_Factory_4 = 210,
            M2_Order_Energy_2 = 200,
            M2_Order_North = 190,
            M2_Order_Factory_5 = 180,
            M2_Order_Mass_5 = 175,
            M2_Order_Antinuke = 170,
            M2_Order_Main_1 = 160,
            M2_Order_Main_2 = 150,
            M2_Order_Main_3 = 145,
            M2_Order_Def_2 = 140,
            M2_Order_Sonar = 130,
            M2_Order_Torp = 120,
        }
    )
    OrderM2Base:StartEmptyBase({{15, 13, 11}, {10, 8, 6}})
    OrderM2Base:SetMaximumConstructionEngineers(5)
end

function OrderM2BaseEngieCount()
    OrderM2Base:SetEngineerCount({{15, 13, 11}, {13, 11, 9}})
    OrderM2Base:SetMaximumConstructionEngineers(3)
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

    ----------
    -- Defense
    ----------
    -- {12, 9, 9} ASFs
    quantity = {4, 3, 3}
    for i = 1, 3 do
        opai = OrderM2Base:AddOpAI('AirAttacks', 'M2_Order_Base_AirDefense1_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M2_Order_Base_AirDef_Chain',
                },
                Priority = 190 + i * 10,
            }
        )
        opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    end

    -- {8, 8, 6} T3 Torpedo Bombers
    for i = 1, 2 do
        quantity = {4, 4, 3}
        opai = OrderM2Base:AddOpAI('AirAttacks', 'M2_Order_Base_AirDefense2_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M2_Order_Base_AirDef_Chain',
                },
                Priority = 190 + i * 10,
            }
        )
        opai:SetChildQuantity('HeavyTorpedoBombers', quantity[Difficulty])

        -- {8, 8, 6} Restorers
        quantity = {4, 4, 3}
        opai = OrderM2Base:AddOpAI('AirAttacks', 'M2_Order_Base_AirDefense3_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M2_Order_Base_AirDef_Chain',
                },
                Priority = 190 + i * 10,
            }
        )
        opai:SetChildQuantity('HeavyGunships', quantity[Difficulty])
    end

    quantity = {4, 3, 3}
    for i = 1, 2 do
        -- {8, 7, 6} T3 Torpedo Bombers around the whole island
        opai = OrderM2Base:AddOpAI('AirAttacks', 'M2_Order_Base_AirDefense_4_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'SplitPatrolThread'},
                PlatoonData = {
                    PatrolChains = {
                        'M2_Order_Defensive_Chain_Full',
                    },
                },
                Priority = 190,
            }
        )
        opai:SetChildQuantity('HeavyTorpedoBombers', quantity[Difficulty])
    end

    -- {12, 10, 9} ASFs around the whole island
    quantity = {4, 3, 3}
    for i = 1, 3 do
        opai = OrderM2Base:AddOpAI('AirAttacks', 'M2_Order_Base_AirDefense_5_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'SplitPatrolThread'},
                PlatoonData = {
                    PatrolChains = {
                        'M2_Order_Defensive_Chain_Full',
                    },
                },
                Priority = 180,
            }
        )
        opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    end

    -- {6, 4, 3} Restorers around the whole island
    quantity = {6, 4, 3}
    opai = OrderM2Base:AddOpAI('AirAttacks', 'M2_Order_Base_AirDefense_6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'SplitPatrolThread'},
            PlatoonData = {
                PatrolChains = {
                    'M2_Order_Defensive_Chain_Full',
                },
            },
            Priority = 170,
        }
    )
    opai:SetChildQuantity('HeavyGunships', quantity[Difficulty])
end

function OrderM2BaseLandAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    --------------------
    -- Reclaim Engineers
    --------------------
    -- Engineer for reclaiming around the base
    opai = OrderM2Base:AddOpAI('EngineerAttack', 'M2_Order_Reclaim_Engineers_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'SplitPatrolThread'},
            PlatoonData = {
                PatrolChains = {
                    'M2_Order_Base_EngineerChain',
                },
            },
            Priority = 180,
        }
    )
    opai:SetChildQuantity('T1Engineers', 3)

    -- Engineer for reclaiming if there's less than 4000 Mass in the storage
    opai = OrderM2Base:AddOpAI('EngineerAttack', 'M2_Order_Reclaim_Engineers_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'SplitPatrolThread'},
            PlatoonData = {
                PatrolChains = {
                    'M2_Order_Defensive_Chain_Full',
                    'M2_Order_Defensive_Chain_West',
                    'M2_Order_Base_AirDef_Chain',
                    'M2_Order_Reclaim_Chain_North',
                },
            },
            Priority = 190,
        }
    )
    opai:SetChildQuantity('T1Engineers', 6)
    opai:AddBuildCondition(CustomFunctions, 'LessMassStorageCurrent', {'default_brain', 4000})

    -- Engineer for reclaiming if there's less than 2000 Mass in the storage
    opai = OrderM2Base:AddOpAI('EngineerAttack', 'M2_Order_Reclaim_Engineers_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'SplitPatrolThread'},
            PlatoonData = {
                PatrolChains = {
                    'M2_Order_Defensive_Chain_Full',
                    'M2_Order_Defensive_Chain_West',
                    'M2_Order_Base_AirDef_Chain',
                    'M2_Order_Reclaim_Chain_North',
                },
            },
            Priority = 200,
        }
    )
    opai:SetChildQuantity('T1Engineers', 6)
    opai:AddBuildCondition(CustomFunctions, 'LessMassStorageCurrent', {'default_brain', 2000})

    ----------
    -- Defense
    ----------
    -- Amhibious units around the base to distract enemy ships
    for i = 1, 2 do
        quantity = {{7, 2}, {6, 1}, {5, 1}}
        opai = OrderM2Base:AddOpAI('BasicLandAttack', 'M2_Order_Amphibious_Defense_1_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M2_Order_Aphibious_Defense_Chain_' .. i,
                },
                Priority = 150,
            }
        )
        opai:SetChildQuantity({'AmphibiousTanks', 'MobileShields'}, quantity[Difficulty])

        quantity = {{6, 3}, {4, 3}, {4, 2}}
        opai = OrderM2Base:AddOpAI('BasicLandAttack', 'M2_Order_Amphibious_Defense_2_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M2_Order_Aphibious_Defense_Chain_' .. i,
                },
                Priority = 160,
            }
        )
        opai:SetChildQuantity({'AmphibiousTanks', 'MobileFlak'}, quantity[Difficulty])

        quantity = {{8, 2, 2}, {7, 2, 2}, {6, 2, 1}}
        opai = OrderM2Base:AddOpAI('BasicLandAttack', 'M2_Order_Amphibious_Defense_3_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M2_Order_Aphibious_Defense_Chain_' .. i,
                },
                Priority = 170,
            }
        )
        opai:SetChildQuantity({'AmphibiousTanks', 'MobileFlak', 'MobileShields'}, quantity[Difficulty])
    end
end

function OrderM2BaseNavalAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    ----------
    -- Defense
    ----------
    -- 2x 3 Destroyers and 3 frigates
    for i = 1, 2 do
        opai = OrderM2Base:AddOpAI('NavalAttacks', 'M2_Order_NavalDef_1_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M2_Order_Defensive_Chain_West',
                },
                Priority = 200,
            }
        )
        opai:SetChildQuantity({'Destroyers', 'Frigates'}, 6)
    end

    -- 3 T2 subs, Cruisers
    opai = OrderM2Base:AddOpAI('NavalAttacks', 'M2_Order_NavalDef_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Order_Defensive_Chain_West',
            },
            Priority = 190,
        }
    )
    opai:SetChildQuantity({'Cruisers', 'T2Submarines'}, 6)

    -- 3 Destroyers
    opai = OrderM2Base:AddOpAI('NavalAttacks', 'M2_Order_NavalDef_4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Order_Defensive_Chain_Full',
            },
            Priority = 180,
        }
    )
    opai:SetChildQuantity('Destroyers', 3)

    -- 3 T2Submarines
    opai = OrderM2Base:AddOpAI('NavalAttacks', 'M2_Order_NavalDef_5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Order_Defensive_Chain_Full',
            },
            Priority = 170,
        }
    )
    opai:SetChildQuantity('T2Submarines', 3)

    -- 3 Destroyers and Cruisers around the whole island
    opai = OrderM2Base:AddOpAI('NavalAttacks', 'M2_Order_NavalDef_6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Order_Defensive_Chain_Full',
            },
            Priority = 160,
        }
    )
    opai:SetChildQuantity({'Destroyers', 'Cruisers'}, 6)
    opai:SetLockingStyle('DeathRatio', {Ratio = .5})

    -- 3 Battleships, randomly splits them between the west patrol and the patrol around the whole island
    opai = OrderM2Base:AddOpAI('NavalAttacks', 'M2_Order_NavalDef_7',
        {
            MasterPlatoonFunction = {SPAIFileName, 'SplitPatrolThread'},
            PlatoonData = {
                PatrolChains = {
                    'M2_Order_Defensive_Chain_Full',
                    'M2_Order_Defensive_Chain_West',
                },
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity('Battleships', 3)
end

function OrderM2RebuildTempest()
    ForkThread(function()
        -- No need to build units from the Tempest anymore.
        ArmyBrains[Order]:PBMRemoveBuildLocation(nil, 'M2_Tempest1')

        if not ScenarioInfo.M1_Order_Tempest or ScenarioInfo.M1_Order_Tempest.Dead then
            return
        end

        while not ScenarioInfo.M1_Order_Tempest.Dead and ScenarioInfo.M1_Order_Tempest:IsUnitState('Building') do
            WaitSeconds(1)
        end

        if not ScenarioInfo.M1_Order_Tempest.Dead then
            ScenarioInfo.M1_Order_Tempest:Kill()
        end

        -- Wait a bit longer before rebuild on harder difficulty
        local delay = {30, 75, 120}
        local opai = OrderM2Base:AddOpAI('M2_Tempest_1',
            {
                Amount = 1,
                KeepAlive = true,
                PlatoonAIFunction = {ThisFile, 'AddPlatoonToAttackManager'},
                PlatoonData = {
                    PlatoonName = 'M2_Tempest_1',
                },
                MaxAssist = 5,
                Retry = true,
                WaitSecondsAfterDeath = delay[Difficulty],
            }
        )
    end)
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
function OrderM2CarriersAI(unit)
    ArmyBrains[Order]:PBMAddBuildLocation('M2_Order_Carrier_Marker_2', 40, 'M2_Order_Carrier_2')

    if unit and not unit.Dead then
        for num, loc in ArmyBrains[Order].PBM.Locations do
            if loc.LocationType == 'M2_Order_Carrier_2' then
                loc.PrimaryFactories.Air = unit
                OrderM2CarrierAttacks()
                break
            end
        end

        while not unit.Dead do
            if unit:IsIdleState() and unit:GetCargo()[1] then
                IssueClearCommands({unit})
                IssueTransportUnload({unit}, unit:GetPosition())
            end
            WaitSeconds(1)
        end
    end
end

function OrderM2CarrierAttacks()
    local quantity = {}
    --------------------
    -- Carrier's defense
    --------------------
    -- T2 Torpedo Bombers
    quantity = {12, 10, 8}
    ArmyBrains[Order]:PBMAddPlatoon({
        BuilderName = 'M2_Order_Carrier1_Air_Builder_1',
        PlatoonTemplate = {
            'M2_Order_Carrier_2_Air_Attack_1',
            'NoPlan',
            {'uaa0204', 1, quantity[Difficulty], 'Attack', 'AttackFormation'}, -- T2 Torp Bomber
        },
        InstanceCount = 1,
        Priority = 200,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'M2_Order_Carrier_2',
        BuildConditions = {
            { '/lua/editor/BaseManagerBuildConditions.lua', 'BaseActive', {'M2_Order_Base'} },
            { '/lua/editor/MiscBuildConditions.lua', 'MissionNumber', {'default_brain', 2}},
        },
        PlatoonAIFunction = {CustomFunctions, 'PatrolThread'},       
        PlatoonData = {
            PatrolChain = 'M2_Order_Defensive_Chain_West',
        },
    })

    -- T3 Torpedo Bombers
    quantity = {7, 6, 5}
    ArmyBrains[Order]:PBMAddPlatoon({
        BuilderName = 'M2_Order_Carrier1_Air_Builder_2',
        PlatoonTemplate = {
            'M2_Order_Carrier_2_Air_Attack_2',
            'NoPlan',
            {'xaa0306', 1, quantity[Difficulty], 'Attack', 'AttackFormation'}, -- Solace
        },
        InstanceCount = 1,
        Priority = 190,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'M2_Order_Carrier_2',
        BuildConditions = {
            { '/lua/editor/BaseManagerBuildConditions.lua', 'BaseActive', {'M2_Order_Base'} },
            { '/lua/editor/MiscBuildConditions.lua', 'MissionNumber', {'default_brain', 2}},
        },
        PlatoonAIFunction = {CustomFunctions, 'PatrolThread'},       
        PlatoonData = {
            PatrolChain = 'M2_Order_Defensive_Chain_West',
        },
    })

    -- T3 Gunships
    quantity = {7, 6, 5}
    ArmyBrains[Order]:PBMAddPlatoon({
        BuilderName = 'M2_Order_Carrier1_Air_Builder_3',
        PlatoonTemplate = {
            'M2_Order_Carrier_2_Air_Attack_3',
            'NoPlan',
            {'xaa0305', 1, quantity[Difficulty], 'Attack', 'AttackFormation'}, -- Restorer
        },
        InstanceCount = 1,
        Priority = 180,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'M2_Order_Carrier_2',
        BuildConditions = {
            { '/lua/editor/BaseManagerBuildConditions.lua', 'BaseActive', {'M2_Order_Base'} },
            { '/lua/editor/MiscBuildConditions.lua', 'MissionNumber', {'default_brain', 2}},
        },
        PlatoonAIFunction = {CustomFunctions, 'PatrolThread'},       
        PlatoonData = {
            PatrolChain = 'M2_Order_Defensive_Chain_West',
        },
    })

    --------------------
    -- Carrier's attacks
    --------------------
    -- T2 Torpedo Bombers
    quantity = {12, 10, 8}
    ArmyBrains[Order]:PBMAddPlatoon({
        BuilderName = 'M2_Order_Carrier1_Air_Builder_4',
        PlatoonTemplate = {
            'M2_Order_Carrier_2_Air_Attack_4',
            'NoPlan',
            {'uaa0204', 1, quantity[Difficulty], 'Attack', 'AttackFormation'}, -- T2 Torp Bomber
        },
        InstanceCount = 1,
        Priority = 120,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'M2_Order_Carrier_2',
        BuildConditions = {
            { '/lua/editor/BaseManagerBuildConditions.lua', 'BaseActive', {'M2_Order_Base'} },
            { '/lua/editor/unitcountbuildconditions.lua', 'HaveGreaterThanUnitsWithCategory', {'default_brain', 8, categories.TECH3 * categories.STRUCTURE * categories.FACTORY} },
            { '/lua/editor/MiscBuildConditions.lua', 'MissionNumber', {'default_brain', 2}},
        },
        PlatoonAIFunction = {CustomFunctions, 'PatrolThread'},       
        PlatoonData = {
            PatrolChain = 'M2_Order_Naval_Attack_Cybran_Island_Chain',
        },
    })

    -- T3 Gunships
    quantity = {7, 6, 5}
    ArmyBrains[Order]:PBMAddPlatoon({
        BuilderName = 'M2_Order_Carrier1_Air_Builder_5',
        PlatoonTemplate = {
            'M2_Order_Carrier_2_Air_Attack_5',
            'NoPlan',
            {'xaa0305', 1, quantity[Difficulty], 'Attack', 'AttackFormation'}, -- Restorer
        },
        InstanceCount = 1,
        Priority = 110,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'M2_Order_Carrier_2',
        BuildConditions = {
            { '/lua/editor/BaseManagerBuildConditions.lua', 'BaseActive', {'M2_Order_Base'} },
            { '/lua/editor/unitcountbuildconditions.lua', 'HaveGreaterThanUnitsWithCategory', {'default_brain', 8, categories.TECH3 * categories.STRUCTURE * categories.FACTORY} },
            { '/lua/editor/MiscBuildConditions.lua', 'MissionNumber', {'default_brain', 2}},
        },
        PlatoonAIFunction = {CustomFunctions, 'PatrolThread'},       
        PlatoonData = {
            PatrolChain = 'M2_Order_Naval_Attack_Cybran_Island_Chain',
        },
    })

    -- T3 Torpedo Bombers
    quantity = {7, 6, 5}
    ArmyBrains[Order]:PBMAddPlatoon({
        BuilderName = 'M2_Order_Carrier1_Air_Builder_6',
        PlatoonTemplate = {
            'M2_Order_Carrier_2_Air_Attack_6',
            'NoPlan',
            {'xaa0306', 1, quantity[Difficulty], 'Attack', 'AttackFormation'}, -- Solace
        },
        InstanceCount = 1,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'M2_Order_Carrier_2',
        BuildConditions = {
            { '/lua/editor/BaseManagerBuildConditions.lua', 'BaseActive', {'M2_Order_Base'} },
            { '/lua/editor/unitcountbuildconditions.lua', 'HaveGreaterThanUnitsWithCategory', {'default_brain', 8, categories.TECH3 * categories.STRUCTURE * categories.FACTORY} },
            { '/lua/editor/MiscBuildConditions.lua', 'MissionNumber', {'default_brain', 2}},
        },
        PlatoonAIFunction = {CustomFunctions, 'PatrolThread'},       
        PlatoonData = {
            PatrolChain = 'M2_Order_Naval_Attack_Cybran_Island_Chain',
        },
    })
end

----------
-- Tempest
----------
function OrderM2TempestAI(unit)
    ArmyBrains[Order]:PBMAddBuildLocation('M2_Order_Starting_Tempest', 60, 'M2_Tempest1')

    if unit and not unit.Dead then
        for num, loc in ArmyBrains[Order].PBM.Locations do
            if loc.LocationType == 'M2_Tempest1' then
                loc.PrimaryFactories.Sea = unit
                OrderM2TempestAttacks()
                break
            end
        end
    end
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
        ArmyBrains[Order]:PBMAddPlatoon(Builder)
    end

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
    ArmyBrains[Order]:PBMAddPlatoon(Builder)

    Temp = {
        'M2_Order_Tempest_Naval_2',
        'NoPlan',
        { 'uas0201', 1, 2, 'Attack', 'AttackFormation' },  -- Destroyer
    }
    Builder = {
        BuilderName = 'M2_Order_Tempest_Naval_Builder_2',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 105,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'M2_Tempest1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},
        PlatoonData = {
            PatrolChain = 'M2_Order_Defensive_Chain_West',
        },    
    }
    ArmyBrains[Order]:PBMAddPlatoon(Builder)

    Temp = {
        'M2_Order_Tempest_Naval_3',
        'NoPlan',
        { 'xas0204', 1, 2, 'Attack', 'AttackFormation' },  -- Destroyer
    }
    Builder = {
        BuilderName = 'M2_Order_Tempest_Naval_Builder_3',
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
    ArmyBrains[Order]:PBMAddPlatoon(Builder)
end

-------------
-- M3 Attacks
-------------
function OrderM3AirAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    -- Transport builder
    opai = OrderM2Base:AddOpAI('EngineerAttack', 'M3_Order_TransportBuilder',
        {
            MasterPlatoonFunction = {SPAIFileName, 'LandAssaultWithTransports'},
            PlatoonData = {
                TransportReturn = 'M2_Order_Base_Marker',
            },
            Priority = 160,
        }
    )
    opai:SetChildQuantity('T2Transports', 3)
    opai:SetLockingStyle('None')
    opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
        'HaveLessThanUnitsWithCategory', {'default_brain', 3, categories.uaa0104})

    ----------
    -- Attacks
    ----------
    -- Send {8, 6, 5} T3 Torp bombers
    quantity = {8, 6, 5}
    opai = OrderM2Base:AddOpAI('AirAttacks', 'M3_Order_Base_AirAttack_1',
        {
            MasterPlatoonFunction = {ThisFile, 'AddPlatoonToAttackManager'},
            Priority = 150,
        }
    )
    opai:SetChildQuantity('HeavyTorpedoBombers', quantity[Difficulty])

    -- Send {14, 12, 10} T2 Torp bombers
    quantity = {14, 12, 10}
    opai = OrderM2Base:AddOpAI('AirAttacks', 'M3_Order_Base_AirAttack_2',
        {
            MasterPlatoonFunction = {ThisFile, 'AddPlatoonToAttackManager'},
            Priority = 140,
        }
    )
    opai:SetChildQuantity('TorpedoBombers', quantity[Difficulty])

    -- Send {15, 12, 12} ASFs
    quantity = {15, 12, 12}
    opai = OrderM2Base:AddOpAI('AirAttacks', 'M3_Order_Base_AirAttack_3',
        {
            MasterPlatoonFunction = {ThisFile, 'AddPlatoonToAttackManager'},
            Priority = 140,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])

    -- Send {6, 5, 4} Reestorers
    quantity = {6, 5, 4}
    opai = OrderM2Base:AddOpAI('AirAttacks', 'M3_Order_Base_AirAttack_4',
        {
            MasterPlatoonFunction = {ThisFile, 'AddPlatoonToAttackManager'},
            Priority = 130,
        }
    )
    opai:SetChildQuantity('HeavyGunships', quantity[Difficulty])

    -- Send 3 strats
    opai = OrderM2Base:AddOpAI('AirAttacks', 'M3_Order_Base_AirAttack_5',
        {
            MasterPlatoonFunction = {ThisFile, 'AddPlatoonToAttackManager'},
            Priority = 120,
        }
    )
    opai:SetChildQuantity('StratBombers', 3)

    -- Send {14, 12, 10} T2 gunships
    quantity = {14, 12, 10}
    opai = OrderM2Base:AddOpAI('AirAttacks', 'M3_Order_Base_AirAttack_6',
        {
            MasterPlatoonFunction = {ThisFile, 'AddPlatoonToAttackManager'},
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])

    -- CZAR, rebuild faster on easier difficulty
    local delay = {30, 75, 120}
    opai = OrderM2Base:AddOpAI('M3_CZAR',
        {
            Amount = 1,
            KeepAlive = true,
            PlatoonAIFunction = {ThisFile, 'AddPlatoonToAttackManager'},
            PlatoonData = {
                PlatoonName = 'M3_CZAR',
            },
            MaxAssist = 5,
            Retry = true,
            WaitSecondsAfterDeath = delay[Difficulty],
        }
    )
end

function OrderM3LandAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    ----------
    -- Attacks
    ----------
    quantity = {{12, 2, 2}, {10, 2, 2}, {8, 2, 2}}
    opai = OrderM2Base:AddOpAI('BasicLandAttack', 'M3_Order_Amphibious_Attack_1',
        {
            MasterPlatoonFunction = {ThisFile, 'AddPlatoonToAttackManager'},
            Priority = 140,
        }
    )
    opai:SetChildQuantity({'AmphibiousTanks', 'MobileFlak', 'MobileShields'}, quantity[Difficulty])

    quantity = {{14, 2, 3}, {12, 2, 2}, {10, 2, 2}}
    opai = OrderM2Base:AddOpAI('BasicLandAttack', 'M3_Order_Amphibious_Attack_2',
        {
            MasterPlatoonFunction = {ThisFile, 'AddPlatoonToAttackManager'},
            Priority = 130,
        }
    )
    opai:SetChildQuantity({'AmphibiousTanks', 'MobileFlak', 'MobileShields'}, quantity[Difficulty])
    opai:SetFormation('AttackFormation')

    quantity = {{17, 3}, {15, 2}, {13, 2}}
    opai = OrderM2Base:AddOpAI('BasicLandAttack', 'M3_Order_Amphibious_Attack_3',
        {
            MasterPlatoonFunction = {ThisFile, 'AddPlatoonToAttackManager'},
            Priority = 120,
        }
    )
    opai:SetChildQuantity({'LightTanks', 'MobileShields'}, quantity[Difficulty])
    opai:SetFormation('AttackFormation')


    -- GC, rebuild faster on easier difficulty, build only if there's already CZAR and Tempest
    -- local delay = {30, 75, 120}
    -- opai = OrderM2Base:AddOpAI('M3_GC',
    --     {
    --         Amount = 1,
    --         KeepAlive = true,
    --         PlatoonAIFunction = {ThisFile, 'AddPlatoonToAttackManager'},
    --         PlatoonData = {
    --             PlatoonName = 'M3_GC',
    --         },
    --         MaxAssist = 5,
    --         Retry = true,
    --         WaitSecondsAfterDeath = delay[Difficulty],
    --         --BuildCondition = {
    --         --    {'/lua/editor/unitcountbuildconditions.lua', 'HaveEqualToUnitsWithCategory', {'default_brain', 2, categories.EXPERIMENTAL}},
    --         --}
    --     }
    -- )
end

function OrderM3NavalAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    -- 3 Battleships
    opai = OrderM2Base:AddOpAI('NavalAttacks', 'M3_Order_Naval_Attack_1',
        {
            MasterPlatoonFunction = {ThisFile, 'AddPlatoonToAttackManager'},
            Priority = 160,
        }
    )
    opai:SetChildQuantity('Battleships', 3)

    -- 3 Cruisers and T2 Subs
    opai = OrderM2Base:AddOpAI('NavalAttacks', 'M3_Order_Naval_Attack_2',
        {
            MasterPlatoonFunction = {ThisFile, 'AddPlatoonToAttackManager'},
            Priority = 150,
        }
    )
    opai:SetChildQuantity({'Cruisers', 'T2Submarines'}, 6)

    -- 3 Destroyers, Cruisers and T2 Subs
    opai = OrderM2Base:AddOpAI('NavalAttacks', 'M3_Order_Naval_Attack_3',
        {
            MasterPlatoonFunction = {ThisFile, 'AddPlatoonToAttackManager'},
            Priority = 140,
        }
    )
    opai:SetChildQuantity({'Destroyers', 'Cruisers', 'T2Submarines'}, 9)

    -- 3 MissileShips
    opai = OrderM2Base:AddOpAI('NavalAttacks', 'M3_Order_Naval_Attack_4',
        {
            MasterPlatoonFunction = {ThisFile, 'AddPlatoonToAttackManager'},
            Priority = 130,
        }
    )
    opai:SetChildQuantity('MissileShips', 3)

    -- 3 Destroyers, Cruisers and T2 Subs
    opai = OrderM2Base:AddOpAI('NavalAttacks', 'M3_Order_Naval_Attack_5',
        {
            MasterPlatoonFunction = {ThisFile, 'AddPlatoonToAttackManager'},
            Priority = 120,
        }
    )
    opai:SetChildQuantity({'Destroyers', 'Cruisers'}, {5, 1})

    -- 3 Carriers
    opai = OrderM2Base:AddOpAI('NavalAttacks', 'M3_Order_Naval_Attack_6',
        {
            MasterPlatoonFunction = {ThisFile, 'AddPlatoonToAttackManager'},
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Carriers', 3)
end

OrderAttackManager = Class {
    Chains = {
        Cybran_Island = 'M3_Order_Attack_Cybran_Island_Chain',
        Cybran_Main = 'M3_Order_Attack_Cybran_Main_Chain',
        UEF_Island = 'M3_Order_Attack_UEF_Island_Chain',
        UEF_Main = 'M3_Order_Attack_UEF_Main_Chain',
    },
    Platoons = {},
    Target = 'Cybran_Island', -- The default target to attack, can be overwritten later

    AddPlatoon = function(self, platoon)
        table.insert(self.Platoons, platoon)

        platoon:AddDestroyCallback(RemovePlatoonFromAttackManager)
        --LOG('*DEBUG: OrderAttackManager: Adding platoon named: ' .. platoon.PlatoonData.PlatoonName or '"Unknown platoon name"')
        self:AssignOrderToPlatoon(platoon)
    end,

    RemovePlatoon = function(self, platoon)
        --LOG('*DEBUG: OrderAttackManager: Removing platoon named: ' .. platoon.PlatoonData.PlatoonName or '"Unknown platoon name"')
        table.removeByValue(self.Platoons, platoon)
    end,

    SetTarget = function(self, newTarget)
        if self.Target ~= newTarget then
            self.Target = newTarget

            --LOG('*DEBUG: OrderAttackManager: New target set: ' .. self.Target)
            self:ChangePlatoonsOrders()
        else
            --LOG('*DEBUG: OrderAttackManager trying to set a new target: ' .. newTarget .. ' but it is the current target.')
        end
    end,

    AssignOrderToPlatoon = function(self, platoon)
        platoon.PlatoonData.LocationChain = self.Chains[self.Target]
        platoon.PlatoonData.High = true
        --LOG('*DEBUG: OrderAttackManager: Assigning orders to platoon named: ' .. platoon.PlatoonData.PlatoonName or '"Unknown platoon name"' .. ' , PlatoonData: ', repr(platoon.PlatoonData))

        platoon:StopAI()
        platoon:ForkAIThread(ScenarioPlatoonAI.PlatoonAttackLocationList)
    end,

    ChangePlatoonsOrders = function(self)
        for _, v in self.Platoons do
            self:AssignOrderToPlatoon(v)
        end
    end,
}

-- Attack the target based picked by the players
function AddPlatoonToAttackManager(platoon)
    OrderAttackManager:AddPlatoon(platoon)
end

function RemovePlatoonFromAttackManager(brain, platoon)
    OrderAttackManager:RemovePlatoon(platoon)
end

function SetNewTarget(newTarget)
    OrderAttackManager:SetTarget(newTarget)
end