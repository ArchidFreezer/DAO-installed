//==============================================================================
/*
    bpsk_rescue_knives_plot.nss
    This tracks the quest to rescue Ser Arbither Cora.
*/
//==============================================================================

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "plot_h"

#include "lot_constants_h"
#include "plt_lotpt_actions"
#include "plt_bpsk_rescue_knives"
#include "plt_bpsk_retake_manor"
#include "plt_bp_spiders_knives"

//------------------------------------------------------------------------------

int StartingConditional()
{
    event   eParms              =   GetCurrentEvent();              // Contains all input parameters

    int     nType               =   GetEventType(eParms);           // GET or SET call
    int     nFlag               =   GetEventInteger(eParms, 1);     // The bit flag # being affected
    int     nResult             =   FALSE;                          // used to return value for DEFINED GET events

    string  strPlot             =   GetEventString(eParms, 0);      // Plot GUID

    object  oParty              =   GetEventCreator(eParms);        // The owner of the plot table for this script
    object  oConversationOwner  =   GetEventObject(eParms, 0);      // Owner on the conversation, if any
    object  oPC                 =   GetHero();
    object  oKnives             =   GetObjectByTag("bpsk_knives");
    object  oCave               =   GetObjectByTag("bpsk_to_cave");

    plot_GlobalPlotHandler(eParms);                                 // any global plot operations, including debug info

    if(nType == EVENT_TYPE_SET_PLOT) // actions -> normal flags only
    {
        int nValue      =   GetEventInteger(eParms, 2);             // On SET call, the value about to be written (on a normal SET that should be '1', and on a 'clear' it should be '0')
        int nOldValue   =   GetEventInteger(eParms, 3);             // On SET call, the current flag value (can be either 1 or 0 regardless if it's a set or clear event)

        // IMPORTANT: The flag value on a SET event is set only AFTER this script finishes running!
        switch(nFlag)
        {
            case KNIVES_QUEST_ACCEPTED:
            {
                // Update parent plot also
                WR_SetPlotFlag(PLT_BP_SPIDERS_KNIVES,BPSK_QUEST_ACCEPTED,TRUE);
                // Check if Lothering has already been destroyed.
                if (WR_GetPlotFlag(PLT_LOTPT_ACTIONS, ACTION_LOTHERING_DESTROYED))
                {
//                    DisplayFloatyMessage(oPC,"Lothering gone - Knives.",FLOATY_MESSAGE,0xff0000,10.0);
                    WR_SetPlotFlag(PLT_BPSK_RESCUE_KNIVES,KNIVES_DARK_TIDE_ENDING,TRUE);
                    WR_SetPlotFlag(PLT_BPSK_RETAKE_MANOR,MANOR_DARK_TIDE_ENDING,TRUE);
                    WR_SetPlotFlag(PLT_BP_SPIDERS_KNIVES,BPSK_DARK_TIDE,TRUE);
                }else{
                    // Flag the cave
                    SetPlotGiver(oCave,TRUE);
                }
                // Remove entry from Job Board
                WR_SetPlotFlag(PLT_BPSK_RESCUE_KNIVES,KNIVES_CHANTER_BOARD,FALSE,FALSE);

                break;
            }

            case KNIVES_REWARD_GIVEN:
            {
                // Clear the plot flag and board entry
                SetPlotGiver(oCave,FALSE);
                WR_SetPlotFlag(PLT_BPSK_RESCUE_KNIVES,KNIVES_CHANTER_BOARD,FALSE,FALSE);

                break;
            }

            case KNIVES_REWARD_STOLEN:
            {
                // Clear the plot flags and board entries
                SetPlotGiver(oKnives,FALSE);
                SetPlotGiver(oCave,FALSE);
                WR_SetPlotFlag(PLT_BPSK_RESCUE_KNIVES,KNIVES_CHANTER_BOARD,FALSE,FALSE);
                WR_SetPlotFlag(PLT_BPSK_RETAKE_MANOR,MANOR_CHANTER_BOARD,FALSE,FALSE);

                break;
            }

        }
     }
     else // EVENT_TYPE_GET_PLOT -> defined conditions only
     {

        switch(nFlag)
        {


        }

    }

    plot_OutputDefinedFlag(eParms, nResult);

    return nResult;
}