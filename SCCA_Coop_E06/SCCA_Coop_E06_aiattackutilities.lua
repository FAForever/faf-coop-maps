local AIUtils = import("/lua/ai/aiutilities.lua")
local AIAttackUtils = import("/lua/ai/aiattackutilities.lua")
local CustomFunctions = import("/maps/scca_coop_e06/scca_coop_e06_customfunctions.lua")
local NavUtils = import("/lua/sim/navutils.lua")
local ScenarioFramework = import("/lua/scenarioframework.lua")
local ScenarioUtils = import("/lua/sim/scenarioutilities.lua")

-- Upvalued for performance
local TableEmpty = table.empty
local TableInsert = table.insert
local TableRemove = table.remove
local TableGetn = table.getn

--------------------
-- Platoon functions
--------------------

--- Function: NavalForceAI
--- Basic attack logic for boats. Searches for a good area to attack, and will use a safe path (if available) to get there.
---@param self Platoon
function NavalForceAI(self)
    self:Stop()
    local aiBrain = self:GetBrain()

    AIAttackUtils.GetMostRestrictiveLayer(self)

    local platoonUnits = self:GetPlatoonUnits()
    local numberOfUnitsInPlatoon = TableGetn(platoonUnits)
    local oldNumberOfUnitsInPlatoon = numberOfUnitsInPlatoon
    local stuckCount = 0

    self.PlatoonAttackForce = true

	-- Issue a dive for submarines if for some reason they are surfaced
    for k,v in self:GetPlatoonUnits() do
        if v.Dead then
			continue
        end

        if v.Layer == 'Sub' then
			continue
        end

        if v:TestCommandCaps('RULEUCC_Dive') then
			IssueDive({v})
        end
    end

    while aiBrain:PlatoonExists(self) do
        local pos = self:GetPlatoonPosition() -- Update positions; prev position done at end of loop so not done first time

        -- If we can't get a position, then we must be dead
        if not pos then
			break
        end

        -- Rebuild formation
        platoonUnits = self:GetPlatoonUnits()
        numberOfUnitsInPlatoon = TableGetn(platoonUnits)
        -- If we have a different number of units in our platoon, regather
        if (oldNumberOfUnitsInPlatoon != numberOfUnitsInPlatoon) then
            self:StopAttack()
        end
        oldNumberOfUnitsInPlatoon = numberOfUnitsInPlatoon

        local cmdQ = {}
        -- fill cmdQ with current command queue for each unit
        for k, v in self:GetPlatoonUnits() do
            if not v.Dead then
                local unitCmdQ = v:GetCommandQueue()
                for cmdIdx,cmdVal in unitCmdQ do
                    table.insert(cmdQ, cmdVal)
                    break
                end
            end
        end

        -- If we're on our final push through to the destination, and we find a unit close to our destination
        local closestTarget
        local NavalPriorities = {
            'ANTINAVY - MOBILE',
            'NAVAL MOBILE',
            'NAVAL FACTORY',
        }

        local nearDest = false
        local oldPathSize = TableGetn(self.LastAttackDestination)
        local maxRange = AIAttackUtils.GetNavalPlatoonMaxRange(aiBrain, self)
        if maxRange then maxRange = maxRange + 10 end

        if self.LastAttackDestination then
            nearDest = oldPathSize == 0 or VDist3(self.LastAttackDestination[oldPathSize], pos) < maxRange
        end

        for _, priority in NavalPriorities do
            closestTarget = self:FindClosestUnit('attack', 'enemy', true, ParseEntityCategory(priority))
            if closestTarget and VDist3(closestTarget:GetPosition(), pos) < maxRange then
                break
            end
        end

        -- If we're near our destination and we have a unit closeby to kill, kill it
        if closestTarget and VDist3(closestTarget:GetPosition(), pos) < maxRange and nearDest then
            self:StopAttack()
            self:AttackTarget(closestTarget)
            cmdQ = {1}
        -- If we have nothing to do, try finding something to do
        elseif TableEmpty(cmdQ) then
            self:StopAttack()
            cmdQ = AIPlatoonNavalAttackVector(aiBrain, self)
            stuckCount = 0
        -- If we've been stuck and unable to reach next marker? Ignore nearby stuff and pick another target
        elseif self.LastPosition and VDist2Sq(self.LastPosition[1], self.LastPosition[3], pos[1], pos[3]) < (self.PlatoonData.StuckDistance or 64) then
            stuckCount = stuckCount + 1
            if stuckCount >= 3 then
                self:StopAttack()
                cmdQ = AIPlatoonNavalAttackVector(aiBrain, self)
                stuckCount = 0
            end
        else
            stuckCount = 0
        end

        self.LastPosition = pos

        -- Wait a while if we're stuck so that we have a better chance to move
        WaitSeconds(10 + 2 * stuckCount)
    end
end
	
--- Function: AttackForceAI
--- Basic attack logic.  Searches for a good area to attack, and will use a safe path (if available) to get there.
---@param self Platoon
function AttackForceAI(self)
    self:Stop()
    local aiBrain = self:GetBrain()

    -- Engine function, potentially useful to focus a single enemy army at the time, but it's currently not used at all
    --local enemy = aiBrain:GetCurrentEnemy()

    local platoonUnits = self:GetPlatoonUnits()
    local numberOfUnitsInPlatoon = TableGetn(platoonUnits)
    local oldNumberOfUnitsInPlatoon = numberOfUnitsInPlatoon
    local stuckCount = 0

    self.PlatoonAttackForce = true

    while aiBrain:PlatoonExists(self) do
        local pos = self:GetPlatoonPosition() -- Update positions; prev position done at end of loop so not done first time

        -- Rebuild formation
        platoonUnits = self:GetPlatoonUnits()
        numberOfUnitsInPlatoon = TableGetn(platoonUnits)
        -- If we have a different number of units in our platoon, regather
        if (oldNumberOfUnitsInPlatoon != numberOfUnitsInPlatoon) then
            self:StopAttack()
        end
        oldNumberOfUnitsInPlatoon = numberOfUnitsInPlatoon

        local cmdQ = {}
        -- Fill cmdQ with current command queue for each unit
        for k, v in platoonUnits do
            if not v.Dead then
                local unitCmdQ = v:GetCommandQueue()
                for cmdIdx,cmdVal in unitCmdQ do
                    table.insert(cmdQ, cmdVal)
                    break
                end
            end
        end

        -- If we're on our final push through to the destination, and we find a unit close to our destination
        local closestTarget = self:FindClosestUnit('Attack', 'Enemy', true, categories.ALLUNITS - categories.WALL)
        local nearDest = false
        local oldPathSize = TableGetn(self.LastAttackDestination)
        if self.LastAttackDestination then
            nearDest = oldPathSize == 0 or VDist3(self.LastAttackDestination[oldPathSize], pos) < 30
        end

        -- if we're near our destination and we have a unit closeby to kill, kill it
        if TableGetn(cmdQ) <= 1 and closestTarget and VDist3(closestTarget:GetPosition(), pos) < 30 and nearDest then
            self:StopAttack()
            self:AttackTarget(closestTarget)
            cmdQ = {1}
        -- if we have nothing to do, try finding something to do
        elseif TableEmpty(cmdQ) then
            self:StopAttack()
            cmdQ = AIPlatoonSquadAttackVector(aiBrain, self, false)
            stuckCount = 0
        -- if we've been stuck and unable to reach next marker? Ignore nearby stuff and pick another target
        elseif self.LastPosition and VDist2Sq(self.LastPosition[1], self.LastPosition[3], pos[1], pos[3]) < (self.PlatoonData.StuckDistance or 32) then
            stuckCount = stuckCount + 1
            if stuckCount >= 3 then
                self:StopAttack()
                cmdQ = AIPlatoonSquadAttackVector(aiBrain, self, false)
                stuckCount = 0
            end
        else
            stuckCount = 0
        end

        self.LastPosition = pos
			
        if TableEmpty(cmdQ) then
            WaitSeconds(10)
        else
			-- Wait a little longer if we're stuck so that we have a better chance to move
			WaitSeconds(10 + 2 * stuckCount)
		end
	end
end

--- Function: HuntAI
--- Very basic attack logic, preferably for Air platoons, attack-moves to the nearest enemy unit the platoon can find
---@param self Platoon
function HuntAI(platoon)
    platoon:Stop()
    local aiBrain = platoon:GetBrain()
    local armyIndex = aiBrain:GetArmyIndex()
    local target, blip, targetPosition
	
    while aiBrain:PlatoonExists(platoon) do
        target = platoon:FindClosestUnit('Attack', 'Enemy', true, categories.ALLUNITS - categories.WALL)
        if target then
            blip = target:GetBlip(armyIndex)
			targetPosition = target:GetPosition()
			
            platoon:Stop()
            platoon:AggressiveMoveToLocation(targetPosition)
            -- GPG added this to prevent the platoon getting stuck
            platoon:MoveToLocation(AIUtils.RandomLocation(targetPosition[1], targetPosition[3]), false)
        end
        WaitSeconds(15)
    end
end

------------
-- Utilities
------------

-- Types of threat to look at based on composition of platoon
local ThreatTable = {
    Land = 'AntiSurface',
    Water = 'AntiSurface',
    Amphibious = 'AntiSurface',
    Air = 'AntiAir',
}

--- Get the best target on a map based on platoon location
--- uses threat map and returns the center of one of the grids in the threat map
---@param aiBrain AIBrain           # aiBrain to use
---@param platoon Platoon           # platoon to find best target for
---@param bSkipPathability any      # skip check to see if platoon can path to destination
---@return table[]                  # A table representing the location of the best threat target
function GetBestThreatTarget(aiBrain, platoon, bSkipPathability)

    -- This is the primary function for determining what to attack on the map
    -- This function uses two user-specified types of "threats" to determine what to attack


    -- Specify what types of "threat" to attack
    -- Threat isn't just what's threatening, but is a measure of various
    -- strengths in the game.  For example, 'Land' threat is a measure of
    -- how many mobile land units are in a given threat area
    -- Economy is a measure of how many economy-generating units there are
    -- in a given threat area
    -- Overall is a sum of all the types of threats
    -- AntiSurface is a measure of  how much damage the units in an area can
    -- do to surface-dwelling units.
    -- there are many other types of threat... CATCH THEM ALL

    local PrimaryTargetThreatType = 'Land'
    local SecondaryTargetThreatType = 'Economy'


    -- These are the values that are used to weight the two types of "threats"
    -- primary by default is weighed most heavily, while a secondary threat is
    -- weighed less heavily
    local PrimaryThreatWeight = 20
    local SecondaryThreatWeight = 0.5

    -- After being sorted by those two types of threats, the places to attack are then
    -- sorted by distance.  So you don't have to worry about specifying that units go
    -- after the closest valid threat - they do this naturally.

    -- If the platoon we're sending is weaker than a potential target, lower
    -- the desirability of choosing that target by this factor
    local WeakAttackThreatWeight = 8 --10

    -- If the platoon we're sending is stronger than a potential target, raise
    -- the desirability of choosing that target by this factor
    local StrongAttackThreatWeight = 8


    -- We can also tune the desirability of a target based on various
    -- distance thresholds.  The thresholds are very near, near, mid, far
    -- and very far.  The Radius value represents the largest distance considered
    -- in a given category; the weight is the multiplicative factor used to increase
    -- the desirability for the distance category

    local VeryNearThreatWeight = 20000
    local VeryNearThreatRadius = 25

    local NearThreatWeight = 2500
    local NearThreatRadius = 75

    local MidThreatWeight = 500
    local MidThreatRadius = 150

    local FarThreatWeight = 100
    local FarThreatRadius = 300

    -- anything that's farther than the FarThreatRadius is considered VeryFar
    local VeryFarThreatWeight = 1

    -- if the platoon is weaker than this threat level, then ignore stronger targets if they're stronger by
    -- the given ratio
    --DUNCAN - Changed from 5
    local IgnoreStrongerTargetsIfWeakerThan = 10
    local IgnoreStrongerTargetsRatio = 10.0
    -- If the platoon is weaker than the target, and the platoon represents a
    -- larger fraction of the unitcap this this value, then ignore
    -- the strength of target - the platoon's death brings more units
    local IgnoreStrongerUnitCap = 0.8

    -- When true, ignores the commander's strength in determining defenses at target location
    local IgnoreCommanderStrength = true

    -- If the combined threat of both primary and secondary threat types
    -- is less than this level, then just outright ignore it as a threat
    local IgnoreThreatLessThan = 15
    -- if the platoon is stronger than this threat level, then ignore weaker targets if the platoon is stronger
    local IgnoreWeakerTargetsIfStrongerThan = 20

    -- When evaluating threat, how many rings in the threat grid do we look at
    local EnemyThreatRings = 1
    -- if we've already chosen an enemy, should this platoon focus on that enemy
    local TargetCurrentEnemy = true

    -----------------------------------------------------------------------------------

    local platoonPosition = platoon:GetPlatoonPosition()
    local selectedWeaponArc = 'None'

    if not platoonPosition then
        --Platoon no longer exists.
        return false
    end

    -- Need to use overall so we can get all the threat points on the map and then filter from there
    -- If a specific threat is used, it will only report back threat locations of that type
    local threatTable = aiBrain:GetThreatsAroundPosition(platoonPosition, 16, true, 'Overall')

    if TableEmpty(threatTable) then
        return false
    end

    -- Evaluate platoon threat
    local myThreat = AIAttackUtils.GetThreatOfUnits(platoon)
    local friendlyThreat = aiBrain:GetThreatAtPosition(platoonPosition, 1, true, ThreatTable[platoon.MovementLayer], aiBrain:GetArmyIndex()) - myThreat
	
	--local friendlyThreat = platoon:GetPlatoonThreat(ThreatTable[platoon.MovementLayer], categories.ALLUNITS, platoonPosition, 45)
    friendlyThreat = friendlyThreat * -1

    local threatDist
    local curMaxThreat = -99999999
    local curMaxIndex = 1
    local foundPathableThreat = false
    local mapSizeX = ScenarioInfo.size[1]
    local mapSizeZ = ScenarioInfo.size[2]
    local maxMapLengthSq = math.sqrt((mapSizeX * mapSizeX) + (mapSizeZ * mapSizeZ))
    local logCount = 0

    local unitCapRatio = GetArmyUnitCostTotal(aiBrain:GetArmyIndex()) / GetArmyUnitCap(aiBrain:GetArmyIndex())

    local maxRange = false
    local turretPitch = nil
    if platoon.MovementLayer == 'Water' then
        maxRange, selectedWeaponArc = AIAttackUtils.GetNavalPlatoonMaxRange(aiBrain, platoon)
    end

    for tIndex, threat in threatTable do
        -- Check if we can path to the position or a position nearby
        if not bSkipPathability then
            if platoon.MovementLayer != 'Water' then
                local success, bestGoalPos = AIAttackUtils.CheckPlatoonPathingEx(platoon, {threat[1], 0, threat[2]})
                logCount = logCount + 1
                if not success then

                    local okThresholdSq = 32 * 32
                    local distSq = (threat[1] - bestGoalPos[1]) * (threat[1] - bestGoalPos[1]) + (threat[2] - bestGoalPos[3]) * (threat[2] - bestGoalPos[3])

                    if distSq < okThresholdSq then
                        threat[1] = bestGoalPos[1]
                        threat[2] = bestGoalPos[3]
                    else
                        continue
                    end
                else
                    threat[1] = bestGoalPos[1]
                    threat[2] = bestGoalPos[3]
                end
            else
                local bestPos = AIAttackUtils.CheckNavalPathing(aiBrain, platoon, {threat[1], 0, threat[2]}, maxRange, selectedWeaponArc)
                if not bestPos then
                    continue
                end
            end
        end

        -- Threat[3] represents the best target

        -- Calculate new threat for debugging
        --------------------------------
        local baseThreat = 0
        local targetThreat = 0
        local distThreat = 0

        local primaryThreat = 0
        local secondaryThreat = 0
        ----------------------------------

        -- Determine the value of the target
        primaryThreat = aiBrain:GetThreatAtPosition({threat[1], 0, threat[2]}, 1, true, PrimaryTargetThreatType)
        secondaryThreat = aiBrain:GetThreatAtPosition({threat[1], 0, threat[2]}, 1, true, SecondaryTargetThreatType)

        baseThreat = primaryThreat + secondaryThreat

        targetThreat = (primaryThreat or 0) * PrimaryThreatWeight + (secondaryThreat or 0) * SecondaryThreatWeight
        threat[3] = targetThreat

        -- Determine relative strength of platoon compared to enemy threat
        local enemyThreat = aiBrain:GetThreatAtPosition({threat[1], 0, threat[2]}, EnemyThreatRings, true, ThreatTable[platoon.MovementLayer] or 'AntiSurface')
        if IgnoreCommanderStrength then
            enemyThreat = enemyThreat - aiBrain:GetThreatAtPosition({threat[1], 0, threat[2]}, EnemyThreatRings, true, 'Commander')
        end
        -- Defaults to no threat (threat difference is opposite of platoon threat)
        local threatDiff =  myThreat - enemyThreat

        --DUNCAN - Moved outside threatdiff check
        -- If we have no threat... what happened?  Also don't attack things way stronger than us
        if myThreat <= IgnoreStrongerTargetsIfWeakerThan
                and (myThreat == 0 or enemyThreat / (myThreat + friendlyThreat) > IgnoreStrongerTargetsRatio)
                and unitCapRatio < IgnoreStrongerUnitCap then
            continue
        end

        if threatDiff <= 0 then
            -- If we're weaker than the enemy... make the target less attractive anyway
            threat[3] = threat[3] + threatDiff * WeakAttackThreatWeight
        else
            -- Ignore overall threats that are really low, otherwise we want to defeat the enemy wherever they are
            if (baseThreat <= IgnoreThreatLessThan) then
                continue
            end
            threat[3] = threat[3] + threatDiff * StrongAttackThreatWeight
        end

        -- Only add distance if there's a threat at all
        local threatDistNorm = -1
        if targetThreat > 0 then
            threatDist = math.sqrt(VDist2Sq(threat[1], threat[2], platoonPosition[1], platoonPosition[3]))
            -- Distance is 1-100 of the max map length, distance function weights are split by the distance radius

            threatDistNorm = 100 * threatDist / maxMapLengthSq
            if threatDistNorm < 1 then
                threatDistNorm = 1
            end
            -- farther away is less threatening, so divide
            if threatDist <= VeryNearThreatRadius then
                threat[3] = threat[3] + VeryNearThreatWeight / threatDistNorm
                distThreat = VeryNearThreatWeight / threatDistNorm
            elseif threatDist <= NearThreatRadius then
                threat[3] = threat[3] + MidThreatWeight / threatDistNorm
                distThreat = MidThreatWeight / threatDistNorm
            elseif threatDist <= MidThreatRadius then
                threat[3] = threat[3] + NearThreatWeight / threatDistNorm
                distThreat = NearThreatWeight / threatDistNorm
            elseif threatDist <= FarThreatRadius then
                threat[3] = threat[3] + FarThreatWeight / threatDistNorm
                distThreat = FarThreatWeight / threatDistNorm
            else
                threat[3] = threat[3] + VeryFarThreatWeight / threatDistNorm
                distThreat = VeryFarThreatWeight / threatDistNorm
            end

            -- store max value
            if threat[3] > curMaxThreat then
                curMaxThreat = threat[3]
                curMaxIndex = tIndex
            end
            foundPathableThreat = true
       end -- ignoreThreat
    end -- threatTable loop

    -- No pathable threat found (or no threats at all)
    if not foundPathableThreat or curMaxThreat == 0 then
        return false
    end
    local x = threatTable[curMaxIndex][1]
    local y = GetTerrainHeight(threatTable[curMaxIndex][1], threatTable[curMaxIndex][2])
    local z = threatTable[curMaxIndex][2]
	
    return {x, y, z}
end

--- Gets the path to a naval marker with the highest threat.
--- TODO: Add support for PlatoonData specifying markers to use
---@param aiBrain AIBrain       # aiBrain to use
---@param platoon Platoon       # platoon to find best target for
---@return Vector[]             # A table representing the path
function AINavalPlanB(aiBrain, platoon)
    -- Get a random naval area and issue a movement thar.
    local navalAreas = AIUtils.AIGetMarkerLocations(aiBrain, 'Naval Link')
    platoon.PlatoonSurfaceThreat = platoon:GetPlatoonThreat('Surface', categories.ALLUNITS)
	local path
	
	-- If no Naval Area markers are present on the map, return false
	if not navalAreas or TableEmpty(navalAreas) then
		return false
	end
	-- Pick the first position as the default, compare the rest with that
	local bestLocation = table.random(navalAreas).Position
    local threat = aiBrain:GetThreatAtPosition(bestLocation, 1, true, 'AntiSurface')

    for _, marker in navalAreas do
		local tempThreat = aiBrain:GetThreatAtPosition(marker.Position, 1, true, 'AntiSurface')
        WaitTicks(1)
		
        if tempThreat > threat then
            bestLocation = marker.position
            threat = tempThreat
			
			-- If we can path to this position, generate a safe path or just return with the marker's position
			if NavUtils.CanPathTo(platoon.MovementLayer, platoon:GetPlatoonPosition(), marker.Position) then
				path = NavUtils.PathToWithThreatThreshold(platoon.MovementLayer, platoon:GetPlatoonPosition(), marker.Position, aiBrain, NavUtils.ThreatFunctions.AntiSurface, platoon.PlatoonSurfaceThreat * 10, aiBrain.IMAPConfig.Rings)
					or {marker.Position}
			end
        end
    end
	
	return path
end

--- Generate the attack vector by picking a good place to attack returns the current command queue of all the units in the platoon if it worked or an empty queue if it didn't. Simpler than the land version of this.
---@param aiBrain AIBrain       # aiBrain to use
---@param platoon Platoon       # platoon to find best target for
---@return table                # A table of every command in every command queue for every unit in the platoon or an empty table if it fails
function AIPlatoonNavalAttackVector(aiBrain, platoon)
    AIAttackUtils.GetMostRestrictiveLayer(platoon)
	
    -- Engine handles whether or not we can occupy our vector now, so this should always be a valid, occupiable spot.
    local attackPos = GetBestThreatTarget(aiBrain, platoon)
    if not platoon.PlatoonSurfaceThreat then
        platoon.PlatoonSurfaceThreat = platoon:GetPlatoonThreat('Surface', categories.ALLUNITS)
    end

    local oldPathSize = TableGetn(platoon.LastAttackDestination)
    local path

    -- if we don't have an old path or our old destination and new destination are different
    if attackPos and (oldPathSize == 0 or attackPos[1] != platoon.LastAttackDestination[oldPathSize][1] or attackPos[3] != platoon.LastAttackDestination[oldPathSize][3]) then

        -- check if we can path to here safely... give a large threat weight to sort by threat first
        path = NavUtils.PathToWithThreatThreshold(platoon.MovementLayer, platoon:GetPlatoonPosition(), attackPos, aiBrain, NavUtils.ThreatFunctions.AntiSurface, platoon.PlatoonSurfaceThreat * 10, aiBrain.IMAPConfig.Rings)
			or NavUtils.PathTo(platoon.MovementLayer, platoon:GetPlatoonPosition(), attackPos)

        -- clear command queue
        platoon:Stop()

    end

    if not path or TableEmpty(path) then
        path = AINavalPlanB(aiBrain, platoon)
	end
	
	if path and not TableEmpty(path) then
        platoon.LastAttackDestination = path
        -- move to new location
        platoon:IssueAggressiveMoveAlongRoute(path)
    end

    -- return current command queue
    local cmd = {}
    for k, v in platoon:GetPlatoonUnits() do
        if not v.Dead then
            local unitCmdQ = v:GetCommandQueue()
            for cmdIdx, cmdVal in unitCmdQ do
                table.insert(cmd, cmdVal)
                break
            end
        end
    end
	
    return cmd
end

--- Generate the attack vector by picking a good place to attack, returns the current command queue of all the units in the platoon if it worked, or an empty queue if it didn't
---@param aiBrain AIBrain       # aiBrain to use
---@param platoon Platoon       # platoon to find best target for
---@param bAggro bool           # Bool if we want the platoon to attack-move via the path we didn't use transports to get to
---@return table                # A table of every command in every command queue for every unit in the platoon or an empty table if it fails
function AIPlatoonSquadAttackVector(aiBrain, platoon, bAggro)
    -- Engine handles whether or not we can occupy our vector now, so this should always be a valid, occupiable spot.
    local attackPos = GetBestThreatTarget(aiBrain, platoon)
    if not platoon.PlatoonSurfaceThreat then
        platoon.PlatoonSurfaceThreat = platoon:GetPlatoonThreat('Surface', categories.ALLUNITS)
    end

    local bNeedTransports = false
	
    -- If we don't have an attack position, ignore layer restrictions
    if not attackPos then
        attackPos = GetBestThreatTarget(aiBrain, platoon, true)
        bNeedTransports = true
		
		-- If we still don't have an attack position, get the default highest threat position, and use that.
        if not attackPos then
            attackPos, threat = aiBrain:GetHighestThreatPosition(1, true)
			if not attackPos or 0 >= threat then
				platoon:StopAttack()
				return {}
			end
        end
    end


    -- Avoid mountains by slowly moving away from higher areas
    AIAttackUtils.GetMostRestrictiveLayer(platoon)
    if platoon.MovementLayer == 'Land' then
        local bestPos = attackPos
        local attackPosHeight = GetTerrainHeight(attackPos[1], attackPos[3])
        -- if we're land
        if attackPosHeight >= GetSurfaceHeight(attackPos[1], attackPos[3]) then
            local lookAroundTable = {1,0,-2,-1,2}
            local squareRadius = (ScenarioInfo.size[1] / 16) / TableGetn(lookAroundTable)
            for ix, offsetX in lookAroundTable do
                for iz, offsetZ in lookAroundTable do
                    local surf = GetSurfaceHeight(bestPos[1]+offsetX, bestPos[3]+offsetZ)
                    local terr = GetTerrainHeight(bestPos[1]+offsetX, bestPos[3]+offsetZ)
                    -- Is it lower land... make it our new position to continue searching around
                    if terr >= surf and terr < attackPosHeight then
                        bestPos[1] = bestPos[1] + offsetX
                        bestPos[3] = bestPos[3] + offsetZ
                        attackPosHeight = terr
                    end
                end
            end
        end
        attackPos = bestPos
    end

    local oldPathSize = TableGetn(platoon.LastAttackDestination)

    -- if we don't have an old path or our old destination and new destination are different
    if oldPathSize == 0 or attackPos[1] != platoon.LastAttackDestination[oldPathSize][1] or attackPos[3] != platoon.LastAttackDestination[oldPathSize][3] then

        AIAttackUtils.GetMostRestrictiveLayer(platoon)
        -- Generate path with threat weight if possible, or just a straight path
		local position = platoon:GetPlatoonPosition()
        local path, reason = NavUtils.PathToWithThreatThreshold(platoon.MovementLayer, position, attackPos, aiBrain, NavUtils.ThreatFunctions.AntiSurface, platoon.PlatoonSurfaceThreat * 10, aiBrain.IMAPConfig.Rings)
			or NavUtils.PathTo(platoon.MovementLayer, position, attackPos)

        -- Clear command queue
        platoon:Stop()

        local usedTransports = false
		-- Try transports if we can't path to our destination, or the target is at least 500 units away
        if (not path and reason == 'Unpathable') or bNeedTransports or VDist2Sq(position[1], position[3], attackPos[1], attackPos[3]) > 512*512 then
			usedTransports = SendPlatoonWithTransportsNoCheck(aiBrain, platoon, attackPos)
        end
		
		-- If we couldn't grab transports, try moving anyway
        if not usedTransports then
			-- We couldn't path there, just try moving straight at the target
            if not path or TableEmpty(path) then
				platoon:AggressiveMoveToLocation(attackPos)
				-- Force re-evaluation
				platoon.LastAttackDestination = {attackPos}
            else
                -- Store path
                platoon.LastAttackDestination = path
                -- Move via the path
                if bAggro then
                    platoon:IssueAggressiveMoveAlongRoute(path)
                else
                    platoon:IssueMoveAlongRoute(path)
                end
            end
        end
    end

    -- return current command queue
    local cmd = {}
    for k,v in platoon:GetPlatoonUnits() do
        if not v.Dead then
            local unitCmdQ = v:GetCommandQueue()
            for cmdIdx,cmdVal in unitCmdQ do
                table.insert(cmd, cmdVal)
                break
            end
        end
    end
    return cmd
end

--- TODO: Refactor this to somewhat resemble LandAssaultWithTransports from the map's CustomFunctions.lua, no need to overcomplicate things
---@param aiBrain AIBrain
---@param platoon Platoon
---@param destination Vector
---@param bRequired any
---@return boolean
function SendPlatoonWithTransportsNoCheck(aiBrain, platoon, destination)

    AIAttackUtils.GetMostRestrictiveLayer(platoon)
    local data = platoon.PlatoonData

    -- only get transports for land (or partial land) movement
    if platoon.MovementLayer == 'Land' or platoon.MovementLayer == 'Amphibious' then

        -- Account for the destination being on water, we don't want to drop land units to the bottom of the sea
        if platoon.MovementLayer == 'Land' then
            local terrain = GetTerrainHeight(destination[1], destination[3])
            local surface = GetSurfaceHeight(destination[1], destination[3])
            if terrain < surface then
                return false
            end
        end

        -- Return false if we couldn't grab transports
        if not CustomFunctions.GetLoadTransports(platoon) then
			return false
		end

        -- Presumably, if we're here, we've gotten transports
        local transportLocation = false
		local landingPositions = {}

		-- If we specified potential landing positions, make landing positions out of chain, markers, or marker names
		-- This is entirely assuming that our chosen target is near our specified positions, which might not be true
		if data.LandingChain then
			landingPositions = ScenarioUtils.ChainToPositions(data.LandingChain)
		elseif data.LandingList then
			for _, v in data.LandingList do
				if type(v) == 'string' then
					table.insert(landingPositions, ScenarioUtils.MarkerToPosition(v))
				else
					table.insert(landingPositions, v)
				end
			end
		-- If we didn't specify them, get markers around the target location, and pick the safest
		else
			local markerTypes = {'Land Path Node', 'Transport Marker'}
			
			-- If the platoon is amphibious, check for those marker types as well
			if platoon.MovementLayer == 'Amphibious' then
				table.insert(markerTypes, 'Amphibious')
			end
			
			-- Insert marker locations by category into the landing positions table, then pick the safest one.
			for _, markerType in markerTypes do
				table.cat(landingPositions, AIUtils.AIGetMarkersAroundLocation(aiBrain, markerType, destination, 125))
			end
		end
		
		if not TableEmpty(landingPositions) then
			transportLocation = CustomFunctions.BrainChooseLowestThreatLocation(aiBrain, landingPositions, 1, 'AntiAir')
		end
		
        -- If we couldn't find any valid landing position, just pick the closest
        if not transportLocation then
            transportLocation = AIUtils.AIGetClosestMarkerLocation(aiBrain, 'Transport Marker', destination[1], destination[3])
				or AIUtils.AIGetClosestMarkerLocation(aiBrain, 'Land Path Node', destination[1], destination[3]) or AIUtils.RandomLocation(destination[1], destination[3])
        end
		
		-- Account for the magical possibility of no valid transport location
		if not transportLocation then
			WARN('CUSTOM AIATTACKUTILITIES WARNING: No transportLocation found for platoon.')
			return false
		end
		
        if transportLocation then
            local minThreat = aiBrain:GetThreatAtPosition(transportLocation, 0, true)
            if minThreat > 0 then
                local threatTable = aiBrain:GetThreatsAroundPosition(transportLocation, 1, true, 'Overall')
                for threatIdx, threatEntry in threatTable do
                    if threatEntry[3] < minThreat then
                        -- If it's land...
                        local terrain = GetTerrainHeight(threatEntry[1], threatEntry[2])
                        local surface = GetSurfaceHeight(threatEntry[1], threatEntry[2])
                        if terrain >= surface  then
                           minThreat = threatEntry[3]
                           transportLocation = {threatEntry[1], terrain, threatEntry[2]}
                       end
                    end
                end
            end
        end
		
		local path, reason = NavUtils.PathToWithThreatThreshold(platoon.MovementLayer, transportLocation, destination, aiBrain, NavUtils.ThreatFunctions.AntiSurface, platoon.PlatoonSurfaceThreat * 10, aiBrain.IMAPConfig.Rings)
		
		-- Platoon is fully loaded on transports, let's begin our great journey!
		local PlatoonPosition = platoon:GetPlatoonPosition()
		local cmd
		
		-- While we are not close enough, re-evaluate our path to the drop zone
		-- We are not updating the drop zone here, would take too much code refactoring
		while VDist2(PlatoonPosition[1], PlatoonPosition[3], transportLocation[1], transportLocation[3]) > 105 and not TableEmpty(platoon:GetSquadUnits('Scout')) do
			platoon:Stop()
	
			-- Transports get the 'Scout' role, if other units got it as well, you damn well better change it to something else
			local threatMax = 10
			local transportNum = TableGetn(platoon:GetSquadUnits('Scout')) or 1
			
			threatMax = transportNum * 10
			
			-- Generate a safe path
			local TransportPath = NavUtils.PathToWithThreatThreshold('Air', PlatoonPosition, transportLocation, aiBrain, NavUtils.ThreatFunctions.AntiAir, threatMax, aiBrain.IMAPConfig.Rings)
		
			if TransportPath then
				ScenarioFramework.PlatoonMoveRoute(platoon, TransportPath)
			end
	
			-- Unload platoon at landing location
			cmd = platoon:UnloadAllAtLocation(transportLocation)
			WaitSeconds(10)
		
			if not aiBrain:PlatoonExists(platoon) then
				return false
			end
		
			-- Update platoon position
			PlatoonPosition = platoon:GetPlatoonPosition()
		
			-- If we are surrounded by too much air threat, then fuck it, make a run for our last landing position
			if aiBrain:GetThreatAtPosition(PlatoonPosition, 1, true, 'AntiAir') > threatMax  then
				platoon:Stop()
				cmd = platoon:UnloadAllAtLocation(transportLocation)
				break
			end
		end
	
		-- If we are already close enough to our destination, just unload
		if not cmd then
			cmd = platoon:UnloadAllAtLocation(transportLocation)
		end
	
		-- Wait until the units are dropped
		while platoon:IsCommandsActive(cmd) do
			WaitSeconds(1)
			if not aiBrain:PlatoonExists(platoon) then
				return false
			end
		end
		
		-- Send transports back to base if desired, otherwise stay with the land platoon
		if data.TransportReturn then
			CustomFunctions.ReturnTransportsToPool(platoon)
		end

        -- We've unloaded at this point, let's shoot stuff
        if not path or TableEmpty(path) then
            -- If no path, then just move straight at the enemy
            platoon:AggressiveMoveToLocation(destination)
            platoon.LastAttackDestination = {destination}
        else
            -- We've got a path, let's do some fancy manouvers, and store our path for future comparison
            platoon.LastAttackDestination = path

            local pathSize = TableGetn(path)
            -- Move through the path, and attack-move to the final location if desired
            for wpidx, waypointPath in path do
                if wpidx == pathSize then
                    platoon:AggressiveMoveToLocation(waypointPath)
                else
                    platoon:MoveToLocation(waypointPath, false)
                end
            end
        end
    else
        return false
    end

    return true
end