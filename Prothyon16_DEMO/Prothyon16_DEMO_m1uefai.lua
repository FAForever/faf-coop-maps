local BaseManager = import('/lua/ai/opai/basemanager.lua')

local SPAIFileName = '/lua/scenarioplatoonai.lua'

# ------
# Locals
# ------
local UEF = 2

# -------------
# Base Managers
# -------------
local UEFM1WestBase = BaseManager.CreateBaseManager()
local UEFM1EastBase = BaseManager.CreateBaseManager()

function UEFM1WestBaseAI()

    # ----------------
    # UEF M1 West Base
    # ----------------
    UEFM1WestBase:Initialize(ArmyBrains[UEF], 'M1_WestLand_Base', 'M1_West_Base_Marker', 40, {M1_WestBase = 100})
    UEFM1WestBase:StartNonZeroBase({{2,5,8}, {2, 3, 5}})
    UEFM1WestBase:SetActive('AirScouting', true)
    UEFM1WestBase:SetActive('LandScouting', true)
    UEFM1WestBase:SetBuild('Defenses', true)

    ForkThread(
        function()
            WaitSeconds(1)
            UEFM1WestBase:AddBuildGroup('M1_WestBaseExtended', 90, false)
        end
    )

    UEFM1WestBaseAirAttacks()
    UEFM1WestBaseLandAttacks()
end

function UEFM1WestBaseAirAttacks()
    local opai = nil

    # ------------------------------------
    # UEF M1 Land Base Op AI, Air Attacks
    # ------------------------------------

    # Builds platoon of 4 Bombers
    opai = UEFM1WestBase:AddOpAI('AirAttacks', 'M1_WestAirAttack1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M1_Land_Attack_Chain'
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Bombers', 4)

end

function UEFM1WestBaseLandAttacks()
    local opai = nil

    # ------------------------------------
    # UEF M1 Land Base Op AI, Land Attacks
    # ------------------------------------

    # Builds platoon of 8 LABs
    opai = UEFM1WestBase:AddOpAI('BasicLandAttack', 'M1_WestLandAttack1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M1_Land_Attack_Chain'
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity('LightBots', 8)

    # Builds platoon of 8 T1 Arties
    opai = UEFM1WestBase:AddOpAI('BasicLandAttack', 'M1_WestLandAttack2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M1_Land_Attack_Chain'
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity('LightArtillery', 8)

    # Builds platoon of 12 T1 Tanks
    opai = UEFM1WestBase:AddOpAI('BasicLandAttack', 'M1_WestLandAttack3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M1_Land_Attack_Chain'
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity('LightTanks', 12)

    # Builds Platoon of 1 Engineer 3 times
    local Temp = {
        'EngineerAttackTemp1',
        'NoPlan',
        { 'uel0105', 1, 4, 'Attack', 'GrowthFormation' },   # T1 Engies
    }
    local Builder = {
        BuilderName = 'EngineerAttackBuilder1',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 150,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'M1_WestLand_Base',
        PlatoonAIFunction = {SPAIFileName, 'RandomDefensePatrolThread'},       
        PlatoonData = {
            PatrolChain = 'M1_Land_Attack_Chain'
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

end

function UEFM1EastBaseAI()

    # ----------------
    # UEF M1 East Base
    # ----------------
    UEFM1EastBase:Initialize(ArmyBrains[UEF], 'M1_East_Base', 'M1_East_Base_Marker', 40, {M1_EastBase = 100})
    UEFM1EastBase:StartNonZeroBase({{2,5,12}, {2, 3, 7}})
    UEFM1EastBase:SetActive('AirScouting', true)
    UEFM1EastBase:SetActive('LandScouting', true)
    UEFM1EastBase:SetBuild('Defenses', true)

    ForkThread(
        function()
            WaitSeconds(1)
            UEFM1EastBase:AddBuildGroup('M1_EastBaseExtended', 90, false)
        end
    )

    UEFM1EastBaseAirAttacks()
    UEFM1EastBaseLandAttacks()

end

function UEFM1EastBaseAirAttacks()
    opai = nil

    # ----------------------------------
    # UEF M1 Air Base Op AI, Air Attacks
    # ----------------------------------

    # Builds platoon of 6 Bombers
    opai = UEFM1EastBase:AddOpAI('AirAttacks', 'M1_EastAirAttack1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_East_Attack_Chain1', 'M1_East_Attack_Chain2', 'M1_East_Attack_Chain3', 'M1_East_Attack_Chain4'},
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity('Bombers', 6)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', 20, categories.ALLUNITS * categories.MOBILE})

    # Builds platoon of 8 Bombers
    opai = UEFM1EastBase:AddOpAI('AirAttacks', 'M1_EastAirAttack2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_East_Attack_Chain1', 'M1_East_Attack_Chain2', 'M1_East_Attack_Chain3', 'M1_East_Attack_Chain4'},
            },
            Priority = 160,
        }
    )
    opai:SetChildQuantity('Bombers', 8)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', 30, categories.ALLUNITS * categories.MOBILE})

    # Builds platoon of 8 Interceptor when Player has 10+ air units
    opai = UEFM1EastBase:AddOpAI('AirAttacks', 'M1_EastAirAttack3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_East_Attack_Chain1', 'M1_East_Attack_Chain2', 'M1_East_Attack_Chain3', 'M1_East_Attack_Chain4'},
            },
            Priority = 150,
        }
    )
    opai:SetChildQuantity('Interceptors', 8)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', 10, categories.AIR * categories.MOBILE})

    # Builds platoon of 12 Interceptor when Player has 20+ air units
    opai = UEFM1EastBase:AddOpAI('AirAttacks', 'M1_EastAirAttack4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_East_Attack_Chain1', 'M1_East_Attack_Chain2', 'M1_East_Attack_Chain3', 'M1_East_Attack_Chain4'},
            },
            Priority = 160,
        }
    )
    opai:SetChildQuantity('Interceptors', 12)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', 20, categories.AIR * categories.MOBILE})

    # Air Defense
    # Maintains 12 Interceptors
    for i = 1, 3 do
        opai = UEFM1EastBase:AddOpAI('AirAttacks', 'M1_East_Base_AirDefense1_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M1_East_Base_Air_Defence_Chain',
                },
                Priority = 150,
            }
        )
        opai:SetChildQuantity({'Interceptors'}, 4)
    end

    # Air Defense
    # Maintains 8 Bombers
    for i = 1, 2 do
        opai = UEFM1EastBase:AddOpAI('AirAttacks', 'M1_East_Base_AirDefense2_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M1_East_Base_Air_Defence_Chain',
                },
                Priority = 150,
            }
        )
        opai:SetChildQuantity({'Bombers'}, 4)
    end

    # Air Defense
    # Maintains 8 Gunship
    for i = 1, 2 do
        opai = UEFM1EastBase:AddOpAI('AirAttacks', 'M1_East_Base_AirDefense3_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'M1_East_Base_Air_Defence_Chain',
                },
                Priority = 160,
            }
        )
        opai:SetChildQuantity({'Gunship'}, 4)
    end

end

function UEFM1EastBaseLandAttacks()
    local opai = nil

    # ------------------------------------
    # UEF M1 East Base Op AI, Land Attacks
    # ------------------------------------

    # Builds Platoon of 1 Engineers 8 times
    local Temp = {
        'EngineerAttackTemp2',
        'NoPlan',
        { 'uel0105', 1, 1, 'Attack', 'None' },   # T1 Engies
    }
    local Builder = {
        BuilderName = 'EngineerAttackBuilder2',
        PlatoonTemplate = Temp,
        InstanceCount = 8,
        Priority = 90,
        PlatoonType = 'Land',
        RequiresConstruction = true,
        LocationType = 'M1_East_Base',
        PlatoonAIFunction = {SPAIFileName, 'PatrolChainPickerThread'},       
        PlatoonData = {
            PatrolChains = {'M1_East_Attack_Chain1', 'M1_East_Attack_Chain2', 'M1_East_Attack_Chain3', 'M1_East_Attack_Chain4'},
        },
    }
    ArmyBrains[UEF]:PBMAddPlatoon( Builder )

    # Builds platoon of 8 T1 Arties
    opai = UEFM1EastBase:AddOpAI('BasicLandAttack', 'M1_EastLandAttack1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_East_Attack_Chain1', 'M1_East_Attack_Chain2', 'M1_East_Attack_Chain3', 'M1_East_Attack_Chain4'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('LightArtillery', 8)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', 20, categories.DIRECTFIRE + categories.INDIRECTFIRE})


    # Builds platoon of 12 T1 Tanks
    opai = UEFM1EastBase:AddOpAI('BasicLandAttack', 'M1_EastLandAttack2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_East_Attack_Chain1', 'M1_East_Attack_Chain2', 'M1_East_Attack_Chain3', 'M1_East_Attack_Chain4'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('LightTanks', 12)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', 12, categories.DIRECTFIRE + categories.INDIRECTFIRE})

    # Builds platoon of 4 T1 Tanks and 4 T1 Arties
    opai = UEFM1EastBase:AddOpAI('BasicLandAttack', 'M1_EastLandAttack3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_East_Attack_Chain1', 'M1_East_Attack_Chain2', 'M1_East_Attack_Chain3', 'M1_East_Attack_Chain4'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'LightTanks', 'LightArtillery'}, 8)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', 15, categories.DIRECTFIRE + categories.INDIRECTFIRE})

    # sends 16 [light tanks]
    opai = UEFM1EastBase:AddOpAI('BasicLandAttack', 'M1_EastLandAttack4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_East_Attack_Chain1', 'M1_East_Attack_Chain2', 'M1_East_Attack_Chain3', 'M1_East_Attack_Chain4'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('LightTanks', 16)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', 25, categories.DIRECTFIRE + categories.INDIRECTFIRE})

    # sends 12 [light artillery] if player has >= 20 units
    opai = UEFM1EastBase:AddOpAI('BasicLandAttack', 'M1_EastLandAttack5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_East_Attack_Chain1', 'M1_East_Attack_Chain2', 'M1_East_Attack_Chain3', 'M1_East_Attack_Chain4'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('LightArtillery', 12)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', 25, categories.ALLUNITS - categories.WALL})

    # sends 10 [mobile aa] if player has >= 6 planes
    opai = UEFM1EastBase:AddOpAI('BasicLandAttack', 'M1_EastLandAttack6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_East_Attack_Chain1', 'M1_East_Attack_Chain2', 'M1_East_Attack_Chain3', 'M1_East_Attack_Chain4'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('MobileAntiAir', 10)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', 6, categories.MOBILE * categories.AIR})

    # sends 16 [light tanks]
    opai = UEFM1EastBase:AddOpAI('BasicLandAttack', 'M1_EastLandAttack7',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_East_Attack_Chain1', 'M1_East_Attack_Chain2', 'M1_East_Attack_Chain3', 'M1_East_Attack_Chain4'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('LightTanks', 20)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', 28, categories.DIRECTFIRE + categories.INDIRECTFIRE})

    # sends 16 [light artillery] if player has >= 20 units
    opai = UEFM1EastBase:AddOpAI('BasicLandAttack', 'M1_EastLandAttack8',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_East_Attack_Chain1', 'M1_East_Attack_Chain2', 'M1_East_Attack_Chain3', 'M1_East_Attack_Chain4'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('LightArtillery', 16)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', 35, categories.ALLUNITS - categories.WALL})

    # sends 20 [light artillery, tanks] if player has >= 30 units
    opai = UEFM1EastBase:AddOpAI('BasicLandAttack', 'M1_EastLandAttack9',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_East_Attack_Chain1', 'M1_East_Attack_Chain2', 'M1_East_Attack_Chain3', 'M1_East_Attack_Chain4'},
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity({'LightArtillery', 'LightTanks'}, 20)
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua', 'BrainGreaterThanOrEqualNumCategory',
        {'default_brain', 'Player', 35, categories.ALLUNITS - categories.WALL})

    #-------------
    # Land Defense
    #-------------
    opai = UEFM1EastBase:AddOpAI('BasicLandAttack', 'M1_EastBase_Land_Defense1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_East_Defence_Chain1', 'M1_East_Defence_Chain2'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('LightTanks', 8)

    opai = UEFM1EastBase:AddOpAI('BasicLandAttack', 'M1_EastBase_Land_Defense2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_East_Defence_Chain1', 'M1_East_Defence_Chain2'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('MobileAntiAir', 12)

    opai = UEFM1EastBase:AddOpAI('BasicLandAttack', 'M1_EastBase_Land_Defense3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_East_Defence_Chain1', 'M1_East_Defence_Chain2'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('LightArtillery', 8)

    opai = UEFM1EastBase:AddOpAI('BasicLandAttack', 'M1_EastBase_Land_Defense4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {'M1_East_Defence_Chain1', 'M1_East_Defence_Chain2'},
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('LightTanks', 16)

end