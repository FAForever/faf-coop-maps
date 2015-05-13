-- ****************************************************************************
-- **
-- **  File     : '/maps/X1CA_Coop_004/X1CA_Coop_004_m2dostyaai.lua'
-- **  Author(s): Greg Van Houdt
-- **
-- **  Summary  : Dostya army AI for Mission 2 - X1CA_Coop_004
-- **
-- **  Copyright © 2007 Gas Powered Games, Inc.  All rights reserved.
-- **
-- ****************************************************************************
local BaseManager = import('/lua/ai/opai/basemanager.lua')

local SPAIFileName = '/lua/ScenarioPlatoonAI.lua'
local FileName = '/maps/X1CA_Coop_004/X1CA_Coop_004_m2dostyaai.lua'

local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')

--------
-- Locals
--------
local Dostya = 2
local Difficulty = ScenarioInfo.Options.Difficulty

---------------
-- Base Managers
---------------
local DostyaBase = BaseManager.CreateBaseManager()
local DostyaAirbase = BaseManager.CreateBaseManager()

function DostyaBaseAI()

-- ScenarioUtils.CreateArmyGroup('Dostya', 'M2_Dostya_Base_Defenders')

    DostyaBase:Initialize(ArmyBrains[Dostya], 'Dostya_Base', 'DostyaAttack', 65,
    {
        Dostya_Base = 100,
        Dostya_Wreckage = 90,
    }
    )
    DostyaBase:StartNonZeroBase({22, 18})

    -- DostyaExperimentals()
    DostyaAirAttacks()
    DostyaLandAttacks()

end

function DostyaAirbaseAI()

    DostyaAirbase:Initialize(ArmyBrains[Dostya], 'Dostya_Airbase', 'Dostya_Airbase_Marker', 25,
    {
        Dostya_Airbase = 100,
    }
    )
    DostyaAirbase:StartNonZeroBase({5, 4})
    DostyaAirbase:SetActive('AirScouting', true)

    DostyaAirbaseAttacks()

    DostyaAirbase:AddBuildGroup('Dostya_Airbase_AdditionalDefenses', 110)

end

function DostyaExperimentals()
    local opai = nil

    opai = DostyaBase:AddOpAI('Monkeylord_West',
        {
            Amount = 0,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'Dostya_NorthWest_Patrol_Chain',
            },
            MaxAssist = 2,
            Retry = true,
        }
    )

    opai = DostyaBase:AddOpAI('Monkeylord_East',
        {
            Amount = 0,
            KeepAlive = true,
            PlatoonAIFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'Dostya_NorthEast_Patrol_Chain',
            },
            MaxAssist = 2,
            Retry = true,
        }
    )

end

function DostyaAirAttacks()
    local opai = nil
    local quantity = {}

    ---------------------------
    -- Dostya Op AI, Air Attacks
    ---------------------------

    -- sends 24, 18, 12 [gunships, bombers]
    quantity = {24, 18, 12}
    opai = DostyaBase:AddOpAI('AirAttacks', 'Dostya_AirAttack1',
        {
            MasterPlatoonFunction = {FileName, 'DostyaAI'},
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'Gunships', 'Bombers'}, quantity[Difficulty])
    opai:SetLockingStyle('None')

    -- sends 12, 8, 6 [heavy gunships]
    quantity = {12, 8, 6}
    opai = DostyaBase:AddOpAI('AirAttacks', 'Dostya_AirAttack2',
        {
            MasterPlatoonFunction = {FileName, 'Dostya_HeavyGunships_AI'},
            Priority = 100,
        }
    )
    opai:SetChildQuantity('HeavyGunships', quantity[Difficulty])
    opai:SetLockingStyle('BuildTimer', {LockTimer = 90})

    -- sends 12 [air superiority]
    opai = DostyaBase:AddOpAI('AirAttacks', 'Dostya_AirAttack3',
        {
            MasterPlatoonFunction = {FileName, 'DostyaAI'},
            Priority = 105,
        }
    )
    opai:SetChildQuantity('AirSuperiority', 12)

    -- Air defense
    for i = 1, 3 do
        opai = DostyaBase:AddOpAI('AirAttacks', 'Dostya_Airdefense_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'DostyaPatrolChain'
                },
                Priority = 110,
            }
        )
        opai:SetChildQuantity('AirSuperiority', 6)
        opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumber', {'default_brain', 2})
    end

    for i = 4, 5 do
        opai = DostyaBase:AddOpAI('AirAttacks', 'Dostya_Airdefense_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
                PlatoonData = {
                    PatrolChain = 'DostyaPatrolChain'
                },
                Priority = 110,
            }
        )
        opai:SetChildQuantity('HeavyGunships', 6)
    end

    opai = DostyaBase:AddOpAI('AirAttacks', 'Dostya_Airdefense_6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'RandomDefensePatrolThread'},
            PlatoonData = {
                PatrolChain = 'DostyaPatrolChain'
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('AirSuperiority', 6)
    opai:AddBuildCondition('/lua/editor/miscbuildconditions.lua', 'MissionNumber', {'default_brain', 3})

end

function DostyaLandAttacks()
    local opai = nil
    local quantity = {}
    local count = {}

    ----------------------------
    -- Dostya Op AI, Land Attacks
    ----------------------------

    count = {2, 2, 1}
    -- sends [random - Heavy Bots - mobile heavy artillery]
    opai = DostyaBase:AddOpAI('BasicLandAttack', 'Dostya_LandAttack1',
        {
            MasterPlatoonFunction = {FileName, 'DostyaAI'},
            Priority = 100,
        }
    )
    opai:SetChildActive('HeavyBots', false)
    opai:SetChildActive('MobileHeavyArtillery', false)
    opai:SetChildCount(count[Difficulty])
    opai:SetLockingStyle('BuildTimer', {LockTimer = 71})

    -- sends [random - T3]
    opai = DostyaBase:AddOpAI('BasicLandAttack', 'Dostya_LandAttack2',
        {
            MasterPlatoonFunction = {FileName, 'DostyaAI'},
            Priority = 100,
        }
    )
    opai:SetChildActive('HeavyBots', false)
    opai:SetChildActive('MobileHeavyArtillery', false)
    opai:SetChildActive('SiegeBots', false)
    opai:SetChildCount(count[Difficulty])
    opai:SetLockingStyle('BuildTimer', {LockTimer = 62})

    -- sends 8, 6, 4 [heavy bots]
    quantity = {8, 6, 4}
    opai = DostyaBase:AddOpAI('BasicLandAttack', 'Dostya_LandAttack3',
        {
            MasterPlatoonFunction = {FileName, 'DostyaAI'},
            Priority = 105,
        }
    )
    opai:SetChildQuantity('HeavyBots', quantity[Difficulty])

    -- Land Defenses

    for i = 1, 3 do

        opai = DostyaBase:AddOpAI('BasicLandAttack', 'Dostya_LandDefense_NE_1_' .. i,
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'Dostya_NorthEast_Patrol_Chain',
                NoFormation = true,
            },
            Priority = 110,
        })
        opai:SetChildQuantity('HeavyBots', 3)
       ----------------------------------------
        opai = DostyaBase:AddOpAI('BasicLandAttack', 'Dostya_LandDefense_NE_2_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
        PlatoonData = {
            PatrolChain = 'Dostya_NorthEast_Patrol_Chain',
                    NoFormation = true,
        },
                Priority = 110,
            }
        )
        opai:SetChildQuantity('MobileFlak', 2)
       ----------------------------------------
        opai = DostyaBase:AddOpAI('BasicLandAttack', 'Dostya_LandDefense_NE_3_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
        PlatoonData = {
            PatrolChain = 'Dostya_NorthEast_Patrol_Chain',
                    NoFormation = true,
        },
                Priority = 109,
            }
        )
        opai:SetChildQuantity('MobileStealth', 1)
--   = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
        opai = DostyaBase:AddOpAI('BasicLandAttack', 'Dostya_LandDefense_NW_1_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
        PlatoonData = {
            PatrolChain = 'Dostya_NorthWest_Patrol_Chain',
                    NoFormation = true,
        },
                Priority = 110,
            }
        )
        opai:SetChildQuantity('HeavyBots', 3)
       ----------------------------------------
        opai = DostyaBase:AddOpAI('BasicLandAttack', 'Dostya_LandDefense_NW_2_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
        PlatoonData = {
            PatrolChain = 'Dostya_NorthWest_Patrol_Chain',
                    NoFormation = true,
        },
                Priority = 110,
            }
        )
        opai:SetChildQuantity('MobileFlak', 2)
       ----------------------------------------
        opai = DostyaBase:AddOpAI('BasicLandAttack', 'Dostya_LandDefense_NW_3_' .. i,
            {
                MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
        PlatoonData = {
            PatrolChain = 'Dostya_NorthWest_Patrol_Chain',
                    NoFormation = true,
        },
                Priority = 105,
            }
        )
        opai:SetChildQuantity('MobileStealth', 1)

    end
end

function DostyaAI(platoon)

    local aiBrain = platoon:GetBrain()
    local moveNum = false

    -- Switches attack chains based on mission number
    while(aiBrain:PlatoonExists(platoon)) do

        if(ScenarioInfo.MissionNumber == 2) then
            if(not moveNum) then
                moveNum = 1
                ScenarioFramework.PlatoonPatrolChain(platoon, 'M2_Dostya_AirAttack_' .. Random(1, 2) .. '_Chain')
            end

        elseif(ScenarioInfo.MissionNumber == 3) then
            if(not moveNum or moveNum ~= 2) then
                moveNum = 2
                IssueStop(platoon:GetPlatoonUnits())
                IssueClearCommands(platoon:GetPlatoonUnits())
                if(Random(1, 3) == 1) then
                    ScenarioFramework.PlatoonPatrolRoute(platoon, 'Dostya_M3_NorthAttackChain')
                else
                ScenarioFramework.PlatoonPatrolRoute(platoon, 'Dostya_M3_SouthAttackChain')
            end
            end
        end
        WaitSeconds(3)
    end
end

function Dostya_HeavyGunships_AI(platoon)
    local aiBrain = platoon:GetBrain()
    local cmd = false

    -- Switches attack chains based on mission number
    while(aiBrain:PlatoonExists(platoon)) do
        if(not cmd or not platoon:IsCommandsActive(cmd)) then

            if(ScenarioInfo.MissionNumber == 2) then
                cmd = ScenarioFramework.PlatoonPatrolChain(platoon, 'Dostya_M2_HeavyGunshipsChain')

            elseif(ScenarioInfo.MissionNumber == 3) then
                cmd = ScenarioFramework.PlatoonPatrolRoute(platoon, ScenarioPlatoonAI.GetRandomPatrolRoute(ScenarioUtils.ChainToPositions('M3_DostyaAirAttackChain')))
            end
        end
        WaitSeconds(11)
    end
end

---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----

function DostyaAirbaseAttacks()

    local opai = DostyaAirbase:AddOpAI('AirAttacks', 'Dostya_AirbaseAttack_1',
        {
            MasterPlatoonFunction = {FileName, 'DostyaAI'},
            Priority = 100,
        }
    )
    opai:SetChildQuantity({'Gunships', 'Bombers'}, 8)

    opai = DostyaAirbase:AddOpAI('AirAttacks', 'Dostya_AirbaseAttack_2',
        {
            MasterPlatoonFunction = {FileName, 'DostyaAI'},
            Priority = 110,
        }
    )
    opai:SetChildQuantity('HeavyGunships', 2)

    for i = 1, 2 do
        opai = DostyaAirbase:AddOpAI('AirAttacks', 'Dostya_AirbaseAttack_3' .. i,
            {
                MasterPlatoonFunction = {FileName, 'DostyaAI'},
                Priority = 110,
            }
        )
        opai:SetChildQuantity('Interceptors', 8)
    end
end


function DisableBase()
    if(true) then
        DostyaBase:BaseActive(false)
        DostyaAirbase:BaseActive(false)
    end
end
