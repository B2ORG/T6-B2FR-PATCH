#include maps\mp\zombies\_zm_stats;

init()
{
    level.frfix_metal_boards_func = ::MetalBoardsMain;
}

MetalBoardsMain()
{
    boards_awarded = false;

    foreach(player in level.players)
    {
        if (isDefined(player.pers_upgrades_awarded["board"]) && player.pers_upgrades_awarded["board"])
            continue;

        boards_awarded = true;

        for (j = 0; j < level.pers_upgrades["board"].stat_names.size; j++)
        {
            stat_name = level.pers_upgrades["board"].stat_names[j];
            stat_value = level.pers_upgrades["board"].stat_desired_values[j];

            player.stats_this_frame[stat_name] = 1;
            player set_global_stat(stat_name, stat_value);
        }

        wait 0.05;
    }

    if (boards_awarded)
    {
        foreach (player in level.players)
            player freezeControls(1);
        iPrintLn("^1RESTART REQUIRED");
        level notify("end_game");
    }
    return;
}
