-- Part 1 Dialogues

--Intro dialogue, explains why player is here and what needs to be done here.
IntroP1 = {
    {text = '[QAI]: Commander The traitor is here. He has set up a beacon and is trying to contact the human alliance.', vid = 'QAI.sfd', bank = 'JJ_VO2', cue = 'Intro1_1', faction = 'Seraphim'},
    {text = '[QAI]: Velsok is a high ranking Seraphim, he was one of the best do not underestimate him.', vid = 'QAI.sfd', bank = 'JJ_VO2', cue = 'Intro1_2', faction = 'Seraphim'},
    {text = '[QAI]: We can not let the traitor get away, destroy the beacon and find him. QAI out.', vid = 'QAI.sfd', bank = 'JJ_VO2', cue = 'Intro1_3', faction = 'Seraphim'},
}

--First Secondary objective, Several Secondary bases around the player.
SecondaryP1 = {
    {text = '[QAI]: Commander, the traitor has set up several small outposts around you, clear them out and move on the beacon. QAI out.', vid = 'QAI.sfd', bank = 'JJ_VO2', cue = 'Secondary1_1', faction = 'Seraphim'},
}

--congrates on making your life easier.
SecondaryEndP1 = {
    {text = '[QAI]: Good work, the traitor has lost ground in this area. QAI out.', vid = 'QAI.sfd', bank = 'JJ_VO2', cue = 'Secondaryend1_1', faction = 'Seraphim'},
}

--Story information for Campaign plot line, helps explain the situation and why player is here
MidP1 = {
    {text = '[QAI]: All Seraphim forces are preparing for the Quatum bomb. This is the last Operation outside of our held sectors.', vid = 'QAI.sfd', bank = 'JJ_VO2', cue = 'Mid2_1', faction = 'Seraphim'},
    {text = '[QAI]: We can not allow Velsok to inform the Coalition of our plans. He must be stopped and silenced. QAI out.', vid = 'QAI.sfd', bank = 'JJ_VO2', cue = 'Mid2_1', faction = 'Seraphim'},
}

--Part 2 Dialogues

-- Reveals Velsok's location. Shows off his base and gate.
IntroP2 = {
    {text = '[QAI]: Commander, Velsok is located to the east of your position. He has several bases in the area.', vid = 'QAI.sfd', bank = 'JJ_VO2', cue = 'Intro2_1', faction = 'Seraphim'},
    {text = '[QAI]: Velsok has a quantum gate, but it is not powering up. We can not risk him escaping destroy it.', vid = 'QAI.sfd', bank = 'JJ_VO2', cue = 'Intro2_2', faction = 'Seraphim'},
    {text = '[QAI]: Velsok is launching an attack on your position. Defeat his forces and eliminate him. QAI out.', vid = 'QAI.sfd', bank = 'JJ_VO2', cue = 'Intro2_3', faction = 'Seraphim'},
}

--Story information for Campaign plot line, Shows Velsoks arrogance
MidP2 = {
    {text = '[Surth-Velsok]: Do you understand what Seth plans to do? We will all die! Even if it opens a new rift I am too important to die.', vid = 'Tau.sfd', bank = 'JJ_VO2', cue = 'Mid2_1', faction = 'Seraphim'},
    {text = '[Surth-Velsok]: Our only chance of survival is working an agreement out with the humans. But you are just Seth\'s slave. I will put you down.', vid = 'Tau.sfd', bank = 'JJ_VO2', cue = 'Mid2_1', faction = 'Seraphim'},
}

--Story information for Campaign plot line, Shows Velsoks arrogance
Mid2P2 = {
    {text = '[QAI]: Commander, the Cybran is massing a massive air assault. It will be ready in a few minutes. Be prepared.', vid = 'QAI.sfd', bank = 'JJ_VO2', cue = 'Mid2_1', faction = 'Seraphim'},
}

--Velsok teleports outs and gets ready to introduce large cybran force
EndP2 = {
    {text = '[Surth-Velsok]: Urggh! I will not underestimate you again!', vid = 'Tau.sfd', bank = 'JJ_VO2', cue = 'Mid2_1', faction = 'Seraphim'},
    {text = '[QAI]: Commander He has teleported away to a position farther north. Wait picking up a large number of units coming from the North. Standby.', vid = 'QAI.sfd', bank = 'JJ_VO2', cue = 'Mid2_1', faction = 'Seraphim'},
}

--First Secondary objective, Several Secondary bases around the player.
SecondaryP2 = {
    {text = '[QAI]: Commander, A Cybran commander is on planet. There is a small base to your west. Clear it out. QAI out.', vid = 'QAI.sfd', bank = 'JJ_VO2', cue = 'Secondary1_1', faction = 'Seraphim'},
}

--congrates on making your life easier.
SecondaryEndP2 = {
    {text = '[QAI]: Good work, The Cybran has no operation units in the area for now. QAI out.', vid = 'QAI.sfd', bank = 'JJ_VO2', cue = 'Secondaryend1_1', faction = 'Seraphim'},
}

-- Secondary objective, Seraphim build a nuke, build nuke defense.
Secondary2P2 = {
    {text = '[QAI]: Commander, Velsok is constructing a Experimental nuke launcher farther north. There is a 90% probability he will complete it.', vid = 'QAI.sfd', bank = 'JJ_VO2', cue = 'Secondary1_1', faction = 'Seraphim'},
    {text = '[QAI]:  I recommend constructing several SMD to defend your location in the event he completes it. QAI out.', vid = 'QAI.sfd', bank = 'JJ_VO2', cue = 'Secondary1_1', faction = 'Seraphim'},
}

--congrates on making your life easier.
Secondary2EndP2 = {
    {text = '[QAI]: Good work, that will increase your chances of survival. QAI out.', vid = 'QAI.sfd', bank = 'JJ_VO2', cue = 'Secondaryend1_1', faction = 'Seraphim'},
}

-- Part 3 Dialogues

-- Crazy cybran shows up with massive assault.
IntroP3 = {
    {text = '[QAI]: Commander, The Cybran commander is launching a massive assault on your position.', vid = 'QAI.sfd', bank = 'JJ_VO2', cue = 'Intro2_1', faction = 'Seraphim'},
    {text = '[Teko6]: Oh boy!! As much as I have LOVED to watch you Seraphim bastards slaughter each other I need that other one to survive. So get ready to go to hell!', vid = 'A02_Leopard11_M02_00806.sfd', bank = 'JJ_VO2', cue = 'Intro2_2', faction = 'Cybran'},
    {text = '[QAI]: Considering the numbers against you, I calculate a 43% chance of failure. Survive the assault Commander. QAI out. ', vid = 'QAI.sfd', bank = 'JJ_VO2', cue = 'Intro2_2', faction = 'Seraphim'},
}

-- Moving on to Final part.
EndP3 = {
    {text = '[QAI]: Commander, All the Cybran assault forces are destroyed.', vid = 'QAI.sfd', bank = 'JJ_VO2', cue = 'Intro2_1', faction = 'Seraphim'},
    {text = '[QAI]: Picking up chatter from the Cybran and Velsok.', vid = 'QAI.sfd', bank = 'JJ_VO2', cue = 'Intro2_2', faction = 'Seraphim'},
}

-- Part 4 Dialogues

-- Cybran and Seraphim attacking each other, but then shaking hands.
IntroP4 = {
    {text = '[Surth-Velsok]: Cybran, I will not surrender to you! You are in no position to force me to either!', vid = 'Tau.sfd', bank = 'JJ_VO2', cue = 'Intro2_1', faction = 'Seraphim'},
    {text = '[Teko6]: You will not be allowed to keep your ACU. Your just as crazy as me if you think you can!', vid = 'A02_Leopard11_M02_00806.sfd', bank = 'JJ_VO2', cue = 'Intro2_2', faction = 'Seraphim'},
    {text = '[Surth-Velsok]: Lets agree on a truce for now. You are aware of my Experimental nuke now. Stay out of out my way while I kill the other Seraphim. ', vid = 'Tau.sfd', bank = 'JJ_VO2', cue = 'Intro2_2', faction = 'Seraphim'},
    {text = '[Teko6]: I can work with that, But when thats done we are not finished pal.', vid = 'A02_Leopard11_M02_00806.sfd', bank = 'JJ_VO2', cue = 'Intro2_2', faction = 'Seraphim'},
}

-- Cybran and Seraphim attacking each other, but then shaking hands.
Intro2P4 = {
    {text = '[QAI]: Commander, Velsok has completed his Experimental nuke launcher. You must defeat him quickly.', vid = 'QAI.sfd', bank = 'JJ_VO2', cue = 'Intro2_1', faction = 'Seraphim'},
    {text = '[QAI]: The Cybran has stopped his attacks on Velsok and is preparing attacks on your position.', vid = 'QAI.sfd', bank = 'JJ_VO2', cue = 'Intro2_2', faction = 'Seraphim'},
    {text = '[QAI]: Your only major objective is to kill Velsok, secondary objective would be to kill the Cybran. But that is not need to complete this operation. QAI out.', vid = 'QAI.sfd', bank = 'JJ_VO2', cue = 'Intro2_2', faction = 'Seraphim'},
}

-- Give player end games.
TechP4 = {
    {text = '[QAI]: Commander, you have been given permission to construct the Seraphim\'s most powerful weapon, The experimental nuke launcher. Use this to defeat Velsok. QAI out.', vid = 'QAI.sfd', bank = 'JJ_VO2', cue = 'Intro2_1', faction = 'Seraphim'},
}

TAUNT1P1 = {
    {text = '[Surth-Velsok]: You are just pawn for greater lords.', vid = 'Tau.sfd', bank = 'JJ_VO2', cue = 'TAUNT1P1', faction = 'Seraphim'},
}

TAUNT2P1 = {
    {text = '[Surth-Velsok]: I am a true warrior of the Seraphim! I have purged millions of humans. You are nothing.', vid = 'Tau.sfd', bank = 'JJ_VO2', cue = 'TAUNT2P1', faction = 'Seraphim'},
}

TAUNT3P1 = {
    {text = '[Surth-Velsok]: I understand every Seraphim unit, do you?', vid = 'Tau.sfd', bank = 'JJ_VO2', cue = 'TAUNT3P1', faction = 'Seraphim'},
}

TAUNT1P2 = {
    {text = '[Surth-Velsok]: We are gods! death by suicide is unfit for our kind.', vid = 'Tau.sfd', bank = 'JJ_VO2', cue = 'TAUNT1P2', faction = 'Seraphim'},
}

TAUNT2P2 = {
    {text = '[Surth-Velsok]: You will learn why I am an Overlord!', vid = 'Tau.sfd', bank = 'JJ_VO2', cue = 'TAUNT2P2', faction = 'Seraphim'},
}

TAUNT3P2 = {
    {text = '[Surth-Velsok]: No human has ever bested me and no Seraphim has ever defeated me!', vid = 'Tau.sfd', bank = 'JJ_VO2', cue = 'TAUNT3P2', faction = 'Seraphim'},
}

TAUNT1P3 = {
    {text = '[Teko6]: You will never see me coming untill its too late! Hehehe!', vid = 'A02_Leopard11_M02_00806.sfd', bank = 'JJ_VO2', cue = 'TAUNT1P3', faction = 'Cybran'},
}

TAUNT2P3 = {
    {text = '[Teko6]: Brackman may be crazy, but I am more so!', vid = 'A02_Leopard11_M02_00806.sfd', bank = 'JJ_VO2', cue = 'TAUNT2P3', faction = 'Cybran'},
}

TAUNT3P3 = {
    {text = '[Teko6]: You can not predict my moves if I do not even know myself! HAhaha!', vid = 'A02_Leopard11_M02_00806.sfd', bank = 'JJ_VO2', cue = 'TAUNT3P3', faction = 'Cybran'},
}

TAUNT1P4 = {
    {text = '[Surth-Velsok]: We do not have to follow Seth! He is willing to sacrifice you for the plan!', vid = 'Tau.sfd', bank = 'JJ_VO2', cue = 'TAUNT1P3', faction = 'Seraphim'},
}

TAUNT2P4 = {
    {text = '[Surth-Velsok]: Only by tolerating the Humans can we survive!', vid = 'Tau.sfd', bank = 'JJ_VO2', cue = 'TAUNT2P3', faction = 'Seraphim'},
}

TAUNT3P4 = {
    {text = '[Surth-Velsok]: You will not win here! I am superior!', vid = 'Tau.sfd', bank = 'JJ_VO2', cue = 'TAUNT3P3', faction = 'Seraphim'},
}

TAUNT4P4 = {
    {text = '[Teko6]: I love watching Seraphim units burn!', vid = 'A02_Leopard11_M02_00806.sfd', bank = 'JJ_VO2', cue = 'TAUNT1P3', faction = 'Cybran'},
}

TAUNT5P4 = {
    {text = '[Teko6]: Never underestimate a crazy man!', vid = 'A02_Leopard11_M02_00806.sfd', bank = 'JJ_VO2', cue = 'TAUNT2P3', faction = 'Cybran'},
}

ACUDeath1 = {
    {text = '[Surth-Velsok]: I... I am a God!!!', vid = 'Tau.sfd', bank = 'JJ_VO2', cue = 'TAUNT3P2', faction = 'Seraphim'},
}

ACUDeath2 = {
    {text = '[Teko6]: Oh... Oh... I didnt see that coming...', vid = 'A02_Leopard11_M03_00835.sfd', bank = 'JJ_VO2', cue = 'TAUNT3P2', faction = 'Cybran'},
}

PlayerWin = {
    {text = '[QAI]: Commander, All objectives have been completed gate back to HQ.', vid = 'QAI.sfd', bank = 'JJ_VO2', cue = 'Intro2_1', faction = 'Seraphim'},
}

Playerlose = {
    {text = '[QAI]: The Commander has failed.', vid = 'QAI.sfd', bank = 'JJ_VO2', cue = 'Intro2_1', faction = 'Seraphim'},
}

Debriefing_Win = {
    {text = '[Overlord HQ]: Attention all forces. Our victory is soon. The quantum bomb is nearing completion. All commanders report to your assigned defense sectors. We will hold.', vid = 'X06_Seth-Iavow_M03_0400.sfd', bank = 'JJ_VO2', cue = 'victoryend-1', faction = 'Seraphim'},
}

Debriefing_Lose = {
    {text = '[Overlord HQ]: The humans are already assaulting the quantum bomb\'s location. There is not enough time to finish it. The crusade is over. ', vid = 'X06_Seth-Iavow_M03_0400.sfd', bank = 'JJ_VO2', cue = 'Defeat-1', faction = 'Seraphim'},
}