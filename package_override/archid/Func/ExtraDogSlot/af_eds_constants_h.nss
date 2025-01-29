// Indirectly Referenced By: (Recompile both if you change this file)
//   eds_dheu_module_core
//   eds_dheu_dying_override
//

const int AF_LOGGROUP_EDS = 7;
// ========================================================
// Variables
// ========================================================
// NOTE: All variables must be registered in var_module.2da

// Name of variable I store on PC to track
// if dog should be added after Party Screen
// Value is int
const string NODOGSLOT = "EDS_ND";

// Name of variable I store to track the NPC(tag)
// he is currently/was last attached to
// Value is string
const string DOG_OWNER = "EDS_WDO";

// When the PC hits the dog whistle button,
// we want to let the dog go away. But normally,
// we want to save the dog if a DYING event fires...
//
// so... we have a bypass variable which tells the DYING event
// to ignore what is going on...
// Value is int
const string DOG_BYPASS = "EDS_BP";

// Needed an event so I could delay removing
// the dog from the party when you blow the
// whistle (So he has time to run away)
const int EVENT_DOG_RAN_AWAY = 6610000;

// Needed to delay activating the dog when
// you return to camp. PC enters area before the
// dog actually exists, which causes the problem.
const int EVENT_MAKE_DOG_CLICKABLE = 6610001;

// Value of new AF_ABI_EDS_DOG_SUMMONED ability I added
// If I use the ITEM_DOG_WHISTLE value for the upkeep
// effect, then I can't use the item while the effect
// is still valid (till owner dies). So I made a new
// ability ID. Needed so I can differentiate between
// my new upkeep effect and the existing onces.
const int AF_ABI_EDS_DOG_SUMMONED  = 0;

// string in module string table for reporting potential
// conflict with another mod.
const int E1_EDS_CONFLICT = 6610052; // Dying only
const int E2_EDS_CONFLICT = 6610053; // Party Member Fired Only
const int E3_EDS_CONFLICT = 6610054; // Dying and Party Member Fired

const int W1_EDS_CONFLICT = 6610051; // Summon Died Only
const int W2_EDS_CONFLICT = 6610055; // Command Pending/Complete Only
const int W3_EDS_CONFLICT = 6610056; // Summon Died and Command Pending/Complete

// Boolean, tracks if the popup result us the result of us
// requesting the dog name.
const string EDS_GET_DOG_NAME = "EDS_DN";

// Variable used to remember if we have checked
// if there is a conflict. This allows more specific
// feedback and we only bother the user with it once.
// If they want the feedback again, they have to
// disable and re-enable the mod.
//
// 0 = never checked
// 1 = checked, no conflicts
// 2 = checked, conflicts (allows alternate implementation)
const string EDS_CHECK_CONFLICT = "EDS_CC";

// DOG RESTORATION VARIABLES
// ===========================================
// DOG_NAME is type string
const string EDS_DOG_NAME = "EDS_NA";
// DOG_XP is type float
const string EDS_DOG_XP = "EDS_XP";
// DOG_LEVEL is type float
const string EDS_DOG_LEVEL = "EDS_LV";
// DOG_XTRA_ATTRIBUTES is type float
const string EDS_DOG_XTRA_ATTRIBUTES = "EDS_AT";
// DOG_XTRA_SKILLS is type float
const string EDS_DOG_XTRA_SKILLS = "EDS_SK";
// DOG_XTRA_TALENTS is type float
const string EDS_DOG_XTRA_TALENTS = "EDS_TA";
// DOG_EQUIP_COLLAR is type string
const string EDS_DOG_EQUIP_COLLAR = "EDS_CO";
// DOG_EQUIP_WARPAINT is type string
const string EDS_DOG_EQUIP_WARPAINT = "EDS_PA";
// DOG_STR is type float
const string EDS_DOG_STR = "EDS_SR";
// DOG_CON is type float
const string EDS_DOG_CON = "EDS_CN";
// DOG_DEX is type float
const string EDS_DOG_DEX = "EDS_DX";
// DOG_INT is type float
const string EDS_DOG_INT = "EDS_IT";
// DOG_WIL is type float
const string EDS_DOG_WIL = "EDS_WL";
// DOG_MAG is type float
const string EDS_DOG_MAG = "EDS_MG";

// DOG_HAS_CHARGE is type int
const string EDS_DOG_HAS_CHARGE = "EDS_CA";
// DOG_HAS_COMBAT is type int
const string EDS_DOG_HAS_COMBAT = "EDS_CM";
// DOG_HAS_FORT is type int
const string EDS_DOG_HAS_FORT = "EDS_FO";
// DOG_HAS_GROWL is type int
const string EDS_DOG_HAS_GROWL = "EDS_GR";
// DOG_HAS_NEMESIS is type int
const string EDS_DOG_HAS_NEMESIS = "EDS_NE";
// DOG_HAS_OVERWHELM is type int
const string EDS_DOG_HAS_OVERWHELM = "EDS_OW";
// DOG_HAS_SHRED is type int
const string EDS_DOG_HAS_SHRED = "EDS_SH";
// DOG_HAS_HOWL is type int
const string EDS_DOG_HAS_HOWL = "EDS_HW";

/* Whistle Item */

// Value of new ITEM_DOG_WHISTLE ability I added
// This was attached to the item instead of UNIQUE_POWER
// so that I could control the animation.
const int AF_ABI_EDS_DOG_WHISTLE  = 6610009;

// Tag of Dog whistle item
const string AF_ITM_EDS_DOG_WHISTLE = "af_eds_dog_whistle";

// Resource of Dog Wistle
const resource AF_ITR_EDS_WHISTLE = R"af_eds_dog_whistle.uti";

// Dog resource
const resource GEN_FLR_DOG = R"gen00fl_dog.utc";

const resource AF_RES_SYS_TREASURE =  R"sys_treasure.ncs";