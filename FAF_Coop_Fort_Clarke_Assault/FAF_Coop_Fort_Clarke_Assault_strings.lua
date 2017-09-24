-----------
-- Story --
-----------
-- General overview:
--    Reworked first mission of FA from Seraphim point of view. Fort Clarke the last stronghold of the UEF have to be destroyed.
--    At the same time 3 coalition commanders defending it.
-- 
-- 
-- Intro
--    Seraphims launch attack on UEF bases, experimental bombers cleaning the area so ACU can gate in. Giving some intial units
--    to deal with leftover units and starting an assault.
-- 
-- Mission 1
--    Players starting in top right corner of the map (where Seraphim base was). First objective to destroy two small UEF bases.
--    Establishing your base, secondary objevtive to reclaim T4 bomber wreck to boost your eco.
--    Map will expand after certain time even if objectives are not completed to keep player under presure.
-- 
-- Mission 2
--    After map expand, the navy comes into play. Ally Order ACU is defending against Aeon and Cybran coalition attacks. Player's
--    objective is to prepare for incoming counter attack.
--    Off map attack on player from UEF bases.
--    Map will expand after certain time even if objectives are not completed to keep player under presure.
--
--        TODO: These attack needs to be balanced.
--
--    Secondary objectiv to destroy civilian city.
-- 
-- Mission 3
--    Incoming counter attack. Combined forces of all 3 coalition commanders, land, air, naval. Objective to destroy all experimentals.
--    This should be the harder part of the mission. Aeon and Cybran bases are revealed.
--
--        TODO: Finish and balance the attack. Both land and naval(not done at all yet) Some Atlantis, maybe Battleship.
--              Also Air attack. Make it harder part of the mission.
-- 
-- Mission 4
--    Final objectives, destroy Fort Clarke and all 3 coalition commanders.
--    Secondary objective to destroy another civilian ciry.
-- 
--    During this "the Nuke Party" is gonna happen. Order commander launching nukes on civilians. As a repay all 3 coalition
--    commander will nuke Order's base. Plan is to kill it so play is left alone. Also giving player time to build SMDs
--    since AI won't be afraid of nuking player as well.
--
--        TODO: There might be a problem with nuke party if player build additional SMDs in Order base.
--              Decide how to handle this.
--



-----------
-- Win/Lose
-----------
PlayerWin = {
  {text = '[Seraphim]: Something.', vid = '', bank = '', cue = '', faction = 'Seraphim'},
}



-- PO1 Factory West Destroyed / Actor:  / Update: 24/2/2016 / VO TODO
BaseDestroyed = {
  {text = '[Seraphim]: Something.', vid = '', bank = '', cue = '', faction = 'Seraphim'},
}



------------
-- Mission 2
------------
-- Assign objective to kill Civilian City / Actor:  / Update: 24/2/2016 / VO TODO
M2_Kill_Civs_Objective = {
  {text = '[Seraphim]: Something.', vid = '', bank = '', cue = '', faction = 'Seraphim'},
}

-- Objective to Destroy M2 UEF City complete / Actor:  / Update: 24/2/2016 / VO TODO
M2_Civs_Killed = {
  {text = '[Seraphim]: Something.', vid = '', bank = '', cue = '', faction = 'Seraphim'},
}

-- Order Commander Killed / Actor:  / Update: 24/2/2016 / VO TODO
M2_OrderCommanderKilled = {
  {text = '[Seraphim]: Something.', vid = '', bank = '', cue = '', faction = 'Seraphim'},
}


------------
-- Mission 3
------------
-- Experimentals from Counterattack killed / Actor:  / Update: 24/2/2016 / VO TODO
M3_All_Exps_Killed = {
  {text = '[Seraphim]: Something.', vid = '', bank = '', cue = '', faction = 'Seraphim'},
}



------------
-- Mission 4
------------

-- Ythothas and T2 subs for player / Actor:  / Update: 24/2/2016 / VO TODO
M4_Reinforcements = {
  {text = '[Seraphim]: Something.', vid = '', bank = '', cue = '', faction = 'Seraphim'},
}


-- Fork Clarke Destroyed / Actor:  / Update: 24/2/2016 / VO TODO
M4_Fort_Clarke_Destroyd = {
  {text = '[Seraphim]: Something.', vid = '', bank = '', cue = '', faction = 'Seraphim'},
}

-- Aeon ACU Killed / Actor:  / Update: 24/2/2016 / VO TODO
M4_Aeon_ACU_Killed = {
  {text = '[Seraphim]: Something.', vid = '', bank = '', cue = '', faction = 'Seraphim'},
}

-- Cybran ACU Killed / Actor:  / Update: 24/2/2016 / VO TODO
M4_Cybran_ACU_Killed = {
  {text = '[Seraphim]: Something.', vid = '', bank = '', cue = '', faction = 'Seraphim'},
}

-- UEF ACU Killed / Actor:  / Update: 24/2/2016 / VO TODO
M4_UEF_ACU_Killed = {
  {text = '[Seraphim]: Something.', vid = '', bank = '', cue = '', faction = 'Seraphim'},
}

-- All ACUs Killed / Actor:  / Update: 24/2/2016 / VO TODO
M4_All_ACUs_Killed = {
  {text = '[Seraphim]: Something.', vid = '', bank = '', cue = '', faction = 'Seraphim'},
}