local BaseManager = import('/lua/ai/opai/basemanager.lua')
local CustomFunctions = '/maps/SCCA_Coop_A06/SCCA_Coop_A06_CustomFunctions.lua'
local SPAIFileName = '/lua/scenarioplatoonai.lua'

---------
-- Locals
---------
local Aeon = 4
local Difficulty = ScenarioInfo.Options.Difficulty

----------------
-- Base Managers
----------------
local AeonM3BlackSunBase = BaseManager.CreateBaseManager()
local AeonM3IslandBase = BaseManager.CreateBaseManager()
local AeonM3BlackSunNavalBase = BaseManager.CreateBaseManager()
local AeonM3SouthWestBase = BaseManager.CreateBaseManager()
local AeonM3SouthEastBase = BaseManager.CreateBaseManager()

-------------------------
-- Aeon M3 Black Sun Base
-------------------------
function AeonM3BlackSunBaseAI()
    AeonM3BlackSunBase:InitializeDifficultyTables(ArmyBrains[Aeon], 'M3_Aeon_Base', 'M3_Aeon_Base_Marker', 60, {M3_Black_Sun_Base = 100})
    AeonM3BlackSunBase:StartNonZeroBase({{2, 4, 6}, {1, 3, 4}})
    AeonM3BlackSunBase:SetActive('AirScouting', true)
    AeonM3BlackSunBase:SetActive('LandScouting', true)

    -- AeonM3BlackSunBase:AddReactiveAI('ExperimentalLand', 'AirRetaliation', 'AeonM3BlackSunBase_ExperimentalLand')
    -- AeonM3BlackSunBase:AddReactiveAI('ExperimentalAir', 'AirRetaliation', 'AeonM3BlackSunBase_ExperimentalAir')
    -- AeonM3BlackSunBase:AddReactiveAI('ExperimentalNaval', 'AirRetaliation', 'AeonM3BlackSunBase_ExperimentalNaval')
    -- AeonM3BlackSunBase:AddReactiveAI('Nuke', 'AirRetaliation', 'AeonM3BlackSunBase_Nuke')
    -- AeonM3BlackSunBase:AddReactiveAI('HLRA', 'AirRetaliation', 'AeonM3BlackSunBase_HLRA')

    AeonM3BlackSunBaseAirAttacks()
    AeonM3BlackSunBaseLandAttacks()
end

function AeonM3BlackSunBaseAirAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    -- Transport builder, maintain 8 transports
    --opai = AeonM3BlackSunBase:AddOpAI('EngineerAttack', 'M3_TransportBuilder',
    --    {
    --        MasterPlatoonFunction = {SPAIFileName, 'TransportPool'},
    --        PlatoonData = {
    --            TransportMoveLocation = 'M3_Aeon_Base_Marker',
    --        },
    --        Priority = 1000,
    --    }
    --)
    --opai:SetChildQuantity('T2Transports', 4)
    --opai:SetLockingStyle('None')
    --opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
    --    'HaveLessThanUnitsWithCategory', {'default_brain', 8, categories.uaa0104})

    quantity = {8, 12, 16}
    opai = AeonM3BlackSunBase:AddOpAI('AirAttacks', 'M3_Aeon_Base_AirAttack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M3_Aeon_Naval_Attack_Chain',
                    'M3_Land_Attack_Chain_2',
                    'M1_UEF_Naval_Attack_Chain_2',
                },
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])

    opai = AeonM3BlackSunBase:AddOpAI('AirAttacks', 'M3_Aeon_Base_AirAttack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M3_Aeon_Naval_Attack_Chain',
                    'M3_Land_Attack_Chain_2',
                    'M1_UEF_Naval_Attack_Chain_2',
                },
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('StratBombers', 4)

    quantity = {6, 9, 12}
    trigger = {10, 11, 12}
    opai = AeonM3BlackSunBase:AddOpAI('AirAttacks', 'M3_Aeon_Base_AirAttack_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M3_Aeon_Naval_Attack_Chain',
                    'M3_Land_Attack_Chain_2',
                    'M1_UEF_Naval_Attack_Chain_2',
                },
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE, '>='})
end

function AeonM3BlackSunBaseLandAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    -- Attack Control Center
    quantity = {8, 10, 12}
    opai = AeonM3BlackSunBase:AddOpAI('BasicLandAttack', 'M3_Aeon_LandAttack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M3_Land_Attack_Chain_1',
                    'M3_Land_Attack_Chain_2',
                    'M3_Land_Attack_Chain_3',
                },
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('HeavyTanks', quantity[Difficulty])
    opai:SetFormation('AttackFormation')

    quantity = {6, 9, 12}
    opai = AeonM3BlackSunBase:AddOpAI('BasicLandAttack', 'M3_Aeon_LandAttack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M3_Land_Attack_Chain_1',
                    'M3_Land_Attack_Chain_2',
                    'M3_Land_Attack_Chain_3',
                },
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('MobileMissiles', quantity[Difficulty])
    opai:SetFormation('AttackFormation')
    
    quantity = {4, 6, 10}
    opai = AeonM3BlackSunBase:AddOpAI('BasicLandAttack', 'M3_Aeon_LandAttack_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M3_Land_Attack_Chain_1',
                    'M3_Land_Attack_Chain_2',
                    'M3_Land_Attack_Chain_3',
                },
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('SiegeBots', quantity[Difficulty])
    opai:SetFormation('AttackFormation')

    quantity = {4, 6, 8}
    opai = AeonM3BlackSunBase:AddOpAI('BasicLandAttack', 'M3_Aeon_LandAttack_4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M3_Land_Attack_Chain_1',
                    'M3_Land_Attack_Chain_2',
                    'M3_Land_Attack_Chain_3',
                },
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('HeavyMobileArtillery', quantity[Difficulty])
    opai:SetFormation('AttackFormation')

    --------
    -- Drops
    --------
    --quantity = {6, 8, 12}
    --for i = 1, 2 do
    --    opai = AeonM3BlackSunBase:AddOpAI('BasicLandAttack', 'M3_Aeon_Drop_1_' .. i,
    --        {
    --            MasterPlatoonFunction = {SPAIFileName, 'LandAssaultWithTransports'},
    --            PlatoonData = {
    --                AttackChain = 'Player_Base_Chain',
    --                MovePath = 'M3_Aeon_Drop_Move_Chain_' .. i,
    --                LandingChain = 'Player_Base_Landing_Chain',
    --                TransportReturn = 'M3_Aeon_Base_Marker',
    --            },
    --            Priority = 200,
    --        }
    --    )
    --    opai:SetChildQuantity('SiegeBots', quantity[Difficulty])
    --    opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
    --        'HaveGreaterThanUnitsWithCategory', {'default_brain', math.ceil(quantity[Difficulty] / 3), categories.uaa0104})
    --    opai:SetLockingStyle('DeathTimer', {LockTimer = 240})
    --end
end

-------------------------------
-- Aeon M3 Black Sun Naval Base
-------------------------------
function AeonM3BlackSunNavalBaseAI()
    AeonM3BlackSunNavalBase:InitializeDifficultyTables(ArmyBrains[Aeon], 'M3_Aeon_Naval_Base', 'M3_Aeon_Naval_Base_Marker', 70, {M3_Naval_Base = 100})
    AeonM3BlackSunNavalBase:StartNonZeroBase({{1, 2, 3}, {1, 2, 2}})

    AeonM3BlackSunNavalBaseNavalAttacks()
end

function AeonM3BlackSunNavalBaseNavalAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    quantity = {{3, 3}, {6, 3}, {12, 6}}
    opai = AeonM3BlackSunNavalBase:AddOpAI('NavalAttacks', 'M3_Main_Base_NavalAttack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M3_Main_Base_Naval_Patrol_Chain',
                    'M3_Aeon_Naval_Attack_Chain',
                },
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'Frigates', 'Submarines'}, quantity[Difficulty])
    opai:SetFormation("AttackFormation")

    opai = AeonM3BlackSunNavalBase:AddOpAI('NavalAttacks', 'M3_Main_Base_NavalAttack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M3_Main_Base_Naval_Patrol_Chain',
                    'M3_Aeon_Naval_Attack_Chain',
                },
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'Destroyers', 'Frigates'}, {3, 6})
    opai:SetFormation("AttackFormation")

    quantity = {{2, 1}, {3, 1, 4}, {4, 2, 6}}
    opai = AeonM3BlackSunNavalBase:AddOpAI('NavalAttacks', 'M3_Main_Base_NavalAttack_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M3_Main_Base_Naval_Patrol_Chain',
                    'M3_Aeon_Naval_Attack_Chain',
                },
            },
            Priority = 120,
        }
    )
    if Difficulty >= 2 then
        opai:SetChildQuantity({'Destroyers', 'Cruisers', 'Submarines'}, quantity[Difficulty])
    else
        opai:SetChildQuantity({'Destroyers', 'Cruisers'}, quantity[Difficulty])
    end
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, 3, categories.NAVAL * categories.MOBILE - categories.TECH1, '>='})

    if Difficulty >= 2 then
        opai = AeonM3BlackSunNavalBase:AddOpAI('NavalAttacks', 'M3_Main_Base_NavalAttack_4',
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
                PlatoonData = {
                    PatrolChains = {
                        'M3_Main_Base_Naval_Patrol_Chain',
                        'M3_Aeon_Naval_Attack_Chain',
                    },
                },
                Priority = 130,
            }
        )
        opai:SetChildQuantity({'Battleships', 'Destroyers'}, {1, 4})
        opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
            'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, 6, categories.NAVAL * categories.MOBILE - categories.TECH1, '>='})
    end

    quantity = {{2, 1}, {4, 2}, {7, 2}}
    opai = AeonM3BlackSunNavalBase:AddOpAI('NavalAttacks', 'M3_Main_Base_NavalAttack_5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M3_Main_Base_Naval_Patrol_Chain',
                    'M3_Aeon_Naval_Attack_Chain',
                },
            },
            Priority = 140,
        }
    )
    opai:SetChildQuantity({'Destroyers', 'Cruisers'}, quantity[Difficulty])
    opai:SetFormation("AttackFormation")
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, 12, categories.NAVAL * categories.MOBILE - categories.TECH1, '>='})
    --[[
    opai = AeonM3BlackSunNavalBase:AddOpAI('NavalAttacks', 'M3_Main_Base_NavalAttack_6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M3_Main_Base_Naval_Patrol_Chain',
                    'M3_Aeon_Naval_Attack_Chain',
                },
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity('Battleships', 3)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, 2, categories.NAVAL * categories.MOBILE * categories.TECH3, '>='})
    --]]

    -- Sonar around the base
    opai = AeonM3BlackSunNavalBase:AddOpAI('Sonar',
        {
            Amount = 1,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Aeon_Sonar_Chain',
            },
            MaxAssist = 1,
            Retry = true,
        }
    )
end

----------------------
-- Aeon M3 Island Base
----------------------
function AeonM3IslandBaseAI()
    AeonM3IslandBase:InitializeDifficultyTables(ArmyBrains[Aeon], 'M3_Aeon_Island_Base', 'Experimental_Island', 50, {M3_Island_Defenses = 100})
    AeonM3IslandBase:StartNonZeroBase({2, 4, 6})
    AeonM3IslandBase:SetDefaultEngineerPatrolChain('M3_Island_Patrol')

    AeonM3IslandBaseExperimentals()
end

function AeonM3IslandBaseExperimentals()
    local opai = nil

    opai = AeonM3IslandBase:AddOpAI('M3_Island_GC',
        {
            Amount = 1,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            MaxAssist = 6,
            Retry = true,
            WaitSecondsAfterDeath = 60,
        }
    )

    opai = AeonM3IslandBase:AddOpAI('M3_Island_Tempest',
        {
            Amount = 1,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            MaxAssist = 6,
            Retry = true,
            WaitSecondsAfterDeath = 60,
        }
    )

    opai = AeonM3IslandBase:AddOpAI('M3_Island_CZAR',
        {
            Amount = 1,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
            MaxAssist = 6,
            Retry = true,
            WaitSecondsAfterDeath = 60,
        }
    )
end

--------------------------------
-- Aeon M3 South West Naval Base
--------------------------------
function AeonM3SouthWestBaseAI()
    AeonM3SouthWestBase:InitializeDifficultyTables(ArmyBrains[Aeon], 'M3_SW_Base', 'M3_SW_Base_Marker', 110, {M3_SW_Base = 100})
    AeonM3SouthWestBase:StartNonZeroBase({{3, 6, 8}, {2, 5, 6}})
    AeonM3SouthWestBase:SetActive('AirScouting', true)
    AeonM3SouthWestBase:SetActive('LandScouting', true)
    -- AeonM3SouthWestBase:SetActive('Nuke', true)
    AeonM3SouthWestBase:SetSupportACUCount(1)
    AeonM3SouthWestBase:SetSACUUpgrades({'EngineeringFocusingModule', 'SystemIntegrityCompensator', 'ResourceAllocation'}, true)

    -- AeonM3SouthWestBase:AddReactiveAI('ExperimentalLand', 'AirRetaliation', 'AeonM3SouthWestBase_ExperimentalLand')
    -- AeonM3SouthWestBase:AddReactiveAI('ExperimentalAir', 'AirRetaliation', 'AeonM3SouthWestBase_ExperimentalAir')
    -- AeonM3SouthWestBase:AddReactiveAI('ExperimentalNaval', 'AirRetaliation', 'AeonM3SouthWestBase_ExperimentalNaval')
    -- AeonM3SouthWestBase:AddReactiveAI('Nuke', 'AirRetaliation', 'AeonM3SouthWestBase_Nuke')
    -- AeonM3SouthWestBase:AddReactiveAI('HLRA', 'AirRetaliation', 'AeonM3SouthWestBase_HLRA')

    AeonM3SouthWestBaseAirAttacks()
    AeonM3SouthWestBaseLandAttacks()
    AeonM3SouthWestBaseNavalAttacks()
    AeonM3SouthWestBaseConditionalBuilds()
end

function AeonM3SouthWestBaseAirAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    quantity = {9, 12, 16}
    opai = AeonM3SouthWestBase:AddOpAI('AirAttacks', 'M3_South_West_AirAttack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M3_SW_Base_Naval_Attack_Chain_1',
                    'M3_SW_Base_Naval_Attack_Chain_2',
                },
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])

    quantity = {9, 12, 16}
    opai = AeonM3SouthWestBase:AddOpAI('AirAttacks', 'M3_South_West_AirAttack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M3_SW_Base_Naval_Attack_Chain_1',
                    'M3_SW_Base_Naval_Attack_Chain_2',
                },
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('TorpedoBombers', quantity[Difficulty])

    quantity = {3, 3, 4}
    opai = AeonM3SouthWestBase:AddOpAI('AirAttacks', 'M3_South_West_AirAttack_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M3_SW_Base_Naval_Attack_Chain_1',
                    'M3_SW_Base_Naval_Attack_Chain_2',
                },
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('StratBombers', quantity[Difficulty])

    quantity = {6, 9, 12}
    trigger = {10, 11, 12}
    opai = AeonM3SouthWestBase:AddOpAI('AirAttacks', 'M3_South_West_AirAttack_4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M3_SW_Base_Naval_Attack_Chain_1',
                    'M3_SW_Base_Naval_Attack_Chain_2',
                },
            },
            Priority = 140,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE, '>='})
end

function AeonM3SouthWestBaseLandAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    quantity = {6, 9, 12}
    opai = AeonM3SouthWestBase:AddOpAI('BasicLandAttack', 'M3_Aeon_SW_LandGuard_1',
        {
            MasterPlatoonFunction = {CustomFunctions, 'AddToNavalGuardPool'},
            PlatoonData = {
                RallyPoint = "M3_SW_AmphibiousRally",
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('MobileShields', quantity[Difficulty])

    quantity = {8, 9, 12}
    opai = AeonM3SouthWestBase:AddOpAI('BasicLandAttack', 'M3_Aeon_SW_LandGuard_2',
        {
            MasterPlatoonFunction = {CustomFunctions, 'AddToNavalGuardPool'},
            PlatoonData = {
                RallyPoint = "M3_SW_AmphibiousRally",
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('MobileFlak', quantity[Difficulty])
end

function AeonM3SouthWestBaseNavalAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    quantity = {{2, 2}, {3, 3}, {4, 4}}
    opai = AeonM3SouthWestBase:AddOpAI('NavalAttacks', 'M3_South_West_NavalAttack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M3_SW_Base_Naval_Attack_Chain_1',
                    'M3_SW_Base_Naval_Attack_Chain_2',
                },
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'Destroyers', 'Frigates'}, quantity[Difficulty])
    opai:AddFormCallback(CustomFunctions, "RequestAmphibiousGuard")

    quantity = {{2, 1, 3}, {2, 1, 3}, {3, 1, 4}}
    trigger = {2, 2, 1}
    opai = AeonM3SouthWestBase:AddOpAI('NavalAttacks', 'M3_South_West_NavalAttack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M3_SW_Base_Naval_Attack_Chain_1',
                    'M3_SW_Base_Naval_Attack_Chain_2',
                },
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'Destroyers', 'Cruisers', 'Frigates'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE - categories.TECH1, '>='})
    opai:SetFormation('AttackFormation')
    opai:AddFormCallback(CustomFunctions, "RequestAmphibiousGuard")

    trigger = {2, 2, 1}
    opai = AeonM3SouthWestBase:AddOpAI('NavalAttacks', 'M3_South_West_NavalAttack_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M3_SW_Base_Naval_Attack_Chain_1',
                    'M3_SW_Base_Naval_Attack_Chain_2',
                },
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity({'Battleships', 'Destroyers'}, {1, 6})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE * (categories.TECH3 + categories.EXPERIMENTAL), '>='})
    opai:AddFormCallback(CustomFunctions, "RequestAmphibiousGuard")

    quantity = {2, 3, 4}
    trigger = {80, 70, 60}
    opai = AeonM3SouthWestBase:AddOpAI('NavalAttacks', 'M3_South_West_NavalAttack_4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M3_SW_Base_Naval_Attack_Chain_1',
                    'M3_SW_Base_Naval_Attack_Chain_2',
                },
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('Cruisers', quantity[Difficulty])
    opai:SetFormation("AttackFormation")
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE, '>='})
    opai:AddFormCallback(CustomFunctions, "RequestAmphibiousGuard")

    quantity = {{2, 2}, {2, 4}, {3, 3}}
    trigger = {5, 4, 3}
    opai = AeonM3SouthWestBase:AddOpAI('NavalAttacks', 'M3_South_West_NavalAttack_5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M3_SW_Base_Naval_Attack_Chain_1',
                    'M3_SW_Base_Naval_Attack_Chain_2',
                },
            },
            Priority = 140,
        }
    )
    opai:SetChildQuantity({'Battleships', 'Destroyers'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE * (categories.TECH3 + categories.EXPERIMENTAL), '>='})
    opai:AddFormCallback(CustomFunctions, "RequestAmphibiousGuard")

    quantity = {{4, 1}, {5, 1}, {6, 2}}
    trigger = {16, 14, 12}
    opai = AeonM3SouthWestBase:AddOpAI('NavalAttacks', 'M3_South_West_NavalAttack_6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M3_SW_Base_Naval_Attack_Chain_1',
                    'M3_SW_Base_Naval_Attack_Chain_2',
                },
            },
            Priority = 140,
        }
    )
    opai:SetChildQuantity({'Destroyers', 'Cruisers'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE * (categories.TECH1 + categories.TECH2), '>='})
    opai:AddFormCallback(CustomFunctions, "RequestAmphibiousGuard")

    trigger = {7, 6, 5}
    opai = AeonM3SouthWestBase:AddOpAI('NavalAttacks', 'M3_South_West_NavalAttack_7',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M3_SW_Base_Naval_Attack_Chain_1',
                    'M3_SW_Base_Naval_Attack_Chain_2',
                },
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity('Battleships', 4)
    opai:SetFormation("AttackFormation")
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE * (categories.TECH3 + categories.EXPERIMENTAL), '>='})
    opai:AddFormCallback(CustomFunctions, "RequestAmphibiousGuard")

    quantity = {{1, 2}, {2, 2}, {3, 5}}
    trigger = {140, 120, 100}
    opai = AeonM3SouthWestBase:AddOpAI('NavalAttacks', 'M3_South_West_NavalAttack_8',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M3_SW_Base_Naval_Attack_Chain_1',
                    'M3_SW_Base_Naval_Attack_Chain_2',
                },
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity({'Carriers', 'Cruisers'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE, '>='})
    opai:AddFormCallback(CustomFunctions, "RequestAmphibiousGuard")
end

function AeonM3SouthWestBaseConditionalBuilds()
    -- Sonar around the base
    local opai = AeonM3SouthWestBase:AddOpAI('M3_SW_Sonar',
        {
            Amount = 1,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_SW_Base_Sonar_Chain',
            },
            MaxAssist = 1,
            Retry = true,
        }
    )

    -- Tempest
    opai = AeonM3SouthWestBase:AddOpAI('M3_SW_Tempest',
        {
            Amount = 1,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_SW_Base_Naval_Attack_Chain_2',
            },
            MaxAssist = 3,
            Retry = true,
            WaitSecondsAfterDeath = 60,
        }
    )

    if Difficulty >= 2 then
        -- GC
        opai = AeonM3SouthWestBase:AddOpAI('M3_SW_GC',
            {
                Amount = 1,
                KeepAlive = true,
                PlatoonAIFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
                PlatoonData = {
                    PatrolChain = 'M3_SW_Base_Naval_Attack_Chain_2',
                },
                MaxAssist = 3,
                Retry = true,
                WaitSecondsAfterDeath = 120,
            }
        )
    end
end

--------------------------------
-- Aeon M3 South East Naval Base
--------------------------------
function AeonM3SouthEastBaseAI()
    AeonM3SouthEastBase:InitializeDifficultyTables(ArmyBrains[Aeon], 'M3_SE_Base', 'M3_SE_Base_Marker', 120, {M3_SE_Base = 100})
    AeonM3SouthEastBase:StartNonZeroBase({{3, 6, 9}, {2, 5, 7}})
    AeonM3SouthEastBase:SetActive('AirScouting', true)
    AeonM3SouthEastBase:SetActive('LandScouting', true)
    -- AeonM3SouthEastBase:SetActive('Nuke', true)
    AeonM3SouthEastBase:SetSupportACUCount(1)
    AeonM3SouthEastBase:SetSACUUpgrades({'EngineeringFocusingModule', 'ShieldHeavy', 'ResourceAllocation'}, true)

    -- AeonM3SouthEastBase:AddReactiveAI('ExperimentalLand', 'AirRetaliation', 'AeonM3SouthEastBase_ExperimentalLand')
    -- AeonM3SouthEastBase:AddReactiveAI('ExperimentalAir', 'AirRetaliation', 'AeonM3SouthEastBase_ExperimentalAir')
    -- AeonM3SouthEastBase:AddReactiveAI('ExperimentalNaval', 'AirRetaliation', 'AeonM3SouthEastBase_ExperimentalNaval')
    -- AeonM3SouthEastBase:AddReactiveAI('Nuke', 'AirRetaliation', 'AeonM3SouthEastBase_Nuke')
    -- AeonM3SouthEastBase:AddReactiveAI('HLRA', 'AirRetaliation', 'AeonM3SouthEastBase_HLRA')

    AeonM3SouthEastBaseAirAttacks()
    AeonM3SouthEastBaseLandAttacks()
    AeonM3SouthEastBaseNavalAttacks()
    AeonM3SouthEastBaseConditionalBuilds()
end

function AeonM3SouthEastBaseAirAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    -- Transport builder, maintain at least 6 transports
    opai = AeonM3SouthEastBase:AddOpAI('EngineerAttack', 'M3_Aeon_SE_TransportBuilder',
        {
            MasterPlatoonFunction = {SPAIFileName, 'TransportPool'},
            PlatoonData = {
                TransportMoveLocation = 'M2_SE_Teleport',
            },
            Priority = 1000,
        }
    )
    opai:SetChildQuantity('T2Transports', 6)
    opai:SetLockingStyle('None')
    opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
        'HaveLessThanUnitsWithCategory', {'default_brain', 6, categories.uaa0104})

    quantity = {12, 15, 18}
    opai = AeonM3SouthEastBase:AddOpAI('AirAttacks', 'M3_South_East_AirAttack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M3_SE_Base_Naval_Attack_Chain_1',
                    'M3_SE_Base_Naval_Attack_Chain_2',
                },
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])

    quantity = {12, 15, 18}
    opai = AeonM3SouthEastBase:AddOpAI('AirAttacks', 'M3_South_East_AirAttack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M3_SE_Base_Naval_Attack_Chain_1',
                    'M3_SE_Base_Naval_Attack_Chain_2',
                },
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('TorpedoBombers', quantity[Difficulty])

    quantity = {4, 5, 6}
    opai = AeonM3SouthEastBase:AddOpAI('AirAttacks', 'M3_South_East_AirAttack_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M3_SE_Base_Naval_Attack_Chain_1',
                    'M3_SE_Base_Naval_Attack_Chain_2',
                },
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('StratBombers', quantity[Difficulty])

    quantity = {8, 10, 12}
    trigger = {10, 11, 12}
    opai = AeonM3SouthEastBase:AddOpAI('AirAttacks', 'M3_South_East_AirAttack_4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M3_SE_Base_Naval_Attack_Chain_1',
                    'M3_SE_Base_Naval_Attack_Chain_2',
                },
            },
            Priority = 140,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE, '>='})
end

function AeonM3SouthEastBaseLandAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    quantity = {8, 10, 12}
    opai = AeonM3SouthEastBase:AddOpAI('BasicLandAttack', 'M3_Aeon_SE_LandGuard_1',
        {
            MasterPlatoonFunction = {CustomFunctions, 'AddToNavalGuardPool'},
            PlatoonData = {
                RallyPoint = "M3_SE_AmphibiousRally",
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('MobileShields', quantity[Difficulty])

    quantity = {8, 10, 12}
    opai = AeonM3SouthEastBase:AddOpAI('BasicLandAttack', 'M3_Aeon_SE_LandGuard_2',
        {
            MasterPlatoonFunction = {CustomFunctions, 'AddToNavalGuardPool'},
            PlatoonData = {
                RallyPoint = "M3_SE_AmphibiousRally",
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('MobileFlak', quantity[Difficulty])

    quantity = {4, 8, 12}
    for i = 1, 2 do
        opai = AeonM3SouthEastBase:AddOpAI('BasicLandAttack', 'M3_Aeon_SE_Drop_1_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'LandAssaultWithTransports'},
                PlatoonData = {
                    AttackChain = 'Player_Base_Chain',
                    MovePath = 'M3_Aeon_SE_Drop_Move_Chain_' .. i,
                    LandingChain = 'Player_Base_Landing_Chain',
                    TransportReturn = 'M2_SE_Teleport',
                },
                Priority = 200,
            }
        )
        opai:SetChildQuantity('SiegeBots', quantity[Difficulty])
        opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
            'HaveGreaterThanUnitsWithCategory', {'default_brain', math.ceil(quantity[Difficulty] / 3), categories.uaa0104})
        opai:SetLockingStyle('DeathTimer', {LockTimer = 180})
    end
end

function AeonM3SouthEastBaseNavalAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}
    --[[
            PlatoonData = {
                PatrolChains = {
                    'M3_SE_Base_Naval_Attack_Chain_1',
                    'M3_SE_Base_Naval_Attack_Chain_2',
                },
            },
    --]]

    quantity = {{2, 2}, {3, 3}, {4, 4}}
    opai = AeonM3SouthEastBase:AddOpAI('NavalAttacks', 'M3_South_East_NavalAttack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M3_SE_Base_Naval_Attack_Chain_1',
                    'M3_SE_Base_Naval_Attack_Chain_2',
                },
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'Destroyers', 'Frigates'}, quantity[Difficulty])
    opai:AddFormCallback(CustomFunctions, "RequestAmphibiousGuard")

    quantity = {{2, 1, 3}, {2, 1, 3}, {3, 1, 4}}
    trigger = {2, 2, 1}
    opai = AeonM3SouthEastBase:AddOpAI('NavalAttacks', 'M3_South_East_NavalAttack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M3_SE_Base_Naval_Attack_Chain_1',
                    'M3_SE_Base_Naval_Attack_Chain_2',
                },
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'Destroyers', 'Cruisers', 'Frigates'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE - categories.TECH1, '>='})
    opai:SetFormation('AttackFormation')
    opai:AddFormCallback(CustomFunctions, "RequestAmphibiousGuard")

    trigger = {2, 2, 1}
    opai = AeonM3SouthEastBase:AddOpAI('NavalAttacks', 'M3_South_East_NavalAttack_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M3_SE_Base_Naval_Attack_Chain_1',
                    'M3_SE_Base_Naval_Attack_Chain_2',
                },
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity({'Battleships', 'Destroyers'}, {1, 6})
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE * (categories.TECH3 + categories.EXPERIMENTAL), '>='})
    opai:AddFormCallback(CustomFunctions, "RequestAmphibiousGuard")

    quantity = {2, 3, 4}
    trigger = {80, 70, 60}
    opai = AeonM3SouthEastBase:AddOpAI('NavalAttacks', 'M3_South_East_NavalAttack_4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M3_SE_Base_Naval_Attack_Chain_1',
                    'M3_SE_Base_Naval_Attack_Chain_2',
                },
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('Cruisers', quantity[Difficulty])
    opai:SetFormation("AttackFormation")
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE, '>='})
    opai:AddFormCallback(CustomFunctions, "RequestAmphibiousGuard")

    quantity = {{2, 2}, {2, 4}, {3, 3}}
    trigger = {5, 4, 3}
    opai = AeonM3SouthEastBase:AddOpAI('NavalAttacks', 'M3_South_East_NavalAttack_5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M3_SE_Base_Naval_Attack_Chain_1',
                    'M3_SE_Base_Naval_Attack_Chain_2',
                },
            },
            Priority = 140,
        }
    )
    opai:SetChildQuantity({'Battleships', 'Destroyers'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE * (categories.TECH3 + categories.EXPERIMENTAL), '>='})
    opai:AddFormCallback(CustomFunctions, "RequestAmphibiousGuard")

    quantity = {{4, 1}, {5, 1}, {6, 2}}
    trigger = {16, 14, 12}
    opai = AeonM3SouthEastBase:AddOpAI('NavalAttacks', 'M3_South_East_NavalAttack_6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M3_SE_Base_Naval_Attack_Chain_1',
                    'M3_SE_Base_Naval_Attack_Chain_2',
                },
            },
            Priority = 140,
        }
    )
    opai:SetChildQuantity({'Destroyers', 'Cruisers'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE * (categories.TECH1 + categories.TECH2), '>='})
    opai:AddFormCallback(CustomFunctions, "RequestAmphibiousGuard")

    trigger = {7, 6, 5}
    opai = AeonM3SouthEastBase:AddOpAI('NavalAttacks', 'M3_South_East_NavalAttack_7',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M3_SE_Base_Naval_Attack_Chain_1',
                    'M3_SE_Base_Naval_Attack_Chain_2',
                },
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity('Battleships', 4)
    opai:SetFormation("AttackFormation")
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE * (categories.TECH3 + categories.EXPERIMENTAL), '>='})
    opai:AddFormCallback(CustomFunctions, "RequestAmphibiousGuard")

    quantity = {{1, 2}, {2, 2}, {3, 5}}
    trigger = {140, 120, 100}
    opai = AeonM3SouthEastBase:AddOpAI('NavalAttacks', 'M3_South_East_NavalAttack_8',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M3_SE_Base_Naval_Attack_Chain_1',
                    'M3_SE_Base_Naval_Attack_Chain_2',
                },
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity({'Carriers', 'Cruisers'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE, '>='})
    opai:AddFormCallback(CustomFunctions, "RequestAmphibiousGuard")

    if false then
        quantity = {2, 3, 4}
        opai = AeonM3SouthEastBase:AddOpAI('NavalAttacks', 'M3_South_East_NukeSubs',
            {
                MasterPlatoonFunction = {CustomFunctions, 'NukeSubPlatoonThread'},
                PlatoonData = {
                },
                Priority = 140,
            }
        )
        opai:SetChildQuantity('NukeSubmarines', quantity[Difficulty])

        quantity = {2, 3, 4}
        opai = AeonM3SouthEastBase:AddOpAI('NavalAttacks', 'M3_South_East_Carriers',
            {
                MasterPlatoonFunction = {CustomFunctions, 'NukeSubPlatoonThread'},
                PlatoonData = {
                    WaitChain = '',
                    PatrolChain = '',
                    MoveChain = '',
                    TargetChain = '',
                },
                Priority = 140,
            }
        )
        opai:SetChildQuantity('Carriers', quantity[Difficulty])
    end
end

function AeonM3SouthEastBaseConditionalBuilds()
    -- Sonar around the base
    opai = AeonM3SouthEastBase:AddOpAI('M3_SE_Sonar',
        {
            Amount = 1,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_SE_Base_Sonar_Chain',
            },
            MaxAssist = 1,
            Retry = true,
        }
    )

    -- CZAR
    if Difficulty >= 2 then
        opai = AeonM3SouthEastBase:AddOpAI('M3_SE_CZAR',
            {
                Amount = 1,
                KeepAlive = true,
                PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},
                PlatoonData = {
                    PatrolChains = {
                        'M3_SE_Base_Naval_Attack_Chain_1',
                        'M3_SE_Base_Naval_Attack_Chain_2',
                        'M3_SE_CZAR_Chain_1',
                        'M3_SE_CZAR_Chain_2',
                    },
                },
                MaxAssist = 3,
                Retry = true,
                WaitSecondsAfterDeath = 120,
            }
        )
    end

    if Difficulty >= 3 then
        -- GC
        opai = AeonM3SouthEastBase:AddOpAI('M3_SE_GC',
            {
                Amount = 1,
                KeepAlive = true,
                PlatoonAIFunction = {SPAIFileName, 'PlatoonAttackHighestThreat'},
                PlatoonData = {
                    PatrolChain = 'M3_SW_Base_Naval_Attack_Chain_2',
                },
                MaxAssist = 3,
                Retry = true,
                WaitSecondsAfterDeath = 120,
            }
        )
    end
end
