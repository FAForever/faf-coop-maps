-- ****************************************************************************
-- **
-- **  File     : /maps/X1CA_Coop_005/X1CA_Coop_005_v03_m2fletcherai.lua
-- **  Author(s): Jessica St. Croix
-- **
-- **  Summary  : Fletcher army AI for Mission 2 - X1CA_Coop_005
-- **
-- **  Copyright © 2007 Gas Powered Games, Inc.  All rights reserved.
-- ****************************************************************************
local BaseManager = import('/lua/ai/opai/basemanager.lua')
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')

local SPAIFileName = '/lua/ScenarioPlatoonAI.lua'

--------
-- Locals
--------
local Fletcher = 2
local Difficulty = ScenarioInfo.Options.Difficulty

---------------
-- Base Managers
---------------
local FletcherBase = BaseManager.CreateBaseManager()
local FletcherM3Base = BaseManager.CreateBaseManager()

function FletcherBaseAI()

    ---------------
    -- Fletcher Base
    ---------------
    FletcherBase:Initialize(ArmyBrains[Fletcher], 'M1_Fletcher_Base', 'M1_Fletcher_Base_Marker', 150,
        {
             M1_Fletcher_MEX1 = 1000,
             M1_Fletcher_RDR1 = 990,
             M1_Fletcher_FACT1 = 980,
             M1_Fletcher_FACT2 = 975,
             M1_Fletcher_MEX2 = 970,
             M1_Fletcher_PWR2 = 960,
             M1_Fletcher_MEX3 = 950,
             M1_Fletcher_DEF1 = 930,
             M1_Fletcher_PWFAB1_1 = 910,
             M1_Fletcher_PWFAB1_2 = 900,
             M1_Fletcher_PWFAB1_3 = 890,
             M1_Fletcher_PWFAB1_4 = 880,
             M1_Fletcher_PWFAB2_1 = 820,
             M1_Fletcher_PWFAB2_2 = 810,
             M1_Fletcher_PWFAB2_3 = 800,
             M1_Fletcher_PWFAB2_4 = 790,
             M1_Fletcher_PWFAB3_1 = 730,
             M1_Fletcher_PWFAB3_2 = 720,
             M1_Fletcher_PWFAB3_3 = 710,
             M1_Fletcher_PWFAB3_4 = 700,
             M1_Fletcher_MSTOR4 = 650,
             M1_Fletcher_PWFAB4_1 = 640,
             M1_Fletcher_PWFAB4_2 = 630,
             M1_Fletcher_PWFAB4_3 = 620,
             M1_Fletcher_PWFAB4_4 = 610,
             M1_Fletcher_DEF2 = 560,
             M1_Fletcher_SHLD1 = 540,
             M1_Fletcher_DEF3 = 510,
             M1_Fletcher_SHLD2 = 500,
             M1_Fletcher_DEF4 = 490,
             M1_Fletcher_PWR1 = 30,
             M1_Fletcher_PWR3 = 30,
             M1_Fletcher_MEX4 = 30,
             M1_Fletcher_MSTOR1 = 20,
             M1_Fletcher_MSTOR2 = 20,
             M1_Fletcher_MSTOR3 = 20,
             M1_Fletcher_FACT4 = 15,    -- 4 factories - 2 air - 2 land    # Belonged to FACT3!
             M1_Fletcher_WALL1 = 10,
             M1_Fletcher_WALL2 = 10,
             M1_Fletcher_WALL3 = 10,
             M1_Fletcher_WALL4 = 10,
             M1_Fletcher_WALL5 = 10,
             M1_Fletcher_WALL6 = 10,
             M1_Fletcher_WALL7 = 10,
             M1_Fletcher_WALL8 = 10,
             M1_Fletcher_WALL9 = 10,
             M1_Fletcher_WALL10 = 10,
             M1_Fletcher_WALL11 = 10,
             M1_Fletcher_WALL12 = 10,
             M1_Fletcher_FACT3 = 5,    -- 675
         }
    )
-- FletcherBase:StartEmptyBase({60, 48})
    FletcherBase:StartEmptyBase(60)
    FletcherBase:SetConstructionAlwaysAssist(true)
    FletcherBase:SetMaximumConstructionEngineers(5)

    FletcherBase:SetActive('AirScouting', true)
    FletcherBase:SetActive('LandScouting', true)

end

function NewEngineerCount()
    FletcherBase:SetEngineerCount({60, 48})
    FletcherBase:SetMaximumConstructionEngineers(5)
end

function FletcherBaseLandAttacks()
    local opai = nil
    local quantity = {}

    -----------------------------------
    -- Fletcher Base Op AI, Land Attacks
    -----------------------------------

    opai = FletcherBase:AddOpAI('Fatboy_1',
        {
            Amount = 2,
            KeepAlive = true,
            BuildCondition = {
                {'/lua/editor/unitcountbuildconditions.lua', 'HaveGreaterThanUnitsWithCategory', {8, categories.ueb1301, false}}
            },
            PlatoonAIFunction = {'/maps/X1CA_Coop_005/X1CA_Coop_005_v03_m2fletcherai.lua', 'FletcherBaseAmphibiousAttacks'},
            MaxAssist = 15,
            Retry = true,
        }
    )

-- ========================================================================

    for i = 1, 2 do
    -- sends [heavy tanks]
    opai = FletcherBase:AddOpAI('BasicLandAttack', 'M2_LandAttack1' .. i,
        {
            MasterPlatoonFunction = {'/maps/X1CA_Coop_005/X1CA_Coop_005_v03_m2fletcherai.lua', 'FletcherLandPlatoonThread'},
            Priority = 100,
        }
    )
    opai:SetChildQuantity('HeavyTanks', 12)
    opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumber', {'default_brain', 2})

-- ========================================================================

    -- sends [mobile missiles]
    opai = FletcherBase:AddOpAI('BasicLandAttack', 'M2_LandAttack2' .. i,
        {
            MasterPlatoonFunction = {'/maps/X1CA_Coop_005/X1CA_Coop_005_v03_m2fletcherai.lua', 'FletcherLandPlatoonThread'},
            Priority = 100,
        }
    )
    opai:SetChildQuantity('MobileMissiles', 12)
    opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumber', {'default_brain', 2})

-- ========================================================================

    -- sends [mobile flak]
    opai = FletcherBase:AddOpAI('BasicLandAttack', 'M2_LandAttack3' .. i,
        {
            MasterPlatoonFunction = {'/maps/X1CA_Coop_005/X1CA_Coop_005_v03_m2fletcherai.lua', 'FletcherLandPlatoonThread'},
            Priority = 100,
        }
    )
    opai:SetChildQuantity('MobileFlak', 12)
    opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumber', {'default_brain', 2})
    end

-- ========================================================================

    -- sends [siege bots, mobile shields, heavy tanks, land scout]
    local template = {
        'ShieldedLandTemp',
        'NoPlan',
        { 'uel0303', 1, 6, 'Attack', 'GrowthFormation' },    -- Siege Bots
        { 'uel0307', 1, 2, 'Attack', 'GrowthFormation' },    -- Mobile Shields
        { 'uel0202', 1, 6, 'Attack', 'GrowthFormation' },    -- Heavy Tanks
        { 'uel0101', 1, 2, 'Attack', 'GrowthFormation' },    -- Land Scout
    }
    local builder = {
        BuilderName = 'ShieldedLand1',
        PlatoonTemplate = template,
        InstanceCount = 2,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'M1_Fletcher_Base',
        PlatoonAIFunction = {'/maps/X1CA_Coop_005/X1CA_Coop_005_v03_m2fletcherai.lua', 'FletcherLandPlatoonThread'},
    }
    ArmyBrains[Fletcher]:PBMAddPlatoon( builder )

-- ========================================================================

    -- sends [heavy bots] (mission 3)
    opai = FletcherBase:AddOpAI('BasicLandAttack', 'M2_LandAttack4',
        {
            MasterPlatoonFunction = {'/maps/X1CA_Coop_005/X1CA_Coop_005_v03_m2fletcherai.lua', 'FletcherBaseAmphibiousAttacks'},
            Priority = 100,
        }
    )
    opai:SetChildQuantity('HeavyBots', 12)
    opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumber', {'default_brain', 3})

-- ========================================================================

    -- sends [siege bots] (mission 3)
    opai = FletcherBase:AddOpAI('BasicLandAttack', 'M2_LandAttack5',
        {
            MasterPlatoonFunction = {'/maps/X1CA_Coop_005/X1CA_Coop_005_v03_m2fletcherai.lua', 'FletcherLandPlatoonThread'},
            Priority = 100,
        }
    )
    opai:SetChildQuantity('SiegeBots', 12)
    opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumber', {'default_brain', 3})
    opai:SetLockingStyle('BuildTimer', {LockTimer = 48})

-- ========================================================================

    -- sends [heavy tanks] (mission 3)
    opai = FletcherBase:AddOpAI('BasicLandAttack', 'M2_LandAttack6',
        {
            MasterPlatoonFunction = {'/maps/X1CA_Coop_005/X1CA_Coop_005_v03_m2fletcherai.lua', 'FletcherLandPlatoonThread'},
            Priority = 100,
        }
    )
    opai:SetChildQuantity('HeavyTanks', 12)
    opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumber', {'default_brain', 3})
    opai:SetLockingStyle('BuildTimer', {LockTimer = 36})

-- ========================================================================

    -- sends [mobile flak] (mission 3)
    opai = FletcherBase:AddOpAI('BasicLandAttack', 'M2_LandAttack7',
        {
            MasterPlatoonFunction = {'/maps/X1CA_Coop_005/X1CA_Coop_005_v03_m2fletcherai.lua', 'FletcherLandPlatoonThread'},
            Priority = 100,
        }
    )
    opai:SetChildQuantity('MobileFlak', 12)
    opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumber', {'default_brain', 3})
    opai:SetLockingStyle('BuildTimer', {LockTimer = 40})

-- ========================================================================

    -- Land Defense

    -- maintains 8, 6, 4 [heavy tanks]
    quantity = {8, 6, 4}
    opai = FletcherBase:AddOpAI('BasicLandAttack', 'M2_LandDefense1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Hex5_Main_LandDefEast_Chain', 'M1_Hex5_Main_LandDefWest_Chain'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('HeavyTanks', quantity[Difficulty])

-- ========================================================================

    -- maintains 6, 4, 2 [mobile missiles]
    quantity = {6, 4, 2}
    opai = FletcherBase:AddOpAI('BasicLandAttack', 'M2_LandDefense2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Hex5_Main_LandDefEast_Chain', 'M1_Hex5_Main_LandDefWest_Chain'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('MobileMissiles', quantity[Difficulty])

-- ========================================================================

    -- maintains 8, 6, 4 [mobile flak]
    quantity = {8, 6, 4}
    opai = FletcherBase:AddOpAI('BasicLandAttack', 'M2_LandDefense3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Hex5_Main_LandDefEast_Chain', 'M1_Hex5_Main_LandDefWest_Chain'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('MobileFlak', quantity[Difficulty])

-- ========================================================================

    -- maintains 6, 4, 2 [siege bots]
    quantity = {6, 4, 2}
    opai = FletcherBase:AddOpAI('BasicLandAttack', 'M2_LandDefense4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Hex5_Main_LandDefEast_Chain', 'M1_Hex5_Main_LandDefWest_Chain'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('SiegeBots', quantity[Difficulty])

-- ========================================================================

end

function FletcherBaseAmphibiousAttacks(platoon)
    local moveNum = false

    while(ArmyBrains[Fletcher]:PlatoonExists(platoon)) do
        if(ScenarioInfo.MissionNumber == 2) then
            if(not moveNum) then
                moveNum = 2
                IssueStop(platoon:GetPlatoonUnits())
                IssueClearCommands(platoon:GetPlatoonUnits())
                for k,v in platoon:GetPlatoonUnits() do
                    if(v and not v:IsDead()) then
                        ScenarioFramework.PlatoonPatrolChain(platoon, 'M2_Fletcher_LandAttack_Chain')
                    end
                end
            end
        elseif(ScenarioInfo.MissionNumber == 3) then
            if(not moveNum or moveNum ~= 3) then
                moveNum = 3
                IssueStop(platoon:GetPlatoonUnits())
                IssueClearCommands(platoon:GetPlatoonUnits())
                for k,v in platoon:GetPlatoonUnits() do
                    if(v and not v:IsDead()) then
                        ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_Fletcher_Fatboy_Attack_Chain')
                    end
                end
            end
        end
        WaitSeconds(10)
    end
end

function FletcherLandPlatoonThread(platoon)
    local moveNum = false

    while(ArmyBrains[Fletcher]:PlatoonExists(platoon)) do
        if(ScenarioInfo.MissionNumber == 2) then
            if(not moveNum) then
                moveNum = 2
                IssueStop(platoon:GetPlatoonUnits())
                IssueClearCommands(platoon:GetPlatoonUnits())
                ScenarioFramework.PlatoonPatrolChain(platoon, 'M2_Fletcher_LandAttack_Chain')
            end
        elseif(ScenarioInfo.MissionNumber == 3) then
            if(not moveNum or moveNum ~= 3) then
                moveNum = 3
                IssueStop(platoon:GetPlatoonUnits())
                IssueClearCommands(platoon:GetPlatoonUnits())
                ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_Fletcher_LandAttack_Chain')
            end
        end
        WaitSeconds(10)
    end
end

function M2FletcherBaseAirAttacks()
    local opai = nil
    local quantity = {}

    ----------------------------------
    -- Fletcher Base Op AI, Air Attacks
    ----------------------------------

    -- sends 12, 10, 8 [bombers]
    for i = 1, 2 do
        quantity = {12, 10, 8}
        opai = FletcherBase:AddOpAI('AirAttacks', 'M2_AirAttack1' .. i,
            {
                MasterPlatoonFunction = {'/maps/X1CA_Coop_005/X1CA_Coop_005_v03_m2fletcherai.lua', 'FletcherAirPlatoonThread'},
                Priority = 100,
            }
        )
        opai:SetChildQuantity('Bombers', quantity[Difficulty])
    end

    -- sends 8, 6, 4 [gunships]
    quantity = {12, 9, 6}
    opai = FletcherBase:AddOpAI('AirAttacks', 'M2_AirAttack2',
        {
            MasterPlatoonFunction = {'/maps/X1CA_Coop_005/X1CA_Coop_005_v03_m2fletcherai.lua', 'FletcherAirPlatoonThread'},
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])

    -- sends 12, 8, 6 [air superiority]
    quantity = {12, 9, 6}
    opai = FletcherBase:AddOpAI('AirAttacks', 'M2_AirAttack3',
        {
            MasterPlatoonFunction = {'/maps/X1CA_Coop_005/X1CA_Coop_005_v03_m2fletcherai.lua', 'FletcherAirPlatoonThread'},
            Priority = 100,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])

    -- sends 12, 8, 6 [heavy gunships] (mission 3) (Air Path)
    quantity = {12, 8, 6}
    opai = FletcherBase:AddOpAI('AirAttacks', 'M2_AirAttack4',
        {
            MasterPlatoonFunction = {'/maps/X1CA_Coop_005/X1CA_Coop_005_v03_m2fletcherai.lua', 'FletcherAirPlatoonThread'},
            Priority = 100,
        }
    )
    opai:SetChildQuantity('HeavyGunships', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumber', {'default_brain', 3})

    -- sends 24, 18, 9 [heavy gunships, gunships, bombers] (mission 3) (Land Path)
    quantity = {24, 18, 9}
    opai = FletcherBase:AddOpAI('AirAttacks', 'M2_AirAttack5',
        {
            MasterPlatoonFunction = {'/maps/X1CA_Coop_005/X1CA_Coop_005_v03_m2fletcherai.lua', 'FletcherLandPlatoonThread'},
            Priority = 90,
        }
    )
    opai:SetChildQuantity({'HeavyGunships', 'Gunships', 'Bombers'}, quantity[Difficulty])
    opai:SetLockingStyle('None')
    opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumber', {'default_brain', 3})


    -- Air Defense

    -- maintains 12, 10, 8 [interceptors]
    quantity = {6, 5, 4}
    for i = 1, 2 do
        opai = FletcherBase:AddOpAI('AirAttacks', 'M2_AirDefense' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M1_Hex5_Main_AirDef_Chain',
                },
                Priority = 110,
            }
        )
        opai:SetChildQuantity('Interceptors', quantity[Difficulty])
    end

    -- maintains 24, 16, 12 [air superiority]
    quantity = {6, 4, 3}
    for i = 3, 6 do
        opai = FletcherBase:AddOpAI('AirAttacks', 'M2_AirDefense' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M1_Hex5_Main_AirDef_Chain',
                },
                Priority = 110,
            }
        )
        opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    end

    -- maintains 12 [heavy gunships]
    for i = 7, 8 do
        opai = FletcherBase:AddOpAI('AirAttacks', 'M2_AirDefense' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M1_Hex5_Main_AirDef_Chain',
                },
                Priority = 110,
            }
        )
        opai:SetChildQuantity('HeavyGunships', 6)
    end

    -- maintains 12 [torpedo bombers] (mission 3)
    for i = 9, 10 do
        opai = FletcherBase:AddOpAI('AirAttacks', 'M2_AirDefense' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M2_Fletcher_TorpedoAirDef_Chain',
                },
                Priority = 110,
            }
        )
        opai:SetChildQuantity('TorpedoBombers', 6)
        opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumber', {'default_brain', 3})
    end
end

function FletcherAirPlatoonThread(platoon)
    local moveNum = false

    while(ArmyBrains[Fletcher]:PlatoonExists(platoon)) do
        if(ScenarioInfo.MissionNumber == 2) then
            if(not moveNum) then
                moveNum = 2
                IssueStop(platoon:GetPlatoonUnits())
                IssueClearCommands(platoon:GetPlatoonUnits())
                ScenarioFramework.PlatoonPatrolChain(platoon, 'M2_Fletcher_AirAttack_Chain')
            end
        elseif(ScenarioInfo.MissionNumber == 3) then
            if(not moveNum or moveNum ~= 3) then
                moveNum = 3
                IssueStop(platoon:GetPlatoonUnits())
                IssueClearCommands(platoon:GetPlatoonUnits())
--           ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_Fletcher_Air_Attack_Chain')
                for k, v in platoon:GetPlatoonUnits() do
                    if(v and not v:IsDead()) then
                           ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M3_QAI_Main_Base_AirDef_Chain')))
                    end
                end
            end
        end
        WaitSeconds(10)
    end
end

function DisableBase()
    if(FletcherBase) then
        FletcherBase:SetBuild('Engineers', false)
        FletcherBase:SetBuildAllStructures(false)
        FletcherBase:SetActive('AirScouting', false)
        FletcherBase:SetActive('LandScouting', false)
        FletcherBase:BaseActive(false)
    end
end

-- ========================================================================
-- ========================================================================
