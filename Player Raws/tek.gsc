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
	replaceFunc(maps\mp\animscripts\zm_utility::wait_network_frame, ::FixNetworkFrame);
	replaceFunc(maps\mp\zombies\_zm_utility::wait_network_frame, ::FixNetworkFrame);

	replaceFunc(maps\mp\zombies\_zm_weapons::get_pack_a_punch_weapon_options, ::GetPapWeaponReticle);
	replaceFunc(maps\mp\zombies\_zm_powerups::powerup_drop, ::TrackedPowerupDrop);
	replaceFunc(maps\mp\zombies\_zm_magicbox::magic_box_opens, ::MagicBoxOpensCounter);
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
	level.FRFIX_ACTIVE = true;
	level.FRFIX_VER = 5.6;
	level.FRFIX_BETA = "";
	level.FRFIX_DEBUG = false;
	level.FRFIX_VANILLA = true;

	level thread SetDvars();
	level thread PermaPerksSetup();
	level thread OnGameStart();
}

OnGameStart()
{
	level endon("end_game");

	// Func Config
	level.FRFIX_TIMER_ENABLED = true;
	level.FRFIX_ROUND_ENABLED = false;
	level.FRFIX_HORDES_ENABLED = true;
	level.FRFIX_PERMAPERKS = true;
	level.FRFIX_PERMAPERKS_TRACKING = false;
	level.FRFIX_HUD_COLOR = (0.9, 0.8, 1);
	level.FRFIX_YELLOWHOUSE = false;
	level.FRFIX_NUKETOWN_EYES = false;
	level.FRFIX_ORIGINSFIX = true;
	level.FRFIX_PRENADES = true;
	level.FRFIX_FRIDGE = false;
	level.FRFIX_FIRSTBOX = false;

	level thread OnPlayerJoined();

	level waittill("initial_players_connected");
	level.FRFIX_WATERMARKS = array();

	// Initial game settings
	level thread DvarDetector();
	level thread FirstBoxHandler();
	level thread OriginsFix();
	level thread EyeChange();
	level thread DebugGamePrints();
	level thread AnticheatSafety();

	flag_wait("initial_blackscreen_passed");

	// HUD
	GetHudPosition();
	level thread TimerHud();
	level thread RoundTimerHud();
	level thread SplitsTimerHud();
	level thread ZombiesHud();
	level thread SemtexChart();

	// Game settings
	ZioSafety();
	RoundSafety();
	DifficultySafety();
	DebuggerSafety();
	level thread NukeMannequins();

	level waittill("end_game");
}

OnPlayerJoined()
{
	level endon("end_game");

	for(;;)
	{
		level waittill("connected", player);
		player thread OnPlayerSpawned();
	}
}

OnPlayerSpawned()
{
	level endon("end_game");
    self endon("disconnect");

	self.initial_spawn = true;

	for(;;)
	{
		self waittill("spawned_player");

		while (!flag("initial_players_connected"))
			wait 0.05;

		if (self.initial_spawn)
		{
			self.initial_spawn = false;

			self thread Fridge("tranzitnp");
			self thread WelcomePrints();
			self thread PrintNetworkFrame(6);
			self thread VelocityMeter();
		}
	}

}

// Utilities

IfDebug()
{
	if (isDefined(level.FRFIX_DEBUG) && level.FRFIX_DEBUG)
		return true;
	return false;
}

DebugPrint(text)
{
	if (IfDebug())
		print("DEBUG: " + text);
	return;
}

InfoPrint(text)
{
	print("INFO: " + text);
	return;
}

DebugPrintPermaPerk(enabled, perk)
{
	if (enabled)
	{
		if (isDefined(level.FRFIX_PERMAPERKS_TRACKING) && level.FRFIX_PERMAPERKS_TRACKING && flag("initial_blackscreen_passed"))
			self iPrintLn("Permaperk " + perk + " ^2ENABLED");
		DebugPrint("Permaperks: " + perk + " enabled");
	}
	else if (!enabled)
	{
		if (isDefined(level.FRFIX_PERMAPERKS_TRACKING) && level.FRFIX_PERMAPERKS_TRACKING)
			self iPrintLn("Permaperk " + perk + " ^1DISABLED");
		DebugPrint("Permaperks: " + perk + " disabled");
	}
	return;
}

GenerateWatermark(text, color, alpha_override)
{
	y_offset = 12 * level.FRFIX_WATERMARKS.size;
	if (!isDefined(color))
		color = level.FRFIX_HUD_COLOR;

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
	level endon("end_game");

    while (!flag("game_started"))
        wait 0.05;
    return;
}

IsTown()
{
	if (level.script == "zm_transit" && level.scr_zm_map_start_location == "town" && level.scr_zm_ui_gametype_group == "zsurvival")
		return true;
	return false;
}

IsFarm()
{
	if (level.script == "zm_transit" && level.scr_zm_map_start_location == "farm" && level.scr_zm_ui_gametype_group == "zsurvival")
		return true;
	return false;
}

IsDepot()
{
	if (level.script == "zm_transit" && level.scr_zm_map_start_location == "transit" && level.scr_zm_ui_gametype_group == "zsurvival")
		return true;
	return false;
}

IsTranzit()
{
	if (level.script == "zm_transit" && level.scr_zm_map_start_location == "transit" && level.scr_zm_ui_gametype_group == "zclassic")
		return true;
	return false;
}

IsNuketown()
{
	if (level.script == "zm_nuked")
		return true;
	return false;
}

IsDieRise()
{
	if (level.script == "zm_highrise")
		return true;
	return false;
}

IsMob()
{
	if (level.script == "zm_prison")
		return true;
	return false;
}

IsBuried()
{
	if (level.script == "zm_buried")
		return true;
	return false;
}

IsOrigins()
{
	if (level.script == "zm_tomb")
		return true;
	return false;
}

DidGameJustStarted()
{
	if (!isDefined(level.start_round))
		return true;

	if (!IsRound(level.start_round + 2))
		return true;

	return false;
}

IsRound(rnd)
{
	if (rnd <= level.round_number)
		is_rnd = true;
	else
		is_rnd = false;
	
	// DebugPrint("if " + rnd + " <= " + level.round_number +": " + is_rnd)

	return is_rnd;
}

IsVanilla()
{
	if (isDefined(level.FRFIX_VANILLA) && level.FRFIX_VANILLA)
		return true;
	return false;
}

// Functions

WelcomePrints()
{
	wait 0.75;
	self iPrintLn("^5FIRST ROOM FIX V" + level.FRFIX_VER + " " + level.FRFIX_BETA);
	wait 0.75;
	self iPrintLn("Source: github.com/Zi0MIX/T6-FIRST-ROOM-FIX");
}

GenerateCheat()
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

DebugGamePrints()
{
	level endon("end_game");

	self thread PowerupOddsWatcher();

	while (true)
	{
		level waittill("start_of_round");
		InfoPrint("ROUND: " + level.round_number + " level.powerup_drop_count = " + level.powerup_drop_count + " | Should be 0");
		InfoPrint("ROUND: " + level.round_number + " size of level.zombie_powerup_array = " + level.zombie_powerup_array.size + " | Should be above 0");
	}
}

PowerupOddsWatcher()
{
	level endon("end_game");

	while (true)
	{
		level waittill("powerup_check", chance);
		InfoPrint("rand_drop = " + chance);
	}
}

SetDvars()
{
	level endon("end_game");

	if (IsMob())
		level.custom_velocity_behaviour = ::HideInAfterlife;

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

DvarDetector() 
{
	level endon("end_game");

	while (true) 
	{
		// Waiting on top so it doesn't trigger before initial dvars are set
		flag_wait("dvars_set");

		// Backspeed
		if (getDvar("player_strafeSpeedScale") != "0.8" || getDvar("player_backSpeedScale") != "0.7") 
		{
			GenerateCheat();

			if (!flag("cheat_printed_backspeed"))
			{
				GenerateWatermark("BACKSPEED", (0.8, 0, 0));
				flag_set("cheat_printed_backspeed");
			}
			
			level notify("reset_dvars");
		}

		// Noprint
		if (getDvar("con_gameMsgWindow0LineCount") != "4" || getDvar("con_gameMsgWindow0MsgTime") != "5"
		|| getDvar("con_gameMsgWindow0FadeInTime") != "0.25" || getDvar("con_gameMsgWindow0FadeOutTime") != "0.5"
		|| getDvar("con_gameMsgWindow0Filter") != "gamenotify obituary") 
		{
			GenerateCheat();

			if (!flag("cheat_printed_noprint"))
			{
				GenerateWatermark("NOPRINT", (0.8, 0, 0));
				flag_set("cheat_printed_noprint");
			}

			level notify("reset_dvars");
		} 
		
		// Cheats
		if (getDvar("sv_cheats") != "0") 
		{
			GenerateCheat();
			
			if (!flag("cheat_printed_cheats"))
			{
				GenerateWatermark("SV_CHEATS", (0.8, 0, 0));
				flag_set("cheat_printed_cheats");
			}

			level notify("reset_dvars");
		}

		// Gspeed
		if (getDvar("g_speed") != "190") 
		{
			GenerateCheat();
			
			if (!flag("cheat_printed_gspeed"))
			{
				GenerateWatermark("GSPEED", (0.8, 0, 0));
				flag_set("cheat_printed_gspeed");
			}

			level notify("reset_dvars");
		}
		wait 0.1;
	}
}

FixNetworkFrame()
{
	if (!isDefined(level.players) || level.players.size == 1)
		wait 0.1;
	else
		wait 0.05;
}

GetHudPosition()
{
	if (!isDefined(level.hudpos_timer_game))
		level.hudpos_timer_game = ::HudPosTimerGame;
	if (!isDefined(level.hudpos_timer_round))
		level.hudpos_timer_round = ::HudPosTimerRound;
	if (!isDefined(level.hudpos_ongame_end))
		level.hudpos_ongame_end = ::HudPosOngameEnd;
	if (!isDefined(level.hudpos_splits))
		level.hudpos_splits = ::HudPosSplits;
	if (!isDefined(level.hudpos_zombies))
		level.hudpos_zombies = ::HudPosZombies;
	if (!isDefined(level.hudpos_velocity))
		level.hudpos_velocity = ::HudPosVelocity;
	if (!isDefined(level.hudpos_semtex_chart))
		level.hudpos_semtex_chart = ::HudPosSemtexChart;
}

HudPosTimerGame(hudelem)
{
	hudelem setpoint("TOPRIGHT", "TOPRIGHT", -8, 0);
}

HudPosTimerRound(hudelem)
{
	hudelem setpoint ("TOPRIGHT", "TOPRIGHT", -8, 17);
}

HudPosOngameEnd(hudelem)
{
	hudelem setpoint ("CENTER", "MIDDLE", 0, -75);
}

HudPosSplits(hudelem)
{
	hudelem setpoint ("CENTER", "TOP", 0, 30);
}

HudPosZombies(hudelem)
{
	hudelem setpoint ("CENTER", "BOTTOM", 0, -75);
}

HudPosVelocity(hudelem)
{
	hudelem setpoint ("CENTER", "CENTER", "CENTER", 200);
}

HudPosSemtexChart(hudelem)
{
	hudelem setpoint ("CENTER", "BOTTOM", 0, -95);
}

DisplaySplit(hudelem, time, length)
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

PrintNetworkFrame(len)
{
	level endon("end_game");
	self endon("disconnect");

    PlayerThreadBlackscreenWaiter();

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
		GenerateWatermark("PLUTO SPAWNS", (0.8, 0, 0));
	}
	else if ((level.players.size > 1) && (network_frame_len != 0.05))
	{
		self.network_hud.label = &"NETWORK FRAME: ^1";
		GenerateWatermark("PLUTO SPAWNS", (0.8, 0, 0));
	}

	self.network_hud setValue(network_frame_len);

	self.network_hud.alpha = 1;
	wait len;
	self.network_hud.alpha = 0;
	wait 0.1;
	self.network_hud destroy();
}

TimerHud()
{
    level endon("end_game");

    timer_hud = createserverfontstring("hudsmall" , 1.5);
	[[level.hudpos_timer_game]](timer_hud);
	timer_hud.color = level.FRFIX_HUD_COLOR;
	timer_hud.alpha = 0;
	timer_hud.hidewheninmenu = 1;

	level.FRFIX_START = int(getTime() / 1000);
	flag_set("game_started");

	skip_split = false;
	label_time_set = false;

	if (!IsVanilla() && isdefined(level.FRFIX_TIMER_ENABLED) && level.FRFIX_TIMER_ENABLED)
	{
		timer_hud setTimerUp(0);
		timer_hud.alpha = 1;
		skip_split = true;
	}
	else if (!IsVanilla())
	{
		timer_hud.label = "TIME: ";
		label_time_set = true;
	}

	while (true)
	{
		level waittill("end_of_round");
		split_time = int(GetTime() / 1000) - level.FRFIX_START;
		InfoPrint("Time at the end of round " + (level.round_number - 1) + ": " + ConvertTime(split_time));

		if (IsVanilla() || skip_split)
			continue;

		if (level.players.size > 1 && label_time_set)
		{
			timer_hud.label = "LOBBY: ";
			label_time_set = false;
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
	}
}

RoundTimerHud()
{
    level endon("end_game");

	round_hud = createserverfontstring("hudsmall" , 1.5);
	[[level.hudpos_timer_round]](round_hud);
	round_hud.color = level.FRFIX_HUD_COLOR;
	round_hud.alpha = 0;
	round_hud.hidewheninmenu = 1;

	while (true)
	{
		level waittill("start_of_round");

		round_start = int(getTime() / 1000);

		if (!IsVanilla() && isdefined(level.FRFIX_ROUND_ENABLED) && level.FRFIX_ROUND_ENABLED)
		{
			round_hud setTimerUp(0);
			round_hud FadeOverTime(0.25);
			round_hud.alpha = 1;
		}

		level waittill("end_of_round");

		round_end = int(getTime() / 1000) - round_start;
		InfoPrint("Round " + (level.round_number - 1) + " time: " + ConvertTime(round_end));

		if (IsVanilla())
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

SplitsTimerHud()
{
	level endon("end_game");

    splits_hud = createserverfontstring("hudsmall" , 1.3);
	[[level.hudpos_splits]](splits_hud);
	splits_hud.color = level.FRFIX_HUD_COLOR;
	splits_hud.alpha = 0;
	splits_hud.hidewheninmenu = 1;

	while (true)
	{
		level waittill("end_of_round");
		wait 8.5;	// Perfect round transition

		if (IsRound(15) && !(level.round_number % 5))
		{
			timestamp = ConvertTime(int(getTime() / 1000) - level.FRFIX_START);
			InfoPrint("Split: Round " + (level.round_number - 1) + ": " + timestamp);

			if (IsVanilla())
				continue;

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
	level endon("end_game");

	if (isDefined(level.FRFIX_VANILLA) && level.FRFIX_VANILLA)
		return;

	if (!isdefined(level.FRFIX_HORDES_ENABLED) || !level.FRFIX_HORDES_ENABLED)
		return;

    zombies_hud = createserverfontstring("hudsmall" , 1.4);
	[[level.hudpos_zombies]](zombies_hud);
	zombies_hud.color = level.FRFIX_HUD_COLOR;
	zombies_hud.alpha = 0;
	zombies_hud.hidewheninmenu = 1;
	zombies_hud.label = &"Hordes this round: ";

	while (true)
	{
		level waittill("start_of_round");
		wait 0.1;
		if (isDefined(flag("dog_round")) && !flag("dog_round") && IsRound(20))
		{
			label = "HORDES ON " + level.round_number + ": ";
			zombies_hud.label = istring(label);

			zombies_value = int(((maps\mp\zombies\_zm_utility::get_round_enemy_array().size + level.zombie_total) / 24) * 100);
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

	if (isDefined(level.FRFIX_VANILLA) && level.FRFIX_VANILLA)
		return;

    PlayerThreadBlackscreenWaiter();

    self.hud_velocity = createfontstring("hudsmall" , 1.2);
	[[level.hudpos_velocity]](self.hud_velocity);
	self.hud_velocity.alpha = 0.75;
	self.hud_velocity.color = level.FRFIX_HUD_COLOR;
	self.hud_velocity.hidewheninmenu = 1;
    // self.hud_velocity.label = &"Velocity: ";

	self thread VelocityMeterSize(self.hud_velocity);

    while (true)
    {
		if (isDefined(level.custom_velocity_behaviour))
			[[level.custom_velocity_behaviour]](self.hud_velocity);

		velocity = int(length(self getvelocity() * (1, 1, 0)));
		GetVelColorScale(velocity, self.hud_velocity);
        self.hud_velocity setValue(velocity);

        wait 0.05;
    }
}

GetVelColorScale(vel, hud)
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

VelocityMeterSize(hud)
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

			DebugPrint("Velocity: Current size: " + hud.fontscale + " / New size: " + new_size + " detected for player " + self.name);

			hud.fontscale = new_size;
		}
	}
}

SemtexChart()
{
	// self endon("disconnect");
	level endon("end_game");

	if (isDefined(level.FRFIX_VANILLA) && level.FRFIX_VANILLA)
		return;

	// Escape if starting round is bigger than 22 since the display is going to be inaccurate
	if (!isdefined(level.FRFIX_PRENADES) || !level.FRFIX_PRENADES || IsRound(23))
		return;

	if (IsTown() && !level.enable_magic)
	{
		// Starts on r22 and goes onwards
		chart = array(1, 2, 3, 4, 5, 7, 8, 9, 10, 12, 13, 17, 19, 22, 24, 28, 29, 34, 39, 42, 46, 52, 57, 61, 69, 78, 86, 96, 103);

		semtex_hud = createserverfontstring("hudsmall" , 1.4);
		[[level.hudpos_semtex_chart]](semtex_hud);
		semtex_hud.color = level.FRFIX_HUD_COLOR;
		semtex_hud.alpha = 0;
		semtex_hud.hidewheninmenu = 1;
		semtex_hud.label = &"Prenades this round: ";

		while (!IsRound(22))
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
	level endon("end_game");

	if (!isdefined(level.FRFIX_YELLOWHOUSE) || !level.FRFIX_YELLOWHOUSE)
		return;

	if (!IsNuketown())
		return;

	wait 1;
    destructibles = getentarray("destructible", "targetname");
    foreach (mannequin in destructibles)
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
	if (!isdefined(level.FRFIX_NUKETOWN_EYES) || !level.FRFIX_NUKETOWN_EYES)
		return;

	if (!IsNuketown())
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

PermaPerksSetup()
{
	level endon("end_game");

	if (!maps\mp\zombies\_zm_pers_upgrades::is_pers_system_active())
		return;

	// It tends to crash without this statement lol
	if (IsMob() || IsOrigins())
		return;

	flag_wait("initial_blackscreen_passed");

	if (isdefined(level.FRFIX_PERMAPERKS) && level.FRFIX_PERMAPERKS)
	{
		if (isDefined(level.frfix_metal_boards_func))
		{
			InfoPrint("Metal Boards plugin present, if perk is awarded, a restart will be required");
			[[level.frfix_metal_boards_func]]();
		}
		self thread StopPermaPerksSystem();
		self thread WatchForNewPlayers();
	}
}

StopPermaPerksSystem()
{
	level endon("end_game");

	while (DidGameJustStarted())
		level waittill("end_of_round");

	DebugPrint("Stopping permaperks award");
	self notify("stop_permaperks_award");
}

WatchForNewPlayers()
{
	level endon("end_game");
	self endon("stop_permaperks_award");

	// Give perma perks to everyone who is connected at this point
	foreach(player in level.players)
	{
		player thread PermaWatcher();
		player thread AwardPermaPerks();
	}

	// And wait for new players
	while (true)
	{
		level waittill("connected", player);

		player thread PermaWatcher();
		player thread AwardPermaPerks();
	}
}

PermaWatcher()
{
	level endon("end_game");
	self endon("disconnect");

	self waittill("initial_permas_awarded");

	self.last_perk_state = array();
	foreach(perk in level.pers_upgrades_keys)
		self.last_perk_state[perk] = self.pers_upgrades_awarded[perk];

	while (true)
	{
		foreach(perk in level.pers_upgrades_keys)
		{
			if (self.pers_upgrades_awarded[perk] != self.last_perk_state[perk])
			{
				self DebugPrintPermaPerk(self.pers_upgrades_awarded[perk], perk);
				self.last_perk_state[perk] = self.pers_upgrades_awarded[perk];
				wait 0.1;
			}
		}

		wait 0.1;
	}
}

AwardPermaPerks()
{
	level endon("end_game");
	self endon("disconnect");

	while (!isalive(self))
		wait 0.05;

	wait 0.5;

	perks_to_award = array("revive", "multikill_headshots", "perk_lose");
	perks_to_remove = array();

	if (!IsRound(15))
		perks_to_award[perks_to_award.size] = "jugg";

	if (IsBuried())
		perks_to_award[perks_to_award.size] = "flopper";
	else
		perks_to_remove[perks_to_remove.size] = "box_weapon";

	if (!IsDieRise() && !IsRound(10))
		perks_to_award[perks_to_award.size] = "nube";
	else if (IsDieRise())
		perks_to_remove[perks_to_remove.size] = "nube";

	// Set permaperks
	foreach(perk in perks_to_award)
	{
		for (j = 0; j < level.pers_upgrades[perk].stat_names.size; j++)
		{
			stat_name = level.pers_upgrades[perk].stat_names[j];
			stat_value = level.pers_upgrades[perk].stat_desired_values[j];

			self AwardPermaPerk(stat_name, perk, stat_value);
			wait 0.05;
		}
	}

	foreach(perk in perks_to_remove)
	{
		self.pers_upgrades_awarded[perk] = 0;
		InfoPrint("Perk Removal for " + self.name + ": " + perk);
	}

	// uploadstats(self);
	self notify("initial_permas_awarded");
}

AwardPermaPerk(stat_name, perk_name, stat_value)
{
	self.stats_this_frame[stat_name] = 1;
	self set_global_stat(stat_name, stat_value);
	// self.pers_upgrades_awarded[perk_name] = 1;
	InfoPrint("Perk Activation for " + self.name + ": " + perk_name + " -> " + stat_name + " set to: " + stat_value);
	return;
}

OriginsFix()
{
    level endon("end_game");
	
	if (!isdefined(level.FRFIX_ORIGINSFIX) || !level.FRFIX_ORIGINSFIX)
		return;

	flag_wait("start_zombie_round_logic");
	wait 0.5;

	if (IsOrigins())
		level.is_forever_solo_game = 0;
	// else if (IsMob() && level.players.size == 1)
	// 	level.is_forever_solo_game = 1;

	return;
}

ZioSafety()
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

RoundSafety()
{
	maxround = 1;
	if (IsTown() || IsFarm() || IsDepot() || IsNuketown())
		maxround = 10;

	DebugPrint("Starting round detected: " + level.start_round);

	if (level.start_round <= maxround)
		return;

	GenerateWatermark("STARTING ROUND", (0.8, 0, 0));
	return;
}

DifficultySafety()
{
	if (level.gamedifficulty == 0)
		GenerateWatermark("EASY MODE", (0.8, 0, 0));
	return;
}

DebuggerSafety()
{
	if (IfDebug())
	{
		foreach(player in level.players)
			player.score = 333333;
		GenerateWatermark("DEBUGGER", (0, 0.8, 0));
	}
	return;
}

AnticheatSafety()
{
	level endon("end_game");

	level waittill("cheat_generated");
	while (isDefined(level.cheat_hud))
		wait 0.1;

	foreach (player in level.players)
		player doDamage(player.health + 69, player.origin);
}

TrackedPowerupDrop( drop_point )
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

Fridge(mode)
{
	if (!isDefined(level.FRFIX_FRIDGE) || !level.FRFIX_FRIDGE)
		return;

	if (!DidGameJustStarted())
		return;

	if (!IsTranzit() && !IsDieRise() && !IsBuried())
		return;

	flag_wait("initial_blackscreen_passed");

	self.account_value = 250000;
	if (isDefined(mode) && mode == "tranzitnp")
	{
		if (!IsTranzit())
			return;

		self clear_stored_weapondata();
		self setdstat("PlayerStatsByMap", "zm_transit", "weaponLocker", "name", "mp5k_upgraded_zm");
		self setdstat("PlayerStatsByMap", "zm_transit", "weaponLocker", "clip", 40);
		self setdstat("PlayerStatsByMap", "zm_transit", "weaponLocker", "stock", 200);
	}
	else
	{
		self clear_stored_weapondata();
		self setdstat("PlayerStatsByMap", "zm_transit", "weaponLocker", "name", "an94_upgraded_zm+mms");
		self setdstat("PlayerStatsByMap", "zm_transit", "weaponLocker", "clip", 50);
		self setdstat("PlayerStatsByMap", "zm_transit", "weaponLocker", "stock", 600);
	}
	return;
}

FirstBoxHandler()
{
    level endon("end_game");

	if (!isDefined(level.enable_magic) || !level.enable_magic)
		return;

	flag_wait("initial_blackscreen_passed");

    level.is_first_box = false;

	// Debug func, doesn't do anything in production
	self thread PrintInitialBoxSize();

	// Scan weapons in the box
	self thread ScanInBox();
	// First Box main loop
	self thread FirstBox();

	while (true)
	{
		if (isDefined(level.is_first_box) && level.is_first_box)
			break;

		wait 0.25;
	}

	GenerateWatermark("FIRST BOX", (0.8, 0, 0));
}

PrintInitialBoxSize()
{
	in_box = 0;

	foreach (weapon in getArrayKeys(level.zombie_weapons))
	{
		if (maps\mp\zombies\_zm_weapons::get_is_in_box(weapon))
			in_box++;
	}
	DebugPrint("Size of initial box weapon list: " + in_box);
}

ScanInBox()
{
    level endon("end_game");

	// Only town needed
    if (IsTown() || IsFarm() || IsDepot() || IsTranzit())
        should_be_in_box = 25;
	else if (IsNuketown())
        should_be_in_box = 26;
	else if (IsDieRise())
        should_be_in_box = 24;
	else if (IsMob())
        should_be_in_box = 16;
    else if (IsBuried())
        should_be_in_box = 22;
	else if (IsOrigins())
		should_be_in_box = 23;

	offset = 0;
	if (IsDieRise() || IsOrigins())
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

		// DebugPrint("in_box: " + in_box + " should: " + should_be_in_box);

        if (in_box == should_be_in_box)
			continue;

		else if ((offset > 0) && (in_box == (should_be_in_box + offset)))
			continue;

		level.is_first_box = true;
		break;

    }
    return;
}

FirstBox()
{	
    level endon("end_game");
	level endon("break_firstbox");

	if (!isDefined(level.FRFIX_FIRSTBOX) || !level.FRFIX_FIRSTBOX)
		return;

	if (level.start_round > 1 && !IsTown())
		return;

	flag_wait("initial_blackscreen_passed");

	iPrintLn("First Box module: ^2AVAILABLE");
	self thread WatchForFinishFirstBox();
	self.rigged_hits = 0;

	while (true)
	{
		level waittill("say", message, player, ishidden);

		if (isSubStr(message, "fb"))
			wpn_key = getSubStr(message, 3);
		else
			continue;

		self thread RigBox(wpn_key, player);
		wait_network_frame();

		while (flag("box_rigged"))
			wait 0.05;
	}
}

RigBox(gun, player)
{
    level endon("end_game");

	weapon_key = GetWeaponKey(gun);
	if (weapon_key == "")
	{
		iPrintLn("Wrong weapon key: ^1" + gun);
		return;
	}

	// weapon_name = level.zombie_weapons[weapon_key].name;
	iPrintLn("" + player.name + " set box weapon to: ^3" +  WeaponDisplayWrapper(weapon_key));
	level.is_first_box = true;
	self.rigged_hits++;

	saved_check = level.special_weapon_magicbox_check;
	current_box_hits = level.total_box_hits;
	removed_guns = array();

	flag_set("box_rigged");
	DebugPrint("FIRST BOX: flag('box_rigged'): " + flag("box_rigged"));

	level.special_weapon_magicbox_check = undefined;
	foreach(weapon in getarraykeys(level.zombie_weapons))
	{
		if ((weapon != weapon_key) && level.zombie_weapons[weapon].is_in_box == 1)
		{
			removed_guns[removed_guns.size] = weapon;
			level.zombie_weapons[weapon].is_in_box = 0;

			DebugPrint("FIRST BOX: setting " + weapon + ".is_in_box to 0");
		}
	}

	while ((current_box_hits == level.total_box_hits) || !isDefined(level.total_box_hits))
	{
		if (IsRound(11))
		{
			DebugPrint("FIRST BOX: breaking out of First Box above round 10");
			break;
		}
		wait 0.05;
	}
	
	wait 5;

	level.special_weapon_magicbox_check = saved_check;

	DebugPrint("FIRST BOX: removed_guns.size " + removed_guns.size);
	if (removed_guns.size > 0)
	{
		foreach(rweapon in removed_guns)
		{
			level.zombie_weapons[rweapon].is_in_box = 1;
			DebugPrint("FIRST BOX: setting " + rweapon + ".is_in_box to 1");
		}
	}

	flag_clear("box_rigged");
	return;
}

WatchForFinishFirstBox()
{
    level endon("end_game");

	while (!IsRound(11))
		wait 0.1;

	iPrintLn("First Box module: ^1DISABLED");
	if (self.rigged_hits)
		iPrintLn("First box used: ^3" + self.rigged_hits + " ^7times");

	level notify("break_firstbox");
	flag_set("break_firstbox");
	DebugPrint("FIRST BOX: notifying module to break");

	return;
}

GetWeaponKey(weapon_str)
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
			if (IsTown() || IsFarm() || IsDepot() || IsTranzit() || IsNuketown() || IsDieRise() || IsBuried() || IsOrigins())
				key = "cymbal_monkey_zm";
			break;
		case "emp":
			if (IsTown() || IsFarm() || IsDepot() || IsTranzit())
				key = "emp_grenade_zm";
			break;
		case "time":
			if (IsBuried())
				key = "time_bomb_zm";
			break;
		case "sliq":
			if (IsDieRise())
				key = "slipgun_zm";
			break;
		case "blunder":
			if (IsMob())
				key = "blundergat_zm";
			break;
		case "paralyzer":
			if (IsBuried())
				key = "slowgun_zm";
			break;

		case "ak47":
			if (IsMob())
				key = "ak47_zm";
			break;
		case "barret":
			if (IsTown() || IsFarm() || IsDepot() || IsTranzit() || IsNuketown() || IsDieRise() || IsMob() || IsBuried())
				key = "barretm82_zm";
			break;
		case "b23":
			if (IsOrigins())
				key = "beretta93r_extclip_zm";
			break;
		case "dsr":
			key = "dsr50_zm";
			break;
		case "evo":
			if (IsOrigins())
				key = "evoskorpion_zm";
			break;
		case "57":
			if (IsTown() || IsFarm() || IsDepot() || IsTranzit() || IsNuketown() || IsDieRise() || IsBuried())
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
			if (IsTown() || IsFarm() || IsDepot() || IsTranzit() || IsNuketown() || IsDieRise() || IsMob() || IsBuried())
				key = "tar21_zm";
			break;
		case "hamr":
			if (IsTown() || IsFarm() || IsDepot() || IsTranzit() || IsNuketown() || IsDieRise() || IsBuried() || IsOrigins())
				key = "hamr_zm";
			break;
		case "m27":
			if (IsNuketown())
				key = "hk416_zm";
			break;
		case "exe":
			if (IsTown() || IsFarm() || IsDepot() || IsTranzit() || IsNuketown() || IsDieRise() || IsMob() || IsBuried())
				key = "judge_zm";
			break;
		case "kap":
			key = "kard_zm";
			break;
		case "bk":
			if (IsTown() || IsFarm() || IsDepot() || IsTranzit() || IsNuketown() || IsDieRise() || IsBuried())
				key = "knife_ballistic_zm";
			break;
		case "ksg":
			if (IsOrigins())
				key = "ksg_zm";
			break;
		case "wm":
			if (IsTown() || IsFarm() || IsDepot() || IsTranzit() || IsNuketown() || IsDieRise() || IsBuried() || IsOrigins())
				key = "m32_zm";
			break;
		case "mg":
		case "lsat":
			if (IsOrigins())
				key = "mg08_zm";
			else if (IsNuketown() || IsMob())
				key = "lsat_zm";
			break;
		case "dm":
			if (IsMob())
				key = "minigun_alcatraz_zm";
		case "mp40":
			if (IsOrigins())
				key = "mp40_stalker_zm";
			break;
		case "pdw":
			if (IsMob() || IsOrigins())
				key = "pdw57_zm";
			break;
		case "pyt":
		case "rnma":
			if (IsTown() || IsFarm() || IsDepot() || IsTranzit() || IsNuketown() || IsDieRise() || IsOrigins())
				key = "python_zm";
			else if (IsBuried())
				key = "rnma_zm";
			break;
		case "type":
			if (IsTown() || IsFarm() || IsDepot() || IsTranzit() || IsNuketown() || IsDieRise() || IsOrigins())
				key = "type95_zm";
			break;
		case "rpd":
			if (IsTown() || IsFarm() || IsDepot() || IsTranzit() || IsNuketown() || IsDieRise())
				key = "rpd_zm";
			break;
		case "s12":
			if (IsTown() || IsFarm() || IsDepot() || IsTranzit() || IsNuketown() || IsDieRise() || IsMob() || IsBuried())
				key = "saiga12_zm";
			break;
		case "scar":
			if (IsOrigins())
				key = "scar_zm";
			break;
		case "m1216":
			if (IsTown() || IsFarm() || IsDepot() || IsTranzit() || IsNuketown() || IsDieRise() || IsBuried() || IsOrigins())
				key = "srm1216_zm";
			break;
		case "tommy":
			if (IsMob())
				key = "thompson_zm";
			break;
		case "chic":
			if (IsTown() || IsFarm() || IsDepot() || IsTranzit() || IsNuketown() || IsDieRise() || IsOrigins())
				key = "qcw05_zm";
			break;
		case "rpg":
			if (IsTown() || IsFarm() || IsDepot() || IsTranzit() || IsNuketown() || IsDieRise() || IsMob() || IsBuried())
				key = "usrpg_zm";
			break;
		case "m8":
			if (IsTown() || IsFarm() || IsDepot() || IsTranzit() || IsNuketown() || IsDieRise())
				key = "xm8_zm";
			break;
	}

	DebugPrint("FIRST BOX: weapon_key: " + key);
	return key;
}

WeaponDisplayWrapper(weapon_key)
{
	if (weapon_key == "emp_grenade_zm")
		return "Emp Grenade";
	if (weapon_key == "cymbal_monkey_zm")
		return "Cymbal Monkey";
	
	return get_weapon_display_name(weapon_key);
}

MagicBoxOpensCounter()
{
	level notify("chest_opened");

	if (!isDefined(level.total_box_hits))
		level.total_box_hits = 1;
	else
		level.total_box_hits++;

	DebugPrint("current box hits: " + level.total_box_hits);

    self setzbarrierpiecestate( 2, "opening" );

    while ( self getzbarrierpiecestate( 2 ) == "opening" )
        wait 0.1;

    self notify( "opened" );
}

HideInAfterlife(hud)
{
	if (self.afterlife)
		hud.alpha = 0;
	else
		hud.alpha = 1;
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
