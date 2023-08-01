-----------
-- Story --
-----------
-- General overview:
--      UEF is developing new experimental weapons on this planet, orbital satellites. This research must be stopped.
--    
-- Mission 1
--      Order naval fleet moves on the map and starts producing units. These units are given to the player/s to destroy the UEF base on the island, so the ACU's can gate in.
--      Objective to destroy the first research station.
--      A time limit to complete this mission, UEF satellites are aproaching and the only way to stop them is to gate in ACUs and let QAI upload a virus to disable them.
--      Few minutes after the timer is revealed, there's an option to gate in the ACU's immediately.
--
-- Mission 2
--      ACU's will spawn in on the island. Depending on number of players, Player1 will play with Order AI or with players.
--      Players 3-4 get an sACU.
--      There are two enemy bases (Cybran and UEF) each on another main island.
--      Incoming counter attack from both Cybran and UEF right after the ACUs spawn in.
--      
--      After the intro the satellites aproach player's ACU. QAI uploads the virus and disables them.
--
--      QAI's ACU controlled by AI spawns in to locate the main research facility. It builds a small base with monitoring station and a countdown begins until the main facility is located.
--
-- Mission 3
--      QAI locates the main research facility, the map expands the last time.
--      2 more enemy bases, one with Cybran commander, other with UEF commander, all the Novaxes and the reseach centres.
--      Objective to destroy all the satellites and research buildings.
--
--
--
-- Characters: name / voice actor
--      Seraphim: Thuum-Aez / everywhere116
--      UEF Commander: TBD / TBD
--      Order Commander: TBD / TBD
--      UEF Researcher: TBD / TBD
--      QAI: QAI / TBD
--
--          Info: Voice actors can suggest names for their characters.

Debriefing_Win = {
    {text = '<LOC FAF_Coop_Novax_Station_Assault_Debriefing_Win>[Thuum-Aez]: The UEF research station has been destroyed.', faction = 'Seraphim'},
}

Debriefing_Lose = {
    {text = '<LOC FAF_Coop_Novax_Station_Assault_Debriefing_Lose>[Thuum-Aez]: Our warrior was unable to stop the UEF from finishing their reseach on a new experimental weapon.', faction = 'Seraphim'},
}

-------------
-- Win / Lose
-------------



-- Player wins
PlayerWin = {
    {
        text = '<LOC FAF_Coop_Novax_Station_Assault_PlayerWin>[Thuum-Aez]: You have performed very well warrior. Without thier new weapon, the UEF will be easier to wipe out.',
        vid = 'Abasi.sfd', vidx = 'FAF_Coop_Novax_Station_Assault_PlayerWin', bank = 'FAF_Coop_Novax_Station_Assault_VO', cue = 'FAF_Coop_Novax_Station_Assault_PlayerWin', faction = 'Seraphim',
    },
}

-- Both mobile factories dead
M1CarriersDied = {
    {
        text = '<LOC FAF_Coop_Novax_Station_Assault_M1CarriersDied>[Thuum-Aez]: You let the UEF destroy both of your mobile factories! We won\'t be able to mount an offensive in time to stop the UEF from finishing their new experimental weapons.',
        vid = 'Abasi.sfd', vidx = 'FAF_Coop_Novax_Station_Assault_M1CarriersDied', bank = 'FAF_Coop_Novax_Station_Assault_VO', cue = 'FAF_Coop_Novax_Station_Assault_M1CarriersDied', faction = 'Seraphim',
    },
}

-- Timer ran out
M1TimeRanOut = {
    {
        text = '<LOC FAF_Coop_Novax_Station_Assault_M1TimeRanOut>[QAI]: I\'m detecting several UEF experimental satellites aproaching the starting position.',
        vid = 'QAI.sfd', vidx = 'FAF_Coop_Novax_Station_Assault_M1TimeRanOut', bank = 'FAF_Coop_Novax_Station_Assault_VO', cue = 'FAF_Coop_Novax_Station_Assault_M1TimeRanOut', faction = 'Cybran',
    },
}

-- Kill game dialogue
KillGameDialogue = {
    {
        text = '<LOC FAF_Coop_Novax_Station_Assault_KillGameDialogue>[Thuum-Aez]: You have failed us.',
        vid = 'Abasi.sfd', vidx = 'FAF_Coop_Novax_Station_Assault_KillGameDialogue', bank = 'FAF_Coop_Novax_Station_Assault_VO', cue = 'FAF_Coop_Novax_Station_Assault_KillGameDialogue', faction = 'Seraphim',
    },
}

-- Player dead
PlayerDead = {
    {
        text = '<LOC FAF_Coop_Novax_Station_Assault_PlayerDead>[Thuum-Aez]: TODO.',
        vid = 'Abasi.sfd', vidx = 'FAF_Coop_Novax_Station_Assault_PlayerDead', bank = 'FAF_Coop_Novax_Station_Assault_VO', cue = 'FAF_Coop_Novax_Station_Assault_PlayerDead', faction = 'Seraphim',
    },
}



--------
-- NIS 1
--------



------------
-- Dialogues
------------
-- Research Station
IntroResearchStation = {
    {
        text = '<LOC FAF_Coop_Novax_Station_Assault_IntroResearchStation>[Thuum-Aez]: Warrior, this is one of the UEF\'s experimental weapon research stations on this planet. It is a very important target.',
        vid = 'Abasi.sfd', vidx = 'FAF_Coop_Novax_Station_Assault_IntroResearchStation', bank = 'FAF_Coop_Novax_Station_Assault_VO', cue = 'FAF_Coop_Novax_Station_Assault_IntroResearchStation', faction = 'Seraphim',
    },
}

-- First Base
IntroUEFBase = {
    {
        text = '<LOC FAF_Coop_Novax_Station_Assault_IntroUEFBase>[Thuum-Aez]: The station is guarded by a small base that must be destroyed before we can send in any ACUs.',
        vid = 'Abasi.sfd', vidx = 'FAF_Coop_Novax_Station_Assault_IntroUEFBase', bank = 'FAF_Coop_Novax_Station_Assault_VO', cue = 'FAF_Coop_Novax_Station_Assault_IntroUEFBase', faction = 'Seraphim',
    },
}

-- UEF Patrols
IntroPatrols = {
    {
        text = '<LOC FAF_Coop_Novax_Station_Assault_IntroPatrols>[Thuum-Aez]: The humans have many units patrolling in this area. Don\'t let them stop you.',
        vid = 'Abasi.sfd', vidx = 'FAF_Coop_Novax_Station_Assault_IntroPatrols', bank = 'FAF_Coop_Novax_Station_Assault_VO', cue = 'FAF_Coop_Novax_Station_Assault_IntroPatrols', faction = 'Seraphim',
    },
}

-- Carriers
IntroCarriers = {
    {
        text = '<LOC FAF_Coop_Novax_Station_Assault_IntroCarriers_1>[Thuum-Aez]: The Order forces will come in from southeast to begin the assault.',
        vid = 'Abasi.sfd', vidx = 'FAF_Coop_Novax_Station_Assault_IntroCarriers_1', bank = 'FAF_Coop_Novax_Station_Assault_VO', cue = 'FAF_Coop_Novax_Station_Assault_IntroCarriers_1', faction = 'Seraphim',
    },
    {
        text = '<LOC FAF_Coop_Novax_Station_Assault_IntroCarriers_2>[Thuum-Aez]: They\'re sending a Tempest and an aircraft carrier to provide you with units to sanitize the landing area. Once its cleared the ACUs can gate in.',
        vid = 'Abasi.sfd', vidx = 'FAF_Coop_Novax_Station_Assault_IntroCarriers_2', bank = 'FAF_Coop_Novax_Station_Assault_VO', cue = 'FAF_Coop_Novax_Station_Assault_IntroCarriers_2', faction = 'Seraphim',
    },
}



------------
-- Mission 1
------------



-------------
-- Objectives
-------------
-- Primary Objective
M1P1Title = '<LOC FAF_Coop_Novax_Station_Assault_M1P1Title>Destroy UEF Research Station'
M1P1Description = '<LOC FAF_Coop_Novax_Station_Assault_M1P1Description>The UEF is developing new weapons on this planet. Destroy the marked research station to slow down their progress.'

-- Secondary Objective
M1S1Title = '<LOC FAF_Coop_Novax_Station_Assault_M1S1Title>Destroy the UEF Island Base'
M1S1Description = '<LOC FAF_Coop_Novax_Station_Assault_M1S1Description>It is advised to eliminate all UEF forces on the island before we send in the ACUs.'

-- Primary Objective
M1P2Title = '<LOC FAF_Coop_Novax_Station_Assault_M1P2Title>Protect Order Aircraft Carrier and Tempest'
M1P2Description = '<LOC FAF_Coop_Novax_Station_Assault_M1P2Description>The Order will provide you units for an attack on the UEF island base. Make sure you don\'t lose the mobile factories. At least one must survive.'

-- Primary Objective
M1P3Title = '<LOC FAF_Coop_Novax_Station_Assault_M1P3Title>Gate in with ACU'
M1P3Description = '<LOC FAF_Coop_Novax_Station_Assault_M1P3Description>ACUs must gate in before UEF\'s Defense Satellites arrives.'

-- Bonus Objective
M1B1Title = '<LOC FAF_Coop_Novax_Station_Assault_M1B1Title>Cruiser control'
M1B1Description = '<LOC FAF_Coop_Novax_Station_Assault_M1B1Description>Your cruisers survived the first part of the assault.'



---------
-- Others
---------
-- Title and description of the button
GateInButtonTitle = '<LOC FAF_Coop_Novax_Station_Assault_GateInButtonTitle>Gate In ACUs'
GateInButtonDescription = '<LOC FAF_Coop_Novax_Station_Assault_GateInButtonDescription>Signal that you are ready to gate in.'

-- Dialogue text after clicking the button
GateInDialogue = '<LOC FAF_Coop_Novax_Station_Assault_GateInDialogue>Are you sure that you want to proceed to the next part of the mission?'



------------
-- Dialogues
------------
-- Objective to kill research station
M1KillResearchStation1 = {
    {
        text = '<LOC FAF_Coop_Novax_Station_Assault_M1KillResearchStation1>[Thuum-Aez]: The UEF can\'t be allowed to finish their research. Clear the landing area of any enemy units and destroy the first research station.',
        vid = 'Abasi.sfd', vidx = 'FAF_Coop_Novax_Station_Assault_M1KillResearchStation1', bank = 'FAF_Coop_Novax_Station_Assault_VO', cue = 'FAF_Coop_Novax_Station_Assault_M1KillResearchStation1', faction = 'Seraphim',
    },
}

-- Following dialogue
M1KillResearchStation2 = {
    {
        text = '<LOC FAF_Coop_Novax_Station_Assault_M1KillResearchStation2_1>[Research]: This is Director TODO:name. Research Station Gamma is detecting incoming Order units from the southeast.',
        vid = '', vidx = 'FAF_Coop_Novax_Station_Assault_M1KillResearchStation2_1', bank = 'FAF_Coop_Novax_Station_Assault_VO', cue = 'FAF_Coop_Novax_Station_Assault_M1KillResearchStation2_1', faction = 'UEF',
    },
    {
        text = '<LOC FAF_Coop_Novax_Station_Assault_M1KillResearchStation2_2>[UEF Commander]: I\'m taking over control of all military stuctures. Destroying the Order forces won\'t take long...',
        vid = 'Fletcher.sfd', vidx = 'FAF_Coop_Novax_Station_Assault_M1KillResearchStation2_2', bank = 'FAF_Coop_Novax_Station_Assault_VO', cue = 'FAF_Coop_Novax_Station_Assault_M1KillResearchStation2_2', faction = 'UEF',
    },
    {
        text = '<LOC FAF_Coop_Novax_Station_Assault_M1KillResearchStation2_3>[Order Commander]: We shall see.',
        vid = 'Gari.sfd', vidx = 'FAF_Coop_Novax_Station_Assault_M1KillResearchStation2_3', bank = 'FAF_Coop_Novax_Station_Assault_VO', cue = 'FAF_Coop_Novax_Station_Assault_M1KillResearchStation2_3', faction = 'Aeon',
    },
}

-- Timer reveal
M1RevealTimer = {
    {
        text = '<LOC FAF_Coop_Novax_Station_Assault_M1RevealTimer_1>[Thuum-Aez]: Warrior, we are detecting several Experimental Defense Satellites approaching the carrier\'s location.',
        vid = 'Abasi.sfd', vidx = 'FAF_Coop_Novax_Station_Assault_M1RevealTimer_1', bank = 'FAF_Coop_Novax_Station_Assault_VO', cue = 'FAF_Coop_Novax_Station_Assault_M1RevealTimer_1', faction = 'Seraphim',
    },
    {
        text = '<LOC FAF_Coop_Novax_Station_Assault_M1RevealTimer_2>[UEF Commander]: You\'ve come to the wrong planet you freak!',
        vid = 'Fletcher.sfd', vidx = 'FAF_Coop_Novax_Station_Assault_M1RevealTimer_2', bank = 'FAF_Coop_Novax_Station_Assault_VO', cue = 'FAF_Coop_Novax_Station_Assault_M1RevealTimer_2', delay = 5, faction = 'UEF',
    },
    {
        text = '<LOC FAF_Coop_Novax_Station_Assault_M1RevealTimer_3>[QAI]: I will make a virus that will disable the satellites. However uploading it will require an ACU to be on the planet.',
        vid = 'QAI.sfd', vidx = 'FAF_Coop_Novax_Station_Assault_M1RevealTimer_3', bank = 'FAF_Coop_Novax_Station_Assault_VO', cue = 'FAF_Coop_Novax_Station_Assault_M1RevealTimer_3', faction = 'Cybran',
    },
}

-- Timer revealed
M1TimerRevealed = {
    {
        text = '<LOC FAF_Coop_Novax_Station_Assault_M1TimerRevealed>[Thuum-Aez]: Clear the landing area as soon as possible.',
        vid = 'Abasi.sfd', vidx = 'FAF_Coop_Novax_Station_Assault_M1TimerRevealed', bank = 'FAF_Coop_Novax_Station_Assault_VO', cue = 'FAF_Coop_Novax_Station_Assault_M1TimerRevealed', faction = 'Seraphim',
    },
}

-- Protect Carriers Objective / Actor: TBD / Update 9/9/2016 / VO TODO
M1ProtectCarriers = {
    {
        text = '<LOC FAF_Coop_Novax_Station_Assault_M1ProtectCarriers>[Order Commander]: Warrior, my mobile factories are the only source of units until we can gate in an ACU. We must protect them at any cost.',
        vid = 'Gari.sfd', vidx = 'FAF_Coop_Novax_Station_Assault_M1ProtectCarriers', bank = 'FAF_Coop_Novax_Station_Assault_VO', cue = 'FAF_Coop_Novax_Station_Assault_M1ProtectCarriers', faction = 'Aeon',
    },
}

-- Reveal Gate In Button
M1GateInButton = {
    {
        text = '<LOC FAF_Coop_Novax_Station_Assault_M1GateInButton>[Thuum-Aez]: Warrior, the ACUs are ready for gating in. If you want to gate in immediately and destroy rest of the units with your ACU, click on the command signal and then anywhere on the map. ',
        vid = 'Abasi.sfd', vidx = 'FAF_Coop_Novax_Station_Assault_M1GateInButton', bank = 'FAF_Coop_Novax_Station_Assault_VO', cue = 'FAF_Coop_Novax_Station_Assault_M1GateInButton', faction = 'Seraphim',
    },
}



-- Research Station Killed
M1ResearchStationKilled1 = {
    {
        text = '<LOC FAF_Coop_Novax_Station_Assault_M1ResearchStationKilled1>[Thuum-Aez]: We have confirmed that the first research station is destroyed. Proceed with clearing the landing area. Sanitize everything, Warrior.',
        vid = 'Abasi.sfd', vidx = 'FAF_Coop_Novax_Station_Assault_M1ResearchStationKilled1', bank = 'FAF_Coop_Novax_Station_Assault_VO', cue = 'FAF_Coop_Novax_Station_Assault_M1ResearchStationKilled1', faction = 'Seraphim',
    },
}

-- Research Station Killed
M1ResearchStationKilled2 = {
    {
        text = '<LOC FAF_Coop_Novax_Station_Assault_M1ResearchStationKilled2>[Thuum-Aez]: We have confirmed that the first research station is destroyed.',
        vid = 'Abasi.sfd', vidx = 'FAF_Coop_Novax_Station_Assault_M1ResearchStationKilled2', bank = 'FAF_Coop_Novax_Station_Assault_VO', cue = 'FAF_Coop_Novax_Station_Assault_M1ResearchStationKilled2', faction = 'Seraphim',
    },
}

-- Landing Area Cleared
M1LandingAreaCleared = {
    {
        text = '<LOC FAF_Coop_Novax_Station_Assault_M1LandingAreaCleared>[Thuum-Aez]: The landing area has been sanitized. We will start the gate in procedures, Warrior.',
        vid = 'Abasi.sfd', vidx = 'FAF_Coop_Novax_Station_Assault_M1LandingAreaCleared', bank = 'FAF_Coop_Novax_Station_Assault_VO', cue = 'FAF_Coop_Novax_Station_Assault_M1LandingAreaCleared', faction = 'Seraphim',
    },
}



------------
-- Reminders
------------
-- 10 min until satellites arrive
M1TimerObjReminder1 = {
    {
        text = '<LOC FAF_Coop_Novax_Station_Assault_M1TimerObjReminder1>[QAI]: The UEF satellites will arrive in 10 minutes.',
        vid = 'QAI.sfd', vidx = 'FAF_Coop_Novax_Station_Assault_M1TimerObjReminder1', bank = 'FAF_Coop_Novax_Station_Assault_VO', cue = 'FAF_Coop_Novax_Station_Assault_M1TimerObjReminder1', faction = 'Cybran',
    },
}

-- 5 min until satellites arrive
M1TimerObjReminder2 = {
    {
        text = '<LOC FAF_Coop_Novax_Station_Assault_M1TimerObjReminder2_1>[QAI]: The UEF satellites will arrive in 5 minutes.',
        vid = 'QAI.sfd', vidx = 'FAF_Coop_Novax_Station_Assault_M1TimerObjReminder2_1', bank = 'FAF_Coop_Novax_Station_Assault_VO', cue = 'FAF_Coop_Novax_Station_Assault_M1TimerObjReminder2_1', faction = 'Cybran',
    },
    {
        text = '<LOC FAF_Coop_Novax_Station_Assault_M1TimerObjReminder2_2>[Thuum-Aez]: Destroy the UEF station now! This assault can\'t fail.',
        vid = 'Abasi.sfd', vidx = 'FAF_Coop_Novax_Station_Assault_M1TimerObjReminder2_2', bank = 'FAF_Coop_Novax_Station_Assault_VO', cue = 'FAF_Coop_Novax_Station_Assault_M1TimerObjReminder2_2', faction = 'Seraphim',
    },
}

-- 1 min until satellites arrive
M1TimerObjReminder3 = {
    {
        text = '<LOC FAF_Coop_Novax_Station_Assault_M1TimerObjReminder3>[QAI]: The UEF satellites will arrive in 1 minute.',
        vid = 'QAI.sfd', vidx = 'FAF_Coop_Novax_Station_Assault_M1TimerObjReminder3', bank = 'FAF_Coop_Novax_Station_Assault_VO', cue = 'FAF_Coop_Novax_Station_Assault_M1TimerObjReminder3', faction = 'Cybran',
    },
}



--------
-- NIS 2
--------



------------
-- Dialogues
------------
-- Gate in ACU
M2Intro1 = {
    {
        text = '<LOC FAF_Coop_Novax_Station_Assault_M2Intro1>[QAI]: Gating in ACUs... Virus upload started.',
        vid = 'QAI.sfd', vidx = 'FAF_Coop_Novax_Station_Assault_M2Intro1', bank = 'FAF_Coop_Novax_Station_Assault_VO', cue = 'FAF_Coop_Novax_Station_Assault_M2Intro1', faction = 'Cybran',
    },
}

-- Incoming attack
M2Intro2 = {
    {
        text = '<LOC FAF_Coop_Novax_Station_Assault_M2Intro2_1>[Thuum-Aez]: Warrior, the enemy is sending units to your position, destroy them all and establish a base. The Order commander will support your assault.',
        vid = 'Abasi.sfd', vidx = 'FAF_Coop_Novax_Station_Assault_M2Intro2_1', bank = 'FAF_Coop_Novax_Station_Assault_VO', cue = 'FAF_Coop_Novax_Station_Assault_M2Intro2_1', faction = 'Seraphim',
    },
    {
        text = '<LOC FAF_Coop_Novax_Station_Assault_M2Intro2_2>[QAI]: Scanning area for the main UEF research station.',
        vid = 'QAI.sfd', vidx = 'FAF_Coop_Novax_Station_Assault_M2Intro2_2', bank = 'FAF_Coop_Novax_Station_Assault_VO', cue = 'FAF_Coop_Novax_Station_Assault_M2Intro2_2', faction = 'Cybran',
    },
}



-- Virus uploaded
M2PostIntro1 = {
    {
        text = '<LOC FAF_Coop_Novax_Station_Assault_M2PostIntro1>[QAI]: Virus successfully uploaded. Executing.',
        vid = 'QAI.sfd', vidx = 'FAF_Coop_Novax_Station_Assault_M2PostIntro1', bank = 'FAF_Coop_Novax_Station_Assault_VO', cue = 'FAF_Coop_Novax_Station_Assault_M2PostIntro1', faction = 'Cybran',
    },
}

-- Satellites dying
M2PostIntro2 = {
    {
        text = '<LOC FAF_Coop_Novax_Station_Assault_M2PostIntro2_1>[UEF Commander]: What the hell is going on? I\'m losing control of the satellites, they are falling out of the sky!.',
        vid = 'Fletcher.sfd', vidx = 'FAF_Coop_Novax_Station_Assault_M2PostIntro2_1', bank = 'FAF_Coop_Novax_Station_Assault_VO', cue = 'FAF_Coop_Novax_Station_Assault_M2PostIntro2_1', faction = 'UEF',
    },
    {
        text = '<LOC FAF_Coop_Novax_Station_Assault_M2PostIntro2_2>[Thuum-Aez]: Ha-ha-ha!.',
        vid = 'Abasi.sfd', vidx = 'FAF_Coop_Novax_Station_Assault_M2PostIntro2_2', bank = 'FAF_Coop_Novax_Station_Assault_VO', cue = 'FAF_Coop_Novax_Station_Assault_M2PostIntro2_2', delay = 2, faction = 'Seraphim',
    },
    {
        text = '<LOC FAF_Coop_Novax_Station_Assault_M2PostIntro2_3>[Research]: Commander, our network got infected with some kind of virus! It is interrupting the communication between the controls center and the satellites.',
        vid = '', vidx = 'FAF_Coop_Novax_Station_Assault_M2PostIntro2_3', bank = 'FAF_Coop_Novax_Station_Assault_VO', cue = 'FAF_Coop_Novax_Station_Assault_M2PostIntro2_3', faction = 'UEF',
    },
    {
        text = '<LOC FAF_Coop_Novax_Station_Assault_M2PostIntro2_4>[UEF Commander]: Fix it ASAP!.',
        vid = 'Fletcher.sfd', vidx = 'FAF_Coop_Novax_Station_Assault_M2PostIntro2_4', bank = 'FAF_Coop_Novax_Station_Assault_VO', cue = 'FAF_Coop_Novax_Station_Assault_M2PostIntro2_4', delay = 5, faction = 'UEF',
    },
    {
        text = '<LOC FAF_Coop_Novax_Station_Assault_M2PostIntro2_5>[QAI]: I am unable to locate the main UEF research facility. A monitoring station on the planet is required. Sending in an ACU.',
        vid = 'QAI.sfd', vidx = 'FAF_Coop_Novax_Station_Assault_M2PostIntro2_5', bank = 'FAF_Coop_Novax_Station_Assault_VO', cue = 'FAF_Coop_Novax_Station_Assault_M2PostIntro2_5', faction = 'Cybran',
    },
}



------------
-- Mission 2
------------



-------------
-- Objectives
-------------
-- Primary Objective 4 - Protct QAI
M2P1Title = '<LOC FAF_Coop_Novax_Station_Assault_M2P1Title>Protect QAI\'s ACU'
M2P1Description = '<LOC FAF_Coop_Novax_Station_Assault_M2P1Description>QAI will construct a monitoring station to locate UEF research facility, protect it.'

-- Primary Objective 5 - Timer
M2P2Title = '<LOC FAF_Coop_Novax_Station_Assault_M2P2Title>Wait until QAI locates UEF'
M2P2Description = '<LOC FAF_Coop_Novax_Station_Assault_M2P2Description>Locating the research facility will take some time, prepare your army meanwhile.'



------------
-- Dialogues
------------
-- Protect QAI
M2ProtectQAI = {
    {
        text = '<LOC FAF_Coop_Novax_Station_Assault_M2_Protect_QAI>[Thuum-Aez]: Warrior, make sure QAI\'s ACU doesn\'t get destroyed. It must locate the research station!',
        vid = 'Abasi.sfd', vidx = 'FAF_Coop_Novax_Station_Assault_M2_Protect_QAI', bank = 'FAF_Coop_Novax_Station_Assault_VO', cue = 'FAF_Coop_Novax_Station_Assault_M2_Protect_QAI', faction = 'Seraphim',
    },
}

-- QAI dies
M2QAIDead = {
    {
        text = '<LOC FAF_Coop_Novax_Station_Assault_M2QAIDead>[Thuum-Aez]: QAI\'s ACU was destroyed. We can\'t locate the UEF research station anymore!',
        vid = 'Abasi.sfd', vidx = 'FAF_Coop_Novax_Station_Assault_M2QAIDead', bank = 'FAF_Coop_Novax_Station_Assault_VO', cue = 'FAF_Coop_Novax_Station_Assault_M2QAIDead', faction = 'Seraphim',
    },
}

-- Reveal Timer objective
M2TimerObjective = {
    {
        text = '<LOC FAF_Coop_Novax_Station_Assault_M2TimerObjective_1>[QAI]: Monitoring station finished. Recieving data...',
        vid = 'QAI.sfd', vidx = 'FAF_Coop_Novax_Station_Assault_M2TimerObjective_1', bank = 'FAF_Coop_Novax_Station_Assault_VO', cue = 'FAF_Coop_Novax_Station_Assault_M2TimerObjective_1', delay = 5, faction = 'Cybran',
    },
    {
        text = '<LOC FAF_Coop_Novax_Station_Assault_M2TimerObjective_2>[QAI]: Location of the main research facility will be known in 15 minutes.',
        vid = 'QAI.sfd', vidx = 'FAF_Coop_Novax_Station_Assault_M2TimerObjective_2', bank = 'FAF_Coop_Novax_Station_Assault_VO', cue = 'FAF_Coop_Novax_Station_Assault_M2TimerObjective_2', faction = 'Cybran',
    },
}

-- UEF research base found
M2TimerObjDone = {
    {
        text = '<LOC FAF_Coop_Novax_Station_Assault_M2TimerObjDone>[QAI]: Scanning complated. I have successfully localized UEF\'s man research facilities.',
        vid = 'QAI.sfd', vidx = 'FAF_Coop_Novax_Station_Assault_M2TimerObjDone', bank = 'FAF_Coop_Novax_Station_Assault_VO', cue = 'FAF_Coop_Novax_Station_Assault_M2TimerObjDone', faction = 'Cybran',
    },
}



------------
-- Reminders
------------
-- 10 min until finding research station
M2TimerObjReminder1 = {
    {
        text = '<LOC FAF_Coop_Novax_Station_Assault_M2TimerObjReminder1>[QAI]: 10 minutes remain.',
        vid = 'QAI.sfd', vidx = 'FAF_Coop_Novax_Station_Assault_M2TimerObjReminder1', bank = 'FAF_Coop_Novax_Station_Assault_VO', cue = 'FAF_Coop_Novax_Station_Assault_M2TimerObjReminder1', faction = 'Cybran',
    },
}

-- 5 min until finding research station
M2TimerObjReminder2 = {
    {
        text = '<LOC FAF_Coop_Novax_Station_Assault_M2TimerObjReminder2>[QAI]: 5 minutes remain.',
        vid = 'QAI.sfd', vidx = 'FAF_Coop_Novax_Station_Assault_M2TimerObjReminder2', bank = 'FAF_Coop_Novax_Station_Assault_VO', cue = 'FAF_Coop_Novax_Station_Assault_M2TimerObjReminder2', faction = 'Cybran',
    },
}



--------
-- NIS 3
--------



------------
-- Dialogues
------------
-- Gate in ACU
M3Intro1 = {
    {
        text = '<LOC FAF_Coop_Novax_Station_Assault_M3Intro1>[Thuum-Aez]: QAI found the main research facilty, it is on the island north of your current position.',
        vid = 'Abasi.sfd', vidx = 'FAF_Coop_Novax_Station_Assault_M3Intro1', bank = 'FAF_Coop_Novax_Station_Assault_VO', cue = 'FAF_Coop_Novax_Station_Assault_M3Intro1', faction = 'Seraphim',
    },
}

-- Gate in ACU
M3Intro2 = {
    {
        text = '<LOC FAF_Coop_Novax_Station_Assault_M3Intro2>[Thuum-Aez]: First you will have to deal with the Cybran commander. His base is on the island between you and the UEF main base.',
        vid = 'Abasi.sfd', vidx = 'FAF_Coop_Novax_Station_Assault_M3Intro2', bank = 'FAF_Coop_Novax_Station_Assault_VO', cue = 'FAF_Coop_Novax_Station_Assault_M3Intro2', faction = 'Seraphim',
    },
}

-- Gate in ACU
M3Intro3 = {
    {
        text = '<LOC FAF_Coop_Novax_Station_Assault_M3Intro3>[Thuum-Aez]: Both the research station and UEF main base are located on this island.',
        vid = 'Abasi.sfd', vidx = 'FAF_Coop_Novax_Station_Assault_M3Intro3', bank = 'FAF_Coop_Novax_Station_Assault_VO', cue = 'FAF_Coop_Novax_Station_Assault_M3Intro3', faction = 'Seraphim',
    },
}

M3Intro4 = {
    {
        text = '<LOC FAF_Coop_Novax_Station_Assault_M3Intro4>[Thuum-Aez]: The UEF managed to block off QAI\'s futher hacking attempts. They have several satellites operational on the island.',
        vid = 'Abasi.sfd', vidx = 'FAF_Coop_Novax_Station_Assault_M3Intro4', bank = 'FAF_Coop_Novax_Station_Assault_VO', cue = 'FAF_Coop_Novax_Station_Assault_M3Intro4', faction = 'Seraphim',
    },
}

M3Intro5 = {
    {
        text = '<LOC FAF_Coop_Novax_Station_Assault_M3Intro5>[Thuum-Aez]: Move there and destroy all the satellites control buildings and marked research centres.',
        vid = 'Abasi.sfd', vidx = 'FAF_Coop_Novax_Station_Assault_M3Intro5', bank = 'FAF_Coop_Novax_Station_Assault_VO', cue = 'FAF_Coop_Novax_Station_Assault_M3Intro5', faction = 'Seraphim',
    },
}



------------
-- Mission 3
------------



-------------
-- Objectives
-------------
-- Primary Objective
M3P1Title = '<LOC FAF_Coop_Novax_Station_Assault_M3P1Title>Wipe out the main research station'
M3P1Description = '<LOC FAF_Coop_Novax_Station_Assault_M3P1Description>QAI located the main UEF research station in the middle of the UEF base. Engage the UEF base and burn down all the research buildings you find there.'

-- Primary Objective
M3P2Title = '<LOC FAF_Coop_Novax_Station_Assault_M3P2Title>Eliminate all Novax Centers'
M3P2Description = '<LOC FAF_Coop_Novax_Station_Assault_M3P2Description>The UEF already deployed several of their new experimental weapons. Destroy them.'

-- Secondary Objective
M3S1Title = '<LOC FAF_Coop_Novax_Station_Assault_M3S1Title>Defeat Cybran Commander'
M3S1Description = '<LOC FAF_Coop_Novax_Station_Assault_M3S1Description>The Cybran base is between you and the UEF research facilities. Destroy it to secure more resources for the final offensive.'



---------
-- Others
---------
-- Title and description of the button
M3OrderAttackPingTitle = '<LOC FAF_Coop_Novax_Station_Assault_M3OrderAttackPingTitle>Set target for Order attacks'
M3OrderAttackPingDescription = '<LOC FAF_Coop_Novax_Station_Assault_M3OrderAttackPingDescription>Click on the enemy island you want the Order to send attack at.'
M3TargetAreaSet = '<LOC FAF_Coop_Novax_Station_Assault_M3TargetAreaSet>New target set!'
M3AreaCleared = '<LOC FAF_Coop_Novax_Station_Assault_M3AreaCleared>This base is already destroyed, select another one.'
M3SameArea = '<LOC FAF_Coop_Novax_Station_Assault_M3SameArea>This island is already set as a target!'
M3InvalidArea = '<LOC FAF_Coop_Novax_Station_Assault_M3InvalidArea>You need to click on one of the enemy islands!'

M3StartingOrderAttacks = {
    {
        text = '<LOC FAF_Coop_Novax_Station_Assault_M3StartingOrderAttacks>[Order Commander]: Master, my base is fully operational and I\'m starting to build attacking units. You can specify a base I should focus on, else I will start with the Cybran base to the west.',
        vid = 'Gari.sfd', vidx = 'FAF_Coop_Novax_Station_Assault_M3StartingOrderAttacks', bank = 'FAF_Coop_Novax_Station_Assault_VO', cue = 'FAF_Coop_Novax_Station_Assault_M3StartingOrderAttacks', faction = 'Aeon',
    },
} 

M3NewOrderTargetCybranIsland = {
    {
        text = '<LOC FAF_Coop_Novax_Station_Assault_M3NewOrderTargetCybranIsland>[Order Commander]: I will attack the Cybran base to west.',
        vid = 'Gari.sfd', vidx = 'FAF_Coop_Novax_Station_Assault_M3NewOrderTargetCybranIsland', bank = 'FAF_Coop_Novax_Station_Assault_VO', cue = 'FAF_Coop_Novax_Station_Assault_M3NewOrderTargetCybranIsland', faction = 'Aeon',
    },
}

M3NewOrderTargetUEFIsland = {
    {
        text = '<LOC FAF_Coop_Novax_Station_Assault_M3NewOrderTargetUEFIsland>[Order Commander]: The smaller UEF base to the north is my next target.',
        vid = 'Gari.sfd', vidx = 'FAF_Coop_Novax_Station_Assault_M3NewOrderTargetUEFIsland', bank = 'FAF_Coop_Novax_Station_Assault_VO', cue = 'FAF_Coop_Novax_Station_Assault_M3NewOrderTargetUEFIsland', faction = 'Aeon',
    },
}

M3NewOrderTargetCybranMain = {
    {
        text = '<LOC FAF_Coop_Novax_Station_Assault_M3NewOrderTargetCybranMain_1>[Thuum-Aez]: Attack the Cybran commander.',
        vid = 'Abasi.sfd', vidx = 'FAF_Coop_Novax_Station_Assault_M3NewOrderTargetCybranMain_1', bank = 'FAF_Coop_Novax_Station_Assault_VO', cue = 'FAF_Coop_Novax_Station_Assault_M3NewOrderTargetCybranMain_1', faction = 'Seraphim',
    },
    {
        text = '<LOC FAF_Coop_Novax_Station_Assault_M3NewOrderTargetCybranMain_2>[Order Commander]: As you wish master.',
        vid = 'Gari.sfd', vidx = 'FAF_Coop_Novax_Station_Assault_M3NewOrderTargetCybranMain_2', bank = 'FAF_Coop_Novax_Station_Assault_VO', cue = 'FAF_Coop_Novax_Station_Assault_M3NewOrderTargetCybranMain_2', faction = 'Aeon',
    },
}

M3NewOrderTargetUEFMain = {
    {
        text = '<LOC FAF_Coop_Novax_Station_Assault_M3NewOrderTargetUEFMain>[Order Commander]: My units are on the way to the main UEF base.',
        vid = 'Gari.sfd', vidx = 'FAF_Coop_Novax_Station_Assault_M3NewOrderTargetUEFMain', bank = 'FAF_Coop_Novax_Station_Assault_VO', cue = 'FAF_Coop_Novax_Station_Assault_M3NewOrderTargetUEFMain', faction = 'Aeon',
    },
}

------------
-- Dialogues
------------
-- First Novax Centre gets destroyed
M3FirstNovaxDestroyed = {
    {
        text = '<LOC FAF_Coop_Novax_Station_Assault_M3FirstNovaxDestroyed>[QAI]: First control centre destroyed. It\'s satellites got disabled and is falling from the sky.',
        vid = 'QAI.sfd', vidx = 'FAF_Coop_Novax_Station_Assault_M3FirstNovaxDestroyed', bank = 'FAF_Coop_Novax_Station_Assault_VO', cue = 'FAF_Coop_Novax_Station_Assault_M3FirstNovaxDestroyed', faction = 'Cybran',
    },
}

-- 3/4 of Novax Centres are destroyed
M3MostNovaxesDestroyed = {
    {
        text = '<LOC FAF_Coop_Novax_Station_Assault_M3MostNovaxesDestroyed>[Thuum-Aez]: Most of the satellite control centres are destroyed, press the attack and finish up the rest!',
        vid = 'Abasi.sfd', vidx = 'FAF_Coop_Novax_Station_Assault_M3MostNovaxesDestroyed', bank = 'FAF_Coop_Novax_Station_Assault_VO', cue = 'FAF_Coop_Novax_Station_Assault_M3MostNovaxesDestroyed', faction = 'Seraphim',
    },
}

-- Obj to destroy novaxes is done
M3AllNovaxesDestroyed = {
    {
        text = '<LOC FAF_Coop_Novax_Station_Assault_M3AllNovaxesDestroyed_1>[Order Commander]: That should be the last control centre master.',
        vid = 'Gari.sfd', vidx = 'FAF_Coop_Novax_Station_Assault_M3AllNovaxesDestroyed_1', bank = 'FAF_Coop_Novax_Station_Assault_VO', cue = 'FAF_Coop_Novax_Station_Assault_M3AllNovaxesDestroyed_1', faction = 'Aeon',
    },
    {
        text = '<LOC FAF_Coop_Novax_Station_Assault_M3AllNovaxesDestroyed_2>[QAI]: Confirmed, I am not detecting any other control centres.',
        vid = 'QAI.sfd', vidx = 'FAF_Coop_Novax_Station_Assault_M3AllNovaxesDestroyed_2', bank = 'FAF_Coop_Novax_Station_Assault_VO', cue = 'FAF_Coop_Novax_Station_Assault_M3AllNovaxesDestroyed_2', faction = 'Cybran',
    },
}

-- Obj to destroy novaxes is done, Order commander is dead
M3AllNovaxesDestroyedAlt = {
    {
        text = '<LOC FAF_Coop_Novax_Station_Assault_M3AllNovaxesDestroyedAlt_1>[Thuum-Aez]: That should be the last control centre warrior.',
        vid = 'Abasi.sfd', vidx = 'FAF_Coop_Novax_Station_Assault_M3AllNovaxesDestroyedAlt_1', bank = 'FAF_Coop_Novax_Station_Assault_VO', cue = 'FAF_Coop_Novax_Station_Assault_M3AllNovaxesDestroyedAlt_1', faction = 'Seraphim',
    },
    {
        text = '<LOC FAF_Coop_Novax_Station_Assault_M3AllNovaxesDestroyedAlt_2>[QAI]: Confirmed, I am not detecting any other control centres.',
        vid = 'QAI.sfd', vidx = 'FAF_Coop_Novax_Station_Assault_M3AllNovaxesDestroyedAlt_2', bank = 'FAF_Coop_Novax_Station_Assault_VO', cue = 'FAF_Coop_Novax_Station_Assault_M3AllNovaxesDestroyedAlt_2', faction = 'Cybran',
    },
}

-- First research centre is destroyed
M3FirstResearchDestroyed = {
    {
        text = '<LOC FAF_Coop_Novax_Station_Assault_M3FirstResearchDestroyed>[Order Commander]: We\'ve destroyed one of the research stations.',
        vid = 'Gari.sfd', vidx = 'FAF_Coop_Novax_Station_Assault_M3FirstResearchDestroyed', bank = 'FAF_Coop_Novax_Station_Assault_VO', cue = 'FAF_Coop_Novax_Station_Assault_M3FirstResearchDestroyed', faction = 'Aeon',
    },
}

-- First research centre is destroyed, Order commander is dead
M3FirstResearchDestroyedAlt = {
    {
        text = '<LOC FAF_Coop_Novax_Station_Assault_M3FirstResearchDestroyedAlt>[QAI]: First research station is destroyed.',
        vid = 'QAI.sfd', vidx = 'FAF_Coop_Novax_Station_Assault_M3FirstResearchDestroyedAlt', bank = 'FAF_Coop_Novax_Station_Assault_VO', cue = 'FAF_Coop_Novax_Station_Assault_M3FirstResearchDestroyedAlt', faction = 'Cybran',
    },
}

-- Obj to destroy research stations done
M3AllResearchDestroyed = {
    {
        text = '<LOC FAF_Coop_Novax_Station_Assault_M3AllResearchDestroyed>[Thuum-Aez]: Well done, both of the UEF\'s research stations are destroyed.',
        vid = 'Abasi.sfd', vidx = 'FAF_Coop_Novax_Station_Assault_M3AllResearchDestroyed', bank = 'FAF_Coop_Novax_Station_Assault_VO', cue = 'FAF_Coop_Novax_Station_Assault_M3AllResearchDestroyed', faction = 'Seraphim',
    },
}

-- Tell the player that the only way to destroy the sattelities is to destroy their control centres.
M3NovaxDialogue = {
    {
        text = '<LOC FAF_Coop_Novax_Station_Assault_M3NovaxDialogue_1>[Thuum-Aez]: Warrior, another group of the UEF satellies is operational and approaching your base. QAI, report.',
        vid = 'Abasi.sfd', vidx = 'FAF_Coop_Novax_Station_Assault_M3NovaxDialogue_1', bank = 'FAF_Coop_Novax_Station_Assault_VO', cue = 'FAF_Coop_Novax_Station_Assault_M3NovaxDialogue_1', faction = 'Seraphim',
    },
    {
        text = '<LOC FAF_Coop_Novax_Station_Assault_M3NovaxDialogue_2>[QAI]: My virus is no longer effective and I am unable to breach the UEF\'s new security measures.',
        vid = 'QAI.sfd', vidx = 'FAF_Coop_Novax_Station_Assault_M3NovaxDialogue_2', bank = 'FAF_Coop_Novax_Station_Assault_VO', cue = 'FAF_Coop_Novax_Station_Assault_M3NovaxDialogue_2', faction = 'Cybran',
    },
    {
        text = '<LOC FAF_Coop_Novax_Station_Assault_M3NovaxDialogue_3>[Thuum-Aez]: We don\'t have means of targeting the satellites directly. In order to destroyed them, you will have to destroy their control centres that are located in the UEF\'s main base.',
        vid = 'Abasi.sfd', vidx = 'FAF_Coop_Novax_Station_Assault_M3NovaxDialogue_3', bank = 'FAF_Coop_Novax_Station_Assault_VO', cue = 'FAF_Coop_Novax_Station_Assault_M3NovaxDialogue_3', faction = 'Seraphim',
    },
}

-- UEF Commander Killed
M3UEFCommanderKilled = {
    {
        text = '<LOC FAF_Coop_Novax_Station_Assault_M3UEFCommanderKilled_1>[UEF Commander]: Aaaaargh',
        vid = 'Fletcher.sfd', vidx = 'FAF_Coop_Novax_Station_Assault_M3UEFCommanderKilled_1', bank = 'FAF_Coop_Novax_Station_Assault_VO', cue = 'FAF_Coop_Novax_Station_Assault_M3UEFCommanderKilled_1', faction = 'UEF',
    },
    {
        text = '<LOC FAF_Coop_Novax_Station_Assault_M3UEFCommanderKilled_2>[Thuum-Aez]: One less human, ha-ha.',
        vid = 'Abasi.sfd', vidx = 'FAF_Coop_Novax_Station_Assault_M3UEFCommanderKilled_2', bank = 'FAF_Coop_Novax_Station_Assault_VO', cue = 'FAF_Coop_Novax_Station_Assault_M3UEFCommanderKilled_2', faction = 'Seraphim',
    },
}

-- Cybran commander is killed
M3CybranCommanderDefeated = {
    {
        text = '<LOC FAF_Coop_Novax_Station_Assault_M3CybranCommanderDefeated>[Order Commander]: Well done master, nothing is stopping us now from attacking the UEF main research facilty.',
        vid = 'Gari.sfd', vidx = 'FAF_Coop_Novax_Station_Assault_M3CybranCommanderDefeated', bank = 'FAF_Coop_Novax_Station_Assault_VO', cue = 'FAF_Coop_Novax_Station_Assault_M3CybranCommanderDefeated', faction = 'Aeon',
    },
}

M3CybranCommanderDefeatedAlt = {
    {
        text = '<LOC FAF_Coop_Novax_Station_Assault_M3CybranCommanderDefeatedAlt>[Thuum-Aez]: The Cybran commander is defeateer, nothing is stopping you now from attacking the UEF main research facilty.',
        vid = 'Abasi.sfd', vidx = 'FAF_Coop_Novax_Station_Assault_M3CybranCommanderDefeatedAlt', bank = 'FAF_Coop_Novax_Station_Assault_VO', cue = 'FAF_Coop_Novax_Station_Assault_M3CybranCommanderDefeatedAlt', faction = 'Aeon',
    },
}



------------
-- Reminders
------------



---------
-- Taunts
---------



-- UEF killing enemy ships
M1UEFTaunt1 = {
    {
        text = '<LOC FAF_Coop_Novax_Station_Assault_M1UEFTaunt1>[UEF Commander]: Your ships are such a good target for my fleet.',
        vid = 'Fletcher.sfd', vidx = 'FAF_Coop_Novax_Station_Assault_M1UEFTaunt1', bank = 'FAF_Coop_Novax_Station_Assault_VO', cue = 'FAF_Coop_Novax_Station_Assault_M1UEFTaunt1', faction = 'UEF',
    },
}

-- UEF losing ships
M1UEFTaunt2 = {
    {
        text = '<LOC FAF_Coop_Novax_Station_Assault_M1UEFTaunt2>[UEF Commander]: You won\'t stop me!',
        vid = 'Fletcher.sfd', vidx = 'FAF_Coop_Novax_Station_Assault_M1UEFTaunt2', bank = 'FAF_Coop_Novax_Station_Assault_VO', cue = 'FAF_Coop_Novax_Station_Assault_M1UEFTaunt2', faction = 'UEF',
    },
}

-- UEF losing torp launcher
M1UEFTaunt3 = {
    {
        text = '<LOC FAF_Coop_Novax_Station_Assault_M1UEFTaunt3>[UEF Commander]: Just come closer, my army is waiting for you.',
        vid = 'Fletcher.sfd', vidx = 'FAF_Coop_Novax_Station_Assault_M1UEFTaunt3', bank = 'FAF_Coop_Novax_Station_Assault_VO', cue = 'FAF_Coop_Novax_Station_Assault_M1UEFTaunt3', faction = 'UEF',
    },
}



-- Order sACU Killed
OrdersACUKilled1 = {
    {
        text = '<LOC FAF_Coop_Novax_Station_Assault_OrdersACUKilled1>[UEF Commander]: One boogie down!',
        vid = 'Fletcher.sfd', vidx = 'FAF_Coop_Novax_Station_Assault_OrdersACUKilled1', bank = 'FAF_Coop_Novax_Station_Assault_VO', cue = 'FAF_Coop_Novax_Station_Assault_OrdersACUKilled1', faction = 'UEF',
    },
}

OrdersACUKilled2 = {
    {
        text = '<LOC FAF_Coop_Novax_Station_Assault_OrdersACUKilled2>[Order Commander]: You will pay for this!',
        vid = 'Gari.sfd', vidx = 'FAF_Coop_Novax_Station_Assault_OrdersACUKilled2', bank = 'FAF_Coop_Novax_Station_Assault_VO', cue = 'FAF_Coop_Novax_Station_Assault_OrdersACUKilled2', faction = 'Aeon',
    },
}



-- UEF losing ships
M3UEFTaunt1 = {
    {
        text = '<LOC FAF_Coop_Novax_Station_Assault_M3UEFTaunt1>[UEF Commander]: You can\'t defeat the Coalition!',
        vid = 'Fletcher.sfd', vidx = 'FAF_Coop_Novax_Station_Assault_M3UEFTaunt1', bank = 'FAF_Coop_Novax_Station_Assault_VO', cue = 'FAF_Coop_Novax_Station_Assault_M3UEFTaunt1', faction = 'UEF',
    },
}

M3UEFTaunt2 = {
    {
        text = '<LOC F3F_Coop_Novax_Station_Assault_M3UEFTaunt2>[UEF Commander]: I\'m coming for you Seraphim!',
        vid = 'Fletcher.sfd', vidx = 'F3F_Coop_Novax_Station_Assault_M3UEFTaunt2', bank = 'FAF_Coop_Novax_Station_Assault_VO', cue = 'F3F_Coop_Novax_Station_Assault_M3UEFTaunt2', faction = 'UEF',
    },
}

-- Damaging player's ACU.
_M3UEFTaunt2 = {
    {
        text = '<LOC F3F_Coop_Novax_Station_Assault_M1UEFTaunt2>[UEF Commander]: I\'ve got you now.',
        vid = 'Fletcher.sfd', vidx = 'F3F_Coop_Novax_Station_Assault_M1UEFTaunt2', bank = 'FAF_Coop_Novax_Station_Assault_VO', cue = 'F3F_Coop_Novax_Station_Assault_M1UEFTaunt2', faction = 'UEF',
    },
}

_M3UEFTaunt2 = {
    {
        text = '<LOC F3F_Coop_Novax_Station_Assault_M1UEFTaunt2>[UEF Commander]: I\'m coming for you Seraphim!',
        vid = 'Fletcher.sfd', vidx = 'F3F_Coop_Novax_Station_Assault_M1UEFTaunt2', bank = 'FAF_Coop_Novax_Station_Assault_VO', cue = 'F3F_Coop_Novax_Station_Assault_M1UEFTaunt2', faction = 'UEF',
    },
}