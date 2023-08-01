local BaseManager = import('/lua/ai/opai/basemanager.lua')
local OpScript = import('/maps/FAF_Coop_Operation_Tight_Spot/FAF_Coop_Operation_Tight_Spot_script.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')

local SPAIFileName = '/lua/ScenarioPlatoonAI.lua'
local ThisFile = '/maps/FAF_Coop_Operation_Tight_Spot/FAF_Coop_Operation_Tight_Spot_m3loyalistai.lua'

---------
-- Locals
---------
local Loyalist = 2
local Difficulty = ScenarioInfo.Options.Difficulty

----------------
-- Base Managers
----------------
local LoyalistM3MainBase = BaseManager.CreateBaseManager()
local LoyalistM3ProxyBase1 = BaseManager.CreateBaseManager()
local LoyalistM3ProxyBase2 = BaseManager.CreateBaseManager()

------------------------
-- Loyalist M3 Main Base
------------------------
function LoyalistM3MainBaseAI()
    LoyalistM3MainBase:InitializeDifficultyTables(ArmyBrains[Loyalist], 'M3_Loyalist_Base', 'M3_Loyalist_Base_Marker', 30, {M3_Loyalist_Base = 100})
    LoyalistM3MainBase:StartNonZeroBase({9, 6})

    LoyalistM3MainBase:SetActive('AirScouting', true)

    LoyalistM3MainBaseAirAttacks()
    LoyalistM3MainBaseLandAttacks()
    LoyalistM3MainBaseConditionalBuilds()
end

function LoyalistM3MainBaseAirAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    quantity = {4, 5, 6}
    opai = LoyalistM3MainBase:AddOpAI('AirAttacks', 'M3_Loyalist_To_QAI_M_AirAttack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M3_Loyalist_To_QAI_M_Land_Attack_Chain_1',
                    'M3_Loyalist_To_QAI_M_Land_Attack_Chain_2',
                },
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Bombers', quantity[Difficulty])
    opai:SetFormation('NoFormation')

    quantity = {5, 7, 9}
    opai = LoyalistM3MainBase:AddOpAI('AirAttacks', 'M3_Loyalist_To_QAI_M_AirAttack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M3_Loyalist_To_QAI_M_Land_Attack_Chain_1',
                    'M3_Loyalist_To_QAI_M_Land_Attack_Chain_2',
                },
            },
            Priority = 100,
        }
    )
    opai:SetChildQuantity('Interceptors', quantity[Difficulty])

    quantity = {4, 6, 9}
    opai = LoyalistM3MainBase:AddOpAI('AirAttacks', 'M3_Loyalist_To_QAI_M_AirAttack_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M3_Loyalist_To_QAI_M_Land_Attack_Chain_1',
                    'M3_Loyalist_To_QAI_M_Land_Attack_Chain_2',
                },
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('Gunships', quantity[Difficulty])

    quantity = {2, 4, 6}
    opai = LoyalistM3MainBase:AddOpAI('AirAttacks', 'M3_Loyalist_To_QAI_M_AirAttack_4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M3_Loyalist_To_QAI_M_Land_Attack_Chain_1',
                    'M3_Loyalist_To_QAI_M_Land_Attack_Chain_2',
                },
            },
            Priority = 110,
        }
    )
    opai:SetChildQuantity('CombatFighters', quantity[Difficulty])

    -------------------
    -- Assault platoons
    -------------------
    for i = 1, 3 do
        quantity = {12, 10, 9}
        opai = LoyalistM3MainBase:AddOpAI('AirAttacks', 'M3_Loyalist_Assault_Bombers_Platoon_' .. i,
            {
                MasterPlatoonFunction = {ThisFile, 'AddPlatoonToAttackManager'},
                PlatoonData = {
                    WaitThread = {SPAIFileName, 'RandomDefensePatrolThread'},
                    PatrolChain = 'M3_Loyalist_Base_Air_Patrol_Chain',
                },
                Priority = 230,
            }
        )
        opai:SetChildQuantity('Bombers', quantity[Difficulty])
    end

    for i = 1, 2 do
        quantity = {9, 7, 6}
        opai = LoyalistM3MainBase:AddOpAI('AirAttacks', 'M3_Loyalist_Assault_CombatFighters_Platoon_' .. i,
            {
                MasterPlatoonFunction = {ThisFile, 'AddPlatoonToAttackManager'},
                PlatoonData = {
                    WaitThread = {SPAIFileName, 'RandomDefensePatrolThread'},
                    PatrolChain = 'M3_Loyalist_Base_Air_Patrol_Chain',
                },
                Priority = 240,
            }
        )
        opai:SetChildQuantity('CombatFighters', quantity[Difficulty])

        quantity = {12, 10, 9}
        opai = LoyalistM3MainBase:AddOpAI('AirAttacks', 'M3_Loyalist_Assault_Gunships_Platoon_' .. i,
            {
                MasterPlatoonFunction = {ThisFile, 'AddPlatoonToAttackManager'},
                PlatoonData = {
                    WaitThread = {SPAIFileName, 'RandomDefensePatrolThread'},
                    PatrolChain = 'M3_Loyalist_Base_Air_Patrol_Chain',
                },
                Priority = 240,
            }
        )
        opai:SetChildQuantity('Gunships', quantity[Difficulty])

        quantity = {10, 8, 6}
        opai = LoyalistM3MainBase:AddOpAI('AirAttacks', 'M3_Loyalist_Assault_HeavyGunships_Platoon_' .. i,
            {
                MasterPlatoonFunction = {ThisFile, 'AddPlatoonToAttackManager'},
                PlatoonData = {
                    WaitThread = {SPAIFileName, 'RandomDefensePatrolThread'},
                    PatrolChain = 'M3_Loyalist_Base_Air_Patrol_Chain',
                },
                Priority = 250,
            }
        )
        opai:SetChildQuantity('HeavyGunships', quantity[Difficulty])

        quantity = {12, 10, 8}
        opai = LoyalistM3MainBase:AddOpAI('AirAttacks', 'M3_Loyalist_Assault_AirSuperiority_Platoon_' .. i,
            {
                MasterPlatoonFunction = {ThisFile, 'AddPlatoonToAttackManager'},
                PlatoonData = {
                    WaitThread = {SPAIFileName, 'RandomDefensePatrolThread'},
                    PatrolChain = 'M3_Loyalist_Base_Air_Patrol_Chain',
                },
                Priority = 250,
            }
        )
        opai:SetChildQuantity('AirSuperiority', quantity[Difficulty])
    end
    ----------
    -- Patrols
    ----------
    --M3_Loyalist_Base_Air_Patrol_Chain
end

function LoyalistM3MainBaseLandAttacks()
    local opai = nil
    local quantity = {}
    local trigger = {}

    -- Reclaiming Engineers
    quantity = {6, 5, 4}
    opai = LoyalistM3MainBase:AddOpAI('EngineerAttack', 'M3_Loyalist_Main_Reclaim_Engineers_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Loyalist_Base_EngineerChain',
            },
            Priority = 290,
        })
    opai:SetChildQuantity('T1Engineers', quantity[Difficulty])
    opai:SetFormation('NoFormation')

    quantity = {6, 5, 4}
    opai = LoyalistM3MainBase:AddOpAI('EngineerAttack', 'M3_Loyalist_Main_Reclaim_Engineers_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'SplitPatrolThread'},
            PlatoonData = {
                PatrolChains = {
                    'M3_Loyalist_To_QAI_M_Land_Attack_Chain_1',
                    'M3_Loyalist_To_QAI_M_Land_Attack_Chain_2',
                },
            },
            Priority = 280,
        })
    opai:SetChildQuantity('T1Engineers', quantity[Difficulty])
    opai:AddBuildCondition('/lua/editor/economybuildconditions.lua',
        'LessThanMassStorageCurrent', {5000})

    ----------------------------
    -- Attack to QAI's main base
    ----------------------------
    quantity = {6, 8, 10}
    opai = LoyalistM3MainBase:AddOpAI('BasicLandAttack', 'M3_Loyalist_To_QAI_M_LandAttack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M3_Loyalist_To_QAI_M_Land_Attack_Chain_1',
                    'M3_Loyalist_To_QAI_M_Land_Attack_Chain_2',
                },
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('HeavyTanks', quantity[Difficulty])

    quantity = {6, 6, 9}
    opai = LoyalistM3MainBase:AddOpAI('BasicLandAttack', 'M3_Loyalist_To_QAI_M_LandAttack_2',
        {
            MasterPlatoonFunction = {SPAIFileName, 'MoveToThread'},
            PlatoonData = {
                MoveChain = 'M3_Loyalist_To_QAI_M_Land_Attack_Chain_1',
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity({'SiegeBots', 'HeavyTanks', 'LightBots'}, quantity[Difficulty])

    quantity = {3, 4, 6}
    opai = LoyalistM3MainBase:AddOpAI('BasicLandAttack', 'M3_Loyalist_To_QAI_M_LandAttack_3',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M3_Loyalist_To_QAI_M_Land_Attack_Chain_1',
                    'M3_Loyalist_To_QAI_M_Land_Attack_Chain_2',
                },
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity('MobileMissiles', quantity[Difficulty])

    quantity = {6, 6, 9}
    opai = LoyalistM3MainBase:AddOpAI('BasicLandAttack', 'M3_Loyalist_To_QAI_M_LandAttack_4',
        {
            MasterPlatoonFunction = {SPAIFileName, 'MoveToThread'},
            PlatoonData = {
                MoveChain = 'M3_Loyalist_To_QAI_M_Land_Attack_Chain_1',
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity({'SiegeBots', 'MobileShields', 'LightBots'}, quantity[Difficulty])

    quantity = {9, 6, 6}
    opai = LoyalistM3MainBase:AddOpAI('BasicLandAttack', 'M3_Loyalist_To_QAI_M_LandAttack_5',
        {
            MasterPlatoonFunction = {SPAIFileName, 'MoveToThread'},
            PlatoonData = {
                MoveChain = 'M3_Loyalist_To_QAI_M_Land_Attack_Chain_2',
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity({'SiegeBots', 'HeavyTanks', 'LightTanks'}, quantity[Difficulty])

    quantity = {6, 6, 6}
    opai = LoyalistM3MainBase:AddOpAI('BasicLandAttack', 'M3_Loyalist_To_QAI_M_LandAttack_6',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolChainPickerThread'},
            PlatoonData = {
                PatrolChains = {
                    'M3_Loyalist_To_QAI_M_Land_Attack_Chain_1',
                    'M3_Loyalist_To_QAI_M_Land_Attack_Chain_2',
                },
            },
            Priority = 120,
        }
    )
    opai:SetChildQuantity({'HeavyTanks', 'LightTanks'}, quantity[Difficulty])

    -------------------
    -- Assault platoons
    -------------------
    for i = 1, 2 do
        quantity = {6, 6, 6}
        opai = LoyalistM3MainBase:AddOpAI('BasicLandAttack', 'M3_Loyalist_Assault_T2_AA_Platoon_1' .. i,
            {
                MasterPlatoonFunction = {ThisFile, 'AddPlatoonToAttackManager'},
                PlatoonData = {
                    WaitThread = {SPAIFileName, 'PatrolThread'},
                    PatrolChain = 'M3_Loyalist_Base_EngineerChain',
                },
                Priority = 220,
            }
        )
        opai:SetChildQuantity({'MobileFlak', 'MobileAntiAir'}, quantity[Difficulty])

        quantity = {5, 4, 3}
        opai = LoyalistM3MainBase:AddOpAI('BasicLandAttack', 'M3_Loyalist_Assault_T3_AA_Platoon_' .. i,
            {
                MasterPlatoonFunction = {ThisFile, 'AddPlatoonToAttackManager'},
                PlatoonData = {
                    WaitThread = {SPAIFileName, 'PatrolThread'},
                    PatrolChain = 'M3_Loyalist_Base_EngineerChain',
                },
                Priority = 230,
            }
        )
        opai:SetChildQuantity('HeavyMobileAntiAir', quantity[Difficulty])

        quantity = {5, 4, 3}
        opai = LoyalistM3MainBase:AddOpAI('BasicLandAttack', 'M3_Loyalist_Assault_Arty_Platoon_' .. i,
            {
                MasterPlatoonFunction = {ThisFile, 'AddPlatoonToAttackManager'},
                PlatoonData = {
                    WaitThread = {SPAIFileName, 'MoveToThread'},
                    MoveRoute = {'M3_Loyalist_Wait_Arty_' .. i},
                },
                Priority = 240,
            }
        )
        opai:SetChildQuantity('MobileHeavyArtillery', quantity[Difficulty])
        opai:SetFormation('AttackFormation')

        quantity = {5, 4, 3}
        opai = LoyalistM3MainBase:AddOpAI('BasicLandAttack', 'M3_Loyalist_Assault_Sniper_Platoon_' .. i,
            {
                MasterPlatoonFunction = {ThisFile, 'AddPlatoonToAttackManager'},
                PlatoonData = {
                    WaitThread = {SPAIFileName, 'MoveToThread'},
                    MoveRoute = {'M3_Loyalist_Wait_Snipers_' .. i},
                },
                Priority = 240,
            }
        )
        opai:SetChildQuantity('HeavyBots', quantity[Difficulty])
        opai:SetFormation('AttackFormation')
    end

    for i = 1, 3 do
        quantity = {10, 8, 6}
        opai = LoyalistM3MainBase:AddOpAI('BasicLandAttack', 'M3_Loyalist_Assault_Harbs_Platoon_' .. i,
            {
                MasterPlatoonFunction = {ThisFile, 'AddPlatoonToAttackManager'},
                PlatoonData = {
                    WaitThread = {SPAIFileName, 'PatrolThread'},
                    PatrolChain = 'M3_Loyalist_MainBase_GC_Chain',
                    UseMove = true,
                },
                Priority = 250,
            }
        )
        opai:SetChildQuantity('SiegeBots', quantity[Difficulty])
        opai:SetFormation('AttackFormation')
        opai:SetLockingStyle('DeathRatio', {Ratio = 0.5})
    end

    -- Attacks to QAI's experimental base
    quantity = {9, 9, 6}
    opai = LoyalistM3MainBase:AddOpAI('BasicLandAttack', 'M3_Loyalist_Assault_Experimental_LandAttack_1',
        {
            MasterPlatoonFunction = {SPAIFileName, 'MoveToThread'},
            PlatoonData = {
                MoveChain = 'M3_Loyalist_To_QAI_Experimental_Attack_Chain',
            },
            Priority = 300,
        }
    )
    opai:SetChildQuantity({'SiegeBots', 'HeavyTanks', 'LightTanks'}, quantity[Difficulty])
end

function LoyalistM3MainBaseConditionalBuilds()
    local opai = nil
    local quantity = {}

    opai = LoyalistM3MainBase:AddOpAI('GC',
        {
            Amount = 1,
            KeepAlive = false,
            PlatoonAIFunction = {ThisFile, 'AddPlatoonToAttackManager'},
            PlatoonData = {
                WaitThread = {SPAIFileName, 'PatrolThread'},
                PatrolChain = 'M3_Loyalist_MainBase_GC_Chain',
                PlatoonName = 'M3_Loyalist_Assault_GC_Platoon',
            },
            MaxAssist = 2,
            Retry = true,
        }
    )
end

--------------------------
-- Loyalist M3 Proxy Bases
--------------------------
function LoyalistM3ProxyBase1AI()
    LoyalistM3ProxyBase1:Initialize(ArmyBrains[Loyalist], 'M3_Loyalist_Proxy_Base_1', 'M3_Loyalist_Proxy_Base_1_Marker', 25, {Proxy_Base_1 = 100})
    LoyalistM3ProxyBase1:StartNonZeroBase({4, 2})

    LoyalistM3ProxyBase1AirAttacks()
    LoyalistM3ProxyBase1LandAttacks()
end

function LoyalistM3ProxyBase1AirAttacks()
    local opai = nil

    opai = LoyalistM3ProxyBase1:AddOpAI('AirAttacks', 'M3_Loyalist_ProxyBase_1_AirAttacks',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Loyalist_Proxy_Base_1_Attack_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetLockingStyle('None')
end

function LoyalistM3ProxyBase1LandAttacks()
    local opai = nil

    opai = LoyalistM3ProxyBase1:AddOpAI('BasicLandAttack', 'M3_Loyalist_ProxyBase_1_LandAttacks',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Loyalist_Proxy_Base_1_Attack_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetLockingStyle('None')
end

function LoyalistM3ProxyBase2AI()
    LoyalistM3ProxyBase2:Initialize(ArmyBrains[Loyalist], 'M3_Loyalist_Proxy_Base_2', 'M3_Loyalist_Proxy_Base_2_Marker', 20, {Proxy_Base_2 = 100})
    LoyalistM3ProxyBase2:StartNonZeroBase(2)

    LoyalistM3ProxyBase2LandAttacks()
end

function LoyalistM3ProxyBase2LandAttacks()
    local opai = nil

    opai = LoyalistM3ProxyBase2:AddOpAI('BasicLandAttack', 'M3_Loyalist_ProxyBase_2_LandAttacks',
        {
            MasterPlatoonFunction = {SPAIFileName, 'PatrolThread'},
            PlatoonData = {
                PatrolChain = 'M3_Loyalist_Proxy_Base_2_Attack_Chain',
            },
            Priority = 100,
        }
    )
    opai:SetLockingStyle('None')
end

--------------------------
-- Loyalist Attack Manager
--------------------------
OpBaseAttackManager = ClassSimple {
    AssaultStarted = false,
    ReadyToAttack = false,
    TargetPosition = false,

    Platoons = {},

    AddPlatoon = function(self, platoon)
        table.insert(self.Platoons, platoon)

        platoon:AddDestroyCallback(RemovePlatoonFromAttackManager)
        --LOG('*DEBUG: OpBaseAttackManager: Adding platoon named: ' .. (platoon.PlatoonData.PlatoonName or '"Unknown platoon name"'))
        --LOG('*DEBUG: OpBaseAttackManager: current count of platoon: '.. self:GetPlatoonCount())

        self:AssignOrderToPlatoon(platoon)

        if not self.ReadyToAttack then
            self:CheckAssaultCondition()
        end
    end,

    RemovePlatoon = function(self, platoon)
        table.removeByValue(self.Platoons, platoon)

        --LOG('*DEBUG: OpBaseAttackManager: Removing platoon named: ' .. (platoon.PlatoonData.PlatoonName or '"Unknown platoon name"'))
        --LOG('*DEBUG: OpBaseAttackManager: current count of platoon: '.. self:GetPlatoonCount())
    end,

    GetPlatoonCount = function(self)
        return table.getn(self.Platoons)
    end,

    SetTarget = function(self, newTarget)
        if not self.AssaultStarted then
            self.AssaultStarted = true
        end

        if not self.TargetPosition or VDist3(self.TargetPosition, newTarget) > 10 then
            self.TargetPosition = newTarget

            --LOG('*DEBUG: OpBaseAttackManager: New target position set: ' .. repr(self.TargetPosition))
            self:ChangePlatoonsOrders()
        else
            --LOG('*DEBUG: OpBaseAttackManager new target position: ' .. repr(newTarget) .. ' is too close the the current one.')
        end
    end,

    AssignOrderToPlatoon = function(self, platoon)
        local data = platoon.PlatoonData
        -- Do default stuff before attack
        if not self.AssaultStarted then
            if data.WaitThread then
                --LOG('*DEBUG: OpBaseAttackManager: Platoon wait thread: ' .. data.WaitThread[2])
                import(data.WaitThread[1])[data.WaitThread[2]](platoon)
            end
        else 
            -- Attack the position that player marked
            --LOG('*DEBUG: OpBaseAttackManager: Attacking new position with platoon: ' .. (platoon.PlatoonData.PlatoonName or '"Unknown platoon name"'))

            platoon:Stop()
            -- Gotta cover stupid harbs doing everything else than attacking.
            if data.UseMove then
                platoon:MoveToLocation(self.TargetPosition, false)
            else
                platoon:AggressiveMoveToLocation(self.TargetPosition)
            end
        end
    end,

    ChangePlatoonsOrders = function(self)
        for _, platoon in self.Platoons do
            self:AssignOrderToPlatoon(platoon)
        end
    end,

    CheckAssaultCondition = function(self)
        if self:GetPlatoonCount() > ScenarioInfo.M3NumLoyalistPlatoonNeeded then
            --LOG('*DEBUG: OpBaseAttackManager is ready to attack.')
            self.ReadyToAttack = true
            OpScript.M3SetUpAttackPing()
        end
    end,
}

local LoyalistAttackManager = OpBaseAttackManager()

-- Attack the target based picked by the players
function AddPlatoonToAttackManager(platoon)
    LoyalistAttackManager:AddPlatoon(platoon)
end

function RemovePlatoonFromAttackManager(brain, platoon)
    LoyalistAttackManager:RemovePlatoon(platoon)
end

function SetNewTarget(newTarget)
    LoyalistAttackManager:SetTarget(newTarget)
end
