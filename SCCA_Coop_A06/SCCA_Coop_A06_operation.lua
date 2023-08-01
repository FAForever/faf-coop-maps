-- ****************************************************************************
-- **
-- **  File     :  /maps/SCCA_Coop_A06/SCCA_Coop_A06_operation.lua
-- **  Author(s):  Evan Pongress
-- **
-- **  Summary  :  Operation data for OpA6
-- **
-- **  Copyright © 2006 Gas Powered Games, Inc.  All rights reserved.
-- ****************************************************************************

local OpStrings = import('/maps/SCCA_Coop_A06/SCCA_Coop_A06_strings.lua')

operationData = 
{
    key = 'SCCA_Coop_A06',
    feedbackURL = 'http://forums.faforever.com/viewtopic.php?f=78&t=13897',
    opName = OpStrings.OPERATION_NAME,
    opDesctiption = OpStrings.OPERATION_DESCRIPTION,
    opBriefing = OpStrings.BriefingData,
    opMovies = OpStrings.OperationMovies,
    opDebriefingSuccess = OpStrings.A06_DB01_010,
    opDebriefingFailure = OpStrings.A06_DB01_020,
}