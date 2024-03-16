-------------------------------------------------------------------------------
--  File     : SCCA_Coop_R06_AIBehaviors.lua
--  Author(s): Dhomie42
--  Summary  : Skirmish-like AI threads, used AIBehaviors.lua as a base
-------------------------------------------------------------------------------
local AIBehaviors = import("/lua/ai/aibehaviors.lua")
local TriggerFile = import("/lua/scenariotriggers.lua")

--- Table: SurfacePriorities AKA "Your stuff just got wrecked" priority list.
--- Description: Provides a list of target priorities an experimental should use when wrecking stuff or deciding what stuff should be wrecked next.
local SurfacePriorities = {
    'COMMAND',
    'EXPERIMENTAL ENERGYPRODUCTION STRUCTURE',
    'TECH3 ENERGYPRODUCTION STRUCTURE',
    'TECH2 ENERGYPRODUCTION STRUCTURE',
    'TECH3 MASSEXTRACTION STRUCTURE',
    'TECH3 INTELLIGENCE STRUCTURE',
    'TECH2 INTELLIGENCE STRUCTURE',
    'TECH1 INTELLIGENCE STRUCTURE',
    'TECH3 SHIELD STRUCTURE',
    'TECH2 SHIELD STRUCTURE',
    'TECH2 MASSEXTRACTION STRUCTURE',
    'TECH3 FACTORY LAND STRUCTURE',
    'TECH3 FACTORY AIR STRUCTURE',
    'TECH3 FACTORY NAVAL STRUCTURE',
    'TECH2 FACTORY LAND STRUCTURE',
    'TECH2 FACTORY AIR STRUCTURE',
    'TECH2 FACTORY NAVAL STRUCTURE',
    'TECH1 FACTORY LAND STRUCTURE',
    'TECH1 FACTORY AIR STRUCTURE',
    'TECH1 FACTORY NAVAL STRUCTURE',
    'TECH1 MASSEXTRACTION STRUCTURE',
    'TECH3 STRUCTURE',
    'TECH2 STRUCTURE',
    'TECH1 STRUCTURE',
    'TECH3 MOBILE LAND',
    'TECH2 MOBILE LAND',
    'TECH1 MOBILE LAND',
    'EXPERIMENTAL LAND',
}
--- Determines if the platoon is in water
--- @param platoon Platoon
--- @return boolean
function InWaterCheck(platoon)
    local t4Pos = platoon:GetPlatoonPosition()
    local inWater = GetTerrainHeight(t4Pos[1], t4Pos[3]) < GetSurfaceHeight(t4Pos[1], t4Pos[3])
    return inWater
end

--- Finds a unit in the base we're currently wrecking.
--- Returns with unit to wreck, and the base, or nil.
--- @param platoon Platoon
--- @param base Vector, Location of the base to wreck
--- @return unit, position
WreckBase = function(self, base)
    for _, priority in SurfacePriorities do
        local numUnitsAtBase = 0
        local notDeadUnit = false
        local unitsAtBase = self:GetBrain():GetUnitsAroundPoint(ParseEntityCategory(priority), base, 100, 'Enemy')
        for _, unit in unitsAtBase do
            if not unit.Dead then
                notDeadUnit = unit
                numUnitsAtBase = numUnitsAtBase + 1
            end
        end

        if numUnitsAtBase > 0 then
            return notDeadUnit, base
        end
    end
	return false
end

--- Callback function when an Experimental Mobile Factory's external factory starts building
---@param@ unit Unit
---@param unitBeingBuilt Unit being constructed
function ExperimentalOnStartBuild(unit, unitBeingBuilt)
	-- The Mobile Factory is set as the external factory's parent, we can access it that way.
	local experimental = unit.OriginUnit
	local aiBrain = unit:GetAIBrain()
	
	unitBeingBuilt.ExperimentalCreator = experimental
	
	-- Add callback when the unit has been built
	if not unitBeingBuilt.AddedFinishedCallback then
		unitBeingBuilt:AddUnitCallback(UnitOnStopBeingBuilt, 'OnStopBeingBuilt')
		unitBeingBuilt.AddedFinishedCallback = true
	end
end

--- Callback function when the Experimental Mobile Factory's produced unit has been built
--- Assigns the unit to a platoon, and issues a guard order on the experimental it belongs to
---@param unit Unit
function UnitOnStopBeingBuilt(unit)
	local experimental = unit.ExperimentalCreator
	local aiBrain = unit:GetAIBrain()
	-- *Issue* engine commands in most cases require a table as 1st parameter, even if it's just a single unit
	local unitTable = {unit}
	
	-- We need to wait a tick for the initial rolloff move order to be issued, so we can cancel it
	ForkThread(
		function()
			WaitTicks(1)
			if unit.Dead then
				return
			end
			
			if not experimental.NewPlatoon or not aiBrain:PlatoonExists(experimental.NewPlatoon) then
				experimental.NewPlatoon = aiBrain:MakePlatoon('', '')
			end

			if not experimental.Dead then
				aiBrain:AssignUnitsToPlatoon(experimental.NewPlatoon, unitTable, 'Attack', experimental.SetFormation)
				IssueClearCommands(unitTable)
				IssueGuard(unitTable, experimental)
			end
			
			return
		end
	)
end

--- Find a base to attack. Sit outside of the base, and build units.
--- @PlatoonData:
---		@BuildTable 	- Table of string unit BP IDs to choose from, default are Percies, Spearheads, and Titans
---		@Formation 		- String formation, use 'GrowthFormation' or 'AttackFormation', default is 'NoFormation'
---		@UnitCount 		- Number, exact size for the children platoon, high numbers cause cluttering, default is 12
---		@SitDistance 	- Number, distance from the target to begin building from, default is 10
--- @param self Platoon, preferably a single-unit Fatboy platoon
function FatboyBehavior(self)
    local aiBrain = self:GetBrain()
    local experimental = self:GetPlatoonUnits()[1]	
    local Base
	local cmd = false
	local InWater = false
	
	-- Some platoon data to allow customization, but also consider that we don't receive any platoon data
	local PlatoonSize = self.PlatoonData.UnitCount or 12
	local Distance = self.PlatoonData.SitDistance or 10
	
	-- Add callback when the structure starts building something
	if not experimental.ExternalFactory.AddedUpgradeCallback then
		experimental.ExternalFactory:AddOnStartBuildCallback(ExperimentalOnStartBuild)
		experimental.ExternalFactory.AddedUpgradeCallback = true
		-- Cache the actual mobile unit on the external factory
		experimental.ExternalFactory.OriginUnit = experimental
	end
	
    experimental.Platoons = experimental.Platoons or {}
	experimental.SetFormation = self.PlatoonData.Formation or 'NoFormation'
	
	TriggerFile.CreateUnitDestroyedTrigger(HandleFatboyLeftoverGuardingUnits, experimental)
	
	self:Stop()

    -- Let's keep the main loop as simple and code-light as possible
	-- We find a target we'd normally nuke, send our existing child platoons to attack the target, and send our mobile factory to attack the target as well
	-- The Fatboy requires special care because of its amphibious nature, we want it to move if it's in water (no stopping to attack stray boats), or attack-move if it's on land
    while aiBrain:PlatoonExists(self) do
		Base = AIBehaviors.GetHighestThreatClusterLocation(aiBrain, experimental)	--We need a threat location only
		
		if Base then
			-- Send our homies to wreck this base
            local goodList = {}
            for _, platoon in experimental.Platoons do
                local platoonUnits = false

                if aiBrain:PlatoonExists(platoon) then
                    platoonUnits = platoon:GetPlatoonUnits()
                end

                if platoonUnits and not table.empty(platoonUnits) then
                    table.insert(goodList, platoon)
                end
            end

            experimental.Platoons = goodList
            for _, platoon in goodList do
                platoon:ForkAIThread(FatboyChildBehavior, experimental, Base)
            end
			
			-- Siege loop, while the target position has units inside, we move to it and build units, once it's empty, we find a new target
			while aiBrain:PlatoonExists(self) and WreckBase(self, Base) do
				-- Attack-move if we are on land, otherwise move if we are inside water
				if not cmd or (cmd and not self:IsCommandsActive(cmd)) then
					-- The unit's very first command, just check if we need to attack-move, or just move
					if InWaterCheck(self) then
						cmd = self:MoveToLocation(Base, false)
						InWater = true
					else
						cmd = self:AggressiveMoveToLocation(Base)
						InWater = false
					end
				else
				-- We already have a command, if we changed layer, stop, and either move, or attack-move
					if InWater ~= InWaterCheck(self) then
						if InWaterCheck(self) then
							self:Stop()
							cmd = self:MoveToLocation(Base, false)
							InWater = true
						else
							self:Stop()
							cmd = self:AggressiveMoveToLocation(Base)
							InWater = false
						end
					end
				end
				
				local pos = self:GetPlatoonPosition() 
				
				-- Spam units once the Fatboy is close enough to the base, make sure it's NOT in water
				--if not InWaterCheck(self) and Distance >= VDist2(pos[1], pos[3], Base[1], Base[3]) then
				if Distance >= VDist2(pos[1], pos[3], Base[1], Base[3]) then
					ForkThread(FatboyBuildCheck, self)
				end
                -- Once we have enough units, form them into a platoon and send them to attack the bad guys!
                if experimental.NewPlatoon and table.getn(experimental.NewPlatoon:GetPlatoonUnits()) >= PlatoonSize then
                    experimental.NewPlatoon:ForkAIThread(FatboyChildBehavior, experimental, Base)

                    table.insert(experimental.Platoons, experimental.NewPlatoon)
                    experimental.NewPlatoon = nil
                end
				
				-- Short delay to spam units ASAP
                WaitTicks(50)
            end
        end
		self:Stop()
        WaitSeconds(10)
    end
end

--- Builds a random land unit defined in BuildTable, or defaults to Percies, Titans, and Spearheads
--- @param self Platoon, preferably a single-unit Fatboy platoon
function FatboyBuildCheck(self)
	local experimental = self:GetPlatoonUnits()[1]
	local factory = experimental.ExternalFactory
	-- If we're dead, or already building something, return
	if (not experimental or experimental.Dead) or factory:IsUnitState('Building') then
		return
	end
	
	-- Recent FAF patch attached an independent factory entity on mobile factory units, allowing them to build on the move, we can access it like this
	local factory = experimental.ExternalFactory
	
	local data = self.PlatoonData
    local aiBrain = self:GetBrain()
	local unitToBuild = nil

	-- If we received a list of units to build from, let's use that.
	if data.BuildTable then
		unitToBuild = table.random(data.BuildTable)
	-- If we didn't receive a list of units to build from, pick between Titans, Percivals, and Spearheads
	else
		local buildUnits = {'uel0303', 'xel0305', 'xel0306', }
		unitToBuild = table.random(buildUnits)
	end
	
	IssueClearFactoryCommands({factory})
	if factory:CanBuild(unitToBuild) then
		aiBrain:BuildUnit(factory, unitToBuild, 1)
	end
end

--- Fatboy's children platoon AI thread. Wrecks the base that the fatboy has selected.
--- If base is wrecked, the units will guard the fatboy, until a new target base is reached for them to attack.
--- @param self Fatboy's child platoon
--- @param parent Parent Fatboy the child platoon belongs to
--- @param base The base to be attacked
function FatboyChildBehavior(self, parent, base)
    local aiBrain = self:GetBrain()
    local targetUnit = false
	local closestTarget = nil

    -- Find target loop
    while aiBrain:PlatoonExists(self) do
		if base then
			targetUnit, base = WreckBase(self, base)
		end

        if not base then
            -- Wrecked base.
            self:Stop()
			-- Guard parent Fatboy if it is alive, kill the AI thread, the Fatboy will call this function again once a new base is found
			if parent and not parent.Dead then
				IssueGuard(self:GetPlatoonUnits(), parent)
				return
			-- Parent got killed, let's avenge it, attack-move to the closest enemy unit, or self-destruct instead.
			else
				closestTarget = self:FindClosestUnit('Attack', 'Enemy', true, categories.ALLUNITS - categories.WALL)
				-- Closest target found, let's wreck 'em.
				if closestTarget and not closestTarget.Dead then
					LOG('DEBUG: Parent Fatboy has been destroyed, child platoon is attack-moving to the closest enemy.')
					self:Stop()
					self:AggressiveMoveToLocation(closestTarget:GetPosition())
				-- Nothing to commit vengeance on, self-destruct instead.
				else
					LOG('DEBUG: Parent Fatboy has been destroyed, no nearest enemies found, self-destructing.')
					for k, v in self:GetPlatoonUnits() do
						if v and not v.Dead then
							v:Kill()
						end
					end
				end
			end
        end

        if targetUnit and not targetUnit.Dead then
            self:Stop()
            self:AggressiveMoveToLocation(targetUnit:GetPosition())
        end

        -- Walk to and kill target loop
        while aiBrain:PlatoonExists(self) and not targetUnit.Dead do
            WaitSeconds(5)
        end

        WaitSeconds(10)
    end
end

--- Orders all guarding units to attack, or self-destruct if there's nothing to attack.
--- @param unit, Unit
function HandleFatboyLeftoverGuardingUnits(unit)
	local aiBrain = unit:GetAIBrain()
	
	local LeftoverUnits = unit:GetGuards()
	
	if LeftoverUnits and not table.empty(LeftoverUnits) then
		local platoon = aiBrain:MakePlatoon('', '')
		aiBrain:AssignUnitsToPlatoon(platoon, LeftoverUnits, 'Attack', 'NoFormation')
		platoon:ForkAIThread(FatboyChildBehavior, unit)
	end
end

--- Find a base to attack. Sit outside of the base in weapon range and build units.
--- @PlatoonData:
---		@BuildTable 	- Table of string unit BP IDs to choose from, default are Destroyers, and Cruisers
---		@Formation 		- String formation, use 'GrowthFormation' or 'AttackFormation', default is 'NoFormation'
---		@UnitCount 		- Number, exact size for the children platoon, high numbers cause cluttering, default is 10
---		@SitDistance 	- Number, distance from the target to begin building from, it's added to the main weapon range, so don't crazy with this, default is 10
--- @param self Platoon, preferably a single-unit Tempest
function TempestBehavior(self)
    local aiBrain = self:GetBrain()

    local experimental = self:GetPlatoonUnits()[1]
    local Base = false
	local cmd = false
	
	-- Some platoon data to allow customization, but also consider that we don't receive any platoon data
	local PlatoonSize = self.PlatoonData.UnitCount or 6
	
	-- Add callback when the structure starts building something
	if not experimental.ExternalFactory.AddedUpgradeCallback then
		experimental.ExternalFactory:AddOnStartBuildCallback(ExperimentalOnStartBuild)
		experimental.ExternalFactory.AddedUpgradeCallback = true
		-- Cache the actual mobile unit on the external factory
		experimental.ExternalFactory.OriginUnit = experimental
	end

	
    experimental.Platoons = experimental.Platoons or {}
	experimental.SetFormation = self.PlatoonData.Formation or 'NoFormation'
	
	TriggerFile.CreateUnitDestroyedTrigger(HandleTempestLeftoverGuardingUnits, experimental)
	
	self:Stop()
	
	-- Let's keep the main loop as simple and code-light as possible
	-- We find a target we'd normally nuke, send our existing child platoons to attack the target, and send our mobile factory to attack the target as well
    while aiBrain:PlatoonExists(self) do
		Base = AIBehaviors.GetHighestThreatClusterLocation(aiBrain, experimental)	--We need a threat location only
		
		if Base then
			-- Send our homies to wreck this base
            local goodList = {}
            for _, platoon in experimental.Platoons do
                local platoonUnits = false

                if aiBrain:PlatoonExists(platoon) then
                    platoonUnits = platoon:GetPlatoonUnits()
                end

                if platoonUnits and not table.empty(platoonUnits) then
                    table.insert(goodList, platoon)
                end
            end

            experimental.Platoons = goodList
            for _, platoon in goodList do
                platoon:ForkAIThread(TempestChildBehavior, experimental, Base)
            end
			
			-- Siege loop, while the target position has units inside, we move to it and build units, once it's empty, we find a new target
			while aiBrain:PlatoonExists(self) and WreckBase(self, Base) do
				-- Attack-move
				if not cmd or (cmd and not self:IsCommandsActive(cmd)) then
					cmd = self:AggressiveMoveToLocation(Base)
				end
				
				local pos = self:GetPlatoonPosition() 
				
				-- Tempests can spam units as soon as their platoon is formed
				ForkThread(TempestBuildCheck, self)
				
                -- Once we have enough units, form them into a platoon and send them to attack the base we're attacking!
                if experimental.NewPlatoon and table.getn(experimental.NewPlatoon:GetPlatoonUnits()) >= PlatoonSize then
                    experimental.NewPlatoon:ForkAIThread(TempestChildBehavior, experimental, Base)

                    table.insert(experimental.Platoons, experimental.NewPlatoon)
                    experimental.NewPlatoon = nil
                end
				
				-- Short delay to spam units ASAP
                WaitSeconds(5)
            end
        end
        WaitSeconds(10)
		self:Stop()
    end
end

--- Builds a random naval unit defined in BuildTable, or defaults to Destroyers, and Cruisers
--- @param self Platoon, a single-unit Tempest platoon
function TempestBuildCheck(self)
	local experimental = self:GetPlatoonUnits()[1]
	local factory = experimental.ExternalFactory
	-- If we're dead, or already building something, return
	if (not experimental or experimental.Dead) or factory:IsUnitState('Building') then
		return
	end
	
	-- Recent FAF patch attached an independent factory entity on mobile factory units, allowing them to build on the move, we can access it like this
	local factory = experimental.ExternalFactory
	
	local data = self.PlatoonData
    local aiBrain = self:GetBrain()
	local unitToBuild = nil

	--If we received a list of units to build from, let's use that.
	if data.BuildTable then
		unitToBuild = table.random(data.BuildTable)
	--If we didn't receive a list of units to build from, pick Destroyers, and Cruisers
	else
		local buildUnits = {'uas0201', 'uas0202',}
		unitToBuild = table.random(buildUnits)
	end
	
	IssueClearFactoryCommands({factory})
	if factory:CanBuild(unitToBuild) then
		aiBrain:BuildUnit(factory, unitToBuild, 1)
	end
end

--- Tempest's children platoon AI thread. Wrecks the base that the Tempest has selected.
--- If base is wrecked, the units will guard the Tempest, until a new target base is reached for them to attack.
--- @param self Tempest's child platoon
--- @param parent Parent Tempest the child platoon belongs to
--- @param base The base to be attacked
function TempestChildBehavior(self, parent, base)
    local aiBrain = self:GetBrain()
    local targetUnit = false
	local closestTarget = nil

    -- Find target loop
    while aiBrain:PlatoonExists(self) do
		if base then
			targetUnit, base = WreckBase(self, base)
		end

        if not base then
            -- Wrecked base.
            self:Stop()
			-- Guard parent Tempest if it is alive, kill the AI thread, the Tempest will call this function again once a new base is found
			if parent and not parent.Dead then
				IssueGuard(self:GetPlatoonUnits(), parent)
				return
			-- Parent got killed, let's avenge it, attack the closest enemy unit, or self-destruct instead.
			else
				closestTarget = self:FindClosestUnit('Attack', 'Enemy', true, categories.ALLUNITS-categories.WALL)
				-- Closest target found, let's wreck 'em.
				if closestTarget and not closestTarget.Dead then
					SPEW('DEBUG: Parent Tempest has been destroyed, child platoon is attacking the closest enemy.')
					self:Stop()
					self:AttackTarget(closestTarget)
				-- Nothing to commit vengeance on, self-destruct instead.
				else
					SPEW('DEBUG: Parent Tempest has been destroyed, no nearest enemies found, self-destructing.')
					for k, v in self:GetPlatoonUnits() do
						if v and not v.Dead then
							v:Kill()
						end
					end
				end
			end
        end

        if targetUnit and not targetUnit.Dead then
            self:Stop()
			self:AttackTarget(targetUnit)
        end

        -- Sail to and kill target loop
        while aiBrain:PlatoonExists(self) and not targetUnit.Dead do
            WaitSeconds(5)
        end

        WaitSeconds(10)
    end
end

--- Orders all guarding units to attack, or self-destruct if there's nothing to attack.
--- @param unit, Unit
function HandleTempestLeftoverGuardingUnits(unit)
	local aiBrain = unit:GetAIBrain()
	
	local LeftoverUnits = unit:GetGuards()
	
	if LeftoverUnits and not table.empty(LeftoverUnits) then
		local platoon = aiBrain:MakePlatoon('', '')
		aiBrain:AssignUnitsToPlatoon(platoon, LeftoverUnits, 'Attack', 'NoFormation')
		platoon:ForkAIThread(TempestChildBehavior, unit)
	end
end
