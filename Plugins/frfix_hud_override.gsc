#include maps\mp\gametypes_zm\_hud_util;

init()
{
    level.hudpos_timer_game = ::OverrideHudTimerGame;
    level.hudpos_timer_round = ::OverrideHudTimerRound;
    level.hudpos_ongame_end = ::OverrideHudOngameEnd;
    level.hudpos_splits = ::OverrideHudSplits;
    level.hudpos_zombies = ::OverrideHudZombies;
    level.hudpos_velocity = ::OverrideHudVelocity;
    level.hudpos_semtex_chart = ::OverrideHudSemtexChart;
}

OverrideHudTimerGame(hudelem)
{
	hudelem setpoint("TOPRIGHT", "TOPRIGHT", -8, 0);
}

OverrideHudTimerRound(hudelem)
{
	hudelem setpoint ("TOPRIGHT", "TOPRIGHT", -8, 17);
}

OverrideHudOngameEnd(hudelem)
{
	hudelem setpoint ("CENTER", "MIDDLE", 0, -75);
}

OverrideHudSplits(hudelem)
{
	hudelem setpoint ("CENTER", "TOP", 0, 0);
}

OverrideHudZombies(hudelem)
{
	hudelem setpoint ("CENTER", "BOTTOM", 0, -75);
}

OverrideHudVelocity(hudelem)
{
	hudelem setpoint ("CENTER", "CENTER", "CENTER", 200);
}

OverrideHudSemtexChart(hudelem)
{
	hudelem setpoint ("CENTER", "BOTTOM", 0, -95);
}