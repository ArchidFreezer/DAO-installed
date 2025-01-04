//::///////////////////////////////////////////////
//:: Plot Events Template
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
  Korcari wilds - light content - lastwill
*/
//:://////////////////////////////////////////////
//:: Created By: Keith
//:: Created On: Jan 15th, 2009
//:://////////////////////////////////////////////

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "plot_h"
#include "lit_constants_h"

#include "plt_lite_kor_lastwill"

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
            case CACHE_FOUND:
            {
                //give the lockbox to the player
                UT_AddItemToInventory(rLITE_IM_KOR_LOCKBOX, 1);
                //deactivate the cache
                object oCache = UT_GetNearestObjectByTag(oPC, LITE_IP_LASTWILL_CACHE);
                SetObjectInteractive(oCache, FALSE);

                break;
            }

            case CACHE_OPENED:
            {
                //give the items - amulet and some jewels
                UT_AddItemToInventory(rLITE_IM_KOR_AMULET, 1);
                UT_AddItemToInventory(rLITE_IM_KOR_EMERALD, 1);
                UT_AddItemToInventory(rLITE_IM_KOR_MALACHITE, 1);
                UT_AddItemToInventory(rLITE_IM_HEALTH_POUL, 2);

                //deactivate the cache
                object oCache = UT_GetNearestObjectByTag(oPC, LITE_IP_LASTWILL_CACHE);
                SetObjectInteractive(oCache, FALSE);
                
                // Qwinn:  And remove the will
                RemoveItemsByTag(oPC,LITE_IM_KOR_LASTWILL_WILL);
                break;
            }

            case LASTWILL_COMPLETE:
            {
                //get rid of the lockbox
                UT_RemoveItemFromInventory(rLITE_IM_KOR_LOCKBOX);
                // Qwinn:  And the will
                RemoveItemsByTag(oPC,LITE_IM_KOR_LASTWILL_WILL);

                //percentage complete plot tracking
                ACH_TrackPercentageComplete(ACH_FAKE_KOKARI_1);

                break;
            }
            
            // Qwinn added:
            case LASTWILL_FAIL:
            {
                RemoveItemsByTag(oPC,LITE_IM_KOR_LASTWILL_WILL);
                break;
            }

        }
     }
     else // EVENT_TYPE_GET_PLOT -> defined conditions only
     {

        switch(nFlag)
        {
            case LASTWILL_READY_TO_TURNIN:
            {
                if (WR_GetPlotFlag(PLT_LITE_KOR_LASTWILL, LASTWILL_GIVEN) == TRUE &&
                    WR_GetPlotFlag(PLT_LITE_KOR_LASTWILL, LASTWILL_COMPLETE) == FALSE &&
                    WR_GetPlotFlag(PLT_LITE_KOR_LASTWILL, LASTWILL_JETTA_DONE) == FALSE)
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