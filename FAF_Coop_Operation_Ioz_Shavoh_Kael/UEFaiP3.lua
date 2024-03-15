local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/scenarioplatoonai.lua'
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local CustomFunctions = '/maps/FAF_Coop_Operation_Ioz_Shavoh_Kael/FAF_Coop_Operation_Ioz_Shavoh_Kael_CustomFunctions.lua'

local Player1 = 1
local UEF = 5

local P3UBaseECO = BaseManager.CreateBaseManager()
local P3UBase1 = BaseManager.CreateBaseManager()
local P3UBase2 = BaseManager.CreateBaseManager()
local P3UBase3 = BaseManager.CreateBaseManager()
local P3UBase4 = BaseManager.CreateBaseManager()

local Difficulty = ScenarioInfo.Options.Difficulty

function M3UEFECOBaseAI()
    P3UBaseECO:InitializeDifficultyTables(ArmyBrains[UEF], 'P3UEFECO', 'P3UBECO', 50, {P3ECO = 100})
    P3UBaseECO:StartNonZeroBase({2, 4, 6})
    P3UBaseECO:SetMaximumConstructionEngineers(6)
    P3UBaseECO:AddBuildGroup('P3UDefense2', 90)
end

function M3UEFFatboyBaseAI()
    P3UBase1:InitializeDifficultyTables(ArmyBrains[UEF], 'P3UEFFatboybase1', 'P3UB2MK1', 20, {P3USbase2 = 100})
    P3UBase1:StartNonZeroBase({{5, 7, 9}, {2, 3, 4}})
    P3UBase1:SetMaximumConstructionEngineers(5)
    P3UBase1:AddBuildGroup('P3UDefense1', 90)

    if Difficulty == 3 then
        ArmyBrains[UEF]:PBMSetCheckInterval(6)
    end
    
    local M2_Fatboy1 = ScenarioInfo.M2_Fatboy1

    for _, location in ArmyBrains[UEF].PBM.Locations do
        if location.LocationType == 'P3UEFFatboybase1' then
            location.PrimaryFactories.Land = M2_Fatboy1.ExternalFactory
            M3UEFFatboyattacks1()
            break
        end
    end

    IssueClearFactoryCommands({M2_Fatboy1.ExternalFactory})
    IssueFactoryRallyPoint({M2_Fatboy1.ExternalFactory}, ScenarioUtils.MarkerToPosition("Rally Point 19"))
end

function M3UEFFatboyBase2AI()
    P3UBase3:InitializeDifficultyTables(ArmyBrains[UEF], 'P3UEFFatboybase2', 'P3UB2MK2', 20, {P3USbase3 = 100})
    P3UBase3:StartNonZeroBase({{2, 3, 4}, {2, 3, 4}})

    if Difficulty == 3 then
        ArmyBrains[UEF]:PBMSetCheckInterval(6)
    end

    local M2_Fatboy2 = ScenarioInfo.M2_Fatboy2

    for _, location in ArmyBrains[UEF].PBM.Locations do
        if location.LocationType == 'P3UEFFatboybase2' then
            location.PrimaryFactories.Land = M2_Fatboy2.ExternalFactory
            M3UEFFatboyattacks2()
            break
        end
    end

    IssueClearFactoryCommands({M2_Fatboy2.ExternalFactory})
    IssueFactoryRallyPoint({M2_Fatboy2.ExternalFactory}, ScenarioUtils.MarkerToPosition("Rally Point 21"))
end

function M3UEFAtlantisBaseAI()
    P3UBase2:InitializeDifficultyTables(ArmyBrains[UEF], 'P3UEFseabase', 'P3UB1MK1', 30, {P3USbase = 100})
    P3UBase2:StartNonZeroBase(2)

    M3UEFAtlantisBaseAirAttacks()
    
    ForkThread(
        function()
            -- Wait for the carrier to be spawned
            WaitSeconds(1)

            local Carrier1 = ScenarioInfo.M2Atlantis 
            for _, location in ArmyBrains[UEF].PBM.Locations do
                if location.LocationType == 'P3UEFseabase' then
                    location.PrimaryFactories.Air = Carrier1.ExternalFactory
                    break
                end
            end

            Carrier1:ForkThread(function(self)
                local factory = self.ExternalFactory

                while true do
                    if table.getn(self:GetCargo()) > 0 and factory:IsIdleState() then
                        IssueClearCommands({self})
                        IssueTransportUnload({self}, ScenarioUtils.MarkerToPosition('Rally Point 20'))
    
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

function M3UEFAtlantisBase2AI()
    P3UBase4:InitializeDifficultyTables(ArmyBrains[UEF], 'P3UEFseabase2', 'P3UB1MK2', 30, {P3USbase4 = 100})
    P3UBase4:StartNonZeroBase(2)

    M3UEFAtlantisBaseAirAttacks2()
    
    ForkThread(
        function()
            -- Wait for the carrier to be spawned
            WaitSeconds(1)

            local Carrier2 = ScenarioInfo.M2Atlantis2 
            for _, location in ArmyBrains[UEF].PBM.Locations do
                if location.LocationType == 'P3UEFseabase2' then
                    location.PrimaryFactories.Air = Carrier2.ExternalFactory
                    break
                end
            end

            Carrier2:ForkThread(function(self)
                local factory = self.ExternalFactory

                while true do
                    if table.getn(self:GetCargo()) > 0 and factory:IsIdleState() then
                        IssueClearCommands({self})
                        IssueTransportUnload({self}, ScenarioUtils.MarkerToPosition('Rally Point 14'))
    
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

function M3UEFAtlantisBaseAirAttacks()

    local quantity = {}
    local trigger = {}

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
    trigger = {10, 8, 6}
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
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE * categories.TECH2}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3UB1airattack1','P3UB1airattack2', 'P3UB1airattack3'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
    
    quantity = {5, 6, 7}
    trigger = {25, 20, 15}
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
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3UB1airattack1','P3UB1airattack2', 'P3UB1airattack3'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
    
    quantity = {3, 4, 5}
    trigger = {25, 20, 15}
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
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.STRUCTURE * categories.DEFENSE * categories.TECH3}},
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
    local trigger = {}

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
    trigger = {20, 15, 10}
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
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.AIR * categories.MOBILE * categories.TECH3}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},     
        PlatoonData = {
            PatrolChains = {'P3UB1airattack1','P3UB1airattack2', 'P3UB1airattack3'}
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
    
    quantity = {5, 7, 9}
    trigger = {7, 5, 3}
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
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE * categories.TECH3}},
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
    local trigger = {}

    quantity = {4, 5, 6}
    local Temp = {
        'P3UFBLAttackTemp0',
        'NoPlan',
        { 'uel0303', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },       
    }
    local Builder = {
        BuilderName = 'P3UFBLAttackBuilder0',
        PlatoonTemplate = Temp,
        InstanceCount = 5,
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
    trigger = {20, 15, 10}
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
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.STRUCTURE * categories.DEFENSE * categories.TECH3}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P3ULandchain1'
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
    
    quantity = {4, 5, 6}
    trigger = {60, 50, 45}
    Temp = {
        'P3UFBLAttackTemp2',
        'NoPlan',
        { 'xel0305', 1, quantity[Difficulty], 'Attack', 'GrowthFormation' },
        { 'uel0307', 1, 2, 'Attack', 'GrowthFormation' },       
    }
    Builder = {
        BuilderName = 'P3UFBLAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 3,
        Priority = 105,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'P3UEFFatboybase1',
        BuildConditions = {
           { '/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.TECH3}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P3ULandchain1'
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    opai = P3UBase1:AddOpAI('EngineerAttack', 'M3B1_West_Reclaim_Engineers',
    {
        MasterPlatoonFunction = {SPAIFileName, 'SplitPatrolThread'},
        PlatoonData = {
            PatrolChains = {'P3ULandchain1','P3ULandchain2'},
        },
        Priority = 500,
    })
    opai:SetChildQuantity('T1Engineers', 5)
end

function M3UEFFatboyattacks2()

    local quantity = {}
    local trigger = {}

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
    
    quantity = {2, 3, 5}
    trigger = {30, 25, 20}
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
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.STRUCTURE * categories.DEFENSE - categories.TECH1}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P3ULandchain2'
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )
    
    quantity = {4, 5, 6}
    trigger = {3, 2, 1}
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
        {'default_brain',  {'HumanPlayers'}, trigger[Difficulty], categories.EXPERIMENTAL}},
        },
        PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},     
        PlatoonData = {
            PatrolChain = 'P3ULandchain2'
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    opai = P3UBase3:AddOpAI('EngineerAttack', 'M3B2_West_Reclaim_Engineers',
    {
        MasterPlatoonFunction = {SPAIFileName, 'SplitPatrolThread'},
        PlatoonData = {
            PatrolChains = {'P3ULandchain1','P3ULandchain2'},
        },
        Priority = 500,
    })
    opai:SetChildQuantity('T1Engineers', 5)
end
    