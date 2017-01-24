-- ****************************************************************************
-- **
-- **  File     :  /maps/SCCA_Coop_A01/SCCA_Coop_A01_operation.lua
-- **  Author(s):  Evan Pongress
-- **
-- **  Summary  :  Operation data for OpA1
-- **
-- **  Copyright © 2006 Gas Powered Games, Inc.  All rights reserved.
-- ****************************************************************************

local OpStrings = import('/maps/SCCA_Coop_A01/SCCA_Coop_A01_strings.lua')

operationData = 
{
    key = 'SCCA_Coop_A01',
    long_name = OpStrings.OPERATION_NAME,
    feedbackURL = 'http://forums.faforever.com/viewtopic.php?f=78&t=13892',
    opBriefingText = OpStrings.BriefingData,
    opDebriefingSuccess = OpStrings.A01_DB01_010,
    opDebriefingFailure = OpStrings.A01_DB01_020,
}