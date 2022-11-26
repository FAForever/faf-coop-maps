local CustomFunctions = import('/maps/FAF_Coop_Novax_Station_Assault/FAF_Coop_Novax_Station_Assault_CustomFunctions.lua')
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local ThisFile = '/maps/FAF_Coop_Novax_Station_Assault/FAF_Coop_Novax_Station_Assault_m1orderai.lua'

---------
-- Locals
---------
local Order = 3
local Difficulty = ScenarioInfo.Options.Difficulty

----------
-- Carrier
----------
function OrderCarrierFactory()
    -- Adding build location for AI
    ArmyBrains[Order]:PBMAddBuildLocation('M1_Order_Carrier_Start_Marker', 150, 'AircraftCarrier1')

    local Carrier = ScenarioInfo.M1_Order_Carrier
    if not Carrier then
        return
    end

    for num, loc in ArmyBrains[Order].PBM.Locations do
        if loc.LocationType == 'AircraftCarrier1' then
            loc.PrimaryFactories.Air = Carrier
            OrderCarrierAttacks()
            break
        end
    end
    
    while ScenarioInfo.MissionNumber == 1 and not Carrier.Dead do
        if Carrier:IsIdleState() and Carrier:GetCargo()[1] then
            IssueClearCommands({Carrier})
            IssueTransportUnload({Carrier}, Carrier:GetPosition())
        end
        WaitSeconds(1)
    end
end

-- Platoons built by carrier
function OrderCarrierAttacks()
    local torpBomberNum = {5, 4, 3}
    local swiftWindNum = {6, 5, 4}
    local gunshipNum = {7, 6, 5}

    local Temp = {
        'M1_Order_Carrier_Air_Attack_1',
        'NoPlan',
        { 'uaa0204', 1, torpBomberNum[Difficulty], 'Attack', 'AttackFormation' }, -- T2 Torp Bomber
        { 'xaa0202', 1, swiftWindNum[Difficulty], 'Attack', 'AttackFormation' }, -- Swift Wind
        { 'uaa0203', 1, gunshipNum[Difficulty], 'Attack', 'AttackFormation' }, -- T2 Gunship
        { 'uaa0101', 1, 6, 'Attack', 'AttackFormation' }, -- T1 Scout
    }
    local Builder = {
        BuilderName = 'M1_Order_Carrier_Air_Builder_1',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 100,
        PlatoonType = 'Air',
        RequiresConstruction = true,
        LocationType = 'AircraftCarrier1',
        PlatoonAIFunction = {ThisFile, 'GivePlatoonToPlayer'},
        PlatoonData = {
            PatrolChain = 'M1_Oder_Naval_Def_Chain',
            FuelMultiplier = 4,
        },      
    }
    ArmyBrains[Order]:PBMAddPlatoon(Builder)
end

----------
-- Tempest
----------
function OrderTempestFactory()
    ArmyBrains[Order]:PBMAddBuildLocation('M1_Order_Tempest_Start_Marker', 150, 'Tempest1')

    for num, loc in ArmyBrains[Order].PBM.Locations do
        if loc.LocationType == 'Tempest1' then
            loc.PrimaryFactories.Sea = ScenarioInfo.M1_Order_Tempest
            OrderTempestAttacks()
            return
        end
    end
end

function OrderTempestAttacks()
    local Temp = {
        'M1_Order_Tempest_Naval_Attack_1',
        'NoPlan',
        { 'uas0201', 1, 1, 'Attack', 'AttackFormation' },  -- Destroyer
        { 'uas0103', 1, 3, 'Attack', 'AttackFormation' },  -- Frigate
        { 'uas0102', 1, 1, 'Attack', 'AttackFormation' },  -- AA Boat
        { 'uas0203', 1, 1, 'Attack', 'AttackFormation' },  -- Submarine
    }
    local Builder = {
        BuilderName = 'M1_Order_Tempest_Naval_Builder_1',
        PlatoonTemplate = Temp,
        InstanceCount = 1,
        Priority = 100,
        PlatoonType = 'Sea',
        RequiresConstruction = true,
        LocationType = 'Tempest1',
        PlatoonAIFunction = {ThisFile, 'MoveAndGivePlatoonToPlayer'},
        PlatoonData = {
            MoveRoute = {'Rally Point 05'},
            PatrolChain = 'M1_Oder_Naval_Def_Chain',
        },    
    }
    ArmyBrains[Order]:PBMAddPlatoon(Builder)
end

-----------------------
-- Platoon AI Functions
-----------------------
function GivePlatoonToPlayer(platoon)
    local givenUnits = {}
    local data = platoon.PlatoonData

    for _, unit in platoon:GetPlatoonUnits() do
        while (not unit.Dead and unit:IsUnitState('Attached')) do
            WaitSeconds(1)
        end
        local tempUnit
        if ScenarioInfo.UseOrderAI then
            tempUnit = ScenarioFramework.GiveUnitToArmy(unit, 'Player1')
        else
            tempUnit = ScenarioFramework.GiveUnitToArmy(unit, 'Player2')
        end
        table.insert(givenUnits, tempUnit)
    end

    if data.FuelMultiplier then
        CustomFunctions.UnitsMultiplyMaxFuel(givenUnits, data.FuelMultiplier)
    end

    if data.PatrolChain then
        ScenarioFramework.GroupPatrolChain(givenUnits, data.PatrolChain)
    end
end

function MoveAndGivePlatoonToPlayer(platoon)
    local givenUnits = {}
    local data = platoon.PlatoonData

    if not data then
        error('*MoveAndGivePlatoonToPlayer: PlatoonData not defined', 2)
    elseif not (data.MoveRoute or data.MoveChain) then
        error('*MoveAndGivePlatoonToPlayer: MoveToRoute or MoveChain not defined', 2)
    end

    local movePositions = {}
    if data.MoveChain then
        movePositions = ScenarioUtils.ChainToPositions(data.MoveChain)
    else
        for _, v in data.MoveRoute do
            if type(v) == 'string' then
                table.insert(movePositions, ScenarioUtils.MarkerToPosition(v))
            else
                table.insert(movePositions, v)
            end
        end
    end

    for _, v in movePositions do
        platoon:MoveToLocation(v, false)
    end

    WaitSeconds(1)

    for _, unit in platoon:GetPlatoonUnits() do
        while (not unit.Dead and unit:IsUnitState('Moving')) do
            WaitSeconds(1)
        end

        local tempUnit = ScenarioFramework.GiveUnitToArmy(unit, 'Player1')
        table.insert(givenUnits, tempUnit)
    end

    if data.PatrolChain then
        ScenarioFramework.GroupPatrolChain(givenUnits, data.PatrolChain)
    end
end