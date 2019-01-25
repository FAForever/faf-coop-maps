local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'

local Cybran = 2

local Difficulty = ScenarioInfo.Options.Difficulty

local M4CybranBase1 = BaseManager.CreateBaseManager()

function M4_Cybran_Base_1_Function()
    M4CybranBase1:Initialize(ArmyBrains[Cybran], 'MainBase', 'M3_Cybran_Base_Marker', 100, {MainBase = 100})
    M4CybranBase1:StartNonZeroBase(6, 3)

    M4CybranBase1:SetActive('AirScouting', true)

    M4_Cybran_Air_Attacks()
    M4_Cybran_Transport_Attacks()
end

function M4_Cybran_Air_Attacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    quantity = {6, 8, 10}
    opai = M4CybranBase1:AddOpAI('AirAttacks', 'M3_Cybran_Air_Attack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Cybran_Air_Attack_Chain', 'M3_Cybran_Air_Attack_2_Chain'}
            },
            Priority = 900,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])

    quantity = {3, 4, 5}
    opai = M4CybranBase1:AddOpAI('AirAttacks', 'M3_Cybran_Air_Attack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Cybran_Air_Attack_Chain', 'M3_Cybran_Air_Attack_2_Chain'}
            },
            Priority = 625,
        }
    )
    opai:SetChildQuantity('HeavyGunships', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, 1, categories.FACTORY * categories.TECH2, '>='})

    quantity = {4, 5, 6}
    opai = M4CybranBase1:AddOpAI('AirAttacks', 'M3_Cybran_Air_Attack_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Cybran_Air_Attack_Chain', 'M3_Cybran_Air_Attack_2_Chain'}
            },
            Priority = 725,
        }
    )
    opai:SetChildQuantity('CombatFighters', quantity[Difficulty])

    quantity = {10, 12, 14}
    opai = M4CybranBase1:AddOpAI('AirAttacks', 'M3_Cybran_Air_Attack_4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Cybran_Air_Attack_Chain', 'M3_Cybran_Air_Attack_2_Chain'}
            },
            Priority = 650,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])

    quantity = {14, 16, 18}
    trigger = {32, 28, 24}
    opai = M4CybranBase1:AddOpAI('AirAttacks', 'M3_Cybran_Air_Attack_5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Cybran_Air_Attack_Chain', 'M3_Cybran_Air_Attack_2_Chain'}
            },
            Priority = 850,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.AIR, '>='})

    quantity = {8, 10, 12}
    opai = M4CybranBase1:AddOpAI('AirAttacks', 'M3_Cybran_Air_Attack_6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Cybran_Air_Attack_Chain', 'M3_Cybran_Air_Attack_2_Chain'}
            },
            Priority = 625,
        }
    )
    opai:SetChildQuantity('Bombers', quantity[Difficulty])

    quantity = {4, 5, 6}
    opai = M4CybranBase1:AddOpAI('AirAttacks', 'M3_Cybran_Air_Attack_7',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Cybran_Air_Attack_Chain', 'M3_Cybran_Air_Attack_2_Chain'}
            },
            Priority = 575,
        }
    )
    opai:SetChildQuantity('CombatFighters', quantity[Difficulty])

    quantity = {2, 3, 4}
    opai = M4CybranBase1:AddOpAI('AirAttacks', 'M3_Cybran_Air_Attack_8',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M3_Cybran_Air_Attack_Chain', 'M3_Cybran_Air_Attack_2_Chain'}
            },
            Priority = 750,
        }
    )
    opai:SetChildQuantity('StratBombers', quantity[Difficulty])
end

function M4_Cybran_Transport_Attacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    opai = M4CybranBase1:AddOpAI('EngineerAttack', 'M3_Cybran_TransportBuilder_T2',
    {
        MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
        PlatoonData = {
            TransportReturn = 'M3_Cybran_Base_Marker',
        },
        Priority = 1000,
    })
    opai:SetChildQuantity('T2Transports', 4)
    opai:SetLockingStyle('None')
    opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
        'HaveLessThanUnitsWithCategory', {'default_brain', 4, categories.ura0104}
    )

    quantity = {2, 4, 6}
    opai = M4CybranBase1:AddOpAI('BasicLandAttack', 'M3_CybranTransportAttack1',
    {
        MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
        PlatoonData = {
            AttackChain = 'M2_Cybran_Tran_Attack_Chain',
            LandingChain = 'M2_Cybran_Tran_Land_2_Chain',
            TransportReturn = 'M3_Cybran_Base_Marker',
        },
        Priority = 225,
    })
    opai:SetChildQuantity('SiegeBots', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, 1, categories.FACTORY * categories.TECH2, '>='})

    quantity = {4, 6, 8}
    opai = M4CybranBase1:AddOpAI('BasicLandAttack', 'M3_CybranTransportAttack2',
    {
        MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
        PlatoonData = {
            AttackChain = 'M2_Cybran_Tran_Attack_Chain',
            LandingChain = 'M2_Cybran_Tran_Land_2_Chain',
            TransportReturn = 'M3_Cybran_Base_Marker',
        },
        Priority = 300,
    })
    opai:SetChildQuantity('HeavyTanks', quantity[Difficulty])

    opai = M4CybranBase1:AddOpAI('BasicLandAttack', 'M3_CybranTransportAttack3',
    {
        MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
        PlatoonData = {
            AttackChain = 'M2_Cybran_Tran_Attack_Chain',
            LandingChain = 'M2_Cybran_Tran_Land_2_Chain',
            TransportReturn = 'M3_Cybran_Base_Marker',
        },
        Priority = 275,
    })
    opai:SetChildQuantity('MobileFlak', 4)

    quantity = {2, 3, 4}
    opai = M4CybranBase1:AddOpAI('BasicLandAttack', 'M3_CybranTransportAttack4',
    {
        MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
        PlatoonData = {
            AttackChain = 'M2_Cybran_Tran_Attack_Chain',
            LandingChain = 'M2_Cybran_Tran_Land_2_Chain',
            TransportReturn = 'M3_Cybran_Base_Marker',
        },
        Priority = 235,
    })
    opai:SetChildQuantity('HeavyBots', quantity[Difficulty])

    quantity = {3, 4, 6}
    opai = M4CybranBase1:AddOpAI('BasicLandAttack', 'M3_CybranTransportAttack5',
    {
        MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
        PlatoonData = {
            AttackChain = 'M2_Cybran_Tran_Attack_Chain',
            LandingChain = 'M2_Cybran_Tran_Land_2_Chain',
            TransportReturn = 'M3_Cybran_Base_Marker',
        },
        Priority = 275,
    })
    opai:SetChildQuantity('SiegeBots', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, 1, categories.FACTORY * categories.TECH3, '>='})

    quantity = {4, 6, 8}
    opai = M4CybranBase1:AddOpAI('BasicLandAttack', 'M3_CybranTransportAttack6',
    {
        MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
        PlatoonData = {
            AttackChain = 'M2_Cybran_Tran_Attack_Chain',
            LandingChain = 'M2_Cybran_Tran_Land_2_Chain',
            TransportReturn = 'M3_Cybran_Base_Marker',
        },
        Priority = 295,
    })
    opai:SetChildQuantity('MobileMissiles', quantity[Difficulty])

    quantity = {2, 3, 4}
    opai = M4CybranBase1:AddOpAI('BasicLandAttack', 'M3_CybranTransportAttack7',
    {
        MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
        PlatoonData = {
            AttackChain = 'M2_Cybran_Tran_Attack_Chain',
            LandingChain = 'M2_Cybran_Tran_Land_2_Chain',
            TransportReturn = 'M3_Cybran_Base_Marker',
        },
        Priority = 265,
    })
    opai:SetChildQuantity('MobileHeavyArtillery', quantity[Difficulty])

    quantity = {6, 7, 8}
    opai = M4CybranBase1:AddOpAI('BasicLandAttack', 'M3_CybranTransportAttack8',
    {
        MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
        PlatoonData = {
            AttackChain = 'M2_Cybran_Tran_Attack_Chain',
            LandingChain = 'M2_Cybran_Tran_Land_2_Chain',
            TransportReturn = 'M3_Cybran_Base_Marker',
        },
        Priority = 325,
    })
    opai:SetChildQuantity('LightArtillery', quantity[Difficulty])
end

function DisableBase()
    if(M4CybranBase1) then
        M4CybranBase1:BaseActive(false)
    end
end

