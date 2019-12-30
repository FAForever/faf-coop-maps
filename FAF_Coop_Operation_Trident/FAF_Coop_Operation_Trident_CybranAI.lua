local BaseManager = import('/lua/ai/opai/basemanager.lua')
local CustomFunctions = '/maps/FAF_Coop_Operation_Trident/FAF_Coop_Operation_Trident_CustomFunctions.lua'
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local SPAIFileName = '/lua/ScenarioPlatoonAI.lua'
local ThisFile = '/maps/FAF_Coop_Operation_Trident/FAF_Coop_Operation_Trident_CybranAI.lua'

---------
-- Locals
---------
local Cybran = 4
local Difficulty = ScenarioInfo.Options.Difficulty

----------------
-- Base Managers
----------------
local M1CybranMainBase = BaseManager.CreateBaseManager()

----------------------
-- M1 Cybran Main Base
----------------------
function M1CybranMainBaseAI()
    M1CybranMainBase:Initialize(ArmyBrains[Cybran], 'M1_Cybran_Main_Base', 'M1_Cybran_Main_Base_Marker', 90,
        {
            Eco_1 = 200,
            Factory_1 = 190,
            Eco_2 = 180,
            Eco_3 = 170,
            Factory_2 = 160,
            Factory_3 = 150,
            Eco_4 = 140,
            Factory_4 = 130,
            Def_1 = 120,
            Eco_5 = 110,
            Rest = 105,
            ['Def_2_D' .. Difficulty] = 100,
            -- Walls_1 = 50,

        }
    )
    M1CybranMainBase:StartEmptyBase(4)
    M1CybranMainBase:SetMaximumConstructionEngineers(5)
    M1CybranMainBase:SetActive('LandScouting', true)

    M1CybranMainBaseAirAttacks()
    M1CybranMainBaseLandAttacks()
    M1CybranMainBaseNavalAttacks()
end

function IncreaseEngineerCount()
    M1CybranMainBase:SetEngineerCount(10)
    M1CybranMainBase:SetMaximumConstructionEngineers(10)
end

function ResetEngineerCount()
    M1CybranMainBase:SetEngineerCount({10, 8})
    M1CybranMainBase:SetMaximumConstructionEngineers(2)

    ArmyBrains[Cybran]:PBMSetCheckInterval(13)
end

-------------
-- M1 Attacks
-------------
function M1CybranMainBaseAirAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    -- Air Scouts for players, only in the first part and after 2 air factories are built
    ArmyBrains[Cybran]:PBMAddPlatoon(
        {
            BuilderName = 'M1_Cybran_AirScouts_Builder',
            PlatoonTemplate = {
                'ScoutThing',
                'NoPlan',
                {'ura0101', 1, 3, 'Scout', 'None'},
            },
            Priority = 200,
            PlatoonAIFunction = {'/maps/FAF_Coop_Operation_Trident/FAF_Coop_Operation_Trident_script.lua', 'M1ScoutPlatoonFormed'},
            BuildConditions = {
                {'/lua/editor/BaseManagerBuildConditions.lua', 'BaseActive', {'M1_Cybran_Main_Base'}},
                {'/lua/editor/MiscBuildConditions.lua', 'MissionNumber', {'default_brain', 1}},
                --{'/lua/editor/UnitCountBuildConditions.lua', 'HaveGreaterThanUnitsWithCategory', {'default_brain', 1, categories.FACTORY * categories.AIR * categories.TECH2}},
            },
            PlatoonData = {
                BaseName = 'M1_Cybran_Main_Base',
            },
            PlatoonType = 'Air',
            RequiresConstruction = true,
            LocationType = 'M1_Cybran_Main_Base',
        }
    )

    -- Transports, maintain at least 3 after 10 min ingame
    opai = M1CybranMainBase:AddOpAI('EngineerAttack', 'M1_Cybran_TransportBuilder',
        {
            MasterPlatoonFunction = {SPAIFileName, 'LandAssaultWithTransports'},
            PlatoonData = {
                TransportReturn = 'M1_Cybran_Transport_Return_Marker',
            },
            Priority = 300,
        }
    )
    opai:SetChildQuantity('T2Transports', 3)
    opai:SetLockingStyle('None')
    opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'GreaterThanGameTime', {'default_brain', 600})
    opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
        'HaveLessThanUnitsWithCategory', {'default_brain', 3, categories.ura0104})

    ----------
    -- Attacks
    ----------
    -- Attack the UEF shore base
    quantity = {9, 7, 6}
    opai = M1CybranMainBase:AddOpAI('AirAttacks', 'M1_Cybran_AirAttack_1',
        {
            MasterPlatoonFunction = {ThisFile, 'M1CybranAirAttackThread'},
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Bombers', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/MiscBuildConditions.lua', 'MissionNumber', {'default_brain', 1})

    quantity = {12, 9, 9}
    opai = M1CybranMainBase:AddOpAI('AirAttacks', 'M1_Cybran_AirAttack_2',
        {
            MasterPlatoonFunction = {ThisFile, 'M1CybranAirAttackThread'},
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Interceptors', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/MiscBuildConditions.lua', 'MissionNumber', {'default_brain', 1})

    quantity = {7, 6, 5}
    opai = M1CybranMainBase:AddOpAI('AirAttacks', 'M1_Cybran_AirAttack_3',
        {
            MasterPlatoonFunction = {ThisFile, 'M1CybranAirAttackThread'},
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/MiscBuildConditions.lua', 'MissionNumber', {'default_brain', 1})

    ----------
    -- Patrols
    ----------
    -- Build some patrolling air units if there's nothing else to build
    for i = 1, 2 do
        opai = M1CybranMainBase:AddOpAI('AirAttacks', 'M1_Cybran_AirDefense_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M1_Cybran_Air_Defense_Chain',
                },
                Priority = 90,
            }
        )
        opai:SetChildQuantity('CombatFighters', 3)
        opai:SetFormation('NoFormation')
        opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    end

    opai = M1CybranMainBase:AddOpAI('AirAttacks', 'M1_Cybran_AirDefense_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M1_Cybran_Air_Defense_Chain',
            },
            Priority = 90,
        }
    )
    opai:SetChildQuantity('TorpedoBombers', 4)
    opai:SetFormation('NoFormation')
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})

    opai = M1CybranMainBase:AddOpAI('AirAttacks', 'M1_Cybran_AirDefense_4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M1_Cybran_Air_Defense_Chain',
            },
            Priority = 90,
        }
    )
    opai:SetChildQuantity('Gunships', 4)
    opai:SetFormation('NoFormation')
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
end

function M1CybranMainBaseLandAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    --------------------
    -- Reclaim Engineers
    --------------------
    -- Engineer for reclaiming around the base
    opai = M1CybranMainBase:AddOpAI('EngineerAttack', 'M1_Cybran_Reclaim_Engineers_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'SplitPatrolThread'},
            PlatoonData = {
                PatrolChains = {
                    'M1_Cybran_Air_Defense_Chain',
                },
            },
            Priority = 180,
        }
    )
    opai:SetChildQuantity('T1Engineers', 3)

    -- Engineer for reclaiming if there's less than 4000 Mass in the storage, starting after 5 minutes
    opai = M1CybranMainBase:AddOpAI('EngineerAttack', 'M1_Cybran_Reclaim_Engineers_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'SplitPatrolThread'},
            PlatoonData = {
                PatrolChains = {
                    'M1_Cybran_Land_Attack_Chain',
                    'M1_Cybran_Air_Attack_Chain',
                },
            },
            Priority = 190,
        }
    )
    opai:SetChildQuantity('T1Engineers', 3)
    opai:AddBuildCondition(CustomFunctions, 'LessMassStorageCurrent', {'default_brain', 4000})
    opai:AddBuildCondition('/lua/editor/MiscBuildConditions.lua', 'MissionNumber', {'default_brain', 1})
    --opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'GreaterThanGameTime', {'default_brain', 300})

    -- Engineer for reclaiming if there's less than 2000 Mass in the storage, starting after 5 minutes
    opai = M1CybranMainBase:AddOpAI('EngineerAttack', 'M1_Cybran_Reclaim_Engineers_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'SplitPatrolThread'},
            PlatoonData = {
                PatrolChains = {
                    'M1_Cybran_Land_Attack_Chain',
                    'M1_Cybran_Air_Attack_Chain',
                },
            },
            Priority = 200,
        }
    )
    opai:SetChildQuantity('T1Engineers', 6)
    opai:AddBuildCondition(CustomFunctions, 'LessMassStorageCurrent', {'default_brain', 2000})
    opai:AddBuildCondition('/lua/editor/MiscBuildConditions.lua', 'MissionNumber', {'default_brain', 1})
    --opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'GreaterThanGameTime', {'default_brain', 300})

    -- Extra engineers assisting T1 naval factories, both T1 factories has to be built
    quantity = {4, 4, 6}
    opai = M1CybranMainBase:AddOpAI('EngineerAttack', 'M1_Cybran_Assist_Engineers_1',
        {
            MasterPlatoonFunction = {CustomFunctions, 'AssistNavalFactories'},
            PlatoonData = {
                BaseName = 'M1_Cybran_Main_Base',
                Factories = categories.TECH1 * categories.NAVAL * categories.FACTORY,
            },
            Priority = 160,
        }
    )
    opai:SetChildQuantity('T1Engineers', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
        'HaveGreaterThanUnitsWithCategory', {'default_brain', 1, categories.TECH2 * categories.NAVAL * categories.FACTORY})

    -- Extra engineers assisting T2 naval factories, both T2 factories has to be built
    -- Count is X, 0 since the platoon contains shields/stealth as well and we want just the engineers. And too lazy to make a new platoon rn.
    quantity = {{4, 0}, {4, 0}, {6, 0}}
    opai = M1CybranMainBase:AddOpAI('EngineerAttack', 'M1_Cybran_Assist_Engineers_2',
        {
            MasterPlatoonFunction = {CustomFunctions, 'AssistNavalFactories'},
            PlatoonData = {
                BaseName = 'M1_Cybran_Main_Base',
                Factories = categories.TECH2 * categories.NAVAL * categories.FACTORY,
            },
            Priority = 170,
        }
    )
    opai:SetChildQuantity('T2Engineers', quantity[Difficulty])
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
        'HaveGreaterThanUnitsWithCategory', {'default_brain', 1, categories.TECH2 * categories.NAVAL * categories.FACTORY})

    ------------------
    -- M1 Land Attacks
    ------------------
    quantity = {15, 14, 12}
    opai = M1CybranMainBase:AddOpAI('BasicLandAttack', 'M1_Cybran_LandAttack_1',
        {
            MasterPlatoonFunction = {ThisFile, 'M1CybranLandAttackThread'},
            Priority = 100,
        }
    )
    opai:SetChildQuantity('LightArtillery', quantity[Difficulty])
    opai:SetFormation('AttackFormation')
    opai:AddBuildCondition('/lua/editor/MiscBuildConditions.lua', 'MissionNumber', {'default_brain', 1})

    quantity = {6, 5, 3}
    opai = M1CybranMainBase:AddOpAI('BasicLandAttack', 'M1_Cybran_LandAttack_2',
        {
            MasterPlatoonFunction = {ThisFile, 'M1CybranLandAttackThread'},
            Priority = 100,
        }
    )
    opai:SetChildQuantity('MobileMissiles', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/MiscBuildConditions.lua', 'MissionNumber', {'default_brain', 1})

    quantity = {4, 3, 2}
    opai = M1CybranMainBase:AddOpAI('BasicLandAttack', 'M1_Cybran_LandAttack_3',
        {
            MasterPlatoonFunction = {ThisFile, 'M1CybranLandAttackThread'},
            Priority = 100,
        }
    )
    opai:SetChildQuantity('MobileFlak', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/MiscBuildConditions.lua', 'MissionNumber', {'default_brain', 1})

    -- Hoplites if there are at least 2 T2 Land Factories
    quantity = {8, 6, 6}
    opai = M1CybranMainBase:AddOpAI('BasicLandAttack', 'M1_Cybran_LandAttack_4',
        {
            MasterPlatoonFunction = {ThisFile, 'M1CybranLandAttackThread'},
            Priority = 110,
        }
    )
    opai:SetChildQuantity('RangeBots', quantity[Difficulty])
    opai:SetFormation('AttackFormation')
    opai:AddBuildCondition('/lua/editor/MiscBuildConditions.lua', 'MissionNumber', {'default_brain', 1})
    opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
        'HaveGreaterThanUnitsWithCategory', {'default_brain', 1, categories.TECH2 * categories.LAND * categories.FACTORY})

    -- Hoplites if there are at least 3 T2 Land Factories
    quantity = {{6, 4}, {6, 4}, {4, 4}}
    opai = M1CybranMainBase:AddOpAI('BasicLandAttack', 'M1_Cybran_LandAttack_5',
        {
            MasterPlatoonFunction = {ThisFile, 'M1CybranLandAttackThread'},
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'RangeBots', 'LightArtillery'}, quantity[Difficulty])
    opai:SetFormation('AttackFormation')
    opai:AddBuildCondition('/lua/editor/MiscBuildConditions.lua', 'MissionNumber', {'default_brain', 1})
    opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
        'HaveGreaterThanUnitsWithCategory', {'default_brain', 2, categories.TECH2 * categories.LAND * categories.FACTORY})
end

function M1CybranMainBaseNavalAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}
    
    -- Basic Naval attack to help player killing UEF base.
    opai = M1CybranMainBase:AddOpAI('NavalAttacks', 'M1_Cybran_NavalAttack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M1_Cybran_Naval_Attack_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'Frigates', 'Submarines'}, 4)
    opai:AddBuildCondition('/lua/editor/MiscBuildConditions.lua', 'MissionNumber', {'default_brain', 1})

    -- Basic Naval attack to help player killing UEF base.
    opai = M1CybranMainBase:AddOpAI('NavalAttacks', 'M1_Cybran_NavalAttack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M1_Cybran_Naval_Attack_Chain',
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'Destroyers', 'Frigates'}, 4)
    opai:AddBuildCondition('/lua/editor/MiscBuildConditions.lua', 'MissionNumber', {'default_brain', 1})

    -- Patrols
    -- 2 T2 and 2 T1 Subs
    opai = M1CybranMainBase:AddOpAI('NavalAttacks', 'M1_Cybran_NavalDefense_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M1_Cybran_Naval_Patrol_Chain',
            },
            Priority = 90,
        }
    )
    opai:SetChildQuantity({'T2Submarines', 'Submarines'}, 4)
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})

    -- 2 Destroyers, 4 Frigates
    opai = M1CybranMainBase:AddOpAI('NavalAttacks', 'M1_Cybran_NavalDefense_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M1_Cybran_Naval_Patrol_Chain',
            },
            Priority = 90,
        }
    )
    opai:SetChildQuantity({'Destroyers', 'Frigates'}, {2, 4})
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})

    -- 2 Destroyers, 4 Frigates
    quantity = {{2, 2}, {2, 1}, 2}
    opai = M1CybranMainBase:AddOpAI('NavalAttacks', 'M1_Cybran_NavalDefense_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M1_Cybran_Naval_Patrol_Chain',
            },
            Priority = 80,
        }
    )
    if Difficulty >= 3 then
        opai:SetChildQuantity('Cruisers', quantity[Difficulty])
    else
        opai:SetChildQuantity({'Cruisers', 'UtilityBoats'}, quantity[Difficulty])
    end
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
end

-- Attack chain during M1 is to help clean the UEF base, once in M2, it sends the platoon towards the Aeon base.
function M1CybranLandAttackThread(platoon)
    local aiBrain = platoon:GetBrain()
    local cmd = false

    -- Switches attack chains based on mission number
    while aiBrain:PlatoonExists(platoon) do
        if (not cmd or not platoon:IsCommandsActive(cmd)) then
            if ScenarioInfo.MissionNumber == 1 then
                cmd = ScenarioFramework.PlatoonAttackChain(platoon, 'M1_Cybran_Land_Attack_Chain')
            elseif ScenarioInfo.MissionNumber == 2 then
                cmd = ScenarioFramework.PlatoonAttackChain(platoon, 'M2_Cybran_Land_Attack_Half_Chain')
            end
        end
        WaitSeconds(11)
    end
end

-- Attack chain during M1 is to help clean the UEF base, once in M2, it sends the platoon towards the Aeon base.
function M1CybranAirAttackThread(platoon)
    local aiBrain = platoon:GetBrain()
    local cmd = false

    -- Switches attack chains based on mission number
    while aiBrain:PlatoonExists(platoon) do
        if (not cmd or not platoon:IsCommandsActive(cmd)) then
            if ScenarioInfo.MissionNumber == 1 then
                cmd = ScenarioFramework.PlatoonAttackChain(platoon, 'M1_Cybran_Air_Attack_Chain')
            elseif ScenarioInfo.MissionNumber == 2 then
                cmd = ScenarioFramework.PlatoonAttackChain(platoon, 'M2_Cybran_Land_Attack_Half_Chain')
            end
        end
        WaitSeconds(11)
    end
end

----------------------
-- M2 Cybran Main Base
----------------------
function M2BuildExtraEconomy()
    M1CybranMainBase:AddBuildGroupDifficulty('M2_Expand_Eco', 90)
    M1CybranMainBase:AddBuildGroupDifficulty('M2_Expand_Defense', 80)
end

function M2RemoveACUFromConstruction()
    M1CybranMainBase:RemoveConstructionEngineer(ScenarioInfo.CybranACU)
end

function M2ChangeACUEnhancements()
    M1CybranMainBase:SetACUUpgrades({'AdvancedEngineering', 'NaniteTorpedoTube', 'StealthGenerator'})
end

-------------
-- M2 Attacks
-------------
function M2CybranMainBaseAirAttacks()
    M1CybranMainBase:SetActive('AirScouting', true)

    local opai = nil
    local quantity = {}
    local trigger = {}

    quantity = {15, 12, 10}
    opai = M1CybranMainBase:AddOpAI('AirAttacks', 'M2_Cybran_AirAttack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Cybran_Naval_Attack_UEF_Chain',
            },
            Priority = 60,
        }
    )
    opai:SetChildQuantity('Bombers', quantity[Difficulty])

    quantity = {12, 10, 8}
    opai = M1CybranMainBase:AddOpAI('AirAttacks', 'M2_Cybran_AirAttack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Cybran_Naval_Attack_UEF_Chain',
            },
            Priority = 70,
        }
    )
    opai:SetChildQuantity('TorpedoBombers', quantity[Difficulty])
end

function M2CybranMainBaseLandAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    ------------------
    -- M2 Land Attacks
    ------------------
    quantity = {15, 14, 12}
    opai = M1CybranMainBase:AddOpAI('BasicLandAttack', 'M2_Cybran_LandAttack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Cybran_Land_Attack_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('LightArtillery', quantity[Difficulty])
    opai:SetFormation('AttackFormation')

    quantity = {15, 14, 12}
    opai = M1CybranMainBase:AddOpAI('BasicLandAttack', 'M2_Cybran_LandAttack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Cybran_Land_Attack_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('HeavyBots', quantity[Difficulty])
    opai:SetFormation('AttackFormation')

    quantity = {6, 5, 3}
    opai = M1CybranMainBase:AddOpAI('BasicLandAttack', 'M2_Cybran_LandAttack_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Cybran_Land_Attack_Chain',
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('MobileMissiles', quantity[Difficulty])

    quantity = {6, 5, 4}
    opai = M1CybranMainBase:AddOpAI('BasicLandAttack', 'M2_Cybran_LandAttack_4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Cybran_Land_Attack_Chain',
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('MobileFlak', quantity[Difficulty])

    quantity = {{8, 1}, {7, 1}, {5, 1}}
    opai = M1CybranMainBase:AddOpAI('BasicLandAttack', 'M2_Cybran_LandAttack_5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Cybran_Land_Attack_Chain',
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'MobileBombs', 'MobileStealth'}, quantity[Difficulty])

    quantity = {8, 6, 6}
    opai = M1CybranMainBase:AddOpAI('BasicLandAttack', 'M2_Cybran_LandAttack_6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Cybran_Land_Attack_Chain',
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('HeavyTanks', quantity[Difficulty])
    opai:SetFormation('AttackFormation')

    -- Wagners
    quantity = {12, 10, 8}
    opai = M1CybranMainBase:AddOpAI('BasicLandAttack', 'M2_Cybran_AmphibiousAttack',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Cybran_Naval_Attack_UEF_Chain',
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity('AmphibiousTanks', quantity[Difficulty])
    opai:SetLockingStyle('DeathTimer', {LockTimer = 240})
end

function M2CybranMainBaseNavalAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    -- Attack UEF Base
    opai = M1CybranMainBase:AddOpAI('NavalAttacks', 'M2_Cybran_NavalAttack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Cybran_Naval_Attack_UEF_Chain',
            },
            Priority = 50,
        }
    )
    opai:SetChildQuantity({'Frigates', 'Submarines'}, {8, 8})

    opai = M1CybranMainBase:AddOpAI('NavalAttacks', 'M2_Cybran_NavalAttack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Cybran_Naval_Attack_UEF_Chain',
            },
            Priority = 60,
        }
    )
    opai:SetChildQuantity({'Destroyers', 'Frigates'}, 4)

    -- Attack UEF Base
    opai = M1CybranMainBase:AddOpAI('NavalAttacks', 'M2_Cybran_NavalAttack_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Cybran_Naval_Attack_UEF_Chain',
            },
            Priority = 70,
        }
    )
    opai:SetChildQuantity({'Destroyers', 'Cruisers', 'Frigates'}, {2, 2, 6})
end
--[[
SimLua do for k, v in ArmyBrains[4].BaseManagers.M1_Cybran_Main_Base.ConstructionEngineers do v:SetStrategicUnderlay('icon_objective_bonus') end end
SimLua do LOG(table.getn(ArmyBrains[4].BaseManagers.M1_Cybran_Main_Base.ConstructionEngineers)) end
SimLua do table.remove(ArmyBrains[4].BaseManagers.M1_Cybran_Main_Base.ConstructionEngineers, 2) end
--]]