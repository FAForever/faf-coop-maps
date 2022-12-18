-- ****************************************************************************
-- **
-- **  File     :  /maps/SCCA_Coop_E01/SCCA_Coop_E01_operation.lua
-- **  Author(s):  Evan Pongress
-- **
-- **  Summary  :  Operation data for OpE1
-- **
-- **  Copyright © 2006 Gas Powered Games, Inc.  All rights reserved.
-- ****************************************************************************

local OpStrings = import('/maps/SCCA_Coop_E01/SCCA_Coop_E01_strings.lua')

operationData = 
{
    key = 'SCCA_Coop_E01',
    feedbackURL = 'http://forums.faforever.com/viewtopic.php?f=78&t=13898',
    opName = OpStrings.OPERATION_NAME,
    opDesctiption = OpStrings.OPERATION_DESCRIPTION,
    opBriefing = OpStrings.BriefingData,
    opMovies = OpStrings.OperationMovies,
    opDebriefingSuccess = OpStrings.E01_DB01_010,
    opDebriefingFailure = OpStrings.E01_DB01_020,
}