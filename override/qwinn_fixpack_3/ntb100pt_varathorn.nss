//::///////////////////////////////////////////////
//:: Plot Events Template
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Plot events for Varathorn
*/
//:://////////////////////////////////////////////
//:: Created By: Cori
//:: Created On: Jan 22/07
//:://////////////////////////////////////////////

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "plot_h"

#include "sys_achievements_h"
#include "plt_gen00pt_generic_actions"
#include "plt_ntb220pt_danyla"
#include "plt_ntb200pt_deygan"
#include "plt_ntb100pt_cammen"
#include "plt_ntb000pt_main"

#include "plt_ntb100pt_varathorn"
#include "ntb_constants_h"
#include "plt_gen00pt_backgrounds"
#include "plt_ntb000pt_plot_items"

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
    object oIronbark = GetItemPossessedBy(oPC,NTB_IM_IRONBARK);
    object oAntlers = GetItemPossessedBy(oPC,NTB_IM_HALLA_ANTLERS);

    plot_GlobalPlotHandler(eParms); // any global plot operations, including debug info

    if(nType == EVENT_TYPE_SET_PLOT) // actions -> normal flags only
    {
        int nValue = GetEventInteger(eParms, 2);        // On SET call, the value about to be written (on a normal SET that should be '1', and on a 'clear' it should be '0')
        int nOldValue = GetEventInteger(eParms, 3);     // On SET call, the current flag value (can be either 1 or 0 regardless if it's a set or clear event)
        // IMPORTANT: The flag value on a SET event is set only AFTER this script finishes running!
        switch(nFlag)
        {
            case NTB_VARATHORN_GIVES_LONGBOW_REWARD:
            {
                // -----------------------------------------------------
                //ACTION: give longbow (in plot manager)
                //ACTION: take the ironbark item
                // -----------------------------------------------------
                if(IsObjectValid(oIronbark))
                {
                    WR_DestroyObject(oIronbark);
                }
                WR_SetPlotFlag(PLT_NTB100PT_VARATHORN,NTB_VARATHORN_IRONBARK_PLOT_DONE,TRUE,TRUE);
                break;
            }
            case NTB_VARATHORN_GIVES_BREASTPLATE_REWARD:
            {
                // -----------------------------------------------------
                //ACTION: give breastplate (in plot manager)
                //ACTION: take the ironbark item
                // -----------------------------------------------------
                if(IsObjectValid(oIronbark))
                {
                    WR_DestroyObject(oIronbark);
                }
                WR_SetPlotFlag(PLT_NTB100PT_VARATHORN,NTB_VARATHORN_IRONBARK_PLOT_DONE,TRUE,TRUE);
                break;
            }
            case NTB_VARATHORN_GIVES_JEWELRY_REWARD:
            {
                // -----------------------------------------------------
                //ACTION: give jewelry (in plot manager)
                //ACTION: take the ironbark item
                // -----------------------------------------------------
                if(IsObjectValid(oIronbark))
                {
                    WR_DestroyObject(oIronbark);
                }
                WR_SetPlotFlag(PLT_NTB100PT_VARATHORN,NTB_VARATHORN_IRONBARK_PLOT_DONE,TRUE,TRUE);
                break;
            }
            case NTB_VARATHORN_GIVES_BOTH_IRONBARK_REWARDS:
            {
                // -----------------------------------------------------
                //ACTION: give longbow (in plot manager)
                //ACTION: give breastplate (in plot manager)
                //ACTION: take the ironbark item
                // -----------------------------------------------------
                WR_SetPlotFlag(PLT_NTB100PT_VARATHORN,NTB_VARATHORN_GIVES_LONGBOW_REWARD,TRUE);
                WR_SetPlotFlag(PLT_NTB100PT_VARATHORN,NTB_VARATHORN_GIVES_BREASTPLATE_REWARD,TRUE);
                if(IsObjectValid(oIronbark))
                {
                    WR_DestroyObject(oIronbark);
                }
                WR_SetPlotFlag(PLT_NTB100PT_VARATHORN,NTB_VARATHORN_IRONBARK_PLOT_DONE,TRUE,TRUE);
                break;
            }
            case NTB_VARATHORN_TAKES_IRONBARK_WITHOUT_REWARD:
            {
                // -----------------------------------------------------
                //SET: PLOT_DONE (Ironbark)
                //ACTION: take ironbark item
                // -----------------------------------------------------
                WR_SetPlotFlag(PLT_NTB100PT_VARATHORN,NTB_VARATHORN_IRONBARK_PLOT_DONE,TRUE,TRUE);
                if(IsObjectValid(oIronbark))
                {
                    WR_DestroyObject(oIronbark);
                }
                break;
            }
            case NTB_VARATHORN_GIVES_MONETARY_REWARD:
            {
                // -----------------------------------------------------
                //ACTION: give 100 crowns (in plot manager)
                //ACTION: take ironbark item
                //SET: PLOT_DONE (Ironbark)
                // -----------------------------------------------------
                if(IsObjectValid(oIronbark))
                {
                    WR_DestroyObject(oIronbark);
                }
                WR_SetPlotFlag(PLT_NTB100PT_VARATHORN,NTB_VARATHORN_IRONBARK_PLOT_DONE,TRUE,TRUE);
                break;
            }
            case NTB_VARATHORN_GIVES_HALLA_AMULET_REWARD:
            {
                // -----------------------------------------------------
                //ACTION: give amulet
                //ACTION: destroy the antlers
                // -----------------------------------------------------
                if(IsObjectValid(oAntlers))
                {
                    WR_DestroyObject(oAntlers);
                }
                break;
            }
            case NTB_VARATHORN_IRONBARK_PLOT_DONE:
            {
                // -----------------------------------------------------
                // FAB 7/2: Adding achievement for NotB
                // -----------------------------------------------------
                int bCondition1 = WR_GetPlotFlag(PLT_NTB000PT_MAIN, NTB_MAIN_WEREWOLVES_PROMISED_ALLIANCE);
                int bCondition2 = WR_GetPlotFlag(PLT_NTB000PT_MAIN, NTB_MAIN_ELVES_PROMISED_ALLIANCE);
                if ( !bCondition1 && !bCondition2 ) break;

                int nCounter;
                if ( WR_GetPlotFlag(PLT_NTB100PT_CAMMEN, NTB_CAMMEN_COUPLE_IN_LOVE) ) nCounter++;
                if ( WR_GetPlotFlag(PLT_NTB200PT_DEYGAN, NTB_DEYGAN_PC_RETURNED_BODY) ) nCounter++;
                if ( WR_GetPlotFlag(PLT_NTB200PT_DEYGAN, NTB_DEYGAN_HEALED_BY_PC) ) nCounter++;
                if ( WR_GetPlotFlag(PLT_NTB200PT_DEYGAN, NTB_DEYGAN_RETURNED_ALIVE_WITH_PC) ) nCounter++;
                if ( WR_GetPlotFlag(PLT_NTB220PT_DANYLA, NTB_DANYLA_PC_TOLD_ATHRAS) ) nCounter++;

                if ( nCounter >= 1 ) Acv_Grant(30);
                // End achievement code

                //percentage complete plot tracking
                ACH_TrackPercentageComplete(ACH_FAKE_BRECILIAN_2a);

                break;
            }
            case NTB_VARATHORN_IRONBARK_PLOT_ACCEPTED:
            {
                //turn off plot giver
                object oVarathorn = UT_GetNearestCreatureByTag(oPC, NTB_CR_VARATHORN);
                SetPlotGiver(oVarathorn, FALSE);
                // Qwinn:  Added missing break; here as it would cause store to always open after accepting quest.
                break;
            }
            case NTB_VARATHORN_OPENS_STORE:
            {
                string sTag;
                if (GetLocalInt(GetModule(), COUNTER_MAIN_PLOTS_DONE) >= 3)
                {
                    sTag = "store_ntb100cr_varathorn_2";
                } else
                {
                    sTag = "store_ntb100cr_varathorn";
                }
                object oStore = GetObjectByTag(sTag);
                ScaleStoreItems(oStore);
                OpenStore(oStore);
                break;
            }

            case NTB_VARATHORN_IRONBARK_DONE_BUT_MAD:
            {
                //percentage complete plot tracking
                ACH_TrackPercentageComplete(ACH_FAKE_BRECILIAN_2a);

                break;
            }
        }
     }
     else // EVENT_TYPE_GET_PLOT -> defined conditions only
     {
        switch(nFlag)
        {
            case NTB_VARATHORN_PC_NOT_DALISH_AND_IRONBARK_PLOT_NOT_ACCEPTED:
            {
                int nPlot = WR_GetPlotFlag(PLT_NTB100PT_VARATHORN,NTB_VARATHORN_IRONBARK_PLOT_ACCEPTED);
                int nDalish = WR_GetPlotFlag(PLT_GEN00PT_BACKGROUNDS,GEN_BACK_ELF_DALISH);
                // -----------------------------------------------------
                // PC not dalish and ironbark plot not accepted
                // -----------------------------------------------------
                if((nDalish == FALSE) && (nPlot == FALSE))
                {
                    nResult = TRUE;
                }
                break;
            }
            case NTB_VARATHORN_PC_DALISH_AND_IRONBARK_PLOT_NOT_ACCEPTED:
            {
                int nPlot = WR_GetPlotFlag(PLT_NTB100PT_VARATHORN,NTB_VARATHORN_IRONBARK_PLOT_ACCEPTED);
                int nDalish = WR_GetPlotFlag(PLT_GEN00PT_BACKGROUNDS,GEN_BACK_ELF_DALISH);
                // -----------------------------------------------------
                // PC is dalish and ironbark plot accepted
                // -----------------------------------------------------
                if((nDalish == TRUE) && (nPlot == FALSE))
                {
                    nResult = TRUE;
                }
                break;
            }
            case NTB_VARATHORN_WILL_BARTER_WITH_PC_OR_IRONBARK_PLOT_DONE:
            {
                int nPlot = WR_GetPlotFlag(PLT_NTB100PT_VARATHORN,NTB_VARATHORN_IRONBARK_PLOT_DONE);
                int nBarter = WR_GetPlotFlag(PLT_NTB100PT_VARATHORN,NTB_VARATHORN_WILL_BARTER_WITH_PC);
                // -----------------------------------------------------
                // Varathorn willing to barter with PC or ironbark plot done
                // -----------------------------------------------------
                if((nBarter == TRUE) || (nPlot == TRUE))
                {
                    nResult = TRUE;
                }
                break;
            }
            case NTB_VARATHORN_PC_HAS_IRONBARK_AND_PLOT_ACCEPTED:
            {
                int nPlot = WR_GetPlotFlag(PLT_NTB100PT_VARATHORN,NTB_VARATHORN_IRONBARK_PLOT_ACCEPTED);
                int nBark = IsObjectValid(oIronbark);
                // -----------------------------------------------------
                // PC has accepted the ironbark plot and now has ironbark
                // -----------------------------------------------------
                if((nBark == TRUE) && (nPlot == TRUE))
                {
                    nResult = TRUE;
                }
                break;
            }
        }
    }

    return nResult;
}