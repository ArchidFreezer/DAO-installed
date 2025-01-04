/////////////////////////////////////
// Single Player module events
/////////////////////////////////////

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "events_h"
#include "global_objects_h"
#include "party_h"
#include "approval_h"

#include "plt_genpt_alistair_events"
#include "plt_genpt_leliana_events"
#include "plt_genpt_leliana_main"
#include "plt_genpt_morrigan_events"
#include "plt_genpt_sten_events"
#include "plt_genpt_zevran_events"
#include "den_constants_h"
#include "arl_constants_h"

#include "plt_nrdpt_drake_scales"
#include "plt_den200pt_dragon_scales"

#include "plt_cod_itm_blood_ring"
#include "plt_cod_itm_bow_golden_sun"
#include "plt_cod_itm_life_drinker"
#include "plt_cod_itm_magister_shield"
#include "plt_cod_itm_summer_sword"
#include "plt_cod_itm_thorn_dead_gods"
#include "plt_cod_itm_yusaris"
#include "plt_cod_lite_tow_jenny"
#include "plt_lite_tow_jenny"
// Qwinn added
#include "plt_orz400pt_rogek"
#include "plt_qwinn"
#include "plt_genpt_morrigan_main"

#include "plt_cod_itm_darkmoon"
#include "plt_cod_itm_shadow"
#include "plt_cod_itm_bard"
#include "plt_cod_itm_katriel"
#include "plt_cod_itm_aegis"
#include "plt_cod_itm_camenae"
#include "plt_cod_itm_aodh"
#include "plt_cod_itm_thorval"
#include "plt_cod_itm_anc_elv_armor"
#include "plt_cod_dal_falondin"
#include "plt_cod_dal_mythal"

#include "ran_constants_h"
#include "plt_lite_chant_rand_remains"
#include "plt_lite_tow_jenny"
#include "plt_cod_lite_tow_jenny"


//------------------------------------------------------------------------------

const resource  RESOURCE_SCRIPT_PRE_ITEM_ACQUIRED = R"preev_item_acquired.nss";
const resource  RESOURCE_SCRIPT_BDC_ITEM_ACQUIRED = R"bdcev_item_acquired.nss";
const resource  RESOURCE_SCRIPT_BDN_ITEM_ACQUIRED = R"bdnev_item_acquired.nss";
const resource  RESOURCE_SCRIPT_ORZ_ITEM_ACQUIRED = R"orzev_item_acquired.nss";
const resource  RESOURCE_SCRIPT_CIR_ITEM_ACQUIRED = R"cirev_item_acquired.nss";
const resource  RESOURCE_SCRIPT_LOT_ITEM_ACQUIRED = R"lotev_item_acquired.nss";
const resource  RESOURCE_SCRIPT_DEN_ITEM_ACQUIRED = R"denev_item_acquired.nss";
const resource  RESOURCE_SCRIPT_ARL_ITEM_ACQUIRED = R"arlev_item_acquired.nss";
const resource  RESOURCE_SCRIPT_NRD_ITEM_ACQUIRED = R"nrdev_item_acquired.nss";
const resource  RESOURCE_SCRIPT_RAN_ITEM_ACQUIRED = R"ranev_item_acquired.nss";
const resource  RESOURCE_SCRIPT_NTB_ITEM_ACQUIRED = R"ntbev_item_acquired.nss";
const resource  RESOURCE_SCRIPT_URN_ITEM_ACQUIRED = R"urnev_item_acquired.nss";
const resource  RESOURCE_SCRIPT_BHM_ITEM_ACQUIRED = R"bhmev_item_acquired.nss";
const resource  RESOURCE_SCRIPT_GEN_ITEM_ACQUIRED = R"genev_item_acquired.nss";
const resource  RESOURCE_SCRIPT_LIT_ITEM_ACQUIRED = R"litev_item_acquired.nss";

//------------------------------------------------------------------------------

void _PassEventToPlotHandler(string sItemTag, event evEvent);

void main()
{

    //--------------------------------------------------------------------------
    // Initialization
    //--------------------------------------------------------------------------

    // Load Event Variables
    event   evEvent     = GetCurrentEvent();
    int     nEventType  = GetEventType(evEvent);

    // Grab Player, set default event handled to false
    object  oPC           = GetHero();
    int     bEventHandled = FALSE;

    Log_Events(GetCurrentScriptName(),evEvent);



    //--------------------------------------------------------------------------

    switch(nEventType)
    {


        case EVENT_TYPE_CAMPAIGN_ITEM_ACQUIRED:
        {

            //------------------------------------------------------------------
            // EVENT_TYPE_CAMPAIGN_ITEM_ACQUIRED
            //------------------------------------------------------------------
            // Sent by: Scripting
            // When:    Item is added to inventory that has
            //          ITEM_SEND_ACQUIRED_EVENT set to TRUE
            //------------------------------------------------------------------

            string      sItemTag;
            object      oItem;
            object      oAcquirer;

            //------------------------------------------------------------------

            oAcquirer = GetEventCreator(evEvent);
            oItem     = GetEventObject(evEvent, 0);
            sItemTag  = GetTag(oItem);
            //------------------------------------------------------------------

            // If the main player -> handle special items
            // IMPORTANT!!! in here we assume this event is fired when choosing the special
            // GIFTING interface - we would probably require a new parameter to know if the item was gifted or not.
            // Another option is moving it to the equip event, but that won't work with non-equipable items.
/*used in the gift code instead
            if(GetTag(oAcquirer) == GEN_FL_ALISTAIR) // The player gives Alistair some special items
            {
                if(sItemTag == DEN_IT_DUNCANS_SHIELD)
                {
                    WR_SetPlotFlag(PLT_GENPT_ALISTAIR_EVENTS, ALISTAIR_EVENT_ON, TRUE);
                    WR_SetPlotFlag(PLT_GENPT_ALISTAIR_EVENTS, ALISTAIR_EVENT_GIVEN_DUNCANS_SHIELD, TRUE);
                    UT_Talk(oAcquirer, GetHero());
                    return;
                }
                else if(sItemTag == GEN_IM_GIFT_ALIAMULET)
                {
                    WR_SetPlotFlag(PLT_GENPT_ALISTAIR_EVENTS, ALISTAIR_EVENT_ON, TRUE);
                    WR_SetPlotFlag(PLT_GENPT_ALISTAIR_EVENTS, ALISTAIR_EVENT_GIVEN_MOTHERS_AMULET, TRUE);
                    UT_Talk(oAcquirer, GetHero());
                    return;
                }
            }
            */
            // If the PC gets a drake scale, then set the flag for the drake scale armor plot
            if (sItemTag == DEN_IT_DRAKE_SCALE)
            {
                /*
                if( WR_GetPlotFlag(PLT_NRDPT_DRAKE_SCALES, HERREN_TALKED_TO) )
                {
                    WR_SetPlotFlag(PLT_NRDPT_DRAKE_SCALES, KNOW_ABOUT_DRAKE_SCALE_CRAFTING, TRUE, TRUE);
                }
                else
                {*/
                WR_SetPlotFlag(PLT_NRDPT_DRAKE_SCALES, JOURNAL_PC_FOUND_DRAKE_SCALE, TRUE, TRUE);
                SetLocalInt(oItem,"ITEM_SEND_ACQUIRED_EVENT",0);
                // }
            }
            else if (sItemTag == DEN_IT_DRAGON_SCALE)
            {
                WR_SetPlotFlag(PLT_DEN200PT_DRAGON_SCALES, PC_HAS_DRAGON_SCALE, TRUE, TRUE);
                SetLocalInt(oItem,"ITEM_SEND_ACQUIRED_EVENT",0);
            }
            else if(sItemTag == "gen_im_acc_rng_bld")
            {
                WR_SetPlotFlag(PLT_COD_ITM_BLOOD_RING, COD_ITM_BLOOD_RING, TRUE, TRUE);
                SetLocalInt(oItem,"ITEM_SEND_ACQUIRED_EVENT",0);
            }
            else if(sItemTag == "gen_im_wep_rng_lbw_sun")
            {
                WR_SetPlotFlag(PLT_COD_ITM_BOW_GOLDEN_SUN, COD_ITM_BOW_GOLDEN_SUN, TRUE, TRUE);
                SetLocalInt(oItem,"ITEM_SEND_ACQUIRED_EVENT",0);
            }
            else if(sItemTag == "gen_im_acc_amu_am6")
            {
                WR_SetPlotFlag(PLT_COD_ITM_LIFE_DRINKER, COD_ITM_LIFE_DRINKER, TRUE, TRUE);
                SetLocalInt(oItem,"ITEM_SEND_ACQUIRED_EVENT",0);
            }
            else if(sItemTag == "gen_im_acc_amu_am16")
            {
                WR_SetPlotFlag(PLT_COD_ITM_MAGISTER_SHIELD, COD_ITM_MAGISTER_SHIELD, TRUE, TRUE);
                SetLocalInt(oItem,"ITEM_SEND_ACQUIRED_EVENT",0);
            }
            else if(sItemTag == "gen_im_wep_mel_gsw_sum")
            {
                WR_SetPlotFlag(PLT_COD_ITM_SUMMER_SWORD, COD_ITM_SUMMER_SWORD, TRUE, TRUE);
                SetLocalInt(oItem,"ITEM_SEND_ACQUIRED_EVENT",0);
            }
            else if(sItemTag == "gen_im_wep_mel_dag_thh" ||GetTag(oItem) == "gen_im_wep_mel_dag_thn" ||GetTag(oItem) =="gen_im_wep_mel_dag_ths")
            {
                WR_SetPlotFlag(PLT_COD_ITM_THORN_DEAD_GODS, COD_ITM_THORN_DEAD_GODS, TRUE, TRUE);
                if (GetTag(oItem) == "gen_im_wep_mel_dag_ths")
                {
                   WR_SetPlotFlag(PLT_QWINN,ORZ_DACE_DAGGER_STOLEN,TRUE);
                }
                SetLocalInt(oItem,"ITEM_SEND_ACQUIRED_EVENT",0);
            }
            else if(sItemTag == "gen_im_wep_mel_gsw_yus")
            {
                WR_SetPlotFlag(PLT_COD_ITM_YUSARIS, COD_ITM_YUSARIS, TRUE, TRUE);
                SetLocalInt(oItem,"ITEM_SEND_ACQUIRED_EVENT",0);
            }

            else if(sItemTag == "gen_im_wep_rng_sbw_new")
            {
                WR_SetPlotFlag(PLT_COD_ITM_DARKMOON, COD_ITM_DARKMOON, TRUE, TRUE);
                SetLocalInt(oItem,"ITEM_SEND_ACQUIRED_EVENT",0);
            }
            else if(sItemTag == "gen_im_arm_cht_lgt_new")
            {
                WR_SetPlotFlag(PLT_COD_ITM_SHADOW, COD_ITM_SHADOW, TRUE, TRUE);
                SetLocalInt(oItem,"ITEM_SEND_ACQUIRED_EVENT",0);
            }
            else if(sItemTag == "gen_im_arm_bot_lgt_new")
            {
                WR_SetPlotFlag(PLT_COD_ITM_BARD, COD_ITM_BARD, TRUE, TRUE);
                SetLocalInt(oItem,"ITEM_SEND_ACQUIRED_EVENT",0);
            }
            else if(sItemTag == "gen_im_arm_glv_lgt_new")
            {
                WR_SetPlotFlag(PLT_COD_ITM_KATRIEL, COD_ITM_KATRIEL, TRUE, TRUE);
                SetLocalInt(oItem,"ITEM_SEND_ACQUIRED_EVENT",0);
            }
            else if(sItemTag == "gen_im_arm_shd_kit_new")
            {
                WR_SetPlotFlag(PLT_COD_ITM_AEGIS, COD_ITM_AEGIS, TRUE, TRUE);
                SetLocalInt(oItem,"ITEM_SEND_ACQUIRED_EVENT",0);
            }
            else if(sItemTag == "gen_im_arm_hel_med_new")
            {
                WR_SetPlotFlag(PLT_COD_ITM_CAMENAE, COD_ITM_CAMENAE, TRUE, TRUE);
                SetLocalInt(oItem,"ITEM_SEND_ACQUIRED_EVENT",0);
            }
            else if(sItemTag == "gen_im_wep_mel_axe_new")
            {
                WR_SetPlotFlag(PLT_COD_ITM_AODH, COD_ITM_AODH, TRUE, TRUE);
                SetLocalInt(oItem,"ITEM_SEND_ACQUIRED_EVENT",0);
            }
            else if(sItemTag == "gen_im_wep_mal_new")
            {
                WR_SetPlotFlag(PLT_COD_ITM_THORVAL, COD_ITM_THORVAL, TRUE, TRUE);
                SetLocalInt(oItem,"ITEM_SEND_ACQUIRED_EVENT",0);
            }
            else if(sItemTag == "gen_im_arm_cht_med_elv")
            {
                WR_SetPlotFlag(PLT_COD_ITM_ANC_ELV_ARMOR, COD_ITM_ANC_ELV_ARMOR, TRUE, TRUE);
                SetLocalInt(oItem,"ITEM_SEND_ACQUIRED_EVENT",0);
            }
            else if (sItemTag == "gen_im_wep_rng_lbw_fal")
            {
                WR_SetPlotFlag(PLT_COD_DAL_FALONDIN, COD_DAL_FALONDIN_MAIN, TRUE, TRUE);
                SetLocalInt(oItem,"ITEM_SEND_ACQUIRED_EVENT",0);
            }
            else if (sItemTag == "gen_im_arm_shd_sml_mth")
            {
                WR_SetPlotFlag(PLT_COD_DAL_MYTHAL, COD_DAL_MYTHAL_MAIN, TRUE, TRUE);
                SetLocalInt(oItem,"ITEM_SEND_ACQUIRED_EVENT",0);
            }
            else if ( sItemTag == RAN_600_SOLDIERS_DIARY )
            {
                //Mark plot done
                WR_SetPlotFlag(PLT_LITE_CHANT_RAND_REMAINS, REMAINS_PLOT_COMPLETED, TRUE, TRUE);
                UT_RemoveItemFromInventory(R_RAN_600_SOLDIERS_DIARY);
                 //turn off on world map
                object oMapLocation = GetObjectByTag("wml_lc_battlefield");
                WR_SetWorldMapLocationStatus(oMapLocation, FALSE);
            }
            // Light Content Plot - Friends of Red Jenny
            else if(sItemTag == RAN_402_JENNY_LETTER)
            {
                //set that letter acquired and give letter codex
                WR_SetPlotFlag(PLT_COD_LITE_TOW_JENNY, TOW_JENNY_MAIN, TRUE, TRUE);
                WR_SetPlotFlag(PLT_LITE_TOW_JENNY, TOW_JENNY_LETTER_ACQUIRED, TRUE, TRUE);

                //if you already have the box - open the journal
                if (WR_GetPlotFlag(PLT_LITE_TOW_JENNY, TOW_JENNY_BOX_ACQUIRED) == TRUE)
                {
                    WR_SetPlotFlag(PLT_LITE_TOW_JENNY, TOW_JENNY_QUEST_START, TRUE, TRUE);
                }
                SetLocalInt(oItem,"ITEM_SEND_ACQUIRED_EVENT",0);
                break; // AVOID PLOT HANDLER
            }
            // Added by Qwinn to reset quest if Lyrium is reacquired.
            else if(sItemTag == "orz400im_rogek_lyrium")
            {
                if(WR_GetPlotFlag( PLT_ORZ400PT_ROGEK, ORZ_ROGEK___PLOT_FAILED))
                {
                    WR_SetPlotFlag( PLT_ORZ400PT_ROGEK, ORZ_ROGEK___PLOT_FAILED, FALSE);
                    WR_SetPlotFlag( PLT_ORZ400PT_ROGEK, ORZ_ROGEK___PLOT_01_ACCEPTED, FALSE);
                    WR_SetPlotFlag( PLT_ORZ400PT_ROGEK, ORZ_ROGEK___PLOT_01_ACCEPTED, TRUE);
                }
                break;
            }
            // Added by Qwinn to prevent Champion's Shield from being repeatedly stolen from Vartag
            else if(sItemTag == "gen_im_arm_shd_lrg_chm")
            {
                WR_SetPlotFlag(PLT_QWINN,ORZ_VARTAG_SHIELD_STOLEN,TRUE);
                SetLocalInt(oItem,"ITEM_SEND_ACQUIRED_EVENT",0);
                break;
            }
            // Added by Qwinn to prevent Nugbane from being stolen twice from the Orzammar Mines Commander
            else if (sItemTag == "gen_im_wep_rng_cbw_dus")
            {
                WR_SetPlotFlag(PLT_QWINN,ORZ_NUGBANE_STOLEN,TRUE);
                SetLocalInt(oItem,"ITEM_SEND_ACQUIRED_EVENT",0);
                break;
            }
            // Added by Qwinn to prevent Hardy's Belt from being stolen twice from the Ostagar Quartermaster
            else if (sItemTag == "gen_im_acc_blt_f1a")
            {
                WR_SetPlotFlag(PLT_QWINN,PRE_HARDYS_BELT_STOLEN,TRUE);
                SetLocalInt(oItem,"ITEM_SEND_ACQUIRED_EVENT",0);
                break;
            }
            // Added by Qwinn to make Kaitlyn's blade different from all other green blades in game so it can be removed safely
            else if (sItemTag == "gen_im_wep_mel_lsw_rwd")
            {
                SetTag(oItem,"kaitlyn_sword");
                SetLocalInt(oItem,"ITEM_SEND_ACQUIRED_EVENT",0);
                break;
            }
            // Added by Qwinn to prevent game from being blocked by somehow destroying all werewolf pelts while Hermit might still need
            else if (sItemTag == "gen_im_pelt_werewolf" && WR_GetPlotFlag(PLT_QWINN,NTB_HERMIT_PLOT_PELT_CREATED) == FALSE)
            {
                WR_SetPlotFlag(PLT_QWINN,NTB_HERMIT_PLOT_PELT_CREATED,TRUE,TRUE);
                RemoveItem(oItem, 1);
                UT_AddItemToInventory(R"gen_im_pelt_ww_plot.uti");
                SetLocalInt(oItem,"ITEM_SEND_ACQUIRED_EVENT",0);
                break;
            }
            // Added by Qwinn to restore Morrigan post-Flemeth dialogue
            else if (sItemTag == "gen_im_gift_flmgrimoire")
            {
                WR_SetPlotFlag(PLT_GENPT_MORRIGAN_EVENTS, MORRIGAN_EVENT_FLEMITH_PLOT_COMPLETED,TRUE);
                SetLocalInt(oItem,"ITEM_SEND_ACQUIRED_EVENT",0);
                break;
            }



            int nCodexItem = GetLocalInt(oItem, ITEM_CODEX_FLAG);
            if(nCodexItem == -1)
                _PassEventToPlotHandler(sItemTag,evEvent);

            break;

        }
        case EVENT_TYPE_MODULE_HANDLE_GIFT:
        {
            object oFollower = GetEventObject(evEvent, 0);
            object oItem = GetEventObject(evEvent, 1);
            string sGiftTag = GetTag(oItem);
            int nApprovalChange = GetEventInteger(evEvent, 0);
            Log_Trace(LOG_CHANNEL_SYSTEMS,"sp_module_item_acq.nss/EVENT_TYPE_MODULE_HANDLE_GIFT","GIFT TAG: " + sGiftTag);
            Log_Trace(LOG_CHANNEL_SYSTEMS,"sp_module_item_acq.nss/EVENT_TYPE_MODULE_HANDLE_GIFT","FOLLOWER: " + GetTag(oFollower));
            // IMPORTANT!!! the item may be destroyed at this moment!!!
            object oAlistair        = Party_GetFollowerByTag(GEN_FL_ALISTAIR);
            object oMorrigan        = Party_GetFollowerByTag(GEN_FL_MORRIGAN);
            object oLeliana         = Party_GetFollowerByTag(GEN_FL_LELIANA);
            object oSten            = Party_GetFollowerByTag(GEN_FL_STEN);
            object oZevran          = Party_GetFollowerByTag(GEN_FL_ZEVRAN);

            int bRefunded = FALSE;


            // ===================================================
            // REFUND ITEM SECTION
            // ===================================================

            resource rFlmGrimoire   = R"gen_im_gift_flmgrimoire.uti";
            resource rBlkGrimoire   = R"gen_im_gift_blkgrimoire.uti";
            resource rMirror        = R"gen_im_gift_mirror.uti";

            resource rStenSword     = R"gen_im_gift_sword_sten.uti";
            resource rNug           = R"gen_im_gift_nugg.uti";
            resource rWhiteFlower   = R"gen_im_gift_flower_andraste.uti";

            // Any of these dialog causing gifts given to the wrong follower
            // will be refunded to the player.

            if ((sGiftTag == "gen_im_gift_grimoire") && (oFollower != oMorrigan))
                bRefunded = TRUE;
                                 
            if ((sGiftTag == "gen_im_gift_flmgrimoire") && (oFollower != oMorrigan))
                bRefunded = TRUE;
                
            // Qwinn added to deal with hacks and cheats giving the player the real grimoire early
            if ((sGiftTag == "gen_im_gift_flmgrimoire") &&
                (WR_GetPlotFlag(PLT_GENPT_MORRIGAN_MAIN,MORRIGAN_MAIN_FLEMITH_ALIVE) == FALSE) &&
                (WR_GetPlotFlag(PLT_GENPT_MORRIGAN_MAIN,MORRIGAN_MAIN_FLEMITH_PLOT_COMPLETED) == FALSE))
                bRefunded = TRUE;                

            if ((sGiftTag == "gen_im_gift_mirror") && (oFollower != oMorrigan))
                bRefunded = TRUE;

            if ((sGiftTag == "gen_im_gift_sword_sten") && (oFollower != oSten))
                bRefunded = TRUE;

            if ((sGiftTag == "gen_im_gift_nugg") && (oFollower != oLeliana))
                bRefunded = TRUE;

            if ((sGiftTag == "gen_im_gift_flower_andraste") && (oFollower != oLeliana))
                bRefunded = TRUE;

            if ((sGiftTag == GEN_IM_GIFT_ALISTAIR_AMULET) && (oFollower != oAlistair))
                bRefunded = TRUE;

            if ((sGiftTag == GEN_IM_GIFT_DUNCAN_SHIELD) && (oFollower != oAlistair))
                bRefunded = TRUE;

            if ((sGiftTag == GEN_IM_GIFT_DALISH_GLOVES) && (oFollower != oZevran))
                bRefunded = TRUE;

            if ((sGiftTag == GEN_IM_GIFT_ANTIVAN_BOOTS) && (oFollower != oZevran))
                bRefunded = TRUE;

            int nSoundSet;
            if(nApprovalChange <= 0) nSoundSet = SS_GIFT_NEGATIVE;
            else if(nApprovalChange > 0 && nApprovalChange <= 3) nSoundSet = SS_GIFT_NEUTRAL;
            else if(nApprovalChange > 3 && nApprovalChange <= 8) nSoundSet = SS_GIFT_POSITIVE;
            else nSoundSet = SS_GIFT_ECSTATIC;

            if(GetTag(oFollower) == GEN_FL_DOG)
                PlaySound(oFollower, "glo_dog/dog/ss/ss_dog_bark_excited");

            if(!bRefunded)
            {
                int nFollower = Approval_GetFollowerIndex(oFollower);
                Approval_ChangeApproval(nFollower, nApprovalChange);
                PlaySoundSet(oFollower, nSoundSet);
                WR_DestroyObject(oItem);
            }
            else
                PlaySoundSet(oFollower, SS_BAD_IDEA);

            // ===================================================
            // END OF REFUND ITEM SECTION
            // ===================================================

            if (oFollower == oMorrigan)
            {
                if (sGiftTag == "gen_im_gift_grimoire")
                {
                    // Set Flags
                    WR_SetPlotFlag(PLT_GENPT_MORRIGAN_EVENTS, MORRIGAN_EVENT_ON, TRUE);
                    WR_SetPlotFlag(PLT_GENPT_MORRIGAN_EVENTS, MORRIGAN_EVENT_GIVEN_GRIMOIRE, TRUE);
                    // Talk to Morrigan
                    UT_Talk(oMorrigan, oPC);
                }

                if (sGiftTag == "gen_im_gift_flmgrimoire")
                {
                    // Set Flags
                    WR_SetPlotFlag(PLT_GENPT_MORRIGAN_EVENTS, MORRIGAN_EVENT_ON, TRUE);
                    WR_SetPlotFlag(PLT_GENPT_MORRIGAN_EVENTS, MORRIGAN_EVENT_GIVEN_REAL_GRIMOIRE, TRUE);
                    // Talk to Morrigan
                    UT_Talk(oMorrigan, oPC);
                }

                // Morrigan Given Golden Mirror
                if (sGiftTag == "gen_im_gift_mirror")
                {
                    WR_SetPlotFlag(PLT_GENPT_MORRIGAN_EVENTS, MORRIGAN_EVENT_ON, TRUE);
                    WR_SetPlotFlag(PLT_GENPT_MORRIGAN_EVENTS, MORRIGAN_EVENT_GIVEN_GOLDEN_MIRROR, TRUE);
                    UT_Talk(oMorrigan, oPC);
                }
            }

            if (oFollower == oLeliana)
            {
                if (sGiftTag == "gen_im_gift_nugg")
                {
                    WR_SetPlotFlag(PLT_GENPT_LELIANA_EVENTS, LELIANA_EVENT_ON, TRUE);
                    WR_SetPlotFlag(PLT_GENPT_LELIANA_EVENTS, LELIANA_EVENT_GIVEN_NUG, TRUE);
                    WR_SetPlotFlag(PLT_GENPT_LELIANA_MAIN, LELIANA_MIAN_LELIANA_HAS_NUG, TRUE);
                    UT_Talk(oLeliana, oPC);

                }

                if ((sGiftTag == "gen_im_gift_flower_andraste") &&
                !WR_GetPlotFlag(PLT_GENPT_LELIANA_MAIN, LELIANA_MAIN_HAVE_FLOWERS))
                {
                    WR_SetPlotFlag(PLT_GENPT_LELIANA_EVENTS, LELIANA_EVENT_ON, TRUE);
                    WR_SetPlotFlag(PLT_GENPT_LELIANA_EVENTS, LELIANA_EVENT_GIVEN_FLOWER, TRUE);
                    WR_SetPlotFlag(PLT_GENPT_LELIANA_MAIN, LELIANA_MAIN_HAVE_FLOWERS, TRUE);
                    UT_Talk(oLeliana, oPC);

                }
            }

            if (oFollower == oSten)
            {
                if (sGiftTag == "gen_im_gift_sword_sten")
                {
                    // Set Flags
                    WR_SetPlotFlag(PLT_GENPT_STEN_EVENTS, STEN_EVENTS_ON, TRUE);
                    WR_SetPlotFlag(PLT_GENPT_STEN_EVENTS, STEN_EVENTS_PC_GIVES_STEN_SWORD, TRUE);
                    UT_Talk(oSten, oSten);
                }
            }

            if (oFollower == oAlistair)
            {
                if (sGiftTag == GEN_IM_GIFT_ALISTAIR_AMULET)
                {
                    // Set Flags
                    WR_SetPlotFlag(PLT_GENPT_ALISTAIR_EVENTS, ALISTAIR_EVENT_ON, TRUE);
                    WR_SetPlotFlag(PLT_GENPT_ALISTAIR_EVENTS, ALISTAIR_EVENT_GIVEN_MOTHERS_AMULET, TRUE,TRUE);
                    // Talk to Alistair
                    UT_Talk(oAlistair, oPC);
                }
                if (sGiftTag == GEN_IM_GIFT_DUNCAN_SHIELD)
                {
                    // Set Flags
                    WR_SetPlotFlag(PLT_GENPT_ALISTAIR_EVENTS, ALISTAIR_EVENT_ON, TRUE);
                    WR_SetPlotFlag(PLT_GENPT_ALISTAIR_EVENTS, ALISTAIR_EVENT_GIVEN_DUNCANS_SHIELD, TRUE,TRUE);
                    // Talk to Alistair
                    UT_Talk(oAlistair, oPC);
                }
            }

            if (oFollower == oZevran)
            {
                if (sGiftTag == GEN_IM_GIFT_DALISH_GLOVES)
                {
                    // Set Flags
                    WR_SetPlotFlag(PLT_GENPT_ZEVRAN_EVENTS, ZEVRAN_EVENT_GIVEN_GLOVES, TRUE,TRUE);
                    // Talk to Zevran
                    UT_Talk(oZevran, oPC);
                }
                if (sGiftTag == GEN_IM_GIFT_ANTIVAN_BOOTS)
                {
                    // Set Flags
                    WR_SetPlotFlag(PLT_GENPT_ZEVRAN_EVENTS, ZEVRAN_EVENT_GIVEN_BOOTS, TRUE,TRUE);
                    // Talk to Zevran
                    UT_Talk(oZevran, oPC);
                }
            }
            Log_Trace(LOG_CHANNEL_SYSTEMS, GetCurrentScriptName(), "Module handle gift, follower: " + GetTag(oFollower) + ", item: " + sGiftTag);
            break;
        }

        case EVENT_TYPE_UNIQUE_POWER:
        {

            //------------------------------------------------------------------
            // EVENT_TYPE_UNIQUE_POWER
            //------------------------------------------------------------------
            // Sent by: Scripting
            // When:    A unique power for an item is used
            //------------------------------------------------------------------

            int         nAbility;
            string      sItemTag;
            object      oItem;
            object      oCaster;
            object      oTarget;

            //------------------------------------------------------------------

            nAbility = GetEventInteger(evEvent,0);
            oItem    = GetEventObject(evEvent, 0);
            oCaster  = GetEventObject(evEvent, 1);
            oTarget  = GetEventObject(evEvent, 2);
            sItemTag = GetTag(oItem);

            //------------------------------------------------------------------

            _PassEventToPlotHandler(sItemTag,evEvent);

            bEventHandled = TRUE;
            break;

        }


    }

    if (!bEventHandled)
        HandleEvent(evEvent, RESOURCE_SCRIPT_MODULE_CORE);

}

//------------------------------------------------------------------------------

void _PassEventToPlotHandler(string sItemTag, event evEvent)
{

    string      sPrefix = SubString(sItemTag,0,3);
    resource    rScript;


    // Filter by prefix, every item MUST belong to a plot
    if      ( sPrefix == "pre" ) rScript = RESOURCE_SCRIPT_PRE_ITEM_ACQUIRED;
    else if ( sPrefix == "bdc" ) rScript = RESOURCE_SCRIPT_BDC_ITEM_ACQUIRED;
    else if ( sPrefix == "bdn" ) rScript = RESOURCE_SCRIPT_BDN_ITEM_ACQUIRED;
    else if ( sPrefix == "orz" ) rScript = RESOURCE_SCRIPT_ORZ_ITEM_ACQUIRED;
    else if ( sPrefix == "cir" ) rScript = RESOURCE_SCRIPT_CIR_ITEM_ACQUIRED;
    else if ( sPrefix == "lot" ) rScript = RESOURCE_SCRIPT_LOT_ITEM_ACQUIRED;
    else if ( sPrefix == "den" ) rScript = RESOURCE_SCRIPT_DEN_ITEM_ACQUIRED;
    else if ( sPrefix == "arl" ) rScript = RESOURCE_SCRIPT_ARL_ITEM_ACQUIRED;
    else if ( sPrefix == "nrd" ) rScript = RESOURCE_SCRIPT_NRD_ITEM_ACQUIRED;
    //else if ( sPrefix == "ran" ) rScript = RESOURCE_SCRIPT_RAN_ITEM_ACQUIRED;
    else if ( sPrefix == "ntb" ) rScript = RESOURCE_SCRIPT_NTB_ITEM_ACQUIRED;
    else if ( sPrefix == "urn" ) rScript = RESOURCE_SCRIPT_URN_ITEM_ACQUIRED;
    else if ( sPrefix == "bhm" ) rScript = RESOURCE_SCRIPT_BHM_ITEM_ACQUIRED;
    else if ( sPrefix == "gen" ) rScript = RESOURCE_SCRIPT_GEN_ITEM_ACQUIRED;
    else if ( sPrefix == "lit" ) rScript = RESOURCE_SCRIPT_LIT_ITEM_ACQUIRED;
    else
    {
        Warning( "Unhandled prefix for EVENT_TYPE_CAMPAIGN_ITEM_ACQUIRED: " +
                 sItemTag +". Please see the owner of this plot." );
        return;
    }

    HandleEvent(evEvent, rScript);

}