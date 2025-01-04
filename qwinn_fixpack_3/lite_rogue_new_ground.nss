//::///////////////////////////////////////////////
//:: Plot Events Template
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Plot events for the "New Ground" (Box of Certain Interests)
*/
//:://////////////////////////////////////////////
//:: Created By: Joshua
//:: Created On: Jan 14th, 2009
//:://////////////////////////////////////////////

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "campaign_h"
#include "plot_h"
#include "lit_constants_h"
#include "den_lc_constants_h"

#include "plt_lite_rogue_new_ground"
#include "plt_lite_rogue_decisions"
#include "plt_lite_rogue_solving"
#include "plt_lite_rogue_terms"
#include "plt_lite_rogue_witness"

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

            case NEW_GROUND_PLOT_ACCEPTED:
            {
                WR_SetPlotFlag(PLT_LITE_ROGUE_DECISIONS,DECISIONS_ROGUE_BOARD,FALSE);
                break;
            }

            case NEW_GROUND_PLOT_SETUP:
            {
                int bPlotAccepted = WR_GetPlotFlag(strPlot,NEW_GROUND_PLOT_ACCEPTED);
                int bGuardDone = WR_GetPlotFlag(strPlot,NEW_GROUND_GUARD_DONE);
                object oGuardContact = UT_GetNearestCreatureByTag(oPC,LITE_CR_ROGUE_GUARD_CONTACT);

                WR_SetObjectActive(oGuardContact, (bPlotAccepted&&!bGuardDone));

                break;
            }
            case NEW_GROUND_PLOT_CLOSED:
            {
                RemoveItemsByTag(GetHero(),LITE_IM_ROGUE_DIRECTIONS);

                //percentage complete plot tracking
                ACH_TrackPercentageComplete(ACH_FAKE_ROGUE_5);

                break;
            }
            case NEW_GROUND_PLOT_COMPLETED:
            {
                object oTarg = GetObjectByTag(WML_LC_ROGUE_D);
                WR_SetWorldMapLocationStatus(oTarg, WM_LOCATION_GRAYED_OUT);

                WR_SetPlotFlag(PLT_LITE_ROGUE_SOLVING,SOLVING_ROGUE_BOARD,FALSE);
                WR_SetPlotFlag(PLT_LITE_ROGUE_TERMS,TERMS_ROGUE_BOARD,FALSE);
                WR_SetPlotFlag(PLT_LITE_ROGUE_WITNESS,WITNESS_ROGUE_BOARD,FALSE);

                if (WR_GetPlotFlag(PLT_LITE_ROGUE_SOLVING,SOLVING_PLOT_ACCEPTED) &&
                    !WR_GetPlotFlag(PLT_LITE_ROGUE_SOLVING,SOLVING_PLOT_CLOSED))
                    WR_SetPlotFlag(PLT_LITE_ROGUE_SOLVING,SOLVING_TERMINATED_D_DEAD,TRUE,TRUE);

                if (WR_GetPlotFlag(PLT_LITE_ROGUE_TERMS,TERMS_PLOT_ACCEPTED) &&
                    !WR_GetPlotFlag(PLT_LITE_ROGUE_TERMS,TERMS_PLOT_CLOSED))
                    WR_SetPlotFlag(PLT_LITE_ROGUE_TERMS,TERMS_TERMINATED_D_DEAD,TRUE,TRUE);

                if (WR_GetPlotFlag(PLT_LITE_ROGUE_WITNESS,WITNESS_PLOT_ACCEPTED) &&
                    !WR_GetPlotFlag(PLT_LITE_ROGUE_WITNESS,WITNESS_PLOT_CLOSED))
                    WR_SetPlotFlag(PLT_LITE_ROGUE_WITNESS,WITNESS_TERMINATED_D_DEAD,TRUE,TRUE);
                break;
            }

            case NEW_GROUND_CONTACT_1:
            case NEW_GROUND_CONTACT_2:
            case NEW_GROUND_CONTACT_3:
            {
                // Set this current plot flag, since it doesn't usually set
                // till this script is fully run
                WR_SetPlotFlag(strPlot,nFlag,TRUE);
                if (WR_GetPlotFlag(strPlot,NEW_GROUND_CONTACT_1) &&
                    WR_GetPlotFlag(strPlot,NEW_GROUND_CONTACT_2) &&
                    WR_GetPlotFlag(strPlot,NEW_GROUND_CONTACT_3))
                {
                    WR_SetPlotFlag(strPlot,NEW_GROUND_PEOPLE_DONE,TRUE,TRUE);
                }
                // Qwinn added
                break;
            }

            case NEW_GROUND_GUARD_DONE:
            {
                object oGuardContact = UT_GetNearestCreatureByTag(oPC,LITE_CR_ROGUE_GUARD_CONTACT);
                WR_SetObjectActive(oGuardContact,FALSE);
                // Qwinn added
                break;
            }

            case NEW_GROUND_D_HOSTILE:
            {
                UT_TeamGoesHostile(DEN_TEAM_ROGUE_D);
                break;
            }
            case NEW_GROUND_D_LIEUT_HOSTILE:
            {
                UT_TeamGoesHostile(DEN_TEAM_ROGUE_K_LIEUT);
                break;
            }
            case NEW_GROUND_LIEUT_DEAD:
            {
                UT_RemoveItemFromInventory(INVALID_RESOURCE,1,OBJECT_INVALID,LITE_IM_ROGUE_DIRECTIONS);
                object oTarg = GetObjectByTag(WML_LC_ROGUE_D);
                WR_SetWorldMapLocationStatus(oTarg, WM_LOCATION_ACTIVE);
                break;
            }

        }
     }
     else // EVENT_TYPE_GET_PLOT -> defined conditions only
     {

        switch(nFlag)
        {
            case NEW_GROUND_RANDOM_ENCOUNTER_ACTIVE:
            {

                if (WR_GetPlotFlag(strPlot,NEW_GROUND_GUARD_DONE) &&
                   !WR_GetPlotFlag(strPlot,NEW_GROUND_LIEUT_DEAD))
                    nResult = TRUE;
                // Qwinn added
                break;
            }
            case NEW_GROUND_CAN_CONTACT:
            {

                if (WR_GetPlotFlag(strPlot,NEW_GROUND_PLOT_ACCEPTED) &&
                   !WR_GetPlotFlag(strPlot,NEW_GROUND_PEOPLE_DONE))
                    nResult = TRUE;
                // Qwinn added
                break;
            }
        }

    }

    plot_OutputDefinedFlag(eParms, nResult);

    return nResult;
}