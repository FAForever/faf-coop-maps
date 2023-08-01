-- *****************************************************************************
-- *
-- *    File: maps/SCCA_Coop_A05/SCCA_Coop_A05_operation.lua
-- *    Author: Drew Staltman
-- *     Summary: Operation data for SCCA_Coop_A05
-- *
-- *    Copyright © 2006 Gas Powered Games, Inc.  All rights reserved.
-- *****************************************************************************

local OpStrings = import('/maps/SCCA_Coop_A05/SCCA_Coop_A05_strings.lua')

operationData = 
{
    key = 'SCCA_Coop_A05',
    feedbackURL = 'http://forums.faforever.com/viewtopic.php?f=78&t=13896',
    opName = OpStrings.OPERATION_NAME,
    opDesctiption = OpStrings.OPERATION_DESCRIPTION,
    opBriefing = OpStrings.BriefingData,
    opDebriefingSuccess = OpStrings.A05_DB01_010,
    opDebriefingFailure = OpStrings.A05_DB01_020,
}