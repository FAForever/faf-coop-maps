-- ONLY EDIT THESE VARS 
opID = 'X1CA_Coop_006'                        -- should always be in the form 'SCCA_' + faction letter + 2-digit op num, e.g. SCCA_E01
opDesc = '<LOC X1CA_Coop_006_description>Using Gate codes recovered from the remains of QAI, Coalition forces can now gate directly to Earth, where the Seraphim are constructing a Quantum Arch. Once complete, the Arch will let the Seraphim summon untold reinforcements. The Arch must be destroyed, no matter the cost.'                            -- used in op select screen

-- DO NOT EDIT
local opVars = import('/lua/ui/campaign/operationvars.lua').MakeOpVars(opID, 'X', 6)

operationData = 
{
    key = opID,
    name = opVars.op_short_name,
    long_name = opVars.op_long_name,
    description = opDesc,
    opNum = opVars.op_num,
    opBriefingText = opVars.op_text,
    opMovies = opVars.op_movies,
    opMap = opVars.op_map,
    opDebriefingSuccess = opVars.op_debrief_success,
    opDebriefingFailure = opVars.op_debrief_failure,
}
