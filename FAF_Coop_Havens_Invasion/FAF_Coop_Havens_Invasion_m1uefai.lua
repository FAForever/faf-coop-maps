local BaseManager = import('/lua/ai/opai/basemanager.lua')
local SPAIFileName = '/lua/ScenarioPlatoonAI.lua'

---------
-- Locals
---------
local UEF = 2
local Difficulty = ScenarioInfo.Options.Difficulty

----------------
-- Base Managers
----------------
local UEFM1Base = BaseManager.CreateBaseManager()

--------------
-- UEF M1 Base
--------------
function UEFM1BaseAI()
    UEFM1Base:InitializeDifficultyTables(ArmyBrains[UEF], 'M1_UEF_Base', 'M1_UEF_Base_Marker', 40, {M1_Base = 100})
    UEFM1Base:StartNonZeroBase({{2, 3, 3}, {1, 2, 2}})

    UEFM1BaseLandAttacks()
    UEFM1BaseNavalAttacks()
end

function UEFM1BaseLandAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    quantity = {2, 3, 4}
    opai = UEFM1Base:AddOpAI('BasicLandAttack', 'M1_UEF_LandAttack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M1_UEF_Base_Land_Patrol_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('LightBots', quantity[Difficulty])

    quantity = {2, 3, 4}
    opai = UEFM1Base:AddOpAI('BasicLandAttack', 'M1_UEF_LandAttack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M1_UEF_Base_Land_Patrol_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('LightTanks', quantity[Difficulty])

    quantity = {2, 3, 4}
    opai = UEFM1Base:AddOpAI('BasicLandAttack', 'M1_UEF_LandAttack_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M1_UEF_Base_Land_Patrol_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('LightArtillery', quantity[Difficulty])
end

function UEFM1BaseNavalAttacks()
    local opai = nil
    local quantity = {}

    opai = UEFM1Base:AddOpAI('NavalAttacks', 'M1_UEF_NavalAttack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M1_UEF_Submarine_Patrol_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Submarines', 2)

    quantity = {1, 2, 2}
    opai = UEFM1Base:AddOpAI('NavalAttacks', 'M1_UEF_NavalAttack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M1_UEF_Submarine_Patrol_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Frigates', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/otherarmyunitcountbuildconditions.lua',
        'BrainsCompareNumCategory', {'default_brain', {'HumanPlayers'}, 1, categories.FACTORY, '>='})
end
