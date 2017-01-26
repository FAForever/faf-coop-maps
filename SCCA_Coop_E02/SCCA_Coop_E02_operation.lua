-- ****************************************************************************
-- **
-- **  File     :  /maps/SCCA_Coop_E02/SCCA_Coop_E02_operation.lua
-- **  Author(s):  Evan Pongress
-- **
-- **  Summary  :  Operation data for OpE2
-- **
-- **  Copyright © 2006 Gas Powered Games, Inc.  All rights reserved.
-- ****************************************************************************

local OpStrings = import('/maps/SCCA_Coop_E02/SCCA_Coop_E02_strings.lua')

operationData = 
{
    key = 'SCCA_Coop_E02',
    long_name = OpStrings.OPERATION_NAME,
    feedbackURL = 'http://forums.faforever.com/viewtopic.php?f=78&t=13899',
    opBriefingText = OpStrings.BriefingData,
    opDebriefingSuccess = OpStrings.E02_DB01_010,
    opDebriefingFailure = OpStrings.E02_DB01_020,
}