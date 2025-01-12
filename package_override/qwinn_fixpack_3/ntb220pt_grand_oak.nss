//::///////////////////////////////////////////////
//:: Plot Events
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Plot events for the Grand Oak in the forest
*/
//:://////////////////////////////////////////////
//:: Created By: Cori
//:: Created On: Jan 24/07
//:://////////////////////////////////////////////

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "plot_h"

#include "plt_ntb220pt_grand_oak"
#include "ntb_constants_h"
#include "plt_ntb000pt_plot_items"
#include "plt_ntb000pt_main"
#include "plt_ntb210pt_hermit"

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
    object oHeart = GetItemPossessedBy(oPC,NTB_IM_GRAND_OAK_HEART);
    object oOak = UT_GetNearestCreatureByTag(oPC,NTB_CR_GRAND_OAK);

    plot_GlobalPlotHandler(eParms); // any global plot operations, including debug info

    if(nType == EVENT_TYPE_SET_PLOT) // actions -> normal flags only
    {
        int nValue = GetEventInteger(eParms, 2);        // On SET call, the value about to be written (on a normal SET that should be '1', and on a 'clear' it should be '0')
        int nOldValue = GetEventInteger(eParms, 3);     // On SET call, the current flag value (can be either 1 or 0 regardless if it's a set or clear event)
        // IMPORTANT: The flag value on a SET event is set only AFTER this script finishes running!
        switch(nFlag)
        {
            case NTB_GRAND_OAK_PC_GOES_HOSTILE:
            {
                ////////////////////////////////////////////////////////////////////////
                //ACTION: go hostile
                ////////////////////////////////////////////////////////////////////////
                SetPlot(oOak, FALSE);
                UT_CombatStart(oOak,oPC);
                break;
            }
            case NTB_GRAND_OAK_GIVES_HEART_REWARD:
            {
                ////////////////////////////////////////////////////////////////////////
                //ACTION: take heart
                //ACTION: give the staff (plot manager)
                ////////////////////////////////////////////////////////////////////////
                if(IsObjectValid(oHeart))
                {
                    WR_DestroyObject(oHeart);
                }
                WR_SetPlotFlag(PLT_NTB000PT_MAIN,NTB_MAIN_PC_HAS_WAY_THROUGH_FOREST,TRUE,TRUE);
                break;
            }
            case NTB_GRAND_OAK_KILLED:
            {
                int nHermit = WR_GetPlotFlag(PLT_NTB210PT_HERMIT,NTB_HERMIT_PC_KNOWS_HERMIT_WANTS_GRAND_OAK_DEAD);
                int nAgree = WR_GetPlotFlag(PLT_NTB210PT_HERMIT,NTB_HERMIT_PC_AGREES_TO_KILL_GRAND_OAK);
                ////////////////////////////////////////////////////////////////////////
                //if the PC knows the hermit wants the grand oak dead
                //or the PC has agreed to kill her
                // set it in the hermit's plot
                ////////////////////////////////////////////////////////////////////////
                if((nHermit == TRUE) || (nAgree == TRUE))
                {
                    WR_SetPlotFlag(PLT_NTB210PT_HERMIT,NTB_HERMIT_PC_KILLED_GRAND_OAK,TRUE,TRUE);
                }

                //percentage complete plot tracking
                ACH_TrackPercentageComplete(ACH_FAKE_BLIGHT_3d);

                break;
            }
            case NTB_GRAND_OAK_HEART_PLOT_DONE:
            {
                //percentage complete plot tracking
                ACH_TrackPercentageComplete(ACH_FAKE_BLIGHT_3c);

                //if PC was on the hermit plot - close it
                int nHermitPlot = WR_GetPlotFlag(PLT_NTB210PT_HERMIT,NTB_HERMIT_PC_AGREES_TO_KILL_GRAND_OAK);
                if (nHermitPlot == TRUE)
                {
                    WR_SetPlotFlag(PLT_NTB210PT_HERMIT,NTB_HERMIT_PC_RETURNED_ACORN_TO_OAK, TRUE, TRUE);
                }

                break;
            }
        }
     }
     else // EVENT_TYPE_GET_PLOT -> defined conditions only
     {
        switch(nFlag)
        {
            case NTB_GRAND_OAK_MENTIONED_HEART_AND_KILLED:
            {
                int nMentioned = WR_GetPlotFlag(PLT_NTB220PT_GRAND_OAK,NTB_GRAND_OAK_MENTIONED_HEART);
                int nKilled = WR_GetPlotFlag(PLT_NTB220PT_GRAND_OAK,NTB_GRAND_OAK_KILLED);
                ////////////////////////////////////////////////////////////////////////
                //if the Oak mentioned her seed
                // and she was killed
                ////////////////////////////////////////////////////////////////////////
                if((nMentioned == TRUE) && (nKilled == TRUE))
                {
                    nResult = TRUE;
                }
                break;
            }
            case NTB_GRAND_OAK_MENTIONED_HEART_AND_ALIVE:
            {
                int nMentioned = WR_GetPlotFlag(PLT_NTB220PT_GRAND_OAK,NTB_GRAND_OAK_MENTIONED_HEART);
                int nKilled = WR_GetPlotFlag(PLT_NTB220PT_GRAND_OAK,NTB_GRAND_OAK_KILLED);
                int nHeart = WR_GetPlotFlag(PLT_NTB000PT_PLOT_ITEMS,NTB_PLOT_ITEMS_PC_HAS_GRAND_OAK_HEART);
                int nHeartTrade = WR_GetPlotFlag(PLT_NTB210PT_HERMIT,NTB_HERMIT_TRADE_PC_GOT_HEART);
                ////////////////////////////////////////////////////////////////////////
                //if the Oak mentioned her seed
                // and she is still alive
                // and player doesn't have the acorn yet
                ////////////////////////////////////////////////////////////////////////
                if(nMentioned == TRUE && nKilled == FALSE && nHeart == FALSE && nHeartTrade == FALSE)
                {
                    nResult = TRUE;
                }
                break;
            }
            case NTB_GRAND_OAK_MENTIONED_HEART_AND_PLOT_ACCEPTED:
            {
                int nMentioned = WR_GetPlotFlag(PLT_NTB220PT_GRAND_OAK,NTB_GRAND_OAK_MENTIONED_HEART);
                int nPlot = WR_GetPlotFlag(PLT_NTB220PT_GRAND_OAK,NTB_GRAND_OAK_HEART_PLOT_ACCEPTED);
                ////////////////////////////////////////////////////////////////////////
                //if the oak mentioned her seed
                // and the pc promised to find it
                ////////////////////////////////////////////////////////////////////////
                if((nMentioned == TRUE) && (nPlot == TRUE))
                {
                    nResult = TRUE;
                }
                break;
            }
            case NTB_GRAND_OAK_MENTIONED_HEART_AND_PLOT_NOT_ACCEPTED:
            {
                int nMentioned = WR_GetPlotFlag(PLT_NTB220PT_GRAND_OAK,NTB_GRAND_OAK_MENTIONED_HEART);
                int nPlot = WR_GetPlotFlag(PLT_NTB220PT_GRAND_OAK,NTB_GRAND_OAK_HEART_PLOT_ACCEPTED);
                ////////////////////////////////////////////////////////////////////////
                //if the oak mentioned her seed
                // and the PC didn't accept the plot
                ////////////////////////////////////////////////////////////////////////
                if((nMentioned == TRUE) && (nPlot == FALSE))
                {
                    nResult = TRUE;
                }
                break;
            }
            case NTB_GRAND_OAK_MENTIONED_HEART_AND_NOT_YET_POSSESSED:
            {
                int nMentioned = WR_GetPlotFlag(PLT_NTB220PT_GRAND_OAK,NTB_GRAND_OAK_MENTIONED_HEART);
                int nHeart = WR_GetPlotFlag(PLT_NTB000PT_PLOT_ITEMS,NTB_PLOT_ITEMS_PC_HAS_GRAND_OAK_HEART);
                ////////////////////////////////////////////////////////////////////////
                //if the grand oak mentioned her seed
                // and the PC doesn't have it yet
                ////////////////////////////////////////////////////////////////////////
                if((nMentioned == TRUE) && (nHeart == FALSE))
                {
                    nResult = TRUE;
                }
                break;
            }
        }
    }

    return nResult;
}