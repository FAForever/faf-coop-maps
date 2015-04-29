-- ONLY EDIT THESE VARS 
opID = 'X1CA_002'                        -- should always be in the form 'SCCA_' + faction letter + 2-digit op num, e.g. SCCA_E01
opDesc = '<LOC X1CA_002_description>Aeon Loyalists, led by Crusader Rhiza, were captured while conducting sabotage and intelligence missions against Order and QAI positions. You must rescue the Loyalists being held by QAI and defeat all enemy commanders operating on the planet.'                            -- used in op select screen

-- DO NOT EDIT
local opVars = import('/lua/ui/campaign/operationvars.lua').MakeOpVars(opID, 'X', 2)

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
