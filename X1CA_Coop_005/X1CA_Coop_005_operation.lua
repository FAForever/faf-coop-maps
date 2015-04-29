-- ONLY EDIT THESE VARS 
opID = 'X1CA_Coop_005'                        -- should always be in the form 'SCCA_' + faction letter + 2-digit op num, e.g. SCCA_E01
opDesc = '<LOC X1CA_Coop_005_description>Because of the events on Hades, QAI must be destroyed once and for all. Using intelligence acquired from the Seven Hand Node, the Coalition has learned that QAI\'s mainframe is on the planet Pearl II. Your mission is to establish a foothold on Pearl II, thus clearing the way for Dr. Brackman, who will arrive and personally shut down QAI.'                            -- used in op select screen

-- DO NOT EDIT
local opVars = import('/lua/ui/campaign/operationvars.lua').MakeOpVars(opID, 'X', 5)

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
