//==============================================================================
/*
    den200pt_ser_landry.nss
    Ser Landry's events.
*/
//==============================================================================
//  Created By: Ferret
//  Created On: June 17th, 2008
//==============================================================================

#include "log_h"
#include "utility_h"
#include "wrappers_h"
#include "plot_h"

#include "den_constants_h"

#include "plt_denpt_talked_to"
#include "plt_den200pt_ser_landry"


// This is exactly the same as UT_PartyStore, except that it will also jump
// the party members to WP's.
void PartyStoreAndJump(int nSetNeutral = FALSE);

// Qwinn:  Added this function to destroy triggers after no longer useful, hopefully reduce lag
void DestroyLandryTriggers();

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

    object  oLandry             =   UT_GetNearestCreatureByTag(oPC, DEN_CR_SER_LANDRY);
    object  oLandrySecond       =   UT_GetNearestCreatureByTag(oPC, DEN_CR_SER_LANDRY_SECOND);

    plot_GlobalPlotHandler(eParms);                                 // any global plot operations, including debug info

    if(nType == EVENT_TYPE_SET_PLOT)    // actions -> normal flags only
    {
        int nValue      =   GetEventInteger(eParms, 2);     // On SET call, the value about to be written (on a normal SET that should be '1', and on a 'clear' it should be '0')
        int nOldValue   =   GetEventInteger(eParms, 3);     // On SET call, the current flag value (can be either 1 or 0 regardless if it's a set or clear event)

        // IMPORTANT: The flag value on a SET event is set only AFTER this script finishes running!
        switch(nFlag)
        {

            case LANDRY_DUEL_ACCEPTED:              // DEN200_SER_LANDRY
                                                    // The PC agree to duel him
            {
                // Landry runs to his duel location
                UT_QuickMove(DEN_CR_SER_LANDRY, "0", TRUE);

                // Then make him non-interactive on the walk there
                SetObjectInteractive(oLandry, FALSE);

                // Spawn in his seconds
                UT_TeamAppears(DEN_TEAM_SER_LANDRY_SECONDS);

                break;
            }

            case LANDRY_DUEL_REFUSED:               // DEN200_SER_LANDRY
                                                    // The duel is refused
            {
                // He goes away, but he will ambush the player later in the back alleys
                UT_ExitDestroy(oLandry);

                DestroyLandryTriggers();

                break;
            }

            case LANDRY_RECONSIDERS_WARDENS:        // DEN200_SER_LANDRY
                                                    // He reconsiders Grey Wardens
            {
                // He goes away
                UT_ExitDestroy(oLandry);

                DestroyLandryTriggers();

                break;
            }

            case LANDRY_TURNS_AROUND:               // Ser Landry gets to his spot then turns around
            {
                // Landry becomes interactive
                SetObjectInteractive(oLandry, TRUE);

                // He turns around
                ClearAllCommands(oLandry);

                AddCommand(oLandry, CommandTurn(90.0));

                break;
            }

            case LANDRY_PC_MOVES_TOO_FAR:           // While dueling Ser Landry the fight moves too far away
            {
               /* if ( WR_GetPlotFlag(PLT_DEN200PT_SER_LANDRY, LANDRY_QUEST_DONE) ) break;

                object  oLandry =   UT_GetNearestObjectByTag(oPC, DEN_CR_SER_LANDRY);
                object  oSecond =   UT_GetNearestCreatureByTag(oPC, DEN_CR_SER_LANDRY_SECOND);

                UT_TeamGoesHostile(DEN_TEAM_SER_LANDRY_SECONDS, FALSE);
                UT_TeamGoesHostile(DEN_TEAM_SER_LANDRY, FALSE);

                // This wrapper is to prevent a double conversation - which can happen
                if ( WR_GetPlotFlag(PLT_DEN200PT_SER_LANDRY, LANDRY_BOUNDARY_ACTIVE) )
                {
                    UT_PartyRestore();

                    // Determine who will speak (if Landry is dead, then a second
                    if ( WR_GetPlotFlag(PLT_DEN200PT_SER_LANDRY, LANDRY_KILLED) )
                    {
                        //oTarg = UT_GetNearestCreatureByTag(oPC, DEN_CR_SER_LANDRY_SECOND);
                        UT_Talk(oSecond, oPC);
                    }

                    else
                    {
                        //oTarg = UT_GetNearestCreatureByTag(oPC, DEN_CR_SER_LANDRY);
                        UT_Talk(oLandry, oPC);

                    }
                    //UT_Talk(oTarg, oPC);
                }


                // Turn off the boundary
                WR_SetPlotFlag(PLT_DEN200PT_SER_LANDRY, LANDRY_BOUNDARY_ACTIVE, FALSE, FALSE);*/


                // Make it so that they player can now open the party picker again.
                //SetPartyPickerGUIStatus(PP_GUI_STATUS_USE);

                break;
            }

            case LANDRY_AND_SECONDS_LEAVE:          // DEN200_SER_LANDRY
                                                    // Ser Landry and his peeps leave
            {
                UT_TeamExit(DEN_TEAM_SER_LANDRY_SECONDS);

                UT_ExitDestroy(oLandry);

                DestroyLandryTriggers();

                //percentage complete plot tracking
                ACH_TrackPercentageComplete(ACH_FAKE_DENERIM_8);

                break;
            }

            case LANDRY_FIGHTS_ONE_ON_ONE:          // DEN200_SER_LANDRY
                                                    // An honorable duel
            {

                object  [] arParty  =   GetPartyList(oPC);
                object  oCurrent;

                int     nSize       =   GetArraySize(arParty);
                int     nLoop;

                // Make it so the PC's followers don't join in
                PartyStoreAndJump(TRUE);

                // Ser Landry Fights
                UT_TeamGoesHostile(DEN_TEAM_SER_LANDRY);

                // This tells the boundary trigger to be active - if you go past it the duel is off
                WR_SetPlotFlag(PLT_DEN200PT_SER_LANDRY, LANDRY_BOUNDARY_ACTIVE, TRUE, TRUE);

                // Make it so that they player cant choose new party members to help in the fight.
                SetPartyPickerGUIStatus(PP_GUI_STATUS_READ_ONLY);

                break;
            }

            case LANDRY_FIGHTS_WITH_MEN:            // DEN200_SER_LANDRY
                                                    // A normal fight
            {
                int bLandryRefused  =   WR_GetPlotFlag(PLT_DEN200PT_SER_LANDRY, LANDRY_DUEL_REFUSED);

                // Put Landry and his men on the same team.
                UT_TeamMerge(DEN_TEAM_SER_LANDRY_SECONDS, DEN_TEAM_SER_LANDRY);

                // Ser Landry Fights
                UT_TeamGoesHostile(DEN_TEAM_SER_LANDRY);

                /*// His Seconds Fight
                UT_TeamGoesHostile(DEN_TEAM_SER_LANDRY_SECONDS);*/

                // This tells the boundary trigger to be active - if you go past it the duel is off
                WR_SetPlotFlag(PLT_DEN200PT_SER_LANDRY, LANDRY_BOUNDARY_ACTIVE, TRUE, TRUE);

                if(bLandryRefused)
                {

                    UT_QuickMove(DEN_CR_SER_LANDRY_SEC_ARCHER, "0", TRUE, FALSE, TRUE, TRUE);

                }

                break;
            }

            case LANDRY_KILLED:                     // You kill the knights
            {
                if ( WR_GetPlotFlag(PLT_DEN200PT_SER_LANDRY, LANDRY_FIGHTS_ONE_ON_ONE) )
                {
                    // This tells the boundary to turn off - no longer relevant
                    WR_SetPlotFlag(PLT_DEN200PT_SER_LANDRY, LANDRY_BOUNDARY_ACTIVE, FALSE, FALSE);

                    UT_PartyRestore();

                    // Make it so that they player can now open the party picker again.
                    //SetPartyPickerGUIStatus(PP_GUI_STATUS_USE);  - no longer enabled for market
                }


                WR_SetPlotFlag(PLT_DEN200PT_SER_LANDRY, LANDRY_QUEST_DONE, TRUE, TRUE);

                break;
            }

            case LANDRY_QUEST_DONE:                 // After killing Ser Landry
            {
                // His seconds speak
                if ( WR_GetPlotFlag(PLT_DEN200PT_SER_LANDRY, LANDRY_FIGHTS_ONE_ON_ONE) )
                {

                    UT_Talk(oLandrySecond, oPC);

                }

                //percentage complete plot tracking
                ACH_TrackPercentageComplete(ACH_FAKE_DENERIM_8);

                DestroyLandryTriggers();

                break;
            }

            case LANDRY_POST_LANDSMEET_HANDLING:    // You've finished the Landsmeet, tie up this quest
            {
                // If the PC accepted the duel, then disappear any combatants and flag the journal
                if ( WR_GetPlotFlag(PLT_DEN200PT_SER_LANDRY, LANDRY_DUEL_ACCEPTED) &&
                    !WR_GetPlotFlag(PLT_DEN200PT_SER_LANDRY, LANDRY_QUEST_DONE) )
                {
                    UT_TeamAppears(DEN_TEAM_SER_LANDRY, FALSE);

                    UT_TeamAppears(DEN_TEAM_SER_LANDRY_SECONDS, FALSE);

                    WR_SetPlotFlag(PLT_DEN200PT_SER_LANDRY, LANDRY_QUEST_ABORTED, TRUE, TRUE);
                }

                else UT_TeamAppears(DEN_TEAM_SER_LANDRY, FALSE);

                DestroyLandryTriggers();

                break;
            }
        }
     }
     else   // EVENT_TYPE_GET_PLOT -> defined conditions only
     {

        switch(nFlag)
        {


        }

    }

    plot_OutputDefinedFlag(eParms, nResult);

    return nResult;
}

void DestroyLandryTriggers()
{
    if ((!WR_GetPlotFlag(PLT_DEN200PT_SER_LANDRY, LANDRY_DUEL_REFUSED)) &&
        (!WR_GetPlotFlag(PLT_DEN200PT_SER_LANDRY, LANDRY_RECONSIDERS_WARDENS)) &&
        (!WR_GetPlotFlag(PLT_DEN200PT_SER_LANDRY, LANDRY_AND_SECONDS_LEAVE)) &&
        (!WR_GetPlotFlag(PLT_DEN200PT_SER_LANDRY, LANDRY_QUEST_DONE)) &&
        (!WR_GetPlotFlag(PLT_DEN200PT_SER_LANDRY, LANDRY_POST_LANDSMEET_HANDLING)))
    {
       object oPC = GetHero();
       object oTrig = UT_GetNearestObjectByTag(oPC,"den200tr_landry_speaks");
       Safe_Destroy_Object(oTrig);
       oTrig = UT_GetNearestObjectByTag(oPC,"den200tr_landry_turns_aroun");
       Safe_Destroy_Object(oTrig);
       oTrig = UT_GetNearestObjectByTag(oPC,"den200tr_landry_duel_talk");
       Safe_Destroy_Object(oTrig);
       oTrig = UT_GetNearestObjectByTag(oPC,"den200tr_duel_boundary");
       Safe_Destroy_Object(oTrig);
    }
}


void PartyStoreAndJump(int nSetNeutral = FALSE)
{
    Log_Trace(LOG_CHANNEL_SYSTEMS, "utility_h.UT_PartyStore", "Storing active party (up to 3 followers can be stores)");

    object [] arParty = GetPartyList(GetPartyLeader());
    int nSize = GetArraySize(arParty);
    int i;
    SetLocalObject(GetModule(), PARTY_STORE_SLOT_1, OBJECT_INVALID);
    SetLocalObject(GetModule(), PARTY_STORE_SLOT_2, OBJECT_INVALID);
    SetLocalObject(GetModule(), PARTY_STORE_SLOT_3, OBJECT_INVALID);

    RemoveAllSummons();

    object oCurrent;
    for(i = 0; i < nSize; i++)
    {
        oCurrent = arParty[i];
        Log_Trace(LOG_CHANNEL_SYSTEMS, "utility_h.UT_PartyStore", "current party member: " + GetTag(oCurrent));

        if(IsFollower(oCurrent) && !IsHero(oCurrent))
        {
            Log_Trace(LOG_CHANNEL_SYSTEMS, "utility_h.UT_PartyStore", "STORING CURRENT PARTY MEMBER");
            if(GetLocalObject(GetModule(), PARTY_STORE_SLOT_1) == OBJECT_INVALID)
            {
                SetLocalObject(GetModule(), PARTY_STORE_SLOT_1, oCurrent);
                WR_SetFollowerState(oCurrent, FOLLOWER_STATE_UNAVAILABLE);
                if(nSetNeutral)
                    SetGroupId(oCurrent, GROUP_NEUTRAL);

                UT_LocalJump(oCurrent, DEN_WP_PARTY_MEMBER_1, TRUE);
            }

            else if(GetLocalObject(GetModule(), PARTY_STORE_SLOT_2) == OBJECT_INVALID)
            {
                SetLocalObject(GetModule(), PARTY_STORE_SLOT_2, oCurrent);
                WR_SetFollowerState(oCurrent, FOLLOWER_STATE_UNAVAILABLE);
                if(nSetNeutral)
                    SetGroupId(oCurrent, GROUP_NEUTRAL);

                 UT_LocalJump(oCurrent, DEN_WP_PARTY_MEMBER_2, TRUE);
            }

            else if(GetLocalObject(GetModule(), PARTY_STORE_SLOT_3) == OBJECT_INVALID)
            {
                SetLocalObject(GetModule(), PARTY_STORE_SLOT_3, oCurrent);
                WR_SetFollowerState(oCurrent, FOLLOWER_STATE_UNAVAILABLE);
                if(nSetNeutral)
                    SetGroupId(oCurrent, GROUP_NEUTRAL);

                UT_LocalJump(oCurrent, DEN_WP_PARTY_MEMBER_3, TRUE);

            }

        }

    }
    Log_Trace(LOG_CHANNEL_SYSTEMS, "utility_h.UT_PartyStore", "END");
}