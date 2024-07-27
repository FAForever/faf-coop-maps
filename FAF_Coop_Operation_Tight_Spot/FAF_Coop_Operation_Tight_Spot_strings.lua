OPERATION_NAME = 'Operation Tight Spot'
OPERATION_DESCRIPTION = "Coallition scouting mission in the QAI's controlled teritory that went wrong. Fight the QAI's forces to survive and escape from the planet."



-------------
-- Debriefing
-------------
-- Showed on the score screen if player wins
Debriefing_Win = {
    {
        text = "<LOC FAF_Coop_Operation_Tight_Spot_Debriefing_Win>[{i HQ}]: That was a major success commander. Thanks to your efforts we have intel on QAI's plans in the sector.",
        faction = 'UEF'
    },
}

-- Showed on the score screen if player loses
Debriefing_Lose = {
    {
        text = "<LOC FAF_Coop_Operation_Tight_Spot_Debriefing_Lose>[{i HQ}]: The mission was a total failure. QAI has managed to detect out commanders much sooner than we anticipated. We haven't managed to gather any intel and we lost 2 out of 5 deployed commanders.",
        faction = 'UEF'
    },
}



-------------
-- Win / Lose
-------------
-- Player dies
PlayerDies = {
    {
        text = "<LOC FAF_Coop_Operation_Tight_Spot_PlayerDies>[{i HQ}]: Commander, come in! Damn it, we've lost her.",
        vid = 'FAF_Coop_Operation_Tight_Spot_PlayerDies.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'PlayerDies', faction = 'UEF'
    },
}

-- Final dialogue after Charis dies
PlayerLose = {
    {
        text = "<LOC FAF_Coop_Operation_Tight_Spot_PlayerLose>[{i HQ}]: Without Charis' gate, there's nothing else we can do for you commander.",
        vid = 'FAF_Coop_Operation_Tight_Spot_PlayerLose.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'PlayerLose', faction = 'UEF'
    },
}

PlayerWin_push = {
    {
        text = "<LOC FAF_Coop_Operation_Tight_Spot_PlayerWin_push>[{i HQ}]: That was hell of a run commander, we're glad you made it!",
        vid = 'FAF_Coop_Operation_Tight_Spot_PlayerWin_push.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'PlayerWin_push', faction = 'UEF'
    },
}

PlayerWin_build = {
    {
        text = "<LOC FAF_Coop_Operation_Tight_Spot_PlayerWin_build>[{i HQ}]: That was hell of a battle commander, we're glad you made it!",
        vid = 'FAF_Coop_Operation_Tight_Spot_PlayerWin_build.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'PlayerWin_build', faction = 'UEF'
    },
}



-------------------------
-- Mission 1 - Evacuation
-------------------------
-- Intro dialogue
M1Intro = {
    {
        text = "<LOC FAF_Coop_Operation_Tight_Spot_M1Intro_1>[Charis]: Sister, my reinforcements are on the way and will arrive shortly. Defend your position.",
        vid = 'Amalia.sfd', vidx = 'FAF_Coop_Operation_Tight_Spot_M1Intro_1.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M1Intro_1', faction = 'Aeon'
    },
    {
        text = "<LOC FAF_Coop_Operation_Tight_Spot_M1Intro_2>[{i QAI}]: It was a mistake coming to this planet.",
        vid = 'QAI.sfd', vidx = 'FAF_Coop_Operation_Tight_Spot_M1Intro_2.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M1Intro_2', faction = 'Cybran'
    },
}



-- Objective to build transport
M1SpiderBotWarning = {
    {
        text = "<LOC FAF_Coop_Operation_Tight_Spot_M1SpiderBotWarning>[{i HQ}]: Commander, we're picking up a group of land experimentals approaching from the east. Charis' reinforcements won't be enough to stop them so you will have to abandon your position. Build an air transport ASAP and prepare for an evac.",
        vid = 'FAF_Coop_Operation_Tight_Spot_M1SpiderBotWarning.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M1SpiderBotWarning', faction = 'UEF'
    },
}



-- Reminder to keep ACU in the base area
M1ACUInBaseReminder1 = {
    {
        text = "<LOC FAF_Coop_Operation_Tight_Spot_M1ACUInBaseReminder1>[{i HQ}]: Commander, you need to stay in your base until the reinforcements arrive.",
        vid = 'FAF_Coop_Operation_Tight_Spot_M1ACUInBaseReminder1.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M1ACUInBaseReminder1', faction = 'UEF'
    },
}

-- Reminder to keep ACU in the base area
M1ACUInBaseReminder2 = {
    {
        text = "<LOC FAF_Coop_Operation_Tight_Spot_M1ACUInBaseReminder2>[{i HQ}]: Return to your base commander, you won't be able to stop those experimentals with your ACU.",
        vid = 'FAF_Coop_Operation_Tight_Spot_M1ACUInBaseReminder2.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M1ACUInBaseReminder2', faction = 'UEF'
    },
}

-- Reminder to keep ACU in the base area
M1ACUInBaseReminder3 = {
    {
        text = "<LOC FAF_Coop_Operation_Tight_Spot_M1ACUInBaseReminder3>[Charis]: Sister I will not be able to cover you if you leave your base. Please return.",
        vid = 'Amalia.sfd', vidx = 'FAF_Coop_Operation_Tight_Spot_M1ACUInBaseReminder3.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M1ACUInBaseReminder3', faction = 'Aeon'
    },
}



-- MLs on the map, player has a transport
M1SpiderBotsSpotted1 = {
    {
        text = "<LOC FAF_Coop_Operation_Tight_Spot_M1SpiderBotsSpotted1_1>[{i HQ}]: Here they come, it's gonna be close.",
        vid = 'FAF_Coop_Operation_Tight_Spot_M1SpiderBotsSpotted1_1.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M1SpiderBotsSpotted1_1', faction = 'UEF'
    },
    {
        text = "<LOC FAF_Coop_Operation_Tight_Spot_M1SpiderBotsSpotted1_2>[{i QAI}]: You can not escape.",
        vid = 'QAI.sfd', vidx = 'FAF_Coop_Operation_Tight_Spot_M1SpiderBotsSpotted1_2.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M1SpiderBotsSpotted1_2', faction = 'Cybran'
    },
}

-- MLs on the map, player doesn't have a transport
M1SpiderBotsSpotted2 = {
    {
        text = "<LOC FAF_Coop_Operation_Tight_Spot_M1SpiderBotsSpotted2>[{i HQ}]: There they are commander, you need that transport right now!",
        vid = 'FAF_Coop_Operation_Tight_Spot_M1SpiderBotsSpotted2.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M1SpiderBotsSpotted2', faction = 'UEF'
    },
}

-- Loyalist forces arrive
M1ReinforcementsArrived = {
    {
        text = "<LOC FAF_Coop_Operation_Tight_Spot_M1ReinforcementsArrived>[Charis]: We must hurry, my units will cover your retreat.",
        vid = 'Amalia.sfd', vidx = 'FAF_Coop_Operation_Tight_Spot_M1ReinforcementsArrived.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M1ReinforcementsArrived', faction = 'Aeon'
    },
}

-- CZAR Dies
M1ReinforcementsDestroyed = {
    {
        text = "<LOC FAF_Coop_Operation_Tight_Spot_M1ReinforcementsDestroyed>[Charis]: No! Forgive me sister, I've failed you.",
        vid = 'Amalia.sfd', vidx = 'FAF_Coop_Operation_Tight_Spot_M1ReinforcementsDestroyed.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M1ReinforcementsDestroyed', faction = 'Aeon'
    },
}



-- Primary Objective
M1P1Title = "<LOC FAF_Coop_Operation_Tight_Spot_M1P1Title>Survive QAI's Assault"
M1P1Description = "<LOC FAF_Coop_Operation_Tight_Spot_M1P1Description>Crusader Charis' reinforcements will arrive soon. Repeal the attacking units and prepare for an evacuation."

-- Primary Objective
M1P2Title = "<LOC FAF_Coop_Operation_Tight_Spot_M1P2Title>Construct T2 Transport"
M1P2Description = "<LOC FAF_Coop_Operation_Tight_Spot_M1P2Description>QAI is sending a group of Spiderbots to your position, build a transport for your ACU."

-- Bonus Objective
M1B1Title = "<LOC FAF_Coop_Operation_Tight_Spot_M1B1Title>Prepared for the Worst"
M1B1Description = "<LOC FAF_Coop_Operation_Tight_Spot_M1B1Description>Upgrade your ACU with Tech 2 Engineering, Range Gun or Shield before you board the transport."

-- Bonus Objective
M1B2Title = "<LOC FAF_Coop_Operation_Tight_Spot_M1B2Title>No Time to Waste"
M1B2Description = "<LOC FAF_Coop_Operation_Tight_Spot_M1B2Description>You finished the T2 Transport before the QAI's Spiderbots arrived."



-------------------------
-- Mission 2 - Crash Site
-------------------------
-- While the ACU is loading in to the tranposrt
M2Intro1 = {
    {
        text = "<LOC FAF_Coop_Operation_Tight_Spot_M2Intro1>[{i HQ}]: It's time to get you out of there commander.",
        vid = 'FAF_Coop_Operation_Tight_Spot_M2Intro1.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M2Intro1', faction = 'UEF'
    },
}

-- Player's ACU on the way
M2Intro2 = {
    {
        text = "<LOC FAF_Coop_Operation_Tight_Spot_M2Intro2>[{i HQ}]: Crusader Charis has a Quantum Gate ready for you, her base is 10 klicks west of your position.",
        vid = 'FAF_Coop_Operation_Tight_Spot_M2Intro2.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M2Intro2', faction = 'UEF'
    },
}

-- QAI's ASFs shooting down the transport
M2Intro3 = {
    {
        text = "<LOC FAF_Coop_Operation_Tight_Spot_M2Intro3>[Charis]: Enemy fighters are inbound, you need to land now!",
        vid = 'Amalia.sfd', vidx = 'FAF_Coop_Operation_Tight_Spot_M2Intro3.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M2Intro3', faction = 'Aeon'
    },
}

-- After emergency drop
M2Intro4 = {
    {
        text = "<LOC FAF_Coop_Operation_Tight_Spot_M2Intro4>[{i HQ}]: Damn it, that's too many close calls for one day.",
        vid = 'FAF_Coop_Operation_Tight_Spot_M2Intro4.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M2Intro4', faction = 'UEF'
    },
}

-- Look at other units and CZAR dying
M2Intro5 = {
    {
        text = "<LOC FAF_Coop_Operation_Tight_Spot_M2Intro5_1>[Charis]: QAI's air presence it's too strong, I am losing my units.",
        vid = 'Amalia.sfd', vidx = 'FAF_Coop_Operation_Tight_Spot_M2Intro5_1.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M2Intro5_1', faction = 'Aeon'
    },
    {
        text = "<LOC FAF_Coop_Operation_Tight_Spot_M2Intro5_2>[{i HQ}]: Commander, secure the area and start building a base, we're working on a new plan.",
        vid = 'FAF_Coop_Operation_Tight_Spot_M2Intro5_2.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M2Intro5_2', faction = 'UEF'
    },
}



-- Spawn second player
M2Player2GateIn = {
    {
        text = "<LOC FAF_Coop_Operation_Tight_Spot_M2Player2GateIn>[{i HQ}]: We have a commander volunteering to help you out of this mess, gating in now.",
        vid = 'FAF_Coop_Operation_Tight_Spot_M2Player2GateIn.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M2Player2GateIn', faction = 'UEF'
    },
}

-- Charis flys group of air untis over the map
M2LoyalistSpiderCounter = {
    {
        text = "<LOC FAF_Coop_Operation_Tight_Spot_M2LoyalistSpiderCounter>[Charis]: I'm sending a squadron of air units to deal with the QAI's Spiderbots before they reach your position.",
        vid = 'Amalia.sfd', vidx = 'FAF_Coop_Operation_Tight_Spot_M2LoyalistSpiderCounter.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M2LoyalistSpiderCounter', faction = 'Aeon'
    },
}



-- Bonus objective done, capture engie station
M2EngieStationCaptured = {
    {
        text = "<LOC FAF_Coop_Operation_Tight_Spot_M2EngieStationCaptured>[{i HQ}]: Good thinking commmander, the extra build power from that Engineering Station will come in handy.",
        vid = 'FAF_Coop_Operation_Tight_Spot_M2EngieStationCaptured.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M2EngieStationCaptured', faction = 'UEF'
    },
}

-- Secondary objective to reclaim the CZAR
M2ReclaimCZAR = {
    {
        text = "<LOC FAF_Coop_Operation_Tight_Spot_M2ReclaimCZAR>[{i HQ}]: The wreckage of the crashed CZAR is a great source of mass, make sure you use it to build your base faster. Every second counts commander.",
        vid = 'FAF_Coop_Operation_Tight_Spot_M2ReclaimCZAR.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M2ReclaimCZAR', faction = 'UEF'
    },
}



-- Scenario pick, stay and build the gate or leave to Charis' base
M2PlayersChoice = {
    {
        text = "<LOC FAF_Coop_Operation_Tight_Spot_M2Choice>[{i HQ}]: Alright commander, you have two choices. Either you build your own gate to get out of this planet or you can try and push through to Crusader Charis' base. We don't know how many units QAI has between you and Crusader Charis, but at the same time QAI can strike your location at any moment. The choice is yours.",
        vid = 'FAF_Coop_Operation_Tight_Spot_M2Choice.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M2Choice', faction = 'UEF'
    },
}

M2ChoiceTitle = "<LOC FAF_Coop_Operation_Tight_Spot_M2ChoiceTitle>Choose a new plan:"
M2ChoiceBuildGate = "<LOC FAF_Coop_Operation_Tight_Spot_M2ChoiceBuildGate>Build a Quantum Gate"
M2ChoiceMakeRun = "<LOC FAF_Coop_Operation_Tight_Spot_M2ChoiceMakeRun>Use Charis' Gate"

-- Reminder player to pick the plan
M2ChoiceReminder = {
    {
        text = "<LOC FAF_Coop_Operation_Tight_Spot_M2ChoiceReminder>[{i HQ}]: Well commander, how do you want to proceed?",
        vid = 'FAF_Coop_Operation_Tight_Spot_M2ChoiceReminder.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M2ChoiceReminder', faction = 'UEF'
    },
}

-- Player took too long to pick
M2ForceChoice = {
    {
        text = "<LOC FAF_Coop_Operation_Tight_Spot_M2ForceChoice>[{i HQ}]: Looks like QAI's just decided that for you commander. Crusader Charis' Quantum Gate is destroyed so you will have to build your own.",
        vid = 'FAF_Coop_Operation_Tight_Spot_M2ForceChoice.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M2ForceChoice', faction = 'UEF'
    },
}

-- Player picks to build the gate
M2BuildGate = {
    {
        text = "<LOC FAF_Coop_Operation_Tight_Spot_M2BuildGate_1>[{i HQ}]: Confirming the new plan to construct a Quantum Gate. Crusader Charis will stay on planet to support you as long as she's able, and until you're ready to leave.",
        vid = 'FAF_Coop_Operation_Tight_Spot_M2BuildGate_1.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M2BuildGate_1', faction = 'UEF'
    },
    {
        text = "<LOC FAF_Coop_Operation_Tight_Spot_M2BuildGate_2>[Charis]: Understood.",
        vid = 'Amalia.sfd', vidx = 'FAF_Coop_Operation_Tight_Spot_M2BuildGate_2.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M2BuildGate_2', faction = 'Aeon'
    },
}

-- Player picks to use Charis' gate
M2UseCharisGate = {
    {
        text = "<LOC FAF_Coop_Operation_Tight_Spot_M2UseCharisGate>[{i HQ}]: Confirming the new plan, you'll move to crusader Charis' position and use her gate.",
        vid = 'FAF_Coop_Operation_Tight_Spot_M2UseCharisGate.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M2UseCharisGate', faction = 'UEF'
    },
}



-- Primary Objective
M2P1Title = "<LOC FAF_Coop_Operation_Tight_Spot_M2P1Title>Secure the Crash Site"
M2P1Description = "<LOC FAF_Coop_Operation_Tight_Spot_M2P1Description>Clear the crash site of enemy units and set up a new base."

-- Secondary Objective
M2S1Title = "<LOC FAF_Coop_Operation_Tight_Spot_M2S1Title>Reclaim the CZAR Wreckage"
M2S1Description = "<LOC FAF_Coop_Operation_Tight_Spot_M2S1Description>Use the resources from the crashed CZAR to boost your economy."

-- Bonus Objective
M2B1Title = "<LOC FAF_Coop_Operation_Tight_Spot_M2B1Title>Enemy Build Power"
M2B1Description = "<LOC FAF_Coop_Operation_Tight_Spot_M2B1Description>You captured QAI's Engineering Station at the crash site."



--------------------------
-- Mission 3 - Escape Plan
--------------------------

--------------------
-- Build gate option
--------------------
-- Intro dialogue for building gate.
M3BuildIntro1 = {
    {
        text = "<LOC FAF_Coop_Operation_Tight_Spot_M3BuildIntro1>[{i HQ}]: The scans show QAI is constructing bases everywhere around your position.",
        vid = 'FAF_Coop_Operation_Tight_Spot_M3BuildIntro1.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M3BuildIntro1', faction = 'UEF'
    },
}

-- Intro dialogue for building gate.
M3BuildIntro2 = {
    {
        text = "<LOC FAF_Coop_Operation_Tight_Spot_M3BuildIntro2>[{i HQ}]: There won't be any room for mistakes here commander. Dig in, construct the Quantum Gate and get off planet before QAI can launch a major offensive.",
        vid = 'FAF_Coop_Operation_Tight_Spot_M3BuildIntro2.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M3BuildIntro2', faction = 'UEF'
    },
    {
        text = "<LOC FAF_Coop_Operation_Tight_Spot_M3BuildIntro3>[{i HQ}]: Keep in mind the Quantum Gate will need some time to charge once it's build, so build it sooner rather than later. Good luck commander, you gonna need it.",
        vid = 'FAF_Coop_Operation_Tight_Spot_M3BuildIntro3.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M3BuildIntro3', faction = 'UEF'
    },
}



-- Post intro dialogue
M3PostIntroBuild = {
    {
        text = "<LOC FAF_Coop_Operation_Tight_Spot_M3PostIntroBuild>[Charis]: Ugh ... my base is under QAI's attack but I will try to send you more reinforcements as soon as I can.",
        vid = 'Amalia.sfd', vidx = 'FAF_Coop_Operation_Tight_Spot_M3PostIntroBuild.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M3PostIntroBuild', faction = 'Aeon'
    },
}



-- Reminder to build the gate
M3BuildGateReminder1 = {
    {
        text = "<LOC FAF_Coop_Operation_Tight_Spot_M3BuildGateReminder1>[{i HQ}]: You need to build the Quantum Gate commander. There's no other way off the planet.",
        vid = 'FAF_Coop_Operation_Tight_Spot_M3BuildGateReminder1.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M3BuildGateReminder1', faction = 'UEF'
    },
}

-- Reminder to build the gate
M3BuildGateReminder2 = {
    {
        text = "<LOC FAF_Coop_Operation_Tight_Spot_M3BuildGateReminder2>[{i HQ}]: Commander, get the Quantum Gate online ASAP. QAI is moving more units towards your position.",
        vid = 'FAF_Coop_Operation_Tight_Spot_M3BuildGateReminder2.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M3BuildGateReminder2', faction = 'UEF'
    },
}



-- Gate is built
M3GateBuilt = {
    {
        text = "<LOC FAF_Coop_Operation_Tight_Spot_M3GateBuilt>[{i HQ}]: The Quantum Gate is online and charging. It's gonna take few minutes before it's ready. You must defend it commander.",
        vid = 'FAF_Coop_Operation_Tight_Spot_M3GateBuilt.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M3GateBuilt', faction = 'UEF'
    },
}

-- Gate dies, no other gate built.
M3GateKilled1 = {
    {
        text = "<LOC FAF_Coop_Operation_Tight_Spot_M3GateKilled1>[{i HQ}]: The Quantum Gate has been destroyed, you'll need to build another one.",
        vid = 'FAF_Coop_Operation_Tight_Spot_M3GateKilled1.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M3GateKilled1', faction = 'UEF'
    },
}

-- Gate dies, no other gate built.
M3GateKilled2 = {
    {
        text = "<LOC FAF_Coop_Operation_Tight_Spot_M3GateKilled2>[{i HQ}]: Ah hell, the Quantum Gate is down, build a new one commander.",
        vid = 'FAF_Coop_Operation_Tight_Spot_M3GateKilled2.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M3GateKilled2', faction = 'UEF'
    },
}

-- Gate dies, but there is another one charging already
M3GateKilled3 = {
    {
        text = "<LOC FAF_Coop_Operation_Tight_Spot_M3GateKilled3>[{i HQ}]: The first Quantum Gate has been destroyed, but the backup will finish charging soon, make sure it survives.",
        vid = 'FAF_Coop_Operation_Tight_Spot_M3GateKilled3.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M3GateKilled3', faction = 'UEF'
    },
}

-- Gate dies, but there is another one charging already
M3GateKilled4 = {
    {
        text = "<LOC FAF_Coop_Operation_Tight_Spot_M3GateKilled4>[{i HQ}]: Ah hell, you lost the gate! Just make sure you defend the backup, it will be charged shortly.",
        vid = 'FAF_Coop_Operation_Tight_Spot_M3GateKilled4.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M3GateKilled4', faction = 'UEF'
    },
}

-- Gate dies, but there's another one already charged.
M3GateKilled5 = {
    {
        text = "<LOC FAF_Coop_Operation_Tight_Spot_M3GateKilled5>[{i HQ}]: The Quantum Gate has been destroyed, but you have another that is also charged. Use that one instead.",
        vid = 'FAF_Coop_Operation_Tight_Spot_M3GateKilled5.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M3GateKilled5', faction = 'UEF'
    },
}

-- Gate is charged 25%
M3GateChargin25 = {
    {
        text = "<LOC FAF_Coop_Operation_Tight_Spot_M3GateCharging25>[{i HQ}]: The Quantum Gate is 25% charged.",
        vid = 'FAF_Coop_Operation_Tight_Spot_M3GateCharging25.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M3GateCharging25', faction = 'UEF'
    },
}

-- Gate is charged 50%
M3GateCharging50 = {
    {
        text = "<LOC FAF_Coop_Operation_Tight_Spot_M3GateCharging50>[{i HQ}]: The Quantum Gate charge is at 50%, you're half way there commander.",
        vid = 'FAF_Coop_Operation_Tight_Spot_M3GateCharging50.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M3GateCharging50', faction = 'UEF'
    },
}

-- Gate is charged 75%
M3GateCharging75 = {
    {
        text = "<LOC FAF_Coop_Operation_Tight_Spot_M3GateCharging75>[{i HQ}]: 75% charged, almost there commander, hold on just for a little longer.",
        vid = 'FAF_Coop_Operation_Tight_Spot_M3GateCharging75.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M3GateCharging75', faction = 'UEF'
    },
}

-- Gate is charged
M3GateCharged = {
    {
        text = "<LOC FAF_Coop_Operation_Tight_Spot_M3GateCharged>[{i HQ}]: The Quantum Gate is now fully charged commander, move your ACU to the gate.",
        vid = 'FAF_Coop_Operation_Tight_Spot_M3GateCharged.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M3GateCharged', faction = 'UEF'
    },
}



-- Cinematics start, ACU's are entering the gate and gating out.
M3PlayerAtGate_build = {
    {
        text = "<LOC FAF_Coop_Operation_Tight_Spot_M3PlayerAtGate_build_1>[{i HQ}]: Come on home commander, we're waiting for you.",
        vid = 'FAF_Coop_Operation_Tight_Spot_M3PlayerAtGate_build_1.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M3PlayerAtGate_build1', faction = 'UEF' -- intentional typo in cue name, should be "build_1" needs rebuilding soundbank
    },
    {
        text = "<LOC FAF_Coop_Operation_Tight_Spot_M3PlayerAtGate_build_2>[Charis]: That was an impressive battle sister, I will see you on the other side.",
        vid = 'Amalia.sfd', vidx = 'FAF_Coop_Operation_Tight_Spot_M3PlayerAtGate_build_2.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M3PlayerAtGate_build_2', faction = 'Aeon'
    },
}



-------------
-- Run option
-------------
-- Cam at defensive line
M3RunIntro1 = {
    {
        text = "<LOC FAF_Coop_Operation_Tight_Spot_M3RunIntro1>[{i HQ}]: Alright commander, this walk isn't gonna be easy, there's QAI's defensive line between you and crusader Charis.",
        vid = 'FAF_Coop_Operation_Tight_Spot_M3RunIntro1.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M3RunIntro1', faction = 'UEF'
    },
}

-- Cam at QAI's base
M3RunIntro2 = {
    {
        text = "<LOC FAF_Coop_Operation_Tight_Spot_M3RunIntro2>[{i HQ}]: One of QAI's bases is right next to it, so expect heavy resistance.",
        vid = 'FAF_Coop_Operation_Tight_Spot_M3RunIntro2.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M3RunIntro2', faction = 'UEF'
    },
}

-- Cam at Charis' base
M3RunIntro3 = {
    {
        text = "<LOC FAF_Coop_Operation_Tight_Spot_M3RunIntro3>[{i HQ}]: Your destination is to the north west. QAI is already assaulting Charis' base. You need to get there before her base falls.",
        vid = 'FAF_Coop_Operation_Tight_Spot_M3RunIntro3.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M3RunIntro3', faction = 'UEF'
    },
}

-- Cam at the transports
M3RunIntro4 = {
    {
        text = "<LOC M3RunIntro4>[Charis]: I'm sending more reinforcements your way. These were all the units I could spare.",
        vid = 'Amalia.sfd', vidx = 'M3RunIntro4.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M3RunIntro4', faction = 'Aeon'
    },
}

-- Final cam, zoomed out
M3RunIntro5 = {
    {
        text = "<LOC FAF_Coop_Operation_Tight_Spot_M3RunIntro5>[{i HQ}]: Garther as many units as you can and run to the gate. Commander Charis will hold the line for as long as possible. Good luck commander.",
        vid = 'FAF_Coop_Operation_Tight_Spot_M3RunIntro5.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M3RunIntro5', faction = 'UEF'
    },
}



-- Post intro dialogue
M3PostIntroPush = {
    {
        text = "<LOC FAF_Coop_Operation_Tight_Spot_M3PostIntroPush_1>[{i HQ}]: QAI has a significant ASF force in the area. It's gonna be a nightmare to keep track of them due to their Stealth ability. We don't recommend trying to move units by transports as they would be an easy prey. Also make sure to have enough Anti-Air units near your ACU. HQ out.",
        vid = 'FAF_Coop_Operation_Tight_Spot_M3PostIntroPush_1.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M3PostIntroPush_1', faction = 'UEF'
    },
    {
        text = "<LOC FAF_Coop_Operation_Tight_Spot_M3PostIntroPush_2>[Charis]: Secure your area and build up as many units as you can. Once you're ready we will assault QAI's base from both sides.",
        vid = 'Amalia.sfd', vidx = 'FAF_Coop_Operation_Tight_Spot_M3PostIntroPush_2.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M3PostIntroPush_2', faction = 'Aeon'
    },
}



-- Objective done, player is near the gate
M3PlayerAtGate_push = {
    {
        text = "<LOC FAF_Coop_Operation_Tight_Spot_M3PlayerAtGate_push>[Charis]: Go straight for the gate. I will leave right after you.",
        vid = 'Amalia.sfd', vidx = 'FAF_Coop_Operation_Tight_Spot_M3PlayerAtGate_push.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M3PlayerAtGate_push', faction = 'Aeon'
    },
}



-- Secondary objective to kill QAI
M3QAISpotted = {
    {
        text = "<LOC FAF_Coop_Operation_Tight_Spot_M3QAISpotted>[{i HQ}]: One of the QAI ACUs is at the base between you and crusader Charis. Looks like you'll have to go through it. If you get the chance, teach that bloated bag of silicone a lesson.",
        vid = 'FAF_Coop_Operation_Tight_Spot_M3QAISpotted.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M3QAISpotted', faction = 'UEF'
    },
}

-- QAI's ACU is defeated
M3QAIDefeated = {
    {
        text = "<LOC X02_T01_290_010>[{i QAI}]: This is just a shell...",
        vid = 'X02_QAI_T01_04565.sfd', bank = 'X02_VO', cue = 'X02_QAI_T01_04565', faction = 'Cybran'
    },
    {
        text = "<LOC FAF_Coop_Operation_Tight_Spot_M3QAIDefeated>[{i HQ}]: Well done commander, now get your ass to the gate!",
        vid = 'FAF_Coop_Operation_Tight_Spot_M3QAIDefeated.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M3QAIDefeated', faction = 'UEF'
    },
}



-- When Charis have enough units to start the attack
M3CharisReadyToAttack = {
    {
        text = "<LOC FAF_Coop_Operation_Tight_Spot_M3CharisReadyToAttack>[Charis]: Sister, I have enough units to assault QAI to help you clear the path to my base. Once you are ready, select the attack ping and set the target anywhere inside QAI's main base.",
        vid = 'Amalia.sfd', vidx = 'FAF_Coop_Operation_Tight_Spot_M3CharisReadyToAttack.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M3CharisReadyToAttack', faction = 'Aeon'
    },
}

-- When player selects a new target.
M3NewTargetSet1 = {
    {
        text = "<LOC FAF_Coop_Operation_Tight_Spot_M3NewTargetSet1>[Charis]: My units are on the way.",
        vid = 'Amalia.sfd', vidx = 'FAF_Coop_Operation_Tight_Spot_M3NewTargetSet1.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M3NewTargetSet1', faction = 'Aeon'
    },
}

-- When player selects a new target.
M3NewTargetSet2 = {
    {
        text = "<LOC FAF_Coop_Operation_Tight_Spot_M3NewTargetSet2>[Charis]: Sending my units to the new target.",
        vid = 'Amalia.sfd', vidx = 'FAF_Coop_Operation_Tight_Spot_M3NewTargetSet2.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M3NewTargetSet2', faction = 'Aeon'
    },
}

-- When player clicks off QAI base are.
M3InvalidTarget = {
    {
        text = "<LOC FAF_Coop_Operation_Tight_Spot_M3InvalidTarget>[Charis]: We must focus on QAI's main base. Select any target in the base.",
        vid = 'Amalia.sfd', vidx = 'FAF_Coop_Operation_Tight_Spot_M3InvalidTarget.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M3InvalidTarget', faction = 'Aeon'
    },
}

-- Reminder to start the attack
M3CharisReadyReminder1 = {
    {
        text = "<LOC FAF_Coop_Operation_Tight_Spot_M3CharisReadyReminder1>[{i HQ}]: Commander Charis is waiting for your order to start her assault.",
        vid = 'FAF_Coop_Operation_Tight_Spot_M3CharisReadyReminder1.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M3CharisReadyReminder1', faction = 'UEF'
    },
}

-- Reminder to start the attack
M3CharisReadyReminder2 = {
    {
        text = "<LOC FAF_Coop_Operation_Tight_Spot_M3CharisReadyReminder2>[Charis]: My forces are ready to attack, we should not wait any longer.",
        vid = 'Amalia.sfd', vidx = 'FAF_Coop_Operation_Tight_Spot_M3CharisReadyReminder2.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M3CharisReadyReminder2', faction = 'Aeon'
    },
}

-- Reminder to start the attack
M3CharisReadyReminder3 = {
    {
        text = "<LOC FAF_Coop_Operation_Tight_Spot_M3CharisReadyReminder3>[{i HQ}]: You don't have much time left commander. QAI is all over the place. Launch the attack ASAP!",
        vid = 'FAF_Coop_Operation_Tight_Spot_M3CharisReadyReminder3.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M3CharisReadyReminder3', faction = 'UEF'
    },
}

-- Start the attack
M3CharisAttackStart = {
    {
        text = "<LOC FAF_Coop_Operation_Tight_Spot_M3CharisAttackStart_1>[Charis]: We're running out of time, I'm launching the assault. Join me in the fight sister!",
        vid = 'Amalia.sfd', vidx = 'FAF_Coop_Operation_Tight_Spot_M3CharisAttackStart_1.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M3CharisAttackStart_1', faction = 'Aeon'
    },
    {
        text = "<LOC FAF_Coop_Operation_Tight_Spot_M3CharisAttackStart_2>[{i HQ}]: QAI's activity in the sector is rising commander. Join the assault on QAI's main base and get to the gate.",
        vid = 'FAF_Coop_Operation_Tight_Spot_M3CharisAttackStart_2.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M3CharisAttackStart_2', faction = 'UEF'
    },
}



-- Charis is defeated
M3CharisDies = {
    {
        text = "<LOC FAF_Coop_Operation_Tight_Spot_M3CharisDies>[Charis]: There's too many of them! ...",
        vid = 'Amalia.sfd', vidx = 'FAF_Coop_Operation_Tight_Spot_M3CharisDies.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M3CharisDies', faction = 'Aeon'
    },
}



-- Final attack to kill player if they take too long and are still in the base.
M3GameEnderDialogue1 = {
    {
        text = "<LOC FAF_Coop_Operation_Tight_Spot_M3GameEnderDialogue_1>[{i HQ}]: Commander, we're detecting several experimental units moving to your location from south east. You need to get out of there now!",
        vid = 'FAF_Coop_Operation_Tight_Spot_M3GameEnderDialogue_1.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M3GameEnderDialogue_1', faction = 'UEF'
    },
    {
        text = "<LOC FAF_Coop_Operation_Tight_Spot_M3GameEnderDialogue_3>[{i QAI}]: You will die on this planet and the coallition will soon follow. There is no stopping us.",
        vid = 'X05_QAI_T01_04415.sfd', vidx = 'FAF_Coop_Operation_Tight_Spot_M3GameEnderDialogue_3.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M3GameEnderDialogue_3', faction = 'Cybran'
    },
}

-- Final attack to kill player if they take too long, player already left base
M3GameEnderDialogue2 = {
    {
        text = "<LOC FAF_Coop_Operation_Tight_Spot_M3GameEnderDialogue_2>[{i HQ}]: Commander, we're detecting several experimental units moving in from south east. Time to pick up the pace!",
        vid = 'FAF_Coop_Operation_Tight_Spot_M3GameEnderDialogue_2.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M3GameEnderDialogue_2', faction = 'UEF'
    },
    {
        text = "<LOC FAF_Coop_Operation_Tight_Spot_M3GameEnderDialogue_3>[{i QAI}]: You will die on this planet and the coallition will soon follow. There is no stopping us.",
        vid = 'X05_QAI_T01_04415.sfd', vidx = 'FAF_Coop_Operation_Tight_Spot_M3GameEnderDialogue_3.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M3GameEnderDialogue_3', faction = 'Cybran'
    },
}



-- Secondary objective, capture science buildings
M3CaptureScienceFacility = {
    {
        text = "<LOC FAF_Coop_Operation_Tight_Spot_M3CaptureScienceFacility>[{i HQ}]: Commander, a small research facility has been detected near your current position. Your top priority remains to get off planet, but if you see an opportunity ... try to capture it.",
        vid = 'FAF_Coop_Operation_Tight_Spot_M3CaptureScienceFacility.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M3CaptureScienceFacility', faction = 'UEF'
    },
}

-- Buildings captured
M3ScienceFacilityCaptured = {
    {
        text = "<LOC FAF_Coop_Operation_Tight_Spot_M3ScienceFacilityCaptured_1>[{i HQ}]: Well done! Our technicians are transferring the data. It'll take some time to decrypt them but hopefully we'll find something that will help us against QAI.",
        vid = 'FAF_Coop_Operation_Tight_Spot_M3ScienceFacilityCaptured_1.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M3ScienceFacilityCaptured_1', faction = 'UEF'
    },
    {
        text = "<LOC FAF_Coop_Operation_Tight_Spot_M3ScienceFacilityCaptured_2>[{i QAI}]: You are too late, everything of importance has been deleted a long time ago.",
        vid = 'QAI.sfd', vidx = 'FAF_Coop_Operation_Tight_Spot_M3ScienceFacilityCaptured_2.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M3ScienceFacilityCaptured_2', faction = 'Cybran'
    },
}

-- Buildings died
M3ScienceFacilityDead = {
    {
        text = "<LOC FAF_Coop_Operation_Tight_Spot_M3ScienceFacilityDead>[{i HQ}]: Damn it, QAI's research facility has been destroyed, carry on with your escape plan commander.",
        vid = 'FAF_Coop_Operation_Tight_Spot_M3ScienceFacilityDead.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M3ScienceFacilityDead', faction = 'UEF'
    },
}

-- Show QAI's spiders
M3ExtraIntelPush = {
    {
        text = "<LOC FAF_Coop_Operation_Tight_Spot_M3ExtraIntelPush>[{i HQ}]: The technicians managed to decrypt some of the data and establish a link to QAI's local network. It'll allows us to track some of the experimental units in the area. HQ out.",
        vid = 'FAF_Coop_Operation_Tight_Spot_M3ExtraIntelPush.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'M3ExtralntelPush', faction = 'UEF' -- Cue name has "intentional" typo in "Intel" as "L-ntel", requires rebuilding soundbank 
    },
}


-------------
-- Build Gate
-------------
-- Primary Objective
M3P1_1_Title = "<LOC FAF_Coop_Operation_Tight_Spot_M3P1_1_Title>Build a Quantum Gate"
M3P1_1_Description = "<LOC FAF_Coop_Operation_Tight_Spot_M3P1_1_Description>You have to build your own Quantum Gate to escape from this planet."

-- Primary Objective
M3P2_1_Title = "<LOC FAF_Coop_Operation_Tight_Spot_M3P2_1_Title>Protect the gate until it's charged"
M3P2_1_Description = "<LOC FAF_Coop_Operation_Tight_Spot_M3P2_1_Description>The Quantum Gate needs to accumulate enough energy to be able to teleport you from the planet. Defend it."

-- Primary Objective
M3P3_1_Title = "<LOC FAF_Coop_Operation_Tight_Spot_M3P3_1_Title>Leave the planet"
M3P3_1_Description = "<LOC FAF_Coop_Operation_Tight_Spot_M3P3_1_Description>The Quantum Gate is fully charged, move your ACU to the gate."

--------------
-- Run to Gate
--------------
-- Primary Objective
M3P1_2_Title = "<LOC FAF_Coop_Operation_Tight_Spot_M3P1_2_Title>Escape the planet"
M3P1_2_Description = "<LOC FAF_Coop_Operation_Tight_Spot_M3P1_2_Description>Crusader Charis' gates are fully charged. Fight your way to her base and use her gate to leave the planet."

-- Secondary Objective
M3S2_2_Title = "<LOC FAF_Coop_Operation_Tight_Spot_M3S2_2_Title>Destroy QAI's ACU"
M3S2_2_Description = "<LOC FAF_Coop_Operation_Tight_Spot_M3S2_2_Description>QAI's main base is between you and crusader Charis's gate. If you get the chance, destroy it's ACU."

-- Secondary Objective
M3S1Title = "<LOC FAF_Coop_Operation_Tight_Spot_M3S1Title>Capture QAI's science facilities"
M3S1Description = "<LOC FAF_Coop_Operation_Tight_Spot_M3S1Description>There's a couple of research stations near your current location. They could contain some useful information about QAI's activities, try to capture them."

-- Bonus Objective
M3B1Title = "<LOC FAF_Coop_Operation_Tight_Spot_M3B1Title>Playing is safe"
M3B1Description = "<LOC FAF_Coop_Operation_Tight_Spot_M3B1Description>Your ACU's health didn't drop below 5000."


--------------
-- Attack ping
--------------
M3LoyalistAttackPingTitle = "<LOC M3LoyalistAttackPingTitle>Set target for Charis' forces."
M3LoyalistAttackPingDescription = "<LOC M3LoyalistAttackPingDescription>Crusader Charis has assembled enough forces to launch an offensive on QAI's main base. Select the ping and click into the QAI's main base to set a new target."

M3TargetAreaSet = "<LOC M3TargetAreaSet>New target set!"
M3InvalidAreaSet = "<LOC M3InvalidAreaSet>Invalid position! You must click inside QAI's main base."



--[[
NewDialogueCharis = {
    {
        text = "<LOC FAF_Coop_Operation_Tight_Spot_NewDialogueCharis>[Charis]: It was a mistake coming to this planet.",
        vid = 'Amalia.sfd', vidx = 'FAF_Coop_Operation_Tight_Spot_NewDialogueCharis.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'NewDialogueCharis', faction = 'Aeon'
    },
}

NewDialogueHQ = {
    {
        text = "<LOC FAF_Coop_Operation_Tight_Spot_NewDialogueHQ>[{i HQ}]: It was a mistake coming to this planet.",
        vid = 'FAF_Coop_Operation_Tight_Spot_NewDialogueHQ.sfd', bank = 'FAF_Coop_Operation_Tight_Spot_VO', cue = 'NewDialogueHQ', faction = 'UEF'
    },
}
--]]


---------
-- Taunts
---------
TAUNT1 = {
    {
        text = "<LOC X05_T01_010_010>[{i QAI}]: Another Commander will not make a difference. You will never defeat me.",
        vid = 'X05_QAI_T01_04415.sfd', bank = 'X05_VO', cue = 'X05_QAI_T01_04415', faction = 'Cybran'
    },
}