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
    long_name = OpStrings.OPERATION_NAME,
    feedbackURL = 'http://forums.faforever.com/viewtopic.php?f=78&t=13898',
    opBriefingText = OpStrings.BriefingData,
    opDebriefingSuccess = OpStrings.E01_DB01_010,
    opDebriefingFailure = OpStrings.E01_DB01_020,
}