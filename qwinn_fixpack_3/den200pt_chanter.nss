//:://////////////////////////////////////////////
//:: den200pt_chanter
//:: Copyright (c) 2008 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Plot events
*/
//:://////////////////////////////////////////////
//:: Created By: Ferret
//:: Created On: May 1st, 2008
//:://////////////////////////////////////////////

#include "log_h"
#include "utility_h"
//this is included in achievement_core_h; #include "wrappers_h"
#include "lit_functions_h"

#include "den_constants_h"
#include "plt_den200pt_chanter"



#include "achievement_core_h"
#include "plt_lot100pt_chanter"


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

    object oTarg;

    plot_GlobalPlotHandler(eParms); // any global plot operations, including debug info

    if(nType == EVENT_TYPE_SET_PLOT) // actions -> normal flags only
    {
        int nValue = GetEventInteger(eParms, 2);        // On SET call, the value about to be written (on a normal SET that should be '1', and on a 'clear' it should be '0')
        int nOldValue = GetEventInteger(eParms, 3);     // On SET call, the current flag value (can be either 1 or 0 regardless if it's a set or clear event)
        // IMPORTANT: The flag value on a SET event is set only AFTER this script finishes running!
        switch(nFlag)
        {
            case CHANTER_CHECK_ALL_QUESTS_ACCEPTED:
            {
                // Check to see if all of the Chanter quests have been accepted
                int nCounter;
                if ( WR_GetPlotFlag(PLT_DEN200PT_ALLEY_JUSTICE, ALLEY_ACCEPTED) ) nCounter++;
                if ( WR_GetPlotFlag(PLT_DEN200PT_FAZZIL_REQUEST, FAZZIL_ACCEPTED) ) nCounter++;
                if ( WR_GetPlotFlag(PLT_DEN200PT_MIA, MIA_ACCEPTED) ) nCounter++;

                if ( WR_GetPlotFlag(PLT_LITE_CHANT_RAND_CIVIL, CIVIL_PLOT_ACCEPTED) ) nCounter++;
                if ( WR_GetPlotFlag(PLT_LITE_CHANT_RAND_FEED, FEED_PLOT_ACCEPTED) ) nCounter++;
                if ( WR_GetPlotFlag(PLT_LITE_CHANT_RAND_JOWAN, JOWAN_PLOT_ACCEPTED) ) nCounter++;
                if ( WR_GetPlotFlag(PLT_LITE_CHANT_RAND_REFUGEE, REFUGEE_PLOT_ACCEPTED) ) nCounter++;
                if ( WR_GetPlotFlag(PLT_LITE_CHANT_RAND_REMAINS, REMAINS_PLOT_ACCEPTED) ) nCounter++;
                if ( WR_GetPlotFlag(PLT_LITE_CHANT_RED_ZOMBIE, RED_ZOMBIE_ACCEPTED) ) nCounter++;
                if ( WR_GetPlotFlag(PLT_LITE_CHANT_TOW_TRICK, TOW_TRICKSTER_ACCEPTED) ) nCounter++;
                // If all the quests have been accepted
                if ( nCounter >= 10 )
                {
                    // Set up sideplot quest giver status
                    oTarg = UT_GetNearestObjectByTag(oPC, DEN_IP_CHANTERS_BOARD);
                    SetPlotGiver(oTarg, FALSE);
                }
                break;
            }

            case CHANTER_REWARD_PC:                 // DEN200_CHANTER_DENERIM
                                                    // Reward the PC for any quests that have been completed
            {
                // Qwinn: Turned all ifs to else ifs to make turn ins one at a time.

                // Close Alley Justice quest if it's ready
                if ( WR_GetPlotFlag(PLT_DEN200PT_ALLEY_JUSTICE, ALLEY_ALL_BAD_GUYS_KILLED) &&
                        !WR_GetPlotFlag(PLT_DEN200PT_ALLEY_JUSTICE, ALLEY_QUEST_DONE))
                {
                    WR_SetPlotFlag(PLT_DEN200PT_ALLEY_JUSTICE, ALLEY_QUEST_DONE, TRUE, TRUE);
                    if(!GetHasAchievementByID(ACH_COLLECT_MERCENARY)) ACH_MercAchievement(oPC);
                }

                // Close Fazzil's Request if it's ready
                else if ( WR_GetPlotFlag(PLT_DEN200PT_FAZZIL_REQUEST, FAZZIL_SEXTANT_RECOVERED) &&
                        WR_GetPlotFlag(PLT_DEN200PT_FAZZIL_REQUEST, FAZZIL_ACCEPTED) &&
                        !WR_GetPlotFlag(PLT_DEN200PT_FAZZIL_REQUEST, FAZZIL_QUEST_DONE))
                {
                    WR_SetPlotFlag(PLT_DEN200PT_FAZZIL_REQUEST, FAZZIL_QUEST_DONE, TRUE, TRUE);
                    if(!GetHasAchievementByID(ACH_COLLECT_MERCENARY)) ACH_MercAchievement(oPC);
                }

                // Close MIA if it's ready
                else if ( WR_GetPlotFlag(PLT_DEN200PT_MIA, MIA_REXEL_FOUND) &&
                        !WR_GetPlotFlag(PLT_DEN200PT_MIA, MIA_QUEST_DONE))
                {
                    WR_SetPlotFlag(PLT_DEN200PT_MIA, MIA_QUEST_DONE, TRUE, TRUE);
                    if(!GetHasAchievementByID(ACH_COLLECT_MERCENARY)) ACH_MercAchievement(oPC);
                }
                //chant rand civil
                else if ( WR_GetPlotFlag(PLT_LITE_CHANT_RAND_CIVIL, CIVIL_PLOT_COMPLETED) == TRUE &&
                     WR_GetPlotFlag(PLT_LITE_CHANT_RAND_CIVIL, CIVIL_PLOT_CLOSED) == FALSE)
                {
                    WR_SetPlotFlag(PLT_LITE_CHANT_RAND_CIVIL, CIVIL_PLOT_CLOSED, TRUE, TRUE);
                    if(!GetHasAchievementByID(ACH_COLLECT_MERCENARY)) ACH_MercAchievement(oPC);
                }
                //chant rand feed
                else if ( WR_GetPlotFlag(PLT_LITE_CHANT_RAND_FEED, FEED_PLOT_COMPLETED) == TRUE &&
                     WR_GetPlotFlag(PLT_LITE_CHANT_RAND_FEED, FEED_PLOT_CLOSED) == FALSE)
                {
                    WR_SetPlotFlag(PLT_LITE_CHANT_RAND_FEED, FEED_PLOT_CLOSED, TRUE, TRUE);
                    if(!GetHasAchievementByID(ACH_COLLECT_MERCENARY)) ACH_MercAchievement(oPC);
                }
                //chant rand jowan
                else if ( (WR_GetPlotFlag(PLT_LITE_CHANT_RAND_JOWAN, JOWAN_PLOT_COMPLETED) == TRUE || WR_GetPlotFlag(PLT_LITE_CHANT_RAND_JOWAN, JOWAN_PLOT_COMPLETED_DEAD) == TRUE) &&
                     WR_GetPlotFlag(PLT_LITE_CHANT_RAND_JOWAN, JOWAN_PLOT_CLOSED) == FALSE)
                {
                    WR_SetPlotFlag(PLT_LITE_CHANT_RAND_JOWAN, JOWAN_PLOT_CLOSED, TRUE, TRUE);
                    if(!GetHasAchievementByID(ACH_COLLECT_MERCENARY)) ACH_MercAchievement(oPC);
                }
                //chant rand refugee
                else if ( (WR_GetPlotFlag(PLT_LITE_CHANT_RAND_REFUGEE, REFUGEE_PLOT_COMPLETED) == TRUE || WR_GetPlotFlag(PLT_LITE_CHANT_RAND_REFUGEE, REFUGEE_PLOT_COMPLETED_DEAD) == TRUE) &&
                     WR_GetPlotFlag(PLT_LITE_CHANT_RAND_REFUGEE, REFUGEE_PLOT_CLOSED) == FALSE)
                {
                    WR_SetPlotFlag(PLT_LITE_CHANT_RAND_REFUGEE, REFUGEE_PLOT_CLOSED, TRUE, TRUE);
                    if(!GetHasAchievementByID(ACH_COLLECT_MERCENARY)) ACH_MercAchievement(oPC);
                }
                //chant rand remains
                else if ( WR_GetPlotFlag(PLT_LITE_CHANT_RAND_REMAINS, REMAINS_PLOT_COMPLETED) == TRUE &&
                     WR_GetPlotFlag(PLT_LITE_CHANT_RAND_REMAINS, REMAINS_PLOT_CLOSED) == FALSE)
                {
                    WR_SetPlotFlag(PLT_LITE_CHANT_RAND_REMAINS, REMAINS_PLOT_CLOSED, TRUE, TRUE);
                    if(!GetHasAchievementByID(ACH_COLLECT_MERCENARY)) ACH_MercAchievement(oPC);
                }

                //chant red zombie - can be closed with either 9 or 18
                else if ( WR_GetPlotFlag(PLT_LITE_CHANT_RED_ZOMBIE, RED_ZOMBIE_COMPLETE_WITH_18) == TRUE &&
                     WR_GetPlotFlag(PLT_LITE_CHANT_RED_ZOMBIE, RED_ZOMBIE_CLOSED_WITH_18) == FALSE &&
                     WR_GetPlotFlag(PLT_LITE_CHANT_RED_ZOMBIE, RED_ZOMBIE_CLOSED_WITH_9) == FALSE)
                {
                    WR_SetPlotFlag(PLT_LITE_CHANT_RED_ZOMBIE, RED_ZOMBIE_CLOSED_WITH_18, TRUE, TRUE);
                    if(!GetHasAchievementByID(ACH_COLLECT_MERCENARY)) ACH_MercAchievement(oPC);
                }
                else if ( WR_GetPlotFlag(PLT_LITE_CHANT_RED_ZOMBIE, RED_ZOMBIE_COMPLETE_WITH_9) == TRUE &&
                     WR_GetPlotFlag(PLT_LITE_CHANT_RED_ZOMBIE, RED_ZOMBIE_CLOSED_WITH_18) == FALSE &&
                     WR_GetPlotFlag(PLT_LITE_CHANT_RED_ZOMBIE, RED_ZOMBIE_CLOSED_WITH_9) == FALSE)
                {
                    WR_SetPlotFlag(PLT_LITE_CHANT_RED_ZOMBIE, RED_ZOMBIE_CLOSED_WITH_9, TRUE, TRUE);
                    if(!GetHasAchievementByID(ACH_COLLECT_MERCENARY)) ACH_MercAchievement(oPC);
                }
                //chant tow trickster whim
                else if (WR_GetPlotFlag(PLT_LITE_CHANT_TOW_TRICK, TOW_TRICKSTER_COMPLETE) == TRUE &&
                    WR_GetPlotFlag(PLT_LITE_CHANT_TOW_TRICK, TOW_TRICKSTER_CLOSED) == FALSE)
                {
                    WR_SetPlotFlag(PLT_LITE_CHANT_TOW_TRICK, TOW_TRICKSTER_CLOSED, TRUE, TRUE);
                    if(!GetHasAchievementByID(ACH_COLLECT_MERCENARY)) ACH_MercAchievement(oPC);
                }

                if ((ChanterTurnInPossible() == FALSE) &&
                   !(WR_GetPlotFlag(PLT_DEN200PT_CHANTER, CHANTER_BOARD_QUESTS_ALL_DONE) &&
                     WR_GetPlotFlag(PLT_DEN200PT_CHANTER, CHANTER_BIG_REWARD_PC) == FALSE))

                {
                   //deactivate plot giver
                   if (GetTag(GetArea(oPC)) == "den200ar_market")
                   {
                       object oDenChanter = UT_GetNearestCreatureByTag(oPC, "den200cr_chanter_denerim");
                       SetPlotGiver(oDenChanter, FALSE);
                   }
                   else if (GetTag(GetArea(oPC)) == "arl100ar_redcliffe_village")
                   {
                       object oArlChanter = UT_GetNearestCreatureByTag(oPC, "arl100cr_chanter_redcliffe");
                       SetPlotGiver(oArlChanter, FALSE);
                   }
                }

                ACH_PilgrimAchievement();
            }
            break;

            case CHANTER_BIG_REWARD_PC:             // Make sure to close off all quests that were complete
                                                    // when the Chanter was visited.
            {
                // Qwinn:  Eliminating this.  Since we're turning in one at a time now, and
                // the all quest done conditions below are now set to only return true if all
                // quests have been rewarded, this isn't necessary.  And it only addresses
                // the 3 quests that don't need to be addressed anyway.

                /*
                if ( WR_GetPlotFlag(PLT_DEN200PT_ALLEY_JUSTICE, ALLEY_QUEST_DONE) == FALSE &&
                        WR_GetPlotFlag(PLT_DEN200PT_ALLEY_JUSTICE, ALLEY_ALL_BAD_GUYS_KILLED) == TRUE )
                {
                    WR_SetPlotFlag(PLT_DEN200PT_ALLEY_JUSTICE, ALLEY_QUEST_DONE, TRUE, TRUE);
                }

                if ( WR_GetPlotFlag(PLT_DEN200PT_FAZZIL_REQUEST, FAZZIL_QUEST_DONE) == FALSE &&
                        WR_GetPlotFlag(PLT_DEN200PT_FAZZIL_REQUEST, FAZZIL_SEXTANT_RECOVERED) == TRUE )
                {
                    WR_SetPlotFlag(PLT_DEN200PT_FAZZIL_REQUEST, FAZZIL_QUEST_DONE, TRUE, TRUE);
                }

                if ( WR_GetPlotFlag(PLT_DEN200PT_MIA, MIA_QUEST_DONE) == FALSE &&
                        WR_GetPlotFlag(PLT_DEN200PT_MIA, MIA_REXEL_FOUND) == TRUE)
                {
                    WR_SetPlotFlag(PLT_DEN200PT_MIA, MIA_QUEST_DONE, TRUE, TRUE);
                }*/
                
                // We do want to turn the plot flag off though, for good.
                if (GetTag(GetArea(oPC)) == "den200ar_market")
                {
                    object oDenChanter = UT_GetNearestCreatureByTag(oPC, "den200cr_chanter_denerim");
                    SetPlotGiver(oDenChanter, FALSE);
                }
                else if (GetTag(GetArea(oPC)) == "arl100ar_redcliffe_village")
                {
                    object oArlChanter = UT_GetNearestCreatureByTag(oPC, "arl100cr_chanter_redcliffe");
                    SetPlotGiver(oArlChanter, FALSE);
                }                
                break;
            }

            case ZZ_SETUP_FOR_QUEST_TURN_IN:
            {
                WR_SetPlotFlag(PLT_DEN200PT_ALLEY_JUSTICE, ALLEY_ALL_BAD_GUYS_KILLED, TRUE, TRUE);
                WR_SetPlotFlag(PLT_DEN200PT_FAZZIL_REQUEST, FAZZIL_SEXTANT_RECOVERED, TRUE, TRUE);
                WR_SetPlotFlag(PLT_DEN200PT_MIA, MIA_REXEL_FOUND, TRUE, TRUE);
            }
            break;

        }
     }
     else // EVENT_TYPE_GET_PLOT -> defined conditions only
     {

        switch(nFlag)
        {

            case CHANTER_HAS_QUESTS_TO_TURN_IN:     // DEN200_CHANTER_DENERIM
                                                    // Checks to see if any of the Chanter's board quests
                                                    // are pending a reward.
            {

                // Alley Justice bad guys cleared AND the quest hasn't been turned in already
                if ( WR_GetPlotFlag(PLT_DEN200PT_ALLEY_JUSTICE, ALLEY_ALL_BAD_GUYS_KILLED) == TRUE &&
                        WR_GetPlotFlag(PLT_DEN200PT_ALLEY_JUSTICE, ALLEY_QUEST_DONE) == FALSE)
                {
                    nResult = TRUE;
                }

                // Fazzil's sextant has been found AND the quest hasn't been turned in already
                if ( WR_GetPlotFlag(PLT_DEN200PT_FAZZIL_REQUEST, FAZZIL_SEXTANT_RECOVERED) == TRUE &&
                        WR_GetPlotFlag(PLT_DEN200PT_FAZZIL_REQUEST, FAZZIL_ACCEPTED) == TRUE &&
                        WR_GetPlotFlag(PLT_DEN200PT_FAZZIL_REQUEST, FAZZIL_QUEST_DONE) == FALSE)
                {
                    nResult = TRUE;
                }

                // Rexel has been found AND the quest hasn't been turned in already
                if ( WR_GetPlotFlag(PLT_DEN200PT_MIA, MIA_REXEL_FOUND) == TRUE &&
                        WR_GetPlotFlag(PLT_DEN200PT_MIA, MIA_QUEST_DONE) == FALSE)
                {
                    nResult = TRUE;
                }
                //chant rand civil
                if ( WR_GetPlotFlag(PLT_LITE_CHANT_RAND_CIVIL, CIVIL_PLOT_COMPLETED) == TRUE &&
                     WR_GetPlotFlag(PLT_LITE_CHANT_RAND_CIVIL, CIVIL_PLOT_CLOSED) == FALSE)
                {
                    nResult = TRUE;
                }
                //chant rand feed
                if ( WR_GetPlotFlag(PLT_LITE_CHANT_RAND_FEED, FEED_PLOT_COMPLETED) == TRUE &&
                     WR_GetPlotFlag(PLT_LITE_CHANT_RAND_FEED, FEED_PLOT_CLOSED) == FALSE)
                {
                    nResult = TRUE;
                }
                //chant rand jowan
                if ( (WR_GetPlotFlag(PLT_LITE_CHANT_RAND_JOWAN, JOWAN_PLOT_COMPLETED) == TRUE || WR_GetPlotFlag(PLT_LITE_CHANT_RAND_JOWAN, JOWAN_PLOT_COMPLETED_DEAD) == TRUE) &&
                     WR_GetPlotFlag(PLT_LITE_CHANT_RAND_JOWAN, JOWAN_PLOT_CLOSED) == FALSE)
                {
                    nResult = TRUE;
                }
                //chant rand refugee
                if ( (WR_GetPlotFlag(PLT_LITE_CHANT_RAND_REFUGEE, REFUGEE_PLOT_COMPLETED) == TRUE || WR_GetPlotFlag(PLT_LITE_CHANT_RAND_REFUGEE, REFUGEE_PLOT_COMPLETED_DEAD) == TRUE) &&
                     WR_GetPlotFlag(PLT_LITE_CHANT_RAND_REFUGEE, REFUGEE_PLOT_CLOSED) == FALSE)
                {
                    nResult = TRUE;
                }
                //chant rand remains
                if ( WR_GetPlotFlag(PLT_LITE_CHANT_RAND_REMAINS, REMAINS_PLOT_COMPLETED) == TRUE &&
                     WR_GetPlotFlag(PLT_LITE_CHANT_RAND_REMAINS, REMAINS_PLOT_CLOSED) == FALSE)
                {
                    nResult = TRUE;
                }
                //chant red zombie - can be closed with either 9 or 18
                if ( WR_GetPlotFlag(PLT_LITE_CHANT_RED_ZOMBIE, RED_ZOMBIE_COMPLETE_WITH_18) == TRUE &&
                     WR_GetPlotFlag(PLT_LITE_CHANT_RED_ZOMBIE, RED_ZOMBIE_CLOSED_WITH_18) == FALSE &&
                     WR_GetPlotFlag(PLT_LITE_CHANT_RED_ZOMBIE, RED_ZOMBIE_CLOSED_WITH_9) == FALSE)
                {
                    nResult = TRUE;
                }
                else if ( WR_GetPlotFlag(PLT_LITE_CHANT_RED_ZOMBIE, RED_ZOMBIE_COMPLETE_WITH_9) == TRUE &&
                     WR_GetPlotFlag(PLT_LITE_CHANT_RED_ZOMBIE, RED_ZOMBIE_CLOSED_WITH_18) == FALSE &&
                     WR_GetPlotFlag(PLT_LITE_CHANT_RED_ZOMBIE, RED_ZOMBIE_CLOSED_WITH_9) == FALSE)
                {
                    nResult = TRUE;
                }
                //chant tow trickster whim
                if (WR_GetPlotFlag(PLT_LITE_CHANT_TOW_TRICK, TOW_TRICKSTER_COMPLETE) == TRUE &&
                    WR_GetPlotFlag(PLT_LITE_CHANT_TOW_TRICK, TOW_TRICKSTER_CLOSED) == FALSE)
                {
                    nResult = TRUE;
                }
                break;
            }

            case CHANTER_BOARD_QUESTS_ALL_DONE:     // DEN200_CHANTER_DENERIM
                                                    // Checks to see if all of the Chanter's board quests are
                                                    // complete.
            {
                // Check to see if each board quest has been completed.

                // Qwinn:  The first 3 with "DONE" mean the reward was given out, but the COMPLETEs can
                // be true before the reward is given out (CLOSED).  I don't want the bonus reward for completing
                // all 10 to be available until the 10 have actually been rewarded.  So changing
                // the completes to closed.
                if ( WR_GetPlotFlag(PLT_DEN200PT_ALLEY_JUSTICE, ALLEY_QUEST_DONE) == TRUE &&
                     WR_GetPlotFlag(PLT_DEN200PT_FAZZIL_REQUEST, FAZZIL_QUEST_DONE) == TRUE &&
                     WR_GetPlotFlag(PLT_DEN200PT_MIA, MIA_QUEST_DONE) == TRUE &&
                     /*
                     WR_GetPlotFlag(PLT_LITE_CHANT_RAND_CIVIL, CIVIL_PLOT_COMPLETED) == TRUE &&
                     WR_GetPlotFlag(PLT_LITE_CHANT_RAND_FEED, FEED_PLOT_COMPLETED) == TRUE &&
                     WR_GetPlotFlag(PLT_LITE_CHANT_RAND_JOWAN, JOWAN_PLOT_COMPLETED) == TRUE &&
                     WR_GetPlotFlag(PLT_LITE_CHANT_RAND_REFUGEE, REFUGEE_PLOT_COMPLETED) == TRUE &&
                     WR_GetPlotFlag(PLT_LITE_CHANT_RAND_REMAINS, REMAINS_PLOT_COMPLETED) == TRUE &&
                     (WR_GetPlotFlag(PLT_LITE_CHANT_RED_ZOMBIE, RED_ZOMBIE_COMPLETE_WITH_18) == TRUE || WR_GetPlotFlag(PLT_LITE_CHANT_RED_ZOMBIE, RED_ZOMBIE_COMPLETE_WITH_9) == TRUE) &&
                     WR_GetPlotFlag(PLT_LITE_CHANT_TOW_TRICK, TOW_TRICKSTER_COMPLETE) == TRUE)
                     */
                     WR_GetPlotFlag(PLT_LITE_CHANT_RAND_CIVIL, CIVIL_PLOT_CLOSED) == TRUE &&
                     WR_GetPlotFlag(PLT_LITE_CHANT_RAND_FEED, FEED_PLOT_CLOSED) == TRUE &&
                     WR_GetPlotFlag(PLT_LITE_CHANT_RAND_JOWAN, JOWAN_PLOT_CLOSED) == TRUE &&
                     WR_GetPlotFlag(PLT_LITE_CHANT_RAND_REFUGEE, REFUGEE_PLOT_CLOSED) == TRUE &&
                     WR_GetPlotFlag(PLT_LITE_CHANT_RAND_REMAINS, REMAINS_PLOT_CLOSED) == TRUE &&
                     (WR_GetPlotFlag(PLT_LITE_CHANT_RED_ZOMBIE, RED_ZOMBIE_CLOSED_WITH_18) == TRUE || WR_GetPlotFlag(PLT_LITE_CHANT_RED_ZOMBIE, RED_ZOMBIE_CLOSED_WITH_9) == TRUE) &&
                     WR_GetPlotFlag(PLT_LITE_CHANT_TOW_TRICK, TOW_TRICKSTER_CLOSED) == TRUE)

                {
                    // Since you've done all the quests, the result is TRUE
                    nResult = TRUE;
                }
                break;
            }


        }

    }

    plot_OutputDefinedFlag(eParms, nResult);

    return nResult;
}