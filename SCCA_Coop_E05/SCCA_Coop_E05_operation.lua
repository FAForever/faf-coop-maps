-- ****************************************************************************
-- **
-- **  File     :  /maps/SCCA_Coop_E05/SCCA_Coop_E05_operation.lua
-- **  Author(s):  Evan Pongress
-- **
-- **  Summary  :  Operation data for OpE5
-- **
-- **  Copyright © 2006 Gas Powered Games, Inc.  All rights reserved.
-- ****************************************************************************

local OpStrings = import('/maps/SCCA_Coop_E05/SCCA_Coop_E05_strings.lua')

operationData = 
{
    key = 'SCCA_Coop_E05',
    long_name = OpStrings.OPERATION_NAME,
    feedbackURL = 'http://forums.faforever.com/viewtopic.php?f=78&t=13902',
    opBriefingText = OpStrings.BriefingData,
    opDebriefingSuccess = OpStrings.E05_DB01_010,
    opDebriefingFailure = OpStrings.E05_DB01_020,
}