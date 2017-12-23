local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'

local Cybran = 2

local Difficulty = ScenarioInfo.Options.Difficulty

local M2CybranBase1 = BaseManager.CreateBaseManager()

function M2_Cybran_Base_Function()
    M2CybranBase1:Initialize(ArmyBrains[Cybran], 'JammerBase', 'JammerBase', 100, {JammerBase = 100})
    M2CybranBase1:StartNonZeroBase(10, 5)

    M2CybranBase1:SetActive('AirScouting', true)

    M2_Cybran_Air_Attacks()
    M2_Cybran_Land_Attacks()
    M2_Cybran_Transport_Attacks()
end

function M2_Cybran_Air_Attacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    quantity = {2, 4, 6}
    opai = M2CybranBase1:AddOpAI('AirAttacks', 'M2_JammerAirAttack_1_Base1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'Cybran_Jammer_Air_Attack'
            },
            Priority = 225,
        }
    )
    opai:SetChildQuantity('Bombers', quantity[Difficulty])

    opai = M2CybranBase1:AddOpAI('AirAttacks', 'M2_JammerAirAttack_2_Base1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'Cybran_Jammer_Air_Attack'
            },
            Priority = 250,
        }
    )
    opai:SetChildQuantity('LightGunships', 3)

    quantity = {8, 12, 16}
    opai = M2CybranBase1:AddOpAI('AirAttacks', 'M2_JammerAirAttack_3_Base1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'Cybran_Jammer_Air_Attack'
            },
            Priority = 200,
        }
    )
    opai:SetChildQuantity('Interceptors', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, 1, categories.FACTORY * categories.AIR, '>='})

    quantity = {2, 3, 4}
    trigger = {36, 28, 20}
    opai = M2CybranBase1:AddOpAI('AirAttacks', 'M2_JammerAirAttack_4_Base1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'Cybran_Jammer_Air_Attack'
            },
            Priority = 210,
        }
    )
    opai:SetChildQuantity('LightGunships', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.MOBILE, '>='})

    trigger = {35, 30, 25}
    quantity = {4, 6, 8}
    opai = M2CybranBase1:AddOpAI('AirAttacks', 'M2_JammerAirAttack_5_Base1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'Cybran_Jammer_Air_Attack'
            },
            Priority = 250,
        }
    )
    opai:SetChildQuantity('Bombers', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.MOBILE, '>='})

    -- Tech 2 Attacks --
    quantity = {14, 16, 18}
    opai = M2CybranBase1:AddOpAI('AirAttacks', 'M2_JammerAirAttack_T2_1_Base1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'Cybran_Jammer_Air_Attack'
            },
            Priority = 240,
        }
    )
    opai:SetChildQuantity('Interceptors', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, 1, categories.FACTORY * categories.TECH2, '>='})

    quantity = {4, 8, 10}
    opai = M2CybranBase1:AddOpAI('AirAttacks', 'M2_JammerAirAttack_T2_2_Base1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'Cybran_Jammer_Air_Attack'
            },
            Priority = 235,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, 1, categories.FACTORY * categories.TECH2, '>='})

    quantity = {4, 5, 6}
    opai = M2CybranBase1:AddOpAI('AirAttacks', 'M2_JammerAirAttack_T2_3_Base1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'Cybran_Jammer_Air_Attack'
            },
            Priority = 225,
        }
    )
    opai:SetChildQuantity('CombatFighters', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, 2, categories.FACTORY * categories.TECH2, '>='})
end

function M2_Cybran_Land_Attacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    quantity = {2, 4, 6}
    opai = M2CybranBase1:AddOpAI('BasicLandAttack', 'M2_JammerLandAttack_1_Base1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'Cybran_Jammer_Land_Attack'
            },
            Priority = 250,
        }
    )
    opai:SetChildQuantity('LightBots', quantity[Difficulty])

    quantity = {4, 6, 8}
    opai = M2CybranBase1:AddOpAI('BasicLandAttack', 'M2_JammerLandAttack_2_Base1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'Cybran_Jammer_Land_Attack'
            },
            Priority = 235,
        }
    )
    opai:SetChildQuantity('HeavyBots', quantity[Difficulty])

    quantity = {3, 5, 7}
    opai = M2CybranBase1:AddOpAI('BasicLandAttack', 'M2_JammerLandAttack_3_Base1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'Cybran_Jammer_Land_Attack'
            },
            Priority = 240,
        }
    )
    opai:SetChildQuantity('LightArtillery', quantity[Difficulty])

    trigger = {35, 30, 25}
    quantity = {15, 20, 25}
    opai = M2CybranBase1:AddOpAI('BasicLandAttack', 'M2_JammerLandAttack_4_Base1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'Cybran_Jammer_Land_Attack'
            },
            Priority = 230,
        }
    )
    opai:SetChildQuantity('HeavyBots', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.MOBILE, '>='})

    quantity = {4, 5, 6}
    opai = M2CybranBase1:AddOpAI('BasicLandAttack', 'M2_JammerLandAttack_5_Base1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'Cybran_Jammer_Land_Attack'
            },
            Priority = 250,
        }
    )
    opai:SetChildQuantity('MobileAntiAir', quantity[Difficulty])

    -- Tech 2 Attacks
    quantity = {4, 6, 8}
    opai = M2CybranBase1:AddOpAI('BasicLandAttack', 'M2_JammerLandAttack_T2_1_Base1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'Cybran_Jammer_Land_Attack'
            },
            Priority = 255,
        }
    )
    opai:SetChildQuantity('HeavyTanks', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, 1, categories.FACTORY * categories.TECH2, '>='})

    quantity = {3, 4, 5}
    opai = M2CybranBase1:AddOpAI('BasicLandAttack', 'M2_JammerLandAttack_T2_2_Base1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'Cybran_Jammer_Land_Attack'
            },
            Priority = 225,
        }
    )
    opai:SetChildQuantity('MobileMissiles', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, 2, categories.FACTORY * categories.TECH2, '>='})

    trigger = {20, 15, 10}
    quantity = {6, 9, 12}
    opai = M2CybranBase1:AddOpAI('BasicLandAttack', 'M2_JammerLandAttack_T2_3_Base1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'Cybran_Jammer_Land_Attack'
            },
            Priority = 210,
        }
    )
    opai:SetChildQuantity('HeavyTanks', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.MOBILE * categories.TECH2, '>='})

    opai = M2CybranBase1:AddOpAI('BasicLandAttack', 'M2_JammerLandAttack_T2_4_Base1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'Cybran_Jammer_Land_Attack'
            },
            Priority = 255,
        }
    )
    opai:SetChildQuantity('MobileFlak', 6)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, 1, categories.FACTORY * categories.TECH2, '>='})
end

function M2_Cybran_Transport_Attacks()
    -- Transport Builder
    opai = M2CybranBase1:AddOpAI('EngineerAttack', 'M2_Cybran_TransportBuilder_Base1_T1',
    {
        MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
        PlatoonData = {
            TransportReturn = 'M2_Transport_Return_Marker_2',
        },
        Priority = 1000,
    })
    opai:SetChildQuantity('T1Transports', 2)
    opai:SetLockingStyle('None')
    opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
        'HaveLessThanUnitsWithCategory', {'default_brain', 2, categories.ura0107})

    -- Tech 1
    opai = M2CybranBase1:AddOpAI('BasicLandAttack', 'M2_CybranTransportAttack_Base1_1',
    {
        MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
        PlatoonData = {
            AttackChain = 'M2_Cybran_Tran_Attack_Chain',
            LandingChain = 'M2_Cybran_Tran_Land_1_Chain',
            TransportReturn = 'M2_Transport_Return_Marker_2',
        },
        Priority = 150,
    })
    opai:SetChildQuantity('HeavyBots', 4)

    opai = M2CybranBase1:AddOpAI('BasicLandAttack', 'M2_CybranTransportAttack_Base1_2',
    {
        MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
        PlatoonData = {
            AttackChain = 'M2_Cybran_Tran_Attack_Chain',
            LandingChain = 'M2_Cybran_Tran_Land_1_Chain',
            TransportReturn = 'M2_Transport_Return_Marker_2',
        },
        Priority = 125,
    })
    opai:SetChildQuantity('LightBots', 6)

    trigger = {24, 20, 16}
    opai = M2CybranBase1:AddOpAI('BasicLandAttack', 'M2_CybranTransportAttack_Base1_3',
    {
        MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
        PlatoonData = {
            AttackChain = 'M2_Cybran_Tran_Attack_Chain',
            LandingChain = 'M2_Cybran_Tran_Land_1_Chain',
            TransportReturn = 'M2_Transport_Return_Marker_2',
        },
        Priority = 175,
    })
    opai:SetChildQuantity('HeavyBots', 12)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.MOBILE, '>='})

    opai = M2CybranBase1:AddOpAI('BasicLandAttack', 'M2_CybranTransportAttack_Base1_4',
    {
        MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
        PlatoonData = {
            AttackChain = 'M2_Cybran_Tran_Attack_Chain',
            LandingChain = 'M2_Cybran_Tran_Land_1_Chain',
            TransportReturn = 'M2_Transport_Return_Marker_2',
        },
        Priority = 125,
    })
    opai:SetChildQuantity('LightArtillery', 6)
end

function DisableBase()
    if(M2CybranBase1) then
        M2CybranBase1:BaseActive(false)
    end
end
