-----------
-- Story --
-----------
-- General overview:
--    As an experienced UEF commander you are invited into Prothyon-16 training facility for for demostration for new pilots.
--    Fighting AI in prepared scenarios. During the excercise Seraphim will launch an attack on the planet and your task
--    is to save sACU pilot surrounded on one of the island, evacuate civilians and yourself from the planet.
-- 
--
-- Pre-Seraphim Stage:
--
-- Mission 1
--    Starting with T1 ACU and only T1 tech your objective is to destroy 2 small bases.
--    Secondary objective to capture "Tech Centres" to unlock additional units and upgrades.
-- 
-- Mission 2
--    After successfully destroying first two bases map expands to south revealing new base which is fully T2
--    Main objective to defeat the AI again. Fighting against T2 land and air units this time.
--    Secondary objective to capture another "Tech Centres" to unlock additional units and upgrades.
-- 
-- Mission 3
--    Defeating AI which is on the island. Fighting against T2 air and naval.
--    When having most of the base destroyed, Seraphim will start an attack. Rest of the base is given to player.
-- 
-- Seraphim Stage:
-- 
-- Mission 4
--    Mission start with showing sACU pilot being under attakc of Seraphim, you objective is to save him.
--    In oder to do that, Seraphim ACU in the main base has to he killed and base destroyed.
--
--        TODO: This part might need to restructure and instead of main objective to kill island base, just kill those bases on the middle island
--              Since that will make more sence. Killing those will open route sACU to evacuate.
--              Then we need to make sure that the transport wont get shot down. Maybe objective to have certain amount of units near sACU base
--              in order for evacuation to behin.
--              
--    Secondary objectives to protect civilians and destroy all enemy bases on the island.                                                                                                           
--        Once seraphim bases are destroyed, evacuation of civilians starts
-- 
-- Mission 4 Part 2
-- 
--    If player takes too long, map expands and second Seraphim commander starts building base and attack playing. No objective on that.
--    After another (30min+-) Seraphim untis start spawning all around map. This is suppose to be game over. Attack needs to be strong enough to
--    player, eventually sACU which would lead to loss as well
-- 
--        TODO: Might not need the part with second Seraphim ACU at all. The mission is already long enough. Going straigh for units spawning everywhere.
--              Another thing to consider would be if sACU die, give objective to evac yourself anyway, since it kinda makes sense and after that
--              mark mission as lost?
--


-- --------
-- Game End
-- --------


-- Player Win / Actor: Gyle / Update 28/09/2015 / VO TODO
PlayerWin = {
  {text = '[Gyle]: Congratulations commander, because of you we were able to retreat with minimal losses.', vid = '', bank = '', cue = '', faction = 'UEF'},
}

-- Player Dies / Actor: Gyle / Update / VO TODO
PlayerDies = {
  {text = '[Gyle]:', vid = '', bank = '', cue = '', faction = 'UEF'},
}

-- Player Lose To AI / Actor: Gyle / Update 22/05/2015 / VO Ready
PlayerLoseToAI = {
  {text = '[Gyle]: Commander, your ACU has been brought to critical health and can no longer participate in combat. You have been defeated!', vid = 'Pro_16_PlayerLose1.sfd', bank = 'G_VO1', cue = '26Playerlose', faction = 'UEF'},
}

-- sACU Die / Actor: Gyle / Update 28/09/2015 / VO TODO
sACUDie = {
  {text = '[Gyle]: We have lost contact with Morax, the operation has failed.', vid = '', bank = '', cue = '', faction = 'UEF'},
}



-------------------------------
-- Mission 1
-- Destroy Outpost + Beach Base
-------------------------------



-- Intro Sequence 1 / Actor: Gyle / Update 30/07/2015 / VO not ready
intro1 = {
  {text = '[Gyle]: Welcome commander – My name is Gyle and I’ll be your intel officer for the forthcoming scenario. In this mission you will be giving a demonstration to our newest recruits by fighting against a training AI. Your first objective will be to destroy this outpost. ', vid = 'Pro_16_intro1.sfd', bank = 'G_VO1', cue = '1intro1', faction = 'UEF'},
}

-- Intro Sequence 2 / Actor: Gyle / Update 22/05/2015 / VO Ready
intro2 = {
  {text = '[Gyle]: There are tech centers positioned around the map - capture them to unlock additional units.', vid = 'Pro_16_intro2.sfd', bank = 'G_VO1', cue = '2intro2', faction = 'UEF'},
}

-- Intro Sequence 3 / Actor: Gyle / Update 22/05/2015 / VO Ready
intro3 = {
  {text = '[Gyle]: Your next objective will then be to secure the beach by destroying this base.  ', vid = 'Pro_16_intro3.sfd', bank = 'G_VO1', cue = '3intro3', faction = 'UEF'},
}

-- Good luck! / Actor: Gyle / Update 22/05/2015 / VO Ready
postintro = {
  {text = '[Gyle]: The training AI has been activated – Good Luck Commander! ', vid = 'Pro_16_postintro.sfd', bank = 'G_VO1', cue = '4postintro', faction = 'UEF'},
}

-- First Base Killed / Actor: Gyle / Update 22/05/2015 / VO Ready
base1killed = {
  {text = '[Gyle]: The outpost has been destroyed, secure the area and push forward. HQ, Out', vid = 'Pro_16_base1killed.sfd', bank = 'G_VO1', cue = '5base1killed', faction = 'UEF'},
}

-- Both Bases Killed / Actor: Gyle / Update 22/05/2015 / VO TODO
base2killed = {
  {text = '[Gyle]: First part of the exercise complete. HQ, Out', vid = '', bank = '', cue = '', faction = 'UEF'},
}



-- Tech building reminder 1 / Actor: Gyle / Update 22/05/2015 / VO Ready
HQcapremind1 = {
  {text = '[Gyle]: Commander, you need to capture the tech centre to gain access to additional units. HQ, Out', vid = 'Pro_16_HQcapremind1.sfd', bank = 'G_VO1', cue = '6HQcapremind1', faction = 'UEF'},
}

-- Tech building reminder 2 / Actor: Gyle / Update 22/05/2015 / VO Ready
HQcapremind2 = {
  {text = '[Gyle]: A tech centre is still in enemy hands - you need to capture it to gain an advantage in battle. HQ, Out', vid = 'Pro_16_HQcapremind2.sfd', bank = 'G_VO1', cue = '7HQcapremind2', faction = 'UEF'},
}

-- Tech building reminder 3 / Actor: Gyle / Update 22/05/2015 / VO Ready
HQcapremind3 = {
  {text = '[Gyle]: You can only gain access to additional units if you capture a tech centre. Do so as soon as possible. HQ, Out', vid = 'Pro_16_HQcapremind3.sfd', bank = 'G_VO1', cue = '8HQcapremind3', faction = 'UEF'},
}

-- Tech building reminder 4 / Actor: Gyle / Update 30/07/2015 / VO not ready, I think. I corrected this.
HQcapremind4 = {
  {text = '[Gyle]: Commander there is still an uncaptured technology centre - you need it to build advanced units. HQ, Out', vid = 'Pro_16_HQcapremind4.sfd', bank = 'G_VO1', cue = '9HQcapremind4', faction = 'UEF'},
}



-- First objective reminder 1 / Actor: Gyle / Update 22/05/2015 / VO Ready
base1remind1 = {
  {text = '[Gyle]: The outpost is obstructing your progress. Destroy it immediately. HQ Out', vid = 'Pro_16_base1remind1.sfd', bank = 'G_VO1', cue = '10base1remind1', faction = 'UEF'},
}

-- First objective reminder 2 / Actor: Gyle / Update 22/05/2015 / VO Ready
base1remind2 = {
  {text = '[Gyle]: The clock\'s ticking commander, destroy that base. HQ Out', vid = 'Pro_16_base1remind2.sfd', bank = 'G_VO1', cue = '11base1remind2', faction = 'UEF'},
}

-- Second objective reminder 1 / Actor: Gyle / Update 22/05/2015 / VO Ready
base2remind1 = {
  {text = '[Gyle]: The base is still operational - you need to destroy it to secure the beach. HQ Out', vid = 'Pro_16_base1remind2.sfd', bank = 'G_VO1', cue = '12base2remind1', faction = 'UEF'},
}



---------------------
-- Mission 2
-- Destroy South Base
---------------------



-- Units moving notification / Actor: Gyle / Update 22/05/2015 / VO Ready
unitmove = {
  {text = '[Gyle]: There will be units moving through your area participating in other training exercises, please ignore them. HQ Out', vid = 'Pro_16_unitmove.sfd', bank = 'G_VO1', cue = '13unitmove', faction = 'UEF'},
}

-- Third Objective intro 1 / Actor: Gyle / Update 22/05/2015 / VO Ready
southbase1 = {
  {text = '[Gyle]: Your next task is to neutralise the base in the south, the training AI has been authorised to use tech 2 land and air units, so expect heavy resistance.  ', vid = 'Pro_16_southbase1.sfd', bank = 'G_VO1', cue = '14southbase1', faction = 'UEF'},
}

-- Third Objective intro 2 / Actor: Gyle / Update 22/05/2015 / VO Ready
southbase2 = {
  {text = '[Gyle]: Attack immediately and secure the whole island in preparation for phase 3 of the exercise. HQ, Out', vid = 'Pro_16_southbase2.sfd', bank = 'G_VO1', cue = '15southbase2', faction = 'UEF'},
}



-- Third objective reminder 1 / Actor: Gyle / Update 22/05/2015 / VO Ready
southbaseremind1 = {
  {text = '[Gyle]: The complex in the south is still operational - send a force to deal with it. HQ, Out', vid = 'Pro_16_southbaseremind1.sfd', bank = 'G_VO1', cue = '16southbaseremind1', faction = 'UEF'},
}

-- Third objective reminder 2 / Actor: Gyle / Update 22/05/2015 / VO Ready
southbaseremind2 = {
  {text = '[Gyle]: The island is still not secure - you need to ensure there are no enemy structures remaining. HQ, Out', vid = 'Pro_16_southbaseremind2.sfd', bank = 'G_VO1', cue = '17southbaseremind2', faction = 'UEF'},
}



-- Air tech objective / Actor: Gyle / Update 22/05/2015 / VO Ready
airhqtechcentre = {
  {text = '[Gyle]: Another tech centre is located behind the south base. Capture it to gain access to tech 2 air units. HQ Out', vid = 'Pro_16_airhqtechcentre.sfd', bank = 'G_VO1', cue = '18airhqtechcentre', faction = 'UEF'},
}

-- Titan patroll objective / Actor: Gyle / Update 22/05/2015 / VO Ready
titankill = {
  {text = '[Gyle]: There are a number of titan units defending this area - engage them at you discretion. HQ Out', vid = 'Pro_16_titankill.sfd', bank = 'G_VO1', cue = '19titankill', faction = 'UEF'},
}

-- Titan patroll objective complete / Actor: Gyle / Update 22/05/2015 / VO Ready
titankilled = {
  {text = '[Gyle]: The titan squad has been eliminated - well done commander. ', vid = 'Pro_16_titankilled.sfd', bank = 'G_VO1', cue = '20titankilled', faction = 'UEF'},
}



-------------------
-- Mission 3
-- Destroy Air Base
-------------------



-- Third objective intro 1 / Actor: Gyle / Update 22/05/2015 / VO Ready
airbase1 = {
  {text = '[Gyle]: The island is now secure.', vid = 'Pro_16_airbase1.sfd', bank = 'G_VO1', cue = '21airbase1', faction = 'UEF'},
}

-- Third objective intro 2 / Actor: Gyle / Update 22/05/2015 / VO Ready
airbase2 = {
  {text = '[Gyle]: Your next objective is to land on the neighbouring island and eliminate this base. The AI has been instructed to use land, air and naval units so watch your step. ', vid = 'Pro_16_airbase2.sfd', bank = 'G_VO1', cue = '22airbase2', faction = 'UEF'},
}

-- Third objective intro 3 / Actor: Gyle / Update 22/05/2015 / VO Ready
postintro3 = {
  {text = '[Gyle]: Repel the attacking forces and launch a counter-offensive. HQ, out', vid = 'Pro_16_postintro3.sfd', bank = 'G_VO1', cue = '23postintro', faction = 'UEF'},
}



-- Third objective reminder 1 / Actor: Gyle / Update 22/05/2015 / VO Ready
airbaseremind1 = {
  {text = '[Gyle]: The second island is still in the hands of the enemy. Send units to attack it. HQ, Out', vid = 'Pro_16_airbaseremind1.sfd', bank = 'G_VO1', cue = '24airbaseremind1', faction = 'UEF'},
}

-- Third objective reminder 2 / Actor: Gyle / Update 22/05/2015 / VO Ready
airbaseremind2 = {
  {text = '[Gyle]: The Air base is still operational, get it done commander. HQ Out', vid = 'Pro_16_airbaseremind2.sfd', bank = 'G_VO1', cue = '25airbaseremind2', faction = 'UEF'},
}



-- Most important part / Actor: Gyle / Update 22/05/2015 / VO Ready
epicEprop = {
  {text = '[Gyle]: Thank you for playing this scenario. This experience has been brought to you courtesy of empire clan. Mission made by speed2, some other useless things were made by Exotic_Retard, and I was responsible for your lovely voiceovers. This is Gyle, Signing out.', vid = 'Pro_16_epicEprop.sfd', bank = 'G_VO1', cue = '27epicEprop', faction = 'UEF'},
}



------------
-- Mission 4
-- 
------------

-- Seraphim arrival intro 1 / Actor: Gyle / Update 28/09/2015 / VO not ready
M4intro1 = {
  {text = '[Gyle]: Excellent work Commander. Clean up the rest of the base, and then \- ', vid = '', bank = '', cue = '', faction = 'UEF'},
} 

-- Seraphim arrival intro 2 / Actor: Gyle / Update 28/09/2015 / VO not ready
M4intro2 = {
#(reopen trans)
  {text = '[Gyle]: Commander, halt all attacks on the AI. Regroup your forces and prepare to defend your positions. Our radars are picking up unidenti- Scratch that. You have hostiles inbound, Seraphim signatures.', vid = '', bank = '', cue = '', faction = 'UEF'},
}

---------------------------------------------
-- Mission 5
-- Protect sACU and Defeat Seraphim Commander
---------------------------------------------


-- Objective 5 Intro 1 / Actor: Gyle, Morax / Update 28/09/2015 / VO TODO
obj5intro1 = {
  {text = '[Gyle]: The Seraphim incursion is too large to be contained! Your job is to ensure that our field commander, Morax makes it off-planet in one piece. Patching you through to him.... now.', vid = '', bank = '', cue = '', faction = 'UEF'},
  {text = '[Morax]: My garrison is in the middle of a warzone and the Seraphim are after me! I will hold off the enemy attacks as long as I can, but I will need assistance!', vid = '', bank = '', cue = '', faction = 'UEF'},
}

-- Objective 5 Intro 3 / Actor: Chief Johnson / Update 06/10/2015 / VO Ready
obj5intro2 = {
  {text = '[Chief Johnson]: Commander, I have issued an evacuation order to all non-combat personnel in the area. But we are cut off by enemy forces! Clear those out of our way and escort everyone to the quantum gateway for extraction as soon as you can.', vid = '', bank = 'ChJ_VO1', cue = 'obj5intro2', faction = 'UEF'},
}

-- Objective 5 Post Intro / Actor: Thel-Uuthow / Update: 06/28/2007 / VO Ready
obj5postintro = {
  {text = '[Zottoo-Zithutin]: [Language Not Recognized]', vid = 'X03_Thel-Uuthow_T01_04346.sfd', bank = 'X03_VO', cue = 'X03_Thel-Uuthow_T01_04346', faction = 'Seraphim'},
}

-- Protect sACU / Actor: Gyle / Update 28/09/2015 / VO TODO
ProtectsACU = {
  {text = '[Gyle]: Commander, you need to defend Morax from the seraphim attacks!', vid = '', bank = '', cue = '', faction = 'UEF'},
}

-- Defeat Seraphim ACU / Actor: Gyle / Update 28/09/2015 / VO TODO
M5KillSeraACU = {
  {text = '[Gyle]: A hostile ACU signature has been detected, destroy that commander as soon as possible!', vid = '', bank = '', cue = '', faction = 'UEF'},
}



-- Main Obj Reminder 1 / Actor: Gyle / Update 28/09/2015 / VO TODO
M5MainReminder1 = {
  {text = '[Gyle]: The seraphim still have a foothold in the area! Rectify that immediately!', vid = '', bank = '', cue = '', faction = 'UEF'},
}

-- Main Obj Reminder 2 / Actor: Gyle / Update 28/09/2015 / VO TODO
M5MainReminder2 = {
  {text = '[Gyle]: There are still seraphim forces in the vicinity commander,', vid = '', bank = '', cue = '', faction = 'UEF'},
}



-- Sera ACU Defeated / Actor: Gyle / Update 28/09/2015 / VO TODO
M5SeraDefeated = {
  {text = '[Gyle]: The enemy ACU is showing up as destroyed! Excellent work commander!', vid = '', bank = '', cue = '', faction = 'UEF'},
}

-- Sera ACU Defeated Base remains / Actor: Gyle / Update 28/09/2015 / VO TODO
M5SeraBaseRemains = {
  {text = '[Gyle]: The enemy base remains and is still operational. Neutralise everything in the area.', vid = '', bank = '', cue = '', faction = 'UEF'},
}



-- sACU on Losing Defences / Actor: Morax / Update 28/09/2015 / VO TODO
sACULoseDef = {
  {text = '[Morax]: My defenses are crumbling! The Seraphim are going to destroy my base!', vid = '', bank = 'Morax_VO', cue = 'defcrumb', faction = 'UEF'},
}

-- sACU on Losing Factory / Actor: Morax / Update 28/09/2015 / VO TODO
sACULoseFac = {
  {text = '[Morax]: One of my factories has been destroyed!', vid = '', bank = 'Morax_VO', cue = 'facdown', faction = 'UEF'},
}

-- sACU on Taking Damage / Actor: Morax / Update 28/09/2015 / VO TODO
sACUTakesDmg = {
  {text = '[Morax]: I\'m getting incoming fire!', vid = '', bank = 'Morax_VO', cue = 'acudamage1', faction = 'UEF'},
}

-- sACU Damaged 25% / Actor: Morax / Update 28/09/2015 / VO TODO
sACUDamaged25 = {
  {text = '[Morax]: Commander, I have received some light fire, but everything is still fully operational.', vid = '', bank = 'Morax_VO', cue = 'lightfireok', faction = 'UEF'},
}

-- sACU Damaged 50% / Actor: Morax / Update 28/09/2015 / VO TODO
sACUDamaged50 = {
  {text = '[Morax]: My armour has suffered minor damage, but I\'m fine.', vid = '', bank = 'Morax_VO', cue = 'minordamage', faction = 'UEF'},
}

-- sACU Damaged 75% / Actor: Morax / Update 28/09/2015 / VO TODO
sACUDamaged75 = {
  {text = '[Morax]: I have received heavy damage! I need support!', vid = '', bank = 'Morax_VO', cue = 'acu75damage', faction = 'UEF'},
}

-- sACU Damaged 90% / Actor: Morax / Update 28/09/2015 / VO TODO
sACUDamaged90 = {
  {text = '[Morax]: Systems report critical damage! I can\'t hold out much longer!', vid = '', bank = 'Morax_VO', cue = 'acucritial', faction = 'UEF'},
}



-- sACU Rescued1 / Actor: Gyle / Update 30/08/2015 / VO TODO
sACURescued1 = {
  {text = '[Gyle]: The Seraphim base has been destroyed and the path to Morax is clear. We\'re extracting him immediately.', vid = '', bank = '', cue = '', faction = 'UEF'},
}

-- sACU Rescued2 / Actor: Morax / Update 30/08/2015 / VO TODO
sACURescued2 = {
  {text = '[Morax]: Thanks for helping me out commander, I wouldn\'t have made it on my own.', vid = '', bank = 'Morax_VO', cue = 'thanks', faction = 'UEF'},
}

-- Secondary Obj Destroy Seraphim Island Bases / Actor: Gyle / Update 28/09/2015 / VO TODO
IslandBasesKill = {
  {text = '[Gyle]: A heavy seraphim naval presence has been detected on the nearby islands. You are to destroy them without delay.', vid = '', bank = '', cue = '', faction = 'UEF'},
}

-- Secondary Obj First Island Base Destroyed / Actor: Gyle / Update 28/09/2015 / VO TODO
IslandBase1Killed = {
  {text = '[Gyle]: The first island base has been destroyed. Proceed onto the next base.', vid = '', bank = '', cue = '', faction = 'UEF'},
}

-- Secondary Obj Second Island Base Destroyed / Actor: Gyle / Update 28/09/2015 / VO TODO
IslandBase2Killed = {
  {text = '[Gyle]: All key structures have been eliminated, move into position and deal with the last base.', vid = '', bank = '', cue = '', faction = 'UEF'},
}

-- Secondary Obj All Island Base Destroyed / Actor: Gyle, sACU / Update 28/09/2015 / VO TODO
IslandBaseAllKilled = {
  {text = '[Gyle]: All seraphim island bases are registering as inactive. Clean up any remaining forces and focus on your other objectives. Good work Commander!', vid = '', bank = '', cue = '', faction = 'UEF'},
  --{text = '[]:', vid = '', bank = '', cue = '', faction = 'UEF'},
}

-- Secondary Obj All Island Base Destroyed, no Civs left / Actor: Gyle / Update 28/09/2015 / VO TODO
IslandBaseAllKilledNoCiv = {
  {text = '[Gyle]: We have defeated the seraphim on this island, but at the cost of many lives.', vid = '', bank = '', cue = '', faction = 'UEF'},
}



-- Secondary Obj Protect Civs / Actor: Chief Johnson  / 06/10/2015 / VO Ready
M5ProtectCivs = {
  {text = '[Chief Johnson]: There is a civilian installation on this island, you need to protect it from the seraphim attacks!', vid = '', bank = 'ChJ_VO1', cue = 'M5ProtectCivs', faction = 'UEF'},
}

-- Secondary Obj Protect Civs Failed / Actor: Chief Johnson  / 06/10/2015 / VO Ready
M5CivsDied = {
  {text = '[Chief Johnson]: The Seraphim have wiped out the civilian installation on the island, there is nothing left.', vid = '', bank = 'ChJ_VO1', cue = 'M5CivsDied', faction = 'UEF'},
}

-- 4 buildings above min / Actor: Chief Johnson  / 06/10/2015 / VO Ready
LosingCivs1 = {
  {text = '[Chief Johnson]: Only a few critical buildings remain, they must be protected!', vid = '', bank = 'ChJ_VO1', cue = 'LosingCivs1', faction = 'UEF'},
}

-- 1 buildings above min / Actor:  Chief Johnson / Update 06/10/2015 / VO Ready
LosingCivs2 = {
  {text = '[Chief Johnson]: We cannot afford to lose anymore civilian structures commander!', vid = '', bank = 'ChJ_VO1', cue = 'LosingCivs2', faction = 'UEF'},
}



-- Secondary obj 3 Evacuate Civs / Actor: Chief Johnson / 06/10/2015 / VO Ready
M5TrucksReady = {
  {text = '[Chief Johnson]: Commander, there are a number of civilian trucks in need of evacuation. You need to get them to the quantum gate as soon as possible.', vid = '', bank = 'ChJ_VO1', cue = 'M5TrucksReady', faction = 'UEF'},
}

-- Trucks taking damage 1 / Actor: Chief Johnson / Update 06/10/2015 / VO Ready
M5TruckDamaged1 = {
  {text = '[Chief Johnson]: The civilian trucks are taking damage! Protect the civilians!', vid = '', bank = 'ChJ_VO1', cue = 'M5TruckDamaged1', faction = 'UEF'},
}

-- Trucks taking damage 2 / Actor: Chief Johnson / Update 06/10/2015 / VO Ready
M5TruckDamaged2 = {
  {text = '[Chief Johnson]: The civilians are under attack, you need to get them out of here safely!', vid = '', bank = 'ChJ_VO1', cue = 'M5TruckDamaged2', faction = 'UEF'},
}


-- 1 truck destroyed / Actor: Chief Johnson / Update 06/10/2015 / VO Ready
M5TruckDestroyed1 = {
  {text = '[Chief Johnson]: We\'ve lost contact with a civilian truck! The rest need to be evacuated immediately!', vid = '', bank = 'ChJ_VO1', cue = 'M5TruckDestroyed1', faction = 'UEF'},
}

-- 2 trucks destroyed / Actor: Chief Johnson / Update 06/10/2015 / VO Ready
M5TruckDestroyed2 = {
  {text = '[Chief Johnson]: Another truck has been destroyed! We need to rescue the civilians!', vid = '', bank = 'ChJ_VO1', cue = 'M5TruckDestroyed2', faction = 'UEF'},
}

-- 3 trucks destroyed / Actor: Chief Johnson / Update 06/10/2015 / VO Ready
M5TruckDestroyed3 = {
  {text = '[Chief Johnson]: A third truck has been destroyed! Send aid at once!', vid = '', bank = 'ChJ_VO1', cue = 'M5TruckDestroyed3', faction = 'UEF'},
}


-- All trucks destroyed, objective failed / Actor: Chief Johnson / Update 06/10/2015 / VO Ready
M5AllTrucksDestroyed = {
  {text = '[Chief Johnson]: Commander, there are no more trucks remaining, all of the civilians have been killed.', vid = '', bank = 'ChJ_VO1', cue = 'M5AllTrucksDestroyed', faction = 'UEF'},
}

-- objective complete / Actor: Chief Johnson / Update 06/10/2015 / VO Ready
M5AllTruckRescued = {
  {text = '[Chief Johnson]: All civilians have been evacuated, good work commander!', vid = '', bank = 'ChJ_VO1', cue = 'M5AllTruckRescued', faction = 'UEF'},
}

-- 1 truck rescued / Actor: Chief Johnson / Update 06/10/2015 / VO Ready
M5TruckRescued1 = {
  {text = '[Chief Johnson]: The first convoy has successfully left the operation area.', vid = '', bank = 'ChJ_VO1', cue = 'M5TruckRescued1', faction = 'UEF'},
}

-- 2 trucks rescued / Actor: Chief Johnson / Update 06/10/2015 / VO Ready
M5TruckRescued2 = {
  {text = '[Chief Johnson]: Another civilian truck has been successfully evacuated!', vid = '', bank = 'ChJ_VO1', cue = 'M5TruckRescued2', faction = 'UEF'},
}



---------------
-- Mission 6
---------------



-- Second Sera ACU gates in / Actor: Gyle / Update 28/09/2015 / VO TODO
M6SecondSeraACU = {
  {text = '[Gyle]: Commander, we\'re detecting a second ACU signature in the area, an enemy commander has just gated in!', vid = '', bank = '', cue = '', faction = 'UEF'},
}

-- invasion announcement / Actor: Gyle / Update 28/09/2015 / VO TODO
M6InvCount1 = {
  {text = '[Gyle]: The Seraphim are planning a massive attack, our intel tells us that you have no more than 30 minutes before it\'s launched!', vid = '', bank = '', cue = '', faction = 'UEF'},
}

-- second invasion countdown / Actor: Gyle / Update 28/09/2015 / VO TODO
M6InvCount2 = {
  {text = '[Gyle]: The activity of the enemy bases suggests you have no more than 15 minutes before all hell breaks lose! Get a move on!', vid = '', bank = '', cue = '', faction = 'UEF'},
}

-- third invasion countdown / Actor: Gyle / Update 28/09/2015 / VO TODO
M6InvCount3 = {
  {text = '[Gyle]: The enemy attack is imminent! You have less than 5 minutes left!', vid = '', bank = '', cue = '', faction = 'UEF'},
}

-- Massive sera attacks / Actor: Gyle / Update 28/09/2015 / VO TODO
M6SeraAttack = {
  {text = '[Gyle]: Hostile Signatures are off the charts! The full scale invasion has just been launched, you need to get off planet, now!', vid = '', bank = '', cue = '', faction = 'UEF'},
}



---------------
-- Enemy Taunts
---------------



-- Taunt01 On losing a large attack force / Actor: Thel-Uuthow / Update: 06/28/2007 / VO Ready
TAUNT1 = {
  {text = '[Zottoo-Zithutin]: [Language Not Recognized]', vid = 'X03_Thel-Uuthow_T01_04320.sfd', bank = 'X03_VO', cue = 'X03_Thel-Uuthow_T01_04320', faction = 'Seraphim'},
}

-- Taunt02 On losing a large attack force / Actor: Thel-Uuthow / Update: 06/28/2007 / VO Ready
TAUNT2 = {
  {text = '[Zottoo-Zithutin]: [Language Not Recognized]', vid = 'X03_Thel-Uuthow_T01_04322.sfd', bank = 'X03_VO', cue = 'X03_Thel-Uuthow_T01_04322', faction = 'Seraphim'},
}

-- Taunt01 On losing defensive structures / Actor: Thel-Uuthow / Update: 06/28/2007 / VO Ready
TAUNT3 = {
  {text = '[Zottoo-Zithutin]: [Language Not Recognized]', vid = 'X03_Thel-Uuthow_T01_04324.sfd', bank = 'X03_VO', cue = 'X03_Thel-Uuthow_T01_04324', faction = 'Seraphim'},
}

-- Taunt02 On losing defensive structures / Actor: Thel-Uuthow / Update: 06/28/2007 / VO Ready
TAUNT4 = {
  {text = '[Zottoo-Zithutin]: [Language Not Recognized]', vid = 'X03_Thel-Uuthow_T01_04325.sfd', bank = 'X03_VO', cue = 'X03_Thel-Uuthow_T01_04325', faction = 'Seraphim'},
}

-- Taunt01 On losing resource structures / Actor: Thel-Uuthow / Update: 06/28/2007 / VO Ready
TAUNT5 = {
  {text = '[Zottoo-Zithutin]: [Language Not Recognized]', vid = 'X03_Thel-Uuthow_T01_04328.sfd', bank = 'X03_VO', cue = 'X03_Thel-Uuthow_T01_04328', faction = 'Seraphim'},
}

-- Taunt02 On losing resource structures / Actor: Thel-Uuthow / Update: 06/28/2007 / VO Ready
TAUNT12 = {
  {text = '[Zottoo-Zithutin]: [Language Not Recognized]', vid = 'X03_Thel-Uuthow_T01_04330.sfd', bank = 'X03_VO', cue = 'X03_Thel-Uuthow_T01_04330', faction = 'Seraphim'},
}

-- Taunt01 On attacking / Actor: Thel-Uuthow / Update: 06/28/2007 / VO Ready
TAUNT14 = {
  {text = '[Zottoo-Zithutin]: [Language Not Recognized]', vid = 'X03_Thel-Uuthow_T01_04332.sfd', bank = 'X03_VO', cue = 'X03_Thel-Uuthow_T01_04332', faction = 'Seraphim'},
}

-- Taunt01 On destroying defensive structure / Actor: Thel-Uuthow / Update: 06/28/2007 / VO Ready
TAUNT16 = {
  {text = '[Zottoo-Zithutin]: [Language Not Recognized]', vid = 'X03_Thel-Uuthow_T01_04334.sfd', bank = 'X03_VO', cue = 'X03_Thel-Uuthow_T01_04334', faction = 'Seraphim'},
}

-- Taunt01 On destroying resource structure / Actor: Thel-Uuthow / Update: 06/28/2007 / VO Ready
TAUNT18 = {
  {text = '[Zottoo-Zithutin]: [Language Not Recognized]', vid = 'X03_Thel-Uuthow_T01_04336.sfd', bank = 'X03_VO', cue = 'X03_Thel-Uuthow_T01_04336', faction = 'Seraphim'},
}

-- Taunt01 On building an experimental / Actor: Thel-Uuthow / Update: 06/28/2007 / VO Ready
TAUNT20 = {
  {text = '[Zottoo-Zithutin]: [Language Not Recognized]', vid = 'X03_Thel-Uuthow_T01_04338.sfd', bank = 'X03_VO', cue = 'X03_Thel-Uuthow_T01_04338', faction = 'Seraphim'},
}

-- Taunt01 On damaging player ACU 50% / Actor: Thel-Uuthow / Update: 06/28/2007 / VO Ready
TAUNT23 = {
  {text = '[Zottoo-Zithutin]: [Language Not Recognized]', vid = 'X03_Thel-Uuthow_T01_04340.sfd', bank = 'X03_VO', cue = 'X03_Thel-Uuthow_T01_04340', faction = 'Seraphim'},
}

-- Taunt02 On damaging player ACU 50% / Actor: Thel-Uuthow / Update: 06/28/2007 / VO Ready
TAUNT24 = {
  {text = '[Zottoo-Zithutin]: [Language Not Recognized]', vid = 'X03_Thel-Uuthow_T01_04342.sfd', bank = 'X03_VO', cue = 'X03_Thel-Uuthow_T01_04342', faction = 'Seraphim'},
}

-- Taunt01 UEF / Actor: Thel-Uuthow / Update: 06/28/2007 / VO Ready
TAUNT26 = {
  {text = '[Zottoo-Zithutin]: [Language Not Recognized]', vid = 'X03_Thel-Uuthow_T01_04344.sfd', bank = 'X03_VO', cue = 'X03_Thel-Uuthow_T01_04344', faction = 'Seraphim'},
}

-- Taunt01 Cybran / Actor: Thel-Uuthow / Update: 06/28/2007 / VO Ready
TAUNT28 = {
  {text = '[Zottoo-Zithutin]: [Language Not Recognized]', vid = 'X03_Thel-Uuthow_T01_04346.sfd', bank = 'X03_VO', cue = 'X03_Thel-Uuthow_T01_04346', faction = 'Seraphim'},
}

-- Taunt01 Aeon / Actor: Thel-Uuthow / Update: 06/28/2007 / VO Ready
TAUNT30 = {
  {text = '[Zottoo-Zithutin]: [Language Not Recognized]', vid = 'X03_Thel-Uuthow_T01_04348.sfd', bank = 'X03_VO', cue = 'X03_Thel-Uuthow_T01_04348', faction = 'Seraphim'},
}

-- Taunt01 At 50% health / Actor: Thel-Uuthow / Update: 06/28/2007 / VO Ready
TAUNT32 = {
  {text = '[Zottoo-Zithutin]: [Language Not Recognized]', vid = 'X03_Thel-Uuthow_T01_04350.sfd', bank = 'X03_VO', cue = 'X03_Thel-Uuthow_T01_04350', faction = 'Seraphim'},
}

-- Taunt01 On death / Actor: Thel-Uuthow / Update: 06/28/2007 / VO Ready
TAUNT34 = {
  {text = '[Zottoo-Zithutin]: [Language Not Recognized]', vid = 'X03_Thel-Uuthow_T01_04352.sfd', bank = 'X03_VO', cue = 'X03_Thel-Uuthow_T01_04352', faction = 'Seraphim'},
}
