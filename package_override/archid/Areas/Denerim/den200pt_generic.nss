//::///////////////////////////////////////////////
//:: Plot Events Template
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Plot events
*/
//:://////////////////////////////////////////////
//:: Created By: Craig
//:: Created On: March 25, 2008
//:://////////////////////////////////////////////

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "plot_h"

#include "plt_den200pt_generic"
#include "plt_bdn120pt_gorim"
#include "plt_cod_bks_enderin_note"
#include "den_constants_h"
#include "plt_gen00pt_generic_actions"

// Merchant Scaling
#include "scalestorefix_h"

const string DEN_STORE_PREFIX = "store_";

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
    string sTag;

    plot_GlobalPlotHandler(eParms); // any global plot operations, including debug info

    if(nType == EVENT_TYPE_SET_PLOT) // actions -> normal flags only
    {
        int nValue = GetEventInteger(eParms, 2);        // On SET call, the value about to be written (on a normal SET that should be '1', and on a 'clear' it should be '0')
        int nOldValue = GetEventInteger(eParms, 3);     // On SET call, the current flag value (can be either 1 or 0 regardless if it's a set or clear event)
        // IMPORTANT: The flag value on a SET event is set only AFTER this script finishes running!
        switch(nFlag)
        {
            case DEN_MARKET_GENERIC_GORIM_AEDUCAN_SHIELD_GIVEN:
            {
                WR_SetPlotFlag(PLT_COD_BKS_ENDERIN_NOTE, COD_BKS_ENDERIN_NOTE, TRUE);
                break;
            }
            case DEN_MARKET_GENERIC_GORIM_DISCOUNT:
            {
                if (GetLocalInt(GetModule(), COUNTER_MAIN_PLOTS_DONE) >= 3)
                {
                    sTag = "store_den200cr_gorim_2";
                } else
                {
                    sTag = "store_den200cr_gorim";
                }
                object oStore = GetObjectByTag(sTag);
                SetStoreMarkDown(oStore, 50);
                ScaleStoreEdited(oStore); // Merchant Scaling
                OpenStore(oStore);
                break;
            }
            case DEN_MARKET_GENERIC_GORIM_OPEN_STORE:
            {
                if (GetLocalInt(GetModule(), COUNTER_MAIN_PLOTS_DONE) >= 3)
                {
                    sTag = "store_den200cr_gorim_2";
                } else
                {
                    sTag = "store_den200cr_gorim";
                }
                object oStore = GetObjectByTag(sTag);
                ScaleStoreEdited(oStore); // Merchant Scaling
                OpenStore(oStore);
                break;
            }
            case DEN_LIGHT_CONTENT_GENERIC_HERREN_OPEN_STORE:
            {
                if (GetLocalInt(GetModule(), COUNTER_MAIN_PLOTS_DONE) >= 3)
                {
                    sTag = "store_nrd_dencr_herren_2";
                } else
                {
                    sTag = "store_nrd_dencr_herren";
                }
                object oStore = GetObjectByTag(sTag);
                ScaleStoreEdited(oStore); // Merchant Scaling
                OpenStore(oStore);
                break;
            }
        }
     }
     else // EVENT_TYPE_GET_PLOT -> defined conditions only
     {

        switch(nFlag)
        {
            case DEN_MARKET_GENERIC_GORIM_ROMANTIC_AND_NOT_MENTIONED:
            {
                nResult = !WR_GetPlotFlag(PLT_DEN200PT_GENERIC, DEN_MARKET_GENERIC_GORIM_ROMANCE_MENTIONED)
                        && WR_GetPlotFlag(PLT_BDN120PT_GORIM, BDN_GORIM_ROMANTIC);

                break;
            }
        }

    }

    plot_OutputDefinedFlag(eParms, nResult);

    return nResult;
}