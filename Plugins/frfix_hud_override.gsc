#include common_scripts\utility;

init()
{
    level.FRFIX_HUD_POS_PLUGIN = array();
    level.FRFIX_HUD_POS_PLUGIN["timer_hud"] = get_timer_hud();
    level.FRFIX_HUD_POS_PLUGIN["round_hud"] = get_round_hud();
    level.FRFIX_HUD_POS_PLUGIN["hordes_hud"] = get_hordes_hud();
    level.FRFIX_HUD_POS_PLUGIN["splits_hud"] = get_splits_hud();
    level.FRFIX_HUD_POS_PLUGIN["hud_velocity"] = get_velocity_hud();
    level.FRFIX_HUD_POS_PLUGIN["semtex_hud"] = get_semtex_hud();
}

get_timer_hud(active)
{
    if (isDefined(active) && active)
    {
        data = array();
        data["x_align"] = "TOPRIGHT";
        data["y_align"] = "TOPRIGHT";
        data["x_pos"] = -8;
        data["y_pos"] = 0;
    }
    else
    {
        data = undefined;
    }

    return data;
}

get_round_hud(active)
{
    if (isDefined(active) && active)
    {
        data = array();
        data["x_align"] = "TOPRIGHT";
        data["y_align"] = "TOPRIGHT";
        data["x_pos"] = -8;
        data["y_pos"] = 17;
    }
    else
    {
        data = undefined;
    }

    return data;
}

get_splits_hud(active)
{
    if (isDefined(active) && active)
    {
        data = array();
        data["x_align"] = "CENTER";
        data["y_align"] = "TOP";
        data["x_pos"] = 0;
        data["y_pos"] = 30;
    }
    else
    {
        data = undefined;
    }

    return data;
}

get_hordes_hud(active)
{
    if (isDefined(active) && active)
    {
        data = array();
        data["x_align"] = "CENTER";
        data["y_align"] = "BOTTOM";
        data["x_pos"] = 0;
        data["y_pos"] = -75;
    }
    else
    {
        data = undefined;
    }

    return data;
}

get_velocity_hud(active)
{
    if (isDefined(active) && active)
    {
        data = array();
        data["x_align"] = "CENTER";
        data["y_align"] = "CENTER";
        data["x_pos"] = "CENTER";
        data["y_pos"] = 200;
    }
    else
    {
        data = undefined;
    }

    return data;
}

get_semtex_hud(active)
{
    if (isDefined(active) && active)
    {
        data = array();
        data["x_align"] = "CENTER";
        data["y_align"] = "BOTTOM";
        data["x_pos"] = 0;
        data["y_pos"] = -95;
    }
    else
    {
        data = undefined;
    }

    return data;
}