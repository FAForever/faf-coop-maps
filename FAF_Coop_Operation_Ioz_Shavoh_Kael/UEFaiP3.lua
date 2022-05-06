local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local CustomFunctions = '/maps/FAF_Coop_Operation_Ioz_Shavoh_Kael/FAF_Coop_Operation_Ioz_Shavoh_Kael_CustomFunctions.lua'
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')

local Player1 = 1
local UEF = 5

local P3UBase1 = BaseManager.CreateBaseManager()
local P3UBase2 = BaseManager.CreateBaseManager()
local P3UBase3 = BaseManager.CreateBaseManager()
local P3UBase4 = BaseManager.CreateBaseManager()

local Difficulty = ScenarioInfo.Options.Difficulty

function M3UEFFatboyBaseAI()
    P3UBase1:InitializeDifficultyTables(ArmyBrains[UEF], 'P3UEFFatboybase1', 'P3UB2MK1', 15, {P3USbase2 = 100})
    P3UBase1:StartNonZeroBase({{2, 4, 6}, {2, 4, 6}})

    M3UEFFatboyattacks1()
    
    local M2_Fatboy = ScenarioInfo.M2_Fatboy 
    local location
            for num, loc in ArmyBrains[UEF].PBM.Locations do
                if loc.LocationType == 'P3UEFFatboybase1' then
                    location = loc
                    break
                end
            end
    
    if not M2_Fatboy:IsDead() then
        location.PrimaryFactories.Land = M2_Fatboy
        IssueFactoryRallyPoint({M2_Fatboy}, ScenarioUtils.MarkerToPosition('Rally Point 19') )
    end
end

function M3UEFFatboyBase2AI()
    P3UBase3:InitializeDifficultyTables(ArmyBrains[UEF], 'P3UEFFatboybase2', 'P3UB2MK2', 15, {P3USbase3 = 100})
    P3UBase3:StartNonZeroBase({{2, 4, 6}, {2, 4, 6}})

    M3UEFFatboyattacks2()
    
    local M2_Fatboy2 = ScenarioInfo.M2_Fatboy2 
    local location
            for num, loc in ArmyBrains[UEF].PBM.Locations do
                if loc.LocationType == 'P3UEFFatboybase2' then
                    location = loc
                    break
                end
            end
    
    if not M2_Fatboy2:IsDead() then
        location.PrimaryFactories.Land = M2_Fatboy2
        IssueFactoryRallyPoint({M2_Fatboy2}, ScenarioUtils.MarkerToPosition('Rally Point 21') )
    end
end

function M3UEFAtlantisBaseAI()
    P3UBase2:InitializeDifficultyTables(ArmyBrains[UEF], 'P3UEFseabase', 'P3UB1MK1', 27, {P3USbase = 100})
    P3UBase2:StartNonZeroBase(2)

    M3UEFAtlantisBaseAirAttacks()
    
    ForkThread(
        function()
            -- Wait for the carrier to be spawned
            WaitSeconds(1)

            local Carrier1 = ScenarioInfo.M2Atlantis 
            local location
            for num, loc in ArmyBrains[UEF].PBM.Locations do
                if loc.LocationType == 'P3UEFseabase' then
                    location = loc
                    break
                end
            end
            location.PrimaryFactories.Air = Carrier1
            while Carrier1 and not Carrier1.Dead do
                if table.getn(Carrier1:GetCargo()) > 0 and Carrier1:IsIdleState() then
                    IssueClearCommands({Carrier1})
                    IssueTransportUnload({Carrier1}, ScenarioUtils.MarkerToPosition('Rally Point 14'))
                end
                WaitSeconds(1)
            end
        end
    )
end

function M3UEFAtlantisBase2AI()
    P3UBase4:InitializeDifficultyTables(ArmyBrains[UEF], 'P3UEFseabase2', 'P3UB1MK2', 27, {P3USbase4 = 100})
    P3UBase4:StartNonZeroBase(2)

    M3UEFAtlantisBaseAirAttacks2()
    
    ForkThread(
        function()
            -- Wait for the carrier to be spawned
            WaitSeconds(1)

            local Carrier2 = ScenarioInfo.M2Atlantis2 
            local location
            for num, loc in ArmyBrains[UEF].PBM.Locations do
                if loc.LocationType == 'P3UEFseabase2' then
                    location = loc
                    break
                end
            end
            location.PrimaryFactories.Air = Carrier2
            while Carrier2 and not Carrier2.Dead do
                if table.getn(Carrier2:GetCargo()) > 0 and Carrier2:IsIdleState() then
                    IssueClearCommands({Carrier2})
                    IssueTransportUnload({Carrier2}, ScenarioUtils.MarkerToPosition('Rally Point 20'))
                end
                WaitSeconds(1)
            end
        end
    )  
end

function M3UEFAtlantisBaseAirAttacks()

    local quantity = {}

    quantity = {6, 8, 10}
    local Temp = {
        'P3U1B1AttackTemp0',
        'NoPlan',
        { 'uea0203', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
    }
    local Builder = {
        BuilderName = 'P3U1B1AttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P3UEFseabase',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3UB1airattack1','P3UB1airattack2', 'P3UB1airattack3'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
    
    quantity = {6, 7, 9}
    Temp = {
        'P3U1B1AttackTemp1',
        'NoPlan',
        { 'uea0204', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
    }
    Builder = {
        BuilderName = 'P3U1B1AttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 105,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P3UEFseabase',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 25, categories.NAVAL * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3UB1airattack1','P3UB1airattack2', 'P3UB1airattack3'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
    
    quantity = {5, 6, 7}
    Temp = {
        'P3U1B1AttackTemp2',
        'NoPlan',
        { 'uea0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
    }
    Builder = {
        BuilderName = 'P3U1B1AttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 110,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P3UEFseabase',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 25, categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3UB1airattack1','P3UB1airattack2', 'P3UB1airattack3'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
    
    quantity = {3, 4, 5}
    Temp = {
        'P3U1B1AttackTemp3',
        'NoPlan',
        { 'uea0304', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
    }
    Builder = {
        BuilderName = 'P3U1B1AttackBuilder3',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 107,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P3UEFseabase',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 30, categories.STRUCTURE * categories.DEFENSE - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3UB1airattack1','P3UB1airattack2', 'P3UB1airattack3'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
end

function M3UEFAtlantisBaseAirAttacks2()

    local quantity = {}

    quantity = {4, 5, 6}
    local Temp = {
        'P3U1B2AttackTemp0',
        'NoPlan',
        { 'uea0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
    }
    local Builder = {
        BuilderName = 'P3U1B2AttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P3UEFseabase2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3UB1airattack1','P3UB1airattack2', 'P3UB1airattack3'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
    
    quantity = {5, 6, 7}
    Temp = {
        'P3U1B2AttackTemp1',
        'NoPlan',
        { 'uea0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
    }
    Builder = {
        BuilderName = 'P3U1B2AttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 110,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P3UEFseabase2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 20, categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3UB1airattack1','P3UB1airattack2', 'P3UB1airattack3'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
    
    quantity = {5, 7, 9}
    Temp = {
        'P3U1B2AttackTemp2',
        'NoPlan',
        { 'uea0204', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },   
    }
    Builder = {
        BuilderName = 'P3U1B2AttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 105,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'P3UEFseabase2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 20, categories.NAVAL * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3UB1airattack1','P3UB1airattack2', 'P3UB1airattack3'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
end

function M3UEFFatboyattacks1()

    local quantity = {}

    quantity = {4, 5, 6}
    local Temp = {
        'P3UFBLAttackTemp0',
        'NoPlan',
        { 'uel0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    local Builder = {
        BuilderName = 'P3UFBLAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P3UEFFatboybase1',
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P3ULandchain1'
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
    
    quantity = {2, 3, 4}
    Temp = {
        'P3UFBLAttackTemp1',
        'NoPlan',
        { 'uel0304', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P3UFBLAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 110,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P3UEFFatboybase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 25, categories.STRUCTURE * categories.DEFENSE - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P3ULandchain1'
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
    
    quantity = {4, 5, 6}
    Temp = {
        'P3UFBLAttackTemp2',
        'NoPlan',
        { 'xel0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uel0307', 1, 2, 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P3UFBLAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 105,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P3UEFFatboybase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 2, categories.EXPERIMENTAL}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P3ULandchain1'
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
end

function M3UEFFatboyattacks2()

    local quantity = {}

    quantity = {4, 5, 6}
    local Temp = {
        'P3UFB2LAttackTemp0',
        'NoPlan',
        { 'uel0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    local Builder = {
        BuilderName = 'P3UFB2LAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 4,
        Priority = 100,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P3UEFFatboybase2',
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P3ULandchain2'
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
    
    quantity = {2, 3, 4}
    Temp = {
        'P3UFB2LAttackTemp1',
        'NoPlan',
        { 'uel0304', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P3UFB2LAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 110,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P3UEFFatboybase2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 25, categories.STRUCTURE * categories.DEFENSE - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P3ULandchain2'
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
    
    quantity = {4, 5, 6}
    Temp = {
        'P3UFB2LAttackTemp2',
        'NoPlan',
        { 'xel0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uel0307', 1, 2, 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P3UFB2LAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 2,
        Priority = 105,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P3UEFFatboybase2',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, 2, categories.EXPERIMENTAL}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P3ULandchain2'
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
end
    