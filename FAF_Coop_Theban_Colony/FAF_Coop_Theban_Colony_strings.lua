-----------
-- Story --
-----------
-- General overview:
-- 		UEF is attack a Cybran colony and player's task is to defend and evacuate. Mission designed for at least 2 players.
-- 	  
-- Prologue
-- 		Just showing of my scripting skills, jokes ^^ tehehe
--		Cybran settlement under heavy UEF attack. Player controls sACU and task is to defend the civilian structures.
--		Impossible, player dying after few minutes.
--
-- Mission 2
--		Map moves to the east and reinforting commander will spawn in two different locations. Task is to defend remaining cybran settlements
--		against UEF attacks.
--		After few minutes a new objective is revealed:
--		Destroy 2 UEF T3 Artilleries that are shooting on other settlements. Those are in the middle of UEF base.
--
--			TODO: Think about better position for the artilleries? They might not need to be in the middle of the base. So it's easier to kill them.
--				  And UEF base won't be destroyed by finishing this objective.
--				  Then tune everythng around, base design, place some dead units around. Set better attacks from the bases, etc... see Issues.
--
-- Mission 3
--		Evacuating the north settlement that was under arty fire from the first mission.
--		Incoming UEF attacks.
--
--			TODO: New idea is to let player decide what he wants to do, either evacuate civs or kill UEF commander.
--				  Depending on the choice the map will expand more the to west to reveal UEF base.
-- 				  All bases, attacks, everything needs to be made.



OPERATION_NAME = '<LOC FAF_Coop_Theban_Colony_OPERATION_NAME>Theban Colony'


-------------
-- Debriefing
-------------
-- Showed on the score screen if player wins
Debriefing_Win = {
    {text = '<LOC FAF_Coop_Theban_Colony_Debriefing_Win_1>You win', faction = 'Cybran'},
}

-- Showed on the score screen if player loses
Debriefing_Lose = {
    {text = '<LOC FAF_Coop_Theban_Colony_Debriefing_Lose_1>The UEF launched a major assault against our colony on Theban. Many of the symbionts were captured and several of our commander died during the evacuation.', faction = 'Cybran'},
}



-----------
-- Prologue
-----------
M1_DefendCivs = {
	{text = '<LOC FAF_Coop_Theban_Colony_M1_DefendCivs_1>[QAI]: Hold on a bit longer commander. The reinforcements should arrive soon.', vid = 'QAI.sfd', bank = '', cue = '', faction = 'Cybran'},
}

M1_Reinforcements = {
	{text = '<LOC FAF_Coop_Theban_Colony_M1_Reinforcements_1>[Cybran Commander]: My base to the south west was destroyed. I\'m sending the rest of my units to assist you.', vid = 'Hex5.sfd', bank = '', cue = '', faction = 'Cybran'},
}

M1_sACU_Dead = {
	{text = '<LOC FAF_Coop_Theban_Colony_M1_sACU_Dead_1>[QAI]: Commander, what\'s your status?', vid = 'QAI.sfd', bank = '', cue = '', faction = 'Cybran'},
}



-- Primary Objective
M1P1Title = '<LOC FAF_Coop_Theban_Colony_M1P1Title>Defend the Colony'

-- Primary Objective
M1P1Description = '<LOC FAF_Coop_Theban_Colony_M1P1Description>The UEF has launched a full planetary assault. We must repeal the attack and evacuate the colonies.'



------------
-- Mission 2
------------



-- Intro
M2_Intro_1 = {
	{text = '<LOC FAF_Coop_Theban_Colony_M2_Intro_1_1>[Ops]: UEF is progressing to on the other settlements. Your task is to defend them.', vid = '', bank = '', cue = '', faction = 'Cybran'},
}

M2_Intro_2 = {
	{text = '<LOC FAF_Coop_Theban_Colony_M2_Intro_2_1>[Ops]: Gating in first ACU. Act quicly commander. UEF units are not far.', vid = '', bank = '', cue = '', faction = 'Cybran'},
}

M2_Intro_3 = {
	{text = '<LOC FAF_Coop_Theban_Colony_M2_Intro_3_1>[Ops]: This is one of the lasts bases in the area. Defeat the attacking forces and regroup with commander to your south.', vid = '', bank = '', cue = '', faction = 'Cybran'},
}

M2_Intro_4 = {
	{text = '<LOC FAF_Coop_Theban_Colony_M2_Intro_4_1>[Ops]: Both commanders are on the planet. Good luck.', vid = '', bank = '', cue = '', faction = 'Cybran'},
}



M2_KillAttackers = {
	{text = '<LOC FAF_Coop_Theban_Colony_M2_KillAttackers_1>[Ops]: Your primary objective is to defend the civilians. Defeat enemy focres closing to your location.', vid = '', bank = '', cue = '', faction = 'Cybran'},
}

M2_Subplot_1 = {
	{text = '<LOC FAF_Coop_Theban_Colony_M2_Subplot_1_1>[Ops]: Scans show that the UEF base is already well established.', vid = '', bank = '', cue = '', faction = 'Cybran'},
}

M2_KillArty = {
	{text = '<LOC FAF_Coop_Theban_Colony_M2_KillArty_1>[Cybran Commander]: HQ, the main city is under artillery fire. I don\'t have enough resources to kill those artilleries and defend the city from UEF attacks. I need help.', vid = '', bank = '', cue = '', faction = 'Cybran'},
	{text = '<LOC FAF_Coop_Theban_Colony_M2_KillArty_2>[Ops]: Commanders, those heavy artillery installations are in your location. Destroy them as fast as you can.', vid = '', bank = '', cue = '', faction = 'Cybran'},
	{text = '<LOC FAF_Coop_Theban_Colony_M2_KillArty_3>[UEF ACU]: You\'ll die here Cybran.', vid = '', bank = '', cue = '', faction = 'UEF'},
}

---------
-- Taunts
---------

TAUNT1 = {
	{text = '<LOC FAF_Coop_Theban_Colony_TAUNT1_1>[Barney]: You\'ll die here, Cybran.', vid = 'Fletcher.sfd', bank = '', cue = '', faction = 'UEF'},
}

TAUNT2 = {
	{text = '<LOC FAF_Coop_Theban_Colony_TAUNT2_1>[Barney]: I got you now!', vid = 'Fletcher.sfd', bank = '', cue = '', faction = 'UEF'},
}