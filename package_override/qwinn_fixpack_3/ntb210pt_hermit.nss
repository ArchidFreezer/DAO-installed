//::///////////////////////////////////////////////
//:: Plot Events
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Plot events for Hermit in the forest
*/
//:://////////////////////////////////////////////
//:: Created By: Cori
//:: Created On: Jan 24/07
//:://////////////////////////////////////////////

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "plot_h"
#include "campaign_h"

#include "plt_ntb210pt_hermit"
#include "plt_cod_bks_hermit_book"
#include "plt_ntb220pt_grand_oak"
#include "ntb_constants_h"
#include "plt_ntb000pt_plot_items"
#include "plt_gen00pt_backgrounds"
#include "plt_ntb000pt_main"
#include "plt_ntb220pt_danyla"
#include "plt_ntb000pt_talked_to"

#include "plt_qwinn"

int StartingConditional()
{
    event eParms = GetCurrentEvent();                // Contains all input parameters
    int nType = GetEventType(eParms);               // GET or SET call
    string strPlot = GetEventString(eParms, 0);         // Plot GUID
    int nFlag = GetEventInteger(eParms, 1);          // The bit flag # being affected
    object oParty = GetEventCreator(eParms);      // The owner of the plot table for this script
    object oConversationOwner = GetEventObject(eParms, 0); // Owner on the conversation, if any
    int nResult = FALSE; // used to return value for DEFINED GET events
    object oPC = GetHero();
    object oHermit = UT_GetNearestCreatureByTag(oPC,NTB_CR_HERMIT);
    // Qwinn changed
    // object oPelt = GetItemPossessedBy(oPC,GEN_IM_PELT_WEREWOLF);
    object oPelt = GetItemPossessedBy(oPC,"gen_im_pelt_ww_plot");
    object oHelmet = GetItemPossessedBy(oPC,GEN_IM_ARM_HEL_MED_ELV);
    object oBook = GetItemPossessedBy(oPC,NTB_IM_HERMIT_BOOK);
    object oBoots = GetItemPossessedBy(oPC,GEN_IM_ARM_BOT_LGT_DEY);
    object oRing = GetItemPossessedBy(oPC,GEN_IM_ACC_RNG_R11);
    object oCBook = GetItemPossessedBy(oPC,NTB_IM_CAMMEN_BOOK);
    object oSong = GetItemPossessedBy(oPC,NTB_IM_LANAYA_SONGBOOK);
    object oAmulet = GetItemPossessedBy(oPC,GEN_IM_ACC_AMU_HAL);
    object oBracer = GetItemPossessedBy(oPC,NTB_IM_IRONBARK_BRACER);
    object oPendant = GetItemPossessedBy(oPC,GEN_IM_ACC_AMU_ATH);
    object oScarf = GetItemPossessedBy(oPC,NTB_IM_DANYLA_SCARF);

    plot_GlobalPlotHandler(eParms); // any global plot operations, including debug info

    if(nType == EVENT_TYPE_SET_PLOT) // actions -> normal flags only
    {
        int nValue = GetEventInteger(eParms, 2);        // On SET call, the value about to be written (on a normal SET that should be '1', and on a 'clear' it should be '0')
        int nOldValue = GetEventInteger(eParms, 3);     // On SET call, the current flag value (can be either 1 or 0 regardless if it's a set or clear event)
        // IMPORTANT: The flag value on a SET event is set only AFTER this script finishes running!
        switch(nFlag)
        {
            case NTB_HERMIT_TRADE_SET_HERMIT_BOOK:
            {
                //reset the other trade variables
                WR_SetPlotFlag(PLT_NTB210PT_HERMIT, NTB_HERMIT_TRADE_SET_HERMIT_HEART, FALSE);
                WR_SetPlotFlag(PLT_NTB210PT_HERMIT, NTB_HERMIT_TRADE_SET_HERMIT_HELMET, FALSE);
                break;
            }
            case NTB_HERMIT_TRADE_SET_HERMIT_HEART:
            {
                //reset the other trade variables
                WR_SetPlotFlag(PLT_NTB210PT_HERMIT, NTB_HERMIT_TRADE_SET_HERMIT_BOOK, FALSE);
                WR_SetPlotFlag(PLT_NTB210PT_HERMIT, NTB_HERMIT_TRADE_SET_HERMIT_HELMET, FALSE);

                break;
            }
            case NTB_HERMIT_TRADE_SET_HERMIT_HELMET:
            {
                //reset the other trade variables
                WR_SetPlotFlag(PLT_NTB210PT_HERMIT, NTB_HERMIT_TRADE_SET_HERMIT_BOOK, FALSE);
                WR_SetPlotFlag(PLT_NTB210PT_HERMIT, NTB_HERMIT_TRADE_SET_HERMIT_HEART, FALSE);
                break;
            }

            case NTB_HERMIT_QUESTIONS_TURN_PC:
            {
                //----------------------------------------------------------------------
                //UN-SET: QUESTIONS_TURN_HEMRIT (HERMIT)
                //----------------------------------------------------------------------
                WR_SetPlotFlag(PLT_NTB210PT_HERMIT,NTB_HERMIT_QUESTIONS_TURN_HERMIT,FALSE);
                break;
            }
            case NTB_HERMIT_QUESTIONS_TURN_HERMIT:
            {
                //----------------------------------------------------------------------
                //UN-SET: QUESTIONS_TURN_PC (HERMIT)
                //----------------------------------------------------------------------
                WR_SetPlotFlag(PLT_NTB210PT_HERMIT,NTB_HERMIT_QUESTIONS_TURN_PC,FALSE);
                break;
            }
            case NTB_HERMIT_JUMPS_AWAY:
            {
                //----------------------------------------------------------------------
                //SET: PC_KNOWS_HERMIT_CAN_VANISH (Hermit)
                //ACTION: the hermit teleports and appears further away
                //shaking his fists angrils at the player and make rude noises. (cinematics)
                //----------------------------------------------------------------------
                //ApplyEffectVisualEffect(oHermit, oHermit,1012, EFFECT_DURATION_TYPE_INSTANT, 0.0);
                WR_SetPlotFlag(PLT_NTB210PT_HERMIT,NTB_HERMIT_PC_KNOWS_HERMIT_CAN_TELEPORT,TRUE,TRUE);
                break;
            }
            case NTB_HERMIT_QUESTIONS_COUNTER_ONE:
            {
                //----------------------------------------------------------------------
                //SET: QUESTIONS_TURN_PC (Hermit)
                //----------------------------------------------------------------------
                WR_SetPlotFlag(PLT_NTB210PT_HERMIT,NTB_HERMIT_QUESTIONS_TURN_PC,TRUE,TRUE);
                break;
            }
            case NTB_HERMIT_QUESTIONS_COUNTER_TWO:
            {
                //----------------------------------------------------------------------
                //SET: QUESTIONS_TURN_PC (Hermit)
                //----------------------------------------------------------------------
                WR_SetPlotFlag(PLT_NTB210PT_HERMIT,NTB_HERMIT_QUESTIONS_TURN_PC,TRUE,TRUE);
                break;
            }
            case NTB_HERMIT_QUESTIONS_COUNTER_THREE:
            {
                //----------------------------------------------------------------------
                //SET: QUESTIONS_TURN_PC (Hermit)
                //----------------------------------------------------------------------
                WR_SetPlotFlag(PLT_NTB210PT_HERMIT,NTB_HERMIT_QUESTIONS_TURN_PC,TRUE,TRUE);
                break;
            }
            case NTB_HERMIT_QUESTIONS_COUNTER_FOUR:
            {
                //----------------------------------------------------------------------
                //SET: QUESTIONS_TURN_PC (Hermit)
                //----------------------------------------------------------------------
                WR_SetPlotFlag(PLT_NTB210PT_HERMIT,NTB_HERMIT_QUESTIONS_TURN_PC,TRUE,TRUE);
                break;
            }
            case NTB_HERMIT_QUESTIONS_COUNTER_FIVE:
            {
                //----------------------------------------------------------------------
                //SET: QUESTIONS_TURN_PC (Hermit)
                //----------------------------------------------------------------------
                WR_SetPlotFlag(PLT_NTB210PT_HERMIT,NTB_HERMIT_QUESTIONS_TURN_PC,TRUE,TRUE);
                break;
            }
            case NTB_HERMIT_QUESTIONS_COUNTER_SIX:
            {
                //----------------------------------------------------------------------
                //SET: QUESTIONS_TURN_PC (Hermit)
                //----------------------------------------------------------------------
                WR_SetPlotFlag(PLT_NTB210PT_HERMIT,NTB_HERMIT_QUESTIONS_TURN_PC,TRUE,TRUE);
                break;
            }
            case NTB_HERMIT_TRADE_EXECUTE:
            {
                int nHBook = WR_GetPlotFlag(PLT_NTB210PT_HERMIT,NTB_HERMIT_TRADE_SET_HERMIT_BOOK,TRUE);
                int nHHelmet = WR_GetPlotFlag(PLT_NTB210PT_HERMIT,NTB_HERMIT_TRADE_SET_HERMIT_HELMET,TRUE);
                int nHHeart = WR_GetPlotFlag(PLT_NTB210PT_HERMIT,NTB_HERMIT_TRADE_SET_HERMIT_HEART,TRUE);

                int nPCPendant = WR_GetPlotFlag(PLT_NTB210PT_HERMIT,NTB_HERMIT_TRADE_SET_PC_ATHRA_PENDANT,TRUE);
                int nPCBook = WR_GetPlotFlag(PLT_NTB210PT_HERMIT,NTB_HERMIT_TRADE_SET_PC_CAMMEN_BOOK,TRUE);
                int nPCScarf = WR_GetPlotFlag(PLT_NTB210PT_HERMIT,NTB_HERMIT_TRADE_SET_PC_DANYLA_SCARF,TRUE);
                int nPCBoots = WR_GetPlotFlag(PLT_NTB210PT_HERMIT,NTB_HERMIT_TRADE_SET_PC_DEYGAN_BOOTS,TRUE);
                int nPCAmulet = WR_GetPlotFlag(PLT_NTB210PT_HERMIT,NTB_HERMIT_TRADE_SET_PC_HALLA_AMULET,TRUE);
                int nPCBracer = WR_GetPlotFlag(PLT_NTB210PT_HERMIT,NTB_HERMIT_TRADE_SET_PC_IRONBARK_BRACER,TRUE);
                int nPCRing = WR_GetPlotFlag(PLT_NTB210PT_HERMIT,NTB_HERMIT_TRADE_SET_PC_RUINS_RING,TRUE);
                int nPCSong = WR_GetPlotFlag(PLT_NTB210PT_HERMIT,NTB_HERMIT_TRADE_SET_PC_SONG_BOOK,TRUE);

                //----------------------------------------------------------------------
                //ACTION: execute the trade, using pre-set flags.
                // if you are trading for the book
                // set that the PC has the book and make it unavailable
                //----------------------------------------------------------------------
                if(nHBook == TRUE)
                {
                    WR_SetPlotFlag(PLT_NTB210PT_HERMIT,NTB_HERMIT_TRADE_SET_HERMIT_BOOK,FALSE);
                    WR_SetPlotFlag(PLT_NTB210PT_HERMIT,NTB_HERMIT_TRADE_PC_GOT_BOOK,TRUE,TRUE);
                    //create resource on PC
                    //add codex
                    WR_SetPlotFlag(PLT_COD_BKS_HERMIT_BOOK, COD_BKS_HERMIT_BOOK, TRUE, TRUE);
                }
                //----------------------------------------------------------------------
                // if you are trading for the helmet
                // set that the PC has the helmet and make it unavailable
                //----------------------------------------------------------------------
                else if(nHHelmet == TRUE)
                {
                    WR_SetPlotFlag(PLT_NTB210PT_HERMIT,NTB_HERMIT_TRADE_SET_HERMIT_HELMET,FALSE);
                    WR_SetPlotFlag(PLT_NTB210PT_HERMIT,NTB_HERMIT_TRADE_PC_GOT_HELMET,TRUE,TRUE);
                    //create resource on PC
                }
                //----------------------------------------------------------------------
                // if you are trading for the oak seed
                // set that the PC has the oak seed and make it unavailable
                //----------------------------------------------------------------------
                else if(nHHeart == TRUE)
                {
                    WR_SetPlotFlag(PLT_NTB210PT_HERMIT,NTB_HERMIT_TRADE_SET_HERMIT_HEART,FALSE);
                    WR_SetPlotFlag(PLT_NTB210PT_HERMIT,NTB_HERMIT_TRADE_PC_GOT_HEART,TRUE,TRUE);
                    //create resource on PC
                }
                //----------------------------------------------------------------------
                //CUTSCENE: Hermit runs over to the stump for a moment
                //and then runs back to the pc and exchanges items.
                //checks for the PC's item, then take it away
                // if you're giving the pendant
                //----------------------------------------------------------------------
                if(nPCPendant == TRUE)
                {
                    WR_SetPlotFlag(PLT_NTB210PT_HERMIT,NTB_HERMIT_TRADE_SET_PC_ATHRA_PENDANT,FALSE);
                    if(IsObjectValid(oPendant))
                    {
                        WR_DestroyObject(oPendant);
                    }
                }
                //----------------------------------------------------------------------
                //checks for the PC's item, then take it away
                // if you're giving Cammen's book
                //----------------------------------------------------------------------
                else if(nPCBook == TRUE)
                {
                    WR_SetPlotFlag(PLT_NTB210PT_HERMIT,NTB_HERMIT_TRADE_SET_PC_CAMMEN_BOOK,FALSE);
                    if(IsObjectValid(oCBook))
                    {
                        WR_DestroyObject(oCBook);
                    }
                }
                //----------------------------------------------------------------------
                //checks for the PC's item, then take it away
                // if you're giving Danyla's scarf
                //----------------------------------------------------------------------
                else if(nPCScarf == TRUE)
                {
                    // Qwinn:  Added check so completed quest doesn't get reopened with the flag set below.
                    // Just checking the flags that CAN be set while hermit can still be traded with
                    int nQuestClosed1 = WR_GetPlotFlag(PLT_NTB220PT_DANYLA,NTB_DANYLA_ATHRAS_ANGRY);
                    int nQuestClosed2 = WR_GetPlotFlag(PLT_NTB220PT_DANYLA,NTB_DANYLA_PC_TOLD_ATHRAS);
                    int nQuestClosed3 = WR_GetPlotFlag(PLT_NTB220PT_DANYLA,NTB_DANYLA_ATHRAS_LOST_HOPE_LEAVES);

                    WR_SetPlotFlag(PLT_NTB210PT_HERMIT,NTB_HERMIT_TRADE_SET_PC_DANYLA_SCARF,FALSE);
                    if(IsObjectValid(oScarf))
                    {
                        WR_DestroyObject(oScarf);
                        if ((!nQuestClosed1) && (!nQuestClosed2) && (!nQuestClosed3))
                        {
                           WR_SetPlotFlag(PLT_NTB220PT_DANYLA,NTB_DANYLA_SCARF_TRADED_TO_HERMIT,TRUE,TRUE);
                        }
                    }

                }
                //----------------------------------------------------------------------
                //checks for the PC's item, then take it away
                // if you're giving Deygan's boots
                //----------------------------------------------------------------------
                else if(nPCBoots == TRUE)
                {
                    WR_SetPlotFlag(PLT_NTB210PT_HERMIT,NTB_HERMIT_TRADE_SET_PC_DEYGAN_BOOTS,FALSE);
                    if(IsObjectValid(oBoots))
                    {
                        WR_DestroyObject(oBoots);
                    }
                }
                //----------------------------------------------------------------------
                //checks for the PC's item, then take it away
                // if you're giving the halla amulet
                //----------------------------------------------------------------------
                else if(nPCAmulet == TRUE)
                {
                    WR_SetPlotFlag(PLT_NTB210PT_HERMIT,NTB_HERMIT_TRADE_SET_PC_HALLA_AMULET,FALSE);
                    if(IsObjectValid(oAmulet))
                    {
                        WR_DestroyObject(oAmulet);
                    }
                }
                //----------------------------------------------------------------------
                //checks for the PC's item, then take it away
                // if you're giving the ironbark bracer
                //----------------------------------------------------------------------
                else if(nPCBracer == TRUE)
                {
                    WR_SetPlotFlag(PLT_NTB210PT_HERMIT,NTB_HERMIT_TRADE_SET_PC_IRONBARK_BRACER,FALSE);
                    if(IsObjectValid(oBracer))
                    {
                        WR_DestroyObject(oBracer);
                    }
                }
                //----------------------------------------------------------------------
                //checks for the PC's item, then take it away
                // if you're giving the ring from the ruins
                //----------------------------------------------------------------------
                else if(nPCRing == TRUE)
                {
                    WR_SetPlotFlag(PLT_NTB210PT_HERMIT,NTB_HERMIT_TRADE_SET_PC_RUINS_RING,FALSE);
                    if(IsObjectValid(oRing))
                    {
                        WR_DestroyObject(oRing);
                    }
                }
                //----------------------------------------------------------------------
                //checks for the PC's item, then take it away
                // if you're giving Lanaya's songbook
                //----------------------------------------------------------------------
                else if(nPCSong == TRUE)
                {
                    WR_SetPlotFlag(PLT_NTB210PT_HERMIT,NTB_HERMIT_TRADE_SET_PC_SONG_BOOK,FALSE);
                    if(IsObjectValid(oSong))
                    {
                        WR_DestroyObject(oSong);
                    }
                }
                break;
            }
            case NTB_HERMIT_TRADE_PC_GOT_HEART:
            {
                //Does the PC have the acorn?
                int nHeart = WR_GetPlotFlag(PLT_NTB000PT_PLOT_ITEMS,NTB_PLOT_ITEMS_PC_HAS_GRAND_OAK_HEART,TRUE);
                //Has the PC spoken to the grand oak before?
                int nTalkedToOak = WR_GetPlotFlag(PLT_NTB000PT_TALKED_TO, NTB_TALKED_TO_GRAND_OAK);

                //----------------------------------------------------------------------
                //ACTION: give oak seed to player
                //and remove from any other inventory (stump or hermit)
                //----------------------------------------------------------------------
                if(nHeart == FALSE)
                {
                    WR_SetPlotFlag(PLT_NTB000PT_PLOT_ITEMS,NTB_PLOT_ITEMS_PC_GETS_GRAND_OAK_HEART,TRUE,TRUE);

                    //journal depends if the player has met the Grand Oak or not
                    if (nTalkedToOak == TRUE)
                    {
                        WR_SetPlotFlag(PLT_NTB220PT_GRAND_OAK,NTB_GRAND_OAK_PC_ACQUIRED_HEART_FROM_HERMIT,TRUE,TRUE);
                    }
                    else
                    {
                        WR_SetPlotFlag(PLT_NTB220PT_GRAND_OAK, NTB_GRAND_OAK_PC_ACQUIRED_HEART_NOT_MET_TREE, TRUE, TRUE);
                    }

                }
                break;
            }
            case NTB_HERMIT_KILLED_BY_PC:
            {

                int nHeart = WR_GetPlotFlag(PLT_NTB000PT_PLOT_ITEMS,NTB_PLOT_ITEMS_PC_HAS_GRAND_OAK_HEART,TRUE);
                // Qwinn:  Added nHeart2
                int nHeart2 = WR_GetPlotFlag(PLT_NTB210PT_HERMIT, NTB_HERMIT_TRADE_PC_GOT_HEART);
                //Has the PC spoken to the grand oak before?
                int nTalkedToOak = WR_GetPlotFlag(PLT_NTB000PT_TALKED_TO, NTB_TALKED_TO_GRAND_OAK);
                //----------------------------------------------------------------------
                //CUTSCENE: player kills the hermit
                //ACTION: Hermit dies
                // if the PC doesn't have the seed, give it to them
                //----------------------------------------------------------------------
                if((nHeart == FALSE) && (nHeart2 == FALSE))
                {
                    WR_SetPlotFlag(PLT_NTB000PT_PLOT_ITEMS,NTB_PLOT_ITEMS_PC_GETS_GRAND_OAK_HEART,TRUE,TRUE);
                    //journal depends if the player has met the Grand Oak or not
                    if (nTalkedToOak == TRUE)
                    {
                        WR_SetPlotFlag(PLT_NTB220PT_GRAND_OAK,NTB_GRAND_OAK_PC_ACQUIRED_HEART_FROM_HERMIT,TRUE,TRUE);
                    }
                    else
                    {
                        WR_SetPlotFlag(PLT_NTB220PT_GRAND_OAK, NTB_GRAND_OAK_PC_ACQUIRED_HEART_NOT_MET_TREE, TRUE, TRUE);
                    }
                }

                //percentage complete plot tracking
                ACH_TrackPercentageComplete(ACH_FAKE_BLIGHT_3g);

                break;
            }
            case NTB_HERMIT_GIVES_HELMET_OR_BOOK:
            {
                int nHelmet = IsObjectValid(oHelmet);
                int nBook = IsObjectValid(oBook);
                //----------------------------------------------------------------------
                //ACTION: Hermit gives helmet or book
                // if the PC doesn't have the helmet
                //set that they get it
                //----------------------------------------------------------------------
                if(nHelmet == FALSE)
                {
                    WR_SetPlotFlag(PLT_NTB210PT_HERMIT,NTB_HERMIT_TRADE_PC_GOT_HELMET,TRUE,TRUE);
                }
                //----------------------------------------------------------------------
                // else if the PC doesn't have the book
                // set that they get it
                //----------------------------------------------------------------------
                else if(nBook == FALSE)
                {
                    //to be scripted
                    WR_SetPlotFlag(PLT_NTB210PT_HERMIT,NTB_HERMIT_TRADE_PC_GOT_BOOK,TRUE,TRUE);
                }
                break;
            }
            case NTB_HERMIT_TAKES_WEREWOLF_PELT_FROM_PC:
            {
                //----------------------------------------------------------------------
                // if the PC has a werewolf pelt
                // take it off the PC
                //----------------------------------------------------------------------
                if(IsObjectValid(oPelt))
                {
                    // WR_DestroyObject(oPelt);
                     // Qwinn: This was originally WR_DestroyObject, which would remove the whole stack of pelts
                    RemoveItem(oPelt, 1);
                }
                break;
            }
            case NTB_HERMIT_GIVES_WEREWOLF_CLOAK_TO_PC:
            {
                int nPelt = UT_CountItemInInventory(rNTB_IM_HERMIT_PELT);
                //----------------------------------------------------------------------
                //ACTION: give cloak to pc
                //This cloaks turns the party into werewolves
                //and allows them to bypass the barrier.
                //This cloak is only useable in the Brecilian Forest.
                //----------------------------------------------------------------------
                if(nPelt == FALSE)
                {
                    UT_AddItemToInventory(rNTB_IM_HERMIT_PELT);
                }
                WR_SetPlotFlag(PLT_NTB000PT_MAIN,NTB_MAIN_PC_HAS_WAY_THROUGH_FOREST,TRUE,TRUE);

                //percentage complete plot tracking
                ACH_TrackPercentageComplete(ACH_FAKE_BLIGHT_3f);

                break;
            }
            case NTB_HERMIT_GOES_HOSTILE:
            {
                //----------------------------------------------------------------------
                //ACTION: go hostile.
                //Also summons some demons to help in the fight.
                //----------------------------------------------------------------------
                ApplyEffectVisualEffect(oHermit, oHermit,1012, EFFECT_DURATION_TYPE_INSTANT, 0.0);
                SetPlot(oHermit, FALSE);
                UT_LocalJump(oHermit, NTB_WP_HERMIT_JUMP);
                UT_CombatStart(oHermit,oPC);
                UT_TeamAppears(NTB_TEAM_EAST_FOREST_HERMIT_DEMON);
                break;
            }
            case NTB_HERMIT_STUMP_LOOTED:
            {
                //----------------------------------------------------------------------
                //SET: EVENT_HERMIT_ROBBED (Hermit)
                //ACTION: player gets Heart (if not having it yet) or a golden ring.
                //The hermit will then init dialog
                //THE HERMIT WILL INITIATE HIS "STUMP ROBBED" DIALOGUE
                //----------------------------------------------------------------------
                WR_SetPlotFlag(PLT_NTB210PT_HERMIT,NTB_HERMIT_ROBBED_BY_PC,TRUE);
                //Does the player have the acorn?
                int nHeart = WR_GetPlotFlag(PLT_NTB000PT_PLOT_ITEMS,NTB_PLOT_ITEMS_PC_HAS_GRAND_OAK_HEART, TRUE);
                int nHeart2 = WR_GetPlotFlag(PLT_NTB220PT_GRAND_OAK, NTB_GRAND_OAK_PC_ACQUIRED_HEART_FROM_HERMIT);
                int nHeart3 = WR_GetPlotFlag(PLT_NTB220PT_GRAND_OAK, NTB_GRAND_OAK_PC_ACQUIRED_HEART_NOT_MET_TREE);
                int nHeart4 = WR_GetPlotFlag(PLT_NTB220PT_GRAND_OAK, NTB_GRAND_OAK_ACORN_STOLEN_FROM_TREE);
                int nHeart5 = WR_GetPlotFlag(PLT_NTB220PT_GRAND_OAK, NTB_GRAND_OAK_ACORN_STOLEN_NOT_MET_TREE);
                // Qwinn:  Added nHeart6
                int nHeart6 = WR_GetPlotFlag(PLT_NTB210PT_HERMIT, NTB_HERMIT_TRADE_PC_GOT_HEART);
                //has the player spoken to the Grand Oak before?
                int nTalkedToOak = WR_GetPlotFlag(PLT_NTB000PT_TALKED_TO, NTB_TALKED_TO_GRAND_OAK);
                if ((!nHeart) && (!nHeart2) && (!nHeart3) && (!nHeart4) && (!nHeart5) && (!nHeart6))
                {
                    //journal depends if the player has met the Grand Oak or not
                    if (nTalkedToOak == TRUE)
                    {
                        WR_SetPlotFlag(PLT_NTB220PT_GRAND_OAK, NTB_GRAND_OAK_ACORN_STOLEN_FROM_TREE, TRUE, TRUE);
                    }
                    else
                    {
                        WR_SetPlotFlag(PLT_NTB220PT_GRAND_OAK, NTB_GRAND_OAK_ACORN_STOLEN_NOT_MET_TREE, TRUE, TRUE);
                    }

                    WR_SetPlotFlag(PLT_NTB000PT_PLOT_ITEMS,NTB_PLOT_ITEMS_PC_GETS_GRAND_OAK_HEART,TRUE,TRUE);
                }
                else
                {
                    //----------------------------------------------------------------------
                    //or a golden ring. (to be scripted)
                    //----------------------------------------------------------------------
                    WR_SetPlotFlag(PLT_NTB210PT_HERMIT,NTB_HERMIT_PC_STEALS_RING_FROM_STUMP,TRUE,TRUE);
                }
                UT_Talk(oHermit,oPC);
                break;
            }
            case NTB_HERMIT_STUMP_POISONS_PC:
            {
                //----------------------------------------------------------------------
                //ACTION: THE PC GETS POISONED (to be scripted)
                //----------------------------------------------------------------------
                ApplyEffectVisualEffect(OBJECT_SELF,OBJECT_SELF,1099,EFFECT_DURATION_TYPE_TEMPORARY,0.0,0);
                break;
            }
            case NTB_HERMIT_LEAVES_PERMANENTLY:
            {
                //----------------------------------------------------------------------
                //ACTION: the Hermit will run off permanently
                //----------------------------------------------------------------------
                WR_SetObjectActive(oHermit,FALSE);
                break;
            }
        }
     }
     else // EVENT_TYPE_GET_PLOT -> defined conditions only
     {
        switch(nFlag)
        {
            case NTB_HERMIT_QUESTIONS_TURN_HERMIT_AND_COUNTER_SIX:
            {
                int nTurn = WR_GetPlotFlag(PLT_NTB210PT_HERMIT,NTB_HERMIT_QUESTIONS_TURN_HERMIT);
                int nQuestions = WR_GetPlotFlag(PLT_NTB210PT_HERMIT,NTB_HERMIT_QUESTIONS_COUNTER_SIX);
                //----------------------------------------------------------------------
                //IF IT IS THE HERMIT'S TURN
                //AND HE HAS ASKED ALL 6 QUESTIONS
                //----------------------------------------------------------------------
                if((nTurn == TRUE) && (nQuestions == TRUE))
                {
                    nResult = TRUE;
                }
                break;
            }
            case NTB_HERMIT_QUESTIONS_TURN_HERMIT_AND_COUNTER_NOT_YET_SIX:
            {
                int nTurn = WR_GetPlotFlag(PLT_NTB210PT_HERMIT,NTB_HERMIT_QUESTIONS_TURN_HERMIT);
                int nQuestions = WR_GetPlotFlag(PLT_NTB210PT_HERMIT,NTB_HERMIT_QUESTIONS_COUNTER_SIX);
                //----------------------------------------------------------------------
                //IF IT IS THE HERMIT'S TURN
                //AND HE HAS ASKED LESS THAN 6 QUESTIONS
                //----------------------------------------------------------------------
                if((nTurn == TRUE) && (nQuestions == FALSE))
                {
                    nResult = TRUE;
                }
                break;
            }
            case NTB_HERMIT_PC_MAGE_AND_KNOWS_HERMIT_CAN_TELEPORT:
            {
                int nMage = WR_GetPlotFlag(PLT_GEN00PT_BACKGROUNDS,GEN_BACK_CIRCLE);
                int nTeleport = WR_GetPlotFlag(PLT_NTB210PT_HERMIT,NTB_HERMIT_PC_KNOWS_HERMIT_CAN_TELEPORT);
                //----------------------------------------------------------------------
                // IF the pc is a mage
                // and the PC knows the hermit can teleport
                //----------------------------------------------------------------------
                if((nMage == TRUE) && (nTeleport == TRUE))
                {
                    nResult = TRUE;
                }
                break;
            }
            case NTB_HERMIT_TRADE_PC_NOT_GOT_HEART_OR_BOOK_OR_HELMET:
            {
                int nHeart = WR_GetPlotFlag(PLT_NTB000PT_PLOT_ITEMS,NTB_PLOT_ITEMS_PC_HAS_GRAND_OAK_HEART);
                int nHeart2 = WR_GetPlotFlag(PLT_NTB210PT_HERMIT, NTB_HERMIT_TRADE_PC_GOT_HEART);
                // Qwinn
                // int nHelmet = IsObjectValid(oHelmet);
                int nHelmet = WR_GetPlotFlag(PLT_NTB210PT_HERMIT,NTB_HERMIT_TRADE_PC_GOT_HELMET);
                // Qwinn
                // int nBook = IsObjectValid(oBook);
                int nBook = WR_GetPlotFlag(PLT_NTB210PT_HERMIT,NTB_HERMIT_TRADE_PC_GOT_BOOK);

                int nKilled = WR_GetPlotFlag(PLT_NTB220PT_GRAND_OAK,NTB_GRAND_OAK_KILLED);
                //----------------------------------------------------------------------
                // if the PC does not have the hermit's book
                // or helmet
                // or the grand oak seed
                // and the grand oak is still alive (for the acorn)
                //----------------------------------------------------------------------
                if(nBook == FALSE && nHelmet == FALSE && nHeart == FALSE && nHeart2 == FALSE && nKilled == FALSE)
                {
                    nResult = TRUE;
                }
               break;
            }
            case NTB_HERMIT_GRAND_OAK_MENTIONED_HEART_BUT_NOT_HERMIT:
            {
                int nOak = WR_GetPlotFlag(PLT_NTB220PT_GRAND_OAK,NTB_GRAND_OAK_MENTIONED_HEART);
                int nHermit = WR_GetPlotFlag(PLT_NTB210PT_HERMIT,NTB_HERMIT_MENTIONED_GRAND_OAK_HEART);
                //----------------------------------------------------------------------
                // if the Grand Oak mentioned her heart
                // and the Hermit hasn't spoken of the grand oak seed
                //----------------------------------------------------------------------
                if((nOak == TRUE) && (nHermit == FALSE))
                {
                    nResult = TRUE;
                }
                break;
            }
            case NTB_HERMIT_PC_KNOWS_TRADE_INTEREST_AND_HAS_CAMMEN_BOOK:
            {
                int nCBook = IsObjectValid(oCBook);
                int nTrade = WR_GetPlotFlag(PLT_NTB210PT_HERMIT,NTB_HERMIT_PC_KNOWS_TRADE_INTEREST);
                //----------------------------------------------------------------------
                // if the PC has Cammen's book
                // and knows about the hermit's willingness to trade
                //----------------------------------------------------------------------
                if((nCBook == TRUE) && (nTrade == TRUE))
                {
                    nResult = TRUE;
                }
                break;
            }
            case NTB_HERMIT_PC_KNOWS_TRADE_INTEREST_AND_HAS_SONG_BOOK:
            {
                int nSong = IsObjectValid(oSong);
                int nTrade = WR_GetPlotFlag(PLT_NTB210PT_HERMIT,NTB_HERMIT_PC_KNOWS_TRADE_INTEREST);
                //----------------------------------------------------------------------
                //APPEARS WHEN: pc has the book from Lanya's chest
                // and knows about the hermit's willingness to trade
                //----------------------------------------------------------------------
                if((nSong == TRUE) && (nTrade == TRUE))
                {
                    nResult = TRUE;
                }
                break;
            }
            case NTB_HERMIT_PC_KNOWS_TRADE_INTEREST_AND_HAS_HALLA_AMULET:
            {
                int nAmulet = IsObjectValid(oAmulet);
                int nTrade = WR_GetPlotFlag(PLT_NTB210PT_HERMIT,NTB_HERMIT_PC_KNOWS_TRADE_INTEREST);
                //----------------------------------------------------------------------
                //APPEARS WHEN: pc has the amulet made from the Halla's horn
                // and knows about the hermit's willingness to trade
                //----------------------------------------------------------------------
                if((nAmulet == TRUE) && (nTrade == TRUE))
                {
                    nResult = TRUE;
                }
                break;
            }
            case NTB_HERMIT_PC_KNOWS_TRADE_INTEREST_AND_HAS_IRONBARK_BRACER:
            {
                int nBracer = IsObjectValid(oBracer);
                int nTrade = WR_GetPlotFlag(PLT_NTB210PT_HERMIT,NTB_HERMIT_PC_KNOWS_TRADE_INTEREST);
                //----------------------------------------------------------------------
                //APPEARS WHEN: pc  has the ironnark bracer made by Varathron
                // and knows about the hermit's willingness to trade
                //----------------------------------------------------------------------
                if((nBracer == TRUE) && (nTrade == TRUE))
                {
                    nResult = TRUE;
                }
                break;
            }
            case NTB_HERMIT_PC_KNOWS_TRADE_INTEREST_AND_HAS_ATHRA_PENDANT:
            {
                int nPendant = IsObjectValid(oPendant);
                int nTrade = WR_GetPlotFlag(PLT_NTB210PT_HERMIT,NTB_HERMIT_PC_KNOWS_TRADE_INTEREST);
                //----------------------------------------------------------------------
                //APPEARS WHEN: pc has Athra's pendant
                // and knows about the hermit's willingness to trade
                //----------------------------------------------------------------------
                if((nPendant == TRUE) && (nTrade == TRUE))
                {
                    nResult = TRUE;
                }
                break;
            }
            case NTB_HERMIT_PC_KNOWS_TRADE_INTEREST_AND_HAS_DANYLA_SCARF:
            {
                int nScarf = WR_GetPlotFlag(PLT_NTB000PT_PLOT_ITEMS,NTB_PLOT_ITEMS_PC_HAS_DANYLA_SCARF);
                Log_Trace(LOG_CHANNEL_TEMP,"NTB210PT_HERMIT","Scarf Held: " + IntToString(nScarf));
                int nTrade = WR_GetPlotFlag(PLT_NTB210PT_HERMIT,NTB_HERMIT_PC_KNOWS_TRADE_INTEREST);
                Log_Trace(LOG_CHANNEL_TEMP,"NTB210PT_HERMIT","Trade Interest Known: " + IntToString(nTrade));
                //----------------------------------------------------------------------
                //APPEARS WHEN: pc has Danyla's scarf
                // and knows about the hermit's willingness to trade
                //----------------------------------------------------------------------
                if((nScarf == TRUE) && (nTrade == TRUE))
                {
                    nResult = TRUE;
                }
                break;
            }
            case NTB_HERMIT_PC_KNOWS_TRADE_INTEREST_AND_HAS_RUINS_RING:
            {
                int nRing = IsObjectValid(oRing);
                int nTrade = WR_GetPlotFlag(PLT_NTB210PT_HERMIT,NTB_HERMIT_PC_KNOWS_TRADE_INTEREST);
                //----------------------------------------------------------------------
                //APPEARS WHEN: pc has ring from the ruins
                // and knows about the hermit's willingness to trade
                //----------------------------------------------------------------------
                if((nRing == TRUE) && (nTrade == TRUE))
                {
                    nResult = TRUE;
                }
                break;
            }
            case NTB_HERMIT_PC_KNOWS_TRADE_INTEREST_AND_HAS_DEYGAN_BOOTS:
            {
                int nBoots = IsObjectValid(oBoots);
                int nTrade = WR_GetPlotFlag(PLT_NTB210PT_HERMIT,NTB_HERMIT_PC_KNOWS_TRADE_INTEREST);
                //----------------------------------------------------------------------
                //APPEARS WHEN: pc has Deygan's boots
                // and knows about the hermit's willingness to trade
                //----------------------------------------------------------------------
                if((nBoots == TRUE) && (nTrade == TRUE))
                {
                    nResult = TRUE;
                }
                break;
            }
            case NTB_HERMIT_TRADE_PC_NOT_GOT_HELMET_OR_BOOK:
            {
                // Qwinn
                // int nHelmet = IsObjectValid(oHelmet);
                int nHelmet = WR_GetPlotFlag(PLT_NTB210PT_HERMIT,NTB_HERMIT_TRADE_PC_GOT_HELMET);
                // Qwinn
                // int nBook = IsObjectValid(oBook);
                int nBook = WR_GetPlotFlag(PLT_NTB210PT_HERMIT,NTB_HERMIT_TRADE_PC_GOT_BOOK);
                //----------------------------------------------------------------------
                //APPEARS WHEN (NOT): TRADE_PC_GOT_BOOK (Hermit)
                //*and* WHEN (NOT): TRADE_PC_GOT_HELMET (Hermit)
                //----------------------------------------------------------------------
                if((nBook == FALSE) && (nHelmet == FALSE))
                {
                    nResult = TRUE;
                }
                break;
            }
            case NTB_HERMIT_TRADE_PC_NOT_GOT_HEART_OR_BOOK:
            {
                // Qwinn
                // int nBook = IsObjectValid(oBook);
                int nBook = WR_GetPlotFlag(PLT_NTB210PT_HERMIT,NTB_HERMIT_TRADE_PC_GOT_BOOK);
                // Qwinn
                // int nHeart = WR_GetPlotFlag(PLT_NTB000PT_PLOT_ITEMS,NTB_PLOT_ITEMS_PC_HAS_GRAND_OAK_HEART,TRUE);
                int nHeart = WR_GetPlotFlag(PLT_NTB210PT_HERMIT, NTB_HERMIT_TRADE_PC_GOT_HEART);
                int nKilled = WR_GetPlotFlag(PLT_NTB220PT_GRAND_OAK,NTB_GRAND_OAK_KILLED);
                //----------------------------------------------------------------------
                //APPEARS WHEN (NOT): TRADE_PC_GOT_BOOK (Hermit)
                //*and* WHEN (NOT): TRADE_PC_GOT_HEART (Hermit)
                //and tree must still be alive
                //----------------------------------------------------------------------
                if(nBook == FALSE && nHeart == FALSE && nKilled == FALSE)
                {
                    nResult = TRUE;
                }
                break;
            }
            case NTB_HERMIT_TRADE_PC_NOT_GOT_HEART_OR_HELMET:
            {
                // Qwinn
                // int nHeart = WR_GetPlotFlag(PLT_NTB000PT_PLOT_ITEMS,NTB_PLOT_ITEMS_PC_HAS_GRAND_OAK_HEART);
                int nHeart = WR_GetPlotFlag(PLT_NTB210PT_HERMIT, NTB_HERMIT_TRADE_PC_GOT_HEART);
                // Qwinn
                // int nHelmet = IsObjectValid(oHelmet);
                int nHelmet = WR_GetPlotFlag(PLT_NTB210PT_HERMIT,NTB_HERMIT_TRADE_PC_GOT_HELMET);
                int nKilled = WR_GetPlotFlag(PLT_NTB220PT_GRAND_OAK,NTB_GRAND_OAK_KILLED);
                //----------------------------------------------------------------------
                //APPEARS WHEN (NOT): TRADE_PC_GOT_HELMET (Hermit)
                //*and* WHEN (NOT): TRADE_PC_GOT_HEART (Hermit)
                // and tree must still be alive
                //----------------------------------------------------------------------
                if(nHeart == FALSE && nHelmet == FALSE && nKilled == FALSE)
                {
                    nResult = TRUE;
                }
                break;
            }
            case NTB_HERMIT_PC_KNOWS_ABOUT_HAS_WEREWOLF_PELT_AND_NOT_GIVEN_CLOAK:
            {
                int nWerewolf = WR_GetPlotFlag(PLT_NTB210PT_HERMIT,NTB_HERMIT_PC_KNOWS_ABOUT_WEREWOLF_PELT);
                int nCloak = WR_GetPlotFlag(PLT_NTB210PT_HERMIT,NTB_HERMIT_GIVES_WEREWOLF_CLOAK_TO_PC);
                int nPelt = IsObjectValid(oPelt);
                //----------------------------------------------------------------------
                //PC_KNOWS_ABOUT_WEREWOLF_SKIN (Hermit)*and*
                //APPEARS WHEN (NOT): EVENT_HERMIT_GIVE_WEREWOLF_CLOAK (Hermit) *and*
                //APPEARS WHEN: pc has a werewolf pelt
                //----------------------------------------------------------------------
                if((nWerewolf == TRUE) && (nPelt == TRUE) && (nCloak == FALSE))
                {
                    nResult = TRUE;
                }
                break;
            }
            case NTB_HERMIT_OAK_KILLED_NOT_AGREED_NOT_KNOWS_PELT_QUESTIONS_SIX:
            {
                int nKilled = WR_GetPlotFlag(PLT_NTB220PT_GRAND_OAK,NTB_GRAND_OAK_KILLED);
                int nAgreed = WR_GetPlotFlag(PLT_NTB210PT_HERMIT,NTB_HERMIT_PC_AGREES_TO_KILL_GRAND_OAK);
                int nWerewolf = WR_GetPlotFlag(PLT_NTB210PT_HERMIT,NTB_HERMIT_PC_KNOWS_ABOUT_WEREWOLF_PELT);
                int nQuestions = WR_GetPlotFlag(PLT_NTB210PT_HERMIT,NTB_HERMIT_QUESTIONS_COUNTER_SIX);
                //----------------------------------------------------------------------
                //APPEARS WHEN: EVENT_OAK_KILLED (Grand Oak - set on it's death) *and*
                //APPEARS WHEN (NOT): EVENT_PC_AGREE_TO_KILL_GRAND_OAK (Hermit) *and*
                //APPEARS WHEN (NOT): PC_KNOWS_ABOUT_WEREWOLF_SKIN (Hemrit)*and*
                //APPEARS WHEN: QUESTIONS_COUNTER_SIX (Hermit) (pc can ask no more question)
                //----------------------------------------------------------------------
                if((nKilled == TRUE)
                    && (nAgreed == FALSE)
                        && (nWerewolf == FALSE)
                            && (nQuestions == TRUE))
                {
                    nResult = TRUE;
                }
                break;
            }
            case NTB_HERMIT_OAK_KILLED_PC_UNAWARE_OF_CLOAK:
            {
                int nKilled = WR_GetPlotFlag(PLT_NTB220PT_GRAND_OAK,NTB_GRAND_OAK_KILLED);
                int nWerewolf = WR_GetPlotFlag(PLT_NTB210PT_HERMIT,NTB_HERMIT_PC_KNOWS_ABOUT_WEREWOLF_PELT);
                if (nKilled == TRUE && nWerewolf == FALSE)
                {
                    nResult = TRUE;
                }
                break;
            }
            case NTB_HERMIT_GRAND_OAK_KILLED_PC_AGREED_NOT_KNOWS_WEREWOLF_PELT:
            {
                int nKilled = WR_GetPlotFlag(PLT_NTB220PT_GRAND_OAK,NTB_GRAND_OAK_KILLED);
                int nAgreed = WR_GetPlotFlag(PLT_NTB210PT_HERMIT,NTB_HERMIT_PC_AGREES_TO_KILL_GRAND_OAK);
                int nWerewolf = WR_GetPlotFlag(PLT_NTB210PT_HERMIT,NTB_HERMIT_PC_KNOWS_ABOUT_WEREWOLF_PELT);
                //----------------------------------------------------------------------
                //APPEARS WHEN: EVENT_OAK_KILLED (Grand Oak - set on it's death) *and*
                //APPEARS WHEN: EVENT_PC_AGREE_TO_KILL_GRAND_OAK (Hermit) *and*
                //APPEARS WHEN (NOT): PC_KNOWS_ABOUT_WEREWOLF_SKIN (Hemrit)
                //----------------------------------------------------------------------
                if((nKilled == TRUE) && (nAgreed == TRUE) && (nWerewolf == FALSE))
                {
                    nResult = TRUE;
                }
                break;
            }
            case NTB_HERMIT_PC_HAS_FOUND_FOREST_ITEMS:
            {
                int nScarf = WR_GetPlotFlag(PLT_NTB000PT_PLOT_ITEMS,NTB_PLOT_ITEMS_PC_HAS_DANYLA_SCARF);
                int nBoots = IsObjectValid(oBoots);
                int nRing = IsObjectValid(oRing);
                //----------------------------------------------------------------------
                // if PC has scarf from danyla
                // or boots from Deygan
                // or Ring from ruins
                //----------------------------------------------------------------------
                if((nScarf == TRUE) || (nBoots == TRUE) || (nRing == TRUE))
                {
                    nResult = TRUE;
                }
                break;
            }
            case NTB_HERMIT_TRADE_PC_HAS_GOLD:
            {
                int nCoin = UT_MoneyCheck(oPC,BEC_MONEY_HERMIT_CHECK);
                //----------------------------------------------------------------------
                // if PC has any money
                //----------------------------------------------------------------------
                if(nCoin == TRUE)
                {
                    nResult = TRUE;
                }
                break;
            }

            case NTB_HERMIT_TRADE_PC_HAS_EITHER_BOOK:
            {
                int nBook = IsObjectValid(oCBook);
                int nSong = IsObjectValid(oSong);
                //----------------------------------------------------------------------
                // if PC has Cammen's book
                // or Lanaya's songbook
                //----------------------------------------------------------------------
                if((nSong == TRUE) || (nBook == TRUE))
                {
                    nResult = TRUE;
                }
                break;
            }
            case NTB_HERMIT_TRADE_PC_HAS_DALISH_CRAFT:
            {
                //halla horn amulet, ironbark bracer, dalish pendant
                int nAmulet = IsObjectValid(oAmulet);
                int nPendant = IsObjectValid(oPendant);
                int nBracer = IsObjectValid(oBracer);
                //----------------------------------------------------------------------
                // if PC has halla horn amulet
                // or ironbark bracer
                // or halla amulet
                //----------------------------------------------------------------------
                if((nPendant == TRUE) || (nAmulet == TRUE) || (nBracer == TRUE))
                {
                    nResult = TRUE;
                }
                break;
            }
            case NTB_HERMIT_PC_AGREES_TO_KILL_GRAND_OAK_AND_HERMIT_NOT_DEAD:
            {
                int nAgreement = WR_GetPlotFlag(PLT_NTB210PT_HERMIT,NTB_HERMIT_PC_AGREES_TO_KILL_GRAND_OAK);
                int nDeadHermit = WR_GetPlotFlag(PLT_NTB210PT_HERMIT,NTB_HERMIT_KILLED_BY_PC);
                //----------------------------------------------------------------------
                //if PC has agreed to kill the Grand Oak
                // and the Hermit is not dead
                //----------------------------------------------------------------------
                if((nAgreement == TRUE) && (nDeadHermit == FALSE))
                {
                    nResult = TRUE;
                }
                break;
            }
            case NTB_HERMIT_STUMP_LOOTED_OR_GRAND_OAK_KILLED:
            {
                int nLooted = WR_GetPlotFlag(PLT_NTB210PT_HERMIT,NTB_HERMIT_STUMP_LOOTED);
                int nGrandOakKilled = WR_GetPlotFlag(PLT_NTB220PT_GRAND_OAK,NTB_GRAND_OAK_KILLED);
                //----------------------------------------------------------------------
                // if the PC has looted the stump
                // or the Grand Oak has been killed
                //----------------------------------------------------------------------
                if((nLooted == TRUE) || (nGrandOakKilled == TRUE))
                {
                    Log_Trace(LOG_CHANNEL_TEMP,"ntb210pt_hermit.nss","CNM: Or statement working");
                    nResult = TRUE;
                }
                break;
            }

            case NTB_HERMIT_EVADES_PC:
            {
                //reset the trade variables - in case the PC leaves without making a trade
                WR_SetPlotFlag(PLT_NTB210PT_HERMIT,NTB_HERMIT_TRADE_SET_HERMIT_BOOK,FALSE);
                WR_SetPlotFlag(PLT_NTB210PT_HERMIT,NTB_HERMIT_TRADE_SET_HERMIT_HELMET,FALSE);
                WR_SetPlotFlag(PLT_NTB210PT_HERMIT,NTB_HERMIT_TRADE_SET_HERMIT_HEART,FALSE);
                break;
            }
        }
    }

    return nResult;
}