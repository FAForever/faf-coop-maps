local AIUtils = import('/lua/ai/aiutilities.lua')

--- Build condition
-- Returns true if mass in storage of <aiBrain> is less than <mStorage>
function LessMassStorageCurrent(aiBrain, mStorage)
    local econ = AIUtils.AIGetEconomyNumbers(aiBrain)
    if econ.MassStorage < mStorage then
        return true
    end
    return false
end

