-- ****************************************************************************
-- **
-- **  File     : /maps/X1CA_Coop_003_v02/X1CA_Coop_003_v02_m1seraphimai.lua
-- **  Author(s): Jessica St. Croix
-- **
-- **  Summary  : Seraphim army AI for Mission 1 - X1CA_Coop_003_v02
-- **
-- **  Copyright © 2007 Gas Powered Games, Inc.  All rights reserved.
-- ****************************************************************************
local BaseManager = import('/lua/ai/opai/basemanager.lua')

local SPAIFileName = '/lua/ScenarioPlatoonAI.lua'

-- ------
-- Locals
-- ------
local Seraphim = 2
local Difficulty = ScenarioInfo.Options.Difficulty

-- -------------
-- Base Managers
-- -------------
local SeraphimM1NorthBase = BaseManager.CreateBaseManager()
local SeraphimM1MiddleBase = BaseManager.CreateBaseManager()

function SeraphimM1NorthBaseAI()

    -- ----------------------
    -- Seraphim M1 North Base
    -- ----------------------
    SeraphimM1NorthBase:InitializeDifficultyTables(ArmyBrains[Seraphim], 'M1_North_Base', 'Seraphim_M1_North_Base', 200, {M1_North_Base = 100})
    SeraphimM1NorthBase:StartNonZeroBase({{12, 19, 28}, {10, 16, 24}})
    SeraphimM1NorthBase:SetMaximumConstructionEngineers(4)
    SeraphimM1NorthBase:SetActive('AirScouting', true)
    SeraphimM1NorthBase:SetBuild('Defenses', false)

    SeraphimM1NorthBase:AddReactiveAI('ExperimentalLand', 'AirRetaliation', 'SeraphimM1NorthBase_ExperimentalLand')
    SeraphimM1NorthBase:AddReactiveAI('ExperimentalAir', 'AirRetaliation', 'SeraphimM1NorthBase_ExperimentalAir')
    SeraphimM1NorthBase:AddReactiveAI('ExperimentalNaval', 'AirRetaliation', 'SeraphimM1NorthBase_ExperimentalNaval')
    SeraphimM1NorthBase:AddReactiveAI('Nuke', 'AirRetaliation', 'SeraphimM1NorthBase_Nuke')
    SeraphimM1NorthBase:AddReactiveAI('HLRA', 'AirRetaliation', 'SeraphimM1NorthBase_HLRA')

    SeraphimM1NorthBaseAirAttacks()
    SeraphimM1NorthBaseNavalAttacks()
end

function SeraphimM1NorthBaseAirAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    -- -----------------------------------------
    -- Seraphim M1 North Base Op AI, Air Attacks
    -- -----------------------------------------

    -- sends 4, 6, 8 [bombers]
    quantity = {4, 6, 8}
    opai = SeraphimM1NorthBase:AddOpAI('AirAttacks', 'M1_AirAttacks1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Seraph_Air_Attack1_Chain', 'M1_Seraph_Air_Attack2_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Bombers', quantity[Difficulty])

    -- sends 4, 6, 8 [interceptors]
    quantity = {4, 6, 8}
    opai = SeraphimM1NorthBase:AddOpAI('AirAttacks', 'M1_AirAttacks2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Seraph_Air_Attack1_Chain', 'M1_Seraph_Air_Attack2_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Interceptors', quantity[Difficulty])

    -- sends 6, 8, 12 [gunships, combat fighters]
    quantity = {6, 8, 12}
    opai = SeraphimM1NorthBase:AddOpAI('AirAttacks', 'M1_MAINAirAttack',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Seraph_Air_Attack1_Chain', 'M1_Seraph_Air_Attack2_Chain'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'Gunships', 'Interceptors'}, quantity[Difficulty])
	opai:SetLockingStyle('None')

    -- sends 4, 6, 8 [bombers] if player has >= 12, 8, 5 AA
    quantity = {4, 6, 8}
    trigger = {12, 8, 5}
    opai = SeraphimM1NorthBase:AddOpAI('AirAttacks', 'M1_AirAttacks3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Seraph_Air_Attack3_Chain', 'M1_Seraph_Air_Attack4_Chain'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Bombers', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.ANTIAIR})

    -- sends 4, 6, 8 [gunships, combat fighter] if player has >= 7, 5, 3 T2/T3 AA
    quantity = {4, 6, 8}
    trigger = {7, 5, 3}
    opai = SeraphimM1NorthBase:AddOpAI('AirAttacks', 'M1_AirAttacks4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Seraph_Air_Attack3_Chain', 'M1_Seraph_Air_Attack4_Chain'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'Gunships', 'CombatFighters'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.ANTIAIR - categories.TECH1})

    -- sends 4, 6, 8 [interceptors] if player has >= 15, 10, 10 mobile air
    quantity = {4, 6, 8}
    trigger = {15, 10, 10}
    opai = SeraphimM1NorthBase:AddOpAI('AirAttacks', 'M1_AirAttacks5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Seraph_Air_Attack3_Chain', 'M1_Seraph_Air_Attack4_Chain'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Interceptors', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.MOBILE * categories.AIR})

    -- sends 4, 6, 8 [torpedo bombers] if player has >= 10, 7, 3 boats
    quantity = {4, 6, 8}
    trigger = {10, 7, 3}
    opai = SeraphimM1NorthBase:AddOpAI('AirAttacks', 'M1_AirAttacks6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Seraph_Naval_Attack4_Chain', 'M1_Seraph_Naval_Attack5_Chain'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('TorpedoBombers', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.NAVAL * categories.MOBILE})

    -- sends 4, 6, 8 [bombers] if player has >= 50, 40, 30 structures
    quantity = {4, 6, 8}
    trigger = {50, 40, 30}
    opai = SeraphimM1NorthBase:AddOpAI('AirAttacks', 'M1_AirAttacks7',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Seraph_Air_Attack3_Chain', 'M1_Seraph_Air_Attack4_Chain'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('Bombers', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.STRUCTURE - categories.WALL})

    -- sends 4, 6, 8 [gunships] if player has >= 30, 20, 10 T2/T3 structures
    quantity = {4, 6, 8}
    trigger = {30, 20, 10}
    opai = SeraphimM1NorthBase:AddOpAI('AirAttacks', 'M1_AirAttacks8',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Seraph_Air_Attack3_Chain', 'M1_Seraph_Air_Attack4_Chain'},
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.STRUCTURE - categories.TECH1})

    -- sends 4, 6, 8 [gunships] if player has >= 75, 60, 40 mobile land units
    quantity = {4, 6, 8}
    trigger = {75, 60, 40}
    opai = SeraphimM1NorthBase:AddOpAI('AirAttacks', 'M1_AirAttacks9',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Seraph_Air_Attack3_Chain', 'M1_Seraph_Air_Attack4_Chain'},
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], (categories.MOBILE * categories.LAND) - categories.CONSTRUCTION})

    -- sends 8, 12, 16 [combat fighter] if player has >= 75, 60, 40 mobile air units
    quantity = {8, 12, 16}
    trigger = {75, 60, 40}
    opai = SeraphimM1NorthBase:AddOpAI('AirAttacks', 'M1_AirAttacks10',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Seraph_Air_Attack3_Chain', 'M1_Seraph_Air_Attack4_Chain'},
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity('CombatFighters', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.MOBILE * categories.AIR})

    -- sends 6, 8, 12 [combat fighter, gunships] if player has >= 40, 30, 20 gunships
    quantity = {6, 8, 12}
    trigger = {40, 30, 20}
    opai = SeraphimM1NorthBase:AddOpAI('AirAttacks', 'M1_AirAttacks11',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Seraph_Air_Attack3_Chain', 'M1_Seraph_Air_Attack4_Chain'},
            },
            Priority = 130,
        }
    )
    opai:SetChildQuantity({'CombatFighters', 'Gunships'}, quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.uaa0203 + categories.uea0203 + categories.ura0203})

    -- sends 4, 6, 8 [gunships] if player has >= 50, 40, 30 T3 units
    quantity = {4, 6, 8}
    trigger = {50, 40, 30}
    opai = SeraphimM1NorthBase:AddOpAI('AirAttacks', 'M1_AirAttacks12',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Seraph_Air_Attack3_Chain', 'M1_Seraph_Air_Attack4_Chain'},
            },
            Priority = 140,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.TECH3})

    -- sends 4, 6, 8 [combat fighter] if player has >= 1 strat bomber
    quantity = {4, 6, 8}
    opai = SeraphimM1NorthBase:AddOpAI('AirAttacks', 'M1_AirAttacks13',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Seraph_Air_Attack3_Chain', 'M1_Seraph_Air_Attack4_Chain'},
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity('CombatFighters', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', 1, categories.uaa0304 + categories.uea0304 + categories.ura0304})

    -- sends 4, 6, 8 [torpedo bombers] if player has >= 1 T3 boat
    quantity = {4, 6, 8}
    opai = SeraphimM1NorthBase:AddOpAI('AirAttacks', 'M1_AirAttacks14',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Seraph_Naval_Attack4_Chain', 'M1_Seraph_Naval_Attack5_Chain'},
            },
            Priority = 160,
        }
    )
    opai:SetChildQuantity('TorpedoBombers', quantity[Difficulty])
    opai:SetLockingStyle('None')
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', 1, categories.MOBILE * categories.NAVAL * categories.TECH3})

    -- sends 4, 6, 8 [gunships] if player has >= 300, 250, 200 units
    quantity = {4, 6, 8}
    trigger = {300, 250, 200}
    opai = SeraphimM1NorthBase:AddOpAI('AirAttacks', 'M1_AirAttacks15',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Seraph_Air_Attack3_Chain', 'M1_Seraph_Air_Attack4_Chain'},
            },
            Priority = 160,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])
    opai:SetLockingStyle('None')
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.ALLUNITS - categories.WALL})

    -- Air Defense
    for i = 1, 3 do
        opai = SeraphimM1NorthBase:AddOpAI('AirAttacks', 'M1North_AirDefense' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M1_Seraph_Main_AirDef_Chain',
                },
                Priority = 180,
            }
        )
        opai:SetChildQuantity('AirSuperiority', 4)
    end

    for i = 1, 4 do
        opai = SeraphimM1NorthBase:AddOpAI('AirAttacks', 'M1Mid_AirDefense' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M1_Seraph_MidAir_Def_Chain',
                },
                Priority = 180,
            }
        )
        opai:SetChildQuantity('AirSuperiority', 2)
    end
end

function SeraphimM1NorthBaseNavalAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    -- -------------------------------------------
    -- Seraphim M1 North Base Op AI, Naval Attacks
    -- -------------------------------------------

    -- sends 3 frigate power of [frigates]
    opai = SeraphimM1NorthBase:AddNavalAI('M1_NavalAttack1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Seraph_Naval_Attack1_Chain', 'M1_Seraph_Naval_Attack2_Chain', 'M1_Seraph_Naval_Attack3_Chain'}
            },
            EnableTypes = {'Frigate'},
            MaxFrigates = 3,
            MinFrigates = 3,
            Priority = 100,
        }
    )

    -- sends 9 frigate power of all but T3
    opai = SeraphimM1NorthBase:AddNavalAI('M1_NavalAttack1_bis',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Seraph_Naval_Attack1_Chain', 'M1_Seraph_Naval_Attack2_Chain', 'M1_Seraph_Naval_Attack3_Chain'}
            },
            MaxFrigates = 9,
            MinFrigates = 9,
            Priority = 105,
        }
    )
    opai:SetChildActive('T3', false)

    -- sends 6 - 10 frigate power of all but T3
    opai = SeraphimM1NorthBase:AddNavalAI('M1_NavalAttack2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Seraph_Naval_Attack1_Chain', 'M1_Seraph_Naval_Attack2_Chain', 'M1_Seraph_Naval_Attack3_Chain'}
            },
            MaxFrigates = 10,
            MinFrigates = 6,
            Priority = 100,
        }
    )
    opai:SetChildActive('T3', false)

    -- sends 16 frigate power of all but T3
    opai = SeraphimM1NorthBase:AddNavalAI('M1_NavalAttack2_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Seraph_Naval_Attack1_Chain', 'M1_Seraph_Naval_Attack2_Chain', 'M1_Seraph_Naval_Attack3_Chain'}
            },
            MaxFrigates = 16,
            MinFrigates = 16,
            Priority = 95,
        }
    )
    opai:SetChildActive('T3', false)
    opai:SetLockingStyle('None')

    -- sends 20 frigate power of all but T3
    opai = SeraphimM1NorthBase:AddNavalAI('M1_NavalAttack2_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Seraph_Naval_Attack1_Chain', 'M1_Seraph_Naval_Attack2_Chain', 'M1_Seraph_Naval_Attack3_Chain'}
            },
            MaxFrigates = 20,
            MinFrigates = 20,
            Priority = 95,
        }
    )

    -- sends 6 frigate power of [frigates, subs] if player has >= 8, 6, 4 boats
    trigger = {8, 6, 4}
    opai = SeraphimM1NorthBase:AddNavalAI('M1_NavalAttack3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Seraph_Naval_Attack1_Chain', 'M1_Seraph_Naval_Attack2_Chain', 'M1_Seraph_Naval_Attack3_Chain'}
            },
            EnableTypes = {'Frigate', 'Submarine'},
            MaxFrigates = 6,
            MinFrigates = 6,
            Priority = 110,
        }
    )
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.NAVAL * categories.MOBILE})

    -- sends 6 frigate power of [frigates, subs] if player has >= 20, 15, 10 boats
    quantity = {4, 6, 8}
    trigger = {20, 15, 10}
    opai = SeraphimM1NorthBase:AddNavalAI('M1_NavalAttack4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Seraph_Naval_Attack1_Chain', 'M1_Seraph_Naval_Attack2_Chain', 'M1_Seraph_Naval_Attack3_Chain'}
            },
            EnableTypes = {'Frigate', 'Submarine'},
            MaxFrigates = quantity[Difficulty],
            MinFrigates = quantity[Difficulty],
            Priority = 120,
        }
    )
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], categories.NAVAL * categories.MOBILE})

    -- sends 6, 9, 12 frigate power of [all but T3] if player has >= 5, 3, 2 T2/T3 boats
    quantity = {6, 9, 12}
    trigger = {5, 3, 2}
    opai = SeraphimM1NorthBase:AddNavalAI('M1_NavalAttack5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Seraph_Naval_Attack1_Chain', 'M1_Seraph_Naval_Attack2_Chain', 'M1_Seraph_Naval_Attack4_Chain', 'M1_Seraph_Naval_Attack5_Chain'}
            },
            MaxFrigates = quantity[Difficulty],
            MinFrigates = quantity[Difficulty],
            Priority = 130,
        }
    )
    opai:SetChildActive('T3', false)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',  'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], (categories.NAVAL * categories.MOBILE) - categories.TECH1})

    -- sends 9, 12, 15 frigate power of [all but T3] if player has >= 6, 5, 4 T2/T3 boats
    quantity = {9, 12, 15}
    trigger = {6, 5, 4}
    opai = SeraphimM1NorthBase:AddNavalAI('M1_NavalAttack6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_Seraph_Naval_Attack1_Chain', 'M1_Seraph_Naval_Attack2_Chain', 'M1_Seraph_Naval_Attack4_Chain', 'M1_Seraph_Naval_Attack5_Chain'}
            },
            MaxFrigates = quantity[Difficulty],
            MinFrigates = quantity[Difficulty],
            Priority = 140,
        }
    )
    opai:SetChildActive('T3', false)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', trigger[Difficulty], (categories.NAVAL * categories.MOBILE) - categories.TECH1})

    -- sends 15 frigate power of all but T3
    for i = 1, 2 do
    for x = 1, Difficulty do
    opai = SeraphimM1NorthBase:AddNavalAI('M1_NavalDefense_' .. i .. x,
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M1_Seraph_Main_NavalDef' .. i .. '_Chain',
            },
            MaxFrigates = 15,
            MinFrigates = 15,
            Priority = 160,
        }
    )
    opai:SetChildActive('T3', false)
    end
    end
	
    -- sends 15 frigate power of all but T3
	for i = 1, 2 do
        opai = SeraphimM1NorthBase:AddNavalAI('M1_NavalDefense_ForwardEast' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M1_Seraph_MidPatrol_East' .. i .. '_Chain',
                },
                MaxFrigates = 20,
                MinFrigates = 20,
                Priority = 150,
            }
        )
        opai:SetChildActive('T3', false)
	
        opai = SeraphimM1NorthBase:AddNavalAI('M1_NavalDefense_ForwardWest' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M1_Seraph_MidPatrol_West' .. i .. '_Chain',
                },
                MaxFrigates = 20,
                MinFrigates = 20,
                Priority = 150,
            }
        )
        opai:SetChildActive('T3', false)
	end

end

function SeraphimM1MiddleBaseAI()

    -- -----------------------
    -- Seraphim M1 Middle Base
    -- -----------------------
    SeraphimM1NorthBase:AddExpansionBase('SeraphimM1MiddleBase', Difficulty)
    SeraphimM1MiddleBase:InitializeDifficultyTables(ArmyBrains[Seraphim], 'SeraphimM1MiddleBase', 'Seraphim_Middle_Base', 80, {M1_Seraph_Mid_Base = 100})
    SeraphimM1MiddleBase:SetEngineerCount({2,3,4})
end
