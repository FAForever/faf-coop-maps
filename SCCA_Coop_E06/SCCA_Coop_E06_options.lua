options = 
{
	{ 
		default = 1, 
		label = "Initial Base", 
		help = "Choose your starting base's size.", 
		key = 'InitialBase', 
		pref = 'InitialBase', 
		values = { 
			{text = "Difficulty-determined", help = "Starting base size will be according to the selected difficulty.", key = 4, },
			{text = "Small base", help = "Starting base size used for Hard difficulty.", key = 3, },
			{text = "Medium base", help = "Starting base size used for Normal difficulty.", key = 2, },
			{text = "Full base", help = "Starting base size used for Easy difficulty.", key = 1, },
		}, 
	},
	{ 
		default = 1, 
		label = "Full Map Access", 
		help = "Determines operation area during the final part of Black Sun's defense.", 
		key = 'FullMapAccess', 
		pref = 'FullMapAccess', 
		values = { 
			{text = "Disabled",					help = "The mission will play out true to the original.", key = 1, },
			{text = "Enabled",	help = "Gain access to the full map during the final part of the operation.", key = 2, },
		}, 
	},
	{ 
		default = 1, 
		label = "Black Sun Support AI", 
		help = "Choose whether you want allied AI support from Aiko via a secondary objective later in the mission.", 
		key = 'BlackSunSupportAI', 
		pref = 'BlackSunSupportAI', 
		values = { 
			{text = "Disabled",					help = "No allied AI support.", key = 1, },
			{text = "Enabled",	help = "Add a secondary objective promting Aiko to support you for the rest of the mission.", key = 2, },
		}, 
	},
	{
		default = 7,
        label = "Black Sun Defense Timer",
        help = "Customize how long you want to defend Black Sun during its charging sequence. There are 20 charge segments, (Arnold arrives after the 16th charge), each taking some seconds, the total time is: 16 multiplied by seconds. Default is 90, which is 24 minutes before Arnold appears.",
        key = 'BlackSunChargeTimer',
		value_text = "%s",
        value_help = "Segment timer of %s seconds",
        values = {
            '120', '115', '110', '105', '100', '95','90', '85', '80', '75', '70', '65', '60', '55', '50', '45', '40', '35', '30', '25', '20', '15',
        },
	},
	{
		default = 1,
        label = "Black Sun Defense Attack Waves Delay",
        help = "Customize how long you want to delay major attack waves during Black Sun\'s charging sequence. Be warned that choosing a long delay along with a short timer will mess up the sequence, and pacing of the waves!",
        key = 'AttackWaveDelay',
		value_text = "%s",
        value_help = "Delay of %s seconds",
        values = {
            '15', '30', '60', '90', '120', '150', '180', '210', '240', '270', '300',
        },
	},
};
