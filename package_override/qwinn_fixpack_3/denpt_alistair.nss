//::///////////////////////////////////////////////
//:: Plot Events Template
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Plot events
*/
//:://////////////////////////////////////////////
//:: Created By: Yaron
//:: Created On: July 21st, 2006
//:://////////////////////////////////////////////

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "plot_h"

#include "party_h"
#include "plt_denpt_alistair"
#include "plt_denpt_main"
#include "plt_denpt_anora"
#include "plt_genpt_app_alistair"
#include "plt_gen00pt_class_race_gend"
#include "plt_gen00pt_skills"
#include "plt_denpt_rescue_the_queen"

#include "den_constants_h"

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
            case DEN_ALISTAIR_BREAKS_UP_WITH_PLAYER:
            {
                if (WR_GetPlotFlag(PLT_GENPT_APP_ALISTAIR, APP_ALISTAIR_IS_IN_LOVE))
                    WR_SetPlotFlag(PLT_GENPT_APP_ALISTAIR, APP_ALISTAIR_STILL_IN_LOVE, TRUE, TRUE);

                WR_SetPlotFlag(PLT_GENPT_APP_ALISTAIR, APP_ALISTAIR_ROMANCE_CUT_OFF, TRUE, TRUE);
                WR_SetPlotFlag(PLT_GENPT_APP_ALISTAIR, APP_ALISTAIR_ROMANCE_CAN_NOT_RESTART, TRUE, TRUE);

                break;
            }
            case DEN_ALISTAIR_GOES_TO_PARTY_CAMP:
            {
                object oAlistair = Party_GetFollowerByTag(GEN_FL_ALISTAIR);
                object oAlistairWP = UT_GetNearestObjectByTag(oPC, DEN_WP_EAMON_ALISTAIR);
                WR_SetObjectActive(oAlistair, FALSE);

                SetMapPinState(oAlistairWP, FALSE);

                DoAutoSave();
                break;
            }
            case DEN_ALISTAIR_MARRYING_PLAYER:
            {
                WR_SetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_ALISTAIR_ENGAGED_TO_PLAYER, TRUE, TRUE);
                break;
            }



        }
     }
     else // EVENT_TYPE_GET_PLOT -> defined conditions only
     {

        switch(nFlag)
        {
            case DEN_ALISTAIR_CAN_FORGIVE_LOGHAIN:
            {
                nResult = WR_GetPlotFlag(PLT_GENPT_APP_ALISTAIR, APP_ALISTAIR_CHANGED, TRUE)
                          &&  WR_GetPlotFlag(PLT_GEN00PT_SKILLS, GEN_PERSUADE_MED, TRUE);

                break;
            }
            case DEN_ALISTAIR_CAN_TALK_ABOUT_ANORA:
            {
                nResult = WR_GetPlotFlag(PLT_DENPT_ANORA, DEN_ANORA_CONVERSATION_1)
                        && !WR_GetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_BEGINS);
                break;
            }

            case DEN_ALISTAIR_CAN_BE_PERSUADED_TO_MARRY:
            {
                nResult = WR_GetPlotFlag(PLT_DENPT_ANORA, DEN_ANORA_ALISTAIR_MARRIAGE_SUCCESS)
                            && !WR_GetPlotFlag(PLT_DENPT_ALISTAIR, DEN_ALISTAIR_ANORA_MARRIAGE_REFUSED)
                            && !WR_GetPlotFlag(PLT_DENPT_ALISTAIR, DEN_ALISTAIR_MARRIAGE_SUCCESS)
                            && !WR_GetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_BEGINS);
                break;
            }
            case DEN_ALISTAIR_CHANGED_AND_PC_FEMALE:
            {
                nResult = WR_GetPlotFlag(PLT_GENPT_APP_ALISTAIR, APP_ALISTAIR_CHANGED, TRUE)
                          &&  WR_GetPlotFlag(PLT_GEN00PT_CLASS_RACE_GEND, GEN_GENDER_FEMALE, TRUE);

                break;
            }
            case DEN_ALISTAIR_UNCHANGED_AND_PC_FEMALE:
            {
                nResult = !WR_GetPlotFlag(PLT_GENPT_APP_ALISTAIR, APP_ALISTAIR_CHANGED, TRUE)
                          &&  WR_GetPlotFlag(PLT_GEN00PT_CLASS_RACE_GEND, GEN_GENDER_FEMALE, TRUE);
                break;
            }
            case DEN_ALISTAIR_WILL_TAKE_THRONE_WITHOUT_PLAYER_APPROVAL:   
            {
                // Version 3.5 - added check that the player didn't actually already approve. This can happen if you consider accepting Loghain into GW
                int bAlistairAlreadyChosen = WR_GetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_ALISTAIR_IS_KING);
                
                int bAlistairWantsToMarryPlayer     = WR_GetPlotFlag(PLT_GENPT_APP_ALISTAIR, APP_ALISTAIR_IS_IN_LOVE, TRUE)
                                                    && WR_GetPlotFlag(PLT_GEN00PT_BACKGROUNDS, GEN_BACK_HUMAN_NOBLE);

                int bAlistairWillingToMarryAnora    = WR_GetPlotFlag(PLT_DENPT_ANORA, DEN_ANORA_ALISTAIR_MARRIAGE_ARRANGED)
                                                    && !WR_GetPlotFlag(PLT_DENPT_ANORA, DEN_ANORA_WILL_BETRAY_PC);

                nResult = WR_GetPlotFlag(PLT_GENPT_APP_ALISTAIR, APP_ALISTAIR_CHANGED, TRUE)
                          && WR_GetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_ALISTAIR_EXECUTES_LOGHAIN)
                          && !bAlistairWantsToMarryPlayer
                          && !bAlistairWillingToMarryAnora
                          && !bAlistairAlreadyChosen;
                break;
            }

        }

    }

    plot_OutputDefinedFlag(eParms, nResult);

    return nResult;
}