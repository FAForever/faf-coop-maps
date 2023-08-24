local BaseManager = import('/lua/ai/opai/basemanager.lua')
local CustomFunctions = '/maps/FAF_Coop_Operation_Trident/FAF_Coop_Operation_Trident_CustomFunctions.lua'
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local SPAIFileName = '/lua/ScenarioPlatoonAI.lua'

---------
-- Locals
---------
local UEF = 3
local Difficulty = ScenarioInfo.Options.Difficulty

----------------
-- Base Managers
----------------
local M1UEFShoreBase = BaseManager.CreateBaseManager()
local M1UEFCityBase = BaseManager.CreateBaseManager()
local M2UEFAtlantisBase = BaseManager.CreateBaseManager()

--------------------
-- M1 UEF Shore Base
--------------------
function M1UEFShoreBaseAI()
    M1UEFShoreBase:InitializeDifficultyTables(ArmyBrains[UEF], 'M1_UEF_Shore_Base', 'M1_UEF_Shore_Base_Marker', 80, {Shore_Base = 100})
    M1UEFShoreBase:StartNonZeroBase({{2, 3, 4}, {2, 2, 3}})

    M1UEFShoreBaseAirAttacks()
    M1UEFShoreBaseLandAttacks()
    M1UEFShoreBaseNavalAttacks()
end

function M1UEFShoreBaseAirAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    opai = M1UEFShoreBase:AddOpAI('AirAttacks', 'M1_UEF_AirDefense_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M1_UEF_Shore_Base_Air_Patrol_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Interceptors', 6)
    opai:SetFormation('NoFormation')
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})

    opai = M1UEFShoreBase:AddOpAI('AirAttacks', 'M1_UEF_AirDefense_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M1_UEF_Shore_Base_Air_Patrol_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Bombers', 6)
    opai:SetFormation('NoFormation')
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
end

function M1UEFShoreBaseLandAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    opai = M1UEFShoreBase:AddOpAI('BasicLandAttack', 'M1_UEF_Land_Attack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M1_UEF_Land_Attack_Chain_Players',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'HeavyTanks', 'LightTanks'}, 8)

    opai = M1UEFShoreBase:AddOpAI('BasicLandAttack', 'M1_UEF_Land_Attack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M1_UEF_Land_Attack_Chain_Players',
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'RangeBots', 'LightArtillery'}, 8)

    --[[
    ArmyBrains[UEF]:PBMAddPlatoon(
        {
            BuilderName = 'M1_UEF_Mongoose_Builder',
            PlatoonTemplate = {
                'Mongoose',
                'NoPlan',
                {'del0204', 1, 4, 'Attack', 'AttackFormation'}, -- Mongoose
                {'uel0103', 1, 4, 'Attack', 'AttackFormation'}, -- T1 Arty
            },
            Priority = 110,
            PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},
            BuildConditions = {
                {'/lua/editor/BaseManagerBuildConditions.lua', 'BaseActive', {'M1_UEF_Shore_Base'}},
            },
            PlatoonData = {
                PatrolChain = 'M1_UEF_Land_Attack_Chain_Players',
            },
            PlatoonType = 'Land',
            RequiresConstruction = true,
            LocationType = 'M1_UEF_Shore_Base',
        }
    )
    --]]
end

function M1UEFShoreBaseNavalAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    opai = M1UEFShoreBase:AddOpAI('NavalAttacks', 'M1_UEF_NavalPatrol_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M1_UEF_Shore_Base_Naval_Patrol_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Submarines', 4)
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})

    opai = M1UEFShoreBase:AddOpAI('NavalAttacks', 'M1_UEF_NavalPatrol_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M1_UEF_Shore_Base_Naval_Patrol_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Frigates', 4)
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
end

-------------------
-- M1 UEF City Base
-------------------
function M1UEFCityBaseAI()
    M1UEFCityBase:InitializeDifficultyTables(ArmyBrains[UEF], 'M1_UEF_City_Base', 'M1_UEF_City_Base_Marker', 35, {City_Base = 100})
    M1UEFCityBase:StartNonZeroBase({3, 2, 2})

    M1UEFCityBaseSparkyPlatoon()
end

function M1UEFCityBaseSparkyPlatoon()
    -- Makes the base use Sparkies for maintaining the base
    ArmyBrains[UEF]:PBMAddPlatoon(
        {
            BuilderName = 'T2BaseManaqer_SparkyEngineersWork_M1_UEF_City_Base',
            PlatoonTemplate = {
                'EngineerThing',
                'NoPlan',
                {'xel0209', 1, 2, 'Support', 'None'},
            },
            Priority = 1,
            PlatoonAIFunction = {'/lua/ai/opai/BaseManagerPlatoonThreads.lua', 'BaseManagerEngineerPlatoonSplit'},
            BuildConditions = {
                {'/lua/editor/BaseManagerBuildConditions.lua', 'BaseManagerNeedsEngineers', {'M1_UEF_City_Base'}},
                {'/lua/editor/BaseManagerBuildConditions.lua', 'BaseActive', {'M1_UEF_City_Base'}},
            },
            PlatoonData = {
                BaseName = 'M1_UEF_City_Base',
            },
            PlatoonType = 'Any',
            RequiresConstruction = false,
            LocationType = 'M1_UEF_City_Base',
        }
    )
end

-----------------------
-- M2 UEF Atlantis Base
-----------------------
function M2UEFAtlantisBaseAI()
    M2UEFAtlantisBase:InitializeDifficultyTables(ArmyBrains[UEF], 'M2_UEF_Sea_Base', 'M2_UEF_Sea_Base_Marker', 80, {Sea_Base = 100})
    M2UEFAtlantisBase:StartNonZeroBase({{6, 8, 10}, {5, 7, 8}})

    M2UEFAtlantisBaseAirAttacks()
    M2UEFAtlantisBaseNavalAttacks()

    ForkThread(
        function()
            -- Wait for the carrier to be spawned
            WaitSeconds(1)

            -- Mark it as a primary factory so it produces air units
            local carrier = ScenarioInfo.M2Atlantis
            local factory = carrier.ExternalFactory

            for _, location in ArmyBrains[UEF].PBM.Locations do
                if location.LocationType == 'M2_UEF_Sea_Base' then
                    location.PrimaryFactories.Air = factory
                    break
                end
            end
            
            -- Gotta release the units once the platoon is built
            carrier.ReleaseUnitsThread = carrier:ForkThread(function(self)
                local factory = self.ExternalFactory

                while true do
                    if table.getn(self:GetCargo()) > 0 and factory:IsIdleState() then
                        IssueClearCommands({self})
                        IssueTransportUnload({self}, ScenarioUtils.MarkerToPosition('Rally Point 06'))
    
                        repeat
                            WaitSeconds(3)
                        until not self:IsUnitState("TransportUnloading")
                    end

                    WaitSeconds(1)
                end
            end)
        end
    )
end

function M2UEFAtlantisBaseAirAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    ----------
    -- Attacks
    ----------
    quantity = {8, 12, 16}
    opai = M2UEFAtlantisBase:AddOpAI('AirAttacks', 'M2_UEF_AirAttack_1',
        {
            MasterPlatoonFunction = {CustomFunctions, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_UEF_Naval_Attack_Cybran_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Bombers', quantity[Difficulty])

    quantity = {8, 10, 12}
    opai = M2UEFAtlantisBase:AddOpAI('AirAttacks', 'M2_UEF_AirAttack_2',
        {
            MasterPlatoonFunction = {CustomFunctions, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_UEF_Naval_Attack_Cybran_Chain',
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])

    quantity = {8, 10, 12}
    opai = M2UEFAtlantisBase:AddOpAI('AirAttacks', 'M2_UEF_AirAttack_3',
        {
            MasterPlatoonFunction = {CustomFunctions, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_UEF_Naval_Attack_Cybran_Chain',
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('TorpedoBombers', quantity[Difficulty])

    ----------
    -- Patrols
    ----------
    quantity = {3, 4, 5}
    for i = 1, 2 do
        opai = M2UEFAtlantisBase:AddOpAI('AirAttacks', 'M2_UEF_AirDefense_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M2_UEF_Air_Patrol_Chain',
                },
                Priority = 90,
            }
        )
        opai:SetChildQuantity('TorpedoBombers', quantity[Difficulty])
        opai:SetFormation('NoFormation')
        opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    end

    quantity = {3, 4, 5}
    for i = 3, 4 do
        opai = M2UEFAtlantisBase:AddOpAI('AirAttacks', 'M2_UEF_AirDefense_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M2_UEF_Air_Patrol_Chain',
                },
                Priority = 90,
            }
        )
        opai:SetChildQuantity('CombatFighters', quantity[Difficulty])
        opai:SetFormation('NoFormation')
        opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    end

    opai = M2UEFAtlantisBase:AddOpAI('AirAttacks', 'M2_UEF_AirDefense_5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_UEF_Air_Patrol_Chain',
            },
            Priority = 90,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    opai:SetFormation('NoFormation')
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
end

function M2UEFAtlantisBaseNavalAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    ----------
    -- Attacks
    ----------
    -- Attack the Aeon base once in a while
    --opai = M2UEFAtlantisBase:AddOpAI('NavalAttacks', 'M2_UEF_NavalAttack_Aeon_1',
    --    {
    --        MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
    --        PlatoonData = {
    --            PatrolChain = 'M2_UEF_Naval_Attack_Aeon_Chain',
    --        },
    --        Priority = 200,
    --    }
    --)
    --opai:SetChildQuantity({'Destroyers', 'Frigates', 'Submarines'}, {4, 4, 4})
    --opai:SetLockingStyle('DeathTimer', {LockTimer = 360})

    opai = M2UEFAtlantisBase:AddOpAI('NavalAttacks', 'M2_UEF_NavalAttack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M2_UEF_Naval_Attack_Player_Chain',
                    'M2_UEF_Naval_Attack_Player_Chain',
                    'M2_UEF_Naval_Attack_Cybran_Chain',
                },
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'Frigates', 'Submarines'}, {2, 2})

    quantity = {{3, 3}, {3, 3}, {4, 4}}
    opai = M2UEFAtlantisBase:AddOpAI('NavalAttacks', 'M2_UEF_NavalAttack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M2_UEF_Naval_Attack_Player_Chain',
                    'M2_UEF_Naval_Attack_Player_Chain',
                    'M2_UEF_Naval_Attack_Cybran_Chain',
                },
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'Frigates', 'Submarines'}, quantity[Difficulty])
    opai:SetFormation('AttackFormation')
    
    quantity = {4, 6, 8}
    trigger = {16, 14, 12}
    opai = M2UEFAtlantisBase:AddOpAI('NavalAttacks', 'M2_UEF_NavalAttack_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M2_UEF_Naval_Attack_Player_Chain',
                    'M2_UEF_Naval_Attack_Player_Chain',
                    'M2_UEF_Naval_Attack_Cybran_Chain',
                },
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Submarines', quantity[Difficulty])
    opai:SetFormation('AttackFormation')
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers', 'Cybran'}, trigger[Difficulty], categories.T1SUBMARINE, '>='})

    quantity = {6, 8, 12}
    trigger = {22, 20, 18}
    opai = M2UEFAtlantisBase:AddOpAI('NavalAttacks', 'M2_UEF_NavalAttack_4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M2_UEF_Naval_Attack_Player_Chain',
                    'M2_UEF_Naval_Attack_Player_Chain',
                    'M2_UEF_Naval_Attack_Cybran_Chain',
                },
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('Submarines', quantity[Difficulty])
    opai:SetFormation('AttackFormation')
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers', 'Cybran'}, trigger[Difficulty], categories.T1SUBMARINE, '>='})

    quantity = {4, 6, 8}
    trigger = {18, 16, 14}
    opai = M2UEFAtlantisBase:AddOpAI('NavalAttacks', 'M2_UEF_NavalAttack_5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M2_UEF_Naval_Attack_Player_Chain',
                    'M2_UEF_Naval_Attack_Player_Chain',
                    'M2_UEF_Naval_Attack_Cybran_Chain',
                },
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Frigates', quantity[Difficulty])
    opai:SetFormation('AttackFormation')
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers', 'Cybran'}, trigger[Difficulty], categories.NAVAL *  categories.MOBILE, '>='})

    quantity = {2, 3, 4}
    trigger = {9, 8, 7}
    opai = M2UEFAtlantisBase:AddOpAI('NavalAttacks', 'M2_UEF_NavalAttack_6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M2_UEF_Naval_Attack_Player_Chain',
                    'M2_UEF_Naval_Attack_Player_Chain',
                    'M2_UEF_Naval_Attack_Cybran_Chain',
                },
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('TorpedoBoats', quantity[Difficulty])
    opai:SetFormation('AttackFormation')
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers', 'Cybran'}, trigger[Difficulty], categories.T2SUBMARINE, '>='})

    quantity = {4, 6, 8}
    trigger = {22, 21, 20}
    opai = M2UEFAtlantisBase:AddOpAI('NavalAttacks', 'M2_UEF_NavalAttack_7',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M2_UEF_Naval_Attack_Player_Chain',
                    'M2_UEF_Naval_Attack_Player_Chain',
                    'M2_UEF_Naval_Attack_Cybran_Chain',
                },
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('TorpedoBoats', quantity[Difficulty])
    opai:SetFormation('AttackFormation')
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers', 'Cybran'}, trigger[Difficulty], categories.T2SUBMARINE, '>='})

    quantity = {{2, 2}, {2, 1, 3}, {3, 1, 4}}
    trigger = {12, 10, 8}
    opai = M2UEFAtlantisBase:AddOpAI('NavalAttacks', 'M2_UEF_NavalAttack_8',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M2_UEF_Naval_Attack_Player_Chain',
                    'M2_UEF_Naval_Attack_Player_Chain',
                    'M2_UEF_Naval_Attack_Cybran_Chain',
                },
            },
            Priority = 120,
        }
    )
    if Difficulty == 1 then
        opai:SetChildQuantity({'Destroyers', 'Frigates'}, quantity[Difficulty])
    else
        opai:SetChildQuantity({'Destroyers', 'Cruisers', 'Frigates'}, quantity[Difficulty])
    end
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers', 'Cybran'}, trigger[Difficulty], categories.TECH2 * categories.NAVAL * categories.MOBILE, '>='})

    quantity = {2, {2, 1}, {3, 1}}
    trigger = {60, 50, 40}
    opai = M2UEFAtlantisBase:AddOpAI('NavalAttacks', 'M2_UEF_NavalAttack_9',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M2_UEF_Naval_Attack_Player_Chain',
                    'M2_UEF_Naval_Attack_Player_Chain',
                    'M2_UEF_Naval_Attack_Cybran_Chain',
                },
            },
            Priority = 120,
        }
    )
    if Difficulty == 1 then
        opai:SetChildQuantity('Cruisers', quantity[Difficulty])
    else
        opai:SetChildQuantity({'Cruisers', 'UtilityBoats'}, quantity[Difficulty])
    end
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers', 'Cybran'}, trigger[Difficulty], categories.AIR * categories.MOBILE, '>='})

    -- Extra cruisers with shield boats if there's a lot of T2 Bombers
    quantity = {2, {2, 2}, {3, 2}}
    trigger = {60, 50, 40}
    opai = M2UEFAtlantisBase:AddOpAI('NavalAttacks', 'M2_UEF_NavalAttack_10',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M2_UEF_Naval_Attack_Player_Chain',
                    'M2_UEF_Naval_Attack_Player_Chain',
                    'M2_UEF_Naval_Attack_Cybran_Chain',
                },
            },
            Priority = 130,
        }
    )
    if Difficulty == 1 then
        opai:SetChildQuantity('Cruisers', quantity[Difficulty])
    else
        opai:SetChildQuantity({'Cruisers', 'UtilityBoats'}, quantity[Difficulty])
    end
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers', 'Cybran'}, trigger[Difficulty], categories.TECH2 * categories.BOMBER * categories.AIR * categories.MOBILE, '>='})

    quantity = {{3, 1, 2, 2}, {4, 1, 3, 3}, {5, 1, 2, 2}}
    trigger = {14, 12, 10}
    opai = M2UEFAtlantisBase:AddOpAI('NavalAttacks', 'M2_UEF_NavalAttack_11',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M2_UEF_Naval_Attack_Player_Chain',
                    'M2_UEF_Naval_Attack_Player_Chain',
                    'M2_UEF_Naval_Attack_Cybran_Chain',
                },
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity({'Destroyers', 'Cruisers', 'Frigates', 'Submarines'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers', 'Cybran'}, trigger[Difficulty], categories.TECH2 * categories.NAVAL * categories.MOBILE, '>='})

    ----------
    -- Patrols
    ----------
    opai = M2UEFAtlantisBase:AddOpAI('NavalAttacks', 'M2_UEF_NavalDefense_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_UEF_Naval_Defense_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Destroyers', 4)
    opai:SetFormation('NoFormation')

    opai = M2UEFAtlantisBase:AddOpAI('NavalAttacks', 'M2_UEF_NavalDefense_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_UEF_Naval_Defense_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Frigates', 4)
    opai:SetFormation('NoFormation')
end