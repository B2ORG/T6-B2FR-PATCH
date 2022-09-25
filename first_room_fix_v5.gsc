#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/zombies/_zm_stats;
#include maps/mp/zombies/_zm_weapons;
#include maps/mp/zombies/_zm_powerups;
#include common_scripts/utility;
#include maps/mp/_utility;
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
	replaceFunc(maps/mp/zombies/_zm_powerups::powerup_drop, ::TrackedPowerupDrop);
}

init()
{
	flag_init("dvars_set");
	flag_init("game_paused");
	flag_init("cheat_printed_backspeed");
	flag_init("cheat_printed_noprint");
	flag_init("cheat_printed_cheats");
	flag_init("cheat_printed_gspeed");

	flag_init("game_started");

	// Patch Config
	level.FRFIX_ACTIVE = true;
	level.FRFIX_VER = 5.1;
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
	level.FRFIX_YELLOWHOUSE = false;
	level.FRFIX_NUKETOWN_EYES = false;
	level.FRFIX_NOFOG = false;
	level.FRFIX_ORIGINSFIX = false;
	level.FRFIX_PRENADES = true;
	level.FRFIX_FRIDGE = false;
	level.FRFIX_COOP_PAUSE_ACTIVE = false;		// Disabled for 5.1 need more testing

	level thread OnPlayerJoined();

	level waittill("initial_players_connected");
	level.FRFIX_WATERMARKS = array();

	// Initial game settings
	level thread SetDvars();
	level thread DvarDetector();
	level thread FirstBoxHandler();
	level thread OriginsFix();
	level thread NoFog();
	level thread EyeChange();
	level thread DebugGamePrints();

	flag_wait("initial_blackscreen_passed");

	level.FRFIX_START = int(getTime() / 1000);
	flag_set("game_started");

	// HUD
	level thread GlobalRoundStart();
	level thread BasicSplitsHud();
	level thread TimerHud();
	level thread RoundTimerHud();
	level thread SplitsTimerHud();
	level thread ZombiesHud();
	level thread SemtexChart();

	// Game settings
	SongSafety();
	RoundSafety();
	DifficultySafety();
	level thread CoopPause();
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

			self thread Fridge("tranzitnp");
			self thread WelcomePrints();
			self thread PrintNetworkFrame(6);
			self thread AwardPermaPerks();
			self thread VelocityMeter();

			if (isDefined(level.FRFIX_DEBUG) && level.FRFIX_DEBUG)
				self.score = 50000;
		}
	}

}

// Utilities

GenerateWatermark(text, color, alpha_override)
{
	y_offset = 12 * level.FRFIX_WATERMARKS.size;
	if (!isDefined(color))
		color = level.FRFIX_HUD_COLOR;

	if (!isDefined(alpha_override))
		alpha_override = 0.2;

    watermark = createserverfontstring("hudsmall" , 1.2);
	watermark setPoint("CENTER", "TOP", 0, y_offset - 10);
	watermark.color = color;
	watermark setText(text);
	watermark.alpha = alpha_override;
	watermark.hidewheninmenu = 0;

	level.FRFIX_WATERMARKS[level.FRFIX_WATERMARKS.size] = watermark;
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

	if ((level.round_number == level.start_round) || (level.round_number == (level.start_round + 1)))
		return true;

	return false;
}

// Functions

WelcomePrints()
{
	wait 0.75;
	self iPrintLn("^5FIRST ROOM FIX V" + level.FRFIX_VER + " " + level.FRFIX_BETA);
	wait 0.75;
	self iPrintLn("Source: github.com/Zi0MIX/First-Room-Fix");
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
	return;
}

DebugGamePrints()
{
	self endon("disconnect");
	level endon("end_game");

	self thread PowerupOddsWatcher();

	while (true)
	{
		level waittill("start_of_round");
		print("DEBUG: ROUND: " + level.round_number + " level.powerup_drop_count = " + level.powerup_drop_count + " | Should be 0");
		print("DEBUG: ROUND: " + level.round_number + " size of level.zombie_powerup_array = " + level.zombie_powerup_array.size + " | Should be above 0");
	}
}

PowerupOddsWatcher()
{
	while (true)
	{
		level waittill("powerup_check", chance);
		print("DEBUG: rand_drop = " + chance);
	}
}

SetDvars()
{
	setDvar("timer_left", 0);
	setDvar("velocity_size", 1.2);

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
	wait 0.1;
}

PrintNetworkFrame(len)
{
    PlayerThreadBlackscreenWaiter();

    self.network_hud = createfontstring("hudsmall" , 1.9);
	self.network_hud setPoint("CENTER", "TOP", "CENTER", 5);
	self.network_hud.alpha = 0;
	self.network_hud.color = (1, 1, 1);
	self.network_hud.hidewheninmenu = 1;
    self.network_hud.label = &"NETWORK FRAME: ^2";

	if (!flag("initial_blackscreen_passed"))
		flag_wait("initial_blackscreen_passed");

	start_time = int(getTime());
	wait_network_frame();
	end_time = int(getTime());
	network_frame_len = (end_time - start_time) / 1000;

	if (!isdefined(len))
		len = 5;

	if (network_frame_len != 0.1)
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

		level waittill("end_of_round");

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

		gt_freeze = int(getTime() / 1000) - (level.paused_time + level.FRFIX_START);
		rt_freeze = int(getTime() / 1000) - (level.paused_round + level.round_start);

		basegt_hud setTimer(gt_freeze);
		basert_hud setTimer(rt_freeze);

		for (ticks = 0; ticks < 100; ticks++)
		{
			basegt_hud setTimer(gt_freeze);
			basert_hud setTimer(rt_freeze);
			wait 0.05;
		}
		basegt_hud fadeOverTime(0.1);
		basert_hud fadeOverTime(0.1);
		basegt_hud.alpha = 0;
		basert_hud.alpha = 0;
	}

	return;
}

CoopPause()
{
	self endon("disconnect");
	level endon("end_game");

	level.paused_time = 0.00;

	if (!isDefined(level.FRFIX_COOP_PAUSE_ACTIVE) || !level.FRFIX_COOP_PAUSE_ACTIVE)
		return;

	// Wait till next round if it's solo
	while (level.players.size == 1)
		level waittill ("start_of_round");

	self thread CoopPauseSwitch();
	// Don't allow pausing on the 1st round of the game regardless what it is (was causing issues)
	level.last_paused_round = getgametypesetting("startRound");
	setDvar("paused", 0);

	while(true)
	{
		current_zombies = int(maps/mp/zombies/_zm_utility::get_round_enemy_array().size + level.zombie_total);

		current_time = int(getTime() / 1000) - (level.paused_time + level.FRFIX_START);
		current_round_time = int(getTime() / 1000) - (level.paused_round + level.round_start);

		while(flag("game_paused"))
		{
			// Lil inaccuracy occurs here
			if (isDefined(level.timer_hud))
				level.timer_hud setTimer(current_time);

			if (isDefined(level.round_hud))
				level.round_hud setTimer(current_round_time);

			level.paused_time += 0.05;
			level.paused_round += 0.05;
			wait 0.05;

			if (current_zombies != int(maps/mp/zombies/_zm_utility::get_round_enemy_array().size + level.zombie_total))
				UnpauseGame();
		}

		wait 0.05;
	}
}

CoopPauseSwitch()
{
	level waittill("start_of_round");

	while (true)
	{		
		while (level.last_paused_round == level.round_number)
		{
			level waittill("start_of_round");
			setDvar("paused", 0);				// To make sure pause doesn't kick in as soon as round starts
		}

		zombie_count = int(maps/mp/zombies/_zm_utility::get_round_enemy_array().size + level.zombie_total);

		if (zombie_count > 0 && getDvarInt("paused") && !flag("game_paused") && level.players.size > 1)
			PauseGame();
		else if ((!getDvarInt("paused") && flag("game_paused")) || (zombie_count <= 0 && flag("game_paused")))
			UnpauseGame();

		wait 0.05;
	}
}

PauseGame()
{
	iPrintLn("^2pausing...");
	flag_set("game_paused");
	setDvar("paused", 1);
}

UnpauseGame()
{
	iPrintLn("^3unpausing...");
	flag_clear("game_paused");
	setDvar("paused", 0);
	level.last_paused_round = level.round_number;

	reclocked = (int(getTime() / 1000) - (level.paused_time + level.FRFIX_START)) * -1;
	if (isDefined(level.timer_hud))
		level.timer_hud setTimerUp(reclocked);

	if (isDefined(level.FRFIX_DEBUG) && level.FRFIX_DEBUG)
	{
		print("reclocked consists of: getTime() = " + int(getTime() / 1000) + " level.paused_time = " + level.paused_time + " level.FIFIX_START = " + level.FRFIX_START);
		print("Setting the timer to: " + reclocked + " s");
	}

	rtreclocked = (int(getTime() / 1000) - (level.paused_round + level.round_start)) * -1;
	if (isDefined(level.round_hud))
		level.round_hud setTimerUp(rtreclocked);

	if (isDefined(level.FRFIX_DEBUG) && level.FRFIX_DEBUG)
	{
		print("reclocked consists of: getTime() = " + int(getTime() / 1000) + " level.paused_round = " + level.paused_round + " level.round_start = " + level.round_start);
		print("Setting the round timer to: " + rtreclocked + " s");
	}
}

GlobalRoundStart()
{
	level.round_start = level.FRFIX_START;
	level.paused_round = 0.00;

	while (true)
	{
		level waittill("start_of_round");
		level.round_start = int(getTime() / 1000);
		level.paused_round = 0.00;
	}
}

TimerHud()
{
    self endon("disconnect");
    level endon("end_game");

	if (!isdefined(level.FRFIX_TIMER_ENABLED) || !level.FRFIX_TIMER_ENABLED)
		return;

    level.timer_hud = createserverfontstring("hudsmall" , 1.5);
	level.timer_hud setPoint("TOPRIGHT", "TOPRIGHT", -8, 0);
	level.timer_hud.color = level.FRFIX_HUD_COLOR;
	level.timer_hud.alpha = 0;
	level.timer_hud.hidewheninmenu = 1;

	level.timer_hud setTimerUp(0);
	level.timer_hud.alpha = 1;

	self thread HudPos(level.timer_hud);
}

RoundTimerHud()
{
    self endon("disconnect");
    level endon("end_game");

	if (!isdefined(level.FRFIX_ROUND_ENABLED) || !level.FRFIX_ROUND_ENABLED)
		return;

	level.round_hud = createserverfontstring("hudsmall" , 1.5);
	level.round_hud setPoint("TOPRIGHT", "TOPRIGHT", -8, 17);
	level.round_hud.color = level.FRFIX_HUD_COLOR;
	level.round_hud.alpha = 0;
	level.round_hud.hidewheninmenu = 1;

	self thread HudPos(level.round_hud, 17);

	while (true)
	{
		level waittill("start_of_round");
		level.round_hud setTimerUp(0);

		level.round_hud FadeOverTime(0.25);
		level.round_hud.alpha = 1;

		level waittill("end_of_round");
		round_end = int(getTime() / 1000);
		// round_start is not calculated globally for the benefit of coop pause func
		round_time = round_end - (level.paused_round + level.round_start);
		level.round_hud setTimer(round_time);

		for (ticks = 0; ticks < 100; ticks++)
		{
			level.round_hud setTimer(round_time);
			wait 0.05;
		}
		level.round_hud FadeOverTime(0.25);
		level.round_hud.alpha = 0;
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
			timestamp = ConvertTime(time - (level.FRFIX_START + level.paused_time));

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
	vel_size = 0;

    self.hud_velocity = createfontstring("hudsmall" , 1.2);
	self.hud_velocity setPoint("CENTER", "CENTER", "CENTER", 200);
	self.hud_velocity.alpha = 0.75;
	self.hud_velocity.color = level.FRFIX_HUD_COLOR;
	self.hud_velocity.hidewheninmenu = 1;
    // self.hud_velocity.label = &"Velocity: ";

    while (true)
    {
		velocity = int(length(self getvelocity() * (1, 1, 0)));
		GetVelColorScale(velocity, self.hud_velocity);
        self.hud_velocity setValue(velocity);

		if (vel_size != getDvarFloat("velocity_size"))
		{
			vel_size = getDvarFloat("velocity_size");
			self.hud_velocity.fontscale = vel_size;
		}
        wait 0.05;
    }
}

GetVelColorScale(vel, hud)
{
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
	
	else
	{
		hud.color = ( 0.6, 0, 0 );
		hud.glowcolor = ( 0.3, 0, 0 );
	}
	return;
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

	if (level.script == "zm_transit" || level.script == "zm_highrise" || level.script == "zm_buried")
	{
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
}

NoFog()
{
	if (!isdefined(level.FRFIX_NOFOG) || !level.FRFIX_NOFOG)
		return;

	if (level.script != "zm_transit")
		return;
	
	if (level.scr_zm_map_start_location == "transit")
		return;

	setDvar("r_fog", 0);
}

OriginsFix()
{
    self endon("disconnect");
    level endon("end_game");
	
	if (!isdefined(level.FRFIX_ORIGINSFIX) || !level.FRFIX_ORIGINSFIX)
		return;

	flag_wait("start_zombie_round_logic");
	wait 0.5;

	if (level.script == "zm_tomb")
		level.is_forever_solo_game = 0;
	// else if (level.script == "zm_prison" && level.players.size == 1)
	// 	level.is_forever_solo_game = 1;

	return;
}

SongSafety()
{
	if (isDefined(level.SONG_AUTO_TIMER_ACTIVE) && level.SONG_AUTO_TIMER_ACTIVE)
	{
		iPrintLn("^1SONG PATCH DETECTED!!!");
		level notify("end_game");
	}
}

RoundSafety()
{
	maxround = 1;
	if (IsTown() || IsFarm() || IsDepot() || level.script == "zm_nuked")
		maxround = 10;

	if (isDefined(level.FRFIX_DEBUG) && level.FRFIX_DEBUG)
		print("DEBUG: Starting round detected: " + getgametypesetting("startRound"));

	if (getgametypesetting("startRound") <= maxround)
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

	if (!flag("initial_blackscreen_passed"))
		flag_wait("initial_blackscreen_passed");

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
    self endon("disconnect");
    level endon("end_game");

	if (!isDefined(level.enable_magic) || !level.enable_magic)
		return;

    level.is_first_box = false;

	self thread ScanInBox();
	self thread CompareKeys();

	flag_wait("initial_blackscreen_passed");

	while (true)
	{
		if (isDefined(level.is_first_box) && level.is_first_box)
			break;

		wait 0.25;
	}

	GenerateWatermark("FIRST BOX", (0.8, 0, 0));
}

ScanInBox()
{
    self endon("disconnect");
    level endon("end_game");

	// Only town needed
    if (IsTown() || IsFarm() || IsDepot() || IsTranzit())
        should_be_in_box = 25;
	// else if (level.script == "zm_nuked")
    //     should_be_in_box = 26;
	// else if (level.script == "zm_highrise")
    //     should_be_in_box = 24;	// Handle midgame changes
	// else if (level.script == "zm_prison")
    //     should_be_in_box = 18;	// Handle midgame changes
    // else if (level.script == "zm_buried")
    //     should_be_in_box = 22;
	// else if (level.script == "zm_tomb")
	// 	should_be_in_box = 23;  // Handle midgame changes

    while (isDefined(should_be_in_box))
    {
        in_box = 0;
        wpn_keys = getarraykeys(level.zombie_weapons);

        for (i=0; i<wpn_keys.size; i++)
        {
            if (maps\mp\zombies\_zm_weapons::get_is_in_box(wpn_keys[i]))
                in_box++;
        }

		if (isDefined(level.FRFIX_DEBUG) && level.FRFIX_DEBUG)
        	print("in_box: " + in_box + " should: " + should_be_in_box);

        if (in_box != should_be_in_box)
        {
            // iPrintLn("1stbox_box");
            level.is_first_box = true;
            break;
        }

        wait_network_frame();
    }
    return;
}

CompareKeys()
{
    self endon("disconnect");
    level endon("end_game");

    an_array = array();
    dupes = 0;

    wait(randomIntRange(2, 22));

    for (i=0; i<10; i++)
    {
        rando = maps\mp\zombies\_zm_magicbox::treasure_chest_chooseweightedrandomweapon(level.players[0]);
        if (isinarray(an_array, rando))
            dupes += 1;
        else
            an_array[an_array.size] = rando;
        
        wait_network_frame();
    }

    if (dupes > 3)
    {
        // iPrintLn("1stbox_keys");
        level.is_first_box = true;
    }

    return;
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
