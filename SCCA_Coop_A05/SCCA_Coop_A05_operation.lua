-- *****************************************************************************
-- *
-- *	File: maps/SCCA_Coop_A05/SCCA_Coop_A05_v03_operation.lua
-- *	Author: Drew Staltman
-- *     Summary: Operation data for SCCA_Coop_A05
-- *
-- *	Copyright © 2006 Gas Powered Games, Inc.  All rights reserved.
-- *****************************************************************************


-- ONLY EDIT THESE VARS 
opID = 'SCCA_Coop_A05'						-- should always be in the form 'SCCA_' + faction letter + 2-digit op num, e.g. SCCA_E01
opLoc = {x = 435, y = 221}			-- location of op 'planet' on op select screen
opDesc = ''							-- used in op select screen

-- DO NOT EDIT
local opVars = import('/lua/ui/campaign/operationvars.lua').MakeOpVars(opID, 'aeon', 5)

operationData = 
{
    key = opID,
    
    operationSelectData = {
        name = opVars.op_short_name,
        long_name = opVars.op_long_name,
        location = opLoc,
        buttonPrefix = opVars.op_BtnPfx,
        description = opDesc,
    },

    operationBriefingData = {
        opNum = opVars.op_num,
        opTitle = opVars.op_long_name,
        opText = opVars.op_text,
        opInfo = opVars.op_info,
        opMovPfx = opVars.op_MovPfx,
        opMap = opVars.op_map,
    },
}
