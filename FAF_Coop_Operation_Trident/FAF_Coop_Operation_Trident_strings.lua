OPERATION_NAME = '<LOC FAF_Coop_Operation_Trident_Name>Operation Trident'
OPERATION_DESCRIPTION = '<LOC FAF_Coop_Operation_Trident_Description>TODO.'



-------------
-- Debriefing
-------------
-- Showed on the score screen if player wins
Debriefing_Win = {
    {
        text = '<LOC SCORE_0055>Operation Successful', faction = 'Cybran'
    },
}

-- Showed on the score screen if player loses
Debriefing_Lose = {
    {
        text = '<LOC SCORE_0056>Operation Failed', faction = 'Cybran'
    },
}



-------------
-- Win / Lose
-------------
-- Player wins
PlayerWins = {
    {
        text = '<LOC FAF_Coop_Operation_Trident_PlayerWins>[{i Ops}]: Well done commanders, are people are safe.',
        vid = 'QAI.sfd', vidx = 'FAF_Coop_Operation_Trident_PlayerWins.sfd', bank = 'FAF_Coop_Operation_Trident_VO', cue = 'PlayerWins', faction = 'Cybran'
    },
}

-- Player dies
PlayerDies = {
    {
        text = '<LOC FAF_Coop_Operation_Trident_PlayerDies>[{i Ops}]: Commander come in! ... Commander! ... Abort the mission, we can\'t risk losing you both.',
        vid = 'QAI.sfd', vidx = 'FAF_Coop_Operation_Trident_PlayerDies.sfd', bank = 'FAF_Coop_Operation_Trident_VO', cue = 'PlayerDies', faction = 'Cybran'
    },
}

CityDestroyed = {
    {
        text = '<LOC FAF_Coop_Operation_Trident_CityDestroyed>[{i Ops}]: It\'s too late... The city has been destroyed by the Aeon commander. Abort the mission and return home.',
        vid = 'QAI.sfd', vidx = 'FAF_Coop_Operation_Trident_CityDestroyed.sfd', bank = 'FAF_Coop_Operation_Trident_VO', cue = 'CityDestroyed', faction = 'Cybran'
    },
}



------------
-- Intro NIS
------------
M1Intro1 = {
    {
        text = '<LOC FAF_Coop_Operation_Trident_M1Intro1>[{i Ops}]: The UEF is still holding the symbionts in the city. However they are under Aeon attack and the defenses can fall any minute.',
        vid = 'QAI.sfd', vidx = 'FAF_Coop_Operation_Trident_M1Intro1.sfd', bank = 'FAF_Coop_Operation_Trident_VO', cue = 'M1Intro1', faction = 'Cybran'
    },
}

M1Intro2 = {
    {
        text = '<LOC FAF_Coop_Operation_Trident_M1Intro2>[{i Ops}]: Our intel suggest that they will evacute the planet. We must stop the UEF from taking the captured symbionts with them and Aeon from cleansing them.',
        vid = 'QAI.sfd', vidx = 'FAF_Coop_Operation_Trident_M1Intro2.sfd', bank = 'FAF_Coop_Operation_Trident_VO', cue = 'M1Intro2', faction = 'Cybran'
    },
}

M1Intro3 = {
    {
        text = '<LOC FAF_Coop_Operation_Trident_M1Intro3>[{i Ops}]: The drop zone is west of the UEF base, but can only support 1 ACU. That\'s why one of you should build the base while the second one will push towards the city.',
        vid = 'QAI.sfd', vidx = 'FAF_Coop_Operation_Trident_M1Intro3.sfd', bank = 'FAF_Coop_Operation_Trident_VO', cue = 'M1Intro3', faction = 'Cybran'
    },
}

M1Intro4 = {
    {
        text = '<LOC FAF_Coop_Operation_Trident_M1Intro4>[{i Ops}]: Move as quickly as possible and save our brothers and sisters before they are transported or killed. Good luck, Ops out.',
        vid = 'QAI.sfd', vidx = 'FAF_Coop_Operation_Trident_M1Intro4.sfd', bank = 'FAF_Coop_Operation_Trident_VO', cue = 'M1Intro4', faction = 'Cybran'
    },
}



------------
-- Mission 1
------------
M1PostIntro = {
    {
        text = '<LOC FAF_Coop_Operation_Trident_M1PostIntro>[Wyxe]: I\'ll construct the base as quickly as possible. Once I get basic economy and couple of factories running, my units will join your assault.',
        vid = 'Hex5.sfd', vidx = 'FAF_Coop_Operation_Trident_M1PostIntro.sfd', bank = 'FAF_Coop_Operation_Trident_VO', cue = 'M1PostIntro', faction = 'Cybran'
    },
}



M1UEFDialogue = {
    {
        text = '<LOC FAF_Coop_Operation_Trident_M1UEFDialogue_1>[Logan]: Are you here for your friends freak? It\'s too late.',
        vid = 'Fletcher.sfd', vidx = 'FAF_Coop_Operation_Trident_M1UEFDialogue_1.sfd', bank = 'FAF_Coop_Operation_Trident_VO', cue = 'M1UEFDialogue_1', faction = 'UEF'
    },
    {
        text = '<LOC FAF_Coop_Operation_Trident_M1UEFDialogue_2>[{i Ops}]: Ignore him commander, the symbionts are still there. Focus on your objectives.',
        vid = 'QAI.sfd', vidx = 'FAF_Coop_Operation_Trident_M1UEFDialogue_2.sfd', bank = 'FAF_Coop_Operation_Trident_VO', cue = 'M1UEFDialogue_2', faction = 'Cybran'
    },
}



M1RadarBuilt = {
    {
        text = '<LOC FAF_Coop_Operation_Trident_M1RadarBuilt>[Wyxe]: A Tech 2 Radar is online.',
        vid = 'Hex5.sfd', vidx = 'FAF_Coop_Operation_Trident_M1RadarBuilt.sfd', bank = 'FAF_Coop_Operation_Trident_VO', cue = 'M1RadarBuilt', faction = 'Cybran'
    },
}

M1StorageGiven = {
    {
        text = '<LOC FAF_Coop_Operation_Trident_M1StorageGiven>[Wyxe]: Commander, I\'m giving you one of my Energy Storages to increase your Overcharge capability. The Recource Allocation upgrade on my ACU should also provide enough energy for now.',
        vid = 'Hex5.sfd', vidx = 'FAF_Coop_Operation_Trident_M1StorageGiven.sfd', bank = 'FAF_Coop_Operation_Trident_VO', cue = 'M1StorageGiven', faction = 'Cybran'
    },
}



M1ScoutsReady1 = {
    {
        text = '<LOC FAF_Coop_Operation_Trident_M1ScoutsReady1>[Wyxe]: Commander, I have a group of Air Scouts at your disposal. Just drop a marker on the map and I will dispatch them.',
        vid = 'Hex5.sfd', vidx = 'FAF_Coop_Operation_Trident_M1ScoutsReady1.sfd', bank = 'FAF_Coop_Operation_Trident_VO', cue = 'M1ScoutsReady1', faction = 'Cybran'
    },
}

M1ScoutsReady2 = {
    {
        text = '<LOC FAF_Coop_Operation_Trident_M1ScoutsReady2>[Wyxe]: Another group of scouts is waiting for your orders commander.',
        vid = 'Hex5.sfd', vidx = 'FAF_Coop_Operation_Trident_M1ScoutsReady2.sfd', bank = 'FAF_Coop_Operation_Trident_VO', cue = 'M1ScoutsReady2', faction = 'Cybran'
    },
}

M1ScoutsReady3 = {
    {
        text = '<LOC FAF_Coop_Operation_Trident_M1ScoutsReady3>[Wyxe]: The next group of scouts is ready to be sent.',
        vid = 'Hex5.sfd', vidx = 'FAF_Coop_Operation_Trident_M1ScoutsReady3.sfd', bank = 'FAF_Coop_Operation_Trident_VO', cue = 'M1ScoutsReady3', faction = 'Cybran'
    },
}

M1ScoutSent1 = {
    {
        text = '<LOC FAF_Coop_Operation_Trident_M1ScoutSent1>[Wyxe]: Sending an Air Scout commander.',
        vid = 'Hex5.sfd', vidx = 'FAF_Coop_Operation_Trident_M1ScoutSent1.sfd', bank = 'FAF_Coop_Operation_Trident_VO', cue = 'M1ScoutSent1', faction = 'Cybran'
    },
}

M1ScoutSent2 = {
    {
        text = '<LOC FAF_Coop_Operation_Trident_M1ScoutSent2>[Wyxe]: The scout is on the way.',
        vid = 'Hex5.sfd', vidx = 'FAF_Coop_Operation_Trident_M1ScoutSent2.sfd', bank = 'FAF_Coop_Operation_Trident_VO', cue = 'M1ScoutSent2', faction = 'Cybran'
    },
}

M1ScoutSent3 = {
    {
        text = '<LOC FAF_Coop_Operation_Trident_M1ScoutSent3>[Wyxe]: Confirming the location for scouting.',
        vid = 'Hex5.sfd', vidx = 'FAF_Coop_Operation_Trident_M1ScoutSent3.sfd', bank = 'FAF_Coop_Operation_Trident_VO', cue = 'M1ScoutSent3', faction = 'Cybran'
    },
}



M1UEFBaseSpotted1 = {
    {
        text = '<LOC FAF_Coop_Operation_Trident_M1UEFBaseSpotted1>[Wyxe]: The UEF base seems to have only small amount of defenses. Stay within the range of the Decievers and take out the PDs with your mobile missile launchers. The rest should be easy.',
        vid = 'Hex5.sfd', vidx = 'FAF_Coop_Operation_Trident_M1UEFBaseSpotted1.sfd', bank = 'FAF_Coop_Operation_Trident_VO', cue = 'M1UEFBaseSpotted1', faction = 'Cybran'
    },
}

M1UEFBaseSpotted2 = {
    {
        text = '<LOC FAF_Coop_Operation_Trident_M1UEFBaseSpotted2>[{i Ops}]: The UEF base seems to have only small amount of defenses. Stay within the range of the Decievers and take out the PDs with your mobile missile launchers. The rest should be easy. Ops out.',
        vid = 'QAI.sfd', vidx = 'FAF_Coop_Operation_Trident_M1UEFBaseSpotted2.sfd', bank = 'FAF_Coop_Operation_Trident_VO', cue = 'M1UEFBaseSpotted2', faction = 'Cybran'
    },
}



-- Aeon dialogue with the first attack
M1AeonInitialDialogue = {
    {
        text = '<LOC FAF_Coop_Operation_Trident_M1AeonInitialDialogue>[Cora]: This is Knight Cora of the Aeon Illuminate, surrender now or be cleansed.',
        vid = 'Vedetta.sfd', vidx = 'FAF_Coop_Operation_Trident_M1AeonInitialDialogue.sfd', bank = 'FAF_Coop_Operation_Trident_VO', cue = 'M1AeonInitialDialogue', faction = 'Aeon'
    },
}

-- When Aron spots Cybran
M1AeonSeesCybran = {
    {
        text = '<LOC FAF_Coop_Operation_Trident_M1AeonSeesCybran>[Cora]: It was a mistake to come back Cybran.',
        vid = 'Vedetta.sfd', vidx = 'FAF_Coop_Operation_Trident_M1AeonSeesCybran.sfd', bank = 'FAF_Coop_Operation_Trident_VO', cue = 'M1AeonSeesCybran', faction = 'Aeon'
    },
}



M1CitySupportSent = {
    {
        text = '<LOC FAF_Coop_Operation_Trident_M1CitySupportSent1>[Logan]: I won\'t let you push me away so easily!',
        vid = 'Fletcher.sfd', vidx = 'FAF_Coop_Operation_Trident_M1CitySupportSent1.sfd', bank = 'FAF_Coop_Operation_Trident_VO', cue = 'M1CitySupportSent1', faction = 'UEF'
    },
    {
        text = '<LOC FAF_Coop_Operation_Trident_M1CitySupportSent2>[{i Ops}]: The UEF commander is sending reinforcements to the city. Don\'t let that stop you.',
        vid = 'QAI.sfd', vidx = 'FAF_Coop_Operation_Trident_M1CitySupportSent2.sfd', bank = 'FAF_Coop_Operation_Trident_VO', cue = 'M1CitySupportSent2', faction = 'Cybran'
    },
}



-- 1 building destoryed
M1CityBuildingDestroyed1 = {
    {
        text = '<LOC FAF_Coop_Operation_Trident_M1CityBuildingDestroyed1>[{i Ops}]: The node is under attack! Get in there quickly commanders!',
        vid = 'QAI.sfd', vidx = 'FAF_Coop_Operation_Trident_M1CityBuildingDestroyed1.sfd', bank = 'FAF_Coop_Operation_Trident_VO', cue = 'M1CityBuildingDestroyed1', faction = 'Cybran'
    },
}

-- 3 buildings destroyed
M1CityBuildingDestroyed2 = {
    {
        text = '<LOC FAF_Coop_Operation_Trident_M1CityBuildingDestroyed2>[{i Ops}]: The Aeons are destroying the node! Stop them!',
        vid = 'QAI.sfd', vidx = 'FAF_Coop_Operation_Trident_M1CityBuildingDestroyed2.sfd', bank = 'FAF_Coop_Operation_Trident_VO', cue = 'M1CityBuildingDestroyed2', faction = 'Cybran'
    },
}

-- 6 buildings destroyed
M1CityBuildingDestroyed3 = {
    {
        text = '<LOC FAF_Coop_Operation_Trident_M1CityBuildingDestroyed3>[{i Ops}]: If you don\'t get to the node quickly, there won\'t be anyone left to save!',
        vid = 'QAI.sfd', vidx = 'FAF_Coop_Operation_Trident_M1CityBuildingDestroyed3.sfd', bank = 'FAF_Coop_Operation_Trident_VO', cue = 'M1CityBuildingDestroyed3', faction = 'Cybran'
    },
}

M1CitySaved = {
    {
        text = '<LOC FAF_Coop_Operation_Trident_M1CitySaved_1>[Nigel]: Thank you commander, the UEF was just about to move us off the planet.',
        vid = 'FAF_Coop_Operation_Trident_M1CitySaved_1.sfd', bank = 'FAF_Coop_Operation_Trident_VO', cue = 'M1CitySaved_1', faction = 'Cybran'
    },
    {
        text = '<LOC FAF_Coop_Operation_Trident_M1CitySaved_2>[{i Ops}]: The battle is not over yet, we need to get our people to safety.',
        vid = 'QAI.sfd', vidx = 'FAF_Coop_Operation_Trident_M1CitySaved_2.sfd', bank = 'FAF_Coop_Operation_Trident_VO', cue = 'M1CitySaved_2', faction = 'Cybran'
    },
}

-- Reminders
M1P1Reminder1 = {
    {
        text = '<LOC FAF_Coop_Operation_Trident_M1P1Reminder1>[{i Ops}]: Hurry up commander, the Aeon forces are getting closer to the symbiont city.',
        vid = 'QAI.sfd', vidx = 'FAF_Coop_Operation_Trident_M1P1Reminder1.sfd', bank = 'FAF_Coop_Operation_Trident_VO', cue = 'M1P1Reminder1', faction = 'Cybran'
    },
}

M1P1Reminder2 = {
    {
        text = '<LOC FAF_Coop_Operation_Trident_M1P1Reminder2>[{i Ops}]: The Aeon commander is building up her forces. This might be the last chance to save the city commanders. Secure it ASAP.',
        vid = 'QAI.sfd', vidx = 'FAF_Coop_Operation_Trident_M1P1Reminder2.sfd', bank = 'FAF_Coop_Operation_Trident_VO', cue = 'M1P1Reminder2', faction = 'Cybran'
    },
}

-- Main attack to destroy the city
M1AeonFinalAttack = {
    {
        text = '<LOC FAF_Coop_Operation_Trident_M1AeonFinalAttack1>[Cora]: Your time has come to the end. This planet will be cleansed at once!',
        vid = 'Vedetta.sfd', vidx = 'FAF_Coop_Operation_Trident_M1AeonFinalAttack1.sfd', bank = 'FAF_Coop_Operation_Trident_VO', cue = 'M1AeonFinalAttack1', faction = 'Aeon'
    },
    {
        text = '<LOC FAF_Coop_Operation_Trident_M1AeonFinalAttack2>[{i Ops}]: We have Aeon units incoming from the north. They are vectoring right towards the city!',
        vid = 'QAI.sfd', vidx = 'FAF_Coop_Operation_Trident_M1AeonFinalAttack2.sfd', bank = 'FAF_Coop_Operation_Trident_VO', cue = 'M1AeonFinalAttack2', faction = 'Cybran'
    },
}



-- Primary Objectives
M1P1Title = '<LOC FAF_Coop_Operation_Trident_M1P1Title>Secure the city'
M1P1Description = '<LOC FAF_Coop_Operation_Trident_M1P1Description>The UEF has established defenses around the city but they are under Aeon attack. Get there before the Aeons and recapture the city.'

M1P2Title = '<LOC FAF_Coop_Operation_Trident_M1P1Title>Protect the Cepheus Node 4'
M1P2Description = '<LOC FAF_Coop_Operation_Trident_M1P1Description>The Aeon commander is attacking the UEF\'s city defenses. Move quickly and secure the city before it\'s cleansed. At least %s%% of the city buildings must survive.'

-- Bonus Objectives
M1B1Title = '<LOC FAF_Coop_Operation_Trident_M1B1Title>Quick Strike'
M1B1escription = '<LOC FAF_Coop_Operation_Trident_M1B1Description>Settlement was secured before the Aeon commander could gather sizable force to attack it.'

M1B2Title = '<LOC FAF_Coop_Operation_Trident_M1B2Title>No casualties'
M1B2escription = '<LOC FAF_Coop_Operation_Trident_M1B2Description>All city buildings survived.'

-- Button
M1ScoutButtonTitle = '<LOC FAF_Coop_Operation_Trident_M1ScoutButtonTitle>Request an Air Scout'
M1ScoutButtonDescription = '<LOC FAF_Coop_Operation_Trident_M1ScoutButtonDescription>Mark a location on the map that you need scouted.'



------------
-- Mission 2
------------
M2Intro = {
    {
        text = '<LOC FAF_Coop_Operation_Trident_M2Intro>[{i Ops}]: Before the evacuation can begin, we need to make sure that the transports can make it out alive. QAI has picked up an Atlantis\' signal somewhere in this area. Break through the UEF\'s blockade and secure the skies. The Atlantis is your next target commanders, find it and sink it.',
        vid = 'QAI.sfd', vidx = 'FAF_Coop_Operation_Trident_M2Intro.sfd', bank = 'FAF_Coop_Operation_Trident_VO', cue = 'M2Intro', faction = 'Cybran'
    },
}



-- 1 building destoryed, different dialogues from the first part of the mission
M2CityBuildingDestroyed1 = {
    {
        text = '<LOC FAF_Coop_Operation_Trident_M2CityBuildingDestroyed1>[Nigel]: We\'re under attack! Help us commander!',
        vid = 'FAF_Coop_Operation_Trident_M2CityBuildingDestroyed1.sfd', bank = 'FAF_Coop_Operation_Trident_VO', cue = 'M2CityBuildingDestroyed1', faction = 'Cybran'
    },
}

-- 3 buildings destroyed
M2CityBuildingDestroyed2 = {
    {
        text = '<LOC FAF_Coop_Operation_Trident_M2CityBuildingDestroyed2>[Nigel]: The Aeons are in the node! Please stop them!',
        vid = 'FAF_Coop_Operation_Trident_M2CityBuildingDestroyed2.sfd', bank = 'FAF_Coop_Operation_Trident_VO', cue = 'M2CityBuildingDestroyed2', faction = 'Cybran'
    },
}

-- 6 buildings destroyed
M2CityBuildingDestroyed3 = {
    {
        text = '<LOC FAF_Coop_Operation_Trident_M2CityBuildingDestroyed3>[Nigel]: We have heavy casualties commander! Most of the node is destroyed!',
        vid = 'FAF_Coop_Operation_Trident_M2CityBuildingDestroyed3.sfd', bank = 'FAF_Coop_Operation_Trident_VO', cue = 'M2CityBuildingDestroyed3', faction = 'Cybran'
    },
}



M2Dialog1 = {
    {
        text = '<LOC FAF_Coop_Operation_Trident_M2Dialog1>[{i Ops}]: The civilians are getting ready for the evacuation. Work on securing the path commanders.',
        vid = 'QAI.sfd', vidx = 'FAF_Coop_Operation_Trident_M2Dialog1.sfd', bank = 'FAF_Coop_Operation_Trident_VO', cue = 'M2Dialog1', faction = 'Cybran'
    },
}



M2ChangeEnhancements = {
    {
        text = '<LOC FAF_Coop_Operation_Trident_M2ChangeEnhancements>[Wyxe]: My economy is up and running so I\'m switching to Stealth upgrade on my ACU.',
        vid = 'Hex5.sfd', vidx = 'FAF_Coop_Operation_Trident_M2ChangeEnhancements.sfd', bank = 'FAF_Coop_Operation_Trident_VO', cue = 'M2ChangeEnhancements', faction = 'Cybran'
    },
}



M2AtlantisLocated = {
    {
        text = '<LOC FAF_Coop_Operation_Trident_M2AtlantisLocated>[{i Ops}]: There\'s the Atlantis commanders, the UEF set up a whole base at that position. Build big enough army and sink the Atlantis.',
        vid = 'QAI.sfd', vidx = 'FAF_Coop_Operation_Trident_M2AtlantisLocated.sfd', bank = 'FAF_Coop_Operation_Trident_VO', cue = 'M2AtlantisLocated', faction = 'Cybran'
    },
}

M2LocateReminder = {
    {
        text = '<LOC FAF_Coop_Operation_Trident_M2LocateReminder>[{i Ops}]: You need to find the Atlantis commanders. Send some scouts to locate it.',
        vid = 'QAI.sfd', vidx = 'FAF_Coop_Operation_Trident_M2LocateReminder.sfd', bank = 'FAF_Coop_Operation_Trident_VO', cue = 'M2LocateReminder', faction = 'Cybran'
    },
}

M2AtlantisDestroyed = {
    {
        text = '<LOC FAF_Coop_Operation_Trident_M2AtlantisDestroyed>[{i Ops}]: The Atlantis is down. Without its support the UEF won\'t be able to intercept out transports. We can begin the evacuation now.',
        vid = 'QAI.sfd', vidx = 'FAF_Coop_Operation_Trident_M2AtlantisDestroyed.sfd', bank = 'FAF_Coop_Operation_Trident_VO', cue = 'M2AtlantisDestroyed', faction = 'Cybran'
    },
}

M2KillReminder1 = {
    {
        text = '<LOC FAF_Coop_Operation_Trident_M2KillReminder1>[{i Ops}]: The Atlantis is still there commands, destroy it.',
        vid = 'QAI.sfd', vidx = 'FAF_Coop_Operation_Trident_M2KillReminder1.sfd', bank = 'FAF_Coop_Operation_Trident_VO', cue = 'M2KillReminder1', faction = 'Cybran'
    },
}

M2KillReminder2 = {
    {
        text = '<LOC FAF_Coop_Operation_Trident_M2KillReminder2>[{i Ops}]: We can\'t begin the evacuation with the Atlantis around. Sink it commander.',
        vid = 'QAI.sfd', vidx = 'FAF_Coop_Operation_Trident_M2KillReminder2.sfd', bank = 'FAF_Coop_Operation_Trident_VO', cue = 'M2KillReminder2', faction = 'Cybran'
    },
}



M2CiviliansReady = {
    {
        text = '<LOC FAF_Coop_Operation_Trident_M2CiviliansReady>[{i Ops}]: The trucks have left the city and the transports are on the way. Protect our people commanders.',
        vid = 'QAI.sfd', vidx = 'FAF_Coop_Operation_Trident_M2CiviliansReady.sfd', bank = 'FAF_Coop_Operation_Trident_VO', cue = 'M2CiviliansReady', faction = 'Cybran'
    },
}

M2TrucksEvacuated = {
    {
        text = '<LOC FAF_Coop_Operation_Trident_M2TrucksEvacuated>[{i Ops}]: The transports have reached the gate, all the symbionts are safe. Well done commanders, come home.',
        vid = 'QAI.sfd', vidx = 'FAF_Coop_Operation_Trident_M2TrucksEvacuated.sfd', bank = 'FAF_Coop_Operation_Trident_VO', cue = 'M2TrucksEvacuated', faction = 'Cybran'
    },
}



M2BuildShields = {
    {
        text = '<LOC FAF_Coop_Operation_Trident_M2BuildShields>[{i Ops}]: The settelement is quite exposed to an Aeon attacks. Construct T2 Shield Generators over it and upgrade them to the ED3 version. That should be sufficient for a while.',
        vid = 'QAI.sfd', vidx = 'FAF_Coop_Operation_Trident_M2BuildShields.sfd', bank = 'FAF_Coop_Operation_Trident_VO', cue = 'M2BuildShields', faction = 'Cybran'
    },
}

M2hieldsBuilt = {
    {
        text = '<LOC FAF_Coop_Operation_Trident_M2hieldsBuilt1>[{i Ops}]: The shield generators are up and running.',
        vid = 'QAI.sfd', vidx = 'FAF_Coop_Operation_Trident_M2hieldsBuilt1.sfd', bank = 'FAF_Coop_Operation_Trident_VO', cue = 'M2hieldsBuilt1', faction = 'Cybran'
    },
    {
        text = '<LOC FAF_Coop_Operation_Trident_M2hieldsBuilt2>[Cora]: You are only delaying the inevitable.',
        vid = 'Vedetta.sfd', vidx = 'FAF_Coop_Operation_Trident_M2hieldsBuilt2.sfd', bank = 'FAF_Coop_Operation_Trident_VO', cue = 'M2hieldsBuilt2', faction = 'Aeon'
    },
}



M2KillAeonCommanders = {
    {
        text = '<LOC FAF_Coop_Operation_Trident_M2KillAeonCommanders>[{i Ops}]: The Aeon base assaulting the city is located to the northwest. Getting the civilians out of this planet is the priority, but if you\'ll get an opening, strike the Aeon commanders.',
        vid = 'QAI.sfd', vidx = 'FAF_Coop_Operation_Trident_M2KillAeonCommanders.sfd', bank = 'FAF_Coop_Operation_Trident_VO', cue = 'M2KillAeonCommanders', faction = 'Cybran'
    },
}

M2AeonCommandersKilled = {
    {
        text = '<LOC FAF_Coop_Operation_Trident_M2AeonCommandersKilled>[{i Ops}]: That\'s both of Aeon commanders, they\'ll think twice before attacking us again.',
        vid = 'QAI.sfd', vidx = 'FAF_Coop_Operation_Trident_M2AeonCommandersKilled.sfd', bank = 'FAF_Coop_Operation_Trident_VO', cue = 'M2AeonCommandersKilled', faction = 'Cybran'
    },
}

M2AeonACUKilled = {
    {
        text = '<LOC FAF_Coop_Operation_Trident_M2AeonACUKilled>[{i Ops}]: Excellent work taking out the Aeon commander.',
        vid = 'QAI.sfd', vidx = 'FAF_Coop_Operation_Trident_M2AeonACUKilled.sfd', bank = 'FAF_Coop_Operation_Trident_VO', cue = 'M2AeonACUKilled', faction = 'Cybran'
    },
}

M2AeonsACUKilled = {
    {
        text = '<LOC FAF_Coop_Operation_Trident_M2AeonsACUKilled>[{i Ops}]: Nice catch commanders, the sACU in the Aeon base is no more. Proceed with your mission.',
        vid = 'QAI.sfd', vidx = 'FAF_Coop_Operation_Trident_M2AeonsACUKilled.sfd', bank = 'FAF_Coop_Operation_Trident_VO', cue = 'M2AeonsACUKilled', faction = 'Cybran'
    },
    {
        text = '<LOC FAF_Coop_Operation_Trident_M2AeonsACUKilled>[Cora]: You abominations will pay for this.',
        vid = 'Vedetta.sfd', vidx = 'FAF_Coop_Operation_Trident_M2AeonsACUKilled.sfd', bank = 'FAF_Coop_Operation_Trident_VO', cue = 'M2AeonsACUKilled', faction = 'Aeon'
    },
}



M2MissileShipSpotted1 = {
    {
        text = '<LOC FAF_Coop_Operation_Trident_M2MissileShipSpotted1>[Wyxe]: Commander, I\'m detecting a Missile ship at the Aeon Base. It\'s missiles can bombard our forces from a large distance so we should sink if we\'re to attack the base.',
        vid = 'Hex5.sfd', vidx = 'FAF_Coop_Operation_Trident_M2MissileShipSpotted1.sfd', bank = 'FAF_Coop_Operation_Trident_VO', cue = 'M2MissileShipSpotted1', faction = 'Cybran'
    },
}

M2MissileShipSpotted2 = {
    {
        text = '<LOC FAF_Coop_Operation_Trident_M2MissileShipSpotted2>[{i Ops}]: Commanders, there\'s a Missile ship guarding the Aeon Base. It\'s missiles can bombard your forces from a large distance. If you choose to attack the Aeon commander, we advise you to sink it first.',
        vid = 'QAI.sfd', vidx = 'FAF_Coop_Operation_Trident_M2MissileShipSpotted2.sfd', bank = 'FAF_Coop_Operation_Trident_VO', cue = 'M2MissileShipSpotted2', faction = 'Cybran'
    },
}

M2MissileShipKilled1 = {
    {
        text = '<LOC FAF_Coop_Operation_Trident_M2MissileShipKilled1>[Wyxe]: The missile ship is destroyed.',
        vid = 'Hex5.sfd', vidx = 'FAF_Coop_Operation_Trident_M2MissileShipKilled1.sfd', bank = 'FAF_Coop_Operation_Trident_VO', cue = 'M2MissileShipKilled1', faction = 'Cybran'
    },
}

M2MissileShipKilled2 = {
    {
        text = '<LOC FAF_Coop_Operation_Trident_M2MissileShipKilled2>[{i Ops}]: The Aeon Missile Ship swims with the fishes now.',
        vid = 'QAI.sfd', vidx = 'FAF_Coop_Operation_Trident_M2MissileShipKilled2.sfd', bank = 'FAF_Coop_Operation_Trident_VO', cue = 'M2MissileShipKilled2', faction = 'Cybran'
    },
}



-- Primary Objectives
M2P1Title = '<LOC FAF_Coop_Operation_Trident_M2P1Title>Locate the Atlantis'
M2P1Description = '<LOC FAF_Coop_Operation_Trident_M2P1Description>Scout the ocean for the UEF experimental carrier.'

M2P2Title = '<LOC FAF_Coop_Operation_Trident_M2P2Title>Sink the Atlantis'
M2P2Description = '<LOC FAF_Coop_Operation_Trident_M2P2Description>The UEF has a strong air presence in the area supported by the Atlantis positioned in the nearby sea base. Sink it to reduce the UEF air production cababilities.'

M2P3Title = '<LOC FAF_Coop_Operation_Trident_M2P3Title>Evacuate the civilians'
M2P3Description = '<LOC FAF_Coop_Operation_Trident_M2P3Description>Transports are coming to pick up our people. At least %s of the trucks must survive.'

-- Secondary Objectives
M2S1Title = '<LOC FAF_Coop_Operation_Trident_M2S1Title>Build Tech 2 Shield Generators over the settlement'
M2S1Description = '<LOC FAF_Coop_Operation_Trident_M2S1Description>Construct 2 Tech 2 ED3 Shield Generators at the marked areas to protect the Cybran settlement.'

M2S2Title = '<LOC FAF_Coop_Operation_Trident_M2S2Title>Defeat the Aeon commanders'
M2S2Description = '<LOC FAF_Coop_Operation_Trident_M2S2Description>The symbionts are the priority, but if you get the chance to strike back the Aeon commanders, don\'t hessitate.'

-- Bonus Objectives
M2B1Title = '<LOC FAF_Coop_Operation_Trident_M2B1Title>Forward Intel'
M2B1Description = '<LOC FAF_Coop_Operation_Trident_M2B1Description>You built the T2 Radar and Sonar near the middle island.'

M2B2Title = '<LOC FAF_Coop_Operation_Trident_M2B2Title>Missiles prohibition'
M2B2Description = '<LOC FAF_Coop_Operation_Trident_M2B2Description>You killed the Missile Ship guarding the Aeon base.'

M2B3Title = '<LOC FAF_Coop_Operation_Trident_M2B3Title>No casualties II'
M2B3Description = '<LOC FAF_Coop_Operation_Trident_M2B3Description>All civilian trucks survived.'



------------
-- Mission 1
------------
-- Player's ACU takes damage
TAUNT1 = {
    {
        text = '<LOC FAF_Coop_Operation_Trident_TAUNT1>[Logan]: A Cybran who isn\'t hiding? Interesting...',
        vid = 'Fletcher.sfd', vidx = 'FAF_Coop_Operation_Trident_TAUNT1.sfd', bank = 'FAF_Coop_Operation_Trident_VO', cue = 'TAUNT1', faction = 'UEF'
    },
}

-- UEF losing first defensive structure
TAUNT2 = {
    {
        text = '<LOC FAF_Coop_Operation_Trident_TAUNT2>[Logan]: You\'re brave to attack my base.',
        vid = 'Fletcher.sfd', vidx = 'FAF_Coop_Operation_Trident_TAUNT2.sfd', bank = 'FAF_Coop_Operation_Trident_VO', cue = 'TAUNT2', faction = 'UEF'
    },
}

-- Aeon launching the final attack on the city
TAUNT3 = {
    {
        text = '<LOC FAF_Coop_Operation_Trident_TAUNT3>[Cora]: There is no stopping the Aeon Illuminate.',
        vid = 'Vedetta.sfd', vidx = 'FAF_Coop_Operation_Trident_TAUNT3.sfd', bank = 'FAF_Coop_Operation_Trident_VO', cue = 'TAUNT3', faction = 'Aeon'
    },
}

-- UEF losing factories
TAUNT4 = {
    {
        text = '<LOC FAF_Coop_Operation_Trident_TAUNT4>[Logan]: I\'ve underestimated you, that won\'t happen again!',
        vid = 'Fletcher.sfd', vidx = 'FAF_Coop_Operation_Trident_TAUNT4.sfd', bank = 'FAF_Coop_Operation_Trident_VO', cue = 'TAUNT4', faction = 'UEF'
    },
}

-- UEF killing units
TAUNT6 = {
    {
        text = '<LOC FAF_Coop_Operation_Trident_TAUNT6>[Logan]: You won\'t stand in my way!',
        vid = 'Fletcher.sfd', vidx = 'FAF_Coop_Operation_Trident_TAUNT6.sfd', bank = 'FAF_Coop_Operation_Trident_VO', cue = 'TAUNT6', faction = 'UEF'
    },
}

------------
-- Mission 2
------------
-- Players' ACUs taking damage
TAUNT7 = {
    {
        text = '<LOC FAF_Coop_Operation_Trident_TAUNT7>[Cora]: Your end is near abomination.',
        vid = 'Vedetta.sfd', vidx = 'FAF_Coop_Operation_Trident_TAUNT7.sfd', bank = 'FAF_Coop_Operation_Trident_VO', cue = 'TAUNT7', faction = 'Aeon'
    },
}

-- Killing T2 navy
TAUNT8 = {
    {
        text = '<LOC FAF_Coop_Operation_Trident_TAUNT8>[Cora]: Every symbiont in the galaxy will soon by dead.',
        vid = 'Vedetta.sfd', vidx = 'FAF_Coop_Operation_Trident_TAUNT8.sfd', bank = 'FAF_Coop_Operation_Trident_VO', cue = 'TAUNT8', faction = 'Aeon'
    },
}

-- Killing T2 land units
TAUNT9 = {
    {
        text = '<LOC FAF_Coop_Operation_Trident_TAUNT9>[Cora]: You stand no chance of defeating me.',
        vid = 'Vedetta.sfd', vidx = 'FAF_Coop_Operation_Trident_TAUNT9.sfd', bank = 'FAF_Coop_Operation_Trident_VO', cue = 'TAUNT9', faction = 'Aeon'
    },
}

-- Losing structures
TAUNT10 = {
    {
        text = '<LOC FAF_Coop_Operation_Trident_TAUNT10>[Cora]: Hmm... a small victory for you, enjoy it while you can.',
        vid = 'Vedetta.sfd', vidx = 'FAF_Coop_Operation_Trident_TAUNT10.sfd', bank = 'FAF_Coop_Operation_Trident_VO', cue = 'TAUNT10', faction = 'Aeon'
    },
}

-- Damage to Cora's ACU
TAUNT11 = {
    {
        text = '<LOC FAF_Coop_Operation_Trident_TAUNT11>[Cora]: How dare you to attack the Knight!',
        vid = 'Vedetta.sfd', vidx = 'FAF_Coop_Operation_Trident_TAUNT11.sfd', bank = 'FAF_Coop_Operation_Trident_VO', cue = 'TAUNT11', faction = 'Aeon'
    },
}

-- Losing ships
TAUNT12 = {
    {
        text = '<LOC FAF_Coop_Operation_Trident_TAUNT12>[Cora]: Sooner or later my forces will reach your base.',
        vid = 'Vedetta.sfd', vidx = 'FAF_Coop_Operation_Trident_TAUNT12.sfd', bank = 'FAF_Coop_Operation_Trident_VO', cue = 'TAUNT12', faction = 'Aeon'
    },
}

-- Losing naval factory
TAUNT13 = {
    {
        text = '<LOC FAF_Coop_Operation_Trident_TAUNT13>[Cora]: Stay away from my base!',
        vid = 'Vedetta.sfd', vidx = 'FAF_Coop_Operation_Trident_TAUNT13.sfd', bank = 'FAF_Coop_Operation_Trident_VO', cue = 'TAUNT13', faction = 'Aeon'
    },
}

-- Killing ships
TAUNT14 = {
    {
        text = '<LOC FAF_Coop_Operation_Trident_TAUNT14>[Logan]: I shall have no mercy with you Cybran!',
        vid = 'Fletcher.sfd', vidx = 'FAF_Coop_Operation_Trident_TAUNT14.sfd', bank = 'FAF_Coop_Operation_Trident_VO', cue = 'TAUNT14', faction = 'UEF'
    },
}

-- Killing air units
TAUNT15 = {
    {
        text = '<LOC FAF_Coop_Operation_Trident_TAUNT15>[Logan]: Your air force is weakening.',
        vid = 'Fletcher.sfd', vidx = 'FAF_Coop_Operation_Trident_TAUNT15.sfd', bank = 'FAF_Coop_Operation_Trident_VO', cue = 'TAUNT15', faction = 'UEF'
    },
}

-- Losing structures
TAUNT16 = {
    {
        text = '<LOC FAF_Coop_Operation_Trident_TAUNT16>[Logan]: Come even closer so I can kill you faster!',
        vid = 'Fletcher.sfd', vidx = 'FAF_Coop_Operation_Trident_TAUNT16.sfd', bank = 'FAF_Coop_Operation_Trident_VO', cue = 'TAUNT16', faction = 'UEF'
    },
}

-- Losing ships
TAUNT17 = {
    {
        text = '<LOC FAF_Coop_Operation_Trident_TAUNT17>[Logan]: Don\'t think you can stop me, I\'ll rebuild those ships in no time!',
        vid = 'Fletcher.sfd', vidx = 'FAF_Coop_Operation_Trident_TAUNT17.sfd', bank = 'FAF_Coop_Operation_Trident_VO', cue = 'TAUNT17', faction = 'UEF'
    },
}

-- Killing structures
TAUNT18 = {
    {
        text = '<LOC FAF_Coop_Operation_Trident_TAUNT18>[Logan]: Your defense line seems to be falling apart.',
        vid = 'Fletcher.sfd', vidx = 'FAF_Coop_Operation_Trident_TAUNT18.sfd', bank = 'FAF_Coop_Operation_Trident_VO', cue = 'TAUNT18', faction = 'UEF'
    },
}
