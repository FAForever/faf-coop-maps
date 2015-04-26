#****************************************************************************
#**
#**  File     :  /maps/SCCA_Coop_E05_v01/SCCA_Coop_E05_v01_EditorFunctions.lua
#**  Author(s):  Ruth Tomandl
#**
#**  Summary  :  This is a set of functions for the platoon builder, used in
#**              operation E5. These functions can be used for Build callbacks
#**              for platoons, or death callbacks for AM platoons.
#**
#**  Copyright © 2006 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************

local OpScript = import ('/maps/SCCA_Coop_E05_v01/SCCA_Coop_E05_v01_script.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local ScenarioFramework = import('/lua/scenarioframework.lua')

ScenarioInfo.Nuke2BasePatrolCounter = 0
ScenarioInfo.Nuke3BasePatrolCounter = 0
ScenarioInfo.MainBaseAttackCounter = 0

#############################################################################################################
# function: BigAeonAttackDied = BuildCallback        doc = "checks when Arnold's big attack has failed for obj. M1P3"
#
# parameter 0:    string brain        = "default_brain"
# parameter 1:    string platoon    = "default_table"
#
############################################################################################################
function BigAeonAttackDied(brain, platoon)
    ForkThread(OpScript.UpdateM1P3)
end

##############################################################################################################
# function: BigAeonAttackAddFunction = AddFunction   doc = "Fires when Arnold's big attack gets created"
#
# parameter 0: string	platoon		= "default_platoon"
#
##############################################################################################################
function BigAeonAttackAddFunction(platoon)
    ScenarioInfo.VarTable['BuildBigAeonAttack'] = false
    ScenarioInfo.M1BigAttackPlatoon = platoon
    ForkThread(OpScript.BigAeonAttackBuilt)
    LOG('debug: Op: Arnold\'s troops are attacking with a big assault!')
end

##############################################################################################################
# function: AeonMainBaseAttackAddFunction = AddFunction   doc = "Fires when the Aeon main base attack gets created"
#
# parameter 0: string	platoon		= "default_platoon"
#
##############################################################################################################
function AeonMainBaseAttackAddFunction(platoon)
    ScenarioInfo.VarTable['BuildAeonMainBaseAttacks'] = false
    ScenarioInfo.MainBaseAttackCounter = ScenarioInfo.MainBaseAttackCounter + 1
    if ScenarioInfo.MainBaseAttackCounter < 3 then
        platoon:Patrol(ScenarioUtils.MarkerToPosition( 'Aeon_Main_Base_Attack_0' ))
        platoon:Patrol(ScenarioUtils.MarkerToPosition( 'Player' ))
        LOG('debug: Op: The Aeon main base is sending an attack against the player')
    end
    if ScenarioInfo.MainBaseAttackCounter == 3 then
        if not ScenarioInfo.ResearchFacility1Destroyed then
            platoon:Patrol(ScenarioUtils.MarkerToPosition( 'Aeon_Main_Base_Attack_0' ))
            platoon:Patrol(ScenarioUtils.MarkerToPosition( 'Research_Facility_1' ))
            LOG('debug: Op: The Aeon main base is sending an attack against RF1')
        else
            platoon:Patrol(ScenarioUtils.MarkerToPosition( 'Aeon_Main_Base_Attack_0' ))
            platoon:Patrol(ScenarioUtils.MarkerToPosition( 'Player' ))
            LOG('debug: Op: The Aeon main base is sending an attack against the player')
        end
    end
    if ScenarioInfo.MainBaseAttackCounter == 4 then
        if not ScenarioInfo.ResearchFacility2Destroyed then
            platoon:Patrol(ScenarioUtils.MarkerToPosition( 'Aeon_Main_Base_Attack_0' ))
            platoon:Patrol(ScenarioUtils.MarkerToPosition( 'Research_Facility_2' ))
            LOG('debug: Op: The Aeon main base is sending an attack against RF2')
        else
            platoon:Patrol(ScenarioUtils.MarkerToPosition( 'Aeon_Main_Base_Attack_0' ))
            platoon:Patrol(ScenarioUtils.MarkerToPosition( 'Player' ))
            LOG('debug: Op: The Aeon main base is sending an attack against the player')
        end
    end
    if ScenarioInfo.MainBaseAttackCounter == 5 then
        ScenarioInfo.MainBaseAttackCounter = 0
        if not ScenarioInfo.ResearchFacility3Destroyed then
            platoon:Patrol(ScenarioUtils.MarkerToPosition( 'Aeon_Main_Base_Attack_0' ))
            platoon:Patrol(ScenarioUtils.MarkerToPosition( 'Aeon_Second_Base_Attack_Player_1' ))
            platoon:Patrol(ScenarioUtils.MarkerToPosition( 'Research_Facility_3' ))
            LOG('debug: Op: The Aeon main base is sending an attack against RF3')
        else
            platoon:Patrol(ScenarioUtils.MarkerToPosition( 'Aeon_Main_Base_Attack_0' ))
            platoon:Patrol(ScenarioUtils.MarkerToPosition( 'Player' ))
            LOG('debug: Op: The Aeon main base is sending an attack against the player')
        end
    end
    WaitSeconds(ScenarioInfo.M1AeonMainBaseAttackDelay)
    ScenarioInfo.VarTable['BuildAeonMainBaseAttacks'] = true
end

##############################################################################################################
# function: AeonNuke2BasePatrolAddFunction = AddFunction   doc = "Fires when the Aeon Nuke2 base patrol gets created"
#
# parameter 0: string	platoon		= "default_platoon"
#
##############################################################################################################
function AeonNuke2BasePatrolAddFunction(platoon)
    ScenarioInfo.Nuke2BasePatrolCounter = ScenarioInfo.Nuke2BasePatrolCounter + 1
    if ScenarioInfo.Nuke2BasePatrolCounter < 3 then
        ScenarioFramework.PlatoonPatrolRoute(platoon, ScenarioUtils.ChainToPositions('Aeon_Nuke_2_Base_Patrol'))
        LOG('debug: Op: The Aeon Nuke2 base is making a patrol')
    else
        platoon:Patrol(ScenarioUtils.MarkerToPosition( 'Aeon_Main_Base_Attack_0' ))
        platoon:Patrol(ScenarioUtils.MarkerToPosition( 'Player' ))
        LOG('debug: Op: The Aeon Nuke2 base is sending an attack against the player')
    end
end

##############################################################################################################
# function: AeonNuke3BasePatrolAddFunction = AddFunction   doc = "Fires when the Aeon Nuke3 base patrol gets created"
#
# parameter 0: string	platoon		= "default_platoon"
#
##############################################################################################################
function AeonNuke3BasePatrolAddFunction(platoon)
    ScenarioInfo.Nuke3BasePatrolCounter = ScenarioInfo.Nuke3BasePatrolCounter + 1
    if ScenarioInfo.Nuke3BasePatrolCounter < 3 then
        ScenarioFramework.PlatoonPatrolRoute(platoon, ScenarioUtils.ChainToPositions('Aeon_Nuke_3_Base_Patrol'))
        LOG('debug: Op: The Aeon Nuke3 base is making a patrol')
    else
        platoon:Patrol(ScenarioUtils.MarkerToPosition( 'Aeon_Main_Base_Attack_0' ))
        platoon:Patrol(ScenarioUtils.MarkerToPosition( 'Player' ))
        LOG('debug: Op: The Aeon Nuke3 base is sending an attack against the player')
    end
end

##############################################################################################################
# function: AeonM2SecondBaseAttackAddFunction = AddFunction   doc = "Fires when the Aeon second base Cybran attack gets created"
#
# parameter 0: string	platoon		= "default_platoon"
#
##############################################################################################################
function AeonM2SecondBaseAttackAddFunction(platoon)
    if not ScenarioInfo.AeonTruckAttack then
        ScenarioFramework.PlatoonPatrolRoute( platoon, ScenarioUtils.ChainToPositions('Aeon_Second_Base_Attack_Cybran') )
        LOG('debug: Op: The Aeon second base is sending an attack against the Cybran')
    else
        ScenarioFramework.PlatoonPatrolRoute( platoon, ScenarioUtils.ChainToPositions('Aeon_Second_Base_Attack_Player') )
        LOG('debug: Op: The Aeon second base is sending an attack against the Player')
        if not ScenarioInfo.AeonM2PlayerAttackTauntPlayed then
            OpScript.ForkArnoldTaunt()
            ScenarioInfo.AeonM2PlayerAttackTauntPlayed = true
        end
    end
end

##############################################################################################################
# function: CybranWAttackAddFunction = AddFunction   doc = "Fires when the Aeon second base Cybran attack gets created"
#
# parameter 0: string	platoon		= "default_platoon"
#
##############################################################################################################
function CybranWAttackAddFunction(platoon)
    if ScenarioInfo.VarTable['BuildCybranM2AeonAttack'] then
        ScenarioFramework.PlatoonPatrolRoute( platoon, ScenarioUtils.ChainToPositions('Cybran_Base_W_Attack_Aeon') )
        LOG('debug: Op: The Cybran W base is sending an attack against the Aeon')
    elseif ScenarioInfo.VarTable['BuildCybranWM2PlayerAttack'] then
        ScenarioFramework.PlatoonPatrolRoute( platoon, ScenarioUtils.ChainToPositions('Cybran_Base_W_Attack_Player') )
        LOG('debug: Op: The Cybran W base is sending an attack against the Player')
    end
end

##############################################################################################################
# function: CybranNNWAttackAddFunction = AddFunction   doc = "Fires when the Cybran NNW Base Player attack gets created"
#
# parameter 0: string	platoon		= "default_platoon"
#
##############################################################################################################
function CybranNNWAttackAddFunction(platoon)
    local rndCheck = Random(1, 5)
    if rndCheck == 1 then
        if not ScenarioInfo.ResearchFacility1Destroyed then
            platoon:AggressiveMoveToLocation(ScenarioUtils.MarkerToPosition( 'Research_Facility_1' ), 'attack')
            LOG('debug: Op: The Cybran NNW base is attacking RF1')
        else
            ScenarioFramework.PlatoonPatrolRoute( platoon, ScenarioUtils.ChainToPositions('Cybran_NW_Player_Attack') )
            LOG('debug: Op: The Cybran NNW base is attacking the Player')
        end
    end
    if rndCheck == 2 then
        if not ScenarioInfo.ResearchFacility2Destroyed then
            platoon:AggressiveMoveToLocation(ScenarioUtils.MarkerToPosition( 'Research_Facility_2' ), 'attack')
            LOG('debug: Op: The Cybran NNW base is attacking RF2')
        else
            ScenarioFramework.PlatoonPatrolRoute( platoon, ScenarioUtils.ChainToPositions('Cybran_NW_Player_Attack') )
            LOG('debug: Op: The Cybran NNW base is attacking the Player')
        end
    end
    if rndCheck == 3 then
        if not ScenarioInfo.ResearchFacility3Destroyed then
            platoon:AggressiveMoveToLocation(ScenarioUtils.MarkerToPosition( 'Research_Facility_3' ), 'attack')
            LOG('debug: Op: The Cybran NNW base is attacking RF3')
        else
            ScenarioFramework.PlatoonPatrolRoute( platoon, ScenarioUtils.ChainToPositions('Cybran_NW_Player_Attack') )
            LOG('debug: Op: The Cybran NNW base is attacking the Player')
        end
    end
    if rndCheck > 3 then
        ScenarioFramework.PlatoonPatrolRoute( platoon, ScenarioUtils.ChainToPositions('Cybran_NW_Player_Attack') )
        LOG('debug: Op: The Cybran NNW base is attacking the Player')
    end
end


##############################################################################################################
# function: CybranNWAttackAddFunction = AddFunction   doc = "Fires when the Cybran NW Base Player attack gets created"
#
# parameter 0: string	platoon		= "default_platoon"
#
##############################################################################################################
function CybranNWAttackAddFunction(platoon)
    local rndCheck = Random(1, 5)
    if rndCheck == 1 then
        if not ScenarioInfo.ResearchFacility1Destroyed then
            platoon:AggressiveMoveToLocation(ScenarioUtils.MarkerToPosition( 'Research_Facility_1' ), 'attack')
            LOG('debug: Op: The Cybran NW base is attacking RF1')
        else
            ScenarioFramework.PlatoonPatrolRoute( platoon, ScenarioUtils.ChainToPositions('Cybran_NW_Player_Attack') )
            LOG('debug: Op: The Cybran NW base is attacking the Player')
        end
    end
    if rndCheck == 2 then
        if not ScenarioInfo.ResearchFacility2Destroyed then
            platoon:AggressiveMoveToLocation(ScenarioUtils.MarkerToPosition( 'Research_Facility_2' ), 'attack')
            LOG('debug: Op: The Cybran NW base is attacking RF2')
        else
            ScenarioFramework.PlatoonPatrolRoute( platoon, ScenarioUtils.ChainToPositions('Cybran_NW_Player_Attack') )
            LOG('debug: Op: The Cybran NW base is attacking the Player')
        end
    end
    if rndCheck == 3 then
        if not ScenarioInfo.ResearchFacility3Destroyed then
            platoon:AggressiveMoveToLocation(ScenarioUtils.MarkerToPosition( 'Research_Facility_3' ), 'attack')
            LOG('debug: Op: The Cybran NW base is attacking RF3')
        else
            ScenarioFramework.PlatoonPatrolRoute( platoon, ScenarioUtils.ChainToPositions('Cybran_NW_Player_Attack') )
            LOG('debug: Op: The Cybran NW base is attacking the Player')
        end
    end
    if rndCheck > 3 then
        ScenarioFramework.PlatoonPatrolRoute( platoon, ScenarioUtils.ChainToPositions('Cybran_NW_Player_Attack') )
        LOG('debug: Op: The Cybran NW base is attacking the Player')
    end
end

