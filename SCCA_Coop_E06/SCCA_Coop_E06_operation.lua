-- ****************************************************************************
-- **
-- **  File     :  /maps/SCCA_Coop_E06/SCCA_Coop_E06_operation.lua
-- **  Author(s):  Evan Pongress
-- **
-- **  Summary  :  Operation data for OpE6
-- **
-- **  Copyright © 2006 Gas Powered Games, Inc.  All rights reserved.
-- ****************************************************************************

local OpStrings = import('/maps/SCCA_Coop_E06/SCCA_Coop_E06_strings.lua')

operationData = 
{
    key = 'SCCA_Coop_E06',
    feedbackURL = 'http://forums.faforever.com/viewtopic.php?f=78&t=13903',
    opName = OpStrings.OPERATION_NAME,
    opDesctiption = OpStrings.OPERATION_DESCRIPTION,
    opBriefing = OpStrings.BriefingData,
    opMovies = OpStrings.OperationMovies,
    opDebriefingSuccess = OpStrings.E06_DB01_010,
    opDebriefingFailure = OpStrings.E06_DB01_020,
}