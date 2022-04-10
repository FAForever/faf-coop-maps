-- ****************************************************************************
-- **
-- **  File     : /maps/X1CA_Coop_003/X1CA_Coop_003_m2seraphimai.lua
-- **  Author(s): Jessica St. Croix
-- **
-- **  Summary  : Seraphim army AI for Mission 2 - X1CA_Coop_003
-- **
-- **  Copyright © 2007 Gas Powered Games, Inc.  All rights reserved.
-- ****************************************************************************
local BaseManager = import('/lua/ai/opai/basemanager.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local ScriptFile = import('/maps/X1CA_Coop_003/X1CA_Coop_003_script.lua')
local Buff = import('/lua/sim/Buff.lua')

local SPAIFileName = '/lua/ScenarioPlatoonAI.lua'

--------
-- Locals
--------
local Seraphim = 2
local Difficulty = ScenarioInfo.Options.Difficulty

---------------
-- Base Managers
---------------
local SeraphimM2NorthBase = BaseManager.CreateBaseManager()
local SeraphimM2SouthBase = BaseManager.CreateBaseManager()

function SeraphimM2NorthBaseAI()

    ------------------------
    -- Seraphim M2 North Base
    ------------------------
    SeraphimM2NorthBase:InitializeDifficultyTables(ArmyBrains[Seraphim], 'M2_Seraph_North_Base', 'Seraphim_M2_North_Base', 220, {M2_Seraph_North_Base = 100})
    SeraphimM2NorthBase:StartNonZeroBase({{4, 8, 13}, {4, 8, 13}})
    SeraphimM2NorthBase:SetActive('AirScouting', true)
    SeraphimM2NorthBase:SetBuildAllStructures(false)

    SeraphimM2NorthBase:AddReactiveAI('ExperimentalLand', 'AirRetaliation', 'SeraphimM2NorthBase_ExperimentalLand1')
    SeraphimM2NorthBase:AddReactiveAI('ExperimentalLand', 'AirRetaliation', 'SeraphimM2NorthBase_ExperimentalLand2')
    SeraphimM2NorthBase:AddReactiveAI('ExperimentalLand', 'AirRetaliation', 'SeraphimM2NorthBase_ExperimentalLand3')
    SeraphimM2NorthBase:AddReactiveAI('ExperimentalAir', 'AirRetaliation', 'SeraphimM2NorthBase_ExperimentalAir')
    SeraphimM2NorthBase:AddReactiveAI('ExperimentalNaval', 'AirRetaliation', 'SeraphimM2NorthBase_ExperimentalNaval')
    SeraphimM2NorthBase:AddReactiveAI('Nuke', 'AirRetaliation', 'SeraphimM2NorthBase_Nuke')
    SeraphimM2NorthBase:AddReactiveAI('HLRA', 'AirRetaliation', 'SeraphimM2NorthBase_HLRA')

    SeraphimM2NorthBaseAirAttacks()
    SeraphimM2NorthBaseNavalAttacks()
    SeraphimM2NorthBaseExperimentals()
end

local BuildPercent = {}
local LastUpdate = 0
local NumBuilding = 0

function UnitBuildPercentUpdate(unit, eng)
    if unit:IsDead() then
        return
    end
    if not eng.UnitBuildPercentSetup then
        eng.UnitBuildPercentSetup = true
        import('/lua/scenariotriggers.lua').CreateUnitDeathTrigger(EngineerDeath, eng)
        table.insert( BuildPercent, { Engineer = eng, Percent = unit:GetFractionComplete(), UnitPassedToScript = false } )
        NumBuilding = NumBuilding + 1
    else
        for k,v in BuildPercent do
            if v.Engineer == eng then
                v.Percent = unit:GetFractionComplete()
                if not v.UnitPassedToScript then
                    v.UnitPassedToScript = true
                    ScriptFile.M2ExperimentalBomberStarted( unit )
                end
            end
        end
    end
    if table.getn( BuildPercent ) == NumBuilding then
        local low = 100
        for k,v in BuildPercent do
            if v.Percent < low then
                low = v.Percent
            end
        end
        if math.floor(low*100) > math.floor(LastUpdate*100) then
            LastUpdate = low
            ScriptFile.M2ExperimentalBuildPercentUpdate( math.floor(LastUpdate * 100) )
        end
    end
end

function EngineerDeath(eng)
    for k,v in BuildPercent do
        if eng == v.Engineer then
            table.remove( BuildPercent, k )
        end
    end
end

function ExperimentalFinished(unit)
    NumBuilding = NumBuilding - 1
    if not unit or unit:IsDead() then
        return
    end
    ScriptFile.M2ExperimentalFinishBuild(unit)
end

function SeraphimM2NorthBaseExperimentals()
    --[[
    local opai = nil

    local NorthYthPatrol = {
        'M2_Seraph_NorthBase_Eng_2',
        'M2_Seraph_NorthBase_Eng_3',
        'M2_Seraph_NorthBase_Eng_4',
        'Blank Marker 33',
        'Blank Marker 30',
    }

    opai = SeraphimM2NorthBase:AddOpAI('Ythota_North',
        {
            Amount = Difficulty,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'RandomPatrolThread'},
            PlatoonData = {
                PatrolRoute = NorthYthPatrol,
            },
            MaxAssist = 5,
            Retry = true,
        }
    )
    ]]--

    -- number of engineers to use
    local engineers = 6
    -- number of bombers to use
    local bombers = 6

    local groups = 6
    local topName = 'M2_Exp_Group_'
    local engSuffix = '_Eng'

    local engSpawned = 0

    local buildList = {}
    local engList = {}

    -- Makes the bombers take 60, 30, 25 minutes to build
    local multiplier = {.625, 1.33, 1.6}

    BuffBlueprint {
        Name = 'Op3M2EngBuildRate',
        DisplayName = 'Op3M2EngBuildRate',
        BuffType = 'AIBUILDRATE',
        Stacks = 'REPLACE',
        Duration = -1,
        EntityCategory = 'ENGINEER',
        Affects = {
            BuildRate = {
                Add = 0,
                Mult = multiplier[Difficulty],
            },
        },
    }

    for i=1,groups do
        table.insert( buildList, 'Seraph_Exper_'..i )
        for k,v in ScenarioUtils.FlattenTreeGroup( 'Seraphim', topName..i..engSuffix ) do
            if engSpawned < engineers then
                unit = CreateUnitHPR( v.type,
                                     'Seraphim',
                                     v.Position[1], v.Position[2], v.Position[3],
                                     v.Orientation[1], v.Orientation[2], v.Orientation[3]
                                 )
                engSpawned = engSpawned + 1
                table.insert( engList, unit )
                -- Apply buff here
                Buff.ApplyBuff( unit, 'Op3M2EngBuildRate' )
            end
        end
    end

    ScenarioInfo.ExperimentalEngineers = engList

    local platoonTable = {}
    for i=1,6 do
        local plat = ArmyBrains[Seraphim]:MakePlatoon( '', '' )
        table.insert( platoonTable, plat )
        plat.PlatoonData = {}
        plat.PlatoonData.NamedUnitBuild = {}
        plat.PlatoonData.NamedUnitBuildReportCallback = UnitBuildPercentUpdate
        plat.PlatoonData.NamedUnitFinishedCallback = ExperimentalFinished
    end

    local platNum = 1
    local filledPlatoons = 0
    for k,v in engList do
        ArmyBrains[Seraphim]:AssignUnitsToPlatoon( platoonTable[platNum], {v}, 'Support', 'None' )
        platNum = platNum + 1
        if filledPlatoons < 6 then
            filledPlatoons = filledPlatoons + 1
        end
        if platNum == 7 then
            platNum = 1
        end
    end

    local whichPlat = 1
    for i=1,bombers do
        table.insert( platoonTable[whichPlat].PlatoonData.NamedUnitBuild, buildList[i] )
        whichPlat = whichPlat + 1
        if whichPlat > filledPlatoons then
            whichPlat = 1
        end
    end

    for i=1,filledPlatoons do
        platoonTable[i]:ForkAIThread( import('/lua/ScenarioPlatoonAI.lua').StartBaseEngineerThread )
    end
end

function SeraphimM2NorthBaseAirAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    -------------------------------------------
    -- Seraphim M2 North Base Op AI, Air Attacks
    -------------------------------------------

    -- sends 7, 14, 24 [bombers]
    quantity = {7, 14, 24}
    opai = SeraphimM2NorthBase:AddOpAI('AirAttacks', 'M2North_AirAttacks1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Seraph_North_AirMain_1_Chain', 'M2_Seraph_North_AirMain_2_Chain', 'M2_Seraph_North_AirMid_Chain', 'M2_Seraph_North_AirNorth_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Bombers', quantity[Difficulty])

    -- sends 7, 7, 8 [interceptors]
    quantity = {7, 7, 8}
    opai = SeraphimM2NorthBase:AddOpAI('AirAttacks', 'M2North_AirAttacks2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Seraph_North_AirMain_1_Chain', 'M2_Seraph_North_AirMain_2_Chain', 'M2_Seraph_North_AirMid_Chain', 'M2_Seraph_North_AirNorth_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Interceptors', quantity[Difficulty])

    -- sends 7, 14, 16 [gunships]
    quantity = {7, 14, 16}
    opai = SeraphimM2NorthBase:AddOpAI('AirAttacks', 'M2North_AirAttacks3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Seraph_North_AirMain_1_Chain', 'M2_Seraph_North_AirMain_2_Chain', 'M2_Seraph_North_AirMid_Chain', 'M2_Seraph_North_AirNorth_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])

    -- sends 12, 14, 16 [gunships, combat fighter] if player has >= 10, 7, 5 T2/T3 AA
    quantity = {12, 14, 16}
    trigger = {10, 7, 5}
    opai = SeraphimM2NorthBase:AddOpAI('AirAttacks', 'M2North_AirAttacks4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Seraph_North_AirMain_1_Chain', 'M2_Seraph_North_AirMain_2_Chain', 'M2_Seraph_North_AirMid_Chain', 'M2_Seraph_North_AirNorth_Chain'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'Gunships', 'CombatFighters'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.ANTIAIR - categories.TECH1, '>='})

    -- sends 12, 14, 16 [gunships] if player has >= 100, 80, 60 mobile land
    quantity = {12, 14, 16}
    trigger = {100, 80, 60}
    opai = SeraphimM2NorthBase:AddOpAI('AirAttacks', 'M2North_AirAttacks5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Seraph_North_AirMain_1_Chain', 'M2_Seraph_North_AirMain_2_Chain', 'M2_Seraph_North_AirMid_Chain', 'M2_Seraph_North_AirNorth_Chain'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], (categories.MOBILE * categories.LAND) - categories.CONSTRUCTION, '>='})

    -- sends 12, 14, 16 [air superiority] if player has >= 100, 80, 60 mobile air
    quantity = {12, 14, 16}
    trigger = {100, 80, 60}
    opai = SeraphimM2NorthBase:AddOpAI('AirAttacks', 'M2North_AirAttacks6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Seraph_North_AirMain_1_Chain', 'M2_Seraph_North_AirMain_2_Chain', 'M2_Seraph_North_AirMid_Chain', 'M2_Seraph_North_AirNorth_Chain'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.MOBILE * categories.AIR, '>='})

    -- sends 12, 14, 16 [air superiority] if player has >= 60, 50, 40 gunships
    quantity = {12, 14, 16}
    trigger = {60, 50, 40}
    opai = SeraphimM2NorthBase:AddOpAI('AirAttacks', 'M2North_AirAttacks7',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Seraph_North_AirMain_1_Chain', 'M2_Seraph_North_AirMain_2_Chain', 'M2_Seraph_North_AirMid_Chain', 'M2_Seraph_North_AirNorth_Chain'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.uaa0203 + categories.uea0203 + categories.ura0203, '>='})

    -- sends 5, 7, 16 [torpedo bombers] if player has >= 10, 8, 5 boats
    quantity = {5, 7, 16}
    trigger = {10, 8, 5}
    opai = SeraphimM2NorthBase:AddOpAI('AirAttacks', 'M2North_AirAttacks8',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChains = {'M2_Seraph_North_AirMain_1_Chain', 'M2_Seraph_North_AirMain_2_Chain', 'M2_Seraph_North_AirMid_Chain', 'M2_Seraph_North_AirNorth_Chain'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('TorpedoBombers', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.uaa0203 + categories.uea0203 + categories.ura0203, '>='})

    -- sends 6, 10, 16 [combat fighters, gunships] if player has >= 60, 50, 40 T3 units
    quantity = {6, 10, 16}
    trigger = {60, 50, 40}
    opai = SeraphimM2NorthBase:AddOpAI('AirAttacks', 'M2North_AirAttacks9',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Seraph_North_AirMain_1_Chain', 'M2_Seraph_North_AirMain_2_Chain', 'M2_Seraph_North_AirMid_Chain', 'M2_Seraph_North_AirNorth_Chain'},
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity({'CombatFighters', 'Gunships'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.TECH3, '>='})

    -- sends 7, 7, 8 [air superiority] if player has >= 1 strat bomber
    quantity = {7, 7, 8}
    opai = SeraphimM2NorthBase:AddOpAI('AirAttacks', 'M2North_AirAttacks10',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Seraph_North_AirMain_1_Chain', 'M2_Seraph_North_AirMain_2_Chain', 'M2_Seraph_North_AirMid_Chain', 'M2_Seraph_North_AirNorth_Chain'},
            },
            Priority = 140,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, 1, categories.uaa0304 + categories.uea0304 + categories.ura0304, '>='})

    -- sends 14, 20, 24 [bombers, gunships] if player has >= 350, 400, 450 units
    quantity = {14, 20, 24}
    trigger = {350, 400, 450}
    opai = SeraphimM2NorthBase:AddOpAI('AirAttacks', 'M2North_AirAttacks11',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Seraph_North_AirMain_1_Chain', 'M2_Seraph_North_AirMain_2_Chain', 'M2_Seraph_North_AirMid_Chain', 'M2_Seraph_North_AirNorth_Chain'},
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity({'Bombers', 'Gunships'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL, '>='})

    -- Air Defense
    opai = SeraphimM2NorthBase:AddOpAI('AirAttacks', 'M2North_AirDefense1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Seraph_MainNorth_AirDef_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('AirSuperiority', 7)

    opai = SeraphimM2NorthBase:AddOpAI('AirAttacks', 'M2North_AirDefense2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Seraph_MainNorth_AirDef_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('TorpedoBombers', 7)
end

function SeraphimM2NorthBaseNavalAttacks()
    local opai = nil
    local trigger = {}

    ---------------------------------------------
    -- Seraphim M2 North Base Op AI, Naval Attacks
    ---------------------------------------------

    -- sends 3 frigate power of [frigates]
    opai = SeraphimM2NorthBase:AddNavalAI('M2North_NavalAttack1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Seraph_North_NavalMain_Chain',
            },
            EnableTypes = {'Frigate'},
            MaxFrigates = 4,
            MinFrigates = 4,
            Priority = 100,
        }
    )

    -- sends 6 - 10 frigate power of all but T3
    opai = SeraphimM2NorthBase:AddNavalAI('M2North_NavalAttack2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Seraph_North_NavalMain_Chain',
            },
            MaxFrigates = 10,
            MinFrigates = 6,
            Priority = 100,
        }
    )
    opai:SetChildActive('T3', false)

    -- sends 10 - 30 frigate power of all but T3
    opai = SeraphimM2NorthBase:AddNavalAI('M2North_NavalAttack3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Seraph_North_NavalMain_Chain',
            },
            MaxFrigates = 10,
            MinFrigates = 30,
            Priority = 100,
        }
    )

    -- sends 6 frigate power of [frigates, subs] if player has >= 8, 6, 4 boats
    trigger = {8, 6, 4}
    opai = SeraphimM2NorthBase:AddNavalAI('M2North_NavalAttack4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Seraph_North_NavalMain_Chain',
            },
            EnableTypes = {'Frigate', 'Submarine'},
            MaxFrigates = 6,
            MinFrigates = 6,
            Priority = 110,
        }
    )
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE, '>='})

    -- sends 9 frigate power of [all but T3] if player has >= 5, 3, 2 T2/T3 boats
    trigger = {5, 3, 2}
    opai = SeraphimM2NorthBase:AddNavalAI('M2North_NavalAttack5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Seraph_North_NavalMain_Chain',
            },
            MaxFrigates = 9,
            MinFrigates = 9,
            Priority = 120,
        }
    )
    opai:SetChildActive('T3', false)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',  'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], (categories.NAVAL * categories.MOBILE) - categories.TECH1, '>='})

    -- sends 12 frigate power of [all but T3] if player has >= 6, 5, 4 T2/T3 boats
    trigger = {6, 5, 4}
    opai = SeraphimM2NorthBase:AddNavalAI('M2North_NavalAttack6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Seraph_North_NavalMain_Chain',
            },
            MaxFrigates = 12,
            MinFrigates = 12,
            Priority = 130,
        }
    )
    opai:SetChildActive('T3', false)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], (categories.NAVAL * categories.MOBILE) - categories.TECH1, '>='})

    -- Sonar
    opai = SeraphimM2NorthBase:AddOpAI('M2_Seraph_Sonar_North',
        {
            Amount = 1,
            KeepAlive = true,
            MaxAssist = 1,
            Retry = true,
        }
    )
end

function SeraphimM2SouthBaseAI()

    ------------------------
    -- Seraphim M2 South Base
    ------------------------
    SeraphimM2SouthBase:InitializeDifficultyTables(ArmyBrains[Seraphim], 'M2_Seraph_South_Base', 'Seraphim_M2_South_Base', 150, {M2_Seraph_South_Base = 100})
    SeraphimM2SouthBase:StartNonZeroBase({{3, 7, 11}, {3, 6, 9}})
    SeraphimM2SouthBase:SetActive('AirScouting', true)
    SeraphimM2SouthBase:SetBuild('Defenses', false)

    SeraphimM2SouthBase:AddReactiveAI('ExperimentalLand', 'AirRetaliation', 'SeraphimM2SouthBase_ExperimentalLand')
    SeraphimM2SouthBase:AddReactiveAI('ExperimentalAir', 'AirRetaliation', 'SeraphimM2SouthBase_ExperimentalAir')
    SeraphimM2SouthBase:AddReactiveAI('ExperimentalNaval', 'AirRetaliation', 'SeraphimM2SouthBase_ExperimentalNaval')
    SeraphimM2SouthBase:AddReactiveAI('Nuke', 'AirRetaliation', 'SeraphimM2SouthBase_Nuke')
    SeraphimM2SouthBase:AddReactiveAI('HLRA', 'AirRetaliation', 'SeraphimM2SouthBase_HLRA')

    SeraphimM2SouthBaseAirAttacks()
    SeraphimM2SouthBaseNavalAttacks()
    --SeraphimM2SouthBaseExperimentals()
end

function SeraphimM2SouthBaseExperimentals()
    local opai = nil

    local SouthYthPatrol = {
        'Seraphim_M2_South_Base',
        'M2_Seraph_SouthBase_Eng_5',
        'Seraphim_M2_South_Mass_Base',
        'M2_Seraph_SouthBase_Eng_4',
        'M2_Seraph_SouthBase_Eng_2',
    }

    opai = SeraphimM2SouthBase:AddOpAI('Ythota_South',
        {
            Amount = Difficulty,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'RandomPatrolThread'},
            PlatoonData = {
                PatrolRoute = SouthYthPatrol,
            },
            MaxAssist = 5,
            Retry = true,
        }
    )
end

function SeraphimM2SouthBaseAirAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    -------------------------------------------
    -- Seraphim M2 South Base Op AI, Air Attacks
    -------------------------------------------

    -- sends 3, 6, 9 [bombers]
    quantity = {3, 6, 9}
    opai = SeraphimM2SouthBase:AddOpAI('AirAttacks', 'M2South_AirAttacks1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'RandomPatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Seraph_South_AirMain_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Bombers', quantity[Difficulty])

    -- sends 3, 6, 9 [interceptors]
    quantity = {3, 6, 9}
    opai = SeraphimM2SouthBase:AddOpAI('AirAttacks', 'M2South_AirAttacks2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'RandomPatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Seraph_South_AirMain_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Interceptors', quantity[Difficulty])

    -- sends 3, 6, 9 [gunships]
    quantity = {3, 6, 9}
    opai = SeraphimM2SouthBase:AddOpAI('AirAttacks', 'M2South_AirAttacks3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'RandomPatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Seraph_South_AirMain_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])

    -- sends 6, 8, 12 [gunships, combat fighter] if player has >= 10, 7, 5 T2/T3 AA
    quantity = {6, 8, 12}
    trigger = {10, 7, 5}
    opai = SeraphimM2SouthBase:AddOpAI('AirAttacks', 'M2South_AirAttacks4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'RandomPatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Seraph_South_AirMain_Chain',
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'Gunships', 'CombatFighters'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.ANTIAIR - categories.TECH1, '>='})

    -- sends 6, 9, 12 [gunships] if player has >= 100, 80, 60 mobile land
    quantity = {6, 9, 12}
    trigger = {100, 80, 60}
    opai = SeraphimM2SouthBase:AddOpAI('AirAttacks', 'M2South_AirAttacks5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'RandomPatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Seraph_South_AirMain_Chain',
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], (categories.MOBILE * categories.LAND) - categories.CONSTRUCTION, '>='})

    -- sends 6, 9, 12 [air superiority] if player has >= 100, 80, 60 mobile air
    quantity = {6, 9, 12}
    trigger = {100, 80, 60}
    opai = SeraphimM2SouthBase:AddOpAI('AirAttacks', 'M2South_AirAttacks6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'RandomPatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Seraph_South_AirMain_Chain',
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.MOBILE * categories.AIR, '>='})

    -- sends 6, 9, 12 [air superiority] if player has >= 60, 50, 40 gunships
    quantity = {6, 9, 12}
    trigger = {60, 50, 40}
    opai = SeraphimM2SouthBase:AddOpAI('AirAttacks', 'M2South_AirAttacks7',
        {
            MasterPlatoonFunction = {SPAIFileName, 'RandomPatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Seraph_South_AirMain_Chain',
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.uaa0203 + categories.uea0203 + categories.ura0203, '>='})

    -- sends 3, 6, 9 [torpedo bombers] if player has >= 10, 8, 5 boats
    quantity = {3, 6, 9}
    trigger = {10, 8, 5}
    opai = SeraphimM2SouthBase:AddOpAI('AirAttacks', 'M2South_AirAttacks8',
        {
            MasterPlatoonFunction = {SPAIFileName, 'RandomPatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Seraph_South_AirMain_Chain',
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('TorpedoBombers', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.uaa0203 + categories.uea0203 + categories.ura0203, '>='})

    -- sends 6, 8, 12 [combat fighters, gunships] if player has >= 60, 50, 40 T3 units
    quantity = {6, 8, 12}
    trigger = {60, 50, 40}
    opai = SeraphimM2SouthBase:AddOpAI('AirAttacks', 'M2South_AirAttacks9',
        {
            MasterPlatoonFunction = {SPAIFileName, 'RandomPatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Seraph_South_AirMain_Chain',
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity({'CombatFighters', 'Gunships'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.TECH3, '>='})

    -- sends 3, 6, 6 [air superiority] if player has >= 1 strat bomber
    quantity = {3, 6, 6}
    opai = SeraphimM2SouthBase:AddOpAI('AirAttacks', 'M2South_AirAttacks10',
        {
            MasterPlatoonFunction = {SPAIFileName, 'RandomPatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Seraph_South_AirMain_Chain',
            },
            Priority = 140,
        }
    )
    opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, 1, categories.uaa0304 + categories.uea0304 + categories.ura0304, '>='})

    -- sends 6, 8, 12 [bombers, gunships] if player has >= 350, 400, 450 units
    quantity = {6, 8, 12}
    trigger = {350, 400, 450}
    opai = SeraphimM2SouthBase:AddOpAI('AirAttacks', 'M2South_AirAttacks11',
        {
            MasterPlatoonFunction = {SPAIFileName, 'RandomPatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Seraph_South_AirMain_Chain',
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity({'Bombers', 'Gunships'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL, '>='})

    -- Air Defense
    opai = SeraphimM2SouthBase:AddOpAI('AirAttacks', 'M2South_AirDefense1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Seraph_MainSouth_AirDef_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('AirSuperiority', 3)

    opai = SeraphimM2SouthBase:AddOpAI('AirAttacks', 'M2South_AirDefense2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Seraph_MainSouth_AirDef_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('TorpedoBombers', 3)
end

function SeraphimM2SouthBaseNavalAttacks()
    local opai = nil
    local trigger = {}

    ---------------------------------------------
    -- Seraphim M2 South Base Op AI, Naval Attacks
    ---------------------------------------------

    -- sends 7 frigate power of [frigates]
    opai = SeraphimM2SouthBase:AddNavalAI('M2South_NavalAttack1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Seraph_South_NavalMain_1_Chain', 'M2_Seraph_South_NavalMain_2_Chain', 'M2_Seraph_South_NavalMid_Chain', 'M2_Seraph_South_NavalNorth_Chain'},
            },
            EnableTypes = {'Frigate'},
            MaxFrigates = 7,
            MinFrigates = 7,
            Priority = 100,
        }
    )

    -- sends 6 - 10 frigate power of all but T3
    opai = SeraphimM2SouthBase:AddNavalAI('M2South_NavalAttack2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Seraph_South_NavalMain_1_Chain', 'M2_Seraph_South_NavalMain_2_Chain', 'M2_Seraph_South_NavalMid_Chain', 'M2_Seraph_South_NavalNorth_Chain'},
            },
            MaxFrigates = 10,
            MinFrigates = 6,
            Priority = 100,
        }
    )
    opai:SetChildActive('T3', false)

    -- sends 10 - 30 frigate power of all but T3
    opai = SeraphimM2SouthBase:AddNavalAI('M2South_NavalAttack3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Seraph_South_NavalMain_1_Chain', 'M2_Seraph_South_NavalMain_2_Chain', 'M2_Seraph_South_NavalMid_Chain', 'M2_Seraph_South_NavalNorth_Chain'},
            },
            MaxFrigates = 10,
            MinFrigates = 30,
            Priority = 100,
        }
    )

    -- sends 6 frigate power of [frigates, subs] if player has >= 8, 6, 4 boats
    trigger = {8, 6, 4}
    opai = SeraphimM2SouthBase:AddNavalAI('M2South_NavalAttack4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Seraph_South_NavalMain_1_Chain', 'M2_Seraph_South_NavalMain_2_Chain', 'M2_Seraph_South_NavalMid_Chain', 'M2_Seraph_South_NavalNorth_Chain'},
            },
            EnableTypes = {'Frigate', 'Submarine'},
            MaxFrigates = 6,
            MinFrigates = 6,
            Priority = 110,
        }
    )
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE, '>='})

    -- sends 9 frigate power of [all but T3] if player has >= 5, 3, 2 T2/T3 boats
    trigger = {5, 3, 2}
    opai = SeraphimM2SouthBase:AddNavalAI('M2South_NavalAttack5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Seraph_South_NavalMain_1_Chain', 'M2_Seraph_South_NavalMain_2_Chain', 'M2_Seraph_South_NavalMid_Chain', 'M2_Seraph_South_NavalNorth_Chain'},
            },
            MaxFrigates = 9,
            MinFrigates = 9,
            Priority = 120,
        }
    )
    opai:SetChildActive('T3', false)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',  'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], (categories.NAVAL * categories.MOBILE) - categories.TECH1, '>='})

    -- sends 12 frigate power of [all but T3] if player has >= 6, 5, 4 T2/T3 boats
    trigger = {6, 5, 4}
    opai = SeraphimM2SouthBase:AddNavalAI('M2South_NavalAttack6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Seraph_South_NavalMain_1_Chain', 'M2_Seraph_South_NavalMain_2_Chain', 'M2_Seraph_South_NavalMid_Chain', 'M2_Seraph_South_NavalNorth_Chain'},
            },
            MaxFrigates = 12,
            MinFrigates = 12,
            Priority = 130,
        }
    )
    opai:SetChildActive('T3', false)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], (categories.NAVAL * categories.MOBILE) - categories.TECH1, '>='})

    -- sends 25 frigate power of everything if player has >= 3, 2, 1 T3 boats
    trigger = {3, 2, 1}
    opai = SeraphimM2SouthBase:AddNavalAI('M2South_NavalAttack7',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M2_Seraph_South_NavalMain_1_Chain', 'M2_Seraph_South_NavalMain_2_Chain', 'M2_Seraph_South_NavalMid_Chain', 'M2_Seraph_South_NavalNorth_Chain'},
            },
            MaxFrigates = 25,
            MinFrigates = 25,
            Priority = 140,
        }
    )
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.NAVAL * categories.MOBILE * categories.TECH3, '>='})

    -- Sonar
    opai = SeraphimM2SouthBase:AddOpAI('M2_Seraph_Sonar_South',
        {
            Amount = 1,
            KeepAlive = true,
            MaxAssist = 1,
            Retry = true,
        }
    )
end
