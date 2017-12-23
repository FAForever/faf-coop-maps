local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'

local Cybran = 2

local Difficulty = ScenarioInfo.Options.Difficulty

local M2CybranBase2 = BaseManager.CreateBaseManager()

function M2_Cybran_Base_Function()
    M2CybranBase2:Initialize(ArmyBrains[Cybran], 'JammerBase2', 'JammerBase2', 75, {JammerBase2 = 100})
    M2CybranBase2:StartNonZeroBase(8, 5)

    M2CybranBase2:SetActive('AirScouting', true)

    M2_Cybran_Air_Attacks()
    M2_Cybran_Transport_Attacks()
end

function M2_Cybran_Air_Attacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    -- Initial Attacks
    quantity = {2, 4, 6}
    opai = M2CybranBase2:AddOpAI('AirAttacks', 'M2_JammerAirAttack_2_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'Cybran_Jammer_Air_Attack_2'
            },
            Priority = 250,
        }
    )
    opai:SetChildQuantity('Bombers', quantity[Difficulty])

    quantity = {8, 12, 16}
    opai = M2CybranBase2:AddOpAI('AirAttacks', 'M2_JammerAirAttack_2_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'Cybran_Jammer_Air_Attack_2'
            },
            Priority = 225,
        }
    )
    opai:SetChildQuantity('Interceptors', quantity[Difficulty])

    quantity = {2, 3, 4}
    opai = M2CybranBase2:AddOpAI('AirAttacks', 'M2_JammerAirAttack_2_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'Cybran_Jammer_Air_Attack_2'
            },
            Priority = 225,
        }
    )
    opai:SetChildQuantity('LightGunships', quantity[Difficulty])
end

function M2_Cybran_Transport_Attacks()
    -- We want this AI to mainly be made up of transport drops.
    local opai = nil
    local trigger = {}

    -- Transport Builder
    opai = M2CybranBase2:AddOpAI('EngineerAttack', 'M2_Cybran_TransportBuilder',
    {
        MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
        PlatoonData = {
            TransportReturn = 'M2_Transport_Return_Marker',
        },
        Priority = 1000,
    })
    opai:SetChildQuantity('T2Transports', 3)
    opai:SetLockingStyle('None')
    opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
        'HaveLessThanUnitsWithCategory', {'default_brain', 3, categories.ura0104})

    -- Tech 1
    opai = M2CybranBase2:AddOpAI('BasicLandAttack', 'M2_CybranTransportAttack1',
    {
        MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
        PlatoonData = {
            AttackChain = 'M2_Cybran_Tran_Attack_Chain',
            LandingChain = 'M2_Cybran_Tran_Land_2_Chain',
            TransportReturn = 'M2_Transport_Return_Marker',
        },
        Priority = 150,
    })
    opai:SetChildQuantity('HeavyBots', 12)

    opai = M2CybranBase2:AddOpAI('BasicLandAttack', 'M2_CybranTransportAttack2',
    {
        MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
        PlatoonData = {
            AttackChain = 'M2_Cybran_Tran_Attack_Chain',
            LandingChain = 'M2_Cybran_Tran_Land_2_Chain',
            TransportReturn = 'M2_Transport_Return_Marker',
        },
        Priority = 200,
    })
    opai:SetChildQuantity('LightBots', 16)

    trigger = {32, 26, 20}
    opai = M2CybranBase2:AddOpAI('BasicLandAttack', 'M2_CybranTransportAttack3',
    {
        MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
        PlatoonData = {
            AttackChain = 'M2_Cybran_Tran_Attack_Chain',
            LandingChain = 'M2_Cybran_Tran_Land_2_Chain',
            TransportReturn = 'M2_Transport_Return_Marker',
        },
        Priority = 175,
    })
    opai:SetChildQuantity('HeavyBots', 16)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.MOBILE, '>='})

    -- Tech 2
    opai = M2CybranBase2:AddOpAI('BasicLandAttack', 'M2_CybranTransportAttack4',
    {
        MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
        PlatoonData = {
            AttackChain = 'M2_Cybran_Tran_Attack_Chain',
            LandingChain = 'M2_Cybran_Tran_Land_2_Chain',
            TransportReturn = 'M2_Transport_Return_Marker',
        },
        Priority = 200,
    })
    opai:SetChildQuantity('HeavyTanks', 8)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, 1, categories.FACTORY * categories.TECH2, '>='})

    opai = M2CybranBase2:AddOpAI('BasicLandAttack', 'M2_CybranTransportAttack5',
    {
        MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
        PlatoonData = {
            AttackChain = 'M2_Cybran_Tran_Attack_Chain',
            LandingChain = 'M2_Cybran_Tran_Land_2_Chain',
            TransportReturn = 'M2_Transport_Return_Marker',
        },
        Priority = 240,
    })
    opai:SetChildQuantity('HeavyTanks', 10)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, 2, categories.FACTORY * categories.TECH2, '>='})

    opai = M2CybranBase2:AddOpAI('BasicLandAttack', 'M2_CybranTransportAttack6',
    {
        MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
        PlatoonData = {
            AttackChain = 'M2_Cybran_Tran_Attack_Chain',
            LandingChain = 'M2_Cybran_Tran_Land_2_Chain',
            TransportReturn = 'M2_Transport_Return_Marker',
        },
        Priority = 245,
    })
    opai:SetChildQuantity('MobileMissiles', 10)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, 2, categories.FACTORY * categories.TECH2, '>='})

    opai = M2CybranBase2:AddOpAI('BasicLandAttack', 'M2_CybranTransportAttack7',
    {
        MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
        PlatoonData = {
            AttackChain = 'M2_Cybran_Tran_Attack_Chain',
            LandingChain = 'M2_Cybran_Tran_Land_2_Chain',
            TransportReturn = 'M2_Transport_Return_Marker',
        },
        Priority = 250,
    })
    opai:SetChildQuantity('MobileFlak', 6)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, 1, categories.FACTORY * categories.TECH2, '>='})

    trigger = {28, 22, 16}
    opai = M2CybranBase2:AddOpAI('BasicLandAttack', 'M2_CybranTransportAttack8',
    {
        MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
        PlatoonData = {
            AttackChain = 'M2_Cybran_Tran_Attack_Chain',
            LandingChain = 'M2_Cybran_Tran_Land_2_Chain',
            TransportReturn = 'M2_Transport_Return_Marker',
        },
        Priority = 175,
    })
    opai:SetChildQuantity('HeavyTanks', 8)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.MOBILE, '>='})
end

function DisableBase()
    if(M2CybranBase2) then
        M2CybranBase2:BaseActive(false)
    end
end

