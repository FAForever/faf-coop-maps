-- ****************************************************************************
-- **
-- **  File     : /maps/X1CA_Coop_002/X1CA_Coop_002_m2orderai.lua
-- **  Author(s): Jessica St. Croix
-- **
-- **  Summary  : Order army AI for Mission 2 - X1CA_Coop_002
-- **
-- **  Copyright © 2007 Gas Powered Games, Inc.  All rights reserved.
-- ****************************************************************************
local BaseManager = import('/lua/ai/opai/basemanager.lua')
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')

local SPAIFileName = '/lua/scenarioplatoonai.lua'

--------
-- Locals
--------
local Order = 2
local Difficulty = ScenarioInfo.Options.Difficulty

---------------
-- Base Managers
---------------
local OrderM2NorthBase = BaseManager.CreateBaseManager()

function OrderM2NorthBaseAI()

    ------------------------
    -- Order North Base Op AI
    ------------------------
    OrderM2NorthBase:InitializeDifficultyTables(ArmyBrains[Order], 'M2_North_Base', 'Order_M2_North_Base_Marker', 70, {M2_North_Base = 100})
    OrderM2NorthBase:StartNonZeroBase({{4, 8, 12}, {4, 7, 10}})
    OrderM2NorthBase:SetActive('AirScouting', true)

    OrderM2NorthBase:AddReactiveAI('ExperimentalLand', 'AirRetaliation', 'OrderM2NorthBase_ExperimentalLand')
    OrderM2NorthBase:AddReactiveAI('ExperimentalAir', 'AirRetaliation', 'OrderM2NorthBase_ExperimentalAir')
    OrderM2NorthBase:AddReactiveAI('ExperimentalNaval', 'AirRetaliation', 'OrderM2NorthBase_ExperimentalNaval')
    OrderM2NorthBase:AddReactiveAI('Nuke', 'AirRetaliation', 'OrderM2NorthBase_Nuke')
    OrderM2NorthBase:AddReactiveAI('HLRA', 'AirRetaliation', 'OrderM2NorthBase_HLRA')

    OrderM2NorthBaseAirAttacks()
    OrderM2NorthBaseLandAttacks()
end

function OrderM2NorthBaseAirAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    ----------------------------------------
    -- Order M2 North Base Op AI, Air Attacks
    ----------------------------------------
    -- sends 3, 4, 8 [bombers]
    quantity = {3, 4, 8}
    opai = OrderM2NorthBase:AddOpAI('AirAttacks', 'M2_AirAttacks1',
        {
            MasterPlatoonFunction = {'/maps/X1CA_Coop_002/X1CA_Coop_002_m2orderai.lua', 'M2OrderAirAttackAI'},
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'Bombers'}, quantity[Difficulty])

    -- sends 3, 4, 8 [interceptors]
    quantity = {3, 4, 8}
    opai = OrderM2NorthBase:AddOpAI('AirAttacks', 'M2_AirAttacks2',
        {
            MasterPlatoonFunction = {'/maps/X1CA_Coop_002/X1CA_Coop_002_m2orderai.lua', 'M2OrderAirAttackAI'},
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'Interceptors'}, quantity[Difficulty])

    -- sends 2, 4, 8 [gunships, combat fighters]
    quantity = {2, 4, 8}
    opai = OrderM2NorthBase:AddOpAI('AirAttacks', 'M2_AirAttacks3',
        {
            MasterPlatoonFunction = {'/maps/X1CA_Coop_002/X1CA_Coop_002_m2orderai.lua', 'M2OrderAirAttackAI'},
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'Gunships', 'CombatFighters'}, quantity[Difficulty])

    -- sends 2, 4, 8[gunships, combat fighters] if player has >= 10, 7, 5 T2/T3 AA
    quantity = {2, 4, 8}
    trigger = {10, 7, 5}
    opai = OrderM2NorthBase:AddOpAI('AirAttacks', 'M2_AirAttacks4',
        {
            MasterPlatoonFunction = {'/maps/X1CA_Coop_002/X1CA_Coop_002_m2orderai.lua', 'M2OrderAirAttackAI'},
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'Gunships', 'CombatFighters'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.ANTIAIR - categories.TECH1, '>='})

    -- sends 3, 4, 8 [gunships] if player has >= 100, 80, 60 mobile land
    quantity = {3, 4, 8}
    trigger = {100, 80, 60}
    opai = OrderM2NorthBase:AddOpAI('AirAttacks', 'M2_AirAttacks5',
        {
            MasterPlatoonFunction = {'/maps/X1CA_Coop_002/X1CA_Coop_002_m2orderai.lua', 'M2OrderAirAttackAI'},
            Priority = 120,
        }
    )
    opai:SetChildQuantity({'Gunships'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], (categories.MOBILE * categories.LAND) - categories.CONSTRUCTION, '>='})

    -- sends 6, 8, 12 [air superiority] if player has >= 100, 80, 60 mobile air
    quantity = {6, 8, 12}
    trigger = {100, 80, 60}
    opai = OrderM2NorthBase:AddOpAI('AirAttacks', 'M2_AirAttacks6',
        {
            MasterPlatoonFunction = {'/maps/X1CA_Coop_002/X1CA_Coop_002_m2orderai.lua', 'M2OrderAirAttackAI'},
            Priority = 120,
        }
    )
    opai:SetChildQuantity({'AirSuperiority'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.MOBILE * categories.AIR, '>='})

    -- sends 6, 8, 12 [air superiority] if player has >= 60, 50, 40 gunships
    quantity = {6, 8, 12}
    trigger = {60, 50, 40}
    opai = OrderM2NorthBase:AddOpAI('AirAttacks', 'M2_AirAttacks7',
        {
            MasterPlatoonFunction = {'/maps/X1CA_Coop_002/X1CA_Coop_002_m2orderai.lua', 'M2OrderAirAttackAI'},
            Priority = 120,
        }
    )
    opai:SetChildQuantity({'AirSuperiority'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.uaa0203 + categories.uea0203 + categories.ura0203, '>='})

    -- sends 6, 8, 12 [combat fighters, gunships] if player has >= 60, 40, 20 T3 units
    quantity = {6, 8, 12}
    trigger = {60, 40, 20}
    opai = OrderM2NorthBase:AddOpAI('AirAttacks', 'M2_AirAttacks8',
        {
            MasterPlatoonFunction = {'/maps/X1CA_Coop_002/X1CA_Coop_002_m2orderai.lua', 'M2OrderAirAttackAI'},
            Priority = 130,
        }
    )
    opai:SetChildQuantity({'Gunships', 'CombatFighters'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.TECH3, '>='})

    -- sends 4, 6, 8 [air superiority] if player has >= 1 strat bomber
    quantity = {4, 6, 8}
    opai = OrderM2NorthBase:AddOpAI('AirAttacks', 'M2_AirAttacks9',
        {
            MasterPlatoonFunction = {'/maps/X1CA_Coop_002/X1CA_Coop_002_m2orderai.lua', 'M2OrderAirAttackAI'},
            Priority = 140,
        }
    )
    opai:SetChildQuantity({'AirSuperiority'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, 1, categories.uaa0304 + categories.uea0304 + categories.ura0304, '>='})

    -- sends 6, 12, 15 [bombers, gunships, heavy gunships] if player has >= 350, 400, 450 units
    quantity = {6, 12, 15}
    trigger = {350, 400, 450}
    opai = OrderM2NorthBase:AddOpAI('AirAttacks', 'M2_AirAttacks10',
        {
            MasterPlatoonFunction = {'/maps/X1CA_Coop_002/X1CA_Coop_002_m2orderai.lua', 'M2OrderAirAttackAI'},
            Priority = 150,
        }
    )
    opai:SetChildQuantity({'Bombers', 'Gunships', 'HeavyGunships'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.ALLUNITS - categories.WALL, '>='})

    -- Air Defense
    -- Maintains 4 Air Superiority
    for i = 1, 2 do
        opai = OrderM2NorthBase:AddOpAI('AirAttacks', 'M2_AirDefense1_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M2_Combined_AirDef_Chain',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity({'AirSuperiority'}, 2)
        opai:AddBuildCondition('/lua/editor/MiscBuildConditions.lua', 'MissionNumber', {'default_brain', 2})
    end

    -- Maintains 8 Combat Fighters
    for i = 1, 2 do
        opai = OrderM2NorthBase:AddOpAI('AirAttacks', 'M2_AirDefense2_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M2_Combined_AirDef_Chain',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity({'CombatFighters'}, 4)
        opai:AddBuildCondition('/lua/editor/MiscBuildConditions.lua', 'MissionNumber', {'default_brain', 2})
    end
end

function OrderM2NorthBaseLandAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    -----------------------------------------
    -- Order M2 North Base Op AI, Land Attacks
    -----------------------------------------

    -- sends 2, 2, 4 [light artillery]
    quantity = {2, 2, 4}
    opai = OrderM2NorthBase:AddOpAI('BasicLandAttack', 'M2_LandAttack1',
        {
            MasterPlatoonFunction = {'/maps/X1CA_Coop_002/X1CA_Coop_002_m2orderai.lua', 'M2OrderLandAttackAI'},
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'LightArtillery'}, quantity[Difficulty])
    opai:SetLockingStyle('None')

    -- sends 2, 2, 4 [light bots]
    quantity = {2, 2, 4}
    opai = OrderM2NorthBase:AddOpAI('BasicLandAttack', 'M2_LandAttack2',
        {
            MasterPlatoonFunction = {'/maps/X1CA_Coop_002/X1CA_Coop_002_m2orderai.lua', 'M2OrderLandAttackAI'},
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'LightBots'}, quantity[Difficulty])
    opai:SetLockingStyle('None')

    -- sends 2, 2, 4 [light tanks]
    quantity = {2, 2, 4}
    opai = OrderM2NorthBase:AddOpAI('BasicLandAttack', 'M2_LandAttack3',
        {
            MasterPlatoonFunction = {'/maps/X1CA_Coop_002/X1CA_Coop_002_m2orderai.lua', 'M2OrderLandAttackAI'},
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'LightTanks'}, quantity[Difficulty])
    opai:SetLockingStyle('None')

    -- sends 2, 2, 4 [heavy tanks]
    quantity = {2, 2, 4}
    opai = OrderM2NorthBase:AddOpAI('BasicLandAttack', 'M2_LandAttack4',
        {
            MasterPlatoonFunction = {'/maps/X1CA_Coop_002/X1CA_Coop_002_m2orderai.lua', 'M2OrderLandAttackAI'},
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'HeavyTanks'}, quantity[Difficulty])
    opai:SetLockingStyle('None')

    -- sends 2, 4, 8 [light tanks, heavy tanks] if player has >= 10, 7, 5 T2/T3 DF/IF
    quantity = {2, 4, 8}
    trigger = {10, 7, 5}
    opai = OrderM2NorthBase:AddOpAI('BasicLandAttack', 'M2_LandAttack5',
        {
            MasterPlatoonFunction = {'/maps/X1CA_Coop_002/X1CA_Coop_002_m2orderai.lua', 'M2OrderLandAttackAI'},
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'LightTanks', 'HeavyTanks'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], (categories.DIRECTFIRE + categories.INDIRECTFIRE) - categories.TECH1, '>='})

    -- sends 4, 6, 8 [light artillery, mobile missiles] if player has >= 100, 80, 60 mobile land
    quantity = {4, 6, 8}
    trigger = {100, 80, 60}
    opai = OrderM2NorthBase:AddOpAI('BasicLandAttack', 'M2_LandAttack6',
        {
            MasterPlatoonFunction = {'/maps/X1CA_Coop_002/X1CA_Coop_002_m2orderai.lua', 'M2OrderLandAttackAI'},
            Priority = 120,
        }
    )
    opai:SetChildQuantity({'LightArtillery', 'MobileMissiles'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], (categories.MOBILE * categories.LAND) - categories.CONSTRUCTION, '>='})

    -- sends 4, 6, 8 [mobile flak, mobile shields] if player has >= 100, 80, 60 mobile air
    quantity = {4, 6, 8}
    trigger = {100, 80, 60}
    opai = OrderM2NorthBase:AddOpAI('BasicLandAttack', 'M2_LandAttack7',
        {
            MasterPlatoonFunction = {'/maps/X1CA_Coop_002/X1CA_Coop_002_m2orderai.lua', 'M2OrderLandAttackAI'},
            Priority = 120,
        }
    )
    opai:SetChildQuantity({'MobileFlak', 'MobileShields'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.MOBILE * categories.AIR, '>='})

    -- sends 4, 6, 8 [mobile flak, mobile shields] if player has >= 60, 50, 40 gunships
    quantity = {4, 6, 8}
    trigger = {100, 80, 60}
    opai = OrderM2NorthBase:AddOpAI('BasicLandAttack', 'M2_LandAttack8',
        {
            MasterPlatoonFunction = {'/maps/X1CA_Coop_002/X1CA_Coop_002_m2orderai.lua', 'M2OrderLandAttackAI'},
            Priority = 120,
        }
    )
    opai:SetChildQuantity({'MobileFlak', 'MobileShields'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.uaa0203 + categories.uea0203 + categories.ura0203, '>='})

    -- sends 2, 4, 6 [siege bots, heavy bots] if player has >= 60, 40, 20 T3 units
    quantity = {2, 4, 6}
    trigger = {60, 40, 20}
    opai = OrderM2NorthBase:AddOpAI('BasicLandAttack', 'M2_LandAttack9',
        {
            MasterPlatoonFunction = {'/maps/X1CA_Coop_002/X1CA_Coop_002_m2orderai.lua', 'M2OrderLandAttackAI'},
            Priority = 130,
        }
    )
    opai:SetChildQuantity({'SiegeBots', 'HeavyBots'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.TECH3, '>='})

    -- sends 3, 4, 6 [mobile flak] if player has >= 1 strat bomber
    quantity = {3, 4, 6}
    opai = OrderM2NorthBase:AddOpAI('BasicLandAttack', 'M2_LandAttack10',
        {
            MasterPlatoonFunction = {'/maps/X1CA_Coop_002/X1CA_Coop_002_m2orderai.lua', 'M2OrderLandAttackAI'},
            Priority = 140,
        }
    )
    opai:SetChildQuantity({'MobileFlak'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, 1, categories.uaa0304 + categories.uea0304 + categories.ura0304, '>='})

    -- sends 3, 6, 9 [mobile heavy artillery, mobile missiles, light artillery] if player has >= 450, 400, 350 units
    quantity = {3, 6, 9}
    trigger = {450, 400, 350}
    opai = OrderM2NorthBase:AddOpAI('BasicLandAttack', 'M2_LandAttack11',
        {
            MasterPlatoonFunction = {'/maps/X1CA_Coop_002/X1CA_Coop_002_m2orderai.lua', 'M2OrderLandAttackAI'},
            Priority = 150,
        }
    )
    opai:SetChildQuantity({'MobileHeavyArtillery', 'MobileMissiles', 'LightArtillery'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainsCompareNumCategory',
        {'default_brain', {'HumanPlayers'}, trigger[Difficulty], categories.uaa0304 + categories.uea0304 + categories.ura0304, '>='})
end

function M2OrderAirAttackAI(platoon)
    local moveNum = false
    while(ArmyBrains[Order]:PlatoonExists(platoon)) do
        if(not ScenarioInfo.OrderAlly) then
            if(not moveNum or moveNum ~= 2) then
                moveNum = 2
                IssueStop(platoon:GetPlatoonUnits())
                IssueClearCommands(platoon:GetPlatoonUnits())
                for k, v in platoon:GetPlatoonUnits() do
                    if(v and not v:IsDead()) then
                        ScenarioFramework.GroupPatrolRoute({v}, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M2_Combined_AirAttack_Chain')))
                    end
                end
            end
        else
            if(not moveNum or moveNum ~= 4) then
                moveNum = 4
                IssueStop(platoon:GetPlatoonUnits())
                IssueClearCommands(platoon:GetPlatoonUnits())
                for k, v in platoon:GetPlatoonUnits() do
                    if(v and not v:IsDead()) then
                        ScenarioFramework.GroupPatrolChain({v}, 'M4_Order_Air_Attack' .. Random(1, 2) .. '_Chain')
                    end
                end
            end
        end
        WaitSeconds(1)
    end
end

function M2OrderLandAttackAI(platoon)
    local moveNum = false
    while(ArmyBrains[Order]:PlatoonExists(platoon)) do
        if(not ScenarioInfo.OrderAlly) then
            if(not moveNum or moveNum ~= 2) then
                moveNum = 2
                IssueStop(platoon:GetPlatoonUnits())
                IssueClearCommands(platoon:GetPlatoonUnits())
                if(Random(1, 2) == 1) then
                    ScenarioFramework.PlatoonPatrolChain(platoon, 'M2_Combined_LandAttack_Chain')
                else
                    ScenarioFramework.PlatoonPatrolChain(platoon, 'M2_Combined_LandAttack2_Chain')
                end
            end
        else
            if(not moveNum or moveNum ~= 4) then
                moveNum = 4
                IssueStop(platoon:GetPlatoonUnits())
                IssueClearCommands(platoon:GetPlatoonUnits())
                ScenarioFramework.PlatoonPatrolChain(platoon, 'M4_Order_Land_Attack' .. Random(1, 2) .. '_Chain')
            end
        end
        WaitSeconds(1)
    end
end
