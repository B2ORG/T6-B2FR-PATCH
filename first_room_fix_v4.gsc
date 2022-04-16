#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;
#include maps/mp/zombies/_zm_stats;
#include maps/mp/zombies/_zm_weapons;
#include maps/mp/animscripts/zm_utility;
#include maps/mp/zm_prison;
#include maps/mp/zm_tomb;
#include maps/mp/zm_tomb_utility;
#include maps/mp/zombies/_zm_audio;
#include maps/mp/zombies/_zm_net;

main()
{
	replaceFunc(maps/mp/animscripts/zm_utility::wait_network_frame, ::FixNetworkFrame);
	replaceFunc(maps/mp/zombies/_zm_utility::wait_network_frame, ::FixNetworkFrame);

	replaceFunc(maps/mp/zombies/_zm_weapons::get_pack_a_punch_weapon_options, ::GetPapWeaponReticle);
}

init()
{
	flag_init("dvars_set");
	// flag_init("cheat_detected");
	flag_init("cheat_printed");
	flag_init("cheat_printed_backspeed");
	flag_init("cheat_printed_noprint");
	flag_init("cheat_printed_cheats");

	level thread OnPlayerConnect();

	level.fix_revision = 11;
	level.debug = false;
	level.start_timestamp = 0;

	// Control modules
	level.cfg_reticle = true;				// Always default red dot
	level.cfg_fog = true;					// No fog
	// level.cfg_blood = true;					// Zombie blood on from challenge box | r3042 onwards again has custom / solo games
	level.cfg_characters = true;			// Set characters
	level.cfg_eyes = true;					// Nuketown blue eyes and richrofen announcer
	level.cfg_mannequins = true;			// Nuketown mannequins for yellow house
	level.cfg_timer = true;					// Timer
	level.cfg_sph = true;					// SPH

	// No Fog Config
	level.fog_coop = false;					// Allow coop
	level.fog_depot = false;				// Include depot in map list
	
	// Characters config
	level.char_coop = true;					// Allow coop
	level.char_survival = true;				// Allow character preset for survival
	level.char_victis = true;				// Allow character preset for green run maps
	level.char_mob = true;					// Allow character preset for mob
	level.char_origins = true;				// Allow character preset for origins

		// Survival characters (cia / cdc)
		level.survival1 = "cdc";
		level.survival2 = "cdc";
		level.survival3 = "cdc";
		level.survival4 = "cdc";

		// Tranzit characters (misty / russman / marlton / stuhlinger)
		level.victis1 = "misty";
		level.victis2 = "russman";
		level.victis3 = "marlton";
		level.victis4 = "stuhlinger";

		// Mob characters (weasel / finn / sal / billy)
		level.mob1 = "weasel";
		level.mob2 = "finn";
		level.mob3 = "sal";
		level.mob4 = "billy";

		// Origins characters (dempsey / nikolai / takeo / richtofen)
		level.origins1 = "dempsey";
		level.origins2 = "nikolai";
		level.origins3 = "takeo";
		level.origins4 = "richtofen";

	// Blue eyes config
	level.eyes_coop = false;				// Allow coop

	// Mannequins
	level.mann_coop = false;				// Allow coop

	// Timer config
	level.timer_coop = true;				// Allow timer for coop games
	level.timer_always_rt = false;			// Enable always displaying round time

	level.timer_right = true;				// Position timer on the right
	level.timer_color = (1, 1, 1);			// Set color for timer
	level.round_timer_color = (1, 1, 1);	// Set color for round timer
}

OnPlayerConnect()
{
	level waittill("connecting", player);	
	// level waittill("initial_players_connected");

	// Initial dvars & anticheat
	level thread SetDvars();
	level thread DvarDetector();

	// Blood in challenge crate & doors prices
	if (isdefined(level.cfg_blood) && level.cfg_blood)
	{
		level thread OriginsFix();
	}

	// No fog
	if ((isdefined(level.cfg_fog) && level.cfg_fog) && level.script == "zm_transit")
	{
		fog_players = HandlePlayerCount(level.fog_coop);

		// Handle depot
		fog_map = ReturnCfg(level.fog_depot, "transit", "placeholder");

		if ((level.scr_zm_map_start_location != fog_map) && (level.players.size <= fog_players))
		{
			setdvar ("r_fog", 0);
		}
	}

	// Blue eyes nuketown
	if ((isdefined(level.cfg_eyes) && level.cfg_eyes) && level.script == "zm_nuked")
	{
		eyes_players = HandlePlayerCount(level.eyes_coop);

		if (level.players.size <= eyes_players)
		{
			level thread EyeChange();
		}
	}

	// Mannequins nuketown
	if ((isdefined(level.cfg_mannequins) && level.cfg_mannequins) && (!level.enable_magic && level.script == "zm_nuked"))
	{
		mannequins_players = HandlePlayerCount(level.mann_coop);

		if (level.players.size <= mannequins_players)
		{
			level thread NukeMannequins();
		}
	}

	// Initialize global HUD
	level thread OnGameStart();

	while (1)
	{
        player thread OnPlayerSpawned();     
		level waittill("connected", player);	// After thread cause 1st player
	}
}

OnGameStart()
{
	flag_wait("initial_blackscreen_passed");
	level.start_timestamp = int(getTime() / 1000);

	// Timer
	timer_players = HandlePlayerCount(level.timer_coop);
	if (level.players.size <= timer_players)
	{
		if (isdefined(level.cfg_timer) && level.cfg_timer)
		{		
			level thread TimerHud();
		}
	}
	level thread RoundTimerHud();

	// Print SPH
	if (isDefined(level.cfg_sph) && level.cfg_sph)
	{
		level thread SphHud();
	}

	level waittill("end_game");
}

OnPlayerSpawned()
{
    level endon("game_ended");
	self endon("disconnect");

	my_id = self.clientid;
	if (level.debug)
	{
		self iPrintLn("clientid: " + my_id);
	}

	self.initial_spawn = true;
	for (;;)
	{
		self waittill("spawned_player");

		if (self.initial_spawn)
		{
            self.initial_spawn = false;

			// Prints
			self iPrintLn("^5FIRST ROOM FIX V4");
			self iPrintLn("^1PATCH VERSION: " + level.fix_revision);
			self thread PrintNetworkFrame(5);

			// Characters
			if (isdefined(level.cfg_characters) && level.cfg_characters)
			{
				char_players = HandlePlayerCount(level.char_coop);

				if (level.players.size <= char_players)
				{
					self thread SetCharacters();
				}
			}   
		}
	}
}

HandlePlayerCount(coop_bool, arg)
{
	answer = 0;

	if (!isdefined(arg))
	{
		arg = 0;
	}

	if (arg > 1 && arg < 8)
	{
		if (coop_bool)
		{
			answer = arg;
		}
	}
	else if (coop_bool)
	{
		answer = 8;
	}
	else
	{
		answer = 1;
	}

	if (level.debug)
	{
		print("answer: " + answer);
	}

	return answer;
}

ReturnCfg(bool, val_true, val_false)
{
	if (!isdefined(bool) || !isdefined(val_true) || !isdefined(val_false))
	{
		return;
	}

	if (bool)
	{
		return val_true;
	}
	else
	{
		return val_false;
	}
}

ConvertTime(seconds)
{
	hours = 0; 
	minutes = 0; 
	
	if( seconds > 59 )
	{
		minutes = int(seconds / 60);

		seconds = int(seconds * 1000) % (60 * 1000);
		seconds = seconds * 0.001; 

		if(minutes > 59)
		{
			hours = int(minutes / 60);
			minutes = int(minutes * 1000) % (60 * 1000);
			minutes = minutes * 0.001; 		
		}
	}

	str_hours = hours;
	if(hours < 10)
	{
		str_hours = "0" + hours; 
	}

	str_minutes = minutes;
	if(minutes < 10 && hours > 0)
	{
		str_minutes = "0" + minutes; 
	}

	str_seconds = seconds;
	if(seconds < 10)
	{
		str_seconds = "0" + seconds; 
	}

	if (hours == 0)
	{
		combined = "" + str_minutes  + ":" + str_seconds; 
	}
	else
	{
		combined = "" + str_hours  + ":" + str_minutes  + ":" + str_seconds; 
	}

	return combined; 
}

FixNetworkFrame()
{

	wait 0.1; 							// IF statement caused fix to not work
}

PrintNetworkFrame(len)
{
	network_hud = newClientHudElem(self);
	network_hud.alignx = "center";
	network_hud.aligny = "top";
	network_hud.horzalign = "user_center";
	network_hud.vertalign = "user_top";
	network_hud.x = 0;
	network_hud.y = 5;
	network_hud.fontscale = 1.8;
	network_hud.alpha = 0;
	network_hud.color = ( 1, 1, 1 );
	network_hud.hidewheninmenu = 1;
	network_hud.label = &"NETWORK FRAME: ^1";

	flag_wait("initial_blackscreen_passed");

	start_time = int(getTime());
	wait_network_frame();
	end_time = int(getTime());
	network_frame_len = (end_time - start_time) / 1000;

	if (!isdefined(len))
	{
		len = 5;
	}

	if (network_frame_len == 0.1)
	{
		network_hud.label = &"NETWORK FRAME: ^2";
	}
	
	network_hud setValue(network_frame_len);

	network_hud.alpha = 1;
	wait len;
	network_hud.alpha = 0;
	wait 0.1;
	network_hud destroy();
}

SetDvars()
{
	level waittill("initial_players_connected");
	while (1)
	{
		setdvar("player_strafeSpeedScale", 0.8);
		setdvar("player_backSpeedScale", 0.7);
	
		setdvar("con_gameMsgWindow0Filter", "gamenotify obituary");
		setdvar("con_gameMsgWindow0LineCount", 4);
		setdvar("con_gameMsgWindow0MsgTime", 5);
		setdvar("con_gameMsgWindow0FadeInTime", 0.25);
		setdvar("con_gameMsgWindow0FadeOutTime", 0.5);
				
		setdvar("sv_endGameIfISuck", 0); 		// Prevent host migration
		setdvar("sv_allowAimAssist", 0); 	 	// Removes target assist
		setdvar("sv_patch_zm_weapons", 0);		// Depatch patched recoil
		setdvar("sv_cheats", 0);

		if (!flag("dvars_set"))
		{
			flag_set("dvars_set");
		}
		level waittill("reset_dvars");
	}


}

DvarDetector() 
{
	cool_message = "Alright there fuckaroo, quit this cheated sheit and touch grass loser.";

	while (1) 
	{
		if (isdefined(level.debug) && level.debug)
		{
			// print("dvars_set " + flag("dvars_set"));
			// print("cheat_printed " + flag("cheat_printed"));
			// print("cheat_printed_backspeed " + flag("cheat_printed_backspeed"));
			// print("cheat_printed_noprint " + flag("cheat_printed_noprint"));
			// print("cheat_printed_cheats " + flag("cheat_printed_cheats"));
		}

		flag_wait("dvars_set");

		// Backspeed
		if (getDvar("player_strafeSpeedScale") != "0.8" || getDvar("player_backSpeedScale") != "0.7") 
		{
			if (!flag("cheat_printed")) 
			{
				level thread CreateWarningHud(cool_message, 0);
				flag_set("cheat_printed");
			}

			if (!flag("cheat_printed_backspeed"))
			{
				level thread CreateWarningHud("Movement Speed Modification Attempted.", 30);
				flag_set("cheat_printed_backspeed");
			}
			
			if (isdefined(level.debug) && !level.debug)
			{
				level notify("reset_dvars");
			}
			// flag_set("cheat_detected");
		}

		// Noprint
		if (getDvar("con_gameMsgWindow0LineCount") != "4" || getDvar("con_gameMsgWindow0MsgTime") != "5"
		|| getDvar("con_gameMsgWindow0FadeInTime") != "0.25" || getDvar("con_gameMsgWindow0FadeOutTime") != "0.5"
		|| getDvar("con_gameMsgWindow0Filter") != "gamenotify obituary") 
		{
			if (!flag("cheat_printed")) 
			{
				level thread CreateWarningHud(cool_message, 0);
				flag_set("cheat_printed");
			}

			if (!flag("cheat_printed_noprint"))
			{
				level thread CreateWarningHud("No Print Attempted.", 50);
				flag_set("cheat_printed_noprint");
			}

			if (isdefined(level.debug) && !level.debug)
			{
				level notify("reset_dvars");
			}
			// flag_set("cheat_detected");
		} 
		
		// Cheats
		if (getDvar("sv_cheats") != "0") 
		{
			if (!flag("cheat_printed")) 
			{
				level thread CreateWarningHud(cool_message, 0);
				flag_set("cheat_printed");
			}
			
			if (!flag("cheat_printed_cheats"))
			{
				level thread CreateWarningHud("sv_cheats Attempted.", 70);
				flag_set("cheat_printed_cheats");
			}

			if (isdefined(level.debug) && !level.debug)
			{
				level notify("reset_dvars");
			}
			// flag_set("cheat_detected");
		}
		wait 0.1;
	}
}

CreateWarningHud(text, offset) 
{
	warnHud = newHudElem();
	warnHud.fontscale = 1.5;
	warnHud.alignx = "left";
	warnHud.x = 20;
	warnHud.y = offset;
	warnHud.color = (0, 0, 0);
	warnHud.hidewheninmenu = 0;

	if (offset != 0) 
	{
		warnHud.label = &"^1";
	}
	else 
	{
		warnHud.label = &"^5";
	}

	warnHud setText(text);
	
	warnHud showElem();
}

TimerHud()
{
	timer_hud = newHudElem();
	timer_hud.alignx = "left";				
	timer_hud.aligny = "top";
	timer_hud.horzalign = "user_left";			
	timer_hud.vertalign = "user_top";
	timer_hud.x = 10; 							
	timer_hud.y = 5;							
	timer_hud.fontscale = 1.5;
	timer_hud.color = level.timer_color;
	timer_hud.hidewheninmenu = 1;
	if (level.timer_right)
	{
		timer_hud.alignx = "right";
		timer_hud.horzalign = "user_right";
		timer_hud.x = -10; 
		timer_hud.y = 25;
	} 

	if (level.debug)
	{
		iPrintLn("timer_color: " + level.timer_color);
		iPrintLn("timer_right: " + level.timer_right);
	}

	timer_hud setTimerUp(0); 
	timer_hud.alpha = 1;
}

RoundTimerHud()
{
	offset = 0;
	if (level.cfg_timer)
	{
		offset = 20;
	}

	round_timer_hud = newHudElem();
	round_timer_hud.alignx = "left";
	round_timer_hud.aligny = "top";
	round_timer_hud.horzalign = "user_left";	
	round_timer_hud.vertalign = "user_top";
	round_timer_hud.x = 10;				
	round_timer_hud.y = (5 + offset);
	round_timer_hud.fontscale = 1.5;
	round_timer_hud.alpha = 0;	
	round_timer_hud.color = level.round_timer_color;
	round_timer_hud.hidewheninmenu = 1;
	if (level.timer_right)
	{
		round_timer_hud.alignx = "right";
		round_timer_hud.horzalign = "user_right";
		round_timer_hud.x = -10; 
		round_timer_hud.y = (25 + offset);
	}

	if (level.debug)
	{
		iPrintLn("rt_color: " + level.round_timer_color);
		iPrintLn("rt_right: " + level.timer_right);
	}

	if (isdefined(level.cfg_timer) && !level.cfg_timer)
	{
		if (isdefined(level.timer_always_rt) && level.timer_always_rt)
		{
			level.timer_always_rt = false;
		}
	}		

	level thread SplitsTimerHud(round_timer_hud);

	if (level.timer_always_rt)
	{
		while(1)
		{
			level waittill("start_of_round");
			start_time = int(getTime() / 1000);
			round_timer_hud setTimerUp(0);
			round_timer_hud fadeOverTime(0.25);
			round_timer_hud.alpha = 1;

			level waittill("end_of_round");
			end_time = int(getTime() / 1000);
			time = ConvertTime(end_time - start_time);
			round_timer_hud setText(time);

			if (level.debug)
			{
				self iPrintLn(time);
			}

			wait 4;
			round_timer_hud fadeOverTime(0.25);
			round_timer_hud.alpha = 0;
		}
	}
	else
	{
		round_timer_hud.label = &"Round: ";
		while (1)
		{
			level waittill("start_of_round");
			start_time = int(getTime() / 1000);

			level waittill("end_of_round");
			end_time = int(getTime() / 1000);
			time = ConvertTime(end_time - start_time);

			if (level.debug)
			{
				self iPrintLn(time);
			}

			if (level.round_number >= 10)
			{
				round_timer_hud setText(time);
				round_timer_hud fadeOverTime(0.25);
				round_timer_hud.alpha = 1;
				wait 5;

				round_timer_hud fadeOverTime(0.25);
				round_timer_hud.alpha = 0;
			}
		}
	}
}

SplitsTimerHud(hud)
{
	splits_timer_hud = newHudElem();
	splits_timer_hud.alignx = hud.alignx;
	splits_timer_hud.aligny = hud.aligny;
	splits_timer_hud.horzalign = hud.horzalign;
	splits_timer_hud.vertalign = hud.vertalign;
	splits_timer_hud.x = hud.x; 				
	splits_timer_hud.y = (hud.y + 20);
	splits_timer_hud.fontscale = hud.fontscale;
	splits_timer_hud.alpha = 0;	
	splits_timer_hud.color = hud.color;
	splits_timer_hud.hidewheninmenu = hud.hidewheninmenu;

	while (1)
	{
		level waittill("end_of_round");
		wait 8.5;

		if ((level.round_number > 10) && (!level.round_number % 5))
		{
			time = int(getTime() / 1000);
			timestamp = ConvertTime(time - level.start_timestamp);

			if (level.debug)
			{
				iPrintLn("split_time: " + time);
				iPrintLn("start_timestamp: " + level.start_timestamp);
			}		

			splits_timer_hud setText("" + level.round_number + " time: " + timestamp);
			splits_timer_hud fadeOverTime(0.25);
			splits_timer_hud.alpha = 1;
			wait 4;

			splits_timer_hud fadeOverTime(0.25);
			splits_timer_hud.alpha = 0;
		}
	}
}

SphHud()
{
	sph_hud = newHudElem();
	sph_hud.alignx = "center";
	sph_hud.aligny = "top";
	sph_hud.horzalign = "user_center";
	sph_hud.vertalign = "user_top";
	sph_hud.x = 0; 				
	sph_hud.y = 25;
	sph_hud.fontscale = 1.5;
	sph_hud.alpha = 0;	
	sph_hud.color = (1, 1, 1);
	sph_hud.hidewheninmenu = 1;
	sph_hud.label = &"SPH: ";

	while (1)
	{
		level waittill("start_of_round");
		if (level.round_number >= 20)
		{
			rnd_size = (maps/mp/zombies/_zm_utility::get_round_enemy_array().size + level.zombie_total) / 24;
			rt_start = int(gettime() / 1000);
			level waittill("end_of_round");
			rt_end = int(gettime() / 1000);

			wait 1;
			sph = (rt_end - rt_start) / rnd_size;
			sph_hud setValue(sph);

			sph_hud fadeOverTime(0.25);
			sph_hud.alpha = 1;
			wait 4;
			sph_hud fadeOverTime(0.25);
			sph_hud.alpha = 0;
		}
	}
}

NukeMannequins()
{
	flag_wait("initial_blackscreen_passed");
	wait 1;
    destructibles = getentarray("destructible", "targetname");
    foreach ( mannequin in destructibles )
    {
        if (mannequin.origin == (1058.2, 387.3, -57))
        {
            mannequin delete();
        }
        if (mannequin.origin == (609.28, 315.9, -53.89))
        {
            mannequin delete();
        }
        if (mannequin.origin == (872.48, 461.88, -56.8))
        {
            mannequin delete();
        }
        if (mannequin.origin == (851.1, 156.6, -51))
        {
            mannequin delete();
        }
        if (mannequin.origin == (808, 140.5, -51))
        {
            mannequin delete();
        }
        if (mannequin.origin == (602.53, 281.09, -55))
        {
            mannequin delete();
        }
        if (mannequin.origin == (-30, 13.90, -47.04))
        {
            mannequin delete();
        }
    }
}

SetCharacters()
{
	if (isdefined(level.char_survival) && level.char_survival && !is_classic())
	{
		ciaviewmodel = "c_zom_suit_viewhands";
		cdcviewmodel = "c_zom_hazmat_viewhands";
		if (level.script == "zm_nuked")
		{
			cdcviewmodel = "c_zom_hazmat_viewhands_light";
		}
		
		// Get properties
		if (self.clientid == 0 || self.clientid == 4)
		{
			preset_player = level.survival1;
		}
		else if (self.clientid == 1 || self.clientid == 5)
		{
			preset_player = level.survival2;
		}
		else if (self.clientid == 2 || self.clientid == 6)
		{
			preset_player = level.survival3;
		}	
		else if (self.clientid == 3 || self.clientid == 7)
		{
			preset_player = level.survival4;
		}		
		
		// Set characters
		if (preset_player == "cdc")
		{
			self setmodel("c_zom_player_cdc_fb");
			self setviewmodel(cdcviewmodel);
			self.characterindex = 1;		
		}
		else if (preset_player == "cia")
		{
			self setmodel("c_zom_player_cia_fb");
			self setviewmodel(ciaviewmodel);
			self.characterindex = 0;
		}
	}
	else if (isdefined(level.char_victis) && level.char_victis)
	{
		if (level.script == "zm_transit" || level.script == "zm_highrise" || level.script == "zm_buried")	// Cause compiler sucks
		{
			// Get properties
			if (self.clientid == 0 || self.clientid == 4)
			{
				preset_player = level.victis1;
			}
			else if (self.clientid == 1 || self.clientid == 5)
			{
				preset_player = level.victis2;
			}
			else if (self.clientid == 2 || self.clientid == 6)
			{
				preset_player = level.victis3;
			}	
			else if (self.clientid == 3 || self.clientid == 7)
			{
				preset_player = level.victis4;
			}		
			
			// Set characters
			if (preset_player == "misty")
			{
				self setmodel("c_zom_player_farmgirl_fb");
				self setviewmodel("c_zom_farmgirl_viewhands");
				self.favorite_wall_weapons_list[self.favorite_wall_weapons_list.size] = "rottweil72_zm";
				self.favorite_wall_weapons_list[self.favorite_wall_weapons_list.size] = "870mcs_zm";
				self set_player_is_female(1);
				self.characterindex = 2;
				if (level.script == "zm_highrise")
				{
					self setmodel("c_zom_player_farmgirl_dlc1_fb");
					self.whos_who_shader = "c_zom_player_farmgirl_dlc1_fb";
				}
			}
			else if (preset_player == "russman")
			{
				self setmodel("c_zom_player_oldman_fb");
				self setviewmodel("c_zom_oldman_viewhands");
				self.favorite_wall_weapons_list[self.favorite_wall_weapons_list.size] = "frag_grenade_zm";
				self.favorite_wall_weapons_list[self.favorite_wall_weapons_list.size] = "claymore_zm";
				self set_player_is_female(0);
				self.characterindex = 0;
				if (level.script == "zm_highrise")
				{
					self setmodel("c_zom_player_oldman_dlc1_fb");
					self.whos_who_shader = "c_zom_player_oldman_dlc1_fb";
				}
			}
			else if (preset_player == "marlton")
			{
				self setmodel("c_zom_player_engineer_fb");
				self setviewmodel("c_zom_engineer_viewhands");
				self.favorite_wall_weapons_list[self.favorite_wall_weapons_list.size] = "m14_zm";
				self.favorite_wall_weapons_list[self.favorite_wall_weapons_list.size] = "m16_zm";
				self set_player_is_female(0);
				self.characterindex = 3;
				if (level.script == "zm_highrise")
				{
					self setmodel("c_zom_player_engineer_dlc1_fb");
					self.whos_who_shader = "c_zom_player_engineer_dlc1_fb";
				}
			}
			else if (preset_player == "stuhlinger")
			{
				self setmodel("c_zom_player_reporter_fb");
				self setviewmodel("c_zom_reporter_viewhands");
				self.favorite_wall_weapons_list[self.favorite_wall_weapons_list.size] = "beretta93r_zm";
				self.talks_in_danger = 1;
				level.rich_sq_player = self;
				self set_player_is_female(0);
				self.characterindex = 1;
				if (level.script == "zm_highrise")
				{
					self setmodel("c_zom_player_reporter_dlc1_fb");
					self.whos_who_shader = "c_zom_player_reporter_dlc1_fb";
				}
			}
		}
	}

	else if (isdefined(level.char_mob) && level.char_mob && level.script == "zm_prison")
	{
		// Get properties
		if (self.clientid == 0 || self.clientid == 4)
		{
			preset_player = level.mob1;
		}
		else if (self.clientid == 1 || self.clientid == 5)
		{
			preset_player = level.mob2;
		}
		else if (self.clientid == 2 || self.clientid == 6)
		{
			preset_player = level.mob3;
		}	
		else if (self.clientid == 3 || self.clientid == 7)
		{
			preset_player = level.mob4;
		}		
		
		// Set characters
		if (preset_player == "weasel")
		{
			self setmodel("c_zom_player_arlington_fb");
			self setviewmodel("c_zom_arlington_coat_viewhands");
			self.favorite_wall_weapons_list[self.favorite_wall_weapons_list.size] = "ray_gun_zm";
			self set_player_is_female(0);
			self.characterindex = 3;
			self.character_name = "Arlington";
			level.has_weasel = 1;
		}
		else if (preset_player == "finn")
		{
			self setmodel("c_zom_player_oleary_fb");
			self setviewmodel("c_zom_oleary_shortsleeve_viewhands");
			self.favorite_wall_weapons_list[self.favorite_wall_weapons_list.size] = "judge_zm";
			self set_player_is_female(0);
			self.characterindex = 0;
			self.character_name = "Finn";
		}
		else if (preset_player == "sal")
		{
			self setmodel("c_zom_player_deluca_fb");
			self setviewmodel("c_zom_deluca_longsleeve_viewhands");
			self.favorite_wall_weapons_list[self.favorite_wall_weapons_list.size] = "thompson_zm";
			self set_player_is_female(0);
			self.characterindex = 1;
			self.character_name = "Sal";
		}
		else if (preset_player == "billy")
		{
			self setmodel("c_zom_player_handsome_fb");
			self setviewmodel("c_zom_handsome_sleeveless_viewhands");
			self.favorite_wall_weapons_list[self.favorite_wall_weapons_list.size] = "blundergat_zm";
			self set_player_is_female(0);
			self.characterindex = 2;
			self.character_name = "Billy";
		}
	}

	else if (isdefined(level.char_origins) && level.char_origins && level.script == "zm_tomb")
	{
		// Get properties
		if (self.clientid == 0 || self.clientid == 4)
		{
			preset_player = level.origins1;
		}
		else if (self.clientid == 1 || self.clientid == 5)
		{
			preset_player = level.origins2;
		}
		else if (self.clientid == 2 || self.clientid == 6)
		{
			preset_player = level.origins3;
		}	
		else if (self.clientid == 3 || self.clientid == 7)
		{
			preset_player = level.origins4;
		}		
		
		// Set characters
		if (preset_player == "dempsey")
		{
			self setmodel("c_zom_tomb_dempsey_fb");
			self setviewmodel("c_zom_dempsey_viewhands");
			self set_player_is_female(0);
			self.characterindex = 0;
			self.character_name = "Dempsey";
		}
		else if (preset_player == "nikolai")
		{
			self setmodel("c_zom_tomb_nikolai_fb");
			self setviewmodel("c_zom_nikolai_viewhands");
			self.voice = "russian";
			self set_player_is_female(0);
			self.characterindex = 1;
			self.character_name = "Nikolai";
		}
		else if (preset_player == "takeo")
		{
			self setmodel("c_zom_tomb_takeo_fb");
			self setviewmodel("c_zom_takeo_viewhands");
			self set_player_is_female(0);
			self.characterindex = 3;
			self.character_name = "Takeo";
		}
		else if (preset_player == "richtofen")
		{
			self setmodel("c_zom_tomb_richtofen_fb");
			self setviewmodel("c_zom_richtofen_viewhands");
			self set_player_is_female(0);
			self.characterindex = 2;
			self.character_name = "Richtofen";
		}
	}
}

EyeChange()
{
	level setclientfield("zombie_eye_change", 1);
	sndswitchannouncervox("richtofen");
}

GetPapWeaponReticle ( weapon ) // Override to get rid of rng reticle
{
	if ( !isDefined( self.pack_a_punch_weapon_options ) )
	{
		self.pack_a_punch_weapon_options = [];
	}
	if ( !is_weapon_upgraded( weapon ) )
	{
		return self calcweaponoptions( 0, 0, 0, 0, 0 );
	}
	if ( isDefined( self.pack_a_punch_weapon_options[ weapon ] ) )
	{
		return self.pack_a_punch_weapon_options[ weapon ];
	}
	smiley_face_reticle_index = 1;
	base = get_base_name( weapon );
	camo_index = 39;
	if ( level.script == "zm_prison" )
	{
		camo_index = 40;
	}
	else if ( level.script == "zm_tomb" )
	{
		camo_index = 45;
	}
	lens_index = randomintrange( 0, 6 );
	reticle_index = randomintrange( 0, 16 );
	reticle_color_index = randomintrange( 0, 6 );
	plain_reticle_index = 16;
	if (level.cfg_reticle)
	{
		use_plain = true;  
	}
	else
	{
		r = randomint( 10 );
		use_plain = r < 3;
	}
	if ( base == "saritch_upgraded_zm" )
	{
		reticle_index = smiley_face_reticle_index;
	}
	else if ( use_plain )
	{
		reticle_index = plain_reticle_index;
	}
	scary_eyes_reticle_index = 8;
	purple_reticle_color_index = 3;
	if ( reticle_index == scary_eyes_reticle_index )
	{
		reticle_color_index = purple_reticle_color_index;
	}
	letter_a_reticle_index = 2;
	pink_reticle_color_index = 6;
	if ( reticle_index == letter_a_reticle_index )
	{
		reticle_color_index = pink_reticle_color_index;
	}
	letter_e_reticle_index = 7;
	green_reticle_color_index = 1;
	if ( reticle_index == letter_e_reticle_index )
	{
		reticle_color_index = green_reticle_color_index;
	}
	self.pack_a_punch_weapon_options[ weapon ] = self calcweaponoptions( camo_index, lens_index, reticle_index, reticle_color_index );
	return self.pack_a_punch_weapon_options[ weapon ];
}

OriginsFix()
{
	flag_wait("start_zombie_round_logic");
	wait 0.5;
	if (level.script == "zm_tomb")
	{
		level.is_forever_solo_game = 0;
	}
}