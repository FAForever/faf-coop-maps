local BaseManager = import('/lua/ai/opai/basemanager.lua')

local SPAIFileName = '/lua/scenarioplatoonai.lua'

---------
-- Locals
---------
local UEF = 2
local Difficulty = ScenarioInfo.Options.Difficulty

----------------
-- Base Managers
----------------
local UEFM2MainBase = BaseManager.CreateBaseManager()
local UEFM2FireBaseNorth = BaseManager.CreateBaseManager()
local UEFM2FireBaseSouth = BaseManager.CreateBaseManager()


function UEFM2MainBaseAI()
    --------------------
    -- UEF M2 Main Base
    --------------------
    UEFM2MainBase:InitializeDifficultyTables(ArmyBrains[UEF], 'M2_UEF_Main_Base', 'M2_UEF_Main_Base_Marker', 110, {M2_UEF_Main_Base = 100,})
    UEFM2MainBase:StartNonZeroBase({{8, 10, 14}, {6, 8, 12}})
    UEFM2MainBase:SetActive('AirScouting', true)

    UEFM2MainBase:AddReactiveAI('ExperimentalLand', 'AirRetaliation', 'UEFM2Base_ExperimentalLand')
    local opai = UEFM2MainBase:AddReactiveAI('Nuke', 'AirRetaliation', 'UEFM2Base_Nuke')
    opai:SetChildActive('HeavyGunships', false)
    opai:SetChildActive('Gunships', false)
    opai:SetChildActive('StratBombers', true)
    local opai = UEFM2MainBase:AddReactiveAI('HLRA', 'AirRetaliation', 'UEFM2Base_HLRA')
    opai:SetChildActive('HeavyGunships', false)
    opai:SetChildActive('Gunships', false)
    opai:SetChildActive('StratBombers', true)

    UEFM2MainBaseLandAttacks()
    UEFM2MainBaseAirAttacks()
end

function UEFM2MainBaseLandAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}
    -- M2_UEF_Main_Base_Land_Attack_Chain_1 - 4 (3, 4 for north player)
    -- M2_UEF_Main_Base_Land_Amph_Chain_1 - 2 (2 for north player)
    --{'SiegeBots', 'HeavyBots'}

    -------------
    -- T2 Attacks
    -------------
    --[[
    quantity = {6, 8, 10}
    local Temp = {
        'T2TanksTemp1',
        'NoPlan',
        { 'uel0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   -- T2 Tank
        { 'uel0307', 1, 2, 'Attack', 'GrowthFormation' },   -- T2 Mobile Shield
    }
    local Builder = {
        BuilderName = 'T2TankAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 110,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'M2_UEF_Main_Base',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},       
        PlatoonData = {
                PatrolChains = {'M2_UEF_Main_Base_Land_Attack_Chain_1',
                                'M2_UEF_Main_Base_Land_Attack_Chain_2', 
                                'M2_UEF_Main_Base_Land_Attack_Chain_3',
                                'M2_UEF_Main_Base_Land_Attack_Chain_4'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
    ]]--
    quantity = {7, 9, 11}
    trigger = {40, 30, 20}
    Temp = {
        'T2TanksTemp2',
        'NoPlan',
        { 'uel0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   -- T2 Tank
        { 'uel0307', 1, 4, 'Attack', 'GrowthFormation' },   -- T2 Mobile Shield
    }
    Builder = {
        BuilderName = 'T2TankAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'M2_UEF_Main_Base',
        BuildConditions = {
            { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.LAND * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},       
        PlatoonData = {
                PatrolChains = {'M2_UEF_Main_Base_Land_Attack_Chain_1',
                                'M2_UEF_Main_Base_Land_Attack_Chain_2', 
                                'M2_UEF_Main_Base_Land_Attack_Chain_3',
                                'M2_UEF_Main_Base_Land_Attack_Chain_4'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    -------------
    -- T3 Attacks
    -------------
    for i = 1, 4 do
        quantity = {6, 7, 8}
        trigger = {70, 60, 50}
        opai = UEFM2MainBase:AddOpAI('BasicLandAttack', 'M2_UEF_MainBase_LandAttack1_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                        PatrolChain = 'M2_UEF_Main_Base_Land_Attack_Chain_' .. i,
                },
                Priority = 120,
            }
        )
        opai:SetChildQuantity('SiegeBots', quantity[Difficulty])
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
            {'default_brain', 'Player', trigger[Difficulty], categories.ALLUNITS - categories.WALL})
    end

    for i = 1, 4 do
        quantity = {6, 7, 8}
        trigger = {90, 80, 70}
        opai = UEFM2MainBase:AddOpAI('BasicLandAttack', 'M2_UEF_MainBase_LandAttack2_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                        PatrolChain = 'M2_UEF_Main_Base_Land_Attack_Chain_' .. i,
                },
                Priority = 130,
            }
        )
        if Difficulty > 1 then
            opai:SetChildQuantity({'HeavyBots', 'MobileShields'}, quantity[Difficulty])
        else
            opai:SetChildQuantity('HeavyBots', quantity[Difficulty])
        end
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
            {'default_brain', 'Player', trigger[Difficulty], categories.TECH3})
    end

    for i = 1, 2 do
        quantity = {6, 7, 8}
        trigger = {30, 25, 20}
        opai = UEFM2MainBase:AddOpAI('BasicLandAttack', 'M2_UEF_MainBase_LandAttack3_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
                PlatoonData = {
                    PatrolChains = {'M2_UEF_Main_Base_Land_Amph_Chain_1',
                                    'M2_UEF_Main_Base_Land_Amph_Chain_2'},
                },
                Priority = 130,
            }
        )
        opai:SetChildQuantity('HeavyBots', quantity[Difficulty])
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
            {'default_brain', 'Player', trigger[Difficulty], categories.TECH3})
    end

    for i = 1, 3 do
        quantity = {6, 12, 16}
        trigger = {20, 15, 10}
        opai = UEFM2MainBase:AddOpAI('BasicLandAttack', 'M2_UEF_MainBase_LandAttack4_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
                PlatoonData = {
                        PatrolChains = {'M2_UEF_Main_Base_Land_Attack_Chain_1',
                                        'M2_UEF_Main_Base_Land_Attack_Chain_2', 
                                        'M2_UEF_Main_Base_Land_Attack_Chain_3',
                                        'M2_UEF_Main_Base_Land_Attack_Chain_4'}
                },
                Priority = 120,
            }
        )
        if Difficulty > 1 then
            opai:SetChildQuantity({'MobileHeavyArtillery', 'MobileShields'}, quantity[Difficulty])
        else
            opai:SetChildQuantity('MobileHeavyArtillery', quantity[Difficulty])
        end
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
            {'default_brain', 'Player', trigger[Difficulty], categories.TECH3 * categories.STRUCTURE})
    end

    for i = 1, 3 do
        quantity = {6, 12, 16}
        trigger = {25, 20, 15}
        opai = UEFM2MainBase:AddOpAI('BasicLandAttack', 'M2_UEF_MainBase_LandAttack5_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
                PlatoonData = {
                        PatrolChains = {'M2_UEF_Main_Base_Land_Attack_Chain_1',
                                        'M2_UEF_Main_Base_Land_Attack_Chain_2', 
                                        'M2_UEF_Main_Base_Land_Attack_Chain_3',
                                        'M2_UEF_Main_Base_Land_Attack_Chain_4'}
                },
                Priority = 120,
            }
        )
        if Difficulty > 1 then
            opai:SetChildQuantity({'MobileMissilePlatforms', 'MobileShields'}, quantity[Difficulty])
        else
            opai:SetChildQuantity('MobileMissilePlatforms', quantity[Difficulty])
        end
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
            {'default_brain', 'Player', trigger[Difficulty], categories.DEFENSE * categories.STRUCTURE})
    end

    -- Fatboy support
    --[[quantity = {7, 9, 11}
    Temp = {
        'T3AATemp1',
        'NoPlan',
        { 'uel0202', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   -- T2 Tank
    }
    Builder = {
        BuilderName = 'T3AABuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'M2_UEF_Main_Base',
        BuildConditions = {
            { '/lua/editor/unitcountbuildconditions.lua',
        'HaveLessThanUnitsWithCategory', {'default_brain', 1, categories.uel0401}},
        },
        PlatoonAIFunction = {'/maps/Colony/colony_m2uefia.lua', 'PlatoonAssistUnit'},
        PlatoonData = {
                Unit = {}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )]]--
end

function UEFM2MainBaseExperimentalAttacks1()
    UEFM2MainBase:SetEngineerCount({{8, 11, 16}, {6, 8, 12}})
    ----------------
    -- Experimentals
    ----------------
    local numEngineers = {2, 3, 4}
    local opai = UEFM2MainBase:AddOpAI('M2_UEF_Fatboy_1',
        {
            Amount = 1,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_UEF_Fatboy_Chain_1',
            },

            MaxAssist = numEngineers[Difficulty],
            Retry = true,
        }
    )
end

function UEFM2MainBaseExperimentalAttacks2()
    local numEngineers = {2, 3, 4}
    local opai = UEFM2MainBase:AddOpAI('M2_UEF_Fatboy_2',
        {
            Amount = 1,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_UEF_Fatboy_Chain_1',
            },
            
            MaxAssist = numEngineers[Difficulty],
            Retry = true,
        }
    )
end

function UEFM2MainBaseAirAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}
    -- M2_UEF_Main_Base_Air_Def_Chain
    -------------
    -- T2 attacks
    -------------
    
    for i = 1, 3 do
        quantity = {6, 8, 10}
        trigger = {90, 80, 70}
        opai = UEFM2MainBase:AddOpAI('AirAttacks', 'M2_UEF_Main_Base_AirAttack_T2_1_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
                PlatoonData = {
                    PatrolChains = {'M2_UEF_Main_Base_Land_Attack_Chain_3',
                                    'M2_UEF_Main_Base_Land_Attack_Chain_4',
                                    'M2_UEF_Main_Base_Land_Amph_Chain_2'},
                },
                Priority = 110,
            }
        )
        opai:SetChildQuantity('Gunships', quantity[Difficulty])
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.ALLUNITS - categories.WALL})
    end

    for i = 1, 3 do
        quantity = {8, 10, 12}
        trigger = {100, 90, 80}
        opai = UEFM2MainBase:AddOpAI('AirAttacks', 'M2_UEF_Main_Base_AirAttack_T2_2_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
                PlatoonData = {
                    PatrolChains = {'M2_UEF_Main_Base_Land_Attack_Chain_3',
                                    'M2_UEF_Main_Base_Land_Attack_Chain_4',
                                    'M2_UEF_Main_Base_Land_Amph_Chain_2'},
                },
                Priority = 110,
            }
        )
        opai:SetChildQuantity('Gunships', quantity[Difficulty])
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.ALLUNITS - categories.WALL})
    end

    for i = 1, 3 do
        quantity = {8, 10, 12}
        trigger = {70, 60, 50}
        opai = UEFM2MainBase:AddOpAI('AirAttacks', 'M2_UEF_Main_Base_AirAttack_T2_3_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
                PlatoonData = {
                    PatrolChains = {'M2_UEF_Main_Base_Land_Attack_Chain_1',
                                    'M2_UEF_Main_Base_Land_Attack_Chain_2', 
                                    'M2_UEF_Main_Base_Land_Amph_Chain_1'},
                },
                Priority = 120,
            }
        )
        opai:SetChildQuantity('Gunships', quantity[Difficulty])
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Coop1', trigger[Difficulty], categories.ALLUNITS - categories.WALL})
    end
    -------------
    -- T3 attacks
    -------------
    for i = 1, 3 do
        quantity = {4, 5, 6}
        trigger = {20, 15, 10}
        opai = UEFM2MainBase:AddOpAI('AirAttacks', 'M2_UEF_Main_Base_AirAttack_1_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
                PlatoonData = {
                    PatrolChains = {'M2_UEF_Main_Base_Land_Attack_Chain_1',
                                    'M2_UEF_Main_Base_Land_Attack_Chain_2', 
                                    'M2_UEF_Main_Base_Land_Attack_Chain_3',
                                    'M2_UEF_Main_Base_Land_Attack_Chain_4',
                                    'M2_UEF_Main_Base_Land_Amph_Chain_1',
                                    'M2_UEF_Main_Base_Land_Amph_Chain_2'},
                },
                Priority = 130,
            }
        )
        opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.AIR * categories.MOBILE * categories.TECH3})
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', 1, categories.AIR * categories.FACTORY * categories.TECH3})
    end

    for i = 1, 2 do
        quantity = {4, 5, 6}
        trigger = {20, 15, 10}
        opai = UEFM2MainBase:AddOpAI('AirAttacks', 'M2_UEF_Main_Base_AirAttack_2_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
                PlatoonData = {
                    PatrolChains = {'M2_UEF_Main_Base_Land_Attack_Chain_1',
                                    'M2_UEF_Main_Base_Land_Attack_Chain_2', 
                                    'M2_UEF_Main_Base_Land_Attack_Chain_3',
                                    'M2_UEF_Main_Base_Land_Attack_Chain_4',
                                    'M2_UEF_Main_Base_Land_Amph_Chain_1',
                                    'M2_UEF_Main_Base_Land_Amph_Chain_2'},
                },
                Priority = 130,
            }
        )
        opai:SetChildQuantity('HeavyGunships', quantity[Difficulty])
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.LAND * categories.MOBILE * categories.TECH3})
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', 1, categories.AIR * categories.FACTORY * categories.TECH3})
    end

    for i = 1, 2 do
        quantity = {2, 2, 3}
        trigger = {30, 25, 20}
        opai = UEFM2MainBase:AddOpAI('AirAttacks', 'M2_UEF_Main_Base_AirAttack_3_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
                PlatoonData = {
                    PatrolChains = {'M2_UEF_Main_Base_Land_Attack_Chain_1',
                                    'M2_UEF_Main_Base_Land_Attack_Chain_2', 
                                    'M2_UEF_Main_Base_Land_Attack_Chain_3',
                                    'M2_UEF_Main_Base_Land_Attack_Chain_4',
                                    'M2_UEF_Main_Base_Land_Amph_Chain_1',
                                    'M2_UEF_Main_Base_Land_Amph_Chain_2'},
                },
                Priority = 130,
            }
        )
        opai:SetChildQuantity('StratBombers', quantity[Difficulty])
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.LAND * categories.MOBILE * categories.TECH3})
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', 1, categories.AIR * categories.FACTORY * categories.TECH3})
    end
    
    --[[ -- no idea what I wanted snipe here :D aka commented out for now
    quantity = {4, 5, 6}
    opai = UEFM2MainBase:AddOpAI('AirAttacks', 'M2_UEF_Main_Base_AirAttack_4',
        {
            MasterPlatoonFunction = { '/lua/ScenarioPlatoonAI.lua', 'CategoryHunterPlatoonAI' },
            PlatoonData = {
                    CategoryList = { categories.ura0304 },
            },
            Priority = 200,
        }
    )
    opai:SetChildQuantity('Interceptors', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', 1, categories.ura0304})
    ]]--
    
    -- Air Defense
    for i = 1, 4 do
        quantity = {4, 5, 6}
        opai = UEFM2MainBase:AddOpAI('AirAttacks', 'M2_UEF_Main_Base_AirDefense1_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M2_UEF_Main_Base_Air_Def_Chain',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
        opai:SetLockingStyle('DeathRatio', {Ratio = .5})
    end
    for i = 1, 3 do
        quantity = {2, 2, 3}
        opai = UEFM2MainBase:AddOpAI('AirAttacks', 'M2_UEF_Main_Base_AirDefense2_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M2_UEF_Main_Base_Air_Def_Chain',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('StratBombers', quantity[Difficulty])
        opai:SetLockingStyle('DeathRatio', {Ratio = .5})
    end
    for i = 1, 3 do
        quantity = {3, 3, 4}
        opai = UEFM2MainBase:AddOpAI('AirAttacks', 'M2_UEF_Main_Base_AirDefense3_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M2_UEF_Main_Base_Air_Def_Chain',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('HeavyGunships', quantity[Difficulty])
        opai:SetLockingStyle('DeathRatio', {Ratio = .5})
    end
end

function UEFM2FireBaseNorthAI()
    -------------------------
    -- UEF M2 North Fire Base
    -------------------------
    UEFM2FireBaseNorth:InitializeDifficultyTables(ArmyBrains[UEF], 'M2_Fire_Base_North', 'M2_Fire_Base_North_Marker', 40, {M2_Fire_Base_North = 100,})
    UEFM2FireBaseNorth:StartNonZeroBase({{3, 3, 4}, {2, 2, 3}})
    UEFM2FireBaseNorth:SetActive('AirScouting', true)

    UEFM2FireBaseNorthAirAttacks()
end

function UEFM2FireBaseNorthAirAttacks()
    -- M2_UEF_North_Base_Air_Attack_Chain_1 - 4 (3, 4 for north player)
    local opai = nil
    local quantity = {}
    local trigger = {}

    quantity = {6, 7, 8}
    opai = UEFM2FireBaseNorth:AddOpAI('AirAttacks', 'M2_UEF_North_Base_AirAttack1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_UEF_North_Base_Air_Attack_Chain_3',
                                'M2_UEF_North_Base_Air_Attack_Chain_4'}
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Bombers', quantity[Difficulty])
    opai:SetLockingStyle('None')

    quantity = {6, 7, 8}
    trigger = {40, 35, 30}
    opai = UEFM2FireBaseNorth:AddOpAI('AirAttacks', 'M2_UEF_North_Base_AirAttack2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_UEF_North_Base_Air_Attack_Chain_1',
                                'M2_UEF_North_Base_Air_Attack_Chain_2'}
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Bombers', quantity[Difficulty])
    opai:SetLockingStyle('None')
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Coop1', trigger[Difficulty], categories.ALLUNITS - categories.WALL})

    for i = 3, 4 do
        quantity = {6, 7, 8}
        trigger = {60, 55, 50}
        opai = UEFM2FireBaseNorth:AddOpAI('AirAttacks', 'M2_UEF_North_Base_AirAttack3_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M2_UEF_North_Base_Air_Attack_Chain_' .. i,
                },
                Priority = 110,
            }
        )
        opai:SetChildQuantity('Gunships', quantity[Difficulty])
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
            {'default_brain', 'Player', trigger[Difficulty], categories.ALLUNITS - categories.WALL})
    end

    for i = 1, 2 do
        quantity = {6, 7, 8}
        trigger = {60, 50, 40}
        opai = UEFM2FireBaseNorth:AddOpAI('AirAttacks', 'M2_UEF_North_Base_AirAttack4_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M2_UEF_North_Base_Air_Attack_Chain_' .. i,
                },
                Priority = 120,
            }
        )
        opai:SetChildQuantity('Gunships', quantity[Difficulty])
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Coop1', trigger[Difficulty], categories.ALLUNITS - categories.WALL})
    end

    for i = 3, 4 do
        quantity = {8, 10, 12}
        trigger = {75, 70, 65}
        opai = UEFM2FireBaseNorth:AddOpAI('AirAttacks', 'M2_UEF_North_Base_AirAttack5_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M2_UEF_North_Base_Air_Attack_Chain_' .. i,
                },
                Priority = 110,
            }
        )
        opai:SetChildQuantity('Gunships', quantity[Difficulty])
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.ALLUNITS - categories.WALL})
    end

    for i = 1, 2 do
        quantity = {8, 10, 12}
        trigger = {70, 60, 50}
        opai = UEFM2FireBaseNorth:AddOpAI('AirAttacks', 'M2_UEF_North_Base_AirAttack6_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M2_UEF_North_Base_Air_Attack_Chain_' .. i,
                },
                Priority = 120,
            }
        )
        opai:SetChildQuantity('Gunships', quantity[Difficulty])
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Coop1', trigger[Difficulty], categories.ALLUNITS - categories.WALL})
    end
end

function UEFM2FireBaseSouthAI()
    -------------------------
    -- UEF M2 South Fire Base
    -------------------------
    UEFM2FireBaseSouth:InitializeDifficultyTables(ArmyBrains[UEF], 'M2_Fire_Base_South', 'M2_Fire_Base_South_Marker', 40, {M2_Fire_Base_South = 100,})
    UEFM2FireBaseSouth:StartNonZeroBase({{3, 3, 4}, {2, 2, 3}})
    UEFM2FireBaseSouth:SetActive('LandScouting', true)

    UEFM2FireBaseSouthLandAttacks()
end

function UEFM2FireBaseSouthLandAttacks()
    -- M2_UEF_South_Base_Land_Attack_Chain_1 - 3 (3 for north player)
    local opai = nil
    local quantity = {}
    local trigger = {}

    quantity = {8, 10, 12}
    trigger = {70, 60, 50}
    opai = UEFM2FireBaseSouth:AddOpAI('BasicLandAttack', 'M2_UEF_SouthBase_LandAttack1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                    PatrolChain = 'M2_UEF_South_Base_Land_Attack_Chain_3',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('HeavyTanks', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.ALLUNITS - categories.WALL})

    for i = 1, 2 do
        quantity = {8, 10, 12}
        trigger = {35, 30, 25}
        opai = UEFM2FireBaseSouth:AddOpAI('BasicLandAttack', 'M2_UEF_SouthBase_LandAttack2_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                        PatrolChain = 'M2_UEF_South_Base_Land_Attack_Chain_' .. i,
                },
                Priority = 110,
            }
        )
        opai:SetChildQuantity('HeavyTanks', quantity[Difficulty])
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
            {'default_brain', 'Coop1', trigger[Difficulty], categories.ALLUNITS - categories.WALL})
    end

    quantity = {8, 10, 12}
    trigger = {85, 75, 65}
    opai = UEFM2FireBaseSouth:AddOpAI('BasicLandAttack', 'M2_UEF_SouthBase_LandAttack3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                    PatrolChain = 'M2_UEF_South_Base_Land_Attack_Chain_3',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('AmphibiousTanks', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.ALLUNITS - categories.WALL})

    for i = 1, 2 do
        quantity = {8, 10, 12}
        trigger = {45, 40, 35}
        opai = UEFM2FireBaseSouth:AddOpAI('BasicLandAttack', 'M2_UEF_SouthBase_LandAttack4_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                        PatrolChain = 'M2_UEF_South_Base_Land_Attack_Chain_' .. i,
                },
                Priority = 110,
            }
        )
        opai:SetChildQuantity('AmphibiousTanks', quantity[Difficulty])
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
            {'default_brain', 'Coop1', trigger[Difficulty], categories.ALLUNITS - categories.WALL})
    end

    quantity = {8, 10, 12}
    trigger = {30, 25, 20}
    opai = UEFM2FireBaseSouth:AddOpAI('BasicLandAttack', 'M2_UEF_SouthBase_LandAttack5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                    PatrolChain = 'M2_UEF_South_Base_Land_Attack_Chain_3',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('MobileMissiles', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.DEFENSE})

    for i = 1, 2 do
        quantity = {8, 10, 12}
        trigger = {30, 25, 20}
        opai = UEFM2FireBaseSouth:AddOpAI('BasicLandAttack', 'M2_UEF_SouthBase_LandAttack6_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                        PatrolChain = 'M2_UEF_South_Base_Land_Attack_Chain_' .. i,
                },
                Priority = 110,
            }
        )
        opai:SetChildQuantity('MobileMissiles', quantity[Difficulty])
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
            {'default_brain', 'Coop1', trigger[Difficulty], categories.DEFENSE})
    end
end
--[[
function PlatoonAssistUnit(platoon)
    platoon:Stop()
    local data = platoon.PlatoonData
    if not data.Unit then
        error('*SCENARIO PLATOON AI ERROR: PlatoonAssistUnit requires a Unit to operate', 2)
    end
    local unit = data.Unit
    if type(unit) == 'string' then
        unit = ScenarioUtils.MarkerToPosition(unit)
    end
    local aiBrain = platoon:GetBrain()
    local cmd = platoon:AggressiveMoveTounit(unit)
    local threat = 0
    while aiBrain:PlatoonExists(platoon) do
        if not platoon:IsCommandsActive(cmd) then
            platoon:Stop()
            cmd = platoon:GuardTarget(unit)
        end
        WaitSeconds(13)
    end
end
]]--