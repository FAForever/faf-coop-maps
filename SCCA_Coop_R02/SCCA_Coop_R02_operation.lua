-- ****************************************************************************
-- **
-- **  File     :  /maps/SCCA_Coop_R02/SCCA_Coop_R02_operation.lua
-- **  Author(s):  Evan Pongress
-- **
-- **  Summary  :  Operation data for OpR2
-- **
-- **  Copyright © 2006 Gas Powered Games, Inc.  All rights reserved.
-- ****************************************************************************

local OpStrings = import('/maps/SCCA_Coop_R02/SCCA_Coop_R02_strings.lua')

operationData = 
{
    key = 'SCCA_Coop_R02',
    long_name = OpStrings.OPERATION_NAME,
    feedbackURL = 'http://forums.faforever.com/viewtopic.php?f=78&t=13905',
    opBriefingText = OpStrings.BriefingData,
    opDebriefingSuccess = OpStrings.R02_DB01_010,
    opDebriefingFailure = OpStrings.R02_DB01_020,
}