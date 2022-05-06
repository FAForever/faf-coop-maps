
-- Part 1 Dialogues

--Intro dialogue, explains why player is here and what needs to be done here.
IntroP1 = {
    {text = '[Overlord HQ]: Commander welcome to Tarv-3 a former UEF colony world. We plan to use it to evacuate our troops from the Core into open space.', vid = 'X06_Seth-Iavow_M03_03997.sfd', bank = 'JJ_VO2', cue = 'Intro1_1', faction = 'Seraphim'},
    {text = '[Overlord HQ]: Initial scans report that seraphim forces recently fought here, we also are picking up a large UEF base in the area.', vid = 'X06_Seth-Iavow_M03_03997.sfd', bank = 'JJ_VO2', cue = 'Intro1_2', faction = 'Seraphim'},
    {text = '[Overlord HQ]: We have limited time commander, you must quicky deal with this UEF commander and establish a foothold for our retreat.', vid = 'X06_Seth-Iavow_M03_03997.sfd', bank = 'JJ_VO2', cue = 'Intro1_3', faction = 'Seraphim'},
    {text = '[Overlord HQ]: Destroy all UEF forces and discover what happened to Yuth and his forces, HQ out', vid = 'X06_Seth-Iavow_M03_03997.sfd', bank = 'JJ_VO2', cue = 'Intro1_4', faction = 'Seraphim'},
}

--First Secondary objective, Tac missiles will bother player, but they can ignore if needed.
SecondaryP1 = {
    {text = '[Overlord HQ]: Commander we are picking up Tac Missile launchers to your northwest and southeast in small bases, these may pose a problem to you but sufficant TMD will stop them as well as destroying them, it\'s your choice. HQ out.', vid = 'X06_Seth-Iavow_M03_03997.sfd', bank = 'JJ_VO2', cue = 'Secondary1_1', faction = 'Seraphim'},
}

--congrates on making your life easier.
SecondaryEndP1 = {
    {text = '[Overlord HQ]: Good work, with those Tac Missile launchers out of the way your landing zone is closer to secured. HQ out.', vid = 'X06_Seth-Iavow_M03_03997.sfd', bank = 'JJ_VO2', cue = 'Secondaryend1_1', faction = 'Seraphim'},
}

--urges the player to be involved in the water, if not they will be at disadvantage later on.
NavalwarningP1 = {
    {text = '[Overlord HQ]: Commander The UEF base to your west has a series of naval factories, we recommended getting your own naval presence quickly. HQ out.', vid = 'X06_Seth-Iavow_M03_03997.sfd', bank = 'JJ_VO2', cue = 'Secondary21_1', faction = 'Seraphim'},
}

--Story information for Campaign plot line, helps explain the situation and why player is here
MidP1 = {
    {text = '[Overlord HQ]: Time is short commander, Coalition forces are attempting to pin down our retreat to a select few worlds. We are limited in our resources after the loss of the main body of the Order and QAI\'s shutdown by Brackman.', vid = 'X06_Seth-Iavow_M03_03997.sfd', bank = 'JJ_VO2', cue = 'Mid2_1', faction = 'Seraphim'},
    {text = '[Overlord HQ]: We must get the bulk of our forces out into open space, before the Coalition has the chance to cut off our escape routes. HQ out.', vid = 'X06_Seth-Iavow_M03_03997.sfd', bank = 'JJ_VO2', cue = 'Mid2_1', faction = 'Seraphim'},
}


--Part 2 Dialogues

-- Reveals Aeon and Cybran forces and that this whole Operation was a trap! Insert Adrimal Ackbar Memes. Shows player Jammer and tells them to kill it, while showing the enemy counter attack coming.
IntroP2 = {
    {text = '[Overlord HQ]: Commander we are detecting several different energy signatures to your south.. Wait! Aeon forces?', vid = 'X06_Seth-Iavow_M03_03997.sfd', bank = 'JJ_VO2', cue = 'Intro2_1', faction = 'Seraphim'},
    {text = '[Overlord HQ]: This is some kind of trap! We are starting the recall process to get you out of there.', vid = 'X06_Seth-Iavow_M03_03997.sfd', bank = 'JJ_VO2', cue = 'Intro2_2', faction = 'Seraphim'},
    {text = '[Overlord HQ]: Oh no, the Qauntum Network is being jammed, the UEF commander has a Jammer in his base!', vid = 'X06_Seth-Iavow_M03_03997.sfd', bank = 'JJ_VO2', cue = 'Intro2_3', faction = 'Seraphim'},
    {text = '[Overlord HQ]: Defeat the UEF Commander and destroy that jammer, We can\'t recall your ACU untill the jammer is gone. HQ out. ', vid = 'X06_Seth-Iavow_M03_03997.sfd', bank = 'JJ_VO2', cue = 'Intro2_4', faction = 'Seraphim'},
}

-- Warn player of a T3 arty being build and suggests some counters
Secondary1P2 = {
    {text = '[Overlord HQ]: Commander The Aeon forces, are constructing a T3 Artillery installation, either build up more shields or take it out before its finished. HQ out.', vid = 'X06_Seth-Iavow_M03_03997.sfd', bank = 'JJ_VO2', cue = 'Secondary12_1', faction = 'Seraphim'},
}

-- tells the player nice job clearing out Arty
Secondary1EndP2 = {
    {text = '[Overlord HQ]: Good work that\'s one less problem to deal with. HQ out.', vid = 'X06_Seth-Iavow_M03_03997.sfd', bank = 'JJ_VO2', cue = 'Secondaryend12_1', faction = 'Seraphim'},
}

-- Warns player that Aeon and Cybran are adding more pressure to the map.
SupportBasesP2 = {
    {text = '[Overlord HQ]: Commander The Aeon and Cybran are constructing secondary bases over the wreakage of Yuth\'s former bases. Destroy them quickly before they are fully established. HQ out.', vid = 'X06_Seth-Iavow_M03_03997.sfd', bank = 'JJ_VO2', cue = 'Secondary22_1', faction = 'Seraphim'},
}

-- Add some more stress to this already stressful situation.
MidP2 = {
    {text = '[Overlord HQ]: So far we are able to detect four enemy commanders on planet, we can\'t find a way to bypass the Jammer, complete your objectives or you will die here. HQ out.', vid = 'X06_Seth-Iavow_M03_03997.sfd', bank = 'JJ_VO2', cue = 'Mid2_1', faction = 'Seraphim'},
}


-- Part 3 Dialogues

-- Explain mission is now a survival of the fittess and to try and not die.
IntroP3 = {
    {text = '[Overlord HQ]: With the Jammer destroyed we can began the process of recalling your ACU.', vid = 'X06_Seth-Iavow_M03_03997.sfd', bank = 'JJ_VO2', cue = 'Intro3_1', faction = 'Seraphim'},
    {text = '[Overlord HQ]: It seems however, that the Coalition is not willing to let you escape. Several large attack groups are being send from outside your operational range.', vid = 'X06_Seth-Iavow_M03_03997.sfd', bank = 'JJ_VO2', cue = 'Intro3_2', faction = 'Seraphim'},
    {text = '[Overlord HQ]: All you need to do is survive untill we can recall you. HQ out.', vid = 'X06_Seth-Iavow_M03_03997.sfd', bank = 'JJ_VO2', cue = 'Intro3_3', faction = 'Seraphim'},
}

-- When player spots enemy bases tells them to kill them to make life easier.
Secondary1P3 = {
    {text = '[Overlord HQ]: Commander, the Coalition forces have several bases on the edge of your operational area. They within reach of attack, destroying them might buy you more time. HQ out.', vid = 'X06_Seth-Iavow_M03_03997.sfd', bank = 'JJ_VO2', cue = 'Secondary13_1', faction = 'Seraphim'},
}

-- Good job for doing something about the units trying to kill you.
SecondaryEnd1P3 = {
    {text = '[Overlord HQ]: Good work, with those bases gone the pressure on your base should be reduced.', vid = 'X06_Seth-Iavow_M03_03997.sfd', bank = 'JJ_VO2', cue = 'Secondary13_1', faction = 'Seraphim'},
}

--Warn player of the final attack before mission ends. They either survive it and win, or die and game over.
FinalAssaultP3 = {
    {text = '[Overlord HQ]: Commander, We are detecting a massive attack forces approaching your location, Looks like the Coalition is throwing everything its got at you. hold out for just a little longer. HQ out', vid = 'X06_Seth-Iavow_M03_03997.sfd', bank = 'JJ_VO2', cue = 'Secondary13_1', faction = 'Seraphim'},
}

-- You survived!
EndP3 = {
    {text = '[Overlord HQ]: Starting recall process in 5.. 4.. 3.. 2.. 1!', vid = 'X06_Seth-Iavow_M03_03997.sfd', bank = 'JJ_VO2', cue = 'End_1', faction = 'Seraphim'},
}

-- UEF taunts

--Angry boi being angry.
RevealP1  = {
    {text = '[Major Fredrick]:  Another Seraphim? You will soon join your alien buddy in Hell!', vid = 'Graham.sfd', bank = 'JJ_VO2', cue = 'RevealP1', faction = 'UEF'},
}

-- Darn you Alien man
TAUNT1P1 = {
    {text = '[Major Fredrick]: I will make you suffer you alien bastard!', vid = 'Graham.sfd', bank = 'JJ_VO2', cue = 'TAUNT1P1', faction = 'UEF'},
}

-- I think thats how RTS games work tho?
TAUNT2P1 = {
    {text = '[Major Fredrick]: Every unit you lose brings me one step closer to victory!', vid = 'Graham.sfd', bank = 'JJ_VO2', cue = 'TAUNT2P1', faction = 'UEF'},
}

-- Is that a Fact? Pretty sure DPS is faster than Engi build speed bro.
TAUNT3P1 = {
    {text = '[Major Fredrick]: I can rebuild those structures faster than you can destroy them.', vid = 'Graham.sfd', bank = 'JJ_VO2', cue = 'TAUNT3P1', faction = 'UEF'},
}

-- Not when I have 50 PD your not!!
TAUNT1P2 = {
    {text = '[Major Fredrick]: We are going to break your defenses sooner or later!', vid = 'Graham.sfd', bank = 'JJ_VO2', cue = 'TAUNT1P2', faction = 'UEF'},
}

-- thats cause you killed him bro. not cool bro
TAUNT2P2 = {
    {text = '[Major Fredrick]: I have friends to help me Seraphim! what do you have? A corpse!', vid = 'Graham.sfd', bank = 'JJ_VO2', cue = 'TAUNT2P2', faction = 'UEF'},
}

-- Not sure if your scared of the yotha, or the 20 strats coming for your head.
TAUNT3P2 = {
    {text = '[Major Fredrick]: You think your threatening me you alien bastard?! We\'re just getting started!', vid = 'Graham.sfd', bank = 'JJ_VO2', cue = 'TAUNT3P2', faction = 'UEF'},
}

-- sure you can buddy!
ACUDeath1 = {
    {text = '[Major Fredrick]: I can\'t die here! Ahh..Ahhhh!', vid = 'Graham.sfd', bank = 'JJ_VO2', cue = 'TAUNT3P2', faction = 'UEF'},
}

-- Bonus Objective
M2B2Title = 'Kill Spider Bots'
M2B2Description = 'You\'ve Killed %s Cybran experimentals.'

Debriefing_Win = {
    {text = '[Overlord HQ]: Good work getting out of there commander, However your objective is still at hand. We have managed to secure a foothold on Velra and have began to set up gates for the evacuatation. You will support the defense, HQ out.', vid = 'X06_Seth-Iavow_M03_0400.sfd', bank = 'JJ_VO2', cue = 'victoryend-1', faction = 'Seraphim'},
}

Debriefing_Lose = {
    {text = '[Overlord HQ]: We lost one of our best commanders today. We must still attempt to break the blockade if we are to survive!', vid = 'X06_Seth-Iavow_M03_0400.sfd', bank = 'JJ_VO2', cue = 'Defeat-1', faction = 'Seraphim'},
}


