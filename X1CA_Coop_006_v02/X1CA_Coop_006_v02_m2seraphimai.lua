#****************************************************************************
#**
#**  File     : /maps/X1CA_Coop_006_v02/X1CA_Coop_006_v02_m2seraphimai.lua
#**  Author(s): Jessica St. Croix
#**
#**  Summary  : Seraphim army AI for Mission 2 - X1CA_Coop_006_v02
#**
#**  Copyright © 2007 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************
local BaseManager = import('/lua/ai/opai/basemanager.lua')
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local SPAIFileName = '/lua/ScenarioPlatoonAI.lua'

# ------
# Locals
# ------
local Seraphim = 5
local Difficulty = ScenarioInfo.Options.Difficulty

# -------------
# Base Managers
# -------------
local SeraphimM2Base = BaseManager.CreateBaseManager()

function SeraphimM2BaseAI()

    # ----------------
    # Seraphim M2 Base
    # ----------------
    SeraphimM2Base:InitializeDifficultyTables(ArmyBrains[Seraphim], 'M2_Seraph_Base', 'M2_Seraphim_Base_Marker', 130, {M2_Seraph_Base = 100})
    SeraphimM2Base:StartNonZeroBase({{4, 12, 18}, {4, 8, 14}})
	SeraphimM2Base:SetMaximumConstructionEngineers(3)
	SeraphimM2Base:SetConstructionAlwaysAssist(true)
    SeraphimM2Base:SetActive('AirScouting', true)

    SeraphimM2BaseAirAttacks()
    SeraphimM2BaseLandAttacks()
    SeraphimM2BaseNavalAttacks()
end

function SeraphimM2BaseAirAttacks()
    local opai = nil

    # ------------------------------------
    # Seraphim M2 Base Op AI - Air Attacks
    # ------------------------------------

    # sends [gunships]
    opai = SeraphimM2Base:AddOpAI('AirAttacks', 'M2_SeraphimAirAttacks1',
        {
            MasterPlatoonFunction = {'/maps/X1CA_Coop_006_v02/X1CA_Coop_006_v02_m2seraphimai.lua', 'M2SeraphimAirAttackAI'},
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Gunships', 18)
    opai:SetLockingStyle('None')

    # sends [gunships, combat fighters]
    opai = SeraphimM2Base:AddOpAI('AirAttacks', 'M2_SeraphimAirAttacks2',
        {
            MasterPlatoonFunction = {'/maps/X1CA_Coop_006_v02/X1CA_Coop_006_v02_m2seraphimai.lua', 'M2SeraphimAirAttackAI'},
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'Gunships', 'CombatFighters'}, 12)
    opai:SetLockingStyle('None')

    # sends [bombers]
    opai = SeraphimM2Base:AddOpAI('AirAttacks', 'M2_SeraphimAirAttacks3',
        {
            MasterPlatoonFunction = {'/maps/X1CA_Coop_006_v02/X1CA_Coop_006_v02_m2seraphimai.lua', 'M2SeraphimAirAttackAI'},
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Bombers', 30)

    # sends [strat bombers]
    opai = SeraphimM2Base:AddOpAI('AirAttacks', 'M2_SeraphimAirAttacks4',
        {
            MasterPlatoonFunction = {'/maps/X1CA_Coop_006_v02/X1CA_Coop_006_v02_m2seraphimai.lua', 'M2SeraphimAirAttackAI'},
            Priority = 110,
        }
    )
    opai:SetChildQuantity('StratBombers', 12)

    # sends [air sups]
    opai = SeraphimM2Base:AddOpAI('AirAttacks', 'M2_SeraphimAirAttacks5',
        {
            MasterPlatoonFunction = {'/maps/X1CA_Coop_006_v02/X1CA_Coop_006_v02_m2seraphimai.lua', 'M2SeraphimAirAttackAI'},
            Priority = 110,
        }
    )
    opai:SetChildQuantity('AirSuperiority', 12)

    # Air Defense
	for i = 1, 3 do
    opai = SeraphimM2Base:AddOpAI('AirAttacks', 'M2_SeraphimAirDefense1' .. i,
        {
            MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Seraph_AirDef_Chain',
            },
            Priority = 140,
        }
    )
    opai:SetChildQuantity('AirSuperiority', 6)

    opai = SeraphimM2Base:AddOpAI('AirAttacks', 'M2_SeraphimAirDefense2' .. i,
        {
            MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Seraph_AirDef_Chain',
            },
            Priority = 140,
        }
    )
    opai:SetChildQuantity('Gunships', 6)
	end
end

function SeraphimM2BaseLandAttacks()
    local opai = nil
    local quantity = {}

    # -------------------------------------
    # Seraphim M2 Base Op AI - Land Attacks
    # -------------------------------------

    # sends engineers
    opai = SeraphimM2Base:AddOpAI('EngineerAttack', 'M2_SeraphimEngAttack1',
    {
        MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
        PlatoonData = {
            AttackChain = 'M2_Seraph_EngAttack_Attack_Chain',
            LandingChain = 'M2_Seraph_EngAttack_Landing_Chain',
            TransportReturn = 'M2_Seraph_Return_Point',
            Categories = {'ECONOMIC'},
        },
        Priority = 100,
    })
    opai:SetChildActive('T1Transports', false)

    # Land Defense
    quantity = {2, 4, 6}
    opai = SeraphimM2Base:AddOpAI('BasicLandAttack', 'M2_SeraphimLandDefense1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
                PlatoonData = {
                    PatrolChains = {'M2_Seraph_Land_Def_1_Chain', 'M2_Seraph_Land_Def_2_Chain'},
                },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('MobileMissiles', quantity[Difficulty])

    quantity = {2, 4, 6}
    opai = SeraphimM2Base:AddOpAI('BasicLandAttack', 'M2_SeraphimLandDefense2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
                PlatoonData = {
                    PatrolChains = {'M2_Seraph_Land_Def_1_Chain', 'M2_Seraph_Land_Def_2_Chain'},
                },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('MobileFlak', quantity[Difficulty])

    quantity = {2, 4, 6}
    opai = SeraphimM2Base:AddOpAI('BasicLandAttack', 'M2_SeraphimLandDefense3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
                PlatoonData = {
                    PatrolChains = {'M2_Seraph_Land_Def_1_Chain', 'M2_Seraph_Land_Def_2_Chain'},
                },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('SiegeBots', quantity[Difficulty])
end

function SeraphimM2BaseNavalAttacks()

    # --------------------------------------
    # Seraphim M2 Base Op AI - Naval Attacks
    # --------------------------------------

    # sends 20 frigate power to Fletcher
    local opai = SeraphimM2Base:AddNavalAI('M2_SeraphimNavalAttack_Fletcher',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Rhiza_NavalAttack_Fletcher_Chain',
            },
            MaxFrigates = 40,
            MinFrigates = 40,
            Priority = 105,
        }
    )
    opai:SetChildActive('T3', false)
	
    # sends 20 frigate power
    opai = SeraphimM2Base:AddNavalAI('M2_SeraphimNavalAttack1',
        {
            MasterPlatoonFunction = {'/maps/X1CA_Coop_006_v02/X1CA_Coop_006_v02_m2seraphimai.lua', 'M2SeraphimNavalAttackAI'},
            MaxFrigates = 20,
            MinFrigates = 20,
            Priority = 100,
        }
    )
	opai:SetLockingStyle('None')

    # sends 10 frigate power of [all but T3]
    opai = SeraphimM2Base:AddNavalAI('M2_SeraphimNavalAttack2',
        {
            MasterPlatoonFunction = {'/maps/X1CA_Coop_006_v02/X1CA_Coop_006_v02_m2seraphimai.lua', 'M2SeraphimNavalAttackAI'},
            MaxFrigates = 10,
            MinFrigates = 10,
            Priority = 105,
        }
    )
    opai:SetChildActive('T3', false)

    # sends 15 frigate power of [all but T3]
    opai = SeraphimM2Base:AddNavalAI('M2_SeraphimNavalAttack3',
        {
            MasterPlatoonFunction = {'/maps/X1CA_Coop_006_v02/X1CA_Coop_006_v02_m2seraphimai.lua', 'M2SeraphimNavalAttackAI'},
            MaxFrigates = 15,
            MinFrigates = 15,
            Priority = 100,
        }
    )
	opai:SetLockingStyle('None')

    # Naval Defense
    opai = SeraphimM2Base:AddNavalAI('M2_SeraphimNavalDefense1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M2_Seraph_Naval_Def_Chain',
            },
            MaxFrigates = 20,
            MinFrigates = 20,
            Priority = 110,
        }
    )
end

function M2SeraphimAirAttackAI(platoon)
    local moveNum = false
    while(ArmyBrains[Seraphim]:PlatoonExists(platoon)) do
        if(ScenarioInfo.RhizaACU and not ScenarioInfo.RhizaACU:IsDead()) then
            if(not moveNum) then
                moveNum = 1
                IssueStop(platoon:GetPlatoonUnits())
                IssueClearCommands(platoon:GetPlatoonUnits())
                ScenarioFramework.PlatoonPatrolChain(platoon, 'M2_Seraph_AirAttack_Rhiza_Chain')
            end
        else
            if(not moveNum or moveNum ~= 2) then
                moveNum = 2
                IssueStop(platoon:GetPlatoonUnits())
                IssueClearCommands(platoon:GetPlatoonUnits())
                ScenarioFramework.PlatoonPatrolChain(platoon, 'M2_Seraph_AirAttack_Player_Chain')
            end
        end
        WaitSeconds(10)
    end
end

function M2SeraphimNavalAttackAI(platoon)
    local moveNum = false
    while(ArmyBrains[Seraphim]:PlatoonExists(platoon)) do
        if(ScenarioInfo.RhizaACU and not ScenarioInfo.RhizaACU:IsDead()) then
            if(not moveNum) then
                moveNum = 1
                IssueStop(platoon:GetPlatoonUnits())
                IssueClearCommands(platoon:GetPlatoonUnits())
                ScenarioFramework.PlatoonPatrolChain(platoon, 'M2_Seraph_NavalAttack_Rhiza_Chain')
            end
        else
            if(not moveNum or moveNum ~= 2) then
                moveNum = 2
                IssueStop(platoon:GetPlatoonUnits())
                IssueClearCommands(platoon:GetPlatoonUnits())
                ScenarioFramework.PlatoonPatrolChain(platoon, 'M2_Seraph_NavalAttack_Player_Chain')
            end
        end
        WaitSeconds(10)
    end
end