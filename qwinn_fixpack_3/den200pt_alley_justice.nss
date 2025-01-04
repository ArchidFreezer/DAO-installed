//:://////////////////////////////////////////////
//:: den200pt_alley_justice
//:: Copyright (c) 2008 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Plot events
*/
//:://////////////////////////////////////////////
//:: Created By: Ferret
//:: Created On: May 23rd, 2008
//:://////////////////////////////////////////////

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "plot_h"

#include "campaign_h"

#include "plt_den200pt_chanter"
#include "plt_den200pt_alley_justice"

void LC_CHECK_ALLEYS()
{
    int nCounter;

    if ( WR_GetPlotFlag(PLT_DEN200PT_ALLEY_JUSTICE, ALLEY_CLEARED_1) ) nCounter++;
    if ( WR_GetPlotFlag(PLT_DEN200PT_ALLEY_JUSTICE, ALLEY_CLEARED_2) ) nCounter++;
    if ( WR_GetPlotFlag(PLT_DEN200PT_ALLEY_JUSTICE, ALLEY_CLEARED_3) ) nCounter++;

    if ( nCounter == 2 )
        WR_SetPlotFlag(PLT_DEN200PT_ALLEY_JUSTICE, ALLEY_ALL_BAD_GUYS_KILLED, TRUE, TRUE);
    // Qwinn fixed
    // else WR_SetPlotFlag(PLT_DEN200PT_ALLEY_JUSTICE, ALLEY_JOURNAL_SOME_CLEARED, TRUE, TRUE);
    else if (WR_GetPlotFlag(PLT_DEN200PT_ALLEY_JUSTICE, ALLEY_ACCEPTED))
        WR_SetPlotFlag(PLT_DEN200PT_ALLEY_JUSTICE, ALLEY_JOURNAL_SOME_CLEARED, TRUE, TRUE);

}

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

    plot_GlobalPlotHandler(eParms); // any global plot operations, including debug info

    if(nType == EVENT_TYPE_SET_PLOT) // actions -> normal flags only
    {
        int nValue = GetEventInteger(eParms, 2);        // On SET call, the value about to be written (on a normal SET that should be '1', and on a 'clear' it should be '0')
        int nOldValue = GetEventInteger(eParms, 3);     // On SET call, the current flag value (can be either 1 or 0 regardless if it's a set or clear event)
        // IMPORTANT: The flag value on a SET event is set only AFTER this script finishes running!
        switch(nFlag)
        {

            case ALLEY_ACCEPTED:                    // DEN200_CHANTER_DENERIM
                                                    // Quest accepted from the board - make map pins visible
            {
                object oTarg = GetObjectByTag(WML_LC_DEN_ALLEY_1);
                WR_SetWorldMapLocationStatus(oTarg, WM_LOCATION_ACTIVE);

                oTarg = GetObjectByTag(WML_LC_DEN_ALLEY_2);
                WR_SetWorldMapLocationStatus(oTarg, WM_LOCATION_ACTIVE);

                oTarg = GetObjectByTag(WML_LC_DEN_ALLEY_3);
                WR_SetWorldMapLocationStatus(oTarg, WM_LOCATION_ACTIVE);

                // See if all Chanter's board quests have been accepted
                WR_SetPlotFlag(PLT_DEN200PT_CHANTER, CHANTER_CHECK_ALL_QUESTS_ACCEPTED, TRUE, TRUE);

                // Remove the post from the board.
                WR_SetPlotFlag(PLT_DEN200PT_ALLEY_JUSTICE, ALLEY_CHANTER_BOARD, FALSE, TRUE);
            }
            break;

            case ALLEY_CLEARED_1:                   // Check if all of the Alleys have been cleared
            {
                LC_CHECK_ALLEYS();
            }
            break;

            case ALLEY_CLEARED_2:                   // Check if all of the Alleys have been cleared
            {
                LC_CHECK_ALLEYS();
            }
            break;

            case ALLEY_CLEARED_3:                   // Check if all of the Alleys have been cleared
            {
                LC_CHECK_ALLEYS();
            }
            break;

            case ALLEY_QUEST_DONE:                  // DEN200_CHANTER_DENERIM
                                                    // Once the quest is done, kill the map notes
            {
                //Keep alleys open as there are other light content quests there now
                /*
                object oTarg = GetObjectByTag(WML_LC_DEN_ALLEY_1);
                WR_SetWorldMapLocationStatus(oTarg, WM_LOCATION_INACTIVE);

                oTarg = GetObjectByTag(WML_LC_DEN_ALLEY_2);
                WR_SetWorldMapLocationStatus(oTarg, WM_LOCATION_INACTIVE);

                oTarg = GetObjectByTag(WML_LC_DEN_ALLEY_3);
                WR_SetWorldMapLocationStatus(oTarg, WM_LOCATION_INACTIVE);
                */

                //percentage complete plot tracking
                ACH_TrackPercentageComplete(ACH_FAKE_DENERIM_9);
            }
            break;


        }
     }
     else // EVENT_TYPE_GET_PLOT -> defined conditions only
     {

        switch(nFlag)
        {

            /*
            case CHANTER_HAS_QUESTS_TO_TURN_IN:     // DEN200_CHANTER_DENERIM
                                                    // Checks to see if any of the Chanter's board quests
                                                    // are pending a reward.
            {
                // pre-setting to true and breaking out if it is so
                nResult = TRUE;

                // Alley Justice bad guys cleared AND the quest hasn't been turned in already
                if ( WR_GetPlotFlag(PLT_DEN200PT_ALLEY_JUSTICE, ALLEY_ALL_BAD_GUYS_KILLED) &&
                        !WR_GetPlotFlag(PLT_DEN200PT_ALLEY_JUSTICE, ALLEY_QUEST_DONE))
                    break;

                // Fazzil's sextant has been found AND the quest hasn't been turned in already
                if ( WR_GetPlotFlag(PLT_DEN200PT_FAZZIL_REQUEST, FAZZIL_SEXTANT_RECOVERED) &&
                        !WR_GetPlotFlag(PLT_DEN200PT_FAZZIL_REQUEST, FAZZIL_QUEST_DONE))
                    break;

                // Rexel has been found AND the quest hasn't been turned in already
                if ( WR_GetPlotFlag(PLT_DEN200PT_MIA, MIA_REXEL_FOUND) &&
                        !WR_GetPlotFlag(PLT_DEN200PT_MIA, MIA_QUEST_DONE))
                    break;

                //  return FALSE if all conditinals failed.
                nResult = FALSE;
                break;
            }

            case CHANTER_BOARD_QUESTS_ALL_DONE:     // DEN200_CHANTER_DENERIM
                                                    // Checks to see if all of the Chanter's board quests are
                                                    // complete.
            {
                // Check to see if each board quest hasn't been complete. If it hasn't break.
                if ( !WR_GetPlotFlag(PLT_DEN200PT_ALLEY_JUSTICE, ALLEY_QUEST_DONE) )
                    break;
                if ( !WR_GetPlotFlag(PLT_DEN200PT_FAZZIL_REQUEST, FAZZIL_QUEST_DONE) )
                    break;
                if ( !WR_GetPlotFlag(PLT_DEN200PT_MIA, MIA_QUEST_DONE) )
                    break;

                // Since you've done all the quests, the result is TRUE
                nResult = TRUE;
                break;
            }
            */


        }

    }

    plot_OutputDefinedFlag(eParms, nResult);

    return nResult;
}