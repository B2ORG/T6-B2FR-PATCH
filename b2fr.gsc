/* Global code configuration */
#define NOHUD 0
#define DEBUG 0
#define BETA 0
#define B2FR_VER 2

/* Const macros */
#define VER_ANCIENT 353
#define VER_MODERN 1824
#define VER_2905 2905
#define VER_4K 4516
#define NET_FRAME_SOLO 100
#define NET_FRAME_COOP 50
#define MAX_VALID_HEALTH 1044606905
#define CHALLENGE_NEW 0
#define CHALLENGE_SUCCESS 1
#define CHALLENGE_FAIL 2

/* Feature flags */
#define FEATURE_NUKETOWN_EYES 0
#define FEATURE_CHARACTERS 1
#define FEATURE_CHALLENGES 1
#define FEATURE_PERMAPERKS 1

/* Snippet macros */
#define LEVEL_ENDON \
    level endon("end_game");
#define PLAYER_ENDON \
    LEVEL_ENDON \
    self endon("disconnect");

/* Function macros */
#if DEBUG == 1
#define DEBUG_PRINT(__txt); printf("DEBUG: ^5" + __txt);
#else
#define DEBUG_PRINT(__txt)
#endif
#define CLEAR(__var) __var = undefined;
#define MS_TO_SECONDS(__ms) int(__ms / 1000)

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
    flag_init("b2_game_started");
    flag_init("b2_permaperks_were_set");
    flag_init("b2_on");

    level thread on_game_start();
}

on_game_start()
{
    LEVEL_ENDON

    thread set_dvars();
#if FEATURE_CHARACTERS == 1
    level thread reevaluate_character_settings();
    level thread character_wrapper();
#endif
#if FEATURE_PERMAPERKS == 1
    level thread perma_perks_setup();
#endif
    level thread on_player_connected();
    level thread origins_fix();

    flag_wait("initial_blackscreen_passed");

    flag_set("b2_game_started");

    level thread b2fr_main_loop();
#if NOHUD == 0
    create_timers();
    level thread semtex_display();
    if (isDefined(level.B2_NETWORK_HUD))
        level thread [[level.B2_NETWORK_HUD]]();
#endif

    if (is_nuketown())
    {
#if FEATURE_NUKETOWN_EYES == 1
        nuketown_switch_eyes();
#endif
        /* This is bad for highrounds, if this mannequin happens to exist, it'll remove one entity that's otherwise not removable */
        thread remove_mannequin((-30, 13.9031, -47.0411), 1);
    }

    if (isDefined(level.B2_POWERUP_TRACKING))
        level thread [[level.B2_POWERUP_TRACKING]]();

    level thread [[level.GAMEPLAY_REMINDER]]();
    CLEAR(level.GAMEPLAY_REMINDER)

#if DEBUG == 1
    debug_mode();
#endif
#if BETA == 1
    beta_mode();
#endif
}

on_player_connected()
{
    LEVEL_ENDON

    while (true)
    {
        level waittill("connected", player);
        player thread on_player_spawned();
#if FEATURE_CHARACTERS == 1
        if (flag("initial_players_connected"))
            player thread set_joining_player_character();
#endif
    }
}

on_player_spawned()
{
    PLAYER_ENDON

    self waittill("spawned_player");

    // Perhaps a redundand safety check, but doesn't hurt
    while (!flag("initial_players_connected"))
        wait 0.05;

    self thread welcome_prints();
    self thread evaluate_network_frame();
#if NOHUD == 0
    self thread velocity_meter();

    if (isDefined(level.B2_ZONES))
        self thread [[level.B2_ZONES]](true);
#endif
}

b2fr_main_loop()
{
    LEVEL_ENDON

    game_start = getTime();

    level thread scan_in_box();
#if FEATURE_CHALLENGES == 1
    level thread challenge_loop();
#endif

    while (true)
    {
        level waittill("start_of_round");
#if NOHUD == 0
        round_start = getTime();
        if (isDefined(level.round_hud))
        {
            level.round_hud setTimerUp(0);
        }
        level thread show_hordes();
#endif

        /* Check gamerules */
        if (getgametypesetting("startRound") > 1 && (is_tranzit() || is_mob() || is_die_rise() || is_mob() || is_buried() || is_origins()))
            generate_watermark("STARTING ROUND", (1, 0, 0), 0.5);
        else if (getgametypesetting("startRound") > 10 && (is_depot() || is_town() || is_farm() || is_nuketown()))
            generate_watermark("STARTING ROUND", (1, 0, 0), 0.5);
        if (!is_true(level.gamedifficulty))
            generate_watermark("DIFFICULTY", (1, 0, 0), 0.5);

        emergency_permaperks_cleanup();

        level waittill("end_of_round");
#if NOHUD == 0
        round_duration = getTime() - round_start;
        if (isDefined(level.round_hud))
        {
            level.round_hud thread keep_displaying_old_time(round_duration);
        }
        level thread show_split(game_start);
        CLEAR(round_duration)
#endif
#if FEATURE_PERMAPERKS == 1
        if (has_permaperks_system())
        {
            setDvar("award_perks", 1);
        }
#endif

        level thread sniff();

        if (get_plutonium_version() >= 4522 && !did_game_just_start() && should_print_checksum())
        {
            level thread print_checksums();
        }
    }
}

challenge_loop()
{
    LEVEL_ENDON

    initial_challenges = [];
    if (!has_magic() && is_nuketown() && is_round(5))
        initial_challenges = add_to_array(initial_challenges, register_challenge(
            ::check_bounds_yellowhouse,
            ::setup_yellowhouse,
            ::failed_yellowhouse
        ));
    if (!has_magic() && is_farm() && is_round(5))
        initial_challenges = add_to_array(initial_challenges, register_challenge(
            ::check_bounds_topbarn,
            ::setup_topbarn,
            ::failed_topbarn
        ));

    level waittill("start_of_round");

    start_challenges = [];
    active_challenges = 0;
    foreach (challenge in initial_challenges)
    {
        in_bounds = true;
        foreach (player in level.players)
        {
            if (!player [[challenge.boundry_check]]())
            {
                in_bounds = false;
            }
        }
        if (!in_bounds)
        {
            continue;
        }
        if (isDefined(challenge.setup))
        {
            thread [[challenge.setup]]();
        }
        start_challenges = add_to_array(start_challenges, challenge);
        active_challenges++;
    }

    CLEAR(initial_challenges)
    CLEAR(in_bounds)

    while (active_challenges)
    {
        foreach (challenge in start_challenges)
        {
            /* Skip challenge if it has already been failed */
            if (challenge.status == CHALLENGE_FAIL)
            {
                continue;
            }

            /* Check if players are within boundries */
            foreach (player in level.players)
            {
                if (!player [[challenge.boundry_check]]())
                {
                    challenge [[challenge.fail]](player);
                    break;
                }
            }

            if (challenge.status == CHALLENGE_FAIL)
            {
                continue;
            }

            /* If additional challenge condition exists, check that as well */
            if (isDefined(challenge.condition) && [[challenge.condition]]())
            {
                challenge [[challenge.fail]]();
            }
        }

        active_challenges = 0;
        foreach (challenge in start_challenges)
        {
            // DEBUG_PRINT("checking status at " + gettime() + ": " + challenge.status);
            if (challenge.status != CHALLENGE_FAIL)
                active_challenges++;
        }

        wait 0.05;
    }

    DEBUG_PRINT("end_challenge_loop");
}

duplicate_file()
{
    iPrintLn("ONLY ONE ^1B2 ^7PATCH CAN RUN AT THE SAME TIME!");
#if DEBUG == 0
    level notify("end_game");
#endif
}

generate_watermark_slots()
{
    slots = [];

    positions = array(0, -90, 90, -180, 180, -270, 270, -360, 360, -450, 450, -540, 540, -630, 630);

    foreach(pos in positions)
    {
        i = slots.size;
        slots[i] = [];
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
    LEVEL_ENDON

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

print_scheduler(content, player, delay)
{
    if (!isDefined(delay))
    {
        delay = 0;
    }

    if (isDefined(player))
    {
        player thread player_print_scheduler(content, delay);
    }
    else
    {
        foreach (player in level.players)
            player thread player_print_scheduler(content, delay);
    }
}

player_print_scheduler(content, delay)
{
    PLAYER_ENDON

    while (delay > 0 && isDefined(self.scheduled_prints) && getDvarInt("con_gameMsgWindow0LineCount") > 0 && self.scheduled_prints >= getDvarInt("con_gameMsgWindow0LineCount"))
    {
        if (delay > 0)
            delay -= 0.05;
        wait 0.05;
    }

    if (isDefined(self.scheduled_prints))
        self.scheduled_prints++;
    else
        self.scheduled_prints = 1;

    self iPrintLn(content);
    wait_for_message_end();
    self.scheduled_prints--;

    if (self.scheduled_prints <= 0)
        CLEAR(self.scheduled_prints)
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

array_create(values, keys)
{
    new_array = [];
    for (i = 0; i < values.size; i++)
    {
        key = i;
        if (isDefined(keys[i]))
            key = keys[i];

        new_array[key] = values[i];
    }

    return new_array;
}

array_implode(separator, arr)
{
    str = "";
    len = arr.size;
    if (len == 0)
        return "";

    for (i = 0; i < len; i++)
    {
        if (i == 0)
            str += arr[i];
        else
            str += separator + arr[i];
    }
    return str;
}

player_wait_for_initial_blackscreen()
{
    LEVEL_ENDON

    while (!flag("b2_game_started"))
        wait 0.05;
}

is_town()
{
    return level.script == "zm_transit" && level.scr_zm_map_start_location == "town" && level.scr_zm_ui_gametype_group == "zsurvival";
}

is_farm()
{
    return level.script == "zm_transit" && level.scr_zm_map_start_location == "farm" && level.scr_zm_ui_gametype_group == "zsurvival";
}

is_depot()
{
    return level.script == "zm_transit" && level.scr_zm_map_start_location == "transit" && level.scr_zm_ui_gametype_group == "zsurvival";
}

is_tranzit()
{
    return level.script == "zm_transit" && level.scr_zm_map_start_location == "transit" && level.scr_zm_ui_gametype_group == "zclassic";
}

is_nuketown()
{
    return level.script == "zm_nuked";
}

is_die_rise()
{
    return level.script == "zm_highrise";
}

is_mob()
{
    return level.script == "zm_prison";
}

is_buried()
{
    return level.script == "zm_buried";
}

is_origins()
{
    return level.script == "zm_tomb";
}

is_survival_map()
{
    return level.scr_zm_ui_gametype_group == "zsurvival";
}

is_victis_map()
{
    return is_tranzit() || is_die_rise() || is_buried();
}

did_game_just_start()
{
    return !isDefined(level.start_round) || !is_round(level.start_round + 2);
}

is_round(rnd)
{
    return rnd <= level.round_number;
}

fetch_pluto_definition()
{
    dvar_defs = [];
    dvar_defs["zm_gungame"] = VER_ANCIENT;
    dvar_defs["zombies_minplayers"] = 920;
    dvar_defs["sv_allowDof"] = 1137;
    dvar_defs["g_randomSeed"] = 1205;
    dvar_defs["g_playerCollision"] = 2016;
    dvar_defs["sv_allowAimAssist"] = 2107;
    dvar_defs["cg_weaponCycleDelay"] = 2693;
    dvar_defs["cl_enableStreamerMode"] = VER_2905;
    dvar_defs["scr_max_loop_time"] = 3755;
    dvar_defs["rcon_timeout"] = 3855;
    dvar_defs["snd_debug"] = 3963;
    dvar_defs["con_displayRconOutput"] = 4035;
    dvar_defs["scr_allowFileIo"] = VER_4K;
    return dvar_defs;
}

try_parse_pluto_version()
{
    dvar = getDvar("version");
    if (!isSubStr(dvar, "Plutonium"))
        return 0;

    parsed = getSubStr(dvar, 23, 27);
    return int(parsed);
}

get_plutonium_version()
{
    parsed = try_parse_pluto_version();
    if (parsed > 0)
        return parsed;

    definitions = fetch_pluto_definition();
    detected_version = 0;
    foreach (definition in array_reverse(getArrayKeys(definitions)))
    {
        version = definitions[definition];
        // DEBUG_PRINT("definition: " + definition + " version: " + version);
        if (getDvar(definition) != "")
            detected_version = version;
    }
    return detected_version;
}

should_set_draw_offset()
{
    return (getDvar("cg_debugInfoCornerOffset") == "40 0" && is_4k());
}

is_redacted()
{
    return isSubStr(getDvar("sv_referencedFFNames"), "patch_redacted");
}

is_plutonium()
{
    return !is_redacted();
}

is_ancient()
{
    return get_plutonium_version() > 0 && get_plutonium_version() <= VER_ANCIENT;
}

is_2k()
{
    return get_plutonium_version() > VER_ANCIENT && get_plutonium_version() <= VER_2905;
}

is_2905()
{
    return get_plutonium_version() == VER_2905;
}

is_3k()
{
    return get_plutonium_version() > VER_2905 && get_plutonium_version() < VER_4K;
}

is_4k()
{
    return get_plutonium_version() >= VER_4K;
}

has_magic()
{
    return is_true(level.enable_magic);
}

has_permaperks_system()
{
    /* Refer to init_persistent_abilities() */
    return isDefined(level.pers_upgrade_boards) && is_true(level.onlinegame);
}

is_special_round()
{
    return is_true(flag("dog_round")) || is_true(flag("leaper_round"));
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
    LEVEL_ENDON
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

    // DEBUG_PRINT("ratio: " + ratio + " | aspect_ratio: " + aspect_ratio + " | x_pos: " + x_pos + " | w: " + res_components[0] + " | h: " + res_components[1]);

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
    PLAYER_ENDON

    wait 0.75;
#if NOHUD == 1
    self iPrintLn("B2^1FR^7 PATCH ^1V" + B2FR_VER + " ^7[NOHUD]");
#else
    self iPrintLn("B2^1FR^7 PATCH ^1V" + B2FR_VER);
#endif
    self iPrintLn(" Detected Plutonium version: ^1" + get_plutonium_version());
    wait 0.75;
    self iPrintLn("Source: ^1github.com/B2ORG/T6-B2FR-PATCH");
}

gameplay_reminder()
{
    LEVEL_ENDON

    wait 1;

    if (level.players.size > 1)
    {
        print_scheduler("^1REMINDER ^7You are a host", maps\mp\_utility::gethostplayer());
        wait 0.25;
        print_scheduler("Full gameplay is required from host perspective as of April 2023", maps\mp\_utility::gethostplayer());
    }
}

print_checksums()
{
    LEVEL_ENDON

    print_scheduler("Showing patch checksums", maps\mp\_utility::gethostplayer());
    cmdexec("flashScriptHashes");

    if (getDvar("cg_drawChecksums") != "1")
    {
        setDvar("cg_drawChecksums", 1);
        wait 3;
        setDvar("cg_drawChecksums", 0);
    }
}

/* Stub */
cmdexec(arg)
{

}

should_print_checksum()
{
    switch (level.players.size)
    {
        case 1:
        case 2:
            faster = 30;
            if (is_town())
                faster = 60;
            else if (is_origins())
                faster = 40;
            break;
        default:
            faster = 25;
            if (is_town())
                faster = 50;
            else if (is_buried())
                faster = 35;
            else if (is_origins())
                faster = 35;
    }

    /*
    early = (is_round(20) && !is_round(faster) && level.round_number % 5 == 2);
    late = (is_round(faster) && level.round_number % 2 == 1);
    DEBUG_PRINT("early = " + early + " late = " + late);
    */

    return ((is_round(15) && !is_round(faster) && level.round_number % 5 == 2) 
        || (is_round(faster) && level.round_number % 2 == 1));
}

set_dvars()
{
    LEVEL_ENDON

    if (!is_4k() && (is_tranzit() || is_die_rise() || is_mob() || is_buried()))
        level.round_start_custom_func = ::trap_fix;

#if FEATURE_CHARACTERS == 1
    level.callbackplayerdisconnect = ::character_flag_cleanup;
#endif

    level.GAMEPLAY_REMINDER = ::gameplay_reminder;
    if (is_nuketown())
    {
        level.GAMEPLAY_REMINDER = ::nuketown_gameplay_reminder;
    }

    dvars = [];
    /*                                  DVAR                            VALUE                   PROTECT INIT_ONLY   EVAL                    */
#if NOHUD == 0
    dvars[dvars.size] = register_dvar("velocity_meter",                 "1",                    false,  true);
#endif
    dvars[dvars.size] = register_dvar("award_perks",                    "1",                    false,  true,    ::has_permaperks_system);
    dvars[dvars.size] = register_dvar("player_strafeSpeedScale",        "0.8",                  true,   false);
    dvars[dvars.size] = register_dvar("player_backSpeedScale",          "0.7",                  true,   false);
    dvars[dvars.size] = register_dvar("g_speed",                        "190",                  true,   false);
    dvars[dvars.size] = register_dvar("con_gameMsgWindow0MsgTime",      "5",                    true,   false);
    dvars[dvars.size] = register_dvar("con_gameMsgWindow0Filter",       "gamenotify obituary",  true,   false);
    dvars[dvars.size] = register_dvar("sv_cheats",                      "0",                    true,   false);
    dvars[dvars.size] = register_dvar("ai_corpseCount",                 "5",                    true,   false);
    /* Prevent host migration (redundant nowadays) */
    dvars[dvars.size] = register_dvar("sv_endGameIfISuck",              "0",                    false,  false);
    /* Force post dlc1 patch on recoil */
    dvars[dvars.size] = register_dvar("sv_patch_zm_weapons",            "1",                    false,  false);
    /* Remove Depth of Field */
    dvars[dvars.size] = register_dvar("r_dof_enable",                   "0",                    false,  true);
    /* Fix for devblocks in r3903/3904 */
    dvars[dvars.size] = register_dvar("scr_skip_devblock",              "1",                    false,  false,      ::is_3k);
    /* Use native health fix, r4516+ */
    dvars[dvars.size] = register_dvar("g_zm_fix_damage_overflow",       "1",                    false,  true,       ::is_4k);
    /* Defines if Pluto error fixes are applied, r4516+ */
    dvars[dvars.size] = register_dvar("g_fix_entity_leaks",             "0",                    true,   false,      ::is_4k);
    /* Enables flashing hashes of individual scripts */
    dvars[dvars.size] = register_dvar("cg_flashScriptHashes",           "1",                    true,   false,      ::is_4k);
    /* Offsets for pluto draws compatibile with b2 timers */
    dvars[dvars.size] = register_dvar("cg_debugInfoCornerOffset",       "50 20",                false,  false,      ::should_set_draw_offset);

    protected = [];
    foreach (dvar in dvars)
    {
        set_dvar_internal(dvar);
        if (is_true(dvar.protected))
            protected[dvar.name] = dvar.value;
    }

    CLEAR(dvars)

    level thread dvar_watcher(protected);
}

set_dvar_internal(dvar)
{
    if (!isDefined(dvar))
        return;
    if (dvar.init_only && getdvar(dvar.name) != "")
        return;
    setdvar(dvar.name, dvar.value);
}

register_dvar(dvar, set_value, b2_protect, init_only, closure)
{
    if (isDefined(closure) && ![[closure]]())
        return undefined;

    dvar_data = SpawnStruct();
    dvar_data.name = dvar;
    dvar_data.value = set_value;
    dvar_data.protected = b2_protect;
    dvar_data.init_only = init_only;

    DEBUG_PRINT("registered dvar " + dvar);

    return dvar_data;
}

dvar_watcher(dvars)
{
    LEVEL_ENDON

    flag_wait("initial_blackscreen_passed");

    /* We're setting them once again, to ensure lack of accidental detections */
    foreach (dvar, value in dvars)
        setdvar(dvar, value);

    while (true)
    {
        foreach (dvar, value in dvars)
        {
            if (getDvar(dvar) != value)
            {
                /* They're not reset here, someone might want to test something related to protected dvars, so they can do so with the watermark */
                generate_watermark("DVAR " + ToUpper(dvar) + " VIOLATED", (1, 0.6, 0.2), 0.66);
                arrayremoveindex(dvars, dvar, true);
            }
        }

        wait 0.1;
    }
}

award_points(amount)
{
    PLAYER_ENDON

    if (is_mob())
        flag_wait("afterlife_start_over");
    self.score = amount;
}

sniff()
{
    LEVEL_ENDON

    wait randomFloatRange(0.1, 1.2);
    if (flag("b2_on")) 
    {
        duplicate_file();
    }
    flag_set("b2_on");
    level waittill("start_of_round");
    flag_clear("b2_on");
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
    PLAYER_ENDON

    flag_wait("initial_blackscreen_passed");

    start_time = getTime();
    wait_network_frame();
    network_frame_len = getTime() - start_time;

    if ((level.players.size == 1 && network_frame_len == NET_FRAME_SOLO) || (level.players.size > 1 && network_frame_len == NET_FRAME_COOP))
    {
        print_scheduler("Network Frame: ^2GOOD", self);
        return;
    }

    print_scheduler("Network Frame: ^1BAD", self);
    level waittill("start_of_round");
    self thread evaluate_network_frame();
}

trap_fix()
{
    if (level.zombie_health <= MAX_VALID_HEALTH)
        return;

    level.zombie_health = MAX_VALID_HEALTH;

    foreach (zombie in get_round_enemy_array())
    {
        if (zombie.health > MAX_VALID_HEALTH)
            zombie.heath = MAX_VALID_HEALTH;
    }
}

#if NOHUD == 0
create_timers()
{
    level.timer_hud = createserverfontstring("big" , 1.6);
    level.timer_hud set_hud_properties("timer_hud", "TOPRIGHT", "TOPRIGHT", 60, -14);
    level.timer_hud.alpha = 1;
    level.timer_hud setTimerUp(0);

    level.round_hud = createserverfontstring("big" , 1.6);
    level.round_hud set_hud_properties("round_hud", "TOPRIGHT", "TOPRIGHT", 60, 3);
    level.round_hud.alpha = 1;
    level.round_hud setText("0:00");
}

keep_displaying_old_time(time)
{
    LEVEL_ENDON
    level endon("start_of_round");

    while (true)
    {
        self setTimer(MS_TO_SECONDS(time) - 0.1);
        wait 0.25;
    }
}

show_split(start_time)
{
    LEVEL_ENDON

    /* B2 splits used, only use rounds specified */
    if (isDefined(level.B2_SPLITS) && !IsInArray(level.B2_SPLITS, level.round_number))
        return;
    /* By default every 5 rounds past 10 */
    if (!isDefined(level.B2_SPLITS) && (level.round_number <= 10 || level.round_number % 5))
        return;

    wait 8.25;

    timestamp = convert_time(MS_TO_SECONDS((getTime() - start_time)));
    print_scheduler("Round " + level.round_number + " time: ^1" + timestamp);
}

show_hordes()
{
    LEVEL_ENDON

    wait 0.05;

    if (!is_special_round() && is_round(20))
    {
        zombies_value = get_hordes_left();
        print_scheduler("HORDES ON " + level.round_number + ": ^3" + zombies_value);
    }
}

velocity_meter()
{
    PLAYER_ENDON

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
    if (getDvar("velocity_meter") == "0" || is_true(self.afterlife))
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
    LEVEL_ENDON

    /* Must be no magic, only town and nuketown (only round 10+) */
    if (has_magic() || (!is_town() && (!is_nuketown() || (is_nuketown() && is_round(5)))))
        return;

    thread notify_about_prenade_switch();

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
        thread semtex_print_on_demand(print_content);

        CLEAR(print_content)
    }
}

semtex_print_on_demand(to_print)
{
    LEVEL_ENDON
    level endon("end_of_round");

    while (true)
    {
        level waittill("say", text, player);

        if (text == "prenades" || text == "p")
        {
            print_scheduler(to_print);
            wait_for_message_end();
        }

        CLEAR(text)
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
    nade_map = [];
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
    LEVEL_ENDON

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
    LEVEL_ENDON

    level waittill("changed_prenade_type", prenade_type);
    print_scheduler("Prenade values generation is now: ^3" + prenade_type);
}
#endif

#if FEATURE_PERMAPERKS == 1
perma_perks_setup()
{
    if (!has_permaperks_system())
        return;

    thread fix_persistent_jug();

    flag_wait("initial_blackscreen_passed");

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

emergency_permaperks_cleanup()
{
    if (!flag("pers_jug_cleared"))
        return;

    /* This shouldn't be necessary, serves as last resort defence. Will not reset health but will prevent the perk to be active after a down */
    foreach (player in level.players)
    {
        player remove_permaperk_wrapper("pers_jugg");
        player remove_permaperk_wrapper("pers_jugg_downgrade_count");
    }
}

fix_persistent_jug()
{
    LEVEL_ENDON

    while (!isDefined(level.pers_upgrades["jugg"]))
        wait 0.05;

    level.pers_upgrades["jugg"].upgrade_active_func = ::fixed_upgrade_jugg_active;
    flag_wait("pers_jug_cleared");
    wait 0.5;

    arrayremoveindex(level.pers_upgrades, "jugg");
    arrayremovevalue(level.pers_upgrades_keys, "jugg");
    DEBUG_PRINT("upgrade_keys => " + array_implode(", ", level.pers_upgrades_keys));
}

watch_permaperk_award()
{
    LEVEL_ENDON

    present_players = level.players.size;

    while (true)
    {
        i = 0;
        foreach (player in level.players)
        {
            if (!isDefined(player.awarding_permaperks_now))
                i++;
        }

        if (i == present_players && flag("b2_permaperks_were_set"))
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
            CLEAR(player.awarding_permaperks_now)
    }
}

permaperk_array(code, maps_award, maps_take, to_round)
{
    if (!isDefined(maps_award))
        maps_award = array("zm_transit", "zm_highrise", "zm_buried");
    if (!isDefined(maps_take))
        maps_take = [];
    if (!isDefined(to_round))
        to_round = 255;

    permaperk = [];
    permaperk["code"] = code;
    permaperk["maps_award"] = maps_award;
    permaperk["maps_take"] = maps_take;
    permaperk["to_round"] = to_round;

    return permaperk;
}

award_permaperks_safe()
{
    PLAYER_ENDON

    while (!isalive(self))
        wait 0.05;

    wait 0.5;

    perks_to_process = [];
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
    CLEAR(self.awarding_permaperks_now)
    CLEAR(self.permaperk_display_lock)
    self maps\mp\zombies\_zm_stats::uploadstatssoon();
}

fixed_upgrade_jugg_active()
{
    PLAYER_ENDON

    wait 1;
    self maps\mp\zombies\_zm_perks::perk_set_max_health_if_jugg("jugg_upgrade", 1, 0);
    DEBUG_PRINT("fixed_upgrade_jugg_active() init " + self.name);

    while (true)
    {
        level waittill("start_of_round");

        if (maps\mp\zombies\_zm_pers_upgrades::is_pers_system_active())
        {
            if (is_round(level.pers_jugg_round_lose_target))
            {
                self maps\mp\zombies\_zm_stats::increment_client_stat("pers_jugg_downgrade_count", 0);
                wait 0.5;

                if (self.pers["pers_jugg_downgrade_count"] >= level.pers_jugg_round_reached_max)
                    break;
            }
        }
    }

    self maps\mp\zombies\_zm_perks::perk_set_max_health_if_jugg("jugg_upgrade", 1, 1);
    self maps\mp\zombies\_zm_stats::zero_client_stat("pers_jugg", 0);
    self maps\mp\zombies\_zm_stats::zero_client_stat("pers_jugg_downgrade_count", 0);
    flag_set("pers_jug_cleared");

    DEBUG_PRINT("fixed_upgrade_jugg_active() deinit " + self.name);
}

resolve_permaperk(perk)
{
    PLAYER_ENDON

    wait 0.05;

    perk_code = perk["code"];

    /* Triggers when perk is not on the map */
    if (!isDefined(self.pers_upgrades_awarded[perk_code]))
        return;

    /* Too high of a round, return out */
    if (is_round(perk["to_round"]))
        return;

    // DEBUG_PRINT("perk = " + perk_code + " 1st eval = " + isinarray(perk["maps_award"], level.script) + " 2nd eval = " + !self.pers_upgrades_awarded[perk_code]);

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
    flag_set("b2_permaperks_were_set");
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
    PLAYER_ENDON

    self.last_perk_state = [];
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

    print_scheduler("Permaperk " + permaperk_name(perk) + ": " + print_player, self)
    DEBUG_PRINT("print_permaperk_state(): " + self.name + ": Permaperk " + perk + " -> " + print_cli);
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
#endif

origins_fix()
{
    LEVEL_ENDON

    flag_wait("start_zombie_round_logic");
    wait 0.5;

    if (is_origins())
        level.is_forever_solo_game = 0;
}

scan_in_box()
{
    LEVEL_ENDON

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

        // DEBUG_PRINT("in_box: " + in_box + " should: " + should_be_in_box);

        if (in_box == should_be_in_box)
            continue;

        else if ((offset > 0) && (in_box == (should_be_in_box + offset)))
            continue;

        generate_watermark("FIRST BOX", (0.5, 0.3, 0.7), 0.66);
        break;
    }
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

remove_mannequin(origin, extra_delay)
{
    LEVEL_ENDON

    if (isDefined(extra_delay))
        wait extra_delay;

    all_mannequins = [];
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

            DEBUG_PRINT("Removed mannequin on origin: " + origin);
            break;
        }
    }
}

nuketown_gameplay_reminder()
{
    LEVEL_ENDON

    // 804.1 -56.86
    // -455.42 617.4
    // -82.07 740.67
    // -844.93 60.8

    wait 1;

    if (level.players.size > 1)
    {
        spawn_positions = [];

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

#if FEATURE_CHARACTERS == 1
reevaluate_character_settings()
{
    LEVEL_ENDON

    flag_wait("start_zombie_round_logic");

    stat = get_stat_for_map();
    if (stat == "lh_clip")
    {
        preset = int(maps\mp\_utility::gethostplayer() maps\mp\zombies\_zm_stats::get_map_weaponlocker_stat(stat, "zm_highrise")) - 1;
        DEBUG_PRINT("survival preset " + preset);
        return set_team_settings(preset);
    }

    DEBUG_PRINT("reevaluate_character_settings start");

    wait 0.2;

    free_presets = array(0, 1, 2, 3);
    allocated = [];
    /* Force host at the beginning to give conflict resolution priority */
    players = array(maps\mp\_utility::gethostplayer());
    foreach (player in level.players)
    {
        players = add_to_array(players, player, false);
    }

    /* Set characters from presets */
    foreach (player in players)
    {
        preset = int(player maps\mp\zombies\_zm_stats::get_map_weaponlocker_stat(stat, "zm_highrise"));
        p = preset - 1;
        DEBUG_PRINT("preset for " + player.name + ": " + preset);
        if (preset > 0 && !isDefined(allocated[p]))
        {
            DEBUG_PRINT("bind preset " + p + " to " + player.name);
            player set_character_index_internal(p);
            allocated[p] = player;
            /* If there are more than 4 players, we leave characters in the poll */
            if (players.size <= 4)
            {
                arrayremovevalue(free_presets, p);
            }
        }
    }

    /* Assign remaining characters to other players */
    foreach (player in level.players)
    {
        if (!isinarray(allocated, player))
        {
            /* Weasel always is on mob coop */
            if (level.players.size > 1 && is_mob() && isinarray(free_presets, 3))
            {
                p = 3;
            }
            /* Richtofen always is on origins coop */
            else if (level.players.size > 1 && is_origins() && isinarray(free_presets, 2))
            {
                p = 2;
            }
            else
            {
                free_presets = array_randomize(free_presets);
                p = free_presets[0];
            }
            // DEBUG_PRINT("randomized: " + array_implode(", ", free_presets));
            DEBUG_PRINT("bind remaining " + p + " to " + player.name);
            player set_character_index_internal(p);
            if (level.players.size <= 4)
            {
                arrayremovevalue(free_presets, p);
            }
        }
    }
}

set_joining_player_character()
{
    PLAYER_ENDON
    DEBUG_PRINT("set_joining_player_character()");
    stat = get_stat_for_map();
    /* Skip for survival maps */
    if (stat == "lh_clip")
        return;
    wait 0.2;

    preset = self maps\mp\zombies\_zm_stats::get_map_weaponlocker_stat(stat, "zm_highrise");
    if (preset > 0)
    {
        index = preset - 1;
        if (flag("char_taken_" + index))
        {
            DEBUG_PRINT("preset " + preset + " already taken");
            return;
        }
        self set_character_index_internal(index);
    }
}

set_team_settings(preset)
{
    DEBUG_PRINT("set_team_settings(" + preset + ")");
    switch (preset)
    {
        case 0:
        case 1:
            level.should_use_cia = preset;
            DEBUG_PRINT("should_use_cia: " + level.should_use_cia);
            foreach (player in level.players)
            {
                player set_character_index_internal(level.should_use_cia);
            }
            break;
    }
}

set_character_index_internal(index)
{
    DEBUG_PRINT("set_character_index_internal(" + index + ")");

    /* Need to suppress hotjoin callback for the duration of index players */
    if (isDefined(level.hotjoin_player_setup))
    {
        saved_hotjoin_player_setup = level.hotjoin_player_setup;
        level.hotjoin_player_setup = undefined;
    }

    switch (index)
    {
        case 0:
        case 1:
        case 2:
        case 3:
            flag_set("char_taken_" + index);
            self.characterindex = index;
            self [[level.givecustomcharacters]]();
            DEBUG_PRINT(self.name + " set character " + index);
            break;
    }

    /* Now need to restore the callback, as recalculated players should have the normal flow */
    if (isDefined(saved_hotjoin_player_setup))
    {
        level.hotjoin_player_setup = saved_hotjoin_player_setup;
    }
}

get_stat_for_map()
{
    if (is_victis_map())
        return "clip";
    else if (is_mob())
        return "stock";
    else if (is_origins())
        return "alt_clip";
    return "lh_clip";
}

character_flag_cleanup()
{
    flag = "char_taken_" + self.characterindex;
    flag_clear(flag);
    DEBUG_PRINT("clearing flag: " + flag);

    /* Need to invoke original callback afterwards */
    self maps\mp\gametypes_zm\_globallogic_player::callback_playerdisconnect();
}

character_wrapper()
{
    LEVEL_ENDON
    level endon("kill_character_wrapper");

    flag_wait("initial_blackscreen_passed");

    level thread terminate_character_wrapper();
    while (true)
    {
        level waittill("say", message, player);
        if (isSubStr(message, "char"))
        {
            switch (getSubStr(message, 5))
            {
                case "russman":
                case "oldman":
                    player maps\mp\zombies\_zm_stats::set_map_weaponlocker_stat("clip", 1, "zm_highrise");
                    print_scheduler("Successfully updated character settings to: ^3Russman", player);
                    break;
                case "marlton":
                case "reporter":
                    player maps\mp\zombies\_zm_stats::set_map_weaponlocker_stat("clip", 4, "zm_highrise");
                    print_scheduler("Successfully updated character settings to: ^3Stuhlinger", player);
                    break;
                case "misty":
                case "farmgirl":
                    player maps\mp\zombies\_zm_stats::set_map_weaponlocker_stat("clip", 3, "zm_highrise");
                    print_scheduler("Successfully updated character settings to: ^3Misty", player);
                    break;
                case "stuhlinger":
                case "engineer":
                    player maps\mp\zombies\_zm_stats::set_map_weaponlocker_stat("clip", 2, "zm_highrise");
                    print_scheduler("Successfully updated character settings to: ^3Marlton", player);
                    break;
                case "finn":
                case "oleary":
                case "shortsleeve":
                    player maps\mp\zombies\_zm_stats::set_map_weaponlocker_stat("stock", 1, "zm_highrise");
                    print_scheduler("Successfully updated character settings to: ^3Finn", player);
                    break;
                case "sal":
                case "deluca":
                case "longsleeve":
                    player maps\mp\zombies\_zm_stats::set_map_weaponlocker_stat("stock", 2, "zm_highrise");
                    print_scheduler("Successfully updated character settings to: ^3Sal", player);
                    break;
                case "billy":
                case "handsome":
                case "sleeveless":
                    player maps\mp\zombies\_zm_stats::set_map_weaponlocker_stat("stock", 3, "zm_highrise");
                    print_scheduler("Successfully updated character settings to: ^3Billy", player);
                    break;
                case "weasel":
                case "arlington":
                    player maps\mp\zombies\_zm_stats::set_map_weaponlocker_stat("stock", 4, "zm_highrise");
                    print_scheduler("Successfully updated character settings to: ^3Weasel", player);
                    break;
                case "dempsey":
                    player maps\mp\zombies\_zm_stats::set_map_weaponlocker_stat("alt_clip", 1, "zm_highrise");
                    print_scheduler("Successfully updated character settings to: ^3Dempsey", player);
                    break;
                case "nikolai":
                    player maps\mp\zombies\_zm_stats::set_map_weaponlocker_stat("alt_clip", 2, "zm_highrise");
                    print_scheduler("Successfully updated character settings to: ^3Nikolai", player);
                    break;
                case "richtofen":
                    player maps\mp\zombies\_zm_stats::set_map_weaponlocker_stat("alt_clip", 3, "zm_highrise");
                    print_scheduler("Successfully updated character settings to: ^3Richtofen", player);
                    break;
                case "takeo":
                    player maps\mp\zombies\_zm_stats::set_map_weaponlocker_stat("alt_clip", 4, "zm_highrise");
                    print_scheduler("Successfully updated character settings to: ^3Takeo", player);
                    break;
                case "cdc":
                    player maps\mp\zombies\_zm_stats::set_map_weaponlocker_stat("lh_clip", 1, "zm_highrise");
                    print_scheduler("Successfully updated character settings to: ^3CDC", player);
                    break;
                case "cia":
                    player maps\mp\zombies\_zm_stats::set_map_weaponlocker_stat("lh_clip", 2, "zm_highrise");
                    print_scheduler("Successfully updated character settings to: ^3CIA", player);
                    break;
                case "reset":
                    player maps\mp\zombies\_zm_stats::set_map_weaponlocker_stat("clip", 0, "zm_highrise");
                    player maps\mp\zombies\_zm_stats::set_map_weaponlocker_stat("stock", 0, "zm_highrise");
                    player maps\mp\zombies\_zm_stats::set_map_weaponlocker_stat("alt_clip", 0, "zm_highrise");
                    player maps\mp\zombies\_zm_stats::set_map_weaponlocker_stat("lh_clip", 0, "zm_highrise");
                    print_scheduler("Character settings have been reset", player);
                    break;
            }
        }
        else if (message == "whoami")
        {
            switch (player maps\mp\zombies\_zm_stats::get_map_weaponlocker_stat(get_stat_for_map(), "zm_highrise"))
            {
                case 1:
                    if (is_victis_map())
                        print_scheduler("Your preset is: ^3Russman", player);
                    else if (is_mob())
                        print_scheduler("Your preset is: ^3Finn", player);
                    else if (is_origins())
                        print_scheduler("Your preset is: ^3Dempsey", player);
                    else
                        print_scheduler("Your preset is: ^3CDC", player);
                    break;
                case 2:
                    if (is_victis_map())
                        print_scheduler("Your preset is: ^3Stuhlinger", player);
                    else if (is_mob())
                        print_scheduler("Your preset is: ^3Sal", player);
                    else if (is_origins())
                        print_scheduler("Your preset is: ^3Nikolai", player);
                    else
                        print_scheduler("Your preset is: ^3CIA", player);
                    break;
                case 3:
                    if (is_victis_map())
                        print_scheduler("Your preset is: ^3Misty", player);
                    else if (is_mob())
                        print_scheduler("Your preset is: ^3Billy", player);
                    else if (is_origins())
                        print_scheduler("Your preset is: ^3Richtofen", player);
                    else
                        print_scheduler("You don't currently have any character preset", player);
                    break;
                case 4:
                    if (is_victis_map())
                        print_scheduler("Your preset is: ^3Marlton", player);
                    else if (is_mob())
                        print_scheduler("Your preset is: ^3Weasel", player);
                    else if (is_origins())
                        print_scheduler("Your preset is: ^3Takeo", player);
                    else
                        print_scheduler("You don't currently have any character preset", player);
                    break;
                default:
                    print_scheduler("You don't currently have any character preset", player);
            }

#if DEBUG == 1
            print_scheduler("Characterindex: ^1" + player.characterindex, player);
            // print_scheduler("Shader: ^1" + player.whos_who_shader, player);
#endif
        }
    }
}

terminate_character_wrapper()
{
    LEVEL_ENDON;
    while (did_game_just_start())
        wait 0.05;
    level notify("kill_character_wrapper");
}

#endif

#if FEATURE_NUKETOWN_EYES == 1
nuketown_switch_eyes()
{
    level setclientfield("zombie_eye_change", 1);
    sndswitchannouncervox("richtofen");
}
#endif

#if FEATURE_CHALLENGES == 1
register_challenge(boundry_check, setup_function, challenge_failed_function, challenge_condition_function)
{
    challenge = spawnStruct();
    challenge.status = CHALLENGE_NEW;
    challenge.boundry_check = boundry_check;
    challenge.setup = setup_function;
    challenge.fail = challenge_failed_function;
    challenge.condition = challenge_condition_function;

    return challenge;
}

setup_yellowhouse()
{
    yellow_house_mannequins = array((1058.2, 387.3, -57), (609.28, 315.9, -53.89), (872.48, 461.88, -56.8), (851.1, 156.6, -51), (808, 140.5, -51), (602.53, 281.09, -55));
    foreach (origin in yellow_house_mannequins)
        remove_mannequin(origin);

    print_scheduler("Yellow House Challenge: ^2ACTIVE");
}

setup_topbarn()
{
    print_scheduler("Top Barn Challenge: ^2ACTIVE");
}

check_bounds_yellowhouse()
{
    return (self get_current_zone() == "openhouse2_f1_zone"
        /* Staircase */
        || (self.origin[0] > 780 && self.origin[1] < 200) && (self.origin[0] < 900 && self.origin[1] > 30)
        /* Doors */
        || (self.origin[0] < 1130 && self.origin[1] > 100) && (self.origin[0] > 900 && self.origin[1] < 750) && self.origin[2] < 0);
}

check_bounds_topbarn()
{
    return ((self get_current_zone() == "zone_brn" && self.origin[2] >= 50)
        || (self.origin[0] > 7875 && self.origin[0] < 8115 && self.origin[1] <= -5115 && self.origin[1] >= -5415));
}

failed_yellowhouse(player)
{
    print_scheduler("Yellow House Challenge: ^1" + player.name + " LEFT THE CHALLENGE AREA!");
    level thread generate_temp_watermark(20, "FAILED YELLOW HOUSE", (0.8, 0, 0));
    self.status = CHALLENGE_FAIL;
}

failed_topbarn(player)
{
    print_scheduler("Top Barn Challenge: ^1" + player.name + " LEFT THE CHALLENGE AREA!");
    level thread generate_temp_watermark(20, "FAILED TOP BARN", (0.8, 0, 0));
    self.status = CHALLENGE_FAIL;
}
#endif
