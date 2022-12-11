-- ****************************************************************************
-- **
-- **  File     :  /maps/SCCA_Coop_R05/SCCA_Coop_R05_operation.lua
-- **  Author(s):  Evan Pongress
-- **
-- **  Summary  :  Operation data for OpR5
-- **
-- **  Copyright © 2006 Gas Powered Games, Inc.  All rights reserved.
-- ****************************************************************************

local OpStrings = import('/maps/SCCA_Coop_R05/SCCA_Coop_R05_strings.lua')

operationData = 
{
    key = 'SCCA_Coop_R05',
    feedbackURL = 'http://forums.faforever.com/viewtopic.php?f=78&t=13908',
    opName = OpStrings.OPERATION_NAME,
    opDesctiption = OpStrings.OPERATION_DESCRIPTION,
    opBriefing = OpStrings.BriefingData,
    opDebriefingSuccess = OpStrings.R05_DB01_010,
    opDebriefingFailure = OpStrings.R05_DB01_020,
}