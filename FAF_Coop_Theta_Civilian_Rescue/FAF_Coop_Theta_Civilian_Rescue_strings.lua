# ----------------------------
# Mission 1
# Rescue Civilians
#-----------------------------
--[<The game starts and you get to see the first base> Explain that Cybrans are the bad guys and some people are kidnapped (civilians or other term possible). And that we expect them to be held in this base]--
M1_West_Base_View = {
  {text = '[UEF]: Commander, several civilians have been kidnapped by the Cybrans. Our scouts were able to trace them back to this base. They\'re preparing for battle, so you\'ll have to fight your way through their defenses.', vid = 'spinUEFBlue_10sec.sfd', bank = 'TCR_VO', cue = '1M1_West_Base_View', faction = 'UEF'},
}

--[<You hover towards a view with the prison and have a good closeup of it> The people are held in the prison and the objective is to capture it.]--
M1_Main_Objective = {
  {text = '[UEF]: We suspect the civilians are being held in this prison. Your main objective is to take control of the prison and free them.', vid = 'spinUEFBlue_6sec.sfd', bank = 'TCR_VO', cue = '2M1_Main_Objective', faction = 'UEF'},
}

--[<Game has started: just commander view> (3+ players only) At the beginning of the view you could see the starting position and incase of 3>= players, there will be some kind of defenses like PD. Fist secondary objective is too destroy these pds so you have room to manouver without getting into PD range.]--
M1_Destroy_Forward_Defenses = {
  {text = '[UEF]:  Destroy the Cybran forward defenses to secure the area.', vid = 'spinUEFBlue_4sec.sfd', bank = 'TCR_VO', cue = '3M1_Destroy_Forward_Defenses', faction = 'UEF'},
}

--[<no view> You killed all the pds and other buildings in the forward defensive positions. Give player some feedback about this.]--
M1_Forward_Defenses_Destroyed = {
  {text = '[UEF]: You\'ve succesfully destroyed the Cybran forward defenses.', vid = 'spinUEFBlue_4sec.sfd', bank = 'TCR_VO', cue = '4M1_Forward_Defenses_Destroyed', faction = 'UEF'},
}

--[<no view> You captured the prison, but not all civilians are in it. Give player some feedback about this.]--
M1_Prison_Captured = {
  {text = '[UEF]: You\'ve succesfully captured the prison, but we couldn\'t find all of the kidnapped civilians inside. Some are still missing.', vid = 'spinUEFBlue_6sec.sfd', bank = 'TCR_VO', cue = '5M1_Prison_Captured', faction = 'UEF'},
}

--[<no view> You destroyed all of the marked buildings (factories) in the first base. Give player some feedback about this.]--
M1_Base_Destroyed = {
  {text = '[UEF]: You\'ve succesfully destroyed the Cybran base.', vid = 'spinUEFBlue_3sec.sfd', bank = 'TCR_VO', cue = '6M1_Base_Destroyed', faction = 'UEF'},
}

--[<no view> You weren't able to capture the prison before the deadline, so we automatically move the mission along. We'll enter 2nd phase and there is another prison with the other civilians inside.]--
M1_Too_Slow = {
  {text = '[UEF]: We just received new intel. Some of the kidnapped civilians were transferred to a different prison more to the east.', vid = 'spinUEFBlue_6sec.sfd', bank = 'TCR_VO', cue = '7M1_Too_Slow', faction = 'UEF'},
}

# ----------------------------
# Mission 2
# Rescue Civilians with Spider
#-----------------------------
--[<no view> The 2nd phase of the mission has begun. Again you have to capture a prison to free the civilians.]--
M2_Main_Objective = {
  {text = '[UEF]: Free the kidnapped civilians by capturing the Cybran Prison.', vid = 'spinUEFBlue_4sec.sfd', bank = 'TCR_VO', cue = '8M2_Main_Objective', faction = 'UEF'},
}

--[<no view> You captured the prison, and the mission is about to end. Give player some feedback about this.]--
M2_Prison_Captured = {
  {text = '[UEF]: You\'ve succesfully captured the prison.', vid = 'spinUEFBlue_3sec.sfd', bank = 'TCR_VO', cue = '9M2_Prison_Captured', faction = 'UEF'},
}

--[<no view> (3+ players only) There are some forward defensive firebases. Player needs to destroy them first otherwise it'll be difficult to reach the base.]--
M2_Destroy_Forward_Defenses = {
  {text = '[UEF]: Destroy the Cybran forward defenses to open the path to the Cybran base.', vid = 'spinUEFBlue_5sec.sfd', bank = 'TCR_VO', cue = '10M2_Destroy_Forward_Defenses', faction = 'UEF'},
}

--[<no view> (3+ players only) There are some forward defensive firebases (maybe not really north?). Player needs to destroy them first otherwise it'll be difficult to reach the base.]--
M2_Forward_Defenses_1_Destroyed = {
  {text = '[UEF]: You\'ve succesfully destroyed the northern forward defenses.', vid = 'spinUEFBlue_4sec.sfd', bank = 'TCR_VO', cue = '11M2_Forward_Defenses_1_Destroyed', faction = 'UEF'},
}
--[<no view> (3+ players and hard difficulty only) There are some forward defensive firebases(maybe not really south?). Player needs to destroy them first otherwise it'll be difficult to reach the base.]--
M2_Forward_Defenses_2_Destroyed = {
  {text = '[UEF]: You\'ve succesfully destroyed the southern forward defenses.', vid = 'spinUEFBlue_4sec.sfd', bank = 'TCR_VO', cue = '12M2_Forward_Defenses_2_Destroyed', faction = 'UEF'},
}

--[<no view> You destroyed all of the marked buildings (pd,aa,...) in the first base. Give player some feedback about this.]--
M2_Base_Destroyed = {
  {text = '[UEF]: You\'ve succesfully destroyed the cybran base.', vid = 'spinUEFBlue_3sec.sfd', bank = 'TCR_VO', cue = '13M2_Base_Destroyed', faction = 'UEF'},
}

--[<no view> (3+ players and hard difficulty only) There are some forward defensive firebases(maybe not really south?). Player needs to destroy them first otherwise it'll be difficult to reach the base.]--
M2_Scared_Cybran = {
  {text = '[UEF]: They are afraid of your power and are rushing the Monkeylord. You don\'t have much time left to prepare.', vid = 'spinUEFBlue_6sec.sfd', bank = 'TCR_VO', cue = '14M2_Scared_Cybran', faction = 'UEF'},
}

M2_Scared_Cybran_Unseen = {
  {text = '[UEF]: It\'s a trap! They are afraid of your power and are rushing a Monkeylord to take you out. You don\'t have much time left to prepare.', vid = 'spinUEFBlue_5sec.sfd', bank = 'TCR_VO', cue = '14M2_Scared_Cybran_UnSeen', faction = 'UEF'},
}

--[<no view> When you scout the 2nd prison the UEF intelligence finds out that its all a trap and that there is a Monkeylord being made off camera.]--
M2_Monkeylord_Detected = {
  {text = '[UEF]: It\'s a trap! The Cybrans are preparing a Monkeylord to take you out. Complete the mission before the Monkeylord is ready!', vid = 'spinUEFBlue_6sec.sfd', bank = 'TCR_VO', cue = '15M2_Monkeylord_Detected', faction = 'UEF'},
}

--[<no view> The timer for the monkeylord is over, and it'll get dropped in the east base.]--
M2_Monkeylord_Is_Coming = {
  {text = '[UEF]: You were too slow and the cybrans are deploying the Monkeylord.', vid = 'spinUEFBlue_4sec.sfd', bank = 'TCR_VO', cue = '16M2_Monkeylord_Is_Coming', faction = 'UEF'},
}
--[<no view> The timer for the monkeylord is over, and it'll get dropped in the east base. Players hear about the monkeylord for the first time.]--
M2_Monkeylord_Is_Coming_Unseen = {
  {text = '[UEF]: It\'s a trap! The Cybrans are deploying a Monkeylord to take you out. Don\'t falter now. We need you to complete this mission!', vid = 'spinUEFBlue_6sec.sfd', bank = 'TCR_VO', cue = '16M2_Monkeylord_Is_Coming_UnSeeen', faction = 'UEF'},
}

--[<no view> You killed the experimental and a new timer has started, showing how long it'll take untill the next experimentals spawn.]--
M2_Experimental_Destroyed = {
  {text = '[UEF]: Good work, Commander. Destroying the experimental has given you some more time. Now hurry up and rescue the civilians before more experimentals arrive.', vid = 'spinUEFBlue_8sec.sfd', bank = 'TCR_VO', cue = '17M2_Experimental_Destroyed', faction = 'UEF'},
}

--[<no view> You killed all the experimentals and a new timer has started, showing how long it'll take untill the next experimentals spawn.]--
M2_Experimentals_Destroyed = {
  {text = '[UEF]: Good work, Commander. Destroying the experimentals has given you some more time. Now hurry up and rescue the civilians before more experimentals arrive.', vid = 'spinUEFBlue_8sec.sfd', bank = 'TCR_VO', cue = '18M2_Experimentals_Destroyed', faction = 'UEF'},
}

--[<no view> The experimentals timer has expired and a new wave of experimentals will arrive now.]--
M2_Time_Is_Up = {
  {text = '[UEF]: You took too long and the Cybrans have started their next experimental assault.', vid = 'spinUEFBlue_4sec.sfd', bank = 'TCR_VO', cue = '19M2_Time_Is_Up', faction = 'UEF'},
}
# ----------------------------
# End Game
#-----------------------------
--[<no view> You captured the prison succesfully and have now completed our mission. Give congratulations.]--
PlayerWin = {
  {text = '[UEF]: The civilians are safe. Congratulations commander.', vid = 'spinUEFBlue_4sec.sfd', bank = 'TCR_VO', cue = '20PlayerWin', faction = 'UEF'},
}
