//::///////////////////////////////////////////////
//:: Broken Circle - Talked To
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
    This is for the Talked To scripts.
*/
//:://////////////////////////////////////////////
//:: Created By: Ferret
//:: Created On: December 14th, 2006
//:://////////////////////////////////////////////

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "plot_h"

#include "cir_constants_h"
#include "cir_functions_h"

#include "plt_cir000pt_talked_to"
#include "plt_cir300pt_fade"

#include "plt_cod_cha_greagoir"

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

    plot_GlobalPlotHandler(eParms);                         // any global plot operations, including debug info

    if(nType == EVENT_TYPE_SET_PLOT)                        // actions -> normal flags only
    {
        int nValue = GetEventInteger(eParms, 2);            // On SET call, the value about to be written (on a normal SET that should be '1', and on a 'clear' it should be '0')
        int nOldValue = GetEventInteger(eParms, 3);         // On SET call, the current flag value (can be either 1 or 0 regardless if it's a set or clear event)
        // IMPORTANT: The flag value on a SET event is set only AFTER this script finishes running!
        switch(nFlag)
        {

            case SLOTH_DEMON_TALKED_TO:         // CIR300_SLOTH_DEMON
                                                // The player and party are transported to Niall
            {
              // The player is transported to Niall
              UT_DoAreaTransition(CIR_AR_FADE, CIR_WP_NIALL_IN_FADE);
              break;
            }
            case GODWIN_TALKED_TO: // If godwin is talked to in the circle
            {
                //Put Godwin back in the closet.
                //Qwinn:  Only if Uldred isn't dead yet
                if(WR_GetPlotFlag(PLT_CIR000PT_MAIN, ULDRED_DEAD) == FALSE)
                {   
                    WR_SetObjectActive(GetObjectByTag(CIR_CR_GODWIN), FALSE);
                }    
                break;
            }
            case GREAGOIR_TALKED_TO: // When greagoir is talked to (at the beginning)
            {
                //If we didn't do the mage origin
                if(WR_GetPlotFlag(PLT_COD_CHA_GREAGOIR, COD_CHA_GREAGOIR_QUOTE_MAGE) == FALSE)
                {
                    //Set quote and main
                    WR_SetPlotFlag(PLT_COD_CHA_GREAGOIR, COD_CHA_GREAGOIR_QUOTE_ALL_OTHERS, TRUE, TRUE);
                    WR_SetPlotFlag(PLT_COD_CHA_GREAGOIR, COD_CHA_GREAGOIR_MAIN, TRUE, TRUE);
                }
                break;
            }

     }
     }
     else // EVENT_TYPE_GET_PLOT -> defined conditions only
     {

        switch(nFlag)
        {
           case WYNNE_TALKED_ABOUT_LITANY_AND_BEEN_IN_FADE: // If Wynne has talked about the litany and has been in the fade
            {
                if(WR_GetPlotFlag(PLT_CIR000PT_TALKED_TO, WYNNE_TALKED_ABOUT_LITANY) == TRUE
                    && WR_GetPlotFlag(PLT_CIR300PT_FADE, ENTER_FADE) == TRUE)
                {
                    nResult = TRUE;
                }
            }

        }
    }

    return nResult;
}