#include common_scripts\utility;

main()
{
    level thread safe_init();
}

safe_init()
{
    level waittill("frfix_init");
    level.FRFIX_HUD_PLUGIN = array();
    level.FRFIX_HUD_PLUGIN["timer_hud"] = ::get_timer_hud;
    level.FRFIX_HUD_PLUGIN["round_hud"] = ::get_round_hud;
    level.FRFIX_HUD_PLUGIN["hud_velocity"] = ::get_velocity_hud;
    level.FRFIX_HUD_PLUGIN["hud_zone"] = ::get_zones_hud;
}

get_timer_hud(input)
{
    data = array();

    switch (input)
    {
        case "v5":
            data["x_align"] = "TOPRIGHT";
            data["y_align"] = "TOPRIGHT";
            data["x_pos"] = -8;
            data["y_pos"] = 0;
            data["color"] = (0.9, 0.8, 1);
            break;
        case "zzeetaa":
            data["color"] = (0, 0.980, 0.604);
            break;
        case "Vistek":
            data["color"] = (1, 0.98, 0.35);
            break;
        case "Tonestone":
            data["color"] = (0.26, 0.87, 0.94);
            break;
        default:
            data = undefined;
    }

    return data;
}

get_round_hud(input)
{
    data = array();

    switch (input)
    {
        case "v5":
            data["x_align"] = "TOPRIGHT";
            data["y_align"] = "TOPRIGHT";
            data["x_pos"] = -8;
            data["y_pos"] = 17;
            data["color"] = (0.9, 0.8, 1);
            break;
        case "zzeetaa":
            data["color"] = (0, 0.980, 0.604);
            break;
        case "Vistek":
            data["color"] = (1, 0.98, 0.35);
            break;
        case "Tonestone":
            data["color"] = (0.26, 0.87, 0.94);
            break;
        default:
            data = undefined;
    }

    return data;
}

/* Yes color is redundant, but it may not be in the future so may as well have it */
get_velocity_hud(input)
{
    data = array();

    switch (input)
    {
        case "v5":
            data["x_align"] = "CENTER";
            data["y_align"] = "CENTER";
            data["x_pos"] = "CENTER";
            data["y_pos"] = 200;
            data["color"] = (0.9, 0.8, 1);
            break;
        case "zzeetaa":
            data["x_align"] = "TOPLEFT";
            data["y_align"] = "TOPLEFT";
            data["x_pos"] = -60;
            data["y_pos"] = -32;
            data["color"] = (0, 0.980, 0.604);
            break;
        case "Vistek":
            data["color"] = (1, 0.98, 0.35);
            break;
        case "Tonestone":
            data["color"] = (0.26, 0.87, 0.94);
            break;
        default:
            data = undefined;
    }

    return data;
}

get_zones_hud(input)
{
    data = array();

    switch (input)
    {
        case "v5":
            data["color"] = (0.9, 0.8, 1);
            break;
        case "zzeetaa":
            data["color"] = (0, 0.980, 0.604);
            break;
        case "Vistek":
            data["color"] = (1, 0.98, 0.35);
            break;
        case "Tonestone":
            data["color"] = (0.26, 0.87, 0.94);
            break;
        default:
            data = undefined;
    }
}
