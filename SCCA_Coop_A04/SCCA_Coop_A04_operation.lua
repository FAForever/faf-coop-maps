-- ****************************************************************************
-- **
-- **  File     :  /maps/SCCA_Coop_A04/SCCA_Coop_A04_operation.lua
-- **  Author(s):  Evan Pongress
-- **
-- **  Summary  :  Operation data for OpA4
-- **
-- **  Copyright © 2006 Gas Powered Games, Inc.  All rights reserved.
-- ****************************************************************************

local OpStrings = import('/maps/SCCA_Coop_A04/SCCA_Coop_A04_strings.lua')

operationData = 
{
    key = 'SCCA_Coop_A04',
    feedbackURL = 'http://forums.faforever.com/viewtopic.php?f=78&t=13895',
    opName = OpStrings.OPERATION_NAME,
    opDesctiption = OpStrings.OPERATION_DESCRIPTION,
    opBriefing = OpStrings.BriefingData,
    opDebriefingSuccess = OpStrings.A04_DB01_010,
    opDebriefingFailure = OpStrings.A04_DB01_020,
}