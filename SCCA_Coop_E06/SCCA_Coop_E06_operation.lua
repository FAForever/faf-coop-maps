-- ****************************************************************************
-- **
-- **  File     :  /maps/SCCA_Coop_E06/SCCA_Coop_E06_v01_operation.lua
-- **  Author(s):  Evan Pongress
-- **
-- **  Summary  :  Operation data for OpE6
-- **
-- **  Copyright © 2006 Gas Powered Games, Inc.  All rights reserved.
-- ****************************************************************************

-- ONLY EDIT THESE VARS 
opID = 'SCCA_Coop_E06'                        -- should always be in the form 'SCCA_' + faction letter + 2-digit op num, e.g. SCCA_E01
opLoc = {x = 627, y = 297}            -- location of op 'planet' on op select screen
opDesc = ''                            -- used in op select screen
opPlanet = ''
opTitle = 'Op 6'

-- DO NOT EDIT
local opVars = import('/lua/ui/campaign/operationvars.lua').MakeOpVars(opID, 'uef', 6)

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
        opMovPfx = opVars.op_MovPfx,
        opMap = opVars.op_map,
    },
}
