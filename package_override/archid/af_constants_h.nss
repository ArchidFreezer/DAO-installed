/*
* List of constants used by multiple functional components in the Archid mod
* Constants that are tied to functionality should be defined in a fuunctional specific script to remove the
*  number of scripts that require recompilation on changes to this file
*/

////
//  Popup Window Types
////

const int AF_POPUP_INVALID                 = 0;
const int AF_POPUP_QUESTION                = 1;   // "Yes/No"
const int AF_POPUP_RENAME_DOG              = 2;   // "Confirm"
const int AF_POPUP_BLOCKING_PLACEABLE      = 3;   // "OK"
const int AF_POPUP_MESSAGE                 = 4;   // "OK"
const int AF_POPUP_PRE_CHARGEN             = 5;   // "OK"

//------------------------------------------------------------------------------
// ITEMS
//------------------------------------------------------------------------------
const resource AF_ITR_AMMO_PHOENIX_DISRUPT      = R"af_ammo_pnxdisrupt.uti";
const resource AF_ITR_AMMO_PHOENIX_FLASH        = R"af_ammo_pnxflash.uti";
const resource AF_ITR_AMMO_PHOENIX_THUNDER      = R"af_ammo_pnxthunder.uti";
const resource AF_ITR_ARM_GARAHEL               = R"af_chest_mas_gar.uti";
const resource AF_ITR_ARM_IVORY_TOWER           = R"af_chest_hvy_ivt.uti";
const resource AF_ITR_ARM_PHOENIX_BMAID         = R"af_chest_med_pnx.uti";
const resource AF_ITR_ARM_PHOENIX_SCOUT         = R"af_chest_lgt_pnx.uti";
const resource AF_ITR_ARM_PHOENIX_MATR          = R"af_chest_hvy_pnx.uti";
const resource AF_ITR_ARM_SUNDOWN               = R"af_chest_lgt_sdh.uti";
const resource AF_ITR_BOOT_GARAHEL              = R"af_boot_mas_gar.uti";
const resource AF_ITR_BOOT_IVORY_TOWER          = R"af_boot_hvy_ivt.uti";
const resource AF_ITR_BOOT_PHOENIX_BMAID        = R"af_boot_med_pnx.uti";
const resource AF_ITR_BOOT_PHOENIX_SCOUT        = R"af_boot_lgt_pnx.uti";
const resource AF_ITR_BOOT_PHOENIX_MATR         = R"af_boot_hvy_pnx.uti";
const resource AF_ITR_BOOT_SUNDOWN              = R"af_boot_lgt_sdh.uti";
const resource AF_ITR_BOOT_WINGS                = R"af_boot_lgt_wings.uti";
const resource AF_ITR_DAGG_NIGHTFALL_BLOOM      = R"af_dagg_nfb.uti";
const resource AF_ITR_DAGG_PHOENIX_HID4         = R"af_dagg_pnxh4.uti";
const resource AF_ITR_DAGG_PHOENIX_HID7         = R"af_dagg_pnxh7.uti";
const resource AF_ITR_DAGG_PHOENIX_MIG4         = R"af_dagg_pnxm4.uti";
const resource AF_ITR_DAGG_PHOENIX_MIG7         = R"af_dagg_pnxm7.uti";
const resource AF_ITR_DAGG_SUNDOWN_SUNRISE      = R"af_dagg_sdh_sunrise.uti";
const resource AF_ITR_DAGG_SUNDOWN_SUNSET       = R"af_dagg_sdh_sunset.uti";
const resource AF_ITR_GLOVE_GARAHEL             = R"af_glove_mas_gar.uti";
const resource AF_ITR_GLOVE_IVORY_TOWER         = R"af_glove_hvy_ivt.uti";
const resource AF_ITR_GLOVE_PHOENIX_BMAID       = R"af_glove_med_pnx.uti";
const resource AF_ITR_GLOVE_PHOENIX_SCOUT       = R"af_glove_lgt_pnx.uti";
const resource AF_ITR_GLOVE_PHOENIX_MATR        = R"af_glove_hvy_pnx.uti";
const resource AF_ITR_GLOVE_SUNDOWN             = R"af_glove_lgt_sdh.uti";
const resource AF_ITR_GLOVE_WINGS               = R"af_glove_lgt_wings.uti";
const resource AF_ITR_HELM_IVORY_TOWER          = R"af_helm_hvy_ivt.uti";
const resource AF_ITR_HELM_PHOENIX_BMAID        = R"af_helm_med_pnx.uti";
const resource AF_ITR_HELM_SUNDOWN              = R"af_helm_lgt_sdh.uti";
const resource AF_ITR_HELM_WINGS                = R"af_helm_cth_wings.uti";
const resource AF_ITR_LBOW_PHOENIX4             = R"af_lbow_pnx4.uti";
const resource AF_ITR_LBOW_PHOENIX7             = R"af_lbow_pnx7.uti";
const resource AF_ITR_LBOW_SUNDOWN              = R"af_lbow_sdh.uti";
const resource AF_ITR_LSWORD_GARAHEL_FURY       = R"af_lsword_gar_fury.uti";
const resource AF_ITR_LSWORD_GARAHEL_VIGILANCE  = R"af_lsword_gar_vigil.uti";
const resource AF_ITR_LSWORD_NIGHTFALL_BLOOM    = R"af_lsword_nfb.uti";
const resource AF_ITR_LSWORD_SUNDOWN_DAYBREAK   = R"af_lsword_sdh_daybreak.uti";
const resource AF_ITR_LSWORD_SUNDOWN_NIGHTFALL  = R"af_lsword_sdh_nightfall.uti";
const resource AF_ITR_ROBE_WINGS                = R"af_robe_wings.uti";
const resource AF_ITR_SBOW_PHOENIX4             = R"af_sbow_pnx4.uti";
const resource AF_ITR_SBOW_PHOENIX7             = R"af_sbow_pnx7.uti";
const resource AF_ITR_SHIELD_NIGHTFALL_BLOOM    = R"af_shield_tow_nfb.uti";
const resource AF_ITR_STAFF_WINGS               = R"af_staff_wings.uti";

const string   AF_IT_AMMO_PHOENIX_DISRUPT       = "af_ammo_pnxdisrupt";
const string   AF_IT_AMMO_PHOENIX_FLASH         = "af_ammo_pnxflash";
const string   AF_IT_AMMO_PHOENIX_THUNDER       = "af_ammo_pnxthunder";
const string   AF_IT_ARM_GARAHEL                = "af_chest_mas_gar";
const string   AF_IT_ARM_IVORY_TOWER            = "af_chest_hvy_ivt";
const string   AF_IT_ARM_PHOENIX_BMAID          = "af_chest_med_pnx";
const string   AF_IT_ARM_PHOENIX_SCOUT          = "af_chest_lgt_pnx";
const string   AF_IT_ARM_PHOENIX_MATR           = "af_chest_hvy_pnx";
const string   AF_IT_ARM_SUNDOWN                = "af_chest_lgt_sdh";
const string   AF_IT_BOOT_GARAHEL               = "af_boot_mas_gar";
const string   AF_IT_BOOT_IVORY_TOWER           = "af_boot_hvy_ivt";
const string   AF_IT_BOOT_PHOENIX_BMAID         = "af_boot_med_pnx";
const string   AF_IT_BOOT_PHOENIX_SCOUT         = "af_boot_lgt_pnx";
const string   AF_IT_BOOT_PHOENIX_MATR          = "af_boot_hvy_pnx";
const string   AF_IT_BOOT_SUNDOWN               = "af_boot_lgt_sdh";
const string   AF_IT_BOOT_WINGS                 = "af_boot_lgt_wings";
const string   AF_IT_DAGG_NIGHTFALL_BLOOM       = "af_dagg_nfb";
const string   AF_IT_DAGG_PHOENIX_HID4          = "af_dagg_pnxh4";
const string   AF_IT_DAGG_PHOENIX_HID7          = "af_dagg_pnxh7";
const string   AF_IT_DAGG_PHOENIX_MIG4          = "af_dagg_pnxm4";
const string   AF_IT_DAGG_PHOENIX_MIG7          = "af_dagg_pnxm7";
const string   AF_IT_DAGG_SUNDOWN_SUNRISE       = "af_dagg_sdh_sunrise";
const string   AF_IT_DAGG_SUNDOWN_SUNSET        = "af_dagg_sdh_sunset";
const string   AF_IT_GLOVE_GARAHEL              = "af_glove_mas_gar";
const string   AF_IT_GLOVE_IVORY_TOWER          = "af_glove_hvy_ivt";
const string   AF_IT_GLOVE_PHOENIX_BMAID        = "af_glove_med_pnx";
const string   AF_IT_GLOVE_PHOENIX_SCOUT        = "af_glove_lgt_pnx";
const string   AF_IT_GLOVE_PHOENIX_MATR         = "af_glove_hvy_pnx";
const string   AF_IT_GLOVE_SUNDOWN              = "af_glove_lgt_sdh";
const string   AF_IT_GLOVE_WINGS                = "af_glove_lgt_wings";
const string   AF_IT_HELM_IVORY_TOWER           = "af_helm_hvy_ivt";
const string   AF_IT_HELM_PHOENIX_BMAID         = "af_helm_med_pnx";
const string   AF_IT_HELM_SUNDOWN               = "af_helm_lgt_sdh";
const string   AF_IT_HELM_WINGS                 = "af_helm_cth_wings";
const string   AF_IT_LBOW_PHOENIX4              = "af_lbow_pnx4";
const string   AF_IT_LBOW_PHOENIX7              = "af_lbow_pnx7";
const string   AF_IT_LBOW_SUNDOWN               = "af_lbow_sdh";
const string   AF_IT_LSWORD_GARAHEL_FURY        = "af_lsword_gar_fury";
const string   AF_IT_LSWORD_GARAHEL_VIGILANCE   = "af_lsword_gar_vigil";
const string   AF_IT_LSWORD_NIGHTFALL_BLOOM     = "af_lsword_nfb";
const string   AF_IT_LSWORD_SUNDOWN_DAYBREAK    = "af_lsword_sdh_daybreak";
const string   AF_IT_LSWORD_SUNDOWN_NIGHTFALL   = "af_lsword_sdh_nightfall";
const string   AF_IT_ROBE_WINGS                 = "af_robe_wings";
const string   AF_IT_SBOW_PHOENIX4              = "af_sbow_pnx4";
const string   AF_IT_SBOW_PHOENIX7              = "af_sbow_pnx7";
const string   AF_IT_SHIELD_NIGHTFALL_BLOOM     = "af_shield_tow_nfb";
const string   AF_IT_STAFF_WINGS                = "af_staff_wings";

//------------------------------------------------------------------------------
// PLACEABLES
//------------------------------------------------------------------------------
