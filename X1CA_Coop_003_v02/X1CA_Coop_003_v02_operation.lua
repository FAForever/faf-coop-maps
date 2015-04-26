# ONLY EDIT THESE VARS 
opID = 'X1CA_Coop_003_v02'						# should always be in the form 'SCCA_' + faction letter + 2-digit op num, e.g. SCCA_E01
opDesc = '<LOC X1CA_Coop_003_v02_description>Princess Burke has returned, but she is in grave danger. Seraphim forces have her trapped on the planet Blue Sky, and she has no chance of escaping. You will go to Blue Sky, destroy the Seraphim commanders, and save Princess Burke.'							# used in op select screen

# DO NOT EDIT
local opVars = import('/lua/ui/campaign/operationvars.lua').MakeOpVars(opID, 'X', 3)

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