-- ****************************************************************************
-- **
-- **  File     :  /maps/scca_coop_r06.v0018/SCCA_Coop_R06_operation.lua
-- **  Author(s):  Evan Pongress
-- **
-- **  Summary  :  Operation data for OpR6
-- **
-- **  Copyright © 2006 Gas Powered Games, Inc.  All rights reserved.
-- ****************************************************************************

local OpStrings = import('/maps/SCCA_Coop_R06/SCCA_Coop_R06_strings.lua')

operationData = 
{
	key = 'SCCA_Coop_R06',
    feedbackURL = 'http://forums.faforever.com/viewtopic.php?f=78&t=13909',
    opName = OpStrings.OPERATION_NAME,
    opDesctiption = OpStrings.OPERATION_DESCRIPTION,
    opBriefing = OpStrings.BriefingData,
    opMovies = OpStrings.OperationMovies,
    opDebriefingSuccess = OpStrings.R06_DB01_010,
    opDebriefingFailure = OpStrings.R06_DB01_020,
}