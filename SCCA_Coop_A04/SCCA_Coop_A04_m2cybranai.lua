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
local CybranM2MainframeBase = BaseManager.CreateBaseManager()
local CybranM2EastBase = BaseManager.CreateBaseManager()
local CybranM2NorthWestBase = BaseManager.CreateBaseManager()
local CybranM2SouthWestBase = BaseManager.CreateBaseManager()

---------------------------
-- Cybran M2 Mainframe Base
---------------------------
function CybranM2MainframeBaseAI()
    CybranM2MainframeBase:InitializeDifficultyTables(ArmyBrains[Cybran], 'M2_Cybran_Mainframe_Base', 'M2_Cybran_Mainframe_Base_Marker', 40, {M2_Cybran_Mainframe_Base = 100})
    CybranM2MainframeBase:StartNonZeroBase({{3, 6, 12}, {3, 5, 9}})
    CybranM2MainframeBase:SetActive('AirScouting', true)

    ForkThread(function()
        WaitSeconds(1)
        CybranM2MainframeBase:AddBuildGroup('M2_Cybran_Mainframe_Support_Factories', 100, true)
    end)

    -- Resource Bases
    CybranM2MainframeBase:AddBuildGroup('M2_Resources_1', 90, true)
    CybranM2MainframeBase:AddBuildGroup('M2_Resources_2', 80, true)

    CybranM2MainframeBaseAirAttacks()
end

function CybranM2MainframeBaseAirAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    quantity = {3, 6, 9}
    opai = CybranM2MainframeBase:AddOpAI('AirAttacks', 'M2_Cybran_Mainfram_AirAttack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Cybran_M2_Mainframe_Base_AirAttack_Chain_1',
                                'Cybran_M2_Mainframe_Base_AirAttack_Chain_2'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Bombers', quantity[Difficulty])
    opai:SetLockingStyle('None')

    -- Send 3, 3, 6 Gunships
    quantity = {3, 6, 9}
    opai = CybranM2MainframeBase:AddOpAI('AirAttacks', 'M2_Cybran_Mainfram_AirAttack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Cybran_M2_Mainframe_Base_AirAttack_Chain_1',
                                'Cybran_M2_Mainframe_Base_AirAttack_Chain_2'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])

    quantity = {6, 9, 12}
    trigger = {20, 15, 10}
    opai = CybranM2MainframeBase:AddOpAI('AirAttacks', 'M2_Cybran_Mainfram_AirAttack_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Cybran_M2_Mainframe_Base_AirAttack_Chain_1',
                                'Cybran_M2_Mainframe_Base_AirAttack_Chain_2'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Interceptors', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE, '>='})
end

----------------------
-- Cybran M2 East Base
----------------------
function CybranM2EastBaseAI()
    CybranM2EastBase:Initialize(ArmyBrains[Cybran], 'M2_Cybran_East_Base', 'M2_Cybran_East_Base_Marker', 100, {M2_Cybran_East_Base = 100})
    CybranM2EastBase:StartNonZeroBase({{6, 12, 18}, {6, 12, 18}})

    CybranM2EastBaseAirAttacks()
    CybranM2EastBaseLandAttacks()
    CybranM2EastBaseNavalAttacks()
end

function CybranM2EastBaseAirAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    -- Transport Builder
    opai = CybranM2EastBase:AddOpAI('EngineerAttack', 'M2_Cybran_East_TransportBuilder',
    {
        MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
        PlatoonData = {
            TransportReturn = 'M2_Cybran_East_Base_Marker',
        },
        Priority = 1000,
    })
    opai:SetChildQuantity('T2Transports', 4)
    opai:SetLockingStyle('None')
    opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
        'HaveLessThanUnitsWithCategory', {'default_brain', 6, categories.ura0104})

    -- Send 6, 8, 10 Gunships
    quantity = {6, 8, 10}
    opai = CybranM2EastBase:AddOpAI('AirAttacks', 'M2_Cybran_East_AirAttack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Cybran_M2_East_Player_Chain',
                                'Cybran_M2_East_Destroyers_Player_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    opai:SetLockingStyle('None')

    -- Send 1, 2, 2 Strat bombers every 4 minutes
    quantity = {1, 1, 2}
    opai = CybranM2EastBase:AddOpAI('AirAttacks', 'M2_Cybran_East_AirAttack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Cybran_M2_East_Player_Chain',
                                'Cybran_M2_East_Destroyers_Player_Chain'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('StratBombers', quantity[Difficulty])
    opai:SetLockingStyle('DeathTimer', {LockTimer = 240})

    -- Send 8, 12, 16 interceptors if players have more than 50, 40, 30 air units
    quantity = {8, 12, 16}
    trigger = {50, 40, 30}
    opai = CybranM2EastBase:AddOpAI('AirAttacks', 'M2_Cybran_East_AirAttack_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Cybran_M2_East_Player_Chain',
                                'Cybran_M2_East_Destroyers_Player_Chain',
                                'Cybran_M2_East_Naval_Mainframe_Chain'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('Interceptors', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE, '>='})
end

function CybranM2EastBaseLandAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    -- Wagner attacks
    quantity = {6, 8, 10}
    opai = CybranM2EastBase:AddOpAI('BasicLandAttack', 'M2_Cybran_AmphibiousAttack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'Cybran_M2_East_Amphibious_Chain',
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('AmphibiousTanks', quantity[Difficulty])
    opai:SetFormation('AttackFormation')

    -- Drops
    -- Rhinos
    quantity = {4, 8, 12}
    opai = CybranM2EastBase:AddOpAI('BasicLandAttack', 'M2_Cybran_East_TransportAttack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain = 'Player_Patrol_Chain',
                LandingChain = 'M2_South_East_Landing_Chain',
                TransportReturn = 'M2_Cybran_East_Base_Marker',
                MovePath = 'M2_South_East_Transport_Move_Chain',
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('HeavyTanks', quantity[Difficulty])

    -- T1 Arty
    opai = CybranM2EastBase:AddOpAI('BasicLandAttack', 'M2_Cybran_East_TransportAttack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain = 'M1_North_Arty_Rhino_Chain_1',
                LandingList = {'M1_North_Arty_Rhino_1'},
                TransportReturn = 'M2_Cybran_East_Base_Marker',
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('LightArtillery', 10)
end

function CybranM2EastBaseNavalAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    opai = CybranM2EastBase:AddNavalAI('M2_Cybran_East_Destroyer_Attack_Player',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'Cybran_M2_East_Destroyers_Player_Chain',
            },
            EnabledTypes = {'Destroyer'},
            MaxFrigates = 10,
            MinFrigates = 10,
            Priority = 100,
        }
    )
    opai:SetLockingStyle('DeathTimer', {LockTimer = 240})

    opai = CybranM2EastBase:AddNavalAI('M2_Cybran_East_Destroyer_Attack_Mainframe',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'Cybran_M2_East_Naval_Mainframe_Chain',
            },
            EnabledTypes = {'Destroyer'},
            MaxFrigates = 10,
            MinFrigates = 10,
            Priority = 100,
        }
    )
    opai:SetLockingStyle('DeathTimer', {LockTimer = 300})

    quantity = {7, 9, 14}
    opai = CybranM2EastBase:AddNavalAI('M_Cybran_East_Naval_Attack_Player_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'Cybran_M2_East_Naval_Chain',
            },
            EnabledTypes = {'Frigate', 'Destroyer', 'Cruiser'},
            Overrides = {
                CORE_TO_CRUISERS = 2,
            },
            MaxFrigates = quantity[Difficulty],
            MinFrigates = quantity[Difficulty],
            Priority = 110,
        }
    )
    opai:SetLockingStyle('None')
end

---------------------------
-- Cybran M2 NorthWest Base
---------------------------
function CybranM2NorthWestBaseAI()
    CybranM2NorthWestBase:Initialize(ArmyBrains[Cybran], 'M2_Cybran_NorthWest_Base', 'M2_Cybran_NorthWest_Base_Marker', 120, {M2_Cybran_NorthWest_Base = 100})
    CybranM2NorthWestBase:StartNonZeroBase({{4, 8, 12}, {4, 8, 12}})

    CybranM2NorthWestBaseAirAttacks()
    CybranM2NorthWestBaseNavalAttacks()
end

function CybranM2NorthWestBaseAirAttacks()
    local opai = nil
    local quantity = {}

    -- Send 6, 8, 10 Gunships
    quantity = {8, 10, 12}
    opai = CybranM2NorthWestBase:AddOpAI('AirAttacks', 'M2_Cybran_North_West_AirAttack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Cybran_M2_West_NW_Mainframe_Chain',
                                'Cybran_M2_West_NW_Mainframe_Naval_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    opai:SetLockingStyle('None')

    -- Send 8, 12, 16 interceptors if players have more than 50, 40, 30 air units
    quantity = {8, 12, 16}
    opai = CybranM2NorthWestBase:AddOpAI('AirAttacks', 'M2_Cybran_North_West_AirAttack_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'Cybran_M2_West_NW_Mainframe_Chain',
                                'Cybran_M2_West_NW_Mainframe_Naval_Chain'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('Interceptors', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, 25, categories.AIR * categories.MOBILE, '>='})
end

function CybranM2NorthWestBaseNavalAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}
end

---------------------------
-- Cybran M2 SouthWest Base
---------------------------
function CybranM2SouthWestBaseAI()
    CybranM2SouthWestBase:Initialize(ArmyBrains[Cybran], 'M2_Cybran_SouthWest_Base', 'M2_Cybran_SouthWest_Base_Marker', 60, {M2_Cybran_SouthWest_Base = 100})
    CybranM2SouthWestBase:StartNonZeroBase({{2, 4, 6}, {2, 4, 6}})
    CybranM2SouthWestBase:SetActive('AirScouting', true)

    CybranM2SouthWestBaseAirAttacks()
end

function CybranM2SouthWestBaseAirAttacks()
    local opai = nil
    local quantity = {}

    quantity = {8, 10, 12}
    opai = CybranM2SouthWestBase:AddOpAI('AirAttacks', 'M2_Cybran_SW_AirAttack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'Cybran_M2_SouthWest_Player_Mainframe_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    opai:SetLockingStyle('None')

    -- Send 1, 2, 2 Strat bombers every 5 minutes
    quantity = {1, 1, 2}
    opai = CybranM2SouthWestBase:AddOpAI('AirAttacks', 'M2_Cybran_SW_AirAttack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'Cybran_M2_SouthWest_Player_Mainframe_Chain',
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('StratBombers', quantity[Difficulty])
    opai:SetLockingStyle('DeathTimer', {LockTimer = 300})

    -- Send 8, 12, 16 interceptors if players have more than 40 air units
    quantity = {8, 12, 16}
    opai = CybranM2SouthWestBase:AddOpAI('AirAttacks', 'M2_Cybran_SW_AirAttack_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'Cybran_M2_SouthWest_Player_Mainframe_Chain',
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('Interceptors', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, 40, categories.AIR * categories.MOBILE, '>='})
end