
-- Part 1 Dialogues

--Intro dialogue, explains why player is here and what needs to be done here.
IntroP1 = {
    {text = '[Coalition HQ]: Commander welcome to Tarv-3, A out of the way colony that was destroyed long ago during the Infinite war.', vid = '', bank = 'JJ_VO2', cue = 'Intro1_1', faction = 'UEF'},
    {text = '[Coalition HQ]: The Seraphim are using this planet as A evacuation site to move their troops from the core worlds.', vid = '', bank = 'JJ_VO2', cue = 'Intro1_2', faction = 'UEF'},
    {text = '[Coalition HQ]: You have two Seraphim bases blocking the path to the gates.', vid = '', bank = 'JJ_VO2', cue = 'Intro1_3', faction = 'UEF'},
    {text = '[Coalition HQ]: Destroy both Seraphim bases and move on to the gates. HQ out.', vid = '', bank = 'JJ_VO2', cue = 'Intro1_4', faction = 'UEF'},
}
-- Let the player know some of the story going on for the Campaign
MidP1 = {
    {text = '[Coalition HQ]: Dozens of Seraphim and Order commanders are escaping to open space.', vid = '', bank = 'JJ_VO2', cue = 'Intro1_1', faction = 'UEF'},
    {text = '[Coalition HQ]: We have several squads of commanders attempting to intercept and destroy them, but we can not cover every planet.', vid = '', bank = 'JJ_VO2', cue = 'Intro1_2', faction = 'UEF'},
    {text = '[Coalition HQ]: We can not allow the Seraphim to use this world as an escape route, finish your objectives Commander, HQ out.', vid = '', bank = 'JJ_VO2', cue = 'Intro1_3', faction = 'UEF'},
}

-- Arty hurts, make it disappear.
SecondaryP1 = {
    {text = '[Coalition HQ]: Commander we are detecting a number of T2 artillery surounding the waterway destroy them, HQ out.', vid = '', bank = 'JJ_VO2', cue = 'Intro2_1', faction = 'UEF'},
}

-- pat on the back for making your own life easier.
SecondaryEndP1 = {
    {text = '[Coalition HQ]: Good work, the waterway is clear, push on the bases, HQ out.', vid = '', bank = 'JJ_VO2', cue = 'Intro2_1', faction = 'UEF'},
}

-- look at all the Factories going to send stuff to kill you.
IntroP2 = {
    {text = '[Coalition HQ]: There are four gates in the area, the first two are guarded by a lower ranked Seraphim commander.', vid = '', bank = 'JJ_VO2', cue = 'Intro3_1', faction = 'UEF'},
    {text = '[Coalition HQ]: He is personally guarding one of the gates and has a land base guarding the other.', vid = '', bank = 'JJ_VO2', cue = 'Intro3_2', faction = 'UEF'},
    {text = '[Coalition HQ]: The third gate has smaller base around it and the fourth gate we are still assessing, destroy the 3 gates and kill the Seraphim, HQ out', vid = '', bank = 'JJ_VO2', cue = 'Intro3_3', faction = 'UEF'},
}

-- Huh I was wondering what those large booms were.
MidP2 = {
    {text = '[Coalition HQ]: Commander we are detecting several Seraphim support commanders across the area.', vid = '', bank = 'JJ_VO2', cue = 'Intro1_1', faction = 'UEF'},
    {text = '[Coalition HQ]: Be careful some of them are equiped with overcharge attacks.', vid = '', bank = 'JJ_VO2', cue = 'Intro1_2', faction = 'UEF'},
    {text = '[Coalition HQ]: Intel on the other Seraphim commander shows that he is building up several nuke launchers. Make sure you have several nuke defense up before you move on to him, HQ out.', vid = '', bank = 'JJ_VO2', cue = 'Intro1_3', faction = 'UEF'},
}

-- Hey look! someone else we have to kill!
SecondaryP2 = {
    {text = '[Coalition HQ]: Commander, we just detected a qauntum warp, a seraphim commander has just gated in. Kill him before he can become a threat. HQ out.', vid = '', bank = 'JJ_VO2', cue = 'IntroP4-1', faction = 'UEF'},
}

-- Shame! Would have loved the hunt for him!
SecondaryEndP2 = {
    {text = '[Coalition HQ]: Good that is one less Seraphim to hunt down, finish your objectives. HQ out.', vid = '', bank = 'JJ_VO2', cue = 'IntroP4-1', faction = 'UEF'},
}

-- Big king Seraphim trying to flea like the coward he is!
IntroP3 = {
    {text = '[Coalition HQ]: Commander the last gate is being guarded by a experienced Seraphim commander.', vid = '', bank = 'JJ_VO2', cue = 'IntroP5-1', faction = 'UEF'},
    {text = '[Coalition HQ]:  Damn it, his gate is powering up! We just used a quantum Jammer to stop him, but its effects will wear off soon!', vid = '', bank = 'JJ_VO2', cue = 'IntroP5-2', faction = 'UEF'},
    {text = '[Coalition HQ]: Kill the Seraphim commander before he can gate out, HQ out.', vid = '', bank = 'JJ_VO2', cue = 'IntroP5-3', faction = 'UEF'},
}

-- King has some goons to deal with.
SecondaryP3 = {
    {text = '[Coalition HQ]: Commander, This experienced Seraphim has 3 hardened Support commanders across the zone, They are the last Seraphim presence on planet.', vid = '', bank = 'JJ_VO2', cue = 'IntroP4-1', faction = 'UEF'},
    {text = '[Coalition HQ]: Kill them if you are able to, HQ out.', vid = '', bank = 'JJ_VO2', cue = 'IntroP4-1', faction = 'UEF'},
}

-- Goons are deleted.
SecondaryEndP3 = {
    {text = '[Coalition HQ]: Good work, all that is left is the main Seraphim, take him out, HQ out.', vid = '', bank = 'JJ_VO2', cue = 'IntroP4-1', faction = 'UEF'},
}

-- Seraphim = Crushed
EndP3 = {
    {text = '[Coalition HQ]: Good job Commander! All Seraphim forces have been destroyed! Gate back to HQ we have another Operation for you, HQ out.', vid = '', bank = 'JJ_VO2', cue = 'IntroP4-1', faction = 'UEF'},
}

-- The most submissive statement ever.
RevealP1  = {
    {text = '[Vuth-Vuthroz]: So the Humans have finally come to stop us? I will handle this filth, my Lord Yuth.', vid = 'Abasi.sfd', bank = 'JJ_VO2', cue = 'RevealP1', faction = 'Seraphim'},
    {text = '[Lord Yuth-Azeath]: Make it quick Vuth, we must prepare for the others.', vid = 'Maahes.sfd', bank = 'JJ_VO2', cue = 'RevealP1', faction = 'Seraphim'},
}

-- yeah, but were any of those kills in ACUs?
TAUNT1P1 = {
    {text = '[Vuth-Vuthroz]: I have killed thosands of Humans, a few more will not be a problem!', vid = 'Abasi.sfd', bank = 'JJ_VO2', cue = 'TAUNT1P1', faction = 'Seraphim'},
}

-- What, you some sort of rich Seraphim snob?
TAUNT2P1 = {
    {text = '[Vuth-Vuthroz]: Humanity is nothing but filth compared to the beauty of the Seraphim!', vid = 'Abasi.sfd', bank = 'JJ_VO2', cue = 'TAUNT1P1', faction = 'Seraphim'},
}

-- Ummm, sure pal, you and what army?
TAUNT3P1 = {
    {text = '[Vuth-Vuthroz]: I will not let you harm another Seraphim! I will purge you!', vid = 'Abasi.sfd', bank = 'JJ_VO2', cue = 'TAUNT1P1', faction = 'Seraphim'},
}

-- Cry to your lord bro, grow a pair and be a... sera-man?
TAUNT1P2 = {
    {text = '[Vuth-Vuthroz]: I am sorry my lord Yuth, but these humans are proving to be resilent!', vid = 'Abasi.sfd', bank = 'JJ_VO2', cue = 'TAUNT1P1', faction = 'Seraphim'},
}

-- did... did you watch lord of the Rings?
TAUNT2P2 = {
    {text = '[Vuth-Vuthroz]: You shall come no further!', vid = 'Abasi.sfd', bank = 'JJ_VO2', cue = 'TAUNT1P1', faction = 'Seraphim'},
}

--hmmm "minor". Pretty sure 6 fatboys is not minor buddy.
TAUNT3P2 = {
    {text = '[Vuth-Vuthroz]: A minor setback! Humanity will still be purged!', vid = 'Abasi.sfd', bank = 'JJ_VO2', cue = 'TAUNT1P1', faction = 'Seraphim'},
}

--Well, if you studied human history, you would know most crusades failed... horribly.
Death1P2 = {
    {text = '[Vuth-Vuthroz]: I failed you my Lord! I... failed... our crusade...', vid = 'Abasi.sfd', bank = 'JJ_VO2', cue = 'TAUNT1P1', faction = 'Seraphim'},
}

-- Seraphim - rift = no backup. Cant fool me I know my math.
TAUNT4P2  = {
    {text = '[Lord Yuth-Azeath]: We will prevail, even without the Rift!', vid = 'Maahes.sfd', bank = 'JJ_VO2', cue = 'RevealP1', faction = 'Seraphim'},
}

-- pretty sure your the one losing here bud
TAUNT1P3  = {
    {text = '[Lord Yuth-Azeath]: Your attack\'s are pathetic, just like you!', vid = 'Maahes.sfd', bank = 'JJ_VO2', cue = 'RevealP1', faction = 'Seraphim'},
}

-- Ahh so your atmitting you are a coward aye?
TAUNT2P3  = {
    {text = '[Lord Yuth-Azeath]: I do not have to defeat you, just outlast you!', vid = 'Maahes.sfd', bank = 'JJ_VO2', cue = 'RevealP1', faction = 'Seraphim'},
}

-- I dont think you have enough gasoline for that son.
TAUNT3P3  = {
    {text = '[Lord Yuth-Azeath]: This galaxy will burn, we will be unstoppable!', vid = 'Maahes.sfd', bank = 'JJ_VO2', cue = 'RevealP1', faction = 'Seraphim'},
}

-- I believe your file has been sealed.
Death2P3 = {
    {text = '[Lord Yuth-Azeath]: Humanity\'s fate... is... sealed!', vid = 'Abasi.sfd', bank = 'JJ_VO2', cue = 'TAUNT1P1', faction = 'Seraphim'},
}

Debriefing_Win = {
    {text = '[Coalition HQ]: Good work. Unfortunately the Seraphim managed to hold several other evacuation planets. A good part of their forces have escaped into open space. We will have to hunt them down.', vid = '', bank = 'JJ_VO2', cue = 'victoryend-1', faction = 'UEF'},
}

Debriefing_Lose = {
    {text = '[Coalition HQ]: The Seraphim have fully escaped into open space. It will be extremely difficult without our top commander.', vid = '', bank = 'JJ_VO2', cue = 'Defeat-1', faction = 'UEF'},
}
