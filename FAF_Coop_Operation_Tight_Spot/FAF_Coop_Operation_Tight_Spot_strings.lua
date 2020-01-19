OPERATION_NAME = 'Operation Tight Spot'
OPERATION_DESCRIPTION = 'czar mission' -- TODO: Proper mission description



-------------
-- Debriefing
-------------
-- Showed on the score screen if player wins
Debriefing_Win = {
    {
        text = 'You win', faction = 'Aeon'
    },
}

-- Showed on the score screen if player loses
Debriefing_Lose = {
    {
        text = 'You lose', faction = 'Aeon'
    },
}



-------------
-- Win / Lose
-------------
-- Player dies
PlayerDies = {
    {
        text = '<LOC FAF_Coop_Operation_Tight_Spot_PlayerDies>[{i HQ}]: Commander, come in! Damn it, we\'ve lost her.',
        vid = 'FAF_Coop_Operation_Tight_Spot_PlayerDies.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'PlayerDies', faction = 'UEF'
    },
}



-------------------------
-- Mission 1 - Evacuation
-------------------------
-- Intro dialogue
M1Intro = {
    {
        text = '<LOC FAF_Coop_Operation_Tight_Spot_M1Intro_1>[Charis]: Sister, my reinforcements are on the way and they will arrive shortly. Defend your position until then.',
        vid = 'Amalia.sfd', vidx = 'FAF_Coop_Operation_Tight_Spot_M1Intro_1.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M1Intro_1', faction = 'Aeon'
    },
    {
        text = '<LOC FAF_Coop_Operation_Tight_Spot_M1Intro_2>[{i QAI}]: It was a mistake to come to this planet.',
        vid = 'QAI.sfd', vidx = 'FAF_Coop_Operation_Tight_Spot_M1Intro_2.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M1Intro_2', faction = 'Cybran'
    },
}



-- Objective to build transport
M1SpiderBotWarning = {
    {
        text = '<LOC FAF_Coop_Operation_Tight_Spot_M1SpiderBotWarning>[{i HQ}]: Commander, we\'re picking up a group of land experimentals approaching from the east. Charis\' reinforcements won\'t be enough to stop them so you will have to abandon your position. Build a transport ASAP and prepare for an evac.',
        vid = 'FAF_Coop_Operation_Tight_Spot_M1SpiderBotWarning.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M1SpiderBotWarning', faction = 'UEF'
    },
}



-- Reminder to keep ACU in the base area
M1ACUInBaseReminder1 = {
    {
        text = '<LOC FAF_Coop_Operation_Tight_Spot_M1ACUInBaseReminder1>[{i HQ}]: Commander, you need to stay in your base until the reinforcements arrive.',
        vid = 'FAF_Coop_Operation_Tight_Spot_M1ACUInBaseReminder1.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M1ACUInBaseReminder1', faction = 'UEF'
    },
}

-- Reminder to keep ACU in the base area
M1ACUInBaseReminder2 = {
    {
        text = '<LOC FAF_Coop_Operation_Tight_Spot_M1ACUInBaseReminder2>[{i HQ}]: Return to your base commander, you won\'t be able to stop those experimentals with your ACU.',
        vid = 'FAF_Coop_Operation_Tight_Spot_M1ACUInBaseReminder2.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M1ACUInBaseReminder2', faction = 'UEF'
    },
}

-- Reminder to keep ACU in the base area
M1ACUInBaseReminder3 = {
    {
        text = '<LOC FAF_Coop_Operation_Tight_Spot_M1ACUInBaseReminder3>[Charis]: Sister I will not be able to cover you if you leave your base. Please return.',
        vid = 'Amalia.sfd', vidx = 'FAF_Coop_Operation_Tight_Spot_M1ACUInBaseReminder3.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M1ACUInBaseReminder3', faction = 'Aeon'
    },
}



-- MLs on the map, player has a transport
M1SpiderBotsSpotted1 = {
    {
        text = '<LOC FAF_Coop_Operation_Tight_Spot_M1SpiderBotsSpotted1_1>[{i HQ}]: Here they come, it\'s gonna be close.',
        vid = 'FAF_Coop_Operation_Tight_Spot_M1SpiderBotsSpotted1_1.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M1SpiderBotsSpotted1_1', faction = 'UEF'
    },
    {
        text = '<LOC FAF_Coop_Operation_Tight_Spot_M1SpiderBotsSpotted1_2>[{i QAI}]: You can not escape.',
        vid = 'QAI.sfd', vidx = 'FAF_Coop_Operation_Tight_Spot_M1SpiderBotsSpotted1_2.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M1SpiderBotsSpotted1_2', faction = 'Cybran'
    },
}

-- MLs on the map, player doesn't have a transport
M1SpiderBotsSpotted2 = {
    {
        text = '<LOC FAF_Coop_Operation_Tight_Spot_M1SpiderBotsSpotted2>[{i HQ}]: There they are commander, you need that transport right now!',
        vid = 'FAF_Coop_Operation_Tight_Spot_M1SpiderBotsSpotted2.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M1SpiderBotsSpotted2', faction = 'UEF'
    },
}

-- Loyalist forces arrive
M1ReeinforcementsArrived = {
    {
        text = '<LOC FAF_Coop_Operation_Tight_Spot_M1ReeinforcementsArrived>[Charis]: We must hurry, I will cover your retreat with my units.',
        vid = 'Amalia.sfd', vidx = 'FAF_Coop_Operation_Tight_Spot_M1ReeinforcementsArrived.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M1ReeinforcementsArrived', faction = 'Aeon'
    },
}

-- CZAR Dies
M1ReinforcementsDestroyed = {
    {
        text = '<LOC FAF_Coop_Operation_Tight_Spot_M1ReinforcementsDestroyed>[Charis]: No! Forgive me sister, I\'ve failed you.',
        vid = 'Amalia.sfd', vidx = 'FAF_Coop_Operation_Tight_Spot_M1ReinforcementsDestroyed.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M1ReinforcementsDestroyed', faction = 'Aeon'
    },
}



-- Primary Objective
M1P1Title = '<LOC FAF_Coop_Operation_Tight_Spot_M1P1Title>Survive QAI\'s Assault'
M1P1Description = '<LOC FAF_Coop_Operation_Tight_Spot_M1P1Description>Crusader Charis\' reinforcements will arrive soon. Repeal the attacking units and prepare for an evacuation.'

-- Primary Objective
M1P2Title = '<LOC FAF_Coop_Operation_Tight_Spot_M1P2Title>Construct T2 Transport'
M1P2Description = '<LOC FAF_Coop_Operation_Tight_Spot_M1P2Description>QAI is sending a group of Spiderbots to your position, build a transport for your ACU.'

-- Bonus Objective
M1B1Title = '<LOC FAF_Coop_Operation_Tight_Spot_M1B1Title>Artillery Snipe'
M1B1Description = '<LOC FAF_Coop_Operation_Tight_Spot_M1B1Description>You killed QAI\'s Mobile Arilleries before they could endanger your retreat.'

-- Bonus Objective
M1B2Title = '<LOC FAF_Coop_Operation_Tight_Spot_M1B2Title>Prepared for the Worst'
M1B2Description = '<LOC FAF_Coop_Operation_Tight_Spot_M1B2Description>Upgrade your ACU with Tech 2 Engineering, Range Gun or Shield before you board the transport.'

-- Bonus Objective
M1B3Title = '<LOC FAF_Coop_Operation_Tight_Spot_M1B3Title>No Time to Waste'
M1B3Description = '<LOC FAF_Coop_Operation_Tight_Spot_M1B3Description>You finished the T2 Transport before the QAI\'s Spiderbots arrived.'



-------------------------
-- Mission 2 - Crash Site
-------------------------
-- While the ACU is loading in to the tranposrt
M2Intro1 = {
    {
        text = '<LOC FAF_Coop_Operation_Tight_Spot_M2Intro1>[{i HQ}]: It\'s time to get you out of there commander.',
        vid = 'FAF_Coop_Operation_Tight_Spot_M2Intro1.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M2Intro1', faction = 'UEF'
    },
}

-- Player's ACU on the way
M2Intro2 = {
    {
        text = '<LOC FAF_Coop_Operation_Tight_Spot_M2Intro2>[{i HQ}]: Crusader Charis has a Quantum Gate ready for you, her base is 10 klicks west of your position.',
        vid = 'FAF_Coop_Operation_Tight_Spot_M2Intro2.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M2Intro2', faction = 'UEF'
    },
}

-- QAI's ASFs shooting down the transport
M2Intro3 = {
    {
        text = '<LOC FAF_Coop_Operation_Tight_Spot_M2Intro3>[Charis]: Enemy fighters are inbound, you need to drop now!',
        vid = 'Amalia.sfd', vidx = 'FAF_Coop_Operation_Tight_Spot_M2Intro3.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M2Intro3', faction = 'Aeon'
    },
}

-- After emergency drop
M2Intro4 = {
    {
        text = '<LOC FAF_Coop_Operation_Tight_Spot_M2Intro4>[{i HQ}]: Damn it, that\'s too many close calls for one day.',
        vid = 'FAF_Coop_Operation_Tight_Spot_M2Intro4.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M2Intro4', faction = 'UEF'
    },
}

-- Look at other units and CZAR dying
M2Intro5 = {
    {
        text = '<LOC FAF_Coop_Operation_Tight_Spot_M2Intro5_1>[Charis]: QAI\'s air presence it\'s too strong, I am losing my units.',
        vid = 'Amalia.sfd', vidx = 'FAF_Coop_Operation_Tight_Spot_M2Intro5_1.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M2Intro5_1', faction = 'Aeon'
    },
    {
        text = '<LOC FAF_Coop_Operation_Tight_Spot_M2Intro5_2>[{i HQ}]: Commander, secure the area and start building a base, we\'re working on a new plan.',
        vid = 'FAF_Coop_Operation_Tight_Spot_M2Intro5_2.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M2Intro5_2', faction = 'UEF'
    },
}



-- Spawn second player
M2Player2GateIn = {
    {
        text = '<LOC FAF_Coop_Operation_Tight_Spot_M2Player2GateIn>[{i HQ}]: We have a commander volunteering to help you out of this mess, gating in now.',
        vid = 'FAF_Coop_Operation_Tight_Spot_M2Player2GateIn.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M2Player2GateIn', faction = 'UEF'
    },
}

-- Charis flys group of air untis over the map
M2LoyalistSpiderCounter = {
    {
        text = '<LOC FAF_Coop_Operation_Tight_Spot_M2LoyalistSpiderCounter>[Charis]: I\'m sending a squadron of air units to deal with the QAI\'s Spiderbots before they reach your position.',
        vid = 'Amalia.sfd', vidx = 'FAF_Coop_Operation_Tight_Spot_M2LoyalistSpiderCounter.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M2LoyalistSpiderCounter', faction = 'Aeon'
    },
}



-- Bonus objective done, capture engie station
M2EngieStationCaptured = {
    {
        text = '<LOC FAF_Coop_Operation_Tight_Spot_M2EngieStationCaptured>[{i HQ}]: Good thinking commmander, the extra build power of the Engineering Station will come in handy.',
        vid = 'FAF_Coop_Operation_Tight_Spot_M2EngieStationCaptured.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M2EngieStationCaptured', faction = 'UEF'
    },
}

-- Secondary objective to reclaim the CZAR
M2ReclaimCZAR = {
    {
        text = '<LOC FAF_Coop_Operation_Tight_Spot_M2ReclaimCZAR>[{i HQ}]: The wreckage of the crashed CZAR is a great source of mass, make sure to use it to build your base faster. Every second will count commander.',
        vid = 'FAF_Coop_Operation_Tight_Spot_M2ReclaimCZAR.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M2ReclaimCZAR', faction = 'UEF'
    },
}



-- Scenario pick, stay and build the gate or leave to Charis' base
M2PlayersChoice = {
    {
        text = '<LOC FAF_Coop_Operation_Tight_Spot_M2Choice>[{i HQ}]: Alright commander, you have two choices. Either you\'re going to build your own gate to get out of this planet or you can try to push through to get to the Crusader Charis\' base. We don\'t know how many units QAI has between you and Crusader Charis but at the same time QAI can strike at your location any moment. The choice is yours.',
        vid = 'FAF_Coop_Operation_Tight_Spot_M2Choice.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M2Choice', faction = 'UEF'
    },
}

M2ChoiceTitle = '<LOC FAF_Coop_Operation_Tight_Spot_M2ChoiceTitle>Pick your approach:'
M2ChoiceBuildGate = '<LOC FAF_Coop_Operation_Tight_Spot_M2ChoiceBuildGate>Build a Quantum Gate'
M2ChoiceMakeRun = '<LOC FAF_Coop_Operation_Tight_Spot_M2ChoiceMakeRun>Use Charis\' Gate'

-- Reminder player to pick the plan
M2ChoiceReminder = {
    {
        text = '<LOC FAF_Coop_Operation_Tight_Spot_M2ChoiceReminder>[{i HQ}]: How do you want to proceed commander?',
        vid = 'FAF_Coop_Operation_Tight_Spot_M2ChoiceReminder.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M2ChoiceReminder', faction = 'UEF'
    },
}

-- Player took too long to pick
M2ForceChoice = {
    {
        text = '<LOC FAF_Coop_Operation_Tight_Spot_M2ForceChoice>[{i HQ}]: Looks like QAI\'s just decided that for you commander. Crusader Charis\' Quantum Gate is destroyed so you will have to build your own.',
        vid = 'FAF_Coop_Operation_Tight_Spot_M2ForceChoice.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M2ForceChoice', faction = 'UEF'
    },
}

-- Player picks to build the gate
M2BuildGate = {
    {
        text = '<LOC FAF_Coop_Operation_Tight_Spot_M2BuildGate_1>[{i HQ}]: Confirming the new plan to construct a Quantum Gate commander. Crusader Charis will stay on the planet and support you as she\'s able until you\'re ready to leave.',
        vid = 'FAF_Coop_Operation_Tight_Spot_M2BuildGate_1.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M2BuildGate_1', faction = 'UEF'
    },
    {
        text = '<LOC FAF_Coop_Operation_Tight_Spot_M2BuildGate_2>[Charis]: Understood.',
        vid = 'Amalia.sfd', vidx = 'FAF_Coop_Operation_Tight_Spot_M2BuildGate_2.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M2BuildGate_2', faction = 'Aeon'
    },
    {
        text = '<LOC FAF_Coop_Operation_Tight_Spot_M2BuildGate_3>[{i HQ}]: Good luck commander, you gonna need it.',
        vid = 'FAF_Coop_Operation_Tight_Spot_M2BuildGate_3.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M2BuildGate_3', faction = 'UEF'
    },
}

-- Player picks to use Charis' gate
M2UseCharisGate = {
    {
        text = '<LOC FAF_Coop_Operation_Tight_Spot_M2UseCharisGate>[{i HQ}]: The new plan is set.',
        vid = 'FAF_Coop_Operation_Tight_Spot_M2UseCharisGate.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M2UseCharisGate', faction = 'UEF'
    },
}



-- Primary Objective
M2P1Title = '<LOC FAF_Coop_Operation_Tight_Spot_M2P1Title>Secure the Crash Site'
M2P1Description = '<LOC FAF_Coop_Operation_Tight_Spot_M2P1Description>Clear the crash site of enemy units in order to set up a new base.'

-- Secondary Objective
M2S1Title = '<LOC FAF_Coop_Operation_Tight_Spot_M2S1Title>Reclaim the CZAR Wreckage'
M2S1Description = '<LOC FAF_Coop_Operation_Tight_Spot_M2S1Description>Use the resources from the crashed CZAR to boost your economy.'

-- Bonus Objective
M2B1Title = '<LOC FAF_Coop_Operation_Tight_Spot_M2B1Title>Extra Support'
M2B1Description = '<LOC FAF_Coop_Operation_Tight_Spot_M2B1Description>Take a higher tech engineer or a Harbinger with your ACU.'

-- Bonus Objective
M2B2Title = '<LOC FAF_Coop_Operation_Tight_Spot_M2B2Title>Enemy Build Power'
M2B2Description = '<LOC FAF_Coop_Operation_Tight_Spot_M2B2Description>You captured QAI\'s Engineering Station.'



--------------------------
-- Mission 3 - Escape Plan
--------------------------
M3BuildIntro1 = {
    {
        text = '<LOC FAF_Coop_Operation_Tight_Spot_M3BuildIntro1>[{i HQ}]: The scans show that the QAI is constructing bases everywhere around your position.',
        vid = 'FAF_Coop_Operation_Tight_Spot_M3BuildIntro1.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M3BuildIntro1', faction = 'UEF'
    },
}

M3BuildIntro2 = {
    {
        text = '<LOC FAF_Coop_Operation_Tight_Spot_M3BuildIntro2>[{i HQ}]: There won\'t be any room for mistakes commander. Construct the Quantum Gate and get off the planet before the QAI can launch any major attack.',
        vid = 'FAF_Coop_Operation_Tight_Spot_M3BuildIntro2.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M3BuildIntro2', faction = 'UEF'
    },
}



-- Post intro dialogue
M3PostIntro = {
    {
        text = '<LOC FAF_Coop_Operation_Tight_Spot_M3PostIntro>[Charis]: Ugh ... my base is under QAI\'s attack but I will try to send you more units as soon as I can.',
        vid = 'Amalia.sfd', vidx = 'FAF_Coop_Operation_Tight_Spot_M3PostIntro.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M3PostIntro', faction = 'Aeon'
    },
}



-- Gate is built
M3GateBuilt = {
    {
        text = '<LOC FAF_Coop_Operation_Tight_Spot_M3GateBuilt>[{i HQ}]: The Quantum Gate is online and charging, it\'s going to take few minutes before it\' ready. You must defend it commander.',
        vid = 'FAF_Coop_Operation_Tight_Spot_M3GateBuilt.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M3GateBuilt', faction = 'UEF'
    },
}

-- Gate is charged
M3GateCharged = {
    {
        text = '<LOC FAF_Coop_Operation_Tight_Spot_M3GateCharged>[{i HQ}]: The Quantum Gate is fully charged commander, move your ACU to the gate.',
        vid = 'FAF_Coop_Operation_Tight_Spot_M3GateCharged.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M3GateCharged', faction = 'UEF'
    },
}

-- Gate dies
M2GateKilled1 = {
    {
        text = '<LOC FAF_Coop_Operation_Tight_Spot_M2GateKilled1>[{i HQ}]: The Quantum Gate has been destroyed, you will another one.',
        vid = 'FAF_Coop_Operation_Tight_Spot_M2GateKilled1.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M2GateKilled1', faction = 'UEF'
    },
}

-- Gate dies
M2GateKilled2 = {
    {
        text = '<LOC FAF_Coop_Operation_Tight_Spot_M2GateKilled2>[{i HQ}]: Ah hell, the Quantum Gate is down, build a new one commander.',
        vid = 'FAF_Coop_Operation_Tight_Spot_M2GateKilled2.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M2GateKilled2', faction = 'UEF'
    },
}



-- Secondary objective, capture science buildings
M3CaptureScienceFacility = {
    {
        text = '<LOC FAF_Coop_Operation_Tight_Spot_M3CaptureScienceFacility>[{i HQ}]: Commander, a small research facility has been detected near your current position. Your top priority remains to get off the planet but try to capture it if you\'ll see an opening.',
        vid = 'FAF_Coop_Operation_Tight_Spot_M3CaptureScienceFacility.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M3CaptureScienceFacility', faction = 'UEF'
    },
}

-- Buildings captured
M3ScienceFacilityCaptured = {
    {
        text = '<LOC FAF_Coop_Operation_Tight_Spot_M3ScienceFacilityCaptured_1>[{i HQ}]: Well done! The datas being transfered. It\'ll take some time to decrypt them but hopefully we\'ll find something that would help us against QAI.',
        vid = 'FAF_Coop_Operation_Tight_Spot_M3ScienceFacilityCaptured_1.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M3ScienceFacilityCaptured_1', faction = 'UEF'
    },
    {
        text = '<LOC FAF_Coop_Operation_Tight_Spot_M3ScienceFacilityCaptured_2>[{i QAI}]: You are too late, everything of importance has been deleted a long time ago.',
        vid = 'QAI.sfd', vidx = 'FAF_Coop_Operation_Tight_Spot_M3ScienceFacilityCaptured_2.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M3ScienceFacilityCaptured_2', faction = 'Cybran'
    },
}

-- Buildings died
M3ScienceFacilityDead = {
    {
        text = '<LOC FAF_Coop_Operation_Tight_Spot_M3ScienceFacilityDead>[{i HQ}]: Damn it, the QAI\'s research facility has been destroyed, carry on with your escape plan commander.',
        vid = 'FAF_Coop_Operation_Tight_Spot_M3ScienceFacilityDead.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M3ScienceFacilityDead', faction = 'UEF'
    },
}



-- Primary Objective
M3P1Title = '<LOC FAF_Coop_Operation_Tight_Spot_M3P1Title>Build a Quantum Gate'
M3P1Description = '<LOC FAF_Coop_Operation_Tight_Spot_M3P1Description>You will need to build a Quantum Gate to escape from this planet. Build it on a safe location because it\'ll require some time to charge.'

-- Primary Objective
M3P2Title = '<LOC FAF_Coop_Operation_Tight_Spot_M3P2Title>Protect the gate until it\'s charged'
M3P2Description = '<LOC FAF_Coop_Operation_Tight_Spot_M3P2Description>The Quantum Gate needs to accumulate enough energy to be able to teleport you from the planet.'

-- Primary Objective
M3P3Title = '<LOC FAF_Coop_Operation_Tight_Spot_M3P3Title>Leave the planet'
M3P3Description = '<LOC FAF_Coop_Operation_Tight_Spot_M3P3Description>The Quantum Gate is fully charged up, move your ACU to the gate.'

-- Secondary Objective
M3S1Title = '<LOC FAF_Coop_Operation_Tight_Spot_M3S1Title>Capture QAI\'s science facilities'
M3S1Description = '<LOC FAF_Coop_Operation_Tight_Spot_M3S1Description>There\'s a couple of research stations near your current location. They could contain some useful information about QAI\'s activities, try to capture them if you can.'



NewDialogue = {
    {
        text = '<LOC FAF_Coop_Operation_Tight_Spot_NewDialogue>[Charis]: It was a mistake coming to this planet.',
        vid = 'FAF_Coop_Operation_Tight_Spot_NewDialogue.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'NewDialogue', faction = 'Aeon'
    },
}

NewDialogue = {
    {
        text = '<LOC FAF_Coop_Operation_Tight_Spot_NewDialogue>[{i HQ}]: It was a mistake coming to this planet.',
        vid = 'FAF_Coop_Operation_Tight_Spot_NewDialogue.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'NewDialogue', faction = 'UEF'
    },
}



---------
-- Taunts
---------
TAUNT1 = {
    {
        text = '<LOC X05_T01_010_010>[{i QAI}]: Another Commander will not make a difference. You will never defeat me.',
        vid = 'X05_QAI_T01_04415.sfd', bank = 'X05_VO', cue = 'X05_QAI_T01_04415', faction = 'Cybran'
    },
}