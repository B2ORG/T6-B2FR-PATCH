#include common_scripts\utility;
#include maps\mp\gametypes_zm\_hud_util;
#include maps\mp\_utility;
#include maps\mp\animscripts\zm_utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\zombies\_zm_stats;
#include maps\mp\zombies\_zm_weapons;
#include maps\mp\zombies\_zm_powerups;
#include maps\mp\zombies\_zm_audio;
#include maps\mp\zombies\_zm_net;
#include maps\mp\zm_prison;
#include maps\mp\zm_tomb;
#include maps\mp\zm_tomb_utility;

main()
{
	replaceFunc(maps\mp\animscripts\zm_utility::wait_network_frame, ::fixed_wait_network_frame);
	replaceFunc(maps\mp\zombies\_zm_utility::wait_network_frame, ::fixed_wait_network_frame);

	replaceFunc(maps\mp\zombies\_zm_weapons::get_pack_a_punch_weapon_options, ::get_pap_weapon_options_set_reticle);
	replaceFunc(maps\mp\zombies\_zm_powerups::powerup_drop, ::powerup_drop_tracking);
}

init()
{
	flag_init("dvars_set");
	flag_init("cheat_printed_backspeed");
	flag_init("cheat_printed_noprint");
	flag_init("cheat_printed_cheats");
	flag_init("cheat_printed_gspeed");

	flag_init("game_started");
	flag_init("box_rigged");
	flag_init("break_firstbox");

	// Patch Config
	level.FRFIX_CONFIG = array();
	level.FRFIX_CONFIG["version"] = 6;
	level.FRFIX_CONFIG["beta"] = "BETA";
	level.FRFIX_CONFIG["debug"] = true;
	level.FRFIX_CONFIG["vanilla"] = get_vanilla_setting();

	level thread set_dvars();
	level thread perma_perks_setup();
	level thread on_game_start();
}

on_game_start()
{
	level endon("end_game");

	// Func Config
	level.FRFIX_CONFIG["hud_color"] = (0.9, 0.8, 1);
	level.FRFIX_CONFIG["const_timer"] = true;
	level.FRFIX_CONFIG["const_round_timer"] = false;
	level.FRFIX_CONFIG["show_hordes"] = true;
	level.FRFIX_CONFIG["give_permaperks"] = true;
	level.FRFIX_CONFIG["track_permaperks"] = false;
	level.FRFIX_CONFIG["mannequins"] = false;
	level.FRFIX_CONFIG["nuketown_25_ee"] = false;
	level.FRFIX_CONFIG["forever_solo_game_fix"] = false;
	level.FRFIX_CONFIG["semtex_prenades"] = true;
	level.FRFIX_CONFIG["fridge"] = false;
	level.FRFIX_CONFIG["first_box_module"] = false;

	level thread on_player_joined();

	level waittill("initial_players_connected");
	level.FRFIX_WATERMARKS = array();

	// Initial game settings
	level thread dvar_detector();
	level thread first_box_handler();
	level thread fridge_handler();
	level thread origins_fix();
	level thread eye_change();
	level thread debug_game_prints();
	level thread safety_anticheat();
	if (is_debug() && isDefined(level.FRFIX_TESTING_PLUGIN))
		level thread [[level.FRFIX_TESTING_PLUGIN]]();

	flag_wait("initial_blackscreen_passed");

	// HUD
	get_hud_position();
	level thread timer_hud();
	level thread round_timer_hud();
	level thread splits_timer_hud();
	level thread hordes_hud();
	level thread semtex_hud();

	// Game settings
	safety_zio();
	safety_round();
	safety_difficulty();
	safety_debugger();
	level thread mannequinn_manager();

	level waittill("end_game");
}

on_player_joined()
{
	level endon("end_game");

	while(true)
	{
		level waittill("connected", player);
		player thread on_player_spawned();
	}
}

on_player_spawned()
{
	level endon("end_game");
    self endon("disconnect");

	self waittill("spawned_player");

	// Perhaps a redundand safety check, but doesn't hurt
	while (!flag("initial_players_connected"))
		wait 0.05;

	self thread welcome_prints();
	self thread print_network_frame(6);
	self thread velocity_meter();
	self thread set_characters();
	self thread permaperks_watcher();

	// while(true)
	// {

	// }
}

// Stubs

replaceFunc(arg1, arg2)
{
}

print(arg1)
{
}

// Utilities

is_debug()
{
	if (isDefined(level.FRFIX_CONFIG["debug"]) && level.FRFIX_CONFIG["debug"])
		return true;
	return false;
}

debug_print(text)
{
	if (is_debug())
		print("DEBUG: " + text);
	return;
}

info_print(text)
{
	print("INFO: " + text);
	return;
}

print_permaperk_state(enabled, perk)
{
	if (enabled)
	{
		print_player = "^2ENABLED";
		print_cli = "enabled";
	}
	else
	{
		print_player = "^1DISABLED";
		print_cli = "disabled";
	}

	if (isDefined(level.FRFIX_CONFIG["track_permaperks"]) && level.FRFIX_CONFIG["track_permaperks"])
		self iPrintLn("Permaperk " + perk + ": " + print_player);
	debug_print("Permaperks: " + perk + " " + print_cli);
	return;
}

generate_watermark(text, color, alpha_override)
{
	y_offset = 12 * level.FRFIX_WATERMARKS.size;
	if (!isDefined(color))
		color = get_hud_color();

	if (!isDefined(alpha_override))
		alpha_override = 0.33;

    watermark = createserverfontstring("hudsmall" , 1.2);
	watermark setPoint("CENTER", "TOP", 0, y_offset - 10);
	watermark.color = color;
	watermark setText(text);
	watermark.alpha = alpha_override;
	watermark.hidewheninmenu = 0;

	level.FRFIX_WATERMARKS[level.FRFIX_WATERMARKS.size] = watermark;
}

convert_time(seconds)
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

player_wait_for_initial_blackscreen()
{
	level endon("end_game");

    while (!flag("game_started"))
        wait 0.05;
    return;
}

is_town()
{
	if (level.script == "zm_transit" && level.scr_zm_map_start_location == "town" && level.scr_zm_ui_gametype_group == "zsurvival")
		return true;
	return false;
}

is_farm()
{
	if (level.script == "zm_transit" && level.scr_zm_map_start_location == "farm" && level.scr_zm_ui_gametype_group == "zsurvival")
		return true;
	return false;
}

is_depot()
{
	if (level.script == "zm_transit" && level.scr_zm_map_start_location == "transit" && level.scr_zm_ui_gametype_group == "zsurvival")
		return true;
	return false;
}

is_tranzit()
{
	if (level.script == "zm_transit" && level.scr_zm_map_start_location == "transit" && level.scr_zm_ui_gametype_group == "zclassic")
		return true;
	return false;
}

is_nuketown()
{
	if (level.script == "zm_nuked")
		return true;
	return false;
}

is_die_rise()
{
	if (level.script == "zm_highrise")
		return true;
	return false;
}

is_mob()
{
	if (level.script == "zm_prison")
		return true;
	return false;
}

is_buried()
{
	if (level.script == "zm_buried")
		return true;
	return false;
}

is_origins()
{
	if (level.script == "zm_tomb")
		return true;
	return false;
}

did_game_just_start()
{
	if (!isDefined(level.start_round))
		return true;

	if (!is_round(level.start_round + 2))
		return true;

	return false;
}

is_round(rnd)
{
	if (rnd <= level.round_number)
		is_rnd = true;
	else
		is_rnd = false;
	
	// debug_print("if " + rnd + " <= " + level.round_number +": " + is_rnd)

	return is_rnd;
}

is_vanilla()
{
	if (isDefined(level.FRFIX_CONFIG["vanilla"]) && level.FRFIX_CONFIG["vanilla"])
		return true;
	return false;
}

has_magic()
{
    if (isDefined(level.enable_magic) && level.enable_magic)
        return true;
    return false;
}

get_hud_color(fallback)
{
	if (isDefined(level.FRFIX_HUD_COLOR_PLUGIN))
		return level.FRFIX_HUD_COLOR_PLUGIN;

	if (isDefined(level.FRFIX_CONFIG["hud_color"]))
		return level.FRFIX_CONFIG["hud_color"];

	if (isDefined(fallback))
		return fallback;

	return (1, 1, 1);
}

// Functions

welcome_prints()
{
	wait 0.75;
	self iPrintLn("^5FIRST ROOM FIX V" + level.FRFIX_CONFIG["version"] + " " + level.FRFIX_CONFIG["beta"]);
	wait 0.75;
	self iPrintLn("Source: github.com/Zi0MIX/T6-FIRST-ROOM-FIX");
}

generate_cheat()
{
	// Don't want to generate it twice
	if (isDefined(level.cheat_hud))
		return;

    level.cheat_hud = createserverfontstring("hudsmall" , 1.2);
	level.cheat_hud setPoint("CENTER", "CENTER", 0, -30);
	level.cheat_hud.color = (1, 0.5, 0);
	level.cheat_hud setText("Alright there fuckaroo, quit this cheated sheit and touch grass loser.");
	level.cheat_hud.alpha = 1;
	level.cheat_hud.hidewheninmenu = 0;

	level notify("cheat_generated");

	return;
}

debug_game_prints()
{
	level endon("end_game");

	self thread powerup_odds_watcher();
	self thread point_drop_watcher();

	while (true)
	{
		level waittill("start_of_round");
		info_print("ROUND: " + level.round_number + " level.powerup_drop_count = " + level.powerup_drop_count + " | Should be 0");
		info_print("ROUND: " + level.round_number + " size of level.zombie_powerup_array = " + level.zombie_powerup_array.size + " | Should be above 0");
	}
}

powerup_odds_watcher()
{
	level endon("end_game");

	while (true)
	{
		level waittill("powerup_check", chance);
		info_print("rand_drop = " + chance);
	}
}

point_drop_watcher()
{
	level endon("end_game");

	while (true)
	{
		wait 0.05;

		if (!level.zombie_vars["zombie_drop_item"])
			continue;

		while (level.zombie_vars["zombie_drop_item"])
			wait 0.05;
		info_print("Point drop");
	}
}

set_dvars()
{
	level endon("end_game");

	if (is_mob())
		level.custom_velocity_behaviour = ::hide_in_afterlife;

	// if (!getDvar("frfix_player0_character"))
	// 	setDvar("frfix_player0_character", randomInt(3));

	while (true)
	{
		setdvar("player_strafeSpeedScale", 0.8);
		setdvar("player_backSpeedScale", 0.7);
		setdvar("g_speed", 190);				// Only for reset_dvars

		setdvar("con_gameMsgWindow0Filter", "gamenotify obituary");
		setdvar("con_gameMsgWindow0LineCount", 4);
		setdvar("con_gameMsgWindow0MsgTime", 5);
		setdvar("con_gameMsgWindow0FadeInTime", 0.25);
		setdvar("con_gameMsgWindow0FadeOutTime", 0.5);

		setdvar("sv_endGameIfISuck", 0); 		// Prevent host migration
		setdvar("sv_allowAimAssist", 0); 	 	// Removes target assist
		setdvar("sv_patch_zm_weapons", 1);		// Force post dlc1 patch on recoil
		setdvar("sv_cheats", 0);

		if (!flag("dvars_set"))
			flag_set("dvars_set");

		level waittill("reset_dvars");
	}
}

dvar_detector() 
{
	level endon("end_game");

	// Waiting on top so it doesn't trigger before initial dvars are set
	flag_wait("dvars_set");

	while (true) 
	{
		// Backspeed
		if (getDvar("player_strafeSpeedScale") != "0.8" || getDvar("player_backSpeedScale") != "0.7") 
		{
			generate_cheat();

			if (!flag("cheat_printed_backspeed"))
			{
				generate_watermark("BACKSPEED", (0.8, 0, 0));
				flag_set("cheat_printed_backspeed");
			}
			
			level notify("reset_dvars");
		}

		// Noprint
		if (getDvarInt("con_gameMsgWindow0LineCount") < 1 || getDvarInt("con_gameMsgWindow0MsgTime") < 1 || getDvar("con_gameMsgWindow0Filter") != "gamenotify obituary") 
		{
			generate_cheat();

			if (!flag("cheat_printed_noprint"))
			{
				generate_watermark("NOPRINT", (0.8, 0, 0));
				flag_set("cheat_printed_noprint");
			}

			level notify("reset_dvars");
		} 
		
		// Cheats
		if (getDvarInt("sv_cheats")) 
		{
			generate_cheat();
			
			if (!flag("cheat_printed_cheats"))
			{
				generate_watermark("SV_CHEATS", (0.8, 0, 0));
				flag_set("cheat_printed_cheats");
			}

			level notify("reset_dvars");
		}

		// Gspeed
		if (getDvarInt("g_speed") != 190) 
		{
			generate_cheat();
			
			if (!flag("cheat_printed_gspeed"))
			{
				generate_watermark("GSPEED", (0.8, 0, 0));
				flag_set("cheat_printed_gspeed");
			}

			level notify("reset_dvars");
		}
		wait 0.1;
	}
}

get_vanilla_setting(override)
{
	if (isDefined(override))
		return override;

	if (getDvar("frfix_vanilla") == "0")
		return false;
	return true;
}

fixed_wait_network_frame()
{
	if (!isDefined(level.players) || level.players.size == 1)
		wait 0.1;
	else
		wait 0.05;
}

get_hud_position()
{
	if (!isDefined(level.hudpos_timer_game))
		level.hudpos_timer_game = ::hudpos_game_time;
	if (!isDefined(level.hudpos_timer_round))
		level.hudpos_timer_round = ::hudpos_round_time;
	if (!isDefined(level.hudpos_ongame_end))
		level.hudpos_ongame_end = ::hudpos_end_screen;
	if (!isDefined(level.hudpos_splits))
		level.hudpos_splits = ::hudpos_splits;
	if (!isDefined(level.hudpos_zombies))
		level.hudpos_zombies = ::hudpos_hordes;
	if (!isDefined(level.hudpos_velocity))
		level.hudpos_velocity = ::hudpos_velocity;
	if (!isDefined(level.hudpos_semtex_chart))
		level.hudpos_semtex_chart = ::hudpos_semtex;
}

hudpos_game_time(hudelem)
{
	hudelem setpoint("TOPRIGHT", "TOPRIGHT", -8, 0);
}

hudpos_round_time(hudelem)
{
	hudelem setpoint ("TOPRIGHT", "TOPRIGHT", -8, 17);
}

hudpos_end_screen(hudelem)
{
	hudelem setpoint ("CENTER", "MIDDLE", 0, -75);
}

hudpos_splits(hudelem)
{
	hudelem setpoint ("CENTER", "TOP", 0, 30);
}

hudpos_hordes(hudelem)
{
	hudelem setpoint ("CENTER", "BOTTOM", 0, -75);
}

hudpos_velocity(hudelem)
{
	hudelem setpoint ("CENTER", "CENTER", "CENTER", 200);
}

hudpos_semtex(hudelem)
{
	hudelem setpoint ("CENTER", "BOTTOM", 0, -95);
}

display_split(hudelem, time, length)
{
	level endon("end_game");

	display_time = 20;
	if (isDefined(length))
		display_time = int(length / 4);

	for (ticks = 0; ticks < display_time; ticks++)
	{
		hudelem setTimer(time - 0.1);
		wait 0.25;
	}
	hudelem fadeOverTime(0.25);
	hudelem.alpha = 0;

	return;
}

print_network_frame(len)
{
	level endon("end_game");
	self endon("disconnect");

    player_wait_for_initial_blackscreen();

    self.network_hud = createfontstring("hudsmall" , 1.9);
	self.network_hud setPoint("CENTER", "TOP", "CENTER", 5);
	self.network_hud.alpha = 0;
	self.network_hud.color = (1, 1, 1);
	self.network_hud.hidewheninmenu = 1;
    self.network_hud.label = &"NETWORK FRAME: ^2";

	flag_wait("initial_blackscreen_passed");

	start_time = int(getTime());
	wait_network_frame();
	end_time = int(getTime());
	network_frame_len = (end_time - start_time) / 1000;

	if (!isdefined(len))
		len = 5;

	if ((level.players.size == 1) && (network_frame_len != 0.1))
	{
		self.network_hud.label = &"NETWORK FRAME: ^1";
		generate_watermark("PLUTO SPAWNS", (0.8, 0, 0));
	}
	else if ((level.players.size > 1) && (network_frame_len != 0.05))
	{
		self.network_hud.label = &"NETWORK FRAME: ^1";
		generate_watermark("PLUTO SPAWNS", (0.8, 0, 0));
	}

	self.network_hud setValue(network_frame_len);

	self.network_hud.alpha = 1;
	wait len;
	self.network_hud.alpha = 0;
	wait 0.1;
	self.network_hud destroy();
}

timer_hud()
{
    level endon("end_game");

    timer_hud = createserverfontstring("hudsmall" , 1.5);
	[[level.hudpos_timer_game]](timer_hud);
	timer_hud.color = get_hud_color();
	timer_hud.alpha = 0;
	timer_hud.hidewheninmenu = 1;

	level.FRFIX_START = int(getTime() / 1000);
	flag_set("game_started");

	skip_split = false;
	label_time_set = false;

	if (!is_vanilla() && isdefined(level.FRFIX_CONFIG["const_timer"]) && level.FRFIX_CONFIG["const_timer"])
	{
		timer_hud setTimerUp(0);
		timer_hud.alpha = 1;
		skip_split = true;
	}
	else if (!is_vanilla())
	{
		timer_hud.label = "TIME: ";
		label_time_set = true;
	}

	while (true)
	{
		level waittill("end_of_round");
		split_time = int(GetTime() / 1000) - level.FRFIX_START;
		info_print("Time at the end of round " + (level.round_number - 1) + ": " + convert_time(split_time));

		if (is_vanilla() || skip_split)
			continue;

		if (level.players.size > 1 && isDefined(label_time_set) && label_time_set)
		{
			timer_hud.label = "LOBBY: ";
			label_time_set = undefined;
		}

		timer_hud fadeOverTime(0.25);
		timer_hud.alpha = 1;

		for (ticks = 0; ticks < 20; ticks++)
		{
			timer_hud setTimer(split_time - 0.1);
			wait 0.25;
		}

		timer_hud fadeOverTime(0.25);
		timer_hud.alpha = 0;

		split_time = undefined;
	}
}

round_timer_hud()
{
    level endon("end_game");

	round_hud = createserverfontstring("hudsmall" , 1.5);
	[[level.hudpos_timer_round]](round_hud);
	round_hud.color = get_hud_color();
	round_hud.alpha = 0;
	round_hud.hidewheninmenu = 1;

	while (true)
	{
		level waittill("start_of_round");

		round_start = int(getTime() / 1000);

		if (!is_vanilla() && isdefined(level.FRFIX_CONFIG["const_round_timer"]) && level.FRFIX_CONFIG["const_round_timer"])
		{
			round_hud setTimerUp(0);
			round_hud FadeOverTime(0.25);
			round_hud.alpha = 1;
		}

		level waittill("end_of_round");

		round_end = int(getTime() / 1000) - round_start;
		info_print("Round " + (level.round_number - 1) + " time: " + convert_time(round_end));

		round_start = undefined;

		if (is_vanilla())
			continue;

		if (!round_hud.alpha)
		{
			round_hud FadeOverTime(0.25);
			round_hud.alpha = 1;
		}

		for (ticks = 0; ticks < 20; ticks++)
		{
			round_hud setTimer(round_end - 0.1);
			wait 0.25;
		}

		round_hud FadeOverTime(0.25);
		round_hud.alpha = 0;
	}
}

splits_timer_hud()
{
	level endon("end_game");

	while (true)
	{
		level waittill("end_of_round");
		wait 8.5;	// Perfect round transition

		if (is_round(15) && !(level.round_number % 5))
		{
			splits_hud = createserverfontstring("hudsmall" , 1.3);
			[[level.hudpos_splits]](splits_hud);
			splits_hud.color = get_hud_color();
			splits_hud.alpha = 0;
			splits_hud.hidewheninmenu = 1;

			timestamp = convert_time(int(getTime() / 1000) - level.FRFIX_START);
			info_print("Split: Round " + (level.round_number - 1) + ": " + timestamp);

			if (is_vanilla())
				continue;

			splits_hud setText("" + level.round_number + " TIME: " + timestamp);
			splits_hud fadeOverTime(0.25);
			splits_hud.alpha = 1;
			wait 4;

			splits_hud fadeOverTime(0.25);
			splits_hud.alpha = 0;

			splits_hud destroy();
			timestamp = undefined;
			splits_hud = undefined;
		}
	}
}

hordes_hud()
{
	level endon("end_game");

	if (is_vanilla())
		return;

	if (!isdefined(level.FRFIX_CONFIG["show_hordes"]) || !level.FRFIX_CONFIG["show_hordes"])
		return;

	while (true)
	{
		level waittill("start_of_round");
		wait 0.1;
		if (isDefined(flag("dog_round")) && !flag("dog_round") && is_round(20))
		{
			zombies_hud = createserverfontstring("hudsmall" , 1.4);
			[[level.hudpos_zombies]](zombies_hud);
			zombies_hud.color = get_hud_color();
			zombies_hud.alpha = 0;
			zombies_hud.hidewheninmenu = 1;
			zombies_hud.label = &"Hordes this round: ";

			label = "HORDES ON " + level.round_number + ": ";
			zombies_hud.label = istring(label);

			zombies_value = int(((maps\mp\zombies\_zm_utility::get_round_enemy_array().size + level.zombie_total) / 24) * 100);
			zombies_hud setValue(zombies_value / 100);

			zombies_hud fadeOverTime(0.25);
			zombies_hud.alpha = 1;

			wait 5;

			zombies_hud fadeOverTime(0.25);
			zombies_hud.alpha = 0;

			zombies_hud destroy();
			zombies_hud = undefined;
			label = undefined;
			zombies_value = undefined;
		}
	}
}

velocity_meter()
{
    self endon("disconnect");
    level endon("end_game");

	if (is_vanilla())
		return;

    player_wait_for_initial_blackscreen();

    self.hud_velocity = createfontstring("hudsmall" , 1.2);
	[[level.hudpos_velocity]](self.hud_velocity);
	self.hud_velocity.alpha = 0.75;
	self.hud_velocity.color = get_hud_color();
	self.hud_velocity.hidewheninmenu = 1;
    // self.hud_velocity.label = &"Velocity: ";

	self thread velocity_meter_size(self.hud_velocity);

    while (true)
    {
		if (isDefined(level.custom_velocity_behaviour))
			[[level.custom_velocity_behaviour]](self.hud_velocity);

		velocity = int(length(self getvelocity() * (1, 1, 0)));
		velocity_meter_scale(velocity, self.hud_velocity);
        self.hud_velocity setValue(velocity);

        wait 0.05;
    }
}

velocity_meter_scale(vel, hud)
{
	hud.color = ( 0.6, 0, 0 );
	hud.glowcolor = ( 0.3, 0, 0 );

	if ( vel < 330 )
	{
		hud.color = ( 0.6, 1, 0.6 );
		hud.glowcolor = ( 0.4, 0.7, 0.4 );
	}

	else if ( vel <= 340 )
	{
		hud.color = ( 0.8, 1, 0.6 );
		hud.glowcolor = ( 0.6, 0.7, 0.4 );
	}

	else if ( vel <= 350 )
	{
		hud.color = ( 1, 1, 0.6 );
		hud.glowcolor = ( 0.7, 0.7, 0.4 );
	}

	else if ( vel <= 360 )
	{
		hud.color = ( 1, 0.8, 0.4 );
		hud.glowcolor = ( 0.7, 0.6, 0.2 );
	}

	else if ( vel <= 370 )
	{
		hud.color = ( 1, 0.6, 0.2 );
		hud.glowcolor = ( 0.7, 0.4, 0.1 );
	}

	else if ( vel <= 380 )
	{
		hud.color = ( 1, 0.2, 0 );
		hud.glowcolor = ( 0.7, 0.1, 0 );
	}
	
	return;
}

velocity_meter_size(hud)
{
    self endon("disconnect");
    level endon("end_game");

	while (true)
	{
		level waittill("say", message, player, ishidden);

		if (isSubStr(message, "vel") && player.name == self.name)
		{
			new_size = string_to_float(getSubStr(message, 4));

			// Fontscale does not accept values outside that range
			if (new_size < 1 || new_size > 4)
				continue;

			debug_print("Velocity: Current size: " + hud.fontscale + " / New size: " + new_size + " detected for player " + self.name);

			hud.fontscale = new_size;
			
			new_size = undefined;
		}
	}
}

semtex_hud()
{
	level endon("end_game");

	if (is_vanilla() || has_magic() || !is_town())
		return;

	// Escape if starting round is bigger than 22 since the display is going to be inaccurate
	if (!isdefined(level.FRFIX_CONFIG["semtex_prenades"]) || !level.FRFIX_CONFIG["semtex_prenades"] || is_round(23))
		return;

	// Starts on r22 and goes onwards
	chart = array(1, 2, 3, 4, 5, 7, 8, 9, 10, 12, 13, 17, 19, 22, 24, 28, 29, 34, 39, 42, 46, 52, 57, 61, 69, 78, 86, 96, 103);

	while (!is_round(22))
		level waittill("between_round_over");

	foreach(semtex in chart)
	{
		level waittill("start_of_round");
		wait 0.1;

		semtex_hud = createserverfontstring("hudsmall" , 1.4);
		[[level.hudpos_semtex_chart]](semtex_hud);
		semtex_hud.color = get_hud_color();
		semtex_hud.alpha = 0;
		semtex_hud.hidewheninmenu = 1;
		semtex_hud.label = &"Prenades this round: ";

		label = "PRENADES ON " + level.round_number + ": ";
		semtex_hud.label = istring(label);

		semtex_hud setValue(semtex);

		semtex_hud fadeOverTime(0.25);
		semtex_hud.alpha = 1;

		wait 5;

		semtex_hud fadeOverTime(0.25);
		semtex_hud.alpha = 0;

		semtex_hud destroy();
		label = undefined;
		semtex_hud = undefined;
	}

	return;
}

mannequinn_manager()
{
	level endon("end_game");

	if (!isdefined(level.FRFIX_CONFIG["mannequins"]) || !level.FRFIX_CONFIG["mannequins"])
		return;

	if (!is_nuketown())
		return;

	wait 1;
    destructibles = getentarray("destructible", "targetname");
    foreach (mannequin in destructibles)
    {
		if (!has_magic())
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
		}
		// FR bus mannequin
		if (mannequin.origin == (-30, 13.9031, -47.0411))
			mannequin delete();
    }
}

eye_change()
{
	if (!isdefined(level.FRFIX_CONFIG["nuketown_25_ee"]) || !level.FRFIX_CONFIG["nuketown_25_ee"])
		return;

	if (!is_nuketown())
		return;

	level setclientfield("zombie_eye_change", 1);
	sndswitchannouncervox("richtofen");
}

get_pap_weapon_options_set_reticle ( weapon ) // Override to get rid of rng reticle
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

perma_perks_setup()
{
	level endon("end_game");

	if (!maps\mp\zombies\_zm_pers_upgrades::is_pers_system_active())
		return;

	// It tends to crash without this statement lol
	if (is_mob() || is_origins())
		return;

	flag_wait("initial_blackscreen_passed");

	if (isdefined(level.FRFIX_CONFIG["give_permaperks"]) && level.FRFIX_CONFIG["give_permaperks"])
	{
		if (isDefined(level.frfix_metal_boards_func))
		{
			info_print("Metal Boards plugin present, if perk is awarded, a restart will be required");
			[[level.frfix_metal_boards_func]]();
		}
		self thread stop_permaperks_module();
		self thread watch_for_new_players();
	}
}

stop_permaperks_module()
{
	level endon("end_game");

	while (did_game_just_start())
		level waittill("end_of_round");

	debug_print("Stopping permaperks award");
	self notify("stop_permaperks_award");
}

// Make watcher usable after reconnecting any round
watch_for_new_players()
{
	level endon("end_game");
	self endon("stop_permaperks_award");

	// Give perma perks to everyone who is connected at this point
	foreach(player in level.players)
	{
		player thread award_permaperks();
	}

	// And wait for new players
	while (true)
	{
		level waittill("connected", player);

		player thread award_permaperks();
	}
}

permaperks_watcher()
{
	level endon("end_game");
	self endon("disconnect");

	self.last_perk_state = array();
	foreach(perk in level.pers_upgrades_keys)
		self.last_perk_state[perk] = self.pers_upgrades_awarded[perk];

	while (true)
	{
		foreach(perk in level.pers_upgrades_keys)
		{
			if (self.pers_upgrades_awarded[perk] != self.last_perk_state[perk])
			{
				if (!isDefined(self.frfix_awarding_permaperks))
					self print_permaperk_state(self.pers_upgrades_awarded[perk], perk);
				self.last_perk_state[perk] = self.pers_upgrades_awarded[perk];
				wait 0.1;
			}
		}

		wait 0.1;
	}
}

award_permaperks()
{
	level endon("end_game");
	self endon("disconnect");

	while (!isalive(self))
		wait 0.05;

	wait 0.5;

	perks_to_award = array("revive", "multikill_headshots", "perk_lose");
	perks_to_remove = array();

	if (!is_round(15))
		perks_to_award[perks_to_award.size] = "jugg";

	if (is_buried())
		perks_to_award[perks_to_award.size] = "flopper";
	else
		perks_to_remove[perks_to_remove.size] = "box_weapon";

	if (!is_die_rise() && !is_round(10))
		perks_to_award[perks_to_award.size] = "nube";
	else if (is_die_rise())
		perks_to_remove[perks_to_remove.size] = "nube";

	// Set permaperks
	self.frfix_awarding_permaperks = true;
	foreach(perk in perks_to_award)
	{
		for (j = 0; j < level.pers_upgrades[perk].stat_names.size; j++)
		{
			stat_name = level.pers_upgrades[perk].stat_names[j];
			stat_value = level.pers_upgrades[perk].stat_desired_values[j];

			self award_permaperk(stat_name, perk, stat_value);
			wait 0.05;
		}
	}

	foreach(perk in perks_to_remove)
	{
		self.pers_upgrades_awarded[perk] = 0;
		info_print("Perk Removal for " + self.name + ": " + perk);
	}
	self.frfix_awarding_permaperks = undefined;
}

award_permaperk(stat_name, perk_name, stat_value)
{
	self.stats_this_frame[stat_name] = 1;
	self set_global_stat(stat_name, stat_value);
	// self.pers_upgrades_awarded[perk_name] = 1;
	info_print("Perk Activation for " + self.name + ": " + perk_name + " -> " + stat_name + " set to: " + stat_value);
	return;
}

origins_fix()
{
    level endon("end_game");
	
	if (!isdefined(level.FRFIX_CONFIG["forever_solo_game_fix"]) || !level.FRFIX_CONFIG["forever_solo_game_fix"])
		return;

	flag_wait("start_zombie_round_logic");
	wait 0.5;

	if (is_origins())
		level.is_forever_solo_game = 0;
	// else if (is_mob() && level.players.size == 1)
	// 	level.is_forever_solo_game = 1;

	return;
}

safety_zio()
{
	if (isDefined(level.SONG_AUTO_TIMER_ACTIVE) && level.SONG_AUTO_TIMER_ACTIVE)
	{
		iPrintLn("^1SONG PATCH DETECTED!!!");
		level notify("end_game");
	}

	if (isDefined(level.INNIT_ACTIVE) && level.INNIT_ACTIVE)
	{
		iPrintLn("^1INNIT PATCH DETECTED!!!");
		level notify("end_game");
	}

	return;
}

safety_round()
{
	maxround = 1;
	if (is_town() || is_farm() || is_depot() || is_nuketown())
		maxround = 10;

	debug_print("Starting round detected: " + level.start_round);

	if (level.start_round <= maxround)
		return;

	generate_watermark("STARTING ROUND", (0.8, 0, 0));
	return;
}

safety_difficulty()
{
	if (level.gamedifficulty == 0)
		generate_watermark("EASY MODE", (0.8, 0, 0));
	return;
}

safety_debugger()
{
	if (is_debug())
	{
		foreach(player in level.players)
			player.score = 333333;
		generate_watermark("DEBUGGER", (0, 0.8, 0));
	}
	return;
}

safety_anticheat()
{
	level endon("end_game");

	level waittill("cheat_generated");
	while (isDefined(level.cheat_hud))
		wait 0.1;

	foreach (player in level.players)
		player doDamage(player.health + 69, player.origin);
}

powerup_drop_tracking( drop_point )
{
    if ( level.powerup_drop_count >= level.zombie_vars["zombie_powerup_drop_max_per_round"] )
        return;

    if ( !isdefined( level.zombie_include_powerups ) || level.zombie_include_powerups.size == 0 )
        return;

    rand_drop = randomint( 100 );
	level notify("powerup_check", rand_drop);

    if ( rand_drop > 2 )
    {
        if ( !level.zombie_vars["zombie_drop_item"] )
            return;

        debug = "score";
    }
    else
        debug = "random";

    playable_area = getentarray( "player_volume", "script_noteworthy" );
    level.powerup_drop_count++;
    powerup = maps\mp\zombies\_zm_net::network_safe_spawn( "powerup", 1, "script_model", drop_point + vectorscale( ( 0, 0, 1 ), 40.0 ) );
    valid_drop = 0;

    for ( i = 0; i < playable_area.size; i++ )
    {
        if ( powerup istouching( playable_area[i] ) )
            valid_drop = 1;
    }

    if ( valid_drop && level.rare_powerups_active )
    {
        pos = ( drop_point[0], drop_point[1], drop_point[2] + 42 );

        if ( check_for_rare_drop_override( pos ) )
        {
            level.zombie_vars["zombie_drop_item"] = 0;
            valid_drop = 0;
        }
    }

    if ( !valid_drop )
    {
        level.powerup_drop_count--;
        powerup delete();
        return;
    }

    powerup powerup_setup();
    print_powerup_drop( powerup.powerup_name, debug );
    powerup thread powerup_timeout();
    powerup thread powerup_wobble();
    powerup thread powerup_grab();
    powerup thread powerup_move();
    powerup thread powerup_emp();
    level.zombie_vars["zombie_drop_item"] = 0;
    level notify( "powerup_dropped", powerup );
}

fridge_handler()
// Fill up the README
{
	level endon("end_game");

	if (!is_tranzit() && !is_die_rise() && !is_buried())
		return;

	if (!isDefined(level.FRFIX_CONFIG["fridge"]) || !level.FRFIX_CONFIG["fridge"])
		return;

	self thread fridge();
	self thread fridge_state_watcher();

	// Cleanup
	level waittill("terminate_fridge_process", player_name);
	info_print("FRIDGE: Player " + player_name + " obtained his weapon. Fridge module no longer available");

	foreach(player in level.players)
	{
		if (isDefined(player.fridge_state))
			player.fridge_state = undefined;
	}
}

fridge()
{
	level endon("end_game");
	level endon("terminate_fridge_process");

	// Use plugin to set initial fridge weapons, only for players connected from r1
	if (isDefined(level.frfix_fridge_plugin))
		self thread [[level.frfix_fridge_plugin]](::player_rig_fridge);

	while (true)
	{
		level waittill("say", message, player, ishidden);

		if (isSubStr(message, "fridge all") && player ishost())
			rig_fridge(getSubStr(message, 11));
		else if (isSubStr(message, "fridge"))
			rig_fridge(getSubStr(message, 7), player);
	}
}

rig_fridge(key, player)
{
	if (isSubStr(key), "+")
		weapon = get_weapon_key(getSubStr(key, 2), ::verify_weapon_key_fridge_pap);
	else
		weapon = get_weapon_key(key, ::verify_weapon_key_fridge);

	if (!weapon)
		return;

	if (isDefined(player))
		player player_rig_fridge(weapon);
	else
	{
		foreach(player in level.players)
			player player_rig_fridge(weapon);
	}
}

player_rig_fridge(weapon)
{
	self clear_stored_weapondata();
	self set_map_weaponlocker_stat("name", weapon);
	self set_map_weaponlocker_stat("clip", weaponClipSize(weapon));
	self set_map_weaponlocker_stat("stock", weaponMaxAmmo(weapon));

	debug_print("FRIDGE: " + self.name + "s Fridge has been rigged with weapon '" + weapon + "'");
}

fridge_state_watcher()
{
	level endon("end_game");
	level endon("terminate_fridge_process");

	while (true)
	{
		foreach(player in level.players)
		{
			if (isDefined(player.fridge_state) && player.fridge_state != get_map_weaponlocker_stat("name"))
				level notify("terminate_fridge_process", player.name);
			else if (!isDefined(player.fridge_state))
				player.fridge_state = get_map_weaponlocker_stat("name");
		}

		wait 0.25;
	}
}

first_box_handler()
{
    level endon("end_game");

	if (!has_magic())
		return;

	flag_wait("initial_blackscreen_passed");

    level.is_first_box = false;

	// Debug func, doesn't do anything in production
	self thread debug_print_initial_boxsize();

	// Init threads watching the status of boxes
	self thread init_box_status_watcher();
	// Scan weapons in the box
	self thread scan_in_box();
	// First Box main loop
	self thread first_box();

	while (true)
	{
		if (isDefined(level.is_first_box) && level.is_first_box)
			break;

		wait 0.25;
	}

	generate_watermark("FIRST BOX", (0.8, 0, 0));
}

debug_print_initial_boxsize()
{
	in_box = 0;

	foreach (weapon in getArrayKeys(level.zombie_weapons))
	{
		if (maps\mp\zombies\_zm_weapons::get_is_in_box(weapon))
			in_box++;
	}
	debug_print("Size of initial box weapon list: " + in_box);
}

init_box_status_watcher()
{
    level endon("end_game");

	level.total_box_hits = 0;

	while (!isDefined(level.chests))
		wait 0.05;
	
	foreach(chest in level.chests)
		chest thread watch_box_state();
}

watch_box_state()
{
    level endon("end_game");

    while (!isDefined(self.zbarrier))
        wait 0.05;

	while (true)
	{
        while (self.zbarrier getzbarrierpiecestate(2) != "opening")
            wait 0.05;
		level.total_box_hits++;
        while (self.zbarrier getzbarrierpiecestate(2) == "opening")
            wait 0.05;
	}
}

scan_in_box()
{
    level endon("end_game");

	// Only town needed
    if (is_town() || is_farm() || is_depot() || is_tranzit())
        should_be_in_box = 25;
	else if (is_nuketown())
        should_be_in_box = 26;
	else if (is_die_rise())
        should_be_in_box = 24;
	else if (is_mob())
        should_be_in_box = 16;
    else if (is_buried())
        should_be_in_box = 22;
	else if (is_origins())
		should_be_in_box = 23;

	offset = 0;
	if (is_die_rise() || is_origins())
		offset = 1;

    while (isDefined(should_be_in_box))
    {
        wait 0.05;

        in_box = 0;

		foreach (weapon in getarraykeys(level.zombie_weapons))
        {
            if (maps\mp\zombies\_zm_weapons::get_is_in_box(weapon))
                in_box++;
        }

		// debug_print("in_box: " + in_box + " should: " + should_be_in_box);

        if (in_box == should_be_in_box)
			continue;

		else if ((offset > 0) && (in_box == (should_be_in_box + offset)))
			continue;

		level.is_first_box = true;
		break;

    }
    return;
}

first_box()
{	
    level endon("end_game");
	level endon("break_firstbox");

	if (!isDefined(level.FRFIX_CONFIG["first_box_module"]) || !level.FRFIX_CONFIG["first_box_module"])
		return;

	if (level.start_round > 1 && !is_town())
		return;

	flag_wait("initial_blackscreen_passed");

	iPrintLn("First Box module: ^2AVAILABLE");
	self thread watch_for_finish_firstbox();
	self.rigged_hits = 0;

	while (true)
	{
		level waittill("say", message, player, ishidden);

		if (isSubStr(message, "fb"))
			wpn_key = getSubStr(message, 3);
		else
			continue;

		self thread rig_box(wpn_key, player);
		wait_network_frame();

		wpn_key = undefined;

		while (flag("box_rigged"))
			wait 0.05;
	}
}

rig_box(gun, player)
{
    level endon("end_game");

	weapon_key = get_weapon_key(gun, ::verify_weapon_key_box);
	if (weapon_key == "")
	{
		iPrintLn("Wrong weapon key: ^1" + gun);
		return;
	}

	// weapon_name = level.zombie_weapons[weapon_key].name;
	iPrintLn("" + player.name + " set box weapon to: ^3" +  weapon_display_wrapper(weapon_key));
	level.is_first_box = true;
	self.rigged_hits++;

	saved_check = level.special_weapon_magicbox_check;
	current_box_hits = level.total_box_hits;
	removed_guns = array();

	flag_set("box_rigged");
	debug_print("FIRST BOX: flag('box_rigged'): " + flag("box_rigged"));

	level.special_weapon_magicbox_check = undefined;
	foreach(weapon in getarraykeys(level.zombie_weapons))
	{
		if ((weapon != weapon_key) && level.zombie_weapons[weapon].is_in_box == 1)
		{
			removed_guns[removed_guns.size] = weapon;
			level.zombie_weapons[weapon].is_in_box = 0;

			debug_print("FIRST BOX: setting " + weapon + ".is_in_box to 0");
		}
	}

	while ((current_box_hits == level.total_box_hits) || !isDefined(level.total_box_hits))
	{
		if (is_round(11))
		{
			debug_print("FIRST BOX: breaking out of First Box above round 10");
			break;
		}
		wait 0.05;
	}
	
	wait 5;

	level.special_weapon_magicbox_check = saved_check;

	debug_print("FIRST BOX: removed_guns.size " + removed_guns.size);
	if (removed_guns.size > 0)
	{
		foreach(rweapon in removed_guns)
		{
			level.zombie_weapons[rweapon].is_in_box = 1;
			debug_print("FIRST BOX: setting " + rweapon + ".is_in_box to 1");
		}
	}

	flag_clear("box_rigged");
	return;
}

watch_for_finish_firstbox()
{
    level endon("end_game");

	while (!is_round(11))
		wait 0.1;

	iPrintLn("First Box module: ^1DISABLED");
	if (self.rigged_hits)
		iPrintLn("First box used: ^3" + self.rigged_hits + " ^7times");

	level notify("break_firstbox");
	flag_set("break_firstbox");
	debug_print("FIRST BOX: notifying module to break");

	return;
}

get_weapon_key(weapon_str, verifier)
{
	key = "";

	switch(weapon_str)
	{
		case "mk1":
			key = "ray_gun_zm";
			break;
		case "mk2":
			key = "raygun_mark2_zm";
			break;
		case "monk":
			// if (is_town() || is_farm() || is_depot() || is_tranzit() || is_nuketown() || is_die_rise() || is_buried() || is_origins())
				key = "cymbal_monkey_zm";
			break;
		case "emp":
			// if (is_town() || is_farm() || is_depot() || is_tranzit())
				key = "emp_grenade_zm";
			break;
		case "time":
			// if (is_buried())
				key = "time_bomb_zm";
			break;
		case "sliq":
			// if (is_die_rise())
				key = "slipgun_zm";
			break;
		case "blunder":
			// if (is_mob())
				key = "blundergat_zm";
			break;
		case "paralyzer":
			// if (is_buried())
				key = "slowgun_zm";
			break;

		case "ak47":
			// if (is_mob())
				key = "ak47_zm";
			break;
		case "an94":
			key = "an94_zm";
			break;
		case "barret":
			// if (is_town() || is_farm() || is_depot() || is_tranzit() || is_nuketown() || is_die_rise() || is_mob() || is_buried())
				key = "barretm82_zm";
			break;
		case "b23r":
			key = "beretta93r_zm";
			break;
		case "b23re"
			// if (is_origins())
				key = "beretta93r_extclip_zm";
			break;
		case "dsr":
			key = "dsr50_zm";
			break;
		case "evo":
			// if (is_origins())
				key = "evoskorpion_zm";
			break;
		case "57":
			// if (is_town() || is_farm() || is_depot() || is_tranzit() || is_nuketown() || is_die_rise() || is_buried())
				key = "fiveseven_zm";
			break;
		case "257":
			key = "fivesevendw_zm";
			break;
		case "fal":
			key = "fnfal_zm";
			break;
		case "galil":
			key = "galil_zm";
			break;
		case "mtar":
			// if (is_town() || is_farm() || is_depot() || is_tranzit() || is_nuketown() || is_die_rise() || is_mob() || is_buried())
				key = "tar21_zm";
			break;
		case "hamr":
			// if (is_town() || is_farm() || is_depot() || is_tranzit() || is_nuketown() || is_die_rise() || is_buried() || is_origins())
				key = "hamr_zm";
			break;
		case "m27":
			if (is_nuketown())
				key = "hk416_zm";
			break;
		case "exe":
			// if (is_town() || is_farm() || is_depot() || is_tranzit() || is_nuketown() || is_die_rise() || is_mob() || is_buried())
				key = "judge_zm";
			break;
		case "kap":
			key = "kard_zm";
			break;
		case "bk":
			// if (is_town() || is_farm() || is_depot() || is_tranzit() || is_nuketown() || is_die_rise() || is_buried())
				key = "knife_ballistic_zm";
			break;
		case "ksg":
			// if (is_origins())
				key = "ksg_zm";
			break;
		case "wm":
			// if (is_town() || is_farm() || is_depot() || is_tranzit() || is_nuketown() || is_die_rise() || is_buried() || is_origins())
				key = "m32_zm";
			break;
		case "mg":
			// if (is_origins())
				key = "mg08_zm";
			break;
		case "lsat":
			// if (is_nuketown() || is_mob())
				key = "lsat_zm";
			break;
		case "dm":
			// if (is_mob())
				key = "minigun_alcatraz_zm";
		case "mp40":
			// if (is_origins())
				key = "mp40_stalker_zm";
			break;
		case "pdw":
			// if (is_mob() || is_origins())
				key = "pdw57_zm";
			break;
		case "pyt":
			// if (is_town() || is_farm() || is_depot() || is_tranzit() || is_nuketown() || is_die_rise() || is_origins())
				key = "python_zm";
			break;
		case "rnma":
			// if (is_buried())
				key = "rnma_zm";
			break;
		case "type":
			// if (is_town() || is_farm() || is_depot() || is_tranzit() || is_nuketown() || is_die_rise() || is_origins())
				key = "type95_zm";
			break;
		case "rpd":
			// if (is_town() || is_farm() || is_depot() || is_tranzit() || is_nuketown() || is_die_rise())
				key = "rpd_zm";
			break;
		case "s12":
			// if (is_town() || is_farm() || is_depot() || is_tranzit() || is_nuketown() || is_die_rise() || is_mob() || is_buried())
				key = "saiga12_zm";
			break;
		case "scar":
			// if (is_origins())
				key = "scar_zm";
			break;
		case "m1216":
			// if (is_town() || is_farm() || is_depot() || is_tranzit() || is_nuketown() || is_die_rise() || is_buried() || is_origins())
				key = "srm1216_zm";
			break;
		case "tommy":
			// if (is_mob())
				key = "thompson_zm";
			break;
		case "chic":
			// if (is_town() || is_farm() || is_depot() || is_tranzit() || is_nuketown() || is_die_rise() || is_origins())
				key = "qcw05_zm";
			break;
		case "rpg":
			// if (is_town() || is_farm() || is_depot() || is_tranzit() || is_nuketown() || is_die_rise() || is_mob() || is_buried())
				key = "usrpg_zm";
			break;
		case "m8":
			// if (is_town() || is_farm() || is_depot() || is_tranzit() || is_nuketown() || is_die_rise())
				key = "xm8_zm";
			break;
		case "m16":
			key = "m16_zm";
			break;
		case "remington":
			key = "870mcs_zm";
			break;
		case "oly":
		case "olympia":
			key = "rottweil72_zm";
			break;
		case "mp5":
			key = "mp5k_zm";
			break;
		case "ak74":
			key = "ak74u_zm";
			break;
	}

	if (isDefined(verifier))
		key = [[verifier]](key);

	debug_print("FIRST BOX: weapon_key: " + key);
	return key;
}

verify_weapon_key_box(weapon_key)
{
	if (isDefined(level.zombie_weapons[weapon_key]) && level.zombie_weapons[weapon_key].is_in_box)
		return weapon_key;
	return "";
}

verify_weapon_key_fridge(weapon_key)
{
    weapon_key = get_base_weapon_name(weapon_key, 1);

    if (!is_weapon_included(weapon_key))
        return "";

    if (is_offhand_weapon(weapon_key) || is_limited_weapon(weapon_key))
        return "";

    return weapon_key;
}

verify_weapon_key_fridge_pap()
{
    weapon_key = verify_weapon_key_fridge(weapon_key);
	if (weapon_key)
		return level.zombie_weapons[weapon_key].upgrade_name;
	return "";
}

weapon_display_wrapper(weapon_key)
{
	if (weapon_key == "emp_grenade_zm")
		return "Emp Grenade";
	if (weapon_key == "cymbal_monkey_zm")
		return "Cymbal Monkey";
	
	return get_weapon_display_name(weapon_key);
}

hide_in_afterlife(hud)
{
	if (self.afterlife)
		hud.alpha = 0;
	else
		hud.alpha = 1;
}

pull_character_preset(character_index)
{
	preset = array();
	preset["model"] = undefined;
	preset["viewmodel"] = undefined;
	preset["favourite_wall_weapons"] = undefined;
	preset["whos_who_shader"] = undefined;
	preset["talks_in_danger"] = undefined;
	preset["rich_sq_player"] = undefined;
	preset["character_name"] = undefined;
	preset["has_weasel"] = undefined;
	preset["voice"] = undefined;
	preset["is_female"] = 0;

	if (is_tranzit() || is_die_rise() || is_buried())
	{
		if (character_index == 0)
		{
			preset["model"] = "c_zom_player_oldman_fb";
			preset["viewmodel"] = "c_zom_oldman_viewhands";
			preset["favourite_wall_weapons"] = array("frag_grenade_zm", "claymore_zm");
			preset["whos_who_shader"] = "c_zom_player_oldman_dlc1_fb";
			preset["character_name"] = "Russman";

			if (is_die_rise())
				preset["model"] = "c_zom_player_oldman_dlc1_fb";
		}

		else if (character_index == 1)
		{
			preset["model"] = "c_zom_player_reporter_fb";
			preset["viewmodel"] = "c_zom_reporter_viewhands";
			preset["favourite_wall_weapons"] = array("beretta93r_zm");
			preset["whos_who_shader"] = "c_zom_player_reporter_dlc1_fb";
			preset["talks_in_danger"] = 1;
			preset["rich_sq_player"] = 1;
			preset["character_name"] = "Stuhlinger";

			if (is_die_rise())
				preset["model"] = "c_zom_player_reporter_dlc1_fb";
		}

		else if (character_index == 2)
		{
			preset["model"] = "c_zom_player_farmgirl_fb";
			preset["viewmodel"] = "c_zom_farmgirl_viewhands";
			preset["is_female"] = 1;
			preset["favourite_wall_weapons"] = array("rottweil72_zm", "870mcs_zm");
			preset["whos_who_shader"] = "c_zom_player_farmgirl_dlc1_fb";
			preset["character_name"] = "Misty";

			if (is_die_rise())
				preset["model"] = "c_zom_player_farmgirl_dlc1_fb";
		}

		else if (character_index == 3)
		{
			preset["model"] = "c_zom_player_engineer_fb";
			preset["viewmodel"] = "c_zom_engineer_viewhands";
			preset["favourite_wall_weapons"] = array("m14_zm", "m16_zm");
			preset["whos_who_shader"] = "c_zom_player_engineer_dlc1_fb";
			preset["character_name"] = "Marlton";

			if (is_die_rise())
				preset["model"] = "c_zom_player_engineer_dlc1_fb";
		}
	}

	else if (is_town() || is_farm() || is_depot() || is_nuketown())
	{
		if (character_index == 0)
		{
			preset["model"] = "c_zom_player_cia_fb";
			preset["viewmodel"] = "c_zom_suit_viewhands";
		}

		else if (character_index == 1)
		{
			preset["model"] = "c_zom_player_cdc_fb";
			preset["viewmodel"] = "c_zom_hazmat_viewhands";

			if (is_nuketown())
				preset["viewmodel"] = "c_zom_hazmat_viewhands_light";
		}
	}

	else if (is_mob())
	{
		if (character_index == 0)
		{
			preset["model"] = "c_zom_player_oleary_fb";
			preset["viewmodel"] = "c_zom_oleary_shortsleeve_viewhands";
			preset["favourite_wall_weapons"] = array("judge_zm");
			preset["character_name"] = "Finn";
		}

		else if (character_index == 1)
		{
			preset["model"] = "c_zom_player_deluca_fb";
			preset["viewmodel"] = "c_zom_deluca_longsleeve_viewhands";
			preset["favourite_wall_weapons"] = array("thompson_zm");
			preset["character_name"] = "Sal";
		}

		else if (character_index == 2)
		{
			preset["model"] = "c_zom_player_handsome_fb";
			preset["viewmodel"] = "c_zom_handsome_sleeveless_viewhands";
			preset["favourite_wall_weapons"] = array("blundergat_zm");
			preset["character_name"] = "Billy";
		}

		else if (character_index == 3)
		{
			preset["model"] = "c_zom_player_arlington_fb";
			preset["viewmodel"] = "c_zom_arlington_coat_viewhands";
			preset["favourite_wall_weapons"] = array("ray_gun_zm");
			preset["character_name"] = "Arlington";
			preset["has_weasel"] = 1;
		}
	}

	else if (is_origins())
	{
		if (character_index == 0)
		{
			preset["model"] = "c_zom_tomb_dempsey_fb";
			preset["viewmodel"] = "c_zom_dempsey_viewhands";
			preset["character_name"] = "Dempsey";
		}

		else if (character_index == 1)
		{
			preset["model"] = "c_zom_tomb_nikolai_fb";
			preset["viewmodel"] = "c_zom_nikolai_viewhands";
			preset["character_name"] = "Nikolai";
			preset["voice"] = "russian";
		}

		else if (character_index == 2)
		{
			preset["model"] = "c_zom_tomb_richtofen_fb";
			preset["viewmodel"] = "c_zom_richtofen_viewhands";
			preset["character_name"] = "Richtofen";
		}

		else if (character_index == 3)
		{
			preset["model"] = "c_zom_tomb_takeo_fb";
			preset["viewmodel"] = "c_zom_takeo_viewhands";
			preset["character_name"] = "Nikolai";
		}
	}

	return preset;
}

set_characters()
{
	level endon("end_game");
	self endon("disconnect");

	player_id = self.clientid;
	if (player_id > 3)
		player_id -= 4;

	dvar = "frfix_player" + player_id + "_character";
	if (isDefined(getDvar(dvar)) && getDvar(dvar))
	{
		prop = pull_character_preset(getDvarInt(dvar));

		self setmodel(prop["model"]);
		self setviewmodel(prop["viewmodel"]);
		self set_player_is_female(prop["is_female"]);
		self.characterindex = getDvarInt(dvar);

		if (isDefined(prop["favourite_wall_weapons"]))
			self.favorite_wall_weapons_list = prop["favourite_wall_weapons"];
		if (isDefined(prop["whos_who_shader"]))
			self.whos_who_shader = prop["whos_who_shader"];
		if (isDefined(prop["talks_in_danger"]))
			self.talks_in_danger = prop["talks_in_danger"];
		if (isDefined(prop["rich_sq_player"]))
			level.rich_sq_player = self;
		if (isDefined(prop["character_name"]))
			self.character_name = prop["character_name"];
		if (isDefined(prop["has_weasel"]))
			level.has_weasel = prop["has_weasel"];
		if (isDefined(prop["voice"]))
			self.voice = prop["voice"];

		debug_print("Read value '" + getDvar(dvar) + "' from dvar '" + dvar + "' for player '" + self.name + "' with ID '" + self.clientid + "' Set character '" + prop["model"] + "'");
	}
}
