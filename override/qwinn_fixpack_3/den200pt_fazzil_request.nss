//:://////////////////////////////////////////////
//:: den200pt_fazzil_request
//:: Copyright (c) 2008 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Plot events
*/
//:://////////////////////////////////////////////
//:: Created By: Ferret
//:: Created On: July 7th, 2008
//:://////////////////////////////////////////////

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "plot_h"

#include "den_constants_h"

#include "plt_den200pt_fazzil_request"
#include "plt_den200pt_chanter"

int StartingConditional()
{
    event eParms = GetCurrentEvent();                       // Contains all input parameters
    int nType = GetEventType(eParms);                       // GET or SET call
    string strPlot = GetEventString(eParms, 0);             // Plot GUID
    int nFlag = GetEventInteger(eParms, 1);                 // The bit flag # being affected
    object oParty = GetEventCreator(eParms);                // The owner of the plot table for this script
    object oConversationOwner = GetEventObject(eParms, 0);  // Owner on the conversation, if any
    int nResult = FALSE;                                    // used to return value for DEFINED GET events
    object oPC = GetHero();
    object oTarg;

    plot_GlobalPlotHandler(eParms);                         // any global plot operations, including debug info

    if(nType == EVENT_TYPE_SET_PLOT)    // actions -> normal flags only
    {
        int nValue = GetEventInteger(eParms, 2);        // On SET call, the value about to be written (on a normal SET that should be '1', and on a 'clear' it should be '0')
        int nOldValue = GetEventInteger(eParms, 3);     // On SET call, the current flag value (can be either 1 or 0 regardless if it's a set or clear event)
        // IMPORTANT: The flag value on a SET event is set only AFTER this script finishes running!
        switch(nFlag)
        {

            case FAZZIL_ACCEPTED:
            {
                // See if all Chanter's board quests have been accepted
                WR_SetPlotFlag(PLT_DEN200PT_CHANTER, CHANTER_CHECK_ALL_QUESTS_ACCEPTED, TRUE, TRUE);
                //turn off the chanter board entry
                WR_SetPlotFlag(PLT_DEN200PT_FAZZIL_REQUEST, FAZZIL_CHANTER_BOARD, FALSE);
                break;
            }

            case FAZZIL_SEXTANT_RECOVERED:          // The sextant is recovered from the Slum Apartments
            {
                // Display one of two journal entries depending on whether you have the quest
                if ( WR_GetPlotFlag(PLT_DEN200PT_FAZZIL_REQUEST, FAZZIL_ACCEPTED) )
                    WR_SetPlotFlag(PLT_DEN200PT_FAZZIL_REQUEST, JOURNAL_SEXTANT_RECOVERED_WITH_QUEST, TRUE, TRUE);
                else
                {
                    WR_SetPlotFlag(PLT_DEN200PT_FAZZIL_REQUEST, FAZZIL_ACCEPTED, TRUE, TRUE);
                    WR_SetPlotFlag(PLT_DEN200PT_FAZZIL_REQUEST, JOURNAL_SEXTANT_RECOVERED_SANS_QUEST, TRUE, TRUE);
                }
                break;
            }

            case FAZZIL_QUEST_DONE:                 // Turning in the quest to the Chanter
            {
                // Remove the sextant from the PC's inventory
                UT_RemoveItemFromInventory(DEN_IM_FAZZIL_SEXTANT);

                //percentage complete plot tracking
                ACH_TrackPercentageComplete(ACH_FAKE_DENERIM_15);

                break;
            }


        }
     }
     else   // EVENT_TYPE_GET_PLOT -> defined conditions only
     {

        switch(nFlag)
        {


        }

    }

    plot_OutputDefinedFlag(eParms, nResult);

    return nResult;
}