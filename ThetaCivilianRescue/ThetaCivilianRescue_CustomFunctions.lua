local ScenarioFramework = import('/lua/ScenarioFramework.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')

-----------------
-- Drop Functions
-----------------
function DropUnits(units, DropLocation, TransportDestination, attackChain, indestructibleTransport)
    local brain = 'Cybran'
    local landUnits = {}
    local allTransports = {}
    
    ForkThread(
        function()
            local allUnits
            if type(units) == 'string' then
                allUnits = ScenarioUtils.CreateArmyGroup(brain, units)
            else
                allUnits = units
            end

            for _, unit in allUnits do
                if EntityCategoryContains( categories.TRANSPORTATION, unit ) then
                    if indestructibleTransport then
                        unit:SetCanTakeDamage(false);
                    end
                    table.insert(allTransports, unit )
                else
                    table.insert(landUnits, unit )
                end
            end
            
            for _, transport in allTransports do
                ScenarioFramework.AttachUnitsToTransports(landUnits, {transport})
                WaitSeconds(0.5)
                IssueTransportUnload({transport}, ScenarioUtils.MarkerToPosition(DropLocation))
                IssueMove({transport}, ScenarioUtils.MarkerToPosition(TransportDestination))
                ScenarioFramework.CreateUnitToMarkerDistanceTrigger(DestroyUnit, transport, TransportDestination, 10)
            end

            for _, unit in landUnits do
                while (not unit:IsDead() and unit:IsUnitState('Attached')) do
                    WaitSeconds(.5)
                end
            end
            ScenarioFramework.GroupPatrolChain(landUnits,attackChain)
        end
    )
end

function DestroyUnit(unit)
    unit:Destroy()
end

-- Retruns the units in <area> of <cat>
function GetAllCatUnitsInArea(cat, area)
    if type(area) == 'string' then
        area = ScenarioUtils.AreaToRect(area)
    end
    local entities = GetUnitsInRect(area)
    local result = {}
    if entities then
        result = EntityCategoryFilterDown(cat, entities)
    end

    return result
end

function CreateFocusACUTrigger( unit, cdr, distance, timeBeforeFocus )
    local focusACU = function() 
            LOG('*DEBUG: focustriggered')
            WaitSeconds(timeBeforeFocus)
            IssueClearCommands({unit})
            IssueAttack({unit},cdr)
        end
    ScenarioFramework.CreateUnitDistanceTrigger( focusACU, unit, cdr, distance )
end

-----------------------------
--ALL BELOW IS MADE BY SPEED2
-----------------------------
function CreateMultipleAreaTrigger(callbackFunction, rectangles, category, onceOnly, invert, number, requireBuilt)
    return ForkThread(AreaTriggerThread, callbackFunction, rectangles, category, onceOnly, invert, number, requireBuilt)
end

function CreateAreaTrigger(callbackFunction, rectangle, category, onceOnly, invert, number, requireBuilt)
    return ForkThread(AreaTriggerThread, callbackFunction, {rectangle}, category, onceOnly, invert, number, requireBuilt)
end

function AreaTriggerThread(callbackFunction, rectangleTable, category, onceOnly, invert, number, requireBuilt, name)
    local recTable = {}
    for k,v in rectangleTable do
        if type(v) == 'string' then
            table.insert(recTable,ScenarioUtils.AreaToRect(v))
        else
            table.insert(recTable, v)
        end
    end
    while true do
        local amount = 0
        local totalEntities = {}
        for k, v in recTable do
            local entities = GetUnitsInRect( v )
            if entities then
                for ke, ve in entities do
                    totalEntities[table.getn(totalEntities) + 1] = ve
                end
            end
        end
        local triggered = false
        local triggeringEntity
        local numEntities = table.getn(totalEntities)
        if numEntities > 0 then
            for k, v in totalEntities do
                local contains = EntityCategoryContains(category, v)
                if contains and (not requireBuilt or (requireBuilt and not v:IsBeingBuilt())) then
                    amount = amount + 1
                    -- If we want to trigger as soon as one of a type is in there, kick out immediately.
                    if not number then
                        triggeringEntity = v
                        triggered = true
                        break
                    -- If we want to trigger on an amount, then add the entity into the triggeringEntity table
                    -- so we can pass that table back to the callback function.
                    else
                        if not triggeringEntity then
                            triggeringEntity = {}
                        end
                        table.insert(triggeringEntity, v)
                    end
                end
            end
        end
        -- Check to see if we have a triggering amount inside in the area.
        if number and ((amount >= number and not invert) or (amount < number and invert)) then
            triggered = true
        end
        -- TRIGGER IF:
        -- You don't want a specific amount and the correct unit category entered
        -- You don't want a specific amount, there are no longer the category inside and you wanted the test inverted
        -- You want a specific amount and we have enough.
        if ( triggered and not invert and not number) or (not triggered and invert and not number) or (triggered and number) then
            if name then
                callbackFunction(TriggerManager, name, triggeringEntity)
            else
                callbackFunction(triggeringEntity)
            end
            if onceOnly then
                return
            end
        end
        WaitTicks(1)
    end
end