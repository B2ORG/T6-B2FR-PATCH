#define DEBUG 0
#define BETA 0
#define NOHUD 0
#define PLUTO_CLI 1

#include common_scripts\utility;
#include maps\mp\gametypes_zm\_hud_util;
#include maps\mp\zombies\_zm_utility;

main()
{
	replaceFunc(maps\mp\animscripts\zm_utility::wait_network_frame, ::fixed_wait_network_frame);
	replaceFunc(maps\mp\zombies\_zm_utility::wait_network_frame, ::fixed_wait_network_frame);

	replaceFunc(maps\mp\zombies\_zm_weapons::get_pack_a_punch_weapon_options, ::get_pap_weapon_options_set_reticle);
}

init()
{
	flag_init("game_started");
	flag_init("box_rigged");
	flag_init("permaperks_were_set");

	// Patch Config
	level.B2FR_VERSION = 1.2;

	level thread on_game_start();
}

on_game_start()
{
	level endon("end_game");

	level thread set_dvars();
	level thread on_player_joined();
    level thread origins_fix();

	flag_wait("initial_blackscreen_passed");

    level.B2FR_START = int(getTime() / 1000);
	flag_set("game_started");

	b2safety();

    level thread b2fr_main_loop();
#if NOHUD == 0
	level thread timers();
    level thread semtex_display();
    if (isDefined(level.B2_NETWORK_HUD))
        level thread [[level.B2_NETWORK_HUD]]();
#endif
	level thread perma_perks_setup();

	level thread nuketown_handler();
	level thread topbarn_controller();

    if (isDefined(level.B2_POWERUP_TRACKING))
        level thread [[level.B2_POWERUP_TRACKING]]();

	level thread [[level.GAMEPLAY_REMINDER]]();

#if DEBUG == 1
	debug_mode();
#endif
#if BETA == 1
	beta_mode();
#endif
}

on_player_joined()
{
	level endon("end_game");

	while(true)
	{
		level waittill("connected", player);
		player thread on_player_spawned();
		player thread on_player_spawned_permaperk();
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
	self thread evaluate_network_frame();
	self thread set_characters();

#if NOHUD == 0
	self thread velocity_meter();

	if (isDefined(level.B2_ZONES))
		self thread [[level.B2_ZONES]]();
#endif
}

on_player_spawned_permaperk()
{
	level endon("end_game");
    self endon("disconnect");

	/* We want to remove the perks before players spawn to prevent health bonus 
	The wait is essential, it allows the game to process permaperks internally before we override them */
	wait 2;

	if (has_permaperks_system())
	{
		self remove_permaperk_wrapper("jugg", 15);
		if (is_buried())
			self remove_permaperk_wrapper("nube", 10);
		else 
			self remove_permaperk_wrapper("nube");
	}
}

b2fr_main_loop()
{
    level endon("end_game");

    while (true)
    {
        level waittill("start_of_round");
#if NOHUD == 0
        level thread show_hordes();
#endif

        /* Verify based on map, cause someone could sneak a patch that'd give those in offline game */
		if (is_tranzit() || is_die_rise() || is_buried())
		{
			wait 2;
			foreach(player in level.players)
			{
				player remove_permaperk_wrapper("jugg", 15);
				player remove_permaperk_wrapper("nube", 10);
			}
		}

        /* Check first box each round */
        scan_in_box();

        /* Check gamerules */
        if (getgametypesetting("startRound") > 1 && (is_tranzit() || is_mob() || is_die_rise() || is_mob() || is_buried() || is_origins()))
            generate_watermark("STARTING ROUND", (1, 0, 0), 0.5);
        else if (getgametypesetting("startRound") > 10 && (is_depot() || is_town() || is_farm() || is_nuketown()))
            generate_watermark("STARTING ROUND", (1, 0, 0), 0.5);
        if (!is_true(level.gamedifficulty))
            generate_watermark("DIFFICULTY", (1, 0, 0), 0.5);

        level waittill("end_of_round");
		if (isDefined(level.B2FR_CHECK))
			level.B2FR_CHECK = undefined;
#if NOHUD == 0
        level thread show_split();
#endif
        if (has_permaperks_system())
            setDvar("award_perks", 1);
    }
}

debug_print(text)
{
#if DEBUG == 1 && PLUTO_CLI == 1
	print("DEBUG: " + text);
#endif
}
info_print(text)
{
#if PLUTO_CLI == 1
	print("INFO: " + text);
#endif
}

generate_watermark_slots()
{
	slots = array();

	positions = array(0, -90, 90, -180, 180, -270, 270, -360, 360, -450, 450, -540, 540, -630, 630);

	foreach(pos in positions)
	{
		i = slots.size;
		slots[i] = array();
		slots[i]["pos"] = pos;
		slots[i]["perm_on"] = false;
		slots[i]["temp_on"] = false;
	}

	level.set_of_slots = slots;
}

get_watermark_position(mode)
{
	mode += "_on";
	for (i = 0; i < level.set_of_slots.size; i++)
	{
		if (!level.set_of_slots[i][mode])
		{
			level.set_of_slots[i][mode] = true;
			pos = level.set_of_slots[i]["pos"];
			if (pos < 640 && pos > -640)
				return pos;
			return 0;
		}
	}
	return 0;
}

generate_watermark(text, color, alpha_override)
{
	if (is_true(flag(text)))
		return;

    if (!isDefined(level.set_of_slots))
        generate_watermark_slots();

	x_pos = get_watermark_position("perm");
	if (!isDefined(x_pos))
		return;

	if (!isDefined(color))
		color = (1, 1, 1);

	if (!isDefined(alpha_override))
		alpha_override = 0.33;

    watermark = createserverfontstring("hudsmall" , 1.2);
	watermark setPoint("CENTER", "TOP", x_pos, -5);
	watermark.color = color;
	watermark setText(text);
	watermark.alpha = alpha_override;
	watermark.hidewheninmenu = 0;

	flag_set(text);

	if (!isDefined(level.num_of_watermarks))
		level.num_of_watermarks = 0;
    level.num_of_watermarks++;
}

generate_temp_watermark(kill_on, text, color, alpha_override)
{
	level endon("end_game");

	if (is_true(flag(text)))
		return;

    if (!isDefined(level.set_of_slots))
        generate_watermark_slots();

	x_pos = get_watermark_position("temp");
	if (!isDefined(x_pos))
		return;

	if (!isDefined(color))
		color = (1, 1, 1);

	if (!isDefined(alpha_override))
		alpha_override = 0.33;

    twatermark = createserverfontstring("hudsmall" , 1.2);
	twatermark setPoint("CENTER", "TOP", x_pos, -17);
	twatermark.color = color;
	twatermark setText(text);
	twatermark.alpha = alpha_override;
	twatermark.hidewheninmenu = 0;

	flag_set(text);

	while (level.round_number < kill_on)
		level waittill("end_of_round");

	twatermark.alpha = 0;
	twatermark destroy_hud();

	/* Cleanup slots array if there are no huds to track */
	for (i = 0; i < level.set_of_slots.size; i++)
	{
		if (level.set_of_slots[i]["pos"] == x_pos)
			level.set_of_slots[i]["temp_on"] = false;
	}

	/* There should've been flag_clear here, but don't add it anymore, since it's now used
	for appending first box info to splits */
}

print_scheduler(content, player)
{
    if (isDefined(player))
	{
        player thread player_print_scheduler(content);
	}
    else
	{
        foreach (player in level.players)
            player thread player_print_scheduler(content);
	}
}

player_print_scheduler(content)
{
    level endon("end_game");
    self endon("disconnect");

    while (isDefined(self.scheduled_prints) && self.scheduled_prints >= getDvarInt("con_gameMsgWindow0LineCount"))
        wait 0.05;

    if (isDefined(self.scheduled_prints))
        self.scheduled_prints++;
    else
        self.scheduled_prints = 1;

    self iPrintLn(content);
    wait_for_message_end();
    self.scheduled_prints--;

    if (self.scheduled_prints <= 0)
        self.scheduled_prints = undefined;
}

convert_time(seconds)
{
	hours = 0;
	minutes = 0;
	
	if (seconds > 59)
	{
		minutes = int(seconds / 60);

		seconds = int(seconds * 1000) % (60 * 1000);
		seconds = seconds * 0.001;

		if (minutes > 59)
		{
			hours = int(minutes / 60);
			minutes = int(minutes * 1000) % (60 * 1000);
			minutes = minutes * 0.001;
		}
	}

	str_hours = hours;
	if (hours < 10)
		str_hours = "0" + hours;

	str_minutes = minutes;
	if (minutes < 10 && hours > 0)
		str_minutes = "0" + minutes;

	str_seconds = seconds;
	if (seconds < 10)
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

	return is_rnd;
}

is_plutonium()
{
	/* Returns true for Pluto versions r2693 and above */
	if (getDvar("cg_weaponCycleDelay") == "")
		return false;
	return true;
}

safe_restart()
{
	if (is_plutonium())
		map_restart();
	else
		level notify("end_game");
}

has_magic()
{
    if (is_true(level.enable_magic))
        return true;
    return false;
}

has_permaperks_system()
{
#if DEBUG == 1
    // debug_print("has_permaperks_system()=" + (isDefined(level.pers_upgrade_boards) && is_true(level.onlinegame)));
#endif
	/* Refer to init_persistent_abilities() */
	if (isDefined(level.pers_upgrade_boards) && is_true(level.onlinegame))
		return true;
	return false;
}

is_special_round()
{
	if (is_true(flag("dog_round")))
		return true;

	if (is_true(flag("leaper_round")))
		return true;

	return false;
}

get_zombies_left()
{
	return get_round_enemy_array().size + level.zombie_total;
}

get_hordes_left()
{
	return int((get_zombies_left() / 24) * 100) / 100;
}

wait_for_message_end()
{
	wait getDvarFloat("con_gameMsgWindow0FadeInTime") + getDvarFloat("con_gameMsgWindow0MsgTime") + getDvarFloat("con_gameMsgWindow0FadeOutTime");
}

set_hud_properties(hud_key, x_align, y_align, x_pos, y_pos, col)
{
	if (!isDefined(col))
		col = (1, 1, 1);

	if (isDefined(level.B2_HUD))
	{
		data = level.B2_HUD[hud_key];
		if (isDefined(data))
		{
			if (isDefined(data["x_align"]))
				x_align = data["x_align"];
			if (isDefined(data["y_align"]))
				y_align = data["y_align"];
			if (isDefined(data["x_pos"]))
				x_pos = data["x_pos"];
			if (isDefined(data["y_pos"]))
				y_pos = data["y_pos"];
			if (isDefined(data["color"]))
				col = data["color"];
		}
	}

	res_components = strTok(getDvar("r_mode"), "x");
	ratio = int((int(res_components[0]) / int(res_components[1])) * 100);
	aspect_ratio = 1609;
	switch (ratio)
	{
		case 160:       // 16:10
			aspect_ratio = 1610;
			break;
		case 125:       // 5:4
		case 133:       // 4:3
        case 149:       // 3:2
        case 150:       // 3:2
			aspect_ratio = 43;
			break;
		case 237:       // 21:9
        case 238:       // 21:9
        case 240:       // 21:9
        case 355:       // 32:9
			aspect_ratio = 2109;
			break;
	}

	if (x_pos == int(x_pos))
		x_pos = recalculate_x_for_aspect_ratio(x_align, x_pos, aspect_ratio);

#if DEBUG == 1
	// debug_print("ratio: " + ratio + " | aspect_ratio: " + aspect_ratio + " | x_pos: " + x_pos + " | w: " + res_components[0] + " | h: " + res_components[1]);
#endif

	self setpoint(x_align, y_align, x_pos, y_pos);
	self.color = col;
}

recalculate_x_for_aspect_ratio(xalign, xpos, aspect_ratio)
{
    if (level.players.size > 1)
        return xpos;

	if (isSubStr(tolower(xalign), "left") && xpos < 0)
	{
		if (aspect_ratio == 1610)
			return xpos + 6;
		if (aspect_ratio == 43)
			return xpos + 14;
		if (aspect_ratio == 2109)
			return xpos - 21;
	}

	else if (isSubStr(tolower(xalign), "right") && xpos > 0)
	{
		if (aspect_ratio == 1610)
			return xpos - 6;
		if (aspect_ratio == 43)
			return xpos - 14;
		if (aspect_ratio == 2109)
			return xpos + 21;
	}

	return xpos;
}

emulate_menu_call(content, ent)
{
	if (!isDefined(ent))
		ent = maps\mp\_utility::gethostplayer();

	ent notify ("menuresponse", "", content);
}

welcome_prints()
{
	wait 0.75;
#if NOHUD == 1
	self iPrintLn("B2^1FR^7 PATCH ^1V" + level.B2FR_VERSION + " ^7[NOHUD]");
#else
	self iPrintLn("B2^1FR^7 PATCH ^1V" + level.B2FR_VERSION);
#endif
	wait 0.75;
	self iPrintLn("Source: ^1github.com/B2ORG/T6-B2FR-PATCH");
}

gameplay_reminder()
{
	level endon("end_game");

	wait 1;

	if (level.players.size > 1)
	{
		print_scheduler("^1REMINDER ^7You are a host", maps\mp\_utility::gethostplayer());
		wait 0.25;
		print_scheduler("Full gameplay is required from host perspective as of April 2023", maps\mp\_utility::gethostplayer());
	}
}

set_dvars()
{
	level endon("end_game");

	/* Wait should help when in some instances foreign scripts try to mess with backspeed */
	wait 0.05;

	if (is_tranzit() || is_die_rise() || is_mob() || is_buried())
    	level.round_start_custom_func = ::trap_fix;

    /* Rules used in init_dvar() used to disable b2fr dvar by default
    Try not to use init_dvar() outside of this function, in which case dvar_rules
    has to become a level variable and be manually removed later */
    dvar_rules = array();

    if (has_permaperks_system())
        init_dvar("award_perks", dvar_rules);

    setdvar("player_strafeSpeedScale", 0.8);
    setdvar("player_backSpeedScale", 0.7);
    setdvar("g_speed", 190);
    setdvar("con_gameMsgWindow0Filter", "gamenotify obituary");
    setdvar("sv_cheats", 0);
	setdvar("sv_endGameIfISuck", 0); 		// Prevent host migration
	setdvar("sv_allowAimAssist", 0); 	 	// Removes target assist
	setdvar("sv_patch_zm_weapons", 1);		// Force post dlc1 patch on recoil
	setdvar("r_dof_enable", 0);				// Remove Depth of Field

	level.GAMEPLAY_REMINDER = ::gameplay_reminder;

    level thread dvar_watcher(array("sv_cheats", "g_speed", "player_strafeSpeedScale", "player_backSpeedScale", "con_gameMsgWindow0Filter"));
}

dvar_watcher(dvars)
{
    level endon("end_game");

	flag_wait("initial_blackscreen_passed");

    values = array();
    foreach (dvar in dvars)
        values[dvar] = getDvar(dvar);

    while (true)
    {
        foreach (dvar in dvars)
        {
            if (getDvar(dvar) != values[dvar])
            {
                generate_watermark("DVAR " + ToUpper(dvar) + " VIOLATED", (1, 0.6, 0.2), 0.66);
                ArrayRemoveIndex(dvars, dvar, true);
            }
        }

        wait 0.25;
    }
}

/* It's not explicit, but dvar_rules is optional arg, as long as it's only call remains inside of is_true() */
init_dvar(dvar_str, dvar_rules)
{
	if (getDvar(dvar_str) != "")
		return;

    setDvar(dvar_str, "1");
	if (is_true(dvar_rules[dvar_str]))
		setDvar(dvar_str, "0");
}

award_points(amount)
{
	level endon("end_game");
	self endon("disconnect");

	if (is_mob())
		flag_wait("afterlife_start_over");
	self.score = amount;
}

b2safety()
{
	if (isDefined(level.SONG_TIMING) || isDefined(level.B2SONG_CONFIG))
	{
		print_scheduler("^1B2SONG DETECTED!!!");
		emulate_menu_call("endround");
	}

	if (isDefined(level.FRFIX_CONFIG))
	{
		print_scheduler("^1OLD FIRST ROOM FIX DETECTED!!!");
		emulate_menu_call("endround");
	}

	if (isDefined(level.B2FR_CHECK))
	{
		print_scheduler("^1ANOTHER B2FR DETECTED!!!");
		emulate_menu_call("endround");
	}
	level.B2FR_CHECK = true;

	if (isDefined(level.B2OP_CONFIG))
	{
		print_scheduler("^1B2OP DETECTED!!!");
		emulate_menu_call("endround");
	}
}

#if DEBUG == 1
debug_mode()
{
	foreach(player in level.players)
		player thread award_points(333333);
	generate_watermark("DEBUGGER", (0.8, 0.8, 0));
}
#endif

#if BETA == 1
beta_mode()
{
	generate_watermark("BETA", (0, 0.8, 0));
}
#endif

evaluate_network_frame()
{
	level endon("end_game");
	self endon("disconnect");

	flag_wait("initial_blackscreen_passed");

	start_time = int(getTime());
	wait_network_frame();
	end_time = int(getTime());
	network_frame_len = (end_time - start_time) / 1000;
    net_frame_good = false;

    /* To avoid direct float equality evaluation */
    if (level.players.size == 1)
    {
        if (network_frame_len > 0.06 && network_frame_len < 0.14)
            net_frame_good = true;
    }
    else
    {
        if (network_frame_len < 0.09)
            net_frame_good = true;
    }

    if (net_frame_good)
    {
        print_scheduler("Network Frame: ^2GOOD", self);
    }
    /* Being extremely nice about it, but after 15 it's fair to say they play on bad network frame */
    else if (!is_round(15))
    {
        print_scheduler("Network Frame: ^1BAD", self);
		level waittill("start_of_round");
		self thread evaluate_network_frame();
    }
    else
    {
        generate_watermark("NETWORK FRAME", (0.8, 0, 0), 0.66);
    }
}

trap_fix()
{
    rnd_155 = 1044606905;

    if (level.zombie_health <= rnd_155)
        return;

    level.zombie_health = rnd_155;

    foreach (zombie in get_round_enemy_array())
    {
        if (zombie.health > rnd_155)
            zombie.heath = rnd_155;
    }
}

#if NOHUD == 0
timers()
{
    level endon("end_game");

    level.timer_hud = createserverfontstring("big" , 1.6);
	level.timer_hud set_hud_properties("timer_hud", "TOPRIGHT", "TOPRIGHT", 60, -14);
	level.timer_hud.alpha = 1;
    level.timer_hud setTimerUp(0);

	level.round_hud = createserverfontstring("big" , 1.6);
	level.round_hud set_hud_properties("round_hud", "TOPRIGHT", "TOPRIGHT", 60, 3);
	level.round_hud.alpha = 1;
    level.round_hud setText("0:00");

    level waittill("start_of_round");
    while (isDefined(level.round_hud))
	{
		round_start = int(getTime() / 1000);
        level.round_hud setTimerUp(0);

		level waittill("end_of_round");
		round_end = int(getTime() / 1000) - round_start;

		level.round_hud keep_displaying_old_time(round_end);
	}
}

keep_displaying_old_time(time)
{
    level endon("end_game");
    level endon("start_of_round");

    while (true)
    {
        self setTimer(time - 0.1);
        wait 0.25;
    }
}

show_split()
{
	level endon("end_game");

	split_rounds = array(15, 20, 25, 30, 35, 40, 45, 50, 60, 70, 80, 90, 100);
	if (isDefined(level.B2_SPLITS))
		split_rounds = level.B2_SPLITS;

	if (!IsInArray(split_rounds, level.round_number))
		return;
	wait 6.25;

    timestamp = convert_time(int(getTime() / 1000) - level.B2FR_START);
    print_scheduler("Round " + level.round_number + " time: ^1" + timestamp);
}

show_hordes()
{
	level endon("end_game");

    wait 0.05;

    if (!is_special_round() && is_round(20))
    {
        zombies_value = get_hordes_left();
        print_scheduler("HORDES ON " + level.round_number + ": ^3" + zombies_value);
    }
}

velocity_meter()
{
    self endon("disconnect");
    level endon("end_game");

    player_wait_for_initial_blackscreen();

    self.hud_velocity = createfontstring("default" , 1.1);
	self.hud_velocity set_hud_properties("hud_velocity", "CENTER", "CENTER", "CENTER", 200);
	self.hud_velocity.alpha = 0.75;
	self.hud_velocity.hidewheninmenu = 1;

    while (true)
    {
        self velocity_visible(self.hud_velocity);

		velocity = int(length(self getvelocity() * (1, 1, 1)));
		if (!self isOnGround())
			velocity = int(length(self getvelocity() * (1, 1, 0)));

		self.hud_velocity velocity_meter_scale(velocity);
        self.hud_velocity setValue(velocity);

        wait 0.05;
    }
}

velocity_visible(hud)
{
    if (is_true(self.afterlife))
        hud.alpha = 0;
    else
        hud.alpha = 1;
}

velocity_meter_scale(vel)
{
	self.color = (0.6, 0, 0);
	self.glowcolor = (0.3, 0, 0);

	if (vel < 330)
	{
		self.color = (0.6, 1, 0.6);
		self.glowcolor = (0.4, 0.7, 0.4);
	}

	else if (vel <= 340)
	{
		self.color = (0.8, 1, 0.6);
		self.glowcolor = (0.6, 0.7, 0.4);
	}

	else if (vel <= 350)
	{
		self.color = (1, 1, 0.6);
		self.glowcolor = (0.7, 0.7, 0.4);
	}

	else if (vel <= 360)
	{
		self.color = (1, 0.8, 0.4);
		self.glowcolor = (0.7, 0.6, 0.2);
	}

	else if (vel <= 370)
	{
		self.color = (1, 0.6, 0.2);
		self.glowcolor = (0.7, 0.4, 0.1);
	}

	else if (vel <= 380)
	{
		self.color = (1, 0.2, 0);
		self.glowcolor = (0.7, 0.1, 0);
	}
}

semtex_display()
{
	level endon("end_game");

	// Town for Semtex, Nuketown for No Magic
	if (has_magic() || (!is_town() && !is_nuketown()))
		return;

	self thread notify_about_prenade_switch();

	num_of_prenades = 0;

	while (true)
	{
		level waittill("start_of_round");
		wait 0.05;

		num_of_prenades = [[get_prenade_mode()]](num_of_prenades);

		if (!num_of_prenades)
			continue;

		print_content = "PRENADES ON " + level.round_number + ": ^3" + num_of_prenades;
		print_scheduler(print_content);
		wait_for_message_end();
		self thread semtex_print_on_demand(print_content);

		print_content = undefined;
	}
}

semtex_print_on_demand(to_print)
{
	level endon("end_game");
	level endon("end_of_round");

	while (is_plutonium())
	{
		level waittill("say", text, player);

		if (text == "prenades" || text == "p")
		{
			print_scheduler(to_print);
			wait_for_message_end();
		}

		text = undefined;
	}
}

get_prenade_mode(switch_round)
{
	if (!isDefined(switch_round))
		switch_round = 51;

	if (is_round(switch_round))
	{
		self notify("changed_prenade_type", "DYNAMIC");
		return ::get_prenade_dynamic;
	}
	return ::get_prenade_from_map;
}

get_prenade_from_map(stub_arg)
{
	nade_array = array(1, 2, 3, 4, 5, 7, 8, 9, 10, 12, 13, 17, 19, 22, 24, 28, 29, 34, 39, 42, 46, 52, 57, 61, 69, 78, 86, 96, 103);
	nade_map = array();
	for (i = 0; i < nade_array.size; i++)
	{
		index = 22 + i;
		nade_map[index] = nade_array[i]; 
	}

	if (isDefined(nade_map[level.round_number]))
	{
		return nade_map[level.round_number];
	}
	return 0;
}

get_prenade_dynamic(previous)
{
	level endon("end_game");

	// Failsafe for starting game at 50 or higher
	if (!previous)
		previous = 103;

	calculated_round = level.round_number + 1;
	dmg_curve = int((-0.958 * 128) + 300);
	dmg_semtex = int(dmg_curve + 150 + calculated_round);

	zm_health = int(level.zombie_health * 1.1) - (dmg_semtex * previous);

	i = 0;
	while (dmg_semtex / zm_health < 0.1)
	{
		zm_health -= dmg_semtex;
		previous += 1;

		if (i >= 20)
		{
			i = 0;
			wait 0.05;
		}

		i++;
	}

	return previous; 
}

notify_about_prenade_switch()
{
	level endon("end_game");

	self waittill("changed_prenade_type", prenade_type);
	print_scheduler("Prenade values generation is now: ^3" + prenade_type);
}
#endif

perma_perks_setup()
{
	if (!has_permaperks_system())
		return;

    if (getDvar("award_perks") == "1")
	{
		setDvar("award_perks", 0);
		thread watch_permaperk_award();

		foreach (player in level.players)
		{
			player.permaperk_display_lock = true;
			player thread award_permaperks_safe();
		}
	}

#if NOHUD == 0
	array_thread(level.players, ::permaperks_watcher);
#endif
}

watch_permaperk_award()
{
	level endon("end_game");

	present_players = level.players.size;

	while (true)
	{
		i = 0;
		foreach (player in level.players)
		{
			if (!isDefined(player.awarding_permaperks_now))
				i++;
		}

		if (i == present_players && flag("permaperks_were_set"))
		{
			print_scheduler("Permaperks Awarded - ^1RESTARTING");
			wait 1;

            emulate_menu_call("restart_level_zm");
			break;
		}

		if (!did_game_just_start())
			break;

		wait 0.1;
	}

	foreach (player in level.players)
	{
		if (isDefined(player.awarding_permaperks_now))
			player.awarding_permaperks_now = undefined;
	}
}

permaperk_array(code, maps_award, maps_take, to_round)
{
	if (!isDefined(maps_award))
		maps_award = array("zm_transit", "zm_highrise", "zm_buried");
	if (!isDefined(maps_take))
		maps_take = array();
	if (!isDefined(to_round))
		to_round = 255;

	permaperk = array();
	permaperk["code"] = code;
	permaperk["maps_award"] = maps_award;
	permaperk["maps_take"] = maps_take;
	permaperk["to_round"] = to_round;

	return permaperk;
}

award_permaperks_safe()
{
	level endon("end_game");
	self endon("disconnect");

	while (!isalive(self))
		wait 0.05;

	wait 0.5;

	perks_to_process = array();
	perks_to_process[perks_to_process.size] = permaperk_array("revive");
	perks_to_process[perks_to_process.size] = permaperk_array("multikill_headshots");
	perks_to_process[perks_to_process.size] = permaperk_array("perk_lose");
	perks_to_process[perks_to_process.size] = permaperk_array("jugg", undefined, undefined, 15);
	perks_to_process[perks_to_process.size] = permaperk_array("flopper", array("zm_buried"));
	perks_to_process[perks_to_process.size] = permaperk_array("nube", array("zm_buried"), array("zm_transit", "zm_highrise"), 10);

	self.awarding_permaperks_now = true;

	foreach (perk in perks_to_process)
	{
		self resolve_permaperk(perk);
		wait 0.05;
	}

	wait 0.5;
	perks_to_process = undefined;
	self.awarding_permaperks_now = undefined;
	self.permaperk_display_lock = undefined;
	self maps\mp\zombies\_zm_stats::uploadstatssoon();
}

resolve_permaperk(perk)
{
	wait 0.05;

	perk_code = perk["code"];

	/* Triggers when perk is not on the map */
	if (!isDefined(self.pers_upgrades_awarded[perk_code]))
		return;

	/* Too high of a round, return out */
	if (is_round(perk["to_round"]))
		return;

#if DEBUG == 1
	// debug_print("perk = " + perk_code + " 1st eval = " + isinarray(perk["maps_award"], level.script) + " 2nd eval = " + !self.pers_upgrades_awarded[perk_code]);
#endif

	if (isinarray(perk["maps_award"], level.script) && !self.pers_upgrades_awarded[perk_code])
	{
		for (j = 0; j < level.pers_upgrades[perk_code].stat_names.size; j++)
		{
			stat_name = level.pers_upgrades[perk_code].stat_names[j];
			stat_value = level.pers_upgrades[perk_code].stat_desired_values[j];

			self award_permaperk(stat_name, perk_code, stat_value);
		}
	}

	if (isinarray(perk["maps_take"], level.script) && is_true(self.pers_upgrades_awarded[perk_code]))
		self remove_permaperk(perk_code);
}

award_permaperk(stat_name, perk_code, stat_value)
{
	flag_set("permaperks_were_set");
	self.stats_this_frame[stat_name] = 1;
	self maps\mp\zombies\_zm_stats::set_global_stat(stat_name, stat_value);
	self playsoundtoplayer("evt_player_upgrade", self);
}

/* If client stat (prefixed with 'pers_') is passed to perk_code, it tries to do it with existing system */
remove_permaperk_wrapper(perk_code, round)
{
	if (!isDefined(round))
		round = 1;

    if (is_round(round) && isSubStr(perk_code, "pers_"))
        self maps\mp\zombies\_zm_stats::zero_client_stat(perk_code, 0);
	else if (is_round(round) && is_true(self.pers_upgrades_awarded[perk_code]))
		self remove_permaperk(perk_code);
}

remove_permaperk(perk_code)
{
	self.pers_upgrades_awarded[perk_code] = 0;
	self playsoundtoplayer("evt_player_downgrade", self);
}

#if NOHUD == 0
permaperks_watcher()
{
	level endon("end_game");
	self endon("disconnect");

	self.last_perk_state = array();
	foreach(perk in level.pers_upgrades_keys)
	{
		while (!isDefined(self.pers_upgrades_awarded[perk]))
			wait 0.1;
		self.last_perk_state[perk] = self.pers_upgrades_awarded[perk];
	}

	while (true)
	{
		foreach(perk in level.pers_upgrades_keys)
		{
			if (self.pers_upgrades_awarded[perk] != self.last_perk_state[perk])
			{
				if (!is_true(self.permaperk_display_lock))
					self print_permaperk_state(self.pers_upgrades_awarded[perk], perk);
				self.last_perk_state[perk] = self.pers_upgrades_awarded[perk];
				wait 0.1;
			}
		}

		wait 0.1;
	}
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

    self iPrintLn("Permaperk " + permaperk_name(perk) + ": " + print_player);
#if DEBUG == 1
	debug_print("print_permaperk_state(): " + self.name + ": Permaperk " + perk + " -> " + print_cli);
#endif
}

permaperk_name(perk)
{
	switch (perk)
	{
		case "revive":
			return "Quick Revive";
		case "multikill_headshots":
			return "Extra Headshot Damage";
		case "perk_lose":
			return "Tombstone";
		case "jugg":
			return "Juggernog";
		case "flopper":
			return "Flopper";
		case "box_weapon":
			return "Better Mystery Box";
		case "nube":
			return "Nube";
		case "board":
			return "Metal Boards";
		case "carpenter":
			return "Metal Carpenter Boards";
		case "insta_kill":
			return "Insta-Kill Pro";
		case "cash_back":
			return "Perk Refund";
		case "pistol_points":
			return "Double Pistol Points";
		case "double_points":
			return "Half-Off";
		case "sniper":
			return "Sniper Points";
		default:
			return perk;
	}
}
#endif

origins_fix()
{
    level endon("end_game");

	flag_wait("start_zombie_round_logic");
	wait 0.5;

	if (is_origins())
		level.is_forever_solo_game = 0;
}

scan_in_box()
{
    level endon("end_game");

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

	in_box = 0;
    foreach (weapon in getarraykeys(level.zombie_weapons))
    {
        if (maps\mp\zombies\_zm_weapons::get_is_in_box(weapon))
            in_box++;
    }

	if (!isDefined(in_box) || !in_box)
		return;

    if ((in_box == should_be_in_box) || ((offset > 0) && (in_box == (should_be_in_box + offset))))
        return;

	generate_watermark("FIRST BOX", (0.5, 0.3, 0.7), 0.66);
}

pull_character_preset(character_name)
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
		switch(toLower(character_name))
		{
			case "russman":
				preset["index"] = 0;
				preset["model"] = "c_zom_player_oldman_fb";
				preset["viewmodel"] = "c_zom_oldman_viewhands";
				preset["favourite_wall_weapons"] = array("frag_grenade_zm", "claymore_zm");
				preset["whos_who_shader"] = "c_zom_player_oldman_dlc1_fb";
				preset["character_name"] = "Russman";

				if (is_die_rise())
					preset["model"] = "c_zom_player_oldman_dlc1_fb";

				break;

			case "stuhlinger":
				preset["index"] = 1;
				preset["model"] = "c_zom_player_reporter_fb";
				preset["viewmodel"] = "c_zom_reporter_viewhands";
				preset["favourite_wall_weapons"] = array("beretta93r_zm");
				preset["whos_who_shader"] = "c_zom_player_reporter_dlc1_fb";
				preset["talks_in_danger"] = 1;
				preset["rich_sq_player"] = 1;
				preset["character_name"] = "Stuhlinger";

				if (is_die_rise())
					preset["model"] = "c_zom_player_reporter_dlc1_fb";

				break;

			case "misty":
				preset["index"] = 2;
				preset["model"] = "c_zom_player_farmgirl_fb";
				preset["viewmodel"] = "c_zom_farmgirl_viewhands";
				preset["is_female"] = 1;
				preset["favourite_wall_weapons"] = array("rottweil72_zm", "870mcs_zm");
				preset["whos_who_shader"] = "c_zom_player_farmgirl_dlc1_fb";
				preset["character_name"] = "Misty";

				if (is_die_rise())
					preset["model"] = "c_zom_player_farmgirl_dlc1_fb";

				break;

			case "marlton":
				preset["index"] = 3;
				preset["model"] = "c_zom_player_engineer_fb";
				preset["viewmodel"] = "c_zom_engineer_viewhands";
				preset["favourite_wall_weapons"] = array("m14_zm", "m16_zm");
				preset["whos_who_shader"] = "c_zom_player_engineer_dlc1_fb";
				preset["character_name"] = "Marlton";

				if (is_die_rise())
					preset["model"] = "c_zom_player_engineer_dlc1_fb";
			
				break;
		}
	}

	else if (is_town() || is_farm() || is_depot() || is_nuketown())
	{
		switch(toLower(character_name))
		{
			case "cia":
				preset["index"] = 0;
				preset["model"] = "c_zom_player_cia_fb";
				preset["viewmodel"] = "c_zom_suit_viewhands";
				break;
			case "cdc":
				preset["index"] = 1;
				preset["model"] = "c_zom_player_cdc_fb";
				preset["viewmodel"] = "c_zom_hazmat_viewhands";

				if (is_nuketown())
					preset["viewmodel"] = "c_zom_hazmat_viewhands_light";

				break;
		}
	}

	else if (is_mob())
	{
		switch(toLower(character_name))
		{
			case "finn":
				preset["index"] = 0;
				preset["model"] = "c_zom_player_oleary_fb";
				preset["viewmodel"] = "c_zom_oleary_shortsleeve_viewhands";
				preset["favourite_wall_weapons"] = array("judge_zm");
				preset["character_name"] = "Finn";
				break;

			case "sal":
				preset["index"] = 1;
				preset["model"] = "c_zom_player_deluca_fb";
				preset["viewmodel"] = "c_zom_deluca_longsleeve_viewhands";
				preset["favourite_wall_weapons"] = array("thompson_zm");
				preset["character_name"] = "Sal";
				break;

			case "billy":
				preset["index"] = 2;
				preset["model"] = "c_zom_player_handsome_fb";
				preset["viewmodel"] = "c_zom_handsome_sleeveless_viewhands";
				preset["favourite_wall_weapons"] = array("blundergat_zm");
				preset["character_name"] = "Billy";
				break;

			case "arlington":
			case "weasel":
				preset["index"] = 3;
				preset["model"] = "c_zom_player_arlington_fb";
				preset["viewmodel"] = "c_zom_arlington_coat_viewhands";
				preset["favourite_wall_weapons"] = array("ray_gun_zm");
				preset["character_name"] = "Arlington";
				preset["has_weasel"] = 1;
				break;
		}
	}

	else if (is_origins())
	{
		switch(toLower(character_name))
		{
			case "dempsey":
				preset["index"] = 0;
				preset["model"] = "c_zom_tomb_dempsey_fb";
				preset["viewmodel"] = "c_zom_dempsey_viewhands";
				preset["character_name"] = "Dempsey";
				break;

			case "nikolai":
				preset["index"] = 1;
				preset["model"] = "c_zom_tomb_nikolai_fb";
				preset["viewmodel"] = "c_zom_nikolai_viewhands";
				preset["character_name"] = "Nikolai";
				preset["voice"] = "russian";
				break;

			case "richtofen":
				preset["index"] = 2;
				preset["model"] = "c_zom_tomb_richtofen_fb";
				preset["viewmodel"] = "c_zom_richtofen_viewhands";
				preset["character_name"] = "Richtofen";
				break;

			case "takeo":
				preset["index"] = 3;
				preset["model"] = "c_zom_tomb_takeo_fb";
				preset["viewmodel"] = "c_zom_takeo_viewhands";
				preset["character_name"] = "Takeo";
				break;
		}
	}

	return preset;
}

set_characters()
{
	level endon("end_game");
	self endon("disconnect");

	/* We don't call clientid cause of Ancient */
	if (!isDefined(level.players))
		player_id = 0;
	else
		player_id = level.players.size - 1;

	while (player_id > 3)
		player_id -= 4;

	translation_layer = array("white", "blue", "yellow", "green");

	if (is_tranzit() || is_die_rise() || is_buried())
		map = "tranzit";
	else if (is_town() || is_farm() || is_depot() || is_nuketown())
		map = "town";
	else if (is_mob())
		map = "mob";
	else if (is_origins())
		map = "origins";

	translation_index = translation_layer[player_id];
	if (!isDefined(level.B2_CHARACTERS[map][translation_index]))
		return;
	character = level.B2_CHARACTERS[map][translation_index];

	prop = pull_character_preset(character);

	self setmodel(prop["model"]);
	self setviewmodel(prop["viewmodel"]);
	self set_player_is_female(prop["is_female"]);
	self.characterindex = prop["index"];

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
}

fixed_wait_network_frame()
{
    if (level.players.size == 1)
        wait 0.1;
    else if (numremoteclients())
    {
        snapshot_ids = getsnapshotindexarray();

        for (acked = undefined; !isdefined(acked); acked = snapshotacknowledged(snapshot_ids))
            level waittill("snapacknowledged");
    }
    else
        wait 0.1;
}

get_pap_weapon_options_set_reticle(weapon)
{
    if (!isdefined(self.pack_a_punch_weapon_options))
        self.pack_a_punch_weapon_options = [];

    if (!is_weapon_upgraded(weapon))
        return self calcweaponoptions(0, 0, 0, 0, 0);

    if (isdefined(self.pack_a_punch_weapon_options[weapon]))
        return self.pack_a_punch_weapon_options[weapon];

    base = get_base_name(weapon);
    camo_index = 39;

    if ("zm_prison" == level.script)
        camo_index = 40;
    else if ("zm_tomb" == level.script)
        camo_index = 45;

    lens_index = randomintrange(0, 6);
    reticle_index = 16;
    reticle_color_index = randomintrange(0, 6);

    if ("saritch_upgraded_zm" == base)
        reticle_index = 1;

    self.pack_a_punch_weapon_options[weapon] = self calcweaponoptions( camo_index, lens_index, reticle_index, reticle_color_index );
    return self.pack_a_punch_weapon_options[weapon];
}

challenge_failed(challenge_name, challenge_name_upper, challenge_zone)
{
	print_scheduler(challenge_name + " Challenge: ^1" + self.name + " LEFT " + challenge_zone + "!");
	info_print(self.name + " failed challenge " + challenge_name + " at " + convert_time(int(GetTime() / 1000) - level.B2FR_START));
	generate_watermark("FAILED " + challenge_name_upper, (0.8, 0, 0));
}

nuketown_handler()
{
	level endon("end_game");

	if (!is_nuketown())
		return;

	level.GAMEPLAY_REMINDER = ::nuketown_gameplay_reminder;

	// Bus mannequin
	/* This is bad for highrounds, if this mannequin happens to exist, it'll remove one entity that's otherwise not removable */
    thread remove_mannequin((-30, 13.9031, -47.0411), 1);

	// Yellow House
	if (!has_magic() && level.start_round >= 5)
		thread yellowhouse_controller();
}

yellowhouse_controller()
{
	level endon("end_game");

	level waittill("start_of_round");

	allowed_zones = array("openhouse2_backyard_zone", "openhouse2_f1_zone");

	foreach (player in level.players)
	{
		if (!player is_player_in_yellowhouse())
		{
#if DEBUG == 1
			debug_print("exiting yellowhouse_controller cause zone: '" + player get_current_zone() + "' with coordinates [0] => " + player.origin[0] + " [1] => " + player.origin[1] + " [2] =>" + player.origin[2]);
#endif
			return;
		}
	}

	print_scheduler("Yellow House Challenge: ^2ACTIVE");

    yellow_house_mannequins = array((1058.2, 387.3, -57), (609.28, 315.9, -53.89), (872.48, 461.88, -56.8), (851.1, 156.6, -51), (808, 140.5, -51), (602.53, 281.09, -55));
    foreach (origin in yellow_house_mannequins)
        remove_mannequin(origin);

	while (true)
	{
		foreach (player in level.players)
		{
			if (!player is_player_in_yellowhouse())
			{
				player challenge_failed("Yellow House", "YELLOW HOUSE", "YELLOW HOUSE AREA");
				return;
			}
		}

		wait 0.05;
	}
}

remove_mannequin(origin, extra_delay)
{
	level endon("end_game");

	if (isDefined(extra_delay))
		wait extra_delay;

	all_mannequins = array();
	foreach (destructible in getentarray("destructible", "targetname"))
	{
		if (isSubStr(destructible.destructibledef, "male"))
			all_mannequins[all_mannequins.size] = destructible;
	}

	foreach (mannequin in all_mannequins)
	{
		if (mannequin.origin == origin)
		{
			// Delete collision
			getent(mannequin.target, "targetname") delete();
			// Delete model
			mannequin delete();

#if DEBUG == 1
			debug_print("Removed mannequin on origin: " + origin);
#endif
			break;
		}
	}
}

topbarn_controller()
{
	level endon("end_game");

	if (!is_farm() || has_magic() || !is_round(5))
		return;

	level waittill("start_of_round");

	foreach (player in level.players)
	{
		if (!player is_player_in_top_barn())
		{
#if DEBUG == 1
			debug_print("exiting topbarn_controller cause zone: '" + player get_current_zone() + "'");
#endif
			return;
		}
	}

	print_scheduler("Top Barn Challenge: ^2ACTIVE");

	while (true)
	{
		foreach (player in level.players)
		{
			if (!player is_player_in_top_barn())
			{
				player challenge_failed("Top Barn", "TOP BARN", "TOP BARN AREA");
				return;
			}
		}

		wait 0.05;
	}
}

is_player_in_yellowhouse()
{
	if (self get_current_zone() == "openhouse2_f1_zone")
		return true;

	/* Staircase */
	if ((self.origin[0] > 780 && self.origin[1] < 200)
		&& (self.origin[0] < 900 && self.origin[1] > 30))
			return true;

	/* Doors */
	if ((self.origin[0] < 1130 && self.origin[1] > 100)
		&& (self.origin[0] > 900 && self.origin[1] < 750)
		&& self.origin[2] < 0)
			return true;

#if DEBUG == 1
	debug_print("what");
	debug_print("player not in yellowhouse: [zone] => " + self get_current_zone() + " [0] => " + self.origin[0] + " [1] => " + self.origin[1] + " [2] =>" + self.origin[2]);
#endif
	return false;
}

is_player_in_top_barn()
{
    if (self get_current_zone() != "zone_brn")
        return false;

    if (self.origin[2] < 50)
	{
		if (self.origin[0] < 7875 || self.origin[0] > 8115)
			return false;
		
		if (self.origin[1] > -5115 || self.origin[1] < -5415)
			return false;
	}

	return true;
}

nuketown_gameplay_reminder()
{
	level endon("end_game");

	// 804.1 -56.86
	// -455.42 617.4
	// -82.07 740.67
	// -844.93 60.8

	wait 1;

	if (level.players.size > 1)
	{
		spawn_positions = array();

		spawn_positions[0] = SpawnStruct();
		spawn_positions[0].x_start = 790;
		spawn_positions[0].x_end = 820;
		spawn_positions[0].y_start = -70;
		spawn_positions[0].y_end = 40;

		spawn_positions[1] = SpawnStruct();
		spawn_positions[1].x_start = -470;
		spawn_positions[1].x_end = -440;
		spawn_positions[1].y_start = 600;
		spawn_positions[1].y_end = 630;

		spawn_positions[2] = SpawnStruct();
		spawn_positions[2].x_start = -100;
		spawn_positions[2].x_end = -70;
		spawn_positions[2].y_start = 725;
		spawn_positions[2].y_end = 755;

		spawn_positions[3] = SpawnStruct();
		spawn_positions[3].x_start = -860;
		spawn_positions[3].x_end = -830;
		spawn_positions[3].y_start = 45;
		spawn_positions[3].y_end = 75;

		jug_in_spawn = false;
		jug_perk = getent("vending_jugg", "targetname");

		foreach(spawn in spawn_positions)
		{
			if ((jug_perk.origin[0] > spawn.x_start && jug_perk.origin[0] < spawn.x_end)
				&& jug_perk.origin[1] > spawn.y_start && jug_perk.origin[1] < spawn.y_end)
					jug_in_spawn = true;
		}

		if (jug_in_spawn)
			print_scheduler("JuggerNog in the first room! Full gameplay from all players will be required!");
		else
		{
			print_scheduler("^1REMINDER ^7You are a host", maps\mp\_utility::gethostplayer());
			wait 0.25;
			print_scheduler("Full gameplay is required from host perspective as of April 2023", maps\mp\_utility::gethostplayer());
		}
	}
}

