//==============================================================================
/*
    den200pt_thief_pick2.nss
    The fourth and final quest in the pickpocket series of plots from
    "Slim" Couldry.
*/
//==============================================================================
//  Created By: Ferret
//  Created On: June 24th, 2008
//==============================================================================

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "plot_h"

#include "campaign_h"
#include "den_constants_h"

#include "plt_gen00pt_skills"
#include "plt_den200pt_thief"
#include "plt_den200pt_thief_pick4"

// Qwinn added these two to stop unconscious guards from waking up
#include "sys_ambient_h"
#include "plt_gen00pt_ambient_ai"
// Qwinn added to assign Stealing Infamy if you kill the guards.
#include "plt_gen00pt_stealing"

//------------------------------------------------------------------------------

int StartingConditional()
{
    event   eParms              = GetCurrentEvent();                // Contains all input parameters

    int     nType               = GetEventType(eParms);             // GET or SET call
    int     nFlag               = GetEventInteger(eParms, 1);       // The bit flag # being affected
    int     nResult             = FALSE;                            // used to return value for DEFINED GET events

    string  strPlot             = GetEventString(eParms, 0);        // Plot GUID

    object  oParty              = GetEventCreator(eParms);          // The owner of the plot table for this script
    object  oConversationOwner  = GetEventObject(eParms, 0);        // Owner on the conversation, if any

    object  oPC                 = GetHero();
    object  oTarg;

    plot_GlobalPlotHandler(eParms);                                 // any global plot operations, including debug info

    if(nType == EVENT_TYPE_SET_PLOT)    // actions -> normal flags only
    {
        int nValue      =   GetEventInteger(eParms, 2);             // On SET call, the value about to be written (on a normal SET that should be '1', and on a 'clear' it should be '0')
        int nOldValue   =   GetEventInteger(eParms, 3);             // On SET call, the current flag value (can be either 1 or 0 regardless if it's a set or clear event)

        // IMPORTANT: The flag value on a SET event is set only AFTER this script finishes running!
        switch(nFlag)
        {

            case THIEF_PICK4_ASSIGNED:              // DEN200_COULDRY
                                                    // You're given the mission
            {
                WR_SetPlotFlag(PLT_DEN200PT_THIEF, THIEF_PICKPOCKET_ACTIVE, TRUE, TRUE);

                // See if you should toggle quest giver notification
                if ( !WR_GetPlotFlag(PLT_DEN200PT_THIEF, THIEF_CHECK_IF_SNEAK_AVAILABLE) )
                {
                    object oTarg = UT_GetNearestCreatureByTag(oPC, DEN_CR_COULDRY);
                    SetPlotGiver(oTarg, FALSE);
                }
                break;
            }

            case THIEF_PICK4_TAKE_FEE:              // DEN200_COULDRY
                                                    // He takes your money
            {
                // Remove the required fee of 6 gold from the PC.
                UT_MoneyTakeFromObject(oPC, 0, 0, 6);

                break;
            }

            case THIEF_PICK4_SETUP_TAVERN:          // Run on area load of the Gnawed Noble tavern
                                                    // Sets up the side room properly
            {
                // Bring in the seneshal's group
                UT_TeamAppears(DEN_TEAM_PICK4_SENESHAL);

                // Were the Crimson Oars still in the bar? Important for undoing the setup
                oTarg = UT_GetNearestCreatureByTag(oPC, DEN_CR_CRIMSON_OAR_LEADER);
                if ( GetObjectActive(oTarg) )
                    WR_SetPlotFlag(PLT_DEN200PT_THIEF_PICK4, CRIMSON_OARS_WERE_ACTIVE, TRUE, TRUE);

                // Turn off the Crimson Oars
                UT_TeamAppears(DEN_TEAM_CRIMSON_OARS, FALSE);

                // Turn off Edwina
                oTarg = UT_GetNearestCreatureByTag(oPC, DEN_CR_EDWINA);
                WR_SetObjectActive(oTarg, FALSE);
                break;
            }

            case THIEF_PICK4_CLEANUP_TAVERN:        // Run on area load of the Gnawed Noble tavern
                                                    // Cleans up the quest after it's done
            {
                // Remove the Seneshal's group
                UT_TeamAppears(DEN_TEAM_PICK4_SENESHAL, FALSE);

                // If the Crimson Oars were active, bring them back
                if ( WR_GetPlotFlag(PLT_DEN200PT_THIEF_PICK4, CRIMSON_OARS_WERE_ACTIVE) )
                    UT_TeamAppears(DEN_TEAM_CRIMSON_OARS);

                // Bring back Edwina
                oTarg = UT_GetNearestCreatureByTag(oPC, DEN_CR_EDWINA);
                WR_SetObjectActive(oTarg, TRUE);

                // Qwinn: Set waitresses walking again
                oTarg = UT_GetNearestCreatureByTag(oPC, "den220cr_waitress_1");
                SetLocalInt(oTarg,AMBIENT_ANIM_PATTERN,0);
                SetLocalInt(oTarg,AMBIENT_MOVE_PATTERN,4);
                Ambient_Start(oTarg);
                oTarg = UT_GetNearestCreatureByTag(oPC, "den220cr_waitress_2");
                SetLocalInt(oTarg,AMBIENT_ANIM_PATTERN,0);
                SetLocalInt(oTarg,AMBIENT_MOVE_PATTERN,4);
                Ambient_Start(oTarg);
                oTarg = UT_GetNearestCreatureByTag(oPC, "den220cr_waitress_3");
                SetLocalInt(oTarg,AMBIENT_ANIM_PATTERN,0);
                SetLocalInt(oTarg,AMBIENT_MOVE_PATTERN,4);
                SetLocalFloat(oTarg,AMBIENT_ANIM_FREQ,-1.0);
                Ambient_Start(oTarg);

                break;
            }

            case GUARDS_ATTACKED:                   // DEN200_PICK4_SENESHAL_GRD
                                                    // The guards attack
            {
                UT_TeamGoesHostile(DEN_TEAM_PICK4_SENESHAL);

                // Lock the side door so combat doesn't spill out into the tavern proper
                oTarg = GetObjectByTag(DEN_IP_GNAWED_SIDE_DOOR);
                SetPlaceableState(oTarg, PLC_STATE_DOOR_LOCKED);

                UT_LocalJump(oPC, "den220wp_seneschal_grds_attacked", TRUE, FALSE, TRUE, TRUE);

                break;
            }

            case GUARDS_KNOCKED_UNCONSCIOUS:        // The guards and seneschal are all knocked out
            {
                object [] oTeam = UT_GetTeam(DEN_TEAM_PICK4_SENESHAL);
                int nTeamSize = GetArraySize(oTeam);
                int nCount;

                // Qwinn
                // command cUnconscious = CommandPlayAnimation(BASE_ANIMATION_DEAD_1);
                command cUnconscious = CommandPlayAnimation(943);
                command cLying     = CommandPlayAnimation(952);
                command cLyingKnee = CommandPlayAnimation(949);
                command cSleep     = CommandPlayAnimation(619);

                command cFaceNorth   = CommandTurn(DIRECTION_NORTH);
                command cFaceWest    = CommandTurn(DIRECTION_WEST);
                command cFaceEast    = CommandTurn(DIRECTION_EAST);

                for ( nCount = 0; nCount < nTeamSize; nCount++ )
                {
                    oTarg = oTeam[nCount];
                    //Qwinn: Stop ambients, otherwise they get right back up
                    Ambient_Stop(oTarg);
                }
                
                oTarg = UT_GetNearestCreatureByTag(oPC, "den220cr_pick4_seneshal");
                WR_AddCommand(oTarg, cUnconscious, TRUE, TRUE);
                oTarg = UT_GetNearestCreatureByTag(oPC, "den220cr_pick4_seneshal_grd");
                WR_AddCommand(oTarg, cFaceWest, FALSE, TRUE);
                WR_AddCommand(oTarg, cSleep, FALSE, TRUE);
                oTarg = UT_GetNearestCreatureByTag(oPC, "den220cr_pick4_sen_grd1");
                WR_AddCommand(oTarg, cLying, FALSE, TRUE);
                oTarg = UT_GetNearestCreatureByTag(oPC, "den220cr_pick4_sen_grd2");
                WR_AddCommand(oTarg, cFaceEast, FALSE, TRUE);
                WR_AddCommand(oTarg, cUnconscious, FALSE, TRUE);
                oTarg = UT_GetNearestCreatureByTag(oPC, "den220cr_pick4_sen_grd3");
                WR_AddCommand(oTarg, cFaceNorth, FALSE, TRUE);
                WR_AddCommand(oTarg, cLyingKnee, FALSE, TRUE);
                oTarg = UT_GetNearestCreatureByTag(oPC, "den220cr_pick4_sen_grd4");
                WR_AddCommand(oTarg, cFaceNorth, FALSE, TRUE);
                WR_AddCommand(oTarg, cLyingKnee, FALSE, TRUE);


                break;
            }

            case GUARDS_KILLED:                     // The guards are all killed
            {
                // Now unlock the side door
                oTarg = GetObjectByTag(DEN_IP_GNAWED_SIDE_DOOR);
                SetPlaceableState(oTarg, PLC_STATE_DOOR_UNLOCKED);
                WR_SetPlotFlag(PLT_GEN00PT_STEALING,STEALING_DEN_INFAMY,TRUE,TRUE);
                break;
            }

            //Qwinn added
            case GUARDS_DISTRACTED_BY_WAITRESS:
            {
                oTarg = UT_GetNearestCreatureByTag(oPC, "den220cr_waitress_1");
                Ambient_Stop(oTarg);
                oTarg = UT_GetNearestCreatureByTag(oPC, "den220cr_waitress_2");
                Ambient_Stop(oTarg);
                oTarg = UT_GetNearestCreatureByTag(oPC, "den220cr_waitress_3");
                Ambient_Stop(oTarg);
                break;
            }

            case STAGE_WAITRESS_DISTRACTION:
            {
                oTarg = UT_GetNearestCreatureByTag(oPC, "den220cr_waitress_1");
                SetLocalInt(oTarg,AMBIENT_MOVE_PATTERN,0);
                SetLocalInt(oTarg,AMBIENT_ANIM_PATTERN,12);
                Ambient_Start(oTarg);
                oTarg = UT_GetNearestCreatureByTag(oPC, "den220cr_waitress_2");
                SetLocalInt(oTarg,AMBIENT_MOVE_PATTERN,0);
                SetLocalInt(oTarg,AMBIENT_ANIM_PATTERN,10);
                Ambient_Start(oTarg);
                oTarg = UT_GetNearestCreatureByTag(oPC, "den220cr_waitress_3");
                SetLocalInt(oTarg,AMBIENT_MOVE_PATTERN,0);
                SetLocalInt(oTarg,AMBIENT_ANIM_PATTERN,13);
                SetLocalFloat(oTarg,AMBIENT_ANIM_FREQ,8.15);
                Ambient_Start(oTarg);

                oTarg = UT_GetNearestCreatureByTag(oPC, "den220cr_pick4_seneshal");
                command cWarmHands = CommandPlayAnimation(971);
                WR_AddCommand(oTarg, cWarmHands);
                break;
            }


            //Qwinn added
            case GUARDS_REFUSE_WAITRESS:
            {
                oTarg = UT_GetNearestCreatureByTag(oPC, "den220cr_waitress_1");
                Ambient_Start(oTarg);
                oTarg = UT_GetNearestCreatureByTag(oPC, "den220cr_waitress_2");
                Ambient_Start(oTarg);
                oTarg = UT_GetNearestCreatureByTag(oPC, "den220cr_waitress_3");
                Ambient_Start(oTarg);
                break;
            }

            //Qwinn added
            case GUARDS_FLEE:
            {
                object [] oTeam = UT_GetTeam(DEN_TEAM_PICK4_SENESHAL);
                int nTeamSize = GetArraySize(oTeam);
                int nCount;

                for ( nCount = 0; nCount < nTeamSize; nCount++ )
                {
                    oTarg = oTeam[nCount];
                    if(GetTag(oTarg) == "den220cr_pick4_seneshal")
                    {
                        Ambient_Stop(oTarg);
                    }
                    else
                    {
                        SetTeamId(oTarg, -1);
                        SetObjectInteractive(oTarg,FALSE);
                        UT_ExitDestroy(oTarg,TRUE);
                    }
                }
                break;
            }

            //Qwinn added
            case SENESHAL_FLEES:
            {
                oTarg = UT_GetNearestCreatureByTag(oPC, "den220cr_pick4_seneshal");
                SetObjectInteractive(oTarg,FALSE);
                UT_ExitDestroy(oTarg,TRUE);
                break;
            }

            case GUARDS_ARE_DRUNK:
            {
                object [] oTeam = UT_GetTeam(DEN_TEAM_PICK4_SENESHAL);
                int nTeamSize = GetArraySize(oTeam);
                int nCount;

                for ( nCount = 0; nCount < nTeamSize; nCount++ )
                {
                    oTarg = oTeam[nCount];
                    //Qwinn: Stop ambients, otherwise they get right back up
                    Ambient_Stop(oTarg);
                }


                command cFaceNorth   = CommandTurn(DIRECTION_NORTH);
                command cFaceWest    = CommandTurn(DIRECTION_WEST);
                command cFaceEast    = CommandTurn(DIRECTION_EAST);
                command cFaceSouth    = CommandTurn(DIRECTION_SOUTH);


                command cDyingSoldier = CommandPlayAnimation(942);
                command cLyingKnee = CommandPlayAnimation(949);
                command cSitGroundTwitch = CommandPlayAnimation(922);
                command cSitDying = CommandPlayAnimation(605);
                command cLyingInjured = CommandPlayAnimation(946);
                command cSquatEnter = CommandPlayAnimation(976);

                oTarg = UT_GetNearestCreatureByTag(oPC, "den220cr_pick4_seneshal_grd");
                WR_AddCommand(oTarg, cFaceEast, FALSE, TRUE);
                WR_AddCommand(oTarg, cDyingSoldier);
                oTarg = UT_GetNearestCreatureByTag(oPC, "den220cr_pick4_sen_grd1");
                WR_AddCommand(oTarg, cLyingKnee);
                oTarg = UT_GetNearestCreatureByTag(oPC, "den220cr_pick4_sen_grd2");
                WR_AddCommand(oTarg, cFaceWest, FALSE, TRUE);
                WR_AddCommand(oTarg, cLyingInjured);
                oTarg = UT_GetNearestCreatureByTag(oPC, "den220cr_pick4_sen_grd3");
                WR_AddCommand(oTarg, cFaceNorth, FALSE, TRUE);
                WR_AddCommand(oTarg, cSquatEnter);
                oTarg = UT_GetNearestCreatureByTag(oPC, "den220cr_pick4_sen_grd4");
                WR_AddCommand(oTarg, cSitGroundTwitch);
                oTarg = UT_GetNearestCreatureByTag(oPC, "den220cr_pick4_seneshal");
                WR_AddCommand(oTarg, cSitDying);

                UT_MoneyTakeFromObject(oPC,0,0,5);
                break;
            }


            case THIEF_PICK4_SUCCESSFUL:
            {
                // This check is so that you don't endlessly loop getting the loot
                /*if ( !WR_GetPlotFlag(PLT_DEN200PT_THIEF_PICK4, THIEF_PICK4_SUCCESSFUL) )
                {
                    UT_AddItemToInventory(DEN_IM_PICK4_CROWN);
                }*/

                int nCrowns =   UT_CountItemInInventory(DEN_IM_PICK4_CROWN);

                if(nCrowns == 0)
                {

                    UT_AddItemToInventory(DEN_IM_PICK4_CROWN);
                    // Qwinn added this to prevent getting crown through dialogue and then stealing a second copy
                    oTarg = UT_GetNearestCreatureByTag(oPC, DEN_CR_PICK4_SENESCHAL);
                    UT_RemoveItemFromInventory(DEN_IM_PICK4_CROWN, 1, oTarg);
                }

                // Flagging this so the check below can read this flag
                WR_SetPlotFlag(PLT_DEN200PT_THIEF_PICK4, THIEF_PICK4_SUCCESSFUL, TRUE, FALSE);

                // See if you should toggle quest giver notification
                // All pick pocket missions done, so if Sneak missions are available then toggle
                if ( WR_GetPlotFlag(PLT_DEN200PT_THIEF, THIEF_CHECK_IF_SNEAK_AVAILABLE) )
                {
                    WR_SetPlotFlag(PLT_DEN200PT_THIEF, COULDRY_QUEUE_UP_PLOT_GIVER, TRUE, TRUE);
                }

                if ( !WR_GetPlotFlag(PLT_DEN200PT_THIEF, PC_IS_SNEAK) )
                    WR_SetPlotFlag(PLT_DEN200PT_THIEF, THIEF_QUEST_DONE, TRUE, TRUE);

                //percentage complete plot tracking
                ACH_TrackPercentageComplete(ACH_FAKE_DENERIM_4d);

                break;
            }

        }
     }
     else   // EVENT_TYPE_GET_PLOT -> defined conditions only
     {

        switch(nFlag)
        {

            case THIEF_PICK4_PC_HAS_MONEY:      // Check to see if the PC has enough money
            {
                // Does the PC have the required fee of 6 gold?
                int bCondition  =   UT_MoneyCheck(oPC, 0, 0, 6);

                nResult = bCondition;

                break;
            }

            case THIEF_PICK4_ACTIVE:                // Is the quest in progress
            {
                int bCondition1 = WR_GetPlotFlag(PLT_DEN200PT_THIEF_PICK4, THIEF_PICK4_ASSIGNED);
                int bCondition2 = WR_GetPlotFlag(PLT_DEN200PT_THIEF_PICK4, THIEF_PICK4_SUCCESSFUL);

                nResult = bCondition1 && !bCondition2;
                break;
            }

            case GUARDS_SUSPICIOUS:                 // They are suspicious if they know the PC is a Warden
            {
                int bCondition1 = WR_GetPlotFlag(PLT_DEN200PT_THIEF_PICK4, GUARDS_TOLD_BACK_TABLE);
                int bCondition2 = WR_GetPlotFlag(PLT_DEN200PT_THIEF_PICK4, GUARDS_TOLD_MESSENGER);

                nResult = bCondition1 || bCondition2;
                break;
            }

            case GUARDS_CATCH_PC_STEALTHING:        // Do the guards catch the PC stealthing?
            {
                int bCondition1 = WR_GetPlotFlag(PLT_GEN00PT_SKILLS, GEN_STEALTH_VERY_HIGH);
                int bCondition2 = IsStealthy(oPC);
                int bCondition3 = WR_GetPlotFlag(PLT_DEN200PT_THIEF_PICK4, THIEF_PICK4_ACTIVE);
                int bCondition4 = WR_GetPlotFlag(PLT_DEN200PT_THIEF_PICK4, GUARDS_ATTACKED);

                nResult = !(bCondition1 && bCondition2) && bCondition3 && !bCondition4;

                // If the PC was stealthing, but got caught, and the quest is active
                if ( bCondition2 && nResult && bCondition3 )
                    WR_SetPlotFlag(PLT_DEN200PT_THIEF_PICK4, GUARDS_TALK_ABOUT_FAILED_PC_STEALTH, TRUE, TRUE);
                break;
            }

            case GUARD_CAUGHT_PC_STEALTHING_AND_WARNED:
            {

                int bCondition1 =   WR_GetPlotFlag(PLT_DEN200PT_THIEF_PICK4, GUARDS_CATCH_PC_STEALTHING);
                int bCondition2 =   WR_GetPlotFlag(PLT_DEN200PT_THIEF_PICK4, GUARD_WARNS_PC);

                nResult =   bCondition1 && bCondition2;

                break;

            }

        }

    }

    plot_OutputDefinedFlag(eParms, nResult);

    return nResult;
}