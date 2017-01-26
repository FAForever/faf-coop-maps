-- ****************************************************************************
-- **
-- **  File     :  /maps/SCCA_Coop_E03/SCCA_Coop_E03_operation.lua
-- **  Author(s):  Evan Pongress
-- **
-- **  Summary  :  Operation data for OpE3
-- **
-- **  Copyright © 2006 Gas Powered Games, Inc.  All rights reserved.
-- ****************************************************************************

local OpStrings = import('/maps/SCCA_Coop_E03/SCCA_Coop_E03_strings.lua')

operationData = 
{
    key = 'SCCA_Coop_E03',
    long_name = OpStrings.OPERATION_NAME,
    feedbackURL = 'http://forums.faforever.com/viewtopic.php?f=78&t=13900',
    opBriefingText = OpStrings.BriefingData,
    opDebriefingSuccess = OpStrings.E03_DB01_010,
    opDebriefingFailure = OpStrings.E03_DB01_020,
}