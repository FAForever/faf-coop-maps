
--Part 1 Dialogues

-- What is the situation
IntroP1 = {
    {text = '<LOC FAF_Coop_Operation_Tha_Atha_Aez_IntroP1_1>[Overlord HQ]: Welcome to Velia... It seems Commander Vuth has failed to defend the gate. All remaining forces are being transfered to you, Commander.', vid = 'X06_Seth-Iavow_M03_03997.sfd', bank = 'JJ_VO2', cue = 'Intro1_1', faction = 'Seraphim'},
    {text = '<LOC FAF_Coop_Operation_Tha_Atha_Aez_IntroP1_2>[Overlord HQ]: This gate is the only one configured to transport commanders out into open space. It must be defended at all costs.', vid = 'X06_Seth-Iavow_M03_03997.sfd', bank = 'JJ_VO2', cue = 'Intro1_2', faction = 'Seraphim'},
    {text = '<LOC FAF_Coop_Operation_Tha_Atha_Aez_IntroP1_3>[Overlord HQ]: We are detecting a larger assault force assemblying, they will be here in a few minutes. Prepare your defenses, HQ out.', vid = 'X06_Seth-Iavow_M03_03997.sfd', bank = 'JJ_VO2', cue = 'Intro1_3', faction = 'Seraphim'},
}

-- Assault has started
AssaultP1 = {
    {text = '<LOC FAF_Coop_Operation_Tha_Atha_Aez_AssaultP1_1>[Overlord HQ]: UEF forces are moving on your position. Destroy them all, HQ out.', vid = 'X06_Seth-Iavow_M03_03997.sfd', bank = 'JJ_VO2', cue = 'JJ2_Richards_06', faction = 'Seraphim'},
}

-- Assault has been defeated
AssaultEndP1 = {
    {text = '<LOC FAF_Coop_Operation_Tha_Atha_Aez_AssaultEndP1_1>[Overlord HQ]: Good work, The Gate is secure for now.', vid = 'X06_Seth-Iavow_M03_03997.sfd', bank = 'JJ_VO2', cue = 'JJ2_Richards_06', faction = 'Seraphim'},
}

-- Part 2 Dialouges

IntroP2 = {
    {text = '<LOC FAF_Coop_Operation_Tha_Atha_Aez_IntroP2_1>[Overlord HQ]: Commander, The UEF has set up a number of bases surrounding your position. They pose a threat to both the gate and any Commanders attempting to reach it.', vid = 'X06_Seth-Iavow_M03_04500.sfd', bank = 'JJ_VO2', cue = 'IntroP2-1', faction = 'Seraphim'},
    {text = '<LOC FAF_Coop_Operation_Tha_Atha_Aez_IntroP2_2>[Overlord HQ]: We need to clear the immediate area before its safe to transfer Commanders out. Speaking of which..', vid = 'X06_Seth-Iavow_M03_03997.sfd', bank = 'JJ_VO2', cue = 'IntroP2-2', faction = 'Seraphim'},
    {text = '<LOC FAF_Coop_Operation_Tha_Atha_Aez_IntroP2_3>[Overlord HQ]: It appears Commander Vuth is still alive. She is guarding one of the transfer gates. Several Commanders are prepared to gate in once the signal is given. Assist Zuth when possible. HQ out.', vid = 'X06_Seth-Iavow_M03_03997.sfd', bank = 'JJ_VO2', cue = 'IntroP2-3', faction = 'Seraphim'},
}

MidP2 = {
    {text = '<LOC FAF_Coop_Operation_Tha_Atha_Aez_MidP2_1>[Overlord HQ]: Commander our current situation is dire. Over 60% of our forces are engaged on planet and the surrounding planets. Our forward scouts are setting up transfer gates, but right now your one of the only gates out of the core systems.', vid = 'X06_Seth-Iavow_M03_03997.sfd', bank = 'JJ_VO2', cue = 'Mid2_1', faction = 'Seraphim'},
    {text = '<LOC FAF_Coop_Operation_Tha_Atha_Aez_MidP2_2>[Overlord HQ]: We will lose many brothers today, make sure none of them die during the transfer from the core to open space. HQ out', vid = 'X06_Seth-Iavow_M03_03997.sfd', bank = 'JJ_VO2', cue = 'Mid2_2', faction = 'Seraphim'},
}

CompleteP2 = {
    {text = '<LOC FAF_Coop_Operation_Tha_Atha_Aez_CompleteP2_1>[Overlord HQ]: With the UEF bases gone we can evacuate the first few batchs of Commanders, defend them as they make their way to your gate, HQ out.', vid = 'X06_Seth-Iavow_M03_03997.sfd', bank = 'JJ_VO2', cue = 'CompleteP3', faction = 'Seraphim'},
}

SecondaryObjP2 = {
    {text = '<LOC FAF_Coop_Operation_Tha_Atha_Aez_SecondaryObjP2_1>[Overlord HQ]: Commander, Vuth is under assault by an Aeon Commander to the east. She has set up a small land base to the north of Vuth\'s position. If you destroy it, it will reduce pressure on commander Zuth. HQ out.', vid = 'X06_Seth-Iavow_M03_03997.sfd', bank = 'JJ_VO2', cue = 'SecondaryObjP2', faction = 'Seraphim'},
}

SecondaryObjEndP2 = {
    {text = '<LOC FAF_Coop_Operation_Tha_Atha_Aez_SecondaryObjEndP2_1>[Overlord HQ]: Good work, Vuth should have an easier time defending Herself now.', vid = 'X06_Seth-Iavow_M03_03997.sfd', bank = 'JJ_VO2', cue = 'CompleteP2S', faction = 'Seraphim'},
}

SecondaryObj2P2 = {
    {text = '<LOC FAF_Coop_Operation_Tha_Atha_Aez_SecondaryObj2P2_1>[Overlord HQ]: Commander we are transfering the shields and power of the exit gate to you. We recommend you upgrade the shields to better protect the gate, HQ out.', vid = 'X06_Seth-Iavow_M03_03997.sfd', bank = 'JJ_VO2', cue = 'CompleteP2S', faction = 'Seraphim'},
}

SecondaryObj2EndP2 = {
    {text = '<LOC FAF_Coop_Operation_Tha_Atha_Aez_SecondaryObj2EndP2_1>[Overlord HQ]: Those T3 shields will provide much better protection, Good work, HQ out.', vid = 'X06_Seth-Iavow_M03_03997.sfd', bank = 'JJ_VO2', cue = 'CompleteP2S', faction = 'Seraphim'},
}

-- Part 3

IntroP3 = {
    {text = '<LOC FAF_Coop_Operation_Tha_Atha_Aez_IntroP3_1>[Overlord HQ]: We got everyone from the first gate to safety, but the next gate will be harder to get to.', vid = 'X06_Seth-Iavow_M03_03997.sfd', bank = 'JJ_VO2', cue = 'IntroP4-1', faction = 'Seraphim'},
    {text = '<LOC FAF_Coop_Operation_Tha_Atha_Aez_IntroP3_2>[Overlord HQ]: The UEF commander is between you and commander Jareth. Defeat him so we may leave this planet quickly, HQ out.', vid = 'X06_Seth-Iavow_M03_03997.sfd', bank = 'JJ_VO2', cue = 'IntroP4-2', faction = 'Seraphim'},
    {text = '<LOC FAF_Coop_Operation_Tha_Atha_Aez_IntroP3_3>[Jareth]: My lord, I ask humbly for your assistance, I fear this UEF commander will overwhelm me and destroy the third gate.', vid = '', bank = 'JJ_VO2', cue = 'IntroP4-3', faction = 'Aeon'},
    {text = '<LOC FAF_Coop_Operation_Tha_Atha_Aez_IntroP3_4>[Jareth]: I am holding, but it won\'t be long before he breaks my forces, please assist me my lord.', vid = '', bank = 'JJ_VO2', cue = 'IntroP4-4', faction = 'Aeon'},
}

SACUsIntroP3 = {
    {text = '<LOC FAF_Coop_Operation_Tha_Atha_Aez_SACUsIntroP3_1>[Overlord HQ]: Commander, two SACU commanders are gating in to assist you, We are also giving you access to consruct new SACUs.', vid = 'X06_Seth-Iavow_M03_03997.sfd', bank = 'JJ_VO2', cue = 'CompleteP2S', faction = 'Seraphim'},
    {text = '<LOC FAF_Coop_Operation_Tha_Atha_Aez_SACUsIntroP3_2>[Overlord HQ]: However, do not needlessly throw away their lives. Seraphim lifes are extremely valuable now, so insure their survival. HQ out.', vid = 'X06_Seth-Iavow_M03_03997.sfd', bank = 'JJ_VO2', cue = 'CompleteP2S', faction = 'Seraphim'},
}

SACUsDeathP3 = {
    {text = '<LOC FAF_Coop_Operation_Tha_Atha_Aez_SACUsDeathP3_1>[Overlord HQ]: Commander one of your support commanders died, We can not afford another loss like that, perform better. HQ out.', vid = 'X06_Seth-Iavow_M03_03997.sfd', bank = 'JJ_VO2', cue = 'CompleteP2S', faction = 'Seraphim'},
}

OrderNukeP3 = {
    {text = '<LOC FAF_Coop_Operation_Tha_Atha_Aez_OrderNukeP3_1>[Jareth]: My lord, I have several nukes ready for use, but am unable to gather enough forces to use them.', vid = '', bank = 'JJ_VO2', cue = 'CompleteP2S', faction = 'Aeon'},
    {text = '<LOC FAF_Coop_Operation_Tha_Atha_Aez_OrderNukeP3_2>[Jareth]: I already have two targets in mind, all you must do is destroy the Nuke defenses. I await your assistance my lord.', vid = '', bank = 'JJ_VO2', cue = 'CompleteP2S', faction = 'Aeon'},
}

OrderNukeEndP3 = {
    {text = '<LOC FAF_Coop_Operation_Tha_Atha_Aez_OrderNukeEndP3_1>[Jareth]: Thank you my lord, I am firing the nukes now.', vid = '', bank = 'JJ_VO2', cue = 'CompleteP2S', faction = 'Aeon'},
}

ZuthDeadP3 = {
    {text = '<LOC FAF_Coop_Operation_Tha_Atha_Aez_ZuthDeadP3_1>[Overlord HQ]: It seems Vuth was killed, a shame, but she failed to defend the gate before you. Her base is shuting down, be careful of increased Aeon attacks. HQ out.', vid = 'X06_Seth-Iavow_M03_03997.sfd', bank = 'JJ_VO2', cue = 'CompleteP2S', faction = 'Seraphim'},
}

ZuthAliveP3 = {
    {text = '<LOC FAF_Coop_Operation_Tha_Atha_Aez_ZuthAliveP3_1>[Overlord HQ]: Vuth is being relieved of duty, all of her units and structures are being transfered to you. As much as she is a failure, she will still prove useful. HQ out.', vid = 'X06_Seth-Iavow_M03_03997.sfd', bank = 'JJ_VO2', cue = 'CompleteP2S', faction = 'Seraphim'},
}

-- Part 4 Dialogues

IntroP4 = {
    {text = '<LOC FAF_Coop_Operation_Tha_Atha_Aez_IntroP4_1>[Overlord HQ]: The last group of commanders are coming throught now, escourt them to the gate. make sure to keep air cover for them.', vid = 'X06_Seth-Iavow_M03_04500.sfd', bank = 'JJ_VO2', cue = 'IntroP5-1', faction = 'Seraphim'},
    {text = '<LOC FAF_Coop_Operation_Tha_Atha_Aez_IntroP4_2>[Jareth]: My task is complete, transfering all my troops to you and warping to my next assignment, good luck my lord.', vid = '', bank = 'JJ_VO2', cue = 'IntroP5-2', faction = 'Aeon'},
    {text = '<LOC FAF_Coop_Operation_Tha_Atha_Aez_IntroP4_3>[Overlord HQ]: All other Seraphim forces have gated off world, you and those commanders are the last left. As we speak dozens of Coalition commanders are rushing here. Procced with haste. HQ out.', vid = 'X06_Seth-Iavow_M03_04500.sfd', bank = 'JJ_VO2', cue = 'IntroP5-3', faction = 'Seraphim'},
}

Victory = {
    {text = '<LOC FAF_Coop_Operation_Tha_Atha_Aez_Victory_1>[Overlord HQ]: Good work Commander. the Seraphim forces will fight on because of you. Head for the gate. HQ out.', vid = 'X06_Seth-Iavow_M03_04500.sfd', bank = 'JJ_VO2', cue = 'Victory-1', faction = 'Seraphim'},
}

Comsdeath = {
    {text = '<LOC FAF_Coop_Operation_Tha_Atha_Aez_Comsdeath_1>[Overlord HQ]: A objective was failed! We can\'t afford failure! This mission is over.', vid = 'X06_Seth-Iavow_M03_0400.sfd', bank = 'JJ_VO2', cue = 'Comsdeath-1', faction = 'Seraphim'},
}

-- UEF Taunts

UEFReveal1 = {
    {text = '<LOC FAF_Coop_Operation_Tha_Atha_Aez_UEFReveal1_1>[Colonel Griff]: So a new alien comes to die! This is where you meet your end, filth!', vid = 'GeneralHall.sfd', bank = 'JJ_VO2', cue = 'UEFReveal-1', faction = 'UEF'},
}

UEFTaunt1 = {
    {text = '<LOC FAF_Coop_Operation_Tha_Atha_Aez_UEFTaunt1_1>[Colonel Griff]: Listen here you alien filth! you and your kind are all going to die here!', vid = 'GeneralHall.sfd', bank = 'JJ_VO2', cue = 'Taunt-1', faction = 'UEF'},
}

UEFTaunt2 = {
    {text = '<LOC FAF_Coop_Operation_Tha_Atha_Aez_UEFTaunt2_1>[Colonel Griff]: You can\'t stop the might of the UEF! We will prevail!', vid = 'GeneralHall.sfd', bank = 'JJ_VO2', cue = 'Taunt-2', faction = 'UEF'},
}

UEFTaunt3 = {
    {text = '<LOC FAF_Coop_Operation_Tha_Atha_Aez_UEFTaunt3_1>[Colonel Griff]: I\'ve already killed 4 of your kind. How does that make you feel, alien filth!', vid = 'GeneralHall.sfd', bank = 'JJ_VO2', cue = 'Taunt-3', faction = 'UEF'},
}

UEFTaunt4 = {
    {text = '<LOC FAF_Coop_Operation_Tha_Atha_Aez_UEFTaunt4_1>[Colonel Griff]: I will kill those commanders you alien filth!', vid = 'GeneralHall.sfd', bank = 'JJ_VO2', cue = 'Taunt-4', faction = 'UEF'},
}

UEFTaunt5 = {
    {text = '<LOC FAF_Coop_Operation_Tha_Atha_Aez_UEFTaunt5_1>[Colonel Griff]: I am A Colonel of the UEF! I will crush you!', vid = 'GeneralHall.sfd', bank = 'JJ_VO2', cue = 'Taunt-4', faction = 'UEF'},
}

UEFTaunt6 = {
    {text = '<LOC FAF_Coop_Operation_Tha_Atha_Aez_UEFTaunt6_1>[Colonel Griff]: We will end your genocide of Humanity here!', vid = 'GeneralHall.sfd', bank = 'JJ_VO2', cue = 'Taunt-4', faction = 'UEF'},
}

UEFTaunt7 = {
    {text = '<LOC FAF_Coop_Operation_Tha_Atha_Aez_UEFTaunt7_1>[Colonel Griff]: You think.. thats enough... to stop me!', vid = 'GeneralHall.sfd', bank = 'JJ_VO2', cue = 'Taunt-5', faction = 'UEF'},
}

UEFdeath1 = {
    {text = '<LOC FAF_Coop_Operation_Tha_Atha_Aez_UEFdeath1_1>[Colonel Griff]: Someone... help me! Please.. help me...aggghh!', vid = 'GeneralHall.sfd', bank = 'JJ_VO2', cue = 'Uefdeath-1', faction = 'UEF'},
}

AeonReact1 = {
    {text = '<LOC FAF_Coop_Operation_Tha_Atha_Aez_AeonReact1_1>[Colonel Griff]: No Thaila! You alien filth will pay for your crimes! ', vid = 'GeneralHall.sfd', bank = 'JJ_VO2', cue = 'AeonReact-1', faction = 'UEF'},
}

-- Aeon Taunts

AeonReveal1 = {
    {text = '<LOC FAF_Coop_Operation_Tha_Atha_Aez_AeonReveal1_1>[Crusader Thaila]: Another Seraphim? You seem.. Different from the previous few. No matter you will meet the same fate.', vid = 'Thalia.sfd', bank = 'JJ_VO2', cue = 'AeonReveal-1', faction = 'Aeon'},
}

AeonTaunt1 = {
    {text = '<LOC FAF_Coop_Operation_Tha_Atha_Aez_AeonTaunt1_1>[Crusader Thaila]: You twisted the minds of the Order to your will! We will smite your evil here once and for all!', vid = 'Thalia.sfd', bank = 'JJ_VO2', cue = 'AeonTaunt-1', faction = 'Aeon'},
}

AeonTaunt2 = {
    {text = '<LOC FAF_Coop_Operation_Tha_Atha_Aez_AeonTaunt2_1>[Crusader Thaila]: We were taught the Way was a message of peace. You have turned it into a message of war.', vid = 'Thalia.sfd', bank = 'JJ_VO2', cue = 'AeonTaunt-2', faction = 'Aeon'},
}

AeonTaunt3 = {
    {text = '<LOC FAF_Coop_Operation_Tha_Atha_Aez_AeonTaunt3_1>[Crusader Thaila]: I fight with rightousness on my side!', vid = 'Thalia.sfd', bank = 'JJ_VO2', cue = 'AeonTaunt-3', faction = 'Aeon'},
}

Aeondeath1 = {
    {text = '<LOC FAF_Coop_Operation_Tha_Atha_Aez_Aeondeath1_1>[Crusader Thaila]: Death is.. not.. the end.', vid = 'Thalia.sfd', bank = 'JJ_VO2', cue = 'Aeondeath-1', faction = 'Aeon'},
}

UEFReact1 = {
    {text = '<LOC FAF_Coop_Operation_Tha_Atha_Aez_UEFReact1_1>[Crusader Thaila]: Griff was a good man. I will avenge his death!', vid = 'Thalia.sfd', bank = 'JJ_VO2', cue = 'UEFReact1-1', faction = 'Aeon'},
}

--- End Screen Dialogues

Debriefing_Win = {
    {text = '<LOC FAF_Coop_Operation_Tha_Atha_Aez_Debriefing_Win_1>[Overlord HQ]: We have evacuated 70% of all our military forces from the core worlds. We however lost 7 seraphim commanders and 12 order minions. Right now scouts are attempting to find suitible worlds deep in open space to set up our new headquarters. Rest while you can, we will have a new assigment for you shortly, HQ out.', vid = 'X06_Seth-Iavow_M03_0400.sfd', bank = 'JJ_VO2', cue = 'victoryend-1', faction = 'Seraphim'},
}

Debriefing_Lose = {
    {text = '<LOC FAF_Coop_Operation_Tha_Atha_Aez_Debriefing_Lose_1>[General Hall]: All Seraphim forces have been trapped and killed on Velra. All remaining Order commanders have either surrendered or have been killed, this is a momentous occasion!', vid = 'X06_Seth-Iavow_M03_0400.sfd', bank = 'JJ_VO2', cue = 'Defeat-1', faction = 'UEF'},
}