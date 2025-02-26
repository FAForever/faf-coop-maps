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

OPERATION_NAME = '<LOC FAF_Coop_Fort_Clarke_Assault_Name>Fort Clarke Assault'
OPERATION_DESCRIPTION = '<LOC FAF_Coop_Fort_Clarke_Assault_Description>Rework of the first FA mission from Seraphim point of view. Work in progress.'

-----------
-- Win/Lose
-----------
PlayerWin = {
    {text = '<LOC FAF_Coop_Fort_Clarke_Assault_PlayerWin>[Seraphim]: Something.', vid = '', bank = '', cue = '', faction = 'Seraphim'},
}



-- PO1 Factory West Destroyed / Actor:  / Update: 24/2/2016 / VO TODO
BaseDestroyed = {
    {text = '<LOC FAF_Coop_Fort_Clarke_Assault_BaseDestroyed>[Seraphim]: Something.', vid = '', bank = '', cue = '', faction = 'Seraphim'},
}

------------
-- Mission 1
------------

-- Primary Objective
M1P1Title = '<LOC FAF_Coop_Fort_Clarke_Assault_M1P1Title>Destroy UEF Forward Bases'
M1P1Description = '<LOC FAF_Coop_Fort_Clarke_Assault_M1P1Description>Secure the area around your starting location.'

-- Secondary Objective
M1S1Title = '<LOC FAF_Coop_Fort_Clarke_Assault_M1S1Title>Reclaim Experimental Bomber Wreck'
M1S1Description = '<LOC FAF_Coop_Fort_Clarke_Assault_M1S1Description>Use the Mass from the wreckage to boost your economy.'


------------
-- Mission 2
------------
-- Assign objective to kill Civilian City / Actor:  / Update: 24/2/2016 / VO TODO
M2_Kill_Civs_Objective = {
    {text = '<LOC FAF_Coop_Fort_Clarke_Assault_M2_Kill_Civs_Objective>[Seraphim]: Something.', vid = '', bank = '', cue = '', faction = 'Seraphim'},
}

-- Objective to Destroy M2 UEF City complete / Actor:  / Update: 24/2/2016 / VO TODO
M2_Civs_Killed = {
    {text = '<LOC FAF_Coop_Fort_Clarke_Assault_M2_Civs_Killed>[Seraphim]: Something.', vid = '', bank = '', cue = '', faction = 'Seraphim'},
}

-- Order Commander Killed / Actor:  / Update: 24/2/2016 / VO TODO
M2_OrderCommanderKilled = {
    {text = '<LOC FAF_Coop_Fort_Clarke_Assault_M2_OrderCommanderKilled>[Seraphim]: Something.', vid = '', bank = '', cue = '', faction = 'Seraphim'},
}

-- Primary Objective
M2P1Title = '<LOC FAF_Coop_Fort_Clarke_Assault_M2P1Title>Prepare your forces for the incoming couter attack'
M2P1Description = '<LOC FAF_Coop_Fort_Clarke_Assault_M2P1Description>Coalition forces are preparing major offensive against your positions. Build up your army to repel their attack.'

-- Secondary Objective
M2S1Title = '<LOC FAF_Coop_Fort_Clarke_Assault_M2S1Title>Annihilate Human City'
M2S1Description = '<LOC FAF_Coop_Fort_Clarke_Assault_M2S1Description>Destroy UEF City south of your location.'


------------
-- Mission 3
------------
-- Experimentals from Counterattack killed / Actor:  / Update: 24/2/2016 / VO TODO
M3_All_Exps_Killed = {
    {text = '<LOC FAF_Coop_Fort_Clarke_Assault_M3_All_Exps_Killed>[Seraphim]: Something.', vid = '', bank = '', cue = '', faction = 'Seraphim'},
}

-- Primary Objective
M3P1Title = '<LOC FAF_Coop_Fort_Clarke_Assault_M3P1Title>Survive the Counterattack'
M3P1Description = '<LOC FAF_Coop_Fort_Clarke_Assault_M3P1Description>Prevent Coalition forces from overrunning your position.'


------------
-- Mission 4
------------

-- Ythothas and T2 subs for player / Actor:  / Update: 24/2/2016 / VO TODO
M4_Reinforcements = {
    {text = '<LOC FAF_Coop_Fort_Clarke_Assault_M4_Reinforcements>[Seraphim]: Something.', vid = '', bank = '', cue = '', faction = 'Seraphim'},
}


-- Fork Clarke Destroyed / Actor:  / Update: 24/2/2016 / VO TODO
M4_Fort_Clarke_Destroyd = {
    {text = '<LOC FAF_Coop_Fort_Clarke_Assault_M4_Fort_Clarke_Destroyd>[Seraphim]: Something.', vid = '', bank = '', cue = '', faction = 'Seraphim'},
}

-- Aeon ACU Killed / Actor:  / Update: 24/2/2016 / VO TODO
M4_Aeon_ACU_Killed = {
    {text = '<LOC FAF_Coop_Fort_Clarke_Assault_M4_Aeon_ACU_Killed>[Seraphim]: Something.', vid = '', bank = '', cue = '', faction = 'Seraphim'},
}

-- Cybran ACU Killed / Actor:  / Update: 24/2/2016 / VO TODO
M4_Cybran_ACU_Killed = {
    {text = '<LOC FAF_Coop_Fort_Clarke_Assault_M4_Cybran_ACU_Killed>[Seraphim]: Something.', vid = '', bank = '', cue = '', faction = 'Seraphim'},
}

-- UEF ACU Killed / Actor:  / Update: 24/2/2016 / VO TODO
M4_UEF_ACU_Killed = {
    {text = '<LOC FAF_Coop_Fort_Clarke_Assault_M4_UEF_ACU_Killed>[Seraphim]: Something.', vid = '', bank = '', cue = '', faction = 'Seraphim'},
}

-- All ACUs Killed / Actor:  / Update: 24/2/2016 / VO TODO
M4_All_ACUs_Killed = {
    {text = '<LOC FAF_Coop_Fort_Clarke_Assault_M4_All_ACUs_Killed>[Seraphim]: Something.', vid = '', bank = '', cue = '', faction = 'Seraphim'},
}

-- Primary Objective
M4P1Title = '<LOC FAF_Coop_Fort_Clarke_Assault_M4P1Title>Destroy Fort Clarke'
M4P1Description = '<LOC FAF_Coop_Fort_Clarke_Assault_M4P1Description>Destroy Fort Clarke.'

-- Primary Objective
M4P2Title = '<LOC FAF_Coop_Fort_Clarke_Assault_M4P2Title>Defeat Coalition Commanders'
M4P2Description = '<LOC FAF_Coop_Fort_Clarke_Assault_M4P2Description>Fort Clarke is being reinforced by 3 Coalition commanders. Don\'t let them stay in your way.'
