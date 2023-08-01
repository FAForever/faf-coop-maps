-- ****************************************************************************
-- **
-- **  File     :  /maps/SCCA_Coop_R03/SCCA_Coop_R03_operation.lua
-- **  Author(s):  Evan Pongress
-- **
-- **  Summary  :  Operation data for OpR3
-- **
-- **  Copyright © 2006 Gas Powered Games, Inc.  All rights reserved.
-- ****************************************************************************

local OpStrings = import('/maps/SCCA_Coop_R03/SCCA_Coop_R03_strings.lua')

operationData = 
{
    key = 'SCCA_Coop_R03',
    feedbackURL = 'http://forums.faforever.com/viewtopic.php?f=78&t=13906',
    opName = OpStrings.OPERATION_NAME,
    opDesctiption = OpStrings.OPERATION_DESCRIPTION,
    opBriefing = OpStrings.BriefingData,
    opDebriefingSuccess = OpStrings.R03_DB01_010,
    opDebriefingFailure = OpStrings.R03_DB01_020,
}