/* Global code configuration */
#define RAW 1
#define DEBUG 0
#define DEBUG_HUD 0
#define BETA 0

/* Const macros */
#define B2FR_VER 3.0
#define VER_ANCIENT 353
#define VER_MODERN 1824
#define VER_2905 2905
#define VER_3K 3042
#define VER_4K 4516
#define NET_FRAME_SOLO 100
#define NET_FRAME_COOP 50
#define MAX_VALID_HEALTH 1044606905
#define CHALLENGE_NEW 0
#define CHALLENGE_SUCCESS 1
#define CHALLENGE_FAIL 2
#define LUI_ROUND_PULSE_TIMES_MIN 2
#define LUI_ROUND_MAX 100
#define LUI_ROUND_PULSE_TIMES_DELTA 5
#define LUI_PULSE_DURATION 500
#define LUI_FIRST_ROUND_DURATION 1000
#define COL_BLACK "^0"
#define COL_RED "^1"
#define COL_GREEN "^2"
#define COL_YELLOW "^3"
#define COL_BLUE "^4"
#define COL_LIGHT_BLUE "^5"
#define COL_PURPLE "^6"
#define COL_WHITE "^7"
#define COL_VARIABLE "^8"
#define COL_GREY "^9"
#define TXT_AVAILABLE COL_GREEN + "AVAILABLE" + COL_WHITE
#define TXT_DISABLED COL_RED + "DISABLED" + COL_WHITE
#define SPLITS_FILE "b2fr/splits.txt"
#define SEMTEX_DYNAMIC_CALC_ROUND 51
#define SEMTEX_PRENADES_MAP array(1, 2, 3, 4, 5, 7, 8, 9, 10, 12, 13, 17, 19, 22, 24, 28, 29, 34, 39, 42, 46, 52, 57, 61, 69, 78, 86, 96, 103)
#define SEMTEX_BEGIN_PRENADES_RND 22

/* Feature flags */
#define FEATURE_HUD 1
#define FEATURE_PERMAPERKS 1
#define FEATURE_HORDES 1
#define FEATURE_CHARACTERS 1
#define FEATURE_CONNECTOR 0
#define FEATURE_SEMTEX_CALC_PRENADE 1
#define FEATURE_NUKETOWN_EYES 0
#define FEATURE_VELOCITY_METER 1
#define FEATURE_CHALLENGES 1

/* Snippet macros */
#define LEVEL_ENDON \
    level endon("end_game");
#define PLAYER_ENDON \
    LEVEL_ENDON \
    self endon("disconnect");

/* Function macros */
#if DEBUG == 1
#define DEBUG_PRINT(__txt) printf("DEBUG: ^5" + __txt);
#else
#define DEBUG_PRINT(__txt)
#endif
#define CLEAR(__var) __var = undefined;
#define MS_TO_SECONDS(__ms) int(__ms / 1000)
#define COLOR_TXT(__txt, __color) __color + __txt + COL_WHITE

#include common_scripts\utility;
#include maps\mp\gametypes_zm\_hud_util;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\_utility;

/*
 ************************************************************************************************************
 ********************************************* INITIALIZATION ***********************************************
 ************************************************************************************************************
*/

main()
{
    replacefunc(maps\mp\animscripts\zm_utility::wait_network_frame, ::fixed_wait_network_frame);
    replacefunc(maps\mp\zombies\_zm_utility::wait_network_frame, ::fixed_wait_network_frame);

    replaceFunc(maps\mp\zombies\_zm_weapons::get_pack_a_punch_weapon_options, ::b2_get_pack_a_punch_weapon_options);
}

init()
{
    thread protect_file();
    thread origins_fix();
    thread on_player_connected();
    init_b2_flags();
    init_b2_dvars();
    init_b2_characters();
    init_b2_permaperks();
    init_b2_io();

#if DEBUG == 1
    thread _custom_start_round();
#endif

    thread post_init();
}

post_init()
{
    LEVEL_ENDON

    flag_wait("initial_blackscreen_passed");

    thread init_b2_hud();
    init_b2_box();
    init_b2_chat_watcher();
    thread b2fr_main_loop();
    thread b2fr_challenge_loop();

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
    }
}

on_player_spawned()
{
    PLAYER_ENDON

    self waittill("spawned_player");

    /* Perhaps a redundand safety check, but doesn't hurt */
    while (!flag("initial_players_connected"))
        wait 0.05;

    self thread welcome_prints();
    self thread evaluate_network_frame();
    self thread fill_up_bank();

#if FEATURE_HUD == 1 && FEATURE_VELOCITY_METER == 1
    self thread velocity_meter();
#endif

#if DEBUG == 1 && DEBUG_HUD == 1 && FEATURE_HUD == 1
    self thread _zone_hud();
#endif
}

init_b2_characters()
{
#if FEATURE_CHARACTERS == 1
    thread hijack_personality_character();
#endif
}

init_b2_permaperks()
{
#if FEATURE_PERMAPERKS == 1
    thread perma_perks_setup();
#endif
}

init_b2_hud()
{
#if FEATURE_HUD == 1
    create_timers();

#if DEBUG_HUD == 1
    thread _network_frame_hud();
#endif
#endif
}

init_b2_box()
{
    if (!has_magic())
        return;

    LEVEL_ENDON

    while (!isdefined(level.chests))
    {
        /* Escape if chests are not defined yet */
        if (!did_game_just_start())
            return;
        wait 0.05;
    }

    level.total_box_hits = 0;
    array_thread(level.chests, ::watch_box_state);
}

init_b2_flags()
{
    flag_init("b2_permaperks_were_set");
    flag_init("b2_on");
    // flag_init("b2_hud_killed");
    flag_init("b2_char_taken_0");
    flag_init("b2_char_taken_1");
    flag_init("b2_char_taken_2");
    flag_init("b2_char_taken_3");
}

init_b2_dvars()
{
    LEVEL_ENDON

#if FEATURE_CHARACTERS == 1
    if (!is_survival_map())
    {
        level.callbackplayerdisconnect = ::character_flag_cleanup;
    }
#endif

#if FEATURE_HUD == 1 && FEATURE_SEMTEX_CALC_PRENADE == 1
    if (!has_magic() && (is_town() || (is_nuketown() && is_round(10))))
    {
        level.b2_semtex_prenades = 0;
    }
#endif

    if (is_nuketown())
    {
        level.GAMEPLAY_REMINDER = ::nuketown_gameplay_reminder;
    }

    dvars = [];
    /*                                  DVAR                            VALUE                   PROTECT INIT_ONLY   EVAL                                                WATCHER_CALLBACK*/
    dvars[dvars.size] = register_dvar("sv_cheats",                      "0",                    true,   false);
    dvars[dvars.size] = register_dvar("award_perks",                    "1",                    false,  true,       ::has_permaperks_system);

#if FEATURE_HUD == 1
    dvars[dvars.size] = register_dvar("timers",                         "1",                    false,  true,       undefined,                                          ::timers_alpha);
    dvars[dvars.size] = register_dvar("splits",                         "1",                    false,  true);
    dvars[dvars.size] = register_dvar("kill_hud",                       "0",                    false,  false,      undefined,                                          ::kill_hud);
#endif

#if FEATURE_HORDES == 1
    dvars[dvars.size] = register_dvar("hordes",                         "1",                    false,  true);
#endif

#if FEATURE_CHARACTERS == 1
    dvars[dvars.size] = register_dvar("viewmodel",                      "",                     false,  false,      undefined,                                          ::viewmodel_input);
#endif

#if DEBUG == 1
    dvars[dvars.size] = register_dvar("getDvarValue",                   "",                     false,  false,      undefined,                                          ::_dvar_reader);
#endif

    dvars[dvars.size] = register_dvar("player_strafeSpeedScale",        "0.8",                  true,   false);
    dvars[dvars.size] = register_dvar("player_backSpeedScale",          "0.7",                  true,   false);
    dvars[dvars.size] = register_dvar("g_speed",                        "190",                  true,   false);
    dvars[dvars.size] = register_dvar("con_gameMsgWindow0MsgTime",      "5",                    true,   false);
    dvars[dvars.size] = register_dvar("con_gameMsgWindow0Filter",       "gamenotify obituary",  true,   false);
    dvars[dvars.size] = register_dvar("ai_corpseCount",                 "8",                    true,   false,      array(::is_plutonium_version, 4837, true));
    /* Prevent host migration (redundant nowadays) */
    dvars[dvars.size] = register_dvar("sv_endGameIfISuck",              "0",                    false,  false);
    /* Force post dlc1 patch on recoil */
    dvars[dvars.size] = register_dvar("sv_patch_zm_weapons",            "1",                    false,  false);
    /* Remove Depth of Field */
    dvars[dvars.size] = register_dvar("r_dof_enable",                   "0",                    false,  true);
    /* Fix for devblocks in r3903/3904 */
    dvars[dvars.size] = register_dvar("scr_skip_devblock",              "1",                    false,  false,      array(::is_plutonium_version, VER_3K));
    /* Use native health fix, r4516+ */
    dvars[dvars.size] = register_dvar("g_zm_fix_damage_overflow",       "1",                    false,  true,       array(::is_plutonium_version, VER_4K));
    /* Defines if Pluto error fixes are applied, r4516+ */
    dvars[dvars.size] = register_dvar("g_fix_entity_leaks",             "0",                    true,   false,      array(::is_plutonium_version, VER_4K));
    /* Enables flashing hashes of individual scripts */
    dvars[dvars.size] = register_dvar("cg_flashScriptHashes",           "1",                    true,   false,      array(::is_plutonium_version, VER_4K));
    /* Offsets for pluto draws compatibile with b2 timers */
    dvars[dvars.size] = register_dvar("cg_debugInfoCornerOffset",       "50 20",                false,  false,      ::should_set_draw_offset);
    /* Displays the game status ID */
    dvars[dvars.size] = register_dvar("cg_drawIdentifier",              "1",                    true,   false,      array(::is_plutonium_version, VER_4K));
    /* Locks fps for all clients - Set it higher due to engine limiter being dogfood, this allows ppl to go constant 250 if they want to */
    dvars[dvars.size] = register_dvar("sv_clientFpsLimit",              "332",                  true,   false);

    for (i = 0; i < dvars.size; i++)
    {
        set_dvar_internal(dvars[i]);
        dvars[i].state = getdvar(dvars[i].name);
    }

    level thread dvar_scanner(dvars);
}

init_b2_chat_watcher()
{
    chat = [];

#if FEATURE_CHARACTERS == 1
    chat["char"] = ::characters_input;
    chat["whoami"] = ::check_whoami;
    chat["view"] = ::viewmodel_input;
#endif

#if FEATURE_HUD == 1 && FEATURE_SEMTEX_CALC_PRENADE == 1
    chat["prenades"] = ::print_semtex_prenades;
#endif

    if (chat.size)
    {
        thread chat_watcher(chat);
    }
}

init_b2_io()
{
    if (is_io_available() && !fs_testfile("b2fr"))
    {
        DEBUG_PRINT("creating b2fr scriptdata dir");
        f = fs_fopen("b2fr/.tmp", "write");
        fs_fclose(f);
        fs_remove("b2fr/.tmp");
    }
}

b2fr_main_loop()
{
    LEVEL_ENDON

    // DEBUG_PRINT("initialized b2fr_main_loop");
    game_start = gettime();

    while (true)
    {
        level waittill("start_of_round");

#if FEATURE_HUD == 1
        round_start = gettime();

        if (isdefined(level.round_hud))
        {
            level.round_hud settimerup(0);
        }
#endif

#if FEATURE_HORDES == 1
        level thread show_hordes();
#endif

        if (has_permaperks_system())
        {
            emergency_permaperks_cleanup();
        }

#if FEATURE_HUD == 1 && FEATURE_SEMTEX_CALC_PRENADE == 1
        if (level.round_number == SEMTEX_DYNAMIC_CALC_ROUND && is_true(level.b2_semtex_prenades))
        {
            print_scheduler("Prenades are calculated " + COLOR_TXT("DYNAMICALLY", COL_YELLOW) + " from now on");
        }
        recalculate_semtex_prenades();
        print_semtex_prenades();
#endif

        level waittill("end_of_round");

#if FEATURE_HUD == 1
        round_duration = gettime() - round_start;

        if (isdefined(level.round_hud))
        {
            level.round_hud thread keep_displaying_old_time(round_duration);
        }
        level thread show_split(game_start);
#endif

#if FEATURE_PERMAPERKS == 1
        if (has_permaperks_system())
        {
            setdvar("award_perks", 1);
        }
#endif

        /* This is less invasive way, less intrusive and threads spin up only at the end of round */
        if (!is_round(50))
        {
            level thread sniff();
        }

        if (should_print_checksum())
        {
            level thread print_checksums();
        }

#if FEATURE_HUD == 1
        CLEAR(round_duration)
#endif
        // level waittill("between_round_over");
    }
}

/*
 ************************************************************************************************************
 ************************************************ UTILITIES *************************************************
 ************************************************************************************************************
*/

generate_watermark_slots()
{
    slots = [];

    positions = array(0, -90, 90, -180, 180, -270, 270, -360, 360, -450, 450, -540, 540, -630, 630);

    foreach (pos in positions)
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

    if (!isdefined(level.set_of_slots))
        generate_watermark_slots();

    x_pos = get_watermark_position("perm");
    if (!isdefined(x_pos))
        return;

    if (!isdefined(color))
        color = (1, 1, 1);

    if (!isdefined(alpha_override))
        alpha_override = 0.33;

    watermark = createserverfontstring("hudsmall" , 1.2);
    watermark setpoint("CENTER", "TOP", x_pos, -5);
    watermark.color = color;
    watermark settext(text);
    watermark.alpha = alpha_override;
    watermark.hidewheninmenu = 0;

    flag_set(text);

    if (!isdefined(level.num_of_watermarks))
        level.num_of_watermarks = 0;
    level.num_of_watermarks++;
}

generate_temp_watermark(kill_on, text, color, alpha_override)
{
    LEVEL_ENDON

    if (is_true(flag(text)))
        return;

    if (!isdefined(level.set_of_slots))
        generate_watermark_slots();

    x_pos = get_watermark_position("temp");
    if (!isdefined(x_pos))
        return;

    if (!isdefined(color))
        color = (1, 1, 1);

    if (!isdefined(alpha_override))
        alpha_override = 0.33;

    twatermark = createserverfontstring("hudsmall" , 1.2);
    twatermark setpoint("CENTER", "TOP", x_pos, -17);
    twatermark.color = color;
    twatermark settext(text);
    twatermark.alpha = alpha_override;
    twatermark.hidewheninmenu = 0;

    flag_set(text);

    CLEAR(text)
    CLEAR(color)
    CLEAR(alpha_override)

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
}

print_scheduler(content, player, delay)
{
    if (!isdefined(delay))
    {
        delay = 0;
    }

    // DEBUG_PRINT("print_scheduler(content='" + content + ")");
    if (isdefined(player))
    {
        // DEBUG_PRINT(player.name + ": print scheduled: " + content);
        player thread player_print_scheduler(content, delay);
    }
    else
    {
        // DEBUG_PRINT("general: print scheduled: " + content);
        foreach (player in level.players)
            player thread player_print_scheduler(content, delay);
    }
}

player_print_scheduler(content, delay)
{
    PLAYER_ENDON

    while (delay > 0 && isdefined(self.scheduled_prints) && getdvarint("con_gameMsgWindow0LineCount") > 0 && self.scheduled_prints >= getdvarint("con_gameMsgWindow0LineCount"))
    {
        if (delay > 0)
            delay -= 0.05;
        wait 0.05;
    }

    if (isdefined(self.scheduled_prints))
        self.scheduled_prints++;
    else
        self.scheduled_prints = 1;

    self iprintln(content);
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
        if (isdefined(keys[i]))
            key = keys[i];

        new_array[key] = values[i];
    }

    return new_array;
}

array_implode(separator, arr)
{
    if (arr.size == 0)
        return "";

    str = "";
    first = true;
    foreach (element in arr)
    {
        if (first)
            str += sstr(element);
        else
            str += separator + sstr(element);

        first = false;
    }
    return str;
}

array_shift(arr)
{
    new_arr = [];
    if (arr.size < 2)
        return new_arr;

    first = true;
    foreach (value in arr)
    {
        if (!first)
            new_arr[new_arr.size] = value;
        first = false;
    }

    return new_arr;
}

call_func_with_variadic_args(callback, arg_array)
{
    if (isdefined(arg_array[9]))
        return [[callback]](arg_array[0], arg_array[1], arg_array[2], arg_array[3], arg_array[4], arg_array[5], arg_array[6], arg_array[7], arg_array[8], arg_array[9]);
    if (isdefined(arg_array[8]))
        return [[callback]](arg_array[0], arg_array[1], arg_array[2], arg_array[3], arg_array[4], arg_array[5], arg_array[6], arg_array[7], arg_array[8]);
    if (isdefined(arg_array[7]))
        return [[callback]](arg_array[0], arg_array[1], arg_array[2], arg_array[3], arg_array[4], arg_array[5], arg_array[6], arg_array[7]);
    if (isdefined(arg_array[6]))
        return [[callback]](arg_array[0], arg_array[1], arg_array[2], arg_array[3], arg_array[4], arg_array[5], arg_array[6]);
    if (isdefined(arg_array[5]))
        return [[callback]](arg_array[0], arg_array[1], arg_array[2], arg_array[3], arg_array[4], arg_array[5]);
    if (isdefined(arg_array[4]))
        return [[callback]](arg_array[0], arg_array[1], arg_array[2], arg_array[3], arg_array[4]);
    if (isdefined(arg_array[3]))
        return [[callback]](arg_array[0], arg_array[1], arg_array[2], arg_array[3]);
    if (isdefined(arg_array[2]))
        return [[callback]](arg_array[0], arg_array[1], arg_array[2]);
    if (isdefined(arg_array[1]))
        return [[callback]](arg_array[0], arg_array[1]);
    if (isdefined(arg_array[0]))
        return [[callback]](arg_array[0]);
    return [[callback]]();
}

sstr(value)
{
    if (!isdefined(value))
        return "undefined";
    else if (isarray(value))
        return "{" + array_implode(", ", value) + "}";
    return value;
}

gettype(value)
{
    if (isint(value))
        return "integer";
    if (isfloat(value))
        return "float";
    if (isstring(value))
        return "string";
    if (isarray(value))
        return "array";
    if (value == true || value == false)
        return "boolean";
    return "struct";
}

naive_round(floating_point)
{
    floating_point = int(floating_point * 1000);
    return floating_point / 1000;
}

number_round(floating_point, decimal_places, format)
{
    if (!isdefined(decimal_places))
        decimal_places = 0;

    factor = int(pow(10, decimal_places));
    scaled = floating_point * factor;
    decimal = scaled - int(scaled);

    if (is_true(format))
    {
        full_scaled = int(scaled);
        full = "" + (int(full_scaled / factor));
        decimal = "" + (int(abs(full_scaled) % factor));

        // DEBUG_PRINT("decimal_places=" + sstr(decimal_places) + " factor=" + sstr(factor) + " typeof(scaled)=" + gettype(scaled) + " typeof(factor)=" + gettype(factor) + " scaled=" + sstr(scaled) + " decimal=" + sstr(decimal) + " full=" + sstr(full) + " abs(scaled)=" + sstr(abs(scaled)) );

        for (i = decimal.size; i < decimal_places; i++)
        {
            decimal = "0" + decimal;
        }

        number = full;
        if (floating_point < 0 && full == "0")
            number = "-" + full;
        if (decimal_places)
            number += "." + decimal;
        return number;
    }

    if (decimal >= 0.5)
        scaled = int(scaled) + 1;
    else if (decimal <= -0.5)
        scaled = int(scaled) - 1;
    else
        scaled = int(scaled);

    return scaled / factor;
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

is_vanilla_map()
{
    switch (level.script)
    {
        case "zm_transit":
        case "zm_nuked":
        case "zm_highrise":
        case "zm_prison":
        case "zm_buried":
        case "zm_tomb":
            return true;
    }
    return false;
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
    return !isdefined(level.start_round) || !is_round(level.start_round + 2);
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
    dvar = getdvar("version");
    if (!issubstr(dvar, "Plutonium"))
        return 0;

    /* Future proof for potential version 10k+ */
    parsed = getsubstr(dvar, 23, 28);
    if (int(parsed))
        return int(parsed);
    parsed = getsubstr(dvar, 23, 27);
    return int(parsed);
}

get_plutonium_version()
{
    parsed = try_parse_pluto_version();
    if (parsed > 0)
        return parsed;

    definitions = fetch_pluto_definition();
    detected_version = 0;
    foreach (definition in array_reverse(getarraykeys(definitions)))
    {
        version = definitions[definition];
        // DEBUG_PRINT("definition: " + definition + " version: " + version);
        if (getdvar(definition) != "")
            detected_version = version;
    }
    return detected_version;
}

should_set_draw_offset()
{
    return (getdvar("cg_debugInfoCornerOffset") == "40 0" && is_plutonium_version(VER_4K));
}

is_redacted()
{
    return issubstr(getdvar("sv_referencedFFNames"), "patch_redacted");
}

is_plutonium()
{
    return !is_redacted();
}

is_plutonium_version(version, negate)
{
    if (is_true(negate))
        return get_plutonium_version() < version;
    return get_plutonium_version() >= version;
}

has_magic()
{
    return is_true(level.enable_magic);
}

is_online_game()
{
    return is_true(level.onlinegame);
}

has_permaperks_system()
{
    // DEBUG_PRINT("has_permaperks_system()=" + (isdefined(level.pers_upgrade_boards) && is_online_game()));
    /* Refer to init_persistent_abilities() */
    return isdefined(level.pers_upgrade_boards) && is_online_game();
}

is_special_round()
{
    return is_true(flag("dog_round")) || is_true(flag("leaper_round"));
}

#if FEATURE_HORDES == 1
get_zombies_left()
{
    return get_round_enemy_array().size + level.zombie_total;
}

get_hordes_left()
{
    return int((get_zombies_left() / 24) * 100) / 100;
}
#endif

wait_for_message_end()
{
    wait getdvarfloat("con_gameMsgWindow0FadeInTime") + getdvarfloat("con_gameMsgWindow0MsgTime") + getdvarfloat("con_gameMsgWindow0FadeOutTime");
}

emulate_menu_call(content, ent)
{
    if (!isdefined(ent))
        ent = level.players[0];

    ent notify ("menuresponse", "", content);
}

is_io_available()
{
    return is_plutonium_version(VER_4K) && getdvar("scr_allowFileIo") == "1";
}

b2_signal(message, ctx, array_keys)
{
#if FEATURE_CONNECTOR == 1
    if (isarray(ctx) && isarray(array_keys))
    {
        ctx = array_create(ctx, array_keys);
    }
    level notify("b2_sig_out", message, ctx);
#endif
}

is_dynamic_prenade_calculation()
{
    return is_round(SEMTEX_DYNAMIC_CALC_ROUND);
}

remove_mannequin(origin, extra_delay)
{
    LEVEL_ENDON

    if (isdefined(extra_delay))
        wait extra_delay;

    all_mannequins = [];
    foreach (destructible in getentarray("destructible", "targetname"))
    {
        if (issubstr(destructible.destructibledef, "male"))
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

/*
 ************************************************************************************************************
 ****************************************** SINGLE PURPOSE FUNCTIONS ****************************************
 ************************************************************************************************************
*/

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

b2_get_pack_a_punch_weapon_options(weapon)
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

protect_file()
{
    wait 0.05;
#if RAW == 1
    bad_file();
#endif
}

chat_watcher(lookups)
{
    LEVEL_ENDON

    keys = getarraykeys(lookups);
    while (true)
    {
        level waittill("say", message, player);

        foreach (chat in keys)
        {
            if (!flag("b2_" + chat + "_locked") && isstrstart(message, chat))
            {
                DEBUG_PRINT("chat_callback('" + getsubstr(message, chat.size + 1) + "', '" + chat + "', '" + player.name + "')");
                [[lookups[chat]]](getsubstr(message, chat.size + 1), chat, player);
                break;
            }
        }

        CLEAR(message)
        CLEAR(chat)
    }
}

bad_file()
{
    flag_set("b2_bad_file");

    wait 0.75;
    iprintln("YOU'VE DOWNLOADED THE ^1WRONG FILE!");
    wait 0.75;
    iprintln("Please read the installation instructions on the patch ^5GitHub^7 page");
    wait 0.75;
    iprintln("Source: ^3github.com/B2ORG/T6-B2FR-PATCH");
    wait 0.75;
#if DEBUG == 0
    level notify("end_game");
#endif
}

duplicate_file()
{
    iprintln("ONLY ONE ^1B2 ^7PATCH CAN RUN AT THE SAME TIME!");
#if DEBUG == 0
    level notify("end_game");
#endif
}

sniff()
{
    LEVEL_ENDON

    wait randomfloatrange(0.1, 1.2);
    if (flag("b2_on")) 
    {
        duplicate_file();
    }
    flag_set("b2_on");
    level waittill("start_of_round");
    flag_clear("b2_on");
}

welcome_prints()
{
    PLAYER_ENDON

    if (is_true(flag("b2_bad_file")))
        return;

    wait 0.75;
    self iprintln("B2^1FR^7 PATCH " + COLOR_TXT("V" + B2FR_VER, COL_RED));
    wait 0.75;
    self iprintln(compose_welcome_print());
    wait 0.75;
    self iprintln("Source: ^1github.com/B2ORG/T6-B2FR-PATCH");

    wait 1;
    if (isdefined(level.GAMEPLAY_REMINDER))
    {
        self thread [[level.GAMEPLAY_REMINDER]]();
    }
    else if (level.players.size > 1 && self ishost())
    {
        print_scheduler("^1REMINDER ^7You are a host", self);
        wait 0.25;
        print_scheduler("Full gameplay is required from host perspective as of April 2023", self);
    }
}

compose_welcome_print()
{
    out = array("PLUTONIUM " + COLOR_TXT(get_plutonium_version(), COL_RED));
    out[out.size] = get_session_status_as_txt();
    out[out.size] = get_connection_status_as_txt();
    if (is_plutonium_version(4843))
        out[out.size] = get_graphic_content_as_txt();
    return array_implode(" | ", out);
}

print_checksums()
{
    LEVEL_ENDON

    if (is_vanilla_map())
    {
        print_scheduler("Showing patch checksums", gethostplayer());
        cmdexec("flashScriptHashes");
    }

    if (getdvar("cg_drawChecksums") != "1")
    {
        setdvar("cg_drawChecksums", 1);
        wait 3;
        setdvar("cg_drawChecksums", 0);
    }
}

should_print_checksum()
{
    if (get_plutonium_version() < 4522 || did_game_just_start())
        return false;

    /* 50, 45, 40, 35 */
    faster = 50 - (5 * level.players.size);
    /* 70, 65, 60, 55 */
    if (is_town())
        faster = 75 - (5 * level.players.size);
    if (faster < 35)
        faster = 35;

    /* 19, 29, 39 and so on */
    if (level.round_number > 10 && level.round_number % 10 == 9)
        return true;
    /* Add .4 rounds past faster round */
    if (is_survival_map() && level.round_number > faster && level.round_number % 10 == 4)
        return true;
    return false;
}

set_dvar_internal(dvar)
{
    if (!isdefined(dvar))
        return;
    if (dvar.init_only && getdvar(dvar.name) != "")
        return;
    setdvar(dvar.name, dvar.value);
}

register_dvar(dvar, set_value, b2_protect, init_only, closure, on_change)
{
    if (isdefined(closure))
    {
        if (isarray(closure) && is_false(call_func_with_variadic_args(closure[0], array_shift(closure))))
        {
            return undefined;
        }
        else if (!isarray(closure) && ![[closure]]())
        {
            return undefined;
        }
    }

    dvar_data = SpawnStruct();
    dvar_data.name = dvar;
    dvar_data.value = set_value;
    dvar_data.protected = b2_protect;
    dvar_data.init_only = init_only;
    dvar_data.on_change = on_change;
    dvar_data.state = undefined;

    DEBUG_PRINT("registered dvar " + dvar);

    return dvar_data;
}

dvar_scanner(dvars)
{
    LEVEL_ENDON

    flag_wait("initial_blackscreen_passed");

    /* We're setting them once again, to ensure lack of accidental detections */
    for (i = 0; i < dvars.size; i++)
    {
        if (dvars[i].protected)
        {
            dvars[i].state = dvars[i].value;
            setdvar(dvars[i].name, dvars[i].state);
        }
    }

    while (true)
    {
        for (i = 0; i < dvars.size; i++)
        {
            current_state = undefined;
            if (dvars[i].protected || isdefined(dvars[i].on_change))
                current_state = getdvar(dvars[i].name);

            if (isdefined(current_state))
            {
                if (dvars[i].protected)
                {
                    if (current_state != dvars[i].value)
                    {
                        /* They're not reset here, someone might want to test something related to protected dvars, so they can do so with the watermark */
                        generate_watermark("DVAR " + toupper(dvars[i].name) + " VIOLATED", (1, 0.6, 0.2), 0.66);
                        setcheatstate();
                        dvars[i].protected = false;
                    }
                }

                if (isdefined(dvars[i].on_change) && dvars[i].state != current_state)
                {
                    DEBUG_PRINT("dvar onchange " + sstr(dvars[i].name) + ": " + sstr(dvars[i].state) + " != " + sstr(current_state));
                    if (!flag("b2_" + dvars[i].name + "_locked"))
                    {
                        reset = [[dvars[i].on_change]](current_state, dvars[i].name, gethostplayer());
                        if (reset)
                        {
                            setdvar(dvars[i].name, dvars[i].value);
                            current_state = dvars[i].value;
                        }
                    }
                }
                dvars[i].state = current_state;
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

#if DEBUG == 1
debug_mode()
{
    foreach (player in level.players)
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

    start_time = gettime();
    wait_network_frame();
    network_frame_len = gettime() - start_time;

    if ((level.players.size == 1 && network_frame_len == NET_FRAME_SOLO) || (level.players.size > 1 && network_frame_len == NET_FRAME_COOP))
    {
        print_scheduler("Network Frame: ^2GOOD", self);
        return;
    }

    print_scheduler("Network Frame: ^1BAD", self);
    level waittill("start_of_round");
    self thread evaluate_network_frame();
}

round_pulses()
{
    /* Original logic in ui_mp/t6/zombie/hudroundstatuszombie.lua::164 */
    round_pulse_times = ceil(LUI_ROUND_PULSE_TIMES_MIN + (1 - min(level.round_number, LUI_ROUND_MAX) / LUI_ROUND_MAX) * LUI_ROUND_PULSE_TIMES_DELTA);

    /* First transition from red to white */
    time = LUI_PULSE_DURATION;
    /* Pulse duration times 2, since pulse consists of 2 animations, use one less pulses due to last one being longer, it's evaluated next line */
    time += (LUI_PULSE_DURATION * 2) * (round_pulse_times - 1);
    /* Last pulse show white number, then fade out is longer */
    time += LUI_PULSE_DURATION + LUI_FIRST_ROUND_DURATION;
    /* Then fade in time of round number */
    time += LUI_FIRST_ROUND_DURATION;
    DEBUG_PRINT("round pulse time: " + time + " (round_pulse_times => " + round_pulse_times + ")");
    return time;
}

get_connection_status_as_txt()
{
    if (is_online_game())
        return COLOR_TXT("ONLINE", COL_GREEN);
    return COLOR_TXT("OFFLINE", COL_YELLOW);
}

get_session_status_as_txt()
{
    if (sessionmodeisprivate())
        return COLOR_TXT("PRIVATE", COL_GREEN);
    return COLOR_TXT("SOLO", COL_YELLOW);
}

get_graphic_content_as_txt()
{
    if (!is_mature())
        return COLOR_TXT("REDUCED GC", COL_YELLOW);
    return COLOR_TXT("UNRESTRICTED GC", COL_GREEN);
}

load_b2_splits()
{
    splits = [];
    if (is_io_available() && fs_testfile(SPLITS_FILE))
    {
        // DEBUG_PRINT("splits init");
        f = fs_fopen(SPLITS_FILE, "read");
        contents = fs_read(f);
        fs_fclose(f);

        // DEBUG_PRINT("splits loaded: " + sstr(contents));
        i = 0;
        foreach (val in strtok(contents, "\n"))
        {
            if (i > 255) {
                break;
            }
            // DEBUG_PRINT("split candidate from IO: " + sstr(val));
            number = int(val);
            if (isint(number) && number)
                splits[splits.size] = number;
            i++;
        }
        DEBUG_PRINT("splits loaded from IO: " + sstr(splits));
    }
    return splits;
}

nuketown_gameplay_reminder()
{
    // 804.1 -56.86
    // -455.42 617.4
    // -82.07 740.67
    // -844.93 60.8

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
        {
            print_scheduler("JuggerNog in the first room! Full gameplay from all players will be required!", self);
        }
        else if (self ishost())
        {
            print_scheduler("^1REMINDER ^7You are a host", self);
            wait 0.25;
            print_scheduler("Full gameplay is required from host perspective as of April 2023", self);
        }
    }
}

origins_fix()
{
    LEVEL_ENDON

    flag_wait("start_zombie_round_logic");
    wait 0.5;

    if (is_origins() && !is_plutonium_version(VER_4K))
    {
        level.is_forever_solo_game = 0;
    }
}

#if FEATURE_NUKETOWN_EYES == 1
nuketown_switch_eyes()
{
    level setclientfield("zombie_eye_change", 1);
    sndswitchannouncervox("richtofen");
}
#endif

/*
 ************************************************************************************************************
 ************************************************** STUBS ***************************************************
 ************************************************************************************************************
*/

cmdexec(arg)
{

}

fs_testfile(arg)
{

}

fs_fopen(arg1, arg2)
{

}

fs_write(arg1, arg2)
{

}

fs_writeline(arg1, arg2)
{

}

fs_readline(arg1, arg2)
{

}

fs_read(arg)
{

}

fs_fcloseall()
{

}

fs_fclose(arg)
{

}

fs_length(arg)
{

}

fs_getseek(arg)
{

}

fs_seek(arg1, arg2)
{

}

fs_remove(arg1, arg2)
{

}

fs_listfiles(arg)
{

}

setcheatstate()
{

}

/*
 ************************************************************************************************************
 *************************************************** HUD ****************************************************
 ************************************************************************************************************
*/

#if FEATURE_HUD == 1
kill_hud()
{
    flag_set("b2_killed_hud");
    if (isdefined(level.timer_hud))
        level.timer_hud destroyelem();
    if (isdefined(level.round_hud))
        level.round_hud destroyelem();
    return true;
}

create_timers()
{
    level.timer_hud = createserverfontstring("big" , 1.6);
    level.timer_hud set_hud_properties("timer_hud", "TOPRIGHT", "TOPRIGHT", 60, -14);
    level.timer_hud.alpha = 1;
    level.timer_hud settimerup(0);

    level.round_hud = createserverfontstring("big" , 1.6);
    level.round_hud set_hud_properties("round_hud", "TOPRIGHT", "TOPRIGHT", 60, 3);
    level.round_hud.alpha = 1;
    level.round_hud settext("0:00");

    timers_alpha(getdvar("timers"));
}

timers_alpha(value)
{
    if (isdefined(level.timer_hud) && level.timer_hud.alpha != int(value))
        level.timer_hud.alpha = int(value);
    if (isdefined(level.round_hud) && level.round_hud.alpha != int(value))
        level.round_hud.alpha = int(value);
    return false;
}

keep_displaying_old_time(time)
{
    LEVEL_ENDON
    level endon("start_of_round");

    while (true)
    {
        self settimer(MS_TO_SECONDS(time) - 0.1);
        wait 0.25;
    }
}

show_split(start_time)
{
    LEVEL_ENDON

    if (getdvar("splits") == "0")
        return;

    b2_splits = load_b2_splits();
    /* Allow loading splits from IO */
    if (b2_splits.size && !isinarray(b2_splits, level.round_number))
        return;
    /* By default every 5 rounds past 10 */
    if (!b2_splits.size && (level.round_number <= 10 || level.round_number % 5))
        return;

    wait MS_TO_SECONDS(round_pulses());

    timestamp = convert_time(MS_TO_SECONDS((gettime() - start_time)));
    print_scheduler("Round " + level.round_number + " time: " + COLOR_TXT(timestamp, COL_RED));

    if (!is_plutonium_version(4837))
        print_scheduler("UTC: " + COLOR_TXT(getutc(), COL_RED));
}

#if FEATURE_HORDES == 1
show_hordes()
{
    LEVEL_ENDON

    if (getdvar("hordes") == "0")
        return;

    wait 0.05;

    if (!is_special_round() && is_round(20))
    {
        zombies_value = get_hordes_left();
        print_scheduler("HORDES ON " + level.round_number + ": " + COLOR_TXT(zombies_value, COL_YELLOW));
    }
}
#endif

set_hud_properties(hud_key, alignment, relative, x_pos, y_pos, col)
{
    if (!isdefined(col))
        col = (1, 1, 1);

    res_components = strtok(getdvar("r_mode"), "x");
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
        x_pos = recalculate_x_for_aspect_ratio(alignment, x_pos, aspect_ratio);

    // DEBUG_PRINT("ratio: " + ratio + " | aspect_ratio: " + aspect_ratio + " | x_pos: " + x_pos + " | w: " + res_components[0] + " | h: " + res_components[1]);

    self setpoint(alignment, relative, x_pos, y_pos);
    self.color = col;
}

recalculate_x_for_aspect_ratio(alignment, xpos, aspect_ratio)
{
    if (level.players.size > 1)
        return xpos;

    if (issubstr(tolower(alignment), "left") && xpos < 0)
    {
        if (aspect_ratio == 1610)
            return xpos + 6;
        if (aspect_ratio == 43)
            return xpos + 14;
        if (aspect_ratio == 2109)
            return xpos - 21;
    }

    else if (issubstr(tolower(alignment), "right") && xpos > 0)
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

#if FEATURE_VELOCITY_METER == 1
velocity_meter()
{
    PLAYER_ENDON

    flag_wait("initial_blackscreen_passed");

    self.hud_velocity = createfontstring("default" , 1.1);
    self.hud_velocity set_hud_properties("hud_velocity", "CENTER", "CENTER", "CENTER", 200);
    self.hud_velocity.alpha = 0.75;
    self.hud_velocity.hidewheninmenu = 1;

    while (true)
    {
        self velocity_visible(self.hud_velocity);

        velocity = int(length(self getvelocity() * (1, 1, 1)));
        if (!self isonground())
            velocity = int(length(self getvelocity() * (1, 1, 0)));

        self.hud_velocity velocity_meter_scale(velocity);
        self.hud_velocity setValue(velocity);

        wait 0.05;
    }
}

velocity_visible(hud)
{
    if (getdvar("velocity_meter") == "0" || is_true(self.afterlife))
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
#endif

#if FEATURE_SEMTEX_CALC_PRENADE == 1
recalculate_semtex_prenades()
{
    if (!isdefined(level.b2_semtex_prenades))
    {
        return;
    }

    level.b2_semtex_prenades = 0;
    if (is_dynamic_prenade_calculation())
    {
        level.b2_semtex_prenades = get_prenade_dynamic();
    }
    else if (is_round(SEMTEX_BEGIN_PRENADES_RND))
    {
        level.b2_semtex_prenades = SEMTEX_PRENADES_MAP[level.round_number - SEMTEX_BEGIN_PRENADES_RND];
    }
}

print_semtex_prenades()
{
    if (is_true(level.b2_semtex_prenades))
    {
        print_content = "PRENADES ON " + level.round_number + ": " + COLOR_TXT(level.b2_semtex_prenades, COL_YELLOW);
        print_scheduler(print_content);
    }
}

get_prenade_dynamic()
{
    if (!isdefined(level.b2_semtex_prenades))
    {
        return;
    }

    /* Failsafe for starting game at 50 or higher */
    previous = level.b2_semtex_prenades;
    if (!previous)
    {
        previous = SEMTEX_PRENADES_MAP[SEMTEX_PRENADES_MAP.size - 1];
    }

    calculated_round = level.round_number + 1;
    dmg_curve = int((-0.958 * 128) + 300);
    dmg_semtex = int(dmg_curve + 150 + calculated_round);

    zm_health = int(level.zombie_health * 1.1) - (dmg_semtex * previous);

    for (i = 0; dmg_semtex / zm_health < 0.1; previous++)
    {
        zm_health -= dmg_semtex;
    }

    return previous;
}
#endif
#endif

/*
 ************************************************************************************************************
 ******************************************* PERMAPERKS / BANK **********************************************
 ************************************************************************************************************
*/

fill_up_bank()
{
    PLAYER_ENDON

    flag_wait("initial_blackscreen_passed");

    if (has_permaperks_system() && did_game_just_start())
    {
        self.account_value = level.bank_account_max;
    }
}

perma_perks_setup()
{
    if (!has_permaperks_system())
        return;

    thread fix_persistent_jug();

#if FEATURE_PERMAPERKS == 1
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

#if FEATURE_HUD == 1
    array_thread(level.players, ::permaperks_watcher);
#endif
#endif
}

/* If client stat (prefixed with 'pers_') is passed to perk_code, it tries to do it with existing system */
remove_permaperk_wrapper(perk_code, round)
{
    if (!isdefined(round))
        round = 1;

    if (is_round(round) && issubstr(perk_code, "pers_"))
        self maps\mp\zombies\_zm_stats::zero_client_stat(perk_code, 0);
    else if (is_round(round) && is_true(self.pers_upgrades_awarded[perk_code]))
        self remove_permaperk(perk_code);
}

remove_permaperk(perk_code)
{
    // DEBUG_PRINT("removing: " + perk_code);
    self.pers_upgrades_awarded[perk_code] = 0;
    self playsoundtoplayer("evt_player_downgrade", self);
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

    while (!isdefined(level.pers_upgrades["jugg"]))
        wait 0.05;

    level.pers_upgrades["jugg"].upgrade_active_func = ::fixed_upgrade_jugg_active;
    flag_wait("pers_jug_cleared");
    wait 0.5;

    arrayremoveindex(level.pers_upgrades, "jugg");
    arrayremovevalue(level.pers_upgrades_keys, "jugg");
    DEBUG_PRINT("upgrade_keys => " + array_implode(", ", level.pers_upgrades_keys));
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

#if FEATURE_PERMAPERKS == 1
watch_permaperk_award()
{
    LEVEL_ENDON

    present_players = level.players.size;

    while (true)
    {
        i = 0;
        foreach (player in level.players)
        {
            if (!isdefined(player.awarding_permaperks_now))
                i++;
        }

        if (i == present_players && flag("b2_permaperks_were_set"))
        {
            print_scheduler("Permaperks Awarded - ^1RESTARTING");
            wait 1;

            if (get_plutonium_version() > VER_MODERN || present_players == 1)
                emulate_menu_call("restart_level_zm");
            else
                emulate_menu_call("endround");
            break;
        }

        if (!did_game_just_start())
            break;

        wait 0.1;
    }

    foreach (player in level.players)
    {
        if (isdefined(player.awarding_permaperks_now))
            CLEAR(player.awarding_permaperks_now)
    }
}

permaperk_array(code, maps_award, maps_take, to_round)
{
    if (!isdefined(maps_award))
        maps_award = array("zm_transit", "zm_highrise", "zm_buried");
    if (!isdefined(maps_take))
        maps_take = [];
    if (!isdefined(to_round))
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

resolve_permaperk(perk)
{
    PLAYER_ENDON

    wait 0.05;

    perk_code = perk["code"];

    /* Too high of a round, return out */
    if (is_round(perk["to_round"]))
        return;

    if (isinarray(perk["maps_award"], level.script) && is_false(self.pers_upgrades_awarded[perk_code]))
    {
        for (j = 0; j < level.pers_upgrades[perk_code].stat_names.size; j++)
        {
            stat_name = level.pers_upgrades[perk_code].stat_names[j];
            stat_value = level.pers_upgrades[perk_code].stat_desired_values[j];

            self award_permaperk(stat_name, perk_code, stat_value);
        }
    }

    if (isinarray(perk["maps_take"], level.script) && is_true(self.pers_upgrades_awarded[perk_code]))
    {
        self remove_permaperk(perk_code);
    }
}

award_permaperk(stat_name, perk_code, stat_value)
{
    // DEBUG_PRINT("awarding: " + stat_name + " " + perk_code + " " + stat_value);
    flag_set("b2_permaperks_were_set");
    self.stats_this_frame[stat_name] = 1;
    self maps\mp\zombies\_zm_stats::set_global_stat(stat_name, stat_value);
    self playsoundtoplayer("evt_player_upgrade", self);
}

#if FEATURE_HUD == 1
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

    print_scheduler("Permaperk " + permaperk_name(perk) + ": " + print_player, self);
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

/*
 ************************************************************************************************************
 ******************************************* Shared box logic ***********************************************
 ************************************************************************************************************
*/

watch_box_state()
{
    LEVEL_ENDON

    while (!isdefined(self.zbarrier))
        wait 0.05;

    while (true)
    {
        while (self.zbarrier getzbarrierpiecestate(2) != "opening")
            wait 0.05;
        level.total_box_hits++;

        self.zbarrier thread scan_in_box();

        self.zbarrier waittill("randomization_done");
        wait 0.05;
        level notify("b2_box_restore");
        DEBUG_PRINT("emit 'b2_box_restore'");
    }
}

scan_in_box()
{
    self notify("scan_in_box_start");

    LEVEL_ENDON
    self endon("randomization_done");
    self endon("scan_in_box_start");

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

    while (true)
    {
        wait 0.05;

        in_box = 0;

        foreach (weapon in getarraykeys(level.zombie_weapons))
        {
            if (maps\mp\zombies\_zm_weapons::get_is_in_box(weapon))
                in_box++;
        }

        // DEBUG_PRINT("scanning in box " + in_box + "/" + should_be_in_box);

        if (in_box == should_be_in_box)
            continue;
        if ((offset > 0) && (in_box == (should_be_in_box + offset)))
            continue;

        thread generate_watermark("BOX MANIPULATION", (1, 0.6, 0.2), 0.66);
        break;
    }
}

/*
 ************************************************************************************************************
 *********************************************** CHARACTERS *************************************************
 ************************************************************************************************************
*/

#if FEATURE_CHARACTERS == 1
hijack_personality_character()
{
    LEVEL_ENDON

    while (!isdefined(level.givecustomcharacters))
        wait 0.05;
    if (is_survival_map())
    {
        level.old_givecustomcharacters = level.givecustomcharacters;
        level.givecustomcharacters = ::override_team_character;
        return;
    }
    level.old_givecustomcharacters = level.givecustomcharacters;
    level.givecustomcharacters = ::override_personality_character;
}

override_personality_character()
{
    /* I need to run this check as original function also does it and it prevents setting the index too quick ... i think */
    if (run_default_character_hotjoin_safety())
        return;

    preset = self parse_preset(get_stat_for_map(), array(1, 2, 3, 4));
    charindex = preset - 1;
    if (preset > 0 && !flag("b2_char_taken_" + charindex))
    {
        /* Need to assign level checks for coop specific logic in original callbacks */
        if (is_mob() && charindex == 3)
            level.has_weasel = true;
        else if (is_origins() && charindex == 2)
            level.has_richtofen = true;

        self.characterindex = charindex;
        DEBUG_PRINT(self.name + " set character " + charindex);
    }

    self [[level.old_givecustomcharacters]]();
    /* Set it here, to avoid duplicates when some players don't have presets */
    flag_set("b2_char_taken_" + self.characterindex);
}

override_team_character()
{
    /* I need to run this check as original function also does it and it prevents setting the index too quick ... i think */
    if (run_default_character_hotjoin_safety())
        return;

    if (!flag("b2_char_taken_0") && !flag("b2_char_taken_1"))
    {
        preset = gethostplayer() parse_preset(get_stat_for_map(), array(1, 2));
        charindex = preset - 1;
        flag_set("b2_char_taken_" + charindex);
        level.should_use_cia = charindex;
        DEBUG_PRINT("Set character " + level.should_use_cia);
    }

    self [[level.old_givecustomcharacters]]();
}

parse_preset(stat, allowed_presets)
{
    if (is_online_game())
    {
        preset = int(self maps\mp\zombies\_zm_stats::get_map_weaponlocker_stat(stat, "zm_highrise"));
    }
    else
    {
        preset = getdvarint("set_character");
    }

    /* Validation */
    if (isinarray(allowed_presets, preset))
    {
        return preset;
    }
    return 0;
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
    flag_clear("b2_char_taken_" + self.characterindex);
    DEBUG_PRINT("clearing flag: b2_char_taken_" + self.characterindex);

    /* Need to invoke original callback afterwards */
    self maps\mp\gametypes_zm\_globallogic_player::callback_playerdisconnect();
}

run_default_character_hotjoin_safety()
{
    if (is_survival_map())
    {
        if (isdefined(level.hotjoin_player_setup) && [[level.hotjoin_player_setup]]("c_zom_suit_viewhands"))
            return true;
    }
    else if (is_tranzit() || is_die_rise() || is_buried())
    {
        if (isdefined(level.hotjoin_player_setup) && [[level.hotjoin_player_setup]]("c_zom_farmgirl_viewhands"))
            return true;
    }
    /* Origins is not a mistake, they do use arlington there originally */
    else if (is_mob() || is_origins())
    {
        if (isdefined(level.hotjoin_player_setup) && [[level.hotjoin_player_setup]]("c_zom_arlington_coat_viewhands"))
            return true;
    }
    return false;
}

characters_input(value, key, player)
{
    if (!did_game_just_start())
    {
        return true;
    }

    switch (value)
    {
        case "russman":
        case "oldman":
            player maps\mp\zombies\_zm_stats::set_map_weaponlocker_stat("clip", 1, "zm_highrise");
            print_scheduler("Successfully updated character settings to: " + COLOR_TXT("Russman", COL_YELLOW), player);
            break;
        case "marlton":
        case "reporter":
            player maps\mp\zombies\_zm_stats::set_map_weaponlocker_stat("clip", 4, "zm_highrise");
            print_scheduler("Successfully updated character settings to: " + COLOR_TXT("Stuhlinger", COL_YELLOW), player);
            break;
        case "misty":
        case "farmgirl":
            player maps\mp\zombies\_zm_stats::set_map_weaponlocker_stat("clip", 3, "zm_highrise");
            print_scheduler("Successfully updated character settings to: " + COLOR_TXT("Misty", COL_YELLOW), player);
            break;
        case "stuhlinger":
        case "engineer":
            player maps\mp\zombies\_zm_stats::set_map_weaponlocker_stat("clip", 2, "zm_highrise");
            print_scheduler("Successfully updated character settings to: " + COLOR_TXT("Marlton", COL_YELLOW), player);
            break;

        case "finn":
        case "oleary":
        case "shortsleeve":
            player maps\mp\zombies\_zm_stats::set_map_weaponlocker_stat("stock", 1, "zm_highrise");
            print_scheduler("Successfully updated character settings to: " + COLOR_TXT("Finn", COL_YELLOW), player);
            break;
        case "sal":
        case "deluca":
        case "longsleeve":
            player maps\mp\zombies\_zm_stats::set_map_weaponlocker_stat("stock", 2, "zm_highrise");
            print_scheduler("Successfully updated character settings to: " + COLOR_TXT("Sal", COL_YELLOW), player);
            break;
        case "billy":
        case "handsome":
        case "sleeveless":
            player maps\mp\zombies\_zm_stats::set_map_weaponlocker_stat("stock", 3, "zm_highrise");
            print_scheduler("Successfully updated character settings to: " + COLOR_TXT("Billy", COL_YELLOW), player);
            break;
        case "weasel":
        case "arlington":
            player maps\mp\zombies\_zm_stats::set_map_weaponlocker_stat("stock", 4, "zm_highrise");
            print_scheduler("Successfully updated character settings to: " + COLOR_TXT("Weasel", COL_YELLOW), player);
            break;

        case "dempsey":
            player maps\mp\zombies\_zm_stats::set_map_weaponlocker_stat("alt_clip", 1, "zm_highrise");
            print_scheduler("Successfully updated character settings to: " + COLOR_TXT("Dempsey", COL_YELLOW), player);
            break;
        case "nikolai":
            player maps\mp\zombies\_zm_stats::set_map_weaponlocker_stat("alt_clip", 2, "zm_highrise");
            print_scheduler("Successfully updated character settings to: " + COLOR_TXT("Nikolai", COL_YELLOW), player);
            break;
        case "richtofen":
            player maps\mp\zombies\_zm_stats::set_map_weaponlocker_stat("alt_clip", 3, "zm_highrise");
            print_scheduler("Successfully updated character settings to: " + COLOR_TXT("Richtofen", COL_YELLOW), player);
            break;
        case "takeo":
            player maps\mp\zombies\_zm_stats::set_map_weaponlocker_stat("alt_clip", 4, "zm_highrise");
            print_scheduler("Successfully updated character settings to: " + COLOR_TXT("Takeo", COL_YELLOW), player);
            break;

        case "cdc":
            player maps\mp\zombies\_zm_stats::set_map_weaponlocker_stat("lh_clip", 1, "zm_highrise");
            print_scheduler("Successfully updated character settings to: " + COLOR_TXT("CDC", COL_YELLOW), player);
            break;
        case "cia":
            player maps\mp\zombies\_zm_stats::set_map_weaponlocker_stat("lh_clip", 2, "zm_highrise");
            print_scheduler("Successfully updated character settings to: " + COLOR_TXT("CIA", COL_YELLOW), player);
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

viewmodel_input(value, key, player)
{
    DEBUG_PRINT("viewmodel_input: '" + sstr(value) + "' for " + player.name);
    switch (value)
    {
        case "russman":
        case "oldman":
            if (is_victis_map())
            {
                player setviewmodel("c_zom_oldman_viewhands");
                print_scheduler("Successfully set viewmodel to: " + COLOR_TXT("Russman", COL_YELLOW), player);
            }
            break;
        case "marlton":
        case "reporter":
            if (is_victis_map())
            {
                player setviewmodel("c_zom_reporter_viewhands");
                print_scheduler("Successfully set viewmodel to: " + COLOR_TXT("Stuhlinger", COL_YELLOW), player);
            }
            break;
        case "misty":
        case "farmgirl":
            if (is_victis_map())
            {
                player setviewmodel("c_zom_farmgirl_viewhands");
                print_scheduler("Successfully set viewmodel to: " + COLOR_TXT("Misty", COL_YELLOW), player);
            }
            break;
        case "stuhlinger":
        case "engineer":
            if (is_victis_map())
            {
                player setviewmodel("c_zom_engineer_viewhands");
                print_scheduler("Successfully set viewmodel to: " + COLOR_TXT("Marlton", COL_YELLOW), player);
            }
            break;

        case "finn":
        case "oleary":
        case "shortsleeve":
            if (is_mob())
            {
                player setviewmodel("c_zom_oleary_shortsleeve_viewhands");
                print_scheduler("Successfully set viewmodel to: " + COLOR_TXT("Finn", COL_YELLOW), player);
            }
            break;
        case "sal":
        case "deluca":
        case "longsleeve":
            if (is_mob())
            {
                player setviewmodel("c_zom_deluca_longsleeve_viewhands");
                print_scheduler("Successfully set viewmodel to: " + COLOR_TXT("Sal", COL_YELLOW), player);
            }
            break;
        case "billy":
        case "handsome":
        case "sleeveless":
            if (is_mob())
            {
                player setviewmodel("c_zom_handsome_sleeveless_viewhands");
                print_scheduler("Successfully set viewmodel to: " + COLOR_TXT("Billy", COL_YELLOW), player);
            }
            break;
        case "weasel":
        case "arlington":
            if (is_mob())
            {
                player setviewmodel("c_zom_arlington_coat_viewhands");
                print_scheduler("Successfully set viewmodel to: " + COLOR_TXT("Weasel", COL_YELLOW), player);
            }
            break;

        case "dempsey":
            if (is_origins())
            {
                player setviewmodel("c_zom_dempsey_viewhands");
                print_scheduler("Successfully set viewmodel to: " + COLOR_TXT("Dempsey", COL_YELLOW), player);
            }
            break;
        case "nikolai":
            if (is_origins())
            {
                player setviewmodel("c_zom_nikolai_viewhands");
                print_scheduler("Successfully set viewmodel to: " + COLOR_TXT("Nikolai", COL_YELLOW), player);
            }
            break;
        case "richtofen":
            if (is_origins())
            {
                player setviewmodel("c_zom_richtofen_viewhands");
                print_scheduler("Successfully set viewmodel to: " + COLOR_TXT("Richtofen", COL_YELLOW), player);
            }
            break;
        case "takeo":
            if (is_origins())
            {
                player setviewmodel("c_zom_takeo_viewhands");
                print_scheduler("Successfully set viewmodel to: " + COLOR_TXT("Takeo", COL_YELLOW), player);
            }
            break;

        case "cdc":
            if (is_nuketown())
            {
                player setviewmodel("c_zom_hazmat_viewhands_light");
                print_scheduler("Successfully set viewmodel to: " + COLOR_TXT("CDC", COL_YELLOW), player);
            }
            else if (is_survival_map())
            {
                player setviewmodel("c_zom_hazmat_viewhands");
                print_scheduler("Successfully set viewmodel to: " + COLOR_TXT("CDC", COL_YELLOW), player);
            }
            break;
        case "cia":
            if (is_survival_map())
            {
                player setviewmodel("c_zom_suit_viewhands");
                print_scheduler("Successfully set viewmodel to: " + COLOR_TXT("CIA", COL_YELLOW), player);
            }
            break;

        case "reset":
            to_reset = undefined;
            switch (player.characterindex)
            {
                case 0:
                    if (is_survival_map() && player getviewmodel() != "c_zom_suit_viewhands")
                    {
                        to_reset = "c_zom_suit_viewhands";
                    }
                    else if (is_victis_map() && player getviewmodel() != "c_zom_oldman_viewhands")
                    {
                        to_reset = "c_zom_oldman_viewhands";
                    }
                    else if (is_mob() && player getviewmodel() != "c_zom_oleary_shortsleeve_viewhands")
                    {
                        to_reset = "c_zom_oleary_shortsleeve_viewhands";
                    }
                    else if (is_origins() && player getviewmodel() != "c_zom_dempsey_viewhands")
                    {
                        to_reset = "c_zom_dempsey_viewhands";
                    }
                    break;
                case 1:
                    if (is_nuketown() && player getviewmodel() != "c_zom_hazmat_viewhands")
                    {
                        to_reset = "c_zom_hazmat_viewhands";
                    }
                    else if (is_survival_map() && player getviewmodel() != "c_zom_hazmat_viewhands_light")
                    {
                        to_reset = "c_zom_hazmat_viewhands_light";
                    }
                    else if (is_victis_map() && player getviewmodel() != "c_zom_reporter_viewhands")
                    {
                        to_reset = "c_zom_reporter_viewhands";
                    }
                    else if (is_mob() && player getviewmodel() != "c_zom_deluca_longsleeve_viewhands")
                    {
                        to_reset = "c_zom_deluca_longsleeve_viewhands";
                    }
                    else if (is_origins() && player getviewmodel() != "c_zom_nikolai_viewhands")
                    {
                        to_reset = "c_zom_nikolai_viewhands";
                    }
                    break;
                case 2:
                    if (is_survival_map() && player getviewmodel() != "c_zom_suit_viewhands")
                    {
                        to_reset = "c_zom_suit_viewhands";
                    }
                    else if (is_victis_map() && player getviewmodel() != "c_zom_farmgirl_viewhands")
                    {
                        to_reset = "c_zom_farmgirl_viewhands";
                    }
                    else if (is_mob() && player getviewmodel() != "c_zom_handsome_sleeveless_viewhands")
                    {
                        to_reset = "c_zom_handsome_sleeveless_viewhands";
                    }
                    else if (is_origins() && player getviewmodel() != "c_zom_richtofen_viewhands")
                    {
                        to_reset = "c_zom_richtofen_viewhands";
                    }
                    break;
                case 3:
                    if (is_nuketown() && player getviewmodel() != "c_zom_hazmat_viewhands")
                    {
                        to_reset = "c_zom_hazmat_viewhands";
                    }
                    else if (is_survival_map() && player getviewmodel() != "c_zom_hazmat_viewhands_light")
                    {
                        to_reset = "c_zom_hazmat_viewhands_light";
                    }
                    else if (is_victis_map() && player getviewmodel() != "c_zom_engineer_viewhands")
                    {
                        to_reset = "c_zom_engineer_viewhands";
                    }
                    else if (is_mob() && player getviewmodel() != "c_zom_arlington_coat_viewhands")
                    {
                        to_reset = "c_zom_arlington_coat_viewhands";
                    }
                    else if (is_origins() && player getviewmodel() != "c_zom_takeo_viewhands")
                    {
                        to_reset = "c_zom_takeo_viewhands";
                    }
                    break;
            }

            if (isdefined(to_reset))
            {
                player setviewmodel(to_reset);
                print_scheduler("Viewmodel has been reset", player);
            }
            break;
    }

    return true;
}

check_whoami(value, key, player)
{
    switch (player maps\mp\zombies\_zm_stats::get_map_weaponlocker_stat(get_stat_for_map(), "zm_highrise"))
    {
        case 1:
            if (is_victis_map())
                print_scheduler("Your preset is: " + COLOR_TXT("Russman", COL_YELLOW), player);
            else if (is_mob())
                print_scheduler("Your preset is: " + COLOR_TXT("Finn", COL_YELLOW), player);
            else if (is_origins())
                print_scheduler("Your preset is: " + COLOR_TXT("Dempsey", COL_YELLOW), player);
            else
                print_scheduler("Your preset is: " + COLOR_TXT("CDC", COL_YELLOW), player);
            break;
        case 2:
            if (is_victis_map())
                print_scheduler("Your preset is: " + COLOR_TXT("Stuhlinger", COL_YELLOW), player);
            else if (is_mob())
                print_scheduler("Your preset is: " + COLOR_TXT("Sal", COL_YELLOW), player);
            else if (is_origins())
                print_scheduler("Your preset is: " + COLOR_TXT("Nikolai", COL_YELLOW), player);
            else
                print_scheduler("Your preset is: " + COLOR_TXT("CIA", COL_YELLOW), player);
            break;
        case 3:
            if (is_victis_map())
                print_scheduler("Your preset is: " + COLOR_TXT("Misty", COL_YELLOW), player);
            else if (is_mob())
                print_scheduler("Your preset is: " + COLOR_TXT("Billy", COL_YELLOW), player);
            else if (is_origins())
                print_scheduler("Your preset is: " + COLOR_TXT("Richtofen", COL_YELLOW), player);
            else
                print_scheduler("You don't currently have any character preset", player);
            break;
        case 4:
            if (is_victis_map())
                print_scheduler("Your preset is: " + COLOR_TXT("Marlton", COL_YELLOW), player);
            else if (is_mob())
                print_scheduler("Your preset is: " + COLOR_TXT("Weasel", COL_YELLOW), player);
            else if (is_origins())
                print_scheduler("Your preset is: " + COLOR_TXT("Takeo", COL_YELLOW), player);
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
#endif

/*
 ************************************************************************************************************
 *********************************************** CHALLENGES *************************************************
 ************************************************************************************************************
*/

#if FEATURE_CHALLENGES == 1
b2fr_challenge_loop()
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

/*
 ************************************************************************************************************
 ************************************************* DEBUG ****************************************************
 ************************************************************************************************************
*/

#if DEBUG == 1
_dvar_reader(dvar)
{
    DEBUG_PRINT("DVAR " + dvar + " => " + getdvar(dvar));
    return true;
}

_create_file(path)
{
    f = fs_fopen(path, "write");
    fs_write("test");
    fs_fclose(f);
}

_custom_start_round()
{
    LEVEL_ENDON

    if (getdvar("startRound") == "")
    {
        setdvar("startRound", "0");
        return;
    }
    while (!is_true(level.round_number))
    {
        wait 0.05;
    }
    dvar = getdvarint("startRound");
    if (dvar > 0)
    {
        level.round_number = dvar;
    }
}

#if DEBUG_HUD == 1 && FEATURE_HUD == 1
_network_frame_hud()
{
    LEVEL_ENDON
    netframe_hud = createserverfontstring("default", 1.3);
    netframe_hud set_hud_properties("netframe_hud", "CENTER", "BOTTOM", 0, 28);
    netframe_hud.label = &"NETFRAME: ";
    netframe_hud.alpha = 1;
    while (true)
    {
        start_time = gettime();
        wait_network_frame();
        end_time = gettime();
        netframe_hud setvalue(end_time - start_time);
    }
}

_zone_hud()
{
    PLAYER_ENDON

    flag_wait("initial_blackscreen_passed");

    self thread _get_my_coordinates();

    self.hud_zone = createfontstring("objective" , 1.2);
    self.hud_zone setpoint("CENTER", "BOTTOM", 0, 20);
    self.hud_zone.alpha = 0.8;

    old_zonename = "old";
    new_zonename = "new";

    while (true)
    {
        wait 0.05;

        if (!isalive(self))
            continue;

        new_zonename = self get_current_zone();

        if (old_zonename == new_zonename)
            continue;

        self notify("stop_showing_zone");

        self thread _show_zone(new_zonename, self.hud_zone);

        old_zonename = new_zonename;
    }
}

_show_zone(zone, hud)
{
    level endon("end_game");
    self endon("disconnect");
    self endon("stop_showing_zone");

    if (hud.alpha != 0)
    {
        hud fadeovertime(0.5);
        hud.alpha = 0;
        wait 0.5;
    }

    hud settext(zone);

    hud fadeovertime(0.5);
    hud.alpha = 0.8;

    wait 3;

    hud fadeovertime(0.5);
    hud.alpha = 0;
}

_get_my_coordinates()
{
    self.coordinates_x_hud = createfontstring("objective" , 1.1);
    self.coordinates_x_hud setpoint("CENTER", "BOTTOM", -40, 10);
    self.coordinates_x_hud.alpha = 0.66;
    self.coordinates_x_hud.color = (1, 1, 1);
    self.coordinates_x_hud.hidewheninmenu = 0;

    self.coordinates_y_hud = createfontstring("objective" , 1.1);
    self.coordinates_y_hud setpoint("CENTER", "BOTTOM", 0, 10);
    self.coordinates_y_hud.alpha = 0.66;
    self.coordinates_y_hud.color = (1, 1, 1);
    self.coordinates_y_hud.hidewheninmenu = 0;

    self.coordinates_z_hud = createfontstring("objective" , 1.1);
    self.coordinates_z_hud setpoint("CENTER", "BOTTOM", 40, 10);
    self.coordinates_z_hud.alpha = 0.66;
    self.coordinates_z_hud.color = (1, 1, 1);
    self.coordinates_z_hud.hidewheninmenu = 0;

    while (true)
    {
        self.coordinates_x_hud setvalue(naive_round(self.origin[0]));
        self.coordinates_y_hud setvalue(naive_round(self.origin[1]));
        self.coordinates_z_hud setvalue(naive_round(self.origin[2]));

        wait 0.05;
    }
}
#endif
#endif
