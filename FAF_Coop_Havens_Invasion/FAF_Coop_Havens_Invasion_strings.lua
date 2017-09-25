OPERATION_NAME = '<LOC FAF_Coop_Havens_Invasion_Name>Haven\'s Invasion'
OPERATION_DESCRIPTION = '<LOC FAF_Coop_Havens_Invasion_Description>Invasion on Haven\'s Reef is starting. It\'s a planet controlled by UEF. You will gate in close to several small settlements and eradicate them. We expect very little resistance from these humans.'



-------------
-- Debriefing
-------------
-- Showed on the score screen if player wins
Debriefing_Win = {
    {text = '<LOC SCORE_0055>Operation Successful', faction = 'Seraphim'},
}

-- Showed on the score screen if player loses
Debriefing_Lose = {
    {text = '<LOC SCORE_0056>Operation Failed', faction = 'Seraphim'},
}



-------------
-- Win / Lose
-------------
-- Player wins
PlayerWins = {
    {text = '<LOC FAF_Coop_Havens_Invasion_PlayerWins>[Thuum-Aez]: This sector is clear of humans. Other operations on this planet are continuing as expected and the planet should be ours in less than an hour.', vid = 'Abasi.sfd', vidx = 'FAF_Coop_Havens_Invasion_PlayerWins.sfd', bank = 'FAF_Coop_Havens_Invasion_VO', cue = 'PlayerWins', faction = 'Seraphim'},
}

-- Player dies
PlayerDies = {
    {text = '<LOC FAF_Coop_Havens_Invasion_PlayerDies>[Beckett]: Scratch one alien.', vid = 'Fletcher.sfd', vidx = 'FAF_Coop_Havens_Invasion_PlayerDies.sfd', bank = 'FAF_Coop_Havens_Invasion_VO', cue = 'PlayerDies', faction = 'UEF'},
}



-----------------------
-- Mission 1 - Hot Drop
-----------------------
-- Intro dialogue
M1Intro1 = {
    {text = '<LOC FAF_Coop_Havens_Invasion_M1Intro1>[Thuum-Aez]: This is the first UEF facility you are to wipe out.', vid = 'Abasi.sfd', vidx = 'FAF_Coop_Havens_Invasion_M1Intro1.sfd', bank = 'FAF_Coop_Havens_Invasion_VO', cue = 'M1Intro1', faction = 'Seraphim'},
}

-- Intro dialogue
M1Intro2 = {
    {text = '<LOC FAF_Coop_Havens_Invasion_M1Intro2>[Thuum-Aez]: Establish a base and ... Grrrr ... seems like the UEF strengthened their position. Show them how the Seraphim fight!', vid = 'Abasi.sfd', vidx = 'FAF_Coop_Havens_Invasion_M1Intro2.sfd', bank = 'FAF_Coop_Havens_Invasion_VO', cue = 'M1Intro2', faction = 'Seraphim'},
}



-- Drop units to the player
M1Reinforcements = {
    {text = '<LOC FAF_Coop_Havens_Invasion_M1Reinforcements_1>[Thuum-Aez]: QAI, report.', vid = 'Abasi.sfd', vidx = 'FAF_Coop_Havens_Invasion_M1Reinforcements_1.sfd', bank = 'FAF_Coop_Havens_Invasion_VO', cue = 'M1Reinforcements_1', faction = 'Seraphim', delay = 2},
    {text = '<LOC FAF_Coop_Havens_Invasion_M1Reinforcements_2>[{i QAI}]: The scan shows that the UEF has already begun the evacuation. The higher presence of enemy forces should not require deploying another commander.', vid = 'QAI.sfd', vidx = 'FAF_Coop_Havens_Invasion_M1Reinforcements_2.sfd', bank = 'FAF_Coop_Havens_Invasion_VO', cue = 'M1Reinforcements_2', faction = 'Cybran'},
    {text = '<LOC FAF_Coop_Havens_Invasion_M1Reinforcements_3>[Thuum-Aez]: Some untis are being redirected to you so you can clear the UEF base faster. Leave no one alive.', vid = 'Abasi.sfd', vidx = 'FAF_Coop_Havens_Invasion_M1Reinforcements_3.sfd', bank = 'FAF_Coop_Havens_Invasion_VO', cue = 'M1Reinforcements_3', faction = 'Seraphim'},
}



-- Primary obj done
M1UEFBuildingDestroyed = {
    {text = '<LOC FAF_Coop_Havens_Invasion_M1UEFBuildingDestroyed>[Thuum-Aez]: Good, the first human settlement is destroyed.', vid = 'Abasi.sfd', vidx = 'FAF_Coop_Havens_Invasion_M1UEFBuildingDestroyed.sfd', bank = 'FAF_Coop_Havens_Invasion_VO', cue = 'M1UEFBuildingDestroyed', faction = 'Seraphim'},
}

-- Reminder
M1Reminder = {
    {text = '<LOC FAF_Coop_Havens_Invasion_M1Reminder>[Thuum-Aez]: What are you waiting for? Don\'t let them escape!', vid = 'Abasi.sfd', vidx = 'FAF_Coop_Havens_Invasion_M1Reminder.sfd', bank = 'FAF_Coop_Havens_Invasion_VO', cue = 'M1Reminder', faction = 'Seraphim'},
}



-- Trucks begin to move
M1TruckEvac = {
    {text = '<LOC FAF_Coop_Havens_Invasion_M1TruckEvac>[Beckett]: The northern defense line has been destroyed, beginning evacuation now.', vid = 'Fletcher.sfd', vidx = 'FAF_Coop_Havens_Invasion_M1TruckEvac.sfd', bank = 'FAF_Coop_Havens_Invasion_VO', cue = 'M1TruckEvac', faction = 'UEF'},
}

-- Player kills the escaping UEF trucks
M1TrucksDestroyed = {
    {text = '<LOC FAF_Coop_Havens_Invasion_M1TrucksDestroyed>[Beckett]: You will pay for this, Seraphim!.', vid = 'Fletcher.sfd', vidx = 'FAF_Coop_Havens_Invasion_M1TrucksDestroyed.sfd', bank = 'FAF_Coop_Havens_Invasion_VO', cue = 'M1TrucksDestroyed', faction = 'UEF'},
}



-- UEF Base destroyed
M1UEFBaseDestroyed = {
    {text = '<LOC FAF_Coop_Havens_Invasion_M1UEFBaseDestroyed>[Thuum-Aez]: That should be all the UEF units in the area.', vid = 'Abasi.sfd', vidx = 'FAF_Coop_Havens_Invasion_M1UEFBaseDestroyed.sfd', bank = 'FAF_Coop_Havens_Invasion_VO', cue = 'M1UEFBaseDestroyed', faction = 'Seraphim'},
}



-- Primary Objective
M1P1Title = '<LOC FAF_Coop_Havens_Invasion_M1P1Title>Destroy the UEF Administrative Building'

-- Primary Objective
M1P1Description = '<LOC FAF_Coop_Havens_Invasion_M1P1Description>This is your first target; destroy the marked UEF structure.'

-- Bonus Objective
M1B1Title = '<LOC FAF_Coop_Havens_Invasion_M1B1Title>No Survivors'

-- Bonus Objective
M1B1Description = '<LOC FAF_Coop_Havens_Invasion_M1B1Description>You killed UEF civilian trucks before they could escape.'



-----------------------
-- Mission 2 - Invasion
-----------------------
M2Intro1 = {
    {text = '<LOC FAF_Coop_Havens_Invasion_M2Intro1>[Thuum-Aez]: This was just one small settlement on this planet.', vid = 'Abasi.sfd', vidx = 'FAF_Coop_Havens_Invasion_M2Intro1.sfd', bank = 'FAF_Coop_Havens_Invasion_VO', cue = 'M2Intro1', faction = 'Seraphim'},
}

M2Intro2 = {
    {text = '<LOC FAF_Coop_Havens_Invasion_M2Intro2>[Thuum-Aez]: There is another one to the south of your position that you\'re going to destroy. It is guarded by one of the UEF commanders.', vid = 'Abasi.sfd', vidx = 'FAF_Coop_Havens_Invasion_M2Intro2.sfd', bank = 'FAF_Coop_Havens_Invasion_VO', cue = 'M2Intro2', faction = 'Seraphim'},
}

M2Intro3 = {
    {text = '<LOC FAF_Coop_Havens_Invasion_M2Intro3>[Thuum-Aez]: Kill the UEF commander and then all humans in the settlement. Do not let them escape!', vid = 'Abasi.sfd', vidx = 'FAF_Coop_Havens_Invasion_M2Intro3.sfd', bank = 'FAF_Coop_Havens_Invasion_VO', cue = 'M2Intro3', faction = 'Seraphim'},
}



-- UEF ACU killed, settlement is not destroyed yet
M2UEFCommanderDead1 = {
    {text = '<LOC FAF_Coop_Havens_Invasion_M2UEFCommanderDead1>[Thuum-Aez]: The UEF Commander is dead. Finish off the human settlement now.', vid = 'Abasi.sfd', vidx = 'FAF_Coop_Havens_Invasion_M2UEFCommanderDead1.sfd', bank = 'FAF_Coop_Havens_Invasion_VO', cue = 'M2UEFCommanderDead1', faction = 'Seraphim'},
}

-- UEF ACU killed, settlement is destroyed
M2UEFCommanderDead2 = {
    {text = '<LOC FAF_Coop_Havens_Invasion_M2UEFCommanderDead2>[Thuum-Aez]: The UEF Commander is dead.', vid = 'Abasi.sfd', vidx = 'FAF_Coop_Havens_Invasion_M2UEFCommanderDead2.sfd', bank = 'FAF_Coop_Havens_Invasion_VO', cue = 'M2UEFCommanderDead2', faction = 'Seraphim'},
}



-- Reminders
M2ReminderACU1 = {
    {text = '<LOC FAF_Coop_Havens_Invasion_M2ReminderACU1>[Thuum-Aez]: Warrior, you need to clear this sector.', vid = 'Abasi.sfd', vidx = 'FAF_Coop_Havens_Invasion_M2ReminderACU1.sfd', bank = 'FAF_Coop_Havens_Invasion_VO', cue = 'M2ReminderACU1', faction = 'Seraphim'},
}

M2ReminderACU2 = {
    {text = '<LOC FAF_Coop_Havens_Invasion_M2ReminderACU2>[Thuum-Aez]: The UEF commander is still standing in your way, defeat him!', vid = 'Abasi.sfd', vidx = 'FAF_Coop_Havens_Invasion_M2ReminderACU2.sfd', bank = 'FAF_Coop_Havens_Invasion_VO', cue = 'M2ReminderACU2', faction = 'Seraphim'},
}

M2ReminderCity1 = {
    {text = '<LOC FAF_Coop_Havens_Invasion_M2ReminderCity1>[Thuum-Aez]: Destroy the humans!', vid = 'Abasi.sfd', vidx = 'FAF_Coop_Havens_Invasion_M2ReminderCity1.sfd', bank = 'FAF_Coop_Havens_Invasion_VO', cue = 'M2ReminderCity1', faction = 'Seraphim'},
}

M2ReminderCity2 = {
    {text = '<LOC FAF_Coop_Havens_Invasion_M2ReminderCity2>[Thuum-Aez]: Kill the humans before they can escape!', vid = 'Abasi.sfd', vidx = 'FAF_Coop_Havens_Invasion_M2ReminderCity2.sfd', bank = 'FAF_Coop_Havens_Invasion_VO', cue = 'M2ReminderCity2', faction = 'Seraphim'},
}

M2ReminderBoth = {
    {text = '<LOC FAF_Coop_Havens_Invasion_M2ReminderBoth>[Thuum-Aez]: Warrior, defeat the UEF commander and kill every human in this sector!', vid = 'Abasi.sfd', vidx = 'FAF_Coop_Havens_Invasion_M2ReminderBoth.sfd', bank = 'FAF_Coop_Havens_Invasion_VO', cue = 'M2ReminderBoth', faction = 'Seraphim'},
}



-- UEF settlement destroyed, ACU not killed yet
M2UEFCityDestroyed1 = {
    {text = '<LOC FAF_Coop_Havens_Invasion_M2UEFCityDestroyed1>[Thuum-Aez]: The human settlement is no more. Kill the UEF commander now.', vid = 'Abasi.sfd', vidx = 'FAF_Coop_Havens_Invasion_M2UEFCityDestroyed1.sfd', bank = 'FAF_Coop_Havens_Invasion_VO', cue = 'M2UEFCityDestroyed1', faction = 'Seraphim'},
}

-- UEF settlement destroyed, ACU is dead
M2UEFCityDestroyed2 = {
    {text = '<LOC FAF_Coop_Havens_Invasion_M2UEFCityDestroyed2>[Thuum-Aez]: The human settlement is gone.', vid = 'Abasi.sfd', vidx = 'FAF_Coop_Havens_Invasion_M2UEFCityDestroyed2.sfd', bank = 'FAF_Coop_Havens_Invasion_VO', cue = 'M2UEFCityDestroyed2', faction = 'Seraphim'},
}



-- Primary Objective
M2P1Title = '<LOC FAF_Coop_Havens_Invasion_M2P1Title>Kill the UEF commander'

-- Primary Objective
M2P1Description = '<LOC FAF_Coop_Havens_Invasion_M2P1Description>Defeat the UEF commander guarding this sector.'

-- Primary Objective
M2P2Title = '<LOC FAF_Coop_Havens_Invasion_M2P2Title>Wipe out the UEF settlement'

-- Primary Objective
M2P2Description = '<LOC FAF_Coop_Havens_Invasion_M2P2Description>Your final task is to kill everyone in the human settlement protected by the UEF commander.'



---------
-- Taunts
---------
TAUNT1 = {
    {text = '<LOC FAF_Coop_Havens_Invasion_TAUNT1>[Beckett]: You\'ve picked the wrong opponent, Seraphim.', vid = 'Fletcher.sfd', vidx = 'FAF_Coop_Havens_Invasion_TAUNT1.sfd', bank = 'FAF_Coop_Havens_Invasion_VO', cue = 'TAUNT1', faction = 'UEF'},
}

-- Player's ACU under 50% HP
TAUNT2 = {
    {text = '<LOC FAF_Coop_Havens_Invasion_TAUNT2>[Beckett]: How do you like this, huh?.', vid = 'Fletcher.sfd', vidx = 'FAF_Coop_Havens_Invasion_TAUNT2.sfd', bank = 'FAF_Coop_Havens_Invasion_VO', cue = 'TAUNT2', faction = 'UEF'},
}

-- Player's ACU under 25% HP
TAUNT3 = {
    {text = '<LOC FAF_Coop_Havens_Invasion_TAUNT3>[Beckett]: Not so tough now, are you?.', vid = 'Fletcher.sfd', vidx = 'FAF_Coop_Havens_Invasion_TAUNT3.sfd', bank = 'FAF_Coop_Havens_Invasion_VO', cue = 'TAUNT3', faction = 'UEF'},
}

TAUNT4 = {
    {text = '<LOC FAF_Coop_Havens_Invasion_TAUNT4>[Beckett]: Leave this planet while you can.', vid = 'Fletcher.sfd', vidx = 'FAF_Coop_Havens_Invasion_TAUNT4.sfd', bank = 'FAF_Coop_Havens_Invasion_VO', cue = 'TAUNT4', faction = 'UEF'},
}

TAUNT5 = {
    {text = '<LOC FAF_Coop_Havens_Invasion_TAUNT5>[Beckett]: I\'m coming for you, Seraphim.', vid = 'Fletcher.sfd', vidx = 'FAF_Coop_Havens_Invasion_TAUNT5.sfd', bank = 'FAF_Coop_Havens_Invasion_VO', cue = 'TAUNT5', faction = 'UEF'},
}

TAUNT6 = {
    {text = '<LOC FAF_Coop_Havens_Invasion_TAUNT6>[Beckett]: This planet will not fall so easily.', vid = 'Fletcher.sfd', vidx = 'FAF_Coop_Havens_Invasion_TAUNT6.sfd', bank = 'FAF_Coop_Havens_Invasion_VO', cue = 'TAUNT6', faction = 'UEF'},
}

-- UEF ACU takes damage
TAUNT7 = {
    {text = '<LOC FAF_Coop_Havens_Invasion_TAUNT7>[Beckett]: You\'re going need much more than this...', vid = 'Fletcher.sfd', vidx = 'FAF_Coop_Havens_Invasion_TAUNT7.sfd', bank = 'FAF_Coop_Havens_Invasion_VO', cue = 'TAUNT7', faction = 'UEF'},
}