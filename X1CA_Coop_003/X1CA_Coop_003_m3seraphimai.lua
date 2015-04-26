-- ****************************************************************************
-- **
-- **  File     : /maps/X1CA_Coop_003/X1CA_Coop_003_v02_m3seraphimai.lua
-- **  Author(s): Jessica St. Croix
-- **
-- **  Summary  : Seraphim army AI for Mission 3 - X1CA_Coop_003
-- **
-- **  Copyright © 2007 Gas Powered Games, Inc.  All rights reserved.
-- ****************************************************************************
local BaseManager = import('/lua/ai/opai/basemanager.lua')

local SPAIFileName = '/lua/ScenarioPlatoonAI.lua'

-- ------
-- Locals
-- ------
local Seraphim = 2
local Difficulty = ScenarioInfo.Options.Difficulty

-- -------------
-- Base Managers
-- -------------
local SeraphimM3Mini1 = BaseManager.CreateBaseManager()
local SeraphimM3Mini2 = BaseManager.CreateBaseManager()
local SeraphimM3Mini3 = BaseManager.CreateBaseManager()
local SeraphimM3Mini4 = BaseManager.CreateBaseManager()
local SeraphimM3Mini5 = BaseManager.CreateBaseManager()
local SeraphimM3Mini6 = BaseManager.CreateBaseManager()
local SeraphimM3Mini7 = BaseManager.CreateBaseManager()
local SeraphimM3Mini8 = BaseManager.CreateBaseManager()
local SeraphimM3Mini9 = BaseManager.CreateBaseManager()
local SeraphimM3Mini10 = BaseManager.CreateBaseManager()
local SeraphimM3SouthBase = BaseManager.CreateBaseManager()

function SeraphimM3MiniBasesAI()

    SeraphimM3Mini1:Initialize(ArmyBrains[Seraphim], 'M3_Seraph_Mini_1', 'M3_Seraph_Mini_1_BaseMarker', 10, {M3_Seraph_Mini_1 = 100})
    SeraphimM3Mini1:StartNonZeroBase({{1, 1, 1}, {1, 1, 1}})

    SeraphimM3Mini2:Initialize(ArmyBrains[Seraphim], 'M3_Seraph_Mini_2', 'M3_Seraph_Mini_2_BaseMarker', 10, {M3_Seraph_Mini_2 = 100})
    SeraphimM3Mini2:StartNonZeroBase({{2, 2, 2}, {2, 2, 2}})

    SeraphimM3Mini3:Initialize(ArmyBrains[Seraphim], 'M3_Seraph_Mini_3', 'M3_Seraph_Mini_3_BaseMarker', 10, {M3_Seraph_Mini_3 = 100})
    SeraphimM3Mini3:StartNonZeroBase({{1, 1, 1}, {1, 1, 1}})

    SeraphimM3Mini4:Initialize(ArmyBrains[Seraphim], 'M3_Seraph_Mini_4', 'M3_Seraph_Mini_4_BaseMarker', 10, {M3_Seraph_Mini_4 = 100})
    SeraphimM3Mini4:StartNonZeroBase({{1, 1, 1}, {1, 1, 1}})

    SeraphimM3Mini5:Initialize(ArmyBrains[Seraphim], 'M3_Seraph_Mini_5', 'M3_Seraph_Mini_5_BaseMarker', 10, {M3_Seraph_Mini_5 = 100})
    SeraphimM3Mini5:StartNonZeroBase({{1, 1, 1}, {1, 1, 1}})

    SeraphimM3Mini6:Initialize(ArmyBrains[Seraphim], 'M3_Seraph_Mini_6', 'M3_Seraph_Mini_6_BaseMarker', 10, {M3_Seraph_Mini_6 = 100})
    SeraphimM3Mini6:StartNonZeroBase({{2, 2, 2}, {2, 2, 2}})

    if(Difficulty > 1) then
        SeraphimM3Mini7:Initialize(ArmyBrains[Seraphim], 'M3_Seraph_Mini_7', 'M3_Seraph_Mini_7_BaseMarker', 10, {M3_Seraph_Mini_7 = 100})
        SeraphimM3Mini7:StartNonZeroBase({{1, 1, 1}, {1, 1, 1}})

        SeraphimM3Mini8:Initialize(ArmyBrains[Seraphim], 'M3_Seraph_Mini_8', 'M3_Seraph_Mini_8_BaseMarker', 10, {M3_Seraph_Mini_8 = 100})
        SeraphimM3Mini8:StartNonZeroBase({{1, 1, 1}, {1, 1, 1}})
    end

    if(Difficulty == 3) then
        SeraphimM3Mini9:Initialize(ArmyBrains[Seraphim], 'M3_Seraph_Mini_9', 'M3_Seraph_Mini_9_BaseMarker', 10, {M3_Seraph_Mini_9 = 100})
        SeraphimM3Mini9:StartNonZeroBase({{2, 2, 2}, {2, 2, 2}})

        SeraphimM3Mini10:Initialize(ArmyBrains[Seraphim], 'M3_Seraph_Mini_10', 'M3_Seraph_Mini_10_BaseMarker', 10, {M3_Seraph_Mini_10 = 100})
        SeraphimM3Mini10:StartNonZeroBase({{2, 2, 2}, {2, 2, 2}})
    end

    SeraphimM3MiniD1Attacks()
    if(Difficulty > 1) then
        SeraphimM3MiniD2Attacks()
    end
    if(Difficulty == 3) then
        SeraphimM3MiniD3Attacks()
    end
end

function SeraphimM3MiniD1Attacks()
    local opai = nil

    -- -------------------------
    -- Seraphim M3 Mini D1 Op AI
    -- -------------------------

    opai = SeraphimM3Mini1:AddOpAI('BasicLandAttack', 'M3Mini1_LandAttack',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Seraph_North_LandAttack_1_Chain', 'M3_Seraph_North_LandAttack_2_Chain', 'M3_Seraph_North_LandAttack_3_Chain'},
            },
        }
    )
    opai:SetChildQuantity('HeavyTanks', 4)
    opai:SetLockingStyle('None')

    opai = SeraphimM3Mini2:AddOpAI('BasicLandAttack', 'M3Mini2_LandAttack',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Seraph_North_LandAttack_1_Chain', 'M3_Seraph_North_LandAttack_2_Chain', 'M3_Seraph_North_LandAttack_3_Chain'},
            },
        }
    )
    opai:SetChildQuantity('MobileMissiles', 2)
    opai:SetLockingStyle('None')

    opai = SeraphimM3Mini3:AddOpAI('BasicLandAttack', 'M3Mini3_LandAttack',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Seraph_North_LandAttack_1_Chain', 'M3_Seraph_North_LandAttack_2_Chain', 'M3_Seraph_North_LandAttack_3_Chain'},
            },
        }
    )
    opai:SetChildQuantity('HeavyBots', 1)
    opai:SetLockingStyle('None')

    opai = SeraphimM3Mini3:AddOpAI('AirAttacks', 'M3Mini3_AirAttack',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Seraph_North_AirAttack_Chain',
            },
        }
    )
    opai:SetChildQuantity('Bombers', 3)
    opai:SetLockingStyle('None')

    opai = SeraphimM3Mini4:AddOpAI('BasicLandAttack', 'M3Mini4_LandAttack',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Seraph_North_LandAttack_1_Chain', 'M3_Seraph_North_LandAttack_2_Chain', 'M3_Seraph_North_LandAttack_3_Chain'},
            },
        }
    )
    opai:SetChildQuantity('LightArtillery', 4)
    opai:SetLockingStyle('None')

    opai = SeraphimM3Mini5:AddOpAI('BasicLandAttack', 'M3Mini5_LandAttack',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Seraph_North_LandAttack_1_Chain', 'M3_Seraph_North_LandAttack_2_Chain', 'M3_Seraph_North_LandAttack_3_Chain'},
            },
        }
    )
    opai:SetChildQuantity('AmphibiousTanks', 2)
    opai:SetLockingStyle('None')

    opai = SeraphimM3Mini6:AddOpAI('AirAttacks', 'M3Mini6_AirAttack',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Seraph_North_AirAttack_Chain',
            },
        }
    )
    opai:SetChildQuantity('Gunships', 2)
    opai:SetLockingStyle('None')
end

function SeraphimM3MiniD2Attacks()
    local opai = nil

    -- -------------------------
    -- Seraphim M3 Mini D2 Op AI
    -- -------------------------

    opai = SeraphimM3Mini7:AddOpAI('BasicLandAttack', 'M3Mini7_LandAttack',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Seraph_North_LandAttack_1_Chain', 'M3_Seraph_North_LandAttack_2_Chain', 'M3_Seraph_North_LandAttack_3_Chain'},
            },
        }
    )
    opai:SetChildQuantity('SiegeBots', 1)
    opai:SetLockingStyle('None')

    opai = SeraphimM3Mini8:AddOpAI('BasicLandAttack', 'M3Mini8_LandAttack',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Seraph_North_LandAttack_1_Chain', 'M3_Seraph_North_LandAttack_2_Chain', 'M3_Seraph_North_LandAttack_3_Chain'},
            },
        }
    )
    opai:SetChildQuantity('HeavyTanks', 4)
    opai:SetLockingStyle('None')
end

function SeraphimM3MiniD3Attacks()
    local opai = nil

    -- -------------------------
    -- Seraphim M3 Mini D3 Op AI
    -- -------------------------

    opai = SeraphimM3Mini9:AddOpAI('BasicLandAttack', 'M3Mini9_LandAttack',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Seraph_North_LandAttack_1_Chain', 'M3_Seraph_North_LandAttack_2_Chain', 'M3_Seraph_North_LandAttack_3_Chain'},
            },
        }
    )
    opai:SetChildQuantity('MobileHeavyArtillery', 1)

    opai = SeraphimM3Mini10:AddOpAI('BasicLandAttack', 'M3Mini10_LandAttack',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Seraph_North_LandAttack_1_Chain', 'M3_Seraph_North_LandAttack_2_Chain', 'M3_Seraph_North_LandAttack_3_Chain'},
            },
        }
    )
    opai:SetChildQuantity('SiegeBots', 1)
    opai:SetLockingStyle('None')

    opai = SeraphimM3Mini10:AddOpAI('AirAttacks', 'M3Mini10_AirAttack',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Seraph_North_AirAttack_Chain',
            },
        }
    )
    opai:SetChildQuantity('Gunships', 2)
    opai:SetLockingStyle('None')
end

function SeraphimM3SouthBaseAI()

    -- ----------------------
    -- Seraphim M3 South Base
    -- ----------------------
    SeraphimM3SouthBase:InitializeDifficultyTables(ArmyBrains[Seraphim], 'M3_Seraph_South', 'M3_Seraph_South', 150, {M3_Seraph_South = 100})
    SeraphimM3SouthBase:StartNonZeroBase({{9, 17, 23}, {8, 15, 20}})
    SeraphimM3SouthBase:SetActive('AirScouting', true)
    SeraphimM3SouthBase:SetBuild('Defenses', false)

    SeraphimM3SouthBase:AddReactiveAI('ExperimentalLand', 'AirRetaliation', 'SeraphimM3SouthBase_ExperimentalLand')
    SeraphimM3SouthBase:AddReactiveAI('ExperimentalAir', 'AirRetaliation', 'SeraphimM3SouthBase_ExperimentalAir')
    SeraphimM3SouthBase:AddReactiveAI('ExperimentalNaval', 'AirRetaliation', 'SeraphimM3SouthBase_ExperimentalNaval')
    SeraphimM3SouthBase:AddReactiveAI('Nuke', 'AirRetaliation', 'SeraphimM3SouthBase_Nuke')
    SeraphimM3SouthBase:AddReactiveAI('HLRA', 'AirRetaliation', 'SeraphimM3SouthBase_HLRA')

    SeraphimM3SouthBaseAirAttacks()
    SeraphimM3SouthBaseNavalAttacks()
end

function SeraphimM3SouthBaseAirAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    -- -----------------------------------------
    -- Seraphim M3 South Base Op AI, Air Attacks
    -- -----------------------------------------

    -- sends 14, 21, 28 [bombers]
    quantity = {14, 21, 28}
    opai = SeraphimM3SouthBase:AddOpAI('AirAttacks', 'M3South_AirAttacks1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Seraph_North_AirMain_1_Chain', 'M2_Seraph_North_AirMain_2_Chain', 'M2_Seraph_North_AirMid_Chain', 'M2_Seraph_North_AirNorth_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Bombers', quantity[Difficulty])

    -- sends 7, 14, 21 [interceptors]
    quantity = {7, 14, 21}
    opai = SeraphimM3SouthBase:AddOpAI('AirAttacks', 'M3South_AirAttacks2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Seraph_North_AirMain_1_Chain', 'M2_Seraph_North_AirMain_2_Chain', 'M2_Seraph_North_AirMid_Chain', 'M2_Seraph_North_AirNorth_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Interceptors', quantity[Difficulty])

    -- sends 7, 14, 21 [gunships]
    quantity = {7, 14, 21}
    opai = SeraphimM3SouthBase:AddOpAI('AirAttacks', 'M3South_AirAttacks3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Seraph_North_AirMain_1_Chain', 'M2_Seraph_North_AirMain_2_Chain', 'M2_Seraph_North_AirMid_Chain', 'M2_Seraph_North_AirNorth_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])

    -- sends 14, 20, 28 [gunships, combat fighter] if player has >= 10, 7, 5 T2/T3 AA
    quantity = {14, 20, 28}
    trigger = {10, 7, 5}
    opai = SeraphimM3SouthBase:AddOpAI('AirAttacks', 'M3South_AirAttacks4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Seraph_North_AirMain_1_Chain', 'M2_Seraph_North_AirMain_2_Chain', 'M2_Seraph_North_AirMid_Chain', 'M2_Seraph_North_AirNorth_Chain'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'Gunships', 'CombatFighters'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.ANTIAIR - categories.TECH1})

    -- sends 14, 21, 28 [gunships] if player has >= 100, 80, 60 mobile land
    quantity = {14, 21, 28}
    trigger = {100, 80, 60}
    opai = SeraphimM3SouthBase:AddOpAI('AirAttacks', 'M3South_AirAttacks5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Seraph_North_AirMain_1_Chain', 'M2_Seraph_North_AirMain_2_Chain', 'M2_Seraph_North_AirMid_Chain', 'M2_Seraph_North_AirNorth_Chain'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], (categories.MOBILE * categories.LAND) - categories.CONSTRUCTION})

    -- sends 7, 14, 21 [air superiority] if player has >= 100, 80, 60 mobile air
    quantity = {7, 14, 21}
    trigger = {100, 80, 60}
    opai = SeraphimM3SouthBase:AddOpAI('AirAttacks', 'M3South_AirAttacks6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Seraph_North_AirMain_1_Chain', 'M2_Seraph_North_AirMain_2_Chain', 'M2_Seraph_North_AirMid_Chain', 'M2_Seraph_North_AirNorth_Chain'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.MOBILE * categories.AIR})

    -- sends 7, 14, 21 [air superiority] if player has >= 60, 50, 40 gunships
    quantity = {7, 14, 21}
    trigger = {60, 50, 40}
    opai = SeraphimM3SouthBase:AddOpAI('AirAttacks', 'M3South_AirAttacks7',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Seraph_North_AirMain_1_Chain', 'M2_Seraph_North_AirMain_2_Chain', 'M2_Seraph_North_AirMid_Chain', 'M2_Seraph_North_AirNorth_Chain'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.uaa0203 + categories.uea0203 + categories.ura0203})

    -- sends 7, 7, 14 [torpedo bombers] if player has >= 10, 8, 5 boats
    quantity = {7, 7, 14}
    trigger = {10, 8, 5}
    opai = SeraphimM3SouthBase:AddOpAI('AirAttacks', 'M3South_AirAttacks8',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChains = {'M2_Seraph_North_AirMain_1_Chain', 'M2_Seraph_North_AirMain_2_Chain', 'M2_Seraph_North_AirMid_Chain', 'M2_Seraph_North_AirNorth_Chain'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('TorpedoBombers', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.uaa0203 + categories.uea0203 + categories.ura0203})

    -- sends 6, 14, 20 [combat fighters, gunships] if player has >= 60, 50, 40 T3 units
    quantity = {6, 14, 20}
    trigger = {60, 50, 40}
    opai = SeraphimM3SouthBase:AddOpAI('AirAttacks', 'M3South_AirAttacks9',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Seraph_North_AirMain_1_Chain', 'M2_Seraph_North_AirMain_2_Chain', 'M2_Seraph_North_AirMid_Chain', 'M2_Seraph_North_AirNorth_Chain'},
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity({'CombatFighters', 'Gunships'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainGreaterThanOrEqualNumCategory', {'default_brain', 'Player', trigger[Difficulty], categories.TECH3})

    -- sends 7 [air superiority] if player has >= 1 strat bomber
    opai = SeraphimM3SouthBase:AddOpAI('AirAttacks', 'M3South_AirAttacks10',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Seraph_North_AirMain_1_Chain', 'M2_Seraph_North_AirMain_2_Chain', 'M2_Seraph_North_AirMid_Chain', 'M2_Seraph_North_AirNorth_Chain'},
            },
            Priority = 140,
        }
    )
    opai:SetChildQuantity('AirSuperiority', 7)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainGreaterThanOrEqualNumCategory', {'default_brain', 'Player', 1, categories.uaa0304 + categories.uea0304 + categories.ura0304})

    -- sends 14, 20, 28 [bombers, gunships] if player has >= 350, 400, 450 units
    quantity = {14, 20, 28}
    trigger = {350, 400, 450}
    opai = SeraphimM3SouthBase:AddOpAI('AirAttacks', 'M3South_AirAttacks11',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Seraph_North_AirMain_1_Chain', 'M2_Seraph_North_AirMain_2_Chain', 'M2_Seraph_North_AirMid_Chain', 'M2_Seraph_North_AirNorth_Chain'},
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity({'Bombers', 'Gunships'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainGreaterThanOrEqualNumCategory', {'default_brain', 'Player', trigger[Difficulty], categories.ALLUNITS - categories.WALL})

    -- sends [gunships] at the princess
    opai = SeraphimM3SouthBase:AddOpAI('AirAttacks', 'M3South_AirAttacks12',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Seraph_South_AirAttack_1_Chain', 'M3_Seraph_South_AirAttack_2_Chain'},
            },
            Priority = 200,
        }
    )
    opai:SetChildQuantity('Gunships', 4)

    -- Air Defense
    opai = SeraphimM3SouthBase:AddOpAI('AirAttacks', 'M3South_AirDefense1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Seraph_South_AirDef_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('AirSuperiority', 7)

    opai = SeraphimM3SouthBase:AddOpAI('AirAttacks', 'M3South_AirDefense2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Seraph_South_AirDef_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('TorpedoBombers', 7)
end

function SeraphimM3SouthBaseNavalAttacks()
    local opai = nil
    local trigger = {}

    -- -------------------------------------------
    -- Seraphim M3 South Base Op AI, Naval Attacks
    -- -------------------------------------------

    -- sends 3 frigate power of [frigates]
    opai = SeraphimM3SouthBase:AddNavalAI('M3South_NavalAttack1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Seraph_South_NavalMain_Chain',
            },
            EnableTypes = {'Frigate'},
            MaxFrigates = 3,
            MinFrigates = 3,
            Priority = 100,
        }
    )

    -- sends 6 - 10 frigate power of all but T3
    opai = SeraphimM3SouthBase:AddNavalAI('M3South_NavalAttack2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Seraph_South_NavalMain_Chain',
            },
            MaxFrigates = 10,
            MinFrigates = 6,
            Priority = 100,
        }
    )
    opai:SetChildActive('T3', false)

    -- sends 6 frigate power of [frigates, subs] if player has >= 8, 6, 4 boats
    trigger = {8, 6, 4}
    opai = SeraphimM3SouthBase:AddNavalAI('M3South_NavalAttack3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Seraph_South_NavalMain_Chain',
            },
            EnableTypes = {'Frigate', 'Submarine'},
            MaxFrigates = 6,
            MinFrigates = 6,
            Priority = 110,
        }
    )
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.NAVAL * categories.MOBILE})

    -- sends 9 frigate power of [all but T3] if player has >= 5, 3, 2 T2/T3 boats
    trigger = {5, 3, 2}
    opai = SeraphimM3SouthBase:AddNavalAI('M3South_NavalAttack4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Seraph_South_NavalMain_Chain',
            },
            MaxFrigates = 9,
            MinFrigates = 9,
            Priority = 120,
        }
    )
    opai:SetChildActive('T3', false)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',  'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], (categories.NAVAL * categories.MOBILE) - categories.TECH1})

    -- sends 12 frigate power of [all but T3] if player has >= 6, 5, 4 T2/T3 boats
    trigger = {6, 5, 4}
    opai = SeraphimM3SouthBase:AddNavalAI('M3South_NavalAttack5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Seraph_South_NavalMain_Chain',
            },
            MaxFrigates = 12,
            MinFrigates = 12,
            Priority = 130,
        }
    )
    opai:SetChildActive('T3', false)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], (categories.NAVAL * categories.MOBILE) - categories.TECH1})
		
	-- sends 20 frigate power
	for i = 1, 2 do
    opai = SeraphimM3SouthBase:AddNavalAI('M3South_NavalAttack6' .. i,
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Seraph_South_NavalMain_Chain',
            },
            MaxFrigates = 20,
            MinFrigates = 20,
            Priority = 130,
        }
    )
	end
end

function DisableBase()
    if(SeraphimM3SouthBase) then
        SeraphimM3SouthBase:BaseActive(false)
    end
end
