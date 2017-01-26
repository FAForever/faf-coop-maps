-- ****************************************************************************
-- **
-- **  File     :  /maps/SCCA_Coop_A02/SCCA_Coop_A02_operation.lua
-- **  Author(s):  Evan Pongress
-- **
-- **  Summary  :  Operation data for OpA2
-- **
-- **  Copyright © 2006 Gas Powered Games, Inc.  All rights reserved.
-- ****************************************************************************

local OpStrings = import('/maps/SCCA_Coop_A02/SCCA_Coop_A02_strings.lua')

operationData = 
{
    key = 'SCCA_Coop_A02',
    long_name = OpStrings.OPERATION_NAME,
    feedbackURL = 'http://forums.faforever.com/viewtopic.php?f=78&t=13893',
    opBriefingText = OpStrings.BriefingData,
    opDebriefingSuccess = OpStrings.A02_DB01_010,
    opDebriefingFailure = OpStrings.A02_DB01_020,
}