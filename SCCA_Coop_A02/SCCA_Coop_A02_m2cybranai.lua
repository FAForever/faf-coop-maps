local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'

---------
-- Locals
---------
local Cybran = 2
local Difficulty = ScenarioInfo.Options.Difficulty

----------------
-- Base Managers
----------------
local CybranM2NorthBase = BaseManager.CreateBaseManager()
local CybranM2SouthBase = BaseManager.CreateBaseManager()

-----------------------
-- Cybran M2 North Base
-----------------------
function CybranM2NorthBaseAI()
    CybranM2NorthBase:InitializeDifficultyTables(ArmyBrains[Cybran], 'M2_North_Base', 'M2_North_Base_Marker', 60, {M2_North_Base = 100})
    CybranM2NorthBase:StartNonZeroBase({{3, 5, 7}, {3, 4, 5}})
    CybranM2NorthBase:SetActive('AirScouting', true)

    CybranM2NorthBaseAirAttacks()
    CybranM2NorthBaseLandAttacks()
    CybranM2NorthBaseNavalAttacks()
end

function CybranM2NorthBaseAirAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    -- Transport Builder
    opai = CybranM2NorthBase:AddOpAI('EngineerAttack', 'M2_TransportBuilder_North',
    {
        MasterPlatoonFunction = {SPAIFileName, 'LandAssaultWithTransports'},
        PlatoonData = {
            TransportReturn = 'M2_Transport_Return_North',
        },
        Priority = 1000,
    })
    opai:SetChildQuantity('T1Transports', 2)
    opai:SetLockingStyle('None')
    opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
        'HaveLessThanUnitsWithCategory', {'default_brain', 5, categories.ura0107})

    -- Bombers
    quantity = {2, 4, 6}
    opai = CybranM2NorthBase:AddOpAI('AirAttacks', 'M2_North_AirAttack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Attack_Route1',
                                'M1_Attack_Route2',
                                'M1_Attack_Route3'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Bombers', quantity[Difficulty])
    opai:SetLockingStyle('None')

    -- Interceptors
    quantity = {4, 6, 8}
    trigger = {20, 15, 10}
    opai = CybranM2NorthBase:AddOpAI('AirAttacks', 'M2_North_AirAttack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Attack_Route1',
                                'M1_Attack_Route2',
                                'M1_Attack_Route3'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Interceptors', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE, '>='})

    -- Air Defence
    for i = 1, 1 + Difficulty do
        opai = CybranM2NorthBase:AddOpAI('AirAttacks', 'M2_North_AirDefense_1_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M2_Defense_Patrol1',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('Interceptors', 4)
    end

    for i = 1, 2 * Difficulty do
        opai = CybranM2NorthBase:AddOpAI('AirAttacks', 'M2_North_AirDefense_2_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M2_Defense_Patrol1',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('Bombers', 2)
    end
end

function CybranM2NorthBaseLandAttacks()
    local opai = nil
    local trigger = {}
    local quantity = {}

    for i = 1, 2 do
        opai = CybranM2NorthBase:AddOpAI('BasicLandAttack', 'M2_North_TransportAttack_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'LandAssaultWithTransports'},
                PlatoonData = {
                    AttackChain = 'M2_Attack_Route1',
                    LandingChain = 'M2_Landing_Area1',
                    TransportReturn = 'M2_Transport_Return_North',
                },
                Priority = 110,
            }
        )
        opai:SetChildQuantity('HeavyBots', 6)
    end

    opai = CybranM2NorthBase:AddOpAI('BasicLandAttack', 'M2_North_TransportAttack_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain = 'M2_Attack_Route1',
                LandingChain = 'M2_Landing_Area1',
                TransportReturn = 'M2_Transport_Return_North',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('LightArtillery', 6)
    opai:SetLockingStyle('None')
end

function CybranM2NorthBaseNavalAttacks()
    local opai = nil
    local trigger = {}
    local quantity = {}

    -- Early naval attack
    quantity = {2, 3, 4}
    trigger = {7, 5, 3}
    opai = CybranM2NorthBase:AddNavalAI('M2_North_Naval_Attack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_North_Naval_Attack',
            },
            MaxFrigates = quantity[Difficulty],
            MinFrigates = quantity[Difficulty],
            Priority = 100,
        }
    )
    opai:SetChildActive('T2', false)
    opai:SetChildActive('T3', false)
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.6})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE, '>='})

    -- Counters naval
    quantity = {4, 6, 8}
    trigger = {13, 11, 8}
    opai = CybranM2NorthBase:AddNavalAI('M2_North_Naval_Attack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_North_Naval_Attack',
            },
            MaxFrigates = quantity[Difficulty],
            MinFrigates = quantity[Difficulty],
            Priority = 110,
        }
    )
    opai:SetChildActive('T2', false)
    opai:SetChildActive('T3', false)
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.6})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE, '>='})

    -- Counter auroras
    quantity = {4, 6, 8}
    trigger = {70, 60, 50}
    opai = CybranM2NorthBase:AddNavalAI('M2_North_Naval_Attack_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_North_Naval_Attack',
            },
            MaxFrigates = quantity[Difficulty],
            MinFrigates = quantity[Difficulty],
            Priority = 110,
        }
    )
    opai:SetChildActive('T2', false)
    opai:SetChildActive('T3', false)
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.6})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.ual0201, '>='})
end

function EastNavalPatrolRebuild()
    -- North West Patrol
    local quantity = {6, 8, 10}
    local opai = CybranM2NorthBase:AddNavalAI('M2_East_Naval_Patrol',
        {
            MasterPlatoonFunction = {'/maps/SCCA_Coop_A02/SCCA_Coop_A02_script.lua', 'NavalPatrolReinforceAI'},
            PlatoonData = {
                PatrolChain = 'M2_East_Water_Patrol',
                Area = 'M2_South_Defenses',
                Location = 'M2_South_Water_Patrol_04',
            },
            MaxFrigates = quantity[Difficulty],
            MinFrigates = quantity[Difficulty],
            Priority = 100,
        }
    )
    opai:SetChildActive('T2', false)
    opai:SetChildActive('T3', false)
    opai:SetFormation('AttackFormation')
end

-----------------------
-- Cybran M2 South Base
-----------------------
function CybranM2SouthBaseAI()
    CybranM2SouthBase:InitializeDifficultyTables(ArmyBrains[Cybran], 'M2_South_Base', 'M2_South_Base_Marker', 80, {M2_South_Base = 100})
    CybranM2SouthBase:StartNonZeroBase({{3, 4, 5}, {3, 3, 4}})
    CybranM2SouthBase:SetActive('AirScouting', true)

    CybranM2SouthBaseAirDefences()
end

function CybranM2SouthBaseAirDefences()
    local opai = nil
    local trigger = {}
    local quantity = {}

    -- Transport Builder
    opai = CybranM2SouthBase:AddOpAI('EngineerAttack', 'M2_TransportBuilder_South',
    {
        MasterPlatoonFunction = {SPAIFileName, 'LandAssaultWithTransports'},
        PlatoonData = {
            TransportReturn = 'M2_Transport_Return_South',
        },
        Priority = 1000,
    })
    opai:SetChildQuantity('T1Transports', 2)
    opai:SetLockingStyle('None')
    opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
        'HaveLessThanUnitsWithCategory', {'default_brain', 7, categories.ura0107})

    -- Air Defence
    for i = 1, Difficulty do
        opai = CybranM2SouthBase:AddOpAI('AirAttacks', 'M2_South_AirDefense_1_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M2_Defense_Patrol2',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('Interceptors', 4)
    end

    for i = 1, 2 + Difficulty do
        opai = CybranM2SouthBase:AddOpAI('AirAttacks', 'M2_South_AirDefense_2_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M2_Defense_Patrol2',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('Bombers', 2)
    end
end

function CybranM2SouthBaseAirAttacks()
    local opai = nil
    local trigger = {}
    local quantity = {}

    -- Bombers
    quantity = {2, 4, 6}
    opai = CybranM2SouthBase:AddOpAI('AirAttacks', 'M2_South_AirAttack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_South_Air_Attack_Chain_1',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Bombers', quantity[Difficulty])
    opai:SetLockingStyle('None')

    -- Interceptors
    quantity = {4, 6, 8}
    trigger = {20, 15, 10}
    opai = CybranM2SouthBase:AddOpAI('AirAttacks', 'M2_South_AirAttack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_South_Air_Attack_Chain_1',
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Interceptors', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE, '>='})
end

function CybranM2SouthBaseLandAttacks()
    local opai = nil
    local trigger = {}
    local quantity = {}

    opai = CybranM2SouthBase:AddOpAI('BasicLandAttack', 'M2_South_TransportAttack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain = 'M2_Attack_Route1',
                LandingChain = 'M2_Landing_Area2',
                TransportReturn = 'M2_Transport_Return_South',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('HeavyBots', 6)
    opai:SetLockingStyle('None')

    opai = CybranM2SouthBase:AddOpAI('BasicLandAttack', 'M2_South_TransportAttack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain = 'M2_Attack_Route1',
                LandingChain = 'M2_Landing_Area2',
                TransportReturn = 'M2_Transport_Return_South',
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('LightArtillery', 12)
end

function CybranM2SouthBaseNavalAttacks()
    local opai = nil
    local trigger = {}
    local quantity = {}

    -- Attack
    -- Cruiser for objective
	opai = CybranM2SouthBase:AddNavalAI('M2_Cybran_Cruiser_Platoon',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_South_Naval_Attack',
            },
            EnabledTypes = {'Cruiser'},
            MaxFrigates = 20,
            MinFrigates = 20,
            Priority = 500,
        }
    )
    opai:SetChildActive('T1', false)
    opai:SetChildActive('T3', false)
    opai:AddBuildCallback('/maps/SCCA_Coop_A02/SCCA_Coop_A02_script.lua', 'M2CreateCruiserDeathTrigger') -- Make sure the cruiser will get built only once

    -- Counters Players' navy
    quantity = {4, 6, 8}
    trigger = {16, 14, 12}
    opai = CybranM2SouthBase:AddNavalAI('M2_South_Naval_Attack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_South_Naval_Attack',
            },
            MaxFrigates = quantity[Difficulty],
            MinFrigates = quantity[Difficulty],
            Priority = 100,
        }
    )
    opai:SetChildActive('T2', false)
    opai:SetChildActive('T3', false)
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.6})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE, '>='})

    -- Counters auroras
    quantity = {4, 5, 6}
    trigger = {60, 50, 40}
    opai = CybranM2SouthBase:AddNavalAI('M2_South_Naval_Attack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_South_Naval_Attack',
            },
            MaxFrigates = quantity[Difficulty],
            MinFrigates = quantity[Difficulty],
            Priority = 100,
        }
    )
    opai:SetChildActive('T2', false)
    opai:SetChildActive('T3', false)
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.6})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.ual0201, '>='})
end

function SouthNavalPatrolRebuild()
    local quantity = {6, 7, 8}
    local opai = CybranM2SouthBase:AddNavalAI('M2_South_Naval_Patrol',
        {
            MasterPlatoonFunction = {SPAIFileName, 'SplitPatrolThread'},
            PlatoonData = {
                PatrolChains = 'M2_South_Water_Patrol',
            },
            MaxFrigates = quantity[Difficulty],
            MinFrigates = quantity[Difficulty],
            Priority = 110,
        }
    )
    opai:SetChildActive('T2', false)
    opai:SetChildActive('T3', false)
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
end