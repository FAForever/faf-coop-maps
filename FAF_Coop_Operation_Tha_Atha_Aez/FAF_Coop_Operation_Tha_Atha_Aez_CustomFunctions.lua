local ScenarioUtils = import("/lua/sim/scenarioutilities.lua")
local ScenarioFramework = import("/lua/scenarioframework.lua")
local ScenarioPlatoonAI = import("/lua/scenarioplatoonAI.lua")
local NavUtils = import("/lua/sim/navutils.lua")
local AIUtils = import("/lua/ai/aiutilities.lua")
local AIAttackUtils = import("/lua/ai/aiattackutilities.lua")
local AIBehaviors = import("/lua/ai/aibehaviors.lua")

ScenarioInfo.Player1 = 1
ScenarioInfo.SeraphimAlly = 2
ScenarioInfo.UEF = 3
ScenarioInfo.Aeon = 4
ScenarioInfo.WarpComs = 5
ScenarioInfo.SeraphimAlly2 = 6
ScenarioInfo.Player2 = 7
ScenarioInfo.Player3 = 8
ScenarioInfo.Player4 = 9

local Difficulty = ScenarioInfo.Options.Difficulty

------------------------------------------------------------------
--  MoveChainPickerThread
--      Gives a platoon a random move chain from a set of chains
--  PlatoonData
--      MoveChains - List of chains to choose from
--  function: MoveChainPickerThread = AddFunction
--      parameter 0: string: platoon = "default_platoon"
------------------------------------------------------------------
function MoveChainPickerThread(platoon)
    local data = platoon.PlatoonData
    platoon:Stop()
    if data then
        if data.MoveChains then
            local chain = Random(1, table.getn(data.MoveChains))
            ScenarioFramework.PlatoonMoveRoute(platoon, ScenarioUtils.ChainToPositions(data.MoveChains[chain]))
        else
            error('*SCENARIO PLATOON AI ERROR: MoveChains not defined', 2)
        end
    else
        error('*SCENARIO PLATOON AI ERROR: PlatoonData not defined', 2)
    end
end

function PlatoonAttackClosestPriorityUnit(platoon)
    local aiBrain = platoon:GetBrain()
    local target

    while not target do
        target = platoon:FindClosestUnit('Attack', 'Enemy', true, categories.url0401 + categories.xab1401 + categories.ueb2401 + categories.xab2307)
        WaitSeconds(3)
    end
    platoon:Stop()

    local cmd = platoon:AggressiveMoveToLocation(target:GetPosition())
    while aiBrain:PlatoonExists(platoon) do
        if target ~= nil then
            if target.Dead or not platoon:IsCommandsActive(cmd) then
                target = platoon:FindClosestUnit('Attack', 'Enemy', true, categories.TECH3 * categories.MOBILE * categories.NAVAL)
                if target and not target.Dead then
                    platoon:Stop()
                    cmd = platoon:AggressiveMoveToLocation(target:GetPosition())
                end
            end
        else
            target = platoon:FindClosestUnit('Attack', 'Enemy', true, categories.TECH2 * categories.MOBILE * categories.NAVAL)
        end
        WaitSeconds(17)
    end
end

--- Merges units produced by the Base Manager conditional build into the same platoon.
-- PlatoonData = {
--     Name - String, unique name for this platoon
--     NumRequired - Number of experimentals to start moving the platoon
--     PatrolChain - Name of the chain to use
-- }
function AddExperimentalToPlatoon(platoon)
    local brain = platoon:GetBrain()
    local data = platoon.PlatoonData
    local name = data.Name
    local unit = platoon:GetPlatoonUnits()[1]
    local plat = brain:GetPlatoonUniquelyNamed(name)
    local spawnThread = false

    if not plat then
        plat = brain:MakePlatoon('', '')
        plat:UniquelyNamePlatoon(name)
        plat:SetPlatoonData(data)
        spawnThread = true
    end

    brain:AssignUnitsToPlatoon(plat, {unit}, 'Attack', 'AttackFormation')
    brain:DisbandPlatoon(platoon)

    if spawnThread then
        ForkThread(MultipleExperimentalsThread, plat)
    end
end

--- Handles an unique platoon of multiple experimentals.
function MultipleExperimentalsThread(platoon)
    local brain = platoon:GetBrain()
    local data = platoon.PlatoonData

    while brain:PlatoonExists(platoon) do
        if not platoon:IsPatrolling('Attack') then
            local numAlive = 0
            for _, v in platoon:GetPlatoonUnits() do
                if not v.Dead then
                    numAlive = numAlive + 1
                end
            end

            if numAlive == data.NumRequired then
                for _, v in ScenarioUtils.ChainToPositions(data.PatrolChain) do
                    platoon:Patrol(v)
                end
            end
        end
        WaitSeconds(10)
    end
end

function PlatoonAttackWithTransports( platoon, landingChain, attackChain, deleteMarker, instant )
    ForkThread( PlatoonAttackWithTransportsThread, platoon, landingChain, attackChain, deleteMarker, instant )
end

function PlatoonAttackWithTransportsThread( platoon, landingChain, attackChain, deleteMarker, instant, moveChain )
    local aiBrain = platoon:GetBrain()
    local allUnits = platoon:GetPlatoonUnits()
    local startPos = platoon:GetPlatoonPosition()
    local units = {}
    local transports = {}
    for k,v in allUnits do
        if EntityCategoryContains( categories.TRANSPORTATION, v ) then
            table.insert( transports, v )
        else
            table.insert( units, v )
        end
    end

    local landingLocs = ScenarioUtils.ChainToPositions( landingChain )
    local landingLocation = landingLocs[Random(1,table.getn(landingLocs))]

    if instant then
        ScenarioFramework.AttachUnitsToTransports( units, transports )
        if moveChain and not ScenarioPlatoonAI.MoveAlongRoute(platoon, ScenarioUtils.ChainToPositions(moveChain)) then
            return
        end
        IssueTransportUnload( transports, landingLocation )
        local attached = true
        while attached do
            WaitSeconds(3)
            local allDead = true
            for k,v in transports do
                if not v.Dead then
                    allDead = false
                    break
                end
            end
            if allDead then
                return
            end
            attached = false
            for num, unit in units do
                if not unit.Dead and unit:IsUnitState('Attached') then
                    attached = true
                    break
                end
            end
        end
    else
        if not import('/lua/ai/aiutilities.lua').UseTransports( units, transports, landingLocation ) then
            return
        end
    end

    local platoon = aiBrain:MakePlatoon('','')
            for _, unit in units do
                while (not unit.Dead and unit:IsUnitState('Attached')) do
                    WaitSeconds(.5)
                end
                
                if (unit and not unit.Dead) then
                    aiBrain:AssignUnitsToPlatoon(platoon, {unit}, 'Attack', 'GrowthFormation')
                end
            end
            ScenarioFramework.PlatoonPatrolChain(platoon, attackChain)


    IssueMove(transports, ScenarioUtils.MarkerToPosition(deleteMarker))

    for _, transport in transports do
        ScenarioFramework.CreateUnitToMarkerDistanceTrigger(DestroyUnit, transport, deleteMarker, 15)
    end
end

function DestroyUnit(unit)
    unit:Destroy()
end

function AssistNavalFactories(platoon)
    local data = platoon.PlatoonData
    local aiBrain = platoon:GetBrain()
    local bManager = aiBrain.BaseManagers[data.BaseName]

    if not data.Factories then
        error('*CUSTOM FUNCTIONS AI ERROR: categories of factories to assist not defined', 2)
    end

    -- local factories = bManager:GetAllBaseFactories(data.Factories)
    local factories = aiBrain:GetListOfUnits(data.Factories, false)

    platoon:Stop()
    local num = 1
    for _, unit in platoon:GetPlatoonUnits() do
        local factory = factories[num]
        if not factory then
            factory = factories[1]
            num = 1
        end
        IssueGuard({unit}, factory)--factories[math.mod(i, 2) + 1])
        num = num + 1
    end
end

-------------------
-- Build Conditions
-------------------

--- Build condition used to determine if we have transports to ferry land units
---@param aiBrain AIBrain
---@param numReq number
---@param platoonName string
---@return boolean
function HaveGreaterOrEqualThanUnitsInTransportPool(aiBrain, numReq, platoonName)
    -- Get either the specific transport platoon, or the universal 'TransportPool' platoon
    local platoon = aiBrain:GetPlatoonUniquelyNamed(platoonName) or aiBrain:GetPlatoonUniquelyNamed('TransportPool')
    
    -- In this case we need the platoon to exist, and have enough units to return true
    return platoon and table.getn(platoon:GetPlatoonUnits()) >= numReq
end

--- Build condition used to determine if need transports to be built
---@param aiBrain AIBrain
---@param numReq number
---@param platoonName string
---@return boolean
function HaveLessThanUnitsInTransportPool(aiBrain, numReq, platoonName)
    -- Get either the specific transport platoon, or the universal 'TransportPool' platoon
    local platoon = aiBrain:GetPlatoonUniquelyNamed(platoonName) or aiBrain:GetPlatoonUniquelyNamed('TransportPool')
    
    -- If neither exists, we need to build transports, return true
    if not platoon then
        return true
    end
    
    return table.getn(platoon:GetPlatoonUnits()) < numReq
end


-------------------------------
-- Modified Transport Functions
-------------------------------

--- Transfers the platoon's units to the 'TransportPool' platoon, or the specified one if BaseName platoon data is given
--- NOTE: Transports are assigned to the land platoon we want to transport, once their commands have been executed, they are reassigned to their original transport pool
--- - TransportMoveLocation - Location to move transport to before assigning to transport pool
--- - MoveRoute - List of locations to move to
--- - MoveChain - Chain of locations to move
---@param platoon Platoon
function TransportPool(platoon)
    local aiBrain = platoon:GetBrain()
    local data = platoon.PlatoonData
    
    -- Default transport platoon to grab from
    local poolName = 'TransportPool'
    local BaseName = data.BaseName
    
    -- If base name is specified in platoon data, use that instead
    if BaseName then 
        poolName = BaseName .. '_TransportPool'
    end
    
    local tPool = aiBrain:GetPlatoonUniquelyNamed(poolName)
    if not tPool then
        tPool = aiBrain:MakePlatoon('', '')
        tPool:UniquelyNamePlatoon(poolName)
    end
    
    if data.TransportMoveLocation then
        if type(data.TransportMoveLocation) == 'string' then
            data.MoveRoute = {ScenarioUtils.MarkerToPosition(data.TransportMoveLocation)}
        else
            data.MoveRoute = {data.TransportMoveLocation}
        end
    end
    
    -- Move the transports along desired route
    if data.MoveRoute then
        ScenarioFramework.PlatoonMoveRoute(platoon, data.MoveRoute)
    elseif data.MoveChain then
        ScenarioFramework.PlatoonMoveChain(platoon, data.MoveChain)
    end

    aiBrain:AssignUnitsToPlatoon(tPool, platoon:GetPlatoonUnits(), 'Scout', 'GrowthFormation')
end

--- Grabs a specific number of transports from the transports pool and loads units into the transport. Once ready a scenario variable can be set. Can wait on another scenario variable. Attempts to land at the location with the least threat and uses the accompanying attack chain for the units that have landed.
--- - LandingList     - (REQUIRED or LandingChain) List of possible locations for transports to unload units
--- - LandingChain    - (REQUIRED or LandingList) Chain of possible landing locations
--- - GenerateSafePath - Bool if you want the transports to dynamically generate a safe path to a safe landing location.
--- - TransportReturn - Location for transports to return to (they will attack with land units if this isn't set)
--- - AttackPoints    - (REQUIRED or AttackChain or PatrolChain) List of locations to attack. The platoon attacks the highest threat first
--- - AttackChain     - (REQUIRED or AttackPoints or PatrolChain) Marker Chain of postitions to attack
--- - PatrolChain     - (REQUIRED or AttackChain or AttackPoints) Chain of patrolling
--- - RandomPatrol    - Bool if you want the patrol things to be random rather than in order
---@param platoon Platoon
function LandAssaultWithTransports(platoon)
    local aiBrain = platoon:GetBrain()
    local data = platoon.PlatoonData
    local cmd

    if not data.AttackPoints and not data.AttackChain and not data.AttackChains then
        error('*CUSTOM PLATOON AI ERROR: LandAssaultWithTransports requires AttackPoints in PlatoonData to operate', 2)
    elseif not data.LandingList and not data.LandingChain then
        error('*CUSTOM PLATOON AI ERROR: LandAssaultWithTransports requires LandingList in PlatoonData to operate', 2)
    end

    -- Pick a random attack and landing chain from AttackChains
    -- Only used if no AttackPoints/AttackChain data, or LandingList/LandingChain data are defined
    local assaultAttackChain, assaultLandingChain
    if data.AttackChains then
        local tempChains = {}
        local tempNum = 0
        for landingChain, attackChain in data.AttackChains do
            for num, pos in ScenarioUtils.ChainToPositions(attackChain) do
                if aiBrain:GetThreatAtPosition(pos, 1, true) > 0 then
                    tempChains[landingChain] = attackChain
                    tempNum = tempNum + 1
                    break
                end
            end
        end
        
        local pickNum = Random(1, tempNum)
        tempNum = 0
        for landingChain, attackChain in tempChains do
            tempNum = tempNum + 1
            if tempNum == pickNum then
                assaultAttackChain = attackChain
                assaultLandingChain = landingChain
                break
            end
        end
    end

    -- Make attack positions out of chain, markers, or marker names
    local attackPositions = {}
    if data.AttackChain then
        attackPositions = ScenarioUtils.ChainToPositions(data.AttackChain)
    elseif assaultAttackChain then
        attackPositions = ScenarioUtils.ChainToPositions(assaultAttackChain)
    else
        for _, v in data.AttackPoints do
            if type(v) == 'string' then
                table.insert(attackPositions, ScenarioUtils.MarkerToPosition(v))
            else
                table.insert(attackPositions, v)
            end
        end
    end

    -- Make landing positions out of chain, markers, or marker names
    local landingPositions = {}
    if data.LandingChain then
        landingPositions = ScenarioUtils.ChainToPositions(data.LandingChain)
    elseif assaultLandingChain then
        landingPositions = ScenarioUtils.ChainToPositions(assaultLandingChain)
    else
        for _, v in data.LandingList do
            if type(v) == 'string' then
                table.insert(landingPositions, ScenarioUtils.MarkerToPosition(v))
            else
                table.insert(landingPositions, v)
            end
        end
    end
    platoon:Stop()

    -- Load transports
    if not GetLoadTransports(platoon) then
        return
    end
    
    -- Find safest landing location, and path to targets, update them every 10 or so seconds until we are close enough to our final landing location
    local landingLocation = BrainChooseLowestThreatLocation(aiBrain, landingPositions, 1, 'AntiAir')
    local PlatoonPosition = platoon:GetPlatoonPosition()
    
    -- Make sure we actually still have transports in our platoon
    while VDist2(PlatoonPosition[1], PlatoonPosition[3], landingLocation[1], landingLocation[3]) > 105 and not table.empty(platoon:GetSquadUnits('Scout')) do
        -- Update landing location at the start of the loop, otherwise the platoon might pick a different landing zone at the very last second.
        -- This can result in retarded behaviour, and we want to avoid that, if we are about to unload in 1 second, then UNLOAD, and not get yeeted because we just got a completely fresh set of commands
        landingLocation = BrainChooseLowestThreatLocation(aiBrain, landingPositions, 1, 'AntiAir')
        
        platoon:Stop()
    
        -- Transports get the 'Scout' role, if other units got it as well, you damn well better change it to something else
        local threatMax = 10
        local transportNum = table.getn(platoon:GetSquadUnits('Scout'))
            
        if transportNum > 0 then
            threatMax = transportNum * 10
        end
            
        -- Generate a safe path
        local safePath = NavUtils.PathToWithThreatThreshold('Air', PlatoonPosition, landingLocation, aiBrain, NavUtils.ThreatFunctions.AntiAir, threatMax, aiBrain.IMAPConfig.Rings)
        
        if safePath then
            ScenarioFramework.PlatoonMoveRoute(platoon, safePath)
        end
    
        -- Unload platoon at landing location
        cmd = platoon:UnloadAllAtLocation(landingLocation)
        
        WaitSeconds(10)
        
        if not aiBrain:PlatoonExists(platoon) then
            return
        end
        
        -- Update platoon position
        PlatoonPosition = platoon:GetPlatoonPosition()
        
        -- If we are surrounded by too much air threat, then fuck it, make a run for our last landing position
        if aiBrain:GetThreatAtPosition(platoon:GetPlatoonPosition(), 1, true, 'AntiAir') > threatMax  then
            platoon:Stop()
            cmd = platoon:UnloadAllAtLocation(landingLocation)
            break
        end
    end
    
    -- If we are already close enough to our destination, just unload
    if not cmd then
        cmd = platoon:UnloadAllAtLocation(landingLocation)
    end
    
    -- Wait until the units are dropped
    while platoon:IsCommandsActive(cmd) do
        WaitSeconds(1)
        if not aiBrain:PlatoonExists(platoon) then
            return
        end
    end

    -- Send transports back to base if desired, otherwise stay with the land platoon
    if data.TransportReturn then
        ReturnTransportsToPool(platoon, data)
    end

    if data.PatrolChain then
        if data.RandomPatrol then
            ScenarioFramework.PlatoonPatrolRoute(platoon, GetRandomPatrolRoute(ScenarioUtils.ChainToPositions(data.PatrolChain)))
        else
            ScenarioFramework.PlatoonPatrolChain(platoon, data.PatrolChain)
        end
    else
        -- Patrol attack route by creating attack route starting with the highest threat position
        local attackRoute = BrainChooseHighestAttackRoute(aiBrain, attackPositions, 1, 'AntiSurface')
        ScenarioFramework.PlatoonPatrolRoute(platoon, attackRoute)
    end
    
    -- If an Engineer unit is part of the platoon, use it's CaptureAI plan instead
    for num, unit in platoon:GetPlatoonUnits() do
        if EntityCategoryContains(categories.ENGINEER, unit) then
            platoon:CaptureAI()
            break
        end
    end
end

--- Utility Function
--- Get and load transports with platoon units
---@param platoon Platoon
---@return boolean
function GetLoadTransports(platoon)
    local numTransports = GetTransportsThread(platoon)
    
    if not numTransports then
        return false
    end

    platoon:Stop()
    local aiBrain = platoon:GetBrain()

    -- Load transports
    local transportTable = {}
    local transSlotTable = {}

    local scoutUnits = platoon:GetSquadUnits('Scout') or {}

    for num, unit in scoutUnits do
        local id = unit.UnitId
        if not transSlotTable[id] then
            transSlotTable[id] = GetNumTransportSlots(unit)
        end
        table.insert(transportTable,
            {
                Transport = unit,
                LargeSlots = transSlotTable[id].Large,
                MediumSlots = transSlotTable[id].Medium,
                SmallSlots = transSlotTable[id].Small,
                Units = {}
            }
       )
    end
    local shields = {}
    local remainingSize3 = {}
    local remainingSize2 = {}
    local remainingSize1 = {}
    for num, unit in platoon:GetPlatoonUnits() do
        if EntityCategoryContains(categories.url0306 + categories.DEFENSE, unit) then
            table.insert(shields, unit)
        elseif unit.Blueprint.Transport.TransportClass == 3 then
            table.insert(remainingSize3, unit)
        elseif unit.Blueprint.Transport.TransportClass == 2 then
            table.insert(remainingSize2, unit)
        elseif unit.Blueprint.Transport.TransportClass == 1 then
            table.insert(remainingSize1, unit)
        elseif not EntityCategoryContains(categories.TRANSPORTATION, unit) then
            table.insert(remainingSize1, unit)
        end
    end

    local needed = GetNumTransports(platoon)
    local largeHave = 0
    for num, data in transportTable do
        largeHave = largeHave + data.LargeSlots
    end
    local leftoverUnits = {}
    local currLeftovers = {}
    local leftoverShields = {}
    transportTable, leftoverShields = SortUnitsOnTransports(transportTable, shields, largeHave - needed.Large)
    transportTable, leftoverUnits = SortUnitsOnTransports(transportTable, remainingSize3, -1)
    transportTable, currLeftovers = SortUnitsOnTransports(transportTable, leftoverShields, -1)
    for _, v in currLeftovers do table.insert(leftoverUnits, v) end
    transportTable, currLeftovers = SortUnitsOnTransports(transportTable, remainingSize2, -1)
    for _, v in currLeftovers do table.insert(leftoverUnits, v) end
    transportTable, currLeftovers = SortUnitsOnTransports(transportTable, remainingSize1, -1)
    for _, v in currLeftovers do table.insert(leftoverUnits, v) end
    transportTable, currLeftovers = SortUnitsOnTransports(transportTable, currLeftovers, -1)
    
    -- Self-destruct any leftovers
    for k, v in currLeftovers do
        if not v.Dead then
            v:Kill()
        end
    end

    -- Old load transports
    local unitsToDrop = {}
    for num, data in transportTable do
        if not table.empty(data.Units) then
            IssueClearCommands(data.Units)
            IssueTransportLoad(data.Units, data.Transport)
            for _, v in data.Units do table.insert(unitsToDrop, v) end
        end
    end

    local attached = true
    repeat
        WaitSeconds(2)
        if not aiBrain:PlatoonExists(platoon) then
            return false
        end
        attached = true
        for _, v in unitsToDrop do
            if not v.Dead and not v:IsIdleState() then
                attached = false
                break
            end
        end
    until attached
    
    -- Self-destruct any leftovers
    for _, unit in unitsToDrop do
        if not unit.Dead and not unit:IsUnitState('Attached') then
            unit:Kill()
        end
    end

    return true
end

--- Utility function
--- Sorts units onto transports distributing equally
---@generic T : table
---@param transportTable T
---@param unitTable Unit[]
---@param numSlots? number defaults to 1
---@return T transportTable
---@return Unit[] unitsLeft
function SortUnitsOnTransports(transportTable, unitTable, numSlots)
    local leftoverUnits = {}
    numSlots = numSlots or -1
    for num, unit in unitTable do
        if numSlots == -1 or num <= numSlots then
            local transSlotNum = 0
            local remainingLarge = 0
            local remainingMed = 0
            local remainingSml = 0
            for tNum, tData in transportTable do
                if tData.LargeSlots > remainingLarge then
                    transSlotNum = tNum
                    remainingLarge = tData.LargeSlots
                    remainingMed = tData.MediumSlots
                    remainingSml = tData.SmallSlots
                elseif tData.LargeSlots == remainingLarge and tData.MediumSlots > remainingMed then
                    transSlotNum = tNum
                    remainingLarge = tData.LargeSlots
                    remainingMed = tData.MediumSlots
                    remainingSml = tData.SmallSlots
                elseif tData.LargeSlots == remainingLarge and tData.MediumSlots == remainingMed and tData.SmallSlots > remainingSml then
                    transSlotNum = tNum
                    remainingLarge = tData.LargeSlots
                    remainingMed = tData.MediumSlots
                    remainingSml = tData.SmallSlots
                end
            end
            if transSlotNum > 0 then
                table.insert(transportTable[transSlotNum].Units, unit)
                if unit.Blueprint.Transport.TransportClass == 3 and remainingLarge >= 1 then
                    transportTable[transSlotNum].LargeSlots = transportTable[transSlotNum].LargeSlots - 1
                    transportTable[transSlotNum].MediumSlots = transportTable[transSlotNum].MediumSlots - 2
                    transportTable[transSlotNum].SmallSlots = transportTable[transSlotNum].SmallSlots - 4
                elseif unit.Blueprint.Transport.TransportClass == 2 and remainingMed > 0 then
                    if transportTable[transSlotNum].LargeSlots > 0 then
                        transportTable[transSlotNum].LargeSlots = transportTable[transSlotNum].LargeSlots - .5
                    end
                    transportTable[transSlotNum].MediumSlots = transportTable[transSlotNum].MediumSlots - 1
                    transportTable[transSlotNum].SmallSlots = transportTable[transSlotNum].SmallSlots - 2
                elseif unit.Blueprint.Transport.TransportClass == 1 and remainingSml > 0 then
                    transportTable[transSlotNum].SmallSlots = transportTable[transSlotNum].SmallSlots - 1
                elseif remainingSml > 0 then
                    transportTable[transSlotNum].SmallSlots = transportTable[transSlotNum].SmallSlots - 1
                else
                    table.insert(leftoverUnits, unit)
                end
            else
                table.insert(leftoverUnits, unit)
            end
        end
    end
    return transportTable, leftoverUnits
end

--- Utility Function
--- Function that gets the correct number of transports for a platoon
--- If BaseName platoon data is specified, grabs transports from that platoon
---@param platoon Platoon
---@return number
function GetTransportsThread(platoon)
    local data = platoon.PlatoonData
    local aiBrain = platoon:GetBrain()
    
    -- Default transport platoon to grab from
    local poolName = 'TransportPool'
    local BaseName = data.BaseName
    
    -- If base name is specified in platoon data, use that instead
    if BaseName then 
        poolName = BaseName .. '_TransportPool'
    end

    local neededTable = GetNumTransports(platoon)
    local numTransports = 0
    local transportsNeeded = false
    if neededTable.Small > 0 or neededTable.Medium > 0 or neededTable.Large > 0 then
        transportsNeeded = true
    end
    local transSlotTable = {}

    if transportsNeeded then
        local pool = aiBrain:GetPlatoonUniquelyNamed(poolName)
        if not pool then
            pool = aiBrain:MakePlatoon('None', 'None')
            pool:UniquelyNamePlatoon(poolName)
        end
        while transportsNeeded do
            neededTable = GetNumTransports(platoon)
            -- Make sure more are needed
            local tempNeeded = {}
            tempNeeded.Small = neededTable.Small
            tempNeeded.Medium = neededTable.Medium
            tempNeeded.Large = neededTable.Large
            -- Find out how many units are needed currently
            for _, v in platoon:GetPlatoonUnits() do
                if not v.Dead then
                    if EntityCategoryContains(categories.TRANSPORTATION, v) then
                        local id = v.UnitId
                        if not transSlotTable[id] then
                            transSlotTable[id] = GetNumTransportSlots(v)
                        end
                        local tempSlots = {}
                        tempSlots.Small = transSlotTable[id].Small
                        tempSlots.Medium = transSlotTable[id].Medium
                        tempSlots.Large = transSlotTable[id].Large
                        while tempNeeded.Large > 0 and tempSlots.Large > 0 do
                            tempNeeded.Large = tempNeeded.Large - 1
                            tempSlots.Large = tempSlots.Large - 1
                            tempSlots.Medium = tempSlots.Medium - 2
                            tempSlots.Small = tempSlots.Small - 4
                        end
                        while tempNeeded.Medium > 0 and tempSlots.Medium > 0 do
                            tempNeeded.Medium = tempNeeded.Medium - 1
                            tempSlots.Medium = tempSlots.Medium - 1
                            tempSlots.Small = tempSlots.Small - 2
                        end
                        while tempNeeded.Small > 0 and tempSlots.Small > 0 do
                            tempNeeded.Small = tempNeeded.Small - 1
                            tempSlots.Small = tempSlots.Small - 1
                        end
                        if tempNeeded.Small <= 0 and tempNeeded.Medium <= 0 and tempNeeded.Large <= 0 then
                            transportsNeeded = false
                        end
                    end
                end
            end
            if transportsNeeded then
                local location = platoon:GetPlatoonPosition()
                local transports = {}
                -- Determine distance of transports from platoon
                for _, unit in pool:GetPlatoonUnits() do
                    if EntityCategoryContains(categories.TRANSPORTATION, unit) and not unit:IsUnitState('Busy') then
                        local unitPos = unit:GetPosition()
                        local curr = {Unit = unit, Distance = VDist2(unitPos[1], unitPos[3], location[1], location[3]), Id = unit.UnitId}
                        table.insert(transports, curr)
                    end
                end
                if not table.empty(transports) then
                    local sortedList = {}
                    -- Sort distances
                    for k = 1, table.getn(transports) do
                        local lowest = -1
                        local key, value
                        for j, u in transports do
                            if lowest == -1 or u.Distance < lowest then
                                lowest = u.Distance
                                value = u
                                key = j
                            end
                        end
                        sortedList[k] = value
                        -- Remove from unsorted table
                        table.remove(transports, key)
                    end
                    -- Take transports as needed
                    for i = 1, table.getn(sortedList) do
                        if transportsNeeded then
                            local id = sortedList[i].Id
                            aiBrain:AssignUnitsToPlatoon(platoon, {sortedList[i].Unit}, 'Scout', 'GrowthFormation')
                            numTransports = numTransports + 1
                            if not transSlotTable[id] then
                                transSlotTable[id] = GetNumTransportSlots(sortedList[i].Unit)
                            end
                            local tempSlots = {}
                            tempSlots.Small = transSlotTable[id].Small
                            tempSlots.Medium = transSlotTable[id].Medium
                            tempSlots.Large = transSlotTable[id].Large
                            -- Update number of slots needed
                            while tempNeeded.Large > 0 and tempSlots.Large > 0 do
                                tempNeeded.Large = tempNeeded.Large - 1
                                tempSlots.Large = tempSlots.Large - 1
                                tempSlots.Medium = tempSlots.Medium - 2
                                tempSlots.Small = tempSlots.Small - 4
                            end
                            while tempNeeded.Medium > 0 and tempSlots.Medium > 0 do
                                tempNeeded.Medium = tempNeeded.Medium - 1
                                tempSlots.Medium = tempSlots.Medium - 1
                                tempSlots.Small = tempSlots.Small - 2
                            end
                            while tempNeeded.Small > 0 and tempSlots.Small > 0 do
                                tempNeeded.Small = tempNeeded.Small - 1
                                tempSlots.Small = tempSlots.Small - 1
                            end
                            if tempNeeded.Small <= 0 and tempNeeded.Medium <= 0 and tempNeeded.Large <= 0 then
                                transportsNeeded = false
                            end
                        end
                    end
                end
            end
            if transportsNeeded then
                WaitSeconds(7)
                if not aiBrain:PlatoonExists(platoon) then
                    return false
                end
                local unitFound = false
                for _, unit in platoon:GetPlatoonUnits() do
                    if not EntityCategoryContains(categories.TRANSPORTATION, unit) then
                        unitFound = true
                        break
                    end
                end
                if not unitFound then
                    ReturnTransportsToPool(platoon, data)
                    return false
                end
            end
        end
    end
    return numTransports
end

--- Utility Function
--- Returns the number of transports required to move the platoon
---@param platoon Platoon
---@return table
function GetNumTransports(platoon)
    local transportNeeded = {
        Small = 0,
        Medium = 0,
        Large = 0,
    }
    for _, v in platoon:GetPlatoonUnits() do
        if not v.Dead then
            if v.Blueprint.Transport.TransportClass == 1 then
                transportNeeded.Small = transportNeeded.Small + 1
            elseif v.Blueprint.Transport.TransportClass == 2 then
                transportNeeded.Medium = transportNeeded.Medium + 1
            elseif v.Blueprint.Transport.TransportClass == 3 then
                transportNeeded.Large = transportNeeded.Large + 1
            else
                transportNeeded.Small = transportNeeded.Small + 1
            end
        end
    end

    return transportNeeded
end

--- Utility Function
--- Returns the number of slots the transport has available
---@param unit Unit
---@return table
function GetNumTransportSlots(unit)
    local bones = {
        Large = 0,
        Medium = 0,
        Small = 0,
    }

    -- compute count based on bones
    for i = 1, unit:GetBoneCount() do
        if unit:GetBoneName(i) ~= nil then
            if string.find(unit:GetBoneName(i), 'Attachpoint_Lrg') then
                bones.Large = bones.Large + 1
            elseif string.find(unit:GetBoneName(i), 'Attachpoint_Med') then
                bones.Medium = bones.Medium + 1
            elseif string.find(unit:GetBoneName(i), 'Attachpoint') then
                bones.Small = bones.Small + 1
            end
        end
    end

    -- retrieve number of slots set by blueprint, if it is set
    local largeSlotsByBlueprint = unit.Blueprint.Transport.SlotsLarge or bones.Large 
    local mediumSlotsByBlueprint = unit.Blueprint.Transport.SlotsMedium or bones.Medium 
    local smallSlotsByBlueprint = unit.Blueprint.Transport.SlotsSmall or bones.Small 

    -- take the minimum of the two
    bones.Large = math.min(bones.Large, largeSlotsByBlueprint)
    bones.Medium = math.min(bones.Medium, mediumSlotsByBlueprint)
    bones.Small = math.min(bones.Small, smallSlotsByBlueprint)

    return bones
end

--- Utility Function
--- Takes transports in platoon, returns them to pool, flies them back to return location
---@param platoon Platoon
---@param data table
function ReturnTransportsToPool(platoon, data)
    -- Put transports back in TPool
    local aiBrain = platoon:GetBrain()
    local transports = platoon:GetSquadUnits('Scout')
    local poolName
    
    -- If base name is specified in platoon data, pick that first over actual base of origin (LocationType)
    local BaseName = data.BaseName
    
    if BaseName then 
        poolName = BaseName .. '_TransportPool'
    else
        poolName = 'TransportPool'
    end

    if table.empty(transports) then
        return
    end

    aiBrain:AssignUnitsToPlatoon(poolName, transports, 'Scout', 'None')
    
    -- Generate safe path to return position, or just move straight to it
    if data.TransportReturn then
        -- Assume TransportReturn is a vector
        local returnLocation = data.TransportReturn
        
        -- If it's marker, convert it to a vector
        if type(data.TransportReturn) == 'string' then
            returnLocation = ScenarioUtils.MarkerToPosition(data.TransportReturn)
        end
        -- '50' is the maximum amount of threat we can still pass by of
        local safePath = NavUtils.PathToWithThreatThreshold('Air', platoon:GetPlatoonPosition(), returnLocation, aiBrain, NavUtils.ThreatFunctions.AntiAir, 50, aiBrain.IMAPConfig.Rings)
        
        if safePath then
            for _, v in safePath do
                IssueMove(transports, v)
            end
        else
            IssueMove(transports, returnLocation)
        end
    end
end

--- Utility Function
--- Returns location with the lowest threat
---@param aiBrain AIBrain
---@param locationList Vector[]
---@param ringSize number
---@param threatType BrainThreatType
---@return Vector
function BrainChooseLowestThreatLocation(aiBrain, locationList, ringSize, threatType)
    -- GetThreatAtPosition() goes nuts if a 5th parameter given to it is nil, and otherwise it calculates overall threat by default
    if not threatType then
        threatType = false
    end
    
    -- Pick the first position as the default, compare the rest with that
    local bestLocation = table.random(locationList)
    local threat = aiBrain:GetThreatAtPosition(bestLocation, ringSize, true, threatType)
    
    -- Loop through each location
    for _, v in locationList do
        local tempThreat = aiBrain:GetThreatAtPosition(v, ringSize, true, threatType)
        WaitTicks(1)
        if tempThreat < threat then
            bestLocation = v
            threat = tempThreat
        end
    end
    
    return bestLocation
end

--- Utility Function
--- Returns location with the highest threat
---@param aiBrain AIBrain
---@param locationList string[]
---@param ringSize number
---@param threatType BrainThreatType
---@return Vector
function BrainChooseHighestThreatLocation(aiBrain, locationList, ringSize, threatType)
    -- GetThreatAtPosition() goes nuts if a 5th parameter given to it is nil, and otherwise it calculates overall threat by default
    if not threatType then
        threatType = false
    end

    -- Pick the first position as the default, compare the rest with that
    local bestLocation = table.random(locationList)
    local threat = aiBrain:GetThreatAtPosition(bestLocation, ringSize, true, threatType)

    for _, v in locationList do
        local tempThreat = aiBrain:GetThreatAtPosition(v, ringSize, true, threatType)
        WaitTicks(1)
        if tempThreat > threat then
            bestLocation = v
            threat = tempThreat
        end
    end

    return bestLocation
end

--- Utility Function
--- Arranges a route from highest to lowest based on threat
---@param aiBrain AIBrain
---@param locationList Vector[]
---@param ringSize number
---@return Vector
function BrainChooseHighestAttackRoute(aiBrain, locationList, ringSize, threatType)
    local attackRoute = {}
    local tempRoute = {}

    for _, v in locationList do
        table.insert(tempRoute, v)
    end

    for i = 1, table.getn(tempRoute) do
        table.insert(attackRoute, BrainChooseHighestThreatLocation(aiBrain, tempRoute, ringSize, threatType))
        for k, v in tempRoute do
            if attackRoute[i] == v then
                table.remove(tempRoute, k)
                break
            end
        end
    end

    return attackRoute
end

--- Utility Function
--- Arranges a route from lowest to highest on threat
---@param aiBrain AIBrain
---@param locationList Vector[]
---@param ringSize number
---@return Vector
function BrainChooseLowestAttackRoute(aiBrain, locationList, ringSize, threatType)
    local attackRoute = {}
    local tempRoute = {}

    for _, v in locationList do
        table.insert(tempRoute, v)
    end

    for i = 1, table.getn(tempRoute) do
        table.insert(attackRoute, BrainChooseLowestThreatLocation(aiBrain, tempRoute, ringSize, threatType))
        for k, v in tempRoute do
            if attackRoute[i] == v then
                table.remove(tempRoute, k)
                break
            end
        end
    end

    return attackRoute
end

--- Assigns the units of the given platoon into new single unit platoons, and sets the 'NukeAI' as their platoon AI function
---@param platoon Platoon
function NukePlatoon(platoon)
    local aiBrain = platoon:GetBrain()
    local SMLs = platoon:GetPlatoonUnits()
    
    for _, silo in SMLs do
        if not silo.Dead then
            local siloPlatoon = aiBrain:MakePlatoon('', '')
            aiBrain:AssignUnitsToPlatoon(siloPlatoon, {silo}, 'Support', 'None')
            siloPlatoon:ForkAIThread(NukeAI)
        end
    end

    aiBrain:DisbandPlatoon(platoon)
end

---@param platoon Platoon
function NukeAI(platoon)
    local aiBrain = platoon:GetBrain()
    local baseName = platoon.PlatoonData.BaseName
    local unit = platoon:GetPlatoonUnits()[1]
    
    if not unit then return end
    
    platoon:Stop()
    
    unit:SetAutoMode(true)
    while aiBrain:PlatoonExists(platoon) do
        while unit:GetNukeSiloAmmoCount() < 1 do
            WaitSeconds(15)
            if not aiBrain:PlatoonExists(platoon) then
                return
            end
        end

        nukePos = AIBehaviors.GetHighestThreatClusterLocation(aiBrain, unit)
        if nukePos then
            IssueNuke({unit}, nukePos)
            WaitSeconds(15)
            IssueClearCommands({unit})
        end
        WaitSeconds(15)
    end
end
