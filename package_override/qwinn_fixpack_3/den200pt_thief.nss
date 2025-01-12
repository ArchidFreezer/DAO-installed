//==============================================================================
/*
    den200pt_thief.nss
    The main hub for the Crime Wave series of quests from "Slim" Couldry.
*/
//==============================================================================
//  Created By: Ferret
//  Created On: June 23rd, 2008
//==============================================================================

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "plot_h"

#include "campaign_h"
#include "den_constants_h"

#include "plt_gen00pt_backgrounds"
#include "plt_denpt_main"
#include "plt_denpt_talked_to"

#include "plt_den200pt_thief"
#include "plt_den200pt_thief_pick1"
#include "plt_den200pt_thief_pick2"
#include "plt_den200pt_thief_pick3"
#include "plt_den200pt_thief_pick4"
#include "plt_den200pt_thief_sneak1"
#include "plt_den200pt_thief_sneak2"
#include "plt_den200pt_thief_sneak3"
#include "plt_den200pt_thief_sneak4"

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
    object  oTarg;

    object  oCouldry            =   UT_GetNearestObjectByTag(oPC, DEN_CR_COULDRY);


    plot_GlobalPlotHandler(eParms);                                 // any global plot operations, including debug info

    if(nType == EVENT_TYPE_SET_PLOT)    // actions -> normal flags only
    {
        int nValue      =   GetEventInteger(eParms, 2);              // On SET call, the value about to be written (on a normal SET that should be '1', and on a 'clear' it should be '0')
        int nOldValue   =   GetEventInteger(eParms, 3);             // On SET call, the current flag value (can be either 1 or 0 regardless if it's a set or clear event)

        // IMPORTANT: The flag value on a SET event is set only AFTER this script finishes running!
        switch(nFlag)
        {

            case THIEF_PICKPOCKET_ACTIVE:
            {

                object oSlim    =   UT_GetNearestObjectByTag(oPC, DEN_CR_COULDRY);

                if( nOldValue )
                {

                    WR_TogglePlotIcon(oSlim, FALSE);

                }

                break;

            }


            case COULDRY_APPEARS:                   // From the Market area enter script
            {

                WR_SetObjectActive(oCouldry, TRUE);

                break;

            }

            case COULDRY_LEAVES_FOREVER_BEFORE_GIVING_QUEST:
                                                    // DEN200_COULDRY
                                                    // Couldry takes off, quest rejected
            {

                UT_ExitDestroy(oCouldry);

                break;

            }

            case PC_IS_BOTH_PICKPOCKET_AND_SNEAK:   // DEN200_COULDRY
                                                    // The PC wants to do both set of missions
            {

                WR_SetPlotFlag(PLT_DEN200PT_THIEF, PC_IS_PICKPOCKET, TRUE, TRUE);
                WR_SetPlotFlag(PLT_DEN200PT_THIEF, PC_IS_SNEAK, TRUE, TRUE);

                break;

            }

            case COULDRY_LEAVES_FOR_GOOD:           // DEN200_COULDRY
                                                    // Couldry takes off (not given a chance to redeem himself)
            {

                UT_ExitDestroy(oCouldry);

                break;

            }

            case COULDRY_LEAVES_FOR_NOW:            // DEN200_COULDRY
                                                    // Couldry leaves for now - searching for redemption
            {

                WR_SetObjectActive(oCouldry, FALSE);

                RewardMoney(0, 0, 10);

                // Note: Couldry returns after the Landsmeet Quest is complete. That logic is stored on the
                // area script for the Denerim Market.

                break;

            }

            case COULDRY_RETURNS_FOR_LAST_SNEAK:    // DEN200_COULDRY
                                                    // Couldry returns - happens on Market area load
            {

                WR_SetObjectActive(oCouldry, TRUE);

                SetPlotGiver(oCouldry, TRUE);

                break;

            }

            case COULDRY_GIVES_LAST_MISSION:        // DEN200_COULDRY
                                                    // Sync up main journal with sub-journal
            {

                WR_SetPlotFlag(PLT_DEN200PT_THIEF_SNEAK4, THIEF_SNEAK4_ASSIGNED, TRUE, TRUE);

                break;

            }

            case THIEF_LAST_MISSION_CHECK:          // DEN200_COULDRY
                                                    // This checks to see if it should close off the global
                                                    // quest.
            {

                int bCondition1 = WR_GetPlotFlag(PLT_DEN200PT_THIEF, PC_IS_PICKPOCKET);
                int bCondition2 = WR_GetPlotFlag(PLT_DEN200PT_THIEF, PC_IS_SNEAK);
                int bCondition3 = WR_GetPlotFlag(PLT_DEN200PT_THIEF_PICK4, THIEF_PICK4_SUCCESSFUL);
                int bCondition4 = WR_GetPlotFlag(PLT_DEN200PT_THIEF_SNEAK4, THIEF_SNEAK4_SUCCESSFUL);

                if ( bCondition3 && !bCondition2 )
                {

                    WR_SetPlotFlag(PLT_DEN200PT_THIEF, COULDRY_ACKNOWLEDGES_QUEST_OVER, TRUE, TRUE);

                }

                if ( bCondition4 && !bCondition1 )
                {

                    WR_SetPlotFlag(PLT_DEN200PT_THIEF, COULDRY_ACKNOWLEDGES_QUEST_OVER, TRUE, TRUE);

                }

                break;

            }

            case THIEF_QUEST_DONE:                  // DEN200_COULDRY
                                                    // He heads off for good
            {
                // Qwinn added:
                UT_ExitDestroy(oCouldry);
                break;

            }

            case COULDRY_LANDSMEET_CLEANUP:         // Post Landsmeet - this is to clean up
                                                    // the plots in light of that change.
            {

                int bPCIsSneaky =   WR_GetPlotFlag(PLT_DEN200PT_THIEF, PC_IS_SNEAK);
                int bSneak2Done =   WR_GetPlotFlag(PLT_DEN200PT_THIEF_SNEAK2, THIEF_SNEAK2_SUCCESSFUL);

                // If you haven't talked to Slim Couldry yet, just disappear him
                if ( !WR_GetPlotFlag(PLT_DENPT_TALKED_TO, DEN_TT_COULDRY) )
                {

                    WR_SetObjectActive(oCouldry, FALSE);

                }

                // If the PC is on the Stealth missions and hasn't completed the Arl Howe
                // specific ones, then shut down the
                if ( bPCIsSneaky &&  !bSneak2Done )
                {

                    // Turn off the SNEAK flag, and queue up Couldry to respond
                    WR_SetPlotFlag(PLT_DEN200PT_THIEF, COULDRY_ABORTING_THE_MISSIONS, TRUE, TRUE);
                    WR_SetPlotFlag(PLT_DEN200PT_THIEF, PC_IS_SNEAK, FALSE, FALSE);
                    WR_SetPlotFlag(PLT_DEN200PT_THIEF, THIEF_SNEAK_ACTIVE, FALSE, FALSE);

                }

                break;

            }

            case THIEF_QUEST_ABORTED:               // The thief quests are aborted (due to the Landsmeet ending)
            {

                int bSneakTwoAssigned   =   WR_GetPlotFlag(PLT_DEN200PT_THIEF_SNEAK2, THIEF_SNEAK2_ASSIGNED);

                if ( bSneakTwoAssigned )
                {

                    WR_SetPlotFlag(PLT_DEN200PT_THIEF_SNEAK2, THIEF_SNEAK2_ASSIGNED, FALSE, FALSE);
                    WR_SetPlotFlag(PLT_DEN200PT_THIEF_SNEAK2, THIEF_SNEAK2_ABORTED, TRUE, TRUE);

                }

                break;

            }

            case THIEF_SNEAK_QUESTS_ABORTED:        // Just kill the sneak quests
            {

                int bSneakTwoAssigned   =   WR_GetPlotFlag(PLT_DEN200PT_THIEF_SNEAK2, THIEF_SNEAK2_ASSIGNED);

                if ( bSneakTwoAssigned )
                {

                    WR_SetPlotFlag(PLT_DEN200PT_THIEF_SNEAK2, THIEF_SNEAK2_ASSIGNED, FALSE, FALSE);
                    WR_SetPlotFlag(PLT_DEN200PT_THIEF_SNEAK2, THIEF_SNEAK2_ABORTED, TRUE, TRUE);

                }

                break;

            }

        }
     }
     else   // EVENT_TYPE_GET_PLOT -> defined conditions only
     {

        switch(nFlag)
        {

            case PC_IS_NOBLE:                       // If the PC is a Dwarf or Human Noble
            {

                int bCondition1 = WR_GetPlotFlag(PLT_GEN00PT_BACKGROUNDS, GEN_BACK_DWARF_NOBLE);
                int bCondition2 = WR_GetPlotFlag(PLT_GEN00PT_BACKGROUNDS, GEN_BACK_HUMAN_NOBLE);

                nResult = bCondition1 || bCondition2;

                break;

            }

            case COULDRY_NOT_READY_FOR_FINAL_PICK:  // Needs the Landsmeet to be open
            {

                int bCondition1 = WR_GetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_PLOT_OPENED);
                int bCondition2 = WR_GetPlotFlag(PLT_DEN200PT_THIEF_PICK3, THIEF_PICK3_SUCCESSFUL);

                // Qwinn:  Fixed condition
                // nResult = !bCondition1 && bCondition2;
                nResult = !bCondition1 || !bCondition2;

                break;

            }

            case COULDRY_READY_FOR_FINAL_PICK:      // Needs the Landsmeet to be open
            {

                int bCondition1 = WR_GetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_PLOT_OPENED);
                int bCondition2 = WR_GetPlotFlag(PLT_DEN200PT_THIEF_PICK3, THIEF_PICK3_SUCCESSFUL);

                nResult = bCondition1 && bCondition2;

                break;

            }

            case COULDRY_READY_FOR_FINAL_SNEAK: // Needs the Landsmeet to be open
            {

                int bCondition1 = WR_GetPlotFlag(PLT_DENPT_MAIN, LANDSMEET_PLOT_OPENED);
                int bCondition2 = WR_GetPlotFlag(PLT_DEN200PT_THIEF_SNEAK2, THIEF_SNEAK2_SUCCESSFUL);
                int bCondition3 = WR_GetPlotFlag(PLT_DEN200PT_THIEF, PC_IS_PICKPOCKET);
                int bCondition4 = WR_GetPlotFlag(PLT_DEN200PT_THIEF_PICK4, THIEF_PICK4_SUCCESSFUL);


                if ( bCondition3 )
                {

                    nResult = bCondition4 && bCondition1 && bCondition2;

                }

                else
                {

                    nResult = bCondition1 && bCondition2;

                }

                break;

            }

            case THIEF_CHECK_IF_SNEAK_AVAILABLE:    // See if any of the plots are available to be picked up
            {

                int bPC_is_Sneak = WR_GetPlotFlag(PLT_DEN200PT_THIEF, PC_IS_SNEAK);
                int bSneak1_Assigned = WR_GetPlotFlag(PLT_DEN200PT_THIEF_SNEAK1, THIEF_SNEAK1_ASSIGNED);
                int bSneak1_Complete = WR_GetPlotFlag(PLT_DEN200PT_THIEF_SNEAK1, THIEF_SNEAK1_SUCCESSFUL);
                int bSneak2_Assigned = WR_GetPlotFlag(PLT_DEN200PT_THIEF_SNEAK2, THIEF_SNEAK2_ASSIGNED);
                int bSneak2_Complete = WR_GetPlotFlag(PLT_DEN200PT_THIEF_SNEAK2, THIEF_SNEAK2_SUCCESSFUL);
                int bSneak3_Assigned = WR_GetPlotFlag(PLT_DEN200PT_THIEF_SNEAK3, THIEF_SNEAK3_ASSIGNED);
                int bSneak3_Complete = WR_GetPlotFlag(PLT_DEN200PT_THIEF_SNEAK3, THIEF_SNEAK3_SUCCESSFUL);
                int bSneak4_Assigned = WR_GetPlotFlag(PLT_DEN200PT_THIEF_SNEAK4, THIEF_SNEAK4_ASSIGNED);
                int bSneak4_Available = WR_GetPlotFlag(PLT_DEN200PT_THIEF, COULDRY_READY_FOR_FINAL_SNEAK);
                int bSneak4_Complete = WR_GetPlotFlag(PLT_DEN200PT_THIEF_SNEAK4, THIEF_SNEAK4_QUEST_DONE);

                // If the PC is not a Sneak Player, then no quests available
                if ( !bPC_is_Sneak )
                {
                    nResult = FALSE;
                    break;
                }

                // Otherwise, check what's where
                if ( !bSneak1_Assigned ) nResult = TRUE;
                if ( bSneak1_Complete && !bSneak2_Assigned ) nResult = TRUE;
                if ( bSneak2_Complete && !bSneak3_Assigned && bSneak4_Available ) nResult = TRUE;
                if ( bSneak3_Complete && !bSneak4_Assigned ) nResult = TRUE;

                break;

            }

            case THIEF_CHECK_IF_PICKPOCKET_AVAILABLE:   // See if any of the plots are available to be picked up
            {

                int bPC_is_Pick = WR_GetPlotFlag(PLT_DEN200PT_THIEF, PC_IS_PICKPOCKET);
                int bPick1_Assigned = WR_GetPlotFlag(PLT_DEN200PT_THIEF_PICK1, THIEF_PICK1_ASSIGNED);
                int bPick1_Complete = WR_GetPlotFlag(PLT_DEN200PT_THIEF_PICK1, THIEF_PICK1_SUCCESSFUL);
                int bPick2_Assigned = WR_GetPlotFlag(PLT_DEN200PT_THIEF_PICK2, THIEF_PICK2_ASSIGNED);
                int bPick2_Complete = WR_GetPlotFlag(PLT_DEN200PT_THIEF_PICK2, THIEF_PICK2_SUCCESSFUL);
                int bPick3_Assigned = WR_GetPlotFlag(PLT_DEN200PT_THIEF_PICK3, THIEF_PICK3_ASSIGNED);
                int bPick3_Complete = WR_GetPlotFlag(PLT_DEN200PT_THIEF_PICK3, THIEF_PICK3_SUCCESSFUL);
                int bPick4_Assigned = WR_GetPlotFlag(PLT_DEN200PT_THIEF_PICK4, THIEF_PICK4_ASSIGNED);
                int bPick4_Available = !WR_GetPlotFlag(PLT_DEN200PT_THIEF, COULDRY_NOT_READY_FOR_FINAL_PICK);
                int bPick4_Complete = WR_GetPlotFlag(PLT_DEN200PT_THIEF_PICK4, THIEF_PICK4_SUCCESSFUL);

                // If the PC is not a Pickpocket Player, then no quests available
                if ( !bPC_is_Pick )
                {
                    nResult = FALSE;
                    break;
                }

                // Otherwise, check what's where
                if ( !bPick1_Assigned ) nResult = TRUE;
                if ( bPick1_Complete && !bPick2_Assigned ) nResult = TRUE;
                if ( bPick2_Complete && !bPick3_Assigned ) nResult = TRUE;
                if ( bPick3_Complete && !bPick4_Assigned && bPick4_Available ) nResult = TRUE;

                break;

            }

            case THIEF_PC_CAN_DO_STEAL_AND_STEALTH:
            {

                int bCondition1 =   GetHasSkill(SKILL_STEALING, 1, oPC);
                int bCondition2 =   GetHasSkill(SKILL_STEALTH, 1, oPC);

                nResult = bCondition1 && bCondition2;

                break;

            }



        }

    }

    plot_OutputDefinedFlag(eParms, nResult);

    return nResult;
}