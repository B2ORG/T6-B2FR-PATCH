#include common_scripts/utility;
#include maps/mp/_utility;
#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/zombies/_zm_stats;
#include maps/mp/zombies/_zm_weapons;
#include maps/mp/animscripts/zm_utility;
#include maps/mp/zm_prison;
#include maps/mp/zm_tomb;
#include maps/mp/zm_tomb_utility;
#include maps/mp/zombies/_zm_audio;
#include maps/mp/zombies/_zm_net;

init()
{
	flag_init("dvars_set");
	flag_init("cheat_printed_backspeed");
	flag_init("cheat_printed_noprint");
	flag_init("cheat_printed_cheats");
	flag_init("cheat_printed_gspeed");

	flag_init("game_started");

	// Patch Config
	level.FRFIX_ACTIVE = true;
	level.FRFIX_VER = 5.1;
	level.FRFIX_BETA = "(REDACTED)";
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
	level.FRFIX_YELLOWHOUSE = false;
	level.FRFIX_NUKETOWN_EYES = false;
	level.FRFIX_PRENADES = false;

	level thread OnPlayerJoined();

	level waittill("initial_players_connected");

	// Initial game settings
	level thread SetDvars();
	level thread DvarDetector();
	level thread EyeChange();

	flag_wait("initial_blackscreen_passed");

	level.FRFIX_START = int(getTime() / 1000);
	flag_set("game_started");

	// HUD
	level thread BasicSplitsHud();
	level thread TimerHud();
	level thread RoundTimerHud();
	level thread SplitsTimerHud();
	level thread ZombiesHud();
	level thread SemtexChart();

	// Game settings
	SongSafety();
	level thread NukeMannequins();

	level waittill("end_game");
}

OnPlayerJoined()
{
	for(;;)
	{
		level waittill("connected", player);
		player thread OnPlayerSpawned();
	}
}

OnPlayerSpawned()
{
    level endon("game_ended");
    self endon("disconnect");

	self.initial_spawn = true;

	for(;;)
	{
		self waittill("spawned_player");

		if (self.initial_spawn)
		{
			self.initial_spawn = false;

			self iPrintLn("^1FIRST ROOM FIX V" + level.FRFIX_VER + " " + level.FRFIX_BETA);
			self thread PrintNetworkFrame(6);
			self thread AwardPermaPerks();
			self thread VelocityMeter();
		}
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

PlayerThreadBlackscreenWaiter()
{
    while (!flag("game_started"))
        wait 0.05;
    return;
}

// Functions

SetDvars()
{
	setDvar("timer_left", 0);

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
			
			level notify("reset_dvars");
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

			level notify("reset_dvars");
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

			level notify("reset_dvars");
		}

		// Gspeed
		if (getDvar("g_speed") != "190") 
		{
			if (!flag("cheat_printed")) 
			{
				level thread CreateWarningHud(cool_message, 0);
				flag_set("cheat_printed");
			}
			
			if (!flag("cheat_printed_gspeed"))
			{
				level thread CreateWarningHud("g_speed Attempted.", 90);
				flag_set("cheat_printed_gspeed");
			}

			level notify("reset_dvars");
		}
		wait 0.1;
	}
}

PrintNetworkFrame(len)
{
    PlayerThreadBlackscreenWaiter();

    self.network_hud = createfontstring("hudsmall" , 1.9);
	self.network_hud setPoint("CENTER", "TOP", "CENTER", 5);
	self.network_hud.alpha = 0;
	self.network_hud.color = (1, 1, 1);
	self.network_hud.hidewheninmenu = 1;
    self.network_hud.label = &"NETWORK FRAME: ^1";

	if (!flag("initial_blackscreen_passed"))
		flag_wait("initial_blackscreen_passed");

	start_time = int(getTime());
	wait_network_frame();
	end_time = int(getTime());
	network_frame_len = (end_time - start_time) / 1000;

	if (!isdefined(len))
		len = 5;

	if (network_frame_len == 0.1)
		self.network_hud.label = &"NETWORK FRAME: ^2";

	self.network_hud setValue(network_frame_len);

	self.network_hud.alpha = 1;
	wait len;
	self.network_hud.alpha = 0;
	wait 0.1;
	self.network_hud destroy();
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

VelocityMeter()
{
    self endon("disconnect");
    level endon("end_game");

    PlayerThreadBlackscreenWaiter();

    self.hud_velocity = createfontstring("hudsmall" , 1);
	self.hud_velocity setPoint("CENTER", "CENTER", "CENTER", 200);
	self.hud_velocity.alpha = 0.75;
	self.hud_velocity.color = level.FRFIX_HUD_COLOR;
	self.hud_velocity.hidewheninmenu = 1;
    // self.hud_velocity.label = &"Velocity: ";

    while (true)
    {
        self.hud_velocity setValue(int(length(self getvelocity() * (1, 1, 0))));
        wait 0.05;
    }
}

SemtexChart()
{
	self endon("disconnect");
	level endon("end_game");

	// Escape if starting round is bigger than 22 since the display is going to be inaccurate
	if (!isdefined(level.FRFIX_PRENADES) || !level.FRFIX_PRENADES || level.round_number >= 22)
		return;

	if (level.scr_zm_map_start_location == "town" && !level.enable_magic)
	{
		// Starts on r22 and goes onwards
		chart = array(1, 2, 3, 4, 5, 7, 8, 9, 10, 12, 13, 17, 19, 22, 24, 28, 29, 34, 39, 42, 46, 52, 57, 61, 69, 78, 86, 96, 103);

		semtex_hud = createserverfontstring("hudsmall" , 1.4);
		semtex_hud setPoint("CENTER", "BOTTOM", 0, -95);
		semtex_hud.color = level.FRFIX_HUD_COLOR;
		semtex_hud.alpha = 0;
		semtex_hud.hidewheninmenu = 1;
		semtex_hud.label = &"Prenades this round: ";

		while (level.round_number < 22)
			level waittill("between_round_over");

		foreach(semtex in chart)
		{
			level waittill("start_of_round");
			wait 0.1;

			label = "PRENADES ON " + level.round_number + ": ";
			semtex_hud.label = istring(label);

			semtex_hud setValue(semtex);

			semtex_hud fadeOverTime(0.25);
			semtex_hud.alpha = 1;

			wait 5;

			semtex_hud fadeOverTime(0.25);
			semtex_hud.alpha = 0;
		}
	}
	return;
}

NukeMannequins()
{
	if (!isdefined(level.FRFIX_YELLOWHOUSE) || !level.FRFIX_YELLOWHOUSE)
		return;

	if (level.script != "zm_nuked")
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
		}
		// FR bus mannequin
		if (mannequin.origin == (-30, 13.9031, -47.0411))
			mannequin delete();
		}
    }

EyeChange()
{
	if (!isdefined(level.NUKETOWN_EYES) || !level.NUKETOWN_EYES)
		return;

	if (level.script != "zm_nuked")
		return;

	level setclientfield("zombie_eye_change", 1);
	sndswitchannouncervox("richtofen");
}

SongSafety()
{
	if (isDefined(level.SONG_AUTO_TIMER_ACTIVE) && level.SONG_AUTO_TIMER_ACTIVE)
	{
		iPrintLn("^1SONG PATCH DETECTED!!!");
		level notify("end_game");
	}
}
