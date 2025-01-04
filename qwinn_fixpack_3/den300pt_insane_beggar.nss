//==============================================================================
/*
    den300pt_insane_beggar.nss
*/
//==============================================================================
//  Created By: Kaelin
//  Created On: 02/19/08
//==============================================================================

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "plot_h"

#include "campaign_h"
#include "den_constants_h"

#include "plt_den300pt_insane_beggar"

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

    plot_GlobalPlotHandler(eParms);                                 // any global plot operations, including debug info

    if(nType == EVENT_TYPE_SET_PLOT)    // actions -> normal flags only
    {
        int nValue      =   GetEventInteger(eParms, 2);             // On SET call, the value about to be written (on a normal SET that should be '1', and on a 'clear' it should be '0')
        int nOldValue   =   GetEventInteger(eParms, 3);             // On SET call, the current flag value (can be either 1 or 0 regardless if it's a set or clear event)

        // IMPORTANT: The flag value on a SET event is set only AFTER this script finishes running!
        switch(nFlag)
        {

            case PC_GAVE_AMULET_TO_BEGGAR:
            {
                // Qwinn: Amulet wasn't actually being removed from player's inventory
                RemoveItemsByTag(oPC,"den300im_beggar_amulet");

                object  oBeggar =   UT_GetNearestObjectByTag(oPC, DEN_CR_OTTO_BEGGAR);

                SetObjectInteractive(oBeggar, FALSE);

                UT_ExitDestroy(oBeggar);

                break;

            }


        }

     }
     else   // EVENT_TYPE_GET_PLOT -> defined conditions only
     {

        switch(nFlag)
        {

            case PC_HAS_AMULET:
            {

                int bCondition1 = WR_GetPlotFlag(PLT_DEN300PT_INSANE_BEGGAR, PC_FOUND_BEGGARS_AMULET);
                int bCondition2 = WR_GetPlotFlag(PLT_DEN300PT_INSANE_BEGGAR, PC_FOUND_AMULET_NEVER_TALKED);
                int bCondition3 = WR_GetPlotFlag(PLT_DEN300PT_INSANE_BEGGAR, PC_GAVE_AMULET_TO_BEGGAR);

                nResult = ( (bCondition1 || bCondition2) && !(bCondition3) );

                break;

            }



        }

    }

    plot_OutputDefinedFlag(eParms, nResult);

    return nResult;
}