Version 1.0 8/3/06



KNOWN ISSUES:
1) there is dialog for objective reminders that is unused - Mission 1 objective to build a sonar (E03_M01_110, and E03_M01_115).  I chose not to implement this dialog since that objective is no longer a primary objective.

2) land boats are possible - boats can get into a position where they path on land.

3) restricted units can be built by exploiting the build cue as you upgrade a factory.

4) the Arnold Death event is clunky - in progress work - need to remove the double explosion.

5) all dialog timing flow seems sluggish and sometimes off - especially with the way objectives completion is currently working.

6) several outstanding objective issues:
    * I have implemented objective description text updates that flat out fail with the new system - no idea why.
    * There are quite a few objectives that could not be implemented to the Bob Berry system - to track these search the script for:
        ##### OLD SYSTEM ADD OBJECTIVE
        ##### OLD SYSTEM UPDATE OBJECTIVE
        ##### OLD SYSTEM COMPLETE OBJECTIVE
        ##### OLD SYSTEM PROGRESS UPDATE
        ##### LEGACY STYLE ADD OBJECTIVE

7) the TML objective has been cut- there are still references to it in the save file and the dialog strings



FAQ:
Where can I find all the information on E3?
    * map files: //depot/rts/main/data/maps/SCCA_E03/
    * spec doc: //depot/rts/main/docs/design/SPECS/Campaign/Operations/Spec_SC_OpE3.doc
    * custom unit: //depot/rts/main/data/Units/OPE3001/
    * feedback: http://enterprise2.eproject.com/Applications/IssueApp/IssueAppItemDetail.aspx?oid=941fd840-bc51-4282-9e95-ee4fc5832639|b6e20a76-2efe-4ede-87ac-fdbc5e9a9b28
    * bugs: http://enterprise2.eproject.com/Applications/IssueApp/IssueAppItemDetail.aspx?oid=22a60f99-a3fa-46c3-b72a-5dfc96fc9264|b6e20a76-2efe-4ede-87ac-fdbc5e9a9b28


How is the Script file structured?
    * all tuning variables are at the top of the script and named according to thier mission, and functionality (eg M1SubAttackDelay is the delay period for sub attacks in M1)
    * all tuning variables are adjusted for difficulty using the function: AdjustDifficulty
    * the format for difficulty settings is: local VariableName = AdjustDifficulty( {difficutly1value, difficutly2value, difficutly3value} )
    * Primary mission flow functions are sequentially listed in their respective mission sections of the script.  The script can be read top down for each mission.
    * Attack functions are near the end of the script in their own function section.


How can I jumpstart to Mission2, 3, or 4?
    * locate the function 'IntroNIS' - in the script file for OPE3
    * locate the bool called 'DebugMode'
    * set this bool to true
    * just below the bool, set the mission you wish to test by changing the function number in 'StartMission4()'
    * this mode is done in the script so we get a clean start to each mission - there are no OnF5 style jumpstarts - that method allows for too many bugs


How are spawned enemies managed?
    * for all spawned units in M1, M2, M3, and M4 I use a spawn function followed by various AI threads
    * see: 'SpawnM1AirAttack' for the standard version of respawning Attacks
    * In the spawn function, 'SpawnM1AirAttack' I create threads that will create platoons and assign AI as many times as needed based on difficulty
    * The spawn function is generally only called once by my scripts
    * In the AI function, 'M1AirAttack' I create the platoon and give it various commands for behavior, and if desired, I create a platoon death trigger
    * For respawning attacks, I use the platoondeath trigger to launch a respawn function
    * in the respawn function, 'ReSpawnM1AirAttack' I create a new thread to make a replacement platoon with AI
    * For single event attacks, I use the platoondeath trigger to launch counter functions that increment each time they are called until it is time for the mission to update


How are PBM defenders and attackers managed?
    * Each component of the M4 base defense is a 'requires construction' PBM with a small 3 or 6 unit platoon instanced based on difficulty given a set patrol path
    * There are independent T1 naval, T2 naval, T1 air, and T2 air builders that form additional patrolling defenders which will combine to form attack forces at timed intervals
    * using this system, there is full control over how many units the enemy can have defending at all times, and a fixed interval for all attacks
    * critical to this working is a very fast build time (obviously faster than the attack times)
    * Additionally, there are still spawned defenders used in M3 that are not managed via PBM


How are the Aeon Engineers Managed?
    * for M4, there are 2 groups of dedicated assisting ENGs and 3 different maintain base patrols of ENGs
    * the three patrols are 'requires construction' PBMs of 2 T2 ENGs - they patrol: the M4 torpedo defense area, M4 air defense area, M4 resource production area
    * the two assist groups are NOT 'requires construction' PBMs of 1 T2 ENG each - they either assist the naval factories (18 total) or the air factories (12 total)
    * in order to keep the number of assisting ENGs constant, the assist PBMs are 1 ENG each, and a pair of builders make additional ENGs to add to the pool
    * these 'pool builders' only build new ENGs when the ENG count around their respective factories drops below the required number (18 and 12)
    * 'pool builder' platoons of 1 ENG are immediately disbanded as soon as they are created - thus becoming available ENGs for the assist PBMs


How are Taunts Managed?
    * function OpE3TauntLauncher is launched at the start of the operation
    * it ticks every 20 player units killed and checks to see if the bool TauntLock is set or not
    * if TauntLock is false, we play a taunt, otherwise we start a new tick of the launcher


How are Objective Reminders Managed?
    * function ObjectiveReminder is launched each time an objective with reminder dialog is innitiated
    * I pass into this function, a named bool, and two dialog calls
    * the function alternates playing the dialog every ReminderDelay seconds so long as the named bool is not true
    * I set the named bool to true on completion of the objective



ENEMY BREAKDOWN:
Mission1:
    * ongoing air attacks
    * 2 submarine patrols
    * 1 frigate with escorting light attack boats
    * 1 small island of resources defended with 2 AA towers (when given enough time to be built)

Mission2:
    * 3 waves of Aeon attackers - mixed naval and air

Mission3:
    * ongoing attacks - varies between bombers, torpedo bombers, submarines, and frigates
    * ocean defending Air patrols
    * ocena defending Naval patrols
    * frigate and light attack boat defenders for positions around the Blackbox Island

Mission4:
    * ongoing Air attacks - 2 platoons of either bombers and interceptors, or bombers, interceptors, and gunships
    * ongoing naval attacks - 2 platoons of either frigates, or frigates and destroyers
    * ocean defending air patrols
    * ocena defending naval patrols
    * island defending air patrols
    * island defending naval patrols
    * island defending torpedo bomber patrols
    * island defending submarine patrols
    * island factory defending air patrols
    * custom attacks for the TML island if captured