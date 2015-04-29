-- ****************************************************************************
-- **
-- **  File     : /maps/X1CA_Coop_003/X1CA_Coop_003_v02_m1rhizaai.lua
-- **  Author(s): Jessica St. Croix
-- **
-- **  Summary  : Rhiza army AI for Mission 1 - X1CA_Coop_003
-- **
-- **  Copyright © 2007 Gas Powered Games, Inc.  All rights reserved.
-- ****************************************************************************
local BaseManager = import('/lua/ai/opai/basemanager.lua')
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local OpStrings = import('/maps/X1CA_Coop_003/X1CA_Coop_003_v02_strings.lua')
local PingGroups = import('/lua/ScenarioFramework.lua').PingGroups

local SPAIFileName = '/lua/ScenarioPlatoonAI.lua'

--------
-- Locals
--------
local Rhiza = 3

---------------
-- Base Managers
---------------
local M1RhizaBase = BaseManager.CreateBaseManager()

function M1RhizaBaseAI()

    ---------------
    -- M1 Rhiza Base
    ---------------
    M1RhizaBase:InitializeDifficultyTables(
        ArmyBrains[Rhiza],
        'M1_Rhiza_Base',
        'Rhiza_M1_Base',
        260,
        {
             M1_Rhiza_Base = 500,
        }
    )
    M1RhizaBase:StartNonZeroBase({10, 8})
    M1RhizaBase:SetMaximumConstructionEngineers(5)
    M1RhizaBase:SetConstructionAlwaysAssist(true)
    M1RhizaBase:SetActive('AirScouting', true)

    M1RhizaBase:AddBuildGroup('M1_Rhiza_NoRebuild', 400)
    M1RhizaBase:AddBuildGroup('Rhiza_Base_Wreckage', 450)

    ArmyBrains[Rhiza]:PBMSetCheckInterval(4)

    M1RhizaBaseLandAttacks()
    M1RhizaBaseAirAttacks()
    M1RhizaBaseNavalAttacks()
    -- M1RhizaTransports()
end

function M1RhizaBaseExperimentalAttacks()
    local opai = nil

    opai = M1RhizaBase:AddOpAI('Colossus_1',
        {
            Amount = 1,
            KeepAlive = true,
            PlatoonAIFunction = {'/maps/X1CA_Coop_003/X1CA_Coop_003_v02_script.lua', 'ColossusPing'},
            MaxAssist = 5,
            Retry = true,
            WaitSecondsAfterDeath = 480,
        }
    )
end

function M1RhizaBaseLandAttacks()
    local opai = nil

    -----------------------------------
    -- M1 Rhiza Base Op AI, Land Attacks
    -----------------------------------

    -- ##################
    -- CUSTOM PLATOONS #
    -- ##################

    local EngineerLandTemp = {
        'EngineerLandTemp',
        'NoPlan',
        { 'ual0309', 1, 1, 'Attack', 'GrowthFormation' },    -- Engineers
    }
    local EngineerLandBuilder = {
        BuilderName = 'EngineerLandBuilder',
        PlatoonTemplate = EngineerLandTemp,
        InstanceCount = 15,
        PlatoonAIPlan = 'DisbandAI',
        Priority = 5115,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        BuildConditions = {
            { '/lua/editor/unitcountbuildconditions.lua', 'HaveLessThanUnitsWithCategory', {'default_brain', 10, categories.ual0309}},
        },
        LocationType = 'M1_Rhiza_Base',
    }
    ArmyBrains[Rhiza]:PBMAddPlatoon( EngineerLandBuilder )

    local template = {
        'AmphibiousLandTemp',
        'NoPlan',
        { 'xal0203', 1, 4, 'Attack', 'GrowthFormation' },    -- Amph Tanks
        { 'ual0307', 1, 2, 'Attack', 'GrowthFormation' },    -- Mobile Shields
        { 'ual0205', 1, 3, 'Attack', 'GrowthFormation' },    -- Mobile Flak
    }
    local builder = {
        BuilderName = 'AmphibiousLand1',
        PlatoonTemplate = template,
        InstanceCount = 2,
        Priority = 90,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'M1_Rhiza_Base',
        PlatoonAIFunction = {'/maps/X1CA_Coop_003/X1CA_Coop_003_v02_m1rhizaai.lua', 'M1RhizaAirAttackAI'},
    }
    ArmyBrains[Rhiza]:PBMAddPlatoon( builder )

    -- Defense
    for i = 1, 6 do
        opai = M1RhizaBase:AddOpAI('BasicLandAttack', 'Rhiza_AmphibiousDefense_' .. i,
            {
                MasterPlatoonFunction = {'/maps/X1CA_Coop_003/X1CA_Coop_003_v02_m1rhizaai.lua', 'RhizaNavalDEFENSEAI'},
                Priority = 110,
            }
        )
        opai:SetChildQuantity('MobileFlak', 1)
    end

    for i = 7, 8 do
        opai = M1RhizaBase:AddOpAI('BasicLandAttack', 'Rhiza_AmphibiousDefense_' .. i,
            {
                MasterPlatoonFunction = {'/maps/X1CA_Coop_003/X1CA_Coop_003_v02_m1rhizaai.lua', 'RhizaNavalDEFENSEAI'},
                Priority = 100,
            }
        )
        opai:SetChildQuantity('AmphibiousTanks', 4)
    end

end

function M1RhizaBaseAirAttacks()
    local opai = nil

    ----------------------------------
    -- M1 Rhiza Base Op AI, Air Attacks
    ----------------------------------

    -- sends [air superiority, gunships, bombers]
    opai = M1RhizaBase:AddOpAI('AirAttacks', 'M1_AirAttacks1',
        {
            MasterPlatoonFunction = {'/maps/X1CA_Coop_003/X1CA_Coop_003_v02_m1rhizaai.lua', 'M1RhizaAirAttackAI'},
            Priority = 1180,
        }
    )
    opai:SetChildQuantity({'AirSuperiority', 'Gunships', 'Bombers'}, 12)
    opai:SetLockingStyle('DeathTimer', {LockTimer = 30})

    -- sends all but [strat bombers]
    opai = M1RhizaBase:AddOpAI('AirAttacks', 'M1_AirAttacks2',
        {
            MasterPlatoonFunction = {'/maps/X1CA_Coop_003/X1CA_Coop_003_v02_m1rhizaai.lua', 'M1RhizaAirAttackAI'},
            Priority = 100,
        }
    )
    opai:SetChildActive('StratBombers', false)

    -- sends Gunships - Heavy Gunships - spy plane
    local template = {
        'Air_HeavyGunships_AirSup_SPY_Gunships_Temp',
        'NoPlan',
        { 'xaa0305', 1, 4, 'Attack', 'GrowthFormation' },    -- Heavy Gunships
        { 'uaa0303', 1, 2, 'Attack', 'GrowthFormation' },    -- Air Superiority
        { 'uaa0203', 1, 8, 'Attack', 'GrowthFormation' },    -- Gunships
        { 'uaa0302', 1, 2, 'Attack', 'GrowthFormation' },    -- Spy Plane
    }
    local builder = {
        BuilderName = 'Air_HeavyGunships_AirSup_SPY_Gunships',
        PlatoonTemplate = template,
        Priority = 110,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'M1_Rhiza_Base',
        PlatoonAIFunction = {'/maps/X1CA_Coop_003/X1CA_Coop_003_v02_m1rhizaai.lua', 'M1RhizaAirAttackAI'},
    }
    ArmyBrains[Rhiza]:PBMAddPlatoon( builder )

    -- sends [air superiority, gunships, bombers] ( mission 3 )
    opai = M1RhizaBase:AddOpAI('AirAttacks', 'M3_AirAttacks1',
        {
            MasterPlatoonFunction = {'/maps/X1CA_Coop_003/X1CA_Coop_003_v02_m1rhizaai.lua', 'M1RhizaAirAttackAI'},
            Priority = 90,
        }
    )
    opai:SetChildQuantity({'AirSuperiority', 'Gunships', 'Bombers'}, 18)
    opai:SetLockingStyle('None')
    opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 3})

    -- ##############
    -- Air Defense #
    -- ##############

    for i = 1, 2 do
        opai = M1RhizaBase:AddOpAI('AirAttacks', 'M1_AirDefense_Player_1' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M2_Rhiza_AirDef_Player_Chain',
                },
                Priority = 1130,
            }
        )
        opai:SetChildActive('All', false)
        opai:SetChildActive('AirSuperiority', true)
        opai:SetChildCount(1)
    end

    opai = M1RhizaBase:AddOpAI('AirAttacks', 'M1_AirDefense_Player_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Rhiza_AirDef_Player_Chain',
            },
        Priority = 120,
        }
    )
    opai:SetChildQuantity('Gunships', 4)

    for i = 1, 3 do
        opai = M1RhizaBase:AddOpAI('AirAttacks', 'M1_AirDefense_1_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M1_Rhiza_AirDef_Chain',
                },
                Priority = 1130,
            }
        )
        opai:SetChildActive('All', false)
        opai:SetChildActive('AirSuperiority', true)
        opai:SetChildCount(1)
    end

    for i = 1, 2 do
        opai = M1RhizaBase:AddOpAI('AirAttacks', 'M1_AirDefense_2_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M1_Rhiza_AirDef_Chain',
                },
                Priority = 130,
            }
        )
        opai:SetChildActive('All', false)
        opai:SetChildActive('Gunships', true)
        opai:SetChildCount(1)
    end

    for i = 1, 2 do
        opai = M1RhizaBase:AddOpAI('AirAttacks', 'M1_AirDefense_3_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M1_Rhiza_AirDef_Chain',
                },
                Priority = 120,
            }
        )
        opai:SetChildActive('All', false)
        opai:SetChildActive('CombatFighters', true)
        opai:SetChildCount(1)
    end
end

function M1RhizaBaseNavalAttacks()
    local opai = nil

    ------------------------------------
    -- M1 Rhiza Base Op AI, Naval Attacks
    ------------------------------------
    -- sends 15 frigate power of all but T3
    opai = M1RhizaBase:AddNavalAI('Rhiza_NavalAttack2',
        {
            MasterPlatoonFunction = {'/maps/X1CA_Coop_003/X1CA_Coop_003_v02_m1rhizaai.lua', 'M1RhizaNavalAttackAI'},
            MaxFrigates = 15,
            MinFrigates = 15,
            Priority = 90,
        }
    )
    opai:SetChildActive('T3', false)
    ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----
    -- sends 8 frigate power of all but T3
    opai = M1RhizaBase:AddNavalAI('Rhiza_NavalAttack3',
        {
            MasterPlatoonFunction = {'/maps/X1CA_Coop_003/X1CA_Coop_003_v02_m1rhizaai.lua', 'M1RhizaNavalAttackAI'},
            MaxFrigates = 8,
            MinFrigates = 8,
            Priority = 95,
        }
    )
    opai:SetChildActive('T3', false)
    ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----
    opai = M1RhizaBase:AddNavalAI('Rhiza_M2_NavalAttack1',
        {
            MasterPlatoonFunction = {'/maps/X1CA_Coop_003/X1CA_Coop_003_v02_m1rhizaai.lua', 'M1RhizaNavalAttackAI'},
            MaxFrigates = 20,
            MinFrigates = 20,
            Priority = 105,
        }
    )
    opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 2})
    ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----
    opai = M1RhizaBase:AddNavalAI('Rhiza_M2_NavalAttack2',
        {
            MasterPlatoonFunction = {'/maps/X1CA_Coop_003/X1CA_Coop_003_v02_m1rhizaai.lua', 'M1RhizaNavalAttackAI'},
            MaxFrigates = 20,
            MinFrigates = 20,
            Priority = 105,
        }
    )
    opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 2})
    ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----
    for i = 1, 2 do
        opai = M1RhizaBase:AddNavalAI('Rhiza_M2_NavalAttack3' .. i,
            {
                MasterPlatoonFunction = {'/maps/X1CA_Coop_003/X1CA_Coop_003_v02_m1rhizaai.lua', 'M1RhizaNavalAttackAI'},
                MaxFrigates = 15,
                MinFrigates = 15,
                Priority = 100,
            }
        )
        opai:SetChildActive('T3', false)
        opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 2})
    end
    ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----
    for i = 1, 2 do
        opai = M1RhizaBase:AddNavalAI('Rhiza_M3_NavalAttack1' .. i,
            {
                MasterPlatoonFunction = {'/maps/X1CA_Coop_003/X1CA_Coop_003_v02_m1rhizaai.lua', 'M1RhizaNavalAttackAI'},
                MaxFrigates = 20,
                MinFrigates = 20,
                Priority = 100,
            }
        )
        opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 3})
        opai:SetChildActive('T3', false)
    end
    ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----
    -- ################
    -- Naval Defense #
    -- ################

    local template = {
        'NavalDefense1Temp',
        'NoPlan',
        { 'uas0201', 1, 1, 'Attack', 'GrowthFormation' },    -- Destroyer
        { 'uas0202', 1, 2, 'Attack', 'GrowthFormation' },    -- Cruisers
        { 'uas0201', 1, 1, 'Attack', 'GrowthFormation' },    -- Destroyer
        { 'xas0204', 1, 2, 'Attack', 'GrowthFormation' },    -- Sub Hunters
    }
    local builder = {
        BuilderName = 'NavalDefense1',
        PlatoonTemplate = template,
        InstanceCount = 1,
        Priority = 130,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'M1_Rhiza_Base',
        PlatoonAIFunction = {'/maps/X1CA_Coop_003/X1CA_Coop_003_v02_m1rhizaai.lua', 'RhizaNavalDEFENSEAI'},
    }
    ArmyBrains[Rhiza]:PBMAddPlatoon( builder )

    template = {
        'SubmarineDefenseTemp',
        'NoPlan',
        { 'xas0204', 1, 4, 'Attack', 'GrowthFormation' },    -- Sub Hunters
    }
    builder = {
        BuilderName = 'SubmarineDefenseTemp',
        PlatoonTemplate = template,
        InstanceCount = 1,
        Priority = 120,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'M1_Rhiza_Base',
        PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
        PlatoonData = {
            PatrolChain = 'M1_Rhiza_SubDef_Chain',
        },
    }
    ArmyBrains[Rhiza]:PBMAddPlatoon( builder )

    for i = 1, 2 do
        opai = M1RhizaBase:AddNavalAI('Rhiza_M1_NavalDefense_' .. i,
            {
                MasterPlatoonFunction = {'/maps/X1CA_Coop_003/X1CA_Coop_003_v02_m1rhizaai.lua', 'RhizaNavalDEFENSEAI'},
                MaxFrigates = 15,
                MinFrigates = 15,
                Priority = 110,
            }
        )
        opai:SetChildActive('T3', false)
    end
    ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----
    opai = M1RhizaBase:AddNavalAI('M2_NavalDefense_Additional',
        {
            MasterPlatoonFunction = {'/maps/X1CA_Coop_003/X1CA_Coop_003_v02_m1rhizaai.lua', 'RhizaNavalDEFENSEAI'},
            MaxFrigates = 20,
            MinFrigates = 20,
            Priority = 120,
        }
    )
    opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumberGreaterOrEqual', {'default_brain', 2})

end

function M1RhizaAirAttackAI(platoon)
    local moveNum = false
    while(ArmyBrains[Rhiza]:PlatoonExists(platoon)) do
        if(ScenarioInfo.MissionNumber == 1) then
            if(not moveNum) then
                moveNum = 1
                IssueStop(platoon:GetPlatoonUnits())
                IssueClearCommands(platoon:GetPlatoonUnits())
                for k, v in platoon:GetPlatoonUnits() do
                    if(v and not v:IsDead()) then
                        ScenarioFramework.PlatoonPatrolRoute(platoon, ScenarioUtils.ChainToPositions('M1_Rhiza_Air_Attack' .. Random(1,2) .. '_Chain')) -- ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M1_Rhiza_Air_Attack' .. Random(1,2) .. '_Chain')))
                    end
                end
            end
        elseif(ScenarioInfo.MissionNumber == 2) then
            if(not moveNum or moveNum ~= 2) then
                moveNum = 2
                IssueStop(platoon:GetPlatoonUnits())
                IssueClearCommands(platoon:GetPlatoonUnits())
                for k, v in platoon:GetPlatoonUnits() do
                    if(v and not v:IsDead()) then
                        ScenarioFramework.PlatoonPatrolChain(platoon, 'M2_Rhiza_Air_Attack_Chain')
                        -- ScenarioFramework.PlatoonPatrolRoute(platoon, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M2_Rhiza_Air_Attack_Chain')))
                    end
                end
            end
        elseif(ScenarioInfo.MissionNumber == 3) then
            if(not moveNum or moveNum ~= 3) then
                moveNum = 3
                IssueStop(platoon:GetPlatoonUnits())
                IssueClearCommands(platoon:GetPlatoonUnits())
                for k, v in platoon:GetPlatoonUnits() do
                    if(v and not v:IsDead()) then
                        ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_Rhiza_AirAttack_Chain')
                        -- ScenarioFramework.PlatoonPatrolRoute(platoon, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M3_Rhiza_AirAttack_Chain')))
                    end
                end
            end
        end
        WaitSeconds(10)
    end
end

function M1RhizaNavalAttackAI(platoon)
    local moveNum = false
    while(ArmyBrains[Rhiza]:PlatoonExists(platoon)) do
        if(ScenarioInfo.MissionNumber == 1) then
            if(not moveNum) then
                moveNum = 1
                IssueStop(platoon:GetPlatoonUnits())
                IssueClearCommands(platoon:GetPlatoonUnits())
                for k, v in platoon:GetPlatoonUnits() do
                    if(v and not v:IsDead()) then
                        ScenarioFramework.PlatoonPatrolRoute(platoon, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M1_Rhiza_Naval_Attack' .. Random(1,2) .. '_Chain')))
                    end
                end
            end
        elseif(ScenarioInfo.MissionNumber == 2) then
            if(not moveNum or moveNum ~= 2) then
                moveNum = 2
                IssueStop(platoon:GetPlatoonUnits())
                IssueClearCommands(platoon:GetPlatoonUnits())
                for k, v in platoon:GetPlatoonUnits() do
                    if(v and not v:IsDead()) then
                        ScenarioFramework.PlatoonPatrolChain(platoon, 'M2_Rhiza_Naval_Attack_' .. Random(1,3) .. '_Chain')
                    end
                end
            end
        elseif(ScenarioInfo.MissionNumber == 3) then
            if(not moveNum or moveNum ~= 3) then
                moveNum = 3
                IssueStop(platoon:GetPlatoonUnits())
                IssueClearCommands(platoon:GetPlatoonUnits())
                for k, v in platoon:GetPlatoonUnits() do
                    if(v and not v:IsDead()) then
                        ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_Rhiza_NavalAttack_Chain')
                    end
                end
            end
        end
        WaitSeconds(10)
    end
end

function RhizaNavalDEFENSEAI(platoon)
    local moveNum = false
    while(ArmyBrains[Rhiza]:PlatoonExists(platoon)) do
        if(ScenarioInfo.MissionNumber == 1) then
            if(not moveNum) then
                moveNum = 1
                IssueStop(platoon:GetPlatoonUnits())
                IssueClearCommands(platoon:GetPlatoonUnits())
                for k, v in platoon:GetPlatoonUnits() do
                    if(v and not v:IsDead()) then
                        ScenarioFramework.PlatoonPatrolChain(platoon, 'M1_Rhiza_NavalDef_Chain')
                    end
                end
            end
        elseif(ScenarioInfo.MissionNumber == 2) then
            if(not moveNum or moveNum ~= 2) then
                moveNum = 2
                IssueStop(platoon:GetPlatoonUnits())
                IssueClearCommands(platoon:GetPlatoonUnits())
                for k, v in platoon:GetPlatoonUnits() do
                    if(v and not v:IsDead()) then
                        ScenarioFramework.PlatoonPatrolChain(platoon, 'M2_Rhiza_NavalDef_Chain')
                    end
                end
            end
        elseif(ScenarioInfo.MissionNumber == 3) then
            if(not moveNum or moveNum ~= 3) then
                moveNum = 3
                IssueStop(platoon:GetPlatoonUnits())
                IssueClearCommands(platoon:GetPlatoonUnits())
                for k, v in platoon:GetPlatoonUnits() do
                    if(v and not v:IsDead()) then
                        ScenarioFramework.PlatoonPatrolRoute(platoon, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M3_Rhiza_NavalAttack_Chain')))
                    end
                end
            end
        end
        WaitSeconds(10)
    end
end

function RhizaExperimentals()
    -- M1RhizaBase:SetEngineerCount({{20, 14, 9}, {16, 12, 8}})

    local opai = nil



    opai = M1RhizaBase:AddOpAI('Colossus_2',
        {
            Amount = 1,
            KeepAlive = true,
            PlatoonAIFunction = {'/maps/X1CA_Coop_003/X1CA_Coop_003_v02_m1rhizaai.lua', 'Colossus2AI'},
            MaxAssist = 5,
            Retry = true,
        }
    )

end

function Colossus1AI(platoon)
    local moveNum = false

    while(ArmyBrains[Rhiza]:PlatoonExists(platoon)) do
        if(ScenarioInfo.MissionNumber == 2) then
            if(not moveNum) then
                moveNum = 2
                IssueStop(platoon:GetPlatoonUnits())
                IssueClearCommands(platoon:GetPlatoonUnits())
                for k, v in platoon:GetPlatoonUnits() do
                    if(v and not v:IsDead()) then
                        ScenarioFramework.PlatoonPatrolChain(platoon, 'M2_Rhiza_Colossus_1_Chain')
                    end
                end
            end
        elseif(ScenarioInfo.MissionNumber == 3) then
            if(not moveNum or moveNum ~= 2) then
                moveNum = 3
                IssueStop(platoon:GetPlatoonUnits())
                IssueClearCommands(platoon:GetPlatoonUnits())
                for k, v in platoon:GetPlatoonUnits() do
                    if(v and not v:IsDead()) then
                        ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_Rhiza_Colossus_Chain')
                    end
                end
            end
        end
        WaitSeconds(10)
    end
end

function Colossus2AI(platoon)
    local moveNum = false

    while(ArmyBrains[Rhiza]:PlatoonExists(platoon)) do
        if(ScenarioInfo.MissionNumber == 2) then
            if(not moveNum) then
                moveNum = 2
                IssueStop(platoon:GetPlatoonUnits())
                IssueClearCommands(platoon:GetPlatoonUnits())
                for k, v in platoon:GetPlatoonUnits() do
                    if(v and not v:IsDead()) then
                        ScenarioFramework.PlatoonPatrolChain(platoon, 'M2_Rhiza_Colossus_2_Chain')
                    end
                end
            end
        elseif(ScenarioInfo.MissionNumber == 3) then
            if(not moveNum or moveNum ~= 2) then
                moveNum = 3
                IssueStop(platoon:GetPlatoonUnits())
                IssueClearCommands(platoon:GetPlatoonUnits())
                for k, v in platoon:GetPlatoonUnits() do
                    if(v and not v:IsDead()) then
                        ScenarioFramework.PlatoonPatrolChain(platoon, 'M3_Rhiza_Colossus_Chain')
                    end
                end
            end
        end
        WaitSeconds(10)
    end
end

function M1RhizaTransports()
    local opai = nil

    opai = M1RhizaBase:AddOpAI('EngineerAttack', 'M1_RhizaEngAttack1',
    {
        MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
        PlatoonData = {
            AttackChain = 'M1_Rhiza_NavalDef_Chain',
            LandingChain = 'M1_Rhiza_NavalDef_Chain',
            TransportReturn = 'Rhiza_M1_Base',
        },
        Priority = 1000,
    })
    opai:SetChildActive('All', false)
    opai:SetChildActive('T2Transports', true)
    opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
        'HaveLessThanUnitsWithCategory', {'default_brain', 2, categories.uaa0104})

end

function DisableBase()
    if(M1RhizaBase) then
        M1RhizaBase:BaseActive(false)
    end
end
