//::///////////////////////////////////////////////
//:: Plot Events Template
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Plot events  for lite-multi-gax
*/
//:://////////////////////////////////////////////
//:: Created By: Keith
//:: Created On: Jan 6, 2008
//:://////////////////////////////////////////////

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "plot_h"
#include "campaign_h"

#include "lit_constants_h"
#include "plt_lite_multi_gax"
#include "plt_cod_lite_multi_gax"
#include "plt_den200pt_alley_justice"

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
            case MULTI_GAX_ADVENTURER:
            {
                WR_SetPlotFlag(PLT_COD_LITE_MULTI_GAX, MULTI_GAX_THREE, TRUE);
                //if all codexes found - activate journal
                if (WR_GetPlotFlag(PLT_COD_LITE_MULTI_GAX, MULTI_GAX_ONE) == TRUE && WR_GetPlotFlag(PLT_COD_LITE_MULTI_GAX, MULTI_GAX_TWO) == TRUE)
                {
                    WR_SetPlotFlag(PLT_LITE_MULTI_GAX, MULTI_GAX_MAIN, TRUE);
                    //the alley becomes visible when in the city
                    object oTarg = GetObjectByTag(WML_LC_DEN_ALLEY_2);
                    WR_SetWorldMapLocationStatus(oTarg, WM_LOCATION_ACTIVE);
                }
                //adventurer runs away
                object oAdventurer = UT_GetNearestCreatureByTag(oPC, LITE_CR_UNBOUND_ADVENTURER);
                SetObjectInteractive(oAdventurer, FALSE);
                UT_ExitDestroy(oAdventurer, TRUE);
                UT_Talk(oAdventurer, oAdventurer);

                break;
            }
            case MULTI_GAX_DOOR_UNLOCK:
            {
                //unlock the door to Gax's house
                object oDoor = UT_GetNearestObjectByTag(oPC, LITE_IP_UNBOUND_GAXDOOR);
                SetPlaceableState(oDoor, PLC_STATE_DOOR_UNLOCKED);
                break;
            }
            case MULTI_GAX_ATTACK:
            {
                //Transform into the revenant
                object oGax = UT_GetNearestCreatureByTag(oPC, LITE_CR_UNBOUND_GAX);
                object oDemon = UT_GetNearestCreatureByTag(oPC, LITE_CR_UNBOUND_GAX_DEMON);
                location lGax = GetLocation(oGax);
                effect eSummon = EffectVisualEffect(90285);

                //Summoning visual effect
                Engine_ApplyEffectAtLocation(EFFECT_DURATION_TYPE_INSTANT, EffectVisualEffect(90047), lGax);

                 //Gax goes away
                 WR_SetObjectActive(oGax, FALSE);
                 //Gax demon appears
                 WR_SetObjectActive(oDemon, TRUE);
                 UT_CombatStart(oDemon, oPC);

                break;
            }

            case MULTI_GAX_MAIN:
            {

                object  oWorldMapLoc    =   GetObjectByTag(WML_LC_DEN_ALLEY_2);

                // The location shows up on the Denerim map.
                WR_SetWorldMapLocationStatus(oWorldMapLoc, WM_LOCATION_ACTIVE);

                break;

            }

            case MULTI_GAX_DEAD:
            {

                // Qwinn:  Disabled this as there are other quests in the area now
                /*
                object  oWorldMapLoc    =   GetObjectByTag(WML_LC_DEN_ALLEY_2);

                int     bAlleyQuestAct  =   WR_GetPlotFlag(PLT_DEN200PT_ALLEY_JUSTICE, ALLEY_ACCEPTED);
                int     bAlleyCleared   =   WR_GetPlotFlag(PLT_DEN200PT_ALLEY_JUSTICE, ALLEY_CLEARED_2);


                // IF the Alley quest IS NOT active
                // OR IF it is AND the second alley has already been cleared,
                // remove the WML.
                
                if( (!bAlleyQuestAct) || (bAlleyQuestAct && bAlleyCleared))
                {

                    // The location is removed from the Denerim map.
                    WR_SetWorldMapLocationStatus(oWorldMapLoc, WM_LOCATION_INACTIVE);

                }
                */

                //percentage complete plot tracking
                ACH_TrackPercentageComplete(ACH_FAKE_DENERIM_16);

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