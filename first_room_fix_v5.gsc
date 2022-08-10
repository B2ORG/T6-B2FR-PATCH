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
	flag_init("cheat_printed_backspeed");
	flag_init("cheat_printed_noprint");
	flag_init("cheat_printed_cheats");

	// Patch Config
	level.FRFIX_ACTIVE = true;
	level.FRFIX_VER = 5.0;
	level.FRFIX_BETA = "";
	level.FRFIX_DEBUG = false;

	level thread OnGameStart();
}

OnGameStart()
{
	// Func Config
	level.FRFIX_TIMER_ENABLED = true;
	level.FRFIX_ROUND_ENABLED = false;
	level.FRFIX_HORDES_ENABLED = true;
	level.FRFIX_PERMAPERKS = true;
	level.FRFIX_HUD_COLOR = (0.9, 0.8, 1);
	level.FRFIX_YELLOWHOUSE = true;
	level.FRFIX_NUKETOWN_EYES = true;
	level.FRFIX_NOFOG = false;
	level.FRFIX_ORIGINSFIX = true;

	level thread OnPlayerJoined();

	level waittill("initial_players_connected");

	// Initial game settings
	level thread SetDvars();
	level thread DvarDetector();
	level thread OriginsFix();
	level thread NoFog();
	level thread EyeChange();

	flag_wait("initial_blackscreen_passed");

	level.FRFIX_START = int(getTime() / 1000);

	// HUD
	level thread BasicSplitsHud();
	level thread TimerHud();
	level thread RoundTimerHud();
	level thread SplitsTimerHud();
	level thread ZombiesHud();

	// Game settings
	SongSafety();
	level thread NukeMannequins();

	level waittill("end_game");
}

OnPlayerJoined()
{
	while (true)
	{
		level waittill("connected", player);

		player iPrintLn("^5FIRST ROOM FIX V" + level.FRFIX_VER + " " + level.FRFIX_BETA);
		player thread PrintNetworkFrame(6);
		player thread AwardPermaPerks();
	}
}

// Utilities

CreateWarningHud(text, offset) 
{
	warnHud = newHudElem();
	warnHud.fontscale = 1.5;
	warnHud.alignx = "left";
	warnHud.x = 20;
	warnHud.y = offset;
	warnHud.color = (0, 0, 0);
	warnHud.alpha = 0;
	warnHud.hidewheninmenu = 0;

	if (offset != 0) 
		warnHud.label = &"^1";

	else 
		warnHud.label = &"^5";

	warnHud setText(text);
	
	warnHud.alpha = 1;
}

HudPos(hud, y_offset)
{
	if (!isDefined(y_offset))
		y_offset = 0;

	last_state = -1;

	while (true)
	{
		if (getDvarInt("timer_left") != last_state)
		{
			last_state = getDvarInt("timer_left");
			if (getDvarInt("timer_left"))
				hud setPoint("TOPLEFT", "TOPLEFT", -8, y_offset);
			else
				hud setPoint("TOPRIGHT", "TOPRIGHT", -8, y_offset);
		}
		wait 0.05;
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
		str_hours = "0" + hours; 

	str_minutes = minutes;
	if(minutes < 10 && hours > 0)
		str_minutes = "0" + minutes; 

	str_seconds = seconds;
	if(seconds < 10)
		str_seconds = "0" + seconds; 

	if (hours == 0)
		combined = "" + str_minutes  + ":" + str_seconds; 
	else
		combined = "" + str_hours  + ":" + str_minutes  + ":" + str_seconds; 

	return combined; 
}

// Functions

SetDvars()
{
	setDvar("timer_left", 0);

	while (true)
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
			flag_set("dvars_set");

		level waittill("reset_dvars");
	}
}

DvarDetector() 
{
	cool_message = "Alright there fuckaroo, quit this cheated sheit and touch grass loser.";

	while (true) 
	{
		flag_wait("dvars_set");

		// Backspeed
		if (getDvar("player_strafeSpeedScale") != "0.8" || getDvar("player_backSpeedScale") != "0.7") 
		{
			if (!flag("cheat_printed_backspeed") && !flag("cheat_printed_noprint") && !flag("cheat_printed_cheats")) 
			{
				level thread CreateWarningHud(cool_message, 0);
				flag_set("cheat_printed");
			}

			if (!flag("cheat_printed_backspeed"))
			{
				level thread CreateWarningHud("Movement Speed Modification Attempted.", 30);
				flag_set("cheat_printed_backspeed");
			}
			
			level notify("reset_dvars");
		}

		// Noprint
		if (getDvar("con_gameMsgWindow0LineCount") != "4" || getDvar("con_gameMsgWindow0MsgTime") != "5"
		|| getDvar("con_gameMsgWindow0FadeInTime") != "0.25" || getDvar("con_gameMsgWindow0FadeOutTime") != "0.5"
		|| getDvar("con_gameMsgWindow0Filter") != "gamenotify obituary") 
		{
			if (!flag("cheat_printed_backspeed") && !flag("cheat_printed_noprint") && !flag("cheat_printed_cheats")) 
			{
				level thread CreateWarningHud(cool_message, 0);
				flag_set("cheat_printed");
			}

			if (!flag("cheat_printed_noprint"))
			{
				level thread CreateWarningHud("No Print Attempted.", 50);
				flag_set("cheat_printed_noprint");
			}

			level notify("reset_dvars");
		} 
		
		// Cheats
		if (getDvar("sv_cheats") != "0") 
		{
			if (!flag("cheat_printed_backspeed") && !flag("cheat_printed_noprint") && !flag("cheat_printed_cheats")) 
			{
				level thread CreateWarningHud(cool_message, 0);
				flag_set("cheat_printed");
			}
			
			if (!flag("cheat_printed_cheats"))
			{
				level thread CreateWarningHud("sv_cheats Attempted.", 70);
				flag_set("cheat_printed_cheats");
			}

			level notify("reset_dvars");
		}
		wait 0.1;
	}
}

FixNetworkFrame()
{
	wait 0.1;
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
	network_hud.fontscale = 1.9;
	network_hud.alpha = 0;
	network_hud.color = ( 1, 1, 1 );
	network_hud.hidewheninmenu = 1;
	network_hud.label = &"NETWORK FRAME: ^1";

	if (!flag("initial_blackscreen_passed"))
		flag_wait("initial_blackscreen_passed");

	start_time = int(getTime());
	wait_network_frame();
	end_time = int(getTime());
	network_frame_len = (end_time - start_time) / 1000;

	if (!isdefined(len))
		len = 5;

	if (network_frame_len == 0.1)
		network_hud.label = &"NETWORK FRAME: ^2";
	
	network_hud setValue(network_frame_len);

	network_hud.alpha = 1;
	wait len;
	network_hud.alpha = 0;
	wait 0.1;
	network_hud destroy();
}

BasicSplitsHud()
{
    self endon("disconnect");
    level endon("end_game");

	basegt_hud = createserverfontstring("hudsmall" , 1.5);
	basegt_hud setPoint("TOPRIGHT", "TOPRIGHT", -8, 0);
	basegt_hud.color = level.FRFIX_HUD_COLOR;
	basegt_hud.alpha = 0;
	basegt_hud.hidewheninmenu = 1;
	basegt_hud.label = &"GAME: ";

	basert_hud = createserverfontstring("hudsmall" , 1.5);
	basert_hud setPoint("TOPRIGHT", "TOPRIGHT", -8, 17);
	basert_hud.color = level.FRFIX_HUD_COLOR;
	basert_hud.alpha = 0;
	basert_hud.hidewheninmenu = 1;
	basert_hud.label = &"ROUND: ";

	while (true)
	{
		level waittill("start_of_round");
		round_start = int(getTime() / 1000);

		level waittill("end_of_round");
		round_end = int(getTime() / 1000);

		if (level.players.size > 1)
			basegt_hud.label = &"LOBBY: ";

		if (!isdefined(level.FRFIX_TIMER_ENABLED) || !level.FRFIX_TIMER_ENABLED)
		{
			basegt_hud fadeOverTime(0.1);
			basegt_hud.alpha = 1;
		}
		if (!isdefined(level.FRFIX_ROUND_ENABLED) || !level.FRFIX_ROUND_ENABLED)
		{
			basert_hud fadeOverTime(0.1);
			basert_hud.alpha = 1;
		}

		if (basegt_hud.alpha == 0 && basert_hud.alpha == 0)
		{
			basegt_hud destroy();
			basert_hud destroy();
			break;
		}

		basegt_hud setTimer(round_end - level.FRFIX_START);
		basert_hud setTimer(round_end - round_start);

		for (ticks = 0; ticks < 100; ticks++)
		{
			basegt_hud setTimer(round_end - level.FRFIX_START);
			basert_hud setTimer(round_end - round_start);
			wait 0.05;
		}
		basegt_hud fadeOverTime(0.1);
		basert_hud fadeOverTime(0.1);
		basegt_hud.alpha = 0;
		basert_hud.alpha = 0;
	}

	return;
}

TimerHud()
{
    self endon("disconnect");
    level endon("end_game");

	if (!isdefined(level.FRFIX_TIMER_ENABLED) || !level.FRFIX_TIMER_ENABLED)
		return;

    timer_hud = createserverfontstring("hudsmall" , 1.5);
	timer_hud setPoint("TOPRIGHT", "TOPRIGHT", -8, 0);
	timer_hud.color = level.FRFIX_HUD_COLOR;
	timer_hud.alpha = 0;
	timer_hud.hidewheninmenu = 1;

	timer_hud setTimerUp(0);
	timer_hud.alpha = 1;

	self thread HudPos(timer_hud);
}

RoundTimerHud()
{
    self endon("disconnect");
    level endon("end_game");

	if (!isdefined(level.FRFIX_ROUND_ENABLED) || !level.FRFIX_ROUND_ENABLED)
		return;

	round_hud = createserverfontstring("hudsmall" , 1.5);
	round_hud setPoint("TOPRIGHT", "TOPRIGHT", -8, 17);
	round_hud.color = level.FRFIX_HUD_COLOR;
	round_hud.alpha = 0;
	round_hud.hidewheninmenu = 1;

	self thread HudPos(round_hud, 17);

	while (true)
	{
		level waittill("start_of_round");
		round_start = int(getTime() / 1000);
		round_hud setTimerUp(0);

		round_hud FadeOverTime(0.25);
		round_hud.alpha = 1;

		level waittill("end_of_round");
		round_end = int(getTime() / 1000);
		round_time = round_end - round_start;
		round_hud setTimer(round_time);

		for (ticks = 0; ticks < 100; ticks++)
		{
			round_hud setTimer(round_time);
			wait 0.05;
		}
		round_hud FadeOverTime(0.25);
		round_hud.alpha = 0;
	}
}

SplitsTimerHud()
{
    splits_hud = createserverfontstring("hudsmall" , 1.4);
	splits_hud setPoint("CENTER", "TOP", 0, 0);
	splits_hud.color = level.FRFIX_HUD_COLOR;
	splits_hud.alpha = 0;
	splits_hud.hidewheninmenu = 1;

	while (true)
	{
		level waittill("end_of_round");
		wait 8.5;	// Perfect round transition

		if ((level.round_number > 10) && (!level.round_number % 5))
		{
			time = int(getTime() / 1000);
			timestamp = ConvertTime(time - level.FRFIX_START);

			splits_hud setText("" + level.round_number + " TIME: " + timestamp);
			splits_hud fadeOverTime(0.25);
			splits_hud.alpha = 1;
			wait 4;

			splits_hud fadeOverTime(0.25);
			splits_hud.alpha = 0;
		}
	}
}

ZombiesHud()
{
	if (!isdefined(level.FRFIX_HORDES_ENABLED) || !level.FRFIX_HORDES_ENABLED)
		return;

    zombies_hud = createserverfontstring("hudsmall" , 1.4);
	zombies_hud setPoint("CENTER", "BOTTOM", 0, -75);
	zombies_hud.color = level.FRFIX_HUD_COLOR;
	zombies_hud.alpha = 0;
	zombies_hud.hidewheninmenu = 1;
	zombies_hud.label = &"Hordes this round: ";

	while (true)
	{
		level waittill("start_of_round");
		wait 0.1;
		if (level.round_number >= 20)
		{
			label = "HORDES ON " + level.round_number + ": ";
			zombies_hud.label = istring(label);

			zombies_value = int(((maps/mp/zombies/_zm_utility::get_round_enemy_array().size + level.zombie_total) / 24) * 100);
			zombies_hud setValue(zombies_value / 100);

			zombies_hud fadeOverTime(0.25);
			zombies_hud.alpha = 1;

			wait 5;

			zombies_hud fadeOverTime(0.25);
			zombies_hud.alpha = 0;
		}
	}
}

NukeMannequins()
{
	if (!isdefined(level.FRFIX_YELLOWHOUSE) || !level.FRFIX_YELLOWHOUSE)
		return;

	wait 1;
    destructibles = getentarray("destructible", "targetname");
    foreach ( mannequin in destructibles )
    {
		if (isdefined(level.enable_magic) && !level.enable_magic)
		{
			if (mannequin.origin == (1058.2, 387.3, -57))
				mannequin delete();

			if (mannequin.origin == (609.28, 315.9, -53.89))
				mannequin delete();

			if (mannequin.origin == (872.48, 461.88, -56.8))
				mannequin delete();

			if (mannequin.origin == (851.1, 156.6, -51))
				mannequin delete();

			if (mannequin.origin == (808, 140.5, -51))
				mannequin delete();

			if (mannequin.origin == (602.53, 281.09, -55))
				mannequin delete();

			// FR bus mannequin
			if (mannequin.origin == (-30, 13.9031, -47.0411))
           		mannequin delete();
		}
    }
}

EyeChange()
{
	if (!isdefined(level.NUKETOWN_EYES) || !level.NUKETOWN_EYES)
		return;

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

AwardPermaPerks()
{
	if (!maps\mp\zombies\_zm_pers_upgrades::is_pers_system_active())
		return;

	if (level.round_number > 2)		// 2 if ppl don't use minplayers
		return;

	if (!isdefined(level.FRFIX_PERMAPERKS) || !level.FRFIX_PERMAPERKS)
		return;

	if (!flag("initial_blackscreen_passed"))
		flag_wait("initial_blackscreen_passed");

	while (!isalive(self))
		wait 0.05;

	wait 0.5;

	// QR, Deadshot, Tombstone & Boards
	perks_list = array("revive", "multikill_headshots", "perk_lose", "board");

	// Jugg
	if (level.round_number < 15)
		perks_list[perks_list.size] = "jugg";

	// Flopper
	if (level.script == "zm_buried")
		perks_list[perks_list.size] = "flopper";

	// RayGun
	raygun_maps = array("zm_transit", "zm_buried");
	if (isinarray(raygun_maps, level.script))
		perks_list[perks_list.size] = "nube";

	// Set permaperks
	for (i = 0; i < perks_list.size; i++)
	{
		name = perks_list[i];

		for (j = 0; j < level.pers_upgrades[name].stat_names.size; j++)
		{
			stat_name = level.pers_upgrades[name].stat_names[j];
			self set_global_stat(stat_name, level.pers_upgrades[name].stat_desired_values[j]);
			self.stats_this_frame[stat_name] = 1;
		}
	}

	playfx(level._effect["upgrade_aquired"], self.origin);
	self playsoundtoplayer("evt_player_upgrade", self);
}

NoFog()
{
	if (!isdefined(level.FRFIX_NOFOG) || !level.FRFIX_NOFOG)
		return;

	setDvar("r_fog", 0);
}

OriginsFix()
{
	if (!isdefined(level.FRFIX_ORIGINSFIX) || !level.FRFIX_ORIGINSFIX)
		return;

	flag_wait("start_zombie_round_logic");
	wait 0.5;

	if (level.script == "zm_tomb")
		level.is_forever_solo_game = 0;
}

SongSafety()
{
	if (isDefined(level.SONG_AUTO_TIMER_ACTIVE) && level.SONG_AUTO_TIMER_ACTIVE)
	{
		iPrintLn("^1SONG PATCH DETECTED!!!");
		level notify("end_game");
	}
}

// SetCharacters()
// {
// 	if (isdefined(level.char_survival) && level.char_survival && !is_classic())
// 	{
// 		ciaviewmodel = "c_zom_suit_viewhands";
// 		cdcviewmodel = "c_zom_hazmat_viewhands";
// 		if (level.script == "zm_nuked")
// 		{
// 			cdcviewmodel = "c_zom_hazmat_viewhands_light";
// 		}
		
// 		// Get properties
// 		if (self.clientid == 0 || self.clientid == 4)
// 		{
// 			preset_player = level.survival1;
// 		}
// 		else if (self.clientid == 1 || self.clientid == 5)
// 		{
// 			preset_player = level.survival2;
// 		}
// 		else if (self.clientid == 2 || self.clientid == 6)
// 		{
// 			preset_player = level.survival3;
// 		}	
// 		else if (self.clientid == 3 || self.clientid == 7)
// 		{
// 			preset_player = level.survival4;
// 		}		
		
// 		// Set characters
// 		if (preset_player == "cdc")
// 		{
// 			self setmodel("c_zom_player_cdc_fb");
// 			self setviewmodel(cdcviewmodel);
// 			self.characterindex = 1;		
// 		}
// 		else if (preset_player == "cia")
// 		{
// 			self setmodel("c_zom_player_cia_fb");
// 			self setviewmodel(ciaviewmodel);
// 			self.characterindex = 0;
// 		}
// 	}
// 	else if (isdefined(level.char_victis) && level.char_victis)
// 	{
// 		if (level.script == "zm_transit" || level.script == "zm_highrise" || level.script == "zm_buried")	// Cause compiler sucks
// 		{
// 			// Get properties
// 			if (self.clientid == 0 || self.clientid == 4)
// 			{
// 				preset_player = level.victis1;
// 			}
// 			else if (self.clientid == 1 || self.clientid == 5)
// 			{
// 				preset_player = level.victis2;
// 			}
// 			else if (self.clientid == 2 || self.clientid == 6)
// 			{
// 				preset_player = level.victis3;
// 			}	
// 			else if (self.clientid == 3 || self.clientid == 7)
// 			{
// 				preset_player = level.victis4;
// 			}		
			
// 			// Set characters
// 			if (preset_player == "misty")
// 			{
// 				self setmodel("c_zom_player_farmgirl_fb");
// 				self setviewmodel("c_zom_farmgirl_viewhands");
// 				self.favorite_wall_weapons_list[self.favorite_wall_weapons_list.size] = "rottweil72_zm";
// 				self.favorite_wall_weapons_list[self.favorite_wall_weapons_list.size] = "870mcs_zm";
// 				self set_player_is_female(1);
// 				self.characterindex = 2;
// 				if (level.script == "zm_highrise")
// 				{
// 					self setmodel("c_zom_player_farmgirl_dlc1_fb");
// 					self.whos_who_shader = "c_zom_player_farmgirl_dlc1_fb";
// 				}
// 			}
// 			else if (preset_player == "russman")
// 			{
// 				self setmodel("c_zom_player_oldman_fb");
// 				self setviewmodel("c_zom_oldman_viewhands");
// 				self.favorite_wall_weapons_list[self.favorite_wall_weapons_list.size] = "frag_grenade_zm";
// 				self.favorite_wall_weapons_list[self.favorite_wall_weapons_list.size] = "claymore_zm";
// 				self set_player_is_female(0);
// 				self.characterindex = 0;
// 				if (level.script == "zm_highrise")
// 				{
// 					self setmodel("c_zom_player_oldman_dlc1_fb");
// 					self.whos_who_shader = "c_zom_player_oldman_dlc1_fb";
// 				}
// 			}
// 			else if (preset_player == "marlton")
// 			{
// 				self setmodel("c_zom_player_engineer_fb");
// 				self setviewmodel("c_zom_engineer_viewhands");
// 				self.favorite_wall_weapons_list[self.favorite_wall_weapons_list.size] = "m14_zm";
// 				self.favorite_wall_weapons_list[self.favorite_wall_weapons_list.size] = "m16_zm";
// 				self set_player_is_female(0);
// 				self.characterindex = 3;
// 				if (level.script == "zm_highrise")
// 				{
// 					self setmodel("c_zom_player_engineer_dlc1_fb");
// 					self.whos_who_shader = "c_zom_player_engineer_dlc1_fb";
// 				}
// 			}
// 			else if (preset_player == "stuhlinger")
// 			{
// 				self setmodel("c_zom_player_reporter_fb");
// 				self setviewmodel("c_zom_reporter_viewhands");
// 				self.favorite_wall_weapons_list[self.favorite_wall_weapons_list.size] = "beretta93r_zm";
// 				self.talks_in_danger = 1;
// 				level.rich_sq_player = self;
// 				self set_player_is_female(0);
// 				self.characterindex = 1;
// 				if (level.script == "zm_highrise")
// 				{
// 					self setmodel("c_zom_player_reporter_dlc1_fb");
// 					self.whos_who_shader = "c_zom_player_reporter_dlc1_fb";
// 				}
// 			}
// 		}
// 	}

// 	else if (isdefined(level.char_mob) && level.char_mob && level.script == "zm_prison")
// 	{
// 		// Get properties
// 		if (self.clientid == 0 || self.clientid == 4)
// 		{
// 			preset_player = level.mob1;
// 		}
// 		else if (self.clientid == 1 || self.clientid == 5)
// 		{
// 			preset_player = level.mob2;
// 		}
// 		else if (self.clientid == 2 || self.clientid == 6)
// 		{
// 			preset_player = level.mob3;
// 		}	
// 		else if (self.clientid == 3 || self.clientid == 7)
// 		{
// 			preset_player = level.mob4;
// 		}		
		
// 		// Set characters
// 		if (preset_player == "weasel")
// 		{
// 			self setmodel("c_zom_player_arlington_fb");
// 			self setviewmodel("c_zom_arlington_coat_viewhands");
// 			self.favorite_wall_weapons_list[self.favorite_wall_weapons_list.size] = "ray_gun_zm";
// 			self set_player_is_female(0);
// 			self.characterindex = 3;
// 			self.character_name = "Arlington";
// 			level.has_weasel = 1;
// 		}
// 		else if (preset_player == "finn")
// 		{
// 			self setmodel("c_zom_player_oleary_fb");
// 			self setviewmodel("c_zom_oleary_shortsleeve_viewhands");
// 			self.favorite_wall_weapons_list[self.favorite_wall_weapons_list.size] = "judge_zm";
// 			self set_player_is_female(0);
// 			self.characterindex = 0;
// 			self.character_name = "Finn";
// 		}
// 		else if (preset_player == "sal")
// 		{
// 			self setmodel("c_zom_player_deluca_fb");
// 			self setviewmodel("c_zom_deluca_longsleeve_viewhands");
// 			self.favorite_wall_weapons_list[self.favorite_wall_weapons_list.size] = "thompson_zm";
// 			self set_player_is_female(0);
// 			self.characterindex = 1;
// 			self.character_name = "Sal";
// 		}
// 		else if (preset_player == "billy")
// 		{
// 			self setmodel("c_zom_player_handsome_fb");
// 			self setviewmodel("c_zom_handsome_sleeveless_viewhands");
// 			self.favorite_wall_weapons_list[self.favorite_wall_weapons_list.size] = "blundergat_zm";
// 			self set_player_is_female(0);
// 			self.characterindex = 2;
// 			self.character_name = "Billy";
// 		}
// 	}

// 	else if (isdefined(level.char_origins) && level.char_origins && level.script == "zm_tomb")
// 	{
// 		// Get properties
// 		if (self.clientid == 0 || self.clientid == 4)
// 		{
// 			preset_player = level.origins1;
// 		}
// 		else if (self.clientid == 1 || self.clientid == 5)
// 		{
// 			preset_player = level.origins2;
// 		}
// 		else if (self.clientid == 2 || self.clientid == 6)
// 		{
// 			preset_player = level.origins3;
// 		}	
// 		else if (self.clientid == 3 || self.clientid == 7)
// 		{
// 			preset_player = level.origins4;
// 		}		
		
// 		// Set characters
// 		if (preset_player == "dempsey")
// 		{
// 			self setmodel("c_zom_tomb_dempsey_fb");
// 			self setviewmodel("c_zom_dempsey_viewhands");
// 			self set_player_is_female(0);
// 			self.characterindex = 0;
// 			self.character_name = "Dempsey";
// 		}
// 		else if (preset_player == "nikolai")
// 		{
// 			self setmodel("c_zom_tomb_nikolai_fb");
// 			self setviewmodel("c_zom_nikolai_viewhands");
// 			self.voice = "russian";
// 			self set_player_is_female(0);
// 			self.characterindex = 1;
// 			self.character_name = "Nikolai";
// 		}
// 		else if (preset_player == "takeo")
// 		{
// 			self setmodel("c_zom_tomb_takeo_fb");
// 			self setviewmodel("c_zom_takeo_viewhands");
// 			self set_player_is_female(0);
// 			self.characterindex = 3;
// 			self.character_name = "Takeo";
// 		}
// 		else if (preset_player == "richtofen")
// 		{
// 			self setmodel("c_zom_tomb_richtofen_fb");
// 			self setviewmodel("c_zom_richtofen_viewhands");
// 			self set_player_is_female(0);
// 			self.characterindex = 2;
// 			self.character_name = "Richtofen";
// 		}
// 	}
// }
