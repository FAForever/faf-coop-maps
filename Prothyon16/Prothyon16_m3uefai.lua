local BaseManager = import('/lua/ai/opai/basemanager.lua')
local CustomFunctions = '/maps/Prothyon16/Prothyon16_CustomFunctions.lua'
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'

ScenarioInfo.Player = 1

---------
-- Locals
---------
local UEF = 2
local Player = ScenarioInfo.Player
local Difficulty = ScenarioInfo.Options.Difficulty

----------------
-- Base Managers
----------------
local UEFM3AirBase = BaseManager.CreateBaseManager()
local UEFM3SouthNavalBase = BaseManager.CreateBaseManager()
local UEFM3WestNavalBase = BaseManager.CreateBaseManager()

------------------
-- UEF M3 Air Base
------------------
function UEFM3AirBaseAI()
    UEFM3AirBase:InitializeDifficultyTables(ArmyBrains[UEF], 'M3_Air_Base', 'M3_Air_Base_Marker', 60, {M3_Air_Base = 100})
    UEFM3AirBase:StartNonZeroBase({{14, 22, 30}, {12, 19, 26}})
    UEFM3AirBase:SetActive('AirScouting', true)

    local opai = UEFM3AirBase:AddReactiveAI('MassedAir', 'AirRetaliation', 'UEFM3AirBase_MassedAir')
    opai:SetChildActive('AirSuperiority', false)
    -- opai:SetChildActive('CombatFighters', false)

    UEFM3AirBaseAirAttacks()
    UEFM3AirBaseLandAttacks()
end

function UEFM3AirBaseAirAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    -- Transport Builder
    opai = UEFM3AirBase:AddOpAI('EngineerAttack', 'M3_UEF_TransportBuilder',
    {
        MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
        PlatoonData = {
            TransportReturn = 'M3_UEF_Base_Marker',
        },
        Priority = 1000,
    })
    opai:SetChildQuantity('T2Transports', 4)
    opai:SetLockingStyle('None')
    opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
        'HaveLessThanUnitsWithCategory', {'default_brain', 5, categories.uea0104})

    -- Builds platoon of 8 Bombers
    quantity = {4, 6, 8}
    opai = UEFM3AirBase:AddOpAI('AirAttacks', 'M3_AirAttack4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Air_Attack_Chain1',
                                'M3_Air_Attack_Chain2',
                                'M3_Air_Attack_Chain3',
                                'M3_Air_Attack_Chain4',
                                'M3_Air_Attack_Chain5',
                                'M3_Air_Attack_Chain6',
                                'M3_Air_Attack_Chain7'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Bombers', quantity[Difficulty])

    -- Builds platoon of 8 Gunships
    quantity = {4, 6, 8}
    opai = UEFM3AirBase:AddOpAI('AirAttacks', 'M3_AirAttack19',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Air_Attack_Chain1',
                                'M3_Air_Attack_Chain2',
                                'M3_Air_Attack_Chain3',
                                'M3_Air_Attack_Chain4',
                                'M3_Air_Attack_Chain5',
                                'M3_Air_Attack_Chain6',
                                'M3_Air_Attack_Chain7'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])

    -- sends 10 [bombers] if player has >= 5 AA
    quantity = {6, 8, 10}
    trigger = {12, 8, 5}
    opai = UEFM3AirBase:AddOpAI('AirAttacks', 'M3_AirAttack18',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Air_Attack_Chain1',
                                'M3_Air_Attack_Chain2',
                                'M3_Air_Attack_Chain3',
                                'M3_Air_Attack_Chain4',
                                'M3_Air_Attack_Chain5',
                                'M3_Air_Attack_Chain6',
                                'M3_Air_Attack_Chain7'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Bombers', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.ANTIAIR})

    -- sends 12 [bombers] if player has >= 20 land units
    quantity = {6, 8, 10}
    trigger = {40, 30, 20}
    opai = UEFM3AirBase:AddOpAI('AirAttacks', 'M3_AirAttack20',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Air_Attack_Chain1',
                                'M3_Air_Attack_Chain2',
                                'M3_Air_Attack_Chain3',
                                'M3_Air_Attack_Chain4',
                                'M3_Air_Attack_Chain5',
                                'M3_Air_Attack_Chain6',
                                'M3_Air_Attack_Chain7'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Bombers', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.LAND * categories.MOBILE})

    -- sends 10 interceptors
    quantity = {6, 8, 10}
    opai = UEFM3AirBase:AddOpAI('AirAttacks', 'M3_AirAttack16',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Air_Attack_Chain1',
                                'M3_Air_Attack_Chain2',
                                'M3_Air_Attack_Chain3',
                                'M3_Air_Attack_Chain4',
                                'M3_Air_Attack_Chain5',
                                'M3_Air_Attack_Chain6',
                                'M3_Air_Attack_Chain7'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Interceptors', quantity[Difficulty])

    -- sends 10 [bombers interceptors] if player has >= 5 AA + Janus
    quantity = {12, 16, 20}
    trigger = {20, 15, 10}
    opai = UEFM3AirBase:AddOpAI('AirAttacks', 'M3_AirAttack15',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Air_Attack_Chain1',
                                'M3_Air_Attack_Chain2',
                                'M3_Air_Attack_Chain3',
                                'M3_Air_Attack_Chain4',
                                'M3_Air_Attack_Chain5',
                                'M3_Air_Attack_Chain6',
                                'M3_Air_Attack_Chain7'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'Bombers', 'Interceptors'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.ANTIAIR + categories.dea0202})

    -- sends 8 [gunships, interceptors] if player has >= 8 AA + Janus
    quantity = {10, 12, 16}
    trigger = {22, 17, 12}
    opai = UEFM3AirBase:AddOpAI('AirAttacks', 'M3_AirAttack6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Air_Attack_Chain1',
                                'M3_Air_Attack_Chain2',
                                'M3_Air_Attack_Chain3',
                                'M3_Air_Attack_Chain4',
                                'M3_Air_Attack_Chain5',
                                'M3_Air_Attack_Chain6',
                                'M3_Air_Attack_Chain7'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'Gunships', 'CombatFighters'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.ANTIAIR + categories.dea0202})

    -- sends 12 [gunships, interceptors] if player has >= 8 AA
    quantity = {16, 20, 24}
    trigger = {60, 50, 40}
    opai = UEFM3AirBase:AddOpAI('AirAttacks', 'M3_AirAttack17',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Air_Attack_Chain1',
                                'M3_Air_Attack_Chain2',
                                'M3_Air_Attack_Chain3',
                                'M3_Air_Attack_Chain4',
                                'M3_Air_Attack_Chain5',
                                'M3_Air_Attack_Chain6',
                                'M3_Air_Attack_Chain7'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'Gunships', 'CombatFighters'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.ALLUNITS - categories.WALL})

    -- sends 20 [interceptors] if player has >= 10 mobile air
    quantity = {12, 16, 20}
    trigger = {30, 20, 10}
    opai = UEFM3AirBase:AddOpAI('AirAttacks', 'M3_AirAttack7',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Air_Attack_Chain1',
                                'M3_Air_Attack_Chain2',
                                'M3_Air_Attack_Chain3',
                                'M3_Air_Attack_Chain4',
                                'M3_Air_Attack_Chain5',
                                'M3_Air_Attack_Chain6',
                                'M3_Air_Attack_Chain7'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Interceptors', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.MOBILE * categories.AIR})

    -- sends 12 [gunships] if player has >= 10 T2/T3 structures
    quantity = {8, 10, 12}
    trigger = {24, 18, 12}
    opai = UEFM3AirBase:AddOpAI('AirAttacks', 'M3_AirAttack8',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Air_Attack_Chain1',
                                'M3_Air_Attack_Chain2',
                                'M3_Air_Attack_Chain3',
                                'M3_Air_Attack_Chain4',
                                'M3_Air_Attack_Chain5',
                                'M3_Air_Attack_Chain6',
                                'M3_Air_Attack_Chain7'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.TECH2 * categories.MOBILE})

    -- sends 20 [gunships] if player has >= 75, 60, 40 mobile land units
    quantity = {12, 16, 20}
    trigger = {60, 50, 40}
    opai = UEFM3AirBase:AddOpAI('AirAttacks', 'M3_AirAttack9',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Air_Attack_Chain1',
                                'M3_Air_Attack_Chain2',
                                'M3_Air_Attack_Chain3',
                                'M3_Air_Attack_Chain4',
                                'M3_Air_Attack_Chain5',
                                'M3_Air_Attack_Chain6',
                                'M3_Air_Attack_Chain7'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], (categories.MOBILE * categories.LAND) - categories.CONSTRUCTION})

    -- sends 25 [interceptors] if player has >= 50 mobile air units
    quantity = {15, 20, 25}
    trigger = {60, 50, 40}
    opai = UEFM3AirBase:AddOpAI('AirAttacks', 'M3_AirAttack10',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Air_Attack_Chain1',
                                'M3_Air_Attack_Chain2',
                                'M3_Air_Attack_Chain3',
                                'M3_Air_Attack_Chain4',
                                'M3_Air_Attack_Chain5',
                                'M3_Air_Attack_Chain6',
                                'M3_Air_Attack_Chain7'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Interceptors', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.MOBILE * categories.AIR})

    -- sends 10 [interceptors, gunships] if player has >= 20 gunships
    quantity = {6, 8, 10}
    trigger = {30, 25, 20}
    opai = UEFM3AirBase:AddOpAI('AirAttacks', 'M3_AirAttack11',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Air_Attack_Chain1',
                                'M3_Air_Attack_Chain2',
                                'M3_Air_Attack_Chain3',
                                'M3_Air_Attack_Chain4',
                                'M3_Air_Attack_Chain5',
                                'M3_Air_Attack_Chain6',
                                'M3_Air_Attack_Chain7'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('CombatFighters', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.uea0203})

    -- sends 30 [interceptors,] if player has >= 25 air units
    quantity = {20, 25, 30}
    trigger = {45, 37, 30}
    opai = UEFM3AirBase:AddOpAI('AirAttacks', 'M3_AirAttack12',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Air_Attack_Chain1',
                                'M3_Air_Attack_Chain2',
                                'M3_Air_Attack_Chain3',
                                'M3_Air_Attack_Chain4',
                                'M3_Air_Attack_Chain5',
                                'M3_Air_Attack_Chain6',
                                'M3_Air_Attack_Chain7'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Interceptors', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.AIR + categories.MOBILE})

    -- sends 10 [gunships] if player has >= 10 T2 units
    quantity = {6, 8, 10}
    trigger = {20, 15, 10}
    opai = UEFM3AirBase:AddOpAI('AirAttacks', 'M3_AirAttack13',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Air_Attack_Chain1',
                                'M3_Air_Attack_Chain2',
                                'M3_Air_Attack_Chain3',
                                'M3_Air_Attack_Chain4',
                                'M3_Air_Attack_Chain5',
                                'M3_Air_Attack_Chain6',
                                'M3_Air_Attack_Chain7'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.TECH2})

    quantity = {6, 8, 10}
    trigger = {34, 26, 20}
    opai = UEFM3AirBase:AddOpAI('AirAttacks', 'M3_AirAttack14',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Air_Attack_Chain1',
                                'M3_Air_Attack_Chain2',
                                'M3_Air_Attack_Chain3',
                                'M3_Air_Attack_Chain4',
                                'M3_Air_Attack_Chain5',
                                'M3_Air_Attack_Chain6',
                                'M3_Air_Attack_Chain7'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('CombatFighters', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.TECH2})

    -- sends 10 [torpedo bombers] at Player CDR
    --[[ -- much desync maybe
    quantity = {8, 10, 12}
    opai = UEFM3AirBase:AddOpAI('AirAttacks', 'M3_AirAirAttack15',
        {
            MasterPlatoonFunction = {'/maps/Prothyon16/Prothyon16_m3uefai.lua', 'M3AttackCDRWaterAI'},
            Priority = 120,
        }
    )
    opai:SetChildQuantity('TorpedoBombers', quantity[Difficulty])
    opai:AddBuildCondition('/maps/Prothyon16/Prothyon16_m3uefai.lua', 'CDROnWater', {})
    ]]--

    -- Air Defense
    -- Maintains 20 CombatFighters    
    for i = 1, 2 do
        quantity = {6, 8, 10}
        opai = UEFM3AirBase:AddOpAI('AirAttacks', 'M3_AirDefense1_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M3_Air_Base_Defense_Chain',
                },
                Priority = 200,
            }
        )
        opai:SetChildQuantity('CombatFighters', quantity[Difficulty])
        opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    end

    -- Maintains 20 Gunships
    for i = 1, 2 do
        quantity = {6, 8, 10}
        opai = UEFM3AirBase:AddOpAI('AirAttacks', 'M3_AirDefense2_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M3_Air_Base_Defense_Chain',
                },
                Priority = 200,
            }
        )
        opai:SetChildQuantity('Gunships', quantity[Difficulty])
        opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    end
end

function UEFM3AirBaseLandAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    -- sends 20 [hover tanks] if player has >=  50 units
    quantity = {12, 16, 20}
    trigger = {70, 60, 50}
    opai = UEFM3AirBase:AddOpAI('BasicLandAttack', 'M3_HoverAttack1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Air_Hover_Chain1', 'M3_Air_Hover_Chain2'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('AmphibiousTanks', quantity[Difficulty])
    opai:SetLockingStyle('None')
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.ALLUNITS - categories.WALL}) 

    -- sends 10 [hover tanks] if player has >=  25 units
    quantity = {8, 8, 10}
    trigger = {35, 28, 20}
    opai = UEFM3AirBase:AddOpAI('BasicLandAttack', 'M3_HoverAttack2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Air_Hover_Chain1', 'M3_Air_Hover_Chain2'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('AmphibiousTanks', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.ALLUNITS - categories.WALL})
    opai:SetLockingStyle('None')

    -- Drops
    for i = 1, 3 do
        opai = UEFM3AirBase:AddOpAI('BasicLandAttack', 'M3_UEFTransportAttack1_' .. i,
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain = 'M3_Init_TransAttack_Chain1',
                LandingChain = 'M3_Init_Landing_Chain',
                TransportReturn = 'M3_Air_Base_Marker',
            },
            Priority = 110,
        })
        opai:SetChildQuantity('HeavyTanks', 6)
        opai:SetLockingStyle('BuildTimer', {LockTimer = 300})
        opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
            'HaveGreaterThanUnitsWithCategory', {'default_brain', 1, categories.uea0104})
    end

    for i = 1, 2 do
        opai = UEFM3AirBase:AddOpAI('BasicLandAttack', 'M3_UEFTransportAttack2_' .. i,
        {
            MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain = 'M3_Init_TransAttack_Chain1',
                LandingChain = 'M3_Init_Landing_Chain',
                TransportReturn = 'M3_Air_Base_Marker',
            },
            Priority = 110,
        })
        opai:SetChildQuantity('LightArtillery', 14)
        opai:SetLockingStyle('BuildTimer', {LockTimer = 300})
        opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
            'HaveGreaterThanUnitsWithCategory', {'default_brain', 1, categories.uea0104})
    end

    if (Difficulty == 3) then
        for i = 1, 2 do
            opai = UEFM3AirBase:AddOpAI('BasicLandAttack', 'M3_UEFTransportAttack3_' .. i,
            {
                MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
                PlatoonData = {
                    AttackChain = 'M3_UEF_Transport_Attack_Chain',
                    LandingChain = 'M3_UEF_Landing_Chain' .. i,
                    MovePath = 'M3_UEF_Transport_Route_Chain' .. i,
                    TransportReturn = 'M3_Air_Base_Marker',
                },
                Priority = 110,
            })
            opai:SetChildQuantity('HeavyTanks', 6)
            opai:SetLockingStyle('BuildTimer', {LockTimer = 300})
            opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
                'HaveGreaterThanUnitsWithCategory', {'default_brain', 1, categories.uea0104})
        end

        for i = 1, 2 do
            opai = UEFM3AirBase:AddOpAI('BasicLandAttack', 'M3_UEFTransportAttack4_' .. i,
            {
                MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
                PlatoonData = {
                    AttackChain = 'M3_UEF_Transport_Attack_Chain',
                    LandingChain = 'M3_UEF_Landing_Chain' .. i,
                    MovePath = 'M3_UEF_Transport_Route_Chain' .. i,
                    TransportReturn = 'M3_Air_Base_Marker',
                },
                Priority = 110,
            })
            opai:SetChildQuantity('LightArtillery', 14)
            opai:SetLockingStyle('BuildTimer', {LockTimer = 300})
            opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
                'HaveGreaterThanUnitsWithCategory', {'default_brain', 1, categories.uea0104})
        end
    end

    -- Land Defense
    opai = UEFM3AirBase:AddOpAI('BasicLandAttack', 'M3_Air_Base_Land_Defense1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Air_Base_Land_Defence_Chain1', 'M3_Air_Base_Land_Defence_Chain2'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('MobileMissiles', 8)

    quantity = {8, 10, 12}
    opai = UEFM3AirBase:AddOpAI('BasicLandAttack', 'M3_Air_Base_Land_Defense2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Air_Base_Land_Defence_Chain1', 'M3_Air_Base_Land_Defence_Chain2'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('HeavyTanks', quantity[Difficulty])

    opai = UEFM3AirBase:AddOpAI('BasicLandAttack', 'M3_Air_Base_Land_Defense3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Air_Base_Land_Defence_Chain1', 'M3_Air_Base_Land_Defence_Chain2'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('MobileFlak', 8)

    quantity = {10, 14, 16}
    opai = UEFM3AirBase:AddOpAI('BasicLandAttack', 'M3_Air_Base_Land_Defense4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Air_Base_Land_Defence_Chain1', 'M3_Air_Base_Land_Defence_Chain2'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('HeavyTanks', quantity[Difficulty])

    -- Reclaiming engineers
    for i = 1, 2 do
        opai = UEFM3AirBase:AddOpAI('EngineerAttack', 'M3_AirBase_Reclaim_Engineers_1_' .. i,
        {
            MasterPlatoonFunction = {SPAIFileName, 'SplitPatrolThread'},
            PlatoonData = {
                PatrolChains = {'M3_Air_Attack_Chain1',
                                'M3_Air_Attack_Chain2',
                                'M3_Air_Attack_Chain3',
                                'M3_Air_Attack_Chain4',
                                'M3_Air_Attack_Chain5',
                                'M3_Air_Attack_Chain6',
                                'M3_Air_Attack_Chain7'},
            },
            Priority = 100,
        })
        opai:SetChildQuantity('T1Engineers', 10)
        opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    end

    opai = UEFM3AirBase:AddOpAI('EngineerAttack', 'M3_AirBase_Reclaim_Engineers_2',
    {
        MasterPlatoonFunction = {SPAIFileName, 'SplitPatrolThread'},
        PlatoonData = {
            PatrolChains = {'M3_Air_Base_NavalAttack_Chain1',
                            'M3_Air_Base_NavalAttack_Chain2',
                            'M3_Air_Base_NavalAttack_Chain3',
                            'M3_Air_Base_NavalAttack_Chain4'},
        },
        Priority = 100,
    })
    opai:SetChildQuantity('T1Engineers', 10)
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', 1, categories.FACTORY * categories.NAVAL})
end

-------------------
-- Naval Base South
-------------------
function UEFM3SouthNavalBaseAI()
    UEFM3AirBase:AddBuildGroup('SouthNavalBase', 80)
    
    UEFM3SouthNavalBase:Initialize(ArmyBrains[UEF], 'SouthNavalBase', 'M3_South_NavalBase_Marker', 40, {SouthNavalBase = 100,})
    UEFM3SouthNavalBase:StartNonZeroBase({10, 8})
    
    UEFM3SouthNavalAttacks()
end

function UEFM3SouthNavalAttacks()
    local opai = nil
    local trigger = {}

    -- Defense
    -- 2x 2 Destroyers and 1 Cruiser
    for i = 1, 2 do
        opai = UEFM3SouthNavalBase:AddNavalAI('M3_NavalDefense_1_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M3_Air_Base_NavalDef' .. i .. '_Chain',
                },
                Overrides = {
                    CORE_TO_CRUISERS = 2,
                },
                EnabledTypes = {'Destroyer', 'Cruiser'},
                MaxFrigates = 10,
                MinFrigates = 10,
                Priority = 200,
            }
        )
        opai:SetChildActive('T1', false)
        opai:SetChildActive('T3', false)
    end

    -- Attack
    trigger = {28, 22, 16}
    opai = UEFM3SouthNavalBase:AddNavalAI('M2_T2_NavalAttack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Air_Base_NavalAttack_Chain2', 'M3_Air_Base_NavalAttack_Chain4'},
            },
            Overrides = {
                CORE_TO_SUBS = 0.5,
            },
            DisableTypes = {['T2Submarine'] = true},
            EnabledTypes = {'Destroyer', 'Submarine'},
            MaxFrigates = 12,
            MinFrigates = 12,
            Priority = 300,
        }
    )
    opai:SetChildActive('T3', false)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainGreaterThanOrEqualNumCategory', {'default_brain', 'Player', trigger[Difficulty], categories.NAVAL * categories.MOBILE + categories.uel0203})
    
    if (Difficulty == 3) then
        opai = UEFM3SouthNavalBase:AddNavalAI('M2_T2_NavalAttack_2',
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
                PlatoonData = {
                    PatrolChains = {'M3_Air_Base_NavalAttack_Chain2', 'M3_Air_Base_NavalAttack_Chain4'},
                },
                Overrides = {
                    CORE_TO_CRUISERS = 0.5,
                    CORE_TO_UTILITY = 0.5,
                },
                EnabledTypes = {'Destroyer', 'Cruiser', 'Utility'},
                MaxFrigates = 10,
                MinFrigates = 10,
                Priority = 400,
            }
        )
        opai:SetChildActive('T3', false)
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
            {'default_brain', 'Player', 20, categories.NAVAL * categories.MOBILE + categories.uel0203})
    end

    trigger = {50, 40, 30}
    opai = UEFM3SouthNavalBase:AddNavalAI('M2_T2_NavalAttack_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Air_Base_NavalAttack_Chain2', 'M3_Air_Base_NavalAttack_Chain4'},
            },
            Overrides = {
                CORE_TO_CRUISERS = 1,
            },
            EnabledTypes = {'Cruiser', 'Utility'},
            MaxFrigates = 15,
            MinFrigates = 15,
            Priority = 400,
        }
    )
    opai:SetChildActive('T3', false)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.dea0202 + categories.uea0203 + categories.uea0204 + categories.uea0103})
    
    opai = UEFM3SouthNavalBase:AddNavalAI('M2_T2_NavalAttack_4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Air_Base_NavalAttack_Chain2', 'M3_Air_Base_NavalAttack_Chain4'},
            },
            Overrides = {
                CORE_TO_SUBS = 1,
            },
            EnabledTypes = {'Submarine'},
            MaxFrigates = 4,
            MinFrigates = 4,
            Priority = 250,
        }
    )
    opai:SetChildActive('T2', false)
    opai:SetChildActive('T3', false)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', 4, categories.NAVAL * categories.MOBILE + categories.uel0203})
end

------------------
-- Naval Base West
------------------
function UEFM3WestNavalBaseAI()  
    UEFM3AirBase:AddBuildGroup('WestNavalBase', 90)
    
    UEFM3WestNavalBase:Initialize(ArmyBrains[UEF], 'WestNavalBase', 'M3_West_NavalBase_Marker', 40, {WestNavalBase = 100,})
    UEFM3WestNavalBase:StartNonZeroBase({6, 4})
    
    UEFM3WestNavalAttacks()
end

function UEFM3WestNavalAttacks()
    local opai = nil
    local trigger = {}

    -- Attacks
    trigger = {12, 8, 4}
    opai = UEFM3WestNavalBase:AddNavalAI('M2_T2_NavalAttack_1_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Air_Base_NavalAttack_Chain1', 'M3_Air_Base_NavalAttack_Chain3'}
            },
            Overrides = {
                CORE_TO_SUBS = 1,
            },
            EnabledTypes = {'Submarine'},
            MaxFrigates = 4,
            MinFrigates = 4,
            Priority = 250,
        }
    )
    opai:SetChildActive('T2', false)
    opai:SetChildActive('T3', false)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.NAVAL * categories.MOBILE + categories.uel0203})

    trigger = {18, 14, 10}
    opai = UEFM3WestNavalBase:AddNavalAI('M2_T2_NavalAttack_1_4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Air_Base_NavalAttack_Chain1', 'M3_Air_Base_NavalAttack_Chain3'}
            },
            Overrides = {
                CORE_TO_SUBS = 2,
            },
            EnabledTypes = {'Submarine'},
            MaxFrigates = 8,
            MinFrigates = 8,
            Priority = 300,
        }
    )
    opai:SetChildActive('T2', false)
    opai:SetChildActive('T3', false)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.NAVAL * categories.MOBILE + categories.uel0203})

    if (Difficulty == 3) then
        opai = UEFM3WestNavalBase:AddNavalAI('M2_T2_NavalAttack_1_5',
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
                PlatoonData = {
                    PatrolChains = {'M3_Air_Base_NavalAttack_Chain1', 'M3_Air_Base_NavalAttack_Chain3'}
                },
                Overrides = {
                    CORE_TO_SUBS = 2,
                },
                EnabledTypes = {'Submarine'},
                MaxFrigates = 12,
                MinFrigates = 12,
                Priority = 350,
            }
        )
        opai:SetChildActive('T2', false)
        opai:SetChildActive('T3', false)
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
            {'default_brain', 'Player', 20, categories.NAVAL * categories.MOBILE + categories.uel0203})
    end

    -- Defense
    for i = 1, 2 do
        opai = UEFM3WestNavalBase:AddNavalAI('M2_T2_NavalAttack_1_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M3_Air_Base_NavalDef' .. i .. '_Chain',
                },
                Overrides = {
                    CORE_TO_SUBS = 1,
                },
                EnabledTypes = {'Submarine'},
                MaxFrigates = 4,
                MinFrigates = 4,
                Priority = 200,
            }
        )
        opai:SetChildActive('T2', false)
        opai:SetChildActive('T3', false)
    end
end

------------------
-- Custom Fnctions
------------------
function CDROnWater(category)
    local unit = ArmyBrains[Player]:GetListOfUnits(categories.COMMAND, false)
    local result = false

    if(unit[1] and not unit[1]:IsDead() and unit[1]:GetCurrentLayer() == 'Seabed') then
        result = true
    else
        result = false
    end

    return result
end

function M3AttackCDRWaterAI(platoon)
    local unit = ArmyBrains[Player]:GetListOfUnits(categories.COMMAND, false)
    if(unit[1] and not unit[1]:IsDead() and unit[1]:GetCurrentLayer() == 'Seabed') then
        platoon:AttackTarget(unit[1])
    else
        ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_Air_Base_NavalAttack_Chain1')
    end
end