/* Global code configuration */
#define RAW 1
#define DEBUG 0
#define DEBUG_HUD 0
#define BETA 0
#define DEPRECATION 5278

/* Const macros */
#define B2FR_VER "3.9"
#define VER_ANCIENT 353
#define VER_MODERN 1824
#define VER_2905 2905
#define VER_3K 3042
#define VER_4K 4516
#define NET_FRAME_SOLO 100
#define NET_FRAME_COOP 50
#define MAX_VALID_HEALTH 1044606905
#define CHALLENGE_PENDING 0
#define CHALLENGE_NEW 1
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
#define VERSION_FILE "b2fr/version.txt"
#define SEMTEX_DYNAMIC_CALC_ROUND 51
#define SEMTEX_PRENADES_MAP array(1, 2, 3, 4, 5, 7, 8, 9, 10, 12, 13, 17, 19, 22, 24, 28, 29, 34, 39, 42, 46, 52, 57, 61, 69, 78, 86, 96, 103)
#define SEMTEX_BEGIN_PRENADES_RND 22
#define STAT_CHAR_MAP "zm_highrise"
#define STAT_CHAR_VICTIS "clip"
#define STAT_CHAR_PRISON "stock"
#define STAT_CHAR_TOMB "alt_clip"
#define STAT_CHAR_SURVIVAL "lh_clip"
#define STAT_RETICLE_MAP "zm_tomb"
#define STAT_RETICLE "stock"
#define STAT_VELOCITY_METER_MAP "zm_tomb"
#define STAT_VELOCITY_METER "lh_clip"
#define RESTORE_WEAPONS 1
#define RESTORE_PERKS 2
#define WATERMARK_SLOT_PERM 0
#define WATERMARK_SLOT_TEMP 1
#define SLOT_ARRAY array(0, -90, 90, -180, 180, -270, 270, -360, 360, -450, 450, -540, 540, -630, 630)

/* Feature flags */
#define FEATURE_HUD 1
#define FEATURE_PERMAPERKS 1
#define FEATURE_HORDES 1
#define FEATURE_CHARACTERS 1
#define FEATURE_CONNECTOR 0
#define FEATURE_SEMTEX_CALC_PRENADE 1
#define FEATURE_CHALLENGES 1
#define FEATURE_CHALLENGE_WARDEN 0
#define FEATURE_LOADOUT_CACHE 1

/* Snippet macros */
#define LEVEL_ENDON \
    level endon("end_game");
#define PLAYER_ENDON \
    LEVEL_ENDON \
    self endon("disconnect");

/* Function macros */
#define COLOR_TXT(__txt, __color) __color + __txt + COL_WHITE
#define CLEAR(__var) __var = undefined;
#define MS_TO_SECONDS(__ms) int(__ms / 1000)
#define STR(__val) "" + (__val)
#if DEBUG == 1
#define DEBUG_PRINT(__txt) printf("DEBUG [" + convert_time() + "]: ^5" + __txt + "^7");
#else
#define DEBUG_PRINT(__txt)
#endif
