local BaseManager = import('/lua/ai/opai/basemanager.lua')
local CustomFunctions = '/maps/Prothyon16/Prothyon16_CustomFunctions.lua'
local SPAIFileName = '/lua/scenarioplatoonai.lua'

---------
-- Locals
---------
local UEF = 2
local Difficulty = ScenarioInfo.Options.Difficulty

----------------
-- Base Managers
----------------
local UEFM5IslandBase = BaseManager.CreateBaseManager()

---------------------
-- UEF M5 Island Base
---------------------
function UEFM5IslandBaseAI()
    UEFM5IslandBase:InitializeDifficultyTables(ArmyBrains[UEF], 'M5_UEF_Island_Base', 'M5_UEF_Island_Base_Marker', 100, {M5_UEF_Island_Base = 100})
    UEFM5IslandBase:StartNonZeroBase({{24, 20, 16}, {21, 17, 14}})
    -- UEFM5IslandBase:SetActive('AirScouting', true)
    -- UEFM5IslandBase:SetSupportACUCount(1)

    ForkThread(function()
        WaitSeconds(1)
        UEFM5IslandBase:AddBuildGroup('M5_UEF_Island_Support_Factories', 100, true)
        UEFM5IslandBase:AddBuildGroupDifficulty('M5_UEF_Island_Base_Defences', 90, true)
    end)

    UEFM5IslandBaseAirAttacks()
    UEFM5IslandBaseLandAttacks()
    UEFM5IslandBaseNavalAttacks()
end

function UEFM5IslandBaseAirAttacks()
	local opai = nil
    local quantity = {}

    -- Sends 2 x 5 Torpedo Bombers
    for i = 1, 2 do
        opai = UEFM5IslandBase:AddOpAI('AirAttacks', 'M5_IslandAirAttack1_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
                PlatoonData = {
                    PatrolChains = {'M5_UEF_Island_Air_Attack_Chain1',
                                    'M5_UEF_Island_Air_Attack_Chain2',
                                    'M5_UEF_Island_Hover_Attack_Chain',
                                    'M5_UEF_Island_Naval_Attack_Chain1',
                                    'M5_UEF_Island_Naval_Attack_Chain2'},
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('TorpedoBombers', 5)
    end

    -- Sends 3 x 10 Gunships
    quantity = {10, 7, 5}
    for i = 1, 2 do
        opai = UEFM5IslandBase:AddOpAI('AirAttacks', 'M5_IslandAirAttack2_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
                PlatoonData = {
                    PatrolChains = {'M5_UEF_Island_Air_Attack_Chain1',
                                    'M5_UEF_Island_Air_Attack_Chain2'},
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('Gunships', quantity[Difficulty])
    end

    -- Sends 3 x 5 Interceptors
    quantity = {5, 4, 4}
    for i = 1, 3 do
        opai = UEFM5IslandBase:AddOpAI('AirAttacks', 'M5_IslandAirAttack3_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
                PlatoonData = {
                    PatrolChains = {'M5_UEF_Island_Air_Attack_Chain1',
                                    'M5_UEF_Island_Air_Attack_Chain2',
                                    'M5_UEF_Island_Hover_Attack_Chain',
                                    'M5_UEF_Island_Naval_Attack_Chain1',
                                    'M5_UEF_Island_Naval_Attack_Chain2'},
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('Interceptors', quantity[Difficulty])
    end

	-- Air Defense
    -- Maintains 20/15/10 CombatFighters
    for i = 1, 5 - Difficulty do
        opai = UEFM5IslandBase:AddOpAI('AirAttacks', 'M5_IslandAirDefense1_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M5_UEF_Island_Air_Defense_Chain',
                },
                Priority = 110,
            }
        )
        opai:SetChildQuantity('CombatFighters', 5)
    end

    -- Maintains 15 Gunships
    quantity = {5, 4, 4}
    for i = 1, 3 do
        opai = UEFM5IslandBase:AddOpAI('AirAttacks', 'M5_IslandAirDefense2_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M5_UEF_Island_Air_Defense_Chain',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('Gunships', quantity[Difficulty])
    end

    -- Maintains 16 Tropedo Bombers
    for i = 1, 5 - Difficulty do
        opai = UEFM5IslandBase:AddOpAI('AirAttacks', 'M5_IslandAirDefense3_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M5_UEF_Island_Air_Defense_Chain',
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('TorpedoBombers', 4)
    end

    -- Maintains 10 Tropedo Bombers
    for i = 1, 2 do
        opai = UEFM5IslandBase:AddOpAI('AirAttacks', 'M5_IslandAirDefense4_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M5_UEF_Island_Air_Defense_Chain',
                },
                Priority = 90,
            }
        )
        opai:SetChildQuantity('Interceptors', 5)
    end
end

function UEFM5IslandBaseLandAttacks()
    local opai = nil

    opai = UEFM5IslandBase:AddOpAI('EngineerAttack', 'M5_UEFBase_Reclaim_Engineers_1',
    {
        MasterPlatoonFunction = {SPAIFileName, 'SplitPatrolThread'},
        PlatoonData = {
            PatrolChains = {'M5_UEF_Island_Hover_Attack_Chain',
                            'M5_UEF_Island_Naval_Attack_Chain1',
                            'M5_UEF_Island_Naval_Attack_Chain2',
                            'M5_UEF_Island_Naval_Defense_Chain2'},
        },
        Priority = 300,
    })
    opai:SetChildQuantity('CombatEngineers', 8)
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})

    opai = UEFM5IslandBase:AddOpAI('EngineerAttack', 'M5_UEFBase_Reclaim_Engineers_2',
    {
        MasterPlatoonFunction = {SPAIFileName, 'SplitPatrolThread'},
        PlatoonData = {
            PatrolChains = {'M5_UEF_Island_Base_EngineerChain'},
        },
        Priority = 300,
    })
    opai:SetChildQuantity('CombatEngineers', 2)

    -- sends 12 [hover tanks] 5 times
    for i = 1, 5 do
        opai = UEFM5IslandBase:AddOpAI('BasicLandAttack', 'M5_UEF_HoverAttack1_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
                PlatoonData = {
                    PatrolChains = {'M5_UEF_Island_Hover_Attack_Chain', 'M5_UEF_Island_Naval_Attack_Chain1', 'M5_UEF_Island_Naval_Attack_Chain2'},
                },
                Priority = 100,
            }
        )
        opai:SetChildQuantity('AmphibiousTanks', 12)
    end
end

function UEFM5IslandBaseNavalAttacks()
    local opai = nil
    local quantity = {}
    --[[
    for i = 1, 2 do
        opai = UEFM5IslandBase:AddNavalAI('M5_UEF_NavalAttack_1_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
                PlatoonData = {
                    PatrolChains = {'M5_UEF_Island_Naval_Attack_Chain1', 'M5_UEF_Island_Naval_Attack_Chain2'},
                },
                Overrides = {
                    CORE_TO_CRUISERS = 2,
                    CORE_TO_UTILITY = 2,
                },
                EnabledTypes = {'Destroyer', 'Cruiser', 'Utility'},
                MaxFrigates = 20,
                MinFrigates = 20,
                Priority = 200,
            }
        )
        opai:SetChildActive('T1', false)
        opai:SetChildActive('T3', false)
        opai:SetLockingStyle('DeathRatio', {Ratio = 0.7})
    ]]--
	-- Defense
    -- 4 Destroyers, 2 Cruisers, 2 Shieldboats
    opai = UEFM5IslandBase:AddNavalAI('M5_UEF_NavalDefense_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M5_UEF_Island_Naval_Defense_Chain1',
            },
            Overrides = {
                CORE_TO_CRUISERS = 2,
                CORE_TO_UTILITY = 2,
            },
            EnabledTypes = {'Destroyer', 'Cruiser', 'Utility'},
            MaxFrigates = 20,
            MinFrigates = 20,
            Priority = 220,
        }
    )
    opai:SetChildActive('T1', false)
    opai:SetChildActive('T3', false)
    opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})

    -- 4 Destroyers
    quantity = {24, 24, 20}
    opai = UEFM5IslandBase:AddNavalAI('M5_UEF_NavalDefense_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M5_UEF_Island_Naval_Defense_Chain2',
            },
            EnabledTypes = {'Destroyer'},
            MaxFrigates = quantity[Difficulty],
            MinFrigates = quantity[Difficulty],
            Priority = 210,
        }
    )
    opai:SetChildActive('T1', false)
    opai:SetChildActive('T3', false)
end

function EscapeTransportBuilder()
    local opai = nil

    opai = UEFM5IslandBase:AddOpAI('EngineerAttack', 'M5_UEF_TransportBuilder',
    {
        MasterPlatoonFunction = {'/lua/ScenarioPlatoonAI.lua', 'LandAssaultWithTransports'},
        PlatoonData = {
            TransportReturn = 'M3_Land_Base_Marker',
        },
        Priority = 1000,
    })
    opai:SetChildQuantity('T2Transports', 1)
    opai:AddBuildCondition('/lua/editor/unitcountbuildconditions.lua',
        'HaveLessThanUnitsWithCategory', {'default_brain', 1, categories.uea0104})
end

function DisbandSACUPlatoon()
    --[[
    if (UEFM5IslandBase) then
        LOG('speed2 >>> UEFM5IslandBase stopped')
        UEFM5IslandBase:BaseActive(false)
    end
    for k, platoon in ArmyBrains[UEF]:GetPlatoonsList() do
        platoon:Stop()
        ArmyBrains[UEF]:DisbandPlatoon(platoon)
    end
    LOG('speed2 >>> All Platoons of UEFM5IslandBase stopped')
    ]]--
    for _, platoon in ArmyBrains[UEF]:GetPlatoonsList() do
        for _, unit in platoon:GetPlatoonUnits() do
            if EntityCategoryContains( categories.SUBCOMMANDER, unit ) then
                ArmyBrains[UEF]:DisbandPlatoon(platoon)
                LOG('speed2 >>> sACU platoon disband')

                -- Put into a platoon to make sure the base manager won't grab it again
                local plat = ArmyBrains[UEF]:MakePlatoon('', '')
                ArmyBrains[UEF]:AssignUnitsToPlatoon(plat, {unit}, 'Attack', 'NoFormation')
            end
        end
    end
end