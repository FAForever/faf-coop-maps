local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/ScenarioPlatoonAI.lua'

---------
-- Locals
---------
local UEF = 2
local Difficulty = ScenarioInfo.Options.Difficulty

----------------
-- Base Managers
----------------
local UEFM2Base = BaseManager.CreateBaseManager()
local UEFM2AirBase = BaseManager.CreateBaseManager()
local UEFM2NavalBase = BaseManager.CreateBaseManager()

--------------
-- UEF M2 Base
--------------
function UEFM2BaseAI()
    UEFM2Base:InitializeDifficultyTables(ArmyBrains[UEF], 'M2_UEF_Base', 'M2_UEF_Base_Marker', 70, {M2_Base = 100})
    UEFM2Base:StartNonZeroBase({{4, 7, 10}, {3, 6, 8}})
    UEFM2Base:SetActive('AirScouting', true)

    UEFM2BaseAirAttacks()
    UEFM2BaseLandAttacks()
    UEFM2BaseNavalAttacks()
end

function UEFM2BaseAirAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    -- Transport builder
    quantity = {2, 2, 3}
    opai = UEFM2Base:AddOpAI('EngineerAttack', 'M2_UEF_TransportBuilder',
        {
            MasterPlatoonFunction = {SPAIFileName, 'LandAssaultWithTransports'},
            PlatoonData = {
                TransportReturn = 'M2_UEF_Transport_Return',
            },
            Priority = 1000,
        }
    )
    opai:SetChildQuantity('T1Transports', quantity[Difficulty])
    opai:SetLockingStyle('None')
    opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
        'HaveLessThanUnitsWithCategory', {'default_brain', 3, categories.uea0107})

    ----------
    -- Attacks
    ----------
    quantity = {2, 2, 3}
    opai = UEFM2Base:AddOpAI('AirAttacks', 'M2_UEF_Air_Attack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M2_UEF_Air_Attack_Chain_1',
                    'M2_UEF_Air_Attack_Chain_2',
                    'M2_UEF_Air_Attack_Chain_3',
                },
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Bombers', quantity[Difficulty])
    opai:SetLockingStyle('None')
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, 30, categories.ALLUNITS - categories.WALL, '>='})

    quantity = {2, 4, 6}
    trigger = {6, 8, 10}
    opai = UEFM2Base:AddOpAI('AirAttacks', 'M2_UEF_Air_Attack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M2_UEF_Air_Attack_Chain_1',
                    'M2_UEF_Air_Attack_Chain_2',
                    'M2_UEF_Air_Attack_Chain_3',
                },
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Interceptors', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE, '>='})

    quantity = {2, 4, 6}
    trigger = {44, 52, 60}
    opai = UEFM2Base:AddOpAI('AirAttacks', 'M2_UEF_Air_Attack_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M2_UEF_Air_Attack_Chain_1',
                    'M2_UEF_Air_Attack_Chain_2',
                    'M2_UEF_Air_Attack_Chain_3',
                },
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Bombers', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL, '>='})

    quantity = {3, 4, 6}
    trigger = {12, 14, 16}
    opai = UEFM2Base:AddOpAI('AirAttacks', 'M2_UEF_Air_Attack_4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M2_UEF_Air_Attack_Chain_1',
                    'M2_UEF_Air_Attack_Chain_2',
                    'M2_UEF_Air_Attack_Chain_3',
                },
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Interceptors', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE, '>='})

    quantity = {3, 6, 9}
    trigger = {80, 90, 100}
    opai = UEFM2Base:AddOpAI('AirAttacks', 'M2_UEF_Air_Attack_5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M2_UEF_Air_Attack_Chain_1',
                    'M2_UEF_Air_Attack_Chain_2',
                    'M2_UEF_Air_Attack_Chain_3',
                },
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('Bombers', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL, '>='})

    ----------
    -- Patrols
    ----------
    local groups = {1, 2, 2}
    for i = 1, groups[Difficulty] do
        quantity = {2, 2 ,3}
        opai = UEFM2Base:AddOpAI('AirAttacks', 'M2_UEF_AirDefense_1_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M2_UEF_Base_Air_Patrol_Chain',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('Bombers', quantity[Difficulty])
        opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
        opai:SetFormation('NoFormation')
    end

    for i = 1, 2 do
        quantity = {2, 2 ,3}
        opai = UEFM2Base:AddOpAI('AirAttacks', 'M2_UEF_AirDefense_2_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M2_UEF_Base_Air_Patrol_Chain',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('Interceptors', quantity[Difficulty])
        opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
        opai:SetFormation('NoFormation')
    end
end

function UEFM2BaseLandAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    -------------
    -- Amphibious
    -------------
    if Difficulty >= 2 then
        quantity = {0, 2, 4}
        trigger = {0, 40, 30}
        opai = UEFM2Base:AddOpAI('BasicLandAttack', 'M2_UEF_Amphibious_Attack',
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
                PlatoonData = {
                    PatrolChains = {
                        'M2_UEF_Naval_Attack_Chain',
                        'M2_UEF_Amphibious_Attack_Chain',
                    },
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('AmphibiousTanks', quantity[Difficulty])
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
            'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], ((categories.LAND + categories.NAVAL) * categories.MOBILE) - categories.ENGINEER, '>='})
    end

    -- Patrol in the Air base
    quantity = {2, 4, 6}
    opai = UEFM2Base:AddOpAI('BasicLandAttack', 'M2_UEF_Air_Base_Atry_Patrol',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_UEF_Air_Base_Arty_Patrol_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('LightArtillery', quantity[Difficulty])
    opai:SetFormation('NoFormation')

    --------
    -- Drops
    --------
    --[[ -- Broken drops
    quantity = {6, 6, 12}
    trigger = {90, 70, 50}
    opai = UEFM2Base:AddOpAI('BasicLandAttack', 'M2_UEF_TransportAttack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain = 'M2_UEF_Transport_Attack_Chain',
                LandingChain = 'M2_UEF_Landing_Chain',
                MovePath = 'M2_UEF_Transport_Move_Chain',
                TransportReturn = 'M2_UEF_Transport_Return', -- Removed until transport return function is fixed
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('LightTanks', quantity[Difficulty])
    opai:SetLockingStyle('DeathTimer', {LockTimer = 120})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL, '>='})

    quantity = {6, 12, 18}
    trigger = {120, 100, 80}
    opai = UEFM2Base:AddOpAI('BasicLandAttack', 'M2_UEF_TransportAttack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'LandAssaultWithTransports'},
            PlatoonData = {
                AttackChain = 'M2_UEF_Transport_Attack_Chain',
                LandingChain = 'M2_UEF_Landing_Chain',
                MovePath = 'M2_UEF_Transport_Move_Chain',
                TransportReturn = 'M2_UEF_Transport_Return', -- Removed until transport return function is fixed
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('LightArtillery', quantity[Difficulty])
    opai:SetLockingStyle('DeathTimer', {LockTimer = 180})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL, '>='})
    --]]

    quantity = {1, 1, 2}
    trigger = {40, 30, 20}
    for i = 1, quantity[Difficulty] do
        opai = UEFM2Base:AddOpAI('BasicLandAttack', 'M2_UEF_TransportAttack_1_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'LandAssaultWithTransports'},
                PlatoonData = {
                    AttackChain = 'M2_UEF_Transport_Attack_Chain',
                    LandingChain = 'M2_UEF_Landing_Chain',
                    MovePath = 'M2_UEF_Transport_Move_Chain',
                    TransportReturn = 'M2_UEF_Transport_Return',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('LightTanks', 6)
        opai:SetLockingStyle('DeathTimer', {LockTimer = 120})
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
            'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty] + i * 10, categories.ALLUNITS - categories.WALL, '>='})
    end

    trigger = {60, 50, 40}
    for i = 1, Difficulty do
        opai = UEFM2Base:AddOpAI('BasicLandAttack', 'M2_UEF_TransportAttack_2_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'LandAssaultWithTransports'},
                PlatoonData = {
                    AttackChain = 'M2_UEF_Transport_Attack_Chain',
                    LandingChain = 'M2_UEF_Landing_Chain',
                    MovePath = 'M2_UEF_Transport_Move_Chain',
                    TransportReturn = 'M2_UEF_Transport_Return',
                },
                Priority = 110,
            }
        )
        opai:SetChildQuantity('LightArtillery', 6)
        opai:SetLockingStyle('DeathTimer', {LockTimer = 180})
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
            'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty] + i * 10, categories.ALLUNITS - categories.WALL, '>='})
    end
end

function UEFM2BaseNavalAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    quantity = {2, 2, 3}
    opai = UEFM2Base:AddOpAI('NavalAttacks', 'M2_UEF_NavalAttack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_UEF_Naval_Attack_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Frigates', quantity[Difficulty])

    quantity = {2, 2, 3}
    trigger = {4, 3, 2}
    opai = UEFM2Base:AddOpAI('NavalAttacks', 'M2_UEF_NavalAttack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_UEF_Naval_Attack_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Submarines', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE, '>='})

    quantity = {2, 2, 3}
    trigger = {40, 30, 20}
    opai = UEFM2Base:AddOpAI('NavalAttacks', 'M2_UEF_NavalAttack_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_UEF_Naval_Attack_Chain',
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Frigates', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.LAND * categories.MOBILE - categories.ENGINEER, '>='})

    quantity = {2, 2, 3}
    trigger = {8, 6, 4}
    opai = UEFM2Base:AddOpAI('NavalAttacks', 'M2_UEF_NavalAttack_4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_UEF_Naval_Attack_Chain',
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Submarines', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE, '>='})

    quantity = {2, 2, 3}
    trigger = {10, 8, 6}
    opai = UEFM2Base:AddOpAI('NavalAttacks', 'M2_UEF_NavalAttack_5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_UEF_Naval_Attack_Chain',
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('Frigates', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE, '>='})
end

------------------
-- UEF M2 Air Base
------------------
function UEFM2AirBaseAI()
    UEFM2AirBase:Initialize(ArmyBrains[UEF], 'M2_UEF_Air_Base', 'M2_UEF_Air_Base_Marker', 30, {M2_Air_Base = 100})
    UEFM2AirBase:StartEmptyBase({1, 1, 2})

    UEFM2Base:AddExpansionBase('M2_UEF_Air_Base', 1)

    UEFM2AirBaseAirAttacks()
end

function UEFM2AirBaseAirAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    ----------
    -- Attacks
    ----------
    opai = UEFM2AirBase:AddOpAI('AirAttacks', 'M2_UEF_Air_Base_Air_Attack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'SplitPatrolThread'},
            PlatoonData = {
                PatrolChains = {
                    'M2_UEF_Short_Air_Attack_Chain_1',
                    'M2_UEF_Short_Air_Attack_Chain_2',
                },
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Bombers', 4)

    trigger = {12, 10, 8}
    opai = UEFM2AirBase:AddOpAI('AirAttacks', 'M2_UEF_Air_Base_Air_Attack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M2_UEF_Short_Air_Attack_Chain_1',
                    'M2_UEF_Short_Air_Attack_Chain_2',
                },
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Interceptors', 4)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE, '>='})

    quantity = {4, 4, 6}
    trigger = {240, 220, 200}
    opai = UEFM2AirBase:AddOpAI('AirAttacks', 'M2_UEF_Air_Base_Air_Attack_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M2_UEF_Short_Air_Attack_Chain_1',
                    'M2_UEF_Short_Air_Attack_Chain_2',
                },
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Bombers', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL, '>='})
end

--------------------
-- UEF M2 Naval Base
--------------------
function UEFM2NavalBaseAI()
    UEFM2NavalBase:Initialize(ArmyBrains[UEF], 'M2_UEF_Naval_Base', 'M2_UEF_Naval_Base_Marker', 30, {M2_Middle_Naval_Base = 100})
    UEFM2NavalBase:StartEmptyBase({1, 1, 2})

    UEFM2Base:AddExpansionBase('M2_UEF_Naval_Base', 1)

    UEFM2NavalBaseNavalAttacks()
end

function UEFM2NavalBaseNavalAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    opai = UEFM2NavalBase:AddOpAI('NavalAttacks', 'M2_UEF_Naval_Base_NavalAttack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_UEF_Short_Naval_Attack_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Frigates', 2)

    opai = UEFM2NavalBase:AddOpAI('NavalAttacks', 'M2_UEF_Naval_Base_NavalAttack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_UEF_Short_Naval_Attack_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Submarines', 2)
end

-- TODO: Rebuild the defense lines with engineer platoon
function BuildThread()
    local locations = {
        'M2_Middle_Pass_Defense_D' .. Difficulty,
        'M2_West_Island_Defense_D' .. Difficulty,
    }
end