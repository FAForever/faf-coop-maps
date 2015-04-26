-- ONLY EDIT THESE VARS 
opID = 'X1CA_Coop_001'						-- should always be in the form 'SCCA_' + faction letter + 2-digit op num, e.g. SCCA_E01
opDesc = '<LOC X1CA_Coop_001_description>Fort Clarke, located on the planet Griffin IV, is the UEF\'s last stronghold. Seraphim and Order forces are attacking the fort with overwhelming force. If Fort Clarke falls, the UEF is finished. You will defeat the enemy commanders on Griffin IV and end the siege of Fort Clarke.'							-- used in op select screen

-- DO NOT EDIT
local opVars = import('/lua/ui/campaign/operationvars.lua').MakeOpVars(opID, 'X', 1)

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