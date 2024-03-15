local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioPlatoonAI = import('/lua/ScenarioPlatoonAI.lua')
local NavUtils = import("/lua/sim/navutils.lua")
local AIUtils = import("/lua/ai/aiutilities.lua")
local AIAttackUtils = import("/lua/ai/aiattackutilities.lua")
local AIBehaviors = import("/lua/ai/aibehaviors.lua")

local Cybran = 5
local Difficulty = ScenarioInfo.Options.Difficulty

-- Upvalued for performance
local TableEmpty = table.empty
local TableInsert = table.insert
local TableRemove = table.remove
local TableGetn = table.getn

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
	
	-- If neither exists, the platoon has yet to be built, return false
	if not platoon then
		return false
	end
	
	-- The engine version of GetPlatoonUnits() can return with the dead/destroyed units, we gotta check if the units are actually alive
	local counter = 0
	local units = platoon:GetPlatoonUnits()
	for index, unit in units do
		if not unit:BeenDestroyed() then
			counter = counter + 1
		end
	end
	
	return counter >= numReq
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
	
	-- The engine version of GetPlatoonUnits() can return with the dead/destroyed units, we gotta check if the units are actually alive
	local counter = 0
	local units = platoon:GetPlatoonUnits()
	for index, unit in units do
		if not unit:BeenDestroyed() then
			counter = counter + 1
		end
	end

	return counter < numReq
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
                TableInsert(attackPositions, ScenarioUtils.MarkerToPosition(v))
            else
                TableInsert(attackPositions, v)
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
                TableInsert(landingPositions, ScenarioUtils.MarkerToPosition(v))
            else
                TableInsert(landingPositions, v)
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
	while VDist2(PlatoonPosition[1], PlatoonPosition[3], landingLocation[1], landingLocation[3]) > 105 and not TableEmpty(platoon:GetSquadUnits('Scout')) do
		-- Update landing location at the start of the loop, otherwise the platoon might pick a different landing zone at the very last second.
		-- This can result in retarded behaviour, and we want to avoid that, if we are about to unload in 1 second, then UNLOAD, and not get yeeted because we just got a completely fresh set of commands
		landingLocation = BrainChooseLowestThreatLocation(aiBrain, landingPositions, 1, 'AntiAir')
		
		platoon:Stop()
	
		-- Transports get the 'Scout' role, if other units got it as well, you damn well better change it to something else
		local threatMax = 10
		local transportNum = TableGetn(platoon:GetSquadUnits('Scout'))
			
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
		if aiBrain:GetThreatAtPosition(PlatoonPosition, 1, true, 'AntiAir') > threatMax  then
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
        ReturnTransportsToPool(platoon)
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
        TableInsert(transportTable,
            {
                Transport = unit,
                LargeSlots = transSlotTable[id].Large,
                MediumSlots = transSlotTable[id].Medium,
                SmallSlots = transSlotTable[id].Small,
                Units = {}
            }
       )
    end
    local remainingSize3 = {}
    local remainingSize2 = {}
    local remainingSize1 = {}
	
	for num, unit in platoon:GetPlatoonUnits() do
        if unit.Blueprint.Transport.TransportClass == 3 then
            TableInsert(remainingSize3, unit)
        elseif unit.Blueprint.Transport.TransportClass == 2 then
            TableInsert(remainingSize2, unit)
        elseif unit.Blueprint.Transport.TransportClass == 1 then
            TableInsert(remainingSize1, unit)
        elseif not EntityCategoryContains(categories.TRANSPORTATION, unit) then
            TableInsert(remainingSize1, unit)
        end
    end

    local leftoverUnits = {}
    local currLeftovers = {}
	local counter = 0
	
	-- Assign large units - note how we come back with leftoverunits here
    transportTable, leftoverUnits = SortUnitsOnTransports(transportTable, remainingSize3, -1)
	-- Assign medium units - but this time we come back with currleftovers
    transportTable, currLeftovers = SortUnitsOnTransports(transportTable, remainingSize2, -1)
	
	-- We move any currleftovers into the leftoverunits table
	for k,v in currLeftovers do
		if not v.Dead then
            counter = counter + 1
			leftoverUnits[counter] = v
		end
	end
	
	currleftovers = {}
	
    -- Assign the small units - again coming back with currleftovers
    transportTable, currLeftovers = SortUnitsOnTransports(transportTable, remainingSize1, -1)
	
	-- Again adding currleftovers to the leftoverunits table
	for k,v in currLeftovers do
		if not v.Dead then
            counter = counter + 1
			leftoverUnits[counter] = v
		end
	end
	
	currleftovers = {}
	
	if leftoverUnits[1] then
		transportTable, currLeftovers = SortUnitsOnTransports(transportTable, leftoverUnits, -1)
	end
	
	-- Self-destruct any units we couldn't arrange a transport slot for
	if currleftovers[1] then
		for k, v in currLeftovers do
			if not v.Dead then
				v:Kill()
			end
		end
	end

    -- Old load transports
    local unitsToDrop = {}
    for num, data in transportTable do
        if not TableEmpty(data.Units) then
            IssueClearCommands(data.Units)
            IssueTransportLoad(data.Units, data.Transport)
            for _, v in data.Units do TableInsert(unitsToDrop, v) end
        end
    end

    local attached = true
    repeat
        WaitSeconds(1)
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
	
	-- Self-destruct any units that failed to load
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
			local TransportClass = 	unit.Blueprint.Transport.TransportClass
			
            for tNum, tData in transportTable do
                if tData.LargeSlots >= remainingLarge and TransportClass == 3 then
                    transSlotNum = tNum
                    remainingLarge = tData.LargeSlots
                    remainingMed = tData.MediumSlots
                    remainingSml = tData.SmallSlots
                elseif tData.MediumSlots >= remainingMed and TransportClass == 2 then
                    transSlotNum = tNum
                    remainingLarge = tData.LargeSlots
                    remainingMed = tData.MediumSlots
                    remainingSml = tData.SmallSlots
                elseif tData.SmallSlots >= remainingSml and TransportClass == 1 then
                    transSlotNum = tNum
                    remainingLarge = tData.LargeSlots
                    remainingMed = tData.MediumSlots
                    remainingSml = tData.SmallSlots
                end
            end
            if transSlotNum > 0 then
                if unit.Blueprint.Transport.TransportClass == 3 and remainingLarge >= 1 then
                    transportTable[transSlotNum].LargeSlots = transportTable[transSlotNum].LargeSlots - 1
                    transportTable[transSlotNum].MediumSlots = transportTable[transSlotNum].MediumSlots - 2
                    transportTable[transSlotNum].SmallSlots = transportTable[transSlotNum].SmallSlots - 4
					TableInsert(transportTable[transSlotNum].Units, unit)
                elseif unit.Blueprint.Transport.TransportClass == 2 and remainingMed >= 1 then
                    --if transportTable[transSlotNum].LargeSlots > 0 then
                        transportTable[transSlotNum].LargeSlots = transportTable[transSlotNum].LargeSlots - 0.5
                   --end
                    transportTable[transSlotNum].MediumSlots = transportTable[transSlotNum].MediumSlots - 1
                    transportTable[transSlotNum].SmallSlots = transportTable[transSlotNum].SmallSlots - 2
					TableInsert(transportTable[transSlotNum].Units, unit)
                elseif unit.Blueprint.Transport.TransportClass == 1 and remainingSml >= 1 then
                    transportTable[transSlotNum].SmallSlots = transportTable[transSlotNum].SmallSlots - 1
					TableInsert(transportTable[transSlotNum].Units, unit)
                else
                    TableInsert(leftoverUnits, unit)
                end
            else
                TableInsert(leftoverUnits, unit)
            end
        end
    end
    return transportTable, leftoverUnits
end

--- Utility Function
--- Function that gets the correct number of transports for a platoon, if BaseName platoon data is specified, grabs transports from that platoon
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
                        if tempNeeded.Small < 1 and tempNeeded.Medium < 1 and tempNeeded.Large < 1 then
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
                        TableInsert(transports, curr)
                    end
                end
                if not TableEmpty(transports) then
                    local sortedList = {}
                    -- Sort distances
                    for k = 1, TableGetn(transports) do
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
                        TableRemove(transports, key)
                    end
                    -- Take transports as needed
                    for i = 1, TableGetn(sortedList) do
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
                            if tempNeeded.Small < 1 and tempNeeded.Medium < 1 and tempNeeded.Large < 1 then
                                transportsNeeded = false
                            end
                        end
                    end
                end
            end
            if transportsNeeded then
                WaitSeconds(5)
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
                    ReturnTransportsToPool(platoon)
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
	
	-- I'm not a fan of having to hardcode these values, but the blueprint, and even engine method are unreliable
	if EntityCategoryContains(categories.xea0306, unit) then
		bones.Large = 8
		bones.Medium = 10
		bones.Small = 24
	elseif EntityCategoryContains(categories.uea0203, unit) then
		bones.Large = 0
		bones.Medium = 1
		bones.Small = 1
	elseif EntityCategoryContains(categories.uea0104, unit) then
		bones.Large = 3
		bones.Medium = 6
		bones.Small = 14
	elseif EntityCategoryContains(categories.uea0107, unit) then
		bones.Large = 1
		bones.Medium = 2
		bones.Small = 6
	elseif EntityCategoryContains(categories.uaa0107, unit) then
		bones.Large = 1
		bones.Medium = 3
		bones.Small = 6
	elseif EntityCategoryContains(categories.uaa0104, unit) then
		bones.Large = 3
		bones.Medium = 6
		bones.Small = 12
	elseif EntityCategoryContains(categories.ura0107, unit) then
		bones.Large = 1
		bones.Medium = 2
		bones.Small = 6
	elseif EntityCategoryContains(categories.ura0104, unit) then
		bones.Large = 2
		bones.Medium = 4
		bones.Small = 10
	elseif EntityCategoryContains(categories.xsa0107, unit) then
		bones.Large = 1
		bones.Medium = 4
		bones.Small = 8
	elseif EntityCategoryContains(categories.xsa0104, unit) then
		bones.Large = 4
		bones.Medium = 8
		bones.Small = 16
	else
		-- If all else fails, try to get the slots from the unit's blueprint
		local largeSlotsByBlueprint = unit.Blueprint.Transport.SlotsLarge
		local mediumSlotsByBlueprint = unit.Blueprint.Transport.SlotsMedium
		local smallSlotsByBlueprint = unit.Blueprint.Transport.SlotsSmall
		
		bones.Large = largeSlotsByBlueprint
		bones.Medium = mediumSlotsByBlueprint
		bones.Small = smallSlotsByBlueprint
	end

    return bones
end

--- Utility Function
--- Takes transports in platoon, returns them to pool, flies them back to return location
---@param platoon Platoon
---@param data table
function ReturnTransportsToPool(platoon)
    -- Put transports back in TPool
    local aiBrain = platoon:GetBrain()
    local transports = platoon:GetSquadUnits('Scout')
	local data = platoon.PlatoonData
	
	-- Default transport platoon to grab from
	local poolName = 'TransportPool'
	local BaseName = data.BaseName
	
	-- If base name is specified in platoon data, use that instead
	if BaseName then 
		poolName = BaseName .. '_TransportPool'
	end

    if TableEmpty(transports) then
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
	-- GetThreatAtPosition() goes nuts if a parameter given to it is nil
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
	-- GetThreatAtPosition() goes nuts if a parameter given to it is nil, and otherwise it calculates overall threat by default
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
        TableInsert(tempRoute, v)
    end

    for i = 1, TableGetn(tempRoute) do
        TableInsert(attackRoute, BrainChooseHighestThreatLocation(aiBrain, tempRoute, ringSize, threatType))
        for k, v in tempRoute do
            if attackRoute[i] == v then
                TableRemove(tempRoute, k)
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
        TableInsert(tempRoute, v)
    end

    for i = 1, TableGetn(tempRoute) do
        TableInsert(attackRoute, BrainChooseLowestThreatLocation(aiBrain, tempRoute, ringSize, threatType))
        for k, v in tempRoute do
            if attackRoute[i] == v then
                TableRemove(tempRoute, k)
                break
            end
        end
    end

    return attackRoute
end

--------------------
-- Platoon Functions
--------------------

-- Merges units produced by the Base Manager conditional build into the same platoon.
-- @PlatoonData
--		@Name - String, unique name for this platoon
--		@NumRequired - Number of experimentals to start moving the platoon
--		@PatrolChain - Name of the chain to use
--		@PatrolChains - Table of chain names, use this if you want to randomly pick between chains
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
        ForkThread(MultipleExperimentalsPatrolThread, plat)
    end
end

--- Handles an unique platoon of multiple experimentals.
function MultipleExperimentalsPatrolThread(platoon)
    local brain = platoon:GetBrain()
    local data = platoon.PlatoonData

    while brain:PlatoonExists(platoon) do
        if not platoon:IsPatrolling('Attack') then
            local numAlive = 0
            for _, v in platoon:GetPlatoonUnits() do
                if not v:IsDead() then
                    numAlive = numAlive + 1
                end
            end

            if numAlive == data.NumRequired then
				--We received a table of chains, pick one at random
				--Works fine even if only 1 chain was given
				if data.PatrolChains then
					--Pick a random chain from the table
					for _, v in ScenarioUtils.ChainToPositions(table.random(data.PatrolChains)) do
						platoon:Patrol(v)
					end
				--We received a single chain
				elseif data.PatrolChain then
					for _, v in ScenarioUtils.ChainToPositions(data.PatrolChain) do
						platoon:Patrol(v)
					end
				--We didn't receive any valid chain data for the platoon
				else
					error('*CUSTOM FUNCTIONS AI ERROR: AddExperimentalToPlatoon PatrolChains or PatrolChain not defined.', 2)
				end
            end
        end
        WaitSeconds(10)
    end
end

--- The default engineer build platoon used by SC1, otherwise just wasted in SPAI
--- Modified to allow additional functions to be called on the built platoon upon forming, if needed.
---@param platoon Platoon
function EngineersBuildPlatoon(platoon)
    local aiBrain = platoon:GetBrain()
    local platoonUnits = platoon:GetPlatoonUnits()
    local data = platoon.PlatoonData
    local platoonName = data.PlatoonName
    local eng = false
    local engTable = {}
    local buildingPlatoon = false
    local buildingData
    local unitBeingBuilt = false
    local busy = false

    if not data.PlatoonsTable then
        error('*SCENARIO PLATOON AI ERROR: EngineersBuildPlatoon requires PlatoonsTable', 2)
    end

    -- Find all engineers in platoon
    for _, v in platoonUnits do
        if EntityCategoryContains(categories.CONSTRUCTION, v) then
            if not eng then
                eng = v
            else
                TableInsert(engTable, v)
            end
        end
    end
    if not eng then
        error('*SCENARIO PLATOON AI ERROR: No Engineers found in platoon using EngineersBuildPlatoon', 2)
    end

    -- Wait for eng to stop moving
    while eng:IsUnitState('Moving') do
        WaitSeconds(1)
        if not aiBrain:PlatoonExists(platoon) then
            return
        end
    end

    -- Have all engineers guard main engineer
    if not TableEmpty(engTable) then
        if eng.Dead then -- Must check if a death occured since platoon was forked
            for num, unit in engTable do
                if not unit.Dead then
                    eng = TableRemove(engTable, num)
                    if not TableEmpty(engTable) then
                        IssueGuard(engTable, eng)
                    end
                    break
                end
            end
        else
            IssueGuard(engTable, eng)
        end
    end

    if not aiBrain.EngBuiltPlatoonList then
        aiBrain.EngBuiltPlatoonList = {}
    end

    while aiBrain:PlatoonExists(platoon) do
        -- Set new primary eng
        if eng.Dead then
            eng, engTable = AssistOtherEngineer(eng, engTable, unitBeingBuilt)
        end
        if not buildingPlatoon then
            for _, v in data.PlatoonsTable do
                if not aiBrain.EngBuiltPlatoonList[v.PlatoonName] then
                    buildingPlatoon = v.PlatoonName
                    buildingData = v
                    break
                else
                    local plat = aiBrain.EngBuiltPlatoonList[v.PlatoonName]
                    if not aiBrain:PlatoonExists(plat) then
                        buildingPlatoon = v.PlatoonName
                        buildingData = v
                        break
                    end
                end
            end
        end
		
        if not eng:IsUnitState('Patrolling') and (eng:IsUnitState('Reclaiming') or eng:IsUnitState('Building') or eng:IsUnitState('Upgrading') or eng:IsUnitState('Repairing')) then
            busy = true
        end
		
        if not busy and buildingPlatoon then
            local newPlatoonUnits = {}
            local unitGroup = ScenarioUtils.FlattenTreeGroup(aiBrain.Name, buildingPlatoon)
            local plat
			
            for strName, tblData in unitGroup do
                if eng and aiBrain:CanBuildStructureAt(tblData.type, tblData.Position) then
                    IssueStop({eng})
                    IssueClearCommands({eng})
                    local result = aiBrain:BuildStructure(eng, tblData.type, {tblData.Position[1], tblData.Position[3], 0}, false)
                    unitBeingBuilt = false

                    repeat
                        WaitSeconds(5)
                        if eng.Dead then
                            eng, engTable = AssistOtherEngineer(eng, engTable, unitBeingBuilt)
                        else
                            if not unitBeingBuilt then
                                unitBeingBuilt = eng.UnitBeingBuilt
                                if unitBeingBuilt then
                                    TableInsert(newPlatoonUnits, unitBeingBuilt)
                                end
                            end
                        end
                    until not eng or eng.Dead or eng:IsIdleState()
					
                    if not aiBrain.EngBuiltPlatoonList[buildingPlatoon] then
                        plat = aiBrain:MakePlatoon('', '')
                        aiBrain.EngBuiltPlatoonList[buildingPlatoon] = plat
                        plat.EngBuildName = buildingPlatoon
                        plat:AddDestroyCallback(
							function(aiBrain, plat)
								aiBrain.EngBuiltPlatoonList[plat.EngBuildName] = false
							end
						)
                    end
                    aiBrain:AssignUnitsToPlatoon(aiBrain.EngBuiltPlatoonList[buildingPlatoon], {unitBeingBuilt}, 'Attack', 'NoFormation')
                end
            end
			
            buildingPlatoon = false
            if not TableEmpty(plat:GetPlatoonUnits()) then
				-- Assign platoon data
                if buildingData.PlatoonData then
                    plat.PlatoonData = buildingData.PlatoonData
                end
				
				-- We can theoretically use this to actually combine factory-built, and engineer-built platoons via the AttackManager
				-- So, I'm keeping this part
                if plat.PlatoonData.AMPlatoons then
                    plat:SetPartOfAttackForce()
                end
				
				-- Fork either platoon plan, or specific AI thread
                if buildingData.PlatoonAI then
                    plat:SetAIPlan(buildingData.PlatoonAI)
				elseif buildingData.PlatoonAIFunction then
					plat:ForkAIThread(import(buildingData.PlatoonAIFunction[1])[buildingData.PlatoonAIFunction[2]])
                end
				
				-- Fork additional functions on the platoon
				if buildingData.PlatoonAddFunctions then
					for _, func in buildingData.PlatoonAddFunctions do
						if type(func) == "function" then
							plat:ForkThread(func)
						else
							plat:ForkThread(import(func[1])[func[2]])
						end
                    end
				end
            end
            newPlatoonUnits = {}

            -- Disband if desired
            if aiBrain:PlatoonExists(platoon) and data.DisbandAfterBuilding then
                aiBrain:DisbandPlatoon(platoon)
            end
        end
        if not eng:IsUnitState('Patrolling') and data.PatrolChain then
            for _, v in ScenarioUtils.ChainToPositions(data.PatrolChain) do
                platoon:Patrol(v)
            end
        end
        WaitSeconds(15)
    end
end

--- Utility Function
--- Resets main engineer and engTablef or StartBaseEngineer
---@param eng EngineerManager
---@param engTable table
---@param unitBeingBuilt Unit
---@return EngineerManager|false
---@return table
function AssistOtherEngineer(eng, engTable, unitBeingBuilt)
    if engTable and not TableEmpty(engTable) then
        for num, unit in engTable do
            if not unit.Dead then
                eng = TableRemove(engTable, num)
                if not TableEmpty(engTable) then
                    IssueGuard(engTable, eng)
                end
                if unitBeingBuilt and not unitBeingBuilt.Dead then
                    IssueRepair({eng}, unitBeingBuilt)
                end
                break
            end
        end
        if eng.Dead then
            return false
        end
    end
    return eng, engTable
end

--  Moves to a set of locations, then disbands if desired
--	Designed for custom Engineer platoons (including sACUs) to move to an expansion base, then disband
--  @PlatoonData
--      @MoveRoute - List of locations to move to
--      @MoveChain - Chain of locations to move
--      @UseTransports - boolean, if true, use transports to move
--		@DisbandAfterArrival - boolean, if true, platoon disbands at the destination.
--  @param platoon Platoon
function EngineersMoveToThread(platoon)
	local cmd = false
    local data = platoon.PlatoonData
	local aiBrain = platoon:GetBrain()
	
	platoon:Stop()

    if data then
        if data.MoveRoute or data.MoveChain then
            local movePositions = {}
            if data.MoveChain then
                movePositions = ScenarioUtils.ChainToPositions(data.MoveChain)
            else
                for _, v in data.MoveRoute do
                    if type(v) == 'string' then
                        TableInsert(movePositions, ScenarioUtils.MarkerToPosition(v))
                    else
                        TableInsert(movePositions, v)
                    end
                end
            end
            if data.UseTransports then
                for _, v in movePositions do
                cmd = platoon:MoveToLocation(v, data.UseTransports)
                end
            else
                for _, v in movePositions do
                cmd = platoon:MoveToLocation(v, false)
                end
            end
        else
            error('*CUSTOM FUNCTIONS  AI ERROR: EngineersMoveToThread MoveRoute or MoveChain not defined', 2)
        end
    else
        error('*CUSTOM FUNCTIONS AI ERROR: EngineersMoveToThread PlatoonData not defined', 2)
    end
	
	if cmd then
		if data.DisbandAfterArrival then
			while aiBrain:PlatoonExists(platoon) do
				-- Only disband after the move command is finished
				if not platoon:IsCommandsActive(cmd) then
					aiBrain:DisbandPlatoon(platoon)
					return
				end
				WaitSeconds(5)
			end
		end
	end
end

--- Adds the platoon's engineer units to the BaseManager, used for expansion, or base rebuilding
---@param platoon Platoon
function AddPlatoonToBaseManager(platoon)
	platoon:StopAI()
	
	if not platoon.PlatoonData.BaseName then
		error('*CUSTOM FUNCTIONS AI ERROR: AddPlatoonToBaseManager PlatoonData not defined, requires BaseName', 2)
	end
	
	platoon:ForkAIThread(import('/lua/AI/OpAI/BaseManagerPlatoonThreads.lua').BaseManagerEngineerPlatoonSplit)
end

--- Platoon generates a safe path to the first position of a set of locations, then patrols them by starting at the lowest threat location
--- Path is periodically updated until the platoon is close enough to ignore path generation
--- - PatrolRoute - List of locations to patrol
--- - PatrolChain - Chain of locations to patrol
---@param platoon Platoon
function AdvancedPatrolThread(platoon)
	local aiBrain = platoon:GetBrain()
    local data = platoon.PlatoonData
	local AttackPositions = {}			-- Table of locations gathered either from data.PatrolChain, or data.PatrolRoute
	local cmd
	local threatValue = 5				-- Defaults to 5, is overwritten if proper platoon threat is obtainable
	local platoonThreat = false			-- Used for own threat calculation, should either be 'Air' or 'Surface' depending on platoon layer
	local threatType = false			-- Used for hostile threat calculation, should either be 'AntiAir' or 'AntiSurface' depending on platoon layer
	
	-- Get the most restrictive layer of the platoon for path generation
	AIAttackUtils.GetMostRestrictiveLayer(platoon)
	
	if not platoon.MovementLayer then
		error('*CUSTOM PLATOON AI ERROR: Couldn\'t determine platoon\'s movement layer.', 2)
	end
	-- Assign calculation data according to layer type
	-- If it's not 'Air', treat the platoon as a surface one, which includes surface ships as well
	if platoon.MovementLayer == 'Air' then
		threatValue = platoon:GetPlatoonThreat('Air', categories.ALLUNITS)
		platoonThreat = 'Air'
		threatType = 'AntiAir'
	else
		threatValue = platoon:GetPlatoonThreat('Surface', categories.ALLUNITS)
		platoonThreat = 'Surface'
		threatType = 'AntiSurface'
	end
	
    platoon:Stop()
	
	if not data.PatrolRoute and not data.PatrolChain then
		error('*CUSTOM PLATOON AI ERROR: PlatoonData not defined, requires either PatrolRoute or PatrolChain', 2)
	end

	-- Make locations out of either chains, markers, or marker names
	-- We're going to use these to sort locations by threat
	if data.PatrolChain then
		AttackPositions = ScenarioUtils.ChainToPositions(data.PatrolChain)
	elseif data.PatrolRoute then
		for _, v in data.PatrolRoute do
            if type(v) == 'string' then
                TableInsert(AttackPositions, ScenarioUtils.MarkerToPosition(v))
            else
                TableInsert(AttackPositions, v)
            end
        end
	end
	
	if TableEmpty(AttackPositions) then
		error('*CUSTOM PLATOON AI ERROR: Could not create AttackPositions out of PatrolRoute or PatrolChain, they are most likely not defined', 2)
	end
	
	-- Find safest attack location, and path to it, update them every 10 or so seconds until we are close enough to it
	-- Also sort AttackPositions by threat
	local SortedAttackPositions = BrainChooseLowestAttackRoute(aiBrain, AttackPositions, 1, threatType)
	local startLocation = SortedAttackPositions[1]
	local PlatoonPosition = platoon:GetPlatoonPosition()
	
	while VDist2(PlatoonPosition[1], PlatoonPosition[3], startLocation[1], startLocation[3]) > 90 do
		-- Update locations, threat values, and loop again if we aren't close enough
		SortedAttackPositions = BrainChooseLowestAttackRoute(aiBrain, AttackPositions, 1, threatType)
		startLocation = SortedAttackPositions[1]
		
		-- Re-calculate platoon threat, as some of its units may have been yeeted
		threatValue = platoon:GetPlatoonThreat(platoonThreat, categories.ALLUNITS)
		
		platoon:Stop()
		
		-- Generate a safe path
		local safePath = NavUtils.PathToWithThreatThreshold(platoon.MovementLayer, PlatoonPosition, startLocation, aiBrain, NavUtils.ThreatFunctions[threatType], threatValue * 10, aiBrain.IMAPConfig.Rings)
		
		if safePath then
			ScenarioFramework.PlatoonMoveRoute(platoon, safePath)
		end
		
		-- Patrol the locations
		for _, node in SortedAttackPositions do
			if type(node) == 'string' then
				node = ScenarioUtils.MarkerToPosition(node)
			end

			cmd = platoon:Patrol(node)
		end
		
		WaitSeconds(10)
		
		if not aiBrain:PlatoonExists(platoon) then
            return
        end
		
		-- Update platoon position
		PlatoonPosition = platoon:GetPlatoonPosition()
		
		-- If we are surrounded by too much threat, then fuck it, patrol our last determined route
		if aiBrain:GetThreatAtPosition(platoon:GetPlatoonPosition(), 1, true, threatType) > threatValue * 10  then
			platoon:Stop()
			
			-- Patrol the locations
			for _, node in SortedAttackPositions do
				if type(node) == 'string' then
					node = ScenarioUtils.MarkerToPosition(node)
				end

				cmd = platoon:Patrol(node)
			end
			
			break
		end
	end
	
	-- If we are already close enough, just patrol the specified chain
	if not cmd then
		for _, node in SortedAttackPositions do
			if type(node) == 'string' then
				node = ScenarioUtils.MarkerToPosition(node)
			end

			cmd = platoon:Patrol(node)
		end
	end
end

--- Adds a unit as the primary factory for an AI build location
--- @PlatoonData:
---		@BaseName 		- String, base name we send the Fatboy to, if it doesn't exist, it will be automatically created.
---		@RallyPoint 	- String, rally point name for the Fatboy to send its built units to
---		@MoveRoute 		- String, chain of locations the Fatboy will use to move to its destination
---		@FactoryType 	- String, Factory type, 'Land', 'Air', 'Sea', and 'Gate' are the options
---			The below PlatoonData are only needed if the base doesn't exist yet
---				@BaseMarker	- String, marker name of a new base we want to initially create
---				@BaseRadius	- Number, radius of a new base we want to initially create
---@param platoon Platoon
function AddMobileFactory(platoon)
	local aiBrain = platoon:GetBrain()
	local data = platoon.PlatoonData
	local unit = platoon:GetPlatoonUnits()[1]
	local factory = unit.ExternalFactory
	
	-- Add build location if it doesn't exist yet
	if not aiBrain:PBMGetLocation(data.BaseName) then
		LOG('Creating ' .. data.BaseName .. 'because it doesn\'t exist yet.')
		aiBrain:PBMAddBuildLocation(data.BaseMarker, data.BaseRadius, data.BaseName)
	end
	
	-- Generic chain of move orders to get the Fatboy where we want it
	ScenarioFramework.PlatoonMoveRoute(platoon, data.MoveRoute)
	
	if not data.FactoryType then
		error('AI WARNING: AddMobileFactory() requires FactoryType data: Land, Air, Sea, or Gate are the valid ones.', 2)
	end
	
	for num, loc in aiBrain.PBM.Locations do
		if loc.LocationType == data.BaseName then
			loc.PrimaryFactories[data.FactoryType] = factory
			break
		end
	end
	
	IssueClearFactoryCommands({factory})
	IssueFactoryRallyPoint({factory}, ScenarioUtils.MarkerToPosition(data.RallyPoint))
end

--- Function for removing wreckages, useful for long in-game testing to avoid simspeed slowdowns due to wreckage counts
function AreaReclaimCleanUp()
	
	local Reclaimables = GetReclaimablesInRect(ScenarioUtils.AreaToRect('M3NewArea'))
		--Check if there are any reclaimables
		if not TableEmpty(Reclaimables) then
			LOG('*DEBUG: Reclaimables found, their current count:' .. table.getsize(Reclaimables))
			for k, v in Reclaimables do
				if v and v.IsWreckage and not v.IsUnit then	--IsUnit(unit) is the same as unit.IsUnit, the latter being added by FAF in 'Unit.lua'
					--Reduce wreckage health
					v:AdjustHealth(v, -1500)
					--If wreckage health is 0 or below, remove it
					if v:GetHealth() <= 0 then
						v:OnKilled()
					--If wreckage health is above 0, update reclaim values
					else
						v:UpdateReclaimLeft()
					end
				end
			end
		end
	LOG('DEBUG: Reclaimables successfully damaged.')
end
