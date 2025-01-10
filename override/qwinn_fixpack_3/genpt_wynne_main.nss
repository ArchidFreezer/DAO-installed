//::///////////////////////////////////////////////
//:: Plot Events Template
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Script for Wynne's main follower conversation.
*/
//:://////////////////////////////////////////////
//:: Created By: David Sims
//:: Created On: July 5th, 2007
//:://////////////////////////////////////////////

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "plot_h"

#include "plt_genpt_wynne_main"
#include "plt_genpt_app_wynne"
#include "plt_mnp000pt_generic"
#include "plt_genpt_app_alistair"
#include "plt_genpt_app_leliana"
#include "plt_genpt_app_zevran"
#include "plt_genpt_app_morrigan"
#include "plt_gen00pt_party"
#include "plt_denpt_rescue_the_queen"
#include "plt_cir000pt_main"
#include "camp_constants_h"

// Qwinn:  Changed for more relevant condition
// #include "plt_denpt_captured"
#include "plt_denpt_main"


int StartingConditional()
{
    event           eParms              = GetCurrentEvent();                // Contains all input parameters
    int             nType               = GetEventType(eParms);               // GET or SET call
    string          strPlot             = GetEventString(eParms, 0);         // Plot GUID
    int             nFlag               = GetEventInteger(eParms, 1);          // The bit flag # being affected
    object          oParty              = GetEventCreator(eParms);      // The owner of the plot table for this script
    object          oConversationOwner  = GetEventObject(eParms, 0); // Owner on the conversation, if any
    int             nResult             = FALSE; // used to return value for DEFINED GET events
    object          oPC                 = GetHero();

    plot_GlobalPlotHandler(eParms); // any global plot operations, including debug info

    if(nType == EVENT_TYPE_SET_PLOT) // actions -> normal flags only
    {
        int nValue = GetEventInteger(eParms, 2);        // On SET call, the value about to be written (on a normal SET that should be '1', and on a 'clear' it should be '0')
        int nOldValue = GetEventInteger(eParms, 3);     // On SET call, the current flag value (can be either 1 or 0 regardless if it's a set or clear event)

        // IMPORTANT: The flag value on a SET event is set only AFTER this script finishes running!
        switch(nFlag)
        {
            case WYNNE_MAIN_MOVES_TO_CAMP_WAYPOINT:
            {
                object oWynne = UT_GetNearestCreatureByTag(oPC,GEN_FL_WYNNE);
                UT_LocalJump(oWynne,WP_CAMP_GEN_FL_WYNNE);
                break;
            }

            case WYNNE_MAIN_TALKED_TO_ANEIRIN:
            {
                //percentage complete plot tracking
                ACH_TrackPercentageComplete(ACH_FAKE_COMPANIONS_6);

                break;
            }
        }
     }
     else // EVENT_TYPE_GET_PLOT -> defined conditions only
     {

        switch(nFlag)
        {
            case WYNNE_MAIN_JUST_BEFORE_LANDSMEET:
            {
                //IF: In Denerim and crit path plots leading up to Landsmeet are done.(Rescue Queen, Captured)
                //IF: Warm
                // Qwinn:  Disabled this condition, it only gets set in very specific circumstances, RESCUE_QUEST_COMPLETE is adequate
                // int bRescueOver = WR_GetPlotFlag(PLT_DENPT_CAPTURED, DEN_CAPTURED_FINAL_FIGHT, TRUE);
                int bCapturedOver = WR_GetPlotFlag(PLT_DENPT_RESCUE_THE_QUEEN, DEN_RESCUE_QUEST_COMPLETE);
                // Qwinn:  And we do need to check that landsmeet isn't complete
                int bLandsmeetDone = WR_GetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_QUEST_DONE);
                
                int bWarm = WR_GetPlotFlag(PLT_GENPT_APP_WYNNE, APP_WYNNE_IS_WARM, TRUE);

                if (bCapturedOver && bWarm && !bLandsmeetDone)
                    nResult = TRUE;

                break;
            }

            case WYNNE_MAIN_PC_IS_IN_A_ROMANCE:
            {
                //IF: PC is at Adore state with an NPC.

                int bAliAdore = WR_GetPlotFlag(PLT_GENPT_APP_ALISTAIR, APP_ALISTAIR_IS_ADORE);
                int bLelAdore = WR_GetPlotFlag(PLT_GENPT_APP_LELIANA, APP_LELIANA_IS_ADORE);
                int bZevAdore = WR_GetPlotFlag(PLT_GENPT_APP_ZEVRAN, APP_ZEVRAN_IS_ADORE);
                int bMorAdore = WR_GetPlotFlag(PLT_GENPT_APP_MORRIGAN, APP_MORRIGAN_IS_ADORE);

                if ( bAliAdore || bLelAdore || bZevAdore || bMorAdore )
                {
                    nResult = TRUE;
                }
                break;
            }
            case WYNNE_MAIN_CAN_ASK_ABOUT_TIRED:
            {
                //IF: PC_KNOWS_WYNNE_TIRED [wynne_main]
                //IF NOT: PC_KNOWS_WYNNE_DEAD [wynne_main]

                int bKnowsTired = WR_GetPlotFlag(PLT_GENPT_WYNNE_MAIN, WYNNE_MAIN_PC_KNOWS_WYNNE_TIRED);
                int bKnowsDead = WR_GetPlotFlag(PLT_GENPT_WYNNE_MAIN, WYNNE_MAIN_PC_KNOWS_WYNNE_DEAD);

                if ( (bKnowsTired == TRUE) && (bKnowsDead == FALSE) )
                {
                    nResult = TRUE;
                }

                break;
            }
            case WYNNE_MAIN_READY_FOR_WHAT_GREY_WARDEN_MEANS:
            {
                //IF: DISCUSSED_BECOMING_GREY_WARDEN [wynne_main]
                //IF: Some time has passed.

                int bDiscussed = WR_GetPlotFlag(PLT_GENPT_WYNNE_MAIN, WYNNE_MAIN_DISCUSSED_BECOMING_GREY_WARDEN);

                if ( (bDiscussed == TRUE) )
                {
                    nResult = TRUE;
                }

                break;
            }
            case WYNNE_MAIN_READY_FOR_GREY_WARDEN_HISTORY:
            {
                //IF: TALKED_ABOUT_DUTY [wynne_main]
                //IF: Some time has passed

                int bTalkedDuty = WR_GetPlotFlag(PLT_GENPT_WYNNE_MAIN, WYNNE_MAIN_TALKED_ABOUT_DUTY);

                if ( (bTalkedDuty == TRUE) )
                {
                    nResult = TRUE;
                }

                break;
            }
            case WYNNE_MAIN_IN_PARTY_AND_PC_HEARD_ABOUT_ANEIRIN:
            {
                int bInParty = WR_GetPlotFlag(PLT_GEN00PT_PARTY,GEN_WYNNE_IN_PARTY,TRUE);
                int bHeardAboutAneirin = WR_GetPlotFlag(PLT_GENPT_WYNNE_MAIN,WYNNE_MAIN_PC_HEARD_ABOUT_ANEIRIN,TRUE);
                int bTalkedToAneirin = WR_GetPlotFlag(PLT_GENPT_WYNNE_MAIN, WYNNE_MAIN_TALKED_TO_ANEIRIN);

                if ( bHeardAboutAneirin == TRUE && bInParty == TRUE && bTalkedToAneirin == FALSE )
                {
                    nResult = TRUE;
                }
                break;
            }
            case WYNNE_MAIN_IN_PARTY_BUT_CIRCLE_PLOT_NOT_DONE:
            {
                // Circle plot not complete  and Wynne in party (i.e. Wynne in party to help complete Circle plot

                int bInParty = WR_GetPlotFlag(PLT_GEN00PT_PARTY,GEN_WYNNE_IN_PARTY,TRUE);
                int bCircleQuestDone = WR_GetPlotFlag(PLT_CIR000PT_MAIN, BROKEN_CIRCLE_PLOT_DONE_TOWER_SAVED);

                nResult = (bInParty == TRUE) && (bCircleQuestDone == FALSE);

                break;
            }
        }

    }

    plot_OutputDefinedFlag(eParms, nResult);

    return nResult;
}