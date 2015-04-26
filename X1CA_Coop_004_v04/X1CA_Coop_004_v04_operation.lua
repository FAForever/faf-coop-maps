# ONLY EDIT THESE VARS 
opID = 'X1CA_Coop_004_v04'						# should always be in the form 'SCCA_' + faction letter + 2-digit op num, e.g. SCCA_E01
opDesc = '<LOC X1CA_Coop_004_v04_description>Coalition Command has received unverified intel that the Seraphim are massing on the planet Hades -- control of Hades will let the Seraphim attack any location within Coalition-controlled space. Elite Commander Dostya will join you for this mission, and the two of you will eliminate any Seraphim forces found on Hades.'							# used in op select screen

# DO NOT EDIT
local opVars = import('/lua/ui/campaign/operationvars.lua').MakeOpVars(opID, 'X', 4)

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