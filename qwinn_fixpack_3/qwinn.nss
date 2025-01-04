//::///////////////////////////////////////////////
//:: Plot Events Template
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
    New plot events for Qwinn Fixpack version 3.0
*/
//:://////////////////////////////////////////////
//:: Created By: Paul Escalona
//:: Created On: February 20, 2017
//:://////////////////////////////////////////////

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "plot_h"

#include "plt_qwinn"
#include "plt_arl000pt_contact_eamon"
#include "plt_arl100pt_oil_stores"
#include "plt_arl100pt_holy_amulet"
#include "plt_arl130pt_recruit_dwyn"
#include "plt_arl150pt_tavern_drinks"
#include "plt_arl100pt_siege"
#include "plt_arl100pt_siege_prep"
#include "plt_arl200pt_remove_demon"
#include "plt_arl150pt_loghain_spy"
#include "plt_bdn110pt_provings"
#include "plt_bdnpt_main"
#include "plt_bhm000pt_tranquility"
#include "plt_bhn000pt_main"
#include "plt_cir000pt_main"
#include "plt_clipt_archdemon"
#include "plt_clipt_main"
#include "plt_clipt_morrigan_ritual"
#include "plt_cod_cha_morrigan"
#include "plt_den200pt_crimson"
#include "plt_den300pt_generic"
#include "plt_denpt_alistair"
#include "plt_denpt_main"
#include "plt_denpt_talked_to"
#include "plt_denpt_slave_trade"
#include "plt_epipt_main"
#include "plt_gen00pt_class_race_gend"
#include "plt_gen00pt_backgrounds"
#include "plt_gen00pt_party"
#include "plt_gen00pt_proving"
#include "plt_gen00pt_skills"
#include "plt_genpt_app_alistair"
#include "plt_genpt_app_leliana"
#include "plt_genpt_app_morrigan"
#include "plt_genpt_app_zevran"
#include "plt_genpt_leliana_main"
#include "plt_genpt_morrigan_events"
#include "plt_genpt_morrigan_main"
#include "plt_genpt_oghren_events"
#include "plt_genpt_oghren_main"
#include "plt_genpt_sten_defined"
#include "plt_genpt_wynne_main"
#include "plt_mnp000pt_generic"
#include "plt_ntb000pt_main"
#include "plt_ntb210pt_hermit"
#include "plt_ntb220pt_grand_oak"
#include "plt_orzpt_main"
#include "plt_orzpt_defined"
#include "plt_orzpt_anvil"
#include "plt_orzpt_wfharrow_t1"
#include "plt_orzpt_wfharrow_t2"
#include "plt_orzpt_wfharrow_t3"
#include "plt_orzpt_wfbhelen_t3"
#include "plt_orzpt_wfharrow_da"
#include "plt_orz200pt_dagna"
#include "plt_orz200pt_filda"
#include "plt_orz300pt_nobhunter"
#include "plt_orz400pt_rogek"
#include "plt_orz550pt_kardol"
#include "plt_prept_talked_to"
#include "plt_urnpt_main"

#include "sys_ambient_h"


int StartingConditional()
{
    event eParms = GetCurrentEvent();                // Contains all input parameters
    int nType = GetEventType(eParms);               // GET or SET call
    string strPlot = GetEventString(eParms, 0);         // Plot GUID
    int nFlag = GetEventInteger(eParms, 1);          // The bit flag # being affected
    object oParty = GetEventCreator(eParms);      // The owner of the plot table for this script
    int nResult = FALSE; // used to return value for DEFINED GET events

    plot_GlobalPlotHandler(eParms); // any global plot operations, including debug info
    object oPC = GetHero();

    if(nType == EVENT_TYPE_SET_PLOT) // actions -> normal flags only
    {
        int nValue = GetEventInteger(eParms, 2);
            // On SET call, the value about to be written
            //(on a normal SET that should be '1', and on a 'clear' it should be '0')
        int nOldValue = GetEventInteger(eParms, 3);
            // On SET call, the current flag value (can be either 1 or 0 regardless if it's a set or clear event)
            // IMPORTANT: The flag value on a SET event is set only AFTER this script finishes running!
        switch(nFlag)
        {
            // A bandit fleeing a mage PC was causing killing the team to not register, potentially making
            // quest uncompletable.  Fix by having him drop from the team.
            case LOT_BANDITS_BANDIT_FLEES_MAGE:
            {
                object oBandit1 = UT_GetNearestObjectByTag(oPC, "lot100cr_bandit");
                SetTeamId(oBandit1, -1);
                break;
            }

            case ORZ_FOUND_RUCK_CHECK_QUEST_STATUS:
            {
                int bAcceptedQuest = WR_GetPlotFlag( PLT_ORZ200PT_FILDA, ORZ_FILDA___PLOT_01_ACCEPTED );


                object oRuck = UT_GetNearestCreatureByTag(oPC,"orz530cr_ruck");
                SetName(oRuck,"Ruck");
                // SetObjectInteractive(oRuck,FALSE);

                if (!bAcceptedQuest)
                   WR_SetPlotFlag( PLT_QWINN,ORZ_FOUND_RUCK_QUEST_INACTIVE,TRUE,TRUE);
                else
                   WR_SetPlotFlag( PLT_ORZ200PT_FILDA, ORZ_FILDA___PLOT_02_RUCK_FOUND,TRUE,TRUE );
                break;
            }

            case ORZ_KILLED_RUCK_CHECK_QUEST_STATUS:
            {
                int bAcceptedQuest = WR_GetPlotFlag( PLT_ORZ200PT_FILDA, ORZ_FILDA___PLOT_01_ACCEPTED );

                // These should only be set if you know who Ruck is when you kill him.  If you didn't know who
                // he was, you never found him, period.  That condition is checked in new creature script for
                // Ruck, orz530cr_ruck.nss - this case will never be called if you haven't "found" him.
                if (!bAcceptedQuest)
                   WR_SetPlotFlag( PLT_QWINN,ORZ_KILLED_RUCK_QUEST_INACTIVE,TRUE,TRUE);
                else
                   WR_SetPlotFlag( PLT_ORZ200PT_FILDA, ORZ_FILDA___PLOT_02_RUCK_KILLED,TRUE,TRUE );
                break;
            }

            case ORZ_GOT_FILDA_QUEST_RUCK_FOUND_OR_KILLED_UPDATE:
            {
                if (WR_GetPlotFlag(PLT_QWINN,ORZ_FOUND_RUCK_QUEST_INACTIVE))
                    WR_SetPlotFlag(PLT_ORZ200PT_FILDA, ORZ_FILDA___PLOT_02_RUCK_FOUND,TRUE,TRUE );
                if (WR_GetPlotFlag(PLT_QWINN,ORZ_KILLED_RUCK_QUEST_INACTIVE))
                    WR_SetPlotFlag(PLT_ORZ200PT_FILDA, ORZ_FILDA___PLOT_02_RUCK_KILLED,TRUE,TRUE );
                break;
            }

            case ARL_SIEGE_PREP_CLOSE_SUBQUESTS:
            {   int bOilSeen = WR_GetPlotFlag(PLT_ARL100PT_OIL_STORES, ARL_OIL_STORES_PC_SEEN_OIL);
                int bPerthToldOil = WR_GetPlotFlag(PLT_ARL100PT_OIL_STORES, ARL_OIL_STORES_PERTH_TOLD_ABOUT_OIL);
                int bPlayerKnowsHolyProtection = WR_GetPlotFlag(PLT_ARL100PT_HOLY_AMULET, ARL_HOLY_AMULET_PC_KNOWS_PERTH_WANTS_HOLY_PROT);
                int bPerthUsingAmulets = WR_GetPlotFlag(PLT_ARL100PT_HOLY_AMULET, ARL_HOLY_AMULET_PERTH_HAS_AMULETS);
                int bPerthDeniedAmulets = WR_GetPlotFlag(PLT_ARL100PT_HOLY_AMULET, ARL_HOLY_AMULET_PERTH_DENIED_HELP);
                int bRecruitDwynActive = WR_GetPlotFlag(PLT_ARL130PT_RECRUIT_DWYN, ARL_RECRUIT_DWYN_PC_HEARD_ABOUT_DWYN);
                int bDwynHelping = WR_GetPlotFlag(PLT_ARL130PT_RECRUIT_DWYN, ARL_RECRUIT_DWYN_DWYN_HELPING);
                int bDwynDead = WR_GetPlotFlag(PLT_ARL130PT_RECRUIT_DWYN, ARL_RECRUIT_DWYN_DWYN_IS_DEAD);
                int bDrinksActive = WR_GetPlotFlag(PLT_ARL150PT_TAVERN_DRINKS, ARL_TAVERN_DRINKS_PC_TOLD_THAT_MILITIA_PAYS_FOR_ALE);
                int bDrinksDone = WR_GetPlotFlag(PLT_ARL150PT_TAVERN_DRINKS, ARL_TAVERN_DRINKS_MILITIA_DRINKS_FREE);
                if ( bOilSeen && !bPerthToldOil )
                { WR_SetPlotFlag(PLT_ARL100PT_OIL_STORES, ARL_OIL_STORES_BATTLE_STARTED, TRUE, TRUE);
                }
                if ( bPlayerKnowsHolyProtection && (!bPerthUsingAmulets) && (!bPerthDeniedAmulets) )
                { WR_SetPlotFlag(PLT_ARL100PT_HOLY_AMULET, ARL_HOLY_AMULET_BATTLE_STARTED, TRUE, TRUE);
                }
                if ( bRecruitDwynActive &&  (!bDwynHelping) && (!bDwynDead) )
                { WR_SetPlotFlag(PLT_ARL130PT_RECRUIT_DWYN, ARL_RECRUIT_DWYN_FAILED, TRUE, TRUE);
                }
                if ( bDrinksActive && (!bDrinksDone) )
                { WR_SetPlotFlag(PLT_ARL150PT_TAVERN_DRINKS, ARL_TAVERN_DRINKS_FAILED, TRUE, TRUE);
                }
                break;
            }

            case DEN_NANCINE_GIVES_FIVE_SILVER:
            {
                RewardMoney ( 0, 5, 0 );
                break;
            }

            case DEN_NANCINE_GIVES_TWO_GOLD:
            {
                RewardMoney ( 0, 0, 2 );
                break;
            }

            case URN_INN_PC_AMBUSHED_CHECK_JOURNAL_STATE:
            {
                if( !WR_GetPlotFlag( PLT_URNPT_MAIN, WEYLON_DEAD ) )
                    WR_SetPlotFlag( PLT_URNPT_MAIN, PC_AMBUSHED_AT_PRINCESS, TRUE, TRUE );
                break;
            }

            case CLI_PC_KNOWS_ABOUT_DARK_RITUAL:
            {
                // Codex entry for offer
                WR_SetPlotFlag(PLT_COD_CHA_MORRIGAN, COD_CHA_MORRIGAN_OFFER, TRUE);
                break;
            }

            case PICK4_PC_PAYS_3_GOLD:
            {
                UT_MoneyTakeFromObject(oPC,0,0,3);
                break;
            }

            case DEN_TOLD_SORIS_TT_SHIANI:
            {   if (WR_GetPlotFlag(PLT_DEN300PT_GENERIC, DEN_ALIENAGE_GENERIC_SORIS_AGREE_TO_SEE_SHIANNI))
                    WR_SetPlotFlag(PLT_DEN300PT_GENERIC, DEN_ALIENAGE_GENERIC_SORIS_AGREE_TO_SEE_SHIANNI,FALSE,FALSE);
                break;
            }

            case BHM_SET_JOWAN_BETRAYED:
            {
                WR_SetPlotFlag(PLT_BHM000PT_TRANQUILITY,JOWAN_BETRAYED,TRUE,FALSE);
                break;
            }

            case PRE_RECRUIT_MORRIGAN_EARLY:
            {
                object oMorrigan = Party_GetFollowerByTag(GEN_FL_MORRIGAN);
                WR_SetPlotFlag(PLT_GEN00PT_PARTY,GEN_MORRIGAN_RECRUITED,TRUE,FALSE);
                WR_SetFollowerState(oMorrigan, FOLLOWER_STATE_UNAVAILABLE, FALSE);
                SetFollowerApprovalEnabled(oMorrigan, TRUE);
                SetFollowerApprovalDescription(oMorrigan, 371487);
                WR_SetPlotFlag(PLT_GENPT_APP_MORRIGAN, APP_MORRIGAN_NO_APPROVAL_NOTIFICATION, TRUE);
                WR_SetPlotFlag(PLT_PREPT_TALKED_TO,PRE_TT_MORRIGAN,TRUE,TRUE);
                break;
            }

            case ZEV_RECRUIT_ZEVRAN_EARLY:
            {
                object oZevran = Party_GetFollowerByTag(GEN_FL_ZEVRAN);
                WR_SetPlotFlag(PLT_GEN00PT_PARTY,GEN_ZEVRAN_RECRUITED,TRUE,FALSE);
                WR_SetFollowerState(oZevran, FOLLOWER_STATE_UNAVAILABLE, FALSE);
                SetFollowerApprovalEnabled(oZevran, TRUE);
                SetFollowerApprovalDescription(oZevran, 371487);
                WR_SetPlotFlag(PLT_GENPT_APP_ZEVRAN, APP_ZEVRAN_NO_APPROVAL_NOTIFICATION, TRUE);
                break;
            }

            case ZEV_DID_NOT_RECRUIT_ZEVRAN:
            {
                object oZevran = Party_GetFollowerByTag(GEN_FL_ZEVRAN);
                WR_SetPlotFlag(PLT_GEN00PT_PARTY,GEN_ZEVRAN_RECRUITED,FALSE,FALSE);
                WR_SetFollowerState(oZevran, FOLLOWER_STATE_INVALID, FALSE);
                break;
            }

            case BDN_SPARE_MANDAR:
            {
                WR_SetPlotFlag(PLT_BDN110PT_PROVINGS,BDN_PROVINGS_HONOR_FIGHT_TO_THE_DEATH,FALSE);
                object oMandar = UT_GetNearestCreatureByTag( oPC, "bdn110cr_mandar_dace" );
                UT_SetSurrenderFlag(oMandar,FALSE);
                WR_SetPlotFlag(PLT_GEN00PT_PROVING,PROVING__WIN,TRUE,TRUE);
                break;
            }

            case BDN_KILL_MANDAR:
            {
                object oMandar = UT_GetNearestCreatureByTag( oPC, "bdn110cr_mandar_dace" );
                UT_SetSurrenderFlag(oMandar,FALSE);
                WR_SetPlotFlag(PLT_BDN110PT_PROVINGS,BDN_PROVINGS_HONOR_FIGHT_TO_THE_DEATH,TRUE,TRUE);
//                UT_CombatStart(oMandar, oPC);
//                SetCurrentHealth(oMandar,1.0f);   Would do this if it worked, but doesn't seem to
                KillCreature(oMandar,oPC);
                break;
            }

            case BDN_MOVE_GORIM_AGAIN_VSYNC:
            {
                object oGorim = UT_GetNearestCreatureByTag(oPC, "bdn120cr_gorim");
                object oGorimWP = UT_GetNearestObjectByTag(oPC, "mp_bdn120cr_gorim_2");
                if (GetDistanceBetween(oGorim,oGorimWP) > 1.0f)
                   UT_QuickMoveObject( oGorim, "2", FALSE, TRUE, TRUE, TRUE );
                break;
            }

            case CLI_LOGHAIN_ANORA_DLG_DONE:
            {
                object oLoghain = UT_GetNearestCreatureByTag(oPC,"gen00fl_loghain");
                SetObjectInteractive(oLoghain,TRUE);
                object oRiordanDoor = UT_GetNearestObjectByTag( oLoghain,"genip_door_fer_lrg_riordan" );
                SetObjectInteractive(oRiordanDoor,TRUE);
                object oAnora = UT_GetNearestCreatureByTag(oPC,"den510cr_anora");
                SetLocalInt(oAnora, RUBBER_HOME_ENABLED, 0);
                object oExit = UT_GetNearestObjectByTag( oPC,"cli310wp_from_main_floor" );
                location lLoc = GetLocation(oExit);
                WR_AddCommand( oAnora,CommandMoveToLocation(lLoc, FALSE, TRUE), TRUE, FALSE );
                break;
            }

            case SHALE_ADD_GIFT_DIAMOND:
            {
                object oGarinStore = UT_GetNearestObjectByTag(oPC,"store_orz200cr_garin");
                UT_AddItemToInventory(R"gen_im_gift_dia.uti",1,oGarinStore);
                break;
            }

            case SHALE_ADD_GIFT_GARNET:
            {
                object oThedasStore = UT_GetNearestObjectByTag(oPC,"store_den230cr_proprietor");
                UT_AddItemToInventory(R"gem_im_gift_gar.uti",1,oThedasStore);
                break;
            }

            case BHN_MALLOL_DLG_RESET_PRAYERS:
            {
                object oMallol = UT_GetNearestObjectByTag(oPC,"bhn100cr_mallol");
                object oGuard1 = UT_GetNearestObjectByTag(oPC,"bhn100cr_praying_guard");
                object oGuard2 = UT_GetNearestObjectByTag(oPC,"bhn100cr_praying_guard2");
                UT_LocalJump(oMallol,"ap_bhn100cr_mallol_01");
                UT_LocalJump(oGuard1,"ap_bhn100cr_praying_guard_01");
                UT_LocalJump(oGuard2,"ap_bhn100cr_praying_guard2_01");
                Ambient_OverrideBehaviour(oMallol,32,-1.0,-1);
                Ambient_OverrideBehaviour(oGuard1,32,-1.0,-1);
                Ambient_OverrideBehaviour(oGuard2,32,-1.0,-1);
                break;
            }

            case QWINN_DEBUG_MAIN:
            {
                // object bAlistair = UT_GetNearestCreatureByTag(oPC,"GEN_FL_ALISTAIR");
                // AddAbility (bAlistair,150005);

                // WR_SetPlotFlag(PLT_DEN200PT_THIEF, COULDRY_QUEUE_UP_PLOT_GIVER, FALSE, FALSE);

                /*
                object oGrd = UT_GetNearestCreatureByTag(oPC,"den220cr_pick4_sen_grd_bow");
                SetTag(oGrd,"den220cr_pick4_sen_grd1");
                oGrd = UT_GetNearestCreatureByTag(oPC,"den220cr_pick4_sen_grd_fnky");
                SetTag(oGrd,"den220cr_pick4_sen_grd2");
                oGrd = UT_GetNearestCreatureByTag(oPC,"den220cr_pick4_sen_grd_fnky");
                SetTag(oGrd,"den220cr_pick4_sen_grd3");
                oGrd = UT_GetNearestCreatureByTag(oPC,"den220cr_pick4_sen_grd_fnky");
                SetTag(oGrd,"den220cr_pick4_sen_grd4");
                */

                // WR_SetPlotFlag(PLT_GEN00PT_PARTY, GEN_ALISTAIR_IN_CAMP, TRUE, TRUE);
                //UT_AddItemToInventory(R"gen_im_arm_bot_mas_chv.uti");
                //UT_AddItemToInventory(R"gen_im_arm_cht_mas_chv.uti");
                //UT_AddItemToInventory(R"gen_im_arm_glv_mas_chv.uti");

                // WR_SetPlotFlag(PLT_DENPT_ANORA, DEN_ANORA_PC_SECRET_BETRAYAL, TRUE);
                //WR_SetPlotFlag(PLT_GENPT_APP_ALISTAIR, APP_ALISTAIR_FRIENDLY_ELIGIBLE,TRUE,TRUE);
                //WR_SetPlotFlag(PLT_GENPT_APP_ALISTAIR, APP_ALISTAIR_INC_EXTREME,TRUE,TRUE);
                //WR_SetPlotFlag(PLT_GENPT_APP_ALISTAIR, APP_ALISTAIR_INC_EXTREME,TRUE,TRUE);
                //WR_SetPlotFlag(PLT_GENPT_APP_ALISTAIR, APP_ALISTAIR_INC_EXTREME,TRUE,TRUE);
                //WR_SetPlotFlag(PLT_GENPT_APP_ALISTAIR, APP_ALISTAIR_INC_EXTREME,TRUE,TRUE);

                // Qwinn:  The next 7 lines take you straight from city gates to archdemon
                // WR_SetPlotFlag(PLT_CLIPT_MORRIGAN_RITUAL, MORRIGAN_RITUAL_WITH_LOGHAIN, FALSE);
                // WR_SetPlotFlag(PLT_CLIPT_MORRIGAN_RITUAL, MORRIGAN_RITUAL_REFUSED, TRUE);

                //WR_SetPlotFlag(PLT_CLIPT_GENERAL_MARKET, CLIPT_GENERAL_MARKET_KILLED,TRUE,TRUE);
                //WR_SetPlotFlag(PLT_CLIPT_GENERAL_ALIENAGE, CLIPT_GENERAL_ALIENAGE_KILLED,TRUE,TRUE);
                //WR_SetPlotFlag(PLT_CLIPT_GENERIC_ACTIONS, CLI_ACTIONS_GENERAL_DEAD_ALIENAGE, TRUE);
                //WR_SetPlotFlag(PLT_CLIPT_GENERIC_ACTIONS, CLI_ACTIONS_GENERAL_DEAD_MARKET, TRUE);
                //UT_DoAreaTransition("cli220ar_fort_roof_1","cli220wp_from_second_floor");



                break;
            }

        }
     }
     else // EVENT_TYPE_GET_PLOT -> defined conditions only
     {
        switch(nFlag)
        {

            // Qwinn - New flag to keep Gilmore conversation from going to post battle state before battle is over
            case BHN_MAIN_BATTLE_IN_MAIN_HALL_ONGOING:
            {
                int nBattle = WR_GetPlotFlag(PLT_BHN000PT_MAIN,BHN_MAIN_BATTLE_BEGUN,TRUE);
                int nBattle2 = WR_GetPlotFlag(PLT_BHN000PT_MAIN,BHN_MAIN_BATTLE_IN_MAIN_HALL_COMPLETE,TRUE);
                if((nBattle == TRUE) && (nBattle2 == FALSE))
                    nResult = TRUE;
                break;
            }

            // Qwinn:  This is for her FRIENDLY reaction to other romances.  Before it was just a friendly
            // check which would trigger in a romance and was awful.  Also adding not cut off because it tends
            // to come up immediately after dumping her for someone else, where her claiming she's not jealous
            // when she just forced you to dump her with a jealous ultimatum is just as bad.
            case LELIANA_FRIENDLY_NO_ROMANCE_NOT_CUT_OFF:
            {
                int bFriendly  = WR_GetPlotFlag(PLT_GENPT_APP_LELIANA, APP_LELIANA_IS_FRIENDLY, TRUE);
                int bRomance   = WR_GetPlotFlag(PLT_GENPT_APP_LELIANA, APP_LELIANA_ROMANCE_ACTIVE, TRUE);
                int bCutOff    = WR_GetPlotFlag(PLT_GENPT_APP_LELIANA, APP_LELIANA_ROMANCE_CUT_OFF, TRUE);
                if (bFriendly && (!bRomance) && (!bCutOff))
                   nResult = TRUE;
                break;
            }


            case LELIANA_HOSTILE_OR_BROKE_UP_HARSHLY:
            {
                int bHostile = WR_GetPlotFlag(PLT_GENPT_APP_LELIANA, APP_LELIANA_IS_HOSTILE, TRUE);
                int bHarsh =  WR_GetPlotFlag(PLT_GENPT_LELIANA_MAIN, LELIANA_MAIN_BROKE_UP_HARSHLY, TRUE);
                if ( (bHostile == TRUE) || (bHarsh == TRUE)  )
                   nResult = TRUE;
                break;
            }

            case LELIANA_READY_TO_DECLARE_LOVE:
            {
                int bLove = WR_GetPlotFlag(PLT_GENPT_APP_LELIANA, APP_LELIANA_IS_IN_LOVE, TRUE);
                int bAtCamp = WR_GetPlotFlag(PLT_MNP000PT_GENERIC, MAIN_PLOT_GENERIC_PARTY_AT_CAMP, TRUE);
                if ( (bAtCamp == TRUE) && (bLove == TRUE) )
                   nResult = TRUE;
                break;
            }

            case LELIANA_MALE_AND_ROMANCE_ELIGIBLE:
            {
                int bMale = WR_GetPlotFlag(PLT_GEN00PT_CLASS_RACE_GEND, GEN_GENDER_MALE, TRUE);
                int bCutOff = WR_GetPlotFlag(PLT_GENPT_APP_LELIANA, APP_LELIANA_ROMANCE_CUT_OFF, TRUE);
                if ( bMale && (!bCutOff) )
                   nResult = TRUE;
                break;
            }

            // Qwinn: if the PC has heard Luthias mentioned but hasn't heard the tale yet
            case PRE_TT_ASH_WARRIORS_CAN_HEAR_LUTHIAS_TALE:
            {
                int nHeardTale = WR_GetPlotFlag(PLT_PREPT_TALKED_TO,PRE_TT_ASH_WARRIORS_ABOUT_LUTHIAS,TRUE);
                int nLuthiasMentioned = WR_GetPlotFlag(PLT_QWINN,PRE_TT_ASH_WARRIORS_LUTHIAS_MENTIONED,TRUE);
                if((nHeardTale == FALSE) && (nLuthiasMentioned == TRUE))
                   nResult = TRUE;
                break;
            }

            // Qwinn:  Next two case statements to prevent Hermit from restarting kill the tree quest after acorn has
            // been given to tree, which would put a permanent plot marker on the tree and an open quest that couldn't
            // be closed.
            // EDIT:  Added checks against quest-given flags to make sure quest never repeats at all
            case NTB_HERMIT_FOUND_BARRIER_NEED_WAY_THROUGH:
            {
                int bFoundForest = WR_GetPlotFlag(PLT_NTB000PT_MAIN, NTB_MAIN_PC_FAILED_TO_ENTER_HEART_OF_FOREST);
                int bWayThrough = WR_GetPlotFlag(PLT_NTB000PT_MAIN, NTB_MAIN_PC_HAS_WAY_THROUGH_FOREST);
                int bGaveQuestKillTree = WR_GetPlotFlag(PLT_NTB210PT_HERMIT, NTB_HERMIT_PC_KNOWS_HERMIT_WANTS_GRAND_OAK_DEAD);
                int bGaveQuestGetPelt = WR_GetPlotFlag(PLT_NTB210PT_HERMIT,NTB_HERMIT_PC_KNOWS_ABOUT_WEREWOLF_PELT);
                if (bFoundForest && (!bGaveQuestKillTree) && (!bGaveQuestGetPelt) && (!bWayThrough))
                {
                    nResult = TRUE;
                }
                break;
            }

            case NTB_HERMIT_NOT_FOUND_BARRIER_NEED_WAY_THROUGH:
            {
                int bFoundForest = WR_GetPlotFlag(PLT_NTB000PT_MAIN, NTB_MAIN_PC_FAILED_TO_ENTER_HEART_OF_FOREST);
                int bWayThrough = WR_GetPlotFlag(PLT_NTB000PT_MAIN, NTB_MAIN_PC_HAS_WAY_THROUGH_FOREST);
                int bGaveQuestKillTree = WR_GetPlotFlag(PLT_NTB210PT_HERMIT, NTB_HERMIT_PC_KNOWS_HERMIT_WANTS_GRAND_OAK_DEAD);
                int bGaveQuestGetPelt = WR_GetPlotFlag(PLT_NTB210PT_HERMIT,NTB_HERMIT_PC_KNOWS_ABOUT_WEREWOLF_PELT);

                if ((!bFoundForest) && (!bGaveQuestKillTree) && (!bGaveQuestGetPelt) && (!bWayThrough))
                {
                    nResult = TRUE;
                }
                break;
            }

            case NTB_HERMIT_PC_NEEDS_HEART_OAK_NOT_DEAD:
            {
                int nKilled = WR_GetPlotFlag(PLT_NTB220PT_GRAND_OAK,NTB_GRAND_OAK_KILLED);
                int nHeart = WR_GetPlotFlag(PLT_NTB210PT_HERMIT, NTB_HERMIT_TRADE_PC_GOT_HEART);

                if ((!nKilled) && (!nHeart))
                {
                    nResult = TRUE;
                }
                break;
            }

            // Qwinn:  Added the following 2 so as to not show the promise lines in Mardy's dialogue
            // if king has been chosen or "Agreed" option is available.
            case ORZ_NOBHUNTER_HARROW_PROMISED_NOT_AGREED_NO_KING:
            {
                int bPlotActive  = WR_GetPlotFlag( PLT_ORZ300PT_NOBHUNTER, ORZ_NOBHUNTER___PLOT_ACTIVE );
                int bPromised    = WR_GetPlotFlag( PLT_ORZ300PT_NOBHUNTER, ORZ_NOBHUNTER___PLOT_02C_HARROWMONT_PROMISED );
                int bAgreed      = WR_GetPlotFlag( PLT_ORZ300PT_NOBHUNTER, ORZ_NOBHUNTER___PLOT_02D_HARROWMONT_AGREED );
                int bKingCrowned = WR_GetPlotFlag( PLT_ORZPT_MAIN, ORZ_MAIN___PLOT_DONE);

                if (bPlotActive && bPromised && (!bAgreed) && (!bKingCrowned))
                   nResult = TRUE;

                break;
            }

            case ORZ_NOBHUNTER_BHELEN_PROMISED_NOT_AGREED_NO_KING:
            {
                int bPlotActive  = WR_GetPlotFlag( PLT_ORZ300PT_NOBHUNTER, ORZ_NOBHUNTER___PLOT_ACTIVE );
                int bPromised    = WR_GetPlotFlag( PLT_ORZ300PT_NOBHUNTER, ORZ_NOBHUNTER___PLOT_02A_BHELEN_PROMISED );
                int bAgreed      = WR_GetPlotFlag( PLT_ORZ300PT_NOBHUNTER, ORZ_NOBHUNTER___PLOT_02B_BHELEN_AGREED );
                int bKingCrowned = WR_GetPlotFlag( PLT_ORZPT_MAIN, ORZ_MAIN___PLOT_DONE);

                if (bPlotActive && bPromised && (!bAgreed) && (!bKingCrowned))
                   nResult = TRUE;

                break;
            }

            // For Godwin in Rogek's quest:  Added the following two defined flags so we don't just use
            // the GODWIN_DENIED flag, which was idiotic.
            case ORZ_ROGEK_PC_HAS_LYRIUM:
            {
                object oLyrium = GetItemPossessedBy(oPC,"orz400im_rogek_lyrium");
                int bLyriumSold = WR_GetPlotFlag( PLT_ORZ400PT_ROGEK , ORZ_ROGEK___PLOT_02_DELIVERY_MADE );
                int bLyriumDonated = WR_GetPlotFlag( PLT_ORZ400PT_ROGEK, ORZ_ROGEK_GODWIN_LYRIUM_DONATED );

                if (IsObjectValid(oLyrium) && (!bLyriumSold) && (!bLyriumDonated))
                   nResult = TRUE;
                break;
            }

            case ORZ_ROGEK_PC_HAS_LYRIUM_AND_DENIED:
            {
                int bHasLyrium  = WR_GetPlotFlag( PLT_QWINN, ORZ_ROGEK_PC_HAS_LYRIUM );
                int bDeniedGodwin = WR_GetPlotFlag( PLT_ORZ400PT_ROGEK, ORZ_ROGEK_GODWIN_DENIED_LYRIUM );

                if ( bHasLyrium && bDeniedGodwin )
                   nResult = TRUE;
                break;
            }

            // Qwinn:  Added this for oghren's Tapsters conversation.
            case ORZ_WORKING_FOR_HARROW_PUBLIC:
            {
                int bFirstTaskAccepted = WR_GetPlotFlag( PLT_ORZPT_WFHARROW_T1, ORZ_WFHT1___PLOT_01_ACCEPTED );
                int bFirstTaskFailed   = WR_GetPlotFlag( PLT_ORZPT_WFHARROW_T1, ORZ_WFHT1___PLOT_FAILED );

                if (bFirstTaskAccepted && !bFirstTaskFailed)
                    nResult = TRUE;

                break;
            }

            // Added for Corra conversation so she doesn't say you met Harrow if you didn't
            // Only if PC is openly working for Harrow (accepted second task)
            case ORZ_CORRA_PC_MET_HARROW_AND_RANDOM:
            {
                float fRandom = RandomFloat() * 100.0;
                int bMetHarrowOpenly = WR_GetPlotFlag( PLT_ORZPT_WFHARROW_T2,ORZ_WFHT2___PLOT_01_ACCEPTED );
                if((fRandom < 25.00f) && bMetHarrowOpenly)
                    nResult = TRUE;
                break;
            }

            //  Added to restore Trian Evidence at coronation
            case ORZ_HARROW_DA_PC_HAS_TRIAN_EVIDENCE_DWARF_NOBLE:
            {
                int bDwarfNoble  = WR_GetPlotFlag( PLT_GEN00PT_BACKGROUNDS, GEN_BACK_DWARF_NOBLE );
                int bKilledTrian = WR_GetPlotFlag( PLT_BDNPT_MAIN, BDN_MAIN_PC_PLOTTED_TO_KILL_TRIAN );
                int bHavePapers  = WR_GetPlotFlag( PLT_ORZPT_WFHARROW_DA, ORZ_WFHDA___PLOT_04_COMPLETED );

                if ( bHavePapers && bDwarfNoble && !bKilledTrian )
                    nResult = TRUE;

                break;
            }

            case ORZ_HARROW_DA_PC_HAS_TRIAN_EVIDENCE_NOT_DWARF_NOBLE:
            {
                int bDwarfNoble  = WR_GetPlotFlag( PLT_GEN00PT_BACKGROUNDS, GEN_BACK_DWARF_NOBLE );
                int bHavePapers  = WR_GetPlotFlag( PLT_ORZPT_WFHARROW_DA, ORZ_WFHDA___PLOT_04_COMPLETED );

                if ( bHavePapers && !bDwarfNoble )
                    nResult = TRUE;
                break;
            }

            case ORZ_OGHREN_THINKS_WORKING_FOR_HARROWMONT:
            {
                int bHarrowPublic = WR_GetPlotFlag( PLT_ORZPT_WFHARROW_T2, ORZ_WFHT2___PLOT_01_ACCEPTED );
                int bToldHarrow   = WR_GetPlotFlag( PLT_QWINN, ORZ_TOLD_OGHREN_WORKING_FOR_HARROW );
                int bToldBhelen   = WR_GetPlotFlag( PLT_QWINN, ORZ_TOLD_OGHREN_WORKING_FOR_BHELEN );
                int bHarrowSent   = WR_GetPlotFlag( PLT_ORZPT_WFHARROW_T3, ORZ_WFHT3___PLOT_01_ACCEPTED );
                int bBhelenSent   = WR_GetPlotFlag( PLT_ORZPT_WFBHELEN_T3, ORZ_WFBT3___PLOT_01_ACCEPTED );

                nResult = bHarrowPublic;
                if (bHarrowSent && (!bBhelenSent))
                    nResult = TRUE;
                if (bBhelenSent && (!bHarrowSent))
                    nResult = FALSE;
                if (bToldHarrow) nResult = TRUE;
                if (bToldBhelen) nResult = FALSE;
                break;
            }

            case ORZ_RUCK_FOUND_AND_NOT_KILLED:
            {
                int bFound  = WR_GetPlotFlag(PLT_ORZ200PT_FILDA, ORZ_FILDA___PLOT_02_RUCK_FOUND);
                int bKilled = WR_GetPlotFlag(PLT_ORZ200PT_FILDA, ORZ_FILDA___PLOT_02_RUCK_KILLED);
                if (bFound && !bKilled)
                   nResult = TRUE;
                break;
            }

            case ORZ_OGHREN_LEFT_RUCK_CAMP_STILL_IN_ORTAN:
            {
                int bInOrtan = WR_GetPlotFlag(PLT_ORZPT_DEFINED, ORZ_DEFINED_INSIDE_AREA_ORTAN_TAIG);
                int bLeftRuck = WR_GetPlotFlag(PLT_GENPT_OGHREN_EVENTS, OGHREN_EVENT_PARAGON_LEAVING_RUCKS_CAMP);
                int bReadBrankaJournal = WR_GetPlotFlag(PLT_GENPT_OGHREN_EVENTS, OGHREN_EVENT_PARAGON_BRANKA_JOURNAL);
                if (bInOrtan && bLeftRuck && !bReadBrankaJournal)
                   nResult = TRUE;
                break;
            }

            case ORZ_OGHREN_TALKED_TO_KARDOL_STILL_IN_DEAD_TRENCHES:
            {
                int bInTrenches = WR_GetPlotFlag(PLT_ORZPT_DEFINED, ORZ_DEFINED_INSIDE_AREA_DEAD_TRENCHES);
                int bTalkedToKardol = WR_GetPlotFlag(PLT_ORZ550PT_KARDOL, ORZ_KARDOL_SPOKEN_ONCE);
                int bFoundBranka = WR_GetPlotFlag(PLT_ORZPT_ANVIL, ORZ_ANVIL_PC_AGREES_TO_HELP_BRANKA_GET_ANVIL);
                if (bInTrenches && bTalkedToKardol && !bFoundBranka)
                   nResult = TRUE;
                break;
            }

            case ORZ_DAGNA_LEFT_AND_JANAR_KNOWS:
            {
               int bJanarKnows   = WR_GetPlotFlag( PLT_ORZ200PT_DAGNA, ORZ_DAGNA_JANAR_KNOWS );
               int bDagnaLeft    = WR_GetPlotFlag( PLT_ORZ200PT_DAGNA, ORZ_DAGNA_LEFT_ORZAMMAR_FOR_TOWER);
               if (bJanarKnows && bDagnaLeft)
                  nResult = TRUE;
               break;
            }

            case ARL_KNIGHTS_RETURNED_WITH_AMULETS:
            {
                int bPerthUsingAmulets = WR_GetPlotFlag(PLT_ARL100PT_HOLY_AMULET, ARL_HOLY_AMULET_PERTH_HAS_AMULETS);
                int bKnightsSentForAmulets = WR_GetPlotFlag(PLT_QWINN,ARL_KNIGHTS_SENT_FOR_AMULETS);
                if (bPerthUsingAmulets && !bKnightsSentForAmulets)
                   nResult = TRUE;
                break;
            }

            case ARL_KNIGHTS_RETURNED_WITH_OIL:
            {
                int bPerthUsingOil = WR_GetPlotFlag(PLT_ARL100PT_OIL_STORES, ARL_OIL_STORES_PERTH_USING_OIL);
                int bKnightsSentForOil = WR_GetPlotFlag(PLT_QWINN,ARL_KNIGHTS_SENT_FOR_OIL);
                if (bPerthUsingOil && !bKnightsSentForOil)
                   nResult = TRUE;
                break;
            }

            case ARL_SIEGE_STARTED_AND_NOT_FINISHED:
            {
                int bSiegeStarted = WR_GetPlotFlag(PLT_ARL100PT_SIEGE_PREP,ARL_SIEGE_PREP_SIEGE_BEGINS);
                int bSiegeFinished = WR_GetPlotFlag(PLT_ARL100PT_SIEGE,ARL_SIEGE_SIEGE_OVER);
                if (bSiegeStarted && !bSiegeFinished)
                   nResult = TRUE;
                break;
            }

            case ARL_REMOVE_DEMON_CIRCLE_SUGGESTED_AND_AVAILABLE:
            {   int bCircleSuggested = WR_GetPlotFlag(PLT_ARL200PT_REMOVE_DEMON, ARL_REMOVE_DEMON_CIRCLE_SUGGESTED);
                int bTemplarsInArmy = WR_GetPlotFlag(PLT_CIR000PT_MAIN, TEMPLARS_IN_ARMY);
                if (bCircleSuggested && !bTemplarsInArmy)
                   nResult = TRUE;
                break;
            }

            case ARL_LLOYD_DEAD:
            {   int bLloydKilledSiege = WR_GetPlotFlag(PLT_ARL100PT_SIEGE, ARL_SIEGE_LLOYD_DIED_IN_SIEGE);
                int bLloydKilled = WR_GetPlotFlag(PLT_ARL150PT_TAVERN_DRINKS, ARL_TAVERN_DRINKS_LLOYD_KILLED);
                if (bLloydKilledSiege || bLloydKilled)
                   nResult = TRUE;
                break;
            }

            case ARL_BEVIN_LOST_PC_OR_FOLLOWER_HAS_SWORD:
            {
               object oFollower, oSword;
               object [] oParty = GetPartyList();
               int nIndex, nSize = GetArraySize(oParty);
               for ( nIndex = 0; nIndex < nSize; ++nIndex )
               {   oFollower = oParty[ nIndex ];
                   oSword = GetItemPossessedBy(oFollower,"kaitlyn_sword");
                   if (IsObjectValid(oSword)) nResult = TRUE;
               }
               break;
            }

            case OGHREN_MAIN_PC_WINGMAN_AND_AT_THE_INN:
            {
               int nPcIsWingman = WR_GetPlotFlag(PLT_GENPT_OGHREN_MAIN,OGHREN_MAIN_PC_WINGMAN);
               string sAreaTag = GetTag(GetArea(oPC));
               if (nPcIsWingman && sAreaTag == "cir110ar_inn")
                  nResult = TRUE;
               break;
            }

            case DEN_PICK3_PC_HAS_10_SILVER:
            {
               nResult = UT_MoneyCheck(oPC,0,10,0);
               break;
            }

            case CONTROLLED_IS_FEMALE:
            {
               string sControlledTag = GetTag(GetMainControlled());
               if((sControlledTag == GEN_FL_MORRIGAN) ||
                  (sControlledTag == GEN_FL_LELIANA) ||
                  (sControlledTag == GEN_FL_WYNNE))
                  nResult = TRUE;
               if (GetMainControlled() == oPC)
                  nResult = WR_GetPlotFlag(PLT_GEN00PT_CLASS_RACE_GEND,GEN_GENDER_FEMALE);
               break;
            }

            case LITE_FITE_WIDOWS_PARTYCHECK:
            {
                if (WR_GetPlotFlag(PLT_GEN00PT_PARTY,GEN_OGHREN_IN_PARTY) ||
                    WR_GetPlotFlag(PLT_GEN00PT_PARTY,GEN_ALISTAIR_IN_PARTY) ||
                    WR_GetPlotFlag(PLT_GEN00PT_PARTY,GEN_LELIANA_IN_PARTY) ||
                    WR_GetPlotFlag(PLT_GEN00PT_PARTY,GEN_STEN_IN_PARTY) ||
                    WR_GetPlotFlag(PLT_GEN00PT_PARTY,GEN_ZEVRAN_IN_PARTY) ||
                    WR_GetPlotFlag(PLT_GEN00PT_PARTY,GEN_LOGHAIN_IN_PARTY) ||
                    WR_GetPlotFlag(PLT_GEN00PT_PARTY,GEN_MORRIGAN_IN_PARTY) ||
                    WR_GetPlotFlag(PLT_GEN00PT_PARTY,GEN_WYNNE_IN_PARTY))
                  nResult = TRUE;
                break;
            }

            case DEN_CRIMSON_QUEST_ACTIVE_OR_FAILED:
            {
                int bCondition1 = WR_GetPlotFlag(PLT_DEN200PT_CRIMSON, CRIMSON_QUEST_ACCEPTED);
                int bCondition2 = WR_GetPlotFlag(PLT_DEN200PT_CRIMSON, CRIMSON_QUEST_DONE);
                int bCondition3 = WR_GetPlotFlag(PLT_DEN200PT_CRIMSON, CRIMSON_QUEST_FAILED);
                if ((bCondition1 && !bCondition2) || bCondition3)
                   nResult = TRUE;

                break;
            }

            case MORRIGAN_HAVE_REAL_GRIMOIRE_AND_AT_CAMP:
            {
                int bEventReady = WR_GetPlotFlag(PLT_GENPT_MORRIGAN_EVENTS, MORRIGAN_EVENT_FLEMITH_PLOT_COMPLETED);
                int bAtCamp = WR_GetPlotFlag(PLT_MNP000PT_GENERIC, MAIN_PLOT_GENERIC_PARTY_AT_CAMP);
                // Qwinn - added the following checks in Hotfix v3.51.  Need to also add #include "plt_genpt_morrigan_main"
                int bFlemethAlive = WR_GetPlotFlag(PLT_GENPT_MORRIGAN_MAIN,MORRIGAN_MAIN_FLEMITH_ALIVE);
                int bFlemethFought = WR_GetPlotFlag(PLT_GENPT_MORRIGAN_MAIN,MORRIGAN_MAIN_FLEMITH_PLOT_COMPLETED);
                if (bEventReady && bAtCamp && (bFlemethAlive || bFlemethFought))
                   nResult = TRUE;
                break;
            }

            // Qwinn added
            case ARL_WYNNE_CAN_TALK_ABOUT_CONNOR:
            {
                int bConnorKnown = WR_GetPlotFlag(PLT_GENPT_WYNNE_MAIN,WYNNE_MAIN_PRESENT_WHEN_CONNOR_MET);
                int bInRedcliffe = WR_GetPlotFlag(PLT_GENPT_STEN_DEFINED,STEN_DEFINED_AT_REDCLIFFE);
                int bConnorPlotDone = WR_GetPlotFlag(PLT_ARL200PT_REMOVE_DEMON,ARL_REMOVE_DEMON_DEMON_DEALT_WITH);
                if (bConnorKnown && bInRedcliffe && !bConnorPlotDone)
                   nResult = TRUE;
                break;
            }

            case ALISTAIR_RECRUITED_AND_NOT_KING:
            {
                int bLandsmeetDone = WR_GetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_QUEST_DONE);
                int bAlistairRecruited = WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_ALISTAIR_RECRUITED);
                int bAlistairKing = WR_GetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_ALISTAIR_ON_THRONE);
                if (bLandsmeetDone && bAlistairRecruited && !bAlistairKing)
                   nResult = TRUE;
                break;
            }

            case ARL_EAMON_REVIVED_LANDSMEET_NOT_DONE:
            {
                int bEamonRevived = WR_GetPlotFlag(PLT_ARL000PT_CONTACT_EAMON, ARL_CONTACT_EAMON_EAMON_REVIVED);
                int bLandsmeetDone = WR_GetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_QUEST_DONE);

                if (bEamonRevived && !bLandsmeetDone)
                   nResult = TRUE;
                break;
            }

            case ALISTAIR_MAY_BE_OR_WILL_BE_KING:
            {
                int bMayBeKing = WR_GetPlotFlag(PLT_QWINN, ARL_EAMON_REVIVED_LANDSMEET_NOT_DONE);
                int bWillBeKing = WR_GetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_ALISTAIR_ON_THRONE);

                if (bMayBeKing || bWillBeKing)
                   nResult = TRUE;
                break;
            }

            case PICK4_PC_HAS_3_GOLD:
            {
                nResult = UT_MoneyCheck(oPC, 0, 0, 3);
                break;
            }

            case PICK4_PC_HAS_5_GOLD:
            {
                nResult = UT_MoneyCheck(oPC, 0, 0, 5);
                break;
            }

            case EPI_ELVEN_BANN:
            {
                if (WR_GetPlotFlag(PLT_EPIPT_MAIN, EPI_PC_BANN_ALIENAGE) ||
                    WR_GetPlotFlag(PLT_EPIPT_MAIN, EPI_SHIANNI_BANN_ALIENAGE) ||
                    WR_GetPlotFlag(PLT_EPIPT_MAIN, EPI_SORIS_BANN_ALIENAGE) ||
                    WR_GetPlotFlag(PLT_EPIPT_MAIN, EPI_SOMEONE_BANN_ALIENAGE))
                   nResult = TRUE;
                break;
            }

            case EPI_PC_GETTING_MARRIED:
            {
                int bAlistairMarry  = WR_GetPlotFlag(PLT_DENPT_ALISTAIR, DEN_ALISTAIR_MARRYING_PLAYER);
                int bAnoraMarry     = WR_GetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_PLAYER_IS_KING);
                int bAlistairKillingBlow = WR_GetPlotFlag(PLT_CLIPT_ARCHDEMON, CLIMAX_ARCHDEMON_ALISTAIR_KILLS_ARCHDEMON);

                if ((bAlistairMarry && !bAlistairKillingBlow) || bAnoraMarry)
                    nResult = TRUE;

                break;
            }

            case CLI_ALISTAIR_DID_RITUAL_AND_CHILD_KNOWN:  // In defined flag section.
            {
                int bAlistairRitual = WR_GetPlotFlag(PLT_CLIPT_MORRIGAN_RITUAL, MORRIGAN_RITUAL_WITH_ALISTAIR,FALSE);
                int bChildKnown = WR_GetPlotFlag(PLT_CLIPT_MORRIGAN_RITUAL, MORRIGAN_RITUAL_ALISTAIR_KNOWS_ABOUT_CHILD,FALSE);

                if (bAlistairRitual && bChildKnown)
                       nResult = TRUE;
                break;
            }

            case DEN_RESCUE_SPLIT_COMPANION_LIST:
            {
                int nPartyMembers   = 0;

                if (WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_MORRIGAN_IN_CAMP)) nPartyMembers++;
                if (WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_LELIANA_IN_CAMP)) nPartyMembers++;
                if (WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_ZEVRAN_IN_CAMP)) nPartyMembers++;
                if (WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_STEN_IN_CAMP)) nPartyMembers++;
                if (WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_DOG_IN_CAMP)) nPartyMembers++;
                if (WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_WYNNE_IN_CAMP)) nPartyMembers++;
                if (WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_OGHREN_IN_CAMP)) nPartyMembers++;
                if (WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_ALISTAIR_IN_CAMP)) nPartyMembers++;
                if (WR_GetPlotFlag(PLT_GEN00PT_PARTY, GEN_SHALE_IN_CAMP)) nPartyMembers++;

                if (nPartyMembers > 6)
                    nResult = TRUE;

                break;
            }

            case DEN_TT_CYRION_STILL_AT_COMPOUND:
            {
                int bTTCyrion = WR_GetPlotFlag(PLT_DENPT_TALKED_TO, DEN_TT_CYRION);
                int bAtCompound = SubString(GetTag(GetArea(oPC)), 0, 6) == "den360";

                if (bTTCyrion && bAtCompound)
                   nResult = TRUE;
                break;
            }

            case DEN_TT_VALENDRIAN_STILL_AT_COMPOUND:
            {
                int bTTValendrian = WR_GetPlotFlag(PLT_DENPT_TALKED_TO, DEN_TT_VALENDRIAN);
                int bAtCompound = SubString(GetTag(GetArea(oPC)), 0, 6) == "den360";

                if (bTTValendrian && bAtCompound)
                   nResult = TRUE;
                break;
            }

            case DEN_TT_SHIANI_SORIS_DOESNT_KNOW:
            {
                int bTTShianni = WR_GetPlotFlag(PLT_DENPT_TALKED_TO, DEN_TT_SHIANI);
                int bSorisKnows = WR_GetPlotFlag(PLT_QWINN, DEN_TOLD_SORIS_TT_SHIANI);

                if (bTTShianni && !bSorisKnows)
                   nResult = TRUE;
                break;
            }

            case DEN_LOST_ANORA_BETRAYED_ALI_NOT_HARDENED:
            {
                int bAnoraBetrayed = WR_GetPlotFlag(PLT_DENPT_MAIN,LANDSMEET_LOST_WITHOUT_ANORA_SUPPORT);
                int bAliHardened = WR_GetPlotFlag(PLT_GENPT_APP_ALISTAIR,APP_ALISTAIR_CHANGED);

                if (bAnoraBetrayed || !bAliHardened)
                   nResult = TRUE;
                break;
            }

            case ARL_BERWICK_IN_TAVERN:
            {
                int bVillageAbandoned = WR_GetPlotFlag(PLT_ARL100PT_SIEGE_PREP, ARL_SIEGE_PREP_VILLAGE_ABANDONED);
                int bBerwickHelping = WR_GetPlotFlag(PLT_ARL150PT_LOGHAIN_SPY, ARL_LOGHAIN_SPY_BERWICK_DEFENDS_VILLAGE);
                int bBerwickGone = WR_GetPlotFlag(PLT_ARL150PT_LOGHAIN_SPY, ARL_LOGHAIN_SPY_BERWICK_GONE);
                int bSiegeOver = WR_GetPlotFlag(PLT_ARL100PT_SIEGE, ARL_SIEGE_PLAYER_RETURNS_FROM_SIEGE);

                if (!(bVillageAbandoned || bBerwickGone || bSiegeOver || bBerwickHelping))
                   nResult = TRUE;

                break;
            }

            case ARL_INT_MED_OR_STEN_THREATENED_LLOYD:
            {
                int bIntMed = WR_GetPlotFlag(PLT_GEN00PT_SKILLS,GEN_INTIMIDATE_MED);
                int bStenThreatenedLloyd = WR_GetPlotFlag(PLT_QWINN,ARL_STEN_THREATENED_LLOYD);

                if (bIntMed || bStenThreatenedLloyd)
                   nResult = TRUE;
                break;
            }

            case QW_CHANTRY_RACE:
            {
                int bHuman = WR_GetPlotFlag(PLT_GEN00PT_CLASS_RACE_GEND,GEN_RACE_HUMAN);
                int bCityElf = WR_GetPlotFlag(PLT_GEN00PT_BACKGROUNDS,GEN_BACK_ELF_CITY);
                int bCircle = WR_GetPlotFlag(PLT_GEN00PT_BACKGROUNDS,GEN_BACK_CIRCLE);

                if (bHuman || bCityElf || bCircle)
                   nResult = TRUE;
                break;
            }

            case CLI_AFTER_RIORDAN_AND_RITUAL_NOT_KNOWN:
            {
               int bRiordanTalk = WR_GetPlotFlag(PLT_CLIPT_MAIN,CLI_MAIN_RIORDAN_GAVE_ARCHDEMON_INFO);
               int bRitualKnown = WR_GetPlotFlag(PLT_QWINN,CLI_RITUAL_MENTIONED);

               if(bRiordanTalk && !bRitualKnown)
                  nResult = TRUE;

               break;
            }

            case GEN_PARTY_SIZE_3_OR_4:
            {
               object [] arParty = GetPartyList(oPC);
               if(GetArraySize(arParty) >= 3)
                   nResult = TRUE;
               break;
            }


            case QWINN_DEBUG_DEFINED:
            {
                // nResult = WR_GetPlotFlag(PLT_GENPT_MORRIGAN_EVENTS, MORRIGAN_EVENT_FLEMITH_PLOT_COMPLETED);
                // object oTrig = UT_GetNearestObjectByTag(oPC,"den200tr_landry_turns_aroun");
                // if (IsObjectValid(oTrig))
                   nResult = TRUE;
                break;

            }

        }
    }

    return nResult;
}