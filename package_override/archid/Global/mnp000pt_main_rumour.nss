//==============================================================================
/*
    mnp000pt_main_rumour.nss

*/
//==============================================================================
//  Created By: Yaron
//  Created On: July 21st, 2006
//==============================================================================

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "plot_h"

#include "camp_constants_h"
#include "sys_ambient_h"

#include "plt_mnp000pt_main_rumour"
#include "plt_cod_mgc_enchantment"

// Merchant Scaling
#include "scalestorefix_h"

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
    object  oBodahn             =   UT_GetNearestCreatureByTag(oPC,CAMP_BODAHN);
    object  oBodahnStore        =   UT_GetNearestObjectByTag(oPC, STORE_CAMP_BODAHN);
    object  oSandal             =   UT_GetNearestCreatureByTag(oPC,CAMP_SANDAL);

    plot_GlobalPlotHandler(eParms); // any global plot operations, including debug info

    if(nType == EVENT_TYPE_SET_PLOT) // actions -> normal flags only
    {
        int nValue      =   GetEventInteger(eParms, 2);             // On SET call, the value about to be written (on a normal SET that should be '1', and on a 'clear' it should be '0')
        int nOldValue   =   GetEventInteger(eParms, 3);             // On SET call, the current flag value (can be either 1 or 0 regardless if it's a set or clear event)

        // IMPORTANT: The flag value on a SET event is set only AFTER this script finishes running!
        switch(nFlag)
        {
            case MAIN_RUMOUR_OPEN_STORE:
            {

                ScaleStoreEdited(oBodahnStore); // Merchant Scaling

                OpenStore(oBodahnStore);

                break;

            }

            case MAIN_RUMOUR_BODAHN_LEAVES_PERMANENTLY:
            {

                // ** Bodahn will not appear at the player camp after this global is set **
                WR_SetObjectActive(oBodahn,FALSE);

                WR_SetObjectActive(oSandal,FALSE);

                break;

            }

            case MAIN_RUMOUR_ROBBED_BY_PC:
            {

                // ACTION: fade to black,
                // give the player some money and some decent equipment rewards
                // and then fade back in

                break;

            }

            case MAIN_RUMOUR_BODAHN_GIVES_SILVER:
            {

                // ACTION: gives the player 100 silvers

                break;

            }

            case MAIN_RUMOUR_BODAHN_GIVES_LARGE_SILVER:
            {

                // ACTION: gives the player 200 silvers

                break;

            }

            case MAIN_RUMOUR_BODAHN_RESCUED:
            {

                object  oTrigger    =   UT_GetNearestObjectByTag(oPC, "lot100tr_talk_bodahn");

                if((IsInTrigger(oPC, oTrigger)) && (GetLocalInt(oTrigger, TRIGGER_DO_ONCE_A) == FALSE))
                {

                    UT_Talk(oBodahn, oPC);

                    //Only fire the trigger once.
                    WR_SetObjectActive(oTrigger, FALSE);

                }

                break;

            }

            case MAIN_RUMOUR_SANDAL_TALKED_TO:
            {

                // Close of the enchantment codex quest.
                WR_SetPlotFlag(PLT_COD_MGC_ENCHANTMENT, CAMP_SANDAL_TALKED_TO, TRUE, TRUE);

                break;

            }

            case MAIN_RUMOUR_CLEAN_UP_POST_ATTACK:
            {

                /*event   evClean =   Event(EVENT_TYPE_CUSTOM_EVENT_06);

                object  oArea   =   GetArea(oBodahn);

                DelayEvent(2.0f, oArea, evClean);*/

                Ambient_Start(oBodahn);

                Ambient_Start(oSandal);

                break;

            }

        }
     }
     else // EVENT_TYPE_GET_PLOT -> defined conditions only
     {

        switch(nFlag)
        {
            case MAIN_RUMOUR_BODAHN_OR_SANDAL_TALKED_AT_CAMP:
            {
                int nBodahn = WR_GetPlotFlag(PLT_MNP000PT_MAIN_RUMOUR,MAIN_RUMOUR_BODAHN_SECOND_TIME_IN_CAMP);
                int nSandal = WR_GetPlotFlag(PLT_MNP000PT_MAIN_RUMOUR,MAIN_RUMOUR_SANDAL_TALKED_TO);
                if((nBodahn == TRUE) || (nSandal == TRUE))
                {
                    nResult = TRUE;
                }
                break;
            }

        }

    }

    plot_OutputDefinedFlag(eParms, nResult);

    return nResult;
}