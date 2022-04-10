-- ****************************************************************************
-- **
-- **  File     : /maps/X1CA_Coop_001/X1CA_Coop_001_m4seraphimai.lua
-- **  Author(s): Jessica St. Croix
-- **
-- **  Summary  : Serapim army AI for Mission 4 - X1CA_Coop_001
-- **
-- **  Copyright © 2007 Gas Powered Games, Inc.  All rights reserved.
-- ****************************************************************************
local BaseManager = import('/lua/ai/opai/basemanager.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')

local SPAIFileName = '/lua/scenarioplatoonai.lua'

--------
-- Locals
--------
local Seraphim = 2
local Difficulty = ScenarioInfo.Options.Difficulty

---------------
-- Base Managers
---------------
local SeraphimM4NorthMainBase = BaseManager.CreateBaseManager()
local SeraphimM4SouthMainBase = BaseManager.CreateBaseManager()
local SeraphimM4AirMainBase = BaseManager.CreateBaseManager()
local SeraphimM4ForwardOne = BaseManager.CreateBaseManager()
local SeraphimM4ForwardTwo = BaseManager.CreateBaseManager()
local SeraphimM4NavalBase = BaseManager.CreateBaseManager()

function SeraphimM4NorthMainBaseAI()

    -----------------------------
    -- Seraphim M4 North Main Base
    -----------------------------
    ScenarioUtils.CreateArmyGroup('Seraphim', 'M3_SeraphNorth_Start_Eng_D' .. Difficulty)
    SeraphimM4NorthMainBase:InitializeDifficultyTables(ArmyBrains[Seraphim], 'M3_North_Base_Main', 'Seraphim_M3_North_Base_Marker', 60, {M3_North_Base_Main = 100,})
    SeraphimM4NorthMainBase:StartNonZeroBase({{3, 7, 11}, {2, 6, 10}})
    SeraphimM4NorthMainBase:SetBuild('Defenses', false)

    SeraphimM4NorthMainBaseLandAttacks()
end

function SeraphimM4NorthMainBaseLandAttacks()
    local opai = nil

    --------------------------------------------
    -- Seraphim M4 North Main Op AI, Land Attacks
    --------------------------------------------

    -- sends [siege bots, heavy tanks, light tanks]
    opai = SeraphimM4NorthMainBase:AddOpAI('BasicLandAttack', 'M4_NorthLandAttack1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Seraph_M4_NorthAttack_Chain', 'Seraph_M4_SouthAttack_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'SiegeBots'}, 12)
    opai:SetLockingStyle('None')

    -- sends [heavy tanks, heavy bots]
    opai = SeraphimM4NorthMainBase:AddOpAI('BasicLandAttack', 'M4_NorthLandAttack2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Seraph_M4_NorthAttack_Chain', 'Seraph_M4_SouthAttack_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'HeavyTanks', 'HeavyBots'}, 12)
    opai:SetLockingStyle('None')

    -- sends [mobile missiles, light artillery]
    opai = SeraphimM4NorthMainBase:AddOpAI('BasicLandAttack', 'M4_NorthLandAttack3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Seraph_M4_NorthAttack_Chain', 'Seraph_M4_SouthAttack_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'MobileMissiles', 'LightArtillery'}, 12)
    opai:SetLockingStyle('None')

    -- sends [mobile flak, light bots]
    opai = SeraphimM4NorthMainBase:AddOpAI('BasicLandAttack', 'M4_NorthLandAttack4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Seraph_M4_NorthAttack_Chain', 'Seraph_M4_SouthAttack_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'MobileFlak', 'LightBots'}, 12)
    opai:SetLockingStyle('None')
end

function SeraphimM4SouthMainBaseAI()

    -----------------------------
    -- Seraphim M4 South Main Base
    -----------------------------
    ScenarioUtils.CreateArmyGroup('Seraphim', 'M3_SeraphSouth_Start_Eng_D' .. Difficulty)
    SeraphimM4SouthMainBase:InitializeDifficultyTables(ArmyBrains[Seraphim], 'M3_South_Base_Main', 'Seraphim_M3_South_Base_Marker', 50, {M3_South_Base_Main = 100,})
    SeraphimM4SouthMainBase:StartNonZeroBase({{3, 7, 11}, {2, 6, 10}})
    SeraphimM4SouthMainBase:SetBuild('Defenses', false)

    SeraphimM4SouthMainBase:AddBuildGroup('M3_Seraph_Forward_One_D2', 90)
    SeraphimM4SouthMainBase:AddBuildGroup('M3_Seraph_Forward_Two_D2', 80)

    SeraphimM4SouthMainBaseLandAttacks()
end

function SeraphimM4SouthMainBaseLandAttacks()
    local opai = nil

    --------------------------------------------
    -- Seraphim M4 South Main Op AI, Land Attacks
    --------------------------------------------

    -- sends [siege bots, heavy tanks, light tanks]
    opai = SeraphimM4SouthMainBase:AddOpAI('BasicLandAttack', 'M4_SouthLandAttack1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Seraph_M4_NorthAttack_Chain', 'Seraph_M4_SouthAttack_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'SiegeBots'}, 12)
    opai:SetLockingStyle('None')

    -- sends [heavy tanks, heavy bots]
    opai = SeraphimM4SouthMainBase:AddOpAI('BasicLandAttack', 'M4_SouthLandAttack2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Seraph_M4_NorthAttack_Chain', 'Seraph_M4_SouthAttack_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'HeavyTanks'}, 12)
    opai:SetLockingStyle('None')

    -- sends [mobile missiles]
    opai = SeraphimM4SouthMainBase:AddOpAI('BasicLandAttack', 'M4_SouthLandAttack3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Seraph_M4_NorthAttack_Chain', 'Seraph_M4_SouthAttack_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'MobileMissiles'}, 12)
    opai:SetLockingStyle('None')

    -- sends [mobile flak, light bots]
    opai = SeraphimM4SouthMainBase:AddOpAI('BasicLandAttack', 'M4_SouthLandAttack4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Seraph_M4_NorthAttack_Chain', 'Seraph_M4_SouthAttack_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'MobileFlak'}, 12)
    opai:SetLockingStyle('None')
end

function SeraphimM4AirMainBaseAI()

    ---------------------------
    -- Seraphim M4 Air Main Base
    ---------------------------
    ScenarioUtils.CreateArmyGroup('Seraphim', 'M3_SeraphAir_Start_Eng_D' .. Difficulty)
    SeraphimM4AirMainBase:InitializeDifficultyTables(ArmyBrains[Seraphim], 'M3_Air_Base_Main', 'Seraphim_M3_Air_Base_Marker', 50, {M3_Air_Base_Main = 100,})
    SeraphimM4AirMainBase:StartNonZeroBase({{2, 5, 9}, {2, 4, 7}})
    SeraphimM4AirMainBase:SetActive('AirScouting', true)
    SeraphimM4AirMainBase:SetBuild('Defenses', false)

    SeraphimM4AirMainBase:AddReactiveAI('ExperimentalLand', 'AirRetaliation', 'SeraphimM4AirMainBase_ExperimentalLand')
    SeraphimM4AirMainBase:AddReactiveAI('ExperimentalAir', 'AirRetaliation', 'SeraphimM4AirMainBase_ExperimentalAir')
    SeraphimM4AirMainBase:AddReactiveAI('ExperimentalNaval', 'AirRetaliation', 'SeraphimM4AirMainBase_ExperimentalNaval')
    SeraphimM4AirMainBase:AddReactiveAI('Nuke', 'AirRetaliation', 'SeraphimM4AirMainBase_Nuke')
    SeraphimM4AirMainBase:AddReactiveAI('HLRA', 'AirRetaliation', 'SeraphimM4AirMainBase_HLRA')

    SeraphimM4AirMainBaseAirAttacks()
end

function SeraphimM4AirMainBaseAirAttacks()
    local opai = nil
    local quantity = {}

    ----------------------------------------------
    -- Seraphim M4 Air Main Base Op AI, Air Attacks
    ----------------------------------------------

    ---- Attacks Fort Clarke

    -- sends [gunships, interceptors]
    quantity = {8, 12, 16}
    opai = SeraphimM4AirMainBase:AddOpAI('AirAttacks', 'M4_AirMainAirAttacks1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'Seraph_M4_AirAttack_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'Gunships', 'Interceptors'}, quantity[Difficulty])
    opai:SetLockingStyle('None')

    -- sends [gunships, bombers]
    quantity = {8, 12, 16}
    opai = SeraphimM4AirMainBase:AddOpAI('AirAttacks', 'M4_AirMainAirAttacks2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'Seraph_M4_AirAttack_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'Gunships', 'Bombers'}, quantity[Difficulty])
    opai:SetLockingStyle('None')

    -- sends [gunships]
    opai = SeraphimM4AirMainBase:AddOpAI('AirAttacks', 'M4_AirMainAirAttacks3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'Seraph_M4_AirAttack_Chain',
            },
            Priority = 115,
        }
    )
    opai:SetChildQuantity({'Gunships'}, 24)
    opai:SetLockingStyle('BuildTimer', {LockTimer = 60})

    ---- Attacks Player

    -- sends 6, 8, 10 [gunships, interceptors]
    quantity = {8, 12, 16}
    opai = SeraphimM4AirMainBase:AddOpAI('AirAttacks', 'M4_AirMainAirAttacks10',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M4_Seraph_AttackPlayer_Air_Chain',
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'Gunships', 'Interceptors'}, quantity[Difficulty])
    opai:SetLockingStyle('DeathTimer', {LockTimer = 120})

    -- sends 6, 8, 10 [gunships, bombers]
    quantity = {8, 12, 16}
    opai = SeraphimM4AirMainBase:AddOpAI('AirAttacks', 'M4_AirMainAirAttacks11',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M4_Seraph_AttackPlayer_Air_Chain',
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'Gunships', 'Bombers'}, quantity[Difficulty])
    opai:SetLockingStyle('DeathTimer', {LockTimer = 120})

    ---- Defense Patrols

    -- [interceptors]
    quantity = {8, 12, 16}
    opai = SeraphimM4AirMainBase:AddOpAI('AirAttacks', 'M4_AirMainDefense1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
            PlatoonData = {
                PatrolChain = 'Seraph_Main_NearAirDef_Chain',
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Interceptors', quantity[Difficulty])

    -- [interceptors]
    quantity = {8, 12, 16}
    opai = SeraphimM4AirMainBase:AddOpAI('AirAttacks', 'M4_AirMainDefense2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
            PlatoonData = {
                PatrolChain = 'Seraph_Main_MidAirDef_Chain',
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('Interceptors', quantity[Difficulty])

    -- [air superiority]
    quantity = {8, 12, 16}
    opai = SeraphimM4AirMainBase:AddOpAI('AirAttacks', 'M4_AirMainDefense3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
            PlatoonData = {
                PatrolChain = 'Seraph_Main_NearAirDef_Chain',
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])

    -- [air superiority]
    quantity = {8, 12, 16}
    opai = SeraphimM4AirMainBase:AddOpAI('AirAttacks', 'M4_AirMainDefense4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
            PlatoonData = {
                PatrolChain = 'Seraph_Main_MidAirDef_Chain',
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])

    -- [air superiority]
    quantity = {8, 12, 16}
    opai = SeraphimM4AirMainBase:AddOpAI('AirAttacks', 'M4_AirMainDefense5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
            PlatoonData = {
                PatrolChain = 'Seraph_Main_NearAirDef_Chain',
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])

    -- [gunships]
    quantity = {8, 12, 16}
    opai = SeraphimM4AirMainBase:AddOpAI('AirAttacks', 'M4_AirMainDefense6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
            PlatoonData = {
                PatrolChain = 'Seraph_Main_NearAirDef_Chain',
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])

    -- [gunships]
    quantity = {8, 12, 16}
    opai = SeraphimM4AirMainBase:AddOpAI('AirAttacks', 'M4_AirMainDefense7',
        {
            MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
            PlatoonData = {
                PatrolChain = 'Seraph_Main_MidAirDef_Chain',
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
end

function SeraphimM4YthotaAttacks()
    quantity = {0, 1, 2}
    opai = SeraphimM4AirMainBase:AddOpAI('M4_Ythotha',
        {
            Amount = quantity[Difficulty],
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M4_Incarna_Attack_Chain',
            },
            MaxAssist = quantity[Difficulty],
            Retry = true,
        }
    )
end

function SeraphimM4ForwardOneAI()

    -----------------------
    -- Seraphim M4 Forward 1
    -----------------------
    SeraphimM4ForwardOne:InitializeDifficultyTables(ArmyBrains[Seraphim], 'M3_Seraph_Forward_One', 'Seraphim_M3_Forward_One_Base_Marker', 30, {M3_Seraph_Forward_One = 100,})
    SeraphimM4ForwardOne:StartNonZeroBase({{1, 2, 3}, {1, 2, 3}})
    SeraphimM4ForwardOne:SetBuild('Defenses', false)

    SeraphimM4ForwardOneLandAttacks()
end

function SeraphimM4ForwardOneLandAttacks()
    local opai = nil

    ------------------------------------------
    -- Seraphim M4 Foward 1 Op AI, Land Attacks
    ------------------------------------------

    -- sends [siege bots, heavy tanks, light tanks]
    opai = SeraphimM4ForwardOne:AddOpAI('BasicLandAttack', 'M4_Forward1LandAttack1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'Seraph_M4_SouthAttack_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'SiegeBots', 'HeavyTanks', 'LightTanks'}, 6)
    opai:SetLockingStyle('None')

    -- sends [heavy tanks, heavy bots]
    opai = SeraphimM4ForwardOne:AddOpAI('BasicLandAttack', 'M4_Forward1LandAttack2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'Seraph_M4_SouthAttack_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'HeavyTanks', 'HeavyBots'}, 4)
    opai:SetLockingStyle('None')

    -- sends [mobile missiles, light artillery]
    opai = SeraphimM4ForwardOne:AddOpAI('BasicLandAttack', 'M4_Forward1LandAttack3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'Seraph_M4_SouthAttack_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'MobileMissiles', 'LightArtillery'}, 4)
    opai:SetLockingStyle('None')

    -- sends [mobile flak, light bots]
    opai = SeraphimM4ForwardOne:AddOpAI('BasicLandAttack', 'M4_Forward1LandAttack4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'Seraph_M4_SouthAttack_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'MobileFlak', 'LightBots'}, 4)
    opai:SetLockingStyle('None')
end

function SeraphimM4ForwardTwoAI()

    -----------------------
    -- Seraphim M4 Forward 2
    -----------------------
    SeraphimM4ForwardTwo:InitializeDifficultyTables(ArmyBrains[Seraphim], 'M3_Seraph_Forward_Two', 'Seraphim_M3_Forward_Two_Base_Marker', 30, {M3_Seraph_Forward_Two = 100,})
    SeraphimM4ForwardTwo:StartNonZeroBase({{1, 2, 3}, {1, 2, 3}})
    SeraphimM4ForwardTwo:SetBuild('Defenses', false)

    SeraphimM4ForwardTwoLandAttacks()
end

function SeraphimM4ForwardTwoLandAttacks()
    local opai = nil

    ------------------------------------------
    -- Seraphim M4 Foward 2 Op AI, Land Attacks
    ------------------------------------------

    -- sends [siege bots, heavy tanks, light tanks]
    opai = SeraphimM4ForwardTwo:AddOpAI('BasicLandAttack', 'M4_Forward2LandAttack1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'Seraph_M4_NorthAttack_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'SiegeBots', 'HeavyTanks', 'LightTanks'}, 3)
    opai:SetLockingStyle('None')

    -- sends [heavy tanks, heavy bots]
    opai = SeraphimM4ForwardTwo:AddOpAI('BasicLandAttack', 'M4_Forward2LandAttack2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'Seraph_M4_NorthAttack_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'HeavyTanks', 'HeavyBots'}, 4)
    opai:SetLockingStyle('None')

    -- sends [mobile missiles, light artillery]
    opai = SeraphimM4ForwardTwo:AddOpAI('BasicLandAttack', 'M4_Forward2LandAttack3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'Seraph_M4_NorthAttack_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'MobileMissiles', 'LightArtillery'}, 4)
    opai:SetLockingStyle('None')

    -- sends [mobile flak, light bots]
    opai = SeraphimM4ForwardTwo:AddOpAI('BasicLandAttack', 'M4_Forward2LandAttack4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'Seraph_M4_NorthAttack_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'MobileFlak', 'LightBots'}, 4)
    opai:SetLockingStyle('None')
end

function SeraphimM4NavalBaseAI()

    ------------------------
    -- Seraphim M4 Naval Base
    ------------------------
    SeraphimM4NavalBase:InitializeDifficultyTables(ArmyBrains[Seraphim], 'M3_Naval_Base', 'M3_Naval_Base_Marker', 60, {M3_Naval_Base = 100,})
    SeraphimM4NavalBase:StartNonZeroBase({{1, 3, 4}, {1, 3, 4}})
    SeraphimM4NavalBase:SetBuild('Defenses', false)

    SeraphimM4NavalBaseNavalAttacks()
end

function SeraphimM4NavalBaseNavalAttacks()
    local opai = nil
    local trigger = {}

    ---------------------------------------------
    -- Seraphim M4 Naval Base Op AI, Naval Attacks
    ---------------------------------------------

    -- sends 3 frigate power of [frigates]
    opai = SeraphimM4NavalBase:AddNavalAI('M4_NavalAttack1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Naval_Attack1_Chain', 'M3_Naval_Attack2_Chain'},
            },
            EnableTypes = {'Frigate'},
            MaxFrigates = 3,
            MinFrigates = 3,
            Priority = 100,
        }
    )

    -- sends 6 - 50 frigate power of all but T3
    opai = SeraphimM4NavalBase:AddNavalAI('M4_NavalAttack2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Naval_Attack1_Chain', 'M3_Naval_Attack2_Chain'},
            },
            MaxFrigates = 50,
            MinFrigates = 6,
            Priority = 100,
        }
    )
    opai:SetChildActive('T3', false)

    -- sends 6 frigate power of [frigates, subs] if player has >= 8, 6, 4 boats
    trigger = {8, 6, 4}
    opai = SeraphimM4NavalBase:AddNavalAI('M4_NavalAttack3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Naval_Attack1_Chain', 'M3_Naval_Attack2_Chain'},
            },
            EnableTypes = {'Frigate', 'Submarine'},
            MaxFrigates = 6,
            MinFrigates = 6,
            Priority = 110,
        }
    )
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE, '>='})

    -- sends 9 frigate power of [all but T3] if player has >= 5, 3, 2 T2/T3 boats
    trigger = {5, 3, 2}
    opai = SeraphimM4NavalBase:AddNavalAI('M4_NavalAttack4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Naval_Attack1_Chain', 'M3_Naval_Attack2_Chain'},
            },
            MaxFrigates = 9,
            MinFrigates = 9,
            Priority = 120,
        }
    )
    opai:SetChildActive('T3', false)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',  'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], (categories.NAVAL * categories.MOBILE) - categories.TECH1, '>='})

    -- sends 12 frigate power of [all but T3] if player has >= 6, 5, 4 T2/T3 boats
    trigger = {6, 5, 4}
    opai = SeraphimM4NavalBase:AddNavalAI('M4_NavalAttack5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Naval_Attack1_Chain', 'M3_Naval_Attack2_Chain'},
            },
            MaxFrigates = 12,
            MinFrigates = 12,
            Priority = 130,
        }
    )
    opai:SetChildActive('T3', false)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], (categories.NAVAL * categories.MOBILE) - categories.TECH1, '>='})

    -- sends 20 - 50 frigate power if player has >= 5, 4, 3 T3 boats
    trigger = {5, 4, 3}
    opai = SeraphimM4NavalBase:AddNavalAI('M4_NavalAttack6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Naval_Attack1_Chain', 'M3_Naval_Attack2_Chain'},
            },
            MaxFrigates = 50,
            MinFrigates = 20,
            Priority = 140,
        }
    )
    opai:SetChildActive('T3', false)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE * categories.TECH3, '>='})

    quantity = {{1, 2}, {1, 3}, {1, 4}}
    trigger = {2, 1, 1}
    opai = SeraphimM4NavalBase:AddOpAI('NavalAttacks', 'M4_NavalAttack7',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Naval_Attack1_Chain', 'M3_Naval_Attack2_Chain'},
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity({'Battleships', 'Destroyers'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE * categories.TECH3, '>='})

    trigger = {5, 4, 3}
    opai = SeraphimM4NavalBase:AddOpAI('NavalAttacks', 'M4_NavalAttack8',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Naval_Attack1_Chain', 'M3_Naval_Attack2_Chain'},
            },
            Priority = 160,
        }
    )
    opai:SetChildQuantity('Battleships', 3)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE * categories.TECH3, '>='})

    -- Naval Defense
    for i = 1, 2 do
        opai = SeraphimM4NavalBase:AddNavalAI('M4_NavalDefense' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M4_Seraph_Naval_Chain',
                },
                MaxFrigates = 9,
                MinFrigates = 9,
                Priority = 140,
            }
        )
        opai:SetChildActive('T3', false)
    end

    -- Sonar
    opai = SeraphimM4NavalBase:AddOpAI('M3_Naval_Base_Sonar',
        {
            Amount = 1,
            KeepAlive = true,
            MaxAssist = 1,
            Retry = true,
        }
    )
end
