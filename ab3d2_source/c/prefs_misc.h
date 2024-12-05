#ifndef PREFS_MISC_H
#define PREFS_MISC_H

    {
        "misc.show_fps",
        &Prefs_DisplayFPS_b,
        CFG_PARAM_TYPE_BOOL,
        CFG_VAR_TYPE_UBYTE
    },

    {
        "misc.original_mouse",
        &Prefs_OriginalMouse_b,
        CFG_PARAM_TYPE_BOOL,
        CFG_VAR_TYPE_UBYTE
    },
    {
        "misc.always_run",
        &Prefs_AlwaysRun_b,
        CFG_PARAM_TYPE_BOOL,
        CFG_VAR_TYPE_UBYTE
    },
    {
        "misc.disable_auto_aim",
        &Prefs_NoAutoAim_b,
        CFG_PARAM_TYPE_BOOL,
        CFG_VAR_TYPE_UBYTE
    },
    {
        "misc.crosshair_colour",
        &Prefs_CrossHairColour_b,
        CFG_PARAM_TYPE_INT,
        CFG_VAR_TYPE_UBYTE
    },
    {
        "misc.disable_messages",
        &Prefs_ShowMessages_b,
        CFG_PARAM_TYPE_BOOL_INV,
        CFG_VAR_TYPE_UBYTE
    },
    {
        "misc.oz_sensitivity",
        &Prefs_OrderZoneSensitivity,
        CFG_PARAM_TYPE_INT,
        CFG_VAR_TYPE_UBYTE
    },
    {
        "misc.edge_pvs_fov",
        &Zone_PVSFieldOfView,
        CFG_PARAM_TYPE_INT,
        CFG_VAR_TYPE_WORD
    },
    {
        "map.transparent",
        &Draw_MapTransparent_b,
        CFG_PARAM_TYPE_BOOL,
        CFG_VAR_TYPE_UBYTE
    },
    {
        "map.zoom",
        &Draw_MapZoomLevel_w,
        CFG_PARAM_TYPE_INT,
        CFG_VAR_TYPE_UWORD
    },

#endif // PREFS_MISC_H
