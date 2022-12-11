-- ****************************************************************************
-- **
-- **  File     :  /maps/SCCA_Coop_R04/SCCA_Coop_R04_operation.lua
-- **  Author(s):  Evan Pongress
-- **
-- **  Summary  :  Operation data for OpR4
-- **
-- **  Copyright © 2006 Gas Powered Games, Inc.  All rights reserved.
-- ****************************************************************************

local OpStrings = import('/maps/SCCA_Coop_R04/SCCA_Coop_R04_strings.lua')

operationData = 
{
    key = 'SCCA_Coop_R04',
    feedbackURL = 'http://forums.faforever.com/viewtopic.php?f=78&t=13907',
    opName = OpStrings.OPERATION_NAME,
    opDesctiption = OpStrings.OPERATION_DESCRIPTION,
    opBriefing = OpStrings.BriefingData,
    opDebriefingSuccess = OpStrings.R04_DB01_010,
    opDebriefingFailure = OpStrings.R04_DB01_020,
}